from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
DEVICE = (ROOT / 'uDeviceClass.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def procedure_body(source: str, start: str, end: str) -> str:
    return source.split(start, 1)[1].split(end, 1)[0]


def test_invalid_completed_spillages_build_summary_columns():
    without_merge = procedure_body(
        PROCEED,
        'procedure TFrameProceed.BuildSummaryColumnsWithoutMerge',
        'procedure TFrameProceed.BuildSummaryResultPointColumns')
    with_merge = procedure_body(
        PROCEED,
        'procedure TFrameProceed.BuildSummaryColumnsWithMerge',
        'procedure TFrameProceed.InitializeResultsGrid')
    for body in (without_merge, with_merge):
        assert 'ASpillage.Validation in [vsValid, vsInvalid]' in body
        assert 'ASpillage.Validation = vsValid' not in body


def test_invalid_completed_spillages_are_display_candidates():
    summary_filter = procedure_body(
        PROCEED,
        'function TFrameProceed.IsValidSummaryResultSpillage',
        'procedure TFrameProceed.LogSummaryResultSelection')
    assert 'ASpillage.Validation in [vsValid, vsInvalid]' in summary_filter
    assert 'not ASpillage.Valid' not in summary_filter

    display_filter = procedure_body(
        DEVICE,
        'function IsDevicePointDisplayErrorCandidate',
        'function TrySelectDevicePointDisplaySpillage')
    assert 'ASpillage.Validation in [vsValid, vsInvalid]' in display_filter
    assert 'ASpillage.Valid and' not in display_filter


def test_exceeded_error_keeps_warning_color():
    color_body = procedure_body(
        PROCEED,
        'function TFrameProceed.GetSpillageErrorResultColor',
        'function TFrameProceed.ResolveDeviceSummaryStatus')
    assert 'svrErrorExceeded:' in color_body
    assert 'Result := COLOR_WARNING' in color_body


def test_failed_result_comment_prioritizes_invalid_point():
    comment_body = procedure_body(
        PROCEED,
        'function TFrameProceed.BuildResultComment',
        'function TFrameProceed.BuildSpillageStatusText')
    exceeded_priority = comment_body.index(
        '(Spillage.ValidationReason = svrErrorExceeded)')
    invalid_priority = comment_body.index(
        '(Spillage.Validation = vsInvalid)')
    generic_reason = comment_body.rindex(
        '(Spillage.ValidationReason <> svrErrorWithinTolerance)')
    assert exceeded_priority < invalid_priority < generic_reason
    assert comment_body.count(
        'Spillage.ValidationReason = svrErrorWithinTolerance') == 1


def test_version():
    assert "APP_VERSION = '1.0.165'" in VERSION
