unit uMeasurementRun;

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
  1. External control MUST be performed only via Execute(Command).
  2. Execute(Command) MUST delegate command handling to HandleCommand().
  3. Stage transitions MUST happen only via SetStage().
  4. SetStage() MUST be the single place where FCurrentStage changes.
  5. SetStage() MUST NOT contain detailed business logic of measurement stages.
  6. Actions required when entering a stage MUST be implemented in DoEnterStage().
  7. Cleanup required when leaving a stage MUST be implemented in DoExitStage().
  8. ProcessStage() MUST only dispatch processing to stage-specific methods.
  9. Stage-specific methods MUST check completion conditions and request the next transition.
  10. UI MUST NOT directly control TWorkTable.
  11. TWorkTable MUST be treated as a low-level executor.
  12. TWorkTable MUST NOT contain measurement scenario logic.
  13. Events MUST only notify observers and MUST NOT perform feedback control.
  14. Errors MUST be reported via FireEvent with TErrorInfo.
  15. No unhandled exception should break the FSM execution flow.

  WorkTable Contract
  ------------------
  TWorkTable is treated as a passive executor and must provide:

    - StartTest / StopTest
    - StartMonitor
    - FlowRate / FluidTemp / FluidPress control
    - State (swtEXECUTE, swtCOMPLETE, etc.)
    - Data access (Flow, Temp, Pressure, Quantity, Time)
    - Stability flags (IsStable)

  TMeasurementRun must NOT rely on hidden logic inside TWorkTable.

  Typical Flow
  ------------
    msSelectPoint
      → msSelectEtalon
      → msSetupPoint
      → msWaitStable
      → msWaitMeasureStart
      → msMeasure
      → msWaitMeasureStop
      → msResultsRead
      → msSave
      → msSelectPoint / msDone

  StartTest is an entry action of msWaitMeasureStart.
  StopTest is an entry action of msWaitMeasureStop.
  Process... methods only check conditions and request transitions.

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
  System.Classes,
  System.Generics.Collections,
  System.IniFiles,
  System.Math,
  System.StrUtils,
  System.SyncObjs,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uDeviceClass,
  uFlowMeter,
  uMeterValue,
  uObservable,
  uProtocols,
  uRepositories,
  uWorkTable;

