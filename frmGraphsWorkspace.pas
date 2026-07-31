unit frmGraphsWorkspace;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.SysUtils,
  System.Types,
  System.UITypes,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Menus,
  FMX.SimpleChart,
  FMX.StdCtrls,
  FMX.Types,
  uGraphsViewConfig,
  uClasses,
  uProtocols,
  uWorkTable;

const
  DesignedGraphSlotCount = 4;

type
  TGraphSourceAssignment = class
  public
    SourceKind: TGraphSourceKind;
    Serial: string;
    ChannelUUID: string;
    MeterValueKey: string;
    Caption: string;
    Color: TAlphaColor;
    Visible: Boolean;
    function Identity: string;
  end;

  { State does not own, or depend on, chart controls.  In particular, changing
    a layout never changes this collection. }
  TGraphWorkspaceState = class
  private
    FAssignments: array[0..DesignedGraphSlotCount - 1] of
      TObjectList<TGraphSourceAssignment>;
  public
    ActiveGraphCount: Integer;
    LayoutMode: TGraphLayoutKind;
    SelectedGraphIndex: Integer;
    ShowLegend: Boolean;
    constructor Create;
    destructor Destroy; override;
    function AddAssignment(AGraphIndex: Integer;
      AAssignment: TGraphSourceAssignment; out AExisting: Boolean): Boolean;
    function Assignments(AGraphIndex: Integer): TObjectList<TGraphSourceAssignment>;
  end;

  TGraphCommandEvent = procedure(Sender: TObject; AGraphIndex: Integer) of object;

  TFrameGraphsWorkspace = class(TFrame)
    LayoutRoot: TLayout;
    LayoutWorkspace: TLayout;
    LayoutToolbar: TLayout;
    LabelGraphCount: TLabel;
    ComboBoxGraphCount: TComboBox;
    LabelLayoutMode: TLabel;
    ComboBoxLayoutMode: TComboBox;
    CheckBoxShowLegend: TCheckBox;
    ButtonClearGraphs: TButton;
    ButtonResetGraphs: TButton;
    LayoutDesignedAreas: TLayout;
    LayoutOneArea: TLayout;
    OneArea1: TLayout;
    LayoutTwoAreasVertical: TLayout;
    TwoVerticalArea1: TLayout;
    TwoVerticalArea2: TLayout;
    LayoutTwoAreasHorizontal: TLayout;
    TwoHorizontalArea1: TLayout;
    TwoHorizontalArea2: TLayout;
    LayoutThreeAreas: TLayout;
    ThreeArea1: TLayout;
    ThreeArea2: TLayout;
    ThreeArea3: TLayout;
    LayoutFourAreas: TLayout;
    FourArea1: TLayout;
    FourArea2: TLayout;
    FourArea3: TLayout;
    FourArea4: TLayout;
    LayoutSlotParking: TLayout;
    GraphSlot1: TLayout;
    GraphHeader1: TPanel;
    LabelGraph1: TLabel;
    ChartGraph1: TSimpleChart;
    GraphSlot2: TLayout;
    GraphHeader2: TPanel;
    LabelGraph2: TLabel;
    ChartGraph2: TSimpleChart;
    GraphSlot3: TLayout;
    GraphHeader3: TPanel;
    LabelGraph3: TLabel;
    ChartGraph3: TSimpleChart;
    GraphSlot4: TLayout;
    GraphHeader4: TPanel;
    LabelGraph4: TLabel;
    ChartGraph4: TSimpleChart;
    SplitterSettings: TSplitter;
    PanelSeries: TPanel;
    LabelSelectedGraph: TLabel;
    LabelSeries: TLabel;
    ListBoxSeries: TListBox;
    PopupMenuGraph: TPopupMenu;
    MenuItemAddSeries: TMenuItem;
    MenuItemRemoveSeries: TMenuItem;
    MenuItemMoveSeries: TMenuItem;
    MenuItemShowAllSeries: TMenuItem;
    MenuItemHideAllSeries: TMenuItem;
    MenuItemClearGraph: TMenuItem;
    procedure ComboBoxGraphCountChange(Sender: TObject);
    procedure ComboBoxLayoutModeChange(Sender: TObject);
    procedure CheckBoxShowLegendChange(Sender: TObject);
    procedure ButtonClearGraphsClick(Sender: TObject);
    procedure ButtonResetGraphsClick(Sender: TObject);
    procedure GraphControlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PopupMenuGraphPopup(Sender: TObject);
    procedure MenuItemAddSeriesClick(Sender: TObject);
    procedure MenuItemRemoveSeriesClick(Sender: TObject);
    procedure MenuItemMoveSeriesClick(Sender: TObject);
    procedure MenuItemShowAllSeriesClick(Sender: TObject);
    procedure MenuItemHideAllSeriesClick(Sender: TObject);
    procedure MenuItemClearGraphClick(Sender: TObject);
  private
    FState: TGraphWorkspaceState;
    FWorkTable: TWorkTable;
    FInitialized: Boolean;
    FApplyingState: Boolean;
    FContextGraphIndex: Integer;
    FOnAddSeries: TGraphCommandEvent;
    FOnRemoveSeries: TGraphCommandEvent;
    FOnMoveSeries: TGraphCommandEvent;
    function Slot(AIndex: Integer): TLayout;
    function Chart(AIndex: Integer): TSimpleChart;
    function GraphIndexOf(Sender: TObject): Integer;
    procedure ClearChartSeriesData(AChart: TSimpleChart);
    procedure SelectGraph(AIndex: Integer);
    procedure SetAllSeriesVisible(AVisible: Boolean);
    procedure UpdateSeriesPanel;
    procedure RebuildAddSeriesMenu;
    procedure SourceMenuItemClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AWorkTable: TWorkTable);
    function AddSeries(AGraphIndex: Integer; ASourceKind: TGraphSourceKind;
      const ASerial, AChannelUUID, AMeterValueKey, ACaption: string;
      AColor: TAlphaColor): Boolean;
    procedure ApplyLayout;
    procedure RefreshFromState;
    property State: TGraphWorkspaceState read FState;
    property WorkTable: TWorkTable read FWorkTable;
    property ContextGraphIndex: Integer read FContextGraphIndex;
    property GraphCharts[AIndex: Integer]: TSimpleChart read Chart;
    property OnAddSeries: TGraphCommandEvent read FOnAddSeries write FOnAddSeries;
    property OnRemoveSeries: TGraphCommandEvent read FOnRemoveSeries write FOnRemoveSeries;
    property OnMoveSeries: TGraphCommandEvent read FOnMoveSeries write FOnMoveSeries;
  end;

