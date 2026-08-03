unit frmMeasurementRun;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.Generics.Collections,
  System.IniFiles,
  System.IOUtils,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDeviceClass,
  uDataManager,
  uMeasurementRun,
  uObservable,
  uProtocols,
  uRepositories,
  uWorkTable;

type
  TPointsGridState = record
    PointUUID: string;
    Point: TDevicePoint;
    Row: Integer;
    ScrollY: Single;
    HadFocus: Boolean;
  end;

  TFrameMeasurementRun = class(TFrame, IEventObserver)
    GridMeasurmentRun: TGrid;
    CheckColumnMREnable: TCheckColumn;
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
    SpeedButtonPointMoveUp: TSpeedButton;
    SpeedButtonPointMoveDown: TSpeedButton;
    CheckBoxMergePoints: TCheckBox;
    LinePointControlsSeparator: TLine;
    StringColumnLimitTime: TStringColumn;
    StringColumnLimitImp: TStringColumn;
    StringColumnLimitVolume: TStringColumn;
    procedure GridMeasurmentRunGetValue(Sender: TObject; const ACol,
      ARow: Integer; var Value: TValue);
    procedure GridMeasurmentRunDrawColumnCell(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure GridMeasurmentRunSetValue(Sender: TObject; const ACol,
      ARow: Integer; const Value: TValue);
    procedure GridMeasurmentRunCellClick(const Column: TColumn; const Row: Integer);
    procedure GridMeasurmentRunHeaderClick(Column: TColumn);
    procedure SpeedButtonCreatePointsClick(Sender: TObject);
    procedure SpeedButtonPauseClick(Sender: TObject);
    procedure SpeedButtonPointDeleteClick(Sender: TObject);
    procedure SpeedButtonPointNextClick(Sender: TObject);
    procedure SpeedButtonPointPrevClick(Sender: TObject);
    procedure SpeedButtonPointMoveUpClick(Sender: TObject);
    procedure SpeedButtonPointMoveDownClick(Sender: TObject);
    procedure CheckBoxMergePointsChange(Sender: TObject);
  private
    FActiveWorkTable: TWorkTable;
    FInvalidPointIndexes: TList<Integer>;
    FPointFlowSortDirection: Integer;
    FCurrentPointUUID: string;
    FCurrentPoint: TDevicePoint;
    FLastIndicatorUUID: string;
    function GetMeasurementRun: TMeasurementRun;
    function GetStopCriteriaText(APoint: TDevicePoint): string;


    procedure SetActiveWorkTable(const Value: TWorkTable);
    procedure AttachMeasurementRunEvents;
    procedure DetachMeasurementRunEvents;
    procedure MeasurementRunStateChanged(ASender: TObject; AState: EMeasurementState);
    procedure MeasurementRunPointChanged(ASender: TObject; APoint: TDevicePoint; APointIndex: Integer);
    procedure MeasurementRunEvent(ASender: TObject; AEvent: EMeasurementEvent; const AError: TErrorInfo);
    procedure SetPointEnabledFromGrid(APoint: TDevicePoint; const AEnabled: Boolean);
    procedure UpdateGridMRHeaders;
    procedure UpdateStopCriteriaColumns;
    procedure UpdatePointOrderControls;
    procedure UpdateMeasurementControls;
    procedure UpdateCurrentPointIndicator;
    function CapturePointsGridState: TPointsGridState;
    procedure RestorePointsGridSelectionAndFocus(const AState: TPointsGridState;
      const AFallbackRow: Integer; const AReturnFocus: Boolean; const AReason: string);
    function ResolvePointRow(const AUUID: string; APoint: TDevicePoint;
      const AFallbackRow: Integer): Integer;
    procedure LoadMergePointsSetting;
    procedure SaveMergePointsSetting;
    function IsPointInvalid(APoint: TDevicePoint): Boolean;
    function GetRowColor(const ARow: Integer): TAlphaColor;
     procedure UpdateGridMesurmentRun;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
    procedure UpdateUI;
    procedure RefreshFromMeasurementRun;
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
  SpeedButtonPointMoveUp.OnClick := SpeedButtonPointMoveUpClick;
  SpeedButtonPointMoveDown.OnClick := SpeedButtonPointMoveDownClick;
  CheckBoxMergePoints.OnChange := CheckBoxMergePointsChange;
  SpeedButtonCreatePoints.OnClick := SpeedButtonCreatePointsClick;
  GridMeasurmentRun.ShowHint := True;
  GridMeasurmentRun.OnCellClick := GridMeasurmentRunCellClick;
  FPointFlowSortDirection := 0;
  LoadMergePointsSetting;
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
  if MeasurementRun <> nil then
  begin
    MeasurementRun.MergePoints := CheckBoxMergePoints.IsChecked;
    FCurrentPoint := MeasurementRun.CurrentPoint;
    if FCurrentPoint <> nil then FCurrentPointUUID := FCurrentPoint.UUID
    else FCurrentPointUUID := '';
  end;
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
  if (MeasurementRun <> nil) and (MeasurementRun.CurrentPoint <> nil) then
  begin
    FCurrentPoint := MeasurementRun.CurrentPoint;
    FCurrentPointUUID := FCurrentPoint.UUID;
  end
  else if AState in [msNone, msDone] then
  begin
    FCurrentPoint := nil;
    FCurrentPointUUID := '';
  end;
  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.MeasurementRunPointChanged(ASender: TObject;
  APoint: TDevicePoint; APointIndex: Integer);
begin
  FCurrentPoint := APoint;
  if APoint <> nil then
  begin
    FCurrentPointUUID := APoint.UUID;
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementCurrentPointResolved', 'Определена текущая точка',
      'ResolveKind=Object; PointUUID=' + FCurrentPointUUID + '; PointIndex=' + IntToStr(APointIndex));
  end else
  begin
    FCurrentPointUUID := '';
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementCurrentPointResolved', 'Текущая точка не найдена',
      'ResolveKind=NotFound; PointUUID=; PointIndex=-1');
  end;
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
begin
  Result := TAlphaColors.Null;

  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) or
     (ARow < 0) or (ARow >= MeasurementRun.Points.Count) then
    Exit;

  LPoint := MeasurementRun.Points[ARow];
  if LPoint = nil then
    Exit;

  Result := LPoint.GetStatusColor;
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
    C := TAlphaColors.Null;
    if Column = StringColumnMRStatus then
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

  if GridMeasurmentRun.Columns[ACol] = CheckColumnMREnable then
  begin
    Value := Point.Enabled;
    Exit;
  end;

  if GridMeasurmentRun.Columns[ACol] = StringColumnPointer then
  begin
    if ResolvePointRow(FCurrentPointUUID, FCurrentPoint, -1) = ARow then Value := '▶' else Value := '';
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


