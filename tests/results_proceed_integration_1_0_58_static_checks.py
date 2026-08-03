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
    assert "FormatErrorValue(S.Error)" in RESULTS
    assert "GetPointResultColor(ADevice: TDevice; ADevicePoint: TDevicePoint;" in PROCESSING


def test_device_result_and_serial_are_delegated_without_row_reordering():
    assert "TFrameProceed(FProceed).GetDeviceResultText(Device)" in RESULTS
    assert "TFrameProceed(FProceed).GetDeviceResultColor(Device)" in RESULTS
    assert "Device.SerialNumber" in RESULTS
    assert "for Ch in FActiveWorkTable.DeviceChannels" in RESULTS


def test_saved_spillages_are_bound_by_the_production_device_matcher():
    assert RESULTS.count("FindMatchedDevicePointForSpillage") >= 3
    finder = _method(
        RESULTS,
        "function TFrameMRResults.FindPointSpillage",
        "function TFrameMRResults.FormatPointHeader",
    )
    assert "MatchedPoint := ADevice.FindMatchedDevicePointForSpillage(S)" in finder
    assert "MatchedPoint = ASessionPoint" in finder
    assert "TMeasurementRun.IsPointEquivalent" not in finder


def test_active_session_never_falls_back_to_a_newer_old_session():
    finder = _method(
        RESULTS,
        "function TFrameMRResults.FindPointSpillage",
        "function TFrameMRResults.FormatPointHeader",
    )
    assert "S.SessionID = Session.ID" in finder
    assert "Fallback" not in finder
    assert "S.DateTime" not in finder
    assert finder.index("if Session = nil then") < finder.index("FindResultSpillageForPoint")


def test_multiple_spillages_are_listed_only_for_their_matched_physical_point():
    listing = _method(
        RESULTS,
        "function TFrameMRResults.BuildErrorsListText",
        "function TFrameMRResults.IsCellRunning",
    )
    assert "MatchedPoint := ADevice.FindMatchedDevicePointForSpillage(S)" in listing
    assert "MatchedPoint <> ADevicePoint" in listing
    assert "TMeasurementRun.IsPointEquivalent" not in listing
    assert "Items[Cnt] := FormatErrorValue(S.Error)" in listing


def test_columns_include_matched_active_session_points_after_scenario_points():
    columns = _method(
        RESULTS,
        "procedure TFrameMRResults.BuildColumns",
        "function TFrameMRResults.SameDisplayPoint",
    )
    assert columns.index("MeasurementRun.Points") < columns.index("Device.Spillages")
    assert "Spill.SessionID <> Session.ID" in columns
    assert "MatchedPoint := Device.FindMatchedDevicePointForSpillage(Spill)" in columns
    assert "AddDisplayPoint(MatchedPoint)" in columns
    assert "for I := 0 to FDisplayPoints.Count - 1" in columns


def test_persisted_error_is_not_replaced_by_protocol_data_from_another_session():
    formatter = _method(
        RESULTS,
        "function TFrameMRResults.FormatSpillageErrors",
        "function TFrameMRResults.BuildErrorsListText",
    )
    assert "FormatErrorValue(ASpillage.Error)" in formatter
    assert "ProtocolDataPoints[" not in formatter


def test_saved_spillage_makes_cell_done_independent_of_point_status():
    state = _method(
        RESULTS,
        "function TFrameMRResults.GetCellState",
        "function TFrameMRResults.GetCellText",
    )
    assert "if ASpillage = nil" in state
    assert "Result := csDone" in state
    assert "ADevicePoint.Status" not in state


def _bind_saved_results(device_points, scenario_order, spills, active_session):
    """Contract model: production match_id resolves a spill before column lookup."""
    columns = list(scenario_order)
    for spill in spills:
        if spill["session"] != active_session:
            continue
        point = device_points[spill["match_id"]]
        if point not in columns:
            columns.append(point)
    cells = {point: [] for point in columns}
    for spill in spills:
        if spill["session"] == active_session:
            cells[device_points[spill["match_id"]]].append(spill["error"])
    return columns, cells


def test_qa_results_do_not_leak_into_qb_or_qc():
    points = {"qa-id": "Qa", "qb-id": "Qb", "qc-id": "Qc"}
    spills = [
        {"session": 7, "match_id": "qa-id", "error": value}
        for value in (-0.126, 0.018, 0.108)
    ]
    _, cells = _bind_saved_results(points, ["Qa", "Qb", "Qc"], spills, 7)
    assert cells == {"Qa": [-0.126, 0.018, 0.108], "Qb": [], "Qc": []}


def test_measurement_run_order_does_not_change_physical_binding():
    points = {"qa-id": "Qa", "qb-id": "Qb", "qc-id": "Qc"}
    spill = {"session": 2, "match_id": "qa-id", "error": -0.126}
    columns, cells = _bind_saved_results(points, ["Qc", "Qb", "Qa"], [spill], 2)
    assert columns == ["Qc", "Qb", "Qa"]
    assert cells["Qa"] == [-0.126]


def test_stable_match_id_wins_when_scenario_and_device_names_differ():
    points = {"stable-source-uuid": "Qa-device"}
    spill = {"session": 3, "match_id": "stable-source-uuid", "error": 0.018}
    _, cells = _bind_saved_results(points, [], [spill], 3)
    assert cells["Qa-device"] == [0.018]


def test_newer_old_session_is_excluded_and_two_active_spills_share_one_cell():
    points = {"qa-id": "Qa", "qb-id": "Qb"}
    spills = [
        {"session": 8, "match_id": "qa-id", "error": -0.126},
        {"session": 8, "match_id": "qa-id", "error": 0.018},
        {"session": 1, "match_id": "qb-id", "error": 9.999},
    ]
    _, cells = _bind_saved_results(points, ["Qa", "Qb"], spills, 8)
    assert cells == {"Qa": [-0.126, 0.018], "Qb": []}
