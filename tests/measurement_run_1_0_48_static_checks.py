from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FORM = (ROOT / "frmMeasurementRun.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmMeasurementRun.fmx").read_text(encoding="utf-8-sig")
RUN = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def handler(name: str, following: str) -> str:
    return FORM.split(f"procedure TFrameMeasurementRun.{name}", 1)[1].split(
        f"procedure TFrameMeasurementRun.{following}", 1
    )[0]


previous = handler("SpeedButtonPointPrevClick", "SpeedButtonPointNextClick")
next_point = handler("SpeedButtonPointNextClick", "SpeedButtonPointMoveUpClick")
assert "mcPreviousPoint" in previous and "MovePoint" not in previous
assert "mcNextPoint" in next_point and "MovePoint" not in next_point
assert "MeasurementRun.MovePointUp" in FORM
assert "MeasurementRun.MovePointDown" in FORM
assert "CapturePointsGridState" in FORM
assert "RestorePointsGridSelectionAndFocus" in FORM
assert "TThread.Queue" in FORM
assert "ScrollToSelectedCell" in FORM
assert "StringColumnPointer" in FMX and "Value := '▶'" in FORM
assert "CheckBoxMergePoints" in FMX
assert "if FMergePoints then" in RUN
assert "APP_VERSION = '1.0.48'" in VERSION
for relative in ("frmMeasurementRun.pas", "frmMeasurementRun.fmx", "uMeasurementRun.pas", "uAppVersion.pas"):
    assert (ROOT / relative).read_bytes().startswith(b"\xef\xbb\xbf")
