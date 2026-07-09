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
  uFlowMeter,
  uWorkTable;

type
  TFrameFlowMeterProperties = class(TFrame)
  private
    FFlowMeter: TFlowMeter;
    FChannel: TChannel;
    FIsLoading: Boolean;
    FOnChange: TNotifyEvent;

    LayoutRoot: TLayout;
    HeaderGrid: TGridPanelLayout;
    TreeInspector: TTreeView;
    CategoryMain: TTreeViewItem;
    CategoryRanges: TTreeViewItem;
    CategoryFrequency: TTreeViewItem;
    CategoryImpulse: TTreeViewItem;
    CategoryVoltage: TTreeViewItem;
    CategoryCurrent: TTreeViewItem;
    CategoryInterface: TTreeViewItem;
    CategoryVisual: TTreeViewItem;

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
    LabelFreqOutputSet: TLabel;
    LabelFreq: TLabel;
    LabelFreqView: TLabel;
    LabelFreqFlowRate: TLabel;
    ComboFreqOutputSet: TComboBox;
    EditFreq: TEdit;
    ComboFreqView: TComboBox;
    EditFreqFlowRate: TEdit;
    LabelImpulseOutputSet: TLabel;
    LabelImpulseView: TLabel;
    LabelImpulseCoef: TLabel;
    ComboImpulseOutputSet: TComboBox;
    ComboImpulseView: TComboBox;
    EditCoef: TEdit;
    ComboVoltageRange: TComboBox;
    EditVoltageQminRate: TEdit;
    EditVoltageQmaxRate: TEdit;
    ComboCurrentRange: TComboBox;
    EditCurrentQminRate: TEdit;
    EditCurrentQmaxRate: TEdit;
    EditProtocolName: TEdit;
    ComboBaudRate: TComboBox;
    ComboParity: TComboBox;
    EditDeviceAddress: TEdit;
    ComboInputType: TComboBox;
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
    procedure ComboFreqOutputSetChange(Sender: TObject);
    procedure ComboFreqViewChange(Sender: TObject);
    procedure EditFreqExit(Sender: TObject);
    procedure EditFreqFlowRateExit(Sender: TObject);
    procedure ComboImpulseOutputSetChange(Sender: TObject);
    procedure ComboImpulseViewChange(Sender: TObject);
    procedure EditCoefExit(Sender: TObject);
    procedure OutputComboChange(Sender: TObject);
    procedure OutputEditExit(Sender: TObject);

    function GetOutputTypeIndex(AOutputType: Integer): Integer;
    function GetOutputTypeByIndex(AIndex: Integer): Integer;
    function GetFlowDimName: string;
    function GetQuantityDimName: string;
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

  CategoryFrequency := AddCategory('Частота');

  ComboFreqOutputSet := TComboBox.Create(Self);
  ComboFreqOutputSet.Items.Add('Авто');
  ComboFreqOutputSet.Items.Add('Пассивный');
  ComboFreqOutputSet.Items.Add('Активный');
  ComboFreqOutputSet.Items.Add('Активный высокоомный');
  ComboFreqOutputSet.Items.Add('Емкостной');
  ComboFreqOutputSet.OnChange := ComboFreqOutputSetChange;
  LabelFreqOutputSet := AddPropertyRow(CategoryFrequency, 'Тип выхода', ComboFreqOutputSet);

  EditFreq := TEdit.Create(Self);
  EditFreq.TextPrompt := 'F: 0..10кГц';
  EditFreq.KillFocusByReturn := True;
  EditFreq.OnExit := EditFreqExit;
  LabelFreq := AddPropertyRow(CategoryFrequency, 'Частота, Гц', EditFreq);

  ComboFreqView := TComboBox.Create(Self);
  ComboFreqView.Items.Add('имп/л');
  ComboFreqView.Items.Add('л/имп');
  ComboFreqView.ItemIndex := 0;
  ComboFreqView.OnChange := ComboFreqViewChange;
  LabelFreqView := AddPropertyRow(CategoryFrequency, 'Представление', ComboFreqView);

  EditFreqFlowRate := TEdit.Create(Self);
  EditFreqFlowRate.TextPrompt := '1';
  EditFreqFlowRate.KillFocusByReturn := True;
  EditFreqFlowRate.OnExit := EditFreqFlowRateExit;
  LabelFreqFlowRate := AddPropertyRow(CategoryFrequency, 'Расход, QF', EditFreqFlowRate);

  CategoryImpulse := AddCategory('Импульсы');

  ComboImpulseOutputSet := TComboBox.Create(Self);
  ComboImpulseOutputSet.Items.Assign(ComboFreqOutputSet.Items);
  ComboImpulseOutputSet.OnChange := ComboImpulseOutputSetChange;
  LabelImpulseOutputSet := AddPropertyRow(CategoryImpulse, 'Тип выхода', ComboImpulseOutputSet);

  ComboImpulseView := TComboBox.Create(Self);
  ComboImpulseView.Items.Add('имп/л');
  ComboImpulseView.Items.Add('л/имп');
  ComboImpulseView.ItemIndex := 0;
  ComboImpulseView.OnChange := ComboImpulseViewChange;
  LabelImpulseView := AddPropertyRow(CategoryImpulse, 'Представление', ComboImpulseView);

  EditCoef := TEdit.Create(Self);
  EditCoef.TextPrompt := '100';
  EditCoef.KillFocusByReturn := True;
  EditCoef.OnExit := EditCoefExit;
  LabelImpulseCoef := AddPropertyRow(CategoryImpulse, 'Коэффициент Kp', EditCoef);

  CategoryVoltage := AddCategory('Напряжение');
  ComboVoltageRange := TComboBox.Create(Self);
  ComboVoltageRange.Items.Add('0-10 В');
  ComboVoltageRange.Items.Add('0-5 В');
  ComboVoltageRange.Items.Add('0-24 В');
  ComboVoltageRange.Tag := 1;
  ComboVoltageRange.OnChange := OutputComboChange;
  AddPropertyRow(CategoryVoltage, 'Диапазон', ComboVoltageRange);
  EditVoltageQminRate := TEdit.Create(Self);
  EditVoltageQminRate.Tag := 1;
  EditVoltageQminRate.OnExit := OutputEditExit;
  AddPropertyRow(CategoryVoltage, 'Qmin', EditVoltageQminRate);
  EditVoltageQmaxRate := TEdit.Create(Self);
  EditVoltageQmaxRate.Tag := 2;
  EditVoltageQmaxRate.OnExit := OutputEditExit;
  AddPropertyRow(CategoryVoltage, 'Qmax', EditVoltageQmaxRate);

  CategoryCurrent := AddCategory('Ток');
  ComboCurrentRange := TComboBox.Create(Self);
  ComboCurrentRange.Items.Add('4-20 мА');
  ComboCurrentRange.Items.Add('0-20 мА');
  ComboCurrentRange.Tag := 2;
  ComboCurrentRange.OnChange := OutputComboChange;
  AddPropertyRow(CategoryCurrent, 'Диапазон', ComboCurrentRange);
  EditCurrentQminRate := TEdit.Create(Self);
  EditCurrentQminRate.Tag := 3;
  EditCurrentQminRate.OnExit := OutputEditExit;
  AddPropertyRow(CategoryCurrent, 'Qmin', EditCurrentQminRate);
  EditCurrentQmaxRate := TEdit.Create(Self);
  EditCurrentQmaxRate.Tag := 4;
  EditCurrentQmaxRate.OnExit := OutputEditExit;
  AddPropertyRow(CategoryCurrent, 'Qmax', EditCurrentQmaxRate);

  CategoryInterface := AddCategory('Интерфейс');
  EditProtocolName := TEdit.Create(Self);
  EditProtocolName.Tag := 5;
  EditProtocolName.OnExit := OutputEditExit;
  AddPropertyRow(CategoryInterface, 'Библиотека', EditProtocolName);
  ComboBaudRate := TComboBox.Create(Self);
  ComboBaudRate.Items.Add('2400');
  ComboBaudRate.Items.Add('4800');
  ComboBaudRate.Items.Add('9600');
  ComboBaudRate.Items.Add('19200');
  ComboBaudRate.Items.Add('115200');
  ComboBaudRate.Tag := 3;
  ComboBaudRate.OnChange := OutputComboChange;
  AddPropertyRow(CategoryInterface, 'Скорость', ComboBaudRate);
  ComboParity := TComboBox.Create(Self);
  ComboParity.Items.Add('Нет');
  ComboParity.Items.Add('Четность');
  ComboParity.Items.Add('Нечетность');
  ComboParity.Tag := 4;
  ComboParity.OnChange := OutputComboChange;
  AddPropertyRow(CategoryInterface, 'Четность', ComboParity);
  EditDeviceAddress := TEdit.Create(Self);
  EditDeviceAddress.Tag := 6;
  EditDeviceAddress.OnExit := OutputEditExit;
  AddPropertyRow(CategoryInterface, 'Адрес', EditDeviceAddress);

  CategoryVisual := AddCategory('Визуальный');
  ComboInputType := TComboBox.Create(Self);
  ComboInputType.Items.Add('Ручной ввод');
  ComboInputType.Items.Add('Клавиатура');
  ComboInputType.Tag := 5;
  ComboInputType.OnChange := OutputComboChange;
  AddPropertyRow(CategoryVisual, 'Тип ввода', ComboInputType);
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
  FChannel := nil;
  FFlowMeter := AFlowMeter;
  UpdateControls;
