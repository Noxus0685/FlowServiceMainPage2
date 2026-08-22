from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def test_delete_button_is_compact_and_beside_name():
    text = source("frmWorkTableProperties.pas")
    build = text.split("procedure TFrameWorkTableProperties.BuildUI", 1)[1]
    build = build.split("procedure TFrameWorkTableProperties.AddEditRow", 1)[0]
    assert "AddWorkTableNameRow(GeneralCategory, 'Имя рабочего стола'" in build
    assert "AddDeleteButtonRow" not in text
    assert "AddEditDeleteButtonRow" not in text
    assert text.count("AddWorkTableNameRow") == 3
    assert "ButtonDeleteWorkTable.Text := '-'" in text
    assert "ButtonDeleteWorkTable.Width := 36" in text
    assert "ButtonDeleteWorkTable.Align := TAlignLayout.Right" in text
    assert "ButtonDeleteWorkTable.Hint := 'Удалить рабочий стол'" in text
    assert "FOnDeleteWorkTable(Sender)" in text


def test_queued_notifications_are_guarded_by_lifetime_token():
    text = source("uObservable.pas")
    assert "IObservableLifetimeToken = interface" in text
    assert "TInterlocked.Exchange(FAlive, 0)" in text
    assert "procedure TObservableObject.CancelPendingNotifications" in text
    notify = text.split("procedure TObservableObject.Notify(Event:", 1)[1]
    notify = notify.split("procedure TObservableObject.Notify(AEvent:", 1)[0]
    assert notify.index("LocalLifetime.IsAlive") < notify.index("Observer.OnNotify(Self")
    owned = text.split("procedure TObservableObject.NotifyOwned(Event:", 1)[1]
    owned = owned.split("procedure TObservableObject.NotifyOwned(AEvent:", 1)[0]
    assert "LocalLifetime.IsAlive" in owned
    assert "finally\n        LocalData.Free;" in owned


def test_manager_barrier_precedes_owned_list_delete():
    text = source("uWorkTable.pas")
    body = text.split("function TWorkTableManager.DeleteWorkTableByUUID(", 1)[1]
    body = body.split("function TWorkTableManager.DeleteWorkTableByName", 1)[0]
    assert body.index("WorkTable.CancelPendingNotifications") < body.index("FWorkTables.Delete(I)")
    assert body.index("WorkTable.ClearObservers") < body.index("FWorkTables.Delete(I)")
    assert "UpperCase(Trim(AWorkTableUUID))" in body


def test_main_frame_has_deletion_barriers_and_single_final_activation():
    text = source("frmMainTable.pas")
    body = text.split("procedure TFrameMainTable.DeleteActiveWorkTableClick", 1)[1]
    body = body.split("procedure TFrameMainTable.NormalizeActiveWorkTable", 1)[0]
    assert "FDeletingWorkTable := True" in body
    assert "finally\n    FDeletingWorkTablePointer := nil;\n    FDeletingWorkTable := False;" in body
    assert "DeletedWorkTable.CancelPendingNotifications" in body
    assert "FindManagedWorkTableByUUID(NewActiveUUID)" in body
    assert body.count("SyncWorkTableTabs;") == 1
    assert "PanelControlWorkTables.Parent :=" not in body
    assert "TabControlWorkTables.ActiveTab :=" not in body
    assert body.count("SelectWorkTable(FActiveWorkTable);") == 1
    assert "ActivateWorkTable(NewActiveWorkTable)" not in body
    assert "WorkTableDeleteNotificationBarrierBegin" in body
    assert "WorkTableDeleteNotificationBarrierDone" in body
    assert "WorkTableQueuedNotificationSkipped" in body
    assert body.index("FDeletingWorkTable := False") < body.index("SelectWorkTable(FActiveWorkTable)")


def test_event_and_grid_updates_reject_deletion_window():
    text = source("frmMainTable.pas")
    event_body = text.split("procedure TFrameMainTable.HandleWorkTableEvent", 1)[1]
    event_body = event_body.split("procedure TFrameMainTable.HandlePumpStateChanged", 1)[0]
    assert "FDeletingWorkTable or not IsManagedWorkTable(AWorkTable)" in event_body
    update = text.split("procedure TFrameMainTable.UpdateUIFromValues", 1)[1]
    update = update.split("procedure TFrameMainTable.SetValues", 1)[0]
    assert "FDeletingWorkTable or (csDestroying in ComponentState)" in update
    assert "not IsManagedWorkTable(FActiveWorkTable)" in update
    assert "if Assigned(StringColumnDeviceFlowRate1) then" in update


def test_tab_sync_detaches_panel_and_selection_owns_final_switch():
    text = source("frmMainTable.pas")
    remove = text.split("procedure TFrameMainTable.RemoveWorkTableTabs", 1)[1]
    remove = remove.split("procedure TFrameMainTable.SyncWorkTableTabs", 1)[0]
    assert remove.index("PanelControlWorkTables.Parent := nil") < remove.index("Tab.Parent := nil")
    assert "PanelControlWorkTables.Parent := TabControlWorkTables" not in remove
    assert "ReplacementTab" not in remove

    sync = text.split("procedure TFrameMainTable.SyncWorkTableTabs", 1)[1]
    sync = sync.split("procedure TFrameMainTable.ActivateWorkTable", 1)[0]
    assert "PanelControlWorkTables.Parent :=" not in sync

    select = text.split("procedure TFrameMainTable.SelectWorkTable", 1)[1]
    select = select.split("procedure TFrameMainTable.UpdateWorkTableTabCaption", 1)[0]
    assert "TabControlWorkTables.ActiveTab := Tab" in select
    assert "PanelControlWorkTables.Parent :=" not in select
    assert select.count("ActivateWorkTable(AWorkTable)") == 1

    activate = text.split("procedure TFrameMainTable.ActivateWorkTable(AWorkTable", 1)[1]
    activate = activate.split("procedure TFrameMainTable.ActivateWorkTableFromTab", 1)[0]
    assert "IsLiveWorkTableTab(ActiveTab)" in activate
    assert "PanelControlWorkTables.Parent := ActiveTab" in activate
    assert "WorkTablePanelAttachedToActiveTab" in activate


def test_release_version():
    assert "APP_VERSION = '1.0.231'" in source("uAppVersion.pas")
