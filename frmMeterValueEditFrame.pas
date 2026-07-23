unit frmMeterValueEditFrame;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Consts,
  FMX.Dialogs,
  FMX.DialogService,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  FMX.Platform,
  FMX.Grid,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uBaseProcedures,
  uMeterValue, FMX.Grid.Style, FMX.ScrollBox, FMX.SimpleChart, uDebugLog;

type
  TMeterValueSampleSource = (
    mssWorkHistory,
    mssTestSamples
  );

  TMeterValueTestScenario = (
    mtsConstantValue,
    mtsStableNoise,
    mtsSlowIncrease,
    mtsSlowDecrease,
    mtsSettlingAfterChange,
    mtsSingleOutlier,
    mtsManyOutliers,
    mtsNotEnoughData,
    mtsStaleData,
    mtsForecastAboveRange,
    mtsForecastBelowRange,
    mtsStableOutOfRange,
    mtsAllConditionsPassed
  );

  TFrameMeterValueEdit = class(TFrame)
    TabControlMain: TTabControl;
    TabItemMainParameters: TTabItem;
    TabItemStabilityForecast: TTabItem;
    TabControlStability: TTabControl;
    TabItemStabilityData: TTabItem;
    TabItemStabilitySettings: TTabItem;
    TabItemStabilityResult: TTabItem;
    TabItemStabilityChart: TTabItem;
    ChartStability: TSimpleChart;
    LayoutConclusion: TLayout;
    LabelConclusionTitle: TLabel;
    RectangleSignalStable: TRectangle;
    LabelSignalStableValue: TLabel;
    RectangleStabilityConfirmed: TRectangle;
    LabelStabilityConfirmedValue: TLabel;
    RectangleCurrentInRange: TRectangle;
    LabelCurrentInRangeValue: TLabel;
    RectangleMeanInRange: TRectangle;
    LabelMeanInRangeValue: TLabel;
    RectangleForecastInRange: TRectangle;
    LabelForecastInRangeValue: TLabel;
    RectangleSuitable: TRectangle;
    LabelSuitableValue: TLabel;
    MemoConclusion: TMemo;
    GridSamples: TGrid;
    StringColumnSampleValue: TStringColumn;
    EditSampleTime: TEdit;
    EditSampleValue: TEdit;
    EditSampleTimeStep: TEdit;
    EditAnalysisTime: TEdit;
    ButtonSampleAdd: TButton;
    ButtonSampleEdit: TButton;
    ButtonSampleDelete: TButton;
    ButtonSamplesClear: TButton;
    GroupAnalysis: TGroupBox;
    ButtonAnalyze: TButton;
    CheckBoxAutoAnalyze: TCheckBox;
    ComboBoxStabilityScenario: TComboBox;
    ButtonApplyScenario: TButton;
    EditScenarioPointCount: TEdit;
    ButtonCopyAllScenarioLogs: TButton;
    EditGeneratorStartValue: TEdit;
    EditGeneratorCount: TEdit;
    EditGeneratorTimeStep: TEdit;
    EditGeneratorTrend: TEdit;
    EditGeneratorNoise: TEdit;
    EditGeneratorOutlierProbability: TEdit;
    EditGeneratorOutlierAmplitude: TEdit;
    ButtonGenerateNew: TButton;
    ButtonGenerateAppend: TButton;
    CheckBoxStabilityEnabled: TCheckBox;
    EditMinSampleCount: TEdit;
    EditWindowDurationSec: TEdit;
    EditMaxSampleAgeSec: TEdit;
    EditConfirmationTimeSec: TEdit;
    EditExitThresholdFactor: TEdit;
    EditMaxVariation: TEdit;
    EditMaxStdDeviation: TEdit;
    EditMaxTrendRate: TEdit;
    EditMaxOutlierFractionPercent: TEdit;
    EditOutlierFactor: TEdit;
    EditForecastHorizonSec: TEdit;
    EditTestTargetValue: TEdit;
    EditTargetAccuracyPlusPercent: TEdit;
    EditTargetAccuracyMinusPercent: TEdit;
    EditTargetToleranceAbsolute: TEdit;
    CheckBoxRequireCurrentValueInRange: TCheckBox;
    CheckBoxRequireMeanValueInRange: TCheckBox;
    CheckBoxRequireForecastInRange: TCheckBox;
    EditTargetLowerLimit: TEdit;
    EditTargetUpperLimit: TEdit;
    EditResultSampleCount: TEdit;
    EditResultUsedSampleCount: TEdit;
    EditResultOutlierCount: TEdit;
    EditResultOutlierFraction: TEdit;
    EditResultWindowDuration: TEdit;
    EditResultLastSampleAge: TEdit;
    EditResultCurrentValue: TEdit;
    EditResultMeanValue: TEdit;
    EditResultMinValue: TEdit;
    EditResultMaxValue: TEdit;
    EditResultVariation: TEdit;
    EditResultStdDeviation: TEdit;
    EditResultTrendRate: TEdit;
    EditResultTrendDirection: TEdit;
    EditResultForecastHorizon: TEdit;
    EditResultForecastValue: TEdit;
    EditResultForecastInRange: TEdit;
    ListBoxStabilityReasons: TListBox;
    MemoStabilityConclusion: TMemo;
    GroupBoxChartAppearance: TGroupBox;
    ComboBoxChartSignalColor: TComboBox;
    ComboBoxChartToleranceColor: TComboBox;
    ComboBoxChartSignalWidth: TComboBox;
    ComboBoxChartToleranceWidth: TComboBox;
  private
    FMeterValue: TMeterValue;
    FLoading: Boolean;
    FTestSamples: TList<TMeterValueSample>;
    FDisplayedSamples: TArray<TMeterValueSample>;
    FSampleSource: TMeterValueSampleSource;
    ComboBoxSampleSource: TComboBox;
    ButtonRefreshHistory: TButton;
    ButtonUseLastSampleTime: TButton;
    FTestCurrentTimeMs: Int64;
    FTestDataModified: Boolean;
    FTestTargetValue: Double;
    FTestSettings: TMeterValueStabilitySettings;
    FTestStabilityInfo: TMeterValueStabilityInfo;
    FLastTestAnalysis: TMeterValueStabilityInfo;
    FTestStableCandidateSinceMs: Int64;
    FTestStabilityConfirmed: Boolean;
    FSettingsModified: Boolean;
    FChartAppearanceModified: Boolean;
    FApplyingSettings: Boolean;
    FRecalculating: Boolean;
    FStabilityTimerUpdating: Boolean;
    FModified: Boolean;
    TimerStabilityAutoRefresh: TTimer;
    LayoutRoot: TVertScrollBox;
    EditName: TEdit;
    EditType: TEdit;
    EditShrtName: TEdit;
    EditDescription: TEdit;
    CheckBoxIsToSave: TCheckBox;
    EditValueFull: TEdit;
    EditValue: TEdit;
    ComboValueDim: TComboBox;
    EditMin: TEdit;
    EditMax: TEdit;
    EditAccuracy: TEdit;
    EditError: TEdit;
    CheckBoxShowTrailingZeros: TCheckBox;
    EditNameValueRate: TEdit;
    EditValueRate: TEdit;
    EditNameValueMultiplier: TEdit;
    EditValueMultiplier: TEdit;
    EditNameValueDevider: TEdit;
    EditValueDevider: TEdit;
    EditCoefK: TEdit;
    EditCoefP: TEdit;

    procedure BuildUI;
    procedure AddEditRow(const ACaption: string; out AEdit: TEdit);
    procedure AddCheckRow(const ACaption: string; out ACheckBox: TCheckBox);
    procedure AddComboRow(const ACaption: string; out AComboBox: TComboBox);
    procedure AddSectionRow(const ACaption: string);
    procedure HandleControlExit(Sender: TObject);
    procedure HandleCheckBoxChange(Sender: TObject);
    procedure HandleComboChange(Sender: TObject);
    procedure FillDimensionCombo;
    function SafeFloat(const S: string): Double;
    function SampleSecondsToMs(const ASeconds: Double): Int64;
    function GetSampleIndexForGridRow(const ARow: Integer): Integer;
    function GetGridRowForSampleIndex(const AIndex: Integer): Integer;
    function SelectedSampleIndex: Integer;
    function GetDisplayedSamples: TArray<TMeterValueSample>;
    function GetDisplayedStabilitySamples: TArray<TMeterValueSample>;
    procedure RefreshDisplayedSamples;
    procedure SortDisplayedSamples;
    function CanRunStabilityAutoRefresh: Boolean;
    procedure UpdateStabilityAutoRefreshTimer;
    procedure RefreshStabilityHistoryAndAnalysis;
    procedure TimerStabilityAutoRefreshTimer(Sender: TObject);
    procedure SetSampleSource(const ASource: TMeterValueSampleSource);
    procedure UpdateSampleSourceControls;
    procedure ComboBoxSampleSourceChange(Sender: TObject);
    procedure TabControlStabilityChange(Sender: TObject);
    procedure ButtonRefreshHistoryClick(Sender: TObject);
    procedure ButtonUseLastSampleTimeClick(Sender: TObject);
    procedure SetAnalysisTimeByLastDisplayedSample;
    function DisplayUnitName: string;
    function AppendUnit(const AText, AUnit: string): string;
    procedure UpdateStabilityHints;
    procedure FillChartColorComboBox(AComboBox: TComboBox);
    function ChartColorToComboIndex(const AColor: TChartColorOption): Integer;
    function ComboIndexToChartColor(const AIndex: Integer): TChartColorOption;
    procedure FillChartWidthComboBox(AComboBox: TComboBox);
    function ChartWidthToComboIndex(const AValue: Single): Integer;
    function ComboIndexToChartWidth(const AIndex: Integer): Single;
    procedure ChartAppearanceChange(Sender: TObject);
    function BaseToDisplayText(const AValue: Double): string;
    function ValueToCurrentDimension(const ABaseValue: Double): Double;
    function BaseDeltaToDisplayText(const AValue: Double): string;
    function FormatBaseInfo(const AValue: Double; const AHasValue: Boolean): string;
    function FormatBaseDeltaInfo(const AValue: Double; const AHasValue: Boolean): string;
    function DisplayToBase(const AText: string): Double;
    function DisplayDeltaToBase(const AText: string): Double;
    procedure UpdateDimensionCaptions;
    procedure LoadSampleToEditor(const AIndex: Integer);
    procedure RefreshSamplesGrid(const AReload: Boolean = True);
    procedure AddSample;
    procedure EditSelectedSample;
    procedure DeleteSelectedSample;
    procedure ClearSamples;
    procedure GenerateNewSamples;
    procedure AppendGeneratedSamples;
    procedure GenerateSamples(const AClearExisting: Boolean);
    function ValidateGeneratorControls(out AErrorText: string): Boolean;
    procedure InitializeScenarioList;
    procedure ApplySelectedScenario;
    function TryGetScenarioPointCount(out APointCount: Integer; const AShowError: Boolean): Boolean;
    function ScenarioDisplayName(const AScenario: TMeterValueTestScenario): string;
    procedure ApplyScenario(const AScenario: TMeterValueTestScenario);
    function BuildAllScenarioReport: string;
    procedure RefreshAllTestControls;
    procedure SortSamples;
    procedure ClearAnalysisDisplay;
    procedure ButtonSampleAddClick(Sender: TObject);
    procedure ButtonSampleEditClick(Sender: TObject);
    procedure ButtonSampleDeleteClick(Sender: TObject);
    procedure ButtonSamplesClearClick(Sender: TObject);
    procedure ButtonAnalyzeClick(Sender: TObject);
    procedure ButtonGenerateNewClick(Sender: TObject);
    procedure ButtonGenerateAppendClick(Sender: TObject);
    procedure ButtonApplyScenarioClick(Sender: TObject);
    procedure ButtonCopyAllScenarioLogsClick(Sender: TObject);
    procedure GridSamplesCellDblClick(const Column: TColumn; const Row: Integer);
    procedure GridSamplesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSamplesSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure GridSamplesSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure EditAnalysisTimeExit(Sender: TObject);
    procedure CopySettingsFromWorkMeterValue;
    procedure LoadSettingsToControls;
    procedure ReadSettingsFromControls(out ASettings: TMeterValueStabilitySettings);
    function StabilitySettingsEqual(const ALeft, ARight: TMeterValueStabilitySettings): Boolean;
    function ApplySettingsFromControls(const AShowError: Boolean): Boolean;
    function ApplyAndSaveStabilitySettings(const ARecalculate: Boolean; const ARefreshChartOnly: Boolean = False; const AShowError: Boolean = False): Boolean;
    procedure RestoreStabilitySettingsControls;
    function ValidateControls(out AErrorText: string): Boolean;
    procedure HandleSettingsChange(Sender: TObject);
    function TryReadFloat(const AText: string; out AValue: Double): Boolean;
    function TryReadInteger(const AText: string; out AValue: Integer): Boolean;
    procedure UpdateTargetLimits;
    procedure HandleTargetRangeChange(Sender: TObject);
    procedure Analyze;
    procedure RecalculateTestPreview;
    function TryGetTestTargetLimits(out ALowerLimit, AUpperLimit: Double): Boolean;
    procedure AnalyzeDisplayedSamples(const AUseLastWorkSampleTime: Boolean; const AShowValidationError: Boolean;
      const ARefreshSource: Boolean = False);
    procedure ClearTestAnalysis;
    function FindSampleAnalysis(const ARow: Integer; out AResult: TMeterValueSampleAnalysis): Boolean;
    function BoolText(const AValue: Boolean): string;
    function InWindowText(const AResult: TMeterValueSampleAnalysis): string;
    procedure AnalyzeIfNeeded;
    procedure HandleAutoAnalyzeChange(Sender: TObject);
    procedure DisplayAnalysis(const AInfo: TMeterValueStabilityInfo);
    procedure SetConclusionIndicator(const ARectangle: TRectangle; const ALabel: TLabel;
      const AText: string; const AColor: TAlphaColor);
    procedure ResetConclusionIndicators;
    procedure UpdateConclusionIndicators(const AInfo: TMeterValueStabilityInfo);
    function FormatInfoFloat(const AValue: Double; const AHasValue: Boolean; const ADigits: Integer = 4): string;
    function TrendDirectionText(const ADirection: TMeterValueTrendDirection; const AHasTrend: Boolean): string;
    procedure UpdateDetailedConclusion(const AInfo: TMeterValueStabilityInfo);
    function ChartColorOptionToAlphaColor(const AOption: TChartColorOption): TAlphaColor;
    procedure ApplyChartSeriesStyle(const ASeries: TChartSeries; const AColor: TChartColorOption; const AThickness: Double; const AShowMarkers: Boolean);
    procedure UpdateStabilityChart;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromMeterValue(AMeterValue: TMeterValue);
    procedure SaveChanges;
    procedure ApplySettingsToWorkMeterValue;
    procedure SetStabilityOnlyMode;
    procedure SetIntegratedMode(const AMainParametersParent, AStabilityParent: TControl);
  end;

implementation

const
  CHART_LINE_WIDTHS: array[0..5] of Single = (0.5, 1.0, 1.5, 2.0, 3.0, 4.0);

{$R *.fmx}

constructor TFrameMeterValueEdit.Create(AOwner: TComponent);
begin
  inherited;
  FTestSamples := TList<TMeterValueSample>.Create;
  FTestCurrentTimeMs := 0;
  FSampleSource := mssWorkHistory;
  SetLength(FDisplayedSamples, 0);
  FTestDataModified := False;
  FTestTargetValue := 0;
  FSettingsModified := False;
  FChartAppearanceModified := False;
  FApplyingSettings := False;
  FRecalculating := False;
  FStabilityTimerUpdating := False;
  FModified := False;
  TimerStabilityAutoRefresh := TTimer.Create(Self);
  TimerStabilityAutoRefresh.Interval := 1000;
  TimerStabilityAutoRefresh.Enabled := False;
  TimerStabilityAutoRefresh.OnTimer := TimerStabilityAutoRefreshTimer;
  FillChar(FTestSettings, SizeOf(FTestSettings), 0);
  FTestStabilityInfo := Default(TMeterValueStabilityInfo);
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
  FTestStableCandidateSinceMs := 0;
  FTestStabilityConfirmed := False;
  BuildUI;
  ClearAnalysisDisplay;
end;

destructor TFrameMeterValueEdit.Destroy;
begin
  if TimerStabilityAutoRefresh <> nil then
    TimerStabilityAutoRefresh.Enabled := False;
  FTestSamples.Free;
  inherited;
end;

procedure TFrameMeterValueEdit.BuildUI;

  procedure SetHintFor(const AName, AHint: string);
  var
    Component: TComponent;
  begin
    Component := FindComponent(AName);
    if Component is TControl then
    begin
      TControl(Component).Hint := AHint;
      TControl(Component).ShowHint := True;
      if Component is TLabel then
        TLabel(Component).HitTest := True;
    end;
  end;

