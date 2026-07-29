from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN_FORM = (ROOT / "fuMain.fmx").read_text(encoding="utf-8-sig")
FRAME = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
CONFIG = (ROOT / "uGraphsViewConfig.pas").read_text(encoding="utf-8-sig")


def test_graphs_is_a_top_level_tab_in_the_required_position():
    names = [
        "object TabItemTable: TTabItem",
        "object TabItemGraphs: TTabItem",
        "object TabItemMnemo: TTabItem",
        "object TabItemResults: TTabItem",
        "object TabItemTest: TTabItem",
    ]
    positions = [MAIN_FORM.index(name) for name in names]
    assert positions == sorted(positions)
    assert "FFrameMainTable.AttachGraphsTo(TabItemGraphs);" in (
        ROOT / "fuMain.pas"
    ).read_text(encoding="utf-8-sig")


def test_graph_configuration_is_control_independent_and_rejects_duplicates():
    for declaration in (
        "TGraphLayoutKind = (glSingle, glTwoRows, glTwoColumns, glGrid2x2)",
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
        "LayoutEtalonGraphSection.Align := TAlignLayout.Top",
        "LayoutEtalonGraphSection.Align := TAlignLayout.Left",
        "ShowLegend",
        "ResolveGraphSeriesMeterValue",
        "ButtonClearFlowGraphsClick",
    ):
        assert feature in FRAME
