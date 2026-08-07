import re
from pathlib import Path

ROOT = Path(__file__).parents[1]
HELPER = (ROOT / 'uGridLayoutManager.pas').read_text(encoding='utf-8-sig')
RESULTS = (ROOT / 'frmMRResults.pas').read_text(encoding='utf-8-sig')
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')


def method(text, signature, next_signature):
    start = text.index(signature)
    return text[start:text.index(next_signature, start + len(signature))]


def test_equal_signature_restores_width_without_structural_mutation():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    guard = apply.index('if Signature = AState.FLastSignature')
    structural = apply.index('AState.FApplying := True', guard)
    unchanged = apply[guard:structural]
    assert 'AState.FColumns.TryGetValue' in unchanged
    assert 'AState.FWidths.TryGetValue' in unchanged
    assert 'Column.Width := SavedWidth' in unchanged
    assert 'GridWidthRestored' in unchanged
    assert 'AGrid.BeginUpdate' not in unchanged
    assert '.Parent :=' not in unchanged
    assert '.Index :=' not in unchanged
    assert 'Exit(False)' in unchanged


def test_state_and_declarative_definition_contain_required_fields():
    for field in ('Key:', 'Header:', 'ColumnClass:', 'InitialWidth:',
                  'ReadOnly:', 'Visible:'):
        assert field in HELPER
    assert 'FLastSignature: string' in HELPER
    assert 'FWidths: TDictionary<string, Single>' in HELPER


def test_results_notifications_are_content_only_and_structure_is_separate():
    notify = method(RESULTS, 'procedure TFrameMRResults.OnNotify',
                    'procedure TFrameMRResults.UpdateUI')
    assert 'TGridLayoutManager.Apply' not in notify
    assert 'BuildColumns' not in notify
    assert 'BuildRows' in notify and 'RefreshRows' in notify
    update = method(RESULTS, 'procedure TFrameMRResults.UpdateUI',
                    'procedure TFrameMRResults.ReloadAndUpdate')
    assert update.count('BuildColumns') == 1


def test_only_dynamic_proceed_results_grid_uses_structural_helper():
    update = method(PROCEED, 'procedure TFrameProceed.UpdateResultsPointColumns',
                    'function TFrameProceed.CreateResultsGridColumn')
    assert 'TGridLayoutManager.Apply' in update
    assert 'GridDataPoints' not in update
    assert 'ExistingColumn' not in update  # supplied declaratively, never freed manually
    assert 'TStringColumn.Create' not in update


def test_no_structural_helper_in_notification_or_timer_handlers():
    frequent = re.finditer(r'procedure\s+\w+\.(?:OnNotify|\w*Timer\w*)\b.*?\nend;',
                           RESULTS + '\n' + PROCEED, re.I | re.S)
    for match in frequent:
        assert 'TGridLayoutManager.Apply' not in match.group(0)


def test_repeated_apply_does_not_rebuild_columns():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    guard = apply.index('if Signature = AState.FLastSignature')
    structural = apply.index('AState.FApplying := True', guard)
    unchanged = apply[guard:structural]
    assert 'Column.Parent :=' not in unchanged
    assert 'Column.Index :=' not in unchanged
    assert 'Column.Width := SavedWidth' in unchanged


def test_structural_mutations_are_conditional_and_width_snapshot_is_before_update():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    assert 'if Column.Parent <> AGrid then' in apply
    assert 'if Abs(Column.Width - SavedWidth) >= CWidthEpsilon then' in apply
    assert 'if Column.Index <> DesiredIndex then' in apply
    snapshot = apply.index('CaptureWidths(AState)')
    assert snapshot < apply.index('AGrid.BeginUpdate')
    assert 'not AState.FWidths.ContainsKey(Definition.Key)' in apply
    capture = method(HELPER, 'class procedure TGridLayoutManager.CaptureWidths',
                     'class function TGridLayoutManager.Apply')
    assert capture.count('AState.FWidths.AddOrSetValue') == 1
    assert 'AState.FWidths.AddOrSetValue(Definition.Key, Column.Width)' in apply


def test_apply_reentrancy_and_diagnostics_are_present():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    assert 'if AState.FApplying then' in apply
    assert 'AState.FApplying := True' in apply
    assert 'AState.FApplying := False' in apply
    for stage in ('before BeginUpdate', 'after Parent', 'after Index',
                  'after EndUpdate'):
        assert stage in apply
    assert 'GridWidthRestored' in apply
    assert 'AStructureContext' in apply
    assert 'FApplyCount' in apply
    assert 'AGrid.Model.InvalidateContentSize' not in apply


def test_structural_apply_restores_widths_only_after_end_update():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    structural = apply[apply.index('AState.FApplying := True'):]
    end_update = structural.index('AGrid.EndUpdate;')
    width_assignments = [
        match.start()
        for match in re.finditer(r'Column\.Width\s*:=', structural)
    ]
    assert width_assignments
    assert all(position > end_update for position in width_assignments)
    assert 'Definition.ExistingColumn = nil' in structural
    assert 'AState.FWidths.AddOrSetValue(Definition.Key, Column.Width)' in structural


def test_end_update_is_the_only_publication_point():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    after_end_update = apply[apply.index('AGrid.EndUpdate;') + len('AGrid.EndUpdate;'):]
    assert 'ContentChanged' not in after_end_update
    assert 'InvalidateContentSize' not in after_end_update
    assert 'after Model.ContentChanged' not in apply


def test_row_count_changes_are_centralized_in_layout_manager():
    row_count_assignment = re.compile(r'\b\w+\.RowCount\s*:=')
    application_sources = [
        path for path in ROOT.glob('*.pas')
        if path.name != 'uGridLayoutManager.pas'
    ]
    offenders = [
        path.name for path in application_sources
        if row_count_assignment.search(path.read_text(
            encoding='utf-8-sig', errors='ignore'))
    ]
    assert offenders == []


def test_set_row_count_preserves_widths_and_skips_empty_rebuild():
    set_rows = method(
        HELPER,
        'class procedure TGridLayoutManager.SetRowCount',
        'class function TGridLayoutManager.Apply',
    )
    empty_guard = set_rows.index(
        'if (AGrid.RowCount = 0) and (NewRowCount = 0)')
    begin_update = set_rows.index('AGrid.BeginUpdate')
    assert empty_guard < begin_update
    assert 'Widths[I] := Columns[I].Width' in set_rows
    assert begin_update < set_rows.index('AGrid.EndUpdate;')
    assert set_rows.index('AGrid.EndUpdate;') < set_rows.index(
        'Columns[I].Width := Widths[I]')