begin
  LayoutRoot := TVertScrollBox.Create(Self);
  LayoutRoot.Parent := TabItemMainParameters;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

  ComboBoxSampleSource := TComboBox.Create(Self);
  ComboBoxSampleSource.Parent := GroupAnalysis;
  ComboBoxSampleSource.Position.X := 214;
  ComboBoxSampleSource.Position.Y := 28;
  ComboBoxSampleSource.Size.Width := 134;
  ComboBoxSampleSource.Size.Height := 24;
  ComboBoxSampleSource.Items.Add('История TMeterValue');
  ComboBoxSampleSource.Items.Add('Тестовый массив');
  ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
  ComboBoxSampleSource.OnChange := ComboBoxSampleSourceChange;

  with TLabel.Create(Self) do
  begin
    Parent := GroupAnalysis;
    Position.X := 12;
    Position.Y := 30;
    Size.Width := 190;
    Size.Height := 22;
    Text := 'Источник данных';
  end;

  GroupAnalysis.Height := 196;
  if FindComponent('LabelAnalysisTime') is TControl then
    TControl(FindComponent('LabelAnalysisTime')).Position.Y := 62;
  EditAnalysisTime.Position.Y := 60;
  ButtonAnalyze.Position.Y := 94;
  CheckBoxAutoAnalyze.Position.Y := 126;
  ButtonRefreshHistory := TButton.Create(Self);
  ButtonRefreshHistory.Parent := GroupAnalysis;
  ButtonRefreshHistory.Position.X := 12;
  ButtonRefreshHistory.Position.Y := 158;
  ButtonRefreshHistory.Size.Width := 160;
  ButtonRefreshHistory.Size.Height := 28;
  ButtonRefreshHistory.Text := 'Обновить историю';
  ButtonRefreshHistory.OnClick := ButtonRefreshHistoryClick;

  ButtonUseLastSampleTime := TButton.Create(Self);
  ButtonUseLastSampleTime.Parent := GroupAnalysis;
  ButtonUseLastSampleTime.Position.X := 188;
  ButtonUseLastSampleTime.Position.Y := 158;
  ButtonUseLastSampleTime.Size.Width := 160;
  ButtonUseLastSampleTime.Size.Height := 28;
  ButtonUseLastSampleTime.Text := 'По последней точке';
  ButtonUseLastSampleTime.OnClick := ButtonUseLastSampleTimeClick;

  if FindComponent('GroupSettingsCommon') is TControl then
    with TLabel.Create(Self) do
    begin
      Name := 'LabelStabilityDisplayUnit';
      Parent := TControl(FindComponent('GroupSettingsCommon'));
      Position.X := 280;
      Position.Y := 6;
      Size.Width := 260;
      Size.Height := 22;
      Text := 'Единица измерения: ' + DisplayUnitName;
      ShowHint := True;
      HitTest := True;
    end;

  ButtonSampleAdd.OnClick := ButtonSampleAddClick;
  ButtonSampleEdit.OnClick := ButtonSampleEditClick;
  ButtonSampleDelete.OnClick := ButtonSampleDeleteClick;
  ButtonSamplesClear.OnClick := ButtonSamplesClearClick;
  ButtonAnalyze.OnClick := ButtonAnalyzeClick;
  ButtonGenerateNew.OnClick := ButtonGenerateNewClick;
  ButtonGenerateAppend.OnClick := ButtonGenerateAppendClick;
  if ButtonApplyScenario.Parent <> nil then
  begin
    with TLabel.Create(Self) do
    begin
      Name := 'LabelScenarioPointCount';
      Parent := ButtonApplyScenario.Parent;
      Position.X := ButtonApplyScenario.Position.X;
      Position.Y := ButtonApplyScenario.Position.Y - 32;
      Size.Width := 120;
      Size.Height := 22;
      Text := 'Количество точек';
    end;

    EditScenarioPointCount := TEdit.Create(Self);
    EditScenarioPointCount.Name := 'EditScenarioPointCount';
    EditScenarioPointCount.Parent := ButtonApplyScenario.Parent;
    EditScenarioPointCount.Position.X := ButtonApplyScenario.Position.X + 130;
    EditScenarioPointCount.Position.Y := ButtonApplyScenario.Position.Y - 34;
    EditScenarioPointCount.Size.Width := 80;
    EditScenarioPointCount.Size.Height := 24;
    EditScenarioPointCount.Text := '10';
    EditScenarioPointCount.KillFocusByReturn := True;

    ButtonCopyAllScenarioLogs := TButton.Create(Self);
    ButtonCopyAllScenarioLogs.Name := 'ButtonCopyAllScenarioLogs';
    ButtonCopyAllScenarioLogs.Parent := ButtonApplyScenario.Parent;
    ButtonCopyAllScenarioLogs.Position.X := ButtonApplyScenario.Position.X;
    ButtonCopyAllScenarioLogs.Position.Y := ButtonApplyScenario.Position.Y + ButtonApplyScenario.Size.Height + 6;
    ButtonCopyAllScenarioLogs.Size.Width := 260;
    ButtonCopyAllScenarioLogs.Size.Height := ButtonApplyScenario.Size.Height;
    ButtonCopyAllScenarioLogs.Text := 'Копировать отчёт по всем сценариям';
    ButtonCopyAllScenarioLogs.OnClick := ButtonCopyAllScenarioLogsClick;
  end;
  ButtonApplyScenario.OnClick := ButtonApplyScenarioClick;
  TabControlStability.OnChange := TabControlStabilityChange;
  FillChartColorComboBox(ComboBoxChartSignalColor);
  FillChartColorComboBox(ComboBoxChartToleranceColor);
  FillChartWidthComboBox(ComboBoxChartSignalWidth);
  FillChartWidthComboBox(ComboBoxChartToleranceWidth);
  ComboBoxChartSignalColor.OnChange := ChartAppearanceChange;
  ComboBoxChartToleranceColor.OnChange := ChartAppearanceChange;
  ComboBoxChartSignalWidth.OnChange := ChartAppearanceChange;
  ComboBoxChartToleranceWidth.OnChange := ChartAppearanceChange;
  CheckBoxAutoAnalyze.OnChange := HandleAutoAnalyzeChange;
  GridSamples.OnCellDblClick := GridSamplesCellDblClick;
  GridSamples.OnGetValue := GridSamplesGetValue;
  GridSamples.OnSetValue := GridSamplesSetValue;
  GridSamples.OnSelectCell := GridSamplesSelectCell;
  EditAnalysisTime.OnExit := EditAnalysisTimeExit;
  CheckBoxStabilityEnabled.OnChange := HandleSettingsChange;
  EditMinSampleCount.OnExit := HandleSettingsChange;
  EditWindowDurationSec.OnExit := HandleSettingsChange;
  EditMaxSampleAgeSec.OnExit := HandleSettingsChange;
  EditConfirmationTimeSec.OnExit := HandleSettingsChange;
  EditExitThresholdFactor.OnExit := HandleSettingsChange;
  EditMaxVariation.OnExit := HandleSettingsChange;
  EditMaxStdDeviation.OnExit := HandleSettingsChange;
  EditMaxTrendRate.OnExit := HandleSettingsChange;
  EditMaxOutlierFractionPercent.OnExit := HandleSettingsChange;
  EditOutlierFactor.OnExit := HandleSettingsChange;
  EditForecastHorizonSec.OnExit := HandleSettingsChange;
  EditTestTargetValue.OnExit := HandleTargetRangeChange;
  EditTargetAccuracyPlusPercent.OnExit := HandleTargetRangeChange;
  EditTargetAccuracyMinusPercent.OnExit := HandleTargetRangeChange;
  EditTargetToleranceAbsolute.OnExit := HandleTargetRangeChange;
  CheckBoxRequireCurrentValueInRange.OnChange := HandleTargetRangeChange;
  CheckBoxRequireMeanValueInRange.OnChange := HandleTargetRangeChange;
  CheckBoxRequireForecastInRange.OnChange := HandleTargetRangeChange;
  EditTargetLowerLimit.ReadOnly := True;
  EditTargetUpperLimit.ReadOnly := True;
  EditResultSampleCount.ReadOnly := True;
  EditResultUsedSampleCount.ReadOnly := True;
  EditResultOutlierCount.ReadOnly := True;
  EditResultOutlierFraction.ReadOnly := True;
  EditResultWindowDuration.ReadOnly := True;
  EditResultLastSampleAge.ReadOnly := True;
  EditResultCurrentValue.ReadOnly := True;
  EditResultMeanValue.ReadOnly := True;
  EditResultMinValue.ReadOnly := True;
  EditResultMaxValue.ReadOnly := True;
  EditResultVariation.ReadOnly := True;
  EditResultStdDeviation.ReadOnly := True;
  EditResultTrendRate.ReadOnly := True;
  EditResultTrendDirection.ReadOnly := True;
  EditResultForecastHorizon.ReadOnly := True;
  EditResultForecastValue.ReadOnly := True;
  EditResultForecastInRange.ReadOnly := True;
  MemoStabilityConclusion.ReadOnly := True;
  EditSampleTimeStep.Text := '1,0';
  EditAnalysisTime.Text := '0';
  EditGeneratorStartValue.Text := '0';
  EditGeneratorCount.Text := '10';
  EditGeneratorTimeStep.Text := '1,0';
  EditGeneratorTrend.Text := '0';
  EditGeneratorNoise.Text := '0';
  EditGeneratorOutlierProbability.Text := '0';
  EditGeneratorOutlierAmplitude.Text := '0';
  InitializeScenarioList;
  SetHintFor('LabelStabilityDisplayUnit', 'Единица, выбранная для отображения текущего TMeterValue. Все размерные значения результатов и соответствующие настройки показываются в этой единице. Внутреннее хранение может выполняться в базовой единице.');
  SetHintFor('CheckBoxStabilityEnabled', 'Включает расчет стабильности и пригодности значения по заданным критериям.');
  SetHintFor('LabelMinSampleCount', 'Минимальное количество отсчётов в окне анализа для достоверного результата.');
  SetHintFor('LabelWindowDurationSec', 'Длительность временного окна, по которому рассчитываются размах, отклонение и тренд.');
  SetHintFor('LabelMaxSampleAgeSec', 'Максимально допустимый возраст последнего отсчёта относительно текущего времени анализа.');
  SetHintFor('LabelConfirmationTimeSec', 'Время, в течение которого условия стабильности должны оставаться выполненными для подтверждения.');
  SetHintFor('LabelExitThresholdFactor', 'Множитель порогов после подтверждения стабильности, задающий гистерезис выхода.');
  SetHintFor('LabelMaxVariation', 'Максимально допустимый размах значений в окне анализа.');
  SetHintFor('LabelMaxStdDeviation', 'Максимально допустимое стандартное отклонение значений в окне анализа.');
  SetHintFor('LabelMaxTrendRate', 'Максимально допустимая абсолютная скорость линейного тренда в единицах в секунду.');
  SetHintFor('LabelMaxOutlierFractionPercent', 'Максимальная допустимая доля выбросов в процентах от использованных отсчётов.');
  SetHintFor('LabelOutlierFactor', 'Коэффициент MAD-критерия для определения выбросов.');
  SetHintFor('LabelForecastHorizonSec', 'Горизонт прогноза от текущего времени анализа, с.');
  SetHintFor('LabelTestTargetValue', 'Целевое значение для проверки текущего, среднего и прогнозного значения.');
  SetHintFor('LabelTargetAccuracyPlusPercent', 'Допуск вверх от целевого значения, %.');
  SetHintFor('LabelTargetAccuracyMinusPercent', 'Допуск вниз от целевого значения, %.');
  SetHintFor('LabelTargetToleranceAbsolute', 'Минимальный абсолютный допуск, применяемый вместе с процентными допусками.');
  SetHintFor('CheckBoxRequireCurrentValueInRange', 'Проверять попадание текущего значения в целевой диапазон.');
  SetHintFor('CheckBoxRequireMeanValueInRange', 'Проверять попадание среднего значения в целевой диапазон.');
  SetHintFor('CheckBoxRequireForecastInRange', 'Проверять попадание прогнозного значения в целевой диапазон.');
  UpdateDimensionCaptions;
  UpdateSampleSourceControls;
  RefreshSamplesGrid;

  AddEditRow('Полное название', EditValueFull);
  AddEditRow('Текущее значение', EditValue);
  AddSectionRow('Основные свойства');
  AddEditRow('Название', EditName);
  AddEditRow('Тип', EditType);
  AddEditRow('Краткое имя', EditShrtName);
  AddEditRow('Описание', EditDescription);
  AddCheckRow('Сохранять', CheckBoxIsToSave);
  AddSectionRow('Значения');
  AddComboRow('Размерность', ComboValueDim);
  AddEditRow('Минимальное значение', EditMin);
  AddEditRow('Максимальное значение', EditMax);
  AddSectionRow('Точность');
  AddEditRow('Знаков после запятой', EditAccuracy);
  AddEditRow('Погрешность форматирования', EditError);
  AddCheckRow('Отображение нулей', CheckBoxShowTrailingZeros);
  AddSectionRow('Коэффициенты');
  AddEditRow('Наименование Rate', EditNameValueRate);
  AddEditRow('Значение Rate', EditValueRate);
  AddEditRow('Наименование множителя', EditNameValueMultiplier);
  AddEditRow('Значение множителя', EditValueMultiplier);
  AddEditRow('Наименование делителя', EditNameValueDevider);
  AddEditRow('Значение делителя', EditValueDevider);
  AddEditRow('Коэффициент K', EditCoefK);
  AddEditRow('Коэффициент P', EditCoefP);
end;


