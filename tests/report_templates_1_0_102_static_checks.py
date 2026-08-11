from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_version_and_capacities():
    assert "APP_VERSION = '1.0.102'" in VERSION
    assert "MAX_DEVICE_POINTS = 7" in SERVICE
    assert "MAX_POINT_SPILLAGES = 10" in SERVICE
    assert "MAX_COEF_ITEMS = 20" in SERVICE
    assert "CCoefTableTypes: array[0..4] of Integer = (10, 11, 12, 13, 14)" in SERVICE


def test_single_table_implementation_is_removed():
    for forbidden in (
        "DATA_TABLE_NAME", "tblReportData", "BuildTableXml",
        "ResolveReportTableId", "ValidateReportTableXml", "CTableRelation",
        "CTableContentType", "flowServiceReportData.xml", "<tableParts",
        "<tablePart", "<autoFilter",
    ):
        assert forbidden not in SERVICE


def test_removed_single_table_helpers_have_no_stale_references():
    """Guard the Delphi unit against E2003 errors from partially removed code."""
    for removed_identifier in (
        "CollectTypeColumns",
        "ColumnRank",
        "BuildReportTableRange",
        "ATableId",
        "TableRange",
    ):
        assert removed_identifier not in SERVICE


def test_separated_sheet_cells_do_not_depend_on_stale_locals():
    builder = SERVICE.split("function BuildSeparatedWorksheetXml", 1)[1].split(
        "function BuildMetaWorksheetXml", 1
    )[0]
    assert "CellRef" not in builder
    assert "TextValue" not in builder
    assert "ExcelColumnName(I + 1) + OutputRow.ToString" in builder
    assert '<v>1</v>' in builder
    assert '<v>0</v>' in builder


def test_five_visible_service_sheets_are_defined():
    for name in ("_Data", "_DevicePoints", "_Spillages", "_CoefTables", "_Meta"):
        assert name in SERVICE
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    assert 'state="hidden"' not in inject
    assert "FindSheetRelationId(WorkbookXml, CSheetNames[I])" in inject
    assert "for I := Low(CSheetNames) to High(CSheetNames) do" in inject


def test_json_rows_are_distributed_by_object_type():
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    assert "['DeviceType', 'Device']" in inject
    assert "['DevicePoint']" in inject
    assert "['Spillage']" in inject
    assert "['CalibrCoefTable', 'CalibrCoefItem']" in inject
    assert "BuildMetaWorksheetXml(ARoot)" in inject
    assert "BuildSeparatedColumns" in SERVICE
    assert "ReportColumnWidth" in SERVICE


def test_service_sheets_are_replaced_without_touching_user_sheet_files():
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    assert "WriteUtf8File(SheetFiles[I], SheetXml[I])" in inject
    assert "WriteUtf8File(SheetFile," not in inject
    assert "TDirectory.GetFiles" not in inject
    assert "ValidateSeparatedWorksheetXml" in inject
    assert "ZipDirectory(TempDir, TempOutput)" in inject


def test_integrity_and_rtti_fixes_are_preserved():
    assert "WorkbookRelsDocument := LoadXMLDocument(WorkbookRelsFile);" in SERVICE
    assert "AddWorksheetRelationship(WorkbookRelsRoot, RelationId, SheetTargets[I]);" in SERVICE
    assert "function NextRelationId(const ARelsRoot: IXMLNode): string;" in SERVICE
    assert "function FindRelationshipTarget(const ARelsRoot: IXMLNode;" in SERVICE
    ensure = SERVICE.split("function EnsureAutomaticCalculation", 1)[1].split(
        "function WorkbookTemplateReloadHint", 1
    )[0]
    assert "CalcPrRegex.Replace(AWorkbookXml, CCalcPrXml, 1)" in ensure
    assert "Match.Index" not in ensure
    assert "ValidateWorkbookXmlText" in SERVICE
    assert "ValidateWorkbookXml" in SERVICE
    assert "SpillageStopCriteriaRttiToString(AValue)" in SERVICE
    set_branch = SERVICE.split("tkSet:", 1)[1].split("end;", 1)[0]
    assert "AValue.AsOrdinal" not in set_branch


def test_json_ownership_is_unchanged():
    assert "EmptyJson := BuildReportJson(nil, nil);" in SERVICE
    assert "InjectDataSheet(ASourceFileName, Result, EmptyJson);" in SERVICE
    assert "EmptyJson.Free;" in SERVICE
    assert "ARoot.Free" not in SERVICE
    assert "Rows.Free" not in SERVICE
def test_xml_builders_use_string_builder_and_json_transfer_is_explicit():
    insert = SERVICE.split("function InsertBeforeClosingTag", 1)[1].split(
        "function XmlAttribute", 1
    )[0]
    assert "TStringBuilder" in insert
    assert "AXml.Insert" not in insert
    assert "Builder.Append(AXml, 0, P)" in insert
    for function_name, next_marker in (
        ("function BuildSeparatedWorksheetXml", "function BuildMetaWorksheetXml"),
        ("function BuildMetaWorksheetXml", "procedure ValidateSeparatedWorksheetXml"),
    ):
        body = SERVICE.split(function_name, 1)[1].split(next_marker, 1)[0]
        assert "TStringBuilder" in body
        assert "Builder := TStringBuilder.Create" in body
        assert "Builder.Free" in body
        assert "Result := Result +" not in body
    scalar = SERVICE.split("procedure AddScalarMembers", 1)[1].split(
        "function NewObjectRow", 1
    )[0]
    assert scalar.count("JsonValue := nil;") >= 4
    assert "finally" in scalar
    assert "JsonValue.Free" in scalar


def test_separated_worksheet_closes_columns_before_sheet_data():
    builder = SERVICE.split("function BuildSeparatedWorksheetXml", 1)[1].split(
        "function BuildMetaWorksheetXml", 1
    )[0]
    assert "Builder.Append('</cols><sheetData><row r=\"1\">');" in builder
    assert builder.index("</cols>") < builder.index("<sheetData>")


def test_export_stages_are_logged_without_pcinfo():
    assert "procedure LogReportStage" in SERVICE
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    for stage in (
        "начало выгрузки", "распаковка XLSX", "чтение workbook.xml",
        "обработка служебного листа", "формирование листа",
        "запись XML листа", "упаковка XLSX", "замена итогового файла",
        "завершение выгрузки",
    ):
        assert stage in inject
    assert "pcInfo" not in inject
    assert "ошибка на этапе" in inject


if __name__ == "__main__":
    for name, value in sorted(globals().items()):
        if name.startswith("test_") and callable(value):
            value()
    print("report memory safety static checks: OK")
