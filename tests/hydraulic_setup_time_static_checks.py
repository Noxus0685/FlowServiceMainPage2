from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
work_table = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8-sig")
measurement_run = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")


range_record = re.search(
    r"RWorkTableHydraulicRange\s*=\s*record(?P<body>.*?)\n\s*end;",
    work_table,
    re.DOTALL,
)
assert range_record, "RWorkTableHydraulicRange record was not found"
assert re.search(r"\bSetupTime\s*:\s*Byte\s*;", range_record.group("body")), (
    "SetupTime must be retained in the independent hydraulic range snapshot"
)

setup_proc = re.search(
    r"procedure\s+TMeasurementRun\.ProcessSetupHydraulicLine\s*;"
    r"(?P<body>.*?)\nend;",
    measurement_run,
    re.DOTALL,
)
assert setup_proc, "ProcessSetupHydraulicLine was not found"
setup_body = setup_proc.group("body")
assert "if SetupTime = 0 then" in setup_body
assert "SetupTimeoutMs := HYDRAULIC_SETUP_TIMEOUT_MS" in setup_body
assert "SetupTimeoutMs := UInt64(SetupTime) * 1000" in setup_body
assert re.search(
    r"GetMonotonicTimeMs\s*-\s*FWaitStartedTick\)\s*>=\s*"
    r"SetupTimeoutMs",
    setup_body,
)
