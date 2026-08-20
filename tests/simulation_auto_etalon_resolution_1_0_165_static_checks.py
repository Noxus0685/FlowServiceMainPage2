from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
MEASUREMENT_RUN = ROOT / "FlowServiceMainPage" / "uMeasurementRun.pas"
VERSION_UNIT = ROOT / "FlowServiceMainPage" / "uAppVersion.pas"


def method_body(source: str, start: str, end: str) -> str:
    match = re.search(
        rf"{re.escape(start)}.*?(?={re.escape(end)})",
        source,
        re.DOTALL,
    )
    assert match, f"{start} body not found"
    return match.group(0)


def test_simulation_bypasses_physical_hydraulic_search() -> None:
    source = MEASUREMENT_RUN.read_text(encoding="utf-8-sig")
    body = method_body(
        source,
        "procedure TMeasurementRun.EnterHydraulicLineConfiguration",
        "procedure TMeasurementRun.EnterSetupHydraulicLine",
    )

    select_pos = body.index("if not SelectEtalons(Point, Error) then")
    simulation_pos = body.index("if FWorkTable.IsSimulationMode then", select_pos)
    stage_pos = body.index("SetStage(msSetupPoint);", simulation_pos)
    exit_pos = body.index("Exit;", stage_pos)
    physical_search_pos = body.index(
        "FWorkTable.BeginHydraulicConfigurationSearch", exit_pos
    )

    assert select_pos < simulation_pos < stage_pos < exit_pos < physical_search_pos
    assert "SimulationHydraulicSelectionBypassed" in body
    assert "RealModeUnchanged=True" in body


def test_direct_setup_transition_is_simulation_only() -> None:
    source = MEASUREMENT_RUN.read_text(encoding="utf-8-sig")
    body = method_body(
        source,
        "function TMeasurementRun.CanChangeStage",
        "procedure TMeasurementRun.SetStage",
    )
    branch = method_body(
        body,
        "msHydraulicLineConfiguration:",
        "msSetupHydraulicLine:",
    )

    simulation_pos = branch.index("FWorkTable.IsSimulationMode")
    simulation_transition = branch.index(
        "[msSetupHydraulicLine, msSetupPoint, msSelectPoint, msDone, msNone]",
        simulation_pos,
    )
    real_transition = branch.index(
        "[msSetupHydraulicLine, msSelectPoint, msDone, msNone]",
        simulation_transition,
    )
    assert simulation_pos < simulation_transition < real_transition


def test_simulation_does_not_mutate_etalon_type() -> None:
    source = MEASUREMENT_RUN.read_text(encoding="utf-8-sig")
    body = method_body(
        source,
        "function TMeasurementRun.SelectEtalons",
        "function TMeasurementRun.CalcMeasureTimeout",
    )

    assert "EtalonType :=" not in body
    assert "SimulationAutoEtalonTypeResolved" not in body


def test_application_version_is_1_0_166() -> None:
    source = VERSION_UNIT.read_text(encoding="utf-8-sig")
    assert "APP_VERSION = '1.0.168';" in source
