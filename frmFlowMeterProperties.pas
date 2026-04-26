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
    GridProps: TGridPanelLayout;

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

    procedure BuildUI;
    procedure UpdateHeaders;
    procedure UpdateControls;
    procedure BuildInspectorHeader;
    procedure BuildRowBackground(ARow: Integer; AColor: TAlphaColor);

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

  function MakePropertyName(const AText: string): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := GridProps;
    Result.Text := AText;
    Result.StyledSettings := [];
    Result.TextSettings.Font.Style := [];
    Result.TextSettings.FontColor := $FF1F1F1F;
    Result.TextSettings.HorzAlign := TTextAlign.Leading;
    Result.TextSettings.VertAlign := TTextAlign.Center;
    Result.Align := TAlignLayout.Client;
    Result.Margins.Rect := TRectF.Create(8, 2, 8, 2);
  end;

  function MakeEdit(AOnExit: TNotifyEvent): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := GridProps;
    Result.Align := TAlignLayout.Client;
    Result.Margins.Rect := TRectF.Create(6, 2, 6, 2);
    Result.TextPrompt := '';
    Result.HitTest := True;
    Result.TabStop := True;
    Result.OnExit := AOnExit;
  end;

begin
  LayoutRoot := TLayout.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(6, 6, 6, 6);

  GridProps := TGridPanelLayout.Create(Self);
  GridProps.Parent := LayoutRoot;
  GridProps.Align := TAlignLayout.Top;
  GridProps.Height := 278;
  GridProps.RowCollection.Clear;
  GridProps.ColumnCollection.Clear;

  GridProps.ColumnCollection.Add.Value := 44;
  GridProps.ColumnCollection.Add.Value := 56;

  GridProps.RowCollection.Add.Value := 30;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;
  GridProps.RowCollection.Add.Value := 31;

  BuildInspectorHeader;
  BuildRowBackground(1, $FFF8F8F8);
  BuildRowBackground(2, $FFFFFFFF);
  BuildRowBackground(3, $FFF8F8F8);
  BuildRowBackground(4, $FFFFFFFF);
  BuildRowBackground(5, $FFF8F8F8);
  BuildRowBackground(6, $FFFFFFFF);
  BuildRowBackground(7, $FFF8F8F8);
  BuildRowBackground(8, $FFFFFFFF);

  LabelDeviceName := MakePropertyName('Имя');
  LabelDeviceTypeName := MakePropertyName('Тип');
  LabelSerialNumber := MakePropertyName('Серийный номер');
  LabelOutputType := MakePropertyName('Тип выхода');
  LabelFlowMax := MakePropertyName('Q макс');
  LabelFlowMin := MakePropertyName('Q мин');
  LabelQuantityMax := MakePropertyName('V макс');
  LabelQuantityMin := MakePropertyName('V мин');
  GridProps.ControlCollection.AddControl(LabelDeviceName, 0, 1);
  GridProps.ControlCollection.AddControl(LabelDeviceTypeName, 0, 2);
  GridProps.ControlCollection.AddControl(LabelSerialNumber, 0, 3);
  GridProps.ControlCollection.AddControl(LabelOutputType, 0, 4);
  GridProps.ControlCollection.AddControl(LabelFlowMax, 0, 5);
  GridProps.ControlCollection.AddControl(LabelFlowMin, 0, 6);
  GridProps.ControlCollection.AddControl(LabelQuantityMax, 0, 7);
  GridProps.ControlCollection.AddControl(LabelQuantityMin, 0, 8);

  EditDeviceName := MakeEdit(EditDeviceNameExit);
  EditDeviceTypeName := MakeEdit(EditDeviceTypeNameExit);
  EditSerialNumber := MakeEdit(EditSerialNumberExit);
  GridProps.ControlCollection.AddControl(EditDeviceName, 1, 1);
  GridProps.ControlCollection.AddControl(EditDeviceTypeName, 1, 2);
  GridProps.ControlCollection.AddControl(EditSerialNumber, 1, 3);

  ComboOutputType := TComboBox.Create(Self);
  ComboOutputType.Parent := GridProps;
  ComboOutputType.Align := TAlignLayout.Client;
  ComboOutputType.Margins.Rect := TRectF.Create(6, 2, 6, 2);
  ComboOutputType.Items.Add('Частота');
  ComboOutputType.Items.Add('Импульсы');
  ComboOutputType.Items.Add('Напряжение');
  ComboOutputType.Items.Add('Ток');
  ComboOutputType.Items.Add('Интерфейс');
  ComboOutputType.Items.Add('Визуальный');
  ComboOutputType.OnChange := ComboOutputTypeChange;
  GridProps.ControlCollection.AddControl(ComboOutputType, 1, 4);

  EditFlowMax := MakeEdit(EditFlowMaxExit);
  EditFlowMin := MakeEdit(EditFlowMinExit);
  EditQuantityMax := MakeEdit(EditQuantityMaxExit);
  EditQuantityMin := MakeEdit(EditQuantityMinExit);
  GridProps.ControlCollection.AddControl(EditFlowMax, 1, 5);
  GridProps.ControlCollection.AddControl(EditFlowMin, 1, 6);
  GridProps.ControlCollection.AddControl(EditQuantityMax, 1, 7);
  GridProps.ControlCollection.AddControl(EditQuantityMin, 1, 8);
end;

procedure TFrameFlowMeterProperties.BuildInspectorHeader;
begin
  HeaderProperty := TLabel.Create(Self);
  HeaderProperty.Parent := GridProps;
  HeaderProperty.Align := TAlignLayout.Client;
  HeaderProperty.Text := 'Свойство';
  HeaderProperty.StyledSettings := [];
  HeaderProperty.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderProperty.TextSettings.FontColor := $FF3D3D3D;
  HeaderProperty.Margins.Rect := TRectF.Create(8, 0, 8, 0);
  GridProps.ControlCollection.AddControl(HeaderProperty, 0, 0);

  HeaderValue := TLabel.Create(Self);
  HeaderValue.Parent := GridProps;
  HeaderValue.Align := TAlignLayout.Client;
  HeaderValue.Text := 'Значение';
  HeaderValue.StyledSettings := [];
  HeaderValue.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderValue.TextSettings.FontColor := $FF3D3D3D;
  HeaderValue.Margins.Rect := TRectF.Create(8, 0, 8, 0);
  GridProps.ControlCollection.AddControl(HeaderValue, 1, 0);
end;

procedure TFrameFlowMeterProperties.BuildRowBackground(ARow: Integer; AColor: TAlphaColor);
var
  LeftRect, RightRect: TRectangle;
begin
  LeftRect := TRectangle.Create(Self);
  LeftRect.Parent := GridProps;
  LeftRect.Fill.Color := AColor;
  LeftRect.Stroke.Kind := TBrushKind.None;
  LeftRect.HitTest := False;
  LeftRect.Align := TAlignLayout.Client;
  LeftRect.SendToBack;
  GridProps.ControlCollection.AddControl(LeftRect, 0, ARow);

  RightRect := TRectangle.Create(Self);
  RightRect.Parent := GridProps;
  RightRect.Fill.Color := AColor;
  RightRect.Stroke.Kind := TBrushKind.None;
  RightRect.HitTest := False;
  RightRect.Align := TAlignLayout.Client;
  RightRect.SendToBack;
  GridProps.ControlCollection.AddControl(RightRect, 1, ARow);
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
