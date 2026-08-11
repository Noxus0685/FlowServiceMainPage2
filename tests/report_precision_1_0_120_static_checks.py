from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT = (ROOT / 'uReportTemplates.pas').read_text(encoding='utf-8-sig')
UI = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def implementation(start, end):
    return REPORT.rsplit(start, 1)[1].split(end, 1)[0]


def test_version_and_shared_precision_policy():
    assert "APP_VERSION = '1.0.120'" in VERSION
    rounding = implementation('function RoundReportValueByMeterPrecision',
                              'function ReportErrorDecimals')
    assert 'AMeterValue.GetStrNum(AValue)' in rounding
    assert 'TryStrToFloat' in rounding
    assert 'FormatFloat' not in rounding
    assert '0.000' not in rounding


def test_snapshot_contains_raw_rounded_text_and_precision_metadata():
    snapshot = implementation('procedure ApplyReportErrorPrecision',
                              'procedure NormalizeReportRowUnits')
    for name in ('ErrorRaw', 'Error', 'ErrorText', 'ErrorDecimals'):
        assert repr(name) in snapshot
    assert "SourceField := 'PointError'" in snapshot
    assert 'ReplaceJsonNumber(Row, SourceField, RoundedValue)' in snapshot
    assert 'ReplaceJsonNumber(Row, \'ErrorRaw\', RawValue)' in snapshot


def test_point_error_named_range_receives_rounded_number():
    build = implementation('class function TReportTemplateService.BuildReportJson',
                           'class function TReportTemplateService.PrepareTemplate')
    assert 'TryGetDevicePointDisplayError' in build
    assert 'ApplyReportErrorPrecision(Rows, AMeterValueError)' in build
    sheet = implementation('function BuildSeparatedWorksheetXml',
                           'function BuildDataWorksheetXml')
    assert 'Value is TJSONNumber' in sheet
    assert '<v>%s</v>' in sheet


def test_live_objects_stay_on_ui_thread_and_worker_gets_json_only():
    click = UI.split('procedure TFrameProceed.ButtonExportReportTemplateClick', 1)[1].split(
        'procedure TFrameProceed.MenuTreeViewDevicesClearClick', 1)[0]
    assert 'MeterValueError := FSessionDevice.ValueError' in click
    assert 'BuildReportJson(Device, DeviceType' in click
    assert click.index('BuildReportJson(Device, DeviceType') < click.index('TTask.Run')
    worker = click.split('TTask.Run', 1)[1]
    assert 'ExportTemplateFromJson' in worker
    assert 'BuildReportJson' not in worker
    assert 'FSessionDevice.ValueError' not in worker


def test_invalid_numeric_values_do_not_reach_xlsx():
    snapshot = implementation('procedure ApplyReportErrorPrecision',
                              'procedure NormalizeReportRowUnits')
    assert 'not IsValidReportNumericValue(RawValue)' in snapshot
    assert 'TJSONNull.Create' in snapshot
