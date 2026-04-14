unit UnitMeasurementRun;

interface

uses
  UnitBaseProcedures,
  UnitWorkTable,
  UnitDeviceClass,
  UnitClasses,
  UnitRepositories,
  UnitFlowMeter,
  UnitMeterValue,
  UnitDataManager,

  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,

  System.Math,
  System.StrUtils,
  System.IniFiles;

type

  TMeasurementRunStateChangedEvent = procedure(ASender: TObject; AState: EMeasurementState) of object;
  TMeasurementRunPointChangedEvent = procedure(ASender: TObject; APoint: TDevicePoint;
    APointIndex: Integer) of object;



  TMeasurementRun = class

  private
    FWorkTable: TWorkTable;
    FPoints: TObjectList<TDevicePoint>;

    FCurrentPointIndex: Integer;
    FThread: TThread;
    FCriticalSection: TCriticalSection;
    FMode: EMeasurementRunMode;

    FManualFlowRate: Double;
    FManualFluidTemp: Double;
    FManualFluidPress: Double;
    FManualTimeSet: Integer;

    FCurrentStage: EMeasurementState;

    FWaitStartedTick: UInt64;
    FCurrentRepeat: Integer;
    FIsPaused: Boolean;
    FForceNextPoint: Boolean;

    FOnStateChangedFrame: TMeasurementRunStateChangedEvent;
    FOnStateChangedMain: TMeasurementRunStateChangedEvent;
    FOnPointChangedFrame: TMeasurementRunPointChangedEvent;
    FOnPointChangedMain: TMeasurementRunPointChangedEvent;

    procedure SetState(const ANewState: EMeasurementState);
    procedure NotifyStateChanged;
    procedure NotifyPointChanged;
    function GetCurrentPoint: TDevicePoint;

    procedure RunThreadProc;
    function IsThreadRunning: Boolean;

    function IsStable: Boolean;
    function IsTerminated: Boolean;
  public
    constructor Create(AWorkTable: TWorkTable);
    destructor Destroy; override;

    procedure CreateSession;
    procedure CreateSessionPoints;
    function IsSessionPointFit(ADevice: TDevice; APoint: TDevicePoint): Boolean;

    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    procedure NextPoint;

    procedure Process;
    procedure SaveMeasurementResults;

    class function SpillStateToString(AState: EMeasurementState): string; static;
    class function SpillStateFromString(const AValue: string): EMeasurementState; static;

    property WorkTable: TWorkTable read FWorkTable;
    property Points: TObjectList<TDevicePoint> read FPoints;

    property Stage: EMeasurementState read FCurrentStage;

    property Mode: EMeasurementRunMode read FMode write FMode;
    property CurrentPointIndex: Integer read FCurrentPointIndex;
    property CurrentPoint: TDevicePoint read GetCurrentPoint;

    property ManualFlowRate: Double read FManualFlowRate write FManualFlowRate;
    property ManualFluidTemp: Double read FManualFluidTemp write FManualFluidTemp;
    property ManualFluidPress: Double read FManualFluidPress write FManualFluidPress;
    property ManualTimeSet: Integer read FManualTimeSet write FManualTimeSet;

    property OnStateChangedFrame: TMeasurementRunStateChangedEvent
      read FOnStateChangedFrame write FOnStateChangedFrame;
    property OnStateChangedMain: TMeasurementRunStateChangedEvent
      read FOnStateChangedMain write FOnStateChangedMain;
    property OnPointChangedFrame: TMeasurementRunPointChangedEvent
      read FOnPointChangedFrame write FOnPointChangedFrame;
    property OnPointChangedMain: TMeasurementRunPointChangedEvent
      read FOnPointChangedMain write FOnPointChangedMain;
  end;

implementation

function AccuracyToRange(const AAccuracy: string; out AMin, AMax: Double): Boolean;
var
  Normalized: string;
  Value: Double;
begin
  Result := False;
  AMin := 0;
  AMax := 0;

  Normalized := NormalizeAccuracyInput(AAccuracy);
  if Normalized = '' then
    Exit;

  if StartsText('+', Normalized) then
  begin
    Value := Abs(NormalizeFloatInput(Copy(Normalized, 2, MaxInt)));
    AMin := 0;
    AMax := Value;
  end
  else if StartsText('-', Normalized) then
  begin
    Value := Abs(NormalizeFloatInput(Copy(Normalized, 2, MaxInt)));
    AMin := -Value;
    AMax := 0;
  end
  else
  begin
    Value := Abs(NormalizeFloatInput(Normalized));
    AMin := -Value;
    AMax := Value;
  end;

  Result := True;
