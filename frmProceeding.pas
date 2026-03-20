unit frmProceeding;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, FMX.Memo.Types, FMX.ListBox, FMX.Objects,
  FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FMX.TabControl, FMX.TreeView,
  FMX.Layouts, FMX.Memo, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox;

type
  TFrameProceeding = class(TFrame)
    LayoutMiddle: TLayout;
    LayoutCenter: TLayout;
    Layout18: TLayout;
    GridDataPoints: TGrid;
    CheckColumnSpillageEnable: TCheckColumn;
    StringColumnSpillageNum: TStringColumn;
    StringColumnName: TStringColumn;
    StringColumnSpillageDateTime: TStringColumn;
    StringColumnSpillageOperator: TStringColumn;
    StringColumnSpillageEtalonName: TStringColumn;
    StringColumnSpillageSpillTime: TStringColumn;
    StringColumnSpillageQavgEtalon: TStringColumn;
    StringColumnSpillageEtalonVolume: TStringColumn;
    StringColumnSpillageQEtalonStd: TStringColumn;
    StringColumnSpillageQEtalonCV: TStringColumn;
    StringColumnSpillageDeviceFlowRate: TStringColumn;
    StringColumnSpillageDeviceVolume: TStringColumn;
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
    StringColumnSpillageDeltaPressure: TStringColumn;
    StringColumnSpillageDensity: TStringColumn;
    StringColumnSpillageAmbientTemperature: TStringColumn;
    StringColumnSpillageAtmosphericPressure: TStringColumn;
    StringColumnSpillageRelativeHumidity: TStringColumn;
    StringColumnSpillageCoef: TStringColumn;
    StringColumnSpillageFCDCoefficient: TStringColumn;
    StringColumnSpillageArchivedData: TStringColumn;
    GridResults: TGrid;
    StringColumnResultName: TStringColumn;
    StringColumnResultType: TStringColumn;
    StringColumnResultSerial: TStringColumn;
    StringColumnPointNum1: TStringColumn;
    StringColumnPointNum2: TStringColumn;
    StringColumnPointNum3: TStringColumn;
    StringColumnPointNum4: TStringColumn;
    StringColumnResult: TStringColumn;
    MemoLog: TMemo;
    LayoutLeft: TLayout;
    TreeViewDevices: TTreeView;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    LayoutRight: TLayout;
    Panel1: TPanel;
    TabControlSessionProperties: TTabControl;
    TabItemSessionProperties: TTabItem;
    LayoutSessionProperties: TLayout;
    LabelCoefs: TLabel;
    LabelSessionDate: TLabel;
    Chart1: TChart;
    LabelSessionActive: TLabel;
    TabItemCalculations: TTabItem;
    GridCoefs: TGrid;
    StringColumnCoefTableName: TStringColumn;
    StringColumn2: TStringColumn;
    TabItemCalibrCoefs: TTabItem;
    TabItemReport: TTabItem;
    LayoutTop: TLayout;
    ToolBarDataPoints: TToolBar;
    Line4: TLine;
    Layout32: TLayout;
    ButtonSessionDeleteDataPoint: TButton;
    ButtonSessionNew: TButton;
    ButtonSessionClearPoints: TButton;
    ButtonSessionClose: TButton;
    Layout19: TLayout;
    Layout20: TLayout;
    ComboBoxUnitsResult: TComboBox;
    Line7: TLine;
    ToolBarResults: TToolBar;
    Layout22: TLayout;
    Label7: TLabel;
    Line8: TLine;
    Layout23: TLayout;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Line9: TLine;
    lyt1: TLayout;
    btnOK: TCornerButton;
    CornerButton1: TCornerButton;
    CornerButtonEditDevice: TCornerButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
