unit UnitMeasurementRun;

{
  TMeasurementRun – Measurement Process Orchestrator (FSM)

  Purpose
  -------
  TMeasurementRun is a high-level controller responsible for executing
  the full measurement cycle. It operates as a finite state machine (FSM)
  and manages the sequence of stages required to perform measurements.

  It acts as a layer above TWorkTable and uses it as a low-level executor
  (hardware / bench interface).

  Responsibilities
  ----------------
  - Build measurement session (CreateSession)
  - Iterate through measurement points
  - Control stage transitions (FSM)
  - Set process parameters (flow, temperature, pressure)
  - Wait for system stabilization
  - Start and monitor measurement process
  - Handle timeouts and retry logic
  - Read and validate results
  - Save results
  - Notify external systems via events

  Architecture
  ------------
  UI / API → Execute(Command)
           → TMeasurementRun (FSM)
           → TWorkTable (executor)
           → FireEvent(Event)
           → UI / Log / API

  Key Concepts
  ------------
  - Stage (EMeasurementStage)
      Internal state of the FSM. Defines current step of measurement.

  - Command (EMeasurementCommand)
      External control input. Used to управляe execution (Start, Stop, etc).

  - Event (EMeasurementEvent)
      Output notification. Used to inform UI/API about state changes.

  Design Rules
  ------------
  1. All logic MUST be implemented inside ProcessStage().
  2. Stage transitions MUST only happen via SetStage().
  3. UI MUST NOT directly control TWorkTable.
  4. TWorkTable MUST NOT contain measurement logic.
  5. Events MUST NOT change system state (no feedback control).
  6. Commands are the only external control mechanism.

  WorkTable Contract
  ------------------
  TWorkTable is treated as a passive executor and must provide:

    - StartTest / StopTest
    - StartMonitor
    - FlowRate / FluidTemp / FluidPress control
    - State (STATE_EXECUTE, STATE_COMPLETE, etc.)
    - Data access (Flow, Temp, Pressure, Quantity, Time)
    - Stability flags (IsStable)

  TMeasurementRun must NOT rely on hidden logic inside TWorkTable.

  Typical Flow
  ------------
    msSelectPoint
      → msSelectEtalon
      → msSetupPoint
      → msWaitStable
      → msMeasure
      → msResultsRead
      → msSave
      → msNextPoint
      → msDone

  Error Handling
  --------------
  All errors are reported via FireEvent with TErrorInfo.
  No exceptions should break the FSM execution flow.

  Threading
  ---------
  TMeasurementRun may run in a worker thread.
  UI updates MUST be synchronized via events.

  Notes
  -----
  This class is the single source of truth for measurement logic.
  Any duplication of logic in UI or TWorkTable is prohibited.
}

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
  System.IniFiles,
  System.Variants,
  UnitProtocols;

