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
  System.Generics.Defaults,
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
    msrExternalCommand,
    msrUserRollback
  );

  TMeasurementRunResult = (
    mrrNone,
    mrrSuccess,
    mrrCancelled,
    mrrError
  );

  TMeasurementRunDoneReason = (
    mdrNone,
    mdrEndOfPointList,
    mdrUserCancelled,
    mdrUserRollback,
    mdrError
  );

  /// <summary>
  /// Конечное или промежуточное состояние ожидания конкретного поверяемого
  /// канала. Результат хранится отдельно для каждого канала: приборы не обязаны
  /// достигать стабильности одновременно.
  /// </summary>
  TDeviceStabilityResult = (dsrNotStarted, dsrWaiting,
    dsrFixedTimeCompleted, dsrAutoStable, dsrAutoTimeout, dsrNoData, dsrError);

  /// <summary>
  /// Runtime-контекст стабилизации одного поверяемого канала. Ссылки на канал,
  /// его собственную точку и анализируемое значение фиксируются при входе в
  /// msWaitStable и больше не перенастраиваются в worker-цикле.
  /// </summary>
  TDeviceStabilityInfo = record
    Channel: TChannel;
    DevicePoint: TDevicePoint;
    Value: TMeterValue;
    Result: TDeviceStabilityResult;
    StartedAtMs: UInt64;
    CompletedAtMs: UInt64;
    RequiredTimeSec: Double;
    TimeoutSec: Double;
    DiagnosticText: string;
    // Ограничение частоты прогресса ведётся независимо для каждого канала.
    LastProgressLogTick: UInt64;
  end;


  TMeasurementRun = class(TMeasurementRunBase)

  const
      STABILITY_VARIATION_ERROR_FACTOR = 0.50;
      STABILITY_STDDEV_ERROR_FACTOR = 0.15;
      STABILITY_TREND_ERROR_FACTOR = 0.25;
      STABILITY_FORECAST_HORIZON_SEC = 5.0;
      DEFAULT_SAMPLE_INTERVAL_MS = 100.0;
      STABILITY_SAMPLE_SIZE_RESERVE_FACTOR = 1.25;
      HISTORY_RESERVE_SEC = 5.0;

  private


    FWorkTable: TWorkTable;
    FPoints: TObjectList<TDevicePoint>;

    FCurrentPointIndex: Integer;
    FThread: TThread;
    FCriticalSection: TCriticalSection;
    FMode: EMeasurementRunMode;
    FPointsPrepared: Boolean;
    FMergePoints: Boolean;
    FPreparedPointsMode: EMeasurementRunMode;

    FManualFlowRate: Double;
    FManualFluidTemp: Double;
    FManualFluidPress: Double;
    FManualTimeSet: Integer;

    FCurrentStage: EMeasurementState;
    // Решение о сохранении действует только для текущего входа в msSave.
    FSaveConfirmationResult: TSaveConfirmationResult;

    FWaitStartedTick: UInt64;
    FLastStableProtocolTick: UInt64;

    FLastConfiguredStabilityValue: TMeterValue;
    FLastPreviousSampleSize: Integer;
    FLastRequiredSampleSize: Integer;
    FLastSampleCountInBuffer: Integer;
    FLastEstimatedSampleIntervalMs: Double;
    FLastBufferExpanded: Boolean;


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
    FLastProcessedPointIndex: Integer;
    FLastProcessedPointName: string;
    FLastResultsAddedToProcessing: Integer;
    FLastResultsPerDevice: string;
    FLastRouteStopDiagnosticKey: string;
    FStableSinceMs: UInt64;
    FDevicesStableSinceMs: UInt64;
    FLastDeviceStableStateKnown: Boolean;
    FLastDeviceStableState: Boolean;
    FRequireAutoStabilization: Boolean;
    FRequiredDeviceStabilizationSec: Double;
    FLastStableProgressSecond: Int64;
    FStableTimerResetReason: string;
    FLastDeviceStabilityLogText: string;
    FLastDeviceStabilityLogTick: UInt64;
    FLastStabilityCheckSecond: Int64;
    FWaitStableStartedMs: Int64;
    FPointSetupCommandSent: Boolean;
    FSetupPointUUID: string;
    FSetupPointIndex: Integer;
    FSetupTargetFlowLS: Double;
    FSetupStartedMs: Int64;
    FStabilityDataStartMs: Int64;
    FLastWaitPointSetupLogMs: Int64;
    FLastFreshDataLogMs: Int64;
    FLastPointDecisionLogMs: Int64;
    FLastPointSetupReadyProtocolMs: Int64;
    FPressureNotControlledLogged: Boolean;
    FTemperatureNotControlledLogged: Boolean;
    FLastTemperatureReady: Boolean;
    FLastPressureReady: Boolean;
    FLastWaitPointSetupLogState: EStateWorkTable;
    FDeviceStability: TArray<TDeviceStabilityInfo>;
    // Счётчики описывают настройку этапа, включая каналы, не попавшие в массив ожидания.
    FStabilityDeviceChannelCount: Integer;
    FStabilityEnabledDeviceCount: Integer;
    FStabilityPointResolvedCount: Integer;
    FStabilitySkippedDeviceCount: Integer;
    FStabilityErrorDeviceCount: Integer;
    FRunCompleted: Boolean;
    FRunResult: TMeasurementRunResult;
    FDoneReason: TMeasurementRunDoneReason;
    FRequestStopCalled: Boolean;
    FFinalized: Boolean;

    procedure ResetRuntimeContext;
    procedure ResetPointSelectionContext;
    procedure FinalizeMeasurementRun(AResult: TMeasurementRunResult; AReason: TMeasurementRunDoneReason);
    function GetStage: EMeasurementState; override;
    procedure HandleCommand(Cmd: EMeasurementCommand; const Param: Variant);
    procedure RequestPointNavigation(const ADirection: string; ATargetIndex: Integer);
    procedure SelectForcedPoint;
    procedure SetStage(const ANewStage: EMeasurementState);
    function CanChangeStage(AOldStage, ANewStage: EMeasurementState): Boolean;
    procedure DoExitStage(AOldStage, ANewStage: EMeasurementState);
    procedure DoEnterStage(AOldStage, ANewStage: EMeasurementState);
    procedure EnterSelectPoint;
    procedure EnterSelectEtalon;
    procedure EnterSetupPoint;
    procedure EnterWaitPointSetup;
    procedure EnterWaitStable;
    procedure LoadRequiredStabilization(APoint: TDevicePoint);
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
    procedure SetPointStatus(APoint: TDevicePoint;
      const AStatus: EMeasurementPointStatus); overload;
    procedure SetPointStatus(APoint: TDevicePoint;
      const AStatus: EMeasurementPointStatus; const AReason: string;
      const ATargetIndex: Integer); overload;
    procedure MarkCurrentPointSkipped(const ADirection: string;
      const ATargetIndex: Integer);
    procedure MarkCurrentPointCancelled(const AReason: TMeasurementStopReason);
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
    class function MeasurementPointStatusToString(AStatus: EMeasurementPointStatus): string; static;
    procedure ProcessSelectPoint;
    procedure ProcessSelectEtalon;
    procedure ProcessSetupPoint;
    procedure ProcessWaitPointSetup;
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
    function FindPreviousEnabledPointIndex(AStartIndex: Integer): Integer;
    function BuildError(ACode: Integer; const AMsg: string): TErrorInfo;
    function ValidatePoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function SetPoint(Index: Integer; out AError: TErrorInfo): Boolean;
    function BuildPointSelectionLog(APoint: TDevicePoint): string;
    function BuildEtalonSelectionLog(APoint: TDevicePoint): string;
    function CalcMeasureTimeout(APoint: TDevicePoint): Cardinal;
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
    function GetRuntimeTargetFlowLS: Double;
    function GetSelectedEtalonUUID: string;
    function IsSetupPointSynchronized(out AReason: string): Boolean;
    function HasNewTableFlowDataSince(const ATimeStampMs: Int64; out AFirstSampleTimeMs,
      ALastSampleTimeMs: Int64; out ASampleCount: Integer): Boolean;
    function BuildPointSetupIdentityLog: string;
    function CalcStableTimeoutSec: Integer;
    procedure ResetPointSetupState;
    procedure StartNewStabilityAttempt;
    /// <summary>
    /// Настраивает три порога по Q/Error и при необходимости
    /// расширяет историю для минимального временного окна.
    /// </summary>
    procedure ConfigureStabilityByPoint(AValue: TMeterValue; APoint: TDevicePoint);
    /// <summary>
    /// Настраивает целевой диапазон по FlowAccuracy и независимо включает
    /// контроль мгновенного и среднего значений.
    /// </summary>
    procedure ConfigureTargetRangeByPoint(AValue: TMeterValue; APoint: TDevicePoint;
      const ACheckCurrent, ACheckAverage: Boolean);
    procedure LogPointSetupValueConfigured(const AName: string; AValue: TMeterValue);
    function BuildPointSetupSignalLog(const AName, ASource, AChannelDetails: string;
      AValue: TMeterValue; const AInfo: TMeterValueStabilityInfo;
      const ACurrentMs: Int64): string;
    /// <summary>Находит собственную поверочную точку заданного канала.</summary>
    function FindDevicePoint(AChannel: TChannel): TDevicePoint;
    /// <summary>
    /// Проверяет только готовность установки: суммарный расход стола
    /// и параметры среды. Поверяемые приборы здесь не участвуют.
    /// </summary>
    function IsPointSetupReady(out AInfo: RStableInfo): Boolean;

    procedure RunThreadProc;
    function IsThreadRunning: Boolean;

    function IsStable(out StableInfo: RStableInfo): Boolean;
    function IsEtalonStable(out StableInfo: RStableInfo): Boolean;
    function IsConditionsStable(out StableInfo: RStableInfo): Boolean;
    function IsDevicesStable(out StableInfo: RStableInfo): Boolean;
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
    procedure RebuildMeasurementPoints;
    function MovePointUp(AIndex: Integer): Boolean;
    function MovePointDown(AIndex: Integer): Boolean;
    procedure SortPointsByFlow(const ADescending: Boolean);
    procedure InvalidatePreparedPoints;
    function IsSessionPointFit(ADevice: TDevice; APoint: TDevicePoint): Boolean;


    procedure Start;
    procedure StartPreparedMeasurementRun;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    procedure NextPoint;
    procedure PreviousPoint;
    procedure Execute(Cmd: EMeasurementCommand); overload;
    procedure Execute(Cmd: EMeasurementCommand; Param: Variant); overload;

    procedure Process;
    procedure ProcessStage;
    procedure SaveMeasurementResults;
    /// <summary>Проверяет необходимость решения пользователя перед сохранением.</summary>
    function RequiresSaveConfirmation: Boolean;
    /// <summary>Фиксирует подтверждение пользователя без сохранения данных.</summary>
    procedure AcceptMeasurementResults;
    /// <summary>Фиксирует отказ пользователя без изменения этапа.</summary>
    procedure RejectMeasurementResults;
    function BuildDiagnosticSnapshot(const ASwitchAutoText: string): string;
    function DrainDiagnosticEvents: TArray<string>;

    class function MeasurementStateToString(AState: EMeasurementState): string; static;
    class function MeasurementStateFromString(const AValue: string): EMeasurementState; static;
    class function MeasurementEventToString(AEvent: EMeasurementEvent): string; static;
    class function MeasurementRunModeToString(AMode: EMeasurementRunMode): string; static;

    property WorkTable: TWorkTable read FWorkTable;
    property Points: TObjectList<TDevicePoint> read FPoints;
    property PointsPrepared: Boolean read FPointsPrepared;
    property MergePoints: Boolean read FMergePoints write FMergePoints;
    property IsPaused: Boolean read FIsPaused;
    property PreparedPointsMode: EMeasurementRunMode read FPreparedPointsMode;

    property StabilityDataStartMs: Int64 read FStabilityDataStartMs;
    property SaveConfirmationResult: TSaveConfirmationResult
      read FSaveConfirmationResult;

    property Mode: EMeasurementRunMode read FMode write FMode;
    property CurrentPointIndex: Integer read FCurrentPointIndex write FCurrentPointIndex;
    property CurrentPoint: TDevicePoint read GetCurrentPoint;
    property CurrentRepeat: Integer read FCurrentRepeat;
    property StopRequested: Boolean read FStopRequested;
    property PhysicalMeasurementStarted: Boolean read HasPhysicalMeasurementStarted;
    property NextStageAfterSave: EMeasurementState read FNextStageAfterSave;
    property ForceNextPoint: Integer read FForceNextPoint;
    property Attempt: Integer read FAttempt;
    property MaxAttemptCount: Integer read FMaxAttemptCount;
    property IsWorkerThreadRunning: Boolean read IsThreadRunning;
    property RunCompleted: Boolean read FRunCompleted;
    property RunResult: TMeasurementRunResult read FRunResult;
    property DoneReason: TMeasurementRunDoneReason read FDoneReason;
    property RequestStopCalled: Boolean read FRequestStopCalled;

    property ManualFlowRate: Double read FManualFlowRate write FManualFlowRate;
    property ManualFluidTemp: Double read FManualFluidTemp write FManualFluidTemp;
    property ManualFluidPress: Double read FManualFluidPress write FManualFluidPress;
    property ManualTimeSet: Integer read FManualTimeSet write FManualTimeSet;

  end;

//function GetMeasurementStopControlMode(APoint: TDevicePoint): TMeasurementStopControlMode;
function AccuracyToRange(const AAccuracy: string; out AMin, AMax: Double): Boolean;

implementation

function TMeasurementRun.GetStage: EMeasurementState;
begin
  Result := FCurrentStage;
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

procedure TMeasurementRun.ConfigureStabilityByPoint(AValue: TMeterValue;
  APoint: TDevicePoint);
var
  Settings: TMeterValueStabilitySettings;
  ErrorAbsolute: Double;
  Samples: TArray<TMeterValueSample>;
  DeltaMs, TotalDeltaMs: Int64;
  PositiveIntervalCount, I, RequiredSampleCount: Integer;
  AverageSampleIntervalMs: Double;
begin
  if (AValue = nil) or (APoint = nil) then
    Exit;

  Settings := AValue.StabilitySettings;
  ErrorAbsolute := Abs(APoint.Q) * Abs(APoint.Error) / 100.0;
  Settings.MaxVariation := ErrorAbsolute * STABILITY_VARIATION_ERROR_FACTOR;
  Settings.MaxStdDeviation := ErrorAbsolute * STABILITY_STDDEV_ERROR_FACTOR;
  Settings.MaxTrendRate := ErrorAbsolute * STABILITY_TREND_ERROR_FACTOR /
    STABILITY_FORECAST_HORIZON_SEC;

  Samples := AValue.GetStabilitySamples;
  TotalDeltaMs := 0;
  PositiveIntervalCount := 0;
  for I := 1 to High(Samples) do
  begin
    DeltaMs := Samples[I].TimeStampMs - Samples[I - 1].TimeStampMs;
    if DeltaMs > 0 then
    begin
      Inc(TotalDeltaMs, DeltaMs);
      Inc(PositiveIntervalCount);
    end;
  end;
  if PositiveIntervalCount > 0 then
    AverageSampleIntervalMs := TotalDeltaMs / PositiveIntervalCount
  else
    AverageSampleIntervalMs := DEFAULT_SAMPLE_INTERVAL_MS;

  RequiredSampleCount := Ceil(Settings.MinWindowDurationSec * 1000.0 /
    AverageSampleIntervalMs);
  RequiredSampleCount := Ceil(RequiredSampleCount *
    STABILITY_SAMPLE_SIZE_RESERVE_FACTOR);
  RequiredSampleCount := Max(RequiredSampleCount, Settings.MinSampleCount + 5);

  FLastConfiguredStabilityValue := AValue;
  FLastPreviousSampleSize := Settings.SampleSize;
  FLastRequiredSampleSize := RequiredSampleCount;
  FLastSampleCountInBuffer := Length(Samples);
  FLastEstimatedSampleIntervalMs := AverageSampleIntervalMs;
  FLastBufferExpanded := RequiredSampleCount > Settings.SampleSize;

  Settings.SampleSize := Max(Settings.SampleSize, RequiredSampleCount);
  Settings.MaxSampleAgeSec := Max(Settings.MaxSampleAgeSec,
  Settings.MinWindowDurationSec + HISTORY_RESERVE_SEC);

  Settings.Enabled:=True;
  AValue.StabilitySettings := Settings;

end;

procedure TMeasurementRun.ConfigureTargetRangeByPoint(AValue: TMeterValue;
  APoint: TDevicePoint; const ACheckCurrent, ACheckAverage: Boolean);
var
  Settings: TMeterValueStabilitySettings;
  MinPercent, MaxPercent: Double;
begin
  if (AValue = nil) or (APoint = nil) then
    Exit;

  Settings := AValue.StabilitySettings;
  Settings.TargetValue := APoint.Q;
  if AccuracyToRange(APoint.FlowAccuracy, MinPercent, MaxPercent) then
  begin
    Settings.TargetAccuracyMinusPercent := Abs(MinPercent);
    Settings.TargetAccuracyPlusPercent := Abs(MaxPercent);
  end
  else
  begin
    Settings.TargetAccuracyMinusPercent := 0.0;
    Settings.TargetAccuracyPlusPercent := 0.0;
  end;
  Settings.TargetToleranceAbsolute := 0.0;
  Settings.RequireCurrentValueInRange := ACheckCurrent;
  Settings.RequireMeanValueInRange := ACheckAverage;
  Settings.RequireForecastInRange := False;
  AValue.StabilitySettings := Settings;
end;

procedure TMeasurementRun.LogPointSetupValueConfigured(const AName: string;
  AValue: TMeterValue);
var
  S: TMeterValueStabilitySettings;
  LowerLimit, UpperLimit: Double;
  RangeText, BufferText: string;
begin
  if AValue = nil then
    Exit;
  S := AValue.StabilitySettings;
  if S.RequireCurrentValueInRange or S.RequireMeanValueInRange then
  begin
    CalculateTargetLimits(S.TargetValue, S.TargetAccuracyPlusPercent,
      S.TargetAccuracyMinusPercent, S.TargetToleranceAbsolute, LowerLimit, UpperLimit);
    RangeText := Format('; LowerLimit=%.6f; UpperLimit=%.6f', [LowerLimit, UpperLimit]);
  end
  else
    RangeText := '; RangeChecksEnabled=False';
  if FLastConfiguredStabilityValue = AValue then
    BufferText := Format('; PreviousSampleSize=%d; ConfiguredSampleSize=%d; SampleCountInBuffer=%d; EstimatedSampleIntervalMs=%.3f; EstimatedSampleRateHz=%.3f; RequiredSampleSize=%d; MinWindowDurationSec=%.3f; MaxSampleAgeSec=%.3f; BufferExpanded=%s',
      [FLastPreviousSampleSize, S.SampleSize, FLastSampleCountInBuffer,
       FLastEstimatedSampleIntervalMs, 1000.0 / FLastEstimatedSampleIntervalMs,
       FLastRequiredSampleSize, S.MinWindowDurationSec, S.MaxSampleAgeSec,
       BoolToStr(FLastBufferExpanded, True)])
  else
    BufferText := '';
  ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitPointSetup',
    'Применены настройки стабилизации',
    Format('PointSetupValueConfigured: Name=%s; Target=%.6f; MaxVariation=%.9f; MaxStdDeviation=%.9f; MaxTrendRate=%.9f; MinSampleCount=%d; MaxOutlierRatio=%.9f; CheckCurrentRange=%s; CheckMeanRange=%s%s%s',
      [AName, S.TargetValue, S.MaxVariation, S.MaxStdDeviation, S.MaxTrendRate,
       S.MinSampleCount, S.MaxOutlierFraction,
       BoolToStr(S.RequireCurrentValueInRange, True),
       BoolToStr(S.RequireMeanValueInRange, True), RangeText, BufferText]));
end;

function TMeasurementRun.BuildPointSetupSignalLog(const AName, ASource,
  AChannelDetails: string; AValue: TMeterValue;
  const AInfo: TMeterValueStabilityInfo; const ACurrentMs: Int64): string;
var
  S: TMeterValueStabilitySettings;
  TargetLowerLimit, TargetUpperLimit: Double;
begin
  S := AValue.StabilitySettings;
  CalculateTargetLimits(S.TargetValue, S.TargetAccuracyPlusPercent,
    S.TargetAccuracyMinusPercent, S.TargetToleranceAbsolute,
    TargetLowerLimit, TargetUpperLimit);
  Result := Format('PointSetupSignal: Name=%s; Source=%s; %sCurrent=%.6f; Mean=%.6f; Target=%.6f; TargetLowerLimit=%.6f; TargetUpperLimit=%.6f; SampleCount=%d; FirstSampleTimeMs=%d; LastSampleTimeMs=%d; WindowDurationSec=%.3f; RequiredWindowDurationSec=%.3f; Variation=%.9f; MaxVariation=%.9f; StdDeviation=%.9f; MaxStdDeviation=%.9f; TrendRate=%.9f; MaxTrendRate=%.9f; OutlierRatio=%.9f; MaxOutlierRatio=%.9f; IsSignalStable=%s; IsCurrentInRange=%s; IsMeanInRange=%s; IsSuitableForMeasurement=%s; Status=%d; Reason=%s; WaitMs=%d',
    [AName, ASource, AChannelDetails, AInfo.CurrentValue,
     AInfo.MeanValue, S.TargetValue, TargetLowerLimit,
     TargetUpperLimit, AInfo.UsedSampleCount,
     AInfo.FirstWindowSampleTimeMs, AInfo.LastWindowSampleTimeMs,
     AInfo.ActualWindowDurationSec, S.MinWindowDurationSec, AInfo.Variation,
     S.MaxVariation, AInfo.StdDeviation, S.MaxStdDeviation, AInfo.TrendRate,
     S.MaxTrendRate, AInfo.OutlierFraction, S.MaxOutlierFraction,
     BoolToStr(AInfo.IsSignalStable, True),
     BoolToStr(AInfo.IsCurrentValueInRange, True),
     BoolToStr(AInfo.IsMeanValueInRange, True),
     BoolToStr(AInfo.IsSuitableForMeasurement, True), Ord(AInfo.Status),
     AInfo.StatusText, ACurrentMs - FSetupStartedMs]);
end;

function GetAccuracyWidth(const AAccuracy: string): Double;
var
  MinVal, MaxVal: Double;
begin
  if not AccuracyToRange(AAccuracy, MinVal, MaxVal) then
    Exit(MaxDouble);
  Result := MaxVal - MinVal;
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
  if ASource.Pause < 0 then
    ATarget.RequireAutoStabilization := True
  else
    ATarget.RequiredStabilizationSec := Max(ATarget.RequiredStabilizationSec, ASource.Pause);
  if ATarget.RequireAutoStabilization then
    ATarget.Pause := -1
  else
    ATarget.Pause := Round(ATarget.RequiredStabilizationSec);
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
  FMergePoints := True;
  inherited Create;
  FWorkTable := AWorkTable;
  FPoints := TObjectList<TDevicePoint>.Create(True);
  FCriticalSection := TCriticalSection.Create;

  FCurrentPointIndex := -1;
  FMode := mrmManual;
  FPointsPrepared := False;
  FPreparedPointsMode := mrmManual;

  FManualFlowRate := 0;
  FManualFluidTemp := 20;
  FManualFluidPress := 1;
  FManualTimeSet := 60;

  FCurrentStage := msNone;
  // До первого этапа msSave решение о сохранении отсутствует.
  FSaveConfirmationResult := scrNone;
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
  FLastProcessedPointIndex := -1;
  FLastProcessedPointName := '';
  FLastResultsAddedToProcessing := 0;
  FLastResultsPerDevice := '';
  FLastRouteStopDiagnosticKey := '';
  FStableSinceMs := 0;
  FDevicesStableSinceMs := 0;
  FLastDeviceStableStateKnown := False;
  FLastDeviceStableState := False;
  FRequireAutoStabilization := False;
  FRequiredDeviceStabilizationSec := 0;
  FLastStableProgressSecond := -1;
  FStableTimerResetReason := '';
  FLastDeviceStabilityLogText := '';
  FLastDeviceStabilityLogTick := 0;
  FLastStabilityCheckSecond := -1;
  FWaitStableStartedMs := 0;
  FPointSetupCommandSent := False;
  FSetupPointUUID := '';
  FSetupPointIndex := -1;
  FSetupTargetFlowLS := 0;
  FSetupStartedMs := 0;
  FStabilityDataStartMs := 0;
  FLastWaitPointSetupLogMs := 0;
  FLastFreshDataLogMs := 0;
  FLastPointDecisionLogMs := 0;
  FLastPointSetupReadyProtocolMs := -1;
  FPressureNotControlledLogged := False;
  FTemperatureNotControlledLogged := False;
  FLastTemperatureReady := True;
  FLastPressureReady := True;
  FLastWaitPointSetupLogState := swtNONE;
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
      Result := ANewStage in [msWaitPointSetup, msWaitStable, msWaitMeasureStart, msSelectPoint, msDone, msNone];
    msWaitPointSetup:
      Result := ANewStage in [msWaitStable, msWaitMeasureStart, msSetupPoint, msSelectPoint, msDone, msNone];
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
      Result := ANewStage in [msWaitMeasureStart, msSelectPoint, msSetupPoint, msDone, msNone];
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

  FWaitStartedTick := TMeterValue.GetMonotonicTimeMs;

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
    'Переход этапа измерения, тайм аут: ' +inttostr(TMeterValue.GetMonotonicTimeMs - FWaitStartedTick)+'; ', TransitionText);
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
  FWaitStartedTick := TMeterValue.GetMonotonicTimeMs;
  if ANewStage in [msNone, msSelectPoint, msSetupPoint, msDone] then
  begin
    FDevicesStableSinceMs := 0;
    FLastDeviceStableStateKnown := False;
    FLastDeviceStableState := False;
  end;
  case ANewStage of
    msSelectPoint: EnterSelectPoint;
    msSelectEtalon: EnterSelectEtalon;
    msSetupPoint: EnterSetupPoint;
    msWaitPointSetup: EnterWaitPointSetup;
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
begin
  SetPointStatus(GetCurrentPoint, AStatus);
