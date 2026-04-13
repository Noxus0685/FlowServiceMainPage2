unit UnitMeasurementRun;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  UnitWorkTable,
  UnitDeviceClass,
  UnitClasses;

type
  TMeasurementRunMode = (mrmManual, mrmAutomatic);

  TMeasurementRunStateChangedEvent = procedure(ASender: TObject; AState: TSpillState) of object;
  TMeasurementRunPointChangedEvent = procedure(ASender: TObject; APoint: TDevicePoint;
    APointIndex: Integer) of object;

  TMeasurementRun = class
  private type
    TPointStage = (psSetupPoint, psWaitStable, psMeasure, psSave, psNextPoint, psDone);
  private
    FWorkTable: TWorkTable;
    FPoints: TObjectList<TDevicePoint>;
    FState: TSpillState;
    FCurrentPointIndex: Integer;
    FThread: TThread;
    FCriticalSection: TCriticalSection;
    FMode: TMeasurementRunMode;

    FManualFlowRate: Double;
    FManualFluidTemp: Double;
    FManualFluidPress: Double;
    FManualTimeSet: Integer;

    FCurrentStage: TPointStage;
    FWaitStartedTick: UInt64;
    FCurrentRepeat: Integer;
    FIsPaused: Boolean;
    FForceNextPoint: Boolean;

    FOnStateChangedFrame: TMeasurementRunStateChangedEvent;
    FOnStateChangedMain: TMeasurementRunStateChangedEvent;
    FOnPointChangedFrame: TMeasurementRunPointChangedEvent;
    FOnPointChangedMain: TMeasurementRunPointChangedEvent;

    procedure SetState(const ANewState: TSpillState);
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

    procedure CreateSessionPoints;
    function IsSessionPointFit(ADevice: TDevice; APoint: TDevicePoint): Boolean;

    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    procedure NextPoint;

    procedure Process;
    procedure SaveMeasurementResults;

    property WorkTable: TWorkTable read FWorkTable;
    property Points: TObjectList<TDevicePoint> read FPoints;
    property State: TSpillState read FState;
    property Mode: TMeasurementRunMode read FMode write FMode;
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

{ TMeasurementRun }

constructor TMeasurementRun.Create(AWorkTable: TWorkTable);
begin
  inherited Create;
  FWorkTable := AWorkTable;
  FPoints := TObjectList<TDevicePoint>.Create(True);
  FCriticalSection := TCriticalSection.Create;

  FState := ssReady;
  FCurrentPointIndex := -1;
  FMode := mrmAutomatic;

  FManualFlowRate := 0;
  FManualFluidTemp := 20;
  FManualFluidPress := 1;
  FManualTimeSet := 60;

  FCurrentStage := psDone;
end;

destructor TMeasurementRun.Destroy;
begin
  Stop;
  FreeAndNil(FCriticalSection);
  FreeAndNil(FPoints);
  inherited Destroy;
end;

procedure TMeasurementRun.SetState(const ANewState: TSpillState);
begin
  if FState = ANewState then
    Exit;
  FState := ANewState;
  NotifyStateChanged;
end;

procedure TMeasurementRun.NotifyStateChanged;
begin
  if Assigned(FOnStateChangedFrame) then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(FOnStateChangedFrame) then
          FOnStateChangedFrame(Self, FState);
      end);

  if Assigned(FOnStateChangedMain) then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(FOnStateChangedMain) then
          FOnStateChangedMain(Self, FState);
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
begin
  Result := True;

  if (FWorkTable = nil) then
    Exit;

  if FWorkTable.FlowRate <> nil then
    Result := Result and FWorkTable.FlowRate.IsStable;

  if FWorkTable.FluidTemp <> nil then
    Result := Result and FWorkTable.FluidTemp.IsStable;

  if FWorkTable.FluidPress <> nil then
    Result := Result and FWorkTable.FluidPress.IsStable;
end;

function TMeasurementRun.IsTerminated: Boolean;
begin
  Result := (FThread = nil) or FThread.CheckTerminated;
end;

procedure TMeasurementRun.CreateSessionPoints;
var
  SourcePoint: TDevicePoint;
  ManualPoint: TDevicePoint;
