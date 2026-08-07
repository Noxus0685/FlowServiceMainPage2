from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANAGER = (ROOT / "uGridLayoutManager.pas").read_text(encoding="utf-8-sig")
REGISTRY = (ROOT / "uGridStabilityRegistry.pas").read_text(encoding="utf-8-sig")
CONTROLLER = (ROOT / "uGridStabilityController.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def _body(signature: str, next_signature: str) -> str:
    start = MANAGER.index(signature)
    end = MANAGER.index(next_signature, start)
    return MANAGER[start:end]


def test_user_resize_uses_active_left_button_and_rebuilds_model_geometry():
    detector = _body(
        "function TGridLayoutState.IsUserColumnResize",
        "procedure TGridLayoutState.RefreshGridPresentation",
    )
    refresh = _body(
        "procedure TGridLayoutState.RefreshGridPresentation",
        "procedure TGridLayoutState.ColumnResizeHandler",
    )
    assert "GetAsyncKeyState(VK_LBUTTON) < 0" in detector
    assert "FGrid.Model.ContentChanged;" in refresh
    assert "FGrid.Repaint;" in refresh
    assert "FSyncingPresentation" in refresh


def test_layout_state_supports_grid_and_string_grid():
    assert "FGrid: TCustomGrid;" in MANAGER
    assert "ConfigureWidthControl(AGrid: TCustomGrid" in MANAGER
    assert "BeginManualColumnResize(AGrid: TCustomGrid" in MANAGER
    assert "TGridOption.ColumnResize" in MANAGER


def test_registered_grids_receive_width_control_by_default():
    assert "AEnableWidthControl: Boolean = True" in REGISTRY
    assert "Result.Attach(AGrid, AFormName, AEnableWidthControl);" in REGISTRY
    assert "FWidthState.ConfigureWidthControl(FGrid" in CONTROLLER
    assert "FWidthState.RegisterExistingColumns;" in CONTROLLER


def test_specialized_dynamic_grids_do_not_get_duplicate_controllers():
    assert "RegisterStableGrid(Self, GridResults, Name, False);" in source("frmProceed.pas")
    assert "RegisterStableGrid(Self, GridMRResults, Name, False);" in source("frmMRResults.pas")
    assert "RegisterStableGrid(Self, GridPoints, Name, False)" in source("fuDeviceEdit.pas")


def test_all_application_grid_surfaces_are_registered():
    expected = {
        "fuDeviceEdit.pas": ["GridPoints", "FGridCoefs"],
        "fuDeviceSelect.pas": ["GridDevices"],
        "fuTypeEditor.pas": ["GridPoints", "GridDiameters", "FGridCoefs"],
        "fuTypeSelect.pas": ["GridTypes"],
        "frmMainTable.pas": [
            "GridDevices", "GridEtalons", "GridAutoTestNumbers", "GridAutoTestResults"
        ],
        "frmMeasurementRun.pas": ["GridMeasurmentRun"],
        "frmProceed.pas": ["GridResults", "GridDataPoints", "GridCoefs"],
        "frmMRResults.pas": ["GridMRResults"],
        "frmCalibrCoefs.pas": ["GridCoefs"],
        "frmMeterValueEditFrame.pas": ["GridSamples"],
        "fuMeterValues.pas": [
            "StringGridCoefsData", "StringGridCoefs",
            "StringGridDimensions", "StringGridValuesList",
        ],
        "frmMeterValueSelect.pas": ["StringGridValuesList"],
    }
    for file_name, grid_names in expected.items():
        text = source(file_name)
        for grid_name in grid_names:
            assert f"RegisterStableGrid(Self, {grid_name}," in text


def test_runtime_columns_use_named_semantic_keys():
    for file_name in (
        "fuDeviceEdit.pas",
        "fuTypeEditor.pas",
        "frmMainTable.pas",
        "frmMeterValueSelect.pas",
    ):
        text = source(file_name)
        assert ".Name :=" in text
    assert "StringColumnCoefName" in source("fuDeviceEdit.pas")
    assert "StringColumnCoefName" in source("fuTypeEditor.pas")
    assert "StringColumnTargetFlow" in source("frmMainTable.pas")
    assert "StringColumnOwner" in source("frmMeterValueSelect.pas")


def test_grid_layout_manager_public_and_private_methods_are_documented():
    required_comments = (
        "Builds the persistent INI key",
        "Loads and validates the last user-approved",
        "Persists one user-approved",
        "Constrains a column width",
        "Accepts user resize events",
        "Restores the last approved width",
        "Connects one stable column key",
        "Disconnects one column",
        "Applies a stored or declared width",
        "Creates isolated width state",
        "Disconnects the grid",
        "Builds a deterministic signature",
        "Applies a changed dynamic column structure",
    )
    for comment in required_comments:
        assert comment in MANAGER


def test_project_version():
    assert "APP_VERSION = '1.0.88';" in VERSION