type

  TMeasurementRunStateChangedEvent = procedure(ASender: TObject; AState: EMeasurementState) of object;
  TMeasurementRunPointChangedEvent = procedure(ASender: TObject; APoint: TDevicePoint;
    APointIndex: Integer) of object;

  TMeasurementEvent = (
    meStateChanged,
    mePointChanged,
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
    meAllDone,
    meStopRequested
  );

  EMeasurementEvent = TMeasurementEvent;

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



  TMeasurementRunEvent = procedure(ASender: TObject; AEvent: EMeasurementEvent; const AError: TErrorInfo) of object;

  TMeasurementStopControlMode = (
    scmNone,
    scmControllerTime,
    scmControllerImpulse,
    scmCommand
  );

  TMeasurementStopReason = (
    msrNone,
    msrNormalComplete,
    msrUserStop,
    msrLimitReached,
    msrError,
    msrCancelledBeforeStart,
    msrEmergency,
    msrExternalCommand
  );


  TMeasurementRun = class(TObservableObject)

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
    FLastStableProtocolTick: UInt64;


    FCurrentRepeat: Integer;
    FIsPaused: Boolean;
    FForceNextPoint: Integer;
    FAttempt: Integer;
    FMaxAttemptCount: Integer;
    FMeasureTimeout: Cardinal;
    FStopRequested: Boolean;
    FStopReason: TMeasurementStopReason;
    FPhysicalMeasureStarted: Boolean;
    FPhysicalStopRequested: Boolean;
    FActualStopEventFired: Boolean;
    FNextStageAfterSave: EMeasurementState;
    FMeasurementDiagnosticEvents: TList<string>;
    FMeasurementDiagnosticCS: TCriticalSection;
    FMeasurementDiagnosticDropped: Integer;
    FLastDiagnosticIsStableText: string;
    FLastDiagnosticIsStableSecond: Int64;
    FLastDiagnosticWorkTableState: EStateWorkTable;
    FLastSaveMeasurementResultsCalled: Boolean;
    FLastSaveMeasurementResultsResult: string;
    FLastSaveErrorText: string;
    FLastMeasureCompletedEventSent: Boolean;
    FLastSaveDoneEventSent: Boolean;
    FLastPointDoneEventSent: Boolean;

    procedure HandleCommand(Cmd: EMeasurementCommand; const Param: Variant);
    procedure SetStage(const ANewStage: EMeasurementState);
    function CanChangeStage(AOldStage, ANewStage: EMeasurementState): Boolean;
    procedure DoExitStage(AOldStage, ANewStage: EMeasurementState);
    procedure DoEnterStage(AOldStage, ANewStage: EMeasurementState);
    procedure EnterSelectPoint;
    procedure EnterSelectEtalon;
    procedure EnterSetupPoint;
    procedure EnterWaitStable;
    procedure EnterWaitMeasureStart;
    procedure EnterMeasure;
    procedure EnterWaitMeasureStop;
    procedure EnterResultsRead;
    procedure EnterSave;
    procedure EnterDone;
    /// <summary>
    /// Updates the status of the current measurement point and notifies
    /// observers only when the value has actually changed.
    /// </summary>
    procedure SetCurrentPointStatus(const AStatus: EMeasurementPointStatus);
    procedure RequestStop;
    procedure StopWorkerThread;
    function IsStopRequested: Boolean;
    function GetStopReason: TMeasurementStopReason;
    procedure SetStopReason(AReason: TMeasurementStopReason);
    function HasPhysicalMeasurementStarted: Boolean;
    function WorkTableNeedsPhysicalStop: Boolean;
    procedure FireActualStopOnce;
    procedure RouteStopInWorker;
    procedure MarkInterruptedPointIfNeeded;
    class function MeasurementStopReasonToString(AReason: TMeasurementStopReason): string; static;
    procedure ProcessSelectPoint;
    procedure ProcessSelectEtalon;
    procedure ProcessSetupPoint;
    procedure ProcessWaitStable;
    procedure ProcessWaitMeasureStart;
    procedure ProcessMeasure;
    procedure ProcessWaitMeasureStop;
    procedure ProcessResultsRead;
    procedure ProcessSave;
    procedure ProcessDone;
    procedure FireEvent(AEvent: EMeasurementEvent; const AError: TErrorInfo); overload;
    procedure FireEvent(AEvent: EMeasurementEvent); overload;

    function GetCurrentPoint: TDevicePoint;
    function FindNextEnabledPointIndex(AStartIndex: Integer): Integer;
    function BuildError(ACode: Integer; const AMsg: string): TErrorInfo;
    function ValidatePoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function SetPoint(Index: Integer; out AError: TErrorInfo): Boolean;
    function SelectEtalons(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function BuildPointSelectionLog(APoint: TDevicePoint): string;
    function BuildEtalonSelectionLog(APoint: TDevicePoint): string;
    function CalcMeasureTimeout(APoint: TDevicePoint): Cardinal;
    function SetupPoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function SetupMeasurement(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function GetCurrentStopTimeValue: Double;
    function GetCurrentStopImpulseValue: Int64;
    function GetCurrentStopVolumeValue: Double;
    function IsCommandStopLimitReached(out AReason: string): Boolean;
    function BuildCommandStopLimitDetails(APoint: TDevicePoint; const AReason: string): string;
    function ShouldUseAllPoints: Boolean;
    function ShouldSetupConditions: Boolean;
    function ShouldWaitStable: Boolean;
    function ShouldSelectEtalon: Boolean;
    function CreateSingleSessionPoint(AWithConditions: Boolean): TDevicePoint;

    procedure RunThreadProc;
    function IsThreadRunning: Boolean;

    function IsStable(out StableInfo: RStableInfo): Boolean;
    procedure AddDiagnosticEvent(const AText: string);
    procedure AddWorkTableStateDiagnosticEvent;
    function CheckFlowStable(out StableInfo: RStableInfo): Boolean;
    procedure ContinueAfterPointError(const AStatus: EMeasurementPointStatus; AEvent: EMeasurementEvent; const AError: TErrorInfo);
    function IsTerminated: Boolean;
  public
    constructor Create(AWorkTable: TWorkTable);
    destructor Destroy; override;

  class function IsPointEquivalent(AP1, AP2: TDevicePoint): Boolean; overload;
  class function IsPointEquivalent(AP1: TDevicePoint; AP2: TPointSpillage): Boolean; overload;

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
    function BuildDiagnosticSnapshot(const ASwitchAutoText: string): string;
    function DrainDiagnosticEvents: TArray<string>;

    class function MeasurementStateToString(AState: EMeasurementState): string; static;
    class function MeasurementStateFromString(const AValue: string): EMeasurementState; static;
    class function MeasurementEventToString(AEvent: EMeasurementEvent): string; static;

    property WorkTable: TWorkTable read FWorkTable;
    property Points: TObjectList<TDevicePoint> read FPoints;

    property Stage: EMeasurementState read FCurrentStage;

    property Mode: EMeasurementRunMode read FMode write FMode;
    property CurrentPointIndex: Integer read FCurrentPointIndex;
    property CurrentPoint: TDevicePoint read GetCurrentPoint;
    property CurrentRepeat: Integer read FCurrentRepeat;
    property StopRequested: Boolean read FStopRequested;
    property NextStageAfterSave: EMeasurementState read FNextStageAfterSave;
    property ForceNextPoint: Integer read FForceNextPoint;
    property Attempt: Integer read FAttempt;
    property MaxAttemptCount: Integer read FMaxAttemptCount;
    property IsWorkerThreadRunning: Boolean read IsThreadRunning;

    property ManualFlowRate: Double read FManualFlowRate write FManualFlowRate;
    property ManualFluidTemp: Double read FManualFluidTemp write FManualFluidTemp;
    property ManualFluidPress: Double read FManualFluidPress write FManualFluidPress;
    property ManualTimeSet: Integer read FManualTimeSet write FManualTimeSet;

  end;

function GetMeasurementStopControlMode(APoint: TDevicePoint): TMeasurementStopControlMode;

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


function GetMeasurementStopControlMode(APoint: TDevicePoint): TMeasurementStopControlMode;
var
  ActiveCriteria: TSpillageStopCriteria;
begin
  Result := scmNone;

  if not Assigned(APoint) then
    Exit;

  ActiveCriteria := [];

  if (scTime in APoint.StopCriteria) and (APoint.LimitTime > 0) then
    Include(ActiveCriteria, scTime);

  if (scImpulse in APoint.StopCriteria) and (APoint.LimitImp > 0) then
    Include(ActiveCriteria, scImpulse);

  if (scVolume in APoint.StopCriteria) and (APoint.LimitVolume > 0) then
    Include(ActiveCriteria, scVolume);

  if ActiveCriteria = [scTime] then
    Exit(scmControllerTime);

  if ActiveCriteria = [scImpulse] then
    Exit(scmControllerImpulse);

  Result := scmCommand;
end;

function MeasurementStopControlModeToString(AMode: TMeasurementStopControlMode): string;
begin
  case AMode of
    scmNone: Result := 'scmNone';
    scmControllerTime: Result := 'scmControllerTime';
    scmControllerImpulse: Result := 'scmControllerImpulse';
    scmCommand: Result := 'scmCommand';
  else
    Result := 'Unknown';
  end;
end;

function StopCriteriaToLogString(ACriteria: TSpillageStopCriteria): string;
var
  Parts: TStringBuilder;
begin
  Parts := TStringBuilder.Create;
  try
    if scTime in ACriteria then
      Parts.Append('scTime');
    if scImpulse in ACriteria then
    begin
      if Parts.Length > 0 then
        Parts.Append(', ');
      Parts.Append('scImpulse');
    end;
    if scVolume in ACriteria then
    begin
      if Parts.Length > 0 then
        Parts.Append(', ');
      Parts.Append('scVolume');
    end;

    if Parts.Length = 0 then
      Result := '[]'
    else
      Result := '[' + Parts.ToString + ']';
  finally
    Parts.Free;
  end;
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

class function TMeasurementRun.IsPointEquivalent(AP1, AP2: TDevicePoint): Boolean;
begin
  Result := (AP1 <> nil) and (AP2 <> nil)
    and IsFlowFit(AP1.Q, AP1.FlowAccuracy, AP2.Q)
    and IsTemperatureFit(AP1.Temp, AP1.TempAccuracy, AP2.Temp);
end;

class function TMeasurementRun.IsPointEquivalent(AP1: TDevicePoint; AP2: TPointSpillage): Boolean;

begin
  Result := (AP1 <> nil) and (AP2 <> nil)
    and IsFlowFit(AP1.Q, AP1.FlowAccuracy, AP2.QavgEtalon)
    and IsTemperatureFit(AP1.Temp, AP1.TempAccuracy, AP2.AvgTemperature);
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
  ATarget.Error := Min(ATarget.Error, ASource.Error);
end;

{ TMeasurementRun }

constructor TMeasurementRun.Create(AWorkTable: TWorkTable);
begin
  inherited Create;
  FWorkTable := AWorkTable;
  FPoints := TObjectList<TDevicePoint>.Create(True);
  FCriticalSection := TCriticalSection.Create;

  FCurrentPointIndex := -1;
  FMode := mrmManual;

  FManualFlowRate := 0;
  FManualFluidTemp := 20;
  FManualFluidPress := 1;
  FManualTimeSet := 60;

  FCurrentStage := msNone;
  FForceNextPoint := -1;
  FMaxAttemptCount := 3;
  FAttempt := 0;
  FMeasureTimeout := 0;
  FStopRequested := False;
  FStopReason := msrNone;
  FPhysicalMeasureStarted := False;
  FPhysicalStopRequested := False;
  FActualStopEventFired := False;
  FNextStageAfterSave := msNone;
  FMeasurementDiagnosticEvents := TList<string>.Create;
  FMeasurementDiagnosticCS := TCriticalSection.Create;
  FLastDiagnosticWorkTableState := swtNONE;
  FLastSaveMeasurementResultsResult := 'not called';
end;

function TMeasurementRun.BuildPointSelectionLog(APoint: TDevicePoint): string;
begin
  if APoint = nil then
    Exit('Точка не выбрана');

  Result := Format('Точка: %s; Q=%.6g; Ограничения: имп=%d, объем=%.6g, время=%.6g c', [
    APoint.Name,
    APoint.Q,
    APoint.LimitImp,
    APoint.LimitVolume,
    APoint.LimitTime
  ]);
end;

function TMeasurementRun.BuildEtalonSelectionLog(APoint: TDevicePoint): string;
var
  I: Integer;
  Channel: TChannel;
  Details: TStringList;
  EtalonName: string;
begin
  if (APoint = nil) or (FWorkTable = nil) or (FWorkTable.EtalonChannels = nil) then
    Exit('Выбранные эталоны отсутствуют');

  Details := TStringList.Create;
  try
    Details.Add(Format('Расход точки: %.6f', [APoint.Q]));
    Details.Add('Выбранные эталоны:');

    for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
    begin
      Channel := FWorkTable.EtalonChannels[I];
      if (Channel = nil) or (Channel.FlowMeter = nil) or (not Channel.Enabled) then
        Continue;

      EtalonName := Trim(Channel.Name);
      if EtalonName = '' then
        EtalonName := Trim(Channel.FlowMeter.DeviceName);
      if EtalonName = '' then
        EtalonName := 'Без имени';

      Details.Add(Format('- %s, диапазон %.6f..%.6f, Group=%d', [
        EtalonName,
        Channel.FlowMeter.FlowMin,
        Channel.FlowMeter.FlowMax,
        Channel.Group
      ]));
    end;

    if Details.Count = 2 then
      Details.Add('Выбранные эталоны отсутствуют');

    Result := Trim(Details.Text);
  finally
    Details.Free;
  end;
end;

destructor TMeasurementRun.Destroy;
begin
  StopWorkerThread;
  if FCurrentStage <> msNone then
    SetStage(msNone);
  FreeAndNil(FMeasurementDiagnosticCS);
  FreeAndNil(FMeasurementDiagnosticEvents);
  FreeAndNil(FCriticalSection);
  FreeAndNil(FPoints);
  inherited Destroy;
end;

function TMeasurementRun.CanChangeStage(AOldStage, ANewStage: EMeasurementState): Boolean;
begin
  if AOldStage = ANewStage then
    Exit(True);

  Result := False;
  case AOldStage of
    msNone:
      case FMode of
        mrmManual:
          Result := ANewStage = msSetupPoint;
        mrmHalfAutomatic,
        mrmAutomatic:
          Result := ANewStage = msSelectPoint;
      else
        Result := False;
      end;
    msSelectPoint:
      Result := ANewStage in [msSelectEtalon, msSetupPoint, msDone, msNone];
    msSelectEtalon:
      Result := ANewStage in [msSetupPoint, msSelectPoint, msDone, msNone];
    msSetupPoint:
      Result := ANewStage in [msWaitStable, msWaitMeasureStart, msSelectPoint, msDone, msNone];
    msWaitStable:
      Result := ANewStage in [msWaitMeasureStart, msSetupPoint, msSelectPoint, msDone, msNone];
    msWaitMeasureStart:
      Result := ANewStage in [msMeasure, msWaitMeasureStop, msSelectPoint, msDone, msNone];
    msMeasure:
      Result := ANewStage in [msWaitMeasureStop, msSelectPoint, msDone, msNone];
    msWaitMeasureStop:
      Result := ANewStage in [msResultsRead, msSelectPoint, msDone, msNone];
    msResultsRead:
      Result := ANewStage in [msSave, msSelectPoint, msDone, msNone];
    msSave:
      Result := ANewStage in [msSelectPoint, msSetupPoint, msDone, msNone];
    msDone:
      Result := ANewStage in [msNone, msSelectPoint, msSetupPoint];
  end;
end;

procedure TMeasurementRun.SetStage(const ANewStage: EMeasurementState);
var
  OldStage: EMeasurementState;
  TransitionText: string;
begin

  if FCurrentStage = ANewStage then
    Exit;

  FWaitStartedTick := TThread.GetTickCount64;

  OldStage := FCurrentStage;
  TransitionText := Format('%s -> %s', [MeasurementStateToString(OldStage),
    MeasurementStateToString(ANewStage)]);

  if not CanChangeStage(OldStage, ANewStage) then
  begin
    ProtocolManager.AddMessage(pcWarning, psMeasurement, 'SetStage',
      'Недопустимый переход этапа измерения', TransitionText);
    FireEvent(meMeasureWarning, BuildError(9001,
      'Invalid measurement stage transition: ' + TransitionText));
    Exit;
  end;

  DoExitStage(OldStage, ANewStage);
  FCurrentStage := ANewStage;

  ProtocolManager.AddMessage(pcState, psMeasurement, 'SetStage',
    'Переход этапа измерения, тайм аут: ' +inttostr(TThread.GetTickCount64 - FWaitStartedTick)+'; ', TransitionText);
  AddDiagnosticEvent('Stage ' + MeasurementStateToString(OldStage) + ' -> ' + MeasurementStateToString(ANewStage));
  if FWorkTable <> nil then
    FWorkTable.MeasurementRunStateChanged(Self, ANewStage);
  Notify(Integer(meStateChanged));
  DoEnterStage(OldStage, ANewStage);
end;

procedure TMeasurementRun.DoExitStage(AOldStage, ANewStage: EMeasurementState);
begin
  case AOldStage of
    msWaitStable:
      if (ANewStage <> msWaitMeasureStart) and (FWorkTable <> nil) then
        FWorkTable.StopMonitor;
  end;
end;

procedure TMeasurementRun.DoEnterStage(AOldStage, ANewStage: EMeasurementState);
begin
  FWaitStartedTick := TThread.GetTickCount64;
  case ANewStage of
    msSelectPoint: EnterSelectPoint;
    msSelectEtalon: EnterSelectEtalon;
    msSetupPoint: EnterSetupPoint;
    msWaitStable: EnterWaitStable;
    msWaitMeasureStart: EnterWaitMeasureStart;
    msMeasure: EnterMeasure;
    msWaitMeasureStop: EnterWaitMeasureStop;
    msResultsRead: EnterResultsRead;
    msSave: EnterSave;
    msDone: EnterDone;
  end;
end;

procedure TMeasurementRun.SetCurrentPointStatus(const AStatus: EMeasurementPointStatus);
var
  Point: TDevicePoint;
begin
  Point := GetCurrentPoint;
  if Point = nil then
    Exit;
  if Point.Status = AStatus then
    Exit;
  Point.Status := AStatus;
  AddDiagnosticEvent('PointStatus -> ' + GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(AStatus)));
  if FWorkTable <> nil then
 //   FWorkTable.MeasurementRunPointChanged(Self, Point, FCurrentPointIndex);
 // Notify(Integer(mePointChanged), Point);
end;


/// <summary>
/// Выполняет действия при входе в состояние выбора очередной точки измерения
/// <c>msSelectPoint</c>.
/// </summary>
/// <remarks>
/// Процедура определяет индекс точки, которая должна стать текущей, пытается
/// загрузить её в <c>FWorkTable.CurrentPoint</c> через <c>SetPoint</c>,
/// обновляет статус точки.
///
/// Возможны два варианта выбора точки:
///
/// 1. Обычный последовательный переход — выбирается следующая точка списка.
/// 2. Принудительный переход — используется индекс из <c>FForceNextPoint</c>.
///
/// После успешного выбора точки машина состояний переходит:
///
/// - в <c>msSelectEtalon</c>, если для точки требуется автоматический выбор
///   эталонных средств измерения;
/// - в <c>msSetupPoint</c>, если выбор эталона не требуется.
///
/// Если все точки уже обработаны, измерительный цикл завершается переходом
/// в <c>msDone</c>.
///
/// Если выбранная точка некорректна или её невозможно применить, точке
/// назначается статус <c>mptsInvalidPoint</c>, формируется событие
/// <c>mePointInvalid</c>, после чего измерительный цикл завершается.
/// </remarks>

function TMeasurementRun.FindNextEnabledPointIndex(AStartIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FPoints = nil then
    Exit;

  for I := Max(AStartIndex, 0) to FPoints.Count - 1 do
    if (FPoints[I] <> nil) and FPoints[I].Enabled and
       (FPoints[I].State <> osDeleted) then
      Exit(I);
end;

procedure TMeasurementRun.EnterSelectPoint;
var
  // Содержит подробную информацию об ошибке, если SetPoint не сможет
  // выбрать, проверить или применить указанную точку измерения.
  Error: TErrorInfo;
begin
  // Начинаем обработку новой точки с нулевого номера попытки.
  //
  // FAttempt обычно используется стадиями ожидания или выполнения команд
  // для подсчёта повторных попыток. При переходе к новой точке значение,
  // оставшееся от предыдущей точки, использовать нельзя.
  FAttempt := 0;

  // Определяем индекс точки, которую необходимо выбрать.
  //
  // Если FForceNextPoint содержит неотрицательное значение, ранее был
  // запрошен принудительный переход к конкретной точке. Например, такой
  // механизм может использоваться командами перехода к предыдущей или
  // следующей точке, повторного измерения либо ручного выбора точки.
  if FForceNextPoint >= 0 then
    FCurrentPointIndex := FForceNextPoint
  else
    // При обычном автоматическом проходе переходим к следующей точке списка.
    //
    // Важно: предполагается, что до первого входа в EnterSelectPoint
    // FCurrentPointIndex имеет значение -1. Тогда первый вызов Inc установит
    // индекс первой точки равным 0.
    Inc(FCurrentPointIndex);

  if (FMode = mrmAutomatic) and ((FCurrentPointIndex < 0) or
     (FCurrentPointIndex >= FPoints.Count) or (not FPoints[FCurrentPointIndex].Enabled) or
     (FPoints[FCurrentPointIndex].State = osDeleted)) then
    FCurrentPointIndex := FindNextEnabledPointIndex(FCurrentPointIndex);

  // Принудительный индекс является одноразовой командой.
  //
  // После его использования обязательно сбрасываем значение, чтобы при
  // следующем входе в msSelectPoint продолжился обычный последовательный
  // обход точек.
  FForceNextPoint := -1;

  // Проверяем, существует ли точка с рассчитанным индексом.
  //
  // Если индекс равен количеству точек или превышает его, значит все точки
  // списка уже обработаны и продолжать измерительный цикл больше не нужно.
  if (FCurrentPointIndex < 0) or (FCurrentPointIndex >= FPoints.Count) then
  begin
    // Переводим машину состояний в конечное состояние.
    //
    // Все завершающие действия должны выполняться обработчиком входа
    // в msDone, а не непосредственно в EnterSelectPoint.
    SetStage(msDone);
    Exit;
  end;

  // Пытаемся выбрать точку с рассчитанным индексом и применить её как
  // текущую точку измерения.
  //
  // SetPoint должен:
  // - получить точку из FPoints;
  // - проверить корректность индекса и самой точки;
  // - назначить текущую точку рабочему столу;
  // - подготовить необходимые данные текущего измерения;
  // - заполнить Error при невозможности выбора точки.
  if SetPoint(FCurrentPointIndex, Error) then
  begin
    // Точка успешно выбрана.
    //
    // Устанавливаем ей статус, соответствующий стадии выбора точки.
    // Статус используется для отображения текущего положения точки
    // в таблице и для последующего анализа результата измерения.
    SetCurrentPointStatus(mptsSelectPoint);

    // После вызова SetPoint могла поступить команда принудительной остановки.
    //
    // Проверка выполняется до протоколирования выбора точки и до перехода
    // на следующую стадию, чтобы не запускать новые действия после Stop.
    //
    // Предполагается, что сама обработка запроса остановки уже определила
    // необходимую следующую стадию машины состояний.
    if IsStopRequested then
      Exit;

    // Записываем в протокол факт успешного выбора точки.
    //
    // BuildPointSelectionLog формирует подробные данные о точке:
    // индекс, расход, ограничения, параметры среды и другие значения,
    // необходимые для диагностики процесса измерения.
    ProtocolManager.AddMessage(
      pcAction,
      psMeasurement,
      'PointSelected',
      'Выбрана точка измерения',
      BuildPointSelectionLog(GetCurrentPoint)
    );

    // Уведомляем подписчиков о том, что очередная точка успешно выбрана.
    //
    // Событие может использоваться для:
    // - обновления пользовательского интерфейса;
    // - отображения текущей точки;
    // - обновления таблицы результатов;
    // - дополнительного протоколирования.
    FireEvent(mePointSelected);

    // Определяем следующий этап подготовки измерения.
    //
    // Если текущий режим и параметры точки требуют автоматического выбора
    // эталонных расходомеров, сначала переходим в msSelectEtalon.
    if ShouldSelectEtalon then
      SetStage(msSelectEtalon)
    else
      // Если эталон уже выбран, выбор эталона запрещён текущим режимом
      // либо не требуется для данной точки, сразу переходим к настройке
      // параметров точки.
      SetStage(msSetupPoint);
  end
  else
  begin
    // Выбрать или применить точку не удалось.
    //
    // Назначаем точке статус некорректной. Этот статус должен быть отражён
    // в интерфейсе, например соответствующим цветом строки или ячейки.
    SetCurrentPointStatus(mptsInvalidPoint);

    // Передаём подписчикам событие о некорректной точке вместе с подробной
    // информацией об ошибке, сформированной внутри SetPoint.
    FireEvent(mePointInvalid, Error);

    if FMode = mrmAutomatic then
      EnterSelectPoint
    else
      SetStage(msDone);
  end;
end;



procedure TMeasurementRun.EnterSelectEtalon;
var
  Error: TErrorInfo;
begin
  SetCurrentPointStatus(mptsSelectEtalon);
  if IsStopRequested then
    Exit;
  if SelectEtalons(GetCurrentPoint, Error) then
  begin
    FireEvent(meEtalonSelected);
    SetStage(msSetupPoint);
  end
  else
  begin
    ContinueAfterPointError(mptsSetupError, meEtalonAbsent, Error);
  end;
end;

procedure TMeasurementRun.EnterSetupPoint;
var
  Point: TDevicePoint;
  Error: TErrorInfo;
begin
  Point := GetCurrentPoint;

  if FMode = mrmManual then
  begin
    if Point = nil then
    begin
      FireEvent(mePointNotSet, BuildError(1200, 'В ручном режиме не задана текущая точка измерения'));
      SetStage(msDone);
      Exit;
    end;

    SetCurrentPointStatus(mptsSetupPoint);

    if not SetupMeasurement(Point, Error) then
    begin
      ContinueAfterPointError(mptsSetupError, mePointNotSet, Error);
      Exit;
    end;

    FireEvent(mePointSet);
    SetStage(msWaitMeasureStart);
    Exit;
  end;

  if Point = nil then
  begin
    FireEvent(mePointNotSet, BuildError(1200, 'Текущая точка измерения не назначена'));
    SetStage(msDone);
    Exit;
  end;

  SetCurrentPointStatus(mptsSetupPoint);
  if IsStopRequested then
    Exit;

  if ShouldSetupConditions then
  begin
    if not SetupPoint(Point, Error) then
    begin
      ContinueAfterPointError(mptsSetupError, mePointNotSet, Error);
      Exit;
    end;
  end
  else
    SetCurrentPointStatus(mptsSetupPoint);

  if not SetupMeasurement(Point, Error) then
  begin
    ContinueAfterPointError(mptsSetupError, mePointNotSet, Error);
    Exit;
  end;

  FireEvent(mePointSet);
  if ShouldWaitStable then
    SetStage(msWaitStable)
  else
    SetStage(msWaitMeasureStart);
end;

procedure TMeasurementRun.EnterWaitStable;
begin
  SetCurrentPointStatus(mptsWaitStable);

  // Начать новый период публикации состояния стабилизации.
  // Первое промежуточное сообщение появится через 2 секунды.
  FLastStableProtocolTick := TThread.GetTickCount64;

  if IsStopRequested then
    Exit;

  if FMode = mrmManual then
  begin
    SetStage(msWaitMeasureStart);
    Exit;
  end;

  if ShouldWaitStable and
     (FWorkTable <> nil) and
     not (FWorkTable.State in [swtSTARTTEST, swtSTARTWAIT, swtEXECUTE]) then
    FWorkTable.StartMonitor;
end;

procedure TMeasurementRun.EnterWaitMeasureStart;
begin
  if IsStopRequested then
  begin
    SetStopReason(msrCancelledBeforeStart);
    ProtocolManager.AddMessage(pcInfo, psMeasurement, 'EnterWaitMeasureStart',
      'Запуск измерения отменён до отправки StartTest',
      Format('Stage=%s; Reason=%s', [MeasurementStateToString(FCurrentStage),
        MeasurementStopReasonToString(GetStopReason)]));
    SetStage(msDone);
    Exit;
  end;

  SetCurrentPointStatus(mptsWaitMeasureStart);
  FMeasureTimeout := CalcMeasureTimeout(GetCurrentPoint);

  if FWorkTable = nil then
  begin
    SetCurrentPointStatus(mptsMeasureError);
    FireEvent(meMeasureError, BuildError(1400, 'Рабочий стол не назначен'));
    SetStage(msDone);
    Exit;
  end;

  ProtocolManager.AddMessage(pcAction, psMeasurement, 'StartTest',
    'Отдана команда запуска измерения', MeasurementStateToString(FCurrentStage));
  AddDiagnosticEvent('StartTest called');
  FPhysicalMeasureStarted := True;
  FWorkTable.StartTest;
end;

procedure TMeasurementRun.EnterMeasure;
begin
  SetCurrentPointStatus(mptsMeasure);
  FireEvent(meMeasureStarted);
end;

procedure TMeasurementRun.EnterWaitMeasureStop;
begin
  SetCurrentPointStatus(mptsWaitMeasureStop);
  if FWorkTable = nil then
  begin
    SetCurrentPointStatus(mptsMeasureError);
    SetStage(msDone);
    Exit;
  end;

  if WorkTableNeedsPhysicalStop then
  begin
    if not FPhysicalStopRequested then
    begin
      FPhysicalStopRequested := True;
      ProtocolManager.AddMessage(pcAction, psMeasurement, 'StopTest',
        'Отдана команда остановки измерения',
        Format('Stage=%s; Reason=%s', [MeasurementStateToString(FCurrentStage),
          MeasurementStopReasonToString(GetStopReason)]));
      AddDiagnosticEvent('StopTest called');
      FWorkTable.StopTest;
    end
    else
      ProtocolManager.AddMessage(pcInfo, psMeasurement, 'StopTest',
        'Повторная команда StopTest не отправлена',
        MeasurementStateToString(FCurrentStage));
  end
  else
  begin
    ProtocolManager.AddMessage(pcInfo, psMeasurement, 'StopTest',
      'Физическая остановка не требуется или уже выполняется',
      MeasurementStateToString(FCurrentStage));
  end;
end;

procedure TMeasurementRun.EnterResultsRead;
begin
  // FWorkTable.SaveMeasurementResults; результат сохраняется в SaveMeasurementResults после чтения.
  SetCurrentPointStatus(mptsResultsRead);
  FireEvent(meResultReading);
end;

procedure TMeasurementRun.EnterSave;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
begin
  FNextStageAfterSave := msDone;
  SetCurrentPointStatus(mptsSave);

  FLastMeasureCompletedEventSent := True;
  FireEvent(meMeasureCompleted);

  Point := GetCurrentPoint;

  SaveMeasurementResults;
  FLastSaveDoneEventSent := True;
  FireEvent(meSaveDone);

  if IsStopRequested then
  begin
    MarkInterruptedPointIfNeeded;
    ProtocolManager.AddMessage(pcInfo, psMeasurement, 'EnterSave',
      'После Stop продолжение серии запрещено',
      Format('Stage=%s; Reason=%s', [MeasurementStateToString(FCurrentStage),
        MeasurementStopReasonToString(GetStopReason)]));
    FNextStageAfterSave := msDone;
    Exit;
  end;

  RepeatsTarget := 1;
  if (FMode <> mrmManual) and (Point <> nil) then
    RepeatsTarget := Max(Point.Repeats, 1);
  Inc(FCurrentRepeat);

  if FCurrentRepeat >= RepeatsTarget then
  begin
    if Point <> nil then
      SetCurrentPointStatus(mptsSaved);
    FCurrentRepeat := 0;
    FLastPointDoneEventSent := True;
    AddDiagnosticEvent('mePointDone');
    FireEvent(mePointDone);
    if FMode = mrmManual then
      FNextStageAfterSave := msDone
    else
    begin
      FNextStageAfterSave := msSelectPoint;
    end;
  end
  else
    FNextStageAfterSave := msSetupPoint;
end;

procedure TMeasurementRun.EnterDone;
begin
  if (GetCurrentPoint <> nil) and (GetCurrentPoint.Status = mptsResultsRead) then
    SetCurrentPointStatus(mptsDone);
  AddDiagnosticEvent('meAllDone');
  FireEvent(meAllDone);
  if FThread <> nil then
    FThread.Terminate;
end;


procedure TMeasurementRun.FireEvent(AEvent: EMeasurementEvent; const AError: TErrorInfo);
var
  ErrorDetails: string;
begin
  ProtocolManager.AddMessage(pcEvent, psMeasurement, 'FireEvent',
    'Событие измерения', MeasurementEventToString(AEvent));
  AddDiagnosticEvent('Event ' + MeasurementEventToString(AEvent));

  if (AError.Code <> 0) or (Trim(AError.Msg) <> '') then
  begin
    ErrorDetails := Format('Event=%s; Code=%d; Stage=%s; Time=%s; Msg=%s', [
      MeasurementEventToString(AEvent),
      AError.Code,
      MeasurementStateToString(EMeasurementState(AError.Stage)),
      FormatDateTime('dd.mm.yyyy hh:nn:ss', AError.Time),
      AError.Msg
    ]);

    ProtocolManager.AddMessage(pcError, psMeasurement, 'MeasurementError',
      'Ошибка события измерения', ErrorDetails);
  end;

  Notify(Integer(AEvent));
end;

procedure TMeasurementRun.FireEvent(AEvent: EMeasurementEvent);
begin
  FireEvent(AEvent, TErrorInfo.Empty(Integer(FCurrentStage)));
end;

function TMeasurementRun.BuildError(ACode: Integer; const AMsg: string): TErrorInfo;
begin
  Result.Code := ACode;
  Result.Msg := AMsg;
  Result.Time := Now;
  Result.Stage := Integer(FCurrentStage);
end;

function TMeasurementRun.GetCurrentPoint: TDevicePoint;
begin
  Result := nil;
  if FMode = mrmManual then
  begin
    if FWorkTable <> nil then
      Result := FWorkTable.CurrentPoint;
    Exit;
  end;

  if (FCurrentPointIndex >= 0) and (FCurrentPointIndex < FPoints.Count) then
    Result := FPoints[FCurrentPointIndex];
end;

function TMeasurementRun.IsThreadRunning: Boolean;
begin
  Result := Assigned(FThread) and (not FThread.Finished);
end;

function TMeasurementRun.IsStable(out StableInfo: RStableInfo): Boolean;
var
  Point: TDevicePoint;
  ParamInfo: RStableInfo;
  DiagnosticText: string;
  DiagnosticSecond: Int64;
begin
  Result := False;
  StableInfo.Status := sNONE;
  StableInfo.StatusText := '';
  StableInfo.CurrentValue := 0;
  Point := GetCurrentPoint;

  if (FWorkTable = nil) or (Point = nil) then
    Exit;

  Result := True;
  if (FWorkTable.FlowRate <> nil) and (Point.Q >= 0) then
  begin
    Result := CheckFlowStable(ParamInfo) and Result;
    if ParamInfo.Status <> sOk then
      StableInfo := ParamInfo;
  end;

  if (FWorkTable.FluidTemp <> nil) and (Point.Temp > 0) then
  begin
    Result := FWorkTable.FluidTemp.IsStable(ParamInfo) and Result;
    if ParamInfo.Status <> sOk then
      StableInfo := ParamInfo;
  end;

  if (FWorkTable.FluidPress <> nil) and (Point.Pressure > 0) then
  begin
    Result := FWorkTable.FluidPress.IsStable(ParamInfo) and Result;
    if ParamInfo.Status <> sOk then
      StableInfo := ParamInfo;
  end;

  DiagnosticSecond := Trunc((TThread.GetTickCount64 - FWaitStartedTick) / 1000);
  DiagnosticText := Format('IsStable=%s; Reason=%s', [BoolToStr(Result, True), StableInfo.StatusText]);
  if (DiagnosticText <> FLastDiagnosticIsStableText) or
     (DiagnosticSecond <> FLastDiagnosticIsStableSecond) then
  begin
    FLastDiagnosticIsStableText := DiagnosticText;
    FLastDiagnosticIsStableSecond := DiagnosticSecond;
    AddDiagnosticEvent(DiagnosticText);
  end;
end;


function TMeasurementRun.CheckFlowStable(out StableInfo: RStableInfo): Boolean;
var
  I: Integer;
  Channel: TChannel;
  StableValue: TMeterValue;
  Settings: TMeterValueStabilitySettings;
  SignalInfo: TMeterValueStabilityInfo;
  Point: TDevicePoint;
  TargetValue: Double;
  ActualValue: Double;
  MinPercent: Double;
  MaxPercent: Double;
  AllowedMinus: Double;
  AllowedPlus: Double;
  ToleranceSource: string;
  FlowReached: Boolean;
  HistoryStable: Boolean;
begin
  StableInfo := Default(RStableInfo);
  Result := False;

  Point := GetCurrentPoint;
  if (FWorkTable = nil) or (FWorkTable.FlowRate = nil) or (Point = nil) then
    Exit;

  StableValue := nil;
  if FWorkTable.EtalonChannels <> nil then
    for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
    begin
      Channel := FWorkTable.EtalonChannels[I];
      if (Channel <> nil) and Channel.Enabled and
         (Channel.FlowMeter <> nil) and (Channel.FlowMeter.ValueFlow <> nil) then
      begin
        StableValue := Channel.FlowMeter.ValueFlow;
        Break;
      end;
    end;

  if StableValue = nil then
    StableValue := FWorkTable.FlowRate.Value;
  if StableValue = nil then
    Exit;

  TargetValue := Point.Q;
  if (TargetValue < 0) and (FWorkTable.FlowRate.ValueSet <> nil) then
    TargetValue := FWorkTable.FlowRate.ValueSet.Value;

  ActualValue := StableValue.GetDoubleValue;
  Settings := StableValue.StabilitySettings;

  ToleranceSource := 'Point.FlowAccuracy';
  if AccuracyToRange(Point.FlowAccuracy, MinPercent, MaxPercent) then
  begin
    AllowedMinus := Abs(TargetValue) * Abs(MinPercent) / 100.0;
    AllowedPlus := Abs(TargetValue) * Abs(MaxPercent) / 100.0;
    StableInfo.LowerLimit := TargetValue - AllowedMinus;
    StableInfo.UpperLimit := TargetValue + AllowedPlus;
  end
  else
  begin
    ToleranceSource := 'TMeterValue.StabilitySettings';
    AllowedMinus := Max(Abs(TargetValue) * Abs(Settings.TargetAccuracyMinusPercent) / 100.0,
      Settings.TargetToleranceAbsolute);
    AllowedPlus := Max(Abs(TargetValue) * Abs(Settings.TargetAccuracyPlusPercent) / 100.0,
      Settings.TargetToleranceAbsolute);
    if SameValue(AllowedMinus, 0) and SameValue(AllowedPlus, 0) then
    begin
      ToleranceSource := 'IsFlowFit default accuracy';
      AllowedMinus := Abs(TargetValue) * 10.0 / 100.0;
      AllowedPlus := AllowedMinus;
    end;
    StableInfo.LowerLimit := TargetValue - AllowedMinus;
    StableInfo.UpperLimit := TargetValue + AllowedPlus;
  end;

  StableInfo.TargetValue := TargetValue;
  StableInfo.CurrentValue := ActualValue;
  StableInfo.IsCurrentInRange := (ActualValue >= StableInfo.LowerLimit) and
    (ActualValue <= StableInfo.UpperLimit);
  StableInfo.IsMeanInRange := True;
  StableInfo.IsForecastInRange := True;
  FlowReached := StableInfo.IsCurrentInRange;

  HistoryStable := True;
  if Settings.Enabled then
  begin
    StableValue.AddSample(ActualValue);
    HistoryStable := StableValue.AnalyzeStability(SignalInfo);
    StableInfo.SignalInfo := SignalInfo;
    StableInfo.IsSignalStable := HistoryStable;
    StableInfo.MeanValue := SignalInfo.MeanValue;
    StableInfo.ForecastValue := SignalInfo.ForecastValue;
    StableInfo.IsMeanInRange := (not Settings.RequireMeanValueInRange) or
      ((SignalInfo.MeanValue >= StableInfo.LowerLimit) and (SignalInfo.MeanValue <= StableInfo.UpperLimit));
    StableInfo.IsForecastInRange := (not Settings.RequireForecastInRange) or
      ((SignalInfo.ForecastValue >= StableInfo.LowerLimit) and (SignalInfo.ForecastValue <= StableInfo.UpperLimit));
    HistoryStable := HistoryStable and StableInfo.IsMeanInRange and StableInfo.IsForecastInRange;
  end
  else
  begin
    StableInfo.SignalInfo.Status := mvssDisabled;
    StableInfo.IsSignalStable := True;
    StableInfo.MeanValue := ActualValue;
    StableInfo.ForecastValue := ActualValue;
  end;

  StableInfo.IsTargetConditionPassed := FlowReached and StableInfo.IsMeanInRange and StableInfo.IsForecastInRange;
  StableInfo.IsReadyForMeasurement := FlowReached and HistoryStable;
  Result := StableInfo.IsReadyForMeasurement;

  if Result then
    StableInfo.Status := sOk
  else
    StableInfo.Status := sRun_NN;

  StableInfo.StatusText := Format('FlowReached=%s; HistoryAnalysisEnabled=%s; HistoryAnalysisSkipped=%s; '
    + 'ToleranceSource=%s; Target=%.6f; Actual=%.6f; FlowMin=%.6f; FlowMax=%.6f; '
    + 'AllowedDeviationLS=%.6f/%.6f; ActualDeviationLS=%.6f; ActualDeviationPercent=%.6f',
    [BoolToStr(FlowReached, True), BoolToStr(Settings.Enabled, True), BoolToStr(not Settings.Enabled, True),
     ToleranceSource, TargetValue, ActualValue, StableInfo.LowerLimit, StableInfo.UpperLimit,
     AllowedMinus, AllowedPlus, Abs(ActualValue - TargetValue),
     IfThen(not SameValue(TargetValue, 0), Abs(ActualValue - TargetValue) / Abs(TargetValue) * 100.0, 0.0)]);

  if Settings.Enabled and (not HistoryStable) and (SignalInfo.StatusText <> '') then
    StableInfo.StatusText := StableInfo.StatusText + '; HistoryReason=' + SignalInfo.StatusText;
end;

procedure TMeasurementRun.ContinueAfterPointError(const AStatus: EMeasurementPointStatus;
  AEvent: EMeasurementEvent; const AError: TErrorInfo);
begin
  AddDiagnosticEvent('Point error: Status=' + GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(AStatus)) + '; Event=' + MeasurementEventToString(AEvent) + '; Error=' + AError.Msg);
  SetCurrentPointStatus(AStatus);
  FireEvent(AEvent, AError);
  FCurrentRepeat := 0;
  SetStopReason(msrError);

  if FMode = mrmAutomatic then
    SetStage(msSelectPoint)
  else
    SetStage(msDone);
end;


procedure TMeasurementRun.AddDiagnosticEvent(const AText: string);
const
  MAX_DIAGNOSTIC_EVENTS = 5000;
begin
  if (FMeasurementDiagnosticEvents = nil) or (FMeasurementDiagnosticCS = nil) then
    Exit;

  FMeasurementDiagnosticCS.Acquire;
  try
    while FMeasurementDiagnosticEvents.Count >= MAX_DIAGNOSTIC_EVENTS do
    begin
      FMeasurementDiagnosticEvents.Delete(0);
      Inc(FMeasurementDiagnosticDropped);
    end;
    FMeasurementDiagnosticEvents.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AText);
  finally
    FMeasurementDiagnosticCS.Release;
  end;
