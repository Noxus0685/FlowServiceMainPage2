unit UnitFlowMeter;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  UnitDeviceClass,
  UnitMeterValue;

const
  CHANNEL = 2;
  XMLVERFLOWMETERS = '5.0';

type
  THscDevice = class
  end;

  TFlowMeterType = class
  end;

  TMeterFlowType = (mftWeightsType, mftVolumeType);

  TPoint = record
    Hash: Integer;
    Name: string;
    Qrate: Single;
    Q: Single;
    Volume: Single;
    VTime: Single;
    Error: Single;
    RangeMinus: Single;
    RangePlus: Single;
  end;

  TDataPoint = record
    PointHash: Integer;
    DateTime: TDateTime;
    Error: Double;
  end;

  TOnChanged = reference to procedure;

  TFlowMeter = class;

  TFlowMeter = class(TDevice)
  private
    FChannel: Byte;
    FHSCDevice: THscDevice;
    FHSC: THscDevice;
    FImpulses: array[0..99] of Word;
    FWrImp: Byte;
    FRdImp: Byte;
    FVolSum: Single;
    FImpSum: Single;
    procedure Init;
    procedure InitValues;
    procedure CopyValues(const AEtalonMeter: TFlowMeter);
  public
    class var ActiveEtalonHash: Integer;
    class var ActiveFlowMeterHash: Integer;
    class var SignCipher: string;
    class var PorveritelFio: string;

    class var JValue: TJSONValue;
    class var JArray: TJSONArray;
    class var JObject: TJSONObject;

    class var FlowMeters: TObjectList<TFlowMeter>;
    class var Etalons: TObjectList<TFlowMeter>;

    class var SHSC: THscDevice;
    class var ActiveFlowMeter: TFlowMeter;
    class var ActiveEtalon: TFlowMeter;
    class var EtalonMeter: TFlowMeter;

    class var OnChangedTestMeter: TOnChanged;

    TypeMeter: TFlowMeterType;

    Hash: Integer;
    DeviceHash: Integer;
    TypeHash: Integer;
    OrderHash: Integer;

    IsEtalon: Boolean;
    Active: Integer;
    CheckType: Integer;

    Status: Integer;
    SendStatus: Integer;

    FlowTypeName: string;

    // Дублирующие с TDevice поля НЕ объявляются здесь намеренно:
    // Name, DeviceTypeName, Modification, SerialNumber, DN, Owner, Documentation,
    // RegDate/ValidityDate/DateOfManufacture, IVI, Qmax/Qmin и др.

    DocNumber: string;
    Means: string;

    K1, P1, K2, P2: string;
    TempWater, Temperature, Pressure, Humidity: string;
    VrfDate: string;

    Data1, Data2, Data3: string;
    Date1, Date2: string;

    ResultValue: string;
    MeterDateTime: TDateTime;
    ModifiedDateTime: string;

    Kp: Double;
    FactoryKp: Double;
    FreqMax: Double;

    K: array[0..99] of Double;
    Q: array[0..99] of Double;

    FlowMax: Double;
    FlowMin: Double;
    QuantityMax: Double;
    QuantityMin: Double;

    Error: Double;

    Point: TPoint;
    DataPoint: TDataPoint;
    CalibrPoint: TCalibrPoint;

    Points: TList<TPoint>;
    DataPoints: TList<TDataPoint>;
    UsedDataPoints: TList<TDataPoint>;
    CalibrPoints: TList<TCalibrPoint>;

    PointIndex: Integer;
    Comment: string;

    MeterFlowType: TMeterFlowType;

    ValueImp: TMeterValue;
    ValueImpTotal: TMeterValue;
    ValueCoef: TMeterValue;
    ValueMassCoef: TMeterValue;
    ValueVolumeCoef: TMeterValue;
    ValueVolume: TMeterValue;
    ValueMass: TMeterValue;
    ValueVolumeMeter: TMeterValue;
    ValueMassMeter: TMeterValue;
    ValueMassFlow: TMeterValue;
    ValueVolumeFlow: TMeterValue;
    ValueQuantity: TMeterValue;
    ValueFlow: TMeterValue;
    ValueError: TMeterValue;
    ValueVolumeError: TMeterValue;
    ValueMassError: TMeterValue;
    ValueDensity: TMeterValue;
    ValuePressure: TMeterValue;
    ValueTemperture: TMeterValue;
    ValueAirPressure: TMeterValue;
    ValueAirTemperture: TMeterValue;
    ValueHumidity: TMeterValue;
    ValueCurrent: TMeterValue;
    ValueTime: TMeterValue;

    HashValueImp: Integer;
    HashValueImpTotal: Integer;
    HashValueCoef: Integer;
    HashValueMassCoef: Integer;
    HashValueVolumeCoef: Integer;
    HashValueVolume: Integer;
    HashValueMass: Integer;
    HashValueVolumeMeter: Integer;
    HashValueMassMeter: Integer;
    HashValueMassFlow: Integer;
    HashValueVolumeFlow: Integer;
    HashValueQuantity: Integer;
    HashValueFlow: Integer;
    HashValueError: Integer;
    HashValueVolumeError: Integer;
    HashValueMassError: Integer;
    HashValueDensity: Integer;
    HashValuePressure: Integer;
    HashValueTemperture: Integer;
    HashValueAirPressure: Integer;
    HashValueAirTemperture: Integer;
    HashValueHumidity: Integer;
    HashValueCurrent: Integer;
    HashValueTime: Integer;

    constructor Create(AMeter: TFlowMeter); overload;
    constructor Create(AHSCDevice: THscDevice; AEtalonMeter: TFlowMeter); overload;
    constructor Create(AHSCDevice: THscDevice; AOrderHash: Integer; AIsEtalon: Boolean); overload;
    constructor Create(AHSCDevice: THscDevice; AIsEtalon: Boolean); overload;
    constructor Create(AHSCDevice: THscDevice; AIsEtalon: Boolean; AHash: Integer); overload;
    constructor Create(AIsEtalon: Boolean); overload;
    destructor Destroy; override;

    procedure SetHSC(AHSCDevice: THscDevice);
    procedure SetType(AType: TFlowMeterType); overload;
    function SetType(ATypeHash: Integer): Boolean; overload;
    procedure SetCopy(AMeter: TFlowMeter);

    function GetStatus: string;
    procedure SetStatus(const AValue: string);
    function GetSendStatus: string;
    procedure SetSendStatus(const AText: string);

    function GetChannel: Byte;
    procedure SetChannel(AChannel: Byte);

    procedure SetImpCoef(AK: Double); overload;
    procedure SetImpCoef(AK: Single); overload;
    function SetImpCoef(const AK: string): Boolean; overload;

    procedure InitHashValues;
    procedure SetValues;
    procedure SetMonitorValues;
    procedure SetFinalValues;
  end;