end;

function GetAccuracyWidth(const AAccuracy: string): Double;
var
  MinVal, MaxVal: Double;
begin
  if not AccuracyToRange(AAccuracy, MinVal, MaxVal) then
    Exit(MaxDouble);
  Result := MaxVal - MinVal;
end;

function IsFlowFit(AQ1: Double; AAccuracy: string; AQ2: Double): Boolean;
var
  MinPercent, MaxPercent: Double;
  MinQ, MaxQ: Double;
  TempValue: Double;
begin
  if AQ1 <= 0 then
    Exit(SameValue(AQ1, AQ2));

  if not AccuracyToRange(AAccuracy, MinPercent, MaxPercent) then
  begin
    MinPercent := -10;
    MaxPercent := 10;
  end;

  MinQ := AQ1 + (AQ1 * MinPercent / 100.0);
  MaxQ := AQ1 + (AQ1 * MaxPercent / 100.0);

  if MinQ > MaxQ then
  begin
    TempValue := MinQ;
    MinQ := MaxQ;
    MaxQ := TempValue;
  end;

  Result := InRange(AQ2, MinQ, MaxQ);
end;

function IsTemperatureFit(ATemp1: Double; ATempAccuracy: string; ATemp2: Double): Boolean;
var
  MinDelta, MaxDelta: Double;
  Delta: Double;
begin
  if SameValue(ATemp1, 0) and SameValue(ATemp2, 0) then
    Exit(True);

  if SameValue(ATemp1, 0) xor SameValue(ATemp2, 0) then
    Exit(False);

  if not AccuracyToRange(ATempAccuracy, MinDelta, MaxDelta) then
    Exit(SameValue(ATemp1, ATemp2));

  Delta := ATemp2 - ATemp1;
  Result := InRange(Delta, MinDelta, MaxDelta);
end;

function GetMostStrictAccuracy(const A1, A2: string): string;
begin
  if Trim(A1) = '' then
    Exit(A2);
  if Trim(A2) = '' then
    Exit(A1);

  if GetAccuracyWidth(A1) <= GetAccuracyWidth(A2) then
    Result := A1
  else
    Result := A2;
end;

function IsStopCriteriaFit(ADevicePoint, ASessionPoint: TDevicePoint): Boolean;
begin
  Result := True;
  if (ADevicePoint = nil) or (ASessionPoint = nil) then
    Exit(False);

  if (scImpulse in ASessionPoint.StopCriteria) and (ADevicePoint.LimitImp < ASessionPoint.LimitImp) then
    Exit(False);

  if (scVolume in ASessionPoint.StopCriteria) and (ADevicePoint.LimitVolume < ASessionPoint.LimitVolume) then
    Exit(False);

  if (scTime in ASessionPoint.StopCriteria) and (ADevicePoint.LimitTime < ASessionPoint.LimitTime) then
    Exit(False);
end;

function IsPointEquivalent(AP1, AP2: TDevicePoint): Boolean;
begin
  Result := (AP1 <> nil) and (AP2 <> nil)
    and IsFlowFit(AP1.Q, AP1.FlowAccuracy, AP2.Q)
    and IsTemperatureFit(AP1.Temp, AP1.TempAccuracy, AP2.Temp);
end;

procedure MergePointParams(ATarget, ASource: TDevicePoint);
begin
  if (ATarget = nil) or (ASource = nil) then
    Exit;

  ATarget.StopCriteria := ATarget.StopCriteria + ASource.StopCriteria;
  ATarget.LimitImp := Max(ATarget.LimitImp, ASource.LimitImp);
  ATarget.LimitVolume := Max(ATarget.LimitVolume, ASource.LimitVolume);
  ATarget.LimitTime := Max(ATarget.LimitTime, ASource.LimitTime);
  ATarget.Pause := Max(ATarget.Pause, ASource.Pause);
  ATarget.RepeatsProtocol := Max(ATarget.RepeatsProtocol, ASource.RepeatsProtocol);
  ATarget.Repeats := Max(ATarget.Repeats, ASource.Repeats);
  ATarget.Pressure := Max(ATarget.Pressure, ASource.Pressure);
  ATarget.FlowAccuracy := GetMostStrictAccuracy(ATarget.FlowAccuracy, ASource.FlowAccuracy);
  ATarget.TempAccuracy := GetMostStrictAccuracy(ATarget.TempAccuracy, ASource.TempAccuracy);
