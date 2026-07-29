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


def test_both_deviation_columns_use_their_own_current_and_mean_flow():
    for channel_collection in ("DeviceChannels", "EtalonChannels"):
        flow = (
            rf"WorkTable\.{channel_collection}\[ARow\]\.FlowMeter\.ValueFlow"
        )
        assert re.search(
            rf"CalculateCurrentDeviationPercent\(\s*"
            rf"{flow}\.GetDoubleValue,\s*"
            rf"{flow}\.GetDoubleMeanValue\)",
            SOURCE,
        )


def test_deviation_calculation_preserves_sign_and_guards_zero_mean():
    assert "if Abs(AMeanValue) <= CurrentDeviationEpsilon then" in SOURCE
    assert (
        "Result := (ACurrentValue - AMeanValue) / Abs(AMeanValue) * 100;"
        in SOURCE
    )
    assert "Abs(ACurrentValue - AMeanValue)" not in SOURCE
