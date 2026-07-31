unit frmGraphsWorkspace;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections,
  FMX.Controls, FMX.Forms, FMX.Layouts, FMX.Menus, FMX.Objects,
  FMX.StdCtrls, FMX.Types, FMX.SimpleChart,
  uBaseProcedures, uClasses, uDeviceClass, uGraphsViewConfig, uMeasurementRun, uMeterValue, uProtocols,
  uWorkTable, uFlowMeter;

type
  TGraphToleranceSourceInfo = record
    Device: TDevice;
    Point: TDevicePoint;
    DeviceUUID: string;
    PointUUID: string;
    PointIndex: Integer;
    TargetQ: Double;
    ErrorPercent: Double;
    SourceKind: string;
  end;

  TGraphSegmentStartReason = (gssrNone, gssrRunStarted,
    gssrPointChanged);

  TGraphSourceEvent = procedure(Sender: TObject; const AGraphIndex: Integer) of object;

  TGraphSourceMenuItem = class(TMenuItem)
  public
    GraphIndex: Integer;
    OwnerKind: TGraphSeriesOwnerKind;
    SourceKind: TGraphSourceKind;
    ChannelUUID: string;
    MeterValueKey: string;
    Serial: string;
    SourceCaption: string;
  end;

  TGraphSeriesColorMenuItem = class(TMenuItem)
  public
    GraphIndex: Integer;
    ChannelUUID: string;
    MeterValueKey: string;
    NewColor: TAlphaColor;
  end;

  TGraphDurationMenuItem = class(TMenuItem)
  public
    DurationSec: Integer;
  end;

  TGraphHistoryLoadMode = (ghlmCurrentSegmentHistory, ghlmAfterLocalReset);

  TGraphSeriesRuntime = class
  public
    ChartSeries: TChartSeries;
    LastSampleTimeMs: Int64;
    LastSampleIndex: Integer;
    WaitingForFirstSample: Boolean;
    LastAcceptedValue: Double;
    LastAcceptedPointKey: string;
    RuntimeResetTimeMs: Int64;
    HistoryLoaded: Boolean;
    HistoryLoadMode: TGraphHistoryLoadMode;
  end;

  TGraphSourceHistory = class
  public
    SourceKey: string;
    Samples: TList<TMeterValueSample>;
    constructor Create(const ASourceKey: string);
    destructor Destroy; override;
  end;

  TGraphVisualSlot = class
  public
    RootLayout: TLayout;
    HeaderLayout: TLayout;
    TitleLabel: TLabel;
    Chart: TSimpleChart;
    HitControl: TRectangle;
    TargetSeries: TChartSeries;
    LowerSeries: TChartSeries;
    UpperSeries: TChartSeries;
    GraphIndex: Integer;
    destructor Destroy; override;
  end;

  TGraphColumnMenuItem = class(TMenuItem)
  public
    ColumnCount: Integer;
  end;

  TFrameGraphsWorkspace = class(TFrame)
    LayoutWorkspaceRoot: TLayout;
    PanelGraphSettings: TPanel;
    LabelGraphLayout: TLabel;
    ComboGraphLayout: TComboBox;
    ButtonClearAll: TButton;
    ButtonReset: TButton;
    LayoutWorkspaceBody: TLayout;
    LayoutGraphsHost: TLayout;
    ScrollBoxGraphs: TVertScrollBox;
    PopupMenuGraph: TPopupMenu;
    MenuItemEtalons: TMenuItem;
    MenuItemDevices: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemSeriesColors: TMenuItem;
    MenuItemGraphLength: TMenuItem;
    MenuItemFlowUnits: TMenuItem;
    MenuItemShowLegend: TMenuItem;
    MenuItemShowTargetLine: TMenuItem;
    MenuItemShowToleranceLines: TMenuItem;
    MenuItemAddGraph: TMenuItem;
    MenuItemDeleteGraph: TMenuItem;
    MenuItemLayout: TMenuItem;
    MenuItemClearGraphValues: TMenuItem;
    MenuItemClearGraph: TMenuItem;
    procedure GraphLayoutChange(Sender: TObject);
    procedure ClearAllClick(Sender: TObject);
    procedure ResetClick(Sender: TObject);
    procedure GraphControlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GraphHitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GraphPopup(Sender: TObject);
    procedure ClearGraphValuesClick(Sender: TObject);
    procedure ClearGraphClick(Sender: TObject);
    procedure GraphColumnModeClick(Sender: TObject);
    procedure SeriesColorClick(Sender: TObject);
    procedure GraphDurationClick(Sender: TObject);
    procedure ShowLegendClick(Sender: TObject);
    procedure ToleranceVisibilityClick(Sender: TObject);
    procedure AddGraphClick(Sender: TObject);
    procedure DeleteGraphClick(Sender: TObject);
    procedure SourceMenuItemClick(Sender: TObject);
  private
    FWorkTable: TWorkTable;
    FConfig: TGraphsViewConfig;
    FSelectedGraph: Integer;
    FContextGraphIndex: Integer;
    FUpdatingControls: Boolean;
    FSeriesRuntime: TObjectDictionary<TGraphSeriesConfig, TGraphSeriesRuntime>;
    FLastRunActive: Boolean;
    FSharedSegmentStartMs: Int64;
    FSharedCurrentTimeSec: Double;
    FSharedAxisMinX: Double;
    FSharedAxisMaxX: Double;
    FSharedTimeInitialized: Boolean;
    FLastPointKey: string;
    FLastPointIndex: Integer;
    FRuntimeResetTimeMs: Int64;
    FLastSegmentDecision: string;
    FLastFlowUnitKey: string;
    FLastFallbackSampleMs: Int64;
    FLastUpdateDiagnosticMs: Int64;
    FDefaultSourcesInitialized: Boolean;
    FLastToleranceDiagnosticMs: Int64;
    FLastToleranceDiagnosticReason: string;
    FToleranceDiagnosticTimes: TDictionary<string, Int64>;
    FLastToleranceSourceInfo: TGraphToleranceSourceInfo;
    FGraphSlots: TObjectList<TGraphVisualSlot>;
    FSegmentHistory: TObjectDictionary<string, TGraphSourceHistory>;
    FApplyingLayout: Boolean;
    FLastLayoutColumns: Integer;
    FLastLayoutRows: Integer;
    FLastLayoutGraphCount: Integer;
    FLastGraphCellWidth: Single;
    FLastGraphCellHeight: Single;
    function CreateGraphSlot(const AGraphIndex: Integer): TGraphVisualSlot;
    procedure DestroyGraphSlot(const AGraphIndex: Integer);
    procedure EnsureGraphSlotCount(const ACount: Integer);
    procedure ReindexGraphSlots;
    function GraphSlotByIndex(const AIndex: Integer): TGraphVisualSlot;
    function ChartByIndex(const AIndex: Integer): TSimpleChart;
    procedure CalculateDynamicGrid(const AGraphCount: Integer;
      const AAvailableWidth: Single; out AColumns, ARows: Integer);
    procedure ApplyDynamicGridLayout;
    procedure SelectGraph(const AIndex: Integer);
    procedure SyncControls;
    procedure ClearChart(const AIndex: Integer; const AClearAssignments: Boolean);
    procedure ClearDynamicMenu(AParent: TMenuItem);
    procedure BuildSourceMenu(out AEtalonCount, ADeviceCount: Integer);
    procedure BuildSeriesColorsMenu;
    procedure UpdateGraphSettingsMenu;
    function NextSeriesColor(const AGraphIndex: Integer): TAlphaColor;
    function FindSeries(const AGraphIndex: Integer; const AChannelUUID,
      AMeterValueKey: string): TGraphSeriesConfig;
    procedure DeleteSource(const AGraphIndex: Integer; ASeries: TGraphSeriesConfig);
    procedure AddEmptyMenuItem(AParent: TMenuItem; const ACaption: string);
    procedure AddChannelMenuItem(AParent: TMenuItem; AChannel: TChannel;
      const AOwnerKind: TGraphSeriesOwnerKind);
    function ResolveChannel(const ASeries: TGraphSeriesConfig): TChannel;
    function ResolveMeterValue(const ASeries: TGraphSeriesConfig;
      AChannel: TChannel): TMeterValue;
    function NormalizeUUID(const AValue: string): string;
    function ResolveSeriesSource(ASeriesConfig: TGraphSeriesConfig;
      out AChannel: TChannel; out AMeterValue: TMeterValue;
      out AReason: string): Boolean;
    function EnsureVisualSeries(AGraphIndex: Integer;
      ASeriesConfig: TGraphSeriesConfig): TChartSeries;
    function GetSeriesSamples(AMeterValue: TMeterValue;
      out ASamples: TArray<TMeterValueSample>): Boolean;
    procedure UpdateSeriesPoints(AGraphIndex: Integer;
      ASeriesConfig: TGraphSeriesConfig; AChartSeries: TChartSeries;
      AMeterValue: TMeterValue; const ANowMs: Int64;
      const ADoFallback, ASamplingActive: Boolean;
      var AAddedCount: Integer);
    function IsSamplingActive: Boolean;
    procedure ResetSeriesSegment(const AStartMs: Int64;
      const APointKey: string);
    function GetCurrentFlowUnitText: string;
    function GetCurrentFlowUnitKey: string;
    function ConvertFlowToDisplayUnits(const AValue: Double): Double;
    procedure CheckFlowUnitsChanged;
    procedure RebuildSeriesForCurrentUnits;
    procedure UpdateChartAxisUnits;
    function CurrentPointKey(out APointIndex: Integer): string;
    function IsPointTransitionStage: Boolean;
    procedure StartSharedSegment(const AReason: TGraphSegmentStartReason;
      const APointKey: string; const APointIndex: Integer);
    procedure CalculateSharedTimeRange(const ANowMs: Int64);
    procedure ApplySharedXAxis;
    procedure EnsureLimitSeries(const AGraphIndex: Integer);
    procedure UpdateToleranceLines;
    procedure UpdateToleranceLinesForGraph(const AGraphIndex: Integer);
    function ResolvePointTolerance(out ATarget, ALower, AUpper,
      AErrorPercent: Double; out AReason: string): Boolean;
    function ResolveToleranceSource(out AInfo: TGraphToleranceSourceInfo;
      out AReason: string): Boolean;
    function ValidateDevicePointsTolerance(const APointIndex: Integer;
      out AReferencePoint: TDevicePoint; out AReason: string): Boolean;
    procedure LogToleranceEvent(const AEventName, AReason,
      ADetails: string);
    procedure UpdateIndependentYAxis(const AGraphIndex: Integer);
    procedure RemoveRuntimeSeries(const AConfig: TGraphSeriesConfig;
      AChart: TSimpleChart);
    procedure RemoveGraphRuntimeSeries(const AGraphIndex: Integer);
    function SeriesSourceKey(const ASeries: TGraphSeriesConfig): string;
    procedure CaptureWorkspaceSample(const ASourceKey: string;
      const ASample: TMeterValueSample);
    function GetWorkspaceSegmentSamples(const ASourceKey: string): TArray<TMeterValueSample>;
    procedure ClearWorkspaceSegmentHistory;
    procedure LoadSeriesCurrentSegmentHistory(const AGraphIndex: Integer;
      ASeriesConfig: TGraphSeriesConfig; ARuntime: TGraphSeriesRuntime);
    procedure LoadGraphCurrentSegmentHistory(const AGraphIndex: Integer);
  public
    destructor Destroy; override;
    procedure Initialize(AWorkTable: TWorkTable);
    procedure UpdateGraphs;
    procedure ApplyLayout;
    procedure ClearGraph(const AGraphIndex: Integer);
    procedure ClearAllGraphs;
    procedure ResetRuntimeGraphData;
    procedure ResetGraphRuntimeData(const AGraphIndex: Integer);
    procedure Resize; override;
    function AddSource(const AGraphIndex: Integer;
      ASource: TGraphSeriesConfig): Boolean;
    procedure EnsureDefaultEnabledSources;
    procedure RefreshEnabledSources;
  end;

implementation

{$R *.fmx}

constructor TGraphSourceHistory.Create(const ASourceKey: string);
begin
  inherited Create;
  SourceKey := ASourceKey;
  Samples := TList<TMeterValueSample>.Create;
end;

destructor TGraphSourceHistory.Destroy;
begin
  Samples.Free;
  inherited;
end;

destructor TGraphVisualSlot.Destroy;
begin
  RootLayout.Free;
  inherited;
end;

destructor TFrameGraphsWorkspace.Destroy;
begin
  { Slots own the controls parented to LayoutGraphsHost and must go first. }
  FGraphSlots.Free;
  FSegmentHistory.Free;
  FToleranceDiagnosticTimes.Free;
  FSeriesRuntime.Free;
  FConfig.Free;
  inherited;
end;

procedure TFrameGraphsWorkspace.Initialize(AWorkTable: TWorkTable);
var
  FirstInitialization: Boolean;
  PointIndex: Integer;
begin
  if PopupMenuGraph = nil then
    raise EInvalidOperation.Create('PopupMenuGraph не загружен из frmGraphsWorkspace.fmx');
  FWorkTable := AWorkTable;
  FirstInitialization := FConfig = nil;
  if FConfig = nil then
  begin
    FConfig := TGraphsViewConfig.Create;
    FGraphSlots := TObjectList<TGraphVisualSlot>.Create(True);
    FSeriesRuntime := TObjectDictionary<TGraphSeriesConfig,
      TGraphSeriesRuntime>.Create([doOwnsValues]);
    FSegmentHistory := TObjectDictionary<string, TGraphSourceHistory>.Create([doOwnsValues]);
    FSelectedGraph := 0;
    FContextGraphIndex := 0;
    FLastPointIndex := -1;
    FSharedAxisMinX := 0;
    FSharedAxisMaxX := 60;
    FRuntimeResetTimeMs := TMeterValue.GetMonotonicTimeMs;
    FToleranceDiagnosticTimes := TDictionary<string, Int64>.Create;
    FLastLayoutColumns := -1;
    FLastLayoutRows := -1;
    FLastLayoutGraphCount := -1;
  end;
  EnsureGraphSlotCount(FConfig.GraphCount);
  SyncControls;
  ApplyDynamicGridLayout;
  if FirstInitialization then
  begin
    FLastPointKey := CurrentPointKey(PointIndex);
    FLastPointIndex := PointIndex;
    ApplySharedXAxis;
    UpdateToleranceLines;
  end;
  EnsureDefaultEnabledSources;
end;

function TFrameGraphsWorkspace.CreateGraphSlot(
  const AGraphIndex: Integer): TGraphVisualSlot;
