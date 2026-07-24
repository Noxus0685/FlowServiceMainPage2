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
  System.Generics.Collections,
  System.Threading,
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
  uAutoMeasurementTestRunner,
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
    LayoutAutoTests: TLayout;
    ComboBoxAutoTestScenario: TComboBox;
    ButtonRunAutoTestScenario: TButton;
    ButtonRunAllAutoTestScenarios: TButton;
    LabelAutoTestResult: TLabel;
    GridAutoTestResults: TGrid;
    StringColumnAutoTestNo: TStringColumn;
    StringColumnAutoTestScenario: TStringColumn;
    StringColumnAutoTestResult: TStringColumn;
    StringColumnAutoTestTime: TStringColumn;
    StringColumnAutoTestStage: TStringColumn;
    StringColumnAutoTestWorkTableState: TStringColumn;
    StringColumnAutoTestReason: TStringColumn;
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
    procedure ButtonRunAutoTestScenarioClick(Sender: TObject);
    procedure ButtonRunAllAutoTestScenariosClick(Sender: TObject);
    procedure GridAutoTestResultsGetValue(Sender: TObject; const ACol,
      ARow: Integer; var Value: TValue);
    procedure GridAutoTestResultsDrawColumnCell(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
  private
    FActiveWorkTable: TWorkTable;
    FInvalidPointIndexes: TList<Integer>;
    FAutoTestResults: TList<TAutoMeasurementTestResult>;
    FAutoTestRunning: Boolean;
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
    function IsPointInvalid(APoint: TDevicePoint): Boolean;
    function GetRowColor(const ARow: Integer): TAlphaColor;
    procedure SetAutoTestControlsEnabled(const AEnabled: Boolean);
    procedure AddAutoTestResult(const AResult: TAutoMeasurementTestResult);
    procedure RunAutoTests(const ARunAll: Boolean);
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
  FAutoTestResults := TList<TAutoMeasurementTestResult>.Create;
  SpeedButtonPointPrev.OnClick := SpeedButtonPointPrevClick;
  SpeedButtonPointNext.OnClick := SpeedButtonPointNextClick;
  SpeedButtonPause.OnClick := SpeedButtonPauseClick;
  SpeedButtonPointDelete.OnClick := SpeedButtonPointDeleteClick;
  SpeedButtonCreatePoints.OnClick := SpeedButtonCreatePointsClick;
  ButtonRunAutoTestScenario.OnClick := ButtonRunAutoTestScenarioClick;
  ButtonRunAllAutoTestScenarios.OnClick := ButtonRunAllAutoTestScenariosClick;
  GridAutoTestResults.OnGetValue := GridAutoTestResultsGetValue;
  GridAutoTestResults.OnDrawColumnCell := GridAutoTestResultsDrawColumnCell;
  TAutoMeasurementTestRunner.FillScenarioNames(ComboBoxAutoTestScenario.Items);
  ComboBoxAutoTestScenario.ItemIndex := 0;
  GridMeasurmentRun.ShowHint := True;
  GridMeasurmentRun.OnCellClick := GridMeasurmentRunCellClick;
end;

destructor TFrameMeasurementRun.Destroy;
begin
    FreeAndNil(FAutoTestResults);
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




procedure TFrameMeasurementRun.SetAutoTestControlsEnabled(const AEnabled: Boolean);
begin
  FAutoTestRunning := not AEnabled;
  ComboBoxAutoTestScenario.Enabled := AEnabled;
  ButtonRunAutoTestScenario.Enabled := AEnabled;
  ButtonRunAllAutoTestScenarios.Enabled := AEnabled;
end;

procedure TFrameMeasurementRun.AddAutoTestResult(const AResult: TAutoMeasurementTestResult);
begin
  FAutoTestResults.Add(AResult);
  GridAutoTestResults.RowCount := FAutoTestResults.Count;
  GridAutoTestResults.Repaint;
  LabelAutoTestResult.Text := TAutoMeasurementTestRunner.StatusToString(AResult.Status) + ': ' + AResult.ScenarioName;
end;

procedure TFrameMeasurementRun.RunAutoTests(const ARunAll: Boolean);
var
  ScenarioIndex: Integer;
begin
  if FAutoTestRunning then
    Exit;
  ScenarioIndex := ComboBoxAutoTestScenario.ItemIndex + 1;
  if ScenarioIndex < 1 then
    ScenarioIndex := 1;
  FAutoTestResults.Clear;
  GridAutoTestResults.RowCount := 0;
  LabelAutoTestResult.Text := 'RUNNING';
  SetAutoTestControlsEnabled(False);
  TTask.Run(
    procedure
    var
      Log: TStringList;
      LogFileName: string;
      R: TAutoMeasurementTestResult;
    begin
      Log := TStringList.Create;
      try
        LogFileName := TAutoMeasurementTestRunner.CreateLogFileName;
        if ARunAll then
          TAutoMeasurementTestRunner.RunAll(Log,
            procedure(const AResult: TAutoMeasurementTestResult)
            begin
              TThread.Queue(nil,
                procedure
                begin
                  AddAutoTestResult(AResult);
                end);
            end)
        else
        begin
          R := TAutoMeasurementTestRunner.RunScenario(ScenarioIndex, Log);
          TThread.Queue(nil,
            procedure
            begin
              AddAutoTestResult(R);
            end);
        end;
        Log.SaveToFile(LogFileName, TEncoding.UTF8);
      finally
        Log.Free;
        TThread.Queue(nil,
          procedure
          begin
            SetAutoTestControlsEnabled(True);
          end);
      end;
    end);
end;

procedure TFrameMeasurementRun.ButtonRunAutoTestScenarioClick(Sender: TObject);
begin
  RunAutoTests(False);
end;

procedure TFrameMeasurementRun.ButtonRunAllAutoTestScenariosClick(Sender: TObject);
begin
  RunAutoTests(True);
end;

procedure TFrameMeasurementRun.GridAutoTestResultsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  R: TAutoMeasurementTestResult;
begin
  if (ARow < 0) or (ARow >= FAutoTestResults.Count) then
    Exit;
  R := FAutoTestResults[ARow];
  case ACol of
    0: Value := R.Index;
    1: Value := R.ScenarioName;
    2: Value := TAutoMeasurementTestRunner.StatusToString(R.Status);
    3: Value := IntToStr(R.DurationMs) + ' ms';
    4: Value := R.StageText;
    5: Value := R.WorkTableStateText;
    6: Value := R.Reason;
  end;
end;

procedure TFrameMeasurementRun.GridAutoTestResultsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  C: TAlphaColor;
begin
  C := COLOR_NONE;
  if (Row >= 0) and (Row < FAutoTestResults.Count) then
    case FAutoTestResults[Row].Status of
      amtsPass: C := COLOR_COMPLETED;
      amtsFail, amtsStopped: C := COLOR_WARNING;
      amtsError: C := COLOR_INVALID;
    end;
  Canvas.Fill.Color := C;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
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