implementation

{$R *.fmx}

function TGraphSourceAssignment.Identity: string;
begin
  Result := Format('%d|%s|%s', [Ord(SourceKind), LowerCase(ChannelUUID),
    LowerCase(MeterValueKey)]);
end;

constructor TGraphWorkspaceState.Create;
var I: Integer;
begin
  inherited;
  for I := Low(FAssignments) to High(FAssignments) do
    FAssignments[I] := TObjectList<TGraphSourceAssignment>.Create(True);
  ActiveGraphCount := 2;
  LayoutMode := glTwoRows;
  SelectedGraphIndex := 0;
  ShowLegend := True;
end;

destructor TGraphWorkspaceState.Destroy;
var I: Integer;
begin
  for I := Low(FAssignments) to High(FAssignments) do FAssignments[I].Free;
  inherited;
end;

function TGraphWorkspaceState.Assignments(AGraphIndex: Integer): TObjectList<TGraphSourceAssignment>;
begin
  if not InRange(AGraphIndex, Low(FAssignments), High(FAssignments)) then
    raise EArgumentOutOfRangeException.Create('Graph index');
  Result := FAssignments[AGraphIndex];
end;

function TGraphWorkspaceState.AddAssignment(AGraphIndex: Integer;
  AAssignment: TGraphSourceAssignment; out AExisting: Boolean): Boolean;
