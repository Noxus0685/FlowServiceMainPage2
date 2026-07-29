from pathlib import Path
import re


root = Path(__file__).resolve().parents[1]
measurement_run = (root / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")
work_table = (root / "uWorkTable.pas").read_text(encoding="utf-8-sig")
pascal_sources = "\n".join(
    path.read_text(encoding="utf-8-sig", errors="ignore")
    for path in root.glob("*.pas")
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


reset_start = work_table.index("procedure TWorkTable.ResetCurrentPoint;")
reset_end = work_table.index("procedure TWorkTable.ResetMeasurementValues;", reset_start)
reset_body = work_table[reset_start:reset_end]

runtime_start = measurement_run.index("procedure TMeasurementRun.ResetRuntimeContext;")
runtime_end = measurement_run.index("procedure TMeasurementRun.FinalizeMeasurementRun", runtime_start)
runtime_body = measurement_run[runtime_start:runtime_end]

require(
    "property CurrentPoint: TDevicePoint read FCurrentPoint;" in work_table,
    "CurrentPoint must be read-only so callers cannot replace the owned object",
)
require(
    not re.search(r"\.CurrentPoint\s*:=", pascal_sources),
    "External CurrentPoint replacement remains in a Pascal source",
)
require(
    "FWorkTable.ResetCurrentPoint;" in runtime_body,
    "ResetRuntimeContext must reset, rather than discard, CurrentPoint",
)
require(
    "FWorkTable.CurrentPoint := nil" not in runtime_body,
    "ResetRuntimeContext must not discard the CurrentPoint reference",
)
require(
    "if FCurrentPoint = nil then" in reset_body
    and "FCurrentPoint := TDevicePoint.Create(0);" in reset_body,
    "ResetCurrentPoint must repair the owned point only when it is unexpectedly nil",
)
for assignment in (
    "FCurrentPoint.LimitTime := -1;",
    "FCurrentPoint.LimitImp := -1;",
    "FCurrentPoint.LimitVolume := -1;",
    "FCurrentPoint.StopCriteria := [];",
    "FInstalledMeasurementPointUUID := '';",
    "FInstalledMeasurementPointIndex := -1;",
    "FInstalledMeasurementTargetFlowLS := 0;",
):
    require(assignment in reset_body, f"ResetCurrentPoint is missing: {assignment}")

print("OK: CurrentPoint ownership and reset lifecycle checks passed.")