procedure TFrameMeasurementRun.SetPointEnabledFromGrid(APoint: TDevicePoint;
  const AEnabled: Boolean);
begin
  if APoint = nil then
    Exit;

  if APoint.Enabled = AEnabled then
    Exit;

  APoint.Enabled := AEnabled;
  if APoint.State = osClean then
    APoint.State := osModified;

  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.GridMeasurmentRunCellClick(const Column: TColumn;
  const Row: Integer);
var
  Point: TDevicePoint;
begin
  UpdatePointOrderControls;
  if Column <> CheckColumnMREnable then
    Exit;

  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then
    Exit;

  if (Row < 0) or (Row >= MeasurementRun.Points.Count) then
    Exit;

  Point := MeasurementRun.Points[Row];
  if Point = nil then
    Exit;

  SetPointEnabledFromGrid(Point, not Point.Enabled);
end;

procedure TFrameMeasurementRun.GridMeasurmentRunHeaderClick(Column: TColumn);
var
  I: Integer;
  HasEnabled: Boolean;
  NewEnabled: Boolean;
  Point: TDevicePoint;
  SelectedPoint: TDevicePoint;
begin
  if (MeasurementRun = nil) or
     (MeasurementRun.Points = nil) or (MeasurementRun.Points.Count = 0) then
    Exit;

  if Column = StringColumnMRFlowRate then
  begin
    if not (MeasurementRun.Stage in [msNone, msDone]) then
      Exit;
    SelectedPoint := nil;
    if (GridMeasurmentRun.Selected >= 0) and
       (GridMeasurmentRun.Selected < MeasurementRun.Points.Count) then
      SelectedPoint := MeasurementRun.Points[GridMeasurmentRun.Selected];
    if FPointFlowSortDirection <> 1 then
    begin
      MeasurementRun.SortPointsByFlow(False);
      FPointFlowSortDirection := 1;
    end
    else
    begin
      MeasurementRun.SortPointsByFlow(True);
      FPointFlowSortDirection := -1;
    end;
    if SelectedPoint <> nil then
      GridMeasurmentRun.Selected := MeasurementRun.Points.IndexOf(SelectedPoint);
    UpdateGridMesurmentRun;
    Exit;
  end;

  if Column <> CheckColumnMREnable then
    Exit;

  HasEnabled := False;
  for I := 0 to MeasurementRun.Points.Count - 1 do
    if (MeasurementRun.Points[I] <> nil) and MeasurementRun.Points[I].Enabled then
    begin
      HasEnabled := True;
      Break;
    end;

  NewEnabled := not HasEnabled;
  GridMeasurmentRun.BeginUpdate;
  try
    for I := 0 to MeasurementRun.Points.Count - 1 do
    begin
      Point := MeasurementRun.Points[I];
      if Point <> nil then
      begin
        Point.Enabled := NewEnabled;
        if Point.State = osClean then
          Point.State := osModified;
      end;
    end;
  finally
    GridMeasurmentRun.EndUpdate;
  end;
  UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.GridMeasurmentRunSetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
