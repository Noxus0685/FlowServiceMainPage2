from pathlib import Path


root = Path(__file__).resolve().parents[1]
source = (root / "frmWorkTableProperties.pas").read_text(encoding="utf-8-sig")
version = (root / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


start = source.index(
    "procedure TFrameWorkTableProperties.ButtonPumpDeleteClick(Sender: TObject);"
)
end = source.index(
    "procedure TFrameWorkTableProperties.ButtonScaleAddClick(Sender: TObject);",
    start,
)
body = source[start:end]

require("Pump := SelectedCatalogPump;" in body,
        "Workspace removal must preserve the selected catalog pump")
require("FWorkTable.RemovePump(Pump);" in body,
        "Workspace removal must detach the selected pump")
require("NotifyRefreshIfChanged(True);" in body,
        "Workspace removal must save and notify listeners")
require("RefreshInstrumentEdits;" not in body,
        "Workspace removal must not explicitly reset the catalog selection")
require("TPump.Pumps.Remove" not in body,
        "Workspace removal must not remove the pump from the global catalog")
require("ComboPumpCatalog.Items.Objects[I] = Pump" in body,
        "Catalog selection must be restored by TPump object identity")
require("FLoading := True;" in body and "FLoading := False;" in body,
        "Catalog restoration must suppress selection-change handlers")
for field in ("Name", "Caption", "Min", "Max"):
    require(f"Pump.{field}" in body,
            f"Workspace removal must retain the pump's {field} field")
require("FWorkTable.ActivePump := Pump" not in body,
        "Workspace removal must not reactivate the removed pump")
require("FWorkTable.AddPump" not in body,
        "Workspace removal must not add the pump back to the table")
require("APP_VERSION = '1.0.217';" in version,
        "Application version must be 1.0.217")

print("OK: workspace pump removal preserves the global catalog selection.")
