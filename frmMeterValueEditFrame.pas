unit frmMeterValueEditFrame;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.Platform,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  FMX.Grid,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uBaseProcedures,
  uMeterValue, FMX.Grid.Style, FMX.ScrollBox, uDebugLog;

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
    GroupStabilityScenario: TGroupBox;
    ComboBoxStabilityScenario: TComboBox;
    ButtonApplyScenario: TButton;
    ButtonRunAllScenarios: TButton;
    ButtonCopyScenarioResults: TButton;
    EditGeneratorStartValue: TEdit;
    EditGeneratorCount: TEdit;
    EditGeneratorTimeStep: TEdit;
    EditGeneratorTrend: TEdit;
    EditGeneratorNoise: TEdit;
    EditGeneratorOutlierProbability: TEdit;
    EditGeneratorOutlierAmplitude: TEdit;
    ButtonGenerateNew: TButton;
    ButtonGenerateAppend: TButton;
    ButtonApplyStabilitySettings: TButton;
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
    FLastTestAnalysis: TMeterValueStabilityInfo;
    FTestStableCandidateSinceMs: Int64;
    FTestStabilityConfirmed: Boolean;
    FScenarioBatchReport: string;
    FScenarioBatchRunning: Boolean;
    FSettingsModified: Boolean;
    FModified: Boolean;
    LayoutRoot: TVertScrollBox;
    EditName: TEdit;
    EditType: TEdit;
    EditShrtName: TEdit;
    EditDescription: TEdit;
    EditHash: TEdit;
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
    function SelectedSampleIndex: Integer;
    function GetDisplayedSamples: TArray<TMeterValueSample>;
    procedure RefreshDisplayedSamples;
    procedure SetSampleSource(const ASource: TMeterValueSampleSource);
    procedure UpdateSampleSourceControls;
    procedure ComboBoxSampleSourceChange(Sender: TObject);
    procedure ButtonRefreshHistoryClick(Sender: TObject);
    procedure ButtonUseLastSampleTimeClick(Sender: TObject);
    procedure SetAnalysisTimeByLastDisplayedSample;
    function DisplayUnitName: string;
    function BaseToDisplayText(const AValue: Double): string;
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
    procedure ApplyScenario(const AScenario: TMeterValueTestScenario);
    procedure RunAllScenarios;
    function BuildScenarioReportBlock(const AScenario: TMeterValueTestScenario;
      const AResult: TMeterValueStabilityInfo; const AExpectedPassed: Boolean;
      const AFailureDescription: string): string;
    function BuildScenarioSamplesReport(const AResult: TMeterValueStabilityInfo): string;
    function ValidateScenarioExpectedResult(const AScenario: TMeterValueTestScenario;
      const AResult: TMeterValueStabilityInfo; out AFailureDescription: string): Boolean;
    procedure CopyScenarioBatchReportToClipboard;
    function ScenarioName(const AScenario: TMeterValueTestScenario): string;
    function ScenarioEnumName(const AScenario: TMeterValueTestScenario): string;
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
    procedure ButtonRunAllScenariosClick(Sender: TObject);
    procedure ButtonCopyScenarioResultsClick(Sender: TObject);
    procedure ButtonApplyStabilitySettingsClick(Sender: TObject);
    procedure GridSamplesCellDblClick(const Column: TColumn; const Row: Integer);
    procedure GridSamplesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridSamplesSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure GridSamplesSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure EditAnalysisTimeExit(Sender: TObject);
    procedure CopySettingsFromWorkMeterValue;
    procedure LoadSettingsToControls;
    procedure ReadSettingsFromControls(out ASettings: TMeterValueStabilitySettings);
    function ValidateControls(out AErrorText: string): Boolean;
    procedure HandleSettingsChange(Sender: TObject);
    function TryReadFloat(const AText: string; out AValue: Double): Boolean;
    function TryReadInteger(const AText: string; out AValue: Integer): Boolean;
    procedure UpdateTargetLimits;
    procedure HandleTargetRangeChange(Sender: TObject);
    procedure Analyze;
    procedure ClearTestAnalysis;
    function FindSampleAnalysis(const ARow: Integer; out AResult: TMeterValueSampleAnalysis): Boolean;
    function BoolText(const AValue: Boolean): string;
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromMeterValue(AMeterValue: TMeterValue);
    procedure SaveChanges;
    procedure ApplySettingsToWorkMeterValue;
  end;

implementation

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
  FModified := False;
  FillChar(FTestSettings, SizeOf(FTestSettings), 0);
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
  FTestStableCandidateSinceMs := 0;
  FTestStabilityConfirmed := False;
  FScenarioBatchReport := '';
  FScenarioBatchRunning := False;
  BuildUI;
  ClearAnalysisDisplay;
end;

destructor TFrameMeterValueEdit.Destroy;
begin
  FTestSamples.Free;
  inherited;
end;

