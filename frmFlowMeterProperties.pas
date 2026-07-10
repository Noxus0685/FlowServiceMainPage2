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
  System.Math,
  uClasses,
  uDeviceClass,
  uFlowMeter;

type
  TFrameFlowMeterProperties = class(TFrame)
  private
    FFlowMeter: TFlowMeter;
    FDevice: TDevice;
    FIsLoading: Boolean;
    FOnChange: TNotifyEvent;

    LayoutRoot: TLayout;
    HeaderGrid: TGridPanelLayout;
    TreeInspector: TTreeView;
    CategoryMain: TTreeViewItem;
    CategoryRanges: TTreeViewItem;
    CategoryOutputSettings: TTreeViewItem;

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

    LabelFrequencyOutputSet: TLabel;
    LabelFrequency: TLabel;
    LabelFrequencyView: TLabel;
    LabelFrequencyFlowRate: TLabel;
    LabelImpulseOutputSet: TLabel;
    LabelImpulseCoef: TLabel;
    LabelImpulseCoefView: TLabel;
    LabelVoltageRange: TLabel;
    LabelVoltageQMin: TLabel;
    LabelVoltageQMax: TLabel;
    LabelCurrentRange: TLabel;
    LabelCurrentQMin: TLabel;
    LabelCurrentQMax: TLabel;
    LabelProtocol: TLabel;
    LabelDeviceAddress: TLabel;
    LabelBaudRate: TLabel;
    LabelParity: TLabel;
    LabelVisualInputType: TLabel;

    ComboBoxFrequencyOutputSet: TComboBox;
    EditFrequency: TEdit;
    ComboBoxFrequencyView: TComboBox;
    EditFrequencyFlowRate: TEdit;
    ComboBoxImpulseOutputSet: TComboBox;
    EditImpulseCoef: TEdit;
    ComboBoxImpulseCoefView: TComboBox;
    ComboBoxVoltageRange: TComboBox;
    EditVoltageQMin: TEdit;
    EditVoltageQMax: TEdit;
    ComboBoxCurrentRange: TComboBox;
    EditCurrentQMin: TEdit;
    EditCurrentQMax: TEdit;
    ComboBoxProtocol: TComboBox;
    EditDeviceAddress: TEdit;
    ComboBoxBaudRate: TComboBox;
    ComboBoxParity: TComboBox;
    ComboBoxVisualInputType: TComboBox;

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
    procedure OutputSetChange(Sender: TObject);
    procedure DimensionCoefChange(Sender: TObject);
    procedure EditFrequencyExit(Sender: TObject);
    procedure EditFrequencyFlowRateExit(Sender: TObject);
    procedure EditImpulseCoefExit(Sender: TObject);
    procedure ComboBoxVoltageRangeChange(Sender: TObject);
    procedure EditVoltageQMinExit(Sender: TObject);
    procedure EditVoltageQMaxExit(Sender: TObject);
    procedure ComboBoxCurrentRangeChange(Sender: TObject);
    procedure EditCurrentQMinExit(Sender: TObject);
    procedure EditCurrentQMaxExit(Sender: TObject);
    procedure ComboBoxProtocolChange(Sender: TObject);
    procedure EditDeviceAddressExit(Sender: TObject);
    procedure ComboBoxBaudRateChange(Sender: TObject);
    procedure ComboBoxParityChange(Sender: TObject);
    procedure ComboBoxVisualInputTypeChange(Sender: TObject);

    procedure LoadOutputSettings;
    procedure UpdateOutputSettingsVisibility;
    procedure ApplyWeightsOutputRestriction;
    procedure SetPropertyRowVisible(ALabel: TLabel; AVisible: Boolean);
    function ValidPositive(AValue: Double): Boolean;
    function DisplayedCoef: Double;

    function GetOutputTypeIndex(AOutputType: Integer): Integer;
    function GetOutputTypeByIndex(AIndex: Integer): Integer;
    function GetFlowDimName: string;
    function GetQuantityDimName: string;
    procedure NotifyChanged;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFlowMeter(AFlowMeter: TFlowMeter);
    property FlowMeter: TFlowMeter read FFlowMeter write SetFlowMeter;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
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
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

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

  TreeInspector := TTreeView.Create(Self);
  TreeInspector.Parent := LayoutRoot;
  TreeInspector.Align := TAlignLayout.Client;
  TreeInspector.ShowCheckboxes := False;
  TreeInspector.ItemHeight := 32;
  TreeInspector.HitTest := True;
  TreeInspector.Stored := False;

  CategoryMain := AddCategory('Основные');

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

  CategoryOutputSettings := AddCategory('Настройки выхода');

  ComboBoxFrequencyOutputSet := TComboBox.Create(Self);
  ComboBoxFrequencyOutputSet.Items.Add('Авто');
  ComboBoxFrequencyOutputSet.Items.Add('Пассивный');
  ComboBoxFrequencyOutputSet.Items.Add('Активный');
  ComboBoxFrequencyOutputSet.Items.Add('Активный высокоомный');
  ComboBoxFrequencyOutputSet.Items.Add('Емкостной');
  ComboBoxFrequencyOutputSet.OnChange := OutputSetChange;
  LabelFrequencyOutputSet := AddPropertyRow(CategoryOutputSettings, 'Тип выхода', ComboBoxFrequencyOutputSet);

  EditFrequency := TEdit.Create(Self);
  EditFrequency.OnExit := EditFrequencyExit;
  LabelFrequency := AddPropertyRow(CategoryOutputSettings, 'Частота, Гц', EditFrequency);

  ComboBoxFrequencyView := TComboBox.Create(Self);
  ComboBoxFrequencyView.Items.Add('имп/л');
  ComboBoxFrequencyView.Items.Add('л/имп');
  ComboBoxFrequencyView.OnChange := DimensionCoefChange;
  LabelFrequencyView := AddPropertyRow(CategoryOutputSettings, 'Представление', ComboBoxFrequencyView);

  EditFrequencyFlowRate := TEdit.Create(Self);
  EditFrequencyFlowRate.OnExit := EditFrequencyFlowRateExit;
  LabelFrequencyFlowRate := AddPropertyRow(CategoryOutputSettings, 'Расход QF', EditFrequencyFlowRate);

  ComboBoxImpulseOutputSet := TComboBox.Create(Self);
  ComboBoxImpulseOutputSet.Items.Assign(ComboBoxFrequencyOutputSet.Items);
  ComboBoxImpulseOutputSet.OnChange := OutputSetChange;
  LabelImpulseOutputSet := AddPropertyRow(CategoryOutputSettings, 'Тип выхода', ComboBoxImpulseOutputSet);

  EditImpulseCoef := TEdit.Create(Self);
  EditImpulseCoef.OnExit := EditImpulseCoefExit;
  LabelImpulseCoef := AddPropertyRow(CategoryOutputSettings, 'Коэффициент импульса', EditImpulseCoef);

  ComboBoxImpulseCoefView := TComboBox.Create(Self);
  ComboBoxImpulseCoefView.Items.Assign(ComboBoxFrequencyView.Items);
  ComboBoxImpulseCoefView.OnChange := DimensionCoefChange;
  LabelImpulseCoefView := AddPropertyRow(CategoryOutputSettings, 'Представление', ComboBoxImpulseCoefView);

  ComboBoxVoltageRange := TComboBox.Create(Self);
  ComboBoxVoltageRange.Items.Add('0..10 В');
  ComboBoxVoltageRange.Items.Add('Другой');
  ComboBoxVoltageRange.OnChange := ComboBoxVoltageRangeChange;
  LabelVoltageRange := AddPropertyRow(CategoryOutputSettings, 'Диапазон напряжения', ComboBoxVoltageRange);
  EditVoltageQMin := TEdit.Create(Self); EditVoltageQMin.OnExit := EditVoltageQMinExit;
  LabelVoltageQMin := AddPropertyRow(CategoryOutputSettings, 'Q мин', EditVoltageQMin);
  EditVoltageQMax := TEdit.Create(Self); EditVoltageQMax.OnExit := EditVoltageQMaxExit;
  LabelVoltageQMax := AddPropertyRow(CategoryOutputSettings, 'Q макс', EditVoltageQMax);

  ComboBoxCurrentRange := TComboBox.Create(Self);
  ComboBoxCurrentRange.Items.Add('0..5 мА'); ComboBoxCurrentRange.Items.Add('0..20 мА');
  ComboBoxCurrentRange.Items.Add('4..20 мА'); ComboBoxCurrentRange.Items.Add('Другой');
  ComboBoxCurrentRange.OnChange := ComboBoxCurrentRangeChange;
  LabelCurrentRange := AddPropertyRow(CategoryOutputSettings, 'Диапазон тока', ComboBoxCurrentRange);
  EditCurrentQMin := TEdit.Create(Self); EditCurrentQMin.OnExit := EditCurrentQMinExit;
  LabelCurrentQMin := AddPropertyRow(CategoryOutputSettings, 'Q мин', EditCurrentQMin);
  EditCurrentQMax := TEdit.Create(Self); EditCurrentQMax.OnExit := EditCurrentQMaxExit;
  LabelCurrentQMax := AddPropertyRow(CategoryOutputSettings, 'Q макс', EditCurrentQMax);

  ComboBoxProtocol := TComboBox.Create(Self); ComboBoxProtocol.OnChange := ComboBoxProtocolChange;
  LabelProtocol := AddPropertyRow(CategoryOutputSettings, 'Библиотека / протокол', ComboBoxProtocol);
  EditDeviceAddress := TEdit.Create(Self); EditDeviceAddress.OnExit := EditDeviceAddressExit;
  LabelDeviceAddress := AddPropertyRow(CategoryOutputSettings, 'Адрес прибора', EditDeviceAddress);
  ComboBoxBaudRate := TComboBox.Create(Self);
  ComboBoxBaudRate.Items.Add('2400'); ComboBoxBaudRate.Items.Add('4800'); ComboBoxBaudRate.Items.Add('9600'); ComboBoxBaudRate.Items.Add('19200'); ComboBoxBaudRate.Items.Add('115200');
  ComboBoxBaudRate.OnChange := ComboBoxBaudRateChange;
  LabelBaudRate := AddPropertyRow(CategoryOutputSettings, 'Скорость передачи', ComboBoxBaudRate);
  ComboBoxParity := TComboBox.Create(Self); ComboBoxParity.Items.Add('Нет'); ComboBoxParity.Items.Add('Четность'); ComboBoxParity.Items.Add('Нечетность'); ComboBoxParity.OnChange := ComboBoxParityChange;
  LabelParity := AddPropertyRow(CategoryOutputSettings, 'Чётность', ComboBoxParity);

  ComboBoxVisualInputType := TComboBox.Create(Self); ComboBoxVisualInputType.Items.Add('Ручной'); ComboBoxVisualInputType.Items.Add('Фотофиксация'); ComboBoxVisualInputType.OnChange := ComboBoxVisualInputTypeChange;
  LabelVisualInputType := AddPropertyRow(CategoryOutputSettings, 'Режим ввода', ComboBoxVisualInputType);
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

