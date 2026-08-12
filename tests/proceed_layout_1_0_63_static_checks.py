from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def body(name: str) -> str:
    markers = (f"procedure TFrameProceed.{name}", f"function TFrameProceed.{name}")
    start = next(PROCEED.index(marker) for marker in markers if marker in PROCEED)
    ends = [pos for marker in ("\nprocedure TFrameProceed.", "\nfunction TFrameProceed.")
            if (pos := PROCEED.find(marker, start + 1)) >= 0]
    return PROCEED[start:min(ends)] if ends else PROCEED[start:]


def test_display_position_and_visibility_are_captured_without_width():
    capture = body("CaptureGridColumnsLayout")
    assert "Column := AGrid.Columns[I]" in capture
    assert "Position := Column.Index" in capture
    assert "Position := I" not in capture
    assert "Width := Column.Width" not in capture
    assert "Visible := Column.Visible" in capture


def test_saved_order_is_applied_by_stable_column_name():
    apply = body("ApplyGridColumnsLayout")
    assert "SortedColumns[J].Position > Temp.Position" in apply
    assert "SameText(AGrid.Columns[ColumnIndex].Name, AName)" in apply
    assert "Column.Index := TargetIndex" in apply
    assert "if (IndexChanged = 0) and (VisibleChanged = 0) then" in apply


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
    assert "APP_VERSION = '1.0.136'" in VERSION


def test_results_point_columns_are_dynamic_and_signature_gated():
    update = body("UpdateResultsPointColumns")
    assert "NewSignature = FResultsPointColumnSignature" in update
    assert "TStringColumn.Create(GridResults)" in update
    assert "C_RESULTS_POINT_COLUMN_COUNT" not in PROCEED
    assert ".Width :=" not in update

def test_results_grid_fixed_point_access_uses_component_index():
    get_value = body("GridResultsGetValue")
    draw = body("GridResultsDrawColumnCell")
    assert "not GridResults.Columns[ACol].Visible" in get_value
    assert "PointIndex := GetResultsPointColumnIndex" in get_value
    assert "PointIndex < Length(FResultPointColumns)" in get_value
    assert "PointIndex < Length(Row.PointValues)" in get_value
    assert "not Column.Visible" in draw
    assert "PointIdx := GetResultsPointColumnIndex(Column)" in draw
