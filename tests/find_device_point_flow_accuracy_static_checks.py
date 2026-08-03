from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RUN = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")


find_device_point = RUN.split(
    "function TMeasurementRun.FindDevicePoint(AChannel: TChannel): TDevicePoint;", 1
)[1].split(
    "function TMeasurementRun.IsPointSetupReady", 1
)[0]

# The match must use the shared work-table point, whose FlowAccuracy defines the
# accepted range, while each device point's Q is the value being checked.
assert "Point := FWorkTable.CurrentPoint" in find_device_point
assert "Device.IsFlowInPoint(Candidate.Q, Point)" in find_device_point
assert "IsFlowInPoint(Point.Q, Candidate)" not in find_device_point

# All matching candidates are compared, so collection order cannot select a
# farther point merely because it appeared first.
range_check = find_device_point.index("Device.IsFlowInPoint(Candidate.Q, Point)")
distance = find_device_point.index("Distance := Abs(Candidate.Q - Point.Q)")
best_check = find_device_point.index("if Distance < BestDistance then")
assert range_check < distance < best_check
assert "BestDistance := MaxDouble" in find_device_point
assert "BestDistance := Distance" in find_device_point

# FindDevicePoint delegates range interpretation and retains its guards. It must
# not reintroduce the former near-exact tolerance or parse FlowAccuracy itself.
assert "1E-4" not in find_device_point
assert "Tolerance" not in find_device_point
assert "FlowAccuracy" in find_device_point  # explanatory comment only
assert "NormalizeFlowAccuracyInput" not in find_device_point
assert "AChannel = nil" in find_device_point
assert "not AChannel.Enabled" in find_device_point
assert "AChannel.FlowMeter = nil" in find_device_point
assert "AChannel.FlowMeter.Device = nil" in find_device_point
assert "Device.Points = nil" in find_device_point
assert "FWorkTable = nil" in find_device_point
assert "Point = nil" in find_device_point
