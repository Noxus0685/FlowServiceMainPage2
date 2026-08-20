from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
MAIN_FORM = ROOT / "FMXFP" / "FlowPlantFMX" / "fuMain.pas"
VERSION_UNIT = ROOT / "FlowServiceMainPage" / "uAppVersion.pas"


def procedure_body(source: str, name: str, next_name: str) -> str:
    match = re.search(
        rf"procedure\s+TMainForm\.{name}\b.*?(?=procedure\s+TMainForm\.{next_name}\b)",
        source,
        re.DOTALL,
    )
    assert match, f"{name} body not found"
    return match.group(0)


def test_simulation_flow_does_not_start_hardware_engine() -> None:
    source = MAIN_FORM.read_text(encoding="utf-8")
    body = procedure_body(source, "FlowRateActionHandler", "FlowRateStateChangedHandler")

    assert "WorkTableManager.IsSimulationMode" in body
    assert re.search(
        r"apStart:.*?if not SimulationMode then.*?"
        r"FPEngine\.SetupManualWaterDischarge.*?"
        r"FlowRate\.State := spStarted",
        body,
        re.DOTALL,
    )
    assert re.search(
        r"apStop:.*?if not SimulationMode then.*?"
        r"FPEngine\.ManualWaterDischarge.*?"
        r"FlowRate\.State := spStopped",
        body,
        re.DOTALL,
    )
    assert re.search(
        r"apSet:.*?if SimulationMode then\s+Exit;",
        body,
        re.DOTALL,
    )


def test_toolbar_flow_button_uses_worktable_in_simulation() -> None:
    source = MAIN_FORM.read_text(encoding="utf-8")
    body = procedure_body(source, "cbtnSetupOutlayClick", "cbtnStartStopClick")

    simulation_guard = body.index("WorkTableManager.IsSimulationMode")
    legacy_engine_call = body.index("FPEngine.SetupManualWaterDischarge")

    assert simulation_guard < legacy_engine_call
    assert "WorkTable.FlowRate.DoFlowRateStart" in body
    assert "WorkTable.FlowRate.DoFlowRateStop" in body
    assert re.search(r"WorkTable\.FlowRate\.DoFlowRateStart;.*?Exit;", body, re.DOTALL)


def test_application_version_is_1_0_162() -> None:
    source = VERSION_UNIT.read_text(encoding="utf-8")
    assert "APP_VERSION = '1.0.168';" in source
