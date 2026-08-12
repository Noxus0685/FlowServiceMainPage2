from pathlib import Path
ROOT = Path(__file__).parents[1]
MAIN = (ROOT/'frmMainTable.pas').read_text(encoding='utf-8-sig')
WORK = (ROOT/'uWorkTable.pas').read_text(encoding='utf-8-sig')
PROCEED = (ROOT/'frmProceed.pas').read_text(encoding='utf-8-sig')

def body(text, start, end): return text.split(start,1)[1].split(end,1)[0]

def test_atomic_copy_replacement_order_and_refresh():
    b=body(MAIN,'procedure TFrameMainTable.ReplaceChannelDeviceFromCopy','procedure TFrameMainTable.LoadChannelFromClipboard')
    ordered=['OldDevice :=','ADest.AssignFlowMeterFrom','ValidateChannelDeviceUUIDs','IsDeviceUsedByAnotherChannel','ReplaceProcessingDevice','MarkChannelDeviceModified','PersistDeviceAsync','FFrameMRResults.ReloadAndUpdate']
    positions=[b.index(x) for x in ordered]
    assert positions == sorted(positions)
    assert 'SameText(Trim(ADest.DeviceUUID), Trim(NewDeviceUUID))' in b
    assert 'SameText(Trim(ADest.FlowMeter.DeviceUUID), Trim(NewDeviceUUID))' in b

def test_copy_uuid_and_history_contract():
    b=body(WORK,'procedure TChannel.AssignFlowMeterFrom','// =====================================================')
    create=b.index('CreateDeviceForChannelCopy')
    assert b.index('FFlowMeter.DeviceUUID := NewDevice.UUID',create)>create
    assert b.index('FFlowMeter.DeviceTypeUUID := NewDevice.DeviceTypeUUID',create)>create
    assert 'Sessions.Assign' not in b and 'Spillages.Assign' not in b

def test_destinations_and_refresh_are_explicit():
    load=body(MAIN,'procedure TFrameMainTable.LoadChannelFromClipboard','function TFrameMainTable.GetSelectedChannel')
    assert 'AddProcessingDevice' not in load
    assert 'ReplaceChannelDeviceFromCopy(AClipboard.Snapshot, AChannel, AAddToProcessing)' in load
    assert 'LoadChannelFromClipboard(Ch, FDeviceClipboard, True)' in MAIN
    assert 'LoadChannelFromClipboard(Ch, FEtalonClipboard, False)' in MAIN
    assert 'RefreshResultsTab' in body(PROCEED,'procedure TFrameProceed.ReplaceProcessingDevice','procedure TFrameProceed.RemoveProcessingDevice')

def test_version():
    assert "APP_VERSION = '1.0.146'" in (ROOT/'uAppVersion.pas').read_text()
    project=(ROOT/'ProjectFornTest.dproj').read_text()
    assert project.count('FileVersion=1.0.146.0')==2
    assert project.count('ProductVersion=1.0.146.0')==2
