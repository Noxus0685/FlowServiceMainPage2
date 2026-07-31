unit frmGraphsWorkspace;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Math,
  FMX.Controls, FMX.Forms, FMX.Layouts, FMX.ListBox, FMX.Menus, FMX.StdCtrls,
  FMX.Types, FMX.SimpleChart,
  uGraphsViewConfig, uWorkTable;

type
  TGraphSourceEvent = procedure(Sender: TObject; const AGraphIndex: Integer) of object;

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
    LayoutGraphSlot2: TLayout;
    LabelGraphTitle2: TLabel;
    ChartGraph2: TSimpleChart;
    LayoutGraphSlot3: TLayout;
    LabelGraphTitle3: TLabel;
    ChartGraph3: TSimpleChart;
    LayoutGraphSlot4: TLayout;
    LabelGraphTitle4: TLabel;
    ChartGraph4: TSimpleChart;
    SplitterSeries: TSplitter;
    PanelSeries: TPanel;
    LabelSelectedGraph: TLabel;
    ListGraphSeries: TListBox;
    PopupGraph: TPopupMenu;
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
    procedure GraphPopup(Sender: TObject);
    procedure AddSeriesClick(Sender: TObject);
    procedure DeleteSeriesClick(Sender: TObject);
    procedure MoveSeriesClick(Sender: TObject);
    procedure ShowAllSeriesClick(Sender: TObject);
    procedure HideAllSeriesClick(Sender: TObject);
    procedure ClearGraphClick(Sender: TObject);
    procedure SeriesListChange(Sender: TObject);
  private
    FWorkTable: TWorkTable;
    FConfig: TGraphsViewConfig;
    FSelectedGraph: Integer;
    FContextGraph: Integer;
    FUpdatingControls: Boolean;
    FOnAddSeries: TGraphSourceEvent;
    FOnDeleteSeries: TGraphSourceEvent;
    FOnMoveSeries: TGraphSourceEvent;
    function ChartByIndex(const AIndex: Integer): TSimpleChart;
    function SlotByIndex(const AIndex: Integer): TLayout;
    function AreaByIndex(const AIndex: Integer): TLayout;
    procedure SelectGraph(const AIndex: Integer);
    procedure UpdateSeriesList;
    procedure SyncControls;
    procedure ClearChart(const AIndex: Integer; const AClearAssignments: Boolean);
    procedure PlaceSlot(const ASlot, AArea: Integer; const AAlign: TAlignLayout);
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
  FConfig.Free;
  inherited;
end;

procedure TFrameGraphsWorkspace.Initialize(AWorkTable: TWorkTable);
begin
  FWorkTable := AWorkTable;
  if FConfig = nil then
    FConfig := TGraphsViewConfig.Create;
  FSelectedGraph := 0;
  FContextGraph := 0;
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
var P: TPointF;
begin
  if not (Sender is TControl) then Exit;
  SelectGraph(TControl(Sender).Tag);
  if Button = TMouseButton.mbRight then
  begin
    FContextGraph := TControl(Sender).Tag;
    P := TControl(Sender).LocalToScreen(PointF(X, Y));
    PopupGraph.Popup(P.X, P.Y);
  end;
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
  if AClearAssignments and (FConfig <> nil) and (AIndex < FConfig.Panels.Count) then FConfig.Panels[AIndex].Series.Clear;
end;

procedure TFrameGraphsWorkspace.ClearGraph(const AGraphIndex: Integer);
begin ClearChart(AGraphIndex, True); if AGraphIndex = FSelectedGraph then UpdateSeriesList end;
procedure TFrameGraphsWorkspace.ClearAllGraphs;
var I: Integer; begin if FConfig <> nil then for I := 0 to FConfig.GraphCount - 1 do ClearChart(I, True); UpdateSeriesList end;
procedure TFrameGraphsWorkspace.ClearAllClick(Sender: TObject); begin ClearAllGraphs end;
procedure TFrameGraphsWorkspace.ClearGraphClick(Sender: TObject); begin ClearGraph(FContextGraph) end;
procedure TFrameGraphsWorkspace.ResetClick(Sender: TObject); begin FConfig.Reset; SyncControls; ApplyLayout; UpdateSeriesList end;

function TFrameGraphsWorkspace.AddSource(const AGraphIndex: Integer; ASource: TGraphSeriesConfig): Boolean;
begin
  Result := False;
  if (ASource = nil) or (FConfig = nil) or (AGraphIndex < 0) or (AGraphIndex >= FConfig.Panels.Count) then Exit;
  ASource.GraphIndex := AGraphIndex;
  Result := FConfig.Panels[AGraphIndex].AddSeries(ASource);
  if not Result then ASource.Free;
  if AGraphIndex = FSelectedGraph then UpdateSeriesList;
end;

procedure TFrameGraphsWorkspace.AddSeriesClick(Sender: TObject); begin if Assigned(FOnAddSeries) then FOnAddSeries(Self, FContextGraph) end;
procedure TFrameGraphsWorkspace.DeleteSeriesClick(Sender: TObject); begin if Assigned(FOnDeleteSeries) then FOnDeleteSeries(Self, FContextGraph) end;
procedure TFrameGraphsWorkspace.MoveSeriesClick(Sender: TObject); begin if Assigned(FOnMoveSeries) then FOnMoveSeries(Self, FContextGraph) end;
procedure TFrameGraphsWorkspace.ShowAllSeriesClick(Sender: TObject);
var S: TGraphSeriesConfig; begin for S in FConfig.Panels[FContextGraph].Series do S.Visible := True; UpdateSeriesList end;
procedure TFrameGraphsWorkspace.HideAllSeriesClick(Sender: TObject);
var S: TGraphSeriesConfig; begin for S in FConfig.Panels[FContextGraph].Series do S.Visible := False; UpdateSeriesList end;
procedure TFrameGraphsWorkspace.SeriesListChange(Sender: TObject); begin end;
procedure TFrameGraphsWorkspace.UpdateGraphs; begin { data is supplied through configured sources by the host update cycle } end;

end.
