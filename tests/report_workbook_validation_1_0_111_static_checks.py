from pathlib import Path

ROOT = Path(__file__).parents[1]
SRC = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def implementation(name, next_name):
    return SRC.split(name, 2)[-1].split(next_name, 1)[0]


def test_common_repair_precedes_parser_on_import_and_export():
    assert "APP_VERSION = '1.0.112'" in VERSION
    loader = implementation("function LoadAndValidateReportWorkbookXml", "function WorkbookTargetToArchivePath")
    assert loader.index("RepairLegacyReportWorkbookXml") < loader.index("ValidateWorkbookXmlText") < loader.index("ValidateWorkbookXml(Result")
    assert "LoadAndValidateReportWorkbookXml(WorkbookFile,\n      'чтение исходного шаблона при выгрузке'" in SRC
    assert "LoadAndValidateReportWorkbookXml(WorkbookFile,\n      'импорт подготовленного шаблона'" in SRC


def test_parse_diagnostics_use_real_position_and_context():
    validator = implementation("procedure ValidateWorkbookXml", "function LoadAndValidateReportWorkbookXml")
    for token in ("E.Line", "E.LinePos", "E.Reason", "E.SrcText", "E.URL", "GetXmlErrorContext"):
        assert token in validator
    context = implementation("function GetXmlErrorContext", "procedure ValidateWorkbookXml")
    assert "[[ERROR]]" in context
    assert "EnsureRange(ARadius, 100, 200)" in context


def test_structural_insert_and_defined_names_are_validated():
    assert "function InsertBeforeUniqueXmlNode" in SRC
    ensure = implementation("function EnsureAutomaticCalculation", "function WorkbookTemplateReloadHint")
    assert ".Replace('<extLst'" not in ensure
    names = implementation("procedure UpdateReportDefinedNames", "procedure ValidateSeparatedWorksheetXml")
    assert "ValidateDefinedNameValues" in names
    assert "ValidateWorkbookXmlText" in names and "ValidateWorkbookXml" in names
    assert ".Replace('<calcPr'" not in names


def test_point_error_migration_is_structural_not_one_name_probe():
    assert "TPointErrorMigrationState = (pemsNotRequired, pemsRequired, pemsPartial" in SRC
    state = implementation("function GetPointErrorMigrationState", "procedure RemoveLegacyReportTableArtifacts")
    for token in ("<t>PointError</t>", "<t>Q</t>", "MAX_DEVICE_POINTS", "ExpectedReference", "pemsPartial", "pemsInvalid"):
        assert token in state
    assert "not WorkbookXml.Contains('DevicePoints_01_PointError')" not in SRC


def test_repacked_xlsx_is_validated_before_atomic_replace():
    assert "procedure ValidateGeneratedReportXlsx" in SRC
    inject = implementation("procedure InjectDataSheet", "procedure InitializeReportTemplate")
    assert inject.index("ZipDirectory(TempDir, TempOutput)") < inject.index("ValidateGeneratedReportXlsx(TempOutput)") < inject.index("RenameFile(TempOutput, AOutputFileName)")
