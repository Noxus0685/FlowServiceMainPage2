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
    procedure GridMeasurmentRunSelChanged(Sender: TObject);
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
    FSubscribedMeasurementRun: TMeasurementRun;
    FRestoringGridState: Boolean;
    FOnRunUIChanged: TNotifyEvent;
    function GetMeasurementRun: TMeasurementRun;
    function GetStopCriteriaText(APoint: TDevicePoint): string;


    procedure SetActiveWorkTable(const Value: TWorkTable);
    procedure AttachMeasurementRunEvents;
    procedure EnsureMeasurementRunSubscription;
    procedure DetachMeasurementRunEvents;
    procedure SyncCurrentPointFromSubscribedRun;
    procedure MeasurementRunStateChanged(ASender: TObject; AState: EMeasurementState);
    procedure MeasurementRunPointChanged(ASender: TObject; APoint: TDevicePoint; APointIndex: Integer);
    procedure MeasurementRunEvent(ASender: TObject; AEvent: EMeasurementEvent; const AError: TErrorInfo);
    procedure SetPointEnabledFromGrid(APoint: TDevicePoint; const AEnabled: Boolean);
    procedure UpdateGridMRHeaders;
    procedure UpdateStopCriteriaColumns;
    procedure UpdatePointOrderControls;
    procedure UpdateMeasurementControls;
    procedure UpdatePauseButtonState;
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
    property OnRunUIChanged: TNotifyEvent read FOnRunUIChanged write FOnRunUIChanged;

  end;

implementation

{$R *.fmx}

constructor TFrameMeasurementRun.Create(AOwner: TComponent);
begin
  inherited;
  FInvalidPointIndexes := TList<Integer>.Create;
  FSubscribedMeasurementRun := nil;
  GridMeasurmentRun.ShowHint := True;
  GridMeasurmentRun.OnCellClick := GridMeasurmentRunCellClick;
  FPointFlowSortDirection := 0;
  LoadMergePointsSetting;
end;

destructor TFrameMeasurementRun.Destroy;
begin
    DetachMeasurementRunEvents;
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
  if FActiveWorkTable <> Value then
  begin
    DetachMeasurementRunEvents;
    FActiveWorkTable := Value;
    FInvalidPointIndexes.Clear;
  end;
  EnsureMeasurementRunSubscription;
  UpdateGridMRHeaders;
  UpdateUI;
end;

procedure TFrameMeasurementRun.AttachMeasurementRunEvents;
begin
  EnsureMeasurementRunSubscription;
end;

procedure TFrameMeasurementRun.DetachMeasurementRunEvents;
var OldRun: TMeasurementRun;
begin
  OldRun := FSubscribedMeasurementRun;
  if OldRun <> nil then
  begin
    OldRun.Unsubscribe(Self);
    FSubscribedMeasurementRun := nil;
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunSubscriptionDetached',
      'Frame отписан от MeasurementRun',
      Format('RunPointer=%p; Reason=WorkTableChangedOrFrameDestroy', [Pointer(OldRun)]));
  end;
end;

procedure TFrameMeasurementRun.EnsureMeasurementRunSubscription;
var
  LRun, OldRun: TMeasurementRun;
  StageValue, PointIndex: Integer;
begin
  LRun := GetMeasurementRun;
  if FSubscribedMeasurementRun = LRun then Exit;
  OldRun := FSubscribedMeasurementRun;
  if OldRun <> nil then
  begin
    OldRun.Unsubscribe(Self);
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunSubscriptionDetached',
      'Frame отписан от заменённого MeasurementRun',
      Format('RunPointer=%p; Reason=RunReplaced', [Pointer(OldRun)]));
  end;
  FSubscribedMeasurementRun := LRun;
  FCurrentPoint := nil;
  FCurrentPointUUID := '';
  FLastIndicatorUUID := '';
  FInvalidPointIndexes.Clear;
  if FSubscribedMeasurementRun <> nil then FSubscribedMeasurementRun.Subscribe(Self);
  SyncCurrentPointFromSubscribedRun;
  StageValue := -1; PointIndex := -1;
  if FSubscribedMeasurementRun <> nil then
  begin
    StageValue := Ord(FSubscribedMeasurementRun.Stage);
    PointIndex := FSubscribedMeasurementRun.CurrentPointIndex;
  end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunSubscriptionChanged',
    'Изменена подписка frame на MeasurementRun',
    Format('OldRunPointer=%p; NewRunPointer=%p; WorkTablePointer=%p; NewRunStage=%d; NewRunCurrentPointIndex=%d; Reason=RunReplaced',
      [Pointer(OldRun), Pointer(FSubscribedMeasurementRun), Pointer(FActiveWorkTable),
       StageValue, PointIndex]));
  if Assigned(FOnRunUIChanged) then FOnRunUIChanged(Self);
