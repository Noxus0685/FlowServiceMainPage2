from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def delete_body() -> str:
    text = source("frmMainTable.pas")
    return text.split("procedure TFrameMainTable.DeleteActiveWorkTableClick", 1)[1].split(
        "procedure TFrameMainTable.NormalizeActiveWorkTable", 1
    )[0]


def test_guard_covers_modal_confirmation_and_is_always_released():
    body = delete_body()
    dialog = body.index("Confirmed := MessageDlg")
    assert body.index("FDeletingWorkTable := True") < dialog
    assert body.index("FDeletingWorkTablePointer := Pointer(DeletedWorkTable)") < dialog
    assert body.index("WorkTableDeleteGuardEnabled") < dialog
    assert "finally\n    FDeletingWorkTablePointer := nil;\n    FDeletingWorkTable := False;" in body
    assert "WorkTableDeleteGuardDisabled" in body
    cancelled = body.split("if not Confirmed then", 1)[1].split("end;", 1)[0]
    assert "WorkTableDeleteCancelled" in cancelled
    assert "UpdateDeleteWorkTableButton" in cancelled
    assert "SelectWorkTable" not in cancelled
    assert "SyncWorkTableTabs" not in cancelled


def test_deleted_sender_is_rejected_before_any_dereference():
    text = source("frmMainTable.pas")
    notify = text.split("procedure TFrameMainTable.OnNotify", 1)[1].split(
        "procedure TFrameMainTable.ProcessAddPoint", 1
    )[0]
    guard = notify.split("if not Assigned(Sender)", 1)[0]
    assert "Pointer(Sender) = FDeletingWorkTablePointer" in guard
    assert "Sender is" not in guard
    assert "TWorkTable(Sender)" not in guard
    assert "Sender.ClassName" not in guard

    event = text.split("procedure TFrameMainTable.HandleWorkTableEvent", 1)[1].split(
        "procedure TFrameMainTable.HandlePumpStateChanged", 1
    )[0]
    pointer_guard = event.index("Pointer(AWorkTable) = FDeletingWorkTablePointer")
    managed_guard = event.index("not IsManagedWorkTable(AWorkTable)")
    event_read = event.index("WorkTableEvent:=TryToGetEvent")
    assert pointer_guard < managed_guard < event_read


def test_ui_is_moved_and_validated_before_notification_barrier_and_free():
    body = delete_body()
    select = body.index("SelectWorkTable(NewActiveWorkTable)")
    barrier = body.index("DeletedWorkTable.CancelPendingNotifications")
    tab_free = body.index("DeletedTab.Free")
    model_delete = body.index("DeleteWorkTableByUUID(DeletedUUID)")
    sync = body.index("SyncWorkTableTabs;")
    assert select < barrier < tab_free < model_delete < sync
    assert body.count("SelectWorkTable(") == 1
    assert body.count("ActivateWorkTable(NewActiveWorkTable)") == 1
    retry = body.index("ActivateWorkTable(NewActiveWorkTable)")
    assert body.index("if BaseSwitchSucceeded and") < retry < barrier
    assert "FActiveWorkTable := nil" not in body
    assert "WorkTableManager.ActiveWorkTable := nil" not in body
    assert "PanelControlWorkTables.Parent :=" not in body
    for invariant in (
        "FActiveWorkTable = NewActiveWorkTable",
        "WorkTableManager.ActiveWorkTable = NewActiveWorkTable",
        "TabControlWorkTables.ActiveTab = NewActiveTab",
    ):
        assert invariant in body
    assert "PanelControlWorkTables.Parent = NewActiveTab" not in body
    assert "PanelControlWorkTables.Parent = DeletedTab" not in body
    assert "IsControlInsideTab(PanelControlWorkTables, NewActiveTab)" in body
    assert "IsControlInsideTab(PanelControlWorkTables, DeletedTab)" in body
    main = source("frmMainTable.pas")
    update = main.split("procedure TFrameMainTable.UpdateUIFromValues", 1)[1].split(
        "procedure TFrameMainTable.SetValues", 1
    )[0]
    assert "if FDeletingWorkTable or" not in update
    assert "UI panel is still attached to deleted tab" in body


