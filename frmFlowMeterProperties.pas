unit frmFlowMeterProperties;

interface

uses
  FMX.Controls,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
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
  System.Variants,
  uClasses,
  uFlowMeter;

type
  TFrameFlowMeterProperties = class(TFrame)
  private
    FFlowMeter: TFlowMeter;
    FIsLoading: Boolean;

    LayoutRoot: TLayout;
    HeaderGrid: TGridPanelLayout;
    TreeInspector: TTreeView;
    CategoryMain: TTreeViewItem;
    CategoryRanges: TTreeViewItem;

    LabelDeviceName: TLabel;
    LabelDeviceTypeName: TLabel;
    LabelSerialNumber: TLabel;
    LabelOutputType: TLabel;
    LabelFlowMax: TLabel;
    LabelFlowMin: TLabel;
    LabelQuantityMax: TLabel;
    LabelQuantityMin: TLabel;

    EditDeviceName: TEdit;
    EditDeviceTypeName: TEdit;
    EditSerialNumber: TEdit;
    ComboOutputType: TComboBox;
    EditFlowMax: TEdit;
    EditFlowMin: TEdit;
    EditQuantityMax: TEdit;
    EditQuantityMin: TEdit;
    HeaderProperty: TLabel;
    HeaderValue: TLabel;
    HeaderDivider: TLine;

    procedure BuildUI;
    procedure UpdateHeaders;
    procedure UpdateControls;
    function AddCategory(const ACaption: string): TTreeViewItem;
    function AddPropertyRow(AParent: TTreeViewItem; const ACaption: string;
      AControl: TControl; const AHint: string = ''): TLabel;

    procedure EditDeviceNameExit(Sender: TObject);
    procedure EditDeviceTypeNameExit(Sender: TObject);
    procedure EditSerialNumberExit(Sender: TObject);
    procedure ComboOutputTypeChange(Sender: TObject);
    procedure EditFlowMaxExit(Sender: TObject);
    procedure EditFlowMinExit(Sender: TObject);
    procedure EditQuantityMaxExit(Sender: TObject);
    procedure EditQuantityMinExit(Sender: TObject);

    function GetOutputTypeIndex(AOutputType: Integer): Integer;
    function GetOutputTypeByIndex(AIndex: Integer): Integer;
    function GetFlowDimName: string;
    function GetQuantityDimName: string;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFlowMeter(AFlowMeter: TFlowMeter);
    property FlowMeter: TFlowMeter read FFlowMeter write SetFlowMeter;
  end;

implementation

uses
  uBaseProcedures;

{$R *.fmx}

{ TFrameFlowMeterProperties }

constructor TFrameFlowMeterProperties.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
  UpdateControls;
end;

procedure TFrameFlowMeterProperties.BuildUI;
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

  CategoryMain := AddCategory('Основные');
  CategoryRanges := AddCategory('Диапазоны');

  EditDeviceName := TEdit.Create(Self);
  EditDeviceName.OnExit := EditDeviceNameExit;
  LabelDeviceName := AddPropertyRow(CategoryMain, 'Имя', EditDeviceName);

  EditDeviceTypeName := TEdit.Create(Self);
  EditDeviceTypeName.OnExit := EditDeviceTypeNameExit;
  LabelDeviceTypeName := AddPropertyRow(CategoryMain, 'Тип', EditDeviceTypeName);

  EditSerialNumber := TEdit.Create(Self);
  EditSerialNumber.OnExit := EditSerialNumberExit;
  LabelSerialNumber := AddPropertyRow(CategoryMain, 'Серийный номер', EditSerialNumber);

  ComboOutputType := TComboBox.Create(Self);
  ComboOutputType.Items.Add('Частота');
  ComboOutputType.Items.Add('Импульсы');
  ComboOutputType.Items.Add('Напряжение');
  ComboOutputType.Items.Add('Ток');
  ComboOutputType.Items.Add('Интерфейс');
  ComboOutputType.Items.Add('Визуальный');
  ComboOutputType.OnChange := ComboOutputTypeChange;
  LabelOutputType := AddPropertyRow(CategoryMain, 'Тип выхода', ComboOutputType);

  EditFlowMax := TEdit.Create(Self);
  EditFlowMax.OnExit := EditFlowMaxExit;
  LabelFlowMax := AddPropertyRow(CategoryRanges, 'Q макс', EditFlowMax);

  EditFlowMin := TEdit.Create(Self);
  EditFlowMin.OnExit := EditFlowMinExit;
  LabelFlowMin := AddPropertyRow(CategoryRanges, 'Q мин', EditFlowMin);

  EditQuantityMax := TEdit.Create(Self);
  EditQuantityMax.OnExit := EditQuantityMaxExit;
  LabelQuantityMax := AddPropertyRow(CategoryRanges, 'V макс', EditQuantityMax);

  EditQuantityMin := TEdit.Create(Self);
  EditQuantityMin.OnExit := EditQuantityMinExit;
  LabelQuantityMin := AddPropertyRow(CategoryRanges, 'V мин', EditQuantityMin);
