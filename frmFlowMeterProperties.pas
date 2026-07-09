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
  FMX.TabControl,
  FMX.TreeView,
  FMX.Types,
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uClasses,
  uDeviceClass,
  uFlowMeter,
  uWorkTable;

type
  TFrameFlowMeterProperties = class(TFrame)
  private
    FFlowMeter: TFlowMeter;
    FChannel: TChannel;
    FDevice: TDevice;
    FIsLoading: Boolean;
    FOnChange: TNotifyEvent;

    LayoutRoot: TLayout;
    HeaderGrid: TGridPanelLayout;
    TreeInspector: TTreeView;
    CategoryMain: TTreeViewItem;
    CategoryOutput: TTreeViewItem;

    EditDeviceName: TEdit;
    EditDeviceTypeName: TEdit;
    EditSerialNumber: TEdit;
    ComboOutputType: TComboBox;
    HeaderProperty: TLabel;
    HeaderValue: TLabel;
    HeaderDivider: TLine;

    TabControlOutputType: TTabControl;
    TabFrequency: TTabItem;
    TabImpulse: TTabItem;
    TabVoltage: TTabItem;
    TabCurrent: TTabItem;
    TabInterface: TTabItem;
    TabVisual: TTabItem;

    cbOutPutType: TComboBox;
    EditFreq: TEdit;
    ComboBox6: TComboBox;
    EditFreqFlowRate: TEdit;

    cbOutPutType2: TComboBox;
    cbCoefViewType: TComboBox;
    EditCoef: TEdit;

    cbVoltageRange: TComboBox;
    EditVoltageQminRate: TEdit;
    EditVoltageQmaxRate: TEdit;

    cbCurrentRange: TComboBox;
    EditCurrentQminRate: TEdit;
    EditCurrentQmaxRate: TEdit;

    EditProtocolName: TEdit;
    cbBaudRate: TComboBox;
    cbParity: TComboBox;
    EditDeviceAddress: TEdit;

    cbInputType: TComboBox;

    procedure BuildUI;
    procedure UpdateHeaders;
    procedure UpdateControls;
    procedure ClearUI;
    function AddCategory(const ACaption: string): TTreeViewItem;
    function AddPropertyRow(AParent: TTreeViewItem; const ACaption: string;
      AControl: TControl; const AHint: string = ''): TLabel;
    procedure AddTabRow(ATab: TTabItem; const ACaption: string; AControl: TControl);
    procedure FillOutputSetCombo(ACombo: TComboBox);
    procedure FillCoefViewCombo(ACombo: TComboBox);
    procedure PopulateOutputTypeCombo(const ASelectedOutputType: Integer);
    procedure ApplyDeviceOutputType;
    procedure UpdateUIFreq;
    procedure UpdateUICoef;
    procedure UpdateUIVoltage;
    procedure UpdateUICurrent;
    procedure UpdateUIInterface;
    procedure UpdateUIVisual;

    procedure EditDeviceNameExit(Sender: TObject);
    procedure EditDeviceTypeNameExit(Sender: TObject);
    procedure EditSerialNumberExit(Sender: TObject);
    procedure ComboOutputTypeChange(Sender: TObject);
    procedure cbOutPutTypeChange(Sender: TObject);
    procedure cbOutPutType2Change(Sender: TObject);
    procedure cbCoefViewTypeChange(Sender: TObject);
    procedure ComboBox6Change(Sender: TObject);
    procedure EditFreqExit(Sender: TObject);
    procedure EditFreqFlowRateExit(Sender: TObject);
    procedure EditCoefExit(Sender: TObject);
    procedure cbVoltageRangeChange(Sender: TObject);
    procedure EditVoltageExit(Sender: TObject);
    procedure cbCurrentRangeChange(Sender: TObject);
    procedure EditCurrentExit(Sender: TObject);
    procedure InterfaceControlChange(Sender: TObject);
    procedure InterfaceEditExit(Sender: TObject);
    procedure cbInputTypeChange(Sender: TObject);

    function GetFlowDimName: string;
    function IsValidFloat(const AValue: Double): Boolean;
    function SafeFloatText(const AValue: Double): string;
    procedure NotifyChanged;
    procedure ApplyOutputType;
    function GetActiveOutputType: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFlowMeter(AFlowMeter: TFlowMeter);
    procedure SetChannel(AChannel: TChannel);
    property FlowMeter: TFlowMeter read FFlowMeter write SetFlowMeter;
    property Channel: TChannel read FChannel write SetChannel;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  System.Math,
  uBaseProcedures;

