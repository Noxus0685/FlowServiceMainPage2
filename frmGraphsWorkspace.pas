unit frmGraphsWorkspace;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections,
  FMX.Controls, FMX.Forms, FMX.Layouts, FMX.ListBox, FMX.Menus, FMX.Objects,
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

  TGraphSeriesRuntime = class
  public
    ChartSeries: TChartSeries;
    LastSampleTimeMs: Int64;
    LastSampleIndex: Integer;
  end;

  TFrameGraphsWorkspace = class(TFrame)
    LayoutWorkspaceRoot: TLayout;
    PanelGraphSettings: TPanel;
    LabelGraphCount: TLabel;
    ComboGraphCount: TComboBox;
    LabelGraphLayout: TLabel;
    ComboGraphLayout: TComboBox;
    CheckShowLegend: TCheckBox;
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
    SplitterSeries: TSplitter;
    PanelSeries: TPanel;
    LabelSelectedGraph: TLabel;
    ListGraphSeries: TListBox;
    PopupMenuGraph: TPopupMenu;
    MenuItemEtalons: TMenuItem;
    MenuItemDevices: TMenuItem;
    MenuAddSeries: TMenuItem;
    MenuDeleteSeries: TMenuItem;
    MenuMoveSeries: TMenuItem;
    MenuShowAllSeries: TMenuItem;
    MenuHideAllSeries: TMenuItem;
    MenuClearGraph: TMenuItem;
    procedure GraphCountChange(Sender: TObject);
    procedure GraphLayoutChange(Sender: TObject);
    procedure ShowLegendChange(Sender: TObject);
    procedure ClearAllClick(Sender: TObject);
    procedure ResetClick(Sender: TObject);
    procedure GraphControlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GraphHitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GraphPopup(Sender: TObject);
    procedure AddSeriesClick(Sender: TObject);
    procedure DeleteSeriesClick(Sender: TObject);
    procedure MoveSeriesClick(Sender: TObject);
    procedure ShowAllSeriesClick(Sender: TObject);
    procedure HideAllSeriesClick(Sender: TObject);
    procedure ClearGraphClick(Sender: TObject);
    procedure SeriesListChange(Sender: TObject);
    procedure SourceMenuItemClick(Sender: TObject);
  private
    FWorkTable: TWorkTable;
    FConfig: TGraphsViewConfig;
    FSelectedGraph: Integer;
    FContextGraphIndex: Integer;
    FUpdatingControls: Boolean;
    FOnAddSeries: TGraphSourceEvent;
    FOnDeleteSeries: TGraphSourceEvent;
    FOnMoveSeries: TGraphSourceEvent;
    FSeriesRuntime: TObjectDictionary<TGraphSeriesConfig, TGraphSeriesRuntime>;
    FLastRunActive: Boolean;
    FSegmentStartMs: Int64;
    FLastFallbackSampleMs: Int64;
    FLastUpdateDiagnosticMs: Int64;
    function ChartByIndex(const AIndex: Integer): TSimpleChart;
    function SlotByIndex(const AIndex: Integer): TLayout;
    function AreaByIndex(const AIndex: Integer): TLayout;
    procedure SelectGraph(const AIndex: Integer);
    procedure UpdateSeriesList;
    procedure SyncControls;
    procedure ClearChart(const AIndex: Integer; const AClearAssignments: Boolean);
    procedure PlaceSlot(const ASlot, AArea: Integer; const AAlign: TAlignLayout);
    procedure ClearDynamicMenu(AParent: TMenuItem);
    procedure BuildSourceMenu(out AEtalonCount, ADeviceCount: Integer);
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
    property OnAddSeries: TGraphSourceEvent read FOnAddSeries write FOnAddSeries;
    property OnDeleteSeries: TGraphSourceEvent read FOnDeleteSeries write FOnDeleteSeries;
    property OnMoveSeries: TGraphSourceEvent read FOnMoveSeries write FOnMoveSeries;
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
  UpdateSeriesList;
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
    if not SlotByIndex(I).Visible then PlaceSlot(I, Min(I, 3), TAlignLayout.Client);
end;

procedure TFrameGraphsWorkspace.SyncControls;
begin
  FUpdatingControls := True;
  try
    ComboGraphCount.ItemIndex := FConfig.GraphCount - 1;
    ComboGraphLayout.ItemIndex := Ord(FConfig.LayoutKind);
    CheckShowLegend.IsChecked := FConfig.ShowLegend;
  finally FUpdatingControls := False end;
end;

