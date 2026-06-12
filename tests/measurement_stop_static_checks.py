from pathlib import Path

root = Path(__file__).resolve().parents[1]
measurement_run = (root / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")
base_procedures = (root / "uBaseProcedures.pas").read_text(encoding="utf-8-sig")
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
run_thread_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.RunThreadProc;",
    "function TMeasurementRun.ValidatePoint",
)
do_exit_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.DoExitStage",
    "procedure TMeasurementRun.DoEnterStage",
)
enter_start_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.EnterWaitMeasureStart;",
    "procedure TMeasurementRun.EnterMeasure;",
)
enter_measure_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.EnterMeasure;",
    "procedure TMeasurementRun.EnterWaitMeasureStop;",
)
enter_stop_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.EnterWaitMeasureStop;",
    "procedure TMeasurementRun.EnterResultsRead;",
)
enter_results_body = procedure_body(
    measurement_run,
    "procedure TMeasurementRun.EnterResultsRead;",
    "procedure TMeasurementRun.EnterSave;",
)
work_table_stop_body = procedure_body(
    work_table,
    "procedure TWorkTable.StopTest;",
    "procedure TWorkTable.StopMonitor;",
)

require("msWaitMeasureStart" in base_procedures, "Wait-for-start state is missing")
require("msWaitMeasureStop" in base_procedures, "Wait-for-stop state is missing")
require("msStartMeasure" not in base_procedures, "Start action must not be represented as a state")
require("msStopMeasure" not in base_procedures, "Stop action must not be represented as a state")

require("Execute(mcStop);" in stop_body, "Public Stop must create mcStop command")
require("mcStop, mcCancel: RequestStop;" in handle_body, "mcStop must be handled by RequestStop")
require("if FStopRequested then" in request_stop_body, "Repeated Stop is not guarded")
require("SetStage(msWaitMeasureStop);" in request_stop_body, "Active measurement must stop through msWaitMeasureStop")
require("StopWorkerThread;" not in request_stop_body, "RequestStop must allow the FSM to stop gracefully")
require("FWorkTable.StopTest" not in request_stop_body, "RequestStop must not directly stop the physical test")
require("msWaitMeasureStop" in run_thread_body, "Worker loop must process graceful measurement stop")
require("if FStopRequested then\n      Break;" not in run_thread_body, "Worker loop must not immediately break on stop request")

require("FWorkTable.StopTest" not in do_exit_body, "DoExitStage must not stop a physical test")
require("FWorkTable.StartTest;" in enter_start_body, "StartTest must be an msWaitMeasureStart entry action")
require("meMeasureStarted" not in enter_start_body, "meMeasureStarted must wait for actual execution")
require("FireEvent(meMeasureStarted);" in enter_measure_body, "msMeasure entry must announce actual execution")
require("FWorkTable.StopTest;" in enter_stop_body, "StopTest must be an msWaitMeasureStop entry action")
require("FWorkTable.SaveMeasurementResults;" in enter_results_body, "Result reading must be an entry action")

process_names = [
    "ProcessSelectPoint",
    "ProcessSelectEtalon",
    "ProcessSetupPoint",
    "ProcessWaitStable",
    "ProcessWaitMeasureStart",
    "ProcessMeasure",
    "ProcessWaitMeasureStop",
    "ProcessResultsRead",
    "ProcessSave",
    "ProcessDone",
]
for index, name in enumerate(process_names):
    signature = f"procedure TMeasurementRun.{name};"
    start = measurement_run.index(signature)
    if index + 1 < len(process_names):
        next_signature = f"procedure TMeasurementRun.{process_names[index + 1]};"
        end = measurement_run.index(next_signature, start)
    else:
        end = measurement_run.index("procedure TMeasurementRun.SaveMeasurementResults;", start)
    body = measurement_run[start:end]
    for forbidden in (
        "FWorkTable.StartTest",
        "FWorkTable.StopTest",
        "FWorkTable.SaveMeasurementResults",
        "FWorkTable.StartMonitor",
        "FWorkTable.StopMonitor",
        "SaveMeasurementResults;",
        "SetupPoint(",
        "SetupMeasurement(",
        "SelectEtalons(",
    ):
        require(forbidden not in body, f"{name} contains physical/action logic: {forbidden}")

require("FireAction(awtStopTest" in work_table_stop_body, "StopTest must publish awtStopTest")
require("DoStopTest" not in work_table_stop_body, "StopTest must not execute physical stop directly")
require("TThread.CurrentThread.ThreadID = LThread.ThreadID" in measurement_run,
        "StopWorkerThread must avoid waiting for itself")

print("OK: measurement FSM entry-action and graceful-stop checks passed.")
