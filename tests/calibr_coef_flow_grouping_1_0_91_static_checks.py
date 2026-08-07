from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "frmCalibrCoefs.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def test_spillages_are_grouped_by_point_flow_accuracy():
    assert "TryGetSpillageFlowRange" in SOURCE
    assert "FindMatchedDevicePointForSpillage(ASpillage)" in SOURCE
    assert "NormalizeFlowAccuracyInput(DevicePoint.FlowAccuracy)" in SOURCE
    assert "SourcePoint.QFrom <= CurrentGroup.QTo + 1E-12" in SOURCE
    assert "SourcePoint.QTo >= CurrentGroup.QFrom - 1E-12" in SOURCE


def test_group_values_and_ranges_are_aggregated():
    assert "CurrentGroup.SumArg / CurrentGroup.Count" in SOURCE
    assert "CurrentGroup.SumValue / CurrentGroup.Count" in SOURCE
    assert "CurrentGroup.SumQ / CurrentGroup.Count" in SOURCE
    assert "CurrentGroup.QFrom := Min(CurrentGroup.QFrom, ASource.QFrom)" in SOURCE
    assert "CurrentGroup.QTo := Max(CurrentGroup.QTo, ASource.QTo)" in SOURCE


def test_recalculation_preserves_group_ranges():
    recalculate = SOURCE.split(
        "procedure TFrameCalibrCoefs.RecalculateCurrentTable;", 1
    )[1].split(
        "function TFrameCalibrCoefs.BuildCoefFromPoint", 1
    )[0]
    assert "Item.QFrom :=" not in recalculate
    assert "Item.QTo :=" not in recalculate
    assert "Item.K :=" in recalculate
    assert "Item.b :=" in recalculate


def test_project_version():
    assert "APP_VERSION = '1.0.91'" in VERSION
