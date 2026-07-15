unit FmxFPModule;

{ ===== Класс TFmxModule =====
  Класс является родительским классом для всех классов модулей. Это интерфейс, который должны реализовывать все
  модули. Однажды создав модуль, его следует уничтожить только в конце работы приложения, т.к. при уничтожении
  каждый модуль уничтожает поток работы с COM-портом, т.е. делает невозможной работу остальных модулей.
  LogoDAC - модуль ЦАП от Логомасс на ESP32
}

interface

uses
  System.SysUtils,
  FmxModbusHelper,
  FmxModbusTypes,
  uProcedureOfObject;

type
  TPortType = (ptCOM, ptBRK, ptTCP);
  TFmxDeviceQuality=(fdqGood,fdqBad,fdqDisguise);
  TConnectionInfo = record
    PortType: TPortType;
    PortDomen: string;
    PortNumber: Integer;
  end;

  TTypeOfProtocol = (tpProprietary, tpModbusRTU, tpModbusASCII, tpModbusTCP);
  // Тип, используемый для определения типа модуля.
  TFmxModuleType = (mtCounter, mtCounterEx, mtFCD, mtFCD2, mtProver, mtScales,
    mtScalesMT, mtSuperBIO, mtT, mtTemp2, mtTemp6, mtUI, mtOldUI, mtValve,
    mtVLT6000, mtATV312, mtDAC_I702X, mtWarm, mtDigitalUnit, mtFastwelUI,
    mtManual, mtIVTM, mtHeat, mtAgat, mtSwitch, mtTEXT, mtKM5, mtRT2,
    mtVLTModbus, mtLogoDAC, mtVaconModbus, mtHSC_CTRL, mtHSC_IMP, mtHSC_FCD,
    mtBIO, mtModbusD, mtModbusA, mtLTA, mtScalesAD103, mtScalesRADWAG,mtABBModbus,
    mtADC_I70XX,mtDeltaModbus, mtNone);
  TComParity = (cpNone,cpOdd,cpEven,cpMark,cpSpace);

const
   //TFmxModuleType
   cNone='NONE';
   cODD='ODD';
   cEVEN='EVEN';
   cMARK='MARK';
   cSPACE='SPACE';
   cComParityName:array[TComParity] of ShortString=(cNone,cODD,cEVEN,cMARK,cSPACE);
   сmtCounter='Счетчик (Гидродинамика)';
   cmtCounterEx='Счетчик (Логомасс)';
   cmtFCD='УПП (Гидродинамика)';
   сmtFCD2='УПП (Логомасс)';
   cmtProver='Prover';
   cmtScales='Весы (Логомасс)';
   cmtScalesMT='Весы (МТоледо)';
   cmtSuperBIO='Дискр.IO (Логомасс)';
   cmtT='Температура (Гидродинамика)';
   cmtTemp2='Температура (Гидродинамика[2])';
   cmtTemp6='Температура (Логомасс[6])';
   cmtUI='АЦП (Логомасс)';
   сmtOldUI='АЦП (Гидродинамика)';
   cmtValve='Эл.Задв. (Гидродинамика)';
   cmtVLT6000='Частотник (VLT-FC)';
   cmtATV312='Частотник (ATV312)';
   cmtDAC_I702X='ЦАП (I702X)';
   сmtWarm='Warm';
   cmtDigitalUnit='DigitalUnit';
   cmtFastwelUI='FastwelUI';
   сmtManual='Ручной ввод';
   cmtIVTM='Барометр ИВТМ7';
   cmtHeat='Heat';
   cmtAgat='Agat';
   cmtSwitch='SWITCH';
   cmtTEXT='TEXT';
   cmtKM5='KM5 (ТБН)';
   cmtRT2='РТ2 (ТБН)';
   cmtVLTModbus='Частотник (VLT-M)';
   cmtLogoDAC='ЦАП (Логомасс)';
   cmtVaconModbus='Частотник (Vacon)';
   cmtHSC_CTRL='Дискр.IO (Актек)';
   cmtHSC_IMP='Счетчик (Актек)';
   cmtHSC_FCD='УПП (Актек)';
   cmtBIO='Дискр.IO (Нептун)';
   cmtModbusD='ModbusD';
   cmtModbusA='ModbusA';
   cmtLTA='LTA';
   cmtScalesAD103='Весы (AD103)';
   cmtScalesRADWAG='Весы (RADWAG)';
   cmtABBModbus='Частотник (ABB)';
   cmtDeltaModbus='Частотник (Delta MS300)';
   cmtADC_I70XX='АЦП (I70XX)';
   cmtNone='???';
   //TTypeOfProtocol
   ctpProprietary='Частный';
   ctpModbusRTU='Modbus RTU';
   ctpModbusASCII='Modbus ASCII';
   ctpModbusTCP='Modbus TCP';


