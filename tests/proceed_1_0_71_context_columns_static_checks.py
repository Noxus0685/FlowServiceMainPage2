from pathlib import Path

root = Path(__file__).resolve().parents[1]
pas = (root / 'frmProceed.pas').read_text(encoding='utf-8-sig')
version = (root / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.71'" in version
assert 'AbsolutePosition' not in pas
for ui in root.glob('frm*.pas'):
    assert 'AbsolutePosition' not in ui.read_text(encoding='utf-8-sig'), ui.name

for method in ('ClearGridContext', 'BuildWorkTableColumns', 'BuildDeviceColumns',
               'BuildSessionColumns', 'BuildColumnsByContext', 'ReloadGridValues'):
    assert f'TFrameProceed.{method}' in pas, f'missing {method}'

builder = pas.split('procedure TFrameProceed.BuildColumnsByContext', 1)[1][:1800]
assert 'pscWorkTable: BuildWorkTableColumns(AContext.WorkTable)' in builder
assert 'pscDevice: BuildDeviceColumns(AContext.Device)' in builder
assert 'pscSession: BuildSessionColumns(AContext.Session, AContext.Device)' in builder
assert "'WorkPoint.' + Point.UUID" in pas
assert "'DevicePoint.' + Point.UUID" in pas
assert "'SessionPoint.' + Point.UUID" in pas
assert 'ProceedGridContextColumnsBuilt' in builder

clear = pas.split('procedure TFrameProceed.ClearGridContext', 1)[1][:900]
for cache in ('FCurrentResultRows', 'FCurrentSpillages',
              'FCurrentPointColumnKeys', 'FCurrentPointSourceUUIDs',
              'FCurrentPointHeaders'):
    assert f'SetLength({cache}, 0)' in clear

apply_context = pas.split('procedure TFrameProceed.ApplySelectionContext', 1)[1][:4500]
sequence = [apply_context.index(token) for token in
            ('ClearGridContext;', 'BuildColumnsByContext(AContext);',
             'ReloadGridValues(AContext);', 'UpdateCalibrCoefsFrame;')]
assert sequence == sorted(sequence)

column_key = pas.split('function TFrameProceed.ProceedGridColumnKey', 1)[1][:1200]
assert 'FCurrentPointColumnKeys[P]' in column_key
assert 'FCurrentResultRows[0].PointKeys' not in column_key

session_builder = pas.split('procedure TFrameProceed.BuildSessionColumns', 1)[1][:1800]
assert 'Spillage.SessionID <> ASession.ID' in session_builder
assert 'FindMatchedDevicePointForSpillage' in session_builder
device_builder = pas.split('procedure TFrameProceed.BuildDeviceColumns', 1)[1][:1000]
assert 'ADevice.Points' in device_builder and 'MeasurementRun' not in device_builder

assert pas.count('ProceedGridContextColumnsBuilt') == 2  # event and title
print('Proceed 1.0.71 context-column checks passed')
