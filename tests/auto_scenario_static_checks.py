from pathlib import Path

root = Path(__file__).resolve().parents[1]
frm = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
work = (root / 'uWorkTable.pas').read_text(encoding='utf-8-sig')
start = frm.index('procedure TFrameMainTable.RunAutoMeasurementScenario')
end = frm.index('procedure TFrameMainTable.MeasurementButtonClickManualMode', start)
scenario = frm[start:end]

checks = {
    'scenario uses the production start entry point': 'WT.StartMeasurementRun;' in scenario,
    'scenario rejects simulation mode': 'if WT.IsSimulationMode then' in scenario,
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
}

failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('FAILED auto scenario static checks: ' + '; '.join(failed))
print('OK: auto scenario is a production-only observer with hardware diagnostics.')
