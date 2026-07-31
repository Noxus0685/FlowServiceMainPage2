from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "frmGraphsWorkspace.pas").read_text(encoding="utf-8-sig")
CONFIG = (ROOT / "uGraphsViewConfig.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def routine(signature: str) -> str:
    start = SOURCE.index(signature)
    positions = [p for marker in ("\nprocedure TFrameGraphsWorkspace.", "\nfunction TFrameGraphsWorkspace.")
                 if (p := SOURCE.find(marker, start + len(signature))) >= 0]
    return SOURCE[start:min(positions, default=len(SOURCE))]


def test_tolerance_uses_device_source_and_absolute_error():
    body = routine("function TFrameGraphsWorkspace.ResolvePointTolerance")
    assert "ResolveToleranceSource(SourceInfo, AReason)" in body
    assert "Abs(AErrorPercent)" in body
    assert "AErrorPercent <= 0" not in body
    assert "CurrentPoint.Error" not in body
    assert "FlowAccuracy" not in body
    assert "TSpillage" not in body


def test_resolution_priority_and_uuid_recovery_are_explicit():
    body = routine("function TFrameGraphsWorkspace.ResolveToleranceSource")
    assert body.index("RunPointIndex := Run.CurrentPointIndex") < body.index("RunPoint := Run.CurrentPoint")
    assert body.index("ValidateDevicePointsTolerance") < body.index("DevicePointByUUID")
    assert "NormalizeUUID(Point.UUID) <> NormalizeUUID(RunPoint.UUID)" in body
    assert body.index("DevicePointByUUID") < body.index("DevicePointByQAndName")
    assert body.index("DevicePointByQAndName") < body.index("RunCurrentPoint")


def test_device_tolerances_are_compared_and_mismatch_hides_lines():
    body = routine("function TFrameGraphsWorkspace.ValidateDevicePointsTolerance")
    assert "for Channel in FWorkTable.DeviceChannels" in body
    assert "Channel.Enabled" in body
    assert "Device.Points[APointIndex]" in body
    assert "SameValue(Point.Q, AReferencePoint.Q, 1E-9)" in body
    assert "SameValue(Point.Error, AReferencePoint.Error, 1E-9)" in body
    assert "DevicePointsToleranceMismatch" in body
    update = routine("procedure TFrameGraphsWorkspace.UpdateToleranceLines")
    assert "Available and FConfig.Panels[I].ShowToleranceLines" in update


def test_diagnostics_publish_source_uuid_index_and_are_throttled():
    for event in ("GraphToleranceSourceResolved", "GraphToleranceSourceFallback",
                  "GraphToleranceSourceMismatch", "GraphToleranceSourceUnavailable"):
        assert event in SOURCE
    resolved = routine("procedure TFrameGraphsWorkspace.UpdateToleranceLines")
    for field in ("SourceKind", "SourceDeviceUUID", "SourcePointUUID", "SourcePointIndex",
                  "RunPointUUID", "RunPointIndex", "RunPointQ", "RunPointError",
                  "ResolvedTargetQ", "ResolvedErrorPercent", "ToleranceValue", "Lower", "Upper"):
        assert field + "=" in resolved
    throttle = routine("procedure TFrameGraphsWorkspace.LogToleranceEvent")
    assert "FToleranceDiagnosticTimes.TryGetValue" in throttle
    assert "NowMs - PreviousMs < 2000" in throttle


def test_default_line_visibility_and_version():
    assert "FPanels[0].ShowTargetLine := False" in CONFIG
    assert "FPanels[0].ShowToleranceLines := False" in CONFIG
    assert "FPanels[1].ShowTargetLine := True" in CONFIG
    assert "FPanels[1].ShowToleranceLines := True" in CONFIG
    assert "APP_VERSION = '1.0.36';" in VERSION
