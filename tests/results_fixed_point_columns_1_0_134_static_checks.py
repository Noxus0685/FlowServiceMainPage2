from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmProceed.fmx").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def method(start, following):
    return PAS[PAS.index(start):PAS.index(following, PAS.index(start))]


def test_twenty_stored_components_precede_result_columns():
    positions = []
    for number in range(1, 21):
        marker = f"object StringColumnPointNum{number}: TStringColumn"
        assert FMX.count(marker) == 1
        positions.append(FMX.index(marker))
        block = FMX[FMX.index(marker):FMX.index("          end", FMX.index(marker))]
        assert "Visible = False" in block
        assert "Stored = False" not in block
        assert f"StringColumnPointNum{number}: TStringColumn;" in PAS
    assert positions == sorted(positions)
    assert positions[-1] < FMX.index("object StringColumnResult: TStringColumn")
    assert FMX.index("object StringColumnResult: TStringColumn") < FMX.index(
        "object StringColumnResultComment: TStringColumn"
    )
    grid = FMX[FMX.index("object GridResults: TGrid"):FMX.index("object MemoLog: TMemo")]
    assert "ColumnMove" not in grid


def test_update_only_configures_fixed_columns():
    body = method(
        "procedure TFrameProceed.UpdateResultsPointColumns;",
        "function TFrameProceed.FindResultSpillageForPoint",
    )
    assert "C_RESULTS_POINT_COLUMN_COUNT = 20" in PAS
    assert "FResultsPointColumns[I].Header" in body
    assert "FResultsPointColumns[I].Visible := True" in body
    assert "FResultsPointColumns[I].Visible := False" in body
    assert "FResultsPointColumns[I].Tag := I" in body
    assert "FResultsPointColumns[I].Tag := -1" in body
    assert "ProcessingResultPointColumnLimitExceeded" in body
    for forbidden in (".Create(", ".Free", ".Parent :=", ".Index :=", ".Width :="):
        assert forbidden not in body


def test_values_resolve_fixed_column_with_bounds_checks():
    body = method(
        "procedure TFrameProceed.GridResultsGetValue",
        "procedure TFrameProceed.GridResultsDrawColumnCell",
    )
    assert "PointIndex := GetResultsPointColumnIndex" in body
    assert "PointIndex < Length(FResultPointColumns)" in body
    assert "PointIndex < Length(Row.PointValues)" in body
    assert "Value := '';" in body


def test_dynamic_results_column_implementation_is_absent():
    for forbidden in (
        "Processing" + "DynamicPoint", "Processing" + "PointColumn",
        "CreateResults" + "GridColumn", "TStringColumn.Create(" + "GridResults)",
    ):
        assert forbidden not in PAS


def test_release_version():
    assert "APP_VERSION = '1.0.135'" in VERSION
