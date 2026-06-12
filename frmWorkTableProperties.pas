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

    LayoutRoot: TLayout;
    EditWorkTableText: TEdit;
    EditWorkTableName: TEdit;
    LabelWorkTableUUID: TLabel;
    LabelWorkTableState: TLabel;
    ComboEditMode: TComboBox;
    ComboVerticalSync: TComboBox;
    ComboVerticalStart: TComboBox;
    ComboVerticalStop: TComboBox;
    ComboVerticalChannel: TComboBox;
    ComboOutputSync1: TComboBox;
    ComboOutputStart1: TComboBox;
    ComboOutputStop1: TComboBox;
    ComboOutputSync2: TComboBox;
    ComboOutputStart2: TComboBox;
    ComboOutputStop2: TComboBox;
    ComboInternalSyncChannel: TComboBox;
    TreeProperties: TTreeView;
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
    procedure AddEditRow(AParent: TTreeViewItem; const ACaption: string; out AEdit: TEdit);
    procedure AddLabelRow(AParent: TTreeViewItem; const ACaption: string; out ALabel: TLabel);
    procedure AddComboRow(AParent: TTreeViewItem; const ACaption: string; out ACombo: TComboBox);
    procedure AddMeterValueRow(AParent: TTreeViewItem; const ACaption: string; out AEdit: TEdit;
      out AButton: TButton; AOnClick: TNotifyEvent);
    function AddCategory(const ACaption: string): TTreeViewItem;
    function CreateLimitEdit(AParent: TTreeViewItem; const ACaption: string; const ATag: Integer): TEdit;
    function MeterValueToText(AMeterValue: TMeterValue): string;
    function WorkTableStateToCaption(AState: EStateWorkTable): string;
    function ParameterByKind(const AKind: Integer): TParameter;
    function MeterValueByKind(const AKind: Integer): TMeterValue;
    procedure RefreshValues;
    procedure FillChannelCombo;
    procedure HandleWorkTableTextExit(Sender: TObject);
    procedure HandleWorkTableNameExit(Sender: TObject);
    procedure HandleEditModeChange(Sender: TObject);
    procedure HandleSyncComboChange(Sender: TObject);
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
  GeneralCategory: TTreeViewItem;
  PressureCategory: TTreeViewItem;
  TempertureCategory: TTreeViewItem;
  FlowRateCategory: TTreeViewItem;
  QuantityCategory: TTreeViewItem;
  VerticalSyncCategory: TTreeViewItem;
  OutputSyncCategory1: TTreeViewItem;
  OutputSyncCategory2: TTreeViewItem;
  InternalSyncCategory: TTreeViewItem;
  HeaderGrid: TGridPanelLayout;
  HeaderProperty: TLabel;
  HeaderValue: TLabel;
  HeaderDivider: TLine;
