unit FmxMedianFilter;


interface
uses
  System.SysUtils, System.Generics.Collections;
const
  cWindowSize=32;

type
  TFmxMedianFilter = class
  private
    WindowSize: Integer;
    Values: TQueue<Double>;
    FWindowSize: Integer;
    function GetMedian: Double;
    procedure SetWindowSize(const Value: Integer);
  public
    constructor Create(AWindowSize: Integer);
    function Filter(Value: Double): Double;
    property Size:Integer read WindowSize write SetWindowSize;
  end;

implementation

constructor TFmxMedianFilter.Create(AWindowSize: Integer);
begin
  if AWindowSize>0 then
    WindowSize := AWindowSize
  else
    WindowSize := cWindowSize;
  Values := TQueue<Double>.Create;
end;

function TFmxMedianFilter.GetMedian: Double;
var
  SortedValues: TArray<Double>;
  i: Integer;
begin
  SortedValues := Values.ToArray;
  TArray.Sort<Double>(SortedValues);
  if Values.Count>=WindowSize then
  begin
    if Odd(WindowSize) then
      Result := SortedValues[WindowSize div 2]
    else
      Result := (SortedValues[WindowSize div 2 - 1] + SortedValues[WindowSize div 2]) / 2;
  end
  else begin
    for I := 0 to Values.Count-1 do
        Result := Result + SortedValues[i];
    result:=Result/Values.Count;
  end;
end;


procedure TFmxMedianFilter.SetWindowSize(const Value: Integer);
begin
  if Value in [5..32] then
     WindowSize := Value
  else
     WindowSize := 10;
end;

function TFmxMedianFilter.Filter(Value: Double): Double;
begin
  Values.Enqueue(Value);
  if Values.Count > WindowSize then
    Values.Dequeue;

  Result := GetMedian;
end;

end.
