unit uBaseProcedures;

interface
uses
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.DateTimeCtrls,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.ListView,
  FMX.ListView.Adapters.Base,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Menus,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Types,
  System.Actions,
  System.Character,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.JSON,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.NetEncoding,
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants;

  const
  COLOR_NONE      = $FFFFFFFF; // Белый: нет состояния / нет активного ограничения
  COLOR_INVALID = $FFFFECEC;   // Светло-красный: точка некорректна
  COLOR_RUNNING = $FFF2E9FF;   // Светло-фиолетовый: точка выполняется
  COLOR_COMPLETED = $FFEAF9EA; // Светло-зелёный: точка выполнена
  COLOR_WARNING   = $FFFFF8E6; // Светло-жёлтый

  GRID_ALTERNATE_ROW_COLOR = $FFF2F2F2;
  GRID_DEVICE_GROUP_COLORS: array[0..2] of TAlphaColor = (
    $331E90FF, $4D1E90FF, $661E90FF);
  GRID_ETALON_GROUP_COLORS: array[0..2] of TAlphaColor = (
    $338A2BE2, $4D8A2BE2, $668A2BE2);

type



   IHasID = interface
    ['{A4E6E2F5-9E6F-4F8F-9A5C-6B4C9D3F8E21}']
    function GetID: Integer;
  end;



  TObjectState = (
    osEmpty,     // репозиторий пуст, ничего не загружено
    osLoading,   // идёт загрузка из БД

    osClean,     // загружено, без изменений (чистое состояние)
    osNew,       // создано, но ещё ни разу не сохранено
    osModified,  // изменено после загрузки или сохранения
    osDeleted,   // помечено на удаление

    osSaving,    // идёт сохранение
    osSaved,     // успешно сохранено
    osError      // ошибка
  );

  TTreeNodeKind = (
    tnAll,
    tnManufacturer,
    tnCategory,
    tnModification
  );

    EMeasurementState = (
      msNone,

      msSelectPoint,        // Выбор точки измерения
      msSelectEtalon,       // Выбор эталонов для текущей точки
      msSetupPoint,         // Задание параметров точки и ограничений измерения
      msWaitStable,         // Ожидание стабилизации условий

      msWaitMeasureStart,   // Команда StartTest отдана, ожидаем фактический запуск
      msMeasure,            // Измерение реально выполняется
      msWaitMeasureStop,    // Команда StopTest отдана или остановка началась, ожидаем завершение

      msResultsRead,        // Чтение/подготовка результатов
      msSave,               // Сохранение результатов
      msDone                // Завершение цикла измерения
    );

  /// <summary>
  /// Defines the current execution and result status of a measurement point.
  /// Unlike EMeasurementState, this value is stored in the point and may
  /// preserve a final result such as Saved, Cancelled, or MeasurementError.
  /// Explicit ordinal values keep database compatibility with the existing
  /// integer Status field.
  /// </summary>
  EMeasurementPointStatus = (
    mptsNone = 0,

    mptsSelectPoint = 1,
    mptsInvalidPoint = 2,

    mptsSelectEtalon = 3,
    mptsSetupPoint = 4,
    mptsWaitStable = 5,

    mptsWaitMeasureStart = 6,
    mptsMeasure = 7,
    mptsWaitMeasureStop = 8,

    mptsResultsRead = 9,
    mptsSave = 10,
    mptsDone = 11,

    mptsSetupError = 12,
    mptsMeasureError = 13,
    mptsInterrupted = 14,
    mptsCancelled = 15,
    mptsSaved = 16
  );

  /// <summary>One physical-value sample stored by TMeterValue for stability analysis.</summary>
  TMeterValueSample = record
    /// <summary>Monotonic timestamp in milliseconds; used for intervals and never based on wall-clock time.</summary>
    TimeStampMs: Int64;
    /// <summary>Physical value at TimeStampMs, before excessive display/filter smoothing.</summary>
    Value: Double;
  end;


  /// <summary>Per-source-sample diagnostic flags calculated by stability analysis.</summary>
  TMeterValueSampleAnalysis = record
    SourceIndex: Integer;
    TimeStampMs: Int64;
    InWindow: Boolean;
    IsInDisplayAnalysisWindow: Boolean;
    IsInConfirmationPeriod: Boolean;
    IsOutlier: Boolean;
    IsInRange: Boolean;
  end;

  /// <summary>Overall state returned by TMeterValue.AnalyzeStability.</summary>
  TMeterValueStabilityStatus = (
    mvssUnknown,       // Analysis has not run yet.
    mvssDisabled,      // Stability analysis is intentionally disabled for this value.
    mvssNotEnoughData, // The window lacks required sample count or duration.
    mvssStaleData,     // Last sample is older than MaxSampleAgeSec.
    mvssUnstable,      // Data is available but at least one criterion failed or confirmation is pending.
    mvssStable         // All criteria passed continuously for ConfirmationTimeSec.
  );

  /// <summary>Individual reasons why a stability analysis did not become stable.</summary>
  TMeterValueStabilityFailReason = (
    mvsfrAnalysisDisabled,
    mvsfrNoData,
    mvsfrNotEnoughSamples,  // Fewer samples than MinSampleCount are available in the active window.
    mvsfrInsufficientWindow,// Trend cannot be calculated because timestamps have insufficient spread.
    mvsfrInsufficientTimeSpread, // Timestamps are too close or identical to calculate a trend.
    mvsfrStaleData,         // Last sample age exceeds MaxSampleAgeSec.
    mvsfrVariationTooHigh,  // Max-min variation exceeds MaxVariation.
    mvsfrDeviationTooHigh,  // Absolute standard deviation exceeds MaxStdDeviation.
    mvsfrTrendTooHigh,      // Absolute regression slope exceeds MaxTrendRate.
    mvsfrTooManyOutliers,   // Outlier fraction exceeds MaxOutlierFraction.
    mvsfrCurrentValueOutOfRange,
    mvsfrMeanValueOutOfRange,
    mvsfrForecastOutOfRange,
    mvsfrWaitingForConfirmation,
    mvsfrInvalidSettings    // Settings failed validation and analysis result is not reliable.
  );

  /// <summary>Set of failure reasons; multiple simultaneous problems can be reported.</summary>
  TMeterValueStabilityFailReasons = set of TMeterValueStabilityFailReason;

  /// <summary>Configurable criteria used by TMeterValue and target-range checks used by TParameter.</summary>
  TChartColorOption = (
    ccoBlue,
    ccoLightBlue,
    ccoGreen,
    ccoRed,
    ccoOrange,
    ccoYellow,
    ccoPurple,
    ccoGray,
    ccoBlack
  );

  TMeterValueStabilitySettings = record
    /// <summary>Enables mathematical stability analysis; disabled values never auto-confirm readiness.</summary>
    Enabled: Boolean;
    /// <summary>Minimum number of samples required inside the active time window.</summary>
    MinSampleCount: Integer;
    /// <summary>Required active-window duration in seconds.</summary>
    WindowDurationSec: Double;
    /// <summary>Maximum allowed age in seconds for the latest sample.</summary>
    MaxSampleAgeSec: Double;
    /// <summary>Maximum allowed max-min spread in physical units.</summary>
    MaxVariation: Double;
    /// <summary>Maximum allowed absolute standard deviation in physical units.</summary>
    MaxStdDeviation: Double;
    /// <summary>Maximum allowed absolute linear-regression slope in physical units per second.</summary>
    MaxTrendRate: Double;
    /// <summary>Forecast horizon in seconds used by AnalyzeStability.</summary>
    ForecastHorizonSec: Double;
    /// <summary>Maximum allowed fraction of detected outliers in the active window.</summary>
    MaxOutlierFraction: Double;
    /// <summary>Multiplier used by the outlier detector threshold.</summary>
    OutlierFactor: Double;
    /// <summary>Seconds that all mathematical criteria must remain true before final stability.</summary>
    ConfirmationTimeSec: Double;
    /// <summary>Multiplier for exit thresholds after stability was already confirmed.</summary>
    ExitThresholdFactor: Double;
    /// <summary>Target value in base units used by current, mean and forecast range checks.</summary>
    TargetValue: Double;
    /// <summary>Upper target tolerance as percent of Abs(TargetValue).</summary>
    TargetAccuracyPlusPercent: Double;
    /// <summary>Lower target tolerance as percent of Abs(TargetValue).</summary>
    TargetAccuracyMinusPercent: Double;
    /// <summary>Absolute target tolerance used near zero and as a minimum tolerance.</summary>
    TargetToleranceAbsolute: Double;
    /// <summary>Requires current value to be inside the target range.</summary>
    RequireCurrentValueInRange: Boolean;
    /// <summary>Requires analyzed mean value to be inside the target range.</summary>
    RequireMeanValueInRange: Boolean;
    /// <summary>Requires forecast value to remain inside the target range.</summary>
    RequireForecastInRange: Boolean;
    /// <summary>Runs preview-analysis automatically after UI changes; persisted per TMeterValue.</summary>
    AutoAnalyze: Boolean;
    ChartSignalColor: TChartColorOption;
    ChartToleranceColor: TChartColorOption;
    ChartSignalLineWidth: Single;
    ChartToleranceLineWidth: Single;
  end;

  /// <summary>Direction of the calculated linear trend.</summary>
  TMeterValueTrendDirection = (
    tdNone,
    tdIncreasing,
    tdDecreasing
  );

  /// <summary>Full diagnostic result of TMeterValue.AnalyzeStability for UI and process logic.</summary>
  TMeterValueStabilityInfo = record
    /// <summary>Overall analysis status after all checks and confirmation-time logic.</summary>
    Status: TMeterValueStabilityStatus;
    /// <summary>All failure reasons detected during the analysis.</summary>
    FailReasons: TMeterValueStabilityFailReasons;
    /// <summary>True when CurrentValue and LastSampleAgeSec are valid.</summary>
    HasCurrentValue: Boolean;
    /// <summary>True when MeanValue/MinValue/MaxValue/Variation/StdDeviation are valid.</summary>
    HasStatistics: Boolean;
    /// <summary>True when TrendRate and TrendDirection are valid.</summary>
    HasTrend: Boolean;
    /// <summary>True when ForecastValue and IsForecastInRange are valid.</summary>
    HasForecast: Boolean;
    /// <summary>True when LastSampleAgeSec is valid.</summary>
    HasLastSampleAge: Boolean;
    /// <summary>True when signal stability criteria pass independently of target range.</summary>
    IsSignalStable: Boolean;
    /// <summary>True when confirmation time has elapsed after signal stability.</summary>
    IsStabilityConfirmed: Boolean;
    /// <summary>True when current value is inside the target range.</summary>
    IsCurrentValueInRange: Boolean;
    /// <summary>True when mean value is inside the target range.</summary>
    IsMeanValueInRange: Boolean;
    /// <summary>True when all mandatory stability and range checks passed.</summary>
    IsSuitableForMeasurement: Boolean;
    /// <summary>Total sample count currently stored in stability history.</summary>
    SampleCount: Integer;
    /// <summary>Number of samples selected into the active analysis window before outlier removal.</summary>
    UsedSampleCount: Integer;
    /// <summary>Number of samples excluded by the outlier detector.</summary>
    OutlierCount: Integer;
    /// <summary>Latest physical value in the active window.</summary>
    CurrentValue: Double;
    /// <summary>Mean value of non-outlier samples in the active window.</summary>
    MeanValue: Double;
    /// <summary>Minimum value of non-outlier samples in the active window.</summary>
    MinValue: Double;
    /// <summary>Maximum value of non-outlier samples in the active window.</summary>
    MaxValue: Double;
    /// <summary>MaxValue - MinValue in physical units.</summary>
    Variation: Double;
    /// <summary>Absolute standard deviation in physical units.</summary>
    StdDeviation: Double;
    /// <summary>Linear-regression slope in physical units per second.</summary>
    TrendRate: Double;
    /// <summary>Regression trend direction calculated by the domain analysis.</summary>
    TrendDirection: TMeterValueTrendDirection;
    /// <summary>Regression-based forecast at ForecastHorizonSec.</summary>
    ForecastValue: Double;
    /// <summary>True when forecast value is inside the target range.</summary>
    IsForecastInRange: Boolean;
    /// <summary>Actual duration in seconds between first and last samples in the active window.</summary>
    WindowDurationSec: Double;
    /// <summary>Age in seconds of the latest sample.</summary>
    LastSampleAgeSec: Double;
    /// <summary>OutlierCount divided by active-window sample count.</summary>
    OutlierFraction: Double;
    /// <summary>Seconds elapsed since the signal first met all mathematical criteria.</summary>
    StableCandidateDurationSec: Double;
    /// <summary>True when StableCandidateDurationSec reached ConfirmationTimeSec.</summary>
    IsConfirmed: Boolean;
    /// <summary>True when active-window sample count meets MinSampleCount.</summary>
    HasEnoughSamples: Boolean;
    /// <summary>True when active-window duration meets WindowDurationSec.</summary>
    HasEnoughWindow: Boolean;
    /// <summary>True when latest sample age does not exceed MaxSampleAgeSec.</summary>
    IsDataActual: Boolean;
    /// <summary>True when Variation is within MaxVariation.</summary>
    IsVariationStable: Boolean;
    /// <summary>True when StdDeviation is within MaxStdDeviation.</summary>
    IsDeviationStable: Boolean;
    /// <summary>True when Abs(TrendRate) is within MaxTrendRate.</summary>
    IsTrendStable: Boolean;
    /// <summary>True when OutlierFraction is within MaxOutlierFraction.</summary>
    IsOutlierLevelAcceptable: Boolean;
    /// <summary>Per-source-sample flags for UI grids and diagnostics.</summary>
    SampleResults: TArray<TMeterValueSampleAnalysis>;
    /// <summary>Human-readable Russian diagnostic text containing the main analysis reasons.</summary>
    StatusText: string;
  end;

  EStableStatus = (
    sNONE,
    sRun_NN,   // no target, no stable
    sRun_SN,   // stable, no target
    sRun_NS,   // no stable, target
    sOk,       // done + stable
    sFail_SN,  // stable, no target
    sFail_NS,  // no stable, target
    sFail_NN   // no stable, no target
  );

  /// <summary>Final parameter-level readiness result assembled by TParameter from signal and target checks.</summary>
  RStableInfo = record
    /// <summary>Backward-compatible parameter status used by existing UI and process logic.</summary>
    Status: EStableStatus;
    /// <summary>Human-readable Russian diagnostic combining signal stability and target-range checks.</summary>
    StatusText: string;
    /// <summary>Current measured value copied from SignalInfo for backward compatibility.</summary>
    CurrentValue: Double;
    /// <summary>Full TMeterValue mathematical stability analysis result.</summary>
    SignalInfo: TMeterValueStabilityInfo;
    /// <summary>Current target/setpoint value from TParameter.ValueSet.</summary>
    TargetValue: Double;
    /// <summary>Lower allowed target boundary after percent and absolute tolerance calculation.</summary>
    LowerLimit: Double;
    /// <summary>Upper allowed target boundary after percent and absolute tolerance calculation.</summary>
    UpperLimit: Double;
    /// <summary>Mean value copied from SignalInfo for UI convenience.</summary>
    MeanValue: Double;
    /// <summary>Forecast value copied from SignalInfo for UI convenience.</summary>
    ForecastValue: Double;
    /// <summary>True when TMeterValue returned confirmed mathematical stability.</summary>
    IsSignalStable: Boolean;
    /// <summary>True when current value is inside LowerLimit..UpperLimit.</summary>
    IsCurrentInRange: Boolean;
    /// <summary>True when mean value is inside LowerLimit..UpperLimit.</summary>
    IsMeanInRange: Boolean;
    /// <summary>True when forecast value is inside LowerLimit..UpperLimit.</summary>
    IsForecastInRange: Boolean;
    /// <summary>True when all enabled target-range checks are satisfied.</summary>
    IsTargetConditionPassed: Boolean;
    /// <summary>True only when signal stability and all enabled target checks are satisfied.</summary>
    IsReadyForMeasurement: Boolean;
  end;

  EOutPutSet = (
    optAuto = 0,
    optPassive,
    optActive,
    optUniversal,
    optCapacity
  );

  ESyncChannelMode = (
    scmOff = 0,
    scmByEdge,
    scmByEdgeTime
  );

  TErrorInfo = record
    Code: Integer;
    Msg: string;
    Time: TDateTime;
    Stage: Integer;//EMeasurementState;
    class function Empty(AStage:Integer{: EMeasurementState}): TErrorInfo; static;
  end;



