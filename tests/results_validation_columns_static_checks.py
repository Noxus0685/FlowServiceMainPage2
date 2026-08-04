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


def test_validity_hint_uses_status_reason_and_detailed_message():
    hint = body("function TFrameProceed.GetSpillageResultHint")

    assert "Reason := Trim(APoint.StatusStr)" in hint
    assert "ValidationReason и ValidationMessage" in hint
    assert "AppendHintLine('Годен.')" in hint
    assert "AppendHintLine('Не годен.')" in hint
    assert "Погрешность находится в допустимых пределах." in hint
    assert "превышает допустимое значение" in hint
    assert "Метрологический результат ещё не определён." in hint


def test_measurement_grid_keeps_hints_enabled_and_targets_validity_column():
    mouse_move = body("procedure TFrameProceed.GridDataPointsMouseMove")

    assert "GridDataPoints.ShowHint := True" in mouse_move
    assert "GridDataPoints.CellByPoint(X, Y, Col, Row)" in mouse_move
    assert "StringColumnSpillageValid" in mouse_move
    assert "GetSpillageResultHint(Device, FCurrentSpillages[Row])" in mouse_move
