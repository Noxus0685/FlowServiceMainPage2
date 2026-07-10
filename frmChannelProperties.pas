unit frmChannelProperties;

interface

//{$CODEPAGE UTF8}

uses
  FMX.ComboEdit,
  FMX.Controls,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Graphics,
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uBaseProcedures,
  uClasses,
  uWorkTable;

type
  TFrameChannelProperties = class(TFrame)
  private
    LayoutRoot: TLayout;
    HeaderGrid: TGridPanelLayout;
    TreeInspector: TTreeView;
    HeaderProperty: TLabel;
    HeaderValue: TLabel;
    HeaderDivider: TLine;
    EditChannelText: TEdit;
    EditChannelName: TEdit;
    EditChannelGroup: TEdit;
    EditQMaxWork: TEdit;
    EditQMinWork: TEdit;
    EditVMaxWork: TEdit;
    EditVMinWork: TEdit;
    ComboChannelType: TComboBox;
    ComboOutputSet: TComboBox;
    ComboSyncMode: TComboBox;
    ComboNoiseFilter: TComboBox;
    IndicatorOutputSet: TCircle;
    IndicatorSyncMode: TCircle;
    IndicatorNoiseFilter: TCircle;
    LabelChannelHash: TLabel;
    LabelQMaxWork: TLabel;
    LabelQMinWork: TLabel;
    FChannel: TChannel;
    FLoading: Boolean;

    function AddCategory(const ACaption: string): TTreeViewItem;
    function AddPropertyRow(AParent: TTreeViewItem; const ACaption: string;
      AControl: TControl): TLabel;
    function CreateEditCombo(const AItems: array of string): TComboEdit;
    procedure BuildUI;
    function CreateComboBox(const AItems: array of string): TComboBox;
    function CreateComboWithIndicator(ACombo: TComboBox; out AIndicator: TCircle): TControl;
    procedure ApplyIndicatorColor(AIndicator: TCircle; const AColor: TAlphaColor);
    procedure RefreshRegisterColors;
    procedure HandleChannelTextExit(Sender: TObject);
    procedure HandleChannelNameExit(Sender: TObject);
    procedure HandleChannelGroupExit(Sender: TObject);
    procedure HandleQMaxWorkExit(Sender: TObject);
    procedure HandleQMinWorkExit(Sender: TObject);
    procedure HandleVMaxWorkExit(Sender: TObject);
    procedure HandleVMinWorkExit(Sender: TObject);
    procedure HandleOutputSetChange(Sender: TObject);
    procedure HandleSyncModeChange(Sender: TObject);
    procedure HandleNoiseFilterChange(Sender: TObject);
    procedure NotifyWorkTableRefreshIfChanged(const AChanged: Boolean);
    function GetChannelWorkTable: TWorkTable;
    function GetFlowUnitName: string;
    function FlowFromBase(const AValueLSec: Double): Double;
    function FlowToBase(const AValue: Double): Double;
    function GetFlowFormatError: Double;
    function FormatFlowWorkValue(const AValue: Double): string;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromChannel(AChannel: TChannel);
    procedure UpdateFlowUnitPresentation;
  end;

implementation

{$R *.fmx}

constructor TFrameChannelProperties.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
end;

function TFrameChannelProperties.AddCategory(const ACaption: string): TTreeViewItem;
begin
  Result := TTreeViewItem.Create(Self);
  Result.Parent := TreeInspector;
  Result.Text := ACaption;
  Result.StyledSettings := [];
  Result.TextSettings.Font.Style := [TFontStyle.fsBold];
  Result.TextSettings.FontColor := $FF2C2C2C;
  Result.IsExpanded := True;
  Result.Height := 30;
end;

function TFrameChannelProperties.AddPropertyRow(AParent: TTreeViewItem;
  const ACaption: string; AControl: TControl): TLabel;
var
  Item: TTreeViewItem;
  RowGrid: TGridPanelLayout;
