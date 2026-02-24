unit fuMain;

interface

uses
  fuTypeSelect,
  UnitDataManager,
  UnitDeviceClass,
  UnitFlowMeter,
  UnitClasses,
  UnitRepositories,
  UnitWorkTable,
  UnitBaseProcedures,
  System.Math,
  System.Generics.Collections,


  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Filter.Effects, FMX.Colors, FMX.Effects, FMX.ListBox,
  FMX.Edit, FMX.StdCtrls, FMX.ComboEdit, FMX.EditBox, FMX.SpinBox, FMX.Objects,
  FMX.Grid, FMX.ScrollBox, FMX.Layouts, FMX.Controls.Presentation,
  FMX.TabControl, FMX.Menus, System.Actions, FMX.ActnList;



type

  TRowData = record
    Enabled: Boolean;
    ChannelName: string;
    TypeName: string;
    Serial: string;
    SignalName: string;
  end;

  TFlowMeterRowData = record
    Enabled: Boolean;
    Channel: Integer;
    Meter: TFlowMeter;
    TypeIndex: Integer;
    SerialIndex: Integer;
    SignalName: string;
  end;

  TFormMain = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabControlWorkTables: TTabControl;
    TabItemWorkTable1: TTabItem;
    Panel2: TPanel;
    Layout1: TLayout;
    GridEtalons: TGrid;
    CheckColumnEtalonEnable1: TCheckColumn;
    StringColumnEtalonChanel1: TStringColumn;
    StringColumnEtalonType1: TStringColumn;
    StringColumnEtalonSerial1: TStringColumn;
    StringColumnEtalonFlowRate1: TStringColumn;
    StringColumnEtalonVolume1: TStringColumn;
    StringColumnEtalonError1: TStringColumn;
    ToolBar2: TToolBar;
    Label30: TLabel;
    Panel3: TPanel;
    GridDevices: TGrid;
    CheckColumnDeviceEnable1: TCheckColumn;
    StringColumnDeviceChanel1: TStringColumn;
    ColumnDeviceType1: TColumn;
    StringColumnDeviceSerial1: TStringColumn;
    StringColumnDeviceFlowRate1: TStringColumn;
    StringColumnDeviceVolume1: TStringColumn;
    StringColumnDeviceError1: TStringColumn;
    ToolBar1: TToolBar;
    Label23: TLabel;
    PanelMain: TPanel;
    PanelInstruments: TPanel;
    LayoutPump: TLayout;
    Line1: TLine;
    Layout3: TLayout;
    LayoutFrequancy: TLayout;
    Rectangle1: TRectangle;
    LabelFreq: TLabel;
    LayoutFreqIn: TLayout;
    Label15: TLabel;
    SpinBoxFreq: TSpinBox;
    LayoutPumpSelect: TLayout;
    ComboEditPumps: TComboEdit;
    SpeedButton3: TSpeedButton;
    SpeedButton28: TSpeedButton;
    Rectangle14: TRectangle;
    Label14: TLabel;
    LayoutConditions: TLayout;
    Layout9: TLayout;
    Layout42: TLayout;
    Rectangle11: TRectangle;
    LabelPres: TLabel;
    Label24: TLabel;
    EditPres: TEdit;
    Layout50: TLayout;
    Label25: TLabel;
    Rectangle12: TRectangle;
    Label13: TLabel;
    Layout6: TLayout;
    Rectangle7: TRectangle;
    LabelTemp: TLabel;
    Layout7: TLayout;
    Label21: TLabel;
    EditTemp: TEdit;
    Label22: TLabel;
    Line3: TLine;
    LayoutFlowRate: TLayout;
    Line5: TLine;
    Layout5: TLayout;
    Layout12: TLayout;
    Rectangle2: TRectangle;
    LabelFlowRate: TLabel;
    Layout13: TLayout;
    Label17: TLabel;
    SpinBoxFlowRate: TSpinBox;
    Layout14: TLayout;
    ComboEditUnits: TComboEdit;
    SpeedButton9: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Rectangle15: TRectangle;
    Label19: TLabel;
    LayoutMain: TLayout;
    Line6: TLine;
    Layout16: TLayout;
    LayoutTaskMain: TLayout;
    ComboBoxTaskMain: TComboBox;
    SpeedButton11: TSpeedButton;
    SpeedButton27: TSpeedButton;
    Rectangle13: TRectangle;
    Label32: TLabel;
    LayoutTaskAddition: TLayout;
    SpeedButton12: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    ComboBoxTaskStep: TComboBox;
    Label36: TLabel;
    LayoutMesure: TLayout;
    Line13: TLine;
    Layout44: TLayout;
    Layout45: TLayout;
    Rectangle8: TRectangle;
    Label51: TLabel;
    Layout46: TLayout;
    Label52: TLabel;
    Edit11: TEdit;
    Layout17: TLayout;
    Rectangle3: TRectangle;
    LabelTime: TLabel;
    Layout48: TLayout;
    Label54: TLabel;
    EditTime: TEdit;
    Layout47: TLayout;
    ComboEdit8: TComboEdit;
    SpeedButton23: TSpeedButton;
    SpeedButton24: TSpeedButton;
    Label53: TLabel;
    Layout49: TLayout;
    Rectangle9: TRectangle;
    LabelVolume: TLabel;
    Label56: TLabel;
    EditVolume: TEdit;
    Layout51: TLayout;
    Label55: TLabel;
    EditImp: TEdit;
    Rectangle10: TRectangle;
    LabelImp: TLabel;
    TabItem2: TTabItem;
    ControlBar: TLayout;
    rctToolsPanelBackground: TRectangle;
    tbShemeColor: TToolBar;
    rct3: TRectangle;
    pnlShemeColor: TPanel;
    Label4: TLabel;
    cbSHEME_COLOR: TComboBox;
    shdwfct12: TShadowEffect;
    pnlBackColor: TPanel;
    Label3: TLabel;
    cbBACK_COLOR: TComboColorBox;
    ShadowEffect11: TShadowEffect;
    lbMainToolButtons: TLayout;
    tbMainPanel: TToolBar;
    rct2: TRectangle;
    sbSaveProject: TSpeedButton;
    ShadowEffect5: TShadowEffect;
    sbSaveSettings: TSpeedButton;
    ShadowEffect6: TShadowEffect;
    sbSetup: TSpeedButton;
    shdwfct4: TShadowEffect;
    sbSound: TSpeedButton;
    ShadowEffect7: TShadowEffect;
    sbToolPosition: TSpeedButton;
    ShadowEffect8: TShadowEffect;
    ebEditProject: TSpeedButton;
    ShadowEffect2: TShadowEffect;
    btnWorkLog: TSpeedButton;
    ShadowEffect4: TShadowEffect;
    btnProjectInfo: TSpeedButton;
    ShadowEffect3: TShadowEffect;
    SpeedButton1: TSpeedButton;
    ShadowEffect15: TShadowEffect;
    tcShemeElements: TTabControl;
    tiControl: TTabItem;
    btnCreatePump: TSpeedButton;
    btnCreateUnoperatedPump: TSpeedButton;
    btnCreatePnevmoValve: TSpeedButton;
    btnCreateElectroValve: TSpeedButton;
    btnCreateBlcdValve: TSpeedButton;
    btnCreateUPP: TSpeedButton;
    btnCreateFlowmeter: TSpeedButton;
    btnCreateTermometer: TSpeedButton;
    btnCreateManometer: TSpeedButton;
    btnCreateFlowmetersPanel: TSpeedButton;
    btnCreateLevelDetector: TSpeedButton;
    btnCreateWaterLevel: TSpeedButton;
    btnCreateScale: TSpeedButton;
    shdwfct5: TShadowEffect;
    tiPipeAndFittings: TTabItem;
    btnCreateElbow: TSpeedButton;
    btnCreateCross: TSpeedButton;
    btnCreateTee: TSpeedButton;
    btnCreateFlange: TSpeedButton;
    btnCreateHorisontalPipe: TSpeedButton;
    btnCreateVerticalPipe: TSpeedButton;
    btnCreatePump_1: TSpeedButton;
    btnCreateMotor: TSpeedButton;
    btnCreate8: TSpeedButton;
    btnCreatefitTank_V: TSpeedButton;
    btnCreate10: TSpeedButton;
    btnCreatefitTank_H: TSpeedButton;
    btnCreatePump_2: TSpeedButton;
    btnCreatePump_3: TSpeedButton;
    shdwfct6: TShadowEffect;
    tiAnimation: TTabItem;
    btnCreateGroupBox: TSpeedButton;
    btnCreateText: TSpeedButton;
    tiUserComponents: TTabItem;
    btnAddUserPrimitive: TSpeedButton;
    btnDeleteUserPrimitive: TSpeedButton;
    shdwfct14: TShadowEffect;
    tbEditProject: TToolBar;
    rct4: TRectangle;
    btnComponentsVisible: TSpeedButton;
    shdwfct9: TShadowEffect;
    btnAnimateVisible: TSpeedButton;
    ShadowEffect1: TShadowEffect;
    btnDeleteComponet: TSpeedButton;
    shdwfct10: TShadowEffect;
    lytWorkTask: TLayout;
    Label11: TLabel;
    cbMainTask: TComboBox;
    sbRunStop: TSpeedButton;
    sbPause: TSpeedButton;
    ShadowEffect10: TShadowEffect;
    btnAbout: TSpeedButton;
    shdwfct11: TShadowEffect;
    lytWorkDesktop: TLayout;
    Label12: TLabel;
    PerspectiveTransformEffect1: TPerspectiveTransformEffect;
    cbWorkDesktop: TComboBox;
    Splitter1: TSplitter;
    ShadowEffect9: TShadowEffect;
    shdwfct8: TShadowEffect;
    TabItem3: TTabItem;
    PopupColumnEtalonSignal1: TPopupColumn;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PopupColumnDeviceSignal1: TPopupColumn;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    PopupMenuWorkTables: TPopupMenu;
    miAddTable: TMenuItem;
    miAddDeviceChannel: TMenuItem;
    miAddEtalonChannel: TMenuItem;
    ActionListWorkTables: TActionList;
    ActionAddWorkTable: TAction;
    ActionAddDeviceChannel: TAction;
    ActionAddEtalonChannel: TAction;
    ActionSaveWorkTable: TAction;
    miSaveWorkTable: TMenuItem;
    PopupMenuInstrumentalLayOut: TPopupMenu;
    miFlowRate: TMenuItem;
    miPump: TMenuItem;
    miMain: TMenuItem;
    miMesurment: TMenuItem;
    miConditions: TMenuItem;
    SpeedButtonMinimizePumpLayout: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure GridEtalonsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridEtalonsSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridEtalonsCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDevicesGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridDevicesSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridDevicesCellClick(const Column: TColumn; const Row: Integer);
    procedure ActionAddWorkTableExecute(Sender: TObject);
    procedure ActionAddDeviceChannelExecute(Sender: TObject);
    procedure ActionAddEtalonChannelExecute(Sender: TObject);
    procedure ActionSaveWorkTableExecute(Sender: TObject);
    procedure TimerSetValuesTimer(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
  private

  FActiveWorkTable: TWorkTable;
    { Private declarations }
  FLastClickRow: Integer;
  FLastClickCol: TColumn;
  FLastClickTick: Cardinal;


    FFlowMeters: TObjectList<TFlowMeter>;
    FFlowMeterRows: TArray<TFlowMeterRowData>;
    procedure OpenTypeSelect(ARow: Integer);
    procedure InitFlowMeters;
    procedure InitTables;
    procedure ApplyFlowMeterSelection(const ARow: Integer);
    function FindTypeIndex(const ATypeName: string): Integer;
    function FindSerialIndex(const ASerialNumber: string): Integer;
    function GetWorkTableByIndex(const AIndex: Integer): TWorkTable;
    procedure UpdateGridDevices;
  public
    { Public declarations }
    destructor Destroy; override;
  private
    FWorkTableManager: TWorkTableManager;
  end;


var
  FormMain: TFormMain;

  FRows: array of TRowData;

implementation

{$R *.fmx}

const
  CFlowMeterTypes: array[0..2] of string = (
    'Расходомер ПРЭМ',
    'Расходомер ЭЛЕМЕР',
    'Расходомер ВЗЛЕТ'
  );

  CFlowMeterSerials: array[0..3] of string = (
    'SN-1001',
    'SN-1002',
    'SN-1003',
    'SN-1004'
  );

function TryGetOutputTypeFromValue(const AValue: TValue; out ASignal: Integer): Boolean;
var
  OT: TOutputType;
  SignalName: string;
begin
  Result := False;
  ASignal := Ord(otUnknown);

  if AValue.IsType<Integer> then
  begin
    ASignal := AValue.AsInteger;
    Exit(True);
  end;

  if not AValue.IsType<string> then
    Exit;

  SignalName := AValue.AsString;
  for OT := Low(TOutputType) to High(TOutputType) do
    if SameText(GetOutputTypeName(OT), SignalName) then
    begin
      ASignal := Ord(OT);
      Exit(True);
    end;
end;

function MeterValueToText(AMeterValue: TMeterValue; const AFormat: string = '0.###'): string;
begin
  if AMeterValue = nil then
    Exit('0');

  Result := FormatFloat(AFormat, AMeterValue.GetDoubleValue);
end;

destructor TFormMain.Destroy;
begin
  TMeterValue.SaveToFile(0);
  FWorkTableManager.Free;
  FFlowMeters.Free;
  inherited;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  OT: TOutputType;

begin
  TMeterValue.LoadFromFile;

  FWorkTableManager := TWorkTableManager.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'TableSettings.ini'
  );
  FWorkTableManager.Load;



  FFlowMeters := TObjectList<TFlowMeter>.Create(True);

  GridDevices.RowCount := 2;

  // Заполняем список через имя колонки
  PopupColumnDeviceSignal1.Items.Clear;

  for OT := otFrequency to High(TOutputType) do
    PopupColumnDeviceSignal1.Items.Add(GetOutputTypeName(OT));

  PopupColumnEtalonSignal1.Items.Assign(PopupColumnDeviceSignal1.Items);

  SetLength(FRows, 0);

  InitFlowMeters;
  InitTables;

  FLastClickRow := -1;