end;

procedure TFrameFlowMeterProperties.SetFlowMeter(AFlowMeter: TFlowMeter);
begin
  FFlowMeter := AFlowMeter;
  UpdateControls;
end;

procedure TFrameFlowMeterProperties.NotifyChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
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
end;

function TFrameFlowMeterProperties.GetOutputTypeIndex(AOutputType: Integer): Integer;
begin
  if (FFlowMeter <> nil) and (FFlowMeter.MeterFlowCategory = mftWeightsType) then
  begin
    case AOutputType of
      Ord(otInterface): Exit(0);
      Ord(otVisual): Exit(1);
    else
      Exit(-1);
    end;
  end;

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
  if (FFlowMeter <> nil) and (FFlowMeter.MeterFlowCategory = mftWeightsType) then
  begin
    case AIndex of
      0: Exit(Ord(otInterface));
      1: Exit(Ord(otVisual));
    else
      Exit(Ord(otUnknown));
    end;
  end;

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

    FDevice := nil;
    if FFlowMeter <> nil then
      FDevice := FFlowMeter.Device;
    ApplyWeightsOutputRestriction;

    Enabled := (FFlowMeter <> nil) and (FDevice <> nil);
    EditDeviceName.Enabled := Enabled;
    EditDeviceTypeName.Enabled := Enabled;
    EditSerialNumber.Enabled := Enabled;
    ComboOutputType.Enabled := Enabled;

    if not Enabled then
    begin
      EditDeviceName.Text := '';
      EditDeviceTypeName.Text := '';
      EditSerialNumber.Text := '';
      ComboOutputType.ItemIndex := -1;
      UpdateOutputSettingsVisibility;
      Exit;
    end;

    EditDeviceName.Text := Trim(FFlowMeter.DeviceName);
    EditDeviceTypeName.Text := Trim(FFlowMeter.DeviceTypeName);
    EditSerialNumber.Text := Trim(FFlowMeter.SerialNumber);
    ComboOutputType.ItemIndex := GetOutputTypeIndex(FDevice.OutputType);
    LoadOutputSettings;
    UpdateOutputSettingsVisibility;

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
  if FFlowMeter.DeviceName = S then
    Exit;
  FFlowMeter.DeviceName := S;
  EditDeviceName.Text := S;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditDeviceTypeNameExit(Sender: TObject);
