unit frmMeasurementRun;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDeviceClass,
  uMeasurementRun,
  uObservable,
  uWorkTable;

type
  TFrameMeasurementRun = class(TFrame, IEventObserver)
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
    procedure GridMeasurmentRunDrawColumnCell(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure SpeedButtonCreatePointsClick(Sender: TObject);
    procedure SpeedButtonPauseClick(Sender: TObject);
    procedure SpeedButtonPointDeleteClick(Sender: TObject);
    procedure SpeedButtonPointNextClick(Sender: TObject);
    procedure SpeedButtonPointPrevClick(Sender: TObject);
  private
    FActiveWorkTable: TWorkTable;
    FInvalidPointIndexes: TList<Integer>;
    function GetMeasurementRun: TMeasurementRun;
    function GetStopCriteriaText(APoint: TDevicePoint): string;


    procedure SetActiveWorkTable(const Value: TWorkTable);
    procedure AttachMeasurementRunEvents;
    procedure DetachMeasurementRunEvents;
    procedure MeasurementRunStateChanged(ASender: TObject; AState: EMeasurementState);
    procedure MeasurementRunPointChanged(ASender: TObject; APoint: TDevicePoint; APointIndex: Integer);
    procedure MeasurementRunEvent(ASender: TObject; AEvent: EMeasurementEvent; const AError: TErrorInfo);
    procedure UpdateGridMRHeaders;
    procedure UpdateStopCriteriaColumns;
    function IsPointInvalid(APoint: TDevicePoint): Boolean;
    function GetRowColor(const ARow: Integer): TAlphaColor;
     procedure UpdateGridMesurmentRun;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
    procedure UpdateUI;
    property MeasurementRun: TMeasurementRun read GetMeasurementRun;
    property ActiveWorkTable: TWorkTable read FActiveWorkTable write SetActiveWorkTable;

  end;

implementation

{$R *.fmx}

constructor TFrameMeasurementRun.Create(AOwner: TComponent);
begin
  inherited;
  FInvalidPointIndexes := TList<Integer>.Create;
  SpeedButtonPointPrev.OnClick := SpeedButtonPointPrevClick;
  SpeedButtonPointNext.OnClick := SpeedButtonPointNextClick;
  SpeedButtonPause.OnClick := SpeedButtonPauseClick;
  SpeedButtonPointDelete.OnClick := SpeedButtonPointDeleteClick;
  SpeedButtonCreatePoints.OnClick := SpeedButtonCreatePointsClick;
end;

destructor TFrameMeasurementRun.Destroy;
begin
    FreeAndNil(FInvalidPointIndexes);
    inherited;
end;

function TFrameMeasurementRun.GetMeasurementRun: TMeasurementRun;
begin
  Result := nil;
  if (FActiveWorkTable = nil) or (FActiveWorkTable.MeasurementRun = nil) then
    Exit;
  Result := TMeasurementRun(FActiveWorkTable.MeasurementRun);
end;

procedure TFrameMeasurementRun.SetActiveWorkTable(const Value: TWorkTable);
begin
  if FActiveWorkTable = Value then
    Exit;

  DetachMeasurementRunEvents;
  FActiveWorkTable := Value;
  FInvalidPointIndexes.Clear;
  AttachMeasurementRunEvents;
  UpdateGridMRHeaders;
  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.AttachMeasurementRunEvents;
begin
  if MeasurementRun = nil then
    Exit;

  MeasurementRun.Subscribe(Self);
end;

procedure TFrameMeasurementRun.DetachMeasurementRunEvents;
begin
  if MeasurementRun = nil then
    Exit;
  MeasurementRun.Unsubscribe(Self);
end;

procedure TFrameMeasurementRun.OnNotify(Sender: TObject; Event: Integer; Data: TObject);
var
  LRun: TMeasurementRun;
  LIdx: Integer;
begin
  if not (Sender is TMeasurementRun) then
    Exit;

  LRun := TMeasurementRun(Sender);

  if Event = Integer(meStateChanged) then
  begin
    MeasurementRunStateChanged(Sender, LRun.Stage);
    Exit;
  end;

  if Event = Integer(mePointChanged) then
  begin
    MeasurementRunPointChanged(Sender, TDevicePoint(Data), LRun.CurrentPointIndex);
    Exit;
  end;

  if Event = Integer(mePointInvalid) then
  begin
    LIdx := LRun.CurrentPointIndex;
    if (LIdx >= 0) and (FInvalidPointIndexes.IndexOf(LIdx) < 0) then
      FInvalidPointIndexes.Add(LIdx);
  end;

  MeasurementRunEvent(Sender, EMeasurementEvent(Event), TErrorInfo.Empty(Integer(LRun.Stage)));
end;

procedure TFrameMeasurementRun.MeasurementRunStateChanged(ASender: TObject;
  AState: EMeasurementState);
begin
  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.MeasurementRunPointChanged(ASender: TObject;
  APoint: TDevicePoint; APointIndex: Integer);
begin
  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.MeasurementRunEvent(ASender: TObject;
  AEvent: EMeasurementEvent; const AError: TErrorInfo);
var
  LIdx: Integer;
begin
  if AEvent = mePointInvalid then
  begin
    LIdx := MeasurementRun.CurrentPointIndex;
    if (LIdx >= 0) and (FInvalidPointIndexes.IndexOf(LIdx) < 0) then
      FInvalidPointIndexes.Add(LIdx);
  end;

  UpdateGridMesurmentRun;
end;

function TFrameMeasurementRun.IsPointInvalid(APoint: TDevicePoint): Boolean;
begin
  Result := True;
  if (APoint = nil) or (FActiveWorkTable = nil) then
    Exit;

  Result := (APoint.Q > 0) and ((APoint.Q < FActiveWorkTable.FlowRate.Min) or (APoint.Q > FActiveWorkTable.FlowRate.Max));
  if Result then
    Exit;

  Result := (APoint.Temp > 0) and ((APoint.Temp < FActiveWorkTable.FluidTemp.Min) or (APoint.Temp > FActiveWorkTable.FluidTemp.Max));
  if Result then
    Exit;

  Result := (APoint.Pressure > 0) and ((APoint.Pressure < FActiveWorkTable.FluidPress.Min) or (APoint.Pressure > FActiveWorkTable.FluidPress.Max));
end;

function TFrameMeasurementRun.GetRowColor(const ARow: Integer): TAlphaColor;
var
  LPoint: TDevicePoint;
  LIsInvalid: Boolean;
  LIsRunning: Boolean;
  LIsCompleted: Boolean;

begin
  Result := TAlphaColors.Null;

  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) or
     (ARow < 0) or (ARow >= MeasurementRun.Points.Count) then
    Exit;

  LPoint := MeasurementRun.Points[ARow];

  LIsInvalid := (FInvalidPointIndexes.IndexOf(ARow) >= 0) or IsPointInvalid(LPoint);
  if LIsInvalid then
    Exit(COLOR_INVALID);

  LIsRunning := (MeasurementRun.CurrentPointIndex = ARow) and
                (MeasurementRun.Stage <> msNone) and
                (MeasurementRun.Stage <> msDone);
  if LIsRunning then
    Exit(COLOR_RUNNING);

  LIsCompleted := (LPoint <> nil) and (LPoint.RepeatsCompleted >= Max(LPoint.Repeats, 1));
  if LIsCompleted then
    Exit(COLOR_COMPLETED);
