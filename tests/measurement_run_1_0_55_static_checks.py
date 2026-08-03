from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RUN = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")
BASE = (ROOT / "uBaseProcedures.pas").read_text(encoding="utf-8-sig")
DEVICE = (ROOT / "uDeviceClass.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def method(name: str, following: str) -> str:
    return RUN.split(f"procedure TMeasurementRun.{name}", 1)[1].split(
        f"procedure TMeasurementRun.{following}", 1
    )[0]


navigation = method("RequestPointNavigation", "Execute")
request_stop = method("RequestStop", "Stop")
skip = method("MarkCurrentPointSkipped", "MarkCurrentPointCancelled")
cancel = method("MarkCurrentPointCancelled", "ResetPointSetupState")
setter = method("SetPointStatus(APoint: TDevicePoint;\n  const AStatus: EMeasurementPointStatus; const AReason: string", "MarkCurrentPointSkipped")

assert "mptsSkipped = 19" in BASE
assert "mptsSkipped: Result := 'Пропущена'" in DEVICE
assert "mptsCancelled: Result := 'Отменено'" in DEVICE
assert "mptsDone, mptsInterrupted, mptsCancelled, mptsSkipped" in DEVICE

# A rejected boundary navigation exits before either the pending target or status changes.
assert navigation.index("if RejectionReason <> ''") < navigation.index("FForceNextPoint := ATargetIndex")
assert navigation.index("FForceNextPoint := ATargetIndex") < navigation.index("MarkCurrentPointSkipped")
assert navigation.count("MarkCurrentPointSkipped(ADirection, ATargetIndex)") == 2
assert "SetPointStatus(Point, mptsSkipped, ADirection + 'Point', ATargetIndex)" in skip
assert "mptsCancelled" not in skip.split("SetPointStatus", 1)[-1]

# Stop marks the saved point object cancelled after the production handler accepts it.
assert "MarkCurrentPointCancelled(ReasonSnapshot)" in request_stop
assert "ReasonSnapshot <> msrUserRollback" in request_stop
assert request_stop.index("MeasurementStopAccepted") < request_stop.index("MarkCurrentPointCancelled")
assert request_stop.index("MarkCurrentPointCancelled") < request_stop.index("'StopRequested'")
assert "SetPointStatus(Point, mptsCancelled, ReasonText, -1)" in cancel
assert "mptsSkipped" not in cancel.split("SetPointStatus", 1)[-1]
assert "mptsSaved" in cancel and "mptsMeasureError" in cancel

# Status publication is separate from mePointChanged and suppresses duplicates.
assert "if OldStatus = AStatus then" in setter
assert "MeasurementPointStatusChanged" in setter
assert "Notify(Integer(meStateChanged), APoint)" in setter
assert "mePointChanged" not in setter
assert "FPoints.IndexOf(APoint)" in setter

assert "APP_VERSION = '1.0.55'" in VERSION


FRAME = (ROOT / "frmMeasurementRun.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmMeasurementRun.fmx").read_text(encoding="utf-8-sig")

pause_click = FRAME.split("procedure TFrameMeasurementRun.SpeedButtonPauseClick", 1)[1].split(
    "procedure TFrameMeasurementRun.SpeedButtonPointDeleteClick", 1
)[0]
main_before = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")

assert "EnsureMeasurementRunSubscription" in pause_click
assert "LRun := GetMeasurementRun" in pause_click
assert "mcPause" not in pause_click and "mcResume" not in pause_click
assert pause_click.count("FActiveWorkTable.StopMeasurementRun") == 1
assert "MeasurementPauseButtonRawClick" in pause_click
assert pause_click.index("MeasurementPauseButtonRawClick") < pause_click.index("MeasurementStopRequested")
assert "RunStage in [msNone, msDone]" in pause_click
assert "MeasurementStopAccepted" in request_stop
assert "MeasurementStopRejected" in request_stop
assert "MeasurementStageExecutionAborted" in request_stop
assert "MeasurementElapsedTimeFrozen" in cancel
assert "Point.DateTime := Now" in cancel
assert "mptsCancelled, mptsSkipped" in setter or "mptsCancelled, mptsSkipped" in RUN
assert FMX.count("OnClick = SpeedButtonPauseClick") == 1
assert "StyleLookup = 'stoptoolbutton'" in FMX
assert "Action =" not in FMX.split("object SpeedButtonPause:", 1)[1].split("end", 1)[0]