//   Старое соответствие имен
//  cModuleName:array[TFmxModuleType]of ShortString=('Counter','CounterEx','FCD',
//   'FCD2','Prover','Scales','ScalesMT','SuperBIO','T','Temp2','Temp6','UI',
//   'OldUI','Valve','VLT6000','ATV312','DAC_I702X','Warm','DigitalUnit','FastwelUI','Manual',
//   'IVTM','Heat', 'Agat','SWITCH','TEXT','KM5','RT2','VLTModbus','LogoDAC','VaconModbus',
//   'HSC_CTRL','HSC_IMP','HSC_FCD','BIO','ModbusD','ModbusA','LTA','ScalesAD103','ScalesRADWAG','ABBModbus','???');
//   Новое соответствие имен
  cTypeOfProtocolNames:array[TTypeOfProtocol] of ShortString=(ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP);

  cModuleTypeNames:array[TFmxModuleType]of ShortString=(
   сmtCounter,cmtCounterEx,cmtFCD,сmtFCD2,cmtProver,cmtScales,cmtScalesMT,cmtSuperBIO,
   cmtT,cmtTemp2,cmtTemp6,cmtUI,сmtOldUI,cmtValve,cmtVLT6000,cmtATV312,cmtDAC_I702X,сmtWarm,cmtDigitalUnit,
   cmtFastwelUI,сmtManual,cmtIVTM,cmtHeat,cmtAgat,cmtSwitch,cmtTEXT,cmtKM5,cmtRT2,cmtVLTModbus,cmtLogoDAC,
   cmtVaconModbus,cmtHSC_CTRL,cmtHSC_IMP,cmtHSC_FCD,cmtBIO,cmtModbusD,cmtModbusA,cmtLTA,cmtScalesAD103,
   cmtScalesRADWAG,cmtABBModbus,cmtADC_I70XX,cmtDeltaModbus,cmtNone
   );

