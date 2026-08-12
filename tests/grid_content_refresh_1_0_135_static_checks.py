from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
HELPER = (ROOT / "FmxHelper.pas").read_text(encoding="cp1251")
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def method(text, marker, following):
    start = text.index(marker)
    return text[start:text.index(following, start)]


def test_refresh_helper_updates_rows_only_when_count_changes():
    body = method(HELPER, "procedure RefreshGridContent(AGrid", "var\n  LogCriticalSection")
    assert "if AGrid = nil then" in body
    assert "AGrid.BeginUpdate" in body
    assert "try" in body and "finally" in body and "AGrid.EndUpdate" in body
    assert "if OldRowCount <> ARowCount then" in body
    assert "AGrid.RowCount := ARowCount" in body
    assert "AGrid.Model.ContentChanged" in body
    assert "AGrid.Repaint" in body
    for forbidden in (".Width", ".Index", ".Parent", ".Visible"):
        assert forbidden not in body
    assert "GridContentRefresh" in body
    assert "AReason" in body


def test_frequent_grids_use_content_refresh():
    expected = {
        "frmMainTable.pas": ("GridDevices", "GridEtalons"),
        "frmProceed.pas": ("GridResults", "GridDataPoints"),
        "frmMRResults.pas": ("GridMRResults",),
        "fuDeviceEdit.pas": ("GridPoints",),
    }
    for filename, grids in expected.items():
        text = (ROOT / filename).read_text(encoding="utf-8-sig")
        for grid in grids:
            assert f"RefreshGridContent({grid}," in text


def test_no_direct_rowcount_mutation_remains_outside_helper():
    for path in ROOT.glob("*.pas"):
        if path.name == "FmxHelper.pas":
            continue
        text = path.read_text(encoding="utf-8-sig", errors="ignore")
        assert not re.search(r"\.RowCount\s*:=", text), path.name


def test_timer_refreshes_intermediate_states_and_simulation_yields():
    timer = method(MAIN, "procedure TFrameMainTable.TimerMainTimer", "function TFrameMainTable.IsValidFlowGraphChannel")
    assert "UpdateGrids" in timer
    assert "swtMONITOR, swtEXECUTE" not in timer
    scenario = method(MAIN, "procedure TFrameMainTable.RunAutoMeasurementScenario", "procedure TFrameMainTable.MeasurementButtonClickManualMode")
    assert "Application.ProcessMessages" in scenario


def test_release_version():
    assert "APP_VERSION = '1.0.135'" in VERSION
