unit UnitMeterValue;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.IniFiles,
  System.IOUtils,
  System.Generics.Collections;

  const
  EPS = 1E-12;

type
  EUpdateType = (OFFLINE_TYPE, ONLINE_TYPE, HAND_TYPE);
  EValueType = (FLOW_TYPE, SUM_TYPE, CONST_TYPE,
                  ERROR_TYPE, MEAN_TYPE, AGGREGATE_TYPE);
  EDependenceType = (INDEPENDENT, DEPENDENT);

  TDimension = record
    Name: string;
    Hash: string;
    Rate: Double;
    Devider: Double;
    Factor: Boolean;
    Recip: Boolean;
  end;

  TCoef = record
    Name: string;
    Index: Integer;
    Hash: string;
    Value: Double;
    Arg: Double;
    Q1: Double;
    Q2: Double;
    K: Double;
    b: Double;
    InUse: Boolean;
  end;

  TCalibrPoint = record
    Value: Double;
    Arg: Double;
  end;



  TMeterValue = class
  private
    class var FMeterValues: TObjectList<TMeterValue>;
    class var FMeterValuesSaves: TObjectList<TMeterValue>;
    class var FFinalValue: Boolean;
    class var FInitDensity: Double;

  private
    FFilterOrder: Integer;
    FFilterRd: Integer;
    FFilterWr: Integer;
    FFilterCnt: Integer;
    FAverageOrder: Integer;
    FLastMean: Single;
    FShortMean: Single;
    FRawValue: Double;
    FFactor: Double;
    FDevider: Double;
    FAggregateMeterValues: TObjectList<TMeterValue>;
    function FindDimIndex(const AName: string): Integer;
    class constructor CreateClass;
    class destructor DestroyClass;

  public
    ValueWoCorrection: Double;
    TempDelta: Integer;
    Short_Mean_index: Integer;
    Hash: string;
    HashOwner: string;
    NameOwner: string;
    IsToSave: Boolean;
    Value: Double;
    Mean: Double;
    MeanCnt: Integer;
    Means: TList<Double>;

    Dimensions: TList<TDimension>;

    ValueType: EValueType;

    DependenceType: EDependenceType;
    UpdateType: EUpdateType;


    ValueRate: TMeterValue;
    ValueBaseMultiplier: TMeterValue;
    ValueBaseDevider: TMeterValue;
    ValueCorrection: TMeterValue;
    ValueEtalon: TMeterValue;


    HashValueRate: string;
    HashValueBaseMultiplier: string;
    HashValueBaseDevider: string;
    HashValueCorrection: string;
    HashValueEtalon: string;

    CurrentDimIndex: Integer;
    CurrentDim: TDimension;
    FilterShortOrder: Integer;
    FilterShortDelta: Single;

    Name: string;
    ShrtName: string;
    Description: string;
    &Type: string;
    RawValueName: string;
    RawValueDim: string;

    Accuracy: Integer;

    Error: Double;

    ARRAY_SIZE: Integer;

    CoefK: Double;
    CoefP: Double;

    MaxValue: Double;
    MinValue: Double;
    MaxNomValue: Double;
    MinNomValue: Double;

    RawValues: TList<Double>;
    Values: TList<Double>;
    AverValues: TList<Single>;
    Coef: TCoef;
    Coefs: TList<TCoef>;

    IsBind : Boolean;

    constructor Create; overload;
    constructor Create(const AHashOwner: string; const ANameOwner: string); overload;
    constructor Create(ACopyFrom: TMeterValue); overload;
    constructor CreateFromHash(const AHash: string);
    destructor Destroy; override;

    procedure SetCopy(AMeterValue: TMeterValue);
    class function GetNewMeterValue(const AHash: string): TMeterValue; static;
    class function GetNewMeterValueBool(const AHash: string; out IsExisted: Integer; const AHashOwner: string; const AName: string): TMeterValue; static;
    class function GetCopyMeterValueBool(var AHash: string; out IsExisted: Integer): TMeterValue; static;
    class function GetExistedMeterValueBool(var AHash: string; out IsExisted: Integer; const AHashOwner: string; const AName: string): TMeterValue; static;
    class function GetMeterValue(const AHash: string): TMeterValue; overload; static;
    class function GetMeterValue(const AHash, AHashOwner: string; const AName: string): TMeterValue; overload; static;

    procedure Random;

    function GetFloatValue: Single; overload;
    function GetFloatValue(Dim: Byte): Single; overload;
    function GetFloatValue(const ADim: string): Single; overload;

    function FilterApply: Double;
    function AverageApply: Single;

    function GetDoubleValue: Double; overload;
    function GetDoubleValue(const ADim: string): Double; overload;
    function GetDoubleValue(Dim: Byte): Double; overload;
    function GetDoubleValueDim: Double;
    function GetDoubleMeanValue(const DimName: string): Double; overload;
    function GetDoubleMeanValue(dim: Byte): Double; overload;
    function GetDoubleMeanValue: Double; overload;
    function GetDoubleVariation: Double;
    function GetDoubleStdDeviationPercent: Double;
    function IsStable(lim: Integer): Boolean;
    function GetStringValue: string; overload;
    function GetStringValue(Dim: Byte): string; overload;
    function GetStringValue(const ADim: string): string; overload;
    function GetStringMeanValue(Dim: Byte): string; overload;
    function GetStringMeanValue: string; overload;
    function GetStringVariation: string;
    function GetStringStdDeviationPercent: string;
    function GetStrStdDeviationPercent: string;
    function GetStrValue: string;
    function GetStringNum(AValue: Double): string;
    function GetStrNumLimits(AValue: Double): string;
    function GetStrNum(AValue: Double): string; overload;
    function GetStrNum(const AStrValue, ADim: string): string; overload;
    function GetStrNum(const AStrValue: string): string; overload;
    function GetStrNum(AValue: Double; const ADim: string): string; overload;

    procedure SetFilter(AOrder: Integer);
    function GetFilter: Integer;

    procedure SetRawValue(InputValue: Double); overload;
    procedure SetRawValue(InputValue: Double; Q: Single); overload;
    procedure SetMainValue(InputValue: Double; Q: Single); overload;
    procedure SetMainValue(InputValue: Double); overload;
    procedure SetValue; overload;
    procedure SetValue(AValue: Single); overload;
    procedure SetValue(AValue: Double); overload;
    procedure SetValue(AValue: Double; Dim: Byte); overload;
    procedure SetValue(AValue: Double; const ADimensions: string); overload;
    procedure SetAddValue(InputValue: Double);
    procedure SetDimValue(AValue: Double); overload;
    procedure SetDimValue(const AStr: string); overload;
    procedure SetValue(const AValue: string); overload;

    function Rate(Q: Double): Double;
    function UpdateCoefs(CalibrPoints: TArray<TCalibrPoint>): Int8;
    procedure SetValueCurrnet(AValue: Double);

    procedure SetDimension(const ADimensions: string; DimRate: Double); overload;
    procedure SetDimension(const AName: string; ARate, ADevider: Double; ARecip: Boolean); overload;
    function GetDimRate(const AName: string): Double; overload;
    function GetDimRate(Dim: Integer): Double; overload;
    function GetDimName: string; overload;
    function GetDimName(Dim: Integer): string; overload;
    function GetDim(const AName: string; out Dim: TDimension): Boolean; overload;
    function GetDim(const AName: string): Integer; overload;
    function GetDim(index: Integer; out Dim: TDimension): Boolean; overload;
    function GetDim: Integer; overload;
    function SetDim(Dim: Integer): Boolean; overload;
    function SetDim(const ADimName: string): Boolean; overload;
    function NextDim: Boolean;
    function GetStrFullName: string;
    function GetDoubleNum(const AStr: string): Double; overload;
    function GetDoubleNum(AValue: Double; const ADim: string): Double; overload;
    function GetDoubleNum(const AStr: string; Dim: Integer): Double; overload;
    procedure Reset; overload;
    procedure Reset(AValue: Double); overload;

    procedure SetAs(AMeterValue: TMeterValue);

    procedure SetAsTime;
    procedure SetAsVolume;
    procedure SetAsMass;
    procedure SetAsVolumeFlow;
    procedure SetAsMassFlow;
    procedure SetAsImp;
    procedure SetAsError;
    procedure SetAsMassError;
    procedure SetAsVolumeError;
    procedure SetAsDensity;
    procedure SetAsTempPT100;
    procedure SetAsTemp;
    procedure SetAsAirTemp;
    procedure SetAsPressure;
    procedure SetAsCurrent;
    procedure SetAsAirPressure;
    procedure SetAsMassCoef;
    procedure SetAsVolumeCoef;
    procedure SetAsHumidity;
    procedure SetCalcValue;

    function GetNewUUID: string;
    class procedure SaveToFile(IsBackUp: Integer); static;
    class procedure LoadFromFile; static;

    procedure SetCoef(ACoef: TCoef); overload;
    function SetCoef(AValue, AArg: Double): string; overload;
    function GetNewHashCoef: Integer;
    procedure CalcCoefs;
    procedure SetToSave(AIsToSave: Boolean);
    procedure DeleteFromVector;
    procedure AddMeterValue(AMeterValue: TMeterValue);
    procedure RemoveMeterValue(AMeterValue: TMeterValue);
    procedure ClearMeterValues;
    property MeterValues: TObjectList<TMeterValue> read FAggregateMeterValues;
    class function GetMeterValues: TObjectList<TMeterValue>; static;
    class procedure RebindReferences(const AOldValue, ANewValue: TMeterValue); static;
    class function GetInitDensity: Double; static;
    class procedure SetInitDensity(const AValue: Double); static;
  end;

