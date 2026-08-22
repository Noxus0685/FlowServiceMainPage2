from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def test_properties_frame_exposes_delete_request_only():
    text = source("frmWorkTableProperties.pas")
    assert "property OnDeleteWorkTable: TNotifyEvent" in text
    assert "ButtonDeleteWorkTable.Text := 'Удалить рабочий стол'" in text
    handler = text.split("procedure TFrameWorkTableProperties.ButtonDeleteWorkTableClick", 1)[1]
    handler = handler.split("end;", 1)[0]
    assert "FOnDeleteWorkTable(Sender)" in handler
    assert "WorkTableManager" not in handler


def test_manager_deletes_by_normalized_uuid_and_persists():
    text = source("uWorkTable.pas")
    body = text.split("function TWorkTableManager.DeleteWorkTableByUUID(", 1)[1]
    body = body.split("function TWorkTableManager.DeleteWorkTableByName", 1)[0]
    assert "UpperCase(Trim(AWorkTableUUID))" in body
    assert "FWorkTables.Delete(I)" in body
    assert "SetActiveWorkTable(nil)" in body
    assert "Save;" in body
    assert "DeleteWorkTableByName" not in body


def test_main_frame_guards_detaches_and_activates_neighbor():
    text = source("frmMainTable.pas")
    body = text.split("procedure TFrameMainTable.DeleteActiveWorkTableClick", 1)[1]
    body = body.split("procedure TFrameMainTable.NormalizeActiveWorkTable", 1)[0]
    for event in ("WorkTableDeleteRequested", "WorkTableDeleteCancelled",
                  "WorkTableDeleteBlocked", "WorkTableDeleteBegin",
                  "WorkTableDeleteDone", "WorkTableDeleteFailed"):
        assert event in body
    assert "WorkCountBefore <= 1" in body
    assert "hlsSelecting, hlsSettingUp" in body
    assert "DetachWorkTableObservers" in body
    assert "DeleteWorkTableByUUID(DeletedUUID)" in body
    assert body.count("SyncWorkTableTabs;") == 1
    assert "SelectWorkTable(NewActiveWorkTable)" in body


def test_release_version():
    assert "APP_VERSION = '1.0.228'" in source("uAppVersion.pas")