{$R *.fmx}

const
  COutputNames: array[0..5] of string = (
    'Частота', 'Импульсы', 'Напряжение', 'Ток', 'Интерфейс', 'Визуальный');

constructor TFrameFlowMeterProperties.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
  ClearUI;
end;

procedure TFrameFlowMeterProperties.BuildUI;
var
  OutputItem: TTreeViewItem;
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
  HeaderGrid.ColumnCollection.Clear;
  HeaderGrid.RowCollection.Clear;
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
  HeaderProperty.Margins.Rect := TRectF.Create(10, 0, 8, 0);
  HeaderGrid.ControlCollection.AddControl(HeaderProperty, 0, 0);

  HeaderValue := TLabel.Create(Self);
  HeaderValue.Parent := HeaderGrid;
  HeaderValue.Align := TAlignLayout.Client;
  HeaderValue.Text := 'Значение';
  HeaderValue.StyledSettings := [];
  HeaderValue.TextSettings.Font.Style := [TFontStyle.fsBold];
  HeaderValue.Margins.Rect := TRectF.Create(8, 0, 10, 0);
  HeaderGrid.ControlCollection.AddControl(HeaderValue, 1, 0);

  HeaderDivider := TLine.Create(Self);
  HeaderDivider.Parent := LayoutRoot;
  HeaderDivider.Align := TAlignLayout.Top;
  HeaderDivider.Height := 1;
  HeaderDivider.LineType := TLineType.Bottom;
  HeaderDivider.Stored := False;

  TreeInspector := TTreeView.Create(Self);
  TreeInspector.Parent := LayoutRoot;
  TreeInspector.Align := TAlignLayout.Client;
  TreeInspector.ShowCheckboxes := False;
  TreeInspector.ItemHeight := 32;
  TreeInspector.Stored := False;

  CategoryMain := AddCategory('Основные');

  EditDeviceName := TEdit.Create(Self);
  EditDeviceName.OnExit := EditDeviceNameExit;
  AddPropertyRow(CategoryMain, 'Имя', EditDeviceName);

  EditDeviceTypeName := TEdit.Create(Self);
  EditDeviceTypeName.OnExit := EditDeviceTypeNameExit;
  AddPropertyRow(CategoryMain, 'Тип', EditDeviceTypeName);

  EditSerialNumber := TEdit.Create(Self);
  EditSerialNumber.OnExit := EditSerialNumberExit;
  AddPropertyRow(CategoryMain, 'Серийный номер', EditSerialNumber);

  ComboOutputType := TComboBox.Create(Self);
  ComboOutputType.OnChange := ComboOutputTypeChange;
  AddPropertyRow(CategoryMain, 'Тип выхода', ComboOutputType);

  CategoryOutput := AddCategory('Настройки выхода');

  OutputItem := TTreeViewItem.Create(Self);
  OutputItem.Parent := CategoryOutput;
  OutputItem.Text := '';
  OutputItem.Height := 190;
  OutputItem.Stored := False;

  TabControlOutputType := TTabControl.Create(Self);
  TabControlOutputType.Parent := OutputItem;
  TabControlOutputType.Align := TAlignLayout.Client;
  TabControlOutputType.TabPosition := TTabPosition(0);
  TabControlOutputType.Stored := False;

  TabFrequency := TTabItem.Create(Self);
  TabFrequency.Parent := TabControlOutputType;
  TabFrequency.Text := 'Частота';
  cbOutPutType := TComboBox.Create(Self);
  FillOutputSetCombo(cbOutPutType);
  cbOutPutType.OnChange := cbOutPutTypeChange;
  AddTabRow(TabFrequency, 'Тип выхода', cbOutPutType);
  EditFreq := TEdit.Create(Self);
  EditFreq.TextPrompt := 'F: 0..10кГц';
  EditFreq.KillFocusByReturn := True;
  EditFreq.OnExit := EditFreqExit;
  AddTabRow(TabFrequency, 'Частота, Гц', EditFreq);
  ComboBox6 := TComboBox.Create(Self);
  FillCoefViewCombo(ComboBox6);
  ComboBox6.OnChange := ComboBox6Change;
  AddTabRow(TabFrequency, 'Представление', ComboBox6);
  EditFreqFlowRate := TEdit.Create(Self);
  EditFreqFlowRate.TextPrompt := '1';
  EditFreqFlowRate.KillFocusByReturn := True;
  EditFreqFlowRate.OnExit := EditFreqFlowRateExit;
  AddTabRow(TabFrequency, 'Расход, QF', EditFreqFlowRate);

  TabImpulse := TTabItem.Create(Self);
  TabImpulse.Parent := TabControlOutputType;
  TabImpulse.Text := 'Импульсы';
  cbOutPutType2 := TComboBox.Create(Self);
  FillOutputSetCombo(cbOutPutType2);
  cbOutPutType2.OnChange := cbOutPutType2Change;
  AddTabRow(TabImpulse, 'Тип выхода', cbOutPutType2);
  cbCoefViewType := TComboBox.Create(Self);
  FillCoefViewCombo(cbCoefViewType);
  cbCoefViewType.OnChange := cbCoefViewTypeChange;
  AddTabRow(TabImpulse, 'Представление', cbCoefViewType);
  EditCoef := TEdit.Create(Self);
  EditCoef.TextPrompt := '100';
  EditCoef.KillFocusByReturn := True;
  EditCoef.OnExit := EditCoefExit;
  AddTabRow(TabImpulse, 'Коэффициент Kp', EditCoef);

  TabVoltage := TTabItem.Create(Self);
  TabVoltage.Parent := TabControlOutputType;
  TabVoltage.Text := 'Напряжение';
  cbVoltageRange := TComboBox.Create(Self);
  cbVoltageRange.Items.Add('0-10 В');
  cbVoltageRange.Items.Add('0-5 В');
  cbVoltageRange.Items.Add('0-24 В');
  cbVoltageRange.OnChange := cbVoltageRangeChange;
  AddTabRow(TabVoltage, 'Диапазон', cbVoltageRange);
  EditVoltageQminRate := TEdit.Create(Self);
  EditVoltageQminRate.OnExit := EditVoltageExit;
  AddTabRow(TabVoltage, 'Qmin', EditVoltageQminRate);
  EditVoltageQmaxRate := TEdit.Create(Self);
  EditVoltageQmaxRate.OnExit := EditVoltageExit;
  AddTabRow(TabVoltage, 'Qmax', EditVoltageQmaxRate);

  TabCurrent := TTabItem.Create(Self);
  TabCurrent.Parent := TabControlOutputType;
  TabCurrent.Text := 'Ток';
  cbCurrentRange := TComboBox.Create(Self);
  cbCurrentRange.Items.Add('4-20 мА');
  cbCurrentRange.Items.Add('0-20 мА');
  cbCurrentRange.OnChange := cbCurrentRangeChange;
  AddTabRow(TabCurrent, 'Диапазон', cbCurrentRange);
  EditCurrentQminRate := TEdit.Create(Self);
  EditCurrentQminRate.OnExit := EditCurrentExit;
  AddTabRow(TabCurrent, 'Qmin', EditCurrentQminRate);
  EditCurrentQmaxRate := TEdit.Create(Self);
  EditCurrentQmaxRate.OnExit := EditCurrentExit;
  AddTabRow(TabCurrent, 'Qmax', EditCurrentQmaxRate);

  TabInterface := TTabItem.Create(Self);
  TabInterface.Parent := TabControlOutputType;
  TabInterface.Text := 'Интерфейс';
  EditProtocolName := TEdit.Create(Self);
  EditProtocolName.OnExit := InterfaceEditExit;
  AddTabRow(TabInterface, 'Библиотека', EditProtocolName);
  cbBaudRate := TComboBox.Create(Self);
  cbBaudRate.Items.Add('2400');
  cbBaudRate.Items.Add('4800');
  cbBaudRate.Items.Add('9600');
  cbBaudRate.Items.Add('19200');
  cbBaudRate.Items.Add('115200');
  cbBaudRate.OnChange := InterfaceControlChange;
  AddTabRow(TabInterface, 'Скорость', cbBaudRate);
  cbParity := TComboBox.Create(Self);
  cbParity.Items.Add('Нет');
  cbParity.Items.Add('Четность');
  cbParity.Items.Add('Нечетность');
  cbParity.OnChange := InterfaceControlChange;
  AddTabRow(TabInterface, 'Четность', cbParity);
  EditDeviceAddress := TEdit.Create(Self);
  EditDeviceAddress.OnExit := InterfaceEditExit;
  AddTabRow(TabInterface, 'Адрес', EditDeviceAddress);

  TabVisual := TTabItem.Create(Self);
  TabVisual.Parent := TabControlOutputType;
  TabVisual.Text := 'Визуальный';
  cbInputType := TComboBox.Create(Self);
  cbInputType.Items.Add('Ручной ввод');
  cbInputType.Items.Add('Клавиатура');
  cbInputType.OnChange := cbInputTypeChange;
  AddTabRow(TabVisual, 'Тип ввода', cbInputType);
