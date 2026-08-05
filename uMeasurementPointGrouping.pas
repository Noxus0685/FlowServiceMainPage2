unit uMeasurementPointGrouping;

interface

type
  TMeasurementPointGrouping = class
  public
    // Рассчитывает диапазон расхода поверочной точки с учетом погрешности.
    class function CalculatePointRange(
      AQ: Double;
      AErrorPercent: Double;
      out AMinQ: Double;
      out AMaxQ: Double;
      out ADeltaQ: Double
    ): Boolean; static;

    // Проверяет возможность объединения двух диапазонов расхода.
    class function CalculateMergedRange(
      ACurrentMinQ,
      ACurrentMaxQ,
      ACurrentDeltaQ,
      ANewMinQ,
      ANewMaxQ,
      ANewDeltaQ: Double;
      out ANewCommonMinQ,
      ANewCommonMaxQ,
      AIntersectionQ,
      AControlDeltaQ: Double
    ): Boolean; static;

    // Определяет, являются ли две поверочные точки одной физической точкой.
    class function ArePointsEquivalent(
      AQ1,
      AError1,
      AQ2,
      AError2: Double
    ): Boolean; static;
  end;

implementation

uses
  System.Math;

const
  FloatTolerance = 1E-9;

class function TMeasurementPointGrouping.CalculatePointRange(AQ,
  AErrorPercent: Double; out AMinQ, AMaxQ, ADeltaQ: Double): Boolean;
begin
  ADeltaQ := 0;
  AMinQ := AQ;
  AMaxQ := AQ;
  Result := (not IsNan(AErrorPercent)) and
    (not IsInfinite(AErrorPercent)) and (AErrorPercent > 0) and
    (not IsNan(AQ)) and (not IsInfinite(AQ));
  if not Result then
    Exit;
  ADeltaQ := Abs(AQ) * AErrorPercent / 100;
  Result := (ADeltaQ > 0) and (not IsNan(ADeltaQ)) and (not IsInfinite(ADeltaQ));
  if Result then
  begin
    AMinQ := AQ - ADeltaQ;
    AMaxQ := AQ + ADeltaQ;
  end;
end;

class function TMeasurementPointGrouping.CalculateMergedRange(ACurrentMinQ,
  ACurrentMaxQ, ACurrentDeltaQ, ANewMinQ, ANewMaxQ, ANewDeltaQ: Double;
  out ANewCommonMinQ, ANewCommonMaxQ, AIntersectionQ,
  AControlDeltaQ: Double): Boolean;
begin
  ANewCommonMinQ := Max(ACurrentMinQ, ANewMinQ);
  ANewCommonMaxQ := Min(ACurrentMaxQ, ANewMaxQ);
  AIntersectionQ := ANewCommonMaxQ - ANewCommonMinQ;
  AControlDeltaQ := Min(ACurrentDeltaQ, ANewDeltaQ);
  Result := (AIntersectionQ > FloatTolerance) and
    (AIntersectionQ + FloatTolerance >= AControlDeltaQ);
end;

class function TMeasurementPointGrouping.ArePointsEquivalent(AQ1, AError1, AQ2,
  AError2: Double): Boolean;
var
  MinQ1, MaxQ1, DeltaQ1: Double;
  MinQ2, MaxQ2, DeltaQ2: Double;
  CommonMinQ, CommonMaxQ, IntersectionQ, ControlDeltaQ: Double;
begin
  Result := CalculatePointRange(AQ1, AError1, MinQ1, MaxQ1, DeltaQ1) and
    CalculatePointRange(AQ2, AError2, MinQ2, MaxQ2, DeltaQ2) and
    CalculateMergedRange(MinQ1, MaxQ1, DeltaQ1, MinQ2, MaxQ2, DeltaQ2,
      CommonMinQ, CommonMaxQ, IntersectionQ, ControlDeltaQ);
end;

end.