procedure TFrameGraphsWorkspace.GraphCountChange(Sender: TObject);
begin
  if FUpdatingControls or (FConfig = nil) then Exit;
  FConfig.EnsurePanelCount(ComboGraphCount.ItemIndex + 1); ApplyLayout;
end;

procedure TFrameGraphsWorkspace.GraphLayoutChange(Sender: TObject);
begin
  if FUpdatingControls or (FConfig = nil) then Exit;
  FConfig.LayoutKind := TGraphLayoutKind(ComboGraphLayout.ItemIndex); ApplyLayout;
end;

procedure TFrameGraphsWorkspace.ShowLegendChange(Sender: TObject);
begin if (not FUpdatingControls) and (FConfig <> nil) then FConfig.ShowLegend := CheckShowLegend.IsChecked end;

procedure TFrameGraphsWorkspace.SelectGraph(const AIndex: Integer);
begin
  if (FConfig = nil) or (AIndex < 0) or (AIndex >= FConfig.GraphCount) then Exit;
  FSelectedGraph := AIndex; LabelSelectedGraph.Text := Format('Серии графика %d', [AIndex + 1]); UpdateSeriesList;
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
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphContextMenuOpened',
        'Открыто контекстное меню графика',
        Format('GraphIndex=%d; EtalonCount=%d; DeviceCount=%d',
          [FContextGraphIndex, EtalonCount, DeviceCount]));
    P := TControl(Sender).LocalToScreen(PointF(X, Y));
    PopupMenuGraph.Popup(P.X, P.Y);
  end;
end;

procedure TFrameGraphsWorkspace.ClearDynamicMenu(AParent: TMenuItem);
var
  Item: TMenuItem;
  ItemIndex: Integer;
begin
  if AParent = nil then
    Exit;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuClearBegin',
      'Начата очистка меню источников графика',
      Format('ParentName=%s; ItemsCount=%d',
        [AParent.Name, AParent.ItemsCount]));
  while AParent.ItemsCount > 0 do
  begin
    ItemIndex := AParent.ItemsCount - 1;
    Item := TMenuItem(AParent.Items[ItemIndex]);
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuClearItem',
        'Удаляется пункт меню источников графика',
        Format('Index=%d; ClassName=%s; Text=%s',
          [ItemIndex, Item.ClassName, Item.Text]));
    Item.Free;
  end;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuClearDone',
      'Очистка меню источников графика завершена',
      Format('ParentName=%s; ItemsCount=%d',
        [AParent.Name, AParent.ItemsCount]));
end;

procedure TFrameGraphsWorkspace.AddEmptyMenuItem(AParent: TMenuItem;
  const ACaption: string);
var
  Item: TMenuItem;
begin
  if AParent = nil then
    raise EArgumentNilException.Create('AParent');
  Item := nil;
  try
    Item := TMenuItem.Create(nil);
    Item.Text := ACaption;
    Item.Enabled := False;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuAddBegin',
        'Начато добавление пункта меню источников графика',
        Format('ParentName=%s; ParentItemsCount=%d; ItemClass=%s; ItemText=%s',
          [AParent.Name, AParent.ItemsCount, Item.ClassName, Item.Text]));
    try
      AParent.AddObject(Item);
    except
      on E: Exception do
      begin
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuAddError',
            'Ошибка добавления пункта меню источников графика',
            Format('ExceptionClass=%s; ExceptionMessage=%s',
              [E.ClassName, E.Message]));
        raise;
      end;
    end;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuAddDone',
        'Пункт меню источников графика добавлен',
        Format('ParentName=%s; ParentItemsCount=%d',
          [AParent.Name, AParent.ItemsCount]));
    Item := nil;
  finally
    Item.Free;
  end;
end;

procedure TFrameGraphsWorkspace.AddChannelMenuItem(AParent: TMenuItem;
  AChannel: TChannel; const AOwnerKind: TGraphSeriesOwnerKind);
var
  Item: TGraphSourceMenuItem;
