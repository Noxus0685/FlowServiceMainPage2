from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def section(start: str, end: str) -> str:
    return REPORT.split(start, 1)[1].split(end, 1)[0]


def test_release_and_single_technical_sheet_catalogue():
    assert "APP_VERSION = '1.0.129'" in VERSION
    assert PROJECT.count("ProductVersion=1.0.129.0") == 2
    catalogue = "('_Data', '_DevicePoints', '_Spillages', '_CoefTables', '_Meta')"
    assert REPORT.count(catalogue) == 1


def test_prepare_always_removes_then_adds_the_complete_structure():
    prepare = section(
        "class function TReportTemplateService.PrepareTemplate(",
        "class procedure TReportTemplateService.ExportTemplate(",
    )
    remove = "RemoveReportTechnicalSheets(ASourceFileName, CleanFileName)"
    add = "AddReportTechnicalSheets(CleanFileName, PreparedFileName, EmptyJson)"
    assert prepare.index(remove) < prepare.index(add)
    assert "часть технических листов" not in prepare


def test_obsolete_defined_name_repair_path_is_removed():
    for obsolete in (
        "RepairPreparedReportDefinedNames",
        "ReplaceReportDefinedNames",
        "IsManagedReportDefinedName",
        "PrepareNewTemplateFile",
    ):
        assert obsolete not in REPORT


def test_export_replaces_only_worksheet_entries():
    export = section(
        "procedure ExportTechnicalSheets(",
        "procedure AddUtf8ZipEntry(AZip: TZipFile; const AName, AText: string); forward;",
    )
    assert "ReplaceTechnicalSheetEntries(ASourceFileName" in export
    assert "CopyXlsxReplacingWorkbook" not in export
    assert "ReplaceReportDefinedNames" not in export
    assert "ValidatePreparedStaticDefinedNames" in export


def test_removal_is_reference_based_and_preserves_user_nodes():
    removal = section(
        "procedure RemoveReportTechnicalSheets(const ASourceFileName,",
        "// Добавляет сформированные именованные диапазоны",
    )
    assert "ReferenceUsesTechnicalSheet(Match.Value)" in removal
    assert "RemovedSheetIndexes.IndexOf(LocalSheetId)" in removal
    assert "localSheetId" in removal
    assert "AGeneratedNames" not in removal


def test_static_columns_ignore_actual_json_fields():
    separated = section(
        "function BuildSeparatedColumns(",
        "// Возвращает ширину столбца",
    )
    data = section("function BuildDataWorksheetXml(", "function BuildMetaWorksheetXml(")
    assert "GetReportStaticColumns" in separated
    assert "JsonRowsToColumns(ARows, [ObjectType], False)" not in data
    assert "Columns := SchemaColumns" in data

