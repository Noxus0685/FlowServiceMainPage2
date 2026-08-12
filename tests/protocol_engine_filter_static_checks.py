from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FORM = (ROOT / "frmProtocol.pas").read_text(encoding="utf-8-sig")
RESOURCE = (ROOT / "frmProtocol.fmx").read_text(encoding="utf-8-sig")
PROTOCOLS = (ROOT / "uProtocols.pas").read_text(encoding="utf-8-sig")


def test_engine_source_has_an_independent_ui_filter():
    assert "CheckBoxEngine: TCheckBox;" in FORM
    assert "psEngine: Result := CheckBoxEngine.IsChecked;" in FORM
    assert "psEngine: Result := CheckBoxWorkLog.IsChecked;" not in FORM
    assert "LoadCheckBoxSetting(Ini, CheckBoxEngine);" in FORM
    assert "SaveCheckBoxSetting(Ini, CheckBoxEngine);" in FORM
    assert "object CheckBoxEngine: TCheckBox" in RESOURCE
    assert "Text = 'ENG'" in RESOURCE


def test_proc_engine_messages_are_visible_with_fresh_settings():
    constructor = FORM.split("constructor TFrameProtocol.Create", 1)[1].split(
        "function TFrameProtocol.ProtocolSettingsFileName", 1
    )[0]
    assert "CheckBoxProc.IsChecked := True;" in constructor
    assert "CheckBoxEngine.IsChecked := True;" in constructor


def test_engine_and_work_log_markers_are_visible_in_formatted_messages():
    assert "pcWorkLog: Result := 'WORKLOG';" in PROTOCOLS
    assert "psEngine: Result := 'ENG';" in PROTOCOLS