procedure TFrameMeterValueEdit.AddEditRow(const ACaption: string; out AEdit: TEdit);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 30;
  Item.Margins.Bottom := 2;
  Item.Stored := False;

  RowGrid := TGridPanelLayout.Create(Self);
  RowGrid.Parent := Item;
  RowGrid.Align := TAlignLayout.Client;
  RowGrid.RowCollection.Clear;
  RowGrid.ColumnCollection.Clear;
  RowGrid.ColumnCollection.Add.Value := 45;
  RowGrid.ColumnCollection.Add.Value := 55;
  RowGrid.RowCollection.Add.Value := 100;
  RowGrid.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := RowGrid;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;
  CaptionLabel.Margins.Rect := TRectF.Create(18, 0, 6, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  AEdit := TEdit.Create(Self);
  AEdit.Parent := RowGrid;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Rect := TRectF.Create(4, 1, 8, 1);
  AEdit.KillFocusByReturn := True;
  AEdit.OnExit := HandleControlExit;
  RowGrid.ControlCollection.AddControl(AEdit, 1, 0);
end;

procedure TFrameMeterValueEdit.AddCheckRow(const ACaption: string; out ACheckBox: TCheckBox);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 30;
  Item.Margins.Bottom := 2;
  Item.Stored := False;

  RowGrid := TGridPanelLayout.Create(Self);
  RowGrid.Parent := Item;
  RowGrid.Align := TAlignLayout.Client;
  RowGrid.RowCollection.Clear;
  RowGrid.ColumnCollection.Clear;
  RowGrid.ColumnCollection.Add.Value := 45;
  RowGrid.ColumnCollection.Add.Value := 55;
  RowGrid.RowCollection.Add.Value := 100;
  RowGrid.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := RowGrid;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;
  CaptionLabel.Margins.Rect := TRectF.Create(18, 0, 6, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := RowGrid;
  ACheckBox.Align := TAlignLayout.Client;
  ACheckBox.Margins.Rect := TRectF.Create(4, 1, 8, 1);
  ACheckBox.OnChange := HandleCheckBoxChange;
  RowGrid.ControlCollection.AddControl(ACheckBox, 1, 0);
end;

procedure TFrameMeterValueEdit.AddComboRow(const ACaption: string; out AComboBox: TComboBox);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 30;
  Item.Margins.Bottom := 2;
  Item.Stored := False;

  RowGrid := TGridPanelLayout.Create(Self);
  RowGrid.Parent := Item;
  RowGrid.Align := TAlignLayout.Client;
  RowGrid.RowCollection.Clear;
  RowGrid.ColumnCollection.Clear;
  RowGrid.ColumnCollection.Add.Value := 45;
  RowGrid.ColumnCollection.Add.Value := 55;
  RowGrid.RowCollection.Add.Value := 100;
  RowGrid.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := RowGrid;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;
  CaptionLabel.Margins.Rect := TRectF.Create(18, 0, 6, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  AComboBox := TComboBox.Create(Self);
  AComboBox.Parent := RowGrid;
  AComboBox.Align := TAlignLayout.Client;
  AComboBox.Margins.Rect := TRectF.Create(4, 1, 8, 1);
  AComboBox.OnChange := HandleComboChange;
  RowGrid.ControlCollection.AddControl(AComboBox, 1, 0);
end;

procedure TFrameMeterValueEdit.AddSectionRow(const ACaption: string);
var
  Item: TLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 26;
  Item.Margins.Top := 4;
  Item.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := Item;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.Margins.Rect := TRectF.Create(10, 0, 8, 0);
  CaptionLabel.HitTest := False;
end;




procedure TFrameMeterValueEdit.FillChartColorComboBox(AComboBox: TComboBox);
begin
  if AComboBox = nil then
    Exit;
  AComboBox.Items.Clear;
  AComboBox.Items.Add('Синий');
  AComboBox.Items.Add('Голубой');
  AComboBox.Items.Add('Зелёный');
  AComboBox.Items.Add('Красный');
  AComboBox.Items.Add('Оранжевый');
  AComboBox.Items.Add('Жёлтый');
  AComboBox.Items.Add('Фиолетовый');
  AComboBox.Items.Add('Серый');
  AComboBox.Items.Add('Чёрный');
end;

function TFrameMeterValueEdit.ChartColorToComboIndex(const AColor: TChartColorOption): Integer;
begin
  case AColor of
    ccoBlue: Result := 0;
    ccoLightBlue: Result := 1;
    ccoGreen: Result := 2;
    ccoRed: Result := 3;
    ccoOrange: Result := 4;
    ccoYellow: Result := 5;
    ccoPurple: Result := 6;
    ccoGray: Result := 7;
    ccoBlack: Result := 8;
  else
    Result := 0;
  end;
end;

function TFrameMeterValueEdit.ComboIndexToChartColor(const AIndex: Integer): TChartColorOption;
begin
  case AIndex of
    0: Result := ccoBlue;
    1: Result := ccoLightBlue;
    2: Result := ccoGreen;
    3: Result := ccoRed;
    4: Result := ccoOrange;
    5: Result := ccoYellow;
    6: Result := ccoPurple;
    7: Result := ccoGray;
    8: Result := ccoBlack;
  else
    Result := ccoBlue;
  end;
end;

procedure TFrameMeterValueEdit.FillChartWidthComboBox(AComboBox: TComboBox);
begin
  if AComboBox = nil then
    Exit;
  AComboBox.Items.Clear;
  AComboBox.Items.Add('0,5');
  AComboBox.Items.Add('1');
  AComboBox.Items.Add('1,5');
  AComboBox.Items.Add('2');
  AComboBox.Items.Add('3');
  AComboBox.Items.Add('4');
end;

function TFrameMeterValueEdit.ComboIndexToChartWidth(const AIndex: Integer): Single;
begin
  if (AIndex >= Low(CHART_LINE_WIDTHS)) and (AIndex <= High(CHART_LINE_WIDTHS)) then
    Result := CHART_LINE_WIDTHS[AIndex]
  else
    Result := 1.0;
end;

function TFrameMeterValueEdit.ChartWidthToComboIndex(const AValue: Single): Integer;
var
  I: Integer;
  BestDelta: Single;
  Delta: Single;
begin
  Result := 0;
  BestDelta := Abs(AValue - CHART_LINE_WIDTHS[0]);
  for I := 1 to High(CHART_LINE_WIDTHS) do
  begin
    Delta := Abs(AValue - CHART_LINE_WIDTHS[I]);
    if Delta < BestDelta then
    begin
      BestDelta := Delta;
      Result := I;
    end;
  end;
end;

procedure TFrameMeterValueEdit.ChartAppearanceChange(Sender: TObject);
begin
  if FLoading or FApplyingSettings then
    Exit;

  ReadSettingsFromControls(FTestSettings);
  FSettingsModified := True;
  FChartAppearanceModified := True;
  FModified := True;
  ApplyAndSaveStabilitySettings(False, True, True);
end;

function TFrameMeterValueEdit.DisplayUnitName: string;
begin
  Result := '';
  if FMeterValue <> nil then
    Result := FMeterValue.GetDimName;
end;

function TFrameMeterValueEdit.AppendUnit(const AText, AUnit: string): string;
begin
  Result := AText;
  if (Result <> '—') and (Trim(AUnit) <> '') then
    Result := Result + ' ' + AUnit;
end;

function TFrameMeterValueEdit.BaseToDisplayText(const AValue: Double): string;
begin
  if FMeterValue <> nil then
    Result := FMeterValue.FormatBaseValue(AValue)
  else
    Result := FloatToStr(AValue);
end;

function TFrameMeterValueEdit.ValueToCurrentDimension(const ABaseValue: Double): Double;
begin
  Result := ABaseValue;
  if IsNan(ABaseValue) or IsInfinite(ABaseValue) then
    Exit;

  if FMeterValue <> nil then
    Result := FMeterValue.BaseToDisplayValue(ABaseValue);
end;

function TFrameMeterValueEdit.BaseDeltaToDisplayText(const AValue: Double): string;
begin
  if FMeterValue <> nil then
    Result := FMeterValue.FormatBaseDeltaValue(AValue)
  else
    Result := FloatToStr(AValue);
end;


function TFrameMeterValueEdit.FormatBaseInfo(const AValue: Double;
  const AHasValue: Boolean): string;
begin
  if not AHasValue then
    Exit('—');
  Result := AppendUnit(BaseToDisplayText(AValue), DisplayUnitName);
end;

function TFrameMeterValueEdit.FormatBaseDeltaInfo(const AValue: Double;
  const AHasValue: Boolean): string;
begin
  if not AHasValue then
    Exit('—');
  Result := AppendUnit(BaseDeltaToDisplayText(AValue), DisplayUnitName);
end;

function TFrameMeterValueEdit.DisplayToBase(const AText: string): Double;
begin
  if FMeterValue <> nil then
    Result := FMeterValue.DisplayToBaseValue(SafeFloat(AText))
  else
    Result := SafeFloat(AText);
end;

function TFrameMeterValueEdit.DisplayDeltaToBase(const AText: string): Double;
begin
  if FMeterValue <> nil then
    Result := FMeterValue.DisplayDeltaToBaseValue(SafeFloat(AText))
  else
    Result := SafeFloat(AText);
end;

procedure TFrameMeterValueEdit.UpdateDimensionCaptions;
var
  UnitName: string;

  procedure SetLabelText(const AName, AText: string);
  var
    LabelControl: TLabel;
  begin
    LabelControl := FindComponent(AName) as TLabel;
    if LabelControl <> nil then
      LabelControl.Text := AText;
  end;

begin
  UnitName := DisplayUnitName;
  if StringColumnSampleValue <> nil then
    StringColumnSampleValue.Header := 'Значение, ' + UnitName;
  SetLabelText('LabelStabilityDisplayUnit', 'Единица измерения: ' + UnitName);
  SetLabelText('LabelSampleValue', 'Значение, ' + UnitName);
  SetLabelText('LabelGeneratorStartValue', 'Начальное значение, ' + UnitName);
  SetLabelText('LabelGeneratorTrend', 'Тренд, ' + UnitName + '/с');
  SetLabelText('LabelGeneratorNoise', 'Шум ±, ' + UnitName);
  SetLabelText('LabelGeneratorOutlierAmplitude', 'Амплитуда выброса, ' + UnitName);
  SetLabelText('LabelMinSampleCount', 'Минимальное количество отсчётов, шт.');
  SetLabelText('LabelWindowDurationSec', 'Длительность окна, с');
  SetLabelText('LabelMaxSampleAgeSec', 'Максимальный возраст данных, с');
  SetLabelText('LabelConfirmationTimeSec', 'Время подтверждения, с');
  SetLabelText('LabelMaxVariation', 'Максимальный размах, ' + UnitName);
  SetLabelText('LabelMaxStdDeviation', 'Максимальное стандартное отклонение, ' + UnitName);
  SetLabelText('LabelMaxTrendRate', 'Максимальная скорость тренда, ' + UnitName + ' за с');
  SetLabelText('LabelMaxOutlierFractionPercent', 'Максимальная доля выбросов, %');
  SetLabelText('LabelForecastHorizonSec', 'Горизонт прогноза, с');
  SetLabelText('LabelTestTargetValue', 'Целевое значение, ' + UnitName);
  SetLabelText('LabelTargetToleranceAbsolute', 'Минимальный абсолютный допуск, ' + UnitName);
  SetLabelText('LabelTargetLowerLimit', 'Нижняя граница, ' + UnitName);
  SetLabelText('LabelTargetUpperLimit', 'Верхняя граница, ' + UnitName);
  UpdateStabilityHints;
end;


procedure TFrameMeterValueEdit.UpdateStabilityHints;
var
  UnitName: string;

  procedure SetHintFor(const AName, AHint: string);
  var
    Component: TComponent;
  begin
    Component := FindComponent(AName);
    if Component is TControl then
    begin
      TControl(Component).Hint := AHint;
      TControl(Component).ShowHint := True;
      if Component is TLabel then
        TLabel(Component).HitTest := True;
    end;
  end;

  procedure SetLabelHint(const ALabelName, AHint: string);
  begin
    SetHintFor(ALabelName, AHint);
  end;

begin
  UnitName := DisplayUnitName;
  SetHintFor('LabelStabilityDisplayUnit', 'Единица, выбранная для отображения текущего TMeterValue. Все размерные значения результатов и соответствующие настройки показываются в этой единице. Внутреннее хранение может выполняться в базовой единице.');
  SetHintFor('CheckBoxStabilityEnabled', 'Включает расчет стабильности и пригодности значения. При отключении анализ не подтверждает готовность измерения.');
  SetHintFor('ComboBoxSampleSource', 'Выбирает массив для preview-анализа. История TMeterValue использует рабочую историю текущего значения. Тестовый массив не изменяет рабочую историю.');
  SetLabelHint('LabelMinSampleCount', 'Минимальное число допустимых точек в текущем окне, необходимое для расчёта статистики. Если после исключения выбросов их меньше указанного числа, анализ возвращает недостаточно данных. Единица: шт.');
  SetLabelHint('LabelWindowDurationSec', 'Длительность интервала истории, используемого для анализа стабильности. Учитываются точки от текущего времени анализа минус указанное число секунд до текущего времени. Более длинное окно сглаживает кратковременные изменения, но медленнее реагирует на смену режима. Единица: с.');
  SetLabelHint('LabelMaxSampleAgeSec', 'Максимально допустимое время с момента последней точки до текущего времени анализа. Если последняя точка старше указанного значения, данные считаются устаревшими. Единица: с.');
  SetLabelHint('LabelConfirmationTimeSec', 'Минимальное время, в течение которого сигнал должен непрерывно удовлетворять условиям стабильности, прежде чем стабильность будет подтверждена. Точки этого периода отмечаются в таблице как “Стаб”. Единица: с.');
  SetLabelHint('LabelExitThresholdFactor', 'Множитель порогов после подтверждения стабильности. Большее значение создаёт гистерезис и снижает частые переключения, меньшее быстрее снимает подтверждение. Безразмерная величина.');
  SetLabelHint('LabelMaxVariation', 'Максимально допустимый размах между минимумом и максимумом в использованных точках. Единица: ' + UnitName + '. Чем меньше порог, тем строже проверка стабильности.');
  SetLabelHint('LabelMaxStdDeviation', 'Стандартное отклонение характеризует абсолютный разброс значений и имеет ту же физическую единицу, что и измеряемая величина. Это не процент, если отдельно не указано относительное стандартное отклонение. Единица: ' + UnitName + '.');
  SetLabelHint('LabelMaxTrendRate', 'Максимально допустимая абсолютная скорость изменения по линейному тренду. Единица: ' + UnitName + ' за с. Меньшее значение строже ограничивает дрейф сигнала.');
  SetLabelHint('LabelMaxOutlierFractionPercent', 'Максимальная допустимая доля выбросов среди точек текущего окна. При превышении порога результат может быть признан непригодным или недостаточным. Единица: %.');
  SetLabelHint('LabelOutlierFactor', 'Коэффициент чувствительности обнаружения выбросов на основе медианного абсолютного отклонения. Меньшее значение выявляет больше выбросов, большее значение делает фильтр менее чувствительным. Безразмерная величина.');
  SetLabelHint('LabelForecastHorizonSec', 'Интервал времени вперёд, на который рассчитывается прогноз по текущему тренду. Чем больше горизонт, тем сильнее влияние небольшого наклона тренда на прогноз. Единица: с.');
  SetLabelHint('LabelTestTargetValue', 'Целевое значение для проверки текущего, среднего и прогнозируемого значения. Значение задаётся в выбранной единице TMeterValue: ' + UnitName + '.');
  SetLabelHint('LabelTargetToleranceAbsolute', 'Минимальный абсолютный допуск целевого диапазона. Единица: ' + UnitName + '. Используется вместе с процентными допусками и влияет на итоговую пригодность.');
  SetHintFor('CheckBoxRequireCurrentValueInRange', 'Проверяет попадание текущего значения в целевой диапазон. Если условие включено и не выполнено, значение непригодно.');
  SetHintFor('CheckBoxRequireMeanValueInRange', 'Проверяет попадание среднего значения в целевой диапазон. Если условие включено и не выполнено, значение непригодно.');
  SetHintFor('CheckBoxRequireForecastInRange', 'Проверяет попадание прогнозного значения в целевой диапазон. Если условие включено и не выполнено, значение непригодно.');
  SetLabelHint('LabelTargetLowerLimit', 'Расчётная нижняя граница допустимого диапазона. Показывается в выбранной единице TMeterValue: ' + UnitName + '.');
  SetLabelHint('LabelTargetUpperLimit', 'Расчётная верхняя граница допустимого диапазона. Показывается в выбранной единице TMeterValue: ' + UnitName + '.');
  SetHintFor('LabelAnalysisTime', 'Момент, относительно которого формируется временное окно, проверяется возраст последней точки и рассчитывается прогноз. Единица: с либо Unix-время — согласно выбранному режиму отображения.');
  SetHintFor('CheckBoxAutoAnalyze', 'Автоматически повторяет preview-анализ после изменения данных, настроек или текущего времени. При отключении изменения не очищают историю, но результат требует ручного пересчёта.');
end;

function TFrameMeterValueEdit.GetDisplayedSamples: TArray<TMeterValueSample>;
begin
  Result := GetDisplayedStabilitySamples;
end;

function TFrameMeterValueEdit.GetDisplayedStabilitySamples: TArray<TMeterValueSample>;
begin
  case FSampleSource of
    mssWorkHistory:
      if FMeterValue <> nil then
        Result := FMeterValue.GetStabilitySamples
      else
        SetLength(Result, 0);
  else
    Result := FTestSamples.ToArray;
  end;
end;

procedure TFrameMeterValueEdit.SortDisplayedSamples;
begin
  TArray.Sort<TMeterValueSample>(FDisplayedSamples,
    TComparer<TMeterValueSample>.Construct(
      function(const L, R: TMeterValueSample): Integer
      begin
        Result := CompareValue(L.TimeStampMs, R.TimeStampMs);
      end));
end;

procedure TFrameMeterValueEdit.RefreshDisplayedSamples;
begin
  FDisplayedSamples := GetDisplayedStabilitySamples;
  SortDisplayedSamples;
end;

function TFrameMeterValueEdit.CanRunStabilityAutoRefresh: Boolean;
begin
  Result := (not FLoading) and
    (not (csDestroying in ComponentState)) and
    (FMeterValue <> nil) and
    (CheckBoxAutoAnalyze <> nil) and CheckBoxAutoAnalyze.IsChecked and
    (CheckBoxStabilityEnabled <> nil) and CheckBoxStabilityEnabled.IsChecked;
end;

procedure TFrameMeterValueEdit.UpdateStabilityAutoRefreshTimer;
begin
  if TimerStabilityAutoRefresh = nil then
    Exit;

  if csDestroying in ComponentState then
  begin
    TimerStabilityAutoRefresh.Enabled := False;
    Exit;
  end;

  TimerStabilityAutoRefresh.Enabled := CanRunStabilityAutoRefresh;
end;

procedure TFrameMeterValueEdit.TimerStabilityAutoRefreshTimer(Sender: TObject);
begin
  if FStabilityTimerUpdating then
    Exit;
  if csDestroying in ComponentState then
    Exit;
  if not CanRunStabilityAutoRefresh then
  begin
    UpdateStabilityAutoRefreshTimer;
    Exit;
  end;

  FStabilityTimerUpdating := True;
  try
    RefreshStabilityHistoryAndAnalysis;
  finally
    FStabilityTimerUpdating := False;
  end;
end;

procedure TFrameMeterValueEdit.RefreshStabilityHistoryAndAnalysis;
var
  WasLastRow: Boolean;
  SelectedTimeStampMs: Int64;
  SelectedRow: Integer;
  I: Integer;
begin
  if (GridSamples <> nil) and GridSamples.IsFocused and (FSampleSource = mssTestSamples) then
    Exit;
  if not CanRunStabilityAutoRefresh then
    Exit;

  SelectedRow := GridSamples.Row;
  WasLastRow := (SelectedRow >= 0) and (SelectedRow = GridSamples.RowCount - 1);
  SelectedTimeStampMs := -1;
  if (SelectedRow >= 0) and (SelectedRow < Length(FDisplayedSamples)) and
     (GetSampleIndexForGridRow(SelectedRow) >= 0) then
    SelectedTimeStampMs := FDisplayedSamples[GetSampleIndexForGridRow(SelectedRow)].TimeStampMs;

  RefreshDisplayedSamples;
  if FSampleSource = mssWorkHistory then
    FTestCurrentTimeMs := TThread.GetTickCount64;
  RefreshSamplesGrid(False);

  if WasLastRow and (GridSamples.RowCount > 0) then
    GridSamples.Row := GridSamples.RowCount - 1
  else if SelectedTimeStampMs >= 0 then
    for I := 0 to High(FDisplayedSamples) do
      if FDisplayedSamples[I].TimeStampMs = SelectedTimeStampMs then
      begin
        GridSamples.Row := GetGridRowForSampleIndex(I);
        Break;
      end;
  GridSamples.Selected := GridSamples.Row;

  AnalyzeDisplayedSamples(False, False, False);
  UpdateStabilityChart;
end;

procedure TFrameMeterValueEdit.SetAnalysisTimeByLastDisplayedSample;
begin
  if Length(FDisplayedSamples) = 0 then
    Exit;
  FTestCurrentTimeMs := FDisplayedSamples[High(FDisplayedSamples)].TimeStampMs;
  EditAnalysisTime.Text := FloatToStr(FTestCurrentTimeMs / 1000.0);
end;

procedure TFrameMeterValueEdit.SetSampleSource(const ASource: TMeterValueSampleSource);
begin
  FSampleSource := ASource;
  if ComboBoxSampleSource <> nil then
    ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
  UpdateSampleSourceControls;
  RefreshSamplesGrid;
  if FSampleSource = mssWorkHistory then
    Analyze
  else
    AnalyzeIfNeeded;
  UpdateStabilityAutoRefreshTimer;
end;

procedure TFrameMeterValueEdit.UpdateSampleSourceControls;
var
  IsTestMode: Boolean;
  ScenarioGroup: TControl;
  GeneratorGroup: TControl;
begin
  IsTestMode := FSampleSource = mssTestSamples;
  EditSampleTime.Enabled := True;
  EditSampleTime.ReadOnly := (FSampleSource = mssWorkHistory) and (GridSamples.Row >= 0);
  EditSampleValue.Enabled := True;
  EditSampleValue.ReadOnly := False;
  EditSampleTimeStep.Enabled := True;
  EditSampleTimeStep.ReadOnly := False;
  ButtonSampleAdd.Enabled := True;
  ButtonSampleEdit.Enabled := GridSamples.Row >= 0;
  ButtonSampleDelete.Enabled := GridSamples.Row >= 0;
  ButtonSamplesClear.Enabled := Length(FDisplayedSamples) > 0;
  ComboBoxStabilityScenario.Enabled := IsTestMode;
  ButtonApplyScenario.Enabled := IsTestMode;
  EditGeneratorStartValue.Enabled := IsTestMode;
  EditGeneratorCount.Enabled := IsTestMode;
  EditGeneratorTimeStep.Enabled := IsTestMode;
  EditGeneratorTrend.Enabled := IsTestMode;
  EditGeneratorNoise.Enabled := IsTestMode;
  EditGeneratorOutlierProbability.Enabled := IsTestMode;
  EditGeneratorOutlierAmplitude.Enabled := IsTestMode;
  ButtonGenerateNew.Enabled := IsTestMode;
  ButtonGenerateAppend.Enabled := IsTestMode;
  EditAnalysisTime.Enabled := IsTestMode;
  if ButtonRefreshHistory <> nil then
    ButtonRefreshHistory.Enabled := not IsTestMode;
  if ButtonUseLastSampleTime <> nil then
    ButtonUseLastSampleTime.Enabled := not IsTestMode;
  ScenarioGroup := FindComponent('GroupStabilityScenario') as TControl;
  if ScenarioGroup <> nil then
    ScenarioGroup.Visible := IsTestMode;
  GeneratorGroup := FindComponent('GroupSamplesGenerator') as TControl;
  if GeneratorGroup <> nil then
    GeneratorGroup.Visible := IsTestMode;
end;

procedure TFrameMeterValueEdit.ComboBoxSampleSourceChange(Sender: TObject);
begin
  if FLoading then
    Exit;
  if ComboBoxSampleSource.ItemIndex = Ord(mssTestSamples) then
    SetSampleSource(mssTestSamples)
  else
    SetSampleSource(mssWorkHistory);
end;

procedure TFrameMeterValueEdit.TabControlStabilityChange(Sender: TObject);
begin
  if TabControlStability.ActiveTab = TabItemStabilityChart then
    UpdateStabilityChart;
end;

procedure TFrameMeterValueEdit.ButtonRefreshHistoryClick(Sender: TObject);
var
  BeforeSamples: TArray<TMeterValueSample>;
  AfterSamples: TArray<TMeterValueSample>;
  SelectedTimeStampMs: Int64;
  BestIndex: Integer;
  I: Integer;

  function BoundaryText(const ASamples: TArray<TMeterValueSample>): string;
  begin
    if Length(ASamples) = 0 then
      Result := 'empty'
    else
      Result := Format('first=%d last=%d', [ASamples[0].TimeStampMs,
        ASamples[High(ASamples)].TimeStampMs]);
  end;

begin
  if FSampleSource <> mssWorkHistory then
    Exit;

  SelectedTimeStampMs := -1;
  if (GridSamples.Row >= 0) and (GridSamples.Row < Length(FDisplayedSamples)) then
    SelectedTimeStampMs := FDisplayedSamples[GetSampleIndexForGridRow(GridSamples.Row)].TimeStampMs;

  if FMeterValue <> nil then
    BeforeSamples := FMeterValue.GetStabilitySamples
  else
    SetLength(BeforeSamples, 0);

  RefreshSamplesGrid(True);
  if (SelectedTimeStampMs >= 0) and (Length(FDisplayedSamples) > 0) then
  begin
    BestIndex := 0;
    for I := 0 to High(FDisplayedSamples) do
    begin
      if Abs(FDisplayedSamples[I].TimeStampMs - SelectedTimeStampMs) <
        Abs(FDisplayedSamples[BestIndex].TimeStampMs - SelectedTimeStampMs) then
        BestIndex := I;
      if FDisplayedSamples[I].TimeStampMs = SelectedTimeStampMs then
      begin
        BestIndex := I;
        Break;
      end;
    end;
    GridSamples.Row := GetGridRowForSampleIndex(BestIndex);
    GridSamples.Selected := GridSamples.Row;
    LoadSampleToEditor(GridSamples.Row);
  end;

  if Length(FDisplayedSamples) = 0 then
  begin
    ClearTestAnalysis;
    MemoConclusion.Lines.Text := 'В рабочей истории нет данных';
  end
  else if CheckBoxAutoAnalyze.IsChecked then
    AnalyzeDisplayedSamples(False, True)
  else
  begin
    ClearTestAnalysis;
    MemoConclusion.Lines.Text := 'История обновлена. Выполните пересчёт.';
    RefreshSamplesGrid(False);
  end;

  if FMeterValue <> nil then
    AfterSamples := FMeterValue.GetStabilitySamples
  else
    SetLength(AfterSamples, 0);

  DebugLog(Format('ButtonRefreshHistory: before count=%d %s; after count=%d %s',
    [Length(BeforeSamples), BoundaryText(BeforeSamples), Length(AfterSamples),
     BoundaryText(AfterSamples)]));
end;

procedure TFrameMeterValueEdit.ButtonUseLastSampleTimeClick(Sender: TObject);
begin
  if Length(FDisplayedSamples) = 0 then
    Exit;
  SetAnalysisTimeByLastDisplayedSample;
  AnalyzeIfNeeded;
end;

function TFrameMeterValueEdit.SampleSecondsToMs(const ASeconds: Double): Int64;
begin
  Result := Round(ASeconds * 1000);
end;

function TFrameMeterValueEdit.GetSampleIndexForGridRow(const ARow: Integer): Integer;
begin
  Result := -1;
  if (ARow >= 0) and (ARow < Length(FDisplayedSamples)) then
    Result := Length(FDisplayedSamples) - 1 - ARow;
end;

function TFrameMeterValueEdit.GetGridRowForSampleIndex(const AIndex: Integer): Integer;
begin
  Result := -1;
  if (AIndex >= 0) and (AIndex < Length(FDisplayedSamples)) then
    Result := Length(FDisplayedSamples) - 1 - AIndex;
end;

function TFrameMeterValueEdit.SelectedSampleIndex: Integer;
begin
  Result := -1;
  if GridSamples <> nil then
    Result := GetSampleIndexForGridRow(GridSamples.Row);
end;

procedure TFrameMeterValueEdit.LoadSampleToEditor(const AIndex: Integer);
var
  SampleIndex: Integer;
begin
  SampleIndex := GetSampleIndexForGridRow(AIndex);
  if SampleIndex < 0 then
    Exit;

  EditSampleTime.Text := FloatToStr((FDisplayedSamples[SampleIndex].TimeStampMs -
    FDisplayedSamples[0].TimeStampMs) / 1000);
  EditSampleValue.Text := BaseToDisplayText(FDisplayedSamples[SampleIndex].Value);
end;

procedure TFrameMeterValueEdit.RefreshSamplesGrid(const AReload: Boolean);
begin
  GridSamples.BeginUpdate;
  try
    if AReload then
      RefreshDisplayedSamples;
    GridSamples.RowCount := Length(FDisplayedSamples);
  finally
    GridSamples.EndUpdate;
  end;

  if GridSamples.Row >= Length(FDisplayedSamples) then
    GridSamples.Row := Length(FDisplayedSamples) - 1;
  GridSamples.Selected := GridSamples.Row;
  if Length(FDisplayedSamples) = 0 then
  begin
    EditSampleTime.Text := '';
    EditSampleValue.Text := '';
  end;
  GridSamples.Repaint;
  UpdateSampleSourceControls;
  UpdateStabilityChart;
end;

procedure TFrameMeterValueEdit.SortSamples;
var
  I: Integer;
  J: Integer;
  Tmp: TMeterValueSample;
begin
  for I := 0 to FTestSamples.Count - 2 do
    for J := I + 1 to FTestSamples.Count - 1 do
      if FTestSamples[J].TimeStampMs < FTestSamples[I].TimeStampMs then
      begin
        Tmp := FTestSamples[I];
        FTestSamples[I] := FTestSamples[J];
        FTestSamples[J] := Tmp;
      end;
end;

procedure TFrameMeterValueEdit.AddSample;
var
  I: Integer;
  Sample: TMeterValueSample;
  StepSec: Double;
begin
  Sample.Value := DisplayToBase(EditSampleValue.Text);
  StepSec := SafeFloat(EditSampleTimeStep.Text);
  if StepSec <= 0 then
  begin
    StepSec := 1.0;
    EditSampleTimeStep.Text := FloatToStr(StepSec);
  end;

  if FSampleSource = mssWorkHistory then
  begin
    if Length(FDisplayedSamples) > 0 then
      Sample.TimeStampMs := FDisplayedSamples[0].TimeStampMs + SampleSecondsToMs(SafeFloat(EditSampleTime.Text))
    else
      Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(EditSampleTime.Text));
    if (FMeterValue <> nil) and FMeterValue.AddStabilitySampleManual(Sample.TimeStampMs, Sample.Value) then
    begin
      RefreshSamplesGrid(True);
      GridSamples.Row := 0;
      GridSamples.Selected := GridSamples.Row;
      LoadSampleToEditor(GridSamples.Row);
      AnalyzeIfNeeded;
    end;
    Exit;
  end;

  if FTestSamples.Count = 0 then
    Sample.TimeStampMs := 0
  else
    Sample.TimeStampMs := FTestSamples[FTestSamples.Count - 1].TimeStampMs +
      SampleSecondsToMs(StepSec);

  FTestSamples.Add(Sample);
  SortSamples;
  RefreshSamplesGrid;
  for I := 0 to FTestSamples.Count - 1 do
    if (FTestSamples[I].TimeStampMs = Sample.TimeStampMs) and
       SameValue(FTestSamples[I].Value, Sample.Value) then
    begin
      GridSamples.Row := GetGridRowForSampleIndex(I);
      GridSamples.Selected := GridSamples.Row;
      Break;
    end;
  LoadSampleToEditor(GridSamples.Row);
  FTestDataModified := True;
  AnalyzeIfNeeded;
  EditSampleValue.SetFocus;
end;

procedure TFrameMeterValueEdit.EditSelectedSample;
var
  Index: Integer;
  I: Integer;
  Sample: TMeterValueSample;
begin
  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

  Sample := FDisplayedSamples[Index];
  Sample.Value := DisplayToBase(EditSampleValue.Text);

  if FSampleSource = mssWorkHistory then
  begin
    if (FMeterValue <> nil) and FMeterValue.UpdateStabilitySampleValue(Index, Sample.Value) then
    begin
      RefreshSamplesGrid(True);
      GridSamples.Row := GetGridRowForSampleIndex(Index);
      GridSamples.Selected := GridSamples.Row;
      LoadSampleToEditor(GridSamples.Row);
      AnalyzeIfNeeded;
    end;
    Exit;
  end;

  if Length(FDisplayedSamples) > 0 then
    Sample.TimeStampMs := FDisplayedSamples[0].TimeStampMs + SampleSecondsToMs(SafeFloat(EditSampleTime.Text))
  else
    Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(EditSampleTime.Text));
  FTestSamples[Index] := Sample;
  SortSamples;
  RefreshSamplesGrid;

  for I := 0 to FTestSamples.Count - 1 do
    if (FTestSamples[I].TimeStampMs = Sample.TimeStampMs) and
       SameValue(FTestSamples[I].Value, Sample.Value) then
    begin
      GridSamples.Row := GetGridRowForSampleIndex(I);
      GridSamples.Selected := GridSamples.Row;
      Break;
    end;

  LoadSampleToEditor(GridSamples.Row);
  FTestDataModified := True;
  AnalyzeIfNeeded;
end;

procedure TFrameMeterValueEdit.DeleteSelectedSample;
var
  Index: Integer;
begin
  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

  if FSampleSource = mssWorkHistory then
  begin
    if (FMeterValue <> nil) and FMeterValue.DeleteStabilitySample(Index) then
    begin
      RefreshSamplesGrid(True);
      AnalyzeIfNeeded;
    end;
    Exit;
  end;

  FTestSamples.Delete(Index);
  RefreshSamplesGrid;
  if GridSamples.Row >= 0 then
    LoadSampleToEditor(GridSamples.Row)
  else
  begin
    EditSampleTime.Text := '';
    EditSampleValue.Text := '';
  end;
  FTestDataModified := True;
  AnalyzeIfNeeded;
end;

procedure TFrameMeterValueEdit.SetConclusionIndicator(const ARectangle: TRectangle;
  const ALabel: TLabel; const AText: string; const AColor: TAlphaColor);
begin
  if ARectangle <> nil then
    ARectangle.Fill.Color := AColor;
  if ALabel <> nil then
    ALabel.Text := AText;
end;

procedure TFrameMeterValueEdit.ResetConclusionIndicators;
begin
  SetConclusionIndicator(RectangleSignalStable, LabelSignalStableValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleStabilityConfirmed, LabelStabilityConfirmedValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleCurrentInRange, LabelCurrentInRangeValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleMeanInRange, LabelMeanInRangeValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleForecastInRange, LabelForecastInRangeValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleSuitable, LabelSuitableValue, '—', COLOR_NONE);
end;

procedure TFrameMeterValueEdit.UpdateConclusionIndicators(const AInfo: TMeterValueStabilityInfo);
var
  SuitableColor: TAlphaColor;
  RangeFailure: Boolean;
begin
  if AInfo.Status = mvssDisabled then
  begin
    ResetConclusionIndicators;
    Exit;
  end;

  if mvsfrNoData in AInfo.FailReasons then
  begin
    SetConclusionIndicator(RectangleSignalStable, LabelSignalStableValue, '—', COLOR_NONE);
    SetConclusionIndicator(RectangleStabilityConfirmed, LabelStabilityConfirmedValue, '—', COLOR_NONE);
    SetConclusionIndicator(RectangleCurrentInRange, LabelCurrentInRangeValue, '—', COLOR_NONE);
    SetConclusionIndicator(RectangleMeanInRange, LabelMeanInRangeValue, '—', COLOR_NONE);
    SetConclusionIndicator(RectangleForecastInRange, LabelForecastInRangeValue, '—', COLOR_NONE);
    SetConclusionIndicator(RectangleSuitable, LabelSuitableValue, 'НЕТ', COLOR_INVALID);
    Exit;
  end;

  if AInfo.IsSignalStable then
    SetConclusionIndicator(RectangleSignalStable, LabelSignalStableValue, 'ДА', COLOR_COMPLETED)
  else if mvsfrNotEnoughSamples in AInfo.FailReasons then
    SetConclusionIndicator(RectangleSignalStable, LabelSignalStableValue, 'НЕТ', COLOR_WARNING)
  else
    SetConclusionIndicator(RectangleSignalStable, LabelSignalStableValue, 'НЕТ', COLOR_WARNING);

  if AInfo.IsStabilityConfirmed then
    SetConclusionIndicator(RectangleStabilityConfirmed, LabelStabilityConfirmedValue, 'ДА', COLOR_COMPLETED)
  else if AInfo.IsSignalStable and (mvsfrWaitingForConfirmation in AInfo.FailReasons) then
    SetConclusionIndicator(RectangleStabilityConfirmed, LabelStabilityConfirmedValue, 'НЕТ', COLOR_RUNNING)
  else
    SetConclusionIndicator(RectangleStabilityConfirmed, LabelStabilityConfirmedValue, 'НЕТ', COLOR_WARNING);

  if AInfo.HasCurrentValue then
  begin
    if AInfo.IsCurrentValueInRange then
      SetConclusionIndicator(RectangleCurrentInRange, LabelCurrentInRangeValue, 'ДА', COLOR_COMPLETED)
    else
      SetConclusionIndicator(RectangleCurrentInRange, LabelCurrentInRangeValue, 'НЕТ', COLOR_INVALID);
  end
  else
    SetConclusionIndicator(RectangleCurrentInRange, LabelCurrentInRangeValue, '—', COLOR_NONE);

  if AInfo.HasStatistics then
  begin
    if AInfo.IsMeanValueInRange then
      SetConclusionIndicator(RectangleMeanInRange, LabelMeanInRangeValue, 'ДА', COLOR_COMPLETED)
    else
      SetConclusionIndicator(RectangleMeanInRange, LabelMeanInRangeValue, 'НЕТ', COLOR_INVALID);
  end
  else
    SetConclusionIndicator(RectangleMeanInRange, LabelMeanInRangeValue, '—', COLOR_NONE);

  if AInfo.HasForecast then
  begin
    if AInfo.IsForecastInRange then
      SetConclusionIndicator(RectangleForecastInRange, LabelForecastInRangeValue, 'ДА', COLOR_COMPLETED)
    else
      SetConclusionIndicator(RectangleForecastInRange, LabelForecastInRangeValue, 'НЕТ', COLOR_INVALID);
  end
  else
    SetConclusionIndicator(RectangleForecastInRange, LabelForecastInRangeValue, '—', COLOR_NONE);

  if AInfo.IsSuitableForMeasurement then
    SuitableColor := COLOR_COMPLETED
  else if mvsfrInvalidSettings in AInfo.FailReasons then
    SuitableColor := COLOR_INVALID
  else if (mvsfrNotEnoughSamples in AInfo.FailReasons) or
          (mvsfrInsufficientWindow in AInfo.FailReasons) then
    SuitableColor := COLOR_WARNING
  else if mvsfrStaleData in AInfo.FailReasons then
    SuitableColor := COLOR_INVALID
  else if not AInfo.IsSignalStable then
    SuitableColor := COLOR_WARNING
  else
  begin
    RangeFailure := (mvsfrCurrentValueOutOfRange in AInfo.FailReasons) or
      (mvsfrMeanValueOutOfRange in AInfo.FailReasons) or
      (mvsfrForecastOutOfRange in AInfo.FailReasons);
    if RangeFailure then
      SuitableColor := COLOR_INVALID
    else if mvsfrWaitingForConfirmation in AInfo.FailReasons then
      SuitableColor := COLOR_RUNNING
    else
      SuitableColor := COLOR_INVALID;
  end;
  SetConclusionIndicator(RectangleSuitable, LabelSuitableValue, BoolText(AInfo.IsSuitableForMeasurement), SuitableColor);
end;

procedure TFrameMeterValueEdit.ClearAnalysisDisplay;
const
  EmptyText = '—';
begin
  MemoConclusion.Lines.Clear;
  ResetConclusionIndicators;
  if EditResultSampleCount = nil then
    Exit;

  EditResultSampleCount.Text := EmptyText;
  EditResultUsedSampleCount.Text := EmptyText;
  EditResultOutlierCount.Text := EmptyText;
  EditResultOutlierFraction.Text := EmptyText;
  EditResultWindowDuration.Text := EmptyText;
  EditResultLastSampleAge.Text := EmptyText;
  EditResultCurrentValue.Text := EmptyText;
  EditResultMeanValue.Text := EmptyText;
  EditResultMinValue.Text := EmptyText;
  EditResultMaxValue.Text := EmptyText;
  EditResultVariation.Text := EmptyText;
  EditResultStdDeviation.Text := EmptyText;
  EditResultTrendRate.Text := EmptyText;
  EditResultTrendDirection.Text := EmptyText;
  EditResultForecastHorizon.Text := EmptyText;
  EditResultForecastValue.Text := EmptyText;
  EditResultForecastInRange.Text := EmptyText;
  ListBoxStabilityReasons.Items.Clear;
  MemoStabilityConclusion.Lines.Clear;
end;

procedure TFrameMeterValueEdit.ClearSamples;
begin
  if FSampleSource = mssWorkHistory then
  begin
    if FMeterValue <> nil then
      TDialogService.MessageDialog('Очистить историю TMeterValue?',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
        TMsgDlgBtn.mbNo, 0,
        procedure(const AResult: TModalResult)
        begin
          if AResult = mrYes then
          begin
            FMeterValue.ClearStabilitySamples;
            RefreshSamplesGrid(True);
            ClearAnalysisDisplay;
          end;
        end);
    Exit;
  end;

  FTestSamples.Clear;
  GridSamples.Row := -1;
  GridSamples.Selected := -1;
  RefreshSamplesGrid;
  EditSampleTime.Text := '';
  EditSampleValue.Text := '';
  ClearAnalysisDisplay;
  FTestDataModified := True;
  AnalyzeIfNeeded;
end;

function TFrameMeterValueEdit.ValidateGeneratorControls(out AErrorText: string): Boolean;
var
  CountValue: Integer;
  DoubleValue: Double;
begin
  Result := False;
  AErrorText := '';

  if not TryReadFloat(EditGeneratorStartValue.Text, DoubleValue) then
    AErrorText := 'Начальное значение должно быть корректным числом.'
  else if (not TryReadInteger(EditGeneratorCount.Text, CountValue)) or (CountValue <= 0) then
    AErrorText := 'Количество точек должно быть положительным целым числом.'
  else if CountValue > 100000 then
    AErrorText := 'Количество точек не должно превышать 100000.'
  else if (not TryReadFloat(EditGeneratorTimeStep.Text, DoubleValue)) or (DoubleValue <= 0) or
          (SampleSecondsToMs(DoubleValue) <= 0) then
    AErrorText := 'Шаг времени должен быть больше 0.'
  else if not TryReadFloat(EditGeneratorTrend.Text, DoubleValue) then
    AErrorText := 'Тренд должен быть корректным числом.'
  else if (not TryReadFloat(EditGeneratorNoise.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Случайный шум не может быть отрицательным.'
  else if (not TryReadFloat(EditGeneratorOutlierProbability.Text, DoubleValue)) or
          (DoubleValue < 0) or (DoubleValue > 100) then
    AErrorText := 'Вероятность выброса должна быть от 0 до 100 процентов.'
  else if (not TryReadFloat(EditGeneratorOutlierAmplitude.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Амплитуда выброса не может быть отрицательной.'
  else
    Result := True;
end;

procedure TFrameMeterValueEdit.GenerateSamples(const AClearExisting: Boolean);
var
  ErrorText: string;
  StartValue: Double;
  TrendRate: Double;
  NoiseAmplitude: Double;
  OutlierProbability: Double;
  OutlierAmplitude: Double;
  ElapsedTimeSec: Double;
  Value: Double;
  CountValue: Integer;
  TimeStepMs: Int64;
  BaseTimeMs: Int64;
  I: Integer;
  Sample: TMeterValueSample;
begin
  if FSampleSource <> mssTestSamples then
    SetSampleSource(mssTestSamples);

  if not ValidateGeneratorControls(ErrorText) then
  begin
    ShowMessage('Тестовый массив не создан.' + sLineBreak + ErrorText);
    Exit;
  end;

  StartValue := DisplayToBase(EditGeneratorStartValue.Text);
  TryReadInteger(EditGeneratorCount.Text, CountValue);
  TimeStepMs := SampleSecondsToMs(SafeFloat(EditGeneratorTimeStep.Text));
  TrendRate := DisplayDeltaToBase(EditGeneratorTrend.Text);
  NoiseAmplitude := Abs(DisplayDeltaToBase(EditGeneratorNoise.Text));
  TryReadFloat(EditGeneratorOutlierProbability.Text, OutlierProbability);
  OutlierAmplitude := Abs(DisplayDeltaToBase(EditGeneratorOutlierAmplitude.Text));
  OutlierProbability := OutlierProbability / 100.0;

  if AClearExisting then
  begin
    FTestSamples.Clear;
    BaseTimeMs := 0;
  end
  else if FTestSamples.Count = 0 then
    BaseTimeMs := 0
  else
    BaseTimeMs := FTestSamples[FTestSamples.Count - 1].TimeStampMs + TimeStepMs;

  ClearTestAnalysis;
  for I := 0 to CountValue - 1 do
  begin
    ElapsedTimeSec := (I * TimeStepMs) / 1000.0;
    Value := StartValue + TrendRate * ElapsedTimeSec;
    if NoiseAmplitude > 0 then
      Value := Value + (Random * 2.0 - 1.0) * NoiseAmplitude;
    if (OutlierAmplitude > 0) and (Random < OutlierProbability) then
      if Random < 0.5 then
        Value := Value - OutlierAmplitude
      else
        Value := Value + OutlierAmplitude;

    Sample.TimeStampMs := BaseTimeMs + I * TimeStepMs;
    Sample.Value := Value;
    FTestSamples.Add(Sample);
  end;

  SortSamples;
  RefreshSamplesGrid;
  if FTestSamples.Count > 0 then
  begin
    GridSamples.Row := 0;
    GridSamples.Selected := GridSamples.Row;
    LoadSampleToEditor(GridSamples.Row);
  end;
  FTestDataModified := True;
  FModified := True;
  AnalyzeIfNeeded;
end;

procedure TFrameMeterValueEdit.GenerateNewSamples;
begin
  GenerateSamples(True);
end;

procedure TFrameMeterValueEdit.AppendGeneratedSamples;
begin
  GenerateSamples(False);
end;

procedure TFrameMeterValueEdit.InitializeScenarioList;
begin
  ComboBoxStabilityScenario.Items.Clear;
  ComboBoxStabilityScenario.Items.Add('Постоянное значение');
  ComboBoxStabilityScenario.Items.Add('Стабильный шум');
  ComboBoxStabilityScenario.Items.Add('Медленный рост');
  ComboBoxStabilityScenario.Items.Add('Медленное снижение');
  ComboBoxStabilityScenario.Items.Add('Стабилизация после изменения');
  ComboBoxStabilityScenario.Items.Add('Единичный выброс');
  ComboBoxStabilityScenario.Items.Add('Много выбросов');
  ComboBoxStabilityScenario.Items.Add('Недостаточно данных');
  ComboBoxStabilityScenario.Items.Add('Устаревшие данные');
  ComboBoxStabilityScenario.Items.Add('Прогноз выше верхней границы');
  ComboBoxStabilityScenario.Items.Add('Прогноз ниже нижней границы');
  ComboBoxStabilityScenario.Items.Add('Стабильный сигнал вне диапазона');
  ComboBoxStabilityScenario.Items.Add('Все условия выполнены');
  ComboBoxStabilityScenario.ItemIndex := Ord(mtsConstantValue);
end;

procedure TFrameMeterValueEdit.RefreshAllTestControls;
begin
  EditAnalysisTime.Text := FloatToStr(FTestCurrentTimeMs / 1000.0);
  LoadSettingsToControls;
  RefreshSamplesGrid;
  if FTestSamples.Count > 0 then
  begin
    GridSamples.Row := 0;
    GridSamples.Selected := GridSamples.Row;
    LoadSampleToEditor(GridSamples.Row);
  end
  else
  begin
    GridSamples.Row := -1;
    GridSamples.Selected := -1;
    EditSampleTime.Text := '';
    EditSampleValue.Text := '';
  end;
end;

procedure TFrameMeterValueEdit.ApplySelectedScenario;
begin
  if FSampleSource <> mssTestSamples then
    SetSampleSource(mssTestSamples);

  if (ComboBoxStabilityScenario.ItemIndex < Ord(Low(TMeterValueTestScenario))) or
     (ComboBoxStabilityScenario.ItemIndex > Ord(High(TMeterValueTestScenario))) then
  begin
    ShowMessage('Сценарий не выбран.');
    Exit;
  end;
  ApplyScenario(TMeterValueTestScenario(ComboBoxStabilityScenario.ItemIndex));
end;

function TFrameMeterValueEdit.TryGetScenarioPointCount(out APointCount: Integer;
  const AShowError: Boolean): Boolean;
begin
  APointCount := 0;
  Result := (EditScenarioPointCount <> nil) and
    TryStrToInt(Trim(EditScenarioPointCount.Text), APointCount);
  Result := Result and (APointCount >= 2) and (APointCount <= 100000);
  if (not Result) and AShowError then
    ShowMessage('Количество точек сценария должно быть целым числом от 2 до 100000.');
end;

function TFrameMeterValueEdit.ScenarioDisplayName(
  const AScenario: TMeterValueTestScenario): string;
begin
  if (ComboBoxStabilityScenario <> nil) and (Ord(AScenario) >= 0) and
     (Ord(AScenario) < ComboBoxStabilityScenario.Items.Count) then
    Result := ComboBoxStabilityScenario.Items[Ord(AScenario)]
  else
    Result := IntToStr(Ord(AScenario));
end;

procedure TFrameMeterValueEdit.ApplyScenario(const AScenario: TMeterValueTestScenario);
var
  ScenarioPointCount: Integer;
  TimeStepSec: Double;
  I, Count, MidIndex, OutlierCount, StepMs, SettlingStart: Integer;
  BaseValue, Span: Double;
  IsStaleScenario: Boolean;

  procedure AddSamplePoint(const AIndex: Integer; const AValue: Double);
  var
    Sample: TMeterValueSample;
  begin
    Sample.TimeStampMs := Int64(AIndex) * StepMs;
    Sample.Value := DisplayToBase(FloatToStr(AValue));
    FTestSamples.Add(Sample);
  end;

  procedure SetBaseSettings;
  begin
    FillChar(FTestSettings, SizeOf(FTestSettings), 0);
    FTestSettings.Enabled := True;
    FTestSettings.MinSampleCount := 10;
    FTestSettings.WindowDurationSec := 10;
    FTestSettings.MaxSampleAgeSec := 3;
    FTestSettings.ConfirmationTimeSec := 3;
    FTestSettings.ExitThresholdFactor := 1.2;
    FTestSettings.MaxVariation := DisplayDeltaToBase('0.5');
    FTestSettings.MaxStdDeviation := DisplayDeltaToBase('0.1');
    FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.05');
    FTestSettings.MaxOutlierFraction := 0.10;
    FTestSettings.OutlierFactor := 3.5;
    FTestSettings.ForecastHorizonSec := 10;
    FTestSettings.TargetAccuracyPlusPercent := 1;
    FTestSettings.TargetAccuracyMinusPercent := 1;
    FTestSettings.TargetToleranceAbsolute := 0;
    FTestSettings.RequireCurrentValueInRange := True;
    FTestSettings.RequireMeanValueInRange := True;
    FTestSettings.RequireForecastInRange := True;
    FTestTargetValue := DisplayToBase('10');
  end;

begin
  if not TryGetScenarioPointCount(ScenarioPointCount, True) then
    Exit;
  TimeStepSec := SafeFloat(EditGeneratorTimeStep.Text);
  if TimeStepSec <= 0 then
    TimeStepSec := 1.0;
  StepMs := Max(1, Round(TimeStepSec * 1000.0));
  BaseValue := 10.0;
  IsStaleScenario := AScenario = mtsStaleData;

  FLoading := True;
  try
    ClearTestAnalysis;
    FTestSamples.Clear;
    FTestStableCandidateSinceMs := 0;
    FTestStabilityConfirmed := False;
    SetBaseSettings;

    Count := ScenarioPointCount;
    case AScenario of
      mtsConstantValue:
        for I := 0 to Count - 1 do
          AddSamplePoint(I, BaseValue);

      mtsStableNoise:
        begin
          FTestSettings.MaxVariation := DisplayDeltaToBase('0.10');
          FTestSettings.MaxStdDeviation := DisplayDeltaToBase('0.05');
          for I := 0 to Count - 1 do
            AddSamplePoint(I, BaseValue + ((I mod 5) - 2) * 0.01);
        end;

      mtsSlowIncrease:
        begin
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.01');
          Span := 0.20;
          for I := 0 to Count - 1 do
            AddSamplePoint(I, BaseValue + Span * I / Max(1, Count - 1));
        end;

      mtsSlowDecrease:
        begin
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.01');
          Span := 0.20;
          for I := 0 to Count - 1 do
            AddSamplePoint(I, BaseValue + Span - Span * I / Max(1, Count - 1));
        end;

      mtsSettlingAfterChange:
        begin
          FTestSettings.MaxSampleAgeSec := 10;
          SettlingStart := Max(1, Count div 3);
          for I := 0 to Count - 1 do
            if I < SettlingStart then
              AddSamplePoint(I, 5.0 + (BaseValue - 5.0) * I / Max(1, SettlingStart))
            else
              AddSamplePoint(I, BaseValue);
        end;

      mtsSingleOutlier:
        begin
          FTestTargetValue := DisplayToBase('29');
          BaseValue := 29.0;
          FTestSettings.MaxOutlierFraction := 0.11;
          MidIndex := Count div 2;
          for I := 0 to Count - 1 do
            if I = MidIndex then
              AddSamplePoint(I, BaseValue + 10.0)
            else
              AddSamplePoint(I, BaseValue + ((I mod 3) - 1) * 0.01);
        end;

      mtsManyOutliers:
        begin
          FTestTargetValue := DisplayToBase('29');
          BaseValue := 29.0;
          FTestSettings.MaxOutlierFraction := 0.10;
          OutlierCount := EnsureRange(Ceil(Count * (FTestSettings.MaxOutlierFraction + 0.05)), 2, Count);
          for I := 0 to Count - 1 do
            if (I > 0) and (I < Count - 1) and ((I mod Max(1, Count div OutlierCount)) = 0) then
              AddSamplePoint(I, BaseValue + 10.0)
            else
              AddSamplePoint(I, BaseValue);
        end;

      mtsNotEnoughData:
        begin
          Count := Min(ScenarioPointCount, Max(1, FTestSettings.MinSampleCount - 1));
          for I := 0 to Count - 1 do
            AddSamplePoint(I, BaseValue);
        end;

      mtsStaleData:
        begin
          for I := 0 to Count - 1 do
            AddSamplePoint(I, BaseValue);
          FTestCurrentTimeMs := FTestSamples[FTestSamples.Count - 1].TimeStampMs +
            Round((FTestSettings.WindowDurationSec + FTestSettings.MaxSampleAgeSec + 10.0) * 1000.0);
        end;

      mtsForecastAboveRange:
        begin
          FTestSettings.ForecastHorizonSec := 20;
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.05');
          FTestSettings.TargetAccuracyPlusPercent := 2;
          FTestSettings.TargetAccuracyMinusPercent := 2;
          for I := 0 to Count - 1 do
            AddSamplePoint(I, 9.80 + 0.20 * I / Max(1, Count - 1));
        end;

      mtsForecastBelowRange:
        begin
          FTestSettings.ForecastHorizonSec := 20;
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.05');
          FTestSettings.TargetAccuracyPlusPercent := 2;
          FTestSettings.TargetAccuracyMinusPercent := 2;
          for I := 0 to Count - 1 do
            AddSamplePoint(I, 10.20 - 0.20 * I / Max(1, Count - 1));
        end;

      mtsStableOutOfRange:
        for I := 0 to Count - 1 do
          AddSamplePoint(I, 0.0);

      mtsAllConditionsPassed:
        begin
          FTestSettings.MaxVariation := DisplayDeltaToBase('0.01');
          FTestSettings.MaxStdDeviation := DisplayDeltaToBase('0.01');
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.001');
          FTestSettings.MaxSampleAgeSec := 3;
          FTestSettings.ConfirmationTimeSec := 3;
          for I := 0 to Count - 1 do
            AddSamplePoint(I, BaseValue);
        end;
    end;

    FTestSettings.TargetValue := FTestTargetValue;
    SortSamples;
    if (FTestSamples.Count > 0) and not IsStaleScenario then
      FTestCurrentTimeMs := FTestSamples[FTestSamples.Count - 1].TimeStampMs;
    RefreshAllTestControls;
  finally
    FLoading := False;
  end;

  FTestDataModified := True;
  FSettingsModified := True;
  FModified := True;
  Analyze;
end;

function TFrameMeterValueEdit.BuildAllScenarioReport: string;
var
  Report, Summary: TStringList;
  ReportFormat: TFormatSettings;
  Scenario: TMeterValueTestScenario;
  Info: TMeterValueStabilityInfo;
  Samples, SavedDisplayedSamples: TArray<TMeterValueSample>;
  SavedSamples: TArray<TMeterValueSample>;
  SavedScenarioIndex, SavedRow: Integer;
  SavedCurrentTimeMs, SavedCandidateMs: Int64;
  SavedSettings: TMeterValueStabilitySettings;
  SavedInfo, SavedLastAnalysis: TMeterValueStabilityInfo;
  SavedTarget: Double;
  SavedConfirmed, SavedDataModified, SavedSettingsModified, SavedModified: Boolean;
  LowerLimit, UpperLimit: Double;
  I, ScenarioNo, PointCount: Integer;
  ReportTimeStepSec: Double;
  Reason: TMeterValueStabilityFailReason;
  Analysis: TMeterValueSampleAnalysis;

  function Fmt(const AValue: Double; const ADigits: Integer = 6): string;
  begin
    Result := FloatToStrF(AValue, ffFixed, 18, ADigits, ReportFormat);
  end;

  function B(const AValue: Boolean): string;
  begin
    if AValue then Result := 'True' else Result := 'False';
  end;

  function StatusName(const AStatus: TMeterValueStabilityStatus): string;
  begin
    case AStatus of
      mvssUnknown: Result := 'Unknown';
      mvssDisabled: Result := 'Disabled';
      mvssNotEnoughData: Result := 'NotEnoughData';
      mvssStaleData: Result := 'StaleData';
      mvssUnstable: Result := 'Unstable';
      mvssStable: Result := 'Stable';
    else
      Result := IntToStr(Ord(AStatus));
    end;
  end;

  function TrendName(const ADirection: TMeterValueTrendDirection): string;
  begin
    case ADirection of
      tdIncreasing: Result := 'Increasing';
      tdDecreasing: Result := 'Decreasing';
    else
      Result := 'None';
    end;
  end;

  function RangeText(const AHasValue, AInRange: Boolean): string;
  begin
    if not AHasValue then Result := 'N/A'
    else Result := B(AInRange);
  end;

  function FindResultByIndex(const ASourceIndex: Integer; out AResult: TMeterValueSampleAnalysis): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    AResult := Default(TMeterValueSampleAnalysis);
    for K := 0 to High(Info.SampleResults) do
      if Info.SampleResults[K].SourceIndex = ASourceIndex then
      begin
        AResult := Info.SampleResults[K];
        Exit(True);
      end;
  end;

  procedure AddResultBlock;
  begin
    Report.Add('РЕЗУЛЬТАТ:');
    Report.Add('Status=' + StatusName(Info.Status));
    Report.Add('StatusText=' + Info.StatusText);
    Report.Add('SampleCount=' + IntToStr(Info.SampleCount));
    Report.Add('UsedSampleCount=' + IntToStr(Info.UsedSampleCount));
    Report.Add('OutlierCount=' + IntToStr(Info.OutlierCount));
    Report.Add('OutlierFraction=' + Fmt(Info.OutlierFraction));
    Report.Add('WindowDurationSec=' + Fmt(Info.WindowDurationSec));
    Report.Add('LastSampleAgeSec=' + Fmt(Info.LastSampleAgeSec));
    Report.Add('CurrentValueBase=' + Fmt(Info.CurrentValue));
    Report.Add('CurrentValueDisplay=' + Fmt(ValueToCurrentDimension(Info.CurrentValue)) + ' ' + DisplayUnitName);
    Report.Add('MeanValueBase=' + Fmt(Info.MeanValue));
    Report.Add('MeanValueDisplay=' + Fmt(ValueToCurrentDimension(Info.MeanValue)) + ' ' + DisplayUnitName);
    Report.Add('MinValue=' + Fmt(Info.MinValue));
    Report.Add('MaxValue=' + Fmt(Info.MaxValue));
    Report.Add('Variation=' + Fmt(Info.Variation));
    Report.Add('StdDeviation=' + Fmt(Info.StdDeviation));
    Report.Add('TrendRate=' + Fmt(Info.TrendRate));
    Report.Add('TrendDirection=' + TrendName(Info.TrendDirection));
    Report.Add('ForecastValueBase=' + Fmt(Info.ForecastValue));
    Report.Add('ForecastValueDisplay=' + Fmt(ValueToCurrentDimension(Info.ForecastValue)) + ' ' + DisplayUnitName);
    Report.Add('HasCurrentValue=' + B(Info.HasCurrentValue));
    Report.Add('HasStatistics=' + B(Info.HasStatistics));
    Report.Add('HasTrend=' + B(Info.HasTrend));
    Report.Add('HasForecast=' + B(Info.HasForecast));
    Report.Add('HasEnoughSamples=' + B(Info.HasEnoughSamples));
    Report.Add('HasEnoughWindow=' + B(Info.HasEnoughWindow));
    Report.Add('IsDataActual=' + B(Info.IsDataActual));
    Report.Add('IsVariationStable=' + B(Info.IsVariationStable));
    Report.Add('IsDeviationStable=' + B(Info.IsDeviationStable));
    Report.Add('IsTrendStable=' + B(Info.IsTrendStable));
    Report.Add('IsOutlierLevelAcceptable=' + B(Info.IsOutlierLevelAcceptable));
    Report.Add('IsSignalStable=' + B(Info.IsSignalStable));
    Report.Add('IsStabilityConfirmed=' + B(Info.IsStabilityConfirmed));
    Report.Add('StableCandidateDurationSec=' + Fmt(Info.StableCandidateDurationSec));
    Report.Add('IsCurrentValueInRange=' + RangeText(Info.HasCurrentValue, Info.IsCurrentValueInRange));
    Report.Add('IsMeanValueInRange=' + RangeText(Info.HasStatistics, Info.IsMeanValueInRange));
    Report.Add('IsForecastInRange=' + RangeText(Info.HasForecast, Info.IsForecastInRange));
    Report.Add('IsSuitableForMeasurement=' + B(Info.IsSuitableForMeasurement));
    Report.Add('');
  end;

begin
  ReportFormat := TFormatSettings.Invariant;
  Report := TStringList.Create;
  Summary := TStringList.Create;
  try
    SavedScenarioIndex := ComboBoxStabilityScenario.ItemIndex;
    SavedRow := GridSamples.Row;
    SavedCurrentTimeMs := FTestCurrentTimeMs;
    SavedSettings := FTestSettings;
    SavedTarget := FTestTargetValue;
    SavedInfo := FTestStabilityInfo;
    SavedLastAnalysis := FLastTestAnalysis;
    SavedCandidateMs := FTestStableCandidateSinceMs;
    SavedConfirmed := FTestStabilityConfirmed;
    SavedDataModified := FTestDataModified;
    SavedSettingsModified := FSettingsModified;
    SavedModified := FModified;
    SavedDisplayedSamples := Copy(FDisplayedSamples);
    SetLength(SavedSamples, FTestSamples.Count);
    for I := 0 to FTestSamples.Count - 1 do
      SavedSamples[I] := FTestSamples[I];

    TryGetScenarioPointCount(PointCount, False);
    ReportTimeStepSec := SafeFloat(EditGeneratorTimeStep.Text);
    TryGetTestTargetLimits(LowerLimit, UpperLimit);
    Report.Add('ОТЧЁТ ПО ТЕСТОВЫМ СЦЕНАРИЯМ СТАБИЛЬНОСТИ');
    Report.Add('Дата и время: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    if FMeterValue <> nil then Report.Add('MeterValue: ' + FMeterValue.Name) else Report.Add('MeterValue:');
    Report.Add('Размерность: ' + DisplayUnitName);
    Report.Add('Количество точек сценария: ' + IntToStr(PointCount));
    Report.Add('Шаг времени: ' + EditGeneratorTimeStep.Text);
    Report.Add('Количество сценариев: ' + IntToStr(Ord(High(TMeterValueTestScenario)) - Ord(Low(TMeterValueTestScenario)) + 1));
    Report.Add('');
    Report.Add('НАСТРОЙКИ:');
    Report.Add('Enabled=' + B(FTestSettings.Enabled));
    Report.Add('MinSampleCount=' + IntToStr(FTestSettings.MinSampleCount));
    Report.Add('WindowDurationSec=' + Fmt(FTestSettings.WindowDurationSec));
    Report.Add('MaxSampleAgeSec=' + Fmt(FTestSettings.MaxSampleAgeSec));
    Report.Add('ConfirmationTimeSec=' + Fmt(FTestSettings.ConfirmationTimeSec));
    Report.Add('ExitThresholdFactor=' + Fmt(FTestSettings.ExitThresholdFactor));
    Report.Add('MaxVariation=' + Fmt(FTestSettings.MaxVariation));
    Report.Add('MaxStdDeviation=' + Fmt(FTestSettings.MaxStdDeviation));
    Report.Add('MaxTrendRate=' + Fmt(FTestSettings.MaxTrendRate));
    Report.Add('MaxOutlierFraction=' + Fmt(FTestSettings.MaxOutlierFraction));
    Report.Add('OutlierFactor=' + Fmt(FTestSettings.OutlierFactor));
    Report.Add('ForecastHorizonSec=' + Fmt(FTestSettings.ForecastHorizonSec));
    Report.Add('TargetValue=' + Fmt(FTestTargetValue));
    Report.Add('LowerLimit=' + Fmt(LowerLimit));
    Report.Add('UpperLimit=' + Fmt(UpperLimit));
    Report.Add('RequireCurrentValueInRange=' + B(FTestSettings.RequireCurrentValueInRange));
    Report.Add('RequireMeanValueInRange=' + B(FTestSettings.RequireMeanValueInRange));
    Report.Add('RequireForecastInRange=' + B(FTestSettings.RequireForecastInRange));
    Report.Add('');

    Summary.Add('СВОДКА');
    Summary.Add('№ | Сценарий | SignalStable | Confirmed | CurrentRange | MeanRange | ForecastRange | Suitable | Status');

    ScenarioNo := 0;
    for Scenario := Low(TMeterValueTestScenario) to High(TMeterValueTestScenario) do
    begin
      Inc(ScenarioNo);
      Report.Add('============================================================');
      Report.Add(Format('СЦЕНАРИЙ %.2d: %s', [ScenarioNo, ScenarioDisplayName(Scenario)]));
      Report.Add('============================================================');
      Report.Add('');
      try
        ComboBoxStabilityScenario.ItemIndex := Ord(Scenario);
        ApplyScenario(Scenario);
        Samples := FDisplayedSamples;
        TryGetTestTargetLimits(LowerLimit, UpperLimit);
        TMeterValue.AnalyzeStabilitySamples(Samples, FTestSettings, FTestCurrentTimeMs,
          FTestTargetValue, LowerLimit, UpperLimit, FTestStableCandidateSinceMs,
          FTestStabilityConfirmed, Info);
        FLastTestAnalysis := Info;

        Report.Add('ПАРАМЕТРЫ:');
        Report.Add('CurrentAnalysisTimeSec=' + Fmt(FTestCurrentTimeMs / 1000.0, 3));
        Report.Add('PointCount=' + IntToStr(Length(Samples)));
        if Length(Samples) > 0 then
        begin
          Report.Add('FirstTimeSec=' + Fmt(Samples[0].TimeStampMs / 1000.0, 3));
          Report.Add('LastTimeSec=' + Fmt(Samples[High(Samples)].TimeStampMs / 1000.0, 3));
        end;
        Report.Add('TimeStepSec=' + Fmt(ReportTimeStepSec, 3));
        Report.Add('');
        Report.Add('ДАННЫЕ:');
        Report.Add('№ | TimeSec | TimeStampMs | ValueBase | ValueDisplay | InWindow | IsOutlier | IsInRange | IsInConfirmationPeriod');
        for I := 0 to High(Samples) do
        begin
          FindResultByIndex(I, Analysis);
          Report.Add(Format('%d | %s | %d | %s | %s %s | %s | %s | %s | %s',
            [I + 1, Fmt(Samples[I].TimeStampMs / 1000.0, 3), Samples[I].TimeStampMs,
             Fmt(Samples[I].Value), Fmt(ValueToCurrentDimension(Samples[I].Value)), DisplayUnitName,
             B(Analysis.InWindow), B(Analysis.IsOutlier), B(Analysis.IsInRange),
             B(Analysis.IsInConfirmationPeriod)]));
        end;
        Report.Add('');
        AddResultBlock;
        Report.Add('FAIL REASONS:');
        if Info.FailReasons = [] then
          Report.Add('- причины отсутствуют')
        else
          for Reason := Low(TMeterValueStabilityFailReason) to High(TMeterValueStabilityFailReason) do
            if Reason in Info.FailReasons then
              Report.Add('- ' + StabilityFailReasonToText(Reason));
        Report.Add('');
        Report.Add('ЗАКЛЮЧЕНИЕ:');
        Report.Add(Info.StatusText);
        Report.Add('');
        Summary.Add(Format('%d | %s | %s | %s | %s | %s | %s | %s | %s',
          [ScenarioNo, ScenarioDisplayName(Scenario), B(Info.IsSignalStable),
           B(Info.IsStabilityConfirmed), RangeText(Info.HasCurrentValue, Info.IsCurrentValueInRange),
           RangeText(Info.HasStatistics, Info.IsMeanValueInRange),
           RangeText(Info.HasForecast, Info.IsForecastInRange), B(Info.IsSuitableForMeasurement),
           StatusName(Info.Status)]));
      except
        on E: Exception do
        begin
          Report.Add('ERROR:');
          Report.Add(E.ClassName + ': ' + E.Message);
          Report.Add('');
          Summary.Add(Format('%d | %s | ERROR | ERROR | N/A | N/A | N/A | ERROR | ERROR',
            [ScenarioNo, ScenarioDisplayName(Scenario)]));
        end;
      end;
    end;

    Report.AddStrings(Summary);
    Result := Report.Text;

    FLoading := True;
    try
      FTestSamples.Clear;
      for I := 0 to High(SavedSamples) do
        FTestSamples.Add(SavedSamples[I]);
      FDisplayedSamples := SavedDisplayedSamples;
      ComboBoxStabilityScenario.ItemIndex := SavedScenarioIndex;
      FTestCurrentTimeMs := SavedCurrentTimeMs;
      FTestSettings := SavedSettings;
      FTestTargetValue := SavedTarget;
      FTestStabilityInfo := SavedInfo;
      FLastTestAnalysis := SavedLastAnalysis;
      FTestStableCandidateSinceMs := SavedCandidateMs;
      FTestStabilityConfirmed := SavedConfirmed;
      FTestDataModified := SavedDataModified;
      FSettingsModified := SavedSettingsModified;
      FModified := SavedModified;
      RefreshAllTestControls;
      GridSamples.Row := SavedRow;
      GridSamples.Selected := SavedRow;
      DisplayAnalysis(FTestStabilityInfo);
    finally
      FLoading := False;
    end;
  finally
    Summary.Free;
    Report.Free;
  end;
end;

procedure TFrameMeterValueEdit.ButtonCopyAllScenarioLogsClick(Sender: TObject);
var
  ClipboardService: IFMXClipboardService;
  PlatformService: IInterface;
  ReportText: string;
  OldApplyEnabled, OldCopyEnabled: Boolean;
  OldCursor: TCursor;
  PointCount: Integer;
begin
  if not TryGetScenarioPointCount(PointCount, True) then
    Exit;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, PlatformService) then
  begin
    ShowMessage('Не удалось получить доступ к буферу обмена.');
    Exit;
  end;
  ClipboardService := PlatformService as IFMXClipboardService;

  OldApplyEnabled := ButtonApplyScenario.Enabled;
  OldCopyEnabled := ButtonCopyAllScenarioLogs.Enabled;
  OldCursor := Screen.Cursor;
  ButtonApplyScenario.Enabled := False;
  ButtonCopyAllScenarioLogs.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    ReportText := BuildAllScenarioReport;
    ClipboardService.SetClipboard(ReportText);
    ShowMessage('Отчёт по всем сценариям скопирован в буфер обмена.');
  finally
    Screen.Cursor := OldCursor;
    ButtonApplyScenario.Enabled := OldApplyEnabled;
    ButtonCopyAllScenarioLogs.Enabled := OldCopyEnabled;
  end;
end;

procedure TFrameMeterValueEdit.ButtonSampleAddClick(Sender: TObject);
begin
  AddSample;
end;

procedure TFrameMeterValueEdit.ButtonSampleEditClick(Sender: TObject);
begin
  EditSelectedSample;
end;

procedure TFrameMeterValueEdit.ButtonSampleDeleteClick(Sender: TObject);
begin
  DeleteSelectedSample;
end;

procedure TFrameMeterValueEdit.ButtonSamplesClearClick(Sender: TObject);
begin
  ClearSamples;
end;

procedure TFrameMeterValueEdit.ButtonAnalyzeClick(Sender: TObject);
begin
  AnalyzeDisplayedSamples(False, True, False);
end;

procedure TFrameMeterValueEdit.ButtonGenerateNewClick(Sender: TObject);
begin
  GenerateNewSamples;
end;

procedure TFrameMeterValueEdit.ButtonGenerateAppendClick(Sender: TObject);
begin
  AppendGeneratedSamples;
end;

procedure TFrameMeterValueEdit.ButtonApplyScenarioClick(Sender: TObject);
begin
  ApplySelectedScenario;
end;

procedure TFrameMeterValueEdit.GridSamplesCellDblClick(const Column: TColumn;
  const Row: Integer);
begin
  if (Row >= 0) and (Row < Length(FDisplayedSamples)) then
  begin
    GridSamples.Row := Row;
    GridSamples.Selected := Row;
    LoadSampleToEditor(Row);
  end;
end;


procedure TFrameMeterValueEdit.GridSamplesGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  AResult: TMeterValueSampleAnalysis;
begin
  if (ARow < 0) or (ARow >= Length(FDisplayedSamples)) then
    Exit;

  case ACol of
    0: Value := IntToStr(ARow + 1);
    1: Value := FloatToStr((FDisplayedSamples[GetSampleIndexForGridRow(ARow)].TimeStampMs - FDisplayedSamples[0].TimeStampMs) / 1000);
    2: Value := IntToStr(FDisplayedSamples[GetSampleIndexForGridRow(ARow)].TimeStampMs);
    3: Value := BaseToDisplayText(FDisplayedSamples[GetSampleIndexForGridRow(ARow)].Value);
    4: if FindSampleAnalysis(ARow, AResult) then Value := InWindowText(AResult) else Value := '';
    5: if FindSampleAnalysis(ARow, AResult) then Value := BoolText(AResult.IsOutlier) else Value := '';
    6: if FindSampleAnalysis(ARow, AResult) then Value := BoolText(AResult.IsInRange) else Value := '';
  end;
end;

procedure TFrameMeterValueEdit.GridSamplesSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
var
  I: Integer;
  Sample: TMeterValueSample;
begin
  if FSampleSource <> mssTestSamples then
    Exit;

  if GetSampleIndexForGridRow(ARow) < 0 then
    Exit;

  if not (ACol in [1, 3]) then
    Exit;

  Sample := FTestSamples[GetSampleIndexForGridRow(ARow)];
  case ACol of
    1: if Length(FDisplayedSamples) > 0 then
         Sample.TimeStampMs := FDisplayedSamples[0].TimeStampMs + SampleSecondsToMs(SafeFloat(Value.ToString))
       else
         Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(Value.ToString));
    3: Sample.Value := DisplayToBase(Value.ToString);
  end;

  FTestSamples[GetSampleIndexForGridRow(ARow)] := Sample;
  SortSamples;
  RefreshSamplesGrid;
  for I := 0 to FTestSamples.Count - 1 do
    if (FTestSamples[I].TimeStampMs = Sample.TimeStampMs) and
       SameValue(FTestSamples[I].Value, Sample.Value) then
    begin
      GridSamples.Row := GetGridRowForSampleIndex(I);
      GridSamples.Selected := GridSamples.Row;
      Break;
    end;
  LoadSampleToEditor(GridSamples.Row);
  FTestDataModified := True;
  AnalyzeIfNeeded;
end;

procedure TFrameMeterValueEdit.GridSamplesSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
  LoadSampleToEditor(ARow);
end;

procedure TFrameMeterValueEdit.EditAnalysisTimeExit(Sender: TObject);
begin
  FTestCurrentTimeMs := SampleSecondsToMs(SafeFloat(EditAnalysisTime.Text));
  AnalyzeIfNeeded;
end;




procedure TFrameMeterValueEdit.UpdateTargetLimits;
var
  TargetValue: Double;
  PlusPercent: Double;
  MinusPercent: Double;
  AbsoluteTolerance: Double;
  LowerLimit: Double;
  UpperLimit: Double;
begin
  if (not TryReadFloat(EditTestTargetValue.Text, TargetValue)) or
     (not TryReadFloat(EditTargetAccuracyPlusPercent.Text, PlusPercent)) or
     (not TryReadFloat(EditTargetAccuracyMinusPercent.Text, MinusPercent)) or
     (not TryReadFloat(EditTargetToleranceAbsolute.Text, AbsoluteTolerance)) or
     (PlusPercent < 0) or (MinusPercent < 0) or (AbsoluteTolerance < 0) then
    Exit;

  FTestTargetValue := DisplayToBase(EditTestTargetValue.Text);
  AbsoluteTolerance := DisplayDeltaToBase(EditTargetToleranceAbsolute.Text);
  FTestSettings.TargetValue := FTestTargetValue;
  FTestSettings.TargetAccuracyPlusPercent := PlusPercent;
  FTestSettings.TargetAccuracyMinusPercent := MinusPercent;
  FTestSettings.TargetToleranceAbsolute := AbsoluteTolerance;
  FTestSettings.RequireCurrentValueInRange := CheckBoxRequireCurrentValueInRange.IsChecked;
  FTestSettings.RequireMeanValueInRange := CheckBoxRequireMeanValueInRange.IsChecked;
  FTestSettings.RequireForecastInRange := CheckBoxRequireForecastInRange.IsChecked;

  CalculateTargetLimits(FTestTargetValue, PlusPercent, MinusPercent, AbsoluteTolerance,
    LowerLimit, UpperLimit);
  EditTargetLowerLimit.Text := BaseToDisplayText(LowerLimit);
  EditTargetUpperLimit.Text := BaseToDisplayText(UpperLimit);
end;

procedure TFrameMeterValueEdit.HandleTargetRangeChange(Sender: TObject);
begin
  if FLoading or FApplyingSettings then
    Exit;

  UpdateTargetLimits;
  FSettingsModified := True;
  FTestDataModified := True;
  FModified := True;
  ApplyAndSaveStabilitySettings(True, False, True);
  UpdateStabilityAutoRefreshTimer;
end;

procedure TFrameMeterValueEdit.ClearTestAnalysis;
begin
  FTestStabilityInfo := Default(TMeterValueStabilityInfo);
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
  FTestStableCandidateSinceMs := 0;
  FTestStabilityConfirmed := False;
  ClearAnalysisDisplay;
  RefreshSamplesGrid(False);
end;

function TFrameMeterValueEdit.BoolText(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function TFrameMeterValueEdit.InWindowText(const AResult: TMeterValueSampleAnalysis): string;
begin
  if not AResult.InWindow then
    Result := 'Нет'
  else if AResult.IsInConfirmationPeriod then
    Result := 'Стаб'
  else
    Result := 'Да';
end;

function TFrameMeterValueEdit.FindSampleAnalysis(const ARow: Integer;
  out AResult: TMeterValueSampleAnalysis): Boolean;
var
  I: Integer;
  SampleIndex: Integer;
begin
  Result := False;
  AResult := Default(TMeterValueSampleAnalysis);
  SampleIndex := GetSampleIndexForGridRow(ARow);
  if SampleIndex < 0 then
    Exit;

  for I := 0 to High(FLastTestAnalysis.SampleResults) do
    if (FLastTestAnalysis.SampleResults[I].SourceIndex = SampleIndex) and
       (FLastTestAnalysis.SampleResults[I].TimeStampMs = FDisplayedSamples[SampleIndex].TimeStampMs) then
    begin
      AResult := FLastTestAnalysis.SampleResults[I];
      Exit(True);
    end;

  for I := 0 to High(FLastTestAnalysis.SampleResults) do
    if FLastTestAnalysis.SampleResults[I].TimeStampMs = FDisplayedSamples[SampleIndex].TimeStampMs then
    begin
      AResult := FLastTestAnalysis.SampleResults[I];
      Exit(True);
    end;
end;

procedure TFrameMeterValueEdit.AnalyzeIfNeeded;
begin
  if FLoading then
    Exit;

  if CheckBoxAutoAnalyze.IsChecked then
    AnalyzeDisplayedSamples(False, True, False)
  else
    ClearTestAnalysis;
end;

procedure TFrameMeterValueEdit.HandleAutoAnalyzeChange(Sender: TObject);
begin
  if FLoading or FApplyingSettings then
    Exit;

  FSettingsModified := True;
  FModified := True;
  FTestSettings.AutoAnalyze := CheckBoxAutoAnalyze.IsChecked;
  ApplyAndSaveStabilitySettings(False, False, True);
  UpdateStabilityAutoRefreshTimer;
  if CheckBoxAutoAnalyze.IsChecked then
    RefreshStabilityHistoryAndAnalysis;
end;

function TFrameMeterValueEdit.TryGetTestTargetLimits(out ALowerLimit, AUpperLimit: Double): Boolean;
begin
  Result := (not IsNan(FTestSettings.TargetValue)) and (not IsInfinite(FTestSettings.TargetValue)) and
    (not IsNan(FTestSettings.TargetAccuracyPlusPercent)) and (not IsInfinite(FTestSettings.TargetAccuracyPlusPercent)) and
    (not IsNan(FTestSettings.TargetAccuracyMinusPercent)) and (not IsInfinite(FTestSettings.TargetAccuracyMinusPercent)) and
    (not IsNan(FTestSettings.TargetToleranceAbsolute)) and (not IsInfinite(FTestSettings.TargetToleranceAbsolute)) and
    (FTestSettings.TargetAccuracyPlusPercent >= 0) and
    (FTestSettings.TargetAccuracyMinusPercent >= 0) and
    (FTestSettings.TargetToleranceAbsolute >= 0);
  if not Result then
    Exit;

  CalculateTargetLimits(FTestSettings.TargetValue, FTestSettings.TargetAccuracyPlusPercent,
    FTestSettings.TargetAccuracyMinusPercent, FTestSettings.TargetToleranceAbsolute,
    ALowerLimit, AUpperLimit);
  Result := (not IsNan(ALowerLimit)) and (not IsInfinite(ALowerLimit)) and
    (not IsNan(AUpperLimit)) and (not IsInfinite(AUpperLimit)) and
    (ALowerLimit <= AUpperLimit);
end;

procedure TFrameMeterValueEdit.RecalculateTestPreview;
begin
  AnalyzeDisplayedSamples(False, True, True);
end;

procedure TFrameMeterValueEdit.Analyze;
begin
  AnalyzeDisplayedSamples(False, True, False);
end;

procedure TFrameMeterValueEdit.AnalyzeDisplayedSamples(const AUseLastWorkSampleTime: Boolean;
  const AShowValidationError: Boolean; const ARefreshSource: Boolean);
var
  ErrorText: string;
  Settings: TMeterValueStabilitySettings;
  Samples: TArray<TMeterValueSample>;
  LowerLimit: Double;
  UpperLimit: Double;
  I: Integer;
  OldSampleCount: Integer;
  OldRowCount: Integer;
  SelectedRow: Integer;
  SelectedTimeStampMs: Int64;
  SelectedSampleValue: Double;

begin
  if FMeterValue = nil then
    Exit;

  OldSampleCount := Length(FDisplayedSamples);
  OldRowCount := GridSamples.RowCount;
  SelectedRow := GridSamples.Row;
  SelectedTimeStampMs := 0;
  SelectedSampleValue := 0;
  if (SelectedRow >= 0) and (SelectedRow < Length(FDisplayedSamples)) and
     (GetSampleIndexForGridRow(SelectedRow) >= 0) then
  begin
    SelectedTimeStampMs := FDisplayedSamples[GetSampleIndexForGridRow(SelectedRow)].TimeStampMs;
    SelectedSampleValue := FDisplayedSamples[GetSampleIndexForGridRow(SelectedRow)].Value;
  end;

  if ARefreshSource then
  begin
    RefreshDisplayedSamples;
    OldSampleCount := Length(FDisplayedSamples);
    OldRowCount := Length(FDisplayedSamples);
  end;

  if Length(FDisplayedSamples) = 0 then
  begin
    ClearTestAnalysis;
    if FSampleSource = mssWorkHistory then
      MemoConclusion.Lines.Text := 'В рабочей истории нет данных';
    Exit;
  end;

  if not ValidateControls(ErrorText) then
  begin
    ClearTestAnalysis;
    if AShowValidationError then
      ShowMessage('Анализ не выполнен.' + sLineBreak + ErrorText);
    Exit;
  end;

  ReadSettingsFromControls(Settings);
  FTestSettings := Settings;
  UpdateTargetLimits;
  if not TryGetTestTargetLimits(LowerLimit, UpperLimit) then
  begin
    ClearTestAnalysis;
    if AShowValidationError then
      ShowMessage('Анализ не выполнен. Некорректный целевой диапазон.');
    Exit;
  end;

  if (FSampleSource = mssWorkHistory) and AUseLastWorkSampleTime then
    SetAnalysisTimeByLastDisplayedSample;

  SetLength(Samples, Length(FDisplayedSamples));
  for I := 0 to High(FDisplayedSamples) do
    Samples[I] := FDisplayedSamples[I];

  TMeterValue.AnalyzeStabilitySamples(Samples, FTestSettings, FTestCurrentTimeMs,
    FTestTargetValue, LowerLimit, UpperLimit, FTestStableCandidateSinceMs,
    FTestStabilityConfirmed, FTestStabilityInfo);
  FLastTestAnalysis := FTestStabilityInfo;
  DisplayAnalysis(FTestStabilityInfo);
  RefreshSamplesGrid(False);

  if (SelectedRow >= 0) and (SelectedRow < GridSamples.RowCount) then
  begin
    GridSamples.Row := SelectedRow;
    GridSamples.Selected := SelectedRow;
    if (GetSampleIndexForGridRow(SelectedRow) >= 0) and
       (FDisplayedSamples[GetSampleIndexForGridRow(SelectedRow)].TimeStampMs = SelectedTimeStampMs) and
       SameValue(FDisplayedSamples[GetSampleIndexForGridRow(SelectedRow)].Value, SelectedSampleValue) then
      LoadSampleToEditor(SelectedRow);
  end;

  Assert(Length(FDisplayedSamples) = OldSampleCount);
  Assert(GridSamples.RowCount = OldRowCount);
  UpdateStabilityChart;
end;

function TFrameMeterValueEdit.FormatInfoFloat(const AValue: Double;
  const AHasValue: Boolean; const ADigits: Integer): string;
begin
  if not AHasValue then
    Exit('—');
  Result := FormatFloatN(AValue, ADigits);
end;

function TFrameMeterValueEdit.TrendDirectionText(
  const ADirection: TMeterValueTrendDirection; const AHasTrend: Boolean): string;
begin
  if not AHasTrend then
    Exit('—');

  case ADirection of
    tdIncreasing: Result := 'Рост';
    tdDecreasing: Result := 'Снижение';
  else
    Result := 'Тренд отсутствует';
  end;
end;

procedure TFrameMeterValueEdit.DisplayAnalysis(const AInfo: TMeterValueStabilityInfo);
var
  Reason: TMeterValueStabilityFailReason;
begin
  MemoConclusion.Lines.Text := AInfo.StatusText;

  if not (AInfo.Status in [mvssNotEnoughData, mvssStaleData, mvssUnstable, mvssStable]) then
  begin
    ClearAnalysisDisplay;
    MemoConclusion.Lines.Text := AInfo.StatusText;
    Exit;
  end;

  EditResultSampleCount.Text := IntToStr(AInfo.SampleCount);
  EditResultUsedSampleCount.Text := IntToStr(AInfo.UsedSampleCount);
  EditResultOutlierCount.Text := IntToStr(AInfo.OutlierCount);
  EditResultOutlierFraction.Text := FormatInfoFloat(AInfo.OutlierFraction * 100, AInfo.UsedSampleCount > 0, 2);
  EditResultWindowDuration.Text := FormatInfoFloat(AInfo.WindowDurationSec, AInfo.UsedSampleCount > 0, 2);
  EditResultLastSampleAge.Text := FormatInfoFloat(AInfo.LastSampleAgeSec, AInfo.HasLastSampleAge, 2);
  EditResultCurrentValue.Text := FormatBaseInfo(AInfo.CurrentValue, AInfo.HasCurrentValue);
  EditResultMeanValue.Text := FormatBaseInfo(AInfo.MeanValue, AInfo.HasStatistics);
  EditResultMinValue.Text := FormatBaseInfo(AInfo.MinValue, AInfo.HasStatistics);
  EditResultMaxValue.Text := FormatBaseInfo(AInfo.MaxValue, AInfo.HasStatistics);
  EditResultVariation.Text := FormatBaseDeltaInfo(AInfo.Variation, AInfo.HasStatistics);
  EditResultStdDeviation.Text := FormatBaseDeltaInfo(AInfo.StdDeviation, AInfo.HasStatistics);
  if AInfo.HasTrend then
    EditResultTrendRate.Text := FormatBaseDeltaInfo(AInfo.TrendRate, AInfo.HasTrend)
  else
    EditResultTrendRate.Text := '—';
  EditResultTrendDirection.Text := TrendDirectionText(AInfo.TrendDirection, AInfo.HasTrend);
  EditResultForecastHorizon.Text := FormatInfoFloat(FTestSettings.ForecastHorizonSec, AInfo.HasForecast, 2);
  EditResultForecastValue.Text := FormatBaseInfo(AInfo.ForecastValue, AInfo.HasForecast);
  if AInfo.HasForecast then
    EditResultForecastInRange.Text := BoolText(AInfo.IsForecastInRange)
  else
    EditResultForecastInRange.Text := '—';

  ListBoxStabilityReasons.Items.Clear;
  for Reason := Low(TMeterValueStabilityFailReason) to High(TMeterValueStabilityFailReason) do
    if Reason in AInfo.FailReasons then
      ListBoxStabilityReasons.Items.Add(StabilityFailReasonToText(Reason));
  if ListBoxStabilityReasons.Items.Count = 0 then
    ListBoxStabilityReasons.Items.Add('Причины отсутствуют.');

  UpdateDetailedConclusion(AInfo);
  UpdateConclusionIndicators(AInfo);
end;


function TFrameMeterValueEdit.ChartColorOptionToAlphaColor(
  const AOption: TChartColorOption): TAlphaColor;
begin
  case AOption of
    ccoBlue: Result := TAlphaColorRec.Blue;
    ccoLightBlue: Result := TAlphaColorRec.Cornflowerblue;
    ccoGreen: Result := TAlphaColorRec.Green;
    ccoRed: Result := TAlphaColorRec.Red;
    ccoOrange: Result := TAlphaColorRec.Orange;
    ccoYellow: Result := TAlphaColorRec.Gold;
    ccoPurple: Result := TAlphaColorRec.Purple;
    ccoGray: Result := TAlphaColorRec.Gray;
    ccoBlack: Result := TAlphaColorRec.Black;
  else
    Result := TAlphaColorRec.Blue;
  end;
end;

procedure TFrameMeterValueEdit.ApplyChartSeriesStyle(const ASeries: TChartSeries;
  const AColor: TChartColorOption; const AThickness: Double; const AShowMarkers: Boolean);
begin
  if ASeries = nil then
    Exit;

  ASeries.Color := ChartColorOptionToAlphaColor(AColor);
  ASeries.Thickness := EnsureRange(AThickness, 0.5, 10.0);
  ASeries.ShowMarkers := AShowMarkers;
end;

procedure TFrameMeterValueEdit.UpdateStabilityChart;
var
  Indexes: TList<Integer>;
  Series: TChartSeries;
  ForecastSeries: TChartSeries;
  LowerSeries: TChartSeries;
  UpperSeries: TChartSeries;
  I: Integer;
  SampleIndex: Integer;
  Sample: TMeterValueSample;
  HasLimits: Boolean;
  BaseTimeMs: Int64;
  X: Double;
  DisplayValue: Double;
  MinActualTimeSec: Double;
  MaxActualTimeSec: Double;
  ForecastEndTimeSec: Double;
  LowerLimit: Double;
  UpperLimit: Double;
  ToleranceColor: TAlphaColor;
  ChartSettings: TMeterValueStabilitySettings;

begin
  if ChartStability = nil then
    Exit;

  ChartSettings := FTestSettings;
  if FMeterValue <> nil then
    ChartSettings := FMeterValue.StabilitySettings;

  ChartStability.BeginUpdate;
  try
    ChartStability.ClearAllSeries;
    ChartStability.Title := 'История сигнала';
    ChartStability.XTitle := 'Время, с';
    ChartStability.YTitle := AppendUnit('Значение', DisplayUnitName);

    if Length(FDisplayedSamples) = 0 then
      Exit;

    Indexes := TList<Integer>.Create;
    try
      for I := 0 to High(FDisplayedSamples) do
        Indexes.Add(I);
      Indexes.Sort(TComparer<Integer>.Construct(
        function(const L, R: Integer): Integer
        begin
          Result := CompareValue(FDisplayedSamples[L].TimeStampMs, FDisplayedSamples[R].TimeStampMs);
        end));

      BaseTimeMs := FDisplayedSamples[0].TimeStampMs;
      MinActualTimeSec := (FDisplayedSamples[Indexes[0]].TimeStampMs - BaseTimeMs) / 1000;
      MaxActualTimeSec := (FDisplayedSamples[Indexes[Indexes.Count - 1]].TimeStampMs - BaseTimeMs) / 1000;
      ForecastEndTimeSec := MaxActualTimeSec;
      HasLimits := (Indexes.Count > 1) and TryGetTestTargetLimits(LowerLimit, UpperLimit);
      if HasLimits then
      begin
        LowerLimit := ValueToCurrentDimension(LowerLimit);
        UpperLimit := ValueToCurrentDimension(UpperLimit);
        LowerSeries := ChartStability.AddSeries('Нижняя граница');
        UpperSeries := ChartStability.AddSeries('Верхняя граница');
        ToleranceColor := ChartColorOptionToAlphaColor(ChartSettings.ChartToleranceColor);
        LowerSeries.Color := ToleranceColor;
        UpperSeries.Color := ToleranceColor;
        LowerSeries.Thickness := ChartSettings.ChartToleranceLineWidth;
        UpperSeries.Thickness := ChartSettings.ChartToleranceLineWidth;
        LowerSeries.ShowMarkers := False;
        UpperSeries.ShowMarkers := False;
      end;

      Series := ChartStability.AddSeries('Сигнал');
      ApplyChartSeriesStyle(Series, ChartSettings.ChartSignalColor,
        ChartSettings.ChartSignalLineWidth, True);

      for SampleIndex in Indexes do
      begin
        Sample := FDisplayedSamples[SampleIndex];
        X := (Sample.TimeStampMs - BaseTimeMs) / 1000;
        DisplayValue := ValueToCurrentDimension(Sample.Value);
        Series.AddPoint(X, DisplayValue);
      end;

      if FTestStabilityInfo.HasForecast then
      begin
        ForecastSeries := ChartStability.AddSeries('Прогноз');
        ForecastSeries.Thickness := ChartSettings.ChartSignalLineWidth;
        ForecastSeries.ShowMarkers := False;
        Sample := FDisplayedSamples[Indexes[Indexes.Count - 1]];
        X := (Sample.TimeStampMs - BaseTimeMs) / 1000;
        ForecastEndTimeSec := X + FTestSettings.ForecastHorizonSec;
        ForecastSeries.AddPoint(X, ValueToCurrentDimension(Sample.Value));
        ForecastSeries.AddPoint(ForecastEndTimeSec,
          ValueToCurrentDimension(FTestStabilityInfo.ForecastValue));
      end;

      if HasLimits then
      begin
        LowerSeries.AddPoint(MinActualTimeSec, LowerLimit);
        LowerSeries.AddPoint(MaxActualTimeSec, LowerLimit);
        UpperSeries.AddPoint(MinActualTimeSec, UpperLimit);
        UpperSeries.AddPoint(MaxActualTimeSec, UpperLimit);
      end;
    finally
      Indexes.Free;
    end;
  finally
    ChartStability.EndUpdate;
  end;

  ChartStability.InvalidateChart;
end;

procedure TFrameMeterValueEdit.UpdateDetailedConclusion(const AInfo: TMeterValueStabilityInfo);
var
  Lines: TStringList;
  Reason: TMeterValueStabilityFailReason;
begin
  Lines := TStringList.Create;
  try
    if AInfo.IsSuitableForMeasurement then
      Lines.Add('Значение пригодно для измерения.')
    else if mvsfrAnalysisDisabled in AInfo.FailReasons then
      Lines.Add('Анализ стабильности отключён.')
    else if mvsfrNoData in AInfo.FailReasons then
      Lines.Add('Нет доступных данных.')
    else
      Lines.Add('Значение пока нельзя использовать.');

    Lines.Add('');
    Lines.Add('Значения:');
    Lines.Add('Всего отсчётов: ' + IntToStr(AInfo.SampleCount) + '.');
    Lines.Add('Использовано отсчётов: ' + IntToStr(AInfo.UsedSampleCount) + '.');
    Lines.Add('Текущее значение: ' + FormatBaseInfo(AInfo.CurrentValue, AInfo.HasCurrentValue) + '.');
    Lines.Add('Среднее значение: ' + FormatBaseInfo(AInfo.MeanValue, AInfo.HasStatistics) + '.');
    Lines.Add('Допустимый диапазон: ' + EditTargetLowerLimit.Text + '–' + EditTargetUpperLimit.Text + '.');

    Lines.Add('');
    Lines.Add('Размах: ' + FormatBaseDeltaInfo(AInfo.Variation, AInfo.HasStatistics) + '.');
    Lines.Add('Стандартное отклонение: ' + FormatBaseDeltaInfo(AInfo.StdDeviation, AInfo.HasStatistics) + '.');
    Lines.Add('Скорость тренда: ' + EditResultTrendRate.Text + ' за с.');
    Lines.Add('Направление тренда: ' + TrendDirectionText(AInfo.TrendDirection, AInfo.HasTrend) + '.');
    Lines.Add('Предварительная стабильность: ' + BoolText(AInfo.IsSignalStable) + '.');
    Lines.Add('Подтверждение стабильности: ' + BoolText(AInfo.IsStabilityConfirmed) + '.');
    if AInfo.IsSignalStable and not AInfo.IsStabilityConfirmed then
      Lines.Add('Время подтверждения: ' + FormatInfoFloat(AInfo.StableCandidateDurationSec, True, 2) +
        ' из ' + FormatInfoFloat(FTestSettings.ConfirmationTimeSec, True, 2) + ' с.');

    Lines.Add('');
    Lines.Add('Прогноз через ' + FormatInfoFloat(FTestSettings.ForecastHorizonSec, AInfo.HasForecast, 2) + ' с: ' +
      FormatBaseInfo(AInfo.ForecastValue, AInfo.HasForecast) + '.');
    Lines.Add('Прогноз в диапазоне: ' + EditResultForecastInRange.Text + '.');

    Lines.Add('');
    Lines.Add('Анализ выбросов:');
    if AInfo.OutlierCount = 0 then
      Lines.Add('Выбросы не обнаружены.')
    else
      Lines.Add('Обнаружено выбросов: ' + IntToStr(AInfo.OutlierCount) + ' из ' +
        IntToStr(AInfo.UsedSampleCount) + ' точек (' +
        FormatInfoFloat(AInfo.OutlierFraction * 100, AInfo.UsedSampleCount > 0, 2) + ' %).');
    Lines.Add('В окне анализа: ' + IntToStr(AInfo.UsedSampleCount) + ' точек.');
    if (AInfo.OutlierCount > 0) and (AInfo.OutlierCount < AInfo.UsedSampleCount) then
    begin
      Lines.Add('Использовано для статистики: ' + IntToStr(AInfo.UsedSampleCount - AInfo.OutlierCount) + ' точек.');
      Lines.Add('Выбросы исключены из расчёта статистики и прогноза.');
    end
    else
      Lines.Add('Использовано для статистики: ' + IntToStr(AInfo.UsedSampleCount) + ' точек.');
    if mvsfrTooManyOutliers in AInfo.FailReasons then
    begin
      Lines.Add('Допустимая доля выбросов превышена.');
      Lines.Add('Результат не может быть признан пригодным для измерения.');
    end
    else
      Lines.Add('Допустимая доля выбросов не превышена.');
    Lines.Add('Метод: медиана и MAD.');

    Lines.Add('');
    Lines.Add('Причины:');
    if AInfo.FailReasons = [] then
      Lines.Add('— причины отсутствуют;')
    else
      for Reason := Low(TMeterValueStabilityFailReason) to High(TMeterValueStabilityFailReason) do
        if Reason in AInfo.FailReasons then
          Lines.Add('— ' + StabilityFailReasonToText(Reason) + ';');

    Lines.Add('');
    if AInfo.IsSuitableForMeasurement then
      Lines.Add('Итог: значение пригодно для измерения.')
    else
      Lines.Add('Итог: значение непригодно для измерения.');

    MemoStabilityConclusion.Lines.Assign(Lines);
  finally
    Lines.Free;
  end;
end;

procedure TFrameMeterValueEdit.ApplySettingsToWorkMeterValue;
begin
  ApplyAndSaveStabilitySettings(True, False, True);
end;

procedure TFrameMeterValueEdit.CopySettingsFromWorkMeterValue;
begin
  FillChar(FTestSettings, SizeOf(FTestSettings), 0);
  if FMeterValue <> nil then
    FTestSettings := FMeterValue.StabilitySettings;
  FSettingsModified := False;
  FChartAppearanceModified := False;
end;

procedure TFrameMeterValueEdit.LoadSettingsToControls;
begin
  FLoading := True;
  try
    CheckBoxStabilityEnabled.IsChecked := FTestSettings.Enabled;
    CheckBoxAutoAnalyze.IsChecked := FTestSettings.AutoAnalyze;
    EditMinSampleCount.Text := IntToStr(FTestSettings.MinSampleCount);
    EditWindowDurationSec.Text := FormatFloat('0.########', FTestSettings.WindowDurationSec);
    EditMaxSampleAgeSec.Text := FormatFloat('0.########', FTestSettings.MaxSampleAgeSec);
    EditConfirmationTimeSec.Text := FormatFloat('0.########', FTestSettings.ConfirmationTimeSec);
    EditExitThresholdFactor.Text := FormatFloat('0.########', FTestSettings.ExitThresholdFactor);
    EditMaxVariation.Text := BaseDeltaToDisplayText(FTestSettings.MaxVariation);
    EditMaxStdDeviation.Text := BaseDeltaToDisplayText(FTestSettings.MaxStdDeviation);
    EditMaxTrendRate.Text := BaseDeltaToDisplayText(FTestSettings.MaxTrendRate);
    EditMaxOutlierFractionPercent.Text := FormatFloat('0.########', FTestSettings.MaxOutlierFraction * 100);
    EditOutlierFactor.Text := FormatFloat('0.########', FTestSettings.OutlierFactor);
    EditForecastHorizonSec.Text := FormatFloat('0.########', FTestSettings.ForecastHorizonSec);
    FTestTargetValue := FTestSettings.TargetValue;
    EditTestTargetValue.Text := BaseToDisplayText(FTestTargetValue);
    EditTargetAccuracyPlusPercent.Text := FormatFloat('0.########', FTestSettings.TargetAccuracyPlusPercent);
    EditTargetAccuracyMinusPercent.Text := FormatFloat('0.########', FTestSettings.TargetAccuracyMinusPercent);
    EditTargetToleranceAbsolute.Text := BaseDeltaToDisplayText(FTestSettings.TargetToleranceAbsolute);
    CheckBoxRequireCurrentValueInRange.IsChecked := FTestSettings.RequireCurrentValueInRange;
    CheckBoxRequireMeanValueInRange.IsChecked := FTestSettings.RequireMeanValueInRange;
    CheckBoxRequireForecastInRange.IsChecked := FTestSettings.RequireForecastInRange;
    ComboBoxChartSignalColor.ItemIndex := ChartColorToComboIndex(FTestSettings.ChartSignalColor);
    ComboBoxChartToleranceColor.ItemIndex := ChartColorToComboIndex(FTestSettings.ChartToleranceColor);
    ComboBoxChartSignalWidth.ItemIndex := ChartWidthToComboIndex(FTestSettings.ChartSignalLineWidth);
    ComboBoxChartToleranceWidth.ItemIndex := ChartWidthToComboIndex(FTestSettings.ChartToleranceLineWidth);
    UpdateTargetLimits;
  finally
    FLoading := False;
  end;
end;

function TFrameMeterValueEdit.TryReadFloat(const AText: string;
  out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(StringReplace(StringReplace(Trim(AText), '.', FormatSettings.DecimalSeparator,
    [rfReplaceAll]), ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), AValue) and (not IsNan(AValue)) and (not IsInfinite(AValue));
end;

function TFrameMeterValueEdit.TryReadInteger(const AText: string;
  out AValue: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(AText), AValue);
end;

procedure TFrameMeterValueEdit.ReadSettingsFromControls(
  out ASettings: TMeterValueStabilitySettings);
var
  OutlierPercent: Double;
begin
  ASettings := FTestSettings;
  ASettings.Enabled := CheckBoxStabilityEnabled.IsChecked;
  ASettings.AutoAnalyze := CheckBoxAutoAnalyze.IsChecked;
  TryReadInteger(EditMinSampleCount.Text, ASettings.MinSampleCount);
  TryReadFloat(EditWindowDurationSec.Text, ASettings.WindowDurationSec);
  TryReadFloat(EditMaxSampleAgeSec.Text, ASettings.MaxSampleAgeSec);
  TryReadFloat(EditConfirmationTimeSec.Text, ASettings.ConfirmationTimeSec);
  TryReadFloat(EditExitThresholdFactor.Text, ASettings.ExitThresholdFactor);
  ASettings.MaxVariation := DisplayDeltaToBase(EditMaxVariation.Text);
  ASettings.MaxStdDeviation := DisplayDeltaToBase(EditMaxStdDeviation.Text);
  ASettings.MaxTrendRate := DisplayDeltaToBase(EditMaxTrendRate.Text);
  if TryReadFloat(EditMaxOutlierFractionPercent.Text, OutlierPercent) then
    ASettings.MaxOutlierFraction := OutlierPercent / 100;
  TryReadFloat(EditOutlierFactor.Text, ASettings.OutlierFactor);
  TryReadFloat(EditForecastHorizonSec.Text, ASettings.ForecastHorizonSec);
  ASettings.TargetValue := DisplayToBase(EditTestTargetValue.Text);
  TryReadFloat(EditTargetAccuracyPlusPercent.Text, ASettings.TargetAccuracyPlusPercent);
  TryReadFloat(EditTargetAccuracyMinusPercent.Text, ASettings.TargetAccuracyMinusPercent);
  ASettings.TargetToleranceAbsolute := DisplayDeltaToBase(EditTargetToleranceAbsolute.Text);
  ASettings.RequireCurrentValueInRange := CheckBoxRequireCurrentValueInRange.IsChecked;
  ASettings.RequireMeanValueInRange := CheckBoxRequireMeanValueInRange.IsChecked;
  ASettings.RequireForecastInRange := CheckBoxRequireForecastInRange.IsChecked;
  if ComboBoxChartSignalColor.ItemIndex >= 0 then
    ASettings.ChartSignalColor := ComboIndexToChartColor(ComboBoxChartSignalColor.ItemIndex);
  if ComboBoxChartToleranceColor.ItemIndex >= 0 then
    ASettings.ChartToleranceColor := ComboIndexToChartColor(ComboBoxChartToleranceColor.ItemIndex);
  ASettings.ChartSignalLineWidth := ComboIndexToChartWidth(ComboBoxChartSignalWidth.ItemIndex);
  ASettings.ChartToleranceLineWidth := ComboIndexToChartWidth(ComboBoxChartToleranceWidth.ItemIndex);
end;

function TFrameMeterValueEdit.StabilitySettingsEqual(const ALeft,
  ARight: TMeterValueStabilitySettings): Boolean;
begin
  Result := (ALeft.Enabled = ARight.Enabled) and
    (ALeft.MinSampleCount = ARight.MinSampleCount) and
    SameValue(ALeft.WindowDurationSec, ARight.WindowDurationSec, 1E-9) and
    SameValue(ALeft.MaxSampleAgeSec, ARight.MaxSampleAgeSec, 1E-9) and
    SameValue(ALeft.MaxVariation, ARight.MaxVariation, 1E-9) and
    SameValue(ALeft.MaxStdDeviation, ARight.MaxStdDeviation, 1E-9) and
    SameValue(ALeft.MaxTrendRate, ARight.MaxTrendRate, 1E-9) and
    SameValue(ALeft.ForecastHorizonSec, ARight.ForecastHorizonSec, 1E-9) and
    SameValue(ALeft.MaxOutlierFraction, ARight.MaxOutlierFraction, 1E-9) and
    SameValue(ALeft.OutlierFactor, ARight.OutlierFactor, 1E-9) and
    SameValue(ALeft.ConfirmationTimeSec, ARight.ConfirmationTimeSec, 1E-9) and
    SameValue(ALeft.ExitThresholdFactor, ARight.ExitThresholdFactor, 1E-9) and
    SameValue(ALeft.TargetValue, ARight.TargetValue, 1E-9) and
    SameValue(ALeft.TargetAccuracyPlusPercent, ARight.TargetAccuracyPlusPercent, 1E-9) and
    SameValue(ALeft.TargetAccuracyMinusPercent, ARight.TargetAccuracyMinusPercent, 1E-9) and
    SameValue(ALeft.TargetToleranceAbsolute, ARight.TargetToleranceAbsolute, 1E-9) and
    (ALeft.RequireCurrentValueInRange = ARight.RequireCurrentValueInRange) and
    (ALeft.RequireMeanValueInRange = ARight.RequireMeanValueInRange) and
    (ALeft.RequireForecastInRange = ARight.RequireForecastInRange) and
    (ALeft.AutoAnalyze = ARight.AutoAnalyze) and
    (ALeft.ChartSignalColor = ARight.ChartSignalColor) and
    (ALeft.ChartToleranceColor = ARight.ChartToleranceColor) and
    SameValue(ALeft.ChartSignalLineWidth, ARight.ChartSignalLineWidth, 1E-9) and
    SameValue(ALeft.ChartToleranceLineWidth, ARight.ChartToleranceLineWidth, 1E-9);
end;

procedure TFrameMeterValueEdit.RestoreStabilitySettingsControls;
begin
  if FMeterValue <> nil then
    FTestSettings := FMeterValue.StabilitySettings;
  LoadSettingsToControls;
end;

function TFrameMeterValueEdit.ApplyAndSaveStabilitySettings(const ARecalculate: Boolean;
  const ARefreshChartOnly: Boolean; const AShowError: Boolean): Boolean;
var
  ErrorText: string;
  Settings: TMeterValueStabilitySettings;
  SavedSettings: TMeterValueStabilitySettings;
begin
  Result := False;
  if FLoading or FApplyingSettings then
    Exit;
  if FMeterValue = nil then
    Exit(True);

  if not ValidateControls(ErrorText) then
  begin
    if AShowError then
      ShowMessage('Настройки стабильности не сохранены.' + sLineBreak + ErrorText);
    RestoreStabilitySettingsControls;
    Exit(False);
  end;

  ReadSettingsFromControls(Settings);
  SavedSettings := FMeterValue.StabilitySettings;
  FMeterValue.StabilitySettings := Settings;
  if not FMeterValue.ValidateStabilitySettings(ErrorText) then
  begin
    FMeterValue.StabilitySettings := SavedSettings;
    if AShowError then
      ShowMessage('Настройки стабильности не сохранены.' + sLineBreak + ErrorText);
    RestoreStabilitySettingsControls;
    Exit(False);
  end;

  FApplyingSettings := True;
  try
    FTestSettings := Settings;
    FTestTargetValue := Settings.TargetValue;
    FSettingsModified := False;
    FChartAppearanceModified := False;
    FModified := FTestDataModified;
    LoadSettingsToControls;
    if FMeterValue.IsToSave then
      TMeterValue.SaveToFile(0);
    if ARefreshChartOnly then
      UpdateStabilityChart
    else if ARecalculate then
    begin
      FRecalculating := True;
      try
        AnalyzeIfNeeded;
      finally
        FRecalculating := False;
      end;
    end;
    Result := True;
  finally
    FApplyingSettings := False;
  end;
end;

function TFrameMeterValueEdit.ApplySettingsFromControls(
  const AShowError: Boolean): Boolean;
begin
  Result := ApplyAndSaveStabilitySettings(True, False, AShowError);
end;

function TFrameMeterValueEdit.ValidateControls(out AErrorText: string): Boolean;
var
  DoubleValue: Double;
  IntValue: Integer;
begin
  Result := False;
  AErrorText := '';

  if (EditMinSampleCount = nil) or (EditWindowDurationSec = nil) or
     (EditMaxSampleAgeSec = nil) or (EditConfirmationTimeSec = nil) or
     (EditExitThresholdFactor = nil) or (EditMaxVariation = nil) or
     (EditMaxStdDeviation = nil) or (EditMaxTrendRate = nil) or
     (EditMaxOutlierFractionPercent = nil) or (EditOutlierFactor = nil) or
     (EditForecastHorizonSec = nil) or (EditTestTargetValue = nil) or
     (EditTargetAccuracyPlusPercent = nil) or (EditTargetAccuracyMinusPercent = nil) or
     (EditTargetToleranceAbsolute = nil) then
  begin
    AErrorText := 'Элементы управления настройками стабильности не инициализированы.';
    Exit;
  end;

  if not TryReadInteger(EditMinSampleCount.Text, IntValue) then
    AErrorText := 'Некорректное минимальное количество отсчётов.'
  else if IntValue < 1 then
    AErrorText := 'Минимальное количество отсчётов должно быть не меньше 1.'
  else if (not TryReadFloat(EditWindowDurationSec.Text, DoubleValue)) or (DoubleValue <= 0) then
    AErrorText := 'Длительность окна должна быть положительным числом.'
  else if (not TryReadFloat(EditMaxSampleAgeSec.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Максимальный возраст данных не может быть отрицательным.'
  else if (not TryReadFloat(EditConfirmationTimeSec.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Время подтверждения не может быть отрицательным.'
  else if (not TryReadFloat(EditExitThresholdFactor.Text, DoubleValue)) or (DoubleValue < 1) then
    AErrorText := 'Коэффициент порога выхода должен быть не меньше 1.'
  else if (not TryReadFloat(EditMaxVariation.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Максимальный размах не может быть отрицательным.'
  else if (not TryReadFloat(EditMaxStdDeviation.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Максимальное стандартное отклонение не может быть отрицательным.'
  else if (not TryReadFloat(EditMaxTrendRate.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Максимальная скорость тренда не может быть отрицательной.'
  else if (not TryReadFloat(EditMaxOutlierFractionPercent.Text, DoubleValue)) or
          (DoubleValue < 0) or (DoubleValue > 100) then
    AErrorText := 'Максимальная доля выбросов должна быть от 0 до 100 процентов.'
  else if (not TryReadFloat(EditOutlierFactor.Text, DoubleValue)) or (DoubleValue <= 0) then
    AErrorText := 'Коэффициент определения выброса должен быть положительным числом.'
  else if (not TryReadFloat(EditForecastHorizonSec.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Горизонт прогноза не может быть отрицательным.'
  else if not TryReadFloat(EditTestTargetValue.Text, DoubleValue) then
    AErrorText := 'Целевое значение должно быть корректным числом.'
  else if (not TryReadFloat(EditTargetAccuracyPlusPercent.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Допуск вверх не может быть отрицательным.'
  else if (not TryReadFloat(EditTargetAccuracyMinusPercent.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Допуск вниз не может быть отрицательным.'
  else if (not TryReadFloat(EditTargetToleranceAbsolute.Text, DoubleValue)) or (DoubleValue < 0) then
    AErrorText := 'Минимальный абсолютный допуск не может быть отрицательным.'
  else
    Result := True;
end;

procedure TFrameMeterValueEdit.HandleSettingsChange(Sender: TObject);
begin
  if FLoading or FApplyingSettings then
    Exit;

  FSettingsModified := True;
  FModified := True;
  ApplyAndSaveStabilitySettings(True, False, True);
  UpdateStabilityAutoRefreshTimer;
end;

function TFrameMeterValueEdit.SafeFloat(const S: string): Double;
begin
  Result := StrToFloatDef(StringReplace(StringReplace(S, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]), ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), 0);
end;

procedure TFrameMeterValueEdit.HandleControlExit(Sender: TObject);
begin
  SaveChanges;
end;

procedure TFrameMeterValueEdit.HandleCheckBoxChange(Sender: TObject);
begin
  if FLoading or (FMeterValue = nil) then
    Exit;

  if Sender = CheckBoxIsToSave then
  begin
    FMeterValue.SetToSave(CheckBoxIsToSave.IsChecked);
    TMeterValue.SaveToFile(0);
    Exit;
  end;

  SaveChanges;
end;

procedure TFrameMeterValueEdit.HandleComboChange(Sender: TObject);
var
  GeneratorStartBase: Double;
  GeneratorTrendBase: Double;
  GeneratorNoiseBase: Double;
  GeneratorOutlierBase: Double;
  TmpErrorText: string;
begin
  if FLoading or (FMeterValue = nil) or (ComboValueDim.ItemIndex < 0) then
    Exit;

  GeneratorStartBase := DisplayToBase(EditGeneratorStartValue.Text);
  GeneratorTrendBase := DisplayDeltaToBase(EditGeneratorTrend.Text);
  GeneratorNoiseBase := DisplayDeltaToBase(EditGeneratorNoise.Text);
  GeneratorOutlierBase := DisplayDeltaToBase(EditGeneratorOutlierAmplitude.Text);
  if ValidateControls(TmpErrorText) then
    ReadSettingsFromControls(FTestSettings);

  if FMeterValue.SetDim(ComboValueDim.ItemIndex) then
  begin
    FLoading := True;
    try
      EditValue.Text := FMeterValue.GetStrValue;
      EditGeneratorStartValue.Text := BaseToDisplayText(GeneratorStartBase);
      EditGeneratorTrend.Text := BaseDeltaToDisplayText(GeneratorTrendBase);
      EditGeneratorNoise.Text := BaseDeltaToDisplayText(GeneratorNoiseBase);
      EditGeneratorOutlierAmplitude.Text := BaseDeltaToDisplayText(GeneratorOutlierBase);
      UpdateDimensionCaptions;
      LoadSettingsToControls;
      RefreshSamplesGrid;
    finally
      FLoading := False;
    end;
    AnalyzeIfNeeded;
    TMeterValue.SaveToFile(0);
  end;
end;

procedure TFrameMeterValueEdit.FillDimensionCombo;
var
  I: Integer;
begin
  ComboValueDim.Items.Clear;
  ComboValueDim.ItemIndex := -1;

  if FMeterValue = nil then
    Exit;

  for I := 0 to FMeterValue.Dimensions.Count - 1 do
    ComboValueDim.Items.Add(FMeterValue.GetDimName(I));

  if (FMeterValue.CurrentDimIndex >= 0) and
     (FMeterValue.CurrentDimIndex < ComboValueDim.Items.Count) then
    ComboValueDim.ItemIndex := FMeterValue.CurrentDimIndex;
end;

procedure TFrameMeterValueEdit.LoadFromMeterValue(AMeterValue: TMeterValue);
var
  MeterValueChanged: Boolean;
begin
  MeterValueChanged := FMeterValue <> AMeterValue;
  FMeterValue := AMeterValue;
  FLoading := True;
  try
    if FMeterValue = nil then
    begin
      EditName.Text := '';
      EditType.Text := '';
      EditShrtName.Text := '';
      EditDescription.Text := '';
      EditValueFull.Text := '';
      EditGeneratorStartValue.Text := '0';
      EditValue.Text := '';
      ComboValueDim.Items.Clear;
      ComboValueDim.ItemIndex := -1;
      EditMin.Text := '';
      EditMax.Text := '';
      EditAccuracy.Text := '';
      EditError.Text := '';
      CheckBoxShowTrailingZeros.IsChecked := False;
      EditNameValueRate.Text := '';
      EditValueRate.Text := '';
      EditNameValueMultiplier.Text := '';
      EditValueMultiplier.Text := '';
      EditNameValueDevider.Text := '';
      EditValueDevider.Text := '';
      EditCoefK.Text := '';
      EditCoefP.Text := '';
      CheckBoxIsToSave.IsChecked := False;
      FTestTargetValue := 0;
      CopySettingsFromWorkMeterValue;
      LoadSettingsToControls;
      if MeterValueChanged then
        FSampleSource := mssWorkHistory;
      if ComboBoxSampleSource <> nil then
        ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
      UpdateSampleSourceControls;
      ClearTestAnalysis;
      MemoConclusion.Lines.Text := 'В рабочей истории нет данных';
      UpdateStabilityAutoRefreshTimer;
      Exit;
    end;

    EditValueFull.Text := FMeterValue.GetStrFullName;
    EditGeneratorStartValue.Text := FloatToStr(FMeterValue.Value);
    EditValue.Text := FMeterValue.GetStrValue;
    FillDimensionCombo;
    UpdateDimensionCaptions;
    EditMin.Text := FMeterValue.GetStrNum(FMeterValue.MinValue);
    EditMax.Text := FMeterValue.GetStrNum(FMeterValue.MaxValue);
    EditAccuracy.Text := IntToStr(FMeterValue.Accuracy);
    EditError.Text := FloatToStr(FMeterValue.Error);
    CheckBoxShowTrailingZeros.IsChecked := FMeterValue.ShowTrailingZeros;
    EditName.Text := FMeterValue.Name;
    EditType.Text := FMeterValue.&Type;
    EditShrtName.Text := FMeterValue.ShrtName;
    EditDescription.Text := FMeterValue.Description;
    CheckBoxIsToSave.IsChecked := FMeterValue.IsToSave;

    if FMeterValue.ValueRate <> nil then
    begin
      EditNameValueRate.Text := FMeterValue.ValueRate.GetStrFullName;
      EditValueRate.Text := FMeterValue.ValueRate.GetStrValue;
    end
    else
    begin
      EditNameValueRate.Text := '-';
      EditValueRate.Text := '-';
    end;

    if FMeterValue.ValueBaseMultiplier <> nil then
    begin
      EditNameValueMultiplier.Text := FMeterValue.ValueBaseMultiplier.GetStrFullName;
      EditValueMultiplier.Text := FMeterValue.ValueBaseMultiplier.GetStrValue;
    end
    else
    begin
      EditNameValueMultiplier.Text := '-';
      EditValueMultiplier.Text := '-';
    end;

    if FMeterValue.ValueBaseDevider <> nil then
    begin
      EditNameValueDevider.Text := FMeterValue.ValueBaseDevider.GetStrFullName;
      EditValueDevider.Text := FMeterValue.ValueBaseDevider.GetStrValue;
    end
    else
    begin
      EditNameValueDevider.Text := '-';
      EditValueDevider.Text := '-';
    end;

    EditCoefK.Text := FloatToStr(FMeterValue.CoefK);
    EditCoefP.Text := FloatToStr(FMeterValue.CoefP);
    if MeterValueChanged then
    begin
      FTestTargetValue := FMeterValue.Value;
      CopySettingsFromWorkMeterValue;
      LoadSettingsToControls;
      FSampleSource := mssWorkHistory;
      ClearTestAnalysis;
    end
    else
    begin
      EditGeneratorStartValue.Text := BaseToDisplayText(DisplayToBase(EditGeneratorStartValue.Text));
      if not FSettingsModified then
      begin
        CopySettingsFromWorkMeterValue;
        LoadSettingsToControls;
      end
      else
        UpdateTargetLimits;
    end;
      if ComboBoxSampleSource <> nil then
      ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
    UpdateSampleSourceControls;
    RefreshSamplesGrid;
    if (not MeterValueChanged) and (FTestStabilityInfo.Status <> mvssUnknown) then
      DisplayAnalysis(FTestStabilityInfo);
  finally
    FLoading := False;
  end;

  if FMeterValue <> nil then
    RecalculateTestPreview;
  UpdateStabilityAutoRefreshTimer;
end;


procedure TFrameMeterValueEdit.SetStabilityOnlyMode;
begin
  if TabControlStability.Parent <> Self then
    TabControlStability.Parent := Self;
  TabControlStability.Align := TAlignLayout.Client;
  TabControlStability.Visible := True;
  TabControlStability.TabPosition := TTabPosition.Top;

  if LayoutConclusion.Parent <> Self then
    LayoutConclusion.Parent := Self;
  LayoutConclusion.Align := TAlignLayout.Bottom;
  LayoutConclusion.Height := 148;
  LayoutConclusion.Visible := True;
  LayoutConclusion.Enabled := True;
  LayoutConclusion.Opacity := 1;
  LayoutConclusion.BringToFront;

  TabControlMain.Visible := False;
  TabItemMainParameters.Visible := False;
  TabItemStabilityForecast.Visible := False;
  TabItemStabilityData.Visible := True;
  TabItemStabilitySettings.Visible := True;
  TabItemStabilityResult.Visible := True;
end;

procedure TFrameMeterValueEdit.SetIntegratedMode(const AMainParametersParent,
  AStabilityParent: TControl);
begin
  TabControlMain.Visible := False;
  TabItemMainParameters.Visible := False;
  TabItemStabilityForecast.Visible := False;

  if AMainParametersParent <> nil then
  begin
    if LayoutRoot.Parent <> AMainParametersParent then
      LayoutRoot.Parent := AMainParametersParent;
    LayoutRoot.Align := TAlignLayout.Client;
    LayoutRoot.Visible := True;
    LayoutRoot.Enabled := True;
    LayoutRoot.Opacity := 1;
    LayoutRoot.BringToFront;
  end;

  if AStabilityParent <> nil then
  begin
    if TabControlStability.Parent <> AStabilityParent then
      TabControlStability.Parent := AStabilityParent;
    TabControlStability.Align := TAlignLayout.Client;
    TabControlStability.Visible := True;
    TabControlStability.Enabled := True;
    TabControlStability.Opacity := 1;
    TabControlStability.TabPosition := TTabPosition.Top;

    if LayoutConclusion.Parent <> AStabilityParent then
      LayoutConclusion.Parent := AStabilityParent;
    LayoutConclusion.Align := TAlignLayout.Bottom;
    LayoutConclusion.Height := 148;
    LayoutConclusion.Visible := True;
    LayoutConclusion.Enabled := True;
    LayoutConclusion.Opacity := 1;
    LayoutConclusion.BringToFront;
  end;

  TabItemStabilityData.Visible := True;
  TabItemStabilitySettings.Visible := True;
  TabItemStabilityResult.Visible := True;
end;


procedure TFrameMeterValueEdit.SaveChanges;
begin
  if FLoading or (FMeterValue = nil) then
    Exit;

  FMeterValue.Name := EditName.Text;
  FMeterValue.&Type := EditType.Text;
  FMeterValue.ShrtName := EditShrtName.Text;
  FMeterValue.Description := EditDescription.Text;
  if ComboValueDim.ItemIndex >= 0 then
    FMeterValue.SetDim(ComboValueDim.ItemIndex);

  FMeterValue.SetValue(EditValue.Text);
  FMeterValue.MinValue := FMeterValue.GetDoubleNum(EditMin.Text);
  FMeterValue.MaxValue := FMeterValue.GetDoubleNum(EditMax.Text);
  FMeterValue.Accuracy := StrToIntDef(Trim(EditAccuracy.Text), FMeterValue.Accuracy);
  FMeterValue.Error := SafeFloat(EditError.Text);
  FMeterValue.ShowTrailingZeros := CheckBoxShowTrailingZeros.IsChecked;
  FMeterValue.CoefK := SafeFloat(EditCoefK.Text);
  FMeterValue.CoefP := SafeFloat(EditCoefP.Text);
  TMeterValue.SaveToFile(0);
end;

end.
