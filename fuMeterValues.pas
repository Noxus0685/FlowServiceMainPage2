unit fuMeterValues;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  FMXTee.Chart,
  FMXTee.Engine,
  FMXTee.Procs,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uDebugLog,
  uMeterValue;

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

  TFormMeterValues = class(TForm)
    StyleBook1: TStyleBook;
    ToolBar1: TToolBar;
    Button1: TButton;
    TabControlMeterValueSettings: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    LayoutCommonSettings: TLayout;
    EditName: TEdit;
    EditShrtName: TEdit;
    EditDescription: TEdit;
    LayoutValues: TLayout;
    EditValue: TEdit;
    EditValueDim: TEdit;
    EditMin: TEdit;
    EditMax: TEdit;
    StringGridCoefsData: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumnValue: TStringColumn;
    StringColumnEtalon: TStringColumn;
    StringColumnQ1: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    StringColumnCoefsDataHash: TStringColumn;
    RefreshConfigButton: TButton;
    DeleteConfigButton: TButton;
    AddRowButton: TButton;
    DeleteRowButton: TButton;
    LoadConfigButton: TButton;
    SaveConfigButton: TButton;
    StringGridDimensions: TStringGrid;
    StringColumn8: TStringColumn;
    StringColumn9: TStringColumn;
    StringColumn10: TStringColumn;
    StringColumn11: TStringColumn;
    StringColumnRecip: TStringColumn;
    StringColumnHash: TStringColumn;
    ButtonCoefsLoad: TButton;
    StringGridCoefs: TStringGrid;
    CheckColumn2: TCheckColumn;
    StringColumn4: TStringColumn;
    StringColumn13: TStringColumn;
    StringColumn14: TStringColumn;
    StringColumn15: TStringColumn;
    StringColumn16: TStringColumn;
    StringColumn17: TStringColumn;
    StringColumn18: TStringColumn;
    Chart1: TChart;
    CheckBoxIsToSave: TCheckBox;
    EditHash: TEdit;
    TabItem4: TTabItem;
    EditTestValueDim: TEdit;
    LabelValueDim: TLabel;
    LabelTestValueDim: TLabel;
    LabelValueRaw: TLabel;
    EditTestValueRaw: TEdit;
    LabelTestValue: TLabel;
    EditValueFull: TEdit;
    LabelValueName: TLabel;
    EditValueType: TEdit;
    TabItemListValues: TTabItem;
    StringGridValuesList: TStringGrid;
    EditNameValueMultiplier: TEdit;
    EditCoefK: TEdit;
    EditCoefP: TEdit;
    EditValueMultiplier: TEdit;
    EditNameValueDevider: TEdit;
    EditValueDevider: TEdit;
    EditNameValueRate: TEdit;
    EditValueRate: TEdit;
    LabelTestValueWoCorrection: TLabel;
    StringColumnDescription: TStringColumn;
    sbClear: TSpeedButton;
    sbFind: TSpeedButton;
    EditFindDevice: TEdit;
    SpeedButtonFindInternet: TSpeedButton;
    Layout22: TLayout;
    TabItemStabilityForecast: TTabItem;
    LayoutConclusion: TLayout;
    LabelConclusionTitle: TLabel;
    LayoutConclusionIndicators: TLayout;
    RectangleSignalStable: TRectangle;
    LabelSignalStableCaption: TLabel;
    LabelSignalStableValue: TLabel;
    RectangleStabilityConfirmed: TRectangle;
    LabelStabilityConfirmedCaption: TLabel;
    LabelStabilityConfirmedValue: TLabel;
    RectangleCurrentInRange: TRectangle;
    LabelCurrentInRangeCaption: TLabel;
    LabelCurrentInRangeValue: TLabel;
    RectangleMeanInRange: TRectangle;
    LabelMeanInRangeCaption: TLabel;
    LabelMeanInRangeValue: TLabel;
    RectangleForecastInRange: TRectangle;
    LabelForecastInRangeCaption: TLabel;
    LabelForecastInRangeValue: TLabel;
    RectangleSuitable: TRectangle;
    LabelSuitableCaption: TLabel;
    LabelSuitableValue: TLabel;
    MemoConclusion: TMemo;
    TabControlStability: TTabControl;
    TabItemStabilityData: TTabItem;
    LayoutDataRoot: TLayout;
    GroupSamplesGrid: TGroupBox;
    GridSamples: TGrid;
    StringColumnSampleNumber: TStringColumn;
    StringColumnSampleTime: TStringColumn;
    StringColumnSampleMark: TStringColumn;
    StringColumnSampleValue: TStringColumn;
    StringColumnSampleInWindow: TStringColumn;
    StringColumnSampleOutlier: TStringColumn;
    StringColumnSampleInRange: TStringColumn;
    LayoutSampleSide: TVertScrollBox;
    GroupAnalysis: TGroupBox;
    LabelAnalysisTime: TLabel;
    EditAnalysisTime: TEdit;
    ButtonAnalyze: TButton;
    CheckBoxAutoAnalyze: TCheckBox;
    GroupStabilityScenario: TGroupBox;
    ComboBoxStabilityScenario: TComboBox;
    ButtonApplyScenario: TButton;
    GroupSamplesActions: TGroupBox;
    ButtonSampleAdd: TButton;
    ButtonSampleEdit: TButton;
    ButtonSampleDelete: TButton;
    ButtonSamplesClear: TButton;
    GroupSampleEditor: TGroupBox;
    LabelSampleTime: TLabel;
    EditSampleTime: TEdit;
    LabelSampleValue: TLabel;
    EditSampleValue: TEdit;
    LabelSampleTimeStep: TLabel;
    EditSampleTimeStep: TEdit;
    GroupSamplesGenerator: TGroupBox;
    LabelGeneratorStartValue: TLabel;
    EditGeneratorStartValue: TEdit;
    LabelGeneratorCount: TLabel;
    EditGeneratorCount: TEdit;
    LabelGeneratorTimeStep: TLabel;
    EditGeneratorTimeStep: TEdit;
    LabelGeneratorTrend: TLabel;
    EditGeneratorTrend: TEdit;
    LabelGeneratorNoise: TLabel;
    EditGeneratorNoise: TEdit;
    LabelGeneratorOutlierProbability: TLabel;
    EditGeneratorOutlierProbability: TEdit;
    LabelGeneratorOutlierAmplitude: TLabel;
    EditGeneratorOutlierAmplitude: TEdit;
    ButtonGenerateNew: TButton;
    ButtonGenerateAppend: TButton;
    TabItemStabilitySettings: TTabItem;
    SettingsScrollBox: TVertScrollBox;
    ButtonApplyStabilitySettings: TButton;
    GroupSettingsCommon: TGroupBox;
    CheckBoxStabilityEnabled: TCheckBox;
    LabelMinSampleCount: TLabel;
    EditMinSampleCount: TEdit;
    LabelWindowDurationSec: TLabel;
    EditWindowDurationSec: TEdit;
    LabelMaxSampleAgeSec: TLabel;
    EditMaxSampleAgeSec: TEdit;
    LabelConfirmationTimeSec: TLabel;
    EditConfirmationTimeSec: TEdit;
    LabelExitThresholdFactor: TLabel;
    EditExitThresholdFactor: TEdit;
    GroupSettingsScatter: TGroupBox;
    LabelMaxVariation: TLabel;
    EditMaxVariation: TEdit;
    LabelMaxStdDeviation: TLabel;
    EditMaxStdDeviation: TEdit;
    LabelMaxTrendRate: TLabel;
    EditMaxTrendRate: TEdit;
    GroupSettingsOutliers: TGroupBox;
    LabelMaxOutlierFractionPercent: TLabel;
    EditMaxOutlierFractionPercent: TEdit;
    LabelOutlierFactor: TLabel;
    EditOutlierFactor: TEdit;
    GroupSettingsForecast: TGroupBox;
    LabelForecastHorizonSec: TLabel;
    EditForecastHorizonSec: TEdit;
    GroupSettingsTargetRange: TGroupBox;
    LabelTestTargetValue: TLabel;
    EditTestTargetValue: TEdit;
    LabelTargetAccuracyPlusPercent: TLabel;
    EditTargetAccuracyPlusPercent: TEdit;
    LabelTargetAccuracyMinusPercent: TLabel;
    EditTargetAccuracyMinusPercent: TEdit;
    LabelTargetToleranceAbsolute: TLabel;
    EditTargetToleranceAbsolute: TEdit;
    CheckBoxRequireCurrentValueInRange: TCheckBox;
    CheckBoxRequireMeanValueInRange: TCheckBox;
    CheckBoxRequireForecastInRange: TCheckBox;
    LabelTargetLowerLimit: TLabel;
    EditTargetLowerLimit: TEdit;
    LabelTargetUpperLimit: TLabel;
    EditTargetUpperLimit: TEdit;
    TabItemStabilityResult: TTabItem;
    ResultScrollBox: TVertScrollBox;
    GroupResultStatistics: TGroupBox;
    LabelResultSampleCount: TLabel;
    EditResultSampleCount: TEdit;
    LabelResultUsedSampleCount: TLabel;
    EditResultUsedSampleCount: TEdit;
    LabelResultOutlierCount: TLabel;
    EditResultOutlierCount: TEdit;
    LabelResultOutlierFraction: TLabel;
    EditResultOutlierFraction: TEdit;
    LabelResultWindowDuration: TLabel;
    EditResultWindowDuration: TEdit;
    LabelResultLastSampleAge: TLabel;
    EditResultLastSampleAge: TEdit;
    LabelResultCurrentValue: TLabel;
    EditResultCurrentValue: TEdit;
    LabelResultMeanValue: TLabel;
    EditResultMeanValue: TEdit;
    LabelResultMinValue: TLabel;
    EditResultMinValue: TEdit;
    LabelResultMaxValue: TLabel;
    EditResultMaxValue: TEdit;
    LabelResultVariation: TLabel;
    EditResultVariation: TEdit;
    LabelResultStdDeviation: TLabel;
    EditResultStdDeviation: TEdit;
    GroupResultTrendForecast: TGroupBox;
    LabelResultTrendRate: TLabel;
    EditResultTrendRate: TEdit;
    LabelResultTrendDirection: TLabel;
    EditResultTrendDirection: TEdit;
    LabelResultForecastHorizon: TLabel;
    EditResultForecastHorizon: TEdit;
    LabelResultForecastValue: TLabel;
    EditResultForecastValue: TEdit;
    LabelResultForecastInRange: TLabel;
    EditResultForecastInRange: TEdit;
    GroupResultReasons: TGroupBox;
    ListBoxStabilityReasons: TListBox;
    GroupResultDetailedConclusion: TGroupBox;
    MemoStabilityConclusion: TMemo;
    procedure FormShow(Sender: TObject);
    procedure AddRowButtonClick(Sender: TObject);
    procedure StringGridCoefsDataEditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure SaveConfigButtonClick(Sender: TObject);
    procedure DeleteRowButtonClick(Sender: TObject);
    procedure StringGridCoefsDataKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure RefreshConfigButtonClick(Sender: TObject);
    procedure LoadConfigButtonClick(Sender: TObject);
    procedure StringGridDimensionsSelChanged(Sender: TObject);
    procedure ButtonCoefsLoadClick(Sender: TObject);
    procedure TabControlMeterValueSettingsChange(Sender: TObject);
    procedure CheckBoxIsToSaveChange(Sender: TObject);
    procedure EditNameExit(Sender: TObject);
    procedure EditShrtNameExit(Sender: TObject);
    procedure EditDescriptionExit(Sender: TObject);
    procedure EditHashExit(Sender: TObject);
    procedure EditValueExit(Sender: TObject);
    procedure EditValueDimExit(Sender: TObject);
    procedure EditMinExit(Sender: TObject);
    procedure EditMaxExit(Sender: TObject);
    procedure EditTestValueDimExit(Sender: TObject);
    procedure EditTestValueRawExit(Sender: TObject);
    procedure StringGridCoefsDataSelChanged(Sender: TObject);
    procedure TabItem4Click(Sender: TObject);
    procedure TabItemListValuesClick(Sender: TObject);
    procedure StringGridValuesListSelChanged(Sender: TObject);
    procedure EditFindDeviceChangeTracking(Sender: TObject);
    procedure EditFindDeviceExit(Sender: TObject);
    procedure sbClearClick(Sender: TObject);
    procedure sbFindClick(Sender: TObject);
    procedure SpeedButtonFindInternetClick(Sender: TObject);
    procedure EditCoefKExit(Sender: TObject);
    procedure EditCoefPExit(Sender: TObject);
    procedure SpeedButtonResetSettingsClick(Sender: TObject);
  private
    FCoef: TCoef;
    FCoefHash: string;
    FFilteredValues: TObjectList<TMeterValue>;
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
    FSettingsModified: Boolean;
    FModified: Boolean;
    FStabilityMeterValue: TMeterValue;
    procedure InitializeStabilityForecastTab;
    procedure BuildStabilityRuntimeUI;
    procedure InitializeStabilityState;
    procedure LoadStabilityFromMeterValue(const AIsNewMeterValue: Boolean);
    procedure SetAnalysisTimeByLastDisplayedSample;
    procedure InstallStabilitySettingsHints;
    procedure SetControlHint(const AName, AHint: string);
    function DisplayUnitName: string;
    function BaseToDisplayText(const AValue: Double): string;
    function BaseDeltaToDisplayText(const AValue: Double): string;
    function FormatBaseInfo(const AValue: Double; const AHasValue: Boolean): string;
    function FormatBaseDeltaInfo(const AValue: Double; const AHasValue: Boolean): string;
    function DisplayToBase(const AText: string): Double;
    function DisplayDeltaToBase(const AText: string): Double;
    procedure UpdateDimensionCaptions;
    function SampleSecondsToMs(const ASeconds: Double): Int64;
    function SelectedSampleIndex: Integer;
    function GetDisplayedSamples: TArray<TMeterValueSample>;
    procedure RefreshDisplayedSamples;
    procedure SetSampleSource(const ASource: TMeterValueSampleSource);
    procedure UpdateSampleSourceControls;
    procedure ComboBoxSampleSourceChange(Sender: TObject);
    procedure ButtonRefreshHistoryClick(Sender: TObject);
    procedure ButtonUseLastSampleTimeClick(Sender: TObject);
    procedure LoadSampleToEditor(const AIndex: Integer);
    procedure RefreshSamplesGrid(const AReload: Boolean = True);
    procedure UpdateSampleCommandButtons;
    procedure AddSample;
    procedure EditSelectedSample;
    procedure DeleteSelectedSample;
    procedure ClearSamples;
    procedure SortSamples;
    procedure GenerateNewSamples;
    procedure AppendGeneratedSamples;
    procedure GenerateSamples(const AClearExisting: Boolean);
    function ValidateGeneratorControls(out AErrorText: string): Boolean;
    procedure InitializeScenarioList;
    procedure ApplySelectedScenario;
    procedure ApplyScenario(const AScenario: TMeterValueTestScenario);
    procedure RefreshAllTestControls;
    procedure ClearAnalysisDisplay;
    procedure ButtonSampleAddClick(Sender: TObject);
    procedure ButtonSampleEditClick(Sender: TObject);
    procedure ButtonSampleDeleteClick(Sender: TObject);
    procedure ButtonSamplesClearClick(Sender: TObject);
    procedure ButtonAnalyzeClick(Sender: TObject);
    procedure ButtonGenerateNewClick(Sender: TObject);
    procedure ButtonGenerateAppendClick(Sender: TObject);
    procedure ButtonApplyScenarioClick(Sender: TObject);
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
    procedure SetConclusionIndicator(const ARectangle: TRectangle; const ALabel: TLabel; const AText: string; const AColor: TAlphaColor);
    procedure ResetConclusionIndicators;
    procedure UpdateConclusionIndicators(const AInfo: TMeterValueStabilityInfo);
    function FormatInfoFloat(const AValue: Double; const AHasValue: Boolean; const ADigits: Integer = 4): string;
    function TrendDirectionText(const ADirection: TMeterValueTrendDirection; const AHasTrend: Boolean): string;
    procedure UpdateDetailedConclusion(const AInfo: TMeterValueStabilityInfo);
    procedure ApplySettingsToWorkMeterValue;
    function SafeFloat(const S: string): Double;
    function SafeInt(const S: string): Integer;
    function HasActiveFilters: Boolean;
    procedure RefreshLayoutValues;
    procedure RefreshLayoutCoefs;
    procedure ApplyFilter;
    procedure UpdateGridDevices;
  public
    destructor Destroy; override;
    MeterValue: TMeterValue;
    procedure UpdateLayoutCommonSettings;
    procedure UpdateLayoutValues;
    procedure UpdateStringGridDimensions;
    procedure UpdateStringGridCoefs;
    procedure UpdateStringGridCoefsData;
    procedure UpdateLayoutTest;
    procedure UpdateLayoutValuesList;
    procedure UpdateLayoutCoefs;
  end;

