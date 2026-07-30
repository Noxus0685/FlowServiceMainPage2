from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


device = (ROOT / "uDeviceClass.pas").read_text(encoding="utf-8-sig")
flow = (ROOT / "uFlowMeter.pas").read_text(encoding="utf-8-sig")
form = (ROOT / "fuMeterValues.pas").read_text(encoding="utf-8-sig")
main = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
version = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


assert "cctMeterValueCoef = 0" in device
assert "APP_VERSION = '1.0.5'" in version
assert "RefreshCorrectionTables" in flow
assert "DeviceCorrectionTableBound" in flow
for field in ("ValueCoef", "ValueFlow", "ValueQuantity", "ValueDensity"):
    assert f"TargetField := '{field}'" in flow
assert "SameInstance=True" in flow
assert "MeterValueCorrectionTabOpened" in form
assert "MeterValueCorrectionGridFilled" in form
assert "FlowMeter.ValueCoef" in main
assert "resolved by TableType" not in (ROOT / "fuDeviceEdit.pas").read_text(
    encoding="utf-8-sig"
)

print("device correction binding static checks passed")
