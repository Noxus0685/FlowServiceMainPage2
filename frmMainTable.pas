unit frmMainTable;

interface

uses
  FMX.ActnList,
  FMX.Colors,
  FMX.ComboEdit,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.DateTimeCtrls,
  FMX.Dialogs,
  FMX.Edit,
  FMX.EditBox,
  FMX.Effects,
  FMX.Filter.Effects,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.ListView,
  FMX.ListView.Adapters.Base,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Menus,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.SpinBox,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.TreeView,
  FMX.Types,
  FMXTee.Chart,
  FMXTee.Engine,
  FMXTee.Procs,
  frmCalibrCoefs,
  frmChannelProperties,
  frmFlowMeterProperties,
  frmWorkTableProperties,
  frmMeasurementRun,
  frmMRResults,
  frmProceed,
  frmProtocol,
  fuDeviceEdit,
  fuDeviceSelect,
  fuMeterValues,
  fuTypeSelect,
  System.Actions,
  System.Classes,
  System.Generics.Collections,
  System.IniFiles,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uDeviceClass,
  uFlowMeter,
  uMeasurementRun,
  uMeterValue,
  uObservable,
  uParameter,
  uProtocols,
  uRepositories,
  uWorkTable;



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
    Device: TDevice;
    Name: string;
    DeviceType: string;
    Serial: string;
    PointNames: TArray<string>;
    PointValues: TArray<string>;
    PointStatuses: TArray<Integer>;
    ResultText: string;
    ResultStatus: Integer;
  end;

  TWorkTableCommandEvent = procedure(AWorkTable: TWorkTable;
    AAction: EActionWorkTable) of object;

  TFrameMainTable = class(TFrame, IEventObserver)
    TabControlWorkTables: TTabControl;
    PanelEtalons1: TPanel;
    LayoutEtalons1: TLayout;
    GridEtalons: TGrid;
    CheckColumnEtalonEnable1: TCheckColumn;
    StringColumnEtalonChanel1: TStringColumn;
    StringColumnEtalonType1: TStringColumn;
    StringColumnEtalonSerial1: TStringColumn;
    StringColumnEtalonFlowRate1: TStringColumn;
    StringColumnEtalonQuantity1: TStringColumn;
    StringColumnEtalonError1: TStringColumn;
    ToolBarEtalons1: TToolBar;
    Label30: TLabel;
    PanelDevices1: TPanel;
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
    SpeedButtonStartPump: TSpeedButton;
    SpeedButton28: TSpeedButton;
    Rectangle14: TRectangle;
    LabelLayoutPump: TLabel;
    LayoutConditions: TLayout;
    Layout9: TLayout;
    LayoutPressure: TLayout;
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
    LayoutFLR: TLayout;
    LayoutFLDisplay: TLayout;
    RectangleLabelFR: TRectangle;
    LabelFlowRate: TLabel;
    LayoutSpinEditFR: TLayout;
    LabelNameFlowRate: TLabel;
    SpinBoxFlowRate: TSpinBox;
    LayoutFREdit: TLayout;
    ComboEditUnits: TComboBox;
    SpeedButtonSetFlowRate: TSpeedButton;
    SpeedButtonStopChangeFlowRate: TSpeedButton;
    Rectangle15: TRectangle;
    LabelLayoutFlowRate: TLabel;
    Line6: TLine;
    Layout16: TLayout;
    LayoutTaskMain: TLayout;
    ComboBoxTaskMain: TComboBox;
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
    Splitter1: TSplitter;
    PopupColumnEtalonSignal1: TPopupColumn;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupColumnDeviceSignal1: TPopupColumn;
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
    TimerMain: TTimer;
    ActionMeterValueProperties: TAction;
    MenuItem8: TMenuItem;
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
    PopupMenuDevicesGrid: TPopupMenu;
    MenuItemDevicesWorkTablesGroup: TMenuItem;
    MenuItemDevicesWorkTablesAddTable: TMenuItem;
    MenuItemDevicesWorkTablesAddDeviceChannel: TMenuItem;
    MenuItemDevicesWorkTablesAddEtalonChannel: TMenuItem;
    MenuItemDevicesWorkTablesSaveWorkTable: TMenuItem;
    MenuItemDevicesWorkTablesMeterValueProperties: TMenuItem;
    MenuItemDevicesWorkTablesOpenDeviceSelect: TMenuItem;
    MenuItemDevicesWorkTablesDeleteDevice: TMenuItem;
    MenuItemDevicesWorkTablesDeleteEtalons: TMenuItem;
    MenuItemDevicesWorkTablesAddPump: TMenuItem;
    MenuItemDevicesWorkTablesDeletePump: TMenuItem;
    MenuItemDevicesColumnsGroup: TMenuItem;
    MenuItemDevicesColumnsChannelGroup: TMenuItem;
    MenuItemDevicesColumnsDeviceGroup: TMenuItem;
    MenuItemDevicesColumnsMeasureGroup: TMenuItem;
    MenuItemDevicesColumnsStatGroup: TMenuItem;
    MenuItemDevicesColumnsOtherGroup: TMenuItem;
    MenuItemDevicesColumn0: TMenuItem;
    MenuItemDevicesColumn1: TMenuItem;
    MenuItemDevicesColumn2: TMenuItem;
    MenuItemDevicesColumn3: TMenuItem;
    MenuItemDevicesColumn4: TMenuItem;
    MenuItemDevicesColumn5: TMenuItem;
    MenuItemDevicesColumn6: TMenuItem;
    MenuItemDevicesColumn7: TMenuItem;
    MenuItemDevicesColumn8: TMenuItem;
    MenuItemDevicesColumn9: TMenuItem;
    MenuItemDevicesColumn10: TMenuItem;
    MenuItemDevicesColumn11: TMenuItem;
    MenuItemDevicesColumn12: TMenuItem;
    MenuItemDevicesColumn13: TMenuItem;
    MenuItemDevicesColumn14: TMenuItem;
    MenuItemDevicesColumn15: TMenuItem;
    MenuItemDevicesColumn16: TMenuItem;
    MenuItemDevicesColumn17: TMenuItem;
    MenuItemDevicesColumn18: TMenuItem;
    MenuItemEtalonsWorkTablesGroup: TMenuItem;
    MenuItemEtalonsWorkTablesAddTable: TMenuItem;
    MenuItemEtalonsWorkTablesAddDeviceChannel: TMenuItem;
    MenuItemEtalonsWorkTablesAddEtalonChannel: TMenuItem;
    MenuItemEtalonsWorkTablesSaveWorkTable: TMenuItem;
    MenuItemEtalonsWorkTablesMeterValueProperties: TMenuItem;
    MenuItemEtalonsWorkTablesOpenDeviceSelect: TMenuItem;
    MenuItemEtalonsWorkTablesDeleteDevice: TMenuItem;
    MenuItemEtalonsWorkTablesDeleteEtalons: TMenuItem;
    MenuItemEtalonsWorkTablesAddPump: TMenuItem;
    MenuItemEtalonsWorkTablesDeletePump: TMenuItem;
    MenuItemEtalonsColumnsGroup: TMenuItem;
    MenuItemEtalonsColumnsChannelGroup: TMenuItem;
    MenuItemEtalonsColumnsDeviceGroup: TMenuItem;
    MenuItemEtalonsColumnsMeasureGroup: TMenuItem;
    MenuItemEtalonsColumnsStatGroup: TMenuItem;
    MenuItemEtalonsColumnsOtherGroup: TMenuItem;
    MenuItemEtalonsColumn0: TMenuItem;
    MenuItemEtalonsColumn1: TMenuItem;
    MenuItemEtalonsColumn2: TMenuItem;
    MenuItemEtalonsColumn3: TMenuItem;
    MenuItemEtalonsColumn4: TMenuItem;
    MenuItemEtalonsColumn5: TMenuItem;
    MenuItemEtalonsColumn6: TMenuItem;
    MenuItemEtalonsColumn7: TMenuItem;
    MenuItemEtalonsColumn8: TMenuItem;
    MenuItemEtalonsColumn9: TMenuItem;
    MenuItemEtalonsColumn10: TMenuItem;
    MenuItemEtalonsColumn11: TMenuItem;
    MenuItemEtalonsColumn12: TMenuItem;
    MenuItemEtalonsColumn13: TMenuItem;
    MenuItemEtalonsColumn14: TMenuItem;
    MenuItemDevicesAddGroup: TMenuItem;
    MenuItemDevicesAddChannel: TMenuItem;
    MenuItemDevicesSelectDevice: TMenuItem;
    MenuItemDevicesFromArchive: TMenuItem;
    MenuItemDevicesEditGroup: TMenuItem;
    MenuItemDevicesProperties: TMenuItem;
    MenuItemDevicesClearRow: TMenuItem;
    MenuItemDevicesCopy: TMenuItem;
    MenuItemDevicesPaste: TMenuItem;
    MenuItemDevicesSep1: TMenuItem;
    MenuItemDevicesClearAll: TMenuItem;
    MenuItemDevicesFillAllBySelected: TMenuItem;
    MenuItemDevicesDeleteGroup: TMenuItem;
    MenuItemDevicesDeleteChannel: TMenuItem;
    MenuItemDevicesOtherGroup: TMenuItem;
    MenuItemDevicesSetFlowSource: TMenuItem;
    MenuItemDevicesAssignEtalon: TMenuItem;
    PopupMenuEtalonsGrid: TPopupMenu;
    MenuItemEtalonsAddGroup: TMenuItem;
    MenuItemEtalonsAddChannel: TMenuItem;
    MenuItemEtalonsFromArchive: TMenuItem;
    MenuItemEtalonsEditGroup: TMenuItem;
    MenuItemEtalonsClearRow: TMenuItem;
    MenuItemEtalonsCopy: TMenuItem;
    MenuItemEtalonsPaste: TMenuItem;
    MenuItemEtalonsSep1: TMenuItem;
    MenuItemEtalonsClearAll: TMenuItem;
    MenuItemEtalonsFillAllBySelected: TMenuItem;
    MenuItemEtalonsDeleteGroup: TMenuItem;
    MenuItemEtalonsDeleteChannel: TMenuItem;
    MenuItemEtalonsOtherGroup: TMenuItem;
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
    HorzScrollBoxInstrumental: THorzScrollBox;
    Layout: TLayout;
    LayoutControl: TLayout;
    ButtonMonitor: TButton;
    CircleIndicatorMonitor: TCircle;
    LayoutButtonTest: TLayout;
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
    SwitchAuto: TSwitch;
    LabelAuto: TLabel;
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
    ComboBoxPumps: TComboBox;
    StringColumnUUID1: TStringColumn;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    PopupColumnEtalonDN1: TPopupColumn;
    PopupColumnDeviceDN1: TPopupColumn;

    SpeedButton6: TSpeedButton;
    LayoutCenter: TLayout;
    Splitter2: TSplitter;
    PanelProperties: TPanel;
    TabControlDevices: TTabControl;
    TabItemMeasurmentRun: TTabItem;
    TabItemMRResults: TTabItem;
    TabItemChannelProperties: TTabItem;
    TabItemWorkTableProperties: TTabItem;
    StringColumnDeviceCoef1: TStringColumn;
    ActionSessionCreatePoints: TAction;
    LayoutRepeats: TLayout;
    RectangleRepeats: TRectangle;
    LabelRepeat: TLabel;
    LabelRepeatsName: TLabel;
    EditRepeats: TEdit;
    TabItemProtocol: TTabItem;
    LayoutProtocolHost: TLayout;
    TabItemDeviceProperties: TTabItem;
    ActionDeleteDevice: TAction;
    ActionDeleteEtalons: TAction;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    ActionPumpAdd: TAction;
    MenuItemAddPump: TMenuItem;
    MenuItemDeletePump: TMenuItem;
    ActionPumpDelete: TAction;
    StyleBook1: TStyleBook;
    PanelControlWorkTables: TPanel;

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
    procedure GridDevicesHeaderClick(Column: TColumn);
    procedure ActionAddWorkTableExecute(Sender: TObject);
    procedure ActionAddDeviceChannelExecute(Sender: TObject);
    procedure ActionAddEtalonChannelExecute(Sender: TObject);
    procedure ActionSaveWorkTableExecute(Sender: TObject);
    procedure ActionMeterValuesPropertiesExecute(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
    procedure SetSessionDim(UnitName: string; QuantityUnitName: string);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
    procedure ActionOpenDeviceEditorExecute(Sender: TObject);
    procedure ActionOpenDeviceSelectExecute(Sender: TObject);
    procedure SpeedButtonMinimizeMesureClick(Sender: TObject);
    procedure SpeedButtonMinimizeConditionsClick(Sender: TObject);
    procedure SpeedButtonMinimizeLayoutMainClick(Sender: TObject);
    procedure SpeedButtonMinimizeProceduresClick(Sender: TObject);
    procedure SpeedButtonMinimzeLayoutFlowRateClick(Sender: TObject);
    procedure PopupMenuInstrumentalLayOutPopup(Sender: TObject);
    procedure PopupMenuWorkTablesPopup(Sender: TObject);
    procedure MenuInstrumentalLayOutClick(Sender: TObject);
    procedure PopupMenuDevicesGridPopup(Sender: TObject);
    procedure PopupMenuEtalonsGridPopup(Sender: TObject);
    procedure MenuGridLayOutClick(Sender: TObject);
    procedure PopupMenuGridDataPointsPopup(Sender: TObject);
    procedure PopupMenuGridResultsPopup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Circle1Click(Sender: TObject);
    procedure ButtonMonitorClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure TreeViewDevicesChange(Sender: TObject);
    procedure TreeViewDevicesMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure GridDataPointsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridDataPointsCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDataPointsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GridResultsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GridResultsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridResultsDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
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
    procedure ComboBoxUnitsChange(Sender: TObject);
    procedure SetDim(FlowUnitName: string; QuantityUnitName: string);
    procedure SpeedButtonStartPumpClick(Sender: TObject);
    procedure ComboBoxPumpsChange(Sender: TObject);
    procedure Rectangle14Click(Sender: TObject);
    procedure UpdateUIPump;
    procedure UpdateUIFlowRate;
    procedure ComboBoxPumpsClick(Sender: TObject);
    procedure SpinBoxFreqChange(Sender: TObject);
    procedure Rectangle15Click(Sender: TObject);
    procedure SpeedButtonSetFlowRateClick(Sender: TObject);
    procedure EditTempExit(Sender: TObject);
    procedure EditPresExit(Sender: TObject);

    procedure GridEtalonsCellDblClick(const Column: TColumn;
      const Row: Integer);
    procedure GridDevicesCellDblClick(const Column: TColumn;
      const Row: Integer);
    procedure GridDevicesSelectCell(Sender: TObject; const ACol, ARow: Integer;
      var CanSelect: Boolean);

    procedure SpeedButtonCreatePointsClick(Sender: TObject);
    procedure EditTimeExit(Sender: TObject);
    procedure EditVolumeExit(Sender: TObject);
    procedure EditImpExit(Sender: TObject);
    procedure EditPresCanFocus(Sender: TObject; var ACanFocus: Boolean);
    procedure EditTempCanFocus(Sender: TObject; var ACanFocus: Boolean);
    procedure ActionSessionCreatePointsExecute(Sender: TObject);
    procedure EditRepeatsExit(Sender: TObject);
    procedure SwitchAutoSwitch(Sender: TObject);
    procedure SpinBoxFlowRateChange(Sender: TObject);
    procedure ActionDeleteDeviceExecute(Sender: TObject);
    procedure ActionDeleteEtalonsExecute(Sender: TObject);
    procedure ActionPumpAddExecute(Sender: TObject);
    procedure ActionPumpDeleteExecute(Sender: TObject);
    procedure SpinBoxFreqExit(Sender: TObject);
    procedure SpinBoxFreqEnter(Sender: TObject);
    procedure GridDevicesEditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure Button1Click(Sender: TObject);
    procedure UpdateForm;

  private

  FActiveWorkTable: TWorkTable;
  FFrameMeasurementRun: TFrameMeasurementRun;
  FFrameMRResults: TFrameMRResults;
  FFrameProtocol: TFrameProtocol;
  FProtocolHostScroll: TVertScrollBox;
  FFrameFlowMeterProperties: TFrameFlowMeterProperties;
  FFrameChannelProperties: TFrameChannelProperties;
  FFrameWorkTableProperties: TFrameWorkTableProperties;
    { Private declarations }
  FLastClickRow: Integer;
  FLastClickCol: TColumn;
  FLastClickTick: Cardinal;

  FRows: array of TRowData;
  IsUpdating: Boolean;

    FFlowMeters: TObjectList<TFlowMeter>;
    FFlowMeterRows: TArray<TFlowMeterRowData>;

    procedure OpenTypeSelect(ARow: Integer; const AIsEtalon: Boolean = False);
    procedure OpenChannelDeviceEditor(AChannel: TChannel);
    procedure SelectDeviceForChannel(AChannel: TChannel);
    procedure InitTables;
    procedure ApplyFlowMeterSelection(const ARow: Integer);
    function FindTypeIndex(const ATypeName: string): Integer;
    function FindSerialIndex(const ASerialNumber: string): Integer;
    function GetWorkTableByIndex(const AIndex: Integer): TWorkTable;
    // Проверяет, что ссылка на рабочий стол ещё принадлежит менеджеру.
    function IsManagedWorkTable(AWorkTable: TWorkTable): Boolean;
    function CanEditActiveWorkTable: Boolean;
    // Сбрасывает устаревшую ссылку FActiveWorkTable после удаления рабочего стола.
    procedure NormalizeActiveWorkTable;
    procedure UpdateGridDevices;
    procedure EnsureEmptyDevicesForGridRows;
    function ShouldReleaseGridDeviceBeforeSave(AChannel: TChannel; ADevice: TDevice): Boolean;

    procedure UpdateUIFromValues;
    procedure SetValues;
    function ResolveTypeForChannel(AChannel: TChannel; out ARepo: TTypeRepository): TDeviceType;
    procedure FillDNItemsForChannel(AChannel: TChannel; APopupColumn: TPopupColumn);
    function ApplyChannelDNChange(AChannel: TChannel; const ANewDN: string): Boolean;
    procedure ApplyActiveWorkTableEditMode;
    procedure UpdateGridPopupActions;
    procedure CaptureGridColumnsLayout(AGrid: TGrid; out AColumns: TArray<TGridColumnLayout>);
    procedure ApplyGridColumnsLayout(AGrid: TGrid; const AColumns: TArray<TGridColumnLayout>);
    procedure EnforceDataPointsColumnsLayout;
    procedure MarkChannelDeviceModified(AChannel: TChannel);
    procedure ApplyMonitorIndicatorColor(const AColor: TAlphaColor);
    procedure RefreshMonitorIndicator;
    procedure RefreshPumpsCombo;
    procedure UpdateConditionsCurrentValues(AWorkTable: TWorkTable);
    procedure AttachType(AChannel: TChannel; ANewType: TDeviceType;
      AFoundRepo: TTypeRepository; const AIsTypeChanged: Boolean);

    procedure SetConfiguration;
    procedure StartMonitor;
    procedure StopMonitor;
    procedure StartTest;
    procedure StopTest;
    procedure RequestStartTest;
    procedure RequestStopTest;


    procedure UpdateGrids;


    procedure ClearChannelData(AChannel: TChannel; AWorkTable: TWorkTable = nil);
    procedure ClearChannelsByMissingDevices;
    procedure RemoveDeviceChannelsByDeletedUUIDs(ADeletedUUIDs: TStrings);
    procedure RemoveDeviceChannelsByDeletedUUIDsFromWorkTable(
      AWorkTable: TWorkTable; ADeletedUUIDs: TStrings);
    function ChannelMatchesDeletedDevice(AChannel: TChannel; ADeletedUUIDs: TStrings): Boolean;
    procedure CopyChannelData(ASource, ADest: TChannel);
    procedure SyncChannelsWithSameDeviceUUID(AChangedChannel: TChannel; const AOldUUID: string);
    function GetSelectedChannel(AChannels: TObjectList<TChannel>; AGrid: TGrid): TChannel;



  private
    FInitialized: Boolean;
    FChange: string ;
    FInstrumentalVisibleOrder: TList<TLayout>;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
    FOnWorkTableCommand: TWorkTableCommandEvent;
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
  public
    { Public declarations }
    procedure Initialize;
    destructor Destroy; override;

    procedure OnChangeState(const ANewState: EStateWorkTable);
    procedure OnChangePoint(ASender: TObject; APoint: TDevicePoint;
      APointIndex: Integer);
    procedure HandleWorkTableStateChanged(const AWorkTable: TWorkTable; AData: TObject);
    procedure HandleWorkTableAction(const AWorkTable: TWorkTable; AData: TObject);
    procedure HandleWorkTableEvent(const AWorkTable: TWorkTable; AData: TObject);
    procedure HandlePumpStateChanged(const APump: TPump);
    procedure HandlePumpAction(const APump: TPump);
    procedure HandleFlowRateStateChanged(const AFlowRate: TFlowRate);
    procedure HandleFlowRateAction(const AFlowRate: TFlowRate);
    procedure HandleFluidTempStateChanged(const AFluidTemp: TFluidTemp);
    procedure HandleFluidTempAction(const AFluidTemp: TFluidTemp);
    procedure HandleFluidPressStateChanged(const AFluidPress: TFluidPress);
    procedure HandleFluidPressAction(const AFluidPress: TFluidPress);
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);

    procedure SaveLayoutSettingsToWorkTable;
    procedure LoadLayoutSettingsFromWorkTable;
    procedure ReleaseEmptyGridDevicesBeforeSave;
    property OnWorkTableCommand: TWorkTableCommandEvent read FOnWorkTableCommand write FOnWorkTableCommand;


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
    procedure PersistDeviceAsync(ADevice: TDevice);
    procedure UpdateUIConditions;
    function   GetMeasurementRun: TMeasurementRun;
    procedure UpdateFlowMeterPropertiesFrame(ARow: Integer = -1);

    property  MeasurementRun:TMeasurementRun read GetMeasurementRun;

  end;



