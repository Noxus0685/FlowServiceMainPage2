from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAS_PATH = ROOT / "frmGraphsWorkspace.pas"
FMX_PATH = ROOT / "frmGraphsWorkspace.fmx"
SOURCE = PAS_PATH.read_text(encoding="utf-8-sig")
FMX = FMX_PATH.read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def routine(signature: str) -> str:
    start = SOURCE.index(signature)
    candidates = [SOURCE.find(marker, start + len(signature)) for marker in
                  ("\nprocedure TFrameGraphsWorkspace.", "\nfunction TFrameGraphsWorkspace.")]
    candidates = [p for p in candidates if p >= 0]
    return SOURCE[start:min(candidates)] if candidates else SOURCE[start:]


def test_run_current_point_is_authoritative():
    body = routine("function TFrameGraphsWorkspace.ResolveToleranceSource")
    current = body.index("RunPoint := Run.CurrentPoint")
    direct = body.index("if IsValidTolerancePoint(RunPoint)", current)
    indexed = body.index("IndexedPoint := Device.Points[Run.CurrentPointIndex]")
    assert direct < indexed
    assert "SetSource(nil, RunPoint, Run.CurrentPointIndex, 'RunCurrentPoint')" in body
    assert "if not PointsMatch(RunPoint, IndexedPoint)" in body
    assert "DevicePointIndexMismatch" in body


def test_tolerance_math_uses_only_point_values():
    body = routine("function TFrameGraphsWorkspace.ResolvePointTolerance")
    assert "ATarget := SourceInfo.TargetQ" in body
    assert "AErrorPercent := SourceInfo.ErrorPercent" in body
    assert "ToleranceValue := Abs(ATarget) * Abs(AErrorPercent) / 100.0" in body
    assert "FlowAccuracy" not in body
    q, error = 0.1008283847, 5.0
    tolerance = abs(q) * abs(error) / 100.0
    assert abs((q - tolerance) * 3.6 - 0.344833) < 1e-6
    assert abs(q * 3.6 - 0.362982) < 1e-6
    assert abs((q + tolerance) * 3.6 - 0.381131) < 1e-6


def test_point_transitions_and_diagnostics_are_explicit():
    update = routine("procedure TFrameGraphsWorkspace.UpdateToleranceLines")
    assert "if IsPointTransitionStage then" in update
    assert "GraphTolerancePointChanged" in update
    assert "FLastTolerancePointKey := NewPointKey" in update
    for event in ("GraphToleranceSourceResolved", "GraphTolerancePointRejected",
                  "GraphTolerancePointChanged", "GraphPointToleranceResolved"):
        assert event in SOURCE
    for field in ("TargetQ", "ErrorPercent", "Lower", "Upper",
                  "DisplayTarget", "DisplayLower", "DisplayUpper"):
        assert field in update


def test_graph_sources_are_utf8_bom_without_mojibake_or_manual_recoding():
    assert PAS_PATH.read_bytes().startswith(b"\xef\xbb\xbf")
    assert FMX_PATH.read_bytes().startswith(b"\xef\xbb\xbf")
    ui = SOURCE + FMX
    for damaged in ("Рџ", "Р“С", "РЎР"):
        # The diagnostic recognizer intentionally names two patterns.
        assert damaged not in FMX
    for conversion in ("UTF8Decode(", "AnsiToUtf8(", "Utf8ToAnsi("):
        assert conversion not in ui
    for caption in ("Компоновка", "Автоматически", "Очистить все", "Сброс",
                    "Эталоны", "Приборы", "Настройки", "Цвета",
                    "Очистить значения графика", "Целевой расход",
                    "Нижняя допустимая граница", "Верхняя допустимая граница"):
        assert caption in ui


def test_version_is_1_0_40():
    assert "APP_VERSION = '1.0.40';" in VERSION


def test_delphi_control_units_and_nested_loop_variables_are_valid():
    assert "FMX.Layouts, FMX.ListBox, FMX.Menus" in SOURCE
    resolver = routine("function TFrameGraphsWorkspace.ResolveToleranceSource")
    assert resolver.count("LocalChannel: TChannel;") == 2
    assert resolver.count("for LocalChannel in FWorkTable.DeviceChannels do") == 2