var Item: TGraphSourceAssignment;
begin
  AExisting := False;
  for Item in Assignments(AGraphIndex) do
    if SameText(Item.Identity, AAssignment.Identity) then
    begin
      Item.Visible := True;
      AExisting := True;
      AAssignment.Free;
      Exit(False);
    end;
  Assignments(AGraphIndex).Add(AAssignment);
  Result := True;
end;

constructor TFrameGraphsWorkspace.Create(AOwner: TComponent);
begin
  inherited;
  FState := TGraphWorkspaceState.Create;
  FContextGraphIndex := 0;
  RefreshFromState;
end;

destructor TFrameGraphsWorkspace.Destroy;
begin
  FState.Free;
  inherited;
end;

procedure TFrameGraphsWorkspace.Initialize(AWorkTable: TWorkTable);
begin
  if FInitialized and (FWorkTable = AWorkTable) then Exit;
  FWorkTable := AWorkTable;
  FInitialized := True;
  RefreshFromState;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcInfo, psForm, 'GraphsWorkspaceInitialized',
      'Инициализирована дизайнерская рабочая область графиков',
      Format('FrameClass=%s; DesignedGraphSlotCount=%d; ActiveGraphCount=%d; LayoutMode=%d',
        [ClassName, DesignedGraphSlotCount, FState.ActiveGraphCount, Ord(FState.LayoutMode)]));
end;

function TFrameGraphsWorkspace.AddSeries(AGraphIndex: Integer;
  ASourceKind: TGraphSourceKind; const ASerial, AChannelUUID,
  AMeterValueKey, ACaption: string; AColor: TAlphaColor): Boolean;
var
  Assignment: TGraphSourceAssignment;
  Existing: Boolean;
begin
  Assignment := TGraphSourceAssignment.Create;
  Assignment.SourceKind := ASourceKind;
  Assignment.Serial := ASerial;
  Assignment.ChannelUUID := AChannelUUID;
  Assignment.MeterValueKey := AMeterValueKey;
  Assignment.Caption := ACaption;
  Assignment.Color := AColor;
  Assignment.Visible := True;
  Result := FState.AddAssignment(AGraphIndex, Assignment, Existing);
  if AGraphIndex = FState.SelectedGraphIndex then
    UpdateSeriesPanel;
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcInfo, psForm, 'GraphSeriesAdded',
      'Источник назначен дизайнерскому графику',
      Format('GraphIndex=%d; SourceKind=%d; Serial=%s; ChannelUUID=%s; ExistingOnGraph=%s',
        [AGraphIndex + 1, Ord(ASourceKind), ASerial, AChannelUUID,
         BoolToStr(Existing, True)]));
end;

function TFrameGraphsWorkspace.Slot(AIndex: Integer): TLayout;
begin
  case AIndex of 0: Result := GraphSlot1; 1: Result := GraphSlot2;
    2: Result := GraphSlot3; 3: Result := GraphSlot4;
  else raise EArgumentOutOfRangeException.Create('Graph index'); end;
end;

function TFrameGraphsWorkspace.Chart(AIndex: Integer): TSimpleChart;
begin
  case AIndex of 0: Result := ChartGraph1; 1: Result := ChartGraph2;
    2: Result := ChartGraph3; 3: Result := ChartGraph4;
  else raise EArgumentOutOfRangeException.Create('Graph index'); end;
end;

function TFrameGraphsWorkspace.GraphIndexOf(Sender: TObject): Integer;
begin
  Result := -1;
  if Sender is TFmxObject then Result := TFmxObject(Sender).Tag;
  if not InRange(Result, 0, DesignedGraphSlotCount - 1) then Result := -1;
end;

procedure TFrameGraphsWorkspace.ApplyLayout;
var I, AreaCount: Integer; Distribution: string;
  procedure Put(AIndex: Integer; AParent: TFmxObject; AAlign: TAlignLayout);
  begin Slot(AIndex).Parent := AParent; Slot(AIndex).Align := AAlign; end;
