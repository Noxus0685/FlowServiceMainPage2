from pathlib import Path

root = Path(__file__).resolve().parents[1]
unit_work_table = (root / 'UnitWorkTable.pas').read_text(encoding='utf-8-sig')
frm_main_table = (root / 'frmMainTable.pas').read_text(encoding='utf-8-sig')
fu_main = (root / 'fuMain.pas').read_text(encoding='utf-8-sig')


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)

# 1) Базовые ограничения TParameters
require('procedure TParameters.SetValue(AValue: Double);' in unit_work_table, 'SetValue отсутствует')
require('if AValue < FMin then' in unit_work_table and 'else if AValue > FMax then' in unit_work_table,
        'SetValue должен ограничивать диапазон [FMin..FMax]')

# 2) Исправление SetMin/SetMax: не должно быть неинициализированного WorkTable
require('WorkTable:TWorkTable' not in unit_work_table,
        'В SetMin/SetMax не должно быть локального неинициализированного WorkTable')
require('FMin := Value;' in unit_work_table and 'FMax := Value;' in unit_work_table,
        'SetMin/SetMax должны задавать значения напрямую')

# 2.1) Для расхода границы должны сохраняться в базовых единицах через GetDoubleNum
require('procedure TWorkTable.SetFlowRateMin' in unit_work_table and 'AValueBase := ValueFlowRate.GetDoubleNum(AValue);' in unit_work_table,
        'SetFlowRateMin должен переводить значение в базовые единицы')
require('FlowRate.FMin := AValueBase;' in unit_work_table,
        'SetFlowRateMin должен сохранять FMin в базовых единицах')
require('procedure TWorkTable.SetFlowRateMax' in unit_work_table,
        'SetFlowRateMax отсутствует')
require('FlowRate.FMax := AValueBase;' in unit_work_table,
        'SetFlowRateMax должен сохранять FMax в базовых единицах')

# 2.2) Для давления границы должны сохраняться в базовых единицах через GetDoubleNum
require('procedure TWorkTable.SetPressureMin' in unit_work_table and 'AValueBase := ValuePressure.GetDoubleNum(AValue);' in unit_work_table,
        'SetPressureMin должен переводить значение в базовые единицы')
require('FluidPress.FMin := AValueBase;' in unit_work_table,
        'SetPressureMin должен сохранять FMin в базовых единицах')
require('procedure TWorkTable.SetPressureMax' in unit_work_table,
        'SetPressureMax отсутствует')
require('FluidPress.FMax := AValueBase;' in unit_work_table,
        'SetPressureMax должен сохранять FMax в базовых единицах')

# 3) Имитация на таймере main-формы должна обновлять насос/расход/климат/давление
require('procedure TFormMain.TimerSetValuesTimer(Sender: TObject);' in fu_main,
        'TimerSetValuesTimer отсутствует')
for snippet in [
    'UpdateRandomFreq(Pump);',
    'UpdateRandomFlowRate(FlowRate);',
    'UpdateRandomClimate(WorkTable);',
    'UpdateRandomPress(WorkTable);',
]:
    require(snippet in fu_main, f'В TimerSetValuesTimer нет вызова {snippet}')

# 4) Перекраска label/rectangle в зависимости от запуска и попадания в погрешность
require('RectangleLabelFR.Fill.Color := $ffC9FFC7' in frm_main_table,
        'FlowRate должен иметь зеленый цвет при стабильности')
require('RectangleLabelFR.Fill.Color := TAlphaColorRec.Lightyellow' in frm_main_table,
        'FlowRate должен иметь желтый цвет при нестабильности')
require('Rectangle7.Fill.Color := $ffC9FFC7' in frm_main_table,
        'Температура должна иметь зеленый цвет при стабильности')
require('Rectangle11.Fill.Color := $ffC9FFC7' in frm_main_table,
        'Давление должно иметь зеленый цвет при стабильности')

# 5) Ввод/вывод значения расхода и пересчет в имп/с
require('ImpSec := (FlowRate * Coef) / 3.6;' in fu_main,
        'Пересчет flow -> imp/sec отсутствует')
require('EditDeviceImpSec.Text := FloatToStr(ImpSec);' in fu_main,
        'Вывод device imp/sec отсутствует')
require('EditEtalonImpSec.Text := FloatToStr(ImpSec);' in fu_main,
        'Вывод etalon imp/sec отсутствует')

print('OK: static checks for TParameters-related flow/press behavior passed.')
