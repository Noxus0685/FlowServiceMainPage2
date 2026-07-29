from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN_FORM = (ROOT / "fuMain.fmx").read_text(encoding="utf-8-sig")
FRAME = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
CONFIG = (ROOT / "uGraphsViewConfig.pas").read_text(encoding="utf-8-sig")
FRAME_FORM = (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dpr").read_text(encoding="utf-8-sig")
PROJECT_XML = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def test_graphs_is_a_top_level_tab_in_the_required_position():
    names = [
        "object TabItemTable: TTabItem",
        "object TabItemMainGraphs: TTabItem",
        "object TabItemMnemo: TTabItem",
        "object TabItemResults: TTabItem",
        "object TabItemTest: TTabItem",
    ]
    positions = [MAIN_FORM.index(name) for name in names]
    assert positions == sorted(positions)
    assert "FFrameMainTable.AttachGraphsTo(TabItemMainGraphs);" in (
        ROOT / "fuMain.pas"
    ).read_text(encoding="utf-8-sig")


def test_current_main_form_is_built_and_old_graph_tab_is_detached():
    assert "fuMain in 'fuMain.pas' {FormMain}" in PROJECT
    assert "Application.CreateForm(TFormMain, FormMain);" in PROJECT
    assert PROJECT_XML.count('DCCReference Include="fuMain.pas"') == 1
    assert "<Form>FormMain</Form>" in PROJECT_XML
    assert "object TabItemWorkTableGraphs: TTabItem" in FRAME_FORM
    assert "TabItemWorkTableGraphs.Parent := nil;" in FRAME
    assert "TargetParent=%s; ActualParent=%s; Align=%d" in FRAME


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