begin
  Result := TGraphVisualSlot.Create;
  Result.GraphIndex := AGraphIndex;
  Result.RootLayout := TLayout.Create(nil);
  Result.RootLayout.Parent := LayoutGraphsHost;
  Result.RootLayout.Align := TAlignLayout.None;
  Result.RootLayout.ClipChildren := True;
  Result.RootLayout.Tag := AGraphIndex;

  Result.HeaderLayout := TLayout.Create(Result.RootLayout);
  Result.HeaderLayout.Parent := Result.RootLayout;
  Result.HeaderLayout.Align := TAlignLayout.Top;
  Result.HeaderLayout.Height := 28;
  Result.TitleLabel := TLabel.Create(Result.HeaderLayout);
  Result.TitleLabel.Parent := Result.HeaderLayout;
  Result.TitleLabel.Align := TAlignLayout.Client;
  Result.TitleLabel.Text := Format('График %d', [AGraphIndex + 1]);
  Result.TitleLabel.TextSettings.HorzAlign := TTextAlign.Center;
  Result.TitleLabel.Tag := AGraphIndex;
  Result.TitleLabel.OnMouseDown := GraphControlMouseDown;

  Result.Chart := TSimpleChart.Create(Result.RootLayout);
  Result.Chart.Parent := Result.RootLayout;
  Result.Chart.Align := TAlignLayout.Client;
  Result.Chart.ClipParent := True;
  Result.Chart.Tag := AGraphIndex;
  Result.Chart.Title := Result.TitleLabel.Text;
  Result.Chart.XTitle := 'Время, с';
  Result.Chart.YTitle := 'Расход, ' + GetCurrentFlowUnitText;
  Result.Chart.OnMouseDown := GraphControlMouseDown;
  { No full-size HitControl: it would consume legend interaction.  The chart
    receives right clicks directly. }
  Result.HitControl := nil;
  FGraphSlots.Add(Result);
  EnsureLimitSeries(AGraphIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSlotCreated',
      'Создан динамический слот графика', Format('GraphIndex=%d; GraphCount=%d',
      [AGraphIndex, FGraphSlots.Count]));
end;

procedure TFrameGraphsWorkspace.DestroyGraphSlot(const AGraphIndex: Integer);
begin
  if (FGraphSlots = nil) or (AGraphIndex < 0) or
     (AGraphIndex >= FGraphSlots.Count) then Exit;
  FGraphSlots.Delete(AGraphIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSlotDestroyed',
      'Удалён динамический слот графика', Format('GraphIndex=%d; GraphCount=%d',
      [AGraphIndex, FGraphSlots.Count]));
end;

procedure TFrameGraphsWorkspace.EnsureGraphSlotCount(const ACount: Integer);
begin
  if FGraphSlots = nil then Exit;
  while FGraphSlots.Count < Max(0, ACount) do
    CreateGraphSlot(FGraphSlots.Count);
  while FGraphSlots.Count > Max(0, ACount) do
    DestroyGraphSlot(FGraphSlots.Count - 1);
  ReindexGraphSlots;
end;

procedure TFrameGraphsWorkspace.ReindexGraphSlots;
var I: Integer; Slot: TGraphVisualSlot;
begin
  if FGraphSlots = nil then Exit;
  for I := 0 to FGraphSlots.Count - 1 do
  begin
    Slot := FGraphSlots[I];
    Slot.GraphIndex := I;
    Slot.RootLayout.Tag := I;
    Slot.TitleLabel.Tag := I;
    Slot.Chart.Tag := I;
    if Slot.HitControl <> nil then Slot.HitControl.Tag := I;
    Slot.TitleLabel.Text := Format('График %d', [I + 1]);
    Slot.Chart.Title := Slot.TitleLabel.Text;
  end;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSlotsReindexed',
      'Переиндексированы слоты графиков', Format('GraphCount=%d', [FGraphSlots.Count]));
end;

function TFrameGraphsWorkspace.GraphSlotByIndex(
  const AIndex: Integer): TGraphVisualSlot;
begin
  Result := nil;
  if (FGraphSlots <> nil) and (AIndex >= 0) and (AIndex < FGraphSlots.Count) then
    Result := FGraphSlots[AIndex];
end;

function TFrameGraphsWorkspace.ChartByIndex(
  const AIndex: Integer): TSimpleChart;
var Slot: TGraphVisualSlot;
begin
  Result := nil;
  Slot := GraphSlotByIndex(AIndex);
  if Slot <> nil then Result := Slot.Chart;
end;

procedure TFrameGraphsWorkspace.CalculateDynamicGrid(const AGraphCount: Integer;
  const AAvailableWidth: Single; out AColumns, ARows: Integer);
var MaxColumnsByWidth: Integer; MinimumWidth: Single;
begin
  AColumns := 0; ARows := 0;
  if AGraphCount <= 0 then Exit;
  MinimumWidth := Max(1, FConfig.MinimumGraphWidth);
  MaxColumnsByWidth := Max(1, Floor(Max(0, AAvailableWidth) / MinimumWidth));
  if FConfig.AutoGrid or (FConfig.PreferredColumnCount <= 0) then
    AColumns := Min(MaxColumnsByWidth, AGraphCount)
  else
    AColumns := Min(Min(FConfig.PreferredColumnCount, MaxColumnsByWidth), AGraphCount);
  AColumns := Max(1, AColumns);
  ARows := (AGraphCount + AColumns - 1) div AColumns;
end;

procedure TFrameGraphsWorkspace.ApplyDynamicGridLayout;
const HorizontalPadding = 8; VerticalPadding = 8;
  HorizontalSpacing = 8; VerticalSpacing = 8;
var I, Columns, Rows, ColumnIndex, RowIndex: Integer;
  AvailableWidth, AvailableHeight, GraphWidth, GraphHeight, ContentHeight: Single;
  Slot: TGraphVisualSlot; Changed, ScrollRequired: Boolean;
begin
  if FApplyingLayout or (FConfig = nil) or (FGraphSlots = nil) then Exit;
  FApplyingLayout := True;
  try
    EnsureGraphSlotCount(FConfig.GraphCount);
    AvailableWidth := Max(0, ScrollBoxGraphs.Width - HorizontalPadding * 2);
    AvailableHeight := Max(0, ScrollBoxGraphs.Height - VerticalPadding * 2);
    CalculateDynamicGrid(FGraphSlots.Count, AvailableWidth, Columns, Rows);
    if Columns = 0 then Exit;
    GraphWidth := Max(1, (AvailableWidth - Max(0, Columns - 1) * HorizontalSpacing) / Columns);
    GraphHeight := Max(FConfig.MinimumGraphHeight,
      (AvailableHeight - Max(0, Rows - 1) * VerticalSpacing) / Max(1, Rows));
    ContentHeight := VerticalPadding * 2 + Rows * GraphHeight +
      Max(0, Rows - 1) * VerticalSpacing;
    Changed := (Columns <> FLastLayoutColumns) or (Rows <> FLastLayoutRows) or
      (FGraphSlots.Count <> FLastLayoutGraphCount) or
      (Abs(GraphWidth - FLastGraphCellWidth) > 1) or
      (Abs(GraphHeight - FLastGraphCellHeight) > 1);
    for I := 0 to FGraphSlots.Count - 1 do
    begin
      Slot := FGraphSlots[I]; ColumnIndex := I mod Columns; RowIndex := I div Columns;
      Slot.RootLayout.Position.X := HorizontalPadding + ColumnIndex * (GraphWidth + HorizontalSpacing);
      Slot.RootLayout.Position.Y := VerticalPadding + RowIndex * (GraphHeight + VerticalSpacing);
      Slot.RootLayout.Width := GraphWidth; Slot.RootLayout.Height := GraphHeight;
      Slot.Chart.ShowLegend := FConfig.Panels[I].ShowLegend;
    end;
    LayoutGraphsHost.Width := AvailableWidth + HorizontalPadding * 2;
    LayoutGraphsHost.Height := Max(1, ContentHeight);
    ScrollRequired := ContentHeight > ScrollBoxGraphs.Height;
    if Changed and Assigned(ProtocolManager) then
    begin
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphDynamicLayoutCalculated',
        'Рассчитана динамическая сетка графиков', Format(
        'GraphCount=%d; AvailableWidth=%g; AvailableHeight=%g; AutoGrid=%s; PreferredColumnCount=%d; CalculatedColumns=%d; CalculatedRows=%d; GraphWidth=%g; GraphHeight=%g',
        [FGraphSlots.Count, AvailableWidth, AvailableHeight, BoolToStr(FConfig.AutoGrid, True),
         FConfig.PreferredColumnCount, Columns, Rows, GraphWidth, GraphHeight]));
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphDynamicLayoutApplied',
        'Применена динамическая сетка графиков', Format(
        'GraphCount=%d; Columns=%d; Rows=%d; ContentHeight=%g; ScrollRequired=%s',
        [FGraphSlots.Count, Columns, Rows, ContentHeight, BoolToStr(ScrollRequired, True)]));
    end;
    FLastLayoutColumns := Columns; FLastLayoutRows := Rows;
    FLastLayoutGraphCount := FGraphSlots.Count;
    FLastGraphCellWidth := GraphWidth; FLastGraphCellHeight := GraphHeight;
    ApplySharedXAxis;
  finally
    FApplyingLayout := False;
  end;
end;

procedure TFrameGraphsWorkspace.ApplyLayout;
begin
  ApplyDynamicGridLayout;
end;

procedure TFrameGraphsWorkspace.Resize;
begin
  inherited;
  ApplyDynamicGridLayout;
end;

procedure TFrameGraphsWorkspace.SyncControls;
begin
  FUpdatingControls := True;
  try
    if FConfig.AutoGrid then ComboGraphLayout.ItemIndex := 0
    else ComboGraphLayout.ItemIndex := EnsureRange(FConfig.PreferredColumnCount, 1, 6);
  finally
    FUpdatingControls := False;
  end;
end;



procedure TFrameGraphsWorkspace.GraphLayoutChange(Sender: TObject);
begin
  if FUpdatingControls or (FConfig = nil) then Exit;
  if ComboGraphLayout.ItemIndex <= 0 then
  begin FConfig.AutoGrid := True; FConfig.PreferredColumnCount := 0 end
  else
  begin FConfig.AutoGrid := False; FConfig.PreferredColumnCount := ComboGraphLayout.ItemIndex end;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphColumnModeChanged', 'Изменён режим колонок графиков', Format(
    'AutoGrid=%s; PreferredColumnCount=%d', [BoolToStr(FConfig.AutoGrid, True),
     FConfig.PreferredColumnCount]));
  ApplyDynamicGridLayout;
end;



procedure TFrameGraphsWorkspace.SelectGraph(const AIndex: Integer);
begin
  if (FConfig = nil) or (AIndex < 0) or (AIndex >= FConfig.GraphCount) then Exit;
  FSelectedGraph := AIndex;
end;

procedure TFrameGraphsWorkspace.GraphControlMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  GraphHitMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFrameGraphsWorkspace.GraphHitMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  P: TPointF;
  EtalonCount, DeviceCount, GraphIndex: Integer;
begin
  if not (Sender is TControl) then
    Exit;
  if FConfig = nil then
    Exit;
  GraphIndex := TControl(Sender).Tag;
  if (GraphIndex < 0) or (GraphIndex >= FConfig.GraphCount) then
    Exit;
  SelectGraph(GraphIndex);
  if Button = TMouseButton.mbRight then
  begin
    if PopupMenuGraph = nil then
      raise EInvalidOperation.Create(
        'PopupMenuGraph не загружен из frmGraphsWorkspace.fmx');
    FContextGraphIndex := GraphIndex;
    BuildSourceMenu(EtalonCount, DeviceCount);
    BuildSeriesColorsMenu;
    UpdateGraphSettingsMenu;
    P := TControl(Sender).LocalToScreen(PointF(X, Y));
    PopupMenuGraph.Popup(P.X, P.Y);
  end;
end;

procedure TFrameGraphsWorkspace.ClearDynamicMenu(AParent: TMenuItem);
var
  Item: TMenuItem;
begin
  if AParent = nil then Exit;
  while AParent.ItemsCount > 0 do
  begin
    Item := TMenuItem(AParent.Items[AParent.ItemsCount - 1]);
    Item.Free;
  end;
end;

procedure TFrameGraphsWorkspace.AddEmptyMenuItem(AParent: TMenuItem;
  const ACaption: string);
var Item: TMenuItem;
begin
  if AParent = nil then raise EArgumentNilException.Create('AParent');
  Item := TMenuItem.Create(nil);
  Item.Text := ACaption;
  Item.Enabled := False;
  AParent.AddObject(Item);
end;

procedure TFrameGraphsWorkspace.AddChannelMenuItem(AParent: TMenuItem;
  AChannel: TChannel; const AOwnerKind: TGraphSeriesOwnerKind);
var Item: TGraphSourceMenuItem;
begin
  if AParent = nil then raise EArgumentNilException.Create('AParent');
  if AChannel = nil then raise EArgumentNilException.Create('AChannel');
  Item := TGraphSourceMenuItem.Create(nil);
  Item.GraphIndex := FContextGraphIndex;
  Item.OwnerKind := AOwnerKind;
  Item.SourceKind := gskFlow;
  Item.ChannelUUID := AChannel.UUID;
  Item.MeterValueKey := 'ValueFlow';
  Item.Serial := Trim(AChannel.Serial);
  Item.SourceCaption := Trim(AChannel.Name);
  if Item.SourceCaption = '' then Item.SourceCaption := Trim(AChannel.Text);
  if Item.Serial <> '' then Item.Text := Format('%s — %s', [Item.Serial, Item.SourceCaption])
  else Item.Text := Item.SourceCaption;
  Item.SourceCaption := Item.Text;
  Item.IsChecked := FindSeries(FContextGraphIndex, Item.ChannelUUID, Item.MeterValueKey) <> nil;
  Item.OnClick := SourceMenuItemClick;
  AParent.AddObject(Item);
end;

procedure TFrameGraphsWorkspace.BuildSourceMenu(out AEtalonCount,
  ADeviceCount: Integer);
var Channel: TChannel;
begin
  AEtalonCount := 0; ADeviceCount := 0;
  ClearDynamicMenu(MenuItemEtalons); ClearDynamicMenu(MenuItemDevices);
  if FWorkTable <> nil then
  begin
    if FWorkTable.EtalonChannels <> nil then
      for Channel in FWorkTable.EtalonChannels do
        if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) then
        begin AddChannelMenuItem(MenuItemEtalons, Channel, gsokEtalon); Inc(AEtalonCount) end;
    if FWorkTable.DeviceChannels <> nil then
      for Channel in FWorkTable.DeviceChannels do
        if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) then
        begin AddChannelMenuItem(MenuItemDevices, Channel, gsokDevice); Inc(ADeviceCount) end;
  end;
  if AEtalonCount = 0 then AddEmptyMenuItem(MenuItemEtalons, 'Нет включённых эталонов');
  if ADeviceCount = 0 then AddEmptyMenuItem(MenuItemDevices, 'Нет включённых приборов');
  MenuItemEtalons.Enabled := AEtalonCount > 0;
  MenuItemDevices.Enabled := ADeviceCount > 0;
end;

procedure TFrameGraphsWorkspace.SourceMenuItemClick(Sender: TObject);
var
  Item: TGraphSourceMenuItem;
  Source, Existing: TGraphSeriesConfig;
  Added: Boolean;
begin
  if not (Sender is TGraphSourceMenuItem) then Exit;
  if FConfig = nil then Exit;
  Item := TGraphSourceMenuItem(Sender);
  if (Item.GraphIndex < 0) or (Item.GraphIndex >= FConfig.GraphCount) then Exit;
  Existing := FindSeries(Item.GraphIndex, Item.ChannelUUID, Item.MeterValueKey);
  if Existing <> nil then
  begin
    DeleteSource(Item.GraphIndex, Existing);
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceRemoved',
        'Источник удалён из графика',
        Format('GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s',
          [Item.GraphIndex, Item.ChannelUUID, Item.MeterValueKey]));
    Exit;
  end;
  Source := TGraphSeriesConfig.Create;
  Source.OwnerKind := Item.OwnerKind;
  Source.SourceKind := Item.SourceKind;
  Source.ChannelUUID := Item.ChannelUUID;
  Source.MeterValueKey := Item.MeterValueKey;
  Source.Caption := Item.SourceCaption;
  Source.Color := NextSeriesColor(Item.GraphIndex);
  Added := AddSource(Item.GraphIndex, Source);
  SelectGraph(Item.GraphIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceAdded',
      'Источник добавлен в график',
      Format('GraphIndex=%d; SourceKind=%d; Serial=%s; ChannelUUID=%s; MeterValueKey=%s; Existing=%s',
        [Item.GraphIndex, Ord(Item.OwnerKind), Item.Serial, Item.ChannelUUID,
         Item.MeterValueKey, BoolToStr(not Added, True)]));
