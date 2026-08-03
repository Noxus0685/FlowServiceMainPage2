from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def test_exporter_uses_installed_flexcel_and_real_xlsx_api():
    text = source("uResultsXlsxExporter.pas")
    assert "FlexCel.Core" in text
    assert "FlexCel.XlsAdapter" in text
    assert "TXlsFile.Create" in text
    assert "Xls.Save(AFileName)" in text
    assert not any(forbidden in text for forbidden in ("libxlsxwriter", "OleVariant", "Excel.Application"))


def test_workbook_has_required_sheets_and_typed_values():
    text = source("uResultsXlsxExporter.pas")
    for sheet in ("Сессия", "Приборы", "Результаты"):
        assert f"Xls.SheetName := '{sheet}'" in text
    assert "Xls.SetCellValue(ARow, ACol, Value)" in text
    assert "Fmt.Format := CDateTimeFormat" in text
    assert "Spillage.Valid" in text


def test_export_scope_is_domain_driven_and_supports_all_devices():
    text = source("uResultsXlsxExporter.pas")
    assert "AWorkTable.DeviceChannels" in text
    assert "Device.GetActiveSessionSpillage" in text
    assert "Session.Spillages" in text
    assert "if ASelectedDevice <> nil" in text
    assert "Grid" not in text and "TreeView" not in text and "TLabel" not in text


def test_empty_results_are_rejected_and_workbook_is_reopenable_by_flexcel_design():
    text = source("uResultsXlsxExporter.pas")
    assert "(ResultCount = 0)" in text
    assert "Нет результатов для экспорта" in text
    assert "TXlsFile" in text and "NewFile(3)" in text


def test_results_tab_contains_export_button_and_enabled_rule():
    form = source("frmMRResults.fmx")
    code = source("frmMRResults.pas")
    assert "object ButtonExportExcel: TButton" in form
    assert "#1042#1099#1075#1088#1091#1079#1080#1090#1100' '#1074' Excel'" in form
    assert "ButtonExportExcel.Enabled := TResultsXlsxExporter.CanExport" in code
    assert "FActiveWorkTable, nil" in code
    assert "Excel Workbook (*.xlsx)|*.xlsx" in code
    assert "Results_" in code


def test_version_and_protocol_events():
    assert "APP_VERSION = '1.0.58'" in source("uAppVersion.pas")
    text = source("uResultsXlsxExporter.pas")
    for event in ("ResultsXlsxExportRequested", "ResultsXlsxExportCompleted", "ResultsXlsxExportFailed"):
        assert event in text