end;

function TFrameFlowMeterProperties.AddCategory(const ACaption: string): TTreeViewItem;
begin
  Result := TTreeViewItem.Create(Self);
  Result.Parent := TreeInspector;
  Result.Text := ACaption;
  Result.StyledSettings := [];
  Result.TextSettings.Font.Style := [TFontStyle.fsBold];
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

  Result := TLabel.Create(Self);
  Result.Parent := RowGrid;
  Result.Align := TAlignLayout.Client;
  Result.Text := ACaption;
  Result.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(Result, 0, 0);

  AControl.Parent := RowGrid;
  AControl.Align := TAlignLayout.Client;
  AControl.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  RowGrid.ControlCollection.AddControl(AControl, 1, 0);
end;

procedure TFrameFlowMeterProperties.AddTabRow(ATab: TTabItem;
  const ACaption: string; AControl: TControl);
var
  Row: TLayout;
  LabelCaption: TLabel;
begin
  Row := TLayout.Create(Self);
  Row.Parent := ATab;
  Row.Align := TAlignLayout.Top;
  Row.Height := 32;
  Row.Padding.Rect := TRectF.Create(40, 3, 10, 3);
  Row.Stored := False;

  LabelCaption := TLabel.Create(Self);
  LabelCaption.Parent := Row;
  LabelCaption.Align := TAlignLayout.Left;
  LabelCaption.Width := 260;
  LabelCaption.Text := ACaption;

  AControl.Parent := Row;
  AControl.Align := TAlignLayout.Client;