end;

procedure TMeasurementRun.SetPointStatus(APoint: TDevicePoint;
  const AStatus: EMeasurementPointStatus);
var
  Reason: string;
begin
  if AStatus in [mptsInvalidPoint, mptsSetupError, mptsMeasureError,
    mptsStabilityError, mptsDevicePointMismatch] then
    Reason := 'Error'
  else if AStatus in [mptsDone, mptsSaved] then
    Reason := 'NormalComplete'
  else
    Reason := 'StageChange';
  SetPointStatus(APoint, AStatus, Reason, -1);
end;

procedure TMeasurementRun.SetPointStatus(APoint: TDevicePoint;
  const AStatus: EMeasurementPointStatus; const AReason: string;
  const ATargetIndex: Integer);
var
  OldStatus: EMeasurementPointStatus;
  PointIndex: Integer;
begin
  if APoint = nil then
    Exit;
  OldStatus := APoint.Status;
  if OldStatus = AStatus then
    Exit;
  // A terminal result belongs to the point object and must survive later FSM
  // callbacks, refreshes, and row reordering.
  if OldStatus in [mptsSaved, mptsInvalidPoint, mptsSetupError,
      mptsMeasureError, mptsStabilityError, mptsDevicePointMismatch,
      mptsInterrupted, mptsCancelled, mptsSkipped] then
    Exit;
  APoint.Status := AStatus;
  PointIndex := -1;
  if FPoints <> nil then
    PointIndex := FPoints.IndexOf(APoint);
  AddDiagnosticEvent('PointStatus -> ' + GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(AStatus)));
  ProtocolManager.AddMessage(pcState, psMeasurement,
    'MeasurementPointStatusChanged', 'Изменён статус точки',
    Format('PointIndex=%d; PointUUID=%s; PointName=%s; OldStatus=%s; NewStatus=%s; Reason=%s; Stage=%s; TargetIndex=%d; StopReason=%s',
      [PointIndex, APoint.UUID, APoint.Name,
       MeasurementPointStatusToString(OldStatus),
       MeasurementPointStatusToString(AStatus), AReason,
       MeasurementStateToString(FCurrentStage), ATargetIndex,
       MeasurementStopReasonToString(GetStopReason)]));
  // Status updates refresh observers without impersonating a current-point change.
  Notify(Integer(meStateChanged), APoint);
end;

procedure TMeasurementRun.MarkCurrentPointSkipped(const ADirection: string;
  const ATargetIndex: Integer);
var
  Point: TDevicePoint;
begin
  Point := GetCurrentPoint;
  if (Point = nil) or (Point.Status in [mptsDone, mptsSaved, mptsInvalidPoint,
    mptsSetupError, mptsMeasureError, mptsStabilityError,
    mptsDevicePointMismatch, mptsInterrupted, mptsCancelled, mptsSkipped]) then
    Exit;
  SetPointStatus(Point, mptsSkipped, ADirection + 'Point', ATargetIndex);
end;

procedure TMeasurementRun.MarkCurrentPointCancelled(
  const AReason: TMeasurementStopReason);
var
  Point: TDevicePoint;
  ReasonText: string;
begin
  if FCurrentStage in [msNone, msDone] then
    Exit;
  Point := GetCurrentPoint;
  if (Point = nil) or (Point.Status in [mptsDone, mptsSaved, mptsInvalidPoint,
    mptsSetupError, mptsMeasureError, mptsStabilityError,
    mptsDevicePointMismatch, mptsInterrupted, mptsSkipped, mptsCancelled]) then
    Exit;
  if AReason = msrExternalCommand then
    ReasonText := 'Cancel'
  else
    ReasonText := 'UserStop';
  SetPointStatus(Point, mptsCancelled, ReasonText, -1);
  // DateTime is the model's persisted completion timestamp.  The grid's
  // "Time" column is LimitTime (planned time), so it must never be advanced
  // from Now during repaint; this one assignment freezes the actual finish.
  Point.DateTime := Now;
  ProtocolManager.AddMessage(pcState, psMeasurement,
    'MeasurementElapsedTimeFrozen', 'Зафиксировано время отмены точки',
    Format('PointIndex=%d; PointUUID=%s; FinishedAt=%s; Stage=%s',
      [FCurrentPointIndex, Point.UUID, DateTimeToStr(Point.DateTime),
       MeasurementStateToString(FCurrentStage)]));
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

function TMeasurementRun.FindPreviousEnabledPointIndex(AStartIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FPoints = nil then
    Exit;

  for I := Min(AStartIndex, FPoints.Count - 1) downto 0 do
    if (FPoints[I] <> nil) and FPoints[I].Enabled and
       (FPoints[I].State <> osDeleted) then
      Exit(I);
end;

procedure TMeasurementRun.EnterSelectPoint;
var
  // Содержит подробную информацию об ошибке, если SetPoint не сможет
  // выбрать, проверить или применить указанную точку измерения.
  Error: TErrorInfo;
  PreviousIndex: Integer;
  ForcedSelection: Boolean;
begin
  ResetPointSetupState;
  PreviousIndex := FCurrentPointIndex;
  ForcedSelection := FForceNextPoint >= 0;

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
    if ForcedSelection then
      ProtocolManager.AddMessage(pcAction, psMeasurement,
        'MeasurementPointNavigationApplied',
        'Запрошенная точка измерения назначена',
        Format('PreviousIndex=%d; NewIndex=%d; NewPointUUID=%s; Stage=%s; ForceNextPointAfter=%d',
          [PreviousIndex, FCurrentPointIndex, GetCurrentPoint.UUID,
           MeasurementStateToString(FCurrentStage), FForceNextPoint]));
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
    if FMode = mrmManual then
      SetStage(msSetupPoint)
    else
      SetStage(msSelectEtalon);
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
    begin
      SetStopReason(msrError);
      SetStage(msDone);
    end;
  end;
end;



procedure TMeasurementRun.EnterSelectEtalon;
var
  Error: TErrorInfo;
  OperationID: Int64;
  Snapshot: TWorkTableHydraulicSnapshot;
  Point: TDevicePoint;
begin
  SetCurrentPointStatus(mptsSelectEtalon);
  if IsStopRequested then Exit;
  Point := GetCurrentPoint;
  if (Point = nil) or (FWorkTable = nil) then
  begin
    ContinueAfterPointError(mptsSetupError, meEtalonAbsent,
      BuildError(1100, 'Нет точки или рабочего стола для выбора гидравлической конфигурации'));
    Exit;
  end;
  Snapshot := FWorkTable.GetHydraulicLineSnapshot;
  if FWorkTable.IsHydraulicLineActual(Point, FCurrentPointIndex) and
     (Snapshot.State in [hlsSelected, hlsSettingUp, hlsConfigured]) then
    Exit;
  FWorkTable.ResetHydraulicLine;
  if not FWorkTable.BeginHydraulicSelection(Point, FCurrentPointIndex,
    OperationID, Error) then
    ContinueAfterPointError(mptsSetupError, meEtalonAbsent, Error)
  else
    FWaitStartedTick := TMeterValue.GetMonotonicTimeMs;
end;

procedure TMeasurementRun.EnterSetupPoint;
var
  Point: TDevicePoint;
  Error: TErrorInfo;
begin
  Point := GetCurrentPoint;
  FPointSetupCommandSent := False;
  FSetupStartedMs := 0;
  if Point = nil then
  begin
    ContinueAfterPointError(mptsSetupError, mePointNotSet,
      BuildError(1200, 'Текущая точка измерения не назначена'));
    Exit;
  end;
  SetCurrentPointStatus(mptsSetupPoint);
  if FMode = mrmManual then
  begin
    if not SetupMeasurement(Point, Error) then
      ContinueAfterPointError(mptsSetupError, mePointNotSet, Error)
    else begin FireEvent(mePointSet); SetStage(msWaitMeasureStart); end;
  end;
end;

procedure TMeasurementRun.EnterWaitPointSetup;
var
  I: Integer;
  Channel: TChannel;
  Point: TDevicePoint;
  CurrentMs: Int64;
begin
  // Эти сообщения описывают текущую точку, поэтому для новой точки их можно
  // опубликовать снова, но не следует повторять при каждом опросе готовности.
  FPressureNotControlledLogged := False;
  FTemperatureNotControlledLogged := False;
  SetCurrentPointStatus(mptsSetupPoint);
  if FWorkTable = nil then
    Exit;

  Point := GetCurrentPoint;
  CurrentMs := TMeterValue.GetMonotonicTimeMs;
  { Stability history starts only after hlsConfigured is observed. }
  FStabilityDataStartMs := 0;

  if Point <> nil then
  begin
    ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitPointSetup',
      'Начато ожидание готовности испытательной установки',
      Format('PointSetupStarted: PointIndex=%d; PointName=%s; PointUUID=%s; TargetQ=%.6f; Error=%.6f; FlowAccuracy=%s; SetupStartedMs=%d; StabilityDataStartMs=%d; TimeoutSec=%d; WorkTableState=%s',
        [FCurrentPointIndex, Point.Name, Point.UUID, Point.Q, Point.Error,
         Point.FlowAccuracy, FSetupStartedMs, FStabilityDataStartMs,
         CalcStableTimeoutSec, TWorkTable.WorkTableStateToString(FWorkTable.State)]));
    FLastFreshDataLogMs := 0;
    FLastPointDecisionLogMs := 0;
    FLastPointSetupReadyProtocolMs := -1;
  end;

  if FWorkTable.State <> swtMONITOR then
    FWorkTable.StartMonitor;
end;


procedure TMeasurementRun.LoadRequiredStabilization(APoint: TDevicePoint);
begin
  FRequireAutoStabilization := False;
  FRequiredDeviceStabilizationSec := 0;
  if APoint = nil then
    Exit;

  // Runtime-поля session-точки рассчитываются при MergePointParams:
  // Auto хранится отдельно от максимального числового Pause.
  FRequireAutoStabilization := APoint.RequireAutoStabilization or (APoint.Pause < 0);
  FRequiredDeviceStabilizationSec := Max(0.0, APoint.RequiredStabilizationSec);
  if (not FRequireAutoStabilization) and (FRequiredDeviceStabilizationSec = 0) and (APoint.Pause > 0) then
    FRequiredDeviceStabilizationSec := APoint.Pause;
end;

procedure TMeasurementRun.EnterWaitStable;
var
  I, N: Integer;
  Channel: TChannel;
  Point, DevicePoint: TDevicePoint;
  Settings: TMeterValueStabilitySettings;
  LogText, ChannelName, ChannelUUID, DeviceName, DeviceUUID,
    DevicePointName, DevicePointUUID, MeasurementPointName,
    MeasurementPointUUID, ModeText, ResultText, Reason: string;
  ChannelEnabled, DeviceAssigned, PointFound, AddedToWaitList: Boolean;
  RequiredSec, TimeoutSec: Double;
  MeasurementTargetQ, DevicePointQ: Double;
  FixedTimeCount, AutoCount, DevicePointIndex, DevicePointID: Integer;
begin
  SetCurrentPointStatus(mptsWaitStable);

  // Начать новый период публикации состояния стабилизации.
  // Первое промежуточное сообщение появится не позднее чем через секунду.
  FLastStableProtocolTick := TMeterValue.GetMonotonicTimeMs;
  FStableSinceMs := 0;
  FDevicesStableSinceMs := 0;
  FLastDeviceStableStateKnown := False;
  FLastDeviceStableState := False;
  FStableTimerResetReason := '';
  FLastStableProgressSecond := -1;
  FLastStabilityCheckSecond := -1;
  FWaitStableStartedMs := TMeterValue.GetMonotonicTimeMs;
  FLastDeviceStabilityLogTick := 0;
  if FStabilityDataStartMs <= 0 then
    FStabilityDataStartMs := FWaitStableStartedMs;

  SetLength(FDeviceStability, 0);
  FStabilityDeviceChannelCount := 0;
  FStabilityEnabledDeviceCount := 0;
  FStabilityPointResolvedCount := 0;
  FStabilitySkippedDeviceCount := 0;
  FStabilityErrorDeviceCount := 0;
  FixedTimeCount := 0;
  AutoCount := 0;
  Point := GetCurrentPoint;
  MeasurementPointName := '';
  MeasurementPointUUID := '';
  MeasurementTargetQ := 0;
  if Point <> nil then
  begin
    MeasurementPointName := Point.Name;
    MeasurementPointUUID := Point.UUID;
    MeasurementTargetQ := Point.Q;
  end;
  if (FWorkTable <> nil) and (FWorkTable.DeviceChannels <> nil) then
    FStabilityDeviceChannelCount := FWorkTable.DeviceChannels.Count;
  ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitStable',
    'Начата настройка стабилизации поверяемых приборов',
    Format('DeviceStabilitySetupStarted: PointIndex=%d; MeasurementPointUUID=%s; MeasurementPointName=%s; TargetFlowLS=%.6f; DeviceChannelCount=%d; StartTimeMs=%d',
      [FCurrentPointIndex, MeasurementPointUUID, MeasurementPointName, MeasurementTargetQ,
       FStabilityDeviceChannelCount, FWaitStableStartedMs]));
  if (FWorkTable <> nil) and (FWorkTable.DeviceChannels <> nil) then
    for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
    begin
      Channel := FWorkTable.DeviceChannels[I];
      ChannelEnabled := (Channel <> nil) and Channel.Enabled and (Channel.State <> osDeleted);
      DeviceAssigned := (Channel <> nil) and (Channel.FlowMeter <> nil) and
        (Channel.FlowMeter.Device <> nil);
      PointFound := False;
      AddedToWaitList := False;
      RequiredSec := 0;
      TimeoutSec := 0;
      DevicePointQ := 0;
      DevicePointIndex := -1;
      DevicePointID := 0;
      ModeText := 'NotConfigured';
      ResultText := 'Skipped';
      Reason := '';
      ChannelName := ''; ChannelUUID := ''; DeviceName := ''; DeviceUUID := '';
      DevicePointName := ''; DevicePointUUID := '';
      DevicePoint := nil;
      if Channel <> nil then
      begin
        ChannelName := Channel.Name;
        ChannelUUID := Channel.UUID;
      end;
      if (Channel <> nil) and (Channel.FlowMeter <> nil) then
      begin
        DeviceName := Channel.FlowMeter.Name;
        if Channel.FlowMeter.Device <> nil then
          DeviceUUID := Channel.FlowMeter.Device.UUID;
      end;
      if not ChannelEnabled then
        Reason := 'ChannelDisabled'
      else
      begin
        Inc(FStabilityEnabledDeviceCount);
        if not DeviceAssigned then
          Reason := 'DeviceNotAssigned'
        else if Channel.FlowMeter.ValueFlow = nil then
        begin
          ResultText := 'Error';
          Reason := 'MeterValueNotAssigned';
          Inc(FStabilityErrorDeviceCount);
        end
        else
        begin
          DevicePoint := FindDevicePoint(Channel);
          PointFound := DevicePoint <> nil;
          if not PointFound then
          begin
            ResultText := 'Error';
            Reason := 'DevicePointNotFound';
            Inc(FStabilityErrorDeviceCount);
          end
          else
          begin
            Inc(FStabilityPointResolvedCount);
            DevicePointName := DevicePoint.Name;
            DevicePointUUID := DevicePoint.UUID;
            DevicePointID := DevicePoint.ID;
            DevicePointIndex := Channel.FlowMeter.Device.Points.IndexOf(DevicePoint);
            DevicePointQ := DevicePoint.Q;
            RequiredSec := DevicePoint.RequiredStabilizationSec;
            if DevicePoint.RequireAutoStabilization or (DevicePoint.Pause < 0) then
            begin
              ModeText := 'Automatic';
              TimeoutSec := CalcStableTimeoutSec;
            end
            else
            begin
              ModeText := 'FixedTime';
              if (RequiredSec = 0) and (DevicePoint.Pause > 0) then
                RequiredSec := DevicePoint.Pause;
            end;
            if (ModeText = 'FixedTime') and (RequiredSec <= 0) then
            begin
              if RequiredSec = 0 then Reason := 'RequiredTimeIsZero'
              else Reason := 'RequiredTimeIsNegative';
            end
            else
            begin
              AddedToWaitList := True;
              ResultText := 'Configured';
              Reason := 'WaitConfigured';
            end;
          end;
        end;
      end;
      if not AddedToWaitList then
      begin
        // Ошибочно настроенный включённый канал также пропущен (и отражается
        // одновременно в ErrorDeviceCount), поскольку в ожидание он не попал.
        if ChannelEnabled then Inc(FStabilitySkippedDeviceCount);
        LogText := Format('DeviceStabilitySetup: ChannelIndex=%d; ChannelName=%s; ChannelUUID=%s; ChannelEnabled=%s; DeviceAssigned=%s; DeviceName=%s; DeviceUUID=%s; DevicePointFound=%s; DevicePointIndex=%d; DevicePointID=%d; DevicePointUUID=%s; DevicePointName=%s; MeasurementPointName=%s; TargetFlowLS=%.6f; DevicePointQ=%.6f; StabilizationMode=%s; RequiredSec=%.3f; AutoStabilizationEnabled=%s; TimeoutSec=%.3f; AddedToWaitList=False; Result=%s; Reason=%s',
          [I, ChannelName, ChannelUUID, BoolToStr(ChannelEnabled, True),
           BoolToStr(DeviceAssigned, True), DeviceName, DeviceUUID,
           BoolToStr(PointFound, True), DevicePointIndex, DevicePointID,
           DevicePointUUID, DevicePointName, MeasurementPointName,
           MeasurementTargetQ, DevicePointQ,
           ModeText, RequiredSec, BoolToStr(ModeText = 'Automatic', True), TimeoutSec,
           ResultText, Reason]);
        if ResultText = 'Error' then
          ProtocolManager.AddMessage(pcError, psMeasurement, 'EnterWaitStable',
            'Ошибка настройки ожидания стабилизации канала', LogText)
        else
          ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitStable',
            'Канал не добавлен в ожидание стабилизации', LogText);
        Continue;
      end;
      N := Length(FDeviceStability);
      SetLength(FDeviceStability, N + 1);
      FDeviceStability[N] := Default(TDeviceStabilityInfo);
      FDeviceStability[N].Channel := Channel;
      FDeviceStability[N].Value := Channel.FlowMeter.ValueFlow;
      FDeviceStability[N].StartedAtMs := FWaitStableStartedMs;
      FDeviceStability[N].Result := dsrWaiting;
      FDeviceStability[N].DevicePoint := DevicePoint;
      ConfigureStabilityByPoint(FDeviceStability[N].Value, DevicePoint);
      ConfigureTargetRangeByPoint(FDeviceStability[N].Value, DevicePoint, False, False);

      // Окно анализа намеренно сохраняется. Данные, накопленные во время
      // подготовки установки, являются непрерывной историей того же сигнала и
      // позволяют сразу оценить прибор после перехода в msWaitStable. Сброс
      // здесь искусственно добавлял бы полное время заполнения окна к ожиданию.
      FDeviceStability[N].RequiredTimeSec := RequiredSec;
      FDeviceStability[N].TimeoutSec := TimeoutSec;
      if TimeoutSec > 0 then Inc(AutoCount) else Inc(FixedTimeCount);
      Settings := FDeviceStability[N].Value.StabilitySettings;
      LogText := Format('DeviceStabilityStarted: Channel=%s; Device=%s; Serial=%s; Point=%s; Mode=%s; TargetQ=%.6f; Error=%.6f; MaxVariation=%.9f; MaxStdDeviation=%.9f; MaxTrendRate=%.9f; RequiredSec=%.3f; TimeoutSec=%.3f; StartedMs=%d; StabilityAnalysisUsed=%s; RangeChecksEnabled=False',
        [Channel.Name, Channel.FlowMeter.Name, Channel.FlowMeter.SerialNumber,
         DevicePoint.Name,
         IfThen(FDeviceStability[N].TimeoutSec > 0, 'Auto', 'FixedTime'),
         DevicePoint.Q, DevicePoint.Error,
         Settings.MaxVariation, Settings.MaxStdDeviation, Settings.MaxTrendRate,
         FDeviceStability[N].RequiredTimeSec, FDeviceStability[N].TimeoutSec,
         FWaitStableStartedMs,
         BoolToStr(FDeviceStability[N].TimeoutSec > 0, True)]);
      AddDiagnosticEvent(LogText);
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitStable',
        'Настроено ожидание стабилизации поверяемого прибора', LogText);
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitStable',
        'Канал добавлен в ожидание стабилизации',
        Format('DeviceStabilitySetup: ChannelIndex=%d; ChannelName=%s; ChannelUUID=%s; ChannelEnabled=True; DeviceAssigned=True; DeviceName=%s; DeviceUUID=%s; DevicePointFound=True; DevicePointIndex=%d; DevicePointID=%d; DevicePointUUID=%s; DevicePointName=%s; MeasurementPointName=%s; TargetFlowLS=%.6f; DevicePointQ=%.6f; StabilizationMode=%s; RequiredSec=%.3f; AutoStabilizationEnabled=%s; TimeoutSec=%.3f; AddedToWaitList=True; Result=Configured; Reason=WaitConfigured',
          [I, ChannelName, ChannelUUID, DeviceName, DeviceUUID,
           Channel.FlowMeter.Device.Points.IndexOf(DevicePoint), DevicePoint.ID,
           DevicePointUUID, DevicePointName, MeasurementPointName,
           MeasurementTargetQ, DevicePoint.Q, ModeText, RequiredSec,
           BoolToStr(ModeText = 'Automatic', True), TimeoutSec]));
    end;

  ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitStable',
    'Завершена настройка стабилизации поверяемых приборов',
    Format('DeviceStabilitySetupCompleted: PointIndex=%d; MeasurementPointName=%s; DeviceChannelCount=%d; EnabledDeviceCount=%d; PointResolvedCount=%d; ConfiguredDeviceCount=%d; SkippedDeviceCount=%d; ErrorDeviceCount=%d; FixedTimeDeviceCount=%d; AutoStabilityDeviceCount=%d; SetupValid=%s; Reason=%s',
      [FCurrentPointIndex, MeasurementPointName,
       FStabilityDeviceChannelCount, FStabilityEnabledDeviceCount,
       FStabilityPointResolvedCount, Length(FDeviceStability),
       FStabilitySkippedDeviceCount, FStabilityErrorDeviceCount,
       FixedTimeCount, AutoCount,
       BoolToStr((FStabilityEnabledDeviceCount = Length(FDeviceStability)), True),
       IfThen((FStabilityEnabledDeviceCount > 0) and (Length(FDeviceStability) = 0),
         'NoEnabledDeviceAddedToWaitList', IfThen(FStabilityErrorDeviceCount > 0,
         'DeviceConfigurationErrors', 'SetupCompleted'))]));

  LoadRequiredStabilization(GetCurrentPoint);
  AddDiagnosticEvent(Format('RequiredStabilizationSec=%.3f; RequireAutoStabilization=%s; RequiredStabilizationSource=TDevicePoint runtime', [FRequiredDeviceStabilizationSec, BoolToStr(FRequireAutoStabilization, True)]));

  if IsStopRequested then
    Exit;

  if FMode = mrmManual then
  begin
    SetStage(msWaitMeasureStart);
    Exit;
  end;
end;

procedure TMeasurementRun.EnterWaitMeasureStart;
var
  Point: TDevicePoint;
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

  Point := GetCurrentPoint;
  SetCurrentPointStatus(mptsWaitMeasureStart);
  FMeasureTimeout := CalcMeasureTimeout(Point);

  if FWorkTable = nil then
  begin
    SetCurrentPointStatus(mptsMeasureError);
    FireEvent(meMeasureError, BuildError(1400, 'Рабочий стол не назначен'));
    SetStage(msDone);
    Exit;
  end;

  FLastMeasureCompletedEventSent := False;
  FLastSaveDoneEventSent := False;
  FPhysicalMeasureStarted := False;
  FPhysicalStopRequested := False;

  if (FMode <> mrmManual) and (FCurrentRepeat > 0) then
  begin
    ProtocolManager.AddMessage(pcAction, psMeasurement, 'StartTestRepeat',
      'Отдана команда запуска повторного измерения без повторной стабилизации',
      Format('PointIndex=%d; CurrentRepeat=%d', [FCurrentPointIndex, FCurrentRepeat]));
    AddDiagnosticEvent(Format('RepeatMeasurementStart: Point=%s; CurrentRepeat=%d; StabilizationSkipped=True',
      [IfThen(Point <> nil, Point.Name, '<none>'), FCurrentRepeat]));
    FWorkTable.StartTestRepeat;
  end
  else
  begin
    ProtocolManager.AddMessage(pcProc, psMeasurement, 'EnterWaitMeasureStart',
      'Отдана команда запуска измерения', MeasurementStateToString(FCurrentStage));
    AddDiagnosticEvent('StartTest called');
    FWorkTable.StartTest;
  end;
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
begin
  FNextStageAfterSave := msDone;
  SetCurrentPointStatus(mptsSave);

  // Каждое новое измерение начинает этап сохранения без решения пользователя.
  FSaveConfirmationResult := scrNone;
  ProtocolManager.AddMessage(pcInfo, psMeasurement, 'EnterSave',
    'Вход в этап сохранения: решение пользователя сброшено',
    MeasurementStateToString(FCurrentStage));

  FLastMeasureCompletedEventSent := True;
  FireEvent(meMeasureCompleted);
