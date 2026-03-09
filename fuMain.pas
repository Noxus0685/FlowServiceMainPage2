unit fuMain;

interface

uses
  fuDeviceSelect,
  fuTypeSelect,
  fuDeviceEdit,
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
  FMX.TabControl, FMX.Menus, System.Actions, FMX.ActnList, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.Memo.Types,
  FMX.Memo, FMX.DateTimeCtrls, FMX.TreeView, FMX.ListView;



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

  TResultGridRow = record
    Name: string;
    DeviceType: string;
    Serial: string;
    PointValues: TArray<string>;
    ResultText: string;
  end;

  TFormMain = class(TForm)
    TabControl1: TTabControl;
    TabItemTable: TTabItem;
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
    SpeedButtonStartPump: TSpeedButton;
    SpeedButton28: TSpeedButton;
    Rectangle14: TRectangle;
    LabelLayoutPump: TLabel;
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
    LabelLayoutConditions: TLabel;
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
    ComboEditUnits: TComboBox;
    SpeedButtonSetFlowRate: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Rectangle15: TRectangle;
    LabelLayoutFlowRate: TLabel;
    Line6: TLine;
    Layout16: TLayout;
    LayoutTaskMain: TLayout;
    ComboBoxTaskMain: TComboBox;
    SpeedButtonSpillageStart: TSpeedButton;
    SpeedButtonSpillageStop: TSpeedButton;
    Rectangle13: TRectangle;
    LabelLayoutMain: TLabel;
    LayoutTaskAddition: TLayout;
    SpeedButtonTaskPause: TSpeedButton;
    SpeedButtonTaskNext: TSpeedButton;
    SpeedButtonTaskPrevious: TSpeedButton;
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
    LabelLayoutMesure: TLabel;
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
    TabItemMnemo: TTabItem;
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
    TabItemResults: TTabItem;
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
    miProcedures: TMenuItem;
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
    ActionOpenDeviceEditor: TAction;
    ActionOpenDeviceSelect: TAction;
    MenuItem9: TMenuItem;
    SpeedButtonMinimizeLayoutMain: TSpeedButton;
    SpeedButtonMinimzeLayoutFlowRate: TSpeedButton;
    SpeedButtonMinimizeMesure: TSpeedButton;
    SpeedButtonMinimizeConditions: TSpeedButton;
    LayoutMain: TLayout;
    StringColumnEtalonName1: TStringColumn;
    StringColumnDeviceName1: TStringColumn;
    StringColumnDeviceStd1: TStringColumn;
    StringColumnEtalonStd1: TStringColumn;
    StringColumnEtalonRawValue1: TStringColumn;
    StringColumnDeviceRawValue1: TStringColumn;
    StringColumnEtalonPressureDelta1: TStringColumn;
    StringColumnDeviceQuantityBefore1: TStringColumn;
    StringColumnDeviceQuantityAfter1: TStringColumn;
    StringColumnDevicePressureDelta1: TStringColumn;
    PopupMenuEtalonsGridLayOut: TPopupMenu;
    PopupMenuDevicesGridLayOut: TPopupMenu;
    PopupMenuDevicesGrid: TPopupMenu;
    MenuItemDevicesClearRow: TMenuItem;
    MenuItemDevicesCopy: TMenuItem;
    MenuItemDevicesPaste: TMenuItem;
    MenuItemDevicesSep1: TMenuItem;
    MenuItemDevicesClearAll: TMenuItem;
    MenuItemDevicesFillAllBySelected: TMenuItem;
    MenuItemDevicesSep2: TMenuItem;
    MenuItemDevicesFromArchive: TMenuItem;
    MenuItemDevicesSep3: TMenuItem;
    MenuItemDevicesSetFlowSource: TMenuItem;
    MenuItemDevicesAssignEtalon: TMenuItem;
    PopupMenuEtalonsGrid: TPopupMenu;
    MenuItemEtalonsClearRow: TMenuItem;
    MenuItemEtalonsCopy: TMenuItem;
    MenuItemEtalonsPaste: TMenuItem;
    MenuItemEtalonsSep1: TMenuItem;
    MenuItemEtalonsClearAll: TMenuItem;
    MenuItemEtalonsFillAllBySelected: TMenuItem;
    MenuItemEtalonsSep2: TMenuItem;
    MenuItemEtalonsFromArchive: TMenuItem;
    MenuItemEtalonsSep3: TMenuItem;
    MenuItemEtalonsSetFlowSource: TMenuItem;
    MenuItemEtalonsAssignEtalon: TMenuItem;
    StringColumnDeviceOptions1: TStringColumn;
    StringColumnEtalonOptions1: TStringColumn;
    LayoutProcedures: TLayout;
    Line2: TLine;
    Layout4: TLayout;
    Layout8: TLayout;
    ComboBoxProcedure: TComboBox;
    SpeedButtonProcedureStart: TSpeedButton;
    SpeedButtonProcedureStop: TSpeedButton;
    Rectangle4: TRectangle;
    LabelLayoutProcedures: TLabel;
    SpeedButtonMinimizeProcedures: TSpeedButton;
    Layout10: TLayout;
    SpeedButtonStepPause: TSpeedButton;
    SpeedButtonStepNext: TSpeedButton;
    SpeedButtonStepPrevious: TSpeedButton;
    ComboBoxStep: TComboBox;
    Label2: TLabel;
    SpeedButtonTest: TSpeedButton;
    Circle1: TCircle;
    HorzScrollBoxInstrumental: THorzScrollBox;
    Layout2: TLayout;
    Layout11: TLayout;
    Button1: TButton;
    Circle2: TCircle;
    ButtonMonitor: TButton;
    CircleIndicatorMonitor: TCircle;
    Layout15: TLayout;
    ButtonCancel: TButton;
    GlowEffect1: TGlowEffect;
    GlowEffect2: TGlowEffect;
    GlowEffectCancelRed: TGlowEffect;
    GlowMesYellow: TGlowEffect;
    GlowMesGreen: TGlowEffect;
    GlowMesRed: TGlowEffect;
    TestButton: TButton;
    StringColumnEtalonRawSumValue1: TStringColumn;
    StringColumnDeviceRawSumValue1: TStringColumn;
    EditTestNum: TEdit;
    LabelTestNum: TLabel;
    Label5: TLabel;
    Switch1: TSwitch;
    Label1: TLabel;
    ActionCopyType: TAction;
    ActionFillAllTypes: TAction;
    ActionDevicesClearRow: TAction;
    ActionDevicesCopy: TAction;
    ActionDevicesPaste: TAction;
    ActionDevicesClearAll: TAction;
    ActionDevicesFillAllBySelected: TAction;
    ActionDevicesFromArchive: TAction;
    ActionDevicesSetFlowSource: TAction;
    ActionDevicesAssignEtalon: TAction;
    ActionEtalonsClearRow: TAction;
    ActionEtalonsCopy: TAction;
    ActionEtalonsPaste: TAction;
    ActionEtalonsClearAll: TAction;
    ActionEtalonsFillAllBySelected: TAction;
    ActionEtalonsFromArchive: TAction;
    ActionEtalonsSetFlowSource: TAction;
    ActionEtalonsAssignEtalon: TAction;
    LayoutLeft: TLayout;
    lvFlowmeterTypes: TListView;
    TreeViewDevices: TTreeView;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    ToolBar3: TToolBar;
    ComboBoxRepository: TComboBox;
    Label6: TLabel;
    LayoutRight: TLayout;
    Layout18: TLayout;
    GridDataPoints: TGrid;
    StringColumnName: TStringColumn;
    StringColumnSpillageNum: TStringColumn;
    StringColumnSpillageDateTime: TStringColumn;
    StringColumnSpillageOperator: TStringColumn;
    StringColumnSpillageEtalonName: TStringColumn;
    StringColumnSpillageSpillTime: TStringColumn;
    StringColumnSpillageQavgEtalon: TStringColumn;
    StringColumnSpillageEtalonVolume: TStringColumn;
    StringColumnSpillageEtalonMass: TStringColumn;
    StringColumnSpillageQEtalonStd: TStringColumn;
    StringColumnSpillageQEtalonCV: TStringColumn;
    StringColumnSpillageDeviceVolume: TStringColumn;
    StringColumnSpillageDeviceMass: TStringColumn;
    StringColumnSpillageVelocity: TStringColumn;
    StringColumnSpillageError: TStringColumn;
    StringColumnSpillageValid: TStringColumn;
    StringColumnSpillageQStd: TStringColumn;
    StringColumnSpillageQCV: TStringColumn;
    StringColumnSpillageVolumeBefore: TStringColumn;
    StringColumnSpillageVolumeAfter: TStringColumn;
    StringColumnSpillagePulseCount: TStringColumn;
    StringColumnSpillageMeanFrequency: TStringColumn;
    StringColumnSpillageAvgCurrent: TStringColumn;
    StringColumnSpillageAvgVoltage: TStringColumn;
    StringColumnSpillageData1: TStringColumn;
    StringColumnSpillageData2: TStringColumn;
    StringColumnSpillageStartTemperature: TStringColumn;
    StringColumnSpillageEndTemperature: TStringColumn;
    StringColumnSpillageAvgTemperature: TStringColumn;
    StringColumnSpillageInputPressure: TStringColumn;
    StringColumnSpillageOutputPressure: TStringColumn;
    StringColumnSpillageDensity: TStringColumn;
    StringColumnSpillageAmbientTemperature: TStringColumn;
    StringColumnSpillageAtmosphericPressure: TStringColumn;
    StringColumnSpillageRelativeHumidity: TStringColumn;
    StringColumnSpillageCoef: TStringColumn;
    StringColumnSpillageFCDCoefficient: TStringColumn;
    StringColumnSpillageArchivedData: TStringColumn;
    ToolBar4: TToolBar;
    Line4: TLine;
    Layout32: TLayout;
    ButtonDeviceDelete: TButton;
    ButtonDeviceAdd: TButton;
    ButtonDeviceClear: TButton;
    Layout19: TLayout;
    sbClear: TSpeedButton;
    sbFind: TSpeedButton;
    EditFindDevice: TEdit;
    SpeedButtonFindInternet: TSpeedButton;
    Layout20: TLayout;
    Label7: TLabel;
    DateEditFilter: TDateEdit;
    Line7: TLine;
    MemoLog: TMemo;
    lyt1: TLayout;
    btnOK: TCornerButton;
    CornerButton1: TCornerButton;
    CornerButtonEditDevice: TCornerButton;
    Splitter2: TSplitter;
    GridResults: TGrid;
    StringColumnResultName: TStringColumn;
    StringColumnResultSerial: TStringColumn;
    StringColumnResultType: TStringColumn;
    StringColumnPointNum1: TStringColumn;
    StringColumnPointNum2: TStringColumn;
    StringColumnPointNum3: TStringColumn;
    StringColumnPointNum4: TStringColumn;
    StringColumnResult: TStringColumn;
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
    procedure ComboBoxUnitsChange(Sender: TObject);
    procedure SetDim(FlowUnitName: string; QuantityUnitName: string);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
    procedure ButtonApplyEtalonValuesClick(Sender: TObject);
    procedure ButtonApplyDeviceValuesClick(Sender: TObject);
    procedure ActionOpenDeviceEditorExecute(Sender: TObject);
    procedure ActionOpenDeviceSelectExecute(Sender: TObject);
    procedure SpeedButtonMinimizeMesureClick(Sender: TObject);
    procedure SpeedButtonMinimizeConditionsClick(Sender: TObject);
    procedure SpeedButtonMinimizeLayoutMainClick(Sender: TObject);
    procedure SpeedButtonMinimizeProceduresClick(Sender: TObject);
    procedure SpeedButtonMinimzeLayoutFlowRateClick(Sender: TObject);
    procedure PopupMenuInstrumentalLayOutPopup(Sender: TObject);
    procedure MenuInstrumentalLayOutClick(Sender: TObject);
    procedure PopupMenuDevicesGridLayOutPopup(Sender: TObject);
    procedure PopupMenuEtalonsGridLayOutPopup(Sender: TObject);
    procedure MenuGridLayOutClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Circle1Click(Sender: TObject);
    procedure ButtonMonitorClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure EditTestNumExit(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure TreeViewDevicesChange(Sender: TObject);
    procedure GridDataPointsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridResultsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure ActionDevicesClearRowExecute(Sender: TObject);
    procedure ActionDevicesCopyExecute(Sender: TObject);
    procedure ActionDevicesPasteExecute(Sender: TObject);
    procedure ActionDevicesClearAllExecute(Sender: TObject);
    procedure ActionDevicesFillAllBySelectedExecute(Sender: TObject);
    procedure ActionDevicesFromArchiveExecute(Sender: TObject);
    procedure ActionDevicesSetFlowSourceExecute(Sender: TObject);
    procedure ActionDevicesAssignEtalonExecute(Sender: TObject);
    procedure ActionEtalonsClearRowExecute(Sender: TObject);
    procedure ActionEtalonsCopyExecute(Sender: TObject);
    procedure ActionEtalonsPasteExecute(Sender: TObject);
    procedure ActionEtalonsClearAllExecute(Sender: TObject);
    procedure ActionEtalonsFillAllBySelectedExecute(Sender: TObject);
    procedure ActionEtalonsFromArchiveExecute(Sender: TObject);
    procedure ActionEtalonsSetFlowSourceExecute(Sender: TObject);
    procedure ActionEtalonsAssignEtalonExecute(Sender: TObject);


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
    procedure OpenChannelDeviceEditor(AChannel: TChannel);
    procedure SelectDeviceForChannel(AChannel: TChannel);
    procedure InitTables;
    procedure ApplyFlowMeterSelection(const ARow: Integer);
    function FindTypeIndex(const ATypeName: string): Integer;
    function FindSerialIndex(const ASerialNumber: string): Integer;
    function GetWorkTableByIndex(const AIndex: Integer): TWorkTable;
    procedure UpdateGridDevices;
    procedure UpdateUIFromValues;
    procedure SetValues;
    procedure FillGridLayOutPopup(AMenu: TPopupMenu; AGrid: TGrid);
    procedure FillGridDevicesActionsPopup(AMenu: TPopupMenu);
    function IsHeaderPopup(AMenu: TPopupMenu; AGrid: TGrid): Boolean;
    procedure GridDevicesActionsMenuClick(Sender: TObject);
    procedure SaveLayoutSettingsToWorkTable;
    procedure LoadLayoutSettingsFromWorkTable;
    procedure CaptureGridColumnsLayout(AGrid: TGrid; out AColumns: TArray<TGridColumnLayout>);
    procedure ApplyGridColumnsLayout(AGrid: TGrid; const AColumns: TArray<TGridColumnLayout>);
    procedure MarkChannelDeviceModified(AChannel: TChannel);
    procedure ApplyMonitorIndicatorColor(const AColor: TAlphaColor);
    procedure RefreshMonitorIndicator;
    procedure ResetMeasurementValues;
    procedure OnChangeState(const ANewState: TMeasurementState);
    procedure SetConfiguration;
    procedure StartMonitor;
    procedure StopMonitor;
    procedure StartTest;
    procedure StopTest;
    procedure SaveMeasurementResults;

    procedure UpdateGrids;
    procedure RefreshResultsTab;
    procedure PopulateTreeViewDevices;
    procedure ShowAllDevicesResults;
    procedure ShowDeviceSpillages(ADevice: TDevice);
    procedure UpdateResultsPointColumns;
    procedure ApplyChannelValues(AChannels: TObjectList<TChannel>; const ACurSec,
      AImpSec, AImpResult: Double);
       procedure UpdateForm;
    procedure ClearChannelData(AChannel: TChannel);
    procedure CopyChannelData(ASource, ADest: TChannel);
    function GetSelectedChannel(AChannels: TObjectList<TChannel>; AGrid: TGrid): TChannel;

  public
    { Public declarations }
    destructor Destroy; override;
  private
    FWorkTableManager: TWorkTableManager;
    FCurrentResultRows: TArray<TResultGridRow>;
    FCurrentSpillages: TArray<TPointSpillage>;
    FInstrumentalVisibleOrder: TList<TLayout>;
    function GetLayoutByMenuItem(AMenuItem: TMenuItem): TLayout;
    procedure RebuildInstrumentalVisibleOrder;
    procedure ApplyInstrumentalVisibleOrder;
    procedure SetInstrumentalLayoutVisible(ALayout: TLayout; AVisible: Boolean);
    function GetLayoutOrderKey(ALayout: TLayout): string;
    function GetLayoutByOrderKey(const AKey: string): TLayout;
    function GetInstrumentalVisibleOrderAsString: string;
    procedure UpdatePanelInstrumentsHeight;
    procedure RestoreInstrumentalLayoutsByFlags(const AFlowRateVisible, APumpVisible,
      AMainVisible, AMesureVisible, AConditionsVisible, AProceduresVisible: Boolean;
      const AOrder: string = '');
  private type
    TChannelClipboardData = record
      HasData: Boolean;
      Snapshot: TChannel;
    end;
  private
    FDeviceClipboard: TChannelClipboardData;
    FEtalonClipboard: TChannelClipboardData;
    procedure SaveChannelToClipboard(AChannel: TChannel; var AClipboard: TChannelClipboardData);
    procedure LoadChannelFromClipboard(AChannel: TChannel; const AClipboard: TChannelClipboardData);
  end;


var
  FormMain: TFormMain;

  FRows: array of TRowData;
  IsUpdating: Boolean = False;

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

function BoolToRussianYesNo(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

destructor TFormMain.Destroy;
begin
  FreeAndNil(FDeviceClipboard.Snapshot);
  FreeAndNil(FEtalonClipboard.Snapshot);
  TMeterValue.SaveToFile(0);
  FInstrumentalVisibleOrder.Free;
  FWorkTableManager.Free;
  FFlowMeters.Free;
  inherited;
end;

procedure TFormMain.EditTestNumExit(Sender: TObject);
begin
       LabelTestNum.Text := FActiveWorkTable.DeviceChannels[0].FlowMeter.ValueError.GetStrNum(EditTestNum.Text)
end;

procedure TFormMain.ApplyMonitorIndicatorColor(const AColor: TAlphaColor);
var
  P: TGradientPoint;
begin
  CircleIndicatorMonitor.Fill.Kind := TBrushKind.Gradient;
  CircleIndicatorMonitor.Fill.Gradient.Style := TGradientStyle.Radial;

  CircleIndicatorMonitor.Fill.Gradient.Points.Clear;

  P := TGradientPoint(CircleIndicatorMonitor.Fill.Gradient.Points.Add);
  P.Color := AColor;
  P.Offset := 0;

  P := TGradientPoint(CircleIndicatorMonitor.Fill.Gradient.Points.Add);
  P.Color := TAlphaColorRec.White;   // вместо claWhite
  P.Offset := 1;

  RefreshMonitorIndicator;
end;

procedure TFormMain.RefreshMonitorIndicator;
begin
  if CircleIndicatorMonitor = nil then
    Exit;

  CircleIndicatorMonitor.Repaint;
  ButtonMonitor.Repaint;
end;

procedure TFormMain.ResetMeasurementValues;
var
  Ch: TChannel;

  procedure ResetMeter(const AMeter: TMeterValue); overload;
  begin
    if AMeter <> nil then
      AMeter.Reset;
  end;

  procedure ResetMeter(const AMeter: TMeterValue; const AValue: Double); overload;
  begin
    if AMeter <> nil then
      AMeter.Reset(AValue);
  end;

  procedure ResetSimulationChannelFields(const AChannel: TChannel);
  begin
    if AChannel = nil then
      Exit;

    AChannel.CurSec := 0;
   // AChannel.ImpSec := 0;
    AChannel.ImpResult := 0;
  end;
begin
  if FActiveWorkTable = nil then
    Exit;

  // Сброс полей, участвующих в имитации
  // (используются в UpdateRandomClimate/UpdateRandomSignals).
  //FActiveWorkTable.Temp := 0;
  //FActiveWorkTable.Press := 0;
  FNextClimateChangeAt := 0;

  FActiveWorkTable.Time  := 0;
  FActiveWorkTable.TimeResult  := 0;

 // FActiveWorkTable.FlowRate   := 0;


  if FActiveWorkTable.TableFlow <> nil then
    FActiveWorkTable.TableFlow.Reset;

  ResetMeter(FActiveWorkTable.ValueTempertureBefore);
  ResetMeter(FActiveWorkTable.ValueTempertureAfter);
  ResetMeter(FActiveWorkTable.ValueTempertureDelta);
  ResetMeter(FActiveWorkTable.ValueTemperture);
  ResetMeter(FActiveWorkTable.ValuePressureBefore);
  ResetMeter(FActiveWorkTable.ValuePressureAfter);
  ResetMeter(FActiveWorkTable.ValuePressureDelta);
  ResetMeter(FActiveWorkTable.ValuePressure);
  ResetMeter(FActiveWorkTable.ValueDensity);
  ResetMeter(FActiveWorkTable.ValueAirPressure);
  ResetMeter(FActiveWorkTable.ValueAirTemperture);
  ResetMeter(FActiveWorkTable.ValueHumidity);
  ResetMeter(FActiveWorkTable.ValueTime, 0);
  ResetMeter(FActiveWorkTable.ValueQuantity, 0);
  ResetMeter(FActiveWorkTable.ValueFlowRate);

  for Ch in FActiveWorkTable.DeviceChannels do
  begin
    if Ch.FlowMeter <> nil then
      Ch.FlowMeter.Reset;

    ResetSimulationChannelFields(Ch);

    ResetMeter(Ch.ValueImp);
    ResetMeter(Ch.ValueImpTotal, 0);
    ResetMeter(Ch.ValueCurrent);
    ResetMeter(Ch.ValueInterface);
  end;

  for Ch in FActiveWorkTable.EtalonChannels do
  begin
    if Ch.FlowMeter <> nil then
      Ch.FlowMeter.Reset;

    ResetSimulationChannelFields(Ch);

    ResetMeter(Ch.ValueImp);
    ResetMeter(Ch.ValueImpTotal, 0);
    ResetMeter(Ch.ValueCurrent);
    ResetMeter(Ch.ValueInterface);
  end;
end;

procedure TFormMain.SetConfiguration;
begin
  OnChangeState(STATE_CONFIGED);
end;

procedure TFormMain.StartMonitor;
begin
  OnChangeState(STATE_STARTMONITOR);
end;

procedure TFormMain.StopMonitor;
begin
  OnChangeState(STATE_STOPMONITOR);
end;

procedure TFormMain.StartTest;
begin
  ResetMeasurementValues;
  OnChangeState(STATE_STARTTEST);
end;

procedure TFormMain.StopTest;
begin
  OnChangeState(STATE_STOPTEST);
end;

 procedure TFormMain.UpdateForm;
 begin
          IsUpdating := True;
            try
               UpdateUIFromValues;
                UpdateGrids;
            finally
          IsUpdating := False;
          end;
 end;

procedure TFormMain.OnChangeState(const ANewState: TMeasurementState);
begin
  if FActiveWorkTable <> nil then
    FActiveWorkTable.MeasurementState := ANewState;

  case ANewState of
    STATE_NONE:
      begin
        TestButton.Tag := 0;
        TestButton.Enabled := False;
        ButtonMonitor.Enabled := False;
        SpeedButtonStartPump.Enabled := False;
        SpeedButtonSetFlowRate.Enabled := False;
        SpeedButtonProcedureStart.Enabled := False;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        GlowMesYellow.Enabled := False;
      end;


    STATE_STANDBY:
      begin
        TestButton.Text := 'Измерение';
        TestButton.Tag := 0;
        TestButton.Enabled := False;
        ButtonMonitor.Enabled := False;
        SpeedButtonStartPump.Enabled := False;
        SpeedButtonSetFlowRate.Enabled := False;
        SpeedButtonProcedureStart.Enabled := False;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        GlowMesYellow.Enabled := False;
        GlowEffectCancelRed.Enabled := False;
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
        ButtonCancel.Visible := False;
      end;

    STATE_CONNECTED:
      begin
        TestButton.Text := 'Измерение';
        TestButton.Tag := 1;
        TestButton.Enabled := True;
        ButtonMonitor.Enabled := True;
        SpeedButtonStartPump.Enabled := True;
        SpeedButtonSetFlowRate.Enabled := True;
        SpeedButtonProcedureStart.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        GlowMesYellow.Enabled := False;
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
        ButtonCancel.Visible := False;
      end;

    STATE_CONFIGED:
      begin
        // Статус зафиксирован после отправки настроек.
      end;

    STATE_STARTTEST:
      begin
        ButtonMonitor.Enabled := False;
        TestButton.Text := 'Запуск';
        TestButton.Tag := 2;
        TestButton.Enabled := False;
        ResetMeasurementValues;
      end;

    STATE_STARTMONITOR:
      begin
        ButtonCancel.Visible := False;
        ResetMeasurementValues;
      end;

    STATE_STARTMONITORWAIT:
      begin
        ApplyMonitorIndicatorColor(GlowMesYellow.GlowColor);
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        GlowMesYellow.Enabled := False;
      end;

    STATE_MONITOR:
      begin
        ApplyMonitorIndicatorColor(GlowMesGreen.GlowColor);
      end;

    STATE_STOPMONITOR:
      begin
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
        UpdateForm;
      end;

    STATE_STARTWAIT:
      begin
        GlowMesYellow.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
        TestButton.Text := 'Стоп';
        TestButton.Tag := 3;
        TestButton.Enabled := True;
        ResetMeasurementValues;
      end;

    STATE_EXECUTE:
      begin
        GlowMesGreen.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesYellow.Enabled := False;
      end;

    STATE_STOPTEST:
      begin
        TestButton.Text := 'Завершение';
        TestButton.Tag := 4;
        TestButton.Enabled := False;
        UpdateForm;
      end;

    STATE_STOPWAIT:
      begin
        // Ожидание завершения остановки.
      end;

    STATE_COMPLETE:
      begin
        TestButton.Text := 'Сохранение';
        TestButton.Tag := 5;
        TestButton.Enabled := False;
        GlowMesYellow.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
      end;

    STATE_FINALREAD:
      begin
        GlowMesYellow.Enabled := False;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := True;
        TestButton.Text := 'Сохранить?';
        TestButton.Tag := 6;
        TestButton.Enabled := True;
        ButtonMonitor.Enabled := True;
        ButtonCancel.Visible := True;
        GlowEffectCancelRed.Enabled := True;
        UpdateForm;
      end;

    STATE_FAILURE:
      begin
        GlowMesRed.Enabled := True;
        GlowMesYellow.Enabled := False;
        GlowMesGreen.Enabled := False;
        TestButton.Text := 'Ошибка';
        TestButton.Enabled := False;
        ButtonMonitor.Enabled := False;
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
      end;
  else
    begin
      // STATE_NONE
    end;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  OT: TOutputType;
  UnitName: string;
  LayoutOrder: string;

begin
  TMeterValue.LoadFromFile;

  FInstrumentalVisibleOrder := TList<TLayout>.Create;

  FWorkTableManager := TWorkTableManager.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Settings\TableSettings.ini'
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
  ComboEditUnits.OnChange := ComboBoxUnitsChange;
  if ComboEditUnits.Items.Count > 0 then
    ComboEditUnits.ItemIndex := 0;

  SetLength(FRows, 0);

  InitTables;

  FLastClickRow := -1;
  FLastClickCol := nil;
  FLastClickTick := 0;

  Randomize;
  FNextClimateChangeAt := Now;

  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  LayoutOrder := '';
  if FActiveWorkTable <> nil then
    LayoutOrder := FActiveWorkTable.InstrumentalLayoutOrder;

  RestoreInstrumentalLayoutsByFlags(
    LayoutFlowRate.Visible,
    LayoutPump.Visible,
    LayoutMain.Visible,
    LayoutMesure.Visible,
    LayoutConditions.Visible,
    LayoutProcedures.Visible,
    LayoutOrder
  );

  ButtonMonitor.OnClick := ButtonMonitorClick;
  ButtonCancel.OnClick := ButtonCancelClick;
  TabControl1.OnChange := TabControl1Change;
  TreeViewDevices.OnChange := TreeViewDevicesChange;
  GridDataPoints.OnGetValue := GridDataPointsGetValue;
  GridResults.OnGetValue := GridResultsGetValue;
  SetValues;
  RefreshResultsTab;
  UpdateForm;
  OnChangeState(STATE_NONE);
end;

procedure TFormMain.TabControl1Change(Sender: TObject);
begin
  if TabControl1.ActiveTab = TabItemResults then
    RefreshResultsTab;
end;

procedure TFormMain.RefreshResultsTab;
begin
  PopulateTreeViewDevices;
  ShowAllDevicesResults;
end;

procedure TFormMain.PopulateTreeViewDevices;
var
  RootAll, RootOther, RootTable, DeviceItem: TTreeViewItem;
  I: Integer;
  WT: TWorkTable;
  Ch: TChannel;
begin
  TreeViewDevices.BeginUpdate;
  try
    TreeViewDevices.Clear;

    RootAll := TTreeViewItem.Create(TreeViewDevices);
    RootAll.Text := '...';
    TreeViewDevices.AddObject(RootAll);

    if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
      for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
      begin
        WT := FWorkTableManager.WorkTables[I];
        if WT = nil then
          Continue;

        RootTable := TTreeViewItem.Create(TreeViewDevices);
        RootTable.Text := WT.Name;
        RootTable.TagObject := WT;
        TreeViewDevices.AddObject(RootTable);

        for Ch in WT.DeviceChannels do
        begin
          if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then
            Continue;

          DeviceItem := TTreeViewItem.Create(TreeViewDevices);
          DeviceItem.Text := Ch.FlowMeter.Device.Name;
          DeviceItem.TagObject := Ch.FlowMeter.Device;
          RootTable.AddObject(DeviceItem);
        end;
      end;

    RootOther := TTreeViewItem.Create(TreeViewDevices);
    RootOther.Text := 'прочее';
    TreeViewDevices.AddObject(RootOther);

    if TreeViewDevices.Count > 0 then
      TreeViewDevices.Selected := TreeViewDevices.ItemByIndex(0);
  finally
    TreeViewDevices.EndUpdate;
  end;
end;

procedure TFormMain.UpdateResultsPointColumns;
var
  MaxPoints, I: Integer;
begin
  MaxPoints := 0;
  for I := 0 to High(FCurrentResultRows) do
    MaxPoints := Max(MaxPoints, Length(FCurrentResultRows[I].PointValues));

  StringColumnPointNum1.Visible := MaxPoints >= 1;
  StringColumnPointNum2.Visible := MaxPoints >= 2;
  StringColumnPointNum3.Visible := MaxPoints >= 3;
  StringColumnPointNum4.Visible := MaxPoints >= 4;

  StringColumnPointNum1.Header := 'Q1';
  StringColumnPointNum2.Header := 'Q2';
  StringColumnPointNum3.Header := 'Q3';
  StringColumnPointNum4.Header := 'Q4';
end;

procedure TFormMain.ShowAllDevicesResults;
var
  Rows: TList<TResultGridRow>;
  WT: TWorkTable;
  Ch: TChannel;
  P: TDevicePoint;
  Row: TResultGridRow;
  I: Integer;
begin
  Rows := TList<TResultGridRow>.Create;
  try
    if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
      for WT in FWorkTableManager.WorkTables do
      begin
        if WT = nil then
          Continue;
        for Ch in WT.DeviceChannels do
        begin
          if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then
            Continue;

          Row.Name := Ch.FlowMeter.Device.Name;
          Row.DeviceType := Ch.FlowMeter.Device.DeviceTypeName;
          Row.Serial := Ch.FlowMeter.Device.SerialNumber;
          if Ch.FlowMeter.Device.Points <> nil then
          begin
            SetLength(Row.PointValues, Ch.FlowMeter.Device.Points.Count);
            for I := 0 to Ch.FlowMeter.Device.Points.Count - 1 do
            begin
              P := Ch.FlowMeter.Device.Points[I];
              if P <> nil then
                Row.PointValues[I] := P.Name
              else
                Row.PointValues[I] := '';
            end;
          end
          else
            SetLength(Row.PointValues, 0);

          if Ch.Enabled then
            Row.ResultText := 'Годен'
          else
            Row.ResultText := 'Не годен';

          Rows.Add(Row);
        end;
      end;

    FCurrentResultRows := Rows.ToArray;
  finally
    Rows.Free;
  end;

  UpdateResultsPointColumns;
  GridResults.Visible := True;
  GridDataPoints.Visible := False;
  GridResults.RowCount := Length(FCurrentResultRows);
  GridResults.Repaint;
end;

procedure TFormMain.ShowDeviceSpillages(ADevice: TDevice);
var
  I: Integer;
begin
  SetLength(FCurrentSpillages, 0);
  if ADevice <> nil then
  begin
    if ADevice.Spillages <> nil then
    begin
      SetLength(FCurrentSpillages, ADevice.Spillages.Count);
      for I := 0 to ADevice.Spillages.Count - 1 do
        FCurrentSpillages[I] := ADevice.Spillages[I];
    end;
  end;

  GridResults.Visible := False;
  GridDataPoints.Visible := True;
  GridDataPoints.RowCount := Length(FCurrentSpillages);
  GridDataPoints.Repaint;
end;

procedure TFormMain.TreeViewDevicesChange(Sender: TObject);
var
  Item: TTreeViewItem;
begin
  Item := TreeViewDevices.Selected;
  if Item = nil then
    Exit;

  if Item.Text = '...' then
  begin
    ShowAllDevicesResults;
    Exit;
  end;

  if Item.Text = 'прочее' then
  begin
    ShowAllDevicesResults;
    Exit;
  end;

  if Item.TagObject is TDevice then
    ShowDeviceSpillages(TDevice(Item.TagObject))
  else
  begin
    ShowAllDevicesResults;
  end;
end;

procedure TFormMain.GridResultsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  Row: TResultGridRow;
begin
  if (ARow < 0) or (ARow >= Length(FCurrentResultRows)) then
    Exit;

  Row := FCurrentResultRows[ARow];

  if GridResults.Columns[ACol] = StringColumnResultName then
    Value := Row.Name
  else if GridResults.Columns[ACol] = StringColumnResultType then
    Value := Row.DeviceType
  else if GridResults.Columns[ACol] = StringColumnResultSerial then
    Value := Row.Serial
  else if GridResults.Columns[ACol] = StringColumnPointNum1 then
  begin
    if Length(Row.PointValues) > 0 then Value := Row.PointValues[0] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnPointNum2 then
  begin
    if Length(Row.PointValues) > 1 then Value := Row.PointValues[1] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnPointNum3 then
  begin
    if Length(Row.PointValues) > 2 then Value := Row.PointValues[2] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnPointNum4 then
  begin
    if Length(Row.PointValues) > 3 then Value := Row.PointValues[3] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnResult then
    Value := Row.ResultText;
end;

procedure TFormMain.GridDataPointsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  P: TPointSpillage;
begin
  if (ARow < 0) or (ARow >= Length(FCurrentSpillages)) then
    Exit;
  P := FCurrentSpillages[ARow];
  if P = nil then
    Exit;

  if GridDataPoints.Columns[ACol] = StringColumnName then
    Value := P.Name
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageNum then
    Value := P.Num
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDateTime then
    Value := DateTimeToStr(P.DateTime)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageOperator then
    Value := P.OperatorName
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEtalonName then
    Value := P.EtalonName
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageSpillTime then
    Value := FloatToStr(P.SpillTime)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQavgEtalon then
    Value := FloatToStr(P.QavgEtalon)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEtalonVolume then
    Value := FloatToStr(P.EtalonVolume)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEtalonMass then
    Value := FloatToStr(P.EtalonMass)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQEtalonStd then
    Value := FloatToStr(P.QEtalonStd)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQEtalonCV then
    Value := FloatToStr(P.QEtalonCV)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDeviceVolume then
    Value := FloatToStr(P.DeviceVolume)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDeviceMass then
    Value := FloatToStr(P.DeviceMass)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageVelocity then
    Value := FloatToStr(P.Velocity)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageError then
    Value := FloatToStr(P.Error)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageValid then
    Value := BoolToRussianYesNo(P.Valid)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQStd then
    Value := FloatToStr(P.QStd)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQCV then
    Value := FloatToStr(P.QCV)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageVolumeBefore then
    Value := FloatToStr(P.VolumeBefore)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageVolumeAfter then
    Value := FloatToStr(P.VolumeAfter)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillagePulseCount then
    Value := P.PulseCount
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageMeanFrequency then
    Value := FloatToStr(P.MeanFrequency)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAvgCurrent then
    Value := FloatToStr(P.AvgCurrent)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAvgVoltage then
    Value := FloatToStr(P.AvgVoltage)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageData1 then
    Value := P.Data1
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageData2 then
    Value := P.Data2
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageStartTemperature then
    Value := FloatToStr(P.StartTemperature)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEndTemperature then
    Value := FloatToStr(P.EndTemperature)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAvgTemperature then
    Value := FloatToStr(P.AvgTemperature)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageInputPressure then
    Value := FloatToStr(P.InputPressure)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageOutputPressure then
    Value := FloatToStr(P.OutputPressure)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDensity then
    Value := FloatToStr(P.Density)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAmbientTemperature then
    Value := FloatToStr(P.AmbientTemperature)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAtmosphericPressure then
    Value := FloatToStr(P.AtmosphericPressure)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageRelativeHumidity then
    Value := FloatToStr(P.RelativeHumidity)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageCoef then
    Value := FloatToStr(P.Coef)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageFCDCoefficient then
    Value := P.FCDCoefficient
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageArchivedData then
    Value := P.ArchivedData;
end;

procedure TFormMain.PopupMenuInstrumentalLayOutPopup(Sender: TObject);
begin
  miFlowRate.Text := LabelLayoutFlowRate.Text;
  miPump.Text := LabelLayoutPump.Text;
  miMain.Text := LabelLayoutMain.Text;
  miMesurment.Text := LabelLayoutMesure.Text;
  miConditions.Text := LabelLayoutConditions.Text;
  miProcedures.Text := LabelLayoutProcedures.Text;

  miFlowRate.IsChecked := LayoutFlowRate.Visible;
  miPump.IsChecked := LayoutPump.Visible;
  miMain.IsChecked := LayoutMain.Visible;
  miMesurment.IsChecked := LayoutMesure.Visible;
  miConditions.IsChecked := LayoutConditions.Visible;
  miProcedures.IsChecked := LayoutProcedures.Visible;
end;

function TFormMain.GetLayoutByMenuItem(AMenuItem: TMenuItem): TLayout;
// Сопоставляет пункт popup-меню и соответствующий инструментальный блок.
begin
  Result := nil;
  if AMenuItem = miFlowRate then
    Result := LayoutFlowRate
  else if AMenuItem = miPump then
    Result := LayoutPump
  else if AMenuItem = miMain then
    Result := LayoutMain
  else if AMenuItem = miMesurment then
    Result := LayoutMesure
  else if AMenuItem = miConditions then
    Result := LayoutConditions
  else if AMenuItem = miProcedures then
    Result := LayoutProcedures;
end;

procedure TFormMain.RebuildInstrumentalVisibleOrder;
// Пересобирает список видимых блоков по текущему состоянию UI.
// Используется после загрузки формы/настроек, чтобы синхронизировать модель порядка.
var
  I: Integer;
  Control: TControl;
begin
  if FInstrumentalVisibleOrder = nil then
    Exit;

  FInstrumentalVisibleOrder.Clear;
  for I := 0 to HorzScrollBoxInstrumental.ControlsCount - 1 do
  begin
    Control := HorzScrollBoxInstrumental.Controls[I];
    if (Control is TLayout) and Control.Visible and
       ((Control = LayoutFlowRate) or (Control = LayoutPump) or
        (Control = LayoutMain) or (Control = LayoutMesure) or
        (Control = LayoutConditions) or (Control = LayoutProcedures)) then
      FInstrumentalVisibleOrder.Add(TLayout(Control));
  end;
end;

procedure TFormMain.ApplyInstrumentalVisibleOrder;
var
  I: Integer;
  Layout: TLayout;
  X: Single;
begin
  if FInstrumentalVisibleOrder = nil then
    Exit;

  HorzScrollBoxInstrumental.BeginUpdate;
  try
    // Не полагаемся на неочевидный порядок Align=Left/MostLeft:
    // задаем положение блоков вручную в порядке включения.
    for Layout in [LayoutFlowRate, LayoutPump, LayoutMain,
      LayoutMesure, LayoutConditions, LayoutProcedures] do
      Layout.Align := TAlignLayout.None;

    X := 0;
    for I := 0 to FInstrumentalVisibleOrder.Count - 1 do
    begin
      Layout := FInstrumentalVisibleOrder[I];
      Layout.Visible := True;
      Layout.Position.X := X;
      Layout.Position.Y := 0;
      X := X + Layout.Width;
    end;

    HorzScrollBoxInstrumental.Content.Width := Max(X, HorzScrollBoxInstrumental.Width);
  finally
    HorzScrollBoxInstrumental.EndUpdate;
  end;

  UpdatePanelInstrumentsHeight;
end;

procedure TFormMain.SetInstrumentalLayoutVisible(ALayout: TLayout;
  AVisible: Boolean);
// Единая точка переключения видимости: поддерживает список порядка
// и сразу перестраивает визуальное расположение блоков.
begin
  if (ALayout = nil) or (FInstrumentalVisibleOrder = nil) then
    Exit;

  if AVisible then
  begin
    // Сразу отключаем Align, чтобы блок не встраивался поверх существующих
    // по внутренним правилам Align перед последующим перерасчетом позиций.
    ALayout.Align := TAlignLayout.None;
    ALayout.Visible := True;
    // При включении добавляем блок в конец последовательности показа.
    if FInstrumentalVisibleOrder.IndexOf(ALayout) < 0 then
      FInstrumentalVisibleOrder.Add(ALayout);
  end
  else
  begin
    // При выключении удаляем блок из последовательности.
    FInstrumentalVisibleOrder.Remove(ALayout);
    ALayout.Visible := False;
  end;

  ApplyInstrumentalVisibleOrder;
end;

function TFormMain.GetLayoutOrderKey(ALayout: TLayout): string;
begin
  Result := '';
  if ALayout = LayoutFlowRate then
    Result := 'FlowRate'
  else if ALayout = LayoutPump then
    Result := 'Pump'
  else if ALayout = LayoutMain then
    Result := 'Main'
  else if ALayout = LayoutMesure then
    Result := 'Mesure'
  else if ALayout = LayoutConditions then
    Result := 'Conditions'
  else if ALayout = LayoutProcedures then
    Result := 'Procedures';
end;

function TFormMain.GetLayoutByOrderKey(const AKey: string): TLayout;
begin
  Result := nil;
  if SameText(AKey, 'FlowRate') then
    Result := LayoutFlowRate
  else if SameText(AKey, 'Pump') then
    Result := LayoutPump
  else if SameText(AKey, 'Main') then
    Result := LayoutMain
  else if SameText(AKey, 'Mesure') then
    Result := LayoutMesure
  else if SameText(AKey, 'Conditions') then
    Result := LayoutConditions
  else if SameText(AKey, 'Procedures') then
    Result := LayoutProcedures;
end;

function TFormMain.GetInstrumentalVisibleOrderAsString: string;
var
  I: Integer;
  Key: string;
begin
  Result := '';
  if FInstrumentalVisibleOrder = nil then
    Exit;

  for I := 0 to FInstrumentalVisibleOrder.Count - 1 do
  begin
    Key := GetLayoutOrderKey(FInstrumentalVisibleOrder[I]);
    if Key = '' then
      Continue;
    if Result <> '' then
      Result := Result + ',';
    Result := Result + Key;
  end;
end;

procedure TFormMain.UpdatePanelInstrumentsHeight;
begin
  if (FInstrumentalVisibleOrder <> nil) and (FInstrumentalVisibleOrder.Count = 0) then
    PanelInstruments.Height := 20
  else
    PanelInstruments.Height := 121;
end;

procedure TFormMain.RestoreInstrumentalLayoutsByFlags(
  const AFlowRateVisible, APumpVisible, AMainVisible, AMesureVisible,
  AConditionsVisible, AProceduresVisible: Boolean; const AOrder: string);
var
  Layout: TLayout;
  OrderKeys: TStringList;
  I: Integer;

  function IsRequestedVisible(ALayout: TLayout): Boolean;
  begin
    Result := ((ALayout = LayoutFlowRate) and AFlowRateVisible) or
      ((ALayout = LayoutPump) and APumpVisible) or
      ((ALayout = LayoutMain) and AMainVisible) or
      ((ALayout = LayoutMesure) and AMesureVisible) or
      ((ALayout = LayoutConditions) and AConditionsVisible) or
      ((ALayout = LayoutProcedures) and AProceduresVisible);
  end;

  procedure ShowIfVisibleAndNotAdded(ALayout: TLayout);
  begin
    if (ALayout = nil) or not IsRequestedVisible(ALayout) then
      Exit;
    if FInstrumentalVisibleOrder.IndexOf(ALayout) >= 0 then
      Exit;
    SetInstrumentalLayoutVisible(ALayout, True);
  end;

begin
  if FInstrumentalVisibleOrder = nil then
    Exit;

  // Полный сброс: сначала скрываем все блоки, затем показываем по одному.
  HorzScrollBoxInstrumental.BeginUpdate;
  try
    FInstrumentalVisibleOrder.Clear;
    for Layout in [LayoutFlowRate, LayoutPump, LayoutMain,
      LayoutMesure, LayoutConditions, LayoutProcedures] do
    begin
      Layout.Align := TAlignLayout.None;
      Layout.Visible := False;
      Layout.Position.X := 0;
      Layout.Position.Y := 0;
    end;
  finally
    HorzScrollBoxInstrumental.EndUpdate;
  end;

  // 1) Восстанавливаем видимые блоки в сохраненном порядке прошлого сеанса.
  OrderKeys := TStringList.Create;
  try
    OrderKeys.StrictDelimiter := True;
    OrderKeys.Delimiter := ',';
    OrderKeys.DelimitedText := AOrder;
    for I := 0 to OrderKeys.Count - 1 do
      ShowIfVisibleAndNotAdded(GetLayoutByOrderKey(Trim(OrderKeys[I])));
  finally
    OrderKeys.Free;
  end;

  // 2) Если в сохраненном порядке чего-то нет, добираем в порядке пунктов меню.
  ShowIfVisibleAndNotAdded(LayoutFlowRate);
  ShowIfVisibleAndNotAdded(LayoutPump);
  ShowIfVisibleAndNotAdded(LayoutMain);
  ShowIfVisibleAndNotAdded(LayoutMesure);
  ShowIfVisibleAndNotAdded(LayoutConditions);
  ShowIfVisibleAndNotAdded(LayoutProcedures);

  ApplyInstrumentalVisibleOrder;
end;

procedure TFormMain.MenuInstrumentalLayOutClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Layout: TLayout;
  NewVisible: Boolean;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  NewVisible := not MenuItem.IsChecked;
  MenuItem.IsChecked := NewVisible;

  Layout := GetLayoutByMenuItem(MenuItem);
  SetInstrumentalLayoutVisible(Layout, NewVisible);

  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.FillGridLayOutPopup(AMenu: TPopupMenu; AGrid: TGrid);
var
  I: Integer;
  MenuItem: TMenuItem;
  Column: TColumn;
begin
  if (AMenu = nil) or (AGrid = nil) then
    Exit;

  AMenu.Clear;

  for I := 0 to AGrid.ColumnCount - 1 do
  begin
    Column := AGrid.Columns[I];

    MenuItem := TMenuItem.Create(AMenu);
    MenuItem.Parent := AMenu;
    MenuItem.Text := Column.Header;
    MenuItem.IsChecked := Column.Visible;
    MenuItem.TagObject := Column;
    MenuItem.OnClick := MenuGridLayOutClick;
  end;
end;

function TFormMain.IsHeaderPopup(AMenu: TPopupMenu; AGrid: TGrid): Boolean;
var
  PopupPoint: TPointF;
begin
  Result := True;
  if (AMenu = nil) or (AGrid = nil) then
    Exit;

  // Если меню вызвано не из грида (например, с тулбара), показываем меню колонок.
  if AMenu.PopupComponent <> AGrid then
    Exit;

  PopupPoint := AMenu.PopupPoint;
  Result := PopupPoint.Y <= 20;
end;

procedure TFormMain.FillGridDevicesActionsPopup(AMenu: TPopupMenu);

  procedure AddItem(const AText: string; const AEnabled: Boolean = True);
  var
    MenuItem: TMenuItem;
  begin
    MenuItem := TMenuItem.Create(AMenu);
    MenuItem.Parent := AMenu;
    MenuItem.Text := AText;
    MenuItem.Enabled := AEnabled;
    MenuItem.OnClick := GridDevicesActionsMenuClick;
  end;

  procedure AddSeparator;
  begin
    AddItem('-');
  end;

begin
  if AMenu = nil then
    Exit;

  AMenu.Clear;

  AddItem('Очистить строку');
  AddItem('Копировать');
  AddItem('Вставить');
  AddSeparator;
  AddItem('Очистить все приборы');
  AddItem('Заполнить все по выбранному');
  AddSeparator;
  AddItem('Прибор из архива');
  AddSeparator;
  AddItem('Установить источник расхода');
  AddItem('Назначить эталоном');
end;

procedure TFormMain.GridDevicesActionsMenuClick(Sender: TObject);
begin
  // Здесь будут обработчики действий с приборами.
end;

procedure TFormMain.PopupMenuDevicesGridLayOutPopup(Sender: TObject);
begin
  if IsHeaderPopup(PopupMenuDevicesGridLayOut, GridDevices) then
    FillGridLayOutPopup(PopupMenuDevicesGridLayOut, GridDevices)
  else
    FillGridDevicesActionsPopup(PopupMenuDevicesGridLayOut);
end;

procedure TFormMain.PopupMenuEtalonsGridLayOutPopup(Sender: TObject);
begin
  if IsHeaderPopup(PopupMenuEtalonsGridLayOut, GridEtalons) then
    FillGridLayOutPopup(PopupMenuEtalonsGridLayOut, GridEtalons)
  else
    FillGridDevicesActionsPopup(PopupMenuEtalonsGridLayOut);
end;

procedure TFormMain.MenuGridLayOutClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TColumn;
  NewVisible: Boolean;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  if not (MenuItem.TagObject is TColumn) then
    Exit;

  Column := TColumn(MenuItem.TagObject);
  NewVisible := not MenuItem.IsChecked;
  MenuItem.IsChecked := NewVisible;
  Column.Visible := NewVisible;

  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.CaptureGridColumnsLayout(AGrid: TGrid;
  out AColumns: TArray<TGridColumnLayout>);
var
  I: Integer;
begin
  SetLength(AColumns, 0);
  if AGrid = nil then
    Exit;

  SetLength(AColumns, AGrid.ColumnCount);
  for I := 0 to AGrid.ColumnCount - 1 do
  begin
    AColumns[I].Name := AGrid.Columns[I].Name;
    AColumns[I].DisplayIndex := I;
    AColumns[I].Width := AGrid.Columns[I].Width;
    AColumns[I].Visible := AGrid.Columns[I].Visible;
  end;
end;

procedure TFormMain.Circle1Click(Sender: TObject);
begin
 GridDevices.Repaint;
end;

procedure TFormMain.ApplyGridColumnsLayout(AGrid: TGrid;
  const AColumns: TArray<TGridColumnLayout>);
var
  I, J: Integer;
  Column: TColumn;
begin
  if (AGrid = nil) or (Length(AColumns) = 0) then
    Exit;

  AGrid.BeginUpdate;
  try
    for I := 0 to High(AColumns) do
    begin
      Column := nil;
      for J := 0 to AGrid.ColumnCount - 1 do
        if SameText(AGrid.Columns[J].Name, AColumns[I].Name) then
        begin
          Column := AGrid.Columns[J];
          Break;
        end;

      if Column = nil then
        Continue;

      Column.Visible := AColumns[I].Visible;
      if AColumns[I].Width > 0 then
        Column.Width := AColumns[I].Width;
      if (AColumns[I].DisplayIndex >= 0) and (AColumns[I].DisplayIndex < AGrid.ColumnCount) then
        Column.Index := AColumns[I].DisplayIndex;
    end;
  finally
    AGrid.EndUpdate;
  end;
end;

procedure TFormMain.SaveLayoutSettingsToWorkTable;
var
  WorkTable: TWorkTable;
  EtalonColumns: TArray<TGridColumnLayout>;
  DeviceColumns: TArray<TGridColumnLayout>;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  WorkTable.LayoutFlowRateVisible := LayoutFlowRate.Visible;
  WorkTable.LayoutPumpVisible := LayoutPump.Visible;
  WorkTable.LayoutMainVisible := LayoutMain.Visible;
  WorkTable.LayoutMesureVisible := LayoutMesure.Visible;
  WorkTable.LayoutConditionsVisible := LayoutConditions.Visible;
  WorkTable.LayoutProceduresVisible := LayoutProcedures.Visible;
  WorkTable.InstrumentalLayoutOrder := GetInstrumentalVisibleOrderAsString;

  CaptureGridColumnsLayout(GridEtalons, EtalonColumns);
  CaptureGridColumnsLayout(GridDevices, DeviceColumns);
  WorkTable.EtalonsGridColumns := EtalonColumns;
  WorkTable.DevicesGridColumns := DeviceColumns;
end;

procedure TFormMain.LoadLayoutSettingsFromWorkTable;
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  RestoreInstrumentalLayoutsByFlags(
    WorkTable.LayoutFlowRateVisible,
    WorkTable.LayoutPumpVisible,
    WorkTable.LayoutMainVisible,
    WorkTable.LayoutMesureVisible,
    WorkTable.LayoutConditionsVisible,
    WorkTable.LayoutProceduresVisible,
    WorkTable.InstrumentalLayoutOrder
  );

  ApplyGridColumnsLayout(GridEtalons, WorkTable.EtalonsGridColumns);
  ApplyGridColumnsLayout(GridDevices, WorkTable.DevicesGridColumns);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveLayoutSettingsToWorkTable;
  if FWorkTableManager <> nil then
    FWorkTableManager.Save;

  if DataManager <> nil then
    DataManager.Save;
end;

procedure TFormMain.MarkChannelDeviceModified(AChannel: TChannel);
begin
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or (AChannel.FlowMeter.Device = nil) then
    Exit;

  if AChannel.FlowMeter.Device.State <> osDeleted then
    AChannel.FlowMeter.Device.State := osModified;
end;

procedure TFormMain.SetDim(FlowUnitName: string; QuantityUnitName: string);
var
  WorkTable: TWorkTable;
  I: Integer;
  IsVolumeUnits: Boolean;
  Meter: TFlowMeter;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  FlowUnitName := Trim(FlowUnitName);
  QuantityUnitName := Trim(QuantityUnitName);

  if FlowUnitName = '' then
    Exit;

  if QuantityUnitName = '' then
    QuantityUnitName := ResolveQuantityUnitByFlowUnit(FlowUnitName);

  IsVolumeUnits := IsVolumeFlowUnit(FlowUnitName);

  Meter := nil;
  if (WorkTable.EtalonChannels.Count > 0) and (WorkTable.EtalonChannels[0] <> nil) then
    Meter := WorkTable.EtalonChannels[0].FlowMeter;
  if (Meter = nil) and (WorkTable.DeviceChannels.Count > 0) and (WorkTable.DeviceChannels[0] <> nil) then
    Meter := WorkTable.DeviceChannels[0].FlowMeter;

  WorkTable.FlowUnitName := FlowUnitName;
  WorkTable.QuantityUnitName := QuantityUnitName;

  if WorkTable.ValueFlowRate <> nil then
    WorkTable.ValueFlowRate.SetDim(FlowUnitName);

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
        Meter.ValueVolumeFlow.SetDim(FlowUnitName);
    end
    else
    begin
      Meter.ValueQuantity := Meter.ValueMass;
      Meter.ValueFlow := Meter.ValueMassFlow;
      if Meter.ValueMass <> nil then
        Meter.ValueMass.SetDim(QuantityUnitName);
      if Meter.ValueMassFlow <> nil then
        Meter.ValueMassFlow.SetDim(FlowUnitName);
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
        Meter.ValueVolumeFlow.SetDim(FlowUnitName);
    end
    else
    begin
      Meter.ValueQuantity := Meter.ValueMass;
      Meter.ValueFlow := Meter.ValueMassFlow;
      if Meter.ValueMass <> nil then
        Meter.ValueMass.SetDim(QuantityUnitName);
      if Meter.ValueMassFlow <> nil then
        Meter.ValueMassFlow.SetDim(FlowUnitName);
    end;
  end;
  WorkTable.UpdateAggregateMeterValues;
  WorkTable.RecalculateAllMeterValues;
  UpdateUIFromValues;
end;

procedure TFormMain.ComboBoxUnitsChange(Sender: TObject);
var
  UnitName: string;
  QuantityUnitName: string;
begin
  UnitName := Trim(ComboEditUnits.Text);
  if UnitName = '' then
    Exit;

  QuantityUnitName := ResolveQuantityUnitByFlowUnit(UnitName);
  SetDim(UnitName, QuantityUnitName);

  GridDevices.SetFocus;
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
  I, LimitCount, UnitIndex: Integer;
begin
  TableCount := 0;
  if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
    TableCount := FWorkTableManager.WorkTables.Count;

  //FActiveWorkTable:=FWorkTableManager.ActiveWorkTable;
  FActiveWorkTable := GetWorkTableByIndex(0);
  if FActiveWorkTable <> nil then
  begin
    FActiveWorkTable.RebindAllFlowMeters;

    if FActiveWorkTable.FlowUnitName <> '' then
    begin
      UnitIndex := ComboEditUnits.Items.IndexOf(FActiveWorkTable.FlowUnitName);
      if UnitIndex >= 0 then
        ComboEditUnits.ItemIndex := UnitIndex
      else if ComboEditUnits.Items.Count > 0 then
        ComboEditUnits.ItemIndex := 0;
    end
    else if ComboEditUnits.Items.Count > 0 then
      ComboEditUnits.ItemIndex := 0;

    SetDim(FActiveWorkTable.FlowUnitName, FActiveWorkTable.QuantityUnitName);
    LoadLayoutSettingsFromWorkTable;
  end;

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

   WorkTable.InitMeterValues;

  WorkTable.RebindAllFlowMeters;
  WorkTable.RecalculateAllMeterValues;
  WorkTable.UpdateAggregateMeterValues;

  InitTables;

  if FWorkTableManager.WorkTables.Count > 0 then
    TabControlWorkTables.TabIndex := EnsureRange(
      FWorkTableManager.WorkTables.Count - 1,
      0,
      Max(0, TabControlWorkTables.TabCount - 1)
    );
end;

procedure TFormMain.ActionOpenDeviceEditorExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  Ch: TChannel;
  Row: Integer;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  Row := GridDevices.Row;
  if (Row < 0) or (Row >= WorkTable.DeviceChannels.Count) then
    Exit;

  Ch := WorkTable.DeviceChannels[Row];
  if Ch = nil then
    Exit;

  OpenChannelDeviceEditor(Ch);
end;

procedure TFormMain.OpenChannelDeviceEditor(AChannel: TChannel);
var
  ADevice: TDevice;
  ActiveRepo: TDeviceRepository;
  FoundRepo: TDeviceRepository;
  SelDevice: TDevice;
  SelectFrm: TFormDeviceSelect;
  Frm: TFormDeviceEditor;
begin
  if AChannel = nil then
    Exit;

  ADevice := nil;
  ActiveRepo := nil;
  if DataManager <> nil then
  begin
    ActiveRepo := DataManager.ActiveDeviceRepo;

    if AChannel.DeviceUUID <> '' then
      ADevice := DataManager.FindDevice(AChannel.DeviceUUID, FoundRepo);
  end;

  if (ADevice = nil) and
     ((ActiveRepo = nil) or (ActiveRepo.Devices = nil) or (ActiveRepo.Devices.Count = 0)) then
  begin
    SelectFrm := TFormDeviceSelect.Create(Self);
    try
      if SelectFrm.ShowModal <> mrOk then
        Exit;

      SelDevice := SelectFrm.GetSelectedDevice;
      if SelDevice = nil then
        Exit;

      AChannel.DeviceUUID := SelDevice.MitUUID;
      AChannel.TypeName := SelDevice.DeviceTypeName;
      AChannel.Serial := SelDevice.SerialNumber;
      AChannel.Signal := SelDevice.OutputType;
      UpdateGridDevices;
    finally
      SelectFrm.Free;
    end;
    Exit;
  end;

  if (ADevice = nil) and (ActiveRepo <> nil) then
  begin
    ADevice := ActiveRepo.CreateDevice(-1);
    AChannel.DeviceUUID := ADevice.MitUUID;
    AChannel.TypeName := ADevice.DeviceTypeName;
    AChannel.Serial := ADevice.SerialNumber;
  end;

  Frm := TFormDeviceEditor.Create(Self);
  try
    Frm.LoadDevice(ADevice);
    if Frm.ShowModal = mrOk then
    begin
      if ADevice <> nil then
      begin
        AChannel.DeviceUUID := ADevice.MitUUID;
        AChannel.TypeName := ADevice.DeviceTypeName;
        AChannel.Serial := ADevice.SerialNumber;
        AChannel.Signal := ADevice.OutputType;
      end;

      UpdateGrids;
    end;
  finally
    Frm.Free;
  end;
end;

procedure TFormMain.ActionOpenDeviceSelectExecute(Sender: TObject);

var
  WorkTable: TWorkTable;
  Ch: TChannel;
  Row: Integer;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  Row := GridDevices.Row;
  if (Row < 0) or (Row >= WorkTable.DeviceChannels.Count) then
    Exit;

  Ch := WorkTable.DeviceChannels[Row];
  if Ch = nil then
    Exit;

  SelectDeviceForChannel(Ch);
end;

procedure TFormMain.SelectDeviceForChannel(AChannel: TChannel);
var
  Frm: TFormDeviceSelect;
  SelDevice: TDevice;
begin
  if AChannel = nil then
    Exit;

  Frm := TFormDeviceSelect.Create(Self);
  try
    if Frm.ShowModal <> mrOk then
      Exit;

    SelDevice := Frm.GetSelectedDevice;
    if SelDevice = nil then
      Exit;

    AChannel.DeviceUUID := SelDevice.MitUUID;
    AChannel.TypeName := SelDevice.DeviceTypeName;
    AChannel.Serial := SelDevice.SerialNumber;
    AChannel.Signal := SelDevice.OutputType;
    MarkChannelDeviceModified(AChannel);
    UpdateGrids;
  finally
    Frm.Free;
  end;
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
    '-',
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
    '-',
    ''
  );

  InitTables;
end;

procedure TFormMain.ActionSaveWorkTableExecute(Sender: TObject);
begin
  if FWorkTableManager = nil then
    Exit;

  SaveLayoutSettingsToWorkTable;
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

procedure TFormMain.SaveChannelToClipboard(AChannel: TChannel;
  var AClipboard: TChannelClipboardData);
begin
  FreeAndNil(AClipboard.Snapshot);
  AClipboard.HasData := AChannel <> nil;
  if AChannel = nil then
    Exit;

  AClipboard.Snapshot := TChannel.Create;
  AClipboard.Snapshot.AssignFlowMeterFrom(AChannel, nil, False);
end;

procedure TFormMain.LoadChannelFromClipboard(AChannel: TChannel;
  const AClipboard: TChannelClipboardData);
begin
  if (AChannel = nil) or not AClipboard.HasData or (AClipboard.Snapshot = nil) then
    Exit;

  AChannel.AssignFlowMeterFrom(AClipboard.Snapshot, FActiveWorkTable, True);
  MarkChannelDeviceModified(AChannel);
end;

function TFormMain.GetSelectedChannel(AChannels: TObjectList<TChannel>;
  AGrid: TGrid): TChannel;
var
  Row: Integer;
begin
  Result := nil;
  if (AChannels = nil) or (AGrid = nil) then
    Exit;

  Row := AGrid.Row;
  if (Row < 0) or (Row >= AChannels.Count) then
    Exit;

  Result := AChannels[Row];
end;

procedure TFormMain.ClearChannelData(AChannel: TChannel);
begin
  if AChannel = nil then
    Exit;

  AChannel.RecreateFlowMeter(FActiveWorkTable);

  AChannel.TypeName := '';
  AChannel.Serial := '';
  AChannel.Signal := -1;
  AChannel.DeviceUUID := '';
  AChannel.TypeUUID := '';
  AChannel.RepoTypeName := '';
  AChannel.RepoTypeUUID := '';
  AChannel.RepoDeviceName := '';
  AChannel.RepoDeviceUUID := '';
  MarkChannelDeviceModified(AChannel);
end;

procedure TFormMain.CopyChannelData(ASource, ADest: TChannel);
begin
  if (ASource = nil) or (ADest = nil) then
    Exit;

  ADest.TypeName := ASource.TypeName;
  ADest.Serial := ASource.Serial;
  ADest.Signal := ASource.Signal;
  ADest.DeviceUUID := ASource.DeviceUUID;
  ADest.TypeUUID := ASource.TypeUUID;
  ADest.RepoTypeName := ASource.RepoTypeName;
  ADest.RepoTypeUUID := ASource.RepoTypeUUID;
  ADest.RepoDeviceName := ASource.RepoDeviceName;
  ADest.RepoDeviceUUID := ASource.RepoDeviceUUID;
  MarkChannelDeviceModified(ADest);
end;

procedure TFormMain.ActionDevicesClearRowExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFormMain.ActionDevicesCopyExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;
  SaveChannelToClipboard(GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices), FDeviceClipboard);
