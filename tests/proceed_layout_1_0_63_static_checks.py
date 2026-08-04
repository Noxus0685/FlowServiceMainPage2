from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def body(name: str) -> str:
    start = PROCEED.index(f"procedure TFrameProceed.{name}")
    end = PROCEED.find("\nprocedure TFrameProceed.", start + 1)
    return PROCEED[start:] if end < 0 else PROCEED[start:end]


def test_display_position_is_captured_from_fmx_column_index():
    capture = body("CaptureGridColumnsLayout")
    assert "Column := AGrid.Columns[I]" in capture
    assert "Position := Column.Index" in capture
    assert "Position := I" not in capture
    assert "Width := Column.Width" in capture
    assert "Visible := Column.Visible" in capture
    assert "'GridLayoutSaveOrderBegin'" in capture
    assert "'GridLayoutSaved'" in capture
    for field in ("GridName", "ColumnName", "ColumnsIndex", "VisualIndex",
                  "Position", "Width", "Visible"):
        assert field in capture


def test_saved_order_is_applied_by_stable_column_name():
    apply = body("ApplyGridColumnsLayout")
    assert "SortedColumns[J].Position > Temp.Position" in apply
    assert "SameText(AGrid.Columns[J].Name, SortedColumns[I].Name)" in apply
    assert "Column.Index := TargetIndex" in apply
    assert "FApplyingGridColumnsLayout := True" in apply
    assert "FApplyingGridColumnsLayout := False" in apply
    assert "'GridLayoutLoaded'" in apply
    assert "SavedPosition=%d; AppliedPosition=%d" in apply


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