end;

procedure TMeasurementRun.AddWorkTableStateDiagnosticEvent;
begin
  if FWorkTable = nil then
    Exit;
  if FWorkTable.State <> FLastDiagnosticWorkTableState then
  begin
    AddDiagnosticEvent('WorkTable.State ' + GetEnumName(TypeInfo(EStateWorkTable), Ord(FLastDiagnosticWorkTableState)) +
      ' -> ' + GetEnumName(TypeInfo(EStateWorkTable), Ord(FWorkTable.State)));
    FLastDiagnosticWorkTableState := FWorkTable.State;
  end;
end;

function TMeasurementRun.DrainDiagnosticEvents: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if (FMeasurementDiagnosticEvents = nil) or (FMeasurementDiagnosticCS = nil) then
    Exit;

  FMeasurementDiagnosticCS.Acquire;
  try
    SetLength(Result, FMeasurementDiagnosticEvents.Count + Ord(FMeasurementDiagnosticDropped > 0));
    I := 0;
    if FMeasurementDiagnosticDropped > 0 then
    begin
      Result[0] := Format('%s <удалено старых диагностических событий: %d>',
        [FormatDateTime('hh:nn:ss.zzz', Now), FMeasurementDiagnosticDropped]);
      I := 1;
    end;
    while I < Length(Result) do
    begin
      Result[I] := FMeasurementDiagnosticEvents[I - Ord(FMeasurementDiagnosticDropped > 0)];
      Inc(I);
    end;
    FMeasurementDiagnosticEvents.Clear;
    FMeasurementDiagnosticDropped := 0;
  finally
    FMeasurementDiagnosticCS.Release;
  end;
