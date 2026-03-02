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


  ValueImp: TMeterValue;
  ValueImpTotal: TMeterValue;
  ValueCoef: TMeterValue;
  ValueMassCoef: TMeterValue;
  ValueVolumeCoef: TMeterValue;

  ValueQuantity: TMeterValue;
  ValueVolume: TMeterValue;
  ValueMass: TMeterValue;


  ValueVolumeMeter: TMeterValue;
  ValueMassMeter: TMeterValue;

  ValueFlow: TMeterValue;
  ValueMassFlow: TMeterValue;
  ValueVolumeFlow: TMeterValue;


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
  HashValuePressure: string;
  HashValueTemperture: string;
  HashValueAirPressure: string;
  HashValueAirTemperture: string;
  HashValueHumidity: string;
  HashValueCurrent: string;
  HashValueTime: string;

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
  procedure SetValues;
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
  FOutputType :=  FDevice.OutputType;
  MeterFlowCategory := ResolveStdCategoryFromDevice;
  UpdateByDevice;

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
  MeterFlowCategory := mftUnknownType;
  FChannel := CHANNEL;

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
  FChannel := CHANNEL;

  if Assigned(Self.Device) then
    SetValues;
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
begin
  ValueTime := TMeterValue.GetExistedMeterValueBool(HashValueTime, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueTime.SetAsTime;

  ValuePressure := TMeterValue.GetExistedMeterValueBool(HashValuePressure, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValuePressure.SetAsPressure;

  ValueTemperture := TMeterValue.GetExistedMeterValueBool(HashValueTemperture, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueTemperture.SetAsTemp;

  ValueDensity := TMeterValue.GetExistedMeterValueBool(HashValueDensity, IsExisted, UUID, Name);
  if IsExisted = 0 then
  ValueDensity.SetAsDensity;
  ValueDensity.ValueBaseMultiplier := ValueTemperture;
  ValueDensity.ValueBaseDevider := ValuePressure;
  ValueDensity.ValueRate := nil;
  ValueDensity.ValueEtalon := nil;

  ValueAirPressure := TMeterValue.GetExistedMeterValueBool(HashValueAirPressure, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueAirPressure.SetAsAirPressure;
  ValueAirTemperture := TMeterValue.GetExistedMeterValueBool(HashValueAirTemperture, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueAirTemperture.SetAsAirTemp;
  ValueHumidity := TMeterValue.GetExistedMeterValueBool(HashValueHumidity, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueHumidity.SetAsHumidity;

  ValueImp := TMeterValue.GetExistedMeterValueBool(HashValueImp, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueImp.SetAsImp;

  ValueImpTotal := TMeterValue.GetExistedMeterValueBool(HashValueImpTotal, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueImpTotal.SetAsImp;

  ValueCoef := nil;
  if not HashValueCoef.IsEmpty then
    ValueCoef := TMeterValue.GetExistedMeterValueBool(HashValueCoef, IsExisted, UUID, Name);

  ValueVolumeCoef := TMeterValue.GetExistedMeterValueBool(HashValueVolumeCoef, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueVolumeCoef.SetValue(Kp);

  ValueMassCoef := TMeterValue.GetExistedMeterValueBool(HashValueMassCoef, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueMassCoef.SetValue(Kp);

  ValueMassFlow := TMeterValue.GetExistedMeterValueBool(HashValueMassFlow, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueMassFlow.SetAsMassFlow;
  ValueMassFlow.ValueCorrection := nil;
  ValueMassFlow.ValueBaseMultiplier := ValueImp;
  ValueMassFlow.ValueBaseDevider := ValueMassCoef;
  ValueMassFlow.ValueRate := nil;
  ValueMassFlow.ValueEtalon := nil;

  ValueVolumeFlow := TMeterValue.GetExistedMeterValueBool(HashValueVolumeFlow, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueVolumeFlow.SetAsVolumeFlow;
  ValueVolumeFlow.ValueCorrection := nil;
  ValueVolumeFlow.ValueBaseMultiplier := ValueImp;
  ValueVolumeFlow.ValueBaseDevider := ValueVolumeCoef;
  ValueVolumeFlow.ValueRate := nil;
  ValueVolumeFlow.ValueEtalon := nil;

  ValueVolume := TMeterValue.GetExistedMeterValueBool(HashValueVolume, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueVolume.SetAsVolume;
  ValueVolume.ValueCorrection := ValueVolumeFlow;
  ValueVolume.ValueBaseMultiplier := ValueImpTotal;
  ValueVolume.ValueBaseDevider := ValueVolumeCoef;
  ValueVolume.ValueRate := nil;
  ValueVolume.ValueEtalon := nil;

  ValueMass := TMeterValue.GetExistedMeterValueBool(HashValueMass, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueMass.SetAsMass;
  ValueMass.ValueCorrection := ValueMassFlow;
  ValueMass.ValueBaseMultiplier := ValueImpTotal;
  ValueMass.ValueBaseDevider := ValueMassCoef;
  ValueMass.ValueRate := nil;
  ValueMass.ValueEtalon := nil;

  ValueMassMeter := TMeterValue.GetExistedMeterValueBool(HashValueMassMeter, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueMassMeter.SetAsMass;

  ValueVolumeMeter := TMeterValue.GetExistedMeterValueBool(HashValueVolumeMeter, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueVolumeMeter.SetAsVolume;

  ValueVolumeError := TMeterValue.GetExistedMeterValueBool(HashValueVolumeError, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueVolumeError.SetAsError;
  if EtalonMeter <> nil then
    ValueVolumeError.ValueEtalon := EtalonMeter.ValueVolume;
  ValueVolumeError.ValueBaseMultiplier := ValueVolume;

  ValueMassError := TMeterValue.GetExistedMeterValueBool(HashValueMassError, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueMassError.SetAsError;
  if EtalonMeter <> nil then
    ValueMassError.ValueEtalon := EtalonMeter.ValueMass;
  ValueMassError.ValueBaseMultiplier := ValueMass;

  ValueError := TMeterValue.GetExistedMeterValueBool(HashValueError, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueError.SetAsError;
  if EtalonMeter <> nil then
    ValueError.ValueEtalon := EtalonMeter.ValueVolume;
  ValueError.ValueBaseMultiplier := ValueVolumeMeter;

  ValueCurrent := TMeterValue.GetExistedMeterValueBool(HashValueCurrent, IsExisted, UUID, Name);
  if IsExisted = 0 then
    ValueCurrent.SetAsCurrent;

  SetMeterCategory(MeterFlowCategory);

  if not IsEtalon then
  begin
    if ValueFlow <> nil then
      ValueFlow.Accuracy := 4;
    ValueImp.Accuracy := 0;
  end
  else if ValueFlow <> nil then
    ValueFlow.Accuracy := 4;
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
    ValueError.ValueEtalon := EtalonMeter.ValueVolume;

  ApplyMeasurementModel;
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
  SetChannel(3);
  Name := 'Etalon';
  IsEtalon := True;
  SetMeterCategory(mftMassFlowmeterType);
  SetImpCoef(100);
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
  UpdateByDevice;
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
