from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def section(start, end):
    return SRC.split(start, 1)[1].split(end, 1)[0]


def test_release_and_analysis_contract():
    assert "APP_VERSION = '1.0.114'" in VERSION
    for field in ("XmlValid", "WorkbookValid", "DevicePointsValid", "CanRepair",
                  "MissingNames", "InvalidReferences"):
        assert field in section("TPointErrorMigrationAnalysis = record", "end;")
    wrapper = section("function GetPointErrorMigrationState", "function PointErrorMigrationStateToString")
    assert "AnalyzePointErrorMigration(AWorkbookXml, ADevicePointsXml).State" in wrapper


def test_old_data_row_count_does_not_gate_migration():
    analysis = SRC.rsplit("function AnalyzePointErrorMigration", 1)[1].split("function GetPointErrorMigrationState", 1)[0]
    assert "RequiredRowsFound" not in analysis
    assert "sheetData" not in analysis
    assert "Result.State := pemsRequired" in analysis
    assert "Result.CanRepair := True" in analysis


def test_only_global_flowservice_point_error_names_are_removed():
    removal = section("procedure RemoveFlowServicePointErrorDefinedNames(",
                      "procedure RemoveFlowServicePointErrorDefinedNamesFromWorkbook")
    matcher = section("function IsFlowServicePointErrorDefinedName", 
                      "procedure RemoveFlowServicePointErrorDefinedNames(")
    assert "for I := ADefinedNamesNode.ChildNodes.Count - 1 downto 0" in removal
    assert "IsFlowServicePointErrorDefinedName(Name) and (LocalSheetId = '')" in removal
    assert "'_PointError'" in matcher
    assert "MAX_DEVICE_POINTS" in matcher


def test_injection_repairs_before_updating_and_has_diagnostics():
    inject = section("procedure InjectDataSheet", "procedure InitializeReportTemplate")
    assert inject.index("AnalyzePointErrorMigration(WorkbookXml") < inject.index("BuildSeparatedWorksheetXml(CSheetTitles[1]")
    assert "if PointErrorMigrationAnalysis.CanRepair then" in inject
    assert "Некорректная структура PointError: %s" in inject
    assert inject.index("RemoveFlowServicePointErrorDefinedNamesFromWorkbook") < inject.index("UpdateReportDefinedNames")
    assert "PointErrorMigrationAnalysis.State <> pemsNotRequired" in inject
    assert "BuildPointErrorMigrationDiagnostic(WorkbookXml, SheetXml[1])" in inject


def test_prepared_workbook_stays_unserialized():
    inject = section("procedure InjectDataSheet", "procedure InitializeReportTemplate")
    assert "if AInitializeStructure or NeedsPointErrorMigration then\n      UpdateReportDefinedNames" in inject
    assert "if AInitializeStructure or NeedsPointErrorMigration or WorkbookRepaired then" in inject


def test_build_report_json_keeps_all_points_and_null_error():
    build = section("class function TReportTemplateService.BuildReportJson", "class procedure TReportTemplateService.ExportTemplate")
    assert "for PointIndex := 1 to MAX_DEVICE_POINTS do" in build
    assert "NewObjectRow('DevicePoint', PointIndex, PointIndex" in build
    assert "PointRow.AddPair('PointError', TJSONNull.Create)" in build