type
  // Тип записи дополнительного получателя ответов от модуля-устройства.
  TReceiver = record
    // Указатель на вызываемый метод.
    Method: TProcedureOfObject;

    // Флаг необходимости вызова метода в основном потоке приложения.
    UseMainThread: Boolean;
  end;

  // ============================================================================================================

  TFmxModule = class

  private

    // Массив указателей на дополнительные получатели ответов от модуля-устройства. При получении любого
    // ответа от модуля-устройства метод ReceiveResponse помимо обработки ответа вызывает все дополнительные
    // получатели по-порядку в соответствующем потоке программы.
    // Строка запроса статуса модуля-устройства, полностью приведенная в формат протокола.
    Receivers: array of TReceiver;
    FBaudRate: Cardinal;
    FParity: TComParity;
    FReceived: longword;
    FSended: longword;
    FModuleType: TFmxModuleType;
    FDevicesCount: integer;
    FPortNumber: integer;
    FLastDevice: TObject;
    FKeepLastDevice: Boolean;
    FDebug: Boolean;
    FTimeOuts: longword;
    FBadPackages: longword;
    FBadCRC: longword;
    FLastReceived: byte;
    FProtocol: TTypeOfProtocol;
    FOutputRegister: integer;
    FInputRegister: integer;
    FPreviousAnswerCRC: word;
    FLastUpdateNextTime: Extended;
    FLastAnswerCRC: word;
    // некоторые платы будут у нас работать на 2х установках,
    // будем вручную перекидывать интерфейс, и делать так, что бы отключенная
    // плата в программе виделась бы как рабочая
    // обзовем это все маскировкой
    FDisguise: Boolean;
    FRequestTime: Cardinal;
    FLastPollTime: TDateTime;
    FPriority: integer;
    FUpdateTime: Cardinal;
    FReadTime: Cardinal;
    FStatusQueryCount: Longint;
    FTerminatedChar: AnsiChar;
    FTransactionID: Word;
    FMaxInputRegs: byte;
    FBaseRegister: word;
    FRequestedModBusFunction: TModBusFunction;
    FUnitID: byte;
    FPriorityCounter: integer;
    FModbusFormat: TModBusDataFormat;
    FMaxChannels: byte;
    FConnectionString: string;
    FInfo: TConnectionInfo;
    procedure SetBaudRate(const Value: Cardinal);
    function GetBaudrate: Cardinal;
    procedure SetResponseLength(const Value: byte);
    procedure SetReceived(const Value: longword);
    procedure SetSended(const Value: longword);
    procedure SetEnabledAutoUpdate(const Value: Boolean);
    procedure SetASCII(const Value: Boolean);
    procedure SeTFmxModuleType(const Value: TFmxModuleType);
    procedure SetDevicesCount(const Value: integer);
    procedure SetPortNumber(const Value: integer);
    procedure SetConnectIsOK(const Value: TFmxDeviceQuality);
    procedure SetStatusQuery(const Value: ShortString);
    function GetConnectIsOK: TFmxDeviceQuality;
    procedure SetLastDevice(const Value: TObject);
    procedure SetKeepLastDevice(const Value: Boolean);
    procedure SetDebug(const Value: Boolean);
    procedure SetTimeOuts(const Value: longword);
    procedure SetBadPackages(const Value: longword);
    procedure SetBadCRC(const Value: longword);
    procedure SetLastReceived(const Value: byte);
    procedure SetProtocol(const Value: TTypeOfProtocol);
    procedure SetInputRegister(const Value: integer);
    procedure SetOutputRegister(const Value: integer);
    function GetParity: TComParity;
    procedure SetParity(const Value: TComParity);
    procedure SetLastAnswerCRC(const Value: word);
    procedure SetLastUpdateNextTime(const Value: Extended);
    procedure SetPreviousAnswerCRC(const Value: word);
    function GetConnectIdGood: Boolean;
    procedure SetConnectIsGood(const Value: Boolean);
    procedure SetDisguise(const Value: Boolean);
    function GetDisguise: Boolean;
    procedure SetRequestTime(const Value: Cardinal);
    procedure SetLastPollTime(const Value: TDateTime);
    procedure SetPriority(const Value: integer);
    procedure SetReadTime(const Value: Cardinal);
    procedure SetUpdateTime(const Value: Cardinal);
    procedure SetStatusQueryCount(const Value: Longint);
    procedure SetTerminatedChar(const Value: AnsiChar);
    procedure SetBaseRegister(const Value: word);
    procedure SetMaxInputRegs(const Value: byte);
    procedure SetRequestedModBusFunction(const Value: TModBusFunction);
    procedure SetTransactionID(const Value: Word);
    procedure SetUnitID(const Value: byte);
    procedure SetPriorityCounter(const Value: integer);
    function GetNeedUpdate: boolean;
    procedure SetMustUpdate(const Value: boolean);
    procedure SetCountOfUpdate(const Value: byte);
    procedure SetModbusFormat(const Value: TModBusDataFormat);
    procedure SetConnectionString(const Value: string);
    function ParseConnectionString(const S: string): Boolean;
    procedure SetInfo(const Value: TConnectionInfo);

  protected
    FCountOfUpdate:byte;
    FMustUpdate:boolean;
    FResponseLength: byte;
    FErrorCode: TModbusExceptionCode;
    FASCII: Boolean;
    FStatusQuery: ShortString;
    ModuleManager: Pointer;// Указатель на используемый менеджер модулей.
    function GetStatusQuery: ShortString; virtual;
    procedure SetAddress(const Value: longword); virtual;
    function GetASCII: Boolean; virtual;
    function GeTFmxModuleName: ShortString; virtual;
    function GetNewTransactionID: Word;
    function GetMaxChannels: byte;virtual;
    procedure SetMaxChannels(const Value: byte);virtual;

  public
    // Адрес модуля-устройства.
    FAddress: longword;

    // Скорость, на которой модуль-устройство общается с ПК.
    xBaudRate: Cardinal;

    // Флаг корректной связи с модулем-устройством.
    // В отличие от остальных полей не используется менеджером модулей.
    FConnectIsOK: TFmxDeviceQuality;

    // Флаг разрешения постоянного обновления статуса.
    FEnabledAutoUpdate: Boolean;

    // Максимальное время ожидания ответа от модуля-устройства в мс.
    Timeout: Word;

    // Конструктор в потомках должен вызываться после определения полей, которые объявляет класс TFmxModule.
    constructor Create(AModuleType: TFmxModuleType;
      _Protocol: TTypeOfProtocol = tpProprietary; AASCII: Boolean = true);
    destructor Destroy; override;

    { ===== AddReceiver =====
      Добавляет дополнительный получатель ответов от модуля-устройства.
      Принимаемые параметры:
      method - указатель на метод, являющийся дополнительным получателем ответа от модуля-устройства; если
      равен nil, то не добавится;
      use_main_thread - флаг необходимости вызова метода в основном потоке приложения.
    }
    procedure AddReceiver(Method: TProcedureOfObject; use_main_thread: Boolean);

    { ===== CheckResponse =====
      Проверяет корректность ответа на запрос в соотствии с используемым модулем протоколом.
      Принимаемые параметры:
      command - команда, ответ на которую проверяется;
      response - проверяемый ответ ответ.
      Возвращает true  в случае успешности проверки.
    }
    function CheckResponse(command, response: ShortString): Boolean;
      virtual; abstract;

    { ===== ReceiveResponse =====
      Метод приема и обработки ответа модуля-устройства на команду.
      Принимаемые параметры:
      command - строка-команда, ответ на которую получен;
      response - строка, полученная от модуля-устройства в качестве ответа на команду.
      Этот метод вызывается менеджером модулей при получении ответа от модуля-устройства на любую команду. По
      истечении таймаута вызывается даже если ответ меньше ожидаемого размера. Если произошла ошибка при работе
      с COM-портом, вызывается с пустой строкой в качестве параметра response.
    }
    procedure ReceiveResponse(command: ShortString = '';
      response: ShortString = ''); virtual;

    property BaudRate: Cardinal read GetBaudrate write SetBaudRate;

    property Parity: TComParity read GetParity write SetParity;

    // Максимальная длина полного (с учетом формата протокола) ответа от модуля-устройства на запрос статуса.
    // В символах.
    property ResponseLength: byte read FResponseLength write SetResponseLength;

    property Address: longword read FAddress write SetAddress;

    property LastReceived: byte read FLastReceived write SetLastReceived;

    property TotalReceived: longword read FReceived write SetReceived;

    property TotalSended: longword read FSended write SetSended;

    property TimeOuts: longword read FTimeOuts write SetTimeOuts;

    property BadPackages: longword read FBadPackages write SetBadPackages;

    property BadCRC: longword read FBadCRC write SetBadCRC;

    property EnabledAutoUpdate: Boolean read FEnabledAutoUpdate
      write SetEnabledAutoUpdate;

    property ModuleType: TFmxModuleType read FModuleType write SeTFmxModuleType;

    property ASCII: Boolean read GetASCII write SetASCII;

    property ModuleName: ShortString read GeTFmxModuleName;

    property DevicesCount: integer read FDevicesCount write SetDevicesCount;

    property PortNumber: integer read FPortNumber write SetPortNumber;

    property ConnectIsOK: TFmxDeviceQuality read GetConnectIsOK write SetConnectIsOK;

    property ConnectIsGood:Boolean read GetConnectIdGood write SetConnectIsGood;

    // Строка запроса статуса модуля-устройства, полностью приведенная в формат протокола.
    property StatusQuery: ShortString read GetStatusQuery write SetStatusQuery;

    property LastDevice: TObject read FLastDevice write SetLastDevice;

    property KeepLastDevice: Boolean read FKeepLastDevice
      write SetKeepLastDevice;

    property Debug: Boolean read FDebug write SetDebug;

    property Protocol: TTypeOfProtocol read FProtocol write SetProtocol;

    property InputRegister: integer read FInputRegister write SetInputRegister;

    property OutputRegister: integer read FOutputRegister
      write SetOutputRegister;

    property LastUpdateNextTime:Extended read FLastUpdateNextTime write SetLastUpdateNextTime;

    property LastAnswerCRC:word read FLastAnswerCRC write SetLastAnswerCRC;

    property PreviousAnswerCRC:word read FPreviousAnswerCRC write SetPreviousAnswerCRC;

    // некоторые платы будут у нас работать на 2х установках,
    // будем вручную перекидывать интерфейс, и делать так, что бы отключенная
    // плата в программе виделась бы как рабочая
    // обзовем это все маскировкой
    property Disguise: Boolean read GetDisguise write SetDisguise;

    property RequestTime:Cardinal read FRequestTime write SetRequestTime;

    property UpdateTime:Cardinal read FUpdateTime write SetUpdateTime;

    property ReadTime:Cardinal read FReadTime write SetReadTime;

    property LastPollTime:TDateTime read FLastPollTime write SetLastPollTime;

    property Priority:integer read FPriority write SetPriority;

    property PriorityCounter:integer read FPriorityCounter write SetPriorityCounter;

    property StatusQueryCount:Longint read FStatusQueryCount write SetStatusQueryCount;

    property TerminatedChar:AnsiChar read FTerminatedChar write SetTerminatedChar;

    {
     Тип протокола
    }
    property TransactionID:Word read FTransactionID write SetTransactionID;

    property UnitID:byte read FUnitID write SetUnitID;

    property BaseRegister:word read FBaseRegister write SetBaseRegister;

    property RequestedModBusFunction: TModBusFunction read FRequestedModBusFunction write SetRequestedModBusFunction;

    property MaxInputRegs:byte read FMaxInputRegs write SetMaxInputRegs;//Количество регистров для чтения статуса

    property ErrorCode:TModbusExceptionCode read FErrorCode write FErrorCode;

    property NeedUpdate:boolean read GetNeedUpdate;

    property MustUpdate:boolean read FMustUpdate write SetMustUpdate;

    property CountOfUpdate:byte read FCountOfUpdate write SetCountOfUpdate;

    property ModbusFormat: TModBusDataFormat read FModbusFormat write SetModbusFormat;

    property MaxChannels: byte read GetMaxChannels write SetMaxChannels;

    property ConnectionString:string read FConnectionString write SetConnectionString;

    property Info: TConnectionInfo read FInfo write SetInfo;
  end;

