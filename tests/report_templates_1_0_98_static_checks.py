from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SERVICE = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
FORM = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmProceed.fmx").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_version_and_project_unit():
    assert "APP_VERSION = '1.0.98'" in VERSION
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
    assert "TRegEx.Matches(WorkbookRels" not in inject
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


def test_spillage_stop_criteria_set_uses_raw_rtti_data():
    assert "PSpillageStopCriteria = ^TSpillageStopCriteria;" in SERVICE
    assert "function SpillageStopCriteriaRttiToString(const AValue: TValue): string;" in SERVICE
    helper = SERVICE.split(
        "function SpillageStopCriteriaRttiToString", 1
    )[1].split("function RttiValueToJson", 1)[0]
    assert "if AValue.Kind <> tkSet then" in helper
    assert "AValue.TypeInfo <> TypeInfo(TSpillageStopCriteria)" in helper
    assert "AValue.ExtractRawData(@Criteria);" in helper
    assert "GetReferenceToRawData" not in helper
    assert "CriteriaToInt(Criteria)" in helper
    assert "SetToString(PTypeInfo(TypeInfo(TSpillageStopCriteria))," in helper
    assert "CriteriaToInt(Criteria), True)" in helper
    assert "Неподдерживаемый тип набора при формировании отчёта" in helper


def test_tkset_does_not_use_ordinal_cast_and_enumeration_is_unchanged():
    converter = SERVICE.split("function RttiValueToJson", 1)[1].split(
        "procedure AddScalarMembers", 1
    )[0]
    set_branch = converter.split("tkSet:", 1)[1].split("end;", 1)[0]
    assert "AValue.AsOrdinal" not in set_branch
    assert "SpillageStopCriteriaRttiToString(AValue)" in set_branch
    assert "tkEnumeration:" in converter
    assert "AValue.TypeInfo = TypeInfo(Boolean)" in converter
    assert "TJSONBool.Create(AValue.AsBoolean)" in converter
    assert "GetEnumName(AValue.TypeInfo," in converter
    assert "AValue.AsOrdinal" in converter.split("tkEnumeration:", 1)[1].split(
        "tkChar", 1
    )[0]


def test_workbook_calculation_update_preserves_safe_regex_replacement():
    ensure = SERVICE.split("function EnsureAutomaticCalculation", 1)[1].split(
        "function WorkbookTemplateReloadHint", 1
    )[0]
    assert "TRegEx.Create(CCalcPrPattern, [roIgnoreCase])" in ensure
    assert "CalcPrRegex.Replace(AWorkbookXml, CCalcPrXml, 1)" in ensure
    for forbidden in ("Match.Index", "Match.Length", ".Remove(", ".Insert("):
        assert forbidden not in ensure


def test_workbook_text_diagnostics_run_before_dom_parsing():
    assert "procedure ValidateWorkbookXmlText(const AWorkbookXml, AStage: string;" in SERVICE
    text_validator = SERVICE.split("procedure ValidateWorkbookXmlText", 1)[1].split(
        "procedure ValidateWorkbookXml", 1
    )[0]
    assert "ARequireSingleCalcPr: Boolean" in text_validator
    assert "AWorkbookXml.Contains('<<<calcPr')" in text_validator
    assert "AWorkbookXml.Contains('<<calcPr')" in text_validator
    assert "AWorkbookXml.Contains('/>extLst>')" in text_validator
    assert "AWorkbookXml.Contains('/>xtLst>')" in text_validator
    assert "if ARequireSingleCalcPr then" in text_validator
    assert "CalcPrCount <> 1" in text_validator
    assert "XmlBody := AWorkbookXml.TrimLeft;" in text_validator
    assert "XmlBody.StartsWith('<workbook')" in text_validator
    assert "Ord(XmlBody[1])" in text_validator
    assert "StringReplace" not in text_validator


def test_workbook_dom_errors_are_wrapped_with_stage_and_original_message():
    assert "Xml.xmldom" in SERVICE
    assert "procedure ValidateWorkbookXml(const AWorkbookXml, AStage: string);" in SERVICE
    validator = SERVICE.split("procedure ValidateWorkbookXml", 1)[1].split(
        "function WorkbookTargetToArchivePath", 1
    )[0]
    assert "on E: EDOMParseError do" in validator
    assert "[AStage, E.Message, WorkbookTemplateReloadHint(AStage)]" in validator
    assert "on E: Exception" not in validator
    assert "SameText(Root.LocalName, 'workbook')" in validator


def test_workbook_validation_localizes_each_mutation_stage():
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    source_read = inject.index("WorkbookXml := ReadUtf8File(WorkbookFile);")
    source_text = inject.index(
        "ValidateWorkbookXmlText(WorkbookXml, 'чтение исходного шаблона', False);"
    )
    source_dom = inject.index(
        "ValidateWorkbookXml(WorkbookXml, 'чтение исходного шаблона');"
    )
    relation_lookup = inject.index("RelationId := FindDataSheetRelationId(WorkbookXml);")
    assert source_read < source_text < source_dom < relation_lookup

    sheet_insert = inject.index("UpdatedWorkbookXml := InsertBeforeClosingTag(")
    sheet_text = inject.index("'добавление листа _Data', False);")
    sheet_dom = inject.index(
        "ValidateWorkbookXml(UpdatedWorkbookXml, 'добавление листа _Data');"
    )
    sheet_assign = inject.index("WorkbookXml := UpdatedWorkbookXml;", sheet_insert)
    assert sheet_insert < sheet_text < sheet_dom < sheet_assign

    calc_update = inject.index(
        "UpdatedWorkbookXml := EnsureAutomaticCalculation(WorkbookXml);"
    )
    calc_text = inject.index("'EnsureAutomaticCalculation', True);")
    calc_dom = inject.index(
        "ValidateWorkbookXml(UpdatedWorkbookXml, 'EnsureAutomaticCalculation');"
    )
    calc_assign = inject.index("WorkbookXml := UpdatedWorkbookXml;", calc_update)
    assert calc_update < calc_text < calc_dom < calc_assign
    assert "После изменения xl/workbook.xml обнаружены" not in inject
    assert "Исходный XLSX-шаблон уже содержит повреждённый" in SERVICE


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
    test_spillage_stop_criteria_set_uses_raw_rtti_data()
    test_tkset_does_not_use_ordinal_cast_and_enumeration_is_unchanged()
    test_workbook_calculation_update_preserves_safe_regex_replacement()
    test_workbook_text_diagnostics_run_before_dom_parsing()
    test_workbook_dom_errors_are_wrapped_with_stage_and_original_message()
    test_workbook_validation_localizes_each_mutation_stage()
    test_ui_uses_selected_device_and_save_dialog()
    print("report template static checks: OK")
