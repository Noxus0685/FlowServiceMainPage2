from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT = (ROOT / 'uReportTemplates.pas').read_text(encoding='utf-8-sig')
UI = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def body(source, start, end):
    return source.split(start, 1)[1].split(end, 1)[0]


def test_version_and_relationship_locations():
    assert "APP_VERSION = '1.0.115'" in VERSION
    assert 'TReportWorksheetLocation = record' in REPORT
    resolver = body(REPORT, 'function ResolveReportWorksheetLocation',
                    '// Проверяет структуру готового XLSX')
    assert 'FindSheetRelationId' in resolver
    assert "Attributes['Type']" in resolver
    assert 'ResolveWorkbookTargetArchivePath' in resolver


def test_safe_target_resolution():
    resolver = body(REPORT, 'function ResolveWorkbookTargetArchivePath',
                    'function WorkbookTargetToArchivePath')
    assert "Source := 'xl/' + Source" in resolver
    assert "if Part = '..'" in resolver
    assert 'Target выходит за корень XLSX' in resolver
    assert 'TPath.GetFullPath' not in resolver


def test_final_validation_reads_actual_zip_entries_without_extract():
    validation = body(REPORT, 'procedure ValidateGeneratedReportXlsx',
                      '// Добавляет или обновляет пять')
    assert 'CTechnicalFiles' not in validation
    assert 'flowServiceData.xml' not in validation
    assert 'ExtractAll' not in validation
    assert 'ResolveReportWorksheetLocation' in validation
    assert 'ReadZipEntryUtf8' in validation
    assert 'Location.ArchivePath' in validation
    assert "AnalyzePointErrorMigration(WorkbookXml, SheetXml)" in validation


def test_export_uses_unique_temporary_file_and_json_snapshot():
    assert 'function BuildTemporaryReportFileName' in REPORT
    assert "AOutputFileName + '.tmp'" not in REPORT
    assert 'class procedure TReportTemplateService.ExportTemplateFromJson' in REPORT
    assert 'TJSONObject.ParseJSONValue(AReportJson)' in REPORT


def test_ui_export_is_background_and_lifetime_guarded():
    click = body(UI, 'procedure TFrameProceed.ButtonExportReportTemplateClick',
                 'procedure TFrameProceed.MenuTreeViewDevicesClearClick')
    assert 'BuildReportJson(Device, DeviceType)' in click
    assert 'ReportJson := Json.ToJSON' in click
    assert 'TTask.Run' in click
    assert 'ExportTemplateFromJson' in click
    assert 'if FReportExportInProgress then Exit' in click
    assert 'TThread.Queue(FReportExportQueueThread' in click
    destroy = body(UI, 'destructor TFrameProceed.Destroy',
                   'procedure TFrameProceed.Initialize')
    assert 'TThread.RemoveQueuedEvents(FReportExportQueueThread)' in destroy
    assert 'FReportExportTask.Wait' in destroy


def test_ui_state_and_protocol_categories():
    assert "ButtonExportReportTemplate.Text := 'Выгрузка…'" in UI
    assert 'ButtonLoadReportTemplate.Enabled := False' in UI
    assert 'ListBoxReportTemplates.Enabled := False' in UI
    assert "ProtocolManager.AddMessage(pcAction" in UI
    assert "ProtocolManager.AddMessage(pcError" in UI
    assert 'ProtocolManager' not in body(REPORT, 'implementation', 'initialization')


def test_ready_analysis_diagnostic_overload():
    assert 'const AAnalysis: TPointErrorMigrationAnalysis): string; overload' in REPORT
    inject = body(REPORT, 'procedure InjectDataSheet',
                  'procedure InitializeReportTemplate')
    assert 'BuildPointErrorMigrationDiagnostic(PointErrorMigrationAnalysis)' in inject