procedure TFrameMeterValueEdit.BuildUI;
begin
  LayoutRoot := TVertScrollBox.Create(Self);
  LayoutRoot.Parent := TabItemMainParameters;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

  ComboBoxSampleSource := TComboBox.Create(Self);
  ComboBoxSampleSource.Parent := GroupAnalysis;
  ComboBoxSampleSource.Position.X := 214;
  ComboBoxSampleSource.Position.Y := 4;
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
    Position.Y := 6;
    Size.Width := 190;
    Size.Height := 22;
    Text := 'Источник данных';
  end;

  GroupAnalysis.Height := 188;
  ButtonRefreshHistory := TButton.Create(Self);
  ButtonRefreshHistory.Parent := GroupAnalysis;
  ButtonRefreshHistory.Position.X := 12;
  ButtonRefreshHistory.Position.Y := 122;
  ButtonRefreshHistory.Size.Width := 160;
  ButtonRefreshHistory.Size.Height := 28;
  ButtonRefreshHistory.Text := 'Обновить историю';
  ButtonRefreshHistory.OnClick := ButtonRefreshHistoryClick;

  ButtonUseLastSampleTime := TButton.Create(Self);
  ButtonUseLastSampleTime.Parent := GroupAnalysis;
  ButtonUseLastSampleTime.Position.X := 188;
  ButtonUseLastSampleTime.Position.Y := 122;
  ButtonUseLastSampleTime.Size.Width := 160;
  ButtonUseLastSampleTime.Size.Height := 28;
  ButtonUseLastSampleTime.Text := 'По последней точке';
  ButtonUseLastSampleTime.OnClick := ButtonUseLastSampleTimeClick;

  ButtonSampleAdd.OnClick := ButtonSampleAddClick;
  ButtonSampleEdit.OnClick := ButtonSampleEditClick;
  ButtonSampleDelete.OnClick := ButtonSampleDeleteClick;
  ButtonSamplesClear.OnClick := ButtonSamplesClearClick;
  ButtonAnalyze.OnClick := ButtonAnalyzeClick;
  ButtonGenerateNew.OnClick := ButtonGenerateNewClick;
  ButtonGenerateAppend.OnClick := ButtonGenerateAppendClick;
  ButtonApplyScenario.OnClick := ButtonApplyScenarioClick;

  GroupStabilityScenario.Height := 148;
  ButtonRunAllScenarios := TButton.Create(Self);
  ButtonRunAllScenarios.Parent := GroupStabilityScenario;
  ButtonRunAllScenarios.Position.X := 12;
  ButtonRunAllScenarios.Position.Y := 82;
  ButtonRunAllScenarios.Size.Width := 336;
  ButtonRunAllScenarios.Size.Height := 28;
  ButtonRunAllScenarios.Text := 'Прогнать все сценарии';
  ButtonRunAllScenarios.OnClick := ButtonRunAllScenariosClick;

  ButtonCopyScenarioResults := TButton.Create(Self);
  ButtonCopyScenarioResults.Parent := GroupStabilityScenario;
  ButtonCopyScenarioResults.Position.X := 12;
  ButtonCopyScenarioResults.Position.Y := 114;
  ButtonCopyScenarioResults.Size.Width := 336;
  ButtonCopyScenarioResults.Size.Height := 28;
  ButtonCopyScenarioResults.Text := 'Скопировать результаты';
  ButtonCopyScenarioResults.OnClick := ButtonCopyScenarioResultsClick;
  ButtonApplyStabilitySettings.OnClick := ButtonApplyStabilitySettingsClick;
  CheckBoxAutoAnalyze.OnChange := HandleAutoAnalyzeChange;
  GridSamples.OnCellDblClick := GridSamplesCellDblClick;
  GridSamples.OnGetValue := GridSamplesGetValue;
  GridSamples.OnSetValue := GridSamplesSetValue;
  GridSamples.OnSelectCell := GridSamplesSelectCell;
  EditAnalysisTime.OnExit := EditAnalysisTimeExit;
  CheckBoxStabilityEnabled.OnChange := HandleSettingsChange;
  EditMinSampleCount.OnChange := HandleSettingsChange;
  EditWindowDurationSec.OnChange := HandleSettingsChange;
  EditMaxSampleAgeSec.OnChange := HandleSettingsChange;
  EditConfirmationTimeSec.OnChange := HandleSettingsChange;
  EditExitThresholdFactor.OnChange := HandleSettingsChange;
  EditMaxVariation.OnChange := HandleSettingsChange;
  EditMaxStdDeviation.OnChange := HandleSettingsChange;
  EditMaxTrendRate.OnChange := HandleSettingsChange;
  EditMaxOutlierFractionPercent.OnChange := HandleSettingsChange;
  EditOutlierFactor.OnChange := HandleSettingsChange;
  EditForecastHorizonSec.OnChange := HandleSettingsChange;
  EditTestTargetValue.OnChange := HandleTargetRangeChange;
  EditTargetAccuracyPlusPercent.OnChange := HandleTargetRangeChange;
  EditTargetAccuracyMinusPercent.OnChange := HandleTargetRangeChange;
  EditTargetToleranceAbsolute.OnChange := HandleTargetRangeChange;
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
  AddEditRow('Hash', EditHash);
  EditHash.ReadOnly := True;
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




function TFrameMeterValueEdit.DisplayUnitName: string;
begin
  Result := '';
  if FMeterValue <> nil then
    Result := FMeterValue.GetDimName;
end;

function TFrameMeterValueEdit.BaseToDisplayText(const AValue: Double): string;
begin
  if FMeterValue <> nil then
    Result := FMeterValue.FormatBaseValue(AValue)
  else
    Result := FloatToStr(AValue);
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
  Result := BaseToDisplayText(AValue);
end;

function TFrameMeterValueEdit.FormatBaseDeltaInfo(const AValue: Double;
  const AHasValue: Boolean): string;
begin
  if not AHasValue then
    Exit('—');
  Result := BaseDeltaToDisplayText(AValue);
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
  SetLabelText('LabelSampleValue', 'Значение, ' + UnitName);
  SetLabelText('LabelGeneratorStartValue', 'Начальное значение, ' + UnitName);
  SetLabelText('LabelGeneratorTrend', 'Тренд, ' + UnitName + '/с');
  SetLabelText('LabelGeneratorNoise', 'Шум ±, ' + UnitName);
  SetLabelText('LabelGeneratorOutlierAmplitude', 'Амплитуда выброса, ' + UnitName);
end;

function TFrameMeterValueEdit.GetDisplayedSamples: TArray<TMeterValueSample>;
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

procedure TFrameMeterValueEdit.RefreshDisplayedSamples;
begin
  FDisplayedSamples := GetDisplayedSamples;
  if (FSampleSource = mssWorkHistory) and (Length(FDisplayedSamples) > 0) then
    SetAnalysisTimeByLastDisplayedSample;
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
end;

procedure TFrameMeterValueEdit.UpdateSampleSourceControls;
var
  IsTestMode: Boolean;
  ScenarioGroup: TControl;
  GeneratorGroup: TControl;
begin
  IsTestMode := FSampleSource = mssTestSamples;
  EditSampleTime.Enabled := IsTestMode;
  EditSampleValue.Enabled := IsTestMode;
  EditSampleTimeStep.Enabled := IsTestMode;
  ButtonSampleAdd.Enabled := IsTestMode;
  ButtonSampleEdit.Enabled := IsTestMode;
  ButtonSampleDelete.Enabled := IsTestMode;
  ButtonSamplesClear.Enabled := IsTestMode;
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
  if ButtonRunAllScenarios <> nil then
    ButtonRunAllScenarios.Enabled := IsTestMode and (not FScenarioBatchRunning);
  if ButtonCopyScenarioResults <> nil then
    ButtonCopyScenarioResults.Enabled := IsTestMode and (not FScenarioBatchRunning);
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

procedure TFrameMeterValueEdit.ButtonRefreshHistoryClick(Sender: TObject);
var
  BeforeSamples: TArray<TMeterValueSample>;
  AfterSamples: TArray<TMeterValueSample>;

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

  if FMeterValue <> nil then
    BeforeSamples := FMeterValue.GetStabilitySamples
  else
    SetLength(BeforeSamples, 0);

  Analyze;

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
  RefreshDisplayedSamples;
  SetAnalysisTimeByLastDisplayedSample;
  AnalyzeIfNeeded;
end;

function TFrameMeterValueEdit.SampleSecondsToMs(const ASeconds: Double): Int64;
begin
  Result := Round(ASeconds * 1000);
end;

function TFrameMeterValueEdit.SelectedSampleIndex: Integer;
begin
  Result := -1;
  if (GridSamples <> nil) and (GridSamples.Row >= 0) and
     (GridSamples.Row < Length(FDisplayedSamples)) and (FSampleSource = mssTestSamples) then
    Result := GridSamples.Row;
end;

