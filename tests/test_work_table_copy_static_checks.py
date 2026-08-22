from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
WORK_TABLE = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8")
MAIN_FORM = (ROOT / "fuMain.pas").read_text(encoding="utf-8")
MAIN_FRAME = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")


def body(source: str, qualified_name: str) -> str:
    match = re.search(
        rf"(?:procedure|function) {re.escape(qualified_name)}\b(.*?)"
        rf"(?=\n(?:procedure|function)\s+[A-Z]\w+\.|\nend\.)",
        source,
        re.S,
    )
    assert match, qualified_name
    return match.group(1)


def test_copy_uses_the_single_history_free_channel_clone_path():
    copy_body = body(WORK_TABLE, "TWorkTableManager.CopyWorkTable")
    clone_body = body(WORK_TABLE, "TWorkTableManager.CloneChannelForWorkTable")
    assert "AssignFlowMeterFrom" not in copy_body
    assert copy_body.count("CloneChannelForWorkTable(SourceChannel, Result, NextID)") == 2
    assert "AssignFlowMeterFrom(ASourceChannel, ADestinationWorkTable, True)" in clone_body
    assert "AssignFlowMeterFrom(SourceChannel, Result, False)" not in WORK_TABLE
    assert "Result.ClearRuntimeMeasurements" in clone_body
    assert "Result.EtalonChannels.Add(NewChannel)" in copy_body
    assert "Result.DeviceChannels.Add(NewChannel)" in copy_body


def test_copied_devices_are_independent_and_invariants_are_logged():
    clone_body = body(WORK_TABLE, "TWorkTableManager.CloneChannelForWorkTable")
    copy_body = body(WORK_TABLE, "TWorkTableManager.CopyWorkTable")
    assert "CreateDeviceForChannelCopy" in WORK_TABLE
    assert "ClonedDevice.UUID := NewUUID" in clone_body
    assert "not SameText(DestinationDevice.UUID, SourceDevice.UUID)" in copy_body
    assert "DestinationChannels[J].WorkTabeID = NextID" in copy_body
    assert "WorkTableCopyInvariantFailed" in copy_body
    assert "RemoveClonedDevices" in copy_body
    assert "DeleteDeviceCascade" not in copy_body
    assert "ActiveDeviceRepo.DeleteDevice(Device)" in copy_body
    assert "WorkTableCopyCompleted" in copy_body
    for field in ("SourceWorkTableUUID", "NewWorkTableUUID", "SourceEtalonCount",
                  "NewEtalonCount", "SourceDeviceCount", "NewDeviceCount",
                  "ClonedDeviceCount"):
        assert field in copy_body


def test_copy_availability_has_safe_states_and_excludes_active_measurement():
    can_copy = body(WORK_TABLE, "TWorkTableManager.CanCopyWorkTable")
    for state in ("swtNONE", "swtSTANDBY", "swtCONNECTED", "swtCONFIGED",
                  "swtCOMPLETE", "swtFAILURE"):
        assert state in can_copy
    assert "MeasurementRunStage in [msNone, msDone]" in can_copy
    assert "IsSimulationMode" not in can_copy


def test_popup_source_and_new_tab_activation_are_uuid_driven():
    resolver = body(MAIN_FRAME, "TFrameMainTable.ActiveTabWorkTable")
    popup = body(MAIN_FORM, "TFormMain.WorkTableForGridPopup")
    click = body(MAIN_FORM, "TFormMain.CopyWorkTableClick")
    assert "ResolveWorkTableForTab(TabControlWorkTables.ActiveTab)" in resolver
    assert "WorkTableManager.WorkTables.IndexOf(Result)" in resolver
    assert "FFrameMainTable.ActiveTabWorkTable" in popup
    assert "TabIndex" not in popup
    assert "FindComponent" not in click
    assert "SyncWorkTableTabs" in click
    assert "SelectWorkTable(NewWorkTable)" in click


def test_menu_enabled_state_is_recomputed_for_both_popups_and_periodically():
    update = body(MAIN_FORM, "TFormMain.UpdateCopyWorkTableMenuState")
    devices_popup = body(MAIN_FORM, "TFormMain.DevicesGridPopup")
    etalons_popup = body(MAIN_FORM, "TFormMain.EtalonsGridPopup")
    timer = body(MAIN_FORM, "TFormMain.TimerSetValuesTimer")
    assert "WorkTableForGridPopup" in update
    assert "FCopyDevicesMenuItem.Enabled := CanCopy" in update
    assert "FCopyEtalonsMenuItem.Enabled := CanCopy" in update
    assert "UpdateCopyWorkTableMenuState" in devices_popup
    assert "UpdateCopyWorkTableMenuState" in etalons_popup
    assert "UpdateCopyWorkTableMenuState" in timer