var
  Point: TDevicePoint;
begin
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then
    Exit;

  if (ARow < 0) or (ARow >= MeasurementRun.Points.Count) then
    Exit;

  if GridMeasurmentRun.Columns[ACol] <> CheckColumnMREnable then
    Exit;

  Point := MeasurementRun.Points[ARow];
  SetPointEnabledFromGrid(Point, Value.AsBoolean);
end;

procedure TFrameMeasurementRun.UpdateUI;
begin
     UpdateGridMRHeaders;
     UpdateGridMesurmentRun;
end;

procedure TFrameMeasurementRun.RefreshFromMeasurementRun;
begin
  FPointFlowSortDirection := 0;
  UpdateUI;
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
  SelectedRow: Integer;
begin
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then
    Rows := MeasurementRun.Points.Count
  else
    Rows := 0;

  SelectedRow := GridMeasurmentRun.Selected;
  UpdateStopCriteriaColumns;

  GridMeasurmentRun.BeginUpdate;
  try
    GridMeasurmentRun.RowCount := 0;
    GridMeasurmentRun.RowCount := Rows;
  finally
    GridMeasurmentRun.EndUpdate;
  end;

  if Rows = 0 then
    GridMeasurmentRun.Selected := -1
  else if SelectedRow >= Rows then
    GridMeasurmentRun.Selected := Rows - 1
  else if SelectedRow >= 0 then
    GridMeasurmentRun.Selected := SelectedRow;

  GridMeasurmentRun.Repaint;
  UpdateCurrentPointIndicator;
  UpdatePointOrderControls;
  UpdateMeasurementControls;
end;

procedure TFrameMeasurementRun.UpdatePointOrderControls;
var
  Row, Count: Integer;
  CanEditOrder: Boolean;
begin
  Row := GridMeasurmentRun.Selected;
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then Count := MeasurementRun.Points.Count else Count := 0;
  CanEditOrder := (MeasurementRun <> nil) and (MeasurementRun.Stage in [msNone, msDone]);
  SpeedButtonPointMoveUp.Enabled := CanEditOrder and (Row > 0) and (Row < Count);
  SpeedButtonPointMoveDown.Enabled := CanEditOrder and (Row >= 0) and (Row < Count - 1);
  SpeedButtonPointDelete.Enabled := CanEditOrder and (Row >= 0) and (Row < Count);
end;

