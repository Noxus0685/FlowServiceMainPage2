unit frmGraphsWorkspace;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections,
  FMX.Controls, FMX.Forms, FMX.Layouts, FMX.Menus, FMX.Objects,
  FMX.StdCtrls, FMX.Types, FMX.SimpleChart,
  uBaseProcedures, uClasses, uDeviceClass, uGraphsViewConfig, uMeasurementRun, uMeterValue, uProtocols,
  uWorkTable;

type
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

  TGraphSeriesRuntime = class
  public
    ChartSeries: TChartSeries;
    LastSampleTimeMs: Int64;
    LastSampleIndex: Integer;
    WaitingForFirstSample: Boolean;
    LastAcceptedValue: Double;
    LastAcceptedPointKey: string;
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
    LayoutArea1: TLayout;
    LayoutArea2: TLayout;
    LayoutArea3: TLayout;
    LayoutArea4: TLayout;
    LayoutParking: TLayout;
    SplitterArea1: TSplitter;
    SplitterArea2: TSplitter;
    SplitterArea3: TSplitter;
    LayoutGraphSlot1: TLayout;
    LabelGraphTitle1: TLabel;
    ChartGraph1: TSimpleChart;
    RectangleGraphHit1: TRectangle;
    LayoutGraphSlot2: TLayout;
    LabelGraphTitle2: TLabel;
    ChartGraph2: TSimpleChart;
    RectangleGraphHit2: TRectangle;
    LayoutGraphSlot3: TLayout;
    LabelGraphTitle3: TLabel;
    ChartGraph3: TSimpleChart;
    RectangleGraphHit3: TRectangle;
    LayoutGraphSlot4: TLayout;
    LabelGraphTitle4: TLabel;
    ChartGraph4: TSimpleChart;
    RectangleGraphHit4: TRectangle;
    PopupMenuGraph: TPopupMenu;
    MenuItemEtalons: TMenuItem;
    MenuItemDevices: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemSeriesColors: TMenuItem;
    MenuItemGraphLength: TMenuItem;
    MenuItemFlowUnits: TMenuItem;
    MenuItemShowLegend: TMenuItem;
    MenuItemAddGraph: TMenuItem;
    MenuItemDeleteGraph: TMenuItem;
    MenuItemClearGraph: TMenuItem;
    procedure GraphLayoutChange(Sender: TObject);
    procedure ClearAllClick(Sender: TObject);
    procedure ResetClick(Sender: TObject);
    procedure GraphControlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GraphHitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GraphPopup(Sender: TObject);
    procedure ClearGraphClick(Sender: TObject);
    procedure SeriesColorClick(Sender: TObject);
    procedure GraphDurationClick(Sender: TObject);
    procedure ShowLegendClick(Sender: TObject);
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
    FTargetSeries: array[0..3] of TChartSeries;
    FLowerSeries: array[0..3] of TChartSeries;
    FUpperSeries: array[0..3] of TChartSeries;
    FLastFallbackSampleMs: Int64;
    FLastUpdateDiagnosticMs: Int64;
    function ChartByIndex(const AIndex: Integer): TSimpleChart;
    function SlotByIndex(const AIndex: Integer): TLayout;
    function AreaByIndex(const AIndex: Integer): TLayout;
    procedure SelectGraph(const AIndex: Integer);
    procedure SyncControls;
    procedure ClearChart(const AIndex: Integer; const AClearAssignments: Boolean);
    procedure PlaceSlot(const ASlot, AArea: Integer; const AAlign: TAlignLayout);
    procedure ClearDynamicMenu(AParent: TMenuItem);
    procedure BuildSourceMenu(out AEtalonCount, ADeviceCount: Integer);
    procedure BuildSeriesColorsMenu;
    procedure UpdateGraphSettingsMenu;
    function NextSeriesColor(const AGraphIndex: Integer): TAlphaColor;
    function FindSeries(const AGraphIndex: Integer; const AChannelUUID,
      AMeterValueKey: string): TGraphSeriesConfig;
    procedure DeleteSource(const AGraphIndex: Integer; ASeries: TGraphSeriesConfig);
    procedure NormalizeLayout;
    procedure AddEmptyMenuItem(AParent: TMenuItem; const ACaption: string);
    procedure AddChannelMenuItem(AParent: TMenuItem; AChannel: TChannel;
      const AOwnerKind: TGraphSeriesOwnerKind);
    function ResolveChannel(const ASeries: TGraphSeriesConfig): TChannel;
    function ResolveMeterValue(const ASeries: TGraphSeriesConfig;
      AChannel: TChannel): TMeterValue;
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
    procedure UpdateIndependentYAxis(const AGraphIndex: Integer);
    procedure RemoveRuntimeSeries(const AConfig: TGraphSeriesConfig;
      AChart: TSimpleChart);
    procedure RemoveGraphRuntimeSeries(const AGraphIndex: Integer);
  public
    destructor Destroy; override;
    procedure Initialize(AWorkTable: TWorkTable);
    procedure UpdateGraphs;
    procedure ApplyLayout;
    procedure ClearGraph(const AGraphIndex: Integer);
    procedure ClearAllGraphs;
    procedure ResetRuntimeGraphData;
    function AddSource(const AGraphIndex: Integer;
      ASource: TGraphSeriesConfig): Boolean;
  end;

