from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
MEASUREMENT_FRAME = (ROOT / "frmMeasurementRun.pas").read_text(encoding="utf-8")
RUN = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8")
HELPER = (ROOT / "FmxHelper.pas").read_text(encoding="cp1251")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8")


def method(text: str, start: str, following: str) -> str:
    begin = text.index(start)
    end = text.index(following, begin + len(start))
    return text[begin:end]


def test_fmx_helper_declares_its_windows_1251_source_encoding():
    assert HELPER.startswith("{$CODEPAGE 1251}")


def test_value_refresh_invalidates_each_cell_cache():
    implementation = HELPER.index("implementation")
    cell_start = HELPER.index("procedure RefreshGridCell(AGrid: TCustomGrid;", implementation)
    values_start = HELPER.index("procedure RefreshGridValues(AGrid: TCustomGrid;", cell_start)
    cell = HELPER[cell_start:values_start]
    values = HELPER[values_start:HELPER.index("var\n  LogCriticalSection", values_start)]
    assert "TGridModel(AGrid.Model).DataChanged(ACol, ARow)" in cell
    assert "AGrid.Model is TGridModel" in cell
    assert "RefreshGridCell(AGrid, ACol, ARow)" in values
    assert "AGrid.Repaint" not in values
    assert "ContentChanged(" not in HELPER
    assert "InvalidateContentSize" not in HELPER


def test_main_grid_refresh_paths_are_non_structural_for_values():
    devices = method(MAIN, "procedure TFrameMainTable.UpdateGridDevices;", "procedure TFrameMainTable.UpdateGrids;")
    timer = method(MAIN, "procedure TFrameMainTable.TimerMainTimer", "function TFrameMainTable.IsValidFlowGraphChannel")
    assert "RefreshGridRowCount(GridDevices, GridDevices.RowCount" not in devices
    assert "RefreshGridValues(GridDevices" in devices
    assert "UpdateGrids" in timer
    assert "RefreshGridValues(GridMeasurmentRun" in MEASUREMENT_FRAME
    assert "GridMeasurmentRun.Repaint" not in method(MEASUREMENT_FRAME, "procedure TFrameMeasurementRun.UpdateGridMesurmentRun;", "procedure TFrameMeasurementRun.UpdateCurrentPointIndicator")


def test_existing_measurement_notification_is_retained_once():
    setter = method(RUN, "procedure TMeasurementRun.SetPointStatus(APoint: TDevicePoint;\n  const AStatus: EMeasurementPointStatus; const AReason: string;", "procedure TMeasurementRun.MarkCurrentPointSkipped")
    assert setter.count("Notify(Integer(meStateChanged), APoint)") == 1


def test_simulation_completes_both_hydraulic_actions_through_public_api():
    handler = method(MAIN, "procedure TFrameMainTable.HandleWorkTableAction", "procedure TFrameMainTable.HandleWorkTableEvent")
    assert "awtFindHydraulicConfiguration:" in handler
    assert "CompleteSimulatedHydraulicConfiguration(AWorkTable)" in handler
    assert "awtSetupHydraulicLine:" in handler
    assert "CompleteSimulatedHydraulicLineSetup(AWorkTable)" in handler
    find_completion = method(MAIN, "procedure TFrameMainTable.CompleteSimulatedHydraulicConfiguration", "procedure TFrameMainTable.CompleteSimulatedHydraulicLineSetup")
    setup_completion = method(MAIN, "procedure TFrameMainTable.CompleteSimulatedHydraulicLineSetup", "procedure TFrameMainTable.ClearChannelSimulationValues")
    assert "CompleteHydraulicConfigurationSearch" in find_completion
    assert "FailHydraulicConfigurationSearch" in find_completion
    assert "BeginHydraulicLineApply" in setup_completion
    assert "CompleteHydraulicLineApply" in setup_completion
    assert "FailHydraulicLineApply" in setup_completion
    assert ".SetStage" not in find_completion + setup_completion


def test_project_version_is_1_0_138():
    assert "APP_VERSION = '1.0.138'" in VERSION
    assert "FileVersion=1.0.138.0" in PROJECT
    assert "ProductVersion=1.0.138.0" in PROJECT
