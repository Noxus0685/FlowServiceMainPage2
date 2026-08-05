from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')


def body_between(start: str, end: str) -> str:
    return PROCEED[PROCEED.index(start):PROCEED.index(end, PROCEED.index(start))]


def test_merged_column_match_ignores_non_flow_identity_fields():
    body = body_between('function TFrameProceed.IsProcessingSpillageInMergedColumn', 'function TFrameProceed.FindResultSpillageForColumn')
    assert 'QavgEtalon' in body
    for forbidden in ['EtalonUUID', 'EtalonName', 'DeviceUUID', 'SessionID', 'SourcePointName', 'SourcePointNum']:
        assert forbidden not in body


def test_summary_merge_uses_valid_enabled_processing_spillages_sorted_by_flow():
    body = body_between('procedure TFrameProceed.BuildSummaryResultPointColumns', 'procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')
    assert 'ASpillage.Enabled and (ASpillage.Validation = vsValid)' in body
    assert 'ProcessingSpillages.Sort' in body
    assert 'CompareValue(Left.QavgEtalon, Right.QavgEtalon)' in body
    assert 'ProcessingSpillages.Add(Spillage)' in body


def test_summary_merge_does_not_group_by_etalon_device_name_num_session():
    body = body_between('if AMergePoints then', 'else\n      begin\n        Col.IsMerged := False')
    assert 'IsProcessingSpillageInMergedColumn(Spillage, Cols[I])' in body
    for forbidden in ['EtalonUUID := Trim', 'EtalonName', 'DeviceUUID := Trim', 'SourcePointNum =', 'SessionID']:
        assert forbidden not in body


def test_summary_merge_diagnostics_and_expected_counts_fields_present():
    body = body_between('procedure TFrameProceed.BuildSummaryResultPointColumns', 'procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')
    assert 'ProcessingSummaryMergeGroup' in body
    for field in ['GroupIndex=%d', 'TargetQ=%s', 'Count=%d', 'SpillageNames=%s', 'QValues=%s', 'EtalonNames=%s']:
        assert field in body
    assert 'MergeEnabled=%s; Source=Spillages; DevicesCount=%d; SpillagesCount=%d; MergedGroupsCount=%d; ColumnsCount=%d' in body