FLastClickCol := nil;
FLastClickTick := 0;
end;

function TFormMain.GetWorkTableByIndex(const AIndex: Integer): TWorkTable;
begin
  Result := nil;
  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
    Exit;

  if (AIndex < 0) or (AIndex >= FWorkTableManager.WorkTables.Count) then
    Exit;

  Result := FWorkTableManager.WorkTables[AIndex];
end;

procedure TFormMain.InitTables;
var
  TableCount: Integer;
  WorkTable: TWorkTable;
  Tab: TTabItem;
  GridEtalonsN, GridDevicesN: TGrid;
  I, LimitCount: Integer;
begin
  TableCount := 0;
  if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
    TableCount := FWorkTableManager.WorkTables.Count;

  //FActiveWorkTable:=FWorkTableManager.ActiveWorkTable;
    FActiveWorkTable:= GetWorkTableByIndex(0);

  TabItemWorkTable1.Visible := TableCount >= 1;

  Tab := FindComponent('TabItemWorkTable2') as TTabItem;
  if Assigned(Tab) then
    Tab.Visible := TableCount >= 2;

  Tab := FindComponent('TabItemWorkTable3') as TTabItem;
  if Assigned(Tab) then
    Tab.Visible := TableCount >= 3;

  LimitCount := Min(TableCount, 3);

  for I := 1 to LimitCount do
  begin
    WorkTable := GetWorkTableByIndex(I - 1);
    if WorkTable = nil then
      Continue;

    GridEtalonsN := FindComponent('GridEtalons' + IntToStr(I)) as TGrid;
    if (GridEtalonsN = nil) and (I = 1) then
      GridEtalonsN := GridEtalons;

    if Assigned(GridEtalonsN) then
    begin
      GridEtalonsN.RowCount := WorkTable.EtalonChannels.Count;
      GridEtalonsN.Repaint;
    end;

    GridDevicesN := FindComponent('GridDevices' + IntToStr(I)) as TGrid;
    if (GridDevicesN = nil) and (I = 1) then
      GridDevicesN := GridDevices;

    if Assigned(GridDevicesN) then
    begin
      GridDevicesN.RowCount := WorkTable.DeviceChannels.Count;
      GridDevicesN.Repaint;
    end;

    if I = 1 then
    begin
      SetLength(FRows, WorkTable.EtalonChannels.Count);
      for TableCount := 0 to WorkTable.EtalonChannels.Count - 1 do
      begin
        FRows[TableCount].Enabled := WorkTable.EtalonChannels[TableCount].Enabled;
        FRows[TableCount].ChannelName := WorkTable.EtalonChannels[TableCount].Name;
        FRows[TableCount].TypeName := WorkTable.EtalonChannels[TableCount].TypeName;
        FRows[TableCount].Serial := WorkTable.EtalonChannels[TableCount].Serial;
        FRows[TableCount].SignalName := GetOutputTypeName(WorkTable.EtalonChannels[TableCount].Signal);
      end;

      SetLength(FFlowMeterRows, WorkTable.DeviceChannels.Count);
      for TableCount := 0 to WorkTable.DeviceChannels.Count - 1 do
      begin
        FFlowMeterRows[TableCount].Enabled := WorkTable.DeviceChannels[TableCount].Enabled;
        FFlowMeterRows[TableCount].Channel := TableCount + 1;
        FFlowMeterRows[TableCount].Meter := nil;
        FFlowMeterRows[TableCount].SignalName := GetOutputTypeName(WorkTable.DeviceChannels[TableCount].Signal);
      end;
    end;
  end;
