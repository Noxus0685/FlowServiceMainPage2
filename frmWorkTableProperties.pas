unit frmWorkTableProperties;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uMeterValue,
  uParameter,
  uWorkTable;

type
  TFrameWorkTableProperties = class(TFrame)
  private
    FWorkTable: TWorkTable;
    FLoading: Boolean;

    LayoutRoot: TVertScrollBox;
    EditWorkTableText: TEdit;
    EditWorkTableName: TEdit;
    LabelWorkTableUUID: TLabel;
    LabelWorkTableState: TLabel;
    ComboEditMode: TComboBox;
    TreeMeterValues: TTreeView;
    EditPressureMin: TEdit;
    EditPressureMax: TEdit;
    EditTempertureMin: TEdit;
    EditTempertureMax: TEdit;
    EditFlowRateMin: TEdit;
    EditFlowRateMax: TEdit;
    EditQuantityMin: TEdit;
    EditQuantityMax: TEdit;
    EditPressure: TEdit;
    EditTemperture: TEdit;
    EditFlowRate: TEdit;
    EditQuantity: TEdit;
    ButtonSelectPressure: TButton;
    ButtonSelectTemperture: TButton;
    ButtonSelectFlowRate: TButton;
    ButtonSelectQuantity: TButton;

    procedure BuildUI;
    procedure AddEditRow(const ACaption: string; out AEdit: TEdit);
    procedure AddLabelRow(const ACaption: string; out ALabel: TLabel);
    procedure AddComboRow(const ACaption: string; out ACombo: TComboBox);
    procedure AddMeterValueRow(AParent: TTreeViewItem; const ACaption: string; out AEdit: TEdit;
      out AButton: TButton; AOnClick: TNotifyEvent);
    function AddMeterCategory(const ACaption: string): TTreeViewItem;
    function CreateLimitEdit(AParent: TTreeViewItem; const ACaption: string; const ATag: Integer): TEdit;
    function MeterValueToText(AMeterValue: TMeterValue): string;
    function WorkTableStateToCaption(AState: EStateWorkTable): string;
    function ParameterByKind(const AKind: Integer): TParameter;
    function MeterValueByKind(const AKind: Integer): TMeterValue;
    procedure RefreshValues;
    procedure HandleWorkTableTextExit(Sender: TObject);
    procedure HandleWorkTableNameExit(Sender: TObject);
    procedure HandleEditModeChange(Sender: TObject);
    procedure HandleLimitExit(Sender: TObject);
    procedure NotifyRefreshIfChanged(const AChanged: Boolean);
    procedure ApplyEditState;
    procedure SelectMeterValue(AKind: Integer);
    procedure ButtonSelectPressureClick(Sender: TObject);
    procedure ButtonSelectTempertureClick(Sender: TObject);
    procedure ButtonSelectFlowRateClick(Sender: TObject);
    procedure ButtonSelectQuantityClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    function CanEditWorkTable: Boolean;
    procedure LoadFromWorkTable(AWorkTable: TWorkTable);
  end;

implementation

uses
  frmMeterValueSelect;

{$R *.fmx}

constructor TFrameWorkTableProperties.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
end;

procedure TFrameWorkTableProperties.BuildUI;
var
  PressureCategory: TTreeViewItem;
  TempertureCategory: TTreeViewItem;
  FlowRateCategory: TTreeViewItem;
  QuantityCategory: TTreeViewItem;
