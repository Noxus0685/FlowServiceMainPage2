from pathlib import Path

work_table = Path('uWorkTable.pas').read_text(encoding='utf-8')
meter_value = Path('uMeterValue.pas').read_text(encoding='utf-8')
measurement_run = Path('uMeasurementRun.pas').read_text(encoding='utf-8')
app_version = Path('uAppVersion.pas').read_text(encoding='utf-8-sig')
protocol_form = Path('frmProtocol.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.2'" in app_version
assert "'ApplicationVersion'" in protocol_form
assert 'SimulationMode=%s; EffectiveSimulationActive=%s' in protocol_form
assert 'Lines.Add(Format(\'ApplicationVersion' in protocol_form

noise_pos = work_table.index("'SimulationNoise'")
cycle_pos = work_table.index('procedure RunChannelSimulationCycle')
apply_call_pos = work_table.index('ApplySimulatedTableFlowValue(AWorkTable, GeneratedTableFlow', cycle_pos)
assert noise_pos < apply_call_pos
assert 'GeneratedTableFlow := CalculateActualEtalonFlow(AWorkTable, SourceChannelCount)' in work_table
assert 'property SimulationActive: Boolean read GetSimulationActive;' in work_table
assert 'if not AWorkTable.SimulationActive then' in work_table
assert 'SimulationStateChanged' in work_table
assert 'SimulationStateMismatch' in work_table
assert 'EffectiveSimulationActive=%s' in work_table
assert "Reject('SimulationModeFalse')" not in work_table
assert 'TargetValue := AWorkTable.FlowRate.Value' in work_table
assert 'CurrentTargetValue := AWorkTable.FlowRate.Value' in work_table
assert 'TargetObjectChanged' in work_table

for event in ('SimulationFlowApplyEnter', 'SimulationFlowCalculated',
              'SimulationFlowSample', 'SimulationFlowApplyRejected',
              'SimulationFlowSampleNotCalled'):
    assert event in work_table
for reason in ('SimulationInactive', 'WorkTableNil', 'FlowRateNil',
               'FlowValueNil', 'NoEnabledEtalons', 'CalculatedValueInvalid',
               'SetValueFailed', 'SampleNotAdded', 'SampleTimestampNotFresh',
               'TargetObjectMismatch', 'TargetObjectChanged',
               'DuplicateSamplesAdded'):
    assert f"Reject('{reason}')" in work_table
assert 'Version=%s; GeneratedValue=' in work_table
assert 'FreshAfterStageStart=%s; SameObject=True' in work_table
assert 'TMeterValue.GetMonotonicTimeMs' in work_table
assert 'function TMeterValue.ApplyGeneratedValue' in meter_value
assert 'SetValue(AValue);' in meter_value
assert meter_value.count('AddStabilitySample(Value, ASampleTimeMs, mssAutomatic)') == 1
assert 'property StabilityDataStartMs: Int64 read FStabilityDataStartMs;' in measurement_run
assert 'if IsSimulationMode then\n  FreshDataReady := True' not in measurement_run
print('simulation flow stability static checks passed')
