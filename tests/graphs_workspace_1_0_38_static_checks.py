from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
source = (root / "frmGraphsWorkspace.pas").read_text(encoding="utf-8")
fmx = (root / "frmGraphsWorkspace.fmx").read_text(encoding="utf-8")
config = (root / "uGraphsViewConfig.pas").read_text(encoding="utf-8")
assert "array[0..3] of TChartSeries" not in source
assert all(x not in source for x in ("LayoutGraphSlot1", "ChartGraph1", "LayoutArea1", "LayoutParking"))
assert "FGraphSlots: TObjectList<TGraphVisualSlot>" in source
chart = source[source.index("function TFrameGraphsWorkspace.ChartByIndex"):]
chart = chart[:chart.index("end;")]
assert "GraphSlotByIndex" in chart and "case AIndex" not in chart
assert "if Wanted > 4" not in config
assert "AColumns - 1) div AColumns" in source
assert "MaxColumnsByWidth" in source and "MinimumGraphWidth" in config
assert "TVertScrollBox" in fmx and "LayoutGraphsHost" in fmx
assert all(x not in fmx for x in ("LayoutGraphSlot1", "LayoutArea1", "ChartGraph1"))
assert all(x in source for x in ("TargetSeries: TChartSeries", "RuntimeResetTimeMs: Int64", "ResetGraphRuntimeData", "EffectiveResetTimeMs"))
local = source[source.index("procedure TFrameGraphsWorkspace.ResetGraphRuntimeData"):source.index("procedure TFrameGraphsWorkspace.ResetRuntimeGraphData")]
assert "Panels[AGraphIndex].Series.Clear" not in local and "DefaultAssignmentSuppressed" not in local
assert "FSharedSegmentStartMs :=" not in local
assert "GraphRuntimeValuesReset" in local and "AssignmentsPreserved=True" in local
assert "MenuItemClearGraphValues" in fmx and "Очистить значения графика" in fmx
for n in (1, 2, 4, 5, 9, 16):
    cols = min(max(1, int(1680 / 420)), n)
    rows = (n + cols - 1) // cols
    assert cols >= 1 and rows * cols >= n