end;

function TMeasurementRun.BuildDiagnosticSnapshot(const ASwitchAutoText: string): string;
const
  STABLE_TIMEOUT_SEC = 30;
var
  Lines: TStringList;
  Point, NextPoint: TDevicePoint;
  StableInfo, FlowStableInfo: RStableInfo;
  IsStableResult, IsFlowStableResult: Boolean;
  NextIndex: Integer;
  WaitStableSec, MeasureSec: Double;
  Reason: string;
  ActualFlowSource, ActualFlowValue, EtalonName: string;
  EtalonIndex: Integer;
  I: Integer;
  Channel: TChannel;
  CurrentTime, CurrentVolume: Double;
  CurrentImp: Int64;
  TolMinPercent, TolMaxPercent: Double;
  FlowToleranceSource: string;
  FlowToleranceRawValue: string;
  FlowToleranceUnit: string;
  AllowedDeviationLS: Double;
  ActualDeviationLS: Double;
  ActualDeviationPercent: Double;
  FlowReached: Boolean;
  TargetFlowForLog: Double;
  ActualFlowForLog: Double;

  function SBool(AValue: Boolean): string;
  begin
    if AValue then Result := 'True' else Result := 'False';
  end;

  function SFloat(AValue: Double): string;
  begin
    Result := FormatFloat('0.######', AValue);
  end;

