unit FMXDeviceCustomControl;

interface
uses  System.Classes,
      FPCustomControl,
      FmxFPModuleManager,
      FmxModbusTypes,
      System.UITypes,
      FMXFPModule;
const
  cMaxModules=5;
type
  //базовый класс для всех компонентов проливной FMX
  TFMXDeviceCustomControl = class(TFPCustomControl)
  private
    FDefaultState: integer;
    FModulePriority:integer;
    FModbusTCPPort: Word;
    FModbusTCPHost: string;
    FActive: boolean;
    FParity: TComParity;
    FMaxChannels: byte;
    FModbusFormat: TModBusDataFormat;
    function GetFirst: boolean;
    function GetInformation: string;
    procedure SetDefaultState(const Value: integer);
    procedure SetFirst(const Value: boolean);
    function GetModbusInputReg(AIdx: integer): word;
    function GetModbusOutputReg(AIdx: integer): word;
    function GetSerialNum: LongWord;
    procedure SetModbusInputReg(AIdx: integer; const Value: word);
    procedure SetModbusOutputReg(AIdx: integer; const Value: word);
    procedure SetSerialNum(const Value: LongWord);
    procedure SetModbusTCPHost(const Value: string);
    procedure SetModbusTCPPort(const Value: Word);
    procedure SetActive(const Value: boolean);
    function GetParity: TComParity;
  protected
    FSerialNum:LongWord;//Серийный номер компонента
    FAFTypeSet:TAppFunctionalTypeSet;//Набор подключенных функциональных свойств (функций)
    FAFIdx:integer;//Функциональный индекс - индекс, работающий в бизнеслогике
    FPort:array[0..cMaxModules-1] of word;  //в Modbus TCP номер порта TCP сокета = 502, в Modbus ASCII и RTU номер последовательного порта
    FAddress:array[0..cMaxModules-1] of integer;//в Modbus TCP адрес сервера, в Modbus ASCII/RTU номер Slave
    FBaudRate:array[0..cMaxModules-1] of Cardinal;//в Modbus ASCII/RTU - сорость обмена
    FInputRegister:array[0..cMaxModules-1] of word;//в Modbus адрес регистра параметров только на чтение
    FOutputRegister:array[0..cMaxModules-1] of word;//в Modbus адрес регистра параметров на чтение и запись
    FTypeOfProtocol:array[0..cMaxModules-1] of TTypeOfProtocol;//типы протоколов
    FModuleType:array[0..cMaxModules-1] of TFMXModuleType;
    FFirst:boolean;
    function GetInfo: String;virtual;
    procedure SetModbusFormat(const Value: TModBusDataFormat);virtual;
    function GetMaxChannels: byte;virtual;
    procedure SetMaxChannels(const Value: byte);virtual;
    function GetCurState: string;override;
    function GetTypeOfProtocol(AIdx: integer): TTypeOfProtocol;virtual;
    procedure SetTypeOfProtocol(AIdx: integer; const Value: TTypeOfProtocol);virtual;
    function GetComPort(AIdx: integer): word;virtual;
    procedure SetComPort(AIdx: integer; const Value: word);virtual;
    function GetAddress(AIdx: integer): integer;virtual;
    procedure SetAddress(AIdx: integer; const Value: integer);virtual;
    function GetBaudRate(AIdx: integer): Cardinal;virtual;
    procedure SetBaudRate(AIdx: integer; const Value: Cardinal);virtual;
    function GetModuleType(AIdx: integer): TFMXModuleType;virtual;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType);virtual;
    procedure ReceiveResponse; virtual; abstract;
    function GetModuleManager: TFmxModuleManager;virtual;
    function Disguise: Boolean; virtual;
    function GetPriority: integer;virtual;
    procedure SetPriority(const Value: integer);virtual;
    procedure SetParity(const Value: TComParity);virtual;
  public
    property Port[AIdx:integer]:word read GetComPort write SetComPort;
    //Тип модуля
    property ModuleType[AIdx:integer]:TFMXModuleType read GetModuleType write SetModuleType;
    // Адрес модуля, к которому подключено устройство.
    property Address[AIdx:integer]: integer read GetAddress write SetAddress;
    // Скорость модуля, к которому подключено устройство.
    property BaudRate[AIdx:integer]: Cardinal read GetBaudRate write SetBaudRate;
    // Тип протокола
    property TypeOfProtocol[AIdx:integer]: TTypeOfProtocol read GetTypeOfProtocol write SetTypeOfProtocol;

    property InputRegister[AIdx:integer]:word read GetModbusInputReg write SetModbusInputReg;

    property OutputRegister[AIdx:integer]:word read GetModbusOutputReg write SetModbusOutputReg;
    constructor Create(AOwner: TComponent); override;
    procedure AddToDeviceManager;
    procedure Update;virtual;
  published
    property DefaultState:integer read FDefaultState write SetDefaultState;
    // Возможность редактирования
    property First:boolean read GetFirst write SetFirst;
    property SerialNum:LongWord read GetSerialNum write SetSerialNum;
    property ShowHint;
    property Caption;
    property Hint;
    property OnKeyDown;
    property OnClick;
    property PopUpMenu;
    property Configuration:string read GetInformation;
    property ModbusTCPHost:string read FModbusTCPHost write SetModbusTCPHost;
    property ModbusTCPPort:Word read FModbusTCPPort write SetModbusTCPPort;
    property Active:boolean read FActive write SetActive;
    property Idx;
    property AFTypeSet;
    property AFIdx;
    property CurrentState;
    property ModulePriority:integer read GetPriority write SetPriority;
    property Parity:TComParity read GetParity write SetParity;
    property MaxChannels:byte read GetMaxChannels write SetMaxChannels;
    property ModbusFormat: TModBusDataFormat read FModbusFormat write SetModbusFormat;
    property Info:String read GetInfo;
  end;

