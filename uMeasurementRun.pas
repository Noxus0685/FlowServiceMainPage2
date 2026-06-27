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
    meAllDone
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
    FCurrentRepeat: Integer;
    FIsPaused: Boolean;
    FForceNextPoint: Integer;
    FAttempt: Integer;
    FMaxAttemptCount: Integer;
    FMeasureTimeout: Cardinal;
    FStopRequested: Boolean;
    FNextStageAfterSave: EMeasurementState;

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
    procedure RequestStop;
    procedure StopWorkerThread;
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
    function BuildError(ACode: Integer; const AMsg: string): TErrorInfo;
    function ValidatePoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function SetPoint(Index: Integer; out AError: TErrorInfo): Boolean;
    function SelectEtalons(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function BuildPointSelectionLog(APoint: TDevicePoint): string;
    function BuildEtalonSelectionLog(APoint: TDevicePoint): string;
    function CalcMeasureTimeout(APoint: TDevicePoint): Cardinal;
    function SetupPoint(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function SetupMeasurement(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
    function ShouldUseAllPoints: Boolean;
    function ShouldSetupConditions: Boolean;
    function ShouldWaitStable: Boolean;
    function ShouldSelectEtalon: Boolean;
    function CreateSingleSessionPoint(AWithConditions: Boolean): TDevicePoint;

    procedure RunThreadProc;
    function IsThreadRunning: Boolean;

    function IsStable(out StableInfo: RStableInfo): Boolean;
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

    property ManualFlowRate: Double read FManualFlowRate write FManualFlowRate;
    property ManualFluidTemp: Double read FManualFluidTemp write FManualFluidTemp;
    property ManualFluidPress: Double read FManualFluidPress write FManualFluidPress;
    property ManualTimeSet: Integer read FManualTimeSet write FManualTimeSet;

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
  FNextStageAfterSave := msNone;
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
  DetailsText: string;
  EtalonName: string;
  Accuracy: string;
begin
  if (APoint = nil) or (FWorkTable = nil) then
    Exit('Эталоны не выбраны');

  Details := TStringList.Create;
  try
    for I := 0 to FWorkTable.EtalonChannels.Count - 1 do
    begin
      Channel := FWorkTable.EtalonChannels[I];
      if (Channel = nil) or (Channel.FlowMeter = nil) then
        Continue;

      if (APoint.Q <= 0) and (not Channel.Enabled) then
        Continue;
      if (APoint.Q > 0) and
         ((APoint.Q < Channel.FlowMeter.FlowMin) or (APoint.Q > Channel.FlowMeter.FlowMax)) then
        Continue;

      EtalonName := Trim(Channel.Name);
      if EtalonName = '' then
        EtalonName := Trim(Channel.FlowMeter.DeviceName);
      if EtalonName = '' then
        EtalonName := 'Без имени';

      Accuracy := '';
      if Channel.FlowMeter.Device <> nil then
        Accuracy := Trim(Channel.FlowMeter.Device.AccuracyClass);
      if Accuracy = '' then
        Accuracy := 'не указана';

      Details.Add(Format('%s (точность %s)', [EtalonName, Accuracy]));
    end;

    if Details.Count = 0 then
      Exit('Эталоны по расходу'  +FWorkTable.TableFlow.ValueFlowRate.GetStrNum(APoint.Q) + ' '+FWorkTable.TableFlow.ValueFlowRate.GetDimName+   ' не найдены');

    DetailsText := Trim(StringReplace(Details.Text, sLineBreak, '; ', [rfReplaceAll]));
    if EndsText(';', DetailsText) then
      Delete(DetailsText, Length(DetailsText), 1);
    Result := 'Установлены эталоны: ' + DetailsText;
  finally
    Details.Free;
  end;
end;

destructor TMeasurementRun.Destroy;
begin
  StopWorkerThread;
  if FCurrentStage <> msNone then
    SetStage(msNone);
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
      Result := ANewStage in [msSelectPoint];
    msSelectPoint:
      Result := ANewStage in [msSelectEtalon, msDone, msNone];
    msSelectEtalon:
      Result := ANewStage in [msSetupPoint, msDone, msNone];
    msSetupPoint:
      Result := ANewStage in [msWaitStable, msWaitMeasureStart, msDone, msNone];
    msWaitStable:
      Result := ANewStage in [msWaitMeasureStart, msSetupPoint, msDone, msNone];
    msWaitMeasureStart:
      Result := ANewStage in [msMeasure, msWaitMeasureStop, msDone, msNone];
    msMeasure:
      Result := ANewStage in [msWaitMeasureStop, msDone, msNone];
    msWaitMeasureStop:
      Result := ANewStage in [msResultsRead, msDone, msNone];
    msResultsRead:
      Result := ANewStage in [msSave, msDone, msNone];
    msSave:
      Result := ANewStage in [msSelectPoint, msSetupPoint, msDone, msNone];
    msDone:
      Result := ANewStage in [msNone, msSelectPoint];
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

procedure TMeasurementRun.EnterSelectPoint;
var
  Error: TErrorInfo;
begin
  FAttempt := 0;

  if FForceNextPoint >= 0 then
    FCurrentPointIndex := FForceNextPoint
  else
    Inc(FCurrentPointIndex);
  FForceNextPoint := -1;

  if FCurrentPointIndex >= FPoints.Count then
  begin
    SetStage(msDone);
    Exit;
  end;

  if SetPoint(FCurrentPointIndex, Error) then
  begin
    ProtocolManager.AddMessage(pcAction, psMeasurement, 'PointSelected',
      'Выбрана точка измерения', BuildPointSelectionLog(GetCurrentPoint));
    FireEvent(mePointSelected);
    if ShouldSelectEtalon then
      SetStage(msSelectEtalon)
    else
      SetStage(msSetupPoint);
  end
  else
  begin
    FireEvent(mePointInvalid, Error);
    SetStage(msDone);
  end;
end;

procedure TMeasurementRun.EnterSelectEtalon;
var
  Error: TErrorInfo;
begin
  if SelectEtalons(GetCurrentPoint, Error) then
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

procedure TMeasurementRun.EnterSetupPoint;
var
  Point: TDevicePoint;
  Error: TErrorInfo;
begin
  Point := GetCurrentPoint;
  if Point = nil then
  begin
    FireEvent(mePointNotSet, BuildError(1200, 'Текущая точка измерения не назначена'));
    SetStage(msDone);
    Exit;
  end;

  if ShouldSetupConditions then
  begin
    if not SetupPoint(Point, Error) then
    begin
      FireEvent(mePointNotSet, Error);
      SetStage(msDone);
      Exit;
    end;
  end
  else
    Point.Status := 3;

  if not SetupMeasurement(Point, Error) then
  begin
    FireEvent(mePointNotSet, Error);
    SetStage(msDone);
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
  if ShouldWaitStable and (FWorkTable <> nil) and
     not (FWorkTable.State in [swtSTARTTEST, swtSTARTWAIT, swtEXECUTE]) then
    FWorkTable.StartMonitor;
end;

procedure TMeasurementRun.EnterWaitMeasureStart;
begin
  FMeasureTimeout := CalcMeasureTimeout(GetCurrentPoint);

  if FWorkTable = nil then
  begin
    FireEvent(meMeasureError, BuildError(1400, 'Рабочий стол не назначен'));
    SetStage(msDone);
    Exit;
  end;

  ProtocolManager.AddMessage(pcAction, psMeasurement, 'StartTest',
    'Отдана команда запуска измерения', MeasurementStateToString(FCurrentStage));
  FWorkTable.StartTest;
end;

procedure TMeasurementRun.EnterMeasure;
begin
  FireEvent(meMeasureStarted);
end;

procedure TMeasurementRun.EnterWaitMeasureStop;
begin
  if FWorkTable = nil then
    Exit;

  if FWorkTable.State in [swtSTARTTEST, swtSTARTWAIT, swtEXECUTE] then
  begin
    ProtocolManager.AddMessage(pcAction, psMeasurement, 'StopTest',
      'Отдана команда остановки измерения', MeasurementStateToString(FCurrentStage));
    FWorkTable.StopTest;
  end;
end;

procedure TMeasurementRun.EnterResultsRead;
var
  Point: TDevicePoint;
begin
  FireEvent(meResultReading);

  Point := GetCurrentPoint;
  if Point <> nil then
    Point.Status := 9;

  FireEvent(meMeasureCompleted);
  FireEvent(meResultReady);
end;

procedure TMeasurementRun.EnterSave;
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
begin
  FNextStageAfterSave := msDone;
  Point := GetCurrentPoint;

  SaveMeasurementResults;
  FireEvent(meSaveDone);

  RepeatsTarget := 1;
  if Point <> nil then
    RepeatsTarget := Max(Point.Repeats, 1);
  Inc(FCurrentRepeat);

  if FCurrentRepeat >= RepeatsTarget then
  begin
    if Point <> nil then
      Point.Status := 9;
    FCurrentRepeat := 0;
    FireEvent(mePointDone);
    FNextStageAfterSave := msSelectPoint;
  end
  else
    FNextStageAfterSave := msSetupPoint;
end;

procedure TMeasurementRun.EnterDone;
begin
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
begin
  Result := False;
  StableInfo.Status := ssNONE;
  StableInfo.StatusText := '';
  StableInfo.CurrentValue := 0;
  Point := GetCurrentPoint;

  if (FWorkTable = nil) or (Point = nil) then
    Exit;

  Result := True;
  if (FWorkTable.FlowRate <> nil) and (Point.Q >= 0) then
  begin
    Result := FWorkTable.FlowRate.IsStable(ParamInfo) and Result;
    if ParamInfo.Status <> ssOk then
      StableInfo := ParamInfo;
  end;

  if (FWorkTable.FluidTemp <> nil) and (Point.Temp > 0) then
  begin
    Result := FWorkTable.FluidTemp.IsStable(ParamInfo) and Result;
    if ParamInfo.Status <> ssOk then
      StableInfo := ParamInfo;
  end;

  if (FWorkTable.FluidPress <> nil) and (Point.Pressure > 0) then
  begin
    Result := FWorkTable.FluidPress.IsStable(ParamInfo) and Result;
    if ParamInfo.Status <> ssOk then
      StableInfo := ParamInfo;
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
        Point := CreateSingleSessionPoint(False);
        if Point <> nil then
          FPoints.Add(Point);
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
  Result := True;
end;

function TMeasurementRun.CreateSingleSessionPoint(AWithConditions: Boolean): TDevicePoint;
begin
  Result := nil;
  if FWorkTable = nil then
    Exit;

  Result := TDevicePoint.Create(0);
  Result.Num := 1;
  Result.Status := 0;
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
        SessionPoint.Assign(SourcePoint, False);
        SessionPoint.Status := 0;
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
    CreateSession;
    if FPoints.Count = 0 then
    begin
      ProtocolManager.AddMessage(pcWarning, psMeasurement, 'Start',
        'Измерение не запущено', 'Нет точек измерения');
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

    FThread := TThread.CreateAnonymousThread(
      procedure
      begin
        RunThreadProc;
      end);
    FThread.FreeOnTerminate := False;
    FThread.Start;
    SetStage(msSelectPoint);
    if not FStopRequested then
      FireEvent(meStarted);
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

procedure TMeasurementRun.RequestStop;
begin
  FCriticalSection.Acquire;
  try
    if FStopRequested then
      Exit;
    FStopRequested := True;
    FIsPaused := False;
  finally
    FCriticalSection.Release;
  end;

  ProtocolManager.AddMessage(pcAction, psMeasurement, 'RequestStop',
    'Запрошена принудительная остановка измерения',
    MeasurementStateToString(FCurrentStage));

  case FCurrentStage of
    msWaitMeasureStart,
    msMeasure:
      SetStage(msWaitMeasureStop);
    msWaitMeasureStop:
      ; // The physical stop has already been requested.
    msNone,
    msDone:
      ;
  else
    SetStage(msDone);
  end;

  FireEvent(meStopped);
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
begin
  while not TThread.CurrentThread.CheckTerminated do
  begin
    try
      if FStopRequested and not (FCurrentStage in [msWaitMeasureStop, msDone]) then
      begin
        if FCurrentStage in [msWaitMeasureStart, msMeasure] then
          SetStage(msWaitMeasureStop)
        else
          SetStage(msDone);
      end;

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
          SetStage(msDone);
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

  FCurrentPointIndex := Index;
  Point := GetCurrentPoint;
  Result := ValidatePoint(Point, AError);
  if Result then
  begin
    Point.Status := 1; //точка выбрана
    FCurrentRepeat := Point.RepeatsCompleted;

  end else
  begin
    Point.Status := 2; //некорректно
  end;
end;

function TMeasurementRun.SelectEtalons(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
var
  I: Integer;
  Channel: TChannel;
  Best: TChannel;
begin
  AError := TErrorInfo.Empty(Integer(msSelectEtalon));
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

    if APoint.Q < 0 then
    begin
      if Channel.Enabled then
        Best := Channel;
      Continue;
    end;

    if SameValue(APoint.Q, 0) then
    begin
      if Channel.Enabled then
        Best := Channel;
      Continue;
    end;

    if (APoint.Q >= Channel.FlowMeter.FlowMin) and
       (APoint.Q <= Channel.FlowMeter.FlowMax) and
       ((Best = nil) or (Channel.FlowMeter.FlowMax < Best.FlowMeter.FlowMax)) then
      Best := Channel;
  end;

  { TODO: SelectEtalons finds the best etalon channel, but the selected
    channel is not currently persisted or applied. }
  Result := Best <> nil;
  if not Result then
  begin
    AError := BuildError(1101, 'Эталон по расходу не найден');
    Exit;
  end;

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

  GetCurrentPoint.Status:= 3;

  Result := True;
end;

function TMeasurementRun.SetupMeasurement(APoint: TDevicePoint; out AError: TErrorInfo): Boolean;
begin
  Result := False;
  AError := TErrorInfo.Empty(Integer(FCurrentStage));

  if (FWorkTable = nil) or (APoint = nil) then
  begin
    AError := BuildError(1202, 'Невозможно настроить параметры измерения');
    Exit;
  end;

  if FWorkTable.CurrentPoint <> nil then
  begin
    FWorkTable.CurrentPoint.LimitTime := -1;
    FWorkTable.CurrentPoint.LimitImp := -1;
    FWorkTable.CurrentPoint.LimitVolume := -1;
    FWorkTable.CurrentPoint.StopCriteria := [];
  end;

      if (scTime in APoint.StopCriteria) and (FWorkTable.CurrentPoint <> nil) then
       if APoint.LimitTime > 0 then
    FWorkTable.CurrentPoint.LimitTime := Round(APoint.LimitTime);

      if (scVolume in APoint.StopCriteria) and (FWorkTable.CurrentPoint <> nil) then
        if APoint.LimitVolume > 0 then
    FWorkTable.CurrentPoint.LimitVolume := APoint.LimitVolume;

    if (scImpulse in APoint.StopCriteria) and (FWorkTable.CurrentPoint <> nil) then
      if APoint.LimitImp > 0 then
    FWorkTable.CurrentPoint.LimitImp := APoint.LimitImp;

    if FWorkTable.CurrentPoint <> nil then
      FWorkTable.CurrentPoint.StopCriteria := APoint.StopCriteria;


  Result := True;
end;

procedure TMeasurementRun.Process;
begin

end;

procedure TMeasurementRun.ProcessStage;
begin
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
  DEFAULT_STABLE_TIMEOUT_MS = 30000;
var
  Point: TDevicePoint;
  StableInfo: RStableInfo;
begin
  Point := GetCurrentPoint;
  if Point = nil then
  begin
    FireEvent(meMeasureError, BuildError(1300, 'Нет текущей точки для стабилизации'));
    SetStage(msDone);
    Exit;
  end;

  if IsStable(StableInfo) then
  begin
    Point.Status := 6;
    FireEvent(meStableReached);
    SetStage(msWaitMeasureStart);
    Exit;
  end;

  if (TThread.GetTickCount64 - FWaitStartedTick) > DEFAULT_STABLE_TIMEOUT_MS then
  begin
    Inc(FAttempt);
    if FAttempt < FMaxAttemptCount then
    begin
      ProtocolManager.AddMessage(pcWarning, psMeasurement, 'StableTimeout',
        'Таймаут установки параметров измерения',
        Format('Попытка выхода на параметры: %d из %d', [FAttempt, FMaxAttemptCount]));
      FireEvent(meStableRetry);
      SetStage(msSetupPoint);
      Exit;
    end;

    ProtocolManager.AddMessage(pcError, psMeasurement, 'StableFailed',
      'Не удалось установить параметры измерения', StableInfo.StatusText);
    FireEvent(meStableTimeout, BuildError(1301, 'Стабилизация не достигнута'));
    SetStage(msDone);
  end;
end;

procedure TMeasurementRun.ProcessWaitMeasureStart;
const
  DEFAULT_START_TIMEOUT_MS = 30000;
begin
  if FWorkTable = nil then
  begin
    FireEvent(meMeasureError, BuildError(1400, 'Рабочий стол не назначен'));
    SetStage(msDone);
    Exit;
  end;

  case FWorkTable.State of
    swtEXECUTE:
      begin
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
        FireEvent(meMeasureError, BuildError(1402, 'Ошибка запуска измерения'));
        SetStage(msDone);
        Exit;
      end;
  end;

  if (TThread.GetTickCount64 - FWaitStartedTick) > DEFAULT_START_TIMEOUT_MS then
  begin
    FireEvent(meMeasureTimeout, BuildError(1403, 'Таймаут ожидания запуска измерения'));
    SetStage(msWaitMeasureStop);
  end;
end;

procedure TMeasurementRun.ProcessMeasure;
begin
  if FWorkTable = nil then
  begin
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
        FireEvent(meMeasureError, BuildError(1404, 'Ошибка во время измерения'));
        SetStage(msWaitMeasureStop);
        Exit;
      end;
  end;

  if Int64(TThread.GetTickCount64 - FWaitStartedTick) > Int64(FMeasureTimeout) * 1000 then
  begin
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
    swtCOMPLETE,
    swtFINALREAD:
      begin
        SetStage(msResultsRead);
        Exit;
      end;
    swtFAILURE:
      begin
        FireEvent(meMeasureError, BuildError(1405, 'Ошибка остановки измерения'));
        SetStage(msDone);
        Exit;
      end;
  end;

  if (TThread.GetTickCount64 - FWaitStartedTick) > DEFAULT_STOP_TIMEOUT_MS then
  begin
    FireEvent(meMeasureTimeout, BuildError(1406, 'Таймаут ожидания остановки измерения'));
    SetStage(msDone);
  end;
end;

procedure TMeasurementRun.ProcessResultsRead;
begin
  SetStage(msSave);
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
  Point := GetCurrentPoint;
  if Point = nil then
    Exit;

  RepeatsTarget := Max(Point.Repeats, 1);
  Point.RepeatsCompleted := Min(RepeatsTarget, FCurrentRepeat + 1);
  Point.DateTime := Now;
   Point.Status := 11;   // 'измерение завершено корректно';
  //Point.Status := 1;
  //Point.StatusStr := 'Measured';

  if FWorkTable <> nil then
    FWorkTable.TimeResult := Point.LimitTime;
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