type

  TMeasurementRunStateChangedEvent = procedure(ASender: TObject; AState: EMeasurementState) of object;
  TMeasurementRunPointChangedEvent = procedure(ASender: TObject; APoint: TDevicePoint;
    APointIndex: Integer) of object;
  EMeasurementEvent = (
    meStarted,
    meStopped,
    mePointSelected,
    mePointInvalid,
    meEtalonSelected,
    meEtalonAbsent,
    mePointSet,
    mePointNotSet,
    meStableReached,
    meStableRetry,
    meStableTimeout,
    meStableUnreachable,
    meMeasureStarted,
    meMeasureCompleted,
    meMeasureTimeout,
    meMeasureError,
    meMeasureWarning,
    meResultReading,
    meResultReady,
    meSaveDone,
    meSaveCancelled,
    meSaveWarning,
    meSaveError,
    mePointDone,
    meAllDone
  );

  EMeasurementCommand = (
    mcStart,
    mcStop,
    mcPause,
    mcReset,
    mcResume,
    mcNextPoint,
    mcPreviousPoint,
    mcRepeatPoint,
    mcForcePoint,
    mcCancel
  );

  TErrorInfo = record
    Code: Integer;
    Msg: string;
    Time: TDateTime;
    Stage: EMeasurementState;
    class function Empty(AStage: EMeasurementState): TErrorInfo; static;
  end;

  TMeasurementRunEvent = procedure(ASender: TObject; AEvent: EMeasurementEvent; const AError: TErrorInfo) of object;



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
    FForceNextPoint: Integer;
    FAttempt: Integer;
    FMaxAttemptCount: Integer;
    FMeasureTimeoutMs: Cardinal;

    FOnStateChangedFrame: TMeasurementRunStateChangedEvent;
    FOnStateChangedMain: TMeasurementRunStateChangedEvent;
    FOnPointChangedFrame: TMeasurementRunPointChangedEvent;
    FOnPointChangedMain: TMeasurementRunPointChangedEvent;
    FOnEvent: TMeasurementRunEvent;

    procedure SetState(const ANewState: EMeasurementState);
    procedure SetStage(const ANewStage: EMeasurementState);
    procedure EnterStage(const ANewStage: EMeasurementState);
    procedure FireEvent(AEvent: EMeasurementEvent; const AError: TErrorInfo); overload;
    procedure FireEvent(AEvent: EMeasurementEvent); overload;
    procedure NotifyStateChanged;
    procedure NotifyPointChanged;
    function GetCurrentPoint: TDevicePoint;
    function BuildError(ACode: Integer; const AMsg: string): TErrorInfo;
    function ValidatePoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function SetPoint(Index: Integer; out AError: TErrorInfo): Boolean;
    function SelectEtalons(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function CalcMeasureTimeoutMs(APoint: TDevicePoint): Cardinal;

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
    procedure Execute(Cmd: EMeasurementCommand); overload;
    procedure Execute(Cmd: EMeasurementCommand; Param: Variant); overload;

    procedure Process;
    procedure ProcessStage;
    procedure SaveMeasurementResults;

    class function SpillStateToString(AState: EMeasurementState): string; static;
    class function SpillStateFromString(const AValue: string): EMeasurementState; static;
    class function MeasurementEventToString(AEvent: EMeasurementEvent): string; static;

    property WorkTable: TWorkTable read FWorkTable;
    property Points: TObjectList<TDevicePoint> read FPoints;

    property Stage: EMeasurementState read FCurrentStage;

    property Mode: EMeasurementRunMode read FMode write FMode;
    property CurrentPointIndex: Integer read FCurrentPointIndex;
    property CurrentPoint: TDevicePoint read GetCurrentPoint;
    property CurrentRepeat: Integer read FCurrentRepeat;

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
    property OnEvent: TMeasurementRunEvent read FOnEvent write FOnEvent;
  end;

implementation

{ TErrorInfo }

class function TErrorInfo.Empty(AStage: EMeasurementState): TErrorInfo;
begin
  Result.Code := 0;
  Result.Msg := '';
  Result.Time := Now;
  Result.Stage := AStage;
end;

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
  FForceNextPoint := -1;
  FMaxAttemptCount := 3;
  FAttempt := 0;
  FMeasureTimeoutMs := 0;
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
  if FCurrentStage = ANewState then
    Exit;
  FCurrentStage := ANewState;
  NotifyStateChanged;
end;

procedure TMeasurementRun.SetStage(const ANewStage: EMeasurementState);
begin
  SetState(ANewStage);
  ProtocolManager.AddMessage(pcState, psMeasurement, 'SetStage',
    'Переход этапа измерения', SpillStateToString(ANewStage));
  EnterStage(ANewStage);
end;

procedure TMeasurementRun.EnterStage(const ANewStage: EMeasurementState);
begin
  FWaitStartedTick := TThread.GetTickCount64;
  case ANewStage of
    msWaitStable:
      begin
        FAttempt := 0;
        if FWorkTable <> nil then
          FWorkTable.StartMonitor;
      end;
    msMeasure:
      begin
        if FWorkTable <> nil then
          FWorkTable.StartTest;
        FMeasureTimeoutMs := CalcMeasureTimeoutMs(GetCurrentPoint);
        FireEvent(meMeasureStarted);
      end;
    msResultsRead:
      FireEvent(meResultReading);
  end;
end;

procedure TMeasurementRun.FireEvent(AEvent: EMeasurementEvent; const AError: TErrorInfo);
begin
  ProtocolManager.AddMessage(pcEvent, psMeasurement, 'MeasurementEvent',
    'Событие измерения', MeasurementEventToString(AEvent));



  if Assigned(FOnEvent) then
    FOnEvent(Self, AEvent, AError);
end;

procedure TMeasurementRun.FireEvent(AEvent: EMeasurementEvent);
begin
  FireEvent(AEvent, TErrorInfo.Empty(FCurrentStage));
end;

function TMeasurementRun.BuildError(ACode: Integer; const AMsg: string): TErrorInfo;
begin
  Result.Code := ACode;
  Result.Msg := AMsg;
  Result.Time := Now;
  Result.Stage := FCurrentStage;
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
begin
  Result := True;

  if (FWorkTable = nil) then
    Exit;

  if (FWorkTable.FlowRate <> nil) and (GetCurrentPoint.Q<>0)  then
    Result := Result and FWorkTable.FlowRate.IsStable;

  if (FWorkTable.FluidTemp <> nil) and  (GetCurrentPoint.Temp<>0) then
    Result := Result and FWorkTable.FluidTemp.IsStable;

  if (FWorkTable.FluidPress <> nil) and  (GetCurrentPoint.Pressure<>0) then
    Result := Result and FWorkTable.FluidPress.IsStable;
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

    FCurrentPointIndex := -1;
    FCurrentRepeat := 0;
    FForceNextPoint := -1;
    FIsPaused := False;
    SetStage(msSelectPoint);
    ProtocolManager.AddMessage(pcAction, psMeasurement, 'Start',
      'Запуск процесса измерения', '');
    FireEvent(meStarted);
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
  SetStage(msNone);
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'Stop',
    'Остановка процесса измерения', '');
  FireEvent(meStopped);