end;

procedure TFormMain.ActionDevicesPasteExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  LoadChannelFromClipboard(Ch, FDeviceClipboard);
  UpdateGrids;
end;

procedure TFormMain.ActionDevicesClearAllExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.DeviceChannels = nil) then
    Exit;
  for Ch in FActiveWorkTable.DeviceChannels do
    ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFormMain.ActionDevicesFillAllBySelectedExecute(Sender: TObject);
var
  Src, Ch: TChannel;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.DeviceChannels = nil) then
    Exit;
  Src := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  if Src = nil then
    Exit;
  for Ch in FActiveWorkTable.DeviceChannels do
    if Ch <> Src then
      CopyChannelData(Src, Ch);
  UpdateGrids;
end;

procedure TFormMain.ActionDevicesFromArchiveExecute(Sender: TObject);
begin
  ActionOpenDeviceSelectExecute(Sender);
end;

procedure TFormMain.ActionDevicesSetFlowSourceExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  Row: Integer;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  Row := GridDevices.Row;
  if (Row < 0) or (Row >= WorkTable.DeviceChannels.Count) then
    Exit;

  GridDevices.SetFocus;
  GridDevices.Selected := PopupColumnDeviceSignal1.Index;
  ShowMessage('Источник расхода задаётся полем "Сигнал" в выбранной строке прибора.');
