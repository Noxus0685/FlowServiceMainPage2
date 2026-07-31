unit frmGraphsWorkspace;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections,
  FMX.Controls, FMX.Forms, FMX.Layouts, FMX.Menus, FMX.Objects,
  FMX.StdCtrls, FMX.Types, FMX.SimpleChart,
  uBaseProcedures, uGraphsViewConfig, uMeasurementRun, uMeterValue, uProtocols,
  uWorkTable;

type
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
    FSegmentStartMs: Int64;
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
    procedure ResetSeriesSegment(const AStartMs: Int64);
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
  if FConfig = nil then
  begin
    FConfig := TGraphsViewConfig.Create;
    FSeriesRuntime := TObjectDictionary<TGraphSeriesConfig,
      TGraphSeriesRuntime>.Create([doOwnsValues]);
    FSelectedGraph := 0;
    FContextGraphIndex := 0;
  end;
  SyncControls;
  ApplyLayout;
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
    Item.IsChecked := FConfig.Panels[FContextGraphIndex].VisibleDurationSec = Durations[I];
    Item.OnClick := GraphDurationClick;
    MenuItemGraphLength.AddObject(Item);
  end;
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
  OldValue := FConfig.Panels[FContextGraphIndex].VisibleDurationSec;
  FConfig.Panels[FContextGraphIndex].VisibleDurationSec := Item.DurationSec;
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
        if SavedPoints.TryGetValue(S, Points) then
          for PointIndex := 0 to High(Points) do
            Runtime.ChartSeries.AddPoint(Points[PointIndex].X, Points[PointIndex].Y);
        if Length(Points) > 0 then
          Runtime.LastSampleTimeMs := FSegmentStartMs +
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
begin ClearChart(AGraphIndex, True) end;
procedure TFrameGraphsWorkspace.ClearAllGraphs;
var I: Integer; begin if FConfig <> nil then for I := 0 to FConfig.GraphCount - 1 do ClearChart(I, True) end;
procedure TFrameGraphsWorkspace.ClearAllClick(Sender: TObject); begin ClearAllGraphs end;
procedure TFrameGraphsWorkspace.ClearGraphClick(Sender: TObject);
begin
  ClearGraph(FContextGraphIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphCleared',
      'График очищен', Format('GraphIndex=%d', [FContextGraphIndex]));
end;
procedure TFrameGraphsWorkspace.ResetClick(Sender: TObject); begin FConfig.Reset; SyncControls; ApplyLayout end;

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

procedure TFrameGraphsWorkspace.ResetSeriesSegment(const AStartMs: Int64);
var
  Pair: TPair<TGraphSeriesConfig, TGraphSeriesRuntime>;
begin
  FSegmentStartMs := AStartMs;
  if FSeriesRuntime = nil then
    Exit;
  for Pair in FSeriesRuntime do
    if Pair.Value <> nil then
    begin
      Pair.Value.LastSampleTimeMs := 0;
      Pair.Value.LastSampleIndex := -1;
      if Pair.Value.ChartSeries <> nil then
        Pair.Value.ChartSeries.ClearPoints;
    end;
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

procedure TFrameGraphsWorkspace.UpdateGraphs;
const
  DiagnosticIntervalMs = 5000;
  FallbackSampleIntervalMs = 1000;
var
  GraphIndex, SampleIndex, AddedCount: Integer;
  Config: TGraphSeriesConfig;
  Runtime: TGraphSeriesRuntime;
  Channel: TChannel;
  MeterValue: TMeterValue;
  Samples: TArray<TMeterValueSample>;
  Sample: TMeterValueSample;
  Chart: TSimpleChart;
  ChartChanged: array[0..3] of Boolean;
  NowMs, SampleTimeMs: Int64;
  TimeSec, Value: Double;
  RunActive, SamplingActive, DiagnosticDue, RuntimeAssigned,
    SeriesAdded, DoFallback: Boolean;