implementation

uses
  UnitBaseProcedures;

{ Initializes class-level collections used to store all meter value instances. }
class constructor TMeterValue.CreateClass;
begin
  FMeterValues := TObjectList<TMeterValue>.Create(False);
  FMeterValuesSaves := TObjectList<TMeterValue>.Create(False);
  FInitDensity := 0.9982;
end;

{ Releases class-level collections allocated in the class constructor. }
class destructor TMeterValue.DestroyClass;
begin
  FMeterValues.Free;
  FMeterValuesSaves.Free;
end;

{ Creates a meter value object with default runtime fields and storage buffers. }
constructor TMeterValue.Create;
begin
  inherited Create;
  Hash := GetNewUUID;
  FFilterOrder := -1;
  FAverageOrder := 1;
  TempDelta := 3;
  Short_Mean_index := 3;
  Accuracy := 5;
  Error := 5;
  ARRAY_SIZE := 1000;
  CoefK := 1;
  CoefP := 0;
  MaxValue := MaxDouble;
  MinValue := -MaxDouble;
  MaxNomValue := MaxDouble;
  MinNomValue := -MaxDouble;
  Dimensions := TList<TDimension>.Create;
  Means := TList<Double>.Create;
  RawValues := TList<Double>.Create;
  Values := TList<Double>.Create;
  AverValues := TList<Single>.Create;
  Coefs := TList<TCoef>.Create;
  FAggregateMeterValues := TObjectList<TMeterValue>.Create(False);
  IsToSave := False;

  FMeterValues.Add(Self);


end;

{ Creates a meter value object with default runtime fields and storage buffers. }
constructor TMeterValue.Create(const AHashOwner: string; const ANameOwner: string);
begin
  Create;
  HashOwner := AHashOwner;
  NameOwner := ANameOwner;
end;

{ Creates a meter value object with default runtime fields and storage buffers. }
constructor TMeterValue.Create(ACopyFrom: TMeterValue);
begin
  Create;
  SetCopy(ACopyFrom);
end;

{ Creates a meter value object and binds it to the provided persistent hash. }
constructor TMeterValue.CreateFromHash(const AHash: string);
var
  MV: TMeterValue;
begin
  Create;
  MV := GetMeterValue(AHash);
  if MV <> nil then
    SetCopy(MV);
end;

{ Frees owned collections and unregisters this instance from global lists. }
destructor TMeterValue.Destroy;
begin
  Coefs.Free;
  AverValues.Free;
  Values.Free;
  RawValues.Free;
  Means.Free;
  Dimensions.Free;
  FAggregateMeterValues.Free;
  inherited;
end;

{ Copies core configuration and calibration settings from another meter value object. }
procedure TMeterValue.SetCopy(AMeterValue: TMeterValue);
var
  D: TDimension;
  C: TCoef;
begin
  if AMeterValue = nil then
    Exit;
  Name := AMeterValue.Name;
  ShrtName := AMeterValue.ShrtName;
  Description := AMeterValue.Description;
  ValueType := AMeterValue.ValueType;
  DependenceType := AMeterValue.DependenceType;
  UpdateType := AMeterValue.UpdateType;
  Accuracy := AMeterValue.Accuracy;
  Error := AMeterValue.Error;
  MaxValue := AMeterValue.MaxValue;
  MinValue := AMeterValue.MinValue;
  CurrentDimIndex := AMeterValue.CurrentDimIndex;
  Dimensions.Clear;
  for D in AMeterValue.Dimensions do Dimensions.Add(D);
  Coefs.Clear;
  for C in AMeterValue.Coefs do Coefs.Add(C);
end;

{ Finds an existing meter value by hash (and optional owner context). }
class function TMeterValue.GetMeterValue(const AHash: string): TMeterValue;
var
  MV: TMeterValue;
begin
  Result := nil;
  if AHash.IsEmpty then Exit;
  for MV in FMeterValues do
    if MV.Hash = AHash then
      Exit(MV);
end;

{ Finds an existing meter value by hash (and optional owner context). }
class function TMeterValue.GetMeterValue(const AHash, AHashOwner: string; const AName: string): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result = nil then
    Result := TMeterValue.Create(AHashOwner, AName);
end;

{ Returns an existing meter value for hash or creates and registers a new one. }
class function TMeterValue.GetNewMeterValue(const AHash: string): TMeterValue;
var
  MV: TMeterValue;
begin
  if AHash.IsEmpty then Exit(nil);
  MV := GetMeterValue(AHash);
  if MV <> nil then Exit(TMeterValue.Create(MV));
  Result := TMeterValue.Create;
end;

{ Gets or creates a meter value and reports whether it already existed. }
class function TMeterValue.GetNewMeterValueBool(const AHash: string; out IsExisted: Integer; const AHashOwner: string; const AName: string): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result <> nil then
  begin
    IsExisted := 1;
    Result := TMeterValue.Create(Result);
  end
  else
  begin
    IsExisted := 0;
    Result := TMeterValue.Create(AHashOwner, AName);
  end;
end;

{ Creates a cloned meter value from hash and reports whether source existed. }
class function TMeterValue.GetCopyMeterValueBool(var AHash: string; out IsExisted: Integer): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result <> nil then
  begin
    IsExisted := 1;
    Result := TMeterValue.Create(Result);
    AHash := Result.Hash;
  end
  else
  begin
    IsExisted := 0;
    Result := TMeterValue.Create;
    AHash := Result.Hash;
  end;
end;

{ Gets an existing meter value by hash; creates one only if missing. }
class function TMeterValue.GetExistedMeterValueBool(var AHash: string; out IsExisted: Integer; const AHashOwner: string; const AName: string): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result <> nil then
  begin
    IsExisted := 1;
    if Result.HashOwner.IsEmpty then
    begin
      Result.HashOwner := AHashOwner;
      Result.NameOwner := AName;
    end;
  end
  else
  begin
    IsExisted := 0;

    Result := TMeterValue.Create(AHashOwner, AName);
    AHash := Result.Hash;
  end;

    Result.IsBind := True;

end;

{ Assigns a random test value in the expected operating range. }
procedure TMeterValue.Random;
begin
  SetValue(System.Math.RandomRange(0, 1000) / 10);
end;

{ Applies configured digital filter to current samples and returns filtered value. }
function TMeterValue.FilterApply: Double;
var
  Flt: Double;
  Val: Double;
  Limit: Double;
  MeanLocal: Double;
  Delta: Integer;
  I: Integer;
  Nulls: Boolean;
begin
  MeanLocal := 0;
  Flt := Value;

  if FFilterOrder > 0 then
  begin
    if Values.Count > FFilterOrder then
      Delta := FFilterOrder
    else
    begin
      Delta := Values.Count;
      if TempDelta > Delta then
        TempDelta := Delta;
    end;

    if TempDelta < FFilterOrder then
    begin
      if TempDelta < Delta then
      begin
        Delta := TempDelta;
        Inc(TempDelta);
      end;
    end;

    Nulls := False;

    for I := 0 to Delta - 1 do
    begin
      Val := Values[I];
      MeanLocal := MeanLocal + Val;

      if Val = 0 then
        Nulls := True;

      if I = FilterShortOrder - 1 then
      begin
        if FilterShortOrder > 0 then
          FShortMean := MeanLocal / FilterShortOrder
        else
          FShortMean := 0;

        if (FLastMean <> 0) and (not Nulls) then
        begin
          Limit := (FShortMean * Error) / 100;
          if Abs(FLastMean - FShortMean) > Limit then
          begin
            Delta := FilterShortOrder;
            TempDelta := FilterShortOrder;
          end;
        end;
      end;
    end;

    if Delta > 0 then
      Mean := MeanLocal / Delta
    else
      Mean := Value;

    FLastMean := Mean;
    Flt := Mean;
  end
  else
  begin
    Mean := Flt;
    Flt := Value;
  end;

  AverValues.Insert(0, Mean);
  if AverValues.Count > ARRAY_SIZE then
    AverValues.Delete(AverValues.Count - 1);

  Result := Flt;
end;

{ Calculates short-term averaged value from the latest measurement history. }
function TMeterValue.AverageApply: Single;
begin
  Result := FShortMean;
end;

{ Returns current value as Single in the default/base dimension. }
function TMeterValue.GetFloatValue: Single;
begin
  Result := GetDoubleValue;
end;

{ Returns current value converted to single-precision (and optional dimension). }
function TMeterValue.GetFloatValue(Dim: Byte): Single;
begin
  Result := GetDoubleValue(Dim);