def test_duplicate_activation_does_not_refresh_form():
    text = source("frmMainTable.pas")
    event = text.split("procedure TFrameMainTable.HandleWorkTableEvent", 1)[1].split(
        "procedure TFrameMainTable.HandlePumpStateChanged", 1
    )[0]
    activated = event.split("if WorkTableEvent = ewtActivated then", 1)[1]
    assert activated.index("if FActiveWorkTable = AWorkTable then") < activated.index("UpdateForm")


def test_generation_logs_and_preserved_safety_features():
    main = source("frmMainTable.pas")
    body = delete_body()
    assert "FWorkTableDeleteGeneration: Integer" in main
    assert "Inc(FWorkTableDeleteGeneration)" in body
    for event in (
        "WorkTableDeleteRequested",
        "WorkTableDeleteGuardEnabled",
        "WorkTableDeleteConfirmed",
        "WorkTableDeleteCancelled",
        "WorkTableDeleteNotificationBarrierBegin",
        "WorkTableDeleteNotificationBarrierDone",
        "WorkTablePostDeleteSelectionBegin",
        "WorkTableTabRemoved",
        "WorkTableDeleteDone",
        "WorkTableDeleteGuardDisabled",
    ):
        assert event in body
    observable = source("uObservable.pas")
    assert "IObservableLifetimeToken = interface" in observable
    assert "procedure TObservableObject.CancelPendingNotifications" in observable
    manager = source("uWorkTable.pas")
    assert "function TWorkTableManager.DeleteWorkTableByUUID" in manager
    assert "UpperCase(Trim(AWorkTableUUID))" in manager


def test_compact_delete_button_has_no_obsolete_row_builder():
    properties = source("frmWorkTableProperties.pas")
    build = properties.split("procedure TFrameWorkTableProperties.BuildUI", 1)[1].split(
        "procedure TFrameWorkTableProperties.AddEditRow", 1
    )[0]
    assert "AddDeleteButtonRow" not in properties
    assert "AddWorkTableNameRow(GeneralCategory" in build
    assert "ButtonDeleteWorkTable.Text := '-'" in properties
    assert "ButtonDeleteWorkTable.Width := 36" in properties


def test_delete_handler_only_uses_symbols_visible_at_call_site():
    body = delete_body()
    assert "FWorkTableTabs.Remove(UpperCase(Trim(DeletedUUID)))" in body
    assert "FWorkTableTabs.Remove(NormalizeWorkTableUUID(DeletedUUID))" not in body


def test_release_version():
    assert "APP_VERSION = '1.0.235'" in source("uAppVersion.pas")


def test_fmx_tab_containment_walks_parent_chain_and_validates_post_delete():
    main = source("frmMainTable.pas")
    helper = main.split("function TFrameMainTable.IsControlInsideTab", 1)[1].split(
        "function TFrameMainTable.FindWorkTableTabByUUID", 1
    )[0]
    assert "ParentObject := AControl" in helper
    assert "while ParentObject <> nil do" in helper
    assert "if ParentObject = ATab then" in helper
    assert "ParentObject := ParentObject.Parent" in helper

    body = delete_body()
    assert "WorkTableReplacementUIValidated" in body
    assert "PanelDirectParentPointer=%p" in body
    assert "PanelInsideTab=True" in body
    assert body.index("IsControlInsideTab(PanelControlWorkTables, NewActiveTab)") < body.index(
        "DeleteWorkTableByUUID(DeletedUUID)"
    )
    assert "WorkTableManager.WorkTables.Count <> WorkCountBefore - 1" in body
    assert "FindManagedWorkTableByUUID(DeletedUUID) <> nil" in body
    assert "FindWorkTableTabByUUID(DeletedUUID) <> nil" in body
    for reason in ("FrameActiveMismatch", "ManagerActiveMismatch",
                   "ActiveTabMismatch", "TabNotLive",
                   "PanelNotInsideActiveTab"):
        assert reason in body