var
  FormMeterValues: TFormMeterValues;

implementation

{$R *.fmx}

procedure TFormMeterValues.InitializeStabilityState;
begin
  if FTestSamples <> nil then
    Exit;
  FTestSamples := TList<TMeterValueSample>.Create;
  FSampleSource := mssWorkHistory;
  FTestCurrentTimeMs := 0;
  FTestTargetValue := 0;
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
end;

procedure TFormMeterValues.InitializeStabilityForecastTab;
var
  IsNewMeterValue: Boolean;
begin
  InitializeStabilityState;
  BuildStabilityRuntimeUI;
  IsNewMeterValue := FStabilityMeterValue <> MeterValue;
  FStabilityMeterValue := MeterValue;
  LoadStabilityFromMeterValue(IsNewMeterValue);
end;

destructor TFormMeterValues.Destroy;
begin
  FTestSamples.Free;
  FFilteredValues.Free;
  inherited;
end;

function AbsoluteError(const AValue, AArg: Double): Double;
begin
  Result := AValue - AArg;
end;

function RelativeErrorStr(const AValue, AArg: Double): string;
var
  E: Double;
begin
  if Abs(AArg) < 1E-12 then
    Exit('0');
  E := (AValue - AArg) / AArg * 100;
  Result := FloatToStr(E);
