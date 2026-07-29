from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def test_processing_header_uses_column_identity_and_any_enabled_rule():
    pas = source("frmProceed.pas")
    fmx = source("frmProceed.fmx")
    body = pas.split("procedure TFrameProceed.GridDataPointsHeaderClick", 1)[1]
    body = body.split("procedure TFrameProceed.GridDataPointsColumnMoved", 1)[0]
    assert "Column <> CheckColumnSpillageEnable" in body
    assert "HasEnabledRow := False" in body
    assert "NewEnabled := not HasEnabledRow" in body
    assert "Point.Enabled := NewEnabled" in body
    assert "OnHeaderClick = GridDataPointsHeaderClick" in fmx


def test_channel_headers_update_channel_models():
    pas = source("frmMainTable.pas")
    fmx = source("frmMainTable.fmx")
    device = pas.split("procedure TFrameMainTable.GridDevicesHeaderClick", 1)[1]
    device = device.split("procedure TFrameMainTable.GridEtalonsHeaderClick", 1)[0]
    etalon = pas.split("procedure TFrameMainTable.GridEtalonsHeaderClick", 1)[1]
    etalon = etalon.split("procedure TFrameMainTable.GridDevicesCellDblClick", 1)[0]
    assert "Column = CheckColumnDeviceEnable1" in device
    assert "DeviceChannels[Row].Enabled := NewEnabled" in device
    assert "NewEnabled := not HasEnabledRow" in device
    assert "Column <> CheckColumnEtalonEnable1" in etalon
    assert "EtalonChannels[Row].Enabled := NewEnabled" in etalon
    assert "OnHeaderClick = GridEtalonsHeaderClick" in fmx


def test_other_enabled_headers_have_identity_guards():
    cases = {
        "fuDeviceSelect.pas": "Column = CheckColumnDeviceEnable",
        "fuTypeSelect.pas": "Column = CheckColumnTypeEnable",
        "frmCalibrCoefs.pas": "Column <> CheckColumnCoefEnable",
    }
    for filename, guard in cases.items():
        assert guard in source(filename)