end;

procedure TMeasurementRun.Pause;
begin
  if FIsPaused then
    Exit;
  FIsPaused := True;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'Pause',
    'Пауза процесса измерения', '');
  //SetState(msPause);
end;

procedure TMeasurementRun.Resume;
begin
  if not FIsPaused then
    Exit;
  FIsPaused := False;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'Resume',
    'Возобновление процесса измерения', '');
  //SetState(msOnGoing);
end;

procedure TMeasurementRun.NextPoint;
begin
  FForceNextPoint := FCurrentPointIndex + 1;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'NextPoint',
    'Переход к следующей точке', IntToStr(FForceNextPoint));
end;

procedure TMeasurementRun.Execute(Cmd: EMeasurementCommand);
begin
  Execute(Cmd, Null);
end;

procedure TMeasurementRun.Execute(Cmd: EMeasurementCommand; Param: Variant);
begin
  case Cmd of
    mcStart: Start;
    mcStop, mcCancel: Stop;
    mcPause: Pause;
    mcResume: Resume;
    mcReset:
      begin
        Stop;
        FCurrentPointIndex := -1;
        Start;
      end;
    mcNextPoint: NextPoint;
    mcPreviousPoint:
      FForceNextPoint := Max(FCurrentPointIndex - 1, 0);
    mcRepeatPoint:
      FForceNextPoint := Max(FCurrentPointIndex, 0);
    mcForcePoint:
      if not VarIsNull(Param) then
        FForceNextPoint := Param;
  end;
end;

procedure TMeasurementRun.RunThreadProc;
begin
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

function TMeasurementRun.ValidatePoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
begin
  AError := TErrorInfo.Empty(msSelectPoint);
  Result := Assigned(APoint) and Assigned(FWorkTable);
  if not Result then
  begin
    AError := BuildError(1000, 'Точка или рабочий стол не назначены');
    Exit;
  end;

  if (APoint.Q > 0) and ((APoint.Q < FWorkTable.FlowRate.Min) or (APoint.Q > FWorkTable.FlowRate.Max)) then
  begin
    AError := BuildError(1001, 'Расход точки вне диапазона');
    Exit(False);
  end;

  if (APoint.Temp > 0) and ((APoint.Temp < FWorkTable.FluidTemp.Min) or (APoint.Temp > FWorkTable.FluidTemp.Max)) then
  begin
    AError := BuildError(1002, 'Температура точки вне диапазона');
    Exit(False);
  end;

  if (APoint.Pressure > 0) and ((APoint.Pressure < FWorkTable.FluidPress.Min) or (APoint.Pressure > FWorkTable.FluidPress.Max)) then
  begin
    AError := BuildError(1003, 'Давление точки вне диапазона');
    Exit(False);
  end;
end;

function TMeasurementRun.SetPoint(Index: Integer; out AError: TErrorInfo): Boolean;
var
  Point: TDevicePoint;
begin
  AError := TErrorInfo.Empty(msSelectPoint);
  Result := False;
  if (Index < 0) or (Index >= FPoints.Count) then
  begin
    AError := BuildError(1004, 'Индекс точки вне диапазона');
    Exit;
  end;

  FCurrentPointIndex := Index;
  Point := GetCurrentPoint;
  Result := ValidatePoint(Point, AError);
  if Result then
  begin
    Point.Status := 0;
    NotifyPointChanged;
  end;
end;

