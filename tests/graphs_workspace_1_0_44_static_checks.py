from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = (ROOT / 'frmGraphsWorkspace.pas').read_text(encoding='utf-8-sig')
CONFIG = (ROOT / 'uGraphsViewConfig.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def routine(signature: str) -> str:
    start = WORKSPACE.index(signature)
    next_proc = WORKSPACE.find('\nprocedure TFrameGraphsWorkspace.', start + len(signature))
    next_func = WORKSPACE.find('\nfunction TFrameGraphsWorkspace.', start + len(signature))
    stops = [x for x in (next_proc, next_func) if x >= 0]
    return WORKSPACE[start:min(stops) if stops else len(WORKSPACE)]


def test_canonical_identity_contains_channel_uuid():
    assert 'IdentityKey: string;' in CONFIG
    assert "Format('%d|%d|%s|%s'" in CONFIG
    assert 'NormalizeGraphUUID(AChannelUUID)' in CONFIG


def test_runtime_binding_is_validated_before_updates():
    update = routine('procedure TFrameGraphsWorkspace.UpdateGraphs')
    assert 'IsRuntimeBoundToSeries(GraphIndex, Config, Runtime)' in update
    assert 'RecreateSeriesRuntime(GraphIndex, Config)' in update
    runtime = routine('function TFrameGraphsWorkspace.IsRuntimeBoundToSeries')
    for reason in ('IdentityKeyMismatch', 'GraphIndexMismatch', 'OwnerKindMismatch',
                   'ChannelUUIDMismatch', 'MeterValueKeyMismatch', 'ChartMismatch',
                   'ToleranceVisualMismatch'):
        assert reason in runtime


def test_refresh_uses_identity_and_never_rebinds_uuid():
    refresh = routine('procedure TFrameGraphsWorkspace.RefreshEnabledSources')
    assert 'FindSeriesByIdentity(GraphIndex, AOwner' in refresh
    assert 'Existing.ChannelUUID :=' not in refresh
    assert 'ValidateGraphRuntimeBindings(GraphIndex)' in refresh
    assert 'RemoveOrphanSeriesRuntime' in refresh


def test_tolerance_rejects_cross_channel_results():
    etalon = routine('function TFrameGraphsWorkspace.ResolveEtalonSeriesPoint')
    assert 'EtalonChannelIdentityMismatch' in etalon
    tolerance = routine('function TFrameGraphsWorkspace.ResolveSeriesTolerance')
    assert 'ResolvedChannelUUIDMismatch' in tolerance
    assert 'ToleranceResultChannelMismatch' in tolerance
    update = routine('procedure TFrameGraphsWorkspace.UpdateSeriesToleranceLines')
    assert 'IsRuntimeBoundToSeries(AGraphIndex, ASeriesConfig, ARuntime)' in update


def test_disabled_channel_cannot_retry_tolerance():
    update = routine('procedure TFrameGraphsWorkspace.UpdateToleranceLinesForGraph')
    assert '(Channel = nil) or not Channel.Enabled or not SeriesConfig.Visible' in update
    assert 'HideSeriesToleranceVisual(Runtime)' in update


def test_runtime_and_tolerance_visual_are_recreated_together():
    recreate = routine('procedure TFrameGraphsWorkspace.RecreateSeriesRuntime')
    assert 'RemoveRuntimeSeries(ASeriesConfig, Chart)' in recreate
    assert 'Runtime.ChannelUUID := NormalizeUUID(ASeriesConfig.ChannelUUID)' in recreate
    assert 'EnsureSeriesToleranceVisual(AGraphIndex, ASeriesConfig, Runtime)' in recreate
    assert "Runtime.TolerancePointKey := ''" in recreate
    assert 'Runtime.HistoryLoaded := False' in recreate


def test_version_1_0_44():
    assert "APP_VERSION = '1.0.44';" in VERSION
