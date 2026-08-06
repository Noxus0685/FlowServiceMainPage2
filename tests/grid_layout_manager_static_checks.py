import re
from pathlib import Path

ROOT = Path(__file__).parents[1]
HELPER = (ROOT / 'uGridLayoutManager.pas').read_text(encoding='utf-8-sig')
RESULTS = (ROOT / 'frmMRResults.pas').read_text(encoding='utf-8-sig')
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')


def method(text, signature, next_signature):
    start = text.index(signature)
    return text[start:text.index(next_signature, start + len(signature))]


def test_equal_signature_is_a_strict_no_op_before_fmx_mutation():
    apply = method(HELPER, 'class function TGridLayoutManager.Apply', 'end.\n')
    guard = apply.index('if Signature = AState.FLastSignature')
    for mutation in ('AGrid.BeginUpdate', '.Parent :=', '.Index :=', '.Width :=',
                     'AGrid.Model.BeginUpdate'):
        assert guard < apply.index(mutation)
    assert 'Exit(False)' in apply[guard:apply.index('AGrid.BeginUpdate')]


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
