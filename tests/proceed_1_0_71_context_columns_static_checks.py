from pathlib import Path

root = Path(__file__).resolve().parents[1]
pas = (root / "frmProceed.pas").read_text(encoding="utf-8-sig")

assert "AbsolutePosition" not in pas
show = pas.split("procedure TFrameProceed.ShowDevicesResults", 1)[1]
assert "pscDevice: PointKeyPrefix := 'DevicePoint.'" in show
assert "pscSession: PointKeyPrefix := 'SessionPoint.'" in show
assert "else PointKeyPrefix := 'WorkPoint.'" in show
assert "if AContextKind = pscSession then" in show
assert "Spillage.SessionID = ActiveSession.ID" in show
assert "FindMatchedDevicePointForSpillage" in show
assert "ProceedGridContextColumnsBuilt" in show

# The fix must use the existing row/column builder, not introduce another layer.
for forbidden in ("BuildWorkTableColumns", "BuildDeviceColumns", "BuildSessionColumns",
                  "BuildColumnsByContext", "ClearGridContext", "ReloadGridValues"):
    assert forbidden not in pas

print("Proceed 1.0.71 minimal context checks passed")