end;

function TFrameGraphsWorkspace.FindSeries(const AGraphIndex: Integer;
  const AChannelUUID, AMeterValueKey: string): TGraphSeriesConfig;
var
  S: TGraphSeriesConfig;
begin
  Result := nil;
  if (FConfig = nil) or (AGraphIndex < 0) or
     (AGraphIndex >= FConfig.Panels.Count) then Exit;
  for S in FConfig.Panels[AGraphIndex].Series do
    if (NormalizeUUID(S.ChannelUUID) = NormalizeUUID(AChannelUUID)) and
       SameText(S.MeterValueKey, AMeterValueKey) then Exit(S);
end;

function TFrameGraphsWorkspace.NextSeriesColor(
  const AGraphIndex: Integer): TAlphaColor;
const
  Palette: array[0..9] of TAlphaColor = ($FFFF3030, $FF2878D0,
    $FF20A050, $FFFF8C20, $FF8848C0, $FF20A8A8, $FFE0C020, $FFE85090,
    $FF808080, $FF202020);
var
  I: Integer;
  S: TGraphSeriesConfig;
  Used: Boolean;
begin
  Result := Palette[0];
  for I := Low(Palette) to High(Palette) do
  begin
    Used := False;
    for S in FConfig.Panels[AGraphIndex].Series do
      if S.Color = Palette[I] then begin Used := True; Break end;
    if not Used then Exit(Palette[I]);
  end;
  Result := Palette[FConfig.Panels[AGraphIndex].Series.Count mod Length(Palette)];
end;

procedure TFrameGraphsWorkspace.DeleteSource(const AGraphIndex: Integer;
  ASeries: TGraphSeriesConfig);
var
  Chart: TSimpleChart;
begin
  if ASeries = nil then Exit;
  Chart := ChartByIndex(AGraphIndex);
  RemoveRuntimeSeries(ASeries, Chart);
  FConfig.Panels[AGraphIndex].Series.Remove(ASeries);
  if Chart <> nil then Chart.InvalidateChart;
end;

procedure TFrameGraphsWorkspace.BuildSeriesColorsMenu;
const
  ColorNames: array[0..9] of string = ('Красный', 'Синий', 'Зелёный',
    'Оранжевый', 'Фиолетовый', 'Бирюзовый', 'Жёлтый', 'Розовый',
    'Серый', 'Чёрный');
  Colors: array[0..9] of TAlphaColor = ($FFFF3030, $FF2878D0,
    $FF20A050, $FFFF8C20, $FF8848C0, $FF20A8A8, $FFE0C020, $FFE85090,
    $FF808080, $FF202020);
var
  S: TGraphSeriesConfig;
  SeriesItem: TMenuItem;
  ColorItem: TGraphSeriesColorMenuItem;
  I: Integer;
begin
  ClearDynamicMenu(MenuItemSeriesColors);
  MenuItemSeriesColors.Enabled := (FConfig <> nil) and
    (FContextGraphIndex < FConfig.Panels.Count) and
    (FConfig.Panels[FContextGraphIndex].Series.Count > 0);
  if not MenuItemSeriesColors.Enabled then
  begin
    AddEmptyMenuItem(MenuItemSeriesColors, 'Нет добавленных серий');
    Exit;
  end;
  for S in FConfig.Panels[FContextGraphIndex].Series do
  begin
    SeriesItem := TMenuItem.Create(nil);
    SeriesItem.Text := S.Caption;
    MenuItemSeriesColors.AddObject(SeriesItem);
    for I := Low(Colors) to High(Colors) do
    begin
      ColorItem := TGraphSeriesColorMenuItem.Create(nil);
      ColorItem.Text := ColorNames[I];
      ColorItem.GraphIndex := FContextGraphIndex;
      ColorItem.ChannelUUID := S.ChannelUUID;
      ColorItem.MeterValueKey := S.MeterValueKey;
      ColorItem.NewColor := Colors[I];
      ColorItem.IsChecked := S.Color = Colors[I];
      ColorItem.OnClick := SeriesColorClick;
      SeriesItem.AddObject(ColorItem);
    end;
  end;
end;

procedure TFrameGraphsWorkspace.UpdateGraphSettingsMenu;
const
  Durations: array[0..6] of Integer = (30, 60, 120, 300, 600, 1800, 0);
  Captions: array[0..6] of string = ('30 секунд', '1 минута', '2 минуты',
    '5 минут', '10 минут', '30 минут', 'Без ограничения');
var
  I: Integer;
  Item: TGraphDurationMenuItem;
  LayoutItem: TGraphColumnMenuItem;
begin
  ClearDynamicMenu(MenuItemLayout);
  for I := 0 to 6 do
  begin
    LayoutItem := TGraphColumnMenuItem.Create(nil);
    LayoutItem.ColumnCount := I;
    if I = 0 then LayoutItem.Text := 'Автоматически'
    else LayoutItem.Text := Format('%d столбцов', [I]);
    LayoutItem.IsChecked := (FConfig.AutoGrid and (I = 0)) or
      ((not FConfig.AutoGrid) and (FConfig.PreferredColumnCount = I));
    LayoutItem.OnClick := GraphColumnModeClick;
    MenuItemLayout.AddObject(LayoutItem);
  end;
  ClearDynamicMenu(MenuItemGraphLength);
  for I := Low(Durations) to High(Durations) do
  begin
    Item := TGraphDurationMenuItem.Create(nil);
    Item.Text := Captions[I];
    Item.DurationSec := Durations[I];
    Item.IsChecked := FConfig.VisibleDurationSec = Durations[I];
    Item.OnClick := GraphDurationClick;
    MenuItemGraphLength.AddObject(Item);
  end;
  MenuItemFlowUnits.Text := 'Единицы расхода: ' + GetCurrentFlowUnitText;
  MenuItemShowLegend.IsChecked := FConfig.Panels[FContextGraphIndex].ShowLegend;
  MenuItemShowTargetLine.IsChecked :=
    FConfig.Panels[FContextGraphIndex].ShowTargetLine;
  MenuItemShowToleranceLines.IsChecked :=
    FConfig.Panels[FContextGraphIndex].ShowToleranceLines;
  MenuItemAddGraph.Enabled := True;
  MenuItemDeleteGraph.Enabled := FConfig.GraphCount > 1;
end;

procedure TFrameGraphsWorkspace.GraphColumnModeClick(Sender: TObject);
var Item: TGraphColumnMenuItem;
begin
  if not (Sender is TGraphColumnMenuItem) then Exit;
  Item := TGraphColumnMenuItem(Sender);
  FConfig.AutoGrid := Item.ColumnCount = 0;
  FConfig.PreferredColumnCount := Item.ColumnCount;
  SyncControls;
  ApplyDynamicGridLayout;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphColumnModeChanged', 'Изменён режим колонок графиков', Format(
    'AutoGrid=%s; PreferredColumnCount=%d', [BoolToStr(FConfig.AutoGrid, True),
     FConfig.PreferredColumnCount]));
end;

procedure TFrameGraphsWorkspace.ClearGraphValuesClick(Sender: TObject);
begin
  if (FConfig <> nil) and (FContextGraphIndex >= 0) and
     (FContextGraphIndex < FConfig.GraphCount) then
    ResetGraphRuntimeData(FContextGraphIndex);
end;

procedure TFrameGraphsWorkspace.SeriesColorClick(Sender: TObject);
var
  Item: TGraphSeriesColorMenuItem;
  S: TGraphSeriesConfig;
  Runtime: TGraphSeriesRuntime;
  OldColor: TAlphaColor;
begin
  if not (Sender is TGraphSeriesColorMenuItem) then Exit;
  Item := TGraphSeriesColorMenuItem(Sender);
  S := FindSeries(Item.GraphIndex, Item.ChannelUUID, Item.MeterValueKey);
  if S = nil then Exit;
  OldColor := S.Color;
  S.Color := Item.NewColor;
  if FSeriesRuntime.TryGetValue(S, Runtime) and (Runtime.ChartSeries <> nil) then
    Runtime.ChartSeries.Color := S.Color;
  ChartByIndex(Item.GraphIndex).InvalidateChart;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesColorChanged',
      'Изменён цвет серии графика', Format(
      'GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s; OldColor=%u; NewColor=%u',
      [Item.GraphIndex, Item.ChannelUUID, Item.MeterValueKey, OldColor, S.Color]));
end;

procedure TFrameGraphsWorkspace.GraphDurationClick(Sender: TObject);
var
  Item: TGraphDurationMenuItem;
  OldValue: Integer;
begin
  if not (Sender is TGraphDurationMenuItem) then Exit;
  Item := TGraphDurationMenuItem(Sender);
  OldValue := FConfig.VisibleDurationSec;
  FConfig.VisibleDurationSec := Item.DurationSec;
  CalculateSharedTimeRange(TMeterValue.GetMonotonicTimeMs);
  ApplySharedXAxis;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphVisibleDurationChanged',
      'Изменена длина графика', Format('GraphIndex=%d; OldValue=%d; NewValue=%d',
      [FContextGraphIndex, OldValue, Item.DurationSec]));
end;

procedure TFrameGraphsWorkspace.ShowLegendClick(Sender: TObject);
var
  Value: Boolean;
begin
  Value := not FConfig.Panels[FContextGraphIndex].ShowLegend;
  FConfig.Panels[FContextGraphIndex].ShowLegend := Value;
  ChartByIndex(FContextGraphIndex).ShowLegend := Value;
  ChartByIndex(FContextGraphIndex).InvalidateChart;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphLegendChanged',
      'Изменено отображение легенды', Format('GraphIndex=%d; ShowLegend=%s',
      [FContextGraphIndex, BoolToStr(Value, True)]));
end;

procedure TFrameGraphsWorkspace.ToleranceVisibilityClick(Sender: TObject);
var
  Panel: TGraphPanelConfig;
begin
  if (FConfig = nil) or (FContextGraphIndex < 0) or
     (FContextGraphIndex >= FConfig.Panels.Count) then Exit;
  Panel := FConfig.Panels[FContextGraphIndex];
  if Sender = MenuItemShowTargetLine then
    Panel.ShowTargetLine := not Panel.ShowTargetLine
  else if Sender = MenuItemShowToleranceLines then
    Panel.ShowToleranceLines := not Panel.ShowToleranceLines
  else
    Exit;
  UpdateToleranceLines;
  UpdateGraphSettingsMenu;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphToleranceVisibilityChanged',
      'Изменена видимость линий допуска', Format(
      'GraphIndex=%d; ShowTargetLine=%s; ShowToleranceLines=%s',
      [FContextGraphIndex, BoolToStr(Panel.ShowTargetLine, True),
       BoolToStr(Panel.ShowToleranceLines, True)]));
end;

procedure TFrameGraphsWorkspace.AddGraphClick(Sender: TObject);
var OldCount: Integer;
begin
  OldCount := FConfig.GraphCount;
  FConfig.EnsurePanelCount(OldCount + 1);
  CreateGraphSlot(OldCount);
  ApplyDynamicGridLayout; SelectGraph(FConfig.GraphCount - 1);
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphAdded', 'Добавлен график', Format('GraphIndex=%d; OldGraphCount=%d; NewGraphCount=%d',
    [FSelectedGraph, OldCount, FConfig.GraphCount]));
end;

procedure TFrameGraphsWorkspace.DeleteGraphClick(Sender: TObject);
var OldCount, DeletedIndex, I: Integer; S: TGraphSeriesConfig;
begin
  OldCount := FConfig.GraphCount;
  if OldCount <= 1 then Exit;
  DeletedIndex := FContextGraphIndex;
  if (DeletedIndex < 0) or (DeletedIndex >= OldCount) then Exit;
  RemoveGraphRuntimeSeries(DeletedIndex);
  FConfig.DeletePanel(DeletedIndex);
  DestroyGraphSlot(DeletedIndex);
  for I := DeletedIndex to FConfig.GraphCount - 1 do
    for S in FConfig.Panels[I].Series do S.GraphIndex := I;
  ReindexGraphSlots;
  ApplyDynamicGridLayout;
  SelectGraph(Min(DeletedIndex, FConfig.GraphCount - 1));
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphDeleted', 'Удалён график', Format('GraphIndex=%d; OldGraphCount=%d; NewGraphCount=%d',
    [DeletedIndex, OldCount, FConfig.GraphCount]));
end;

procedure TFrameGraphsWorkspace.GraphPopup(Sender: TObject);
var
  EtalonCount, DeviceCount: Integer;
begin
  BuildSourceMenu(EtalonCount, DeviceCount);
  BuildSeriesColorsMenu;
  UpdateGraphSettingsMenu;
end;



procedure TFrameGraphsWorkspace.ClearChart(const AIndex: Integer; const AClearAssignments: Boolean);
var Chart: TSimpleChart; I: Integer;
begin
  Chart := ChartByIndex(AIndex); if Chart = nil then Exit;
  for I := 0 to Chart.SeriesCount - 1 do Chart.Series[I].ClearPoints;
  Chart.InvalidateChart;
  if AClearAssignments and (FConfig <> nil) and
     (AIndex < FConfig.Panels.Count) then
  begin
    RemoveGraphRuntimeSeries(AIndex);
    FConfig.Panels[AIndex].Series.Clear;
    FConfig.Panels[AIndex].DefaultAssignmentSuppressed := True;
  end;
end;

procedure TFrameGraphsWorkspace.RefreshEnabledSources;
var
  Channel: TChannel;
  Source, Existing: TGraphSeriesConfig;
  Runtime: TGraphSeriesRuntime;
  GraphIndex, AddedCount, ExistingCount, UnavailableCount,
    EtalonsEnabled, DevicesEnabled: Integer;
  Caption: string;

  procedure Synchronize(AChannel: TChannel; AOwner: TGraphSeriesOwnerKind);
  begin
    if (AChannel = nil) or not AChannel.Enabled then Exit;
    if AOwner = gsokEtalon then Inc(EtalonsEnabled) else Inc(DevicesEnabled);
    if FConfig.GraphCount = 1 then GraphIndex := 0
    else if AOwner = gsokEtalon then GraphIndex := 0 else GraphIndex := 1;
    if FConfig.Panels[GraphIndex].DefaultAssignmentSuppressed then Exit;
    if (Trim(AChannel.UUID) = '') or (AChannel.FlowMeter = nil) or
       (AChannel.FlowMeter.ValueFlow = nil) then
    begin
      Inc(UnavailableCount);
      if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
        'GraphDefaultSourceUnavailable', 'Источник графика недоступен',
        Format('GraphIndex=%d; ChannelUUID=%s', [GraphIndex, AChannel.UUID]));
      Exit;
    end;
    Existing := FindSeries(GraphIndex, NormalizeUUID(AChannel.UUID), 'ValueFlow');
    if Existing <> nil then
    begin
      Inc(ExistingCount);
      if FSeriesRuntime.TryGetValue(Existing, Runtime) and
         (Runtime.ChartSeries <> nil) then Runtime.ChartSeries.Visible := True;
      Exit;
    end;
    Caption := Trim(AChannel.Name);
    if Caption = '' then Caption := Trim(AChannel.Text);
    if Trim(AChannel.Serial) <> '' then
      Caption := Format('%s — %s', [Trim(AChannel.Serial), Caption]);
    Source := TGraphSeriesConfig.Create;
    Source.OwnerKind := AOwner;
    Source.SourceKind := gskFlow;
    Source.ChannelUUID := AChannel.UUID;
    Source.MeterValueKey := 'ValueFlow';
    Source.Caption := Caption;
    Source.Color := NextSeriesColor(GraphIndex);
    Source.Visible := True;
    if AddSource(GraphIndex, Source) then
    begin
      Inc(AddedCount);
      if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
        'GraphDefaultSourceAdded', 'Добавлен источник графика по умолчанию',
        Format('GraphIndex=%d; OwnerKind=%d; ChannelUUID=%s; Caption=%s; MeterValueKey=ValueFlow',
          [GraphIndex, Ord(AOwner), AChannel.UUID, Caption]));
    end;
  end;

