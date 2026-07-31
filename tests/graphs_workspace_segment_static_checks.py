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


def test_version_is_1_0_32():
    assert "APP_VERSION = '1.0.32';" in VERSION