begin
  Item := TTreeViewItem.Create(Self);
  Item.Parent := AParent;
  Item.Text := '';
  Item.Stored := False;
  Item.Height := 32;

  RowGrid := TGridPanelLayout.Create(Self);
  RowGrid.Parent := Item;
  RowGrid.Align := TAlignLayout.Client;
  RowGrid.RowCollection.Clear;
  RowGrid.ColumnCollection.Clear;
  RowGrid.ColumnCollection.Add.Value := 45;
  RowGrid.ColumnCollection.Add.Value := 55;
  RowGrid.RowCollection.Add.Value := 100;
  RowGrid.Stored := False;

  Result := TLabel.Create(Self);
  Result.Parent := RowGrid;
  Result.Align := TAlignLayout.Client;
  Result.Text := ACaption;
  Result.StyledSettings := [];
  Result.TextSettings.FontColor := $FF1F1F1F;
  Result.TextSettings.HorzAlign := TTextAlign.Leading;
  Result.TextSettings.VertAlign := TTextAlign.Center;
  Result.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  Result.HitTest := False;
  RowGrid.ControlCollection.AddControl(Result, 0, 0);

  AControl.Parent := RowGrid;
  AControl.Align := TAlignLayout.Client;
  AControl.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  AControl.HitTest := True;
  if AControl is TStyledControl then
    TStyledControl(AControl).TabStop := True;
  RowGrid.ControlCollection.AddControl(AControl, 1, 0);

end;

function TFrameChannelProperties.CreateEditCombo(
  const AItems: array of string): TComboEdit;
var
  I: Integer;
begin
  Result := TComboEdit.Create(Self);
  for I := Low(AItems) to High(AItems) do
    Result.Items.Add(AItems[I]);
end;

function TFrameChannelProperties.CreateComboBox(
  const AItems: array of string): TComboBox;
var
  I: Integer;
begin
  Result := TComboBox.Create(Self);
  for I := Low(AItems) to High(AItems) do
    Result.Items.Add(AItems[I]);
end;


function TFrameChannelProperties.CreateComboWithIndicator(ACombo: TComboBox; out AIndicator: TCircle): TControl;
var
  LWrap: TLayout;
begin
  LWrap := TLayout.Create(Self);
  LWrap.Stored := False;

  ACombo.Parent := LWrap;
  ACombo.Align := TAlignLayout.Client;
  ACombo.Margins.Right := 20;

  AIndicator := TCircle.Create(Self);
  AIndicator.Parent := LWrap;
  AIndicator.Align := TAlignLayout.Right;
  AIndicator.Width := 12;
  AIndicator.Height := 12;
  AIndicator.Margins.Rect := TRectF.Create(4, 8, 2, 8);
  AIndicator.Stored := False;
  AIndicator.HitTest := False;
  AIndicator.Stroke.Kind := TBrushKind.None;
  AIndicator.Fill.Color := TAlphaColors.Gray;

  Result := LWrap;
end;

procedure TFrameChannelProperties.ApplyIndicatorColor(AIndicator: TCircle; const AColor: TAlphaColor);
begin
  if AIndicator = nil then
    Exit;
  AIndicator.Fill.Color := AColor;
end;

procedure TFrameChannelProperties.RefreshRegisterColors;
begin
  if FChannel = nil then
  begin
    ApplyIndicatorColor(IndicatorOutputSet, TAlphaColors.Gray);
    ApplyIndicatorColor(IndicatorSyncMode, TAlphaColors.Gray);
    ApplyIndicatorColor(IndicatorNoiseFilter, TAlphaColors.Gray);
    Exit;
  end;

  ApplyIndicatorColor(IndicatorOutputSet, FChannel.GetOutputSetStateColor);
  ApplyIndicatorColor(IndicatorSyncMode, FChannel.GetSyncModeStateColor);
  ApplyIndicatorColor(IndicatorNoiseFilter, FChannel.GetNoiseFilterStateColor);
end;

procedure TFrameChannelProperties.HandleChannelTextExit(Sender: TObject);
var
  NewValue: string;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;
  NewValue := Trim(EditChannelText.Text);
  Changed := FChannel.Text <> NewValue;
  FChannel.Text := NewValue;
  EditChannelText.Text := NewValue;
  NotifyWorkTableRefreshIfChanged(Changed);
end;