begin
  if AParent = nil then
    raise EArgumentNilException.Create('AParent');
  if AChannel = nil then
    raise EArgumentNilException.Create('AChannel');
  Item := nil;
  try
    Item := TGraphSourceMenuItem.Create(nil);
    Item.GraphIndex := FContextGraphIndex;
    Item.OwnerKind := AOwnerKind;
    Item.SourceKind := gskFlow;
    Item.ChannelUUID := AChannel.UUID;
    Item.MeterValueKey := 'ValueFlow';
    Item.Serial := Trim(AChannel.Serial);
    Item.SourceCaption := Trim(AChannel.Name);
    if Item.SourceCaption = '' then
      Item.SourceCaption := Trim(AChannel.Text);
    if Item.Serial <> '' then
      Item.Text := Format('%s — %s', [Item.Serial, Item.SourceCaption])
    else
      Item.Text := Item.SourceCaption;
    Item.SourceCaption := Item.Text;
    Item.OnClick := SourceMenuItemClick;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuAddBegin',
        'Начато добавление пункта меню источников графика',
        Format('ParentName=%s; ParentItemsCount=%d; ItemClass=%s; ItemText=%s',
          [AParent.Name, AParent.ItemsCount, Item.ClassName, Item.Text]));
    try
      AParent.AddObject(Item);
    except
      on E: Exception do
      begin
        if Assigned(ProtocolManager) then
          ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuAddError',
            'Ошибка добавления пункта меню источников графика',
            Format('ExceptionClass=%s; ExceptionMessage=%s',
              [E.ClassName, E.Message]));
        raise;
      end;
    end;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuAddDone',
        'Пункт меню источников графика добавлен',
        Format('ParentName=%s; ParentItemsCount=%d',
          [AParent.Name, AParent.ItemsCount]));
    Item := nil;
  finally
    Item.Free;
  end;
end;

procedure TFrameGraphsWorkspace.BuildSourceMenu(out AEtalonCount,
  ADeviceCount: Integer);
var
  Channel: TChannel;
begin
  AEtalonCount := 0;
  ADeviceCount := 0;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuBuildBegin',
      'Начато построение меню источников графика',
      Format('FrameAssigned=True; WorkTableAssigned=%s; PopupAssigned=%s; EtalonsMenuAssigned=%s; DevicesMenuAssigned=%s; GraphIndex=%d',
        [BoolToStr(FWorkTable <> nil, True),
         BoolToStr(PopupMenuGraph <> nil, True),
         BoolToStr(MenuItemEtalons <> nil, True),
         BoolToStr(MenuItemDevices <> nil, True), FContextGraphIndex]));
  try
    if MenuItemEtalons = nil then
      raise EInvalidOperation.Create(
        'MenuItemEtalons не загружен из frmGraphsWorkspace.fmx');
    if MenuItemDevices = nil then
      raise EInvalidOperation.Create(
        'MenuItemDevices не загружен из frmGraphsWorkspace.fmx');

    ClearDynamicMenu(MenuItemEtalons);
    ClearDynamicMenu(MenuItemDevices);
    MenuItemEtalons.Enabled := False;
    MenuItemDevices.Enabled := False;

    if FWorkTable = nil then
    begin
      AddEmptyMenuItem(MenuItemEtalons, 'Нет включённых эталонов');
      AddEmptyMenuItem(MenuItemDevices, 'Нет включённых приборов');
    end
    else
    begin
      if FWorkTable.EtalonChannels <> nil then
        for Channel in FWorkTable.EtalonChannels do
          if (Channel <> nil) and Channel.Enabled and
             (Channel.FlowMeter <> nil) then
          begin
            AddChannelMenuItem(MenuItemEtalons, Channel, gsokEtalon);
            Inc(AEtalonCount);
          end;
      if FWorkTable.DeviceChannels <> nil then
        for Channel in FWorkTable.DeviceChannels do
          if (Channel <> nil) and Channel.Enabled and
             (Channel.FlowMeter <> nil) then
          begin
            AddChannelMenuItem(MenuItemDevices, Channel, gsokDevice);
            Inc(ADeviceCount);
          end;
      if AEtalonCount = 0 then
        AddEmptyMenuItem(MenuItemEtalons, 'Нет включённых эталонов');
      if ADeviceCount = 0 then
        AddEmptyMenuItem(MenuItemDevices, 'Нет включённых приборов');
      MenuItemEtalons.Enabled := AEtalonCount > 0;
      MenuItemDevices.Enabled := ADeviceCount > 0;
    end;

    if Assigned(ProtocolManager) then
    begin
      if (AEtalonCount = 0) and (ADeviceCount = 0) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuEmpty',
          'Нет доступных источников графика',
          Format('GraphIndex=%d', [FContextGraphIndex]));
      ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuBuildDone',
        'Построение меню источников графика завершено',
        Format('GraphIndex=%d; EtalonCount=%d; DeviceCount=%d',
          [FContextGraphIndex, AEtalonCount, ADeviceCount]));
    end;
  except
    on E: Exception do
    begin
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceMenuBuildError',
          'Ошибка построения меню источников графика',
          Format('ExceptionClass=%s; ExceptionMessage=%s',
            [E.ClassName, E.Message]));
      raise;
    end;
  end;