function TMeasurementRun.SelectEtalons(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
var
  I: Integer;
  Channel: TChannel;
  Best: TChannel;
begin
  AError := TErrorInfo.Empty(msSelectEtalon);
  Result := False;
  Best := nil;

  if (APoint = nil) or (FWorkTable = nil) then
  begin
    AError := BuildError(1100, 'Нет точки или рабочего стола для выбора эталона');
    Exit;
  end;

  for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
  begin
    Channel := FWorkTable.EtalonChannels[I];
    if (Channel = nil) or (Channel.FlowMeter = nil) then
      Continue;
    if (APoint.Q >= Channel.FlowMeter.FlowMin) and (APoint.Q <= Channel.FlowMeter.FlowMax) then
    begin
      if (Best = nil) or (Channel.FlowMeter.FlowMax < Best.FlowMeter.FlowMax) then
        Best := Channel;
    end;
  end;

  Result := Best <> nil;
  if not Result then
    AError := BuildError(1101, 'Эталон по расходу не найден');
end;

function TMeasurementRun.CalcMeasureTimeoutMs(APoint: TDevicePoint): Cardinal;
var
  TimeByLimit: Double;
  Q: Double;
begin
  Result := 70000;
  if APoint = nil then
    Exit;

  Q := Max(APoint.Q, 0.000001);
  TimeByLimit := APoint.LimitTime;
  if APoint.LimitVolume > 0 then
    TimeByLimit := Max(TimeByLimit, APoint.LimitVolume / Q);
  if APoint.LimitImp > 0 then
    TimeByLimit := Max(TimeByLimit, APoint.LimitImp / Q);
  if TimeByLimit <= 0 then
    TimeByLimit := 60;
  Result := Round((TimeByLimit + 10) * 1000);
end;

procedure TMeasurementRun.Process;
begin
  if IsTerminated then
    Exit;
  ProcessStage;
end;

procedure TMeasurementRun.ProcessStage;
var
  Point: TDevicePoint;
  Error: TErrorInfo;
  RepeatsTarget: Integer;
begin
  Point := GetCurrentPoint;
  case FCurrentStage of
    msSelectPoint:
      begin
        if FForceNextPoint >= 0 then
          FCurrentPointIndex := FForceNextPoint
        else
          Inc(FCurrentPointIndex);
        FForceNextPoint := -1;

        if FCurrentPointIndex >= FPoints.Count then
        begin
          FireEvent(meAllDone);
          SetStage(msDone);
          Exit;
        end;

        if SetPoint(FCurrentPointIndex, Error) then
        begin
          FireEvent(mePointSelected);
          SetStage(msSelectEtalon);
        end
        else
        begin
          FireEvent(mePointInvalid, Error);
          SetStage(msDone);
        end;
      end;

    msSelectEtalon:
      begin
        if SelectEtalons(Point, Error) then
        begin
          FireEvent(meEtalonSelected);
          SetStage(msSetupPoint);
        end
        else
        begin
          FireEvent(meEtalonAbsent, Error);
          SetStage(msDone);
        end;
      end;

    msSetupPoint:
      begin
        if (FWorkTable <> nil) and (Point <> nil) then
        begin
          if (Point.Q >= 0) and (FWorkTable.FlowRate <> nil) then
          begin
            FWorkTable.FlowRate.DoFlowRateSet(Point.Q);
            FWorkTable.FlowRate.DoFlowRateStart;
          end;
          if (Point.Temp >= 0) and (FWorkTable.FluidTemp <> nil) then
            FWorkTable.FluidTemp.DoFluidTempStart(Point.Temp);
          if (Point.Pressure >= 0) and (FWorkTable.FluidPress <> nil) then
            FWorkTable.FluidPress.DoFluidPressStart(Point.Pressure);
          if Point.LimitTime > 0 then
            FWorkTable.TimeSet := Round(Point.LimitTime);
          FireEvent(mePointSet);
          SetStage(msWaitStable);
        end
        else
        begin
          FireEvent(mePointNotSet, BuildError(1201, 'Невозможно задать параметры точки'));
          SetStage(msDone);
        end;
      end;

    msWaitStable:
      begin
        if IsStable then
        begin
          FireEvent(meStableReached);
          SetStage(msMeasure);
          Exit;
        end;

        if (TThread.GetTickCount64 - FWaitStartedTick) > 30000 then
        begin
          Inc(FAttempt);
          if FAttempt < FMaxAttemptCount then
          begin
            FireEvent(meStableRetry);
            SetStage(msSetupPoint);
          end
          else
          begin
            FireEvent(meStableTimeout, BuildError(1301, 'Стабилизация не достигнута'));
            SetStage(msDone);
          end;
        end;
      end;

    msMeasure:
      begin
        if (FWorkTable <> nil) and (FWorkTable.State = STATE_COMPLETE) then
        begin
          FireEvent(meMeasureCompleted);
          SetStage(msResultsRead);
          Exit;
        end;

        if (TThread.GetTickCount64 - FWaitStartedTick) > FMeasureTimeoutMs then
        begin
          FireEvent(meMeasureTimeout, BuildError(1401, 'Таймаут измерения'));
          SetStage(msDone);
        end;
      end;

    msResultsRead:
      begin
        FireEvent(meResultReady);
        SetStage(msSave);
      end;

    msSave:
      begin
        SaveMeasurementResults;
        FireEvent(meSaveDone);

        RepeatsTarget := 1;
        if Point <> nil then
          RepeatsTarget := Max(Point.Repeats, 1);
        Inc(FCurrentRepeat);
        if FCurrentRepeat >= RepeatsTarget then
        begin
          FCurrentRepeat := 0;
          FireEvent(mePointDone);
          SetStage(msSelectPoint);
        end
        else
          SetStage(msSetupPoint);
      end;

    msDone:
      if FThread <> nil then
        FThread.Terminate;
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
var
  S: string;
begin
  S := Trim(LowerCase(AValue));

  if (S = '') or (S = '-') or (S = 'none') or (S = 'msnone') then
    Exit(msNone);

  if (S = 'выбор точки') or (S = 'выборточки') or (S = 'msselectpoint') then
    Exit(msSelectPoint);

  if (S = 'выбор эталона') or (S = 'msselectetalon') then
    Exit(msSelectEtalon);

  if (S = 'установка точки') or (S = 'mssetuppoint') then
    Exit(msSetupPoint);

  if (S = 'стабилизация') or (S = 'ожидание стабилизации') or (S = 'mswaitstable') then
    Exit(msWaitStable);

  if (S = 'измерение') or (S = 'msmeasure') then
    Exit(msMeasure);

  if (S = 'чтение результата') or (S = 'чтение результатов') or (S = 'msresultsread') then
    Exit(msResultsRead);

  if (S = 'сохранение') or (S = 'mssave') then
    Exit(msSave);

  if (S = 'завершено') or (S = 'окончание') or (S = 'msdone') then
    Exit(msDone);

  Result := msNone;
end;

{ Converts spill state enum value to persisted string. }
class function TMeasurementRun.SpillStateToString(AState: EMeasurementState): string;
begin
  case AState of
    msNone:        Result := '-';
    msSelectPoint: Result := 'Выбор точки';
    msSelectEtalon:Result := 'Выбор эталона';
    msSetupPoint:  Result := 'Установка точки';
    msWaitStable:  Result := 'Стабилизация';
    msMeasure:     Result := 'Измерение';
    msResultsRead: Result := 'Чтение результата';
    msSave:        Result := 'Сохранение';
    msDone:        Result := 'Завершено';
  else
    Result := '-';
  end;
end;

class function TMeasurementRun.MeasurementEventToString(AEvent: EMeasurementEvent): string;
begin
  case AEvent of
    meStarted:          Result := 'Запущено';
    meStopped:          Result := 'Остановлено';
    mePointSelected:    Result := 'Точка выбрана';
    mePointInvalid:     Result := 'Точка невалидна';
    meEtalonSelected:   Result := 'Эталон выбран';
    meEtalonAbsent:     Result := 'Эталон отсутствует';
    mePointSet:         Result := 'Точка установлена';
    mePointNotSet:      Result := 'Точка не установлена';
    meStableReached:    Result := 'Стабилизация достигнута';
    meStableRetry:      Result := 'Повтор стабилизации';
    meStableTimeout:    Result := 'Таймаут стабилизации';
    meStableUnreachable:Result := 'Стабилизация недостижима';
    meMeasureStarted:   Result := 'Измерение запущено';
    meMeasureCompleted: Result := 'Измерение завершено';
    meMeasureTimeout:   Result := 'Таймаут измерения';
    meMeasureError:     Result := 'Ошибка измерения';
    meMeasureWarning:   Result := 'Предупреждение измерения';
    meResultReading:    Result := 'Чтение результата';
    meResultReady:      Result := 'Результат готов';
    meSaveDone:         Result := 'Сохранено';
    meSaveCancelled:    Result := 'Сохранение отменено';
    meSaveWarning:      Result := 'Предупреждение сохранения';
    meSaveError:        Result := 'Ошибка сохранения';
    mePointDone:        Result := 'Точка завершена';
    meAllDone:          Result := 'Все точки завершены';
  else
    Result := '-';
  end;
end;

end.
