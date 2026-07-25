unit uFMXDeviceCustomControl;

interface
uses FPCustomControl,
     FMXFPModule;
const
  cMaxModules=5;
  cDiv=',';
type
  //базовый класс для всех компонентов проливной FMX
  TFMXDeviceCustomControl = class(TFPCustomControl)
  private
    FVisibleSensors: boolean;
    FDesignMode: Boolean;
    FTypeOfAppFunc: TTypeOfAppFunc;
    FFONT_SIZE: Integer;
    FDefaultState: integer;
    function GetAFIdx: integer;
    function GetAFTypeSet: TAppFunctionalTypeSet;
    function GetIdx: integer;
    function GetControlType: TControlType;
    function GetFirst: boolean;
    function GetInformation: string;
    procedure SetAFIdx(const Value: integer);
    procedure SetAFTypeSet(const Value: TAppFunctionalTypeSet);
    procedure SetIdx(const Value: integer);
    procedure SetControlType(const Value: TControlType);
    procedure SetDefaultState(const Value: integer);
    procedure SetDesignMode(const Value: Boolean);
    procedure SetFirst(const Value: boolean);
    procedure SetFONT_SIZE(const Value: Integer);
    procedure SetTypeOfAppFunc(const Value: TTypeOfAppFunc);
    procedure SetVisibleSensors(const Value: boolean);
    function GetModbusInputReg(AIdx: integer): word;
    function GetModbusOutputReg(AIdx: integer): word;
    function GetSerialNum: LongWord;
    procedure SetModbusInputReg(AIdx: integer; const Value: word);
    procedure SetModbusOutputReg(AIdx: integer; const Value: word);
    procedure SetSerialNum(const Value: LongWord);
  protected
    FIdx:integer;//Индекс в массиве построения компонентов - Z уровень
    FSerialNum:LongWord;//Серийный номер компонента
    FAFTypeSet:TAppFunctionalTypeSet;//Набор подключенных функциональных свойств (функций)
    FAFIdx:integer;//Функциональный индекс - индекс, работающий в бизнеслогике
    FControlType:TControlType;//Тип компонента (Датчик, Эталонный расходомер,  Насос, УПП и т.п.)
    FPort:array[0..cMaxModules-1] of word;  //в Modbus TCP номер порта TCP сокета = 502, в Modbus ASCII и RTU номер последовательного порта
    FAddress:array[0..cMaxModules-1] of integer;//в Modbus TCP адрес сервера, в Modbus ASCII/RTU номер Slave
    FBaudRate:array[0..cMaxModules-1] of Cardinal;//в Modbus ASCII/RTU - сорость обмена
    FInputRegister:array[0..cMaxModules-1] of word;//в Modbus адрес регистра параметров только на чтение
    FOutputRegister:array[0..cMaxModules-1] of word;//в Modbus адрес регистра параметров на чтение и запись
    FTypeOfProtocol:array[0..cMaxModules-1] of TTypeOfProtocol;//типы протоколов
    FModuleType:array[0..cMaxModules-1] of TFMXModuleType;
    FFirst:boolean;
    function GetState: String;virtual;
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
  public
    property Port[AIdx:integer]:word read GetComPort write SetComPort;
    //Тип модуля
    property ModuleType[AIdx:integer]:TFMXModuleType read GetModuleType write SetModuleType;
    // Адрес модуля, к которому подключено устройство.
    property Address[AIdx:integer]: integer read GetAddress write SetAddress;
    // Скорость модуля, к которому подключено устройство.
    property BaudRate[AIdx:integer]: Cardinal read GetBaudRate write SetBaudRate;
    // Тип протокола
    property TypesOfProtocol[AIdx:integer]: TTypeOfProtocol read GetTypeOfProtocol write SetTypeOfProtocol;

    property InputRegister[AIdx:integer]:word read GetModbusInputReg write SetModbusInputReg;

    property OutputRegister[AIdx:integer]:word read GetModbusOutputReg write SetModbusOutputReg;
  published
    property ControlType:TControlType  read GetControlType write SetControlType;
    property Idx:integer read GetIdx write SetIdx;
    property AFTypeSet:TAppFunctionalTypeSet read GetAFTypeSet write SetAFTypeSet;
    property AFIdx:integer read GetAFIdx write SetAFIdx;
    property DefaultState:integer read FDefaultState write SetDefaultState;
    // Возможность редактирования
    property First:boolean read GetFirst write SetFirst;
    property VisibleSensors:boolean read FVisibleSensors write SetVisibleSensors;
    property FONT_SIZE:Integer read FFONT_SIZE write SetFONT_SIZE;
    property State:String read GetState;
    property TypeOfAppFunc:TTypeOfAppFunc read FTypeOfAppFunc write SetTypeOfAppFunc;
    property DesignMode:Boolean read FDesignMode write SetDesignMode default False;
    property SerialNum:LongWord read GetSerialNum write SetSerialNum;
    property ShowHint;
    property Caption;
    property Hint;
    property OnKeyDown;
    property OnClick;
    property OnMouseUp;
    property OnMouseDown;
    property OnMouseMove;
    property PopUpMenu;
    property Information:string read GetInformation;

  end;

implementation
uses
  System.SysUtils;
{ TFMXDeviceCustomControl }

function TFMXDeviceCustomControl.GetAddress(AIdx: integer): integer;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FAddress[AIdx]
  else
     result:=0;
