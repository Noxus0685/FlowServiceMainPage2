unit FmxFPDevice;

{ ===== Класс TFmxDevice =====
  Класс является родительским для всех классов устройств. Однажды создав устройство, его следует уничтожить
  только в конце работы приложения, т.к. при уничтожении каждое устройство уничтожает поток работы с COM-портом,
  т.е. делает невозможной работу остальных устройств.
}

interface

uses
  FmxFPModuleManager, FMXDeviceCustomControl, FmxFPModule, uProcedureOfObject,
  FmxModbusTypes,
  FmxFPDeviceManager;

type
  // Тип выхода расходомера.
  TFmxOutputType = (fotNone, fotVoltage, fotCurrent, fotFrequency, fotVisual, fotInterface);

const
  cFmxOutputTypeName: array [TFmxOutputType] of String = ('без подключения',
    'напряжение', 'ток', 'частота', 'Визуальное сличение',
    'цифровой интерфейс');

type
  TFmxDevice = class

  private
    FModuleType: TFmxModuleType;
    FDebug: integer;
    FHost: TFMXDeviceCustomControl;
    FTypeOfProtocol: TTypeOfProtocol;
    FInputRegAddr: word;
    FOutputRegAddr: word;
    FSerialNum: LongWord;
    FMaxI: Single;
    FMinO: Single;
    FMinI: Single;
    FMaxO: Single;
    FUnitName: String;
    FUnitID: longint;
    FUnitNumber: String;
    FOutputType: TFmxOutputType;
    FMaxChannels: byte;
    FParity: TComParity;
    FMustUpdate: boolean;
    FModbusFormat: TModBusDataFormat;
    FDigitsForChannel: byte;
    procedure SetModuleType(const Value: TFmxModuleType);
    function GetFmxModule: TFmxModule;
    procedure SetDisguise(const Value: boolean);
    procedure SetFmxModule(const Value: TFmxModule);
    procedure SetDebug(const Value: integer);
    procedure SetHost(const Value: TFMXDeviceCustomControl);
    procedure SetConnect(const Value: boolean);
    procedure SetFmxModuleManager(const Value: TFmxModuleManager);
    function GetValid: boolean;
    function GetDisguise: boolean;
    function GetFmxModuleTypeName: String;
    procedure SetTypeOfProtocol(const Value: TTypeOfProtocol);
    procedure SetInputRegAddr(const Value: word);
    procedure SetOutputRegAddr(const Value: word);
    procedure SetSerialNum(const Value: LongWord);
    procedure SetMaxI(const Value: Single);
    procedure SetMaxO(const Value: Single);
    procedure SetMinI(const Value: Single);
    procedure SetMinO(const Value: Single);
    procedure SetUnitID(const Value: longint);
    procedure SetUnitName(const Value: String);
    procedure SetUnitNumber(const Value: String);
    procedure SetOutputType(const Value: TFmxOutputType);
    function GetPriority: integer;
    procedure SetPriority(const Value: integer);
    procedure SetParity(const Value: TComParity);
    function GetMaxChannels: byte;
    function GetModuleType: TFmxModuleType;
  protected
    FCheckConnect: boolean;

    FModuleManager: TFmxModuleManager;
    FPort:integer;
    FAddr:integer;
    // Указатель на используемый модуль.
    FModule: TFmxModule;

    function GetInfo: String;virtual;
    function GetAddr: integer;Virtual;
    function GetPort: integer;Virtual;
    procedure SetAddr(const Value: integer);Virtual;
    procedure SetPort(const Value: integer);Virtual;
    procedure SetModbusFormat(const Value: TModBusDataFormat);Virtual;
    procedure SetMaxChannels(const Value: byte); Virtual;
    procedure SetDigitsForChannel(const Value: byte);Virtual;
    function CheckConnect: boolean; Virtual;
    function GetAutoUpdateFlag: boolean; Virtual;
    procedure SetAutoUpdateFlag(flag: boolean); Virtual;
    procedure SetMustUpdate(const Value: boolean);virtual;
    function GetMustUpdate: boolean;virtual;

  public

    // Указатель на процедуру добавления записи в лог работы; если nil, то действия устройства не будут
    // добавляться в журнал.

    // 20.05.2009 -- добавлена переменная usual_mode! Для лога по нерегулируемым насосам
    AddToWorkLogProc: procedure(str: ShortString;
      level: TAddToWorkLogLevel = awlSimple;
      with_time: boolean = true { ; usual_mode: Boolean = true } ) of object;

    // Название устройства, используемое для вывода в лог работы.
    DeviceName: String;

    // Указатель на используемый менеджер модулей.
    property ModuleManager: TFmxModuleManager read FModuleManager
      write SetFmxModuleManager;

    { ===== AddReceiver =====
      Добавляет дополнительный получатель ответов от модуля-устройства.
      Принимаемые параметры:
      receiver - указатель на метод, являющийся дополнительным получателем ответа от модуля-устройства; если
      равен nil, то не добавится;
      use_main_thread - флаг необходимости вызова метода в основном потоке приложения.
    }
    procedure AddReceiver(receiver: TProcedureOfObject;
      use_main_thread: boolean = true); Virtual;
    procedure SwitchDisguise;

    constructor Create;

    destructor Destroy; override;

    // Флаг разрешения автоматического обновления статуса модуля.
    property AutoUpdateEnabled: boolean read GetAutoUpdateFlag
      write SetAutoUpdateFlag;

    // Флаг успешно установленного соединения.
    property ConnectIsOK: boolean read CheckConnect write SetConnect;

    property ModuleType: TFmxModuleType read GetModuleType write SetModuleType;

    property ModuleTypeName: String read GetFmxModuleTypeName;

    property Disguise: boolean read GetDisguise write SetDisguise;

    property Module: TFmxModule read GetFmxModule write SetFmxModule;

    property Debug: integer read FDebug write SetDebug;

    property Host: TFMXDeviceCustomControl read FHost write SetHost;

    property Valid: boolean read GetValid;

    property TypeOfProtocol: TTypeOfProtocol read FTypeOfProtocol
      write SetTypeOfProtocol;

    property InputRegister: word read FInputRegAddr write SetInputRegAddr;

    property OutputRegister: word read FOutputRegAddr write SetOutputRegAddr;

    property MinInput: Single read FMinI write SetMinI;

    property MaxInput: Single read FMaxI write SetMaxI;

    property MinOutput: Single read FMinO write SetMinO;

    property MaxOutput: Single read FMaxO write SetMaxO;

    property SerialNum: LongWord read FSerialNum write SetSerialNum;

    property UnitName: String read FUnitName write SetUnitName;

    property UnitNumber: String read FUnitNumber write SetUnitNumber;

    property UnitID: longint read FUnitID write SetUnitID;

    property OutputType: TFmxOutputType read FOutputType write SetOutputType;
    // Тип подключения

    property MaxChannels: byte read GetMaxChannels write SetMaxChannels;

    property DigitsForChannel: byte read FDigitsForChannel write SetDigitsForChannel;

    property ModulePriority: integer read GetPriority write SetPriority;

    property Parity:TComParity read FParity write SetParity;

    property MustUpdate:boolean read GetMustUpdate write SetMustUpdate;

    property ModbusFormat: TModBusDataFormat read FModbusFormat write SetModbusFormat;

    property Info:String read GetInfo;

    property Addr:integer read GetAddr write SetAddr;

    property PortNumber:integer read GetPort write SetPort;
  end;