begin
  if (FConfig = nil) or (FWorkTable = nil) then Exit;
  AddedCount := 0; ExistingCount := 0; UnavailableCount := 0;
  EtalonsEnabled := 0; DevicesEnabled := 0;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphDefaultSourcesRefreshBegin', 'Начата синхронизация источников графиков',
    Format('GraphCount=%d', [FConfig.GraphCount]));
  if FWorkTable.EtalonChannels <> nil then
    for Channel in FWorkTable.EtalonChannels do Synchronize(Channel, gsokEtalon);
  if FWorkTable.DeviceChannels <> nil then
    for Channel in FWorkTable.DeviceChannels do Synchronize(Channel, gsokDevice);
  { Existing assignments remain intact when a channel is disabled. }
  for GraphIndex := 0 to FConfig.GraphCount - 1 do
    for Existing in FConfig.Panels[GraphIndex].Series do
      if FSeriesRuntime.TryGetValue(Existing, Runtime) and
         (Runtime.ChartSeries <> nil) then
      begin
        Channel := ResolveChannel(Existing);
        Runtime.ChartSeries.Visible := Existing.Visible and (Channel <> nil) and
          Channel.Enabled and (Channel.FlowMeter <> nil) and
          (Channel.FlowMeter.ValueFlow <> nil);
      end;
  FDefaultSourcesInitialized := (EtalonsEnabled + DevicesEnabled) > 0;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphDefaultSourcesRefreshDone', 'Завершена синхронизация источников графиков',
    Format('EtalonsEnabled=%d; DevicesEnabled=%d; AddedCount=%d; ExistingCount=%d; UnavailableCount=%d; GraphCount=%d',
      [EtalonsEnabled, DevicesEnabled, AddedCount, ExistingCount,
       UnavailableCount, FConfig.GraphCount]));
end;

procedure TFrameGraphsWorkspace.EnsureDefaultEnabledSources;
begin
  if not FDefaultSourcesInitialized then RefreshEnabledSources;
end;

procedure TFrameGraphsWorkspace.ClearGraph(const AGraphIndex: Integer);
begin ClearChart(AGraphIndex, True); UpdateToleranceLines end;
procedure TFrameGraphsWorkspace.ClearAllGraphs;
var I: Integer; begin if FConfig <> nil then begin for I := 0 to FConfig.GraphCount - 1 do ClearChart(I, True); UpdateToleranceLines end end;
procedure TFrameGraphsWorkspace.ClearAllClick(Sender: TObject); begin ClearAllGraphs end;
procedure TFrameGraphsWorkspace.ClearGraphClick(Sender: TObject);
begin
  ClearGraph(FContextGraphIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphCleared',
      'График очищен', Format('GraphIndex=%d', [FContextGraphIndex]));
end;
procedure TFrameGraphsWorkspace.ResetClick(Sender: TObject); begin ResetRuntimeGraphData end;

function TFrameGraphsWorkspace.AddSource(const AGraphIndex: Integer; ASource: TGraphSeriesConfig): Boolean;
var
  Chart: TSimpleChart;
  Series: TChartSeries;
begin
  Result := False;
  if (ASource = nil) or (FConfig = nil) or (AGraphIndex < 0) or (AGraphIndex >= FConfig.Panels.Count) then Exit;
  ASource.GraphIndex := AGraphIndex;
  Result := FConfig.Panels[AGraphIndex].AddSeries(ASource);
  if not Result then
    ASource.Free
  else
  begin
    Chart := ChartByIndex(AGraphIndex);
    if Chart <> nil then
    begin
      Series := Chart.AddSeries(ASource.Caption);
      Series.Color := ASource.Color;
      Series.Visible := True;
      if FSeriesRuntime = nil then
        FSeriesRuntime := TObjectDictionary<TGraphSeriesConfig,
          TGraphSeriesRuntime>.Create([doOwnsValues]);
      FSeriesRuntime.Add(ASource, TGraphSeriesRuntime.Create);
      FSeriesRuntime[ASource].ChartSeries := Series;
      FSeriesRuntime[ASource].LastSampleIndex := -1;
      FSeriesRuntime[ASource].LastSampleTimeMs := 0;
      FSeriesRuntime[ASource].WaitingForFirstSample := True;
      FSeriesRuntime[ASource].RuntimeResetTimeMs := 0;
      FSeriesRuntime[ASource].HistoryLoadMode := ghlmCurrentSegmentHistory;
      FSeriesRuntime[ASource].HistoryLoaded := False;
      LoadSeriesCurrentSegmentHistory(AGraphIndex, ASource,
        FSeriesRuntime[ASource]);
      Chart.InvalidateChart;
    end;
  end;
end;













function TFrameGraphsWorkspace.ResolveChannel(
  const ASeries: TGraphSeriesConfig): TChannel;
var
  Channel: TChannel;
begin
  Result := nil;
  if (ASeries = nil) or (FWorkTable = nil) then
    Exit;
  if (ASeries.OwnerKind = gsokEtalon) and
     (FWorkTable.EtalonChannels <> nil) then
    for Channel in FWorkTable.EtalonChannels do
      if (Channel <> nil) and
         (NormalizeUUID(Channel.UUID) = NormalizeUUID(ASeries.ChannelUUID)) then
        Exit(Channel);
  if (ASeries.OwnerKind = gsokDevice) and
     (FWorkTable.DeviceChannels <> nil) then
    for Channel in FWorkTable.DeviceChannels do
      if (Channel <> nil) and
         (NormalizeUUID(Channel.UUID) = NormalizeUUID(ASeries.ChannelUUID)) then
        Exit(Channel);
end;

function TFrameGraphsWorkspace.ResolveMeterValue(
  const ASeries: TGraphSeriesConfig; AChannel: TChannel): TMeterValue;
begin
  Result := nil;
  if (ASeries = nil) or (FWorkTable = nil) then
    Exit;
  if ASeries.OwnerKind = gsokWorkTable then
  begin
    if SameText(ASeries.MeterValueKey, 'ValueFlow') or
       SameText(ASeries.MeterValueKey, 'FlowRate') then
      Result := FWorkTable.ValueFlowRate
    else if SameText(ASeries.MeterValueKey, 'ValueQuantity') then
      Result := FWorkTable.ValueQuantity;
    Exit;
  end;
  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;
  if SameText(ASeries.MeterValueKey, 'ValueFlow') or
     SameText(ASeries.MeterValueKey, 'FlowRate') then
    Result := AChannel.FlowMeter.ValueFlow
  else if SameText(ASeries.MeterValueKey, 'ValueQuantity') or
          SameText(ASeries.MeterValueKey, 'Volume') or
          SameText(ASeries.MeterValueKey, 'Mass') then
    Result := AChannel.FlowMeter.ValueQuantity;
end;

function TFrameGraphsWorkspace.NormalizeUUID(const AValue: string): string;
begin
  Result := LowerCase(Trim(AValue));
  if (Length(Result) >= 2) and (Result[1] = '{') and
     (Result[Length(Result)] = '}') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function TFrameGraphsWorkspace.ResolveSeriesSource(
  ASeriesConfig: TGraphSeriesConfig; out AChannel: TChannel;
  out AMeterValue: TMeterValue; out AReason: string): Boolean;
var
  Candidate: TChannel;
  WantedUUID: string;
begin
  Result := False;
  AChannel := nil;
  AMeterValue := nil;
  AReason := '';
  if ASeriesConfig = nil then
  begin
    AReason := 'ConfigMissing';
    Exit;
  end;
  if FWorkTable = nil then
  begin
    AReason := 'ChannelNotFound';
    Exit;
  end;
  WantedUUID := NormalizeUUID(ASeriesConfig.ChannelUUID);
  if (ASeriesConfig.OwnerKind = gsokEtalon) and
     (FWorkTable.EtalonChannels <> nil) then
  begin
    for Candidate in FWorkTable.EtalonChannels do
      if (Candidate <> nil) and
         (NormalizeUUID(Candidate.UUID) = WantedUUID) then
      begin
        AChannel := Candidate;
        Break;
      end;
  end
  else if (ASeriesConfig.OwnerKind = gsokDevice) and
          (FWorkTable.DeviceChannels <> nil) then
  begin
    for Candidate in FWorkTable.DeviceChannels do
      if (Candidate <> nil) and
         (NormalizeUUID(Candidate.UUID) = WantedUUID) then
      begin
        AChannel := Candidate;
        Break;
      end;
  end;
  if AChannel = nil then
  begin
    AReason := 'ChannelNotFound';
    Exit;
  end;
  AMeterValue := ResolveMeterValue(ASeriesConfig, AChannel);
  if AMeterValue = nil then
  begin
    AReason := 'MeterValueNotFound';
    Exit;
  end;
  Result := True;
end;

function TFrameGraphsWorkspace.EnsureVisualSeries(AGraphIndex: Integer;
  ASeriesConfig: TGraphSeriesConfig): TChartSeries;
var
  Runtime: TGraphSeriesRuntime;
  Chart: TSimpleChart;
begin
  Result := nil;
  if (ASeriesConfig = nil) or (FSeriesRuntime = nil) then
    Exit;
  if FSeriesRuntime.TryGetValue(ASeriesConfig, Runtime) and
     (Runtime <> nil) and (Runtime.ChartSeries <> nil) then
    Exit(Runtime.ChartSeries);
  Chart := ChartByIndex(AGraphIndex);
  if Chart = nil then
    Exit;
  Runtime := TGraphSeriesRuntime.Create;
  Runtime.ChartSeries := Chart.AddSeries(ASeriesConfig.Caption);
  Runtime.ChartSeries.Color := ASeriesConfig.Color;
  Runtime.ChartSeries.Visible := ASeriesConfig.Visible;
  Runtime.LastSampleIndex := -1;
  Runtime.LastSampleTimeMs := 0;
  Runtime.WaitingForFirstSample := True;
  Runtime.LastAcceptedPointKey := FLastPointKey;
  Runtime.RuntimeResetTimeMs := 0;
  Runtime.HistoryLoadMode := ghlmCurrentSegmentHistory;
  Runtime.HistoryLoaded := False;
  FSeriesRuntime.Add(ASeriesConfig, Runtime);
  Result := Runtime.ChartSeries;
end;

function TFrameGraphsWorkspace.GetSeriesSamples(AMeterValue: TMeterValue;
  out ASamples: TArray<TMeterValueSample>): Boolean;
begin
  SetLength(ASamples, 0);
  Result := AMeterValue <> nil;
  if Result then
  begin
    ASamples := AMeterValue.GetStabilitySamples;
    Result := Length(ASamples) > 0;
  end;
end;

function TFrameGraphsWorkspace.SeriesSourceKey(
  const ASeries: TGraphSeriesConfig): string;
begin
  Result := Format('%d|%s|%s|%s', [Ord(ASeries.OwnerKind),
    NormalizeUUID(ASeries.ChannelUUID), LowerCase(Trim(ASeries.MeterValueKey)),
    FLastPointKey]);
end;

procedure TFrameGraphsWorkspace.CaptureWorkspaceSample(const ASourceKey: string;
  const ASample: TMeterValueSample);
var History: TGraphSourceHistory; I: Integer;
begin
  if (FSegmentHistory = nil) or (ASample.TimeStampMs < FSharedSegmentStartMs) or
     (ASample.TimeStampMs < FRuntimeResetTimeMs) then Exit;
  if not FSegmentHistory.TryGetValue(ASourceKey, History) then
  begin
    History := TGraphSourceHistory.Create(ASourceKey);
    FSegmentHistory.Add(ASourceKey, History);
  end;
  for I := History.Samples.Count - 1 downto Max(0, History.Samples.Count - 8) do
    if History.Samples[I].TimeStampMs = ASample.TimeStampMs then Exit;
  History.Samples.Add(ASample);
end;

function TFrameGraphsWorkspace.GetWorkspaceSegmentSamples(
  const ASourceKey: string): TArray<TMeterValueSample>;
var History: TGraphSourceHistory;
begin
  SetLength(Result, 0);
  if (FSegmentHistory <> nil) and FSegmentHistory.TryGetValue(ASourceKey, History) then
    Result := History.Samples.ToArray;
end;

procedure TFrameGraphsWorkspace.ClearWorkspaceSegmentHistory;
begin
  if FSegmentHistory <> nil then FSegmentHistory.Clear;
end;

procedure TFrameGraphsWorkspace.LoadSeriesCurrentSegmentHistory(
  const AGraphIndex: Integer; ASeriesConfig: TGraphSeriesConfig;
  ARuntime: TGraphSeriesRuntime);
var Channel: TChannel; MeterValue: TMeterValue; Samples: TArray<TMeterValueSample>;
  Sample: TMeterValueSample; SourceKey, HistorySource, Reason: string;
  EffectiveStartMs, FirstTime, LastTime: Int64;
  I, Added, Skipped: Integer; X, Y, FirstX, LastX: Double;