procedure TFrameChannelProperties.HandleChannelNameExit(Sender: TObject);
var
  NewValue: string;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;
  NewValue := Trim(EditChannelName.Text);
  Changed := FChannel.Name <> NewValue;
  FChannel.Name := NewValue;
  EditChannelName.Text := NewValue;
  NotifyWorkTableRefreshIfChanged(Changed);
end;


procedure TFrameChannelProperties.HandleChannelGroupExit(Sender: TObject);
var
  NewValue: Integer;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;

  NewValue := StrToIntDef(Trim(EditChannelGroup.Text), FChannel.Group);
  Changed := FChannel.Group <> NewValue;
  FChannel.Group := NewValue;
  EditChannelGroup.Text := IntToStr(NewValue);
  NotifyWorkTableRefreshIfChanged(Changed);
end;


procedure TFrameChannelProperties.HandleQMaxWorkExit(Sender: TObject);
var
  NewValue: Double;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;
  NewValue := FlowToBase(NormalizeFloatInput(EditQMaxWork.Text));
  Changed := FChannel.QMaxWork <> NewValue;
  FChannel.QMaxWork := NewValue;
  EditQMaxWork.Text := FormatFlowWorkValue(FlowFromBase(NewValue));
  NotifyWorkTableRefreshIfChanged(Changed);
end;

procedure TFrameChannelProperties.HandleQMinWorkExit(Sender: TObject);
var
  NewValue: Double;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;
  NewValue := FlowToBase(NormalizeFloatInput(EditQMinWork.Text));
  Changed := FChannel.QMinWork <> NewValue;
  FChannel.QMinWork := NewValue;
  EditQMinWork.Text := FormatFlowWorkValue(FlowFromBase(NewValue));
  NotifyWorkTableRefreshIfChanged(Changed);
end;

procedure TFrameChannelProperties.HandleVMaxWorkExit(Sender: TObject);
var
  NewValue: Double;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;
  NewValue := NormalizeFloatInput(EditVMaxWork.Text);
  Changed := FChannel.VMaxWork <> NewValue;
  FChannel.VMaxWork := NewValue;
  EditVMaxWork.Text := FloatToStr(NewValue);
  NotifyWorkTableRefreshIfChanged(Changed);
end;

procedure TFrameChannelProperties.HandleVMinWorkExit(Sender: TObject);
var
  NewValue: Double;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) then
    Exit;
  NewValue := NormalizeFloatInput(EditVMinWork.Text);
  Changed := FChannel.VMinWork <> NewValue;
  FChannel.VMinWork := NewValue;
  EditVMinWork.Text := FloatToStr(NewValue);
  NotifyWorkTableRefreshIfChanged(Changed);
end;

procedure TFrameChannelProperties.HandleOutputSetChange(Sender: TObject);
var
  NewValue: EOutPutSet;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) or (ComboOutputSet = nil) then
    Exit;
  if ComboOutputSet.ItemIndex >= 0 then
  begin
    NewValue := EOutPutSet(ComboOutputSet.ItemIndex);
    Changed := FChannel.OutputSet <> NewValue;
    FChannel.OutputSet := NewValue;
    NotifyWorkTableRefreshIfChanged(Changed);
  end;
  RefreshRegisterColors;
end;

procedure TFrameChannelProperties.HandleSyncModeChange(Sender: TObject);
var
  NewValue: ESyncChannelMode;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) or (ComboSyncMode = nil) then
    Exit;
  if ComboSyncMode.ItemIndex >= 0 then
  begin
    NewValue := ESyncChannelMode(ComboSyncMode.ItemIndex);
    Changed := FChannel.SyncMode <> NewValue;
    FChannel.SyncMode := NewValue;
    NotifyWorkTableRefreshIfChanged(Changed);
  end;
  RefreshRegisterColors;
end;

procedure TFrameChannelProperties.HandleNoiseFilterChange(Sender: TObject);
var
  NewValue: Integer;
  Changed: Boolean;
begin
  if FLoading or (FChannel = nil) or (ComboNoiseFilter = nil) then
    Exit;
  if ComboNoiseFilter.ItemIndex >= 0 then
  begin
    NewValue := StrToNoiseFilter(ComboNoiseFilter.Items[ComboNoiseFilter.ItemIndex]);
    Changed := FChannel.NoiseFilter <> NewValue;
    FChannel.NoiseFilter := NewValue;
    NotifyWorkTableRefreshIfChanged(Changed);
  end;
  RefreshRegisterColors;