begin
  LayoutRoot := TLayout.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

  TreeProperties := TTreeView.Create(Self);
  TreeProperties.Parent := LayoutRoot;
  TreeProperties.Align := TAlignLayout.Client;
  TreeProperties.ShowCheckboxes := False;
  TreeProperties.ItemHeight := 32;
  TreeProperties.Stored := False;

  HeaderGrid := TGridPanelLayout.Create(Self);
  HeaderGrid.Parent := LayoutRoot;
  HeaderGrid.Align := TAlignLayout.Top;
  HeaderGrid.Height := 30;
  HeaderGrid.RowCollection.Clear;
  HeaderGrid.ColumnCollection.Clear;
  HeaderGrid.ColumnCollection.Add.Value := 45;
  HeaderGrid.ColumnCollection.Add.Value := 55;
  HeaderGrid.RowCollection.Add.Value := 100;
  HeaderGrid.Stored := False;

  HeaderProperty := TLabel.Create(Self);
  HeaderProperty.Parent := HeaderGrid;
  HeaderProperty.Align := TAlignLayout.Client;
  HeaderProperty.Text := 'Свойство';
  HeaderProperty.StyledSettings := [];
  HeaderProperty.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderProperty.TextSettings.FontColor := $FF3D3D3D;
  HeaderProperty.Margins.Rect := TRectF.Create(10, 0, 8, 0);
  HeaderGrid.ControlCollection.AddControl(HeaderProperty, 0, 0);

  HeaderValue := TLabel.Create(Self);
  HeaderValue.Parent := HeaderGrid;
  HeaderValue.Align := TAlignLayout.Client;
  HeaderValue.Text := 'Значение';
  HeaderValue.StyledSettings := [];
  HeaderValue.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderValue.TextSettings.FontColor := $FF3D3D3D;
  HeaderValue.Margins.Rect := TRectF.Create(8, 0, 10, 0);
  HeaderGrid.ControlCollection.AddControl(HeaderValue, 1, 0);

  HeaderDivider := TLine.Create(Self);
  HeaderDivider.Parent := LayoutRoot;
  HeaderDivider.Align := TAlignLayout.Top;
  HeaderDivider.Height := 1;
  HeaderDivider.LineType := TLineType.Bottom;
  HeaderDivider.Stroke.Color := $FFCDCDCD;
  HeaderDivider.Stored := False;

  GeneralCategory := AddCategory('Рабочий стол');
  AddEditRow(GeneralCategory, 'Название рабочего стола', EditWorkTableText);
  EditWorkTableText.OnExit := HandleWorkTableTextExit;

  AddEditRow(GeneralCategory, 'Имя рабочего стола', EditWorkTableName);
  EditWorkTableName.OnExit := HandleWorkTableNameExit;

  AddLabelRow(GeneralCategory, 'UUID рабочего стола', LabelWorkTableUUID);
  AddLabelRow(GeneralCategory, 'Текущее состояние', LabelWorkTableState);

  AddComboRow(GeneralCategory, 'Редактирование', ComboEditMode);
  ComboEditMode.Items.Add('Можно редактировать');
  ComboEditMode.Items.Add('Нельзя редактировать');
  ComboEditMode.ItemIndex := 0;
  ComboEditMode.OnChange := HandleEditModeChange;

  VerticalSyncCategory := AddCategory('Вертикальная синхронизация');
  AddComboRow(VerticalSyncCategory, 'Вертикальная синхронизация', ComboVerticalSync);
  ComboVerticalSync.Items.Add('Отключено');
  ComboVerticalSync.Items.Add('Внешняя синхронизация');
  ComboVerticalSync.Items.Add('По каналу');
  ComboVerticalSync.ItemIndex := 0;
  ComboVerticalSync.OnChange := HandleSyncComboChange;
  AddComboRow(VerticalSyncCategory, 'Старт', ComboVerticalStart);
  ComboVerticalStart.Items.Add('Фронт');
  ComboVerticalStart.Items.Add('Спад');
  ComboVerticalStart.ItemIndex := 0;
  AddComboRow(VerticalSyncCategory, 'Стоп', ComboVerticalStop);
  ComboVerticalStop.Items.Add('Фронт');
  ComboVerticalStop.Items.Add('Спад');
  ComboVerticalStop.ItemIndex := 0;
  AddComboRow(VerticalSyncCategory, 'Канал', ComboVerticalChannel);

  OutputSyncCategory1 := AddCategory('Выходная синхронизация 1');
  AddComboRow(OutputSyncCategory1, 'Выходная синхронизация', ComboOutputSync1);
  ComboOutputSync1.Items.Add('Выкл');
  ComboOutputSync1.Items.Add('Вкл');
  ComboOutputSync1.ItemIndex := 0;
  ComboOutputSync1.OnChange := HandleSyncComboChange;
  AddComboRow(OutputSyncCategory1, 'Старт', ComboOutputStart1);
  ComboOutputStart1.Items.Add('Фронт');
  ComboOutputStart1.Items.Add('Спад');
  ComboOutputStart1.ItemIndex := 0;
  AddComboRow(OutputSyncCategory1, 'Стоп', ComboOutputStop1);
  ComboOutputStop1.Items.Add('Фронт');
  ComboOutputStop1.Items.Add('Спад');
  ComboOutputStop1.ItemIndex := 0;

  OutputSyncCategory2 := AddCategory('Выходная синхронизация 2');
  AddComboRow(OutputSyncCategory2, 'Выходная синхронизация', ComboOutputSync2);
  ComboOutputSync2.Items.Add('Выкл');
  ComboOutputSync2.Items.Add('Вкл');
  ComboOutputSync2.ItemIndex := 0;
  ComboOutputSync2.OnChange := HandleSyncComboChange;
  AddComboRow(OutputSyncCategory2, 'Старт', ComboOutputStart2);
  ComboOutputStart2.Items.Add('Фронт');
  ComboOutputStart2.Items.Add('Спад');
  ComboOutputStart2.ItemIndex := 0;
  AddComboRow(OutputSyncCategory2, 'Стоп', ComboOutputStop2);
  ComboOutputStop2.Items.Add('Фронт');
  ComboOutputStop2.Items.Add('Спад');
  ComboOutputStop2.ItemIndex := 0;

  InternalSyncCategory := AddCategory('Выход внутренней синхронизации');
  AddComboRow(InternalSyncCategory, 'Канал', ComboInternalSyncChannel);
  ComboInternalSyncChannel.Items.Add('Выкл');
  ComboInternalSyncChannel.Items.Add('Вкл');
  ComboInternalSyncChannel.ItemIndex := 0;

  PressureCategory := AddCategory('Давление');
  AddMeterValueRow(PressureCategory, 'Давление', EditPressure, ButtonSelectPressure,
    ButtonSelectPressureClick);
  EditPressureMin := CreateLimitEdit(PressureCategory, 'Мин значение', 0);
  EditPressureMax := CreateLimitEdit(PressureCategory, 'Макс значение', 1);

  TempertureCategory := AddCategory('Температура');
  AddMeterValueRow(TempertureCategory, 'Температура', EditTemperture, ButtonSelectTemperture,
    ButtonSelectTempertureClick);
  EditTempertureMin := CreateLimitEdit(TempertureCategory, 'Мин значение', 2);
  EditTempertureMax := CreateLimitEdit(TempertureCategory, 'Макс значение', 3);

  FlowRateCategory := AddCategory('Расход');
  AddMeterValueRow(FlowRateCategory, 'Расход', EditFlowRate, ButtonSelectFlowRate,
    ButtonSelectFlowRateClick);
  EditFlowRateMin := CreateLimitEdit(FlowRateCategory, 'Мин значение', 4);
  EditFlowRateMax := CreateLimitEdit(FlowRateCategory, 'Макс значение', 5);

  QuantityCategory := AddCategory('Жидкость');
  AddMeterValueRow(QuantityCategory, 'Количество жидкости', EditQuantity, ButtonSelectQuantity,
    ButtonSelectQuantityClick);
  EditQuantityMin := CreateLimitEdit(QuantityCategory, 'Мин значение', 6);
  EditQuantityMax := CreateLimitEdit(QuantityCategory, 'Макс значение', 7);
