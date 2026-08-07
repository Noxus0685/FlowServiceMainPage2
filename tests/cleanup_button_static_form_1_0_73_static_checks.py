from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
FORM = (ROOT / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.77'" in VERSION
assert 'ButtonRemoveInvalidAndExcessMeasurements: TButton' in FORM
assert 'Action = ActionRemoveInvalidAndExcessMeasurements' in FORM
assert 'ActionRemoveInvalidAndExcessMeasurements: TAction' in FORM
assert 'OnExecute = ActionRemoveInvalidAndExcessMeasurementsExecute' in FORM
assert 'ButtonRemoveInvalidAndExcessMeasurements := TButton.Create' not in PROCEED
assert 'ActionRemoveInvalidAndExcessMeasurements := TAction.Create' not in PROCEED
assert 'ButtonRemoveInvalidAndExcessMeasurements.Parent := ToolBarDataPoints' not in PROCEED
assert 'ButtonRemoveInvalidAndExcessMeasurements.Action := ActionRemoveInvalidAndExcessMeasurements' in PROCEED