begin
  LayoutOneArea.Visible := FState.LayoutMode = glSingle;
  LayoutTwoAreasVertical.Visible := FState.LayoutMode = glTwoRows;
  LayoutTwoAreasHorizontal.Visible := FState.LayoutMode = glTwoColumns;
  LayoutThreeAreas.Visible := FState.LayoutMode = glThreePanels;
  LayoutFourAreas.Visible := FState.LayoutMode = glGrid2x2;
  for I := 0 to DesignedGraphSlotCount - 1 do begin
    Slot(I).Parent := LayoutSlotParking; Slot(I).Visible := I < FState.ActiveGraphCount;
  end;
  case FState.LayoutMode of
    glSingle: begin AreaCount := 1; Distribution := IntToStr(FState.ActiveGraphCount);
      for I := 0 to FState.ActiveGraphCount - 1 do Put(I, OneArea1, TAlignLayout.Top); end;
    glTwoRows: begin AreaCount := 2;
      if FState.ActiveGraphCount = 3 then begin Put(0, TwoVerticalArea1, TAlignLayout.Top); Put(1, TwoVerticalArea1, TAlignLayout.Client); Put(2, TwoVerticalArea2, TAlignLayout.Client); Distribution := '2+1'; end
      else begin for I := 0 to FState.ActiveGraphCount - 1 do if I < (FState.ActiveGraphCount + 1) div 2 then Put(I, TwoVerticalArea1, TAlignLayout.Top) else Put(I, TwoVerticalArea2, TAlignLayout.Top); Distribution := Format('%d+%d', [(FState.ActiveGraphCount+1) div 2, FState.ActiveGraphCount div 2]); end; end;
    glTwoColumns: begin AreaCount := 2;
      if FState.ActiveGraphCount = 3 then begin Put(0, TwoHorizontalArea1, TAlignLayout.Top); Put(1, TwoHorizontalArea1, TAlignLayout.Client); Put(2, TwoHorizontalArea2, TAlignLayout.Client); Distribution := '2+1'; end
      else begin for I := 0 to FState.ActiveGraphCount - 1 do if I < (FState.ActiveGraphCount + 1) div 2 then Put(I, TwoHorizontalArea1, TAlignLayout.Top) else Put(I, TwoHorizontalArea2, TAlignLayout.Top); Distribution := Format('%d+%d', [(FState.ActiveGraphCount+1) div 2, FState.ActiveGraphCount div 2]); end; end;
    glThreePanels: begin AreaCount := 3; for I := 0 to FState.ActiveGraphCount - 1 do case I mod 3 of 0: Put(I, ThreeArea1, TAlignLayout.Client); 1: Put(I, ThreeArea2, TAlignLayout.Client); 2: Put(I, ThreeArea3, TAlignLayout.Client); end; Distribution := '1+1+1'; end;
  else begin AreaCount := 4; for I := 0 to FState.ActiveGraphCount - 1 do case I of 0: Put(I, FourArea1, TAlignLayout.Client); 1: Put(I, FourArea2, TAlignLayout.Client); 2: Put(I, FourArea3, TAlignLayout.Client); 3: Put(I, FourArea4, TAlignLayout.Client); end; Distribution := '1+1+1+1'; end; end;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcInfo, psForm,
    'GraphsWorkspaceLayoutApplied', 'Применена схема дизайнерских графиков',
    Format('GraphCount=%d; AreaCount=%d; LayoutMode=%d; Distribution=%s',
      [FState.ActiveGraphCount, AreaCount, Ord(FState.LayoutMode), Distribution]));
end;

procedure TFrameGraphsWorkspace.RefreshFromState;
begin
  FApplyingState := True;
  try
    ComboBoxGraphCount.ItemIndex := FState.ActiveGraphCount - 1;
    ComboBoxLayoutMode.ItemIndex := Ord(FState.LayoutMode);
    CheckBoxShowLegend.IsChecked := FState.ShowLegend;
  finally FApplyingState := False; end;
  ApplyLayout; SelectGraph(FState.SelectedGraphIndex);