function CheckProtocol(const Value:TTypeOfProtocol):TTypeOfProtocol;
function StrToParity(Value:String):TComParity;

implementation

uses
  FmxFPModuleManager,FMXHelper;

var
  FmxFPModuleError:string;


// ============================================================================================================
// ============================================================================================================

constructor TFmxModule.Create(AModuleType: TFmxModuleType;
  _Protocol: TTypeOfProtocol = tpProprietary; AASCII: Boolean = true);
begin
  FDevicesCount := 1; // минимум одно устройство, вызвавшее создание модуля
  FKeepLastDevice := False;
  FModuleType := AModuleType;
  Protocol := _Protocol;
  ASCII := AASCII;
  SetLength(Receivers, 0);
  ConnectIsOK := fdqGood;
  CountOfUpdate:=0;
  FDisguise:=False;
  Parity := TComParity.cpNone;
  FStatusQueryCount := 0;
  TerminatedChar:=#0;
  PriorityCounter:=0;
  ModbusFormat:=mdf_1_0_3_2;
  if Assigned(ModuleManager) then
    TFmxModuleManager(ModuleManager).AddModule(Self);
end;

// ============================================================================================================

destructor TFmxModule.Destroy;
begin
  TFmxModuleManager(ModuleManager).TerminateCOMThread;
  SetLength(Receivers, 0);
  inherited Destroy;