end;

procedure TFormMain.InitFlowMeters;
var
  I: Integer;
  Meter: TFlowMeter;
begin
  FFlowMeters.Clear;
  SetLength(FFlowMeterRows, 3);

  for I := 0 to High(FFlowMeterRows) do
  begin
    Meter := TFlowMeter.Create(False);
    Meter.SetChannel(I + 1);
  //  Meter.DeviceTypeName := CFlowMeterTypes[I mod Length(CFlowMeterTypes)];
  //  Meter.SerialNumber := CFlowMeterSerials[I mod Length(CFlowMeterSerials)];
    FFlowMeters.Add(Meter);

    FFlowMeterRows[I].Enabled := True;
    FFlowMeterRows[I].Channel := I + 1;
    FFlowMeterRows[I].Meter := Meter;
   // FFlowMeterRows[I].TypeIndex := FindTypeIndex(Meter.DeviceTypeName);
   // FFlowMeterRows[I].SerialIndex := FindSerialIndex(Meter.SerialNumber);
  end;

  GridDevices.RowCount := Length(FFlowMeterRows);
  GridDevices.Repaint;
end;

function TFormMain.FindTypeIndex(const ATypeName: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(CFlowMeterTypes) do
    if SameText(CFlowMeterTypes[I], ATypeName) then
      Exit(I);
end;

function TFormMain.FindSerialIndex(const ASerialNumber: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(CFlowMeterSerials) do
    if SameText(CFlowMeterSerials[I], ASerialNumber) then
      Exit(I);
end;

procedure TFormMain.ActionAddWorkTableExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
    Exit;

  WorkTable := TWorkTable.Create;
  WorkTable.ID := FWorkTableManager.WorkTables.Count + 1;
  WorkTable.Name := 'Рабочий стол ' + IntToStr(WorkTable.ID);
  FWorkTableManager.WorkTables.Add(WorkTable);

  InitTables;

  if FWorkTableManager.WorkTables.Count > 0 then
    TabControlWorkTables.TabIndex := EnsureRange(
      FWorkTableManager.WorkTables.Count - 1,
      0,
      Max(0, TabControlWorkTables.TabCount - 1)
    );
end;

procedure TFormMain.ActionAddDeviceChannelExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  ChannelIndex: Integer;
begin
  WorkTable := GetWorkTableByIndex(TabControlWorkTables.TabIndex);
  if WorkTable = nil then
    Exit;

  ChannelIndex := WorkTable.DeviceChannels.Count + 1;
  WorkTable.AddDeviceChannel(
    True,
    -1,
    IntToStr(ChannelIndex),
    '',
    'Импульсный',
    ''
  );

  InitTables;
end;

procedure TFormMain.ActionAddEtalonChannelExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  ChannelIndex: Integer;
begin
  WorkTable := GetWorkTableByIndex(TabControlWorkTables.TabIndex);
  if WorkTable = nil then
    Exit;

  ChannelIndex := WorkTable.EtalonChannels.Count + 1;
  WorkTable.AddEtalonChannel(
    True,
    -1,
    IntToStr(ChannelIndex),

    '',
    'Импульсный',
    ''
  );

  InitTables;
end;

procedure TFormMain.ActionSaveWorkTableExecute(Sender: TObject);
begin
  if FWorkTableManager = nil then
    Exit;

  FWorkTableManager.Save;
end;

procedure TFormMain.TimerSetValuesTimer(Sender: TObject);
var
  WorkTable: TWorkTable;
  I: Integer;
  DeviceChannel: TChannel;
  EtalonChannel: TChannel;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  // Основные MeterValues рабочего стола.
  WorkTable.ValueTempertureBefore.SetValue(WorkTable.Temp);
  WorkTable.ValueTempertureAfter.SetValue(WorkTable.Temp);
  WorkTable.ValuePressureBefore.SetValue(WorkTable.Press);
  WorkTable.ValuePressureAfter.SetValue(WorkTable.Press);

  // Основные MeterValues каналов прибора.
  for I := 0 to WorkTable.DeviceChannels.Count - 1 do
  begin
    DeviceChannel := WorkTable.DeviceChannels[I];
    if (DeviceChannel = nil) or (DeviceChannel.FlowMeter = nil) then
      Continue;

    DeviceChannel.FlowMeter.ValueFlow.SetValue(WorkTable.FlowRate);
    DeviceChannel.FlowMeter.ValueQuantity.SetValue(DeviceChannel.FlowMeter.ValueQuantity.GetDoubleValue + WorkTable.FlowRate);
    DeviceChannel.FlowMeter.ValueVolume.SetValue(DeviceChannel.FlowMeter.ValueQuantity.GetDoubleValue);
    DeviceChannel.FlowMeter.ValueTemperture.SetValue(WorkTable.Temp);
    DeviceChannel.FlowMeter.ValueTime.SetValue(WorkTable.Time);
  end;

  // Основные MeterValues эталонных каналов.
  for I := 0 to WorkTable.EtalonChannels.Count - 1 do
  begin
    EtalonChannel := WorkTable.EtalonChannels[I];
    if (EtalonChannel = nil) or (EtalonChannel.FlowMeter = nil) then
      Continue;

    EtalonChannel.FlowMeter.ValueFlow.SetValue(WorkTable.FlowRate);
    EtalonChannel.FlowMeter.ValueQuantity.SetValue(EtalonChannel.FlowMeter.ValueQuantity.GetDoubleValue + WorkTable.FlowRate);
    EtalonChannel.FlowMeter.ValueVolume.SetValue(EtalonChannel.FlowMeter.ValueQuantity.GetDoubleValue);
    EtalonChannel.FlowMeter.ValueTemperture.SetValue(WorkTable.Temp);
    EtalonChannel.FlowMeter.ValueTime.SetValue(WorkTable.Time);
  end;
end;

procedure TFormMain.TimerMainTimer(Sender: TObject);
var
  WorkTable: TWorkTable;
  DeviceMeter: TFlowMeter;
  EtalonMeter: TFlowMeter;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  DeviceMeter := nil;
  if WorkTable.DeviceChannels.Count > 0 then
    DeviceMeter := WorkTable.DeviceChannels[0].FlowMeter;

  EtalonMeter := nil;
  if WorkTable.EtalonChannels.Count > 0 then
    EtalonMeter := WorkTable.EtalonChannels[0].FlowMeter;

  // Обновление таблиц по основным MeterValues.
  GridDevices.Repaint;
  GridEtalons.Repaint;

  // Обновление элементов формы.
  LabelTime.Text := MeterValueToText(nil, '0.0');
  LabelFlowRate.Text := MeterValueToText(nil, '0.###');
  LabelTemp.Text := MeterValueToText(nil, '0.##');

  if DeviceMeter <> nil then
  begin
    LabelTime.Text := MeterValueToText(DeviceMeter.ValueTime, '0.0');
    LabelFlowRate.Text := MeterValueToText(DeviceMeter.ValueFlow, '0.###');
    LabelTemp.Text := MeterValueToText(DeviceMeter.ValueTemperture, '0.##');
  end;

  // Явно используем основные колонки (данные берутся через GridDevicesGetValue/GridEtalonsGetValue).
  StringColumnDeviceFlowRate1.Header := 'Расход';
  StringColumnDeviceVolume1.Header := 'Объём';
  StringColumnEtalonFlowRate1.Header := 'Расход';
  StringColumnEtalonVolume1.Header := 'Объём';

  if DeviceMeter <> nil then
  begin
    StringColumnDeviceFlowRate1.TagString := MeterValueToText(DeviceMeter.ValueFlow, '0.###');
    StringColumnDeviceVolume1.TagString := MeterValueToText(DeviceMeter.ValueQuantity, '0.###');
  end;

  if EtalonMeter <> nil then
  begin
    StringColumnEtalonFlowRate1.TagString := MeterValueToText(EtalonMeter.ValueFlow, '0.###');
    StringColumnEtalonVolume1.TagString := MeterValueToText(EtalonMeter.ValueQuantity, '0.###');
  end;
end;

procedure TFormMain.ApplyFlowMeterSelection(const ARow: Integer);
begin
  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  FFlowMeterRows[ARow].TypeIndex := EnsureRange(FFlowMeterRows[ARow].TypeIndex, 0, High(CFlowMeterTypes));
  FFlowMeterRows[ARow].SerialIndex := EnsureRange(FFlowMeterRows[ARow].SerialIndex, 0, High(CFlowMeterSerials));

 // FFlowMeterRows[ARow].Meter.DeviceTypeName := CFlowMeterTypes[FFlowMeterRows[ARow].TypeIndex];
 // FFlowMeterRows[ARow].Meter.SerialNumber := CFlowMeterSerials[FFlowMeterRows[ARow].SerialIndex];
end;

procedure TFormMain.OpenTypeSelect(ARow: Integer);
var
  Frm: TFormTypeSelect;
  CurrentType, NewType: TDeviceType;
  FoundRepo: TTypeRepository;
  RepoName: string;
  IsTypeChanged, NeedFill: Boolean;
  Ch: TChannel;
begin

  if (FActiveWorkTable = nil) then
    Exit;

  if (ARow < 0) or (ARow >= FActiveWorkTable.DeviceChannels.Count) then
    Exit;

  if (DataManager = nil) then
    Exit;

  Ch := FActiveWorkTable.DeviceChannels[ARow];
  if (Ch = nil) or (Ch.FlowMeter = nil) then
    Exit;

  Frm := TFormTypeSelect.Create(Self);
  try
    {----------------------------------------------------}
    { 1. Предвыбор текущего типа }
    {----------------------------------------------------}
    CurrentType := DataManager.FindType(
      '',                     // UUID можем не знать
      Ch.TypeName,            // текущее имя типа (прокси в FlowMeter)
      FoundRepo
    );

    if (CurrentType <> nil) and (FoundRepo <> nil) then
    begin
      DataManager.ActiveTypeRepo := FoundRepo;
      Frm.SelectType(CurrentType);
    end;

    {----------------------------------------------------}
    { 2. Открываем форму выбора }
    {----------------------------------------------------}
    if Frm.ShowModal <> mrOk then
      Exit;

    NewType := Frm.SelectedType;
    if NewType = nil then
      Exit;

    FoundRepo := DataManager.ActiveTypeRepo;

    {----------------------------------------------------}
    { 3. Проверяем смену типа }
    {----------------------------------------------------}
    IsTypeChanged := True;

    if CurrentType <> nil then
    begin
      if CurrentType = NewType then
        IsTypeChanged := False
      else if (CurrentType.MitUUID <> '') and (NewType.MitUUID <> '') then
        IsTypeChanged := not SameText(CurrentType.MitUUID, NewType.MitUUID)
      else
        IsTypeChanged :=
          (CurrentType.ID <> NewType.ID) or
          (not SameText(CurrentType.Name, NewType.Name)) or
          (not SameText(CurrentType.Modification, NewType.Modification));
    end;

    NeedFill := False;
    // if IsTypeChanged then
    //   NeedFill := AskFillFromType;

    {----------------------------------------------------}
    { 4. Привязываем тип (в runtime: FlowMeter / Channel) }
    {----------------------------------------------------}
    if (DataManager.ActiveTypeRepo <> nil) then
      FoundRepo := DataManager.ActiveTypeRepo;

    if FoundRepo <> nil then
      RepoName := FoundRepo.Name
    else
      RepoName := '';

    // Новая идеология: канал проксирует в FlowMeter
    Ch.TypeName := NewType.Name;

    // Если у вас был расчёт индекса по типу для UI/сигнала — храните как отдельное поле канала/строки,
    // либо пересчитывайте динамически. Здесь оставляю как комментарий:
    // Ch.TypeIndex := FindTypeIndex(NewType.Name);

    {----------------------------------------------------}
    { 5. При необходимости заполняем данные прибора из типа }
    {----------------------------------------------------}
    // В новой модели это обычно делается на уровне привязки TDevice к каналу:
    // if NeedFill and Assigned(Ch.FlowMeter.Device) then
    // begin
    //   Ch.FlowMeter.Device.AttachType(NewType, RepoName);
    //   Ch.FlowMeter.Device.FillFromType(NewType);
    // end;

    {----------------------------------------------------}
    { 6. Обновляем UI }
    {----------------------------------------------------}
    UpdateGridDevices;  // подставь имя своего грида
    // SetModified;
  finally
    Frm.Free;
  end;
end;

procedure TFormMain.SpeedButton2Click(Sender: TObject);
begin
 LayoutPump.Visible := False;
end;

procedure TFormMain.SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
begin
      LayoutPump.Visible:=False;
end;

procedure TFormMain.GridDevicesCellClick(const Column: TColumn; const Row: Integer);
const
  SECOND_CLICK_MS = 700; // окно "второго клика" (подбери по ощущениям)
var
  Tick: Cardinal;
  IsSecondClick: Boolean;
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  WorkTable := GetWorkTableByIndex(0);
  if (WorkTable <> nil) and ((Row < 0) or (Row >= WorkTable.DeviceChannels.Count)) then
    Exit;

  if (WorkTable = nil) and ((Row < 0) or (Row >= Length(FFlowMeterRows))) then
    Exit;

  Rows := GridDevices.RowCount;
  Tick := TThread.GetTickCount;
  GridDevices.ReadOnly := True;

  IsSecondClick :=
    (Row = FLastClickRow) and
    (Column = FLastClickCol);

  FLastClickRow := Row;
  FLastClickCol := Column;
  FLastClickTick := Tick;

  if (Column = CheckColumnDeviceEnable1) then
  begin
    if WorkTable <> nil then
      WorkTable.DeviceChannels[Row].Enabled := not WorkTable.DeviceChannels[Row].Enabled
    else
      FFlowMeterRows[Row].Enabled := not FFlowMeterRows[Row].Enabled;
  end;

    if (Column = PopupColumnDeviceSignal1 ) then
  begin
    GridDevices.ReadOnly:=False;
    GridDevices.EditorMode := True;
    inherited;
    Exit;
  end;

  if IsSecondClick then
  begin
    if Column = ColumnDeviceType1 then
    begin
      GridDevices.EditorMode := False;
      if WorkTable <> nil then
        OpenTypeSelect(Row);
    end
    else if Column = StringColumnDeviceSerial1 then
    begin
      GridDevices.ReadOnly := False;
      GridDevices.EditorMode := True;

      if WorkTable = nil then
      begin
        FFlowMeterRows[Row].SerialIndex :=
          (FFlowMeterRows[Row].SerialIndex + 1) mod Length(CFlowMeterSerials);
        ApplyFlowMeterSelection(Row);
      end;
    end;
  end;

  GridDevices.BeginUpdate;
  try
    GridDevices.RowCount := Rows;
  finally
    GridDevices.EndUpdate;
  end;
end;

procedure TFormMain.GridDevicesGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.DeviceChannels.Count) then
  begin
    if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
      Value := WorkTable.DeviceChannels[ARow].Enabled
    else if GridDevices.Columns[ACol] = StringColumnDeviceChanel1 then
      Value := WorkTable.DeviceChannels[ARow].Name
    else if GridDevices.Columns[ACol] = ColumnDeviceType1 then
      Value := WorkTable.DeviceChannels[ARow].TypeName
    else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
      Value := WorkTable.DeviceChannels[ARow].Serial
    else if GridDevices.Columns[ACol] = StringColumnDeviceFlowRate1 then
    begin
      if WorkTable.DeviceChannels[ARow].FlowMeter <> nil then
        Value := MeterValueToText(WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow, '0.###')
      else
        Value := '0';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceVolume1 then
    begin
      if WorkTable.DeviceChannels[ARow].FlowMeter <> nil then
        Value := MeterValueToText(WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity, '0.###')
      else
        Value := '0';
    end
    else if GridDevices.Columns[ACol] = PopupColumnDeviceSignal1 then
      Value := GetOutputTypeName(WorkTable.DeviceChannels[ARow].Signal);
    Exit;
  end;

  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;


end;

procedure TFormMain.GridDevicesSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
var
  WorkTable: TWorkTable;
  Signal: Integer;
begin
  WorkTable := GetWorkTableByIndex(0);
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.DeviceChannels.Count) then
  begin
    if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
      WorkTable.DeviceChannels[ARow].Enabled := Value.AsBoolean
    else if GridDevices.Columns[ACol] = StringColumnDeviceChanel1 then
      WorkTable.DeviceChannels[ARow].Name := Value.AsString
    else if GridDevices.Columns[ACol] = ColumnDeviceType1 then
      WorkTable.DeviceChannels[ARow].TypeName := Value.AsString
    else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
      WorkTable.DeviceChannels[ARow].Serial := Value.AsString
    else if GridDevices.Columns[ACol] = PopupColumnDeviceSignal1 then
      if TryGetOutputTypeFromValue(Value, Signal) then
        WorkTable.DeviceChannels[ARow].Signal := Signal;
    Exit;
  end;

  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  GridDevices.ReadOnly := True;
