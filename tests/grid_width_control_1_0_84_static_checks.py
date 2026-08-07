from pathlib import Path

ROOT = Path(__file__).parents[1]
HELPER = (ROOT / "uGridLayoutManager.pas").read_text(encoding="utf-8-sig")
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
DEVICE = (ROOT / "fuDeviceEdit.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def section(text, start, end):
    left = text.index(start)
    right = text.index(end, left + len(start))
    return text[left:right]


def test_release_version():
    assert "APP_VERSION = '1.0.86'" in VERSION


def test_resize_is_authorized_inside_column_resize_handler():
    handler = section(
        HELPER,
        "procedure TGridLayoutState.ColumnResizeHandler",
        "procedure TGridLayoutState.BeginManualColumnResize",
    )
    assert "IsUserColumnResize(Column)" in handler
    assert "FManualResizeActive := True" in handler
    assert "FTrackedColumn := Column" in handler
    assert "SaveApprovedWidth(ColumnKey, ApprovedWidth)" in handler
    assert "RestoreApprovedColumnWidth(Column, ColumnKey, 'OnResize')" in handler


def test_user_resize_does_not_depend_on_grid_mousedown():
    assert "BeginManualColumnResize(GridMRResults, X, Y)" not in RESULTS
    assert "BeginManualColumnResize(GridResults, X, Y)" not in PROCEED
    assert "FinishPendingManualResize" in RESULTS
    assert "FinishPendingManualResize" in PROCEED
    assert "GetAsyncKeyState(VK_LBUTTON)" in HELPER
    assert "AColumn.LocalToScreen" in HELPER


def test_device_points_has_independent_width_state():
    assert "FGridPointsLayoutState: TGridLayoutState" in DEVICE
    assert "procedure TFormDeviceEditor.RegisterGridPointsWidthControl" in DEVICE
    registration = section(
        DEVICE,
        "procedure TFormDeviceEditor.RegisterGridPointsWidthControl",
        "procedure TFormDeviceEditor.LoadDevice",
    )
    assert "ConfigureWidthControl(GridPoints" in registration
    assert "RegisterExistingColumns" in registration
    assert "FreeAndNil(FGridPointsLayoutState)" in DEVICE
    assert "FGridPointsStability" in DEVICE


def test_existing_context_menu_handler_is_preserved():
    handler = section(
        DEVICE,
        "procedure TFormDeviceEditor.GridPointsMouseDown",
        "procedure TFormDeviceEditor.LoadDevice",
    )
    assert "TMouseButton.mbRight" in handler
    assert "FPopupMenuGridPointsHeader.Popup" in handler



def test_header_drag_uses_full_grid_bounds_and_repaints_body():
    detector = section(
        HELPER,
        "function TGridLayoutState.IsUserColumnResize",
        "procedure TGridLayoutState.ColumnResizeHandler",
    )
    assert "FGrid.LocalToScreen(PointF(0, 0))" in detector
    assert "FGrid.LocalToScreen(PointF(FGrid.Width, FGrid.Height))" in detector
    assert "CursorScreen.Y >= Min(GridTopLeft.Y, GridBottomRight.Y)" in detector
    assert "DividerScreen.Y + FGrid.Height" not in detector

    handler = section(
        HELPER,
        "procedure TGridLayoutState.ColumnResizeHandler",
        "procedure TGridLayoutState.BeginManualColumnResize",
    )
    assert "FGrid.Repaint" in handler
