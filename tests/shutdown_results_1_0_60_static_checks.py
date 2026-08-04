from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

def text(name):
    return (ROOT / name).read_text(encoding='utf-8-sig')

def body(source, signature, next_signature):
    return source[source.index(signature):source.index(next_signature, source.index(signature) + 1)]

def test_proceed_has_no_concrete_measurement_run_dependency_or_cast():
    source = text('frmProceed.pas')
    implementation_uses = source[source.index('implementation'):source.index('{$R *.fmx}')]
    method = body(source, 'function TFrameProceed.CanManageResultSessions',
                  'function TFrameProceed.RequestClearActiveSession')
    assert 'uMeasurementRun' not in implementation_uses
    assert 'TMeasurementRun(' not in method
    assert 'FActiveWorkTable.MeasurementRunStage in [msNone, msDone]' in method

def test_protocol_shutdown_guards_and_message_ownership():
    source = text('uProtocols.pas')
    add = body(source, 'procedure TProtocolManager.AddMessage',
               'procedure TProtocolManager.NotifyListeners')
    destroy = body(source, 'destructor TProtocolManager.Destroy',
                   'procedure TProtocolManager.StartWorker')
    assert 'FShuttingDown: Boolean' in source
    assert destroy.index('FShuttingDown := True') < destroy.index('StopWorker') < destroy.index('Clear')
    assert add.count('FShuttingDown or (FQueue = nil)') >= 2
    assert 'try' in add and 'finally' in add and 'Msg.Free' in add
    assert 'Msg := nil' in add
    assert 'if not FShuttingDown then\n      Notify(Integer(pmeMessageQueued))' in add
    assert 'and not FShuttingDown and (FQueue <> nil)' in add

def test_protocol_finalization_publishes_nil_before_free():
    source = text('uProtocols.pas')
    finalize = body(source, 'procedure FinalizeProtocolManager', '{ TProtocolMessage }')
    assert finalize.index('Manager := ProtocolManager') < finalize.index('ProtocolManager := nil') < finalize.index('Manager.Free')

def test_measurement_detach_is_idempotent_and_protocol_optional():
    source = text('frmMeasurementRun.pas')
    detach = body(source, 'procedure TFrameMeasurementRun.DetachMeasurementRunEvents',
                  'procedure TFrameMeasurementRun.EnsureMeasurementRunSubscription')
    assert detach.index('OldRun := FSubscribedMeasurementRun') < detach.index('FSubscribedMeasurementRun := nil') < detach.index('OldRun.Unsubscribe(Self)')
    assert 'if Assigned(ProtocolManager) then' in detach

def test_results_columns_are_rebuilt_only_from_enabled_current_points():
    source = text('frmMRResults.pas')
    build = body(source, 'procedure TFrameMRResults.BuildColumns',
                 'function TFrameMRResults.HasCurrentMeasurementPoints')
    has = body(source, 'function TFrameMRResults.HasCurrentMeasurementPoints',
               'function TFrameMRResults.PointBelongsToDisplayGroup')
    assert build.index('FPointColumns.Clear') < build.index('while GridMRResults.ColumnCount > 2')
    assert build.index('FDisplayPoints.Clear') < build.index('while GridMRResults.ColumnCount > 2')
    assert 'if not HasCurrentMeasurementPoints then Exit' in build
    assert 'Device.Points' not in build
    assert 'MeasurementRun.Points[I].Enabled' in build
    assert 'MeasurementRun.Points = nil' in has and '.Enabled' in has

def test_version_is_1_0_60():
    assert "APP_VERSION = '1.0.60'" in text('uAppVersion.pas')
