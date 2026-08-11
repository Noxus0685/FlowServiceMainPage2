from pathlib import Path

ROOT = Path(__file__).parents[1]
REPORT = (ROOT / 'uReportTemplates.pas').read_text(encoding='utf-8-sig')
UI = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')
PROJECT = (ROOT / 'ProjectFornTest.dproj').read_text(encoding='utf-8-sig')


def impl(name, following):
    return REPORT.split(name, 2)[2].split(following, 1)[0]


def test_version_and_result_contracts():
    assert "APP_VERSION = '1.0.131'" in VERSION
    assert PROJECT.count('1.0.131.0') >= 4
    for name in ('TReportCalculationState', 'TReportExportResult',
                 'ReadReportCalculationState', 'ValidateFinalReportFile',
                 'ReplaceAndValidateReportOutputFile'):
        assert name in REPORT


def test_state_is_read_from_named_xlsx_not_expected_strings():
    body = impl('function ReadReportCalculationState',
                '// Проверяет окончательно сохранённый XLSX')
    assert 'Archive.Open(AXlsxFileName, zmRead)' in body
    for part in ('xl/workbook.xml', 'xl/_rels/workbook.xml.rels',
                 '[Content_Types].xml', 'xl/calcChain.xml'):
        assert part in body
    assert "Node.Attributes['calcId']" in body
    assert 'CCalculationChainRelation' in body
    assert 'CCalculationChainContentType' in body


def test_final_file_validation_and_hash_are_fact_based():
    body = impl('function ValidateFinalReportFile',
                '// Атомарно заменяет отчёт')
    for call in ('ValidateWorkbookXml', 'ValidateGeneratedTechnicalSheets',
                 'ValidateGeneratedDefinedNames', 'ValidateDefinedNameDuplicates',
                 'ValidateReportDefinedNameBindings',
                 'ValidateWorkbookCalculationSettings',
                 'ValidateCalculationChainRemoved', 'ReadReportCalculationState'):
        assert call in body
    assert 'THashSHA2.GetHashStringFromFile(AXlsxFileName)' in body
    assert 'TFile.GetLastWriteTimeUtc(AXlsxFileName)' in body
    assert 'TFile.GetSize(AXlsxFileName)' in body


def test_atomic_replace_validates_destination_before_deleting_backup():
    body = impl('function ReplaceAndValidateReportOutputFile',
                '// Атомарно сохраняет сформированный XLSX')
    assert body.index('ValidateFinalReportFile(ATemporaryFileName)') < body.index('TFile.Replace')
    assert body.index('TFile.Replace') < body.index('ValidateFinalReportFile(OutputFullPath)')
    assert body.index('ValidateFinalReportFile(OutputFullPath)') < body.rindex('TFile.Delete(BackupFileName)')
    assert 'TFile.Move(BackupFileName, OutputFullPath)' in body
    assert 'Stage=FinalOutputValidation' in body


def test_export_returns_verified_result_and_rejects_bad_template():
    body = REPORT.split('function ExportTechnicalSheets', 1)[1].split(
        'function ReferenceUsesTechnicalSheet', 1)[0]
    assert 'ValidateFinalReportFile(ASourceFileName)' in body
    assert 'Stage=ValidatePreparedTemplate' in body
    assert 'Result := ReplaceAndValidateReportOutputFile(TempOutput, AOutputFileName)' in body
    assert 'class function TReportTemplateService.ExportTemplate(' in REPORT
    assert 'class function TReportTemplateService.ExportTemplateFromJson(' in REPORT


def test_protocol_uses_result_and_rechecks_hash():
    complete = UI.split('procedure TFrameProceed.CompleteReportExport', 1)[1].split(
        'procedure TFrameProceed.FailReportExport', 1)[0]
    assert 'const AResult: TReportExportResult' in complete
    for field in ('FileHashSHA256', 'LastWriteTimeUtc', 'CalcPrCount', 'CalcMode',
                  'CalcChainEntryExists', 'CalcChainRelationshipExists',
                  'CalcChainOverrideExists'):
        assert 'AResult.' in complete and field in complete
    assert 'CalcMode=auto' not in UI
    assert 'CalcChainRemoved=True' not in UI
    assert 'THashSHA2.GetHashStringFromFile(ExportResult.OutputFileName)' in UI
    assert 'Итоговый XLSX был изменён после проверки.' in UI
    assert 'Проверен не тот итоговый файл отчёта.' in UI
