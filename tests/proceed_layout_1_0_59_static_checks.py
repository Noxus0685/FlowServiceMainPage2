from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
FMX = (ROOT / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
MAIN = (ROOT / 'frmMainTable.pas').read_text(encoding='utf-8-sig')


def body(name: str) -> str:
    start = PAS.index(f'procedure TFrameProceed.{name}')
    end = PAS.find('\nprocedure TFrameProceed.', start + 1)
    return PAS[start:] if end < 0 else PAS[start:end]


def test_layout_uses_existing_worktable_storage_and_stable_names():
    capture = body('CaptureGridColumnsLayout')
    apply = body('ApplyGridColumnsLayout')
    save = body('SaveLayoutSettingsToWorkTable')
    assert 'AColumns[I].Name := AGrid.Columns[I].Name' in capture
    assert 'DisplayIndex' in capture and 'Width' in capture and 'Visible' in capture
    assert 'SameText(AGrid.Columns[J].Name, AColumns[I].Name)' in apply
    assert 'WorkTable.DataPointsGridColumns :=' in save
    assert 'WorkTable.ResultsGridColumns :=' in save
    assert 'FWorkTableManager.Save' in save


def test_layout_is_applied_after_rows_are_populated():
    for method, row_assignment, apply_call in (
        ('UpdateGridResults', 'GridResults.RowCount := Length(FCurrentResultRows)',
         'ApplyGridColumnsLayout(GridResults, FActiveWorkTable.ResultsGridColumns)'),
        ('UpdateGridDataPoints', 'GridDataPoints.RowCount := Length(FCurrentSpillages)',
         'ApplyGridColumnsLayout(GridDataPoints, FActiveWorkTable.DataPointsGridColumns)'),
    ):
        source = body(method)
        assert source.index(row_assignment) < source.index(apply_call)
    assert 'if Length(WorkTable.DataPointsGridColumns) = 0 then' in MAIN


def test_columns_root_is_permanent_and_only_children_are_rebuilt():
    popup = body('PopupMenuGridResultsPopup')
    for name in ('MenuItemGridDataPointsColumns', 'MenuItemGridResultsColumns'):
        assert FMX.count(f'object {name}: TMenuItem') == 1
        assert name in popup
    assert 'ColumnsMenu.Children[I].Free' in popup
    assert 'ColumnsMenu := TMenuItem.Create' not in popup
    assert 'Item.TagString := Grid.Columns[I].Name' in popup


def test_open_hint_is_cancelled_when_hovered_row_changes():
    for method in ('GridResultsMouseMove', 'GridDataPointsMouseMove'):
        source = body(method)
        assert 'CellByPoint(X, Y, Col, Row)' in source
        assert 'Application.CancelHint;' in source
        assert source.index('Application.CancelHint;') < source.index(".Hint := ''")