implementation



{$R *.fmx}

uses
  fuTable_Main;


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

  CProcessingDevicesSection = 'ProcessingDevices';
  CProcessingDevicesCountKey = 'Count';
  CProcessingDevicesItemKeyPrefix = 'Item';
  CEmptyGridDeviceComment = '[GridDevices.EmptyPlaceholder]';

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

destructor TFrameMainTable.Destroy;
begin
  FreeAndNil(FFrameMeasurementRun);
  FreeAndNil(FFrameMRResults);
  FreeAndNil(FFrameProtocol);
  FreeAndNil(FProtocolHostScroll);
  FreeAndNil(FFrameFlowMeterProperties);
  FreeAndNil(FFrameChannelProperties);
  FreeAndNil(FFrameWorkTableProperties);
  FreeAndNil(FDeviceClipboard.Snapshot);
  FreeAndNil(FEtalonClipboard.Snapshot);
  FInstrumentalVisibleOrder.Free;
  inherited;
end;

function TFrameMainTable.GetMeasurementRun: TMeasurementRun;
begin
  Result := nil;

  if FActiveWorkTable = nil then
    Exit;

  if FActiveWorkTable.MeasurementRun = nil then
    Exit;

  Result := TMeasurementRun(FActiveWorkTable.MeasurementRun);
end;

procedure TFrameMainTable.UpdateFlowMeterPropertiesFrame(ARow: Integer = -1);
var
  Meter: TFlowMeter;
begin
  if FFrameFlowMeterProperties = nil then
    Exit;

  Meter := nil;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.DeviceChannels <> nil) then
  begin
    if ARow < 0 then
      ARow := GridDevices.Selected;

    if (ARow >= 0) and (ARow < FActiveWorkTable.DeviceChannels.Count) and
       (FActiveWorkTable.DeviceChannels[ARow] <> nil) then
      Meter := FActiveWorkTable.DeviceChannels[ARow].FlowMeter;
  end;

  FFrameFlowMeterProperties.FlowMeter := Meter;
end;

procedure TFrameMainTable.ApplyMonitorIndicatorColor(const AColor: TAlphaColor);
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

procedure TFrameMainTable.RefreshMonitorIndicator;
begin
  if CircleIndicatorMonitor = nil then
    Exit;

  CircleIndicatorMonitor.Repaint;
  ButtonMonitor.Repaint;
end;

procedure TFrameMainTable.RefreshPumpsCombo;
var
  Pump: TPump;
  SelectedPumpName: string;
  ItemIndex: Integer;
begin
  ComboBoxPumps.Items.Clear;
  ComboBoxPumps.ItemIndex := -1;

  if FActiveWorkTable = nil then
  begin
    //ComboBoxPumps.Text := '';
    Exit;
  end;

  SelectedPumpName := Trim(ComboBoxPumps.Text);
  for Pump in FActiveWorkTable.Pumps do
    ComboBoxPumps.Items.Add(Pump.Name);

  ItemIndex := -1;
  if SelectedPumpName <> '' then
    ItemIndex := ComboBoxPumps.Items.IndexOf(SelectedPumpName);
  if (ItemIndex < 0) and (ComboBoxPumps.Items.Count > 0) then
    ItemIndex := 0;

  ComboBoxPumps.ItemIndex := ItemIndex;
 { if ItemIndex >= 0 then
    ComboBoxPumps.Text := ComboBoxPumps.Items[ItemIndex]
  else
    ComboBoxPumps.Text := '';   }


end;

procedure TFrameMainTable.SetConfiguration;
begin
  if FActiveWorkTable <> nil then
    FActiveWorkTable.State:= swtCONFIGED;
end;

procedure TFrameMainTable.StartMonitor;
begin
  if FActiveWorkTable <> nil then
  begin
    ProtocolManager.AddMessage(pcAction, psForm, 'StartMonitor', 'Запуск мониторинга из UI', FActiveWorkTable.Name);
    FActiveWorkTable.StartMonitor;
  end;
end;

procedure TFrameMainTable.StopMonitor;
begin
  if FActiveWorkTable <> nil then
  begin
    FActiveWorkTable.StopMonitor;
    ProtocolManager.AddMessage(pcAction, psForm, 'StopMonitor', 'Пользователь запросил остановку мониторинга', FActiveWorkTable.Name);
  end;
end;

procedure TFrameMainTable.RequestStartTest;
begin
  if Assigned(FOnWorkTableCommand) and (FActiveWorkTable <> nil) then
    FOnWorkTableCommand(FActiveWorkTable, awtStartTest);
end;

procedure TFrameMainTable.RequestStopTest;
begin
  if Assigned(FOnWorkTableCommand) and (FActiveWorkTable <> nil) then
    FOnWorkTableCommand(FActiveWorkTable, awtStopTest);
end;

procedure TFrameMainTable.StartTest;
begin
  if FActiveWorkTable = nil then
    Exit;

  if MeasurementRun = nil then
  begin
    ProtocolManager.AddMessage(pcWarning, psForm, 'StartTest',
      'Невозможно запустить измерение: MeasurementRun не создан', FActiveWorkTable.Name);
    Exit;
  end;

  FActiveWorkTable.MeasurementMode := MeasurementRun.Mode;
  RequestStartTest;
  ProtocolManager.AddMessage(pcAction, psForm, 'StartTest', 'Пользователь запустил измерение', FActiveWorkTable.Name);

  end;

procedure TFrameMainTable.StopTest;
begin

  if FActiveWorkTable = nil then
    Exit;

  if MeasurementRun = nil then
  begin
    ProtocolManager.AddMessage(pcWarning, psForm, 'StopTest',
      'Невозможно остановить измерение: MeasurementRun не создан', FActiveWorkTable.Name);
    Exit;
  end;

   RequestStopTest;
   ProtocolManager.AddMessage(pcAction, psForm, 'StopTest', 'Пользователь останавливает измерение', FActiveWorkTable.Name);
 
end;

 procedure TFrameMainTable.SwitchAutoSwitch(Sender: TObject);
begin
        if MeasurementRun=nil then
        begin
            SwitchAuto.IsChecked:=False;
            Exit;
        end;

           if SwitchAuto.IsChecked then
           begin
             MeasurementRun.Mode:= EMeasurementRunMode.mrmAutomatic;
             if FActiveWorkTable <> nil then
               FActiveWorkTable.MeasurementMode := EMeasurementRunMode.mrmAutomatic;
           end
           else
           begin
             MeasurementRun.Mode:= EMeasurementRunMode.mrmManual;
             if FActiveWorkTable <> nil then
               FActiveWorkTable.MeasurementMode := EMeasurementRunMode.mrmManual;
           end;

end;

procedure TFrameMainTable.UpdateForm;
 begin
          NormalizeActiveWorkTable;
          if FActiveWorkTable = nil then
          begin
            UpdateGrids;
            if FFrameWorkTableProperties <> nil then
              FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
            ApplyActiveWorkTableEditMode;
            Exit;
          end;

          IsUpdating := True;
            try
               UpdateUIFromValues;
                UpdateGrids;
                if FFrameWorkTableProperties <> nil then
                  FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
                ApplyActiveWorkTableEditMode;
            finally
          IsUpdating := False;
          end;
 end;

procedure TFrameMainTable.OnChangePoint(ASender: TObject; APoint: TDevicePoint;
    APointIndex: Integer);
begin
  {}
end;

procedure TFrameMainTable.HandleWorkTableStateChanged(const AWorkTable: TWorkTable; AData: TObject);
var
  Point: TDevicePoint;
begin
  OnChangeState(AWorkTable.State);

  if AData is TDevicePoint then
    Point := TDevicePoint(AData)
  else
    Point := AWorkTable.CurrentPoint;

  if Point <> nil then
    OnChangePoint(AWorkTable, Point, -1);

  UpdateForm;
end;

procedure TFrameMainTable.HandleWorkTableAction(const AWorkTable: TWorkTable; AData: TObject);
begin
  case AWorkTable.Action of
    awtStartTest:
      begin
        AWorkTable.ExecuteAction;
        if (AWorkTable = FActiveWorkTable) and (MeasurementRun <> nil) then
          MeasurementRun.Execute(mcStart);
        Exit;
      end;

    awtStopTest:
      begin
        AWorkTable.ExecuteAction;
        if (AWorkTable = FActiveWorkTable) and (MeasurementRun <> nil) then
          MeasurementRun.Execute(mcStop);
        Exit;
      end;
  else
    AWorkTable.ExecuteAction;
  end;

  if AData is TDevicePoint then
    OnChangePoint(AWorkTable, TDevicePoint(AData), -1);

  UpdateForm;
end;

procedure TFrameMainTable.HandleWorkTableEvent(const AWorkTable: TWorkTable; AData: TObject);
var
  WorkTableEvent: TWorkTableEvent;
begin
  if AWorkTable = nil then
    Exit;

  if (AWorkTable.Event >= Ord(Low(TWorkTableEvent))) and
     (AWorkTable.Event <= Ord(High(TWorkTableEvent))) then
    WorkTableEvent := TWorkTableEvent(AWorkTable.Event)
  else
    WorkTableEvent := ewtNone;

  if WorkTableEvent = ewtActivated then
  begin
    if FActiveWorkTable <> AWorkTable then
    begin
      FActiveWorkTable := AWorkTable;

      if FFrameMeasurementRun <> nil then
        FFrameMeasurementRun.ActiveWorkTable := FActiveWorkTable;
      if FFrameMRResults <> nil then
        FFrameMRResults.ActiveWorkTable := FActiveWorkTable;
    end;

    if FFrameWorkTableProperties <> nil then
      FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);

    SetValues;
    UpdateForm;
    Exit;
  end;

  if WorkTableEvent = ewtRefresh then
  begin
    if FActiveWorkTable = AWorkTable then
    begin
      UpdateForm;
      if (FFrameChannelProperties <> nil) and (GridDevices.Row >= 0) and
         (GridDevices.Row < FActiveWorkTable.DeviceChannels.Count) then
        FFrameChannelProperties.LoadFromChannel(FActiveWorkTable.DeviceChannels[GridDevices.Row]);
      if FFrameWorkTableProperties <> nil then
        FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
    end;
    Exit;
  end;

  HandleWorkTableAction(AWorkTable, AData);
end;

procedure TFrameMainTable.HandlePumpStateChanged(const APump: TPump);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ActivePump = APump) then
    UpdateUIPump;
end;

procedure TFrameMainTable.HandlePumpAction(const APump: TPump);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ActivePump = APump) then
    UpdateUIPump;
  RefreshPumpsCombo;
end;

procedure TFrameMainTable.HandleFlowRateStateChanged(const AFlowRate: TFlowRate);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.FlowRate = AFlowRate) then
    UpdateUIFlowRate;
end;

procedure TFrameMainTable.HandleFlowRateAction(const AFlowRate: TFlowRate);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.FlowRate = AFlowRate) then
    UpdateUIFlowRate;
end;

procedure TFrameMainTable.HandleFluidTempStateChanged(const AFluidTemp: TFluidTemp);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.FluidTemp = AFluidTemp) then
    UpdateUIConditions;
end;

procedure TFrameMainTable.HandleFluidTempAction(const AFluidTemp: TFluidTemp);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.FluidTemp = AFluidTemp) then
    UpdateUIConditions;
end;

procedure TFrameMainTable.HandleFluidPressStateChanged(const AFluidPress: TFluidPress);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.FluidPress = AFluidPress) then
    UpdateUIConditions;
end;

procedure TFrameMainTable.HandleFluidPressAction(const AFluidPress: TFluidPress);
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.FluidPress = AFluidPress) then
    UpdateUIConditions;
end;

procedure TFrameMainTable.OnNotify(Sender: TObject; Event: Integer; Data: TObject);
const
  notifyStateChanged = 1;
  notifyAction = 2;
  notifyEvent = 3;
type
  TNotifySenderKind = (
    nskUnknown,
    nskWorkTable,
    nskPump,
    nskFlowRate,
    nskFluidTemp,
    nskFluidPress
  );
var
  SenderKind: TNotifySenderKind;
