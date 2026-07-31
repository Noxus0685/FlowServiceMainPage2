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


def test_delphi_loop_and_resolver_variables_are_local():
    destructor = routine('destructor TGraphToleranceVisual.Destroy')
    assert 'procedure RemoveItem(AItem: TChartSeries);\n  var\n    I: Integer;' in destructor
    point_resolver = routine('function TFrameGraphsWorkspace.ResolveSeriesPoint')
    assert 'RunPoint: TDevicePoint;' in point_resolver
    tolerance_resolver = routine(
        'function TFrameGraphsWorkspace.ResolveSeriesTolerance')
    assert 'SourceDevice: TDevice;' in tolerance_resolver
    assert 'SourcePoint: TDevicePoint;' in tolerance_resolver
    assert 'SourcePointIndex: Integer;' in tolerance_resolver


def test_series_point_is_resolved_within_owning_channel_device():
    body = routine('function TFrameGraphsWorkspace.ResolveSeriesPoint')
    assert 'Channel := ResolveChannel(ASeriesConfig)' in body
    assert 'ADevice := Channel.FlowMeter.Device' in body
    assert 'ADevice.Points[Run.CurrentPointIndex]' in body
    assert 'SameValue(Candidate.Q, RunPoint.Q, Epsilon)' in body


def test_tolerance_uses_source_point_q_and_error():
    body = routine('function TFrameGraphsWorkspace.ResolveSeriesTolerance')
    assert 'AInfo.TargetQ := SourcePoint.Q' in body
    assert 'AInfo.ErrorPercent := Abs(SourcePoint.Error)' in body
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
    assert "APP_VERSION = '1.0.42';" in VERSION



def test_etalon_resolution_uses_target_q_not_device_point_uuid():
    dispatcher = routine('function TFrameGraphsWorkspace.ResolveSeriesPoint')
    assert 'gsokEtalon:' in dispatcher
    assert 'ResolveEtalonSeriesPoint' in dispatcher
    body = routine('function TFrameGraphsWorkspace.ResolveEtalonSeriesPoint')
    assert 'FindEtalonPointByTargetQ(ADevice, RunPoint.Q' in body
    assert 'NormalizeUUID' not in body
    assert 'SeriesPointUUIDMismatch' not in body


def test_etalon_duplicate_q_selection_never_uses_index_alone():
    body = routine('function TFrameGraphsWorkspace.FindEtalonPointByTargetQ')
    q_check = body.index('SameValue(Candidate.Q, ATargetQ, ToleranceQ)')
    index_choice = body.index('ARunPointIndex >= 0')
    assert q_check < index_choice
    assert 'SameValue(ADevice.Points[ARunPointIndex].Q, ATargetQ, ToleranceQ)' in body
    assert 'NamedIndex' in body and 'FirstIndex' in body


def test_etalon_target_and_error_sources_are_independent():
    body = routine('function TFrameGraphsWorkspace.ResolveSeriesTolerance')
    etalon = body[body.index('if ASeriesConfig.OwnerKind = gsokEtalon then'):]
    assert 'AInfo.TargetQ := RunPoint.Q' in etalon
    assert 'AInfo.ErrorPercent := Abs(SourcePoint.Error)' in etalon
    assert "AInfo.SourceKind := 'EtalonPointByQ'" in etalon
    assert 'Run.CurrentPoint.Error' not in body


def test_etalon_bounds_for_point_two_tenths_percent():
    target = 3.6
    tolerance = abs(target) * .2 / 100.0
    assert math.isclose(target - tolerance, 3.5928)
    assert math.isclose(target + tolerance, 3.6072)


def test_missing_tolerance_does_not_hide_main_series_and_visual_is_reused():
    update = routine('procedure TFrameGraphsWorkspace.UpdateSeriesToleranceLines')
    clear = routine('procedure TFrameGraphsWorkspace.ClearSeriesToleranceLines')
    ensure = routine('function TFrameGraphsWorkspace.EnsureSeriesToleranceVisual')
    assert 'ARuntime.ChartSeries.Visible :=' not in clear
    assert 'ARuntime.ChartSeries.Visible :=' not in update
    assert 'if ARuntime.ToleranceVisual <> nil then Exit(ARuntime.ToleranceVisual)' in ensure
    assert 'ARuntime.ChartSeries.Visible' in update


def test_etalon_protocol_and_version_are_current():
    for event in ('GraphEtalonToleranceResolveBegin',
                  'GraphEtalonToleranceSourceResolved',
                  'GraphEtalonToleranceCalculated',
                  'GraphEtalonToleranceSourceUnavailable'):
        assert event in SOURCE
    assert "APP_VERSION = '1.0.42';" in VERSION