end;

procedure TMeasurementRun.EnterDone;
begin
  if FFinalized then
    Exit;

  if FStopRequested or (FStopReason in [msrUserStop, msrCancelledBeforeStart]) then
    FinalizeMeasurementRun(mrrCancelled, mdrUserCancelled)
  else if FStopReason in [msrError, msrEmergency] then
    FinalizeMeasurementRun(mrrError, mdrError)
  else
    FinalizeMeasurementRun(mrrSuccess, mdrEndOfPointList);
end;

procedure TMeasurementRun.ResetRuntimeContext;
begin
  FCurrentPointIndex := -1;
  FCurrentRepeat := 0;
  FForceNextPoint := -1;
  FAttempt := 0;
  FMeasureTimeout := 0;
  FPhysicalMeasureStarted := False;
  FPhysicalStopRequested := False;
  FActualStopEventFired := False;
  FNextStageAfterSave := msNone;
  FWaitStartedTick := 0;
  FLastPointSetupReadyProtocolMs := -1;
  FStableSinceMs := 0;
  FDevicesStableSinceMs := 0;
  FLastDeviceStableStateKnown := False;
  FLastDeviceStableState := False;
  FRequireAutoStabilization := False;
  FRequiredDeviceStabilizationSec := 0;
  FLastStableProgressSecond := -1;
  FStableTimerResetReason := '';
  ResetPointSetupState;
  if FWorkTable <> nil then
  begin
   // FWorkTable.ResetCurrentPoint;
    if (FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.ValueSet <> nil) then
      FWorkTable.FlowRate.ValueSet.Value := 0;
    FWorkTable.TimeResult := 0;
  end;
end;

procedure TMeasurementRun.ResetPointSelectionContext;
var
  Point: TDevicePoint;
begin
  FCurrentPointIndex := -1;
  FCurrentRepeat := 0;
  FForceNextPoint := -1;
  FNextStageAfterSave := msNone;
  for Point in FPoints do
    if Point <> nil then
    begin
      Point.Status := mptsNone;
      Point.RepeatsCompleted := 0;
    end;
end;

procedure TMeasurementRun.FinalizeMeasurementRun(AResult: TMeasurementRunResult;
  AReason: TMeasurementRunDoneReason);
var
  PreviousStage: EMeasurementState;
  PreviousWorkTableState: EStateWorkTable;
  CurrentPointIndexBefore: Integer;
  NextStageAfterSaveBefore: EMeasurementState;
  DisplayedStatusText: string;
  FinalWorkTableStateText: string;
begin
  if FFinalized then
    Exit;

  PreviousStage := FCurrentStage;
  if FWorkTable <> nil then
    PreviousWorkTableState := FWorkTable.State
  else
    PreviousWorkTableState := swtNONE;
  CurrentPointIndexBefore := FCurrentPointIndex;
  NextStageAfterSaveBefore := FNextStageAfterSave;

  FFinalized := True;

  if (GetCurrentPoint <> nil) and (GetCurrentPoint.Status = mptsResultsRead) then
    SetCurrentPointStatus(mptsDone);

  FRunCompleted := True;
  FRunResult := AResult;
  FDoneReason := AReason;
  FCurrentStage := msDone;
  if AResult = mrrSuccess then
  begin
    FStopRequested := False;
    FStopReason := msrNone;
  end
  else if AResult = mrrCancelled then
  begin
    FStopReason := msrUserStop;
    if GetCurrentPoint <> nil then
      SetCurrentPointStatus(mptsCancelled);
  end;

  ResetRuntimeContext;
  if FWorkTable <> nil then
    FWorkTable.State := swtNONE;

  case FRunResult of
    mrrCancelled: DisplayedStatusText := 'Отменено';
    mrrError: DisplayedStatusText := 'Ошибка';
  else
    if FRunCompleted and (FRunResult = mrrSuccess) then
      DisplayedStatusText := 'Завершено'
    else if FStopRequested then
      DisplayedStatusText := 'Остановка'
    else
      DisplayedStatusText := MeasurementStateToString(FCurrentStage);
  end;

  if FWorkTable <> nil then
    FinalWorkTableStateText := TWorkTable.WorkTableStateToString(FWorkTable.State)
  else
    FinalWorkTableStateText := TWorkTable.WorkTableStateToString(swtNONE);

  AddDiagnosticEvent(Format('FinalizeMeasurementRun: PreviousStage=%s; FinalStage=%s; PreviousWorkTableState=%s; FinalWorkTableState=%s; RunCompleted=%s; RunResult=%s; DoneReason=%s; StopRequested=%s; CurrentPointIndexBefore=%d; CurrentPointIndexAfter=%d; NextStageAfterSaveBefore=%s; NextStageAfterSaveAfter=%s; DisplayedStatusText=%s',
    [MeasurementStateToString(PreviousStage), MeasurementStateToString(FCurrentStage),
     TWorkTable.WorkTableStateToString(PreviousWorkTableState), FinalWorkTableStateText,
     BoolToStr(FRunCompleted, True), GetEnumName(TypeInfo(TMeasurementRunResult), Ord(FRunResult)),
     GetEnumName(TypeInfo(TMeasurementRunDoneReason), Ord(FDoneReason)), BoolToStr(FStopRequested, True),
     CurrentPointIndexBefore, FCurrentPointIndex, MeasurementStateToString(NextStageAfterSaveBefore),
     MeasurementStateToString(FNextStageAfterSave), DisplayedStatusText]));

  if AResult = mrrSuccess then
  begin
    AddDiagnosticEvent('meAllDone');
    FireEvent(meAllDone);
  end;

  Notify(Integer(meStateChanged), nil);
  if AResult = mrrCancelled then
    ProtocolManager.AddMessage(pcState, psMeasurement,
      'MeasurementStopCompleted', 'Остановка измерительного запуска завершена',
      Format('PreviousStage=%s; FinalStage=%s; PointIndex=%d',
        [MeasurementStateToString(PreviousStage),
         MeasurementStateToString(FCurrentStage), CurrentPointIndexBefore]));
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
      // In manual mode, use the current work-table task point.
      // TMeasurementRun does not replace it with a point from FPoints.
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

/// <summary>
/// Возвращает собственную точку поверяемого прибора, соответствующую расходу
/// общей session-точки. Удалённые и выключенные точки не рассматриваются.
/// Из нескольких допустимых кандидатов выбирается ближайший по Q.
/// </summary>
function TMeasurementRun.FindDevicePoint(AChannel: TChannel): TDevicePoint;
var
  I: Integer;
  Candidate, Point: TDevicePoint;
  Device: TDevice;
  BestDistance, Distance: Double;
begin
  Result := nil;
  if (AChannel = nil) or (not AChannel.Enabled) or
     (AChannel.State = osDeleted) or (AChannel.FlowMeter = nil) or
     (AChannel.FlowMeter.Device = nil) then
    Exit;

  Device := AChannel.FlowMeter.Device;
  if (Device.Points = nil) or (FWorkTable = nil) then
    Exit;

  Point := FWorkTable.CurrentPoint;
  if Point = nil then
    Exit;

  BestDistance := MaxDouble;
  for I := 0 to Device.Points.Count - 1 do
  begin
    Candidate := Device.Points[I];
    if (Candidate = nil) or not Candidate.Enabled or (Candidate.State = osDeleted) then
      Continue;

    // Сопоставляем по диапазону FlowAccuracy именно общей точки измерения.
    if not Device.IsFlowInPoint(Candidate.Q, Point) then
      Continue;

    Distance := Abs(Candidate.Q - Point.Q);
    if Distance < BestDistance then
    begin
      Result := Candidate;
      BestDistance := Distance;
    end;
  end;
end;

/// <summary>
/// Формирует единое решение о готовности испытательной установки.
/// </summary>
/// <remarks>
/// Суммарный расход стола проверяется по IsSuitableForMeasurement:
/// обязательны стабильность, текущее и среднее значения в целевом диапазоне.
/// Эталонные и поверяемые каналы функция не читает.
/// </remarks>
function TMeasurementRun.IsPointSetupReady(out AInfo: RStableInfo): Boolean;
var
  Value: TMeterValue;
  SignalInfo: TMeterValueStabilityInfo;
  ConditionsInfo: RStableInfo;
  TableFlowAvailable, TableFlowReady: Boolean;
  TemperatureReady, PressureReady, ConditionsReady: Boolean;
  Reason, FlowLogText, LogText: string;
  PublishProtocol: Boolean;
  CurrentMs: Int64;
begin
  AInfo := Default(RStableInfo);
  CurrentMs := TMeterValue.GetMonotonicTimeMs;
  if (FWorkTable = nil) or (GetCurrentPoint = nil) then
    Exit(False);

  TableFlowAvailable := (FWorkTable.FlowRate <> nil) and
    (FWorkTable.FlowRate.Value <> nil);
  TableFlowReady := False;
  SignalInfo := Default(TMeterValueStabilityInfo);
  if TableFlowAvailable then
  begin
    Value := FWorkTable.FlowRate.Value;
    Value.AnalyzeStabilityForMeasurement(FStabilityDataStartMs,
      Value.StabilitySettings, SignalInfo);
    TableFlowReady := SignalInfo.IsSuitableForMeasurement;
    FlowLogText := BuildPointSetupSignalLog('TableFlow',
      'WorkTable.FlowRate.Value', '', Value, SignalInfo, CurrentMs);
    AddDiagnosticEvent(FlowLogText);
  end;
  if not TableFlowAvailable then
    FlowLogText := 'PointSetupSignal: Name=TableFlow; Available=False; ' +
      'Reason=WorkTable.FlowRate.Value is not assigned';

  ConditionsInfo := Default(RStableInfo);
  ConditionsReady := IsConditionsStable(ConditionsInfo);
  TemperatureReady := FLastTemperatureReady;
  PressureReady := FLastPressureReady;
  Result := TableFlowReady and ConditionsReady;

  if Result then
    Reason := 'Все обязательные проверки установки выполнены'
  else if not TableFlowAvailable then
    Reason := 'Значение расхода стола не назначено'
  else if not TableFlowReady then
    Reason := 'Расход стола не готов: ' + SignalInfo.StatusText
  else
    Reason := ConditionsInfo.StatusText;

  LogText := Format('PointSetupDecision: PointIndex=%d; PointName=%s; WaitMs=%d; TimeoutMs=%d; FreshDataReady=True; TableFlowAvailable=%s; TableFlowReady=%s; TemperatureReady=%s; PressureReady=%s; ConditionsReady=%s; Result=%s; Reason=%s',
    [FCurrentPointIndex, GetCurrentPoint.Name, CurrentMs - FSetupStartedMs,
     CalcStableTimeoutSec * 1000, BoolToStr(TableFlowAvailable, True),
     BoolToStr(TableFlowReady, True), BoolToStr(TemperatureReady, True),
     BoolToStr(PressureReady, True), BoolToStr(ConditionsReady, True),
     BoolToStr(Result, True), Reason]);
  PublishProtocol := (FLastPointSetupReadyProtocolMs < 0) or
    (CurrentMs - FLastPointSetupReadyProtocolMs >= 2000);
  if PublishProtocol then
  begin
    ProtocolManager.AddMessage(pcProc, psMeasurement, 'IsPointSetupReady',
      'Диагностика расхода стола', FlowLogText);
    ProtocolManager.AddMessage(pcProc, psMeasurement, 'IsPointSetupReady',
      'Итоговое решение о готовности установки', LogText);
    FLastPointSetupReadyProtocolMs := CurrentMs;
  end;

if Result then
begin
  AInfo.Status := sOk;
  AInfo.StatusText := 'Испытательная установка готова';
end
else if not TableFlowAvailable then
begin
  AInfo.Status := sFail_NN;
  AInfo.StatusText := 'Значение расхода стола не назначено';
end
else if not TableFlowReady then
begin
  AInfo.Status := sRun_NN;
  AInfo.StatusText := 'Расход стола не готов: ' + SignalInfo.StatusText;
end
else
  AInfo := ConditionsInfo;
end;


function TMeasurementRun.IsStable(out StableInfo: RStableInfo): Boolean;
var
  EtalonInfo, ConditionsInfo, DevicesInfo: RStableInfo;
  EtalonStable, ConditionsStable, DevicesStable: Boolean;
  DiagnosticText: string;
  DiagnosticSecond: Int64;
begin
  StableInfo := Default(RStableInfo);
  EtalonStable := IsEtalonStable(EtalonInfo);
  ConditionsStable := IsConditionsStable(ConditionsInfo);
  DevicesStable := IsDevicesStable(DevicesInfo);
  Result := EtalonStable and ConditionsStable and DevicesStable;

  if not EtalonStable then
    StableInfo := EtalonInfo
  else if not ConditionsStable then
    StableInfo := ConditionsInfo
  else if not DevicesStable then
    StableInfo := DevicesInfo
  else
    StableInfo.Status := sOk;


    { TODO -oAndrey -cВажно, не срочно :
При неуспехе раз в 2 секунды пишет диагностику WaitEtalonStable;
после 30 секунд выполняет повтор настройки точки до FMaxAttemptCount, затем фиксирует
ошибку стабилизации
сделать настройку для общего времени стабилизации }


  DiagnosticSecond := Trunc((TMeterValue.GetMonotonicTimeMs - FWaitStartedTick) / 1000);
  DiagnosticText := Format('IsStable=%s; EtalonStable=%s; ConditionsStable=%s; DevicesStable=%s; ReadyToMeasure=%s; Reason=%s',
    [BoolToStr(Result, True), BoolToStr(EtalonStable, True), BoolToStr(ConditionsStable, True),
     BoolToStr(DevicesStable, True), BoolToStr(Result, True), StableInfo.StatusText]);
  if (DiagnosticText <> FLastDiagnosticIsStableText) or
     (DiagnosticSecond <> FLastDiagnosticIsStableSecond) then
  begin
    FLastDiagnosticIsStableText := DiagnosticText;
    FLastDiagnosticIsStableSecond := DiagnosticSecond;
    AddDiagnosticEvent(DiagnosticText);
  end;
end;

function TMeasurementRun.IsEtalonStable(out StableInfo: RStableInfo): Boolean;
begin
  Result := CheckFlowStable(StableInfo);
  AddDiagnosticEvent('EtalonStable=' + BoolToStr(Result, True) + '; Reason=' + StableInfo.StatusText);
end;

function TMeasurementRun.IsConditionsStable(out StableInfo: RStableInfo): Boolean;
var
  Point: TDevicePoint;
  ParamInfo: RStableInfo;
  TemperatureStable, PressureStable: Boolean;
  LogText: string;
  PublishProtocol: Boolean;
begin
  StableInfo := Default(RStableInfo);
  Point := GetCurrentPoint;
  if (FWorkTable = nil) or (Point = nil) then
    Exit(False);

  TemperatureStable := True;
  PublishProtocol := TMeterValue.GetMonotonicTimeMs - FLastPointDecisionLogMs >= 2000;
  if (FWorkTable.FluidTemp <> nil) and (Point.Temp > 0) then
  begin
    TemperatureStable := FWorkTable.FluidTemp.IsStable(ParamInfo);
    LogText := Format('PointSetupCondition: Name=FluidTemp; Enabled=True; Current=%.6f; Mean=%.6f; Target=%.6f; LowerLimit=%.6f; UpperLimit=%.6f; IsSignalStable=%s; IsCurrentInRange=%s; IsMeanInRange=%s; IsSuitableForMeasurement=%s; Reason=%s',
      [ParamInfo.CurrentValue, ParamInfo.MeanValue, ParamInfo.TargetValue,
       ParamInfo.LowerLimit, ParamInfo.UpperLimit,
       BoolToStr(ParamInfo.IsSignalStable, True), BoolToStr(ParamInfo.IsCurrentInRange, True),
       BoolToStr(ParamInfo.IsMeanInRange, True), BoolToStr(TemperatureStable, True), ParamInfo.StatusText]);
    AddDiagnosticEvent(LogText);
    if PublishProtocol then ProtocolManager.AddMessage(pcProc, psMeasurement,
      'IsConditionsStable', 'Диагностика температуры', LogText);
    if not TemperatureStable then
      StableInfo := ParamInfo;
  end
  else begin
    LogText := 'PointSetupCondition: Name=FluidTemp; Enabled=False; Skipped=True; Reason=Parameter is not configured';
    AddDiagnosticEvent(LogText);
    if not FTemperatureNotControlledLogged then
    begin
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'IsPointSetupReady',
        'Температура не контролируется',
        'Контроль температуры для текущей точки отключён');
      FTemperatureNotControlledLogged := True;
    end;
  end;
  if (FWorkTable.FluidTemp <> nil) and (Point.Temp > 0) then
    FTemperatureNotControlledLogged := False;
  FLastTemperatureReady := TemperatureStable;

  PressureStable := True;
  if (FWorkTable.FluidPress <> nil) and (Point.Pressure > 0) then
  begin
    PressureStable := FWorkTable.FluidPress.IsStable(ParamInfo);
    LogText := Format('PointSetupCondition: Name=FluidPress; Enabled=True; Current=%.6f; Mean=%.6f; Target=%.6f; LowerLimit=%.6f; UpperLimit=%.6f; IsSignalStable=%s; IsCurrentInRange=%s; IsMeanInRange=%s; IsSuitableForMeasurement=%s; Reason=%s',
      [ParamInfo.CurrentValue, ParamInfo.MeanValue, ParamInfo.TargetValue,
       ParamInfo.LowerLimit, ParamInfo.UpperLimit,
       BoolToStr(ParamInfo.IsSignalStable, True), BoolToStr(ParamInfo.IsCurrentInRange, True),
       BoolToStr(ParamInfo.IsMeanInRange, True), BoolToStr(PressureStable, True), ParamInfo.StatusText]);
    AddDiagnosticEvent(LogText);
    if PublishProtocol then ProtocolManager.AddMessage(pcProc, psMeasurement,
      'IsConditionsStable', 'Диагностика давления', LogText);
    if PressureStable = False then
      StableInfo := ParamInfo;
  end
  else begin
    LogText := 'PointSetupCondition: Name=FluidPress; Enabled=False; Skipped=True; Reason=Parameter is not configured';
    AddDiagnosticEvent(LogText);
    if not FPressureNotControlledLogged then
    begin
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'IsPointSetupReady',
        'Давление не контролируется',
        'Контроль давления для текущей точки отключён');
      FPressureNotControlledLogged := True;
    end;
  end;
  if (FWorkTable.FluidPress <> nil) and (Point.Pressure > 0) then
    FPressureNotControlledLogged := False;
  FLastPressureReady := PressureStable;

  if PublishProtocol then
    FLastPointDecisionLogMs := TMeterValue.GetMonotonicTimeMs;

  Result := TemperatureStable and PressureStable;
  if Result then
  begin
    StableInfo.Status := sOk;
    StableInfo.StatusText := 'ConditionsStable=True';
  end;
  AddDiagnosticEvent('ConditionsStable=' + BoolToStr(Result, True));
end;

function TMeasurementRun.IsDevicesStable(out StableInfo: RStableInfo): Boolean;
var
  I, J: Integer;
  Channel: TChannel;
  ValueFlow: TMeterValue;
  Settings: TMeterValueStabilitySettings;
  SignalInfo: TMeterValueStabilityInfo;
  CheckedCount, ReadySecCount, TotalSecCount, ReadyAutoCount, TotalAutoCount: Integer;
  ActualValue: Double;
  EtalonTargetValue: Double;
  DeviceQmaxLS: Double;
  DeviceTargetValue: Double;
  TargetValue: Double;
  TargetSource: string;
  PointMatchSource: string;
  CurrentPoint: TDevicePoint;
  DevicePoint: TDevicePoint;
  BestPoint: TDevicePoint;
  BestDistance, Distance: Double;
  ErrorPercent, AllowedDeviation: Double;
  StableReady, RangeReady, Ready, RequireRange: Boolean;
  CurrentInRange, MeanInRange, ForecastInRange: Boolean;
  Reason, LogText, CurrentPointName, DeviceUUID, DevicePointUUID, MatchedPointName, ModeText: string;
  FirstNotReadyStatusText: string;
  CurrentPointQ, CurrentPointFlowRate, MatchedPointQ, MatchedDistance: Double;
  FlowRateDistance, BestFlowRateDistance: Double;
  CurrentTick: UInt64;
  Participant: TMeasurementPointParticipant;
  ParticipantFound: Boolean;
  TargetDifferenceToPhysicalPoint, MergeToleranceLS: Double;

  function IsValidFlowValue(const AValue: Double): Boolean;
  begin
    Result := (not IsNan(AValue)) and (not IsInfinite(AValue));
  end;

  function M3H(const ALS: Double): Double;
  begin
    Result := ALS * 3.6;
  end;

  function IsAutomaticDeviceMode: Boolean;
  begin
    Result := Assigned(CurrentPoint) and (CurrentPoint.SpillageType = Ord(stWithStop));
  end;

  function NormalizePointName(const AName: string): string;
  begin
    Result := LowerCase(Trim(AName));
    Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
  end;

  function IsSameFlowRate(APoint: TDevicePoint): Boolean;
  begin
    Result := Assigned(CurrentPoint) and Assigned(APoint) and
      IsValidFlowValue(CurrentPoint.FlowRate) and IsValidFlowValue(APoint.FlowRate) and
      SameValue(APoint.FlowRate, CurrentPoint.FlowRate, 1E-6);
  end;

  function IsSamePointName(APoint: TDevicePoint): Boolean;
  begin
    Result := Assigned(CurrentPoint) and Assigned(APoint) and
      (NormalizePointName(APoint.Name) <> '') and
      (NormalizePointName(APoint.Name) = NormalizePointName(CurrentPoint.Name));
  end;

  function FlowMergeTolerance(const AQ1, AQ2: Double): Double;
  begin
    Result := Max(1E-6, Max(Abs(AQ1), Abs(AQ2)) * 1E-4);
  end;

  function CheckRangeRequirements(const ASettings: TMeterValueStabilitySettings;
    const AInfo: TMeterValueStabilityInfo): Boolean;
  begin
    Result := True;
    if ASettings.RequireCurrentValueInRange then
      Result := Result and AInfo.IsCurrentValueInRange;
    if ASettings.RequireMeanValueInRange then
      Result := Result and AInfo.IsMeanValueInRange;
    if ASettings.RequireForecastInRange then
      Result := Result and AInfo.IsForecastInRange;
  end;

  procedure PublishDeviceLog(const AText: string);
  begin
    CurrentTick := TMeterValue.GetMonotonicTimeMs;
    if (AText <> FLastDeviceStabilityLogText) or
       (FLastDeviceStabilityLogTick = 0) or
       (CurrentTick - FLastDeviceStabilityLogTick >= 5000) then
    begin
      AddDiagnosticEvent(AText);
      FLastDeviceStabilityLogText := AText;
      FLastDeviceStabilityLogTick := CurrentTick;
    end;
  end;

