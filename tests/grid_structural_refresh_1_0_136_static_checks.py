from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
FMX = (ROOT / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
HELPER = (ROOT / 'FmxHelper.pas').read_text(encoding='cp1251')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def section(start, end):
    a = PROCEED.index(start)
    return PROCEED[a:PROCEED.index(end, a)]


def test_value_refresh_is_repaint_only():
    body = HELPER[HELPER.index('procedure RefreshGridValues', HELPER.index('implementation')):
                  HELPER.index('var\n  LogCriticalSection')]
    assert 'AGrid.Repaint' in body
    for forbidden in ('AGrid.Model.ContentChanged', 'InvalidateContentSize', '.RowCount :=',
                      '.Width', '.Index', '.Visible', '.Header'):
        assert forbidden not in body


def test_frequent_result_updates_are_content_only():
    results = section('procedure TFrameProceed.UpdateGridResults;',
                      'procedure TFrameProceed.UpdateGridDataPoints;')
    points = section('procedure TFrameProceed.UpdateGridDataPoints;',
                     'function TFrameProceed.BuildCurrentSpillagesList')
    for body in (results, points):
        assert 'RefreshGridRowCount' in body
        assert 'RefreshGridValues' in body
        for forbidden in ('ApplyGridColumnsLayout', '.Options :=', '.RowHeight :=',
                          '.StyleLookup :=', '.Width :='):
            assert forbidden not in body


def test_dynamic_columns_are_signature_gated_and_unlimited():
    update = section('procedure TFrameProceed.UpdateResultsPointColumns;',
                     'function TFrameProceed.FindResultSpillageForPoint')
    assert 'NewSignature = FResultsPointColumnSignature' in update
    assert 'TStringColumn.Create(GridResults)' in update
    assert '.Width :=' not in update
    assert 'ProcessingResultPointColumnLimitExceeded' not in PROCEED
    assert 'C_RESULTS_POINT_COLUMN_COUNT' not in PROCEED
    assert not re.search(r'StringColumnPointNum(?:[1-9]|1[0-9]|20)', PROCEED + FMX)


def test_no_double_results_refresh():
    show_all = section('procedure TFrameProceed.ShowAllDevicesResults;',
                       'procedure TFrameProceed.ShowDevicesResults(')
    assert 'ShowDevicesResults(Devices)' in show_all
    assert 'UpdateGridResults' not in show_all


def test_version():
    assert "APP_VERSION = '1.0.136'" in VERSION
