unit UnitMeterValue;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.IniFiles,
  System.IOUtils,
  System.Generics.Collections;

type
  EUpdateType = (OFFLINE_TYPE, ONLINE_TYPE, HAND_TYPE);
  EValueType = (FLOW_TYPE, SUM_TYPE, CONST_TYPE, ERROR_TYPE);
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
    function IsStable(lim: Integer): Boolean;
    function GetStringValue: string; overload;
    function GetStringValue(Dim: Byte): string; overload;
    function GetStringValue(const ADim: string): string; overload;
    function GetStrValue: string;
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
    class function GetMeterValues: TObjectList<TMeterValue>; static;
  end;

implementation

uses
  UnitBaseProcedures;

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
  IsToSave := False;
  FMeterValues.Add(Self);
  FMeterValuesSaves.Add(Self);
end;

constructor TMeterValue.Create(const AHashOwner: string; const ANameOwner: string);
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

constructor TMeterValue.CreateFromHash(const AHash: string);
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

class function TMeterValue.GetMeterValue(const AHash, AHashOwner: string; const AName: string): TMeterValue;
begin
  Result := GetMeterValue(AHash);
  if Result = nil then
    Result := TMeterValue.Create(AHashOwner, AName);
end;

class function TMeterValue.GetNewMeterValue(const AHash: string): TMeterValue;
var
  MV: TMeterValue;
begin
  if AHash.IsEmpty then Exit(nil);
  MV := GetMeterValue(AHash);
  if MV <> nil then Exit(TMeterValue.Create(MV));
  Result := TMeterValue.Create;
end;

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
var
  Dbl: Double;
  Precision: Integer;
  FormatMask: string;
begin
  if Value < MinValue then
    Exit('-');

  if Value > MaxValue then
    Exit('+NAN');

  Dbl := GetDoubleValue(Dim);
  if (Error <> 0) and (Abs(Dbl) < (Error / 100) / 10) then
    Dbl := 0;

  Precision := Accuracy;
  if Precision < 0 then
    Precision := 0;

  if Precision > 12 then
    Precision := 12;

  if Precision > 0 then
    FormatMask := '0.' + StringOfChar('0', Precision)
  else
    FormatMask := '0';

  Result := FormatFloat(FormatMask, Dbl);
end;

function TMeterValue.GetStringValue(const ADim: string): string;
begin
  Result := FormatFloat('0.#####', GetDoubleValue(ADim));
end;

function TMeterValue.GetStrValue: string;
begin
  Result := GetStringValue(CurrentDimIndex);
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
  ValueType := CONST_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 0;
  Error := 0.001;
  Name := 'Время';
  ShrtName := 'T';
  Dimensions.Clear;
  SetDimension('s', 1);
  SetDimension('min', 1, 60, False);
  SetDimension('h', 1, 3600, False);
  SetDim(0);
  SetValue(0.0);
  MaxValue := 99999999;
  MinValue := 0;
  MaxNomValue := 3600;
  MinNomValue := 0;
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
  D.Hash := GetNewUUID;
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

procedure TMeterValue.SetAsMass;
begin
  ValueType := SUM_TYPE;
  Name := 'Масса';
  ShrtName := 'M';
  SetFilter(-1);
  Accuracy := 6;
  Value := 0;
  Dimensions.Clear;
  SetDimension('кг', 1, 1, False);
  SetDimension('т', 1, 1000, False);
  SetDim(0);
  MaxValue := MaxDouble;
  MinValue := 0;
  Error := 0.01;
end;

procedure TMeterValue.SetAsVolumeFlow;
begin
  ValueType := FLOW_TYPE;
  Name := 'Объемный расход';
  ShrtName := 'Qv';
  SetFilter(8);
  Accuracy := 4;
  Value := 0;
  Dimensions.Clear;
  SetDimension('л/с', 1, 1, False);
  SetDimension('л/мин', 60, 1, False);
  SetDimension('л/ч', 3600, 1, False);
  SetDimension('м3/мин', 60, 1000, False);
  SetDimension('м3/ч', 3600, 1000, False);
  SetDim(4);
  MaxValue := MaxDouble;
  MinValue := 0;
  Error := 0.01;
end;

procedure TMeterValue.SetAsMassFlow;
begin
  ValueType := FLOW_TYPE;
  Name := 'Массовый расход';
  ShrtName := 'Qm';
  SetFilter(8);
  Accuracy := 4;
  Value := 0;
  Dimensions.Clear;
  SetDimension('кг/с', 1, 1, False);
  SetDimension('кг/мин', 60, 1, False);
  SetDimension('кг/ч', 3600, 1, False);
  SetDimension('т/мин', 60, 1000, False);
  SetDimension('т/ч', 3600, 1000, False);
  SetDim(4);
  MaxValue := MaxDouble;
  MinValue := 0;
  Error := 0.01;
end;

procedure TMeterValue.SetAsImp;
begin
  ValueType := FLOW_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 5;
  Name := 'Импульсы';
  ShrtName := 'N';
  Dimensions.Clear;
  SetDimension('имп', 1, 1, False);
  SetDim(0);
  MaxValue := MaxDouble;
  MinValue := 0;
  Error := 0.001;
  Reset;
end;