begin
  StableInfo := Default(RStableInfo);
  Result := True;
  CurrentPoint := GetCurrentPoint;

  if (FWorkTable = nil) or (FWorkTable.DeviceChannels = nil) then
  begin
    StableInfo.Status := sRun_NN;
    StableInfo.StatusText := 'NoSelectedDeviceChannels';
    Exit(False);
  end;

  CheckedCount := 0;
  ReadySecCount := 0;
  TotalSecCount := 0;
  ReadyAutoCount := 0;
  TotalAutoCount := 0;
  FirstNotReadyStatusText := '';
  for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := FWorkTable.DeviceChannels[I];
    if (Channel = nil) or (not Channel.Enabled) or (Channel.State = osDeleted) or
       (Channel.FlowMeter = nil) or (Channel.FlowMeter.ValueFlow = nil) then
      Continue;

    ValueFlow := Channel.FlowMeter.ValueFlow;
    ActualValue := ValueFlow.GetDoubleValue;
    Settings := ValueFlow.StabilitySettings;

    EtalonTargetValue := 0;
    if Assigned(CurrentPoint) and IsValidFlowValue(CurrentPoint.Q) then
      EtalonTargetValue := CurrentPoint.Q;
    DeviceQmaxLS := 0;
    if (Channel.FlowMeter.Device <> nil) and IsValidFlowValue(Channel.FlowMeter.Device.Qmax) then
      DeviceQmaxLS := Channel.FlowMeter.Device.Qmax;
    DeviceTargetValue := 0;
    if Assigned(CurrentPoint) and IsValidFlowValue(CurrentPoint.FlowRate) and
       (CurrentPoint.FlowRate > 0) and (DeviceQmaxLS > 0) then
      DeviceTargetValue := DeviceQmaxLS * CurrentPoint.FlowRate;
    TargetValue := DeviceTargetValue;
    TargetSource := 'DeviceQmaxLS*MeasurementPointFlowRate';
    PointMatchSource := '<none>';
    Reason := '';
    BestPoint := nil;
    BestDistance := MaxDouble;
    BestFlowRateDistance := MaxDouble;
    ErrorPercent := 0;
    AllowedDeviation := 0;
    CurrentInRange := False;
    MeanInRange := True;
    ForecastInRange := True;
    StableReady := False;
    RangeReady := True;
    Ready := False;
    SignalInfo := Default(TMeterValueStabilityInfo);
    DeviceUUID := Channel.DeviceUUID;
    if DeviceUUID = '' then
      DeviceUUID := Channel.FlowMeter.DeviceUUID;
    CurrentPointQ := 0;
    CurrentPointFlowRate := 0;
    if CurrentPoint <> nil then
    begin
      CurrentPointName := CurrentPoint.Name;
      CurrentPointQ := CurrentPoint.Q;
      CurrentPointFlowRate := CurrentPoint.FlowRate;
    end
    else
      CurrentPointName := '<none>';
    MatchedPointName := '<none>';
    DevicePointUUID := '';
    MatchedPointQ := 0;
    MatchedDistance := 0;
    Participant := Default(TMeasurementPointParticipant);
    ParticipantFound := False;
    TargetDifferenceToPhysicalPoint := 0;
    MergeToleranceLS := 0;

    if Assigned(CurrentPoint) then
      for J := 0 to High(CurrentPoint.Participants) do
        if (SameText(CurrentPoint.Participants[J].DeviceUUID, DeviceUUID) or
            ((Channel.FlowMeter.Device <> nil) and SameText(CurrentPoint.Participants[J].DeviceUUID, Channel.FlowMeter.Device.UUID))) and
           ((CurrentPoint.Participants[J].DeviceChannelUUID = '') or SameText(CurrentPoint.Participants[J].DeviceChannelUUID, Channel.UUID)) then
        begin
          Participant := CurrentPoint.Participants[J];
          ParticipantFound := True;
          Break;
        end;

    if not ParticipantFound then
    begin
      AddDiagnosticEvent(Format('DeviceChannelReadiness: ChannelIndex=%d; ChannelUUID=%s; ChannelName=%s; DeviceUUID=%s; MeasurementPointQLS=%.6f; ParticipantFound=False; ParticipatesInCurrentPoint=False; SkipReason=ParticipantNotAssigned; ActualLS=%.6f; ActualM3H=%.6f',
        [I, Channel.UUID, Channel.Name, DeviceUUID, CurrentPointQ, ActualValue, M3H(ActualValue)]));
      Continue;
    end;

    Inc(CheckedCount);
    RequireRange := not IsAutomaticDeviceMode;
    if RequireRange then
    begin
      Inc(TotalSecCount);
      ModeText := 'секундный'
    end
    else
    begin
      Inc(TotalAutoCount);
      ModeText := 'автоматический';
    end;

    TargetValue := Participant.SelectedSourceTargetQLS;
    DeviceTargetValue := TargetValue;
    TargetSource := 'MeasurementPoint.Participant.SelectedSourceTargetQLS';
    DevicePointUUID := Participant.SourcePointUUID;
    MatchedPointName := Participant.SourcePointName;
    ErrorPercent := Abs(Participant.SourceErrorPercent);
    TargetDifferenceToPhysicalPoint := Abs(TargetValue - CurrentPointQ);
    MergeToleranceLS := FlowMergeTolerance(TargetValue, CurrentPointQ);
    if TargetDifferenceToPhysicalPoint > MergeToleranceLS then
      Reason := 'ParticipantTargetDoesNotMatchPhysicalPoint';

    if (not Assigned(CurrentPoint)) or (not IsValidFlowValue(CurrentPoint.Q)) or
       (CurrentPoint.Q <= 0) then
      Reason := 'TargetNotAssigned';

    if Reason = '' then
    begin
      BestPoint := nil;
      if (Channel.FlowMeter.Device <> nil) and (Channel.FlowMeter.Device.Points <> nil) then
      begin
        for J := 0 to Channel.FlowMeter.Device.Points.Count - 1 do
        begin
          DevicePoint := Channel.FlowMeter.Device.Points[J];
          if (DevicePoint = nil) or (DevicePoint.State = osDeleted) or (not DevicePoint.Enabled) then
            Continue;

          if (Participant.SourcePointUUID <> '') and SameText(DevicePoint.UUID, Participant.SourcePointUUID) then
          begin
            BestPoint := DevicePoint;
            PointMatchSource := 'Participant.SourcePointUUID';
            Break;
          end;
        end;
        if BestPoint = nil then
          for J := 0 to Channel.FlowMeter.Device.Points.Count - 1 do
          begin
            DevicePoint := Channel.FlowMeter.Device.Points[J];
            if (DevicePoint = nil) or (DevicePoint.State = osDeleted) or (not DevicePoint.Enabled) or
               (not IsValidFlowValue(DevicePoint.Q)) then
              Continue;
            if Abs(DevicePoint.Q - TargetValue) <= MergeToleranceLS then
            begin
              BestPoint := DevicePoint;
              PointMatchSource := 'Participant.AbsoluteQFallback';
              Break;
            end;
          end;
      end;

      if BestPoint = nil then
        Reason := 'DevicePointNotFound'
    end;

    if Reason = '' then
    begin
      if IsNan(Participant.SourceErrorPercent) or IsInfinite(Participant.SourceErrorPercent) or
         (Participant.SourceErrorPercent < 0) then
        Reason := 'InvalidDevicePointError'
      else
      begin
        ErrorPercent := Abs(Participant.SourceErrorPercent);
        AllowedDeviation := Abs(TargetValue) * ErrorPercent / 100.0;
        StableInfo.LowerLimit := TargetValue - AllowedDeviation;
        StableInfo.UpperLimit := TargetValue + AllowedDeviation;

        ConfigureStabilityByPoint(ValueFlow, BestPoint);
        ConfigureTargetRangeByPoint(ValueFlow, BestPoint, False, False);
        Settings := ValueFlow.StabilitySettings;
        ValueFlow.AnalyzeStabilityForMeasurement(FStabilityDataStartMs,
          Settings, SignalInfo);
        StableInfo.LowerLimit := SignalInfo.StabilityLowerLimit;
        StableInfo.UpperLimit := SignalInfo.StabilityUpperLimit;
        CurrentInRange := SignalInfo.IsCurrentValueInRange;
        MeanInRange := True;
        ForecastInRange := True;
        StableReady := SignalInfo.IsSignalStable;
        RangeReady := True;
        Ready := StableReady;
      end;
    end;

    if Reason <> '' then
    begin
      StableReady := False;
      RangeReady := False;
      Ready := False;
      CurrentInRange := False;
      MeanInRange := False;
      ForecastInRange := False;
    end;

    StableInfo.CurrentValue := ActualValue;
    StableInfo.TargetValue := TargetValue;
    StableInfo.SignalInfo := SignalInfo;
    StableInfo.MeanValue := SignalInfo.MeanValue;
    StableInfo.ForecastValue := SignalInfo.ForecastValue;
    StableInfo.IsCurrentInRange := CurrentInRange;
    StableInfo.IsSignalStable := StableReady;
    StableInfo.IsMeanInRange := MeanInRange;
    StableInfo.IsForecastInRange := ForecastInRange;
    StableInfo.IsTargetConditionPassed := RangeReady;
    StableInfo.IsReadyForMeasurement := Ready;

    if Reason = '' then
    begin
      if Ready then
        Reason := 'Ready'
      else if not StableReady then
        Reason := SignalInfo.StatusText
      else if RequireRange and not RangeReady then
        Reason := 'StableButOutOfRequiredRange'
      else
        Reason := 'Stable; RangeDiagnosticOnly';
    end;

    if BestPoint <> nil then
    begin
      MatchedPointName := BestPoint.Name;
      DevicePointUUID := BestPoint.UUID;
      MatchedPointQ := BestPoint.Q;
      MatchedDistance := Abs(BestPoint.Q - TargetValue);
    end;

    LogText := Format('DeviceChannelReadiness: ChannelIndex=%d; ChannelUUID=%s; ChannelName=%s; DeviceUUID=%s; DevicePointUUID=%s; DevicePointName=%s; MeasurementMode=%s; MeasurementPointQLS=%.6f; ParticipantFound=%s; ParticipantSourcePointUUID=%s; ParticipantSourceTargetQLS=%.6f; DeviceTargetValue=%.6f; TargetDifferenceToPhysicalPointLS=%.9f; MergeToleranceLS=%.9f; ParticipatesInCurrentPoint=%s; DevicePointErrorPercent=%.6f; StabilityLower=%.6f; StabilityUpper=%.6f; UsedSampleCount=%d; RequiredSampleCount=%d; ElapsedWindowSec=%.3f; RequiredWindowDurationSec=%.3f; HasEnoughSamples=%s; HasFullWindow=%s; IsDataActual=%s; OutOfRangeSampleCount=%d; FirstOutOfRangeValue=%.6f; FirstOutOfRangeTimeMs=%d; Variation=%.9f; MaxVariation=%.9f; IsVariationStable=%s; StdDeviation=%.9f; MaxStdDeviation=%.9f; IsDeviationStable=%s; TrendRate=%.9f; MaxTrendRate=%.9f; IsTrendStable=%s; StableReady=%s; Ready=%s; Reason=%s; TargetSource=%s; DevicePointMatchSource=%s; ActualLS=%.6f; ActualM3H=%.6f',
      [I, Channel.UUID, Channel.Name, DeviceUUID, DevicePointUUID, MatchedPointName,
       ModeText, CurrentPointQ, BoolToStr(ParticipantFound, True), Participant.SourcePointUUID,
       Participant.SelectedSourceTargetQLS, TargetValue, TargetDifferenceToPhysicalPoint, MergeToleranceLS,
       BoolToStr(ParticipantFound and (Reason <> 'ParticipantTargetDoesNotMatchPhysicalPoint'), True),
       ErrorPercent, SignalInfo.StabilityLowerLimit, SignalInfo.StabilityUpperLimit,
       SignalInfo.UsedSampleCount, SignalInfo.RequiredSampleCount, SignalInfo.ElapsedWindowSec,
       SignalInfo.RequiredWindowDurationSec, BoolToStr(SignalInfo.HasEnoughSamples, True),
       BoolToStr(SignalInfo.HasFullWindow, True), BoolToStr(SignalInfo.IsDataActual, True),
       SignalInfo.OutOfRangeSampleCount, SignalInfo.FirstOutOfRangeSampleValue,
       SignalInfo.FirstOutOfRangeSampleTimeMs,
       SignalInfo.Variation, Settings.MaxVariation, BoolToStr(SignalInfo.IsVariationStable, True),
       SignalInfo.StdDeviation, Settings.MaxStdDeviation, BoolToStr(SignalInfo.IsDeviationStable, True),
       SignalInfo.TrendRate, Settings.MaxTrendRate, BoolToStr(SignalInfo.IsTrendStable, True),
       BoolToStr(StableReady, True), BoolToStr(Ready, True), Reason, TargetSource,
       PointMatchSource, ActualValue, M3H(ActualValue)]);
    PublishDeviceLog(LogText);

    if Ready then
    begin
      if RequireRange then
        Inc(ReadySecCount)
      else
        Inc(ReadyAutoCount);
    end
    else
    begin
      // Do not stop or overwrite the aggregate result here. Every enabled
      // participant is analyzed during the same IsDevicesStable call, so all
      // channel windows advance simultaneously. Preserve only the first
      // failure for the user-facing status.
      Result := False;
      if FirstNotReadyStatusText = '' then
        FirstNotReadyStatusText := Format(
          'Device channel is not ready: UUID=%s; Name=%s; Mode=%s; Reason=%s',
          [Channel.UUID, Channel.Name, ModeText, Reason]);
    end;
  end;

  if not Result then
  begin
    StableInfo.Status := sRun_NN;
    StableInfo.StatusText := FirstNotReadyStatusText;
  end;

  AddDiagnosticEvent(Format('DeviceReadinessSummary: SecondsDevicesReadyCount=%d; AutomaticDevicesReadyCount=%d; TotalRequiredDevices=%d; AllChannelsCheckedSimultaneously=True',
    [ReadySecCount, ReadyAutoCount, TotalSecCount + TotalAutoCount]));

  if CheckedCount = 0 then
  begin
    StableInfo.Status := sRun_NN;
    StableInfo.StatusText := 'NoSelectedDeviceChannels';
    Exit(False);
  end;

  if Result then
  begin
    StableInfo.Status := sOk;
    StableInfo.StatusText := 'DevicesReady=True';
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
  MinPercent, MaxPercent, AllowedMinus, AllowedPlus: Double;
  PointErrorPercent: Double;
  ToleranceSource, Reason, ChannelReason, FirstChannelFailureReason: string;
  GroupFlows: TDictionary<Integer, Double>;
  Pair: TPair<Integer, Double>;
  GroupKey: Integer;
  HasEtalonValue: Boolean;
  GroupFlowReached, AllChannelsStable, ChannelStable: Boolean;
begin
  StableInfo := Default(RStableInfo);
  Result := False;
  Point := GetCurrentPoint;
  if (FWorkTable = nil) or (FWorkTable.FlowRate = nil) or (Point = nil) then
    Exit;

  TargetValue := Point.Q;
  if (TargetValue < 0) and (FWorkTable.FlowRate.ValueSet <> nil) then
    TargetValue := FWorkTable.FlowRate.ValueSet.Value;

  ActualValue := 0;
  HasEtalonValue := False;
  AllChannelsStable := True;
  Reason := '';
  FirstChannelFailureReason := '';
  PointErrorPercent := 0;
  Settings := Default(TMeterValueStabilitySettings);
  ToleranceSource := 'Point.FlowAccuracy';
  if AccuracyToRange(Point.FlowAccuracy, MinPercent, MaxPercent) then
  begin
    AllowedMinus := Abs(TargetValue) * Abs(MinPercent) / 100.0;
    AllowedPlus := Abs(TargetValue) * Abs(MaxPercent) / 100.0;
  end
  else
  begin
    ToleranceSource := 'TMeterValue.StabilitySettings';
    AllowedMinus := 0;
    AllowedPlus := 0;
  end;
  if SameValue(AllowedMinus, 0) and SameValue(AllowedPlus, 0) then
  begin
    ToleranceSource := 'IsFlowFit default accuracy';
    AllowedMinus := Abs(TargetValue) * 10.0 / 100.0;
    AllowedPlus := AllowedMinus;
  end;
  StableInfo.TargetValue := TargetValue;
  StableInfo.LowerLimit := TargetValue - AllowedMinus;
  StableInfo.UpperLimit := TargetValue + AllowedPlus;
  if IsNan(Point.Error) or IsInfinite(Point.Error) or (Point.Error < 0) then
    Reason := Format('InvalidPointError: PointUUID=%s; PointName=%s; Error=%.6f', [Point.UUID, Point.Name, Point.Error])
  else
    PointErrorPercent := Abs(Point.Error);
  GroupFlows := TDictionary<Integer, Double>.Create;
  try
    if FWorkTable.EtalonChannels <> nil then
      for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
      begin
        Channel := FWorkTable.EtalonChannels[I];
        if (Channel = nil) or (not Channel.Enabled) or (Channel.State = osDeleted) or
           (Channel.FlowMeter = nil) or (Channel.FlowMeter.ValueFlow = nil) then
          Continue;

        StableValue := Channel.FlowMeter.ValueFlow;
        HasEtalonValue := True;
        GroupKey := Channel.Group;
        ActualValue := StableValue.GetDoubleValue;
        if GroupFlows.ContainsKey(GroupKey) then
          GroupFlows[GroupKey] := GroupFlows[GroupKey] + ActualValue
        else
          GroupFlows.Add(GroupKey, ActualValue);

        ConfigureStabilityByPoint(StableValue, Point);
        ConfigureTargetRangeByPoint(StableValue, Point, True, True);
        Settings := StableValue.StabilitySettings;
        if Reason = '' then
          StableValue.AnalyzeStabilityForMeasurement(FStabilityDataStartMs,
            Settings, SignalInfo)
        else
          SignalInfo := Default(TMeterValueStabilityInfo);
        ChannelStable := (Reason = '') and SignalInfo.IsSuitableForMeasurement;

        AllChannelsStable := AllChannelsStable and ChannelStable;
        if Reason <> '' then
          ChannelReason := Reason
        else
          ChannelReason := SignalInfo.StatusText;
        if (not ChannelStable) and (FirstChannelFailureReason = '') then
          FirstChannelFailureReason := ChannelReason;
        AddDiagnosticEvent(Format('EtalonChannelReady=%s; ChannelUUID=%s; ChannelName=%s; TargetValue=%.6f; PointErrorPercent=%.6f; StabilityLower=%.6f; StabilityUpper=%.6f; FlowAccuracy=%s; FlowReachedLower=%.6f; FlowReachedUpper=%.6f; UsedSampleCount=%d; RequiredSampleCount=%d; ElapsedWindowSec=%.3f; RequiredWindowDurationSec=%.3f; HasEnoughSamples=%s; HasFullWindow=%s; IsDataActual=%s; OutOfRangeSampleCount=%d; MinSampleValue=%.6f; MaxSampleValue=%.6f; Variation=%.9f; MaxVariation=%.9f; IsVariationStable=%s; StdDeviation=%.9f; MaxStdDeviation=%.9f; IsDeviationStable=%s; TrendRate=%.9f; MaxTrendRate=%.9f; IsTrendStable=%s; StableReady=%s; FlowReached=%s; Ready=%s; Reason=%s',
          [BoolToStr(ChannelStable, True), Channel.UUID, Channel.Name, TargetValue, PointErrorPercent,
           SignalInfo.StabilityLowerLimit, SignalInfo.StabilityUpperLimit, Point.FlowAccuracy,
           StableInfo.LowerLimit, StableInfo.UpperLimit, SignalInfo.UsedSampleCount,
           SignalInfo.RequiredSampleCount, SignalInfo.ElapsedWindowSec, SignalInfo.RequiredWindowDurationSec,
           BoolToStr(SignalInfo.HasEnoughSamples, True), BoolToStr(SignalInfo.HasFullWindow, True),
           BoolToStr(SignalInfo.IsDataActual, True), SignalInfo.OutOfRangeSampleCount,
           SignalInfo.MinValue, SignalInfo.MaxValue,
           SignalInfo.Variation, Settings.MaxVariation, BoolToStr(SignalInfo.IsVariationStable, True),
           SignalInfo.StdDeviation, Settings.MaxStdDeviation, BoolToStr(SignalInfo.IsDeviationStable, True),
           SignalInfo.TrendRate, Settings.MaxTrendRate, BoolToStr(SignalInfo.IsTrendStable, True),
           BoolToStr(ChannelStable, True),
           BoolToStr((ActualValue >= StableInfo.LowerLimit) and (ActualValue <= StableInfo.UpperLimit), True),
           BoolToStr(ChannelStable and ((ActualValue >= StableInfo.LowerLimit) and (ActualValue <= StableInfo.UpperLimit)), True),
           ChannelReason]));
      end;

    if HasEtalonValue then
    begin
      ActualValue := 0;
      for Pair in GroupFlows do
      begin
        AddDiagnosticEvent(Format('EtalonGroupFlow: Group=%d; Sum=%.6f', [Pair.Key, Pair.Value]));
        ActualValue := Max(ActualValue, Pair.Value);
      end;
      AddDiagnosticEvent(Format('EtalonGroupFlowSelectedMax=%.6f', [ActualValue]));
    end
    else
    begin
      StableValue := FWorkTable.FlowRate.Value;
      if StableValue = nil then
        Exit;
      ActualValue := StableValue.GetDoubleValue;
      ConfigureStabilityByPoint(StableValue, Point);
      ConfigureTargetRangeByPoint(StableValue, Point, True, True);
      Settings := StableValue.StabilitySettings;
      if Reason = '' then
        StableValue.AnalyzeStabilityForMeasurement(FStabilityDataStartMs,
          Settings, SignalInfo)
      else
        SignalInfo := Default(TMeterValueStabilityInfo);
      AllChannelsStable := (Reason = '') and SignalInfo.IsSuitableForMeasurement;
      if not AllChannelsStable then
        FirstChannelFailureReason := SignalInfo.StatusText;
      AddDiagnosticEvent(Format('EtalonFlowFallback=True; Source=FWorkTable.FlowRate.Value; Actual=%.6f', [ActualValue]));
    end;
  finally
    GroupFlows.Free;
  end;

  StableInfo.TargetValue := TargetValue;
  StableInfo.CurrentValue := ActualValue;
  StableInfo.IsCurrentInRange := (ActualValue >= StableInfo.LowerLimit) and (ActualValue <= StableInfo.UpperLimit);
  StableInfo.IsMeanInRange := True;
  StableInfo.IsForecastInRange := True;
  StableInfo.IsSignalStable := AllChannelsStable;
  GroupFlowReached := StableInfo.IsCurrentInRange;
  StableInfo.IsTargetConditionPassed := GroupFlowReached;
  StableInfo.IsReadyForMeasurement := GroupFlowReached and AllChannelsStable;
  Result := StableInfo.IsReadyForMeasurement;
  if Result then StableInfo.Status := sOk else StableInfo.Status := sRun_NN;
  StableInfo.StatusText := Format('EtalonFlowStable=%s; GroupFlowReached=%s; AllSelectedEtalonChannelsStable=%s; ToleranceSource=%s; Target=%.6f; Actual=%.6f; Lower=%.6f; Upper=%.6f; FailureReason=%s',
    [BoolToStr(Result, True), BoolToStr(GroupFlowReached, True), BoolToStr(AllChannelsStable, True),
     ToleranceSource, TargetValue, ActualValue, StableInfo.LowerLimit, StableInfo.UpperLimit,
     FirstChannelFailureReason]);
end;

procedure TMeasurementRun.ContinueAfterPointError(const AStatus: EMeasurementPointStatus;
  AEvent: EMeasurementEvent; const AError: TErrorInfo);