begin
  if (ARuntime = nil) or ARuntime.HistoryLoaded then Exit;
  if ARuntime.HistoryLoadMode = ghlmAfterLocalReset then
  begin
    ARuntime.HistoryLoaded := True;
    Exit;
  end;
  if not ResolveSeriesSource(ASeriesConfig, Channel, MeterValue, Reason) then Exit;
  SourceKey := SeriesSourceKey(ASeriesConfig);
  Samples := GetWorkspaceSegmentSamples(SourceKey);
  HistorySource := 'WorkspaceArchive';
  if Length(Samples) = 0 then
  begin
    Samples := MeterValue.GetStabilitySamples;
    HistorySource := 'MeterValueBuffer';
    for Sample in Samples do CaptureWorkspaceSample(SourceKey, Sample);
    if (Length(Samples) > 0) and Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSegmentHistoryCaptured',
        'Отсчёты источника сохранены в общем архиве сегмента', Format(
        'SourceKey=%s; CapturedCount=%d', [SourceKey, Length(Samples)]));
  end;
  EffectiveStartMs := Max(FSharedSegmentStartMs, FRuntimeResetTimeMs);
  Added := 0; Skipped := 0; FirstTime := 0; LastTime := 0; FirstX := 0; LastX := 0;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphSeriesHistoryLoadBegin', 'Начата загрузка истории серии', Format(
    'GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s; HistoryLoadMode=CurrentSegmentHistory; SegmentStartMs=%d; GlobalResetTimeMs=%d; LocalResetTimeMs=%d; AvailableSampleCount=%d; HistorySource=%s',
    [AGraphIndex, ASeriesConfig.ChannelUUID, ASeriesConfig.MeterValueKey,
     FSharedSegmentStartMs, FRuntimeResetTimeMs, ARuntime.RuntimeResetTimeMs,
     Length(Samples), HistorySource]));
  if Length(Samples) = 0 then
  begin
    ARuntime.HistoryLoaded := True;
    if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
      'GraphSeriesHistoryLoadSkipped', 'История серии недоступна', Format(
      'GraphIndex=%d; ChannelUUID=%s; Reason=NoHistory',
      [AGraphIndex, ASeriesConfig.ChannelUUID]));
    Exit;
  end;
  for I := 0 to High(Samples) do
  begin
    Sample := Samples[I];
    if (Sample.TimeStampMs < EffectiveStartMs) or IsNan(Sample.Value) or
       IsInfinite(Sample.Value) or (Abs(Sample.Value) >= MaxDouble) then
    begin Inc(Skipped); Continue end;
    X := (Sample.TimeStampMs - FSharedSegmentStartMs) / 1000.0;
    Y := Sample.Value;
    if SameText(ASeriesConfig.MeterValueKey, 'ValueFlow') or
       SameText(ASeriesConfig.MeterValueKey, 'FlowRate') then
      Y := ConvertFlowToDisplayUnits(Y);
    ARuntime.ChartSeries.AddPoint(X, Y);
    if (Added = 0) and Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesHistorySampleAdded',
        'Добавлен первый исторический отсчёт серии', Format(
        'GraphIndex=%d; ChannelUUID=%s; SampleTimeMs=%d; X=%g; Y=%g',
        [AGraphIndex, ASeriesConfig.ChannelUUID, Sample.TimeStampMs, X, Y]));
    if Added = 0 then begin FirstTime := Sample.TimeStampMs; FirstX := X end;
    LastTime := Sample.TimeStampMs; LastX := X; Inc(Added);
    ARuntime.LastSampleTimeMs := Sample.TimeStampMs;
    ARuntime.LastSampleIndex := I;
  end;
  ARuntime.HistoryLoaded := True;
  ARuntime.WaitingForFirstSample := Added = 0;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphSeriesHistoryLoadDone', 'Загрузка истории серии завершена', Format(
    'GraphIndex=%d; ChannelUUID=%s; ReadCount=%d; AddedCount=%d; SkippedCount=%d; FirstSampleTimeMs=%d; LastSampleTimeMs=%d; FirstX=%g; LastX=%g; PointsCount=%d',
    [AGraphIndex, ASeriesConfig.ChannelUUID, Length(Samples), Added, Skipped,
     FirstTime, LastTime, FirstX, LastX, ARuntime.ChartSeries.Points.Count]));
end;

procedure TFrameGraphsWorkspace.LoadGraphCurrentSegmentHistory(
  const AGraphIndex: Integer);
var Config: TGraphSeriesConfig; Runtime: TGraphSeriesRuntime;
begin
  if (AGraphIndex < 0) or (AGraphIndex >= FConfig.Panels.Count) then Exit;
  for Config in FConfig.Panels[AGraphIndex].Series do
    if FSeriesRuntime.TryGetValue(Config, Runtime) then
      LoadSeriesCurrentSegmentHistory(AGraphIndex, Config, Runtime);
end;

procedure TFrameGraphsWorkspace.UpdateSeriesPoints(AGraphIndex: Integer;
  ASeriesConfig: TGraphSeriesConfig; AChartSeries: TChartSeries;
  AMeterValue: TMeterValue; const ANowMs: Int64;
  const ADoFallback, ASamplingActive: Boolean; var AAddedCount: Integer);
var
  Runtime: TGraphSeriesRuntime;
  Samples: TArray<TMeterValueSample>;
  Sample: TMeterValueSample;
  SampleIndex, Added, Skipped, BufferedAddedCount,
    FallbackAddedCount: Integer;
  BaseY, DisplayY, X: Double;
  RejectReason, FallbackSkipReason: string;
  FirstRejectedLogged, FirstAcceptedLogged: Boolean;
  NewestSampleTimeMs, EffectiveResetTimeMs: Int64;
begin
  if (ASeriesConfig = nil) or (AChartSeries = nil) or
     not FSeriesRuntime.TryGetValue(ASeriesConfig, Runtime) then
    Exit;
  EffectiveResetTimeMs := Max(FRuntimeResetTimeMs, Runtime.RuntimeResetTimeMs);
  Added := 0;
  Skipped := 0;
  BufferedAddedCount := 0;
  FallbackAddedCount := 0;
  FirstRejectedLogged := False;
  FirstAcceptedLogged := False;
  GetSeriesSamples(AMeterValue, Samples);
  NewestSampleTimeMs := 0;
  if Length(Samples) > 0 then
    NewestSampleTimeMs := Samples[High(Samples)].TimeStampMs;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesSamplesRead',
      'Прочитаны отсчёты пользовательской серии', Format(
      'GraphIndex=%d; ChannelUUID=%s; SamplesCount=%d; SegmentStartMs=%d; NewestSampleTimeMs=%d',
      [AGraphIndex, ASeriesConfig.ChannelUUID, Length(Samples),
       FSharedSegmentStartMs, NewestSampleTimeMs]));
  if (Length(Samples) = 0) and Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesSampleDecision',
      'Буфер отсчётов пользовательской серии пуст', Format(
      'GraphIndex=%d; ChannelUUID=%s; SampleIndex=-1; SampleTimeMs=0; Value=0; Accepted=False; RejectReason=SampleBufferEmpty',
      [AGraphIndex, ASeriesConfig.ChannelUUID]));
  for SampleIndex := 0 to High(Samples) do
  begin
    Sample := Samples[SampleIndex];
    CaptureWorkspaceSample(SeriesSourceKey(ASeriesConfig), Sample);
    BaseY := Sample.Value;
    RejectReason := '';
    if Sample.TimeStampMs < FSharedSegmentStartMs then
      RejectReason := 'SampleBeforeSegment'
    else if Sample.TimeStampMs < EffectiveResetTimeMs then
      RejectReason := 'SampleBeforeReset'
    else if (Sample.TimeStampMs < Runtime.LastSampleTimeMs) or
            ((Sample.TimeStampMs = Runtime.LastSampleTimeMs) and
             (SampleIndex <= Runtime.LastSampleIndex)) then
      RejectReason := 'SampleAlreadyProcessed'
    else if IsNan(BaseY) or IsInfinite(BaseY) or (Abs(BaseY) >= MaxDouble) then
      RejectReason := 'SampleInvalidValue'
    else
    begin
      X := (Sample.TimeStampMs - FSharedSegmentStartMs) / 1000.0;
      if X < 0 then
        RejectReason := 'SampleNegativeTime'
      else if Runtime.WaitingForFirstSample and IsPointTransitionStage and
              SameValue(BaseY, 0.0, 1E-12) then
        RejectReason := 'WaitingTransition';
    end;
    if RejectReason <> '' then
    begin
      Inc(Skipped);
      if (not FirstRejectedLogged) and Assigned(ProtocolManager) then
      begin
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesSampleDecision',
          'Отсчёт пользовательской серии отклонён', Format(
          'GraphIndex=%d; ChannelUUID=%s; SampleIndex=%d; SampleTimeMs=%d; Value=%g; Accepted=False; RejectReason=%s',
          [AGraphIndex, ASeriesConfig.ChannelUUID, SampleIndex,
           Sample.TimeStampMs, BaseY, RejectReason]));
        FirstRejectedLogged := True;
      end;
      Continue;
    end;
    DisplayY := BaseY;
    if SameText(ASeriesConfig.MeterValueKey, 'ValueFlow') or
       SameText(ASeriesConfig.MeterValueKey, 'FlowRate') then
      DisplayY := ConvertFlowToDisplayUnits(BaseY);
    AChartSeries.AddPoint(X, DisplayY);
    Runtime.LastSampleTimeMs := Sample.TimeStampMs;
    Runtime.LastSampleIndex := SampleIndex;
    Runtime.WaitingForFirstSample := False;
    Runtime.LastAcceptedValue := BaseY;
    Runtime.LastAcceptedPointKey := FLastPointKey;
    Inc(Added);
    Inc(BufferedAddedCount);
    Inc(AAddedCount);
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesPointAdded',
        'Точка добавлена в визуальную серию', Format(
        'GraphIndex=%d; ChannelUUID=%s; X=%g; BaseY=%g; DisplayY=%g; PointsCount=%d; SampleTimeMs=%d',
        [AGraphIndex, ASeriesConfig.ChannelUUID, X, BaseY, DisplayY,
         AChartSeries.Points.Count, Sample.TimeStampMs]));
    if (not FirstAcceptedLogged) and Assigned(ProtocolManager) then
    begin
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesSampleDecision',
        'Отсчёт пользовательской серии принят', Format(
        'GraphIndex=%d; ChannelUUID=%s; SampleIndex=%d; SampleTimeMs=%d; Value=%g; Accepted=True; RejectReason=',
        [AGraphIndex, ASeriesConfig.ChannelUUID, SampleIndex,
         Sample.TimeStampMs, BaseY]));
      FirstAcceptedLogged := True;
    end;
  end;
  FallbackSkipReason := '';
  if not ASamplingActive then
    FallbackSkipReason := 'SamplingInactive'
  else if not ADoFallback then
    FallbackSkipReason := 'FallbackIntervalNotElapsed'
  else if BufferedAddedCount > 0 then
    FallbackSkipReason := 'BufferedSampleAlreadyAdded'
  else if IsPointTransitionStage then
    FallbackSkipReason := 'PointTransitionStage'
  else if AMeterValue = nil then
    FallbackSkipReason := 'MeterValueMissing'
  else if AChartSeries = nil then
    FallbackSkipReason := 'VisualSeriesMissing'
  else
  begin
    BaseY := AMeterValue.GetDoubleValue;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesFallbackAttempt',
        'Выполнена попытка резервного обновления серии', Format(
        'GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s; DoFallback=%s; SamplingActive=%s; TransitionStage=%s; WaitingForFirstSample=%s; BufferAddedCount=%d; CurrentValue=%g; NowMs=%d; SegmentStartMs=%d; RuntimeResetTimeMs=%d',
        [AGraphIndex, ASeriesConfig.ChannelUUID, ASeriesConfig.MeterValueKey,
         BoolToStr(ADoFallback, True), BoolToStr(ASamplingActive, True),
         BoolToStr(IsPointTransitionStage, True),
         BoolToStr(Runtime.WaitingForFirstSample, True), BufferedAddedCount,
         BaseY, ANowMs, FSharedSegmentStartMs, FRuntimeResetTimeMs]));
    if IsNan(BaseY) or IsInfinite(BaseY) or (Abs(BaseY) >= MaxDouble) then
      FallbackSkipReason := 'InvalidCurrentValue'
    else if (FSharedSegmentStartMs = 0) or
            (ANowMs < FSharedSegmentStartMs) then
      FallbackSkipReason := 'BeforeSegment'
    else if ANowMs < EffectiveResetTimeMs then
      FallbackSkipReason := 'BeforeRuntimeReset'
    else if Runtime.WaitingForFirstSample and
            SameValue(BaseY, 0.0, 1E-12) and
            (ANowMs - FSharedSegmentStartMs < 1000) then
      FallbackSkipReason := 'WaitingForFirstSampleZero'
    else
    begin
      X := (ANowMs - FSharedSegmentStartMs) / 1000.0;
      DisplayY := BaseY;
      if SameText(ASeriesConfig.MeterValueKey, 'ValueFlow') or
         SameText(ASeriesConfig.MeterValueKey, 'FlowRate') then
        DisplayY := ConvertFlowToDisplayUnits(BaseY);
      AChartSeries.AddPoint(X, DisplayY);
      Runtime.LastSampleTimeMs := ANowMs;
      Runtime.LastSampleIndex := -1;
      Runtime.LastAcceptedValue := BaseY;
      Runtime.LastAcceptedPointKey := FLastPointKey;
      Runtime.WaitingForFirstSample := False;
      Inc(Added);
      Inc(FallbackAddedCount);
      Inc(AAddedCount);
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesFallbackAdded',
          'Резервная точка добавлена в визуальную серию', Format(
          'GraphIndex=%d; ChannelUUID=%s; TimeSec=%g; BaseValue=%g; DisplayValue=%g; PointsCount=%d; SampleTimeMs=%d',
          [AGraphIndex, ASeriesConfig.ChannelUUID, X, BaseY, DisplayY,
           AChartSeries.Points.Count, ANowMs]));
    end;
  end;
  if (FallbackSkipReason <> '') and ADoFallback and
     Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesFallbackSkipped',
      'Резервная точка пользовательской серии пропущена', Format(
      'GraphIndex=%d; ChannelUUID=%s; Reason=%s',
      [AGraphIndex, ASeriesConfig.ChannelUUID, FallbackSkipReason]));
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesUpdateDone',
      'Обновление пользовательской серии завершено', Format(
      'GraphIndex=%d; ChannelUUID=%s; SamplesRead=%d; AddedCount=%d; BufferedAddedCount=%d; FallbackAddedCount=%d; SkippedCount=%d; PointsCount=%d; LastSampleTimeMs=%d',
      [AGraphIndex, ASeriesConfig.ChannelUUID, Length(Samples), Added,
       BufferedAddedCount, FallbackAddedCount, Skipped,
       AChartSeries.Points.Count, Runtime.LastSampleTimeMs]));
end;

function TFrameGraphsWorkspace.IsSamplingActive: Boolean;
var
  Run: TMeasurementRun;
begin
  Result := (FWorkTable <> nil) and (FWorkTable.State in
    [swtSTARTMONITOR, swtSTARTMONITORWAIT, swtMONITOR, swtSTARTTEST,
     swtSTARTWAIT, swtEXECUTE, swtSTOPTEST, swtSTOPWAIT, swtFINALREAD]);
  if (not Result) and (FWorkTable <> nil) and
     (FWorkTable.MeasurementRun is TMeasurementRun) then
  begin
    Run := TMeasurementRun(FWorkTable.MeasurementRun);
    Result := not (Run.Stage in [msNone, msDone]);
  end;
end;

procedure TFrameGraphsWorkspace.ResetSeriesSegment(const AStartMs: Int64;
  const APointKey: string);
var
  Pair: TPair<TGraphSeriesConfig, TGraphSeriesRuntime>;
  SeriesCount, ClearedPoints: Integer;
begin
  FSharedSegmentStartMs := AStartMs;
  if FSeriesRuntime = nil then
    Exit;
  SeriesCount := 0;
  ClearedPoints := 0;
  for Pair in FSeriesRuntime do
    if Pair.Value <> nil then
    begin
      Inc(SeriesCount);
      Pair.Value.LastSampleTimeMs := 0;
      Pair.Value.LastSampleIndex := -1;
      Pair.Value.WaitingForFirstSample := True;
      Pair.Value.LastAcceptedPointKey := APointKey;
      Pair.Value.RuntimeResetTimeMs := AStartMs;
      Pair.Value.HistoryLoaded := False;
      Pair.Value.HistoryLoadMode := ghlmCurrentSegmentHistory;
      if Pair.Value.ChartSeries <> nil then
      begin
        Inc(ClearedPoints, Pair.Value.ChartSeries.Points.Count);
        Pair.Value.ChartSeries.ClearPoints;
      end;
    end;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesRuntimeReset',
      'Сброшено runtime-состояние серий', Format(
      'SeriesCount=%d; ClearedPointsCount=%d; SegmentStartMs=%d; PointKey=%s',
      [SeriesCount, ClearedPoints, AStartMs, APointKey]));
end;

procedure TFrameGraphsWorkspace.RemoveRuntimeSeries(
  const AConfig: TGraphSeriesConfig; AChart: TSimpleChart);
var
  Runtime: TGraphSeriesRuntime;
  I: Integer;
