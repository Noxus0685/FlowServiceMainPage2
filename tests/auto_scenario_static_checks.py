from pathlib import Path

root = Path(__file__).resolve().parents[1]
files = {p.name: p.read_text(encoding='utf-8-sig') for p in [
    root/'frmMainTable.pas', root/'uWorkTable.pas', root/'uMeterValue.pas',
    root/'uMeasurementRun.pas', root/'fuTable_Main.pas']}
measurement_frame = (root/'frmMeasurementRun.pas').read_text(encoding='utf-8-sig')
measurement_layout = (root/'frmMeasurementRun.fmx').read_text(encoding='utf-8-sig')
all_source = '\n'.join(files.values())
forbidden = [
    'VirtualTime', 'VirtualTimeStart', 'VirtualNow', 'ScenarioTime',
    'EmulatedTime', 'AdvanceTime', 'AdvanceVirtualClock', 'EnableVirtualClock',
    'DisableVirtualClock', 'RunUntil', 'Virtual command boundary',
    'Сценарный тест: реальный запуск мониторинга заблокирован',
    'состояние swtMONITOR установлено имитатором',
]
checks = {
    'virtual-time executor removed': not any(x in all_source for x in forbidden),
    'scenario uses monotonic real tick': all(x in files['uWorkTable.pas'] for x in [
        'TThread.GetTickCount64', 'TickSimulationMeasurementTest',
        'CurrentTick - FSimulationTestStartedTick']),
    'normal timer performs one simulation and observer tick': all(
        files['fuTable_Main.pas'].count(x) == 1 for x in [
            'FWorkTableManager.UpdateSimulation;',
            'FWorkTableManager.TickSimulationMeasurementTest;']),
    'test starts only through production API': all(x in files['uWorkTable.pas'] for x in [
        'MeasurementMode := mrmAutomatic', 'StartMeasurementRun;']),
    'test does not drive FSM': not any(x in files['uWorkTable.pas'] for x in [
        '.ProcessStage', '.SetStage', '.CreateSession']),
    'simulation no longer blocks production operations': not any(
        x in files['uWorkTable.pas'] for x in [
            'if IsSimulationMode then\n  begin\n    State := swtMONITOR',
            'if IsSimulationMode then\n  begin\n    State := swtEXECUTE']),
    'stage log reports prior-stage elapsed time': all(x in files['uMeasurementRun.pas'] for x in [
        'PreviousStageStartedTick := FWaitStartedTick', 'StageElapsedMs=',
        'CurrentTick - PreviousStageStartedTick']),
    'testing tab is restored and uses observer controls': all(x in files['frmMainTable.pas'] for x in [
        "FAutoTestTab.Text := 'Тестирование'", 'WorkTableManager.StartSimulationMeasurementTest',
        'WorkTableManager.StopSimulationMeasurementTest(True)',
        'WorkTableManager.SimulationTestVerdict']),
    'obsolete lower test panel is removed': all(x not in measurement_frame + measurement_layout for x in [
        'LayoutAutoTests', 'ButtonRunAllAutoTestScenarios', 'TAutoMeasurementTestRunner']),
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('FAILED real-time scenario checks: ' + '; '.join(failed))
print('OK: real-time observer, production FSM, simulation timer, and stage logging checks passed.')