end;

function TFrameChannelProperties.GetChannelWorkTable: TWorkTable;
begin
  Result := nil;
  if (FChannel = nil) or (WorkTableManager = nil) then
    Exit;
  Result := WorkTableManager.FindWorkTableByID(FChannel.WorkTabeID);
end;

function TFrameChannelProperties.GetFlowUnitName: string;
var
  WorkTable: TWorkTable;
begin
  Result := 'л/с';
  WorkTable := GetChannelWorkTable;
  if WorkTable = nil then
    Exit;

  Result := Trim(WorkTable.FlowUnitName);
  if (Result = '') and (WorkTable.ValueFlowRate <> nil) then
    Result := WorkTable.ValueFlowRate.GetDimName;
  if Result = '' then
    Result := 'л/с';
end;

function TFrameChannelProperties.FlowFromBase(const AValueLSec: Double): Double;
var
  WorkTable: TWorkTable;
begin
  WorkTable := GetChannelWorkTable;
  if (WorkTable <> nil) and (WorkTable.ValueFlowRate <> nil) then
    Result := WorkTable.ValueFlowRate.GetDoubleNum(AValueLSec, GetFlowUnitName)
  else
    Result := AValueLSec;
end;

function TFrameChannelProperties.FlowToBase(const AValue: Double): Double;
var
  WorkTable: TWorkTable;
  DimIndex: Integer;
begin
  Result := AValue;
  WorkTable := GetChannelWorkTable;
  if (WorkTable = nil) or (WorkTable.ValueFlowRate = nil) then
    Exit;

  DimIndex := WorkTable.ValueFlowRate.GetDim(GetFlowUnitName);
  if DimIndex >= 0 then
    Result := WorkTable.ValueFlowRate.GetDoubleBaseNum(AValue, DimIndex);
end;

function TFrameChannelProperties.GetFlowFormatError: Double;
begin
  Result := 0;
  if (FChannel <> nil) and (FChannel.FlowMeter <> nil) then
  begin
    if FChannel.FlowMeter.ValueFlow <> nil then
      Result := FChannel.FlowMeter.ValueFlow.Error;
    if (Result <= 0) and (FChannel.FlowMeter.Device <> nil) then
      Result := FChannel.FlowMeter.Device.Error;
  end;
end;

function TFrameChannelProperties.FormatFlowWorkValue(const AValue: Double): string;
begin
  if AValue > 0 then
    Result := FormatByBaseError(AValue, GetFlowFormatError)
  else
    Result := FloatToStr(AValue);
end;

procedure TFrameChannelProperties.UpdateFlowUnitPresentation;
var
  FlowUnitName: string;
begin
  FlowUnitName := GetFlowUnitName;
  if LabelQMaxWork <> nil then
    LabelQMaxWork.Text := 'Q макс раб, ' + FlowUnitName;
  if LabelQMinWork <> nil then
    LabelQMinWork.Text := 'Q мин раб, ' + FlowUnitName;

  if FChannel = nil then
    Exit;

  EditQMaxWork.Text := FormatFlowWorkValue(FlowFromBase(FChannel.QMaxWork));
  EditQMinWork.Text := FormatFlowWorkValue(FlowFromBase(FChannel.QMinWork));
end;

procedure TFrameChannelProperties.NotifyWorkTableRefreshIfChanged(const AChanged: Boolean);
var
  WorkTable: TWorkTable;
begin
  if not AChanged then
    Exit;
  if (FChannel = nil) or (WorkTableManager = nil) then
    Exit;

  WorkTable := WorkTableManager.FindWorkTableByID(FChannel.WorkTabeID);
  if WorkTable <> nil then
    WorkTable.FireEvent(ewtRefresh);
end;


procedure TFrameChannelProperties.LoadFromChannel(AChannel: TChannel);
var
  SignalName: string;