end;

procedure TFrameMeasurementRun.SyncCurrentPointFromSubscribedRun;
begin
  if FSubscribedMeasurementRun = nil then
  begin
    FCurrentPoint := nil;
    FCurrentPointUUID := '';
    Exit;
  end;
  FCurrentPoint := FSubscribedMeasurementRun.CurrentPoint;
  if FCurrentPoint <> nil then FCurrentPointUUID := FCurrentPoint.UUID
  else FCurrentPointUUID := '';
end;

procedure TFrameMeasurementRun.OnNotify(Sender: TObject; Event: Integer; Data: TObject);
var
  LRun: TMeasurementRun;
  LIdx: Integer;
begin
  if not (Sender is TMeasurementRun) then
    Exit;

  EnsureMeasurementRunSubscription;
  if Sender <> FSubscribedMeasurementRun then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunEventIgnored',
      'Проигнорировано событие старого MeasurementRun',
      Format('SenderPointer=%p; SubscribedRunPointer=%p; Event=%d; Reason=OldMeasurementRun',
        [Pointer(Sender), Pointer(FSubscribedMeasurementRun), Event]));
    Exit;
  end;
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
var LRun: TMeasurementRun;
begin
  if not (ASender is TMeasurementRun) or (ASender <> FSubscribedMeasurementRun) then Exit;
  LRun := TMeasurementRun(ASender);
  if LRun.CurrentPoint <> nil then
  begin
    FCurrentPoint := LRun.CurrentPoint;
    FCurrentPointUUID := FCurrentPoint.UUID;
  end
  else if AState in [msNone, msDone] then
  begin
    FCurrentPoint := nil;
    FCurrentPointUUID := '';
  end;
  UpdateGridMesurmentRun;
  UpdatePauseButtonState;
  if Assigned(FOnRunUIChanged) then FOnRunUIChanged(Self);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandObserved',
    'Наблюдается фактическое состояние измерения',
    Format('Command=StateChanged; StageAfter=%d; PointIndexAfter=%d; CurrentPointUUID=%s; IsPausedAfter=%s',
      [Ord(AState), LRun.CurrentPointIndex, FCurrentPointUUID,
       BoolToStr(LRun.IsPaused, True)]));
end;

procedure TFrameMeasurementRun.MeasurementRunPointChanged(ASender: TObject;
  APoint: TDevicePoint; APointIndex: Integer);
var LRun: TMeasurementRun;
begin
  if not (ASender is TMeasurementRun) or (ASender <> FSubscribedMeasurementRun) then Exit;
  LRun := TMeasurementRun(ASender);
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
  UpdateCurrentPointIndicator;
  UpdateMeasurementControls;
  if Assigned(FOnRunUIChanged) then FOnRunUIChanged(Self);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandObserved',
    'Наблюдается фактическое изменение точки',
    Format('Command=PointChanged; StageAfter=%d; PointIndexAfter=%d; CurrentPointUUID=%s; IsPausedAfter=%s',
      [Ord(LRun.Stage), APointIndex, FCurrentPointUUID,
       BoolToStr(LRun.IsPaused, True)]));
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