implementation

uses
  System.SysUtils;

// ============================================================================================================
// ============================================================================================================

function TFmxDevice.CheckConnect: boolean;
begin
  if Assigned(Module) then
    Result := Module.ConnectIsGood
  else
  begin
    if ModuleType = mtManual then
      Result := true
    else if ModuleType = mtLTA then
      Result := FCheckConnect
    else
      Result := False;
  end;
end;

function TFmxDevice.GetAddr: integer;
begin
  result:=FAddr;
end;

// ============================================================================================================

function TFmxDevice.GetAutoUpdateFlag: boolean;
begin
  if Assigned(Module) then
    Result := Module.EnabledAutoUpdate
  else
    Result := False;
end;

function TFmxDevice.GetDisguise: boolean;
begin
  if Assigned(Module) then
    Result := Module.Disguise
  else if not(ModuleType in [mtManual, mtLTA]) then
    Result := true
  else
    Result := False;
end;

procedure TFmxDevice.SetAddr(const Value: integer);
begin
  FAddr:=Value;
end;

// ============================================================================================================

procedure TFmxDevice.SetAutoUpdateFlag(flag: boolean);
begin
  if Assigned(Module) then
    Module.EnabledAutoUpdate := flag;
end;

// ============================================================================================================

procedure TFmxDevice.AddReceiver(receiver: TProcedureOfObject;
  use_main_thread: boolean = true);
begin
  if Assigned(Module) then
    Module.AddReceiver(receiver, use_main_thread);
end;

// ============================================================================================================
procedure TFmxDevice.SwitchDisguise;
begin
  try
    if Assigned(Module) then
    begin
      Module.Disguise := not Module.Disguise;
      if Module.Disguise then
        Module.ConnectIsOK := fdqDisguise;
      Module.EnabledAutoUpdate := not Module.Disguise;
    end;
  finally

  end;
end;
// ============================================================================================================

constructor TFmxDevice.Create;
begin
  AddToWorkLogProc := nil;
  DeviceName := '';
  UnitName := '---';
  UnitNumber := '---';
  SerialNum := 0;
  FUnitID := -1;
  FUnitID := -1;
  MinInput := 0;
  MaxInput := 100;
  MinOutput := 0;
  MaxOutput := 100;
  ModbusFormat:=mdf_1_0_3_2;
end;

// ============================================================================================================

destructor TFmxDevice.Destroy;
begin
  ModuleManager.TerminateCOMThread;
  inherited Destroy;