end;

// ============================================================================================================

procedure TFmxModule.AddReceiver(Method: TProcedureOfObject;
  use_main_thread: Boolean);
begin
  try
    if Assigned(Method) and Assigned(ModuleManager) then
    begin
      TFmxModuleManager(ModuleManager).SuspendCOMThread;
      SetLength(Receivers, Length(Receivers) + 1);
      Receivers[Length(Receivers) - 1].Method := Method;
      Receivers[Length(Receivers) - 1].UseMainThread := use_main_thread;
      TFmxModuleManager(ModuleManager).ResumeCOMThread;
    end;
  except
    on e:Exception do
      FmxFPModuleError:='Ошибка в FmxFPModuleError E:'+e.Message;
  end;
end;

// ============================================================================================================

procedure TFmxModule.ReceiveResponse(command: ShortString = '';
  response: ShortString = '');
//var
//  i: byte;
//begin
//  for i := 1 to Length(Receivers) do
//    if Receivers[i - 1].UseMainThread then
//      TFmxModuleManager(ModuleManager).ExecuteInMainThread(Receivers[i - 1].Method)
//    else
//      TFmxModuleManager(ModuleManager).ExecuteInCOMThread(Receivers[i - 1].Method);
//end;
var
  i: Byte;
  LastCRC:Word;