begin
  if (AConfig = nil) or (FSeriesRuntime = nil) or
     not FSeriesRuntime.TryGetValue(AConfig, Runtime) then
    Exit;
  if (AChart <> nil) and (Runtime.ChartSeries <> nil) then
    for I := AChart.SeriesCount - 1 downto 0 do
      if AChart.Series[I] = Runtime.ChartSeries then
      begin
        AChart.RemoveSeries(I);
        Break;
      end;
  FSeriesRuntime.Remove(AConfig);
end;

procedure TFrameGraphsWorkspace.RemoveGraphRuntimeSeries(
  const AGraphIndex: Integer);
var
  Config: TGraphSeriesConfig;
  Chart: TSimpleChart;
begin
  if (FConfig = nil) or (AGraphIndex < 0) or
     (AGraphIndex >= FConfig.Panels.Count) then
    Exit;
  Chart := ChartByIndex(AGraphIndex);
  for Config in FConfig.Panels[AGraphIndex].Series do
    RemoveRuntimeSeries(Config, Chart);
end;

function TFrameGraphsWorkspace.GetCurrentFlowUnitText: string;
begin
  Result := 'л/с';
  if (FWorkTable <> nil) and (FWorkTable.ValueFlowRate <> nil) then
    Result := FWorkTable.ValueFlowRate.GetDimName;
end;

function TFrameGraphsWorkspace.GetCurrentFlowUnitKey: string;
begin
  Result := GetCurrentFlowUnitText;
  if (FWorkTable <> nil) and (FWorkTable.ValueFlowRate <> nil) then
    Result := Format('%d|%s', [FWorkTable.ValueFlowRate.CurrentDimIndex, Result]);
end;

function TFrameGraphsWorkspace.ConvertFlowToDisplayUnits(
  const AValue: Double): Double;
begin
  Result := AValue;
  if (FWorkTable <> nil) and (FWorkTable.ValueFlowRate <> nil) then
    Result := FWorkTable.ValueFlowRate.GetDoubleNum(AValue,
      FWorkTable.ValueFlowRate.CurrentDimIndex);
end;

procedure TFrameGraphsWorkspace.UpdateChartAxisUnits;
var I: Integer;
begin
  for I := 0 to FConfig.GraphCount - 1 do
  begin
    ChartByIndex(I).XTitle := 'Время, с';
    ChartByIndex(I).YTitle := 'Расход, ' + GetCurrentFlowUnitText;
  end;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphAxisUnitsUpdated',
      'Обновлены единицы осей графиков', 'Unit=' + GetCurrentFlowUnitText);
end;

procedure TFrameGraphsWorkspace.RebuildSeriesForCurrentUnits;
var Pair: TPair<TGraphSeriesConfig, TGraphSeriesRuntime>;
begin
  for Pair in FSeriesRuntime do
  begin
    Pair.Value.ChartSeries.ClearPoints;
    Pair.Value.LastSampleTimeMs := 0;
    Pair.Value.LastSampleIndex := -1;
    Pair.Value.HistoryLoaded := False;
    LoadSeriesCurrentSegmentHistory(Pair.Key.GraphIndex, Pair.Key, Pair.Value);
  end;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesRebuiltForUnits',
      'Серии перестроены в выбранных единицах',
      'Unit=' + GetCurrentFlowUnitText);
end;

procedure TFrameGraphsWorkspace.CheckFlowUnitsChanged;
var NewKey, OldKey: string; OldCoef, NewCoef: Double;
begin
  NewKey := GetCurrentFlowUnitKey;
  if FLastFlowUnitKey = '' then
  begin
    FLastFlowUnitKey := NewKey;
    UpdateChartAxisUnits;
    Exit;
  end;
  if SameText(NewKey, FLastFlowUnitKey) then Exit;
  OldKey := FLastFlowUnitKey;
  OldCoef := 1; NewCoef := ConvertFlowToDisplayUnits(1);
  FLastFlowUnitKey := NewKey;
  RebuildSeriesForCurrentUnits;
  UpdateChartAxisUnits;
  UpdateToleranceLines;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphFlowUnitsChanged',
      'Изменены единицы расхода', Format(
      'OldUnit=%s; NewUnit=%s; OldCoef=%g; NewCoef=%g',
      [OldKey, NewKey, OldCoef, NewCoef]));
end;

function TFrameGraphsWorkspace.CurrentPointKey(out APointIndex: Integer): string;
var Run: TMeasurementRun; Point: TDevicePoint;
begin
  Result := ''; APointIndex := -1;
  if (FWorkTable = nil) or not (FWorkTable.MeasurementRun is TMeasurementRun) then Exit;
  Run := TMeasurementRun(FWorkTable.MeasurementRun);
  Point := Run.CurrentPoint;
  APointIndex := Run.CurrentPointIndex;
  if Point = nil then Exit;
  if Trim(Point.UUID) <> '' then Result := Point.UUID
  else Result := Format('%d|%s|%.12g', [APointIndex, Point.Name, Point.Q]);
end;

function TFrameGraphsWorkspace.IsPointTransitionStage: Boolean;
var Stage: EMeasurementState;
begin
  Result := False;
  if (FWorkTable = nil) or not (FWorkTable.MeasurementRun is TMeasurementRun) then Exit;
  Stage := TMeasurementRun(FWorkTable.MeasurementRun).Stage;
  Result := Stage in [msSelectPoint, msSelectEtalon, msSetupPoint];
end;

procedure TFrameGraphsWorkspace.StartSharedSegment(
  const AReason: TGraphSegmentStartReason; const APointKey: string;
  const APointIndex: Integer);
var
  StartMs: Int64;
  ReasonText: string;
begin
  StartMs := Max(TMeterValue.GetMonotonicTimeMs, FRuntimeResetTimeMs);
  case AReason of
    gssrRunStarted: ReasonText := 'RunStarted';
    gssrPointChanged: ReasonText := 'PointChanged';
  else
    Exit;
  end;
  ClearWorkspaceSegmentHistory;
  ResetSeriesSegment(StartMs, APointKey);
  FLastFallbackSampleMs := 0;
  FSharedTimeInitialized := True;
  FSharedCurrentTimeSec := 0;
  FSharedAxisMinX := 0;
  if FConfig.VisibleDurationSec > 0 then
    FSharedAxisMaxX := FConfig.VisibleDurationSec
  else
    FSharedAxisMaxX := 60;
  FLastPointKey := APointKey; FLastPointIndex := APointIndex;
  ApplySharedXAxis;
  UpdateToleranceLines;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSharedTimeSegmentStarted',
      'Начат общий временной сегмент', Format(
      'Reason=%s; SegmentStartMs=%d; PointKey=%s; PointIndex=%d; GraphCount=%d',
      [ReasonText, StartMs, APointKey, APointIndex, FConfig.GraphCount]));
end;

procedure TFrameGraphsWorkspace.CalculateSharedTimeRange(const ANowMs: Int64);
var Duration: Integer;
begin
  if FSharedTimeInitialized then
    FSharedCurrentTimeSec := Max(0.0, (ANowMs - FSharedSegmentStartMs) / 1000.0)
  else FSharedCurrentTimeSec := 0;
  Duration := FConfig.VisibleDurationSec;
  if Duration = 0 then
  begin
    FSharedAxisMinX := 0;
    FSharedAxisMaxX := Max(60.0, FSharedCurrentTimeSec);
  end
  else if FSharedCurrentTimeSec <= Duration then
  begin
    FSharedAxisMinX := 0; FSharedAxisMaxX := Duration;
  end
  else
  begin
    FSharedAxisMinX := FSharedCurrentTimeSec - Duration;
    FSharedAxisMaxX := FSharedCurrentTimeSec;
  end;
  if Assigned(ProtocolManager) and
     ((FLastUpdateDiagnosticMs = 0) or (ANowMs - FLastUpdateDiagnosticMs >= 1000)) then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSharedTimeRangeUpdated',
      'Обновлён общий диапазон времени', Format(
      'CurrentTimeSec=%g; VisibleDurationSec=%d; AxisMinX=%g; AxisMaxX=%g',
      [FSharedCurrentTimeSec, Duration, FSharedAxisMinX, FSharedAxisMaxX]));
    FLastUpdateDiagnosticMs := ANowMs;
  end;
end;

procedure TFrameGraphsWorkspace.ApplySharedXAxis;
var I: Integer; Chart: TSimpleChart;
begin
  for I := 0 to FConfig.GraphCount - 1 do
  begin
    Chart := ChartByIndex(I);
    Chart.AutoRangeX := False;
    Chart.XMin := FSharedAxisMinX; Chart.XMax := FSharedAxisMaxX;
  end;
  if Assigned(ProtocolManager) and not FSharedTimeInitialized then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphXAxisSynchronized',
      'Оси времени графиков синхронизированы', Format(
      'GraphCount=%d; AxisMinX=%g; AxisMaxX=%g',
      [FConfig.GraphCount, FSharedAxisMinX, FSharedAxisMaxX]));
end;

procedure TFrameGraphsWorkspace.EnsureLimitSeries(const AGraphIndex: Integer);
var Slot: TGraphVisualSlot;
begin
  Slot := GraphSlotByIndex(AGraphIndex);
  if (Slot = nil) or (Slot.Chart = nil) then Exit;
  if Slot.TargetSeries = nil then
  begin
    Slot.TargetSeries := Slot.Chart.AddSeries('Целевой расход');
    Slot.TargetSeries.Color := TAlphaColors.Green;
    Slot.TargetSeries.ShowMarkers := False;
    Slot.LowerSeries := Slot.Chart.AddSeries('Нижняя допустимая граница');
    Slot.LowerSeries.Color := TAlphaColors.Red;
    Slot.LowerSeries.ShowMarkers := False;
    Slot.UpperSeries := Slot.Chart.AddSeries('Верхняя допустимая граница');
    Slot.UpperSeries.Color := TAlphaColors.Red;
    Slot.UpperSeries.ShowMarkers := False;
  end;
end;

procedure TFrameGraphsWorkspace.LogToleranceEvent(const AEventName,
  AReason, ADetails: string);
var
  NowMs: Int64;
  PreviousMs: Int64;
  DiagnosticKey: string;
begin
  if not Assigned(ProtocolManager) then
    Exit;
  NowMs := TMeterValue.GetMonotonicTimeMs;
  DiagnosticKey := AEventName + '|' + AReason;
  if (FToleranceDiagnosticTimes <> nil) and
     FToleranceDiagnosticTimes.TryGetValue(DiagnosticKey, PreviousMs) and
     (NowMs - PreviousMs < 2000) then
    Exit;
  ProtocolManager.AddMessage(pcProc, psForm, AEventName,
    'Диагностика источника допуска графика', ADetails);
  FLastToleranceDiagnosticMs := NowMs;
  FLastToleranceDiagnosticReason := DiagnosticKey;
  if FToleranceDiagnosticTimes <> nil then
    FToleranceDiagnosticTimes.AddOrSetValue(DiagnosticKey, NowMs);
end;

function TFrameGraphsWorkspace.ValidateDevicePointsTolerance(
  const APointIndex: Integer; out AReferencePoint: TDevicePoint;
  out AReason: string): Boolean;
var
  Channel: TChannel;
  Device, ReferenceDevice: TDevice;
  Point: TDevicePoint;
begin
  Result := False;
  AReferencePoint := nil;
  ReferenceDevice := nil;
  AReason := '';
  if (FWorkTable = nil) or (FWorkTable.DeviceChannels = nil) then
  begin
    AReason := 'DeviceChannelsMissing';
    Exit;
  end;
  if APointIndex < 0 then
  begin
    AReason := 'InvalidPointIndex';
    Exit;
  end;
  for Channel in FWorkTable.DeviceChannels do
  begin
    if (Channel = nil) or not Channel.Enabled or (Channel.FlowMeter = nil) then
      Continue;
    Device := Channel.FlowMeter.Device;
    if (Device = nil) or (Device.Points = nil) or
       (APointIndex >= Device.Points.Count) then
      Continue;
    Point := Device.Points[APointIndex];
    if Point = nil then
      Continue;
    if AReferencePoint = nil then
    begin
      AReferencePoint := Point;
      ReferenceDevice := Device;
    end
    else if not SameValue(Point.Q, AReferencePoint.Q, 1E-9) or
            not SameValue(Point.Error, AReferencePoint.Error, 1E-9) then
    begin
      AReason := 'DevicePointsToleranceMismatch';
      LogToleranceEvent('GraphToleranceSourceMismatch', AReason, Format(
        'ReferenceDeviceUUID=%s; ReferencePointUUID=%s; ReferenceQ=%g; ReferenceError=%g; ConflictingDeviceUUID=%s; ConflictingPointUUID=%s; ConflictingQ=%g; ConflictingError=%g',
        [ReferenceDevice.UUID, AReferencePoint.UUID, AReferencePoint.Q,
         AReferencePoint.Error, Device.UUID, Point.UUID, Point.Q, Point.Error]));
      Exit;
    end;
  end;
  if AReferencePoint = nil then
  begin
    AReason := 'DevicePointNotFound';
    Exit;
  end;
  Result := True;
end;

function TFrameGraphsWorkspace.ResolveToleranceSource(
  out AInfo: TGraphToleranceSourceInfo; out AReason: string): Boolean;
var
  Run: TMeasurementRun;
  RunPoint, Point, ReferencePoint: TDevicePoint;
  Channel: TChannel;
  Device, ReferenceDevice: TDevice;
  I, RunPointIndex: Integer;
  MatchKind, FallbackReason: string;

  function NumberValid(const AValue: Double): Boolean;
  begin
    Result := not IsNan(AValue) and not IsInfinite(AValue) and
      (Abs(AValue) < MaxDouble);
  end;

  function FindPointInDevice(ADevice: TDevice; out APointIndex: Integer): TDevicePoint;
  var
    J: Integer;
  begin
    Result := nil;
    APointIndex := -1;
    if (ADevice = nil) or (ADevice.Points = nil) or (RunPoint = nil) then
      Exit;
    if Trim(RunPoint.UUID) <> '' then
      for J := 0 to ADevice.Points.Count - 1 do
        if (ADevice.Points[J] <> nil) and
           (NormalizeUUID(ADevice.Points[J].UUID) = NormalizeUUID(RunPoint.UUID)) then
        begin
          APointIndex := J;
          Exit(ADevice.Points[J]);
        end;
    for J := 0 to ADevice.Points.Count - 1 do
      if (ADevice.Points[J] <> nil) and SameValue(ADevice.Points[J].Q,
         RunPoint.Q, 1E-9) and SameText(Trim(ADevice.Points[J].Name),
         Trim(RunPoint.Name)) then
      begin
        APointIndex := J;
        Exit(ADevice.Points[J]);
      end;
  end;

  procedure SetDeviceSource(ADevice: TDevice; APoint: TDevicePoint;
    const APointIndex: Integer; const ASourceKind: string);
  begin
    AInfo.Device := ADevice;
    AInfo.Point := APoint;
    AInfo.DeviceUUID := ADevice.UUID;
    AInfo.PointUUID := APoint.UUID;
    AInfo.PointIndex := APointIndex;
    AInfo.TargetQ := APoint.Q;
    AInfo.ErrorPercent := APoint.Error;
    AInfo.SourceKind := ASourceKind;
  end;