end;

function TFMXDeviceCustomControl.GetAFIdx: integer;
begin
  result:=FAFIdx;
end;

function TFMXDeviceCustomControl.GetAFTypeSet: TAppFunctionalTypeSet;
begin
  result:=FAFTypeSet;
end;

function TFMXDeviceCustomControl.GetBaudRate(AIdx: integer): Cardinal;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FBaudrate[AIdx]
  else
     result:=0;
end;

function TFMXDeviceCustomControl.GetIdx: integer;
begin
  result:=FIdx;
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

function TFMXDeviceCustomControl.GetModuleType(AIdx: integer): TFMXModuleType;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FModuleType[AIdx]
  else
     result:=mtNone;
end;

function TFMXDeviceCustomControl.GetControlType: TControlType;
begin
  result:=FControlType;
end;


function TFMXDeviceCustomControl.GetFirst: boolean;
begin
  result:=FFirst;
end;

function TFMXDeviceCustomControl.GetSerialNum: LongWord;
begin
  result:=FSerialNum;
end;

function TFMXDeviceCustomControl.GetState: String;
begin
  result:=Caption;
end;

function TFMXDeviceCustomControl.GetInformation: string;
begin
 result:=Name+cDiv+ClassName+cDiv+
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
         IntToStr(ord(TypesOfProtocol[0]))+cDiv+
         IntToStr(InputRegister[0])+cDiv+
         IntToStr(OutputRegister[0])+cDiv+

         IntToStr(Port[1])+cDiv+
         IntToStr(Address[1])+cDiv+
         IntToStr(BaudRate[1])+cDiv+
         IntToStr(Ord(ModuleType[1]))+cDiv+
         IntToStr(ord(TypesOfProtocol[1]))+cDiv+
         IntToStr(InputRegister[1])+cDiv+
         IntToStr(OutputRegister[1])+cDiv+

         IntToStr(Port[2])+cDiv+
         IntToStr(Address[2])+cDiv+
         IntToStr(BaudRate[2])+cDiv+
         IntToStr(Ord(ModuleType[2]))+cDiv+
         IntToStr(ord(TypesOfProtocol[2]))+cDiv+
         IntToStr(InputRegister[2])+cDiv+
         IntToStr(OutputRegister[2])+cDiv+

         IntToStr(Ord(ControlType))+cDiv+
         IntToStr(DefaultState)+cDiv+
         IntToStr(FONT_SIZE)+cDiv+
         IntToStr(ord(TypeOfAppFunc))+cDiv+
         IntToStr(Ord(AFIdx));
end;


function TFMXDeviceCustomControl.GetTypeOfProtocol(
  AIdx: integer): TTypeOfProtocol;
begin
  if AIdx in [0..cMaxModules-1]  then
     result:=FTypeOfProtocol[AIdx]
  else
     result:=tpProprietary;
end;

procedure TFMXDeviceCustomControl.SetAddress(AIdx: integer;
  const Value: integer);
begin
  if AIdx in [0..cMaxModules-1]  then
     FAddress[AIdx]:=Value;
end;

procedure TFMXDeviceCustomControl.SetAFIdx(const Value: integer);
begin
  FAFIdx:=Value;
end;

procedure TFMXDeviceCustomControl.SetAFTypeSet(
  const Value: TAppFunctionalTypeSet);
begin
  FAFTypeSet:=Value;
end;

procedure TFMXDeviceCustomControl.SetBaudRate(AIdx: integer;
  const Value: Cardinal);
begin
  if AIdx in [0..cMaxModules-1]  then
     FBaudRate[AIdx]:=Value;
end;

procedure TFMXDeviceCustomControl.SetIdx(const Value: integer);
begin
  FIdx:=Value;
end;

procedure TFMXDeviceCustomControl.SetComPort(AIdx: integer; const Value: word);
begin
  if AIdx in [0..cMaxModules-1]  then
     FPort[AIdx]:=Value;
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

procedure TFMXDeviceCustomControl.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  if AIdx in [0..cMaxModules-1]  then
     FModuleType[AIdx]:=Value;
end;

procedure TFMXDeviceCustomControl.SetSerialNum(const Value: LongWord);
begin
  FSerialNum:=Value;
end;

procedure TFMXDeviceCustomControl.SetControlType(const Value: TControlType);
begin
  FControlType:=Value;
end;

procedure TFMXDeviceCustomControl.SetDefaultState(const Value: integer);
begin
  FDefaultState := Value;
end;

procedure TFMXDeviceCustomControl.SetDesignMode(const Value: Boolean);
begin
  FDesignMode := Value;
end;


procedure TFMXDeviceCustomControl.SetFirst(const Value: boolean);
begin

end;

procedure TFMXDeviceCustomControl.SetFONT_SIZE(const Value: Integer);
begin
  FFONT_SIZE := Value;
end;

procedure TFMXDeviceCustomControl.SetTypeOfAppFunc(const Value: TTypeOfAppFunc);
begin
  FTypeOfAppFunc := Value;
end;

procedure TFMXDeviceCustomControl.SetTypeOfProtocol(AIdx: integer;
  const Value: TTypeOfProtocol);
begin

end;

procedure TFMXDeviceCustomControl.SetVisibleSensors(const Value: boolean);
begin
  FVisibleSensors := Value;
end;


end.
