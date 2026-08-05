from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / 'frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = (ROOT / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.75'" in VERSION
assert 'function FormatMergedSummarySeriesResults' in PROCEED
assert 'FormatMergedSummarySeriesResults(FResultPointColumns[I], Spillages, SelectedSpillages)' in PROCEED
assert 'SummaryResultSelection' in PROCEED
assert 'MinimumAbsoluteError' in PROCEED
assert 'CurrentBest := nil;' in PROCEED
assert 'Abs(Spillage.Error) < Abs(CurrentBest.Error)' in PROCEED
assert "Result := FormatResultErrorValue(CurrentBest.Error)" in PROCEED
assert "Format('Серия %d: %s'" not in PROCEED
assert 'SummarySeriesResultSelection' not in PROCEED