end;

{ Returns current value converted to single-precision (and optional dimension). }
function TMeterValue.GetFloatValue(const ADim: string): Single;
begin
  Result := GetDoubleValue(ADim);
end;

{ Returns current value in base dimension Zero analyse. }
function TMeterValue.GetDoubleValue: Double;
var
  AbsError: Double;
begin
  if ValueType = AGGREGATE_TYPE then
    SetValue;

//  if (Error <> 0) and (MinNomValue<>0) then
//  begin
//    AbsError := Abs(MinNomValue) * Error / 100;
//
//    if Abs(Value) < AbsError / 1000 then
//      Result := 0
//    else
//      Result := Value;
//  end
//  else
    Result := Value;
end;

{ Returns current value in base units or converted to the requested dimension. }
function TMeterValue.GetDoubleValue(Dim: Byte): Double;
var
  D: TDimension;
begin
  Result := 0;

  if not GetDim(Dim, D) then
    Exit;

  if D.Recip then
  begin
    if GetDoubleValue = 0 then
      Exit;
    Result := D.Rate / GetDoubleValue;
  end
  else
    Result := D.Rate * GetDoubleValue;

  if (D.Devider <> 0) and (D.Devider <> 1) then
    Result := Result / D.Devider;
end;

{ Returns current value in base units or converted to the requested dimension. }
function TMeterValue.GetDoubleValue(const ADim: string): Double;
begin
  Result := Value * GetDimRate(ADim);
end;

{ Returns current value converted to the currently selected dimension. }
function TMeterValue.GetDoubleValueDim: Double;
begin
  Result := GetDoubleValue(CurrentDimIndex);
end;

{ Returns accumulated mean in base units; falls back to current value if empty. }
function TMeterValue.GetDoubleMeanValue: Double;
begin
  if Means.Count = 0 then Exit(Value);
  Result := Mean;
end;

{ Returns mean value in base units or converted to a requested dimension. }
function TMeterValue.GetDoubleMeanValue(dim: Byte): Double;
begin
  Result := GetDoubleMeanValue * GetDimRate(dim);
end;

{ Returns mean value in base units or converted to a requested dimension. }
function TMeterValue.GetDoubleMeanValue(const DimName: string): Double;
begin
  Result := GetDoubleMeanValue * GetDimRate(DimName);
end;

{ Returns variation (max - min) in absolute units over Values history. }
function TMeterValue.GetDoubleVariation: Double;
var
  MinHistory: Double;
  MaxHistory: Double;
  ItemValue: Double;
begin
  if Values.Count = 0 then
    Exit(0);

  MinHistory := Values[0];
  MaxHistory := Values[0];

  for ItemValue in Values do
  begin
    if ItemValue < MinHistory then
      MinHistory := ItemValue;
    if ItemValue > MaxHistory then
      MaxHistory := ItemValue;
  end;

  Result := MaxHistory - MinHistory;
end;

{ Returns standard deviation in percent relative to mean over Values history. }
function TMeterValue.GetDoubleStdDeviationPercent: Double;
var
  MeanHistory: Double;
  SumSquares: Double;
  ItemValue: Double;
  Delta: Double;
begin
  if Values.Count = 0 then
    Exit(0);

  MeanHistory := 0;
  for ItemValue in Values do
    MeanHistory := MeanHistory + ItemValue;
  MeanHistory := MeanHistory / Values.Count;

  if SameValue(MeanHistory, 0, 1E-12) then
    Exit(0);

  SumSquares := 0;
  for ItemValue in Values do
  begin
    Delta := ItemValue - MeanHistory;
    SumSquares := SumSquares + Sqr(Delta);
  end;

  Result := Sqrt(SumSquares / Values.Count) / Abs(MeanHistory) * 100;
end;

{ Checks whether current value deviation from last mean is within the limit. }
function TMeterValue.IsStable(lim: Integer): Boolean;
begin
  Result := Abs(Value - FLastMean) <= lim;
end;

{ Returns formatted string value in the default display dimension. }
function TMeterValue.GetStringValue: string;
begin
  Result := GetStringValue(0);
end;

{ Formats current numeric value to string in default or requested dimension. }
function TMeterValue.GetStringValue(Dim: Byte): string;
var
  Dbl: Double;
begin

  Dbl := GetDoubleValue(Dim);

if Abs(Value) < EPS then
  Exit('0');

  if Value <= MinValue then
    Exit('-');



  if (Value >= MaxValue) and (MaxValue<>0) then
    Exit('+NAN');

  Result := FormatValue(Dbl, Accuracy, Error);
end;

{ Formats current numeric value to string in default or requested dimension. }
function TMeterValue.GetStringValue(const ADim: string): string;
begin
  Result := GetStringValue(GetDim(ADim));
end;

{ Formats mean numeric value to string in default or requested dimension. }
function TMeterValue.GetStringMeanValue(Dim: Byte): string;
var
  Dbl: Double;
begin
  Dbl := GetDoubleMeanValue(Dim);

  if Value < MinValue then
    Exit('-');

  if Value > MaxValue then
    Exit('+NAN');

  Result := FormatValue(Dbl, Accuracy, Error);
end;

{ Returns formatted mean value in the default display dimension. }
function TMeterValue.GetStringMeanValue: string;
begin
  Result := GetStringMeanValue(0);
end;

{ Returns formatted variation string in absolute units. }
function TMeterValue.GetStringVariation: string;
begin
  Result := FormatValue(GetDoubleVariation, -1, 1);
end;

{ Returns formatted standard deviation string in percent. }
function TMeterValue.GetStringStdDeviationPercent: string;
begin
  Result := FormatValue(GetDoubleStdDeviationPercent, -1, 10) + ' %';
end;

function TMeterValue.GetStrStdDeviationPercent: string;
begin
  Result := FormatValue(GetDoubleStdDeviationPercent, -1, 10);
end;

{ Returns formatted value using CurrentDimIndex as active display dimension. }
function TMeterValue.GetStrValue: string;
begin
  Result := GetStringValue(CurrentDimIndex);
end;

{ C++ parity for GetStringNum(double):
  temporarily substitutes internal Value by AValue, formats via GetStringValue(),
  then restores previous Value. This keeps method side-effect free for callers. }
function TMeterValue.GetStringNum(AValue: Double): string;
var
  TempValue: Double;
begin
  TempValue := Value;
  Value := AValue;
  try
    Result := GetStringValue;
  finally
    Value := TempValue;
  end;
end;

{ C++ parity for GetStrNumLimits(double):
  formats AValue exactly in CurrentDimIndex representation (with dimension/limits
  logic inside GetStringValue(CurrentDimIndex)) and restores object state after call. }
function TMeterValue.GetStrNumLimits(AValue: Double): string;
var
  TempValue: Double;
begin
  TempValue := Value;
  Value := AValue;
  try
    Result := GetStringValue(CurrentDimIndex);
  finally
    Value := TempValue;
  end;
end;

{ C++ parity for GetStrNum(double):
  converts AValue into CurrentDimIndex numeric view and formats it by Accuracy/Error,
  without persisting any temporary Value change. }
function TMeterValue.GetStrNum(AValue: Double): string;
var
  TempValue: Double;
  DisplayValue: Double;
begin
  TempValue := Value;
  Value := AValue;
  try
    DisplayValue := GetDoubleValue(CurrentDimIndex);
    Result := FormatValue(DisplayValue, Accuracy, Error);
  finally
    Value := TempValue;
  end;
end;

{ C++ parity for GetStrNum(UnicodeString strvalue, UnicodeString Dim):
  parses textual input into numeric value (invalid text -> 0), assigns it directly
  to internal Value, returns formatted representation in requested dimension ADim,
  and restores previous Value on exit. }
function TMeterValue.GetStrNum(const AStrValue, ADim: string): string;
var
  TempValue: Double;
  ParsedValue: Double;
begin
  TempValue := Value;
  ParsedValue := StrToFloatDef(StringReplace(Trim(AStrValue), ',', '.', [rfReplaceAll]), 0, TFormatSettings.Invariant);
  Value := ParsedValue;
  try
    Result := GetStringValue(ADim);
  finally
    Value := TempValue;
  end;
end;

{ C++ parity for GetStrNum(UnicodeString strvalue):
  parses text, places it into temporary Value, then delegates formatting to
  GetStringValue() using current/default display dimension rules. }
function TMeterValue.GetStrNum(const AStrValue: string): string;
var
  TempValue: Double;
  ParsedValue: Double;
begin
  TempValue := Value;
  ParsedValue := StrToFloatDef(StringReplace(Trim(AStrValue), ',', '.', [rfReplaceAll]), 0, TFormatSettings.Invariant);
  Value := ParsedValue;
  try
    Result := GetStringValue;
  finally
    Value := TempValue;
  end;
end;

{ C++ parity for GetStrNum(double value, UnicodeString Dim):
  assigns numeric input directly to Value and returns string in requested ADim,
  then restores previous Value so conversion helper has no observable side effects. }
function TMeterValue.GetStrNum(AValue: Double; const ADim: string): string;
var
  TempValue: Double;
