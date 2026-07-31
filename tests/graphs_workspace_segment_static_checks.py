from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = (ROOT / "frmGraphsWorkspace.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def routine(signature: str) -> str:
    start = WORKSPACE.index(signature)
    candidates = [
        WORKSPACE.find("\nprocedure TFrameGraphsWorkspace.", start + len(signature)),
        WORKSPACE.find("\nfunction TFrameGraphsWorkspace.", start + len(signature)),
    ]
    end = min((position for position in candidates if position >= 0), default=len(WORKSPACE))
    return WORKSPACE[start:end]


def test_initialize_does_not_repeat_runtime_reset():
    body = routine("procedure TFrameGraphsWorkspace.Initialize")
    assert "ResetRuntimeGraphData" not in body
    assert "if FirstInitialization then" in body


def test_update_owns_one_segment_decision_per_tick():
    body = routine("procedure TFrameGraphsWorkspace.UpdateGraphs")
    assert "NewRunStarted := RunActive and not FLastRunActive;" in body
    assert body.count("StartSharedSegment(") == 1
    assert "else if SamplingActive and not FSharedTimeInitialized" not in body
    assert body.rfind("FLastRunActive := RunActive;") > body.rfind("UpdateToleranceLines;")


def test_point_identity_and_reset_barrier_are_preserved():
    update = routine("procedure TFrameGraphsWorkspace.UpdateGraphs")
    reset = routine("procedure TFrameGraphsWorkspace.ResetRuntimeGraphData")
    assert "(FLastPointKey <> '') and (PointKey <> FLastPointKey)" in update
    assert "FRuntimeResetTimeMs := TMeterValue.GetMonotonicTimeMs;" in reset
    assert "FLastPointKey := PointKey; FLastPointIndex := PointIndex;" in reset
    assert "FLastPointKey := '';" not in reset


def test_segment_reset_sets_series_runtime_once():
    body = routine("procedure TFrameGraphsWorkspace.ResetSeriesSegment")
    for statement in (
        "LastSampleTimeMs := 0;",
        "LastSampleIndex := -1;",
        "WaitingForFirstSample := True;",
        "LastAcceptedPointKey := APointKey;",
        "GraphSeriesRuntimeReset",
    ):
        assert statement in body


def test_version_is_1_0_34():
    assert "APP_VERSION = '1.0.34';" in VERSION


def test_visual_series_pipeline_is_explicit_and_diagnostic():
    update = routine("procedure TFrameGraphsWorkspace.UpdateGraphs")
    for statement in (
        "EnsureVisualSeries(GraphIndex, Config)",
        "ResolveSeriesSource(Config, Channel, MeterValue, ResolveReason)",
        "UpdateSeriesPoints(GraphIndex, Config, VisualSeries, MeterValue",
        "GraphWorkspaceUpdateBegin",
        "GraphSeriesUpdateBegin",
        "GraphSeriesSourceResolved",
        "GraphWorkspaceUpdateDone",
    ):
        assert statement in update
    point_update = routine("procedure TFrameGraphsWorkspace.UpdateSeriesPoints")
    assert "AMeterValue.GetStabilitySamples" not in point_update  # delegated helper
    assert "AChartSeries.AddPoint(X, DisplayY);" in point_update
    assert "GraphSeriesPointAdded" in point_update
    assert "SampleBeforeSegment" in point_update
    assert "SampleBeforeReset" in point_update


def test_workspace_update_is_called_once_from_main_refresh():
    main = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
    assert main.count("FGraphsWorkspace.UpdateGraphs;") == 1


def test_empty_sample_buffer_has_shared_one_second_fallback():
    update = routine("procedure TFrameGraphsWorkspace.UpdateGraphs")
    points = routine("procedure TFrameGraphsWorkspace.UpdateSeriesPoints")
    start = routine("procedure TFrameGraphsWorkspace.StartSharedSegment")
    reset = routine("procedure TFrameGraphsWorkspace.ResetRuntimeGraphData")
    assert "FallbackSampleIntervalMs = 1000;" in update
    assert update.index("DoFallback := SamplingActive") < update.index(
        "for GraphIndex := 0 to FConfig.GraphCount - 1 do"
    )
    assert update.index("FLastFallbackSampleMs := NowMs;") > update.index(
        "for GraphIndex := 0 to FConfig.GraphCount - 1 do"
    )
    assert "BufferedAddedCount > 0" in points
    assert "BaseY := AMeterValue.GetDoubleValue;" in points
    assert "AChartSeries.AddPoint(X, DisplayY);" in points
    assert "IsPointTransitionStage" in points
    assert "FSharedSegmentStartMs" in points
    assert "FLastFallbackSampleMs := 0;" in start
    assert "FLastFallbackSampleMs := 0;" in reset
