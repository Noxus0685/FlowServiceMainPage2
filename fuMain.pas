unit fuMain;

interface

uses
  fuTypeSelect,
  fuMeterValues,
  UnitDataManager,
  UnitMeterValue,
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
    StringColumnEtalonQuantity1: TStringColumn;
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
    StringColumnDeviceQuantity1: TStringColumn;
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
    LabelNameFreq: TLabel;
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
    LabelPressure: TLabel;
    LabelNamePressure: TLabel;
    EditPres: TEdit;
    Layout50: TLayout;
    LabelNameDensity: TLabel;
    Rectangle12: TRectangle;
    LabelDensity: TLabel;
    Layout6: TLayout;
    Rectangle7: TRectangle;
    LabelTemp: TLabel;
    Layout7: TLayout;
    LabelNameTemperture: TLabel;
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
    LabelNameFlowRate: TLabel;
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
    LabelNameTime: TLabel;
    EditTime: TEdit;
    Layout47: TLayout;
    ComboEdit8: TComboEdit;
    SpeedButton23: TSpeedButton;
    SpeedButton24: TSpeedButton;
    Label53: TLabel;
    Layout49: TLayout;
    Rectangle9: TRectangle;
    LabelQuantity: TLabel;
    LabelNameQuantity: TLabel;
    EditVolume: TEdit;
    Layout51: TLayout;
    LabelNameImp: TLabel;
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
    TimerSetValues: TTimer;
    TimerMain: TTimer;
    ActionMeterValueProperties: TAction;
    MenuItem8: TMenuItem;
    TabItemTest: TTabItem;
    LayoutTestValues: TLayout;
    GroupBoxEtalonChannels: TGroupBox;
    LabelEtalonCurSec: TLabel;
    LabelEtalonImpSec: TLabel;
    LabelEtalonImpResult: TLabel;
    EditEtalonCurSec: TEdit;
    EditEtalonImpSec: TEdit;
    EditEtalonImpResult: TEdit;
    ButtonApplyEtalonValues: TButton;
    GroupBoxDeviceChannels: TGroupBox;
    LabelDeviceCurSec: TLabel;
    LabelDeviceImpSec: TLabel;
    LabelDeviceImpResult: TLabel;
    EditDeviceCurSec: TEdit;
    EditDeviceImpSec: TEdit;
    EditDeviceImpResult: TEdit;
    ButtonApplyDeviceValues: TButton;
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
    procedure ActionMeterValuesPropertiesExecute(Sender: TObject);
    procedure TimerSetValuesTimer(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
    procedure ComboEditUnitsChange(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
    procedure ButtonApplyEtalonValuesClick(Sender: TObject);
    procedure ButtonApplyDeviceValuesClick(Sender: TObject);
  private

  FActiveWorkTable: TWorkTable;
    { Private declarations }
  FLastClickRow: Integer;
  FLastClickCol: TColumn;
  FLastClickTick: Cardinal;


    FFlowMeters: TObjectList<TFlowMeter>;
    FFlowMeterRows: TArray<TFlowMeterRowData>;
    FNextClimateChangeAt: TDateTime;
    procedure UpdateRandomClimate(const AWorkTable: TWorkTable);
    procedure UpdateRandomSignals(const AWorkTable: TWorkTable);
    procedure OpenTypeSelect(ARow: Integer);
    procedure InitTables;
    procedure ApplyFlowMeterSelection(const ARow: Integer);
    function FindTypeIndex(const ATypeName: string): Integer;
    function FindSerialIndex(const ASerialNumber: string): Integer;
    function GetWorkTableByIndex(const AIndex: Integer): TWorkTable;
    procedure UpdateGridDevices;
    procedure UpdateUIFromValues;
    procedure SetValues;

     procedure UpdateGrids;
    procedure ApplyChannelValues(AChannels: TObjectList<TChannel>; const ACurSec,
      AImpSec, AImpResult: Double);

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
  CVolumeFlowUnits: array[0..4] of string = (
    'л/с',
    'л/мин',
    'л/ч',
    'м3/мин',
    'м3/ч'
  );

  CMassFlowUnits: array[0..4] of string = (
    'кг/с',
    'кг/мин',
    'кг/ч',
    'т/мин',
    'т/ч'
  );

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

function IsVolumeFlowUnit(const AUnit: string): Boolean;
var
  I: Integer;
begin
  for I := Low(CVolumeFlowUnits) to High(CVolumeFlowUnits) do
    if SameText(AUnit, CVolumeFlowUnits[I]) then
      Exit(True);
  Result := False;
end;

function ResolveQuantityUnitByFlowUnit(const AUnit: string): string;
begin
  if SameText(AUnit, 'л/с') or SameText(AUnit, 'л/мин') or SameText(AUnit, 'л/ч') then
    Exit('л');
  if SameText(AUnit, 'м3/мин') or SameText(AUnit, 'м3/ч') then
    Exit('м3');
  if SameText(AUnit, 'кг/с') or SameText(AUnit, 'кг/мин') or SameText(AUnit, 'кг/ч') then
    Exit('кг');
  if SameText(AUnit, 'т/мин') or SameText(AUnit, 'т/ч') then
    Exit('т');
  Result := '';
end;

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
  UnitName: string;

begin
  TMeterValue.LoadFromFile;

  FWorkTableManager := TWorkTableManager.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'TableSettings.ini'
  );

  FWorkTableManager.Load;

  GridDevices.RowCount := 2;

  // Заполняем список через имя колонки
  PopupColumnDeviceSignal1.Items.Clear;

  for OT := otFrequency to High(TOutputType) do
    PopupColumnDeviceSignal1.Items.Add(GetOutputTypeName(OT));

  PopupColumnEtalonSignal1.Items.Assign(PopupColumnDeviceSignal1.Items);

  ComboEditUnits.Items.Clear;
  for UnitName in CVolumeFlowUnits do
    ComboEditUnits.Items.Add(UnitName);
  for UnitName in CMassFlowUnits do
    ComboEditUnits.Items.Add(UnitName);
  ComboEditUnits.OnChange := ComboEditUnitsChange;
  if ComboEditUnits.Items.Count > 0 then
    ComboEditUnits.ItemIndex := 0;

  SetLength(FRows, 0);

  InitTables;
  if ComboEditUnits.ItemIndex >= 0 then
    ComboEditUnitsChange(ComboEditUnits);

  FLastClickRow := -1;
  FLastClickCol := nil;
  FLastClickTick := 0;

  Randomize;
  FNextClimateChangeAt := Now;
end;

procedure TFormMain.ComboEditUnitsChange(Sender: TObject);
var
  WorkTable: TWorkTable;
  I: Integer;
  UnitName: string;
  QuantityUnitName: string;
  IsVolumeUnits: Boolean;
  Meter: TFlowMeter;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  UnitName := Trim(ComboEditUnits.Text);
  if UnitName = '' then
    Exit;

  IsVolumeUnits := IsVolumeFlowUnit(UnitName);
  QuantityUnitName := ResolveQuantityUnitByFlowUnit(UnitName);

  Meter := nil;
  if (WorkTable.EtalonChannels.Count > 0) and (WorkTable.EtalonChannels[0] <> nil) then
    Meter := WorkTable.EtalonChannels[0].FlowMeter;
  if (Meter = nil) and (WorkTable.DeviceChannels.Count > 0) and (WorkTable.DeviceChannels[0] <> nil) then
    Meter := WorkTable.DeviceChannels[0].FlowMeter;

  if WorkTable.ValueFlowRate <> nil then
    WorkTable.ValueFlowRate.SetDim(UnitName);

  if (WorkTable.ValueQuantity <> nil) and (QuantityUnitName <> '') then
    WorkTable.ValueQuantity.SetDim(QuantityUnitName);

  for I := 0 to WorkTable.DeviceChannels.Count - 1 do
  begin
    if (WorkTable.DeviceChannels[I] = nil) or (WorkTable.DeviceChannels[I].FlowMeter = nil) then
      Continue;

    Meter := WorkTable.DeviceChannels[I].FlowMeter;
    if IsVolumeUnits then
    begin
      Meter.ValueQuantity := Meter.ValueVolume;
      Meter.ValueFlow := Meter.ValueVolumeFlow;
      if Meter.ValueVolume <> nil then
        Meter.ValueVolume.SetDim(QuantityUnitName);
      if Meter.ValueVolumeFlow <> nil then
        Meter.ValueVolumeFlow.SetDim(UnitName);
    end
    else
    begin
      Meter.ValueQuantity := Meter.ValueMass;
      Meter.ValueFlow := Meter.ValueMassFlow;
      if Meter.ValueMass <> nil then
        Meter.ValueMass.SetDim(QuantityUnitName);
      if Meter.ValueMassFlow <> nil then
        Meter.ValueMassFlow.SetDim(UnitName);
    end;
  end;

  for I := 0 to WorkTable.EtalonChannels.Count - 1 do
  begin
    if (WorkTable.EtalonChannels[I] = nil) or (WorkTable.EtalonChannels[I].FlowMeter = nil) then
      Continue;

    Meter := WorkTable.EtalonChannels[I].FlowMeter;
    if IsVolumeUnits then
    begin
      Meter.ValueQuantity := Meter.ValueVolume;
      Meter.ValueFlow := Meter.ValueVolumeFlow;
      if Meter.ValueVolume <> nil then
        Meter.ValueVolume.SetDim(QuantityUnitName);
      if Meter.ValueVolumeFlow <> nil then
        Meter.ValueVolumeFlow.SetDim(UnitName);
    end
    else
    begin
      Meter.ValueQuantity := Meter.ValueMass;
      Meter.ValueFlow := Meter.ValueMassFlow;
      if Meter.ValueMass <> nil then
        Meter.ValueMass.SetDim(QuantityUnitName);
      if Meter.ValueMassFlow <> nil then
        Meter.ValueMassFlow.SetDim(UnitName);
    end;
  end;

  WorkTable.RecalculateAllMeterValues;
  UpdateUIFromValues;
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
  FActiveWorkTable := GetWorkTableByIndex(0);
  if FActiveWorkTable <> nil then
    FActiveWorkTable.RebindAllFlowMeters;

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

    Tab := FindComponent('TabItemWorkTable' + IntToStr(I)) as TTabItem;
    if Assigned(Tab) then
      Tab.Text := WorkTable.Text;

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
        FRows[TableCount].ChannelName := WorkTable.EtalonChannels[TableCount].Text;
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
  WorkTable.Name := TWorkTable.BuildWorkTableServiceName(WorkTable.ID);
  WorkTable.Text := 'Рабочий стол ' + IntToStr(WorkTable.ID);
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
    TWorkTable.BuildChannelDefaultText(ChannelIndex),
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
    TWorkTable.BuildChannelDefaultText(ChannelIndex),

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

procedure TFormMain.ActionMeterValuesPropertiesExecute(Sender: TObject);
var
  Frm: TFormMeterValues;
  MV: TMeterValue;
  WorkTable: TWorkTable;
  Row: Integer;
begin
  MV := nil;
  WorkTable := FActiveWorkTable;

  if (WorkTable <> nil) and (WorkTable.DeviceChannels.Count > 0) then
  begin
    Row := GridDevices.Row;
    if (Row < 0) or (Row >= WorkTable.DeviceChannels.Count) then
      Row := 0;

    if (WorkTable.DeviceChannels[Row] <> nil) and
       (WorkTable.DeviceChannels[Row].FlowMeter <> nil) then
      MV := WorkTable.DeviceChannels[Row].FlowMeter.ValueFlow;
  end;

  if (MV = nil) and (TMeterValue.GetMeterValues <> nil) and
     (TMeterValue.GetMeterValues.Count > 0) then
    MV := TMeterValue.GetMeterValues[0];

  if MV = nil then
  begin
    ShowMessage('Нет доступных MeterValue для редактирования.');
    Exit;
  end;

  Frm := TFormMeterValues.Create(Self);
  try
    Frm.MeterValue := MV;
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFormMain.UpdateRandomClimate(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

  if (FNextClimateChangeAt = 0) or (Now >= FNextClimateChangeAt) then
  begin
    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;

    AWorkTable.Temp := EnsureRange(AWorkTable.Temp + TempDelta, -50.0, 150.0);
    AWorkTable.Press := EnsureRange(AWorkTable.Press + PressDelta, 0.0, 10.0);

    FNextClimateChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
  end;
end;

procedure TFormMain.UpdateRandomSignals(const AWorkTable: TWorkTable);
var
  I: Integer;
  Channel: TChannel;
  CurDelta: Double;
  ImpDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
  begin
    Channel := AWorkTable.EtalonChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random * 0.06) - 0.03;
    ImpDelta := Random(11) - 5;

    Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
    Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, 0.0, 1000000.0);
    Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
  end;

  for I := 0 to AWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := AWorkTable.DeviceChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random * 0.6) - 0.3;
    ImpDelta := Random(11) - 5;

    Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
    Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, 0.0, 1000000.0);
    Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
  end;
