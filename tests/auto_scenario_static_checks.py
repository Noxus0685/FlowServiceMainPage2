from pathlib import Path

root = Path(__file__).resolve().parents[1]
frm = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
work = (root / 'uWorkTable.pas').read_text(encoding='utf-8-sig')
table_form = (root / 'fuTable_Main.pas').read_text(encoding='utf-8-sig')
legacy_form = (root / 'fuMain.pas').read_text(encoding='utf-8-sig')
start = frm.index('procedure TFrameMainTable.RunAutoMeasurementScenario')
end = frm.index('procedure TFrameMainTable.MeasurementButtonClickManualMode', start)
scenario = frm[start:end]
editing_start = frm.index('procedure TFrameMainTable.GridDevicesEditingDone')
editing_end = frm.index('function TFrameMainTable.GetDisplayFlowText', editing_start)
editing_done = frm[editing_start:editing_end]
flow_props_start = frm.index('procedure TFrameMainTable.UpdateFlowMeterPropertiesFrame')
flow_props_end = frm.index('procedure ', flow_props_start + len('procedure '))
flow_props = frm[flow_props_start:flow_props_end]

checks = {
    'scenario uses the production start entry point': 'WT.StartMeasurementRun;' in scenario,
    'scenario rejects simulation mode': all(x in scenario for x in [
        'WorkTableManager.IsSimulationMode', 'WT.IsSimulationMode then'
    ]),
    'scenario does not generate or inject meter data': not any(x in scenario for x in [
        '.SetValue(', '.Reset(', 'AddStabilitySampleManual', 'ActualQ :=',
        'EnableVirtualClock', 'AdvanceVirtualClock', 'IsSimulationMode := True'
    ]),
    'scenario observes production timestamps': all(x in scenario for x in [
        'GetStabilitySamples', 'LastSampleTimeMs > InitialSampleTimeMs',
        'FAIL — новые данные от оборудования не поступили'
    ]),
    'scenario observes production FSM without driving transitions':
        'Run.Execute(' not in scenario and 'Run.Process' not in scenario,
    'scenario diagnoses real acquisition and stabilization': all(x in scenario for x in [
        'FAIL — стабилизация по реальным данным не достигнута',
        'FAIL — оборудование не подтвердило запуск',
        'FAIL — реальные результаты не получены',
        'FAIL — результаты не сохранены'
    ]),
    'report contains required hardware fields': all(x in scenario for x in [
        'ModuleAddress=', 'ModuleChannel=', 'ReadTimestamp=', 'Frequency=',
        'ImpSec=', 'FlowValue=', 'Temperature=', 'Pressure=',
        'MeasurementRunStage=', 'WorkTableState=', 'EngineState='
    ]),
    'for-in channel control belongs to snapshot local scope':
        'procedure ReadProductionSnapshot;\n  var\n    Channel: TChannel;' in scenario,
    'grid editor flow avoids unsupported nested thread queues':
        'TThread.ForceQueue(nil,' not in editing_done and 'TThread.Queue(nil,' not in editing_done,
    'main table timer gates simulation but keeps UI updates': all(x in table_form for x in [
        'SyncWorkTableObservers;', 'UpdateInstrumentNameEdit;',
        'if FWorkTableManager.IsSimulationMode then\n    FWorkTableManager.UpdateSimulation;'
    ]),
    'UpdateSimulation has an internal no-mutation guard':
        'if not IsSimulationMode then\n    Exit;\n\n  for WorkTable in FWorkTables do' in work,
    'legacy simulation timer is disabled in real mode':
        '(FWorkTableManager = nil) or (not FWorkTableManager.IsSimulationMode)' in legacy_form,
    'flow-meter property selection avoids a malformed local var section':
        'FFlowMeterPropertiesChannel := nil;' in flow_props and '\nvar\n' not in flow_props,
    'observer uses the available global manager':
        'FWorkTableManager.IsSimulationMode' not in scenario,
}

failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('FAILED auto scenario static checks: ' + '; '.join(failed))
print('OK: auto scenario is a production-only observer with hardware diagnostics.')