end;

procedure TFormMain.GridEtalonsCellClick(const Column: TColumn;
  const Row: Integer);
const
  SECOND_CLICK_MS = 700;
var
  Tick: Cardinal;
  IsSecondClick: Boolean;
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  WorkTable := GetWorkTableByIndex(0);

  if (WorkTable <> nil) and ((Row < 0) or (Row >= WorkTable.EtalonChannels.Count)) then
    Exit;

  if (WorkTable = nil) and ((Row < 0) or (Row >= Length(FRows))) then
    Exit;

  Rows := GridEtalons.RowCount;
  Tick := TThread.GetTickCount;
  GridEtalons.ReadOnly := True;

  IsSecondClick :=
    (Row = FLastClickRow) and
    (Column = FLastClickCol) and
    (Tick - FLastClickTick <= SECOND_CLICK_MS);

  FLastClickRow := Row;
  FLastClickCol := Column;
  FLastClickTick := Tick;

  if Column = CheckColumnEtalonEnable1 then
  begin
    if WorkTable <> nil then
      WorkTable.EtalonChannels[Row].Enabled := not WorkTable.EtalonChannels[Row].Enabled
    else
      FRows[Row].Enabled := not FRows[Row].Enabled;
  end;

  if Column = PopupColumnEtalonSignal1 then
  begin
    GridEtalons.ReadOnly := False;
    GridEtalons.EditorMode := True;
    inherited;
    Exit;
  end;

  if IsSecondClick then
  begin
    if Column = StringColumnEtalonType1 then
    begin
      GridEtalons.EditorMode := False;
      if WorkTable <> nil then
        OpenTypeSelect(Row);
    end
    else if Column = StringColumnEtalonSerial1 then
    begin
      GridEtalons.ReadOnly := False;
      GridEtalons.EditorMode := True;
    end;
  end;

  GridEtalons.BeginUpdate;
  try
    GridEtalons.RowCount := Rows;
  finally
    GridEtalons.EndUpdate;
  end;
