from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
fmx = (root / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
pas = (root / 'frmProceed.pas').read_text(encoding='utf-8-sig')
version = (root / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

assert "APP_VERSION = '1.0.71'" in version
assert len(re.findall(r'^\s*object\s+\w+:\s*TToolBar\s*$', fmx, re.M)) == 1
assert fmx.count('object ButtonProceedExportExcel: TButton') == 1
assert 'object ToolBarResults: TToolBar' not in fmx

toolbar = fmx.split('object ToolBarDataPoints: TToolBar', 1)[1]
toolbar = toolbar.split('object lyt1: TLayout', 1)[0]
assert 'Align = Top' in toolbar
assert 'Size.Height = 32.000000000000000000' in toolbar

button = fmx.split('object ButtonProceedExportExcel: TButton', 1)[1].split('        end', 1)[0]
assert 'Align = Left' in button
assert 'Enabled = False' in button
assert 'Visible = False' not in button
assert 'Position.X' not in button
assert 'Size.Width = 40.000000000000000000' in button
assert 'Size.Height = 32.000000000000000000' in button
assert "StyleLookup = 'composetoolbutton'" in button
assert 'ParentShowHint = False' in button and 'ShowHint = True' in button
assert 'OnClick = ButtonProceedExportExcelClick' in button
assert "Hint = 'Выгрузить выбранные данные в Excel'" in button
assert 'Visible = True' in button

assert 'TToolBar.Create' not in pas and 'TButton.Create' not in pas
assert pas.count('procedure TFrameProceed.ButtonProceedExportExcelClick') == 1
assert 'ButtonProceedExportExcel.Visible := True' in pas
assert 'ButtonProceedExportExcel.Enabled := Length(FCurrentResultRows) > 0' in pas
assert 'uGridXlsxExporter' in pas and 'TGridXlsxExporter.ExportToFile' in pas
assert 'FSelectionContext' in pas
assert 'ProceedToolbarLayoutResolved' in pas

layout_top = re.search(r'object LayoutTop: TLayout(?P<body>.*?)object ToolBarDataPoints:',
                       fmx, re.S).group('body')
assert 'Size.Height = 33.000000000000000000' in layout_top
tree = fmx.split('object TreeViewDevices: TTreeView', 1)[1].split('end', 1)[0]
assert 'Align = Client' in tree
height = re.search(r'Size.Height = ([0-9.]+)', tree)
assert height and float(height.group(1)) > 0

print('Proceed 1.0.71 toolbar checks passed')