end;

procedure TFrameFlowMeterProperties.FillOutputSetCombo(ACombo: TComboBox);
begin
  ACombo.Items.Clear;
  ACombo.Items.Add('Авто');
  ACombo.Items.Add('Пассивный');
  ACombo.Items.Add('Активный');
  ACombo.Items.Add('Активный высокоомный');
  ACombo.Items.Add('Емкостной');
end;

procedure TFrameFlowMeterProperties.FillCoefViewCombo(ACombo: TComboBox);
begin
  ACombo.Items.Clear;
  ACombo.Items.Add('имп/л');
  ACombo.Items.Add('л/имп');
  ACombo.ItemIndex := 0;
end;

procedure TFrameFlowMeterProperties.PopulateOutputTypeCombo(
  const ASelectedOutputType: Integer);
var
  I: Integer;
begin
  ComboOutputType.Items.BeginUpdate;
  try
    ComboOutputType.Items.Clear;
    for I := 0 to High(COutputNames) do
      ComboOutputType.Items.AddObject(COutputNames[I], TObject(NativeInt(I)));
    ComboOutputType.ItemIndex := -1;
    for I := 0 to ComboOutputType.Items.Count - 1 do
      if Integer(NativeInt(ComboOutputType.Items.Objects[I])) = ASelectedOutputType then
      begin
        ComboOutputType.ItemIndex := I;
        Break;
      end;
  finally
    ComboOutputType.Items.EndUpdate;
  end;
