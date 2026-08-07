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


def test_summary_merge_selects_one_best_repeat_per_device_physical_point():
    body = body_between('procedure TFrameProceed.BuildSummaryColumnsWithMerge', 'procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')
    assert 'ASpillage.Enabled and (ASpillage.Validation = vsValid)' in body
    assert 'BuildPhysicalPointKey' in body
    assert "AnsiUpperCase(OwnerDeviceUUID) + '|UUID:'" in body
    assert "AnsiUpperCase(OwnerDeviceUUID) + '|POINT:'" in body
    assert 'SelectBestPhysicalPointSpillage' in body
    assert 'Abs(Item.Error) < Abs(Result.Error)' in body
    assert 'ProcessingSpillages.Add(SelectedSpillage)' in body
    assert 'ProcessingSpillages.Sort' in body
    assert 'CompareValue(Left.QavgEtalon, Right.QavgEtalon)' in body


def test_summary_merge_does_not_group_by_etalon_device_name_num_session():
    body = body_between('procedure TFrameProceed.BuildSummaryColumnsWithMerge', 'procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')
    assert 'TryMergePointRanges(Cols[I].CommonMinQ' in body
    assert 'else\n        begin\n          Col.IsMerged := True;' in body
    for forbidden in ['EtalonUUID := Trim', 'EtalonName :=', 'SourcePointNum =', 'SessionID :=']:
        assert forbidden not in body


def test_summary_merge_diagnostics_and_expected_counts_fields_present():
    body = body_between('procedure TFrameProceed.BuildSummaryColumnsWithMerge', 'procedure TFrameProceed.NormalizeResultsPointColumnsVisibility')
    assert 'ProcessingSummaryMergeGroup' in body
    for field in ['GroupIndex=%d', 'TargetQ=%s', 'Count=%d', 'SpillageNames=%s', 'QValues=%s', 'EtalonNames=%s']:
        assert field in body
    assert 'MergeEnabled=%s; Source=Spillages; DevicesCount=%d; SourceSpillagesCount=%d; SelectedSpillagesCount=%d; MergedGroupsCount=%d; ColumnsCount=%d' in body
    assert 'SummaryColumnsSource=BestPhysicalPointSpillages' in body
