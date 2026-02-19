unit UnitMeterValue;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections,
  System.DateUtils;

type
  EUpdateType = (OFFLINE_TYPE, ONLINE_TYPE, HAND_TYPE);
  EValueType = (FLOW_TYPE, SUM_TYPE, CONST_TYPE, ERROR_TYPE);
  EDependenceType = (INDEPENDENT, DEPENDENT);

  TDimension = record
    Name: string;
    Hash: Integer;
    Rate: Double;
    Devider: Double;
    Factor: Boolean;
    Recip: Boolean;
  end;

  TCoef = record
    Name: string;
    Index: Integer;
    Hash: Integer;
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
    function FindDimIndex(const AName: string): Integer;
    class constructor CreateClass;
    class destructor DestroyClass;
  public
    ValueWoCorrection: Double;
    TempDelta: Integer;
    Short_Mean_index: Integer;
    Hash: Integer;
    HashOwner: Integer;
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
    HashValueRate: Integer;
    HashValueBaseMultiplier: Integer;
    HashValueBaseDevider: Integer;
    HashValueCorrection: Integer;
    HashValueEtalon: Integer;
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
    Accuracy: Byte;
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

    constructor Create; overload;
    constructor Create(AHashOwner: Integer; const ANameOwner: string); overload;
    constructor Create(ACopyFrom: TMeterValue); overload;
    constructor CreateFromHash(AHash: Integer);
    destructor Destroy; override;

    procedure SetCopy(AMeterValue: TMeterValue);
    class function GetNewMeterValue(AHash: Integer): TMeterValue; static;
    class function GetNewMeterValueBool(AHash: Integer; out IsExisted: Integer; AHashOwner: Integer; const AName: string): TMeterValue; static;
    class function GetCopyMeterValueBool(var AHash: Integer; out IsExisted: Integer): TMeterValue; static;
    class function GetExistedMeterValueBool(var AHash: Integer; out IsExisted: Integer; AHashOwner: Integer; const AName: string): TMeterValue; static;
    class function GetMeterValue(AHash: Integer): TMeterValue; overload; static;
    class function GetMeterValue(AHash, AHashOwner: Integer; const AName: string): TMeterValue; overload; static;

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
    function IsStable(lim: Integer): Boolean;
    function GetStringValue: string; overload;
    function GetStringValue(Dim: Byte): string; overload;
    function GetStringValue(const ADim: string): string; overload;
    function GetStringNum(AValue: Double): string;

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
    procedure SetAsTime;
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
    function SetDim(Dim: Integer): Boolean;
    function NextDim: Boolean;
    function GetStrFullName: string;
    function GetDoubleNum(const AStr: string): Double;
    procedure Reset;

    procedure SetAsVolume;
    procedure SetAsMass;
    procedure SetAsVolumeFlow;
    procedure SetAsMassFlow;
    procedure SetAsImp;
    procedure SetAsError;
    procedure SetAsCurrent;
    procedure SetCalcValue;

    function GetNewHash: Integer;
    class procedure SaveToFile(IsBackUp: Integer); static;
    class procedure LoadFromFile; static;

    procedure SetCoef(ACoef: TCoef); overload;
    function SetCoef(AValue, AArg: Double): Integer; overload;
    function GetNewHashCoef: Integer;
    procedure CalcCoefs;
    procedure SetToSave(AIsToSave: Boolean);
    procedure DeleteFromVector;
  end;

implementation

{ TMeterValue }

class constructor TMeterValue.CreateClass;
begin
  FMeterValues := TObjectList<TMeterValue>.Create(False);
  FMeterValuesSaves := TObjectList<TMeterValue>.Create(False);
end;

class destructor TMeterValue.DestroyClass;
begin
  FMeterValues.Free;
  FMeterValuesSaves.Free;
end;

constructor TMeterValue.Create;
begin
  inherited Create;
  Hash := GetNewHash;
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
  FMeterValues.Add(Self);
end;