procedure TFrameMeasurementRun.UpdateMeasurementControls;
begin
  if MeasurementRun = nil then
  begin
    SpeedButtonPointPrev.Enabled := False; SpeedButtonPointNext.Enabled := False;
    SpeedButtonPause.Enabled := False; Exit;
  end;
  SpeedButtonPointPrev.Enabled := (MeasurementRun.CurrentPointIndex > 0) and
    not (MeasurementRun.Stage in [msNone, msDone]);
  SpeedButtonPointNext.Enabled := (MeasurementRun.Points <> nil) and
    (MeasurementRun.CurrentPointIndex >= 0) and
    (MeasurementRun.CurrentPointIndex < MeasurementRun.Points.Count - 1) and
    not (MeasurementRun.Stage in [msNone, msDone]);
  SpeedButtonPause.Enabled := not (MeasurementRun.Stage in [msNone, msDone]);
  if MeasurementRun.IsPaused then SpeedButtonPause.StyleLookup := 'playtoolbuttonbordered'
  else SpeedButtonPause.StyleLookup := 'pausetoolbuttonbordered';
end;

function TFrameMeasurementRun.ResolvePointRow(const AUUID: string; APoint: TDevicePoint;
  const AFallbackRow: Integer): Integer;
var I: Integer;
begin
  Result := -1;
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then Exit;
  if AUUID <> '' then for I := 0 to MeasurementRun.Points.Count - 1 do
    if SameText(MeasurementRun.Points[I].UUID, AUUID) then Exit(I);
  if APoint <> nil then for I := 0 to MeasurementRun.Points.Count - 1 do
    if MeasurementRun.Points[I] = APoint then Exit(I);
  if (AFallbackRow >= 0) and (AFallbackRow < MeasurementRun.Points.Count) then Result := AFallbackRow;
end;

function TFrameMeasurementRun.CapturePointsGridState: TPointsGridState;
begin
  Result.PointUUID := ''; Result.Point := nil; Result.Row := GridMeasurmentRun.Selected;
  Result.ScrollY := GridMeasurmentRun.ViewportPosition.Y;
  Result.HadFocus := GridMeasurmentRun.IsFocused;
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) and
     (Result.Row >= 0) and (Result.Row < MeasurementRun.Points.Count) then
  begin Result.Point := MeasurementRun.Points[Result.Row]; Result.PointUUID := Result.Point.UUID; end;
end;

procedure TFrameMeasurementRun.RestorePointsGridSelectionAndFocus(const AState: TPointsGridState;
  const AFallbackRow: Integer; const AReturnFocus: Boolean; const AReason: string);
var Row: Integer; ScrollRestored, FocusRestored: Boolean;
begin
  Row := ResolvePointRow(AState.PointUUID, AState.Point, AFallbackRow);
  GridMeasurmentRun.Selected := Row;
  GridMeasurmentRun.ViewportPosition := PointF(GridMeasurmentRun.ViewportPosition.X, AState.ScrollY);
  ScrollRestored := True; FocusRestored := False;
  if AReturnFocus or AState.HadFocus then
    TThread.Queue(nil, procedure begin if GridMeasurmentRun.CanFocus then begin GridMeasurmentRun.SetFocus; GridMeasurmentRun.ScrollToSelectedCell; end; end);
  FocusRestored := AReturnFocus or AState.HadFocus;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointsGridFocusRestored',
    'Восстановлено состояние таблицы точек', Format('Reason=%s; PointUUID=%s; ResolvedRow=%d; ScrollRestored=%s; FocusRestored=%s',
    [AReason, AState.PointUUID, Row, BoolToStr(ScrollRestored, True), BoolToStr(FocusRestored, True)]));
end;

procedure TFrameMeasurementRun.UpdateCurrentPointIndicator;
var UUID: string;
begin
  UUID := FCurrentPointUUID;
  if UUID = FLastIndicatorUUID then Exit;
  FLastIndicatorUUID := UUID;
  if UUID = '' then ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementCurrentPointIndicatorCleared', 'Индикатор текущей точки очищен', '')
  else ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementCurrentPointIndicatorUpdated', 'Индикатор текущей точки обновлён', 'PointUUID=' + UUID);
end;

