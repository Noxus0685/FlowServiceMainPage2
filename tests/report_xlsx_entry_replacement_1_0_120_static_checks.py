from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
REPORT = (ROOT / 'uReportTemplates.pas').read_text(encoding='utf-8-sig')
UI = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

def section(start, end):
    return REPORT.split(start, 1)[1].split(end, 1)[0]

def test_version_and_template_preparation():
    assert "APP_VERSION = '1.0.120'" in VERSION
    body = section('class function TReportTemplateService.PrepareTemplate',
                   'class procedure TReportTemplateService.ExportTemplate')
    assert 'MissingTechnicalSheetNames(WorkbookXml)' in body
    assert 'PrepareNewTemplateFile(ASourceFileName, TemporaryFileName, EmptyJson)' in body
    assert 'TFile.Copy(ASourceFileName, Result, False)' in body
    prepare = section('procedure PrepareNewTemplateFile',
                      'class function TReportTemplateService.TemplatesPath')
    assert 'CReportTechnicalSheetNames[I]' in prepare
    assert 'SetLength(SheetXml, 5)' in prepare
    assert 'RegisterPreparedSeparatedNames(Rows, Names)' in prepare
    assert 'TDevice.Create' not in body
    assert 'AddWorksheetRelationship' in prepare
    assert 'AddPreparedDefinedNames' in prepare
    assert "InsertBeforeUniqueXmlNode(ContentTypesXml, '</Types>'" in prepare

def test_only_entries_are_replaced():
    for required in ('ResolveTechnicalSheetEntries', 'ReplaceTechnicalSheetEntries',
                     'ReplaceReportOutputFile'):
        assert required in REPORT
    for forbidden in ('ExtractAll', 'ZipDirectory', 'InjectDataSheet',
                      'AnalyzePointErrorMigration', 'UpdateReportDefinedNames',
                      'IsPreparedReportTemplate', 'GReportLogLock'):
        assert forbidden not in REPORT
    replace = section('procedure ReplaceTechnicalSheetEntries',
                      'procedure ValidateGeneratedTechnicalSheets')
    assert 'for EntryName in InputArchive.FileNames' in replace
    assert 'ResultArchive.Add(EntryStream, EntryName)' in replace

def test_workbook_parts_are_read_only_and_missing_sheet_is_explicit():
    export = section('procedure ExportTechnicalSheets',
                     '// Добавляет сформированные именованные диапазоны')
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


def test_empty_template_schema_is_stable_and_has_no_migration():
    for required in ('AddNullScalarMembersForClass', 'EnsureTechnicalSheetSchema',
                     'BuildDevicePointsColumns', 'MergeReportColumns'):
        assert required in REPORT
    device_columns = section('function BuildDevicePointsColumns',
                             '// Возвращает устойчивый набор столбцов')
    assert "TechnicalName := 'Q'" in device_columns
    assert "TechnicalName := 'PointError'" in device_columns
    assert 'List.Insert(QIndex + 1, PointErrorColumn)' in device_columns
    for forbidden in ('TDevicePointsHeaderInfo', 'GetDevicePointsHeaderInfo',
                      'ExtractExcelColumnName', 'ExcelColumnIndex',
                      'GetWorksheetCellText', 'Нельзя добавить PointError'):
        assert forbidden not in REPORT
    separated = section('function BuildSeparatedWorksheetXml',
                        '// Формирует вертикальный XML')
    assert 'if IsSchemaRow(Row)' in separated

def test_template_preparation_has_concise_duration_protocol():
    load = UI.split('procedure TFrameProceed.ButtonLoadReportTemplateClick', 1)[1].split(
        'procedure TFrameProceed.BeginReportExportUi', 1)[0]
    assert 'TStopwatch.StartNew' in load
    assert 'pcAction' in load and 'DurationMs=%d' in load
    assert 'pcError' in load and 'Stage=%s' in load


def test_zip_validation_routine_is_closed_before_next_function():
    validation = section('procedure ValidateZipEntries',
                         '// Проверяет наличие ZIP entry')
    assert validation.rstrip().endswith('end;')


def test_entry_replacement_and_validation_are_top_level_routines():
    replacement = section('procedure ReplaceTechnicalSheetEntries',
                          'procedure ValidateGeneratedTechnicalSheets')
    for declaration in ('InputArchive: TZipFile',
                        'ResultArchive: TZipFile'):
        assert declaration in replacement
    assert replacement.rstrip().endswith('end;')
    assert REPORT.count('procedure ValidateGeneratedTechnicalSheets') == 1
    validation = section('procedure ValidateGeneratedTechnicalSheets',
                         '// Атомарно сохраняет сформированный XLSX')
    assert validation.rstrip().endswith('end;')