procedure TFrameMeasurementRun.GridMeasurmentRunSelChanged(Sender: TObject);
begin
  if not FRestoringGridState then UpdatePointOrderControls;
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
     EnsureMeasurementRunSubscription;
     SyncCurrentPointFromSubscribedRun;
     UpdateGridMRHeaders;
     UpdateGridMesurmentRun;
     UpdateMeasurementControls;
     UpdatePauseButtonState;
     UpdateCurrentPointIndicator;
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

  SelectedRow := GridMeasurmentRun.Row;
  UpdateStopCriteriaColumns;

  GridMeasurmentRun.BeginUpdate;
  try
    GridMeasurmentRun.RowCount := 0;
    GridMeasurmentRun.RowCount := Rows;
  finally
    GridMeasurmentRun.EndUpdate;
  end;

  if Rows = 0 then
    GridMeasurmentRun.Row := -1
  else if SelectedRow >= Rows then
    GridMeasurmentRun.Row := Rows - 1
  else if SelectedRow >= 0 then
    GridMeasurmentRun.Row := SelectedRow;

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
  Row := GridMeasurmentRun.Row;
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then Count := MeasurementRun.Points.Count else Count := 0;
  CanEditOrder := (MeasurementRun <> nil) and (MeasurementRun.Stage in [msNone, msDone]);
  SpeedButtonPointMoveUp.Enabled := CanEditOrder and (Row > 0) and (Row < Count);
  SpeedButtonPointMoveDown.Enabled := CanEditOrder and (Row >= 0) and (Row < Count - 1);
  SpeedButtonPointDelete.Enabled := CanEditOrder and (Row >= 0) and (Row < Count);
end;

procedure TFrameMeasurementRun.UpdateMeasurementControls;
begin
  { Исторические командные кнопки не дублируют ограничения FSM формы. }
  SpeedButtonPointPrev.Enabled := MeasurementRun <> nil;
  SpeedButtonPointNext.Enabled := MeasurementRun <> nil;
  SpeedButtonPause.Enabled := (MeasurementRun <> nil) and
    not (MeasurementRun.Stage in [msNone, msDone]);
  UpdatePauseButtonState;
end;

procedure TFrameMeasurementRun.UpdatePauseButtonState;
begin
  // The historical component name is retained for .fmx compatibility.  This
  // control is now always the Stop command, never Pause/Resume.
  SpeedButtonPause.StyleLookup := 'stoptoolbutton';
  SpeedButtonPause.Hint := 'Остановить измерение';
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
  Result.PointUUID := ''; Result.Point := nil; Result.Row := GridMeasurmentRun.Row;
  Result.ScrollY := GridMeasurmentRun.ViewportPosition.Y;
  Result.HadFocus := GridMeasurmentRun.IsFocused;
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) and
     (Result.Row >= 0) and (Result.Row < MeasurementRun.Points.Count) then
  begin Result.Point := MeasurementRun.Points[Result.Row]; Result.PointUUID := Result.Point.UUID; end;
end;

procedure TFrameMeasurementRun.RestorePointsGridSelectionAndFocus(const AState: TPointsGridState;
  const AFallbackRow: Integer; const AReturnFocus: Boolean; const AReason: string);
