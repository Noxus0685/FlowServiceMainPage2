from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
FMX_BYTES = (ROOT / "frmMainTable.fmx").read_bytes()
FMX = FMX_BYTES.decode("ascii")

DEVICE_ITEMS = [f"MenuItemDevicesColumn{i}" for i in range(19)] + ["MenuItemDevicesColumnMeanFlow"]
ETALON_ITEMS = [f"MenuItemEtalonsColumn{i}" for i in range(15)] + ["MenuItemEtalonsColumnMeanFlow"]


def procedure_body(name: str) -> str:
    match = re.search(
        rf"(?:procedure|function) TFrameMainTable\.{name}\b(.*?)(?=\n(?:procedure|function) TFrameMainTable\.)",
        PAS,
        re.S,
    )
    assert match, name
    return match.group(1)


def menu_item_block(name: str) -> str:
    match = re.search(rf"object {name}: TMenuItem(.*?)\n        end", FMX, re.S)
    assert match, name
    return match.group(1)


def test_caption_normalization_removes_units_and_normalizes_case():
    body = procedure_body("NormalizeColumnCaption")
    assert "P := Pos(',', Result);" in body
    assert "Result := Trim(Copy(Result, 1, P - 1));" in body
    assert "Result := LowerCase(Result);" in body


def test_column_lookup_scans_current_headers_instead_of_saved_indices():
    body = procedure_body("FindGridColumnByMenuText")
    assert "for I := 0 to AGrid.ColumnCount - 1 do" in body
    assert "NormalizeColumnCaption(AGrid.Columns[I].Header)" in body
    assert "SameText(MenuCaption, ColumnCaption)" in body
    assert "Exit(AGrid.Columns[I]);" in body
    assert ".Index" not in body
    assert ".Tag" not in body
    assert "TagObject" not in body


def test_click_handlers_resolve_column_from_current_menu_text():
    for handler, grid in (("DevicesColumnMenuItemClick", "GridDevices"),
                          ("EtalonsColumnMenuItemClick", "GridEtalons")):
        body = procedure_body(handler)
        assert f"FindGridColumnByMenuText({grid}, MenuItem.Text)" in body
        assert "Column.Visible := not Column.Visible;" in body
        assert "MenuItem.IsChecked := Column.Visible;" in body
        assert "MenuItem.Tag" not in body
        assert "Columns[Index]" not in body
        assert ".Realign" not in body  # protected in the supported dcc32 version
        assert f"{grid}.Repaint;" in body


def test_sync_resolves_each_item_by_text_and_only_updates_checked_state():
    for sync, grid, group in (
        ("SyncDevicesColumnsMenu", "GridDevices", "MenuItemDevicesColumnsGroup"),
        ("SyncEtalonsColumnsMenu", "GridEtalons", "MenuItemEtalonsColumnsGroup"),
    ):
        body = procedure_body(sync)
        assert f"for I := 0 to {group}.ItemsCount - 1 do" in body
        assert f"FindGridColumnByMenuText({grid}, MenuItem.Text)" in body
        assert "MenuItem.IsChecked := Column.Visible" in body
        assert "MenuItem.Tag" not in body
        assert ".Enabled" not in body


def test_all_column_items_have_grid_specific_handlers_and_no_binding_tags():
    for item in DEVICE_ITEMS:
        block = menu_item_block(item)
        assert "OnClick = DevicesColumnMenuItemClick" in block
        assert "Tag =" not in block and "TagObject" not in block
    for item in ETALON_ITEMS:
        block = menu_item_block(item)
        assert "OnClick = EtalonsColumnMenuItemClick" in block
        assert "Tag =" not in block and "TagObject" not in block


def test_mean_flow_items_are_ascii_safe_and_have_expected_caption():
    caption = "Text = #1057#1088#46#32#1088#1072#1089#1093#1086#1076"
    assert caption in menu_item_block("MenuItemDevicesColumnMeanFlow")
    assert caption in menu_item_block("MenuItemEtalonsColumnMeanFlow")
    FMX_BYTES.decode("ascii")


def test_popup_sync_is_last_operation_and_legacy_binding_is_absent():
    for popup, sync in (("PopupMenuDevicesGridPopup", "SyncDevicesColumnsMenu"),
                        ("PopupMenuEtalonsGridPopup", "SyncEtalonsColumnsMenu")):
        body = procedure_body(popup)
        assert body.rstrip().endswith(sync + ";\nend;")
    for legacy in ("InitializeColumnMenuTags", "BindColumnMenuItem", "SyncGridColumnMenu"):
        assert legacy not in PAS
