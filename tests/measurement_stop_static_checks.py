from pathlib import Path

root = Path(__file__).resolve().parents[1]
measurement_run = (root / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")
work_table = (root / "uWorkTable.pas").read_text(encoding="utf-8-sig")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def procedure_body(source: str, signature: str, next_signature: str) -> str:
    start = source.index(signature)
    end = source.index(next_signature, start)
    return source[start:end]


stop_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.Stop;",
    "procedure TMeasurementRun.Pause;",
)
handle_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.HandleCommand",
    "procedure TMeasurementRun.RunThreadProc;",
)
request_stop_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.RequestStop;",
    "procedure TMeasurementRun.Stop;",
)
process_measure_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.ProcessMeasure;",
    "procedure TMeasurementRun.ProcessResultsRead;",
)
work_table_stop_body = procedure_body(
    work_table,
    "procedure TWorkTable.StopTest;",
    "procedure TWorkTable.StopMonitor;",
)

require("FStopRequested: Boolean;" in measurement_run, "Stop request flag is missing")
require("Execute(mcStop);" in stop_body, "Public Stop must create mcStop command")
require("mcStop, mcCancel: RequestStop;" in handle_body, "mcStop must be handled by RequestStop")
require("if FStopRequested then" in request_stop_body, "Repeated Stop is not guarded")
require("StopWorkerThread;" in request_stop_body, "RequestStop must stop the worker")
require("SetStage(msNone);" in request_stop_body, "RequestStop must transition through SetStage")
require("FWorkTable.StopTest" not in request_stop_body, "RequestStop must not directly stop the physical test")
require("FWorkTable.StopTest" not in process_measure_body, "ProcessMeasure timeout must stop through DoExitStage")
require("FireAction(awtStopTest" in work_table_stop_body, "StopTest must publish awtStopTest")
require("DoStopTest" not in work_table_stop_body, "StopTest must not execute physical stop directly")
require("TThread.CurrentThread.ThreadID = LThread.ThreadID" in measurement_run,
        "StopWorkerThread must avoid waiting for itself")
require("if FStopRequested then" in measurement_run and "Break;" in measurement_run,
        "Worker loop must terminate on a stop request")

print("OK: measurement stop command architecture checks passed.")
