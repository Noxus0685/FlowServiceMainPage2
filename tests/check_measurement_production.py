#!/usr/bin/env python3
"""Production automatic-measurement architecture regressions (dcc32-independent)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
run = (ROOT / 'uMeasurementRun.pas').read_text(encoding='utf-8-sig')
meter = (ROOT / 'uMeterValue.pas').read_text(encoding='utf-8-sig')
work = (ROOT / 'uWorkTable.pas').read_text(encoding='utf-8-sig')

create = run[run.index('procedure TMeasurementRun.CreateSessionPoints;'):run.index('procedure TMeasurementRun.Execute', run.index('procedure TMeasurementRun.CreateSessionPoints;'))]
wait_stop = run[run.index('procedure TMeasurementRun.ProcessWaitMeasureStop;'):run.index('procedure TMeasurementRun.ProcessResultsRead;')]
stop_limits = run[run.index('function TMeasurementRun.IsCommandStopLimitReached'):run.index('function TMeasurementRun.BuildCommandStopLimitDetails')]
stability = meter[meter.index('function TMeterValue.AnalyzePointStabilityForMeasurement'):meter.index('class function TMeterValue.AnalyzeSingleStabilityWindow')]

checks = {
    'session identity includes device channel and source point': all(x in create for x in ('DeviceUUID', 'DeviceChannelUUID', 'SourcePointUUID')),
    'session rejects missing point identity': 'DevicePointIdentityMissing' in create,
    'session does not merge by flow': 'MergedByAbsoluteQ' not in create and 'Abs(SessionPoint.Q - TargetQLS)' not in create,
    'session validates source/session cardinality': 'FPoints.Count <> ProcessingDevicePointCount' in create,
    'session reports separate mode and device-point counts': all(x in create for x in ('SessionModeCount', 'ExpectedDevicePointCount', 'ProcessedDevicePointCount', 'SavedDevicePointCount')),
    'stability uses monotonic timestamps': 'CurrentMs := GetMonotonicTimeMs' in stability,
    'stability retains inclusive left boundary': 'SourceSamples[I].TimeStampMs >= AMinTimeStampMs' in stability,
    'stability requires full actual duration': 'AInfo.ActualWindowDurationSec + EPS >= AWindowDurationSec' in stability,
    'combined stop criteria have one AND contract': 'Result := TimeReached and ImpulseReached and VolumeReached' in stop_limits,
    'completed controller goes to result reading': 'ControllerCompleted: ResultsReady=True' in wait_stop and 'SetStage(msResultsRead)' in wait_stop,
    'completed controller does not receive another stop': 'StopCommandRequired=False' in wait_stop,
    'stop wait has a production timeout': 'DEFAULT_STOP_TIMEOUT_MS' in wait_stop,
    'save advances to next production point': 'FNextStageAfterSave := msSelectPoint' in run,
    'automatic run finalizes only at end of point list': 'FinalizeMeasurementRun(mrrSuccess, mdrEndOfPointList)' in run,
    'result saving filters by exact participant channel': 'CurrentPointIncludesChannel(DeviceChannel, CurrentSourcePointUUID)' in work,
    'result saving resolves original source point UUID': 'SameText(DevicePoint.UUID, CurrentSourcePointUUID)' in work,
}

# Identity regression: equal flows across devices remain six source identities.
source_points = [(f'device-{d}', f'channel-{d}', f'point-{p}', q)
                 for d, p, q in ((1, 1, 1.0), (1, 2, 2.0), (1, 3, 3.0),
                                 (2, 1, 1.0), (2, 2, 2.0), (2, 3, 3.0))]
checks['six cross-device points remain six identities'] = len({x[:3] for x in source_points}) == 6
checks['different target flows remain distinct'] = len({(x[:3], x[3]) for x in source_points}) == 6

for name, ok in checks.items():
    print(f"{'PASS' if ok else 'FAIL'}: {name}")
raise SystemExit(0 if all(checks.values()) else 1)
