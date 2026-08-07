from pathlib import Path

ROOT = Path(__file__).parents[1]
HELPER = (ROOT / 'uGridLayoutManager.pas').read_text(encoding='utf-8-sig')
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
RESULTS = (ROOT / 'frmMRResults.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def test_release_version():
    assert "APP_VERSION = '1.0.83'" in VERSION


def test_manual_only_width_state_and_recursion_protection():
    for token in (
        'FApprovedWidths',
        'FManualResizeActive',
        'FRestoringWidth',
        'FApplyingInitialWidths',
        'FTrackedColumn',
        'ColumnResizeHandler',
        'RestoreApprovedColumnWidth',
    ):
        assert token in HELPER
    assert 'if FRestoringWidth or FApplyingInitialWidths then' in HELPER


def test_only_confirmed_mouseup_persists_approved_width():
    end_resize = HELPER[HELPER.index(
        'function TGridLayoutState.EndManualColumnResize: Boolean'):]
    save = end_resize.index('SaveApprovedWidth(ColumnKey, ApprovedWidth)')
    reset = end_resize.index('FManualResizeActive := False')
    assert save < reset
    assert 'SaveApprovedWidth' not in HELPER[
        HELPER.index('procedure TGridLayoutState.ColumnResizeHandler'):
        HELPER.index('procedure TGridLayoutState.BeginManualColumnResize')
    ]


def test_unauthorized_resize_restores_approved_width():
    handler = HELPER[
        HELPER.index('procedure TGridLayoutState.ColumnResizeHandler'):
        HELPER.index('procedure TGridLayoutState.BeginManualColumnResize')
    ]
    assert 'FManualResizeActive and (Column = FTrackedColumn)' in handler
    assert "RestoreApprovedColumnWidth(Column, ColumnKey, 'OnResize')" in handler


def test_dynamic_result_grids_use_shared_width_and_manual_boundaries():
    assert 'TStringColumn, C_DYNAMIC_COLUMN_WIDTH, True, True' in PROCEED
    assert 'TStringColumn, C_DYNAMIC_COLUMN_WIDTH, True, True' in RESULTS
    assert 'BeginManualColumnResize(GridResults, X, Y)' in PROCEED
    assert 'BeginManualColumnResize(GridMRResults, X, Y)' in RESULTS
    assert 'EndManualColumnResize' in PROCEED
    assert 'EndManualColumnResize' in RESULTS
