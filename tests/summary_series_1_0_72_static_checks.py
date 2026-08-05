from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.73'" in VERSION
assert 'function FormatMergedSummarySeriesResults' in PROCEED
assert "Format('Серия %d: %s'" in PROCEED
assert 'SummarySeriesResultSelection' in PROCEED
assert 'MinimumAbsoluteError' in PROCEED
assert 'Abs(Spillage.Error) < Abs(CurrentBest.Error)' in PROCEED
assert 'ParticipantKey(ASpillage: TPointSpillage)' in PROCEED
assert 'AnsiUpperCase(Trim(ASpillage.DeviceUUID))' in PROCEED
assert 'AnsiUpperCase(Trim(ASpillage.DeviceTypeUUID))' in PROCEED
assert 'FormatMergedSummarySeriesResults(FResultPointColumns[I], Spillages, SelectedSpillages)' in PROCEED
