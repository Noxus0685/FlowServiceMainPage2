from pathlib import Path


root = Path(__file__).resolve().parents[1]
source = (root / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")

function_start = source.index(
    "function TMeasurementRun.IsPointSetupReady(out AInfo: RStableInfo): Boolean;"
)
function_end = source.index(
    "function TMeasurementRun.IsStable(out StableInfo: RStableInfo): Boolean;",
    function_start,
)
function_body = source[function_start:function_end]

assert "FLastPointSetupReadyProtocolMs: Int64;" in source
assert "CurrentMs := TMeterValue.GetMonotonicTimeMs;" in function_body
assert "CurrentMs - FLastPointSetupReadyProtocolMs >= 2000" in function_body
assert function_body.count("ProtocolManager.AddMessage") == 2
assert function_body.index("if PublishProtocol then") < function_body.index(
    "'Диагностика расхода стола'"
)
assert function_body.index("'Диагностика расхода стола'") < function_body.index(
    "'Итоговое решение о готовности установки'"
)
assert "FLastPointSetupReadyProtocolMs := CurrentMs;" in function_body

reset_runtime_start = source.index("procedure TMeasurementRun.ResetRuntimeContext;")
reset_runtime_end = source.index(
    "procedure TMeasurementRun.FinalizeMeasurementRun", reset_runtime_start
)
assert "FLastPointSetupReadyProtocolMs := -1;" in source[
    reset_runtime_start:reset_runtime_end
]

reset_point_start = source.index("procedure TMeasurementRun.ResetPointSetupState;")
reset_point_end = source.index(
    "procedure TMeasurementRun.StartNewStabilityAttempt;", reset_point_start
)
assert "FLastPointSetupReadyProtocolMs := -1;" in source[
    reset_point_start:reset_point_end
]

conditions_start = source.index(
    "function TMeasurementRun.IsConditionsStable(out StableInfo: RStableInfo): Boolean;"
)
conditions_end = source.index(
    "function TMeasurementRun.IsDevicesStable(out StableInfo: RStableInfo): Boolean;",
    conditions_start,
)
conditions_body = source[conditions_start:conditions_end]

assert "FPressureNotControlledLogged: Boolean;" in source
assert "FTemperatureNotControlledLogged: Boolean;" in source
assert "if not FTemperatureNotControlledLogged then" in conditions_body
assert "if not FPressureNotControlledLogged then" in conditions_body
assert "FTemperatureNotControlledLogged := True;" in conditions_body
assert "FPressureNotControlledLogged := True;" in conditions_body
assert "FTemperatureNotControlledLogged := False;" in conditions_body
assert "FPressureNotControlledLogged := False;" in conditions_body
assert "FLastPointDecisionLogMs := TMeterValue.GetMonotonicTimeMs;" in conditions_body

enter_start = source.index("procedure TMeasurementRun.EnterWaitPointSetup;")
enter_end = source.index("procedure TMeasurementRun.LoadRequiredStabilization", enter_start)
enter_body = source[enter_start:enter_end]
assert "FPressureNotControlledLogged := False;" in enter_body
assert "FTemperatureNotControlledLogged := False;" in enter_body

print("OK: dynamic setup diagnostics are throttled and static control messages are state-based.")
