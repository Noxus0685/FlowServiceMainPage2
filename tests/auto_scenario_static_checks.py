from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
frm = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
start = frm.index('procedure TFrameMainTable.RunAutoMeasurementScenario')
end = frm.index('procedure TFrameMainTable.MeasurementButtonClickManualMode', start)
auto = frm[start:end]

required = {
    'public automatic start route': 'WT.StartMeasurementRun(Ord(mrmAutomatic))' in auto,
    'production point preparation': 'Run.RebuildMeasurementPoints' in auto,
    'real monotonic delta': all(x in auto for x in ['TThread.GetTickCount64', 'DeltaMs := CurrentTick - PreviousTick']),
    'fractional pulse accumulator': all(x in auto for x in ['FractionRemainder', 'ExpectedIncrement - AddedImpulses']),
    'raw pulse inputs only': all(x in auto for x in ['Channel.ImpSec :=', 'Channel.ImpResult :=']),
    'production recalculation route': 'SetValues;' in auto,
    'normal stop route': 'WT.StopMeasurementRun' in auto,
    'input lifecycle protocol': all(x in auto for x in ['AutoTestInputSimulationStarted', 'AutoTestPulseAdjusted', 'AutoTestPointObserved', 'AutoTestInputSimulationStopped']),
    'real stage observations': 'AutoTestStageObserved' in auto and 'PreviousElapsedMs=' in auto,
    'global simulation remains disabled': 'WT.IsSimulationMode' in auto and 'SimulationMode=False EffectiveSimulationActive=False' in auto,
}
forbidden_patterns = {
    'virtual clock': r'Virtual(Time|Now|Clock)|AdvanceTime|TimeScale|AddStabilitySampleManual',
    'internal FSM calls': r'\b(ProcessStage|ProcessSelectPoint|ProcessWaitStable|ProcessMeasure|ProcessSave|SetStage|DoEnterStage)\s*\(',
    'direct work-table state': r'\bWT\.State\s*:=|\bWorkTable\.State\s*:=',
    'forced internal events': r'\b(mcNextPoint|mcForcePoint)\b',
    'derived/result assignments': r'(ValueFlow\.Value|TPointSpillage\.(Error|Status)|\bFCurrentStage\s*:=)',
}
failed = [name for name, ok in required.items() if not ok]
failed += [name for name, pattern in forbidden_patterns.items() if re.search(pattern, auto, re.I)]
if failed:
    raise SystemExit('FAILED real-time auto scenario checks: ' + '; '.join(failed))
print('OK: auto test observes the production FSM and feeds only real-time pulse inputs.')