constructor TMeterValue.Create(AHashOwner: Integer; const ANameOwner: string);
begin
  Create;
  HashOwner := AHashOwner;
  NameOwner := ANameOwner;
end;

constructor TMeterValue.Create(ACopyFrom: TMeterValue);
begin
  Create;
  SetCopy(ACopyFrom);
end;

constructor TMeterValue.CreateFromHash(AHash: Integer);
var
  MV: TMeterValue;
begin
  Create;
  MV := GetMeterValue(AHash);
  if MV <> nil then
    SetCopy(MV);
end;

destructor TMeterValue.Destroy;
begin
  Coefs.Free;
  AverValues.Free;
  Values.Free;
  RawValues.Free;
  Means.Free;
  Dimensions.Free;
  inherited;
end;

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

class function TMeterValue.GetMeterValue(AHash: Integer): TMeterValue;
var
  MV: TMeterValue;
begin
  Result := nil;
  if AHash = 0 then Exit;
  for MV in FMeterValues do
    if MV.Hash = AHash then
      Exit(MV);
end;

class function TMeterValue.GetMeterValue(AHash, AHashOwner: Integer; const AName: string): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result = nil then
    Result := TMeterValue.Create(AHashOwner, AName);
end;

class function TMeterValue.GetNewMeterValue(AHash: Integer): TMeterValue;
var
  MV: TMeterValue;
begin
  if AHash = 0 then Exit(nil);
  MV := GetMeterValue(AHash);
  if MV <> nil then Exit(TMeterValue.Create(MV));
  Result := TMeterValue.Create;
end;

class function TMeterValue.GetNewMeterValueBool(AHash: Integer; out IsExisted: Integer; AHashOwner: Integer; const AName: string): TMeterValue;
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

class function TMeterValue.GetCopyMeterValueBool(var AHash: Integer; out IsExisted: Integer): TMeterValue;
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

class function TMeterValue.GetExistedMeterValueBool(var AHash: Integer; out IsExisted: Integer; AHashOwner: Integer; const AName: string): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result <> nil then
  begin
    IsExisted := 1;
    if Result.HashOwner = 0 then
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
end;

procedure TMeterValue.Random;
begin
  SetValue(System.Math.RandomRange(0, 1000) / 10);
end;

function TMeterValue.FilterApply: Double;
begin
  Result := Value;
end;

function TMeterValue.AverageApply: Single;
begin
  Result := FShortMean;
end;

function TMeterValue.GetFloatValue: Single;
begin
  Result := GetDoubleValue;
end;

function TMeterValue.GetFloatValue(Dim: Byte): Single;
begin
  Result := GetDoubleValue(Dim);
end;

function TMeterValue.GetFloatValue(const ADim: string): Single;
begin
  Result := GetDoubleValue(ADim);
end;

function TMeterValue.GetDoubleValue: Double;
begin
  Result := Value;
end;

function TMeterValue.GetDoubleValue(Dim: Byte): Double;
begin
  Result := Value * GetDimRate(Dim);
end;

function TMeterValue.GetDoubleValue(const ADim: string): Double;
begin
  Result := Value * GetDimRate(ADim);
end;

function TMeterValue.GetDoubleValueDim: Double;
begin
  Result := GetDoubleValue(CurrentDimIndex);
end;

function TMeterValue.GetDoubleMeanValue: Double;
begin
  if Means.Count = 0 then Exit(Value);
  Result := Mean;
end;

function TMeterValue.GetDoubleMeanValue(dim: Byte): Double;
begin
  Result := GetDoubleMeanValue * GetDimRate(dim);
end;

function TMeterValue.GetDoubleMeanValue(const DimName: string): Double;
begin
  Result := GetDoubleMeanValue * GetDimRate(DimName);
end;

function TMeterValue.IsStable(lim: Integer): Boolean;
begin
  Result := Abs(Value - FLastMean) <= lim;
end;

function TMeterValue.GetStringValue: string;
begin
  Result := FormatFloat('0.#####', GetDoubleValue);
end;

