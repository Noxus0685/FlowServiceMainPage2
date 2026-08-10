from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_version_and_capacities():
    assert "APP_VERSION = '1.0.100'" in VERSION
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


if __name__ == "__main__":
    for name, value in sorted(globals().items()):
        if name.startswith("test_") and callable(value):
            value()
    print("separated report sheet static checks: OK")
