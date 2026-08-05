from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.73'" in VERSION
assert 'procedure BuildSummaryColumnsWithoutMerge(const ADevices: TList<TDevice>);' in PROCEED
assert 'procedure BuildSummaryColumnsWithMerge(const ADevices: TList<TDevice>);' in PROCEED
wrapper = PROCEED[PROCEED.index('procedure TFrameProceed.BuildSummaryResultPointColumns'):PROCEED.index('procedure TFrameProceed.BuildSummaryColumnsWithMerge')]
assert 'BuildSummaryColumnsWithMerge(ADevices)' in wrapper
assert 'BuildSummaryColumnsWithoutMerge(ADevices)' in wrapper
without = PROCEED[PROCEED.index('procedure TFrameProceed.BuildSummaryColumnsWithoutMerge'):PROCEED.index('procedure TFrameProceed.BuildSummaryResultPointColumns')]
assert 'Col.IsMerged := False' in without
assert 'Col.DeviceUUID := DeviceUUID' in without
assert 'Col.SourcePointUUID := SourcePointUUID' in without
assert "PointKey := AnsiUpperCase(DeviceUUID) + '|UUID:'" in without
assert 'SeenKeys.ContainsKey(PointKey)' in without
for forbidden in ('TryMergePointRanges', 'CalculatePointFlowRange', 'ProcessingSummaryMergeGroup', 'IsProcessingSpillageInMergedColumn'):
    assert forbidden not in without
with_merge = PROCEED[PROCEED.index('procedure TFrameProceed.BuildSummaryColumnsWithMerge'):PROCEED.index('procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')]
assert 'TryMergePointRanges' in with_merge
assert 'ProcessingSummaryMergeGroup' in with_merge
assert 'Col.IsMerged := True' in with_merge