begin
  Lines := TStringList.Create;
  try
    Point := GetCurrentPoint;
    IsFlowStableResult := CheckFlowStable(FlowStableInfo);
    IsStableResult := IsStable(StableInfo);
    Reason := StableInfo.StatusText;
    if Reason = '' then
      Reason := '<нет данных>';

    EtalonIndex := -1;
    EtalonName := '<нет данных>';
    ActualFlowSource := '<нет данных>';
    ActualFlowValue := '<нет данных>';
    if (FWorkTable <> nil) and (FWorkTable.EtalonChannels <> nil) then
      for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
      begin
        Channel := FWorkTable.EtalonChannels[I];
        if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) and
           (Channel.FlowMeter.ValueFlow <> nil) then
        begin
          EtalonIndex := I;
          ActualFlowSource := Format('EtalonChannels[%d].FlowMeter.ValueFlow', [I]);
          ActualFlowValue := SFloat(Channel.FlowMeter.ValueFlow.GetDoubleValue);
          if Channel.Name <> '' then
            EtalonName := Channel.Name
          else if Channel.FlowMeter.Device <> nil then
            EtalonName := Channel.FlowMeter.Device.Name;
          Break;
        end;
      end;
    if (ActualFlowValue = '<нет данных>') and (FWorkTable <> nil) and (FWorkTable.FlowRate <> nil) and
       (FWorkTable.FlowRate.Value <> nil) then
    begin
      ActualFlowSource := 'WorkTable.FlowRate.Value';
      ActualFlowValue := SFloat(FWorkTable.FlowRate.Value.GetDoubleValue);
    end;

    WaitStableSec := 0;
    if FCurrentStage = msWaitStable then
      WaitStableSec := (TThread.GetTickCount64 - FWaitStartedTick) / 1000;
    MeasureSec := 0;
    if FCurrentStage = msMeasure then
      MeasureSec := (TThread.GetTickCount64 - FWaitStartedTick) / 1000;

    NextIndex := FindNextEnabledPointIndex(FCurrentPointIndex + 1);
    NextPoint := nil;
    if (NextIndex >= 0) and (NextIndex < FPoints.Count) then
      NextPoint := FPoints[NextIndex];

    CurrentTime := GetCurrentStopTimeValue;
    CurrentVolume := GetCurrentStopVolumeValue;
    CurrentImp := GetCurrentStopImpulseValue;

    TargetFlowForLog := FlowStableInfo.TargetValue;
    ActualFlowForLog := FlowStableInfo.CurrentValue;
    FlowToleranceSource := 'Point.FlowAccuracy';
    FlowToleranceRawValue := '<нет данных>';
    FlowToleranceUnit := '%';
    if (Point <> nil) and AccuracyToRange(Point.FlowAccuracy, TolMinPercent, TolMaxPercent) then
    begin
      FlowToleranceRawValue := Point.FlowAccuracy;
      AllowedDeviationLS := Max(Abs(TargetFlowForLog) * Abs(TolMinPercent) / 100.0,
        Abs(TargetFlowForLog) * Abs(TolMaxPercent) / 100.0);
    end
    else
    begin
      FlowToleranceSource := 'TMeterValue.StabilitySettings/IsFlowFit default';
      FlowToleranceRawValue := Format('FlowMin=%f; FlowMax=%f',
        [FlowStableInfo.LowerLimit, FlowStableInfo.UpperLimit]);
      FlowToleranceUnit := 'л/с';
      AllowedDeviationLS := Max(Abs(FlowStableInfo.LowerLimit - TargetFlowForLog),
        Abs(FlowStableInfo.UpperLimit - TargetFlowForLog));
    end;
    ActualDeviationLS := Abs(ActualFlowForLog - TargetFlowForLog);
    if SameValue(TargetFlowForLog, 0) then
      ActualDeviationPercent := 0
    else
      ActualDeviationPercent := ActualDeviationLS / Abs(TargetFlowForLog) * 100.0;
    FlowReached := (ActualFlowForLog >= FlowStableInfo.LowerLimit) and
      (ActualFlowForLog <= FlowStableInfo.UpperLimit);

    Lines.Add('==================================================');
    Lines.Add('Время снимка: ' + FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now));
    Lines.Add('Причина: ручное нажатие «Добавить лог»');
    Lines.Add('');
    Lines.Add('[РЕЖИМ]');
    Lines.Add('SwitchAuto=' + ASwitchAutoText);
    Lines.Add('MeasurementRun.Mode=' + GetEnumName(TypeInfo(EMeasurementRunMode), Ord(FMode)));
    if FWorkTable <> nil then
    begin
      Lines.Add('WorkTable.MeasurementMode=' + GetEnumName(TypeInfo(EMeasurementRunMode), Ord(FWorkTable.MeasurementMode)));
      Lines.Add('WorkTable.State=' + GetEnumName(TypeInfo(EStateWorkTable), Ord(FWorkTable.State)));
    end
    else
    begin
      Lines.Add('WorkTable.MeasurementMode=<нет данных>');
      Lines.Add('WorkTable.State=<нет данных>');
    end;
    Lines.Add('MeasurementRun.Stage=' + MeasurementStateToString(FCurrentStage));
    Lines.Add('WorkerThreadRunning=' + SBool(IsThreadRunning));
    Lines.Add('StopRequested=' + SBool(FStopRequested));
    Lines.Add('NextStageAfterSave=' + MeasurementStateToString(FNextStageAfterSave));
    Lines.Add('ForceNextPoint=' + IntToStr(FForceNextPoint));
    Lines.Add('');
    Lines.Add('[ТОЧКА]');
    Lines.Add('CurrentPointIndex=' + IntToStr(FCurrentPointIndex));
    if FPoints <> nil then Lines.Add('Points.Count=' + IntToStr(FPoints.Count)) else Lines.Add('Points.Count=<нет данных>');
    if Point <> nil then
    begin
      Lines.Add('Name=' + Point.Name);
      Lines.Add('UUID=' + Point.UUID);
      Lines.Add('Enabled=' + SBool(Point.Enabled));
      Lines.Add('State=' + GetEnumName(TypeInfo(TObjectState), Ord(Point.State)));
      Lines.Add('Status=' + GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(Point.Status)));
      Lines.Add('FlowRate=' + SFloat(Point.FlowRate));
      Lines.Add('Q=' + SFloat(Point.Q));
      Lines.Add('StopCriteria=' + StopCriteriaToLogString(Point.StopCriteria));
      Lines.Add('LimitTime=' + SFloat(Point.LimitTime));
      Lines.Add('LimitVolume=' + SFloat(Point.LimitVolume));
      Lines.Add('LimitImp=' + IntToStr(Point.LimitImp));
      Lines.Add('Repeats=' + IntToStr(Point.Repeats));
      Lines.Add('RepeatsCompleted=' + IntToStr(Point.RepeatsCompleted));
    end
    else
      Lines.Add('CurrentPoint=<нет данных>');
    Lines.Add('CurrentRepeat=' + IntToStr(FCurrentRepeat));
    Lines.Add('');
    Lines.Add('[СТАБИЛИЗАЦИЯ]');
    Lines.Add('Stage=' + MeasurementStateToString(FCurrentStage));
    Lines.Add('WaitStableSec=' + SFloat(WaitStableSec));
    if (FWorkTable <> nil) and (FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.ValueSet <> nil) then
      Lines.Add('TargetFlowLS=' + SFloat(FWorkTable.FlowRate.ValueSet.Value))
    else
      Lines.Add('TargetFlowLS=<нет данных>');
    Lines.Add('ActualFlowLS=' + ActualFlowValue);
    Lines.Add('ActualFlowSource=' + ActualFlowSource);
    Lines.Add('SelectedEtalonIndex=' + IntToStr(EtalonIndex));
    Lines.Add('SelectedEtalonName=' + EtalonName);
    Lines.Add('FlowMin=' + SFloat(FlowStableInfo.LowerLimit));
    Lines.Add('FlowMax=' + SFloat(FlowStableInfo.UpperLimit));
    Lines.Add('FlowToleranceSource=' + FlowToleranceSource);
    Lines.Add('FlowToleranceRawValue=' + FlowToleranceRawValue);
    Lines.Add('FlowToleranceUnit=' + FlowToleranceUnit);
    Lines.Add('AllowedDeviationLS=' + SFloat(AllowedDeviationLS));
    Lines.Add('ActualDeviationLS=' + SFloat(ActualDeviationLS));
    Lines.Add('ActualDeviationPercent=' + SFloat(ActualDeviationPercent));
    Lines.Add('FlowReached=' + SBool(FlowReached));
    Lines.Add('HistoryAnalysisEnabled=' + SBool(FlowStableInfo.SignalInfo.Status <> mvssDisabled));
    Lines.Add('HistoryAnalysisSkipped=' + SBool(FlowStableInfo.SignalInfo.Status = mvssDisabled));
    Lines.Add('IsFlowStable=' + SBool(IsFlowStableResult));
    Lines.Add('IsStable=' + SBool(IsStableResult));
    Lines.Add('Reason=' + Reason);
    Lines.Add('Attempt=' + IntToStr(FAttempt));
    Lines.Add('MaxAttemptCount=' + IntToStr(FMaxAttemptCount));
    Lines.Add('TimeoutSec=' + IntToStr(STABLE_TIMEOUT_SEC));
    Lines.Add('');
    Lines.Add('[ИЗМЕРЕНИЕ]');
    Lines.Add('MeasureStageSec=' + SFloat(MeasureSec));
    Lines.Add('CurrentTime=' + SFloat(CurrentTime));
    Lines.Add('CurrentVolume=' + SFloat(CurrentVolume));
    Lines.Add('CurrentImpulses=' + IntToStr(CurrentImp));
    if Point <> nil then
    begin
      Lines.Add('TimeReached=' + SBool((scTime in Point.StopCriteria) and (Point.LimitTime > 0) and (CurrentTime >= Point.LimitTime)));
      Lines.Add('VolumeReached=' + SBool((scVolume in Point.StopCriteria) and (Point.LimitVolume > 0) and (CurrentVolume >= Point.LimitVolume)));
      Lines.Add('ImpulseReached=' + SBool((scImpulse in Point.StopCriteria) and (Point.LimitImp > 0) and (CurrentImp >= Point.LimitImp)));
    end;
    Lines.Add('StopCriteriaReached=' + SBool(IsCommandStopLimitReached(Reason)));
    Lines.Add('StopReason=' + MeasurementStopReasonToString(FStopReason));
    Lines.Add('RequestStopCalled=' + SBool(FStopRequested));
    Lines.Add('RouteStopInWorker=<см. события>');
    Lines.Add('');
    Lines.Add('[ПЕРЕХОД]');
    Lines.Add('CurrentPointIndex=' + IntToStr(FCurrentPointIndex));
    Lines.Add('NextSearchStartIndex=' + IntToStr(FCurrentPointIndex + 1));
    Lines.Add('NextEnabledPointIndex=' + IntToStr(NextIndex));
    if NextPoint <> nil then
    begin
      Lines.Add('NextPointName=' + NextPoint.Name);
      Lines.Add('NextPointEnabled=' + SBool(NextPoint.Enabled));
      Lines.Add('NextPointState=' + GetEnumName(TypeInfo(TObjectState), Ord(NextPoint.State)));
    end
    else
      Lines.Add('NextPointReason=<следующая включенная точка не найдена>');
    Lines.Add('CurrentStage=' + MeasurementStateToString(FCurrentStage));
    Lines.Add('NextStageAfterSave=' + MeasurementStateToString(FNextStageAfterSave));
    Lines.Add('DoneReason=<см. события>');
    Lines.Add('');
    Lines.Add('[СОХРАНЕНИЕ]');
    Lines.Add('SaveMeasurementResultsCalled=' + SBool(FLastSaveMeasurementResultsCalled));
    Lines.Add('LastSaveResult=' + FLastSaveMeasurementResultsResult);
    Lines.Add('MeasureCompletedEventSent=' + SBool(FLastMeasureCompletedEventSent));
    Lines.Add('SaveDoneEventSent=' + SBool(FLastSaveDoneEventSent));
    Lines.Add('PointDoneEventSent=' + SBool(FLastPointDoneEventSent));
    Lines.Add('ResultsAddedToProcessing=<поле отсутствует в текущей реализации>');
    Lines.Add('ResultsPerDevice=<поле отсутствует в текущей реализации>');
    if FLastSaveErrorText <> '' then Lines.Add('LastSaveError=' + FLastSaveErrorText) else Lines.Add('LastSaveError=<нет данных>');
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function TMeasurementRun.IsTerminated: Boolean;
begin
  Result := (FThread = nil) or FThread.CheckTerminated;
end;

procedure TMeasurementRun.CreateSession;
var
  Point: TDevicePoint;
begin
  FPoints.Clear;
  if FWorkTable = nil then
    Exit;

  case FMode of
    mrmAutomatic:
      if ShouldUseAllPoints then
        CreateSessionPoints;
    mrmManual:
      begin
        // Manual mode measures the current worktable point as-is.
        // Do not create or select a session point here.
      end;
    mrmHalfAutomatic:
      begin
        Point := CreateSingleSessionPoint(True);
        if Point <> nil then
          FPoints.Add(Point);
      end;
  end;

  ProtocolManager.AddMessage(pcInfo, psMeasurement, 'CreateSession',
    'Создание сессии измерения',
    Format('Mode=%d; Points=%d', [Ord(FMode), FPoints.Count]));
end;

function TMeasurementRun.ShouldUseAllPoints: Boolean;
begin
  Result := FMode = mrmAutomatic;
end;

function TMeasurementRun.ShouldSetupConditions: Boolean;
begin
  Result := FMode in [mrmHalfAutomatic, mrmAutomatic];
end;

function TMeasurementRun.ShouldWaitStable: Boolean;
begin
  Result := FMode in [mrmHalfAutomatic, mrmAutomatic];
end;

function TMeasurementRun.ShouldSelectEtalon: Boolean;
begin
  Result := FMode in [mrmHalfAutomatic, mrmAutomatic];
end;