end;

procedure TFrameFlowMeterProperties.SetChannel(AChannel: TChannel);
begin
  FChannel := AChannel;
  if AChannel <> nil then
    FFlowMeter := AChannel.FlowMeter
  else
    FFlowMeter := nil;
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

function TFrameFlowMeterProperties.GetActiveOutputType: Integer;
begin
  if (FChannel <> nil) and (FChannel.Signal = Ord(otFrequency)) then
    Exit(Ord(otFrequency));

  if (FFlowMeter <> nil) and (FFlowMeter.Device <> nil) and
     (FFlowMeter.Device.OutputType = Ord(otFrequency)) then
    Exit(Ord(otFrequency));

  if FChannel <> nil then
    Result := FChannel.Signal
  else if FFlowMeter <> nil then
    Result := FFlowMeter.OutputType
  else
    Result := Ord(otUnknown);

  if (Result = Ord(otUnknown)) and (FFlowMeter <> nil) and
     (FFlowMeter.Device <> nil) then
    Result := FFlowMeter.Device.OutputType;
end;

procedure TFrameFlowMeterProperties.ApplyOutputType;
begin
  if CategoryFrequency <> nil then
    CategoryFrequency.Visible := GetActiveOutputType = Ord(otFrequency);
  if CategoryImpulse <> nil then
    CategoryImpulse.Visible := GetActiveOutputType = Ord(otImpulse);
  if CategoryVoltage <> nil then
    CategoryVoltage.Visible := GetActiveOutputType = Ord(otVoltage);
  if CategoryCurrent <> nil then
    CategoryCurrent.Visible := GetActiveOutputType = Ord(otCurrent);
  if CategoryInterface <> nil then
    CategoryInterface.Visible := GetActiveOutputType = Ord(otInterface);
  if CategoryVisual <> nil then
    CategoryVisual.Visible := GetActiveOutputType = Ord(otVisual);

  if (LabelFreqFlowRate <> nil) and (FFlowMeter <> nil) then
    LabelFreqFlowRate.Text := 'Расход, QF, ' + GetFlowDimName;
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
    ComboFreqOutputSet.Enabled := Enabled;
    EditFreq.Enabled := Enabled;
    ComboFreqView.Enabled := Enabled;
    EditFreqFlowRate.Enabled := Enabled;
    ComboImpulseOutputSet.Enabled := Enabled;
    ComboImpulseView.Enabled := Enabled;
    EditCoef.Enabled := Enabled;
    ComboVoltageRange.Enabled := Enabled;
    EditVoltageQminRate.Enabled := Enabled;
    EditVoltageQmaxRate.Enabled := Enabled;
    ComboCurrentRange.Enabled := Enabled;
    EditCurrentQminRate.Enabled := Enabled;
    EditCurrentQmaxRate.Enabled := Enabled;
    EditProtocolName.Enabled := Enabled;
    ComboBaudRate.Enabled := Enabled;
    ComboParity.Enabled := Enabled;
    EditDeviceAddress.Enabled := Enabled;
    ComboInputType.Enabled := Enabled;

    if not Enabled then
    begin
      EditDeviceName.Text := '';
      EditDeviceTypeName.Text := '';
      EditSerialNumber.Text := '';
      ComboOutputType.ItemIndex := -1;
      ComboFreqOutputSet.ItemIndex := -1;
      EditFreq.Text := '';
      ComboFreqView.ItemIndex := -1;
      EditFreqFlowRate.Text := '';
      ComboImpulseOutputSet.ItemIndex := -1;
      ComboImpulseView.ItemIndex := -1;
      EditCoef.Text := '';
      ComboVoltageRange.ItemIndex := -1;
      EditVoltageQminRate.Text := '';
      EditVoltageQmaxRate.Text := '';
      ComboCurrentRange.ItemIndex := -1;
      EditCurrentQminRate.Text := '';
      EditCurrentQmaxRate.Text := '';
      EditProtocolName.Text := '';
      ComboBaudRate.ItemIndex := -1;
      ComboParity.ItemIndex := -1;
      EditDeviceAddress.Text := '';
      ComboInputType.ItemIndex := -1;
      ApplyOutputType;
      Exit;
    end;

    EditDeviceName.Text := Trim(FFlowMeter.DeviceName);
    EditDeviceTypeName.Text := Trim(FFlowMeter.DeviceTypeName);
    EditSerialNumber.Text := Trim(FFlowMeter.SerialNumber);
    ComboOutputType.ItemIndex := GetOutputTypeIndex(GetActiveOutputType);
    if FFlowMeter.Device <> nil then
    begin
      if (FFlowMeter.Device.OutputSet >= 0) and
         (FFlowMeter.Device.OutputSet < ComboFreqOutputSet.Items.Count) then
        ComboFreqOutputSet.ItemIndex := FFlowMeter.Device.OutputSet
      else
        ComboFreqOutputSet.ItemIndex := -1;

      if FFlowMeter.Device.Freq > 0 then
        EditFreq.Text := IntToStr(FFlowMeter.Device.Freq)
      else
        EditFreq.Text := '';

      if FFlowMeter.Device.DimensionCoef >= 0 then
        ComboFreqView.ItemIndex := FFlowMeter.Device.DimensionCoef
      else
        ComboFreqView.ItemIndex := 0;
      if FFlowMeter.Device.FreqFlowRate > 0 then
        EditFreqFlowRate.Text := FloatToStr(FFlowMeter.Device.FreqFlowRate)
      else
        EditFreqFlowRate.Text := '';

      ComboImpulseOutputSet.ItemIndex := ComboFreqOutputSet.ItemIndex;
      ComboImpulseView.ItemIndex := ComboFreqView.ItemIndex;
      if FFlowMeter.Device.Coef > 0 then
        EditCoef.Text := FloatToStr(FFlowMeter.Device.Coef)
      else
        EditCoef.Text := '';

      case FFlowMeter.Device.VoltageRange of
        10: ComboVoltageRange.ItemIndex := 0;
        5: ComboVoltageRange.ItemIndex := 1;
        24: ComboVoltageRange.ItemIndex := 2;
      else
        ComboVoltageRange.ItemIndex := -1;
      end;
      EditVoltageQminRate.Text := FloatToStr(FFlowMeter.Device.VoltageQminRate);
      EditVoltageQmaxRate.Text := FloatToStr(FFlowMeter.Device.VoltageQmaxRate);

      case FFlowMeter.Device.CurrentRange of
        20: ComboCurrentRange.ItemIndex := 0;
        0: ComboCurrentRange.ItemIndex := 1;
      else
        ComboCurrentRange.ItemIndex := -1;
      end;
      EditCurrentQminRate.Text := FloatToStr(FFlowMeter.Device.CurrentQminRate);
      EditCurrentQmaxRate.Text := FloatToStr(FFlowMeter.Device.CurrentQmaxRate);

      EditProtocolName.Text := FFlowMeter.Device.ProtocolName;
      ComboBaudRate.ItemIndex := ComboBaudRate.Items.IndexOf(IntToStr(FFlowMeter.Device.BaudRate));
      ComboParity.ItemIndex := FFlowMeter.Device.Parity;
      EditDeviceAddress.Text := IntToStr(FFlowMeter.Device.DeviceAddress);
      ComboInputType.ItemIndex := FFlowMeter.Device.InputType;
    end;
    ApplyOutputType;

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
  if FIsLoading or (FFlowMeter = nil) then
    Exit;

  if ComboOutputType.ItemIndex >= 0 then
  begin
    if GetActiveOutputType = GetOutputTypeByIndex(ComboOutputType.ItemIndex) then
      Exit;
    FFlowMeter.OutputType := GetOutputTypeByIndex(ComboOutputType.ItemIndex);
    if FChannel <> nil then
      FChannel.Signal := FFlowMeter.OutputType;
    if FFlowMeter.Device <> nil then
      FFlowMeter.Device.OutputType := FFlowMeter.OutputType;
    ApplyOutputType;
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


