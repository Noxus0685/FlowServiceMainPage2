from pathlib import Path


ROOT = Path(__file__).parents[1]
CHART = (ROOT / "Components" / "FP" / "FMX.SimpleChart.pas").read_text(
    encoding="utf-8-sig"
)
GRID = (ROOT / "uGridLayoutManager.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def section(text, start, end):
    left = text.index(start)
    right = text.index(end, left + len(start))
    return text[left:right]


def test_overlapping_y_point_labels_are_replaced_with_one_average():
    markers = section(
        CHART,
        "procedure TSimpleChart.DrawMarkersForSeries",
        "procedure TSimpleChart.DrawSeries",
    )
    assert "AYLabels: TList<TChartYLabelInfo>" in markers
    assert "YLabel.Value := PointValue.Y" in markers
    assert "AYLabels.Add(YLabel)" in markers
    assert "TryPlaceYLabel" not in markers


def test_y_labels_use_arithmetic_mean_without_displacement_lines():
    labels = section(
        CHART,
        "procedure TSimpleChart.DrawAveragedYLabels",
        "procedure TSimpleChart.DrawSeries",
    )
    assert "AverageValue := SumValue / GroupCount" in labels
    assert "AverageScreenY := WorldToScreen(PointF(FXMin, AverageValue)).Y" in labels
    assert "FormatFloat('0.###', AverageValue)" in labels
    assert "Canvas.DrawLine" not in labels


def test_vertical_axis_title_uses_the_full_plot_height():
    axes = section(
        CHART,
        "procedure TSimpleChart.DrawAxesAndGrid",
        "procedure TSimpleChart.DrawMarkersForSeries",
    )
    assert "-plotRect.Bottom" in axes
    assert "-plotRect.Top" in axes
    assert "-CenterY - 30" not in axes


def test_grid_invalidates_cached_content_size_before_refresh():
    refresh = section(
        GRID,
        "procedure TGridLayoutState.RefreshGridPresentation",
        "procedure TGridLayoutState.ColumnResizeHandler",
    )
    invalidate = refresh.index("FGrid.Model.InvalidateContentSize")
    changed = refresh.index("FGrid.Model.ContentChanged")
    repaint = refresh.index("FGrid.Repaint")
    assert invalidate < changed < repaint


def test_manual_resize_finish_uses_the_same_full_presentation_refresh():
    finish = section(
        GRID,
        "function TGridLayoutState.FinishPendingManualResize",
        "function TGridLayoutState.EndManualColumnResize",
    )
    assert "RefreshGridPresentation" in finish
    assert "FGrid.Repaint" not in finish


def test_release_version():
    assert "APP_VERSION = '1.0.90'" in VERSION
