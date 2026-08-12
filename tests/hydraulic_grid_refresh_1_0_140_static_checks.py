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


def test_fmx_helper_remains_windows_1251_without_unsupported_directive():
    raw = (ROOT / "FmxHelper.pas").read_bytes()
    assert "{$CODEPAGE" not in HELPER
    assert raw.decode("cp1251") == HELPER
    try:
        raw.decode("utf-8")
    except UnicodeDecodeError:
        pass
    else:
        raise AssertionError("FmxHelper.pas must remain Windows-1251")


def test_legacy_conversion_tables_accept_rad_studio_string_literals():
    assert "PICCHAR:array[$C0..$FF] of string=" in HELPER
    assert "WinR: Array[0..66] of string =" in HELPER
    assert "KoiR: Array[0..66] of string =" in HELPER


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


def test_project_version_is_1_0_140():
    assert "APP_VERSION = '1.0.140'" in VERSION
    assert "FileVersion=1.0.140.0" in PROJECT
    assert "ProductVersion=1.0.140.0" in PROJECT


def test_shortstring_trim_is_explicit_before_overload_resolution():
    assert "function IsStrFloat(AStr:ShortString):boolean;" in HELPER
    implementation = HELPER.index("function IsStrFloat(AStr:ShortString):boolean;", HELPER.index("implementation"))
    body = HELPER[implementation:HELPER.index("function IsStrDecimalInteger", implementation)]
    assert "Trim(string(AStr))" in body
    assert "string(Trim(AStr))" not in body


def test_channel_grid_focus_is_mutually_exclusive_and_not_timer_driven():
    assert "OnEnter = GridDevicesEnter" in (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8")
    assert "OnEnter = GridEtalonsEnter" in (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8")
    devices = method(MAIN, "procedure TFrameMainTable.GridDevicesEnter", "procedure TFrameMainTable.GridEtalonsEnter")
    etalons = method(MAIN, "procedure TFrameMainTable.GridEtalonsEnter", "procedure TFrameMainTable.GridDevicesHeaderClick")
    assert "FGridFocusUpdating" in devices and "GridEtalons.Row := -1" in devices and "GridEtalons.ResetFocus" in devices
    assert "FGridFocusUpdating" in etalons and "GridDevices.Row := -1" in etalons and "GridDevices.ResetFocus" in etalons
    timer = method(MAIN, "procedure TFrameMainTable.TimerMainTimer", "function TFrameMainTable.IsValidFlowGraphChannel")
    update = method(MAIN, "procedure TFrameMainTable.UpdateGrids", "procedure TFrameMainTable.GridEtalonsSetValue")
    assert "ResetFocus" not in timer + update