end;

procedure TFormMain.ActionDevicesAssignEtalonExecute(Sender: TObject);
var
  Ch: TChannel;
  EtalonCh: TChannel;
  EtalonRow: Integer;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.EtalonChannels.Count = 0) then
    Exit;

  EtalonRow := GridEtalons.Row;
  if (EtalonRow >= 0) and (EtalonRow < FActiveWorkTable.EtalonChannels.Count) then
    EtalonCh := FActiveWorkTable.EtalonChannels[EtalonRow]
  else
    EtalonCh := FActiveWorkTable.EtalonChannels[0];

  Ch := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  if (Ch <> nil) and (Ch.FlowMeter <> nil) and
     (EtalonCh <> nil) and
     (EtalonCh.FlowMeter <> nil) then
    Ch.FlowMeter.SetEtalon(EtalonCh.FlowMeter);
  UpdateGrids;
end;

procedure TFormMain.ActionEtalonsClearRowExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFormMain.ActionEtalonsCopyExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;
  SaveChannelToClipboard(GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons), FEtalonClipboard);
end;

procedure TFormMain.ActionEtalonsPasteExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  LoadChannelFromClipboard(Ch, FEtalonClipboard);
  UpdateGrids;
end;

procedure TFormMain.ActionEtalonsClearAllExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.EtalonChannels = nil) then
    Exit;
  for Ch in FActiveWorkTable.EtalonChannels do
    ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFormMain.ActionEtalonsFillAllBySelectedExecute(Sender: TObject);
