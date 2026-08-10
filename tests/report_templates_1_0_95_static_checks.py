from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SERVICE = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
FORM = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmProceed.fmx").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_version_and_project_unit():
    assert "APP_VERSION = '1.0.95'" in VERSION
    assert "uReportTemplates in 'uReportTemplates.pas'" in (
        ROOT / "ProjectFornTest.dpr"
    ).read_text(encoding="utf-8-sig")


def test_report_tab_has_template_list_and_two_buttons():
    assert "object ListBoxReportTemplates: TListBox" in FMX
    assert "object ButtonLoadReportTemplate: TButton" in FMX
    assert "object ButtonExportReportTemplate: TButton" in FMX
    assert "OnClick = ButtonLoadReportTemplateClick" in FMX
    assert "OnClick = ButtonExportReportTemplateClick" in FMX


def test_fixed_single_table_schema():
    assert "MAX_DEVICE_POINTS = 7" in SERVICE
    assert "MAX_POINT_SPILLAGES = 10" in SERVICE
    assert "MAX_COEF_ITEMS = 20" in SERVICE
    assert "DATA_SHEET_NAME = '_Data'" in SERVICE
    assert "DATA_TABLE_NAME = 'tblReportData'" in SERVICE
    assert "CCoefTableTypes: array[0..4] of Integer = (10, 11, 12, 13, 14)" in SERVICE
    assert "Rows.AddElement(NewObjectRow('DevicePoint'" in SERVICE
    assert "Rows.AddElement(NewObjectRow('Spillage'" in SERVICE
    assert "Rows.AddElement(NewObjectRow('CalibrCoefTable'" in SERVICE
    assert "Rows.AddElement(NewObjectRow('CalibrCoefItem'" in SERVICE


def test_json_is_source_for_data_sheet_and_template_is_preserved():
    assert "class function TReportTemplateService.BuildReportJson" in SERVICE
    assert "InjectDataSheet(ASourceFileName, Result, EmptyJson)" in SERVICE
    assert "InjectDataSheet(ATemplateFileName, AOutputFileName, Json)" in SERVICE
    assert "Zip.ExtractAll(TempDir)" in SERVICE
    assert "<tableParts count=\"1\">" in SERVICE


def test_zip_entry_validation_keeps_nil_guard_and_direct_iteration():
    assert "if AZip = nil then" in SERVICE
    assert "for Name in AZip.FileNames do" in SERVICE
    assert "Names := AZip.FileNames;" not in SERVICE
    assert "локальную копию списка имён" not in SERVICE
    assert "Names:" not in SERVICE.split("procedure ValidateZipEntries", 1)[1].split("end;", 1)[0]


def test_workbook_relationships_use_xml_dom():
    assert "Xml.XMLDoc" in SERVICE
    assert "Xml.XMLIntf" in SERVICE
    assert "System.Variants" in SERVICE
    assert "WorkbookRelsDocument := LoadXMLDocument(WorkbookRelsFile);" in SERVICE
    assert "WorkbookRelsRoot := WorkbookRelsDocument.DocumentElement;" in SERVICE
    assert "function NextRelationId(const ARelsRoot: IXMLNode): string;" in SERVICE
    assert "function FindRelationshipTarget(const ARelsRoot: IXMLNode;" in SERVICE
    assert "procedure AddWorksheetRelationship(const ARelsRoot: IXMLNode;" in SERVICE
    assert "ARelsRoot.AddChild('Relationship', ARelsRoot.NamespaceURI)" in SERVICE
    assert "Node.Attributes['Id'] := ARelationId;" in SERVICE
    assert "Node.Attributes['Type'] := CWorksheetRelation;" in SERVICE
    assert "Node.Attributes['Target'] := ATarget;" in SERVICE
    assert "WorkbookRelsDocument.SaveToFile(WorkbookRelsFile);" in SERVICE
    assert "WriteUtf8File(WorkbookRelsFile" not in SERVICE


def test_workbook_relationships_are_not_held_as_a_string():
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    assert "WorkbookRelsXml" not in inject
    assert "ReadUtf8File(WorkbookRelsFile)" not in inject
    assert "InsertBeforeClosingTag(WorkbookRels" not in inject
    assert "TRegEx" not in inject
    assert "AddWorksheetRelationship(WorkbookRelsRoot, RelationId, Target);" in inject
    assert "FindRelationshipTarget(WorkbookRelsRoot, RelationId)" in inject


def test_managed_values_are_not_modified_unsafely():
    for forbidden in (
        "Pointer(", "PPointer", "FillChar(", "Finalize(", "Move(",
        "UniqueString(", "ARoot.Free", "Rows.Free"
    ):
        assert forbidden not in SERVICE


def test_data_sheet_input_is_validated_without_taking_json_ownership():
    assert "if ARoot = nil then" in SERVICE
    assert "Не заданы данные для формирования листа _Data" in SERVICE
    assert "if Rows = nil then" in SERVICE
    assert "В данных отчёта отсутствует массив Rows" in SERVICE
    assert "ARoot.Free" not in SERVICE
    assert "[TReportTemplateService.DATA_SHEET_NAME, SheetId, RelationId]" in SERVICE
    assert SERVICE.count("if ARoot = nil then") == 1
    for forbidden in ("FillChar(", "ZeroMemory(", "Move(", "ARoot.Free"):
        assert forbidden not in SERVICE


def test_ui_uses_selected_device_and_save_dialog():
    assert "Device := ResolveSelectedDevice" in FORM
    assert "TReportTemplateService.ImportTemplate(Dialog.FileName)" in FORM
    assert "TReportTemplateService.ExportTemplate(TemplateFileName, Dialog.FileName" in FORM
    assert "Dialog := TSaveDialog.Create(Self)" in FORM


if __name__ == "__main__":
    test_version_and_project_unit()
    test_report_tab_has_template_list_and_two_buttons()
    test_fixed_single_table_schema()
    test_json_is_source_for_data_sheet_and_template_is_preserved()
    test_zip_entry_validation_keeps_nil_guard_and_direct_iteration()
    test_workbook_relationships_use_xml_dom()
    test_workbook_relationships_are_not_held_as_a_string()
    test_managed_values_are_not_modified_unsafely()
    test_data_sheet_input_is_validated_without_taking_json_ownership()
    test_ui_uses_selected_device_and_save_dialog()
    print("report template static checks: OK")