procedure TFrameMeterValueEdit.LoadSampleToEditor(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= Length(FDisplayedSamples)) then
    Exit;

  EditSampleTime.Text := FloatToStr(FDisplayedSamples[AIndex].TimeStampMs / 1000);
  EditSampleValue.Text := BaseToDisplayText(FDisplayedSamples[AIndex].Value);
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
  GridSamples.Repaint;
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
  if FSampleSource <> mssTestSamples then
    Exit;

  Sample.Value := DisplayToBase(EditSampleValue.Text);
  StepSec := SafeFloat(EditSampleTimeStep.Text);
  if StepSec <= 0 then
  begin
    StepSec := 1.0;
    EditSampleTimeStep.Text := FloatToStr(StepSec);
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
      GridSamples.Row := I;
      GridSamples.Selected := I;
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
  if FSampleSource <> mssTestSamples then
    Exit;

  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

  Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(EditSampleTime.Text));
  Sample.Value := DisplayToBase(EditSampleValue.Text);
  FTestSamples[Index] := Sample;
  SortSamples;
  RefreshSamplesGrid;

  for I := 0 to FTestSamples.Count - 1 do
    if (FTestSamples[I].TimeStampMs = Sample.TimeStampMs) and
       SameValue(FTestSamples[I].Value, Sample.Value) then
    begin
      GridSamples.Row := I;
      GridSamples.Selected := I;
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
  if FSampleSource <> mssTestSamples then
    Exit;

  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

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
  if FSampleSource <> mssTestSamples then
    Exit;
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
    GridSamples.Row := FTestSamples.Count - 1;
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
    GridSamples.Row := FTestSamples.Count - 1;
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

procedure TFrameMeterValueEdit.ApplyScenario(const AScenario: TMeterValueTestScenario);

  procedure AddSamplePoint(const ATimeSec: Integer; const AValue: Double);
  var
    Sample: TMeterValueSample;
  begin
    Sample.TimeStampMs := ATimeSec * 1000;
    Sample.Value := DisplayToBase(FloatToStr(AValue));
    FTestSamples.Add(Sample);
  end;

  procedure AddValues(const AValues: array of Double; const AStartSec: Integer);
  var
    I: Integer;
  begin
    for I := Low(AValues) to High(AValues) do
      AddSamplePoint(AStartSec + I, AValues[I]);
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
    FTestCurrentTimeMs := 10000;
  end;

  procedure AddConstantSamples(const ACount: Integer; const AValue: Double);
  var
    I: Integer;
  begin
    for I := 0 to ACount - 1 do
      AddSamplePoint(I, AValue);
  end;

  function FailReasonsText(const AInfo: TMeterValueStabilityInfo): string;
  var
    Reason: TMeterValueStabilityFailReason;
  begin
    Result := '';
    for Reason := Low(TMeterValueStabilityFailReason) to High(TMeterValueStabilityFailReason) do
      if Reason in AInfo.FailReasons then
      begin
        if Result <> '' then
          Result := Result + ',';
        Result := Result + StabilityFailReasonToText(Reason);
      end;
    if Result = '' then
      Result := 'none';
  end;

  procedure LogAllConditionsAnalysis(const AStage: string);
  begin
    if AScenario <> mtsAllConditionsPassed then
      Exit;

    DebugLog(Format('AllConditions %s: SampleCount=%d UsedSampleCount=%d OutlierCount=%d Variation=%.12g StdDeviation=%.12g TrendRate=%.12g MaxVariation=%.12g MaxStdDeviation=%.12g MaxTrendRate=%.12g LastSampleAgeSec=%.12g IsSignalStable=%s IsStabilityConfirmed=%s FailReasons=%s FTestStableCandidateSinceMs=%d FTestCurrentTimeMs=%d',
      [AStage, FLastTestAnalysis.SampleCount, FLastTestAnalysis.UsedSampleCount,
       FLastTestAnalysis.OutlierCount, FLastTestAnalysis.Variation,
       FLastTestAnalysis.StdDeviation, FLastTestAnalysis.TrendRate,
       FTestSettings.MaxVariation, FTestSettings.MaxStdDeviation,
       FTestSettings.MaxTrendRate, FLastTestAnalysis.LastSampleAgeSec,
       BoolToStr(FLastTestAnalysis.IsSignalStable, True),
       BoolToStr(FLastTestAnalysis.IsStabilityConfirmed, True),
       FailReasonsText(FLastTestAnalysis), FTestStableCandidateSinceMs,
       FTestCurrentTimeMs]));
  end;

begin
  FLoading := True;
  try
    ClearTestAnalysis;
    FTestSamples.Clear;
    FTestStableCandidateSinceMs := 0;
    FTestStabilityConfirmed := False;
  FScenarioBatchReport := '';
  FScenarioBatchRunning := False;
    SetBaseSettings;

    case AScenario of
      mtsConstantValue:
        AddConstantSamples(11, 10);
      mtsStableNoise:
        begin
          FTestSettings.MaxVariation := DisplayDeltaToBase('0.10');
          FTestSettings.MaxStdDeviation := DisplayDeltaToBase('0.05');
          AddValues([10.00, 10.02, 9.99, 10.01, 9.98, 10.00, 10.01, 9.99, 10.02, 10.00, 10.01], 0);
        end;
      mtsSlowIncrease:
        begin
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.01');
          AddValues([10.00, 10.02, 10.04, 10.06, 10.08, 10.10, 10.12, 10.14, 10.16, 10.18, 10.20], 0);
        end;
      mtsSlowDecrease:
        begin
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.01');
          AddValues([10.20, 10.18, 10.16, 10.14, 10.12, 10.10, 10.08, 10.06, 10.04, 10.02, 10.00], 0);
        end;
      mtsSettlingAfterChange:
        begin
          FTestCurrentTimeMs := 20000;
          FTestSettings.MaxSampleAgeSec := 10;
          AddValues([5, 5, 5, 5, 5, 7, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10], 0);
        end;
      mtsSingleOutlier:
        begin
          FTestTargetValue := DisplayToBase('29');
          FTestSettings.TargetAccuracyPlusPercent := 1;
          FTestSettings.TargetAccuracyMinusPercent := 1;
          FTestSettings.MaxOutlierFraction := 0.11;
          AddValues([29.00, 29.02, 28.98, 29.01, 29.00, 39.00, 28.99, 29.03, 29.00, 28.97, 29.01], 0);
        end;
      mtsManyOutliers:
        begin
          FTestTargetValue := DisplayToBase('29');
          FTestSettings.TargetAccuracyPlusPercent := 1;
          FTestSettings.TargetAccuracyMinusPercent := 1;
          FTestSettings.MaxOutlierFraction := 0.10;
          AddValues([29, 29, 29, 29, 39, 29, 29, 19, 29, 29, 29, 39, 29, 29, 29], 0);
          FTestCurrentTimeMs := 14000;
        end;
      mtsNotEnoughData:
        begin
          FTestCurrentTimeMs := 4000;
          AddValues([10.00, 10.01, 9.99, 10.00, 10.01], 0);
        end;
      mtsStaleData:
        begin
          FTestCurrentTimeMs := 30000;
          FTestSettings.WindowDurationSec := 30;
          FTestSettings.MaxSampleAgeSec := 5;
          AddConstantSamples(11, 10);
        end;
      mtsForecastAboveRange:
        begin
          FTestSettings.ForecastHorizonSec := 20;
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.05');
          FTestSettings.TargetAccuracyPlusPercent := 2;
          FTestSettings.TargetAccuracyMinusPercent := 2;
          AddValues([9.80, 9.82, 9.84, 9.86, 9.88, 9.90, 9.92, 9.94, 9.96, 9.98, 10.00], 0);
        end;
      mtsForecastBelowRange:
        begin
          FTestSettings.ForecastHorizonSec := 20;
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.05');
          FTestSettings.TargetAccuracyPlusPercent := 2;
          FTestSettings.TargetAccuracyMinusPercent := 2;
          AddValues([10.20, 10.18, 10.16, 10.14, 10.12, 10.10, 10.08, 10.06, 10.04, 10.02, 10.00], 0);
        end;
      mtsStableOutOfRange:
        AddConstantSamples(11, 0);
      mtsAllConditionsPassed:
        begin
          FTestSettings.MaxVariation := DisplayDeltaToBase('0.01');
          FTestSettings.MaxStdDeviation := DisplayDeltaToBase('0.01');
          FTestSettings.MaxTrendRate := DisplayDeltaToBase('0.001');
          FTestSettings.MaxSampleAgeSec := 3;
          FTestSettings.ConfirmationTimeSec := 3;
          AddConstantSamples(11, 10);
          FTestCurrentTimeMs := 10000;
        end;
    end;

    SortSamples;
    RefreshAllTestControls;
  finally
    FLoading := False;
  end;

  FTestDataModified := True;
  FSettingsModified := True;
  FModified := True;
  if AScenario = mtsAllConditionsPassed then
  begin
    Analyze;
    LogAllConditionsAnalysis('after first analyze');
    AddSamplePoint(11, 10);
    AddSamplePoint(12, 10);
    AddSamplePoint(13, 10);
    SortSamples;
    RefreshSamplesGrid;
    FTestCurrentTimeMs := 13000;
    EditAnalysisTime.Text := FloatToStr(FTestCurrentTimeMs / 1000.0);
    Analyze;
    LogAllConditionsAnalysis('after second analyze');
  end
  else
    Analyze;