begin
  FLoading := True;
  try
    FChannel := AChannel;
    if AChannel = nil then
    begin
      EditChannelText.Text := '';
      EditChannelName.Text := '';
      EditChannelGroup.Text := '';
      ComboChannelType.ItemIndex := -1;
      ComboOutputSet.ItemIndex := -1;
      ComboSyncMode.ItemIndex := -1;
      ComboNoiseFilter.ItemIndex := -1;
      LabelChannelHash.Text := '';
      EditQMaxWork.Text := '';
      EditQMinWork.Text := '';
      UpdateFlowUnitPresentation;
      EditVMaxWork.Text := '';
      EditVMinWork.Text := '';
      Exit;
    end;

    EditChannelText.Text := AChannel.Text;
    EditChannelName.Text := AChannel.Name;
    EditChannelGroup.Text := IntToStr(AChannel.Group);

    SignalName := GetOutputTypeName(TOutputType(AChannel.Signal));
    ComboChannelType.ItemIndex := ComboChannelType.Items.IndexOf(SignalName);
    if ComboChannelType.ItemIndex < 0 then
      ComboChannelType.ItemIndex := 0;

    ComboOutputSet.ItemIndex := Ord(AChannel.OutputSet);
    ComboSyncMode.ItemIndex := Ord(AChannel.SyncMode);
    ComboNoiseFilter.ItemIndex := ComboNoiseFilter.Items.IndexOf(NoiseFilterToStr(AChannel.NoiseFilter));

    LabelChannelHash.Text := AChannel.UUID;
    UpdateFlowUnitPresentation;
    EditVMaxWork.Text := FloatToStr(AChannel.VMaxWork);
    EditVMinWork.Text := FloatToStr(AChannel.VMinWork);
  finally
    FLoading := False;
    RefreshRegisterColors;
  end;
end;

procedure TFrameChannelProperties.BuildUI;
var
  CategoryGeneral: TTreeViewItem;
  CategoryFreqPulse: TTreeViewItem;
  CategoryAnalogCurrent: TTreeViewItem;
  CategoryAnalogVoltage: TTreeViewItem;
  CategoryRanges: TTreeViewItem;
