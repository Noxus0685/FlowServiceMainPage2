from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
FMX_BYTES = (ROOT / "frmMainTable.fmx").read_bytes()
FMX = FMX_BYTES.decode("ascii")

DEVICE_GROUPS = ("Channel", "Device", "Measurement", "Statistics", "Other")
ETALON_GROUPS = DEVICE_GROUPS
DEVICE_ITEMS = (
    "Enable", "Channel", "SignalType", "Signal", "DeviceType", "Size", "Device", "Serial",
    "Frequency", "Impulses", "Flow", "MeanFlow", "Volume", "Value", "Error", "Deviation",
    "VolumeBefore", "VolumeAfter", "PressureDelta", "Status", "UUID", "Coefficient",
)
ETALON_ITEMS = (
    "Enable", "Channel", "SignalType", "Signal", "DeviceType", "Size", "Device", "Serial",
    "Frequency", "Impulses", "Flow", "MeanFlow", "Volume", "Value", "Error", "Deviation",
    "PressureDelta", "Status",
)


def procedure_body(name: str) -> str:
    match = re.search(
        rf"(?:procedure|function) TFrameMainTable\.{name}\b(.*?)(?=\n(?:procedure|function) TFrameMainTable\.)",
        PAS, re.S,
    )
    assert match, name
    return match.group(1)


def object_block(name: str) -> str:
    marker = f"object {name}: TMenuItem"
    start = FMX.index(marker)
    lines = FMX[start:].splitlines(True)
    depth = 0
    result = []
    for line in lines:
        result.append(line)
        stripped = line.strip()
        if stripped.startswith("object "):
            depth += 1
        elif stripped == "end":
            depth -= 1
            if depth == 0:
                break
    return "".join(result)


def test_complete_named_hierarchy_is_stored_in_fmx_and_declared_in_pas():
    for prefix, groups, items in (
        ("Devices", DEVICE_GROUPS, DEVICE_ITEMS),
        ("Etalons", ETALON_GROUPS, ETALON_ITEMS),
    ):
        root = object_block(f"MenuItem{prefix}ColumnsGroup")
        for group in groups:
            name = f"MenuItem{prefix}Columns{group}Group"
            assert f"object {name}: TMenuItem" in root
            assert re.search(rf"\b{name}: TMenuItem;", PAS)
            group_header = object_block(name).split("object ", 2)[1]
            assert "OnClick =" not in group_header.split("object ", 1)[0]
        for suffix in items:
            name = f"MenuItem{prefix}Column{suffix}"
            assert root.count(f"object {name}: TMenuItem") == 1
            assert re.search(rf"\b{name}: TMenuItem;", PAS)
            assert f"OnClick = {prefix}ColumnMenuItemClick" in object_block(name)


def test_every_real_grid_column_has_exactly_one_menu_binding():
    expected = {
        "Devices": re.findall(r"object (\w+): T(?:Check|String|Popup)?Column\b", object_block_grid("GridDevices")),
        "Etalons": re.findall(r"object (\w+): T(?:Check|String|Popup)?Column\b", object_block_grid("GridEtalons")),
    }
    for prefix, columns in expected.items():
        root = object_block(f"MenuItem{prefix}ColumnsGroup")
        for column in columns:
            assert root.count(f"TagString = '{column}'") == 1, column


def object_block_grid(name: str) -> str:
    marker = f"object {name}: TGrid"
    start = FMX.index(marker)
    lines = FMX[start:].splitlines(True)
    depth = 0
    result = []
    for line in lines:
        result.append(line)
        stripped = line.strip()
        if stripped.startswith("object "):
            depth += 1
        elif stripped == "end":
            depth -= 1
            if depth == 0:
                break
    return "".join(result)


def test_column_menu_is_never_built_or_reordered_at_runtime():
    assert "EnsureGridColumnsMenu" not in PAS
    assert "FindColumnMenuGroup" not in PAS
    assert "FindColumnMenuItem" not in PAS
    assert not re.search(r"TMenuItem\.Create\([^\n]*(?:Column|Group)", PAS)
    sync = procedure_body("SyncColumnMenuBranch")
    for forbidden in (".Create", "AddObject", "InsertObject", "RemoveObject", "Items.Clear",
                      "DeleteChildren", ".Parent :=", ".Index :=", ".Text :="):
        assert forbidden not in sync