end;


function TFrameMeterValueEdit.ScenarioName(const AScenario: TMeterValueTestScenario): string;
begin
  case AScenario of
    mtsConstantValue: Result := 'Постоянное значение';
    mtsStableNoise: Result := 'Стабильный шум';
    mtsSlowIncrease: Result := 'Медленный рост';
    mtsSlowDecrease: Result := 'Медленное снижение';
    mtsSettlingAfterChange: Result := 'Стабилизация после изменения';
    mtsSingleOutlier: Result := 'Единичный выброс';
    mtsManyOutliers: Result := 'Много выбросов';
    mtsNotEnoughData: Result := 'Недостаточно данных';
    mtsStaleData: Result := 'Устаревшие данные';
    mtsForecastAboveRange: Result := 'Прогноз выше верхней границы';
    mtsForecastBelowRange: Result := 'Прогноз ниже нижней границы';
    mtsStableOutOfRange: Result := 'Стабильный сигнал вне диапазона';
    mtsAllConditionsPassed: Result := 'Все условия выполнены';
  else
    Result := '';
  end;
end;

function TFrameMeterValueEdit.ScenarioEnumName(const AScenario: TMeterValueTestScenario): string;
begin
  case AScenario of
    mtsConstantValue: Result := 'mtsConstantValue';
    mtsStableNoise: Result := 'mtsStableNoise';
    mtsSlowIncrease: Result := 'mtsSlowIncrease';
    mtsSlowDecrease: Result := 'mtsSlowDecrease';
    mtsSettlingAfterChange: Result := 'mtsSettlingAfterChange';
    mtsSingleOutlier: Result := 'mtsSingleOutlier';
    mtsManyOutliers: Result := 'mtsManyOutliers';
    mtsNotEnoughData: Result := 'mtsNotEnoughData';
    mtsStaleData: Result := 'mtsStaleData';
    mtsForecastAboveRange: Result := 'mtsForecastAboveRange';
    mtsForecastBelowRange: Result := 'mtsForecastBelowRange';
    mtsStableOutOfRange: Result := 'mtsStableOutOfRange';
    mtsAllConditionsPassed: Result := 'mtsAllConditionsPassed';
  else
    Result := '';
  end;
end;

function TFrameMeterValueEdit.ValidateScenarioExpectedResult(
  const AScenario: TMeterValueTestScenario; const AResult: TMeterValueStabilityInfo;
  out AFailureDescription: string): Boolean;

  function HasReason(const AReason: TMeterValueStabilityFailReason): Boolean;
  begin
    Result := AReason in AResult.FailReasons;
  end;

begin
  Result := True;
  AFailureDescription := '';
  case AScenario of
    mtsConstantValue:
      Result := AResult.IsSignalStable and (AResult.OutlierCount = 0);
    mtsStableNoise:
      Result := AResult.IsSignalStable and (AResult.OutlierCount = 0);
    mtsSlowIncrease:
      Result := (AResult.TrendDirection = tdIncreasing) and (not AResult.IsSignalStable);
    mtsSlowDecrease:
      Result := (AResult.TrendDirection = tdDecreasing) and (not AResult.IsSignalStable);
    mtsSettlingAfterChange:
      Result := AResult.IsSignalStable;
    mtsSingleOutlier:
      Result := AResult.OutlierCount = 1;
    mtsManyOutliers:
      Result := (not AResult.IsSignalStable) and HasReason(mvsfrTooManyOutliers);
    mtsNotEnoughData:
      Result := HasReason(mvsfrNotEnoughSamples) and (not AResult.IsSuitableForMeasurement);
    mtsStaleData:
      Result := HasReason(mvsfrStaleData) and (not AResult.IsSuitableForMeasurement);
    mtsForecastAboveRange, mtsForecastBelowRange:
      Result := not AResult.IsForecastInRange;
    mtsStableOutOfRange:
      Result := AResult.IsSignalStable and (not AResult.IsSuitableForMeasurement);
    mtsAllConditionsPassed:
      Result := AResult.IsSuitableForMeasurement;
  end;
  if not Result then
    AFailureDescription := 'Фактический результат не соответствует ожидаемому контракту сценария.';
end;

function TFrameMeterValueEdit.BuildScenarioSamplesReport(
  const AResult: TMeterValueStabilityInfo): string;
var
  B: TStringBuilder;
  FS: TFormatSettings;
  I: Integer;
  Sample: TMeterValueSample;
  SampleResult: TMeterValueSampleAnalysis;
begin
  FS := TFormatSettings.Invariant;
  FS.DecimalSeparator := '.';
  B := TStringBuilder.Create;
  try
    B.AppendLine('Samples:');
    B.AppendLine('Index; TimeStampMs; TimeSec; ValueBase; ValueDisplay; InWindow; IsOutlier; IsInRange');
    for I := 0 to FTestSamples.Count - 1 do
    begin
      Sample := FTestSamples[I];
      if not FindSampleAnalysis(I, SampleResult) then
        SampleResult := Default(TMeterValueSampleAnalysis);
      B.AppendLine(Format('%d; %d; %s; %s; %s; %s; %s; %s',
        [I + 1, Sample.TimeStampMs, FormatFloat('0.000', Sample.TimeStampMs / 1000.0, FS),
         FormatFloat('0.###############', Sample.Value, FS), BaseToDisplayText(Sample.Value),
         BoolToStr(SampleResult.InWindow, True), BoolToStr(SampleResult.IsOutlier, True),
         BoolToStr(SampleResult.IsInRange, True)]));
    end;
    Result := B.ToString;
  finally
    B.Free;
  end;
