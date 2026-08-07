from pathlib import Path

ROOT = Path(__file__).parents[1]
CHART = (ROOT / "Components" / "FP" / "FMX.SimpleChart.pas").read_text(
    encoding="utf-8-sig"
)


def section(text, start, end):
    left = text.index(start)
    right = text.index(end, left + len(start))
    return text[left:right]


def test_point_guide_tracks_both_axis_labels():
    declaration = section(
        CHART,
        "procedure TSimpleChart.DrawMarkersForSeries",
        "procedure TSimpleChart.DrawSeries",
    )
    assert "ADrawnXLabels, ADrawnYLabels: TList<Double>" in declaration
    assert "IsAxisLabelDrawn(PointValue.X, ADrawnXLabels)" in declaration
    assert "IsAxisLabelDrawn(PointValue.Y, ADrawnYLabels)" in declaration
    assert "ADrawnXLabels.Add(PointValue.X)" in declaration
    assert "ADrawnYLabels.Add(PointValue.Y)" in declaration


def test_axis_label_comparison_uses_same_tolerance_for_x_and_y():
    declaration = section(
        CHART,
        "procedure TSimpleChart.DrawMarkersForSeries",
        "procedure TSimpleChart.DrawSeries",
    )
    assert "function IsAxisLabelDrawn" in declaration
    assert "Max(1E-9, Abs(AValue) * 1E-9)" in declaration


def test_draw_series_owns_separate_axis_label_lists():
    draw_series = section(
        CHART,
        "procedure TSimpleChart.DrawSeries",
        "procedure TSimpleChart.Paint",
    )
    assert "DrawnXLabels, DrawnYLabels: TList<Double>" in draw_series
    assert "DrawnYLabels := TList<Double>.Create" in draw_series
    assert "DrawMarkersForSeries(series, DrawnXLabels, DrawnYLabels)" in draw_series
    assert "DrawnYLabels.Free" in draw_series