end;

function TFormMeterValues.SafeFloat(const S: string): Double;
begin
  Result := StrToFloatDef(StringReplace(StringReplace(S, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]), ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), 0);
end;

function TFormMeterValues.SafeInt(const S: string): Integer;
begin
  Result := StrToIntDef(S, 0);
end;

procedure TFormMeterValues.UpdateLayoutCommonSettings;
begin
  EditName.Text := MeterValue.Name;
  EditValueType.Text := MeterValue.&Type;
  EditShrtName.Text := MeterValue.ShrtName;
  EditDescription.Text := MeterValue.Description;
  EditHash.Text := MeterValue.Hash;

  CheckBoxIsToSave.Tag := 1;
  CheckBoxIsToSave.IsChecked := MeterValue.IsToSave;
  CheckBoxIsToSave.Tag := 0;
end;

procedure TFormMeterValues.UpdateLayoutValues;
begin
  LabelValueName.Text := MeterValue.GetStrFullName;
  EditValueFull.Text := MeterValue.GetStrValue;

  EditValue.Text := FloatToStr(MeterValue.GetDoubleValueDim);
  EditMax.Text := MeterValue.GetStrNum(MeterValue.MaxValue);
  EditMin.Text := MeterValue.GetStrNum(MeterValue.MinValue);
  EditValueDim.Text := MeterValue.GetDimName;
end;

procedure TFormMeterValues.RefreshLayoutValues;
begin
  MeterValue.&Type := EditValueType.Text;
  MeterValue.Name := EditName.Text;
  MeterValue.ShrtName := EditShrtName.Text;
  MeterValue.Description := EditDescription.Text;

  MeterValue.SetValue(EditValue.Text);
  MeterValue.MinValue := MeterValue.GetDoubleNum(EditMin.Text);
  MeterValue.MaxValue := MeterValue.GetDoubleNum(EditMax.Text);
  MeterValue.Hash := EditHash.Text;

  TMeterValue.SaveToFile(0);
end;

procedure TFormMeterValues.FormShow(Sender: TObject);
begin
  StringGridCoefsData.OnKeyDown := StringGridCoefsDataKeyDown;
  InitializeStabilityForecastTab;
  if MeterValue <> nil then
  begin
    UpdateLayoutCommonSettings;
    UpdateLayoutValues;
    UpdateStringGridDimensions;
    UpdateStringGridCoefsData;
    UpdateStringGridCoefs;
    UpdateLayoutCoefs;
    UpdateLayoutValuesList;
  end;
end;

procedure TFormMeterValues.StringGridCoefsDataKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkDelete then
  begin
    DeleteRowButtonClick(DeleteRowButton);
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure TFormMeterValues.UpdateStringGridDimensions;
var
  I: Integer;
begin
  StringGridDimensions.BeginUpdate;
  try
    StringGridDimensions.RowCount := 0;

    if MeterValue.Dimensions.Count > 0 then
    begin
      StringGridDimensions.RowCount := MeterValue.Dimensions.Count;
      for I := 0 to MeterValue.Dimensions.Count - 1 do
      begin
        StringGridDimensions.Cells[0, I] := IntToStr(I + 1);
        StringGridDimensions.Cells[1, I] := MeterValue.Dimensions[I].Name;
        StringGridDimensions.Cells[2, I] := FloatToStr(MeterValue.Dimensions[I].Rate);
        StringGridDimensions.Cells[3, I] := FloatToStr(MeterValue.Dimensions[I].Devider);
        StringGridDimensions.Cells[4, I] := BoolToStr(MeterValue.Dimensions[I].Factor, True);
        StringGridDimensions.Cells[5, I] := BoolToStr(MeterValue.Dimensions[I].Recip, True);
        StringGridDimensions.Cells[6, I] := MeterValue.Dimensions[I].Hash;
      end;
    end;

    StringGridDimensions.Row := MeterValue.CurrentDimIndex;
  finally
    StringGridDimensions.EndUpdate;
  end;
end;

procedure TFormMeterValues.UpdateStringGridCoefsData;
var
  I, Index: Integer;
  Dbl: Double;
begin
  Index := -1;
  StringGridCoefsData.Tag := 1;
  StringGridCoefsData.BeginUpdate;
  try
    StringColumnEtalon.Header := 'Эталон, ' + MeterValue.GetDimName;
    StringColumnValue.Header := 'Знач. прибора, ' + MeterValue.GetDimName;

    StringGridCoefsData.RowCount := 0;

    if MeterValue.Coefs.Count > 0 then
    begin
      StringGridCoefsData.RowCount := MeterValue.Coefs.Count;
      for I := 0 to MeterValue.Coefs.Count - 1 do
      begin
        FCoef := MeterValue.Coefs[I];

        StringGridCoefsData.Cells[0, I] := BoolToStr(FCoef.InUse, True);
        StringGridCoefsData.Cells[1, I] := FCoef.Name;
        StringGridCoefsData.Cells[2, I] := MeterValue.GetStringNum(FCoef.Value);
        StringGridCoefsData.Cells[3, I] := MeterValue.GetStringNum(FCoef.Arg);
        StringGridCoefsData.Cells[4, I] := RelativeErrorStr(FCoef.Value, FCoef.Arg);

        Dbl := AbsoluteError(FCoef.Value, FCoef.Arg);
        StringGridCoefsData.Cells[5, I] := MeterValue.GetStringNum(Dbl);
        StringGridCoefsData.Cells[6, I] := '';
        StringGridCoefsData.Cells[7, I] := FCoef.Hash;

        if SameText(FCoefHash, FCoef.Hash) then
          Index := I;
      end;
    end;
  finally
    StringGridCoefsData.EndUpdate;
  end;

  StringGridCoefsData.Tag := 1;
  StringGridCoefsData.Row := Index;
end;

procedure TFormMeterValues.UpdateStringGridCoefs;
var
  I: Integer;
begin
  StringGridCoefs.BeginUpdate;
  try
    StringGridCoefs.RowCount := 0;
    if MeterValue.Coefs.Count > 0 then
    begin
      StringGridCoefs.RowCount := MeterValue.Coefs.Count;
      for I := 0 to MeterValue.Coefs.Count - 1 do
      begin
        StringGridCoefs.Cells[0, I] := BoolToStr(MeterValue.Coefs[I].InUse, True);
        StringGridCoefs.Cells[1, I] := MeterValue.Coefs[I].Name;
        StringGridCoefs.Cells[2, I] := MeterValue.GetStringNum(MeterValue.Coefs[I].Q1);
        StringGridCoefs.Cells[3, I] := MeterValue.GetStringNum(MeterValue.Coefs[I].Q2);
        StringGridCoefs.Cells[4, I] := FloatToStr(MeterValue.Coefs[I].K);
        StringGridCoefs.Cells[5, I] := FloatToStr(MeterValue.Coefs[I].b);
        StringGridCoefs.Cells[6, I] := MeterValue.Coefs[I].Hash;
      end;
    end;
  finally
    StringGridCoefs.EndUpdate;
  end;
end;

procedure TFormMeterValues.AddRowButtonClick(Sender: TObject);
begin
  FCoefHash := MeterValue.SetCoef(0, 0);
  MeterValue.CalcCoefs;
  UpdateStringGridCoefsData;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.StringGridCoefsDataEditingDone(Sender: TObject;
  const ACol, ARow: Integer);