end;

function TFrameFlowMeterProperties.AddCategory(const ACaption: string): TTreeViewItem;
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

function TFrameFlowMeterProperties.AddPropertyRow(AParent: TTreeViewItem;
  const ACaption: string; AControl: TControl; const AHint: string): TLabel;
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
  if AHint <> '' then
    Result.Hint := AHint;
  RowGrid.ControlCollection.AddControl(Result, 0, 0);

  AControl.Parent := RowGrid;
  AControl.Align := TAlignLayout.Client;
  AControl.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  AControl.HitTest := True;
  if AControl is TStyledControl then
    TStyledControl(AControl).TabStop := True;
  if AHint <> '' then
    AControl.Hint := AHint;
  RowGrid.ControlCollection.AddControl(AControl, 1, 0);

  Divider := TLine.Create(Self);
  Divider.Parent := Item;
  Divider.Align := TAlignLayout.Bottom;
  Divider.Height := 1;
  Divider.LineType := TLineType.Bottom;
  Divider.Stroke.Color := $FFEBEBEB;
  Divider.Stored := False;
end;

procedure TFrameFlowMeterProperties.SetFlowMeter(AFlowMeter: TFlowMeter);
begin
  FFlowMeter := AFlowMeter;
  UpdateControls;
end;

function TFrameFlowMeterProperties.GetFlowDimName: string;
begin
  Result := '';
  if (FFlowMeter <> nil) and (FFlowMeter.ValueFlow <> nil) then
    Result := Trim(FFlowMeter.ValueFlow.GetDimName);
  if Result = '' then
    Result := 'ед.';
end;

function TFrameFlowMeterProperties.GetQuantityDimName: string;
begin
  Result := '';
  if (FFlowMeter <> nil) and (FFlowMeter.ValueQuantity <> nil) then
    Result := Trim(FFlowMeter.ValueQuantity.GetDimName);
  if Result = '' then
    Result := 'ед.';
end;

procedure TFrameFlowMeterProperties.UpdateHeaders;
begin
  LabelFlowMax.Text := 'Q макс, ' + GetFlowDimName;
  LabelFlowMin.Text := 'Q мин, ' + GetFlowDimName;
  LabelQuantityMax.Text := 'V макс, ' + GetQuantityDimName;
  LabelQuantityMin.Text := 'V мин, ' + GetQuantityDimName;

  EditFlowMax.Hint := 'Диапазон Q макс — максимум диапазона расхода';
  EditFlowMin.Hint := 'Диапазон Q мин — минимум диапазона расхода';
  EditQuantityMax.Hint := 'Диапазон V макс — максимум диапазона количества';
  EditQuantityMin.Hint := 'Диапазон V мин — минимум диапазона количества';
end;

function TFrameFlowMeterProperties.GetOutputTypeIndex(AOutputType: Integer): Integer;
begin
  case AOutputType of
    Ord(otFrequency): Result := 0;
    Ord(otImpulse): Result := 1;
    Ord(otVoltage): Result := 2;
    Ord(otCurrent): Result := 3;
    Ord(otInterface): Result := 4;
    Ord(otVisual): Result := 5;
  else
    Result := -1;
  end;
end;