end;

{ TMeasurementRun }

constructor TMeasurementRun.Create(AWorkTable: TWorkTable);
begin
  inherited Create;
  FWorkTable := AWorkTable;
  FPoints := TObjectList<TDevicePoint>.Create(True);
  FCriticalSection := TCriticalSection.Create;

  FCurrentPointIndex := -1;
  FMode := mrmAutomatic;

  FManualFlowRate := 0;
  FManualFluidTemp := 20;
  FManualFluidPress := 1;
  FManualTimeSet := 60;

  FCurrentStage := msNone;
end;

destructor TMeasurementRun.Destroy;
begin
  Stop;
  FreeAndNil(FCriticalSection);
  FreeAndNil(FPoints);
  inherited Destroy;
end;

procedure TMeasurementRun.SetState(const ANewState: EMeasurementState);
begin

  NotifyStateChanged;
end;

procedure TMeasurementRun.NotifyStateChanged;
begin
  if Assigned(FOnStateChangedFrame) then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(FOnStateChangedFrame) then
          FOnStateChangedFrame(Self, FCurrentStage);
      end);

  if Assigned(FOnStateChangedMain) then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(FOnStateChangedMain) then
          FOnStateChangedMain(Self, FCurrentStage);
      end);
end;

procedure TMeasurementRun.NotifyPointChanged;
begin
  if Assigned(FOnPointChangedFrame) then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(FOnPointChangedFrame) then
          FOnPointChangedFrame(Self, GetCurrentPoint, FCurrentPointIndex);
      end);

  if Assigned(FOnPointChangedMain) then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(FOnPointChangedMain) then
          FOnPointChangedMain(Self, GetCurrentPoint, FCurrentPointIndex);
      end);
end;

function TMeasurementRun.GetCurrentPoint: TDevicePoint;
begin
  Result := nil;
  if (FCurrentPointIndex >= 0) and (FCurrentPointIndex < FPoints.Count) then
    Result := FPoints[FCurrentPointIndex];
end;

function TMeasurementRun.IsThreadRunning: Boolean;
begin
  Result := Assigned(FThread) and (not FThread.Finished);
end;

function TMeasurementRun.IsStable: Boolean;
var
  ParamStatus: Boolean;
begin
  Result := True;

  if (FWorkTable = nil) then
    Exit;

  if (FWorkTable.FlowRate <> nil) and (GetCurrentPoint.Q<>0)  then
    Result := Result and FWorkTable.FlowRate.IsStable(ParamStatus);

  if (FWorkTable.FluidTemp <> nil) and  (GetCurrentPoint.Temp<>0) then
    Result := Result and FWorkTable.FluidTemp.IsStable(ParamStatus);

  if (FWorkTable.FluidPress <> nil) and  (GetCurrentPoint.Pressure<>0) then
    Result := Result and FWorkTable.FluidPress.IsStable(ParamStatus);
end;

function TMeasurementRun.IsTerminated: Boolean;
begin
  Result := (FThread = nil) or FThread.CheckTerminated;
end;

procedure TMeasurementRun.CreateSession;
var
  SourcePoint: TDevicePoint;
  ManualPoint: TDevicePoint;
begin
  FPoints.Clear;

  if FMode = mrmManual then
  begin
    ManualPoint := TDevicePoint.Create(0);
    ManualPoint.FlowRate := 1; //FManualFlowRate;
    ManualPoint.Q := FWorkTable.FlowRate.ValueSet;
    ManualPoint.Temp := FWorkTable.FluidTemp.ValueSet;
    ManualPoint.Pressure := FWorkTable.FluidPress.ValueSet;
    ManualPoint.LimitTime := FWorkTable.TimeSet;
    ManualPoint.Repeats := FWorkTable.Repeats;
    ManualPoint.RepeatsProtocol := FWorkTable.Repeats;
    ManualPoint.Num := 1;
    FPoints.Add(ManualPoint);
    Exit;
  end;

  if FWorkTable = nil then
    Exit;

  CreateSessionPoints;
   {
  for SourcePoint in FWorkTable.Points do
  begin
    ManualPoint := TDevicePoint.Create(0);
    ManualPoint.Assign(SourcePoint);
    FPoints.Add(ManualPoint);
  end;
  }
