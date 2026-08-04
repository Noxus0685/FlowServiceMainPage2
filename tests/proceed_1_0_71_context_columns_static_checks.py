from pathlib import Path

root = Path(__file__).resolve().parents[1]
pas = (root / "frmProceed.pas").read_text(encoding="utf-8-sig")

assert "AbsolutePosition" not in pas
show = pas.split("procedure TFrameProceed.ShowDevicesResults", 1)[1]
assert "Row.PointKeys[I] := 'Point.' + P.UUID" in show
for virtual_prefix in ("'WorkPoint.'", "'DevicePoint.'", "'SessionPoint.'"):
    assert virtual_prefix not in show
assert "if AContextKind = pscSession then" in show
assert "Spillage.SessionID = ActiveSession.ID" in show
assert "FindMatchedDevicePointForSpillage" in show
assert "ProceedGridContextColumnsBuilt" in show
assert 'SelectedDeviceUUID=%s; SelectedSessionID=%d; PointCount=%d' in show

# The fix must use the existing row/column builder, not introduce another layer.
for forbidden in ("BuildWorkTableColumns", "BuildDeviceColumns", "BuildSessionColumns",
                  "BuildColumnsByContext", "ClearGridContext", "ReloadGridValues"):
    assert forbidden not in pas

print("Proceed 1.0.71 minimal context checks passed")
