from pathlib import Path
import re


SOURCE = Path(__file__).resolve().parents[1] / "frmMeterValueEditFrame.pas"


def test_tolerance_lines_receive_one_actual_y_step_of_padding():
    text = SOURCE.read_text(encoding="utf-8-sig")

    assert "YStep := CalculateYAxisStep(AxisMinY, AxisMaxY);" in text
    assert "DesiredMinY := LowerLimit - YStep;" in text
    assert "DesiredMaxY := UpperLimit + YStep;" in text
    assert "AxisMinY := Min(DataMinY, DesiredMinY);" in text
    assert "AxisMaxY := Max(DataMaxY, DesiredMaxY);" in text
    assert re.search(
        r"ActualYStep := CalculateYAxisStep\(AxisMinY, AxisMaxY\);\s*"
        r"if ActualYStep <= YStep then",
        text,
    )


def test_manual_y_range_is_applied_to_stability_chart():
    text = SOURCE.read_text(encoding="utf-8-sig")

    assert "ChartStability.AutoRangeY := False;" in text
    assert "ChartStability.YMin := AxisMinY;" in text
    assert "ChartStability.YMax := AxisMaxY;" in text


def test_trend_and_forecast_are_included_in_data_range():
    text = SOURCE.read_text(encoding="utf-8-sig")

    assert "DataMinY := Min(DataMinY, Min(TrendStartValue, TrendEndValue));" in text
    assert "DataMaxY := Max(DataMaxY, Max(TrendStartValue, TrendEndValue));" in text
    assert "DataMinY := Min(DataMinY, Min(DisplayValue, ForecastValue));" in text
    assert "DataMaxY := Max(DataMaxY, Max(DisplayValue, ForecastValue));" in text
