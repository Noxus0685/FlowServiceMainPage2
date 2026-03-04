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
  XMLVERFLOWMETERS = '5.0';

type
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

TFlowMeter = class(TTypeEntity)
private
  // =====================================================
  // == Связь с "базовым" устройством из БД
  // =====================================================
  FDevice: TDevice;

  FSerialNumber:  string;
  FDeviceTypeUUID:  string;
  FTypeName:  string;
  FDeviceUUID:  string;
  FRepoTypeName: string;
  FRepoTypeUUID: string;
  FRepoDeviceName: string;
  FRepoDeviceUUID: string;
  FOutputType: Integer; // тип должен совпадать с типом OutputType в TDevice

  FImpulses: array[0..99] of Word;
  FWrImp: Byte;
  FRdImp: Byte;
  FVolSum: Single;
  FImpSum: Single;

  FValueImp: TMeterValue;
  FValueImpTotal: TMeterValue;
  FValueCoef: TMeterValue;
  FValueMassCoef: TMeterValue;
  FValueVolumeCoef: TMeterValue;
  FValueQuantity: TMeterValue;
  FValueVolume: TMeterValue;
  FValueMass: TMeterValue;
  FValueVolumeMeter: TMeterValue;
  FValueMassMeter: TMeterValue;
  FValueFlow: TMeterValue;
  FValueMassFlow: TMeterValue;
  FValueVolumeFlow: TMeterValue;
  FValueError: TMeterValue;
  FValueVolumeError: TMeterValue;
  FValueMassError: TMeterValue;
  FValueDensity: TMeterValue;
  FValueTempertureBefore: TMeterValue;
  FValueTempertureAfter: TMeterValue;
  FValueTempertureDelta: TMeterValue;
  FValuePressureBefore: TMeterValue;
  FValuePressureAfter: TMeterValue;
  FValuePressureDelta: TMeterValue;
  FValueFlowRate: TMeterValue;
  FValuePressure: TMeterValue;
  FValueTemperture: TMeterValue;
  FValueAirPressure: TMeterValue;
  FValueAirTemperture: TMeterValue;
  FValueHumidity: TMeterValue;
  FValueCurrent: TMeterValue;
  FValueTime: TMeterValue;

  HashValueImp: string;
  HashValueImpTotal: string;
  HashValueCoef: string;
  HashValueMassCoef: string;
  HashValueVolumeCoef: string;
  HashValueVolume: string;
  HashValueMass: string;
  HashValueVolumeMeter: string;
  HashValueMassMeter: string;
  HashValueMassFlow: string;
  HashValueVolumeFlow: string;
  HashValueQuantity: string;
  HashValueFlow: string;
  HashValueError: string;
  HashValueVolumeError: string;
  HashValueMassError: string;
  HashValueDensity: string;
  HashValueTempertureBefore: string;
  HashValueTempertureAfter: string;
  HashValueTempertureDelta: string;
  HashValuePressureBefore: string;
  HashValuePressureAfter: string;
  HashValuePressureDelta: string;
  HashValueFlowRate: string;
  HashValuePressure: string;
  HashValueTemperture: string;
  HashValueAirPressure: string;
  HashValueAirTemperture: string;
  HashValueHumidity: string;
  HashValueCurrent: string;
  HashValueTime: string;

  function GetDevice: TDevice;
  procedure SetDevice(const ADevice: TDevice);

  function GetDeviceUUID: string;
  procedure SetDeviceUUID(const ADevice: string);

  function GetDeviceTypeNameProxy: string;
  procedure SetDeviceTypeNameProxy(const AValue: string);

  function GetDeviceTypeUUIDProxy: string;
  procedure SetDeviceTypeUUIDProxy(const AValue: string);

  function GetRepoTypeNameProxy: string;
  procedure SetRepoTypeNameProxy(const AValue: string);

  function GetRepoTypeUUIDProxy: string;
  procedure SetRepoTypeUUIDProxy(const AValue: string);

  function GetRepoDeviceNameProxy: string;
  procedure SetRepoDeviceNameProxy(const AValue: string);

  function GetRepoDeviceUUIDProxy: string;
  procedure SetRepoDeviceUUIDProxy(const AValue: string);

  function GetSerialNumberProxy: string;
  procedure SetSerialNumberProxy(const AValue: string);

  function GetOutputTypeProxy: Integer;
  procedure SetOutputTypeProxy(const AValue: Integer);

  procedure SetMeterValue(var ATarget: TMeterValue; var ATargetHash: string; const AValue: TMeterValue);

  function GetValueCoef: TMeterValue;
  function GetValueQuantity: TMeterValue;
  function GetValueFlow: TMeterValue;



  procedure SetValueImp(const AValue: TMeterValue);
  procedure SetValueImpTotal(const AValue: TMeterValue);
  procedure SetValueCoef(const AValue: TMeterValue);
  procedure SetValueMassCoef(const AValue: TMeterValue);
  procedure SetValueVolumeCoef(const AValue: TMeterValue);
  procedure SetValueQuantity(const AValue: TMeterValue);
  procedure SetValueVolume(const AValue: TMeterValue);
  procedure SetValueMass(const AValue: TMeterValue);
  procedure SetValueVolumeMeter(const AValue: TMeterValue);
  procedure SetValueMassMeter(const AValue: TMeterValue);
  procedure SetValueFlow(const AValue: TMeterValue);
  procedure SetValueMassFlow(const AValue: TMeterValue);
  procedure SetValueVolumeFlow(const AValue: TMeterValue);
  procedure SetValueError(const AValue: TMeterValue);
  procedure SetValueVolumeError(const AValue: TMeterValue);
  procedure SetValueMassError(const AValue: TMeterValue);
  procedure SetValueDensity(const AValue: TMeterValue);
  procedure SetValueTempertureBefore(const AValue: TMeterValue);
  procedure SetValueTempertureAfter(const AValue: TMeterValue);
  procedure SetValueTempertureDelta(const AValue: TMeterValue);
  procedure SetValuePressureBefore(const AValue: TMeterValue);
  procedure SetValuePressureAfter(const AValue: TMeterValue);
  procedure SetValuePressureDelta(const AValue: TMeterValue);
  procedure SetValueFlowRate(const AValue: TMeterValue);
  procedure SetValuePressure(const AValue: TMeterValue);
  procedure SetValueTemperture(const AValue: TMeterValue);
  procedure SetValueAirPressure(const AValue: TMeterValue);
  procedure SetValueAirTemperture(const AValue: TMeterValue);
  procedure SetValueHumidity(const AValue: TMeterValue);
  procedure SetValueCurrent(const AValue: TMeterValue);
  procedure SetValueTime(const AValue: TMeterValue);

  procedure InitValues;
  procedure ApplyMeasurementModel;
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

  property RepoTypeName: string
    read GetRepoTypeNameProxy
    write SetRepoTypeNameProxy;

  property RepoTypeUUID: string
    read GetRepoTypeUUIDProxy
    write SetRepoTypeUUIDProxy;

  property RepoDeviceName: string
    read GetRepoDeviceNameProxy
    write SetRepoDeviceNameProxy;

  property RepoDeviceUUID: string
    read GetRepoDeviceUUIDProxy
    write SetRepoDeviceUUIDProxy;

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

  MeterFlowCategory: TStdCategory;

  property ValueImp: TMeterValue read FValueImp write SetValueImp;
  property ValueImpTotal: TMeterValue read FValueImpTotal write SetValueImpTotal;
  property ValueCoef: TMeterValue read GetValueCoef write SetValueCoef;
  property ValueMassCoef: TMeterValue read FValueMassCoef write SetValueMassCoef;
  property ValueVolumeCoef: TMeterValue read FValueVolumeCoef write SetValueVolumeCoef;
  property ValueQuantity: TMeterValue read GetValueQuantity write SetValueQuantity;
  property ValueVolume: TMeterValue read FValueVolume write SetValueVolume;
  property ValueMass: TMeterValue read FValueMass write SetValueMass;
  property ValueVolumeMeter: TMeterValue read FValueVolumeMeter write SetValueVolumeMeter;
  property ValueMassMeter: TMeterValue read FValueMassMeter write SetValueMassMeter;
  property ValueFlow: TMeterValue read GetValueFlow write SetValueFlow;
  property ValueMassFlow: TMeterValue read FValueMassFlow write SetValueMassFlow;
  property ValueVolumeFlow: TMeterValue read FValueVolumeFlow write SetValueVolumeFlow;
  property ValueError: TMeterValue read FValueError write SetValueError;
  property ValueVolumeError: TMeterValue read FValueVolumeError write SetValueVolumeError;
  property ValueMassError: TMeterValue read FValueMassError write SetValueMassError;
  property ValueDensity: TMeterValue read FValueDensity write SetValueDensity;
  property ValueTempertureBefore: TMeterValue read FValueTempertureBefore write SetValueTempertureBefore;
  property ValueTempertureAfter: TMeterValue read FValueTempertureAfter write SetValueTempertureAfter;
  property ValueTempertureDelta: TMeterValue read FValueTempertureDelta write SetValueTempertureDelta;
  property ValuePressureBefore: TMeterValue read FValuePressureBefore write SetValuePressureBefore;
  property ValuePressureAfter: TMeterValue read FValuePressureAfter write SetValuePressureAfter;
  property ValuePressureDelta: TMeterValue read FValuePressureDelta write SetValuePressureDelta;
  property ValueFlowRate: TMeterValue read FValueFlowRate write SetValueFlowRate;
  property ValuePressure: TMeterValue read FValuePressure write SetValuePressure;
  property ValueTemperture: TMeterValue read FValueTemperture write SetValueTemperture;
  property ValueAirPressure: TMeterValue read FValueAirPressure write SetValueAirPressure;
  property ValueAirTemperture: TMeterValue read FValueAirTemperture write SetValueAirTemperture;
  property ValueHumidity: TMeterValue read FValueHumidity write SetValueHumidity;
  property ValueCurrent: TMeterValue read FValueCurrent write SetValueCurrent;
  property ValueTime: TMeterValue read FValueTime write SetValueTime;

  constructor Create(); overload;
  constructor Create(AIsEtalon: Boolean); overload;
  destructor Destroy;

  function SetType(ATypeHash: Integer): Boolean; overload;
  procedure SetCopy(AMeter: TFlowMeter);

  function GetStatus: string;
  procedure SetStatus(const AValue: string);
  function GetSendStatus: string;
  procedure SetSendStatus(const AText: string);

  procedure SetEtalon(AEtalon: TFlowMeter);
  procedure SetMeterCategory(AMeterFlowType: TStdCategory); overload;
  procedure SetMeterCategory(const AMeterFlowType: string); overload;
  function GetMeterCategory: string;
  function ResolveStdCategoryFromDevice: TStdCategory;
  procedure SetAsEtalon;

  procedure SetImpCoef(AK: Double); overload;
  procedure SetImpCoef(AK: Single); overload;
  function SetImpCoef(const AK: string): Boolean; overload;

  procedure InitHashValues;
  procedure InitAllValues;
  procedure UpdateByDevice;
  procedure RebindCalculatedValues;
  procedure SetMonitorValues;
  procedure SetFinalValues;
  procedure SetUpdateType(AType: EUpdateType);

  procedure Init; overload;
  procedure Init(UUID: string); overload;