var
  S: string;
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;
  S := Trim(EditDeviceTypeName.Text);
  if FFlowMeter.DeviceTypeName = S then
    Exit;
  FFlowMeter.DeviceTypeName := S;
  EditDeviceTypeName.Text := S;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditSerialNumberExit(Sender: TObject);
var
  S: string;
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;
  S := Trim(EditSerialNumber.Text);
  if FFlowMeter.SerialNumber = S then
    Exit;
  FFlowMeter.SerialNumber := S;
  EditSerialNumber.Text := S;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.ComboOutputTypeChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then
    Exit;

  if ComboOutputType.ItemIndex >= 0 then
  begin
    if FDevice.OutputType = GetOutputTypeByIndex(ComboOutputType.ItemIndex) then
      Exit;
    FDevice.OutputType := GetOutputTypeByIndex(ComboOutputType.ItemIndex);
    FFlowMeter.OutputType := FDevice.OutputType;
    UpdateOutputSettingsVisibility;
    LoadOutputSettings;
    NotifyChanged;
  end;
end;

procedure TFrameFlowMeterProperties.EditFlowMaxExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  if FFlowMeter.FlowMax = NormalizeFloatInput(EditFlowMax.Text) then
    Exit;
  FFlowMeter.FlowMax := NormalizeFloatInput(EditFlowMax.Text);
  EditFlowMax.Text := FloatToStr(FFlowMeter.FlowMax);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFlowMinExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  if FFlowMeter.FlowMin = NormalizeFloatInput(EditFlowMin.Text) then
    Exit;
  FFlowMeter.FlowMin := NormalizeFloatInput(EditFlowMin.Text);
  EditFlowMin.Text := FloatToStr(FFlowMeter.FlowMin);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditQuantityMaxExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  if FFlowMeter.QuantityMax = NormalizeFloatInput(EditQuantityMax.Text) then
    Exit;
  FFlowMeter.QuantityMax := NormalizeFloatInput(EditQuantityMax.Text);
  EditQuantityMax.Text := FloatToStr(FFlowMeter.QuantityMax);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditQuantityMinExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  if FFlowMeter.QuantityMin = NormalizeFloatInput(EditQuantityMin.Text) then
    Exit;
  FFlowMeter.QuantityMin := NormalizeFloatInput(EditQuantityMin.Text);
  EditQuantityMin.Text := FloatToStr(FFlowMeter.QuantityMin);
  NotifyChanged;
