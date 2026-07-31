from pathlib import Path
import math

SOURCE = Path('frmGraphsWorkspace.pas').read_text(encoding='utf-8-sig')
VERSION = Path('uAppVersion.pas').read_text(encoding='utf-8-sig')

def routine(signature: str) -> str:
    start = SOURCE.index(signature)
    body = SOURCE.index('\nbegin', start)
    end = SOURCE.index('\nend;', body)
    return SOURCE[start:end]

def test_one_graph_level_tolerance_set_and_no_runtime_work_path():
    slot = SOURCE[SOURCE.index('TGraphVisualSlot = class'):SOURCE.index('TGraphColumnMenuItem = class')]
    assert slot.count('TargetSeries: TChartSeries') == 1
    assert slot.count('LowerSeries: TChartSeries') == 1
    assert slot.count('UpperSeries: TChartSeries') == 1
    update = routine('procedure TFrameGraphsWorkspace.UpdateToleranceLinesForGraph')
    assert 'ResolveGraphTolerance' in update
    assert 'UpdateGraphToleranceVisual' in update
    assert not any(name in update for name in ('Runtime.ToleranceVisual', 'ResolveSeriesTolerance', 'RecreateSeriesRuntime'))

def test_etalon_source_is_direct_channel_device_and_q_lookup():
    active = routine('function TFrameGraphsWorkspace.GetActiveEtalonChannel')
    resolve = routine('function TFrameGraphsWorkspace.ResolveActiveEtalonTolerance')
    finder = routine('function TFrameGraphsWorkspace.FindPointByTargetQ')
    assert 'FWorkTable.EtalonChannels[I]' in active and 'Channel.Enabled' in active
    assert 'Device := AChannel.FlowMeter.Device' in resolve
    assert 'FindPointByTargetQ(Device, ATargetQ' in resolve
    assert 'SameValue(Point.Q, ATargetQ, ToleranceQ)' in finder
    assert 'UUID' not in finder

def test_device_calculation_and_common_axis_scaling_are_preserved():
    resolve = routine('function TFrameGraphsWorkspace.ResolveGraphTolerance')
    axis = routine('procedure TFrameGraphsWorkspace.UpdateIndependentYAxis')
    assert 'ATargetQ := RunPoint.Q' in resolve
    assert 'AErrorPercent := Abs(SourcePoint.Error)' in resolve
    assert 'ToleranceValue := Abs(ATargetQ) * Abs(AErrorPercent) / 100.0' in resolve
    assert all(x in axis for x in ('Slot.TargetSeries', 'Slot.LowerSeries', 'Slot.UpperSeries'))

def test_expected_display_regressions():
    q = 0.100828384700955
    conv = lambda value: value * 3.6
    target = conv(q)
    etalon_delta = abs(q) * .2 / 100
    device_delta = abs(q) * 2 / 100
    assert math.isclose(target, .362982184923438, abs_tol=1e-12)
    assert math.isclose(conv(q-etalon_delta), .362256220553591, abs_tol=1e-12)
    assert math.isclose(conv(q+etalon_delta), .363708149293285, abs_tol=1e-12)
    assert math.isclose(conv(q-device_delta), .355722541224969, abs_tol=1e-12)
    assert math.isclose(conv(q+device_delta), .370241828621907, abs_tol=1e-12)

def test_protocol_and_version_1_0_45():
    for event in ('GraphToleranceResolveBegin', 'GraphToleranceSourceResolved',
                  'GraphToleranceCalculated', 'GraphToleranceVisualUpdated',
                  'GraphToleranceSourceUnavailable'):
        assert event in SOURCE
    assert "APP_VERSION = '1.0.45';" in VERSION
