from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "frmGraphsWorkspace.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmGraphsWorkspace.fmx").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_dynamic_slots_and_vertical_scrolling():
    assert "FGraphSlots: TObjectList<TGraphVisualSlot>" in SOURCE
    assert "function TFrameGraphsWorkspace.ChartByIndex" in SOURCE
    assert "GraphSlotByIndex(AIndex)" in SOURCE
    assert "array[0..3]" not in SOURCE
    assert "TVertScrollBox" in FMX
    assert "ChartGraph1" not in FMX


def test_history_and_reset_modes_are_distinct():
    assert "TGraphHistoryLoadMode = (ghlmCurrentSegmentHistory, ghlmAfterLocalReset)" in SOURCE
    assert "Runtime.RuntimeResetTimeMs := 0" in SOURCE
    assert "Runtime.HistoryLoaded := False" in SOURCE
    assert "(Sample.TimeStampMs - FSharedSegmentStartMs) / 1000.0" in SOURCE
    local_reset = SOURCE[SOURCE.index("procedure TFrameGraphsWorkspace.ResetGraphRuntimeData"):SOURCE.index("procedure TFrameGraphsWorkspace.ResetRuntimeGraphData")]
    assert "ghlmAfterLocalReset" in local_reset
    assert "ClearWorkspaceSegmentHistory" not in local_reset
    global_reset = SOURCE[SOURCE.index("procedure TFrameGraphsWorkspace.ResetRuntimeGraphData"):SOURCE.index("procedure TFrameGraphsWorkspace.UpdateGraphs")]
    assert "ClearWorkspaceSegmentHistory" in global_reset


def test_segment_archive_and_version():
    assert "FSegmentHistory: TObjectDictionary<string, TGraphSourceHistory>" in SOURCE
    assert "ClearWorkspaceSegmentHistory;\n  ResetSeriesSegment" in SOURCE
    assert "APP_VERSION = '1.0.39'" in VERSION
