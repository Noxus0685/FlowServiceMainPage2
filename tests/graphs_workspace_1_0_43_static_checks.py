from pathlib import Path
import re

ROOT = Path(__file__).parents[1]
SOURCE = (ROOT / 'frmGraphsWorkspace.pas').read_text(encoding='utf-8-sig')
CONFIG = (ROOT / 'uGraphsViewConfig.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')
FMX = (ROOT / 'frmGraphsWorkspace.fmx').read_text(encoding='utf-8-sig')


def routine(signature, following='\nprocedure TFrameGraphsWorkspace.'):
    start = SOURCE.index(signature)
    end = SOURCE.find(following, start + len(signature))
    return SOURCE[start:] if end < 0 else SOURCE[start:end]


def test_pending_point_state_is_retryable():
    update = routine('procedure TFrameGraphsWorkspace.UpdateSeriesToleranceLines')
    assert 'ToleranceResolveState := gtrsPendingPoint' in update
    assert "TolerancePointKey := ''" in update
    assert 'ToleranceResolveState := gtrsUnavailable' in update
    pending = update[update.index('if not TryGetValidRunPoint'):update.index("LogToleranceEvent('GraphTolerancePointPending'")]
    assert 'ToleranceResolveState := gtrsUnavailable' not in pending


def test_valid_run_point_guards_zero_q_and_allows_pending_index():
    body = routine('function TFrameGraphsWorkspace.TryGetValidRunPoint')
    assert "if ARunPoint.Q = 0 then" in body
    assert "AReason := 'RunTargetQNotAssigned'" in body
    assert 'CurrentPointIndex=-1 is intentionally accepted' in body
    resolver = routine('function TFrameGraphsWorkspace.ResolveSeriesTolerance')
    assert resolver.index('TryGetValidRunPoint') < resolver.index('ResolveSeriesPoint')


def test_point_key_drives_retry_without_tick_rebuild():
    update = routine('procedure TFrameGraphsWorkspace.UpdateSeriesToleranceLines')
    assert 'BuildRunTolerancePointKey' in SOURCE
    assert 'SameText(ARuntime.TolerancePointKey, CurrentPointKey) then Exit' in update
    assert "Reason := 'PointBecameAvailable'" in update
    assert "Reason := 'PointChanged'" in update


def test_hidden_visual_can_become_visible_again():
    hide = routine('procedure TFrameGraphsWorkspace.HideSeriesToleranceVisual')
    update = routine('procedure TFrameGraphsWorkspace.UpdateSeriesToleranceLines')
    assert '.Visible := False' in hide
    assert 'Visual.TargetSeries.Visible := Panel.ShowTargetLine and MainSeriesVisible' in update
    assert 'Visual.LowerSeries.Visible := Panel.ShowToleranceLines and MainSeriesVisible' in update
    assert 'Visual.TargetSeries.Visible :=\n  Visual.TargetSeries.Visible and' not in update


def test_defaults_axis_and_version():
    assert CONFIG.count('ShowTargetLine := True') >= 3
    assert CONFIG.count('ShowToleranceLines := True') >= 3
    axis = routine('procedure TFrameGraphsWorkspace.UpdateIndependentYAxis')
    assert 'Runtime.ToleranceVisual' in axis
    assert 'Visual.TargetSeries' in axis and 'Visual.LowerSeries' in axis and 'Visual.UpperSeries' in axis
    assert 'Slot.TargetSeries' not in axis
    assert "APP_VERSION = '1.0.43';" in VERSION


def test_menu_literals_are_clean_utf8():
    wanted = ('Эталоны','Приборы','Настройки','Цвета','Длина временного окна',
      'Единицы расхода','Показывать легенду','Показывать целевую линию',
      'Показывать границы допуска','Показывать служебные линии в легенде',
      'Компоновка','Добавить график','Удалить график','Очистить значения графика','Очистить график')
    literals = re.findall(r"(?:Text\s*:=|Text\s*=)\s*'([^']*)'", SOURCE + '\n' + FMX)
    joined = '\n'.join(literals)
    for text in wanted:
        assert text in joined
    for bad in ('Рџ','РЎР','Р“С','Р”Р','РћС','РќР','РµР'):
        assert bad not in joined
    for conversion in ('UTF8Decode(', 'UTF8ToString(', 'AnsiToUtf8(',
                       'Utf8ToAnsi(', 'PAnsiChar(', 'RawByteString('):
        assert conversion not in SOURCE