end;

procedure TFrameMeasurementRun.GridMeasurmentRunDrawColumnCell(
  Sender: TObject; const Canvas: TCanvas; const Column: TColumn;
  const Bounds: TRectF; const Row: Integer; const Value: TValue;
  const State: TGridDrawStates);
var
  C: TAlphaColor;
  SavedState: TCanvasSaveState;
begin
  SavedState := Canvas.SaveState;

  if Row<0 then
  Exit;

  try
    C := GetRowColor(Row);

    if C <> TAlphaColors.Null then
    begin
      Canvas.Fill.Kind := TBrushKind.Solid;
      Canvas.Fill.Color := C;
      Canvas.FillRect(Bounds, 0, 0, [], 1);
    end;

    Column.DefaultDrawCell(Canvas, Bounds, Row, Value, State);
  finally
    Canvas.RestoreState(SavedState);
  end;
end;


function TFrameMeasurementRun.GetStopCriteriaText(APoint: TDevicePoint): string;
var
  Parts: array of string;
begin
  Result := '';
  if APoint = nil then
    Exit;

  SetLength(Parts, 0);

  if scImpulse in APoint.StopCriteria then
    Parts := Parts + [Format('%d имп', [APoint.LimitImp])];

  if scVolume in APoint.StopCriteria then
    Parts := Parts + [FormatFloat('0.###', APoint.LimitVolume) + ' л'];

  if scTime in APoint.StopCriteria then
    Parts := Parts + [FormatFloat('0.###', APoint.LimitTime) + ' сек'];

  Result := string.Join(', ', Parts);
end;

procedure TFrameMeasurementRun.GridMeasurmentRunGetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
var
  Point: TDevicePoint;
  RepeatsTarget: Integer;
  RepeatsNow: Integer;
