from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')


def test_cleanup_button_and_public_api_present():
    assert "ButtonRemoveInvalidAndExcessMeasurements.Text := 'Удалить лишние измерения'" in PROCEED
    assert 'function FindUnassignedMeasurements: TArray<TPointSpillage>;' in PROCEED
    assert 'function FindExcessMeasurements: TArray<TPointSpillage>;' in PROCEED
    assert 'procedure RemoveInvalidAndExcessMeasurements;' in PROCEED


def test_cleanup_uses_device_point_repeats_and_existing_matching():
    excess = PROCEED[PROCEED.index('function TFrameProceed.FindExcessMeasurements'):PROCEED.index('procedure TFrameProceed.RemoveInvalidAndExcessMeasurements')]
    assert 'AllowedCount := Max(Point.Repeats, 1);' in excess
    assert 'Device.FindMatchedDevicePointForSpillage(Spillage) = Point' in excess
    assert 'TMeasurementRun.Points' not in excess


def test_cleanup_confirmation_report_logging_and_refresh():
    cleanup = PROCEED[PROCEED.index('procedure TFrameProceed.RemoveInvalidAndExcessMeasurements'):PROCEED.index('procedure TFrameProceed.ActionRemoveInvalidAndExcessMeasurementsExecute')]
    assert 'Всего измерений: %d' in cleanup
    assert 'Не привязано к точкам: %d' in cleanup
    assert 'Будет удалено всего: %d' in cleanup
    assert 'Будут удалены:' in cleanup
    assert 'ProcessingMeasurementsCleanup' in cleanup
    assert 'PopulateTreeViewDevices;' in cleanup
    assert 'ShowAllDevicesResults;' in cleanup
    assert 'SavePendingProcessingChanges(Self);' in cleanup


def test_version_bumped_to_1_0_68():
    assert "APP_VERSION = '1.0.68'" in VERSION