end;


procedure TFrameFlowMeterProperties.SetPropertyRowVisible(ALabel: TLabel; AVisible: Boolean);
var
  Item: TFmxObject;
begin
  if ALabel = nil then
    Exit;
  Item := ALabel.Parent;
  if Item <> nil then
    Item := Item.Parent;
  if Item is TControl then
  begin
    TControl(Item).Visible := AVisible;
    if AVisible then
      TControl(Item).Height := 32
    else
      TControl(Item).Height := 0;
  end;
end;

function TFrameFlowMeterProperties.ValidPositive(AValue: Double): Boolean;
begin
  Result := (AValue > 0) and (not IsNan(AValue)) and (not IsInfinite(AValue));
end;

function TFrameFlowMeterProperties.DisplayedCoef: Double;
begin
  Result := 0;
  if (FDevice = nil) or (not ValidPositive(FDevice.Coef)) then
    Exit;
  case FDevice.DimensionCoef of
    1: Result := 1 / FDevice.Coef;
  else
    Result := FDevice.Coef;
  end;
end;

procedure TFrameFlowMeterProperties.ApplyWeightsOutputRestriction;
begin
  if ComboOutputType = nil then
    Exit;
  ComboOutputType.Items.BeginUpdate;
  try
    ComboOutputType.Items.Clear;
    if (FFlowMeter <> nil) and (FFlowMeter.MeterFlowCategory = mftWeightsType) then
    begin
      ComboOutputType.Items.Add('Интерфейс');
      ComboOutputType.Items.Add('Визуальный');
    end
    else
    begin
      ComboOutputType.Items.Add('Частота');
      ComboOutputType.Items.Add('Импульсы');
      ComboOutputType.Items.Add('Напряжение');
      ComboOutputType.Items.Add('Ток');
      ComboOutputType.Items.Add('Интерфейс');
      ComboOutputType.Items.Add('Визуальный');
    end;
  finally
    ComboOutputType.Items.EndUpdate;
  end;