end;

procedure TFrameFlowMeterProperties.SetFlowMeter(AFlowMeter: TFlowMeter);
begin
  FChannel := nil;
  FFlowMeter := AFlowMeter;
  if FFlowMeter <> nil then
    FDevice := FFlowMeter.Device
  else
    FDevice := nil;
  UpdateControls;
end;

procedure TFrameFlowMeterProperties.SetChannel(AChannel: TChannel);
begin
  FIsLoading := True;
  try
    FChannel := AChannel;
    FDevice := nil;
    if FChannel <> nil then
      FFlowMeter := FChannel.FlowMeter
    else
      FFlowMeter := nil;
    if FFlowMeter <> nil then
      FDevice := FFlowMeter.Device;

    if FDevice = nil then
      ClearUI
    else
    begin
      UpdateControls;
      PopulateOutputTypeCombo(FDevice.OutputType);
      ApplyDeviceOutputType;
    end;
  finally
    FIsLoading := False;
  end;
end;

procedure TFrameFlowMeterProperties.ClearUI;
begin
  EditDeviceName.Text := '';
  EditDeviceTypeName.Text := '';
  EditSerialNumber.Text := '';
  ComboOutputType.ItemIndex := -1;
  TabControlOutputType.ActiveTab := TabFrequency;
  TabControlOutputType.Enabled := False;
end;

procedure TFrameFlowMeterProperties.UpdateHeaders;
begin
end;

procedure TFrameFlowMeterProperties.UpdateControls;
begin
  FIsLoading := True;
  try
    UpdateHeaders;
    if FDevice = nil then
    begin
      ClearUI;
      Exit;
    end;

    TabControlOutputType.Enabled := True;
    EditDeviceName.Text := Trim(FDevice.Name);
    EditDeviceTypeName.Text := Trim(FDevice.DeviceTypeName);
    EditSerialNumber.Text := Trim(FDevice.SerialNumber);
    PopulateOutputTypeCombo(FDevice.OutputType);
    ApplyDeviceOutputType;
  finally
    FIsLoading := False;
  end;
end;

procedure TFrameFlowMeterProperties.NotifyChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TFrameFlowMeterProperties.GetFlowDimName: string;
begin
  Result := 'ед.';
  if FDevice <> nil then
    Result := FDevice.GetDimensionName;
end;

function TFrameFlowMeterProperties.IsValidFloat(const AValue: Double): Boolean;
begin
  Result := (AValue = AValue) and (Abs(AValue) < 1.0E308);
end;

function TFrameFlowMeterProperties.SafeFloatText(const AValue: Double): string;
begin
  if IsValidFloat(AValue) then
    Result := FloatToStr(AValue)
  else
    Result := '0';
end;

procedure TFrameFlowMeterProperties.ApplyDeviceOutputType;
begin
  if FDevice = nil then
    Exit;

  case FDevice.OutputType of
    Ord(otFrequency):
      begin
        UpdateUIFreq;
        TabControlOutputType.ActiveTab := TabFrequency;
      end;
    Ord(otImpulse):
      begin
        UpdateUICoef;
        TabControlOutputType.ActiveTab := TabImpulse;
      end;
    Ord(otVoltage):
      begin
        UpdateUIVoltage;
        TabControlOutputType.ActiveTab := TabVoltage;
      end;
    Ord(otCurrent):
      begin
        UpdateUICurrent;
        TabControlOutputType.ActiveTab := TabCurrent;
      end;
    Ord(otInterface):
      begin
        UpdateUIInterface;
        TabControlOutputType.ActiveTab := TabInterface;
      end;
    Ord(otVisual):
      begin
        UpdateUIVisual;
        TabControlOutputType.ActiveTab := TabVisual;
      end;
  end;
end;

