from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")


def body(name: str) -> str:
    start = PAS.index(name)
    next_procedure = PAS.find("\nprocedure ", start + len(name))
    next_function = PAS.find("\nfunction ", start + len(name))
    ends = [position for position in (next_procedure, next_function) if position >= 0]
    return PAS[start:min(ends) if ends else len(PAS)]


def test_error_column_always_formats_model_value():
    get_value = body("procedure TFrameProceed.GridDataPointsGetValue")
    error_branch = get_value.split(
        "GridDataPoints.Columns[ACol] = StringColumnSpillageError", 1
    )[1].split(
        "GridDataPoints.Columns[ACol] = StringColumnSpillageValid", 1
    )[0]

    assert "GetStrNum(P.Error)" in error_branch
    assert "FloatToStr(P.Error)" in error_branch
    assert "SPS_STOP_CRITERIA_FAILED" not in error_branch
    assert "#$2014" not in error_branch


def test_validity_hint_uses_shared_full_state_text():
    hint = body("function TFrameProceed.GetSpillageResultHint")

    assert "Result := APoint.GetFullStateText" in hint
    assert "APoint.Status" not in hint
    assert "APoint.Validation" not in hint
    assert "SPS_" not in hint
    assert "AppendHintLine" not in hint


def test_proceed_uses_current_validation_model():
    device_hint = body("function TFrameProceed.GetDeviceResultHint")
    summary = body("function TFrameProceed.ResolveDeviceSummaryStatus")
    get_value = body("procedure TFrameProceed.GridDataPointsGetValue")

    assert "SPS_" not in PAS
    assert "Spillage.Validation = vsValid" in device_hint
    assert "Spillage.Validation = vsInvalid" in device_hint
    assert "Spillage.ValidationReason = svrStopCriteriaFailed" in device_hint
    assert "Spillage.Validation = vsInvalid" in summary
    assert "Spillage.ValidationReason = svrStopCriteriaFailed" in summary
    assert "Value := P.GetShortStateText" in get_value


def test_result_point_colors_use_validation_model():
    refresh = body("procedure TFrameProceed.ShowDevicesResults")
    draw = body("procedure TFrameProceed.GridResultsDrawColumnCell")

    assert "Row.PointColors[I] := GetSpillageValidationColor(" in refresh
    assert "Spillage.Validation, Spillage.ValidationReason" in refresh
    assert "Row.PointStatuses" not in refresh
    assert "Color := GridRow.PointColors[PointIdx]" in draw


def test_measurement_grid_keeps_hints_enabled_and_targets_validity_column():
    mouse_move = body("procedure TFrameProceed.GridDataPointsMouseMove")

    assert "FLastDataPointsHintRow" in mouse_move
    assert "GridDataPoints.ShowHint := False" in mouse_move
    assert "GridDataPoints.ShowHint := HintText <> ''" in mouse_move
    assert "GridDataPoints.CellByPoint(X, Y, Col, Row)" in mouse_move
    assert "StringColumnSpillageValid" in mouse_move
    assert "GetSpillageResultHint(Device, FCurrentSpillages[Row])" in mouse_move


def test_right_click_hint_passes_device_and_measurement():
    mouse_down = body("procedure TFrameProceed.GridDataPointsMouseDown")

    assert "GetSpillageResultHint(ResolveSelectedDevice," in mouse_down
    assert "FCurrentSpillages[ARow])" in mouse_down


def test_columns_menu_is_not_rebuilt_while_popup_is_open():
    popup = body("procedure TFrameProceed.PopupMenuGridResultsPopup")

    assert "Children[I].Free" not in popup
    assert "TMenuItem.Create" not in popup
    assert "SameText(Grid.Columns[J].Name, Item.TagString)" in popup


def test_initialize_explicitly_connects_existing_hint_handlers():
    initialize = body("procedure TFrameProceed.Initialize")

    assert "GridResults.OnMouseMove := GridResultsMouseMove" in initialize
    assert "GridDataPoints.OnMouseMove := GridDataPointsMouseMove" in initialize


def test_column_layout_is_keyed_by_name_and_persisted():
    capture = body("procedure TFrameProceed.CaptureGridColumnsLayout")
    save = body("procedure TFrameProceed.SaveLayoutSettingsToWorkTable")
    mouse_up = body("procedure TFrameProceed.GridColumnLayoutMouseUp")

    assert "AColumns[I].Name := AGrid.Columns[I].Name" in capture
    assert "AColumns[I].Position := AGrid.Columns[I].Index" in capture
    assert "AColumns[I].Width := AGrid.Columns[I].Width" in capture
    assert "AColumns[I].Visible := AGrid.Columns[I].Visible" in capture
    assert "FWorkTableManager.Save" in save
    assert "SaveLayoutSettingsToWorkTable" in mouse_up


def test_results_hint_is_rearmed_when_hovered_cell_changes():
    mouse_move = body("procedure TFrameProceed.GridResultsMouseMove")

    assert "FLastResultsHintRow" in mouse_move
    assert "FLastResultsHintCol" in mouse_move
    assert "GridResults.ShowHint := False" in mouse_move
    assert "GridResults.ShowHint := HintText <> ''" in mouse_move
