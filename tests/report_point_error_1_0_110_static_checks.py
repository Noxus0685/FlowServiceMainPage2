from pathlib import Path

ROOT = Path(__file__).parents[1]
REPORT = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
DEVICE = (ROOT / "uDeviceClass.pas").read_text(encoding="utf-8-sig")
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_version_and_shared_selection():
    assert "APP_VERSION = '1.0.112'" in VERSION
    assert "function TryGetDevicePointDisplayError" in DEVICE
    assert "function TrySelectDevicePointDisplaySpillage" in DEVICE
    merged = PROCEED.split("function TFrameProceed.FormatMergedSummarySeriesResults", 1)[1].split("procedure TFrameProceed.BuildSummaryColumnsWithoutMerge", 1)[0]
    assert "TrySelectDevicePointDisplaySpillage" in merged


def test_signed_minimum_absolute_error_and_validation():
    selector = DEVICE.split("function TrySelectDevicePointDisplaySpillage", 2)[2].split("end;", 1)[0]
    assert "Abs(Candidate.Error) < Abs(ASelected.Error)" in selector
    assert "AError := Selected.Error" in DEVICE
    assert "ADevicePoint.ResultError" not in REPORT
    validator = DEVICE.split("function IsDevicePointDisplayErrorCandidate", 1)[1].split("end;", 1)[0]
    for check in ("osDeleted", "Enabled", "Validation = vsValid", "IsNan", "IsInfinite", "MaxDouble"):
        assert check in validator


def test_active_session_device_and_point_identity_filters():
    helper = DEVICE.split("function TryGetDevicePointDisplayError", 2)[2].split("function UnknownStateText", 1)[0]
    for check in ("Candidate.SessionID <> ASession.ID", "Candidate.DeviceUUID", "ADevice.UUID",
                  "DeviceTypeUUID", "Candidate.Name", "FindMatchedDevicePointForSpillage"):
        assert check in helper
    build = REPORT.split("class function TReportTemplateService.BuildReportJson", 1)[1]
    assert "Session.Active" in build
    assert "GetActiveSessionSpillage" not in build.split("end;", 1)[0]


def test_point_error_json_column_and_names():
    assert "PointRow.AddPair('PointError', TJSONNumber.Create(PointError))" in REPORT
    assert "PointRow.AddPair('PointError', TJSONNull.Create)" in REPORT
    order = REPORT.split("PointError is a calculated report field", 1)[1].split("end;", 1)[0]
    assert "Result.IndexOf('Q')" in order
    assert "Result.Insert(I + 1, 'PointError')" in order
    assert "Погрешность точки (PointError)" in REPORT
    assert "SeparatedRowDefinedName(Row, Columns[I])" in REPORT


def test_controlled_idempotent_defined_name_migration():
    assert "GetPointErrorMigrationState(WorkbookXml" in REPORT
    assert "pemsRequired: NeedsPointErrorMigration := True" in REPORT
    assert "pemsPartial:" in REPORT and "pemsInvalid:" in REPORT
    assert "if AInitializeStructure or NeedsPointErrorMigration then\n      UpdateReportDefinedNames" in REPORT