end;

function TFrameMeterValueEdit.BuildScenarioReportBlock(
  const AScenario: TMeterValueTestScenario; const AResult: TMeterValueStabilityInfo;
  const AExpectedPassed: Boolean; const AFailureDescription: string): string;
var
  B: TStringBuilder;
  FS: TFormatSettings;
  LowerLimit: Double;
  UpperLimit: Double;
  Reason: TMeterValueStabilityFailReason;
  HasReasons: Boolean;

  function F(const AValue: Double): string;
  begin
    Result := FormatFloat('0.###############', AValue, FS);
  end;

  procedure AddValuePair(const AName: string; const ABase: Double; const AIsDelta: Boolean = False);
  begin
    B.AppendLine(AName + 'Base: ' + F(ABase));
    if AIsDelta then
      B.AppendLine(AName + 'Display: ' + BaseDeltaToDisplayText(ABase) + ' ' + DisplayUnitName)
    else
      B.AppendLine(AName + 'Display: ' + BaseToDisplayText(ABase) + ' ' + DisplayUnitName);
  end;

begin
  FS := TFormatSettings.Invariant;
  FS.DecimalSeparator := '.';
  CalculateTargetLimits(FTestTargetValue, FTestSettings.TargetAccuracyPlusPercent,
    FTestSettings.TargetAccuracyMinusPercent, FTestSettings.TargetToleranceAbsolute,
    LowerLimit, UpperLimit);
  B := TStringBuilder.Create;
  try
    B.AppendLine('============================================================');
    B.AppendLine('СЦЕНАРИЙ: ' + ScenarioName(AScenario));
    B.AppendLine('ENUM: ' + ScenarioEnumName(AScenario));
    B.AppendLine('============================================================');
    B.AppendLine('');
    B.AppendLine('Настройки:');
    B.AppendLine('Enabled: ' + BoolToStr(FTestSettings.Enabled, True));
    B.AppendLine('MinSampleCount: ' + IntToStr(FTestSettings.MinSampleCount));
    B.AppendLine('WindowDurationSec: ' + F(FTestSettings.WindowDurationSec));
    B.AppendLine('MaxSampleAgeSec: ' + F(FTestSettings.MaxSampleAgeSec));
    B.AppendLine('ConfirmationTimeSec: ' + F(FTestSettings.ConfirmationTimeSec));
    B.AppendLine('ExitThresholdFactor: ' + F(FTestSettings.ExitThresholdFactor));
    B.AppendLine('MaxVariation: ' + F(FTestSettings.MaxVariation));
    B.AppendLine('MaxStdDeviation: ' + F(FTestSettings.MaxStdDeviation));
    B.AppendLine('MaxTrendRate: ' + F(FTestSettings.MaxTrendRate));
    B.AppendLine('MaxOutlierFraction: ' + F(FTestSettings.MaxOutlierFraction));
    B.AppendLine('OutlierFactor: ' + F(FTestSettings.OutlierFactor));
    B.AppendLine('ForecastHorizonSec: ' + F(FTestSettings.ForecastHorizonSec));
    B.AppendLine('');
    B.AppendLine('Диапазон:');
    AddValuePair('TargetValue', FTestTargetValue);
    AddValuePair('LowerLimit', LowerLimit);
    AddValuePair('UpperLimit', UpperLimit);
    B.AppendLine('RequireCurrentValueInRange: ' + BoolToStr(FTestSettings.RequireCurrentValueInRange, True));
    B.AppendLine('RequireMeanValueInRange: ' + BoolToStr(FTestSettings.RequireMeanValueInRange, True));
    B.AppendLine('RequireForecastInRange: ' + BoolToStr(FTestSettings.RequireForecastInRange, True));
    B.AppendLine('');
    B.AppendLine('Время анализа:');
    B.AppendLine('CurrentTimeMs: ' + IntToStr(FTestCurrentTimeMs));
    B.AppendLine('CurrentTimeSec: ' + F(FTestCurrentTimeMs / 1000.0));
    B.AppendLine('');
    B.AppendLine('Точки:');
    B.AppendLine('SampleCount: ' + IntToStr(AResult.SampleCount));
    B.AppendLine('UsedSampleCount: ' + IntToStr(AResult.UsedSampleCount));
    B.AppendLine('OutlierCount: ' + IntToStr(AResult.OutlierCount));
    B.AppendLine('OutlierFraction: ' + F(AResult.OutlierFraction));
    B.AppendLine('');
    B.AppendLine('Статистика:');
    AddValuePair('CurrentValue', AResult.CurrentValue);
    AddValuePair('MeanValue', AResult.MeanValue);
    AddValuePair('MinValue', AResult.MinValue);
    AddValuePair('MaxValue', AResult.MaxValue);
    AddValuePair('Variation', AResult.Variation, True);
    AddValuePair('StdDeviation', AResult.StdDeviation, True);
    B.AppendLine('');
    B.AppendLine('Тренд и прогноз:');
    B.AppendLine('TrendRateBasePerSec: ' + F(AResult.TrendRate));
    B.AppendLine('TrendRateDisplayPerSec: ' + BaseDeltaToDisplayText(AResult.TrendRate) + ' ' + DisplayUnitName + '/с');
    B.AppendLine('TrendDirection: ' + TrendDirectionText(AResult.TrendDirection, AResult.HasTrend));
    AddValuePair('ForecastValue', AResult.ForecastValue);
    B.AppendLine('LastSampleAgeSec: ' + F(AResult.LastSampleAgeSec));
    B.AppendLine('');
    B.AppendLine('Состояние:');
    B.AppendLine('IsSignalStable: ' + BoolToStr(AResult.IsSignalStable, True));
    B.AppendLine('IsStabilityConfirmed: ' + BoolToStr(AResult.IsStabilityConfirmed, True));
    B.AppendLine('IsCurrentValueInRange: ' + BoolToStr(AResult.IsCurrentValueInRange, True));
    B.AppendLine('IsMeanValueInRange: ' + BoolToStr(AResult.IsMeanValueInRange, True));
    B.AppendLine('IsForecastInRange: ' + BoolToStr(AResult.IsForecastInRange, True));
    B.AppendLine('IsSuitableForMeasurement: ' + BoolToStr(AResult.IsSuitableForMeasurement, True));
    B.AppendLine('');
    B.AppendLine('Причины:');
    HasReasons := False;
    for Reason := Low(TMeterValueStabilityFailReason) to High(TMeterValueStabilityFailReason) do
      if Reason in AResult.FailReasons then
      begin
        HasReasons := True;
        B.AppendLine(StabilityFailReasonToText(Reason));
      end;
    if not HasReasons then
      B.AppendLine('Нет');
    B.AppendLine('');
    B.AppendLine('Заключение:');
    B.AppendLine(AResult.StatusText);
    B.AppendLine('');
    B.AppendLine(BuildScenarioSamplesReport(AResult));
    B.AppendLine('Ожидаемый результат:');
    if AExpectedPassed then
      B.AppendLine('Контракт сценария выполнен.')
    else
      B.AppendLine(AFailureDescription);
    B.AppendLine('');
    B.AppendLine('Проверка ожидания:');
    if AExpectedPassed then
      B.AppendLine('PASS')
    else
      B.AppendLine('FAIL');
    B.AppendLine('');
    Result := B.ToString;
  finally
    B.Free;
  end;