begin
  Result := False;
  AInfo := Default(TGraphToleranceSourceInfo);
  AInfo.PointIndex := -1;
  AReason := '';
  if FWorkTable = nil then
  begin
    AReason := 'WorkTableMissing';
    Exit;
  end;
  if not (FWorkTable.MeasurementRun is TMeasurementRun) then
  begin
    AReason := 'MeasurementRunMissing';
    Exit;
  end;
  Run := TMeasurementRun(FWorkTable.MeasurementRun);
  RunPointIndex := Run.CurrentPointIndex;
  RunPoint := Run.CurrentPoint;

  if RunPointIndex >= 0 then
  begin
    if not ValidateDevicePointsTolerance(RunPointIndex, ReferencePoint,
       AReason) then
    begin
      if AReason = 'DevicePointsToleranceMismatch' then
        Exit;
      AReason := '';
      ReferencePoint := nil;
    end;
    ReferenceDevice := nil;
    if ReferencePoint <> nil then
      for Channel in FWorkTable.DeviceChannels do
      if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) and
         (Channel.FlowMeter.Device <> nil) and
         (Channel.FlowMeter.Device.Points <> nil) and
         (RunPointIndex < Channel.FlowMeter.Device.Points.Count) and
         (Channel.FlowMeter.Device.Points[RunPointIndex] = ReferencePoint) then
      begin
        ReferenceDevice := Channel.FlowMeter.Device;
        Break;
      end;
    if ReferenceDevice <> nil then
    begin
      SetDeviceSource(ReferenceDevice, ReferencePoint, RunPointIndex,
        'DevicePointByIndex');
      Result := True;
    end;
  end;

  if not Result and (RunPoint <> nil) and (Trim(RunPoint.UUID) <> '') then
  begin
    ReferencePoint := nil;
    ReferenceDevice := nil;
    for Channel in FWorkTable.DeviceChannels do
    begin
      if (Channel = nil) or not Channel.Enabled or (Channel.FlowMeter = nil) then
        Continue;
      Device := Channel.FlowMeter.Device;
      Point := FindPointInDevice(Device, I);
      if (Point = nil) or
         (NormalizeUUID(Point.UUID) <> NormalizeUUID(RunPoint.UUID)) then
        Continue;
      if ReferencePoint = nil then
      begin
        ReferencePoint := Point;
        ReferenceDevice := Device;
        RunPointIndex := I;
      end
      else if not SameValue(Point.Q, ReferencePoint.Q, 1E-9) or
              not SameValue(Point.Error, ReferencePoint.Error, 1E-9) then
      begin
        AReason := 'DevicePointsToleranceMismatch';
        LogToleranceEvent('GraphToleranceSourceMismatch', AReason, Format(
          'ReferenceDeviceUUID=%s; ReferencePointUUID=%s; ReferenceQ=%g; ReferenceError=%g; ConflictingDeviceUUID=%s; ConflictingPointUUID=%s; ConflictingQ=%g; ConflictingError=%g',
          [ReferenceDevice.UUID, ReferencePoint.UUID, ReferencePoint.Q,
           ReferencePoint.Error, Device.UUID, Point.UUID, Point.Q, Point.Error]));
        Exit;
      end;
    end;
    if ReferencePoint <> nil then
    begin
      SetDeviceSource(ReferenceDevice, ReferencePoint, RunPointIndex,
        'DevicePointByUUID');
      Result := True;
    end;
  end;

  { Q and name are intentionally the final device-point matching fallback. }
  if not Result and (RunPoint <> nil) then
  begin
    MatchKind := 'DevicePointByQAndName';
    ReferencePoint := nil;
    ReferenceDevice := nil;
    for Channel in FWorkTable.DeviceChannels do
      if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) then
      begin
        Device := Channel.FlowMeter.Device;
        Point := FindPointInDevice(Device, I);
        if Point = nil then
          Continue;
        if ReferencePoint = nil then
        begin
          ReferencePoint := Point;
          ReferenceDevice := Device;
          RunPointIndex := I;
        end
        else if not SameValue(Point.Q, ReferencePoint.Q, 1E-9) or
                not SameValue(Point.Error, ReferencePoint.Error, 1E-9) then
        begin
          AReason := 'DevicePointsToleranceMismatch';
          LogToleranceEvent('GraphToleranceSourceMismatch', AReason, Format(
            'ReferenceDeviceUUID=%s; ReferencePointUUID=%s; ReferenceQ=%g; ReferenceError=%g; ConflictingDeviceUUID=%s; ConflictingPointUUID=%s; ConflictingQ=%g; ConflictingError=%g',
            [ReferenceDevice.UUID, ReferencePoint.UUID, ReferencePoint.Q,
             ReferencePoint.Error, Device.UUID, Point.UUID, Point.Q, Point.Error]));
          Exit;
        end;
      end;
    if ReferencePoint <> nil then
    begin
      SetDeviceSource(ReferenceDevice, ReferencePoint, RunPointIndex, MatchKind);
      Result := True;
    end;
  end;

  if Result then
  begin
    LogToleranceEvent('GraphToleranceSourceResolved', AInfo.SourceKind, Format(
      'SourceKind=%s; DeviceUUID=%s; PointUUID=%s; PointIndex=%d; Q=%g; Error=%g',
      [AInfo.SourceKind, AInfo.DeviceUUID, AInfo.PointUUID, AInfo.PointIndex,
       AInfo.TargetQ, AInfo.ErrorPercent]));
    Exit;
  end;

  { A run point is never accepted unless it can be associated with an enabled
    device.  This is a defensive compatibility path for incomplete device
    point objects only. }
  FallbackReason := 'DevicePointValuesUnavailable';
  if (RunPoint <> nil) and ((Run.CurrentPointIndex >= 0) or
     (Trim(RunPoint.UUID) <> '')) and NumberValid(RunPoint.Q) and
     NumberValid(RunPoint.Error) and not SameValue(RunPoint.Error, 0.0, 1E-12) then
    for Channel in FWorkTable.DeviceChannels do
      if (Channel <> nil) and Channel.Enabled and (Channel.FlowMeter <> nil) then
      begin
        Device := Channel.FlowMeter.Device;
        Point := FindPointInDevice(Device, I);
        if Point <> nil then
        begin
          AInfo.Device := Device;
          AInfo.Point := RunPoint;
          AInfo.DeviceUUID := Device.UUID;
          AInfo.PointUUID := RunPoint.UUID;
          AInfo.PointIndex := I;
          AInfo.TargetQ := RunPoint.Q;
          AInfo.ErrorPercent := RunPoint.Error;
          AInfo.SourceKind := 'RunCurrentPoint';
          LogToleranceEvent('GraphToleranceSourceFallback', FallbackReason,
            Format('SourceKind=RunCurrentPoint; RunPointUUID=%s; RunPointIndex=%d; Q=%g; Error=%g; FallbackReason=%s',
              [RunPoint.UUID, Run.CurrentPointIndex, RunPoint.Q, RunPoint.Error,
               FallbackReason]));
          Result := True;
          Exit;
        end;
      end;
  AReason := 'DevicePointNotFound';
end;

function TFrameGraphsWorkspace.ResolvePointTolerance(out ATarget, ALower,
  AUpper, AErrorPercent: Double; out AReason: string): Boolean;
var
  SourceInfo: TGraphToleranceSourceInfo;
  ToleranceValue: Double;
begin
  Result := False;
  ATarget := 0;
  ALower := 0;
  AUpper := 0;
  AErrorPercent := 0;
  AReason := '';

  if not ResolveToleranceSource(SourceInfo, AReason) then
    Exit;
  FLastToleranceSourceInfo := SourceInfo;
  ATarget := SourceInfo.TargetQ;
  AErrorPercent := SourceInfo.ErrorPercent;

  if IsNan(ATarget) or IsInfinite(ATarget) or
     (Abs(ATarget) >= MaxDouble) then
  begin
    AReason := 'InvalidTargetQ';
    Exit;
  end;
  if IsNan(AErrorPercent) or IsInfinite(AErrorPercent) or
     (Abs(AErrorPercent) >= MaxDouble) then
  begin
    AReason := 'InvalidPointError';
    Exit;
  end;
  if SameValue(AErrorPercent, 0.0, 1E-12) then
  begin
    AReason := 'ZeroPointError';
    Exit;
  end;
  if SameValue(ATarget, 0.0, 1E-12) then
  begin
    AReason := 'ZeroTargetWithoutAbsoluteTolerance';
    Exit;
  end;
  ToleranceValue := Abs(ATarget) * Abs(AErrorPercent) / 100.0;
  ALower := ATarget - ToleranceValue;
  AUpper := ATarget + ToleranceValue;
  Result := True;
end;

procedure TFrameGraphsWorkspace.UpdateToleranceLines;
var
  I, PointIndex: Integer;
  BaseTarget, BaseLower, BaseUpper, ErrorPercent, ToleranceValue: Double;
  DisplayTarget, DisplayLower, DisplayUpper: Double;
  Available: Boolean;
  Reason: string;
  NowMs: Int64;
  RunPointUUID: string;
  RunPointQ, RunPointError: Double;
  Run: TMeasurementRun;
begin
  Available := ResolvePointTolerance(BaseTarget, BaseLower, BaseUpper,
    ErrorPercent, Reason);
  DisplayTarget := ConvertFlowToDisplayUnits(BaseTarget);
  DisplayLower := ConvertFlowToDisplayUnits(BaseLower);
  DisplayUpper := ConvertFlowToDisplayUnits(BaseUpper);
  PointIndex := -1;
  RunPointUUID := '';
  RunPointQ := 0;
  RunPointError := 0;
  if (FWorkTable <> nil) and
     (FWorkTable.MeasurementRun is TMeasurementRun) then
  begin
    Run := TMeasurementRun(FWorkTable.MeasurementRun);
    PointIndex := Run.CurrentPointIndex;
    if Run.CurrentPoint <> nil then
    begin
      RunPointUUID := Run.CurrentPoint.UUID;
      RunPointQ := Run.CurrentPoint.Q;
      RunPointError := Run.CurrentPoint.Error;
    end;
  end;
  NowMs := TMeterValue.GetMonotonicTimeMs;
  if Available then
  begin
    ToleranceValue := Abs(BaseTarget) * Abs(ErrorPercent) / 100.0;
    LogToleranceEvent('GraphPointToleranceResolved',
      FLastToleranceSourceInfo.SourceKind, Format(
      'SourceKind=%s; SourceDeviceUUID=%s; SourcePointUUID=%s; SourcePointIndex=%d; RunPointUUID=%s; RunPointIndex=%d; RunPointQ=%g; RunPointError=%g; ResolvedTargetQ=%g; ResolvedErrorPercent=%g; ToleranceValue=%g; Lower=%g; Upper=%g; DisplayUnit=%s; DisplayTarget=%g; DisplayLower=%g; DisplayUpper=%g',
      [FLastToleranceSourceInfo.SourceKind,
       FLastToleranceSourceInfo.DeviceUUID,
       FLastToleranceSourceInfo.PointUUID,
       FLastToleranceSourceInfo.PointIndex,
       RunPointUUID, PointIndex, RunPointQ, RunPointError,
       BaseTarget, ErrorPercent, ToleranceValue, BaseLower, BaseUpper,
       GetCurrentFlowUnitText, DisplayTarget, DisplayLower, DisplayUpper]));
  end
  else
  begin
    LogToleranceEvent('GraphToleranceSourceUnavailable', Reason, Format(
      'RunPointUUID=%s; RunPointIndex=%d; RunPointQ=%g; RunPointError=%g; Reason=%s',
      [RunPointUUID, PointIndex, RunPointQ, RunPointError, Reason]));
    LogToleranceEvent('GraphPointToleranceUnavailable', Reason, Format(
      'RunPointUUID=%s; RunPointIndex=%d; RunPointQ=%g; RunPointError=%g; Reason=%s',
      [RunPointUUID, PointIndex, RunPointQ, RunPointError, Reason]));
  end;
  for I := 0 to FConfig.GraphCount - 1 do
  begin
    EnsureLimitSeries(I);
    GraphSlotByIndex(I).TargetSeries.ClearPoints; GraphSlotByIndex(I).LowerSeries.ClearPoints;
    GraphSlotByIndex(I).UpperSeries.ClearPoints;
    GraphSlotByIndex(I).TargetSeries.Visible := Available and FConfig.Panels[I].ShowTargetLine;
    GraphSlotByIndex(I).LowerSeries.Visible := Available and FConfig.Panels[I].ShowToleranceLines;
    GraphSlotByIndex(I).UpperSeries.Visible := Available and FConfig.Panels[I].ShowToleranceLines;
    if Available then
    begin
      GraphSlotByIndex(I).TargetSeries.AddPoint(FSharedAxisMinX, DisplayTarget);
      GraphSlotByIndex(I).TargetSeries.AddPoint(FSharedAxisMaxX, DisplayTarget);
      GraphSlotByIndex(I).LowerSeries.AddPoint(FSharedAxisMinX, DisplayLower);
      GraphSlotByIndex(I).LowerSeries.AddPoint(FSharedAxisMaxX, DisplayLower);
      GraphSlotByIndex(I).UpperSeries.AddPoint(FSharedAxisMinX, DisplayUpper);
      GraphSlotByIndex(I).UpperSeries.AddPoint(FSharedAxisMaxX, DisplayUpper);
    end;
    UpdateIndependentYAxis(I);
  end;
  if Assigned(ProtocolManager) and Available then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphToleranceLinesUpdated',
      'Обновлены линии допуска графиков', Format(
      'GraphCount=%d; AxisMinX=%g; AxisMaxX=%g',
      [FConfig.GraphCount, FSharedAxisMinX, FSharedAxisMaxX]));
end;

procedure TFrameGraphsWorkspace.UpdateToleranceLinesForGraph(
  const AGraphIndex: Integer);
var Slot: TGraphVisualSlot; Target, Lower, Upper, ErrorPercent: Double;
  Available: Boolean; Reason: string;
begin
  Slot := GraphSlotByIndex(AGraphIndex);
  if (Slot = nil) or (AGraphIndex < 0) or
     (AGraphIndex >= FConfig.GraphCount) then Exit;
  EnsureLimitSeries(AGraphIndex);
  Available := ResolvePointTolerance(Target, Lower, Upper, ErrorPercent, Reason);
  Target := ConvertFlowToDisplayUnits(Target);
  Lower := ConvertFlowToDisplayUnits(Lower);
  Upper := ConvertFlowToDisplayUnits(Upper);
  Slot.TargetSeries.ClearPoints;
  Slot.LowerSeries.ClearPoints;
  Slot.UpperSeries.ClearPoints;
  Slot.TargetSeries.Visible := Available and FConfig.Panels[AGraphIndex].ShowTargetLine;
  Slot.LowerSeries.Visible := Available and FConfig.Panels[AGraphIndex].ShowToleranceLines;
  Slot.UpperSeries.Visible := Available and FConfig.Panels[AGraphIndex].ShowToleranceLines;
  if Available then
  begin
    Slot.TargetSeries.AddPoint(FSharedAxisMinX, Target);
    Slot.TargetSeries.AddPoint(FSharedAxisMaxX, Target);
    Slot.LowerSeries.AddPoint(FSharedAxisMinX, Lower);
    Slot.LowerSeries.AddPoint(FSharedAxisMaxX, Lower);
    Slot.UpperSeries.AddPoint(FSharedAxisMinX, Upper);
    Slot.UpperSeries.AddPoint(FSharedAxisMaxX, Upper);
  end;
end;

