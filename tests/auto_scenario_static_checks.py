from pathlib import Path

root = Path(__file__).resolve().parents[1]
frm = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
work = (root / 'uWorkTable.pas').read_text(encoding='utf-8-sig')
table_form = (root / 'fuTable_Main.pas').read_text(encoding='utf-8-sig')
legacy_form = (root / 'fuMain.pas').read_text(encoding='utf-8-sig')
start = frm.index('procedure TFrameMainTable.RunAutoMeasurementScenario')
process = frm.index('procedure TFrameMainTable.ProcessAutoMeasurementObserver', start)
finish = frm.index('procedure TFrameMainTable.FinishAutoMeasurementObserver', process)
end = frm.index('procedure TFrameMainTable.MeasurementButtonClickManualMode', finish)
launcher = frm[start:process]
observer = frm[process:finish]
scenario = frm[start:end]

checks = {
    'launcher uses production UI entry point': 'StartMeasurement;' in launcher,
    'launcher returns without synchronous waiting': not any(x in launcher for x in [
        'TThread.Sleep', 'WaitFor', 'WaitForSingleObject', 'CheckSynchronize',
        'Application.ProcessMessages', 'while ', 'repeat\n', 'for Step'
    ]),
    'observer has explicit states': all(x in frm for x in [
        'mtsIdle', 'mtsStarting', 'mtsWaitingMonitor', 'mtsWaitingSamples',
        'mtsWaitingMeasurement', 'mtsCompleted', 'mtsFailed', 'mtsCancelled'
    ]),
    'timer performs one observer iteration': 'ProcessAutoMeasurementObserver;' in frm[
        frm.index('procedure TFrameMainTable.TimerMainTimer'):
        frm.index('procedure ', frm.index('procedure TFrameMainTable.TimerMainTimer') + 10)
    ],
    'timeouts use monotonic tick checks': 'TThread.GetTickCount64' in scenario and all(x in observer for x in [
        'START_TIMEOUT_MS', 'MONITOR_TIMEOUT_MS', 'SAMPLE_TIMEOUT_MS',
        'MEASUREMENT_TIMEOUT_MS'
    ]),
    'observer does not drive production FSM': not any(x in observer for x in [
        'Run.Execute(', 'Run.Process', 'WT.State :=', 'UpdateSimulation',
        '.SetValue(', 'AddStabilitySampleManual', 'EnableVirtualClock'
    ]),
    'stop is asynchronous production request': 'FActiveWorkTable.StopMeasurementRun;' in frm and 'WaitFor' not in launcher,
    'run diagnostics carry correlation id': all(x in scenario for x in [
        'TestRunID=', 'AutoTestStarted', 'StartMeasurementRequested',
        'StartMeasurementReturned', 'MeasurementWorkerStarted',
        'StartMonitorActionHandled', 'FirstNewSampleReceived',
        'MeasurementStageChanged', 'AutoTestCompleted', 'AutoTestFailed'
    ]),
    'main table timer gates simulation but keeps UI updates': all(x in table_form for x in [
        'SyncWorkTableObservers;', 'UpdateInstrumentNameEdit;',
        'if FWorkTableManager.IsSimulationMode then\n    FWorkTableManager.UpdateSimulation;'
    ]),
    'UpdateSimulation has internal guard':
        'if not IsSimulationMode then\n    Exit;\n\n  for WorkTable in FWorkTables do' in work,
    'legacy simulator disabled in real mode':
        '(FWorkTableManager = nil) or (not FWorkTableManager.IsSimulationMode)' in legacy_form,
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('FAILED auto scenario checks: ' + '; '.join(failed))
print('OK: auto scenario is a non-blocking production observer state machine.')
