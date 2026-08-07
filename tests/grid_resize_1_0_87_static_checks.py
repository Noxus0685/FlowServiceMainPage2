from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANAGER = (ROOT / "uGridLayoutManager.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def _body(signature: str, next_signature: str) -> str:
    start = MANAGER.index(signature)
    end = MANAGER.index(next_signature, start)
    return MANAGER[start:end]


def test_user_resize_uses_active_left_button_without_cursor_region_filter():
    body = _body(
        "function TGridLayoutState.IsUserColumnResize",
        "procedure TGridLayoutState.RefreshGridPresentation",
    )
    assert "GetAsyncKeyState(VK_LBUTTON) < 0" in body
    assert "GetCursorPos" not in body
    assert "DividerScreen" not in body
    assert "CursorScreen" not in body


def test_accepted_width_rebuilds_grid_model_geometry():
    refresh = _body(
        "procedure TGridLayoutState.RefreshGridPresentation",
        "procedure TGridLayoutState.ColumnResizeHandler",
    )
    handler = _body(
        "procedure TGridLayoutState.ColumnResizeHandler",
        "procedure TGridLayoutState.BeginManualColumnResize",
    )
    assert "FGrid.Model.ContentChanged;" in refresh
    assert "FGrid.Repaint;" in refresh
    assert "FSyncingPresentation" in refresh
    assert "RefreshGridPresentation;" in handler


def test_programmatic_and_presentation_resizes_stay_guarded():
    handler = _body(
        "procedure TGridLayoutState.ColumnResizeHandler",
        "procedure TGridLayoutState.BeginManualColumnResize",
    )
    assert "FRestoringWidth" in handler
    assert "FApplyingInitialWidths" in handler
    assert "FApplying" in handler
    assert "FSyncingPresentation" in handler
    assert "RestoreApprovedColumnWidth(Column, ColumnKey, 'OnResize')" in handler


def test_project_version():
    assert "APP_VERSION = '1.0.87';" in VERSION
