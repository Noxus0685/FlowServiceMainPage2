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


def test_y_point_labels_use_non_overlapping_screen_rectangles():
    markers = section(
        CHART,
        "procedure TSimpleChart.DrawMarkersForSeries",
        "procedure TSimpleChart.DrawSeries",
    )
    assert "ADrawnYLabelRects: TList<TRectF>" in markers
    assert "function TryPlaceYLabel" in markers
    assert "ADrawnYLabelRects.Add(TextRect)" in markers
    assert "DrawnYLabels" not in markers


def test_shifted_y_labels_keep_a_visual_link_to_their_value():
    markers = section(
        CHART,
        "procedure TSimpleChart.DrawMarkersForSeries",
        "procedure TSimpleChart.DrawSeries",
    )
    assert "Canvas.DrawLine(PointF(TextRect.Right + 2" in markers
    assert "PointF(PlotRect.Left - 2, ScreenPt.Y)" in markers


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
    assert "APP_VERSION = '1.0.89'" in VERSION