var ResolvedRow: Integer;
begin
  ResolvedRow := ResolvePointRow(AState.PointUUID, AState.Point, AFallbackRow);
  TThread.Queue(nil,
    procedure
    begin
      FRestoringGridState := True;
      try
        GridMeasurmentRun.Row := ResolvedRow;
        GridMeasurmentRun.Selected := ResolvedRow;
        GridMeasurmentRun.ViewportPosition := PointF(
          GridMeasurmentRun.ViewportPosition.X, AState.ScrollY);
        if ResolvedRow >= 0 then GridMeasurmentRun.ScrollToSelectedCell;
        if (AReturnFocus or AState.HadFocus) and GridMeasurmentRun.CanFocus then
          GridMeasurmentRun.SetFocus;
      finally
        FRestoringGridState := False;
      end;
      UpdatePointOrderControls;
      ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointsGridFocusRestored',
        'Восстановлено состояние таблицы точек',
        Format('Reason=%s; PointUUID=%s; ResolvedRow=%d; ScrollRestored=True; FocusRestored=%s',
          [AReason, AState.PointUUID, ResolvedRow,
           BoolToStr(AReturnFocus or AState.HadFocus, True)]));
      if SameText(AReason, 'MoveUp') or SameText(AReason, 'MoveDown') then
        ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoved',
          'Точка перемещена и состояние таблицы восстановлено',
          Format('Direction=%s; PointUUID=%s; OldIndex=%d; NewIndex=%d; GridRowAfter=%d; MoveUpEnabledAfter=%s; MoveDownEnabledAfter=%s; FocusRestored=%s',
            [Copy(AReason, 5, MaxInt), AState.PointUUID, AState.Row, ResolvedRow,
             GridMeasurmentRun.Row, BoolToStr(SpeedButtonPointMoveUp.Enabled, True),
             BoolToStr(SpeedButtonPointMoveDown.Enabled, True),
             BoolToStr(GridMeasurmentRun.IsFocused, True)]));
    end);
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
var Run: TMeasurementRun; StageBefore, IndexBefore: Integer; PausedBefore: Boolean;
begin
  EnsureMeasurementRunSubscription;
  Run := GetMeasurementRun;
  if Run = nil then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSkipped',
      'Команда интерфейса не передана', 'Command=PreviousPoint; Reason=MeasurementRunNotAssigned');
    Exit;
  end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunSubscriptionVerified',
    'Подтверждена подписка перед UI-командой',
    Format('RunPointer=%p; Reason=Command', [Pointer(Run)]));
  StageBefore := Ord(Run.Stage); IndexBefore := Run.CurrentPointIndex; PausedBefore := Run.IsPaused;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested',
    'Запрошена команда интерфейса измерения',
    Format('Command=PreviousPoint; AutoMode=%s; RunAssigned=True; Stage=%d; IsPaused=%s; CurrentPointIndex=%d; CurrentPointUUID=%s; WorkTableState=-1; ButtonEnabled=%s',
      [BoolToStr(Run.Mode = mrmAutomatic, True), Ord(Run.Stage), BoolToStr(Run.IsPaused, True),
       Run.CurrentPointIndex, FCurrentPointUUID, BoolToStr(SpeedButtonPointPrev.Enabled, True)]));
  Run.Execute(mcPreviousPoint, Unassigned);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent',
    'Команда интерфейса передана', Format('Command=PreviousPoint; RunObjectPointer=%p; StageBefore=%d; IsPausedBefore=%s; CurrentPointIndexBefore=%d',
      [Pointer(Run), StageBefore, BoolToStr(PausedBefore, True), IndexBefore]));
end;

procedure TFrameMeasurementRun.SpeedButtonPointNextClick(Sender: TObject);
var Run: TMeasurementRun; StageBefore, IndexBefore: Integer; PausedBefore: Boolean;
begin
  EnsureMeasurementRunSubscription;
  Run := GetMeasurementRun;
  if Run = nil then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSkipped',
      'Команда интерфейса не передана', 'Command=NextPoint; Reason=MeasurementRunNotAssigned');
    Exit;
  end;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementRunSubscriptionVerified',
    'Подтверждена подписка перед UI-командой',
    Format('RunPointer=%p; Reason=Command', [Pointer(Run)]));
  StageBefore := Ord(Run.Stage); IndexBefore := Run.CurrentPointIndex; PausedBefore := Run.IsPaused;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandRequested',
    'Запрошена команда интерфейса измерения',
    Format('Command=NextPoint; AutoMode=%s; RunAssigned=True; Stage=%d; IsPaused=%s; CurrentPointIndex=%d; CurrentPointUUID=%s; WorkTableState=-1; ButtonEnabled=%s',
      [BoolToStr(Run.Mode = mrmAutomatic, True), Ord(Run.Stage), BoolToStr(Run.IsPaused, True),
       Run.CurrentPointIndex, FCurrentPointUUID, BoolToStr(SpeedButtonPointNext.Enabled, True)]));
  Run.Execute(mcNextPoint, Null);
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementUiCommandSent',
    'Команда интерфейса передана', Format('Command=NextPoint; RunObjectPointer=%p; StageBefore=%d; IsPausedBefore=%s; CurrentPointIndexBefore=%d',
      [Pointer(Run), StageBefore, BoolToStr(PausedBefore, True), IndexBefore]));
end;

procedure TFrameMeasurementRun.SpeedButtonPointMoveUpClick(Sender: TObject);
var State: TPointsGridState; Row: Integer;
begin
  State := CapturePointsGridState; Row := State.Row;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoveRequested', 'Запрошено перемещение точки', Format('Direction=Up; OldIndex=%d', [Row]));
  if (MeasurementRun <> nil) and MeasurementRun.MovePointUp(Row) then begin
    FPointFlowSortDirection := 0; UpdateGridMesurmentRun;
    RestorePointsGridSelectionAndFocus(State, Row - 1, True, 'MoveUp');
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
  end else ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMoveRejected', 'Перемещение точки отклонено', Format('Direction=Down; Index=%d', [Row]));
