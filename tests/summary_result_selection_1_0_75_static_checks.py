from pathlib import Path

PROCEED = Path('frmProceed.pas').read_text(encoding='utf-8-sig')
VERSION = Path('uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.77'" in VERSION
assert 'function IsValidSummaryResultSpillage' in PROCEED
assert 'SummaryResultSelection' in PROCEED
assert 'InvalidDoubleValue' in PROCEED
assert 'IsNan(ASpillage.Error)' in PROCEED
assert 'IsInfinite(ASpillage.Error)' in PROCEED
assert 'Abs(ASpillage.Error) >= MaxDouble' in PROCEED
assert 'not ASpillage.Valid' in PROCEED
assert 'LogSummaryResultSelection(AColumn.Header, Spillage, False, SkipReason' in PROCEED
assert 'LogSummaryResultSelection(GroupKey, Item, False, SkipReason' in PROCEED
assert 'MinimumAbsoluteError' in PROCEED

assert 'CurrentBest := nil;' in PROCEED
assert 'Result := FormatResultErrorValue(CurrentBest.Error)' in PROCEED
assert "Format('Серия %d: %s'" not in PROCEED
