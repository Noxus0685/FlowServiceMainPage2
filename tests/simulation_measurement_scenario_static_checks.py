from pathlib import Path


source = (Path(__file__).resolve().parents[1] / "uWorkTable.pas").read_text(
    encoding="utf-8-sig"
)

checks = {
    "configurable scenario object": all(
        token in source
        for token in (
            "TSimulationTestScenario = class",
            "TargetWorkTable",
            "TargetDeviceChannel",
            "Factor",
            "OffsetImpSec",
            "NoisePercent",
            "StartDelaySec",
            "DurationSec",
        )
    ),
    "production automatic start API": all(
        token in source
        for token in (
            "MeasurementMode := mrmAutomatic",
            "StartMeasurementRun;",
            "StopMeasurementRun;",
        )
    ),
    "scenario is gated by simulation and selected device": all(
        token in source
        for token in (
            "if FIsSimulationMode and",
            "(AWorkTable = FTargetWorkTable)",
            "(AChannel = FTargetDeviceChannel)",
            "FAutomaticTestActive",
        )
    ),
    "factor is applied before normal accumulation": (
        source.index("Channel.ImpSec := Scenario.AdjustImpSec")
        < source.index(
            "AccumulateSimulationChannelImpResult(AWorkTable.DeviceChannels",
            source.index("Channel.ImpSec := Scenario.AdjustImpSec"),
        )
    ),
    "scenario never enters etalon updater": "Scenario.AdjustImpSec" not in source[
        source.index("procedure UpdateEtalonChannelSignals") : source.index(
            "procedure UpdateDeviceChannelSignals"
        )
    ],
    "cleanup restores pre-test simulation mode": all(
        token in source
        for token in (
            "FSimulationModeBeforeTest := FIsSimulationMode",
            "FIsSimulationMode := FSimulationModeBeforeTest",
            "FSimulationTestScenario.Clear",
        )
    ),
}

failed = [name for name, passed in checks.items() if not passed]
if failed:
    raise SystemExit("FAILED simulation scenario checks: " + "; ".join(failed))
print("OK: simulation scenario targeting, accumulation, start, and cleanup checks passed.")