function NormalizeFloatInput(const S: string): Double;
function FormatPercentPM(const Value: Double): string;
function ExtractFirstFloat(const S: string): Double;
function ParseAccuracyClass(const S: string): Double;
function GetFracDigits(Value: Double): Integer;
function FormatDeviceError(Value: Double): string;
function FormatError(Value: Double): string;
 function FormatPhys(Value: Double): string;
function FormatTime(Value: Double): string;
function FormatByBaseError(Value, BaseError: Double): string;
function FormatValue(Value: Double; Accuracy: Integer; Error: Double; ShowTrailingZeros: Boolean = True): string; overload;
function FormatValue(const Str: string; Accuracy: Integer; Error: Double; ShowTrailingZeros: Boolean = True): string; overload;
function RemoveTrailingZeros(const Str: string): string;
function RandomGenerate(Value, Error: Double): Double;
procedure CalculateTargetLimits(
  const ATargetValue: Double;
  const APlusPercent: Double;
  const AMinusPercent: Double;
  const AAbsoluteTolerance: Double;
  out ALowerLimit: Double;
  out AUpperLimit: Double
);
function FormatFloatN(Value: Double; Digits: Integer): string;
function NormalizeAccuracyInput(const S: string): string;
function FormatAccuracy(const S: string): string;
function NormalizeDateInput(const AText: string): string;
function ParseFlexibleDate(const AText: string; out ADate: TDateTime): Boolean;
function ExtractInt(const AText: string; out AValue: Integer): Boolean;
function ExtractManufacturerName(const S: string): string;
function NormalizeNameCase(const S: string): string;
function NormalizeSearchText(const S: string): string;
function NormalizeTreeText(const S: string): string;
function NormalizeTreeKey(const S: string): string;
function FindChildInNode(AParent: TTreeViewItem; ATag: Integer; const AKey: string): TTreeViewItem;
function FindChildInTree(ATree: TTreeView; ATag: Integer; const AKey: string): TTreeViewItem;
function NewGuidString: string;
function ContainsTextAny(const AText, AFind: string): Boolean;
function IsDateInRange(const ADate, AFrom, ATo: TDate): Boolean;
function TryMeasurementPointStatusFromInteger(const AValue: Integer; out AStatus: EMeasurementPointStatus): Boolean;
function StabilityFailReasonToText(const AReason: TMeterValueStabilityFailReason): string;
function NormalizeFlowAccuracyInput(const S: string): string;
function BoolToRussianYesNo(const AValue: Boolean): string;
function ObjClassNameOrNil(const AObject: TObject): string;
function OutputSetToStr(AValue: EOutPutSet): string;
function StrToOutputSet(const AValue: string): EOutPutSet;
function IntToOutputSet(const AValue: Integer): EOutPutSet;
function SyncChannelModeToStr(AValue: ESyncChannelMode): string;
function StrToSyncChannelMode(const AValue: string): ESyncChannelMode;
function IntToSyncChannelMode(const AValue: Integer): ESyncChannelMode;
function NoiseFilterToStr(AValue: Integer): string;
function StrToNoiseFilter(const AValue: string): Integer;

