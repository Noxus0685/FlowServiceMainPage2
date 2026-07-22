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
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.IOUtils,
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
  uDataManager,
  uMeasurementRun,
  uObservable,
  uRepositories,
  uWorkTable;

type
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
    StringColumnLimitTime: TStringColumn;
    StringColumnLimitImp: TStringColumn;
    StringColumnLimitVolume: TStringColumn;
    LabelMeasurementScenario: TLabel;
    ComboBoxMeasurementScenario: TComboBox;
    ButtonStartMeasurementScenario: TButton;
    LabelScenarioResult: TLabel;
    LayoutMeasurementControls: TLayout;
    LayoutScenarioControls: TLayout;
    procedure GridMeasurmentRunGetValue(Sender: TObject; const ACol,
      ARow: Integer; var Value: TValue);
    procedure GridMeasurmentRunDrawColumnCell(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure GridMeasurmentRunSetValue(Sender: TObject; const ACol,
      ARow: Integer; const Value: TValue);
    procedure GridMeasurmentRunCellClick(const Column: TColumn; const Row: Integer);
    procedure SpeedButtonCreatePointsClick(Sender: TObject);
    procedure SpeedButtonPauseClick(Sender: TObject);
    procedure SpeedButtonPointDeleteClick(Sender: TObject);
    procedure SpeedButtonPointNextClick(Sender: TObject);
    procedure SpeedButtonPointPrevClick(Sender: TObject);
    procedure ButtonStartMeasurementScenarioClick(Sender: TObject);
  private
    FActiveWorkTable: TWorkTable;
    FInvalidPointIndexes: TList<Integer>;
    FScenarioTimer: TTimer;
    FScenarioSelected: EMeasurementScenario;
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
    procedure ScenarioTimerTimer(Sender: TObject);
    procedure FinishScenarioRun(const AResultText: string);
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

procedure AppendScenarioUiLog(const AText: string);
begin
  try
    TFile.AppendAllText('MAIN2_UPDATE_COMMENTS.md',
      FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' UI: ' + AText + sLineBreak, TEncoding.UTF8);
  except
    // Ошибка записи лога не должна мешать UI.
  end;
end;

constructor TFrameMeasurementRun.Create(AOwner: TComponent);
begin
  inherited;
  FInvalidPointIndexes := TList<Integer>.Create;

  LayoutMeasurementControls := TLayout.Create(Self);
  LayoutMeasurementControls.Parent := ToolBarGridMR;
  LayoutMeasurementControls.Align := TAlignLayout.Left;
  LayoutMeasurementControls.Width := 321;

  LayoutScenarioControls := TLayout.Create(Self);
  LayoutScenarioControls.Parent := ToolBarGridMR;
  LayoutScenarioControls.Align := TAlignLayout.Client;
  LayoutScenarioControls.Margins.Left := 8;

  SpeedButtonPointPrev.Parent := LayoutMeasurementControls;
  SpeedButtonPause.Parent := LayoutMeasurementControls;
  SpeedButtonPointNext.Parent := LayoutMeasurementControls;
  SpeedButtonPointDelete.Parent := LayoutMeasurementControls;
  SpeedButtonCreatePoints.Parent := LayoutMeasurementControls;

  LabelMeasurementScenario.Parent := LayoutScenarioControls;
  LabelMeasurementScenario.Align := TAlignLayout.Left;
  LabelMeasurementScenario.Width := 115;
  LabelMeasurementScenario.Margins.Right := 6;

  ButtonStartMeasurementScenario.Parent := LayoutScenarioControls;
  ButtonStartMeasurementScenario.Align := TAlignLayout.Right;
  ButtonStartMeasurementScenario.Width := 145;
  ButtonStartMeasurementScenario.Margins.Left := 6;
  ButtonStartMeasurementScenario.Text := 'Запустить';

  LabelScenarioResult.Parent := LayoutScenarioControls;
  LabelScenarioResult.Align := TAlignLayout.Right;
  LabelScenarioResult.Width := 180;
  LabelScenarioResult.Margins.Left := 6;

  ComboBoxMeasurementScenario.Parent := LayoutScenarioControls;
  ComboBoxMeasurementScenario.Align := TAlignLayout.Client;
  ComboBoxMeasurementScenario.ItemIndex := 0;

  SpeedButtonPointPrev.OnClick := SpeedButtonPointPrevClick;
  SpeedButtonPointNext.OnClick := SpeedButtonPointNextClick;
  SpeedButtonPause.OnClick := SpeedButtonPauseClick;
  SpeedButtonPointDelete.OnClick := SpeedButtonPointDeleteClick;
  SpeedButtonCreatePoints.OnClick := SpeedButtonCreatePointsClick;
  ButtonStartMeasurementScenario.OnClick := ButtonStartMeasurementScenarioClick;
  FScenarioTimer := TTimer.Create(Self);
  FScenarioTimer.Enabled := False;
  FScenarioTimer.Interval := 1;
  FScenarioTimer.OnTimer := ScenarioTimerTimer;
  GridMeasurmentRun.ShowHint := True;
  GridMeasurmentRun.OnCellClick := GridMeasurmentRunCellClick;
end;

destructor TFrameMeasurementRun.Destroy;
begin
    if FScenarioTimer <> nil then
      FScenarioTimer.Enabled := False;
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


procedure TFrameMeasurementRun.UpdateGridMRHeaders;
var
  ReservedWidth: Single;
begin
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
    StringColumnMRFlowRate.Header := 'Расход, ' + FActiveWorkTable.ValueFlowRate.GetDimName
  else
    StringColumnMRFlowRate.Header := 'Расход';

  CheckColumnMREnable.Width := 32;
  StringColumnPointer.Width := 36;
  StringColumnMRFlowRate.Width := 82;
  StringColumnMRStopCriterea.Width := 86;
  StringColumnLimitTime.Width := 58;
  StringColumnLimitVolume.Width := 64;
  StringColumnLimitImp.Width := 64;
  StringColumnRepeats.Width := 58;
  StringColumnMRStatus.Width := 96;

  ReservedWidth := CheckColumnMREnable.Width + StringColumnPointer.Width +
    StringColumnMRFlowRate.Width + StringColumnMRStopCriterea.Width +
    StringColumnRepeats.Width + StringColumnMRStatus.Width + 24;
  if StringColumnLimitTime.Visible then
    ReservedWidth := ReservedWidth + StringColumnLimitTime.Width;
  if StringColumnLimitVolume.Visible then
    ReservedWidth := ReservedWidth + StringColumnLimitVolume.Width;
  if StringColumnLimitImp.Visible then
    ReservedWidth := ReservedWidth + StringColumnLimitImp.Width;

  StringColumnMRStopCriterea.Header := 'Остановка';
  StringColumnRepeats.Header := 'Повтор';
  StringColumnMRPointName.Width := Max(120.0, GridMeasurmentRun.Width - ReservedWidth);
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




procedure TFrameMeasurementRun.FinishScenarioRun(const AResultText: string);
begin
  if FScenarioTimer <> nil then
    FScenarioTimer.Enabled := False;
  LabelScenarioResult.Text := AResultText;
  UpdateGridMesurmentRun;
  ButtonStartMeasurementScenario.Text := 'Запустить';
  ComboBoxMeasurementScenario.Enabled := True;
  ButtonStartMeasurementScenario.Enabled := True;
  AppendScenarioUiLog('восстановление доступности элементов управления: ' + AResultText);
end;

procedure TFrameMeasurementRun.ScenarioTimerTimer(Sender: TObject);
var
  ResultText: string;
begin
  if MeasurementRun = nil then
  begin
    FinishScenarioRun('MeasurementRun не подготовлен');
    Exit;
  end;

  FScenarioTimer.Enabled := False;
  try
    MeasurementRun.RunScenario(FScenarioSelected, ResultText);
    if ResultText <> '' then
      FinishScenarioRun(ResultText)
    else
      FScenarioTimer.Enabled := True;
  except
    on E: Exception do
      FinishScenarioRun('Ошибка сценария: ' + E.Message);
  end;
end;

procedure TFrameMeasurementRun.ButtonStartMeasurementScenarioClick(Sender: TObject);
begin
  if MeasurementRun = nil then
  begin
    LabelScenarioResult.Text := 'MeasurementRun не подготовлен';
    Exit;
  end;

  FScenarioSelected := EMeasurementScenario(Max(0, ComboBoxMeasurementScenario.ItemIndex));
  ComboBoxMeasurementScenario.Enabled := False;
  ButtonStartMeasurementScenario.Enabled := False;
  ButtonStartMeasurementScenario.Text := 'Выполняется...';
  LabelScenarioResult.Text := 'Выполняется...';
  FScenarioTimer.Enabled := True;
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
