from pathlib import Path

root = Path(__file__).resolve().parents[1]
proceed = (root / 'frmProceed.pas').read_text(encoding='utf-8-sig')
fmx = (root / 'frmProceed.fmx').read_text(encoding='utf-8-sig')
exporter = (root / 'uGridXlsxExporter.pas').read_text(encoding='utf-8-sig')
version = (root / 'uAppVersion.pas').read_text(encoding='utf-8-sig')

def require(value, message):
    if not value:
        raise AssertionError(message)

require("APP_VERSION = '1.0.71'" in version, 'release version is not 1.0.71')
require('Spillage.SessionID <> ASession.ID' in proceed,
        'point lookup must reject spillages outside the row session')
filter_pos = proceed.index('Spillage.SessionID <> ASession.ID')
match_pos = proceed.index("if (TypeUUID <> '')", filter_pos)
require(filter_pos < match_pos, 'session filter must precede point matching')
require('Device.GetActiveSessionSpillage' in proceed,
        'production active-session resolver is not used')
require('(Spillage.Num > Result.Num)' in proceed and '(Spillage.ID > Result.ID)' in proceed,
        'repeat priority must use Num then ID')
require("Result.DisplayText := #$2014" in proceed and 'ASpillage.StatusStr' in proceed,
        'unfinished points must render an em dash with a status hint')
require('Результат отсутствует в текущей сессии' in proceed,
        'missing active-session result hint is absent')
require("CProceedGridColumnsSection = 'ProceedGridColumns'" in proceed,
        'proceed grid needs an isolated settings section')
for suffix in ('.Visible', '.Width', '.Order'):
    require(suffix in proceed, f'missing persisted column property {suffix}')
require(all(prefix in proceed for prefix in ("'WorkPoint.'", "'DevicePoint.'",
        "'SessionPoint.'")), 'context point keys are not UUID based')
require("ColumnsRoot.Text := 'Столбцы'" in proceed and
        "Item.Text := 'Восстановить по умолчанию'" in proceed,
        'column reset command is absent')
require('Редактировать прибор' in proceed and 'TFormDeviceEditor.Create' in proceed,
        'tree device editor must reuse the production editor')
require('ButtonProceedExportExcel' in fmx and
        'OnClick = ButtonProceedExportExcelClick' in fmx,
        'Proceed toolbar export button is absent')
require('TGridExportSnapshot' in exporter and 'uOpenXmlXlsx' in exporter,
        'FMX-independent Proceed XLSX snapshot/exporter is absent')
require('GridResults.Columns[I].Visible' in proceed,
        'export must honor visible grid columns')
require('ProceedGridContextBuilt' in proceed and
        'ProceedGridActiveSessionRow' in proceed and
        'ProceedGridColumnsLoaded' in proceed and
        'ProceedGridExportCompleted' in proceed,
        'required aggregate protocol events are absent')
require('SummaryResults CELL' not in proceed,
        'per-cell SummaryResults logging must be removed')
print('Proceed 1.0.71 compatibility checks passed')