function TMeasurementRun.CreateSingleSessionPoint(AWithConditions: Boolean): TDevicePoint;
begin
  Result := nil;
  if FWorkTable = nil then
    Exit;

  Result := TDevicePoint.Create(0);
  Result.Num := 1;
  Result.Status := mptsNone;
  Result.RepeatsCompleted := 0;

  if FWorkTable.CurrentPoint <> nil then
  begin
    Result.LimitTime := FWorkTable.CurrentPoint.LimitTime;
    Result.LimitImp := FWorkTable.CurrentPoint.LimitImp;
    Result.LimitVolume := FWorkTable.CurrentPoint.LimitVolume;
    Result.StopCriteria := FWorkTable.CurrentPoint.StopCriteria;
    Result.Repeats := FWorkTable.CurrentPoint.Repeats;
    Result.RepeatsProtocol := FWorkTable.CurrentPoint.RepeatsProtocol;
  end
  else
  begin
    Result.LimitTime := -1;
    Result.LimitImp := -1;
    Result.LimitVolume := -1;
    Result.StopCriteria := [];
    Result.Repeats := 1;
    Result.RepeatsProtocol := 1;
  end;

  if Result.Repeats <= 0 then
    Result.Repeats := Max(FWorkTable.Repeats, 1);
  if Result.RepeatsProtocol <= 0 then
    Result.RepeatsProtocol := Result.Repeats;

  if AWithConditions then
  begin
    if (FWorkTable.CurrentPoint <> nil) and (FWorkTable.CurrentPoint.Q >= 0) then
      Result.Q := FWorkTable.CurrentPoint.Q
    else if (FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.ValueSet.Value >= 0) then
      Result.Q := FWorkTable.FlowRate.ValueSet.Value
    else
      Result.Q := -1;

    if (FWorkTable.CurrentPoint <> nil) and (FWorkTable.CurrentPoint.Temp >= 0) then
      Result.Temp := FWorkTable.CurrentPoint.Temp
    else if FWorkTable.FluidTemp <> nil then
      Result.Temp := FWorkTable.FluidTemp.ValueSet.Value
    else
      Result.Temp := -1;

    if (FWorkTable.CurrentPoint <> nil) and (FWorkTable.CurrentPoint.Pressure >= 0) then
      Result.Pressure := FWorkTable.CurrentPoint.Pressure
    else if FWorkTable.FluidPress <> nil then
      Result.Pressure := FWorkTable.FluidPress.ValueSet.Value
    else
      Result.Pressure := -1;
  end
  else
  begin
    Result.Q := -1;
    Result.Temp := -1;
    Result.Pressure := -1;
  end;
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
  if FWorkTable = nil then
    Exit;

  if FWorkTable.DeviceChannels.Count = 0 then
    FWorkTable.AddDeviceChannel(
      True,
      -1,
      TWorkTable.BuildChannelDefaultText(1),
      '',
      '-',
      ''
    );

  for Channel in FWorkTable.DeviceChannels do
  begin
    if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
      Continue;

    Device := Channel.FlowMeter.Device;
    if ((Device = nil) or (Device.Points = nil) or (Device.Points.Count = 0)) and
       (DataManager <> nil) and (DataManager.ActiveDeviceRepo <> nil) then
      Device := TDeviceCreationService.EnsureDeviceForChannel(
        Channel,
        FWorkTable,
        DataManager.ActiveDeviceRepo,
        dcmMeasurementPromoted,
        nil,
        FWorkTable.CurrentPoint
      );

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
        SessionPoint.Assign(SourcePoint, True);
        SessionPoint.Status := mptsNone;
        SessionPoint.RepeatsCompleted := 0;
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

    FStopRequested := False;
    FStopReason := msrNone;
    FPhysicalMeasureStarted := False;
    FPhysicalStopRequested := False;
    FActualStopEventFired := False;
    CreateSession;
    if FWorkTable = nil then
    begin
      ProtocolManager.AddMessage(pcWarning, psMeasurement, 'Start',
        'Измерение не запущено', 'Не задан рабочий стол');
      FireEvent(meMeasureError, BuildError(1001, 'Не задан рабочий стол'));
      if FCurrentStage <> msNone then
        SetStage(msNone);
      Exit;
    end;

    if (FMode = mrmManual) and (FWorkTable.CurrentPoint = nil) then
    begin
      ProtocolManager.AddMessage(pcWarning, psMeasurement, 'Start',
        'Измерение не запущено', 'В ручном режиме не задана текущая точка измерения');
      FireEvent(mePointNotSet, BuildError(1002, 'В ручном режиме не задана текущая точка измерения'));
      if FCurrentStage <> msNone then
        SetStage(msNone);
      Exit;
    end;

    if (FMode <> mrmManual) and ((FPoints.Count = 0) or
       ((FMode = mrmAutomatic) and (FindNextEnabledPointIndex(0) < 0))) then
    begin
      ProtocolManager.AddMessage(pcWarning, psMeasurement, 'Start',
        'Измерение не запущено', 'Нет включенных точек измерения');
      if FCurrentStage <> msNone then
        SetStage(msNone);
      Exit;
    end;

    FCurrentPointIndex := -1;
    FCurrentRepeat := 0;
    FForceNextPoint := -1;
    FIsPaused := False;
    FAttempt := 0;
    FMeasureTimeout := 0;
    FNextStageAfterSave := msNone;
    FLastDiagnosticWorkTableState := swtNONE;
    FLastSaveMeasurementResultsCalled := False;
    FLastSaveMeasurementResultsResult := 'not called';
    FLastSaveErrorText := '';
    FLastMeasureCompletedEventSent := False;
    FLastSaveDoneEventSent := False;
    FLastPointDoneEventSent := False;

    case Mode of
      mrmAutomatic:
        ProtocolManager.AddMessage(pcAction, psMeasurement, 'Start',
          'Запуск процесса измерения в автоматическом режиме', '');
      mrmManual:
        ProtocolManager.AddMessage(pcAction, psMeasurement, 'Start',
          'Запуск процесса измерения в ручном режиме', '');
      mrmHalfAutomatic:
        ProtocolManager.AddMessage(pcAction, psMeasurement, 'Start',
          'Запуск процесса измерения в полуавтоматическом режиме', '');
    end;

  // Создаём отдельный рабочий поток для выполнения процесса измерения.
  //
  // Поток создаётся в приостановленном состоянии. Фактическое выполнение
  // анонимной процедуры начнётся только после вызова FThread.Start.


  FThread := TThread.CreateAnonymousThread(
  procedure
  var
    ThreadName: string;
  begin
    ThreadName := Format(
      'MeasurementRun_%s_%d',
      [
        Name,
        Ord(Mode)
      ]
    );

    TThread.NameThreadForDebugging(ThreadName);

    RunThreadProc;
  end
);

  FThread.FreeOnTerminate := False;
  FThread.Start;


   // if not FStopRequested then
   //   FireEvent(meStarted);
  finally
    FCriticalSection.Release;
  end;
end;

procedure TMeasurementRun.StopWorkerThread;
var
  LThread: TThread;
  IsCurrentThread: Boolean;
begin
  LThread := nil;
  IsCurrentThread := False;

  FCriticalSection.Acquire;
  try
    LThread := FThread;
    if LThread = nil then
      Exit;

    LThread.Terminate;
    IsCurrentThread := TThread.CurrentThread.ThreadID = LThread.ThreadID;
    if not IsCurrentThread then
      FThread := nil;
  finally
    FCriticalSection.Release;
  end;

  // Waiting for the current worker from inside itself would deadlock.
  if not IsCurrentThread then
  begin
    LThread.WaitFor;
    LThread.Free;
  end;
end;

function TMeasurementRun.IsStopRequested: Boolean;
begin
  FCriticalSection.Acquire;
  try
    Result := FStopRequested;
  finally
    FCriticalSection.Release;
  end;
end;

function TMeasurementRun.GetStopReason: TMeasurementStopReason;
begin
  FCriticalSection.Acquire;
  try
    Result := FStopReason;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TMeasurementRun.SetStopReason(AReason: TMeasurementStopReason);
begin
  FCriticalSection.Acquire;
  try
    if (FStopReason in [msrNone, msrNormalComplete, msrUserStop, msrLimitReached]) or
       (AReason in [msrError, msrEmergency]) then
      FStopReason := AReason;
  finally
    FCriticalSection.Release;
  end;
end;

function TMeasurementRun.HasPhysicalMeasurementStarted: Boolean;
begin
  Result := FPhysicalMeasureStarted;
  if not Result and (FWorkTable <> nil) then
    Result := FWorkTable.State in [swtSTARTTEST, swtSTARTWAIT, swtEXECUTE,
      swtSTOPTEST, swtSTOPWAIT, swtFINALREAD, swtCOMPLETE];
end;

function TMeasurementRun.WorkTableNeedsPhysicalStop: Boolean;
begin
  Result := (FWorkTable <> nil) and
    (FWorkTable.State in [swtSTARTTEST, swtSTARTWAIT, swtEXECUTE]);
end;

procedure TMeasurementRun.FireActualStopOnce;
begin
  if FActualStopEventFired then
    Exit;
  FActualStopEventFired := True;
  ProtocolManager.AddMessage(pcEvent, psMeasurement, 'ActualStop',
    'Фактическая остановка измерения подтверждена',
    Format('Stage=%s; Reason=%s', [MeasurementStateToString(FCurrentStage),
      MeasurementStopReasonToString(GetStopReason)]));
  FireEvent(meStopped);
end;

procedure TMeasurementRun.MarkInterruptedPointIfNeeded;
begin
  if IsStopRequested and (GetCurrentPoint <> nil) and
     not (GetCurrentPoint.Status in [mptsMeasureError, mptsSetupError, mptsCancelled, mptsSaved]) then
    SetCurrentPointStatus(mptsInterrupted);
end;

procedure TMeasurementRun.RouteStopInWorker;
begin
  if IsStopRequested then
    AddDiagnosticEvent('RouteStopInWorker processing: Stage=' + MeasurementStateToString(FCurrentStage));
  if not IsStopRequested then
    Exit;

  case FCurrentStage of
    msNone, msDone:
      Exit;
    msWaitMeasureStop, msResultsRead, msSave:
      Exit;
    msWaitMeasureStart, msMeasure:
      begin
        SetStage(msWaitMeasureStop);
        Exit;
      end;
  else
    if HasPhysicalMeasurementStarted or WorkTableNeedsPhysicalStop then
      SetStage(msWaitMeasureStop)
    else
    begin
      SetStopReason(msrCancelledBeforeStart);
      ProtocolManager.AddMessage(pcInfo, psMeasurement, 'RouteStopInWorker',
        'Stop обработан до физического запуска измерения',
        Format('Stage=%s; Reason=%s', [MeasurementStateToString(FCurrentStage),
          MeasurementStopReasonToString(GetStopReason)]));
      if FWorkTable <> nil then
        FWorkTable.StopMonitor;
      SetCurrentPointStatus(mptsCancelled);
      FireActualStopOnce;
      SetStage(msDone);
    end;
  end;
end;

procedure TMeasurementRun.RequestStop;
var
  StageSnapshot: EMeasurementState;
  ReasonSnapshot: TMeasurementStopReason;
  Duplicate: Boolean;
begin
  FCriticalSection.Acquire;
  try
    StageSnapshot := FCurrentStage;
    ReasonSnapshot := FStopReason;
    if FStopRequested then
    begin
      Duplicate := True;
    end
    else
    begin
      Duplicate := False;
      FStopRequested := True;
      FIsPaused := False;
      if FStopReason in [msrNone, msrNormalComplete] then
        FStopReason := msrUserStop;
      ReasonSnapshot := FStopReason;
    end;
  finally
    FCriticalSection.Release;
  end;

  if Duplicate then
  begin
    ProtocolManager.AddMessage(pcInfo, psMeasurement, 'RequestStop',
      'Повторный запрос Stop проигнорирован',
      Format('Stage=%s; Reason=%s', [MeasurementStateToString(StageSnapshot),
        MeasurementStopReasonToString(ReasonSnapshot)]));
      Exit;
  end;

  ProtocolManager.AddMessage(pcAction, psMeasurement, 'RequestStop',
    'Запрошена принудительная остановка измерения',
    Format('Stage=%s; Reason=%s', [MeasurementStateToString(StageSnapshot),
      MeasurementStopReasonToString(ReasonSnapshot)]));

  AddDiagnosticEvent('RequestStop called');
  if StageSnapshot in [msWaitMeasureStart, msMeasure] then
    SetStage(msWaitMeasureStop);
  FireEvent(meStopRequested);
end;

procedure TMeasurementRun.Stop;
begin
  Execute(mcStop);
end;

procedure TMeasurementRun.Pause;
begin
  if FIsPaused then
    Exit;
  FIsPaused := True;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'Pause',
    'Пауза процесса измерения', '');
end;

procedure TMeasurementRun.Resume;
begin
  if not FIsPaused then
    Exit;
  FIsPaused := False;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'Resume',
    'Возобновление процесса измерения', '');
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
  HandleCommand(Cmd, Param);
end;

procedure TMeasurementRun.HandleCommand(Cmd: EMeasurementCommand; const Param: Variant);
begin
  case Cmd of
    mcStart: Start;
    mcStop, mcCancel: RequestStop;
    mcPause: Pause;
    mcResume: Resume;
    mcReset:
      begin
        RequestStop;
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
// msWaitMeasureStop is processed by ProcessStage for graceful Stop.

procedure InitializeRunStage;
var
  InitialStage: EMeasurementState;
begin
  case FMode of
    mrmAutomatic:
      InitialStage := msSelectPoint;

    mrmManual,
    mrmHalfAutomatic:
      InitialStage := msSetupPoint;
  else
    raise Exception.CreateFmt(
      'Unsupported measurement mode: %d',
      [Ord(FMode)]
    );
  end;

  FireEvent(meStarted);
  SetStage(InitialStage);

end;