begin
  TempValue := Value;
  Value := AValue;
  try
    Result := GetStringValue(ADim);
  finally
    Value := TempValue;
  end;
end;

{ Parses numeric input and converts it into base or requested dimension units. }
function TMeterValue.GetDoubleNum(AValue: Double; const ADim: string): Double;
var
  Temp: Double;
  FO: Integer;
begin
  Temp := Value;
  Value := AValue;
  FO := FFilterOrder;
  FFilterOrder := -1;
  try
    Result := GetDoubleValue(ADim);
  finally
    Value := Temp;
    FFilterOrder := FO;
  end;
end;

{ Sets filter order used by runtime smoothing logic. }
procedure TMeterValue.SetFilter(AOrder: Integer);
begin
  FFilterOrder := AOrder;
end;

{ Returns current filter order used for runtime signal smoothing. }
function TMeterValue.GetFilter: Integer;
begin
  Result := FFilterOrder;
end;

{ Stores raw sensor input and propagates it through standard value pipeline. }
procedure TMeterValue.SetRawValue(InputValue: Double);
var
  ValueLocal: Double;
  RateLocal: Double;
  ResultLocal: Double;
begin
  RawValues.Insert(0, FRawValue);
  if RawValues.Count > ARRAY_SIZE then
    RawValues.Delete(RawValues.Count - 1);

  FRawValue := InputValue;

  if UpdateType <> HAND_TYPE then
  begin
    UpdateType := ONLINE_TYPE;

    if Assigned(ValueRate) then
      ValueLocal := InputValue * ValueRate.GetDoubleValue
    else
      ValueLocal := InputValue;

    ValueLocal := ValueLocal * CoefK + CoefP;

    ValueWoCorrection := ValueLocal;

    RateLocal := Rate(ValueLocal);
    ResultLocal := RateLocal * ValueLocal;

    SetValue(ResultLocal);
  end;
end;

{ Stores raw sensor input and propagates it through standard value pipeline. }
procedure TMeterValue.SetRawValue(InputValue: Double; Q: Single);
var
  ValueLocal: Double;
begin
  if UpdateType <> HAND_TYPE then
  begin
    UpdateType := ONLINE_TYPE;
    if Assigned(ValueRate) then
      ValueLocal := InputValue * ValueRate.GetDoubleValue
    else
      ValueLocal := InputValue;

    ValueLocal := ValueLocal * CoefK + CoefP;
    ValueWoCorrection := ValueLocal;
    SetMainValue(ValueLocal, Q);
  end;
end;

{ Sets processed value directly (optionally with flow-dependent correction). }
procedure TMeterValue.SetMainValue(InputValue: Double);
var
  ValueLocal: Double;
begin
  if Coefs.Count > 0 then
    ValueLocal := InputValue * Rate(InputValue)
  else
    ValueLocal := InputValue;

  SetValue(ValueLocal);
end;

{ Sets processed value directly (optionally with flow-dependent correction). }
procedure TMeterValue.SetMainValue(InputValue: Double; Q: Single);
var
  ValueLocal: Double;
begin
  if Coefs.Count > 0 then
    ValueLocal := InputValue * Rate(Q)
  else
    ValueLocal := InputValue;

  SetValue(ValueLocal);
end;

{ Assigns value, applies range limits, and updates history/mean buffers. }
procedure TMeterValue.SetValue;
var
  ValueLocal: Double;
  Q: Single;
  MeterValue: TMeterValue;
begin
  ValueLocal := 0;

  if UpdateType <> HAND_TYPE then
  begin
    if SameText(Name, 'Плотность') then
    begin
      SetCalcValue;
      Exit;
    end;

    if ValueType = AGGREGATE_TYPE then
    begin
      for MeterValue in FAggregateMeterValues do
      begin
        if (MeterValue = nil) or (MeterValue = Self) then
          Continue;
        ValueLocal := ValueLocal + MeterValue.GetDoubleValue;
      end;
      SetValue(ValueLocal);
      Exit;
    end;

    if ValueEtalon <> nil then
    begin
      if ValueType = ERROR_TYPE then
      begin
        if ValueBaseMultiplier <> nil then
          ValueLocal := ValueBaseMultiplier.Value - ValueEtalon.Value
        else
          ValueLocal := -ValueEtalon.Value;

        if ValueEtalon.Value <> 0 then
        begin
          ValueLocal := ValueLocal * 100;
          ValueLocal := ValueLocal / ValueEtalon.Value;
        end
        else
          ValueLocal := -MaxDouble;

        SetValue(ValueLocal);
      end
      else
        ValueLocal := 0;
    end
    else if (ValueBaseMultiplier <> nil) or (ValueBaseDevider <> nil) then
    begin
      if ValueType = MEAN_TYPE then
      begin
        if ValueBaseMultiplier <> nil then
          ValueLocal := ValueBaseMultiplier.Value
        else
          ValueLocal := 0;

        if ValueBaseDevider <> nil then
          ValueLocal := (ValueLocal + ValueBaseDevider.Value) / 2;
      end
      else
      begin
        if ValueBaseMultiplier <> nil then
          ValueLocal := ValueBaseMultiplier.Value
        else
          ValueLocal := 1;

        if ValueRate <> nil then
          ValueLocal := ValueLocal * ValueRate.Value;

        if ValueBaseDevider <> nil then
          ValueLocal := ValueLocal / ValueBaseDevider.Value;
      end;

      ValueWoCorrection := ValueLocal;

      if ValueCorrection <> nil then
      begin
        Q := ValueCorrection.Value;
        if Coefs.Count > 0 then
          ValueLocal := ValueLocal * Rate(Q);
      end
      else if Coefs.Count > 0 then
        ValueLocal := ValueLocal * Rate(ValueLocal);

      SetValue(ValueLocal);
    end;
  end;
end;

{ Adds a meter value to the aggregate source list (if not already present). }
procedure TMeterValue.AddMeterValue(AMeterValue: TMeterValue);
begin
  if (AMeterValue = nil) or (AMeterValue = Self) then
    Exit;
  if FAggregateMeterValues.IndexOf(AMeterValue) < 0 then
    FAggregateMeterValues.Add(AMeterValue);
end;

{ Removes a meter value from the aggregate source list. }
procedure TMeterValue.RemoveMeterValue(AMeterValue: TMeterValue);
begin
  if AMeterValue = nil then
    Exit;
  FAggregateMeterValues.Remove(AMeterValue);
end;

{ Clears all aggregate source meter values. }
procedure TMeterValue.ClearMeterValues;
begin
  FAggregateMeterValues.Clear;
end;

{ Assigns value, applies range limits, and updates history/mean buffers. }
procedure TMeterValue.SetValue(AValue: Single);
begin
  SetValue(Double(AValue));
end;

{ Assigns value, applies range limits, and updates history/mean buffers. }
procedure TMeterValue.SetValue(AValue: Double);
var
  InputValue: Double;
begin
  //InputValue := EnsureRange(AValue, MinValue, MaxValue);
  InputValue :=   AValue;


  if ARRAY_SIZE > 0 then
  begin
    Values.Insert(0, InputValue);
    if Values.Count > ARRAY_SIZE then
      Values.Delete(Values.Count - 1);

    if (FFilterOrder <> -1) and (not FFinalValue) then
      Value := FilterApply
    else
      Value := InputValue;
  end
  else
    Value := InputValue;
end;

{ Assigns value, applies range limits, and updates history/mean buffers. }
procedure TMeterValue.SetValue(AValue: Double; Dim: Byte);
begin
  SetValue(AValue / GetDimRate(Dim));
end;

{ Assigns value, applies range limits, and updates history/mean buffers. }
procedure TMeterValue.SetValue(AValue: Double; const ADimensions: string);
begin
  SetValue(AValue / GetDimRate(ADimensions));
end;

{ Adds increment to current value via standard SetValue pipeline. }
procedure TMeterValue.SetAddValue(InputValue: Double);
begin
  SetValue(Value + InputValue);
end;

{ Sets value expressed in current dimension (number or string input). }
procedure TMeterValue.SetDimValue(AValue: Double);
begin
  SetValue(AValue, CurrentDimIndex);
end;

{ Sets value expressed in current dimension (number or string input). }
procedure TMeterValue.SetDimValue(const AStr: string);
var
  ParsedValue: Double;
begin
  ParsedValue := StrToFloatDef(StringReplace(Trim(AStr), ',', '.', [rfReplaceAll]), 0, TFormatSettings.Invariant);
  SetDimValue(ParsedValue);
end;

{ Assigns value, applies range limits, and updates history/mean buffers. }
procedure TMeterValue.SetValue(const AValue: string);
begin
  SetValue(GetDoubleNum(AValue));
end;

{ Configures this meter value as time with predefined units and limits. }
procedure TMeterValue.SetAs(AMeterValue: TMeterValue);
var
  D: TDimension;