var
  Dbl: Double;
  Hash: string;
  Cell: string;
  C: TCoef;
begin
  if (ARow < 0) or (ARow >= MeterValue.Coefs.Count) then
    Exit;

  FCoefHash := StringGridCoefsData.Cells[7, ARow];
  C := MeterValue.Coefs[ARow];
  Cell := StringGridCoefsData.Cells[ACol, ARow];

  case ACol of
    0: C.InUse := SameText(Cell, 'True');
    1: C.Name := Cell;
    2: C.Value := MeterValue.GetDoubleNum(Cell);
    3: C.Arg := MeterValue.GetDoubleNum(Cell);
    4:
      begin
        Dbl := SafeFloat(Cell);
        C.Value := C.Arg / (1 - Dbl / 100);
      end;
    5:
      begin
        Dbl := MeterValue.GetDoubleNum(Cell);
        C.Value := C.Arg + Dbl;
      end;
    7:
      begin
        Hash := Cell;
        if not Hash.IsEmpty then
          C.Hash := Hash;
      end;
  end;

  MeterValue.Coefs[ARow] := C;
  MeterValue.CalcCoefs;

  UpdateStringGridCoefsData;
  UpdateStringGridCoefs;

  StringGridCoefsData.Tag := 2;
end;

procedure TFormMeterValues.SaveConfigButtonClick(Sender: TObject);
begin
  TMeterValue.SaveToFile(0);
end;

procedure TFormMeterValues.DeleteRowButtonClick(Sender: TObject);
begin
  if (StringGridCoefsData.Row <> -1) and
     (StringGridCoefsData.Row < MeterValue.Coefs.Count) then
    MeterValue.Coefs.Delete(StringGridCoefsData.Row);

  UpdateStringGridCoefsData;
  MeterValue.CalcCoefs;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.RefreshConfigButtonClick(Sender: TObject);
begin
  // В Delphi-версии TMeterValue нет SortCoefs, оставляем только обновление.
  UpdateStringGridCoefsData;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.LoadConfigButtonClick(Sender: TObject);
begin
  TMeterValue.LoadFromFile;
  UpdateStringGridCoefsData;
  MeterValue.CalcCoefs;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.StringGridDimensionsSelChanged(Sender: TObject);
begin
  if StringGridDimensions.Row <> -1 then
    MeterValue.SetDim(StringGridDimensions.Row);
end;

procedure TFormMeterValues.ButtonCoefsLoadClick(Sender: TObject);
begin
  TMeterValue.LoadFromFile;
end;

procedure TFormMeterValues.TabControlMeterValueSettingsChange(Sender: TObject);
begin
  case TabControlMeterValueSettings.TabIndex of
    0:
      begin
        UpdateLayoutCommonSettings;
        UpdateLayoutValues;
        UpdateLayoutCoefs;
      end;
    1:
      begin
        UpdateStringGridCoefsData;
        UpdateStringGridCoefs;
      end;
    2: UpdateStringGridDimensions;
    3: UpdateLayoutTest;
    4: InitializeStabilityForecastTab;
    5: UpdateLayoutValuesList;
  end;
end;

procedure TFormMeterValues.CheckBoxIsToSaveChange(Sender: TObject);
begin
  if CheckBoxIsToSave.Tag = 0 then
    MeterValue.SetToSave(CheckBoxIsToSave.IsChecked)
  else
    CheckBoxIsToSave.Tag := 0;
end;

procedure TFormMeterValues.EditNameExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditShrtNameExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditDescriptionExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditHashExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditValueExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditValueDimExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditMinExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditMaxExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditTestValueDimExit(Sender: TObject);
var
  Dbl: Double;
begin
  Dbl := SafeFloat(EditTestValueDim.Text);
  MeterValue.SetDimValue(Dbl);
  UpdateLayoutTest;
  EditTestValueRaw.Text := '';
  LabelTestValueWoCorrection.Text := '';
end;

procedure TFormMeterValues.EditTestValueRawExit(Sender: TObject);
var
  Dbl: Double;
begin
  Dbl := SafeFloat(EditTestValueRaw.Text);
  MeterValue.SetRawValue(Dbl);
  UpdateLayoutTest;
  EditTestValueDim.Text := '';
end;

procedure TFormMeterValues.UpdateLayoutTest;
begin
  LabelValueRaw.Text := 'Текущее значение (' + MeterValue.RawValueName + ')';
  LabelValueDim.Text := 'Приведенное значение (' + MeterValue.GetStrFullName + ')';

  LabelTestValue.Text := MeterValue.GetStringValue + ' ' + MeterValue.GetDimName(0);

  LabelTestValueWoCorrection.Text :=
    MeterValue.GetStringNum(MeterValue.ValueWoCorrection) + ' ' + MeterValue.GetDimName(0);

  LabelTestValueDim.Text := MeterValue.GetStrValue + ' ' + MeterValue.GetDimName;
end;

procedure TFormMeterValues.StringGridCoefsDataSelChanged(Sender: TObject);
var
  Row, I: Integer;
begin
  if StringGridCoefsData.Tag = 0 then
  begin
    Row := StringGridCoefsData.Row;
    if (Row >= 0) and (Row < StringGridCoefsData.RowCount) then
      FCoefHash := StringGridCoefsData.Cells[7, Row];
  end
  else if StringGridCoefsData.Tag = 2 then
  begin
    StringGridCoefsData.Tag := 1;
    for I := 0 to MeterValue.Coefs.Count - 1 do
      if SameText(MeterValue.Coefs[I].Hash, FCoefHash) then
      begin
        StringGridCoefsData.Row := I;
        Break;
      end;
  end
  else
    StringGridCoefsData.Tag := 0;
end;

procedure TFormMeterValues.TabItem4Click(Sender: TObject);
begin
  UpdateLayoutTest;
end;

procedure TFormMeterValues.ApplyFilter;
var
  Source: TObjectList<TMeterValue>;
  Item: TMeterValue;
  SearchText, SearchArea: string;
begin
  Source := TMeterValue.GetMeterValues;

  FreeAndNil(FFilteredValues);
  FFilteredValues := TObjectList<TMeterValue>.Create(False);

  if Source = nil then
    Exit;

  SearchText := Trim(LowerCase(EditFindDevice.Text));
  for Item in Source do
  begin
    if SearchText = '' then
    begin
      FFilteredValues.Add(Item);
      Continue;
    end;

    SearchArea :=
      LowerCase(Item.NameOwner + ' ' +
      Item.Description + ' ' +
      Item.GetStrFullName + ' ' +
      Item.GetStrValue + ' ' +
      Item.Hash);

    if Pos(SearchText, SearchArea) > 0 then
      FFilteredValues.Add(Item);
  end;
end;

procedure TFormMeterValues.UpdateGridDevices;
var
  I, Col, Index: Integer;
  Item: TMeterValue;
begin
  Index := -1;
  StringGridValuesList.BeginUpdate;
  try
    StringGridValuesList.Tag := 1;
    if FFilteredValues <> nil then
      StringGridValuesList.RowCount := FFilteredValues.Count
    else
      StringGridValuesList.RowCount := 0;

    for I := 0 to StringGridValuesList.RowCount - 1 do
    begin
      Item := FFilteredValues[I];
      Col := 0;
      StringGridValuesList.Cells[Col, I] := IntToStr(I); Inc(Col);
      StringGridValuesList.Cells[Col, I] := Item.NameOwner; Inc(Col);
      StringGridValuesList.Cells[Col, I] := Item.Description; Inc(Col);
      StringGridValuesList.Cells[Col, I] := Item.GetStrFullName; Inc(Col);
      StringGridValuesList.Cells[Col, I] := Item.GetStrValue; Inc(Col);
      StringGridValuesList.Cells[Col, I] := Item.Hash; Inc(Col);

      if Item.ValueRate <> nil then
      begin
        StringGridValuesList.Cells[Col, I] := Item.ValueRate.GetStrFullName; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueRate.GetStrValue; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueRate.Hash; Inc(Col);
      end;

      if Item.ValueBaseMultiplier <> nil then
      begin
        StringGridValuesList.Cells[Col, I] := Item.ValueBaseMultiplier.GetStrFullName; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueBaseMultiplier.GetStrValue; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueBaseMultiplier.Hash; Inc(Col);
      end;

      if Item.ValueBaseDevider <> nil then
      begin
        StringGridValuesList.Cells[Col, I] := Item.ValueBaseDevider.GetStrFullName; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueBaseDevider.GetStrValue; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueBaseDevider.Hash; Inc(Col);
      end;

      if Item.ValueCorrection <> nil then
      begin
        StringGridValuesList.Cells[Col, I] := Item.ValueCorrection.GetStrFullName; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueCorrection.GetStrValue; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueCorrection.Hash; Inc(Col);
      end;

      if Item.ValueEtalon <> nil then
      begin
        StringGridValuesList.Cells[Col, I] := Item.ValueEtalon.GetStrFullName; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueEtalon.GetStrValue; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.ValueEtalon.Hash; Inc(Col);
      end;

      if (MeterValue <> nil) and (Item.Hash = MeterValue.Hash) then
        Index := I;
    end;

    if (Index >= 0) and (StringGridValuesList.RowCount > 0) then
      StringGridValuesList.Row := Index
    else if StringGridValuesList.RowCount > 0 then
      StringGridValuesList.Row := 0;

    sbFind.IsPressed := HasActiveFilters;
    StringGridValuesList.Tag := 0;
  finally
    StringGridValuesList.EndUpdate;
  end;