end;

// ============================================================================================================

procedure TFmxDevice.SetModuleType(const Value: TFmxModuleType);
begin
  FModuleType := Value;
end;

procedure TFmxDevice.SetOutputRegAddr(const Value: word);
begin
  FOutputRegAddr := Value;
  if Assigned(Module) then
    Module.OutputRegister := Value;
end;

procedure TFmxDevice.SetOutputType(const Value: TFmxOutputType);
begin
  FOutputType := Value;
end;

procedure TFmxDevice.SetParity(const Value: TComParity);
begin
  FParity := Value;
  if Assigned(Module) then Module.Parity:=Value;
end;

procedure TFmxDevice.SetPort(const Value: integer);
begin
  FPort:=Value;
end;

procedure TFmxDevice.SetPriority(const Value: integer);
begin
  if Assigned(Module) then
    Module.Priority := Value;
end;

procedure TFmxDevice.SetSerialNum(const Value: LongWord);
begin
  FSerialNum := Value;
end;

procedure TFmxDevice.SetTypeOfProtocol(const Value: TTypeOfProtocol);
begin
  FTypeOfProtocol := Value;
  if Assigned(Module) then
    Module.Protocol := Value;
end;

procedure TFmxDevice.SetUnitID(const Value: longint);
begin
  FUnitID := Value;
end;

procedure TFmxDevice.SetUnitName(const Value: String);
begin
  FUnitName := Value;
end;

procedure TFmxDevice.SetUnitNumber(const Value: String);
begin
  FUnitNumber := Value;
end;

function TFmxDevice.GetFmxModule: TFmxModule;
begin
  Result := FModule;
end;

function TFmxDevice.GetFmxModuleTypeName: String;
begin
  Result := cModuleTypeNames[FModuleType];
end;

function TFmxDevice.GetInfo: String;
begin
  result:=Format('П:%d А:%d',[FPort,FAddr]);
end;

function TFmxDevice.GetMaxChannels: byte;
begin
  if Assigned(Module) then
     result:=Module.MaxChannels
  else
     result:=FMaxChannels;
end;

function TFmxDevice.GetModuleType: TFmxModuleType;
begin
  result:=FModuleType;
end;

function TFmxDevice.GetMustUpdate: boolean;
begin
  result:=FMustUpdate;
end;

function TFmxDevice.GetPort: integer;
begin
  result:=FPort;
end;

function TFmxDevice.GetPriority: integer;
begin
  if Assigned(Module) then
    Result := Module.Priority
  else
    Result := 0;
end;

function TFmxDevice.GetValid: boolean;
begin
  Result := true;
  if Assigned(Module) then
    if (Module.TotalSended > 10) then
      Result := (1 - (Module.TotalSended - Module.TotalReceived) /
        Module.TotalSended) > 0.7;
end;

procedure TFmxDevice.SetDigitsForChannel(const Value: byte);
begin
  FDigitsForChannel := Value;
end;

procedure TFmxDevice.SetDisguise(const Value: boolean);
begin
  try
    if Assigned(Module) then
      Module.Disguise := Value;
  finally

  end;
end;

procedure TFmxDevice.SetMaxChannels(const Value: byte);
begin
  FMaxChannels := Value;
  if Assigned(Module) then
     Module.MaxChannels:=Value;
end;

procedure TFmxDevice.SetMaxI(const Value: Single);
begin
  FMaxI := Value;
end;

procedure TFmxDevice.SetMaxO(const Value: Single);
begin
  FMaxO := Value;
end;

procedure TFmxDevice.SetMinI(const Value: Single);
begin
  FMinI := Value;
end;

procedure TFmxDevice.SetMinO(const Value: Single);
begin
  FMinO := Value;
end;

procedure TFmxDevice.SetModbusFormat(const Value: TModBusDataFormat);
begin
  FModbusFormat := Value;
  if Assigned(FModule) then
      FModule.ModbusFormat:=Value;
end;

procedure TFmxDevice.SetMustUpdate(const Value: boolean);
begin
  FMustUpdate := Value;
end;

procedure TFmxDevice.SetFmxModule(const Value: TFmxModule);
begin
  FModule := Value;
end;

procedure TFmxDevice.SetFmxModuleManager(const Value: TFmxModuleManager);
begin
  FModuleManager := Value;
end;

procedure TFmxDevice.SetDebug(const Value: integer);
begin
  FDebug := Value;
end;

procedure TFmxDevice.SetHost(const Value: TFMXDeviceCustomControl);
begin
  FHost := Value;
end;

procedure TFmxDevice.SetInputRegAddr(const Value: word);
begin
  FInputRegAddr := Value;
  if Assigned(Module) then
    Module.InputRegister := Value;
end;

procedure TFmxDevice.SetConnect(const Value: boolean);
begin
  if Assigned(Module) then
    Module.ConnectIsGood := Value
  else
    FCheckConnect := Value;
end;

end.
