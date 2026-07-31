from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = (ROOT / "frmGraphsWorkspace.pas").read_text(encoding="utf-8-sig")
CONFIG = (ROOT / "uGraphsViewConfig.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def routine(signature: str, following: str = "\nprocedure TFrameGraphsWorkspace.") -> str:
    start = WORKSPACE.index(signature)
    end = WORKSPACE.find(following, start + len(signature))
    return WORKSPACE[start:] if end < 0 else WORKSPACE[start:end]


def test_fallback_uses_current_value_only_without_buffered_point():
    body = routine("procedure TFrameGraphsWorkspace.UpdateSeriesPoints")
    assert "BufferedAddedCount := 0;" in body
    assert "else if BufferedAddedCount > 0 then" in body
    assert "BaseY := AMeterValue.GetDoubleValue;" in body
    update = routine("procedure TFrameGraphsWorkspace.UpdateGraphs")
    assert update.index("for GraphIndex :=") < update.index(
        "FLastFallbackSampleMs := NowMs;"
    )


def test_tolerance_is_point_error_based_not_flow_accuracy_based():
    body = routine(
        "function TFrameGraphsWorkspace.ResolvePointTolerance",
        "\nprocedure TFrameGraphsWorkspace.",
    )
    assert "CurrentPoint.Q" in body
    assert "CurrentPoint.Error" in body
    assert "FlowAccuracy" not in routine(
        "procedure TFrameGraphsWorkspace.UpdateToleranceLines"
    )


def test_panel_persists_visibility_and_clear_suppression():
    assert "ShowTargetLine: Boolean;" in CONFIG
    assert "ShowToleranceLines: Boolean;" in CONFIG
    assert "DefaultAssignmentSuppressed: Boolean;" in CONFIG
    clear = routine("procedure TFrameGraphsWorkspace.ClearChart")
    assert "DefaultAssignmentSuppressed := True;" in clear
    reset = routine("procedure TFrameGraphsWorkspace.ResetRuntimeGraphData")
    assert ".Series.Clear" not in reset
    assert "DefaultAssignmentSuppressed" not in reset


def test_default_assignment_is_partitioned_and_deduplicated():
    body = routine("procedure TFrameGraphsWorkspace.RefreshEnabledSources")
    assert "AOwner = gsokEtalon then GraphIndex := 0 else GraphIndex := 1" in body
    assert "FindSeries(GraphIndex, NormalizeUUID(AChannel.UUID), 'ValueFlow')" in body
    assert "for Channel in FWorkTable.EtalonChannels" in body
    assert "for Channel in FWorkTable.DeviceChannels" in body


def test_application_version_is_1_0_35():
    assert "APP_VERSION = '1.0.35';" in VERSION