end;

function TFormMeterValues.HasActiveFilters: Boolean;
begin
  Result := Trim(EditFindDevice.Text) <> '';
end;

procedure TFormMeterValues.UpdateLayoutValuesList;
begin
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormMeterValues.TabItemListValuesClick(Sender: TObject);
begin
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormMeterValues.StringGridValuesListSelChanged(Sender: TObject);
begin
  if StringGridValuesList.Tag = 0 then
  begin
    if (FFilteredValues <> nil) and (StringGridValuesList.Row >= 0) and
       (StringGridValuesList.Row < FFilteredValues.Count) then
      MeterValue := FFilteredValues[StringGridValuesList.Row];
  end;

  UpdateLayoutValues;
  UpdateStringGridCoefs;
  UpdateStringGridCoefsData;
end;

procedure TFormMeterValues.EditFindDeviceChangeTracking(Sender: TObject);
begin
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormMeterValues.EditFindDeviceExit(Sender: TObject);
begin
  EditFindDeviceChangeTracking(Sender);
end;

procedure TFormMeterValues.sbClearClick(Sender: TObject);
begin
  EditFindDevice.Text := '';
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormMeterValues.sbFindClick(Sender: TObject);
begin
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormMeterValues.SpeedButtonFindInternetClick(Sender: TObject);
begin
  sbFindClick(Sender);
end;

procedure TFormMeterValues.UpdateLayoutCoefs;
begin
  if MeterValue.ValueRate <> nil then
  begin
    EditNameValueRate.Text := MeterValue.ValueRate.GetStrFullName;
    EditValueRate.Text := MeterValue.ValueRate.GetStrValue;
  end
  else
  begin
    EditNameValueRate.Text := '-';
    EditValueRate.Text := '-';
  end;

  if MeterValue.ValueBaseMultiplier <> nil then
  begin
    EditNameValueMultiplier.Text := MeterValue.ValueBaseMultiplier.GetStrFullName;
    EditValueMultiplier.Text := MeterValue.ValueBaseMultiplier.GetStrValue;
  end
  else
  begin
    EditNameValueMultiplier.Text := '-';
    EditValueMultiplier.Text := '-';
  end;

  if MeterValue.ValueBaseDevider <> nil then
  begin
    EditNameValueDevider.Text := MeterValue.ValueBaseDevider.GetStrFullName;
    EditValueDevider.Text := MeterValue.ValueBaseDevider.GetStrValue;
  end
  else
  begin
    EditNameValueDevider.Text := '-';
    EditValueDevider.Text := '-';
  end;

  EditCoefK.Text := FloatToStr(MeterValue.CoefK);
  EditCoefP.Text := FloatToStr(MeterValue.CoefP);
end;

procedure TFormMeterValues.RefreshLayoutCoefs;
var
  Dbl: Double;
begin
  Dbl := SafeFloat(EditCoefK.Text);
  MeterValue.CoefK := Dbl;

  Dbl := SafeFloat(EditCoefP.Text);
  MeterValue.CoefP := Dbl;
end;

procedure TFormMeterValues.SpeedButtonResetSettingsClick(Sender: TObject);
begin
  if MeterValue = nil then
    Exit;

  if SameText(MeterValue.&Type, 'Время') then
    MeterValue.SetAsTime
  else if SameText(MeterValue.&Type, 'Объем') then
    MeterValue.SetAsVolume
  else if SameText(MeterValue.&Type, 'Масса') then
    MeterValue.SetAsMass
  else if SameText(MeterValue.&Type, 'Объемный расход') then
    MeterValue.SetAsVolumeFlow
  else if SameText(MeterValue.&Type, 'Массовый расход') then
    MeterValue.SetAsMassFlow
  else if SameText(MeterValue.&Type, 'Импульсы') then
    MeterValue.SetAsImp
  else if SameText(MeterValue.&Type, 'Погрешность') then
    MeterValue.SetAsError
  else if SameText(MeterValue.&Type, 'Погрешность по массе') then
    MeterValue.SetAsMassError
  else if SameText(MeterValue.&Type, 'Погрешность по объему') then
    MeterValue.SetAsVolumeError
  else if SameText(MeterValue.&Type, 'Расчётная плотность') then
    MeterValue.SetAsDensity
  else if SameText(MeterValue.&Type, 'PT100') then
    MeterValue.SetAsTempPT100
  else if SameText(MeterValue.&Type, 'Температурный датчик') then
    MeterValue.SetAsTemp
  else if SameText(MeterValue.&Type, 'Датчик температуры ИВТМ') then
    MeterValue.SetAsAirTemp
  else if SameText(MeterValue.&Type, 'Датчик токовый') then
    MeterValue.SetAsPressure
  else if SameText(MeterValue.&Type, 'Давление атмосферное') then
    MeterValue.SetAsAirPressure
  else if SameText(MeterValue.&Type, 'Токовый вход') then
    MeterValue.SetAsCurrent
  else if SameText(MeterValue.&Type, 'Коэффициент массы') then
    MeterValue.SetAsMassCoef
  else if SameText(MeterValue.&Type, 'Коэффициент объема') then
    MeterValue.SetAsVolumeCoef
  else if SameText(MeterValue.&Type, 'Датчик влажности') then
    MeterValue.SetAsHumidity
  else if SameText(MeterValue.Name, 'Температура') and SameText(MeterValue.RawValueName, 'Сопротивление') then
    MeterValue.SetAsTempPT100
  else if SameText(MeterValue.Name, 'Температура') then
    MeterValue.SetAsTemp
  else if SameText(MeterValue.Name, 'Температура атм') then
    MeterValue.SetAsAirTemp
  else if SameText(MeterValue.Name, 'Давление') then
    MeterValue.SetAsPressure
  else if SameText(MeterValue.Name, 'Плотность') then
    MeterValue.SetAsDensity
  else if SameText(MeterValue.Name, 'Влажность') then
    MeterValue.SetAsHumidity;

  UpdateLayoutCommonSettings;
  UpdateLayoutValues;
  UpdateStringGridDimensions;
  UpdateLayoutTest;
  UpdateLayoutCoefs;
end;

procedure TFormMeterValues.EditCoefKExit(Sender: TObject);
begin
  RefreshLayoutCoefs;
end;

procedure TFormMeterValues.EditCoefPExit(Sender: TObject);
begin
  RefreshLayoutCoefs;
end;

procedure TFormMeterValues.BuildStabilityRuntimeUI;
begin
  if ComboBoxSampleSource <> nil then
    Exit;

  ComboBoxSampleSource := TComboBox.Create(Self);
  ComboBoxSampleSource.Parent := GroupAnalysis;
  ComboBoxSampleSource.Position.X := 214;
  ComboBoxSampleSource.Position.Y := 32;
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
    Position.Y := 8;
    Size.Width := 190;
    Size.Height := 22;
    Text := 'Источник данных';
  end;

  GroupAnalysis.Height := 220;
  ButtonRefreshHistory := TButton.Create(Self);
  ButtonRefreshHistory.Parent := GroupAnalysis;
  ButtonRefreshHistory.Position.X := 12;
  ButtonRefreshHistory.Position.Y := 180;
  ButtonRefreshHistory.Size.Width := 160;
  ButtonRefreshHistory.Size.Height := 28;
  ButtonRefreshHistory.Text := 'Обновить историю';
  ButtonRefreshHistory.OnClick := ButtonRefreshHistoryClick;

  ButtonUseLastSampleTime := TButton.Create(Self);
  ButtonUseLastSampleTime.Parent := GroupAnalysis;
  ButtonUseLastSampleTime.Position.X := 188;
  ButtonUseLastSampleTime.Position.Y := 180;
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
  InstallStabilitySettingsHints;
  RefreshSamplesGrid;
  ClearAnalysisDisplay;