procedure TFrameMeasurementRun.SpeedButtonPointPrevClick(Sender: TObject);
var Run: TMeasurementRun; UUID: string; StageValue, PointIndex: Integer;
begin
  Run := MeasurementRun; UUID := ''; StageValue := -1; PointIndex := -1;
  if Run <> nil then begin StageValue := Ord(Run.Stage); PointIndex := Run.CurrentPointIndex;
    if Run.CurrentPoint <> nil then UUID := Run.CurrentPoint.UUID; end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested', 'Запрошена команда интерфейса измерения',
    Format('Command=PreviousPoint; AutoMode=%s; RunAssigned=%s; Stage=%d; CurrentPointIndex=%d; CurrentPointUUID=%s',
      [BoolToStr((Run <> nil) and (Run.Mode = mrmAutomatic), True), BoolToStr(Run <> nil, True),
       StageValue, PointIndex, UUID]));
  if (Run = nil) or (Run.CurrentPointIndex <= 0) or (Run.Stage in [msNone, msDone]) then
  begin ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRejected', 'Команда интерфейса измерения отклонена', 'Command=PreviousPoint; Reason=Unavailable'); Exit; end;
  Run.Execute(mcPreviousPoint, Unassigned);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent', 'Команда интерфейса измерения передана', 'Command=PreviousPoint');
  UpdateUI;
end;

procedure TFrameMeasurementRun.SpeedButtonPointNextClick(Sender: TObject);
var Run: TMeasurementRun; UUID: string; StageValue, PointIndex: Integer;
begin
  Run := MeasurementRun; UUID := ''; StageValue := -1; PointIndex := -1;
  if Run <> nil then begin StageValue := Ord(Run.Stage); PointIndex := Run.CurrentPointIndex;
    if Run.CurrentPoint <> nil then UUID := Run.CurrentPoint.UUID; end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested', 'Запрошена команда интерфейса измерения',
    Format('Command=NextPoint; AutoMode=%s; RunAssigned=%s; Stage=%d; CurrentPointIndex=%d; CurrentPointUUID=%s',
      [BoolToStr((Run <> nil) and (Run.Mode = mrmAutomatic), True), BoolToStr(Run <> nil, True),
       StageValue, PointIndex, UUID]));
  if (Run = nil) or (Run.Points = nil) or (Run.CurrentPointIndex < 0) or
     (Run.CurrentPointIndex >= Run.Points.Count - 1) or (Run.Stage in [msNone, msDone]) then
  begin ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRejected', 'Команда интерфейса измерения отклонена', 'Command=NextPoint; Reason=Unavailable'); Exit; end;
  Run.Execute(mcNextPoint, Null);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent', 'Команда интерфейса измерения передана', 'Command=NextPoint');
  UpdateUI;
end;

procedure TFrameMeasurementRun.SpeedButtonPointMoveUpClick(Sender: TObject);
var State: TPointsGridState; Row: Integer;
begin
  State := CapturePointsGridState; Row := State.Row;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoveRequested', 'Запрошено перемещение точки', Format('Direction=Up; OldIndex=%d', [Row]));
  if (MeasurementRun <> nil) and MeasurementRun.MovePointUp(Row) then begin
    FPointFlowSortDirection := 0; UpdateGridMesurmentRun;
    RestorePointsGridSelectionAndFocus(State, Row - 1, True, 'MoveUp');
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoved', 'Точка перемещена', Format('OldIndex=%d; NewIndex=%d', [Row, Row-1]));
  end else ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoveRejected', 'Перемещение точки отклонено', Format('Direction=Up; Index=%d', [Row]));
end;

procedure TFrameMeasurementRun.SpeedButtonPointMoveDownClick(Sender: TObject);
var State: TPointsGridState; Row: Integer;
begin
  State := CapturePointsGridState; Row := State.Row;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoveRequested', 'Запрошено перемещение точки', Format('Direction=Down; OldIndex=%d', [Row]));
  if (MeasurementRun <> nil) and MeasurementRun.MovePointDown(Row) then begin
    FPointFlowSortDirection := 0; UpdateGridMesurmentRun;
    RestorePointsGridSelectionAndFocus(State, Row + 1, True, 'MoveDown');
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoved', 'Точка перемещена', Format('OldIndex=%d; NewIndex=%d', [Row, Row+1]));
  end else ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoveRejected', 'Перемещение точки отклонено', Format('Direction=Down; Index=%d', [Row]));
