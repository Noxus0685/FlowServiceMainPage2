from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACTIVE_FORMS = (
    "frmProceed",
    "frmCalibrCoefs",
    "fuMeterValues",
)
ALL_CHART_FORMS = ACTIVE_FORMS + ("FormMeterValue",)


def read(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8-sig")


SIMPLE_CHART = read("Components/FP/FMX.SimpleChart.pas")


def test_active_forms_no_longer_reference_teechart():
    for unit_name in ACTIVE_FORMS:
        pas = read(f"{unit_name}.pas")
        fmx = read(f"{unit_name}.fmx")
        assert ": TChart;" not in pas
        assert "FMXTee" not in pas
        assert ": TChart" not in fmx


def test_all_requested_forms_stream_simple_charts():
    expected_names = {
        "frmProceed": "Chart1",
        "frmCalibrCoefs": "ChartCoefs",
        "fuMeterValues": "Chart1",
        "FormMeterValue": "Chart1",
    }
    for form_name in ALL_CHART_FORMS:
        assert (
            f"object {expected_names[form_name]}: TSimpleChart"
            in read(f"{form_name}.fmx")
        )


def test_calibration_chart_uses_simple_chart_series_api():
    source = read("frmCalibrCoefs.pas")
    assert "ChartCoefs: TSimpleChart;" in source
    assert "ChartCoefs.ClearAllSeries;" in source
    assert "ChartCoefs.BeginUpdate;" in source
    assert "ChartCoefs.EndUpdate;" in source
    assert "TFastLineSeries" not in source
    assert "TLineSeries" not in source
    assert "TPointSeries" not in source


def test_simple_chart_is_registered_for_runtime_fmx_streaming():
    assert "initialization" in SIMPLE_CHART
    registrations = (
        "RegisterFmxClasses([TSimpleChart]);",
        "RegisterClass(TSimpleChart);",
    )
    assert sum(registration in SIMPLE_CHART for registration in registrations) == 1
