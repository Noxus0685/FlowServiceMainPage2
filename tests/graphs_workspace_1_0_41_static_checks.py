from pathlib import Path
import math

ROOT = Path(__file__).parents[1]
SOURCE = (ROOT / 'frmGraphsWorkspace.pas').read_text(encoding='utf-8-sig')
CONFIG = (ROOT / 'uGraphsViewConfig.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def routine(signature, following='\nprocedure TFrameGraphsWorkspace.'):
    start = SOURCE.index(signature)
    end = SOURCE.find(following, start + len(signature))
    return SOURCE[start:] if end < 0 else SOURCE[start:end]


def test_series_runtime_owns_individual_tolerance_visual():
    assert 'ToleranceVisual: TGraphToleranceVisual' in SOURCE
    assert all(field in SOURCE for field in ('TolerancePointKey: string',
        'ToleranceTargetQ: Double', 'ToleranceErrorPercent: Double'))
    assert 'ARuntime.ToleranceVisual := Result' in SOURCE


def test_series_point_is_resolved_within_owning_channel_device():
    body = routine('function TFrameGraphsWorkspace.ResolveSeriesPoint')
    assert 'Channel := ResolveChannel(ASeriesConfig)' in body
    assert 'ADevice := Channel.FlowMeter.Device' in body
    assert 'ADevice.Points[Run.CurrentPointIndex]' in body
    assert 'SameValue(Candidate.Q, Run.CurrentPoint.Q, Epsilon)' in body


def test_tolerance_uses_source_point_q_and_error():
    body = routine('function TFrameGraphsWorkspace.ResolveSeriesTolerance')
    assert 'AInfo.TargetQ := AInfo.SourcePoint.Q' in body
    assert 'AInfo.ErrorPercent := Abs(AInfo.SourcePoint.Error)' in body
    assert 'Run.CurrentPoint.Error' not in body
    assert 'Abs(AInfo.TargetQ) * Abs(AInfo.ErrorPercent) / 100.0' in body


def test_known_tolerance_values_are_independent():
    target = 0.3629821849
    def bounds(error):
        tolerance = abs(target) * abs(error) / 100.0
        return target - tolerance, target + tolerance
    assert all(math.isclose(a, b, abs_tol=5e-11) for a, b in zip(
        bounds(2), (0.3557225412, 0.3702418286)))
    assert all(math.isclose(a, b, abs_tol=5e-11) for a, b in zip(
        bounds(.2), (0.3622562206, 0.3637081493)))
    assert bounds(2) != bounds(.2)


def test_updates_each_config_and_never_archives_service_series():
    body = routine('procedure TFrameGraphsWorkspace.UpdateToleranceLinesForGraph')
    assert 'for SeriesConfig in FConfig.Panels[AGraphIndex].Series do' in body
    assert 'UpdateSeriesToleranceLines(AGraphIndex, SeriesConfig, Runtime)' in body
    assert 'FSegmentHistory' not in routine(
        'procedure TFrameGraphsWorkspace.UpdateSeriesToleranceLines')


def test_legend_setting_and_version():
    assert 'ShowToleranceInLegend: Boolean' in CONFIG
    assert 'ShowToleranceInLegend := True' in CONFIG
    assert "APP_VERSION = '1.0.41';" in VERSION