begin
  if not Assigned(Sender) then
  begin
    ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
      Format('[Notify] Event=%d Sender=nil', [Event]), '');
    Exit;
  end;

  if Sender is TWorkTable then
    SenderKind := nskWorkTable
  else if Sender is TPump then
    SenderKind := nskPump
  else if Sender is TFlowRate then
    SenderKind := nskFlowRate
  else if Sender is TFluidTemp then
    SenderKind := nskFluidTemp
  else if Sender is TFluidPress then
    SenderKind := nskFluidPress
  else
    SenderKind := nskUnknown;

  if (SenderKind = nskWorkTable) and (FActiveWorkTable <> nil) and
     (TWorkTable(Sender) <> FActiveWorkTable) then
  begin
    if (Event <> notifyEvent) or (TWorkTable(Sender).Event <> Ord(ewtActivated)) then
      Exit;
  end;

  case SenderKind of
    nskWorkTable:
      case Event of
        notifyStateChanged: HandleWorkTableStateChanged(TWorkTable(Sender), Data);
        notifyAction: HandleWorkTableAction(TWorkTable(Sender), Data);
        notifyEvent: HandleWorkTableEvent(TWorkTable(Sender), Data);
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[WorkTable.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskPump:
      case Event of
        notifyStateChanged: HandlePumpStateChanged(TPump(Sender));
        notifyAction: HandlePumpAction(TPump(Sender));
        notifyEvent: HandlePumpAction(TPump(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[Pump.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskFlowRate:
      case Event of
        notifyStateChanged: HandleFlowRateStateChanged(TFlowRate(Sender));
        notifyAction: HandleFlowRateAction(TFlowRate(Sender));
        notifyEvent: HandleFlowRateAction(TFlowRate(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[FlowRate.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskFluidTemp:
      case Event of
        notifyStateChanged: HandleFluidTempStateChanged(TFluidTemp(Sender));
        notifyAction: HandleFluidTempAction(TFluidTemp(Sender));
        notifyEvent: HandleFluidTempAction(TFluidTemp(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[FluidTemp.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskFluidPress:
      case Event of
        notifyStateChanged: HandleFluidPressStateChanged(TFluidPress(Sender));
        notifyAction: HandleFluidPressAction(TFluidPress(Sender));
        notifyEvent: HandleFluidPressAction(TFluidPress(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[FluidPress.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;
  else
    ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
      Format('[Notify] Unsupported Sender=%s Event=%d Data=%s',
        [Sender.ClassName, Event, ObjClassNameOrNil(Data)]), '');
  end;
end;

procedure TFrameMainTable.OnChangeState(const ANewState: EStateWorkTable); //ChangeStateHandler
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.State <> ANewState) then
  begin
    FActiveWorkTable.State := ANewState;
    Exit;
  end;

  case ANewState of
    swtNONE:
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


    swtSTANDBY:
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

    swtCONNECTED:
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

    swtCONFIGED:
      begin
        // Статус зафиксирован после отправки настроек.
      end;

    swtSTARTTEST:
      begin
        ButtonMonitor.Enabled := False;
        TestButton.Text := 'Запуск';
        TestButton.Tag := 2;
        TestButton.Enabled := False;
       // ResetMeasurementValues;
      end;

    swtSTARTMONITOR:
      begin
        ButtonCancel.Visible := False;
       // ResetMeasurementValues;
      end;

    swtSTARTMONITORWAIT:
      begin
        ApplyMonitorIndicatorColor(GlowMesYellow.GlowColor);
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        GlowMesYellow.Enabled := False;
      end;

    swtMONITOR:
      begin
        ApplyMonitorIndicatorColor(GlowMesGreen.GlowColor);
      end;

    swtSTOPMONITOR:
      begin
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
        UpdateForm;
      end;

    swtSTARTWAIT:
      begin
        GlowMesYellow.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
        TestButton.Text := 'Стоп';
        TestButton.Tag := 3;
        TestButton.Enabled := True;
       // ResetMeasurementValues;
      end;

    swtEXECUTE:
      begin
        GlowMesGreen.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesYellow.Enabled := False;
      end;

    swtSTOPTEST:
      begin
        TestButton.Text := 'Завершение';
        TestButton.Tag := 4;
        TestButton.Enabled := False;
        UpdateForm;
      end;

    swtSTOPWAIT:
      begin
        // Ожидание завершения остановки.
      end;

    swtCOMPLETE:
      begin
        TestButton.Text := 'Сохранение';
        TestButton.Tag := 5;
        TestButton.Enabled := False;
        GlowMesYellow.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
      end;

    swtFINALREAD:
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

    swtFAILURE:
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
      // swtNONE
    end;
  end;
end;

procedure TFrameMainTable.FormCreate(Sender: TObject);
begin
  Initialize;
end;

procedure TFrameMainTable.Initialize;
var
  OT: TOutputType;
  UnitName: string;
  LayoutOrder: string;

begin
  if FInitialized then
    Exit;



  FInitialized := True;
  SwitchAuto.IsChecked := False;
  FInstrumentalVisibleOrder := TList<TLayout>.Create;
  FFrameProceed := nil;
  FFrameMeasurementRun := nil;
  FFrameMRResults := nil;
  FFrameProtocol := nil;
  FFrameFlowMeterProperties := nil;
  FFrameChannelProperties := nil;
  FFrameWorkTableProperties := nil;

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

  if ComboEditUnits.Items.Count > 0 then
    ComboEditUnits.ItemIndex := 0;

  SetLength(FRows, 0);

  InitTables;

  if FFrameMeasurementRun = nil then
  begin
    FFrameMeasurementRun := TFrameMeasurementRun.Create(Self);
    FFrameMeasurementRun.Parent := TabItemMeasurmentRun;
    FFrameMeasurementRun.Align := TAlignLayout.Client;
  end;
  FFrameMeasurementRun.ActiveWorkTable := FActiveWorkTable;

  if FFrameMRResults = nil then
  begin
    FFrameMRResults := TFrameMRResults.Create(Self);
    FFrameMRResults.Parent := TabItemMRResults;
    FFrameMRResults.Align := TAlignLayout.Client;
  end;
  FFrameMRResults.ActiveWorkTable := FActiveWorkTable;

  if FFrameProtocol = nil then
  begin
    if FProtocolHostScroll = nil then
    begin
      FProtocolHostScroll := TVertScrollBox.Create(Self);
      FProtocolHostScroll.Parent := LayoutProtocolHost;
      FProtocolHostScroll.Align := TAlignLayout.Client;
      FProtocolHostScroll.Stored := False;
      FProtocolHostScroll.ShowScrollBars := True;
    end;
    FFrameProtocol := TFrameProtocol.Create(Self);
    FFrameProtocol.Parent := FProtocolHostScroll;
    FFrameProtocol.Align := TAlignLayout.Client;
  end;

  if FFrameFlowMeterProperties = nil then
  begin
    FFrameFlowMeterProperties := TFrameFlowMeterProperties.Create(Self);
    FFrameFlowMeterProperties.Parent := TabItemDeviceProperties;
    FFrameFlowMeterProperties.Align := TAlignLayout.Client;
  end;
  UpdateFlowMeterPropertiesFrame;

  if FFrameChannelProperties = nil then
  begin
    FFrameChannelProperties := TFrameChannelProperties.Create(Self);
    FFrameChannelProperties.Parent := TabItemChannelProperties;
    FFrameChannelProperties.Align := TAlignLayout.Client;
  end;

  if FFrameWorkTableProperties = nil then
  begin
    FFrameWorkTableProperties := TFrameWorkTableProperties.Create(Self);
    FFrameWorkTableProperties.Parent := TabItemWorkTableProperties;
    FFrameWorkTableProperties.Align := TAlignLayout.Client;
  end;
  FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
  PopupMenuWorkTables.OnPopup := PopupMenuWorkTablesPopup;
  ApplyActiveWorkTableEditMode;

  RefreshPumpsCombo;

  FLastClickRow := -1;
  FLastClickCol := nil;
  FLastClickTick := 0;

  Randomize;


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

  EnforceDataPointsColumnsLayout;


  SetValues;
  UpdateForm;
  if FActiveWorkTable <> nil then
  begin
    FActiveWorkTable.NextClimateChangeAt := Now;
    FActiveWorkTable.State := swtNONE;
    if FFrameWorkTableProperties <> nil then
      FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
  end
  else
    OnChangeState(swtNONE);
end;

procedure TFrameMainTable.TabControl1Change(Sender: TObject);
begin
//  if (TabControl1.ActiveTab = TabItemResults) and (FFrameProceed <> nil) then
//    FFrameProceed.RefreshResultsTab;
end;

procedure TFrameMainTable.SetSessionDim(UnitName: string; QuantityUnitName: string);
begin
  if FFrameProceed <> nil then
    FFrameProceed.SetSessionDim(UnitName, QuantityUnitName);
end;

procedure TFrameMainTable.PopupMenuGridDataPointsPopup(Sender: TObject);
begin
  if not CanEditActiveWorkTable then
    Exit;

 // if FFrameProceed <> nil then
 //   FFrameProceed.PopupMenuGridDataPointsPopup(Sender);
end;

procedure TFrameMainTable.PopupMenuGridResultsPopup(Sender: TObject);
begin
  if not CanEditActiveWorkTable then
    Exit;

 // if FFrameProceed <> nil then
 //   FFrameProceed.PopupMenuGridResultsPopup(Sender);
end;

procedure TFrameMainTable.TreeViewDevicesChange(Sender: TObject);
begin
  if FFrameProceed <> nil then
    FFrameProceed.TreeViewDevicesChange(Sender);
end;

procedure TFrameMainTable.TreeViewDevicesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if FFrameProceed <> nil then
    FFrameProceed.TreeViewDevicesMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFrameMainTable.GridDataPointsGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
  if FFrameProceed <> nil then
    FFrameProceed.GridDataPointsGetValue(Sender, ACol, ARow, Value);
end;

procedure TFrameMainTable.GridDataPointsCellClick(const Column: TColumn; const Row: Integer);
begin
  if FFrameProceed <> nil then
    FFrameProceed.GridDataPointsCellClick(Column, Row);
end;

procedure TFrameMainTable.GridDataPointsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if FFrameProceed <> nil then
    FFrameProceed.GridDataPointsMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFrameMainTable.GridResultsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if FFrameProceed <> nil then
    FFrameProceed.GridResultsMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFrameMainTable.GridResultsGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
  if FFrameProceed <> nil then
    FFrameProceed.GridResultsGetValue(Sender, ACol, ARow, Value);
end;

procedure TFrameMainTable.GridResultsDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
begin
  if FFrameProceed <> nil then
    FFrameProceed.GridResultsDrawColumnCell(Sender, Canvas, Column, Bounds, Row, Value, State);
end;

procedure TFrameMainTable.SpeedButton2Click(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutPump, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonMinimizeConditionsClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutConditions, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonMinimizeLayoutMainClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutMain, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonMinimizeProceduresClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutProcedures, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonMinimizeMesureClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutMesure, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonMinimizePumpLayoutClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutPump, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonMinimzeLayoutFlowRateClick(Sender: TObject);
begin
  SetInstrumentalLayoutVisible(LayoutFlowRate, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonSetFlowRateClick(Sender: TObject);
var
AValue:double;
begin
  AValue:= FActiveWorkTable.ValueFlowRate.GetDoubleBaseNum(SpinBoxFlowRate.Value,FActiveWorkTable.ValueFlowRate.CurrentDimIndex);
  //if not( SameValue(FActiveWorkTable.FlowRate.ValueSet ,AValue, MinDouble)) then
  FActiveWorkTable.FlowRate.DoFlowRateStart(AValue);
  ProtocolManager.AddMessage(pcAction, psForm, 'SetFlowRate', 'Пользователь задал расход', Format('Q=%.3f', [AValue]));
  UpdateUIFlowRate;
end;

procedure TFrameMainTable.SpeedButtonStartPumpClick(Sender: TObject);
begin

    if FActiveWorkTable.ActivePump=nil then
    begin
         ProtocolManager.AddMessage(pcWarning, psForm, 'PumpStart', 'Пользователь запустил насос', 'Активного насоса нет!');
          Exit;
    end;

  if  (LayoutPump.tag=0) or (LayoutPump.tag=3) then
  begin
    ProtocolManager.AddMessage(pcAction, psForm, 'PumpStart', 'Пользователь запустил насос', ComboBoxPumps.Text);
    FActiveWorkTable.ActivePump.DoPumpStart ;
    UpdateUIPump;
  end;
end;



procedure TFrameMainTable.SpinBoxFlowRateChange(Sender: TObject);
var
AValue:double;
StableStatus: RStableInfo;
begin

  if  SameValue(FActiveWorkTable.FlowRate.ValueSet.Value ,SpinBoxFlowRate.Value, MinDouble) then
       Exit;

  if  (LayoutFlowRate.tag=0) or (LayoutFlowRate.tag=3)  then
  begin
    AValue:= FActiveWorkTable.ValueFlowRate.GetDoubleBaseNum(SpinBoxFlowRate.Value,FActiveWorkTable.ValueFlowRate.CurrentDimIndex);
    FActiveWorkTable.FlowRate.DoFlowRateSet(AValue);
    //if FActiveWorkTable.FlowRate.IsStable(StableStatus) then
    //  FActiveWorkTable.FlowRate.Start;
    UpdateUIFlowRate;
  end;
end;

procedure TFrameMainTable.SpinBoxFreqChange(Sender: TObject);
begin
  if  (LayoutPump.tag=0) or (LayoutPump.tag=3)  then
    begin
      FActiveWorkTable.ActivePump.DoFreqSet(NormalizeFloatInput(SpinBoxFreq.Text));
    end;
end;

procedure TFrameMainTable.SpinBoxFreqEnter(Sender: TObject);
begin
  LayoutPump.tag:=3;
end;

procedure TFrameMainTable.SpinBoxFreqExit(Sender: TObject);
begin
  LayoutPump.tag:=2;
end;

procedure TFrameMainTable.ButtonMonitorClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  if WorkTable.State = swtMONITOR then
    StopMonitor
  else
    StartMonitor;
end;

procedure TFrameMainTable.PopupMenuInstrumentalLayOutPopup(Sender: TObject);
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

function TFrameMainTable.GetLayoutByMenuItem(AMenuItem: TMenuItem): TLayout;
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

procedure TFrameMainTable.RebuildInstrumentalVisibleOrder;
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

procedure TFrameMainTable.Rectangle14Click(Sender: TObject);
begin
    if FActiveWorkTable.ActivePump=nil then
    begin
         ProtocolManager.AddMessage(pcWarning, psForm, 'PumpStart', 'Пользователь попробовал остановить насос', 'Активного насоса нет!');
          Exit;
    end;

  if  (LayoutPump.tag=0) or (LayoutPump.tag=3) then
    begin
      FActiveWorkTable.ActivePump.DoPumpStop ;
       UpdateUIPump;
      //FActiveWorkTable.ActivePump.State:=CONTROL_STOPPED;
    end;
end;

procedure TFrameMainTable.Rectangle15Click(Sender: TObject);
begin
 FActiveWorkTable.FlowRate.DoFlowRateStop;
 UpdateUIFlowRate;
end;

procedure TFrameMainTable.ApplyInstrumentalVisibleOrder;
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

procedure TFrameMainTable.SetInstrumentalLayoutVisible(ALayout: TLayout;
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

function TFrameMainTable.GetLayoutOrderKey(ALayout: TLayout): string;
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

function TFrameMainTable.GetLayoutByOrderKey(const AKey: string): TLayout;
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

function TFrameMainTable.GetInstrumentalVisibleOrderAsString: string;
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

procedure TFrameMainTable.UpdatePanelInstrumentsHeight;
begin
  if (FInstrumentalVisibleOrder <> nil) and (FInstrumentalVisibleOrder.Count = 0) then
    PanelInstruments.Height := 20
  else
    PanelInstruments.Height := 121;
end;

procedure TFrameMainTable.RestoreInstrumentalLayoutsByFlags(
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

procedure TFrameMainTable.MenuInstrumentalLayOutClick(Sender: TObject);
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



procedure TFrameMainTable.PopupMenuWorkTablesPopup(Sender: TObject);
var
  CanEdit: Boolean;
begin
  CanEdit := CanEditActiveWorkTable;
  if miAddTable <> nil then
    miAddTable.Enabled := CanEdit;
  if miAddDeviceChannel <> nil then
    miAddDeviceChannel.Enabled := CanEdit;
  if miAddEtalonChannel <> nil then
    miAddEtalonChannel.Enabled := CanEdit;
  if miSaveWorkTable <> nil then
    miSaveWorkTable.Enabled := CanEdit;
  if ActionAddWorkTable <> nil then
    ActionAddWorkTable.Enabled := CanEdit;
  if ActionAddDeviceChannel <> nil then
    ActionAddDeviceChannel.Enabled := CanEdit;
  if ActionAddEtalonChannel <> nil then
    ActionAddEtalonChannel.Enabled := CanEdit;
  if ActionSaveWorkTable <> nil then
    ActionSaveWorkTable.Enabled := CanEdit;
  if ActionPumpAdd <> nil then
    ActionPumpAdd.Enabled := CanEdit;
  if ActionPumpDelete <> nil then
    ActionPumpDelete.Enabled := CanEdit;
end;

procedure TFrameMainTable.UpdateGridPopupActions;
var
  CanEdit: Boolean;
  HasDeviceRow: Boolean;
  HasEtalonRow: Boolean;

  procedure UpdateColumnMenuChecks(const APrefix: string; AGrid: TGrid);
  var
    I: Integer;
    MenuItem: TMenuItem;
    Component: TComponent;
  begin
    if AGrid = nil then
      Exit;

    for I := 0 to AGrid.ColumnCount - 1 do
    begin
      Component := FindComponent('MenuItem' + APrefix + 'Column' + IntToStr(I));
      if Component is TMenuItem then
      begin
        MenuItem := TMenuItem(Component);
        MenuItem.IsChecked := AGrid.Columns[I].Visible;
        MenuItem.Enabled := CanEdit;
      end;
    end;
  end;
begin
  CanEdit := CanEditActiveWorkTable;
  HasDeviceRow := CanEdit and (FActiveWorkTable <> nil) and (GridDevices <> nil) and
    (GridDevices.Row >= 0) and (GridDevices.Row < FActiveWorkTable.DeviceChannels.Count);
  HasEtalonRow := CanEdit and (FActiveWorkTable <> nil) and (GridEtalons <> nil) and
    (GridEtalons.Row >= 0) and (GridEtalons.Row < FActiveWorkTable.EtalonChannels.Count);

  if ActionAddWorkTable <> nil then
    ActionAddWorkTable.Enabled := CanEdit;
  if ActionSaveWorkTable <> nil then
    ActionSaveWorkTable.Enabled := CanEdit;
  if ActionPumpAdd <> nil then
    ActionPumpAdd.Enabled := CanEdit;
  if ActionPumpDelete <> nil then
    ActionPumpDelete.Enabled := CanEdit;
  if ActionAddDeviceChannel <> nil then
    ActionAddDeviceChannel.Enabled := CanEdit;
  if ActionAddEtalonChannel <> nil then
    ActionAddEtalonChannel.Enabled := CanEdit;
  if ActionOpenDeviceSelect <> nil then
    ActionOpenDeviceSelect.Enabled := HasDeviceRow;
  if ActionMeterValueProperties <> nil then
    ActionMeterValueProperties.Enabled := HasDeviceRow;

  if ActionDevicesClearRow <> nil then
    ActionDevicesClearRow.Enabled := HasDeviceRow;
  if ActionDevicesCopy <> nil then
    ActionDevicesCopy.Enabled := HasDeviceRow;
  if ActionDevicesPaste <> nil then
    ActionDevicesPaste.Enabled := HasDeviceRow;
  if ActionDevicesClearAll <> nil then
    ActionDevicesClearAll.Enabled := CanEdit and (FActiveWorkTable <> nil) and
      (FActiveWorkTable.DeviceChannels.Count > 0);
  if ActionDevicesFillAllBySelected <> nil then
    ActionDevicesFillAllBySelected.Enabled := HasDeviceRow;
  if ActionDevicesFromArchive <> nil then
    ActionDevicesFromArchive.Enabled := HasDeviceRow;
  if ActionDevicesSetFlowSource <> nil then
    ActionDevicesSetFlowSource.Enabled := HasDeviceRow;
  if ActionDevicesAssignEtalon <> nil then
    ActionDevicesAssignEtalon.Enabled := HasDeviceRow and (FActiveWorkTable <> nil) and
      (FActiveWorkTable.EtalonChannels.Count > 0);
  if ActionDeleteDevice <> nil then
    ActionDeleteDevice.Enabled := HasDeviceRow;

  if ActionEtalonsClearRow <> nil then
    ActionEtalonsClearRow.Enabled := HasEtalonRow;
  if ActionEtalonsCopy <> nil then
    ActionEtalonsCopy.Enabled := HasEtalonRow;
  if ActionEtalonsPaste <> nil then
    ActionEtalonsPaste.Enabled := HasEtalonRow;
  if ActionEtalonsClearAll <> nil then
    ActionEtalonsClearAll.Enabled := CanEdit and (FActiveWorkTable <> nil) and
      (FActiveWorkTable.EtalonChannels.Count > 0);
  if ActionEtalonsFillAllBySelected <> nil then
    ActionEtalonsFillAllBySelected.Enabled := HasEtalonRow;
  if ActionEtalonsFromArchive <> nil then
    ActionEtalonsFromArchive.Enabled := HasEtalonRow;
  if ActionEtalonsSetFlowSource <> nil then
    ActionEtalonsSetFlowSource.Enabled := HasEtalonRow;
  if ActionEtalonsAssignEtalon <> nil then
    ActionEtalonsAssignEtalon.Enabled := HasEtalonRow;
  if ActionDeleteEtalons <> nil then
    ActionDeleteEtalons.Enabled := HasEtalonRow;

  UpdateColumnMenuChecks('Devices', GridDevices);
  UpdateColumnMenuChecks('Etalons', GridEtalons);
end;

procedure TFrameMainTable.PopupMenuDevicesGridPopup(Sender: TObject);
begin
  UpdateGridPopupActions;
end;

procedure TFrameMainTable.PopupMenuEtalonsGridPopup(Sender: TObject);
begin
  UpdateGridPopupActions;
end;

procedure TFrameMainTable.MenuGridLayOutClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TColumn;
  NewVisible: Boolean;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  Column := nil;
  if MenuItem.TagObject is TColumn then
    Column := TColumn(MenuItem.TagObject)
  else if (Copy(MenuItem.Name, 1, Length('MenuItemDevicesColumn')) = 'MenuItemDevicesColumn') and
    (GridDevices <> nil) and (MenuItem.Tag >= 0) and (MenuItem.Tag < GridDevices.ColumnCount) then
    Column := GridDevices.Columns[Integer(MenuItem.Tag)]
  else if (Copy(MenuItem.Name, 1, Length('MenuItemEtalonsColumn')) = 'MenuItemEtalonsColumn') and
    (GridEtalons <> nil) and (MenuItem.Tag >= 0) and (MenuItem.Tag < GridEtalons.ColumnCount) then
    Column := GridEtalons.Columns[Integer(MenuItem.Tag)];

  if Column = nil then
    Exit;

  if (FFrameProceed <> nil) and (Column = FFrameProceed.StringColumnSpillageNum) then
  begin
    MenuItem.IsChecked := False;
    FFrameProceed.StringColumnSpillageNum.Visible := False;
    Exit;
  end;

  NewVisible := not MenuItem.IsChecked;
  MenuItem.IsChecked := NewVisible;
  Column.Visible := NewVisible;

  if (FFrameProceed <> nil) and (Column = FFrameProceed.CheckColumnSpillageEnable) and
     not FFrameProceed.CheckColumnSpillageEnable.Visible then
    FFrameProceed.CheckColumnSpillageEnable.Visible := True;

  EnforceDataPointsColumnsLayout;
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.CaptureGridColumnsLayout(AGrid: TGrid;
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

procedure TFrameMainTable.Circle1Click(Sender: TObject);
begin
 GridDevices.Repaint;
end;

procedure TFrameMainTable.ApplyGridColumnsLayout(AGrid: TGrid;
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

procedure TFrameMainTable.EnforceDataPointsColumnsLayout;
begin
  if (FFrameProceed = nil) or (FFrameProceed.GridDataPoints = nil) then
    Exit;

  if FFrameProceed.CheckColumnSpillageEnable <> nil then
  begin
    FFrameProceed.CheckColumnSpillageEnable.Visible := True;
    FFrameProceed.CheckColumnSpillageEnable.Index := 0;
  end;

  if FFrameProceed.StringColumnSpillageNum <> nil then
    FFrameProceed.StringColumnSpillageNum.Visible := False;
end;

procedure TFrameMainTable.SaveLayoutSettingsToWorkTable;
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

procedure TFrameMainTable.LoadLayoutSettingsFromWorkTable;
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
  if FFrameProceed <> nil then
    ApplyGridColumnsLayout(FFrameProceed.GridDataPoints, WorkTable.DataPointsGridColumns);
  if FFrameProceed <> nil then
    ApplyGridColumnsLayout(FFrameProceed.GridResults, WorkTable.ResultsGridColumns);
  EnforceDataPointsColumnsLayout;
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
end;

procedure TFrameMainTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveLayoutSettingsToWorkTable;
 // if FWorkTableManager <> nil then
  //  FWorkTableManager.Save;


 // if DataManager <> nil then
 //   DataManager.Save;
end;

procedure TFrameMainTable.MarkChannelDeviceModified(AChannel: TChannel);
var
  RepoDevice: TDevice;
  FoundRepo: TDeviceRepository;
begin
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or (AChannel.FlowMeter.Device = nil) then
    Exit;

  AChannel.FlowMeter.Device.State := osModified;

  RepoDevice := nil;
  if DataManager <> nil then
    RepoDevice := DataManager.FindDevice(AChannel.FlowMeter.Device.UUID, FoundRepo);

  if (RepoDevice <> nil) and (RepoDevice <> AChannel.FlowMeter.Device) then
  begin
    RepoDevice.Assign(AChannel.FlowMeter.Device, True);
    RepoDevice.State := osModified;
    AChannel.FlowMeter.Device := RepoDevice;
  end;

  AChannel.FlowMeter.RebindCalculatedValues;
  PersistDeviceAsync(AChannel.FlowMeter.Device);

end;

procedure TFrameMainTable.SetDim(FlowUnitName: string; QuantityUnitName: string);
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
  if FFrameProceed <> nil then
    FFrameProceed.UpdateGridDataPointsHeaders(FActiveWorkTable.TableFlow.ValueVolume.GetDimName, FActiveWorkTable.TableFlow.ValueVolumeFlow.GetDimName);

  UpdateUIFromValues;

  LayoutFlowRate.Tag:=3;
  UpdateUIFlowRate;

  if FFrameMeasurementRun <> nil then
  FFrameMeasurementRun.UpdateUI;

  if FFrameMRResults <> nil then
    FFrameMRResults.UpdateUI;

end;

function TFrameMainTable.GetWorkTableByIndex(const AIndex: Integer): TWorkTable;
begin
  Result := nil;
  if (WorkTableManager = nil) or (WorkTableManager.WorkTables = nil) then
    Exit;

  if (AIndex < 0) or (AIndex >= WorkTableManager.WorkTables.Count) then
    Exit;

  Result := WorkTableManager.WorkTables[AIndex];
end;

function TFrameMainTable.IsManagedWorkTable(AWorkTable: TWorkTable): Boolean;
begin
  // Не разыменовываем AWorkTable: после удаления это может быть висячая ссылка.
  Result := (AWorkTable <> nil) and
    (WorkTableManager <> nil) and
    (WorkTableManager.WorkTables <> nil) and
    (WorkTableManager.WorkTables.IndexOf(AWorkTable) >= 0);
end;

function TFrameMainTable.CanEditActiveWorkTable: Boolean;
begin
  Result := FActiveWorkTable <> nil;
  if Result and (FFrameWorkTableProperties <> nil) then
    Result := FFrameWorkTableProperties.CanEditWorkTable;
end;

procedure TFrameMainTable.ApplyActiveWorkTableEditMode;
var
  CanEdit: Boolean;
begin
  CanEdit := CanEditActiveWorkTable;

  if ActionAddWorkTable <> nil then
    ActionAddWorkTable.Enabled := CanEdit;
  if ActionAddDeviceChannel <> nil then
    ActionAddDeviceChannel.Enabled := CanEdit;
  if ActionAddEtalonChannel <> nil then
    ActionAddEtalonChannel.Enabled := CanEdit;
  if ActionSaveWorkTable <> nil then
    ActionSaveWorkTable.Enabled := CanEdit;

  if TabControlWorkTables <> nil then
    if CanEdit then
      TabControlWorkTables.PopupMenu := PopupMenuWorkTables
    else
      TabControlWorkTables.PopupMenu := nil;

  if Label23 <> nil then
    Label23.PopupMenu := nil;

  if Label30 <> nil then
    Label30.PopupMenu := nil;

  if GridDevices <> nil then
  begin
    GridDevices.EditorMode := False;
    if CanEdit then
    begin
      GridDevices.PopupMenu := PopupMenuDevicesGrid;
      if StringColumnDeviceSerial1 <> nil then
        StringColumnDeviceSerial1.PopupMenu := PopupMenu1;
      GridDevices.Options := GridDevices.Options + [TGridOption.Editing];
    end
    else
    begin
      GridDevices.PopupMenu := nil;
      if StringColumnDeviceSerial1 <> nil then
        StringColumnDeviceSerial1.PopupMenu := nil;
      GridDevices.Options := GridDevices.Options - [TGridOption.Editing];
    end;
  end;

  if GridEtalons <> nil then
  begin
    GridEtalons.EditorMode := False;
    if CanEdit then
    begin
      GridEtalons.PopupMenu := PopupMenuEtalonsGrid;
      GridEtalons.Options := GridEtalons.Options + [TGridOption.Editing];
    end
    else
    begin
      GridEtalons.PopupMenu := nil;
      GridEtalons.Options := GridEtalons.Options - [TGridOption.Editing];
    end;
  end;

  if ToolBar1 <> nil then
    ToolBar1.PopupMenu := nil;

  if ToolBarEtalons1 <> nil then
    ToolBarEtalons1.PopupMenu := nil;
end;

procedure TFrameMainTable.NormalizeActiveWorkTable;
var
  NewActiveWorkTable: TWorkTable;
begin
  // После удаления рабочего стола другие формы могут ещё хранить старый указатель.
  // Перед любым доступом заменяем его на актуальный объект из менеджера или nil.
  if IsManagedWorkTable(FActiveWorkTable) then
    Exit;

  NewActiveWorkTable := nil;
  if (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil) then
  begin
    if IsManagedWorkTable(WorkTableManager.ActiveWorkTable) then
      NewActiveWorkTable := WorkTableManager.ActiveWorkTable
    else
    begin
      if WorkTableManager.WorkTables.Count > 0 then
        NewActiveWorkTable := WorkTableManager.WorkTables[0];

      // Нельзя вызывать SetActiveWorkTable, если ActiveWorkTable уже удалён:
      // сеттер сначала обращается к старому объекту и может вызвать AV.
      WorkTableManager.ActiveWorkTable := NewActiveWorkTable;
      if NewActiveWorkTable <> nil then
        NewActiveWorkTable.IsActive := True;
    end;
  end;

  FActiveWorkTable := NewActiveWorkTable;
  if FActiveWorkTable = nil then
  begin
    SetLength(FRows, 0);
    SetLength(FFlowMeterRows, 0);
  end;

  if FFrameMeasurementRun <> nil then
    FFrameMeasurementRun.ActiveWorkTable := FActiveWorkTable;
  if FFrameMRResults <> nil then
    FFrameMRResults.ActiveWorkTable := FActiveWorkTable;
end;

procedure TFrameMainTable.InitTables;
var
  TableCount: Integer;
  WorkTable: TWorkTable;
  Tab: TTabItem;
  GridEtalonsN, GridDevicesN: TGrid;
  I, LimitCount, UnitIndex, WorkTableIndex: Integer;
begin
  TableCount := 0;
  if (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil) then
    TableCount := WorkTableManager.WorkTables.Count;

  //FActiveWorkTable:=FWorkTableManager.ActiveWorkTable;
  FActiveWorkTable := GetWorkTableByIndex(0);
  for WorkTableIndex := 0 to TableCount - 1 do
  begin
    WorkTable := GetWorkTableByIndex(WorkTableIndex);
    if WorkTable = nil then
      Continue;
    WorkTable.Subscribe(Self);
    WorkTable.RebindAllFlowMeters;
  end;

  EnsureEmptyDevicesForGridRows;

  if FActiveWorkTable <> nil then
  begin
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
    RefreshPumpsCombo;
  end
  else
    RefreshPumpsCombo;

  if FFrameMeasurementRun <> nil then
    FFrameMeasurementRun.ActiveWorkTable := FActiveWorkTable;

  if FFrameMRResults <> nil then
    FFrameMRResults.ActiveWorkTable := FActiveWorkTable;

  if FFrameProtocol = nil then
  begin
    if FProtocolHostScroll = nil then
    begin
      FProtocolHostScroll := TVertScrollBox.Create(Self);
      FProtocolHostScroll.Parent := LayoutProtocolHost;
      FProtocolHostScroll.Align := TAlignLayout.Client;
      FProtocolHostScroll.Stored := False;
      FProtocolHostScroll.ShowScrollBars := True;
    end;
    FFrameProtocol := TFrameProtocol.Create(Self);
    FFrameProtocol.Parent := FProtocolHostScroll;
    FFrameProtocol.Align := TAlignLayout.Client;
  end;

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

function TFrameMainTable.FindTypeIndex(const ATypeName: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(CFlowMeterTypes) do
    if SameText(CFlowMeterTypes[I], ATypeName) then
      Exit(I);
end;

function TFrameMainTable.FindSerialIndex(const ASerialNumber: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(CFlowMeterSerials) do
    if SameText(CFlowMeterSerials[I], ASerialNumber) then
      Exit(I);
end;

function TFrameMainTable.ResolveTypeForChannel(AChannel: TChannel;
  out ARepo: TTypeRepository): TDeviceType;
var
  TypeUUID: string;
  TypeName: string;
begin
  Result := nil;
  ARepo := nil;

  if (AChannel = nil) or (DataManager = nil) then
    Exit;

  TypeUUID := Trim(AChannel.TypeUUID);
  TypeName := Trim(AChannel.TypeName);

  if (TypeUUID = '') and (AChannel.FlowMeter <> nil) then
    TypeUUID := Trim(AChannel.FlowMeter.DeviceTypeUUID);

  if (TypeName = '') and (AChannel.FlowMeter <> nil) then
    TypeName := Trim(AChannel.FlowMeter.DeviceTypeName);

  Result := DataManager.FindType(TypeUUID, TypeName, ARepo);
end;

procedure TFrameMainTable.FillDNItemsForChannel(AChannel: TChannel;
  APopupColumn: TPopupColumn);
var
  DeviceType: TDeviceType;
  Repo: TTypeRepository;
  D: TDiameter;
begin
  if APopupColumn = nil then
    Exit;

  APopupColumn.Items.BeginUpdate;
  try
    APopupColumn.Items.Clear;

    DeviceType := ResolveTypeForChannel(AChannel, Repo);
    if (DeviceType = nil) or (DeviceType.Diameters = nil) then
      Exit;

    for D in DeviceType.Diameters do
      if (D <> nil) and (Trim(D.Name) <> '') then
        APopupColumn.Items.Add(D.Name);
  finally
    APopupColumn.Items.EndUpdate;
  end;
end;

function TFrameMainTable.ApplyChannelDNChange(AChannel: TChannel;
  const ANewDN: string): Boolean;
var
  DeviceType: TDeviceType;
  Repo: TTypeRepository;
  Device: TDevice;
  NewDN: string;
  D: TDiameter;
begin
  Result := False;

  NewDN := Trim(ANewDN);
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or (NewDN = '') then
    Exit;

  Device := AChannel.FlowMeter.Device;
  if Device = nil then
    Exit;

  if SameText(Trim(Device.DN), NewDN) then
    Exit;

  DeviceType := ResolveTypeForChannel(AChannel, Repo);

  if DeviceType = nil then
  begin
    Device.DN := NewDN;
    Device.SyncNameWithModificationAndDiameter;
  end
  else
  begin
    D := DeviceType.FindDiameterByDN(NewDN);
    if D = nil then
    begin
      Device.DN := NewDN;
      Device.SyncNameWithModificationAndDiameter;
    end
    else
      Device.AttachDN(D, DeviceType);
  end;

  if AChannel.FlowMeter <> nil then
    AChannel.FlowMeter.UpdateByDevice;

  MarkChannelDeviceModified(AChannel);
  PersistDeviceAsync(Device);
  Result := True;
end;

procedure TFrameMainTable.ActionAddWorkTableExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  if (WorkTableManager = nil) or (WorkTableManager.WorkTables = nil) then
    Exit;

    WorkTableManager.AddWorkTable;

      InitTables;

  if WorkTableManager.WorkTables.Count > 0 then
    TabControlWorkTables.TabIndex := EnsureRange(
      WorkTableManager.WorkTables.Count - 1,
      0,
      Max(0, TabControlWorkTables.TabCount - 1)
    );

end;

procedure TFrameMainTable.ActionOpenDeviceEditorExecute(Sender: TObject);
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

procedure TFrameMainTable.OpenChannelDeviceEditor(AChannel: TChannel);
var
  ADevice: TDevice;
  FoundRepo: TDeviceRepository;
  SelDevice: TDevice;
  SelectFrm: TFormDeviceSelect;
  Frm: TFormDeviceEditor;
  OldDeviceUUID: string;
  DeviceSelectResult: TModalResult;
begin
  if AChannel = nil then
    Exit;

  OldDeviceUUID := Trim(AChannel.DeviceUUID);
  ADevice := nil;
  if AChannel.FlowMeter <> nil then
    ADevice := AChannel.FlowMeter.Device;

  if (ADevice = nil) and (DataManager <> nil) then
    ADevice := DataManager.FindDevice(AChannel.DeviceUUID, FoundRepo);

  if ADevice = nil then
  begin
    SelectFrm := TFormDeviceSelect.Create(Self);
    try
      DeviceSelectResult := SelectFrm.ShowModal;
      RemoveDeviceChannelsByDeletedUUIDs(SelectFrm.DeletedDeviceUUIDs);

      if DeviceSelectResult <> mrOk then
      begin
        ClearChannelsByMissingDevices;
        Exit;
      end;

      RemoveDeviceChannelsByDeletedUUIDs(SelectFrm.DeletedDeviceUUIDs);

      SelDevice := SelectFrm.GetSelectedDevice;
      if SelDevice = nil then
      begin
        ClearChannelsByMissingDevices;
        Exit;
      end;

      AChannel.FlowMeter.Init(SelDevice.UUID);

      if AChannel.FlowMeter.Device <> nil then
      begin
        AChannel.DeviceUUID := AChannel.FlowMeter.Device.UUID;
        AChannel.TypeUUID := AChannel.FlowMeter.Device.DeviceTypeUUID;
        AChannel.TypeName := AChannel.FlowMeter.Device.DeviceTypeName;
        AChannel.Serial := AChannel.FlowMeter.Device.SerialNumber;
        AChannel.Signal := AChannel.FlowMeter.Device.OutputType;

        AChannel.RepoTypeName := AChannel.FlowMeter.Device.RepoTypeName;
        AChannel.RepoTypeUUID := AChannel.FlowMeter.Device.RepoTypeUUID;
        AChannel.RepoDeviceName := AChannel.FlowMeter.Device.RepoDeviceName;
        AChannel.RepoDeviceUUID := AChannel.FlowMeter.Device.RepoDeviceUUID;

        AChannel.FlowMeter.UpdateByDevice;
      end;

      MarkChannelDeviceModified(AChannel);
      SyncChannelsWithSameDeviceUUID(AChannel, OldDeviceUUID);
      UpdateGrids;
      GridDevices.Repaint;
      ClearChannelsByMissingDevices;

    finally
      SelectFrm.Free;
    end;
    Exit;
  end;

  Frm := TFormDeviceEditor.Create(Self);
  try
    Frm.LoadDevice(ADevice);
    if Frm.ShowModal = mrOk then
    begin
      if ADevice <> nil then
      begin
        AChannel.DeviceUUID := ADevice.UUID;
        AChannel.TypeUUID := ADevice.DeviceTypeUUID;
        AChannel.TypeName := ADevice.DeviceTypeName;
        AChannel.Serial := ADevice.SerialNumber;
        AChannel.Signal := ADevice.OutputType;
        AChannel.RepoTypeName := ADevice.RepoTypeName;
        AChannel.RepoTypeUUID := ADevice.RepoTypeUUID;
        AChannel.RepoDeviceName := ADevice.RepoDeviceName;
        AChannel.RepoDeviceUUID := ADevice.RepoDeviceUUID;

        if AChannel.FlowMeter <> nil then
        begin
          AChannel.FlowMeter.Device := ADevice;
          AChannel.FlowMeter.UpdateByDevice;
        end;
      end;

      MarkChannelDeviceModified(AChannel);
      SyncChannelsWithSameDeviceUUID(AChannel, OldDeviceUUID);
    end;
  finally
    Frm.Free;
  end;

  UpdateGrids;

end;

procedure TFrameMainTable.ActionOpenDeviceSelectExecute(Sender: TObject);

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

procedure TFrameMainTable.ActionPumpAddExecute(Sender: TObject);
begin
        FActiveWorkTable.AddPump('1');
        RefreshPumpsCombo;
        UpdateUIPump;
end;

procedure TFrameMainTable.ActionPumpDeleteExecute(Sender: TObject);
begin
         if FActiveWorkTable.ActivePump=nil then
         Exit;

        FActiveWorkTable.RemovePump(FActiveWorkTable.ActivePump);
        RefreshPumpsCombo;
        UpdateUIPump;
end;

procedure TFrameMainTable.SelectDeviceForChannel(AChannel: TChannel);
var
  Frm: TFormDeviceSelect;
  SelDevice: TDevice;
  LinkedChannel: TChannel;
  I: Integer;
  SelectedUUID: string;
  OldDeviceUUID : string;
  DeviceSelectResult: TModalResult;
begin
  if AChannel = nil then
    Exit;

  OldDeviceUUID := Trim(AChannel.DeviceUUID);

  if DataManager <> nil then
    DataManager.PendingSelectedDeviceUUID := AChannel.DeviceUUID;

  Frm := TFormDeviceSelect.Create(Self);
  try
    DeviceSelectResult := Frm.ShowModal;
    RemoveDeviceChannelsByDeletedUUIDs(Frm.DeletedDeviceUUIDs);

    if DeviceSelectResult <> mrOk then
      Exit;

    RemoveDeviceChannelsByDeletedUUIDs(Frm.DeletedDeviceUUIDs);

    SelDevice := Frm.GetSelectedDevice;
    if SelDevice = nil then
      Exit;

    if AChannel.FlowMeter = nil then
      Exit;

    SelectedUUID := Trim(SelDevice.UUID);

    // Полностью переинициализируем расходомер выбранным прибором,
    // чтобы в канал попали все данные нового прибора и его типа.
    AChannel.FlowMeter.Init(SelDevice.UUID);

    if (AChannel.FlowMeter.Device = nil) or
       (not SameText(Trim(AChannel.FlowMeter.Device.UUID), Trim(SelDevice.UUID))) or
       (not SameText(Trim(AChannel.FlowMeter.Device.DeviceTypeUUID), Trim(SelDevice.DeviceTypeUUID))) then
      AChannel.FlowMeter.Device := SelDevice;

    // После Init берём данные уже из нового прибора внутри FlowMeter.
    if AChannel.FlowMeter.Device <> nil then
    begin
      AChannel.DeviceUUID := AChannel.FlowMeter.Device.UUID;
      AChannel.TypeUUID := AChannel.FlowMeter.Device.DeviceTypeUUID;
      AChannel.TypeName := AChannel.FlowMeter.Device.DeviceTypeName;
      AChannel.Serial := AChannel.FlowMeter.Device.SerialNumber;
      AChannel.Signal := AChannel.FlowMeter.Device.OutputType;

      AChannel.RepoTypeName := AChannel.FlowMeter.Device.RepoTypeName;
      AChannel.RepoTypeUUID := AChannel.FlowMeter.Device.RepoTypeUUID;
      AChannel.RepoDeviceName := AChannel.FlowMeter.Device.RepoDeviceName;
      AChannel.RepoDeviceUUID := AChannel.FlowMeter.Device.RepoDeviceUUID;

      AChannel.FlowMeter.UpdateByDevice;

      if FFrameProceed <> nil then
        FFrameProceed.AddProcessingDevice(AChannel.FlowMeter.Device);

      if (FActiveWorkTable <> nil) and (SelectedUUID <> '') then
        for I := 0 to FActiveWorkTable.DeviceChannels.Count - 1 do
        begin
          LinkedChannel := FActiveWorkTable.DeviceChannels[I];
          if (LinkedChannel = nil) or (LinkedChannel = AChannel) then
            Continue;
          if not SameText(Trim(LinkedChannel.DeviceUUID), SelectedUUID) then
            Continue;
          if LinkedChannel.FlowMeter = nil then
            Continue;

          LinkedChannel.FlowMeter.Device := AChannel.FlowMeter.Device;
          LinkedChannel.FlowMeter.UpdateByDevice;

          LinkedChannel.DeviceUUID := AChannel.DeviceUUID;
          LinkedChannel.TypeUUID := AChannel.TypeUUID;
          LinkedChannel.TypeName := AChannel.TypeName;
          LinkedChannel.Serial := AChannel.Serial;
          LinkedChannel.Signal := AChannel.Signal;
          LinkedChannel.RepoTypeName := AChannel.RepoTypeName;
          LinkedChannel.RepoTypeUUID := AChannel.RepoTypeUUID;
          LinkedChannel.RepoDeviceName := AChannel.RepoDeviceName;
          LinkedChannel.RepoDeviceUUID := AChannel.RepoDeviceUUID;

          MarkChannelDeviceModified(LinkedChannel);
        end;
    end;

    MarkChannelDeviceModified(AChannel);

    if FActiveWorkTable <> nil then
    begin
      FActiveWorkTable.RecalculateAllMeterValues;
      FActiveWorkTable.RebindAllFlowMeters;
    end;

    UpdateGrids;
  finally
    ClearChannelsByMissingDevices;
    if DataManager <> nil then
      DataManager.PendingSelectedDeviceUUID := '';
    Frm.Free;
  end;
end;

procedure TFrameMainTable.ActionAddDeviceChannelExecute(Sender: TObject);
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

procedure TFrameMainTable.ActionAddEtalonChannelExecute(Sender: TObject);
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

procedure TFrameMainTable.ActionSaveWorkTableExecute(Sender: TObject);
begin
  if WorkTableManager = nil then
    Exit;

  SaveLayoutSettingsToWorkTable;
  if DataManager <> nil then
    DataManager.Save;
  WorkTableManager.Save;
end;

procedure TFrameMainTable.ActionSessionCreatePointsExecute(Sender: TObject);
var
  SourcePoint: TDevicePoint;
  SessionPoint: TDevicePoint;
begin
  if (MeasurementRun = nil) then
    Exit;

   MeasurementRun.CreateSession;

end;

procedure TFrameMainTable.ActionMeterValuesPropertiesExecute(Sender: TObject);
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

procedure TFrameMainTable.PersistDeviceAsync(ADevice: TDevice);
var
  Repo: TDeviceRepository;
  ErrMsg: string;
begin
  if (ADevice = nil) or (DataManager = nil) then
    Exit;

  Repo := DataManager.ActiveDeviceRepo;
  if Repo = nil then
    Exit;

  if ADevice.SerialNumber = '' then
  Exit;

  TThread.CreateAnonymousThread(
    procedure
    begin
      TMonitor.Enter(Repo);
      try
        try
          Repo.SaveDevice(ADevice);
        except
          on E: Exception do
          begin
            ErrMsg := E.Message;
            //TThread.Queue(
            //  procedure
            //  begin
                ShowMessage('Ошибка сохранения прибора после смены типа: ' + ErrMsg);
           //   end
           // );
          end;
        end;
      finally
        TMonitor.Exit(Repo);
      end;
    end
  ).Start;
end;

procedure TFrameMainTable.SaveChannelToClipboard(AChannel: TChannel;
  var AClipboard: TChannelClipboardData);
begin
  FreeAndNil(AClipboard.Snapshot);
  AClipboard.HasData := AChannel <> nil;
  if AChannel = nil then
    Exit;

  AClipboard.Snapshot := TChannel.Create;
  AClipboard.Snapshot.AssignFlowMeterFrom(AChannel, nil, False);
end;

procedure TFrameMainTable.LoadChannelFromClipboard(AChannel: TChannel;
  const AClipboard: TChannelClipboardData);
begin
  if (AChannel = nil) or not AClipboard.HasData or (AClipboard.Snapshot = nil) then
    Exit;

  AChannel.AssignFlowMeterFrom(AClipboard.Snapshot, FActiveWorkTable, True);
  if FFrameProceed <> nil then
    FFrameProceed.AddProcessingDevice(AChannel.FlowMeter.Device);
  MarkChannelDeviceModified(AChannel);
end;

function TFrameMainTable.GetSelectedChannel(AChannels: TObjectList<TChannel>;
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




function TFrameMainTable.ShouldReleaseGridDeviceBeforeSave(AChannel: TChannel;
  ADevice: TDevice): Boolean;
begin
  Result := False;
  if (AChannel = nil) or (ADevice = nil) then
    Exit;

  Result := (SameText(Trim(ADevice.Comment), CEmptyGridDeviceComment) or
             (ADevice.State = osNew)) and
            (Trim(AChannel.TypeName) = '') and
            (Trim(AChannel.DeviceName) = '') and
            (Trim(AChannel.Serial) = '') and
            (Trim(ADevice.Name) = '') and
            (Trim(ADevice.DeviceTypeName) = '') and
            (Trim(ADevice.DeviceTypeUUID) = '') and
            (Trim(ADevice.SerialNumber) = '') and
            (Trim(ADevice.DN) = '') and
            ((ADevice.Points = nil) or (ADevice.Points.Count = 0)) and
            ((ADevice.Sessions = nil) or (ADevice.Sessions.Count = 0)) and
            ((ADevice.Spillages = nil) or (ADevice.Spillages.Count = 0));
end;

procedure TFrameMainTable.ReleaseEmptyGridDevicesBeforeSave;
var
  WorkTable: TWorkTable;
  Channel: TChannel;
  Device: TDevice;
  Repo: TDeviceRepository;
  DeviceUUID: string;
begin
  if (WorkTableManager = nil) or (WorkTableManager.WorkTables = nil) then
    Exit;

  for WorkTable in WorkTableManager.WorkTables do
  begin
    if (WorkTable = nil) or (WorkTable.DeviceChannels = nil) then
      Continue;

    for Channel in WorkTable.DeviceChannels do
    begin
      if Channel = nil then
        Continue;

      DeviceUUID := Trim(Channel.DeviceUUID);
      if DeviceUUID = '' then
        Continue;

      Device := nil;
      Repo := nil;
      if (Channel.FlowMeter <> nil) and (Channel.FlowMeter.Device <> nil) and
         SameText(Trim(Channel.FlowMeter.Device.UUID), DeviceUUID) then
        Device := Channel.FlowMeter.Device;

      if DataManager <> nil then
      begin
        if Device = nil then
          Device := DataManager.FindDevice(DeviceUUID, Repo)
        else
          DataManager.FindDevice(DeviceUUID, Repo);
      end;

      if not ShouldReleaseGridDeviceBeforeSave(Channel, Device) then
        Continue;

      Channel.DeviceUUID := '';
      if Channel.FlowMeter <> nil then
        Channel.FlowMeter.Device := nil;

      if (Repo <> nil) and (Device <> nil) then
        Repo.DeleteDevice(Device);
    end;
  end;
end;

procedure TFrameMainTable.EnsureEmptyDevicesForGridRows;
var
  I: Integer;
  Channel: TChannel;
  Device: TDevice;
  Repo: TDeviceRepository;
  DeviceUUID: string;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.DeviceChannels = nil) or
     (DataManager = nil) or (DataManager.ActiveDeviceRepo = nil) then
    Exit;

  for I := 0 to FActiveWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := FActiveWorkTable.DeviceChannels[I];
    if Channel = nil then
      Continue;

    DeviceUUID := Trim(Channel.DeviceUUID);
    Device := nil;
    Repo := nil;
    if DeviceUUID <> '' then
      Device := DataManager.FindDevice(DeviceUUID, Repo);

    if (DeviceUUID <> '') and (Device = nil) then
    begin
      Channel.DeviceUUID := '';
      if Channel.FlowMeter <> nil then
        Channel.FlowMeter.Device := nil;
    end;

    TDeviceCreationService.EnsureDeviceForChannel(
      Channel,
      FActiveWorkTable,
      DataManager.ActiveDeviceRepo,
      dcmGridPlaceholder
    );
  end;
end;

procedure TFrameMainTable.ClearChannelData(AChannel: TChannel; AWorkTable: TWorkTable);
var
  Device: TDevice;
  WorkTable: TWorkTable;
begin
  if AChannel = nil then
    Exit;

  Device := nil;
  if AChannel.FlowMeter <> nil then
    Device := AChannel.FlowMeter.Device;

  if FFrameProceed <> nil then
    FFrameProceed.RemoveProcessingDevice(Device);

  WorkTable := AWorkTable;
  if WorkTable = nil then
    WorkTable := FActiveWorkTable;

  AChannel.TypeName := '';
  AChannel.Serial := '';
  AChannel.Signal := -1;
  AChannel.TypeUUID := '';
  AChannel.RepoTypeName := '';
  AChannel.RepoTypeUUID := '';
  AChannel.RepoDeviceName := '';
  AChannel.RepoDeviceUUID := '';
  AChannel.DeviceUUID := '';
  if AChannel.FlowMeter <> nil then
    AChannel.FlowMeter.Device := nil;

  if (DataManager <> nil) and (DataManager.ActiveDeviceRepo <> nil) then
    TDeviceCreationService.EnsureDeviceForChannel(
      AChannel,
      WorkTable,
      DataManager.ActiveDeviceRepo,
      dcmGridPlaceholder
    );

  MarkChannelDeviceModified(AChannel);
end;

procedure TFrameMainTable.ClearChannelsByMissingDevices;
var
  I: Integer;
  Ch: TChannel;
  Repo: TDeviceRepository;
  SourceRepo: TDeviceRepository;
  DeviceUUID: string;
  RepoName: string;
  Device: TDevice;
  FoundDevice: TDevice;
  HasChanges: Boolean;
begin
  if (FActiveWorkTable = nil) or (DataManager = nil) then
    Exit;

  HasChanges := False;
  for I := 0 to FActiveWorkTable.DeviceChannels.Count - 1 do
  begin
    Ch := FActiveWorkTable.DeviceChannels[I];
    if Ch = nil then
      Continue;

    DeviceUUID := Trim(Ch.DeviceUUID);
    if DeviceUUID = '' then
      Continue;

    Device := nil;
    RepoName := Trim(Ch.RepoDeviceName);
    if RepoName <> '' then
    begin
      SourceRepo := DataManager.FindDeviceRepositoryByName(RepoName);
      if (SourceRepo <> nil) and (SourceRepo.Devices <> nil) then
      begin
        FoundDevice := nil;
        for Device in SourceRepo.Devices do
          if (Device <> nil) and (Device.State <> osDeleted) and
             SameText(Trim(Device.UUID), DeviceUUID) then
          begin
            FoundDevice := Device;
            Break;
          end;

        Device := FoundDevice;
      end;
    end;

    if Device = nil then
      Device := DataManager.FindDevice(DeviceUUID, Repo);

    if Device <> nil then
      Continue;

    ClearChannelData(Ch);
    HasChanges := True;
  end;

  if HasChanges then
    UpdateGrids;
end;

function TFrameMainTable.ChannelMatchesDeletedDevice(AChannel: TChannel;
  ADeletedUUIDs: TStrings): Boolean;
var
  DeviceUUID: string;
begin
  Result := False;

  if (AChannel = nil) or (ADeletedUUIDs = nil) then
    Exit;

  DeviceUUID := Trim(AChannel.DeviceUUID);
  if (DeviceUUID <> '') and (ADeletedUUIDs.IndexOf(DeviceUUID) >= 0) then
    Exit(True);

  if (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.Device <> nil) then
  begin
    DeviceUUID := Trim(AChannel.FlowMeter.Device.UUID);
    if (DeviceUUID <> '') and (ADeletedUUIDs.IndexOf(DeviceUUID) >= 0) then
      Exit(True);
  end;
end;

procedure TFrameMainTable.RemoveDeviceChannelsByDeletedUUIDsFromWorkTable(
  AWorkTable: TWorkTable; ADeletedUUIDs: TStrings);
var
  I: Integer;
  Channel: TChannel;
begin
  if (AWorkTable = nil) or (AWorkTable.DeviceChannels = nil) then
    Exit;

  for I := AWorkTable.DeviceChannels.Count - 1 downto 0 do
  begin
    Channel := AWorkTable.DeviceChannels[I];
    if not ChannelMatchesDeletedDevice(Channel, ADeletedUUIDs) then
      Continue;

    ClearChannelData(Channel, AWorkTable);
  end;
end;

procedure TFrameMainTable.RemoveDeviceChannelsByDeletedUUIDs(ADeletedUUIDs: TStrings);
var
  WorkTable: TWorkTable;
begin
  if (ADeletedUUIDs = nil) or (ADeletedUUIDs.Count = 0) then
    Exit;

  if WorkTableManager = nil then
    Exit;

  for WorkTable in WorkTableManager.WorkTables do
    RemoveDeviceChannelsByDeletedUUIDsFromWorkTable(WorkTable, ADeletedUUIDs);

  UpdateGrids;
end;

procedure TFrameMainTable.CopyChannelData(ASource, ADest: TChannel);
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
  if FFrameProceed <> nil then
    FFrameProceed.AddProcessingDevice(ADest.FlowMeter.Device);
  MarkChannelDeviceModified(ADest);
end;

procedure TFrameMainTable.SyncChannelsWithSameDeviceUUID(AChangedChannel: TChannel; const AOldUUID: string);
var
  I: Integer;
  Ch: TChannel;
  OldUUID: string;
begin
  if (FActiveWorkTable = nil) or (AChangedChannel = nil) then
    Exit;

  OldUUID := Trim(AOldUUID);
  if OldUUID = '' then
    Exit;

  if not SameText(OldUUID, Trim(AChangedChannel.DeviceUUID)) then
    Exit;

  for I := 0 to FActiveWorkTable.DeviceChannels.Count - 1 do
  begin
    Ch := FActiveWorkTable.DeviceChannels[I];
    if (Ch = nil) or (Ch = AChangedChannel) then
      Continue;

    if not SameText(Trim(Ch.DeviceUUID), OldUUID) then
      Continue;

    if Ch.FlowMeter <> nil then
      Ch.FlowMeter.Init(AChangedChannel.DeviceUUID);

    Ch.DeviceUUID := AChangedChannel.DeviceUUID;
    Ch.TypeUUID := AChangedChannel.TypeUUID;
    Ch.TypeName := AChangedChannel.TypeName;
    Ch.Serial := AChangedChannel.Serial;
    Ch.Signal := AChangedChannel.Signal;
    Ch.RepoTypeName := AChangedChannel.RepoTypeName;
    Ch.RepoTypeUUID := AChangedChannel.RepoTypeUUID;
    Ch.RepoDeviceName := AChangedChannel.RepoDeviceName;
    Ch.RepoDeviceUUID := AChangedChannel.RepoDeviceUUID;

    if Ch.FlowMeter <> nil then
      Ch.FlowMeter.UpdateByDevice;

    MarkChannelDeviceModified(Ch);
  end;
end;

procedure TFrameMainTable.ActionDevicesClearRowExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFrameMainTable.ActionDevicesCopyExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;
  SaveChannelToClipboard(GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices), FDeviceClipboard);
end;

procedure TFrameMainTable.ActionDevicesPasteExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  LoadChannelFromClipboard(Ch, FDeviceClipboard);
  UpdateGrids;
end;

procedure TFrameMainTable.ActionDevicesClearAllExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.DeviceChannels = nil) then
    Exit;
  for Ch in FActiveWorkTable.DeviceChannels do
    ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFrameMainTable.ActionDevicesFillAllBySelectedExecute(Sender: TObject);
var
  Src, Ch: TChannel;
  SourceType: TDeviceType;
  FoundRepo: TTypeRepository;
begin

  if (FActiveWorkTable = nil) or (FActiveWorkTable.DeviceChannels = nil) or
     (DataManager = nil) then
    Exit;

  Src := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  if Src = nil then
    Exit;

  FoundRepo := nil;
  SourceType := DataManager.FindType(Src.TypeUUID, Src.TypeName, FoundRepo);
  if SourceType = nil then
  begin
    ShowMessage('Тип выбранной строки не найден в подключенных репозиториях.');
    Exit;
  end;

  for Ch in FActiveWorkTable.DeviceChannels do
    if (Ch <> Src) and Ch.Enabled then
    begin



       If (Ch.FlowMeter.Device<>nil) and (Src.FlowMeter.Device<>nil) then
      begin
      Ch.FlowMeter.Device.Assign(Src.FlowMeter.Device, False);//  (Src.FlowMeter.Device.DN, SourceType);
      PersistDeviceAsync(Ch.FlowMeter.Device); //Сохранение прибора
      end
       else
      AttachType(Ch, SourceType, FoundRepo, True);

  //  If (Ch.FlowMeter.Device<>nil) and (Src.FlowMeter.Device<>nil) then
  //    Ch.FlowMeter.Device.AttachDN(Src.FlowMeter.Device.DN, SourceType);



      Ch.FlowMeter.RebindCalculatedValues;

    end;

  UpdateGrids;
end;

procedure TFrameMainTable.ActionDevicesFromArchiveExecute(Sender: TObject);
begin
  ActionOpenDeviceSelectExecute(Sender);
end;

procedure TFrameMainTable.ActionDevicesSetFlowSourceExecute(Sender: TObject);
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

procedure TFrameMainTable.ComboBoxPumpsChange(Sender: TObject);
begin
  if  (LayoutPump.tag=0) or (LayoutPump.tag=3) then
    begin
      LayoutPump.tag:=0;
      FActiveWorkTable.SetActivePump(ComboBoxPumps.Text);
      UpdateUIPump;
    end;
end;

procedure TFrameMainTable.ComboBoxPumpsClick(Sender: TObject);
begin
  ComboBoxPumps.Tag:=2;
end;

procedure TFrameMainTable.ComboBoxUnitsChange(Sender: TObject);
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

procedure TFrameMainTable.ActionDeleteDeviceExecute(Sender: TObject);
var
 Src: TChannel;
begin
   Src := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
   FActiveWorkTable.DeleteChannel(Src);
   UpdateGrids;
end;


procedure TFrameMainTable.ActionDeleteEtalonsExecute(Sender: TObject);
var
  Src: TChannel;
begin
   Src := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
   FActiveWorkTable.DeleteChannel(Src);
   UpdateGrids;
end;

procedure TFrameMainTable.ActionDevicesAssignEtalonExecute(Sender: TObject);
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

procedure TFrameMainTable.ActionEtalonsClearRowExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFrameMainTable.ActionEtalonsCopyExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;
  SaveChannelToClipboard(GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons), FEtalonClipboard);
end;

procedure TFrameMainTable.ActionEtalonsPasteExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  LoadChannelFromClipboard(Ch, FEtalonClipboard);
  UpdateGrids;
end;

procedure TFrameMainTable.ActionEtalonsClearAllExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.EtalonChannels = nil) then
    Exit;
  for Ch in FActiveWorkTable.EtalonChannels do
    ClearChannelData(Ch);
  UpdateGrids;
end;

procedure TFrameMainTable.ActionEtalonsFillAllBySelectedExecute(Sender: TObject);
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

procedure TFrameMainTable.ActionEtalonsFromArchiveExecute(Sender: TObject);
var
  Ch: TChannel;
begin
  if FActiveWorkTable = nil then
    Exit;
  Ch := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);
  SelectDeviceForChannel(Ch);
end;

procedure TFrameMainTable.ActionEtalonsSetFlowSourceExecute(Sender: TObject);
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

procedure TFrameMainTable.ActionEtalonsAssignEtalonExecute(Sender: TObject);
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

procedure TFrameMainTable.SetValues;
var
  WorkTable: TWorkTable;
  I: Integer;
  DeviceChannel: TChannel;
  EtalonChannel: TChannel;
begin
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;




  // Основные MeterValues рабочего стола.
   WorkTable.SetTemperature(WorkTable.FluidTemp.BeforeValue, WorkTable.FluidTemp.AfterValue);
  WorkTable.ValueTempertureBefore.SetValue(WorkTable.FluidTemp.BeforeValue);
  WorkTable.ValueTempertureAfter.SetValue(WorkTable.FluidTemp.AfterValue);

  WorkTable.ValuePressureBefore.SetValue(WorkTable.FluidPress.BeforeValue);
  WorkTable.ValuePressureAfter.SetValue(WorkTable.FluidPress.AfterValue);



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

         if DeviceChannel.ValueCurrent<>nil then
    DeviceChannel.ValueCurrent.SetValue(DeviceChannel.CurSec);
         if DeviceChannel.ValueImp<>nil then
    DeviceChannel.ValueImp.SetValue(DeviceChannel.ImpSec);
         if DeviceChannel.ValueImpTotal<>nil then
    DeviceChannel.ValueImpTotal.SetValue(DeviceChannel.ImpResult);
         if DeviceChannel.ValueInterface<>nil then
    DeviceChannel.ValueInterface.SetValue(DeviceChannel.ValueSec);
  end;

  WorkTable.RecalculateAllMeterValues;


   WorkTable.FluidTemp.Value.value:=  WorkTable.ValueTemperture.GetDoubleValue;
   WorkTable.FluidPress.Value.value:= WorkTable.ValuePressure.GetDoubleValue;
   // WorkTable.FlowRate.Flow:= WorkTable.ValueFlowRate.GetDoubleValue


  //if WorkTable.FlowRate.IsRunning then
    WorkTable.FlowRate.Value.value:= WorkTable.ValueFlowRate.GetDoubleValue;    //в value записываем в л/с а выводим в label в м3/ч
  //else
  //  WorkTable.FlowRate.Value:=0;
    {if WorkTable.ValueFlowRate <> nil then
    LabelFlowRate.Text := WorkTable.ValueFlowRate.GetStrValue
  else
    LabelFlowRate.Text := '-'; }

end;

procedure TFrameMainTable.TimerMainTimer(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  SetValues;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  IsUpdating := True;
  try
  //Grid Headers + Instrumental Labels
    UpdateUIFromValues;
    UpdateUIPump;
    UpdateUIFlowRate;
    UpdateUIConditions;
  finally
    IsUpdating := False;
  end;



  if not (WorkTable.State in [swtMONITOR, swtEXECUTE]) then
    Exit;

  IsUpdating := True;
  try
//Grids
   UpdateGrids;
  finally
   IsUpdating := False;
  end;

end;

procedure TFrameMainTable.UpdateUIFromValues;
var
  WorkTable: TWorkTable;
  I: Integer;
  MinImpValue: TMeterValue;
  RawValueBaseMultiplier: TMeterValue;
  RawQuantityBaseMultiplier: TMeterValue;

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
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  UpdateConditionsCurrentValues(WorkTable);

  if WorkTable.ValueTime <> nil then
    LabelTime.Text := FormatFloat('0', WorkTable.ValueTime.GetDoubleValue)
  else
    LabelTime.Text := '-';

  if WorkTable.CurrentPoint <> nil then
  begin
    if not EditTime.IsFocused then
      if SameValue(WorkTable.CurrentPoint.LimitTime, -1, MinDouble) or
         SameValue(WorkTable.CurrentPoint.LimitTime, 0, MinDouble)
         then
        EditTime.Text := '-'
      else
        EditTime.Text := FormatFloat('0.###', WorkTable.CurrentPoint.LimitTime);

    if not EditVolume.IsFocused then
      if SameValue(WorkTable.CurrentPoint.LimitVolume, -1, MinDouble) then
        EditVolume.Text := '-'
      else
        EditVolume.Text := FormatFloat('0.###', WorkTable.CurrentPoint.LimitVolume);

    if not EditImp.IsFocused then
      if WorkTable.CurrentPoint.LimitImp = -1 then
        EditImp.Text := '-'
      else
        EditImp.Text := IntToStr(WorkTable.CurrentPoint.LimitImp);
  end;

  if WorkTable.ValueTemperture <> nil then
    LabelTemp.Text := FormatFloat('0.###', WorkTable.ValueTemperture.GetDoubleValue)
  else
    LabelTemp.Text := FormatFloat('0.###', WorkTable.FluidTemp.Value.Value);

 { if WorkTable.ValuePressure <> nil then
    LabelPressure.Text := FormatFloat('0.###', WorkTable.ValuePressure.GetDoubleValue)
  else
    LabelPressure.Text := FormatFloat('0.###', WorkTable.Press); }
  //EditTemp.Text := FormatFloat('0.###', WorkTable.Temp);
  //EditPres.Text := FormatFloat('0.###', WorkTable.Press);

  {if WorkTable.ValueFlowRate <> nil then
    LabelFlowRate.Text := WorkTable.ValueFlowRate.GetStrValue
  else
    LabelFlowRate.Text := '-'; }



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

  if (WorkTable.CurrentPoint <> nil) and (scTime in WorkTable.CurrentPoint.StopCriteria) then
    Rectangle3.Fill.Color := $FFFEF9C3
  else
    Rectangle3.Fill.Color := TAlphaColorRec.White;

  if (WorkTable.CurrentPoint <> nil) and (scVolume in WorkTable.CurrentPoint.StopCriteria) then
    Rectangle9.Fill.Color := $FFFEF9C3
  else
    Rectangle9.Fill.Color := TAlphaColorRec.White;

  if (WorkTable.CurrentPoint <> nil) and (scImpulse in WorkTable.CurrentPoint.StopCriteria) then
    Rectangle10.Fill.Color := $FFFEF9C3
  else
    Rectangle10.Fill.Color := TAlphaColorRec.White;

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

   if RawValueBaseMultiplier <> nil then
  begin
    if RawValueBaseMultiplier.&Type = 'Импульсы'  then
     begin
      StringColumnDeviceRawValue1.Header := 'Частота, Гц';
     end
     else
     begin
    StringColumnDeviceRawValue1.Header := RawValueBaseMultiplier.GetStrFullName;
     end
  end;

    RawValueBaseMultiplier := FindFirstValueBaseMultiplier(WorkTable.EtalonChannels);


  if RawValueBaseMultiplier <> nil then
  begin
    if RawValueBaseMultiplier.&Type = 'Импульсы'  then
     begin
      StringColumnEtalonRawValue1.Header := 'Частота, Гц';
     end
     else
     begin
    StringColumnEtalonRawValue1.Header := RawValueBaseMultiplier.GetStrFullName;
     end
  end;

  RawValueBaseMultiplier := FindFirstQuantityValueBaseMultiplier(WorkTable.DeviceChannels);

  if RawValueBaseMultiplier <> nil then
  begin
    StringColumnDeviceRawSumValue1.Header := RawValueBaseMultiplier.GetStrFullName;
    StringColumnEtalonRawSumValue1.Header := RawValueBaseMultiplier.GetStrFullName;
  end;

    RawValueBaseMultiplier := FindFirstQuantityValueBaseMultiplier(WorkTable.EtalonChannels);

   if RawValueBaseMultiplier <> nil then
  begin
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



  if WorkTable.State in [swtSTARTMONITORWAIT, swtMONITOR, swtSTOPMONITOR] then
    RefreshMonitorIndicator;


end;

procedure TFrameMainTable.UpdateConditionsCurrentValues(AWorkTable: TWorkTable);
begin
  // Актуальные значения условий уже приходят через meter values
  // и выводятся непосредственно в UpdateUI.
end;

procedure TFrameMainTable.EditTempCanFocus(Sender: TObject;
  var ACanFocus: Boolean);
begin
LayoutConditions.tag:=3;
end;

procedure TFrameMainTable.EditTempExit(Sender: TObject);
var
  Value,AValue: Double;
  TempBeforeValue: Double;
  TempAfterValue: Double;
begin
  LayoutConditions.tag := 0;
  if FActiveWorkTable = nil then
    Exit;

  if TryStrToFloat(EditTemp.Text, Value) then
  begin
    AValue:= FActiveWorkTable.ValueTemperture.GetDoubleBaseNum(NormalizeFloatInput(EditTemp.text),FActiveWorkTable.ValuePressure.CurrentDimIndex);
    FActiveWorkTable.FluidTemp.DoFluidTempStart(AValue);
    UpdateUIConditions;

  end;

end;

procedure TFrameMainTable.EditTimeExit(Sender: TObject);
var
  Value: Double;
  SC: TSpillageStopCriteria;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.CurrentPoint = nil) then
    Exit;

  SC := FActiveWorkTable.CurrentPoint.StopCriteria;

  if (Trim(EditTime.Text) = '-') or
     (TryStrToFloat(EditTime.Text, Value) and SameValue(Value, -1, MinDouble)) or
     (TryStrToFloat(EditTime.Text, Value) and SameValue(Value, 0, MinDouble))
     then
  begin
    FActiveWorkTable.CurrentPoint.LimitTime := -1;
    Exclude(SC, scTime);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
    EditTime.Text:='-';
    Exit;
  end;

  if TryStrToFloat(EditTime.Text, Value) then
  begin
    FActiveWorkTable.CurrentPoint.LimitTime := Value;
    Include(SC, scTime);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
  end;
end;

procedure TFrameMainTable.EditVolumeExit(Sender: TObject);
var
  Value: Double;
  SC: TSpillageStopCriteria;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.CurrentPoint = nil) then
    Exit;

  SC := FActiveWorkTable.CurrentPoint.StopCriteria;

  if (Trim(EditVolume.Text) = '-') or
     (TryStrToFloat(EditVolume.Text, Value) and SameValue(Value, -1, MinDouble)) then
  begin
    FActiveWorkTable.CurrentPoint.LimitVolume := -1;
    Exclude(SC, scVolume);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
    Exit;
  end;

  if TryStrToFloat(EditVolume.Text, Value) then
  begin
    FActiveWorkTable.CurrentPoint.LimitVolume := Value;
    Include(SC, scVolume);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
  end;
end;

procedure TFrameMainTable.EditImpExit(Sender: TObject);
var
  Value: Integer;
  SC: TSpillageStopCriteria;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.CurrentPoint = nil) then
    Exit;

  SC := FActiveWorkTable.CurrentPoint.StopCriteria;

  if (Trim(EditImp.Text) = '-') or
     (TryStrToInt(EditImp.Text, Value) and (Value = -1)) then
  begin
    FActiveWorkTable.CurrentPoint.LimitImp := -1;
    Exclude(SC, scImpulse);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
    Exit;
  end;

  if TryStrToInt(EditImp.Text, Value) then
  begin
    FActiveWorkTable.CurrentPoint.LimitImp := Value;
    Include(SC, scImpulse);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
  end;
end;

procedure TFrameMainTable.EditPresCanFocus(Sender: TObject;
  var ACanFocus: Boolean);
begin
LayoutConditions.tag:=3;
end;

procedure TFrameMainTable.EditPresExit(Sender: TObject);
var
  Value: Double;
  AValue:double;
begin
  if FActiveWorkTable = nil then
    Exit;
    LayoutConditions.tag:=0;
  if TryStrToFloat(EditPres.Text, Value) then
  begin
    AValue:= FActiveWorkTable.ValuePressure.GetDoubleBaseNum(NormalizeFloatInput(EditPres.text),FActiveWorkTable.ValuePressure.CurrentDimIndex);
    FActiveWorkTable.FluidPress.DoFluidPressStart(AValue);
    UpdateUIConditions;
    //EditPres.Text := FormatFloat('0.###', FActiveWorkTable.Press);
  end
  //else
    //EditPres.Text := FormatFloat('0.###', FActiveWorkTable.Press);
end;

procedure TFrameMainTable.EditRepeatsExit(Sender: TObject);
begin
    //Установка кол-ва повторов.
  FActiveWorkTable.Repeats:= StrToInt(EditRepeats.Text);

end;

procedure TFrameMainTable.ApplyFlowMeterSelection(const ARow: Integer);
begin
  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  FFlowMeterRows[ARow].TypeIndex := EnsureRange(FFlowMeterRows[ARow].TypeIndex, 0, High(CFlowMeterTypes));
  FFlowMeterRows[ARow].SerialIndex := EnsureRange(FFlowMeterRows[ARow].SerialIndex, 0, High(CFlowMeterSerials));

 // FFlowMeterRows[ARow].Meter.DeviceTypeName := CFlowMeterTypes[FFlowMeterRows[ARow].TypeIndex];
 // FFlowMeterRows[ARow].Meter.SerialNumber := CFlowMeterSerials[FFlowMeterRows[ARow].SerialIndex];
end;

procedure TFrameMainTable.AttachType(AChannel: TChannel; ANewType: TDeviceType;
  AFoundRepo: TTypeRepository; const AIsTypeChanged: Boolean);
var
  RepoName: string;
  RepoUUID: string;
  Repo: TTypeRepository;
begin
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or (ANewType = nil) then
    Exit;

  if (AFoundRepo = nil) and (DataManager <> nil) then
    for Repo in DataManager.TypeRepositories do
      if (Repo <> nil) and (Repo.Types <> nil) and
         (Repo.Types.IndexOf(ANewType) >= 0) then
      begin
        AFoundRepo := Repo;
        Break;
      end;

  if AFoundRepo = nil then
    ResolveTypeForChannel(AChannel, AFoundRepo);

  if AFoundRepo <> nil then
  begin
    RepoName := AFoundRepo.Name;
    RepoUUID := AFoundRepo.UUID;
  end
  else
  begin
    RepoName := '';
    RepoUUID := '';
  end;

  AChannel.TypeName := ANewType.Name;
  AChannel.TypeUUID := ANewType.UUID;
  AChannel.RepoTypeName := RepoName;
  AChannel.RepoTypeUUID := RepoUUID;

  if not Assigned(AChannel.FlowMeter.Device) then
    Exit;

  AChannel.FlowMeter.Device.DeviceTypeUUID := ANewType.UUID;
  AChannel.FlowMeter.Device.DeviceTypeName := ANewType.Name;
  AChannel.FlowMeter.Device.RepoTypeName := RepoName;
  AChannel.FlowMeter.Device.RepoTypeUUID := RepoUUID;

  if not AIsTypeChanged then
    Exit;

  // При смене типа поверочные точки должны полностью переходить из типа в прибор.
  // Измерения (проливы/сессии) и калибровочные коэффициенты при этом не трогаем.
  AChannel.FlowMeter.Device.AttachType(ANewType, RepoName);
  MarkChannelDeviceModified(AChannel);
  PersistDeviceAsync(AChannel.FlowMeter.Device); //Сохранение прибора
end;

procedure TFrameMainTable.OpenTypeSelect(ARow: Integer; const AIsEtalon: Boolean);
var
  Frm: TFormTypeSelect;
  CurrentType, NewType: TDeviceType;
  FoundRepo: TTypeRepository;
  IsTypeChanged: Boolean;
  IsCurrentTypeDeletedInSelector: Boolean;
  Ch: TChannel;

  function FindRepoByUUID(const AUUID: string): TTypeRepository;
  var
    Repo: TTypeRepository;
  begin
    Result := nil;
    if Trim(AUUID) = '' then
      Exit;

    for Repo in DataManager.TypeRepositories do
      if (Repo <> nil) and SameText(Trim(Repo.UUID), Trim(AUUID)) then
        Exit(Repo);
  end;

  function FindRepoByName(const AName: string): TTypeRepository;
  var
    Repo: TTypeRepository;
  begin
    Result := nil;
    if Trim(AName) = '' then
      Exit;

    for Repo in DataManager.TypeRepositories do
      if (Repo <> nil) and SameText(Trim(Repo.Name), Trim(AName)) then
        Exit(Repo);
  end;

  function FindTypeInRepo(ARepo: TTypeRepository; const AUUID,
    AName: string): TDeviceType;
  begin
    Result := nil;
    if ARepo = nil then
      Exit;

    if Trim(AUUID) <> '' then
      Result := ARepo.FindTypeByUUID(Trim(AUUID));

    if (Result = nil) and (Trim(AName) <> '') then
      Result := ARepo.FindTypeByName(Trim(AName));
  end;

  function FindTypeByUUIDInAnyRepo(const AUUID: string;
    out ARepo: TTypeRepository): TDeviceType;
  var
    Repo: TTypeRepository;
  begin
    Result := nil;
    ARepo := nil;
    if Trim(AUUID) = '' then
      Exit;

    for Repo in DataManager.TypeRepositories do
    begin
      if Repo = nil then
        Continue;

      Result := Repo.FindTypeByUUID(Trim(AUUID));
      if Result <> nil then
      begin
        ARepo := Repo;
        Exit;
      end;
    end;
  end;

  function FindTypeByNameInAnyRepo(const AName: string;
    out ARepo: TTypeRepository): TDeviceType;
  var
    Repo: TTypeRepository;
  begin
    Result := nil;
    ARepo := nil;
    if Trim(AName) = '' then
      Exit;

    for Repo in DataManager.TypeRepositories do
    begin
      if Repo = nil then
        Continue;

      Result := Repo.FindTypeByName(Trim(AName));
      if Result <> nil then
      begin
        ARepo := Repo;
        Exit;
      end;
    end;
  end;

  procedure ResolveInitialTypeRepository;
  begin
    FoundRepo := FindRepoByUUID(Ch.RepoTypeUUID);

    if FoundRepo = nil then
      FoundRepo := FindRepoByName(Ch.RepoTypeName);

    if FoundRepo <> nil then
    begin
      CurrentType := FindTypeInRepo(FoundRepo, Ch.TypeUUID, Ch.TypeName);
      Exit;
    end;

    CurrentType := FindTypeByUUIDInAnyRepo(Ch.TypeUUID, FoundRepo);

    if CurrentType = nil then
      CurrentType := FindTypeByNameInAnyRepo(Ch.TypeName, FoundRepo);
  end;
begin

  if (FActiveWorkTable = nil) then
    Exit;

  if AIsEtalon then
  begin
    if (ARow < 0) or (ARow >= FActiveWorkTable.EtalonChannels.Count) then
      Exit;
  end
  else
  begin
    if (ARow < 0) or (ARow >= FActiveWorkTable.DeviceChannels.Count) then
      Exit;
  end;

  if (DataManager = nil) then
    Exit;

  if AIsEtalon then
    Ch := FActiveWorkTable.EtalonChannels[ARow]
  else
    Ch := FActiveWorkTable.DeviceChannels[ARow];
  if (Ch = nil) or (Ch.FlowMeter = nil) then
    Exit;

  CurrentType := nil;
  FoundRepo := nil;
  ResolveInitialTypeRepository;

  if FoundRepo <> nil then
    DataManager.ActiveTypeRepo := FoundRepo;

  Frm := TFormTypeSelect.Create(Self);
  try
    {----------------------------------------------------}
    { 1. Предвыбор текущего типа }
    {----------------------------------------------------}
    if FoundRepo <> nil then
      Frm.SetInitialRepository(FoundRepo);

    if (CurrentType <> nil) and (FoundRepo <> nil) then
      Frm.SelectType(CurrentType)
    else if (Ch.TypeUUID <> '') and (CurrentType = nil) then
      ShowMessage('Данный тип не найден. Загрузите репозитарий ' + Ch.RepoTypeName);

    {----------------------------------------------------}
    { 2. Открываем форму выбора }
    {----------------------------------------------------}
    if Frm.ShowModal <> mrOk then
      Exit;

    NewType := Frm.SelectedType;
    if NewType = nil then
    begin
      IsCurrentTypeDeletedInSelector := False;
      if (CurrentType <> nil) and (CurrentType.UUID <> '') then
        IsCurrentTypeDeletedInSelector :=
          FindTypeByUUIDInAnyRepo(CurrentType.UUID, FoundRepo) = nil;

      // Очищаем строку только если удалили именно текущий тип
      // в окне выбора. При простом закрытии окна без выбора
      // текущую строку не трогаем.
      if IsCurrentTypeDeletedInSelector and (not AIsEtalon) then
      begin
        GridDevices.Row := ARow;
        ActionDevicesClearRowExecute(nil);
      end;
      Exit;
    end;

    FoundRepo := Frm.SelectedRepository;
    if FoundRepo = nil then
      FindTypeByUUIDInAnyRepo(NewType.UUID, FoundRepo);

    {----------------------------------------------------}
    { 3. Проверяем смену типа }
    {----------------------------------------------------}
    IsTypeChanged := True;
    AttachType(Ch, NewType, FoundRepo, IsTypeChanged);

    {----------------------------------------------------}
    { 4. Обновляем UI }
    {----------------------------------------------------}

    FActiveWorkTable.RecalculateAllMeterValues;

    UpdateGrids;
    // SetModified;
  finally
    Frm.Free;
  end;
end;

procedure TFrameMainTable.TestButtonClick(Sender: TObject);
var
  WorkTable: TWorkTable;
  Channel: TChannel;
  Run: TMeasurementRun;
  NeedSaveResults: Boolean;
begin
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  if (TestButton.Tag = 6) and SameText(Trim(TestButton.Text), 'Сохранить?') then
  begin
    NeedSaveResults := False;
    for Channel in WorkTable.DeviceChannels do
      if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) and
         (Channel.FlowMeter.Device <> nil) and
         ((Channel.FlowMeter.Device.Spillages = nil) or
          (Channel.FlowMeter.Device.Spillages.Count = 0)) then
      begin
        NeedSaveResults := True;
        Break;
      end;

    if NeedSaveResults then
      WorkTable.SaveMeasurementResults;

    if DataManager <> nil then
      DataManager.Save;

    if WorkTableManager <> nil then
      WorkTableManager.Save;

    WorkTable.State := swtSTANDBY;
    Exit;
  end;

  Run := MeasurementRun;
  if ((Run <> nil) and not (Run.Stage in [msNone, msDone])) or
     (WorkTable.State in [swtSTARTTEST, swtSTARTWAIT, swtEXECUTE]) then
    StopTest
  else
    StartTest;
end;

procedure TFrameMainTable.Button1Click(Sender: TObject);
begin
UpdateForm;
end;

procedure TFrameMainTable.ButtonCancelClick(Sender: TObject);
begin
  if (FActiveWorkTable <> nil) then
    FActiveWorkTable.State := swtSTANDBY
  else
    OnChangeState(swtSTANDBY);
end;

procedure TFrameMainTable.GridDevicesCellClick(const Column: TColumn; const Row: Integer);
const
  SECOND_CLICK_MS = 1000; // окно "второго клика" (подбери по ощущениям)
var
  Tick: Cardinal;
  IsSecondClick: Boolean;
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  WorkTable := FActiveWorkTable;
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

    if (Column = PopupColumnDeviceDN1) then
  begin
    if WorkTable <> nil then
      FillDNItemsForChannel(WorkTable.DeviceChannels[Row], PopupColumnDeviceDN1);
    GridDevices.ReadOnly := False;
    GridDevices.EditorMode := True;
    inherited;
    Exit;
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
        OpenTypeSelect(Row, False);
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

  UpdateFlowMeterPropertiesFrame(Row);
  if (FFrameChannelProperties <> nil) and (WorkTable <> nil) and
     (Row >= 0) and (Row < WorkTable.DeviceChannels.Count) then
    FFrameChannelProperties.LoadFromChannel(WorkTable.DeviceChannels[Row]);
end;

procedure TFrameMainTable.GridDevicesHeaderClick(Column: TColumn);
var
  WorkTable: TWorkTable;
  Row: Integer;
  AllEnabled: Boolean;
  NewEnabled: Boolean;
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  if Column = CheckColumnDeviceEnable1 then
  begin

  WorkTable := GetWorkTableByIndex(0);
  if WorkTable <> nil then
  begin
    AllEnabled := WorkTable.DeviceChannels.Count > 0;
    for Row := 0 to WorkTable.DeviceChannels.Count - 1 do
      if not WorkTable.DeviceChannels[Row].Enabled then
      begin
        AllEnabled := False;
        Break;
      end;

    NewEnabled := not AllEnabled;
    for Row := 0 to WorkTable.DeviceChannels.Count - 1 do
    begin
      WorkTable.DeviceChannels[Row].Enabled := NewEnabled;
      MarkChannelDeviceModified(WorkTable.DeviceChannels[Row]);
    end;
  end
  else
  begin
    AllEnabled := Length(FFlowMeterRows) > 0;
    for Row := 0 to High(FFlowMeterRows) do
      if not FFlowMeterRows[Row].Enabled then
      begin
        AllEnabled := False;
        Break;
      end;

    NewEnabled := not AllEnabled;
    for Row := 0 to High(FFlowMeterRows) do
      FFlowMeterRows[Row].Enabled := NewEnabled;
  end;

  UpdateGridDevices;
  end;
end;

procedure TFrameMainTable.GridDevicesCellDblClick(const Column: TColumn;
  const Row: Integer);
var
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  WorkTable := FActiveWorkTable;
  if (WorkTable <> nil) and ((Row < 0) or (Row >= WorkTable.DeviceChannels.Count)) then
    Exit;

  if (WorkTable = nil) and ((Row < 0) or (Row >= Length(FFlowMeterRows))) then
    Exit;

  Rows := GridDevices.RowCount;
  GridDevices.ReadOnly := True;


    if Column = ColumnDeviceType1 then
    begin
      GridDevices.EditorMode := False;
      if WorkTable <> nil then
        OpenTypeSelect(Row, False);
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


  GridDevices.BeginUpdate;
  try
    GridDevices.RowCount := Rows;
  finally
    GridDevices.EndUpdate;
  end;

  UpdateFlowMeterPropertiesFrame(Row);
  if (FFrameChannelProperties <> nil) and (WorkTable <> nil) and
     (Row >= 0) and (Row < WorkTable.DeviceChannels.Count) then
    FFrameChannelProperties.LoadFromChannel(WorkTable.DeviceChannels[Row]);
end;

procedure TFrameMainTable.GridDevicesEditingDone(
  Sender: TObject;
  const ACol, ARow: Integer
);
var
  NextRow: Integer;
  WorkTable: TWorkTable;
  i: integer;
  CurrentValue: string;
  NewValue: string;
  DuplicateFound: boolean;
begin
  if not CanEditActiveWorkTable then
    Exit;

  WorkTable := FActiveWorkTable;

  // Проверка дубликатов только для столбца серийных номеров
  if ACol = StringColumnDeviceSerial1.Index then
  begin
    // Получаем новое значение из источника данных
    NewValue := workTable.DeviceChannels[ARow].Serial;
    DuplicateFound := False;

    // Проверяем все строки на наличие дубликата
    for i := 0 to workTable.DeviceChannels.Count - 1 do
    begin
      if i <> ARow then // Пропускаем текущую строку
      begin
        CurrentValue := workTable.DeviceChannels[i].Serial;
        // Сравниваем значения
        if (NewValue <> '') and (CurrentValue = NewValue) then
        begin
          DuplicateFound := True;
          Break;
        end;
      end;
    end;

    // Если найден дубликат - остаемся в ячейке, не очищая значение
    if DuplicateFound then
    begin
      TThread.Queue(nil,
        procedure
        begin
          // Остаемся в этой же ячейке для исправления
          GridDevices.SetFocus;
          GridDevices.SelectCell(ACol, ARow);
          TThread.ForceQueue(nil,
            procedure
            begin
              if GridDevices.Model <> nil then
                GridDevices.Model.ShowEditor;
            end
          );
        end
      );
      Exit; // Выходим, не переходим на следующую строку
    end;
  end;

  // Переход на следующую строку (только если нет дубликата)
  if ACol <> StringColumnDeviceSerial1.Index then
    Exit;

  if (WorkTable = nil) or (ARow < 0) or (ARow >= WorkTable.DeviceChannels.Count) then
    Exit;

  // Поиск следующей включенной строки. Переходить можно только на строку,
  // у которой CheckColumnDeviceEnable1=True; если дальше включенных строк нет,
  // остаемся на текущей строке и не открываем редактор на отключенной строке.
  NextRow := -1;
  for i := ARow + 1 to WorkTable.DeviceChannels.Count - 1 do
    if WorkTable.DeviceChannels[i].Enabled then
    begin
      NextRow := i;
      Break;
    end;

  if (NextRow < 0) or (NextRow >= GridDevices.RowCount) then
    Exit;

  TThread.Queue(nil,
    procedure
    begin
      GridDevices.SetFocus;
      GridDevices.SelectCell(StringColumnDeviceSerial1.Index, NextRow);
      TThread.ForceQueue(nil,
        procedure
        begin
          if GridDevices.Model <> nil then
            GridDevices.Model.ShowEditor;
        end
      );
    end
  );
end;

procedure TFrameMainTable.GridDevicesGetValue(Sender: TObject; const ACol,
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
    else if GridDevices.Columns[ACol] = PopupColumnDeviceDN1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.Device <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.Device.DN
      else
        Value := '';
    end
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
    else if GridDevices.Columns[ACol] = StringColumnDeviceCoef1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueCoef <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueCoef.GetStrValue
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
        Value := '-';
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
      Value := GetOutputTypeName(WorkTable.DeviceChannels[ARow].Signal)
    else if GridDevices.Columns[ACol] = StringColumnUUID1 then
    begin
      Value := WorkTable.DeviceChannels[ARow].DeviceUUID;
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.Device <> nil) and
         (Trim(WorkTable.DeviceChannels[ARow].FlowMeter.Device.UUID) <> '') then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.Device.UUID;
    end;


          Exit;
  end;

  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;
end;

procedure TFrameMainTable.GridDevicesSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    CanSelect := True;
    Exit;
  end;

{  UpdateFlowMeterPropertiesFrame(ARow);

  if (FFrameChannelProperties <> nil) and (FActiveWorkTable <> nil) and
     (ARow >= 0) and (ARow < FActiveWorkTable.DeviceChannels.Count) then
    FFrameChannelProperties.LoadFromChannel(FActiveWorkTable.DeviceChannels[ARow]);

    if not IsUpdating then



    if ACol = StringColumnDeviceSerial1.Index then
  begin
    GridDevices.SetFocus;
    // 2. Сбрасываем режим (иначе может не переключиться)
    GridDevices.EditorMode := False;
    GridDevices.ReadOnly:=True;
    // 3. Отложенно включаем редактор
    TThread.Queue(nil,
    procedure
    begin
      GridDevices.ReadOnly:=False;
      GridDevices.EditorMode := True;
    end);
  end;   }


end;

procedure TFrameMainTable.GridDevicesSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
var
  WorkTable: TWorkTable;
  Signal: Integer;
  Changed: Boolean;
  DeviceFieldsChanged: Boolean;
begin
  if IsUpdating then
    Exit;

  if not CanEditActiveWorkTable then
    Exit;

  WorkTable := FActiveWorkTable;
  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.DeviceChannels.Count) then
  begin
    Changed := False;
    DeviceFieldsChanged := False;

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
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.Device <> nil) then
        WorkTable.DeviceChannels[ARow].FlowMeter.Device.DeviceTypeName := Value.AsString;
      DeviceFieldsChanged := True;
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
    begin
      Changed := WorkTable.DeviceChannels[ARow].Serial <> Value.AsString;
      WorkTable.DeviceChannels[ARow].Serial := Value.AsString;
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.Device <> nil) then
        WorkTable.DeviceChannels[ARow].FlowMeter.Device.SerialNumber := Value.AsString;
      DeviceFieldsChanged := True;
    end
    else if GridDevices.Columns[ACol] = PopupColumnDeviceDN1 then
    begin
      Changed := ApplyChannelDNChange(WorkTable.DeviceChannels[ARow], Value.AsString);
      DeviceFieldsChanged := Changed;
    end
    else if GridDevices.Columns[ACol] = PopupColumnDeviceSignal1 then
      if TryGetOutputTypeFromValue(Value, Signal) then
      begin
        Changed := WorkTable.DeviceChannels[ARow].Signal <> Signal;
        WorkTable.DeviceChannels[ARow].Signal := Signal;
        if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
           (WorkTable.DeviceChannels[ARow].FlowMeter.Device <> nil) then
          WorkTable.DeviceChannels[ARow].FlowMeter.Device.OutputType := Signal;
        DeviceFieldsChanged := True;
      end;

    if Changed then
    begin
      MarkChannelDeviceModified(WorkTable.DeviceChannels[ARow]);
      if DeviceFieldsChanged then
        SyncChannelsWithSameDeviceUUID(WorkTable.DeviceChannels[ARow], WorkTable.DeviceChannels[ARow].DeviceUUID);
    end;

    Exit;
  end;

  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  GridDevices.ReadOnly := True;
end;






procedure TFrameMainTable.GridEtalonsCellClick(const Column: TColumn;
  const Row: Integer);
var
  Tick: Cardinal;
  IsSecondClick: Boolean;
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

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
    (Column = FLastClickCol);

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

  if Column = PopupColumnEtalonDN1 then
  begin
    if WorkTable <> nil then
      FillDNItemsForChannel(WorkTable.EtalonChannels[Row], PopupColumnEtalonDN1);
    GridEtalons.ReadOnly := False;
    GridEtalons.EditorMode := True;
    inherited;
    Exit;
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
        OpenTypeSelect(Row, True);
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

  if (FFrameChannelProperties <> nil) and (WorkTable <> nil) and
     (Row >= 0) and (Row < WorkTable.EtalonChannels.Count) then
    FFrameChannelProperties.LoadFromChannel(WorkTable.EtalonChannels[Row]);
end;

procedure TFrameMainTable.GridEtalonsCellDblClick(const Column: TColumn;
  const Row: Integer);
var
  Tick: Cardinal;
  IsSecondClick: Boolean;
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  WorkTable := GetWorkTableByIndex(0);

  if (WorkTable <> nil) and ((Row < 0) or (Row >= WorkTable.EtalonChannels.Count)) then
    Exit;

  if (WorkTable = nil) and ((Row < 0) or (Row >= Length(FRows))) then
    Exit;

  Rows := GridEtalons.RowCount;
  GridEtalons.ReadOnly := True;

    if Column = StringColumnEtalonType1 then
    begin
      GridEtalons.EditorMode := False;
      if WorkTable <> nil then
        OpenTypeSelect(Row, True);
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


  GridEtalons.BeginUpdate;
  try
    GridEtalons.RowCount := Rows;
  finally
    GridEtalons.EndUpdate;
  end;

end;

procedure TFrameMainTable.GridEtalonsGetValue(Sender: TObject;
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
    else if GridEtalons.Columns[ACol] = PopupColumnEtalonDN1 then
    begin
      if (WorkTable.EtalonChannels[ARow].FlowMeter <> nil) and
         (WorkTable.EtalonChannels[ARow].FlowMeter.Device <> nil) then
        Value := WorkTable.EtalonChannels[ARow].FlowMeter.Device.DN
      else
        Value := '';
    end
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

 procedure TFrameMainTable.UpdateGridDevices;
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

procedure TFrameMainTable.UpdateGrids;
var
  WT: TWorkTable;
begin
  NormalizeActiveWorkTable;
  WT := FActiveWorkTable;

  if WT <> nil then
    SoftReloadGridByGrowingRowCount(
      GridDevices,
      WT.DeviceChannels.Count,
      [ColumnDeviceType1, PopupColumnDeviceDN1, StringColumnDeviceName1,
       StringColumnDeviceSerial1, PopupColumnDeviceSignal1, StringColumnUUID1,
       StringColumnDeviceRawValue1, StringColumnDeviceRawSumValue1,
       StringColumnDeviceFlowRate1, StringColumnDeviceQuantity1,
       StringColumnDeviceCoef1, StringColumnDeviceError1]
    )
  else
    SoftReloadGridByGrowingRowCount(
      GridDevices,
      0,
      [ColumnDeviceType1, PopupColumnDeviceDN1, StringColumnDeviceName1,
       StringColumnDeviceSerial1, PopupColumnDeviceSignal1, StringColumnUUID1,
       StringColumnDeviceRawValue1, StringColumnDeviceRawSumValue1,
       StringColumnDeviceFlowRate1, StringColumnDeviceQuantity1,
       StringColumnDeviceCoef1, StringColumnDeviceError1]
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
      0,
      [StringColumnEtalonRawValue1, StringColumnEtalonRawSumValue1,
       StringColumnEtalonFlowRate1,
       StringColumnEtalonQuantity1, StringColumnEtalonError1]
    );

 // UpdateGridMesurmentRun;
end;

procedure TFrameMainTable.GridEtalonsSetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
var
  WorkTable: TWorkTable;
  Signal: Integer;
  Changed: Boolean;
begin
  if IsUpdating then
    Exit;

  if not CanEditActiveWorkTable then
    Exit;

  WorkTable := FActiveWorkTable;
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
    else if GridEtalons.Columns[ACol] = PopupColumnEtalonDN1 then
      Changed := ApplyChannelDNChange(WorkTable.EtalonChannels[ARow], Value.AsString)
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

procedure TFrameMainTable.SpeedButtonCreatePointsClick(Sender: TObject);
begin
  if FFrameMeasurementRun <> nil then
    FFrameMeasurementRun.SpeedButtonCreatePointsClick(Sender);
end;

procedure TFrameMainTable.UpdateUIPump;
var
  WorkTable: TWorkTable;
  i:integer;
begin
    WorkTable := FActiveWorkTable;

    if WorkTable = nil then
      Exit;

    if WorkTable.ActivePump = nil then
      exit;

    if WorkTable.ActivePump <> nil then
      LabelFreq.Text :=FormatFloat('0.##', WorkTable.ActivePump.Value.Value)
    else
      LabelFreq.Text := '-';

    if (WorkTable.ActivePump.Value.Value = 0) or not (WorkTable.ActivePump.IsRunning) then
       Rectangle1.Fill.Color := TAlphaColorRec.White
    else if (WorkTable.ActivePump.Value.Value < WorkTable.ActivePump.ValueSet.Value) then
      Rectangle1.Fill.Color := TAlphaColorRec.Lightyellow
    else if WorkTable.ActivePump.Value.Value = WorkTable.ActivePump.ValueSet.Value then
      Rectangle1.Fill.Color := $ffC9FFC7 ;



    if LayoutPump.tag = 3 then
      exit;

    LayoutPump.tag:=2;

   // if ((SpinBoxFreq.Text='12,00') and (WorkTable.ActivePump.FreqSet <> 0)) or
    // ((SpinBoxFreq.Text <>  '12,00') and (WorkTable.ActivePump.FreqSet = 0))  then

    SpinBoxFreq.Value:= (WorkTable.ActivePump.ValueSet.Value);
    SpinBoxFreq.Min:= WorkTable.ActivePump.Min;
    SpinBoxFreq.Max:= WorkTable.ActivePump.Max;


    if ComboBoxPumps.Count <> 0 then
      for I := ComboBoxPumps.Count-1 to 0 do
      begin
        if ComboBoxPumps.Items[i] =  WorkTable.ActivePump.Name then
        begin
          ComboBoxPumps.ItemIndex := i;
          break;
        end;
      end;

   LayoutPump.tag:=0;



end;

procedure TFrameMainTable.UpdateUIFlowRate;
var
  WorkTable: TWorkTable;
  i:integer;
  AMax,tmpMax:Double;
  StableStatus: RStableInfo;
  tmpDevice:TDevice;
begin
    WorkTable := FActiveWorkTable;
    tmpMax:=-1;
    if WorkTable = nil then
      Exit;

    //if WorkTable.FlowRate.IsRunning the

    if( WorkTable.FlowRate.Value.GetDoubleValue<=WorkTable.FlowRate.Max) and (WorkTable.FlowRate.Value.GetDoubleValue>=WorkTable.FlowRate.Min) then
      LabelFlowRate.text:=WorkTable.FlowRate.Value.GetStrValue
    else
      LabelFlowRate.Text := '-';
   // else
   //   LabelFlowRate.Text := '0';
  // if LayoutFlowRate.tag = 3 then
   // begin
      for I := 0 to FActiveWorkTable.EtalonChannels.Count-1 do
        begin
          tmpDevice:=FActiveWorkTable.EtalonChannels[i].FlowMeter.Device;
          if Assigned(tmpDevice) then
          begin
               tmpMax:=FActiveWorkTable.ValueFlowRate.GetDoubleBaseNum(tmpDevice.Qmax,4);
               if AMax<tmpMax then
                  Amax:=tmpMax;
          end;
        end;
      LayoutFlowRate.tag:=2;
      SpinBoxFlowRate.Min:=  FActiveWorkTable.ValueFlowRate.GetDoubleNum(WorkTable.FlowRate.Min);
      SpinBoxFlowRate.Max:= FActiveWorkTable.ValueFlowRate.GetDoubleNum(Amax,WorkTable.ValueFlowRate.CurrentDimIndex);
      if WorkTable.FlowRate.ValueSet.Value<>0 then
        SpinBoxFlowRate.value:=WorkTable.ValueFlowRate.GetDoubleNum(WorkTable.FlowRate.ValueSet.Value);


if WorkTable.FlowRate.IsRunning then
  begin
        if WorkTable.FlowRate.Value.Value = 0 then
           RectangleLabelFR.Fill.Color := TAlphaColorRec.White
       ELSE if WorkTable.FlowRate.IsStable(StableStatus) THEN
          RectangleLabelFR.Fill.Color := $ffC9FFC7
       else if (WorkTable.FlowRate.Value <> WorkTable.FlowRate.ValueSet) then
          RectangleLabelFR.Fill.Color := TAlphaColorRec.Lightyellow;
  end
  else
  begin

    RectangleLabelFR.Fill.Color := TAlphaColorRec.White
  end;




    LayoutFlowRate.tag:=0;
end;

procedure TFrameMainTable.UpdateUIConditions;
var
  WorkTable: TWorkTable;
  i:integer;
  ATempSet,APressSet: string;
  TempStableStatus, PressStableStatus: RStableInfo;
begin
    WorkTable := FActiveWorkTable;

    if WorkTable = nil then
      Exit;

      if Layout9.tag = 3 then
      exit;

    Layout9.tag:=2;

IF WorkTable.FluidTemp.IsRunning THEN
  begin
     if (WorkTable.FluidTemp.ValueSet.Value=0) or (WorkTable.FluidTemp.Value.Value=0) then
      Rectangle7.Fill.Color := TAlphaColorRec.White
     ELSE if WorkTable.FluidTemp.IsStable(TempStableStatus)   THEN
      Rectangle7.Fill.Color := $ffC9FFC7
     else
      Rectangle7.Fill.Color := TAlphaColorRec.Lightyellow;
  end
  else
  begin

      Rectangle7.Fill.Color := TAlphaColorRec.White

  end;

IF WorkTable.FluidPress.IsRunning THEN
  begin
   if (WorkTable.FluidPress.ValueSet.Value=0) or (WorkTable.FluidPress.Value.Value=0 )  then

    Rectangle11.Fill.Color := TAlphaColorRec.White
   else IF not(WorkTable.FluidPress.IsStable(PressStableStatus)) then
    Rectangle11.Fill.Color := TAlphaColorRec.Lightyellow
   else
    Rectangle11.Fill.Color := $ffC9FFC7;
  end
  else
  begin

    Rectangle11.Fill.Color := TAlphaColorRec.White


  end;


    APressset:= WorkTable.FluidPress.ValueSet.GetStrValue;
    ATempset:= WorkTable.FluidTemp.ValueSet.GetStrValue;

    if LayoutConditions.tag<>3 then
    begin
      if  SameValue(NormalizeFloatInput(EditTemp.Text) , NormalizeFloatInput(ATempset ), MinDouble)
      or (NormalizeFloatInput(EditTemp.Text) = 0) or (EditTemp.Text <> ATempset) then
      EditTemp.Text := WorkTable.ValueTemperture.GetStrNum(WorkTable.FluidTemp.ValueSet.Value) ;


      if  SameValue(NormalizeFloatInput(EditPres.Text) , NormalizeFloatInput(APressSet ), MinDouble)
      or (NormalizeFloatInput(EditPres.Text) = 0) or (EditPres.Text <> APressSet)  then
        EditPres.Text := WorkTable.ValuePressure.GetStrNum(WorkTable.FluidPress.ValueSet.Value);
    end;

    if( WorkTable.FluidTemp.Value.GetDoubleValue<=WorkTable.FluidTemp.Max) and (WorkTable.FluidTemp.Value.GetDoubleValue>=WorkTable.FluidTemp.Min) then
      LabelTemp.text:=WorkTable.FluidTemp.Value.GetStrValue
    else
      LabelTemp.Text := '-';

    if( WorkTable.FluidPress.Value.GetDoubleValue<=WorkTable.FluidPress.Max) and (WorkTable.FluidPress.Value.GetDoubleValue>=WorkTable.FluidPress.Min) then
      LabelPressure.text:=WorkTable.FluidPress.Value.GetStrValue
    else
      LabelPressure.Text := '-';





end;



end.
