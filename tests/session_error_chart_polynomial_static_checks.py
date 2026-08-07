from pathlib import Path

SOURCE = (Path(__file__).resolve().parents[1] / "frmProceed.pas").read_text(encoding="utf-8-sig")
START = SOURCE.index("procedure TFrameProceed.UpdateSessionErrorChart;")
END = SOURCE.index("procedure TFrameProceed.ComboBoxUnitsResultChange", START)
BODY = SOURCE[START:END]

assert "1 / AveragePoints" not in BODY
assert "TryCalculatePolynomialCoefficients" in BODY
assert "EvaluatePolynomial(PolynomialCoefficients, Z)" in BODY
assert "PolynomialDegree := Min(CChartPolynomialMaxDegree," in BODY
assert "AveragePoints.Count - 1" in BODY
assert "APoints.Count = 0" in BODY
assert "APoints.Count < ADegree + 1" in BODY
assert "while (PolynomialDegree >= 0)" in BODY
assert "Abs(Pivot) <= CPivotEpsilon" in BODY
assert "IsNan(ACoefficients[Row]) or IsInfinite(ACoefficients[Row])" in BODY
assert "(AveragePoints.Count = 1) or" in BODY
assert "SameValue(AveragePoints[0].X," in BODY
assert "CChartPolynomialSampleCount" in BODY
assert "— полиномиальная аппроксимация" in BODY

print("OK: session error chart uses guarded per-device polynomial approximation.")