begin
  if (AMeterValue = nil) or (AMeterValue = Self) then
    Exit;

  ValueType := AMeterValue.ValueType;
  DependenceType := AMeterValue.DependenceType;
  UpdateType := AMeterValue.UpdateType;

  Name := AMeterValue.Name;
  ShrtName := AMeterValue.ShrtName;
  Description := AMeterValue.Description;
  &Type := AMeterValue.&Type;
  RawValueName := AMeterValue.RawValueName;
  RawValueDim := AMeterValue.RawValueDim;

  SetFilter(AMeterValue.GetFilter);
  FilterShortOrder := AMeterValue.FilterShortOrder;
  FilterShortDelta := AMeterValue.FilterShortDelta;

  Accuracy := AMeterValue.Accuracy;
  Error := AMeterValue.Error;
  MaxValue := AMeterValue.MaxValue;
  MinValue := AMeterValue.MinValue;
  MaxNomValue := AMeterValue.MaxNomValue;
  MinNomValue := AMeterValue.MinNomValue;

  CoefK := AMeterValue.CoefK;
  CoefP := AMeterValue.CoefP;

  Dimensions.Clear;
  for D in AMeterValue.Dimensions do
    Dimensions.Add(D);

  if not SetDim(AMeterValue.CurrentDimIndex) and (Dimensions.Count > 0) then
    SetDim(0);
end;

{ Configures this meter value as time with predefined units and limits. }
procedure TMeterValue.SetAsTime;
begin
  ValueType := CONST_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 0;
  Error := 0.001;
  Name := 'Время';
  ShrtName := 'T';
  Dimensions.Clear;
  SetDimension('сек', 1);
  SetDimension('мин', 1, 60, False);
  SetDimension('ч', 1, 3600, False);
  SetDim(0);
  SetValue(0.0);
  MaxValue := 99999999;
  MinValue := 0;
  MaxNomValue := 3600;
  MinNomValue := 0;
end;

{ Calculates linear correction coefficient by flow argument Q. }
function TMeterValue.Rate(Q: Double): Double;
var
  I: Integer;
  K: Double;
  B: Double;
  Qetl: Double;
begin
  if Q = 0 then
    Exit(1);

  if Coefs.Count > 0 then
  begin
    Qetl := 0;
    K := 0;
    B := 0;

    for I := 0 to Coefs.Count - 1 do
    begin
      K := Coefs[I].K;
      B := Coefs[I].b;

      if (Q >= Coefs[I].Q1) and (Q < Coefs[I].Q2) then
      begin
        Qetl := K * Q + B;
        Exit(Qetl / Q);
      end;
    end;

    if Qetl = 0 then
    begin
      Qetl := K * Q + B;
      Exit(Qetl / Q);
    end;
  end;

  Result := 1;
end;

{ Replaces calibration table and recalculates interpolation coefficients. }
function TMeterValue.UpdateCoefs(CalibrPoints: TArray<TCalibrPoint>): Int8;
var
  P: TCalibrPoint;
begin
  Coefs.Clear;
  for P in CalibrPoints do
    SetCoef(P.Value, P.Arg);
  CalcCoefs;
  Result := 0;
end;

{ Compatibility wrapper that assigns current value through SetValue. }
procedure TMeterValue.SetValueCurrnet(AValue: Double);
begin
  SetValue(AValue);
end;

{ Finds dimension index by name; returns -1 when dimension is absent. }
function TMeterValue.FindDimIndex(const AName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Dimensions.Count - 1 do
    if SameText(Dimensions[I].Name, AName) then
      Exit(I);
  Result := -1;
end;

{ Adds a new dimension with conversion parameters and metadata. }
procedure TMeterValue.SetDimension(const ADimensions: string; DimRate: Double);
begin
  SetDimension(ADimensions, DimRate, 1, False);
end;

{ Adds a new dimension with conversion parameters and metadata. }
procedure TMeterValue.SetDimension(const AName: string; ARate, ADevider: Double; ARecip: Boolean);
var
  D: TDimension;
begin
  D.Name := AName;
  D.Hash := GetNewUUID;
  D.Rate := ARate;
  D.Devider := ADevider;
  D.Recip := ARecip;
  D.Factor := False;
  Dimensions.Add(D);
  if Dimensions.Count = 1 then
    CurrentDimIndex := 0;
end;

{ Returns conversion factor for dimension name or index. }
function TMeterValue.GetDimRate(const AName: string): Double;
var
  I: Integer;
begin
  I := FindDimIndex(AName);
  if I < 0 then Exit(1);
  Result := GetDimRate(I);
end;

{ Returns conversion factor for dimension name or index. }
function TMeterValue.GetDimRate(Dim: Integer): Double;
var
  D: TDimension;
begin
  if (Dim < 0) or (Dim >= Dimensions.Count) then Exit(1);
  D := Dimensions[Dim];
  if D.Recip then
    Result := D.Devider / D.Rate
  else
    Result := D.Rate / D.Devider;
end;

{ Returns dimension name for the currently selected dimension index. }
function TMeterValue.GetDimName: string;
begin
  Result := GetDimName(CurrentDimIndex);
end;

{ Returns dimension name for current or specified index. }
function TMeterValue.GetDimName(Dim: Integer): string;
begin
  if (Dim >= 0) and (Dim < Dimensions.Count) then
    Result := Dimensions[Dim].Name
  else
    Result := '';
end;

{ Returns dimension index/details or current dimension index overload. }
function TMeterValue.GetDim(const AName: string; out Dim: TDimension): Boolean;
var
  I: Integer;
begin
  I := FindDimIndex(AName);
  Result := I >= 0;
  if Result then Dim := Dimensions[I];
end;

{ Returns dimension index/details or current dimension index overload. }
function TMeterValue.GetDim(const AName: string): Integer;
begin
  Result := FindDimIndex(AName);
end;

{ Returns dimension index/details or current dimension index overload. }
function TMeterValue.GetDim(index: Integer; out Dim: TDimension): Boolean;
begin
  Result := (index >= 0) and (index < Dimensions.Count);
  if Result then Dim := Dimensions[index];
end;

{ Returns the current active dimension index. }
function TMeterValue.GetDim: Integer;
begin
  Result := CurrentDimIndex;
end;

{ Selects active dimension index when it is valid. }
function TMeterValue.SetDim(Dim: Integer): Boolean;
begin
  Result := (Dim >= 0) and (Dim < Dimensions.Count);
  if Result then CurrentDimIndex := Dim;
end;

{ Selects active dimension by its display name (TDimension.Name). }
function TMeterValue.SetDim(const ADimName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Dimensions.Count - 1 do
    if SameText(Dimensions[I].Name, ADimName) then
    begin
      CurrentDimIndex := I;
      Exit(True);
    end;
end;

{ Switches active dimension to the next one and wraps at the end of list. }
function TMeterValue.NextDim: Boolean;
begin
  if Dimensions.Count = 0 then Exit(False);
  CurrentDimIndex := (CurrentDimIndex + 1) mod Dimensions.Count;
  Result := True;
end;

{ Returns full display caption including meter name and current dimension name. }
function TMeterValue.GetStrFullName: string;
begin
  Result := Name;
  if GetDimName <> '' then
    Result := Result + ', ' + GetDimName;
end;

{ Parses numeric input and converts it into base or requested dimension units. }
function TMeterValue.GetDoubleNum(const AStr: string): Double;
var
  TempValue: Double;
  TempFilterOrder: Integer;
begin
  { C++ parity:
    - preserve current Value;
    - temporarily disable runtime filtering (filter_order := -1), because conversion
      helper methods must return the "raw" converted number, not a filtered one;
    - assign parsed value as if it was entered in CurrentDimIndex units;
    - read back resulting base Value and restore object state. }
  TempValue := Value;
  TempFilterOrder := FFilterOrder;
  FFilterOrder := -1;
  try
    { Use invariant parser with decimal separator normalization.
      Invalid input becomes 0.0, matching prior Delphi behavior and C++ fallback logic
      from TryStrToDouble_ usage in related methods. }
    SetDimValue(AStr);
    Result := Value;
  finally
    Value := TempValue;
    FFilterOrder := TempFilterOrder;
  end;
end;

{ Parses numeric input and converts it into base or requested dimension units. }
function TMeterValue.GetDoubleNum(const AStr: string; Dim: Integer): Double;
var
  TempValue: Double;
begin
  { C++ parity for GetDoubleNum(str, int Dim):
    convert incoming string from CurrentDimIndex representation into the internal
    base value, then return that value converted to requested Dim. }
  TempValue := Value;
  try
    SetDimValue(AStr);
    Result := GetDoubleValue(Dim);
  finally
    Value := TempValue;
  end;
end;

{ Clears runtime accumulators and returns measurement state to initial defaults. }
procedure TMeterValue.Reset;
begin
  FFilterRd := 0;
  FFilterWr := 0;
  FFilterCnt := 0;
  FLastMean := 0;
  TempDelta := 0;

  Mean := 0;
  MeanCnt := 0;
  RawValues.Clear;
  Values.Clear;
  AverValues.Clear;
  Means.Clear;
end;

procedure TMeterValue.Reset(AValue: Double);
begin
  Reset;
  Value := AValue;
end;

{ Configures this meter value as volume with predefined units and limits. }
procedure TMeterValue.SetAsVolume;
begin
  ValueType := SUM_TYPE;
  Name := 'Объем';
  ShrtName := 'V';
  SetFilter(-1);
  Accuracy := 6;
  Value := 0;
  Dimensions.Clear;
  SetDimension('л', 1);
  SetDimension('м3', 1, 1000, False);
  SetDim(0);
  MaxValue := MaxDouble;
  MinValue := 0;
  Error := 0.01;
end;

{ Configures this meter value as mass with predefined units and limits. }
procedure TMeterValue.SetAsMass;
begin
  ValueType := SUM_TYPE;
  Name := 'Масса';
  ShrtName := 'M';
  SetFilter(-1);
  Accuracy := -1;
  Error := 0.1;
  Value := 0;
  Dimensions.Clear;
  SetDimension('кг', 1, 1, False);
  SetDimension('т', 1, 1000, False);
  SetDim(0);
  MaxValue := MaxDouble;
  MinValue := 0;
end;

{ Configures this meter value as volume flow with predefined units. }
procedure TMeterValue.SetAsVolumeFlow;
begin
  ValueType := FLOW_TYPE;
  Name := 'Объемный расход';
  ShrtName := 'Qv';
  SetFilter(-1);
  Accuracy := -1;
  Error := 0.1;
  Value := 0;
  MinValue := 0;
  MaxValue := MaxDouble;

  Dimensions.Clear;
  SetDimension('л/с', 1, 1, False);
  SetDimension('л/мин', 60, 1, False);
  SetDimension('л/ч', 3600, 1, False);
  SetDimension('м3/мин', 60, 1000, False);
  SetDimension('м3/ч', 3600, 1000, False);
  SetDim(4);

end;

{ Configures this meter value as mass flow with predefined units. }
procedure TMeterValue.SetAsMassFlow;
begin
  ValueType := FLOW_TYPE;
  Name := 'Массовый расход';
  ShrtName := 'Qm';
  SetFilter(-1);
  Accuracy := -1;
  Error := 0.1;
  MaxValue := MaxDouble;
  MinValue := 0;
  Value := 0;
  Dimensions.Clear;
  SetDimension('кг/с', 1, 1, False);
  SetDimension('кг/мин', 60, 1, False);
  SetDimension('кг/ч', 3600, 1, False);
  SetDimension('т/мин', 60, 1000, False);
  SetDimension('т/ч', 3600, 1000, False);
  SetDim(4);

end;

{ Configures this meter value as impulse counter with predefined limits. }
procedure TMeterValue.SetAsImp;
begin
  ValueType := FLOW_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 0;
  Error := 0.001;
  MaxValue := MaxDouble;
  MinValue := 0;

  Name := 'Импульсы';
  ShrtName := 'N';
  Dimensions.Clear;
  SetDimension('имп', 1, 1, False);
  SetDim(0);

  Reset;
end;

{ Configures this meter value as generic error percentage value. }
procedure TMeterValue.SetAsError;
begin
  ValueType := ERROR_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := -1;
  Error := 10;

  MaxValue := 999;
  MinValue := -999;
  MaxNomValue := 0.1;
  MinNomValue := -0.1;
  ShrtName := 'δ';

  Name := 'Погрешность';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);

end;

{ Configures this meter value as mass error percentage value. }
procedure TMeterValue.SetAsMassError;
begin
  ValueType := ERROR_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := -1;
  Error := 10;

  MaxValue := 999;
  MinValue := -999;
  MaxNomValue := 0.1;
  MinNomValue := -0.1;

  Name := 'Погрешность по массе';
  ShrtName := 'δm';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);

