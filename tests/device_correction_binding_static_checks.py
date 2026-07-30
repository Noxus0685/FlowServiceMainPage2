from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


device = (ROOT / "uDeviceClass.pas").read_text(encoding="utf-8-sig")
flow = (ROOT / "uFlowMeter.pas").read_text(encoding="utf-8-sig")
form = (ROOT / "fuMeterValues.pas").read_text(encoding="utf-8-sig")
main = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
version = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


assert "cctMeterValueCoef = 1" in device
assert "TryCalibrCoefTableType" in device
assert "Ord(Low(TCalibrCoefTableType))" in device
assert "Ord(High(TCalibrCoefTableType))" in device
assert "APP_VERSION = '1.0.9'" in version
assert "RefreshCorrectionTables" in flow
assert "DeviceCorrectionTableBound" in flow
assert "DeviceCorrectionTableTypeResolved" in flow
assert "DeviceCorrectionTableTypeRaw" in flow
assert "TCalibrCoefTableType(ARawType)" not in device
assert "(ValueCoef.DependenceType = INDEPENDENT)" not in flow
assert "TryResolveCalibrCoefTableTarget" in device
assert "cctReference: ATargetField := 'Device.CalibrCoefTables[cctReference]'" in device
assert "ProcessedBindings" in flow
assert "FindTableByType(FlowMeter, cctReference)" in form
for field in ("ValueCoef", "ValueFlow", "ValueQuantity", "ValueDensity"):
    assert f"ATargetField := '{field}'" in device
assert "SameInstance=True" in flow
assert "MeterValueCorrectionTabOpened" in form
assert "MeterValueCorrectionGridFilled" in form
assert "MeterValueSelected" in form
assert "DeviceCorrectionTableTargetResolved" in flow
assert "AmbiguousTargetMeterValue" in form
assert "FlowMeter.ValueCoef" in main
assert "resolved by TableType" not in (ROOT / "fuDeviceEdit.pas").read_text(
    encoding="utf-8-sig"
)

print("device correction binding static checks passed")