end;

procedure TFrameWorkTableProperties.AddEditRow(AParent: TTreeViewItem; const ACaption: string; out AEdit: TEdit);
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

  AEdit := TEdit.Create(Self);
  AEdit.Parent := RowGrid;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  AEdit.KillFocusByReturn := True;
  RowGrid.ControlCollection.AddControl(AEdit, 1, 0);
end;

procedure TFrameWorkTableProperties.AddLabelRow(AParent: TTreeViewItem; const ACaption: string; out ALabel: TLabel);
var
  Item: TTreeViewItem;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TTreeViewItem.Create(Self);
  Item.Parent := AParent;
  Item.Text := '';
  Item.Height := 32;
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

procedure TFrameWorkTableProperties.AddComboRow(AParent: TTreeViewItem; const ACaption: string; out ACombo: TComboBox);
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

function TFrameWorkTableProperties.AddCategory(const ACaption: string): TTreeViewItem;
begin
  Result := TTreeViewItem.Create(Self);
  Result.Parent := TreeProperties;
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

procedure TFrameWorkTableProperties.FillChannelCombo;
var
  I: Integer;
  Channel: TChannel;
  ChannelName: string;
begin
  ComboVerticalChannel.Items.Clear;
  if FWorkTable = nil then
  begin
    ComboVerticalChannel.ItemIndex := -1;
    Exit;
  end;

  for I := 0 to FWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := FWorkTable.DeviceChannels[I];
    if Channel = nil then
      Continue;
    ChannelName := Trim(Channel.Name);
    if ChannelName = '' then
      ChannelName := Trim(Channel.Text);
    if ChannelName = '' then
      ChannelName := TWorkTable.BuildDeviceChannelServiceName(I + 1);
    ComboVerticalChannel.Items.Add(ChannelName);
  end;

  if ComboVerticalChannel.Items.Count > 0 then
    ComboVerticalChannel.ItemIndex := 0
  else
    ComboVerticalChannel.ItemIndex := -1;
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
      FillChannelCombo;
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
    FillChannelCombo;
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
  ComboVerticalSync.Enabled := CanEdit;
  ComboVerticalStart.Enabled := CanEdit and (ComboVerticalSync.ItemIndex = 1);
  ComboVerticalStop.Enabled := CanEdit and (ComboVerticalSync.ItemIndex = 1);
  ComboVerticalChannel.Enabled := CanEdit and (ComboVerticalSync.ItemIndex = 2);
  ComboOutputSync1.Enabled := CanEdit;
  ComboOutputStart1.Enabled := CanEdit and (ComboOutputSync1.ItemIndex = 1);
  ComboOutputStop1.Enabled := CanEdit and (ComboOutputSync1.ItemIndex = 1);
  ComboOutputSync2.Enabled := CanEdit;
  ComboOutputStart2.Enabled := CanEdit and (ComboOutputSync2.ItemIndex = 1);
  ComboOutputStop2.Enabled := CanEdit and (ComboOutputSync2.ItemIndex = 1);
  ComboInternalSyncChannel.Enabled := CanEdit;
end;

procedure TFrameWorkTableProperties.HandleSyncComboChange(Sender: TObject);
begin
  ApplyEditState;
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
