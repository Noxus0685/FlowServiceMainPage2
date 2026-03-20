unit frmMainTable;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, FMX.Effects, FMX.Menus, FMX.Grid, FMX.ScrollBox,
  FMX.TabControl, FMX.ComboEdit, FMX.Objects, FMX.ListBox, FMX.EditBox,
  FMX.SpinBox, FMX.Edit, FMX.Layouts, FMX.Controls.Presentation;

type
  TFrameMainTable = class(TFrame)
    Layout2: TLayout;
    PanelInstruments: TPanel;
    HorzScrollBoxInstrumental: THorzScrollBox;
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
    SpeedButtonMinimizeConditions: TSpeedButton;
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
    SpeedButtonMinimzeLayoutFlowRate: TSpeedButton;
    LayoutMain: TLayout;
    Line6: TLine;
    Layout16: TLayout;
    LayoutTaskMain: TLayout;
    ComboBoxTaskMain: TComboBox;
    SpeedButtonSpillageStart: TSpeedButton;
    SpeedButtonSpillageStop: TSpeedButton;
    Rectangle13: TRectangle;
    SpeedButtonTest: TSpeedButton;
    Circle1: TCircle;
    LabelLayoutMain: TLabel;
    SpeedButtonMinimizeLayoutMain: TSpeedButton;
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
    SpeedButtonMinimizeMesure: TSpeedButton;
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
    SpeedButtonMinimizePumpLayout: TSpeedButton;
    TabControlWorkTables: TTabControl;
    TabItemWorkTable1: TTabItem;
    Panel2: TPanel;
    Layout1: TLayout;
    GridEtalons: TGrid;
    CheckColumnEtalonEnable1: TCheckColumn;
    StringColumnEtalonChanel1: TStringColumn;
    StringColumnEtalonType1: TStringColumn;
    StringColumnEtalonName1: TStringColumn;
    StringColumnEtalonSerial1: TStringColumn;
    PopupColumnEtalonSignal1: TPopupColumn;
    StringColumnEtalonRawValue1: TStringColumn;
    StringColumnEtalonFlowRate1: TStringColumn;
    StringColumnEtalonQuantity1: TStringColumn;
    StringColumnEtalonError1: TStringColumn;
    StringColumnEtalonStd1: TStringColumn;
    StringColumnEtalonPressureDelta1: TStringColumn;
    StringColumnEtalonOptions1: TStringColumn;
    StringColumnEtalonRawSumValue1: TStringColumn;
    ToolBar2: TToolBar;
    Label30: TLabel;
    Panel3: TPanel;
    GridDevices: TGrid;
    CheckColumnDeviceEnable1: TCheckColumn;
    StringColumnDeviceChanel1: TStringColumn;
    ColumnDeviceType1: TColumn;
    StringColumnDeviceName1: TStringColumn;
    StringColumnDeviceSerial1: TStringColumn;
    PopupColumnDeviceSignal1: TPopupColumn;
    StringColumnDeviceRawValue1: TStringColumn;
    StringColumnDeviceFlowRate1: TStringColumn;
    StringColumnDeviceQuantity1: TStringColumn;
    StringColumnDeviceError1: TStringColumn;
    StringColumnDeviceStd1: TStringColumn;
    StringColumnDeviceQuantityBefore1: TStringColumn;
    StringColumnDeviceQuantityAfter1: TStringColumn;
    StringColumnDevicePressureDelta1: TStringColumn;
    StringColumnDeviceOptions1: TStringColumn;
    StringColumnDeviceRawSumValue1: TStringColumn;
    ToolBar1: TToolBar;
    Label23: TLabel;
    PopupMenuDevicesGridLayOut: TPopupMenu;
    Splitter1: TSplitter;
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
    TestButton: TButton;
    GlowMesGreen: TGlowEffect;
    GlowMesRed: TGlowEffect;
    GlowMesYellow: TGlowEffect;
    Switch1: TSwitch;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
