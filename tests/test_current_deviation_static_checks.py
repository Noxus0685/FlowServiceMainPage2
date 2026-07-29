import math
import re
from pathlib import Path


SOURCE = (Path(__file__).parents[1] / "frmMainTable.pas").read_text(
    encoding="utf-8-sig"
)


def _deviation(current: float, mean: float) -> float:
    if abs(mean) <= 1e-12:
        return 0.0
    return (current - mean) / abs(mean) * 100


def test_current_deviation_examples_and_zero_mean_are_finite():
    cases = (
        (100, 100, 0),
        (105, 100, 5),
        (95, 100, -5),
        (0, 100, -100),
        (100, 0, 0),
    )

    for current, mean, expected in cases:
        actual = _deviation(current, mean)
        assert math.isfinite(actual)
        assert actual == expected


def test_fractional_deviation_examples_keep_value_and_sign():
    assert math.isclose(_deviation(11.98, 12.03), -0.4156276, abs_tol=1e-7)
    assert math.isclose(_deviation(12.02, 12.07), -0.4142502, abs_tol=1e-7)
    assert math.isclose(_deviation(12.22, 12.18), 0.3284072, abs_tol=1e-7)


def test_both_deviation_columns_use_shared_average_flow_calculation():
    for channel_collection in ("DeviceChannels", "EtalonChannels"):
        block = re.search(
            rf"FlowMeter := WorkTable\.{channel_collection}\[ARow\]\.FlowMeter;"
            rf".*?CalculateCurrentDeviationPercent\(\s*CurrentFlow, AverageFlow\),"
            rf" 2, 0\);",
            SOURCE,
            re.DOTALL,
        )
        assert block
        assert "TryGetAverageFlow(FlowMeter, WorkTable, AverageFlow)" in block.group()
        assert "CurrentFlow := FlowMeter.ValueFlow.GetDoubleValue" in block.group()


def test_average_text_and_deviation_share_try_get_average_flow():
    assert SOURCE.count("TryGetAverageFlow(") >= 4
    assert "AAverageFlow := AFlowMeter.ValueQuantity.GetDoubleValue / MeasureTime;" in SOURCE
    assert "if MeasureTime <= 0 then" in SOURCE
    assert "GetDoubleMeanValue)," not in SOURCE


def test_deviation_calculation_preserves_sign_and_guards_zero_mean():
    assert "if Abs(AMeanValue) <= CurrentDeviationEpsilon then" in SOURCE
    assert (
        "Result := (ACurrentValue - AMeanValue) / Abs(AMeanValue) * 100;"
        in SOURCE
    )
    assert "Abs(ACurrentValue - AMeanValue)" not in SOURCE
