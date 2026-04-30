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
  System.Generics.Collections,
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
    HeaderPropertyLayout: TLayout;
    HeaderSplitter: TSplitter;
    TreeInspector: TTreeView;
    HeaderProperty: TLabel;
    HeaderValue: TLabel;
    HeaderDivider: TLine;
    EditChannelName: TEdit;
    ComboChannelType: TComboBox;
    ComboOutputSet: TComboBox;
    ComboSyncMode: TComboBox;
    ComboNoiseFilter: TComboBox;
    IndicatorOutputSet: TCircle;
    IndicatorSyncMode: TCircle;
    IndicatorNoiseFilter: TCircle;
    LabelChannelHash: TLabel;
    FChannel: TChannel;
    FLoading: Boolean;
    FPropertyColumnWidth: Single;
    FPropertyLabels: TObjectList<TControl>;
    FValueControls: TObjectList<TControl>;
    FRowSplitters: TObjectList<TSplitter>;

    function AddCategory(const ACaption: string): TTreeViewItem;
    function AddPropertyRow(AParent: TTreeViewItem; const ACaption: string;
      AControl: TControl): TLabel;
    function CreateEditCombo(const AItems: array of string): TComboEdit;
    procedure BuildUI;
    function CreateComboBox(const AItems: array of string): TComboBox;
    function CreateComboWithIndicator(ACombo: TComboBox; out AIndicator: TCircle): TControl;
    procedure ApplyIndicatorColor(AIndicator: TCircle; const AColor: TAlphaColor);
    procedure RefreshRegisterColors;
    procedure HandleChannelNameChange(Sender: TObject);
    procedure HandleOutputSetChange(Sender: TObject);
    procedure HandleSyncModeChange(Sender: TObject);
    procedure HandleNoiseFilterChange(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromChannel(AChannel: TChannel);
  end;

implementation

{$R *.fmx}

constructor TFrameChannelProperties.Create(AOwner: TComponent);
begin
  inherited;
  FPropertyColumnWidth := 170;
  FPropertyLabels := TObjectList<TControl>.Create(False);
  FValueControls := TObjectList<TControl>.Create(False);
  FRowSplitters := TObjectList<TSplitter>.Create(False);
  BuildUI;
end;

destructor TFrameChannelProperties.Destroy;
begin
  FRowSplitters.Free;
  FValueControls.Free;
  FPropertyLabels.Free;
  inherited;
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
  Divider: TLine;
  Splitter: TSplitter;
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
  RowGrid.ColumnCollection.Add.Value := FPropertyColumnWidth;
  RowGrid.ColumnCollection.Add.Value := 8;
  RowGrid.ColumnCollection.Add.Value := 100;
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
  RowGrid.ControlCollection.AddControl(AControl, 2, 0);
  FValueControls.Add(AControl);

  Divider := TLine.Create(Self);
  Divider.Parent := Item;
  Divider.Align := TAlignLayout.Bottom;
  Divider.Height := 1;
  Divider.LineType := TLineType.Bottom;
  Divider.Stroke.Color := $FFEBEBEB;
  Divider.Stored := False;
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

procedure TFrameChannelProperties.HandleChannelNameChange(Sender: TObject);
begin
  if FLoading or (FChannel = nil) then
    Exit;
  FChannel.Text := Trim(EditChannelName.Text);
end;

procedure TFrameChannelProperties.HandleOutputSetChange(Sender: TObject);
begin
  if FLoading or (FChannel = nil) or (ComboOutputSet = nil) then
    Exit;
  if ComboOutputSet.ItemIndex >= 0 then
    FChannel.OutputSet := EOutPutSet(ComboOutputSet.ItemIndex);
  RefreshRegisterColors;
end;

procedure TFrameChannelProperties.HandleSyncModeChange(Sender: TObject);
begin
  if FLoading or (FChannel = nil) or (ComboSyncMode = nil) then
    Exit;
  if ComboSyncMode.ItemIndex >= 0 then
    FChannel.SyncMode := ESyncChannelMode(ComboSyncMode.ItemIndex);
  RefreshRegisterColors;
end;

procedure TFrameChannelProperties.HandleNoiseFilterChange(Sender: TObject);
begin
  if FLoading or (FChannel = nil) or (ComboNoiseFilter = nil) then
    Exit;
  if ComboNoiseFilter.ItemIndex >= 0 then
    FChannel.NoiseFilter := StrToNoiseFilter(ComboNoiseFilter.Items[ComboNoiseFilter.ItemIndex]);
  RefreshRegisterColors;
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
      EditChannelName.Text := '';
      ComboChannelType.ItemIndex := -1;
      ComboOutputSet.ItemIndex := -1;
      ComboSyncMode.ItemIndex := -1;
      ComboNoiseFilter.ItemIndex := -1;
      LabelChannelHash.Text := '';
      Exit;
    end;

    EditChannelName.Text := AChannel.Text;

    SignalName := GetOutputTypeName(TOutputType(AChannel.Signal));
    ComboChannelType.ItemIndex := ComboChannelType.Items.IndexOf(SignalName);
    if ComboChannelType.ItemIndex < 0 then
      ComboChannelType.ItemIndex := 0;

    ComboOutputSet.ItemIndex := Ord(AChannel.OutputSet);
    ComboSyncMode.ItemIndex := Ord(AChannel.SyncMode);
    ComboNoiseFilter.ItemIndex := ComboNoiseFilter.Items.IndexOf(NoiseFilterToStr(AChannel.NoiseFilter));

    LabelChannelHash.Text := AChannel.UUID;
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
begin
  LayoutRoot := TLayout.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(6, 6, 6, 6);

  HeaderGrid := TGridPanelLayout.Create(Self);
  HeaderGrid.Parent := LayoutRoot;
  HeaderGrid.Align := TAlignLayout.Top;
  HeaderGrid.Height := 30;
  HeaderGrid.RowCollection.Clear;
  HeaderGrid.ColumnCollection.Clear;
  HeaderGrid.ColumnCollection.Add.Value := 100;
  HeaderGrid.RowCollection.Add.Value := 100;

  HeaderPropertyLayout := TLayout.Create(Self);
  HeaderPropertyLayout.Parent := HeaderGrid;
  HeaderPropertyLayout.Align := TAlignLayout.Left;
  HeaderPropertyLayout.Width := FPropertyColumnWidth;
  HeaderGrid.ControlCollection.AddControl(HeaderPropertyLayout, 0, 0);

  HeaderProperty := TLabel.Create(Self);
  HeaderProperty.Parent := HeaderPropertyLayout;
  HeaderProperty.Align := TAlignLayout.Client;
  HeaderProperty.Text := 'Свойство';
  HeaderProperty.StyledSettings := [];
  HeaderProperty.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderProperty.TextSettings.FontColor := $FF3D3D3D;
  HeaderProperty.Margins.Rect := TRectF.Create(10, 0, 8, 0);
  HeaderSplitter := TSplitter.Create(Self);
  HeaderSplitter.Parent := HeaderGrid;
  HeaderSplitter.Align := TAlignLayout.Left;
  HeaderSplitter.Width := 8;
  HeaderGrid.ControlCollection.AddControl(HeaderSplitter, 0, 0);

  HeaderValue := TLabel.Create(Self);
  HeaderValue.Parent := HeaderGrid;
  HeaderValue.Align := TAlignLayout.Client;
  HeaderValue.Text := 'Значение';
  HeaderValue.StyledSettings := [];
  HeaderValue.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderValue.TextSettings.FontColor := $FF3D3D3D;
  HeaderValue.Margins.Rect := TRectF.Create(8, 0, 10, 0);
  HeaderGrid.ControlCollection.AddControl(HeaderValue, 1, 0);

  CategoryGeneral := AddCategory('Общий');
  EditChannelName := TEdit.Create(Self);
  AddPropertyRow(CategoryGeneral, 'Имя канала', EditChannelName);
  EditChannelName.OnChangeTracking := HandleChannelNameChange;

  ComboChannelType := CreateComboBox(['Не задан', 'Частотный', 'Импульсный', 'Токовый', 'Напряжение']);
  AddPropertyRow(CategoryGeneral, 'Тип канала', ComboChannelType);

  LabelChannelHash := TLabel.Create(Self);
  LabelChannelHash.StyledSettings := [];
  LabelChannelHash.TextSettings.HorzAlign := TTextAlign.Leading;
  LabelChannelHash.TextSettings.VertAlign := TTextAlign.Center;
  AddPropertyRow(CategoryGeneral, 'HASH канала', LabelChannelHash);

  HeaderDivider := TLine.Create(Self);
  HeaderDivider.Parent := LayoutRoot;
  HeaderDivider.Align := TAlignLayout.Top;
  HeaderDivider.Height := 1;
  HeaderDivider.LineType := TLineType.Bottom;
  HeaderDivider.Stroke.Color := $FFCDCDCD;
  HeaderDivider.Stored := False;

  TreeInspector := TTreeView.Create(Self);
  TreeInspector.Parent := LayoutRoot;
  TreeInspector.Align := TAlignLayout.Client;
  TreeInspector.ShowCheckboxes := False;
  TreeInspector.ItemHeight := 32;
  TreeInspector.HitTest := True;
  TreeInspector.Stored := False;

  CategoryFreqPulse := AddCategory('Частотно-импульсный сигнал');
  ComboOutputSet := CreateComboBox(['Авто', 'Пассивный', 'Активный', 'Универсальный', 'Емкостной']);
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
