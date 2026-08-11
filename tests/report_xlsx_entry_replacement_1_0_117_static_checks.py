from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
REPORT = (ROOT / 'uReportTemplates.pas').read_text(encoding='utf-8-sig')
UI = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

def section(start, end):
    return REPORT.split(start, 1)[1].split(end, 1)[0]

def test_version_and_simple_import():
    assert "APP_VERSION = '1.0.117'" in VERSION
    body = section('class function TReportTemplateService.ImportTemplate',
                   'class procedure TReportTemplateService.ExportTemplate')
    assert 'TFile.Copy(ASourceFileName, Result, False)' in body
    for forbidden in ('TZipFile', 'workbook.xml', 'InjectDataSheet'):
        assert forbidden not in body

def test_only_entries_are_replaced():
    for required in ('ResolveTechnicalSheetEntries', 'ReplaceTechnicalSheetEntries',
                     'ReplaceReportOutputFile'):
        assert required in REPORT
    for forbidden in ('ExtractAll', 'ZipDirectory', 'InjectDataSheet',
                      'AnalyzePointErrorMigration', 'UpdateReportDefinedNames',
                      'IsPreparedReportTemplate', 'GReportLogLock'):
        assert forbidden not in REPORT
    replace = section('procedure ReplaceTechnicalSheetEntries',
                      'procedure ValidateTechnicalSheetOutput')
    assert 'for Name in SourceZip.FileNames' in replace
    assert 'OutputZip.Add(Stream, Name)' in replace

def test_workbook_parts_are_read_only_and_missing_sheet_is_explicit():
    export = section('procedure ExportTechnicalSheets',
                     'class function TReportTemplateService.TemplatesPath')
    assert "ReadZipEntryUtf8(Zip, 'xl/workbook.xml')" in export
    assert "ReadZipEntryUtf8(Zip, 'xl/_rels/workbook.xml.rels')" in export
    assert 'Write' not in export
    assert 'Шаблон не содержит обязательный технический лист' in REPORT

def test_safe_output_and_async_snapshot():
    replace = section('procedure ReplaceReportOutputFile',
                      'procedure ExportTechnicalSheets')
    assert "TFile.Replace(ATemporaryFileName, AOutputFileName, BackupFileName)" in replace
    assert "TFile.Replace(ATemporaryFileName, AOutputFileName, '')" not in replace
    worker = UI.split('TTask.Run', 1)[1]
    assert 'ExportTemplateFromJson' in worker
    assert 'ProtocolManager' not in worker.split('procedure TFrameProceed.MenuTreeViewDevicesClearClick', 1)[0]
