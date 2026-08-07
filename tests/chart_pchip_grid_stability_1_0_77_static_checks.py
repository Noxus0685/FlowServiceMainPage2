import re
from pathlib import Path


ROOT = Path(__file__).parents[1]
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
PROCEED_FORM = (ROOT / "frmProceed.fmx").read_text(encoding="utf-8-sig")
CHART = (ROOT / "Components/FP/FMX.SimpleChart.pas").read_text(
    encoding="utf-8-sig"
)
MR_RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
GRID_LAYOUT = (ROOT / "uGridLayoutManager.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def method_body(source: str, class_name: str, method_name: str) -> str:
    start = re.search(
        rf"(?:procedure|function)\s+{class_name}\.{method_name}\b.*?;\s*",
        source,
        re.IGNORECASE | re.DOTALL,
    )
    assert start, f"{class_name}.{method_name} not found"
    next_method = re.search(
        rf"\n(?:class\s+)?(?:procedure|function)\s+{class_name}\.",
        source[start.end():],
        re.IGNORECASE,
    )
    assert next_method, f"end of {class_name}.{method_name} not found"
    return source[start.end():start.end() + next_method.start()]


def test_chart_supports_independent_line_and_axis_settings():
    assert "TChartAverageLineMode = (calmPchipLogQ, calmLinearSegments)" in PROCEED
    assert "TChartFlowScale = (cfsLogarithmic, cfsLinear)" in PROCEED
    assert "function AddPchipLogLine" in PROCEED
    assert "FitPolynomial" not in PROCEED
    assert "EvaluatePolynomial" not in PROCEED
    assert "MenuItemChartLinePchip" in PROCEED_FORM
    assert "MenuItemChartLineSegments" in PROCEED_FORM
    assert "MenuItemChartScaleLog" in PROCEED_FORM
    assert "MenuItemChartScaleLinear" in PROCEED_FORM


def test_simple_chart_maps_log_axis_without_changing_series_values():
    assert "property LogarithmicX" in CHART
    assert "PointX := Log10(Value.X)" in CHART
    assert "function TSimpleChart.GetLogTicks" in CHART


def test_measurement_result_columns_have_stable_keys_and_rows():
    key_body = method_body(MR_RESULTS, "TFrameMRResults", "GetDisplayPointKey")
    assert "ScenarioPoint.UUID" not in key_body
    assert "KeyParts.Sorted := True" in key_body
    headers_body = method_body(MR_RESULTS, "TFrameMRResults", "MakeDisplayHeadersUnique")
    assert "ScenarioPoint.UUID" not in headers_body
    refresh_body = method_body(MR_RESULTS, "TFrameMRResults", "RefreshRows")
    assert "FRows.Count, True" not in refresh_body


def test_grid_widths_are_never_changed_after_end_update():
    assert "TGridDeferredWidthRestore" not in GRID_LAYOUT
    row_body = method_body(GRID_LAYOUT, "TGridLayoutManager", "SetRowCount")
    end_update = row_body.index("AGrid.EndUpdate")
    assert ".Width :=" not in row_body[end_update:]


def test_version():
    assert "APP_VERSION = '1.0.77'" in VERSION