end;

procedure TFormMeterValues.LoadStabilityFromMeterValue(const AIsNewMeterValue: Boolean);
begin
  if MeterValue = nil then
    Exit;
  FLoading := True;
  try
    FTestTargetValue := MeterValue.Value;
    CopySettingsFromWorkMeterValue;
    LoadSettingsToControls;
    if AIsNewMeterValue then
      FSampleSource := mssWorkHistory;
    if ComboBoxSampleSource <> nil then
      ComboBoxSampleSource.ItemIndex := Ord(FSampleSource);
    UpdateSampleSourceControls;
    RefreshDisplayedSamples;
    if AIsNewMeterValue and (Length(FDisplayedSamples) > 0) then
      SetAnalysisTimeByLastDisplayedSample;
  finally
    FLoading := False;
  end;
  Analyze;
end;
function TFormMeterValues.DisplayUnitName: string;
begin
  Result := '';
  if MeterValue <> nil then
    Result := MeterValue.GetDimName;
end;

function TFormMeterValues.BaseToDisplayText(const AValue: Double): string;
begin
  if MeterValue <> nil then
    Result := MeterValue.FormatBaseValue(AValue)
  else
    Result := FloatToStr(AValue);
end;

function TFormMeterValues.BaseDeltaToDisplayText(const AValue: Double): string;
begin
  if MeterValue <> nil then
    Result := MeterValue.FormatBaseDeltaValue(AValue)
  else
    Result := FloatToStr(AValue);
end;


function TFormMeterValues.FormatBaseInfo(const AValue: Double;
  const AHasValue: Boolean): string;
begin
  if not AHasValue then
    Exit('—');
  Result := BaseToDisplayText(AValue);
end;

function TFormMeterValues.FormatBaseDeltaInfo(const AValue: Double;
  const AHasValue: Boolean): string;
begin
  if not AHasValue then
    Exit('—');
  Result := BaseDeltaToDisplayText(AValue);
end;

function TFormMeterValues.DisplayToBase(const AText: string): Double;
begin
  if MeterValue <> nil then
    Result := MeterValue.DisplayToBaseValue(SafeFloat(AText))
  else
    Result := SafeFloat(AText);
end;

function TFormMeterValues.DisplayDeltaToBase(const AText: string): Double;
begin
  if MeterValue <> nil then
    Result := MeterValue.DisplayDeltaToBaseValue(SafeFloat(AText))
  else
    Result := SafeFloat(AText);
end;

procedure TFormMeterValues.UpdateDimensionCaptions;
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

function TFormMeterValues.GetDisplayedSamples: TArray<TMeterValueSample>;
begin
  case FSampleSource of
    mssWorkHistory:
      if MeterValue <> nil then
        Result := MeterValue.GetStabilitySamples
      else
        SetLength(Result, 0);
  else
    Result := FTestSamples.ToArray;
  end;
end;

procedure TFormMeterValues.RefreshDisplayedSamples;
begin
  FDisplayedSamples := GetDisplayedSamples;
end;

procedure TFormMeterValues.SetAnalysisTimeByLastDisplayedSample;
begin
  if Length(FDisplayedSamples) = 0 then
    Exit;
  FTestCurrentTimeMs := FDisplayedSamples[High(FDisplayedSamples)].TimeStampMs;
  EditAnalysisTime.Text := FloatToStr(FTestCurrentTimeMs / 1000.0);
end;

procedure TFormMeterValues.SetSampleSource(const ASource: TMeterValueSampleSource);
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

procedure TFormMeterValues.UpdateSampleSourceControls;
var
  IsTestMode: Boolean;
  ScenarioGroup: TControl;
  GeneratorGroup: TControl;
begin
  IsTestMode := FSampleSource = mssTestSamples;
  EditSampleTime.Enabled := True;
  EditSampleValue.Enabled := True;
  EditSampleTimeStep.Enabled := True;
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
  EditAnalysisTime.Enabled := True;
  if ButtonRefreshHistory <> nil then
    ButtonRefreshHistory.Enabled := not IsTestMode;
  if ButtonUseLastSampleTime <> nil then
    ButtonUseLastSampleTime.Enabled := True;
  UpdateSampleCommandButtons;
  ScenarioGroup := FindComponent('GroupStabilityScenario') as TControl;
  if ScenarioGroup <> nil then
    ScenarioGroup.Visible := IsTestMode;
  GeneratorGroup := FindComponent('GroupSamplesGenerator') as TControl;
  if GeneratorGroup <> nil then
    GeneratorGroup.Visible := IsTestMode;
end;

procedure TFormMeterValues.ComboBoxSampleSourceChange(Sender: TObject);
begin
  if FLoading then
    Exit;
  if ComboBoxSampleSource.ItemIndex = Ord(mssTestSamples) then
    SetSampleSource(mssTestSamples)
  else
    SetSampleSource(mssWorkHistory);
end;

procedure TFormMeterValues.ButtonRefreshHistoryClick(Sender: TObject);
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

  if MeterValue <> nil then
    BeforeSamples := MeterValue.GetStabilitySamples
  else
    SetLength(BeforeSamples, 0);

  Analyze;

  if MeterValue <> nil then
    AfterSamples := MeterValue.GetStabilitySamples
  else
    SetLength(AfterSamples, 0);

  DebugLog(Format('ButtonRefreshHistory: before count=%d %s; after count=%d %s',
    [Length(BeforeSamples), BoundaryText(BeforeSamples), Length(AfterSamples),
     BoundaryText(AfterSamples)]));
end;

procedure TFormMeterValues.ButtonUseLastSampleTimeClick(Sender: TObject);
begin
  SetAnalysisTimeByLastDisplayedSample;
  Analyze;
end;

procedure TFormMeterValues.SetControlHint(const AName, AHint: string);
var
  Obj: TFmxObject;
begin
  Obj := FindComponent(AName) as TFmxObject;
  if Obj is TControl then
  begin
    TControl(Obj).Hint := AHint;
    TControl(Obj).ShowHint := True;
  end;
end;