procedure TFrameFlowMeterProperties.ComboFreqOutputSetChange(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  if ComboFreqOutputSet.ItemIndex < 0 then
    Exit;
  if FFlowMeter.Device.OutputSet = ComboFreqOutputSet.ItemIndex then
    Exit;
  FFlowMeter.Device.OutputSet := ComboFreqOutputSet.ItemIndex;
  NotifyChanged;
end;


procedure TFrameFlowMeterProperties.ComboFreqViewChange(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  if ComboFreqView.ItemIndex < 0 then
    Exit;
  if FFlowMeter.Device.DimensionCoef = ComboFreqView.ItemIndex then
    Exit;
  FFlowMeter.Device.DimensionCoef := ComboFreqView.ItemIndex;
  NotifyChanged;
end;


procedure TFrameFlowMeterProperties.ComboImpulseOutputSetChange(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  if ComboImpulseOutputSet.ItemIndex < 0 then
    Exit;
  if FFlowMeter.Device.OutputSet = ComboImpulseOutputSet.ItemIndex then
    Exit;
  FFlowMeter.Device.OutputSet := ComboImpulseOutputSet.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.ComboImpulseViewChange(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  if ComboImpulseView.ItemIndex < 0 then
    Exit;
  if FFlowMeter.Device.DimensionCoef = ComboImpulseView.ItemIndex then
    Exit;
  FFlowMeter.Device.DimensionCoef := ComboImpulseView.ItemIndex;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditCoefExit(Sender: TObject);
var
  NewCoef: Double;
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  NewCoef := NormalizeFloatInput(EditCoef.Text);
  if NewCoef <= 0 then
  begin
    EditCoef.Text := FloatToStr(FFlowMeter.Device.Coef);
    Exit;
  end;
  if SameValue(FFlowMeter.Device.Coef, NewCoef) then
    Exit;
  FFlowMeter.Device.Coef := NewCoef;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFreqExit(Sender: TObject);
var
  NewFreq: Integer;
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  NewFreq := Trunc(NormalizeFloatInput(EditFreq.Text));
  if NewFreq <= 0 then
  begin
    EditFreq.Text := IntToStr(FFlowMeter.Device.Freq);
    Exit;
  end;
  FFlowMeter.Device.Freq := NewFreq;
  if FFlowMeter.Device.FreqFlowRate > 0 then
    FFlowMeter.Device.Coef := 3.6 * FFlowMeter.Device.Freq / FFlowMeter.Device.FreqFlowRate;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.EditFreqFlowRateExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;
  NewRate := NormalizeFloatInput(EditFreqFlowRate.Text);
  if NewRate <= 0 then
  begin
    EditFreqFlowRate.Text := FloatToStr(FFlowMeter.Device.FreqFlowRate);
    Exit;
  end;
  if SameValue(FFlowMeter.Device.FreqFlowRate, NewRate) then
    Exit;
  FFlowMeter.Device.FreqFlowRate := NewRate;
  if FFlowMeter.Device.FreqFlowRate > 0 then
    FFlowMeter.Device.Coef := 3.6 * FFlowMeter.Device.Freq / FFlowMeter.Device.FreqFlowRate;
  NotifyChanged;
end;


procedure TFrameFlowMeterProperties.OutputComboChange(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) or
     not (Sender is TComboBox) then
    Exit;

  case TComboBox(Sender).Tag of
    1:
      case TComboBox(Sender).ItemIndex of
        0: FFlowMeter.Device.VoltageRange := 10;
        1: FFlowMeter.Device.VoltageRange := 5;
        2: FFlowMeter.Device.VoltageRange := 24;
      end;
    2:
      case TComboBox(Sender).ItemIndex of
        0: FFlowMeter.Device.CurrentRange := 20;
        1: FFlowMeter.Device.CurrentRange := 0;
      end;
    3:
      FFlowMeter.Device.BaudRate := StrToIntDef(TComboBox(Sender).Text,
        FFlowMeter.Device.BaudRate);
    4:
      FFlowMeter.Device.Parity := TComboBox(Sender).ItemIndex;
    5:
      FFlowMeter.Device.InputType := TComboBox(Sender).ItemIndex;
  end;
  NotifyChanged;
end;

procedure TFrameFlowMeterProperties.OutputEditExit(Sender: TObject);
begin
  if FIsLoading or (FFlowMeter = nil) or (FFlowMeter.Device = nil) or
     not (Sender is TEdit) then
    Exit;

  case TEdit(Sender).Tag of
    1: FFlowMeter.Device.VoltageQminRate := NormalizeFloatInput(TEdit(Sender).Text);
    2: FFlowMeter.Device.VoltageQmaxRate := NormalizeFloatInput(TEdit(Sender).Text);
    3: FFlowMeter.Device.CurrentQminRate := NormalizeFloatInput(TEdit(Sender).Text);
    4: FFlowMeter.Device.CurrentQmaxRate := NormalizeFloatInput(TEdit(Sender).Text);
    5: FFlowMeter.Device.ProtocolName := Trim(TEdit(Sender).Text);
    6: FFlowMeter.Device.DeviceAddress := StrToIntDef(TEdit(Sender).Text,
         FFlowMeter.Device.DeviceAddress);
  end;
  NotifyChanged;
end;

end.
