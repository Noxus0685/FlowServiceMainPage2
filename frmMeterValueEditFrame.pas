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
  uMeterValue;

type
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
    MemoConclusion: TMemo;
    GridSamples: TGrid;
    EditSampleTime: TEdit;
    EditSampleValue: TEdit;
    EditSampleTimeStep: TEdit;
    EditAnalysisTime: TEdit;
    ButtonSampleAdd: TButton;
    ButtonSampleEdit: TButton;
    ButtonSampleDelete: TButton;
    ButtonSamplesClear: TButton;
    ButtonAnalyze: TButton;
    CheckBoxAutoAnalyze: TCheckBox;
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
    FTestCurrentTimeMs: Int64;
    FTestDataModified: Boolean;
    FTestTargetValue: Double;
    FTestSettings: TMeterValueStabilitySettings;
    FLastTestAnalysis: TMeterValueStabilityInfo;
    FTestStableCandidateSinceMs: Int64;
    FTestStabilityConfirmed: Boolean;
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
    procedure LoadSampleToEditor(const AIndex: Integer);
    procedure RefreshSamplesGrid;
    procedure AddSample;
    procedure EditSelectedSample;
    procedure DeleteSelectedSample;
    procedure ClearSamples;
    procedure SortSamples;
    procedure ClearAnalysisDisplay;
    procedure ButtonSampleAddClick(Sender: TObject);
    procedure ButtonSampleEditClick(Sender: TObject);
    procedure ButtonSampleDeleteClick(Sender: TObject);
    procedure ButtonSamplesClearClick(Sender: TObject);
    procedure ButtonAnalyzeClick(Sender: TObject);
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
  FTestDataModified := False;
  FTestTargetValue := 0;
  FSettingsModified := False;
  FModified := False;
  FillChar(FTestSettings, SizeOf(FTestSettings), 0);
  FLastTestAnalysis := Default(TMeterValueStabilityInfo);
  FTestStableCandidateSinceMs := 0;
  FTestStabilityConfirmed := False;
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

  ButtonSampleAdd.OnClick := ButtonSampleAddClick;
  ButtonSampleEdit.OnClick := ButtonSampleEditClick;
  ButtonSampleDelete.OnClick := ButtonSampleDeleteClick;
  ButtonSamplesClear.OnClick := ButtonSamplesClearClick;
  ButtonAnalyze.OnClick := ButtonAnalyzeClick;
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


function TFrameMeterValueEdit.SampleSecondsToMs(const ASeconds: Double): Int64;
begin
  Result := Round(ASeconds * 1000);
end;

function TFrameMeterValueEdit.SelectedSampleIndex: Integer;
begin
  Result := -1;
  if (GridSamples <> nil) and (GridSamples.Row >= 0) and
     (GridSamples.Row < FTestSamples.Count) then
    Result := GridSamples.Row;
end;

procedure TFrameMeterValueEdit.LoadSampleToEditor(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FTestSamples.Count) then
    Exit;

  EditSampleTime.Text := FloatToStr(FTestSamples[AIndex].TimeStampMs / 1000);
  EditSampleValue.Text := FloatToStr(FTestSamples[AIndex].Value);
end;

procedure TFrameMeterValueEdit.RefreshSamplesGrid;
begin
  GridSamples.BeginUpdate;
  try
    GridSamples.RowCount := FTestSamples.Count;
  finally
    GridSamples.EndUpdate;
  end;

  if GridSamples.Row >= FTestSamples.Count then
    GridSamples.Row := FTestSamples.Count - 1;
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
  Sample.Value := SafeFloat(EditSampleValue.Text);
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
  Index := SelectedSampleIndex;
  if Index < 0 then
    Exit;

  Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(EditSampleTime.Text));
  Sample.Value := SafeFloat(EditSampleValue.Text);
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

procedure TFrameMeterValueEdit.ClearAnalysisDisplay;
const
  EmptyText = '—';
begin
  MemoConclusion.Lines.Clear;
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

procedure TFrameMeterValueEdit.GridSamplesCellDblClick(const Column: TColumn;
  const Row: Integer);