begin
  LastCRC:=CRC32(response);
  Inc(FCountOfUpdate);
//  //Если ответ отличается от крайнего
//  if (LastAnswerCRC<>LastCRC) or    //Ответ отличается от предыдущего
//     (LastAnswerCRC<>PreviousAnswerCRC) or //Ответ отличается от предпредыдущего
//     (ModuleType in [mtCounter, mtCounterEx,mtScales,mtHSC_IMP,mtScalesAD103,mtScalesRADWAG])//или модуль, который может использовать фильтр
////     (not TFmxModuleManager(ModuleManager).Optimization)//отключена оптимизация
//  then begin
    LastAnswerCRC:=LastCRC;
    for i:=1 to Length(Receivers) do
      if Receivers[i-1].UseMainThread then
        TFmxModuleManager(ModuleManager).ExecuteInMainThread(Receivers[i-1].Method,'ReceiveResponse')
      else
        TFmxModuleManager(ModuleManager).ExecuteInCOMThread(Receivers[i-1].Method);
//  end;
end;


// ============================================================================================================

procedure TFmxModule.SetBadCRC(const Value: longword);
begin
  FBadCRC := Value;
end;

procedure TFmxModule.SetBadPackages(const Value: longword);
begin
  FBadPackages := Value;
end;

procedure TFmxModule.SetBaseRegister(const Value: word);
begin
  FBaseRegister := Value;
end;

procedure TFmxModule.SetBaudRate(const Value: Cardinal);
begin
  FBaudRate := Value;
end;

procedure TFmxModule.SetConnectIsGood(const Value: Boolean);
begin
  if Value then
     ConnectIsOK := fdqGood
  else
     ConnectIsOK := fdqBad;
end;

procedure TFmxModule.SetConnectIsOK(const Value: TFmxDeviceQuality);
begin
  if FConnectIsOK <> Value then
  begin
    FConnectIsOK := Value;
    MustUpdate:=True;
  end;
end;


procedure TFmxModule.SetCountOfUpdate(const Value: byte);
begin
  FCountOfUpdate := Value;
end;

procedure TFmxModule.SetParity(const Value: TComParity);
begin
  FParity := Value;
end;

procedure TFmxModule.SetPortNumber(const Value: integer);
begin
  FPortNumber := Value;
end;

procedure TFmxModule.SetConnectionString(const Value: string);
begin
  if (Value<>'') and (FConnectionString<>Value)  then
  begin
    FConnectionString:=Value;
    ParseConnectionString(Value);
  end;
end;

procedure TFmxModule.SetPreviousAnswerCRC(const Value: word);
begin
  FPreviousAnswerCRC := Value;
end;


procedure TFmxModule.SetPriority(const Value: integer);
begin
  FPriority := Value;
end;

procedure TFmxModule.SetPriorityCounter(const Value: integer);
begin
  FPriorityCounter := Value;
end;

procedure TFmxModule.SetProtocol(const Value: TTypeOfProtocol);
begin
  FProtocol := Value;
end;

procedure TFmxModule.SetDebug(const Value: Boolean);
begin
  FDebug := Value;
end;

procedure TFmxModule.SetDevicesCount(const Value: integer);
begin
  FDevicesCount := Value;
end;

procedure TFmxModule.SetDisguise(const Value: Boolean);
begin
  FDisguise := Value;
  MustUpdate:=True;
end;

function TFmxModule.GetASCII: Boolean;
begin
  result := FASCII;
end;

function TFmxModule.GetBaudrate: Cardinal;
begin
  if FBaudRate > 0 then
    result := FBaudRate
  else
    result := 115200;