end;

procedure TFrameGraphsWorkspace.SourceMenuItemClick(Sender: TObject);
var
  Item: TGraphSourceMenuItem;
  Source: TGraphSeriesConfig;
  Added: Boolean;
begin
  if not (Sender is TGraphSourceMenuItem) then Exit;
  if FConfig = nil then Exit;
  Item := TGraphSourceMenuItem(Sender);
  if (Item.GraphIndex < 0) or (Item.GraphIndex >= FConfig.GraphCount) then Exit;
  Source := TGraphSeriesConfig.Create;
  Source.OwnerKind := Item.OwnerKind;
  Source.SourceKind := Item.SourceKind;
  Source.ChannelUUID := Item.ChannelUUID;
  Source.MeterValueKey := Item.MeterValueKey;
  Source.Caption := Item.SourceCaption;
  Added := AddSource(Item.GraphIndex, Source);
  SelectGraph(Item.GraphIndex);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GraphSourceSelected',
      'Выбран источник графика',
      Format('GraphIndex=%d; SourceKind=%d; Serial=%s; ChannelUUID=%s; MeterValueKey=%s; Existing=%s',
        [Item.GraphIndex, Ord(Item.OwnerKind), Item.Serial, Item.ChannelUUID,
         Item.MeterValueKey, BoolToStr(not Added, True)]));
end;

procedure TFrameGraphsWorkspace.GraphPopup(Sender: TObject);
begin
  MenuDeleteSeries.Enabled := ListGraphSeries.ItemIndex >= 0;
  MenuMoveSeries.Enabled := (ListGraphSeries.ItemIndex >= 0) and (FConfig.GraphCount > 1);
end;

procedure TFrameGraphsWorkspace.UpdateSeriesList;
var S: TGraphSeriesConfig; Item: TListBoxItem;
begin
  ListGraphSeries.Clear;
  if (FConfig = nil) or (FSelectedGraph >= FConfig.Panels.Count) then Exit;
  for S in FConfig.Panels[FSelectedGraph].Series do begin Item := TListBoxItem.Create(ListGraphSeries); Item.Parent := ListGraphSeries; Item.Text := S.Caption; Item.IsChecked := S.Visible; end;
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
begin ClearChart(AGraphIndex, True); if AGraphIndex = FSelectedGraph then UpdateSeriesList end;
procedure TFrameGraphsWorkspace.ClearAllGraphs;
var I: Integer; begin if FConfig <> nil then for I := 0 to FConfig.GraphCount - 1 do ClearChart(I, True); UpdateSeriesList end;
procedure TFrameGraphsWorkspace.ClearAllClick(Sender: TObject); begin ClearAllGraphs end;
procedure TFrameGraphsWorkspace.ClearGraphClick(Sender: TObject); begin ClearGraph(FContextGraphIndex) end;
procedure TFrameGraphsWorkspace.ResetClick(Sender: TObject); begin FConfig.Reset; SyncControls; ApplyLayout; UpdateSeriesList end;

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
  if AGraphIndex = FSelectedGraph then UpdateSeriesList;
end;

procedure TFrameGraphsWorkspace.AddSeriesClick(Sender: TObject); begin if Assigned(FOnAddSeries) then FOnAddSeries(Self, FContextGraphIndex) end;
procedure TFrameGraphsWorkspace.DeleteSeriesClick(Sender: TObject); begin if Assigned(FOnDeleteSeries) then FOnDeleteSeries(Self, FContextGraphIndex) end;
procedure TFrameGraphsWorkspace.MoveSeriesClick(Sender: TObject); begin if Assigned(FOnMoveSeries) then FOnMoveSeries(Self, FContextGraphIndex) end;
procedure TFrameGraphsWorkspace.ShowAllSeriesClick(Sender: TObject);
var S: TGraphSeriesConfig; begin for S in FConfig.Panels[FContextGraphIndex].Series do S.Visible := True; UpdateSeriesList end;
procedure TFrameGraphsWorkspace.HideAllSeriesClick(Sender: TObject);
var S: TGraphSeriesConfig; begin for S in FConfig.Panels[FContextGraphIndex].Series do S.Visible := False; UpdateSeriesList end;
procedure TFrameGraphsWorkspace.SeriesListChange(Sender: TObject); begin end;

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
        ChartChanged[GraphIndex] := True;
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
