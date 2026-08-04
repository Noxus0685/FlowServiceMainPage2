from pathlib import Path
import math
import re

ROOT = Path(__file__).resolve().parents[1]

def source(name):
    return (ROOT / name).read_text(encoding='utf-8-sig')

def method(text, start, end):
    pos = text.index(start)
    return text[pos:text.index(end, pos + len(start))]

def test_proceed_uses_typed_run_contract_without_measurement_run_dependency():
    s = source('frmProceed.pas')
    uses = s[s.index('implementation'):s.index('{$R *.fmx}')]
    body = method(s, 'function TFrameProceed.CanManageResultSessions',
                  'function TFrameProceed.RequestClearActiveSession')
    assert 'uMeasurementRun' not in uses
    assert 'TMeasurementRun(' not in body
    assert 'FActiveWorkTable.MeasurementRun.Stage in [msNone, msDone]' in body

def test_protocol_shutdown_and_idempotent_detach_guards():
    p = source('uProtocols.pas')
    add = method(p, 'procedure TProtocolManager.AddMessage',
                 'procedure TProtocolManager.NotifyListeners')
    worker = method(p, 'procedure TProtocolManager.WorkerProc',
                    'procedure TProtocolManager.FreeMessage')
    assert add.count('FShuttingDown or (FQueue = nil)') >= 2
    assert 'try' in add and 'finally' in add and 'Msg.Free' in add
    assert 'Msg := nil' in add and 'not FShuttingDown and (FQueue <> nil)' in add
    assert 'if FShuttingDown or (FQueue = nil)' in worker
    f = source('frmMeasurementRun.pas')
    detach = method(f, 'procedure TFrameMeasurementRun.DetachMeasurementRunEvents',
                    'procedure TFrameMeasurementRun.EnsureMeasurementRunSubscription')
    assert detach.index('OldRun := FSubscribedMeasurementRun') < detach.index('FSubscribedMeasurementRun := nil') < detach.index('OldRun.Unsubscribe(Self)')
    assert 'if Assigned(ProtocolManager) then' in detach

def test_results_empty_current_schema_clears_every_dynamic_column():
    s = source('frmMRResults.pas')
    build = method(s, 'procedure TFrameMRResults.BuildColumns',
                   'function TFrameMRResults.HasCurrentMeasurementPoints')
    assert build.index('FPointColumns.Clear') < build.index('while GridMRResults.ColumnCount > 2')
    assert build.index('FDisplayPoints.Clear') < build.index('while GridMRResults.ColumnCount > 2')
    assert 'if not HasCurrentMeasurementPoints then Exit' in build
    assert 'Device.Points' not in build
    assert 'ReloadAndUpdate' in s

def test_devices_sheet_uses_eight_base_columns_plus_dynamic_numeric_point_columns():
    x = source('uResultsXlsxExporter.pas')
    assert 'SHeaderDeviceError' not in x
    assert 'SHeaderPointErrors' not in x
    assert 'PointErrorsText' not in x
    assert 'ResultErrorSet' not in x
    assert 'TResultsExportPointColumn = class' in x
    assert 'PointColumns: TObjectList<TResultsExportPointColumn>' in x
    assert 'PointCells: TList<TResultsExportPointCell>' in x
    assert 'S.WriteNumber(I+2, 9+C, PercentPointsToExcelFraction(Cell.Error), xsError)' in x
    assert '8 + AData.PointColumns.Count' in x
    assert 'PointColumns=%d' in x and 'DevicesSheetColumns=%d' in x

def test_percentage_point_examples_and_missing_values_contract():
    for value, expected in ((0.164, 0.00164), (-0.527, -0.00527), (0.013, 0.00013)):
        assert math.isclose(value / 100, expected, abs_tol=1e-14)
    x = source('uResultsXlsxExporter.pas')
    assert 'if Cell.ErrorSet' in x
    assert 'else S.WriteNumber' not in x

def test_point_identity_uses_production_participants_and_matching_route():
    s = source('frmMRResults.pas')
    assert 'Dev.FindMatchedDevicePointForSpillage(Spill)' in s
    assert 'ScenarioPoint.Participants[J].DeviceUUID' in s
    assert 'ScenarioPoint.Participants[J].SourcePointUUID' in s
    assert "PointColumn.Key := ScenarioPoint.UUID" in s
    assert "PointColumn.Key := ScenarioPoint.Participants[0].DeviceUUID + '|' +" in s
    assert 'CreateGUID' not in method(s, 'function TFrameMRResults.BuildExportData',
                                      '{ Exports the selected device')

def test_mode_and_session_status_snapshots_are_text_not_numbers():
    s = source('frmMRResults.pas')
    for text in ('Ручной', 'Полуавтоматический', 'Автоматический',
                 'Открыта', 'Выполняется', 'Завершена', 'Не определён'):
        assert text in s
    snapshot = method(s, 'function TFrameMRResults.BuildExportData',
                      '{ Exports the selected device')
    assert 'ES.Mode:=MeasurementModeToDisplayText' in snapshot
    assert 'ES.Status:=SessionStatusToDisplayText' in snapshot
    assert 'IntToStr(Ord(FActiveWorkTable.MeasurementMode))' not in snapshot
    assert 'IntToStr(Session.Status)' not in snapshot
    x = source('uResultsXlsxExporter.pas')
    assert 'EMeasurementRunMode' not in x and 'TSessionSpillage' not in x

def test_release_version():
    assert "APP_VERSION = '1.0.63'" in source('uAppVersion.pas')
    assert 'ApplicationVersion' in source('frmProtocol.pas')
