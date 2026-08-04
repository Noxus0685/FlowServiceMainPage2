from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")


def build_groups(scenario_groups, device_points):
    """Small contract model of the production participant-identity mapping."""
    groups = [{"scenario": title, "members": dict(members)} for title, members in scenario_groups]
    assigned = {identity for group in groups for identity in group["members"]}
    for identity, title in device_points:
        if identity not in assigned:
            groups.append({"scenario": None, "members": {identity: title}})
    return groups


def test_combined_qa_q1_fraction_is_one_column_with_own_row_results():
    ids = [("125", "qa"), ("124a", "q1"), ("124b", "fraction")]
    groups = build_groups([("common", {item: name for item, name in zip(ids, ("Qa", "Q1", "0,0089Qmax"))})], [])
    saved = {ids[0]: -0.1, ids[1]: 0.2, ids[2]: 0.3}
    assert len(groups) == 1
    assert [saved[item] for item in groups[0]["members"]] == [-0.1, 0.2, 0.3]


def test_uncombined_points_make_three_columns_even_at_equal_flow():
    points = [(('125', 'qa'), 'Qa'), (('124a', 'q1'), 'Q1'), (('124b', 'fraction'), '0,0089Qmax')]
    groups = build_groups([], points)
    assert len(groups) == 3


def test_combined_groups_precede_unparticipating_points():
    groups = build_groups([("common", {("a", "qa"): "Qa", ("b", "q1"): "Q1"})], [(('c', 'own'), 'Own')])
    assert [group["scenario"] for group in groups] == ["common", None]


def test_equal_flow_without_shared_participant_identity_does_not_merge():
    groups = build_groups([], [(('a', 'same-flow'), 'Q'), (('b', 'same-flow'), 'Q')])
    assert len(groups) == 2


def test_different_names_and_types_merge_through_source_uuid_participants():
    groups = build_groups([("scenario", {("a", "source-1"): "Qa", ("b", "source-2"): "Q1"})], [])
    assert len(groups) == 1


def test_nine_separate_or_three_production_groups():
    names = ("Qa", "Qb", "Qc", "Q1", "Q2", "Q3", "0,0089Qmax", "0,0891Qmax", "0,8908Qmax")
    points = [((str(i // 3), str(i)), name) for i, name in enumerate(names)]
    assert len(build_groups([], points)) == 9
    merged = [(f"flow-{i}", {points[i][0]: points[i][1], points[i+3][0]: points[i+3][1], points[i+6][0]: points[i+6][1]}) for i in range(3)]
    assert len(build_groups(merged, [])) == 3


def test_source_implements_group_rebuild_and_direct_row_binding():
    assert "TDisplayPointGroup = class" in SOURCE
    assert "Participants: TList<TDisplayPointParticipant>" in SOURCE
    assert SOURCE.index("AddScenarioDisplayPoint(MeasurementRun.Points[I])") < SOURCE.index("AddStandaloneDisplayPoint(Device, Point)")
    assert "SameText(Participant.SourcePointUUID, APoint.UUID)" in SOURCE
    assert "ADevicePoint := FindDevicePoint(Device, AGroup)" in SOURCE
    assert "ASpillage := FindPointSpillage(Device, ADevicePoint)" in SOURCE
    assert SOURCE.count("UpdateUI;") >= 4
    get_value = SOURCE[SOURCE.index("procedure TFrameMRResults.GridMRResultsGetValue"):]
    assert "BuildColumns" not in get_value


def test_repeated_update_rebuilds_without_stale_or_duplicate_groups():
    update = SOURCE[SOURCE.index("procedure TFrameMRResults.UpdateUI"):SOURCE.index("procedure TFrameMRResults.BuildRows")]
    columns = SOURCE[SOURCE.index("procedure TFrameMRResults.BuildColumns"):SOURCE.index("function TFrameMRResults.PointBelongsToDisplayGroup")]
    assert "BuildColumns;" in update
    assert "FDisplayPoints.Clear;" in columns
    assert "while GridMRResults.ColumnCount > 2" in columns
