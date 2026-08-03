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
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
start_body = MAIN.split("procedure TFrameMainTable.StartMeasurement;", 1)[1].split("procedure TFrameMainTable.StopMeasurement;", 1)[0]
stop_body = MAIN.split("procedure TFrameMainTable.StopMeasurement;", 1)[1].split("procedure TFrameMainTable.SwitchAutoSwitch", 1)[0]
switch_body = MAIN.split("procedure TFrameMainTable.ApplyMeasurementModeFromSwitch;", 1)[1].split("procedure TFrameMainTable.UpdateForm;", 1)[0]
assert "BuildManualMeasurementPoint;" not in start_body
assert "Points[0]" not in start_body
assert "CurrentPointIndex := 0" not in MAIN
assert "FActiveWorkTable.StartMeasurementRun" in start_body
assert "FActiveWorkTable.StopMeasurementRun" in stop_body
assert "RebuildMeasurementPoints" not in start_body
assert "ManualPointReused" in start_body
assert "BuildManualMeasurementPoint" in switch_body
assert "ManualPointSetCleared" in MAIN
assert "ManualPointCreated" in MAIN
assert "AutoPointSetRestored" in switch_body
assert "UpdatePauseButtonState" in FORM
assert ".Click" not in FORM
assert "UpdateUI;" not in previous
assert "UpdateUI;" not in next_point
assert "TThread.Queue" not in previous and "TThread.Queue" not in next_point
assert "CurrentPointIndex :=" not in previous and "CurrentPointIndex :=" not in next_point
assert "OnClick = SpeedButtonPointPrevClick" in FMX
assert "OnClick = SpeedButtonPointNextClick" in FMX
assert "OnClick = SpeedButtonPauseClick" in FMX
assert "OnClick = SpeedButtonPointMoveUpClick" in FMX
assert "OnClick = SpeedButtonPointMoveDownClick" in FMX
assert "OnClick :=" not in FORM
assert "APP_VERSION = '1.0.52'" in VERSION
for relative in ("frmMeasurementRun.pas", "frmMeasurementRun.fmx", "uMeasurementRun.pas", "uAppVersion.pas"):
    assert (ROOT / relative).read_bytes().startswith(b"\xef\xbb\xbf")

# Version 1.0.51 UI state regressions.
assert "UpdateMeasurementStartStopButton" in MAIN
assert "FLastMeasurementMainButtonAction: string;" in MAIN
assert "MeasurementMainButtonUpdated" in MAIN
assert "MeasurementStopRequested" in MAIN
assert "FActiveWorkTable.StopMeasurementRun" in stop_body
assert "RebuildMeasurementPoints" not in stop_body
assert "StartMeasurementRun" not in stop_body
assert "FSubscribedMeasurementRun" in FORM
assert "EnsureMeasurementRunSubscription" in FORM
assert "OnSelChanged = GridMeasurmentRunSelChanged" in FMX
restore_body = FORM.split("procedure TFrameMeasurementRun.RestorePointsGridSelectionAndFocus", 1)[1].split("procedure TFrameMeasurementRun.UpdateCurrentPointIndicator", 1)[0]
assert "GridMeasurmentRun.Row := ResolvedRow" in restore_body
assert restore_body.index("GridMeasurmentRun.Row := ResolvedRow") < restore_body.index("UpdatePointOrderControls")
assert "UpdatePointOrderControls" in restore_body.split("TThread.Queue", 1)[1]
pause_state = FORM.split("procedure TFrameMeasurementRun.UpdatePauseButtonState", 1)[1].split("function TFrameMeasurementRun.ResolvePointRow", 1)[0]
assert "mcPause" not in pause_state and "mcResume" not in pause_state

# Version 1.0.52 subscription checks.
set_active = FORM.split("procedure TFrameMeasurementRun.SetActiveWorkTable", 1)[1].split("procedure TFrameMeasurementRun.AttachMeasurementRunEvents", 1)[0]
detach = FORM.split("procedure TFrameMeasurementRun.DetachMeasurementRunEvents", 1)[1].split("procedure TFrameMeasurementRun.EnsureMeasurementRunSubscription", 1)[0]
update_ui = FORM.split("procedure TFrameMeasurementRun.UpdateUI", 1)[1].split("procedure TFrameMeasurementRun.RefreshFromMeasurementRun", 1)[0]
on_notify = FORM.split("procedure TFrameMeasurementRun.OnNotify", 1)[1].split("procedure TFrameMeasurementRun.MeasurementRunStateChanged", 1)[0]
point_changed = FORM.split("procedure TFrameMeasurementRun.MeasurementRunPointChanged", 1)[1].split("procedure TFrameMeasurementRun.MeasurementRunEvent", 1)[0]
assert "FSubscribedMeasurementRun: TMeasurementRun" in FORM
assert "FSubscribedMeasurementRun.Unsubscribe(Self)" in detach or "OldRun.Unsubscribe(Self)" in detach
assert "EnsureMeasurementRunSubscription" in set_active
assert "EnsureMeasurementRunSubscription" in update_ui
assert "Sender <> FSubscribedMeasurementRun" in on_notify
assert "ASender <> FSubscribedMeasurementRun" in point_changed
assert "SyncCurrentPointFromSubscribedRun" in FORM
assert "MeasurementRunSubscriptionChanged" in FORM
assert "MeasurementRunSubscriptionDetached" in FORM
assert "MeasurementRunEventIgnored" in FORM
assert previous.index("EnsureMeasurementRunSubscription") < previous.index("mcPreviousPoint")
assert next_point.index("EnsureMeasurementRunSubscription") < next_point.index("mcNextPoint")
assert "GridMeasurmentRun.Row" not in previous and "GridMeasurmentRun.Selected" not in previous
assert "GridMeasurmentRun.Row" not in next_point and "GridMeasurmentRun.Selected" not in next_point