implementation

{$R *.fmx}

destructor TFrameGraphsWorkspace.Destroy;
begin
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
    raise EInvalidOperation.Create(
      'PopupMenuGraph не загружен из frmGraphsWorkspace.fmx');
  if MenuItemEtalons = nil then
    raise EInvalidOperation.Create(
      'MenuItemEtalons не загружен из frmGraphsWorkspace.fmx');
  if MenuItemDevices = nil then
    raise EInvalidOperation.Create(
      'MenuItemDevices не загружен из frmGraphsWorkspace.fmx');
  FWorkTable := AWorkTable;
  FirstInitialization := FConfig = nil;
  if FConfig = nil then
  begin
    FConfig := TGraphsViewConfig.Create;
    FSeriesRuntime := TObjectDictionary<TGraphSeriesConfig,
      TGraphSeriesRuntime>.Create([doOwnsValues]);
    FSelectedGraph := 0;
    FContextGraphIndex := 0;
    FLastPointIndex := -1;
    FSharedAxisMinX := 0;
    FSharedAxisMaxX := 60;
    FRuntimeResetTimeMs := TMeterValue.GetMonotonicTimeMs;
  end;
  SyncControls;
  ApplyLayout;
  if FirstInitialization then
  begin
    FLastPointKey := CurrentPointKey(PointIndex);
    FLastPointIndex := PointIndex;
    ApplySharedXAxis;
    UpdateToleranceLines;
  end;
end;

function TFrameGraphsWorkspace.ChartByIndex(const AIndex: Integer): TSimpleChart;
begin
  case AIndex of
    0: Result := ChartGraph1; 1: Result := ChartGraph2;
    2: Result := ChartGraph3; 3: Result := ChartGraph4;
  else Result := nil end;
end;

function TFrameGraphsWorkspace.SlotByIndex(const AIndex: Integer): TLayout;
begin
  case AIndex of
    0: Result := LayoutGraphSlot1; 1: Result := LayoutGraphSlot2;
    2: Result := LayoutGraphSlot3; 3: Result := LayoutGraphSlot4;
  else Result := nil end;
end;

function TFrameGraphsWorkspace.AreaByIndex(const AIndex: Integer): TLayout;
begin
  case AIndex of
    0: Result := LayoutArea1; 1: Result := LayoutArea2;
    2: Result := LayoutArea3; 3: Result := LayoutArea4;
  else Result := LayoutArea1 end;
end;

procedure TFrameGraphsWorkspace.PlaceSlot(const ASlot, AArea: Integer;
  const AAlign: TAlignLayout);
var Slot: TLayout;
begin
  Slot := SlotByIndex(ASlot);
  Slot.Parent := AreaByIndex(AArea);
  Slot.Align := AAlign;
  Slot.Visible := True;