begin
  LayoutRoot := TVertScrollBox.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

  AddEditRow('Название рабочего стола', EditWorkTableText);
  EditWorkTableText.OnExit := HandleWorkTableTextExit;

  AddEditRow('Имя рабочего стола', EditWorkTableName);
  EditWorkTableName.OnExit := HandleWorkTableNameExit;

  AddLabelRow('UUID рабочего стола', LabelWorkTableUUID);
  AddLabelRow('Текущее состояние', LabelWorkTableState);

  AddComboRow('Редактирование', ComboEditMode);
  ComboEditMode.Items.Add('Можно редактировать');
  ComboEditMode.Items.Add('Нельзя редактировать');
  ComboEditMode.ItemIndex := 0;
  ComboEditMode.OnChange := HandleEditModeChange;

  TreeMeterValues := TTreeView.Create(Self);
  TreeMeterValues.Parent := LayoutRoot;
  TreeMeterValues.Align := TAlignLayout.Top;
  TreeMeterValues.Height := 520;
  TreeMeterValues.Margins.Rect := TRectF.Create(0, 8, 0, 0);
  TreeMeterValues.ShowCheckboxes := False;
  TreeMeterValues.ItemHeight := 32;
  TreeMeterValues.Stored := False;

  PressureCategory := AddMeterCategory('Давление');
  AddMeterValueRow(PressureCategory, 'Давление', EditPressure, ButtonSelectPressure,
    ButtonSelectPressureClick);
  EditPressureMin := CreateLimitEdit(PressureCategory, 'Мин значение', 0);
  EditPressureMax := CreateLimitEdit(PressureCategory, 'Макс значение', 1);

  TempertureCategory := AddMeterCategory('Температура');
  AddMeterValueRow(TempertureCategory, 'Температура', EditTemperture, ButtonSelectTemperture,
    ButtonSelectTempertureClick);
  EditTempertureMin := CreateLimitEdit(TempertureCategory, 'Мин значение', 2);
  EditTempertureMax := CreateLimitEdit(TempertureCategory, 'Макс значение', 3);

  FlowRateCategory := AddMeterCategory('Расход');
  AddMeterValueRow(FlowRateCategory, 'Расход', EditFlowRate, ButtonSelectFlowRate,
    ButtonSelectFlowRateClick);
  EditFlowRateMin := CreateLimitEdit(FlowRateCategory, 'Мин значение', 4);
  EditFlowRateMax := CreateLimitEdit(FlowRateCategory, 'Макс значение', 5);

  QuantityCategory := AddMeterCategory('Жидкость');
  AddMeterValueRow(QuantityCategory, 'Количество жидкости', EditQuantity, ButtonSelectQuantity,
    ButtonSelectQuantityClick);
  EditQuantityMin := CreateLimitEdit(QuantityCategory, 'Мин значение', 6);
  EditQuantityMax := CreateLimitEdit(QuantityCategory, 'Макс значение', 7);
end;

procedure TFrameWorkTableProperties.AddEditRow(const ACaption: string; out AEdit: TEdit);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 36;
  Item.Margins.Bottom := 4;
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
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  AEdit := TEdit.Create(Self);
  AEdit.Parent := RowGrid;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  AEdit.KillFocusByReturn := True;
  RowGrid.ControlCollection.AddControl(AEdit, 1, 0);
end;

procedure TFrameWorkTableProperties.AddLabelRow(const ACaption: string; out ALabel: TLabel);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 32;
  Item.Margins.Bottom := 4;
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
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  ALabel := TLabel.Create(Self);
  ALabel.Parent := RowGrid;
  ALabel.Align := TAlignLayout.Client;
  ALabel.Margins.Rect := TRectF.Create(6, 0, 10, 0);
  ALabel.TextSettings.VertAlign := TTextAlign.Center;
  RowGrid.ControlCollection.AddControl(ALabel, 1, 0);
end;

procedure TFrameWorkTableProperties.AddComboRow(const ACaption: string; out ACombo: TComboBox);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 36;
  Item.Margins.Bottom := 4;
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
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  ACombo := TComboBox.Create(Self);
  ACombo.Parent := RowGrid;
  ACombo.Align := TAlignLayout.Client;
  ACombo.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  RowGrid.ControlCollection.AddControl(ACombo, 1, 0);
end;

procedure TFrameWorkTableProperties.AddMeterValueRow(AParent: TTreeViewItem; const ACaption: string; out AEdit: TEdit;
  out AButton: TButton; AOnClick: TNotifyEvent);
var
  Item: TTreeViewItem;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
  ValueLayout: TLayout;
begin
  Item := TTreeViewItem.Create(Self);
  Item.Parent := AParent;
  Item.Text := '';
  Item.Height := 36;
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
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  ValueLayout := TLayout.Create(Self);
  ValueLayout.Parent := RowGrid;
  ValueLayout.Align := TAlignLayout.Client;
  ValueLayout.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  ValueLayout.Stored := False;
  RowGrid.ControlCollection.AddControl(ValueLayout, 1, 0);

  AButton := TButton.Create(Self);
  AButton.Parent := ValueLayout;
  AButton.Align := TAlignLayout.Right;
  AButton.Width := 36;
  AButton.Margins.Left := 8;
  AButton.Text := '...';
  AButton.OnClick := AOnClick;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := ValueLayout;
  AEdit.Align := TAlignLayout.Client;
  AEdit.ReadOnly := True;
end;

