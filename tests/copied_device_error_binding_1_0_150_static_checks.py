from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
work_table = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8-sig")
main_table = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
version = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
project = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def body(source: str, start: str, end: str) -> str:
    begin = source.index(start)
    finish = source.index(end, begin)
    return source[begin:finish]


assign = body(
    work_table,
    "procedure TChannel.AssignFlowMeterFrom",
    "// =====================================================",
)
assert assign.index("FFlowMeter.Device := NewDevice;") < assign.index(
    "FFlowMeter.SetEtalon(AWorkTable.TableFlow);"
)
assert assign.index("FFlowMeter.SetEtalon(AWorkTable.TableFlow);") < assign.index(
    "FFlowMeter.RebindCalculatedValues;"
)
assert "AWorkTable.DeviceChannels.IndexOf(Self) >= 0" in assign
assert "not FFlowMeter.IsEtalon" in assign
assert "CreateDeviceForChannelCopy(SrcDevice)" in assign
assert "TGUID.NewGuid.ToString" in assign
assert "Sessions" not in assign and "Spillages" not in assign
assert "ValueError.GetDoubleValue" not in assign

load = body(
    main_table,
    "procedure TFrameMainTable.LoadChannelFromClipboard",
    "function TFrameMainTable.GetSelectedChannel",
)
assert load.index("FFrameProceed.RemoveProcessingDevice(OldDevice);") < load.index(
    "FFrameProceed.AddProcessingDevice(NewDevice);"
)
assert "ReplaceProcessingDevice" not in load

save = body(
    work_table,
    "procedure TWorkTable.SaveMeasurementResults",
    "procedure TWorkTable.StartTest",
)
assert "IsDeviceErrorBindingValid(DeviceChannel, BindingReason)" in save
assert "DeviceChannel.FlowMeter.SetEtalon(TableFlow);" in save
assert "DeviceChannel.FlowMeter.RebindCalculatedValues;" in save
assert "DeviceChannel.FlowMeter.SetValues;" in save
assert "Point.Error :=\n        CalculatedError;" in save
assert "Point.Error := 0" not in save

repository = (ROOT / "uRepositories.pas").read_text(encoding="utf-8-sig")
copy_device = body(
    repository,
    "function TDeviceRepository.CreateDeviceForChannelCopy",
    "function TDeviceRepository.GetDevice",
)
assert "CreateNewDevice" in copy_device
assert "AssignWithoutMeasurementHistory(ASource)" in copy_device

assert "APP_VERSION = '1.0.150'" in version
assert "FileVersion=1.0.150.0" in project
