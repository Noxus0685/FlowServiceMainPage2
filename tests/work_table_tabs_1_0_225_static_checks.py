from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FRAME = (ROOT / "FlowServiceMainPage/frmMainTable.pas").read_text(encoding="utf-8-sig")
MAIN = (ROOT / "FMXFP/FlowPlantFMX/fuMain.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "FlowServiceMainPage/uAppVersion.pas").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "FMXFP/FlowPlantFMX/FlowPlantFmx.dproj").read_text(encoding="utf-8-sig")


def test_tabs_are_synchronized_and_bound_by_uuid():
    assert "procedure TFrameMainTable.SyncWorkTableTabs" in FRAME
    assert "function TFrameMainTable.FindWorkTableByTab" in FRAME
    assert "Tab.TagString := WorkTable.UUID" in FRAME
    assert "SameText(WorkTableManager.WorkTables[I].UUID, ATab.TagString)" in FRAME
    assert "Tab := TTabItem.Create(Self)" in FRAME
    assert "Tab.Index := I" in FRAME
    assert "LimitCount := Min(TableCount, 3)" not in FRAME
    assert "FindComponent('TabItemWorkTable2')" not in FRAME


def test_switching_uses_shared_panel_and_recursion_guard():
    assert "TabControlWorkTables.OnChange := TabControlWorkTablesChange" in FRAME
    assert "PanelControlWorkTables.Parent := Tab" in FRAME
    assert "PanelControlWorkTables.Align := TAlignLayout.Client" in FRAME
    assert "FChangingWorkTableTab := True" in FRAME
    assert "finally\n    FChangingWorkTableTab := False" in FRAME


def test_copy_and_refresh_use_central_synchronization():
    assert "FFrameMainTable.SyncWorkTableTabs;" in MAIN
    assert "FFrameMainTable.SelectWorkTable(AWorkTable);" in MAIN
    refresh = FRAME[FRAME.index("if WorkTableEvent = ewtRefresh then"):]
    assert "SyncWorkTableTabs;" in refresh[:300]
    assert "FindComponent(\n    'TabItemWorkTable'" not in MAIN


def test_application_version_is_1_0_225():
    assert "APP_VERSION = '1.0.225'" in VERSION
    assert PROJECT.count("FileVersion=1.0.225.0") == 2
    assert PROJECT.count("ProductVersion=1.0.225.0") == 2
