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
assert "CurrentMs - FLastPointSetupReadyProtocolMs >= 1000" in function_body
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

print("OK: IsPointSetupReady protocol messages are throttled as one 1000 ms block.")