end;

procedure TFrameGraphsWorkspace.ApplyLayout;
var I: Integer; Slot: TLayout;
begin
  if FConfig = nil then Exit;
  for I := 0 to 3 do
  begin
    Slot := SlotByIndex(I);
    Slot.Parent := LayoutParking;
    Slot.Visible := False;
  end;
  for I := 0 to 3 do AreaByIndex(I).Visible := False;
  LayoutArea1.Align := TAlignLayout.Client;
  case FConfig.LayoutKind of
    glSingle: begin LayoutArea1.Visible := True; PlaceSlot(0, 0, TAlignLayout.Client); end;
    glTwoRows:
      begin
        LayoutArea1.Visible := True; LayoutArea1.Align := TAlignLayout.Top; LayoutArea1.Height := LayoutGraphsHost.Height / 2;
        LayoutArea2.Visible := True; LayoutArea2.Align := TAlignLayout.Client;
        PlaceSlot(0, 0, TAlignLayout.Client);
        if FConfig.GraphCount = 3 then begin PlaceSlot(1, 0, TAlignLayout.Left); LayoutGraphSlot2.Width := LayoutArea1.Width / 2; LayoutGraphSlot1.Align := TAlignLayout.Client; PlaceSlot(2, 1, TAlignLayout.Client); end
        else PlaceSlot(1, 1, TAlignLayout.Client);
      end;
    glTwoColumns:
      begin
        LayoutArea1.Visible := True; LayoutArea1.Align := TAlignLayout.Left; LayoutArea1.Width := LayoutGraphsHost.Width / 2;
        LayoutArea2.Visible := True; LayoutArea2.Align := TAlignLayout.Client;
        PlaceSlot(0, 0, TAlignLayout.Client);
        if FConfig.GraphCount = 3 then begin PlaceSlot(1, 0, TAlignLayout.Top); LayoutGraphSlot2.Height := LayoutArea1.Height / 2; LayoutGraphSlot1.Align := TAlignLayout.Client; PlaceSlot(2, 1, TAlignLayout.Client); end
        else PlaceSlot(1, 1, TAlignLayout.Client);
      end;
    glThreePanels:
      for I := 0 to Min(2, FConfig.GraphCount - 1) do begin AreaByIndex(I).Visible := True; AreaByIndex(I).Align := TAlignLayout.Left; AreaByIndex(I).Width := LayoutGraphsHost.Width / 3; PlaceSlot(I, I, TAlignLayout.Client); end;
    glGrid2x2:
      for I := 0 to FConfig.GraphCount - 1 do begin AreaByIndex(I).Visible := True; AreaByIndex(I).Align := TAlignLayout.None; AreaByIndex(I).Position.X := (I mod 2) * LayoutGraphsHost.Width / 2; AreaByIndex(I).Position.Y := (I div 2) * LayoutGraphsHost.Height / 2; AreaByIndex(I).Width := LayoutGraphsHost.Width / 2; AreaByIndex(I).Height := LayoutGraphsHost.Height / 2; PlaceSlot(I, I, TAlignLayout.Client); end;
  end;
  for I := 0 to FConfig.GraphCount - 1 do
  begin
    if not SlotByIndex(I).Visible then PlaceSlot(I, Min(I, 3), TAlignLayout.Client);
    ChartByIndex(I).ShowLegend := FConfig.Panels[I].ShowLegend;
  end;
  { Align/Parent changes above enqueue FMX alignment automatically.  Realign is
    protected in the Delphi version used by the application and must not be
    called from the frame. }
  ApplySharedXAxis;
end;

procedure TFrameGraphsWorkspace.SyncControls;
begin
  FUpdatingControls := True;
  try
    ComboGraphLayout.ItemIndex := Ord(FConfig.LayoutKind);
  finally
    FUpdatingControls := False;
  end;
end;