begin
  FPoints.Clear;

  if FMode = mrmManual then
  begin
    ManualPoint := TDevicePoint.Create(0);
    ManualPoint.FlowRate := FManualFlowRate;
    ManualPoint.Q := FManualFlowRate;
    ManualPoint.Temp := FManualFluidTemp;
    ManualPoint.Pressure := FManualFluidPress;
    ManualPoint.LimitTime := FManualTimeSet;
    ManualPoint.Repeats := 1;
    ManualPoint.RepeatsProtocol := 1;
    ManualPoint.Num := 1;
    FPoints.Add(ManualPoint);
    Exit;
  end;

  if FWorkTable = nil then
    Exit;

  FWorkTable.CreateSessionPoints;

  for SourcePoint in FWorkTable.Points do
  begin
    ManualPoint := TDevicePoint.Create(0);
    ManualPoint.Assign(SourcePoint);
    FPoints.Add(ManualPoint);
  end;
end;

function TMeasurementRun.IsSessionPointFit(ADevice: TDevice; APoint: TDevicePoint): Boolean;
begin
  Result := False;
  if FWorkTable = nil then
    Exit;
  Result := FWorkTable.IsSessionPointFit(ADevice, APoint);
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
      SetState(ssReady);
      Exit;
    end;

    FCurrentPointIndex := 0;
    FCurrentStage := psSetupPoint;
    FCurrentRepeat := 0;
    FForceNextPoint := False;
    FIsPaused := False;
    SetState(ssStarting);
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
  SetState(ssStopping);
  SetState(ssReady);
end;

procedure TMeasurementRun.Pause;
begin
  if FIsPaused then
    Exit;
  FIsPaused := True;
  SetState(ssStopping);
end;

procedure TMeasurementRun.Resume;
begin
  if not FIsPaused then
    Exit;
  FIsPaused := False;
  SetState(ssOnGoing);
end;

procedure TMeasurementRun.NextPoint;
begin
  FForceNextPoint := True;
end;

procedure TMeasurementRun.RunThreadProc;
begin
  SetState(ssOnGoing);
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
    FCurrentStage := psDone;
    SetState(ssResultReady);
    Exit;
  end;

  case FCurrentStage of
    psSetupPoint:
      begin
        if FWorkTable <> nil then
        begin
          FWorkTable.FlowRate.DoFlowRateSet(Point.Q);
          FWorkTable.FluidTemp.DoFluidTempStart(Point.Temp);
          FWorkTable.FluidPress.DoFluidPressStart(Point.Pressure);
          if Point.LimitTime > 0 then
            FWorkTable.TimeSet := Round(Point.LimitTime);
        end;
        FWaitStartedTick := TThread.GetTickCount64;
        FCurrentStage := psWaitStable;
      end;

    psWaitStable:
      begin
        if FForceNextPoint then
        begin
          FCurrentStage := psNextPoint;
          Exit;
        end;

        if IsStable then
          FCurrentStage := psMeasure
        else if (TThread.GetTickCount64 - FWaitStartedTick) > 30000 then
          FCurrentStage := psMeasure;
      end;

    psMeasure:
      begin
        if FForceNextPoint then
        begin
          FCurrentStage := psNextPoint;
          Exit;
        end;

        RepeatsTarget := Point.Repeats;
        if RepeatsTarget <= 0 then
          RepeatsTarget := 1;

        Inc(FCurrentRepeat);
        if FCurrentRepeat >= RepeatsTarget then
          FCurrentStage := psSave;
      end;

    psSave:
      begin
        SaveMeasurementResults;
        FCurrentStage := psNextPoint;
      end;

    psNextPoint:
      begin
        FForceNextPoint := False;
        FCurrentRepeat := 0;
        Inc(FCurrentPointIndex);
        if FCurrentPointIndex >= FPoints.Count then
        begin
          FCurrentStage := psDone;
          SetState(ssResultReady);
        end
        else
        begin
          NotifyPointChanged;
          FCurrentStage := psSetupPoint;
        end;
      end;

    psDone:
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

end.