begin
  if (Row >= 0) and (Row < FTestSamples.Count) then
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
  if (ARow < 0) or (ARow >= FTestSamples.Count) then
    Exit;

  case ACol of
    0: Value := IntToStr(ARow + 1);
    1: Value := FloatToStr(FTestSamples[ARow].TimeStampMs / 1000);
    2: Value := IntToStr(FTestSamples[ARow].TimeStampMs);
    3: Value := FloatToStr(FTestSamples[ARow].Value);
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
  if (ARow < 0) or (ARow >= FTestSamples.Count) then
    Exit;

  if not (ACol in [1, 3]) then
    Exit;

  Sample := FTestSamples[ARow];
  case ACol of
    1: Sample.TimeStampMs := SampleSecondsToMs(SafeFloat(Value.ToString));
    3: Sample.Value := SafeFloat(Value.ToString);
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

  FTestTargetValue := TargetValue;
  FTestSettings.TargetAccuracyPlusPercent := PlusPercent;
  FTestSettings.TargetAccuracyMinusPercent := MinusPercent;
  FTestSettings.TargetToleranceAbsolute := AbsoluteTolerance;
  FTestSettings.RequireCurrentValueInRange := CheckBoxRequireCurrentValueInRange.IsChecked;
  FTestSettings.RequireMeanValueInRange := CheckBoxRequireMeanValueInRange.IsChecked;
  FTestSettings.RequireForecastInRange := CheckBoxRequireForecastInRange.IsChecked;

  CalculateTargetLimits(TargetValue, PlusPercent, MinusPercent, AbsoluteTolerance,
    LowerLimit, UpperLimit);
  EditTargetLowerLimit.Text := FloatToStr(LowerLimit);
  EditTargetUpperLimit.Text := FloatToStr(UpperLimit);
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
  if (ARow < 0) or (ARow >= FTestSamples.Count) then
    Exit;

  for I := 0 to High(FLastTestAnalysis.SampleResults) do
    if (FLastTestAnalysis.SampleResults[I].SourceIndex = ARow) and
       (FLastTestAnalysis.SampleResults[I].TimeStampMs = FTestSamples[ARow].TimeStampMs) then
    begin
      AResult := FLastTestAnalysis.SampleResults[I];
      Exit(True);
    end;

  for I := 0 to High(FLastTestAnalysis.SampleResults) do
    if FLastTestAnalysis.SampleResults[I].TimeStampMs = FTestSamples[ARow].TimeStampMs then
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

  if FTestSamples.Count = 0 then
  begin
    ClearTestAnalysis;
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
  if (not TryReadFloat(EditTargetLowerLimit.Text, LowerLimit)) or
     (not TryReadFloat(EditTargetUpperLimit.Text, UpperLimit)) then
  begin
    ClearTestAnalysis;
    ShowMessage('Анализ не выполнен: некорректные границы целевого диапазона.');
    Exit;
  end;

  FTestCurrentTimeMs := SampleSecondsToMs(SafeFloat(EditAnalysisTime.Text));
  SetLength(Samples, FTestSamples.Count);
  for I := 0 to FTestSamples.Count - 1 do
    Samples[I] := FTestSamples[I];

  TMeterValue.AnalyzeStabilitySamples(Samples, Settings, FTestCurrentTimeMs,
    FTestTargetValue, LowerLimit, UpperLimit, FTestStableCandidateSinceMs,
    FTestStabilityConfirmed, FLastTestAnalysis);
  DisplayAnalysis(FLastTestAnalysis);
  RefreshSamplesGrid;
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
  EditResultCurrentValue.Text := FormatInfoFloat(AInfo.CurrentValue, AInfo.HasCurrentValue, 4);
  EditResultMeanValue.Text := FormatInfoFloat(AInfo.MeanValue, AInfo.HasStatistics, 4);
  EditResultMinValue.Text := FormatInfoFloat(AInfo.MinValue, AInfo.HasStatistics, 4);
  EditResultMaxValue.Text := FormatInfoFloat(AInfo.MaxValue, AInfo.HasStatistics, 4);
  EditResultVariation.Text := FormatInfoFloat(AInfo.Variation, AInfo.HasStatistics, 4);
  EditResultStdDeviation.Text := FormatInfoFloat(AInfo.StdDeviation, AInfo.HasStatistics, 4);
  if AInfo.HasTrend then
    EditResultTrendRate.Text := FormatFloat('+0.0000;-0.0000;0.0000', AInfo.TrendRate)
  else
    EditResultTrendRate.Text := '—';
  EditResultTrendDirection.Text := TrendDirectionText(AInfo.TrendDirection, AInfo.HasTrend);
  EditResultForecastHorizon.Text := FormatInfoFloat(FTestSettings.ForecastHorizonSec, AInfo.HasForecast, 2);
  EditResultForecastValue.Text := FormatInfoFloat(AInfo.ForecastValue, AInfo.HasForecast, 4);
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
    Lines.Add('Текущее значение: ' + FormatInfoFloat(AInfo.CurrentValue, AInfo.HasCurrentValue, 4) + '.');
    Lines.Add('Среднее значение: ' + FormatInfoFloat(AInfo.MeanValue, AInfo.HasStatistics, 4) + '.');
    Lines.Add('Допустимый диапазон: ' + EditTargetLowerLimit.Text + '–' + EditTargetUpperLimit.Text + '.');

    Lines.Add('');
    Lines.Add('Размах: ' + FormatInfoFloat(AInfo.Variation, AInfo.HasStatistics, 4) + '.');
    Lines.Add('Стандартное отклонение: ' + FormatInfoFloat(AInfo.StdDeviation, AInfo.HasStatistics, 4) + '.');
    Lines.Add('Скорость тренда: ' + EditResultTrendRate.Text + ' ед./с.');
    Lines.Add('Направление тренда: ' + TrendDirectionText(AInfo.TrendDirection, AInfo.HasTrend) + '.');
    Lines.Add('Предварительная стабильность: ' + BoolText(AInfo.IsSignalStable) + '.');
    Lines.Add('Подтверждение стабильности: ' + BoolText(AInfo.IsStabilityConfirmed) + '.');
    if AInfo.IsSignalStable and not AInfo.IsStabilityConfirmed then
      Lines.Add('Время подтверждения: ' + FormatInfoFloat(AInfo.StableCandidateDurationSec, True, 2) +
        ' из ' + FormatInfoFloat(FTestSettings.ConfirmationTimeSec, True, 2) + ' с.');

    Lines.Add('');
    Lines.Add('Прогноз через ' + FormatInfoFloat(FTestSettings.ForecastHorizonSec, AInfo.HasForecast, 2) + ' с: ' +
      FormatInfoFloat(AInfo.ForecastValue, AInfo.HasForecast, 4) + '.');
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
    EditMaxVariation.Text := FloatToStr(FTestSettings.MaxVariation);
    EditMaxStdDeviation.Text := FloatToStr(FTestSettings.MaxStdDeviation);
    EditMaxTrendRate.Text := FloatToStr(FTestSettings.MaxTrendRate);
    EditMaxOutlierFractionPercent.Text := FloatToStr(FTestSettings.MaxOutlierFraction * 100);
    EditOutlierFactor.Text := FloatToStr(FTestSettings.OutlierFactor);
    EditForecastHorizonSec.Text := FloatToStr(FTestSettings.ForecastHorizonSec);
    EditTestTargetValue.Text := FloatToStr(FTestTargetValue);
    EditTargetAccuracyPlusPercent.Text := FloatToStr(FTestSettings.TargetAccuracyPlusPercent);
    EditTargetAccuracyMinusPercent.Text := FloatToStr(FTestSettings.TargetAccuracyMinusPercent);
    EditTargetToleranceAbsolute.Text := FloatToStr(FTestSettings.TargetToleranceAbsolute);
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
  Result := TryStrToFloat(StringReplace(Trim(AText), ',', FormatSettings.DecimalSeparator,
    [rfReplaceAll]), AValue) and (not IsNan(AValue)) and (not IsInfinite(AValue));
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
  TryReadFloat(EditMaxVariation.Text, ASettings.MaxVariation);
  TryReadFloat(EditMaxStdDeviation.Text, ASettings.MaxStdDeviation);
  TryReadFloat(EditMaxTrendRate.Text, ASettings.MaxTrendRate);
  if TryReadFloat(EditMaxOutlierFractionPercent.Text, OutlierPercent) then
    ASettings.MaxOutlierFraction := OutlierPercent / 100;
  TryReadFloat(EditOutlierFactor.Text, ASettings.OutlierFactor);
  TryReadFloat(EditForecastHorizonSec.Text, ASettings.ForecastHorizonSec);
  TryReadFloat(EditTargetAccuracyPlusPercent.Text, ASettings.TargetAccuracyPlusPercent);
  TryReadFloat(EditTargetAccuracyMinusPercent.Text, ASettings.TargetAccuracyMinusPercent);
  TryReadFloat(EditTargetToleranceAbsolute.Text, ASettings.TargetToleranceAbsolute);
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
  Result := StrToFloatDef(StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), 0);
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
begin
  if FLoading or (FMeterValue = nil) or (ComboValueDim.ItemIndex < 0) then
    Exit;

  if FMeterValue.SetDim(ComboValueDim.ItemIndex) then
  begin
    FLoading := True;
    try
      EditValue.Text := FloatToStr(FMeterValue.GetDoubleValueDim);
    finally
      FLoading := False;
    end;
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
      ClearTestAnalysis;
      Exit;
    end;

    EditValueFull.Text := FMeterValue.GetStrFullName;
    EditValue.Text := FloatToStr(FMeterValue.GetDoubleValueDim);
    FillDimensionCombo;
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
    FTestTargetValue := FMeterValue.GetDoubleValueDim;
    CopySettingsFromWorkMeterValue;
    LoadSettingsToControls;
    ClearTestAnalysis;
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
