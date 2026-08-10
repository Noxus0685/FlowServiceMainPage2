from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SERVICE = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_version_and_vertical_data_layout():
    assert "APP_VERSION = '1.0.103'" in VERSION
    body = SERVICE.split("function BuildDataWorksheetXml", 1)[1].split(
        "function BuildMetaWorksheetXml", 1
    )[0]
    assert '<dimension ref="A1:D%d"/>' in body
    assert "Техническое имя" in body
    assert "Название" in body
    assert "Значение" in body
    assert "Тип объекта" in body
    assert "ObjectType + '_' + FieldName" in body
    assert "GetReportFieldCaption(ObjectType, FieldName)" in body
    assert "'''_Data''!$C$%d" in body


def test_data_has_a_dedicated_builder_and_separated_data_is_retained():
    inject = SERVICE.split("procedure InjectDataSheet", 1)[1].split(
        "class function TReportTemplateService.TemplatesPath", 1
    )[0]
    assert "SheetXml[0] := BuildDataWorksheetXml" in inject
    assert inject.count("BuildSeparatedWorksheetXml(") == 3
    assert "['DevicePoint']" in inject
    assert "['Spillage']" in inject
    assert "['CalibrCoefTable', 'CalibrCoefItem']" in inject
    separated = SERVICE.split("function BuildSeparatedWorksheetXml", 1)[1].split(
        "function BuildDataWorksheetXml", 1
    )[0]
    assert "</cols><sheetData>" in separated


def test_stable_service_defined_names_are_created():
    for token in (
        "DevicePoints_%.2d_%s",
        "DevicePoints_%.2d_Spillages_%.2d_%s",
        "CalibrCoefTables_%s_Items_%.2d_%s",
        "ReportMeta_",
        "DeviceType_",
        "Device_",
    ):
        assert token in SERVICE
    assert "UpdateReportDefinedNames(WorkbookXml, DefinedNames)" in SERVICE
    assert "RemoveObsoleteReportDefinedNames(AWorkbookXml, ADefinedNames)" in SERVICE


def test_user_names_are_not_removed():
    cleanup = SERVICE.split("procedure RemoveObsoleteReportDefinedNames", 1)[1].split(
        "procedure UpdateReportDefinedNames", 1
    )[0]
    assert "IsReportDefinedName(Name)" in cleanup
    assert "not ADefinedNames.ContainsKey(Name)" in cleanup
    assert "Delete(AWorkbookXml" in cleanup


def test_required_helpers_and_xml_integrity_checks_remain():
    for declaration in (
        "function BuildDataWorksheetXml",
        "function GetReportFieldCaption",
        "function BuildReportDefinedName",
        "procedure UpdateReportDefinedNames",
        "procedure RemoveObsoleteReportDefinedNames",
        "procedure ValidateSeparatedWorksheetXml",
    ):
        assert declaration in SERVICE
    assert "ValidateWorkbookXml(WorkbookXml, 'именованные диапазоны')" in SERVICE
    assert "Builder.Append('</cols><sheetData><row r=\"1\">');" in SERVICE