begin

  InitializeRunStage;

  while not TThread.CurrentThread.CheckTerminated do
  begin
    try
      RouteStopInWorker;

      if FIsPaused then
      begin
        TThread.Sleep(50);
        Continue;
      end;

      if IsTerminated then
        Break;

      ProcessStage;

      if FCurrentStage = msDone then
        Break;
    except
      on E: Exception do
      begin
        FireEvent(meMeasureError, BuildError(1999, E.Message));
        if FCurrentStage <> msDone then
          ContinueAfterPointError(mptsMeasureError, meMeasureError, BuildError(1999, E.Message));
      end;
    end;

    TThread.Sleep(10);
  end;
end;

function TMeasurementRun.ValidatePoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
begin
  AError := TErrorInfo.Empty(Integer(msSelectPoint));
  Result := Assigned(APoint) and Assigned(FWorkTable);
  if not Result then
  begin
    AError := BuildError(1000, 'Точка или рабочий стол не назначены');
    Exit;
  end;

  if (APoint.Q > 0) and ((FWorkTable.FlowRate = nil) or
     (APoint.Q < FWorkTable.FlowRate.Min) or (APoint.Q > FWorkTable.FlowRate.Max)) then
  begin
    AError := BuildError(1001, 'Расход точки вне диапазона');
    Exit(False);
  end;

  if (APoint.Temp > 0) and ((FWorkTable.FluidTemp = nil) or
     (APoint.Temp < FWorkTable.FluidTemp.Min) or (APoint.Temp > FWorkTable.FluidTemp.Max)) then
  begin
    AError := BuildError(1002, 'Температура точки вне диапазона');
    Exit(False);
  end;

  if (APoint.Pressure > 0) and ((FWorkTable.FluidPress = nil) or
     (APoint.Pressure < FWorkTable.FluidPress.Min) or (APoint.Pressure > FWorkTable.FluidPress.Max)) then
  begin
    AError := BuildError(1003, 'Давление точки вне диапазона');
    Exit(False);
  end;
end;

function TMeasurementRun.SetPoint(Index: Integer; out AError: TErrorInfo): Boolean;
var
  Point: TDevicePoint;
begin
  AError := TErrorInfo.Empty(Integer(msSelectPoint));
  Result := False;
  if (Index < 0) or (Index >= FPoints.Count) then
  begin
    AError := BuildError(1004, 'Индекс точки вне диапазона');
    Exit;
  end;
  AddDiagnosticEvent(Format('SetPoint called: Index=%d; PreviousIndex=%d', [Index, FCurrentPointIndex]));
  FCurrentPointIndex := Index;
  Point := GetCurrentPoint;
  Result := ValidatePoint(Point, AError);
  if Result then
  begin

    FCurrentRepeat := Point.RepeatsCompleted;
    AddDiagnosticEvent('SetPoint success: ' + BuildPointSelectionLog(Point));

  end else
  begin
    AddDiagnosticEvent('SetPoint failed: ' + AError.Msg);
  end;
end;

function TMeasurementRun.SelectEtalons(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
begin
  AError := TErrorInfo.Empty(Integer(msSelectEtalon));
  Result := False;

  if (APoint = nil) or (FWorkTable = nil) then
  begin
    AError := BuildError(1100, 'Нет точки или рабочего стола для выбора эталона');
    Exit;
  end;

  Result := FWorkTable.SelectEtalons(APoint.Q, AError);
  if not Result then
    Exit;

  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcAction, psMeasurement, 'EtalonSelected',
      'Выбраны эталоны для точки', BuildEtalonSelectionLog(APoint));
end;

function TMeasurementRun.CalcMeasureTimeout(APoint: TDevicePoint): Cardinal;
const
  DEFAULT_MEASURE_TIMEOUT_SEC = 3600;
  MIN_POSITIVE_FLOW = 0.000001;
var
  TimeByLimit: Double;
  Q: Double;
  HasRestrictions: Boolean;
begin
  Result := DEFAULT_MEASURE_TIMEOUT_SEC;

  if APoint = nil then
    Exit;

  TimeByLimit := 0;
  HasRestrictions := False;

  if (scTime in APoint.StopCriteria) and (APoint.LimitTime > 0) then
  begin
    TimeByLimit := Max(TimeByLimit, APoint.LimitTime);
    HasRestrictions := True;
  end;

  // При нулевом/отрицательном расходе ограничения по объему и импульсам не учитываем.
  if APoint.Q > 0 then
  begin
    Q := Max(APoint.Q, MIN_POSITIVE_FLOW);

    if (scVolume in APoint.StopCriteria) and (APoint.LimitVolume > 0) then
    begin
      TimeByLimit := Max(TimeByLimit, APoint.LimitVolume / Q);
      HasRestrictions := True;
    end;

    if (scImpulse in APoint.StopCriteria) and (APoint.LimitImp > 0) then
    begin
      TimeByLimit := Max(TimeByLimit, APoint.LimitImp / Q);
      HasRestrictions := True;
    end;
  end;

  if HasRestrictions and (TimeByLimit > 0) then
    Result := Ceil(TimeByLimit)+5; // Аварийная добавка к измерению?!
end;

function TMeasurementRun.SetupPoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
begin
  Result := False;
  AError := TErrorInfo.Empty(Integer(FCurrentStage));

  if (FWorkTable = nil) or (APoint = nil) then
  begin
    AError := BuildError(1201, 'Невозможно задать параметры точки');
    Exit;
  end;

  if (APoint.Q >= 0) and (FWorkTable.FlowRate <> nil) then
  begin
    FWorkTable.FlowRate.DoFlowRateSet(APoint.Q);
    FWorkTable.FlowRate.DoFlowRateStart;
  end;

  if (APoint.Temp >= 0) and (FWorkTable.FluidTemp <> nil) then
    FWorkTable.FluidTemp.DoFluidTempStart(APoint.Temp);

  if (APoint.Pressure >= 0) and (FWorkTable.FluidPress <> nil) then
    FWorkTable.FluidPress.DoFluidPressStart(APoint.Pressure);

  Result := True;
end;

function TMeasurementRun.SetupMeasurement(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
var
  LimitTime: Double;
  LimitImp: Int64;
  LimitVolume: Double;
  StopCriteria: TSpillageStopCriteria;
begin
  Result := False;
  AError := TErrorInfo.Empty(Integer(FCurrentStage));

  if (FWorkTable = nil) or (APoint = nil) then
  begin
    AError := BuildError(1202, 'Невозможно настроить параметры измерения');
    Exit;
  end;

  LimitTime := APoint.LimitTime;
  LimitImp := APoint.LimitImp;
  LimitVolume := APoint.LimitVolume;
  StopCriteria := APoint.StopCriteria;

  if FWorkTable.CurrentPoint <> nil then
  begin
    FWorkTable.CurrentPoint.LimitTime := -1;
    FWorkTable.CurrentPoint.LimitImp := -1;
    FWorkTable.CurrentPoint.LimitVolume := -1;
    FWorkTable.CurrentPoint.StopCriteria := [];

    if (scTime in StopCriteria) and (LimitTime > 0) then
      FWorkTable.CurrentPoint.LimitTime := Round(LimitTime);

    if (scVolume in StopCriteria) and (LimitVolume > 0) then
      FWorkTable.CurrentPoint.LimitVolume := LimitVolume;

    if (scImpulse in StopCriteria) and (LimitImp > 0) then
      FWorkTable.CurrentPoint.LimitImp := LimitImp;

    FWorkTable.CurrentPoint.StopCriteria := StopCriteria;
  end;

  Result := True;
end;

procedure TMeasurementRun.Process;
begin

end;

procedure TMeasurementRun.ProcessStage;
begin
  AddWorkTableStateDiagnosticEvent;
  case FCurrentStage of
    msSelectPoint: ProcessSelectPoint;
    msSelectEtalon: ProcessSelectEtalon;
    msSetupPoint: ProcessSetupPoint;
    msWaitStable: ProcessWaitStable;
    msWaitMeasureStart: ProcessWaitMeasureStart;
    msMeasure: ProcessMeasure;
    msWaitMeasureStop: ProcessWaitMeasureStop;
    msResultsRead: ProcessResultsRead;
    msSave: ProcessSave;
    msDone: ProcessDone;
  end;
end;

procedure TMeasurementRun.ProcessSelectPoint;
begin
  // Point selection is performed once in EnterSelectPoint.
end;

procedure TMeasurementRun.ProcessSelectEtalon;
begin
  // Etalon selection is performed once in EnterSelectEtalon.
end;

procedure TMeasurementRun.ProcessSetupPoint;
begin
  // Point and measurement setup are performed once in EnterSetupPoint.
end;

procedure TMeasurementRun.ProcessWaitStable;
const
  DEFAULT_STABLE_TIMEOUT_S = 30;
  STABLE_PROTOCOL_INTERVAL_MS = 2000;
var
  Point: TDevicePoint;
  StableInfo: RStableInfo;
  CurrentTick: UInt64;
begin
  if FMode = mrmManual then
  begin
    SetStage(msWaitMeasureStart);
    Exit;
  end;

  Point := GetCurrentPoint;
  if Point = nil then
  begin
    FireEvent(
      meMeasureError,
      BuildError(1300, 'Нет текущей точки для стабилизации')
    );
    SetStage(msDone);
    Exit;
  end;

  if IsStable(StableInfo) then
  begin
    FireEvent(meStableReached);
    SetStage(msWaitMeasureStart);
    Exit;
  end;

  // Параметры ещё не стабилизированы.
  // Публиковать диагностическую информацию не чаще одного раза в 2 секунды.
  CurrentTick := TThread.GetTickCount64;

  if CurrentTick - FLastStableProtocolTick >=
     STABLE_PROTOCOL_INTERVAL_MS then
  begin
    FLastStableProtocolTick := CurrentTick;

    ProtocolManager.AddMessage(
      pcInfo,
      psMeasurement,
      'WaitStable',
      'Ожидание стабилизации параметров',
      StableInfo.StatusText
    );
  end;

  if ((CurrentTick - FWaitStartedTick) / 1000) >
     DEFAULT_STABLE_TIMEOUT_S then
  begin
    Inc(FAttempt);

    if FAttempt < FMaxAttemptCount then
    begin
      ProtocolManager.AddMessage(
        pcWarning,
        psMeasurement,
        'StableTimeout',
        'Таймаут установки параметров измерения',
        Format(
          'Попытка выхода на параметры: %d из %d',
          [FAttempt, FMaxAttemptCount]
        )
      );

      FireEvent(meStableRetry);
      SetStage(msSetupPoint);
      Exit;
    end;

    ProtocolManager.AddMessage(
      pcError,
      psMeasurement,
      'StableFailed',
      'Не удалось установить параметры измерения',
      StableInfo.StatusText
    );

    FireEvent(
      meStableTimeout,
      BuildError(1301, 'Стабилизация не достигнута')
    );

    if FMode = mrmAutomatic then
      ContinueAfterPointError(mptsSetupError, meStableTimeout, BuildError(1301, 'Стабилизация не достигнута'))
    else
      SetStage(msDone);
  end;
end;

procedure TMeasurementRun.ProcessWaitMeasureStart;
var timeout: extended;
const
  DEFAULT_START_TIMEOUT_S = 30;

begin
  if FWorkTable = nil then
  begin
    SetCurrentPointStatus(mptsMeasureError);
    FireEvent(meMeasureError, BuildError(1400, 'Рабочий стол не назначен'));
    SetStage(msDone);
    Exit;
  end;

  case FWorkTable.State of
    swtEXECUTE:
      begin
        FPhysicalMeasureStarted := True;
        AddDiagnosticEvent('WorkTable.State -> swtEXECUTE');
        SetStage(msMeasure);
        Exit;
      end;
    swtSTOPTEST,
    swtSTOPWAIT,
    swtCOMPLETE,
    swtFINALREAD:
      begin
        SetStage(msWaitMeasureStop);
        Exit;
      end;
    swtFAILURE:
      begin
        ContinueAfterPointError(mptsMeasureError, meMeasureError, BuildError(1402, 'Ошибка запуска измерения'));
        Exit;
      end;
  end;
   timeout := (TThread.GetTickCount64 - FWaitStartedTick)/1000;
  if timeout > DEFAULT_START_TIMEOUT_S then
  begin
    ContinueAfterPointError(mptsMeasureError, meMeasureTimeout, BuildError(1403, 'Таймаут ожидания запуска измерения'));
  end;
end;

function TMeasurementRun.GetCurrentStopTimeValue: Double;
begin
  Result := 0;

  if not Assigned(FWorkTable) then
    Exit;

  if Assigned(FWorkTable.ValueTime) then
    Result := FWorkTable.ValueTime.GetDoubleValue
  else
    Result := FWorkTable.Time;
end;

function TMeasurementRun.GetCurrentStopImpulseValue: Int64;
var
  I: Integer;
  Value: Double;
  MinValue: Double;
  HasValue: Boolean;
begin
  Result := 0;
  MinValue := 0;
  HasValue := False;

  if not Assigned(FWorkTable) then
    Exit;

  if not Assigned(FWorkTable.DeviceChannels) then
    Exit;

  for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
  begin
    if not Assigned(FWorkTable.DeviceChannels[I]) then
      Continue;

    if not FWorkTable.DeviceChannels[I].Enabled then
      Continue;

    Value := FWorkTable.DeviceChannels[I].ImpResult;

    if Value <= 0 then
      Continue;

    if (not HasValue) or (Value < MinValue) then
    begin
      MinValue := Value;
      HasValue := True;
    end;
  end;

  if HasValue then
    Result := Trunc(MinValue)
  else
    Result := 0;
end;

function TMeasurementRun.GetCurrentStopVolumeValue: Double;
begin
  Result := 0;

  if not Assigned(FWorkTable) then
    Exit;

  if Assigned(FWorkTable.ValueQuantity) then
    Result := FWorkTable.ValueQuantity.GetDoubleValue;
end;

function TMeasurementRun.IsCommandStopLimitReached(out AReason: string): Boolean;
var
  Point: TDevicePoint;
  CurrentTime: Double;
  CurrentImpulse: Int64;
  CurrentVolume: Double;

  NeedTime: Boolean;
  NeedImpulse: Boolean;
  NeedVolume: Boolean;

  TimeReached: Boolean;
  ImpulseReached: Boolean;
  VolumeReached: Boolean;

  HasAnyLimit: Boolean;
begin
  Result := False;
  AReason := '';

  if not Assigned(FWorkTable) then
    Exit;

  Point := FWorkTable.CurrentPoint;

  if not Assigned(Point) then
    Exit;

  NeedTime :=
    (scTime in Point.StopCriteria) and
    (Point.LimitTime > 0);

  NeedImpulse :=
    (scImpulse in Point.StopCriteria) and
    (Point.LimitImp > 0);

  NeedVolume :=
    (scVolume in Point.StopCriteria) and
    (Point.LimitVolume > 0);

  HasAnyLimit := NeedTime or NeedImpulse or NeedVolume;

  if not HasAnyLimit then
    Exit;

  CurrentTime := GetCurrentStopTimeValue;
  CurrentImpulse := GetCurrentStopImpulseValue;
  CurrentVolume := GetCurrentStopVolumeValue;

  TimeReached :=
    (not NeedTime) or
    (CurrentTime >= Point.LimitTime);

  ImpulseReached :=
    (not NeedImpulse) or
    (CurrentImpulse >= Point.LimitImp);

  VolumeReached :=
    (not NeedVolume) or
    (CurrentVolume >= Point.LimitVolume);

  Result := TimeReached and ImpulseReached and VolumeReached;

  if Result then
  begin
    AReason := 'Достигнуты все заданные лимиты остановки';

    if NeedTime then
      AReason := AReason + Format(
        '. Время: текущее %.3f с, лимит %.3f с',
        [CurrentTime, Point.LimitTime]);

    if NeedImpulse then
      AReason := AReason + Format(
        '. Импульсы: текущее %d, лимит %d',
        [CurrentImpulse, Point.LimitImp]);

    if NeedVolume then
      AReason := AReason + Format(
        '. Объём: текущее %.6f, лимит %.6f',
        [CurrentVolume, Point.LimitVolume]);
  end;
end;


function TMeasurementRun.BuildCommandStopLimitDetails(APoint: TDevicePoint; const AReason: string): string;
begin
  Result := AReason;

  if not Assigned(APoint) then
    Exit;

  Result := Format('%s; StopCriteria=%s; CurrentTime=%.3f; CurrentImpulse=%d; CurrentVolume=%.6f; '
    + 'LimitTime=%.3f; LimitImp=%d; LimitVolume=%.6f; StopControlMode=%s; NextStage=%s',
    [AReason,
     StopCriteriaToLogString(APoint.StopCriteria),
     GetCurrentStopTimeValue,
     GetCurrentStopImpulseValue,
     GetCurrentStopVolumeValue,
     APoint.LimitTime,
     APoint.LimitImp,
     APoint.LimitVolume,
     MeasurementStopControlModeToString(scmCommand),
     MeasurementStateToString(msWaitMeasureStop)]);
end;

procedure TMeasurementRun.ProcessMeasure;
var
  StopControlMode: TMeasurementStopControlMode;
  StopReason: string;
begin
  if FWorkTable = nil then
  begin
    SetCurrentPointStatus(mptsMeasureError);
    FireEvent(meMeasureError, BuildError(1400, 'Рабочий стол не назначен'));
    SetStage(msDone);
    Exit;
  end;

  case FWorkTable.State of
    swtEXECUTE:
      ; // Measurement is running normally.
    swtSTOPTEST,
    swtSTOPWAIT,
    swtCOMPLETE,
    swtFINALREAD:
      begin
        SetStage(msWaitMeasureStop);
        Exit;
      end;
    swtFAILURE:
      begin
        SetStopReason(msrError);
        FireEvent(meMeasureError, BuildError(1404, 'Ошибка во время измерения'));
        SetStage(msWaitMeasureStop);
        Exit;
      end;
  end;

  StopControlMode := GetMeasurementStopControlMode(FWorkTable.CurrentPoint);

  if StopControlMode = scmCommand then
  begin
    if IsCommandStopLimitReached(StopReason) then
    begin
      AddDiagnosticEvent('StopCriteria reached: ' + StopReason);
      ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessMeasure',
        'Достигнут программный лимит измерения',
        BuildCommandStopLimitDetails(FWorkTable.CurrentPoint, StopReason));
      SetStopReason(msrLimitReached);
      SetStage(msWaitMeasureStop);
      Exit;
    end;
  end;

  if Int64(TThread.GetTickCount64 - FWaitStartedTick) > Int64(FMeasureTimeout) * 1000 then
  begin
    SetStopReason(msrError);
    FireEvent(meMeasureTimeout, BuildError(1401, 'Таймаут измерения'));
    SetStage(msWaitMeasureStop);
  end;