procedure TFrameGraphsWorkspace.GraphLayoutChange(Sender: TObject);
begin
  if FUpdatingControls or (FConfig = nil) then Exit;
  FConfig.LayoutKind := TGraphLayoutKind(ComboGraphLayout.ItemIndex); ApplyLayout;
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
    if SameText(S.ChannelUUID, AChannelUUID) and
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
begin
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
  MenuItemAddGraph.Enabled := FConfig.GraphCount < 4;
  MenuItemDeleteGraph.Enabled := FConfig.GraphCount > 1;
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

procedure TFrameGraphsWorkspace.NormalizeLayout;
begin
  if FConfig.GraphCount = 1 then FConfig.LayoutKind := glSingle
  else if FConfig.GraphCount = 2 then
  begin
    if not (FConfig.LayoutKind in [glTwoRows, glTwoColumns]) then
      FConfig.LayoutKind := glTwoRows;
  end
  else if FConfig.GraphCount = 3 then
  begin
    if not (FConfig.LayoutKind in [glTwoRows, glTwoColumns, glThreePanels]) then
      FConfig.LayoutKind := glThreePanels;
  end
  else FConfig.LayoutKind := glGrid2x2;
  SyncControls;
end;

procedure TFrameGraphsWorkspace.AddGraphClick(Sender: TObject);
var OldCount: Integer;
begin
  OldCount := FConfig.GraphCount;
  if OldCount >= 4 then Exit;
  FConfig.EnsurePanelCount(OldCount + 1);
  NormalizeLayout; ApplyLayout; SelectGraph(FConfig.GraphCount - 1);
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcProc, psForm,
    'GraphAdded', 'Добавлен график', Format('GraphIndex=%d; OldGraphCount=%d; NewGraphCount=%d',
    [FSelectedGraph, OldCount, FConfig.GraphCount]));
end;

procedure TFrameGraphsWorkspace.DeleteGraphClick(Sender: TObject);
var
  OldCount, DeletedIndex, I, PointIndex: Integer;
  S: TGraphSeriesConfig;
  Runtime: TGraphSeriesRuntime;
  SavedPoints: TDictionary<TGraphSeriesConfig, TArray<TPointF>>;
  Points: TArray<TPointF>;
  Chart: TSimpleChart;
begin
  OldCount := FConfig.GraphCount;
  if OldCount <= 1 then Exit;
  DeletedIndex := FContextGraphIndex;
  SavedPoints := TDictionary<TGraphSeriesConfig, TArray<TPointF>>.Create;
  try
    { Snapshot the shifted panels' displayed points before their series are
      rebound to the designer charts on the left. }
    for I := DeletedIndex + 1 to OldCount - 1 do
      for S in FConfig.Panels[I].Series do
        if FSeriesRuntime.TryGetValue(S, Runtime) and
           (Runtime.ChartSeries <> nil) then
        begin
          SetLength(Points, Runtime.ChartSeries.Points.Count);
          for PointIndex := 0 to Runtime.ChartSeries.Points.Count - 1 do
            Points[PointIndex] := Runtime.ChartSeries.Points[PointIndex];
          SavedPoints.Add(S, Points);
        end;
    for I := DeletedIndex to OldCount - 1 do RemoveGraphRuntimeSeries(I);
    FConfig.DeletePanel(DeletedIndex);
    for I := DeletedIndex to FConfig.GraphCount - 1 do
    begin
      Chart := ChartByIndex(I);
      for S in FConfig.Panels[I].Series do
      begin
        SetLength(Points, 0);
        S.GraphIndex := I;
        Runtime := TGraphSeriesRuntime.Create;
        Runtime.ChartSeries := Chart.AddSeries(S.Caption);
        Runtime.ChartSeries.Color := S.Color;
        Runtime.LastSampleIndex := -1;
        Runtime.WaitingForFirstSample := True;
        if SavedPoints.TryGetValue(S, Points) then
          for PointIndex := 0 to High(Points) do
            Runtime.ChartSeries.AddPoint(Points[PointIndex].X, Points[PointIndex].Y);
        if Length(Points) > 0 then
          Runtime.LastSampleTimeMs := FSharedSegmentStartMs +
            Round(Points[High(Points)].X * 1000);
        FSeriesRuntime.Add(S, Runtime);
      end;
      Chart.InvalidateChart;
    end;
  finally
    SavedPoints.Free;
  end;
  NormalizeLayout; ApplyLayout;
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
  end;
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
      FSeriesRuntime[ASource].WaitingForFirstSample := True;
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
      if (Channel <> nil) and SameText(Channel.UUID, ASeries.ChannelUUID) then
        Exit(Channel);
  if (ASeries.OwnerKind = gsokDevice) and
     (FWorkTable.DeviceChannels <> nil) then
    for Channel in FWorkTable.DeviceChannels do
      if (Channel <> nil) and SameText(Channel.UUID, ASeries.ChannelUUID) then
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
var
  Pair: TPair<TGraphSeriesConfig, TGraphSeriesRuntime>;
  Channel: TChannel;
  MeterValue: TMeterValue;
  Samples: TArray<TMeterValueSample>;
  Sample: TMeterValueSample;