end;

{ Configures this meter value as volume error percentage value. }
procedure TMeterValue.SetAsVolumeError;
begin
  ValueType := ERROR_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := -1;
  Error := 10;

  MaxValue := 999;
  MinValue := -999;
  MaxNomValue := 0.1;
  MinNomValue := -0.1;

  Name := 'Погрешность по объему';
  ShrtName := 'δv';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);

end;

{ Configures this meter value as density with supported units. }
procedure TMeterValue.SetAsDensity;
begin
  ValueType := CONST_TYPE;
  Value := 998.1;
  SetFilter(-1);
  Accuracy := -1;
  Name := 'Плотность';
  ShrtName := 'ρ';
  Dimensions.Clear;
  SetDimension('кг/л', 1);
  SetDimension('кг/м3', 1000);
  SetDimension('т/л', 1, 1000, False);
  SetDimension('т/м3', 1);
  SetDim(0);
  MaxValue := 1.1100;
  MinValue := 0.900;
  MaxNomValue := 0.999;
  MinNomValue := 0.997;
  Error := 0.01;
  SetValue(FInitDensity);
end;

{ Configures this meter value as product temperature with supported units. }
procedure TMeterValue.SetAsTempPT100;
begin
  ValueType := CONST_TYPE;
  Value := 21.3;
  SetFilter(-1);
  Accuracy := 2;
  Name := 'Температура';
  &Type := 'PT100';
  RawValueName := 'Сопротивление';
  RawValueDim := 'Ом';
  ShrtName := 't';
  Dimensions.Clear;
  SetDimension('°C', 1);
  SetDimension('град. С', 1);
  SetDim(0);
  SetValue(20.0);
  MaxValue := 100;
  MinValue := 0;
  MaxNomValue := 25;
  MinNomValue := 15;
  Error := 0.5;
  SetValue(21.3);
end;


procedure TMeterValue.SetAsTemp;
begin
  ValueType := CONST_TYPE;
  Value := 21.3;
  SetFilter(-1);
  Accuracy := 2;
  Name := 'Температура';
  &Type := '';
  RawValueName := 'Температура';
  RawValueDim := '°C';
  ShrtName := 't';
  Dimensions.Clear;
  SetDimension('°C', 1);
  SetDimension('град. С', 1);
  SetDim(0);
  SetValue(20.0);
  MaxValue := 100;
  MinValue := 0;
  MaxNomValue := 25;
  MinNomValue := 15;
  Error := 0.5;
  SetValue(21.3);
end;

{ Configures this meter value as ambient temperature with supported units. }
procedure TMeterValue.SetAsAirTemp;
begin
  ValueType := CONST_TYPE;
  Value := 21.3;
  SetFilter(-1);
  Accuracy := 4;
  Name := 'Температура атм';
  &Type := 'ИВТМ';
  RawValueName := '';
  RawValueDim := '';
  ShrtName := 't';
  Dimensions.Clear;
  SetDimension('°C', 1);
  SetDimension('град. С', 1);
  SetDim(0);
  SetValue(20.0);
  MaxValue := 100;
  MinValue := 0;
  MaxNomValue := 25;
  MinNomValue := 15;
  Error := 0.5;
  SetValue(21.3);
end;

{ Configures this meter value as pressure with supported units and limits. }
procedure TMeterValue.SetAsPressure;
begin
  ValueType := CONST_TYPE;
  Value := 98;
  SetFilter(-1);
  Accuracy := 0;
  Name := 'Давление';
  &Type := 'Датчик';
  RawValueName := 'Ток';
  RawValueDim := 'мА';
  ShrtName := 'P';
  Dimensions.Clear;
  SetDimension('Па', 1);
  SetDimension('гПа', 1, 100, False);
  SetDimension('кПа', 1, 1000, False);
  SetDimension('bar', 1, 100000, False);
  SetDimension('МПа', 1, 1000000, False);
  SetDim(3);
  MaxValue := 1600000;
  MinValue := -10000;
  MaxNomValue := 100000;
  MinNomValue := 0;
  Error := 0.1;
  CoefK := 100000;
  CoefP := -400000;
  SetValue(98.0);
end;

{ Configures this meter value as atmospheric pressure with supported units. }
procedure TMeterValue.SetAsAirPressure;
begin
  ValueType := CONST_TYPE;
  Value := 102124.64;
  SetFilter(-1);
  Accuracy := 4;
  Name := 'Давление атм';
  ShrtName := 'Pатм';
  Dimensions.Clear;
  SetDimension('Па', 1);
  SetDimension('гПа', 1, 100, False);
  SetDimension('мм.рт.ст.', 1, 133.32239023154, False);
  SetDimension('кПа', 1, 1000, False);
  SetDim(1);
  MaxValue := 1000000;
  MinValue := -10000;
  MaxNomValue := 103000;
  MinNomValue := 101000;
  CoefK := 10000;
  CoefP := -40000;
  Error := 0.1;
  SetValue(102124.64);
end;

{ Configures this meter value as electrical current with supported units. }
procedure TMeterValue.SetAsCurrent;
begin
  ValueType := CONST_TYPE;
  Value := 4;
  SetFilter(-1);
  Accuracy := 4;
  Name := 'Ток';
  ShrtName := 'I';
  Dimensions.Clear;
  SetDimension('мА', 1);
  SetDim(0);
  MaxValue := 20;
  MinValue := 0;
  MaxNomValue := 20;
  MinNomValue := 4;
  Error := 0.02;
  CoefK := 1;
  CoefP := 0;
  SetValue(4.0);
