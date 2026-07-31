from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRAME = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
CONFIG = (ROOT / "uGraphsViewConfig.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def body(signature, next_signature):
    return FRAME[FRAME.index(signature):FRAME.index(next_signature, FRAME.index(signature))]


def test_version_and_independent_selectors():
    assert "APP_VERSION = '1.0.11'" in VERSION
    count = body("procedure TFrameMainTable.GraphCountChange", "procedure TFrameMainTable.GraphLayoutChange")
    layout = body("procedure TFrameMainTable.GraphLayoutChange", "procedure TFrameMainTable.GraphLegendChange")
    assert "LayoutKind :=" not in count
    assert "GraphCount :=" not in layout
    assert "EnsurePanelCount" not in layout


def test_balanced_effective_area_distribution_and_protocol():
    apply = body("procedure TFrameMainTable.ApplyGraphsLayout", "procedure TFrameMainTable.EnsureGraphViewCount")
    assert "EffectiveAreas := Min(RequestedAreas, FGraphsViewConfig.GraphCount)" in apply
    assert "BaseCount := FGraphsViewConfig.GraphCount div EffectiveAreas" in apply
    assert "ExtraCount := FGraphsViewConfig.GraphCount mod EffectiveAreas" in apply
    assert "GraphLayoutConfigurationApplied" in apply
    for field in ("RequestedGraphCount", "RequestedAreaCount", "EffectiveAreaCount", "Orientation", "GraphDistribution"):
        assert field in apply


def test_graph_removal_preserves_assignments_and_duplicates_are_local():
    assert "Extract(FPanels.Last.Series.Last)" in CONFIG
    assert "FPanels[Wanted - 1].AddSeries(Moving)" in CONFIG
    source_identity = CONFIG[CONFIG.index("function TGraphSeriesConfig.SourceIdentity"):]
    source_identity = source_identity[:source_identity.index("constructor TGraphPanelConfig.Create")]
    assert "GraphIndex" not in source_identity


def test_context_menu_commands_mouse_binding_and_audit_events():
    for command in ("Добавить серию", "Удалить серию", "Переместить серию на график", "Показать все серии", "Скрыть все серии", "Очистить график"):
        assert command in FRAME
    for control in ("Root", "Header", "TitleLabel", "Chart", "EmptyLabel", "LegendHost", "LegendLayout"):
        assert f"View.{control}.OnMouseDown := GraphViewMouseDown;" in FRAME
    for event in ("GraphContextMenuOpened", "GraphSeriesAdded", "GraphSeriesRemoved", "GraphSeriesMoved"):
        assert event in FRAME
    assert "if Button = TMouseButton.mbRight then" in FRAME
    assert "ScreenPoint := TControl(Sender).LocalToScreen(PointF(X, Y));" in FRAME
    assert "PopupMenu.PopupComponent :=" in FRAME
    assert "FGraphViews[FGraphPopupIndex].PopupMenu.Popup(ScreenPoint.X," in FRAME
    constructor = FRAME[FRAME.index("constructor TGraphPanelView.Create"):]
    constructor = constructor[:constructor.index("destructor TGraphPanelView.Destroy")]
    assert ".PopupMenu := PopupMenu" not in constructor


def test_visual_series_share_samples_but_keep_local_state():
    visual = FRAME[FRAME.index("constructor TFlowGraphSeries.CreateVisual"):]
    visual = visual[:visual.index("function TFlowGraphSeries.EffectiveVisible")]
    assert "FSamples := ASource.Samples" in visual
    assert "FColor := AColor" in visual
    assert "FUserVisible := AVisible" in visual
    assert "FGraphIndex := AGraphIndex" in visual
    assert "FGraphPopupIndex := TControl(Sender).Tag" in FRAME
