from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
PROCESSING = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
DPR = (ROOT / "ProjectFornTest.dpr").read_text(encoding="utf-8-sig")
DPROJ = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def _method(source: str, signature: str, next_signature: str) -> str:
    start = source.index(signature)
    end = source.index(next_signature, start + len(signature))
    return source[start:end]


def test_no_result_presentation_module_or_reference_exists():
    assert not (ROOT / "uResultPresentation.pas").exists()
    for source in (DPR, DPROJ, PROCESSING, RESULTS):
        assert "uResultPresentation" not in source


def test_results_error_text_delegates_to_processing_formatter():
    body = _method(
        RESULTS,
        "function TFrameMRResults.FormatErrorValue",
        "function TFrameMRResults.FormatSpillageErrors",
    )
    assert "TFrameProceed(FProceed).FormatResultErrorValue(AValue)" in body
    assert "GetStrNumLimits" not in body
    assert "FormatFloat" not in body
    assert "FormatDeviceError(AValue)" in body  # existing project fallback only


def test_processing_formatter_remains_the_summary_grid_production_rule():
    wrapper = _method(
        PROCESSING,
        "function TFrameProceed.FormatResultErrorValue",
        "function TFrameProceed.GetPointResultColor",
    )
    assert "FormatFloat('0.###', AValue)" in wrapper
    assert "FormatResultErrorValue(Spillage.Error)" in PROCESSING


def test_completed_result_color_delegates_without_local_status_mapping():
    color = _method(
        RESULTS,
        "function TFrameMRResults.GetCellColor",
        "function TFrameMRResults.GetResultText",
    )
    assert "TFrameProceed(FProceed).GetPointResultColor" in color
    for forbidden in ("mptsDone", "SPS_OK", "SPS_ERROR_EXCEEDED"):
        assert forbidden not in color


def test_q1_q2_q3_cells_share_processing_text_and_color_entry_points():
    # Every dynamic point column (including Q1/Q2/Q3) reaches these two methods.
    assert "Value := GetCellText(Channel, SessionPoint)" in RESULTS
    assert "C := GetCellColor(Channel, SessionPoint)" in RESULTS
    assert "FormatErrorValue(ADevicePoint.ProtocolDataPoints[I].Error)" in RESULTS
    assert "FormatErrorValue(S.Error)" in RESULTS
    assert "GetPointResultColor(ADevice: TDevice; ADevicePoint: TDevicePoint;" in PROCESSING


def test_device_result_and_serial_are_delegated_without_row_reordering():
    assert "TFrameProceed(FProceed).GetDeviceResultText(Device)" in RESULTS
    assert "TFrameProceed(FProceed).GetDeviceResultColor(Device)" in RESULTS
    assert "Device.SerialNumber" in RESULTS
    assert "for Ch in FActiveWorkTable.DeviceChannels" in RESULTS
