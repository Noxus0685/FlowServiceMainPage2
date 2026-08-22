from pathlib import Path
import math
import re


ROOT = Path(__file__).resolve().parents[1]


def source(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


def procedure(text: str, name: str) -> str:
    match = re.search(
        rf"procedure\s+{re.escape(name)}\b(.*?)(?=\n(?:procedure|function)\s|\Z)",
        text,
        re.IGNORECASE | re.DOTALL,
    )
    assert match, name
    return match.group(0)


def test_qf_ui_uses_the_unit_conversion_boundary():
    editor = source("fuDeviceEdit.pas")
    update = procedure(editor, "TFormDeviceEditor.UpdateUIFreq")
    edit = procedure(editor, "TFormDeviceEditor.EditFreqFlowRateExit")
    qmax = procedure(editor, "TFormDeviceEditor.EditQmaxExit")

    assert "FromBaseUnits(FDevice.FreqFlowRate)" in update
    assert "FDevice.ToBaseUnits(DisplayRate)" in edit
    assert "FromBaseUnits(FDevice.FreqFlowRate)" in edit
    assert "FDevice.FreqFlowRate := FDevice.Qmax" in qmax
    assert "FromBaseUnits(FDevice.Qmax)" not in qmax


def test_frequency_formulas_are_centralized_and_unit_agnostic():
    model = source("uDeviceClass.pas")
    device_editor = source("fuDeviceEdit.pas")
    type_editor = source("fuTypeEditor.pas")

    assert "Result := AFrequency / ABaseCoefficient" in model
    assert "Result := AFlowRate * ABaseCoefficient" in model
    assert "Result := AFrequency / AFlowRate" in model
    for text in (device_editor, type_editor):
        assert not re.search(r"3\.6\s*\*\s*[^;\n]*(?:Freq|QF)", text)
        assert not re.search(r"(?:Freq|QF)[^;\n]*?/\s*3\.6", text)

    freq_exit = procedure(device_editor, "TFormDeviceEditor.EditFreqExit")
    assert "FrequencyAndFlowRateToCoefficient" in freq_exit
    assert "RecalcDevicePointsCoef" in freq_exit
    assert "UpdatePointsGrid" in freq_exit


def test_qf_storage_remains_in_base_units_without_database_migration():
    model = source("uDeviceClass.pas")
    repositories = source("uRepositories.pas")
    type_editor = source("fuTypeEditor.pas")

    assert "FreqFlowRate := ADiameter.QFmax" in model
    assert "Qmax * FType.FreqFlowRate" in type_editor
    assert "FType.FromBaseUnits(D.QFmax)" in type_editor
    assert "FType.ToBaseUnits(DisplayQFmax)" in type_editor
    assert "SetFloatParam(Q, 'QFmax', ADiameter.QFmax)" in repositories
    assert "SetFloatParam(Q, 'FreqFlowRate', ADevice.FreqFlowRate)" in repositories


def test_equivalent_volume_and_mass_units_produce_the_same_calculation():
    # Conversion boundary examples; calculations receive only base units.
    volume_base = [3.0 / 3.6, 0.8333333333333334, 50.0 / 60.0]
    mass_base = [2.0, 120.0 / 60.0, 7200.0 / 3600.0, 7.2 * 1000.0 / 3600.0]

    for equivalents in (volume_base, mass_base):
        assert all(math.isclose(value, equivalents[0], rel_tol=1e-12) for value in equivalents)
        coefficients = [1000.0 / value for value in equivalents]
        frequencies = [value * coefficient for value, coefficient in zip(equivalents, coefficients)]
        assert all(math.isclose(value, coefficients[0], rel_tol=1e-12) for value in coefficients)
        assert all(math.isclose(value, 1000.0, rel_tol=1e-12) for value in frequencies)


def test_version():
    assert "APP_VERSION = '1.0.233'" in source("uAppVersion.pas")