end;

procedure TFrameGraphsWorkspace.SelectGraph(AIndex: Integer);
begin
  FState.SelectedGraphIndex := EnsureRange(AIndex, 0, FState.ActiveGraphCount - 1);
  LabelSelectedGraph.Text := Format('Выбран график %d', [FState.SelectedGraphIndex + 1]);
  UpdateSeriesPanel;
end;

procedure TFrameGraphsWorkspace.UpdateSeriesPanel;
var A: TGraphSourceAssignment; Item: TListBoxItem;
begin
  ListBoxSeries.Clear;
  for A in FState.Assignments(FState.SelectedGraphIndex) do begin
    Item := TListBoxItem.Create(ListBoxSeries); Item.Parent := ListBoxSeries;
    Item.Text := A.Caption; Item.IsChecked := A.Visible;
  end;
end;

procedure TFrameGraphsWorkspace.ClearChartSeriesData(AChart: TSimpleChart);
var
  SeriesIndex: Integer;
begin
  if AChart = nil then
    Exit;

  { TSimpleChart has no Clear method.  Retain every series object (including
    any designer-owned series) and clear only its data through the actual
    TChartSeries API. }
  AChart.BeginUpdate;
  try
    for SeriesIndex := 0 to AChart.SeriesCount - 1 do
      if AChart.Series[SeriesIndex] <> nil then
        AChart.Series[SeriesIndex].ClearPoints;
  finally
    AChart.EndUpdate;
  end;
end;

procedure TFrameGraphsWorkspace.ComboBoxGraphCountChange(Sender: TObject);
begin if FApplyingState or (ComboBoxGraphCount.ItemIndex < 0) then Exit;
  FState.ActiveGraphCount := ComboBoxGraphCount.ItemIndex + 1; RefreshFromState; end;
procedure TFrameGraphsWorkspace.ComboBoxLayoutModeChange(Sender: TObject);
begin if FApplyingState or (ComboBoxLayoutMode.ItemIndex < 0) then Exit;
  FState.LayoutMode := TGraphLayoutKind(ComboBoxLayoutMode.ItemIndex); ApplyLayout; end;
procedure TFrameGraphsWorkspace.CheckBoxShowLegendChange(Sender: TObject);
begin if not FApplyingState then FState.ShowLegend := CheckBoxShowLegend.IsChecked; end;
procedure TFrameGraphsWorkspace.ButtonClearGraphsClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FState.ActiveGraphCount - 1 do
  begin
    FState.Assignments(I).Clear;
    ClearChartSeriesData(Chart(I));
  end;
  UpdateSeriesPanel;
end;
procedure TFrameGraphsWorkspace.ButtonResetGraphsClick(Sender: TObject);
begin FState.Free; FState := TGraphWorkspaceState.Create; RefreshFromState; end;

procedure TFrameGraphsWorkspace.GraphControlMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var P: TPointF; Index: Integer;
begin
  Index := GraphIndexOf(Sender); if Index < 0 then Exit; SelectGraph(Index);
  if Button = TMouseButton.mbRight then begin FContextGraphIndex := Index;
    P := TControl(Sender).LocalToScreen(PointF(X, Y));
    PopupMenuGraph.PopupComponent := TControl(Sender); PopupMenuGraph.Popup(P.X, P.Y); end;
end;

procedure TFrameGraphsWorkspace.PopupMenuGraphPopup(Sender: TObject);
begin SelectGraph(FContextGraphIndex);
  RebuildAddSeriesMenu;
  if Assigned(ProtocolManager) then ProtocolManager.AddMessage(pcInfo, psForm,
    'GraphContextMenuOpened', 'Открыто меню дизайнерского графика',
    Format('DesignedSlot=%d', [FContextGraphIndex + 1])); end;