procedure TFrameFlowMeterProperties.UpdateUIFreq;
begin
  if FDevice.OutputSet >= 0 then
    cbOutPutType.ItemIndex := FDevice.OutputSet
  else
    cbOutPutType.ItemIndex := -1;
  if FDevice.Freq > 0 then
    EditFreq.Text := IntToStr(FDevice.Freq)
  else
    EditFreq.Text := '';
  ComboBox6.ItemIndex := FDevice.DimensionCoef;
  if FDevice.FreqFlowRate > 0 then
    EditFreqFlowRate.Text := SafeFloatText(FDevice.FreqFlowRate)
  else
    EditFreqFlowRate.Text := '';
end;

procedure TFrameFlowMeterProperties.UpdateUICoef;
begin
  if FDevice.OutputSet >= 0 then
    cbOutPutType2.ItemIndex := FDevice.OutputSet
  else
    cbOutPutType2.ItemIndex := -1;
  cbCoefViewType.ItemIndex := FDevice.DimensionCoef;
  if FDevice.Coef > 0 then
    EditCoef.Text := SafeFloatText(FDevice.Coef)
  else
    EditCoef.Text := '';
end;

procedure TFrameFlowMeterProperties.UpdateUIVoltage;
begin
  case FDevice.VoltageRange of
    10: cbVoltageRange.ItemIndex := 0;
    5: cbVoltageRange.ItemIndex := 1;
    24: cbVoltageRange.ItemIndex := 2;
  else
    cbVoltageRange.ItemIndex := -1;
  end;
  EditVoltageQminRate.Text := SafeFloatText(FDevice.VoltageQminRate);
  EditVoltageQmaxRate.Text := SafeFloatText(FDevice.VoltageQmaxRate);
end;

procedure TFrameFlowMeterProperties.UpdateUICurrent;
begin
  case FDevice.CurrentRange of
    20: cbCurrentRange.ItemIndex := 0;
    0: cbCurrentRange.ItemIndex := 1;
  else
    cbCurrentRange.ItemIndex := -1;
  end;
  EditCurrentQminRate.Text := SafeFloatText(FDevice.CurrentQminRate);
  EditCurrentQmaxRate.Text := SafeFloatText(FDevice.CurrentQmaxRate);
end;

procedure TFrameFlowMeterProperties.UpdateUIInterface;
begin
  EditProtocolName.Text := FDevice.ProtocolName;
  cbBaudRate.ItemIndex := cbBaudRate.Items.IndexOf(IntToStr(FDevice.BaudRate));
  cbParity.ItemIndex := FDevice.Parity;
  EditDeviceAddress.Text := IntToStr(FDevice.DeviceAddress);
end;

procedure TFrameFlowMeterProperties.UpdateUIVisual;
begin
  cbInputType.ItemIndex := FDevice.InputType;
end;

procedure TFrameFlowMeterProperties.EditDeviceNameExit(Sender: TObject);
var S: string;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  S := Trim(EditDeviceName.Text);
  if FDevice.Name = S then Exit;
  FDevice.Name := S;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditDeviceTypeNameExit(Sender: TObject);
var S: string;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  S := Trim(EditDeviceTypeName.Text);
  if FDevice.DeviceTypeName = S then Exit;
  FDevice.DeviceTypeName := S;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditSerialNumberExit(Sender: TObject);
var S: string;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  S := Trim(EditSerialNumber.Text);
  if FDevice.SerialNumber = S then Exit;
  FDevice.SerialNumber := S;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.ComboOutputTypeChange(Sender: TObject);
var V: Integer;
begin
  if FIsLoading or (FDevice = nil) or (ComboOutputType.ItemIndex < 0) then
    Exit;
  V := Integer(NativeInt(ComboOutputType.Items.Objects[ComboOutputType.ItemIndex]));
  if FDevice.OutputType = V then
    Exit;
  FDevice.OutputType := V;
  if FFlowMeter <> nil then
    FFlowMeter.OutputType := V;
  if FChannel <> nil then
    FChannel.Signal := V;
  PopulateOutputTypeCombo(FDevice.OutputType);
  ApplyDeviceOutputType;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.cbOutPutTypeChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) or (cbOutPutType.ItemIndex < 0) then Exit;
  FDevice.OutputSet := cbOutPutType.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.cbOutPutType2Change(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) or (cbOutPutType2.ItemIndex < 0) then Exit;
  FDevice.OutputSet := cbOutPutType2.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.cbCoefViewTypeChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) or (cbCoefViewType.ItemIndex < 0) then Exit;
  FDevice.DimensionCoef := cbCoefViewType.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.ComboBox6Change(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) or (ComboBox6.ItemIndex < 0) then Exit;
  FDevice.DimensionCoef := ComboBox6.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFreqExit(Sender: TObject);