procedure TFormMeterValues.InstallStabilitySettingsHints;
begin
  SetControlHint('CheckBoxStabilityEnabled', 'Включает расчёт стабильности и прогноза для этой метрологической величины. Если выключено, анализ не участвует в заключении.');
  SetControlHint('LabelMinSampleCount', 'Минимальное число точек в окне анализа, необходимое для расчёта стабильности. Если точек меньше, результат считается недостаточным для анализа.');
  SetControlHint('EditMinSampleCount', (FindComponent('LabelMinSampleCount') as TControl).Hint);
  SetControlHint('LabelWindowDurationSec', 'Длительность окна анализа в секундах. Большее значение сглаживает случайный шум, но медленнее реагирует на изменения сигнала.');
  SetControlHint('EditWindowDurationSec', (FindComponent('LabelWindowDurationSec') as TControl).Hint);
  SetControlHint('LabelMaxSampleAgeSec', 'Максимально допустимое время в секундах с момента последней точки до текущего времени анализа. Если последняя точка старше, данные считаются устаревшими.');
  SetControlHint('EditMaxSampleAgeSec', (FindComponent('LabelMaxSampleAgeSec') as TControl).Hint);
  SetControlHint('LabelConfirmationTimeSec', 'Время подтверждения в секундах: сколько сигнал должен непрерывно удовлетворять условиям стабильности. Малое значение подтверждает быстрее, большое снижает риск ложного подтверждения.');
  SetControlHint('EditConfirmationTimeSec', (FindComponent('LabelConfirmationTimeSec') as TControl).Hint);
  SetControlHint('LabelExitThresholdFactor', 'Коэффициент расширения порогов после подтверждения. Большее значение добавляет гистерезис и реже сбрасывает подтверждённую стабильность.');
  SetControlHint('EditExitThresholdFactor', (FindComponent('LabelExitThresholdFactor') as TControl).Hint);
  SetControlHint('LabelMaxVariation', 'Предельный размах значений в окне в единицах величины. Малое значение требует почти неизменного сигнала, большое допускает больший разброс.');
  SetControlHint('EditMaxVariation', (FindComponent('LabelMaxVariation') as TControl).Hint);
  SetControlHint('LabelMaxStdDeviation', 'Предельное стандартное отклонение в единицах величины. Малое значение жёстко ограничивает шум, большое допускает более шумный сигнал.');
  SetControlHint('EditMaxStdDeviation', (FindComponent('LabelMaxStdDeviation') as TControl).Hint);
  SetControlHint('LabelMaxTrendRate', 'Предельная допустимая скорость изменения сигнала в единицах величины в секунду. Если модуль тренда выше этого порога, сигнал считается нестабильным.');
  SetControlHint('EditMaxTrendRate', (FindComponent('LabelMaxTrendRate') as TControl).Hint);
  SetControlHint('LabelMaxOutlierFractionPercent', 'Максимальная доля выбросов в процентах от числа точек окна. Малое значение допускает мало выбросов, большое менее строго к одиночным ошибкам.');
  SetControlHint('EditMaxOutlierFractionPercent', (FindComponent('LabelMaxOutlierFractionPercent') as TControl).Hint);
  SetControlHint('LabelOutlierFactor', 'Порог чувствительности обнаружения выбросов. Используется в алгоритме MAD. Чем меньше значение, тем больше точек будет считаться выбросами.');
  SetControlHint('EditOutlierFactor', (FindComponent('LabelOutlierFactor') as TControl).Hint);
  SetControlHint('LabelForecastHorizonSec', 'Горизонт прогноза в секундах от текущего времени анализа. Большое значение проверяет более дальний прогноз и сильнее зависит от тренда.');
  SetControlHint('EditForecastHorizonSec', (FindComponent('LabelForecastHorizonSec') as TControl).Hint);
  SetControlHint('LabelTestTargetValue', 'Целевое значение в текущих единицах отображения. От него рассчитываются верхняя и нижняя границы допустимого диапазона.');
  SetControlHint('EditTestTargetValue', (FindComponent('LabelTestTargetValue') as TControl).Hint);
  SetControlHint('LabelTargetAccuracyPlusPercent', 'Допуск вверх в процентах от целевого значения. Большее значение расширяет верхнюю допустимую границу.');
  SetControlHint('EditTargetAccuracyPlusPercent', (FindComponent('LabelTargetAccuracyPlusPercent') as TControl).Hint);
  SetControlHint('LabelTargetAccuracyMinusPercent', 'Допуск вниз в процентах от целевого значения. Большее значение расширяет нижнюю допустимую границу.');
  SetControlHint('EditTargetAccuracyMinusPercent', (FindComponent('LabelTargetAccuracyMinusPercent') as TControl).Hint);
  SetControlHint('LabelTargetToleranceAbsolute', 'Минимальный абсолютный допуск в единицах величины. Используется как нижняя граница допуска, когда процентный допуск слишком мал.');
  SetControlHint('EditTargetToleranceAbsolute', (FindComponent('LabelTargetToleranceAbsolute') as TControl).Hint);
  SetControlHint('CheckBoxRequireCurrentValueInRange', 'Требовать, чтобы текущее значение было в целевом диапазоне. Если выключено, этот признак не блокирует итоговую пригодность.');
  SetControlHint('CheckBoxRequireMeanValueInRange', 'Требовать, чтобы среднее значение в окне было в целевом диапазоне. Полезно для устойчивости к одиночным выбросам.');
  SetControlHint('CheckBoxRequireForecastInRange', 'Требовать, чтобы прогноз на заданный горизонт был в целевом диапазоне. Учитывает тренд и предупреждает о будущем выходе за границы.');
end;

function TFormMeterValues.SampleSecondsToMs(const ASeconds: Double): Int64;
begin
  Result := Round(ASeconds * 1000);
end;

function TFormMeterValues.SelectedSampleIndex: Integer;
begin
  Result := -1;
  if (GridSamples <> nil) and (GridSamples.Row >= 0) and
     (GridSamples.Row < Length(FDisplayedSamples)) then
    Result := GridSamples.Row;
end;

procedure TFormMeterValues.LoadSampleToEditor(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= Length(FDisplayedSamples)) then
  begin
    EditSampleTime.Text := '';
    EditSampleValue.Text := '';
    Exit;
  end;

  if Length(FDisplayedSamples) > 0 then
    EditSampleTime.Text := FloatToStr((FDisplayedSamples[AIndex].TimeStampMs - FDisplayedSamples[0].TimeStampMs) / 1000.0)
  else
    EditSampleTime.Text := '0';
  EditSampleValue.Text := BaseToDisplayText(FDisplayedSamples[AIndex].Value);
end;

procedure TFormMeterValues.RefreshSamplesGrid(const AReload: Boolean);
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
  if GridSamples.Row >= 0 then
    LoadSampleToEditor(GridSamples.Row)
  else
    LoadSampleToEditor(-1);
  UpdateSampleCommandButtons;
  GridSamples.Repaint;
end;

procedure TFormMeterValues.UpdateSampleCommandButtons;
var
  HasSelection: Boolean;
  HasSamples: Boolean;
begin
  HasSamples := Length(FDisplayedSamples) > 0;
  HasSelection := (GridSamples <> nil) and (GridSamples.Row >= 0) and
    (GridSamples.Row < Length(FDisplayedSamples));
  ButtonSampleAdd.Enabled := MeterValue <> nil;
  ButtonSampleEdit.Enabled := HasSelection;
  ButtonSampleDelete.Enabled := HasSelection;
  ButtonSamplesClear.Enabled := HasSamples;
end;

procedure TFormMeterValues.SortSamples;
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

procedure TFormMeterValues.AddSample;
var
  I: Integer;
  Sample: TMeterValueSample;
  StepSec: Double;
begin
  Sample.Value := DisplayToBase(EditSampleValue.Text);
  if FSampleSource = mssWorkHistory then
  begin
    if MeterValue = nil then
      Exit;
    if Length(FDisplayedSamples) > 0 then
      Sample.TimeStampMs := FDisplayedSamples[0].TimeStampMs + SampleSecondsToMs(SafeFloat(EditSampleTime.Text))
    else
      Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(EditSampleTime.Text));
    if MeterValue.ManualAddStabilitySample(Sample.TimeStampMs, Sample.Value) then
    begin
      RefreshSamplesGrid;
      AnalyzeIfNeeded;
    end;
    Exit;
  end;

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

procedure TFormMeterValues.EditSelectedSample;
var
  Index: Integer;
  I: Integer;
  Sample: TMeterValueSample;
begin
  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

  if FSampleSource = mssWorkHistory then
  begin
    if MeterValue = nil then
      Exit;
    Sample := FDisplayedSamples[Index];
    Sample.Value := DisplayToBase(EditSampleValue.Text);
    if MeterValue.ManualSetStabilitySample(Index, Sample.TimeStampMs, Sample.Value) then
    begin
      RefreshSamplesGrid;
      GridSamples.Row := Index;
      GridSamples.Selected := Index;
      LoadSampleToEditor(Index);
      FModified := True;
      AnalyzeIfNeeded;
    end;
    Exit;
  end;

  if Length(FDisplayedSamples) > 0 then
    Sample.TimeStampMs := FDisplayedSamples[0].TimeStampMs + SampleSecondsToMs(SafeFloat(EditSampleTime.Text))
  else
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

procedure TFormMeterValues.DeleteSelectedSample;
var
  Index: Integer;
begin
  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

  if FSampleSource = mssWorkHistory then
  begin
    if (MeterValue <> nil) and MeterValue.ManualDeleteStabilitySample(Index) then
    begin
      RefreshSamplesGrid;
      if GridSamples.Row >= 0 then
        LoadSampleToEditor(GridSamples.Row)
      else
        LoadSampleToEditor(-1);
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

procedure TFormMeterValues.SetConclusionIndicator(const ARectangle: TRectangle;
  const ALabel: TLabel; const AText: string; const AColor: TAlphaColor);
begin
  if ARectangle <> nil then
    ARectangle.Fill.Color := AColor;
  if ALabel <> nil then
    ALabel.Text := AText;
end;

procedure TFormMeterValues.ResetConclusionIndicators;
begin
  SetConclusionIndicator(RectangleSignalStable, LabelSignalStableValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleStabilityConfirmed, LabelStabilityConfirmedValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleCurrentInRange, LabelCurrentInRangeValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleMeanInRange, LabelMeanInRangeValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleForecastInRange, LabelForecastInRangeValue, '—', COLOR_NONE);
  SetConclusionIndicator(RectangleSuitable, LabelSuitableValue, '—', COLOR_NONE);
end;

procedure TFormMeterValues.UpdateConclusionIndicators(const AInfo: TMeterValueStabilityInfo);
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

procedure TFormMeterValues.ClearAnalysisDisplay;
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