var
  Src, Ch: TChannel;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.EtalonChannels = nil) then
    Exit;
  Src := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  if Src = nil then
    Exit;
  for Ch in FActiveWorkTable.EtalonChannels do
    if Ch <> Src then
      CopyChannelData(Src, Ch);
  UpdateGrids;
end;

procedure TFormMain.ActionEtalonsFromArchiveExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  SelectDeviceForChannel(Ch);
end;

procedure TFormMain.ActionEtalonsSetFlowSourceExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  Row: Integer;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  Row := GridEtalons.Row;
  if (Row < 0) or (Row >= WorkTable.EtalonChannels.Count) then
    Exit;

  GridEtalons.SetFocus;
  GridEtalons.Selected := PopupColumnEtalonSignal1.Index;
  ShowMessage('Источник расхода задаётся полем "Сигнал" в выбранной строке эталона.');
end;

procedure TFormMain.ActionEtalonsAssignEtalonExecute(Sender: TObject);
var
  Ch: TChannel;
  DeviceCh: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;

  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  if (Ch = nil) or (Ch.FlowMeter = nil) then
    Exit;

  for DeviceCh in FActiveWorkTable.DeviceChannels do
    if (DeviceCh <> nil) and (DeviceCh.FlowMeter <> nil) then
      DeviceCh.FlowMeter.SetEtalon(Ch.FlowMeter);

  UpdateGrids;
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

    AWorkTable.Time := AWorkTable.Time + 1;

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


  case WorkTable.MeasurementState of
    STATE_NONE:
      OnChangeState(STATE_STANDBY);

    STATE_STANDBY:
      OnChangeState(STATE_CONNECTED);

    STATE_STARTMONITOR:
      OnChangeState(STATE_STARTMONITORWAIT);

    STATE_STARTMONITORWAIT:
      OnChangeState(STATE_MONITOR);

    STATE_MONITOR:
       UpdateRandomSignals(WorkTable);

    STATE_STOPMONITOR,
    STATE_CONFIGED:
      OnChangeState(STATE_CONNECTED);

    STATE_STARTTEST:
      OnChangeState(STATE_STARTWAIT);

    STATE_STARTWAIT:
      OnChangeState(STATE_EXECUTE);

    STATE_EXECUTE:
       UpdateRandomSignals(WorkTable);

    STATE_STOPTEST:
      OnChangeState(STATE_STOPWAIT);

    STATE_STOPWAIT:
      OnChangeState(STATE_COMPLETE);

    STATE_COMPLETE:
      OnChangeState(STATE_FINALREAD);
  end;
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
var
  WorkTable: TWorkTable;
