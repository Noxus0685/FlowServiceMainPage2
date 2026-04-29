unit frmChannelProperties;

interface

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
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes;

type
  TFrameChannelProperties = class(TFrame)
  private
    LayoutRoot: TLayout;
    HeaderGrid: TGridPanelLayout;
    TreeInspector: TTreeView;
    HeaderProperty: TLabel;
    HeaderValue: TLabel;
    HeaderDivider: TLine;

    function AddCategory(const ACaption: string): TTreeViewItem;
    function AddPropertyRow(AParent: TTreeViewItem; const ACaption: string;
      AControl: TControl): TLabel;
    function CreateEditCombo(const AItems: array of string): TComboEdit;
    procedure BuildUI;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

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
  Divider: TLine;
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

procedure TFrameChannelProperties.BuildUI;
var
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
  HeaderGrid.ColumnCollection.Add.Value := 45;
  HeaderGrid.ColumnCollection.Add.Value := 55;
  HeaderGrid.RowCollection.Add.Value := 100;

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

  TreeInspector := TTreeView.Create(Self);
  TreeInspector.Parent := LayoutRoot;
  TreeInspector.Align := TAlignLayout.Client;
  TreeInspector.ShowCheckboxes := False;
  TreeInspector.ItemHeight := 32;
  TreeInspector.HitTest := True;
  TreeInspector.Stored := False;

  CategoryFreqPulse := AddCategory('Частотно-импульсный сигнал');
  AddPropertyRow(CategoryFreqPulse, 'Тип выхода прибора', CreateEditCombo(['Авто', 'Пассивный (+Namur)', 'Активный', 'Универсальный', 'Емкостной']));
  AddPropertyRow(CategoryFreqPulse, 'Синхронизация', CreateEditCombo(['Выкл', 'По фронту', 'По фронту + время']));
  AddPropertyRow(CategoryFreqPulse, 'Фильтр помех', CreateEditCombo(['Выкл', 'Авто', '10 мс', '50 мс', '100 мс']));
  AddPropertyRow(CategoryFreqPulse, 'Усреднение', CreateEditCombo(['Выкл', 'Авто', '2 сек', '4 сек']));
  AddPropertyRow(CategoryFreqPulse, 'Текущая частота, Гц', TEdit.Create(Self));
  AddPropertyRow(CategoryFreqPulse, 'Текущая длительность импульса', TEdit.Create(Self));
  AddPropertyRow(CategoryFreqPulse, 'Квадратичное отклонение, %', TEdit.Create(Self));
  AddPropertyRow(CategoryFreqPulse, 'Девиация, Гц', TEdit.Create(Self));

  CategoryAnalogCurrent := AddCategory('Аналоговый сигнал (ток)');
  AddPropertyRow(CategoryAnalogCurrent, 'Тип выхода прибора', CreateEditCombo(['0..20мА', '4..20мА', '-20мА..20мА']));
  AddPropertyRow(CategoryAnalogCurrent, 'Усреднение', CreateEditCombo(['Выкл', '2 сек', '4 сек']));
  AddPropertyRow(CategoryAnalogCurrent, 'Текущий ток', TEdit.Create(Self));
  AddPropertyRow(CategoryAnalogCurrent, 'Квадратичное отклонение, %', TEdit.Create(Self));
  AddPropertyRow(CategoryAnalogCurrent, 'Девиация, мА', TEdit.Create(Self));

  CategoryAnalogVoltage := AddCategory('Аналоговый сигнал (напряжение)');
  AddPropertyRow(CategoryAnalogVoltage, 'Тип выхода прибора', CreateEditCombo(['0..10В', '1..10В', '-10В..10В']));
  AddPropertyRow(CategoryAnalogVoltage, 'Усреднение', CreateEditCombo(['Выкл', '2 сек', '4 сек']));
  AddPropertyRow(CategoryAnalogVoltage, 'Текущий ток', TEdit.Create(Self));
  AddPropertyRow(CategoryAnalogVoltage, 'Квадратичное отклонение, %', TEdit.Create(Self));
  AddPropertyRow(CategoryAnalogVoltage, 'Девиация, В', TEdit.Create(Self));
end;

end.