function TMeterValue.GetStringValue(Dim: Byte): string;
begin
  Result := FormatFloat('0.#####', GetDoubleValue(Dim));
end;

function TMeterValue.GetStringValue(const ADim: string): string;
begin
  Result := FormatFloat('0.#####', GetDoubleValue(ADim));
end;

function TMeterValue.GetStringNum(AValue: Double): string;
begin
  Result := FormatFloat('0.#####', AValue);
end;

procedure TMeterValue.SetFilter(AOrder: Integer);
begin
  FFilterOrder := AOrder;
end;

function TMeterValue.GetFilter: Integer;
begin
  Result := FFilterOrder;
end;

procedure TMeterValue.SetRawValue(InputValue: Double);
begin
  FRawValue := InputValue;
  SetValue(InputValue);
end;

procedure TMeterValue.SetRawValue(InputValue: Double; Q: Single);
begin
  SetRawValue(InputValue * Rate(Q));
end;

procedure TMeterValue.SetMainValue(InputValue: Double);
begin
  SetValue(InputValue);
end;

procedure TMeterValue.SetMainValue(InputValue: Double; Q: Single);
begin
  SetValue(InputValue * Rate(Q));
end;

procedure TMeterValue.SetValue;
begin
  SetValue(FRawValue);
end;

procedure TMeterValue.SetValue(AValue: Single);
begin
  SetValue(Double(AValue));
end;

procedure TMeterValue.SetValue(AValue: Double);
begin
  Value := EnsureRange(AValue, MinValue, MaxValue);
  Values.Add(Value);
  if Values.Count > ARRAY_SIZE then
    Values.Delete(0);
  Mean := (Mean * MeanCnt + Value) / (MeanCnt + 1);
  Inc(MeanCnt);
  FLastMean := Mean;
end;

procedure TMeterValue.SetValue(AValue: Double; Dim: Byte);
begin
  SetValue(AValue / GetDimRate(Dim));
end;

procedure TMeterValue.SetValue(AValue: Double; const ADimensions: string);
begin
  SetValue(AValue / GetDimRate(ADimensions));
end;

procedure TMeterValue.SetAddValue(InputValue: Double);
begin
  SetValue(Value + InputValue);
end;

procedure TMeterValue.SetDimValue(AValue: Double);
begin
  SetValue(AValue, CurrentDimIndex);
end;

procedure TMeterValue.SetDimValue(const AStr: string);
begin
  SetDimValue(GetDoubleNum(AStr));
end;

procedure TMeterValue.SetValue(const AValue: string);
begin
  SetValue(GetDoubleNum(AValue));
end;

procedure TMeterValue.SetAsTime;
begin
  SetDimension('s', 1);
  SetDimension('min', 1 / 60);
  SetDimension('h', 1 / 3600);
end;

function TMeterValue.Rate(Q: Double): Double;
begin
  Result := CoefK * Q + CoefP;
end;

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

procedure TMeterValue.SetValueCurrnet(AValue: Double);
begin
  SetValue(AValue);
end;

