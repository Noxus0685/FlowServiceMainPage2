from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
WORK_TABLE = ROOT / "FlowServiceMainPage" / "uWorkTable.pas"
VERSION_UNIT = ROOT / "FlowServiceMainPage" / "uAppVersion.pas"


def method_body(source: str, start: str, end: str) -> str:
    match = re.search(
        rf"{re.escape(start)}.*?(?={re.escape(end)})",
        source,
        re.DOTALL,
    )
    assert match, f"{start} body not found"
    return match.group(0)


def test_manager_simulation_mode_is_propagated_to_work_tables() -> None:
    source = WORK_TABLE.read_text(encoding="utf-8-sig")

    assert (
        "property IsSimulationMode: Boolean read FIsSimulationMode "
        "write SetIsSimulationMode;"
    ) in source

    setter = method_body(
        source,
        "procedure TWorkTableManager.SetIsSimulationMode",
        "function TWorkTableManager.DeleteWorkTableByName",
    )
    assert "FIsSimulationMode := AValue;" in setter
    assert "for WorkTable in FWorkTables do" in setter
    assert "WorkTable.IsSimulationMode := AValue;" in setter
    assert "BoolText(FIsSimulationMode)" in setter
    assert "BoolToStr(FIsSimulationMode, True)" not in setter

    add_table = method_body(
        source,
        "procedure TWorkTableManager.AddWorkTable;",
        "procedure TWorkTableManager.AddWorkTable(const WorkTableName",
    )
    assert "WorkTable.IsSimulationMode := FIsSimulationMode;" in add_table

    load = method_body(
        source,
        "procedure TWorkTableManager.Load;",
        "procedure TWorkTableManager.Save;",
    )
    assert "FWorkTables[I].IsSimulationMode := FIsSimulationMode;" in load


def test_selected_session_point_uuid_is_published_to_work_table() -> None:
    source = WORK_TABLE.read_text(encoding="utf-8-sig")
    body = method_body(
        source,
        "procedure TWorkTable.MeasurementRunPointChanged",
        "procedure TWorkTable.ResetCurrentPoint",
    )

    assign_pos = body.index("FCurrentPoint.Assign(APoint, True);")
    uuid_pos = body.index("FCurrentPoint.UUID := APoint.UUID;")
    assert assign_pos < uuid_pos


def test_simulated_hydraulic_setup_never_fires_hardware_action() -> None:
    source = WORK_TABLE.read_text(encoding="utf-8-sig")
    body = method_body(
        source,
        "function TWorkTable.SetupHydraulicLine",
        "procedure TWorkTable.ResetSpillageRuntimeValues",
    )

    simulation_pos = body.index("if IsSimulationMode then")
    logical_apply_pos = body.index("Result := ApplyHydraulicConfiguration(AError);")
    exit_pos = body.index("Exit;", logical_apply_pos)
    hardware_action_pos = body.index("FireAction(awtSetupHydraulicLine")

    assert simulation_pos < logical_apply_pos < exit_pos < hardware_action_pos


def test_application_version_is_1_0_163() -> None:
    source = VERSION_UNIT.read_text(encoding="utf-8-sig")
    assert "APP_VERSION = '1.0.168';" in source