implementation

  { TErrorInfo }

class function TErrorInfo.Empty(AStage: Integer): TErrorInfo;
begin
  Result.Code := 0;
  Result.Msg := '';
  Result.Time := Now;
  Result.Stage := AStage;
end;

function BoolToRussianYesNo(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function ObjClassNameOrNil(const AObject: TObject): string;
begin
  if AObject = nil then
    Exit('nil');
  Result := AObject.ClassName;
end;

function OutputSetToStr(AValue: EOutPutSet): string;
begin
  case AValue of
    optPassive: Result := 'Пассивный';
    optActive: Result := 'Активный';
    optUniversal: Result := 'Универсальный';
    optCapacity: Result := 'Емкостной';
  else
    Result := 'Авто';
  end;
end;

function StrToOutputSet(const AValue: string): EOutPutSet;
var
  LValue: string;
begin
  LValue := Trim(LowerCase(AValue));
  if LValue = LowerCase('Пассивный') then
    Exit(optPassive);
  if LValue = LowerCase('Активный') then
    Exit(optActive);
  if LValue = LowerCase('Универсальный') then
    Exit(optUniversal);
  if LValue = LowerCase('Емкостной') then
    Exit(optCapacity);
  Result := optAuto;
end;

function IntToOutputSet(const AValue: Integer): EOutPutSet;
begin
  if (AValue >= Ord(Low(EOutPutSet))) and (AValue <= Ord(High(EOutPutSet))) then
    Result := EOutPutSet(AValue)
  else
    Result := optAuto;
end;

function SyncChannelModeToStr(AValue: ESyncChannelMode): string;
begin
  case AValue of
    scmByEdge: Result := 'По фронту';
    scmByEdgeTime: Result := 'По фронту + время';
  else
    Result := 'Выкл';
  end;
end;

function StrToSyncChannelMode(const AValue: string): ESyncChannelMode;
var
  LValue: string;
begin
  LValue := Trim(LowerCase(AValue));
  if LValue = LowerCase('По фронту') then
    Exit(scmByEdge);
  if LValue = LowerCase('По фронту + время') then
    Exit(scmByEdgeTime);
  Result := scmOff;
end;

function IntToSyncChannelMode(const AValue: Integer): ESyncChannelMode;
begin
  if (AValue >= Ord(Low(ESyncChannelMode))) and
     (AValue <= Ord(High(ESyncChannelMode))) then
    Result := ESyncChannelMode(AValue)
  else
    Result := scmOff;
end;

function NoiseFilterToStr(AValue: Integer): string;
begin
  case AValue of
    -1: Result := 'Выкл';
    0: Result := 'Авто';
  else
    Result := IntToStr(AValue) + ' мс';
  end;
end;

function StrToNoiseFilter(const AValue: string): Integer;
var
  LValue: string;
  LInt: Integer;
begin
  LValue := Trim(LowerCase(AValue));
  if LValue = LowerCase('Выкл') then
    Exit(-1);
  if LValue = LowerCase('Авто') then
    Exit(0);
  if ExtractInt(LValue, LInt) then
    Result := LInt
  else
    Result := 0;
end;

function NormalizeFloatInput(const S: string): Double;
var
  I: Integer;
  Tmp: string;
  DecSep: Char;
begin
  Tmp := '';
  DecSep := FormatSettings.DecimalSeparator;

  for I := 1 to Length(S) do
    if CharInSet(S[I], ['0'..'9', '.', ',']) then
      Tmp := Tmp + S[I];

  Tmp := StringReplace(Tmp, '.', DecSep, [rfReplaceAll]);
  Tmp := StringReplace(Tmp, ',', DecSep, [rfReplaceAll]);

  Result := StrToFloatDef(Tmp, 0);
end;

function FormatPercentPM(const Value: Double): string;
begin
  if Value > 0 then
    Result := '±' + FloatToStr(Value) + '%'
  else
    Result := '—';
end;

function ExtractFirstFloat(const S: string): Double;
var
  I: Integer;
  Tmp: string;
  DecSep: Char;
begin
  Tmp := '';
  DecSep := FormatSettings.DecimalSeparator;

  for I := 1 to Length(S) do
    if CharInSet(S[I], ['0'..'9', '.', ',']) then
      Tmp := Tmp + S[I];

  Tmp := StringReplace(Tmp, '.', DecSep, [rfReplaceAll]);
  Tmp := StringReplace(Tmp, ',', DecSep, [rfReplaceAll]);

  Result := StrToFloatDef(Tmp, 0);
end;

function ParseAccuracyClass(const S: string): Double;
var
  Tmp: string;
begin
  Tmp := StringReplace(S, ',', '.', [rfReplaceAll]);
  Result := StrToFloatDef(Tmp, 1.0);
end;


function GetFracDigits(Value: Double): Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  if Value = 0 then Exit;

  S := FloatToStr(Value);
  P := Pos(FormatSettings.DecimalSeparator, S);
  if P > 0 then
    Result := Length(S) - P;
end;


function FormatFloatN(Value: Double; Digits: Integer): string;
begin
  Result := FormatFloat('0.' + StringOfChar('0', Digits), Value);
end;

function FormatByBaseError(Value, BaseError: Double): string;
var
  Delta, Rounded: Double;
  Digits: Integer;
  Fmt: string;
begin
  // ------------------------------------
  // Защита
  // ------------------------------------
  if Value <= 0 then
    Exit('—');

  // Если погрешность не задана —
  // показываем число как есть, но НЕ в экспоненте
  if BaseError <= 0 then
  begin
    Result := FormatFloat('0.################', Value);
    Exit;
  end;

  // ------------------------------------
  // Шаг округления
  // Δ = F * E / 1000
  // ------------------------------------
  Delta := Value * BaseError / 1000;

  if Delta <= 0 then
  begin
    Result := FormatFloat('0.################', Value);
    Exit;
  end;

  // ------------------------------------
  // Δ >= 1 → дробная часть бессмысленна
  // ------------------------------------
  if Delta >= 1 then
  begin
    Result := FormatFloat('0', Trunc(Value));
    Exit;
  end;

  // ------------------------------------
  // Округление к шагу Δ
  // ------------------------------------
  Rounded := Round(Value / Delta) * Delta;

  // ------------------------------------
  // Определяем количество знаков
  // по шагу Δ
  // ------------------------------------
  Digits := Max(0, -Floor(Log10(Delta)));

  if Digits>10 then
          Digits := 10;
  // Формат без экспоненты
  Fmt := '0.' + StringOfChar('#', Digits);

  Result := FormatFloat(Fmt, Rounded);
end;

function GetDigitsFromError(Value, Error: Double): Integer;
var
  AbsError: Double;
  ValuePart: Double;
begin
  Result := 0;

  if Error <= 0 then
    Exit;

  // Абсолютная погрешность при относительной погрешности Error (%)
  AbsError := Abs(Value) * Error / 100;

  // Если само значение = 0, то относительная погрешность не даёт масштаба.
  // В таком случае просто оставляем 0 знаков.
  if AbsError <= 0 then
    Exit;

  // Требуемая дискретность отображения = 1/10 абсолютной погрешности
  ValuePart := AbsError / 2;

  if ValuePart >= 1 then
    Exit(0);

  Result := Ceil(-Log10(ValuePart));

  if Result < 0 then
    Result := 0;

  Result := EnsureRange(Result, 0, 12);
end;


function FormatValue(Value: Double; Accuracy: Integer; Error: Double; ShowTrailingZeros: Boolean): string;
var
  FS: TFormatSettings;
  FractPartCnt: Integer;
  RoundedValue: Double;
begin
  FS := TFormatSettings.Create;

  // 1. Если точность указана явно - используем только её
  if Accuracy >= 0 then
  begin
    FractPartCnt := EnsureRange(Accuracy, 0, 12);
    RoundedValue := RoundTo(Value, -FractPartCnt);
    Exit(FloatToStrF(RoundedValue, ffFixed, 18, FractPartCnt, FS));
  end;

  // 2. Иначе, если задана погрешность - рассчитываем число знаков по ней
  if Error > 0 then
    FractPartCnt := GetDigitsFromError(Value, Error)
  else
    FractPartCnt := 0;

  FractPartCnt := EnsureRange(FractPartCnt, 0, 12);
  RoundedValue := RoundTo(Value, -FractPartCnt);
  Result := FloatToStrF(RoundedValue, ffFixed, 18, FractPartCnt, FS);

  if not ShowTrailingZeros then
    Result := RemoveTrailingZeros(Result);
end;

function FormatValue(const Str: string; Accuracy: Integer; Error: Double; ShowTrailingZeros: Boolean): string;
var
  FS: TFormatSettings;
  S: string;
  V: Double;
begin
  FS := TFormatSettings.Create;
  S := Trim(Str);

  S := StringReplace(S, '.', FS.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, ',', FS.DecimalSeparator, [rfReplaceAll]);

  V := StrToFloatDef(S, 0, FS);
  Result := FormatValue(V, Accuracy, Error, ShowTrailingZeros);
end;

function RemoveTrailingZeros(const Str: string): string;
var
  S: string;
  FS: TFormatSettings;
  SepPos, EndPos: Integer;
begin
  FS := TFormatSettings.Create;
  S := Trim(Str);
  SepPos := Pos(FS.DecimalSeparator, S);
  if SepPos = 0 then
    Exit(S);

  EndPos := Length(S);
  while (EndPos > SepPos) and (S[EndPos] = '0') do
    Dec(EndPos);

  if (EndPos >= SepPos) and (S[EndPos] = FS.DecimalSeparator) then
    Dec(EndPos);

  if EndPos > 0 then
    Result := Copy(S, 1, EndPos)
  else
    Result := '0';
end;

function RandomGenerate(Value, Error: Double): Double;
var
  LowerBound, UpperBound: Double;
begin
  LowerBound := Value - Value * Error / 100.0;
  UpperBound := Value + Value * Error / 100.0;
  Result := LowerBound + Random * (UpperBound - LowerBound);
end;

function FormatTime(Value: Double): string;
begin
  if Value = 0 then
    Result := '—'
  else
    Result := FormatFloatN(Value, 2);
end;


 function FormatPhys(Value: Double): string;
begin
  if Value = 0 then
    Result := '—'
  else
    Result := FormatFloatN(Value, 1);
end;

function FormatError(Value: Double): string;
begin
  if Value = 0 then
    Result := '—'
  else
    Result := FormatFloatN(Value, 1);
end;

function FormatDeviceError(Value: Double): string;
var
  Digits: Integer;
begin
  if Value = 0 then
    Exit('—');

  Digits := GetFracDigits(Value);
  Result := FormatFloatN(Value, Digits);
end;

function NormalizeFlowAccuracyInput(const S: string): string;
var
  T: string;
  V: Double;
begin
  Result := '';

  // убираем пробелы и %
  T := Trim(S);
  T := StringReplace(T, '%', '', [rfReplaceAll]);
  T := StringReplace(T, '±', '', [rfReplaceAll]);

  if T = '' then
    Exit('');

  // +5
  if (T[1] = '+') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '+' + FloatToStr(V);
    Exit;
  end;

  // -5
  if (T[1] = '-') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '-' + FloatToStr(V);
    Exit;
  end;

  // 5 → ±5
  V := NormalizeFloatInput(T);
  if V > 0 then
    Result := FloatToStr(V); // знак ± добавим при выводе
end;


function NormalizeAccuracyInput(const S: string): string;
var
  T: string;
  V: Double;
begin
  Result := '';

  // убираем пробелы и %
  T := Trim(S);
  T := StringReplace(T, '%', '', [rfReplaceAll]);
  T := StringReplace(T, '±', '', [rfReplaceAll]);

  if T = '' then
    Exit('');

  // +5
  if (T[1] = '+') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '+' + FloatToStr(V);
    Exit;
  end;

  // -5
  if (T[1] = '-') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '-' + FloatToStr(V);
    Exit;
  end;

  // 5 → ±5
  V := NormalizeFloatInput(T);
  if V > 0 then
    Result := FloatToStr(V); // знак ± добавим при выводе
end;


 function FormatAccuracy(const S: string): string;
var
  V: Double;
begin
  Result := '—';

  if Trim(S) = '' then
    Exit;

  // +5
  if S[1] = '+' then
  begin
    V := NormalizeFloatInput(Copy(S, 2, MaxInt));
    if V > 0 then
      Result := '+' + FloatToStr(V);
    Exit;
  end;

  // -5
  if S[1] = '-' then
  begin
    V := NormalizeFloatInput(Copy(S, 2, MaxInt));
    if V > 0 then
      Result := '-' + FloatToStr(V);
    Exit;
  end;

  // 5 → ±5
  V := NormalizeFloatInput(S);
  if V > 0 then
    Result := '±' + FloatToStr(V);
end;

function NormalizeDateInput(const AText: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := '';

  for I := 1 to Length(AText) do
  begin
    C := AText[I];

    // цифры оставляем
    if C in ['0'..'9'] then
      Result := Result + C

    // любые разделители считаем точкой
    else if C in ['.', ',', ':', '-', '/', ' '] then
    begin
      if (Result = '') or (Result[Length(Result)] <> '.') then
        Result := Result + '.';
    end;

    // все прочие символы просто игнорируем
  end;

  // убираем точку в конце
  if (Result <> '') and (Result[Length(Result)] = '.') then
    Delete(Result, Length(Result), 1);
end;

function ParseFlexibleDate(const AText: string; out ADate: TDateTime): Boolean;
var
  S: string;
  Parts: TArray<string>;
  Y, M, D: Word;
begin
  Result := False;
  ADate := 0;

  S := NormalizeDateInput(AText);
  if S = '' then Exit;

  Parts := S.Split(['.']);

  try
    case Length(Parts) of
      1:
        begin
          // только год
          Y := StrToInt(Parts[0]);
          M := 1;
          D := 1;
        end;

      2:
        begin
          // месяц + год
          M := StrToInt(Parts[0]);
          Y := StrToInt(Parts[1]);
          D := 1;
        end;

      3:
        begin
          // день + месяц + год
          D := StrToInt(Parts[0]);
          M := StrToInt(Parts[1]);
          Y := StrToInt(Parts[2]);
        end
      else
        Exit;
    end;

    ADate := EncodeDate(Y, M, D);
    Result := True;
  except
    Result := False;
  end;
end;

function ExtractInt(const AText: string; out AValue: Integer): Boolean;
var
  I: Integer;
  S: string;
begin
  S := '';

  for I := 1 to Length(AText) do
    if AText[I] in ['0'..'9'] then
      S := S + AText[I];

  Result := (S <> '');
  if Result then
    AValue := StrToIntDef(S, 0);
end;

function ExtractManufacturerName(const S: string): string;
var
  Src, Part, Name: string;
  I, StartPos, EndPos: Integer;
  OpenQuote, CloseQuote: Char;
begin
  Result := '';

  Src := Trim(S);
  if Src = '' then Exit;

  // Берём первого производителя (до ;)
  I := Pos(';', Src);
  if I > 0 then
    Part := Trim(Copy(Src, 1, I - 1))
  else
    Part := Src;

  // Ищем первую пару кавычек
  for I := 1 to Length(Part) do
  begin
    if (Part[I] = '"') or (Part[I] = '«') then
    begin
      OpenQuote := Part[I];
      if OpenQuote = '«' then
        CloseQuote := '»'
      else
        CloseQuote := '"';

      StartPos := I + 1;
      EndPos := StartPos;

      while (EndPos <= Length(Part)) and (Part[EndPos] <> CloseQuote) do
        Inc(EndPos);

      if EndPos <= Length(Part) then
      begin
        Name := Copy(Part, StartPos, EndPos - StartPos);
        Result := NormalizeNameCase(Trim(Name));
        Exit;
      end;
    end;
  end;

  // fallback
  Result := NormalizeNameCase(Src);
end;

function NormalizeNameCase(const S: string): string;
var
  I: Integer;
  FirstLetterFound: Boolean;
begin
  Result := S;
  FirstLetterFound := False;

  for I := 1 to Length(Result) do
  begin
    if TCharacter.IsLetter(Result[I]) then
    begin
      if not FirstLetterFound then
      begin
        Result[I] := TCharacter.ToUpper(Result[I]);
        FirstLetterFound := True;
      end
      else
        Result[I] := TCharacter.ToLower(Result[I]);
    end;
  end;
end;

function NormalizeSearchText(const S: string): string;
begin
  Result := LowerCase(S);

  // все виды тире → пробел
  Result := StringReplace(Result, '–', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '—', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '-', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '-', ' ', [rfReplaceAll]);
end;

function NormalizeTreeText(const S: string): string;
begin
  if Trim(S) = '' then
    Result := '<пусто>'
  else
    Result := Trim(S);
end;

function NormalizeTreeKey(const S: string): string;
var
  T: string;
begin
  T := Trim(S).ToLower;

  if T = '' then
    Exit('');

  Result := T.Substring(0, 1).ToUpper + T.Substring(1);
end;

function FindChildInTree(
  ATree: TTreeView;
  ATag: Integer;
  const AKey: string
): TTreeViewItem;
var
  I: Integer;
  Item: TTreeViewItem;
begin
  Result := nil;

  for I := 0 to ATree.Count - 1 do
  begin
    Item := ATree.Items[I];
    if (Item.Tag = ATag) and SameText(NormalizeTreeKey(Item.TagString), NormalizeTreeKey(AKey)) then
      Exit(Item);
  end;
end;

function FindChildInNode(
  AParent: TTreeViewItem;
  ATag: Integer;
  const AKey: string
): TTreeViewItem;
var
  I: Integer;
  Item: TTreeViewItem;
begin
  Result := nil;

  for I := 0 to AParent.Count - 1 do
  begin
    Item := TTreeViewItem(AParent.Items[I]);
    if (Item.Tag = ATag) and SameText(NormalizeTreeKey(Item.TagString), NormalizeTreeKey(AKey)) then
      Exit(Item);
  end;
end;




procedure CalculateTargetLimits(
  const ATargetValue: Double;
  const APlusPercent: Double;
  const AMinusPercent: Double;
  const AAbsoluteTolerance: Double;
  out ALowerLimit: Double;
  out AUpperLimit: Double
);
var
  PlusTolerance: Double;
  MinusTolerance: Double;
begin
  PlusTolerance := System.Math.Max(AAbsoluteTolerance,
    Abs(ATargetValue) * APlusPercent / 100.0);
  MinusTolerance := System.Math.Max(AAbsoluteTolerance,
    Abs(ATargetValue) * AMinusPercent / 100.0);
  ALowerLimit := ATargetValue - MinusTolerance;
  AUpperLimit := ATargetValue + PlusTolerance;
end;

function NewGuidString: string;
begin
  Result := TGUID.NewGuid.ToString;
end;


function ContainsTextAny(const AText, AFind: string): Boolean;
begin
  Result := (AFind = '') or
            ContainsText(AText, AFind);
end;

function IsDateInRange(const ADate, AFrom, ATo: TDate): Boolean;
begin
  Result := (ADate >= AFrom) and (ADate <= ATo);
end;



function StabilityFailReasonToText(const AReason: TMeterValueStabilityFailReason): string;
begin
  case AReason of
    mvsfrAnalysisDisabled: Result := 'анализ стабильности отключён';
    mvsfrNoData: Result := 'нет доступных данных';
    mvsfrNotEnoughSamples: Result := 'недостаточно отсчётов';
    mvsfrInsufficientWindow: Result := 'Недостаточная длительность окна анализа.';
    mvsfrInsufficientTimeSpread: Result := 'недостаточный временной интервал между точками для расчёта тренда';
    mvsfrStaleData: Result := 'последнее значение устарело';
    mvsfrVariationTooHigh: Result := 'размах превышает допустимое значение';
    mvsfrDeviationTooHigh: Result := 'стандартное отклонение превышает допустимое значение';
    mvsfrTrendTooHigh: Result := 'скорость тренда превышает допустимое значение';
    mvsfrTooManyOutliers: Result := 'Доля выбросов превышает допустимое значение';
    mvsfrCurrentValueOutOfRange: Result := 'текущее значение вне диапазона';
    mvsfrMeanValueOutOfRange: Result := 'среднее значение вне диапазона';
    mvsfrForecastOutOfRange: Result := 'прогноз вне диапазона';
    mvsfrWaitingForConfirmation: Result := 'ожидается подтверждение стабильности';
    mvsfrInvalidSettings: Result := 'некорректные настройки';
  else
    Result := 'неизвестная причина';
  end;
end;

function TryMeasurementPointStatusFromInteger(const AValue: Integer; out AStatus: EMeasurementPointStatus): Boolean;
begin
  Result := (AValue >= Ord(Low(EMeasurementPointStatus))) and
            (AValue <= Ord(High(EMeasurementPointStatus)));
  if Result then
    AStatus := EMeasurementPointStatus(AValue)
  else
    AStatus := mptsNone;
end;

end.