end;

procedure TFrameFlowMeterProperties.LoadOutputSettings;
var
  Idx: Integer;
begin
  if FDevice = nil then
    Exit;
  ComboBoxFrequencyOutputSet.ItemIndex := FDevice.OutputSet;
  ComboBoxImpulseOutputSet.ItemIndex := FDevice.OutputSet;
  if FDevice.Freq > 0 then EditFrequency.Text := IntToStr(FDevice.Freq) else EditFrequency.Text := '';
  ComboBoxFrequencyView.ItemIndex := FDevice.DimensionCoef;
  ComboBoxImpulseCoefView.ItemIndex := FDevice.DimensionCoef;
  if FDevice.FreqFlowRate > 0 then EditFrequencyFlowRate.Text := FloatToStr(FDevice.FreqFlowRate) else EditFrequencyFlowRate.Text := '';
  if DisplayedCoef > 0 then EditImpulseCoef.Text := FormatFloat('0.########', DisplayedCoef) else EditImpulseCoef.Text := '';
  if (FDevice.VoltageRange >= 0) and (FDevice.VoltageRange < ComboBoxVoltageRange.Items.Count) then
    ComboBoxVoltageRange.ItemIndex := FDevice.VoltageRange
  else
    ComboBoxVoltageRange.ItemIndex := -1;
  EditVoltageQMin.Text := FloatToStr(FDevice.VoltageQminRate);
  EditVoltageQMax.Text := FloatToStr(FDevice.VoltageQmaxRate);
  if (FDevice.CurrentRange >= 0) and (FDevice.CurrentRange < ComboBoxCurrentRange.Items.Count) then
    ComboBoxCurrentRange.ItemIndex := FDevice.CurrentRange
  else
    ComboBoxCurrentRange.ItemIndex := -1;
  EditCurrentQMin.Text := FloatToStr(FDevice.CurrentQminRate);
  EditCurrentQMax.Text := FloatToStr(FDevice.CurrentQmaxRate);
  Idx := ComboBoxProtocol.Items.IndexOf(FDevice.ProtocolName);
  ComboBoxProtocol.ItemIndex := Idx;
  ComboBoxProtocol.ItemIndex :=
  ComboBoxProtocol.Items.IndexOf(FDevice.ProtocolName);
  EditDeviceAddress.Text := IntToStr(FDevice.DeviceAddress);
  ComboBoxBaudRate.ItemIndex := ComboBoxBaudRate.Items.IndexOf(IntToStr(FDevice.BaudRate));
  if (FDevice.Parity >= 0) and (FDevice.Parity < ComboBoxParity.Items.Count) then
    ComboBoxParity.ItemIndex := FDevice.Parity
  else
    ComboBoxParity.ItemIndex := -1;
  if (FDevice.InputType >= 0) and (FDevice.InputType < ComboBoxVisualInputType.Items.Count) then
    ComboBoxVisualInputType.ItemIndex := FDevice.InputType
  else
    ComboBoxVisualInputType.ItemIndex := -1;
end;

procedure TFrameFlowMeterProperties.UpdateOutputSettingsVisibility;
var
  OutputType: Integer;
