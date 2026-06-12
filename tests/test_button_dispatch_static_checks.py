from pathlib import Path

root = Path(__file__).resolve().parents[1]
main_table = (root / "frmMainTable.pas").read_text(encoding="utf-8-sig")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def method_body(signature: str, next_signature: str) -> str:
    start = main_table.index(signature)
    end = main_table.index(next_signature, start)
    return main_table[start:end]


save_mode_body = method_body(
    "function TFrameMainTable.IsTestButtonSaveMode: Boolean;",
    "function TFrameMainTable.IsMeasurementActive",
)
measurement_active_body = method_body(
    "function TFrameMainTable.IsMeasurementActive",
    "function TFrameMainTable.NeedSaveMeasurementResults",
)
need_save_body = method_body(
    "function TFrameMainTable.NeedSaveMeasurementResults",
    "procedure TFrameMainTable.AcceptMeasurementResults;",
)
accept_body = method_body(
    "procedure TFrameMainTable.AcceptMeasurementResults;",
    "procedure TFrameMainTable.TestButtonClick",
)
click_body = method_body(
    "procedure TFrameMainTable.TestButtonClick",
    "procedure TFrameMainTable.Button1Click",
)

require("(TestButton <> nil)" in save_mode_body, "Save-mode check must tolerate a missing button")
require("(TestButton.Tag = 6)" in save_mode_body, "Save-mode check must preserve Tag compatibility")
require("SameText(Trim(TestButton.Text), 'Сохранить?')" in save_mode_body,
        "Save-mode check must preserve the confirmation text")

for state in ("swtSTARTTEST", "swtSTARTWAIT", "swtEXECUTE", "swtSTOPTEST", "swtSTOPWAIT"):
    require(state in measurement_active_body, f"Active-measurement check is missing {state}")
require("not (Run.Stage in [msNone, msDone])" in measurement_active_body,
        "Active-measurement check must account for the measurement run stage")

for condition in ("Channel.Enabled", "Channel.FlowMeter <> nil", "Channel.FlowMeter.Device <> nil",
                  "Channel.FlowMeter.Device.Spillages = nil", "Channel.FlowMeter.Device.Spillages.Count = 0"):
    require(condition in need_save_body, f"Result-save predicate is missing: {condition}")

for operation in ("NeedSaveMeasurementResults(WorkTable)", "WorkTable.SaveMeasurementResults;",
                  "DataManager.Save;", "WorkTableManager.Save;", "WorkTable.State := swtCONNECTED;"):
    require(operation in accept_body, f"AcceptMeasurementResults is missing: {operation}")
require("'AcceptResults'" in accept_body, "AcceptMeasurementResults must write a protocol message")
require("swtSTANDBY" not in accept_body, "AcceptMeasurementResults must not force the standby state")

for dispatch in ("IsTestButtonSaveMode", "AcceptMeasurementResults;", "IsMeasurementActive(WorkTable)",
                 "StopMeasurement", "StartMeasurement"):
    require(dispatch in click_body, f"TestButtonClick is missing dispatch call: {dispatch}")
for forbidden in ("SaveMeasurementResults", "DataManager.Save", "WorkTableManager.Save", "WorkTable.State",
                  "TestButton.Tag", "TestButton.Text", "MeasurementRun", "DeviceChannels"):
    require(forbidden not in click_body, f"TestButtonClick still contains business logic: {forbidden}")

print("OK: main measurement button dispatch checks passed.")
