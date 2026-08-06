from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.75'" in VERSION
assert 'procedure BuildSummaryColumnsWithoutMerge(const ADevices: TList<TDevice>);' in PROCEED
assert 'procedure BuildSummaryColumnsWithMerge(const ADevices: TList<TDevice>);' in PROCEED
wrapper = PROCEED[PROCEED.index('procedure TFrameProceed.BuildSummaryResultPointColumns'):PROCEED.index('procedure TFrameProceed.BuildSummaryColumnsWithMerge')]
assert 'BuildSummaryColumnsWithMerge(ADevices)' in wrapper
assert 'BuildSummaryColumnsWithoutMerge(ADevices)' in wrapper
without = PROCEED[PROCEED.index('procedure TFrameProceed.BuildSummaryColumnsWithoutMerge'):PROCEED.index('procedure TFrameProceed.BuildSummaryResultPointColumns')]
assert 'Col.IsMerged := False' in without
assert 'Col.DeviceUUID := Trim(SelectedSpillage.DeviceUUID)' in without
assert 'Col.SourcePointUUID := SourcePointUUID' in without
assert "Result := AnsiUpperCase(Trim(ADeviceUUID)) + '|UUID:'" in without
assert "'|Q:' + FormatFloat('0.##########', AQavgEtalon)" in without
assert 'SelectBestSpillageByAbsoluteError' in without
assert 'Abs(Item.Error) < Abs(Result.Error)' in without
assert 'Col.GroupedSpillages := GroupSpillages.ToArray' in without
assert 'Col.SelectedSpillage := SelectedSpillage' in without
assert 'SummaryPointGrouping' in without
assert 'Groups.TryGetValue(GroupKey, GroupSpillages)' in without
for forbidden in ('TryMergePointRanges', 'CalculatePointFlowRange', 'ProcessingSummaryMergeGroup', 'IsProcessingSpillageInMergedColumn'):
    assert forbidden not in without
with_merge = PROCEED[PROCEED.index('procedure TFrameProceed.BuildSummaryColumnsWithMerge'):PROCEED.index('procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')]
assert 'TryMergePointRanges' in with_merge
assert 'ProcessingSummaryMergeGroup' in with_merge
assert 'Mode=Merge' in with_merge
assert 'Col.IsMerged := True' in with_merge