begin
  for Pair in FSeriesRuntime do
  begin
    Pair.Value.ChartSeries.ClearPoints;
    Pair.Value.LastSampleTimeMs := 0;
    Pair.Value.LastSampleIndex := -1;
    Channel := ResolveChannel(Pair.Key);
    MeterValue := ResolveMeterValue(Pair.Key, Channel);
    if MeterValue = nil then Continue;
    Samples := MeterValue.GetStabilitySamples;
    for Sample in Samples do
      if (Sample.TimeStampMs >= FSharedSegmentStartMs) and
         (Sample.TimeStampMs > Pair.Value.LastSampleTimeMs) then
      begin
        Pair.Value.ChartSeries.AddPoint(
          (Sample.TimeStampMs - FSharedSegmentStartMs) / 1000.0,
          IfThen(SameText(Pair.Key.MeterValueKey, 'ValueFlow') or
            SameText(Pair.Key.MeterValueKey, 'FlowRate'),
            ConvertFlowToDisplayUnits(Sample.Value), Sample.Value));
        Pair.Value.LastSampleTimeMs := Sample.TimeStampMs;
      end;
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
  ResetSeriesSegment(StartMs, APointKey);
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
var Chart: TSimpleChart;
begin
  Chart := ChartByIndex(AGraphIndex);
  if FTargetSeries[AGraphIndex] = nil then
  begin
    FTargetSeries[AGraphIndex] := Chart.AddSeries('Целевой расход');
    FTargetSeries[AGraphIndex].Color := TAlphaColors.Green;
    FTargetSeries[AGraphIndex].ShowMarkers := False;
    FLowerSeries[AGraphIndex] := Chart.AddSeries('Нижняя допустимая граница');
    FLowerSeries[AGraphIndex].Color := TAlphaColors.Red;
    FLowerSeries[AGraphIndex].ShowMarkers := False;
    FUpperSeries[AGraphIndex] := Chart.AddSeries('Верхняя допустимая граница');
    FUpperSeries[AGraphIndex].Color := TAlphaColors.Red;
    FUpperSeries[AGraphIndex].ShowMarkers := False;
  end;
end;

procedure TFrameGraphsWorkspace.UpdateToleranceLines;
var
  I: Integer; Run: TMeasurementRun; Point: TDevicePoint;
  MinPercent, MaxPercent, BaseLower, BaseUpper: Double;
  Available: Boolean;