end;

procedure TFrameMeterValueEdit.RunAllScenarios;
var
  SavedSource: TMeterValueSampleSource;
  SavedScenarioIndex: Integer;
  SavedAutoAnalyze: Boolean;
  SavedSamples: TArray<TMeterValueSample>;
  SavedSettings: TMeterValueStabilitySettings;
  SavedCurrentTimeMs: Int64;
  SavedTargetValue: Double;
  SavedStableCandidateSinceMs: Int64;
  SavedStabilityConfirmed: Boolean;
  Scenario: TMeterValueTestScenario;
  B: TStringBuilder;
  Summary: TStringBuilder;
  FailedNames: TStringBuilder;
  ExpectedPassed: Boolean;
  FailureDescription: string;
  PassCount: Integer;
  FailCount: Integer;
  AllConditionsPassed: Boolean;
  I: Integer;

  function ScenarioCheckText(const AValue: Boolean): string;
  begin
    if AValue then
      Result := 'PASS'
    else
      Result := 'FAIL';
  end;

begin
  if FScenarioBatchRunning then
    Exit;

  SavedSource := FSampleSource;
  SavedScenarioIndex := ComboBoxStabilityScenario.ItemIndex;
  SavedAutoAnalyze := CheckBoxAutoAnalyze.IsChecked;
  SavedSamples := FTestSamples.ToArray;
  SavedSettings := FTestSettings;
  SavedCurrentTimeMs := FTestCurrentTimeMs;
  SavedTargetValue := FTestTargetValue;
  SavedStableCandidateSinceMs := FTestStableCandidateSinceMs;
  SavedStabilityConfirmed := FTestStabilityConfirmed;
  PassCount := 0;
  FailCount := 0;
  AllConditionsPassed := False;
  FScenarioBatchReport := '';
  FScenarioBatchRunning := True;
  ButtonRunAllScenarios.Enabled := False;
  ButtonApplyScenario.Enabled := False;
  ButtonCopyScenarioResults.Enabled := False;

  B := TStringBuilder.Create;
  Summary := TStringBuilder.Create;
  FailedNames := TStringBuilder.Create;
  try
    B.AppendLine('STABILITY SCENARIO REPORT');
    B.AppendLine('Дата и время формирования:');
    B.AppendLine(DateTimeToStr(Now));
    B.AppendLine('Количество сценариев:');
    B.AppendLine(IntToStr(Ord(High(TMeterValueTestScenario)) - Ord(Low(TMeterValueTestScenario)) + 1));
    B.AppendLine('Источник:');
    B.AppendLine('Тестовый массив');
    B.AppendLine('Размерность:');
    B.AppendLine(DisplayUnitName);
    B.AppendLine('');

    CheckBoxAutoAnalyze.IsChecked := False;
    SetSampleSource(mssTestSamples);

    for Scenario := Low(TMeterValueTestScenario) to High(TMeterValueTestScenario) do
    begin
      try
        ApplyScenario(Scenario);
        ExpectedPassed := ValidateScenarioExpectedResult(Scenario, FLastTestAnalysis, FailureDescription);
        if ExpectedPassed then
          Inc(PassCount)
        else
        begin
          Inc(FailCount);
          FailedNames.AppendLine('- ' + ScenarioName(Scenario));
        end;
        if Scenario = mtsAllConditionsPassed then
          AllConditionsPassed := ExpectedPassed;
        B.Append(BuildScenarioReportBlock(Scenario, FLastTestAnalysis, ExpectedPassed, FailureDescription));
        Summary.AppendLine(Format('%s | %s | %s | %s | %s | %s | %s | %s',
          [ScenarioName(Scenario), BoolText(FLastTestAnalysis.IsSignalStable),
           BoolText(FLastTestAnalysis.IsStabilityConfirmed), BoolText(FLastTestAnalysis.IsCurrentValueInRange),
           BoolText(FLastTestAnalysis.IsMeanValueInRange), BoolText(FLastTestAnalysis.IsForecastInRange),
           BoolText(FLastTestAnalysis.IsSuitableForMeasurement),
           ScenarioCheckText(ExpectedPassed)]));
      except
        on E: Exception do
        begin
          Inc(FailCount);
          FailedNames.AppendLine('- ' + ScenarioName(Scenario));
          B.AppendLine('============================================================');
          B.AppendLine('СЦЕНАРИЙ: ' + ScenarioName(Scenario));
          B.AppendLine('ENUM: ' + ScenarioEnumName(Scenario));
          B.AppendLine('============================================================');
          B.AppendLine('ERROR:');
          B.AppendLine(E.ClassName + ': ' + E.Message);
          B.AppendLine('Проверка ожидания:');
          B.AppendLine('FAIL');
          B.AppendLine('');
          Summary.AppendLine(ScenarioName(Scenario) + ' | Нет | Нет | Нет | Нет | Нет | Нет | FAIL');
        end;
      end;
    end;

    B.AppendLine('============================================================');
    B.AppendLine('ИТОГ');
    B.AppendLine('============================================================');
    B.AppendLine('Всего сценариев: ' + IntToStr(Ord(High(TMeterValueTestScenario)) - Ord(Low(TMeterValueTestScenario)) + 1));
    B.AppendLine('PASS: ' + IntToStr(PassCount));
    B.AppendLine('FAIL: ' + IntToStr(FailCount));
    B.AppendLine('');
    B.AppendLine('Сценарии с FAIL:');
    if FailedNames.Length = 0 then
      B.AppendLine('Нет')
    else
      B.Append(FailedNames.ToString);
    B.AppendLine('');
    B.AppendLine('Полностью положительный сценарий:');
    B.AppendLine('Все условия выполнены = ' + ScenarioCheckText(AllConditionsPassed));
    B.AppendLine('');
    B.AppendLine('Сценарий | Stable | Confirmed | CurrentRange | MeanRange | ForecastRange | Suitable | Result');
    B.Append(Summary.ToString);
    B.AppendLine('END OF STABILITY SCENARIO REPORT');
    FScenarioBatchReport := B.ToString;
  finally
    FTestSamples.Clear;
    for I := 0 to High(SavedSamples) do
      FTestSamples.Add(SavedSamples[I]);
    FTestSettings := SavedSettings;
    FTestCurrentTimeMs := SavedCurrentTimeMs;
    FTestTargetValue := SavedTargetValue;
    FTestStableCandidateSinceMs := SavedStableCandidateSinceMs;
    FTestStabilityConfirmed := SavedStabilityConfirmed;
    CheckBoxAutoAnalyze.IsChecked := SavedAutoAnalyze;
    if ComboBoxStabilityScenario <> nil then
      ComboBoxStabilityScenario.ItemIndex := SavedScenarioIndex;
    FSampleSource := SavedSource;
    if ComboBoxSampleSource <> nil then
      ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
    FScenarioBatchRunning := False;
    UpdateSampleSourceControls;
    LoadSettingsToControls;
    RefreshSamplesGrid;
    ButtonApplyScenario.Enabled := FSampleSource = mssTestSamples;
    ButtonRunAllScenarios.Enabled := FSampleSource = mssTestSamples;
    ButtonCopyScenarioResults.Enabled := FSampleSource = mssTestSamples;
    B.Free;
    Summary.Free;
    FailedNames.Free;
  end;

  ShowMessage(Format('Проверка завершена. PASS: %d, FAIL: %d.', [PassCount, FailCount]));