function TMeterValue.FindDimIndex(const AName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Dimensions.Count - 1 do
    if SameText(Dimensions[I].Name, AName) then
      Exit(I);
  Result := -1;
end;

procedure TMeterValue.SetDimension(const ADimensions: string; DimRate: Double);
begin
  SetDimension(ADimensions, DimRate, 1, False);
end;

procedure TMeterValue.SetDimension(const AName: string; ARate, ADevider: Double; ARecip: Boolean);
var
  D: TDimension;
begin
  D.Name := AName;
  D.Hash := GetNewHash;
  D.Rate := ARate;
  D.Devider := ADevider;
  D.Recip := ARecip;
  D.Factor := False;
  Dimensions.Add(D);
  if Dimensions.Count = 1 then
    CurrentDimIndex := 0;
end;

function TMeterValue.GetDimRate(const AName: string): Double;
var
  I: Integer;
begin
  I := FindDimIndex(AName);
  if I < 0 then Exit(1);
  Result := GetDimRate(I);
end;

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

function TMeterValue.GetDimName: string;
begin
  Result := GetDimName(CurrentDimIndex);
end;

function TMeterValue.GetDimName(Dim: Integer): string;
begin
  if (Dim >= 0) and (Dim < Dimensions.Count) then
    Result := Dimensions[Dim].Name
  else
    Result := '';
end;

function TMeterValue.GetDim(const AName: string; out Dim: TDimension): Boolean;
var
  I: Integer;
begin
  I := FindDimIndex(AName);
  Result := I >= 0;
  if Result then Dim := Dimensions[I];
end;

function TMeterValue.GetDim(const AName: string): Integer;
begin
  Result := FindDimIndex(AName);
end;

function TMeterValue.GetDim(index: Integer; out Dim: TDimension): Boolean;
begin
  Result := (index >= 0) and (index < Dimensions.Count);
  if Result then Dim := Dimensions[index];
end;

function TMeterValue.GetDim: Integer;
begin
  Result := CurrentDimIndex;
end;

function TMeterValue.SetDim(Dim: Integer): Boolean;
begin
  Result := (Dim >= 0) and (Dim < Dimensions.Count);
  if Result then CurrentDimIndex := Dim;
end;

function TMeterValue.NextDim: Boolean;
begin
  if Dimensions.Count = 0 then Exit(False);
  CurrentDimIndex := (CurrentDimIndex + 1) mod Dimensions.Count;
  Result := True;
end;

function TMeterValue.GetStrFullName: string;
begin
  Result := Name;
  if GetDimName <> '' then
    Result := Result + ', ' + GetDimName;
end;

function TMeterValue.GetDoubleNum(const AStr: string): Double;
begin
  Result := StrToFloatDef(StringReplace(Trim(AStr), ',', '.', [rfReplaceAll]), 0, TFormatSettings.Invariant);
end;

procedure TMeterValue.Reset;
begin
  Value := 0;
  Mean := 0;
  MeanCnt := 0;
  RawValues.Clear;
  Values.Clear;
  AverValues.Clear;
  Means.Clear;
end;

procedure TMeterValue.SetAsVolume;
begin
  SetDimension('m3', 1);
end;

procedure TMeterValue.SetAsMass;
begin
  SetDimension('kg', 1);
end;

procedure TMeterValue.SetAsVolumeFlow;
begin
  SetDimension('m3/h', 1);
end;

procedure TMeterValue.SetAsMassFlow;
begin
  SetDimension('kg/h', 1);
end;

procedure TMeterValue.SetAsImp;
begin
  SetDimension('imp', 1);
end;

procedure TMeterValue.SetAsError;
begin
  SetDimension('%', 1);
end;

procedure TMeterValue.SetAsCurrent;
begin
  SetDimension('mA', 1);
end;

procedure TMeterValue.SetCalcValue;
begin
  SetValue(FilterApply);
end;

function TMeterValue.GetNewHash: Integer;
begin
  Result := Integer(DateTimeToUnix(Now, False)) + System.Random(MaxInt);
end;

class procedure TMeterValue.SaveToFile(IsBackUp: Integer);
begin
end;

class procedure TMeterValue.LoadFromFile;
begin
end;

procedure TMeterValue.SetCoef(ACoef: TCoef);
begin
  Coefs.Add(ACoef);
end;

function TMeterValue.SetCoef(AValue, AArg: Double): Integer;
var
  C: TCoef;
begin
  C.Hash := GetNewHashCoef;
  C.Index := Coefs.Count;
  C.Value := AValue;
  C.Arg := AArg;
  C.InUse := True;
  Coefs.Add(C);
  Result := C.Hash;
end;

function TMeterValue.GetNewHashCoef: Integer;
begin
  Result := Coefs.Count + 1;
end;

procedure TMeterValue.CalcCoefs;
begin
  // Заглушка: вычисления коэффициентов калибровки.
end;

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

procedure TMeterValue.DeleteFromVector;
begin
  FMeterValues.Remove(Self);
  FMeterValuesSaves.Remove(Self);
end;

end.