def test_click_and_recursive_sync_resolve_leaves_independently_of_order():
    lookup = procedure_body("FindGridColumnForMenuItem")
    assert "FindGridColumnByName(AGrid, AMenuItem.TagString)" in lookup
    assert "NormalizeColumnCaption(AGrid.Columns[I].Header)" in lookup
    assert "NormalizeColumnCaption(AMenuItem.Text)" in lookup
    assert ".Index" not in lookup

    for handler, grid in (("DevicesColumnMenuItemClick", "GridDevices"),
                          ("EtalonsColumnMenuItemClick", "GridEtalons")):
        body = procedure_body(handler)
        assert "if MenuItem.ItemsCount > 0 then" in body
        assert f"FindGridColumnForMenuItem({grid}, MenuItem)" in body
        assert "GridColumn.Visible := not GridColumn.Visible;" in body
        assert f"RefreshGridColumns({grid});" in body
        assert "SaveLayoutSettingsToWorkTable;" in body
        assert body.index("GridColumn.Visible := not GridColumn.Visible;") < body.index("MenuItem.IsChecked := GridColumn.Visible;")
        assert body.index("MenuItem.IsChecked := GridColumn.Visible;") < body.index(f"RefreshGridColumns({grid});")
        assert body.index(f"RefreshGridColumns({grid});") < body.index("SaveLayoutSettingsToWorkTable;")

    sync = procedure_body("SyncColumnMenuBranch")
    assert "SyncColumnMenuBranch(MenuItem, AGrid);" in sync
    assert "FindGridColumnForMenuItem(AGrid, MenuItem)" in sync
    assert "MenuItem.IsChecked := GridColumn.Visible" in sync


def test_dynamic_units_are_removed_during_caption_fallback():
    body = procedure_body("NormalizeColumnCaption")
    assert "P := Pos(',', Result);" in body
    assert "Result := Trim(Copy(Result, 1, P - 1));" in body
    assert "Result := LowerCase(Trim(Result));" in body
    assert "#$00A0" in body


def test_popups_only_sync_existing_column_items():
    for popup, sync in (("PopupMenuDevicesGridPopup", "SyncDevicesColumnsMenu"),
                        ("PopupMenuEtalonsGridPopup", "SyncEtalonsColumnsMenu")):
        body = procedure_body(popup)
        assert body.rstrip().endswith(sync + ";\nend;")
        assert "Ensure" not in body


def test_fmx_remains_ascii_safe():
    FMX_BYTES.decode("ascii")


def test_grid_model_and_viewport_are_refreshed_after_structural_changes():
    body = procedure_body("RefreshGridColumns")
    assert "FRefreshingGridColumns or (AGrid = nil)" in body
    assert "ViewportY := AGrid.ViewportPosition.Y;" in body
    assert "AGrid.Model.BeginUpdate;" in body
    assert "AGrid.Model.InvalidateContentSize;" in body
    assert "AGrid.Model.ContentChanged;" in body
    assert "AGrid.Model.EndUpdate;" in body
    assert "AGrid.ViewportPosition := PointF(0, ViewportY);" in body
    assert "AGrid.Repaint;" in body
    assert "AGrid.Realign" not in body
    assert body.index("AGrid.Model.InvalidateContentSize;") < body.index("AGrid.Model.ContentChanged;")
    assert body.index("AGrid.Model.ContentChanged;") < body.index("AGrid.ViewportPosition := PointF(0, ViewportY);")

    load = procedure_body("LoadLayoutSettingsFromWorkTable")
    for grid in ("GridEtalons", "GridDevices", "FFrameProceed.GridDataPoints", "FFrameProceed.GridResults"):
        apply = f"ApplyGridColumnsLayout({grid},"
        refresh = f"RefreshGridColumns({grid});"
        assert apply in load
        assert refresh in load
        assert load.index(apply) < load.index(refresh)


def test_model_refresh_is_not_called_from_hot_grid_callbacks():
    for callback in ("GridDevicesGetValue", "GridEtalonsGetValue", "GridDevicesDrawColumnCell",
                     "GridEtalonsDrawColumnCell", "TimerMainTimer"):
        assert "RefreshGridColumns" not in procedure_body(callback)