procedure Register;

implementation
uses
  System.SysUtils,FMXHelper;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFMXDeviceCustomControl]);
end;

{ TFMXDeviceCustomControl }

procedure TFMXDeviceCustomControl.AddToDeviceManager;
begin
  self.Loaded;
end;

constructor TFMXDeviceCustomControl.Create(AOwner: TComponent);
var i:integer;
begin
  inherited;
  FAFIdx:=1;
  for i := 0 to cMaxModules-1 do
  begin
    Port[i]:=i;
    Address[i]:=1;
    BaudRate[i]:=19200;
    InputRegister[i]:=0;
    FOutputRegister[i]:=0;
    TypeOfProtocol[i]:=tpProprietary;
    ModuleType[i]:=mtNone;
  end;
end;


function TFMXDeviceCustomControl.Disguise: Boolean;
begin
  result:=false;
end;

function TFMXDeviceCustomControl.GetAddress(AIdx: integer): integer;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FAddress[AIdx]
  else
     result:=0;
end;



function TFMXDeviceCustomControl.GetBaudRate(AIdx: integer): Cardinal;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FBaudrate[AIdx]
  else
     result:=0;
end;


function TFMXDeviceCustomControl.GetComPort(AIdx: integer): word;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FPort[AIdx]
  else
     result:=0;
end;

function TFMXDeviceCustomControl.GetModbusInputReg(AIdx: integer): word;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FInputRegister[AIdx]
  else
     result:=0;
end;

function TFMXDeviceCustomControl.GetModbusOutputReg(AIdx: integer): word;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FOutputRegister[AIdx]
  else
     result:=0;
end;

function TFMXDeviceCustomControl.GetModuleManager: TFmxModuleManager;
begin
  result:=nil;
end;

function TFMXDeviceCustomControl.GetModuleType(AIdx: integer): TFMXModuleType;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FModuleType[AIdx]
  else
     result:=mtNone;
end;

function TFMXDeviceCustomControl.GetParity: TComParity;
begin
  if not (FParity in [cpNone..cpSpace]) then
     FParity:=cpNone;
  result:=FParity;
end;

function TFMXDeviceCustomControl.GetPriority: integer;
begin
  result:=FModulePriority;
end;

function TFMXDeviceCustomControl.GetCurState: string;
begin
  result:=inherited + Format(' №%d ', [SerialNum]);
end;

function TFMXDeviceCustomControl.GetFirst: boolean;
begin
  result:=FFirst;
end;

function TFMXDeviceCustomControl.GetSerialNum: LongWord;
begin
  result:=FSerialNum;
end;


function TFMXDeviceCustomControl.GetInfo: String;
begin
  result:=Format('П:%d А:%d',[FPort[0],FAddress[0]]);
end;

