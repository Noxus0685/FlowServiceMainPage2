from pathlib import Path

root = Path(__file__).resolve().parents[1]
pas = (root / 'frmProceed.pas').read_text(encoding='utf-8-sig')
fmx = (root / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
xlsx = (root / 'uGridXlsxExporter.pas').read_text(encoding='utf-8-sig')

def need(fragment, message):
    assert fragment in pas, message

for kind in ('pscNone', 'pscWorkTable', 'pscDevice', 'pscSession'):
    need(kind, f'missing selection context kind {kind}')
for field in ('WorkTableUUID', 'DeviceUUID', 'SessionID'):
    need(field, f'missing context identity field {field}')
need('function TFrameProceed.ResolveSelectionContext', 'missing context resolver')
need('procedure TFrameProceed.ApplySelectionContext', 'missing unified context application')
tree_change = pas.split('procedure TFrameProceed.TreeViewDevicesChange', 1)[1].split('end;', 1)[0]
assert 'ResolveSelectionContext' in tree_change and 'ApplySelectionContext' in tree_change
assert 'ShowWorkTableResults' not in tree_change and 'ShowSessionSpillages' not in tree_change

for state in ('pcsEmpty', 'pcsValid', 'pcsErrorExceeded', 'pcsConditionFailed',
              'pcsInvalid', 'pcsCancelled'):
    need(state, f'missing point cell state {state}')
need('BuildProceedPointCellInfo', 'missing unified point cell builder')
need('GridRow.PointCells[PointIdx].CellState', 'drawing does not use point cell model')
need('FCurrentResultRows[J].PointCells[PointIdx]', 'export does not use point cell model')
assert "Result.DisplayText := #$2014" in pas
assert "Result.HintText := 'Результат отсутствует в текущей сессии'" in pas

popup = pas.split('procedure TFrameProceed.PopupMenuGridResultsPopup', 1)[1][:2500]
assert "ColumnsRoot.Text := 'Столбцы'" in popup
assert 'PopupMenuGridResults.Clear' not in popup
assert 'ColumnsRoot.AddObject(Item)' in popup
assert "Item.Text := 'Восстановить по умолчанию'" in pas

popup_tree = pas.split('procedure TFrameProceed.PopupMenuTreeViewDevicesPopup', 1)[1][:5000]
assert "AddSimpleMenuItem('Редактировать прибор'" in popup_tree
need('Context := ResolveSelectionContext', 'editor does not use unified context')

button = fmx.split('object ButtonProceedExportExcel: TButton', 1)[1].split('end', 1)[0]
assert 'Align = Left' in button and 'Enabled = False' in button
assert "StyleLookup = 'composetoolbutton'" in button
assert 'Visible = False' not in button and 'Position.X' not in button
assert 'OnClick = ButtonProceedExportExcelClick' in button
need('ButtonProceedExportExcel.Visible := True', 'runtime must keep export visible')
need('ProceedExportButtonState', 'missing one-shot export button diagnostics')

assert "AddWorksheet('Причины')" in xlsx
for event in ('ProceedSelectionContextResolved', 'ProceedContextApplied',
              'ProceedGridActiveSessionRow'):
    need(event, f'missing aggregate protocol event {event}')

print('Proceed 1.0.68 context checks passed')
