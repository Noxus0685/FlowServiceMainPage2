from pathlib import Path

ROOT = Path(__file__).parents[1]
SRC = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def section(start, end):
    return SRC.split(start, 1)[1].split(end, 1)[0]


def test_version_and_dom_migration_types():
    assert "APP_VERSION = '1.0.113'" in VERSION
    assert "TDevicePointsHeaderInfo = record" in SRC
    assert "TPointErrorDefinedNameInfo = record" in SRC


def test_header_parser_is_cell_scoped_dom_without_regex():
    body = section("function GetDevicePointsHeaderInfo", "function NormalizeDefinedNameReference")
    assert "FindDirectChildNode(Worksheet, 'sheetData')" in body
    assert "Attributes['r']), '2'" in body
    assert "GetWorksheetCellText(Cell)" in body
    assert "ExtractExcelColumnName" in body
    assert "SameText(HeaderText, 'Q')" in body
    assert "SameText(HeaderText, 'PointError')" in body
    assert "TRegEx" not in body and ".*?" not in body


def test_multiletter_excel_columns_and_case_insensitive_ordering():
    extract = section("function ExtractExcelColumnName", "function GetWorksheetCellText")
    assert "while (I <= Length(CleanReference))" in extract
    assert "Result := Result + UpCase" in extract
    columns = section("function BuildSeparatedColumns", "function ReportColumnWidth")
    assert "IndexOfColumnName(Result, 'PointError')" in columns
    assert "IndexOfColumnName(Result, 'Q')" in columns
    assert "в _DevicePoints отсутствует столбец Q" in columns


def test_defined_names_are_read_from_dom_and_actual_column():
    body = section("function GetPointErrorDefinedNameInfo", "function GetPointErrorMigrationState")
    assert "FindDirectChildNode(Root, 'definedNames')" in body
    assert "Child.Attributes['name']" in body
    assert "Child.Text" in body
    assert "APointErrorColumn" in body
    assert "TRegEx" not in body


def test_migration_state_has_exact_rules_and_diagnostics():
    body = section("function GetPointErrorMigrationState", "function PointErrorMigrationStateToString")
    assert "LoadXMLData(AWorkbookXml)" in body
    assert "LoadXMLData(ADevicePointsXml)" in body
    assert "Header.PointErrorIndex = Header.QIndex + 1" in body
    assert "Names.CorrectCount = Names.ExpectedCount" in body
    assert "TRegEx" not in body
    assert "BuildPointErrorMigrationDiagnostic" in SRC
    assert "expected=%s actual=%s" in SRC


def test_post_migration_error_reports_state_and_structure():
    assert "PointErrorMigrationState := GetPointErrorMigrationState(WorkbookXml" in SRC
    assert "PointErrorMigrationStateToString(PointErrorMigrationState)" in SRC
    assert "BuildPointErrorMigrationDiagnostic(WorkbookXml, SheetXml[1])" in SRC
