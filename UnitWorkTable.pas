unit UnitWorkTable;

interface

uses

  UnitFlowMeter,
  UnitMeterValue,
  UnitClasses,
  UnitDataManager,
  System.SysUtils,
  System.IniFiles,
  System.Generics.Collections;

type
  TSpillState = (
    ssNone,
    ssReady,
    ssStarting,
    ssOnGoing,
    ssStopping,
    ssResultReady
  );

  TChannel = class(TTypeEntity)
  private
    FEnabled: Boolean;

    // Çíà÷åíèÿ êàíàëà (ÍÅ ïðîêñè)
    FImpSec: Double;
    FImpResult: Double;
    FCurSec: Double;
    FCurResult: Double;
    FValueSec: Double;
    FValueResult: Double;

    FFlowMeter: TFlowMeter;
    FValueImp: TMeterValue;
    FValueImpTotal: TMeterValue;
    FValueCurrent: TMeterValue;
    FValueInterface: TMeterValue;

    FHashValueImp: string;
    FHashValueImpTotal: string;
    FHashValueCurrent: string;
    FHashValueInterface: string;

    // --- ïðîêñè ê FlowMeter ---
    function GetTypeNameProxy: string;
    procedure SetTypeNameProxy(const AValue: string);

    function GetSerialProxy: string;
    procedure SetSerialProxy(const AValue: string);

    function GetSignalProxy: Integer;
    procedure SetSignalProxy(const AValue: Integer);

    function GetDeviceUUIDProxy: string;
    procedure SetDeviceUUIDProxy(const AValue: string);

    procedure Init;

    // --- îáû÷íûå ãåòòåðû/ñåòòåðû ê ïåðåìåííûì êàíàëà ---
    function GetImpSecProxy: Double;
    procedure SetImpSecProxy(const AValue: Double);

    function GetImpResultProxy: Double;
    procedure SetImpResultProxy(const AValue: Double);

    function GetCurSecProxy: Double;
    procedure SetCurSecProxy(const AValue: Double);

    function GetCurResultProxy: Double;
    procedure SetCurResultProxy(const AValue: Double);

    function GetValueSecProxy: Double;
    procedure SetValueSecProxy(const AValue: Double);

    function GetValueResultProxy: Double;
    procedure SetValueResultProxy(const AValue: Double);

  public
    constructor Create; override;
    destructor Destroy; override;

    property UUID: string read FMitUUID write FMitUUID;

    property FlowMeter: TFlowMeter read FFlowMeter;

    property Enabled: Boolean read FEnabled write FEnabled;
    property Name: string read FName write FName;

    // Ïðîêñè-ïîëÿ (äóáëèðóþò FlowMeter)
    property TypeName: string read GetTypeNameProxy write SetTypeNameProxy;
    property Serial: string read GetSerialProxy write SetSerialProxy;
    property Signal: Integer read GetSignalProxy write SetSignalProxy;
    property DeviceUUID: string read GetDeviceUUIDProxy write SetDeviceUUIDProxy;

    // Ïîëÿ êàíàëà (âíóòðåííèå ïåðåìåííûå)
    property ImpSec: Double read GetImpSecProxy write SetImpSecProxy;
    property ImpResult: Double read GetImpResultProxy write SetImpResultProxy;
    property CurSec: Double read GetCurSecProxy write SetCurSecProxy;
    property CurResult: Double read GetCurResultProxy write SetCurResultProxy;
    property ValueSec: Double read GetValueSecProxy write SetValueSecProxy;
    property ValueResult: Double read GetValueResultProxy write SetValueResultProxy;

    property ValueImp: TMeterValue read FValueImp;
    property ValueImpTotal: TMeterValue read FValueImpTotal;
    property ValueCurrent: TMeterValue read FValueCurrent;
    property ValueInterface: TMeterValue read FValueInterface;
  end;

  TWorkTable = class
  private
    FID: Integer;
    FName: string;

    FDeviceChannels: TObjectList<TChannel>;
    FEtalonChannels: TObjectList<TChannel>;

    FTemp: Double;
    FTempDelta: Double;
    FPress: Double;
    FPressDelta: Double;
    FFlowRate: Double;
    FTime: Double;
    FTimeResult: Double;
    FState: TSpillState;
    FTableClamped: Boolean;

    FValueTempertureBefore: TMeterValue;
    FValueTempertureAfter: TMeterValue;
    FValueTempertureDelta: TMeterValue;
    FValuePressureBefore: TMeterValue;
    FValuePressureAfter: TMeterValue;
    FValuePressureDelta: TMeterValue;
    FValueAirPressure: TMeterValue;
    FValueAirTemperture: TMeterValue;
    FValueHumidity: TMeterValue;

    FHashValueTempertureBefore: string;
    FHashValueTempertureAfter: string;
    FHashValueTempertureDelta: string;
    FHashValuePressureBefore: string;
    FHashValuePressureAfter: string;
    FHashValuePressureDelta: string;
    FHashValueAirPressure: string;
    FHashValueAirTemperture: string;
    FHashValueHumidity: string;

    procedure InitMeterValues;

    class function SpillStateToString(AState: TSpillState): string; static;
    class function SpillStateFromString(const AValue: string): TSpillState; static;

    class procedure SaveChannelList(
      AIni: TIniFile;
      const ASectionPrefix: string;
      AChannels: TObjectList<TChannel>
    ); static;

    class procedure LoadChannelList(
      AIni: TIniFile;
      const ASectionPrefix: string;
      AChannels: TObjectList<TChannel>
    ); static;

  public
    constructor Create;
    destructor Destroy; override;

    function AddDeviceChannel: TChannel; overload;
    function AddDeviceChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
        ATypeName, ASerial, ADeviceUUID: string): TChannel; overload;

    function AddEtalonChannel: TChannel; overload;
    function AddEtalonChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
       ATypeName, ASerial, ADeviceUUID: string): TChannel;  overload;

    class procedure Save(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

    class procedure Load(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

    property ID: Integer read FID write FID;
    property Name: string read FName write FName;

    property DeviceChannels: TObjectList<TChannel> read FDeviceChannels;
    property EtalonChannels: TObjectList<TChannel> read FEtalonChannels;

    property Temp: Double read FTemp write FTemp;
    property TempDelta: Double read FTempDelta write FTempDelta;
    property Press: Double read FPress write FPress;
    property PressDelta: Double read FPressDelta write FPressDelta;
    property FlowRate: Double read FFlowRate write FFlowRate;

    property Time: Double read FTime write FTime;
    property TimeResult: Double read FTimeResult write FTimeResult;

    property State: TSpillState read FState write FState;
    property TableClamped: Boolean read FTableClamped write FTableClamped;

    property ValueTempertureBefore: TMeterValue read FValueTempertureBefore;
    property ValueTempertureAfter: TMeterValue read FValueTempertureAfter;
    property ValueTempertureDelta: TMeterValue read FValueTempertureDelta;
    property ValuePressureBefore: TMeterValue read FValuePressureBefore;
    property ValuePressureAfter: TMeterValue read FValuePressureAfter;
    property ValuePressureDelta: TMeterValue read FValuePressureDelta;
    property ValueAirPressure: TMeterValue read FValueAirPressure;
    property ValueAirTemperture: TMeterValue read FValueAirTemperture;
    property ValueHumidity: TMeterValue read FValueHumidity;
  end;

  TWorkTableManager = class
  private
    FIniFileName: string;
    FWorkTables: TObjectList<TWorkTable>;
    FActiveWorkTable  :TWorkTable;
  public
    constructor Create(const AIniFileName: string);
    destructor Destroy; override;

    procedure Load;
    procedure Save;

    property WorkTables: TObjectList<TWorkTable> read FWorkTables;
    property IniFileName: string read FIniFileName write FIniFileName;
  end;

implementation


  {$REGION 'TChannel'}
constructor TChannel.Create;
var
  IsExisted: Integer;
begin
  inherited Create;

  FFlowMeter := TFlowMeter.Create;

  FEnabled := True;

  FImpSec := 0;
  FImpResult := 0;
  FCurSec := 0;
  FCurResult := 0;
  FValueSec := 0;
  FValueResult := 0;

  FValueImp := TMeterValue.GetExistedMeterValueBool(FHashValueImp, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueImp.SetAsImp;
    FValueImp.DependenceType := INDEPENDENT;
    FValueImp.UpdateType := ONLINE_TYPE;
  end;
  FValueImp.SetToSave(True);

  FValueImpTotal := TMeterValue.GetExistedMeterValueBool(FHashValueImpTotal, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueImpTotal.SetAsImp;
    FValueImpTotal.DependenceType := INDEPENDENT;
    FValueImpTotal.UpdateType := ONLINE_TYPE;
  end;
  FValueImpTotal.SetToSave(True);

  FValueCurrent := TMeterValue.GetExistedMeterValueBool(FHashValueCurrent, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueCurrent.SetAsCurrent;
    FValueCurrent.DependenceType := INDEPENDENT;
    FValueCurrent.UpdateType := ONLINE_TYPE;
  end;
  FValueCurrent.SetToSave(True);

  FValueInterface := TMeterValue.GetExistedMeterValueBool(FHashValueInterface, IsExisted, UUID, Name);
  FValueInterface.SetToSave(True);
end;

destructor TChannel.Destroy;
begin
  FreeAndNil(FFlowMeter);
  inherited Destroy;
end;

procedure TChannel.Init;
begin
  if not Assigned(FFlowMeter) then
    Exit;

  if DataManager = nil then
    Exit;

  FFlowMeter.Init(DeviceUUID);
end;

// =====================================================
// == Proxy: FlowMeter ïîëÿ
// =====================================================

function TChannel.GetTypeNameProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.DeviceTypeName
  else
    Result := '';
end;

procedure TChannel.SetTypeNameProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.DeviceTypeName := AValue;
end;

function TChannel.GetSerialProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.SerialNumber
  else
    Result := '';
end;

procedure TChannel.SetSerialProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.SerialNumber := AValue;
end;

function TChannel.GetSignalProxy: Integer;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.OutputType
  else
    Result := -1;
end;

procedure TChannel.SetSignalProxy(const AValue: Integer);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.OutputType := AValue;
end;

function TChannel.GetDeviceUUIDProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.DeviceUUID
  else
    Result := '';
end;

procedure TChannel.SetDeviceUUIDProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.DeviceUUID := AValue;
end;

// =====================================================
// == Proxy: âíóòðåííèå ïåðåìåííûå êàíàëà
// =====================================================

function TChannel.GetImpSecProxy: Double;
begin
  Result := FImpSec;
end;

procedure TChannel.SetImpSecProxy(const AValue: Double);
begin
  FImpSec := AValue;
end;

function TChannel.GetImpResultProxy: Double;
begin
  Result := FImpResult;
end;

procedure TChannel.SetImpResultProxy(const AValue: Double);
begin
  FImpResult := AValue;
end;

function TChannel.GetCurSecProxy: Double;
begin
  Result := FCurSec;
end;

procedure TChannel.SetCurSecProxy(const AValue: Double);
begin
  FCurSec := AValue;
end;

function TChannel.GetCurResultProxy: Double;
begin
  Result := FCurResult;
end;

procedure TChannel.SetCurResultProxy(const AValue: Double);
begin
  FCurResult := AValue;
end;

function TChannel.GetValueSecProxy: Double;
begin
  Result := FValueSec;
end;

procedure TChannel.SetValueSecProxy(const AValue: Double);
begin
  FValueSec := AValue;
end;

function TChannel.GetValueResultProxy: Double;
begin
  Result := FValueResult;
end;

procedure TChannel.SetValueResultProxy(const AValue: Double);
begin
  FValueResult := AValue;
end;
    {$ENDREGION}

  {$REGION 'TWorkTable'}
constructor TWorkTable.Create;
begin
  inherited Create;

  FDeviceChannels := TObjectList<TChannel>.Create(True);
  FEtalonChannels := TObjectList<TChannel>.Create(True);

  FState := ssNone;
  FTableClamped := False;
  InitMeterValues;
end;

procedure TWorkTable.InitMeterValues;
var
  IsExisted: Integer;
begin
  FValueTempertureBefore := TMeterValue.GetExistedMeterValueBool(FHashValueTempertureBefore, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValueTempertureBefore.SetAsTemp;
    FValueTempertureBefore.DependenceType := INDEPENDENT;
    FValueTempertureBefore.UpdateType := ONLINE_TYPE;
  end;
  FValueTempertureBefore.SetToSave(True);

  FValueTempertureAfter := TMeterValue.GetExistedMeterValueBool(FHashValueTempertureAfter, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValueTempertureAfter.SetAsTemp;
    FValueTempertureAfter.DependenceType := INDEPENDENT;
    FValueTempertureAfter.UpdateType := ONLINE_TYPE;
  end;
  FValueTempertureAfter.SetToSave(True);

  FValueTempertureDelta := TMeterValue.GetExistedMeterValueBool(FHashValueTempertureDelta, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValueTempertureDelta.SetAsError;
    FValueTempertureDelta.DependenceType := INDEPENDENT;
    FValueTempertureDelta.UpdateType := ONLINE_TYPE;
  end;
  FValueTempertureDelta.SetToSave(True);

  FValuePressureBefore := TMeterValue.GetExistedMeterValueBool(FHashValuePressureBefore, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValuePressureBefore.SetAsPressure;
    FValuePressureBefore.DependenceType := INDEPENDENT;
    FValuePressureBefore.UpdateType := ONLINE_TYPE;
  end;
  FValuePressureBefore.SetToSave(True);

  FValuePressureAfter := TMeterValue.GetExistedMeterValueBool(FHashValuePressureAfter, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValuePressureAfter.SetAsPressure;
    FValuePressureAfter.DependenceType := INDEPENDENT;
    FValuePressureAfter.UpdateType := ONLINE_TYPE;
  end;
  FValuePressureAfter.SetToSave(True);

  FValuePressureDelta := TMeterValue.GetExistedMeterValueBool(FHashValuePressureDelta, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValuePressureDelta.SetAsError;
    FValuePressureDelta.DependenceType := INDEPENDENT;
    FValuePressureDelta.UpdateType := ONLINE_TYPE;
  end;
  FValuePressureDelta.SetToSave(True);

  FValueAirPressure := TMeterValue.GetExistedMeterValueBool(FHashValueAirPressure, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValueAirPressure.SetAsAirPressure;
    FValueAirPressure.DependenceType := INDEPENDENT;
    FValueAirPressure.UpdateType := ONLINE_TYPE;
  end;
  FValueAirPressure.SetToSave(True);

  FValueAirTemperture := TMeterValue.GetExistedMeterValueBool(FHashValueAirTemperture, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValueAirTemperture.SetAsAirTemp;
    FValueAirTemperture.DependenceType := INDEPENDENT;
    FValueAirTemperture.UpdateType := ONLINE_TYPE;
  end;
  FValueAirTemperture.SetToSave(True);

  FValueHumidity := TMeterValue.GetExistedMeterValueBool(FHashValueHumidity, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FValueHumidity.SetAsHumidity;
    FValueHumidity.DependenceType := INDEPENDENT;
    FValueHumidity.UpdateType := ONLINE_TYPE;
  end;
  FValueHumidity.SetToSave(True);
end;

destructor TWorkTable.Destroy;
begin
  FDeviceChannels.Free;
  FEtalonChannels.Free;
  inherited;
end;

function TWorkTable.AddDeviceChannel: TChannel;
begin
  Result := TChannel.Create;
  FDeviceChannels.Add(Result);
end;

function TWorkTable.AddDeviceChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
  ATypeName, ASerial, ADeviceUUID: string): TChannel;
begin
  Result := AddDeviceChannel;
  Result.Enabled := AEnabled;
  Result.Name := AName;
  Result.TypeName := ATypeName;
  Result.Serial := ASerial;
  Result.Signal := ASignal;
  Result.DeviceUUID := ADeviceUUID;
  Result.Init;
end;

function TWorkTable.AddEtalonChannel: TChannel;
begin
  Result := TChannel.Create;
  FEtalonChannels.Add(Result);
end;

function TWorkTable.AddEtalonChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
  ATypeName, ASerial, ADeviceUUID: string): TChannel;
begin
  Result := AddEtalonChannel;
  Result.Enabled := AEnabled;
  Result.Name := AName;
  Result.TypeName := ATypeName;
  Result.Serial := ASerial;
  Result.Signal := ASignal;
  Result.DeviceUUID := ADeviceUUID;
  Result.Init;
end;

class procedure TWorkTable.Save(const AIniFileName: string;
  AWorkTables: TObjectList<TWorkTable>);
var
  Ini: TIniFile;
  ValuesIni: TIniFile;
  I: Integer;
  WorkTable: TWorkTable;
  Section: string;
  WorkTableValuesFileName: string;
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  Ini := TIniFile.Create(AIniFileName);
  WorkTableValuesFileName := IncludeTrailingPathDelimiter(ExtractFilePath(AIniFileName)) + 'WorkTableValues.ini';
  ValuesIni := TIniFile.Create(WorkTableValuesFileName);
  try
    Ini.EraseSection('WorkTables');
    Ini.WriteInteger('WorkTables', 'Count', AWorkTables.Count);

    for I := 0 to AWorkTables.Count - 1 do
    begin
      WorkTable := AWorkTables[I];
      Section := 'WorkTable.' + IntToStr(I);

      Ini.EraseSection(Section);
      Ini.WriteInteger(Section, 'ID', WorkTable.ID);
      Ini.WriteString(Section, 'Name', WorkTable.Name);
      Ini.WriteFloat(Section, 'Temp', WorkTable.Temp);
      Ini.WriteFloat(Section, 'TempDelta', WorkTable.TempDelta);
      Ini.WriteFloat(Section, 'Press', WorkTable.Press);
      Ini.WriteFloat(Section, 'PressDelta', WorkTable.PressDelta);
      Ini.WriteFloat(Section, 'FlowRate', WorkTable.FlowRate);
      Ini.WriteFloat(Section, 'Time', WorkTable.Time);
      Ini.WriteFloat(Section, 'TimeResult', WorkTable.TimeResult);
      Ini.WriteString(Section, 'State', SpillStateToString(WorkTable.State));
      Ini.WriteBool(Section, 'TableClamped', WorkTable.TableClamped);

      ValuesIni.EraseSection(Section);
      ValuesIni.WriteString(Section, 'HashValueTempertureBefore', WorkTable.ValueTempertureBefore.Hash);
      ValuesIni.WriteString(Section, 'HashValueTempertureAfter', WorkTable.ValueTempertureAfter.Hash);
      ValuesIni.WriteString(Section, 'HashValueTempertureDelta', WorkTable.ValueTempertureDelta.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressureBefore', WorkTable.ValuePressureBefore.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressureAfter', WorkTable.ValuePressureAfter.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressureDelta', WorkTable.ValuePressureDelta.Hash);
      ValuesIni.WriteString(Section, 'HashValueAirPressure', WorkTable.ValueAirPressure.Hash);
      ValuesIni.WriteString(Section, 'HashValueAirTemperture', WorkTable.ValueAirTemperture.Hash);
      ValuesIni.WriteString(Section, 'HashValueHumidity', WorkTable.ValueHumidity.Hash);

      ValuesIni.WriteFloat(Section, 'ValueTempertureBefore', WorkTable.ValueTempertureBefore.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueTempertureAfter', WorkTable.ValueTempertureAfter.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueTempertureDelta', WorkTable.ValueTempertureDelta.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressureBefore', WorkTable.ValuePressureBefore.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressureAfter', WorkTable.ValuePressureAfter.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressureDelta', WorkTable.ValuePressureDelta.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueAirPressure', WorkTable.ValueAirPressure.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueAirTemperture', WorkTable.ValueAirTemperture.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueHumidity', WorkTable.ValueHumidity.GetDoubleValue);

      SaveChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      SaveChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);
    end;
  finally
    ValuesIni.Free;
    Ini.Free;
  end;
end;

class procedure TWorkTable.Load(const AIniFileName: string;
  AWorkTables: TObjectList<TWorkTable>);
var
  Ini: TIniFile;
  ValuesIni: TIniFile;
  Count, I: Integer;
  WorkTable: TWorkTable;
  Section: string;
  WorkTableValuesFileName: string;
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  if not FileExists(AIniFileName) then
    Exit;

  AWorkTables.Clear;

  Ini := TIniFile.Create(AIniFileName);
  WorkTableValuesFileName := IncludeTrailingPathDelimiter(ExtractFilePath(AIniFileName)) + 'WorkTableValues.ini';
  ValuesIni := TIniFile.Create(WorkTableValuesFileName);
  try
    Count := Ini.ReadInteger('WorkTables', 'Count', 0);

    for I := 0 to Count - 1 do
    begin
      Section := 'WorkTable.' + IntToStr(I);
      WorkTable := TWorkTable.Create;

      WorkTable.ID := Ini.ReadInteger(Section, 'ID', I + 1);
      WorkTable.Name := Ini.ReadString(Section, 'Name', '');
      WorkTable.Temp := Ini.ReadFloat(Section, 'Temp', 0);
      WorkTable.TempDelta := Ini.ReadFloat(Section, 'TempDelta', 0);
      WorkTable.Press := Ini.ReadFloat(Section, 'Press', 0);
      WorkTable.PressDelta := Ini.ReadFloat(Section, 'PressDelta', 0);
      WorkTable.FlowRate := Ini.ReadFloat(Section, 'FlowRate', 0);
      WorkTable.Time := Ini.ReadFloat(Section, 'Time', 0);
      WorkTable.TimeResult := Ini.ReadFloat(Section, 'TimeResult', 0);
      WorkTable.State := SpillStateFromString(
        Ini.ReadString(Section, 'State', 'None')
      );
      WorkTable.TableClamped := Ini.ReadBool(Section, 'TableClamped', False);

      WorkTable.FHashValueTempertureBefore := ValuesIni.ReadString(Section, 'HashValueTempertureBefore', WorkTable.FHashValueTempertureBefore);
      WorkTable.FHashValueTempertureAfter := ValuesIni.ReadString(Section, 'HashValueTempertureAfter', WorkTable.FHashValueTempertureAfter);
      WorkTable.FHashValueTempertureDelta := ValuesIni.ReadString(Section, 'HashValueTempertureDelta', WorkTable.FHashValueTempertureDelta);
      WorkTable.FHashValuePressureBefore := ValuesIni.ReadString(Section, 'HashValuePressureBefore', WorkTable.FHashValuePressureBefore);
      WorkTable.FHashValuePressureAfter := ValuesIni.ReadString(Section, 'HashValuePressureAfter', WorkTable.FHashValuePressureAfter);
      WorkTable.FHashValuePressureDelta := ValuesIni.ReadString(Section, 'HashValuePressureDelta', WorkTable.FHashValuePressureDelta);
      WorkTable.FHashValueAirPressure := ValuesIni.ReadString(Section, 'HashValueAirPressure', WorkTable.FHashValueAirPressure);
      WorkTable.FHashValueAirTemperture := ValuesIni.ReadString(Section, 'HashValueAirTemperture', WorkTable.FHashValueAirTemperture);
      WorkTable.FHashValueHumidity := ValuesIni.ReadString(Section, 'HashValueHumidity', WorkTable.FHashValueHumidity);

      if WorkTable.FValueTempertureBefore <> nil then WorkTable.FValueTempertureBefore.DeleteFromVector;
      if WorkTable.FValueTempertureAfter <> nil then WorkTable.FValueTempertureAfter.DeleteFromVector;
      if WorkTable.FValueTempertureDelta <> nil then WorkTable.FValueTempertureDelta.DeleteFromVector;
      if WorkTable.FValuePressureBefore <> nil then WorkTable.FValuePressureBefore.DeleteFromVector;
      if WorkTable.FValuePressureAfter <> nil then WorkTable.FValuePressureAfter.DeleteFromVector;
      if WorkTable.FValuePressureDelta <> nil then WorkTable.FValuePressureDelta.DeleteFromVector;
      if WorkTable.FValueAirPressure <> nil then WorkTable.FValueAirPressure.DeleteFromVector;
      if WorkTable.FValueAirTemperture <> nil then WorkTable.FValueAirTemperture.DeleteFromVector;
      if WorkTable.FValueHumidity <> nil then WorkTable.FValueHumidity.DeleteFromVector;

      WorkTable.InitMeterValues;

      WorkTable.ValueTempertureBefore.SetValue(ValuesIni.ReadFloat(Section, 'ValueTempertureBefore', 0));
      WorkTable.ValueTempertureAfter.SetValue(ValuesIni.ReadFloat(Section, 'ValueTempertureAfter', 0));
      WorkTable.ValueTempertureDelta.SetValue(ValuesIni.ReadFloat(Section, 'ValueTempertureDelta', 0));
      WorkTable.ValuePressureBefore.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressureBefore', 0));
      WorkTable.ValuePressureAfter.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressureAfter', 0));
      WorkTable.ValuePressureDelta.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressureDelta', 0));
      WorkTable.ValueAirPressure.SetValue(ValuesIni.ReadFloat(Section, 'ValueAirPressure', 0));
      WorkTable.ValueAirTemperture.SetValue(ValuesIni.ReadFloat(Section, 'ValueAirTemperture', 0));
      WorkTable.ValueHumidity.SetValue(ValuesIni.ReadFloat(Section, 'ValueHumidity', 0));

      LoadChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      LoadChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);

      AWorkTables.Add(WorkTable);
    end;
  finally
    ValuesIni.Free;
    Ini.Free;
  end;
end;

class procedure TWorkTable.SaveChannelList(AIni: TIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>);
var
  I: Integer;
  Channel: TChannel;
  Section: string;
begin
  if (AIni = nil) or (AChannels = nil) then
    Exit;

  AIni.EraseSection(ASectionPrefix);
  AIni.WriteInteger(ASectionPrefix, 'Count', AChannels.Count);

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    Section := ASectionPrefix + '.' + IntToStr(I);

    AIni.EraseSection(Section);
    AIni.WriteInteger(Section, 'ID', Channel.ID);
    AIni.WriteString(Section, 'UUID', Channel.UUID);
    AIni.WriteBool(Section, 'Enabled', Channel.Enabled);
    AIni.WriteString(Section, 'Name', Channel.Name);
    AIni.WriteString(Section, 'TypeName', Channel.TypeName);
    AIni.WriteString(Section, 'Serial', Channel.Serial);
    AIni.WriteInteger(Section, 'Signal', Channel.Signal);
    AIni.WriteString(Section, 'DeviceUUID', Channel.DeviceUUID);

    AIni.WriteFloat(Section, 'ImpSec', Channel.ImpSec);
    AIni.WriteFloat(Section, 'ImpResult', Channel.ImpResult);
    AIni.WriteFloat(Section, 'CurSec', Channel.CurSec);
    AIni.WriteFloat(Section, 'CurResult', Channel.CurResult);
    AIni.WriteFloat(Section, 'ValueSec', Channel.ValueSec);
    AIni.WriteFloat(Section, 'ValueResult', Channel.ValueResult);

    AIni.WriteString(Section, 'HashValueImp', Channel.ValueImp.Hash);
    AIni.WriteString(Section, 'HashValueImpTotal', Channel.ValueImpTotal.Hash);
    AIni.WriteString(Section, 'HashValueCurrent', Channel.ValueCurrent.Hash);
    AIni.WriteString(Section, 'HashValueInterface', Channel.ValueInterface.Hash);
  end;
end;

class procedure TWorkTable.LoadChannelList(AIni: TIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>);
var
  Count, I: Integer;
  Channel: TChannel;
  Section: string;
  IsExisted: Integer;
begin
  if (AIni = nil) or (AChannels = nil) then
    Exit;

  AChannels.Clear;
  Count := AIni.ReadInteger(ASectionPrefix, 'Count', 0);

  for I := 0 to Count - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);

    Channel := TChannel.Create;
    Channel.ID := AIni.ReadInteger(Section, 'ID', I + 1);
    Channel.UUID := AIni.ReadString(Section, 'UUID', '');
    Channel.Enabled := AIni.ReadBool(Section, 'Enabled', True);
    Channel.Name := AIni.ReadString(Section, 'Name', '');
    Channel.TypeName := AIni.ReadString(Section, 'TypeName', '');
    Channel.Serial := AIni.ReadString(Section, 'Serial', '');
    Channel.Signal := AIni.ReadInteger(Section, 'Signal', -1);
    Channel.DeviceUUID := AIni.ReadString(Section, 'DeviceUUID', '');

    Channel.ImpSec := AIni.ReadFloat(Section, 'ImpSec', 0);
    Channel.ImpResult := AIni.ReadFloat(Section, 'ImpResult', 0);
    Channel.CurSec := AIni.ReadFloat(Section, 'CurSec', 0);
    Channel.CurResult := AIni.ReadFloat(Section, 'CurResult', 0);
    Channel.ValueSec := AIni.ReadFloat(Section, 'ValueSec', 0);
    Channel.ValueResult := AIni.ReadFloat(Section, 'ValueResult', 0);

    Channel.FHashValueImp := AIni.ReadString(Section, 'HashValueImp', Channel.FHashValueImp);
    Channel.FHashValueImpTotal := AIni.ReadString(Section, 'HashValueImpTotal', Channel.FHashValueImpTotal);
    Channel.FHashValueCurrent := AIni.ReadString(Section, 'HashValueCurrent', Channel.FHashValueCurrent);
    Channel.FHashValueInterface := AIni.ReadString(Section, 'HashValueInterface', Channel.FHashValueInterface);

    if Channel.FValueImp <> nil then Channel.FValueImp.DeleteFromVector;
    if Channel.FValueImpTotal <> nil then Channel.FValueImpTotal.DeleteFromVector;
    if Channel.FValueCurrent <> nil then Channel.FValueCurrent.DeleteFromVector;
    if Channel.FValueInterface <> nil then Channel.FValueInterface.DeleteFromVector;

    Channel.FValueImp := TMeterValue.GetExistedMeterValueBool(Channel.FHashValueImp, IsExisted, Channel.UUID, Channel.Name);
    if IsExisted = 0 then
    begin
      Channel.FValueImp.SetAsImp;
      Channel.FValueImp.DependenceType := INDEPENDENT;
      Channel.FValueImp.UpdateType := ONLINE_TYPE;
    end;
    Channel.FValueImp.SetToSave(True);

    Channel.FValueImpTotal := TMeterValue.GetExistedMeterValueBool(Channel.FHashValueImpTotal, IsExisted, Channel.UUID, Channel.Name);
    if IsExisted = 0 then
    begin
      Channel.FValueImpTotal.SetAsImp;
      Channel.FValueImpTotal.DependenceType := INDEPENDENT;
      Channel.FValueImpTotal.UpdateType := ONLINE_TYPE;
    end;
    Channel.FValueImpTotal.SetToSave(True);

    Channel.FValueCurrent := TMeterValue.GetExistedMeterValueBool(Channel.FHashValueCurrent, IsExisted, Channel.UUID, Channel.Name);
    if IsExisted = 0 then
    begin
      Channel.FValueCurrent.SetAsCurrent;
      Channel.FValueCurrent.DependenceType := INDEPENDENT;
      Channel.FValueCurrent.UpdateType := ONLINE_TYPE;
    end;
    Channel.FValueCurrent.SetToSave(True);
    Channel.FValueInterface := TMeterValue.GetExistedMeterValueBool(Channel.FHashValueInterface, IsExisted, Channel.UUID, Channel.Name);
    Channel.FValueInterface.SetToSave(True);

    Channel.Init;

    AChannels.Add(Channel);
  end;
end;

class function TWorkTable.SpillStateFromString(const AValue: string): TSpillState;
begin
  if SameText(AValue, 'Ready') then
    Exit(ssReady);

  if SameText(AValue, 'Starting') then
    Exit(ssStarting);

  if SameText(AValue, 'OnGoing') then
    Exit(ssOnGoing);

  if SameText(AValue, 'Stopping') then
    Exit(ssStopping);

  if SameText(AValue, 'ResultReady') then
    Exit(ssResultReady);

  Result := ssNone;
end;

class function TWorkTable.SpillStateToString(AState: TSpillState): string;
begin
  case AState of
    ssReady:
      Result := 'Ready';
    ssStarting:
      Result := 'Starting';
    ssOnGoing:
      Result := 'OnGoing';
    ssStopping:
      Result := 'Stopping';
    ssResultReady:
      Result := 'ResultReady';
  else
    Result := 'None';
  end;
end;

{ TWorkTableManager }

constructor TWorkTableManager.Create(const AIniFileName: string);
begin
  inherited Create;
  FIniFileName := AIniFileName;
  FWorkTables := TObjectList<TWorkTable>.Create(True);
end;

destructor TWorkTableManager.Destroy;
begin
  FWorkTables.Free;
  inherited;
end;

procedure TWorkTableManager.Load;
begin
  TWorkTable.Load(FIniFileName, FWorkTables);
end;

procedure TWorkTableManager.Save;
begin
  TWorkTable.Save(FIniFileName, FWorkTables);
end;
    {$ENDREGION 'TWorkTable'}



end.