end;
implementation

uses
  UnitDataManager,
  UnitRepositories;

{ TFlowMeter }



constructor TFlowMeter.Create();
begin
  inherited Create;
  UUID := '';
  DeviceHash := 0;
  TypeHash := 0;
  OrderHash := 0;

  IsEtalon := False;
  Active := 0;
  CheckType := 0;
  Status := 0;
  SendStatus := 0;

  FlowTypeName := '';
  DocNumber := '';
  Means := '';

  K1 := '';
  P1 := '';
  K2 := '';
  P2 := '';
  TempWater := '';
  Temperature := '';
  Pressure := '';
  Humidity := '';
  VrfDate := '';

  Data1 := '';
  Data2 := '';
  Data3 := '';
  Date1 := '';
  Date2 := '';

  ResultValue := '';
  MeterDateTime := 0;
  ModifiedDateTime := '';

  Kp := 0;
  FactoryKp := 0;
  FreqMax := 0;
  FlowMax := 0;
  FlowMin := 0;
  QuantityMax := 0;
  QuantityMin := 0;
  Error := 0;
  PointIndex := 0;
  Comment := '';

  HashValueImp := '';
  HashValueImpTotal := '';
  HashValueCoef := '';
  HashValueMassCoef := '';
  HashValueVolumeCoef := '';
  HashValueVolume := '';
  HashValueMass := '';
  HashValueVolumeMeter := '';
  HashValueMassMeter := '';
  HashValueMassFlow := '';
  HashValueVolumeFlow := '';
  HashValueQuantity := '';
  HashValueFlow := '';
  HashValueError := '';
  HashValueVolumeError := '';
  HashValueMassError := '';
  HashValueDensity := '';
  HashValueTempertureBefore := '';
  HashValueTempertureAfter := '';
  HashValueTempertureDelta := '';
  HashValuePressureBefore := '';
  HashValuePressureAfter := '';
  HashValuePressureDelta := '';
  HashValueFlowRate := '';
  HashValuePressure := '';
  HashValueTemperture := '';
  HashValueAirPressure := '';
  HashValueAirTemperture := '';
  HashValueHumidity := '';
  HashValueCurrent := '';
  HashValueTime := '';

  FValueImp := nil;
  FValueImpTotal := nil;
  FValueCoef := nil;
  FValueMassCoef := nil;
  FValueVolumeCoef := nil;
  FValueQuantity := nil;
  FValueVolume := nil;
  FValueMass := nil;
  FValueVolumeMeter := nil;
  FValueMassMeter := nil;
  FValueFlow := nil;
  FValueMassFlow := nil;
  FValueVolumeFlow := nil;
  FValueError := nil;
  FValueVolumeError := nil;
  FValueMassError := nil;
  FValueDensity := nil;
  FValueTempertureBefore := nil;
  FValueTempertureAfter := nil;
  FValueTempertureDelta := nil;
  FValuePressureBefore := nil;
  FValuePressureAfter := nil;
  FValuePressureDelta := nil;
  FValueFlowRate := nil;
  FValuePressure := nil;
  FValueTemperture := nil;
  FValueAirPressure := nil;
  FValueAirTemperture := nil;
  FValueHumidity := nil;
  FValueCurrent := nil;
  FValueTime := nil;

  FRepoTypeName := '';
  FRepoTypeUUID := '';
  FRepoDeviceName := '';
  FRepoDeviceUUID := '';

  MeterFlowCategory := mftUnknownType;
  Name:='Новое устройство';
  FlowMeters.Add(self);
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
   if Assigned(ADevice) then
 begin
   FDevice := ADevice;

  Self.UUID := FDevice.MitUUID;
  Self.Name := FDevice.Name;
  FDeviceUUID:= FDevice.MitUUID;
  FSerialNumber :=   FDevice.SerialNumber;
  FDeviceTypeUUID :=  FDevice.DeviceTypeUUID;
  FRepoTypeName := FDevice.RepoTypeName;
  FRepoTypeUUID := FDevice.RepoTypeUUID;
  FRepoDeviceName := FDevice.RepoDeviceName;
  FRepoDeviceUUID := FDevice.RepoDeviceUUID;
  FOutputType :=  FDevice.OutputType;
  MeterFlowCategory := ResolveStdCategoryFromDevice;
  UpdateByDevice;

 end;