end;

procedure TMeasurementRun.ProcessWaitMeasureStop;
const
  DEFAULT_STOP_TIMEOUT_MS = 30000;
begin
  if FWorkTable = nil then
  begin
    SetStage(msDone);
    Exit;
  end;

  case FWorkTable.State of
    swtCOMPLETE:
      begin
        FireActualStopOnce;
        if IsStopRequested and HasPhysicalMeasurementStarted then
        begin
          ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessWaitMeasureStop',
            'Остановка подтверждена, результат будет сохранён как прерванный',
            MeasurementStopReasonToString(GetStopReason));
          MarkInterruptedPointIfNeeded;
        end;
        SetStage(msSave);
        Exit;
      end;

    swtFINALREAD:
      begin
        FireActualStopOnce;
        if IsStopRequested then
          ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessWaitMeasureStop',
            'Начато чтение результата после Stop', MeasurementStopReasonToString(GetStopReason));
        SetStage(msResultsRead);
        Exit;
      end;

    swtFAILURE:
      begin
        ContinueAfterPointError(mptsMeasureError, meMeasureError, BuildError(1405, 'Ошибка остановки измерения'));
        Exit;
      end;
  end;

  if (TThread.GetTickCount64 - FWaitStartedTick) > DEFAULT_STOP_TIMEOUT_MS then
  begin
    ContinueAfterPointError(mptsMeasureError, meMeasureTimeout, BuildError(1406, 'Таймаут ожидания остановки измерения'));
  end;
end;

procedure TMeasurementRun.ProcessResultsRead;
const
  DEFAULT_STOP_TIMEOUT_MS = 3000;
begin

  if FWorkTable = nil then
  begin
    SetStage(msDone);
    Exit;
  end;

  case FWorkTable.State of
    swtCOMPLETE:
      begin
        FireEvent(meResultReady);
        if IsStopRequested then
        begin
          ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessResultsRead',
            'Результат прерванного измерения прочитан',
            MeasurementStopReasonToString(GetStopReason));
          MarkInterruptedPointIfNeeded;
        end;
        SetStage(msSave);
        Exit;
      end;

    swtFINALREAD:
      begin

      end;

    swtFAILURE:
      begin
        ContinueAfterPointError(mptsMeasureError, meMeasureError, BuildError(1410, 'Ошибка чтения результатов'));
        Exit;
      end;
  end;

  if (TThread.GetTickCount64 - FWaitStartedTick) > DEFAULT_STOP_TIMEOUT_MS then
  begin
    ContinueAfterPointError(mptsMeasureError, meMeasureTimeout, BuildError(1411, 'Таймаут чтения результатов'));
  end;
end;

procedure TMeasurementRun.ProcessSave;
begin
  if FNextStageAfterSave <> msNone then
    SetStage(FNextStageAfterSave);
end;

procedure TMeasurementRun.ProcessDone;
begin
  // Completion actions are performed once in EnterDone.
end;


procedure TMeasurementRun.SaveMeasurementResults;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
begin
  FLastSaveMeasurementResultsCalled := True;
  FLastSaveMeasurementResultsResult := 'started';
  FLastSaveErrorText := '';
  AddDiagnosticEvent('SaveMeasurementResults called');

  Point := GetCurrentPoint;
  if Point = nil then
  begin
    FLastSaveMeasurementResultsResult := 'failed: current point is nil';
    AddDiagnosticEvent('SaveMeasurementResults failed: current point is nil');
    Exit;
  end;

  try
    RepeatsTarget := Max(Point.Repeats, 1);

    if FWorkTable <> nil then
    begin
      FWorkTable.RecalculateAllMeterValues;
      if FWorkTable.ValueTime <> nil then
        FWorkTable.TimeResult := FWorkTable.ValueTime.GetDoubleValue
      else
        FWorkTable.TimeResult := Point.LimitTime;
    end;

    WorkTable.SaveMeasurementResults;

    if DataManager <> nil then
      DataManager.Save;

    if WorkTableManager <> nil then
      WorkTableManager.Save;

    Point.RepeatsCompleted := Min(RepeatsTarget, FCurrentRepeat + 1);
    Point.DateTime := Now;
    FLastSaveMeasurementResultsResult := 'success';
    AddDiagnosticEvent('SaveMeasurementResults success');
  except
    on E: Exception do
    begin
      FLastSaveMeasurementResultsResult := 'failed';
      FLastSaveErrorText := E.Message;
      AddDiagnosticEvent('SaveMeasurementResults failed: ' + E.Message);
      raise;
    end;
  end;
end;

{ Converts persisted string to spill state enum value. }
class function TMeasurementRun.MeasurementStateFromString(const AValue: string): EMeasurementState;
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

  if (S = 'ожидание запуска измерения') or (S = 'ожидание запуска') or
     (S = 'mswaitmeasurestart') then
    Exit(msWaitMeasureStart);

  if (S = 'измерение') or (S = 'msmeasure') then
    Exit(msMeasure);

  if (S = 'ожидание остановки измерения') or (S = 'ожидание остановки') or
     (S = 'mswaitmeasurestop') then
    Exit(msWaitMeasureStop);

  if (S = 'чтение результата') or (S = 'чтение результатов') or (S = 'msresultsread') then
    Exit(msResultsRead);

  if (S = 'сохранение') or (S = 'mssave') then
    Exit(msSave);

  if (S = 'завершено') or (S = 'окончание') or (S = 'msdone') then
    Exit(msDone);

  Result := msNone;
end;

{ Converts spill state enum value to persisted string. }
class function TMeasurementRun.MeasurementStateToString(AState: EMeasurementState): string;
begin
  case AState of
    msNone:             Result := '-';
    msSelectPoint:      Result := 'Выбор точки';
    msSelectEtalon:     Result := 'Выбор эталона';
    msSetupPoint:       Result := 'Установка точки';
    msWaitStable:       Result := 'Стабилизация';
    msWaitMeasureStart: Result := 'Ожидание запуска измерения';
    msMeasure:          Result := 'Измерение';
    msWaitMeasureStop:  Result := 'Ожидание остановки измерения';
    msResultsRead:      Result := 'Чтение результата';
    msSave:             Result := 'Сохранение';
    msDone:             Result := 'Завершено';
  else
    Result := '-';
  end;
end;

class function TMeasurementRun.MeasurementEventToString(AEvent: EMeasurementEvent): string;
begin
  case AEvent of
    meStarted:          Result := 'Запущено';
    meStopRequested:    Result := 'Запрошена остановка';
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

class function TMeasurementRun.MeasurementStopReasonToString(AReason: TMeasurementStopReason): string;
begin
  case AReason of
    msrNone: Result := 'остановка не запрошена';
    msrNormalComplete: Result := 'штатное завершение';
    msrUserStop: Result := 'остановка пользователем';
    msrLimitReached: Result := 'достигнут лимит';
    msrError: Result := 'ошибка';
    msrCancelledBeforeStart: Result := 'отмена до начала измерения';
    msrEmergency: Result := 'аварийное завершение';
    msrExternalCommand: Result := 'внешняя команда';
  else
    Result := 'неизвестная причина';
  end;
end;

end.
