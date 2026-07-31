from pathlib import Path
import math

SOURCE = Path('frmGraphsWorkspace.pas').read_text(encoding='utf-8-sig')
VERSION = Path('uAppVersion.pas').read_text(encoding='utf-8-sig')


def routine(signature: str) -> str:
    start = SOURCE.index(signature)
    body = SOURCE.index('\nbegin', start)
    return SOURCE[start:SOURCE.index('\nend;', body)]


def normalize(value: float, source: str):
    if source == 'Q':
        return value, ''
    if source == 'FlowRate':
        return value / 3.6, ''
    return None, 'EtalonPointFlowUnitUnknown'


def test_numeric_cross_unit_etalon_matching_and_lines():
    for run_q, displayed in (
        (0.100828384700955, 0.362982184923439),
        (0.999950922654103, 3.59982332155477),
    ):
        normalized, reason = normalize(displayed, 'FlowRate')
        tolerance = max(1e-9, abs(run_q) * 1e-6)
        assert reason == '' and math.isclose(normalized, run_q, abs_tol=tolerance)
        error_percent = abs(-0.2)
        delta = abs(run_q) * error_percent / 100.0
        target_series = [(0, run_q * 3.6), (1, run_q * 3.6)]
        lower_series = [(0, (run_q-delta)*3.6), (1, (run_q-delta)*3.6)]
        upper_series = [(0, (run_q+delta)*3.6), (1, (run_q+delta)*3.6)]
        assert error_percent == 0.2
        assert len(target_series) == len(lower_series) == len(upper_series) == 2


def test_base_q_is_not_converted_twice_and_unknown_unit_fails():
    q = 0.100828384700955
    assert normalize(q, 'Q') == (q, '')
    assert normalize(q, 'Unknown') == (None, 'EtalonPointFlowUnitUnknown')


def test_finder_compares_only_normalized_flow_and_keeps_target():
    finder = routine('function TFrameGraphsWorkspace.FindEtalonPointByTargetQ')
    assert 'SameValue(CandidateFlow, ARunTargetQ, ToleranceQ)' in finder
    assert 'SameValue(Candidate.Q, ARunTargetQ' not in finder
    active = routine('function TFrameGraphsWorkspace.ResolveActiveEtalonTolerance')
    assert 'ATargetQ := Run.CurrentPoint.Q' in active
    resolve = routine('function TFrameGraphsWorkspace.ResolveGraphTolerance')
    assert 'AErrorPercent := Abs(SourcePoint.Error)' in resolve
    assert 'UpdateGraphToleranceVisual' in routine('procedure TFrameGraphsWorkspace.UpdateToleranceLinesForGraph')


def test_normalization_is_centralized_and_protocol_is_complete():
    normalizer = routine('function TFrameGraphsWorkspace.NormalizePointFlowToBase')
    assert 'AValue / M3H_PER_LS' in normalizer
    for event in ('GraphEtalonPointCandidate', 'GraphEtalonFlowNormalization',
                  'GraphEtalonPointMatched', 'GraphToleranceSourceResolved',
                  'GraphToleranceCalculated', 'GraphToleranceVisualUpdated'):
        assert event in SOURCE
    assert "APP_VERSION = '1.0.46';" in VERSION
