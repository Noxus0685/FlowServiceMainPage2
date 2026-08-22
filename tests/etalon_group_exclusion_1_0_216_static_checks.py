from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8")


def method(source: str, start: str, end: str) -> str:
    return source[source.index(start):source.index(end, source.index(start) + len(start))]


def test_other_groups_are_disabled_and_active_group_is_preserved():
    disable = method(
        MAIN,
        "procedure TFrameMainTable.DisableOtherChannelGroups",
        "procedure TFrameMainTable.ApplyEnabledChannelSimulationValues",
    )
    assert "(OtherChannel.Group = ActiveGroup) then" in disable
    assert "(OtherChannel.Group <> ActiveGroup) then" not in disable
    assert "OtherChannel.Enabled := False" in disable
    assert "ClearChannelSimulationValues(OtherChannel)" in disable
    assert "PersistChannelEnabled(FActiveWorkTable, OtherChannel, 'Etalon', OldEnabled, False)" in disable


def test_automatic_disable_is_logged_only_for_enabled_channels():
    disable = method(
        MAIN,
        "procedure TFrameMainTable.DisableOtherChannelGroups",
        "procedure TFrameMainTable.ApplyEnabledChannelSimulationValues",
    )
    enabled_block = disable[disable.index("if OldEnabled then"):]
    assert enabled_block.index("EtalonEnabledGroupChange") < enabled_block.index("    end;\n  end;")
    assert "Reason=ExclusiveOtherGroupSelection" in disable
    for field in (
        "WorkTableUUID=", "SelectedChannelUUID=", "SelectedChannelName=",
        "SelectedGroup=", "AffectedChannelUUID=", "AffectedChannelName=",
        "AffectedGroup=", "AffectedOldEnabled=", "AffectedNewEnabled=",
    ):
        assert field in disable


def test_group_recalculation_remains_outside_disable_loop():
    disable = method(
        MAIN,
        "procedure TFrameMainTable.DisableOtherChannelGroups",
        "procedure TFrameMainTable.ApplyEnabledChannelSimulationValues",
    )
    assert "ApplyEnabledChannelSimulationValues" not in disable
    assert "WorkTableManager.Save" not in disable
    assert "Sleep(" not in disable
    assert "ProcessMessages" not in disable


def test_release_version():
    assert "APP_VERSION = '1.0.216';" in VERSION
