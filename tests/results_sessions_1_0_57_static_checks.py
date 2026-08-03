from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
RESULTS_FMX = (ROOT / "frmMRResults.fmx").read_text(encoding="utf-8-sig")
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
HOST = (ROOT / "fuTable_Main.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
PROTOCOL = (ROOT / "frmProtocol.pas").read_text(encoding="utf-8-sig")


def test_results_buttons_use_processing_routes():
    assert "object ButtonClearSession: TButton" in RESULTS_FMX
    assert "object ButtonCreateSession: TButton" in RESULTS_FMX
    assert "RequestClearActiveSession(Channel.FlowMeter.Device)" in RESULTS
    assert "RequestCreateSession(Channel.FlowMeter.Device)" in RESULTS
    assert "ActionSessionDeleteExecute(ActionSessionDelete);" in PROCEED
    assert "ActionSessionNewExecute(ActionSessionNew);" in PROCEED
    assert "TMeasurementRun.CreateSession" not in RESULTS


def test_both_results_views_are_synchronized():
    assert "FFrameProceed.OnResultsSynchronized := FFrameMainTable.RefreshSynchronizedResults" in HOST
    assert "FFrameMRResults.UpdateUI" in MAIN
    assert "SelectTreeItemByTagObject(Session)" in PROCEED
    assert "SelectTreeItemByTagObject(ADevice)" in PROCEED


def test_required_proc_events_are_present():
    for event in (
        "ResultsSessionClearRequested",
        "ResultsSessionCleared",
        "ResultsSessionCreateRequested",
        "ResultsSessionCreated",
        "ResultsViewSynchronized",
    ):
        assert f"'{event}'" in PROCEED
    for field in ("SourceTab=Results", "DeviceUUID=%s", "Sessions=%d", "Spillages=%d"):
        assert field in PROCEED


def test_application_version_is_1_0_58():
    assert "APP_VERSION = '1.0.58'" in VERSION
    assert "'ApplicationVersion'" in PROTOCOL
    assert "Version=%s" in PROTOCOL