procedure TFormMeterValues.ClearSamples;
begin
  if FSampleSource = mssWorkHistory then
  begin
    if (MeterValue = nil) or (MessageDlg('Очистить рабочую историю значений?', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes) then
      Exit;
    MeterValue.ManualClearStabilitySamples;
    GridSamples.Row := -1;
    GridSamples.Selected := -1;
    RefreshSamplesGrid;
    LoadSampleToEditor(-1);
    ClearTestAnalysis;
    AnalyzeIfNeeded;
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

function TFormMeterValues.ValidateGeneratorControls(out AErrorText: string): Boolean;
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

procedure TFormMeterValues.GenerateSamples(const AClearExisting: Boolean);
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

procedure TFormMeterValues.GenerateNewSamples;
begin
  GenerateSamples(True);
end;

procedure TFormMeterValues.AppendGeneratedSamples;
begin
  GenerateSamples(False);
end;

procedure TFormMeterValues.InitializeScenarioList;
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

procedure TFormMeterValues.RefreshAllTestControls;
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

procedure TFormMeterValues.ApplySelectedScenario;
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

procedure TFormMeterValues.ApplyScenario(const AScenario: TMeterValueTestScenario);

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

procedure TFormMeterValues.ButtonSampleAddClick(Sender: TObject);
begin
  AddSample;
end;

procedure TFormMeterValues.ButtonSampleEditClick(Sender: TObject);
begin
  EditSelectedSample;
end;

procedure TFormMeterValues.ButtonSampleDeleteClick(Sender: TObject);
begin
  DeleteSelectedSample;
end;

procedure TFormMeterValues.ButtonSamplesClearClick(Sender: TObject);
begin
  ClearSamples;
end;

procedure TFormMeterValues.ButtonAnalyzeClick(Sender: TObject);
begin
  Analyze;
end;

procedure TFormMeterValues.ButtonGenerateNewClick(Sender: TObject);
begin
  GenerateNewSamples;
end;

procedure TFormMeterValues.ButtonGenerateAppendClick(Sender: TObject);
begin
  AppendGeneratedSamples;
end;

procedure TFormMeterValues.ButtonApplyScenarioClick(Sender: TObject);
begin
  ApplySelectedScenario;
end;

procedure TFormMeterValues.GridSamplesCellDblClick(const Column: TColumn;
  const Row: Integer);
begin
  if (Row >= 0) and (Row < Length(FDisplayedSamples)) then
  begin
    GridSamples.Row := Row;
    GridSamples.Selected := Row;
    LoadSampleToEditor(Row);
  end;
end;


procedure TFormMeterValues.GridSamplesGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  AResult: TMeterValueSampleAnalysis;
begin
  if (ARow < 0) or (ARow >= Length(FDisplayedSamples)) then
    Exit;

  case ACol of
    0: Value := IntToStr(ARow + 1);
    1: if Length(FDisplayedSamples) > 0 then
         Value := FloatToStr((FDisplayedSamples[ARow].TimeStampMs - FDisplayedSamples[0].TimeStampMs) / 1000.0)
       else
         Value := '0';
    2: Value := IntToStr(FDisplayedSamples[ARow].TimeStampMs);
    3: Value := BaseToDisplayText(FDisplayedSamples[ARow].Value);
    4: if FindSampleAnalysis(ARow, AResult) then Value := BoolText(AResult.InWindow) else Value := '';
    5: if FindSampleAnalysis(ARow, AResult) then Value := BoolText(AResult.IsOutlier) else Value := '';
    6: if FindSampleAnalysis(ARow, AResult) then Value := BoolText(AResult.IsInRange) else Value := '';
  end;
end;

procedure TFormMeterValues.GridSamplesSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
var
  I: Integer;
  Sample: TMeterValueSample;
begin
  if (ARow < 0) or (ARow >= Length(FDisplayedSamples)) then
    Exit;

  if FSampleSource = mssWorkHistory then
  begin
    if (ACol <> 3) or (MeterValue = nil) then
      Exit;
    Sample := FDisplayedSamples[ARow];
    Sample.Value := DisplayToBase(Value.ToString);
    if MeterValue.ManualSetStabilitySample(ARow, Sample.TimeStampMs, Sample.Value) then
    begin
      RefreshSamplesGrid;
      GridSamples.Row := ARow;
      GridSamples.Selected := ARow;
      LoadSampleToEditor(ARow);
      FModified := True;
      AnalyzeIfNeeded;
    end;
    Exit;
  end;

  if (ARow < 0) or (ARow >= FTestSamples.Count) then
    Exit;

  if not (ACol in [1, 3]) then
    Exit;

  Sample := FTestSamples[ARow];
  case ACol of
    1: if Length(FDisplayedSamples) > 0 then
         Sample.TimeStampMs := FDisplayedSamples[0].TimeStampMs + SampleSecondsToMs(SafeFloat(Value.ToString))
       else
         Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(Value.ToString));
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

procedure TFormMeterValues.GridSamplesSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
  LoadSampleToEditor(ARow);
  UpdateSampleCommandButtons;
end;

procedure TFormMeterValues.EditAnalysisTimeExit(Sender: TObject);
begin
  FTestCurrentTimeMs := SampleSecondsToMs(SafeFloat(EditAnalysisTime.Text));
  AnalyzeIfNeeded;
end;




procedure TFormMeterValues.UpdateTargetLimits;
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

procedure TFormMeterValues.HandleTargetRangeChange(Sender: TObject);
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

procedure TFormMeterValues.ClearTestAnalysis;
begin
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
  FTestStableCandidateSinceMs := 0;
  FTestStabilityConfirmed := False;
  ClearAnalysisDisplay;
  RefreshSamplesGrid;
end;

function TFormMeterValues.BoolText(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function TFormMeterValues.FindSampleAnalysis(const ARow: Integer;
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

procedure TFormMeterValues.AnalyzeIfNeeded;
begin
  if FLoading then
    Exit;

  if CheckBoxAutoAnalyze.IsChecked then
    Analyze
  else
    ClearTestAnalysis;
end;

procedure TFormMeterValues.HandleAutoAnalyzeChange(Sender: TObject);
begin
  if (not FLoading) and CheckBoxAutoAnalyze.IsChecked then
    Analyze;
end;

procedure TFormMeterValues.Analyze;
var
  ErrorText: string;
  Settings: TMeterValueStabilitySettings;
  Samples: TArray<TMeterValueSample>;
  LowerLimit: Double;
  UpperLimit: Double;
  I: Integer;
begin
  if MeterValue = nil then
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


function TFormMeterValues.FormatInfoFloat(const AValue: Double;
  const AHasValue: Boolean; const ADigits: Integer): string;
begin
  if not AHasValue then
    Exit('—');
  Result := FormatFloatN(AValue, ADigits);
end;

function TFormMeterValues.TrendDirectionText(
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

procedure TFormMeterValues.DisplayAnalysis(const AInfo: TMeterValueStabilityInfo);
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


procedure TFormMeterValues.UpdateDetailedConclusion(const AInfo: TMeterValueStabilityInfo);
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

procedure TFormMeterValues.ApplySettingsToWorkMeterValue;
var
  ErrorText: string;
  Settings: TMeterValueStabilitySettings;
begin
  if MeterValue = nil then
    Exit;

  if not ValidateControls(ErrorText) then
  begin
    ShowMessage('Настройки стабильности не применены.' + sLineBreak + ErrorText);
    Exit;
  end;

  ReadSettingsFromControls(Settings);
  MeterValue.StabilitySettings := Settings;
  CopySettingsFromWorkMeterValue;
  LoadSettingsToControls;
  FModified := FTestDataModified;
end;

procedure TFormMeterValues.ButtonApplyStabilitySettingsClick(Sender: TObject);
begin
  ApplySettingsToWorkMeterValue;
end;

procedure TFormMeterValues.CopySettingsFromWorkMeterValue;
begin
  FillChar(FTestSettings, SizeOf(FTestSettings), 0);
  if MeterValue <> nil then
    FTestSettings := MeterValue.StabilitySettings;
  FSettingsModified := False;
end;

procedure TFormMeterValues.LoadSettingsToControls;
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

function TFormMeterValues.TryReadFloat(const AText: string;
  out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(StringReplace(StringReplace(Trim(AText), '.', FormatSettings.DecimalSeparator,
    [rfReplaceAll]), ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), AValue) and (not IsNan(AValue)) and (not IsInfinite(AValue));
end;

function TFormMeterValues.TryReadInteger(const AText: string;
  out AValue: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(AText), AValue);
end;

procedure TFormMeterValues.ReadSettingsFromControls(
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

function TFormMeterValues.ValidateControls(out AErrorText: string): Boolean;
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

procedure TFormMeterValues.HandleSettingsChange(Sender: TObject);
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


end.