begin
  Run := nil; Point := nil;
  if (FWorkTable <> nil) and (FWorkTable.MeasurementRun is TMeasurementRun) then
  begin
    Run := TMeasurementRun(FWorkTable.MeasurementRun); Point := Run.CurrentPoint;
  end;
  Available := (Point <> nil) and AccuracyToRange(Point.FlowAccuracy,
    MinPercent, MaxPercent);
  if Available then
    CalculateTargetLimits(Point.Q, Abs(MaxPercent), Abs(MinPercent), 0,
      BaseLower, BaseUpper);
  if Assigned(ProtocolManager) and (FLastUpdateDiagnosticMs = 0) then
    if Available then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphToleranceResolved',
        'Разрешены границы допуска графиков', Format(
        'PointAssigned=True; BaseTarget=%g; BaseLower=%g; BaseUpper=%g; DisplayUnit=%s; DisplayTarget=%g; DisplayLower=%g; DisplayUpper=%g',
        [Point.Q, BaseLower, BaseUpper, GetCurrentFlowUnitText,
         ConvertFlowToDisplayUnits(Point.Q), ConvertFlowToDisplayUnits(BaseLower),
         ConvertFlowToDisplayUnits(BaseUpper)]))
    else
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphToleranceUnavailable',
        'Границы допуска графиков недоступны',
        'PointAssigned=' + BoolToStr(Point <> nil, True));
  for I := 0 to FConfig.GraphCount - 1 do
  begin
    EnsureLimitSeries(I);
    FTargetSeries[I].ClearPoints; FLowerSeries[I].ClearPoints;
    FUpperSeries[I].ClearPoints;
    FTargetSeries[I].Visible := Point <> nil;
    FLowerSeries[I].Visible := Available; FUpperSeries[I].Visible := Available;
    if Point <> nil then
    begin
      FTargetSeries[I].AddPoint(FSharedAxisMinX, ConvertFlowToDisplayUnits(Point.Q));
      FTargetSeries[I].AddPoint(FSharedAxisMaxX, ConvertFlowToDisplayUnits(Point.Q));
    end;
    if Available then
    begin
      FLowerSeries[I].AddPoint(FSharedAxisMinX, ConvertFlowToDisplayUnits(BaseLower));
      FLowerSeries[I].AddPoint(FSharedAxisMaxX, ConvertFlowToDisplayUnits(BaseLower));
      FUpperSeries[I].AddPoint(FSharedAxisMinX, ConvertFlowToDisplayUnits(BaseUpper));
      FUpperSeries[I].AddPoint(FSharedAxisMaxX, ConvertFlowToDisplayUnits(BaseUpper));
    end;
    UpdateIndependentYAxis(I);
  end;
  if Assigned(ProtocolManager) and Available and
     (FLastUpdateDiagnosticMs = 0) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphToleranceLinesUpdated',
      'Обновлены линии допуска графиков', Format(
      'GraphCount=%d; AxisMinX=%g; AxisMaxX=%g',
      [FConfig.GraphCount, FSharedAxisMinX, FSharedAxisMaxX]));
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

procedure TFrameGraphsWorkspace.ResetRuntimeGraphData;
var
  Pair: TPair<TGraphSeriesConfig, TGraphSeriesRuntime>;
  Count, Cleared, PointIndex: Integer;
  PointKey: string;
begin
  Count := 0; Cleared := 0;
  FRuntimeResetTimeMs := TMeterValue.GetMonotonicTimeMs;
  PointKey := CurrentPointKey(PointIndex);
  for Pair in FSeriesRuntime do
  begin
    Inc(Count); Inc(Cleared, Pair.Value.ChartSeries.Points.Count);
    Pair.Value.ChartSeries.ClearPoints; Pair.Value.LastSampleTimeMs := 0;
    Pair.Value.LastSampleIndex := -1; Pair.Value.WaitingForFirstSample := True;
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
      'GraphCount=%d; SeriesCount=%d; ClearedPointsCount=%d; AssignmentsPreserved=True; VisibleDurationSec=%d',
      [FConfig.GraphCount, Count, Cleared, FConfig.VisibleDurationSec]));
end;

procedure TFrameGraphsWorkspace.UpdateGraphs;
var
  GraphIndex, SampleIndex, PointIndex: Integer;
  Config: TGraphSeriesConfig; Runtime: TGraphSeriesRuntime;
  Channel: TChannel; MeterValue: TMeterValue;
  Samples: TArray<TMeterValueSample>; Sample: TMeterValueSample;
  Chart: TSimpleChart; NowMs: Int64; TimeSec, Value: Double;
  RunActive, SamplingActive, NewRunStarted, PointChanged, Changed,
    SegmentStartRequired, PointStateStored: Boolean;
  PointKey, StoredPointKey, SelectedReason, Decision: string;
  SegmentReason: TGraphSegmentStartReason;