end;

procedure TMeasurementRun.CreateSessionPoints;
var
  Channel: TChannel;
  Device: TDevice;
  SourcePoint: TDevicePoint;
  SessionPoint: TDevicePoint;
  ExistingPoint: TDevicePoint;
begin
  if FPoints = nil then
    FPoints := TObjectList<TDevicePoint>.Create(True);

  FPoints.Clear;

  for Channel in FWorkTable.DeviceChannels do
  begin
    if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
      Continue;

    Device := Channel.FlowMeter.Device;
    if (Device = nil) or (Device.Points = nil) then
      Continue;

    for SourcePoint in Device.Points do
    begin
      ExistingPoint := nil;
      for SessionPoint in FPoints do
        if IsPointEquivalent(SessionPoint, SourcePoint) then
        begin
          ExistingPoint := SessionPoint;
          Break;
        end;

      if ExistingPoint = nil then
      begin
        SessionPoint := TDevicePoint.Create(0);
        SessionPoint.Assign(SourcePoint);
        SessionPoint.Status:=0;
        FPoints.Add(SessionPoint);
      end
      else
        MergePointParams(ExistingPoint, SourcePoint);
    end;
  end;
end;

function TMeasurementRun.IsSessionPointFit(ADevice: TDevice; APoint: TDevicePoint): Boolean;
var
  DevicePoint: TDevicePoint;
begin
  Result := False;
  if (ADevice = nil) or (APoint = nil) or (ADevice.Points = nil) then
    Exit;

  for DevicePoint in ADevice.Points do
  begin
    if not IsFlowFit(DevicePoint.Q, DevicePoint.FlowAccuracy, APoint.Q) then
      Continue;

    if not IsTemperatureFit(DevicePoint.Temp, DevicePoint.TempAccuracy, APoint.Temp) then
      Continue;

    if not IsStopCriteriaFit(DevicePoint, APoint) then
      Continue;

    if DevicePoint.Pause < APoint.Pause then
      Continue;

    if DevicePoint.RepeatsProtocol < APoint.RepeatsProtocol then
      Continue;

    if DevicePoint.Repeats < APoint.Repeats then
      Continue;

    Exit(True);
  end;
end;

procedure TMeasurementRun.Start;
begin
  FCriticalSection.Acquire;
  try
    if IsThreadRunning then
      Exit;
    if Assigned(FThread) then
      FreeAndNil(FThread);

    CreateSessionPoints;
    if FPoints.Count = 0 then
    begin
      SetState(msNone);
      Exit;
    end;

    FCurrentPointIndex := 0;
    FCurrentStage := msSelectPoint;
    FCurrentRepeat := 0;
    FForceNextPoint := False;
    FIsPaused := False;

//    SetState();

    NotifyPointChanged;

    FThread := TThread.CreateAnonymousThread(
      procedure
      begin
        RunThreadProc;
      end);
    FThread.FreeOnTerminate := False;
    FThread.Start;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TMeasurementRun.Stop;
var
  LThread: TThread;
begin
  FCriticalSection.Acquire;
  try
    LThread := FThread;
    FThread := nil;
  finally
    FCriticalSection.Release;
  end;

  if LThread <> nil then
  begin
    LThread.Terminate;
    LThread.WaitFor;
    LThread.Free;
  end;

  FIsPaused := False;
 // SetState(msStopping);
  SetState(msNone);
end;

procedure TMeasurementRun.Pause;
begin
  if FIsPaused then
    Exit;
  FIsPaused := True;
  //SetState(msPause);
end;

procedure TMeasurementRun.Resume;
begin
  if not FIsPaused then
    Exit;
  FIsPaused := False;
  //SetState(msOnGoing);
end;

procedure TMeasurementRun.NextPoint;
begin
  FForceNextPoint := True;
end;

procedure TMeasurementRun.RunThreadProc;
begin
 // SetState(msOnGoing);
  while not TThread.CurrentThread.CheckTerminated do
  begin
    if FIsPaused then
    begin
      TThread.Sleep(50);
      Continue;
    end;

    Process;
    TThread.Sleep(10);
  end;
