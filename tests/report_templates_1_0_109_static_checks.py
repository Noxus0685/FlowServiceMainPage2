from pathlib import Path

ROOT = Path(__file__).parents[1]
SRC = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_release_and_template_state_api():
    assert "APP_VERSION = '1.0.110'" in VERSION
    for name in ("IsPreparedReportTemplate", "GetMissingReportTemplateSheets",
                 "RepairLegacyReportWorkbookXml", "ImportPreparedReportTemplate"):
        assert name in SRC


def test_prepared_export_does_not_rebuild_package_metadata():
    assert "UpdatePreparedTemplateData(ATemplateFileName, AOutputFileName, Json)" in SRC
    assert "InjectDataSheet(ASourceFileName, AOutputFileName, ARoot, False)" in SRC
    assert "if AInitializeStructure or NeedsPointErrorMigration then\n      UpdateReportDefinedNames" in SRC
    assert "if AInitializeStructure or NeedsPointErrorMigration then\n    begin\n      WriteUtf8File(WorkbookFile" in SRC


def test_safe_legacy_patterns_are_scoped_and_validated():
    repair = SRC.split("function RepairLegacyReportWorkbookXml", 2)[2].split(
        "function NextSheetId", 1)[0]
    for pattern in ("<<<calcPr", "<<calcPr", "/>xtLst>", "/>extLst>"):
        assert pattern in repair
    assert "ValidateWorkbookXml(Result, 'восстановление старого шаблона')" in repair


def test_flow_conversion_is_explicit_and_json_only():
    assert "ADevice.FromBaseUnits(AValue)" in SRC
    assert "function IsBaseFlowReportField" in SRC
    assert "procedure NormalizeReportRowUnits" in SRC
    assert "_FlowUnitsNormalized" in SRC
    assert "cctDeviceFlowRateCorrection" in SRC
    assert "CommonMinQ" not in SRC.split("function IsBaseFlowReportField", 2)[2].split("end;", 1)[0]
