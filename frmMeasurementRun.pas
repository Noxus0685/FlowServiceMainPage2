unit frmMeasurementRun;



interface

uses
  fuDeviceSelect,
  fuTypeSelect,
  fuDeviceEdit,
  fuMeterValues,
  frmCalibrCoefs,
  frmProceed,
  frmMainTable,

  UnitParameter,
  UnitDataManager,
  UnitMeterValue,
  UnitDeviceClass,
  UnitFlowMeter,
  UnitClasses,
  UnitRepositories,
  UnitWorkTable,
  UnitBaseProcedures,
  UnitMeasurementRun,

  System.Math, System.Generics.Collections, System.SysUtils, System.Types,
  System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Filter.Effects, FMX.Colors, FMX.Effects, FMX.ListBox,
  FMX.Edit, FMX.StdCtrls, FMX.ComboEdit, FMX.EditBox, FMX.SpinBox, FMX.Objects,
  FMX.Grid, FMX.ScrollBox, FMX.Layouts, FMX.Controls.Presentation,
  FMX.TabControl, FMX.Menus, System.Actions, FMX.ActnList, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.Memo.Types,
  FMX.Memo, FMX.DateTimeCtrls, FMX.TreeView, FMX.ListView,
  System.IniFiles, FMXTee.Engine, FMXTee.Procs, FMXTee.Chart;

type
  TFrameMeasurementRun = class(TFrame)
    GridMeasurmentRun: TGrid;
    StringColumnPointer: TStringColumn;
    StringColumnMRPointName: TStringColumn;
    StringColumnMRFlowRate: TStringColumn;
    StringColumnMRStopCriterea: TStringColumn;
    StringColumnRepeats: TStringColumn;
    StringColumnMRStatus: TStringColumn;
    ToolBarGridMR: TToolBar;
    SpeedButtonPointPrev: TSpeedButton;
    SpeedButtonPointNext: TSpeedButton;
    SpeedButtonPause: TSpeedButton;
    SpeedButtonPointDelete: TSpeedButton;
    SpeedButtonCreatePoints: TSpeedButton;
    StringColumnLimitTime: TStringColumn;
    StringColumnLimitImp: TStringColumn;
    StringColumnLimitVolume: TStringColumn;
    procedure GridMeasurmentRunGetValue(Sender: TObject; const ACol,
      ARow: Integer; var Value: TValue);
  private
    { Private declarations }
    procedure UpdateGridMesurmentRun;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}





procedure TFrameMeasurementRun.GridMeasurmentRunGetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
var
  Point: TDevicePoint;
  StopParts: TStringList;

  function GetStopCriteriaText(APoint: TDevicePoint): string;
  begin
    Result := '';
    if APoint = nil then
      Exit;

    StopParts := TStringList.Create;
    try
      if scImpulse in APoint.StopCriteria then
        StopParts.Add(Format('%d θμο', [APoint.LimitImp]));
      if scVolume in APoint.StopCriteria then
        StopParts.Add(Format('%s λ', [FormatFloat('0.###', APoint.LimitVolume)]));
      if scTime in APoint.StopCriteria then
        StopParts.Add(Format('%s ρεκ', [FormatFloat('0.###', APoint.LimitTime)]));

      Result := Trim(StringReplace(StopParts.CommaText, ',', ', ', [rfReplaceAll]));
      Result := StringReplace(Result, '"', '', [rfReplaceAll]);
    finally
      StopParts.Free;
    end;
  end;
begin
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then
    Exit;

  if (ARow < 0) or (ARow >= MeasurementRun.Points.Count) then
    Exit;

  Point := MeasurementRun.Points[ARow];
  if Point = nil then
    Exit;

  if GridMeasurmentRun.Columns[ACol] = StringColumnMRPointName then
    Value := Point.Name
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRFlowRate then
  begin
    if (FActiveWorkTable.ValueFlowRate <> nil) then
      Value := FActiveWorkTable.ValueFlowRate.GetStrNum(Point.Q)
    else
      Value := FormatFloat('0.###', Point.Q);
  end
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRStopCriterea then
    Value := GetStopCriteriaText(Point)
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRStatus then
    Value := Point.GetStatus;
end;

procedure TFrameMeasurementRun.UpdateGridMesurmentRun;
var
  Rows: Integer;
begin
  if MeasurementRun <> nil then
    Rows := MeasurementRun.Points.Count
  else
    Rows := 0;

  GridMeasurmentRun.BeginUpdate;
  try
    GridMeasurmentRun.RowCount := 0;
    GridMeasurmentRun.RowCount := Rows;
  finally
    GridMeasurmentRun.EndUpdate;
  end;
end;


end.
