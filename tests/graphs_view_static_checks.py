from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN_FORM = (ROOT / "fuTable_Main.fmx").read_text(encoding="utf-8-sig")
MAIN_UNIT = (ROOT / "fuTable_Main.pas").read_text(encoding="utf-8-sig")
FRAME = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
CONFIG = (ROOT / "uGraphsViewConfig.pas").read_text(encoding="utf-8-sig")
FRAME_FORM = (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dpr").read_text(encoding="utf-8-sig")
PROJECT_XML = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def test_graphs_is_a_top_level_tab_in_the_required_position():
    names = [
        "object tiTable: TTabItem",
        "object TabItemMainGraphs: TTabItem",
        "object tiMnemo: TTabItem",
        "object tiResults: TTabItem",
        "object tiTest: TTabItem",
    ]
    positions = [MAIN_FORM.index(name) for name in names]
    assert positions == sorted(positions)
    assert "FFrameMainTable.AttachGraphsTo(TabItemMainGraphs);" in MAIN_UNIT


def test_current_main_form_is_built_and_old_graph_tab_is_detached():
    assert "fuTable_Main in 'fuTable_Main.pas' {TableMainForm}" in PROJECT
    assert "Application.CreateForm(TTableMainForm, TableMainForm);" in PROJECT
    assert "Application.CreateForm(TFormMain, FormMain);" not in PROJECT
    assert PROJECT_XML.count('DCCReference Include="fuTable_Main.pas"') == 1
    assert "<Form>TableMainForm</Form>" in PROJECT_XML
    assert "object TabItemWorkTableGraphs: TTabItem" in FRAME_FORM
    assert "TabItemWorkTableGraphs.Parent := nil;" in FRAME
    assert "TargetParent=%s; ActualParent=%s; Align=%d" in FRAME
    assert "TabItemMainGraphs" not in (
        ROOT / "fuMain.pas"
    ).read_text(encoding="utf-8-sig")
    assert "object TabItemMainGraphs" not in (
        ROOT / "fuMain.fmx"
    ).read_text(encoding="utf-8-sig")


def test_graph_configuration_is_control_independent_and_rejects_duplicates():
    for declaration in (
        "TGraphLayoutKind = (glSingle, glTwoRows, glTwoColumns, glThreePanels,",
        "TGraphSourceKind = (gskFlow, gskTemperature, gskPressure, gskMass,",
        "TGraphSeriesOwnerKind = (gsokEtalon, gsokDevice, gsokWorkTable, gsokSystem)",
        "Panels: TObjectList<TGraphPanelConfig>",
        "function SourceIdentity: string",
        "function AddSeries(const ASeries: TGraphSeriesConfig): Boolean",
    ):
        assert declaration in CONFIG
    assert "if Existing <> nil then" in CONFIG
    assert "Existing.Visible := True;" in CONFIG


def test_graph_workspace_has_collapsible_settings_and_runtime_layouts():
    for feature in (
        "LayoutGraphsRoot",
        "SplitterGraphsSettings",
        "LayoutGraphsSettings",
        "GraphSettingsToggleClick",
        "glTwoColumns:",
        "procedure TFrameMainTable.EnsureGraphViewCount",
        "procedure TFrameMainTable.ClearGraphsLayout",
        "glThreePanels:",
        "glGrid2x2:",
        "ShowLegend",
        "ResolveGraphSeriesMeterValue",
        "ButtonClearFlowGraphsClick",
    ):
        assert feature in FRAME


def test_disabled_channels_and_dynamic_graph_views_are_runtime_safe():
    for feature in (
        "TGraphPanelView = class",
        "FGraphViews: TObjectList<TGraphPanelView>",
        "if not C.Enabled then",
        "'ChannelDisabled'",
        "S.ChannelAvailable := C.Enabled",
        "not Pair.Value.EffectiveVisible",
        "MinimumRange := Max(Abs(CenterValue) * 0.01, 0.000001)",
        "GraphsLayoutApplied",
        "GraphScale",
        "procedure TFrameMainTable.RebuildGraphPopupMenu",
        "procedure TFrameMainTable.GraphMenuClick",
        "'Добавить серию'",
        "'Настроить цвета'",
    ):
        assert feature in FRAME


def test_graph_workspace_uses_public_fmx_api_and_local_for_in_variables():
    assert "TControl(LayoutGraphsClient.Children[I]).Visible := False" in FRAME
    assert "LayoutGraphsClient.Realign" not in FRAME
    assert "for SourcePair in ADictionary do" in FRAME
    assert "for CurrentPair in FFlowGraphHistory.EtalonSeries do" in FRAME
    assert "for DictionaryPair in ADictionary do" in FRAME


def extract_method_body(source: str, signature: str) -> str:
    start = source.index(signature)
    next_method = source.find("\nprocedure TFrameMainTable.", start + len(signature))
    if next_method < 0:
        next_method = len(source)
    return source[start:next_method]


def extract_routine_body(source: str, signature: str) -> str:
    start = source.index(signature)
    next_routine = min(
        (
            position for position in (
                source.find("\nprocedure ", start + len(signature)),
                source.find("\ndestructor ", start + len(signature)),
                source.find("\nfunction ", start + len(signature)),
            ) if position >= 0
        ),
        default=len(source),
    )
    return source[start:next_routine]


def test_render_does_not_rebuild_popup_menu_or_legend():
    render_body = extract_method_body(
        FRAME,
        "procedure TFrameMainTable.RenderConfiguredGraph"
    )
    assert "RebuildGraphPopupMenu" not in render_body
    assert "TCheckBox.Create" not in render_body
    assert "TRectangle.Create" not in render_body


def test_popup_menu_is_built_on_popup():
    assert "GraphPopupMenuPopup" in FRAME
    assert "PopupMenu.OnPopup := GraphPopupMenuPopup" in FRAME


def test_graph_views_are_detached_before_fmx_destruction_starts():
    declaration = "procedure BeforeDestruction; override;"
    before_destruction = extract_routine_body(
        FRAME, "procedure TFrameMainTable.BeforeDestruction"
    )
    frame_destroy = extract_routine_body(
        FRAME, "destructor TFrameMainTable.Destroy"
    )

    assert declaration in FRAME
    assert "GraphView.Root.Parent := nil;" in before_destruction
    assert "GraphView.Root.Align" not in before_destruction
    assert "GraphView.Root.Parent" not in frame_destroy
    assert "GraphView.Root.Align" not in frame_destroy
    assert "for View " not in frame_destroy
    assert "View." not in frame_destroy
    assert "DetachGraphViewEvents" not in frame_destroy


def test_graph_view_owns_exactly_one_ownerless_root():
    constructor = extract_routine_body(FRAME, "constructor TGraphPanelView.Create")
    view_destroy = extract_routine_body(FRAME, "destructor TGraphPanelView.Destroy")

    assert "Root := TLayout.Create(nil);" in constructor
    for child_creation in (
        "Header := TLayout.Create(Root);",
        "TitleLabel := TLabel.Create(Root);",
        "Chart := TSimpleChart.Create(Root);",
        "EmptyLabel := TLabel.Create(Root);",
        "LegendHost := TLayout.Create(Root);",
        "LegendLayout := TFlowLayout.Create(Root);",
        "PopupMenu := TPopupMenu.Create(Root);",
    ):
        assert child_creation in constructor
    assert "Root.Parent := nil;" in view_destroy
    assert view_destroy.count(".Free;") == 1
    assert "Root.Free;" in view_destroy
    assert "Root.Align" not in view_destroy


def test_graph_render_callbacks_stop_during_destruction():
    timer = extract_routine_body(
        FRAME, "procedure TFrameMainTable.GraphRenderTimerTimer"
    )
    queue = extract_routine_body(
        FRAME, "procedure TFrameMainTable.QueueRenderGraphViews"
    )
    render = extract_routine_body(
        FRAME, "procedure TFrameMainTable.RenderGraphViews"
    )

    assert "if FDestroying then" in timer
    assert "if FDestroying or" in queue
    assert "if FGraphRenderTimer = nil then\n    Exit;" in queue
    assert "if FDestroying then\n    Exit;" in render
    assert "(FGraphViews = nil) or (FGraphsViewConfig = nil)" in render


def test_temporary_graph_layout_controls_have_one_owner():
    apply_layout = extract_routine_body(
        FRAME, "procedure TFrameMainTable.ApplyGraphsLayout"
    )

    assert "Result := TSplitter.Create(nil);" in apply_layout
    assert "Result := TLayout.Create(nil);" in apply_layout
    assert "TSplitter.Create(Self)" not in apply_layout
    assert "TLayout.Create(Self)" not in apply_layout
    assert "FGraphSplitters := TObjectList<TSplitter>.Create(True);" in FRAME
    assert (
        "FGraphLayoutContainers := TObjectList<TLayout>.Create(True);" in FRAME
    )


def test_temporary_layout_controls_are_detached_before_freeing():
    clear_layout = extract_routine_body(
        FRAME, "procedure TFrameMainTable.ClearGraphsLayout"
    )
    before_destruction = extract_routine_body(
        FRAME, "procedure TFrameMainTable.BeforeDestruction"
    )
    frame_destroy = extract_routine_body(
        FRAME, "destructor TFrameMainTable.Destroy"
    )

    assert clear_layout.index("GraphView.Root.Parent := LayoutGraphsClient;") < (
        clear_layout.index("FGraphSplitters.Clear;")
    )
    assert clear_layout.index("Splitter.Parent := nil;") < (
        clear_layout.index("FGraphSplitters.Clear;")
    )
    assert clear_layout.index("Container.Parent := nil;") < (
        clear_layout.index("FGraphLayoutContainers.Clear;")
    )
    assert "Splitter.Parent := nil;" in before_destruction
    assert "Container.Parent := nil;" in before_destruction
    for visual_property in (".Parent", ".Align", ".Width", ".Height"):
        assert visual_property not in frame_destroy
