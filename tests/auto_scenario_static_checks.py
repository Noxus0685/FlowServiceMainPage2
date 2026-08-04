from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
frm = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
work = (root / 'uWorkTable.pas').read_text(encoding='utf-8-sig')
graphs = (root / 'frmGraphsWorkspace.pas').read_text(encoding='utf-8-sig')
start = frm.index('procedure TFrameMainTable.RunAutoMeasurementScenario')
end = frm.index('procedure TFrameMainTable.MeasurementButtonClickManualMode', start)
auto = frm[start:end]

required = {
    'public automatic start route': 'WT.StartMeasurementRun(Ord(mrmAutomatic))' in auto,
    'production point preparation': 'Run.RebuildMeasurementPoints' in auto,
    'real per-channel delta': 'ChannelDeltaMs := CurrentTick - PulseStates[I].PreviousTick' in auto,
    'fractional pulse accumulator': all(x in auto for x in ['FractionRemainder', 'ExpectedIncrement - AddedImpulses']),
    'production pulse route': 'Channel.ApplyPulseInput(' in auto and 'procedure TChannel.ApplyPulseInput' in work,
    'production aggregate and notification route': 'WT.PublishPulseInputs' in auto and 'FireEvent(ewtRefresh' in work,
    'normal stop route': 'WT.StopMeasurementRun' in auto,
    'separate channel and device identities': all(x in auto for x in ['ChannelUUID=%s DeviceUUID=%s', '.ChannelUUID := AChannels[J].UUID', '.DeviceUUID := AChannels[J].DeviceUUID']),
    'runtime object identity check': all(x in auto for x in ['WT.EtalonChannels.IndexOf', 'WT.DeviceChannels.IndexOf', 'AutoTestRuntimeBindingVerified']),
    'input override lifecycle': all(x in auto for x in ['OriginalOverrideActive', 'AutoTestInputOverrideActive := True', 'SimulationGeneratorSuppressed']),
    'input lifecycle protocol': all(x in auto for x in ['AutoTestInputSimulationStarted', 'AutoTestPulseAdjusted', 'AutoTestInputApplied', 'AutoTestPointObserved', 'AutoTestInputSimulationStopped']),
    'history diagnostics': all(x in auto for x in ['GetStabilitySamples', 'HistorySampleCount=', 'LastSampleMs=']),
    'actual flow comes from production': 'FlowMeter.ValueFlow.GetDoubleValue' in auto,
    'real stage observations': 'AutoTestStageObserved' in auto and 'PreviousElapsedMs=' in auto,
    'stable noise-free profile': 'ChannelFlow := TargetFlow * Min(1.0' in auto,
    'global simulation remains disabled': 'WT.IsSimulationMode' in auto,
    'graph and auto test share channel UUID': 'Item.ChannelUUID := AChannel.UUID' in graphs and '.ChannelUUID := AChannels[J].UUID' in auto,
    'generator skips overridden channels': '(not AChannel.AutoTestInputOverrideActive)' in work and 'AChannel.AutoTestInputOverrideActive or' in work,
    'override restored in finally': 'finally' in auto and 'OriginalOverrideActive' in auto,
    'application version 1.0.63': "APP_VERSION = '1.0.63'" in (root / 'uAppVersion.pas').read_text(encoding='utf-8-sig'),
}
forbidden_patterns = {
    'virtual clock': r'Virtual(Time|Now|Clock)|AdvanceTime|TimeScale|AddStabilitySampleManual',
    'internal FSM calls': r'\b(ProcessStage|ProcessSelectPoint|ProcessWaitStable|ProcessMeasure|ProcessSave|SetStage|DoEnterStage)\s*\(',
    'direct work-table state': r'\bWT\.State\s*:=|\bWorkTable\.State\s*:=',
    'forced internal events': r'\b(mcNextPoint|mcForcePoint)\b',
    'derived/result assignments': r'(ValueFlow\.Value|FlowRate\.Value\s*:=|TPointSpillage\.(Error|Status)|\bFCurrentStage\s*:=)',
    'device UUID used as runtime key': r'PulseStates\[[^]]+\]\.DeviceUUID\s*:=\s*AChannels\[[^]]+\]\.DeviceUUID\s*;\s*PulseStates\[[^]]+\]\.Channel\s*:='
}
failed = [name for name, ok in required.items() if not ok]
failed += [name for name, pattern in forbidden_patterns.items() if re.search(pattern, auto, re.I | re.S)]
if failed:
    raise SystemExit('FAILED real-time auto scenario checks: ' + '; '.join(failed))
print('OK: auto test uses channel-keyed production pulse/history/UI route with generator override.')
