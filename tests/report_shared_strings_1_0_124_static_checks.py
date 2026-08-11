from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def section(start, end):
    return REPORT.split(start, 1)[1].split(end, 1)[0]


def test_shared_strings_preserve_indexes_and_join_rich_text():
    body = section("function ParseSharedStrings", "// Возвращает фактический текст ячейки")
    assert "SameText(Root.LocalName, 'sst')" in body
    assert "SameText(Node.LocalName, 'si')" in body
    assert "AppendDescendantTextNodes(Node, Value)" in body
    assert "Values.Add(Value)" in body
    assert "xl/sharedStrings.xml" in body


def test_cell_text_dispatches_on_storage_type():
    body = section("function GetWorksheetCellText", "// Строит соответствие технического имени")
    assert "SameText(CellType, 's')" in body
    assert "ASharedStrings[SharedStringIndex]" in body
    assert "SameText(CellType, 'inlineStr')" in body
    assert "AppendDescendantTextNodes(InlineNode, Result)" in body
    assert "SameText(CellType, 'str')" in body
    for unsupported in ("'b'", "'e'", "'d'"):
        assert unsupported in body
    assert "SharedStringsCount=%d" in body


def test_header_index_uses_resolved_normalized_text_only():
    body = section("function BuildWorksheetHeaderIndex", "// Возвращает ссылку definedName")
    assert "GetWorksheetCellText(CellNode, ASharedStrings)" in body
    assert "NormalizedHeader := LowerCase(Trim(Header));" in body
    assert "Result.Add(NormalizedHeader, ColumnIndex)" in body
    assert "FindDirectChildNode(CellNode, 'v')" not in body
    assert "TStringComparer.OrdinalIgnoreCase" not in body


def test_shared_strings_are_loaded_once_for_repair_and_export_validation():
    repair = section("procedure RepairPreparedReportDefinedNames", "function MissingTechnicalSheetNames")
    export = section("procedure ExportTechnicalSheets", "// Добавляет сформированные")
    assert "ZipEntryExists(Zip, 'xl/sharedStrings.xml')" in repair
    assert "ParseSharedStrings" in repair
    assert "ValidateReportDefinedNameBindings(WorkbookXml, Sheets, SharedStrings)" in repair
    assert "TemplateSharedStrings := ParseSharedStrings" in export
    assert "GeneratedSharedStrings" in export


def test_repair_uses_schema_names_not_normalized_or_numeric_header_keys():
    repair = section("procedure RepairPreparedReportDefinedNames", "function MissingTechnicalSheetNames")
    assert "DevicePointColumns := BuildDevicePointsColumns" in repair
    assert "FieldName := DevicePointColumn.TechnicalName" in repair
    assert "for FieldName in Headers.Keys" not in repair
    assert "LowerCase(Trim(FieldName))" in repair


def test_version_is_1_0_124():
    assert "APP_VERSION = '1.0.124'" in VERSION
    assert PROJECT.count("FileVersion=1.0.124.0") == 2
    assert PROJECT.count("ProductVersion=1.0.124.0") == 2
