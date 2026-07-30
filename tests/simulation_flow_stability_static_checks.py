from pathlib import Path

work_table = Path('uWorkTable.pas').read_text(encoding='utf-8')
meter_value = Path('uMeterValue.pas').read_text(encoding='utf-8')
measurement_run = Path('uMeasurementRun.pas').read_text(encoding='utf-8')

assert 'ApplySimulatedTableFlowValue(AWorkTable, CalculateActualEtalonFlow(AWorkTable))' in work_table
assert 'WorkTableFlowValue := AWorkTable.FlowRate.Value' in work_table
assert 'SimulationTargetValue := WorkTableFlowValue' in work_table
assert 'SimulationFlowTargetMismatch' in work_table
assert 'SimulationFlowSampleRejected' in work_table
assert 'SimulationFlowSample' in work_table
assert 'DIAGNOSTIC_INTERVAL_MS = 2000' in work_table
assert 'TMeterValue.GetMonotonicTimeMs' in work_table
assert 'SimulationTargetValue.ApplyGeneratedValue' in work_table
assert 'BoolToStr(SameObject, True)' not in work_table
assert "IfThen(SameObject, 'True', 'False')" in work_table
assert 'function TMeterValue.ApplyGeneratedValue' in meter_value
assert 'SetValue(AValue);' in meter_value
assert 'AddStabilitySample(Value, ASampleTimeMs, mssAutomatic)' in meter_value
assert 'property StabilityDataStartMs: Int64 read FStabilityDataStartMs;' in measurement_run

# The fix must remain in the simulator/value layer, not bypass freshness in the FSM.
assert 'if IsSimulationMode then\n  FreshDataReady := True' not in measurement_run
print('simulation flow stability static checks passed')