begin
  AddDiagnosticEvent('Point error: Status=' + GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(AStatus)) + '; Event=' + MeasurementEventToString(AEvent) + '; Error=' + AError.Msg);
  FLastProcessedPointIndex := FCurrentPointIndex;
  if GetCurrentPoint <> nil then
    FLastProcessedPointName := GetCurrentPoint.Name;
  SetCurrentPointStatus(AStatus);
  FireEvent(AEvent, AError);
  FCurrentRepeat := 0;

  if (FMode = mrmAutomatic) and (AStatus = mptsSetupError) then
  begin
    if FAttempt < FMaxAttemptCount then
    begin
      Inc(FAttempt);
      AddDiagnosticEvent(Format('Retry setup point: Attempt=%d of %d; %s', [FAttempt, FMaxAttemptCount, BuildPointSetupIdentityLog]));
      ResetPointSetupState;
      SetStage(msSetupPoint);
    end
    else
    begin
      SetStopReason(msrError);
      SetStage(msDone);
    end;
  end
  else
  begin
    SetStopReason(msrError);
    SetStage(msDone);
  end;
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
      WaitStableSec := (TMeterValue.GetMonotonicTimeMs - FWaitStartedTick) / 1000;
    MeasureSec := 0;
    if FCurrentStage = msMeasure then
      MeasureSec := (TMeterValue.GetMonotonicTimeMs - FWaitStartedTick) / 1000;

    if FCurrentStage = msDone then
      NextIndex := -1
    else
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
    Lines.Add('RunCompleted=' + SBool(FRunCompleted));
    Lines.Add('RunResult=' + GetEnumName(TypeInfo(TMeasurementRunResult), Ord(FRunResult)));
    Lines.Add('DoneReason=' + GetEnumName(TypeInfo(TMeasurementRunDoneReason), Ord(FDoneReason)));
    Lines.Add('RequestStopCalled=' + SBool(FRequestStopCalled));
    Lines.Add('LastProcessedPointIndex=' + IntToStr(FLastProcessedPointIndex));
    if FLastProcessedPointName <> '' then
      Lines.Add('LastProcessedPointName=' + FLastProcessedPointName)
    else
      Lines.Add('LastProcessedPointName=<нет данных>');
    Lines.Add('NextStageAfterSave=' + MeasurementStateToString(FNextStageAfterSave));
    Lines.Add('WorkTableFlowRangeSource=WorkTable.FlowRate.Min/Max');
    Lines.Add('WorkTableFlowRangeUpdatedBy=<см. события WorkTable.State/SelectEtalons>');
    Lines.Add('WorkTableFlowRangeUnit=л/с');
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
      if FStopReason <> msrNone then
      begin
        Lines.Add('ErrorStage=' + MeasurementStateToString(FCurrentStage));
        Lines.Add('ErrorPointIndex=' + IntToStr(FCurrentPointIndex));
        Lines.Add('ErrorPointUUID=' + Point.UUID);
        Lines.Add('ErrorPointName=' + Point.Name);
        Lines.Add('ErrorStatus=' + GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(Point.Status)));
        Lines.Add('ErrorReason=' + MeasurementStopReasonToString(FStopReason));
      end;
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
    Lines.Add('RequireAutoStabilization=' + SBool(FRequireAutoStabilization));
    Lines.Add('RequiredStabilizationSec=' + SFloat(FRequiredDeviceStabilizationSec));
    Lines.Add('StableSinceMs=' + UIntToStr(FStableSinceMs));
    Lines.Add('DevicesStableSinceMs=' + UIntToStr(FDevicesStableSinceMs));
    if FDevicesStableSinceMs <> 0 then
    begin
      Lines.Add('DevicesStableDurationSec=' + SFloat((TMeterValue.GetMonotonicTimeMs - FDevicesStableSinceMs) / 1000));
      Lines.Add('DevicesStableRemainingSec=' + SFloat(Max(0.0, FRequiredDeviceStabilizationSec - ((TMeterValue.GetMonotonicTimeMs - FDevicesStableSinceMs) / 1000))));
      Lines.Add('DevicesStableTimerRunning=True');
    end
    else
    begin
      Lines.Add('DevicesStableDurationSec=0');
      Lines.Add('DevicesStableRemainingSec=' + SFloat(FRequiredDeviceStabilizationSec));
      Lines.Add('DevicesStableTimerRunning=False');
    end;
    if FStableTimerResetReason <> '' then
      Lines.Add('StableTimerResetReason=' + FStableTimerResetReason)
    else
      Lines.Add('StableTimerResetReason=<нет данных>');
    if Point <> nil then
      Lines.Add('DeviceStabilizationValues=TDevicePoint.Pause=' + IntToStr(Point.Pause))
    else
      Lines.Add('DeviceStabilizationValues=<нет данных>');
    Lines.Add('Attempt=' + IntToStr(FAttempt));
    Lines.Add('MaxAttemptCount=' + IntToStr(FMaxAttemptCount));
    Lines.Add('TimeoutSec=' + IntToStr(CalcStableTimeoutSec));
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
    Lines.Add('RequestStopCalled=' + SBool(FRequestStopCalled));
    Lines.Add('RouteStopInWorker=<см. события>');
    Lines.Add('');
    Lines.Add('[ПЕРЕХОД]');
    Lines.Add('CurrentPointIndex=' + IntToStr(FCurrentPointIndex));
    Lines.Add('NextSearchStartIndex=' + IntToStr(FCurrentPointIndex + 1));
    Lines.Add('NextEnabledPointIndex=' + IntToStr(NextIndex));
    Lines.Add('NextPointExists=' + SBool(NextPoint <> nil));
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
    Lines.Add('DoneReason=' + GetEnumName(TypeInfo(TMeasurementRunDoneReason), Ord(FDoneReason)));
    Lines.Add('');
    Lines.Add('[СОХРАНЕНИЕ]');
    Lines.Add('SaveMeasurementResultsCalled=' + SBool(FLastSaveMeasurementResultsCalled));
    Lines.Add('LastSaveResult=' + FLastSaveMeasurementResultsResult);
    Lines.Add('MeasureCompletedEventSent=' + SBool(FLastMeasureCompletedEventSent));
    Lines.Add('SaveDoneEventSent=' + SBool(FLastSaveDoneEventSent));
    Lines.Add('PointDoneEventSent=' + SBool(FLastPointDoneEventSent));
    Lines.Add('ResultsAddedThisPoint=' + IntToStr(FLastResultsAddedToProcessing));
    if FLastResultsPerDevice <> '' then
      Lines.Add('TotalResultsPerDevice=' + FLastResultsPerDevice)
    else
      Lines.Add('TotalResultsPerDevice=<нет данных>');
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

class function TMeasurementRun.MeasurementRunModeToString(
  AMode: EMeasurementRunMode): string;
begin
  Result := GetEnumName(TypeInfo(EMeasurementRunMode), Ord(AMode));
end;

procedure TMeasurementRun.CreateSession;
begin
  ProtocolManager.AddMessage(pcInfo, psMeasurement, 'CreateSession',
    'Подготовка запуска измерения',
    Format('Mode=%d; Points=%d', [Ord(FMode), FPoints.Count]));
end;

procedure TMeasurementRun.RebuildMeasurementPoints;
var
  Point: TDevicePoint;
begin
  FPointsPrepared := False;
  FPoints.Clear;
  ResetPointSelectionContext;
  if FWorkTable = nil then
    Exit;

  case FMode of
    mrmAutomatic:
      if ShouldUseAllPoints then
        CreateSessionPoints;
    mrmManual:
      if FWorkTable.CurrentPoint <> nil then
      begin
        Point := TDevicePoint.Create(0);
        Point.Assign(FWorkTable.CurrentPoint, False);
        if Trim(Point.Name) = '' then
          Point.Name := 'Ручная точка';
        Point.Enabled := True;
        Point.Status := mptsNone;
        Point.RepeatsCompleted := 0;
        FPoints.Add(Point);
        FCurrentPointIndex := 0;
        FWorkTable.CurrentPoint.Assign(Point, False);
      end;
    mrmHalfAutomatic:
      begin
        Point := CreateSingleSessionPoint(True);
        if Point <> nil then
          FPoints.Add(Point);
      end;
  end;
  FPreparedPointsMode := FMode;
  FPointsPrepared := True;
end;

procedure TMeasurementRun.InvalidatePreparedPoints;
begin
  FPointsPrepared := False;
end;

function TMeasurementRun.MovePointUp(AIndex: Integer): Boolean;
var
  PointName: string;
begin
  Result := False;
  if not (FCurrentStage in [msNone, msDone]) or (FPoints = nil) or
     (AIndex <= 0) or (AIndex >= FPoints.Count) then
    Exit;
  PointName := FPoints[AIndex].Name;
  FPoints.Exchange(AIndex, AIndex - 1);
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'MeasurementPointMoved',
    'Изменён порядок поверочных точек',
    Format('Point=%s; OldIndex=%d; NewIndex=%d', [PointName, AIndex, AIndex - 1]));
  Result := True;
end;

function TMeasurementRun.MovePointDown(AIndex: Integer): Boolean;
var
  PointName: string;
begin
  Result := False;
  if not (FCurrentStage in [msNone, msDone]) or (FPoints = nil) or
     (AIndex < 0) or (AIndex >= FPoints.Count - 1) then
    Exit;
  PointName := FPoints[AIndex].Name;
  FPoints.Exchange(AIndex, AIndex + 1);
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'MeasurementPointMoved',
    'Изменён порядок поверочных точек',
    Format('Point=%s; OldIndex=%d; NewIndex=%d', [PointName, AIndex, AIndex + 1]));
  Result := True;
end;

procedure TMeasurementRun.SortPointsByFlow(const ADescending: Boolean);
var
  I, J: Integer;
  DirectionText: string;
begin
  if not (FCurrentStage in [msNone, msDone]) or (FPoints = nil) or
     (FPoints.Count < 2) then
    Exit;

  { Stable insertion sort: equal Q values are never exchanged. }
  for I := 1 to FPoints.Count - 1 do
  begin
    J := I;
    while (J > 0) and
      ((ADescending and (FPoints[J].Q > FPoints[J - 1].Q)) or
       ((not ADescending) and (FPoints[J].Q < FPoints[J - 1].Q))) do
    begin
      FPoints.Exchange(J, J - 1);
      Dec(J);
    end;
  end;
  if ADescending then
    DirectionText := 'Descending'
  else
    DirectionText := 'Ascending';
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'MeasurementPointsSorted',
    'Отсортированы поверочные точки',
    Format('Column=Flow; Direction=%s; PointsCount=%d',
      [DirectionText, FPoints.Count]));
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
const
  QmaxMismatchRelativeTolerance = 1E-3;
  FloatTolerance = 1E-9;
var
  Channel: TChannel;
  Device: TDevice;
  RepoDevice: TDevice;
  Repo: TDeviceRepository;
  SourcePoint: TDevicePoint;
  SessionPoint: TDevicePoint;
  ExistingPoint: TDevicePoint;
  Participant: TMeasurementPointParticipant;
  StoredQLS, CalculatedQLS, TargetQLS, MergeTolerance: Double;
  EtalonErrorPercent, EtalonDeltaQ, PointMinQ, PointMaxQ: Double;
  NewCommonMinQ, NewCommonMaxQ, IntersectionDeltaQ, ControlEtalonDeltaQ: Double;
  BestIntersectionDeltaQ, BestDistance, CandidateDistance: Double;
  DerivedQmaxLS, EffectiveDeviceQmaxLS, PointQValidationToleranceLS, RelativeQmaxDiff: Double;
  ProcessingDeviceCount, ProcessingDevicePointCount, ParticipantCount: Integer;
  I, J, DuplicateParticipantCount, LostSourcePointCount: Integer;
  TotalDeviceChannelCount, EnabledDeviceChannelCount, DisabledDeviceChannelCount: Integer;
  ResolvedUniqueDeviceCount, DistinctDeviceQmaxCount: Integer;
  DeviceSourcePointCount, DeviceAddedParticipantCount, DeviceCreatedPointCount, DeviceMergedParticipantCount: Integer;
  ChannelIndex: Integer;
  IncludedInAutomaticSession: Boolean;
  QmaxMismatch: Boolean;
  SkipReason, DeviceResolveSource: string;
  Action, Reason, PointName, MergeReason: string;
  ChannelUUIDText, ChannelDeviceUUIDText, ChannelDeviceNameText: string;
  SelectedDeviceUUIDText, SelectedDeviceNameText, RepoDeviceUUIDText: string;
  ChannelDeviceQmax, SelectedDeviceQmax, RepoDeviceQmax: Double;
  IsDistinctQmax: Boolean;
  DeviceUUIDs: TArray<string>;
  DeviceQmaxValues: TArray<Double>;
  DevicePointers: TArray<NativeUInt>;

  function IsValidFlowValue(const AValue: Double): Boolean;
  begin
    Result := (not IsNan(AValue)) and (not IsInfinite(AValue)) and (AValue > 0);
  end;

  function FlowMergeTolerance(const AQ1, AQ2: Double): Double;
  begin
    Result := Max(1E-6, Max(Abs(AQ1), Abs(AQ2)) * 1E-4);
  end;

  function CalculatePointEtalonRange(const APointQ, AEtalonErrorPercent: Double;
    out ADeltaQ, AMinQ, AMaxQ: Double): Boolean;
  begin
    ADeltaQ := 0;
    AMinQ := APointQ;
    AMaxQ := APointQ;
    Result := (not IsNan(AEtalonErrorPercent)) and
      (not IsInfinite(AEtalonErrorPercent)) and (AEtalonErrorPercent > 0) and
      (not IsNan(APointQ)) and (not IsInfinite(APointQ));
    if not Result then
      Exit;
    ADeltaQ := Abs(APointQ) * AEtalonErrorPercent / 100;
    Result := (ADeltaQ > 0) and (not IsNan(ADeltaQ)) and (not IsInfinite(ADeltaQ));
    if Result then
    begin
      AMinQ := APointQ - ADeltaQ;
      AMaxQ := APointQ + ADeltaQ;
    end;
  end;

  function TryCalculateMergedRange(APoint: TDevicePoint;
    const APointMinQ, APointMaxQ, APointEtalonDeltaQ: Double;
    out ANewMinQ, ANewMaxQ, AIntersectionQ, AControlDeltaQ: Double): Boolean;
  begin
    ANewMinQ := Max(APoint.CommonMinQ, APointMinQ);
    ANewMaxQ := Min(APoint.CommonMaxQ, APointMaxQ);
    AIntersectionQ := ANewMaxQ - ANewMinQ;
    AControlDeltaQ := Min(APoint.MinEtalonDeltaQ, APointEtalonDeltaQ);
    Result := APoint.EtalonRangeValid and
      (AIntersectionQ > FloatTolerance) and
      (AIntersectionQ + FloatTolerance >= AControlDeltaQ);
  end;

  function PtrText(AObject: TObject): string;
  begin
    if AObject = nil then
      Result := 'nil'
    else
      Result := '$' + IntToHex(NativeUInt(Pointer(AObject)), SizeOf(Pointer) * 2);
  end;


  function ChannelDevice(AChannel: TChannel): TDevice;
  begin
    Result := nil;
    if (AChannel <> nil) and (AChannel.FlowMeter <> nil) then
      Result := AChannel.FlowMeter.Device;
  end;

  function BoolText(const AValue: Boolean): string;
  begin
    if AValue then
      Result := 'True'
    else
      Result := 'False';
  end;

  function DeviceStateText(ADevice: TDevice): string;
  begin
    if ADevice = nil then
      Result := 'nil'
    else
      Result := GetEnumName(TypeInfo(TObjectState), Ord(ADevice.State));
  end;

  procedure AddUniqueDeviceInfo(ADevice: TDevice);
  var
    K: Integer;
  begin
    if ADevice = nil then
      Exit;
    for K := 0 to High(DeviceUUIDs) do
      if SameText(DeviceUUIDs[K], ADevice.UUID) then
        Exit;
    K := Length(DeviceUUIDs);
    SetLength(DeviceUUIDs, K + 1);
    SetLength(DeviceQmaxValues, K + 1);
    SetLength(DevicePointers, K + 1);
    DeviceUUIDs[K] := ADevice.UUID;
    DeviceQmaxValues[K] := ADevice.Qmax;
    DevicePointers[K] := NativeUInt(Pointer(ADevice));
  end;


  function EnabledSourcePointCount(ADevice: TDevice): Integer;
  var
    P: TDevicePoint;
  begin
    Result := 0;
    if (ADevice = nil) or (ADevice.Points = nil) then
      Exit;
    for P in ADevice.Points do
      if (P <> nil) and P.Enabled and (P.State <> osDeleted) then
        Inc(Result);
  end;

  function ParticipantExists(APoint: TDevicePoint; const AParticipant: TMeasurementPointParticipant): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    if APoint = nil then
      Exit;
    for K := 0 to High(APoint.Participants) do
      if SameText(APoint.Participants[K].DeviceUUID, AParticipant.DeviceUUID) and
         SameText(APoint.Participants[K].DeviceChannelUUID, AParticipant.DeviceChannelUUID) and
         SameText(APoint.Participants[K].SourcePointUUID, AParticipant.SourcePointUUID) then
        Exit(True);
  end;

  procedure AddParticipant(APoint: TDevicePoint; const AParticipant: TMeasurementPointParticipant);
  var
    N: Integer;
  begin
    if ParticipantExists(APoint, AParticipant) then
      Exit;
    N := Length(APoint.Participants);
    SetLength(APoint.Participants, N + 1);
    APoint.Participants[N] := AParticipant;
    APoint.SourcePointCount := Length(APoint.Participants);
    Inc(ParticipantCount);
  end;

  procedure RefreshSessionPointParams(APoint: TDevicePoint);
  var
    K, N: Integer;
    Names, Flows: TStringList;
    Value: string;
  begin
    if (APoint = nil) or (Length(APoint.Participants) = 0) then
      Exit;

    APoint.RequireAutoStabilization := False;
    APoint.RequiredStabilizationSec := 0;
    Names := TStringList.Create;
    Flows := TStringList.Create;
    try
      Names.CaseSensitive := False;
      Names.Duplicates := dupIgnore;
      Flows.Duplicates := dupIgnore;
      for K := 0 to High(APoint.Participants) do
      begin
        if APoint.Participants[K].SourcePauseSec < 0 then
          APoint.RequireAutoStabilization := True
        else
          APoint.RequiredStabilizationSec := Max(APoint.RequiredStabilizationSec, APoint.Participants[K].SourcePauseSec);
        Value := Trim(APoint.Participants[K].SourcePointName);
        if (Value <> '') and (Names.IndexOf(Value) < 0) then
          Names.Add(Value);
        Value := Format('%.4f', [APoint.Participants[K].SelectedSourceTargetQLS]);
        if Flows.IndexOf(Value) < 0 then
          Flows.Add(Value);
      end;
      Value := '';
      if Names.Count > 0 then
        for N := 0 to Names.Count - 1 do
        begin
          if Value <> '' then Value := Value + ' → ';
          Value := Value + Names[N];
        end
      else
        for N := 0 to Flows.Count - 1 do
        begin
          if Value <> '' then Value := Value + ' → ';
          Value := Value + Flows[N];
        end;
      APoint.Name := Value;
    finally
      Flows.Free;
      Names.Free;
    end;
    if APoint.RequireAutoStabilization then
      APoint.Pause := -1
    else
      APoint.Pause := Round(APoint.RequiredStabilizationSec);
  end;