end;

function TFlowMeter.GetRepoTypeNameProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.RepoTypeName
  else
    Result := FRepoTypeName;
end;

procedure TFlowMeter.SetRepoTypeNameProxy(const AValue: string);
begin
  FRepoTypeName := AValue;
  if Assigned(FDevice) then
    FDevice.RepoTypeName := AValue;
end;

function TFlowMeter.GetRepoTypeUUIDProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.RepoTypeUUID
  else
    Result := FRepoTypeUUID;
end;

procedure TFlowMeter.SetRepoTypeUUIDProxy(const AValue: string);
begin
  FRepoTypeUUID := AValue;
  if Assigned(FDevice) then
    FDevice.RepoTypeUUID := AValue;
end;

function TFlowMeter.GetRepoDeviceNameProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.RepoDeviceName
  else
    Result := FRepoDeviceName;
end;

procedure TFlowMeter.SetRepoDeviceNameProxy(const AValue: string);
begin
  FRepoDeviceName := AValue;
  if Assigned(FDevice) then
    FDevice.RepoDeviceName := AValue;
end;

function TFlowMeter.GetRepoDeviceUUIDProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.RepoDeviceUUID
  else
    Result := FRepoDeviceUUID;
end;

procedure TFlowMeter.SetRepoDeviceUUIDProxy(const AValue: string);
begin
  FRepoDeviceUUID := AValue;
  if Assigned(FDevice) then
    FDevice.RepoDeviceUUID := AValue;
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
  UpdateByDevice;
end;


{ ===================================================== }
{ == Прокси: Тип устройства                          == }
{ ===================================================== }

function TFlowMeter.GetDeviceTypeNameProxy: string;
begin
  if Assigned(FDevice) then
    Result := FDevice.DeviceTypeName
  else
    Result := FTypeName;
end;

procedure TFlowMeter.SetDeviceTypeNameProxy(const AValue: string);
begin
  FTypeName := AValue;
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



procedure TFlowMeter.SetMeterValue(var ATarget: TMeterValue; var ATargetHash: string; const AValue: TMeterValue);
begin
  if ATarget = AValue then
  begin
    if ATarget <> nil then
      ATargetHash := ATarget.Hash
    else
      ATargetHash := '';
    Exit;
  end;

  if ATarget <> nil then
  begin

    TMeterValue.RebindReferences(ATarget, AValue);

    if TMeterValue.GetMeterValues <> nil then
      TMeterValue.GetMeterValues.Remove(ATarget);
    ATarget.Free;
  end;

  ATarget := AValue;
  if ATarget <> nil then
    ATargetHash := ATarget.Hash
  else
    ATargetHash := '';
end;

function TFlowMeter.GetValueCoef: TMeterValue;
begin
  Result := TMeterValue.GetMeterValue(HashValueCoef);
end;

function TFlowMeter.GetValueQuantity: TMeterValue;
begin
  Result := TMeterValue.GetMeterValue(HashValueQuantity);
end;

function TFlowMeter.GetValueFlow: TMeterValue;
begin
  Result := TMeterValue.GetMeterValue(HashValueFlow);
end;

