from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
API = (ROOT / "uXlsxWriterApi.pas").read_text(encoding="utf-8-sig")
EXPORTER = (ROOT / "uResultsXlsxExporter.pas").read_text(encoding="utf-8-sig")
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
MEASUREMENT = (ROOT / "frmMeasurementRun.pas").read_text(encoding="utf-8-sig")


def test_xlsx_api_is_cdecl_and_complete():
    names = ("workbook_new", "workbook_close", "worksheet_write_string",
             "worksheet_write_number", "worksheet_autofilter", "format_set_bold")
    for name in names:
        assert name in API
    assert API.count("cdecl") >= 17


def test_export_uses_domain_objects_and_utf8():
    assert "TList<TDevice>" in EXPORTER
    assert "TGrid" not in EXPORTER and "TTreeView" not in EXPORTER
    assert "UTF8String" in EXPORTER
    assert "worksheet_write_number" in EXPORTER
    assert all(value in EXPORTER for value in ("Сессия", "Приборы", "Результаты"))


def test_results_support_selected_or_all_devices():
    assert "CollectTargetDevices" in RESULTS
    assert "SelectedDevice" in RESULTS and "AllDevices" in RESULTS
    assert "ResultsXlsxExportCompleted" in RESULTS
    assert "ResultsSessionsClearCompleted" in RESULTS


def test_current_point_focus_does_not_rebuild_every_time():
    assert "procedure TFrameMeasurementRun.FocusCurrentMeasurementPoint" in MEASUREMENT
    assert "GridMeasurmentRun.Selected := LIndex" in MEASUREMENT
    assert "GridMeasurmentRun.ScrollToSelectedCell" in MEASUREMENT
    assert "GridMeasurmentRun.RowCount := 0" not in MEASUREMENT
    assert "if (LIndex < 0)" in MEASUREMENT
