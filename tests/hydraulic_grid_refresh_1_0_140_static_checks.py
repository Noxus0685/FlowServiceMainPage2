from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]
ROOT_HELPER_PATH = (ROOT / "FmxHelper.pas").resolve()
COMPONENT_HELPER_PATH = (ROOT / "Components" / "FP" / "FmxHelper.pas").resolve()
assert ROOT_HELPER_PATH.is_absolute()
assert ROOT_HELPER_PATH.parent == ROOT
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
MEASUREMENT_FRAME = (ROOT / "frmMeasurementRun.pas").read_text(encoding="utf-8")
RUN = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8")
SIMULATION_FORM = (ROOT / "fuTable_Main.pas").read_text(encoding="utf-8")
HELPER = ROOT_HELPER_PATH.read_text(encoding="utf-8")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8")


def method(text: str, start: str, following: str) -> str:
    begin = text.index(start)
    end = text.index(following, begin + len(start))
    return text[begin:end]


def test_root_fmx_helper_path_encoding_and_first_line(capsys):
    print(f"Root FmxHelper: {ROOT_HELPER_PATH}")
    assert str(ROOT_HELPER_PATH) in capsys.readouterr().out
    raw = ROOT_HELPER_PATH.read_bytes()
    assert raw.splitlines()[0] == b"unit FmxHelper;"
    assert b"CODEPAGE" not in raw.upper()
    assert raw.decode("utf-8") == HELPER


def test_picchar_is_the_original_64_char_table():
    raw = ROOT_HELPER_PATH.read_bytes()
    match = re.search(
        rb"PICCHAR\s*:\s*array\[\$C0\.\.\$FF\]\s+of\s+Char\s*=\s*\((.*?)\);",
        raw,
        re.IGNORECASE | re.DOTALL,
    )
    assert match, f"PICCHAR Char declaration not found in {ROOT_HELPER_PATH}"
    assert not re.search(rb"array\[\$C0\.\.\$FF\]\s+of\s+string", raw, re.IGNORECASE)
    block = match.group(1).decode("utf-8")
    elements = re.findall(r"'([^']*)'", block)
    assert len(elements) == 64
    assert all(len(element) == 1 for element in elements)
    assert [ord(element) for element in elements] == list(range(0xC0, 0x100))


def test_char2byte_uses_picchar_without_string_conversion():
    implementation = HELPER.index("implementation")
    start = HELPER.index("function Char2Byte(ch: BYTE):char;", implementation)
    body = HELPER[start:HELPER.index("function GetKM5CRC", start)]
    assert "result:=PICCHAR[ord(ch)]" in body
    assert "Char(PICCHAR" not in body
    assert "PICCHAR[ord(ch)][" not in body
    assert ".Chars[" not in body


def test_nested_component_helper_is_unchanged():
    assert hashlib.sha256(COMPONENT_HELPER_PATH.read_bytes()).hexdigest() == \
        "f858a31801349f3cfc080110632a0f07cec93969b4abf4089cd36fed3ab03d6d"

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
    assert "IsHydraulicSimulationMode(AWorkTable)" in handler
    assert "CompleteSimulatedHydraulicConfiguration(AWorkTable)" in handler
    assert "awtSetupHydraulicLine:" in handler
    assert "CompleteSimulatedHydraulicLineSetup(AWorkTable)" in handler
    assert "AWorkTable.ApplyHydraulicConfiguration(Error)" in handler
    predicate = method(MAIN, "function TFrameMainTable.IsHydraulicSimulationMode", "procedure TFrameMainTable.CompleteSimulatedHydraulicConfiguration")
    assert "AWorkTable.IsSimulationMode" in predicate
    assert "WorkTableManager.IsSimulationMode" in predicate
    assert "AWorkTable.SimulationActive" not in predicate
    find_completion = method(MAIN, "procedure TFrameMainTable.CompleteSimulatedHydraulicConfiguration", "procedure TFrameMainTable.CompleteSimulatedHydraulicLineSetup")
    setup_completion = method(MAIN, "procedure TFrameMainTable.CompleteSimulatedHydraulicLineSetup", "procedure TFrameMainTable.ClearChannelSimulationValues")
    assert "CompleteHydraulicConfigurationSearch" in find_completion
    assert "FailHydraulicConfigurationSearch" in find_completion
    assert "BeginHydraulicLineApply" in setup_completion
    assert "CompleteHydraulicLineApply" in setup_completion
    assert "FailHydraulicLineApply" in setup_completion
    assert ".SetStage" not in find_completion + setup_completion


def test_simulation_entry_point_enables_manager_mode_before_frame_initialization():
    form_create = method(SIMULATION_FORM, "procedure TTableMainForm.FormCreate", "procedure TTableMainForm.tcMainChange")
    manager_assignment = form_create.index("FWorkTableManager := AppServices.WorkTableManager;")
    simulation_assignment = form_create.index("FWorkTableManager.IsSimulationMode := True;")
    frame_initialization = form_create.index("FFrameMainTable.Initialize;")
    assert manager_assignment < simulation_assignment < frame_initialization
    assert form_create.count("FWorkTableManager.IsSimulationMode := True;") == 1
    assert "FWorkTableManager.IsSimulationMode := True;" not in MAIN


def test_project_version_is_1_0_144():
    assert "APP_VERSION = '1.0.144'" in VERSION
    assert "FileVersion=1.0.144.0" in PROJECT
    assert "ProductVersion=1.0.144.0" in PROJECT


def test_shortstring_trim_is_explicit_before_overload_resolution():
    assert "function IsStrFloat(AStr:ShortString):boolean;" in HELPER
    implementation = HELPER.index("function IsStrFloat(AStr:ShortString):boolean;", HELPER.index("implementation"))
    body = HELPER[implementation:HELPER.index("function IsStrDecimalInteger", implementation)]
    assert "Trim(string(AStr))" in body
    assert "string(Trim(AStr))" not in body


def test_channel_grid_focus_is_mutually_exclusive_and_not_timer_driven():
    form = (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8")
    assert "OnEnter = GridDevicesEnter" in form
    assert "OnEnter = GridEtalonsEnter" in form
    activate = method(MAIN, "procedure TFrameMainTable.ActivateMeasurementGrid", "procedure TFrameMainTable.GridDevicesEnter")
    devices = method(MAIN, "procedure TFrameMainTable.GridDevicesEnter", "procedure TFrameMainTable.GridEtalonsEnter")
    etalons = method(MAIN, "procedure TFrameMainTable.GridEtalonsEnter", "procedure TFrameMainTable.GridDevicesHeaderClick")
    assert "FChangingMeasurementGridFocus" in activate
    assert "OtherGrid.Row := -1" in activate and "OtherGrid.ResetFocus" in activate
    assert "ActivateMeasurementGrid(GridDevices)" in devices
    assert "ActivateMeasurementGrid(GridEtalons)" in etalons
    timer = method(MAIN, "procedure TFrameMainTable.TimerMainTimer", "function TFrameMainTable.IsValidFlowGraphChannel")
    update = method(MAIN, "procedure TFrameMainTable.UpdateGrids", "procedure TFrameMainTable.GridEtalonsSetValue")
    refresh = method(HELPER, "procedure RefreshGridValues(AGrid: TCustomGrid;", "var\n  LogCriticalSection")
    assert "ResetFocus" not in timer + update + refresh