end;

procedure TFrameMeasurementRun.SpeedButtonPauseClick(Sender: TObject);
var Run: TMeasurementRun; CommandName, UUID: string;
begin
  Run := MeasurementRun;
  if Run = nil then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRejected',
      'Команда интерфейса измерения отклонена', 'Command=Pause; Reason=MeasurementRunNotAssigned');
    Exit;
  end;
  UUID := '';
  if Run.CurrentPoint <> nil then UUID := Run.CurrentPoint.UUID;
  if Run.IsPaused then CommandName := 'Resume' else CommandName := 'Pause';
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested',
    'Запрошена команда интерфейса измерения',
    Format('Command=%s; AutoMode=%s; RunAssigned=True; Stage=%d; CurrentPointIndex=%d; CurrentPointUUID=%s',
      [CommandName, BoolToStr(Run.Mode = mrmAutomatic, True), Ord(Run.Stage),
       Run.CurrentPointIndex, UUID]));
  if Run.IsPaused then Run.Execute(mcResume, Null)
  else Run.Execute(mcPause, Null);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent',
    'Команда интерфейса измерения передана', 'Command=' + CommandName);
  UpdateUI;
end;

procedure TFrameMeasurementRun.SpeedButtonPointDeleteClick(Sender: TObject);
var Row: Integer; State: TPointsGridState;
begin
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) or
     not (MeasurementRun.Stage in [msNone, msDone]) then Exit;
  State := CapturePointsGridState; Row := State.Row;
  if (Row < 0) or (Row >= MeasurementRun.Points.Count) then Exit;
  MeasurementRun.Points.Delete(Row);
  State.Point := nil; State.PointUUID := '';
  UpdateGridMesurmentRun;
  RestorePointsGridSelectionAndFocus(State, Min(Row, MeasurementRun.Points.Count - 1), True, 'Delete');
end;

procedure TFrameMeasurementRun.SpeedButtonCreatePointsClick(Sender: TObject);
var State: TPointsGridState;
begin
  if MeasurementRun = nil then Exit;
  State := CapturePointsGridState;
  UpdateGridMesurmentRun;
  RestorePointsGridSelectionAndFocus(State, State.Row, True, 'Refresh');
end;

procedure TFrameMeasurementRun.CheckBoxMergePointsChange(Sender: TObject);
var State: TPointsGridState;
begin
  if MeasurementRun = nil then Exit;
  State := CapturePointsGridState;
  MeasurementRun.MergePoints := CheckBoxMergePoints.IsChecked;
  SaveMergePointsSetting;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMergeModeChanged', 'Изменён режим объединения точек',
    'Enabled=' + BoolToStr(CheckBoxMergePoints.IsChecked, True));
  if (MeasurementRun.Mode = mrmAutomatic) and
     (MeasurementRun.Stage in [msNone, msDone]) then begin
    MeasurementRun.InvalidatePreparedPoints; MeasurementRun.RebuildMeasurementPoints;
    FPointFlowSortDirection := 0; FInvalidPointIndexes.Clear; UpdateGridMesurmentRun;
    RestorePointsGridSelectionAndFocus(State, State.Row, True, 'MergeModeChanged');
  end;
end;

procedure TFrameMeasurementRun.LoadMergePointsSetting;
var Ini: TIniFile; FileName: string;
begin
  CheckBoxMergePoints.IsChecked := True;
  FileName := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), 'Settings'), 'MeasurementRun.ini');
  if not FileExists(FileName) then Exit;
  Ini := TIniFile.Create(FileName); try CheckBoxMergePoints.IsChecked := Ini.ReadBool('Points', 'MergePoints', True); finally Ini.Free; end;
end;

procedure TFrameMeasurementRun.SaveMergePointsSetting;
var Ini: TIniFile; FileName: string;
begin
  FileName := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), 'Settings'), 'MeasurementRun.ini');
  ForceDirectories(ExtractFilePath(FileName)); Ini := TIniFile.Create(FileName);
  try Ini.WriteBool('Points', 'MergePoints', CheckBoxMergePoints.IsChecked); finally Ini.Free; end;
end;


end.
