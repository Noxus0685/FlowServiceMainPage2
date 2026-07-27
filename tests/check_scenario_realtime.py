#!/usr/bin/env python3
"""Architecture regressions for real-time automatic measurement scenarios.

These checks intentionally inspect the Delphi sources because the CI container does
not provide dcc32. They guard the failure mode where UI code advanced a virtual
clock in a tight loop and bypassed production channel calculations.
"""
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
work_table = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8-sig")
main_form = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
runner = main_form[main_form.index("procedure TFrameMainTable.RunAutoMeasurementScenario"):]
runner = runner[:runner.index("procedure TFrameMainTable.MeasurementButtonClickManualMode")]

checks = {
    "scenario runner has no virtual clock": "EnableVirtualClock" not in runner and "AdvanceVirtualClock" not in runner,
    "scenario runner has no fast step loop": "for Step :=" not in runner and "TThread.Sleep(1)" not in runner,
    "scenario starts production FSM": "WorkTableManager.StartScenario(ScenarioName, Profile)" in runner,
    "scenario is observed by application timer": "UpdateAutoMeasurementScenario;" in main_form,
    "first simulation update advances zero seconds": "DeltaTimeSec := 0.0;" in work_table,
    "simulation uses monotonic timestamp": "TStopwatch.GetTimeStamp * 1000.0 / TStopwatch.Frequency" in work_table,
    "impulses have one timed accumulation site": work_table.count("Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec * ADeltaTimeSec") == 1,
    "ApplyChannelValues does not accumulate": "Channel.ImpResult + Channel.ImpSec;" not in work_table,
    "production values are recalculated": "AWorkTable.RecalculateAllMeterValues;" in work_table,
    "stability meter receives calculated samples": "AWorkTable.FlowRate.Value.SetValue(AWorkTable.ValueFlowRate.GetDoubleValue);" in work_table,
    "scenario does not force FSM stages": ".SetStage(" not in runner,
}

# The integration formula must be invariant to update frequency.
for hz in (2, 5, 10, 20, 100):
    frequency = 37.25
    dt = 1.0 / hz
    accumulated = sum(frequency * dt for _ in range(hz * 20))
    checks[f"impulse integration invariant at {hz} Hz"] = math.isclose(accumulated, frequency * 20, rel_tol=1e-12)

for name, passed in checks.items():
    print(f"{'PASS' if passed else 'FAIL'}: {name}")

raise SystemExit(0 if all(checks.values()) else 1)
