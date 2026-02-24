unit UnitFlowMeter;

interface

uses
  UnitClasses,


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

  TMeterFlowType = (mftWeightsType, mftVolumeType);

  TFlowMeter = class;

{
  TFlowMeter – класс runtime-состояния прибора.
  -------------------------------------------------------------
  Данный класс НЕ является сущностью БД и не должен использоваться
  для хранения или изменения паспортных данных устройства.

  TFlowMeter описывает текущее состояние прибора в процессе работы:
  - текущий расход
  - температура
  - давление
  - измеренные значения (TMeterValue)
  - состояние канала / сигнала
  - временные флаги и служебные параметры

  Паспортные данные (тип, серийный номер, коэффициенты,
  точки проливки, межповерочный интервал и т.д.) хранятся
  в объекте TDevice, который загружается из репозитория.

  TFlowMeter должен содержать ссылку на соответствующий TDevice
  и использовать его как источник конфигурационных данных,
  но не дублировать их.

  Жизненный цикл:
  - создаётся каналом (TChannel) при инициализации стола
  - привязывается к TDevice после загрузки конфигурации
  - уничтожается вместе с каналом

  Таким образом:
  TDevice   → описание прибора (БД, конфигурация)
  TFlowMeter → текущее состояние прибора (runtime)
 }

TFlowMeter = class(TDevice)
private
  // =====================================================
  // == Связь с "базовым" устройством из БД
  // =====================================================
  FDevice: TDevice;

  FSerialNumber:  string;
  FUUID :  string;
  FDeviceTypeUUID:  string;
  FDeviceUUID:  string;
  FOutputType: Integer; // тип должен совпадать с типом OutputType в TDevice

  function GetDevice: TDevice;
  procedure SetDevice(const ADevice: TDevice);

  function GetDeviceUUID: string;
  procedure SetDeviceUUID(const ADevice: string);

  function GetDeviceTypeNameProxy: string;
  procedure SetDeviceTypeNameProxy(const AValue: string);

  function GetDeviceTypeUUIDProxy: string;
  procedure SetDeviceTypeUUIDProxy(const AValue: string);

  function GetSerialNumberProxy: string;
  procedure SetSerialNumberProxy(const AValue: string);

  function GetOutputTypeProxy: Integer;
  procedure SetOutputTypeProxy(const AValue: Integer);



private

  FChannel: Byte;
  FImpulses: array[0..99] of Word;
  FWrImp: Byte;
  FRdImp: Byte;
  FVolSum: Single;
  FImpSum: Single;

  procedure InitValues;
  procedure CopyValues(const AEtalonMeter: TFlowMeter);

public
  // =====================================================
  // == Прокси-свойства к устройству через FlowMeter
  // =====================================================
  property Device: TDevice read GetDevice write SetDevice;

  property DeviceUUID: string
    read GetDeviceUUID
    write SetDeviceUUID;

  // Имя типа прибора (берется из привязанного TDevice)
  property DeviceTypeName: string
    read GetDeviceTypeNameProxy
    write SetDeviceTypeNameProxy;

  property DeviceTypeUUID: string
    read GetDeviceTypeUUIDProxy
    write SetDeviceTypeUUIDProxy;

  // Серийный номер (берется из привязанного TDevice)
  property SerialNumber: string
    read GetSerialNumberProxy
    write SetSerialNumberProxy;

  property OutputType: Integer
    read GetOutputTypeProxy
    write SetOutputTypeProxy;

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

  class var ActiveFlowMeter: TFlowMeter;
  class var ActiveEtalon: TFlowMeter;
  class var EtalonMeter: TFlowMeter;

  UUID: string;
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

  constructor Create(); overload;
  constructor Create(AIsEtalon: Boolean); overload;
  destructor Destroy;

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

  procedure Init; overload;
  procedure Init(UUID: string); overload;
end;
implementation

{ TFlowMeter }



constructor TFlowMeter.Create();
begin
  inherited Create;
end;

constructor TFlowMeter.Create(AIsEtalon: Boolean);
begin
  inherited Create;
end;



{ ===================================================== }
{ == Связь с TDevice                                 == }
{ ===================================================== }

function TFlowMeter.GetDevice: TDevice;
begin
  Result := FDevice;
end;

procedure TFlowMeter.SetDevice(const ADevice: TDevice);
begin
  if FDevice = ADevice then
    Exit;

  FDevice := ADevice;

  // Если нужно хранить UUID устройства отдельно
  if Assigned(FDevice) then
  begin
    Self.UUID := FDevice.MitUUID;   // если у FlowMeter есть UUID
    FDeviceUUID:= ADevice.MitUUID;
  end;
end;


function TFlowMeter.GetDeviceUUID: string;
begin
 if Assigned(FDevice) then
   Result := FDevice.MitUUID
   else
   Result :=  FDeviceUUID;
end;

procedure TFlowMeter.SetDeviceUUID(const ADevice: string);
begin

  FDeviceUUID := ADevice;

   if Assigned(FDevice) then
    Exit;



end;

function TFlowMeter.GetOutputTypeProxy: Integer;
begin
  if Assigned(FDevice) then
    Result := FDevice.OutputType
  else
    Result := FOutputType;
end;

procedure TFlowMeter.SetOutputTypeProxy(const AValue: Integer);
begin
  if Assigned(FDevice) then
    FDevice.OutputType := AValue;

  FOutputType := AValue;
end;


{ ===================================================== }
{ == Прокси: Тип устройства                          == }
{ ===================================================== }

function TFlowMeter.GetDeviceTypeNameProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.DeviceTypeName
  else
    Result := '';
end;

procedure TFlowMeter.SetDeviceTypeNameProxy(const AValue: string);
begin
  if Assigned(FDevice) then
    FDevice.DeviceTypeName := AValue;
end;

function TFlowMeter.GetDeviceTypeUUIDProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.DeviceTypeUUID
  else
    Result := FDeviceTypeUUID;
end;

procedure TFlowMeter.SetDeviceTypeUUIDProxy(const AValue: string);
begin
  if Assigned(FDevice) then
    FDevice.DeviceTypeUUID := AValue
  else
   FDeviceTypeUUID := AValue;

end;


{ ===================================================== }
{ == Прокси: Серийный номер                          == }
{ ===================================================== }

function TFlowMeter.GetSerialNumberProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.SerialNumber
  else
    Result := FSerialNumber;
end;

procedure TFlowMeter.SetSerialNumberProxy(const AValue: string);
begin
  FSerialNumber :=  AValue;
  if Assigned(FDevice) then
    FDevice.SerialNumber := AValue;
end;





procedure TFlowMeter.CopyValues(const AEtalonMeter: TFlowMeter);
begin
  if AEtalonMeter = nil then
    Exit;
end;

destructor TFlowMeter.Destroy;
begin

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

end;

procedure TFlowMeter.Init(UUID: string);
begin
  ResultValue := '-';
  MeterFlowType := mftWeightsType;
  FChannel := CHANNEL;
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

  UUID := AMeter.UUID;
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
