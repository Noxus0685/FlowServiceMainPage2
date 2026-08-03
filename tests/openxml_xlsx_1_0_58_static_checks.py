from pathlib import Path
import re


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
    assert "function Utf8XmlBytes(const AXml: string): TBytes" in XLSX
    assert "TEncoding.UTF8.GetBytes(AXml)" in XLSX
    assert "TBytesStream.Create(Bytes)" in XLSX
    assert "TStringStream" not in XLSX
    for forbidden in ("AnsiString", "UTF8String", "RawByteString", "PAnsiChar"):
        assert forbidden not in XLSX


def test_every_xml_part_uses_the_common_utf8_writer():
    for part in ("[Content_Types].xml", "_rels/.rels", "docProps/app.xml",
                 "docProps/core.xml", "xl/workbook.xml", "xl/_rels/workbook.xml.rels",
                 "xl/styles.xml", "xl/sharedStrings.xml", "xl/worksheets/sheet%d.xml"):
        assert f"AddUtf8XmlEntry(Z,'{part}'" in XLSX or f"AddUtf8XmlEntry(Z,Format('{part}'" in XLSX
    assert XLSX.count('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>') == 1


def test_cyrillic_source_literals_are_compiled_as_unicode():
    expected = {
        "SWorksheetSession": "Сессия", "SWorksheetDevices": "Приборы",
        "SWorksheetResults": "Результаты", "SHeaderSessionID": "ID сессии",
        "SHeaderDateTime": "Дата и время", "SHeaderWorkTable": "Рабочий стол",
        "SHeaderMode": "Режим измерения", "SHeaderStatus": "Статус",
        "SHeaderName": "Название", "SHeaderSerial": "Серийный номер",
        "SHeaderUuid": "UUID", "SHeaderChannel": "Канал",
        "SHeaderDeviceType": "Тип прибора", "SHeaderActiveSessionID": "ID активной сессии",
        "SHeaderNumber": "№", "SHeaderDevice": "Прибор",
        "SHeaderDeviceUuid": "UUID прибора", "SHeaderPointName": "Название точки",
        "SHeaderReferenceFlow": "Расход эталона", "SHeaderEtalon": "Эталон",
        "SHeaderEtalonUuid": "UUID эталона", "SHeaderDeviceValue": "Значение прибора",
        "SHeaderError": "Погрешность", "SHeaderValidity": "Валидность",
    }
    for name, value in expected.items():
        encoded = re.search(rf"^\s*{name}\s*=\s*((?:#\$[0-9A-F]{{4}})+);", EXPORTER, re.MULTILINE)
        assert encoded, name
        actual = "".join(chr(int(code, 16)) for code in re.findall(r"#\$([0-9A-F]{4})", encoded.group(1)))
        assert actual == value
    assert not re.search(r"[\u0400-\u04ff]", EXPORTER)
    assert "ValidateExportLabels;" in EXPORTER
    assert "raise EEncodingError.CreateFmt" in EXPORTER


def test_package_parts_relationships_and_invariant_values():
    for part in ("[Content_Types].xml", "_rels/.rels", "docProps/app.xml",
                 "docProps/core.xml", "xl/workbook.xml", "xl/_rels/workbook.xml.rels",
                 "xl/styles.xml", "xl/sharedStrings.xml", "xl/worksheets/sheet%d.xml"):
        assert part in XLSX
    assert "FS.DecimalSeparator:='.'" in XLSX
    assert "t=\"b\"" in XLSX
    assert "EncodeDate(1900, 3, 1)" in XLSX


def test_export_layout_and_ui_wiring():
    for sheet in ("SWorksheetSession", "SWorksheetDevices", "SWorksheetResults"):
        assert f"AddWorksheet({sheet})" in EXPORTER
    assert "object ButtonExportExcel: TButton" in FMX
    assert "Выгрузить" not in FMX  # FMX stores Cyrillic as character codes.
    assert "TSaveDialog" not in FMX
    assert "Dialog := TSaveDialog.Create(Self)" in RESULTS
    assert "Excel Workbook (*.xlsx)|*.xlsx" in RESULTS
    assert "ResultsXlsxExportRequested" in RESULTS
    assert "ResultsXlsxExportCompleted" in RESULTS
    assert "ResultsXlsxExportFailed" in RESULTS


def test_portable_package_unit_has_no_platform_api_or_external_writer():
    lowered = XLSX.lower()
    for forbidden in ("winapi", "comobj", "activex", "flexcel", "fastreport", "libxlsxwriter"):
        assert forbidden not in lowered
