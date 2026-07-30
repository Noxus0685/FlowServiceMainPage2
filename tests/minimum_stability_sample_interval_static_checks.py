from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
BASE = (ROOT / "uBaseProcedures.pas").read_text(encoding="utf-8")
METER = (ROOT / "uMeterValue.pas").read_text(encoding="utf-8")
FRAME = (ROOT / "frmMeterValueEditFrame.pas").read_text(encoding="utf-8")
FMX = (ROOT / "frmMeterValueEditFrame.fmx").read_text(encoding="utf-8")


def body(name: str) -> str:
    match = re.search(rf"procedure TMeterValue\.{name}\b.*?\nbegin\n(.*?)\nend;", METER, re.S)
    assert match, name
    return match.group(1)


def test_setting_default_validation_and_ini_roundtrip_are_present():
    assert "MinimumSampleIntervalSec: Double;" in BASE
    assert "FStabilitySettings.MinimumSampleIntervalSec := 0;" in METER
    assert "'MinimumSampleIntervalSec', MV.FStabilitySettings.MinimumSampleIntervalSec" in METER
    assert "'MinimumSampleIntervalSec', AMeterValue.FStabilitySettings.MinimumSampleIntervalSec" in METER
    assert "Минимальный интервал автоматической записи проб не может быть отрицательным." in METER


def test_automatic_sampling_is_atomic_monotonic_and_separate_from_manual_sampling():
    automatic = body("AddCurrentStabilitySample")
    manual = body("AddSample")
    assert "FLastAutomaticStabilitySampleMs: Int64;" in METER
    assert "procedure AddSampleLocked" in METER
    assert "if not FStabilitySettings.Enabled then" in automatic
    assert "CurrentTimeMs := GetMonotonicTimeMs;" in automatic
    assert "MinimumIntervalMs := Round(Max(0.0," in automatic
    assert "AddSampleLocked(Value, CurrentTimeMs);" in automatic
    assert automatic.index("AddSampleLocked(Value, CurrentTimeMs);") < automatic.index("FLastAutomaticStabilitySampleMs := CurrentTimeMs;")
    assert "AddSampleLocked(AValue, ATimeStampMs);" in manual
    assert "MinimumSampleIntervalSec" not in manual
    assert "FLastAutomaticStabilitySampleMs" not in manual


def test_full_history_clears_reset_automatic_timestamp_but_analysis_reset_does_not():
    for name in ("ClearSamplesHistory", "ClearStabilitySamples"):
        clear = body(name)
        assert "FSamples.Clear;" in clear
        assert "FLastAutomaticStabilitySampleMs := 0;" in clear
    assert "FLastAutomaticStabilitySampleMs" not in body("ResetStabilityInfo")


def test_ui_control_binding_format_comparison_and_validation_are_present():
    for source in (FRAME, FMX):
        assert "LabelMinimumSampleIntervalSec" in source
        assert "EditMinimumSampleIntervalSec" in source
    assert "EditMinimumSampleIntervalSec.OnExit := HandleSettingsChange;" in FRAME
    assert "FormatFloat('0.########', FTestSettings.MinimumSampleIntervalSec)" in FRAME
    assert "TryReadFloat(EditMinimumSampleIntervalSec.Text, ASettings.MinimumSampleIntervalSec);" in FRAME
    assert "SameValue(ALeft.MinimumSampleIntervalSec, ARight.MinimumSampleIntervalSec, 1E-9)" in FRAME
    assert "Минимальный интервал автоматических проб должен быть числом." in FRAME
    assert "Минимальный интервал автоматических проб не может быть отрицательным." in FRAME