procedure TFlowMeter.SetValueImp(const AValue: TMeterValue);
begin
  SetMeterValue(FValueImp, HashValueImp, AValue);
end;

procedure TFlowMeter.SetValueImpTotal(const AValue: TMeterValue);
begin
  SetMeterValue(FValueImpTotal, HashValueImpTotal, AValue);
end;

procedure TFlowMeter.SetValueCoef(const AValue: TMeterValue);
begin
  if AValue <> nil then
    HashValueCoef := AValue.Hash
  else
    HashValueCoef := '';
end;

procedure TFlowMeter.SetValueMassCoef(const AValue: TMeterValue);
begin
  SetMeterValue(FValueMassCoef, HashValueMassCoef, AValue);
end;

procedure TFlowMeter.SetValueVolumeCoef(const AValue: TMeterValue);
begin
  SetMeterValue(FValueVolumeCoef, HashValueVolumeCoef, AValue);
end;

procedure TFlowMeter.SetValueQuantity(const AValue: TMeterValue);
begin
  if AValue <> nil then
    HashValueQuantity := AValue.Hash
  else
    HashValueQuantity := '';
end;

procedure TFlowMeter.SetValueVolume(const AValue: TMeterValue);
begin
  SetMeterValue(FValueVolume, HashValueVolume, AValue);
end;

procedure TFlowMeter.SetValueMass(const AValue: TMeterValue);
begin
  SetMeterValue(FValueMass, HashValueMass, AValue);
end;

procedure TFlowMeter.SetValueVolumeMeter(const AValue: TMeterValue);
begin
  SetMeterValue(FValueVolumeMeter, HashValueVolumeMeter, AValue);
end;

procedure TFlowMeter.SetValueMassMeter(const AValue: TMeterValue);
begin
  SetMeterValue(FValueMassMeter, HashValueMassMeter, AValue);
end;

procedure TFlowMeter.SetValueFlow(const AValue: TMeterValue);
begin
  if AValue <> nil then
    HashValueFlow := AValue.Hash
  else
    HashValueFlow := '';
end;

procedure TFlowMeter.SetValueMassFlow(const AValue: TMeterValue);
begin
  SetMeterValue(FValueMassFlow, HashValueMassFlow, AValue);
end;

procedure TFlowMeter.SetValueVolumeFlow(const AValue: TMeterValue);
begin
  SetMeterValue(FValueVolumeFlow, HashValueVolumeFlow, AValue);
end;

procedure TFlowMeter.SetValueError(const AValue: TMeterValue);
begin
  SetMeterValue(FValueError, HashValueError, AValue);
end;

procedure TFlowMeter.SetValueVolumeError(const AValue: TMeterValue);
begin
  SetMeterValue(FValueVolumeError, HashValueVolumeError, AValue);
end;

procedure TFlowMeter.SetValueMassError(const AValue: TMeterValue);
begin
  SetMeterValue(FValueMassError, HashValueMassError, AValue);
end;

procedure TFlowMeter.SetValueDensity(const AValue: TMeterValue);
begin
  SetMeterValue(FValueDensity, HashValueDensity, AValue);
end;

procedure TFlowMeter.SetValueTempertureBefore(const AValue: TMeterValue);
begin
  SetMeterValue(FValueTempertureBefore, HashValueTempertureBefore, AValue);
end;

procedure TFlowMeter.SetValueTempertureAfter(const AValue: TMeterValue);
begin
  SetMeterValue(FValueTempertureAfter, HashValueTempertureAfter, AValue);
end;

procedure TFlowMeter.SetValueTempertureDelta(const AValue: TMeterValue);
begin
  SetMeterValue(FValueTempertureDelta, HashValueTempertureDelta, AValue);
end;

procedure TFlowMeter.SetValuePressureBefore(const AValue: TMeterValue);
begin
  SetMeterValue(FValuePressureBefore, HashValuePressureBefore, AValue);
end;

procedure TFlowMeter.SetValuePressureAfter(const AValue: TMeterValue);
begin
  SetMeterValue(FValuePressureAfter, HashValuePressureAfter, AValue);
end;

procedure TFlowMeter.SetValuePressureDelta(const AValue: TMeterValue);
begin
  SetMeterValue(FValuePressureDelta, HashValuePressureDelta, AValue);
end;

procedure TFlowMeter.SetValueFlowRate(const AValue: TMeterValue);
begin
  SetMeterValue(FValueFlowRate, HashValueFlowRate, AValue);
end;

procedure TFlowMeter.SetValuePressure(const AValue: TMeterValue);
begin
  SetMeterValue(FValuePressure, HashValuePressure, AValue);
end;

procedure TFlowMeter.SetValueTemperture(const AValue: TMeterValue);
begin
  SetMeterValue(FValueTemperture, HashValueTemperture, AValue);
end;

procedure TFlowMeter.SetValueAirPressure(const AValue: TMeterValue);
begin
  SetMeterValue(FValueAirPressure, HashValueAirPressure, AValue);
end;

procedure TFlowMeter.SetValueAirTemperture(const AValue: TMeterValue);
begin
  SetMeterValue(FValueAirTemperture, HashValueAirTemperture, AValue);
end;

procedure TFlowMeter.SetValueHumidity(const AValue: TMeterValue);
begin
  SetMeterValue(FValueHumidity, HashValueHumidity, AValue);
end;

procedure TFlowMeter.SetValueCurrent(const AValue: TMeterValue);
begin
  SetMeterValue(FValueCurrent, HashValueCurrent, AValue);
end;

procedure TFlowMeter.SetValueTime(const AValue: TMeterValue);
begin
  SetMeterValue(FValueTime, HashValueTime, AValue);
end;




procedure TFlowMeter.CopyValues(const AEtalonMeter: TFlowMeter);
begin
  if AEtalonMeter = nil then
    Exit;
end;