end;


procedure TFormMain.GridEtalonsGetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.EtalonChannels.Count) then
  begin
    if GridEtalons.Columns[ACol] = CheckColumnEtalonEnable1 then
      Value := WorkTable.EtalonChannels[ARow].Enabled
    else if GridEtalons.Columns[ACol] = StringColumnEtalonChanel1 then
      Value := WorkTable.EtalonChannels[ARow].Name
    else if GridEtalons.Columns[ACol] = StringColumnEtalonType1 then
      Value := WorkTable.EtalonChannels[ARow].TypeName
    else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
      Value := WorkTable.EtalonChannels[ARow].Serial
    else if GridEtalons.Columns[ACol] = StringColumnEtalonFlowRate1 then
    begin
      if WorkTable.EtalonChannels[ARow].FlowMeter <> nil then
        Value := MeterValueToText(WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow, '0.###')
      else
        Value := '0';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonVolume1 then
    begin
      if WorkTable.EtalonChannels[ARow].FlowMeter <> nil then
        Value := MeterValueToText(WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity, '0.###')
      else
        Value := '0';
    end
    else if GridEtalons.Columns[ACol] = PopupColumnEtalonSignal1 then
      Value := GetOutputTypeName(WorkTable.EtalonChannels[ARow].Signal);
    Exit;
  end;

  if (ARow < 0) or (ARow >= Length(FRows)) then
    Exit;

  if GridEtalons.Columns[ACol] = CheckColumnEtalonEnable1 then
    Value := FRows[ARow].Enabled
  else if GridEtalons.Columns[ACol] = StringColumnEtalonChanel1 then
    Value := FRows[ARow].ChannelName
  else if GridEtalons.Columns[ACol] = StringColumnEtalonType1 then
    Value := FRows[ARow].TypeName
  else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
    Value := FRows[ARow].Serial
  else if GridEtalons.Columns[ACol] = PopupColumnEtalonSignal1 then
    Value := FRows[ARow].SignalName;