end;

procedure TFrameMeasurementRun.SpeedButtonPauseClick(Sender: TObject);
var
  LRun: TMeasurementRun;
  LPoint: TDevicePoint;
  SenderName, SenderClass, PointUUID, PointStatus: string;
  RunStage: EMeasurementState;
  PointIndex: Integer;
  RunPaused, RunStopRequested: Boolean;
begin
  EnsureMeasurementRunSubscription;
  LRun := GetMeasurementRun;
  LPoint := nil;
  PointUUID := '';
  PointStatus := '-';
  RunStage := msNone;
  PointIndex := -1;
  RunPaused := False;
  RunStopRequested := False;
  if Sender <> nil then
    SenderClass := Sender.ClassName
  else
    SenderClass := '<nil>';
  if Sender is TComponent then
    SenderName := TComponent(Sender).Name
  else
    SenderName := '';
  if LRun <> nil then
  begin
    RunStage := LRun.Stage;
    PointIndex := LRun.CurrentPointIndex;
    RunPaused := LRun.IsPaused;
    RunStopRequested := LRun.StopRequested;
    LPoint := LRun.CurrentPoint;
    if LPoint <> nil then
    begin
      PointUUID := LPoint.UUID;
      PointStatus := LPoint.GetStatus;
    end;
  end;
  ProtocolManager.AddMessage(pcAction, psForm, 'MeasurementPauseButtonRawClick',
    'Зафиксировано нажатие кнопки остановки',
    Format('SenderName=%s; SenderClass=%s; RunAssigned=%s; RunStage=%s; CurrentPointIndex=%d; CurrentPointUUID=%s; CurrentPointStatus=%s; IsPaused=%s; StopRequested=%s; ButtonEnabled=%s',
      [SenderName, SenderClass, BoolToStr(LRun <> nil, True),
       TMeasurementRun.MeasurementStateToString(RunStage),
       PointIndex, PointUUID, PointStatus,
       BoolToStr(RunPaused, True), BoolToStr(RunStopRequested, True),
       BoolToStr(SpeedButtonPause.Enabled, True)]));
  if (LRun = nil) or (RunStage in [msNone, msDone]) or
     (FActiveWorkTable = nil) then
  begin
    ProtocolManager.AddMessage(pcInfo, psForm, 'MeasurementStopRejected',
      'Stop из кнопки отклонён',
      Format('Source=SpeedButtonPauseClick; RunAssigned=%s; RunStage=%s',
        [BoolToStr(LRun <> nil, True), TMeasurementRun.MeasurementStateToString(RunStage)]));
    Exit;
  end;
  ProtocolManager.AddMessage(pcAction, psForm, 'MeasurementStopRequested',
    'Stop из кнопки передан активному запуску',
    Format('Source=SpeedButtonPauseClick; RunStage=%s; CurrentPointIndex=%d; CurrentPointUUID=%s; CurrentPointStatus=%s; PhysicalMeasurementStarted=%s; SetupInProgress=%s',
      [TMeasurementRun.MeasurementStateToString(RunStage), LRun.CurrentPointIndex,
       PointUUID, PointStatus, BoolToStr(LRun.PhysicalMeasurementStarted, True),
       BoolToStr(RunStage in [msSelectPoint, msSelectEtalon, msSetupPoint,
         msWaitPointSetup, msWaitStable, msWaitMeasureStart], True)]));
  FActiveWorkTable.StopMeasurementRun;
  UpdateMeasurementControls;
  if Assigned(FOnRunUIChanged) then FOnRunUIChanged(Self);
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
begin
  if MeasurementRun = nil then Exit;
  MeasurementRun.MergePoints := CheckBoxMergePoints.IsChecked;
  SaveMergePointsSetting;
  ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMergeModeChanged', 'Изменён режим объединения точек',
    'Enabled=' + BoolToStr(CheckBoxMergePoints.IsChecked, True));
  if (MeasurementRun.Mode = mrmAutomatic) and
     (MeasurementRun.Stage in [msNone, msDone]) then begin
    MeasurementRun.InvalidatePreparedPoints; MeasurementRun.RebuildMeasurementPoints;
    FPointFlowSortDirection := 0; FInvalidPointIndexes.Clear; UpdateGridMesurmentRun;
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