begin
  if (FConfig = nil) or (FSeriesRuntime = nil) then Exit;
  NowMs := TMeterValue.GetMonotonicTimeMs;
  RunActive := (FWorkTable <> nil) and
    (FWorkTable.MeasurementRun is TMeasurementRun) and
    not (TMeasurementRun(FWorkTable.MeasurementRun).Stage in [msNone, msDone]);
  SamplingActive := IsSamplingActive and not IsPointTransitionStage;
  PointKey := CurrentPointKey(PointIndex);
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

  for GraphIndex := 0 to FConfig.GraphCount - 1 do
  begin
    Chart := ChartByIndex(GraphIndex); Changed := False;
    for Config in FConfig.Panels[GraphIndex].Series do
    begin
      if not FSeriesRuntime.TryGetValue(Config, Runtime) then
      begin
        Runtime := TGraphSeriesRuntime.Create;
        Runtime.ChartSeries := Chart.AddSeries(Config.Caption);
        Runtime.ChartSeries.Color := Config.Color;
        Runtime.LastSampleIndex := -1; Runtime.WaitingForFirstSample := True;
        FSeriesRuntime.Add(Config, Runtime);
      end;
      Channel := ResolveChannel(Config); MeterValue := ResolveMeterValue(Config, Channel);
      if (not SamplingActive) or (Channel = nil) or not Channel.Enabled or
         (MeterValue = nil) or (PointKey = '') then Continue;
      Samples := MeterValue.GetStabilitySamples;
      for SampleIndex := 0 to High(Samples) do
      begin
        Sample := Samples[SampleIndex];
        if (Sample.TimeStampMs < FSharedSegmentStartMs) or
           (Sample.TimeStampMs <= Runtime.LastSampleTimeMs) then Continue;
        Runtime.LastSampleTimeMs := Sample.TimeStampMs;
        Runtime.LastSampleIndex := SampleIndex;
        Value := Sample.Value;
        if IsNan(Value) or IsInfinite(Value) or (Abs(Value) >= MaxDouble) then Continue;
        if Runtime.WaitingForFirstSample and SameValue(Value, 0.0, 1E-12) then
          Continue;
        TimeSec := (Sample.TimeStampMs - FSharedSegmentStartMs) / 1000.0;
        if SameText(Config.MeterValueKey, 'ValueFlow') or
           SameText(Config.MeterValueKey, 'FlowRate') then
          Value := ConvertFlowToDisplayUnits(Value);
        Runtime.ChartSeries.AddPoint(TimeSec, Value);
        if Runtime.WaitingForFirstSample and Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm, 'GraphPointFirstSampleAccepted',
            'Принят первый отсчёт сегмента', Format(
            'GraphIndex=%d; ChannelUUID=%s; PointKey=%s; SampleTimeMs=%d; Value=%g; TimeSec=%g',
            [GraphIndex, Config.ChannelUUID, PointKey, Sample.TimeStampMs,
             Sample.Value, TimeSec]));
        Runtime.WaitingForFirstSample := False;
        Runtime.LastAcceptedValue := Sample.Value;
        Runtime.LastAcceptedPointKey := PointKey; Changed := True;
      end;
      while (FConfig.VisibleDurationSec > 0) and
        (Runtime.ChartSeries.Points.Count > 0) and
        (Runtime.ChartSeries.Points[0].X < FSharedAxisMinX) do
        Runtime.ChartSeries.Points.Delete(0);
    end;
    if Changed then UpdateIndependentYAxis(GraphIndex);
  end;
  ApplySharedXAxis;
  UpdateToleranceLines;
  for GraphIndex := 0 to FConfig.GraphCount - 1 do ChartByIndex(GraphIndex).InvalidateChart;
  FLastRunActive := RunActive;
end;

end.
