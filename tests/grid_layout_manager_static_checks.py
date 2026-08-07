import re
from pathlib import Path

ROOT = Path(__file__).parents[1]
HELPER = (ROOT / 'uGridLayoutManager.pas').read_text(encoding='utf-8-sig')
RESULTS = (ROOT / 'frmMRResults.pas').read_text(encoding='utf-8-sig')
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')


def method(text, signature, next_signature):
    start = text.index(signature)
    return text[start:text.index(next_signature, start + len(signature))]


def test_equal_signature_exits_without_any_column_mutation():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    guard = apply.index('if Signature = AState.FLastSignature')
    structural = apply.index('AState.FApplying := True', guard)
    unchanged = apply[guard:structural]
    assert 'Exit(False)' in unchanged
    for token in ('Column.Width :=', 'Column.Parent :=', 'Column.Index :=',
                  'Column.Visible :=', 'AGrid.BeginUpdate'):
        assert token not in unchanged


def test_obsolete_automatic_width_capture_is_removed():
    for token in ('FWidths', 'CaptureWidths', 'GridWidthRestored',
                  'Columns[I].Width := Widths[I]'):
        assert token not in HELPER
    assert 'FApprovedWidths: TDictionary<string, Single>' in HELPER
    assert 'FManualResizeActive: Boolean' in HELPER
    assert 'FRestoringWidth: Boolean' in HELPER


def test_initial_width_is_applied_before_parent_and_registered_once():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    initial = apply.index('AState.ApplyInitialWidth(Key, Column, Definition.InitialWidth)')
    parent = apply.index('Column.Parent := AGrid', initial)
    register = apply.index('AState.RegisterColumn(Key, Column)', parent)
    assert initial < parent < register
    assert 'AState.UnregisterColumn(Pair.Value)' in apply


def test_set_row_count_does_not_capture_or_restore_widths():
    set_rows = method(
        HELPER,
        'class procedure TGridLayoutManager.SetRowCount',
        'class function TGridLayoutManager.Apply',
    )
    assert 'AGrid.BeginUpdate' in set_rows
    assert 'AGrid.EndUpdate' in set_rows
    assert 'Column.Width :=' not in set_rows
    assert 'Widths[' not in set_rows


def test_results_notifications_are_content_only_and_structure_is_separate():
    notify = method(RESULTS, 'procedure TFrameMRResults.OnNotify',
                    'procedure TFrameMRResults.UpdateUI')
    assert 'TGridLayoutManager.Apply' not in notify
    assert 'BuildColumns' not in notify
    assert 'BuildRows' in notify and 'RefreshRows' in notify
    update = method(RESULTS, 'procedure TFrameMRResults.UpdateUI',
                    'procedure TFrameMRResults.ReloadAndUpdate')
    assert update.count('BuildColumns') == 1


def test_only_dynamic_result_grids_use_structural_helper():
    update = method(PROCEED, 'procedure TFrameProceed.UpdateResultsPointColumns',
                    'function TFrameProceed.CreateResultsGridColumn')
    assert 'TGridLayoutManager.Apply' in update
    assert 'GridDataPoints' not in update
    assert 'TStringColumn.Create' not in update


def test_manual_resize_is_gated_by_mousedown_and_confirmed_by_mouseup():
    assert 'BeginManualColumnResize(GridResults, X, Y)' in PROCEED
    assert 'EndManualColumnResize' in PROCEED
    assert 'BeginManualColumnResize(GridMRResults, X, Y)' in RESULTS
    assert 'EndManualColumnResize' in RESULTS
    assert 'CaptureWidths' not in PROCEED
    assert 'CaptureWidths' not in RESULTS


def test_dynamic_result_columns_share_initial_width():
    assert 'C_DYNAMIC_COLUMN_WIDTH = 125.0' in HELPER
    assert 'TStringColumn, C_DYNAMIC_COLUMN_WIDTH, True, True' in PROCEED
    assert 'TStringColumn, C_DYNAMIC_COLUMN_WIDTH, True, True' in RESULTS