end;

 procedure TFormMain.UpdateGridDevices;
  var  Rows: Integer;
 begin
   Rows:= GridDevices.RowCount;

    GridDevices.BeginUpdate;

    GridDevices.RowCount := 0;

  try
    GridDevices.RowCount := Rows;
  finally
    GridDevices.EndUpdate;
  end;


 end;


procedure TFormMain.GridEtalonsSetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
var
  WorkTable: TWorkTable;
  Signal: Integer;
begin
  WorkTable := GetWorkTableByIndex(0);
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.EtalonChannels.Count) then
  begin
    if GridEtalons.Columns[ACol] = CheckColumnEtalonEnable1 then
      WorkTable.EtalonChannels[ARow].Enabled := Value.AsBoolean
    else if GridEtalons.Columns[ACol] = StringColumnEtalonChanel1 then
      WorkTable.EtalonChannels[ARow].Name := Value.AsString
    else if GridEtalons.Columns[ACol] = StringColumnEtalonType1 then
      WorkTable.EtalonChannels[ARow].TypeName := Value.AsString
    else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
      WorkTable.EtalonChannels[ARow].Serial := Value.AsString
    else if GridEtalons.Columns[ACol] = PopupColumnEtalonSignal1 then
      if TryGetOutputTypeFromValue(Value, Signal) then
        WorkTable.EtalonChannels[ARow].Signal := Signal;
    Exit;
  end;

  if (ARow < 0) or (ARow >= Length(FRows)) then
    Exit;

  if GridEtalons.Columns[ACol] = CheckColumnEtalonEnable1 then
    FRows[ARow].Enabled := Value.AsBoolean
  else if GridEtalons.Columns[ACol] = StringColumnEtalonChanel1 then
    FRows[ARow].ChannelName := Value.AsString
  else if GridEtalons.Columns[ACol] = StringColumnEtalonType1 then
    FRows[ARow].TypeName := Value.AsString
  else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
    FRows[ARow].Serial := Value.AsString
  else if GridEtalons.Columns[ACol] = PopupColumnEtalonSignal1 then
    FRows[ARow].SignalName := Value.AsString;

  GridEtalons.ReadOnly := True;
end;

end.
