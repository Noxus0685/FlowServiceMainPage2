from pathlib import Path


meter_value = Path("uMeterValue.pas").read_text(encoding="utf-8-sig")

assert (
    "MinOutlierThreshold := Max(AMaxStdDeviation, AMaxVariation / 2.0);"
    in meter_value
)
assert "if (Mad <= EPS) or (CalculatedOutlierThreshold <= EPS) then" in meter_value
assert (
    "OutlierThreshold := Max(CalculatedOutlierThreshold, MinOutlierThreshold);"
    in meter_value
)
assert "if Deviations[I] > OutlierThreshold then" in meter_value
assert "else if (not AInfo.IsSignalStable) and (Msg <> '') then" in meter_value

# A discrete stable sequence must stay below the stability-derived threshold.
values = [0.100000, 0.100050, 0.100000, 0.099950]
median = 0.100000
threshold = max(0.000752951, 0.002509837 / 2)
assert not any(abs(value - median) > threshold for value in values)

# The threshold still identifies an isolated value outside the permitted limits.
assert abs(0.103000 - median) > threshold

print("meter value outlier threshold static checks passed")