function TFrameWorkTableProperties.AddMeterCategory(const ACaption: string): TTreeViewItem;
begin
  Result := TTreeViewItem.Create(Self);
  Result.Parent := TreeMeterValues;
  Result.Text := ACaption;
  Result.StyledSettings := [];
  Result.TextSettings.Font.Style := [TFontStyle.fsBold];
  Result.TextSettings.FontColor := $FF2C2C2C;
  Result.IsExpanded := True;
  Result.Height := 30;
  Result.Stored := False;
end;

function TFrameWorkTableProperties.CreateLimitEdit(AParent: TTreeViewItem; const ACaption: string;
  const ATag: Integer): TEdit;
var
  Item: TTreeViewItem;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TTreeViewItem.Create(Self);
  Item.Parent := AParent;
  Item.Text := '';
  Item.Height := 36;
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
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  Result := TEdit.Create(Self);
  Result.Parent := RowGrid;
  Result.Align := TAlignLayout.Client;
  Result.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  Result.KillFocusByReturn := True;
  Result.Tag := ATag;
  Result.OnExit := HandleLimitExit;
  RowGrid.ControlCollection.AddControl(Result, 1, 0);
end;

function TFrameWorkTableProperties.MeterValueToText(AMeterValue: TMeterValue): string;
begin
  if AMeterValue = nil then
    Exit('');

  Result := AMeterValue.Hash;
end;

function TFrameWorkTableProperties.WorkTableStateToCaption(AState: EStateWorkTable): string;
begin
  case AState of
    swtSTANDBY: Result := 'Ожидание';
    swtCONNECTED: Result := 'Подключен';
    swtSTARTMONITOR: Result := 'Запуск мониторинга';
    swtSTARTMONITORWAIT: Result := 'Ожидание запуска мониторинга';
    swtMONITOR: Result := 'Мониторинг';
    swtSTOPMONITOR: Result := 'Остановка мониторинга';
    swtCONFIGED: Result := 'Настроен';
    swtSTARTTEST: Result := 'Запуск измерения';
    swtSTARTWAIT: Result := 'Ожидание запуска';
    swtEXECUTE: Result := 'Выполнение';
    swtSTOPTEST: Result := 'Остановка измерения';
    swtSTOPWAIT: Result := 'Ожидание остановки';
    swtCOMPLETE: Result := 'Завершен';
    swtFINALREAD: Result := 'Финальное чтение';
    swtFAILURE: Result := 'Ошибка';
  else
    Result := 'Не задано';
  end;
end;


function TFrameWorkTableProperties.ParameterByKind(const AKind: Integer): TParameter;
begin
  Result := nil;
  if FWorkTable = nil then
    Exit;

  case AKind of
    0: Result := FWorkTable.FluidPress;
    1: Result := FWorkTable.FluidTemp;
    2: Result := FWorkTable.FlowRate;
  end;
end;

function TFrameWorkTableProperties.MeterValueByKind(const AKind: Integer): TMeterValue;
begin
  Result := nil;
  if FWorkTable = nil then
    Exit;

  case AKind of
    0: Result := FWorkTable.ValuePressure;
    1: Result := FWorkTable.ValueTemperture;
    2: Result := FWorkTable.ValueFlowRate;
    3: Result := FWorkTable.ValueQuantity;
  end;
end;

function TFrameWorkTableProperties.CanEditWorkTable: Boolean;
begin
  Result := (FWorkTable <> nil) and (ComboEditMode.ItemIndex = 0);
end;

procedure TFrameWorkTableProperties.LoadFromWorkTable(AWorkTable: TWorkTable);
begin
  FWorkTable := AWorkTable;
  RefreshValues;
  ApplyEditState;
end;