destructor TFlowMeter.Destroy;
begin
  ValueImp := nil;
  ValueImpTotal := nil;
  ValueCoef := nil;
  ValueMassCoef := nil;
  ValueVolumeCoef := nil;
  ValueQuantity := nil;
  ValueVolume := nil;
  ValueMass := nil;
  ValueVolumeMeter := nil;
  ValueMassMeter := nil;
  ValueFlow := nil;
  ValueMassFlow := nil;
  ValueVolumeFlow := nil;
  ValueError := nil;
  ValueVolumeError := nil;
  ValueMassError := nil;
  ValueDensity := nil;
  ValueTempertureBefore := nil;
  ValueTempertureAfter := nil;
  ValueTempertureDelta := nil;
  ValuePressureBefore := nil;
  ValuePressureAfter := nil;
  ValuePressureDelta := nil;
  ValueFlowRate := nil;
  ValuePressure := nil;
  ValueTemperture := nil;
  ValueAirPressure := nil;
  ValueAirTemperture := nil;
  ValueHumidity := nil;
  ValueCurrent := nil;
  ValueTime := nil;

  inherited;
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
  MeterFlowCategory := mftUnknownType;

end;

procedure TFlowMeter.Init(UUID: string);
var
  FoundDevice: TDevice;
  FoundRepo: TDeviceRepository;
  SrcDevice: TDevice;
begin
  Self.DeviceUUID := UUID;

  if DataManager <> nil then
  begin
    FoundDevice := DataManager.FindDevice(Self.DeviceUUID, FoundRepo);

    if FoundDevice = nil then
    begin
      if DataManager.ActiveDeviceRepo <> nil then
      begin
        SrcDevice := TDevice.Create;
        try
          SrcDevice.MitUUID := Self.DeviceUUID;
          SrcDevice.SerialNumber := Self.SerialNumber;
          SrcDevice.DeviceTypeName := Self.DeviceTypeName;
          SrcDevice.DeviceTypeUUID := Self.DeviceTypeUUID;
          SrcDevice.RepoTypeName := Self.RepoTypeName;
          SrcDevice.RepoTypeUUID := Self.RepoTypeUUID;
          SrcDevice.RepoDeviceName := Self.RepoDeviceName;
          SrcDevice.RepoDeviceUUID := Self.RepoDeviceUUID;
          SrcDevice.OutputType := Self.OutputType;

          FoundDevice := DataManager.ActiveDeviceRepo.CreateDevice(SrcDevice);
        finally
          SrcDevice.Free;
        end;
      end;
    end;
    if FoundDevice <> nil then
      Self.Device := FoundDevice;
  end;

  ResultValue := '-';
  MeterFlowCategory := ResolveStdCategoryFromDevice;

 // if Assigned(Self.Device) then
    InitAllValues;
end;

procedure TFlowMeter.InitHashValues;
begin
  if ValueImp <> nil then
    HashValueImp := ValueImp.Hash;
  if ValueImpTotal <> nil then
    HashValueImpTotal := ValueImpTotal.Hash;
  if ValueCoef <> nil then
    HashValueCoef := ValueCoef.Hash;
  if ValueVolumeCoef <> nil then
    HashValueVolumeCoef := ValueVolumeCoef.Hash;
  if ValueMassCoef <> nil then
    HashValueMassCoef := ValueMassCoef.Hash;
  if ValueVolume <> nil then
    HashValueVolume := ValueVolume.Hash;
  if ValueMass <> nil then
    HashValueMass := ValueMass.Hash;
  if ValueVolumeFlow <> nil then
    HashValueVolumeFlow := ValueVolumeFlow.Hash;
  if ValueMassFlow <> nil then
    HashValueMassFlow := ValueMassFlow.Hash;
  if ValueVolumeMeter <> nil then
    HashValueVolumeMeter := ValueVolumeMeter.Hash;
  if ValueMassMeter <> nil then
    HashValueMassMeter := ValueMassMeter.Hash;
  if ValueError <> nil then
    HashValueError := ValueError.Hash;
  if ValueVolumeError <> nil then
    HashValueVolumeError := ValueVolumeError.Hash;
  if ValueMassError <> nil then
    HashValueMassError := ValueMassError.Hash;
  if ValueCurrent <> nil then
    HashValueCurrent := ValueCurrent.Hash;
  if ValueTime <> nil then
    HashValueTime := ValueTime.Hash;
end;

procedure TFlowMeter.InitValues;
var
  IsExisted: Integer;
  procedure SetDescription(AMeterValue: TMeterValue; const ADescription: string);
  begin
    if AMeterValue <> nil then
      AMeterValue.Description := ADescription;
  end;
