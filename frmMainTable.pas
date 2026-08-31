unit frmMainTable;

interface

uses
  FmxHelper,
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
  FMX.SimpleChart,
  frmCalibrCoefs,
  frmChannelProperties,
  frmFlowMeterProperties,
  frmGraphsWorkspace,
  frmWorkTableProperties,
  frmMeasurementRun,
  frmMRResults,
  frmProceed,
  frmPhotoReading,
  frmProtocol,
  fuDeviceEdit,
  fuDeviceSelect,
  fuMeterValues,
  fuTypeSelect,
  System.Actions,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.IniFiles,
  System.IOUtils,
  System.Math,
  System.Rtti,
  System.StrUtils,
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
  uProjectSettings,
  uProtocols,
  uRepositories,
  uGraphsViewConfig,
  uWorkTable;

const
  CValueEditButtonWidth = 24;
  CTestPhotoReadingFile =
    'C:\Projects\FlowSericeX\FlowServiceWorkspace\FMXFP\FlowPlantFMX\' +
    'Win32\Debug\DATA\Projects\' +
    'misc-fbi-computer-hacker-wallpaper-9910681d914a8d4b36f768ffa0e176cd.jpg';

{ Рисует кнопку фотофиксации одинаково в ячейке и активном редакторе. }
procedure DrawValueEditButton(const ACanvas: TCanvas; const ARect: TRectF;
  const APressed: Boolean);


type
  TGetGridButtonVisibleEvent = procedure(Sender: TObject; const ACol,
    ARow: Integer; var AVisible: Boolean) of object;
  TValueButtonClickEvent = procedure(Sender: TObject; const ACol,
    ARow: Integer; const AText: string) of object;

  TValueEditColumn = class;

  { Нестилизованная кнопка редактора, совпадающая с кнопкой нарисованной ячейки. }
  TValueEditButton = class(TEditButton)
  private
    FPressed: Boolean;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure Paint; override;
  end;

  { Составной редактор с фиксированной кнопкой слева. }
  TValueEditCellEditor = class(TEdit)
  private
    FPhotoButton: TValueEditButton;
    FColumn: TValueEditColumn;
    FCol: Integer;
    FRow: Integer;
    procedure ButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Initialize(AColumn: TValueEditColumn; const ACol, ARow: Integer;
      const AText: string; const AShowButton: Boolean);
  end;

  { Редактируемый столбец с дополнительной кнопкой слева. }
  TValueEditColumn = class(TStringColumn)
  private
    FButtonText: string;
    FButtonWidth: Single;
    FOnGetButtonVisible: TGetGridButtonVisibleEvent;
    FOnButtonClick: TValueButtonClickEvent;
  public
    constructor Create(AOwner: TComponent); override;
    function ButtonVisible(const ACol, ARow: Integer): Boolean;
    function CreateEditor(const ACol, ARow: Integer;
      const AText: string): TValueEditCellEditor;
    procedure ClickButton(const ACol, ARow: Integer; const AText: string);
    procedure DrawButtonCell(const Canvas: TCanvas; const Bounds: TRectF;
      const ACol, ARow: Integer; const AText: string;
      const ABackground: TAlphaColor);
  published
    property ButtonText: string read FButtonText write FButtonText;
    property ButtonWidth: Single read FButtonWidth write FButtonWidth;
    property OnGetButtonVisible: TGetGridButtonVisibleEvent
      read FOnGetButtonVisible write FOnGetButtonVisible;
    property OnButtonClick: TValueButtonClickEvent
      read FOnButtonClick write FOnButtonClick;
  end;

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

  TScaleTareRequestEvent = procedure(Sender: TObject;
    const AScaleName: string) of object;

  TFlowGraphChannelKind = (fgckEtalon, fgckDevice);

  TAutoMeasurementTestResultKind = (amtrkNone, amtrkPass, amtrkFail, amtrkError, amtrkStopped);

  TAutoMeasurementTestStepRow = record
    VirtualTimeSec: Integer;
    PointText: string;
    RepeatText: string;
    StageBefore: string;
    StageAfter: string;
    WorkTableState: string;
    TargetFlow: Double;
    ActualFlow: Double;
    TargetTemp: Double;
    ActualTemp: Double;
    TargetPress: Double;
    ActualPress: Double;
    StableText: string;
    Reason: string;
    ExecutorCall: string;
    QParameter: Double;
    QSample: Double;
    SampleTimeMs: Int64;
    TimeSource: string;
    VirtualCommand: string;
    VirtualResponse: string;
    ProgressText: string;
    CheckText: string;
  end;

  TAutoMeasurementTestResultRow = record
    Num: Integer;
    Scenario: string;
    ResultText: string;
    ElapsedMs: Cardinal;
    VirtualTimeSec: Integer;
    PointCount: Integer;
    RepeatCount: Integer;
    FinalStage: string;
    FinalWorkTableState: string;
    Reason: string;
    LogFile: string;
    ResultKind: TAutoMeasurementTestResultKind;
  end;

  TFlowGraphSample = record
    TimeStampMs: Int64;
    FlowValue: Double;
    ErrorValue: Double;
    ErrorValid: Boolean;
  end;

  TFlowGraphSeries = class
  private
    FKey: string;
    FCaption: string;
    FUserVisible: Boolean;
    FChannelAvailable: Boolean;
    FGraphIndex: Integer;
    FPointColor: TAlphaColor;
    FLineColor: TAlphaColor;
    FSamples: TList<TFlowGraphSample>;
  public
    constructor Create(const AKey, ACaption: string; AColor: TAlphaColor; AVisible: Boolean);
    destructor Destroy; override;
    property Key: string read FKey;
    property Caption: string read FCaption write FCaption;
    function EffectiveVisible: Boolean;
    property UserVisible: Boolean read FUserVisible write FUserVisible;
    property ChannelAvailable: Boolean read FChannelAvailable write FChannelAvailable;
    property GraphIndex: Integer read FGraphIndex write FGraphIndex;
    property PointColor: TAlphaColor read FPointColor write FPointColor;
    property LineColor: TAlphaColor read FLineColor write FLineColor;
    property Samples: TList<TFlowGraphSample> read FSamples;
  end;

  TGraphPanelView = class
  public
    Root: TLayout;
    Header: TLayout;
    TitleLabel: TLabel;
    Chart: TSimpleChart;
    LegendHost: TLayout;
    LegendLayout: TFlowLayout;
    EmptyLabel: TLabel;
    PopupMenu: TPopupMenu;
    GraphIndex: Integer;
    constructor Create(AOwner: TComponent; AParent: TFmxObject;
      const AGraphIndex: Integer);
    destructor Destroy; override;
  end;

  TFlowGraphLimits = record
    TargetValid: Boolean;
    ToleranceValid: Boolean;
    Valid: Boolean;
    TargetLS: Double;
    LowerLS: Double;
    UpperLS: Double;
    AccuracyText: string;
    LowerPercent: Double;
    UpperPercent: Double;
  end;

  TFlowGraphHistory = class
  private
    FEtalonSeries: TObjectDictionary<string, TFlowGraphSeries>;
    FDeviceSeries: TObjectDictionary<string, TFlowGraphSeries>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property EtalonSeries: TObjectDictionary<string, TFlowGraphSeries> read FEtalonSeries;
    property DeviceSeries: TObjectDictionary<string, TFlowGraphSeries> read FDeviceSeries;
  end;

  TChannelClipboardData = record
    HasData: Boolean;
    Snapshot: TChannel;
  end;

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
    StringColumnEtalonAvgFlowRate1: TStringColumn;
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
    StringColumnDeviceAvgFlowRate1: TStringColumn;
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
    LayoutScale: TLayout;
    LineScale: TLine;
    LayoutScaleClient: TLayout;
    LayoutScaleDisplay: TLayout;
    LayoutScaleTotal: TLayout;
    RectangleScaleTotalWeight: TRectangle;
    LabelScaleWeight: TLabel;
    LayoutScaleCurrent: TLayout;
    LabelScaleTotalWeightCaption: TLabel;
    RectangleScaleWeight: TRectangle;
    LayoutScaleSelect: TLayout;
    ComboBoxScales: TComboBox;
    ButtonScaleDrain: TButton;
    ButtonScaleTare: TButton;
    LabelLayoutScale: TLabel;
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
    miScale: TMenuItem;
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
    StringColumnDeviceQuantityBefore1: TValueEditColumn;
    StringColumnDeviceQuantityAfter1: TValueEditColumn;
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
    MenuItemDevicesWorkTablesAddScale: TMenuItem;
    MenuItemDevicesWorkTablesDeleteScale: TMenuItem;
    MenuItemDevicesColumnsGroup: TMenuItem;
    MenuItemDevicesColumnsChannelGroup: TMenuItem;
    MenuItemDevicesColumnsDeviceGroup: TMenuItem;
    MenuItemDevicesColumnsMeasurementGroup: TMenuItem;
    MenuItemDevicesColumnsStatisticsGroup: TMenuItem;
    MenuItemDevicesColumnsOtherGroup: TMenuItem;
    MenuItemDevicesColumnEnable: TMenuItem;
    MenuItemDevicesColumnChannel: TMenuItem;
    MenuItemDevicesColumnSignalType: TMenuItem;
    MenuItemDevicesColumnSignal: TMenuItem;
    MenuItemDevicesColumnDeviceType: TMenuItem;
    MenuItemDevicesColumnSize: TMenuItem;
    MenuItemDevicesColumnDevice: TMenuItem;
    MenuItemDevicesColumnSerial: TMenuItem;
    MenuItemDevicesColumnFrequency: TMenuItem;
    MenuItemDevicesColumnImpulses: TMenuItem;
    MenuItemDevicesColumnFlow: TMenuItem;
    MenuItemDevicesColumnMeanFlow: TMenuItem;
    MenuItemDevicesColumnVolume: TMenuItem;
    MenuItemDevicesColumnValue: TMenuItem;
    MenuItemDevicesColumnError: TMenuItem;
    MenuItemDevicesColumnDeviation: TMenuItem;
    MenuItemDevicesColumnVolumeBefore: TMenuItem;
    MenuItemDevicesColumnVolumeAfter: TMenuItem;
    MenuItemDevicesColumnPressureDelta: TMenuItem;
    MenuItemDevicesColumnStatus: TMenuItem;
    MenuItemDevicesColumnUUID: TMenuItem;
    MenuItemDevicesColumnCoefficient: TMenuItem;
    MenuItemDevicesColumnCalculatedCoefficient: TMenuItem;
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
    MenuItemEtalonsWorkTablesAddScale: TMenuItem;
    MenuItemEtalonsWorkTablesDeleteScale: TMenuItem;
    MenuItemEtalonsColumnsGroup: TMenuItem;
    MenuItemEtalonsColumnsChannelGroup: TMenuItem;
    MenuItemEtalonsColumnsDeviceGroup: TMenuItem;
    MenuItemEtalonsColumnsMeasurementGroup: TMenuItem;
    MenuItemEtalonsColumnsStatisticsGroup: TMenuItem;
    MenuItemEtalonsColumnsOtherGroup: TMenuItem;
    MenuItemEtalonsColumnEnable: TMenuItem;
    MenuItemEtalonsColumnChannel: TMenuItem;
    MenuItemEtalonsColumnSignalType: TMenuItem;
    MenuItemEtalonsColumnSignal: TMenuItem;
    MenuItemEtalonsColumnDeviceType: TMenuItem;
    MenuItemEtalonsColumnSize: TMenuItem;
    MenuItemEtalonsColumnDevice: TMenuItem;
    MenuItemEtalonsColumnSerial: TMenuItem;
    MenuItemEtalonsColumnFrequency: TMenuItem;
    MenuItemEtalonsColumnImpulses: TMenuItem;
    MenuItemEtalonsColumnFlow: TMenuItem;
    MenuItemEtalonsColumnMeanFlow: TMenuItem;
    MenuItemEtalonsColumnVolume: TMenuItem;
    MenuItemEtalonsColumnValue: TMenuItem;
    MenuItemEtalonsColumnError: TMenuItem;
    MenuItemEtalonsColumnDeviation: TMenuItem;
    MenuItemEtalonsColumnPressureDelta: TMenuItem;
    MenuItemEtalonsColumnStatus: TMenuItem;
    MenuItemDevicesClearRow: TMenuItem;
    MenuItemDevicesCopy: TMenuItem;
    MenuItemDevicesPaste: TMenuItem;
    MenuItemDevicesSep1: TMenuItem;
    MenuItemDevicesFillAllBySelected: TMenuItem;
    MenuItemDevicesOtherGroup: TMenuItem;
    MenuItemDevicesSetFlowSource: TMenuItem;
    MenuItemDevicesAssignEtalon: TMenuItem;
    PopupMenuEtalonsGrid: TPopupMenu;
    MenuItemEtalonsClearRow: TMenuItem;
    MenuItemEtalonsCopy: TMenuItem;
    MenuItemEtalonsPaste: TMenuItem;
    MenuItemEtalonsSep1: TMenuItem;
    MenuItemEtalonsFillAllBySelected: TMenuItem;
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
    StringColumnDeviceCalculatedCoef1: TStringColumn;
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
    ActionScaleAdd: TAction;
    ActionScaleDelete: TAction;
    MenuItemAddScale: TMenuItem;
    MenuItemDeleteScale: TMenuItem;
    StyleBook1: TStyleBook;
    PanelControlWorkTables: TPanel;
    TabItemWorkTable1: TTabItem;
    TabItemWorkTableGraphs: TTabItem;
    LayoutGraphsClient: TLayout;
    LayoutEtalonGraphSection: TLayout;
    LayoutEtalonChart: TLayout;
    ChartEtalonFlow: TSimpleChart;
    SplitterFlowGraphs: TSplitter;
    LayoutDeviceGraphSection: TLayout;
    LayoutDeviceChart: TLayout;
    ChartDeviceFlow: TSimpleChart;
    LayoutGraphCommands: TLayout;
    ButtonClearFlowGraphs: TButton;
    Label3: TLabel;
    SpeedButton7: TSpeedButton;
    LabelScaleTotalWeight: TLabel;
    PopupMenuFlowChart: TPopupMenu;
    MenuItemFlowChartSettings: TMenuItem;
    MenuItemFlowChartLineMode: TMenuItem;
    MenuItemFlowChartLinePchip: TMenuItem;
    MenuItemFlowChartLineSegments: TMenuItem;
    MenuItemFlowChartValueMode: TMenuItem;
    MenuItemFlowChartValueFlow: TMenuItem;
    MenuItemFlowChartValueError: TMenuItem;
    MenuItemFlowChartScale: TMenuItem;
    MenuItemFlowChartScaleLog: TMenuItem;
    MenuItemFlowChartScaleLinear: TMenuItem;
    MenuItemFlowChartSeries: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure GridEtalonsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridEtalonsDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure GridEtalonsSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridEtalonsCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDevicesGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridDevicesDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure GridDevicesCreateCustomEditor(Sender: TObject;
      const Column: TColumn; var Control: TStyledControl);
    procedure GridDevicesSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridDevicesCellClick(const Column: TColumn; const Row: Integer);
    procedure DeviceReadingButtonVisible(Sender: TObject; const ACol,
      ARow: Integer; var AVisible: Boolean);
    procedure DeviceReadingButtonClick(Sender: TObject; const ACol,
      ARow: Integer; const AText: string);
    procedure BeginDeviceReadingEdit(const ACol, ARow: Integer);
    function ResolveReadingPhotoPath(const AStoredPath: string): string;
    function StorePendingReadingPhoto(const ASourcePath,
      APreviousStoredPath: string): string;
    procedure GridDevicesEnter(Sender: TObject);
    procedure GridEtalonsEnter(Sender: TObject);
    procedure ActivateMeasurementGrid(AGrid: TGrid);
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
    procedure DevicesColumnMenuItemClick(Sender: TObject);
    procedure EtalonsColumnMenuItemClick(Sender: TObject);
    procedure PopupMenuGridDataPointsPopup(Sender: TObject);
    procedure PopupMenuGridResultsPopup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Circle1Click(Sender: TObject);
    procedure ButtonMonitorClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    function GetPointResultError(const ADevice: TDevice; const APoint: TDevicePoint): Double;
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
    procedure ComboBoxScalesChange(Sender: TObject);
    procedure ButtonScaleTareClick(Sender: TObject);
    procedure ButtonScaleDrainClick(Sender: TObject);
    procedure Rectangle14Click(Sender: TObject);
    procedure UpdateUIPump;
    procedure UpdateUIScale;
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
    procedure ActionScaleAddExecute(Sender: TObject);
    procedure ActionScaleDeleteExecute(Sender: TObject);
    procedure SpinBoxFreqExit(Sender: TObject);
    procedure SpinBoxFreqEnter(Sender: TObject);
    procedure GridDevicesEditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure Button1Click(Sender: TObject);
    procedure UpdateForm;

  private

    FActiveWorkTable: TWorkTable;
    FNewInstrumentName: string;

    FFlowGraphHistory: TFlowGraphHistory;
    FLastFlowGraphSampleMs: Int64;
    FFlowGraphWorkTable: TWorkTable;
    FFlowGraphXMin: Int64;
    FFlowGraphXMax: Int64;
    FCurrentGraphPointUUID: string;
    FCurrentGraphPointIndex: Integer;
    FCurrentGraphPointKey: string;
    FCurrentGraphPointStartMs: Int64;
    FGraphMonitorStartMs: Int64;
    FMeasurementRunInstance: TMeasurementRun;
    FGraphChannelsReady: Boolean;
    FGraphSamplingActive: Boolean;
    FLastGraphRunActive: Boolean;
    FLastFlowGraphLimits: TFlowGraphLimits;
    FGraphsViewConfig: TGraphsViewConfig;
    FGraphsWorkspace: TFrameGraphsWorkspace;
    FGraphsRoot: TLayout;
    FGraphsSettings: TPanel;
    FGraphsSettingsContent: TVertScrollBox;
    FGraphsSettingsWidth: Single;
    FGraphCountCombo: TComboBox;
    FGraphLayoutCombo: TComboBox;
    FGraphLegendCheck: TCheckBox;
    FSelectedGraphLegend: TFlowLayout;
    FGraphSettingsToggle: TButton;
    FGraphViews: TObjectList<TGraphPanelView>;
    FGraphSplitters: TObjectList<TSplitter>;
    FGraphLayoutContainers: TObjectList<TLayout>;
    FSelectedGraphIndex: Integer;
    FUpdatingGraphsSettings: Boolean;
    FInitializingGraphs: Boolean;
    FRenderingGraphViews: Boolean;
    FGraphRenderQueued: Boolean;
    FGraphRenderTimer: TTimer;
    FDestroying: Boolean;
  FFrameMeasurementRun: TFrameMeasurementRun;
  FFrameMRResults: TFrameMRResults;
  FFrameProtocol: TFrameProtocol;
  FFrameFlowMeterProperties: TFrameFlowMeterProperties;
  FFlowMeterPropertiesChannel: TChannel;
  FFrameChannelProperties: TFrameChannelProperties;
  FFrameWorkTableProperties: TFrameWorkTableProperties;
    { Private declarations }
  FLastClickRow: Integer;
  FLastClickCol: TColumn;
  FLastClickTick: Cardinal;
  FLastPopupGrid: TGrid;
  FRefreshingGridColumns: Boolean;
  FChangingMeasurementGridFocus: Boolean;
  FChangingWorkTableTab: Boolean;
  FDeletingWorkTable: Boolean;
  FDeletingWorkTablePointer: Pointer;
  FWorkTableDeleteGeneration: Integer;
  FSyncingWorkTableTabs: Boolean;
  FWorkTableTabs: TDictionary<string, TTabItem>;

  FRows: array of TRowData;
  IsUpdating: Boolean;
  FUpdatingChannelEnabled: Boolean;
  FUpdatingAutoSwitch: Boolean;
  FLastAutoStatusText: string;
  FLastMeasurementMainButtonAction: string;
  FLastUiDataLogTick: UInt64;
  FLastUiTimeText: string;
  FAutoTestTab: TTabItem;
  FAutoTestInfoLabel: TLabel;
  ComboBoxAutoTestScenario: TComboBox;
  ButtonRunAutoTestScenario: TButton;
  ButtonRunAllAutoTestScenarios: TButton;
  ButtonStopAutoTestScenario: TButton;
  ButtonAutoTestStep: TButton;
  ButtonAutoTestContinueToStage: TButton;
  FAutoTestStatusLabel: TLabel;
  GridAutoTestNumbers: TGrid;
  GridAutoTestResults: TGrid;
  FAutoTestStepRows: TArray<TAutoMeasurementTestStepRow>;
  FAutoTestResultRows: TArray<TAutoMeasurementTestResultRow>;
  FAutoTestRunning: Boolean;
  FAutoTestStopRequested: Boolean;
  FAutoTestRealCommandsBlocked: Boolean;

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
    function CanDeleteActiveWorkTable: Boolean;
    procedure UpdateDeleteWorkTableButton;
    procedure DeleteActiveWorkTableClick(Sender: TObject);
    function GetNewInstrumentName: string;
    procedure ClearChannelSimulationValues(AChannel: TChannel);
    procedure DisableOtherChannelGroups(AChannels: TObjectList<TChannel>; const AActiveIndex: Integer);
    procedure ApplyEnabledChannelSimulationValues(AWorkTable: TWorkTable; const AEtalonChannels: Boolean);
    // Определяет явный режим симуляции для гидравлических действий стола.
    function IsHydraulicSimulationMode(AWorkTable: TWorkTable): Boolean;
    procedure CompleteSimulatedHydraulicConfiguration(AWorkTable: TWorkTable);
    procedure CompleteSimulatedHydraulicLineSetup(AWorkTable: TWorkTable);
    // Сбрасывает устаревшую ссылку FActiveWorkTable после удаления рабочего стола.
    procedure NormalizeActiveWorkTable;
    procedure TabControlWorkTablesChange(Sender: TObject);
    procedure UpdateGridDevices;
    procedure ChannelMoveRequested(Sender: TObject; AChannel: TChannel;
      const AMoveUp: Boolean);
    procedure ToggleAllChannelRows(AGrid: TGrid;
      AChannels: TObjectList<TChannel>; const AEtalonChannels: Boolean);
    procedure ToggleAllDeviceChannels;
    procedure ToggleAllEtalonChannels;
    procedure EnsureEmptyDevicesForGridRows;
    function ShouldReleaseGridDeviceBeforeSave(AChannel: TChannel; ADevice: TDevice): Boolean;
    function GetEtalonGroupColor(const AGroup: Integer): TAlphaColor;
    function GetDeviceGroupColor(const AGroup: Integer): TAlphaColor;
    function GetDisplayFlowText(AFlowMeter: TFlowMeter; AWorkTable: TWorkTable): string;

    procedure RefreshFlowGraphChannels(const AReason: string = 'Unspecified');
    procedure AddFlowGraphSamples(const ATimeStampMs: Int64);
    procedure RenderFlowGraphs;
    procedure EnsureFlowGraphDictionaries;
    procedure UpdateEtalonFlowChart;
    procedure UpdateDeviceFlowChart;
    procedure RenderFlowChart(AChart: TSimpleChart; AGraphSeries: TObjectDictionary<string, TFlowGraphSeries>; const ATitle: string; const AVisibleXMinMs, AVisibleXMaxMs: Int64; const AAxisMinSec, AAxisMaxSec: Double; AMeasurementSegment: Boolean);
    procedure AddFlowLimitSeries(AChart: TSimpleChart; const ALimits: TFlowGraphLimits; const AAxisMinSec, AAxisMaxSec: Double; const AValueMode: TGraphValueMode);
    procedure ApplyFlowChartSeriesStyle(const ASeries: TChartSeries; const AColor: TAlphaColor; const AThickness: Single; const AShowMarkers: Boolean);
    procedure FlowGraphCheckBoxChange(Sender: TObject);
    function TryGetCurrentPointGraphTarget(out ATargetLS: Double): Boolean;
    function TryGetCurrentPointGraphTolerance(out ALowerLS: Double; out AUpperLS: Double): Boolean;
    function TryGetCurrentPointGraphLimits(out ATargetLS: Double; out ALowerLS: Double; out AUpperLS: Double): Boolean;
    function TryGetFlowGraphLimits(out ALimits: TFlowGraphLimits): Boolean;
    function IsFlowGraphSamplingActive(AWorkTable: TWorkTable): Boolean;
    function BuildFlowGraphChannelKey(AKind: TFlowGraphChannelKind; AWorkTable: TWorkTable; AChannel: TChannel; AChannelIndex: Integer): string;
    function BuildFlowGraphSeriesKey(const AKind: string; AWorkTable: TWorkTable; AChannel: TChannel; AChannelIndex: Integer): string;
    function BuildFlowGraphCaption(AChannel: TChannel; AChannelIndex: Integer; const AFallbackPrefix: string): string;
    function IsValidFlowGraphChannel(AChannel: TChannel): Boolean;
    function FlowToCurrentDimension(const AFlowLS: Double): Double;
    function FlowGraphDisplayValue(AWorkTable: TWorkTable; const ABaseFlowLS: Double): Double;
    function FlowGraphSamplesCount(ADict: TObjectDictionary<string, TFlowGraphSeries>): Integer;
    procedure SetFlowChartYAxis(AChart: TSimpleChart; const AYMin, AYMax: Double);
    procedure ButtonClearFlowGraphsClick(Sender: TObject);
    procedure GraphSettingsToggleClick(Sender: TObject);
    procedure GraphCountChange(Sender: TObject);
    procedure GraphLayoutChange(Sender: TObject);
    procedure GraphLegendChange(Sender: TObject);
    procedure ResetGraphSettingsClick(Sender: TObject);
    procedure ApplyGraphsLayout;
    procedure EnsureGraphViewCount(const ACount: Integer);
    procedure ClearGraphsLayout;
    procedure DetachGraphViewEvents;
    procedure RenderGraphViews;
    procedure QueueRenderGraphViews;
    procedure GraphRenderTimerTimer(Sender: TObject);
    procedure RenderConfiguredGraph(AView: TGraphPanelView);
    procedure GraphViewClick(Sender: TObject);
    procedure GraphPopupMenuPopup(Sender: TObject);
    // Открывает штатное ПКМ видимого графика после обновления динамической ветки.
    procedure FlowChartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    // Назначает одно меню из .fmx обоим видимым графикам рабочего стола.
    procedure InitializeVisibleGraphPopupMenus;
    // Формирует только динамическую ветку серий штатного меню из .fmx.
    procedure RebuildVisibleFlowChartMenu(const AGraphIndex: Integer);
    procedure SyncGraphsSettingsControls;
    procedure RebuildGraphPopupMenu(APopupMenu: TPopupMenu;
      const AGraphIndex: Integer);
    procedure RebuildSelectedGraphLegend;
    procedure GraphMenuClick(Sender: TObject);
    procedure BuildGraphsSettingsPanel;
    function ResolveGraphSeriesMeterValue(
      const ASeries: TGraphSeriesConfig): TMeterValue;

    procedure UpdateUIFromValues;
    procedure SetValues;
    function ResolveTypeForChannel(AChannel: TChannel; out ARepo: TTypeRepository): TDeviceType;
    procedure FillDNItemsForChannel(AChannel: TChannel; APopupColumn: TPopupColumn);
    function ApplyChannelDNChange(AChannel: TChannel; const ANewDN: string): Boolean;
    procedure ApplyActiveWorkTableEditMode;
    procedure UpdateGridPopupActions;
    procedure CaptureGridColumnsLayout(AGrid: TGrid; out AColumns: TArray<TGridColumnLayout>);
    procedure ApplyGridColumnsLayout(AGrid: TGrid; const AColumns: TArray<TGridColumnLayout>);
    procedure RefreshGridColumns(AGrid: TGrid);
    function NormalizeColumnCaption(const ACaption: string): string;
    function FindGridColumnByName(AGrid: TGrid;
      const AColumnName: string): TColumn;
    function FindGridColumnForMenuItem(AGrid: TGrid;
      AMenuItem: TMenuItem): TColumn;
    procedure SyncColumnMenuBranch(AParentItem: TMenuItem; AGrid: TGrid);
    procedure SyncDevicesColumnsMenu;
    procedure SyncEtalonsColumnsMenu;
    procedure EnforceDataPointsColumnsLayout;
    procedure MarkChannelDeviceModified(AChannel: TChannel);
    procedure PersistChannelEnabled(AWorkTable: TWorkTable; AChannel: TChannel; const AKind: string; const AOldEnabled, ANewEnabled: Boolean);
    procedure ApplyMonitorIndicatorColor(const AColor: TAlphaColor);
    procedure RefreshMonitorIndicator;
    procedure RefreshPumpsCombo;
    procedure ResetUIPump;
    procedure RefreshScalesCombo;
    procedure UpdateConditionsCurrentValues(AWorkTable: TWorkTable);
    procedure AttachType(AChannel: TChannel; ANewType: TDeviceType;
      AFoundRepo: TTypeRepository; const AIsTypeChanged: Boolean);

    procedure SetConfiguration;
    procedure StartMonitor;
    procedure StopMonitor;
    procedure StartMeasurement;
    procedure StopMeasurement;
    procedure ApplyMeasurementModeFromSwitch;
    procedure BuildManualMeasurementPoint;
    procedure UpdatePreparedManualPoint;
    procedure RefreshMeasurementRunFrame;
    procedure UpdateTestButton;
    procedure UpdateMeasurementStartStopButton(const AReason: string = 'Refresh');
    procedure MeasurementRunUiChanged(Sender: TObject);
    procedure MeasurementButtonClickManualMode;
    procedure MeasurementButtonClickAutoMode;
    function IsTestButtonSaveMode: Boolean;
    function IsMeasurementActive(AWorkTable: TWorkTable): Boolean;
    function NeedSaveMeasurementResults(AWorkTable: TWorkTable): Boolean;
    procedure AcceptMeasurementResults;

    procedure InitializeAutoMeasurementTestTab;
    procedure RefreshAutoMeasurementTestContext;
    procedure InitializeAutoTestScenarioList;
    procedure AutoTestButtonRunClick(Sender: TObject);
    procedure AutoTestButtonRunAllClick(Sender: TObject);
    procedure AutoTestButtonStopClick(Sender: TObject);
    procedure AutoTestButtonStepClick(Sender: TObject);
    procedure AutoTestButtonContinueClick(Sender: TObject);
    procedure GridAutoTestNumbersGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridAutoTestResultsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure RunAutoMeasurementScenario(const AScenarioIndex: Integer);
    procedure RunAllAutoMeasurementScenarios;

    procedure UpdateGrids;


    procedure ClearChannelData(AChannel: TChannel; AWorkTable: TWorkTable = nil);
    procedure ClearChannelsByMissingDevices;
    procedure RemoveDeviceChannelsByDeletedUUIDs(ADeletedUUIDs: TStrings);
    procedure RemoveDeviceChannelsByDeletedUUIDsFromWorkTable(
      AWorkTable: TWorkTable; ADeletedUUIDs: TStrings);
    function ChannelMatchesDeletedDevice(AChannel: TChannel; ADeletedUUIDs: TStrings): Boolean;
    procedure CopyChannelData(ASource, ADest: TChannel);
    procedure CloneSelectedChannelDevice(ASource, ADest: TChannel);
    procedure SyncChannelsWithSameDeviceUUID(AChangedChannel: TChannel; const AOldUUID: string);
    function GetSelectedChannel(AChannels: TObjectList<TChannel>; AGrid: TGrid): TChannel;



  private
    FInitialized: Boolean;
    FStabilitySampleTimer: TTimer;
    FChange: string ;
    FInstrumentalVisibleOrder: TList<TLayout>;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
    FOnWorkTableCommand: TWorkTableCommandEvent;
    FOnScaleTareRequest: TScaleTareRequestEvent;
    FDeviceClipboard: TChannelClipboardData;
    FEtalonClipboard: TChannelClipboardData;
    function GetLayoutByMenuItem(AMenuItem: TMenuItem): TLayout;
    procedure StabilitySampleTimerTimer(Sender: TObject);
    procedure RebuildInstrumentalVisibleOrder;
    procedure ApplyInstrumentalVisibleOrder;
    procedure SetInstrumentalLayoutVisible(ALayout: TLayout; AVisible: Boolean);
    function GetLayoutOrderKey(ALayout: TLayout): string;
    function GetLayoutByOrderKey(const AKey: string): TLayout;
    function GetInstrumentalVisibleOrderAsString: string;
    procedure RestoreInstrumentalLayoutsByFlags(const AFlowRateVisible, APumpVisible,
      AMainVisible, AMesureVisible, AConditionsVisible, AProceduresVisible: Boolean;
      const AOrder: string = '');
  protected
    procedure BeforeDestruction; override;
  public
    procedure AttachGraphsTo(AParent: TFmxObject);
    procedure ConnectResultsProcessing(AProceed: TFrameProceed);
    procedure RefreshSynchronizedResults(Sender: TObject);
    { Public declarations }
    procedure Initialize;
    { Prepares child frames before application services release their managers. }
    procedure PrepareForShutdown;
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
    procedure Splitter1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure SaveActiveWorkTableConfiguration;
    procedure ReleaseEmptyGridDevicesBeforeSave;
    // Вкладки связываются с рабочими столами только по UUID в TagString.
    procedure SyncWorkTableTabs;
    procedure ActivateWorkTableFromTab(ATab: TTabItem);
    procedure ActivateWorkTable(AWorkTable: TWorkTable);
    function GetWorkTableTabUUID(ATab: TTabItem): string;
    function ResolveWorkTableForTab(ATab: TTabItem): TWorkTable;
    function EnsureWorkTableTab(AWorkTable: TWorkTable): TTabItem;
    function IsLiveWorkTableTab(ATab: TTabItem): Boolean;
    function IsControlInsideTab(AControl: TFmxObject;
      ATab: TTabItem): Boolean;
    procedure RemoveWorkTableTabs(const ATabs: TList<TTabItem>);
    function FindManagedWorkTableByUUID(const AUUID: string): TWorkTable;
    function FindWorkTableTabByUUID(
      const AWorkTableUUID: string): TTabItem;
    function FindWorkTableByTab(ATab: TTabItem): TWorkTable;
    { Возвращает управляемый рабочий стол, связанный с активной
      вкладкой по UUID из TagString. }
    function ActiveTabWorkTable: TWorkTable;
    procedure SelectWorkTable(AWorkTable: TWorkTable);
    procedure UpdateWorkTableTabCaption(AWorkTable: TWorkTable);
    property NewInstrumentName: string read FNewInstrumentName write FNewInstrumentName;
    property OnWorkTableCommand: TWorkTableCommandEvent read FOnWorkTableCommand write FOnWorkTableCommand;
    property OnScaleTareRequest: TScaleTareRequestEvent
      read FOnScaleTareRequest write FOnScaleTareRequest;
  private
    procedure SaveChannelToClipboard(AChannel: TChannel; var AClipboard: TChannelClipboardData);
    procedure LoadChannelFromClipboard(AChannel: TChannel; const AClipboard: TChannelClipboardData);
    procedure PersistDeviceAsync(ADevice: TDevice);
    procedure UpdateUIConditions;
    function   GetMeasurementRun: TMeasurementRun;
    procedure UpdateFlowMeterPropertiesFrame(ARow: Integer = -1; AEtalon: Boolean = False);
    procedure FlowMeterPropertiesChanged(Sender: TObject);
    procedure RefreshActiveWorkTableViews(AChannel: TChannel = nil; ASyncFromFlowMeter: Boolean = False);
    procedure UpdateScaleWeightFromFlow(AWorkTable: TWorkTable);
    function TryGetAverageFlow(AFlowMeter: TFlowMeter; AWorkTable: TWorkTable;
      out AAverageFlow: Double): Boolean;
    function GetAverageFlowText(AFlowMeter: TFlowMeter; AWorkTable: TWorkTable): string;
    function CalculateCurrentDeviationPercent(const ACurrentValue,
      AMeanValue: Double): Double;
    { Returns the common coefficient representation for the whole grid.
      Mixed representations are displayed as the base imp/l representation. }
    function GetGridCoefficientDimensionCoef(AWorkTable: TWorkTable): Integer;
    function GetCoefficientUnit(ADimensionCoef: Integer): string;
    { Updates both coefficient column headers for the whole grid. }
    procedure UpdateDeviceCoefficientHeaders;
    { Returns the passport coefficient in the common grid representation. }
    function GetDeviceCoefficientText(AChannel: TChannel): string;
    { Returns the conversion coefficient that would give zero error for the
      current pulse count and the reference quantity. }
    function GetCalculatedDeviceCoefficientText(AChannel: TChannel;
      AWorkTable: TWorkTable): string;
    function GetErrorCellColor(AChannel: TChannel; const AText: string; out AColor: TAlphaColor): Boolean;

    property  MeasurementRun:TMeasurementRun read GetMeasurementRun;

  end;



implementation

uses
  fuTable_Main;

const
  CurrentDeviationEpsilon = 1E-12;
  GraphSampleIntervalMs = 1000;
  GraphVisibleWindowSec = 60.0;
  GraphVisibleWindowMs = 60000;
  MaxGraphSampleCountPerSeries = 3600;
  FLOW_GRAPH_COLORS: array[0..11] of TAlphaColor = (
    $FF2196F3,
    $FFF44336,
    $FF4CAF50,
    $FFFF9800,
    $FF9C27B0,
    $FF00BCD4,
    $FFFFC107,
    $FF795548,
    $FF3F51B5,
    $FF8BC34A,
    $FFE91E63,
    $FF607D8B
  );

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

  CScaleUnits: array[0..4] of string = (
    'г',
    'кг',
    'т',
    'л',
    'м3'
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

function IsVisualInputChannel(AWorkTable: TWorkTable; const ARow,
  AInputType: Integer): Boolean;
var
  Device: TDevice;
begin
  Result := False;
  if (AWorkTable = nil) or (ARow < 0) or
     (ARow >= AWorkTable.DeviceChannels.Count) or
     (AWorkTable.DeviceChannels[ARow] = nil) or
     (AWorkTable.DeviceChannels[ARow].FlowMeter = nil) then
    Exit;

  Device := AWorkTable.DeviceChannels[ARow].FlowMeter.Device;
  Result := (Device <> nil) and
    (Device.OutputType = Ord(otVisual)) and
    (Device.InputType = AInputType);
end;

function IsDeviceReadingColumn(const AColumn: TColumn): Boolean;
begin
  Result := (AColumn <> nil) and
    ((AColumn.Name = 'StringColumnDeviceQuantityBefore1') or
     (AColumn.Name = 'StringColumnDeviceQuantityAfter1'));
end;

{$R *.fmx}

procedure DrawValueEditButton(const ACanvas: TCanvas; const ARect: TRectF;
  const APressed: Boolean);
var
  State: TCanvasSaveState;
begin
  State := ACanvas.SaveState;
  try
    ACanvas.Fill.Kind := TBrushKind.Solid;
    if APressed then
      ACanvas.Fill.Color := $FFC8C8C8
    else
      ACanvas.Fill.Color := $FFE0E0E0;
    ACanvas.FillRect(ARect, 0, 0, [], 1);
    ACanvas.Stroke.Kind := TBrushKind.Solid;
    ACanvas.Stroke.Color := $FF808080;
    ACanvas.Stroke.Thickness := 1;
    ACanvas.DrawRect(ARect, 0, 0, [], 1);
    ACanvas.Fill.Color := TAlphaColors.Black;
    ACanvas.Font.Size := 12;
    ACanvas.FillText(ARect, '...', False, 1, [], TTextAlign.Center,
      TTextAlign.Center);
  finally
    ACanvas.RestoreState(State);
  end;
end;

{ TValueEditButton }

procedure TValueEditButton.Paint;
begin
  DrawValueEditButton(Canvas, LocalRect, FPressed);
end;

procedure TValueEditButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    FPressed := True;
    Repaint;
  end;
  inherited;
end;

procedure TValueEditButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    FPressed := False;
    Repaint;
  end;
  inherited;
end;

{ TValueEditColumn }

constructor TValueEditColumn.Create(AOwner: TComponent);
begin
  inherited;
  ReadOnly := False;
  FButtonText := '...';
  FButtonWidth := CValueEditButtonWidth;
end;

function TValueEditColumn.ButtonVisible(const ACol, ARow: Integer): Boolean;
begin
  Result := True;
  if Assigned(FOnGetButtonVisible) then
    FOnGetButtonVisible(Self, ACol, ARow, Result);
end;

procedure TValueEditColumn.ClickButton(const ACol, ARow: Integer;
  const AText: string);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self, ACol, ARow, AText);
end;

function TValueEditColumn.CreateEditor(const ACol, ARow: Integer;
  const AText: string): TValueEditCellEditor;
begin
  Result := TValueEditCellEditor.Create(nil);
  Result.Initialize(Self, ACol, ARow, AText, ButtonVisible(ACol, ARow));
end;

procedure TValueEditColumn.DrawButtonCell(const Canvas: TCanvas;
  const Bounds: TRectF; const ACol, ARow: Integer; const AText: string;
  const ABackground: TAlphaColor);
var
  ButtonBounds: TRectF;
begin
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := ABackground;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  if ButtonVisible(ACol, ARow) then
  begin
    ButtonBounds := RectF(Bounds.Left, Bounds.Top,
      Bounds.Left + FButtonWidth, Bounds.Bottom);
    DrawValueEditButton(Canvas, ButtonBounds, False);
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(RectF(ButtonBounds.Right, Bounds.Top, Bounds.Right,
      Bounds.Bottom), AText, False, 1, [], TTextAlign.Leading,
      TTextAlign.Center);
  end
  else
  begin
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(RectF(Bounds.Left + 4, Bounds.Top, Bounds.Right,
      Bounds.Bottom), AText, False, 1, [], TTextAlign.Leading,
      TTextAlign.Center);
  end;
end;

{ TValueEditCellEditor }

constructor TValueEditCellEditor.Create(AOwner: TComponent);
begin
  inherited;
  Enabled := True;
  ReadOnly := False;
  HitTest := True;
  CanFocus := True;
  TabStop := True;

  FPhotoButton := TValueEditButton.Create(Self);
  FPhotoButton.Parent := Self;
  FPhotoButton.Align := TAlignLayout.Right;
  FPhotoButton.Width := CValueEditButtonWidth;
  FPhotoButton.Margins.Rect := TRectF.Empty;
  FPhotoButton.OnClick := ButtonClick;
end;

procedure TValueEditCellEditor.ButtonClick(Sender: TObject);
var
  LColumn: TValueEditColumn;
  LCol: Integer;
  LRow: Integer;
  LText: string;
begin
  LColumn := FColumn;
  LCol := FCol;
  LRow := FRow;
  LText := Text;
  if LColumn <> nil then
    LColumn.ClickButton(LCol, LRow, LText);
end;

procedure TValueEditCellEditor.Initialize(AColumn: TValueEditColumn;
  const ACol, ARow: Integer; const AText: string;
  const AShowButton: Boolean);
begin
  FColumn := AColumn;
  FCol := ACol;
  FRow := ARow;
  Text := AText;
  FPhotoButton.Text := AColumn.ButtonText;
  FPhotoButton.Visible := AShowButton;
end;

{ TFlowGraphSeries }

constructor TFlowGraphSeries.Create(const AKey, ACaption: string; AColor: TAlphaColor; AVisible: Boolean);
begin
  inherited Create;
  FKey := AKey;
  FCaption := ACaption;
  FPointColor := AColor;
  FLineColor := AColor;
  FUserVisible := AVisible;
  FChannelAvailable := AVisible;
  FGraphIndex := 0;
  FSamples := TList<TFlowGraphSample>.Create;
end;

function TFlowGraphSeries.EffectiveVisible: Boolean;
begin
  Result := FUserVisible and FChannelAvailable;
end;

destructor TFlowGraphSeries.Destroy;
begin
  FSamples.Free;
  inherited;
end;

{ TGraphPanelView }

constructor TGraphPanelView.Create(AOwner: TComponent; AParent: TFmxObject;
  const AGraphIndex: Integer);
begin
  inherited Create;
  GraphIndex := AGraphIndex;
  Root := TLayout.Create(AOwner);
  Root.Parent := AParent;
  Root.Align := TAlignLayout.None;
  Root.Padding.Rect := RectF(4, 4, 4, 4);

  Header := TLayout.Create(AOwner);
  Header.Parent := Root;
  Header.Align := TAlignLayout.Top;
  Header.Height := 32;
  TitleLabel := TLabel.Create(AOwner);
  TitleLabel.Parent := Header;
  TitleLabel.Align := TAlignLayout.Client;
  TitleLabel.Text := Format('График %d', [GraphIndex + 1]);
  TitleLabel.TextSettings.Font.Style := [TFontStyle.fsBold];

  LegendHost := TLayout.Create(AOwner);
  LegendHost.Parent := Root;
  LegendHost.Align := TAlignLayout.Bottom;
  LegendHost.Height := 0;
  LegendHost.Visible := False;
  LegendLayout := TFlowLayout.Create(AOwner);
  LegendLayout.Parent := LegendHost;
  LegendLayout.Align := TAlignLayout.Client;
  LegendLayout.FlowDirection := TFlowDirection.LeftToRight;

  Chart := TSimpleChart.Create(AOwner);
  Chart.Parent := Root;
  Chart.Align := TAlignLayout.Client;
  Chart.BackgroundColor := TAlphaColors.White;
  Chart.XTitle := 'Время, с';
  Chart.YTitle := 'Значение';

  EmptyLabel := TLabel.Create(AOwner);
  EmptyLabel.Parent := Root;
  EmptyLabel.Align := TAlignLayout.Center;
  EmptyLabel.Width := 310;
  EmptyLabel.Height := 56;
  EmptyLabel.Text := 'Нет выбранных данных.' + sLineBreak +
    'Добавьте серию через правую кнопку мыши.';
  EmptyLabel.TextSettings.HorzAlign := TTextAlign.Center;

  PopupMenu := TPopupMenu.Create(AOwner);
  Root.PopupMenu := PopupMenu;
end;

destructor TGraphPanelView.Destroy;
begin
  Root := nil;
  Header := nil;
  TitleLabel := nil;
  Chart := nil;
  EmptyLabel := nil;
  LegendHost := nil;
  LegendLayout := nil;
  PopupMenu := nil;
  inherited;
end;


constructor TFlowGraphHistory.Create;
begin
  inherited Create;
  FEtalonSeries := TObjectDictionary<string, TFlowGraphSeries>.Create([doOwnsValues]);
  FDeviceSeries := TObjectDictionary<string, TFlowGraphSeries>.Create([doOwnsValues]);
end;

destructor TFlowGraphHistory.Destroy;
begin
  FEtalonSeries.Free;
  FDeviceSeries.Free;
  inherited;
end;

procedure TFlowGraphHistory.Clear;
begin
  FEtalonSeries.Clear;
  FDeviceSeries.Clear;
end;



function IsVolumeFlowUnit(const AUnit: string): Boolean;
var
  I: Integer;
begin
  for I := Low(CVolumeFlowUnits) to High(CVolumeFlowUnits) do
    if SameText(AUnit, CVolumeFlowUnits[I]) then
      Exit(True);
  Result := False;
end;

function IsScaleUnit(const AUnit: string): Boolean;
var
  I: Integer;
begin
  for I := Low(CScaleUnits) to High(CScaleUnits) do
    if SameText(AUnit, CScaleUnits[I]) then
      Exit(True);
  Result := False;
end;

function ResolveQuantityUnitByFlowUnit(const AUnit: string): string; forward;

function NormalizeScaleUnit(const AUnit: string): string;
begin
  Result := Trim(AUnit);
  if IsScaleUnit(Result) then
    Exit;

  Result := ResolveQuantityUnitByFlowUnit(Result);
  if not IsScaleUnit(Result) then
    Result := 'кг';
end;

function BuildScaleCaption(const ACaptionPrefix, AUnit: string): string;
var
  ValueName: string;
begin
  if SameText(AUnit, 'л') or SameText(AUnit, 'м3') then
    ValueName := 'объем'
  else
    ValueName := 'вес';

  Result := ACaptionPrefix + ' ' + ValueName + ', ' + AUnit;
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

procedure TFrameMainTable.BeforeDestruction;
begin
  FDestroying := True;
  FGraphRenderQueued := False;

  if FGraphRenderTimer <> nil then
  begin
    FGraphRenderTimer.Enabled := False;
    FGraphRenderTimer.OnTimer := nil;
  end;

  if FStabilitySampleTimer <> nil then
  begin
    FStabilitySampleTimer.Enabled := False;
    FStabilitySampleTimer.OnTimer := nil;
  end;

  if FGraphSplitters <> nil then
    FGraphSplitters.Clear;

  if FGraphLayoutContainers <> nil then
    FGraphLayoutContainers.Clear;

  inherited;
end;

destructor TFrameMainTable.Destroy;
begin
  FDestroying := True;
  FGraphRenderQueued := False;

  if FGraphRenderTimer <> nil then
  begin
    FGraphRenderTimer.Enabled := False;
    FGraphRenderTimer.OnTimer := nil;
  end;

  if FStabilitySampleTimer <> nil then
  begin
    FStabilitySampleTimer.Enabled := False;
    FStabilitySampleTimer.OnTimer := nil;
  end;

  FreeAndNil(FGraphSplitters);
  FreeAndNil(FGraphLayoutContainers);
  FreeAndNil(FGraphViews);
  if ChartEtalonFlow <> nil then
  begin
    ChartEtalonFlow.OnMouseDown := nil;
    ChartEtalonFlow.PopupMenu := nil;
  end;
  if ChartDeviceFlow <> nil then
  begin
    ChartDeviceFlow.OnMouseDown := nil;
    ChartDeviceFlow.PopupMenu := nil;
  end;
  FreeAndNil(FFlowGraphHistory);
  FreeAndNil(FGraphsViewConfig);
  FreeAndNil(FFrameMeasurementRun);
  FreeAndNil(FFrameMRResults);
  FreeAndNil(FFrameProtocol);
  FreeAndNil(FFrameFlowMeterProperties);
  FreeAndNil(FFrameChannelProperties);
  FreeAndNil(FFrameWorkTableProperties);
  FreeAndNil(FDeviceClipboard.Snapshot);
  FreeAndNil(FEtalonClipboard.Snapshot);
  FreeAndNil(FInstrumentalVisibleOrder);
  FreeAndNil(FWorkTableTabs);
  inherited;
end;

procedure TFrameMainTable.PrepareForShutdown;
begin
  if FDestroying then
    Exit;

  if FFrameProtocol <> nil then
    FFrameProtocol.PrepareForShutdown;

  if FFrameProceed <> nil then
    FFrameProceed.PrepareForShutdown;

  SaveLayoutSettingsToWorkTable;
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

procedure TFrameMainTable.UpdateFlowMeterPropertiesFrame(ARow: Integer = -1;
  AEtalon: Boolean = False);
var
  Channel: TChannel;
begin
  if FFrameFlowMeterProperties = nil then
    Exit;

  Channel := nil;
  if FActiveWorkTable <> nil then
  begin
    if AEtalon then
    begin
      if ARow < 0 then
        ARow := GridEtalons.Selected;

      if (FActiveWorkTable.EtalonChannels <> nil) and
         (ARow >= 0) and (ARow < FActiveWorkTable.EtalonChannels.Count) then
        Channel := FActiveWorkTable.EtalonChannels[ARow];
    end
    else
    begin
      if ARow < 0 then
        ARow := GridDevices.Selected;

      if (FActiveWorkTable.DeviceChannels <> nil) and
         (ARow >= 0) and (ARow < FActiveWorkTable.DeviceChannels.Count) then
        Channel := FActiveWorkTable.DeviceChannels[ARow];
    end;
  end;

  FFlowMeterPropertiesChannel := Channel;
  if Channel <> nil then
    FFrameFlowMeterProperties.FlowMeter := Channel.FlowMeter
  else
    FFrameFlowMeterProperties.FlowMeter := nil;
end;

procedure TFrameMainTable.FlowMeterPropertiesChanged(Sender: TObject);
var
  Row: Integer;
  Channel: TChannel;
begin
  Channel := FFlowMeterPropertiesChannel;

  if (Channel = nil) and (FActiveWorkTable <> nil) and
     (FActiveWorkTable.DeviceChannels <> nil) then
  begin
    Row := GridDevices.Selected;
    if (Row >= 0) and (Row < FActiveWorkTable.DeviceChannels.Count) then
      Channel := FActiveWorkTable.DeviceChannels[Row];
  end;

  RefreshActiveWorkTableViews(Channel, True);

  if DataManager <> nil then
    DataManager.Save;
  if WorkTableManager <> nil then
    WorkTableManager.Save;
end;

procedure TFrameMainTable.RefreshActiveWorkTableViews(AChannel: TChannel;
  ASyncFromFlowMeter: Boolean);
var
  InputType: Integer;
  HasInputType: Boolean;
begin
  if IsUpdating then
    Exit;

  HasInputType := ASyncFromFlowMeter and (AChannel <> nil) and
    (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.Device <> nil);
  if HasInputType then
    InputType := AChannel.FlowMeter.Device.InputType;

  if ASyncFromFlowMeter and (AChannel <> nil) and (AChannel.FlowMeter <> nil) then
  begin
    AChannel.TypeName := AChannel.FlowMeter.DeviceTypeName;
    AChannel.Serial := AChannel.FlowMeter.SerialNumber;
    AChannel.Signal := AChannel.FlowMeter.OutputType;
    MarkChannelDeviceModified(AChannel);
    SyncChannelsWithSameDeviceUUID(AChannel, AChannel.DeviceUUID);

    { SyncChannelsWithSameDeviceUUID may rebind the flow meter to the
      repository device. Preserve the input mode selected in the properties. }
    if HasInputType and (AChannel.FlowMeter.Device <> nil) then
      AChannel.FlowMeter.Device.InputType := InputType;
  end;

  IsUpdating := True;
  try
    UpdateUIFromValues;
    UpdateGrids;
    if FFrameWorkTableProperties <> nil then
      FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
    if AChannel <> nil then
    begin
      FFlowMeterPropertiesChannel := AChannel;
      if FFrameFlowMeterProperties <> nil then
        FFrameFlowMeterProperties.FlowMeter := AChannel.FlowMeter;
      if FFrameChannelProperties <> nil then
        FFrameChannelProperties.LoadFromChannel(AChannel);
    end;
  finally
    IsUpdating := False;
  end;
  { Channel notifications only synchronize graph assignments/availability;
    they deliberately do not reinitialize or clear graph runtime data. }
  if FGraphsWorkspace <> nil then
    FGraphsWorkspace.RefreshEnabledSources;
end;

{ Moves a channel and refreshes the corresponding grid immediately. }
procedure TFrameMainTable.ChannelMoveRequested(Sender: TObject;
  AChannel: TChannel; const AMoveUp: Boolean);
var
  WorkTable: TWorkTable;
  Grid: TGrid;
  OldIndex: Integer;
  NewIndex: Integer;
  Moved: Boolean;
begin
  if IsUpdating or (AChannel = nil) then
    Exit;

  WorkTable := FActiveWorkTable;
  if not IsManagedWorkTable(WorkTable) then
    Exit;

  OldIndex := WorkTable.EtalonChannels.IndexOf(AChannel);
  if OldIndex >= 0 then
    Grid := GridEtalons
  else
  begin
    OldIndex := WorkTable.DeviceChannels.IndexOf(AChannel);
    if OldIndex < 0 then
      Exit;
    Grid := GridDevices;
  end;

  if AMoveUp then
    Moved := WorkTable.MoveChannelUp(AChannel)
  else
    Moved := WorkTable.MoveChannelDown(AChannel);

  if not Moved then
  begin
    if Assigned(FFrameChannelProperties) then
      FFrameChannelProperties.UpdateMoveButtons;
    Exit;
  end;

  if Grid = GridEtalons then
    NewIndex := WorkTable.EtalonChannels.IndexOf(AChannel)
  else
    NewIndex := WorkTable.DeviceChannels.IndexOf(AChannel);

  IsUpdating := True;
  try
    { Repaint alone keeps the grid's cached row mapping.  RefreshGridValues
      inside UpdateGrids makes the new collection order visible immediately. }
    UpdateGrids;
    if NewIndex >= 0 then
      Grid.Selected := NewIndex;
    FFlowMeterPropertiesChannel := AChannel;
    if Assigned(FFrameChannelProperties) then
      FFrameChannelProperties.LoadFromChannel(AChannel);
  finally
    IsUpdating := False;
  end;

  if Assigned(WorkTableManager) then
    WorkTableManager.Save;
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
  I: Integer;
  Pump: TPump;
  ItemIndex: Integer;
  OldTag: NativeInt;
begin
  OldTag := LayoutPump.Tag;
  LayoutPump.Tag := 2;
  try
    ComboBoxPumps.Items.Clear;
    ComboBoxPumps.ItemIndex := -1;

    if (FActiveWorkTable = nil) or (FActiveWorkTable.Pumps = nil) then
      Exit;

    ItemIndex := -1;
    // В интерфейсе показываем Caption, а объект храним в Items.Objects.
    for Pump in FActiveWorkTable.Pumps do
      if Pump <> nil then
      begin
        I := ComboBoxPumps.Items.AddObject(Pump.Caption, Pump);
        if Pump = FActiveWorkTable.ActivePump then
          ItemIndex := I;
      end;

    ComboBoxPumps.ItemIndex := ItemIndex;
  finally
    LayoutPump.Tag := OldTag;
  end;
end;

procedure TFrameMainTable.RefreshScalesCombo;
var
  Scale: TWeight;
  SelectedScaleName: string;
  ItemIndex: Integer;
  OldTag: NativeInt;
begin
  OldTag := LayoutScale.Tag;
  LayoutScale.Tag := 2;
  try
    ComboBoxScales.Items.Clear;
    ComboBoxScales.ItemIndex := -1;

    if (FActiveWorkTable = nil) or (FActiveWorkTable.Weights = nil) then
      Exit;

    SelectedScaleName := Trim(ComboBoxScales.Text);
    if (SelectedScaleName = '') and (FActiveWorkTable.ActiveScale <> nil) then
      SelectedScaleName := FActiveWorkTable.ActiveScale.Name;

    for Scale in FActiveWorkTable.Weights do
      if Scale <> nil then
        ComboBoxScales.Items.Add(Scale.Name);

    ItemIndex := -1;
    if SelectedScaleName <> '' then
      ItemIndex := ComboBoxScales.Items.IndexOf(SelectedScaleName);
    if (ItemIndex < 0) and (ComboBoxScales.Items.Count > 0) then
      ItemIndex := 0;

    ComboBoxScales.ItemIndex := ItemIndex;
    if ItemIndex >= 0 then
      FActiveWorkTable.SetActiveScale(ComboBoxScales.Items[ItemIndex]);
  finally
    LayoutScale.Tag := OldTag;
  end;
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

procedure TFrameMainTable.StartMeasurement;
var Run: TMeasurementRun; UUID: string; StageBefore, IndexBefore: Integer; PausedBefore: Boolean;
begin
  if FActiveWorkTable = nil then Exit;
  Run := MeasurementRun;
  if Run = nil then Exit;
  UUID := ''; StageBefore := Ord(Run.Stage); IndexBefore := Run.CurrentPointIndex; PausedBefore := Run.IsPaused;
  if Run.CurrentPoint <> nil then UUID := Run.CurrentPoint.UUID;
  if (Run.Mode = mrmManual) and (Run.Points <> nil) and (Run.Points.Count = 1) then
    ProtocolManager.AddMessage(pcProc, psForm, 'ManualPointReused',
      'Повторно используется подготовленная ручная точка',
      Format('UUID=%s; PreparedPointsCount=%d; Reason=StartInManualMode',
        [Run.Points.First.UUID, Run.Points.Count]));
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested',
    'Запрошена команда интерфейса измерения',
    Format('Command=Start; AutoMode=%s; RunAssigned=True; Stage=%d; IsPaused=%s; CurrentPointIndex=%d; CurrentPointUUID=%s; WorkTableState=%d; ButtonEnabled=%s',
      [BoolToStr((SwitchAuto <> nil) and SwitchAuto.IsChecked, True), Ord(Run.Stage),
       BoolToStr(Run.IsPaused, True), Run.CurrentPointIndex, UUID,
       Ord(FActiveWorkTable.State), BoolToStr(TestButton.Enabled, True)]));
  FActiveWorkTable.MeasurementMode := Run.Mode;
  FActiveWorkTable.StartMeasurementRun;
  if FFrameMeasurementRun <> nil then FFrameMeasurementRun.UpdateUI;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent',
    'Команда интерфейса передана',
    Format('Command=Start; RunObjectPointer=%p; StageBefore=%d; IsPausedBefore=%s; CurrentPointIndexBefore=%d',
      [Pointer(Run), StageBefore, BoolToStr(PausedBefore, True), IndexBefore]));
end;

procedure TFrameMainTable.StopMeasurement;
var Run: TMeasurementRun; StageValue, PointIndex: Integer; Paused: Boolean;
begin
  if FActiveWorkTable = nil then Exit;
  Run := MeasurementRun; StageValue := -1; PointIndex := -1; Paused := False;
  if Run <> nil then begin StageValue := Ord(Run.Stage); PointIndex := Run.CurrentPointIndex; Paused := Run.IsPaused; end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested',
    'Запрошена команда интерфейса измерения',
    Format('Command=Stop; AutoMode=%s; RunAssigned=%s; Stage=%d; IsPaused=%s; CurrentPointIndex=%d; CurrentPointUUID=; WorkTableState=%d; ButtonEnabled=%s',
      [BoolToStr((SwitchAuto <> nil) and SwitchAuto.IsChecked, True), BoolToStr(Run <> nil, True),
       StageValue, BoolToStr(Paused, True), PointIndex, Ord(FActiveWorkTable.State), BoolToStr(TestButton.Enabled, True)]));
  FActiveWorkTable.StopMeasurementRun;
  if FFrameMeasurementRun <> nil then FFrameMeasurementRun.UpdateUI;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent',
    'Команда интерфейса передана',
    Format('Command=Stop; RunObjectPointer=%p; StageBefore=%d; IsPausedBefore=%s; CurrentPointIndexBefore=%d',
      [Pointer(Run), StageValue, BoolToStr(Paused, True), PointIndex]));
end;

 procedure TFrameMainTable.SwitchAutoSwitch(Sender: TObject);
begin
  ApplyMeasurementModeFromSwitch;
end;

procedure TFrameMainTable.RefreshMeasurementRunFrame;
begin
  if FFrameMeasurementRun <> nil then
    FFrameMeasurementRun.RefreshFromMeasurementRun;
end;

procedure TFrameMainTable.BuildManualMeasurementPoint;
var
  Run: TMeasurementRun;
  CountBefore: Integer;
  Point: TDevicePoint;
begin
  Run := MeasurementRun;
  if (FActiveWorkTable = nil) or (Run = nil) or (FActiveWorkTable.CurrentPoint = nil) then Exit;
  CountBefore := Run.Points.Count;
  Run.Points.Clear;
  ProtocolManager.AddMessage(pcProc, psForm, 'ManualPointSetCleared',
    'Очищен подготовленный набор точек',
    Format('CountBefore=%d; CountAfter=%d; Reason=SwitchToManual', [CountBefore, Run.Points.Count]));
  if (FActiveWorkTable.FlowRate <> nil) and (FActiveWorkTable.FlowRate.ValueSet <> nil) then
    FActiveWorkTable.CurrentPoint.Q := FActiveWorkTable.FlowRate.ValueSet.Value;
  if (FActiveWorkTable.FluidTemp <> nil) and (FActiveWorkTable.FluidTemp.ValueSet <> nil) then
    FActiveWorkTable.CurrentPoint.Temp := FActiveWorkTable.FluidTemp.ValueSet.Value;
  if (FActiveWorkTable.FluidPress <> nil) and (FActiveWorkTable.FluidPress.ValueSet <> nil) then
    FActiveWorkTable.CurrentPoint.Pressure := FActiveWorkTable.FluidPress.ValueSet.Value;
  Run.InvalidatePreparedPoints;
  Run.RebuildMeasurementPoints;
  if (Run.Points <> nil) and (Run.Points.Count = 1) then
  begin
    Point := Run.CurrentPoint;
    if Point = nil then
      Exit;
    ProtocolManager.AddMessage(pcProc, psForm, 'ManualPointCreated',
      'Создана подготовленная ручная точка',
      Format('UUID=%s; Q=%.9g; FlowRate=%.9g; StopCriteria=%d; LimitTime=%.9g; LimitVolume=%.9g; LimitImp=%d; PreparedPointsCount=%d',
        [Point.UUID, Point.Q, Point.FlowRate, CriteriaToInt(Point.StopCriteria), Point.LimitTime,
         Point.LimitVolume, Point.LimitImp, Run.Points.Count]));
  end;
end;

procedure TFrameMainTable.UpdatePreparedManualPoint;
var
  Run: TMeasurementRun;
  Point: TDevicePoint;
  PointUUID: string;
begin
  Run := MeasurementRun;
  if (Run = nil) or (Run.Mode <> mrmManual) or (Run.Points = nil) or
     (Run.Points.Count <> 1) or (FActiveWorkTable = nil) or
     (FActiveWorkTable.CurrentPoint = nil) then Exit;
  if (FActiveWorkTable.FlowRate <> nil) and (FActiveWorkTable.FlowRate.ValueSet <> nil) then
    FActiveWorkTable.CurrentPoint.Q := FActiveWorkTable.FlowRate.ValueSet.Value;
  if (FActiveWorkTable.FluidTemp <> nil) and (FActiveWorkTable.FluidTemp.ValueSet <> nil) then
    FActiveWorkTable.CurrentPoint.Temp := FActiveWorkTable.FluidTemp.ValueSet.Value;
  if (FActiveWorkTable.FluidPress <> nil) and (FActiveWorkTable.FluidPress.ValueSet <> nil) then
    FActiveWorkTable.CurrentPoint.Pressure := FActiveWorkTable.FluidPress.ValueSet.Value;
  Point := Run.Points.First;
  PointUUID := Point.UUID;
  Point.Assign(FActiveWorkTable.CurrentPoint, False);
  // Обновление параметров не должно превращать ручную runtime-точку обратно
  // в последнюю автоматическую точку и менять её идентификатор.
  Point.UUID := PointUUID;
  Point.Name := 'Ручная точка';
  Point.Enabled := True;
  FActiveWorkTable.CurrentPoint.Assign(Point, False);
  FActiveWorkTable.CurrentPoint.UUID := Point.UUID;
  if FFrameMeasurementRun <> nil then FFrameMeasurementRun.RefreshFromMeasurementRun;
end;

procedure TFrameMainTable.ApplyMeasurementModeFromSwitch;
var
  Run: TMeasurementRun;
  NewMode, PreviousMode: EMeasurementRunMode;
begin
  if FUpdatingAutoSwitch or (FActiveWorkTable = nil) then
    Exit;
  Run := MeasurementRun;
  if Run = nil then
    Exit;

  PreviousMode := Run.Mode;
  if not (Run.Stage in [msNone, msDone]) then
  begin
    FUpdatingAutoSwitch := True;
    try
      SwitchAuto.IsChecked := PreviousMode = mrmAutomatic;
    finally
      FUpdatingAutoSwitch := False;
    end;
    Exit;
  end;

  if SwitchAuto.IsChecked then
    NewMode := mrmAutomatic
  else
    NewMode := mrmManual;
  if NewMode = PreviousMode then
    Exit;

  Run.Mode := NewMode;
  FActiveWorkTable.MeasurementMode := NewMode;
  if NewMode = mrmManual then
    BuildManualMeasurementPoint
  else
  begin
    Run.InvalidatePreparedPoints;
    Run.RebuildMeasurementPoints;
    ProtocolManager.AddMessage(pcProc, psForm, 'AutoPointSetRestored',
      'Восстановлен автоматический набор точек',
      Format('PointsCount=%d', [Run.Points.Count]));
  end;
  RefreshMeasurementRunFrame;
  UpdateTestButton;
  ProtocolManager.AddMessage(pcAction, psMeasurement, 'MeasurementModeChanged',
    'Изменён режим измерения',
    Format('Mode=%s; PointsCount=%d; ManualPointAssigned=%s',
      [TMeasurementRun.MeasurementRunModeToString(Run.Mode), Run.Points.Count,
       BoolToStr((Run.Mode = mrmManual) and
         (FActiveWorkTable.CurrentPoint <> nil), True)]));
end;

procedure TFrameMainTable.UpdateForm;
 begin
          NormalizeActiveWorkTable;
          if FActiveWorkTable = nil then
          begin
            RefreshPumpsCombo;
            ResetUIPump;
            RefreshScalesCombo;
            UpdateUIScale;
            UpdateGrids;
            if FFrameWorkTableProperties <> nil then
              FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
            ApplyActiveWorkTableEditMode;
            Exit;
          end;

          IsUpdating := True;
            try
               UpdateUIFromValues;
                RefreshPumpsCombo;
                UpdateUIPump;
                RefreshScalesCombo;
                UpdateUIScale;
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
  Notification: TStateNotification;
  NewState: EStateWorkTable;
begin
  if not (AData is TStateNotification) then
  begin
    ProtocolManager.AddMessage(pcWarning, psForm, 'HandleWorkTableStateChanged',
      Format('[WorkTable.State] Некорректный тип Data: %s', [ObjClassNameOrNil(AData)]), '');
    Exit;
  end;

  Notification := TStateNotification(AData);
  if (Notification.NewState < Ord(Low(EStateWorkTable))) or
     (Notification.NewState > Ord(High(EStateWorkTable))) then
    Exit;

  NewState := EStateWorkTable(Notification.NewState);

  if NewState in [swtCOMPLETE, swtFINALREAD, swtSaveConfirmation] then
    AWorkTable.RecalculateAllMeterValues;

  if AWorkTable <> FActiveWorkTable then
    Exit;

  OnChangeState(NewState);
  UpdateMeasurementStartStopButton('WorkTableStateChanged');
  if FFrameMeasurementRun <> nil then FFrameMeasurementRun.UpdateUI;
  {
  if AData is TDevicePoint then
    Point := TDevicePoint(AData)
  else
    Point := AWorkTable.CurrentPoint;

  if Point <> nil then
    OnChangePoint(AWorkTable, Point, -1);
        }
  UpdateForm;
end;

procedure TFrameMainTable.HandleWorkTableAction(const AWorkTable: TWorkTable; AData: TObject);
var
  Action: EActionWorkTable;
  Error: TErrorInfo;


function TryToGetAction:  EActionWorkTable;
begin
    Result:=EActionWorkTable.awtNone;

   if not (AData is TActionNotification) then
  begin
    ProtocolManager.AddMessage(pcWarning, psForm, 'HandleWorkTableAction',
    Format('[WorkTable.Action] Некорректный тип Data: %s', [ObjClassNameOrNil(AData)]), '');
    Result:= AWorkTable.Action;
  end else
  begin

  if (TActionNotification(AData).Action < Ord(Low(EActionWorkTable))) or
     (TActionNotification(AData).Action > Ord(High(EActionWorkTable))) then
  begin
    ProtocolManager.AddMessage(pcWarning, psForm, 'HandleWorkTableAction',
      Format('[WorkTable.Action] Некорректный код Action: %d', [TActionNotification(AData).Action]), '');
    Exit;
  end;
      Result:= EActionWorkTable(TActionNotification(AData).Action);
  end;

end;

begin
  if AWorkTable = nil then
    Exit;

   Action:= TryToGetAction;

  case Action of
    awtStartTest:
      begin
          //После очистки стола, обновляем форму.
          UpdateForm;
      end;

    awtStopTest:
         begin

         end;

    awtStartMonitor:
         begin
           //После очистки стола, обновляем форму.
          UpdateForm;
         end;

    awtStopMonitor:
          begin

         end;
    awtFindHydraulicConfiguration:
         begin
         if IsHydraulicSimulationMode(AWorkTable) then
           CompleteSimulatedHydraulicConfiguration(AWorkTable);
         if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(
            pcProc,
            psForm,
            'FindHydraulicConfiguration',
            'Подбор гидравлической схемы',
            AWorkTable.Name
          );
         end;
    awtSetupHydraulicLine:
      begin
        if IsHydraulicSimulationMode(AWorkTable) then
        begin
          CompleteSimulatedHydraulicLineSetup(AWorkTable);
          Exit;
        end;
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm,
            'SetupHydraulicLine', 'Гидравлическая линия устанавливается',
            AWorkTable.Name);
        if not AWorkTable.ApplyHydraulicConfiguration(Error) and
           Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcError, psForm,
            'SetupHydraulicLine', 'Ошибка установки гидравлической линии',
            Error.Msg);
      end;
    awtSelectEtalons:
      begin
        // Доменное действие уже выполнено в TWorkTable.SelectEtalons.
        // Обработчик только пишет протокол: он не меняет Enabled и не запускает измерение.
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(
            pcProc,
            psForm,
            'SelectEtalons',
            'Выполнен выбор эталонов рабочего стола',
            AWorkTable.Name
          );
      end;
  end;

{  case AWorkTable.Action of
    awtStartTest:
      begin
       AWorkTable.ExecuteAction;
      //  if (AWorkTable = FActiveWorkTable) and (MeasurementRun <> nil) then
      //   MeasurementRun.Execute(mcStart);
        Exit;
      end;

    awtStopTest:
      begin
        AWorkTable.ExecuteAction;
      //  if (AWorkTable = FActiveWorkTable) and (MeasurementRun <> nil) then
      //    MeasurementRun.Execute(mcStop);
        Exit;
      end;
  else
    AWorkTable.ExecuteAction;
  end;

  if AData is TDevicePoint then
    OnChangePoint(AWorkTable, TDevicePoint(AData), -1);
             }
  UpdateForm;
end;

procedure TFrameMainTable.HandleWorkTableEvent(const AWorkTable: TWorkTable; AData: TObject);
var
  Notification: TEventNotification;
  WorkTableEvent: EEventWorkTable;

  SelectedChannel: TChannel;

function TryToGetEvent:  EEventWorkTable;
begin
    Result:=EEventWorkTable.ewtEvent;

   if Assigned(AData) and (AData is TEventNotification) then
  begin
    Notification := TEventNotification(AData);

    if (Notification.Event < Ord(Low(EEventWorkTable))) or
     (Notification.Event > Ord(High(EEventWorkTable))) then
      Exit;

    Result := EEventWorkTable(Notification.Event);
  end
  else
  begin

     Result:=EEventWorkTable(AWorkTable.Event);

  end;

end;


begin
  { The pointer comparison must precede every dereference of the queued sender. }
  if FDeletingWorkTable and
     (Pointer(AWorkTable) = FDeletingWorkTablePointer) then
  begin
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcInfo, psWorkTable,
        'WorkTableEventIgnoredDuringDelete',
        Format('Sender=%p; Deleting=%s', [Pointer(AWorkTable),
          BoolToStr(FDeletingWorkTable, True)]), '');
    Exit;
  end;

  { Only a pointer found in the owning list may be dereferenced. }
  if not IsManagedWorkTable(AWorkTable) then
    Exit;

  WorkTableEvent:=TryToGetEvent;

  if WorkTableEvent = ewtActivated then
  begin
    { SelectWorkTable already performed the complete UI activation.  A queued
      copy of the same event must not rebuild grids and columns a second time. }
    if FActiveWorkTable = AWorkTable then
      Exit;

    FActiveWorkTable := AWorkTable;

    if FFrameMeasurementRun <> nil then
      FFrameMeasurementRun.ActiveWorkTable := FActiveWorkTable;
    if FFrameMRResults <> nil then
      FFrameMRResults.ActiveWorkTable := FActiveWorkTable;

    if FFrameWorkTableProperties <> nil then
      FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);

    SetValues;
    RefreshScalesCombo;
    UpdateUIScale;
    OnChangeState(FActiveWorkTable.State);
    UpdateForm;
    Exit;
  end;

  if WorkTableEvent = ewtSimulationMeasurementResultsSaved then
  begin
    { SaveMeasurementResults уже завершён, поэтому обработка перечитывает
      окончательно сохранённые имитационные проливки, а не предыдущее состояние. }
    if FActiveWorkTable = AWorkTable then
    begin
      if FFrameProceed <> nil then
        FFrameProceed.RefreshResultsTab;
      if FFrameMRResults <> nil then
        FFrameMRResults.ReloadAndUpdate;
    end;

    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(
        pcProc,
        psForm,
        'SimulationResultsUiRefreshed',
        'Обработка обновлена после сохранения имитационной проливки',
        AWorkTable.Name
      );
    Exit;
  end;

  if WorkTableEvent = ewtEtalonsChanged then
  begin
    // UI обновляется по уведомлению рабочего стола, без прямых вызовов из TWorkTable.
    if FActiveWorkTable = AWorkTable then
    begin
      UpdateGrids;
      UpdateForm;
    end;

    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(
        pcInfo,
        psWorkTable,
        'EtalonsChanged',
        'Обновление интерфейса после изменения выбранных эталонов',
        AWorkTable.Name
      );
    Exit;
  end;

  if WorkTableEvent = ewtRefresh then
  begin
    UpdateWorkTableTabCaption(AWorkTable);
    if FFrameProceed <> nil then
      FFrameProceed.RefreshWorkTableDisplayName(AWorkTable);
    if FActiveWorkTable = AWorkTable then
    begin
      RefreshPumpsCombo;
      RefreshScalesCombo;
      UpdateForm;


      {if (FFrameChannelProperties <> nil) and (GridDevices.Row >= 0) and
         (GridDevices.Row < FActiveWorkTable.DeviceChannels.Count) then
        FFrameChannelProperties.LoadFromChannel(FActiveWorkTable.DeviceChannels[GridDevices.Row]);     }

      if (FFrameChannelProperties <> nil) and (FFlowMeterPropertiesChannel <> nil) and
         (((FActiveWorkTable.DeviceChannels <> nil) and
           (FActiveWorkTable.DeviceChannels.IndexOf(FFlowMeterPropertiesChannel) >= 0)) or
          ((FActiveWorkTable.EtalonChannels <> nil) and
           (FActiveWorkTable.EtalonChannels.IndexOf(FFlowMeterPropertiesChannel) >= 0))) then
        FFrameChannelProperties.LoadFromChannel(FFlowMeterPropertiesChannel);


      if FFrameWorkTableProperties <> nil then
        FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
    end;
    Exit;
  end;

 // HandleWorkTableAction(AWorkTable, AData);
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
  if FDeletingWorkTable and
     (Pointer(Sender) = FDeletingWorkTablePointer) then
  begin
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcInfo, psWorkTable,
        'WorkTableEventIgnoredDuringDelete',
        Format('Sender=%p', [Pointer(Sender)]), '');
    Exit;
  end;

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
    if (Event <> Ord(notifyEvent)) or not (Data is TEventNotification) or
       (TEventNotification(Data).Event <> Ord(ewtActivated)) then
      Exit;
  end;

  case SenderKind of
    nskWorkTable:
      case Event of
        Ord(notifyStateChanged): HandleWorkTableStateChanged(TWorkTable(Sender), Data);
        Ord(notifyAction): HandleWorkTableAction(TWorkTable(Sender), Data);
        Ord(notifyEvent): HandleWorkTableEvent(TWorkTable(Sender), Data);
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[WorkTable.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskPump:
      case Event of
        Ord(notifyStateChanged): HandlePumpStateChanged(TPump(Sender));
        Ord(notifyAction): HandlePumpAction(TPump(Sender));
        Ord(notifyEvent): HandlePumpAction(TPump(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[Pump.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskFlowRate:
      case Event of
        Ord(notifyStateChanged): HandleFlowRateStateChanged(TFlowRate(Sender));
        Ord(notifyAction): HandleFlowRateAction(TFlowRate(Sender));
        Ord(notifyEvent): HandleFlowRateAction(TFlowRate(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[FlowRate.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskFluidTemp:
      case Event of
        Ord(notifyStateChanged): HandleFluidTempStateChanged(TFluidTemp(Sender));
        Ord(notifyAction): HandleFluidTempAction(TFluidTemp(Sender));
        Ord(notifyEvent): HandleFluidTempAction(TFluidTemp(Sender));
      else
        ProtocolManager.AddMessage(pcWarning, psForm, 'OnNotify',
          Format('[FluidTemp.Notify] Unknown Event=%d Sender=%s Data=%s',
            [Event, Sender.ClassName, ObjClassNameOrNil(Data)]), '');
      end;

    nskFluidPress:
      case Event of
        Ord(notifyStateChanged): HandleFluidPressStateChanged(TFluidPress(Sender));
        Ord(notifyAction): HandleFluidPressAction(TFluidPress(Sender));
        Ord(notifyEvent): HandleFluidPressAction(TFluidPress(Sender));
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
  UpdateDeleteWorkTableButton;

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

        FActiveWorkTable.ValueTime.Accuracy:=-1;
        FActiveWorkTable.ValueTime.ShowTrailingZeros:=False;
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
        TestButton.Text := 'Стоп';
        TestButton.Tag := 3;
        TestButton.Enabled := True;
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

     swtFINALREAD:
      begin
        TestButton.Text := 'Сохранение';
        TestButton.Tag := 5;
        TestButton.Enabled := False;
        GlowMesYellow.Enabled := True;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := False;
      end;

     swtCOMPLETE:
      begin
        SetValues;
        UpdateForm;

        GlowMesYellow.Enabled := False;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := True;
        TestButton.Text := 'Сохранение';
        TestButton.Tag := 5;
        TestButton.Enabled := False;
        ButtonCancel.Text := 'Отмена';
        ButtonCancel.Enabled := False;
        ButtonCancel.Visible := False;
        GlowEffectCancelRed.Enabled := False;

      end;

    swtSaveConfirmation:
      begin
        // Запрос сохранения показывается только по специальному состоянию стола.
        SetValues;
        UpdateForm;
        GlowMesYellow.Enabled := False;
        GlowMesRed.Enabled := False;
        GlowMesGreen.Enabled := True;
        TestButton.Text := 'Сохранить?';
        TestButton.Tag := 6;
        TestButton.Enabled := True;
        ButtonCancel.Text := 'Отмена';
        ButtonCancel.Enabled := True;
        ButtonCancel.Visible := True;
        GlowEffectCancelRed.Enabled := True;
      end;

    swtFAILURE:
      begin
        GlowMesRed.Enabled := True;
        GlowMesYellow.Enabled := False;
        GlowMesGreen.Enabled := False;
        TestButton.Text := 'Ошибка';
        TestButton.Enabled := True;
        ButtonMonitor.Enabled := True;
        ApplyMonitorIndicatorColor(TAlphaColorRec.Gray);
      end;
  else
    begin
      // swtNONE
    end;
  end;

  UpdateTestButton;
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
  if FWorkTableTabs = nil then
    FWorkTableTabs := TDictionary<string, TTabItem>.Create;
  { TMenuItem.TagString is not streamable in all supported Delphi versions.
    Assign grid column names at runtime so lookup remains name-based. }
  if (MenuItemDevicesColumnCoefficient <> nil) and
     (StringColumnDeviceCoef1 <> nil) then
    MenuItemDevicesColumnCoefficient.TagString := StringColumnDeviceCoef1.Name;

  if (MenuItemDevicesColumnCalculatedCoefficient <> nil) and
     (StringColumnDeviceCalculatedCoef1 <> nil) then
    MenuItemDevicesColumnCalculatedCoefficient.TagString :=
      StringColumnDeviceCalculatedCoef1.Name;

  EnsureFlowGraphDictionaries;
  InitializeVisibleGraphPopupMenus;
  if ButtonClearFlowGraphs <> nil then
    ButtonClearFlowGraphs.OnClick := ButtonClearFlowGraphsClick;
  if Splitter1 <> nil then
    Splitter1.OnMouseUp := Splitter1MouseUp;
  if TabControlWorkTables <> nil then
    TabControlWorkTables.OnChange := TabControlWorkTablesChange;
  if (PanelControlWorkTables <> nil) and (TabItemWorkTable1 <> nil) and
     not IsControlInsideTab(PanelControlWorkTables, TabItemWorkTable1) then
  begin
    PanelControlWorkTables.Parent := TabItemWorkTable1;
    PanelControlWorkTables.Align := TAlignLayout.Client;
  end;

  if FInitialized then
    Exit;



  FInitialized := True;
  FStabilitySampleTimer := TTimer.Create(Self);
  FStabilitySampleTimer.Interval := 1000;
  FStabilitySampleTimer.OnTimer := StabilitySampleTimerTimer;
  FStabilitySampleTimer.Enabled := True;
  SwitchAuto.IsChecked := False;
  FInstrumentalVisibleOrder := TList<TLayout>.Create;
  FFrameProceed := nil;
  FFrameMeasurementRun := nil;
  FFrameMRResults := nil;
  FFrameProtocol := nil;
  FFrameFlowMeterProperties := nil;
  FFrameChannelProperties := nil;
  FFrameWorkTableProperties := nil;

  { Toolbar trash removes the selected channel; the context-menu clear command
    remains available through ActionDevicesClearRow. }
  if SpeedButton3 <> nil then
    SpeedButton3.Action := ActionDeleteDevice;

  RefreshGridRowCount(GridDevices, 2, 'initial-rows');
  RefreshGridValues(GridDevices, 'initial-rows');

  // Заполняем список через имя колонки
  PopupColumnDeviceSignal1.Items.Clear;

  for OT := otFrequency to High(TOutputType) do
    PopupColumnDeviceSignal1.Items.Add(GetOutputTypeName(OT));

  PopupColumnEtalonSignal1.Items.Assign(PopupColumnDeviceSignal1.Items);
  GridEtalons.OnDrawColumnCell := GridEtalonsDrawColumnCell;
  GridDevices.OnDrawColumnCell := GridDevicesDrawColumnCell;
  StringColumnDeviceQuantityBefore1.OnGetButtonVisible :=
    DeviceReadingButtonVisible;
  StringColumnDeviceQuantityAfter1.OnGetButtonVisible :=
    DeviceReadingButtonVisible;
  StringColumnDeviceQuantityBefore1.OnButtonClick := DeviceReadingButtonClick;
  StringColumnDeviceQuantityAfter1.OnButtonClick := DeviceReadingButtonClick;

  SyncDevicesColumnsMenu;
  SyncEtalonsColumnsMenu;

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
  FFrameMeasurementRun.OnRunUIChanged := MeasurementRunUiChanged;
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
    FFrameProtocol := TFrameProtocol.Create(Self);
    FFrameProtocol.Parent := LayoutProtocolHost;
    FFrameProtocol.Align := TAlignLayout.Client;
  end;

  InitializeAutoMeasurementTestTab;
  RefreshAutoMeasurementTestContext;

  RefreshFlowGraphChannels('UpdateForm');

  if FFrameFlowMeterProperties = nil then
  begin
    FFrameFlowMeterProperties := TFrameFlowMeterProperties.Create(Self);
    FFrameFlowMeterProperties.Parent := TabItemDeviceProperties;
    FFrameFlowMeterProperties.Align := TAlignLayout.Client;
    FFrameFlowMeterProperties.OnChange := FlowMeterPropertiesChanged;
  end;
  UpdateFlowMeterPropertiesFrame;

  if FFrameChannelProperties = nil then
  begin
    FFrameChannelProperties := TFrameChannelProperties.Create(Self);
    FFrameChannelProperties.Parent := TabItemChannelProperties;
    FFrameChannelProperties.Align := TAlignLayout.Client;
  end;
  FFrameChannelProperties.OnMoveChannel := ChannelMoveRequested;
  FFrameChannelProperties.UpdateMoveButtons;

  if FFrameWorkTableProperties = nil then
  begin
    FFrameWorkTableProperties := TFrameWorkTableProperties.Create(Self);
    FFrameWorkTableProperties.Parent := TabItemWorkTableProperties;
    FFrameWorkTableProperties.Align := TAlignLayout.Client;
  end;
  FFrameWorkTableProperties.OnDeleteWorkTable := DeleteActiveWorkTableClick;
  FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
  UpdateDeleteWorkTableButton;
  PopupMenuWorkTables.OnPopup := PopupMenuWorkTablesPopup;
  ApplyActiveWorkTableEditMode;

  RefreshPumpsCombo;
  RefreshScalesCombo;
  UpdateUIScale;

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
  if (TabControlDevices.ActiveTab = TabItemMRResults) and
     Assigned(FFrameMRResults) then
    FFrameMRResults.ReloadAndUpdate;
end;

procedure TFrameMainTable.ConnectResultsProcessing(AProceed: TFrameProceed);
begin
  FFrameProceed := AProceed;
  if FFrameMRResults <> nil then
    FFrameMRResults.ConnectProcessingFrame(AProceed);
end;

procedure TFrameMainTable.RefreshSynchronizedResults(Sender: TObject);
begin
  RefreshMeasurementRunFrame;
  if FFrameMRResults <> nil then
    FFrameMRResults.ReloadAndUpdate;
end;

function TFrameMainTable.GetPointResultError(const ADevice: TDevice;
  const APoint: TDevicePoint): Double;
begin
  Result := NaN;
  if FFrameProceed <> nil then
    Result := FFrameProceed.GetPointResultError(ADevice, APoint);
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
  SetInstrumentalLayoutVisible(LayoutScale, False);
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.SpeedButtonSetFlowRateClick(Sender: TObject);
var
AValue:double;
begin
  if FActiveWorkTable = nil then
    Exit;

  if (FActiveWorkTable.ValueFlowRate = nil) or (FActiveWorkTable.FlowRate = nil) then
    Exit;

  AValue:= FActiveWorkTable.ValueFlowRate.GetDoubleBaseNum(SpinBoxFlowRate.Value,FActiveWorkTable.ValueFlowRate.CurrentDimIndex);
  //if not( SameValue(FActiveWorkTable.FlowRate.ValueSet ,AValue, MinDouble)) then
  FActiveWorkTable.FlowRate.DoFlowRateStart(AValue);
  FActiveWorkTable.ResetSpillageRuntimeValues;
  ProtocolManager.AddMessage(pcAction, psForm, 'SetFlowRate', 'Пользователь задал расход', Format('Q=%.3f', [AValue]));
  ProtocolManager.AddMessage(pcAction, psForm, 'ResetSpillageTimer',
    'Сброшен таймер текущей проливки после задания расхода', FActiveWorkTable.Name);
  UpdateUIFlowRate;
  UpdatePreparedManualPoint;
end;

procedure TFrameMainTable.SpeedButtonStartPumpClick(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;


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
  if FActiveWorkTable = nil then
    Exit;


  if  SameValue(FActiveWorkTable.FlowRate.ValueSet.Value ,SpinBoxFlowRate.Value, MinDouble) then
       Exit;

  if  (LayoutFlowRate.tag=0) or (LayoutFlowRate.tag=3)  then
  begin
    AValue:= FActiveWorkTable.ValueFlowRate.GetDoubleBaseNum(SpinBoxFlowRate.Value,FActiveWorkTable.ValueFlowRate.CurrentDimIndex);
    FActiveWorkTable.FlowRate.DoFlowRateSet(AValue);
    //if FActiveWorkTable.FlowRate.IsStable(StableStatus) then
    //  FActiveWorkTable.FlowRate.Start;
    UpdateUIFlowRate;
    UpdatePreparedManualPoint;
  end;
end;

procedure TFrameMainTable.SpinBoxFreqChange(Sender: TObject);
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.ActivePump = nil) then
    Exit;

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
  miScale.Text := LabelLayoutScale.Text;
  miMain.Text := LabelLayoutMain.Text;
  miMesurment.Text := LabelLayoutMesure.Text;
  miConditions.Text := LabelLayoutConditions.Text;
  miProcedures.Text := LabelLayoutProcedures.Text;

  miFlowRate.IsChecked := LayoutFlowRate.Visible;
  miPump.IsChecked := LayoutPump.Visible;
  miScale.IsChecked := LayoutScale.Visible;
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
  else if AMenuItem = miScale then
    Result := LayoutScale
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
        (Control = LayoutScale) or (Control = LayoutMain) or (Control = LayoutMesure) or
        (Control = LayoutConditions) or (Control = LayoutProcedures)) then
      FInstrumentalVisibleOrder.Add(TLayout(Control));
  end;
end;

procedure TFrameMainTable.Rectangle14Click(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

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
  if FActiveWorkTable = nil then
    Exit;

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
    for Layout in [LayoutFlowRate, LayoutPump, LayoutScale, LayoutMain,
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
  else if ALayout = LayoutScale then
    Result := 'Scale'
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
  else if SameText(AKey, 'Scale') then
    Result := LayoutScale
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
      (ALayout = LayoutScale) or
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
    for Layout in [LayoutFlowRate, LayoutPump, LayoutScale, LayoutMain,
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
  ShowIfVisibleAndNotAdded(LayoutScale);
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
    miAddTable.Enabled := (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil);
  if miAddDeviceChannel <> nil then
    miAddDeviceChannel.Enabled := CanEdit;
  if miAddEtalonChannel <> nil then
    miAddEtalonChannel.Enabled := CanEdit;
  if miSaveWorkTable <> nil then
    miSaveWorkTable.Enabled := CanEdit;
  if ActionAddWorkTable <> nil then
    ActionAddWorkTable.Enabled := (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil);
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
  if ActionScaleAdd <> nil then
    ActionScaleAdd.Enabled := CanEdit;
  if ActionScaleDelete <> nil then
    ActionScaleDelete.Enabled := CanEdit;

end;

procedure TFrameMainTable.UpdateGridPopupActions;
var
  CanEdit: Boolean;
  HasDeviceRow: Boolean;
  HasEtalonRow: Boolean;

begin
  CanEdit := CanEditActiveWorkTable;
  HasDeviceRow := CanEdit and (FActiveWorkTable <> nil) and (GridDevices <> nil) and
    (GridDevices.Row >= 0) and (GridDevices.Row < FActiveWorkTable.DeviceChannels.Count);
  HasEtalonRow := CanEdit and (FActiveWorkTable <> nil) and (GridEtalons <> nil) and
    (GridEtalons.Row >= 0) and (GridEtalons.Row < FActiveWorkTable.EtalonChannels.Count);

  if ActionAddWorkTable <> nil then
    ActionAddWorkTable.Enabled := (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil);
  if ActionSaveWorkTable <> nil then
    ActionSaveWorkTable.Enabled := CanEdit;
  if ActionPumpAdd <> nil then
    ActionPumpAdd.Enabled := CanEdit;
  if ActionPumpDelete <> nil then
    ActionPumpDelete.Enabled := CanEdit;
  if ActionScaleAdd <> nil then
    ActionScaleAdd.Enabled := CanEdit;
  if ActionScaleDelete <> nil then
    ActionScaleDelete.Enabled := CanEdit;
  if ActionAddDeviceChannel <> nil then
    ActionAddDeviceChannel.Enabled := CanEdit;
  if ActionAddEtalonChannel <> nil then
    ActionAddEtalonChannel.Enabled := CanEdit;
  if ActionOpenDeviceSelect <> nil then
    ActionOpenDeviceSelect.Enabled := HasDeviceRow or HasEtalonRow;
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

end;

procedure TFrameMainTable.PopupMenuDevicesGridPopup(Sender: TObject);
begin
  ActivateMeasurementGrid(GridDevices);
  FLastPopupGrid := GridDevices;
  PopupMenuWorkTablesPopup(Sender);
  UpdateGridPopupActions;
  SyncDevicesColumnsMenu;
end;

procedure TFrameMainTable.PopupMenuEtalonsGridPopup(Sender: TObject);
begin
  ActivateMeasurementGrid(GridEtalons);
  FLastPopupGrid := GridEtalons;
  PopupMenuWorkTablesPopup(Sender);
  UpdateGridPopupActions;
  SyncEtalonsColumnsMenu;
end;

procedure TFrameMainTable.DevicesColumnMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  GridColumn: TColumn;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  if MenuItem.ItemsCount > 0 then
    Exit;

  GridColumn := FindGridColumnForMenuItem(GridDevices, MenuItem);
  if GridColumn = nil then
  begin
    MenuItem.IsChecked := False;
    Exit;
  end;

  GridColumn.Visible := not GridColumn.Visible;
  MenuItem.IsChecked := GridColumn.Visible;
  RefreshGridColumns(GridDevices);
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameMainTable.EtalonsColumnMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  GridColumn: TColumn;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  if MenuItem.ItemsCount > 0 then
    Exit;

  GridColumn := FindGridColumnForMenuItem(GridEtalons, MenuItem);
  if GridColumn = nil then
  begin
    MenuItem.IsChecked := False;
    Exit;
  end;

  GridColumn.Visible := not GridColumn.Visible;
  MenuItem.IsChecked := GridColumn.Visible;
  RefreshGridColumns(GridEtalons);
  SaveLayoutSettingsToWorkTable;
end;

function TFrameMainTable.NormalizeColumnCaption(
  const ACaption: string): string;
var
  P: Integer;
begin
  Result := StringReplace(ACaption, #$00A0, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := Trim(Result);
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
  P := Pos(',', Result);
  if P > 0 then
    Result := Trim(Copy(Result, 1, P - 1));
  while (Result <> '') and (Result[Length(Result)] = ':') do
    Delete(Result, Length(Result), 1);
  Result := LowerCase(Trim(Result));
  Result := StringReplace(Result, 'ё', 'е', [rfReplaceAll]);
end;

function TFrameMainTable.FindGridColumnByName(AGrid: TGrid;
  const AColumnName: string): TColumn;
var
  I: Integer;
begin
  Result := nil;
  if (AGrid = nil) or (Trim(AColumnName) = '') then
    Exit;

  for I := 0 to AGrid.ColumnCount - 1 do
    if SameText(AGrid.Columns[I].Name, AColumnName) then
      Exit(AGrid.Columns[I]);
end;

function TFrameMainTable.FindGridColumnForMenuItem(AGrid: TGrid;
  AMenuItem: TMenuItem): TColumn;
var
  I: Integer;
begin
  Result := nil;
  if (AGrid = nil) or (AMenuItem = nil) then
    Exit;

  if Trim(AMenuItem.TagString) <> '' then
  begin
    Result := FindGridColumnByName(AGrid, AMenuItem.TagString);
    if Result <> nil then
      Exit;
  end;

  for I := 0 to AGrid.ColumnCount - 1 do
    if SameText(NormalizeColumnCaption(AGrid.Columns[I].Header),
      NormalizeColumnCaption(AMenuItem.Text)) then
      Exit(AGrid.Columns[I]);
end;

procedure TFrameMainTable.SyncColumnMenuBranch(AParentItem: TMenuItem;
  AGrid: TGrid);
var
  I: Integer;
  MenuItem: TMenuItem;
  GridColumn: TColumn;
begin
  if (AParentItem = nil) or (AGrid = nil) then
    Exit;

  for I := 0 to AParentItem.ItemsCount - 1 do
  begin
    if not (AParentItem.Items[I] is TMenuItem) then
      Continue;
    MenuItem := TMenuItem(AParentItem.Items[I]);
    if MenuItem.ItemsCount > 0 then
    begin
      SyncColumnMenuBranch(MenuItem, AGrid);
      Continue;
    end;

    GridColumn := FindGridColumnForMenuItem(AGrid, MenuItem);
    if GridColumn <> nil then
      MenuItem.IsChecked := GridColumn.Visible
    else
      MenuItem.IsChecked := False;
  end;
end;

procedure TFrameMainTable.SyncDevicesColumnsMenu;
begin
  SyncColumnMenuBranch(MenuItemDevicesColumnsGroup, GridDevices);
end;

procedure TFrameMainTable.SyncEtalonsColumnsMenu;
begin
  SyncColumnMenuBranch(MenuItemEtalonsColumnsGroup, GridEtalons);
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
    AColumns[I].Position := AGrid.Columns[I].Index;
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
  I, J, TargetPosition: Integer;
  Column: TColumn;
begin
  { Restores visibility, width and order saved for the WorkTable grid. }
  if (AGrid = nil) or (Length(AColumns) = 0) then
    Exit;

  AGrid.BeginUpdate;
  try
    for I := 0 to High(AColumns) do
      for J := 0 to AGrid.ColumnCount - 1 do
        if SameText(AGrid.Columns[J].Name, AColumns[I].Name) then
        begin
          Column := AGrid.Columns[J];
          Column.Visible := AColumns[I].Visible;
          if AColumns[I].Width > 0 then
            Column.Width := AColumns[I].Width;
          Break;
        end;

    { Apply positions from left to right so an Index change cannot undo
      positions that have already been restored. }
    for TargetPosition := 0 to AGrid.ColumnCount - 1 do
      for I := 0 to High(AColumns) do
        if AColumns[I].Position = TargetPosition then
        begin
          for J := 0 to AGrid.ColumnCount - 1 do
            if SameText(AGrid.Columns[J].Name, AColumns[I].Name) then
            begin
              AGrid.Columns[J].Index := TargetPosition;
              Break;
            end;
          Break;
        end;
  finally
    AGrid.EndUpdate;
  end;
  AGrid.Repaint;
end;

procedure TFrameMainTable.RefreshGridColumns(AGrid: TGrid);
begin
  { Repaints visible cells after an explicit column-menu action. }
  RefreshGridValues(AGrid, 'column-menu');
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
  if PanelEtalons1 <> nil then
    WorkTable.EtalonsPanelHeight := PanelEtalons1.Height;

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

  if (PanelEtalons1 <> nil) and (WorkTable.EtalonsPanelHeight >= 20) then
    PanelEtalons1.Height := WorkTable.EtalonsPanelHeight;

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
  RefreshGridColumns(GridEtalons);
  SyncEtalonsColumnsMenu;
  ApplyGridColumnsLayout(GridDevices, WorkTable.DevicesGridColumns);
  RefreshGridColumns(GridDevices);
  SyncDevicesColumnsMenu;
  if FFrameProceed <> nil then
  begin
    ApplyGridColumnsLayout(FFrameProceed.GridDataPoints, WorkTable.DataPointsGridColumns);
    RefreshGridColumns(FFrameProceed.GridDataPoints);
  end;
  if FFrameProceed <> nil then
  begin
    ApplyGridColumnsLayout(FFrameProceed.GridResults, WorkTable.ResultsGridColumns);
    RefreshGridColumns(FFrameProceed.GridResults);
  end;

  if Length(WorkTable.DataPointsGridColumns) = 0 then
    EnforceDataPointsColumnsLayout;
  PopupMenuInstrumentalLayOutPopup(PopupMenuInstrumentalLayOut);
end;


procedure TFrameMainTable.Splitter1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;
  SaveActiveWorkTableConfiguration;
end;

{ Saves the current channel collection and grid layout immediately. }
procedure TFrameMainTable.SaveActiveWorkTableConfiguration;
var
  Ini: TCustomIniFile;
  WorkTableIndex: Integer;
  WorkTableSection: string;
begin
  SaveLayoutSettingsToWorkTable;
  if WorkTableManager = nil then
    Exit;

  WorkTableManager.Save;

  { Persist the actual collection sizes explicitly in the selected project.
    Loading is driven by these Count values, so a deleted trailing channel
    cannot be restored from an obsolete channel section. }
  if (FActiveWorkTable = nil) or (WorkTableManager.WorkTables = nil) then
    Exit;

  WorkTableIndex := WorkTableManager.WorkTables.IndexOf(FActiveWorkTable);
  if WorkTableIndex < 0 then
    Exit;

  WorkTableSection := 'WorkTable.' + IntToStr(WorkTableIndex);
  Ini := TProjectSettingsIni.Create(
    GetProjectSettingsFileName,
    STORAGE_TABLE_SETTINGS
  );
  try
    Ini.WriteInteger(
      WorkTableSection + '.Device',
      'Count',
      FActiveWorkTable.DeviceChannels.Count
    );
    Ini.WriteInteger(
      WorkTableSection + '.Etalon',
      'Count',
      FActiveWorkTable.EtalonChannels.Count
    );
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TFrameMainTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveLayoutSettingsToWorkTable;
 // if FWorkTableManager <> nil then
  //  FWorkTableManager.Save;


 // if DataManager <> nil then
 //   DataManager.Save;
end;


procedure TFrameMainTable.PersistChannelEnabled(AWorkTable: TWorkTable; AChannel: TChannel;
  const AKind: string; const AOldEnabled, ANewEnabled: Boolean);
var
  Ini: TCustomIniFile;
  StoragePath: string;
  SectionName: string;
begin
  if (AWorkTable = nil) or (AChannel = nil) then
    Exit;

  StoragePath := GetProjectSettingsFileName;

  if SameText(AKind, 'Etalon') then
    SectionName := Format('WorkTables/%s/EtalonChannels/%s', [AWorkTable.UUID, AChannel.UUID])
  else
    SectionName := Format('WorkTables/%s/DeviceChannels/%s', [AWorkTable.UUID, AChannel.UUID]);

  Ini := TProjectSettingsIni.Create(StoragePath, STORAGE_TABLE_SETTINGS);
  try
    Ini.WriteBool(SectionName, 'Enabled', ANewEnabled);
    Ini.UpdateFile;
    ProtocolManager.AddMessage(pcAction, psForm, 'ChannelEnabledChanged',
      'Изменён флаг включения канала рабочего стола',
      Format('WorkTableUUID=%s; ChannelKind=%s; ChannelUUID=%s; OldEnabled=%s; NewEnabled=%s; StoragePath=%s; SaveResult=Success',
        [AWorkTable.UUID, AKind, AChannel.UUID, BoolToStr(AOldEnabled, True),
         BoolToStr(ANewEnabled, True), StoragePath]));
  finally
    Ini.Free;
  end;

  // The channel flag is already persisted above. A full WorkTableManager.Save
  // rewrites the whole project and caused a visible pause on every checkbox click.
end;

procedure TFrameMainTable.MarkChannelDeviceModified(AChannel: TChannel);
var
  RepoDevice: TDevice;
  FoundRepo: TDeviceRepository;
begin
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or (AChannel.FlowMeter.Device = nil) then
    Exit;

  AChannel.State := osModified;
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
    FFrameProceed.UpdateGridDataPointsHeaders(WorkTable.TableFlow.ValueVolume.GetDimName, WorkTable.TableFlow.ValueVolumeFlow.GetDimName);

  UpdateUIFromValues;
  if FFrameChannelProperties <> nil then
    FFrameChannelProperties.UpdateFlowUnitPresentation;

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
    ActionAddWorkTable.Enabled := (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil);
  if ActionAddDeviceChannel <> nil then
    ActionAddDeviceChannel.Enabled := CanEdit;
  if ActionAddEtalonChannel <> nil then
    ActionAddEtalonChannel.Enabled := CanEdit;
  if ActionSaveWorkTable <> nil then
    ActionSaveWorkTable.Enabled := CanEdit;

  if TabControlWorkTables <> nil then
    // Старое общее меню не должно открываться на пустой области панели вкладок.
    TabControlWorkTables.PopupMenu := nil;

  if Label23 <> nil then
    Label23.PopupMenu := nil;

  if Label30 <> nil then
    Label30.PopupMenu := nil;

  if GridDevices <> nil then
  begin
    GridDevices.EditorMode := False;
    GridDevices.PopupMenu := PopupMenuDevicesGrid;
    if CanEdit then
    begin
      if StringColumnDeviceSerial1 <> nil then
        StringColumnDeviceSerial1.PopupMenu := PopupMenu1;
      GridDevices.Options := GridDevices.Options + [TGridOption.Editing];
    end
    else
    begin
      if StringColumnDeviceSerial1 <> nil then
        StringColumnDeviceSerial1.PopupMenu := nil;
      { Editing remains available for ValueBefore/ValueAfter of manual visual
        devices. GridDevicesCellClick keeps every other column read-only. }
      GridDevices.Options := GridDevices.Options + [TGridOption.Editing];
      GridDevices.ReadOnly := True;
    end;
  end;

  if GridEtalons <> nil then
  begin
    GridEtalons.EditorMode := False;
    GridEtalons.PopupMenu := PopupMenuEtalonsGrid;
    if CanEdit then
      GridEtalons.Options := GridEtalons.Options + [TGridOption.Editing]
    else
      GridEtalons.Options := GridEtalons.Options - [TGridOption.Editing];
  end;

  if ToolBar1 <> nil then
    ToolBar1.PopupMenu := nil;

  if ToolBarEtalons1 <> nil then
    ToolBarEtalons1.PopupMenu := nil;
end;

function TFrameMainTable.CanDeleteActiveWorkTable: Boolean;
var
  HydraulicState: EHydraulicLineState;
  HydraulicError: TErrorInfo;
  OperationID: Int64;
  PointUUID: string;
  PointIndex: Integer;
  TargetFlow: Double;
  Configuration: RWorkTableHydraulicConfiguration;
  HydraulicRange: RWorkTableHydraulicRange;
begin
  Result := IsManagedWorkTable(FActiveWorkTable) and
    (WorkTableManager.WorkTables.Count > 1);
  if not Result then
    Exit;

  FActiveWorkTable.GetHydraulicStateSnapshot(HydraulicState, HydraulicError,
    OperationID, PointUUID, PointIndex, TargetFlow, Configuration,
    HydraulicRange);
  Result := not IsMeasurementActive(FActiveWorkTable) and
    not (FActiveWorkTable.State in [swtSTARTMONITOR, swtSTARTMONITORWAIT,
      swtMONITOR]) and
    not (HydraulicState in [hlsSelecting, hlsSettingUp]);
end;

procedure TFrameMainTable.UpdateDeleteWorkTableButton;
begin
  if FFrameWorkTableProperties <> nil then
    FFrameWorkTableProperties.UpdateDeleteButtonEnabled(
      CanDeleteActiveWorkTable);
end;

{ Проверяет запрос UI и безопасно удаляет активный стол строго по UUID. }
procedure TFrameMainTable.DeleteActiveWorkTableClick(Sender: TObject);
var
  DeletedWorkTable, NewActiveWorkTable: TWorkTable;
  DeletedUUID, DeletedText: string;
  DeletedIndex: Integer;
  ObserverHost: IWorkTableObserverHost;
begin
  if not CanDeleteActiveWorkTable then
    Exit;

  DeletedWorkTable := FActiveWorkTable;
  DeletedUUID := DeletedWorkTable.UUID;
  DeletedText := DeletedWorkTable.Text;
  DeletedIndex := WorkTableManager.WorkTables.IndexOf(DeletedWorkTable);

  if MessageDlg(Format('Удалить рабочий стол «%s»?'#13#10#13#10 +
    'Будут удалены его каналы и настройки.', [DeletedText]),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0,
    TMsgDlgBtn.mbNo) <> mrYes then
    Exit;

  if DeletedIndex + 1 < WorkTableManager.WorkTables.Count then
    NewActiveWorkTable := WorkTableManager.WorkTables[DeletedIndex + 1]
  else
    NewActiveWorkTable := WorkTableManager.WorkTables[DeletedIndex - 1];

  { Move the shared UI to the replacement first. No tab is destroyed: the
    permanent designer tab is simply rebound by SelectWorkTable. }
  SelectWorkTable(NewActiveWorkTable);
  FDeletingWorkTable := True;
  FDeletingWorkTablePointer := Pointer(DeletedWorkTable);
  try
    DeletedWorkTable.CancelPendingNotifications;
    if Supports(Owner, IWorkTableObserverHost, ObserverHost) then
      ObserverHost.DetachWorkTableObservers(DeletedWorkTable);
    DeletedWorkTable.ClearObservers;
    if not WorkTableManager.DeleteWorkTableByUUID(DeletedUUID) then
    begin
      if Supports(Owner, IWorkTableObserverHost, ObserverHost) then
        ObserverHost.AttachWorkTableObservers(DeletedWorkTable);
      SelectWorkTable(DeletedWorkTable);
      Exit;
    end;
    SyncWorkTableTabs;
    WorkTableManager.Save;
  finally
    FDeletingWorkTablePointer := nil;
    FDeletingWorkTable := False;
  end;
  UpdateDeleteWorkTableButton;
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

function NormalizeWorkTableUUID(const AUUID: string): string;
begin
  Result := UpperCase(Trim(AUUID));
end;

function TFrameMainTable.GetWorkTableTabUUID(ATab: TTabItem): string;
const
  Prefix = 'WORKTABLE:';
begin
  { TagString is the only persistent link between a work-table tab and its model. }
  Result := '';
  if (ATab = nil) or not StartsText(Prefix, ATab.TagString) then
    Exit;
  Result := NormalizeWorkTableUUID(Copy(ATab.TagString,
    Length(Prefix) + 1, MaxInt));
end;

function TFrameMainTable.FindManagedWorkTableByUUID(
  const AUUID: string): TWorkTable;
var
  I: Integer;
  Key: string;
begin
  Result := nil;
  Key := NormalizeWorkTableUUID(AUUID);
  if (Key = '') or (WorkTableManager = nil) or
     (WorkTableManager.WorkTables = nil) then Exit;
  for I := 0 to WorkTableManager.WorkTables.Count - 1 do
    if (WorkTableManager.WorkTables[I] <> nil) and
       (NormalizeWorkTableUUID(WorkTableManager.WorkTables[I].UUID) = Key) then
      Exit(WorkTableManager.WorkTables[I]);
end;

function TFrameMainTable.ResolveWorkTableForTab(ATab: TTabItem): TWorkTable;
var
  Key: string;
begin
  { Always resolve against the manager's current objects, never cached models. }
  Key := GetWorkTableTabUUID(ATab);
  Result := FindManagedWorkTableByUUID(Key);
  if Result <> nil then
  begin
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcInfo, psWorkTable,
        'WorkTableTabResolveSuccess', 'WorkTableUUID=' + Key, Result.Name);
  end
  else if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcError, psWorkTable,
      'WorkTableTabResolveFailed', 'WorkTableUUID=' + Key, '');
end;

function TFrameMainTable.IsLiveWorkTableTab(ATab: TTabItem): Boolean;
var
  I: Integer;
begin
  { Validate the pointer against TTabControl before dereferencing the tab. }
  Result := False;
  if (ATab = nil) or (TabControlWorkTables = nil) then Exit;
  for I := 0 to TabControlWorkTables.TabCount - 1 do
    if TabControlWorkTables.Tabs[I] = ATab then
      Exit(True);
end;

function TFrameMainTable.IsControlInsideTab(AControl: TFmxObject;
  ATab: TTabItem): Boolean;
var
  ParentObject: TFmxObject;
begin
  { A tab can insert an internal FMX content object between itself and a child. }
  Result := False;
  if (AControl = nil) or (ATab = nil) then
    Exit;

  ParentObject := AControl;
  while ParentObject <> nil do
  begin
    if ParentObject = ATab then
      Exit(True);
    ParentObject := ParentObject.Parent;
  end;
end;

function TFrameMainTable.FindWorkTableTabByUUID(
  const AWorkTableUUID: string): TTabItem;
var
  Key: string;
begin
  Result := nil;
  Key := NormalizeWorkTableUUID(AWorkTableUUID);
  if (Key <> '') and IsLiveWorkTableTab(TabItemWorkTable1) and
     (GetWorkTableTabUUID(TabItemWorkTable1) = Key) then
    Result := TabItemWorkTable1;
end;

function TFrameMainTable.FindWorkTableByTab(ATab: TTabItem): TWorkTable;
begin
  Result := ResolveWorkTableForTab(ATab);
end;

function TFrameMainTable.ActiveTabWorkTable: TWorkTable;
begin
  Result := nil;
  if (TabControlWorkTables = nil) or (WorkTableManager = nil) or
     (WorkTableManager.WorkTables = nil) then
    Exit;
  Result := ResolveWorkTableForTab(TabControlWorkTables.ActiveTab);
  if (Result <> nil) and (WorkTableManager.WorkTables.IndexOf(Result) < 0) then
    Result := nil;
end;

function TFrameMainTable.EnsureWorkTableTab(
  AWorkTable: TWorkTable): TTabItem;
var
  Key: string;
begin
  Result := nil;
  if not IsManagedWorkTable(AWorkTable) or
     not IsLiveWorkTableTab(TabItemWorkTable1) then
    Exit;
  Key := NormalizeWorkTableUUID(AWorkTable.UUID);
  if Key = '' then
    Exit;

  { The designer-created tab is permanent. Switching only changes the model
    identity and caption associated with this one visual surface. }
  Result := TabItemWorkTable1;
  Result.TagString := 'WORKTABLE:' + Key;
  Result.Text := AWorkTable.Text;
  Result.Visible := True;
  FWorkTableTabs.Clear;
  FWorkTableTabs.AddOrSetValue(Key, Result);
end;

procedure TFrameMainTable.RemoveWorkTableTabs(
  const ATabs: TList<TTabItem>);
var
  I: Integer;
  Tab: TTabItem;
  Key: string;
  OldParent: TFmxObject;
begin
  if (ATabs = nil) or (ATabs.Count = 0) then
    Exit;

  FWorkTableTabs.Clear;
  for I := 0 to ATabs.Count - 1 do
  begin
    Tab := ATabs[I];
    if not IsLiveWorkTableTab(Tab) then
      Continue;
    Key := GetWorkTableTabUUID(Tab);
    if (PanelControlWorkTables <> nil) and
       IsControlInsideTab(PanelControlWorkTables, Tab) then
    begin
      OldParent := PanelControlWorkTables.Parent;
      { Панель отсоединяется до удаления вкладки; новый parent задаст Activate. }
      PanelControlWorkTables.Parent := nil;
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcInfo, psWorkTable,
          'WorkTablePanelDetachedBeforeTabDelete', Format(
          'WorkTableUUID=%s; OldParent=%p; NewParent=%p; TabPointer=%p',
          [Key, Pointer(OldParent), Pointer(PanelControlWorkTables.Parent),
           Pointer(Tab)]), '');
    end;
    Tab.Parent := nil;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcInfo, psWorkTable, 'WorkTableTabRemoved',
        Format('WorkTableUUID=%s; TabPointer=%p', [Key, Pointer(Tab)]), '');
    Tab.Free;
  end;
end;

procedure TFrameMainTable.SyncWorkTableTabs;
var
  I: Integer;
  Tab: TTabItem;
  TabsToRemove: TList<TTabItem>;
  ActiveWorkTable: TWorkTable;
begin
  if FSyncingWorkTableTabs or (TabControlWorkTables = nil) then
    Exit;
  FSyncingWorkTableTabs := True;
  TabsToRemove := TList<TTabItem>.Create;
  try
    { Remove leftovers produced by the former one-tab-per-work-table
      implementation. The designer tab is the only persistent tab. }
    for I := 0 to TabControlWorkTables.TabCount - 1 do
    begin
      Tab := TabControlWorkTables.Tabs[I];
      if Tab <> TabItemWorkTable1 then
        TabsToRemove.Add(Tab);
    end;
    RemoveWorkTableTabs(TabsToRemove);

    ActiveWorkTable := nil;
    if (WorkTableManager <> nil) and
       IsManagedWorkTable(WorkTableManager.ActiveWorkTable) then
      ActiveWorkTable := WorkTableManager.ActiveWorkTable
    else if IsManagedWorkTable(FActiveWorkTable) then
      ActiveWorkTable := FActiveWorkTable;

    FWorkTableTabs.Clear;
    if ActiveWorkTable <> nil then
      EnsureWorkTableTab(ActiveWorkTable)
    else
    begin
      TabItemWorkTable1.TagString := '';
      TabItemWorkTable1.Text := '';
    end;
    TabControlWorkTables.ActiveTab := TabItemWorkTable1;
  finally
    TabsToRemove.Free;
    FSyncingWorkTableTabs := False;
  end;
  UpdateDeleteWorkTableButton;
end;

procedure TFrameMainTable.ActivateWorkTable(AWorkTable: TWorkTable);
var
  I, ActiveCount, TabCountBefore: Integer;
  OldFrameActive, OldManagerActive: TWorkTable;
  ActiveTab: TTabItem;
  OldPanelParent: TFmxObject;
  ActiveTabText: string;
  InvariantsValid: Boolean;
begin
  { This is the single path that performs a complete model and UI activation. }
  if not IsManagedWorkTable(AWorkTable) then Exit;
  OldFrameActive := FActiveWorkTable;
  OldManagerActive := WorkTableManager.ActiveWorkTable;
  TabCountBefore := TabControlWorkTables.TabCount;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcInfo, psWorkTable, 'WorkTableActivationBegin',
      'WorkTableUUID=' + NormalizeWorkTableUUID(AWorkTable.UUID), AWorkTable.Name);

  if IsManagedWorkTable(FActiveWorkTable) and (FActiveWorkTable <> AWorkTable) then
    SaveLayoutSettingsToWorkTable;
  for I := 0 to WorkTableManager.WorkTables.Count - 1 do
    if WorkTableManager.WorkTables[I] <> nil then
      WorkTableManager.WorkTables[I].IsActive := False;
  WorkTableManager.ActiveWorkTable := AWorkTable;
  FActiveWorkTable := AWorkTable;
  AWorkTable.IsActive := True;

  ActiveTab := EnsureWorkTableTab(AWorkTable);
  if (PanelControlWorkTables <> nil) and IsLiveWorkTableTab(ActiveTab) then
  begin
    OldPanelParent := PanelControlWorkTables.Parent;
    if not IsControlInsideTab(PanelControlWorkTables, ActiveTab) then
      PanelControlWorkTables.Parent := ActiveTab;
    PanelControlWorkTables.Align := TAlignLayout.Client;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcInfo, psWorkTable,
        'WorkTablePanelAttachedToActiveTab', Format(
        'WorkTableUUID=%s; TabPointer=%p; OldParent=%p; NewParent=%p; TabCount=%d',
        [AWorkTable.UUID, Pointer(ActiveTab), Pointer(OldPanelParent),
         Pointer(PanelControlWorkTables.Parent), TabControlWorkTables.TabCount]), '');
  end;

  if FFrameMeasurementRun <> nil then FFrameMeasurementRun.ActiveWorkTable := AWorkTable;
  if FFrameMRResults <> nil then FFrameMRResults.ActiveWorkTable := AWorkTable;
  SetValues;
  LoadLayoutSettingsFromWorkTable;
  RefreshPumpsCombo;
  RefreshScalesCombo;
  UpdateUIScale;
  UpdateUIFromValues;
  UpdateGrids;
  if FFrameChannelProperties <> nil then FFrameChannelProperties.LoadFromChannel(nil);
  if FFrameFlowMeterProperties <> nil then FFrameFlowMeterProperties.FlowMeter := nil;
  if FFrameWorkTableProperties <> nil then FFrameWorkTableProperties.LoadFromWorkTable(AWorkTable);
  RefreshFlowGraphChannels('ActivateWorkTable');
  if FGraphsWorkspace <> nil then FGraphsWorkspace.RefreshEnabledSources;
  OnChangeState(AWorkTable.State);
  ApplyActiveWorkTableEditMode;
  UpdateForm;

  ActiveCount := 0;
  for I := 0 to WorkTableManager.WorkTables.Count - 1 do
    if (WorkTableManager.WorkTables[I] <> nil) and
       WorkTableManager.WorkTables[I].IsActive then Inc(ActiveCount);
  ActiveTab := TabControlWorkTables.ActiveTab;
  ActiveTabText := '';
  if ActiveTab <> nil then
    ActiveTabText := ActiveTab.Text;
  InvariantsValid := (FActiveWorkTable = AWorkTable) and
    (WorkTableManager.ActiveWorkTable = AWorkTable) and AWorkTable.IsActive and
    (ActiveCount = 1) and
    (GetWorkTableTabUUID(ActiveTab) = NormalizeWorkTableUUID(AWorkTable.UUID));
  if Assigned(ProtocolManager) then
  begin
    if not InvariantsValid then
      ProtocolManager.AddMessage(pcError, psWorkTable,
        'WorkTableActivationInvariantFailed',
        Format('WorkTableUUID=%s; ActiveCount=%d; ActiveTabUUID=%s',
        [AWorkTable.UUID, ActiveCount, GetWorkTableTabUUID(ActiveTab)]), AWorkTable.Name);
    ProtocolManager.AddMessage(pcInfo, psWorkTable, 'WorkTableActivationDone',
      Format('TabUUID=%s; TabText=%s; WorkTableUUID=%s; ID=%d; Name=%s; Text=%s; OldFrame=%p; NewFrame=%p; OldManager=%p; NewManager=%p; TabCountBefore=%d; TabCountAfter=%d',
      [GetWorkTableTabUUID(ActiveTab), ActiveTabText, AWorkTable.UUID,
       AWorkTable.ID, AWorkTable.Name, AWorkTable.Text, Pointer(OldFrameActive),
       Pointer(FActiveWorkTable), Pointer(OldManagerActive),
       Pointer(WorkTableManager.ActiveWorkTable), TabCountBefore,
       TabControlWorkTables.TabCount]), '');
  end;
end;

procedure TFrameMainTable.ActivateWorkTableFromTab(ATab: TTabItem);
var
  ManagedWorkTable: TWorkTable;
begin
  ManagedWorkTable := ResolveWorkTableForTab(ATab);
  if ManagedWorkTable <> nil then
    ActivateWorkTable(ManagedWorkTable);
end;

procedure TFrameMainTable.SelectWorkTable(AWorkTable: TWorkTable);
begin
  if not IsManagedWorkTable(AWorkTable) then
    Exit;
  { Keep the existing active-work-table mechanism; only reuse the permanent
    visual tab instead of selecting or creating a tab per model. }
  EnsureWorkTableTab(AWorkTable);
  FChangingWorkTableTab := True;
  try
    TabControlWorkTables.ActiveTab := TabItemWorkTable1;
  finally
    FChangingWorkTableTab := False;
  end;
  ActivateWorkTable(AWorkTable);
end;

procedure TFrameMainTable.UpdateWorkTableTabCaption(AWorkTable: TWorkTable);
begin
  if IsManagedWorkTable(AWorkTable) and (AWorkTable = FActiveWorkTable) and
     IsLiveWorkTableTab(TabItemWorkTable1) then
    TabItemWorkTable1.Text := AWorkTable.Text;
end;

procedure TFrameMainTable.TabControlWorkTablesChange(Sender: TObject);
var
  Tab, ActualTab: TTabItem;
  ManagedWorkTable: TWorkTable;
  TabText: string;
begin
  if FChangingWorkTableTab or FSyncingWorkTableTabs or
     (TabControlWorkTables = nil) then Exit;
  Tab := TabControlWorkTables.ActiveTab;
  TabText := '';
  if Tab <> nil then
    TabText := Tab.Text;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcInfo, psWorkTable, 'WorkTableTabChangeBegin',
      'WorkTableUUID=' + GetWorkTableTabUUID(Tab), TabText);
  ManagedWorkTable := ResolveWorkTableForTab(Tab);
  if ManagedWorkTable = nil then
  begin
    ActualTab := nil;
    if IsManagedWorkTable(FActiveWorkTable) then
      ActualTab := FindWorkTableTabByUUID(FActiveWorkTable.UUID);
    if ActualTab <> nil then
    begin
      FChangingWorkTableTab := True;
      try
        TabControlWorkTables.ActiveTab := ActualTab;
      finally
        FChangingWorkTableTab := False;
      end;
    end;
    Exit;
  end;
  ActivateWorkTable(ManagedWorkTable);
end;

procedure TFrameMainTable.InitTables;
var
  TableCount: Integer;
  WorkTable: TWorkTable;
  UnitIndex, WorkTableIndex: Integer;
begin
  TableCount := 0;
  if (WorkTableManager <> nil) and (WorkTableManager.WorkTables <> nil) then
    TableCount := WorkTableManager.WorkTables.Count;

  if (WorkTableManager <> nil) and IsManagedWorkTable(WorkTableManager.ActiveWorkTable) then
    FActiveWorkTable := WorkTableManager.ActiveWorkTable
  else
    FActiveWorkTable := GetWorkTableByIndex(0);

  if (WorkTableManager <> nil) and (FActiveWorkTable <> nil) then
    WorkTableManager.ActiveWorkTable := FActiveWorkTable;

  SyncWorkTableTabs;
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
    RefreshScalesCombo;
    UpdateUIScale;
  end
  else
  begin
    RefreshPumpsCombo;
    RefreshScalesCombo;
    UpdateUIScale;
  end ;

  if FFrameMeasurementRun <> nil then
    FFrameMeasurementRun.ActiveWorkTable := FActiveWorkTable;

  if FFrameMRResults <> nil then
    FFrameMRResults.ActiveWorkTable := FActiveWorkTable;

  if FFrameProtocol = nil then
  begin
    FFrameProtocol := TFrameProtocol.Create(Self);
    FFrameProtocol.Parent := LayoutProtocolHost;
    FFrameProtocol.Align := TAlignLayout.Client;
  end;

  RefreshFlowGraphChannels('SyncFlowGraphWorkTable');

  WorkTable := FActiveWorkTable;
  if WorkTable <> nil then
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

  UpdateGrids;
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
      AChannel.InitWorkRangesFromFlowMeter;

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
  WorkTable := WorkTableManager.WorkTables[WorkTableManager.WorkTables.Count - 1];
  InitTables;
  SelectWorkTable(WorkTable);

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
      AChannel.InitWorkRangesFromFlowMeter;
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
      AChannel.InitWorkRangesFromFlowMeter;
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

  if FLastPopupGrid = GridEtalons then
  begin
    Row := GridEtalons.Row;
    if (Row < 0) or (Row >= WorkTable.EtalonChannels.Count) then
      Exit;

    Ch := WorkTable.EtalonChannels[Row];
  end
  else
  begin
    Row := GridDevices.Row;
    if (Row < 0) or (Row >= WorkTable.DeviceChannels.Count) then
      Exit;

    Ch := WorkTable.DeviceChannels[Row];
  end;

  if Ch = nil then
    Exit;

  FLastPopupGrid := nil;
  SelectDeviceForChannel(Ch);
end;


function TFrameMainTable.GetNewInstrumentName: string;
begin
  Result := Trim(FNewInstrumentName);
  if Result = '' then
    Result := '1';
end;

procedure TFrameMainTable.ActionPumpAddExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

        FActiveWorkTable.AddPump(GetNewInstrumentName);
        RefreshPumpsCombo;
        RefreshScalesCombo;
        UpdateUIPump;
        UpdateUIScale;
end;

procedure TFrameMainTable.ActionPumpDeleteExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

         if FActiveWorkTable.ActivePump=nil then
         Exit;

        FActiveWorkTable.RemovePump(FActiveWorkTable.ActivePump);
        RefreshPumpsCombo;
        RefreshScalesCombo;
        UpdateUIPump;
        UpdateUIScale;
end;


procedure TFrameMainTable.ActionScaleAddExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

  FActiveWorkTable.AddScale(GetNewInstrumentName);
  RefreshScalesCombo;
  UpdateUIScale;
end;

procedure TFrameMainTable.ActionScaleDeleteExecute(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

  if FActiveWorkTable.ActiveScale = nil then
    Exit;

  FActiveWorkTable.RemoveScale(FActiveWorkTable.ActiveScale);
  RefreshScalesCombo;
  UpdateUIScale;
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
      AChannel.InitWorkRangesFromFlowMeter;

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
          LinkedChannel.InitWorkRangesFromFlowMeter;

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
    SaveActiveWorkTableConfiguration;
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
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
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
  SaveActiveWorkTableConfiguration;
end;

procedure TFrameMainTable.ActionAddEtalonChannelExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  ChannelIndex: Integer;
begin
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
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
  SaveActiveWorkTableConfiguration;
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

   MeasurementRun.InvalidatePreparedPoints;
   MeasurementRun.RebuildMeasurementPoints;
   RefreshMeasurementRunFrame;

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
    begin
      // Correction tables of type cctMeterValueCoef belong to the active
      // coefficient value, not to ValueFlow.  Open the settings form on the
      // exact runtime TMeterValue which was populated from the device table.
      MV := WorkTable.DeviceChannels[Row].FlowMeter.ValueCoef;
      if MV = nil then
        MV := WorkTable.DeviceChannels[Row].FlowMeter.ValueFlow;
    end;
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
  if (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.Device <> nil) and
     (AClipboard.Snapshot.FlowMeter <> nil) then
  begin
    AClipboard.Snapshot.FlowMeter.Device := TDevice.Create;
    AClipboard.Snapshot.FlowMeter.Device.AssignWithoutMeasurementHistory(
      AChannel.FlowMeter.Device);
    AClipboard.Snapshot.FlowMeter.Device.SerialNumber := AChannel.FlowMeter.Device.SerialNumber;
  end;
end;

procedure TFrameMainTable.LoadChannelFromClipboard(AChannel: TChannel;
  const AClipboard: TChannelClipboardData);
var
  OldDevice, NewDevice: TDevice;
  OldFlowMeter: TFlowMeter;
  OldDeviceUUID, NewDeviceUUID: string;
begin
  if (AChannel = nil) or not AClipboard.HasData or (AClipboard.Snapshot = nil) then
    Exit;

  OldFlowMeter := AChannel.FlowMeter;
  OldDevice := nil;
  OldDeviceUUID := AChannel.DeviceUUID;
  if OldFlowMeter <> nil then
    OldDevice := OldFlowMeter.Device;

  CloneSelectedChannelDevice(AClipboard.Snapshot, AChannel);
  NewDevice := nil;
  NewDeviceUUID := '';
  if AChannel.FlowMeter <> nil then
  begin
    NewDevice := AChannel.FlowMeter.Device;
    NewDeviceUUID := AChannel.FlowMeter.DeviceUUID;
  end;
  if (FFrameProceed <> nil) and (FActiveWorkTable <> nil) and
     (FActiveWorkTable.DeviceChannels.IndexOf(AChannel) >= 0) and
     not SameText(Trim(OldDeviceUUID), Trim(NewDeviceUUID)) then
  begin
    if OldDevice <> nil then
      FFrameProceed.RemoveProcessingDevice(OldDevice);
    if NewDevice <> nil then
      FFrameProceed.AddProcessingDevice(NewDevice);
  end;
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

procedure TFrameMainTable.CloneSelectedChannelDevice(ASource, ADest: TChannel);
var
  SourceDevice: TDevice;
  ClonedDevice: TDevice;
  ClonedDeviceUUID: string;
begin
  if (ASource = nil) or (ADest = nil) then
    Exit;

  ADest.AssignFlowMeterFrom(ASource, FActiveWorkTable, True);

  SourceDevice := nil;
  ClonedDevice := nil;
  if ASource.FlowMeter <> nil then
    SourceDevice := ASource.FlowMeter.Device;
  if ADest.FlowMeter <> nil then
    ClonedDevice := ADest.FlowMeter.Device;

  { AssignWithoutMeasurementHistory copies the source UUID. A channel copy must
    receive its own UUID or later synchronization will replace another channel. }
  if (SourceDevice <> nil) and (ClonedDevice <> nil) and
     SameText(Trim(SourceDevice.UUID), Trim(ClonedDevice.UUID)) then
  begin
    ClonedDeviceUUID := TGUID.NewGuid.ToString;
    ClonedDevice.UUID := ClonedDeviceUUID;
    ADest.FlowMeter.DeviceUUID := ClonedDeviceUUID;
    ADest.DeviceUUID := ClonedDeviceUUID;
  end;

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
  SaveActiveWorkTableConfiguration;
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

  if MessageDlg(
       'Заполнить все строки приборов по выбранной?',
       TMsgDlgType.mtConfirmation,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) <> mrYes then
    Exit;

  for Ch in FActiveWorkTable.DeviceChannels do
    if (Ch <> Src) and Ch.Enabled then
    begin



      CloneSelectedChannelDevice(Src, Ch);
      if (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
        PersistDeviceAsync(Ch.FlowMeter.Device) //Сохранение прибора
      else
        AttachType(Ch, SourceType, FoundRepo, True);

  //  If (Ch.FlowMeter.Device<>nil) and (Src.FlowMeter.Device<>nil) then
  //    Ch.FlowMeter.Device.AttachDN(Src.FlowMeter.Device.DN, SourceType);



      Ch.FlowMeter.RebindCalculatedValues;

    end;

  UpdateGrids;
  SaveActiveWorkTableConfiguration;
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
var
  Pump: TPump;
  Changed: Boolean;
begin
  if FActiveWorkTable = nil then
    Exit;

  if (LayoutPump.Tag = 0) or (LayoutPump.Tag = 3) then
  begin
    LayoutPump.Tag := 0;
    Pump := nil;
    if (ComboBoxPumps.ItemIndex >= 0) and
       (ComboBoxPumps.ItemIndex < ComboBoxPumps.Items.Count) and
       (ComboBoxPumps.Items.Objects[ComboBoxPumps.ItemIndex] is TPump) then
      Pump := TPump(ComboBoxPumps.Items.Objects[ComboBoxPumps.ItemIndex]);
    Changed := (Pump <> nil) and (FActiveWorkTable.Pumps <> nil) and
      (FActiveWorkTable.Pumps.IndexOf(Pump) >= 0) and
      (FActiveWorkTable.ActivePump <> Pump);
    if Changed then
    begin
      FActiveWorkTable.ActivePump := Pump;
      UpdateUIPump;
      if FFrameWorkTableProperties <> nil then
        FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
      if WorkTableManager <> nil then
        WorkTableManager.Save;
    end;
  end;
end;

procedure TFrameMainTable.ComboBoxPumpsClick(Sender: TObject);
begin
  ComboBoxPumps.Tag:=2;
end;

procedure TFrameMainTable.ComboBoxScalesChange(Sender: TObject);
begin
  if (FActiveWorkTable = nil) or not ((LayoutScale.Tag = 0) or (LayoutScale.Tag = 3)) then
    Exit;

  LayoutScale.Tag := 0;
  FActiveWorkTable.SetActiveScale(ComboBoxScales.Text);
  if FFrameWorkTableProperties <> nil then
    FFrameWorkTableProperties.LoadFromWorkTable(FActiveWorkTable);
  UpdateUIScale;
end;

procedure TFrameMainTable.ButtonScaleTareClick(Sender: TObject);
begin
  if (FActiveWorkTable = nil) or
     (FActiveWorkTable.ActiveScale = nil) then
    Exit;

  if Assigned(FOnScaleTareRequest) then
    FOnScaleTareRequest(Self, FActiveWorkTable.ActiveScale.Name);
end;

procedure TFrameMainTable.ButtonScaleDrainClick(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

  FActiveWorkTable.DoScaleDrain;
  UpdateUIScale;
end;

procedure TFrameMainTable.ComboBoxUnitsChange(Sender: TObject);
var
  UnitName: string;
  QuantityUnitName: string;
begin
  UnitName := Trim(ComboEditUnits.Text);
  if UnitName = '' then
  begin
    UpdateUIScale;
    Exit;
  end;

  if IsScaleUnit(UnitName) then
  begin
    UpdateUIScale;
    Exit;
  end;

  QuantityUnitName := ResolveQuantityUnitByFlowUnit(UnitName);
  SetDim(UnitName, QuantityUnitName);
  UpdateUIFromValues;
  UpdateGrids;
  UpdateUIScale;

  GridDevices.SetFocus;
end;

procedure TFrameMainTable.ActionDeleteDeviceExecute(Sender: TObject);
var
  Src: TChannel;
  SelectedRow: Integer;
begin
  if FActiveWorkTable = nil then
    Exit;

  Src := GetSelectedChannel(FActiveWorkTable.DeviceChannels, GridDevices);
  if (FFrameProceed <> nil) and (Src <> nil) and (Src.FlowMeter <> nil) then
    FFrameProceed.RemoveProcessingDevice(Src.FlowMeter.Device);

  if FFrameChannelProperties <> nil then
    FFrameChannelProperties.DetachChannel(Src);
  if FFlowMeterPropertiesChannel = Src then
    FFlowMeterPropertiesChannel := nil;

  if FActiveWorkTable.DeleteChannel(Src) then
  begin
    UpdateGrids;
    SelectedRow := GridDevices.Row;
    if FFrameChannelProperties <> nil then
    begin
      if (SelectedRow >= 0) and
         (SelectedRow < FActiveWorkTable.DeviceChannels.Count) then
        FFrameChannelProperties.LoadFromChannel(
          FActiveWorkTable.DeviceChannels[SelectedRow])
      else
        FFrameChannelProperties.LoadFromChannel(nil);
    end;
    SaveActiveWorkTableConfiguration;
  end;
end;


procedure TFrameMainTable.ActionDeleteEtalonsExecute(Sender: TObject);
var
  Src: TChannel;
  SelectedRow: Integer;
begin
  if FActiveWorkTable = nil then
    Exit;

  Src := GetSelectedChannel(FActiveWorkTable.EtalonChannels, GridEtalons);

  if FFrameChannelProperties <> nil then
    FFrameChannelProperties.DetachChannel(Src);
  if FFlowMeterPropertiesChannel = Src then
    FFlowMeterPropertiesChannel := nil;

  if FActiveWorkTable.DeleteChannel(Src) then
  begin
    UpdateGrids;
    SelectedRow := GridEtalons.Row;
    if FFrameChannelProperties <> nil then
    begin
      if (SelectedRow >= 0) and
         (SelectedRow < FActiveWorkTable.EtalonChannels.Count) then
        FFrameChannelProperties.LoadFromChannel(
          FActiveWorkTable.EtalonChannels[SelectedRow])
      else
        FFrameChannelProperties.LoadFromChannel(nil);
    end;
    SaveActiveWorkTableConfiguration;
  end;
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
  SaveActiveWorkTableConfiguration;
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

  if MessageDlg(
       'Заполнить все строки эталонов по выбранной?',
       TMsgDlgType.mtConfirmation,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) <> mrYes then
    Exit;

  for Ch in FActiveWorkTable.EtalonChannels do
    if Ch <> Src then
      CloneSelectedChannelDevice(Src, Ch);
  UpdateGrids;
  SaveActiveWorkTableConfiguration;
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

procedure TFrameMainTable.UpdateScaleWeightFromFlow(AWorkTable: TWorkTable);
var
  FlowPerSecond: Double;
  DeltaSeconds: Double;
  FlowUnit: string;

  function FlowToBasePerSecond(const AFlow: Double; const AUnitName: string): Double;
  begin
    if SameText(AUnitName, 'л/мин') or SameText(AUnitName, 'кг/мин') then
      Result := AFlow / 60
    else if SameText(AUnitName, 'л/ч') or SameText(AUnitName, 'кг/ч') then
      Result := AFlow / 3600
    else if SameText(AUnitName, 'м3/мин') or SameText(AUnitName, 'т/мин') then
      Result := AFlow * 1000 / 60
    else if SameText(AUnitName, 'м3/ч') or SameText(AUnitName, 'т/ч') then
      Result := AFlow * 1000 / 3600
    else
      Result := AFlow;
  end;

begin
  { Расчёт веса по расходу выполняется только при имитации.
    В реальном режиме вес поступает из DoOnChangeScales. }
  if (AWorkTable = nil) or (not AWorkTable.IsSimulationMode) then
    Exit;

  if (AWorkTable.FlowRate = nil) or
     (AWorkTable.FlowRate.Value = nil) or (AWorkTable.ValueFlowRate = nil) or
     (AWorkTable.ActiveScale = nil) then
    Exit;

  if not (AWorkTable.State in [swtMONITOR, swtEXECUTE]) then
    Exit;

  FlowUnit := Trim(AWorkTable.FlowUnitName);
  if FlowUnit = '' then
    FlowUnit := AWorkTable.ValueFlowRate.GetDimName;

  if FlowUnit <> '' then
    FlowPerSecond := FlowToBasePerSecond(
      AWorkTable.ValueFlowRate.GetDoubleValue(FlowUnit), FlowUnit)
  else
    FlowPerSecond := AWorkTable.FlowRate.Value.Value;
  if FlowPerSecond <= 0 then
    Exit;

  DeltaSeconds := TimerMain.Interval / 1000;
  if DeltaSeconds <= 0 then
    DeltaSeconds := 1;

  AWorkTable.Value := AWorkTable.Value + FlowPerSecond * DeltaSeconds;
  AWorkTable.ActiveScale.CurentValue := AWorkTable.Value;
end;

procedure TFrameMainTable.SetValues;
var
  WorkTable: TWorkTable;
  I: Integer;
  DeviceChannel: TChannel;
  EtalonChannel: TChannel;
  SignalSource: string;
  AcquisitionActive: Boolean;

  procedure StoreChannelSignals(AChannel: TChannel);
  begin
    if AChannel = nil then Exit;

    //Мгновенные значения считаем для всех приборов,
    //а сумму только для включенных и только во время измерения.

    if not AChannel.Enabled then
    begin
      AChannel.ClearRuntimeMeasurements;
      Exit;
    end;

    if not AcquisitionActive then
    begin
      AChannel.ClearPendingMeasurements;
      Exit;
    end;

    if (ProtocolManager <> nil) and
       (ProtocolManager.SampleChartEnabled or ProtocolManager.StatisticsEnabled) then
      AChannel.RecordPendingMeasurements(SignalSource)
    else
      AChannel.ClearPendingMeasurements;
    { TODO -oAndrey -cMUSTTODO :
Здесь записываются текущие значения.
Такая же функция должна быть про итоговвые значения! }

    if AChannel.ValueImpTotal <> nil then
      AChannel.ValueImpTotal.SetValue(AChannel.ImpResult);
  end;


begin
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  { Only an active acquisition cycle turns runtime fields into valid samples. }
  AcquisitionActive := WorkTable.State in [swtMONITOR, swtEXECUTE];
  if WorkTable.IsSimulationMode then SignalSource := 'Simulation'
  else SignalSource := 'Device';




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


   StoreChannelSignals(EtalonChannel);

  end;

  // Основные MeterValues каналов приборов.
  for I := 0 to WorkTable.DeviceChannels.Count - 1 do
  begin
    DeviceChannel := WorkTable.DeviceChannels[I];
    if (DeviceChannel = nil) or (DeviceChannel.FlowMeter = nil) then
      Continue;

    if AcquisitionActive then StoreChannelSignals(DeviceChannel)
    else if not DeviceChannel.Enabled then DeviceChannel.ClearRuntimeMeasurements;
  end;

  WorkTable.RecalculateAllMeterValues;

     { TODO -oAndrey -cNote : Что-то странное }
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

procedure TFrameMainTable.StabilitySampleTimerTimer(Sender: TObject);
var
  MV: TMeterValue;
begin
  { The registry owns only live objects: TMeterValue.Destroy removes an item before
    releasing its state. The timer never retains a meter value or its sample lock. }
 { for MV in TMeterValue.GetMeterValues do
    if (MV <> nil) and MV.StabilitySettings.Enabled then
      MV.AddCurrentStabilitySample;  }
end;

procedure TFrameMainTable.TimerMainTimer(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
  begin
    RefreshPumpsCombo;
    ResetUIPump;
    Exit;
  end;

  SetValues;
  if IsFlowGraphSamplingActive(WorkTable) then
    RenderFlowGraphs;
  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  UpdateScaleWeightFromFlow(WorkTable);

  IsUpdating := True;
  try
  //Grid Headers + Instrumental Labels
    UpdateUIFromValues;
    UpdateUIPump;
    UpdateUIScale;
    UpdateUIFlowRate;
    UpdateUIConditions;

    if FFrameChannelProperties <> nil then
      FFrameChannelProperties.UpdateDynamicValues;

  finally
    IsUpdating := False;
  end;



  { Канальные значения могут изменяться во всех промежуточных состояниях. }
  IsUpdating := True;
  try
//Grids
    if (WorkTable.State =  swtMONITOR) or (WorkTable.State =  swtEXECUTE) then
   UpdateGrids;
  finally
   IsUpdating := False;
  end;

end;


function TFrameMainTable.IsValidFlowGraphChannel(AChannel: TChannel): Boolean;
begin
  Result := (AChannel <> nil) and (AChannel.State <> osDeleted) and
    (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.ValueFlow <> nil) and
    ((AChannel.FlowMeter.Device = nil) or (AChannel.FlowMeter.Device.State <> osDeleted));
end;

function TFrameMainTable.BuildFlowGraphChannelKey(AKind: TFlowGraphChannelKind; AWorkTable: TWorkTable; AChannel: TChannel; AChannelIndex: Integer): string;
const
  KindNames: array[TFlowGraphChannelKind] of string = ('Etalon', 'Device');
var
  WorkTableUUID, ChannelUUID, ChannelPart: string;
begin
  WorkTableUUID := '';
  if AWorkTable <> nil then
    WorkTableUUID := Trim(AWorkTable.UUID);
  ChannelUUID := '';
  if AChannel <> nil then
    ChannelUUID := Trim(AChannel.UUID);
  if ChannelUUID <> '' then
    ChannelPart := ChannelUUID
  else
    ChannelPart := IntToStr(AChannelIndex);
  Result := Format('%s:%s:%s', [KindNames[AKind], WorkTableUUID, ChannelPart]);
end;

function TFrameMainTable.BuildFlowGraphSeriesKey(const AKind: string; AWorkTable: TWorkTable; AChannel: TChannel; AChannelIndex: Integer): string;
begin
  if SameText(AKind, 'Device') then
    Result := BuildFlowGraphChannelKey(fgckDevice, AWorkTable, AChannel, AChannelIndex)
  else
    Result := BuildFlowGraphChannelKey(fgckEtalon, AWorkTable, AChannel, AChannelIndex);
end;

function TFrameMainTable.BuildFlowGraphCaption(AChannel: TChannel; AChannelIndex: Integer; const AFallbackPrefix: string): string;
  procedure AppendUnique(const APart: string);
  var
    Part: string;
  begin
    Part := Trim(APart);
    if Part = '' then
      Exit;
    if (Result <> '') and (Pos(UpperCase(Part), UpperCase(Result)) > 0) then
      Exit;
    if (Result <> '') and (Pos(UpperCase(Result), UpperCase(Part)) > 0) then
      Result := Part
    else
    begin
      if Result <> '' then
        Result := Result + ' ';
      Result := Result + Part;
    end;
  end;
var
  S, DN: string;
begin
  Result := '';
  if AChannel <> nil then
  begin
    AppendUnique(AChannel.DeviceName);
    AppendUnique(AChannel.TypeName);
    DN := '';
    if (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.Device <> nil) then
      DN := Trim(AChannel.FlowMeter.Device.DN);
    if (DN <> '') and (Pos('DN', UpperCase(DN)) <> 1) then
      DN := 'DN' + DN;
    AppendUnique(DN);
    S := Trim(AChannel.Serial);
    if S <> '' then
      if Result <> '' then
        Result := Result + ' — №' + S
      else
        Result := '№' + S;
  end;
  if Result = '' then
    Result := Format('%s %d', [AFallbackPrefix, AChannelIndex + 1]);
end;

function TFrameMainTable.FlowToCurrentDimension(const AFlowLS: Double): Double;
begin
  Result := AFlowLS;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
    Result := FActiveWorkTable.ValueFlowRate.GetDoubleNum(AFlowLS, FActiveWorkTable.ValueFlowRate.CurrentDimIndex);
end;

function TFrameMainTable.FlowGraphDisplayValue(AWorkTable: TWorkTable; const ABaseFlowLS: Double): Double;
begin
  Result := FlowToCurrentDimension(ABaseFlowLS);
end;

function TFrameMainTable.IsFlowGraphSamplingActive(AWorkTable: TWorkTable): Boolean;
var
  Run: TMeasurementRun;
begin
  Result := (AWorkTable <> nil) and (AWorkTable.State in [swtSTARTMONITOR, swtSTARTMONITORWAIT, swtMONITOR, swtSTARTTEST, swtSTARTWAIT, swtEXECUTE, swtSTOPTEST, swtSTOPWAIT, swtFINALREAD]);
  if (not Result) and (AWorkTable <> nil) and (AWorkTable.MeasurementRun is TMeasurementRun) then
  begin
    Run := TMeasurementRun(AWorkTable.MeasurementRun);
    Result := not (Run.Stage in [msNone, msDone]);
  end;
end;

procedure TFrameMainTable.EnsureFlowGraphDictionaries;
begin
  if FFlowGraphHistory = nil then
    FFlowGraphHistory := TFlowGraphHistory.Create;
end;

// Создаёт контекстные меню для реально отображаемых ChartEtalonFlow и
// ChartDeviceFlow; меню родительского рабочего стола больше не перехватывает ПКМ.
procedure TFrameMainTable.InitializeVisibleGraphPopupMenus;
begin
  if FGraphsViewConfig = nil then
    FGraphsViewConfig := TGraphsViewConfig.Create;
  FGraphsViewConfig.EnsurePanelCount(2);

  { GraphMenuClick is private, therefore its handlers must not be streamed
    from .fmx and are assigned only after the frame has been loaded. }
  if MenuItemFlowChartLinePchip <> nil then
    MenuItemFlowChartLinePchip.OnClick := GraphMenuClick;
  if MenuItemFlowChartLineSegments <> nil then
    MenuItemFlowChartLineSegments.OnClick := GraphMenuClick;
  if MenuItemFlowChartValueFlow <> nil then
    MenuItemFlowChartValueFlow.OnClick := GraphMenuClick;
  if MenuItemFlowChartValueError <> nil then
    MenuItemFlowChartValueError.OnClick := GraphMenuClick;
  if MenuItemFlowChartScaleLog <> nil then
    MenuItemFlowChartScaleLog.OnClick := GraphMenuClick;
  if MenuItemFlowChartScaleLinear <> nil then
    MenuItemFlowChartScaleLinear.OnClick := GraphMenuClick;

  if ChartEtalonFlow <> nil then
  begin
    ChartEtalonFlow.PopupMenu := nil;
    ChartEtalonFlow.OnMouseDown := FlowChartMouseDown;
  end;
  if ChartDeviceFlow <> nil then
  begin
    ChartDeviceFlow.PopupMenu := nil;
    ChartDeviceFlow.OnMouseDown := FlowChartMouseDown;
  end;
end;

// Формирует только список серий; постоянные настройки принадлежат меню из .fmx.
procedure TFrameMainTable.RebuildVisibleFlowChartMenu(
  const AGraphIndex: Integer);
const
  ColorNames: array[0..11] of string = ('Синий', 'Красный', 'Зелёный',
    'Оранжевый', 'Фиолетовый', 'Бирюзовый', 'Жёлтый', 'Коричневый',
    'Индиго', 'Салатовый', 'Розовый', 'Серый');
var
  CurrentPair: TPair<string, TFlowGraphSeries>;

  function AddItem(AParent: TFmxObject; const ACaption,
    ACommand: string): TMenuItem;
  begin
    Result := TMenuItem.Create(nil);
    Result.Text := ACaption;
    Result.TagString := ACommand;
    if ACommand <> '' then
      Result.OnClick := GraphMenuClick;
    AParent.AddObject(Result);
  end;

  procedure AddSeries(ASeries: TFlowGraphSeries);
  var
    SeriesRoot, PointColorRoot, LineColorRoot, Item: TMenuItem;
    ColorIndex: Integer;
  begin
    if (ASeries = nil) or (ASeries.GraphIndex <> AGraphIndex) then
      Exit;

    SeriesRoot := AddItem(MenuItemFlowChartSeries, ASeries.Caption, '');
    Item := AddItem(SeriesRoot, 'Показывать',
      Format('visible|%d|%s', [AGraphIndex, ASeries.Key]));
    Item.IsChecked := ASeries.UserVisible;

    PointColorRoot := AddItem(SeriesRoot, 'Цвет точек', '');
    LineColorRoot := AddItem(SeriesRoot, 'Цвет линии', '');
    for ColorIndex := Low(FLOW_GRAPH_COLORS) to High(FLOW_GRAPH_COLORS) do
    begin
      Item := AddItem(PointColorRoot, ColorNames[ColorIndex],
        Format('pointcolor|%d|%s|%d', [AGraphIndex, ASeries.Key,
          ColorIndex]));
      Item.IsChecked := ASeries.PointColor = FLOW_GRAPH_COLORS[ColorIndex];

      Item := AddItem(LineColorRoot, ColorNames[ColorIndex],
        Format('linecolor|%d|%s|%d', [AGraphIndex, ASeries.Key,
          ColorIndex]));
      Item.IsChecked := ASeries.LineColor = FLOW_GRAPH_COLORS[ColorIndex];
    end;
  end;
begin
  if (PopupMenuFlowChart = nil) or (MenuItemFlowChartSeries = nil) or
     (FFlowGraphHistory = nil) or (FGraphsViewConfig = nil) or
     (AGraphIndex < 0) or
     (AGraphIndex >= FGraphsViewConfig.Panels.Count) then
    Exit;

  MenuItemFlowChartLinePchip.TagString :=
    Format('linemode|%d|pchip', [AGraphIndex]);
  MenuItemFlowChartLineSegments.TagString :=
    Format('linemode|%d|linear', [AGraphIndex]);
  MenuItemFlowChartValueFlow.TagString :=
    Format('valuemode|%d|flow', [AGraphIndex]);
  MenuItemFlowChartValueError.TagString :=
    Format('valuemode|%d|error', [AGraphIndex]);
  MenuItemFlowChartScaleLog.TagString :=
    Format('flowscale|%d|log', [AGraphIndex]);
  MenuItemFlowChartScaleLinear.TagString :=
    Format('flowscale|%d|linear', [AGraphIndex]);

  MenuItemFlowChartLinePchip.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].LineMode = glmPchipTime;
  MenuItemFlowChartLineSegments.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].LineMode = glmLinearSegments;
  MenuItemFlowChartValueFlow.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].ValueMode = gvmFlow;
  MenuItemFlowChartValueError.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].ValueMode = gvmError;
  MenuItemFlowChartScale.Enabled :=
    FGraphsViewConfig.Panels[AGraphIndex].ValueMode = gvmFlow;
  MenuItemFlowChartScaleLog.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].FlowScale = gfsLogarithmic;
  MenuItemFlowChartScaleLinear.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].FlowScale = gfsLinear;

  while MenuItemFlowChartSeries.ItemsCount > 0 do
    MenuItemFlowChartSeries.Items[
      MenuItemFlowChartSeries.ItemsCount - 1].Free;

  for CurrentPair in FFlowGraphHistory.EtalonSeries do
    AddSeries(CurrentPair.Value);
  for CurrentPair in FFlowGraphHistory.DeviceSeries do
    AddSeries(CurrentPair.Value);
end;

// Открывает штатное меню в точке ПКМ по рабочей схеме frmProceed.Chart1MouseDown.
procedure TFrameMainTable.FlowChartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  GraphIndex: Integer;
  P: TPointF;
begin
  if (Button <> TMouseButton.mbRight) or not (Sender is TControl) or
     (PopupMenuFlowChart = nil) then
    Exit;

  if Sender = ChartEtalonFlow then
    GraphIndex := 0
  else if Sender = ChartDeviceFlow then
    GraphIndex := 1
  else
    Exit;

  RebuildVisibleFlowChartMenu(GraphIndex);
  P := TControl(Sender).LocalToScreen(PointF(X, Y));
  PopupMenuFlowChart.Popup(P.X, P.Y);
end;

function TFrameMainTable.FlowGraphSamplesCount(ADict: TObjectDictionary<string, TFlowGraphSeries>): Integer;
var
  Pair: TPair<string, TFlowGraphSeries>;
begin
  Result := 0;
  if ADict = nil then
    Exit;
  for Pair in ADict do
    if (Pair.Value <> nil) and (Pair.Value.Samples <> nil) then
      Inc(Result, Pair.Value.Samples.Count);
end;

function TFrameMainTable.TryGetCurrentPointGraphTarget(out ATargetLS: Double): Boolean;
var
  Run: TMeasurementRun;
  Point: TDevicePoint;
begin
  ATargetLS := 0;
  Result := False;
  if (FActiveWorkTable = nil) or not (FActiveWorkTable.MeasurementRun is TMeasurementRun) then
    Exit;
  Run := TMeasurementRun(FActiveWorkTable.MeasurementRun);
  if Run.Stage in [msNone, msDone] then
    Exit;
  Point := Run.CurrentPoint;
  if (Point = nil) or IsNan(Point.Q) or IsInfinite(Point.Q) then
    Exit;
  ATargetLS := Point.Q;
  Result := True;
end;

function TFrameMainTable.TryGetCurrentPointGraphTolerance(out ALowerLS: Double; out AUpperLS: Double): Boolean;
var
  TargetLS: Double;
  Run: TMeasurementRun;
  Point: TDevicePoint;
  MinPercent, MaxPercent: Double;
  AllowedMinusLS, AllowedPlusLS: Double;
begin
  ALowerLS := 0;
  AUpperLS := 0;
  Result := False;
  if not TryGetCurrentPointGraphTarget(TargetLS) then
    Exit;
  Run := TMeasurementRun(FActiveWorkTable.MeasurementRun);
  Point := Run.CurrentPoint;
  if (Point = nil) or (not AccuracyToRange(Point.FlowAccuracy, MinPercent, MaxPercent)) then
    Exit;
  AllowedMinusLS := Abs(TargetLS) * Abs(MinPercent) / 100.0;
  AllowedPlusLS := Abs(TargetLS) * Abs(MaxPercent) / 100.0;
  ALowerLS := TargetLS - AllowedMinusLS;
  AUpperLS := TargetLS + AllowedPlusLS;
  Result := (not IsNan(ALowerLS)) and (not IsInfinite(ALowerLS)) and
    (not IsNan(AUpperLS)) and (not IsInfinite(AUpperLS));
end;

function TFrameMainTable.TryGetCurrentPointGraphLimits(out ATargetLS: Double; out ALowerLS: Double; out AUpperLS: Double): Boolean;
begin
  Result := TryGetCurrentPointGraphTarget(ATargetLS);
  if not Result then
  begin
    ALowerLS := 0;
    AUpperLS := 0;
    Exit;
  end;
  Result := TryGetCurrentPointGraphTolerance(ALowerLS, AUpperLS);
end;

function TFrameMainTable.TryGetFlowGraphLimits(out ALimits: TFlowGraphLimits): Boolean;
var
  Run: TMeasurementRun;
  Point: TDevicePoint;
  MinPercent, MaxPercent: Double;
begin
  ALimits := Default(TFlowGraphLimits);
  ALimits.TargetValid := TryGetCurrentPointGraphTarget(ALimits.TargetLS);
  if ALimits.TargetValid then
  begin
    Run := TMeasurementRun(FActiveWorkTable.MeasurementRun);
    Point := Run.CurrentPoint;
    if Point <> nil then
    begin
      ALimits.AccuracyText := Point.FlowAccuracy;
      if AccuracyToRange(ALimits.AccuracyText, MinPercent, MaxPercent) then
      begin
        ALimits.LowerPercent := -Abs(MinPercent);
        ALimits.UpperPercent := Abs(MaxPercent);
        ALimits.LowerLS := ALimits.TargetLS +
          Abs(ALimits.TargetLS) * ALimits.LowerPercent / 100.0;
        ALimits.UpperLS := ALimits.TargetLS +
          Abs(ALimits.TargetLS) * ALimits.UpperPercent / 100.0;
        ALimits.ToleranceValid :=
          (not IsNan(ALimits.LowerLS)) and
          (not IsInfinite(ALimits.LowerLS)) and
          (not IsNan(ALimits.UpperLS)) and
          (not IsInfinite(ALimits.UpperLS));
      end;
    end;
    ALimits.Valid := ALimits.ToleranceValid;
    FLastFlowGraphLimits := ALimits;
  end
  else
    ALimits := FLastFlowGraphLimits;
  Result := ALimits.TargetValid;
end;

procedure TFrameMainTable.RefreshFlowGraphChannels(const AReason: string);
  procedure RemoveMissing(AValidKeys: TDictionary<string, Boolean>);
  var
    Keys: TList<string>;
    Key: string;
  begin
    Keys := TList<string>.Create;
    try
      for Key in FFlowGraphHistory.EtalonSeries.Keys do
        if not AValidKeys.ContainsKey(Key) then
          Keys.Add(Key);
      for Key in Keys do
        FFlowGraphHistory.EtalonSeries.Remove(Key);
      Keys.Clear;
      for Key in FFlowGraphHistory.DeviceSeries.Keys do
        if not AValidKeys.ContainsKey(Key) then
          Keys.Add(Key);
      for Key in Keys do
        FFlowGraphHistory.DeviceSeries.Remove(Key);
    finally
      Keys.Free;
    end;
  end;

  function GetFlowGraphColor(const AIndex: Integer): TAlphaColor;
  begin
    Result := FLOW_GRAPH_COLORS[Abs(AIndex) mod Length(FLOW_GRAPH_COLORS)];
  end;

  procedure BuildList(AKind: TFlowGraphChannelKind; AList: TObjectList<TChannel>; ADict: TObjectDictionary<string,TFlowGraphSeries>; const APrefix, AFallback: string; AValidKeys: TDictionary<string, Boolean>);
  var
    I: Integer;
    C: TChannel;
    Key, Caption: string;
    S: TFlowGraphSeries;
  begin
    if AList = nil then
      Exit;
    for I := 0 to AList.Count - 1 do
    begin
      C := AList[I];
      if not IsValidFlowGraphChannel(C) then
        Continue;
      Key := BuildFlowGraphChannelKey(AKind, FActiveWorkTable, C, I);
      Caption := APrefix + ': ' + BuildFlowGraphCaption(C, I, AFallback);
      AValidKeys.AddOrSetValue(Key, True);
      if not ADict.TryGetValue(Key, S) then
      begin
        S := TFlowGraphSeries.Create(Key, Caption, GetFlowGraphColor(I), C.Enabled);
        if AKind = fgckEtalon then
          S.GraphIndex := 0
        else
          S.GraphIndex := 1;
        ADict.Add(Key, S);
      end
      else
        S.Caption := Caption;
      S.ChannelAvailable := C.Enabled;
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcInfo, psForm, 'GraphSeriesState', Caption,
          Format('ChannelUUID=%s; Enabled=%s; Available=%s; UserVisible=%s; EffectiveVisible=%s',
          [C.UUID, BoolToStr(C.Enabled, True), BoolToStr(S.ChannelAvailable, True),
           BoolToStr(S.UserVisible, True), BoolToStr(S.EffectiveVisible, True)]));
    end;
  end;
var
  ValidKeys: TDictionary<string, Boolean>;
begin
  EnsureFlowGraphDictionaries;
  if FFlowGraphWorkTable <> FActiveWorkTable then
  begin
    FFlowGraphHistory.Clear;
    FFlowGraphWorkTable := FActiveWorkTable;
    FFlowGraphXMin := 0; FFlowGraphXMax := 0; FCurrentGraphPointUUID := ''; FCurrentGraphPointIndex := -1;
    FCurrentGraphPointKey := ''; FCurrentGraphPointStartMs := 0; FGraphMonitorStartMs := 0; FLastFlowGraphSampleMs := 0;
    FMeasurementRunInstance := nil; FGraphChannelsReady := False; FGraphSamplingActive := False; FLastGraphRunActive := False;
    FLastFlowGraphLimits := Default(TFlowGraphLimits);
  end;
  ValidKeys := TDictionary<string, Boolean>.Create;
  try
    if FActiveWorkTable <> nil then
    begin
      BuildList(fgckEtalon, FActiveWorkTable.EtalonChannels, FFlowGraphHistory.EtalonSeries, 'Эталон', 'Эталонный канал', ValidKeys);
      BuildList(fgckDevice, FActiveWorkTable.DeviceChannels, FFlowGraphHistory.DeviceSeries, 'Прибор', 'Поверяемый канал', ValidKeys);
      FGraphChannelsReady := True;
    end
    else
      FGraphChannelsReady := False;
    RemoveMissing(ValidKeys);
  finally
    ValidKeys.Free;
  end;
  RebuildSelectedGraphLegend;
  if FActiveWorkTable <> nil then
    RenderFlowGraphs;
end;


procedure TFrameMainTable.FlowGraphCheckBoxChange(Sender: TObject);
var
  CheckBox: TCheckBox;
  Series: TFlowGraphSeries;
begin
  if FInitializingGraphs then
    Exit;
  if not (Sender is TCheckBox) then
    Exit;
  CheckBox := TCheckBox(Sender);
  if FFlowGraphHistory = nil then
    Exit;
  if FFlowGraphHistory.EtalonSeries.TryGetValue(CheckBox.TagString, Series) then
    Series.UserVisible := CheckBox.IsChecked
  else if FFlowGraphHistory.DeviceSeries.TryGetValue(CheckBox.TagString, Series) then
    Series.UserVisible := CheckBox.IsChecked
  else
    Exit;
  RebuildSelectedGraphLegend;
  QueueRenderGraphViews;
end;

procedure TFrameMainTable.AddFlowGraphSamples(const ATimeStampMs: Int64);
  procedure LogSample(const AKind, AKey: string; const ARawValue: Double; const AAccepted: Boolean; const AReason: string; const ASamplesBefore, ASamplesAfter: Integer);
  begin
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcMKS, psForm, 'FlowGraphAddSample',
        Format('PointIndex=%d; PointKey=%s; SeriesKind=%s; SeriesKey=%s; RawValueLS=%g; Accepted=%s; RejectReason=%s; TimeStampMs=%d; SegmentStartMs=%d; SamplesBefore=%d; SamplesAfter=%d',
          [FCurrentGraphPointIndex, FCurrentGraphPointKey, AKind, AKey, ARawValue, BoolToStr(AAccepted, True), AReason,
           ATimeStampMs, FCurrentGraphPointStartMs, ASamplesBefore, ASamplesAfter]), '');
  end;

  procedure AddList(AList: TObjectList<TChannel>; ADict: TObjectDictionary<string,TFlowGraphSeries>; const AKind, AFallback: string);
  var
    I: Integer;
    C: TChannel;
    Key: string;
    S: TFlowGraphSeries;
    Sample: TFlowGraphSample;
    RawValue, RawError: Double;
  begin
    if AList = nil then
      Exit;
    for I := 0 to AList.Count - 1 do
    begin
      C := AList[I];
      Key := '';
      RawValue := 0;
      RawError := 0;
      if FActiveWorkTable <> nil then
        Key := BuildFlowGraphSeriesKey(AKind, FActiveWorkTable, C, I);
      if C = nil then
      begin
        LogSample(AKind, Key, RawValue, False, 'ChannelNil', 0, 0);
        Continue;
      end;
      if not ADict.TryGetValue(Key, S) then
      begin
        LogSample(AKind, Key, RawValue, False, 'SeriesKeyNotFound', 0, 0);
        Continue;
      end;
      if not C.Enabled then
      begin
        S.ChannelAvailable := False;
        LogSample(AKind, Key, 0, False, 'ChannelDisabled', 0, 0);
        Continue;
      end;
      S.ChannelAvailable := True;
      if C.FlowMeter = nil then
      begin
        LogSample(AKind, Key, RawValue, False, 'FlowMeterNil', 0, 0);
        Continue;
      end;
      if C.FlowMeter.ValueFlow = nil then
      begin
        LogSample(AKind, Key, RawValue, False, 'ValueFlowNil', 0, 0);
        Continue;
      end;
      if (C.State = osDeleted) or ((C.FlowMeter.Device <> nil) and (C.FlowMeter.Device.State = osDeleted)) then
      begin
        LogSample(AKind, Key, RawValue, False, 'Deleted', 0, 0);
        Continue;
      end;
      RawValue := C.FlowMeter.ValueFlow.GetDoubleValue;
      if IsNan(RawValue) or IsInfinite(RawValue) then
      begin
        LogSample(AKind, Key, RawValue, False, 'InvalidValue', S.Samples.Count, S.Samples.Count);
        Continue;
      end;
      Sample.TimeStampMs := ATimeStampMs;
      Sample.FlowValue := RawValue;
      Sample.ErrorValue := 0;
      Sample.ErrorValid := False;
      if C.FlowMeter.ValueError <> nil then
      begin
        RawError := C.FlowMeter.ValueError.GetDoubleValue;
        if (not IsNan(RawError)) and (not IsInfinite(RawError)) then
        begin
          Sample.ErrorValue := RawError;
          Sample.ErrorValid := True;
        end;
      end;
      LogSample(AKind, Key, RawValue, True, '', S.Samples.Count, S.Samples.Count + 1);
      S.Samples.Add(Sample);
      while S.Samples.Count > MaxGraphSampleCountPerSeries do
        S.Samples.Delete(0);
    end;
  end;
begin
  if FActiveWorkTable = nil then
    Exit;
  EnsureFlowGraphDictionaries;
  AddList(FActiveWorkTable.EtalonChannels, FFlowGraphHistory.EtalonSeries, 'Etalon', 'Эталонный канал');
  AddList(FActiveWorkTable.DeviceChannels, FFlowGraphHistory.DeviceSeries, 'Device', 'Приборный канал');
end;

procedure TFrameMainTable.ApplyFlowChartSeriesStyle(const ASeries: TChartSeries;
  const AColor: TAlphaColor; const AThickness: Single; const AShowMarkers: Boolean);
begin
  if ASeries = nil then
    Exit;

  ASeries.Color := AColor;
  ASeries.Thickness := EnsureRange(AThickness, 0.5, 10.0);
  ASeries.ShowMarkers := AShowMarkers;
end;


procedure TFrameMainTable.SetFlowChartYAxis(AChart: TSimpleChart; const AYMin, AYMax: Double);
var
  SafeMin: Double;
begin
  if (AChart = nil) or IsNan(AYMin) or IsInfinite(AYMin) or
     IsNan(AYMax) or IsInfinite(AYMax) or (AYMax <= AYMin) then
    Exit;
  SafeMin := AYMin;
  if AChart.LogarithmicY then
  begin
    if AYMax <= 0 then
      Exit;
    if SafeMin <= 0 then
      SafeMin := AYMax / 1000;
  end;
  AChart.YMin := SafeMin;
  AChart.YMax := AYMax;
end;

procedure TFrameMainTable.AddFlowLimitSeries(AChart: TSimpleChart;
  const ALimits: TFlowGraphLimits; const AAxisMinSec, AAxisMaxSec: Double;
  const AValueMode: TGraphValueMode);
var
  TargetSeries, LowerSeries, UpperSeries: TChartSeries;
  TargetValue, LowerValue, UpperValue: Double;
begin
  if AChart = nil then
    Exit;

  if ALimits.TargetValid then
  begin
    if AValueMode = gvmError then
      TargetValue := 0
    else
      TargetValue := FlowToCurrentDimension(ALimits.TargetLS);
    if AChart.LogarithmicY and (TargetValue <= 0) then
      TargetValue := 0;
    if (not AChart.LogarithmicY) or (TargetValue > 0) then
    begin
      if AValueMode = gvmError then
        TargetSeries := AChart.AddSeries('Нулевая погрешность')
      else
        TargetSeries := AChart.AddSeries('Заданный расход');
      ApplyFlowChartSeriesStyle(TargetSeries, TAlphaColors.Green, 1.5, False);
      TargetSeries.AddPoint(AAxisMinSec, TargetValue);
      TargetSeries.AddPoint(AAxisMaxSec, TargetValue);
    end;
  end;

  if ALimits.ToleranceValid then
  begin
    if AValueMode = gvmError then
    begin
      LowerValue := ALimits.LowerPercent;
      UpperValue := ALimits.UpperPercent;
    end
    else
    begin
      LowerValue := FlowToCurrentDimension(ALimits.LowerLS);
      UpperValue := FlowToCurrentDimension(ALimits.UpperLS);
    end;
    if (not AChart.LogarithmicY) or (LowerValue > 0) then
    begin
      LowerSeries := AChart.AddSeries('Нижняя граница');
      ApplyFlowChartSeriesStyle(LowerSeries, TAlphaColors.Red, 1.0, False);
      LowerSeries.AddPoint(AAxisMinSec, LowerValue);
      LowerSeries.AddPoint(AAxisMaxSec, LowerValue);
    end;
    if (not AChart.LogarithmicY) or (UpperValue > 0) then
    begin
      UpperSeries := AChart.AddSeries('Верхняя граница');
      ApplyFlowChartSeriesStyle(UpperSeries, TAlphaColors.Red, 1.0, False);
      UpperSeries.AddPoint(AAxisMinSec, UpperValue);
      UpperSeries.AddPoint(AAxisMaxSec, UpperValue);
    end;
  end;
end;

procedure TFrameMainTable.RenderFlowChart(AChart: TSimpleChart; AGraphSeries: TObjectDictionary<string, TFlowGraphSeries>; const ATitle: string; const AVisibleXMinMs, AVisibleXMaxMs: Int64; const AAxisMinSec, AAxisMaxSec: Double; AMeasurementSegment: Boolean);
var
  Pair: TPair<string, TFlowGraphSeries>;
  Sample: TFlowGraphSample;
  Series, PointSeries: TChartSeries;
  XSec, V, DisplayValue: Double;
  UnitName: string;
  Limits: TFlowGraphLimits;
  HasData: Boolean;
  DataMin, DataMax, YDataMin, YDataMax, ValueRange, Padding: Double;
  AxisMinDisplay, AxisMaxDisplay: Double;
  MinimumRange, CenterValue: Double;
  AutoScaleMode: TGraphAutoScaleMode;
  LineMode: TGraphLineMode;
  FlowScale: TGraphFlowScale;
  ValueMode: TGraphValueMode;
  ViewIndex, ScaleSeriesCount: Integer;
  UseForAutoScale: Boolean;

  // Строит формосохраняющую PCHIP-линию по времени, не меняя исходные точки.
  procedure BuildPchipTimeLine(const APoints: TList<TPointF>;
    ASeries: TChartSeries);
  const
    CSamplesPerInterval = 12;
  var
    PointX, PointY, H, Delta, Derivative: TArray<Double>;
    PointCount, PointIndex, SegmentIndex, SampleIndex: Integer;
    T, H00, H10, H01, H11, CurveX, CurveY: Double;

    function SameNonZeroSign(const A, B: Double): Boolean;
    begin
      Result := not SameValue(A, 0.0) and not SameValue(B, 0.0) and
        ((A > 0) = (B > 0));
    end;

    function EndpointDerivative(const H0, H1, Delta0,
      Delta1: Double): Double;
    begin
      Result := ((2 * H0 + H1) * Delta0 - H0 * Delta1) / (H0 + H1);
      if not SameNonZeroSign(Result, Delta0) then
        Result := 0
      else if not SameNonZeroSign(Delta0, Delta1) and
              (Abs(Result) > 3 * Abs(Delta0)) then
        Result := 3 * Delta0;
    end;

    procedure CopyPoints;
    var
      P: TPointF;
    begin
      ASeries.ClearPoints;
      for P in APoints do
        ASeries.AddPoint(P.X, P.Y);
    end;
  begin
    if (APoints = nil) or (ASeries = nil) then
      Exit;
    if APoints.Count < 3 then
    begin
      CopyPoints;
      Exit;
    end;

    PointCount := APoints.Count;
    SetLength(PointX, PointCount);
    SetLength(PointY, PointCount);
    SetLength(H, PointCount - 1);
    SetLength(Delta, PointCount - 1);
    SetLength(Derivative, PointCount);
    for PointIndex := 0 to PointCount - 1 do
    begin
      PointX[PointIndex] := APoints[PointIndex].X;
      PointY[PointIndex] := APoints[PointIndex].Y;
      if (PointIndex > 0) and
         (PointX[PointIndex] <= PointX[PointIndex - 1]) then
      begin
        CopyPoints;
        Exit;
      end;
    end;

    for PointIndex := 0 to PointCount - 2 do
    begin
      H[PointIndex] := PointX[PointIndex + 1] - PointX[PointIndex];
      Delta[PointIndex] :=
        (PointY[PointIndex + 1] - PointY[PointIndex]) / H[PointIndex];
    end;
    Derivative[0] := EndpointDerivative(H[0], H[1], Delta[0], Delta[1]);
    Derivative[PointCount - 1] := EndpointDerivative(
      H[PointCount - 2], H[PointCount - 3], Delta[PointCount - 2],
      Delta[PointCount - 3]);
    for PointIndex := 1 to PointCount - 2 do
      if SameNonZeroSign(Delta[PointIndex - 1], Delta[PointIndex]) then
        Derivative[PointIndex] :=
          (2 * H[PointIndex] + H[PointIndex - 1] + H[PointIndex] +
           2 * H[PointIndex - 1]) /
          ((2 * H[PointIndex] + H[PointIndex - 1]) /
             Delta[PointIndex - 1] +
           (H[PointIndex] + 2 * H[PointIndex - 1]) /
             Delta[PointIndex])
      else
        Derivative[PointIndex] := 0;

    ASeries.ClearPoints;
    for SegmentIndex := 0 to PointCount - 2 do
      for SampleIndex := 0 to CSamplesPerInterval do
      begin
        if (SegmentIndex > 0) and (SampleIndex = 0) then
          Continue;
        T := SampleIndex / CSamplesPerInterval;
        H00 := 2 * T * T * T - 3 * T * T + 1;
        H10 := T * T * T - 2 * T * T + T;
        H01 := -2 * T * T * T + 3 * T * T;
        H11 := T * T * T - T * T;
        CurveX := PointX[SegmentIndex] + H[SegmentIndex] * T;
        CurveY := H00 * PointY[SegmentIndex] +
          H10 * H[SegmentIndex] * Derivative[SegmentIndex] +
          H01 * PointY[SegmentIndex + 1] +
          H11 * H[SegmentIndex] * Derivative[SegmentIndex + 1];
        if IsNan(CurveY) or IsInfinite(CurveY) then
        begin
          CopyPoints;
          Exit;
        end;
        ASeries.AddPoint(CurveX, CurveY);
      end;
  end;
begin
  if (AChart = nil) or (AGraphSeries = nil) then
    Exit;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
    UnitName := FActiveWorkTable.ValueFlowRate.GetDimName
  else
    UnitName := 'л/с';

  AChart.BeginUpdate;
  try
    AChart.ClearAllSeries;
    AChart.XTitle := 'Время, с';

    HasData := False;
    ScaleSeriesCount := 0;
    AutoScaleMode := gasWorkingValues;
    LineMode := glmLinearSegments;
    ValueMode := gvmFlow;
    FlowScale := gfsLinear;
    ViewIndex := -1;
    if FGraphsViewConfig <> nil then
    begin
      if AChart = ChartEtalonFlow then
        ViewIndex := 0
      else if AChart = ChartDeviceFlow then
        ViewIndex := 1;

      if (ViewIndex < 0) and (FGraphViews <> nil) then
        for ViewIndex := 0 to FGraphViews.Count - 1 do
          if FGraphViews[ViewIndex].Chart = AChart then
            Break;

      if (ViewIndex >= 0) and
         (ViewIndex < FGraphsViewConfig.Panels.Count) then
      begin
        AutoScaleMode := FGraphsViewConfig.Panels[ViewIndex].AutoScaleMode;
        LineMode := FGraphsViewConfig.Panels[ViewIndex].LineMode;
        ValueMode := FGraphsViewConfig.Panels[ViewIndex].ValueMode;
        FlowScale := FGraphsViewConfig.Panels[ViewIndex].FlowScale;
      end;
    end;

    if ValueMode = gvmError then
    begin
      if AChart = ChartEtalonFlow then
        AChart.Title := 'Погрешность эталонов'
      else if AChart = ChartDeviceFlow then
        AChart.Title := 'Погрешность поверяемых приборов'
      else
        AChart.Title := ATitle + ' (погрешность)';
      AChart.YTitle := 'Погрешность, %';
      AChart.LogarithmicY := False;
    end
    else
    begin
      AChart.Title := ATitle;
      AChart.YTitle := 'Расход, ' + UnitName;
      AChart.LogarithmicY := FlowScale = gfsLogarithmic;
    end;

    DataMin := 0;
    DataMax := 0;
    TryGetFlowGraphLimits(Limits);

    for Pair in AGraphSeries do
    begin
      if (Pair.Value = nil) or (not Pair.Value.EffectiveVisible) then
        Continue;
      Series := AChart.AddSeries(Pair.Value.Caption);
      PointSeries := AChart.AddSeries('');
      Inc(ScaleSeriesCount);
      ApplyFlowChartSeriesStyle(Series, Pair.Value.LineColor, 2.0, False);
      ApplyFlowChartSeriesStyle(PointSeries, Pair.Value.PointColor, 2.0, True);
      PointSeries.ShowLine := False;
      for Sample in Pair.Value.Samples do
      begin
        if AMeasurementSegment then
        begin
          if (FCurrentGraphPointStartMs <= 0) or
             (Sample.TimeStampMs < FCurrentGraphPointStartMs) then
            Continue;
          XSec := (Sample.TimeStampMs - FCurrentGraphPointStartMs) / 1000.0;
        end
        else
        begin
          if (Sample.TimeStampMs < AVisibleXMinMs) or
             (Sample.TimeStampMs > AVisibleXMaxMs) then
            Continue;
          if FGraphMonitorStartMs > 0 then
            XSec := (Sample.TimeStampMs - FGraphMonitorStartMs) / 1000.0
          else
            XSec := (Sample.TimeStampMs - AVisibleXMinMs) / 1000.0;
        end;
        if (XSec < AAxisMinSec) or (XSec > AAxisMaxSec) then
          Continue;

        if ValueMode = gvmError then
        begin
          if not Sample.ErrorValid then
            Continue;
          V := Sample.ErrorValue;
          DisplayValue := V;
        end
        else
        begin
          V := Sample.FlowValue;
          DisplayValue := FlowToCurrentDimension(V);
        end;
        if IsNan(V) or IsInfinite(V) then
          Continue;
        if AChart.LogarithmicY and (DisplayValue <= 0) then
          Continue;

        UseForAutoScale := (ValueMode = gvmError) or
          (AutoScaleMode = gasAllSeries) or
          (not SameValue(V, 0.0, 1E-12)) or
          (Limits.TargetValid and SameValue(Limits.TargetLS, 0.0, 1E-12));
        if UseForAutoScale then
        begin
          if not HasData then
          begin
            DataMin := V;
            DataMax := V;
            HasData := True;
          end
          else
          begin
            DataMin := Min(DataMin, V);
            DataMax := Max(DataMax, V);
          end;
        end;
        PointSeries.AddPoint(XSec, DisplayValue);
      end;
      if LineMode = glmPchipTime then
        BuildPchipTimeLine(PointSeries.Points, Series)
      else
      begin
        Series.ClearPoints;
        for ViewIndex := 0 to PointSeries.Points.Count - 1 do
          Series.AddPoint(PointSeries.Points[ViewIndex].X,
            PointSeries.Points[ViewIndex].Y);
      end;
    end;

    if Limits.ToleranceValid then
    begin
      if ValueMode = gvmError then
      begin
        YDataMin := Min(Limits.LowerPercent, Limits.UpperPercent);
        YDataMax := Max(Limits.LowerPercent, Limits.UpperPercent);
      end
      else
      begin
        YDataMin := Min(Limits.LowerLS, Limits.UpperLS);
        YDataMax := Max(Limits.LowerLS, Limits.UpperLS);
      end;
      ValueRange := YDataMax - YDataMin;
      if ValueRange > 0 then
        Padding := ValueRange * 0.10
      else
        Padding := Max(Abs(YDataMin) * 0.01, 0.001);
      if ValueMode = gvmError then
      begin
        AxisMinDisplay := YDataMin - Padding;
        AxisMaxDisplay := YDataMax + Padding;
      end
      else
      begin
        AxisMinDisplay := FlowToCurrentDimension(YDataMin - Padding);
        AxisMaxDisplay := FlowToCurrentDimension(YDataMax + Padding);
      end;
      SetFlowChartYAxis(AChart, AxisMinDisplay, AxisMaxDisplay);
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcMKS, psForm, 'FlowChartLimits',
          Format('PointName=%s; ValueMode=%d; FlowAccuracy=%s; LowerRaw=%.12g; UpperRaw=%.12g; YAxisMin=%.12g; YAxisMax=%.12g',
            [FCurrentGraphPointKey, Ord(ValueMode), Limits.AccuracyText,
             YDataMin, YDataMax, AxisMinDisplay, AxisMaxDisplay]), '');
    end
    else if Limits.TargetValid then
    begin
      if ValueMode = gvmError then
      begin
        YDataMin := 0;
        YDataMax := 0;
      end
      else
      begin
        YDataMin := Limits.TargetLS;
        YDataMax := Limits.TargetLS;
      end;
      if HasData and (AutoScaleMode <> gasTargetTolerance) then
      begin
        YDataMin := Min(YDataMin, DataMin);
        YDataMax := Max(YDataMax, DataMax);
      end;
      ValueRange := YDataMax - YDataMin;
      if ValueRange > 0 then
        Padding := ValueRange * 0.10
      else
        Padding := Max(Abs(YDataMin) * 0.01, 0.001);
      if ValueMode = gvmError then
      begin
        AxisMinDisplay := YDataMin - Padding;
        AxisMaxDisplay := YDataMax + Padding;
      end
      else
      begin
        AxisMinDisplay := FlowToCurrentDimension(YDataMin - Padding);
        AxisMaxDisplay := FlowToCurrentDimension(YDataMax + Padding);
      end;
      SetFlowChartYAxis(AChart, AxisMinDisplay, AxisMaxDisplay);
    end
    else if HasData then
    begin
      CenterValue := (DataMin + DataMax) / 2;
      ValueRange := DataMax - DataMin;
      MinimumRange := Max(Abs(CenterValue) * 0.01, 0.000001);
      if ValueRange < MinimumRange then
      begin
        DataMin := CenterValue - MinimumRange / 2;
        DataMax := CenterValue + MinimumRange / 2;
        ValueRange := MinimumRange;
      end;
      Padding := Max(ValueRange * 0.10, Abs(CenterValue) * 0.001);
      if ValueMode = gvmError then
      begin
        AxisMinDisplay := DataMin - Padding;
        AxisMaxDisplay := DataMax + Padding;
      end
      else
      begin
        AxisMinDisplay := FlowToCurrentDimension(DataMin - Padding);
        AxisMaxDisplay := FlowToCurrentDimension(DataMax + Padding);
      end;
      SetFlowChartYAxis(AChart, AxisMinDisplay, AxisMaxDisplay);
    end;

    if Assigned(ProtocolManager) and (ScaleSeriesCount > 0) then
      ProtocolManager.AddMessage(pcMKS, psForm, 'GraphScale', ATitle,
        Format('ValueMode=%d; AutoScaleMode=%d; ScaleMin=%g; ScaleMax=%g; SeriesCount=%d',
          [Ord(ValueMode), Ord(AutoScaleMode), AChart.YMin, AChart.YMax,
           ScaleSeriesCount]));

    AddFlowLimitSeries(AChart, Limits, AAxisMinSec, AAxisMaxSec, ValueMode);
  finally
    AChart.EndUpdate;
  end;
  AChart.InvalidateChart;
end;

procedure TFrameMainTable.UpdateEtalonFlowChart;
var
  BaseMs: Int64;
  AxisMinSec, AxisMaxSec: Double;
begin
  if FFlowGraphHistory = nil then
    Exit;
  BaseMs := FGraphMonitorStartMs;
  if FCurrentGraphPointStartMs > 0 then
    BaseMs := FCurrentGraphPointStartMs;
  AxisMinSec := 0;
  AxisMaxSec := GraphVisibleWindowSec;
  if BaseMs > 0 then
  begin
    AxisMinSec := Max(0.0, (FFlowGraphXMin - BaseMs) / 1000.0);
    AxisMaxSec := Max(GraphVisibleWindowSec, (FFlowGraphXMax - BaseMs) / 1000.0);
  end;
  RenderFlowChart(ChartEtalonFlow, FFlowGraphHistory.EtalonSeries, 'Расход эталонов',
    FFlowGraphXMin, FFlowGraphXMax, AxisMinSec, AxisMaxSec, FCurrentGraphPointStartMs > 0);
end;

procedure TFrameMainTable.UpdateDeviceFlowChart;
var
  BaseMs: Int64;
  AxisMinSec, AxisMaxSec: Double;
begin
  if FFlowGraphHistory = nil then
    Exit;
  BaseMs := FGraphMonitorStartMs;
  if FCurrentGraphPointStartMs > 0 then
    BaseMs := FCurrentGraphPointStartMs;
  AxisMinSec := 0;
  AxisMaxSec := GraphVisibleWindowSec;
  if BaseMs > 0 then
  begin
    AxisMinSec := Max(0.0, (FFlowGraphXMin - BaseMs) / 1000.0);
    AxisMaxSec := Max(GraphVisibleWindowSec, (FFlowGraphXMax - BaseMs) / 1000.0);
  end;
  RenderFlowChart(ChartDeviceFlow, FFlowGraphHistory.DeviceSeries, 'Расход поверяемых приборов',
    FFlowGraphXMin, FFlowGraphXMax, AxisMinSec, AxisMaxSec, FCurrentGraphPointStartMs > 0);
end;

procedure TFrameMainTable.RenderFlowGraphs;
var
  CurrentTimeMs, SegmentTimeMs, VisibleXMinMs, VisibleXMaxMs: Int64;
  AxisMinSec, AxisMaxSec, ElapsedSec: Double;
  Run: TMeasurementRun;
  Point: TDevicePoint;
  PointUUID, PointKey: string;
  PointIndex, StageOrdinal, WorkTableStateOrdinal: Integer;
  MeasurementSegment, RunActive, NewRunStarted, PointChanged, SampleAdded: Boolean;
begin
  if FGraphsWorkspace <> nil then
  begin
    FGraphsWorkspace.Initialize(FActiveWorkTable);
    FGraphsWorkspace.UpdateGraphs;
  end;
  if FFlowGraphHistory = nil then
    Exit;

  CurrentTimeMs := TMeterValue.GetMonotonicTimeMs;
  SegmentTimeMs := CurrentTimeMs;
  MeasurementSegment := False;
  RunActive := False;
  NewRunStarted := False;
  PointChanged := False;
  SampleAdded := False;
  Run := nil;
  Point := nil;
  PointUUID := '';
  PointKey := '';
  PointIndex := -1;
  StageOrdinal := -1;
  WorkTableStateOrdinal := -1;
  if FActiveWorkTable <> nil then
    WorkTableStateOrdinal := Ord(FActiveWorkTable.State);
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.MeasurementRun is TMeasurementRun) then
  begin
    Run := TMeasurementRun(FActiveWorkTable.MeasurementRun);
    StageOrdinal := Ord(Run.Stage);
    if FMeasurementRunInstance <> Run then
    begin
      FMeasurementRunInstance := Run;
      FCurrentGraphPointUUID := '';
      FCurrentGraphPointIndex := -1;
      FCurrentGraphPointKey := '';
      FCurrentGraphPointStartMs := 0;
      FLastFlowGraphSampleMs := 0;
      FLastFlowGraphLimits := Default(TFlowGraphLimits);
    end;
    RunActive := not (Run.Stage in [msNone, msDone]);
    NewRunStarted := RunActive and not FLastGraphRunActive;
    if NewRunStarted then
    begin
      FMeasurementRunInstance := Run;
      FCurrentGraphPointUUID := '';
      FCurrentGraphPointIndex := -1;
      FCurrentGraphPointKey := '';
      FCurrentGraphPointStartMs := 0;
      FLastFlowGraphSampleMs := 0;
      FLastFlowGraphLimits := Default(TFlowGraphLimits);
      FGraphSamplingActive := False;
    end;
    if RunActive then
    begin
      Point := Run.CurrentPoint;
      PointIndex := Run.CurrentPointIndex;
    end;
  end
  else
    FMeasurementRunInstance := nil;

  if Point <> nil then
  begin
    PointUUID := Trim(Point.UUID);
    if PointUUID <> '' then
      PointKey := PointUUID
    else if PointIndex >= 0 then
      PointKey := IntToStr(PointIndex) + ':' + Point.Name + ':' + FloatToStr(Point.Q)
    else
      PointKey := Point.Name + ':' + FloatToStr(Point.Q);
  end;

  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcMKS, psForm, 'FlowGraphTick',
      Format('TimeMs=%d; RunActive=%s; LastRunActive=%s; NewRunStarted=%s; Stage=%d; WorkTableState=%d; CurrentPointAssigned=%s; CurrentPointIndex=%d; CurrentPointKey=%s; StoredPointKey=%s; SegmentStartMs=%d; ChannelsReady=%s; SamplingActive=%s',
        [CurrentTimeMs, BoolToStr(RunActive, True), BoolToStr(FLastGraphRunActive, True), BoolToStr(NewRunStarted, True),
         StageOrdinal, WorkTableStateOrdinal, BoolToStr(Point <> nil, True), PointIndex, PointKey, FCurrentGraphPointKey, FCurrentGraphPointStartMs,
         BoolToStr(FGraphChannelsReady, True), BoolToStr(FGraphSamplingActive, True)]), '');

  if (not FGraphChannelsReady) and (FActiveWorkTable <> nil) then
    RefreshFlowGraphChannels('ChannelsNotReady');

  if Point <> nil then
  begin
    PointUUID := Trim(Point.UUID);
    if PointUUID <> '' then
      PointKey := PointUUID
    else if PointIndex >= 0 then
      PointKey := IntToStr(PointIndex) + ':' + Point.Name + ':' + FloatToStr(Point.Q)
    else
      PointKey := Point.Name + ':' + FloatToStr(Point.Q);

    PointChanged := RunActive and ((FCurrentGraphPointStartMs = 0) or
      (not SameText(FCurrentGraphPointKey, PointKey)) or (FCurrentGraphPointIndex <> PointIndex));
    if PointChanged then
    begin
      FCurrentGraphPointKey := PointKey;
      FCurrentGraphPointUUID := PointUUID;
      FCurrentGraphPointIndex := PointIndex;
      FCurrentGraphPointStartMs := CurrentTimeMs;
      FLastFlowGraphSampleMs := 0;
      FGraphSamplingActive := True;
      if FGraphChannelsReady then
      begin
        AddFlowGraphSamples(CurrentTimeMs);
        FLastFlowGraphSampleMs := CurrentTimeMs;
        SampleAdded := True;
      end;
    end;
  end;

  { Keep the completed point visible until a new run/work table resets it. }
  MeasurementSegment := FCurrentGraphPointStartMs > 0;

  if (not MeasurementSegment) and IsFlowGraphSamplingActive(FActiveWorkTable) and (FGraphMonitorStartMs = 0) then
  begin
    FGraphMonitorStartMs := CurrentTimeMs;
    FLastFlowGraphSampleMs := 0;
  end;

  if (not SampleAdded) and (FGraphChannelsReady or (FActiveWorkTable <> nil)) and IsFlowGraphSamplingActive(FActiveWorkTable) and
     ((FLastFlowGraphSampleMs = 0) or (CurrentTimeMs < FLastFlowGraphSampleMs) or
      (CurrentTimeMs - FLastFlowGraphSampleMs >= GraphSampleIntervalMs)) then
  begin
    AddFlowGraphSamples(CurrentTimeMs);
    FLastFlowGraphSampleMs := CurrentTimeMs;
  end;

  if MeasurementSegment then
  begin
    if not RunActive then
    begin
      SegmentTimeMs := FLastFlowGraphSampleMs;
      if SegmentTimeMs < FCurrentGraphPointStartMs then
        SegmentTimeMs := FCurrentGraphPointStartMs;
    end;
    ElapsedSec := Max(0.0, (SegmentTimeMs - FCurrentGraphPointStartMs) / 1000.0);
    if ElapsedSec <= GraphVisibleWindowSec then
    begin
      AxisMinSec := 0;
      AxisMaxSec := GraphVisibleWindowSec;
    end
    else
    begin
      AxisMinSec := ElapsedSec - GraphVisibleWindowSec;
      AxisMaxSec := ElapsedSec;
    end;
    VisibleXMinMs := FCurrentGraphPointStartMs + Round(AxisMinSec * 1000.0);
    VisibleXMaxMs := FCurrentGraphPointStartMs + Round(AxisMaxSec * 1000.0);
  end
  else
  begin
    if FGraphMonitorStartMs = 0 then
      FGraphMonitorStartMs := CurrentTimeMs;
    ElapsedSec := Max(0.0, (CurrentTimeMs - FGraphMonitorStartMs) / 1000.0);
    if ElapsedSec <= GraphVisibleWindowSec then
    begin
      AxisMinSec := 0;
      AxisMaxSec := GraphVisibleWindowSec;
    end
    else
    begin
      AxisMinSec := ElapsedSec - GraphVisibleWindowSec;
      AxisMaxSec := ElapsedSec;
    end;
    VisibleXMinMs := FGraphMonitorStartMs + Round(AxisMinSec * 1000.0);
    VisibleXMaxMs := FGraphMonitorStartMs + Round(AxisMaxSec * 1000.0);
  end;
  FFlowGraphXMin := VisibleXMinMs;
  FFlowGraphXMax := VisibleXMaxMs;

  if (FGraphViews <> nil) and (FGraphViews.Count > 0) then
    RenderGraphViews
  else
  begin
    RenderFlowChart(ChartEtalonFlow, FFlowGraphHistory.EtalonSeries, 'Расход эталонов',
      VisibleXMinMs, VisibleXMaxMs, AxisMinSec, AxisMaxSec, MeasurementSegment);
    RenderFlowChart(ChartDeviceFlow, FFlowGraphHistory.DeviceSeries, 'Расход поверяемых приборов',
      VisibleXMinMs, VisibleXMaxMs, AxisMinSec, AxisMaxSec, MeasurementSegment);
  end;
  FLastGraphRunActive := RunActive;
end;

procedure TFrameMainTable.AttachGraphsTo(AParent: TFmxObject);
begin
  if AParent = nil then
    Exit;

  { The embedded work-table graphs tab is legacy.  The current graphs
    workspace belongs to the main form and is opened by its own button. }
  if TabItemWorkTableGraphs <> nil then
  begin
    TabItemWorkTableGraphs.Visible := False;
    TabItemWorkTableGraphs.Parent := nil;
  end;

  if FGraphsWorkspace = nil then
  begin
    FGraphsWorkspace := TFrameGraphsWorkspace.Create(Self);
    FGraphsWorkspace.Parent := AParent;
    FGraphsWorkspace.Align := TAlignLayout.Client;
  end
  else if FGraphsWorkspace.Parent <> AParent then
    FGraphsWorkspace.Parent := AParent;

  FGraphsWorkspace.Initialize(FActiveWorkTable);
end;

procedure TFrameMainTable.BuildGraphsSettingsPanel;
var
  Caption: TLabel;
  ClearButton, ResetButton: TButton;
begin
  if FGraphsSettings = nil then
    Exit;
  FGraphSettingsToggle := TButton.Create(FGraphsSettings);
  FGraphSettingsToggle.Parent := FGraphsSettings;
  FGraphSettingsToggle.Align := TAlignLayout.Top;
  FGraphSettingsToggle.Height := 36;
  FGraphSettingsToggle.Text := '<';
  FGraphSettingsToggle.OnClick := GraphSettingsToggleClick;

  FGraphsSettingsContent := TVertScrollBox.Create(FGraphsSettings);
  FGraphsSettingsContent.Parent := FGraphsSettings;
  FGraphsSettingsContent.Align := TAlignLayout.Client;

  Caption := TLabel.Create(FGraphsSettingsContent);
  Caption.Parent := FGraphsSettingsContent;
  Caption.Position.Point := PointF(12, 12);
  Caption.Width := 290;
  Caption.Height := 32;
  Caption.Text := 'Общие настройки графиков';
  Caption.TextSettings.Font.Style := [TFontStyle.fsBold];

  FGraphCountCombo := TComboBox.Create(FGraphsSettingsContent);
  FGraphCountCombo.Parent := FGraphsSettingsContent;
  FGraphCountCombo.Position.Point := PointF(12, 52);
  FGraphCountCombo.Width := 290;
  FGraphCountCombo.Items.Add('1 график');
  FGraphCountCombo.Items.Add('2 графика');
  FGraphCountCombo.Items.Add('3 графика');
  FGraphCountCombo.Items.Add('4 графика');
  FGraphCountCombo.ItemIndex := FGraphsViewConfig.GraphCount - 1;
  FGraphCountCombo.OnChange := GraphCountChange;

  FGraphLayoutCombo := TComboBox.Create(FGraphsSettingsContent);
  FGraphLayoutCombo.Parent := FGraphsSettingsContent;
  FGraphLayoutCombo.Position.Point := PointF(12, 98);
  FGraphLayoutCombo.Width := 290;
  FGraphLayoutCombo.Items.Add('1 область');
  FGraphLayoutCombo.Items.Add('2 области по вертикали');
  FGraphLayoutCombo.Items.Add('2 области по горизонтали');
  FGraphLayoutCombo.Items.Add('3 области');
  FGraphLayoutCombo.Items.Add('4 области сеткой 2x2');
  FGraphLayoutCombo.ItemIndex := Ord(FGraphsViewConfig.LayoutKind);
  FGraphLayoutCombo.OnChange := GraphLayoutChange;

  FGraphLegendCheck := TCheckBox.Create(FGraphsSettingsContent);
  FGraphLegendCheck.Parent := FGraphsSettingsContent;
  FGraphLegendCheck.Position.Point := PointF(12, 144);
  FGraphLegendCheck.Width := 290;
  FGraphLegendCheck.Text := 'Показывать легенду справа';
  FGraphLegendCheck.IsChecked := FGraphsViewConfig.ShowLegend;
  FGraphLegendCheck.OnChange := GraphLegendChange;

  ClearButton := TButton.Create(FGraphsSettingsContent);
  ClearButton.Parent := FGraphsSettingsContent;
  ClearButton.Position.Point := PointF(12, 194);
  ClearButton.Width := 290;
  ClearButton.Text := 'Очистить все графики';
  ClearButton.OnClick := ButtonClearFlowGraphsClick;

  ResetButton := TButton.Create(FGraphsSettingsContent);
  ResetButton.Parent := FGraphsSettingsContent;
  ResetButton.Position.Point := PointF(12, 240);
  ResetButton.Width := 290;
  ResetButton.Text := 'Сбросить настройки графиков';
  ResetButton.OnClick := ResetGraphSettingsClick;

  Caption := TLabel.Create(FGraphsSettingsContent);
  Caption.Parent := FGraphsSettingsContent;
  Caption.Position.Point := PointF(12, 294);
  Caption.Width := 290;
  Caption.Height := 32;
  Caption.Text := 'Серии выбранного графика';
  Caption.TextSettings.Font.Style := [TFontStyle.fsBold];

  FSelectedGraphLegend := TFlowLayout.Create(FGraphsSettingsContent);
  FSelectedGraphLegend.Parent := FGraphsSettingsContent;
  FSelectedGraphLegend.Position.Point := PointF(12, 330);
  FSelectedGraphLegend.Width := 290;
  FSelectedGraphLegend.Height := 300;
  FSelectedGraphLegend.FlowDirection := TFlowDirection.LeftToRight;
end;

procedure TFrameMainTable.GraphSettingsToggleClick(Sender: TObject);
begin
  if FInitializingGraphs then
    Exit;
  FGraphsViewConfig.SettingsPanelVisible :=
    not FGraphsViewConfig.SettingsPanelVisible;
  FGraphsSettingsContent.Visible := FGraphsViewConfig.SettingsPanelVisible;
  if FGraphsViewConfig.SettingsPanelVisible then
  begin
    FGraphsSettings.Width := FGraphsSettingsWidth;
    FGraphSettingsToggle.Text := '<';
  end
  else
  begin
    FGraphsSettings.Width := 38;
    FGraphSettingsToggle.Text := '>';
  end;
  ApplyGraphsLayout;
end;

procedure TFrameMainTable.GraphCountChange(Sender: TObject);
begin
  if FInitializingGraphs or FUpdatingGraphsSettings then
    Exit;
  if FGraphCountCombo.ItemIndex < 0 then
    Exit;
  FGraphsViewConfig.EnsurePanelCount(FGraphCountCombo.ItemIndex + 1);
  case FGraphsViewConfig.GraphCount of
    1: FGraphsViewConfig.LayoutKind := glSingle;
    2: if not (FGraphsViewConfig.LayoutKind in [glTwoRows, glTwoColumns]) then
         FGraphsViewConfig.LayoutKind := glTwoRows;
    3: FGraphsViewConfig.LayoutKind := glThreePanels;
    4: FGraphsViewConfig.LayoutKind := glGrid2x2;
  end;
  SyncGraphsSettingsControls;
  ApplyGraphsLayout;
end;

procedure TFrameMainTable.GraphLayoutChange(Sender: TObject);
begin
  if FInitializingGraphs or FUpdatingGraphsSettings then
    Exit;
  if FGraphLayoutCombo.ItemIndex < 0 then
    Exit;
  FGraphsViewConfig.LayoutKind := TGraphLayoutKind(FGraphLayoutCombo.ItemIndex);
  case FGraphsViewConfig.LayoutKind of
    glSingle: FGraphsViewConfig.GraphCount := 1;
    glTwoRows, glTwoColumns: FGraphsViewConfig.GraphCount := 2;
    glThreePanels: FGraphsViewConfig.GraphCount := 3;
    glGrid2x2: FGraphsViewConfig.GraphCount := 4;
  end;
  FGraphsViewConfig.EnsurePanelCount(FGraphsViewConfig.GraphCount);
  SyncGraphsSettingsControls;
  ApplyGraphsLayout;
end;

procedure TFrameMainTable.GraphLegendChange(Sender: TObject);
begin
  if FInitializingGraphs or FUpdatingGraphsSettings then
    Exit;
  FGraphsViewConfig.ShowLegend := FGraphLegendCheck.IsChecked;
  RebuildSelectedGraphLegend;
end;

procedure TFrameMainTable.ResetGraphSettingsClick(Sender: TObject);
begin
  if FInitializingGraphs then
    Exit;
  FGraphsViewConfig.Reset;
  SyncGraphsSettingsControls;
  ApplyGraphsLayout;
end;

procedure TFrameMainTable.SyncGraphsSettingsControls;
begin
  FUpdatingGraphsSettings := True;
  try
    FGraphCountCombo.ItemIndex := FGraphsViewConfig.GraphCount - 1;
    FGraphLayoutCombo.ItemIndex := Ord(FGraphsViewConfig.LayoutKind);
    FGraphLegendCheck.IsChecked := FGraphsViewConfig.ShowLegend;
  finally
    FUpdatingGraphsSettings := False;
  end;
end;

procedure TFrameMainTable.ApplyGraphsLayout;
var
  RowTop, RowBottom: TLayout;
  Splitter: TSplitter;
  I: Integer;
  Details: string;

  function AddContainer(AParent: TFmxObject; AAlign: TAlignLayout): TLayout;
  begin
    Result := TLayout.Create(nil);
    Result.Parent := AParent;
    Result.Align := AAlign;
    FGraphLayoutContainers.Add(Result);
  end;

  function AddSplitter(AParent: TFmxObject; AAlign: TAlignLayout): TSplitter;
  begin
    Result := TSplitter.Create(nil);
    Result.Parent := AParent;
    Result.Align := AAlign;
    Result.MinSize := 80;
    if AAlign = TAlignLayout.Left then
      Result.Width := 6
    else
      Result.Height := 6;
    FGraphSplitters.Add(Result);
  end;
begin
  if (FGraphsViewConfig = nil) or (LayoutGraphsClient = nil) then
    Exit;
  EnsureGraphViewCount(FGraphsViewConfig.GraphCount);
  ClearGraphsLayout;
  case FGraphsViewConfig.LayoutKind of
    glSingle:
      FGraphViews[0].Root.Align := TAlignLayout.Client;
    glTwoRows:
      begin
        FGraphViews[0].Root.Align := TAlignLayout.Top;
        FGraphViews[0].Root.Height := Max(180, LayoutGraphsClient.Height / 2);
        AddSplitter(LayoutGraphsClient, TAlignLayout.Top);
        FGraphViews[1].Root.Align := TAlignLayout.Client;
      end;
    glTwoColumns:
      begin
        FGraphViews[0].Root.Align := TAlignLayout.Left;
        FGraphViews[0].Root.Width := Max(260, LayoutGraphsClient.Width / 2);
        AddSplitter(LayoutGraphsClient, TAlignLayout.Left);
        FGraphViews[1].Root.Align := TAlignLayout.Client;
      end;
    glThreePanels:
      begin
        FGraphViews[0].Root.Align := TAlignLayout.Top;
        FGraphViews[0].Root.Height := Max(180, LayoutGraphsClient.Height / 2);
        AddSplitter(LayoutGraphsClient, TAlignLayout.Top);
        RowBottom := AddContainer(LayoutGraphsClient, TAlignLayout.Client);
        FGraphViews[1].Root.Parent := RowBottom;
        FGraphViews[1].Root.Align := TAlignLayout.Left;
        FGraphViews[1].Root.Width := Max(220, LayoutGraphsClient.Width / 2);
        AddSplitter(RowBottom, TAlignLayout.Left);
        FGraphViews[2].Root.Parent := RowBottom;
        FGraphViews[2].Root.Align := TAlignLayout.Client;
      end;
    glGrid2x2:
      begin
        RowTop := AddContainer(LayoutGraphsClient, TAlignLayout.Top);
        RowTop.Height := Max(180, LayoutGraphsClient.Height / 2);
        FGraphViews[0].Root.Parent := RowTop;
        FGraphViews[0].Root.Align := TAlignLayout.Left;
        FGraphViews[0].Root.Width := Max(220, LayoutGraphsClient.Width / 2);
        AddSplitter(RowTop, TAlignLayout.Left);
        FGraphViews[1].Root.Parent := RowTop;
        FGraphViews[1].Root.Align := TAlignLayout.Client;
        AddSplitter(LayoutGraphsClient, TAlignLayout.Top);
        RowBottom := AddContainer(LayoutGraphsClient, TAlignLayout.Client);
        FGraphViews[2].Root.Parent := RowBottom;
        FGraphViews[2].Root.Align := TAlignLayout.Left;
        FGraphViews[2].Root.Width := Max(220, LayoutGraphsClient.Width / 2);
        AddSplitter(RowBottom, TAlignLayout.Left);
        FGraphViews[3].Root.Parent := RowBottom;
        FGraphViews[3].Root.Align := TAlignLayout.Client;
      end;
  end;
  for I := 0 to FGraphViews.Count - 1 do
    FGraphViews[I].LegendHost.Visible := False;
  // Alignment is recalculated automatically after Parent/Align changes.  Realign
  // is protected in FMX and therefore cannot be called from the frame.
  LayoutGraphsClient.Repaint;
  QueueRenderGraphViews;
  Details := '';
  for I := 0 to FGraphsViewConfig.GraphCount - 1 do
    Details := Details + Format(' G%d=%.0fx%.0f;', [I + 1,
      FGraphViews[I].Root.Width, FGraphViews[I].Root.Height]);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcInfo, psForm, 'GraphsLayoutApplied',
      'Схема графиков применена', Format('GraphCount=%d; LayoutKind=%d; Views=%d;%s',
      [FGraphsViewConfig.GraphCount, Ord(FGraphsViewConfig.LayoutKind),
       FGraphViews.Count, Details]));
end;

procedure TFrameMainTable.EnsureGraphViewCount(const ACount: Integer);
var
  Wanted, I: Integer;
  View: TGraphPanelView;
begin
  Wanted := EnsureRange(ACount, 1, 4);
  while FGraphViews.Count < Wanted do
  begin
    View := TGraphPanelView.Create(Self, LayoutGraphsClient, FGraphViews.Count);
    View.PopupMenu.OnPopup := GraphPopupMenuPopup;
    View.Root.Tag := View.GraphIndex;
    View.Root.OnClick := GraphViewClick;
    View.Header.Tag := View.GraphIndex;
    View.Header.OnClick := GraphViewClick;
    View.TitleLabel.Tag := View.GraphIndex;
    View.TitleLabel.OnClick := GraphViewClick;
    View.Chart.Tag := View.GraphIndex;
    View.Chart.OnClick := GraphViewClick;
    View.LegendHost.Tag := View.GraphIndex;
    View.LegendHost.OnClick := GraphViewClick;
    FGraphViews.Add(View);
  end;
  for I := 0 to FGraphViews.Count - 1 do
    FGraphViews[I].Root.Visible := I < Wanted;
end;

procedure TFrameMainTable.ClearGraphsLayout;
var
  I: Integer;
  GraphView: TGraphPanelView;
  Splitter: TSplitter;
  Container: TLayout;
begin
  if FGraphViews <> nil then
    for GraphView in FGraphViews do
      if (GraphView <> nil) and (GraphView.Root <> nil) then
      begin
        GraphView.Root.Parent := LayoutGraphsClient;
        GraphView.Root.Align := TAlignLayout.None;
        GraphView.Root.Width := 0;
        GraphView.Root.Height := 0;
      end;

  if FGraphSplitters <> nil then
    for I := FGraphSplitters.Count - 1 downto 0 do
    begin
      Splitter := FGraphSplitters[I];
      FGraphSplitters.Delete(I);

      if Splitter <> nil then
      begin
        Splitter.Parent := nil;
        Splitter.Free;
      end;
    end;

  if FGraphLayoutContainers <> nil then
    for I := FGraphLayoutContainers.Count - 1 downto 0 do
    begin
      Container := FGraphLayoutContainers[I];
      FGraphLayoutContainers.Delete(I);

      if Container <> nil then
      begin
        Container.Parent := nil;
        Container.Free;
      end;
    end;
end;

procedure TFrameMainTable.DetachGraphViewEvents;
var
  View: TGraphPanelView;
begin
  if FGraphViews = nil then
    Exit;

  for View in FGraphViews do
  begin
    if View = nil then
      Continue;

    if View.Root <> nil then
    begin
      View.Root.OnClick := nil;
      View.Root.PopupMenu := nil;
    end;
    if View.Header <> nil then
      View.Header.OnClick := nil;
    if View.TitleLabel <> nil then
      View.TitleLabel.OnClick := nil;
    if View.Chart <> nil then
      View.Chart.OnClick := nil;
    if View.LegendHost <> nil then
      View.LegendHost.OnClick := nil;
    if View.PopupMenu <> nil then
      View.PopupMenu.OnPopup := nil;
  end;
end;

procedure TFrameMainTable.GraphViewClick(Sender: TObject);
var
  I: Integer;
begin
  if not (Sender is TControl) then
    Exit;
  FSelectedGraphIndex := TControl(Sender).Tag;
  for I := 0 to FGraphViews.Count - 1 do
    if I = FSelectedGraphIndex then
      FGraphViews[I].TitleLabel.TextSettings.FontColor := TAlphaColors.Dodgerblue
    else
      FGraphViews[I].TitleLabel.TextSettings.FontColor := TAlphaColors.Black;
  RebuildSelectedGraphLegend;
end;

procedure TFrameMainTable.GraphPopupMenuPopup(Sender: TObject);
var
  I: Integer;
begin
  if not (Sender is TPopupMenu) then
    Exit;

  if FGraphViews = nil then
    Exit;
  for I := 0 to FGraphViews.Count - 1 do
    if (FGraphViews[I] <> nil) and (FGraphViews[I].PopupMenu = Sender) then
    begin
      RebuildGraphPopupMenu(FGraphViews[I].PopupMenu,
        FGraphViews[I].GraphIndex);
      Exit;
    end;
end;

procedure TFrameMainTable.RebuildGraphPopupMenu(APopupMenu: TPopupMenu;
  const AGraphIndex: Integer);
const
  ColorNames: array[0..11] of string = ('Синий', 'Красный', 'Зелёный',
    'Оранжевый', 'Фиолетовый', 'Бирюзовый', 'Жёлтый', 'Коричневый',
    'Индиго', 'Салатовый', 'Розовый', 'Серый');
var
  AddRoot, FlowRoot, EtalonRoot, DeviceRoot, RemoveRoot, VisibilityRoot,
  SettingsRoot, LineModeRoot, ValueModeRoot, ScaleRoot, ColorRoot, PointColorRoot,
  LineColorRoot, SeriesRoot, Item: TMenuItem;
  I, ColorIndex: Integer;
  CurrentPair: TPair<string, TFlowGraphSeries>;

  function AddItem(AParent: TFmxObject; const ACaption, ACommand: string): TMenuItem;
  begin
    Result := TMenuItem.Create(APopupMenu);
    Result.Text := ACaption;
    Result.TagString := ACommand;
    Result.OnClick := GraphMenuClick;
    Result.Parent := AParent;
  end;

  procedure AddSources(ADictionary: TObjectDictionary<string, TFlowGraphSeries>;
    AParent: TMenuItem);
  var
    SourcePair: TPair<string, TFlowGraphSeries>;
  begin
    for SourcePair in ADictionary do
      if (SourcePair.Value <> nil) and SourcePair.Value.ChannelAvailable then
        AddItem(AParent, SourcePair.Value.Caption,
          Format('add|%d|%s', [AGraphIndex, SourcePair.Key]));
  end;

  procedure AddCurrent(ARoot: TMenuItem; const ACommand: string);
  var
    CurrentPair: TPair<string, TFlowGraphSeries>;
  begin
    for CurrentPair in FFlowGraphHistory.EtalonSeries do
      if (CurrentPair.Value <> nil) and
         (CurrentPair.Value.GraphIndex = AGraphIndex) then
        AddItem(ARoot, CurrentPair.Value.Caption, ACommand + '|' +
          IntToStr(AGraphIndex) + '|' + CurrentPair.Key);
    for CurrentPair in FFlowGraphHistory.DeviceSeries do
      if (CurrentPair.Value <> nil) and
         (CurrentPair.Value.GraphIndex = AGraphIndex) then
        AddItem(ARoot, CurrentPair.Value.Caption, ACommand + '|' +
          IntToStr(AGraphIndex) + '|' + CurrentPair.Key);
  end;
begin
  if (APopupMenu = nil) or (FFlowGraphHistory = nil) or
     (FGraphsViewConfig = nil) or (AGraphIndex < 0) or
     (AGraphIndex >= FGraphsViewConfig.Panels.Count) then
    Exit;
  for I := APopupMenu.ChildrenCount - 1 downto 0 do
    APopupMenu.Children[I].Free;
  AddRoot := AddItem(APopupMenu, 'Добавить серию', '');
  FlowRoot := AddItem(AddRoot, 'Расход', '');
  EtalonRoot := AddItem(FlowRoot, 'Эталоны', '');
  DeviceRoot := AddItem(FlowRoot, 'Приборы', '');
  AddSources(FFlowGraphHistory.EtalonSeries, EtalonRoot);
  AddSources(FFlowGraphHistory.DeviceSeries, DeviceRoot);
  RemoveRoot := AddItem(APopupMenu, 'Удалить серию', '');
  AddCurrent(RemoveRoot, 'remove');
  AddItem(APopupMenu, 'Очистить график',
    Format('clear|%d|', [AGraphIndex]));
  AddItem(APopupMenu, 'Переименовать график', 'rename|' +
    IntToStr(AGraphIndex) + '|');
  AddItem(APopupMenu, 'Автомасштаб', 'autoscale|' +
    IntToStr(AGraphIndex) + '|');
  AddItem(APopupMenu, 'Сброс масштаба', 'autoscale|' +
    IntToStr(AGraphIndex) + '|');
  VisibilityRoot := AddItem(APopupMenu, 'Видимость серий', '');
  for CurrentPair in FFlowGraphHistory.EtalonSeries do
    if (CurrentPair.Value <> nil) and
       (CurrentPair.Value.GraphIndex = AGraphIndex) then
    begin
      Item := AddItem(VisibilityRoot, CurrentPair.Value.Caption, 'visible|' +
        IntToStr(AGraphIndex) + '|' + CurrentPair.Key);
      Item.IsChecked := CurrentPair.Value.UserVisible;
    end;
  for CurrentPair in FFlowGraphHistory.DeviceSeries do
    if (CurrentPair.Value <> nil) and
       (CurrentPair.Value.GraphIndex = AGraphIndex) then
    begin
      Item := AddItem(VisibilityRoot, CurrentPair.Value.Caption, 'visible|' +
        IntToStr(AGraphIndex) + '|' + CurrentPair.Key);
      Item.IsChecked := CurrentPair.Value.UserVisible;
    end;

  SettingsRoot := AddItem(APopupMenu, 'Настройки', '');
  LineModeRoot := AddItem(SettingsRoot, 'Линия значений', '');
  Item := AddItem(LineModeRoot, 'PCHIP по времени',
    Format('linemode|%d|pchip', [AGraphIndex]));
  Item.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].LineMode = glmPchipTime;
  Item := AddItem(LineModeRoot, 'Прямые отрезки',
    Format('linemode|%d|linear', [AGraphIndex]));
  Item.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].LineMode = glmLinearSegments;

  ValueModeRoot := AddItem(SettingsRoot, 'Отображаемое значение', '');
  Item := AddItem(ValueModeRoot, 'Расход',
    Format('valuemode|%d|flow', [AGraphIndex]));
  Item.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].ValueMode = gvmFlow;
  Item := AddItem(ValueModeRoot, 'Погрешность',
    Format('valuemode|%d|error', [AGraphIndex]));
  Item.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].ValueMode = gvmError;

  ScaleRoot := AddItem(SettingsRoot, 'Шкала расхода', '');
  ScaleRoot.Enabled :=
    FGraphsViewConfig.Panels[AGraphIndex].ValueMode = gvmFlow;
  Item := AddItem(ScaleRoot, 'Логарифмическая',
    Format('flowscale|%d|log', [AGraphIndex]));
  Item.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].FlowScale = gfsLogarithmic;
  Item := AddItem(ScaleRoot, 'Обычная',
    Format('flowscale|%d|linear', [AGraphIndex]));
  Item.IsChecked :=
    FGraphsViewConfig.Panels[AGraphIndex].FlowScale = gfsLinear;

  ColorRoot := AddItem(APopupMenu, 'Настроить цвета', '');
  for CurrentPair in FFlowGraphHistory.EtalonSeries do
    if (CurrentPair.Value <> nil) and
       (CurrentPair.Value.GraphIndex = AGraphIndex) then
    begin
      SeriesRoot := AddItem(ColorRoot, CurrentPair.Value.Caption, '');
      PointColorRoot := AddItem(SeriesRoot, 'Цвет точек', '');
      LineColorRoot := AddItem(SeriesRoot, 'Цвет линии', '');
      for ColorIndex := Low(FLOW_GRAPH_COLORS) to High(FLOW_GRAPH_COLORS) do
      begin
        Item := AddItem(PointColorRoot, ColorNames[ColorIndex],
          Format('pointcolor|%d|%s|%d', [AGraphIndex,
            CurrentPair.Key, ColorIndex]));
        Item.IsChecked :=
          CurrentPair.Value.PointColor = FLOW_GRAPH_COLORS[ColorIndex];
        Item := AddItem(LineColorRoot, ColorNames[ColorIndex],
          Format('linecolor|%d|%s|%d', [AGraphIndex,
            CurrentPair.Key, ColorIndex]));
        Item.IsChecked :=
          CurrentPair.Value.LineColor = FLOW_GRAPH_COLORS[ColorIndex];
      end;
    end;
  for CurrentPair in FFlowGraphHistory.DeviceSeries do
    if (CurrentPair.Value <> nil) and
       (CurrentPair.Value.GraphIndex = AGraphIndex) then
    begin
      SeriesRoot := AddItem(ColorRoot, CurrentPair.Value.Caption, '');
      PointColorRoot := AddItem(SeriesRoot, 'Цвет точек', '');
      LineColorRoot := AddItem(SeriesRoot, 'Цвет линии', '');
      for ColorIndex := Low(FLOW_GRAPH_COLORS) to High(FLOW_GRAPH_COLORS) do
      begin
        Item := AddItem(PointColorRoot, ColorNames[ColorIndex],
          Format('pointcolor|%d|%s|%d', [AGraphIndex,
            CurrentPair.Key, ColorIndex]));
        Item.IsChecked :=
          CurrentPair.Value.PointColor = FLOW_GRAPH_COLORS[ColorIndex];
        Item := AddItem(LineColorRoot, ColorNames[ColorIndex],
          Format('linecolor|%d|%s|%d', [AGraphIndex,
            CurrentPair.Key, ColorIndex]));
        Item.IsChecked :=
          CurrentPair.Value.LineColor = FLOW_GRAPH_COLORS[ColorIndex];
      end;
    end;
end;

procedure TFrameMainTable.GraphMenuClick(Sender: TObject);
var
  Parts: TArray<string>;
  Command, Key: string;
  GraphIndex, ColorIndex: Integer;
  Series: TFlowGraphSeries;

  function FindSeries: TFlowGraphSeries;
  begin
    Result := nil;
    if not FFlowGraphHistory.EtalonSeries.TryGetValue(Key, Result) then
      FFlowGraphHistory.DeviceSeries.TryGetValue(Key, Result);
  end;
begin
  if not (Sender is TMenuItem) or (TMenuItem(Sender).TagString = '') then
    Exit;
  Parts := TMenuItem(Sender).TagString.Split(['|']);
  if Length(Parts) < 2 then
    Exit;
  Command := Parts[0];
  GraphIndex := StrToIntDef(Parts[1], 0);
  Key := '';
  if Length(Parts) > 2 then
    Key := Parts[2];
  Series := FindSeries;
  if SameText(Command, 'add') and (Series <> nil) then
  begin
    Series.GraphIndex := GraphIndex;
    Series.UserVisible := True;
  end
  else if SameText(Command, 'remove') and (Series <> nil) then
    Series.GraphIndex := -1
  else if SameText(Command, 'clear') then
  begin
    for Series in FFlowGraphHistory.EtalonSeries.Values do
      if Series.GraphIndex = GraphIndex then
        Series.Samples.Clear;
    for Series in FFlowGraphHistory.DeviceSeries.Values do
      if Series.GraphIndex = GraphIndex then
        Series.Samples.Clear;
  end
  else if SameText(Command, 'visible') and (Series <> nil) then
    Series.UserVisible := not Series.UserVisible
  else if SameText(Command, 'pointcolor') and (Series <> nil) and
          (Length(Parts) > 3) then
  begin
    ColorIndex := EnsureRange(StrToIntDef(Parts[3], 0),
      Low(FLOW_GRAPH_COLORS), High(FLOW_GRAPH_COLORS));
    Series.PointColor := FLOW_GRAPH_COLORS[ColorIndex];
  end
  else if SameText(Command, 'linecolor') and (Series <> nil) and
          (Length(Parts) > 3) then
  begin
    ColorIndex := EnsureRange(StrToIntDef(Parts[3], 0),
      Low(FLOW_GRAPH_COLORS), High(FLOW_GRAPH_COLORS));
    Series.LineColor := FLOW_GRAPH_COLORS[ColorIndex];
  end
  else if SameText(Command, 'linemode') and
          (GraphIndex >= 0) and
          (GraphIndex < FGraphsViewConfig.Panels.Count) then
  begin
    if SameText(Key, 'pchip') then
      FGraphsViewConfig.Panels[GraphIndex].LineMode := glmPchipTime
    else if SameText(Key, 'linear') then
      FGraphsViewConfig.Panels[GraphIndex].LineMode := glmLinearSegments;
  end
  else if SameText(Command, 'valuemode') and
          (GraphIndex >= 0) and
          (GraphIndex < FGraphsViewConfig.Panels.Count) then
  begin
    if SameText(Key, 'flow') then
      FGraphsViewConfig.Panels[GraphIndex].ValueMode := gvmFlow
    else if SameText(Key, 'error') then
      FGraphsViewConfig.Panels[GraphIndex].ValueMode := gvmError;
  end
  else if SameText(Command, 'flowscale') and
          (GraphIndex >= 0) and
          (GraphIndex < FGraphsViewConfig.Panels.Count) then
  begin
    if SameText(Key, 'log') then
      FGraphsViewConfig.Panels[GraphIndex].FlowScale := gfsLogarithmic
    else if SameText(Key, 'linear') then
      FGraphsViewConfig.Panels[GraphIndex].FlowScale := gfsLinear;
  end;
  RebuildSelectedGraphLegend;
  if (FGraphViews <> nil) and (FGraphViews.Count > 0) then
    QueueRenderGraphViews
  else
  begin
    UpdateEtalonFlowChart;
    UpdateDeviceFlowChart;
  end;
end;

procedure TFrameMainTable.RebuildSelectedGraphLegend;
var
  I: Integer;

  procedure AddDictionary(
    ADictionary: TObjectDictionary<string, TFlowGraphSeries>);
  var
    LegendPair: TPair<string, TFlowGraphSeries>;
    Marker: TRectangle;
    CheckBox: TCheckBox;
  begin
    if ADictionary = nil then
      Exit;
    for LegendPair in ADictionary do
    begin
      if (LegendPair.Value = nil) or
         (LegendPair.Value.GraphIndex <> FSelectedGraphIndex) then
        Continue;
      Marker := TRectangle.Create(FSelectedGraphLegend);
      Marker.Parent := FSelectedGraphLegend;
      Marker.Width := 16;
      Marker.Height := 16;
      Marker.Fill.Color := LegendPair.Value.LineColor;
      Marker.Stroke.Kind := TBrushKind.None;
      CheckBox := TCheckBox.Create(FSelectedGraphLegend);
      CheckBox.Parent := FSelectedGraphLegend;
      CheckBox.Width := 250;
      CheckBox.Height := 28;
      CheckBox.Text := LegendPair.Value.Caption;
      CheckBox.TagString := LegendPair.Key;
      CheckBox.IsChecked := LegendPair.Value.UserVisible;
      CheckBox.Enabled := LegendPair.Value.ChannelAvailable;
      CheckBox.OnChange := FlowGraphCheckBoxChange;
    end;
  end;
begin
  if (FSelectedGraphLegend = nil) or (FFlowGraphHistory = nil) then
    Exit;
  for I := FSelectedGraphLegend.ChildrenCount - 1 downto 0 do
    FSelectedGraphLegend.Children[I].Free;
  FSelectedGraphLegend.Visible := (FGraphsViewConfig <> nil) and
    FGraphsViewConfig.ShowLegend;
  if not FSelectedGraphLegend.Visible then
    Exit;
  AddDictionary(FFlowGraphHistory.EtalonSeries);
  AddDictionary(FFlowGraphHistory.DeviceSeries);
end;

procedure TFrameMainTable.QueueRenderGraphViews;
begin
  if FDestroying or
     FInitializingGraphs or
     FGraphRenderQueued then
    Exit;

  if FGraphRenderTimer = nil then
    Exit;

  FGraphRenderQueued := True;
  FGraphRenderTimer.Enabled := False;
  FGraphRenderTimer.Enabled := True;
end;

procedure TFrameMainTable.GraphRenderTimerTimer(Sender: TObject);
begin
  if FDestroying then
  begin
    if FGraphRenderTimer <> nil then
      FGraphRenderTimer.Enabled := False;
    Exit;
  end;

  if FGraphRenderTimer <> nil then
    FGraphRenderTimer.Enabled := False;
  FGraphRenderQueued := False;
  if FDestroying or (csDestroying in ComponentState) then
    Exit;
  RenderGraphViews;
end;

procedure TFrameMainTable.RenderConfiguredGraph(AView: TGraphPanelView);
var
  Combined: TObjectDictionary<string, TFlowGraphSeries>;
  BaseMs: Int64;
  AxisMinSec, AxisMaxSec: Double;

  procedure AddDictionary(ADictionary: TObjectDictionary<string, TFlowGraphSeries>);
  var
    DictionaryPair: TPair<string, TFlowGraphSeries>;
  begin
    if ADictionary = nil then
      Exit;
    for DictionaryPair in ADictionary do
      if (DictionaryPair.Value <> nil) and
         (DictionaryPair.Value.GraphIndex = AView.GraphIndex) then
        Combined.AddOrSetValue(DictionaryPair.Key, DictionaryPair.Value);
  end;
begin
  if (AView = nil) or (AView.Chart = nil) or
     (FFlowGraphHistory = nil) or (FGraphsViewConfig = nil) then
    Exit;
  if (AView.GraphIndex < 0) or
     (AView.GraphIndex >= FGraphsViewConfig.Panels.Count) then
    Exit;
  Combined := TObjectDictionary<string, TFlowGraphSeries>.Create([]);
  try
    AddDictionary(FFlowGraphHistory.EtalonSeries);
    AddDictionary(FFlowGraphHistory.DeviceSeries);
    BaseMs := FGraphMonitorStartMs;
    if FCurrentGraphPointStartMs > 0 then
      BaseMs := FCurrentGraphPointStartMs;
    AxisMinSec := 0;
    AxisMaxSec := GraphVisibleWindowSec;
    if BaseMs > 0 then
    begin
      AxisMinSec := Max(0.0, (FFlowGraphXMin - BaseMs) / 1000.0);
      AxisMaxSec := Max(GraphVisibleWindowSec, (FFlowGraphXMax - BaseMs) / 1000.0);
    end;
    RenderFlowChart(AView.Chart, Combined,
      FGraphsViewConfig.Panels[AView.GraphIndex].Title, FFlowGraphXMin,
      FFlowGraphXMax, AxisMinSec, AxisMaxSec, FCurrentGraphPointStartMs > 0);

    AView.EmptyLabel.Visible := Combined.Count = 0;
  finally
    Combined.Free;
  end;
end;

procedure TFrameMainTable.RenderGraphViews;
var
  I, Count: Integer;
begin
  if FDestroying then
    Exit;

  if FRenderingGraphViews then
    Exit;
  if (FGraphViews = nil) or (FGraphsViewConfig = nil) then
    Exit;
  FRenderingGraphViews := True;
  try
    Count := Min(FGraphsViewConfig.GraphCount, FGraphViews.Count);
    for I := 0 to Count - 1 do
      if (FGraphViews[I] <> nil) and (FGraphViews[I].Root <> nil) and
         FGraphViews[I].Root.Visible then
        RenderConfiguredGraph(FGraphViews[I]);
  finally
    FRenderingGraphViews := False;
  end;
end;

function TFrameMainTable.ResolveGraphSeriesMeterValue(
  const ASeries: TGraphSeriesConfig): TMeterValue;
var
  Channels: TObjectList<TChannel>;
  Channel: TChannel;
begin
  Result := nil;
  if (ASeries = nil) or (FActiveWorkTable = nil) then
    Exit;
  if ASeries.OwnerKind = gsokWorkTable then
  begin
    if SameText(ASeries.MeterValueKey, 'FlowRate') or
       SameText(ASeries.MeterValueKey, 'ValueFlow') then
      Exit(FActiveWorkTable.ValueFlowRate);
    if SameText(ASeries.MeterValueKey, 'FluidTemp') and
       (FActiveWorkTable.FluidTemp <> nil) then
      Exit(FActiveWorkTable.FluidTemp.Value);
    if SameText(ASeries.MeterValueKey, 'FluidPress') and
       (FActiveWorkTable.FluidPress <> nil) then
      Exit(FActiveWorkTable.FluidPress.Value);
    if SameText(ASeries.MeterValueKey, 'ValueQuantity') or
       SameText(ASeries.MeterValueKey, 'Volume') then
      Exit(FActiveWorkTable.ValueQuantity);
    Exit;
  end;
  if ASeries.OwnerKind = gsokEtalon then
    Channels := FActiveWorkTable.EtalonChannels
  else if ASeries.OwnerKind = gsokDevice then
    Channels := FActiveWorkTable.DeviceChannels
  else
    Exit;
  for Channel in Channels do
    if (Channel <> nil) and SameText(Channel.UUID, ASeries.ChannelUUID) then
    begin
      if (Channel.FlowMeter <> nil) and
         (SameText(ASeries.MeterValueKey, 'FlowRate') or
          SameText(ASeries.MeterValueKey, 'ValueFlow')) then
        Result := Channel.FlowMeter.ValueFlow;
      if (Channel.FlowMeter <> nil) and
         (SameText(ASeries.MeterValueKey, 'ValueQuantity') or
          SameText(ASeries.MeterValueKey, 'Volume') or
          SameText(ASeries.MeterValueKey, 'Mass')) then
        Result := Channel.FlowMeter.ValueQuantity;
      Exit;
    end;
end;

procedure TFrameMainTable.ButtonClearFlowGraphsClick(Sender: TObject);
begin
  EnsureFlowGraphDictionaries;
  if FFlowGraphHistory <> nil then
    FFlowGraphHistory.Clear;
  FLastFlowGraphSampleMs := 0;
  FGraphChannelsReady := False;
  RefreshFlowGraphChannels('ButtonClearFlowGraphsClick');
  UpdateEtalonFlowChart;
  UpdateDeviceFlowChart;
end;


procedure TFrameMainTable.UpdateUIFromValues;
var
  WorkTable: TWorkTable;
  I: Integer;
  MinImpTotalValue: TMeterValue;
  RawValueBaseMultiplier: TMeterValue;
  RawQuantityBaseMultiplier: TMeterValue;
  Channel: TChannel;
  UiLogTick: UInt64;
  ValueTimeRaw: Double;
  EtalonSnapshot: string;
  DeviceSnapshot: string;
  UiSnapshot: string;

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


  function GetMinPositiveDeviceImpTotal: Double;
  var
    J: Integer;
    V: Double;
    HasValue: Boolean;
  begin
    Result := 0;
    HasValue := False;

    if (WorkTable = nil) or (WorkTable.DeviceChannels = nil) then
      Exit;

    for J := 0 to WorkTable.DeviceChannels.Count - 1 do
      if (WorkTable.DeviceChannels[J] <> nil) and
         WorkTable.DeviceChannels[J].Enabled and
         (WorkTable.DeviceChannels[J].ValueImpTotal <> nil) then
      begin
        V := WorkTable.DeviceChannels[J].ValueImpTotal.GetDoubleValue;

        if V <= 0 then
          Continue;

        if (not HasValue) or (V < Result) then
        begin
          Result := V;
          HasValue := True;
        end;
      end;
  end;

  function IsLimitReached(ACriterion: TSpillageStopCriterion): Boolean;
  var
    CurrentValue: Double;
    LimitValue: Double;
  begin
    Result := False;

    if (WorkTable = nil) or (WorkTable.CurrentPoint = nil) then
      Exit;

    if not (ACriterion in WorkTable.CurrentPoint.StopCriteria) then
      Exit;

    CurrentValue := 0;
    LimitValue := 0;

    case ACriterion of
      scTime:
        begin
          LimitValue := WorkTable.CurrentPoint.LimitTime;

          if WorkTable.ValueTime = nil then
            Exit;

          CurrentValue := WorkTable.ValueTime.GetDoubleValue;
          Result := (LimitValue > 0) and (CurrentValue >= LimitValue);
        end;

      scVolume:
        begin
          LimitValue := WorkTable.CurrentPoint.LimitVolume;

          if WorkTable.ValueQuantity = nil then
            Exit;

          CurrentValue := WorkTable.ValueQuantity.GetDoubleValue;
          Result := (LimitValue > 0) and (CurrentValue >= LimitValue);
        end;

      scImpulse:
        begin
          LimitValue := WorkTable.CurrentPoint.LimitImp;
          CurrentValue := GetMinPositiveDeviceImpTotal;

          Result := (LimitValue > 0) and (CurrentValue >= LimitValue);
        end;
    end;
  end;

  function GetLimitIndicatorColor(ACriterion: TSpillageStopCriterion): TAlphaColor;
  begin
    Result := COLOR_NONE;

    if (WorkTable = nil) or (WorkTable.CurrentPoint = nil) then
      Exit;

    // В режиме монитора критерии остановки не относятся к активному измерению,
    // поэтому цветовые индикаторы критериев скрываем.
    if WorkTable.State in [swtSTARTMONITOR, swtSTARTMONITORWAIT, swtMONITOR] then
      Exit;

    if not (ACriterion in WorkTable.CurrentPoint.StopCriteria) then
      Exit;

    if IsLimitReached(ACriterion) then
      Result := COLOR_COMPLETED
    else
      Result := COLOR_WARNING;
  end;
begin
  if (csDestroying in ComponentState) or
     not IsManagedWorkTable(FActiveWorkTable) then
    Exit;

  WorkTable := FActiveWorkTable;
  if WorkTable = nil then
    Exit;

  UpdateConditionsCurrentValues(WorkTable);
  UpdateDeviceCoefficientHeaders;

  if WorkTable.ValueTime <> nil then
  begin
    LabelTime.Text := WorkTable.ValueTime.GetStrValue;
  end
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
      if WorkTable.CurrentPoint.LimitImp <= 0 then
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


 { MinImpTotalValue := nil;
  for I := 0 to WorkTable.DeviceChannels.Count - 1 do
    if (WorkTable.DeviceChannels[I] <> nil) and
       WorkTable.DeviceChannels[I].Enabled and
       (WorkTable.DeviceChannels[I].ValueImpTotal <> nil) and
       (WorkTable.DeviceChannels[I].ValueImpTotal.GetDoubleValue > 0) then
    begin
      if (MinImpTotalValue = nil) or
         (WorkTable.DeviceChannels[I].ValueImpTotal.GetDoubleValue < MinImpTotalValue.GetDoubleValue) then
        MinImpTotalValue := WorkTable.DeviceChannels[I].ValueImpTotal;
    end;

  if MinImpTotalValue <> nil then
    LabelImp.Text := MinImpTotalValue.GetStrValue
  else
    LabelImp.Text := '0';  }

    if WorkTable.TableFlow.ValueImpTotal <> nil then
    LabelImp.Text := WorkTable.TableFlow.ValueImpTotal.GetStrValue
  else
    LabelImp.Text := '0';

  Rectangle3.Fill.Color := GetLimitIndicatorColor(scTime);
  Rectangle9.Fill.Color := GetLimitIndicatorColor(scVolume);
  Rectangle10.Fill.Color := GetLimitIndicatorColor(scImpulse);

  if WorkTable.ValueFlowRate <> nil then
  begin
    if Assigned(StringColumnDeviceFlowRate1) then
      StringColumnDeviceFlowRate1.Header := 'Расход, ' + WorkTable.ValueFlowRate.GetDimName;
    if Assigned(StringColumnDeviceAvgFlowRate1) then
      StringColumnDeviceAvgFlowRate1.Header := 'Ср. расход, ' + WorkTable.ValueFlowRate.GetDimName;
    if Assigned(StringColumnEtalonFlowRate1) then
      StringColumnEtalonFlowRate1.Header := 'Расход, ' + WorkTable.ValueFlowRate.GetDimName;
    if Assigned(StringColumnEtalonAvgFlowRate1) then
      StringColumnEtalonAvgFlowRate1.Header := 'Ср. расход, ' + WorkTable.ValueFlowRate.GetDimName;
  end;

  if WorkTable.ValueQuantity <> nil then
  begin
    if Assigned(StringColumnDeviceQuantity1) then
      StringColumnDeviceQuantity1.Header := WorkTable.ValueQuantity.GetStrFullName;
    if Assigned(StringColumnEtalonQuantity1) then
      StringColumnEtalonQuantity1.Header := WorkTable.ValueQuantity.GetStrFullName;
  end;

  RawValueBaseMultiplier := FindFirstValueBaseMultiplier(WorkTable.DeviceChannels);

   if RawValueBaseMultiplier <> nil then
  begin
    if RawValueBaseMultiplier.&Type = 'Импульсы'  then
     begin
      if Assigned(StringColumnDeviceRawValue1) then
        StringColumnDeviceRawValue1.Header := 'Частота, Гц';
     end
     else
     begin
    if Assigned(StringColumnDeviceRawValue1) then
      StringColumnDeviceRawValue1.Header := RawValueBaseMultiplier.GetStrFullName;
     end
  end;

    RawValueBaseMultiplier := FindFirstValueBaseMultiplier(WorkTable.EtalonChannels);


  if RawValueBaseMultiplier <> nil then
  begin
    if RawValueBaseMultiplier.&Type = 'Импульсы'  then
     begin
      if Assigned(StringColumnEtalonRawValue1) then
        StringColumnEtalonRawValue1.Header := 'Частота, Гц';
     end
     else
     begin
    if Assigned(StringColumnEtalonRawValue1) then
      StringColumnEtalonRawValue1.Header := RawValueBaseMultiplier.GetStrFullName;
     end
  end;

  RawValueBaseMultiplier := FindFirstQuantityValueBaseMultiplier(WorkTable.DeviceChannels);

  if RawValueBaseMultiplier <> nil then
  begin
    if Assigned(StringColumnDeviceRawSumValue1) then
      StringColumnDeviceRawSumValue1.Header := RawValueBaseMultiplier.GetStrFullName;
    if Assigned(StringColumnEtalonRawSumValue1) then
      StringColumnEtalonRawSumValue1.Header := RawValueBaseMultiplier.GetStrFullName;
  end;

    RawValueBaseMultiplier := FindFirstQuantityValueBaseMultiplier(WorkTable.EtalonChannels);

   if RawValueBaseMultiplier <> nil then
  begin
     if Assigned(StringColumnEtalonRawSumValue1) then
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



  SyncDevicesColumnsMenu;
  SyncEtalonsColumnsMenu;

  if WorkTable.State in [swtSTARTMONITORWAIT, swtMONITOR, swtSTOPMONITOR] then
    RefreshMonitorIndicator;


  UiLogTick := TThread.GetTickCount64;
  if (FLastUiDataLogTick = 0) or
     (UiLogTick < FLastUiDataLogTick) or
     (UiLogTick - FLastUiDataLogTick >= 1000) or
     (FLastUiTimeText <> LabelTime.Text) then
  begin
    ValueTimeRaw := 0;
    if WorkTable.ValueTime <> nil then
      ValueTimeRaw := WorkTable.ValueTime.GetDoubleValue;

    EtalonSnapshot := '';
    for I := 0 to WorkTable.EtalonChannels.Count - 1 do
    begin
      Channel := WorkTable.EtalonChannels[I];
      if Channel = nil then
        Continue;
      if EtalonSnapshot <> '' then
        EtalonSnapshot := EtalonSnapshot + ',';
      EtalonSnapshot := EtalonSnapshot + Format(
        '#%d(%s;Enabled=%s;CurSec=%.6f;ImpSec=%.6f;ImpResult=%.6f;ValueSec=%.6f)',
        [I, Channel.Text, BoolToStr(Channel.Enabled, True), Channel.CurSec,
         Channel.ImpSec, Channel.ImpResult, Channel.ValueSec]);
    end;
    if EtalonSnapshot = '' then
      EtalonSnapshot := '<none>';

    DeviceSnapshot := '';
    for I := 0 to WorkTable.DeviceChannels.Count - 1 do
    begin
      Channel := WorkTable.DeviceChannels[I];
      if Channel = nil then
        Continue;
      if DeviceSnapshot <> '' then
        DeviceSnapshot := DeviceSnapshot + ',';
      DeviceSnapshot := DeviceSnapshot + Format(
        '#%d(%s;Enabled=%s;CurSec=%.6f;ImpSec=%.6f;ImpResult=%.6f;ValueSec=%.6f)',
        [I, Channel.Text, BoolToStr(Channel.Enabled, True), Channel.CurSec,
         Channel.ImpSec, Channel.ImpResult, Channel.ValueSec]);
    end;
    if DeviceSnapshot = '' then
      DeviceSnapshot := '<none>';

    UiSnapshot := Format(
      'WorkTable="%s"; State=%d; WorkTable.Time=%.6f; TimeResult=%.6f; ' +
      'ValueTime=%.6f; DisplayTime="%s"; DisplayFlow="%s"; ' +
      'DisplayQuantity="%s"; DisplayTemperature="%s"; DisplayPressure="%s"; ' +
      'EtalonChannels=[%s]; DeviceChannels=[%s]',
      [WorkTable.Text, Ord(WorkTable.State), WorkTable.Time,
       WorkTable.TimeResult, ValueTimeRaw, LabelTime.Text, LabelFlowRate.Text,
       LabelQuantity.Text, LabelTemp.Text, LabelPressure.Text,
       EtalonSnapshot, DeviceSnapshot]);

    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiData',
      'Данные, отображённые в интерфейсе', UiSnapshot);
    FLastUiDataLogTick := UiLogTick;
    FLastUiTimeText := LabelTime.Text;
  end;

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
    UpdatePreparedManualPoint;

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
    UpdatePreparedManualPoint;
    Exit;
  end;

  if TryStrToFloat(EditTime.Text, Value) then
  begin
    FActiveWorkTable.CurrentPoint.LimitTime := Value;
    Include(SC, scTime);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
  end;
  UpdatePreparedManualPoint;
end;

procedure TFrameMainTable.EditVolumeExit(Sender: TObject);
var
  Value: Double;
  SC: TSpillageStopCriteria;
begin
  if (FActiveWorkTable = nil) or (FActiveWorkTable.CurrentPoint = nil) then
    Exit;

  SC := FActiveWorkTable.CurrentPoint.StopCriteria;

  Value:= NormalizeFloatInput(EditVolume.Text);

  if (Trim(EditVolume.Text) = '-') or
     (Value<=0) then
  begin
    FActiveWorkTable.CurrentPoint.LimitVolume := -1;
    Exclude(SC, scVolume);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
    UpdatePreparedManualPoint;
    Exit;
  end;


    FActiveWorkTable.CurrentPoint.LimitVolume := Value;
    Include(SC, scVolume);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;

  UpdatePreparedManualPoint;
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
     (TryStrToInt(EditImp.Text, Value) and (Value <= 0)) then
  begin
    FActiveWorkTable.CurrentPoint.LimitImp := -1;
    Exclude(SC, scImpulse);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
    EditImp.Text := '-';
    UpdatePreparedManualPoint;
    Exit;
  end;

  if TryStrToInt(EditImp.Text, Value) then
  begin
    FActiveWorkTable.CurrentPoint.LimitImp := Value;
    Include(SC, scImpulse);
    FActiveWorkTable.CurrentPoint.StopCriteria := SC;
  end;
  UpdatePreparedManualPoint;
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
    UpdatePreparedManualPoint;
    //EditPres.Text := FormatFloat('0.###', FActiveWorkTable.Press);
  end
  //else
    //EditPres.Text := FormatFloat('0.###', FActiveWorkTable.Press);
end;

procedure TFrameMainTable.EditRepeatsExit(Sender: TObject);
begin
  if FActiveWorkTable = nil then
    Exit;

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
begin
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or (ANewType = nil) then
    Exit;

  if (DataManager <> nil) and (DataManager.ActiveTypeRepo <> nil) then
    AFoundRepo := DataManager.ActiveTypeRepo;

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
  FoundRepo, PreferredRepo: TTypeRepository;
  IsTypeChanged: Boolean;
  IsCurrentTypeDeletedInSelector: Boolean;
  Ch: TChannel;
  Repo: TTypeRepository;
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
    begin
      IsCurrentTypeDeletedInSelector := False;
      if (CurrentType <> nil) and (CurrentType.UUID <> '') then
        IsCurrentTypeDeletedInSelector :=
          DataManager.FindType(CurrentType.UUID, '', FoundRepo) = nil;

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

    FoundRepo := DataManager.ActiveTypeRepo;

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


procedure TFrameMainTable.UpdateTestButton;
begin
  UpdateMeasurementStartStopButton('UpdateTestButton');
end;

procedure TFrameMainTable.MeasurementRunUiChanged(Sender: TObject);
begin
  UpdateMeasurementStartStopButton('MeasurementRunEvent');
end;

procedure TFrameMainTable.UpdateMeasurementStartStopButton(const AReason: string);
var
  Run: TMeasurementRun;
  Active: Boolean;
  NewAction, PreviousAction: string;
  StageValue, PointIndex, WorkTableStateValue: Integer;
  Paused, SaveMode: Boolean;
begin
  if TestButton = nil then Exit;
  SaveMode := IsTestButtonSaveMode;
  Run := MeasurementRun;
  Active := IsMeasurementActive(FActiveWorkTable);
  if Active then NewAction := 'Stop' else NewAction := 'Start';
  PreviousAction := FLastMeasurementMainButtonAction;

  if Active then
  begin
    TestButton.Text := 'Стоп';
    TestButton.StyleLookup := 'circlebuttonstyle';
    TestButton.Hint := 'Остановить измерение';
    TestButton.Tag := 3;
    TestButton.Enabled := FActiveWorkTable <> nil;
  end
  else
  begin
    TestButton.Text := 'Измерение';
    TestButton.StyleLookup := 'circlebuttonstyle';
    TestButton.Hint := 'Начать измерение';
    TestButton.Tag := 1;
    TestButton.Enabled := (FActiveWorkTable <> nil) and
      not (FActiveWorkTable.State in [swtNONE, swtSTANDBY]);
  end;

  { Состояние подтверждения сохранения сохраняет специальное назначение. }
  if SaveMode then
  begin
    TestButton.Text := 'Сохранить?';
    TestButton.Hint := 'Подтвердить сохранение результатов';
    TestButton.Tag := 6;
    TestButton.Enabled := True;
  end;

  if NewAction <> PreviousAction then
  begin
    StageValue := -1; PointIndex := -1; Paused := False;
    if FActiveWorkTable <> nil then WorkTableStateValue := Ord(FActiveWorkTable.State)
    else WorkTableStateValue := -1;
    if Run <> nil then
    begin
      StageValue := Ord(Run.Stage);
      PointIndex := Run.CurrentPointIndex;
      Paused := Run.IsPaused;
    end;
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementMainButtonUpdated',
      'Обновлено фактическое действие центральной кнопки',
      Format('Action=%s; WorkTableState=%d; RunAssigned=%s; RunStage=%d; IsPaused=%s; CurrentPointIndex=%d; Reason=%s',
        [NewAction, WorkTableStateValue,
         BoolToStr(Run <> nil, True), StageValue, BoolToStr(Paused, True),
         PointIndex, AReason]));
    if (PreviousAction = 'Stop') and (NewAction = 'Start') then
      ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunUiStateChanged',
        'Интерфейс отобразил фактическое завершение измерения',
        Format('PreviousAction=Stop; NewAction=Start; WorkTableState=%d; RunStage=%d',
          [WorkTableStateValue, StageValue]));
    FLastMeasurementMainButtonAction := NewAction;
  end;
end;

const
  AUTO_MEASUREMENT_SCENARIO_COUNT = 20;
  AUTO_MEASUREMENT_MAX_STEPS = 600;
  AUTO_MEASUREMENT_MAX_LOG_LINES = 5000;

function AutoMeasurementScenarioName(const AIndex: Integer): string;
begin
  case AIndex of
    0: Result := '1. Успешный полный проход';
    1: Result := '2. Постепенный выход на стабильный расход';
    2: Result := '3. Стабильный шум в пределах допуска';
    3: Result := '4. Колебания вне допуска';
    4: Result := '5. Постоянный положительный тренд';
    5: Result := '6. Постоянный отрицательный тренд';
    6: Result := '7. Единичный выброс';
    7: Result := '8. Многочисленные выбросы';
    8: Result := '9. Недостаточно данных';
    9: Result := '10. Устаревшие данные';
    10: Result := '11. Расход стабилен, температура нестабильна';
    11: Result := '12. Расход и температура стабильны, давление вне диапазона';
    12: Result := '13. Тайм-аут стабилизации с успешной повторной попыткой';
    13: Result := '14. Окончательный тайм-аут стабилизации';
    14: Result := '15. Ошибка запуска мониторинга';
    15: Result := '16. Ошибка запуска измерения';
    16: Result := '17. Остановка пользователем во время измерения';
    17: Result := '18. Ошибка остановки оборудования';
    18: Result := '19. Ошибка чтения результатов';
    19: Result := '20. Несколько точек и повторов';
  else
    Result := Format('%d. Сценарий', [AIndex + 1]);
  end;
end;

{ Creates one runtime grid column with a stable persistent identity. }
procedure AddStringColumn(AGrid: TGrid; const AName, AHeader: string;
  const AWidth: Single);
var
  Col: TStringColumn;
begin
  Col := TStringColumn.Create(AGrid);
  Col.Name := AName;
  Col.Header := AHeader;
  Col.Width := AWidth;
  Col.Parent := AGrid;
end;

procedure TFrameMainTable.InitializeAutoMeasurementTestTab;
var
  Layout: TVertScrollBox;
  Buttons: TLayout;
begin
  if FAutoTestTab <> nil then
    Exit;

  FAutoTestTab := TTabItem.Create(Self);
  FAutoTestTab.Text := 'Тест автоизмерения';
  FAutoTestTab.Parent := TabControlDevices;

  Layout := TVertScrollBox.Create(Self);
  Layout.Parent := FAutoTestTab;
  Layout.Align := TAlignLayout.Client;
  Layout.Padding.Rect := TRectF.Create(8, 8, 8, 8);

  FAutoTestInfoLabel := TLabel.Create(Self);
  FAutoTestInfoLabel.Parent := Layout;
  FAutoTestInfoLabel.Align := TAlignLayout.Top;
  FAutoTestInfoLabel.Height := 72;
  FAutoTestInfoLabel.Text := 'Текущий стол не выбран';

  ComboBoxAutoTestScenario := TComboBox.Create(Self);
  ComboBoxAutoTestScenario.Parent := Layout;
  ComboBoxAutoTestScenario.Align := TAlignLayout.Top;
  ComboBoxAutoTestScenario.Height := 32;

  Buttons := TLayout.Create(Self);
  Buttons.Parent := Layout;
  Buttons.Align := TAlignLayout.Top;
  Buttons.Height := 40;

  ButtonRunAutoTestScenario := TButton.Create(Self);
  ButtonRunAutoTestScenario.Parent := Buttons;
  ButtonRunAutoTestScenario.Position.X := 0;
  ButtonRunAutoTestScenario.Width := 160;
  ButtonRunAutoTestScenario.Text := 'Запустить сценарий';
  ButtonRunAutoTestScenario.OnClick := AutoTestButtonRunClick;

  ButtonRunAllAutoTestScenarios := TButton.Create(Self);
  ButtonRunAllAutoTestScenarios.Parent := Buttons;
  ButtonRunAllAutoTestScenarios.Position.X := 168;
  ButtonRunAllAutoTestScenarios.Width := 160;
  ButtonRunAllAutoTestScenarios.Text := 'Прогнать все';
  ButtonRunAllAutoTestScenarios.OnClick := AutoTestButtonRunAllClick;

  ButtonStopAutoTestScenario := TButton.Create(Self);
  ButtonStopAutoTestScenario.Parent := Buttons;
  ButtonStopAutoTestScenario.Position.X := 336;
  ButtonStopAutoTestScenario.Width := 120;
  ButtonStopAutoTestScenario.Text := 'Остановить';
  ButtonStopAutoTestScenario.OnClick := AutoTestButtonStopClick;

  ButtonAutoTestStep := TButton.Create(Self);
  ButtonAutoTestStep.Parent := Buttons;
  ButtonAutoTestStep.Position.X := 464;
  ButtonAutoTestStep.Width := 120;
  ButtonAutoTestStep.Text := 'Шаг времени';
  ButtonAutoTestStep.OnClick := AutoTestButtonStepClick;

  ButtonAutoTestContinueToStage := TButton.Create(Self);
  ButtonAutoTestContinueToStage.Parent := Buttons;
  ButtonAutoTestContinueToStage.Position.X := 592;
  ButtonAutoTestContinueToStage.Width := 180;
  ButtonAutoTestContinueToStage.Text := 'До смены Stage';
  ButtonAutoTestContinueToStage.OnClick := AutoTestButtonContinueClick;

  FAutoTestStatusLabel := TLabel.Create(Self);
  FAutoTestStatusLabel.Parent := Layout;
  FAutoTestStatusLabel.Align := TAlignLayout.Top;
  FAutoTestStatusLabel.Height := 48;
  FAutoTestStatusLabel.Text := 'Тест не запускался';

  GridAutoTestNumbers := TGrid.Create(Self);
  GridAutoTestNumbers.Name := 'GridAutoTestNumbers';
  GridAutoTestNumbers.Parent := Layout;
  GridAutoTestNumbers.Align := TAlignLayout.Top;
  GridAutoTestNumbers.Height := 220;
  GridAutoTestNumbers.OnGetValue := GridAutoTestNumbersGetValue;
  AddStringColumn(GridAutoTestNumbers, 'StringColumnTime', 'Время', 70);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnPoint', 'Точка', 120);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnRepeat', 'Repeat', 70);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnTargetFlow', 'Q заданный', 90);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnActualFlow', 'Q фактический', 100);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnFlowParameter', 'Q parameter', 100);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnFlowSample', 'Q sample', 100);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnSampleTime', 'Sample time', 100);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnTimeSource', 'Time source', 90);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnTargetTemperature', 'T заданная', 90);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnActualTemperature', 'T фактическая', 100);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnTargetPressure', 'P заданное', 90);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnActualPressure', 'P фактическое', 100);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnStable', 'Stable', 90);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnVirtualCommand', 'Virtual command', 130);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnVirtualResponse', 'Virtual response', 130);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnProgress', 'Progress', 90);
  AddStringColumn(GridAutoTestNumbers, 'StringColumnReason', 'Причина', 300);
  GridAutoTestResults := TGrid.Create(Self);
  GridAutoTestResults.Name := 'GridAutoTestResults';
  GridAutoTestResults.Parent := Layout;
  GridAutoTestResults.Align := TAlignLayout.Top;
  GridAutoTestResults.Height := 260;
  GridAutoTestResults.OnGetValue := GridAutoTestResultsGetValue;
  AddStringColumn(GridAutoTestResults, 'StringColumnNumber', '№', 40);
  AddStringColumn(GridAutoTestResults, 'StringColumnScenario', 'Сценарий', 260);
  AddStringColumn(GridAutoTestResults, 'StringColumnResult', 'Результат', 90);
  AddStringColumn(GridAutoTestResults, 'StringColumnTime', 'Время', 80);
  AddStringColumn(GridAutoTestResults, 'StringColumnVirtualTime', 'Вирт. время', 90);
  AddStringColumn(GridAutoTestResults, 'StringColumnPoints', 'Точек', 60);
  AddStringColumn(GridAutoTestResults, 'StringColumnRepeats', 'Повторов', 70);
  AddStringColumn(GridAutoTestResults, 'StringColumnStage', 'Stage', 130);
  AddStringColumn(GridAutoTestResults, 'StringColumnWorkTableState', 'WorkTable.State', 130);
  AddStringColumn(GridAutoTestResults, 'StringColumnReason', 'Причина', 240);
  AddStringColumn(GridAutoTestResults, 'StringColumnLogFile', 'Файл лога', 220);
  InitializeAutoTestScenarioList;
  ButtonStopAutoTestScenario.Enabled := False;
  FAutoTestRealCommandsBlocked := False;
end;

procedure TFrameMainTable.InitializeAutoTestScenarioList;
var
  I: Integer;
begin
  ComboBoxAutoTestScenario.Items.Clear;
  for I := 0 to AUTO_MEASUREMENT_SCENARIO_COUNT - 1 do
    ComboBoxAutoTestScenario.Items.Add(AutoMeasurementScenarioName(I));
  ComboBoxAutoTestScenario.ItemIndex := 0;
end;

procedure TFrameMainTable.RefreshAutoMeasurementTestContext;
var
  DeviceEnabled, EtalonEnabled, PointCount, I: Integer;
  RunText: string;
begin
  if FAutoTestInfoLabel = nil then
    Exit;

  DeviceEnabled := 0;
  EtalonEnabled := 0;
  PointCount := 0;
  if FActiveWorkTable <> nil then
  begin
    if FActiveWorkTable.DeviceChannels <> nil then
      for I := 0 to FActiveWorkTable.DeviceChannels.Count - 1 do
        if (FActiveWorkTable.DeviceChannels[I] <> nil) and FActiveWorkTable.DeviceChannels[I].Enabled then
          Inc(DeviceEnabled);
    if FActiveWorkTable.EtalonChannels <> nil then
      for I := 0 to FActiveWorkTable.EtalonChannels.Count - 1 do
        if (FActiveWorkTable.EtalonChannels[I] <> nil) and FActiveWorkTable.EtalonChannels[I].Enabled then
          Inc(EtalonEnabled);
    if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then
      PointCount := MeasurementRun.Points.Count;
    if MeasurementRun <> nil then
      RunText := TMeasurementRun.MeasurementStateToString(MeasurementRun.Stage)
    else
      RunText := '-';
    FAutoTestInfoLabel.Text := Format('Стол: %s (%s)'#13#10'Режим: %d; Состояние: %s; Stage: %s'#13#10'Включено приборных каналов: %d; Точек сессии: %d; Включено эталонов: %d; Реальные команды заблокированы: %s',
      [FActiveWorkTable.Name, FActiveWorkTable.UUID, Ord(MeasurementRun.Mode),
       TWorkTable.WorkTableStateToString(FActiveWorkTable.State), RunText,
       DeviceEnabled, PointCount, EtalonEnabled, BoolToStr(FAutoTestRealCommandsBlocked, True)]);
  end
  else
    FAutoTestInfoLabel.Text := 'Текущий стол не выбран';
end;

procedure TFrameMainTable.GridAutoTestNumbersGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var R: TAutoMeasurementTestStepRow;
begin
  if (ARow < 0) or (ARow >= Length(FAutoTestStepRows)) then Exit;
  R := FAutoTestStepRows[ARow];
  case ACol of
    0: Value := R.VirtualTimeSec;
    1: Value := R.PointText;
    2: Value := R.RepeatText;
    3: Value := FormatFloat('0.000', R.TargetFlow);
    4: Value := FormatFloat('0.000', R.ActualFlow);
    5: Value := FormatFloat('0.000', R.QParameter);
    6: Value := FormatFloat('0.000', R.QSample);
    7: Value := R.SampleTimeMs;
    8: Value := R.TimeSource;
    9: Value := FormatFloat('0.000', R.TargetTemp);
    10: Value := FormatFloat('0.000', R.ActualTemp);
    11: Value := FormatFloat('0.000', R.TargetPress);
    12: Value := FormatFloat('0.000', R.ActualPress);
    13: Value := R.StableText;
    14: Value := R.VirtualCommand;
    15: Value := R.VirtualResponse;
    16: Value := R.ProgressText;
  else Value := R.Reason;
  end;
end;

procedure TFrameMainTable.GridAutoTestResultsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var R: TAutoMeasurementTestResultRow;
begin
  if (ARow < 0) or (ARow >= Length(FAutoTestResultRows)) then Exit;
  R := FAutoTestResultRows[ARow];
  case ACol of
    0: Value := R.Num;
    1: Value := R.Scenario;
    2: Value := R.ResultText;
    3: Value := R.ElapsedMs;
    4: Value := R.VirtualTimeSec;
    5: Value := R.PointCount;
    6: Value := R.RepeatCount;
    7: Value := R.FinalStage;
    8: Value := R.FinalWorkTableState;
    9: Value := R.Reason;
  else Value := R.LogFile;
  end;
end;

procedure TFrameMainTable.AutoTestButtonRunClick(Sender: TObject);
begin
  if ComboBoxAutoTestScenario = nil then Exit;
  RunAutoMeasurementScenario(Max(0, ComboBoxAutoTestScenario.ItemIndex));
end;

procedure TFrameMainTable.AutoTestButtonRunAllClick(Sender: TObject);
begin
  RunAllAutoMeasurementScenarios;
end;

procedure TFrameMainTable.AutoTestButtonStopClick(Sender: TObject);
begin
  FAutoTestStopRequested := True;
  if MeasurementRun <> nil then
    MeasurementRun.Execute(mcStop, Null);
end;

procedure TFrameMainTable.AutoTestButtonStepClick(Sender: TObject);
begin
  RunAutoMeasurementScenario(Max(0, ComboBoxAutoTestScenario.ItemIndex));
end;

procedure TFrameMainTable.AutoTestButtonContinueClick(Sender: TObject);
begin
  RunAutoMeasurementScenario(Max(0, ComboBoxAutoTestScenario.ItemIndex));
end;

procedure TFrameMainTable.RunAllAutoMeasurementScenarios;
var I: Integer;
begin
  for I := 0 to AUTO_MEASUREMENT_SCENARIO_COUNT - 1 do
  begin
    RunAutoMeasurementScenario(I);
    if FAutoTestStopRequested then
      Break;
  end;
end;

procedure TFrameMainTable.RunAutoMeasurementScenario(const AScenarioIndex: Integer);
var
  WT: TWorkTable;
  Run: TMeasurementRun;
  OldState: EStateWorkTable;
  OldSimulation: Boolean;
  OldPoint: TDevicePoint;
  StartTick: Cardinal;
  Step, DeviceEnabled, EtalonEnabled, RepeatCount, I: Integer;
  Point: TDevicePoint;
  StageBefore, StageAfter: EMeasurementState;
  Row: TAutoMeasurementTestStepRow;
  ResultRow: TAutoMeasurementTestResultRow;
  Lines: TStringList;
  LogFile: string;
  ScenarioName: string;
  Factor, TargetQ, TargetT, TargetP, ActualQ, ActualT, ActualP: Double;
  StableInfo: RStableInfo;
  StableText: string;
  LastProgressKey: string;
  ProgressKey: string;
  NoProgressSteps: Integer;
  AppliedQ: Double;
  LastSampleQ: Double;
  LastSampleTimeMs: Int64;
  VirtualTimeStartMs: Int64;
  MaxExistingSampleTimeMs: Int64;
  PointWaitSteps: Integer;
  ValuesInjected: Boolean;
  PointReady: Boolean;
  OldFlowValue: Double;
  OldTempValue: Double;
  OldPressValue: Double;
  OldFlowSamples: TArray<TMeterValueSample>;
  OldTempSamples: TArray<TMeterValueSample>;
  OldPressSamples: TArray<TMeterValueSample>;
  PointNameForLog: string;
  FinalKind: TAutoMeasurementTestResultKind;
  FinalReason: string;

  procedure AppendStep;
  begin
    SetLength(FAutoTestStepRows, Length(FAutoTestStepRows) + 1);
    FAutoTestStepRows[High(FAutoTestStepRows)] := Row;
    if Lines.Count < AUTO_MEASUREMENT_MAX_LOG_LINES then
      Lines.Add(Format('t=%d; Point=%s; Repeat=%s; StageBefore=%s; StageAfter=%s; WT=%s; Qset=%.6f; Qactual=%.6f; Tset=%.6f; Tactual=%.6f; Pset=%.6f; Pactual=%.6f; Stable=%s; Reason=%s; Executor=%s; Check=%s',
        [Row.VirtualTimeSec, Row.PointText, Row.RepeatText, Row.StageBefore, Row.StageAfter,
         Row.WorkTableState, Row.TargetFlow, Row.ActualFlow, Row.TargetTemp, Row.ActualTemp,
         Row.TargetPress, Row.ActualPress, Row.StableText, Row.Reason, Row.ExecutorCall, Row.CheckText]));
  end;

  procedure AddSampleToMeter(AMeter: TMeterValue; const AValue: Double; const ATimeMs: Int64);
  begin
    if AMeter <> nil then
      AMeter.AddStabilitySampleManual(ATimeMs, AValue);
  end;

  function ReadLastSample(AMeter: TMeterValue; out AValue: Double; out ATimeMs: Int64): Boolean;
  var
    LocalSamples: TArray<TMeterValueSample>;
  begin
    Result := False;
    AValue := 0;
    ATimeMs := 0;
    if AMeter = nil then
      Exit;
    LocalSamples := AMeter.GetStabilitySamples;
    if Length(LocalSamples) = 0 then
      Exit;
    AValue := LocalSamples[High(LocalSamples)].Value;
    ATimeMs := LocalSamples[High(LocalSamples)].TimeStampMs;
    Result := True;
  end;

  function LastSampleTimeOf(AMeter: TMeterValue): Int64;
  var
    Value: Double;
  begin
    Result := 0;
    ReadLastSample(AMeter, Value, Result);
  end;

  procedure SnapshotMeter(AMeter: TMeterValue; out ASamples: TArray<TMeterValueSample>; out AValue: Double);
  begin
    AValue := 0;
    SetLength(ASamples, 0);
    if AMeter = nil then
      Exit;
    AValue := AMeter.Value;
    ASamples := AMeter.GetStabilitySamples;
  end;

  procedure RestoreMeter(AMeter: TMeterValue; const ASamples: TArray<TMeterValueSample>; const AValue: Double);
  var
    Sample: TMeterValueSample;
  begin
    if AMeter = nil then
      Exit;
    AMeter.ClearStabilitySamples;
    AMeter.Value := AValue;
    for Sample in ASamples do
      AMeter.AddStabilitySampleManual(Sample.TimeStampMs, Sample.Value);
  end;

begin
  if FAutoTestRunning then
    Exit;

  WT := FActiveWorkTable;
  Run := MeasurementRun;
  ScenarioName := AutoMeasurementScenarioName(AScenarioIndex);
  SetLength(FAutoTestStepRows, 0);
  Lines := TStringList.Create;
  try
    StartTick := TThread.GetTickCount;
    FinalKind := amtrkFail;
    FinalReason := '';
    RepeatCount := 0;
    LastProgressKey := '';
    NoProgressSteps := 0;
    PointWaitSteps := 0;
    ValuesInjected := False;
    VirtualTimeStartMs := 0;
    MaxExistingSampleTimeMs := 0;
    if WT = nil then
      FinalReason := 'FAIL — активный TWorkTable отсутствует'
    else if Run = nil then
      FinalReason := 'FAIL — MeasurementRun не создан'
    else if Run.IsWorkerThreadRunning or FAutoTestRunning then
      FinalReason := 'FAIL — уже выполняется настоящее или тестовое измерение'
    else if not (WT.State in [swtCONNECTED, swtCOMPLETE, swtSTARTMONITOR, swtSTARTMONITORWAIT, swtMONITOR, swtNONE]) then
      FinalReason := 'FAIL — состояние стола не допускает сценарный запуск'
    else
    begin
      DeviceEnabled := 0;
      EtalonEnabled := 0;
      for I := 0 to WT.DeviceChannels.Count - 1 do
        if (WT.DeviceChannels[I] <> nil) and WT.DeviceChannels[I].Enabled then Inc(DeviceEnabled);
      for I := 0 to WT.EtalonChannels.Count - 1 do
        if (WT.EtalonChannels[I] <> nil) and WT.EtalonChannels[I].Enabled then Inc(EtalonEnabled);
      if DeviceEnabled = 0 then
        FinalReason := 'FAIL — нет включённых проверяемых каналов'
      else if EtalonEnabled = 0 then
        FinalReason := 'FAIL — нет включённых эталонных каналов';
    end;

    Lines.Add('AUTO MEASUREMENT TEST');
    Lines.Add('Scenario=' + ScenarioName);
    if WT <> nil then
      Lines.Add(Format('WorkTable=%s; UUID=%s', [WT.Name, WT.UUID]));

    if FinalReason = '' then
    begin
      FAutoTestRunning := True;
      FAutoTestStopRequested := False;
      OldState := WT.State;
      OldSimulation := WT.IsSimulationMode;
      OldPoint := TDevicePoint.Create(0);
      OldPoint.Assign(WT.CurrentPoint, True);
      try
        if WT.FlowRate <> nil then SnapshotMeter(WT.FlowRate.Value, OldFlowSamples, OldFlowValue);
        if WT.FluidTemp <> nil then SnapshotMeter(WT.FluidTemp.Value, OldTempSamples, OldTempValue);
        if WT.FluidPress <> nil then SnapshotMeter(WT.FluidPress.Value, OldPressSamples, OldPressValue);
        MaxExistingSampleTimeMs := 0;
        if WT.FlowRate <> nil then
          MaxExistingSampleTimeMs := Max(MaxExistingSampleTimeMs, LastSampleTimeOf(WT.FlowRate.Value));
        if WT.FluidTemp <> nil then
          MaxExistingSampleTimeMs := Max(MaxExistingSampleTimeMs, LastSampleTimeOf(WT.FluidTemp.Value));
        if WT.FluidPress <> nil then
          MaxExistingSampleTimeMs := Max(MaxExistingSampleTimeMs, LastSampleTimeOf(WT.FluidPress.Value));
        VirtualTimeStartMs := Max(TMeterValue.GetMonotonicTimeMs, MaxExistingSampleTimeMs) + 1;
        WT.IsSimulationMode := True;
        TMeterValue.EnableVirtualClock(VirtualTimeStartMs);
        FAutoTestRealCommandsBlocked := True;
        Lines.Add(Format('ScenarioStart; InitialStage=%s; InitialWorkTableState=%s; CurrentMonotonicTime=%d; MaxExistingSampleTime=%d; VirtualTimeStart=%d',
          [TMeasurementRun.MeasurementStateToString(Run.Stage), TWorkTable.WorkTableStateToString(WT.State),
           VirtualTimeStartMs - 1, MaxExistingSampleTimeMs, VirtualTimeStartMs]));
        Run.Mode := mrmAutomatic;
        Run.InvalidatePreparedPoints;
        Run.RebuildMeasurementPoints;
        if (Run.Points = nil) or (Run.Points.Count = 0) then
          FinalReason := 'FAIL — штатный RebuildMeasurementPoints не сформировал точки'
        else
        begin
          Run.Start;
          for Step := 0 to AUTO_MEASUREMENT_MAX_STEPS - 1 do
          begin
            if FAutoTestStopRequested then
            begin
              FinalKind := amtrkStopped;
              FinalReason := 'STOPPED — остановлено пользователем';
              Break;
            end;
            StageBefore := Run.Stage;
            { Возвращаем управление FMX message loop между шагами имитации. }
            Application.ProcessMessages;
            TThread.Sleep(1);
            Point := Run.CurrentPoint;
            PointReady := (Point <> nil) and (Run.CurrentPointIndex >= 0) and
              (Run.Points <> nil) and (Run.CurrentPointIndex < Run.Points.Count) and
              (Run.Points[Run.CurrentPointIndex] = Point) and
              (Run.Stage in [msSelectPoint, msHydraulicLineConfiguration, msSetupHydraulicLine, msSetupPoint, msWaitPointSetup, msWaitStable, msWaitMeasureStart, msMeasure, msWaitMeasureStop, msResultsRead, msSave]);
            if not PointReady then
            begin
              Inc(PointWaitSteps);
              Row.VirtualTimeSec := Integer(TMeterValue.GetMonotonicTimeMs - VirtualTimeStartMs);
              Row.PointText := '-';
              Row.RepeatText := '-';
              Row.StageBefore := TMeasurementRun.MeasurementStateToString(StageBefore);
              Row.StageAfter := TMeasurementRun.MeasurementStateToString(Run.Stage);
              Row.WorkTableState := TWorkTable.WorkTableStateToString(WT.State);
              Row.TargetFlow := 0; Row.ActualFlow := 0;
              Row.QParameter := 0; Row.QSample := 0; Row.SampleTimeMs := 0; Row.TimeSource := 'Virtual';
              Row.TargetTemp := 0; Row.ActualTemp := 0; Row.TargetPress := 0; Row.ActualPress := 0;
              Row.StableText := 'DeliveryCheck=Skipped';
              Row.VirtualCommand := 'WaitPointSelection';
              Row.VirtualResponse := TWorkTable.WorkTableStateToString(WT.State);
              Row.ProgressText := 'WaitingPoint';
              Row.Reason := 'Reason=PointNotSelected';
              Row.ExecutorCall := Row.VirtualCommand;
              Row.CheckText := 'DeliveryCheck=Skipped; Reason=PointNotSelected';
              AppendStep;
              if PointWaitSteps >= 40 then
              begin
                FinalReason := 'FAIL — штатная FSM не выбрала точку';
                Break;
              end;
              Continue;
            end;

            if PointWaitSteps > 0 then
              Lines.Add(Format('PointSelected; PointIndex=%d; PointName=%s; TargetQ=%.9f; Stage=%s; VirtualTime=%d',
                [Run.CurrentPointIndex, Point.Name, Point.Q, TMeasurementRun.MeasurementStateToString(Run.Stage),
                 TMeterValue.GetMonotonicTimeMs]));

            TMeterValue.AdvanceVirtualClock(1000);
            TargetQ := Point.Q;
            TargetT := Point.Temp;
            TargetP := Point.Pressure;
            Factor := Min(1.0, 0.72 + Step * 0.07);
            case AScenarioIndex of
              3: Factor := 1.25;
              4: Factor := 0.85 + Step * 0.01;
              5: Factor := 1.15 - Step * 0.01;
              8: if Step < 3 then Factor := 1.0;
              10: ActualT := TargetT + Step * 0.5;
              11: ActualP := TargetP + Max(Abs(TargetP) * 0.2, 0.1);
            end;
            ActualQ := TargetQ * Factor;
            if AScenarioIndex in [2, 6] then
              ActualQ := TargetQ * (1.0 + IfThen(Odd(Step), 0.001, -0.001));
            if (TargetQ > 0) and SameValue(ActualQ, 0, 1E-12) then
            begin
              FinalReason := Format('FAIL — для выбранной точки сформирован нулевой расход; PointIndex=%d; PointName=%s; TargetQ=%.9f; Stage=%s; GeneratedQ=%.9f; Source=SelectedMeasurementRunPoint',
                [Run.CurrentPointIndex, Point.Name, TargetQ, TMeasurementRun.MeasurementStateToString(Run.Stage), ActualQ]);
              Break;
            end;
            ValuesInjected := True;

            if not (AScenarioIndex = 10) then
              ActualT := TargetT + IfThen(Step < 4, -0.5 + Step * 0.15, 0.01);
            if not (AScenarioIndex = 11) then
              ActualP := TargetP + IfThen(Step < 4, -0.05 + Step * 0.015, 0.001);

            if WT.FlowRate <> nil then
            begin
              WT.FlowRate.SetValue(ActualQ);
              AddSampleToMeter(WT.FlowRate.Value, ActualQ, TMeterValue.GetMonotonicTimeMs);
            end;
            if WT.FluidTemp <> nil then
            begin
              WT.FluidTemp.SetValue(ActualT);
              AddSampleToMeter(WT.FluidTemp.Value, ActualT, TMeterValue.GetMonotonicTimeMs);
            end;
            if WT.FluidPress <> nil then
            begin
              WT.FluidPress.SetValue(ActualP);
              AddSampleToMeter(WT.FluidPress.Value, ActualP, TMeterValue.GetMonotonicTimeMs);
            end;
            if WT.ValueFlowRate <> nil then WT.ValueFlowRate.Reset(ActualQ);
            if WT.ValueTemperture <> nil then WT.ValueTemperture.Reset(ActualT);
            if WT.ValuePressure <> nil then WT.ValuePressure.Reset(ActualP);
            for I := 0 to WT.EtalonChannels.Count - 1 do
              if (WT.EtalonChannels[I] <> nil) and WT.EtalonChannels[I].Enabled and
                 (WT.EtalonChannels[I].FlowMeter <> nil) and (WT.EtalonChannels[I].FlowMeter.ValueFlow <> nil) then
                AddSampleToMeter(WT.EtalonChannels[I].FlowMeter.ValueFlow, ActualQ, TMeterValue.GetMonotonicTimeMs);
            for I := 0 to WT.DeviceChannels.Count - 1 do
              if (WT.DeviceChannels[I] <> nil) and WT.DeviceChannels[I].Enabled then
              begin
                WT.DeviceChannels[I].ImpResult := Step * 1000;
                if (WT.DeviceChannels[I].FlowMeter <> nil) and (WT.DeviceChannels[I].FlowMeter.ValueFlow <> nil) then
                  AddSampleToMeter(WT.DeviceChannels[I].FlowMeter.ValueFlow, ActualQ, TMeterValue.GetMonotonicTimeMs);
              end;

            AppliedQ := 0;
            LastSampleQ := 0;
            LastSampleTimeMs := 0;
            if (WT.FlowRate <> nil) and (WT.FlowRate.Value <> nil) then
              AppliedQ := WT.FlowRate.Value.Value;
            if WT.FlowRate <> nil then
              ReadLastSample(WT.FlowRate.Value, LastSampleQ, LastSampleTimeMs);
            if ValuesInjected and ((not SameValue(ActualQ, AppliedQ, 1E-9)) or
               (not SameValue(ActualQ, LastSampleQ, 1E-9)) or
               (LastSampleTimeMs <> TMeterValue.GetMonotonicTimeMs)) then
            begin
              if Point <> nil then
                PointNameForLog := Point.Name
              else
                PointNameForLog := '-';
              FinalReason := Format('FAIL — тестовое значение не передано в рабочий параметр; Parameter=FlowRate; GeneratedQ=%.9f; AppliedQ=%.9f; LastSampleQ=%.9f; SampleTime=%d; VirtualTime=%d; Point=%s; Stage=%s; WorkTable.State=%s',
                [ActualQ, AppliedQ, LastSampleQ, LastSampleTimeMs, TMeterValue.GetMonotonicTimeMs,
                 PointNameForLog, TMeasurementRun.MeasurementStateToString(Run.Stage),
                 TWorkTable.WorkTableStateToString(WT.State)]);
              Break;
            end;

            { Возвращаем управление FMX message loop между шагами имитации. }
            Application.ProcessMessages;
            TThread.Sleep(1);
            StageAfter := Run.Stage;
            StableText := 'n/a';
            if WT.FlowRate <> nil then
            begin
              if WT.FlowRate.IsStable(StableInfo) then
                StableText := 'True: ' + StableInfo.StatusText
              else
                StableText := 'False: ' + StableInfo.StatusText;
            end;

            ProgressKey := Format('%d|%d|%d|%d', [Ord(Run.Stage), Ord(WT.State), Run.CurrentPointIndex, Run.CurrentRepeat]);
            if ProgressKey = LastProgressKey then
              Inc(NoProgressSteps)
            else
            begin
              LastProgressKey := ProgressKey;
              NoProgressSteps := 0;
            end;

            Row.VirtualTimeSec := Integer((TMeterValue.GetMonotonicTimeMs - VirtualTimeStartMs) div 1000);
            if Point <> nil then Row.PointText := Format('%d/%d %s', [Run.CurrentPointIndex + 1, Run.Points.Count, Point.Name]) else Row.PointText := '-';
            Row.RepeatText := IntToStr(Run.CurrentRepeat + 1);
            Row.StageBefore := TMeasurementRun.MeasurementStateToString(StageBefore);
            Row.StageAfter := TMeasurementRun.MeasurementStateToString(StageAfter);
            Row.WorkTableState := TWorkTable.WorkTableStateToString(WT.State);
            Row.TargetFlow := TargetQ; Row.ActualFlow := ActualQ;
            Row.QParameter := AppliedQ; Row.QSample := LastSampleQ;
            Row.SampleTimeMs := LastSampleTimeMs; Row.TimeSource := 'Virtual';
            Row.TargetTemp := TargetT; Row.ActualTemp := ActualT;
            Row.TargetPress := TargetP; Row.ActualPress := ActualP;
            Row.StableText := StableText;
            Row.VirtualCommand := 'Virtual command boundary';
            Row.VirtualResponse := TWorkTable.WorkTableStateToString(WT.State);
            if NoProgressSteps = 0 then Row.ProgressText := 'True' else Row.ProgressText := 'False';
            Row.Reason := 'Шаг виртуального времени; значения прочитаны обратно из производственных параметров';
            Row.ExecutorCall := Row.VirtualCommand;
            Row.CheckText := 'Generated/Applied/Sample verified';
            AppendStep;

            if NoProgressSteps >= 20 then
            begin
              FinalReason := Format('FAIL — отсутствует прогресс FSM; Stage=%s; WorkTable.State=%s; Point=%d; Repeat=%d; GeneratedQ=%.9f; AppliedQ=%.9f; LastSampleQ=%.9f; TargetQ=%.9f; StableStatus=%s; LastVirtualCommand=%s; LastVirtualResponse=%s; VirtualTime=%d; RealExecutionTime=%d',
                [TMeasurementRun.MeasurementStateToString(Run.Stage), TWorkTable.WorkTableStateToString(WT.State),
                 Run.CurrentPointIndex, Run.CurrentRepeat, ActualQ, AppliedQ, LastSampleQ, TargetQ, StableText,
                 Row.VirtualCommand, Row.VirtualResponse, TMeterValue.GetMonotonicTimeMs, TThread.GetTickCount - StartTick]);
              Break;
            end;

            if Run.Stage = msDone then
              Break;
          end;
          RepeatCount := 0;
          for I := 0 to Run.Points.Count - 1 do
            if Run.Points[I] <> nil then
              Inc(RepeatCount, Max(1, Run.Points[I].Repeats));
          if FinalReason = '' then
          begin
            if Step >= AUTO_MEASUREMENT_MAX_STEPS - 1 then
              FinalReason := 'FAIL — превышен лимит шагов/событий, вероятен цикл FSM'
            else if (Run.Stage = msDone) and Run.RunCompleted and (Run.RunResult = mrrSuccess) and (AScenarioIndex in [0,1,2,19]) then
            begin
              FinalKind := amtrkPass;
              FinalReason := 'PASS — обязательные проверки сценария выполнены, рабочее сохранение заблокировано SimulationMode';
            end
            else if AScenarioIndex in [3,4,5,7,8,9,10,11,13,14,15,17,18] then
              FinalReason := 'FAIL — сценарий отрицательной ветки выполнен без PASS по одному только msDone'
            else
              FinalReason := 'FAIL — итоговое состояние не совпало с Expected/Actual сценария';
          end;
        end;
      except
        on E: Exception do
        begin
          FinalKind := amtrkError;
          FinalReason := 'ERROR — ' + E.Message;
        end;
      end;
      if (Run <> nil) and Run.IsWorkerThreadRunning then
        Run.Execute(mcStop, Null);
      for I := 0 to 50 do
      begin
        if (Run = nil) or (not Run.IsWorkerThreadRunning) then
          Break;
        Application.ProcessMessages;
        TThread.Sleep(1);
      end;
      if WT.FlowRate <> nil then RestoreMeter(WT.FlowRate.Value, OldFlowSamples, OldFlowValue);
      if WT.FluidTemp <> nil then RestoreMeter(WT.FluidTemp.Value, OldTempSamples, OldTempValue);
      if WT.FluidPress <> nil then RestoreMeter(WT.FluidPress.Value, OldPressSamples, OldPressValue);
      TMeterValue.DisableVirtualClock;
      WT.IsSimulationMode := OldSimulation;
      WT.CurrentPoint.Assign(OldPoint, True);
      FreeAndNil(OldPoint);
      WT.State := OldState;
      FAutoTestRealCommandsBlocked := False;
      FAutoTestRunning := False;
    end;

    if FinalKind = amtrkFail then
    begin
      if StartsText('PASS', FinalReason) then FinalKind := amtrkPass
      else if StartsText('STOPPED', FinalReason) then FinalKind := amtrkStopped
      else if StartsText('ERROR', FinalReason) then FinalKind := amtrkError;
    end;

    LogFile := TPath.Combine(TPath.GetTempPath, Format('AUTO_MEASUREMENT_TEST_%s.txt', [FormatDateTime('yyyymmdd_hhnnss', Now)]));
    Lines.Add('Result=' + FinalReason);
    Lines.Add('RestoreState=Done; WorkTableRecreated=False; RealCommandsBlocked=True; WorkingDbSaveBlocked=True');
    Lines.SaveToFile(LogFile, TEncoding.UTF8);

    ResultRow.Num := Length(FAutoTestResultRows) + 1;
    ResultRow.Scenario := ScenarioName;
    case FinalKind of
      amtrkPass: ResultRow.ResultText := 'PASS';
      amtrkError: ResultRow.ResultText := 'ERROR';
      amtrkStopped: ResultRow.ResultText := 'STOPPED';
    else ResultRow.ResultText := 'FAIL';
    end;
    ResultRow.ElapsedMs := TThread.GetTickCount - StartTick;
    ResultRow.VirtualTimeSec := Max(0, Length(FAutoTestStepRows) - 1);
    if (Run <> nil) and (Run.Points <> nil) then ResultRow.PointCount := Run.Points.Count else ResultRow.PointCount := 0;
    ResultRow.RepeatCount := RepeatCount;
    if Run <> nil then ResultRow.FinalStage := TMeasurementRun.MeasurementStateToString(Run.Stage) else ResultRow.FinalStage := '-';
    if WT <> nil then ResultRow.FinalWorkTableState := TWorkTable.WorkTableStateToString(WT.State) else ResultRow.FinalWorkTableState := '-';
    ResultRow.Reason := FinalReason;
    ResultRow.LogFile := LogFile;
    ResultRow.ResultKind := FinalKind;
    SetLength(FAutoTestResultRows, Length(FAutoTestResultRows) + 1);
    FAutoTestResultRows[High(FAutoTestResultRows)] := ResultRow;

    RefreshGridRowCount(GridAutoTestNumbers, Length(FAutoTestStepRows), 'auto-test-step');
    RefreshGridValues(GridAutoTestNumbers, 'auto-test-step');
    RefreshGridRowCount(GridAutoTestResults, Length(FAutoTestResultRows), 'auto-test-result');
    RefreshGridValues(GridAutoTestResults, 'auto-test-result');
    if FAutoTestStatusLabel <> nil then
      FAutoTestStatusLabel.Text := FinalReason;
    RefreshAutoMeasurementTestContext;
  finally
    Lines.Free;
    if ButtonStopAutoTestScenario <> nil then
      ButtonStopAutoTestScenario.Enabled := False;
  end;
end;

procedure TFrameMainTable.MeasurementButtonClickManualMode;
begin
  if FActiveWorkTable = nil then
    Exit;

  if IsTestButtonSaveMode then
  begin
    AcceptMeasurementResults;
    Exit;
  end;

  if IsMeasurementActive(FActiveWorkTable) then
    StopMeasurement
  else
    StartMeasurement;
end;

procedure TFrameMainTable.MeasurementButtonClickAutoMode;
var
  Run: TMeasurementRun;
begin
  Run := MeasurementRun;
  if Run = nil then
    Exit;

  case Run.Stage of
    msNone:
      StartMeasurement;

    msDone:
      if Run.RunCompleted and (Run.RunResult = mrrSuccess) then
      begin
        ProtocolManager.AddMessage(pcAction, psForm, 'RollbackMeasurementRun',
          'Запрошена отмена результатов последнего автоматического запуска', '');
        Run.Execute(mcCancel);
      end
      else
        StartMeasurement;

    msSelectPoint,
    msHydraulicLineConfiguration,
    msSetupHydraulicLine,
    msSetupPoint,
    msWaitStable,
    msWaitMeasureStart,
    msMeasure,
    msWaitMeasureStop,
    msResultsRead,
    msSave:
      StopMeasurement;
  else
    Exit;
  end;
end;

function TFrameMainTable.IsTestButtonSaveMode: Boolean;
begin
  Result := (FActiveWorkTable <> nil) and
    (TestButton <> nil) and
    (TestButton.Tag = 6) and
    SameText(Trim(TestButton.Text), 'Сохранить?') and
    (FActiveWorkTable.State = swtSaveConfirmation);
end;

function TFrameMainTable.IsMeasurementActive(AWorkTable: TWorkTable): Boolean;
var
  Run: TMeasurementRun;
begin
  Result := False;

  if AWorkTable = nil then
    Exit;

  Run := MeasurementRun;
  if (Run <> nil) and not (Run.Stage in [msNone, msDone]) then
    Exit(True);

  Result := AWorkTable.State in [
    swtSTARTTEST,
    swtSTARTWAIT,
    swtEXECUTE,
    swtSTOPTEST,
    swtSTOPWAIT
  ];
end;

// Returns True when the current table appears to have measurement results
// that were not materialized into device spillages yet.
// TODO: Replace this indirect check with an explicit WorkTable.HasUnsavedMeasurementResults flag.
function TFrameMainTable.NeedSaveMeasurementResults(
  AWorkTable: TWorkTable): Boolean;
var
  Channel: TChannel;
begin
  Result := False;

  if AWorkTable = nil then
    Exit;

  for Channel in AWorkTable.DeviceChannels do
    if (Channel <> nil) and
       Channel.Enabled and
       (Channel.FlowMeter <> nil) and
       (Channel.FlowMeter.Device <> nil) and
       ((Channel.FlowMeter.Device.Spillages = nil) or
        (Channel.FlowMeter.Device.Spillages.Count = 0)) then
    begin
      Result := True;
      Exit;
    end;
end;

// Передаёт подтверждение в TMeasurementRun; сам интерфейс данные не сохраняет.
procedure TFrameMainTable.AcceptMeasurementResults;
begin
  // Интерфейс только передаёт решение текущему сценарию измерения.
  if MeasurementRun <> nil then
    MeasurementRun.AcceptMeasurementResults;
end;

// Handles the main measurement button click.
// The handler must only dispatch the user intent:
// - accept pending measurement results;
// - stop the active measurement;
// - start a new measurement.
// Business logic must be kept in dedicated helper methods.
procedure TFrameMainTable.TestButtonClick(Sender: TObject);
var Active: Boolean; Run: TMeasurementRun; StageValue, PointIndex: Integer;
begin
  if FActiveWorkTable = nil then Exit;
  if IsTestButtonSaveMode then
  begin
    AcceptMeasurementResults;
    Exit;
  end;
  Run := MeasurementRun;
  Active := IsMeasurementActive(FActiveWorkTable);
  StageValue := -1; PointIndex := -1;
  if Run <> nil then begin StageValue := Ord(Run.Stage); PointIndex := Run.CurrentPointIndex; end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementMainButtonClicked',
    'Нажата центральная кнопка измерения',
    Format('Action=%s; WorkTableState=%d; RunStage=%d; CurrentPointIndex=%d',
      [System.StrUtils.IfThen(Active, 'Stop', 'Start'), Ord(FActiveWorkTable.State), StageValue, PointIndex]));
  if Active then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementStopRequested',
      'Передан запрос штатной остановки измерения',
      Format('WorkTableState=%d; RunStage=%d; CurrentPointIndex=%d; SetupInProgress=%s',
        [Ord(FActiveWorkTable.State), StageValue, PointIndex,
         BoolToStr((Run <> nil) and (Run.Stage in [msSetupPoint, msWaitPointSetup]), True)]));
    StopMeasurement;
  end
  else
    StartMeasurement;
end;

procedure TFrameMainTable.Button1Click(Sender: TObject);
begin
UpdateForm;
end;

procedure TFrameMainTable.ButtonCancelClick(Sender: TObject);
begin
  if FActiveWorkTable = nil then
  begin
    OnChangeState(swtSTANDBY);
    Exit;
  end;

  ProtocolManager.AddMessage(pcAction, psForm, 'Cancel',
    'Пользователь запросил отмену текущего действия',
    FActiveWorkTable.Name);

  case FActiveWorkTable.State of
    swtSTARTTEST,
    swtSTARTWAIT,
    swtEXECUTE:
      StopMeasurement;

    swtSTOPTEST,
    swtSTOPWAIT:
      begin
        // Уже останавливаемся. Повторно ничего не делаем.
      end;

    swtSaveConfirmation:
      begin
        // Интерфейс только передаёт отказ; выход из msSave выполняет автомат.
        if MeasurementRun <> nil then
          MeasurementRun.RejectMeasurementResults;
      end;

    swtSTARTMONITOR,
    swtSTARTMONITORWAIT,
    swtMONITOR:
      begin
        FActiveWorkTable.StopMonitor;
      end;

  else
    begin
      // Для спокойных состояний Cancel просто возвращает UI в нормальный режим.
      if FActiveWorkTable.State <> swtCONNECTED then
        FActiveWorkTable.State := swtCONNECTED;
    end;
  end;
end;


function TFrameMainTable.GetDeviceGroupColor(const AGroup: Integer): TAlphaColor;
begin
  Result := GRID_DEVICE_GROUP_COLORS[Abs(AGroup) mod Length(GRID_DEVICE_GROUP_COLORS)];
end;

function TFrameMainTable.GetErrorCellColor(AChannel: TChannel;
  const AText: string; out AColor: TAlphaColor): Boolean;
var
  S: string;
  ActualError: Double;
  AllowedError: Double;
  DeviceFlow: Double;
  Distance: Double;
  MinDistance: Double;
  DevicePoint: TDevicePoint;
  MatchedPoint: TDevicePoint;
begin
  Result := False;
  AColor := TAlphaColors.Null;

  S := Trim(AText);
  if (AChannel = nil) or (AChannel.FlowMeter = nil) or
     (AChannel.FlowMeter.Device = nil) or
     (AChannel.FlowMeter.ValueFlow = nil) or
     (AChannel.FlowMeter.Device.Points = nil) or
     (S = '') or (S = '-') then
    Exit;

  S := StringReplace(S, '%', '', [rfReplaceAll]);
  S := StringReplace(S, '±', '', [rfReplaceAll]);
  S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  if not TryStrToFloat(Trim(S), ActualError) then
    Exit;

  DeviceFlow := AChannel.FlowMeter.ValueFlow.GetDoubleValue;
  MatchedPoint := nil;
  MinDistance := MaxDouble;

  for DevicePoint in AChannel.FlowMeter.Device.Points do
  begin
    if (DevicePoint = nil) or (DevicePoint.State = osDeleted) then
      Continue;

    Distance := Abs(DeviceFlow - DevicePoint.Q);
    if Distance < MinDistance then
    begin
      MinDistance := Distance;
      MatchedPoint := DevicePoint;
    end;
  end;

  if MatchedPoint = nil then
    Exit;

  AllowedError := Abs(MatchedPoint.Error);

  Result := True;
  if Abs(ActualError) <= AllowedError then
    AColor := COLOR_COMPLETED
  else if  Abs(ActualError) <= NormalizeFloatInput(MatchedPoint.FlowAccuracy )  then
    AColor := COLOR_WARNING
  else AColor:= TAlphaColors.Null;
end;

procedure TFrameMainTable.GridDevicesDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
var
  Channel: TChannel;
  CellColor: TAlphaColor;
  IsChannelColumn: Boolean;
  NeedCustomDraw: Boolean;
begin
  IsChannelColumn := Column = StringColumnDeviceChanel1;
  if Odd(Row) then
    CellColor := GRID_ALTERNATE_ROW_COLOR
  else
    CellColor := TAlphaColors.White;

  if IsChannelColumn and (FActiveWorkTable <> nil) and
     (Row >= 0) and (Row < FActiveWorkTable.DeviceChannels.Count) then
  begin
    Channel := FActiveWorkTable.DeviceChannels[Row];
    if Channel <> nil then
      CellColor := GetDeviceGroupColor(Channel.Group);
  end;

  if (Column = StringColumnDeviceError1) and (FActiveWorkTable <> nil) and
     (Row >= 0) and (Row < FActiveWorkTable.DeviceChannels.Count) and
     (FActiveWorkTable.DeviceChannels[Row] <> nil) then
    GetErrorCellColor(FActiveWorkTable.DeviceChannels[Row],
      Value.ToString, CellColor);

  NeedCustomDraw := (Column = StringColumnDeviceError1) or IsChannelColumn or
    (not (Sender is TGrid)) or (Row <> TGrid(Sender).Row);

  if (not (Column is TCheckColumn)) and
     NeedCustomDraw then
  begin
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := CellColor;
    Canvas.FillRect(Bounds, 0, 0, [], 1);
    Column.DefaultDrawCell(Canvas, Bounds, Row, Value, State);
  end;
end;

procedure TFrameMainTable.GridDevicesCreateCustomEditor(Sender: TObject;
  const Column: TColumn; var Control: TStyledControl);
var
  Editor: TValueEditCellEditor;
  Value: TValue;
begin
  if not IsDeviceReadingColumn(Column) or
     not IsVisualInputChannel(FActiveWorkTable, GridDevices.Row, 1) then
    Exit;

  GridDevicesGetValue(GridDevices, Column.Index, GridDevices.Row, Value);
  Editor := TValueEditColumn(Column).CreateEditor(Column.Index,
    GridDevices.Row, Value.ToString);
  Control := Editor;
end;

{ Определяет, нужна ли кнопка фотофиксации для строки редактора. }
procedure TFrameMainTable.DeviceReadingButtonVisible(Sender: TObject;
  const ACol, ARow: Integer; var AVisible: Boolean);
var
  Channel: TChannel;
begin
  AVisible := False;
  if (FActiveWorkTable = nil) or (ARow < 0) or
     (ARow >= FActiveWorkTable.DeviceChannels.Count) then
    Exit;
  Channel := FActiveWorkTable.DeviceChannels[ARow];
  AVisible := (Channel <> nil) and (Channel.FlowMeter <> nil) and
    (Channel.FlowMeter.Device <> nil) and
    (Channel.FlowMeter.Device.OutputType = Ord(otVisual)) and
    (Channel.FlowMeter.Device.InputType = 1);
end;

{ Преобразует сохраненный относительный путь снимка в абсолютный. }
function TFrameMainTable.ResolveReadingPhotoPath(
  const AStoredPath: string): string;
var
  ProjectFile: string;
begin
  Result := Trim(AStoredPath);
  if (Result = '') or TPath.IsPathRooted(Result) then
    Exit;
  ProjectFile := GetProjectSettingsFileName;
  if ProjectFile <> '' then
    Result := TPath.GetFullPath(TPath.Combine(
      TPath.GetDirectoryName(ProjectFile), Result));
end;

{ Копирует выбранную фотографию в каталог проекта и возвращает
  относительный путь, который безопасно хранить в настройках и БД. }
function TFrameMainTable.StorePendingReadingPhoto(const ASourcePath,
  APreviousStoredPath: string): string;
var
  ProjectFile: string;
  ProjectDir: string;
  RelativeDir: string;
  PendingDir: string;
  SourceFile: string;
  TargetFile: string;
  PreviousFile: string;
  Extension: string;
  FileName: string;
  PhotoGuid: TGUID;
begin
  SourceFile := TPath.GetFullPath(Trim(ASourcePath));
  if not FileExists(SourceFile) then
    raise Exception.Create('Файл фотографии не найден: ' + SourceFile);

  ProjectFile := GetProjectSettingsFileName;
  if Trim(ProjectFile) = '' then
    raise Exception.Create('Не определён файл текущего проекта');

  ProjectDir := TPath.GetDirectoryName(ProjectFile);
  RelativeDir := TPath.Combine(
    TPath.GetFileNameWithoutExtension(ProjectFile) + '_files',
    TPath.Combine('Photos', 'Pending'));
  PendingDir := TPath.GetFullPath(TPath.Combine(ProjectDir, RelativeDir));
  ForceDirectories(PendingDir);

  Extension := LowerCase(TPath.GetExtension(SourceFile));
  if Extension = '' then
    Extension := '.jpg';
  CreateGUID(PhotoGuid);
  FileName := StringReplace(StringReplace(GUIDToString(PhotoGuid),
    '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]) + Extension;
  TargetFile := TPath.Combine(PendingDir, FileName);
  TFile.Copy(SourceFile, TargetFile, False);
  Result := TPath.Combine(RelativeDir, FileName);

  { После успешного копирования удаляем заменённый временный снимок,
    но никогда не удаляем произвольный внешний файл пользователя. }
  PreviousFile := ResolveReadingPhotoPath(APreviousStoredPath);
  if (PreviousFile <> '') and FileExists(PreviousFile) and
     StartsText(IncludeTrailingPathDelimiter(PendingDir), PreviousFile) then
    try
      TFile.Delete(PreviousFile);
    except
      { Старый временный файл не мешает использовать новый снимок. }
    end;
end;

procedure TFrameMainTable.DeviceReadingButtonClick(Sender: TObject;
  const ACol, ARow: Integer; const AText: string);
var
  Column: TColumn;
  Row: Integer;
  ReadingValue: Double;
  ReadingText: string;
  PhotoPath: string;
  SelectedPhotoFile: string;
  StoredPhotoPath: string;
  PreviousPhotoPath: string;
  EditedValue: Double;
  IsBefore: Boolean;
begin
  if (ACol < 0) or (ACol >= GridDevices.ColumnCount) then
    Exit;
  Column := GridDevices.Columns[ACol];
  Row := ARow;
  if not IsDeviceReadingColumn(Column) or
     not IsVisualInputChannel(FActiveWorkTable, Row, 1) then
    Exit;

  if not TryStrToFloat(StringReplace(StringReplace(
       Trim(AText), '.', FormatSettings.DecimalSeparator,
       [rfReplaceAll]), ',', FormatSettings.DecimalSeparator, [rfReplaceAll]),
       EditedValue) then
  begin
    ShowMessage('Некорректное числовое значение');
    Exit;
  end;
  GridDevicesSetValue(GridDevices, ACol, ARow, AText);
  IsBefore := Column = StringColumnDeviceQuantityBefore1;
  if IsBefore then
  begin
    ReadingValue := FActiveWorkTable.DeviceChannels[Row].ValueBefore;
    PhotoPath := FActiveWorkTable.DeviceChannels[Row].PhotoBeforePath;
  end
  else
  begin
    ReadingValue := FActiveWorkTable.DeviceChannels[Row].ValueAfter;
    PhotoPath := FActiveWorkTable.DeviceChannels[Row].PhotoAfterPath;
  end;
  PhotoPath := ResolveReadingPhotoPath(PhotoPath);
  if PhotoPath = '' then
    PhotoPath := CTestPhotoReadingFile;

  ReadingText := FActiveWorkTable.DeviceChannels[Row].FlowMeter.ValueQuantity.GetStrNum(
    ReadingValue, 0);

  if TFormPhotoReading.Execute(
    PhotoPath, ReadingText, ReadingValue, SelectedPhotoFile) then
  begin
    if SelectedPhotoFile <> '' then
    begin
      if IsBefore then
        PreviousPhotoPath :=
          FActiveWorkTable.DeviceChannels[Row].PhotoBeforePath
      else
        PreviousPhotoPath :=
          FActiveWorkTable.DeviceChannels[Row].PhotoAfterPath;

      try
        StoredPhotoPath := StorePendingReadingPhoto(
          SelectedPhotoFile, PreviousPhotoPath);
      except
        on E: Exception do
        begin
          ShowMessage('Не удалось сохранить фотографию:' +
            sLineBreak + E.Message);
          Exit;
        end;
      end;

      if IsBefore then
        FActiveWorkTable.DeviceChannels[Row].PhotoBeforePath :=
          StoredPhotoPath
      else
        FActiveWorkTable.DeviceChannels[Row].PhotoAfterPath :=
          StoredPhotoPath;
    end;

    { GridDevicesSetValue сохраняет показание и новые пути рабочего стола.
      При сохранении проливки пути переносятся в PointSpillage в БД. }
    GridDevicesSetValue(GridDevices, ACol, ARow, FloatToStr(ReadingValue));
  end;
end;

{ Запускает редактор показания одним щелчком по числовой области. }
procedure TFrameMainTable.BeginDeviceReadingEdit(const ACol, ARow: Integer);
begin
  if (ACol < 0) or (ACol >= GridDevices.ColumnCount) or
     (ARow < 0) or (ARow >= GridDevices.RowCount) then
    Exit;

  GridDevices.Col := ACol;
  GridDevices.Row := ARow;
  GridDevices.ReadOnly := False;
  GridDevices.Options := GridDevices.Options + [TGridOption.Editing];
  TThread.ForceQueue(nil,
    procedure
    begin
      if (GridDevices.Col = ACol) and (GridDevices.Row = ARow) then
      begin
        GridDevices.SetFocus;
        GridDevices.EditorMode := True;
      end;
    end);
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
  ActivateMeasurementGrid(GridDevices);
  WorkTable := FActiveWorkTable;

  if IsDeviceReadingColumn(Column) then
  begin
    GridDevices.ReadOnly := True;
    GridDevices.EditorMode := False;

    { Вне редактирования ячейка показывает только значение.
      Кнопка фото создаётся внутри активного редактора. }
    if IsVisualInputChannel(WorkTable, Row, 0) or
       IsVisualInputChannel(WorkTable, Row, 1) then
      BeginDeviceReadingEdit(Column.Index, Row);
    Exit;
  end;

  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

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
      if WorkTable.DeviceChannels[Row].Enabled then
        begin
          ApplyEnabledChannelSimulationValues(WorkTable, False);
        end
      else
        begin
          ClearChannelSimulationValues(WorkTable.DeviceChannels[Row]);
          ApplyEnabledChannelSimulationValues(WorkTable, False);
        end;
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

  RefreshGridRowCount(GridDevices, Rows, 'device-structure');
  if Column = CheckColumnDeviceEnable1 then
    UpdateDeviceCoefficientHeaders;
  RefreshGridValues(GridDevices, 'device-structure');

  UpdateFlowMeterPropertiesFrame(Row);
  if (FFrameChannelProperties <> nil) and (WorkTable <> nil) and
     (Row >= 0) and (Row < WorkTable.DeviceChannels.Count) then
    FFrameChannelProperties.LoadFromChannel(WorkTable.DeviceChannels[Row]);
end;

procedure TFrameMainTable.ActivateMeasurementGrid(AGrid: TGrid);
var
  OtherGrid: TGrid;
begin
  { Keep focus and selection mutually exclusive without recursive OnEnter calls. }
  if FChangingMeasurementGridFocus or (AGrid = nil) then
    Exit;
  if AGrid = GridDevices then
    OtherGrid := GridEtalons
  else if AGrid = GridEtalons then
    OtherGrid := GridDevices
  else
    Exit;
  FChangingMeasurementGridFocus := True;
  try
    OtherGrid.EditorMode := False;
    OtherGrid.Selected := -1;
    OtherGrid.Row := -1;
    OtherGrid.ResetFocus;
  finally
    FChangingMeasurementGridFocus := False;
  end;
end;

procedure TFrameMainTable.GridDevicesEnter(Sender: TObject);
begin
  ActivateMeasurementGrid(GridDevices);
end;

procedure TFrameMainTable.GridEtalonsEnter(Sender: TObject);
begin
  ActivateMeasurementGrid(GridEtalons);
end;

procedure TFrameMainTable.GridDevicesHeaderClick(Column: TColumn);
begin
  if Column = CheckColumnDeviceEnable1 then
  begin
    ToggleAllDeviceChannels;
    Exit;
  end;

  if Column = CheckColumnEtalonEnable1 then
  begin
    ToggleAllEtalonChannels;
    Exit;
  end;
end;

procedure TFrameMainTable.ToggleAllChannelRows(AGrid: TGrid;
  AChannels: TObjectList<TChannel>; const AEtalonChannels: Boolean);
var
  I: Integer;
  HasEnabled: Boolean;
  NewEnabled: Boolean;
  Channel: TChannel;
begin
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  if (AGrid = nil) or (AChannels = nil) or (AChannels.Count = 0) then
    Exit;

  HasEnabled := False;
  for I := 0 to AChannels.Count - 1 do
    if (AChannels[I] <> nil) and AChannels[I].Enabled then
    begin
      HasEnabled := True;
      Break;
    end;

  NewEnabled := not HasEnabled;
  AGrid.BeginUpdate;
  try
    for I := 0 to AChannels.Count - 1 do
    begin
      Channel := AChannels[I];
      if Channel = nil then
        Continue;
      Channel.Enabled := NewEnabled;
      MarkChannelDeviceModified(Channel);
    end;
  finally
    AGrid.EndUpdate;
  end;

  ApplyEnabledChannelSimulationValues(FActiveWorkTable, AEtalonChannels);
  FActiveWorkTable.RebindAllFlowMeters;
  if WorkTableManager <> nil then
    WorkTableManager.Save;
  AGrid.Repaint;
  RefreshActiveWorkTableViews(nil);
end;

procedure TFrameMainTable.ToggleAllDeviceChannels;
begin
  if FActiveWorkTable <> nil then
    ToggleAllChannelRows(GridDevices, FActiveWorkTable.DeviceChannels, False);
end;

procedure TFrameMainTable.ToggleAllEtalonChannels;
begin
  if FActiveWorkTable <> nil then
    ToggleAllChannelRows(GridEtalons, FActiveWorkTable.EtalonChannels, True);
end;

procedure TFrameMainTable.GridDevicesCellDblClick(const Column: TColumn;
  const Row: Integer);
var
  Rows: Integer;
  WorkTable: TWorkTable;
begin
  ActivateMeasurementGrid(GridDevices);
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


  RefreshGridRowCount(GridDevices, Rows, 'device-structure');
  RefreshGridValues(GridDevices, 'device-structure');

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
  ActivateMeasurementGrid(GridDevices);
  if (ACol >= 0) and (ACol < GridDevices.ColumnCount) and
     IsDeviceReadingColumn(GridDevices.Columns[ACol]) then
  begin
    { Показания измерения редактируются независимо от режима настроек. }
    ApplyActiveWorkTableEditMode;
    RefreshGridValues(GridDevices, 'visual-reading-finished');
    Exit;
  end;
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

function TFrameMainTable.GetDisplayFlowText(AFlowMeter: TFlowMeter;
  AWorkTable: TWorkTable): string;
begin
  Result := '-';
  if (AFlowMeter = nil) or (AFlowMeter.ValueFlow = nil) then
    Exit;

  if (AWorkTable <> nil) and (AWorkTable.ValueFlowRate <> nil) then
    Result := AWorkTable.ValueFlowRate.GetStrNum(AFlowMeter.ValueFlow.GetDoubleValue)
  else
    Result := AFlowMeter.ValueFlow.GetStrValue;
end;

function TFrameMainTable.GetAverageFlowText(AFlowMeter: TFlowMeter;
  AWorkTable: TWorkTable): string;
var
  AverageFlow: Double;
begin
  Result := '-';
  if not TryGetAverageFlow(AFlowMeter, AWorkTable, AverageFlow) then
    Exit;

  if AWorkTable.ValueFlowRate <> nil then
    Result := AWorkTable.ValueFlowRate.GetStrNum(AverageFlow)
  else if (AFlowMeter <> nil) and (AFlowMeter.ValueFlow <> nil) then
    Result := AFlowMeter.ValueFlow.GetStrNum(AverageFlow);
end;

function TFrameMainTable.TryGetAverageFlow(AFlowMeter: TFlowMeter;
  AWorkTable: TWorkTable; out AAverageFlow: Double): Boolean;
var
  MeasureTime: Double;
begin
  Result := False;
  AAverageFlow := 0;

  if (AFlowMeter = nil) or (AFlowMeter.ValueQuantity = nil) or
     (AWorkTable = nil) or (AWorkTable.ValueTime = nil) then
    Exit;

  MeasureTime := AWorkTable.ValueTime.GetDoubleValue;
  if MeasureTime <= 0 then
    Exit;

  AAverageFlow := AFlowMeter.ValueQuantity.GetDoubleValue / MeasureTime;
  Result := True;
end;

function TFrameMainTable.CalculateCurrentDeviationPercent(
  const ACurrentValue, AMeanValue: Double): Double;
begin
  if Abs(AMeanValue) <= CurrentDeviationEpsilon then
    Exit(0);

  Result := (ACurrentValue - AMeanValue) / Abs(AMeanValue) * 100;
end;


function TFrameMainTable.GetGridCoefficientDimensionCoef(
  AWorkTable: TWorkTable): Integer;
var
  I: Integer;
  CurrentDimensionCoef: Integer;
  CommonDimensionCoef: Integer;
  Channel: TChannel;
  Device: TDevice;
  RepresentationFound: Boolean;
begin
  { imp/l is the base and fallback representation. }
  Result := 0;
  if (AWorkTable = nil) or (AWorkTable.DeviceChannels = nil) then
    Exit;

  CommonDimensionCoef := 0;
  RepresentationFound := False;

  for I := 0 to AWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := AWorkTable.DeviceChannels[I];
    if (Channel = nil) or
       (not Channel.Enabled) or
       not (Channel.Signal in [Ord(otFrequency), Ord(otImpulse)]) or
       (Channel.FlowMeter = nil) then
      Continue;

    Device := Channel.FlowMeter.Device;
    if Device = nil then
      Continue;

    if Device.DimensionCoef = 1 then
      CurrentDimensionCoef := 1
    else
      CurrentDimensionCoef := 0;

    if not RepresentationFound then
    begin
      CommonDimensionCoef := CurrentDimensionCoef;
      RepresentationFound := True;
    end
    else if CommonDimensionCoef <> CurrentDimensionCoef then
      Exit(0);
  end;

  if RepresentationFound then
    Result := CommonDimensionCoef;
end;


function TFrameMainTable.GetCoefficientUnit(
  ADimensionCoef: Integer): string;
begin
  if ADimensionCoef = 1 then
    Result := 'л/имп'
  else
    Result := 'имп/л';
end;


procedure TFrameMainTable.UpdateDeviceCoefficientHeaders;
var
  I: Integer;
  GridDimensionCoef: Integer;
  Channel: TChannel;
  UnitName: string;
  CoefHeader: string;
  CalculatedCoefHeader: string;
begin
  GridDimensionCoef := GetGridCoefficientDimensionCoef(FActiveWorkTable);

  { Set one common representation for every coefficient meter value.
    GetStrNum then performs both dimension conversion and error-based rounding. }
  if (FActiveWorkTable <> nil) and
     (FActiveWorkTable.DeviceChannels <> nil) then
    for I := 0 to FActiveWorkTable.DeviceChannels.Count - 1 do
    begin
      Channel := FActiveWorkTable.DeviceChannels[I];
      if (Channel = nil) or
         not (Channel.Signal in [Ord(otFrequency), Ord(otImpulse)]) or
         (Channel.FlowMeter = nil) or
         (Channel.FlowMeter.ValueCoef = nil) then
        Continue;

      Channel.FlowMeter.ValueCoef.SetDim(GridDimensionCoef);
    end;

  UnitName := GetCoefficientUnit(GridDimensionCoef);

  CoefHeader := 'Кф, ' + UnitName;
  CalculatedCoefHeader := 'Кф расч., ' + UnitName;

  if (StringColumnDeviceCoef1 <> nil) and
     (StringColumnDeviceCoef1.Header <> CoefHeader) then
    if Assigned(StringColumnDeviceCoef1) then
      StringColumnDeviceCoef1.Header := CoefHeader;

  if (StringColumnDeviceCalculatedCoef1 <> nil) and
     (StringColumnDeviceCalculatedCoef1.Header <> CalculatedCoefHeader) then
    if Assigned(StringColumnDeviceCalculatedCoef1) then
      StringColumnDeviceCalculatedCoef1.Header := CalculatedCoefHeader;
end;


function TFrameMainTable.GetDeviceCoefficientText(
  AChannel: TChannel): string;
var
  Device: TDevice;
  BaseCoef: Double;
begin
  Result := '-';

  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;

  Device := AChannel.FlowMeter.Device;

  { Representation applies only to pulse and frequency signals. }
  if (Device = nil) or
     not (AChannel.Signal in [Ord(otFrequency), Ord(otImpulse)]) then
  begin
    if AChannel.FlowMeter.ValueCoef <> nil then
      Result := AChannel.FlowMeter.ValueCoef.GetStrValue;
    Exit;
  end;

  if AChannel.FlowMeter.ValueCoef = nil then
    Exit;

  { Device.Coef and ValueCoef.Value are stored in the base imp/l representation.
    CurrentDimIndex was set once for the whole grid in the header update. }
  BaseCoef := Device.Coef;
  if BaseCoef <= 0 then
    BaseCoef := AChannel.FlowMeter.ValueCoef.Value;

  if (BaseCoef <= 0) or IsNan(BaseCoef) or IsInfinite(BaseCoef) then
    Exit;

  Result := AChannel.FlowMeter.ValueCoef.GetStrNum(BaseCoef);
end;


function TFrameMainTable.GetCalculatedDeviceCoefficientText(
  AChannel: TChannel; AWorkTable: TWorkTable): string;
var
  Device: TDevice;
  PulseCount: Double;
  ReferenceQuantity: Double;
  CalculatedCoef: Double;
begin
  Result := '-';

  if (AChannel = nil) or (AWorkTable = nil) or
     (AChannel.FlowMeter = nil) or (AChannel.FlowMeter.Device = nil) then
    Exit;

  if not (AChannel.Signal in [Ord(otFrequency), Ord(otImpulse)]) then
    Exit;

  if AChannel.FlowMeter.ValueCoef = nil then
    Exit;

  Device := AChannel.FlowMeter.Device;
  if AChannel.ValueImpTotal <> nil then
    PulseCount := AChannel.ValueImpTotal.GetDoubleValue
  else
    PulseCount := AChannel.ImpResult;

  ReferenceQuantity := 0.0;
  case TMeasuredDimension(Device.MeasuredDimension) of
    mdVolumeFlow,
    mdVolume:
      if (AWorkTable.TableFlow <> nil) and
         (AWorkTable.TableFlow.ValueVolume <> nil) then
        ReferenceQuantity := AWorkTable.TableFlow.ValueVolume.GetDoubleValue;

    mdMassFlow,
    mdMass:
      if (AWorkTable.TableFlow <> nil) and
         (AWorkTable.TableFlow.ValueMass <> nil) then
        ReferenceQuantity := AWorkTable.TableFlow.ValueMass.GetDoubleValue;
  end;

  if (PulseCount <= 1E-12) or (ReferenceQuantity <= 1E-12) then
    Exit;

  { Calculate in the base imp/l representation. GetStrNum uses the common
    CurrentDimIndex and applies the coefficient meter value Accuracy/Error. }
  CalculatedCoef := PulseCount / ReferenceQuantity;

  if IsNan(CalculatedCoef) or IsInfinite(CalculatedCoef) then
    Exit;

  Result := AChannel.FlowMeter.ValueCoef.GetStrNum(CalculatedCoef);
end;


procedure TFrameMainTable.GridDevicesGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  WorkTable: TWorkTable;
  FlowMeter: TFlowMeter;
  CurrentFlow: Double;
  AverageFlow: Double;
  DebugChannel: TChannel;
  DebugError: TMeterValue;
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
        Value := GetDisplayFlowText(WorkTable.DeviceChannels[ARow].FlowMeter, WorkTable)
      else
        Value := '-';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceAvgFlowRate1 then
    begin
      Value := GetAverageFlowText(WorkTable.DeviceChannels[ARow].FlowMeter, WorkTable);
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceQuantity1 then
    begin
      if (WorkTable.DeviceChannels[ARow].FlowMeter <> nil) and
         (WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity <> nil) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.GetStrValue
      else
        Value := '-';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceQuantityBefore1 then
    begin
      if IsVisualInputChannel(WorkTable, ARow, 0) or
         IsVisualInputChannel(WorkTable, ARow, 1) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.GetStrNum(
          WorkTable.DeviceChannels[ARow].ValueBefore, 0)
      else
        Value := '';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceQuantityAfter1 then
    begin
      if IsVisualInputChannel(WorkTable, ARow, 0) or
         IsVisualInputChannel(WorkTable, ARow, 1) then
        Value := WorkTable.DeviceChannels[ARow].FlowMeter.ValueQuantity.GetStrNum(
          WorkTable.DeviceChannels[ARow].ValueAfter, 0)
      else
        Value := '';
    end
    else if GridDevices.Columns[ACol] = StringColumnDeviceCoef1 then
      Value := GetDeviceCoefficientText(WorkTable.DeviceChannels[ARow])
    else if GridDevices.Columns[ACol] = StringColumnDeviceCalculatedCoef1 then
      Value := GetCalculatedDeviceCoefficientText(
        WorkTable.DeviceChannels[ARow], WorkTable)
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
      FlowMeter := WorkTable.DeviceChannels[ARow].FlowMeter;
      if (FlowMeter <> nil) and (FlowMeter.ValueFlow <> nil) and
         TryGetAverageFlow(FlowMeter, WorkTable, AverageFlow) then
      begin
        CurrentFlow := FlowMeter.ValueFlow.GetDoubleValue;
        Value := FormatValue(CalculateCurrentDeviationPercent(
          CurrentFlow, AverageFlow), 2, 0);
      end
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
  if (ACol >= 0) and (ACol < GridDevices.ColumnCount) and
     IsDeviceReadingColumn(GridDevices.Columns[ACol]) and
     (IsVisualInputChannel(FActiveWorkTable, ARow, 0) or
      IsVisualInputChannel(FActiveWorkTable, ARow, 1)) then
  begin
    { Показания доступны независимо от режима настройки рабочего стола. }
    CanSelect := True;
    Exit;
  end;

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
  ReadingValue: Double;
begin
  if IsUpdating then
    Exit;

  WorkTable := FActiveWorkTable;

  if (WorkTable <> nil) and (ARow >= 0) and
     (ARow < WorkTable.DeviceChannels.Count) and
     IsDeviceReadingColumn(GridDevices.Columns[ACol]) then
  begin
    if (IsVisualInputChannel(WorkTable, ARow, 0) or
        IsVisualInputChannel(WorkTable, ARow, 1)) and
       TryStrToFloat(StringReplace(StringReplace(Trim(Value.AsString), '.',
         FormatSettings.DecimalSeparator, [rfReplaceAll]), ',',
         FormatSettings.DecimalSeparator, [rfReplaceAll]), ReadingValue) then
    begin
      if GridDevices.Columns[ACol] = StringColumnDeviceQuantityBefore1 then
        WorkTable.DeviceChannels[ARow].ValueBefore := ReadingValue
      else
        WorkTable.DeviceChannels[ARow].ValueAfter := ReadingValue;
      if not GridDevices.EditorMode then
        RefreshGridValues(GridDevices, 'visual-reading');
      ActionSaveWorkTableExecute(nil);
    end;
    Exit;
  end;

  if not CanEditActiveWorkTable then
    Exit;

  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.DeviceChannels.Count) then
  begin
    Changed := False;
    DeviceFieldsChanged := False;

    if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
    begin
      Changed := WorkTable.DeviceChannels[ARow].Enabled <> Value.AsBoolean;
      if Changed then
        PersistChannelEnabled(WorkTable, WorkTable.DeviceChannels[ARow], 'Device', WorkTable.DeviceChannels[ARow].Enabled, Value.AsBoolean);
      if FUpdatingChannelEnabled then
        Exit;
      FUpdatingChannelEnabled := True;
      try
        WorkTable.DeviceChannels[ARow].Enabled := Value.AsBoolean;
        if WorkTable.DeviceChannels[ARow].Enabled then
          begin
            ApplyEnabledChannelSimulationValues(WorkTable, False);
          end
        else
          begin
            ClearChannelSimulationValues(WorkTable.DeviceChannels[ARow]);
            ApplyEnabledChannelSimulationValues(WorkTable, False);
          end;
      finally
        FUpdatingChannelEnabled := False;
      end;
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
      RefreshActiveWorkTableViews(WorkTable.DeviceChannels[ARow]);
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
  OldEnabled: Boolean;
  NewEnabled: Boolean;
begin
  ActivateMeasurementGrid(GridEtalons);
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;

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
    if FUpdatingChannelEnabled then
      Exit;
    if WorkTable <> nil then
    begin
      FUpdatingChannelEnabled := True;
      try
      OldEnabled := WorkTable.EtalonChannels[Row].Enabled;
      NewEnabled := not OldEnabled;
      WorkTable.EtalonChannels[Row].Enabled := NewEnabled;
      PersistChannelEnabled(WorkTable, WorkTable.EtalonChannels[Row], 'Etalon',
        OldEnabled, NewEnabled);
      if WorkTable.EtalonChannels[Row].Enabled then
        begin
          DisableOtherChannelGroups(WorkTable.EtalonChannels, Row);
          ApplyEnabledChannelSimulationValues(WorkTable, True);
        end
      else
        begin
          ClearChannelSimulationValues(WorkTable.EtalonChannels[Row]);
          ApplyEnabledChannelSimulationValues(WorkTable, True);
        end;
      MarkChannelDeviceModified(WorkTable.EtalonChannels[Row]);
      finally
        FUpdatingChannelEnabled := False;
      end;
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

  RefreshGridRowCount(GridEtalons, Rows, 'etalon-structure');
  RefreshGridValues(GridEtalons, 'etalon-structure');

  UpdateFlowMeterPropertiesFrame(Row, True);
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
  ActivateMeasurementGrid(GridEtalons);
  if not CanEditActiveWorkTable then
  begin
    ApplyActiveWorkTableEditMode;
    Exit;
  end;

  NormalizeActiveWorkTable;
  WorkTable := FActiveWorkTable;

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


  RefreshGridRowCount(GridEtalons, Rows, 'etalon-structure');
  RefreshGridValues(GridEtalons, 'etalon-structure');

  UpdateFlowMeterPropertiesFrame(Row, True);
  if (FFrameChannelProperties <> nil) and (WorkTable <> nil) and
     (Row >= 0) and (Row < WorkTable.EtalonChannels.Count) then
    FFrameChannelProperties.LoadFromChannel(WorkTable.EtalonChannels[Row]);
end;


function TFrameMainTable.GetEtalonGroupColor(const AGroup: Integer): TAlphaColor;
begin
  Result := GRID_ETALON_GROUP_COLORS[Abs(AGroup) mod Length(GRID_ETALON_GROUP_COLORS)];
end;

function TFrameMainTable.IsHydraulicSimulationMode(AWorkTable: TWorkTable): Boolean;
begin
  Result := (AWorkTable <> nil) and
    (AWorkTable.IsSimulationMode or
     ((WorkTableManager <> nil) and WorkTableManager.IsSimulationMode));
end;

procedure TFrameMainTable.CompleteSimulatedHydraulicConfiguration(AWorkTable: TWorkTable);
var
  State: EHydraulicLineState;
  Error: TErrorInfo;
  OperationID: Int64;
  PointUUID: string;
  PointIndex, I, EtalonCount, ScaleCount: Integer;
  TargetFlow: Double;
  Configuration: RWorkTableHydraulicConfiguration;
  HydraulicRange: RWorkTableHydraulicRange;
  Channel: TChannel;
begin
  { Simulation creates a valid virtual selection through the public completion API. }
  if not IsHydraulicSimulationMode(AWorkTable) then
    Exit;
  AWorkTable.GetHydraulicStateSnapshot(State, Error, OperationID, PointUUID,
    PointIndex, TargetFlow, Configuration, HydraulicRange);
  if State <> hlsSelecting then
    Exit;
  Configuration := Default(RWorkTableHydraulicConfiguration);
  HydraulicRange := Default(RWorkTableHydraulicRange);
  Configuration.ChartIndex := 0;
  Configuration.ChartName := 'Simulation';
  Configuration.RangeIndex := 0;
  HydraulicRange.IsValid := True;
  HydraulicRange.Number := 0;
  HydraulicRange.FlowMin := 0;
  HydraulicRange.FlowMax := Max(TargetFlow, 1) * 2;
  Configuration.Range := HydraulicRange;
  EtalonCount := 0;
  ScaleCount := 0;
  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
  begin
    Channel := AWorkTable.EtalonChannels[I];
    if (Channel = nil) or not Channel.Enabled or (Channel.FlowMeter = nil) then
      Continue;
    if Channel.FlowMeter.MeterFlowCategory = mftWeightsType then
    begin
      SetLength(Configuration.ScaleNames, ScaleCount + 1);
      Configuration.ScaleNames[ScaleCount] := Channel.FlowMeter.Name;
      Inc(ScaleCount);
    end
    else
    begin
      SetLength(Configuration.EtalonNames, EtalonCount + 1);
      Configuration.EtalonNames[EtalonCount] := Channel.FlowMeter.Name;
      Inc(EtalonCount);
    end;
  end;
  if not AWorkTable.CompleteHydraulicConfigurationSearch(OperationID,
    PointUUID, PointIndex, Configuration, HydraulicRange) then
  begin
    Error := TErrorInfo.Empty(Integer(AWorkTable.State));
    Error.Code := 1381;
    Error.Msg := 'Не удалось завершить виртуальный поиск гидравлической конфигурации';
    Error.Time := Now;
    AWorkTable.FailHydraulicConfigurationSearch(OperationID, PointUUID,
      PointIndex, Error);
  end;
end;

procedure TFrameMainTable.CompleteSimulatedHydraulicLineSetup(AWorkTable: TWorkTable);
var
  State: EHydraulicLineState;
  Error: TErrorInfo;
  OperationID: Int64;
  PointUUID: string;
  PointIndex: Integer;
  TargetFlow: Double;
  Configuration: RWorkTableHydraulicConfiguration;
  HydraulicRange: RWorkTableHydraulicRange;
begin
  { Simulation applies the saved virtual selection without equipment commands. }
  if not IsHydraulicSimulationMode(AWorkTable) then
    Exit;
  AWorkTable.GetHydraulicStateSnapshot(State, Error, OperationID, PointUUID,
    PointIndex, TargetFlow, Configuration, HydraulicRange);
  if not AWorkTable.BeginHydraulicLineApply(OperationID, PointUUID, PointIndex,
    Configuration, HydraulicRange) then
    Exit;
  if not AWorkTable.CompleteHydraulicLineApply(OperationID, PointUUID, PointIndex) then
  begin
    Error := TErrorInfo.Empty(Integer(AWorkTable.State));
    Error.Code := 1382;
    Error.Msg := 'Не удалось завершить виртуальную установку гидравлической линии';
    Error.Time := Now;
    AWorkTable.FailHydraulicLineApply(OperationID, PointUUID, PointIndex, Error);
  end;
end;

procedure TFrameMainTable.ClearChannelSimulationValues(AChannel: TChannel);
begin
  if AChannel = nil then
    Exit;

  AChannel.ImpSec := 0;
  AChannel.CurSec := 0;
  AChannel.ValueSec := 0;
  AChannel.ImpResult := 0;
end;

procedure TFrameMainTable.DisableOtherChannelGroups(AChannels: TObjectList<TChannel>; const AActiveIndex: Integer);
var
  J: Integer;
  ActiveGroup: Integer;
  SelectedChannel: TChannel;
  OtherChannel: TChannel;
  OldEnabled: Boolean;
  WorkTableUUID: string;
begin
  if (AChannels = nil) or (AActiveIndex < 0) or (AActiveIndex >= AChannels.Count) or
     (AChannels[AActiveIndex] = nil) then
    Exit;

  SelectedChannel := AChannels[AActiveIndex];
  ActiveGroup := SelectedChannel.Group;
  if FActiveWorkTable <> nil then
    WorkTableUUID := FActiveWorkTable.UUID
  else
    WorkTableUUID := '';
  for J := 0 to AChannels.Count - 1 do
  begin
    OtherChannel := AChannels[J];
    if (J = AActiveIndex) or
       (OtherChannel = nil) or
       (OtherChannel.Group = ActiveGroup) then
      Continue;

    OldEnabled := OtherChannel.Enabled;
    if OldEnabled then
    begin
      OtherChannel.Enabled := False;
      ClearChannelSimulationValues(OtherChannel);
      MarkChannelDeviceModified(OtherChannel);
      if FActiveWorkTable <> nil then
        PersistChannelEnabled(FActiveWorkTable, OtherChannel, 'Etalon', OldEnabled, False);

      ProtocolManager.AddMessage(pcAction, psForm, 'EtalonEnabledGroupChange',
        'Отключение эталонного канала другой группы',
        Format('WorkTableUUID=%s; SelectedChannelUUID=%s; SelectedChannelName=%s; SelectedGroup=%d; AffectedChannelUUID=%s; AffectedChannelName=%s; AffectedGroup=%d; AffectedOldEnabled=%s; AffectedNewEnabled=%s; Reason=ExclusiveOtherGroupSelection',
        [WorkTableUUID,
         SelectedChannel.UUID, SelectedChannel.Name, ActiveGroup,
         OtherChannel.UUID, OtherChannel.Name, OtherChannel.Group,
         BoolToStr(OldEnabled, True), BoolToStr(OtherChannel.Enabled, True)]));
    end;
  end;
end;


procedure TFrameMainTable.ApplyEnabledChannelSimulationValues(AWorkTable: TWorkTable; const AEtalonChannels: Boolean);
var
  Flow: Double;
  ImpSecValues: TArray<Double>;
begin
  if (AWorkTable = nil) or (WorkTableManager = nil) then
    Exit;

  Flow := 0;
  if (AWorkTable.FlowRate <> nil) and (AWorkTable.FlowRate.ValueSet <> nil) and
     (AWorkTable.FlowRate.ValueSet.Value > 0) then
    Flow := AWorkTable.FlowRate.ValueSet.Value
  else if AWorkTable.EtalonFlowSet > 0 then
    Flow := AWorkTable.EtalonFlowSet;
  if Flow <= 0 then
    Exit;

  if AEtalonChannels then
  begin
    ImpSecValues := WorkTableManager.BuildImpSecValuesForChannels(AWorkTable,
      AWorkTable.EtalonChannels, Flow, 0, True, False);
    AWorkTable.ApplyChannelValues(AWorkTable.EtalonChannels, 0, ImpSecValues, 0);
  end
  else
  begin
    ImpSecValues := WorkTableManager.BuildImpSecValuesForChannels(AWorkTable,
      AWorkTable.DeviceChannels, Flow, 0, False, True);
    AWorkTable.ApplyChannelValues(AWorkTable.DeviceChannels, 0, ImpSecValues, 0);
  end;
end;
procedure TFrameMainTable.GridEtalonsDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
var
  Channel: TChannel;
  CellColor: TAlphaColor;
begin
  CellColor := TAlphaColors.Null;

  if (Column = StringColumnEtalonChanel1) and (FActiveWorkTable <> nil) and
     (Row >= 0) and (Row < FActiveWorkTable.EtalonChannels.Count) then
  begin
    Channel := FActiveWorkTable.EtalonChannels[Row];
    if Channel <> nil then
      CellColor := GetEtalonGroupColor(Channel.Group);
  end;


  if CellColor <> TAlphaColors.Null then
  begin
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := CellColor;
    Canvas.FillRect(Bounds, 0, 0, [], 1);
    Column.DefaultDrawCell(Canvas, Bounds, Row, Value, State);
  end;
end;

procedure TFrameMainTable.GridEtalonsGetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
var
  WorkTable: TWorkTable;
  FlowMeter: TFlowMeter;
  CurrentFlow: Double;
  AverageFlow: Double;
begin

  WorkTable := FActiveWorkTable;

  if (WorkTable <> nil) and (ARow >= 0) and (ARow < WorkTable.EtalonChannels.Count) then
  begin
    if GridEtalons.Columns[ACol] = CheckColumnEtalonEnable1 then
      Value := WorkTable.EtalonChannels[ARow].Enabled
    else if (not WorkTable.EtalonChannels[ARow].Enabled) and
            ((GridEtalons.Columns[ACol] = StringColumnEtalonFlowRate1) or
             (GridEtalons.Columns[ACol] = StringColumnEtalonAvgFlowRate1) or
             (GridEtalons.Columns[ACol] = StringColumnEtalonQuantity1) or
             (GridEtalons.Columns[ACol] = StringColumnEtalonRawValue1) or
             (GridEtalons.Columns[ACol] = StringColumnEtalonRawSumValue1) or
             (GridEtalons.Columns[ACol] = StringColumnEtalonStd1) or
             (GridEtalons.Columns[ACol] = StringColumnEtalonError1)) then
      Value := '0'
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
        Value := GetDisplayFlowText(WorkTable.EtalonChannels[ARow].FlowMeter, WorkTable)
      else
        Value := '-';
    end
    else if GridEtalons.Columns[ACol] = StringColumnEtalonAvgFlowRate1 then
    begin
      Value := GetAverageFlowText(WorkTable.EtalonChannels[ARow].FlowMeter, WorkTable);
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
      FlowMeter := WorkTable.EtalonChannels[ARow].FlowMeter;
      if (FlowMeter <> nil) and (FlowMeter.ValueFlow <> nil) and
         TryGetAverageFlow(FlowMeter, WorkTable, AverageFlow) then
      begin
        CurrentFlow := FlowMeter.ValueFlow.GetDoubleValue;
        Value := FormatValue(CalculateCurrentDeviationPercent(
          CurrentFlow, AverageFlow), 2, 0);
      end
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
begin
  { Повторно запрашивает значения строк без изменения их структуры. }
  RefreshGridValues(GridDevices, 'device-values');
end;

procedure TFrameMainTable.UpdateGrids;
var
  WT: TWorkTable;
  DeviceRows, EtalonRows: Integer;
begin
  { Обновляет содержимое каналов, изменяя RowCount только при смене их числа. }
  NormalizeActiveWorkTable;
  WT := FActiveWorkTable;
  DeviceRows := 0;
  EtalonRows := 0;
  if WT <> nil then
  begin
    DeviceRows := WT.DeviceChannels.Count;
    EtalonRows := WT.EtalonChannels.Count;
  end;
  if GridDevices.RowCount <> DeviceRows then
    RefreshGridRowCount(GridDevices, DeviceRows, 'channel-values');

  { Set the common representation before repainting the grid. Otherwise
    the new header becomes visible only after a later focus change. }
  UpdateDeviceCoefficientHeaders;
  RefreshGridValues(GridDevices, 'channel-values');

  if GridEtalons.RowCount <> EtalonRows then
    RefreshGridRowCount(GridEtalons, EtalonRows, 'channel-values');
  RefreshGridValues(GridEtalons, 'channel-values');
end;

procedure TFrameMainTable.GridEtalonsSetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
var
  WorkTable: TWorkTable;
  Signal: Integer;
  Changed: Boolean;
  OldEnabled: Boolean;
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
      if FUpdatingChannelEnabled then
        Exit;
      OldEnabled := WorkTable.EtalonChannels[ARow].Enabled;
      Changed := OldEnabled <> Value.AsBoolean;
      FUpdatingChannelEnabled := True;
      try
        WorkTable.EtalonChannels[ARow].Enabled := Value.AsBoolean;
        if Changed then
          PersistChannelEnabled(WorkTable, WorkTable.EtalonChannels[ARow],
            'Etalon', OldEnabled, Value.AsBoolean);
        if WorkTable.EtalonChannels[ARow].Enabled then
          begin
            DisableOtherChannelGroups(WorkTable.EtalonChannels, ARow);
            ApplyEnabledChannelSimulationValues(WorkTable, True);
          end
        else
          begin
            ClearChannelSimulationValues(WorkTable.EtalonChannels[ARow]);
            ApplyEnabledChannelSimulationValues(WorkTable, True);
          end;
      finally
        FUpdatingChannelEnabled := False;
      end;
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
    begin
      MarkChannelDeviceModified(WorkTable.EtalonChannels[ARow]);
      RefreshActiveWorkTableViews(WorkTable.EtalonChannels[ARow]);
    end;

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

procedure TFrameMainTable.ResetUIPump;
begin
  LabelFreq.Text := '-';
  Rectangle1.Fill.Color := COLOR_NONE;

  LayoutPump.Tag := 2;
  try
    SpinBoxFreq.Min := 0;
    SpinBoxFreq.Max := 0;
    SpinBoxFreq.Value := 0;
    ComboBoxPumps.ItemIndex := -1;
  finally
    LayoutPump.Tag := 0;
  end;
end;

procedure TFrameMainTable.UpdateUIPump;
var
  WorkTable: TWorkTable;
  i:integer;
begin
    NormalizeActiveWorkTable;
    WorkTable := FActiveWorkTable;

    if WorkTable = nil then
    begin
      ResetUIPump;
      Exit;
    end;

    if WorkTable.ActivePump = nil then
    begin
      ResetUIPump;
      exit;
    end;

    if WorkTable.ActivePump <> nil then
      LabelFreq.Text :=FormatFloat('0.##', WorkTable.ActivePump.Value.Value)
    else
      LabelFreq.Text := '-';

    if (WorkTable.ActivePump.Value.Value = 0) or not (WorkTable.ActivePump.IsRunning) then
       Rectangle1.Fill.Color := COLOR_NONE
    else if (WorkTable.ActivePump.Value.Value < WorkTable.ActivePump.ValueSet.Value) then
      Rectangle1.Fill.Color := COLOR_WARNING
    else if (WorkTable.ActivePump.Value.Value > WorkTable.ActivePump.ValueSet.Value * 0.999) and (WorkTable.ActivePump.Value.Value < WorkTable.ActivePump.ValueSet.Value * 1.001) then
      Rectangle1.Fill.Color := COLOR_COMPLETED;



    if LayoutPump.tag = 3 then
      exit;

    LayoutPump.tag:=2;

   // if ((SpinBoxFreq.Text='12,00') and (WorkTable.ActivePump.FreqSet <> 0)) or
    // ((SpinBoxFreq.Text <>  '12,00') and (WorkTable.ActivePump.FreqSet = 0))  then

    SpinBoxFreq.Value:= (WorkTable.ActivePump.ValueSet.Value);
    SpinBoxFreq.Min:= WorkTable.ActivePump.Min;
    SpinBoxFreq.Max:= WorkTable.ActivePump.Max;


    if ComboBoxPumps.Count <> 0 then
      for I := ComboBoxPumps.Count - 1 downto 0 do
        if (ComboBoxPumps.Items.Objects[I] is TPump) and
           (TPump(ComboBoxPumps.Items.Objects[I]) = WorkTable.ActivePump) then
        begin
          ComboBoxPumps.ItemIndex := I;
          Break;
        end;

   LayoutPump.tag:=0;



end;

procedure TFrameMainTable.UpdateUIScale;
var
  WorkTable: TWorkTable;
  UnitName: string;
  RoundedWeight: Double;
  I: Integer;
begin
  WorkTable := FActiveWorkTable;
  UnitName := NormalizeScaleUnit(ComboEditUnits.Text);


  Label3.Text := 'Масса, ' + UnitName;

  if WorkTable = nil then
  begin
    LabelScaleWeight.Text := '-';
    LabelScaleTotalWeight.Text := '-';
    Exit;
  end;

  if WorkTable.ValueQuantity <> nil then
    LabelScaleWeight.Text := WorkTable.ValueQuantity.GetStrNum(WorkTable.ActiveScale.CurrentWeight,0)
  else
    LabelScaleWeight.Text := '-';

  if (WorkTable.ActiveScale <> nil) and
     (WorkTable.TableFlow <> nil) and
     (WorkTable.TableFlow.ValueMass <> nil) then
  begin
    RoundedWeight := WorkTable.ActiveScale.TareWeight;
    LabelScaleTotalWeight.Text := WorkTable.TableFlow.ValueMass.GetStrNum(
      RoundedWeight, 0);
  end
  else
    LabelScaleTotalWeight.Text := '-';

  if LayoutScale.Tag = 3 then
    Exit;

  LayoutScale.Tag := 2;
  try
    if (WorkTable.ActiveScale <> nil) and (ComboBoxScales.Count <> 0) then
      for I := ComboBoxScales.Count - 1 downto 0 do
        if ComboBoxScales.Items[I] = WorkTable.ActiveScale.Name then
        begin
          ComboBoxScales.ItemIndex := I;
          Break;
        end;
  finally
    LayoutScale.Tag := 0;
  end;
end;

procedure TFrameMainTable.UpdateUIFlowRate;
var
  WorkTable: TWorkTable;
  StableStatus: RStableInfo;
begin
    WorkTable := FActiveWorkTable;
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
  //    WorkTable.UpdateFlowRateLimitsByEtalons;
      LayoutFlowRate.tag:=2;
      SpinBoxFlowRate.Min:= WorkTable.ValueFlowRate.GetDoubleNum(WorkTable.FlowRate.Min);
      SpinBoxFlowRate.Max:= WorkTable.ValueFlowRate.GetDoubleNum(WorkTable.FlowRate.Max,
        WorkTable.ValueFlowRate.CurrentDimIndex);
      if WorkTable.FlowRate.ValueSet.Value<>0 then
        SpinBoxFlowRate.value:=WorkTable.ValueFlowRate.GetDoubleNum(WorkTable.FlowRate.ValueSet.Value);


if WorkTable.FlowRate.IsRunning then
  begin
        if WorkTable.FlowRate.Value.Value = 0 then
           RectangleLabelFR.Fill.Color := COLOR_NONE
       ELSE if WorkTable.FlowRate.IsStable(StableStatus) THEN
          RectangleLabelFR.Fill.Color := COLOR_COMPLETED
       else if (WorkTable.FlowRate.Value <> WorkTable.FlowRate.ValueSet) then
          RectangleLabelFR.Fill.Color := COLOR_WARNING;
  end
  else
  begin

    RectangleLabelFR.Fill.Color := COLOR_NONE
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
      Rectangle7.Fill.Color := COLOR_NONE
     ELSE if WorkTable.FluidTemp.IsStable(TempStableStatus)   THEN
      Rectangle7.Fill.Color := COLOR_COMPLETED
     else
      Rectangle7.Fill.Color := COLOR_WARNING;
  end
  else
  begin

      Rectangle7.Fill.Color := COLOR_NONE

  end;

IF WorkTable.FluidPress.IsRunning THEN
  begin
   if (WorkTable.FluidPress.ValueSet.Value=0) or (WorkTable.FluidPress.Value.Value=0 )  then

    Rectangle11.Fill.Color := COLOR_NONE
   else IF not(WorkTable.FluidPress.IsStable(PressStableStatus)) then
    Rectangle11.Fill.Color := COLOR_WARNING
   else
    Rectangle11.Fill.Color := COLOR_COMPLETED;
  end
  else
  begin

    Rectangle11.Fill.Color := COLOR_NONE


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

initialization
  RegisterFmxClasses([TValueEditColumn]);

end.