begin

  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  SetValues;

  IsUpdating := True;
  try
    UpdateUIFromValues;
  finally
    IsUpdating := False;
  end;

  if WorkTable.MeasurementState in [STATE_STARTMONITORWAIT, STATE_MONITOR, STATE_STOPMONITOR] then
    RefreshMonitorIndicator;

  if not (WorkTable.MeasurementState in [STATE_MONITOR, STATE_EXECUTE]) then
    Exit;

  IsUpdating := True;
  try
   UpdateGrids;
  finally
   IsUpdating := False;
  end;

end;

procedure TFormMain.UpdateUIFromValues;
var
  WorkTable: TWorkTable;
  I: Integer;
  MinImpValue: TMeterValue;
  RawValueBaseMultiplier: TMeterValue;

  function FindFirstValueBaseMultiplier(
    AChannels: TObjectList<TChannel>): TMeterValue;
  var
    J: Integer;
  begin
    Result := nil;
    if AChannels = nil then
      Exit;

    for J := 0 to AChannels.Count - 1 do
      if (AChannels[J] <> nil) and
         (AChannels[J].FlowMeter <> nil) and
        (AChannels[J].FlowMeter.ValueFlow <> nil) and
        (AChannels[J].FlowMeter.ValueFlow.ValueBaseMultiplier <> nil) then
      begin
        Result := AChannels[J].FlowMeter.ValueFlow.ValueBaseMultiplier;
        Exit;
      end;
  end;

  function FindFirstQuantityValueBaseMultiplier
    (AChannels: TObjectList<TChannel>): TMeterValue;
  var
    J: Integer;
  begin
    Result := nil;
    if AChannels = nil then
      Exit;

    for J := 0 to AChannels.Count - 1 do
      if (AChannels[J] <> nil) and (AChannels[J].FlowMeter <> nil) and
        (AChannels[J].FlowMeter.ValueQuantity <> nil) and
        (AChannels[J].FlowMeter.ValueQuantity.ValueBaseMultiplier <> nil) then
      begin
        Result := AChannels[J].FlowMeter.ValueQuantity.ValueBaseMultiplier;
        Exit;
      end;
  end;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;




  GridDevices.Repaint;
  GridEtalons.Repaint;

  if WorkTable.ValueTime <> nil then
    LabelTime.Text := FormatFloat('0', WorkTable.ValueTime.GetDoubleValue)
  else
    LabelTime.Text := '-';

  if WorkTable.ValueTemperture <> nil then
    LabelTemp.Text :=    WorkTable.ValueTemperture.GetStrValue
  else
    LabelTemp.Text := '-';

  if WorkTable.ValuePressure <> nil then
    EditPres.Text := WorkTable.ValuePressure.GetStrValue
  else
    EditPres.Text := '-';

  if WorkTable.ValueFlowRate <> nil then
    LabelFlowRate.Text := WorkTable.ValueFlowRate.GetStrValue
  else
    LabelFlowRate.Text := '-';

  if WorkTable.ValuePressure <> nil then
    LabelPressure.Text := WorkTable.ValuePressure.GetStrValue
  else
    LabelPressure.Text := '-';

  if WorkTable.ValueDensity <> nil then
    LabelDensity.Text := WorkTable.ValueDensity.GetStrValue
  else
    LabelDensity.Text := '-';

  if WorkTable.ValueQuantity <> nil then
    LabelQuantity.Text := WorkTable.ValueQuantity.GetStrValue
  else
    LabelQuantity.Text := '-';


    if WorkTable.ValueFlowRate <> nil then
      LabelNameFlowRate.Text :=  'Расход, ' + WorkTable.ValueFlowRate.GetDimName;
    if WorkTable.ValueTime <> nil then
      LabelNameTime.Text := WorkTable.ValueTime.GetStrFullName;
    if WorkTable.ValueQuantity <> nil then
      LabelNameQuantity.Text := WorkTable.ValueQuantity.GetStrFullName;
    if WorkTable.ValuePressure <> nil then
      LabelNamePressure.Text := WorkTable.ValuePressure.GetStrFullName;
    if WorkTable.ValueDensity <> nil then
      LabelNameDensity.Text := WorkTable.ValueDensity.GetStrFullName;
    if WorkTable.ValueTemperture <> nil then
      LabelNameTemperture.Text := WorkTable.ValueTemperture.GetStrFullName;


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

  RawValueBaseMultiplier := FindFirstValueBaseMultiplier(WorkTable.DeviceChannels);
  if RawValueBaseMultiplier = nil then
    RawValueBaseMultiplier := FindFirstValueBaseMultiplier(WorkTable.EtalonChannels);

  if RawValueBaseMultiplier <> nil then
  begin
    StringColumnDeviceRawValue1.Header := RawValueBaseMultiplier.GetStrFullName;
    StringColumnEtalonRawValue1.Header := RawValueBaseMultiplier.GetStrFullName;
  end;

  RawValueBaseMultiplier := FindFirstQuantityValueBaseMultiplier(WorkTable.DeviceChannels);
  if RawValueBaseMultiplier = nil then
    RawValueBaseMultiplier := FindFirstQuantityValueBaseMultiplier(WorkTable.EtalonChannels);

  if RawValueBaseMultiplier <> nil then
  begin
    StringColumnDeviceRawSumValue1.Header := RawValueBaseMultiplier.GetStrFullName;
    StringColumnEtalonRawSumValue1.Header := RawValueBaseMultiplier.GetStrFullName;
  end;


    if WorkTable.ValueFlowRate <> nil then
      StringColumnDeviceFlowRate1.TagString := WorkTable.ValueFlowRate.GetStrValue
    else
      StringColumnDeviceFlowRate1.TagString := '0';

    if WorkTable.ValueQuantity <> nil then
      StringColumnDeviceQuantity1.TagString := WorkTable.ValueQuantity.GetStrValue
    else
      StringColumnDeviceQuantity1.TagString := '0';



    if WorkTable.ValueFlowRate <> nil then
      StringColumnEtalonFlowRate1.TagString := WorkTable.ValueFlowRate.GetStrValue
    else
      StringColumnEtalonFlowRate1.TagString := '0';

    if WorkTable.ValueQuantity <> nil then
      StringColumnEtalonQuantity1.TagString := WorkTable.ValueQuantity.GetStrValue
    else
      StringColumnEtalonQuantity1.TagString := '0';
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
  FoundRepo, PreferredRepo: TTypeRepository;
  RepoName: string;
  RepoUUID: string;
  IsTypeChanged, NeedFill: Boolean;
  Ch: TChannel;
  Repo: TTypeRepository;
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
    PreferredRepo := nil;
    FoundRepo := nil;

    if Ch.FlowMeter.RepoTypeUUID <> '' then
    begin
      for Repo in DataManager.TypeRepositories do
        if SameText(Repo.UUID, Ch.FlowMeter.RepoTypeUUID) then
        begin
          PreferredRepo := Repo;
          Break;
        end;
    end;

    if PreferredRepo <> nil then
      DataManager.ActiveTypeRepo := PreferredRepo;

    CurrentType := DataManager.FindType(
      Ch.FlowMeter.DeviceTypeUUID,
      '',
      FoundRepo
    );

    if (CurrentType = nil) and (Ch.FlowMeter.DeviceTypeUUID <> '') then
    begin
      ShowMessage('Данный тип не найден. Загрузите репозитарий ' + Ch.FlowMeter.RepoTypeName);
    end;

    if (CurrentType = nil) and (Ch.TypeName <> '') then
      CurrentType := DataManager.FindType('', Ch.TypeName, FoundRepo);

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
    begin
      RepoName := FoundRepo.Name;
      RepoUUID := FoundRepo.UUID;
    end
    else
    begin
      RepoName := '';
      RepoUUID := '';
    end;

    // Новая идеология: канал проксирует в FlowMeter
    Ch.TypeName := NewType.Name;
    Ch.TypeUUID := NewType.MitUUID;
    Ch.RepoTypeName := RepoName;
    Ch.RepoTypeUUID := RepoUUID;

    if Assigned(Ch.FlowMeter) and Assigned(Ch.FlowMeter.Device) then
    begin
      Ch.FlowMeter.Device.DeviceTypeUUID := NewType.MitUUID;
      Ch.FlowMeter.Device.DeviceTypeName := NewType.Name;
      Ch.FlowMeter.Device.RepoTypeName := RepoName;
      Ch.FlowMeter.Device.RepoTypeUUID := RepoUUID;

      if IsTypeChanged then
      begin
        Ch.FlowMeter.Device.AttachType(NewType, RepoName);
        Ch.FlowMeter.Device.FillFromType(NewType);
      end;
    end;

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
  SetInstrumentalLayoutVisible(LayoutPump, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.SpeedButtonMinimizeConditionsClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutConditions, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.SpeedButtonMinimizeLayoutMainClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutMain, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.SpeedButtonMinimizeProceduresClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutProcedures, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.SpeedButtonMinimizeMesureClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutMesure, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutPump, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.SpeedButtonMinimzeLayoutFlowRateClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutFlowRate, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFormMain.ButtonMonitorClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  if WorkTable.MeasurementState = STATE_MONITOR then
    StopMonitor
  else
    StartMonitor;
end;

procedure TFormMain.TestButtonClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  if (TestButton.Tag = 6) and SameText(Trim(TestButton.Text), 'Сохранить?') then
  begin
    SaveMeasurementResults;
    OnChangeState(STATE_STANDBY);
    Exit;
  end;

  if WorkTable.MeasurementState = STATE_EXECUTE then
    StopTest
  else
    StartTest;
end;

procedure TFormMain.SaveMeasurementResults;
var
  WorkTable: TWorkTable;
  DeviceChannel: TChannel;
  Point: TPointSpillage;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  for DeviceChannel in WorkTable.DeviceChannels do
  begin
    if (DeviceChannel = nil) or (not DeviceChannel.Enabled) or
       (DeviceChannel.FlowMeter = nil) or (DeviceChannel.FlowMeter.Device = nil) then
      Continue;

    Point := TPointSpillage.Create(DeviceChannel.FlowMeter.Device.ID);
    try
      Point.DateTime := Now;
      Point.Num := DeviceChannel.FlowMeter.Device.Spillages.Count + 1;
      Point.Name := 'Измерение #' + IntToStr(Point.Num);
      Point.DeviceID := DeviceChannel.FlowMeter.Device.ID;
      Point.EtalonName := WorkTable.TableFlow.Name;
      Point.SpillTime := WorkTable.ValueTime.GetDoubleValue;
      Point.QavgEtalon := WorkTable.ValueFlowRate.GetDoubleValue;
      Point.EtalonVolume := WorkTable.ValueQuantity.GetDoubleValue;
      Point.DeviceVolume := DeviceChannel.FlowMeter.ValueQuantity.GetDoubleValue;
      Point.Error := DeviceChannel.FlowMeter.ValueError.GetDoubleValue;
      Point.PulseCount := Round(DeviceChannel.ValueImpResult.GetDoubleValue);
      Point.MeanFrequency := DeviceChannel.ValueImp.GetDoubleValue;
      Point.AvgCurrent := DeviceChannel.ValueCurrent.GetDoubleValue;
      Point.StartTemperature := WorkTable.ValueTempertureBefore.GetDoubleValue;
      Point.EndTemperature := WorkTable.ValueTempertureAfter.GetDoubleValue;
      Point.AvgTemperature := WorkTable.ValueTemperture.GetDoubleValue;
      Point.InputPressure := WorkTable.ValuePressureBefore.GetDoubleValue;
      Point.OutputPressure := WorkTable.ValuePressureAfter.GetDoubleValue;
      Point.AtmosphericPressure := WorkTable.ValueAirPressure.GetDoubleValue;
      Point.AmbientTemperature := WorkTable.ValueAirTemperture.GetDoubleValue;
      Point.RelativeHumidity := WorkTable.ValueHumidity.GetDoubleValue;
      Point.Valid := True;

      DeviceChannel.FlowMeter.AddDataPoint(Point);
    finally
      Point.Free;
    end;
  end;
end;

procedure TFormMain.ButtonCancelClick(Sender: TObject);
begin
  OnChangeState(STATE_STANDBY);
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
    begin
      WorkTable.DeviceChannels[Row].Enabled := not WorkTable.DeviceChannels[Row].Enabled;
      MarkChannelDeviceModified(WorkTable.DeviceChannels[Row]);
    end
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
    else if Column = StringColumnDeviceName1 then
    begin
      GridDevices.EditorMode := False;
      if WorkTable <> nil then
        OpenChannelDeviceEditor(WorkTable.DeviceChannels[Row]);
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
    else if GridDevices.Columns[ACol] = StringColumnDeviceName1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.Device <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.Device.Name
      else
        Value := '';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
      Value := WorkTable.DeviceChannels[ARow].Serial
    else if GridDevices.Columns[ACol] = StringColumnDeviceFlowRate1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow.GetStrValue
      else
        Value := '-';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceQuantity1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.GetStrValue
      else
        Value := '-';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceRawValue1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow.ValueBaseMultiplier <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow.ValueBaseMultiplier.GetStrValue
      else
        Value := '-';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceRawSumValue1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.ValueBaseMultiplier <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.ValueBaseMultiplier.GetStrValue
      else
        Value := '0';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceStd1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueFlow.GetStrStdDeviationPercent
      else
        Value := '-';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceError1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueError <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueError.GetStrValue
      else
        Value := '-';
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
  Changed: Boolean;
begin
  if IsUpdating then
    Exit;

  WorkTable := GetWorkTableByIndex(0);
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.DeviceChannels.Count) then
  begin
    Changed := False;

    if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
    begin
      Changed := WorkTable.DeviceChannels[ARow].Enabled <> Value.AsBoolean;
      WorkTable.DeviceChannels[ARow].Enabled := Value.AsBoolean;
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceChanel1 then
    begin
      Changed := WorkTable.DeviceChannels[ARow].Text <> Value.AsString;
      WorkTable.DeviceChannels[ARow].Text := Value.AsString;
    end
    else if GridDevices.Columns[ACol] = ColumnDeviceType1 then
    begin
      Changed := WorkTable.DeviceChannels[ARow].TypeName <> Value.AsString;
      WorkTable.DeviceChannels[ARow].TypeName := Value.AsString;
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
    begin
      Changed := WorkTable.DeviceChannels[ARow].Serial <> Value.AsString;
      WorkTable.DeviceChannels[ARow].Serial := Value.AsString;
    end
    else if GridDevices.Columns[ACol] = PopupColumnDeviceSignal1 then
      if TryGetOutputTypeFromValue(Value, Signal) then
      begin
        Changed := WorkTable.DeviceChannels[ARow].Signal <> Signal;
        WorkTable.DeviceChannels[ARow].Signal := Signal;
      end;

    if Changed then
      MarkChannelDeviceModified(WorkTable.DeviceChannels[ARow]);

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
    begin
      WorkTable.EtalonChannels[Row].Enabled := not WorkTable.EtalonChannels[Row].Enabled;
      MarkChannelDeviceModified(WorkTable.EtalonChannels[Row]);
    end
    else
      FRows[Row].Enabled := not FRows[Row].Enabled;

    if WorkTable <> nil then
      WorkTable.RebindAllFlowMeters;
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
    else if Column = StringColumnEtalonName1 then
    begin
      GridEtalons.EditorMode := False;
      if WorkTable <> nil then
        OpenChannelDeviceEditor(WorkTable.EtalonChannels[Row]);
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
    else if GridEtalons.Columns[ACol] = StringColumnEtalonName1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.Device <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.Device.Name
      else
        Value := '';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
      Value := WorkTable.EtalonChannels[ARow].Serial
    else if GridEtalons.Columns[ACol] = StringColumnEtalonFlowRate1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow.GetStrValue
      else
        Value := '-';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonQuantity1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity.GetStrValue
      else
        Value := '-';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonRawValue1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow.ValueBaseMultiplier <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow.ValueBaseMultiplier.GetStrValue
      else
        Value := '-';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonRawSumValue1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity.ValueBaseMultiplier <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueQuantity.ValueBaseMultiplier.GetStrValue
      else
        Value := '0';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonStd1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueFlow.GetStrStdDeviationPercent
      else
        Value := '-';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonError1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.ValueError <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.ValueError.GetStrValue
      else
        Value := '-';
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

