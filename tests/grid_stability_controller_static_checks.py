import re
from pathlib import Path

ROOT = Path(__file__).parents[1]
CONTROLLER = (ROOT / 'uGridStabilityController.pas').read_text(encoding='utf-8-sig')
DOC = (ROOT / 'docs/grid-stability-audit.md').read_text(encoding='utf-8')


def test_controller_is_observer_only_and_captures_required_state():
    snapshot = CONTROLLER[CONTROLLER.index('procedure TGridStabilityController.Snapshot'):]
    for field in ('Name:', 'Index:', 'Width:', 'Visible:', 'FGridWidth:',
                  'FViewportWidth:', 'ViewportSize.Width'):
        assert field in CONTROLLER
    for forbidden in ('Column.Width :=', 'Column.Index :=', 'Column.Parent :=', 'BeginUpdate',
                      'EndUpdate', 'ContentChanged', 'Repaint'):
        assert forbidden not in snapshot
    for diagnostic in ('Form="%s"', 'Grid="%s"', 'Column="%s"',
                       'Width=%.4f->%.4f', 'Index=%d->%d', 'Context="%s"',
                       'UIThread=%d'):
        assert diagnostic in CONTROLLER


def test_every_repo_owned_root_grid_is_registered_or_documented_exclusion():
    declarations = []
    for path in ROOT.glob('*.fmx'):
        if path.name == 'FormMeterValue.fmx':
            continue
        text = path.read_text(encoding='utf-8-sig', errors='replace')
        declarations += [(path.stem, name) for name in
                         re.findall(r'object\s+(\w+):\s+T(?:String)?Grid\b', text)]
    pas = '\n'.join(p.read_text(encoding='utf-8-sig', errors='replace') for p in ROOT.glob('*.pas'))
    for owner, grid in declarations:
        registered = re.search(rf'RegisterStableGrid\([^;]*\b{re.escape(grid)}\b', pas)
        excluded = f'`{owner}`' in DOC and f'`{grid}`' in DOC and 'documented exclusion' in DOC
        assert registered or excluded, f'{owner}.{grid} has no stability policy'


def test_device_edit_has_all_diagnostic_boundaries():
    text = (ROOT / 'fuDeviceEdit.pas').read_text(encoding='utf-8-sig')
    for context in ('after-fmx-load', 'after-show', 'before-UpdatePointsGrid',
                    'after-EndUpdate', 'after-UpdatePointsGrid',
                    'after-deferred-layout'):
        assert f"Snapshot('{context}')" in text


def test_structural_manager_only_targets_dynamic_grids():
    calls = []
    for path in ROOT.glob('*.pas'):
        if path.name == 'uGridLayoutManager.pas':
            continue
        text = path.read_text(encoding='utf-8-sig', errors='replace')
        for match in re.finditer(r'TGridLayoutManager\.Apply\((\w+)', text):
            calls.append((path.name, match.group(1)))
    assert sorted(calls) == [('frmMRResults.pas', 'GridMRResults'),
                             ('frmProceed.pas', 'GridResults')]


def test_frequent_paths_never_apply_structural_or_persisted_layout():
    forbidden = ('TGridLayoutManager.Apply', 'ApplyGridColumnsLayout')
    frequent_names = r'(?:OnNotify|\w*Timer\w*|UpdatePointsGrid|RefreshRows|RefreshGridColumns)'
    for path in ROOT.glob('*.pas'):
        text = path.read_text(encoding='utf-8-sig', errors='replace')
        for match in re.finditer(rf'procedure\s+\w+\.{frequent_names}\b.*?\nend;', text, re.I | re.S):
            for token in forbidden:
                assert token not in match.group(0), f'{token} in {path.name} frequent path'


def test_persisted_layout_writes_are_change_guarded():
    for name in ('frmMainTable.pas', 'frmProceed.pas'):
        text = (ROOT / name).read_text(encoding='utf-8-sig')
        start = text.index('procedure T' + ('FrameMainTable' if name.startswith('frmMain') else 'FrameProceed') + '.ApplyGridColumnsLayout')
        body = text[start:text.index('\nend;', start)]
        assert 'if Column.Visible <>' in body
        assert 'Abs(Column.Width -' in body
        assert 'Column.Index <>' in body