begin
  if FPoints = nil then
    FPoints := TObjectList<TDevicePoint>.Create(True);
  FPoints.Clear;
  if FWorkTable = nil then
    Exit;

  ProcessingDeviceCount := 0;
  ProcessingDevicePointCount := 0;
  ParticipantCount := 0;
  DuplicateParticipantCount := 0;
  LostSourcePointCount := 0;
  TotalDeviceChannelCount := 0;
  EnabledDeviceChannelCount := 0;
  DisabledDeviceChannelCount := 0;

  if FWorkTable.DeviceChannels.Count = 0 then
    FWorkTable.AddDeviceChannel(True, -1, TWorkTable.BuildChannelDefaultText(1), '', '-', '');

  TotalDeviceChannelCount := FWorkTable.DeviceChannels.Count;

  for ChannelIndex := 0 to FWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := FWorkTable.DeviceChannels[ChannelIndex];
    Device := nil;
    RepoDevice := nil;
    DeviceResolveSource := 'None';
    SkipReason := '';

    Device := ChannelDevice(Channel);
    if Device <> nil then
      DeviceResolveSource := 'Channel.FlowMeter.Device';

    if Channel = nil then
      SkipReason := 'ChannelNil'
    else if not Channel.Enabled then
      SkipReason := 'ChannelDisabled'
    else if Channel.State = osDeleted then
      SkipReason := 'ChannelDeleted'
    else if Channel.FlowMeter = nil then
      SkipReason := 'FlowMeterNotAssigned'
    else if Device = nil then
      SkipReason := 'DeviceNotAssigned'
    else if Device.State = osDeleted then
      SkipReason := 'DeviceDeleted';

    IncludedInAutomaticSession := SkipReason = '';

    if (Device <> nil) and (Trim(Device.UUID) <> '') and (DataManager <> nil) then
      RepoDevice := DataManager.FindDevice(Device.UUID, Repo);
    if (RepoDevice <> nil) and not SameText(RepoDevice.UUID, Device.UUID) then
      RepoDevice := nil;

    if IncludedInAutomaticSession then
    begin
      if ((Device.Points = nil) or (Device.Points.Count = 0)) and
         (DataManager <> nil) and (DataManager.ActiveDeviceRepo <> nil) then
      begin
        RepoDevice := DataManager.FindDevice(Device.UUID, Repo);
        if (RepoDevice <> nil) and SameText(RepoDevice.UUID, Device.UUID) then
        begin
          Device := RepoDevice;
          DeviceResolveSource := 'RepositoryByUUID';
        end;
      end;
      if EnabledSourcePointCount(Device) = 0 then
      begin
        SkipReason := 'NoEnabledSourcePoints';
        IncludedInAutomaticSession := False;
      end;
    end;

    if IncludedInAutomaticSession then
      Inc(EnabledDeviceChannelCount)
    else
      Inc(DisabledDeviceChannelCount);

    ChannelUUIDText := '';
    if Channel <> nil then
      ChannelUUIDText := Channel.UUID;
    ChannelDeviceUUIDText := '';
    ChannelDeviceNameText := '';
    ChannelDeviceQmax := 0;
    if ChannelDevice(Channel) <> nil then
    begin
      ChannelDeviceUUIDText := ChannelDevice(Channel).UUID;
      ChannelDeviceNameText := ChannelDevice(Channel).Name;
      ChannelDeviceQmax := ChannelDevice(Channel).Qmax;
    end;
    RepoDeviceUUIDText := '';
    RepoDeviceQmax := 0;
    if RepoDevice <> nil then
    begin
      RepoDeviceUUIDText := RepoDevice.UUID;
      RepoDeviceQmax := RepoDevice.Qmax;
    end;
    SelectedDeviceUUIDText := '';
    SelectedDeviceNameText := '';
    SelectedDeviceQmax := 0;
    if Device <> nil then
    begin
      SelectedDeviceUUIDText := Device.UUID;
      SelectedDeviceNameText := Device.Name;
      SelectedDeviceQmax := Device.Qmax;
    end;

    AddDiagnosticEvent(Format('CreateSessionChannelResolve: ChannelIndex=%d; ChannelUUID=%s; ChannelEnabled=%s; ChannelDevicePointer=%s; ChannelDeviceUUID=%s; ChannelDeviceName=%s; ChannelDeviceQmaxLS=%.6f; RepositoryDevicePointer=%s; RepositoryDeviceUUID=%s; RepositoryDeviceQmaxLS=%.6f; SelectedDevicePointer=%s; SelectedDeviceUUID=%s; SelectedDeviceQmaxLS=%.6f; DeviceResolveSource=%s',
      [ChannelIndex, ChannelUUIDText, BoolText((Channel <> nil) and Channel.Enabled), PtrText(ChannelDevice(Channel)), ChannelDeviceUUIDText, ChannelDeviceNameText, ChannelDeviceQmax, PtrText(RepoDevice), RepoDeviceUUIDText, RepoDeviceQmax, PtrText(Device), SelectedDeviceUUIDText, SelectedDeviceQmax, DeviceResolveSource]));
    AddDiagnosticEvent(Format('CreateSessionChannelInclude: ChannelIndex=%d; ChannelUUID=%s; ChannelEnabled=%s; FlowMeterEnabled=%s; DeviceEnabled=%s; DeviceState=%s; IncludedInAutomaticSession=%s; SkipReason=%s',
      [ChannelIndex, ChannelUUIDText, BoolText((Channel <> nil) and Channel.Enabled), 'n/a', BoolText((Device <> nil) and Device.Enabled), DeviceStateText(Device), BoolText(IncludedInAutomaticSession), SkipReason]));

    if not IncludedInAutomaticSession then
      Continue;

    AddUniqueDeviceInfo(Device);
    Inc(ProcessingDeviceCount);
    DeviceSourcePointCount := 0;
    DeviceAddedParticipantCount := 0;
    DeviceCreatedPointCount := 0;
    DeviceMergedParticipantCount := 0;
    for SourcePoint in Device.Points do
    begin
      if (SourcePoint = nil) or (not SourcePoint.Enabled) or (SourcePoint.State = osDeleted) then
        Continue;
      Inc(ProcessingDevicePointCount);
      Inc(DeviceSourcePointCount);

      StoredQLS := SourcePoint.Q;
      CalculatedQLS := 0;
      DerivedQmaxLS := 0;
      EffectiveDeviceQmaxLS := Device.Qmax;
      if IsValidFlowValue(SourcePoint.FlowRate) and IsValidFlowValue(StoredQLS) then
        DerivedQmaxLS := StoredQLS / SourcePoint.FlowRate;
      QmaxMismatch := False;
      RelativeQmaxDiff := 0;
      if IsValidFlowValue(DerivedQmaxLS) and IsValidFlowValue(Device.Qmax) then
      begin
        RelativeQmaxDiff := Abs(Device.Qmax - DerivedQmaxLS) / Max(Abs(DerivedQmaxLS), 1E-12);
        QmaxMismatch := RelativeQmaxDiff > QmaxMismatchRelativeTolerance;
      end;
      if QmaxMismatch and IsValidFlowValue(DerivedQmaxLS) then
        EffectiveDeviceQmaxLS := DerivedQmaxLS;
      if IsValidFlowValue(EffectiveDeviceQmaxLS) and IsValidFlowValue(SourcePoint.FlowRate) then
        CalculatedQLS := EffectiveDeviceQmaxLS * SourcePoint.FlowRate;
      AddDiagnosticEvent(Format('SessionSourcePointQmaxValidation: ChannelDeviceUUID=%s; SelectedDeviceUUID=%s; SelectedDeviceQmaxLS=%.6f; EffectiveDeviceQmaxLS=%.6f; SourcePointQLS=%.6f; SourcePointFlowRate=%.9f; DerivedQmaxLS=%.6f; QmaxMismatch=%s',
        [ChannelDeviceUUIDText, Device.UUID, Device.Qmax, EffectiveDeviceQmaxLS, StoredQLS, SourcePoint.FlowRate, DerivedQmaxLS, BoolText(QmaxMismatch)]));
      if QmaxMismatch then
        AddDiagnosticEvent(Format('DeviceQmaxBindingCorrectedFromSourcePoint: ChannelUUID=%s; DeviceUUID=%s; StoredQmax=%.6f; DerivedQmax=%.6f; SourcePointUUID=%s; StoredPointQLS=%.6f; SourceFlowRate=%.9f; CalculatedTargetQLS=%.6f; RelativeQmaxDiff=%.9f',
          [Channel.UUID, Device.UUID, Device.Qmax, DerivedQmaxLS, SourcePoint.UUID, StoredQLS, SourcePoint.FlowRate, CalculatedQLS, RelativeQmaxDiff]));
      if not IsValidFlowValue(CalculatedQLS) then
      begin
        AddDiagnosticEvent(Format('SessionSourcePoint: DeviceUUID=%s; DeviceChannelUUID=%s; SourcePointUUID=%s; SourcePointName=%s; SourceFlowRate=%.9f; DeviceQmaxLS=%.6f; StoredPointQLS=%.6f; CalculatedTargetQLS=%.6f; DerivedQmaxLS=%.6f; SelectedTargetQLS=0; MatchedSessionPointUUID=; MatchedSessionPointQLS=0; MergeToleranceLS=0; Action=Skipped; Reason=InvalidCalculatedTargetQLS',
          [Device.UUID, Channel.UUID, SourcePoint.UUID, SourcePoint.Name, SourcePoint.FlowRate, EffectiveDeviceQmaxLS, StoredQLS, CalculatedQLS, DerivedQmaxLS]));
        Continue;
      end;

      TargetQLS := CalculatedQLS;
      PointQValidationToleranceLS := Max(1E-6, Abs(StoredQLS) * 1E-4);
      if IsValidFlowValue(StoredQLS) and (Abs(StoredQLS - CalculatedQLS) <= PointQValidationToleranceLS) then
        TargetQLS := StoredQLS
      else if IsValidFlowValue(StoredQLS) then
        AddDiagnosticEvent(Format('SourcePointQMismatch: CurrentDeviceUUID=%s; CurrentDeviceQmaxLS=%.6f; SourcePointQLS=%.6f; SourcePointFlowRate=%.9f; CalculatedTargetQLS=%.6f; DerivedQmaxLS=%.6f',
          [Device.UUID, EffectiveDeviceQmaxLS, StoredQLS, SourcePoint.FlowRate, CalculatedQLS, DerivedQmaxLS]));

      Participant := Default(TMeasurementPointParticipant);
      Participant.DeviceUUID := Device.UUID;
      Participant.DeviceChannelUUID := Channel.UUID;
      Participant.SourcePointUUID := SourcePoint.UUID;
      Participant.SourcePointName := SourcePoint.Name;
      Participant.SourceFlowRate := SourcePoint.FlowRate;
      Participant.SourceDeviceQmaxLS := EffectiveDeviceQmaxLS;
      Participant.StoredSourcePointQLS := StoredQLS;
      Participant.CalculatedSourceTargetQLS := CalculatedQLS;
      Participant.SelectedSourceTargetQLS := TargetQLS;
      Participant.SourceTargetQLS := TargetQLS;
      Participant.SourceErrorPercent := SourcePoint.Error;
      Participant.SourcePauseSec := SourcePoint.Pause;

      EtalonErrorPercent := SourcePoint.Error;
      if not CalculatePointEtalonRange(TargetQLS, EtalonErrorPercent,
        EtalonDeltaQ, PointMinQ, PointMaxQ) then
        MergeReason := 'InvalidEtalonError'
      else
        MergeReason := '';
      AddDiagnosticEvent(Format('SessionPointRange: DeviceUUID=%s; ChannelUUID=%s; SourcePointUUID=%s; SourcePointName=%s; SourceFlowRate=%.9f; PointQ=%.9f; EtalonErrorPercent=%.9f; EtalonDeltaQ=%.9f; PointMinQ=%.9f; PointMaxQ=%.9f',
        [Device.UUID, Channel.UUID, SourcePoint.UUID, SourcePoint.Name,
         SourcePoint.FlowRate, TargetQLS, EtalonErrorPercent, EtalonDeltaQ,
         PointMinQ, PointMaxQ]));

      ExistingPoint := nil;
      BestIntersectionDeltaQ := -MaxDouble;
      BestDistance := MaxDouble;
      if FMergePoints then
      for SessionPoint in FPoints do
      begin
        if ParticipantExists(SessionPoint, Participant) then
        begin
          Inc(DuplicateParticipantCount);
          AddDiagnosticEvent(Format('SessionPointMergeCheck: SourcePointUUID=%s; CandidateSessionPointUUID=%s; CandidateSessionPointName=%s; CandidateQ=%.9f; CurrentCommonMinQ=%.9f; CurrentCommonMaxQ=%.9f; PointMinQ=%.9f; PointMaxQ=%.9f; NewCommonMinQ=0; NewCommonMaxQ=0; IntersectionDeltaQ=0; CurrentMinEtalonDeltaQ=%.9f; PointEtalonDeltaQ=%.9f; ControlEtalonDeltaQ=0; CanMerge=False; Reason=DuplicateParticipant',
            [SourcePoint.UUID, SessionPoint.UUID, SessionPoint.Name, SessionPoint.Q,
             SessionPoint.CommonMinQ, SessionPoint.CommonMaxQ, PointMinQ, PointMaxQ,
             SessionPoint.MinEtalonDeltaQ, EtalonDeltaQ]));
          Continue;
        end;
        if MergeReason = 'InvalidEtalonError' then
        begin
          NewCommonMinQ := 0; NewCommonMaxQ := 0; IntersectionDeltaQ := 0; ControlEtalonDeltaQ := 0;
          Reason := 'InvalidEtalonError';
        end
        else if TryCalculateMergedRange(SessionPoint, PointMinQ, PointMaxQ,
          EtalonDeltaQ, NewCommonMinQ, NewCommonMaxQ, IntersectionDeltaQ,
          ControlEtalonDeltaQ) then
          Reason := 'MergedByCommonRange'
        else if not SessionPoint.EtalonRangeValid then
          Reason := 'InvalidEtalonError'
        else if IntersectionDeltaQ < -FloatTolerance then
          Reason := 'NoIntersection'
        else if IntersectionDeltaQ <= FloatTolerance then
          Reason := 'TouchOnly'
        else
          Reason := 'IntersectionNarrowerThanEtalonTolerance';
        AddDiagnosticEvent(Format('SessionPointMergeCheck: SourcePointUUID=%s; CandidateSessionPointUUID=%s; CandidateSessionPointName=%s; CandidateQ=%.9f; CurrentCommonMinQ=%.9f; CurrentCommonMaxQ=%.9f; PointMinQ=%.9f; PointMaxQ=%.9f; NewCommonMinQ=%.9f; NewCommonMaxQ=%.9f; IntersectionDeltaQ=%.9f; CurrentMinEtalonDeltaQ=%.9f; PointEtalonDeltaQ=%.9f; ControlEtalonDeltaQ=%.9f; CanMerge=%s; Reason=%s',
          [SourcePoint.UUID, SessionPoint.UUID, SessionPoint.Name, SessionPoint.Q,
           SessionPoint.CommonMinQ, SessionPoint.CommonMaxQ, PointMinQ, PointMaxQ,
           NewCommonMinQ, NewCommonMaxQ, IntersectionDeltaQ, SessionPoint.MinEtalonDeltaQ,
           EtalonDeltaQ, ControlEtalonDeltaQ, BoolText(Reason = 'MergedByCommonRange'), Reason]));
        if Reason = 'MergedByCommonRange' then
        begin
          CandidateDistance := Abs(SessionPoint.Q - TargetQLS);
          if (ExistingPoint = nil) or
             (IntersectionDeltaQ > BestIntersectionDeltaQ + FloatTolerance) or
             (SameValue(IntersectionDeltaQ, BestIntersectionDeltaQ, FloatTolerance) and
              (CandidateDistance < BestDistance - FloatTolerance)) then
          begin
            ExistingPoint := SessionPoint;
            BestIntersectionDeltaQ := IntersectionDeltaQ;
            BestDistance := CandidateDistance;
          end;
        end;
      end;

      if ExistingPoint = nil then
      begin
        SessionPoint := TDevicePoint.Create(0);
        SessionPoint.Assign(SourcePoint, True);
        SetLength(SessionPoint.Participants, 0);
        SessionPoint.SourcePointCount := 0;
        SessionPoint.Q := TargetQLS;
        SessionPoint.CommonMinQ := PointMinQ;
        SessionPoint.CommonMaxQ := PointMaxQ;
        SessionPoint.MinEtalonDeltaQ := EtalonDeltaQ;
        SessionPoint.EtalonRangeValid := MergeReason <> 'InvalidEtalonError';
        SessionPoint.DeviceUUID := '';
        SessionPoint.Status := mptsNone;
        SessionPoint.RepeatsCompleted := 0;
        AddParticipant(SessionPoint, Participant);
        RefreshSessionPointParams(SessionPoint);
        FPoints.Add(SessionPoint);
        MergeTolerance := FlowMergeTolerance(SessionPoint.Q, TargetQLS);
        Inc(DeviceAddedParticipantCount);
        Inc(DeviceCreatedPointCount);
        Action := 'Created';
        if MergeReason = 'InvalidEtalonError' then
          Reason := MergeReason
        else
          Reason := 'NewPhysicalPoint';
      end
      else
      begin
        MergePointParams(ExistingPoint, SourcePoint);
        AddParticipant(ExistingPoint, Participant);
        Inc(DeviceAddedParticipantCount);
        Inc(DeviceMergedParticipantCount);
        ExistingPoint.CommonMinQ := Max(ExistingPoint.CommonMinQ, PointMinQ);
        ExistingPoint.CommonMaxQ := Min(ExistingPoint.CommonMaxQ, PointMaxQ);
        ExistingPoint.MinEtalonDeltaQ := Min(ExistingPoint.MinEtalonDeltaQ, EtalonDeltaQ);
        ExistingPoint.Q := (ExistingPoint.CommonMinQ + ExistingPoint.CommonMaxQ) / 2;
        Action := 'Merged';
        Reason := 'MergedByCommonRange';
        RefreshSessionPointParams(ExistingPoint);
        SessionPoint := ExistingPoint;
        MergeTolerance := FlowMergeTolerance(SessionPoint.Q, TargetQLS);
        AddDiagnosticEvent(Format('SessionPointMerged: SessionPointUUID=%s; SessionPointName=%s; ParticipantCount=%d; CommonMinQ=%.9f; CommonMaxQ=%.9f; IntersectionWidthQ=%.9f; TargetQ=%.9f; MinEtalonDeltaQ=%.9f',
          [SessionPoint.UUID, SessionPoint.Name, Length(SessionPoint.Participants),
           SessionPoint.CommonMinQ, SessionPoint.CommonMaxQ,
           SessionPoint.CommonMaxQ - SessionPoint.CommonMinQ, SessionPoint.Q,
           SessionPoint.MinEtalonDeltaQ]));
      end;

      AddDiagnosticEvent(Format('SessionSourcePoint: DeviceUUID=%s; DeviceChannelUUID=%s; SourcePointUUID=%s; SourcePointName=%s; SourceFlowRate=%.9f; DeviceQmaxLS=%.6f; StoredPointQLS=%.6f; CalculatedTargetQLS=%.6f; DerivedQmaxLS=%.6f; SelectedTargetQLS=%.6f; MatchedSessionPointUUID=%s; MatchedSessionPointQLS=%.6f; MergeToleranceLS=%.9f; Action=%s; Reason=%s',
        [Device.UUID, Channel.UUID, SourcePoint.UUID, SourcePoint.Name, SourcePoint.FlowRate,
         EffectiveDeviceQmaxLS, StoredQLS, CalculatedQLS, DerivedQmaxLS, TargetQLS, SessionPoint.UUID, SessionPoint.Q,
         MergeTolerance, Action, Reason]));
    end;
    AddDiagnosticEvent(Format('CreateSessionDeviceSummary: DeviceUUID=%s; DeviceName=%s; DeviceQmaxLS=%.6f; EnabledSourcePointCount=%d; AddedParticipantCount=%d; CreatedPhysicalPointCount=%d; MergedParticipantCount=%d',
      [Device.UUID, Device.Name, Device.Qmax, DeviceSourcePointCount, DeviceAddedParticipantCount,
       DeviceCreatedPointCount, DeviceMergedParticipantCount]));
  end;

  ResolvedUniqueDeviceCount := Length(DeviceUUIDs);
  DistinctDeviceQmaxCount := 0;
  for I := 0 to High(DeviceQmaxValues) do
  begin
    IsDistinctQmax := True;
    for J := 0 to I - 1 do
      if Abs(DeviceQmaxValues[I] - DeviceQmaxValues[J]) <= FlowMergeTolerance(DeviceQmaxValues[I], DeviceQmaxValues[J]) then
      begin
        IsDistinctQmax := False;
        Break;
      end;
    if IsDistinctQmax then
      Inc(DistinctDeviceQmaxCount);
  end;

  if ResolvedUniqueDeviceCount > 1 then
  begin
    for I := 0 to High(DevicePointers) do
      for J := I + 1 to High(DevicePointers) do
        if DevicePointers[I] = DevicePointers[J] then
        begin
          PointName := 'DeviceChannelBindingMismatch: different DeviceUUID values resolve to the same DevicePointer';
          AddDiagnosticEvent(PointName);
          ProtocolManager.AddMessage(pcError, psMeasurement, 'DeviceChannelBindingMismatch', 'Некорректная привязка каналов приборов', PointName);
          raise Exception.Create(PointName);
        end;
  end;

  FPoints.Sort(TComparer<TDevicePoint>.Construct(
    function(const Left, Right: TDevicePoint): Integer
    begin
      Result := CompareValue(Left.Q, Right.Q, 1E-12);
      if Result = 0 then
        Result := CompareText(Left.Name, Right.Name);
      if Result = 0 then
        Result := CompareText(Left.UUID, Right.UUID);
    end));

  for I := 0 to FPoints.Count - 1 do
  begin
    FPoints[I].Num := I + 1;
    RefreshSessionPointParams(FPoints[I]);
    AddDiagnosticEvent(Format('SessionPointFinal: SessionPointIndex=%d; SessionPointUUID=%s; SessionPointName=%s; PhysicalTargetQLS=%.6f; Participants.Count=%d',
      [I, FPoints[I].UUID, FPoints[I].Name, FPoints[I].Q, Length(FPoints[I].Participants)]));
    for J := 0 to High(FPoints[I].Participants) do
      AddDiagnosticEvent(Format('SessionPointFinalParticipant: SessionPointIndex=%d; DeviceUUID=%s; DeviceChannelUUID=%s; SourcePointUUID=%s; SourcePointName=%s; SelectedSourceTargetQLS=%.6f',
        [I, FPoints[I].Participants[J].DeviceUUID, FPoints[I].Participants[J].DeviceChannelUUID,
         FPoints[I].Participants[J].SourcePointUUID, FPoints[I].Participants[J].SourcePointName,
         FPoints[I].Participants[J].SelectedSourceTargetQLS]));
  end;

  for I := 0 to FPoints.Count - 1 do
    for J := 0 to High(FPoints[I].Participants) do
      if FPoints[I].EtalonRangeValid and
         ((FPoints[I].Q < FPoints[I].CommonMinQ - FloatTolerance) or
          (FPoints[I].Q > FPoints[I].CommonMaxQ + FloatTolerance)) then
        Inc(LostSourcePointCount);

  AddDiagnosticEvent(Format('CreateSessionSummary: TotalDeviceChannelCount=%d; EnabledDeviceChannelCount=%d; DisabledDeviceChannelCount=%d; ResolvedUniqueDeviceCount=%d; DistinctDeviceQmaxCount=%d; ProcessingDeviceCount=%d; ProcessingDevicePointCount=%d; SessionPointCount=%d; ParticipantCount=%d; UniqueParticipantCount=%d; DuplicateParticipantCount=%d; LostSourcePointCount=%d',
    [TotalDeviceChannelCount, EnabledDeviceChannelCount, DisabledDeviceChannelCount,
     ResolvedUniqueDeviceCount, DistinctDeviceQmaxCount, ProcessingDeviceCount,
     ProcessingDevicePointCount, FPoints.Count, ParticipantCount, ParticipantCount,
     DuplicateParticipantCount, LostSourcePointCount]));

  if FPoints.Count = 0 then
    ProtocolManager.AddMessage(pcWarning, psMeasurement,
      'NoAutomaticMeasurementPoints', 'Не сформированы точки автоматического запуска',
      'Points.Count=0');

  if (LostSourcePointCount > 0) or (ParticipantCount <> ProcessingDevicePointCount) then
  begin
    PointName := Format('InvalidMeasurementSession: ProcessingDevicePointCount=%d; ParticipantCount=%d; LostSourcePointCount=%d',
      [ProcessingDevicePointCount, ParticipantCount, LostSourcePointCount]);
    ProtocolManager.AddMessage(pcError, psMeasurement, 'InvalidMeasurementSession', 'Некорректная сессия измерения', PointName);
    raise Exception.Create(PointName);
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
  StartPreparedMeasurementRun;
end;

procedure TMeasurementRun.StartPreparedMeasurementRun;
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
    if (not FPointsPrepared) or (FPreparedPointsMode <> FMode) then
      RebuildMeasurementPoints;
    ResetPointSelectionContext;
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

    if (FMode = mrmManual) and ((FWorkTable.CurrentPoint = nil) or
       (FPoints.Count = 0)) then
    begin
      ProtocolManager.AddMessage(pcWarning, psMeasurement, 'Start',
        'Измерение не запущено', 'В ручном режиме не задана текущая точка измерения');
      FireEvent(mePointNotSet, BuildError(1002, 'В ручном режиме не задана текущая точка измерения'));
      if FCurrentStage <> msNone then
        SetStage(msNone);
      Exit;
    end;

    if (FPoints.Count = 0) or (FindNextEnabledPointIndex(0) < 0) then
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
    FLastProcessedPointIndex := -1;
    FLastProcessedPointName := '';
    FLastResultsAddedToProcessing := 0;
    FLastResultsPerDevice := '';
    FLastRouteStopDiagnosticKey := '';
    FStableSinceMs := 0;
    FDevicesStableSinceMs := 0;
    FLastDeviceStableStateKnown := False;
    FLastDeviceStableState := False;
    FRequireAutoStabilization := False;
    FRequiredDeviceStabilizationSec := 0;
    FLastStableProgressSecond := -1;
    FStableTimerResetReason := '';
    FRunCompleted := False;
    FRunResult := mrrNone;
    FDoneReason := mdrNone;
    FRequestStopCalled := False;
    FFinalized := False;

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
var
  DiagnosticKey: string;
begin
  if IsStopRequested then
    AddDiagnosticEvent('RouteStopInWorker processing: Stage=' + MeasurementStateToString(FCurrentStage));
  if not IsStopRequested then
    Exit;

  DiagnosticKey := MeasurementStateToString(FCurrentStage) + '|';
  if FWorkTable <> nil then
    DiagnosticKey := DiagnosticKey + GetEnumName(TypeInfo(EStateWorkTable), Ord(FWorkTable.State))
  else
    DiagnosticKey := DiagnosticKey + '<нет WorkTable>';
  DiagnosticKey := DiagnosticKey + '|Stop=True';
  if DiagnosticKey <> FLastRouteStopDiagnosticKey then
  begin
    FLastRouteStopDiagnosticKey := DiagnosticKey;
    AddDiagnosticEvent('RouteStopInWorker accepted: ' + DiagnosticKey);
  end;

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
  if FWorkTable <> nil then
    FWorkTable.ResetHydraulicLine;
  if FCurrentStage in [msNone, msDone] then
  begin
    ProtocolManager.AddMessage(pcInfo, psMeasurement,
      'MeasurementStopRejected', 'Stop отклонён неактивным запуском',
      Format('Stage=%s; Reason=RunInactive',
        [MeasurementStateToString(FCurrentStage)]));
    Exit;
  end;
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
      FRequestStopCalled := True;
      FStopRequested := True;
      FRunResult := mrrCancelled;
      FDoneReason := mdrUserCancelled;
      ResetPointSetupState;
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

  ProtocolManager.AddMessage(pcAction, psMeasurement, 'MeasurementStopAccepted',
    'Принудительная остановка принята измерительным запуском',
    Format('Stage=%s; Reason=%s', [MeasurementStateToString(StageSnapshot),
      MeasurementStopReasonToString(ReasonSnapshot)]));

  // Navigation uses the stop machinery only to finish a physical operation;
  // it has already marked the point as skipped and must never cancel it.
  if ReasonSnapshot <> msrUserRollback then
    MarkCurrentPointCancelled(ReasonSnapshot);

  if not HasPhysicalMeasurementStarted and
     (StageSnapshot in [msSelectPoint, msSelectEtalon, msSetupPoint,
       msWaitPointSetup, msWaitStable, msWaitMeasureStart]) then
    ProtocolManager.AddMessage(pcState, psMeasurement,
      'MeasurementStageExecutionAborted', 'Выполнение подготовительной стадии прекращено',
      Format('Stage=%s; PointIndex=%d',
        [MeasurementStateToString(StageSnapshot), FCurrentPointIndex]));

  ProtocolManager.AddMessage(pcAction, psMeasurement, 'StopRequested',
    'Stop принят измерительным запуском',
    Format('Stage=%s; Reason=%s', [MeasurementStateToString(StageSnapshot),
      MeasurementStopReasonToString(ReasonSnapshot)]));

  AddDiagnosticEvent('RequestStop called');
  if StageSnapshot in [msWaitMeasureStart, msMeasure] then
  begin
    SetStage(msWaitMeasureStop);
  end
  else if not (StageSnapshot in [msNone, msDone, msSave, msResultsRead, msWaitMeasureStop]) then
    SetStage(msDone);
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
var
  TargetIndex: Integer;
begin
  TargetIndex := FindNextEnabledPointIndex(FCurrentPointIndex + 1);
  RequestPointNavigation('Next', TargetIndex);
end;

procedure TMeasurementRun.PreviousPoint;
var
  TargetIndex: Integer;
begin
  TargetIndex := FindPreviousEnabledPointIndex(FCurrentPointIndex - 1);
  RequestPointNavigation('Previous', TargetIndex);
end;

procedure TMeasurementRun.SelectForcedPoint;
begin
  // SetStage intentionally ignores a transition to the current stage.
  // Re-enter the one canonical point-selection routine instead.
  EnterSelectPoint;
end;

procedure TMeasurementRun.RequestPointNavigation(const ADirection: string;
  ATargetIndex: Integer);
var
  CurrentUUID, TargetUUID, RejectionReason, Route: string;
  PhysicalStarted: Boolean;
begin
  CurrentUUID := '';
  TargetUUID := '';
  if GetCurrentPoint <> nil then
    CurrentUUID := GetCurrentPoint.UUID;
  if (FPoints <> nil) and (ATargetIndex >= 0) and (ATargetIndex < FPoints.Count) and
     (FPoints[ATargetIndex] <> nil) then
    TargetUUID := FPoints[ATargetIndex].UUID;
  PhysicalStarted := HasPhysicalMeasurementStarted or WorkTableNeedsPhysicalStop;

  ProtocolManager.AddMessage(pcAction, psMeasurement,
    'MeasurementPointNavigationRequested', 'Запрошен переход между точками',
    Format('Direction=%s; CurrentStage=%s; CurrentPointIndex=%d; CurrentPointUUID=%s; TargetIndex=%d; TargetUUID=%s; PhysicalMeasureStarted=%s; StopRequested=%s; ForceNextPointBefore=%d',
      [ADirection, MeasurementStateToString(FCurrentStage), FCurrentPointIndex,
       CurrentUUID, ATargetIndex, TargetUUID, BoolToStr(PhysicalStarted, True),
       BoolToStr(FStopRequested, True), FForceNextPoint]));

  RejectionReason := '';
  if FCurrentStage in [msNone, msDone] then
    RejectionReason := 'RunInactive'
  else if FPoints = nil then
    RejectionReason := 'PointsNotAssigned'
  else if GetCurrentPoint = nil then
    RejectionReason := 'NoCurrentPoint'
  else if FForceNextPoint >= 0 then
    RejectionReason := 'NavigationAlreadyPending'
  else if ATargetIndex < 0 then
  begin
    if SameText(ADirection, 'Next') then
      RejectionReason := 'NoNextEnabledPoint'
    else
      RejectionReason := 'NoPreviousEnabledPoint';
  end
  else if (ATargetIndex >= FPoints.Count) or (FPoints[ATargetIndex] = nil) or
          (not FPoints[ATargetIndex].Enabled) or
          (FPoints[ATargetIndex].State = osDeleted) then
    RejectionReason := 'InvalidTargetIndex'
  else if ATargetIndex = FCurrentPointIndex then
    RejectionReason := 'SameTargetIndex';

  if RejectionReason <> '' then
  begin
    ProtocolManager.AddMessage(pcInfo, psMeasurement,
      'MeasurementPointNavigationRejected', 'Переход между точками отклонён',
      Format('Direction=%s; Reason=%s; Stage=%s; TargetIndex=%d',
        [ADirection, RejectionReason, MeasurementStateToString(FCurrentStage), ATargetIndex]));
    Exit;
  end;

  FForceNextPoint := ATargetIndex;
  SetStopReason(msrUserRollback);
  ResetPointSetupState;
  FAttempt := 0;

  if FCurrentStage in [msMeasure, msWaitMeasureStop, msResultsRead, msSave] then
  begin
    Route := 'StopThenSelect';
    if FCurrentStage in [msResultsRead, msSave] then
      Route := 'SaveThenSelect';
    FNextStageAfterSave := msSelectPoint;
    ProtocolManager.AddMessage(pcProc, psMeasurement,
      'MeasurementPointNavigationPrepared', 'Маршрут перехода подготовлен',
      Format('TargetIndex=%d; ForceNextPointAfter=%d; NextStageAfterSave=%s; Route=%s',
        [ATargetIndex, FForceNextPoint,
         MeasurementStateToString(FNextStageAfterSave), Route]));
    MarkCurrentPointSkipped(ADirection, ATargetIndex);
    ProtocolManager.AddMessage(pcProc, psMeasurement,
      'MeasurementPointNavigationStoppingCurrent',
      'Текущая физическая операция завершается штатно',
      Format('Stage=%s; TargetIndex=%d',
        [MeasurementStateToString(FCurrentStage), ATargetIndex]));
    RequestStop;
  end
  else
  begin
    Route := 'DirectSelect';
    FNextStageAfterSave := msNone;
    ProtocolManager.AddMessage(pcProc, psMeasurement,
      'MeasurementPointNavigationPrepared', 'Маршрут перехода подготовлен',
      Format('TargetIndex=%d; ForceNextPointAfter=%d; NextStageAfterSave=%s; Route=%s',
        [ATargetIndex, FForceNextPoint,
         MeasurementStateToString(FNextStageAfterSave), Route]));
    MarkCurrentPointSkipped(ADirection, ATargetIndex);
    if FWorkTable <> nil then
      FWorkTable.StopMonitor;
    if FCurrentStage = msSelectPoint then
      SelectForcedPoint
    else
      SetStage(msSelectPoint);
  end;

  ProtocolManager.AddMessage(pcState, psMeasurement,
    'MeasurementPointNavigationStageChanged', 'Стадия перехода обработана',
    Format('Stage=%s; TargetIndex=%d; Route=%s',
      [MeasurementStateToString(FCurrentStage), ATargetIndex, Route]));
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
        ResetPointSetupState;
        FCurrentPointIndex := -1;
        Start;
      end;
    mcNextPoint: NextPoint;
    mcPreviousPoint: PreviousPoint;
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
var
  AllowedMin: Double;
  AllowedMax: Double;
  RangeSource: string;
  Details: TStringBuilder;

  function BuildFlowDetails(const AReason: string): string;
  var
    J: Integer;
    DetailChannel: TChannel;
  begin
    Details := TStringBuilder.Create;
    try
      Details.AppendFormat('SetPoint validation failed: Index=%d; Name=%s; FlowRate=%.6f; PointQ=%.6f л/с; AllowedMin=%.6f л/с; AllowedMax=%.6f л/с; RangeSource=%s; Reason=%s',
        [FCurrentPointIndex, APoint.Name, APoint.FlowRate, APoint.Q, AllowedMin, AllowedMax, RangeSource, AReason]);
      if FWorkTable <> nil then
      begin
        if FWorkTable.FlowRate <> nil then
          Details.AppendFormat('; WorkTable.FlowRate.Min=%.6f; WorkTable.FlowRate.Max=%.6f',
            [FWorkTable.FlowRate.Min, FWorkTable.FlowRate.Max]);
        if FWorkTable.EtalonChannels <> nil then
          for J := 0 to FWorkTable.EtalonChannels.Count - 1 do
          begin
            DetailChannel := FWorkTable.EtalonChannels[J];
            if DetailChannel = nil then
              Continue;
            Details.AppendFormat('; Etalon[%d].Enabled=%s; Group=%d; QminWork=%.6f; QmaxWork=%.6f',
              [J, BoolToStr(DetailChannel.Enabled, True), DetailChannel.Group, DetailChannel.QMinWork, DetailChannel.QMaxWork]);
            if (DetailChannel.FlowMeter <> nil) and (DetailChannel.FlowMeter.Device <> nil) then
              Details.AppendFormat('; Etalon[%d].Name=%s; DeviceQmin=%.6f; DeviceQmax=%.6f',
                [J, DetailChannel.FlowMeter.Device.Name, DetailChannel.FlowMeter.Device.Qmin, DetailChannel.FlowMeter.Device.Qmax]);
          end;
      end;
      Result := Details.ToString;
    finally
      Details.Free;
    end;
  end;

