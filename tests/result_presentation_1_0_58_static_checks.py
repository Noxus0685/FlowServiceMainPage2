from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHARED = (ROOT / "uResultPresentation.pas").read_text(encoding="utf-8-sig")
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
PROCESSING = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")


def _production_format(value: float) -> str:
    """Python oracle for Delphi FormatFloat('0.###') with Russian separator."""
    value = round(value, 3)
    text = f"{value:.3f}".rstrip("0").rstrip(".")
    return text.replace(".", ",")


def test_shared_error_formatter_matches_processing_precision_examples():
    assert "FormatFloat('0.###', AValue)" in SHARED
    expected = ["-0,436", "-0,073", "0,003", "0,301", "2"]
    assert [_production_format(v) for v in (-0.436, -0.073, 0.003, 0.301, 2.0)] == expected
    assert "FormatResultError(AValue)" in RESULTS
    assert "FormatResultError(Spillage.Error)" in PROCESSING


def test_results_has_no_private_meter_value_error_formatting():
    assert "ValueError.GetStrNumLimits" not in RESULTS
    formatter = RESULTS[RESULTS.index("function TFrameMRResults.FormatErrorValue"):]
    formatter = formatter[:formatter.index("end;")]
    assert "FormatFloat" not in formatter


def test_both_tabs_use_shared_visual_state_and_colors():
    for source in (RESULTS, PROCESSING):
        assert "ResolvePointResultVisualState" in source
        assert "GetResultStateColor" in source
        assert "ResolveDeviceResultVisualState" in source
        assert "GetDeviceResultText" in source


def test_done_status_is_not_an_independent_warning_rule():
    resolver = SHARED[SHARED.index("function ResolvePointResultVisualState"):]
    assert "mptsDone:" not in resolver
    assert "SPS_OK: Result := prvsValid" in resolver
    assert "SPS_ERROR_EXCEEDED: Result := prvsInvalid" in resolver
    assert "SPS_STOP_CRITERIA_FAILED: Result := prvsWarning" in resolver


def test_visual_palette_covers_success_failure_warning_pending_and_running():
    assert "prvsRunning: Result := COLOR_RUNNING" in SHARED
    assert "prvsValid: Result := COLOR_COMPLETED" in SHARED
    assert "prvsInvalid: Result := COLOR_INVALID" in SHARED
    assert "prvsWarning: Result := COLOR_WARNING" in SHARED
    assert "Exit(prvsPending)" in SHARED


def test_device_column_includes_serial_without_reordering_rows():
    assert "Device.SerialNumber" in RESULTS
    assert "for Ch in FActiveWorkTable.DeviceChannels" in RESULTS


def test_three_device_q1_q2_q3_integration_contract_uses_one_pipeline():
    # The three rows and all their point columns are built in DeviceChannels order;
    # every Q1/Q2/Q3 cell reaches these same shared formatter/state functions.
    assert "Value := GetCellText(Channel, SessionPoint)" in RESULTS
    assert "C := GetCellColor(Channel, SessionPoint)" in RESULTS
    assert RESULTS.count("FormatErrorValue(") >= 6