end;

procedure TFrameMeterValueEdit.CopyScenarioBatchReportToClipboard;
var
  ClipboardService: IFMXClipboardService;
begin
  if FScenarioBatchReport = '' then
  begin
    ShowMessage('Сначала выполните все сценарии.');
    Exit;
  end;

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(ClipboardService)) then
  begin
    ClipboardService.SetClipboard(FScenarioBatchReport);
    ShowMessage('Результаты скопированы в буфер обмена.');
  end
  else
    ShowMessage('Буфер обмена недоступен на этой платформе.');
end;

procedure TFrameMeterValueEdit.ButtonRunAllScenariosClick(Sender: TObject);
begin
  RunAllScenarios;
end;

procedure TFrameMeterValueEdit.ButtonCopyScenarioResultsClick(Sender: TObject);
begin
  CopyScenarioBatchReportToClipboard;
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
  Analyze;
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
    1: Value := FloatToStr(FDisplayedSamples[ARow].TimeStampMs / 1000);
    2: Value := IntToStr(FDisplayedSamples[ARow].TimeStampMs);
    3: Value := BaseToDisplayText(FDisplayedSamples[ARow].Value);
    4: if FindSampleAnalysis(ARow, AResult) then Value := BoolText(AResult.InWindow) else Value := '';
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

  if (ARow < 0) or (ARow >= FTestSamples.Count) then
    Exit;

  if not (ACol in [1, 3]) then
    Exit;

  Sample := FTestSamples[ARow];
  case ACol of
    1: Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(Value.ToString));
    3: Sample.Value := DisplayToBase(Value.ToString);
  end;

  FTestSamples[ARow] := Sample;
  SortSamples;
  RefreshSamplesGrid;
  for I := 0 to FTestSamples.Count - 1 do
    if (FTestSamples[I].TimeStampMs = Sample.TimeStampMs) and
       SameValue(FTestSamples[I].Value, Sample.Value) then
    begin
      GridSamples.Row := I;
      GridSamples.Selected := I;
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
  if FLoading then
    Exit;

  UpdateTargetLimits;
  if Sender <> EditTestTargetValue then
    FSettingsModified := True;
  FTestDataModified := True;
  FModified := True;
  AnalyzeIfNeeded;
end;

procedure TFrameMeterValueEdit.ClearTestAnalysis;
begin
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
  FTestStableCandidateSinceMs := 0;
  FTestStabilityConfirmed := False;
  FScenarioBatchReport := '';
  FScenarioBatchRunning := False;
  ClearAnalysisDisplay;
  RefreshSamplesGrid;
end;

