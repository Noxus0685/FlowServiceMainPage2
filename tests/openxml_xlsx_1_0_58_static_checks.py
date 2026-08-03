from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
XLSX = (ROOT / "uOpenXmlXlsx.pas").read_text(encoding="utf-8-sig")
EXPORTER = (ROOT / "uResultsXlsxExporter.pas").read_text(encoding="utf-8-sig")
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmMRResults.fmx").read_text(encoding="utf-8-sig")


def column_name(number: int) -> str:
    result = ""
    while number:
        number -= 1
        result = chr(ord("A") + number % 26) + result
        number //= 26
    return result


def test_excel_column_examples_and_cell_address_algorithm():
    assert [column_name(x) for x in (1, 26, 27, 52, 53)] == ["A", "Z", "AA", "AZ", "BA"]
    assert "ExcelColumnName(Cell.Column)" in XLSX


def test_xml_and_shared_string_contract():
    for entity in ("&amp;", "&lt;", "&gt;", "&quot;", "&apos;"):
        assert entity in XLSX
    assert "FIndex.TryGetValue(AValue, Result)" in XLSX
    assert "xml:space=\"preserve\"" in XLSX
    assert "TEncoding.UTF8.GetBytes" in XLSX


def test_package_parts_relationships_and_invariant_values():
    for part in ("[Content_Types].xml", "_rels/.rels", "docProps/app.xml",
                 "docProps/core.xml", "xl/workbook.xml", "xl/_rels/workbook.xml.rels",
                 "xl/styles.xml", "xl/sharedStrings.xml", "xl/worksheets/sheet%d.xml"):
        assert part in XLSX
    assert "FS.DecimalSeparator:='.'" in XLSX
    assert "t=\"b\"" in XLSX
    assert "EncodeDate(1900, 3, 1)" in XLSX


def test_export_layout_and_ui_wiring():
    for sheet in ("Сессия", "Приборы", "Результаты"):
        assert f"AddWorksheet('{sheet}')" in EXPORTER
    assert "object ButtonExportExcel: TButton" in FMX
    assert "Выгрузить" not in FMX  # FMX stores Cyrillic as character codes.
    assert "object SaveDialogXlsx: TSaveDialog" in FMX
    assert "Excel Workbook (*.xlsx)|*.xlsx" in FMX
    assert "ResultsXlsxExportRequested" in RESULTS
    assert "ResultsXlsxExportCompleted" in RESULTS
    assert "ResultsXlsxExportFailed" in RESULTS


def test_portable_package_unit_has_no_platform_api_or_external_writer():
    lowered = XLSX.lower()
    for forbidden in ("winapi", "comobj", "activex", "flexcel", "fastreport", "libxlsxwriter"):
        assert forbidden not in lowered