begin
  if FDevice <> nil then OutputType := FDevice.OutputType else OutputType := Ord(otUnknown);
  SetPropertyRowVisible(LabelFrequencyOutputSet, OutputType = Ord(otFrequency));
  SetPropertyRowVisible(LabelFrequency, OutputType = Ord(otFrequency));
  SetPropertyRowVisible(LabelFrequencyView, False);
  SetPropertyRowVisible(LabelFrequencyFlowRate, OutputType = Ord(otFrequency));
  SetPropertyRowVisible(LabelImpulseOutputSet, OutputType = Ord(otImpulse));
  SetPropertyRowVisible(LabelImpulseCoef, OutputType = Ord(otImpulse));
  SetPropertyRowVisible(LabelImpulseCoefView, OutputType = Ord(otImpulse));
  SetPropertyRowVisible(LabelVoltageRange, OutputType = Ord(otVoltage));
  SetPropertyRowVisible(LabelVoltageQMin, OutputType = Ord(otVoltage));
  SetPropertyRowVisible(LabelVoltageQMax, OutputType = Ord(otVoltage));
  SetPropertyRowVisible(LabelCurrentRange, OutputType = Ord(otCurrent));
  SetPropertyRowVisible(LabelCurrentQMin, OutputType = Ord(otCurrent));
  SetPropertyRowVisible(LabelCurrentQMax, OutputType = Ord(otCurrent));
  SetPropertyRowVisible(LabelProtocol, OutputType = Ord(otInterface));
  SetPropertyRowVisible(LabelDeviceAddress, OutputType = Ord(otInterface));
  SetPropertyRowVisible(LabelBaudRate, OutputType = Ord(otInterface));
  SetPropertyRowVisible(LabelParity, OutputType = Ord(otInterface));
  SetPropertyRowVisible(LabelVisualInputType, OutputType = Ord(otVisual));
  Realign;
end;

procedure TFrameFlowMeterProperties.OutputSetChange(Sender: TObject);
var V: Integer;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  V := TComboBox(Sender).ItemIndex; if V < 0 then Exit;
  FDevice.OutputSet := V; NotifyChanged;
end;

procedure TFrameFlowMeterProperties.DimensionCoefChange(Sender: TObject);
var V: Integer;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  V := TComboBox(Sender).ItemIndex; if V < 0 then Exit;
  FDevice.DimensionCoef := V; LoadOutputSettings; NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFrequencyExit(Sender: TObject);
var NewFreq: Integer;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  NewFreq := Trunc(NormalizeFloatInput(EditFrequency.Text));
  if NewFreq <= 0 then begin EditFrequency.Text := IntToStr(FDevice.Freq); Exit; end;
  FDevice.Freq := NewFreq;
  if ValidPositive(FDevice.FreqFlowRate) then FDevice.Coef := 3.6 * FDevice.Freq / FDevice.FreqFlowRate;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFrequencyFlowRateExit(Sender: TObject);
var NewRate: Double;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  NewRate := NormalizeFloatInput(EditFrequencyFlowRate.Text);
  if not ValidPositive(NewRate) then begin EditFrequencyFlowRate.Text := FloatToStr(FDevice.FreqFlowRate); Exit; end;
  FDevice.FreqFlowRate := NewRate;
  if FDevice.Freq > 0 then FDevice.Coef := 3.6 * FDevice.Freq / FDevice.FreqFlowRate;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditImpulseCoefExit(Sender: TObject);
var InputValue, NewStoredCoef: Double;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  InputValue := NormalizeFloatInput(EditImpulseCoef.Text);
  if not ValidPositive(InputValue) then begin EditImpulseCoef.Text := FormatFloat('0.########', DisplayedCoef); Exit; end;
  if FDevice.DimensionCoef = 1 then NewStoredCoef := 1 / InputValue else NewStoredCoef := InputValue;
  if not ValidPositive(NewStoredCoef) then begin EditImpulseCoef.Text := FormatFloat('0.########', DisplayedCoef); Exit; end;
  FDevice.Coef := NewStoredCoef;
  if ValidPositive(FDevice.FreqFlowRate) then FDevice.Freq := Round(FDevice.Coef * FDevice.FreqFlowRate / 3.6);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.ComboBoxVoltageRangeChange(Sender: TObject); begin if FIsLoading or (FDevice = nil) then Exit; if ComboBoxVoltageRange.ItemIndex >= 0 then begin FDevice.VoltageRange := ComboBoxVoltageRange.ItemIndex; NotifyChanged; end; end;
