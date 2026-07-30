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
    assert "FStabilitySettings.MinimumSampleIntervalSec := 0.8;" in METER
    assert re.search(
        r"MV\.FStabilitySettings\.MinimumSampleIntervalSec\s*:=\s*Ini\.ReadFloat\(Section,\s*"
        r"'MinimumSampleIntervalSec',\s*MV\.FStabilitySettings\.MinimumSampleIntervalSec\);",
        METER,
    )
    assert re.search(
        r"AMeterValue\.FStabilitySettings\.MinimumSampleIntervalSec\s*:=\s*Ini\.ReadFloat\(ASection,\s*"
        r"'MinimumSampleIntervalSec',\s*AMeterValue\.FStabilitySettings\.MinimumSampleIntervalSec\);",
        METER,
    )
    assert "'MinimumSampleIntervalSec', 0" not in METER
    assert "По умолчанию 0,8 секунды." in BASE
    assert "Значение 0 отключает прореживание." in BASE
    assert "Минимальный интервал автоматической записи проб не может быть отрицательным." in METER


def test_automatic_sampling_is_atomic_monotonic_and_separate_from_manual_sampling():
    automatic = body("AddCurrentStabilitySample")
    manual = body("AddSample")
    assert "FLastAutomaticStabilitySampleMs: Int64;" in METER
    assert "TMeterValueSampleSource = (" in METER
    assert "mssAutomatic" in METER and "mssManual" in METER
    assert "AddSampleLocked" not in METER
    assert re.search(r"function AddStabilitySample\s*\([^)]*\)\s*:\s*Boolean;", METER, re.S)
    assert "AddStabilitySample(Value, GetMonotonicTimeMs, mssAutomatic);" in automatic
    assert "FSampleLock" not in automatic
    assert "AddStabilitySample(AValue, ATimeStampMs, mssManual);" in manual
    assert "FSampleLock" not in manual
    assert "SampleCountBefore" not in METER
    assert "FSamples.Count > SampleCountBefore" not in METER


def test_unified_addition_handles_source_interval_duplicates_and_history_trim():
    match = re.search(
        r"function TMeterValue\.AddStabilitySample\b(.*?)\nprocedure TMeterValue\.AddSample",
        METER,
        re.S,
    )
    assert match
    unified = match.group(1)
    assert "Result := False;" in unified
    assert "if IsNan(AValue) or IsInfinite(AValue) then" in unified
    assert "FSampleLock.Enter;" in unified and "FSampleLock.Leave;" in unified
    assert "if not FStabilitySettings.Enabled then" in unified
    assert "MinimumIntervalMs := Round(Max(0.0," in unified
    assert "if Sample.TimeStampMs < LastTimeStampMs then\n        Exit;" in unified
    duplicate = re.search(
        r"if Sample\.TimeStampMs = LastTimeStampMs then\s*begin\s*"
        r"if ASource = mssAutomatic then\s*Exit;\s*Inc\(Sample\.TimeStampMs\);",
        unified,
        re.S,
    )
    assert duplicate
    assert "FLastAutomaticStabilitySampleMs := ATimeStampMs;" in unified
    add_index = unified.index("FSamples.Add(Sample);")
    trim_index = unified.index("TrimStabilityHistory;")
    success_index = unified.index("Result := True;")
    assert add_index < trim_index < success_index


def test_special_manual_entry_uses_unified_method_for_new_samples():
    match = re.search(
        r"function TMeterValue\.AddStabilitySampleManual\b(.*?)\nfunction TMeterValue\.UpdateStabilitySampleValue",
        METER,
        re.S,
    )
    assert match
    assert "Result := AddStabilitySample(AValue, ATimeStampMs, mssManual);" in match.group(1)


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