procedure SoftReloadGridByGrowingRowCount(AGrid: TGrid; ANewRowCount: Integer;
  const ARefreshColumns: array of TColumn);
var
  I: Integer;
  Sel: Integer;
begin
  if AGrid = nil then
    Exit;

  Sel := AGrid.Selected;

  AGrid.BeginUpdate;
  try
    if AGrid.RowCount < ANewRowCount then
      for I := AGrid.RowCount + 1 to ANewRowCount do
        AGrid.RowCount := I
    else if AGrid.RowCount <> ANewRowCount then
      AGrid.RowCount := ANewRowCount;
  finally
    AGrid.EndUpdate;
  end;

  if (Sel >= 0) and (Sel < AGrid.RowCount) then
    AGrid.Selected := Sel;

  if Length(ARefreshColumns) = 0 then
    AGrid.Repaint
  else
    for I := Low(ARefreshColumns) to High(ARefreshColumns) do
      if ARefreshColumns[I] <> nil then
        ARefreshColumns[I].Repaint;
end;

procedure TFormMain.UpdateGrids;
var
  WT: TWorkTable;
begin
  WT := GetWorkTableByIndex(0);

  if WT <> nil then
    SoftReloadGridByGrowingRowCount(
      GridDevices,
      WT.DeviceChannels.Count,
      [StringColumnDeviceRawValue1, StringColumnDeviceRawSumValue1,
       StringColumnDeviceFlowRate1,
       StringColumnDeviceQuantity1, StringColumnDeviceError1]
    )
  else
    SoftReloadGridByGrowingRowCount(
      GridDevices,
      Length(FFlowMeterRows),
      [StringColumnDeviceRawValue1, StringColumnDeviceRawSumValue1,
       StringColumnDeviceFlowRate1,
       StringColumnDeviceQuantity1, StringColumnDeviceError1]
    );

  if WT <> nil then
    SoftReloadGridByGrowingRowCount(
      GridEtalons,
      WT.EtalonChannels.Count,
      [StringColumnEtalonRawValue1, StringColumnEtalonRawSumValue1,
       StringColumnEtalonFlowRate1,
       StringColumnEtalonQuantity1, StringColumnEtalonError1]
    )
  else
    SoftReloadGridByGrowingRowCount(
      GridEtalons,
      GridEtalons.RowCount,
      [StringColumnEtalonRawValue1, StringColumnEtalonRawSumValue1,
       StringColumnEtalonFlowRate1,
       StringColumnEtalonQuantity1, StringColumnEtalonError1]
    );
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
  Changed: Boolean;