begin
  LayoutRoot := TLayout.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;


  TreeInspector := TTreeView.Create(Self);
  TreeInspector.Parent := LayoutRoot;
  TreeInspector.Align := TAlignLayout.Client;
  TreeInspector.ShowCheckboxes := False;
  TreeInspector.ItemHeight := 32;
  TreeInspector.HitTest := True;
  TreeInspector.Stored := False;

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

  CategoryGeneral := AddCategory('Общий');
  EditChannelText := TEdit.Create(Self);
  AddPropertyRow(CategoryGeneral, 'Название канала', EditChannelText);
  EditChannelText.KillFocusByReturn:=True;
  EditChannelText.OnExit := HandleChannelTextExit;

  EditChannelName := TEdit.Create(Self);
  AddPropertyRow(CategoryGeneral, 'Имя канала', EditChannelName);
  EditChannelName.KillFocusByReturn:=True;
  EditChannelName.OnExit := HandleChannelNameExit;

  EditChannelGroup := TEdit.Create(Self);
  AddPropertyRow(CategoryGeneral, 'Группа каналов', EditChannelGroup);
  EditChannelGroup.KillFocusByReturn:=True;
  EditChannelGroup.OnExit := HandleChannelGroupExit;

  ComboChannelType := CreateComboBox(['Не задан', 'Частотный', 'Импульсный', 'Токовый', 'Напряжение']);
  AddPropertyRow(CategoryGeneral, 'Тип канала', ComboChannelType);

  CategoryRanges := AddCategory('Рабочие диапазоны');
  EditQMaxWork := TEdit.Create(Self);
  LabelQMaxWork := AddPropertyRow(CategoryRanges, 'Q макс раб, л/с', EditQMaxWork);
  EditQMaxWork.KillFocusByReturn := True;
  EditQMaxWork.OnExit := HandleQMaxWorkExit;

  EditQMinWork := TEdit.Create(Self);
  LabelQMinWork := AddPropertyRow(CategoryRanges, 'Q мин раб, л/с', EditQMinWork);
  EditQMinWork.KillFocusByReturn := True;
  EditQMinWork.OnExit := HandleQMinWorkExit;

  EditVMaxWork := TEdit.Create(Self);
  AddPropertyRow(CategoryRanges, 'V макс раб, м³', EditVMaxWork);
  EditVMaxWork.KillFocusByReturn := True;
  EditVMaxWork.OnExit := HandleVMaxWorkExit;

  EditVMinWork := TEdit.Create(Self);
  AddPropertyRow(CategoryRanges, 'V мин раб, м³', EditVMinWork);
  EditVMinWork.KillFocusByReturn := True;
  EditVMinWork.OnExit := HandleVMinWorkExit;

  LabelChannelHash := TLabel.Create(Self);
  LabelChannelHash.StyledSettings := [];
  LabelChannelHash.TextSettings.HorzAlign := TTextAlign.Leading;
  LabelChannelHash.TextSettings.VertAlign := TTextAlign.Center;
  AddPropertyRow(CategoryGeneral, 'HASH ', LabelChannelHash);

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

  CategoryFreqPulse := AddCategory('Частотно-импульсный сигнал');
  ComboOutputSet := CreateComboBox(['Авто', 'Пассивный', 'Активный', 'Активный высокоомный', 'Емкостной']);
  AddPropertyRow(CategoryFreqPulse, 'Тип выхода прибора', CreateComboWithIndicator(ComboOutputSet, IndicatorOutputSet));
  ComboOutputSet.OnChange := HandleOutputSetChange;
  ComboSyncMode := CreateComboBox(['Выкл', 'По фронту', 'По фронту + время']);
  AddPropertyRow(CategoryFreqPulse, 'Синхронизация', CreateComboWithIndicator(ComboSyncMode, IndicatorSyncMode));
  ComboSyncMode.OnChange := HandleSyncModeChange;
  ComboNoiseFilter := CreateComboBox(['Выкл', 'Авто', '10 мс', '50 мс', '100 мс']);
  AddPropertyRow(CategoryFreqPulse, 'Фильтр помех', CreateComboWithIndicator(ComboNoiseFilter, IndicatorNoiseFilter));
  ComboNoiseFilter.OnChange := HandleNoiseFilterChange;
  AddPropertyRow(CategoryFreqPulse, 'Усреднение', CreateComboBox(['Выкл', 'Авто', '2 сек', '4 сек']));
  AddPropertyRow(CategoryFreqPulse, 'Текущая частота, Гц', TLabel.Create(Self));
  AddPropertyRow(CategoryFreqPulse, 'Текущая длительность импульса', TLabel.Create(Self));
  AddPropertyRow(CategoryFreqPulse, 'Квадратичное отклонение, %', TLabel.Create(Self));
  AddPropertyRow(CategoryFreqPulse, 'Девиация, Гц', TLabel.Create(Self));

  CategoryAnalogCurrent := AddCategory('Аналоговый сигнал (ток)');
  AddPropertyRow(CategoryAnalogCurrent, 'Тип выхода прибора', CreateComboBox(['0..20мА', '4..20мА', '-20мА..20мА']));
  AddPropertyRow(CategoryAnalogCurrent, 'Усреднение', CreateComboBox(['Выкл', '2 сек', '4 сек']));
  AddPropertyRow(CategoryAnalogCurrent, 'Текущий ток', TLabel.Create(Self));
  AddPropertyRow(CategoryAnalogCurrent, 'Квадратичное отклонение, %', TLabel.Create(Self));
  AddPropertyRow(CategoryAnalogCurrent, 'Девиация, мА', TLabel.Create(Self));

  CategoryAnalogVoltage := AddCategory('Аналоговый сигнал (напряжение)');
  AddPropertyRow(CategoryAnalogVoltage, 'Тип выхода прибора', CreateComboBox(['0..10В', '1..10В', '-10В..10В']));
  AddPropertyRow(CategoryAnalogVoltage, 'Усреднение', CreateComboBox(['Выкл', '2 сек', '4 сек']));
  AddPropertyRow(CategoryAnalogVoltage, 'Текущий ток', TLabel.Create(Self));
  AddPropertyRow(CategoryAnalogVoltage, 'Квадратичное отклонение, %', TLabel.Create(Self));
  AddPropertyRow(CategoryAnalogVoltage, 'Девиация, В', TLabel.Create(Self));
end;

end.