function TFrameMeterValueEdit.BoolText(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function TFrameMeterValueEdit.FindSampleAnalysis(const ARow: Integer;
  out AResult: TMeterValueSampleAnalysis): Boolean;
var
  I: Integer;
begin
  Result := False;
  AResult := Default(TMeterValueSampleAnalysis);
  if (ARow < 0) or (ARow >= Length(FDisplayedSamples)) then
    Exit;

  for I := 0 to High(FLastTestAnalysis.SampleResults) do
    if (FLastTestAnalysis.SampleResults[I].SourceIndex = ARow) and
       (FLastTestAnalysis.SampleResults[I].TimeStampMs = FDisplayedSamples[ARow].TimeStampMs) then
    begin
      AResult := FLastTestAnalysis.SampleResults[I];
      Exit(True);
    end;

  for I := 0 to High(FLastTestAnalysis.SampleResults) do
    if FLastTestAnalysis.SampleResults[I].TimeStampMs = FDisplayedSamples[ARow].TimeStampMs then
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
    Analyze
  else
    ClearTestAnalysis;
end;

procedure TFrameMeterValueEdit.HandleAutoAnalyzeChange(Sender: TObject);
begin
  if (not FLoading) and CheckBoxAutoAnalyze.IsChecked then
    Analyze;
end;

procedure TFrameMeterValueEdit.Analyze;
var
  ErrorText: string;
  Settings: TMeterValueStabilitySettings;
  Samples: TArray<TMeterValueSample>;
  LowerLimit: Double;
  UpperLimit: Double;
  I: Integer;
begin
  if FMeterValue = nil then
    Exit;

  RefreshDisplayedSamples;
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
    ShowMessage('Анализ не выполнен.' + sLineBreak + ErrorText);
    Exit;
  end;

  ReadSettingsFromControls(Settings);
  UpdateTargetLimits;
  LowerLimit := DisplayToBase(EditTargetLowerLimit.Text);
  UpperLimit := DisplayToBase(EditTargetUpperLimit.Text);

  if FSampleSource = mssWorkHistory then
    SetAnalysisTimeByLastDisplayedSample
  else
    FTestCurrentTimeMs := SampleSecondsToMs(SafeFloat(EditAnalysisTime.Text));
  SetLength(Samples, Length(FDisplayedSamples));
  for I := 0 to High(FDisplayedSamples) do
    Samples[I] := FDisplayedSamples[I];

  TMeterValue.AnalyzeStabilitySamples(Samples, Settings, FTestCurrentTimeMs,
    FTestTargetValue, LowerLimit, UpperLimit, FTestStableCandidateSinceMs,
    FTestStabilityConfirmed, FLastTestAnalysis);
  DisplayAnalysis(FLastTestAnalysis);
  RefreshSamplesGrid(False);
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
    Lines.Add('Всего отсчётов: ' + IntToStr(AInfo.SampleCount) + '.');
    Lines.Add('Использовано отсчётов: ' + IntToStr(AInfo.UsedSampleCount) + '.');
    Lines.Add('Текущее значение: ' + FormatBaseInfo(AInfo.CurrentValue, AInfo.HasCurrentValue) + '.');
    Lines.Add('Среднее значение: ' + FormatBaseInfo(AInfo.MeanValue, AInfo.HasStatistics) + '.');
    Lines.Add('Допустимый диапазон: ' + EditTargetLowerLimit.Text + '–' + EditTargetUpperLimit.Text + '.');

    Lines.Add('');
    Lines.Add('Размах: ' + FormatBaseDeltaInfo(AInfo.Variation, AInfo.HasStatistics) + '.');
    Lines.Add('Стандартное отклонение: ' + FormatBaseDeltaInfo(AInfo.StdDeviation, AInfo.HasStatistics) + '.');
    Lines.Add('Скорость тренда: ' + EditResultTrendRate.Text + ' ' + DisplayUnitName + '/с.');
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
var
  ErrorText: string;
  Settings: TMeterValueStabilitySettings;
begin
  if FMeterValue = nil then
    Exit;

  if not ValidateControls(ErrorText) then
  begin
    ShowMessage('Настройки стабильности не применены.' + sLineBreak + ErrorText);
    Exit;
  end;

  ReadSettingsFromControls(Settings);
  FMeterValue.StabilitySettings := Settings;
  CopySettingsFromWorkMeterValue;
  LoadSettingsToControls;
  FModified := FTestDataModified;
end;

procedure TFrameMeterValueEdit.ButtonApplyStabilitySettingsClick(Sender: TObject);
begin
  ApplySettingsToWorkMeterValue;
end;

procedure TFrameMeterValueEdit.CopySettingsFromWorkMeterValue;
begin
  FillChar(FTestSettings, SizeOf(FTestSettings), 0);
  if FMeterValue <> nil then
    FTestSettings := FMeterValue.StabilitySettings;
  FSettingsModified := False;
end;

procedure TFrameMeterValueEdit.LoadSettingsToControls;
begin
  FLoading := True;
  try
    CheckBoxStabilityEnabled.IsChecked := FTestSettings.Enabled;
    EditMinSampleCount.Text := IntToStr(FTestSettings.MinSampleCount);
    EditWindowDurationSec.Text := FloatToStr(FTestSettings.WindowDurationSec);
    EditMaxSampleAgeSec.Text := FloatToStr(FTestSettings.MaxSampleAgeSec);
    EditConfirmationTimeSec.Text := FloatToStr(FTestSettings.ConfirmationTimeSec);
    EditExitThresholdFactor.Text := FloatToStr(FTestSettings.ExitThresholdFactor);
    EditMaxVariation.Text := BaseDeltaToDisplayText(FTestSettings.MaxVariation);
    EditMaxStdDeviation.Text := BaseDeltaToDisplayText(FTestSettings.MaxStdDeviation);
    EditMaxTrendRate.Text := BaseDeltaToDisplayText(FTestSettings.MaxTrendRate);
    EditMaxOutlierFractionPercent.Text := FloatToStr(FTestSettings.MaxOutlierFraction * 100);
    EditOutlierFactor.Text := FloatToStr(FTestSettings.OutlierFactor);
    EditForecastHorizonSec.Text := FloatToStr(FTestSettings.ForecastHorizonSec);
    EditTestTargetValue.Text := BaseToDisplayText(FTestTargetValue);
    EditTargetAccuracyPlusPercent.Text := FloatToStr(FTestSettings.TargetAccuracyPlusPercent);
    EditTargetAccuracyMinusPercent.Text := FloatToStr(FTestSettings.TargetAccuracyMinusPercent);
    EditTargetToleranceAbsolute.Text := BaseDeltaToDisplayText(FTestSettings.TargetToleranceAbsolute);
    CheckBoxRequireCurrentValueInRange.IsChecked := FTestSettings.RequireCurrentValueInRange;
    CheckBoxRequireMeanValueInRange.IsChecked := FTestSettings.RequireMeanValueInRange;
    CheckBoxRequireForecastInRange.IsChecked := FTestSettings.RequireForecastInRange;
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
  TryReadFloat(EditTargetAccuracyPlusPercent.Text, ASettings.TargetAccuracyPlusPercent);
  TryReadFloat(EditTargetAccuracyMinusPercent.Text, ASettings.TargetAccuracyMinusPercent);
  ASettings.TargetToleranceAbsolute := DisplayDeltaToBase(EditTargetToleranceAbsolute.Text);
  ASettings.RequireCurrentValueInRange := CheckBoxRequireCurrentValueInRange.IsChecked;
  ASettings.RequireMeanValueInRange := CheckBoxRequireMeanValueInRange.IsChecked;
  ASettings.RequireForecastInRange := CheckBoxRequireForecastInRange.IsChecked;
end;

function TFrameMeterValueEdit.ValidateControls(out AErrorText: string): Boolean;
var
  DoubleValue: Double;
  IntValue: Integer;
begin
  Result := False;
  AErrorText := '';

  if not TryReadInteger(EditMinSampleCount.Text, IntValue) then
    AErrorText := 'Некорректное минимальное количество отсчётов.'
  else if IntValue < 2 then
    AErrorText := 'Минимальное количество отсчётов должно быть не меньше 2.'
  else if (not TryReadFloat(EditWindowDurationSec.Text, DoubleValue)) or (DoubleValue <= 0) then
    AErrorText := 'Длительность окна должна быть положительным числом.'
  else if (not TryReadFloat(EditMaxSampleAgeSec.Text, DoubleValue)) or (DoubleValue <= 0) then
    AErrorText := 'Максимальный возраст данных должен быть положительным числом.'
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
var
  ErrorText: string;
begin
  if FLoading then
    Exit;

  FSettingsModified := True;
  FModified := True;
  if ValidateControls(ErrorText) then
    ReadSettingsFromControls(FTestSettings);
  AnalyzeIfNeeded;
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
  SaveChanges;
end;

procedure TFrameMeterValueEdit.HandleComboChange(Sender: TObject);
var
  GeneratorStartBase: Double;
  GeneratorTrendBase: Double;
  GeneratorNoiseBase: Double;
  GeneratorOutlierBase: Double;
begin
  if FLoading or (FMeterValue = nil) or (ComboValueDim.ItemIndex < 0) then
    Exit;

  GeneratorStartBase := DisplayToBase(EditGeneratorStartValue.Text);
  GeneratorTrendBase := DisplayDeltaToBase(EditGeneratorTrend.Text);
  GeneratorNoiseBase := DisplayDeltaToBase(EditGeneratorNoise.Text);
  GeneratorOutlierBase := DisplayDeltaToBase(EditGeneratorOutlierAmplitude.Text);

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
begin
  FMeterValue := AMeterValue;
  FLoading := True;
  try
    if FMeterValue = nil then
    begin
      EditName.Text := '';
      EditType.Text := '';
      EditShrtName.Text := '';
      EditDescription.Text := '';
      EditHash.Text := '';
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
      FSampleSource := mssWorkHistory;
      if ComboBoxSampleSource <> nil then
        ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
      UpdateSampleSourceControls;
      ClearTestAnalysis;
      MemoConclusion.Lines.Text := 'В рабочей истории нет данных';
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
    EditHash.Text := FMeterValue.Hash;
    EditHash.ReadOnly := True;
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
    FTestTargetValue := FMeterValue.Value;
    CopySettingsFromWorkMeterValue;
    LoadSettingsToControls;
    FSampleSource := mssWorkHistory;
    if ComboBoxSampleSource <> nil then
      ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
    UpdateSampleSourceControls;
    Analyze;
  finally
    FLoading := False;
  end;
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
  FMeterValue.SetToSave(CheckBoxIsToSave.IsChecked);
  TMeterValue.SaveToFile(0);
end;

end.