var NewFreq: Integer;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  NewFreq := Trunc(NormalizeFloatInput(EditFreq.Text));
  if NewFreq <= 0 then
  begin
    EditFreq.Text := IntToStr(FDevice.Freq);
    Exit;
  end;
  FDevice.Freq := NewFreq;
  if (FDevice.Freq > 0) and (FDevice.FreqFlowRate > 0) and
     IsValidFloat(FDevice.FreqFlowRate) then
    FDevice.Coef := 3.6 * FDevice.Freq / FDevice.FreqFlowRate;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFreqFlowRateExit(Sender: TObject);
var NewRate: Double;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  NewRate := NormalizeFloatInput(EditFreqFlowRate.Text);
  if NewRate <= 0 then
  begin
    EditFreqFlowRate.Text := SafeFloatText(FDevice.FreqFlowRate);
    Exit;
  end;
  if not IsValidFloat(NewRate) then
  begin
    EditFreqFlowRate.Text := SafeFloatText(FDevice.FreqFlowRate);
    Exit;
  end;
  if Abs(FDevice.FreqFlowRate - NewRate) < 1E-12 then Exit;
  FDevice.FreqFlowRate := NewRate;
  if (FDevice.Freq > 0) and (FDevice.FreqFlowRate > 0) and
     IsValidFloat(FDevice.FreqFlowRate) then
    FDevice.Coef := 3.6 * FDevice.Freq / FDevice.FreqFlowRate;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditCoefExit(Sender: TObject);
var NewCoef: Double;
begin
  if FIsLoading or (FDevice = nil) then Exit;
  NewCoef := NormalizeFloatInput(EditCoef.Text);
  if (NewCoef <= 0) or not IsValidFloat(NewCoef) then
  begin
    EditCoef.Text := SafeFloatText(FDevice.Coef);
    Exit;
  end;
  if Abs(FDevice.Coef - NewCoef) < 1E-12 then Exit;
  FDevice.Coef := NewCoef;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.cbVoltageRangeChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  case cbVoltageRange.ItemIndex of
    0: FDevice.VoltageRange := 10;
    1: FDevice.VoltageRange := 5;
    2: FDevice.VoltageRange := 24;
  end;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditVoltageExit(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  FDevice.VoltageQminRate := NormalizeFloatInput(EditVoltageQminRate.Text);
  FDevice.VoltageQmaxRate := NormalizeFloatInput(EditVoltageQmaxRate.Text);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.cbCurrentRangeChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  case cbCurrentRange.ItemIndex of
    0: FDevice.CurrentRange := 20;
    1: FDevice.CurrentRange := 0;
  end;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditCurrentExit(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  FDevice.CurrentQminRate := NormalizeFloatInput(EditCurrentQminRate.Text);
  FDevice.CurrentQmaxRate := NormalizeFloatInput(EditCurrentQmaxRate.Text);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.InterfaceControlChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  FDevice.BaudRate := StrToIntDef(cbBaudRate.Text, FDevice.BaudRate);
  FDevice.Parity := cbParity.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.InterfaceEditExit(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  FDevice.ProtocolName := Trim(EditProtocolName.Text);
  FDevice.DeviceAddress := StrToIntDef(EditDeviceAddress.Text, FDevice.DeviceAddress);
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.cbInputTypeChange(Sender: TObject);
begin
  if FIsLoading or (FDevice = nil) then Exit;
  FDevice.InputType := cbInputType.ItemIndex;
  NotifyChanged;
end;

end.