begin
  AError := TErrorInfo.Empty(Integer(msSelectPoint));
  Result := Assigned(APoint) and Assigned(FWorkTable);
  if not Result then
  begin
    AError := BuildError(1000, 'Точка или рабочий стол не назначены');
    Exit;
  end;

  if APoint.Q > 0 then
  begin
    if FWorkTable.FlowRate = nil then
    begin
      AllowedMin := 0;
      AllowedMax := 0;
      RangeSource := 'WorkTable.FlowRate';
      AError := BuildError(1001, BuildFlowDetails('WorkTable.FlowRate=nil'));
      Exit(False);
    end;

    if FMode = mrmAutomatic then
    begin
      AllowedMin := 0;
      AllowedMax := FWorkTable.CalcEtalonFlowRateMax;
      RangeSource := 'AllEtalonChannelsAndGroups';
      if (AllowedMax > 0) and (APoint.Q > AllowedMax) then
      begin
        AError := BuildError(1001, BuildFlowDetails('PointQ > maximum flow of all available etalon channels/groups'));
        AddDiagnosticEvent(AError.Msg);
        Exit(False);
      end;
      AddDiagnosticEvent(Format('SetPoint validation: Index=%d; Name=%s; PointQ=%.6f л/с; AllowedMin=%.6f л/с; AllowedMax=%.6f л/с; RangeSource=%s; Result=True',
        [FCurrentPointIndex, APoint.Name, APoint.Q, AllowedMin, AllowedMax, RangeSource]));
    end
    else if (APoint.Q < FWorkTable.FlowRate.Min) or (APoint.Q > FWorkTable.FlowRate.Max) then
    begin
      AllowedMin := FWorkTable.FlowRate.Min;
      AllowedMax := FWorkTable.FlowRate.Max;
      RangeSource := 'WorkTable.FlowRate';
      if APoint.Q < AllowedMin then
        AError := BuildError(1001, BuildFlowDetails('PointQ < WorkTable.FlowRate.Min'))
      else
        AError := BuildError(1001, BuildFlowDetails('PointQ > WorkTable.FlowRate.Max'));
      AddDiagnosticEvent(AError.Msg);
      Exit(False);
    end;
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
    if FWorkTable <> nil then
    begin
      // Publish the selected automatic measurement point as the current
      // work-table task. CurrentPoint remains owned by TWorkTable.
      FWorkTable.MeasurementRunPointChanged(Self, Point, FCurrentPointIndex);
    end;
    Notify(Integer(mePointChanged), Point);
    AddDiagnosticEvent('SetPoint success: ' + BuildPointSelectionLog(Point));

  end else
  begin
    AddDiagnosticEvent('SetPoint failed: ' + AError.Msg);
  end;
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


function TMeasurementRun.GetRuntimeTargetFlowLS: Double;
begin
  Result := 0;
  if (FWorkTable <> nil) and (FWorkTable.FlowRate <> nil) and
     (FWorkTable.FlowRate.ValueSet <> nil) then
    Result := FWorkTable.FlowRate.ValueSet.Value;
end;

function TMeasurementRun.GetSelectedEtalonUUID: string;
var
  I: Integer;
  Channel: TChannel;
begin
  Result := '';
  if (FWorkTable = nil) or (FWorkTable.EtalonChannels = nil) then
    Exit;
  for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
  begin
    Channel := FWorkTable.EtalonChannels[I];
    if (Channel <> nil) and Channel.Enabled and (Channel.State <> osDeleted) then
      Exit(Channel.UUID);
  end;
end;

function TMeasurementRun.IsSetupPointSynchronized(out AReason: string): Boolean;
var
  Point: TDevicePoint;
  RuntimeTarget: Double;
begin
  Result := False;
  AReason := '';
  Point := GetCurrentPoint;
  if Point = nil then
    AReason := 'MeasurementRunPoint=nil'
  else if FWorkTable = nil then
    AReason := 'WorkTable=nil'
  else if not FPointSetupCommandSent then
    AReason := 'PointSetupCommandNotSent'
  else if FWorkTable.State <> swtMONITOR then
    AReason := 'WorkTableState=' + TWorkTable.WorkTableStateToString(FWorkTable.State)
  else if FCurrentPointIndex <> FSetupPointIndex then
    AReason := Format('MeasurementRunPointIndex=%d; SetupPointIndex=%d', [FCurrentPointIndex, FSetupPointIndex])
  else if Point.UUID <> FSetupPointUUID then
    AReason := Format('MeasurementRunPointUUID=%s; SetupPointUUID=%s', [Point.UUID, FSetupPointUUID])
  else if FWorkTable.InstalledMeasurementPointIndex <> FSetupPointIndex then
    AReason := Format('InstalledMeasurementPointIndex=%d; SetupPointIndex=%d', [FWorkTable.InstalledMeasurementPointIndex, FSetupPointIndex])
  else if FWorkTable.InstalledMeasurementPointUUID <> FSetupPointUUID then
    AReason := Format('InstalledMeasurementPointUUID=%s; SetupPointUUID=%s', [FWorkTable.InstalledMeasurementPointUUID, FSetupPointUUID])
  else if not SameValue(FWorkTable.InstalledMeasurementTargetFlowLS, FSetupTargetFlowLS, 1E-6) then
    AReason := Format('InstalledMeasurementTargetFlowLS=%.6f; SetupTargetFlowLS=%.6f', [FWorkTable.InstalledMeasurementTargetFlowLS, FSetupTargetFlowLS])
  else begin
    RuntimeTarget := GetRuntimeTargetFlowLS;
    if not SameValue(RuntimeTarget, FSetupTargetFlowLS, 1E-6) then
      AReason := Format('TargetFlowRuntimeLS=%.6f; TargetFlowSetupLS=%.6f', [RuntimeTarget, FSetupTargetFlowLS])
    else
      Result := True;
  end;

  if AReason <> '' then
    AReason := AReason + '; ' + BuildPointSetupIdentityLog;
end;

function TMeasurementRun.BuildPointSetupIdentityLog: string;
var
  Point: TDevicePoint;
  MeasurementUUID: string;
  RuntimeUUID: string;
  InstalledUUID: string;
  InstalledIndex: Integer;
  WorkTableStateText: string;
begin
  Point := GetCurrentPoint;
  MeasurementUUID := '';
  if Point <> nil then
    MeasurementUUID := Point.UUID;

  RuntimeUUID := '';
  InstalledUUID := '';
  InstalledIndex := -1;
  WorkTableStateText := '<nil>';
  if FWorkTable <> nil then
  begin
    InstalledUUID := FWorkTable.InstalledMeasurementPointUUID;
    InstalledIndex := FWorkTable.InstalledMeasurementPointIndex;
    WorkTableStateText := TWorkTable.WorkTableStateToString(FWorkTable.State);
    if FWorkTable.CurrentPoint <> nil then
      RuntimeUUID := FWorkTable.CurrentPoint.UUID;
  end;

  Result := Format('MeasurementRunPointIndex=%d; MeasurementRunPointUUID=%s; SetupPointIndex=%d; SetupPointUUID=%s; InstalledMeasurementPointIndex=%d; InstalledMeasurementPointUUID=%s; WorkTableRuntimePointUUID=%s; TargetFlowSetupLS=%.6f; TargetFlowRuntimeLS=%.6f; WorkTableState=%s',
    [FCurrentPointIndex, MeasurementUUID, FSetupPointIndex, FSetupPointUUID,
     InstalledIndex, InstalledUUID, RuntimeUUID, FSetupTargetFlowLS,
     GetRuntimeTargetFlowLS, WorkTableStateText]);
end;

function TMeasurementRun.HasNewTableFlowDataSince(const ATimeStampMs: Int64;
  out AFirstSampleTimeMs, ALastSampleTimeMs: Int64;
  out ASampleCount: Integer): Boolean;
var
  I: Integer;
  Samples: TArray<TMeterValueSample>;
begin
  Result := False;
  AFirstSampleTimeMs := 0;
  ALastSampleTimeMs := 0;
  ASampleCount := 0;
  if (FWorkTable = nil) or (FWorkTable.FlowRate = nil) or
     (FWorkTable.FlowRate.Value = nil) then
    Exit;
  Samples := FWorkTable.FlowRate.Value.GetStabilitySamples;
  for I := 0 to High(Samples) do
    if Samples[I].TimeStampMs > ATimeStampMs then
    begin
      Inc(ASampleCount);
      if (AFirstSampleTimeMs = 0) or (Samples[I].TimeStampMs < AFirstSampleTimeMs) then
        AFirstSampleTimeMs := Samples[I].TimeStampMs;
      if Samples[I].TimeStampMs > ALastSampleTimeMs then
        ALastSampleTimeMs := Samples[I].TimeStampMs;
      Result := True;
    end;
end;


procedure TMeasurementRun.ResetPointSetupState;
begin
  FPointSetupCommandSent := False;
  FSetupPointUUID := '';
  FSetupPointIndex := -1;
  FSetupTargetFlowLS := 0;
  FSetupStartedMs := 0;
  FStabilityDataStartMs := 0;
  FLastWaitPointSetupLogMs := 0;
  FLastWaitPointSetupLogState := swtNONE;
  FLastPointSetupReadyProtocolMs := -1;
  FPressureNotControlledLogged := False;
  FTemperatureNotControlledLogged := False;
end;

procedure TMeasurementRun.StartNewStabilityAttempt;
var
  I: Integer;
  Channel: TChannel;
begin
  FStabilityDataStartMs := TMeterValue.GetMonotonicTimeMs;
  FLastStabilityCheckSecond := -1;
  FStableSinceMs := 0;
  FDevicesStableSinceMs := 0;
  FLastDeviceStableStateKnown := False;
  FLastDeviceStableState := False;
  FLastStableProgressSecond := -1;
  if (FWorkTable <> nil) and (FWorkTable.EtalonChannels <> nil) then
    for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
    begin
      Channel := FWorkTable.EtalonChannels[I];
      if (Channel <> nil) and (Channel.FlowMeter <> nil) and (Channel.FlowMeter.ValueFlow <> nil) then
        Channel.FlowMeter.ValueFlow.ResetStabilityRuntimeState;
    end;
  // История поверяемых приборов не очищается даже при повторной подготовке
  // установки: msWaitStable должен продолжить анализ непрерывного окна сигнала.
end;

function TMeasurementRun.CalcStableTimeoutSec: Integer;
const
  SETUP_MARGIN_SEC = 5;
var
  I: Integer;
  Channel: TChannel;
  Settings: TMeterValueStabilitySettings;
  MinHistorySec, NeedSec: Double;

  procedure IncludeMeterValue(const AMeterValue: TMeterValue);
  begin
    if AMeterValue = nil then
      Exit;
    Settings := AMeterValue.StabilitySettings;
    MinHistorySec := Max(1, Settings.MaxSampleAgeSec);
    NeedSec := Ceil(MinHistorySec) + 1 + SETUP_MARGIN_SEC;
    if FRequiredDeviceStabilizationSec > 0 then
      NeedSec := NeedSec + FRequiredDeviceStabilizationSec;
    Result := Max(Result, Ceil(NeedSec));
  end;
begin
  Result := Ceil(Max(0.001, FRequiredDeviceStabilizationSec)) + 1 + SETUP_MARGIN_SEC;
  if FWorkTable = nil then
    Exit;

  if FWorkTable.EtalonChannels <> nil then
    for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
    begin
      Channel := FWorkTable.EtalonChannels[I];
      if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) then
        IncludeMeterValue(Channel.FlowMeter.ValueFlow);
    end;

  if FWorkTable.DeviceChannels <> nil then
    for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
    begin
      Channel := FWorkTable.DeviceChannels[I];
      if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) then
        IncludeMeterValue(Channel.FlowMeter.ValueFlow);
    end;
end;

procedure TMeasurementRun.ProcessStage;
begin
  AddWorkTableStateDiagnosticEvent;
  if IsStopRequested and not (FCurrentStage in [msWaitMeasureStop, msResultsRead, msSave, msDone]) then
  begin
    RouteStopInWorker;
    if FCurrentStage = msDone then
      Exit;
  end;
  case FCurrentStage of
    msSelectPoint: ProcessSelectPoint;
    msSelectEtalon: ProcessSelectEtalon;
    msSetupPoint: ProcessSetupPoint;
    msWaitPointSetup: ProcessWaitPointSetup;
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
const
  SELECTION_TIMEOUT_S = 30;
var
  Snapshot: TWorkTableHydraulicSnapshot;
  Error: TErrorInfo;
begin
  if (FWorkTable = nil) then Exit;
  Snapshot := FWorkTable.GetHydraulicLineSnapshot;
  case Snapshot.State of
    hlsSelecting:
      begin
        if TMeterValue.GetMonotonicTimeMs - FWaitStartedTick > SELECTION_TIMEOUT_S * 1000 then
        begin
          Error := BuildError(1101, 'Тайм-аут поиска гидравлической конфигурации');
          FWorkTable.FailHydraulicOperation(Snapshot.OperationID, Error);
          ContinueAfterPointError(mptsSetupError, meEtalonAbsent, Error);
        end;
        Exit;
      end;
    hlsSelected:
      begin FireEvent(meEtalonSelected); SetStage(msSetupPoint); end;
    hlsFailed:
      ContinueAfterPointError(mptsSetupError, meEtalonAbsent, Snapshot.Error);
    hlsSettingUp, hlsConfigured:
      SetStage(msSetupPoint);
  else
    ContinueAfterPointError(mptsSetupError, meEtalonAbsent,
      BuildError(1102, 'Несогласованное состояние выбора гидравлической линии'));
  end;
end;

procedure TMeasurementRun.ProcessSetupPoint;
var
  Snapshot: TWorkTableHydraulicSnapshot;
  OperationID: Int64;
  Error: TErrorInfo;
  Point: TDevicePoint;
begin
  if FMode = mrmManual then Exit;
  Point := GetCurrentPoint;
  Snapshot := FWorkTable.GetHydraulicLineSnapshot;
  case Snapshot.State of
    hlsSelected:
      begin
        if FPointSetupCommandSent then Exit;
        if not SetupMeasurement(Point, Error) then
        begin ContinueAfterPointError(mptsSetupError, mePointNotSet, Error); Exit; end;
        if not FWorkTable.BeginHydraulicLineSetup(OperationID, Error) then
        begin ContinueAfterPointError(mptsSetupError, mePointNotSet, Error); Exit; end;
        FPointSetupCommandSent := True;
        FSetupStartedMs := TMeterValue.GetMonotonicTimeMs;
        FireEvent(mePointSet);
        SetStage(msWaitPointSetup);
      end;
    hlsSettingUp:
      begin FPointSetupCommandSent := True; FSetupStartedMs := TMeterValue.GetMonotonicTimeMs; SetStage(msWaitPointSetup); end;
    hlsConfigured:
      begin FPointSetupCommandSent := True; SetStage(msWaitPointSetup); end;
    hlsFailed:
      ContinueAfterPointError(mptsSetupError, mePointNotSet, Snapshot.Error);
  else
    ContinueAfterPointError(mptsSetupError, mePointNotSet,
      BuildError(1202, 'Нарушена последовательность установки гидравлической линии'));
  end;
end;


/// <summary>
/// Ожидает готовность только испытательной установки. Тайм-аут этого этапа
/// критический: при непригодном расходе, эталоне или параметре среды измерение
/// не запускается и управление передаётся штатной обработке ошибки точки.
/// </summary>
procedure TMeasurementRun.ProcessWaitPointSetup;
const
  SETUP_TIMEOUT_S = 30;
var
  Reason: string;
  SetupInfo: RStableInfo;
  FirstSampleTimeMs: Int64;
  LastSampleTimeMs: Int64;
  FreshSampleCount: Integer;
  CurrentMs: Int64;
  FreshLog: string;
  Point: TDevicePoint;
  Error: TErrorInfo;
  Snapshot: TWorkTableHydraulicSnapshot;
  I: Integer;
  Channel: TChannel;
begin
  CurrentMs := TMeterValue.GetMonotonicTimeMs;
  Point := GetCurrentPoint;
  if FMode = mrmManual then
  begin
    SetStage(msWaitMeasureStart);
    Exit;
  end;

  if FWorkTable = nil then
  begin
    ContinueAfterPointError(mptsSetupError, mePointNotSet, BuildError(1210, 'Рабочий стол не назначен'));
    Exit;
  end;

  if IsStopRequested then
  begin
    SetStopReason(msrCancelledBeforeStart);
    SetCurrentPointStatus(mptsCancelled);

    ProtocolManager.AddMessage(pcProc, psMeasurement,
      'ProcessWaitPointSetup',
      'Ожидание установки точки отменено пользователем',
      Format('PointIndex=%d; WaitMs=%d',
        [FCurrentPointIndex,
         TMeterValue.GetMonotonicTimeMs - FSetupStartedMs]));

    SetStage(msDone);
    Exit;
  end;



  Snapshot := FWorkTable.GetHydraulicLineSnapshot;
  case Snapshot.State of
    hlsSettingUp:
      begin
        if (FSetupStartedMs > 0) and (CurrentMs - FSetupStartedMs > SETUP_TIMEOUT_S * 1000) then
        begin
          Error := BuildError(1214, 'Тайм-аут физической установки гидравлической линии');
          FWorkTable.FailHydraulicOperation(Snapshot.OperationID, Error);
          ContinueAfterPointError(mptsSetupError, mePointNotSet, Error);
        end;
        Exit;
      end;
    hlsFailed:
      begin ContinueAfterPointError(mptsSetupError, mePointNotSet, Snapshot.Error); Exit; end;
    hlsConfigured:
      if FStabilityDataStartMs = 0 then
      begin
        FSetupStartedMs := CurrentMs;
        FStabilityDataStartMs := CurrentMs;
        if (FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.Value <> nil) then
        begin
          ConfigureStabilityByPoint(FWorkTable.FlowRate.Value, Point);
          ConfigureTargetRangeByPoint(FWorkTable.FlowRate.Value, Point, True, True);
          FWorkTable.FlowRate.Value.ResetStabilityRuntimeState;
          LogPointSetupValueConfigured('TableFlow', FWorkTable.FlowRate.Value);
        end;
        if FWorkTable.DeviceChannels <> nil then
          for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
          begin
            Channel := FWorkTable.DeviceChannels[I];
            if (Channel <> nil) and (Channel.FlowMeter <> nil) and
               (Channel.FlowMeter.ValueFlow <> nil) then
              Channel.FlowMeter.ValueFlow.ResetStabilityRuntimeState;
          end;
      end;
  else
    ContinueAfterPointError(mptsSetupError, mePointNotSet,
      BuildError(1215, 'Гидравлическая линия не готова к ожиданию стабилизации'));
    Exit;
  end;

  if FWorkTable.State <> swtMONITOR then
  begin
    if (FSetupStartedMs > 0) and (CurrentMs - FSetupStartedMs > SETUP_TIMEOUT_S * 1000) then
    begin
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
        'Тайм-аут запуска мониторинга', Format('PointSetupTimeout: PointIndex=%d; PointName=%s; ElapsedMs=%d; TimeoutMs=%d; FreshDataReady=False; TableFlowAvailable=%s; TableFlowReady=False; ConditionsReady=False; Reason=Мониторинг не запущен (%s); Action=ContinueAfterPointError',
        [FCurrentPointIndex, Point.Name, CurrentMs - FSetupStartedMs,
         SETUP_TIMEOUT_S * 1000,
         BoolToStr((FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.Value <> nil), True),
         TWorkTable.WorkTableStateToString(FWorkTable.State)]));
      ContinueAfterPointError(mptsSetupError, mePointNotSet, BuildError(1211,
        'Мониторинг не запустился после установки точки'));
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
        'Тайм-аут обработан', Format('PointSetupTimeoutHandled: PointStatus=%d; MeasurementError=%s; NextStage=%s; ContinueMeasurement=%s',
        [Ord(mptsSetupError), 'Мониторинг не запустился', MeasurementStateToString(FCurrentStage), BoolToStr(FCurrentStage <> msDone, True)]));
    end
    else
      if (FLastWaitPointSetupLogState <> FWorkTable.State) or (CurrentMs - FLastWaitPointSetupLogMs >= 1000) then
      begin
        FLastWaitPointSetupLogState := FWorkTable.State;
        FLastWaitPointSetupLogMs := CurrentMs;
        AddDiagnosticEvent('WaitPointSetup: waiting swtMONITOR; ' + BuildPointSetupIdentityLog);
      end;
    Exit;
  end;

  if not IsSetupPointSynchronized(Reason) then
  begin
    AddDiagnosticEvent('PointSetup desync: ' + Reason);
    ContinueAfterPointError(mptsSetupError, mePointNotSet, BuildError(1212,
      'Рассинхронизация установленной точки: ' + Reason));
    Exit;
  end;

  if not HasNewTableFlowDataSince(FSetupStartedMs, FirstSampleTimeMs,
    LastSampleTimeMs, FreshSampleCount) then
  begin
    if CurrentMs - FLastFreshDataLogMs >= 2000 then
    begin
      FLastFreshDataLogMs := CurrentMs;
      FreshLog := Format('PointSetupFreshData: Ready=False; CheckedSource=TableFlow; SinceMs=%d; FirstFreshSampleMs=0; LastFreshSampleMs=0; SampleCount=0; WaitMs=%d',
        [FSetupStartedMs, CurrentMs - FSetupStartedMs]);
      AddDiagnosticEvent(FreshLog);
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
        'Ожидание новых данных после установки точки', FreshLog);
    end;
    if CurrentMs - FSetupStartedMs > SETUP_TIMEOUT_S * 1000 then
    begin
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
        'Тайм-аут ожидания данных расхода стола',
        Format('PointSetupTimeout: PointIndex=%d; PointName=%s; ElapsedMs=%d; TimeoutMs=%d; FreshDataReady=False; TableFlowAvailable=%s; TableFlowReady=False; ConditionsReady=False; Reason=Нет свежих данных расхода стола; Action=ContinueAfterPointError',
          [FCurrentPointIndex, Point.Name, CurrentMs - FSetupStartedMs,
           SETUP_TIMEOUT_S * 1000,
           BoolToStr((FWorkTable.FlowRate <> nil) and
             (FWorkTable.FlowRate.Value <> nil), True)]));
      ContinueAfterPointError(mptsStabilityError, meStableTimeout,
        BuildError(1213, 'Нет свежих данных расхода стола'));
    end;
    Exit;
  end;

  if FLastFreshDataLogMs <> -1 then
  begin
    FreshLog := Format('PointSetupFreshData: Ready=True; CheckedSource=TableFlow; SinceMs=%d; FirstFreshSampleMs=%d; LastFreshSampleMs=%d; SampleCount=%d; WaitMs=%d',
      [FSetupStartedMs, FirstSampleTimeMs, LastSampleTimeMs,
       FreshSampleCount, CurrentMs - FSetupStartedMs]);
    AddDiagnosticEvent(FreshLog);
    ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
      'Получены новые данные после установки точки', FreshLog);
    FLastFreshDataLogMs := -1;
  end;

  // Анализ новой точки начинается с её первой свежей пробы.
  if (FStabilityDataStartMs = FSetupStartedMs) and (FirstSampleTimeMs > 0) then
    FStabilityDataStartMs := FirstSampleTimeMs;

  if not IsPointSetupReady(SetupInfo) then
  begin
    if CurrentMs - FSetupStartedMs > SETUP_TIMEOUT_S * 1000 then
    begin
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
        'Тайм-аут стабилизации установки', Format('PointSetupTimeout: PointIndex=%d; PointName=%s; ElapsedMs=%d; TimeoutMs=%d; FreshDataReady=True; TableFlowAvailable=%s; TableFlowReady=%s; ConditionsReady=%s; Reason=%s; Action=ContinueAfterPointError',
        [FCurrentPointIndex, Point.Name, CurrentMs - FSetupStartedMs,
         SETUP_TIMEOUT_S * 1000,
         BoolToStr((FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.Value <> nil), True),
         BoolToStr((FWorkTable.FlowRate <> nil) and (FWorkTable.FlowRate.Value <> nil) and
           FWorkTable.FlowRate.Value.LastStabilityInfo.IsSuitableForMeasurement, True),
         BoolToStr(FLastTemperatureReady and FLastPressureReady, True), SetupInfo.StatusText]));
      ContinueAfterPointError(mptsStabilityError, meStableTimeout, BuildError(1213,
        'Установка не достигла стабильности или диапазона: ' + SetupInfo.StatusText));
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
        'Тайм-аут обработан', Format('PointSetupTimeoutHandled: PointStatus=%d; MeasurementError=%s; NextStage=%s; ContinueMeasurement=%s',
        [Ord(mptsStabilityError), SetupInfo.StatusText, MeasurementStateToString(FCurrentStage), BoolToStr(FCurrentStage <> msDone, True)]));
    end;
    Exit;
  end;
  AddDiagnosticEvent(Format(
    'PointSetupConfirmed: WaitMs=%d; ActualFlowLS=%.6f; WorkTableState=%s; FirstSampleTimeMs=%d; StabilityDataStartMs=%d',
    [CurrentMs - FSetupStartedMs, GetRuntimeTargetFlowLS,
     TWorkTable.WorkTableStateToString(FWorkTable.State), FirstSampleTimeMs, FStabilityDataStartMs]));
  ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitPointSetup',
    'Установка готова; переход к ожиданию приборов',
    Format('PointSetupCompleted: PointIndex=%d; PointName=%s; Result=Ready; WaitMs=%d; TableFlowReady=True; ConditionsReady=True; NextStage=msWaitStable',
      [FCurrentPointIndex, Point.Name, CurrentMs - FSetupStartedMs]));
  SetStage(msWaitStable);