end;

{ Configures this meter value as mass conversion coefficient. }
procedure TMeterValue.SetAsMassCoef;
begin
  ValueType := CONST_TYPE;
  Value := 100;
  SetFilter(-1);
  Accuracy := 5;
  ShrtName := 'Km';
  Name := 'Коэфициент по массе';
  Dimensions.Clear;
  SetDimension('имп/кг', 1);
  SetDimension('кг/имп', 1, 1, True);
  SetDim(0);
  Error := 0.01;
  MaxValue := MaxDouble;
  MinValue := 0.00000000001;
end;

{ Configures this meter value as volume conversion coefficient. }
procedure TMeterValue.SetAsVolumeCoef;
begin
  ValueType := CONST_TYPE;
  Value := 100;
  SetFilter(-1);
  Accuracy := 5;
  Error := 0.01;
  ShrtName := 'Kv';
  Name := 'Коэфициент по объему';
  Dimensions.Clear;
  SetDimension('имп/л', 1, 1, False);
  SetDimension('л/имп', 1, 1, True);
  SetDim(0);
  MaxValue := MaxDouble;
  MinValue := 0.00000000001;
end;

{ Configures this meter value as relative humidity percentage. }
procedure TMeterValue.SetAsHumidity;
begin
  ValueType := CONST_TYPE;
  Value := 35;
  SetFilter(-1);
  Accuracy := 4;
  Name := 'Влажность';
  ShrtName := 'φ атм';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);
  MaxValue := 100;
  MinValue := 0;
  MaxNomValue := 60;
  MinNomValue := 20;
end;

{ Configures this meter value as calculated/derived value placeholder. }
procedure TMeterValue.SetCalcValue;
var
  ResultLocal: Double;
  TLocal: Double;
  PLocal: Double;
  DensLocal: Double;
  DLocal: Double;
  D2Local: Double;
  T2Local: Double;
  T3Local: Double;
  T4Local: Double;
  PAdd: Double;
begin
  if SameText(Name, 'Плотность') then
  begin
    if (ValueBaseMultiplier <> nil) and (ValueBaseDevider <> nil) then
    begin
      TLocal := ValueBaseMultiplier.Value;
      PLocal := ValueBaseDevider.Value;
      DensLocal := (FInitDensity * 1000 - 998.204) + 1.7675;

      PAdd := (PLocal / 20000 * 0.01);
      T2Local := Power(TLocal + (-3.983035), 2);
      T3Local := (522528.9 * (TLocal + 69.34881));
      T4Local := (-4.612 * Power(10, -3) + 0.106 * Power(10, -3) * TLocal);

      D2Local := (1 - T2Local * (TLocal + 301.797) / T3Local);
      DLocal := (998.204 * D2Local) + T4Local;
      ResultLocal := DLocal + DensLocal + PAdd;

      SetValue(ResultLocal / 1000);
    end;
    Exit;
  end;

  SetValue(FilterApply);
end;

{ Creates a GUID-based unique identifier string for a meter value object. }
function TMeterValue.GetNewUUID: string;
begin
  Result := TGUID.NewGuid.ToString;
end;

{ Serializes all meter values to persistent INI storage (optionally backup). }
class procedure TMeterValue.SaveToFile(IsBackUp: Integer);
var
  Ini: TMemIniFile;
  FileName: string;
  I, J: Integer;
  MV: TMeterValue;
  Section: string;
  SubSection: string;
  Dim: TDimension;
  CoefItem: TCoef;
begin
  FMeterValuesSaves.Clear;
  for MV in FMeterValues do
    if MV.IsToSave then
      FMeterValuesSaves.Add(MV);

  if IsBackUp = 0 then
    FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'MeterValues.ini')
  else
    FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), Format('MeterValuesBackUp%d.ini', [IsBackUp]));

  Ini := TMemIniFile.Create(FileName);
  try
    Ini.Clear;
    Ini.WriteString('MeterValues', 'VER', '1.0');
    Ini.WriteFloat('MeterValues', 'InitDensity', FInitDensity);
    Ini.WriteInteger('MeterValues', 'ValuesCount', FMeterValuesSaves.Count);

    for I := 0 to FMeterValuesSaves.Count - 1 do
    begin
      MV := FMeterValuesSaves[I];
      Section := 'MeterValue.' + IntToStr(I);

      Ini.WriteString(Section, 'Hash', MV.Hash);
      Ini.WriteBool(Section, 'IsToSave', MV.IsToSave);
      Ini.WriteString(Section, 'HashOwner', MV.HashOwner);
      Ini.WriteString(Section, 'NameOwner', MV.NameOwner);
      Ini.WriteString(Section, 'Name', MV.Name);
      Ini.WriteString(Section, 'ShrtName', MV.ShrtName);
      Ini.WriteString(Section, 'Description', MV.Description);
      Ini.WriteString(Section, 'Type', MV.&Type);
      Ini.WriteString(Section, 'RawValueName', MV.RawValueName);
      Ini.WriteString(Section, 'RawValueDim', MV.RawValueDim);

      Ini.WriteString(Section, 'HashValueRate', MV.HashValueRate);
      Ini.WriteString(Section, 'HashValueBaseMultiplier', MV.HashValueBaseMultiplier);
      Ini.WriteString(Section, 'HashValueBaseDevider', MV.HashValueBaseDevider);
      Ini.WriteString(Section, 'HashValueCorrection', MV.HashValueCorrection);
      Ini.WriteString(Section, 'HashValueEtalon', MV.HashValueEtalon);

      Ini.WriteInteger(Section, 'filter_order', MV.FFilterOrder);
      Ini.WriteInteger(Section, 'Accuracy', MV.Accuracy);
      Ini.WriteFloat(Section, 'Error', MV.Error);
      Ini.WriteFloat(Section, 'MaxValue', MV.MaxValue);
      Ini.WriteFloat(Section, 'MinValue', MV.MinValue);
      Ini.WriteFloat(Section, 'MaxNomValue', MV.MaxNomValue);
      Ini.WriteFloat(Section, 'MinNomValue', MV.MinNomValue);
      Ini.WriteFloat(Section, 'CoefK', MV.CoefK);
      Ini.WriteFloat(Section, 'CoefP', MV.CoefP);
      Ini.WriteInteger(Section, 'CurrentDimIndex', MV.CurrentDimIndex);
      Ini.WriteInteger(Section, 'ValueType', Ord(MV.ValueType));
      Ini.WriteInteger(Section, 'DependenceType', Ord(MV.DependenceType));
      Ini.WriteInteger(Section, 'UpdateType', Ord(MV.UpdateType));

      Ini.WriteInteger(Section, 'DimensionsCount', MV.Dimensions.Count);
      for J := 0 to MV.Dimensions.Count - 1 do
      begin
        Dim := MV.Dimensions[J];
        SubSection := Section + '.Dimension.' + IntToStr(J);
        Ini.WriteString(SubSection, 'Name', Dim.Name);
        Ini.WriteString(SubSection, 'Hash', Dim.Hash);
        Ini.WriteFloat(SubSection, 'Rate', Dim.Rate);
        Ini.WriteFloat(SubSection, 'Devider', Dim.Devider);
        Ini.WriteBool(SubSection, 'Factor', Dim.Factor);
        Ini.WriteBool(SubSection, 'Recip', Dim.Recip);
      end;

      Ini.WriteInteger(Section, 'CoefsCount', MV.Coefs.Count);
      for J := 0 to MV.Coefs.Count - 1 do
      begin
        CoefItem := MV.Coefs[J];
        SubSection := Section + '.Coef.' + IntToStr(J);
        Ini.WriteString(SubSection, 'Name', CoefItem.Name);
        Ini.WriteInteger(SubSection, 'Index', CoefItem.Index);
        Ini.WriteString(SubSection, 'Hash', CoefItem.Hash);
        Ini.WriteFloat(SubSection, 'Value', CoefItem.Value);
        Ini.WriteFloat(SubSection, 'Arg', CoefItem.Arg);
        Ini.WriteFloat(SubSection, 'Q1', CoefItem.Q1);
        Ini.WriteFloat(SubSection, 'Q2', CoefItem.Q2);
        Ini.WriteFloat(SubSection, 'K', CoefItem.K);
        Ini.WriteFloat(SubSection, 'b', CoefItem.b);
        Ini.WriteBool(SubSection, 'InUse', CoefItem.InUse);
      end;
    end;

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

{ Loads meter values from persistent INI storage and restores relations. }
class procedure TMeterValue.LoadFromFile;
var
  Ini: TIniFile;
  FileName: string;
  Count, I, J: Integer;
  Section: string;
  MV: TMeterValue;
  Dim: TDimension;
  CoefItem: TCoef;
  Hash: string;