implementation

{ TFlowMeter }

constructor TFlowMeter.Create(AHSCDevice: THscDevice; AOrderHash: Integer; AIsEtalon: Boolean);
begin
  inherited Create;
  Init;
  FHSCDevice := AHSCDevice;
  FHSC := AHSCDevice;
  OrderHash := AOrderHash;
  IsEtalon := AIsEtalon;
end;

constructor TFlowMeter.Create(AMeter: TFlowMeter);
begin
  inherited Create;
  Init;
  if AMeter <> nil then
  begin
    IsEtalon := AMeter.IsEtalon;
    FHSCDevice := AMeter.FHSCDevice;
    FHSC := AMeter.FHSC;
    SetCopy(AMeter);
  end;
end;

constructor TFlowMeter.Create(AHSCDevice: THscDevice; AEtalonMeter: TFlowMeter);
begin
  inherited Create;
  Init;
  FHSCDevice := AHSCDevice;
  FHSC := AHSCDevice;
  IsEtalon := False;
  EtalonMeter := AEtalonMeter;
end;

constructor TFlowMeter.Create(AHSCDevice: THscDevice; AIsEtalon: Boolean);
begin
  Create(AHSCDevice, 0, AIsEtalon);
end;

constructor TFlowMeter.Create(AHSCDevice: THscDevice; AIsEtalon: Boolean; AHash: Integer);
begin
  Create(AHSCDevice, 0, AIsEtalon);
  Hash := AHash;
end;

constructor TFlowMeter.Create(AIsEtalon: Boolean);
begin
  Create(SHSC, 0, AIsEtalon);
end;

procedure TFlowMeter.CopyValues(const AEtalonMeter: TFlowMeter);
begin
  if AEtalonMeter = nil then
    Exit;
