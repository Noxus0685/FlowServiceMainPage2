from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESULTS = (ROOT / 'frmMRResults.pas').read_text(encoding='utf-8-sig')
RESULTS_FMX = (ROOT / 'frmMRResults.fmx').read_text(encoding='utf-8-sig')
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
PROCEED_FMX = (ROOT / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
MAIN = (ROOT / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
EXPORTER = (ROOT / 'uResultsXlsxExporter.pas').read_text(encoding='utf-8-sig')
OPENXML = (ROOT / 'uOpenXmlXlsx.pas').read_text(encoding='utf-8-sig')

def test_results_tab_activation_uses_one_reload_route():
    assert 'TabControl1.ActiveTab = TabItemMRResults' in MAIN
    assert 'FFrameMRResults.ReloadAndUpdate' in MAIN
    assert 'procedure TFrameMRResults.ReloadAndUpdate' in RESULTS
    assert 'if FRefreshing then Exit' in RESULTS
    body = RESULTS.split('procedure TFrameMRResults.ReloadAndUpdate', 1)[1].split('procedure TFrameMRResults.GridMRResultsSelChanged', 1)[0]
    for call in ('RefreshResultsTab', 'BuildRows', 'BuildColumns', 'RefreshRows', 'GridMRResults.Repaint'):
        assert call in body

def test_processing_frame_is_connected_after_both_frames_exist():
    host = (ROOT / 'fuTable_Main.pas').read_text(encoding='utf-8-sig')
    assert host.index('FFrameProceed := TFrameProceed.Create') < host.index('ConnectResultsProcessing(FFrameProceed)')
    assert 'FFrameMRResults.ConnectProcessingFrame(AProceed)' in MAIN

def test_session_icons_reuse_processing_styles():
    assert 'object ButtonClearSession: TButton' not in RESULTS_FMX
    assert 'object ButtonCreateSession: TButton' not in RESULTS_FMX
    assert 'object ButtonClearSession: TSpeedButton' in RESULTS_FMX
    assert "StyleLookup = 'pagecurltoolbutton'" in RESULTS_FMX and "StyleLookup = 'pagecurltoolbutton'" in PROCEED_FMX
    assert "StyleLookup = 'additembutton'" in RESULTS_FMX and "StyleLookup = 'additembutton'" in PROCEED_FMX
    assert RESULTS_FMX.count('ShowHint = True') >= 2

def test_selected_and_all_device_routes_are_explicit():
    assert "Scope := 'SelectedDevice'" in RESULTS
    assert "Scope := 'AllDevices'" in RESULTS
    assert 'RequestClearActiveSession(Device)' in RESULTS
    assert 'RequestCreateSession(Device)' in RESULTS
    assert 'RequestClearActiveSessions' in RESULTS
    assert 'RequestCreateSessions' in RESULTS
    assert 'RequestClearActiveSession(nil)' not in RESULTS
    assert 'RequestCreateSession(nil)' not in RESULTS

def test_production_guards_and_protocol_outcomes_exist():
    assert 'CanManageResultSessions' in PROCEED
    assert 'Stage in [msNone, msDone]' in PROCEED
    for event in ('ResultsSessionClearRequested', 'ResultsSessionClearCompleted', 'ResultsSessionClearFailed',
                  'ResultsSessionCreateRequested', 'ResultsSessionCreateCompleted', 'ResultsSessionCreateFailed'):
        assert f"'{event}'" in PROCEED
    for field in ('Scope=', 'DeviceUUID=', 'Serial=', 'OldSessionID=', 'NewSessionID=', 'Spillages=', 'Error='):
        assert field in PROCEED

def test_clear_uses_active_session_points_route_not_session_deletion():
    body = PROCEED.split('function TFrameProceed.RequestClearActiveSession', 1)[1].split('function TFrameProceed.RequestCreateSession', 1)[0]
    assert 'GetActiveVisibleSession(ADevice)' in body
    assert 'ActionSessionPointsClearExecute(ActionSessionPointsClear)' in body
    assert 'ActionSessionDeleteExecute' not in body

def test_devices_sheet_has_error_columns_and_percent_scale():
    for field in ('ResultError: Double', 'ResultErrorSet: Boolean', 'PointErrorsText: string'):
        assert field in EXPORTER
    assert 'SHeaderDeviceError' in EXPORTER and 'SHeaderPointErrors' in EXPORTER
    assert 'PercentPointsToExcelFraction(D.ResultError)' in EXPORTER
    assert 'D.PointErrorsText,xsWrapped' in EXPORTER
    assert 'wrapText="1"' in OPENXML

def test_point_error_snapshot_uses_active_session_matcher_and_format():
    assert 'for Spill in Session.Spillages' in RESULTS
    assert 'Dev.FindMatchedDevicePointForSpillage(Spill)' in RESULTS
    assert "FormatFloat('0.###', Spill.Error)" in RESULTS
    assert "FormatFloat('0.###', DevicePoint.Error)" in RESULTS
    assert "PointText := PointText + ' / ±'" in RESULTS