procedure TFrameFlowMeterProperties.EditVoltageQMinExit(Sender: TObject); var V: Double; begin if FIsLoading or (FDevice = nil) then Exit; V := NormalizeFloatInput(EditVoltageQMin.Text); if (V <= 0) or (V >= 1) or IsNan(V) or IsInfinite(V) then begin EditVoltageQMin.Text := FloatToStr(FDevice.VoltageQminRate); Exit; end; FDevice.VoltageQminRate := V; NotifyChanged; end;
procedure TFrameFlowMeterProperties.EditVoltageQMaxExit(Sender: TObject); var V: Double; begin if FIsLoading or (FDevice = nil) then Exit; V := NormalizeFloatInput(EditVoltageQMax.Text); if (V <= 0) or (V > 1) or IsNan(V) or IsInfinite(V) then begin EditVoltageQMax.Text := FloatToStr(FDevice.VoltageQmaxRate); Exit; end; FDevice.VoltageQmaxRate := V; NotifyChanged; end;
procedure TFrameFlowMeterProperties.ComboBoxCurrentRangeChange(Sender: TObject); begin if FIsLoading or (FDevice = nil) then Exit; if ComboBoxCurrentRange.ItemIndex >= 0 then begin FDevice.CurrentRange := ComboBoxCurrentRange.ItemIndex; NotifyChanged; end; end;
procedure TFrameFlowMeterProperties.EditCurrentQMinExit(Sender: TObject); var V: Double; begin if FIsLoading or (FDevice = nil) then Exit; V := NormalizeFloatInput(EditCurrentQMin.Text); if (V < 0) or (V >= 1) or IsNan(V) or IsInfinite(V) then begin EditCurrentQMin.Text := FloatToStr(FDevice.CurrentQminRate); Exit; end; FDevice.CurrentQminRate := V; NotifyChanged; end;
procedure TFrameFlowMeterProperties.EditCurrentQMaxExit(Sender: TObject); var V: Double; begin if FIsLoading or (FDevice = nil) then Exit; V := NormalizeFloatInput(EditCurrentQMax.Text); if (V <= 0) or (V > 1) or IsNan(V) or IsInfinite(V) then begin EditCurrentQMax.Text := FloatToStr(FDevice.CurrentQmaxRate); Exit; end; FDevice.CurrentQmaxRate := V; NotifyChanged; end;
procedure TFrameFlowMeterProperties.ComboBoxProtocolChange(Sender: TObject); begin if FIsLoading or (FDevice = nil) then Exit; FDevice.ProtocolName := Trim(ComboBoxProtocol.Text); NotifyChanged; end;
procedure TFrameFlowMeterProperties.EditDeviceAddressExit(Sender: TObject); var V: Integer; begin if FIsLoading or (FDevice = nil) then Exit; V := StrToIntDef(Trim(EditDeviceAddress.Text), FDevice.DeviceAddress); if V < 0 then V := FDevice.DeviceAddress; FDevice.DeviceAddress := V; EditDeviceAddress.Text := IntToStr(V); NotifyChanged; end;
procedure TFrameFlowMeterProperties.ComboBoxBaudRateChange(Sender: TObject); var V: Integer; begin if FIsLoading or (FDevice = nil) then Exit; V := StrToIntDef(ComboBoxBaudRate.Text, FDevice.BaudRate); FDevice.BaudRate := V; NotifyChanged; end;
procedure TFrameFlowMeterProperties.ComboBoxParityChange(Sender: TObject); begin if FIsLoading or (FDevice = nil) then Exit; if ComboBoxParity.ItemIndex >= 0 then begin FDevice.Parity := ComboBoxParity.ItemIndex; NotifyChanged; end; end;
procedure TFrameFlowMeterProperties.ComboBoxVisualInputTypeChange(Sender: TObject); begin if FIsLoading or (FDevice = nil) then Exit; if ComboBoxVisualInputType.ItemIndex >= 0 then begin FDevice.InputType := ComboBoxVisualInputType.ItemIndex; NotifyChanged; end; end;

end.