procedure TFrameGraphsWorkspace.UpdateIndependentYAxis(const AGraphIndex: Integer);
var I, J: Integer; Chart: TSimpleChart; V, Lo, Hi, Pad: Double; HasValue: Boolean;
begin
  Chart := ChartByIndex(AGraphIndex); HasValue := False; Lo := 0; Hi := 0;
  for I := 0 to Chart.SeriesCount - 1 do
    if Chart.Series[I].Visible then
      for J := 0 to Chart.Series[I].Points.Count - 1 do
      begin
        V := Chart.Series[I].Points[J].Y;
        if not HasValue then begin Lo := V; Hi := V; HasValue := True end
        else begin Lo := Min(Lo, V); Hi := Max(Hi, V) end;
      end;
  if not HasValue then begin Lo := 0; Hi := 1 end;
  Pad := Hi - Lo;
  if Pad <= 0 then Pad := Max(Abs(Lo) * 0.01, 0.001) else Pad := Pad * 0.1;
  Chart.AutoRangeY := False; Chart.YMin := Lo - Pad; Chart.YMax := Hi + Pad;
end;

procedure TFrameGraphsWorkspace.ResetGraphRuntimeData(
  const AGraphIndex: Integer);
var Config: TGraphSeriesConfig; Runtime: TGraphSeriesRuntime;
  Slot: TGraphVisualSlot; ResetTimeMs, LastSampleBefore: Int64;
  ClearedSeriesCount, ClearedPointsCount, OldPointsCount: Integer;
begin
  if (FConfig = nil) or (AGraphIndex < 0) or
     (AGraphIndex >= FConfig.GraphCount) then Exit;
  ResetTimeMs := TMeterValue.GetMonotonicTimeMs;
  ClearedSeriesCount := 0; ClearedPointsCount := 0;
  for Config in FConfig.Panels[AGraphIndex].Series do
    if FSeriesRuntime.TryGetValue(Config, Runtime) and (Runtime <> nil) then
    begin
      OldPointsCount := 0; LastSampleBefore := Runtime.LastSampleTimeMs;
      if Runtime.ChartSeries <> nil then
      begin
        OldPointsCount := Runtime.ChartSeries.Points.Count;
        Inc(ClearedPointsCount, OldPointsCount);
        Runtime.ChartSeries.ClearPoints;
      end;
      Runtime.LastSampleTimeMs := ResetTimeMs;
      Runtime.HistoryLoadMode := ghlmAfterLocalReset;
      Runtime.HistoryLoaded := True;
      Runtime.LastSampleIndex := -1;
      Runtime.WaitingForFirstSample := True;
      Runtime.LastAcceptedValue := 0;
      Runtime.LastAcceptedPointKey := FLastPointKey;
      Runtime.RuntimeResetTimeMs := ResetTimeMs;
      Inc(ClearedSeriesCount);
      if False and Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphRuntimeValuesResetSeries',
          'Очищены значения серии выбранного графика', Format(
          'GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s; OldPointsCount=%d; LastSampleTimeMsBefore=%d; RuntimeResetTimeMs=%d; WaitingForFirstSample=True',
          [AGraphIndex, Config.ChannelUUID, Config.MeterValueKey, OldPointsCount,
           LastSampleBefore, ResetTimeMs]));
      { Per-series details are intentionally kept out of the normal protocol;
        the summary below is sufficient when diagnostic mode is disabled. }
    end;
  Slot := GraphSlotByIndex(AGraphIndex);
  if Slot <> nil then
  begin
    if Slot.TargetSeries <> nil then Slot.TargetSeries.ClearPoints;
    if Slot.LowerSeries <> nil then Slot.LowerSeries.ClearPoints;
    if Slot.UpperSeries <> nil then Slot.UpperSeries.ClearPoints;
  end;
  UpdateToleranceLinesForGraph(AGraphIndex);
  UpdateIndependentYAxis(AGraphIndex);
  if (Slot <> nil) and (Slot.Chart <> nil) then Slot.Chart.InvalidateChart;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphRuntimeValuesReset', 'Очищены значения выбранного графика', Format(
    'Scope=SingleGraph; GraphIndex=%d; ResetTimeMs=%d; SeriesCount=%d; ClearedPointsCount=%d; AssignmentsPreserved=True; SharedSegmentPreserved=True; OtherGraphsAffected=False',
    [AGraphIndex, ResetTimeMs, ClearedSeriesCount, ClearedPointsCount]));
end;

procedure TFrameGraphsWorkspace.ResetRuntimeGraphData;
var
  Pair: TPair<TGraphSeriesConfig, TGraphSeriesRuntime>;
  Count, Cleared, PointIndex: Integer;
  PointKey: string;
begin
  Count := 0; Cleared := 0;
  FRuntimeResetTimeMs := TMeterValue.GetMonotonicTimeMs;
  ClearWorkspaceSegmentHistory;
  FLastFallbackSampleMs := 0;
  PointKey := CurrentPointKey(PointIndex);
  for Pair in FSeriesRuntime do
  begin
    Inc(Count); Inc(Cleared, Pair.Value.ChartSeries.Points.Count);
    Pair.Value.ChartSeries.ClearPoints; Pair.Value.LastSampleTimeMs := 0;
    Pair.Value.LastSampleIndex := -1; Pair.Value.WaitingForFirstSample := True;
    Pair.Value.RuntimeResetTimeMs := 0;
    Pair.Value.HistoryLoadMode := ghlmCurrentSegmentHistory;
    Pair.Value.HistoryLoaded := False;
    Pair.Value.LastAcceptedPointKey := PointKey;
  end;
  FSharedSegmentStartMs := FRuntimeResetTimeMs;
  FSharedTimeInitialized := False; FSharedCurrentTimeSec := 0;
  FSharedAxisMinX := 0; FSharedAxisMaxX := 60; FLastRunActive := False;
  FLastPointKey := PointKey; FLastPointIndex := PointIndex;
  ApplySharedXAxis; UpdateToleranceLines;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphRuntimeReset',
      'Сброшены runtime-данные графиков', Format(
      'Scope=AllGraphs; GraphCount=%d; SeriesCount=%d; ClearedPointsCount=%d; AssignmentsPreserved=True; VisibleDurationSec=%d',
      [FConfig.GraphCount, Count, Cleared, FConfig.VisibleDurationSec]));
end;

procedure TFrameGraphsWorkspace.UpdateGraphs;
const
  FallbackSampleIntervalMs = 1000;
var
  GraphIndex, PointIndex, SeriesProcessed, SeriesResolved,
    SeriesFailed, PointsAdded, GraphsInvalidated, SeriesAddedBefore: Integer;
  Config: TGraphSeriesConfig; Runtime: TGraphSeriesRuntime;
  Channel: TChannel; MeterValue: TMeterValue;
  Chart: TSimpleChart; NowMs: Int64;
  RunActive, SamplingActive, NewRunStarted, PointChanged, Changed,
    SegmentStartRequired, PointStateStored, DoFallback: Boolean;
  PointKey, StoredPointKey, SelectedReason, Decision, ResolveReason: string;
  SegmentReason: TGraphSegmentStartReason;
  VisualSeries: TChartSeries;
  RuntimeLastSampleTimeMs: Int64;
  RuntimeLastSampleIndex: Integer;
  RuntimeWaitingForFirstSample: Boolean;
begin
  if (FConfig = nil) or (FSeriesRuntime = nil) then Exit;
  if FWorkTable = nil then
  begin
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphWorkspaceUpdateDone',
        'Рабочая область графиков не обновлена',
        'SeriesProcessed=0; SeriesResolved=0; SeriesFailed=0; PointsAdded=0; GraphsInvalidated=0');
    Exit;
  end;
  EnsureDefaultEnabledSources;
  NowMs := TMeterValue.GetMonotonicTimeMs;
  RunActive := (FWorkTable <> nil) and
    (FWorkTable.MeasurementRun is TMeasurementRun) and
    not (TMeasurementRun(FWorkTable.MeasurementRun).Stage in [msNone, msDone]);
  SamplingActive := IsSamplingActive and not IsPointTransitionStage;
  DoFallback := SamplingActive and
    ((FLastFallbackSampleMs = 0) or
     (NowMs - FLastFallbackSampleMs >= FallbackSampleIntervalMs));
  PointKey := CurrentPointKey(PointIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphWorkspaceUpdateBegin',
      'Начато обновление визуальных серий рабочей области', Format(
      'GraphCount=%d; RunActive=%s; SamplingActive=%s; SegmentStartMs=%d; RuntimeResetTimeMs=%d; CurrentPointKey=%s',
      [FConfig.GraphCount, BoolToStr(RunActive, True),
       BoolToStr(SamplingActive, True), FSharedSegmentStartMs,
       FRuntimeResetTimeMs, PointKey]));
  StoredPointKey := FLastPointKey;
  NewRunStarted := RunActive and not FLastRunActive;
  PointChanged := (PointKey <> '') and
    (FLastPointKey <> '') and (PointKey <> FLastPointKey);
  SegmentReason := gssrNone;
  if NewRunStarted then
    SegmentReason := gssrRunStarted
  else if PointChanged then
    SegmentReason := gssrPointChanged;
  SegmentStartRequired := SegmentReason <> gssrNone;
  case SegmentReason of
    gssrRunStarted: SelectedReason := 'RunStarted';
    gssrPointChanged: SelectedReason := 'PointChanged';
  else
    SelectedReason := 'None';
  end;
  Decision := Format('%s|%s|%s|%s|%s|%s|%s',
    [BoolToStr(RunActive, True), BoolToStr(FLastRunActive, True),
     BoolToStr(NewRunStarted, True), PointKey, StoredPointKey,
     BoolToStr(PointChanged, True), SelectedReason]);
  if (Decision <> FLastSegmentDecision) and Assigned(ProtocolManager) then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSegmentDecision',
      'Принято решение о временном сегменте графиков', Format(
      'RunActive=%s; LastRunActive=%s; NewRunStarted=%s; CurrentPointKey=%s; StoredPointKey=%s; PointChanged=%s; SelectedReason=%s; SegmentStartRequired=%s',
      [BoolToStr(RunActive, True), BoolToStr(FLastRunActive, True),
       BoolToStr(NewRunStarted, True), PointKey, StoredPointKey,
       BoolToStr(PointChanged, True), SelectedReason,
       BoolToStr(SegmentStartRequired, True)]));
    FLastSegmentDecision := Decision;
  end;
  PointStateStored := (PointKey <> '') and
    ((FLastPointKey <> PointKey) or (FLastPointIndex <> PointIndex));
  if SegmentStartRequired then
    StartSharedSegment(SegmentReason, PointKey, PointIndex);
  if PointKey <> '' then
  begin
    FLastPointKey := PointKey;
    FLastPointIndex := PointIndex;
  end;
  if PointStateStored and Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphPointStateStored',
      'Сохранено состояние поверочной точки графиков', Format(
      'PointKey=%s; PointIndex=%d', [PointKey, PointIndex]));
  CheckFlowUnitsChanged;
  CalculateSharedTimeRange(NowMs);

  SeriesProcessed := 0;
  SeriesResolved := 0;
  SeriesFailed := 0;
  PointsAdded := 0;
  GraphsInvalidated := 0;
  for GraphIndex := 0 to FConfig.GraphCount - 1 do
  begin
    Chart := ChartByIndex(GraphIndex); Changed := False;
    for Config in FConfig.Panels[GraphIndex].Series do
    begin
      Inc(SeriesProcessed);
      VisualSeries := EnsureVisualSeries(GraphIndex, Config);
      Runtime := nil;
      FSeriesRuntime.TryGetValue(Config, Runtime);
      RuntimeLastSampleTimeMs := 0;
      RuntimeLastSampleIndex := -1;
      RuntimeWaitingForFirstSample := False;
      if Runtime <> nil then
      begin
        RuntimeLastSampleTimeMs := Runtime.LastSampleTimeMs;
        RuntimeLastSampleIndex := Runtime.LastSampleIndex;
        RuntimeWaitingForFirstSample := Runtime.WaitingForFirstSample;
      end;
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesUpdateBegin',
          'Начато обновление пользовательской серии', Format(
          'GraphIndex=%d; ChannelUUID=%s; OwnerKind=%d; MeterValueKey=%s; VisualSeriesAssigned=%s; Visible=%s; LastSampleTimeMs=%d; LastSampleIndex=%d; WaitingForFirstSample=%s',
          [GraphIndex, Config.ChannelUUID, Ord(Config.OwnerKind),
           Config.MeterValueKey, BoolToStr(VisualSeries <> nil, True),
           BoolToStr(Config.Visible, True),
           RuntimeLastSampleTimeMs, RuntimeLastSampleIndex,
           BoolToStr(RuntimeWaitingForFirstSample, True)]));
      if VisualSeries = nil then
      begin
        Inc(SeriesFailed);
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm,
            'GraphSeriesSourceResolveFailed', 'Визуальная серия недоступна',
            Format('GraphIndex=%d; ChannelUUID=%s; Reason=VisualSeriesMissing',
              [GraphIndex, Config.ChannelUUID]));
        Continue;
      end;
      VisualSeries.Visible := Config.Visible;
      if not Config.Visible then
      begin
        Inc(SeriesFailed);
        Continue;
      end;
      if not ResolveSeriesSource(Config, Channel, MeterValue, ResolveReason) then
      begin
        Inc(SeriesFailed);
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm,
            'GraphSeriesSourceResolveFailed', 'Источник серии не разрешён',
            Format('GraphIndex=%d; ChannelUUID=%s; Reason=%s',
              [GraphIndex, Config.ChannelUUID, ResolveReason]));
        Continue;
      end;
      Inc(SeriesResolved);
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphSeriesSourceResolved',
          'Источник пользовательской серии разрешён', Format(
          'GraphIndex=%d; ChannelUUID=%s; ChannelAssigned=True; MeterValueAssigned=True; MeterValueClass=%s; SampleBufferAvailable=True',
          [GraphIndex, Config.ChannelUUID, MeterValue.ClassName]));
      if not Channel.Enabled then
      begin
        VisualSeries.Visible := False;
        Inc(SeriesFailed);
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm,
            'GraphSeriesSourceResolveFailed', 'Канал источника отключён',
            Format('GraphIndex=%d; ChannelUUID=%s; Reason=ChannelDisabled',
              [GraphIndex, Config.ChannelUUID]));
        Continue;
      end;
      VisualSeries.Visible := Config.Visible;
      if (Runtime <> nil) and not Runtime.HistoryLoaded then
      begin
        SeriesAddedBefore := VisualSeries.Points.Count;
        LoadSeriesCurrentSegmentHistory(GraphIndex, Config, Runtime);
        if VisualSeries.Points.Count > SeriesAddedBefore then Changed := True;
      end;
      if not SamplingActive then
        Continue;
      SeriesAddedBefore := PointsAdded;
      UpdateSeriesPoints(GraphIndex, Config, VisualSeries, MeterValue,
        NowMs, DoFallback, SamplingActive, PointsAdded);
      if PointsAdded > SeriesAddedBefore then
        Changed := True;
      while (FConfig.VisibleDurationSec > 0) and
        (VisualSeries.Points.Count > 0) and
        (VisualSeries.Points[0].X < FSharedAxisMinX) do
        VisualSeries.Points.Delete(0);
    end;
    if Changed then
    begin
      UpdateIndependentYAxis(GraphIndex);
      Chart.InvalidateChart;
      Inc(GraphsInvalidated);
    end;
    if Changed then UpdateIndependentYAxis(GraphIndex);
  end;
  ApplySharedXAxis;
  UpdateToleranceLines;
  if DoFallback then
    FLastFallbackSampleMs := NowMs;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphWorkspaceUpdateDone',
      'Обновление визуальных серий рабочей области завершено', Format(
      'SeriesProcessed=%d; SeriesResolved=%d; SeriesFailed=%d; PointsAdded=%d; GraphsInvalidated=%d',
      [SeriesProcessed, SeriesResolved, SeriesFailed, PointsAdded,
       GraphsInvalidated]));
  FLastRunActive := RunActive;
end;

end.