end;

procedure TMeasurementRun.Process;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
begin
  if IsTerminated then
    Exit;

  Point := GetCurrentPoint;
  if Point = nil then
  begin
    FCurrentStage := msDone ;
    //SetState(msResultReady);
    Exit;
  end;

  case FCurrentStage of

   //Установка параметров точки
    msSelectPoint:
      begin

       FWorkTable.StartMonitor;

        if FWorkTable <> nil then
        begin

          // Если не указан расход, то на него не выходим
          if (Point.Q<>0) then
          begin
          FWorkTable.FlowRate.DoFlowRateSet(Point.Q);
          FWorkTable.FlowRate.DoFlowRateStart;
          end;

          if Point.Temp<>0 then
          FWorkTable.FluidTemp.DoFluidTempStart(Point.Temp);

          if Point.Pressure<>0 then
          FWorkTable.FluidPress.DoFluidPressStart(Point.Pressure);

          if Point.LimitTime > 0 then
            FWorkTable.TimeSet := Round(Point.LimitTime);

        end;
        FWaitStartedTick := TThread.GetTickCount64;
        FCurrentStage := msSelectEtalon;
      end;

    msSetupPoint:
      begin
         //Принудительное изменение точки
        if FForceNextPoint then
        begin
          FCurrentStage := msSelectPoint;
          Exit;
        end;

        //Если вышли на расход, то переходим к измерению
        if IsStable then
          FCurrentStage := msMeasure

        //Ограничение времени ожидания стабилизации
        else if (TThread.GetTickCount64 - FWaitStartedTick) > 30000 then
          FCurrentStage := msMeasure;

      end;

    msMeasure:
      begin
        if FForceNextPoint then
        begin
          FCurrentStage := msSelectPoint;
          Exit;
        end;

        RepeatsTarget := Point.Repeats;
        if RepeatsTarget <= 0 then
          RepeatsTarget := 1;

        Inc(FCurrentRepeat);
        if FCurrentRepeat >= RepeatsTarget then
          FCurrentStage := msSave;
      end;

    msSave:
      begin
        SaveMeasurementResults;
        FCurrentStage := msSelectPoint;
      end;

    msResultsRead:
      begin
        FForceNextPoint := False;
        FCurrentRepeat := 0;
        Inc(FCurrentPointIndex);
        if FCurrentPointIndex >= FPoints.Count then
        begin
          FCurrentStage := msDone;
          SetState(msResultsRead);
        end
        else
        begin
          NotifyPointChanged;
          FCurrentStage := msSetupPoint;
        end;
      end;

    msDone:
      begin
        if FThread <> nil then
          FThread.Terminate;
      end;
  end;
end;

procedure TMeasurementRun.SaveMeasurementResults;
var
  Point: TDevicePoint;
begin
  Point := GetCurrentPoint;
  if Point = nil then
    Exit;

  Point.DateTime := Now;
  Point.Status := 1;
  Point.StatusStr := 'Measured';

  if FWorkTable <> nil then
    FWorkTable.TimeResult := Point.LimitTime;
end;

{ Converts persisted string to spill state enum value. }
class function TMeasurementRun.SpillStateFromString(const AValue: string): EMeasurementState;
begin
  if SameText(AValue, 'Готов') then
 // Exit(msNone);

  if SameText(AValue, 'Запуск') then
  //  Exit(msStarting);

  if SameText(AValue, 'Измерние') then
  ///  Exit(msOnGoing);

  if SameText(AValue, 'Остановка') then
   // Exit(msStopping);

  if SameText(AValue, 'Сохранение') then
  //  Exit(msResultReady);

  Result := msNone;
end;

{ Converts spill state enum value to persisted string. }
class function TMeasurementRun.SpillStateToString(AState: EMeasurementState): string;
begin
  case AState of
   msNone:
          Result := '-';
  {
    msReady:
      Result := 'Готов';
  //  msStarting:
      Result := 'Запуск';
 //   msOnGoing:
      Result := 'Измерние';
 //   msStopping:
      Result := 'Остановка';
 //   msResultReady:
      Result := 'Сохранение';  }
  else
    Result := '-';
  end;
end;

end.
