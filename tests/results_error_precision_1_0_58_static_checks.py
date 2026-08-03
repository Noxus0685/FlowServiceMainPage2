from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESULTS = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
PROCESSING = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
DPR = (ROOT / "ProjectFornTest.dpr").read_text(encoding="utf-8-sig")
DPROJ = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def _method(source: str, start: str, end: str) -> str:
    body = source[source.index(start):]
    return body[:body.index(end)]


def _processing_precision(value: float) -> str:
    return f"{value:.3f}".rstrip("0").rstrip(".").replace(".", ",")


def test_actual_errors_match_processing_precision():
    processing_cell = "FormatFloat('0.###', Spillage.Error)"
    assert processing_cell in PROCESSING
    formatter = _method(
        RESULTS,
        "function TFrameMRResults.FormatActualErrorValue",
        "function TFrameMRResults.FormatSpillageErrors",
    )
    assert "FormatFloat('0.###', AValue)" in formatter
    assert [_processing_precision(v) for v in (-0.126, -0.452, -0.214)] == [
        "-0,126", "-0,452", "-0,214"
    ]


def test_unavailable_double_marker_is_not_rendered_as_an_error():
    formatter = _method(
        RESULTS,
        "function TFrameMRResults.FormatActualErrorValue",
        "function TFrameMRResults.FormatSpillageErrors",
    )
    assert "AValue <= -MaxDouble" in formatter
    assert "IsNan(AValue)" in formatter
    assert "IsInfinite(AValue)" in formatter
    assert "Exit('-')" in formatter


def test_only_actual_results_use_processing_precision():
    assert "FormatActualErrorValue(S.Error)" in RESULTS
    assert "FormatActualErrorValue(ASpillage.Error)" in RESULTS
    assert "FormatActualErrorValue(ACurrentError)" in RESULTS
    tolerance = _method(
        RESULTS,
        "function TFrameMRResults.FormatErrorValue",
        "function TFrameMRResults.FormatActualErrorValue",
    )
    assert "ValueError.GetStrNumLimits(AValue)" in tolerance


def test_previous_results_architecture_is_restored():
    for source in (RESULTS, PROCESSING, DPR, DPROJ):
        assert "uResultPresentation" not in source
    assert not (ROOT / "uResultPresentation.pas").exists()
    for forbidden in (
        "FDisplayPoints", "MRResultsPointBinding",
        "FormatResultErrorValue", "GetPointResultColor", "GetDeviceResultColor",
    ):
        assert forbidden not in RESULTS
        assert forbidden not in PROCESSING
    point_lookup = _method(
        RESULTS,
        "function TFrameMRResults.FindPointSpillage",
        "function TFrameMRResults.FormatPointHeader",
    )
    assert "FindMatchedDevicePointForSpillage" not in point_lookup
    assert "MeasurementRun.Points[Idx]" in RESULTS
    assert "TMeasurementRun.IsPointEquivalent(ASessionPoint, S)" in RESULTS
    assert "csDoneValid" in RESULTS and "csDoneWarning" in RESULTS
