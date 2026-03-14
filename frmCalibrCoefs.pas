unit frmCalibrCoefs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, FMX.Layouts, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Grid, FMX.ListBox, FMXTee.Engine, FMXTee.Procs,
  FMXTee.Chart;

type
  TFrameCalibrCoefs = class(TFrame)
    GridCoefs: TGrid;
    Layout1: TLayout;
    ToolBar1: TToolBar;
    SpeedButtonCoefsClear: TSpeedButton;
    SpeedButtonCoefDelete: TSpeedButton;
    SpeedButtonCefAdd: TSpeedButton;
    SpeedButtonCoefsRefresh: TSpeedButton;
    CheckColumnCoefEnable: TCheckColumn;
    StringColumnCoefValue: TStringColumn;
    StringColumnCoefArg: TStringColumn;
    StringColumnCoefInitError: TStringColumn;
    StringColumnCoefCalcError: TStringColumn;
    StringColumnCoefK: TStringColumn;
    StringColumnCoefb: TStringColumn;
    StringColumnCoefFrom: TStringColumn;
    StringColumnCoefTo: TStringColumn;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    Chart1: TChart;
    ComboBox1: TComboBox;
    LabelCoefTable: TLabel;
    ComboBoxCoefTables: TComboBox;
    StringColumnCoefNum: TStringColumn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
