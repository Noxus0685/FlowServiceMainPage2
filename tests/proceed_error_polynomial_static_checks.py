from pathlib import Path


SOURCE = (Path(__file__).parents[1] / "frmProceed.pas").read_text(encoding="utf-8")


def chart_method() -> str:
    start = SOURCE.index("procedure TFrameProceed.UpdateSessionErrorChart;")
    end = SOURCE.index("procedure TFrameProceed.ComboBoxUnitsResultChange", start)
    return SOURCE[start:end]


def test_chart_uses_polynomial_regression_instead_of_reciprocal_interpolation():
    method = chart_method()
    assert "FitPolynomial(AveragePoints" in method
    assert "EvaluatePolynomial(PolynomialCoefficients" in method
    assert "1 / AveragePoints" not in method


def test_quadratic_requires_more_points_than_exact_interpolation():
    method = chart_method()
    assert "if AveragePoints.Count >= 4 then" in method
    assert "PolynomialDegree := 2" in method
    assert "PolynomialDegree := 1" in method
    assert "APoints.Count < ADegree + 2" in method


def test_polynomial_fit_rejects_degenerate_and_non_finite_results():
    method = chart_method()
    assert "SameValue(Matrix[PivotRow][Column], 0.0, 1E-12)" in method
    assert "IsNan(ACoefficients[Row + 1])" in method
    assert "IsInfinite(ACoefficients[Row + 1])" in method