end;

function TFmxModule.GetConnectIdGood: Boolean;
begin
  result:=ConnectIsOK in [fdqGood,fdqDisguise];
end;

function TFmxModule.GetConnectIsOK: TFmxDeviceQuality;
begin
  result := fdqGood;
  if  ModuleType=mtManual then
     Exit
  else
    if TotalSended > 0 then
    begin
      if LastReceived > 0 then
        result := FConnectIsOK
      else
      begin
        if Disguise then
          FConnectIsOK := fdqDisguise
        else
          FConnectIsOK := fdqBad;
        result := FConnectIsOK;
      end;
    end;
end;

function TFmxModule.GetDisguise: Boolean;
begin
  result:=FDisguise;
end;

function TFmxModule.GeTFmxModuleName: ShortString;
begin
  result := cModuleTypeNames[FModuleType];
end;

function TFmxModule.GetParity: TComParity;
begin
  result := FParity;
end;

function TFmxModule.GetStatusQuery: ShortString;
begin
  result := FStatusQuery;
  Inc(FStatusQueryCount);
end;

procedure TFmxModule.SetResponseLength(const Value: byte);
begin
  FResponseLength := Value;
end;

procedure TFmxModule.SetAddress(const Value: longword);
begin
  FAddress := Value;
end;

procedure TFmxModule.SetASCII(const Value: Boolean);
begin
  FASCII := Value;
end;

procedure TFmxModule.SetReadTime(const Value: Cardinal);
begin
  FReadTime := Value;
end;

procedure TFmxModule.SetReceived(const Value: longword);
begin
  FReceived := Value;
  if LastReceived < 10 then
    LastReceived := LastReceived + 1;
end;

procedure TFmxModule.SetRequestedModBusFunction(const Value: TModBusFunction);
begin
  FRequestedModBusFunction := Value;
end;

procedure TFmxModule.SetRequestTime(const Value: Cardinal);
begin
  FRequestTime := Value;
end;

procedure TFmxModule.SetSended(const Value: longword);
begin
  FSended := Value;
end;

procedure TFmxModule.SetStatusQuery(const Value: ShortString);
begin
  FStatusQuery := Value;
end;

procedure TFmxModule.SetStatusQueryCount(const Value: Longint);
begin
  FStatusQueryCount := Value;
end;

procedure TFmxModule.SetTerminatedChar(const Value: AnsiChar);
begin
  FTerminatedChar := Value;
end;

procedure TFmxModule.SetTimeOuts(const Value: longword);
begin
  if FTimeOuts <> Value then
  begin
    // если идет нарастание ошибки - уменьшаем количество удачно принятых
    if (Value > FTimeOuts) and (LastReceived > 0) then
      LastReceived := LastReceived - 1;
    FTimeOuts := Value;
  end;
end;

procedure TFmxModule.SetMaxChannels(const Value: byte);
begin
  FMaxChannels := Value;
end;

procedure TFmxModule.SetTransactionID(const Value: Word);
begin
  FTransactionID := Value;
end;

procedure TFmxModule.SetUnitID(const Value: byte);
begin
  FUnitID := Value;
end;

procedure TFmxModule.SetUpdateTime(const Value: Cardinal);
begin
  FUpdateTime := Value;
end;

procedure TFmxModule.SetEnabledAutoUpdate(const Value: Boolean);
begin
  FEnabledAutoUpdate := Value;
end;

procedure TFmxModule.SetInfo(const Value: TConnectionInfo);
begin
  FInfo := Value;
end;

procedure TFmxModule.SetInputRegister(const Value: integer);
begin
  FInputRegister := Value;
end;

procedure TFmxModule.SetKeepLastDevice(const Value: Boolean);
begin
  FKeepLastDevice := Value;
end;

procedure TFmxModule.SetLastAnswerCRC(const Value: word);
begin
  PreviousAnswerCRC:=FLastAnswerCRC;
  FLastAnswerCRC := Value;
end;

procedure TFmxModule.SetLastDevice(const Value: TObject);
begin
  if FKeepLastDevice and (not Assigned(Value)) then
    Exit;
  FLastDevice := Value;
end;

procedure TFmxModule.SetLastPollTime(const Value: TDateTime);
begin
  FLastPollTime := Value;
end;

