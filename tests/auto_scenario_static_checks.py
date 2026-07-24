from pathlib import Path

root = Path(__file__).resolve().parents[1]
frm = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
work = (root / 'uWorkTable.pas').read_text(encoding='utf-8-sig')
meter = (root / 'uMeterValue.pas').read_text(encoding='utf-8-sig')
run = (root / 'uMeasurementRun.pas').read_text(encoding='utf-8-sig')

checks = {
    'virtual clock API is available': all(x in meter for x in [
        'EnableVirtualClock', 'AdvanceVirtualClock', 'DisableVirtualClock',
        'if FVirtualClockEnabled then', 'Exit(FVirtualClockMs)'
    ]),
    'measurement run uses virtual-capable monotonic time': 'TThread.GetTickCount64' not in run and 'TMeterValue.GetMonotonicTimeMs' in run,
    'scenario writes generated flow to production parameter': 'WT.FlowRate.SetValue(ActualQ)' in frm and 'WT.FlowRate.Value' in frm,
    'scenario verifies parameter and last sample delivery': all(x in frm for x in [
        'AppliedQ := WT.FlowRate.Value.Value', 'ReadLastSample(WT.FlowRate.Value',
        'FAIL — тестовое значение не передано в рабочий параметр'
    ]),
    'scenario waits for selected point before injection': 'DeliveryCheck=Skipped; Reason=PointNotSelected' in frm and 'FAIL — штатная FSM не выбрала точку' in frm,
    'scenario starts virtual time after existing samples': 'MaxExistingSampleTimeMs' in frm and 'VirtualTimeStartMs := Max(TMeterValue.GetMonotonicTimeMs, MaxExistingSampleTimeMs) + 1' in frm,
    'scenario has early no-progress detection': 'FAIL — отсутствует прогресс FSM' in frm and 'NoProgressSteps >= 20' in frm,
    'scenario restores simulation mode and virtual clock': 'TMeterValue.DisableVirtualClock' in frm and 'WT.IsSimulationMode := OldSimulation' in frm,
    'virtual executor blocks real commands with responses': all(x in work for x in [
        'property IsSimulationMode: Boolean', 'State := swtMONITOR', 'State := swtEXECUTE',
        'State := swtCOMPLETE', 'рабочее сохранение результатов заблокировано'
    ]),
}

failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('FAILED auto scenario static checks: ' + '; '.join(failed))
print('OK: auto scenario delivery, virtual-time, executor, progress, and restore checks passed.')