procedure TFrameWorkTableProperties.RefreshValues;
begin
  FLoading := True;
  try
    if FWorkTable = nil then
    begin
      EditWorkTableText.Text := '';
      EditWorkTableName.Text := '';
      LabelWorkTableUUID.Text := '';
      LabelWorkTableState.Text := '';
      ComboEditMode.Enabled := False;
      EditPressure.Text := '';
      EditTemperture.Text := '';
      EditFlowRate.Text := '';
      EditQuantity.Text := '';
      EditPressureMin.Text := '';
      EditPressureMax.Text := '';
      EditTempertureMin.Text := '';
      EditTempertureMax.Text := '';
      EditFlowRateMin.Text := '';
      EditFlowRateMax.Text := '';
      EditQuantityMin.Text := '';
      EditQuantityMax.Text := '';
      Exit;
    end;

    EditWorkTableText.Text := FWorkTable.Text;
    EditWorkTableName.Text := FWorkTable.Name;
    LabelWorkTableUUID.Text := FWorkTable.UUID;
    LabelWorkTableState.Text := WorkTableStateToCaption(FWorkTable.State);
    ComboEditMode.Enabled := True;
    EditPressure.Text := MeterValueToText(FWorkTable.ValuePressure);
    EditTemperture.Text := MeterValueToText(FWorkTable.ValueTemperture);
    EditFlowRate.Text := MeterValueToText(FWorkTable.ValueFlowRate);
    EditQuantity.Text := MeterValueToText(FWorkTable.ValueQuantity);

    if FWorkTable.FluidPress <> nil then
    begin
      EditPressureMin.Text := FWorkTable.ValuePressure.GetStrNum(FWorkTable.FluidPress.Min);
      EditPressureMax.Text := FWorkTable.ValuePressure.GetStrNum(FWorkTable.FluidPress.Max);
    end;
    if FWorkTable.FluidTemp <> nil then
    begin
      EditTempertureMin.Text := FWorkTable.ValueTemperture.GetStrNum(FWorkTable.FluidTemp.Min);
      EditTempertureMax.Text := FWorkTable.ValueTemperture.GetStrNum(FWorkTable.FluidTemp.Max);
    end;
    if FWorkTable.FlowRate <> nil then
    begin
      EditFlowRateMin.Text := FWorkTable.ValueFlowRate.GetStrNum(FWorkTable.FlowRate.Min);
      EditFlowRateMax.Text := FWorkTable.ValueFlowRate.GetStrNum(FWorkTable.FlowRate.Max);
    end;
    if FWorkTable.TableFlow <> nil then
    begin
      EditQuantityMin.Text := FWorkTable.ValueQuantity.GetStrNum(FWorkTable.TableFlow.QuantityMin);
      EditQuantityMax.Text := FWorkTable.ValueQuantity.GetStrNum(FWorkTable.TableFlow.QuantityMax);
    end;
  finally
    FLoading := False;
  end;
end;

procedure TFrameWorkTableProperties.ApplyEditState;
var
  CanEdit: Boolean;
begin
  CanEdit := CanEditWorkTable;

  EditWorkTableText.Enabled := CanEdit;
  EditWorkTableName.Enabled := CanEdit;
  ButtonSelectPressure.Enabled := CanEdit;
  ButtonSelectTemperture.Enabled := CanEdit;
  ButtonSelectFlowRate.Enabled := CanEdit;
  ButtonSelectQuantity.Enabled := CanEdit;
  EditPressureMin.Enabled := CanEdit;
  EditPressureMax.Enabled := CanEdit;
  EditTempertureMin.Enabled := CanEdit;
  EditTempertureMax.Enabled := CanEdit;
  EditFlowRateMin.Enabled := CanEdit;
  EditFlowRateMax.Enabled := CanEdit;
  EditQuantityMin.Enabled := CanEdit;
  EditQuantityMax.Enabled := CanEdit;
end;

procedure TFrameWorkTableProperties.HandleEditModeChange(Sender: TObject);
begin
  ApplyEditState;
  if (not FLoading) and (FWorkTable <> nil) then
    FWorkTable.FireEvent(ewtRefresh);
end;


procedure TFrameWorkTableProperties.HandleLimitExit(Sender: TObject);
var
  Edit: TEdit;
  Kind: Integer;
  IsMax: Boolean;
  TextValue: string;
  NewValue: Double;
  BaseValue: Double;
  FormatSettings: TFormatSettings;
  Parameter: TParameter;
  MeterValue: TMeterValue;
  Changed: Boolean;