begin
  FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'MeterValues.ini');
  if not FileExists(FileName) then
  begin
    SaveToFile(0);
    Exit;
  end;

  Ini := TIniFile.Create(FileName);
  try
    FInitDensity := Ini.ReadFloat('MeterValues', 'InitDensity', FInitDensity);
    Count := Ini.ReadInteger('MeterValues', 'ValuesCount', 0);
    FMeterValuesSaves.Clear;

    for I := 0 to Count - 1 do
    begin
      Section := 'MeterValue.' + IntToStr(I);
      Hash := Ini.ReadString(Section, 'Hash', '');
      MV := GetMeterValue(Hash);
      if MV = nil then
        MV := TMeterValue.Create;

      if not Hash.IsEmpty then
        MV.Hash := Hash;
      MV.IsToSave := True;
      MV.HashOwner := Ini.ReadString(Section, 'HashOwner', '');
      MV.NameOwner := Ini.ReadString(Section, 'NameOwner', '');
      MV.Name := Ini.ReadString(Section, 'Name', '');
      MV.ShrtName := Ini.ReadString(Section, 'ShrtName', '');
      MV.Description := Ini.ReadString(Section, 'Description', '');
      MV.&Type := Ini.ReadString(Section, 'Type', '');
      MV.RawValueName := Ini.ReadString(Section, 'RawValueName', '');
      MV.RawValueDim := Ini.ReadString(Section, 'RawValueDim', '');

      MV.HashValueRate := Ini.ReadString(Section, 'HashValueRate', '');
      MV.HashValueBaseMultiplier := Ini.ReadString(Section, 'HashValueBaseMultiplier', '');
      MV.HashValueBaseDevider := Ini.ReadString(Section, 'HashValueBaseDevider', '');
      MV.HashValueCorrection := Ini.ReadString(Section, 'HashValueCorrection', '');
      MV.HashValueEtalon := Ini.ReadString(Section, 'HashValueEtalon', '');

      MV.FFilterOrder := Ini.ReadInteger(Section, 'filter_order', MV.FFilterOrder);
      MV.Accuracy := Ini.ReadInteger(Section, 'Accuracy', MV.Accuracy);
      MV.Error := Ini.ReadFloat(Section, 'Error', MV.Error);
      MV.MaxValue := Ini.ReadFloat(Section, 'MaxValue', MV.MaxValue);
      MV.MinValue := Ini.ReadFloat(Section, 'MinValue', MV.MinValue);
      MV.MaxNomValue := Ini.ReadFloat(Section, 'MaxNomValue', MV.MaxNomValue);
      MV.MinNomValue := Ini.ReadFloat(Section, 'MinNomValue', MV.MinNomValue);
      MV.CoefK := Ini.ReadFloat(Section, 'CoefK', MV.CoefK);
      MV.CoefP := Ini.ReadFloat(Section, 'CoefP', MV.CoefP);
      MV.CurrentDimIndex := Ini.ReadInteger(Section, 'CurrentDimIndex', 0);
      MV.ValueType := EValueType(Ini.ReadInteger(Section, 'ValueType', Ord(MV.ValueType)));
      MV.DependenceType := EDependenceType(Ini.ReadInteger(Section, 'DependenceType', Ord(MV.DependenceType)));
      MV.UpdateType := EUpdateType(Ini.ReadInteger(Section, 'UpdateType', Ord(MV.UpdateType)));

      MV.Dimensions.Clear;
      for J := 0 to Ini.ReadInteger(Section, 'DimensionsCount', 0) - 1 do
      begin
        Dim.Name := Ini.ReadString(Section + '.Dimension.' + IntToStr(J), 'Name', '');
        Dim.Hash := Ini.ReadString(Section + '.Dimension.' + IntToStr(J), 'Hash', '');
        Dim.Rate := Ini.ReadFloat(Section + '.Dimension.' + IntToStr(J), 'Rate', 1);
        Dim.Devider := Ini.ReadFloat(Section + '.Dimension.' + IntToStr(J), 'Devider', 1);
        Dim.Factor := Ini.ReadBool(Section + '.Dimension.' + IntToStr(J), 'Factor', True);
        Dim.Recip := Ini.ReadBool(Section + '.Dimension.' + IntToStr(J), 'Recip', False);
        MV.Dimensions.Add(Dim);
      end;

      MV.Coefs.Clear;
      for J := 0 to Ini.ReadInteger(Section, 'CoefsCount', 0) - 1 do
      begin
        CoefItem.Name := Ini.ReadString(Section + '.Coef.' + IntToStr(J), 'Name', '');
        CoefItem.Index := Ini.ReadInteger(Section + '.Coef.' + IntToStr(J), 'Index', J);
        CoefItem.Hash := Ini.ReadString(Section + '.Coef.' + IntToStr(J), 'Hash', '');
        CoefItem.Value := Ini.ReadFloat(Section + '.Coef.' + IntToStr(J), 'Value', 0);
        CoefItem.Arg := Ini.ReadFloat(Section + '.Coef.' + IntToStr(J), 'Arg', 0);
        CoefItem.Q1 := Ini.ReadFloat(Section + '.Coef.' + IntToStr(J), 'Q1', 0);
        CoefItem.Q2 := Ini.ReadFloat(Section + '.Coef.' + IntToStr(J), 'Q2', 0);
        CoefItem.K := Ini.ReadFloat(Section + '.Coef.' + IntToStr(J), 'K', 0);
        CoefItem.b := Ini.ReadFloat(Section + '.Coef.' + IntToStr(J), 'b', 0);
        CoefItem.InUse := Ini.ReadBool(Section + '.Coef.' + IntToStr(J), 'InUse', True);
        MV.Coefs.Add(CoefItem);
      end;
      MV.SetToSave(False);
    end;
  finally
    Ini.Free;
  end;
end;

class function TMeterValue.GetInitDensity: Double;
begin
  Result := FInitDensity;
end;

class procedure TMeterValue.SetInitDensity(const AValue: Double);
begin
  FInitDensity := AValue;
end;

{ Stores a calibration coefficient entry (record or value/argument pair). }
procedure TMeterValue.SetCoef(ACoef: TCoef);
begin
  Coefs.Add(ACoef);
end;

{ Stores a calibration coefficient entry (record or value/argument pair). }
function TMeterValue.SetCoef(AValue, AArg: Double): string;
var
  C: TCoef;
begin
  C.Hash := GetNewUUID;
  C.Index := Coefs.Count;
  C.Value := AValue;
  C.Arg := AArg;
  C.InUse := True;
  Coefs.Add(C);
  Result := C.Hash;
end;

{ Returns index position for appending a new coefficient entry. }
function TMeterValue.GetNewHashCoef: Integer;
begin
  Result := Coefs.Count + 1;
end;

{ Recalculates piecewise-linear coefficient parameters after table changes. }
procedure TMeterValue.CalcCoefs;
begin
  // Заглушка: вычисления коэффициентов калибровки.
end;

{ Marks value as persistent and updates the save-list registry. }
procedure TMeterValue.SetToSave(AIsToSave: Boolean);
begin
  IsToSave := AIsToSave;
  if AIsToSave then
  begin
    if FMeterValuesSaves.IndexOf(Self) < 0 then
      FMeterValuesSaves.Add(Self);
  end
  else
    FMeterValuesSaves.Remove(Self);
end;

{ Removes this instance from global in-memory meter value registries. }
procedure TMeterValue.DeleteFromVector;
begin
  FMeterValues.Remove(Self);
  FMeterValuesSaves.Remove(Self);
end;

{ Returns shared registry containing all created TMeterValue instances. }
class function TMeterValue.GetMeterValues: TObjectList<TMeterValue>;
begin
  Result := FMeterValues;
end;

class procedure TMeterValue.RebindReferences(const AOldValue, ANewValue: TMeterValue);
var
  MV: TMeterValue;
  I: Integer;
begin
  if (AOldValue = nil) or (AOldValue = ANewValue) then
    Exit;

  for MV in FMeterValues do
  begin
    if MV = nil then
      Continue;

    if MV.ValueRate = AOldValue then
      MV.ValueRate := ANewValue;
    if MV.ValueBaseMultiplier = AOldValue then
      MV.ValueBaseMultiplier := ANewValue;
    if MV.ValueBaseDevider = AOldValue then
      MV.ValueBaseDevider := ANewValue;
    if MV.ValueCorrection = AOldValue then
      MV.ValueCorrection := ANewValue;
    if MV.ValueEtalon = AOldValue then
      MV.ValueEtalon := ANewValue;

    for I := MV.MeterValues.Count - 1 downto 0 do
    begin
      if MV.MeterValues[I] <> AOldValue then
        Continue;

      if ANewValue = nil then
        MV.MeterValues.Delete(I)
      else if MV.MeterValues.IndexOf(ANewValue) < 0 then
        MV.MeterValues[I] := ANewValue
      else
        MV.MeterValues.Delete(I);
    end;
  end;

  for I := FMeterValuesSaves.Count - 1 downto 0 do
  begin
    if FMeterValuesSaves[I] <> AOldValue then
      Continue;

    if ANewValue = nil then
      FMeterValuesSaves.Delete(I)
    else if FMeterValuesSaves.IndexOf(ANewValue) < 0 then
      FMeterValuesSaves[I] := ANewValue
    else
      FMeterValuesSaves.Delete(I);
  end;
end;

end.
