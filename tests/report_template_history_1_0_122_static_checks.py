from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
UI = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
FORM = (ROOT / "frmProceed.fmx").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def method(name, next_name):
    return UI.split(name, 1)[1].split(next_name, 1)[0]


def test_report_history_header_and_actions_are_wired():
    assert "object LayoutReportTemplatesHeader: TLayout" in FORM
    assert "object LabelReportTemplates: TLabel" in FORM
    assert "object ButtonClearReportTemplates: TButton" in FORM
    assert "OnClick = ButtonClearReportTemplatesClick" in FORM


def test_templates_are_sorted_by_utc_timestamp_then_name():
    sorting = method(
        "function TFrameProceed.GetSortedReportTemplateFiles",
        "procedure TFrameProceed.MarkReportTemplateAsRecentlyLoaded",
    )
    assert "TDirectory.GetFiles" in sorting
    assert "'*.xlsx'" in sorting
    assert "TSearchOption.soTopDirectoryOnly" in sorting
    assert sorting.count("TFile.GetLastWriteTimeUtc") == 2
    assert "if LeftTime > RightTime then" in sorting
    assert "CompareText" in sorting
    assert "TStringComparer.OrdinalIgnoreCase" not in sorting


def test_import_marks_timestamp_then_refreshes_and_selects_file():
    loading = method(
        "procedure TFrameProceed.ButtonLoadReportTemplateClick",
        "procedure TFrameProceed.ButtonClearReportTemplatesClick",
    )
    prepare = loading.index("TReportTemplateService.PrepareTemplate")
    mark = loading.index("MarkReportTemplateAsRecentlyLoaded", prepare)
    refresh = loading.index("RefreshReportTemplates", mark)
    select = loading.index("Items.IndexOf", refresh)
    assert prepare < mark < refresh < select
    assert "TFile.SetLastWriteTime(AFileName, Now)" in UI
    assert "TTimeZone" not in UI


def test_clear_deletes_only_top_level_xlsx_and_collects_failures():
    clearing = method(
        "procedure TFrameProceed.ButtonClearReportTemplatesClick",
        "procedure TFrameProceed.BeginReportExportUi",
    )
    assert "'*.xlsx', TSearchOption.soTopDirectoryOnly" in clearing
    assert "TFile.Delete(FileName)" in clearing
    assert "TDirectory.Delete" not in clearing
    assert "FailedFiles.Add" in clearing
    assert clearing.count("MessageDlg") == 2
    assert "ReportTemplateHistoryClearStarted" in clearing
    assert "ReportTemplateHistoryClear" in clearing
    assert "pcInfo" not in clearing


def test_empty_history_and_export_state_control_button_availability():
    controls = method(
        "procedure TFrameProceed.UpdateReportTemplateControls",
        "procedure TFrameProceed.ButtonLoadReportTemplateClick",
    )
    assert "Items.Count > 0" in controls
    assert "ButtonLoadReportTemplate.Enabled := not FReportExportInProgress" in controls
    assert "ButtonExportReportTemplate.Enabled := HasTemplates" in controls
    assert "ButtonClearReportTemplates.Enabled := HasTemplates" in controls
    assert "UpdateReportTemplateControls;" in method(
        "procedure TFrameProceed.EndReportExportUi",
        "procedure TFrameProceed.CompleteReportExport",
    )


def test_project_version_is_1_0_122():
    assert "APP_VERSION = '1.0.122'" in VERSION
    assert "FileVersion=1.0.122.0" in PROJECT
    assert "ProductVersion=1.0.122.0" in PROJECT