begin
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then
    Exit;

  if (ARow < 0) or (ARow >= MeasurementRun.Points.Count) then
    Exit;

  Point := MeasurementRun.Points[ARow];
  if Point = nil then
    Exit;

  if GridMeasurmentRun.Columns[ACol] = StringColumnPointer then
  begin
    if MeasurementRun.CurrentPointIndex = ARow then
      Value := '▶'
    else
      Value := '';
  end
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRPointName then
    Value := Point.Name
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRFlowRate then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
      Value := FActiveWorkTable.ValueFlowRate.GetStrNumLimits(Point.Q)
    else
      Value := FormatFloat('0.###', Point.Q);
  end
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRStopCriterea then
    Value := GetStopCriteriaText(Point)
  else if GridMeasurmentRun.Columns[ACol] = StringColumnLimitTime then
    if scTime in Point.StopCriteria then
      Value := FormatFloat('0.###', Point.LimitTime)
    else
      Value := '-'
  else if GridMeasurmentRun.Columns[ACol] = StringColumnLimitVolume then
    if scVolume in Point.StopCriteria then
      Value := FormatFloat('0.###', Point.LimitVolume)
    else
      Value := '-'
  else if GridMeasurmentRun.Columns[ACol] = StringColumnLimitImp then
    if scImpulse in Point.StopCriteria then
      Value := IntToStr(Point.LimitImp)
    else
      Value := '-'
  else if GridMeasurmentRun.Columns[ACol] = StringColumnRepeats then
  begin
    RepeatsTarget := Max(Point.Repeats, 1);
    RepeatsNow := Point.RepeatsCompleted;

    if (MeasurementRun.CurrentPointIndex = ARow) and
       (MeasurementRun.Stage <> msNone) and
       (MeasurementRun.Stage <> msDone) then
      RepeatsNow := Min(RepeatsTarget, Max(RepeatsNow, MeasurementRun.CurrentRepeat + 1));

    Value := Format('%d/%d', [RepeatsNow, RepeatsTarget]);
  end
  else if GridMeasurmentRun.Columns[ACol] = StringColumnMRStatus then
    Value := Point.GetStatus;
end;

procedure TFrameMeasurementRun.UpdateUI;
begin
     UpdateGridMRHeaders;
     UpdateGridMesurmentRun;
end;


procedure TFrameMeasurementRun.UpdateGridMRHeaders;
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
    StringColumnMRFlowRate.Header := 'Расход, ' + FActiveWorkTable.ValueFlowRate.GetDimName
  else
    StringColumnMRFlowRate.Header := 'Расход';
end;

procedure TFrameMeasurementRun.UpdateStopCriteriaColumns;
var
  I: Integer;
  P: TDevicePoint;
  HasTime, HasVolume, HasImpulse: Boolean;
begin
  HasTime := False;
  HasVolume := False;
  HasImpulse := False;

  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then
    for I := 0 to MeasurementRun.Points.Count - 1 do
    begin
      P := MeasurementRun.Points[I];
      if P = nil then
        Continue;
      HasTime := HasTime or (scTime in P.StopCriteria);
      HasVolume := HasVolume or (scVolume in P.StopCriteria);
      HasImpulse := HasImpulse or (scImpulse in P.StopCriteria);
    end;

  StringColumnLimitTime.Visible := HasTime;
  StringColumnLimitVolume.Visible := HasVolume;
  StringColumnLimitImp.Visible := HasImpulse;
end;

procedure TFrameMeasurementRun.UpdateGridMesurmentRun;
var
  Rows: Integer;
begin
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then
    Rows := MeasurementRun.Points.Count
  else
    Rows := 0;

  UpdateStopCriteriaColumns;

  GridMeasurmentRun.BeginUpdate;
  try
    GridMeasurmentRun.RowCount := 0;
    GridMeasurmentRun.RowCount := Rows;
  finally
    GridMeasurmentRun.EndUpdate;
  end;

  GridMeasurmentRun.Repaint;
end;



procedure TFrameMeasurementRun.SpeedButtonPointPrevClick(Sender: TObject);
begin
  if MeasurementRun <> nil then
    MeasurementRun.Execute(mcPreviousPoint, Unassigned);
end;

procedure TFrameMeasurementRun.SpeedButtonPointNextClick(Sender: TObject);
begin
  if MeasurementRun <> nil then
    MeasurementRun.Execute(mcNextPoint, Null);
end;

procedure TFrameMeasurementRun.SpeedButtonPauseClick(Sender: TObject);
begin
  if MeasurementRun = nil then
    Exit;
  MeasurementRun.Execute(mcPause, Null);
end;

procedure TFrameMeasurementRun.SpeedButtonPointDeleteClick(Sender: TObject);
var
  Row: Integer;
begin
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then
    Exit;

  Row := GridMeasurmentRun.Selected;
  if (Row < 0) or (Row >= MeasurementRun.Points.Count) then
    Exit;

  MeasurementRun.Points.Delete(Row);
  if MeasurementRun.CurrentPointIndex = Row then
    MeasurementRun.Execute(mcPreviousPoint, Null);

  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.SpeedButtonCreatePointsClick(Sender: TObject);
begin
  if MeasurementRun = nil then
    Exit;

  MeasurementRun.CreateSession;
  FInvalidPointIndexes.Clear;
  UpdateGridMesurmentRun;
end;


end.
