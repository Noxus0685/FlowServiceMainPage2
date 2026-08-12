from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
DEVICE = (ROOT / "uDeviceClass.pas").read_text(encoding="utf-8")
REPOS = (ROOT / "uRepositories.pas").read_text(encoding="utf-8")
WORK = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8")


def method(source: str, start: str, following: str) -> str:
    return source.split(start, 1)[1].split(following, 1)[0]


def test_measurement_grid_selection_is_mutually_exclusive():
    activate = method(MAIN, "procedure TFrameMainTable.ActivateMeasurementGrid", "procedure TFrameMainTable.GridDevicesEnter")
    devices_enter = method(MAIN, "procedure TFrameMainTable.GridDevicesEnter", "procedure TFrameMainTable.GridEtalonsEnter")
    etalons_enter = method(MAIN, "procedure TFrameMainTable.GridEtalonsEnter", "procedure TFrameMainTable.GridDevicesHeaderClick")
    devices_click = method(MAIN, "procedure TFrameMainTable.GridDevicesCellClick", "procedure TFrameMainTable.ActivateMeasurementGrid")
    etalons_click = method(MAIN, "procedure TFrameMainTable.GridEtalonsCellClick", "procedure TFrameMainTable.GridEtalonsCellDblClick")
    assert "FChangingMeasurementGridFocus" in activate
    assert "OtherGrid.EditorMode := False" in activate
    assert "OtherGrid.Selected := -1" in activate
    assert "OtherGrid.Row := -1" in activate
    assert "ActivateMeasurementGrid(GridDevices)" in devices_enter
    assert "ActivateMeasurementGrid(GridEtalons)" in etalons_enter
    assert devices_click.index("ActivateMeasurementGrid(GridDevices)") < devices_click.index("CanEditActiveWorkTable")
    assert etalons_click.index("ActivateMeasurementGrid(GridEtalons)") < etalons_click.index("CanEditActiveWorkTable")


def test_background_refresh_does_not_change_grid_focus_or_selection():
    for start in (
        "procedure TFrameMainTable.TimerMainTimer",
        "procedure TFrameMainTable.UpdateGrids",
    ):
        body = MAIN.split(start, 1)[1].split("\nprocedure TFrameMainTable.", 1)[0]
        assert "ActivateMeasurementGrid" not in body
        assert ".Selected :=" not in body
        assert ".Row :=" not in body


def test_channel_copy_uses_configuration_only_mode_before_persistence():
    helper = method(DEVICE, "procedure TDevice.AssignWithoutMeasurementHistory", "procedure TCalibrCoefItem.Assign")
    factory = method(REPOS, "function TDeviceRepository.CreateDeviceForChannelCopy", "function TDeviceRepository.GetDevice")
    channel_copy = method(WORK, "procedure TChannel.AssignFlowMeterFrom", "// =====================================================")
    clipboard = method(MAIN, "procedure TFrameMainTable.SaveChannelToClipboard", "procedure TFrameMainTable.ValidateChannelDeviceUUIDs")
    assert "Assign(ASource, False)" in helper
    assert helper.index("FSessions.Clear") > helper.index("Assign(ASource, False)")
    assert helper.index("FSpillages.Clear") > helper.index("Assign(ASource, False)")
    assert "AssignWithoutMeasurementHistory(ASource)" in factory
    assert "CreateDeviceForChannelCopy(SrcDevice)" in channel_copy
    assert "NewDevice.UUID :=" not in channel_copy
    assert "AssignWithoutMeasurementHistory" in clipboard
    assert "PersistDeviceAsync" not in factory + channel_copy + clipboard
    # The legacy method retains its deep-copy behavior for all existing callers.
    legacy = method(DEVICE, "procedure TDevice.Assign(ASource: TDevice; FullAssign: Boolean)", "procedure TDevice.AssignWithoutMeasurementHistory")
    assert "ASource.FSessions" in legacy
    assert "ASource.FSpillages" in legacy


def test_version_1_0_146():
    assert "APP_VERSION = '1.0.148'" in (ROOT / "uAppVersion.pas").read_text(encoding="utf-8")
    project = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8")
    assert project.count("FileVersion=1.0.148.0") == 2
    assert project.count("ProductVersion=1.0.148.0") == 2
