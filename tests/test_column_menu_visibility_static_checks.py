from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8")
FMX = (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8")

DEVICES = {
    "MenuItemDevicesColumn0": "CheckColumnDeviceEnable1",
    "MenuItemDevicesColumn1": "StringColumnDeviceChanel1",
    "MenuItemDevicesColumn2": "ColumnDeviceType1",
    "MenuItemDevicesColumn3": "PopupColumnDeviceDN1",
    "MenuItemDevicesColumn4": "StringColumnDeviceName1",
    "MenuItemDevicesColumn5": "StringColumnDeviceSerial1",
    "MenuItemDevicesColumn6": "PopupColumnDeviceSignal1",
    "MenuItemDevicesColumn7": "StringColumnDeviceRawValue1",
    "MenuItemDevicesColumn8": "StringColumnDeviceFlowRate1",
    "MenuItemDevicesColumnMeanFlow": "StringColumnDeviceAvgFlowRate1",
    "MenuItemDevicesColumn9": "StringColumnDeviceQuantity1",
    "MenuItemDevicesColumn10": "StringColumnDeviceError1",
    "MenuItemDevicesColumn11": "StringColumnDeviceStd1",
    "MenuItemDevicesColumn12": "StringColumnDeviceQuantityBefore1",
    "MenuItemDevicesColumn13": "StringColumnDeviceQuantityAfter1",
    "MenuItemDevicesColumn14": "StringColumnDevicePressureDelta1",
    "MenuItemDevicesColumn15": "StringColumnDeviceOptions1",
    "MenuItemDevicesColumn16": "StringColumnDeviceRawSumValue1",
    "MenuItemDevicesColumn17": "StringColumnUUID1",
    "MenuItemDevicesColumn18": "StringColumnDeviceCoef1",
}
ETALONS = {
    "MenuItemEtalonsColumn0": "CheckColumnEtalonEnable1",
    "MenuItemEtalonsColumn1": "StringColumnEtalonChanel1",
    "MenuItemEtalonsColumn2": "StringColumnEtalonType1",
    "MenuItemEtalonsColumn3": "PopupColumnEtalonDN1",
    "MenuItemEtalonsColumn4": "StringColumnEtalonName1",
    "MenuItemEtalonsColumn5": "PopupColumnEtalonSignal1",
    "MenuItemEtalonsColumn6": "StringColumnEtalonRawValue1",
    "MenuItemEtalonsColumn7": "StringColumnEtalonFlowRate1",
    "MenuItemEtalonsColumnMeanFlow": "StringColumnEtalonAvgFlowRate1",
    "MenuItemEtalonsColumn8": "StringColumnEtalonQuantity1",
    "MenuItemEtalonsColumn9": "StringColumnEtalonSerial1",
    "MenuItemEtalonsColumn10": "StringColumnEtalonError1",
    "MenuItemEtalonsColumn11": "StringColumnEtalonStd1",
    "MenuItemEtalonsColumn12": "StringColumnEtalonPressureDelta1",
    "MenuItemEtalonsColumn13": "StringColumnEtalonOptions1",
    "MenuItemEtalonsColumn14": "StringColumnEtalonRawSumValue1",
}


def test_every_menu_item_uses_runtime_column_index():
    for item, column in (DEVICES | ETALONS).items():
        assert f"{item}.Tag := {column}.Index;" in PAS


def test_menu_items_use_grid_specific_handlers():
    for item in DEVICES:
        block = re.search(rf"object {item}: TMenuItem(.*?)\n        end", FMX, re.S)
        assert block and "OnClick = DevicesColumnMenuItemClick" in block.group(1)
    for item in ETALONS:
        block = re.search(rf"object {item}: TMenuItem(.*?)\n        end", FMX, re.S)
        assert block and "OnClick = EtalonsColumnMenuItemClick" in block.group(1)


def test_no_legacy_column_binding_remains():
    for legacy in ("BindColumnMenuItem", "BindDevicesColumnMenu", "BindEtalonsColumnMenu", "SyncGridColumnMenu"):
        assert legacy not in PAS
    assert "OnClick = MenuGridLayOutClick" not in FMX


def test_popup_sync_is_last_operation():
    for popup, sync in (("PopupMenuDevicesGridPopup", "SyncDevicesColumnsMenu"),
                        ("PopupMenuEtalonsGridPopup", "SyncEtalonsColumnsMenu")):
        body = re.search(rf"procedure TFrameMainTable\.{popup}\(.*?\);(.*?)end;", PAS, re.S).group(1)
        assert body.rstrip().endswith(sync + ";")
