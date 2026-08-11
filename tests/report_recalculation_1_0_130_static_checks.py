from pathlib import Path

ROOT = Path(__file__).parents[1]
REPORT = (ROOT / 'uReportTemplates.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')
PROJECT = (ROOT / 'ProjectFornTest.dproj').read_text(encoding='utf-8-sig')
UI = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')


def implementation(name, following):
    return REPORT.split(name, 2)[2].split(following, 1)[0]


def test_version_1_0_130():
    assert "APP_VERSION = '1.0.130'" in VERSION
    assert 'FileVersion=1.0.130.0' in PROJECT
    assert 'ProductVersion=1.0.130.0' in PROJECT


def test_calcpr_is_updated_with_dom_and_validated():
    body = implementation('function EnableFullWorkbookRecalculation',
                          '// Удаляет устаревшую цепочку')
    assert "Document.CreateNode('calcPr', ntElement" in body
    assert 'Root.DOMNode.insertBefore' in body
    assert 'Count > 1' in body
    for name, value in [('calcMode', 'auto'), ('fullCalcOnLoad', '1'),
                        ('forceFullCalc', '1'), ('calcOnSave', '1'),
                        ('calcId', '0')]:
        assert f"CalcPr.Attributes['{name}'] := '{value}'" in body
    assert 'ValidateWorkbookXml(Result' in body
    assert 'ValidateWorkbookCalculationSettings(Result)' in body


def test_calc_chain_is_removed_by_relationship_type():
    body = implementation('procedure RemoveWorkbookCalculationChain',
                          '// Возвращает пути ZIP-entry')
    assert 'CCalculationChainRelation' in body
    assert "Node.Attributes['Target']" in body
    assert 'ResolveWorkbookTargetArchivePath(Target)' in body
    assert 'RelsRoot.ChildNodes.Delete(I)' in body
    assert 'TypesRoot.ChildNodes.Delete(I)' in body
    assert "'xl/calcChain.xml'" in body


def test_single_export_path_replaces_only_allowed_parts():
    body = implementation('procedure ReplaceTechnicalSheetEntries',
                          'procedure ValidateGeneratedTechnicalSheets')
    for part in ('xl/workbook.xml', 'xl/_rels/workbook.xml.rels',
                 '[Content_Types].xml'):
        assert part in body
    assert 'RemoveWorkbookCalculationChain' in body
    assert 'EnableFullWorkbookRecalculation' in body
    assert 'ArchivePathListContains(RemovedEntries' in body
    export = REPORT.split('procedure ExportTechnicalSheets', 1)[1].split(
        '// Добавляет сформированные именованные диапазоны', 1)[0]
    assert export.count('ReplaceTechnicalSheetEntries(') == 1
    assert 'ValidateCalculationChainRemoved(TempOutput)' in export


def test_preparation_and_protocol_use_recalculation_contract():
    remove = implementation('procedure RemoveReportTechnicalSheets',
                            '// Добавляет сформированные именованные диапазоны')
    assert 'RemoveWorkbookCalculationChain' in remove
    assert 'EnableFullWorkbookRecalculation' in remove
    add = implementation('procedure AddReportTechnicalSheets',
                         'class function TReportTemplateService.TemplatesPath')
    assert 'EnableFullWorkbookRecalculation' in add
    prepare = REPORT.split('class function TReportTemplateService.PrepareTemplate', 1)[1]
    assert 'ValidateWorkbookCalculationSettings(WorkbookXml)' in prepare
    assert 'ValidateCalculationChainRemoved(PreparedFileName)' in prepare
    for item in ('CalcMode=auto', 'FullCalcOnLoad=True', 'ForceFullCalc=True',
                 'CalcOnSave=True', 'CalcId=0', 'CalcChainRemoved=True',
                 'Stage=EnableFullWorkbookRecalculation'):
        assert item in UI
    assert 'pcAction' in UI