function TFrameFlowMeterProperties.GetOutputTypeByIndex(AIndex: Integer): Integer;
begin
  case AIndex of
    0: Result := Ord(otFrequency);
    1: Result := Ord(otImpulse);
    2: Result := Ord(otVoltage);
    3: Result := Ord(otCurrent);
    4: Result := Ord(otInterface);
    5: Result := Ord(otVisual);
  else
    Result := Ord(otUnknown);
  end;
end;

procedure TFrameFlowMeterProperties.UpdateControls;
var
  Enabled: Boolean;
begin
  FIsLoading := True;
  try
    UpdateHeaders;

    Enabled := FFlowMeter <> nil;
    EditDeviceName.Enabled := Enabled;
    EditDeviceTypeName.Enabled := Enabled;
    EditSerialNumber.Enabled := Enabled;
    ComboOutputType.Enabled := Enabled;
    EditFlowMax.Enabled := Enabled;
    EditFlowMin.Enabled := Enabled;
    EditQuantityMax.Enabled := Enabled;
    EditQuantityMin.Enabled := Enabled;

    if not Enabled then
    begin
      EditDeviceName.Text := '';
      EditDeviceTypeName.Text := '';
      EditSerialNumber.Text := '';
      ComboOutputType.ItemIndex := -1;
      EditFlowMax.Text := '';
      EditFlowMin.Text := '';
      EditQuantityMax.Text := '';
      EditQuantityMin.Text := '';
      Exit;
    end;

    EditDeviceName.Text := Trim(FFlowMeter.DeviceName);
    EditDeviceTypeName.Text := Trim(FFlowMeter.DeviceTypeName);
    EditSerialNumber.Text := Trim(FFlowMeter.SerialNumber);
    ComboOutputType.ItemIndex := GetOutputTypeIndex(FFlowMeter.OutputType);

    EditFlowMax.Text := FloatToStr(FFlowMeter.FlowMax);
    EditFlowMin.Text := FloatToStr(FFlowMeter.FlowMin);
    EditQuantityMax.Text := FloatToStr(FFlowMeter.QuantityMax);
    EditQuantityMin.Text := FloatToStr(FFlowMeter.QuantityMin);
  finally
    FIsLoading := False;
  end;
end;

procedure TFrameFlowMeterProperties.EditDeviceNameExit(Sender: TObject);
var
  S: string;
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;
  S := Trim(EditDeviceName.Text);
  FFlowMeter.DeviceName := S;
  EditDeviceName.Text := S;
end;

procedure TFrameFlowMeterProperties.EditDeviceTypeNameExit(Sender: TObject);
var
  S: string;
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;
  S := Trim(EditDeviceTypeName.Text);
  FFlowMeter.DeviceTypeName := S;
  EditDeviceTypeName.Text := S;
end;

procedure TFrameFlowMeterProperties.EditSerialNumberExit(Sender: TObject);
var
  S: string;
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;
  S := Trim(EditSerialNumber.Text);
  FFlowMeter.SerialNumber := S;
  EditSerialNumber.Text := S;
end;

procedure TFrameFlowMeterProperties.ComboOutputTypeChange(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  if ComboOutputType.ItemIndex >= 0 then
    FFlowMeter.OutputType := GetOutputTypeByIndex(ComboOutputType.ItemIndex);
end;

procedure TFrameFlowMeterProperties.EditFlowMaxExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  FFlowMeter.FlowMax := NormalizeFloatInput(EditFlowMax.Text);
  EditFlowMax.Text := FloatToStr(FFlowMeter.FlowMax);
end;

procedure TFrameFlowMeterProperties.EditFlowMinExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  FFlowMeter.FlowMin := NormalizeFloatInput(EditFlowMin.Text);
  EditFlowMin.Text := FloatToStr(FFlowMeter.FlowMin);
end;

procedure TFrameFlowMeterProperties.EditQuantityMaxExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  FFlowMeter.QuantityMax := NormalizeFloatInput(EditQuantityMax.Text);
  EditQuantityMax.Text := FloatToStr(FFlowMeter.QuantityMax);
end;

procedure TFrameFlowMeterProperties.EditQuantityMinExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  FFlowMeter.QuantityMin := NormalizeFloatInput(EditQuantityMin.Text);
  EditQuantityMin.Text := FloatToStr(FFlowMeter.QuantityMin);
end;

end.