begin
  if FLoading or (FWorkTable = nil) or not (Sender is TEdit) then
    Exit;

  Edit := TEdit(Sender);
  Kind := Edit.Tag div 2;
  IsMax := (Edit.Tag mod 2) = 1;
  TextValue := StringReplace(Trim(Edit.Text), ',', '.', [rfReplaceAll]);
  FormatSettings := TFormatSettings.Invariant;
  if not TryStrToFloat(TextValue, NewValue, FormatSettings) then
  begin
    RefreshValues;
    Exit;
  end;

  MeterValue := MeterValueByKind(Kind);
  if MeterValue = nil then
    Exit;

  Changed := False;
  if Kind = 3 then
  begin
    if FWorkTable.TableFlow = nil then
      Exit;

    BaseValue := MeterValue.GetDoubleBaseNum(NewValue, MeterValue.CurrentDimIndex);
    if IsMax then
    begin
      if BaseValue < FWorkTable.TableFlow.QuantityMin then
      begin
        RefreshValues;
        Exit;
      end;
      Changed := FWorkTable.TableFlow.QuantityMax <> BaseValue;
      FWorkTable.TableFlow.QuantityMax := BaseValue;
    end
    else
    begin
      if BaseValue > FWorkTable.TableFlow.QuantityMax then
      begin
        RefreshValues;
        Exit;
      end;
      Changed := FWorkTable.TableFlow.QuantityMin <> BaseValue;
      FWorkTable.TableFlow.QuantityMin := BaseValue;
    end;
  end
  else
  begin
    Parameter := ParameterByKind(Kind);
    if Parameter = nil then
      Exit;

    BaseValue := MeterValue.GetDoubleBaseNum(NewValue, MeterValue.CurrentDimIndex);
    if IsMax then
    begin
      if BaseValue < Parameter.Min then
      begin
        RefreshValues;
        Exit;
      end;
      Changed := Parameter.Max <> BaseValue;
      Parameter.Max := BaseValue;
    end
    else
    begin
      if BaseValue > Parameter.Max then
      begin
        RefreshValues;
        Exit;
      end;
      Changed := Parameter.Min <> BaseValue;
      Parameter.Min := BaseValue;
    end;
  end;

  RefreshValues;
  NotifyRefreshIfChanged(Changed);
end;

procedure TFrameWorkTableProperties.NotifyRefreshIfChanged(const AChanged: Boolean);
begin
  if AChanged and (FWorkTable <> nil) then
  begin
    FWorkTable.FireEvent(ewtRefresh);
    if WorkTableManager <> nil then
      WorkTableManager.Save;
  end;
end;

procedure TFrameWorkTableProperties.HandleWorkTableTextExit(Sender: TObject);
var
  NewValue: string;
begin
  if FLoading or (FWorkTable = nil) then
    Exit;

  NewValue := EditWorkTableText.Text;
  if FWorkTable.Text = NewValue then
    Exit;

  FWorkTable.Text := NewValue;
  NotifyRefreshIfChanged(True);
end;

procedure TFrameWorkTableProperties.HandleWorkTableNameExit(Sender: TObject);
var
  NewValue: string;
begin
  if FLoading or (FWorkTable = nil) then
    Exit;

  NewValue := EditWorkTableName.Text;
  if FWorkTable.Name = NewValue then
    Exit;

  FWorkTable.Name := NewValue;
  NotifyRefreshIfChanged(True);
end;

procedure TFrameWorkTableProperties.SelectMeterValue(AKind: Integer);
var
  Form: TFormMeterValueSelect;
  SelectedMeterValue: TMeterValue;
begin
  if (FWorkTable = nil) or (ComboEditMode.ItemIndex <> 0) then
    Exit;

  Form := TFormMeterValueSelect.Create(Self);
  try
    case AKind of
      0: Form.SetFilterText('давление');
      1: Form.SetFilterText('температура');
      2: Form.SetFilterText('расход');
      3: Form.SetFilterText('объем');
    end;

    case AKind of
      0: Form.SelectMeterValue(FWorkTable.ValuePressure);
      1: Form.SelectMeterValue(FWorkTable.ValueTemperture);
      2: Form.SelectMeterValue(FWorkTable.ValueFlowRate);
      3: Form.SelectMeterValue(FWorkTable.ValueQuantity);
    end;

    if Form.ShowModal <> mrOk then
      Exit;

    SelectedMeterValue := Form.SelectedMeterValue;
    if SelectedMeterValue = nil then
      Exit;

    case AKind of
      0: FWorkTable.ValuePressure := SelectedMeterValue;
      1: FWorkTable.ValueTemperture := SelectedMeterValue;
      2: FWorkTable.ValueFlowRate := SelectedMeterValue;
      3: FWorkTable.ValueQuantity := SelectedMeterValue;
    else
      Exit;
    end;

    RefreshValues;
    FWorkTable.FireEvent(ewtRefresh);
    if WorkTableManager <> nil then
      WorkTableManager.Save;
  finally
    Form.Free;
  end;
end;

procedure TFrameWorkTableProperties.ButtonSelectPressureClick(Sender: TObject);
begin
  SelectMeterValue(0);
end;

procedure TFrameWorkTableProperties.ButtonSelectTempertureClick(Sender: TObject);
begin
  SelectMeterValue(1);
end;

procedure TFrameWorkTableProperties.ButtonSelectFlowRateClick(Sender: TObject);
begin
  SelectMeterValue(2);
end;

procedure TFrameWorkTableProperties.ButtonSelectQuantityClick(Sender: TObject);
begin
  SelectMeterValue(3);
end;

end.