begin
  if (FConfig = nil) or (FSeriesRuntime = nil) then
    Exit;
  NowMs := TMeterValue.GetMonotonicTimeMs;
  RunActive := (FWorkTable <> nil) and
    (FWorkTable.MeasurementRun is TMeasurementRun) and
    not (TMeasurementRun(FWorkTable.MeasurementRun).Stage in [msNone, msDone]);
  SamplingActive := IsSamplingActive;
  DiagnosticDue := (FLastUpdateDiagnosticMs = 0) or
    (NowMs - FLastUpdateDiagnosticMs >= DiagnosticIntervalMs);
  DoFallback := SamplingActive and ((FLastFallbackSampleMs = 0) or
    (NowMs - FLastFallbackSampleMs >= FallbackSampleIntervalMs));
  if RunActive and not FLastRunActive then
    ResetSeriesSegment(NowMs)
  else if SamplingActive and (FSegmentStartMs = 0) then
    FSegmentStartMs := NowMs;
  FLastRunActive := RunActive;
  AddedCount := 0;
  FillChar(ChartChanged, SizeOf(ChartChanged), 0);

  if DiagnosticDue and Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphWorkspaceUpdateBegin',
      'Начато обновление рабочей области графиков',
      Format('GraphCount=%d; RunActive=%s; SamplingActive=%s',
        [FConfig.GraphCount, BoolToStr(RunActive, True),
         BoolToStr(SamplingActive, True)]));

  for GraphIndex := 0 to FConfig.GraphCount - 1 do
  begin
    Chart := ChartByIndex(GraphIndex);
    if Chart = nil then
      Continue;
    for Config in FConfig.Panels[GraphIndex].Series do
    begin
      RuntimeAssigned := FSeriesRuntime.TryGetValue(Config, Runtime) and
        (Runtime <> nil) and (Runtime.ChartSeries <> nil);
      if not RuntimeAssigned then
      begin
        Runtime := TGraphSeriesRuntime.Create;
        Runtime.ChartSeries := Chart.AddSeries(Config.Caption);
        Runtime.ChartSeries.Color := Config.Color;
        Runtime.LastSampleIndex := -1;
        FSeriesRuntime.Add(Config, Runtime);
        RuntimeAssigned := True;
      end;
      Channel := ResolveChannel(Config);
      MeterValue := ResolveMeterValue(Config, Channel);
      if DiagnosticDue and Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm,
          'GraphWorkspaceSeriesResolve', 'Разрешение источника серии графика',
          Format('GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s; ChannelFound=%s; MeterValueFound=%s; ChartSeriesAssigned=%s',
            [GraphIndex, Config.ChannelUUID, Config.MeterValueKey,
             BoolToStr(Channel <> nil, True), BoolToStr(MeterValue <> nil, True),
             BoolToStr(RuntimeAssigned, True)]));
      if (not RuntimeAssigned) or (MeterValue = nil) then
      begin
        if DiagnosticDue and Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm,
            'GraphWorkspacePointSkipped', 'Точка графика пропущена',
            Format('GraphIndex=%d; ChannelUUID=%s; MeterValueKey=%s; Reason=SourceNotResolved',
              [GraphIndex, Config.ChannelUUID, Config.MeterValueKey]));
        Continue;
      end;
      Runtime.ChartSeries.Visible := Config.Visible;
      if (not Config.Visible) or (not SamplingActive) then
        Continue;
      SeriesAdded := False;
      Samples := MeterValue.GetStabilitySamples;
      for SampleIndex := 0 to High(Samples) do
      begin
        Sample := Samples[SampleIndex];
        if Sample.TimeStampMs <= Runtime.LastSampleTimeMs then
          Continue;
        Runtime.LastSampleTimeMs := Sample.TimeStampMs;
        Runtime.LastSampleIndex := SampleIndex;
        if (FSegmentStartMs > 0) and (Sample.TimeStampMs < FSegmentStartMs) then
          Continue;
        Value := Sample.Value;
        if IsNan(Value) or IsInfinite(Value) or (Abs(Value) >= MaxDouble) then
          Continue;
        if FSegmentStartMs = 0 then
          FSegmentStartMs := Sample.TimeStampMs;
        TimeSec := (Sample.TimeStampMs - FSegmentStartMs) / 1000.0;
        Runtime.ChartSeries.AddPoint(TimeSec, Value);
        Inc(AddedCount);
        SeriesAdded := True;
        if DiagnosticDue and Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm,
            'GraphWorkspacePointAdded', 'Добавлена точка графика',
            Format('GraphIndex=%d; ChannelUUID=%s; TimeSec=%g; Value=%g; PointsCount=%d',
              [GraphIndex, Config.ChannelUUID, TimeSec, Value,
               Runtime.ChartSeries.Points.Count]));
      end;
      if (not SeriesAdded) and DoFallback then
      begin
        Value := MeterValue.GetDoubleValue;
        if not IsNan(Value) and not IsInfinite(Value) and
           (Abs(Value) < MaxDouble) then
        begin
          SampleTimeMs := NowMs;
          TimeSec := Max(0.0, (SampleTimeMs - FSegmentStartMs) / 1000.0);
          Runtime.ChartSeries.AddPoint(TimeSec, Value);
          Runtime.LastSampleTimeMs := Max(Runtime.LastSampleTimeMs, SampleTimeMs);
          Inc(AddedCount);
          SeriesAdded := True;
          if DiagnosticDue and Assigned(ProtocolManager) then
            ProtocolManager.AddMessage(pcProc, psForm,
              'GraphWorkspacePointAdded', 'Добавлена текущая точка графика',
              Format('GraphIndex=%d; ChannelUUID=%s; TimeSec=%g; Value=%g; PointsCount=%d',
                [GraphIndex, Config.ChannelUUID, TimeSec, Value,
                 Runtime.ChartSeries.Points.Count]));
        end;
      end;
      if SeriesAdded then
      begin
        if FConfig.Panels[GraphIndex].VisibleDurationSec > 0 then
          while (Runtime.ChartSeries.Points.Count > 0) and
            (Runtime.ChartSeries.Points[0].X < TimeSec -
              FConfig.Panels[GraphIndex].VisibleDurationSec) do
            Runtime.ChartSeries.Points.Delete(0);
        while Runtime.ChartSeries.Points.Count > 10000 do
          Runtime.ChartSeries.Points.Delete(0);
        ChartChanged[GraphIndex] := True;
      end;
    end;
    if ChartChanged[GraphIndex] then
    begin
      Chart.AutoRangeX := True;
      Chart.AutoRangeY := True;
      Chart.InvalidateChart;
      if DiagnosticDue and Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphScale',
          'Автоматический масштаб графика',
          Format('GraphIndex=%d; AutoRangeX=True; AutoRangeY=True',
            [GraphIndex]));
    end;
  end;
  if DoFallback then
    FLastFallbackSampleMs := NowMs;
  if DiagnosticDue then
  begin
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphWorkspaceUpdateDone',
        'Обновление рабочей области графиков завершено',
        Format('AddedPoints=%d', [AddedCount]));
    FLastUpdateDiagnosticMs := NowMs;
  end;
end;

end.