begin
  ValueTime := TMeterValue.GetExistedMeterValueBool(HashValueTime, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueTime.SetAsTime;
    SetDescription(ValueTime, 'Время измерения');
  end;

  ValuePressure := TMeterValue.GetExistedMeterValueBool(HashValuePressure, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValuePressure.SetAsPressure;
    SetDescription(ValuePressure, 'Давление среды');
  end;

  ValueTemperture := TMeterValue.GetExistedMeterValueBool(HashValueTemperture, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueTemperture.SetAsTemp;
    SetDescription(ValueTemperture, 'Температура среды');
  end;

  ValueDensity := TMeterValue.GetExistedMeterValueBool(HashValueDensity, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueDensity.SetAsDensity;
    SetDescription(ValueDensity, 'Плотность среды');
  end;
  ValueDensity.ValueBaseMultiplier := ValueTemperture;
  ValueDensity.ValueBaseDevider := ValuePressure;
  ValueDensity.ValueRate := nil;
  ValueDensity.ValueEtalon := nil;

  ValueAirPressure := TMeterValue.GetExistedMeterValueBool(HashValueAirPressure, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueAirPressure.SetAsAirPressure;
    SetDescription(ValueAirPressure, 'Атмосферное давление');
  end;
  ValueAirTemperture := TMeterValue.GetExistedMeterValueBool(HashValueAirTemperture, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueAirTemperture.SetAsAirTemp;
    SetDescription(ValueAirTemperture, 'Температура воздуха');
  end;
  ValueHumidity := TMeterValue.GetExistedMeterValueBool(HashValueHumidity, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueHumidity.SetAsHumidity;
    SetDescription(ValueHumidity, 'Влажность воздуха');
  end;

  ValueImp := TMeterValue.GetExistedMeterValueBool(HashValueImp, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin

    SetDescription(ValueImp, 'Импульсы расходомера');
  end;
    ValueImp.SetAsImp;

  ValueImpTotal := TMeterValue.GetExistedMeterValueBool(HashValueImpTotal, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    SetDescription(ValueImpTotal, 'Суммарные импульсы');
  end;
    ValueImpTotal.SetAsImp;

  ValueVolumeCoef := TMeterValue.GetExistedMeterValueBool(HashValueVolumeCoef, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueVolumeCoef.SetAsVolumeCoef;
    SetDescription(ValueVolumeCoef, 'Коэффициент объема');
  end;
  ValueVolumeCoef.SetValue(1);

  ValueMassCoef := TMeterValue.GetExistedMeterValueBool(HashValueMassCoef, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueMassCoef.SetAsMassCoef;
    SetDescription(ValueMassCoef, 'Коэффициент массы');
  end;
  ValueMassCoef.SetValue(1);

  ValueMassFlow := TMeterValue.GetExistedMeterValueBool(HashValueMassFlow, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueMassFlow.SetAsMassFlow;
    SetDescription(ValueMassFlow, 'Массовый расход');
  end;
  ValueMassFlow.ValueCorrection := nil;
  ValueMassFlow.ValueBaseMultiplier := ValueImp;
  ValueMassFlow.ValueBaseDevider := ValueMassCoef;
  ValueMassFlow.ValueRate := nil;
  ValueMassFlow.ValueEtalon := nil;

  ValueVolumeFlow := TMeterValue.GetExistedMeterValueBool(HashValueVolumeFlow, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueVolumeFlow.SetAsVolumeFlow;
    SetDescription(ValueVolumeFlow, 'Объемный расход');
  end;
  ValueVolumeFlow.ValueCorrection := nil;
  ValueVolumeFlow.ValueBaseMultiplier := ValueImp;
  ValueVolumeFlow.ValueBaseDevider := ValueVolumeCoef;
  ValueVolumeFlow.ValueRate := nil;
  ValueVolumeFlow.ValueEtalon := nil;

  ValueVolume := TMeterValue.GetExistedMeterValueBool(HashValueVolume, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueVolume.SetAsVolume;
    SetDescription(ValueVolume, 'Объем');
  end;
  ValueVolume.ValueCorrection := ValueVolumeFlow;
  ValueVolume.ValueBaseMultiplier := ValueImpTotal;
  ValueVolume.ValueBaseDevider := ValueVolumeCoef;
  ValueVolume.ValueRate := nil;
  ValueVolume.ValueEtalon := nil;

  ValueMass := TMeterValue.GetExistedMeterValueBool(HashValueMass, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueMass.SetAsMass;
    SetDescription(ValueMass, 'Масса');
  end;
  ValueMass.ValueCorrection := ValueMassFlow;
  ValueMass.ValueBaseMultiplier := ValueImpTotal;
  ValueMass.ValueBaseDevider := ValueMassCoef;
  ValueMass.ValueRate := nil;
  ValueMass.ValueEtalon := nil;

  ValueMassMeter := TMeterValue.GetExistedMeterValueBool(HashValueMassMeter, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueMassMeter.SetAsMass;
    SetDescription(ValueMassMeter, 'Масса по прибору');
  end;

  ValueVolumeMeter := TMeterValue.GetExistedMeterValueBool(HashValueVolumeMeter, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueVolumeMeter.SetAsVolume;
    SetDescription(ValueVolumeMeter, 'Объем по прибору');
  end;

  ValueVolumeError := TMeterValue.GetExistedMeterValueBool(HashValueVolumeError, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueVolumeError.SetAsError;
    SetDescription(ValueVolumeError, 'Погрешность объема');
  end;
  if EtalonMeter <> nil then
    ValueVolumeError.ValueEtalon := EtalonMeter.ValueVolume;
  ValueVolumeError.ValueBaseMultiplier := ValueVolume;

  ValueMassError := TMeterValue.GetExistedMeterValueBool(HashValueMassError, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueMassError.SetAsError;
    SetDescription(ValueMassError, 'Погрешность массы');
  end;
  if EtalonMeter <> nil then
    ValueMassError.ValueEtalon := EtalonMeter.ValueMass;
  ValueMassError.ValueBaseMultiplier := ValueMass;

  ValueError := TMeterValue.GetExistedMeterValueBool(HashValueError, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueError.SetAsError;
    SetDescription(ValueError, 'Итоговая погрешность');
  end;
  if EtalonMeter <> nil then
    ValueError.ValueEtalon := EtalonMeter.ValueQuantity;
  ValueError.ValueBaseMultiplier := ValueQuantity;

  ValueCurrent := TMeterValue.GetExistedMeterValueBool(HashValueCurrent, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    ValueCurrent.SetAsCurrent;
    SetDescription(ValueCurrent, 'Токовый сигнал');
  end;

  SetMeterCategory(MeterFlowCategory);

  if not IsEtalon then
  begin
    if ValueFlow <> nil then
      ValueFlow.Accuracy := 4;
    ValueImp.Accuracy := 0;
  end
  else if ValueFlow <> nil then
    ValueFlow.Accuracy := 4;
        ValueImp.Accuracy := 0;
end;

procedure TFlowMeter.SetEtalon(AEtalon: TFlowMeter);
begin
  if AEtalon = nil then
    Exit;

  EtalonMeter := AEtalon;

  if ValueVolumeError <> nil then
    ValueVolumeError.ValueEtalon := EtalonMeter.ValueVolume;
  if ValueMassError <> nil then
    ValueMassError.ValueEtalon := EtalonMeter.ValueMass;
  if ValueError <> nil then
    ValueError.ValueEtalon := EtalonMeter.ValueQuantity;

  //ApplyMeasurementModel;
end;

procedure TFlowMeter.ApplyMeasurementModel;
var
  OutputKind: TOutputType;
  MeasuredKind: TMeasuredDimension;
  FlowSource: TMeterValue;
  TotalSource: TMeterValue;
  VoltageRange: Double;
  CurrentRange: Double;
  K: Double;
begin
  if (ValueMassCoef = nil) or (ValueVolumeCoef = nil) or
     (ValueMassFlow = nil) or (ValueVolumeFlow = nil) or
     (ValueMass = nil) or (ValueVolume = nil) then
    Exit;

  OutputKind := TOutputType(OutputType);
  MeasuredKind := mdUnknown;
  if Assigned(Device) then
    MeasuredKind := TMeasuredDimension(Device.MeasuredDimension);

  case MeasuredKind of
    mdMassFlow,
    mdMass:
      begin
        ValueVolumeCoef.ValueCorrection := nil;
        ValueVolumeCoef.ValueBaseMultiplier := ValueMassCoef;
        ValueVolumeCoef.ValueBaseDevider := nil;
        ValueVolumeCoef.ValueRate := ValueDensity;

        ValueMassCoef.ValueCorrection := nil;
        ValueMassCoef.ValueBaseMultiplier := nil;
        ValueMassCoef.ValueBaseDevider := nil;
        ValueMassCoef.ValueRate := nil;

        ValueMassCoef.DependenceType := INDEPENDENT;
        ValueVolumeCoef.DependenceType := DEPENDENT;

        ValueCoef := ValueMassCoef;
        ValueQuantity := ValueMass;
        ValueFlow := ValueMassFlow;
      end;
    mdUnknown,
    mdVolumeFlow,
    mdVolume:
      begin
        ValueMassCoef.ValueCorrection := nil;
        ValueMassCoef.ValueBaseMultiplier := ValueVolumeCoef;
        ValueMassCoef.ValueBaseDevider := ValueDensity;
        ValueMassCoef.ValueRate := nil;

        ValueVolumeCoef.ValueCorrection := nil;
        ValueVolumeCoef.ValueBaseMultiplier := nil;
        ValueVolumeCoef.ValueBaseDevider := nil;
        ValueVolumeCoef.ValueRate := nil;

        ValueMassCoef.DependenceType := DEPENDENT;
        ValueVolumeCoef.DependenceType := INDEPENDENT;

        ValueVolumeCoef.ValueType := CONST_TYPE;
        ValueMassCoef.ValueType := CONST_TYPE;

        ValueCoef := ValueVolumeCoef;
        ValueQuantity := ValueVolume;
        ValueFlow := ValueVolumeFlow;
      end;
    mdSpeed,
    mdHeat:
      begin
        // зарезервировано: используем модель объемного расходомера по умолчанию
        ValueMassCoef.ValueCorrection := nil;
        ValueMassCoef.ValueBaseMultiplier := ValueVolumeCoef;
        ValueMassCoef.ValueBaseDevider := ValueDensity;
        ValueMassCoef.ValueRate := nil;

        ValueVolumeCoef.ValueCorrection := nil;
        ValueVolumeCoef.ValueBaseMultiplier := nil;
        ValueVolumeCoef.ValueBaseDevider := nil;
        ValueVolumeCoef.ValueRate := nil;

        ValueMassCoef.DependenceType := DEPENDENT;
        ValueVolumeCoef.DependenceType := INDEPENDENT;

        ValueVolumeCoef.ValueType := CONST_TYPE;
        ValueMassCoef.ValueType := CONST_TYPE;

        ValueCoef := ValueVolumeCoef;
        ValueQuantity := ValueVolume;
        ValueFlow := ValueVolumeFlow;
      end;
  end;

  FlowSource := ValueImp;
  TotalSource := ValueImpTotal;

  case OutputKind of
    otUnknown,
    otFrequency,
    otImpulse:
      begin
        FlowSource := ValueImp;
        if Assigned(ValueCoef) and Assigned(Device) then
          ValueCoef.SetValue(Device.Coef);

          SetUpdateType(ONLINE_TYPE);

      end;
    otVoltage:
      begin
        FlowSource := ValueImp;
        VoltageRange := 24;
        if Assigned(Device) and (Device.VoltageRange > 0) then
          VoltageRange := Device.VoltageRange;

        K := 0;
        if Assigned(Device) and (VoltageRange <> 0) then
          K := (Device.VoltageQmaxRate - Device.VoltageQminRate) / VoltageRange;

        if Assigned(ValueCoef) then
          ValueCoef.SetValue(K);
      end;
    otCurrent:
      begin
        if Assigned(ValueCurrent) then
          FlowSource := ValueCurrent
        else
          FlowSource := ValueImp;

        CurrentRange := 16;
        if Assigned(Device) then
        begin
          if Device.CurrentRange = 20 then
            CurrentRange := 16
          else if Device.CurrentRange > 0 then
            CurrentRange := Device.CurrentRange;
        end;

        K := 0;
        if Assigned(Device) and (CurrentRange <> 0) then
          K := (Device.CurrentQmaxRate - Device.CurrentQminRate) / CurrentRange;

        if Assigned(ValueCoef) then
          ValueCoef.SetValue(K);

        if TotalSource = nil then
          TotalSource := FlowSource;
      end;
    otInterface,
    otVisual:
      begin
        FlowSource := ValueImp;
        if Assigned(ValueCoef) then
          ValueCoef.SetValue(1);
      end;
  end;

  if ValueMassFlow <> nil then
  begin
    ValueMassFlow.ValueCorrection := nil;
    ValueMassFlow.ValueBaseMultiplier := FlowSource;
    ValueMassFlow.ValueBaseDevider := ValueMassCoef;
    ValueMassFlow.ValueRate := nil;
  end;

  if ValueVolumeFlow <> nil then
  begin
    ValueVolumeFlow.ValueCorrection := nil;
    ValueVolumeFlow.ValueBaseMultiplier := FlowSource;
    ValueVolumeFlow.ValueBaseDevider := ValueVolumeCoef;
    ValueVolumeFlow.ValueRate := nil;
  end;

  if ValueMass <> nil then
  begin
    ValueMass.ValueCorrection := ValueMassFlow;
    ValueMass.ValueBaseMultiplier := TotalSource;
    ValueMass.ValueBaseDevider := ValueMassCoef;
    ValueMass.ValueRate := nil;
  end;

  if ValueVolume <> nil then
  begin
    ValueVolume.ValueCorrection := ValueVolumeFlow;
    ValueVolume.ValueBaseMultiplier := TotalSource;
    ValueVolume.ValueBaseDevider := ValueVolumeCoef;
    ValueVolume.ValueRate := nil;
  end;

  if ValueError <> nil then
  begin
    ValueError.ValueBaseMultiplier := ValueQuantity;
    if EtalonMeter <> nil then
      ValueError.ValueEtalon := EtalonMeter.ValueQuantity
    else
      ValueError.ValueEtalon := nil;
  end;

end;

procedure TFlowMeter.UpdateByDevice;
begin
  if not Assigned(Device) then
    Exit;

  if (ValueMassCoef = nil) or (ValueVolumeCoef = nil) or
     (ValueMassFlow = nil) or (ValueVolumeFlow = nil) or
     (ValueMass = nil) or (ValueVolume = nil) then
    Exit;

  ApplyMeasurementModel;
end;

function TFlowMeter.ResolveStdCategoryFromDevice: TStdCategory;
var
  Cat: TDeviceCategory;
begin
  Result := mftUnknownType;

  if not Assigned(Device) then
    Exit;

  if DataManager = nil then
    Exit;

  Cat := DataManager.FindCategoryByID(Device.Category);
  if Cat <> nil then
    Exit(Cat.StdCategory);
end;

procedure TFlowMeter.SetMeterCategory(AMeterFlowType: TStdCategory);
begin
  MeterFlowCategory := AMeterFlowType;

  if (ValueVolumeCoef = nil) or (ValueMassCoef = nil) or (ValueDensity = nil) or
     (ValueVolume = nil) or (ValueMass = nil) then
    Exit;

  case MeterFlowCategory of
    mftWeightsType,
    mftMassFlowmeterType:
      begin
        case MeterFlowCategory of
          mftWeightsType:
            FlowTypeName := 'Весовое устройство';
         else
          FlowTypeName := 'Массовый расходомер';
        end;

        ValueVolumeCoef.ValueCorrection := nil;
        ValueVolumeCoef.ValueBaseMultiplier := ValueMassCoef;
        ValueVolumeCoef.ValueBaseDevider := nil;
        ValueVolumeCoef.ValueRate := ValueDensity;

        ValueMassCoef.ValueCorrection := nil;
        ValueMassCoef.ValueBaseMultiplier := nil;
        ValueMassCoef.ValueBaseDevider := nil;
        ValueMassCoef.ValueRate := nil;

        ValueMassCoef.DependenceType := INDEPENDENT;
        ValueVolumeCoef.DependenceType := DEPENDENT;

        ValueCoef := ValueMassCoef;
        ValueQuantity := ValueMass;
        ValueFlow := ValueMassFlow;
      end;
    mftUnknownType,
    mftVolumeFlowmeterType,
    mftTankType:
      begin
        if MeterFlowCategory = mftVolumeFlowmeterType then
          FlowTypeName := 'Объемный расходомер'
        else
          FlowTypeName := 'Мерник';

        ValueMassCoef.ValueCorrection := nil;
        ValueMassCoef.ValueBaseMultiplier := ValueVolumeCoef;
        ValueMassCoef.ValueBaseDevider := ValueDensity;
        ValueMassCoef.ValueRate := nil;

        ValueVolumeCoef.ValueCorrection := nil;
        ValueVolumeCoef.ValueBaseMultiplier := nil;
        ValueVolumeCoef.ValueBaseDevider := nil;
        ValueVolumeCoef.ValueRate := nil;

        ValueMassCoef.DependenceType := DEPENDENT;
        ValueVolumeCoef.DependenceType := INDEPENDENT;

        ValueVolumeCoef.ValueType := CONST_TYPE;
        ValueMassCoef.ValueType := CONST_TYPE;

        ValueCoef := ValueVolumeCoef;
        ValueQuantity := ValueVolume;
        ValueFlow := ValueVolumeFlow;
      end;
  end;

  if ValueError <> nil then
  begin
    ValueError.ValueBaseMultiplier := ValueQuantity;
    if EtalonMeter <> nil then
      ValueError.ValueEtalon := EtalonMeter.ValueQuantity
    else
      ValueError.ValueEtalon := nil;
  end;

    SetUpdateType(ONLINE_TYPE);

end;

procedure TFlowMeter.SetMeterCategory(const AMeterFlowType: string);
begin
  if SameText(AMeterFlowType, 'Весовое устройство') then
    SetMeterCategory(mftWeightsType)
  else if SameText(AMeterFlowType, 'Массовый расходомер') then
    SetMeterCategory(mftMassFlowmeterType)
  else if SameText(AMeterFlowType, 'Объемный расходомер') then
    SetMeterCategory(mftVolumeFlowmeterType)
  else if SameText(AMeterFlowType, 'Мерник') then
    SetMeterCategory(mftTankType)
  else
    SetMeterCategory(mftUnknownType);
end;

function TFlowMeter.GetMeterCategory: string;
begin
  Result := FlowTypeName;
end;

procedure TFlowMeter.SetUpdateType(AType: EUpdateType);

  procedure ApplyUpdateType(AMeterValue: TMeterValue);
  begin
    if AMeterValue <> nil then
      AMeterValue.UpdateType := AType;
  end;

begin
  ApplyUpdateType(ValueTime);
  ApplyUpdateType(ValuePressure);
  ApplyUpdateType(ValueTemperture);
  ApplyUpdateType(ValueDensity);
  ApplyUpdateType(ValueAirPressure);
  ApplyUpdateType(ValueAirTemperture);
  ApplyUpdateType(ValueHumidity);

  ApplyUpdateType(ValueImp);
  ApplyUpdateType(ValueImpTotal);
  ApplyUpdateType(ValueCurrent);

  ApplyUpdateType(ValueCoef);
  ApplyUpdateType(ValueMassCoef);
  ApplyUpdateType(ValueVolumeCoef);

  ApplyUpdateType(ValueMassFlow);
  ApplyUpdateType(ValueVolumeFlow);
  ApplyUpdateType(ValueFlow);

  ApplyUpdateType(ValueMass);
  ApplyUpdateType(ValueVolume);
  ApplyUpdateType(ValueQuantity);
  ApplyUpdateType(ValueMassMeter);
  ApplyUpdateType(ValueVolumeMeter);

  ApplyUpdateType(ValueError);
  ApplyUpdateType(ValueMassError);
  ApplyUpdateType(ValueVolumeError);
end;

procedure TFlowMeter.SetAsEtalon;
begin
  Name := 'Etalon';
  IsEtalon := True;
  SetMeterCategory(mftMassFlowmeterType);
  SetImpCoef(100);
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

procedure TFlowMeter.InitAllValues;
begin
   // InitHashValues;
  InitValues;
  ApplyMeasurementModel;
end;

procedure TFlowMeter.RebindCalculatedValues;
begin
  ApplyMeasurementModel;
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