function TFMXDeviceCustomControl.GetInformation: string;
begin
 result:=Name+cDiv+ClassName+cDiv+
         StyleLookup+cDiv+
         Caption+cDiv+
         Hint+cDiv+
         IntToStr(Round(left))+cDiv+
         IntToStr(Round(Top))+cDiv+
         IntToStr(Round(Width))+cDiv+
         IntToStr(Round(Height))+cDiv+

         IntToStr(Port[0])+cDiv+
         IntToStr(Address[0])+cDiv+
         IntToStr(BaudRate[0])+cDiv+
         IntToStr(Ord(ModuleType[0]))+cDiv+
         IntToStr(ord(TypeOfProtocol[0]))+cDiv+
         IntToStr(InputRegister[0])+cDiv+
         IntToStr(OutputRegister[0])+cDiv+

         IntToStr(Port[1])+cDiv+
         IntToStr(Address[1])+cDiv+
         IntToStr(BaudRate[1])+cDiv+
         IntToStr(Ord(ModuleType[1]))+cDiv+
         IntToStr(ord(TypeOfProtocol[1]))+cDiv+
         IntToStr(InputRegister[1])+cDiv+
         IntToStr(OutputRegister[1])+cDiv+

         IntToStr(Port[2])+cDiv+
         IntToStr(Address[2])+cDiv+
         IntToStr(BaudRate[2])+cDiv+
         IntToStr(Ord(ModuleType[2]))+cDiv+
         IntToStr(ord(TypeOfProtocol[2]))+cDiv+
         IntToStr(InputRegister[2])+cDiv+
         IntToStr(OutputRegister[2])+cDiv+

         IntToStr(Ord(ControlType))+cDiv+
         IntToStr(SerialNum)+cDiv+
         IntToStr(DefaultState)+cDiv+
         IntToStr(ord(TypeOfAppFunc))+cDiv+
         IntToStr(Ord(AFIdx));
end;


function TFMXDeviceCustomControl.GetMaxChannels: byte;
begin
   result:=FMaxChannels;
end;

function TFMXDeviceCustomControl.GetTypeOfProtocol(
  AIdx: integer): TTypeOfProtocol;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FTypeOfProtocol[AIdx]
  else
     result:=tpProprietary;
end;




procedure TFMXDeviceCustomControl.SetActive(const Value: boolean);
begin
  FActive := Value;
  UpdateStyle();
end;

procedure TFMXDeviceCustomControl.SetAddress(AIdx: integer;
  const Value: integer);
begin
  if AIdx in [0..cMaxModules-1]  then
     FAddress[AIdx]:=Value;
end;



procedure TFMXDeviceCustomControl.SetBaudRate(AIdx: integer;
  const Value: Cardinal);
begin
  if AIdx in [0..cMaxModules-1]  then
     FBaudRate[AIdx]:=Value;
end;


procedure TFMXDeviceCustomControl.SetComPort(AIdx: integer; const Value: word);
begin
  if AIdx in [0..cMaxModules-1]  then
     FPort[AIdx]:=Value;
end;


procedure TFMXDeviceCustomControl.SetModbusFormat(
  const Value: TModBusDataFormat);
begin
  FModbusFormat := Value;
end;

procedure TFMXDeviceCustomControl.SetModbusInputReg(AIdx: integer;
  const Value: word);
begin
  if AIdx in [0..cMaxModules-1]  then
     FInputRegister[AIdx]:=Value;
end;

procedure TFMXDeviceCustomControl.SetModbusOutputReg(AIdx: integer;
  const Value: word);
begin
  if AIdx in [0..cMaxModules-1]  then
     FOutputRegister[AIdx]:=Value;
end;

procedure TFMXDeviceCustomControl.SetModbusTCPHost(const Value: string);
begin
  FModbusTCPHost := Value;
end;

procedure TFMXDeviceCustomControl.SetModbusTCPPort(const Value: Word);
begin
  FModbusTCPPort := Value;
end;

procedure TFMXDeviceCustomControl.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  if AIdx in [0..cMaxModules-1]  then
     FModuleType[AIdx]:=Value;
end;

procedure TFMXDeviceCustomControl.SetParity(const Value: TComParity);
begin
  FParity := Value;
end;

procedure TFMXDeviceCustomControl.SetPriority(const Value: integer);
begin
   FModulePriority:=Value;
end;

procedure TFMXDeviceCustomControl.SetSerialNum(const Value: LongWord);
begin
  FSerialNum:=Value;
end;

procedure TFMXDeviceCustomControl.SetDefaultState(const Value: integer);
begin
  FDefaultState := Value;
end;



procedure TFMXDeviceCustomControl.SetFirst(const Value: boolean);
begin
  FFirst:=Value;
end;



procedure TFMXDeviceCustomControl.SetMaxChannels(const Value: byte);
begin
  FMaxChannels := Value;
end;

procedure TFMXDeviceCustomControl.SetTypeOfProtocol(AIdx: integer;
  const Value: TTypeOfProtocol);
begin
  if AIdx in [0..cMaxModules-1]  then
     FTypeOfProtocol[AIdx]:=Value;
end;


procedure TFMXDeviceCustomControl.Update;
begin
  if Disguise then
  begin
    if (State<>fpsDisguise) then
       State:=fpsDisguise;
  end
  else begin
    if (State=fpsDisguise) then
       State:=PreviousState;
  end;

  UpdateStyle;
end;

end.