end;

procedure TFormMain.TimerSetValuesTimer(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  UpdateRandomClimate(WorkTable);
  UpdateRandomSignals(WorkTable);
  SetValues;
end;

procedure TFormMain.SetValues;
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

  WorkTable.Time := WorkTable.Time + 1;
  WorkTable.ValueTime.SetValue(WorkTable.Time);

  // Основные MeterValues эталонных каналов.
  for I := 0 to WorkTable.EtalonChannels.Count - 1 do
  begin
    EtalonChannel := WorkTable.EtalonChannels[I];
    if (EtalonChannel = nil) or (EtalonChannel.FlowMeter = nil) then
      Continue;

    EtalonChannel.ValueCurrent.SetValue(EtalonChannel.CurSec);
    EtalonChannel.ValueImp.SetValue(EtalonChannel.ImpSec);
    EtalonChannel.ValueImpTotal.SetValue(EtalonChannel.ImpResult);
  end;

  // Основные MeterValues каналов приборов.
  for I := 0 to WorkTable.DeviceChannels.Count - 1 do
  begin
    DeviceChannel := WorkTable.DeviceChannels[I];
    if (DeviceChannel = nil) or (DeviceChannel.FlowMeter = nil) then
      Continue;

    DeviceChannel.ValueCurrent.SetValue(DeviceChannel.CurSec);
    DeviceChannel.ValueImp.SetValue(DeviceChannel.ImpSec);
    DeviceChannel.ValueImpTotal.SetValue(DeviceChannel.ImpResult);
    DeviceChannel.ValueInterface.SetValue(DeviceChannel.ValueSec);
  end;

  WorkTable.RecalculateAllMeterValues;
end;

procedure TFormMain.TimerMainTimer(Sender: TObject);
begin
  UpdateUIFromValues;
  UpdateGrids;
end;

procedure TFormMain.UpdateUIFromValues;
var
  WorkTable: TWorkTable;
  DeviceMeter: TFlowMeter;
  EtalonMeter: TFlowMeter;
  MeterForNames: TFlowMeter;
  I: Integer;
  MinImpValue: TMeterValue;
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

  MeterForNames := EtalonMeter;
  if MeterForNames = nil then
    MeterForNames := DeviceMeter;

  GridDevices.Repaint;
  GridEtalons.Repaint;

  if WorkTable.ValueTime <> nil then
    LabelTime.Text := FormatFloat('0', WorkTable.ValueTime.GetDoubleValue)
  else
    LabelTime.Text := '0';

  if WorkTable.ValueTemperture <> nil then
    LabelTemp.Text :=    WorkTable.ValueTemperture.GetStrValue
  else
    LabelTemp.Text := '0';

  if WorkTable.ValuePressure <> nil then
    EditPres.Text := WorkTable.ValuePressure.GetStrValue
  else
    EditPres.Text := '0';

  if WorkTable.ValueFlowRate <> nil then
    LabelFlowRate.Text := WorkTable.ValueFlowRate.GetStrValue
  else
    LabelFlowRate.Text := '0';

  if WorkTable.ValuePressure <> nil then
    LabelPressure.Text := WorkTable.ValuePressure.GetStrValue
  else
    LabelPressure.Text := '0';

  if (MeterForNames <> nil) and (MeterForNames.ValueDensity <> nil) then
    LabelDensity.Text := MeterForNames.ValueDensity.GetStrValue
  else
    LabelDensity.Text := '0';

  if WorkTable.ValueQuantity <> nil then
    LabelQuantity.Text := WorkTable.ValueQuantity.GetStrValue
  else
    LabelQuantity.Text := '0';

  if MeterForNames <> nil then
  begin
    if MeterForNames.ValueFlow <> nil then
      LabelNameFlowRate.Text :=  'Расход, ' + WorkTable.ValueFlowRate.GetDimName;
    if MeterForNames.ValueTime <> nil then
      LabelNameTime.Text := MeterForNames.ValueTime.GetStrFullName;
    if MeterForNames.ValueQuantity <> nil then
      LabelNameQuantity.Text := MeterForNames.ValueQuantity.GetStrFullName;
    if MeterForNames.ValueImp <> nil then
      LabelNameImp.Text := MeterForNames.ValueImp.GetStrFullName;
    if MeterForNames.ValuePressure <> nil then
      LabelNamePressure.Text := MeterForNames.ValuePressure.GetStrFullName;
    if MeterForNames.ValueDensity <> nil then
      LabelNameDensity.Text := MeterForNames.ValueDensity.GetStrFullName;
    if MeterForNames.ValueTemperture <> nil then
      LabelNameTemperture.Text := MeterForNames.ValueTemperture.GetStrFullName;
  end;

  MinImpValue := nil;
  for I := 0 to WorkTable.DeviceChannels.Count - 1 do
    if (WorkTable.DeviceChannels[I] <> nil) and (WorkTable.DeviceChannels[I].ValueImp <> nil) then
    begin
      if (MinImpValue = nil) or
         (WorkTable.DeviceChannels[I].ValueImp.GetDoubleValue < MinImpValue.GetDoubleValue) then
        MinImpValue := WorkTable.DeviceChannels[I].ValueImp;
    end;

  if MinImpValue <> nil then
    LabelImp.Text := MinImpValue.GetStrValue
  else
    LabelImp.Text := '0';

  if WorkTable.ValueFlowRate <> nil then
  begin
    StringColumnDeviceFlowRate1.Header := 'Расход, ' + WorkTable.ValueFlowRate.GetDimName;
    StringColumnEtalonFlowRate1.Header := 'Расход, ' +WorkTable.ValueFlowRate.GetDimName;
  end;
  if WorkTable.ValueQuantity <> nil then
  begin
    StringColumnDeviceQuantity1.Header := WorkTable.ValueQuantity.GetStrFullName;
    StringColumnEtalonQuantity1.Header := WorkTable.ValueQuantity.GetStrFullName;
  end;

  if DeviceMeter <> nil then
  begin
    if WorkTable.ValueFlowRate <> nil then
      StringColumnDeviceFlowRate1.TagString := WorkTable.ValueFlowRate.GetStrValue
    else
      StringColumnDeviceFlowRate1.TagString := '0';

    if WorkTable.ValueQuantity <> nil then
      StringColumnDeviceQuantity1.TagString := WorkTable.ValueQuantity.GetStrValue
    else
      StringColumnDeviceQuantity1.TagString := '0';
  end;

  if EtalonMeter <> nil then
  begin
    if WorkTable.ValueFlowRate <> nil then
      StringColumnEtalonFlowRate1.TagString := WorkTable.ValueFlowRate.GetStrValue
    else
      StringColumnEtalonFlowRate1.TagString := '0';

    if WorkTable.ValueQuantity <> nil then
      StringColumnEtalonQuantity1.TagString := WorkTable.ValueQuantity.GetStrValue
    else
      StringColumnEtalonQuantity1.TagString := '0';
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
    FActiveWorkTable.RecalculateAllMeterValues;

    UpdateGrids;
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
      Value := WorkTable.DeviceChannels[ARow].Text
    else if GridDevices.Columns[ACol] = ColumnDeviceType1 then
      Value := WorkTable.DeviceChannels[ARow].TypeName
    else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
      Value := WorkTable.DeviceChannels[ARow].Serial
    else if GridDevices.Columns[ACol] = StringColumnDeviceFlowRate1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow.GetStrValue
      else
        Value := '0';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceQuantity1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.GetStrValue
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
      WorkTable.DeviceChannels[ARow].Text := Value.AsString
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
      Value := WorkTable.EtalonChannels[ARow].Text
    else if GridEtalons.Columns[ACol] = StringColumnEtalonType1 then
      Value := WorkTable.EtalonChannels[ARow].TypeName
    else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
      Value := WorkTable.EtalonChannels[ARow].Serial
    else if GridEtalons.Columns[ACol] = StringColumnEtalonFlowRate1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow.GetStrValue
      else
        Value := '0';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonQuantity1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity.GetStrValue
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

procedure ReloadGridByGrowingRowCount(AGrid: TGrid; ANewRowCount: Integer);
var
  i: Integer;
  Sel: Integer;
begin
  if AGrid = nil then Exit;

  Sel := AGrid.Selected;

  AGrid.BeginUpdate;
  try
    AGrid.RowCount := 0;

    // добавляем строки по одной
    for i := 1 to ANewRowCount do
      AGrid.RowCount := i;

  finally
    AGrid.EndUpdate;
  end;

  // вернуть выделение (если осталось валидным)
  if (Sel >= 0) and (Sel < AGrid.RowCount) then
    AGrid.Selected := Sel;

  AGrid.Repaint;
end;

procedure TFormMain.UpdateGrids;
var
  WT: TWorkTable;
begin
  WT := GetWorkTableByIndex(0);

  if WT <> nil then
    ReloadGridByGrowingRowCount(GridDevices, WT.DeviceChannels.Count)
  else
    ReloadGridByGrowingRowCount(GridDevices, Length(FFlowMeterRows));

  // для эталонов аналогично — подставь свой источник строк
  ReloadGridByGrowingRowCount(GridEtalons, GridEtalons.RowCount);
end;


procedure TFormMain.ApplyChannelValues(AChannels: TObjectList<TChannel>; const ACurSec,
  AImpSec, AImpResult: Double);
var
  I: Integer;
  Channel: TChannel;
begin
  if AChannels = nil then
    Exit;

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    if Channel = nil then
      Continue;

    Channel.CurSec := ACurSec;
    Channel.ImpSec := AImpSec;
    if AImpResult > 0 then
      Channel.ImpResult := EnsureRange(AImpResult, 0.0, 1.0E12)
    else
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
  end;
end;

procedure TFormMain.ButtonApplyEtalonValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := GetWorkTableByIndex(0);
  if WorkTable = nil then
    Exit;

  ApplyChannelValues(
    WorkTable.EtalonChannels,
    NormalizeFloatInput(EditEtalonCurSec.Text),
    NormalizeFloatInput(EditEtalonImpSec.Text),
    NormalizeFloatInput(EditEtalonImpResult.Text)
  );
  SetValues;
end;

procedure TFormMain.ButtonApplyDeviceValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := GetWorkTableByIndex(0);
  if WorkTable = nil then
    Exit;

  ApplyChannelValues(
    WorkTable.DeviceChannels,
    NormalizeFloatInput(EditDeviceCurSec.Text),
    NormalizeFloatInput(EditDeviceImpSec.Text),
    NormalizeFloatInput(EditDeviceImpResult.Text)
  );
  SetValues;
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
      WorkTable.EtalonChannels[ARow].Text := Value.AsString
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