begin
  if IsUpdating then
    Exit;

  WorkTable := GetWorkTableByIndex(0);
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.EtalonChannels.Count) then
  begin
    Changed := False;

    if GridEtalons.Columns[ACol] = CheckColumnEtalonEnable1 then
     begin
      Changed := WorkTable.EtalonChannels[ARow].Enabled <> Value.AsBoolean;
      WorkTable.EtalonChannels[ARow].Enabled := Value.AsBoolean;
      WorkTable.RebindAllFlowMeters;
     end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonChanel1 then
    begin
      Changed := WorkTable.EtalonChannels[ARow].Text <> Value.AsString;
      WorkTable.EtalonChannels[ARow].Text := Value.AsString;
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonType1 then
    begin
      Changed := WorkTable.EtalonChannels[ARow].TypeName <> Value.AsString;
      WorkTable.EtalonChannels[ARow].TypeName := Value.AsString;
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonSerial1 then
    begin
      Changed := WorkTable.EtalonChannels[ARow].Serial <> Value.AsString;
      WorkTable.EtalonChannels[ARow].Serial := Value.AsString;
    end
    else if GridEtalons.Columns[ACol] = PopupColumnEtalonSignal1 then
      if TryGetOutputTypeFromValue(Value, Signal) then
      begin
        Changed := WorkTable.EtalonChannels[ARow].Signal <> Signal;
        WorkTable.EtalonChannels[ARow].Signal := Signal;
      end;

    if Changed then
      MarkChannelDeviceModified(WorkTable.EtalonChannels[ARow]);

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