procedure TFrameGraphsWorkspace.MenuItemAddSeriesClick(Sender: TObject); begin if Assigned(FOnAddSeries) then FOnAddSeries(Self, FContextGraphIndex); end;
procedure TFrameGraphsWorkspace.MenuItemRemoveSeriesClick(Sender: TObject); begin if Assigned(FOnRemoveSeries) then FOnRemoveSeries(Self, FContextGraphIndex); end;
procedure TFrameGraphsWorkspace.MenuItemMoveSeriesClick(Sender: TObject); begin if Assigned(FOnMoveSeries) then FOnMoveSeries(Self, FContextGraphIndex); end;
procedure TFrameGraphsWorkspace.SetAllSeriesVisible(AVisible: Boolean); var A: TGraphSourceAssignment; begin for A in FState.Assignments(FContextGraphIndex) do A.Visible := AVisible; UpdateSeriesPanel; end;
procedure TFrameGraphsWorkspace.MenuItemShowAllSeriesClick(Sender: TObject); begin SetAllSeriesVisible(True); end;
procedure TFrameGraphsWorkspace.MenuItemHideAllSeriesClick(Sender: TObject); begin SetAllSeriesVisible(False); end;
procedure TFrameGraphsWorkspace.MenuItemClearGraphClick(Sender: TObject);
var
  GraphIndex: Integer;
begin
  GraphIndex := FContextGraphIndex;
  if not InRange(GraphIndex, 0, FState.ActiveGraphCount - 1) then
    GraphIndex := FState.SelectedGraphIndex;
  FState.Assignments(GraphIndex).Clear;
  ClearChartSeriesData(Chart(GraphIndex));
  UpdateSeriesPanel;
end;

procedure TFrameGraphsWorkspace.RebuildAddSeriesMenu;
  procedure AddChannels(AChannels: TObjectList<TChannel>; const APrefix: string;
    AOwnerCode: Char);
  var
    I: Integer;
    Channel: TChannel;
    Item: TMenuItem;
  begin
    if AChannels = nil then Exit;
    for I := 0 to AChannels.Count - 1 do
    begin
      Channel := AChannels[I];
      Item := TMenuItem.Create(MenuItemAddSeries);
      Item.Parent := MenuItemAddSeries;
      Item.Text := Format('%s №%s', [APrefix, Channel.Serial]);
      Item.TagString := AOwnerCode + IntToStr(I);
      Item.OnClick := SourceMenuItemClick;
    end;
  end;
begin
  { Only submenu contents are dynamic; the command itself is in the FMX. }
  MenuItemAddSeries.Clear;
  if FWorkTable = nil then Exit;
  AddChannels(FWorkTable.EtalonChannels, 'Эталон', 'E');
  AddChannels(FWorkTable.DeviceChannels, 'Прибор', 'D');
end;

procedure TFrameGraphsWorkspace.SourceMenuItemClick(Sender: TObject);
var
  Code: string;
  Index: Integer;
  Channel: TChannel;
  Prefix: string;
begin
  if not (Sender is TMenuItem) or (FWorkTable = nil) then Exit;
  Code := TMenuItem(Sender).TagString;
  if (Length(Code) < 2) or not TryStrToInt(Copy(Code, 2, MaxInt), Index) then Exit;
  if Code[1] = 'E' then
  begin
    if not InRange(Index, 0, FWorkTable.EtalonChannels.Count - 1) then Exit;
    Channel := FWorkTable.EtalonChannels[Index];
    Prefix := 'Эталон';
  end
  else
  begin
    if not InRange(Index, 0, FWorkTable.DeviceChannels.Count - 1) then Exit;
    Channel := FWorkTable.DeviceChannels[Index];
    Prefix := 'Прибор';
  end;
  AddSeries(FContextGraphIndex, gskFlow, Channel.Serial, Channel.UUID,
    Channel.UUID + '|Flow', Format('%s №%s', [Prefix, Channel.Serial]),
    TAlphaColors.Blue);
end;

end.