end;

/// <summary>
/// Обрабатывает независимые ожидания всех поверяемых каналов.
/// </summary>
/// <remarks>
/// Фиксированный режим является простой выдержкой от StartedAtMs и никогда не
/// сбрасывается из-за колебаний сигнала. Автоматический режим проверяет только
/// IsSignalStable; целевой диапазон для прибора отключён при входе в состояние.
/// Автоматический тайм-аут сохраняется как dsrAutoTimeout и является конечным,
/// но некритическим результатом, поэтому не препятствует запуску измерения.
/// </remarks>
procedure TMeasurementRun.ProcessWaitStable;
var
  I: Integer;
  CurrentTick, ElapsedMs: UInt64;
  SignalInfo: TMeterValueStabilityInfo;
  AllCompleted, IsAuto, PublishProgress: Boolean;
  LogText, DecisionReason: string;
  FixedCount, StableCount, TimeoutCount, PendingCount, CompletedCount: Integer;
begin
  if FMode = mrmManual then
  begin
    SetStage(msWaitMeasureStart);
    Exit;
  end;
  CurrentTick := TMeterValue.GetMonotonicTimeMs;
  AllCompleted := True;
  for I := 0 to High(FDeviceStability) do
  begin
    if FDeviceStability[I].Result <> dsrWaiting then
      Continue;
    AllCompleted := False;
    ElapsedMs := CurrentTick - FDeviceStability[I].StartedAtMs;
    IsAuto := FDeviceStability[I].TimeoutSec > 0;
    // Каждый канал имеет собственный секундный ограничитель публикации.
    PublishProgress := (FDeviceStability[I].LastProgressLogTick = 0) or
      (CurrentTick - FDeviceStability[I].LastProgressLogTick >= 1000);
    if not IsAuto then
    begin
      if ElapsedMs >= Round(FDeviceStability[I].RequiredTimeSec * 1000) then
      begin
        FDeviceStability[I].Result := dsrFixedTimeCompleted;
        FDeviceStability[I].CompletedAtMs := CurrentTick;
        FDeviceStability[I].DiagnosticText := 'Fixed time completed';
      end;
      if PublishProgress then
      begin
        LogText := Format('DeviceStabilityProgress: ChannelName=%s; DevicePointName=%s; Mode=FixedTime; RequiredSec=%.3f; ElapsedSec=%.3f; RemainingSec=%.3f; Completed=%s',
          [FDeviceStability[I].Channel.Name, FDeviceStability[I].DevicePoint.Name,
           FDeviceStability[I].RequiredTimeSec, ElapsedMs / 1000,
           Max(0.0, FDeviceStability[I].RequiredTimeSec - ElapsedMs / 1000),
           BoolToStr(FDeviceStability[I].Result = dsrFixedTimeCompleted, True)]);
        ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitStable',
          'Ход ожидания фиксированного времени', LogText);
      end;
    end
    else
    begin
      // Используем всё уже накопленное окно TMeterValue. Временная отметка
      // входа в состояние нужна только таймеру канала и не является нижней
      // границей выборки анализа.
      FDeviceStability[I].Value.AnalyzeStabilityForMeasurement(SignalInfo);
      if SignalInfo.IsSignalStable then
      begin
        FDeviceStability[I].Result := dsrAutoStable;
        FDeviceStability[I].CompletedAtMs := CurrentTick;
        FDeviceStability[I].DiagnosticText := SignalInfo.StatusText;
      end
      else if ElapsedMs >= Round(FDeviceStability[I].TimeoutSec * 1000) then
      begin
        FDeviceStability[I].Result := dsrAutoTimeout;
        FDeviceStability[I].CompletedAtMs := CurrentTick;
        FDeviceStability[I].DiagnosticText := SignalInfo.StatusText;
        ProtocolManager.AddMessage(pcWarning, psMeasurement, 'DeviceStabilityTimeout',
          'Прибор не достиг стабильности за установленное время. Измерение будет продолжено.',
          Format('Channel=%s; Point=%s; Reason=%s',
            [FDeviceStability[I].Channel.Name, FDeviceStability[I].DevicePoint.Name,
             SignalInfo.StatusText]));
      end;
      LogText := Format('DeviceStabilityProgress: ChannelName=%s; DevicePointName=%s; Mode=Automatic; ElapsedSec=%.3f; TimeoutSec=%.3f; SampleCount=%d; WindowDurationSec=%.3f; IsSignalStable=%s; Variation=%.9f; MaxVariation=%.9f; StdDeviation=%.9f; MaxStdDeviation=%.9f; TrendRate=%.9f; MaxTrendRate=%.9f; OutlierRatio=%.9f; MaxOutlierRatio=%.9f; Completed=%s; Reason=%s',
        [FDeviceStability[I].Channel.Name, FDeviceStability[I].DevicePoint.Name,
         ElapsedMs / 1000,
         FDeviceStability[I].TimeoutSec, SignalInfo.UsedSampleCount,
         SignalInfo.ActualWindowDurationSec, BoolToStr(SignalInfo.IsSignalStable, True),
         SignalInfo.Variation,
         FDeviceStability[I].Value.StabilitySettings.MaxVariation,
         SignalInfo.StdDeviation, FDeviceStability[I].Value.StabilitySettings.MaxStdDeviation,
         SignalInfo.TrendRate, FDeviceStability[I].Value.StabilitySettings.MaxTrendRate,
         SignalInfo.OutlierFraction, FDeviceStability[I].Value.StabilitySettings.MaxOutlierFraction,
         BoolToStr(FDeviceStability[I].Result <> dsrWaiting, True), SignalInfo.StatusText]);
      AddDiagnosticEvent(LogText);
      if PublishProgress then
        ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitStable',
          'Проверка стабильности поверяемого прибора', LogText);
    end;
    if PublishProgress then
      FDeviceStability[I].LastProgressLogTick := CurrentTick;
    if FDeviceStability[I].Result <> dsrWaiting then
    begin
      LogText := Format('DeviceStabilityCompleted: ChannelName=%s; ChannelUUID=%s; DeviceName=%s; DevicePointName=%s; DevicePointUUID=%s; Mode=%s; RequiredSec=%.3f; ActualWaitSec=%.3f; TimeoutSec=%.3f; IsSignalStable=%s; Result=%s; MeasurementWillContinue=True; Reason=%s',
        [FDeviceStability[I].Channel.Name, FDeviceStability[I].Channel.UUID,
         FDeviceStability[I].Channel.FlowMeter.Name,
         FDeviceStability[I].DevicePoint.Name, FDeviceStability[I].DevicePoint.UUID,
         IfThen(IsAuto, 'Automatic', 'FixedTime'),
         FDeviceStability[I].RequiredTimeSec, ElapsedMs / 1000,
         FDeviceStability[I].TimeoutSec,
         BoolToStr(FDeviceStability[I].Result = dsrAutoStable, True),
         IfThen(FDeviceStability[I].Result = dsrFixedTimeCompleted, 'FixedTimeCompleted',
           IfThen(FDeviceStability[I].Result = dsrAutoStable, 'SignalStable', 'AutoStabilityTimeout')),
         FDeviceStability[I].DiagnosticText]);
      AddDiagnosticEvent(LogText);
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitStable',
        'Завершено ожидание поверяемого прибора', LogText);
    end;
  end;
  AllCompleted := True;
  PendingCount := 0;
  for I := 0 to High(FDeviceStability) do
    if FDeviceStability[I].Result = dsrWaiting then
    begin
      AllCompleted := False;
      Inc(PendingCount);
    end;
  FixedCount := 0; StableCount := 0; TimeoutCount := 0;
  for I := 0 to High(FDeviceStability) do
    case FDeviceStability[I].Result of
      dsrFixedTimeCompleted: Inc(FixedCount);
      dsrAutoStable: Inc(StableCount);
      dsrAutoTimeout: Inc(TimeoutCount);
    end;
  CompletedCount := FixedCount + StableCount + TimeoutCount;
  if not AllCompleted then
  begin
    if (FLastDeviceStabilityLogTick = 0) or
       (CurrentTick - FLastDeviceStabilityLogTick >= 1000) then
    begin
      ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitStable',
        'Итоговое решение ожидания поверяемых приборов',
        Format('DeviceStabilityDecision: DeviceChannelCount=%d; EnabledDeviceCount=%d; ConfiguredDeviceCount=%d; PendingDeviceCount=%d; CompletedDeviceCount=%d; SkippedDeviceCount=%d; FixedTimeCompletedCount=%d; AutoStableCount=%d; AutoTimeoutCount=%d; AllDevicesConfigured=%s; AllDevicesCompleted=False; MeasurementWillStart=False; NextStage=msWaitStable; Reason=Ожидание стабилизации настроенных приборов продолжается',
          [FStabilityDeviceChannelCount, FStabilityEnabledDeviceCount,
           Length(FDeviceStability), PendingCount, CompletedCount,
           FStabilitySkippedDeviceCount, FixedCount, StableCount, TimeoutCount,
           BoolToStr(FStabilityEnabledDeviceCount = Length(FDeviceStability), True)]));
      FLastDeviceStabilityLogTick := CurrentTick;
    end;
    Exit;
  end;
  if (FStabilityEnabledDeviceCount > 0) and (Length(FDeviceStability) = 0) then
    DecisionReason := 'Ни один включённый прибор не был добавлен в ожидание стабилизации'
  else if FStabilityPointResolvedCount < FStabilityEnabledDeviceCount then
    DecisionReason := 'Не для всех включённых приборов найдены поверочные точки'
  else
    DecisionReason := 'Все настроенные приборы завершили ожидание';
  ProtocolManager.AddMessage(pcProc, psMeasurement, 'ProcessWaitStable',
    'Итог ожидания поверяемых приборов',
    Format('DeviceStabilityDecision: DeviceChannelCount=%d; EnabledDeviceCount=%d; ConfiguredDeviceCount=%d; PendingDeviceCount=0; CompletedDeviceCount=%d; SkippedDeviceCount=%d; FixedTimeCompletedCount=%d; AutoStableCount=%d; AutoTimeoutCount=%d; AllDevicesConfigured=%s; AllDevicesCompleted=%s; MeasurementWillStart=True; NextStage=msWaitMeasureStart; Reason=%s',
      [FStabilityDeviceChannelCount, FStabilityEnabledDeviceCount,
       Length(FDeviceStability), CompletedCount, FStabilitySkippedDeviceCount,
       FixedCount, StableCount, TimeoutCount,
       BoolToStr(FStabilityEnabledDeviceCount = Length(FDeviceStability), True),
       BoolToStr((Length(FDeviceStability) > 0) and
         (CompletedCount = Length(FDeviceStability)), True), DecisionReason]));
  FireEvent(meStableReached);
  SetStage(msWaitMeasureStart);
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
    swtFAILURE:
      begin
        ContinueAfterPointError(mptsMeasureError, meMeasureError, BuildError(1402, 'Ошибка запуска измерения'));
        Exit;
      end;
  end;
   timeout := (TMeterValue.GetMonotonicTimeMs - FWaitStartedTick)/1000;
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

  if Int64(TMeterValue.GetMonotonicTimeMs - FWaitStartedTick) > Int64(FMeasureTimeout) * 1000 then
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
            'Физическая остановка завершена; доступный результат передаётся в msSave',
            MeasurementStopReasonToString(GetStopReason));
          // После физического старта не завершаем процесс досрочно:
          // пользователь должен принять решение о сохранении результата в msSave.
          MarkInterruptedPointIfNeeded;
        end;
        if IsStopRequested and not HasPhysicalMeasurementStarted then
        begin
          // При Stop до физического старта сохранять нечего — оставляем штатную отмену.
          FinalizeMeasurementRun(mrrCancelled, mdrUserCancelled);
          Exit;
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

  if (TMeterValue.GetMonotonicTimeMs - FWaitStartedTick) > DEFAULT_STOP_TIMEOUT_MS then
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
        if IsStopRequested and HasPhysicalMeasurementStarted then
        begin
          ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessResultsRead',
            'Результат прерванного после физического старта измерения прочитан и передаётся в msSave',
            MeasurementStopReasonToString(GetStopReason));
          // Досрочное завершение отменено: решение о сохранении доступного
          // результата принимает пользователь в штатном ProcessSave.
          MarkInterruptedPointIfNeeded;
        end;
        if IsStopRequested and not HasPhysicalMeasurementStarted then
        begin
          // Защитная ветка сохраняет отмену без msSave, если физического старта не было.
           ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessResultsRead',
            'Защитная ветка сохраняет отмену без msSave, если физического старта не было.',
            MeasurementStopReasonToString(GetStopReason));

          FinalizeMeasurementRun(mrrCancelled, mdrUserCancelled);
          Exit;
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

  if (TMeterValue.GetMonotonicTimeMs - FWaitStartedTick) > DEFAULT_STOP_TIMEOUT_MS then
  begin
    ContinueAfterPointError(mptsMeasureError, meMeasureTimeout, BuildError(1411, 'Таймаут чтения результатов'));
  end;
end;

procedure TMeasurementRun.ProcessSave;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
  IsLastRepeat: Boolean;
  SavedRepeat: Integer;
  ResultsSaved: Boolean;
begin
  // Одиночное ручное измерение остаётся в msSave до решения пользователя.
  if RequiresSaveConfirmation then
    case FSaveConfirmationResult of
      scrNone:
        begin
          if (FWorkTable <> nil) and
             (FWorkTable.State <> swtSaveConfirmation) then
          begin
            FWorkTable.State := swtSaveConfirmation;
            ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessSave',
              'Стол ожидает подтверждения сохранения результата',
              MeasurementStateToString(FCurrentStage));
          end;
          Exit;
        end;
      scrAccepted:
        ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessSave',
          'Сохранение результата после подтверждения пользователя', '');
      scrRejected:
        ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessSave',
          'Сохранение результата пропущено после отказа пользователя', '');
    end
  else
    ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessSave',
      'Автоматическое сохранение результата без подтверждения', '');

  ResultsSaved := not RequiresSaveConfirmation or
    (FSaveConfirmationResult = scrAccepted);

  if ResultsSaved then
  begin
    SaveMeasurementResults;
    FLastSaveDoneEventSent := True;
    FireEvent(meSaveDone);
  end;

  Point := GetCurrentPoint;
  if (FForceNextPoint >= 0) and (FNextStageAfterSave = msSelectPoint) then
  begin
    MarkInterruptedPointIfNeeded;
    // Navigation uses RequestStop only to finish the current physical
    // operation. It must not finalize the complete measurement run.
    FStopRequested := False;
    FPhysicalStopRequested := False;
    FRunResult := mrrNone;
    FDoneReason := mdrNone;
    SetStage(msSelectPoint);
    Exit;
  end;
  if IsStopRequested then
  begin
    MarkInterruptedPointIfNeeded;
    ProtocolManager.AddMessage(pcInfo, psMeasurement, 'ProcessSave',
      'После Stop продолжение серии запрещено',
      Format('Stage=%s; Reason=%s', [MeasurementStateToString(FCurrentStage),
        MeasurementStopReasonToString(GetStopReason)]));
    FNextStageAfterSave := msDone;
    SetStage(FNextStageAfterSave);
    Exit;
  end;

  RepeatsTarget := 1;
  if Point <> nil then
    RepeatsTarget := Max(Point.Repeats, 1);
  Inc(FCurrentRepeat);
  IsLastRepeat := FCurrentRepeat >= RepeatsTarget;
  SavedRepeat := FCurrentRepeat;

  if IsLastRepeat then
  begin
    if Point <> nil then
    begin
      FLastProcessedPointIndex := FCurrentPointIndex;
      FLastProcessedPointName := Point.Name;
      // Отказ завершает обработку точки, но не помечает её как сохранённую.
      if ResultsSaved then
        SetCurrentPointStatus(mptsSaved);
    end;
    FCurrentRepeat := 0;
    FLastPointDoneEventSent := True;
    AddDiagnosticEvent('mePointDone');
    FireEvent(mePointDone);
    if FMode = mrmManual then
      FNextStageAfterSave := msDone
    else if FindNextEnabledPointIndex(FCurrentPointIndex + 1) < 0 then
      FNextStageAfterSave := msDone
    else
      FNextStageAfterSave := msSelectPoint;
  end
  else
    FNextStageAfterSave := msWaitMeasureStart;

  AddDiagnosticEvent(Format(
    'RepeatTransition: PointName=%s; CurrentRepeat=%d; RepeatsTarget=%d; IsLastRepeat=%s; NextStage=%s; StabilizationSkipped=%s',
    [IfThen(Point <> nil, Point.Name, '<none>'), SavedRepeat, RepeatsTarget,
     BoolToStr(IsLastRepeat, True), MeasurementStateToString(FNextStageAfterSave),
     BoolToStr(FNextStageAfterSave = msWaitMeasureStart, True)]));
  SetStage(FNextStageAfterSave);
end;

function TMeasurementRun.RequiresSaveConfirmation: Boolean;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
begin
  Point := GetCurrentPoint;
  RepeatsTarget := 1;
  if Point <> nil then
    RepeatsTarget := Max(Point.Repeats, 1);

  // Подтверждение требуется только для одного повтора в ручном режиме.
  Result := (FMode = mrmManual) and (RepeatsTarget = 1);
end;

procedure TMeasurementRun.AcceptMeasurementResults;
begin
  // Метод фиксирует решение; сохранение выполнит следующий ProcessSave.
  if (FCurrentStage <> msSave) or not RequiresSaveConfirmation or
     (FSaveConfirmationResult <> scrNone) then
    Exit;
  FSaveConfirmationResult := scrAccepted;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'AcceptResults',
    'Пользователь подтвердил сохранение результата измерения', '');
end;

procedure TMeasurementRun.RejectMeasurementResults;
begin
  // Метод фиксирует решение; завершение обработки выполнит ProcessSave.
  if (FCurrentStage <> msSave) or not RequiresSaveConfirmation or
     (FSaveConfirmationResult <> scrNone) then
    Exit;
  FSaveConfirmationResult := scrRejected;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'RejectResults',
    'Пользователь отказался от сохранения результата измерения', '');
end;

procedure TMeasurementRun.ProcessDone;
begin
  // Completion actions are performed once in EnterDone.
end;


procedure TMeasurementRun.SaveMeasurementResults;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
  I: Integer;
  Device: TDevice;
  TotalBefore: Integer;
  TotalAfter: Integer;
  PerDevice: TStringBuilder;
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

  TotalBefore := 0;
  TotalAfter := 0;
  PerDevice := TStringBuilder.Create;
  try
    try
      RepeatsTarget := Max(Point.Repeats, 1);

      if (FWorkTable <> nil) and (FWorkTable.DeviceChannels <> nil) then
        for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
          if (FWorkTable.DeviceChannels[I] <> nil) and
             (FWorkTable.DeviceChannels[I].FlowMeter <> nil) then
          begin
            Device := FWorkTable.DeviceChannels[I].FlowMeter.Device;
            if (Device <> nil) and (Device.Spillages <> nil) then
              Inc(TotalBefore, Device.Spillages.Count);
          end;

      if FWorkTable <> nil then
      begin
        FWorkTable.RecalculateAllMeterValues;
        // Берем сохраненное  TimeResult
       { if FWorkTable.ValueTime <> nil then
          FWorkTable.TimeResult := FWorkTable.ValueTime.GetDoubleValue
        else
          FWorkTable.TimeResult := Point.LimitTime;}
      end;

      WorkTable.SaveMeasurementResults;

      if (FWorkTable <> nil) and (FWorkTable.DeviceChannels <> nil) then
        for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
          if (FWorkTable.DeviceChannels[I] <> nil) and
             (FWorkTable.DeviceChannels[I].FlowMeter <> nil) then
          begin
            Device := FWorkTable.DeviceChannels[I].FlowMeter.Device;
            if (Device <> nil) and (Device.Spillages <> nil) then
            begin
              Inc(TotalAfter, Device.Spillages.Count);
              if PerDevice.Length > 0 then
                PerDevice.Append('; ');
              PerDevice.AppendFormat('DeviceUUID=%s; DeviceName=%s; Results=%d',
                [Device.UUID, Device.Name, Device.Spillages.Count]);
            end;
          end;

      FLastResultsAddedToProcessing := Max(0, TotalAfter - TotalBefore);
      FLastResultsPerDevice := PerDevice.ToString;

      if DataManager <> nil then
        DataManager.Save;

      if WorkTableManager <> nil then
        WorkTableManager.Save;

      Point.RepeatsCompleted := Min(RepeatsTarget, FCurrentRepeat + 1);
      Point.DateTime := Now;
      FLastSaveMeasurementResultsResult := 'success';
      AddDiagnosticEvent(Format('SaveMeasurementResults success; ResultsAdded=%d; %s',
        [FLastResultsAddedToProcessing, FLastResultsPerDevice]));
    except
      on E: Exception do
      begin
        FLastSaveMeasurementResultsResult := 'failed';
        FLastSaveErrorText := E.Message;
        AddDiagnosticEvent('SaveMeasurementResults failed: ' + E.Message);
        raise;
      end;
    end;
  finally
    PerDevice.Free;
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

  if (S = 'ожидание установки точки') or (S = 'mswaitpointsetup') then
    Exit(msWaitPointSetup);

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
    msWaitPointSetup:   Result := 'Ожидание установки точки';
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
    msrUserRollback: Result := 'отмена результатов пользователем';
  else
    Result := 'неизвестная причина';
  end;
end;

class function TMeasurementRun.MeasurementPointStatusToString(
  AStatus: EMeasurementPointStatus): string;
begin
  case AStatus of
    mptsSkipped: Result := 'Пропущена';
    mptsCancelled: Result := 'Отменено';
  else
    Result := GetEnumName(TypeInfo(EMeasurementPointStatus), Ord(AStatus));
  end;
end;

end.
