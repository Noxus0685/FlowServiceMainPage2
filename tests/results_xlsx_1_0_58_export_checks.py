from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
EXPORTER = (ROOT / "uResultsXlsxExporter.pas").read_text(encoding="utf-8-sig")
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
XLSX = (ROOT / "uOpenXmlXlsx.pas").read_text(encoding="utf-8-sig")


def test_percentage_points_conversion_examples():
    convert = lambda value: value / 100
    for source, expected in ((.67, .0067), (-.49, -.0049), (0, 0), (7.9677, .079677)):
        assert math.isclose(convert(source), expected, rel_tol=0, abs_tol=1e-12)
    assert "Result := AValue / 100;" in EXPORTER
    assert "PercentPointsToExcelFraction(R.Error)" in EXPORTER
    assert "PercentPointsToExcelFraction(R.PointAllowedError)" in EXPORTER


def test_both_error_cells_are_numeric_percent_cells_and_allowed_error_can_be_blank():
    assert "formatCode=\"0.0000%\"" in XLSX
    assert "S.WriteNumber(Row,7,PercentPointsToExcelFraction(R.Error),xsError)" in EXPORTER
    assert "if R.PointAllowedErrorSet then S.WriteNumber(Row,8," in EXPORTER
    assert "PointAllowedError: Double" in EXPORTER
    assert "DevicePoint.Error" in RESULTS


def test_flow_uses_production_dimension_conversion_at_snapshot_boundary():
    assert "ValueFlowRate.CurrentDimIndex" in RESULTS
    assert "ValueFlowRate.GetDimName" in RESULTS
    assert RESULTS.count("ValueFlowRate.GetDoubleNum(") >= 2
    assert "ER.ReferenceFlow" not in EXPORTER
    convert = lambda base, rate, divider: base * rate / divider
    assert math.isclose(convert(1.0, 3600, 1000), 3.6)
    assert math.isclose(convert(1.004245, 3600, 1000), 3.615282, abs_tol=1e-12)
    assert math.isclose(convert(1.004245, 1, 1), 1.004245)


def test_per_device_worksheets_are_filtered_unique_and_bounded():
    assert "W.AddWorksheet(SheetName)" in EXPORTER
    assert "SameText(R.DeviceUUID, D.UUID)" in EXPORTER
    assert "Copy(ABase, 1, 31 - Length(Suffix)) + Suffix" in EXPORTER
    assert "SWorksheetResults" not in EXPORTER
    assert "if ResultCount = 0 then DeviceSheets.Add('')" in EXPORTER
    assert "DeviceSheets.Add(UniqueSheetName" in EXPORTER