end;

destructor TFlowMeter.Destroy;
begin
  Points.Free;
  DataPoints.Free;
  UsedDataPoints.Free;
  CalibrPoints.Free;
  inherited;
end;

function TFlowMeter.GetChannel: Byte;
begin
  Result := FChannel;
end;

function TFlowMeter.GetSendStatus: string;
begin
  case SendStatus of
    1: Result := 'В процессе';
    2: Result := 'Отправлено';
  else
    Result := 'Не отправлено';
  end;
end;

function TFlowMeter.GetStatus: string;
begin
  case Status of
    1: Result := 'Есть ошибки';
    2: Result := 'Готов';
  else
    Result := 'Норма';
  end;
end;

procedure TFlowMeter.Init;
begin
  ResultValue := '-';
  MeterFlowType := mftWeightsType;
  FChannel := CHANNEL;

  Points := TList<TPoint>.Create;
  DataPoints := TList<TDataPoint>.Create;
  UsedDataPoints := TList<TDataPoint>.Create;
  CalibrPoints := TList<TCalibrPoint>.Create;
end;

procedure TFlowMeter.InitHashValues;
begin
  // TODO: перенести оригинальную C++ логику инициализации хэшей.
end;

procedure TFlowMeter.InitValues;
begin
  // TODO: перенести оригинальную C++ логику связывания Value*.
end;

procedure TFlowMeter.SetChannel(AChannel: Byte);
begin
  FChannel := AChannel;
end;

procedure TFlowMeter.SetCopy(AMeter: TFlowMeter);
begin
  if AMeter = nil then
    Exit;

  Hash := AMeter.Hash;
  DeviceHash := AMeter.DeviceHash;
  TypeHash := AMeter.TypeHash;
  OrderHash := AMeter.OrderHash;
  Kp := AMeter.Kp;
  FactoryKp := AMeter.FactoryKp;
end;

procedure TFlowMeter.SetFinalValues;
begin
  // TODO: перенести оригинальную C++ логику расчёта финальных значений.
end;

procedure TFlowMeter.SetHSC(AHSCDevice: THscDevice);
begin
  FHSCDevice := AHSCDevice;
  FHSC := AHSCDevice;
end;

procedure TFlowMeter.SetImpCoef(AK: Single);
begin
  SetImpCoef(Double(AK));
end;

function TFlowMeter.SetImpCoef(const AK: string): Boolean;
begin
  Result := TryStrToFloat(AK, Kp);
end;

procedure TFlowMeter.SetImpCoef(AK: Double);
begin
  Kp := AK;
end;

procedure TFlowMeter.SetMonitorValues;
begin
  // TODO: перенести оригинальную C++ логику значений мониторинга.
end;

procedure TFlowMeter.SetSendStatus(const AText: string);
begin
  if SameText(AText, 'Отправлено') then
    SendStatus := 2
  else if SameText(AText, 'В процессе') then
    SendStatus := 1
  else
    SendStatus := 0;
end;

procedure TFlowMeter.SetStatus(const AValue: string);
begin
  if SameText(AValue, 'Готов') then
    Status := 2
  else if SameText(AValue, 'Есть ошибки') then
    Status := 1
  else
    Status := 0;
end;

procedure TFlowMeter.SetType(AType: TFlowMeterType);
begin
  TypeMeter := AType;
end;

function TFlowMeter.SetType(ATypeHash: Integer): Boolean;
begin
  TypeHash := ATypeHash;
  Result := True;
end;

procedure TFlowMeter.SetValues;
begin
  InitHashValues;
  InitValues;
end;

initialization
  TFlowMeter.ActiveEtalonHash := 0;
  TFlowMeter.ActiveFlowMeterHash := 0;
  TFlowMeter.SignCipher := ' ';
  TFlowMeter.PorveritelFio := ' ';

  TFlowMeter.FlowMeters := TObjectList<TFlowMeter>.Create(False);
  TFlowMeter.Etalons := TObjectList<TFlowMeter>.Create(False);

  TFlowMeter.JArray := TJSONArray.Create;
  TFlowMeter.JObject := TJSONObject.Create;

finalization
  TFlowMeter.FlowMeters.Free;
  TFlowMeter.Etalons.Free;
  TFlowMeter.JArray.Free;
  TFlowMeter.JObject.Free;

end.
