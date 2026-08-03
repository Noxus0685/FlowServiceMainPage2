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

assert "APP_VERSION = '1.0.56'" in VERSION


FRAME = (ROOT / "frmMeasurementRun.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmMeasurementRun.fmx").read_text(encoding="utf-8-sig")

pause_click = FRAME.split("procedure TFrameMeasurementRun.SpeedButtonPauseClick", 1)[1].split(
    "procedure TFrameMeasurementRun.SpeedButtonPointDeleteClick", 1
)[0]
main_before = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")

assert "EnsureMeasurementRunSubscription" in pause_click
assert "LRun := GetMeasurementRun" in pause_click
assert "if LRun.IsPaused then" in pause_click
assert "LRun.Execute(mcPause, Null)" in pause_click
assert "LRun.Execute(mcResume, Null)" in pause_click
for forbidden in ["MeasurementPauseButtonRawClick", "MeasurementStopRequested",
                  "MeasurementStopAccepted", "MeasurementStopRejected",
                  "MeasurementStopCompleted", "MeasurementStageExecutionAborted",
                  "MeasurementElapsedTimeFrozen", "StopMeasurementRun", "mcStop",
                  "RequestStop", "StopTest", "MarkCurrentPointCancelled",
                  "MarkCurrentPointSkipped", "SetStage(msDone)", "SetStage(msNone)"]:
    assert forbidden not in pause_click
for forbidden in ["CurrentPoint :=", "CurrentPointIndex :=", "mptsCancelled", "mptsSkipped"]:
    assert forbidden not in pause_click
assert "Source=SpeedButtonPauseClick" not in FRAME
assert FMX.count("OnClick = SpeedButtonPauseClick") == 1
pause_fmx = FMX.split("object SpeedButtonPause:", 1)[1].split("end", 1)[0]
assert "StyleLookup = 'pausetoolbuttonbordered'" in pause_fmx
assert "stoptoolbutton" not in pause_fmx.lower()
assert "cancel" not in pause_fmx.lower()
assert "Action =" not in pause_fmx and "OnExecute =" not in pause_fmx
pause_state = FRAME.split("procedure TFrameMeasurementRun.UpdatePauseButtonState", 1)[1].split(
    "function TFrameMeasurementRun.ResolvePointRow", 1)[0]
assert "LRun.IsPaused" in pause_state
assert "playtoolbuttonbordered" in pause_state
assert "pausetoolbuttonbordered" in pause_state
assert "SpeedButtonPause.Enabled" in pause_state
assert "mcPause" not in pause_state and "mcResume" not in pause_state
assert "stoptoolbutton" not in pause_state

controls = FRAME.split("procedure TFrameMeasurementRun.UpdateMeasurementControls", 1)[1].split(
    "procedure TFrameMeasurementRun.UpdatePauseButtonState", 1)[0]
assert "LRun.CurrentPointIndex" in controls
assert "LRun.Points.Count" in controls
assert "LRun.CurrentPoint <> nil" in controls
assert "SpeedButtonPointPrev.Enabled := LHasCurrentPoint and (LIndex > 0)" in controls
assert "SpeedButtonPointNext.Enabled := LHasCurrentPoint and (LIndex < LCount - 1)" in controls
assert "GridMeasurmentRun.Row" not in controls

manual = main_before.split("procedure TFrameMainTable.BuildManualMeasurementPoint", 1)[1].split(
    "procedure TFrameMainTable.UpdatePreparedManualPoint", 1)[0]
mode_switch = main_before.split("procedure TFrameMainTable.ApplyMeasurementModeFromSwitch", 1)[1].split(
    "procedure TFrameMainTable.UpdateForm", 1)[0]
assert "Run.Points.Clear" in manual
assert "Run.InvalidatePreparedPoints" in manual
assert "Run.RebuildMeasurementPoints" in manual
assert "Run.Points.Count = 1" in manual
assert "Point := Run.CurrentPoint" in manual
assert "SourceUUID := FActiveWorkTable.CurrentPoint.UUID" in manual
assert "SameText(Point.UUID, SourceUUID)" in manual
assert "Point.UUID := TGUID.NewGuid.ToString" in manual
assert "Points[0]" not in manual and "Run.Points.First" not in manual
assert "if NewMode = mrmManual then\n    BuildManualMeasurementPoint" in mode_switch
assert "Run.InvalidatePreparedPoints" in mode_switch
assert "Run.RebuildMeasurementPoints" in mode_switch