procedure TFmxModule.SetLastReceived(const Value: byte);
begin
  FLastReceived := Value;
end;

procedure TFmxModule.SetLastUpdateNextTime(const Value: Extended);
begin
  FLastUpdateNextTime := Value;
end;

procedure TFmxModule.SetMaxInputRegs(const Value: byte);
begin
  FMaxInputRegs := Value;
end;


procedure TFmxModule.SetModbusFormat(const Value: TModBusDataFormat);
begin
  FModbusFormat := Value;
end;

procedure TFmxModule.SetMustUpdate(const Value: boolean);
begin
  FMustUpdate := Value;
  if Value then
  begin
     CountOfUpdate:=0;
     PriorityCounter:=0;
  end;
end;

procedure TFmxModule.SeTFmxModuleType(const Value: TFmxModuleType);
begin
  FModuleType := Value;
end;

procedure TFmxModule.SetOutputRegister(const Value: integer);
begin
  FOutputRegister := Value;
end;

function TFmxModule.GetMaxChannels: byte;
begin
  result:=FMaxChannels;
end;

function TFmxModule.GetNeedUpdate: boolean;
begin
  result:=(CountOfUpdate<3);
end;

function TFmxModule.GetNewTransactionID: Word;
begin
  if (FTransactionID = $FFFF) then
    FTransactionID := 0
  else
    Inc(FTransactionID);
  Result := Swap16(FTransactionID);
end;


function CheckProtocol(const Value:TTypeOfProtocol):TTypeOfProtocol;
begin
  result:=tpProprietary;
  if (Value in [tpProprietary..tpModbusTCP]) then result:=Value;
end;


function StrToParity(Value:String):TComParity;
var i:integer;
begin
   result:=cpNone;
   for I := ord(cpNone) to ord(cpMark) do
   begin
     if (
          (cComParityName[TComParity(I)]=UpperCase(Value)) or
          (Value = IntToStr(i))
        ) then
     begin
       result:=TComParity(I);
       break;
     end;
   end;
end;

function TFmxModule.ParseConnectionString(const S: string): Boolean;
var
  L, R: Integer;
  Temp: string;
  tmpInfo:TConnectionInfo;
begin
  Result := False;
  tmpInfo.PortNumber := 0;
  tmpInfo.PortDomen := '';

  try
    // Проверка на COM
    if Copy(S, 1, 3) = 'COM' then
    begin
      tmpInfo.PortType := ptCOM;
      Temp := Copy(S, 4, MaxInt);
      tmpInfo.PortNumber := StrToIntDef(Temp, -1);
      Result := (tmpInfo.PortNumber >= 0);
      if Result then tmpInfo.PortDomen := '';
      Exit;
    end;

    // Проверка на BRK
    if Copy(S, 1, 3) = 'BRK' then
    begin
      tmpInfo.PortType := ptBRK;
      Temp := Copy(S, 4, MaxInt);
      L := Pos(':', Temp);
      if L > 0 then
      begin
        tmpInfo.PortDomen := Copy(Temp, 1, L - 1);
        tmpInfo.PortNumber := StrToIntDef(Copy(Temp, L + 1, MaxInt), -1);
      end
      else
      begin
        // если нет двоеточия – считаем весь остаток как domen, номер порта не указан (0?)
        tmpInfo.PortDomen := Temp;
        tmpInfo.PortNumber := 0;
      end;
      Result := (tmpInfo.PortNumber >= 0) and (tmpInfo.PortDomen <> '');
      Exit;
    end;

    // Проверка на TCP
    if Copy(S, 1, 3) = 'TCP' then
    begin
      tmpInfo.PortType := ptTCP;
      Temp := Copy(S, 4, MaxInt);
      L := Pos(':', Temp);
      if L > 0 then
      begin
        tmpInfo.PortDomen := Copy(Temp, 1, L - 1);
        tmpInfo.PortNumber := StrToIntDef(Copy(Temp, L + 1, MaxInt), -1);
        Result := (tmpInfo.PortNumber > 0) and (tmpInfo.PortDomen <> '');
      end;
      Exit;
    end;
  finally
    //Если подошел один из шаблонов
    if Result then
       Info:=tmpInfo;
  end;
end;


initialization
  FmxFPModuleError:='';


end.