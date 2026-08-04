from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def body(name: str) -> str:
    start = PROCEED.index(f"procedure TFrameProceed.{name}")
    end = PROCEED.find("\nprocedure TFrameProceed.", start + 1)
    return PROCEED[start:] if end < 0 else PROCEED[start:end]


def test_display_position_is_captured_from_grid_enumeration():
    capture = body("CaptureGridColumnsLayout")
    assert "Name := AGrid.Columns[I].Name" in capture
    assert "Position := I" in capture
    assert "Position := AGrid.Columns[I].Index" not in capture
    assert "Width := AGrid.Columns[I].Width" in capture
    assert "Visible := AGrid.Columns[I].Visible" in capture


def test_saved_order_is_applied_by_stable_column_name():
    apply = body("ApplyGridColumnsLayout")
    assert "AColumns[I].Position = TargetIndex" in apply
    assert "SameText(AGrid.Columns[J].Name, AColumns[I].Name)" in apply
    assert "AGrid.Columns[J].Index := TargetIndex" in apply


def test_columns_menu_uses_logical_items_not_fmx_style_children():
    build = body("BuildGridColumnsMenu")
    popup = body("PopupMenuGridResultsPopup")
    assert "AColumnsMenu.ItemsCount <> 0" in build
    assert "AColumnsMenu.ChildrenCount <> 0" not in build
    assert "ColumnsMenu.ItemsCount" in popup
    assert "ColumnsMenu.Items[I]" in popup
    assert "Item.IsChecked := Grid.Columns[J].Visible" in popup
    assert ".Free" not in popup


def test_release_version():
    assert "APP_VERSION = '1.0.63'" in VERSION