procedure TMeterValue.SetAsError;
begin
  ValueType := ERROR_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 4;
  Error := 0.0;
  ShrtName := 'δ';
  Name := 'Погрешность';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);
  MaxValue := 100;
  MinValue := -100;
  MaxNomValue := 0.1;
  MinNomValue := -0.1;
end;

procedure TMeterValue.SetAsMassError;
begin
  ValueType := ERROR_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 4;
  Error := 0;
  Name := 'Погрешность по массе';
  ShrtName := 'δm';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);
  MaxValue := 100;
  MinValue := -100;
  MaxNomValue := 0.1;
  MinNomValue := -0.1;
end;

procedure TMeterValue.SetAsVolumeError;
begin
  ValueType := ERROR_TYPE;
  Value := 0;
  SetFilter(-1);
  Accuracy := 4;
  Error := 0;
  Name := 'Погрешность по объему';
  ShrtName := 'δv';
  Dimensions.Clear;
  SetDimension('%', 1);
  SetDim(0);
  MaxValue := 100;
  MinValue := -100;
  MaxNomValue := 0.1;
  MinNomValue := -0.1;
end;

procedure TMeterValue.SetAsDensity;
begin
  ValueType := CONST_TYPE;
  Value := 998.1;
  SetFilter(-1);
  Accuracy := 5;
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
  SetValue(0.9982);
end;

procedure TMeterValue.SetAsTemp;
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

procedure TMeterValue.SetAsPressure;
begin
  ValueType := CONST_TYPE;
  Value := 98;
  SetFilter(-1);
  Accuracy := 4;
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
  Error := 0.5;
  CoefK := 100000;
  CoefP := -400000;
  SetValue(98.0);
end;

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

procedure TMeterValue.SetCalcValue;
begin
  SetValue(FilterApply);
end;

function TMeterValue.GetNewUUID: string;
begin
  Result := TGUID.NewGuid.ToString;
end;

class procedure TMeterValue.SaveToFile(IsBackUp: Integer);
var
  Ini: TIniFile;
  FileName: string;
  I, J: Integer;
  MV: TMeterValue;
  Section: string;
  Dim: TDimension;
  CoefItem: TCoef;
begin
  FMeterValuesSaves.Clear;
 // for MV in FMeterValues do
//    if MV.IsToSave then
 //     FMeterValuesSaves.Add(MV);

  if IsBackUp = 0 then
    FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'MeterValues.ini')
  else
    FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), Format('MeterValuesBackUp%d.ini', [IsBackUp]));

  Ini := TIniFile.Create(FileName);
  try
    Ini.EraseSection('MeterValues');
    Ini.WriteString('MeterValues', 'VER', '1.0');
    Ini.WriteInteger('MeterValues', 'ValuesCount', FMeterValuesSaves.Count);

    for I := 0 to FMeterValuesSaves.Count - 1 do
    begin
      MV := FMeterValuesSaves[I];
      Section := 'MeterValue.' + IntToStr(I);
      Ini.EraseSection(Section);

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
        Ini.WriteString(Section + '.Dimension.' + IntToStr(J), 'Name', Dim.Name);
        Ini.WriteString(Section + '.Dimension.' + IntToStr(J), 'Hash', Dim.Hash);
        Ini.WriteFloat(Section + '.Dimension.' + IntToStr(J), 'Rate', Dim.Rate);
        Ini.WriteFloat(Section + '.Dimension.' + IntToStr(J), 'Devider', Dim.Devider);
        Ini.WriteBool(Section + '.Dimension.' + IntToStr(J), 'Factor', Dim.Factor);
        Ini.WriteBool(Section + '.Dimension.' + IntToStr(J), 'Recip', Dim.Recip);
      end;

      Ini.WriteInteger(Section, 'CoefsCount', MV.Coefs.Count);
      for J := 0 to MV.Coefs.Count - 1 do
      begin
        CoefItem := MV.Coefs[J];
        Ini.WriteString(Section + '.Coef.' + IntToStr(J), 'Name', CoefItem.Name);
        Ini.WriteInteger(Section + '.Coef.' + IntToStr(J), 'Index', CoefItem.Index);
        Ini.WriteString(Section + '.Coef.' + IntToStr(J), 'Hash', CoefItem.Hash);
        Ini.WriteFloat(Section + '.Coef.' + IntToStr(J), 'Value', CoefItem.Value);
        Ini.WriteFloat(Section + '.Coef.' + IntToStr(J), 'Arg', CoefItem.Arg);
        Ini.WriteFloat(Section + '.Coef.' + IntToStr(J), 'Q1', CoefItem.Q1);
        Ini.WriteFloat(Section + '.Coef.' + IntToStr(J), 'Q2', CoefItem.Q2);
        Ini.WriteFloat(Section + '.Coef.' + IntToStr(J), 'K', CoefItem.K);
        Ini.WriteFloat(Section + '.Coef.' + IntToStr(J), 'b', CoefItem.b);
        Ini.WriteBool(Section + '.Coef.' + IntToStr(J), 'InUse', CoefItem.InUse);
      end;
    end;
  finally
    Ini.Free;
  end;
end;

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
      MV.SetToSave(True);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TMeterValue.SetCoef(ACoef: TCoef);
begin
  Coefs.Add(ACoef);
end;

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

class function TMeterValue.GetMeterValues: TObjectList<TMeterValue>;
begin
  Result := FMeterValues;
end;

end.
