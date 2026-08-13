unit FmxFPModuleManager;

{ ===== Класс TFmxModuleManager =====
  Новая архитектура: отдельные потоки для каждого COM-порта.
  Каждый порт имеет свой TPortPollThread, который синхронно опрашивает модули.
  SendCommand работает через TTransferManager (синхронно, без очереди).
}

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  System.Win.ScktComp,
  {$ENDIF}
  Classes,
  System.SyncObjs,
  System.SysUtils,
  System.Generics.Collections,
  Fmx.Forms,
  FmxFPModule,
  System.UITypes,
  DateUtils,
  FmxHelper,
  Fmx.Graphics,
  IdTCPClient,
  uTransferManager,
  uProcedureOfObject;

const
  cTimeout = 'нет ответа...';
  cSleepBeforeRead = 50;
  cMinSleepBeforeRead = 1;
  cViewIOBufMin = 20;
  cViewIOBufMax = 128;
  cUPPMaxTime = 65000;
  cErrorOpenComPortDelay = 100;
  cDelayAfterErrorFirstRequest = 10;
  c_DopTimOut = 50;
  COM_RUN_QUERY_BUFFER_LENGTH = 10;
  PORT_NUMBER = 1;
  cPortHeader = 'Порт:COM';

type
//  TComPortInfo = record
//    PortHandle: Cardinal;
//    PortNumber: integer;
//    BaudRate: integer;
//    Parity: Integer;
//    Timeout: integer;
//    IsOpen: Boolean;
//    LastUsed: TDateTime;
//    TimeOuts: Longint;
//    TotalAttempts: Longint;
//  end;

  TComPortArray = array of TComPortInfo;
  TPortStatus = (psOpen, psClose, psError);
  TComPortType = (ctMain, ctFlowmeter);

  TProcedureOfGetPortObject = procedure(var MainPort: integer; var FlowmeterPort: integer) of object;
  TLogViewerAddMessage = procedure(const AText: string; const AColor: TAlphaColor = TAlphaColorRec.Black; const AStyle: TFontStyles = []) of object;

  TSendCommandProcs = procedure(module: TFmxModule; const command: String; response_length: integer; var result: boolean) of Object;
  TUpdateNextProcs = procedure(module: TFmxModule) of Object;

  TFmxModuleManager=class;
  // ============================================================
  // Класс потока для опроса одного COM-порта (синхронный)
  // ============================================================
  TPortPollThread = class(TThread)
  private
    FManager: TFmxModuleManager;
    FPortNumber: Integer;
    procedure DoUpdateNext;
  protected
    procedure Execute; override;
  public
    constructor Create(AManager: TFmxModuleManager; APortNumber: Integer);
  end;

  TFmxModuleManager = class
  private
    // Менеджер портов (для SendCommand)
    FTransferManager: TTransferManager;

    // Потоки для каждого порта
    FPortThreads: TDictionary<Integer, TPortPollThread>;
    FPortCurrentModule: TDictionary<Integer, Integer>; // порт -> текущий индекс модуля

    // Статистика циклов
    FCycleStartTime: Cardinal;
    FLastCycleTime: Double;
    FAverageCycleTime: Double;
    FMinCycleTime: Double;
    FMaxCycleTime: Double;
    FCycleCount: Integer;
    FTotalCycleTime: Double;
    FCurrentCycleModules: Integer;

    FLogCriticalSection: TCriticalSection;

    _ViewIOBuff: array[0..cViewIOBufMax - 1] of ShortString;
    _ViewIOBuffColor: array[0..cViewIOBufMax - 1] of TAlphaColor;

    FCurrentModule: integer;
    CurrentCommandModule: integer;

    LogFile: Text;
    LogFileIsOpened: Boolean;
    LoopStartTickCount: Cardinal;
    Modules: array of TFmxModule;
    TCP_Client: TIdTCPClient;

    FLogFileName: string;
    FComPortNumber: integer;
    FOnUpdateNext: TUpdateNextProcs;
    FOnSendCommand: TSendCommandProcs;
    FOnGetPort: TProcedureOfGetPortObject;
    dummy: longword;
    FDebug: boolean;
    FSENDING_TRIES_COUNT: integer;
    FChangePort: boolean;
    CurComPortNumber: integer;
    CurFlowmeterComPortNumber: integer;
    FErrorConnection: boolean;
    FShowPortInLog: boolean;
    FShowModuleInLog: boolean;
    FPortState: ShortString;
    FPortStaus: TPortStatus;
    FNextSleep: integer;
    FFormHandle: THandle;
    FDopTimOut: integer;
    FViewIOBuffCounter: integer;
    FViewIOBuffActive: boolean;
    FViewIOBufMax: integer;
    FModbusTCPPort: word;
    FModbusTCPHost: string;
    FTCP_Client_Active: Boolean;
    FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT: Boolean;
    FPortReady: boolean;
    FPortName: ShortString;
    FUpdate: boolean;
    FDelayBeforeSendCommand: integer;
    FOptimization: Boolean;
    FOnLogViewerAddMessage: TLogViewerAddMessage;
    FTimeDebug: string;
    FClosePorts: boolean;

    // Вспомогательные методы
//    function FindComPortIndex(PortNumber: integer): integer;
//    function GetComPortInfo(PortNumber: integer; var PortInfo: TComPortInfo; var PortIndex: integer): Boolean;
//    procedure UpdateComPortInfo(const PortInfo: TComPortInfo);
//    procedure AddComPortInfo(const PortInfo: TComPortInfo);
//    procedure ClosePort;
//    procedure OpenPort;
//    function GetComPort(PortNumber, BaudRate, Parity, Timeout: integer; var PortInfo: TComPortInfo; var PortIndex: integer): Boolean;
//    procedure OpenComPort(PortNumber, BaudRate, Parity, Timeout: integer; var PortInfo: TComPortInfo; var PortIndex: integer);
//    procedure CloseComPort(PortNumber: integer);
//    procedure CloseAllComPorts;
//    procedure CleanupUnusedPorts(TimeoutMinutes: integer);
//    procedure RemoveClosedPortsFromArray;
//    function GetPortName: ShortString;

    procedure WriteToBuffer(str: ShortString; Module: TFmxModule);
    procedure UpdateNextForPort(APortNumber: Integer);
    function GetNextModuleForPort(APortNumber: Integer): TFmxModule;

    // Сеттеры и геттеры
    procedure SetOnSendCommand(const Value: TSendCommandProcs);
    procedure SetOnUpdateNext(const Value: TUpdateNextProcs);
    procedure SetOnGetPort(const Value: TProcedureOfGetPortObject);
    procedure SetComPortNumber(const Value: integer);
    procedure SetDebug(const Value: boolean);
    function GetRunQueriesCount: integer;
    function GetDebug: boolean;
    procedure SetSENDING_TRIES_COUNT(const Value: integer);
    procedure SetActive(const Value: boolean);
    procedure SetChangePort(const Value: boolean);
    procedure SetErrorConnection(const Value: boolean);
    procedure SetShowPortInLog(const Value: boolean);
    procedure SetShowModuleInLog(const Value: boolean);
    procedure SetPortState(const Value: shortString);
    procedure SetPortStaus(const Value: TPortStatus);
    procedure SetNextSleep(const Value: integer);
    procedure SetFormHandle(const Value: THandle);
    function GeTFmxModulesCount: integer;
    procedure SetDopTimOut(const Value: integer);
    function GeTFmxModule(ModuleIndex: integer): TFmxModule;
    function GetViewIOBuff(Index: integer): ShortString;
    procedure SetViewIOBuff(Index: integer; const Value: ShortString);
    procedure SetViewIOBuffCounter(const Value: integer);
    function GetViewIOBuffColor(Index: integer): TColor;
    procedure SetViewIOBuffColor(Index: integer; const Value: TColor);
    procedure SetViewIOBuffActive(const Value: boolean);
    function GetMaxViewBuffCounter: integer;
    procedure SetViewIOBufMax(const Value: integer);
    procedure SetCOMRunQueriesCount(const Value: integer);
    function GetThreadRun: integer;
    function GetCurModule: Integer;
    procedure SetCurrentModule(const Value: integer);
    function GetCurrentModule: integer;
    procedure SetModbusTCPHost(const Value: string);
    procedure SetModbusTCPPort(const Value: word);
    procedure IdTCPClientConnected(Sender: TObject);
    procedure IdTCPClientDisconnected(Sender: TObject);
    procedure SetTCP_Client_Active(const Value: Boolean);
    function TCP_Client_Connected: Boolean;
    procedure SetHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT(const Value: Boolean);
    function GetFirstActiveModule: Integer;
    procedure SetPortReady(const Value: boolean);
    procedure SetPortName(const Value: ShortString);
    procedure SetUpdate(const Value: boolean);
    procedure SetDelayBeforeSendCommand(const Value: integer);
    procedure SetOptimization(const Value: Boolean);
    function GetLogFileName: string;
    procedure SetOnLogViewerAddMessage(const Value: TLogViewerAddMessage);
    procedure SetModule(ModuleIndex: integer; const Value: TFmxModule);
    procedure SetModulesCount(const Value: integer);
    function CountActiveModules: Integer;
    procedure ResetCycleStatistics;
    procedure UpdateCycleStatistics(CycleTime: Double);
    procedure SetTimeDebug(const Value: string);
    function HasActiveModules: Boolean;
    procedure ClosePortHandle(PortHandle: Cardinal);
    procedure SetClosePorts(const Value: boolean);
    function GetComPortsCount: integer;
    function GetComPortInformation(Idx: integer): TComPortInfo;
    function IsOverallCommunicationAlive(): Boolean;
    function GetPercentOfQuality: integer;

    // Запуск потоков для портов
    procedure StartPortThreads;
    function GetMaxChannels: byte;
    procedure SetMaxChannels(const Value: byte);
    procedure UpdateNext;
    function GetOpenPortsList: TList<Integer>;
    function GetPortName: ShortString;

  public
    {$IFDEF MSWINDOWS}
    ActualTimeouts: COMMTIMEOUTS;
    {$ENDIF}
    FActive: boolean;
    ComPortType: TComPortType;
    LastLoopTime: Double;

    constructor Create(AModbusTCPHost: String; AModbusTCPPort: Word);
    destructor Destroy; override;

    procedure AddToLog(Module: TFmxModule; buffer: PByte; length: integer; sended: Boolean; err: Boolean = false);
    procedure AddModule(module: TFmxModule);
    procedure ExecuteInCOMThread(method: TProcedureOfObject; first: boolean = false); overload;
    procedure ExecuteInCOMThread(proc: TProc); overload;
    procedure ExecuteInThread(method: TProc; const AThreadName: string);
    procedure ExecuteInMainThread(method: TProcedureOfObject; Name: String);
    function IterateCOMLoop(iterations_count: integer): Boolean;
    procedure IterateCOMLoop1;
    procedure ResumeCOMThread;
    function SendCommand(module: TFmxModule; const command: ShortString; response_length: integer; terminator: ansichar = #0): Boolean;
    procedure SetLogFileName(log_filename: String);
    procedure SuspendCOMThread;
    procedure TerminateCOMThread;
    procedure ClearViewIOBuff;
    procedure ResetCycleStats;

    // Свойства
    property OnUpdateNext: TUpdateNextProcs read FOnUpdateNext write SetOnUpdateNext;
    property OnSendCommand: TSendCommandProcs read FOnSendCommand write SetOnSendCommand;
    property OnGetPort: TProcedureOfGetPortObject read FOnGetPort write SetOnGetPort;
    property ComPortNumber: integer read FComPortNumber write SetComPortNumber;
    property Debug: boolean read GetDebug write SetDebug;
    property RunQueriesCount: integer read GetRunQueriesCount;
    property SENDING_TRIES_COUNT: integer read FSENDING_TRIES_COUNT write SetSENDING_TRIES_COUNT default 10;
    property ChangePort: boolean read FChangePort write SetChangePort;
    property Active: boolean read FActive write SetActive default False;
    property Update: boolean read FUpdate write SetUpdate default True;
    property ErrorConnection: boolean read FErrorConnection write SetErrorConnection;
    property ShowPortInLog: boolean read FShowPortInLog write SetShowPortInLog;
    property ShowModuleInLog: boolean read FShowModuleInLog write SetShowModuleInLog;
    property PortState: ShortString read FPortState write SetPortState;
//    property PortName: ShortString read GetPortName;
    property PortStatus: TPortStatus read FPortStaus write SetPortStaus;
    property NextSleep: integer read FNextSleep write SetNextSleep;
    property FormHandle: THandle read FFormHandle write SetFormHandle;
    property ModulesCount: integer read GeTFmxModulesCount write SetModulesCount;
    property DopTimOut: integer read FDopTimOut write SetDopTimOut;
    property Module[ModuleIndex: integer]: TFmxModule read GeTFmxModule write SetModule;
    property ViewIOBuff[Index: integer]: ShortString read GetViewIOBuff write SetViewIOBuff;
    property ViewIOBuffColor[Index: integer]: TColor read GetViewIOBuffColor write SetViewIOBuffColor;
    property ViewIOBuffCounter: integer read FViewIOBuffCounter write SetViewIOBuffCounter;
    property MaxViewIOBuffCounter: integer read GetMaxViewBuffCounter;
    property ViewIOBuffActive: boolean read FViewIOBuffActive write SetViewIOBuffActive;
    property ViewIOBufMax: integer read FViewIOBufMax write SetViewIOBufMax;
    property CurrentModule: integer read GetCurrentModule write SetCurrentModule;
    property ModbusTCPHost: string read FModbusTCPHost write SetModbusTCPHost;
    property ModbusTCPPort: word read FModbusTCPPort write SetModbusTCPPort;
    property TCP_Client_Active: Boolean read FTCP_Client_Active write SetTCP_Client_Active;
    property HOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT: Boolean read FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT write SetHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT;
    property FirstActiveModule: Integer read GetFirstActiveModule;
    property PortReady: boolean read FPortReady write SetPortReady;
    property DelayBeforeSendCommand: integer read FDelayBeforeSendCommand write SetDelayBeforeSendCommand;
    property Optimization: Boolean read FOptimization write SetOptimization;
    property LogFileName: string read GetLogFileName;
    property OnLogViewerAddMessage: TLogViewerAddMessage read FOnLogViewerAddMessage write SetOnLogViewerAddMessage;

    property LastCycleTime: Double read FLastCycleTime;
    property AverageCycleTime: Double read FAverageCycleTime;
    property MinCycleTime: Double read FMinCycleTime;
    property MaxCycleTime: Double read FMaxCycleTime;
    property CycleCount: Integer read FCycleCount;
    property CurrentCycleModules: Integer read FCurrentCycleModules;
    property TimeDebug: string read FTimeDebug write SetTimeDebug;
    property ClosePorts: boolean read FClosePorts write SetClosePorts;
    property ComPortsCount: integer read GetComPortsCount;
    property ComPortInfo[Idx: integer]: TComPortInfo read GetComPortInformation;
    property CommunicationState: boolean read IsOverallCommunicationAlive;
    property PercentOfQuality: integer read GetPercentOfQuality;
  end;

implementation

uses
  uMessageConstants, IdGlobal, fmxkbdhelper;

// ============================================================
//  TPortPollThread
// ============================================================

constructor TPortPollThread.Create(AManager: TFmxModuleManager; APortNumber: Integer);
begin
  inherited Create(True);
  FManager := AManager;
  FPortNumber := APortNumber;
  FreeOnTerminate := False;
  Priority := tpTimeCritical;
end;

procedure TPortPollThread.DoUpdateNext;
begin
  if Assigned(FManager) and FManager.Active and FManager.Update then
  begin
    FManager.UpdateNextForPort(FPortNumber);
  end;
end;

procedure TPortPollThread.Execute;
begin
  while not Terminated do
  begin
    if Assigned(Application) then
    begin
      try
        DoUpdateNext;
      except
        on e: Exception do
          ODS(PChar('TPortPollThread[' + IntToStr(FPortNumber) + '] Error: ' + e.Message));
      end;
    end
    else
      Break;
    Sleep(1);
  end;
end;

// ============================================================
//  TFmxModuleManager - реализация
// ============================================================
(*
procedure TFmxModuleManager.AddToLog(Module: TFmxModule; buffer: PByte; length: integer; sended: Boolean; err: Boolean = false);
var
  hour, min, sec, msec: Word;
  str, substr: String;
  i: integer;
  msgColor: TAlphaColor;
  PortIndex: Integer;
  PortOpen: Boolean;
begin
  if not LogFileIsOpened then Exit;
  if FLogFileName = '' then Exit;

  FLogCriticalSection.Enter;
  try
    if not LogFileIsOpened then Exit;

//    // Проверяем состояние порта через справочник
//    PortIndex := FindComPortIndex(Module.PortNumber);
//    PortOpen := (PortIndex >= 0) and FComPorts[PortIndex].IsOpen;

    AssignFile(LogFile, FLogFileName);
    {$I-}
    if FileExists(FLogFileName) then
      Append(LogFile)
    else
      Rewrite(LogFile);
    {$I+}
    if IOResult <> 0 then Exit;

    DecodeTime(Time, hour, min, sec, msec);
    str := Format('%.2d:%.2d:%.2d.%.3d', [hour, min, sec, msec]);

    substr := '';
    if ShowPortInLog then substr := ' COM' + IntToStr(Module.PortNumber);
    if ShowModuleInLog and (Module.ModuleType <> mtDigitalUnit) then
      substr := substr + ' ' + Module.ModuleName + Format('(0x%.2X', [Module.FAddress]);
    if sended then
      str := str + substr + ') <-- '
    else
      str := str + substr + ') --> ';

    if Module.ASCII then
      begin
        if err then
          msgColor := TAlphaColorRec.Darkred
        else
          msgColor := TAlphaColorRec.DarkGreen;
        if length > 0 then
        begin
          for i := 1 to length do
            if buffer[i-1] = 13 then
              str := str + '<CR>'
            else if buffer[i-1] = 10 then
              str := str + '<LF>'
            else if buffer[i-1] = $A6 then
              str := str + '<A6>'
            else
              str := str + Chr(buffer[i-1]);
        end
        else
          str := str + cTimeout;
      end
      else
      begin
        if err then
          msgColor := TAlphaColorRec.Darkred
        else
          msgColor := TAlphaColorRec.Darkolivegreen;
        if length > 0 then
          str := str + '[hex] ' + B2HS(@buffer[0], length)
        else
          str := str + cTimeout;
      end;

    WriteLn(LogFile, str);
    if Debug and Assigned(FOnLogViewerAddMessage) then
      OnLogViewerAddMessage(str, msgColor);
  finally
    try
      CloseFile(LogFile);
    except
    end;
    FLogCriticalSection.Leave;
  end;
end;
*)


procedure TFmxModuleManager.AddToLog(Module: TFmxModule; buffer: PByte; length: integer; sended: Boolean; err: Boolean = false);
var
  hour, min, sec, msec: Word;
  str, substr: String;
  i: integer;
  msgColor: TAlphaColor;
  PortOpen: Boolean;
begin
  if not LogFileIsOpened then Exit;
  if FLogFileName = '' then Exit;

  FLogCriticalSection.Enter;
  try
    if not LogFileIsOpened then Exit;

    // Проверяем состояние порта через TransferManager
    if Assigned(FTransferManager) then
      PortOpen := FTransferManager.IsPortOpen(Module.PortNumber)
    else
      PortOpen := False;

    AssignFile(LogFile, FLogFileName);
    {$I-}
    if FileExists(FLogFileName) then
      Append(LogFile)
    else
      Rewrite(LogFile);
    {$I+}
    if IOResult <> 0 then Exit;

    DecodeTime(Time, hour, min, sec, msec);
    str := Format('%.2d:%.2d:%.2d.%.3d', [hour, min, sec, msec]);

    substr := '';
    if ShowPortInLog then substr := ' COM' + IntToStr(Module.PortNumber);
    if ShowModuleInLog and (Module.ModuleType <> mtDigitalUnit) then
      substr := substr + ' ' + Module.ModuleName + Format('(0x%.2X', [Module.FAddress]);
    if sended then
      str := str + substr + ') <-- '
    else
      str := str + substr + ') --> ';

    if Module.ASCII then
      begin
        if err then
          msgColor := TAlphaColorRec.Darkred
        else
          msgColor := TAlphaColorRec.DarkGreen;
        if length > 0 then
        begin
          for i := 1 to length do
            if buffer[i-1] = 13 then
              str := str + '<CR>'
            else if buffer[i-1] = 10 then
              str := str + '<LF>'
            else if buffer[i-1] = $A6 then
              str := str + '<A6>'
            else
              str := str + Chr(buffer[i-1]);
        end
        else
          str := str + cTimeout;
      end
      else
      begin
        if err then
          msgColor := TAlphaColorRec.Darkred
        else
          msgColor := TAlphaColorRec.Darkolivegreen;
        if length > 0 then
          str := str + '[hex] ' + B2HS(@buffer[0], length)
        else
          str := str + cTimeout;
      end;

    WriteLn(LogFile, str);
    if Debug and Assigned(FOnLogViewerAddMessage) then
      OnLogViewerAddMessage(str, msgColor);
  finally
    try
      CloseFile(LogFile);
    except
    end;
    FLogCriticalSection.Leave;
  end;
end;


procedure TFmxModuleManager.ClearViewIOBuff;
var i: integer;
begin
  for i := 0 to cViewIOBufMax - 1 do
  begin
    _ViewIOBuff[i] := '';
    _ViewIOBuffColor[i] := TAlphaColorRec.Black;
  end;
  ViewIOBuffCounter := 0;
  FViewIOBuffActive := True;
end;

//procedure TFmxModuleManager.ClosePort;
//begin
//  PortReady := False;
//  if FComPortNumber > 0 then
//    CloseComPort(FComPortNumber);
//  CloseAllComPorts;
//  ComPortNumber := -1;
//  PortStatus := psClose;
//  PortState := 'Порт закрыт';
//end;

//procedure TFmxModuleManager.OpenPort;
//var
//  PortInfo: TComPortInfo;
//begin
//  if FComPortNumber <= 0 then
//  begin
//    PortStatus := psError;
//    PortState := 'Неверный номер порта';
//    Exit;
//  end;
//  {$IFDEF WINDOWS}
//  OpenComPort(FComPortNumber, CBR_115200, NOPARITY, 200, PortInfo);
//  {$ENDIF}
//  if PortInfo.IsOpen then
//  begin
//    PortStatus := psOpen;
//    PortReady := True;
//    PortState := 'Порт ' + PortName + ' открыт';
//  end
//  else
//  begin
//    PortStatus := psError;
//    PortReady := False;
//    PortState := 'Ошибка открытия порта ' + PortName;
//    ErrorConnection := True;
//  end;
//end;

// ============================================================
//  UpdateNextForPort - опрос модулей на конкретном порту
// ============================================================

procedure TFmxModuleManager.UpdateNextForPort(APortNumber: Integer);
var
  CurrentModuleObj: TFmxModule;
begin
  // Проверки
  if (Length(Modules) = 0) or (not Update) or (not Active) or (not Assigned(Application)) then
  begin
    Sleep(100);
    Exit;
  end;

  // Получаем следующий модуль для этого порта
  CurrentModuleObj := GetNextModuleForPort(APortNumber);
  if not Assigned(CurrentModuleObj) then
  begin
    Sleep(10);
    Exit;
  end;

  // Отключённые модули
  if CurrentModuleObj.Disguise or (not CurrentModuleObj.EnabledAutoUpdate) then
  begin
    CurrentModuleObj.ReceiveResponse('*', '');
    Exit;
  end;

  // Синхронный опрос
  CurrentModuleObj.TotalSended := CurrentModuleObj.TotalSended + 1;
  CurrentModuleObj.MustUpdate := False;

  SendCommand(CurrentModuleObj,
              CurrentModuleObj.StatusQuery,
              CurrentModuleObj.ResponseLength,
              #0);
end;

// ============================================================
//  GetNextModuleForPort - поиск следующего модуля на порту
// ============================================================

function TFmxModuleManager.GetNextModuleForPort(APortNumber: Integer): TFmxModule;
var
  i, idx, StartIndex: Integer;
  Found: Boolean;
begin
  Result := nil;

  if Length(Modules) = 0 then Exit;

  // Получаем текущий индекс для этого порта
  if not FPortCurrentModule.TryGetValue(APortNumber, StartIndex) then
  begin
    StartIndex := 0;
    FPortCurrentModule.Add(APortNumber, 0);
  end;

  Found := False;
  idx := StartIndex;

  // Ищем следующий активный модуль на этом порту
  for i := 0 to Length(Modules) - 1 do
  begin
    idx := (idx + 1) mod Length(Modules);

    if Assigned(Modules[idx]) and
       (Modules[idx].PortNumber = APortNumber) and
       (not Modules[idx].Disguise) and
       Modules[idx].EnabledAutoUpdate then
    begin
      Found := True;
      Break;
    end;
  end;

  if Found then
  begin
    FPortCurrentModule[APortNumber] := idx;
    Result := Modules[idx];
  end;
end;

// ============================================================
//  StartPortThreads - запуск потоков для всех портов
// ============================================================

procedure TFmxModuleManager.StartPortThreads;
var
  i: Integer;
  PortNumber: Integer;
  Thread: TPortPollThread;
  PortsList: TList<Integer>;
begin
  if not Assigned(FPortThreads) then Exit;

  PortsList := TList<Integer>.Create;
  try
    // Собираем уникальные номера портов из активных модулей
    for i := 0 to ModulesCount - 1 do
    begin
      if Assigned(Modules[i]) and Modules[i].EnabledAutoUpdate and (not Modules[i].Disguise) then
      begin
        PortNumber := Modules[i].PortNumber;
        if PortNumber <= 0 then Continue;
        if not PortsList.Contains(PortNumber) then
          PortsList.Add(PortNumber);
      end;
    end;

    // Для каждого порта создаём поток
    for PortNumber in PortsList do
    begin
      if not FPortCurrentModule.ContainsKey(PortNumber) then
        FPortCurrentModule.Add(PortNumber, 0);

      Thread := TPortPollThread.Create(Self, PortNumber);
      FPortThreads.Add(PortNumber, Thread);
      Thread.Resume;

      if Debug then
        DebugOutput('Запущен поток опроса для COM' + IntToStr(PortNumber));
    end;
  finally
    PortsList.Free;
  end;
end;

// ============================================================
//  SendCommand - синхронная отправка команды
// ============================================================

function TFmxModuleManager.SendCommand(module: TFmxModule; const command: ShortString;
  response_length: integer; terminator: ansichar = #0): Boolean;
begin
  if Assigned(FTransferManager) and Assigned(module) then
    Result := FTransferManager.SendCommand(module, command, response_length, terminator)
  else
    Result := False;
end;

// ============================================================
//  AddModule
// ============================================================

procedure TFmxModuleManager.AddModule(module: TFmxModule);
var cnt: integer;
begin
  cnt := Length(Modules);
  Inc(cnt);
  SetLength(Modules, cnt);
  Modules[cnt - 1] := module;
end;

// ============================================================
//  ExecuteInMainThread
// ============================================================

procedure TFmxModuleManager.ExecuteInMainThread(method: TProcedureOfObject; Name: String);
begin
  if Assigned(method) then
    TThread.Queue(nil,
      procedure
      begin
        method();
      end
    );
end;

// ============================================================
//  ExecuteInCOMThread - заглушка (больше не используется)
// ============================================================



procedure TFmxModuleManager.ExecuteInCOMThread(method: TProcedureOfObject; first: boolean = false);
begin
  if Assigned(method) then
    method();
end;

procedure TFmxModuleManager.ExecuteInCOMThread(proc: TProc);
begin
  if Assigned(proc) then
    proc();
end;

procedure TFmxModuleManager.ExecuteInThread(method: TProc; const AThreadName: string);
var
  LThread: TThread;
begin
  if not Assigned(method) then
    Exit;

  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.NameThreadForDebugging(AThreadName);
      method();
    end
  );

  LThread.FreeOnTerminate := True;
  LThread.Start;
end;

// ============================================================
//  IterateCOMLoop - заглушка
// ============================================================

function TFmxModuleManager.IterateCOMLoop(iterations_count: integer): Boolean;
begin
  Result := True;
end;

procedure TFmxModuleManager.IterateCOMLoop1;
begin
  // заглушка
end;

procedure TFmxModuleManager.ResumeCOMThread;
begin
  // заглушка
end;

procedure TFmxModuleManager.SuspendCOMThread;
begin
  // заглушка
end;

procedure TFmxModuleManager.TerminateCOMThread;
begin
  // заглушка
end;

// ============================================================
//  WriteToBuffer
// ============================================================

procedure TFmxModuleManager.WriteToBuffer(str: ShortString; Module: TFmxModule);
var tmpColor: TAlphaColor;
begin
  if not FViewIOBuffActive then Exit;
  ViewIOBuff[ViewIOBuffCounter] := str;
  tmpColor := TAlphaColorRec.Black;
  if Assigned(Module) then
    case Module.ModuleType of
      mtCounter, mtCounterEx: tmpColor := TColors.Brown;
      mtFCD, mtFCD2: tmpColor := TColors.Navy;
      mtScales, mtScalesMT: tmpColor := TColors.DarkBlue;
      mtValve: tmpColor := TColors.Green;
      mtBIO: tmpColor := TColors.DarkGreen;
      mtSuperBIO: tmpColor := TColors.DarkGreen;
      mtT, mtTemp2, mtTemp6, mtUI, mtOldUI: tmpColor := TColors.Blue;
      mtVLT6000, mtATV312, mtDAC_I702X, mtVLTModbus: tmpColor := TColors.Darkcyan;
      mtIVTM: tmpColor := TColors.Darkgray;
      mtDigitalUnit: tmpColor := TColors.Darkgoldenrod;
      mtKM5: tmpColor := TColors.Darkgoldenrod;
      mtRT2: tmpColor := TColors.goldenrod;
    end;
  ViewIOBuffColor[ViewIOBuffCounter] := tmpColor;
  ViewIOBuffCounter := ViewIOBuffCounter + 1;
end;

// ============================================================
//  Конструктор и деструктор
// ============================================================

constructor TFmxModuleManager.Create(AModbusTCPHost: String; AModbusTCPPort: Word);
begin
  inherited Create;

  FTransferManager := TTransferManager.Create(Self);
  FTransferManager.DefaultRetryCount := SENDING_TRIES_COUNT;

  FPortThreads := TDictionary<Integer, TPortPollThread>.Create;
  FPortCurrentModule := TDictionary<Integer, Integer>.Create;

  FClosePorts := True;
  FCycleStartTime := GetTickCount;
  FLastCycleTime := 0.0;
  FAverageCycleTime := 0.0;
  FMinCycleTime := 0.0;
  FMaxCycleTime := 0.0;
  FCycleCount := 0;
  FTotalCycleTime := 0;
  FCurrentCycleModules := 0;

  Active := False;
  Update := True;
  DelayBeforeSendCommand := 10;
  FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT := True;
  TCP_Client_Active := False;
  TCP_Client := TIdTCPClient.Create(nil);
  TCP_Client.OnConnected := IdTCPClientConnected;
  TCP_Client.OnDisconnected := IdTCPClientDisConnected;
  ModbusTCPHost := '127.0.0.1';
  FModbusTCPPort := 502;
  ViewIOBufMax := cViewIOBufMax;
  FormHandle := 0;
  FChangePort := True;
  FShowPortInLog := True;
  FShowModuleInLog := True;
  FNextSleep := 1;
  SENDING_TRIES_COUNT := 10;
  CurrentModule := 0;
  LastLoopTime := 0.0;
  LogFileIsOpened := false;
  LoopStartTickCount := GetTickCount;

//  FComPortsLock := TCriticalSection.Create;
  FLogCriticalSection := TCriticalSection.Create;
//  SetLength(FComPorts, 0);

  ComPortNumber := 0;
  ComPortType := ctMain;
  DopTimOut := c_DopTimOut;

  ClearViewIOBuff;
end;

destructor TFmxModuleManager.Destroy;
var
  Thread: TPortPollThread;
begin
  Active := False;

  // Завершаем потоки опроса портов
  if Assigned(FPortThreads) then
  begin
    for Thread in FPortThreads.Values do
    begin
      Thread.Terminate;
      Thread.WaitFor;
      Thread.Free;
    end;
    FPortThreads.Free;
    FPortThreads := nil;
  end;

  if Assigned(FPortCurrentModule) then
    FPortCurrentModule.Free;

  if Assigned(FTransferManager) then
    FTransferManager.Free;

  //CloseAllComPorts;

  if LogFileIsOpened then
  begin
    try
      Close(LogFile);
    except
    end;
  end;

  if Assigned(TCP_Client) then
  begin
    try
      TCP_Client.Free;
    except
      on E: Exception do
        if Debug then DebugOutput('Ошибка при освобождении TCP клиента: ' + E.Message);
    end;
  end;

//  if Assigned(FComPortsLock) then
//    FComPortsLock.Free;
  if Assigned(FLogCriticalSection) then
    FLogCriticalSection.Free;

  inherited Destroy;
end;

// ============================================================
//  SetActive - запуск/остановка потоков
// ============================================================

procedure TFmxModuleManager.SetActive(const Value: boolean);
begin
  FActive := Value;
  if Value then
  begin
    StartPortThreads;
  end
  else
  begin
    // Останавливаем потоки
    if Assigned(FPortThreads) then
    begin
      for var Thread in FPortThreads.Values do
        Thread.Terminate;
    end;
  end;
end;

// ============================================================
//  Работа с COM-портами (из оригинального файла)
// ============================================================

//procedure TFmxModuleManager.OpenComPort(PortNumber, BaudRate, Parity, Timeout: integer;
//  var PortInfo: TComPortInfo; var PortIndex: integer);
//{$IFDEF MSWINDOWS}
//var
//  DCB: TDCB;
//  CTO: COMMTIMEOUTS;
//{$ENDIF}
//begin
//  if PortNumber <= 0 then Exit;
//
//  FComPortsLock.Enter;
//  Inc(Timeout, FDopTimOut);
//  try
//    if GetComPortInfo(PortNumber, PortInfo, PortIndex) then
//    begin
//      if (PortInfo.BaudRate <> BaudRate) or (PortInfo.Parity <> Parity) then
//      begin
//        CloseComPort(PortNumber);
//        PortInfo.PortNumber := PortNumber;
//        PortInfo.BaudRate := BaudRate;
//        PortInfo.Parity := Parity;
//        PortInfo.Timeout := Timeout;
//        PortInfo.IsOpen := False;
//      end
//      else
//      begin
//        Exit;
//      end;
//    end
//    else
//    begin
//      PortInfo.PortNumber := PortNumber;
//      PortInfo.BaudRate := BaudRate;
//      PortInfo.Parity := Parity;
//      PortInfo.Timeout := Timeout;
//      PortInfo.IsOpen := False;
//    end;
//
//    {$IFDEF MSWINDOWS}
//    PortInfo.PortHandle := CreateFile(
//      PChar('\\.\COM' + IntToStr(PortNumber)),
//      GENERIC_READ or GENERIC_WRITE,
//      0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
//
//    if PortInfo.PortHandle = INVALID_HANDLE_VALUE then
//    begin
//      PortInfo.IsOpen := False;
//      PortState := 'Ошибка открытия порта COM' + IntToStr(PortNumber);
//      if FindComPortIndex(PortNumber) >= 0 then
//        UpdateComPortInfo(PortInfo)
//      else
//        AddComPortInfo(PortInfo);
//      Exit;
//    end;
//
//    GetCommState(PortInfo.PortHandle, DCB);
//    DCB.BaudRate := BaudRate;
//    DCB.Parity := Parity;
//    DCB.ByteSize := 8;
//    DCB.StopBits := ONESTOPBIT;
//    SetCommState(PortInfo.PortHandle, DCB);
//
//    GetCommTimeouts(PortInfo.PortHandle, CTO);
//    CTO.ReadIntervalTimeout := MAXWORD;
//    CTO.ReadTotalTimeoutMultiplier := 0;
//    CTO.ReadTotalTimeoutConstant := Timeout;
//    CTO.WriteTotalTimeoutMultiplier := 150;
//    CTO.WriteTotalTimeoutConstant := 100;
//    SetCommTimeouts(PortInfo.PortHandle, CTO);
//
//    EscapeCommFunction(PortInfo.PortHandle, SETRTS);
//    {$ENDIF}
//
//    PortInfo.IsOpen := True;
//    PortInfo.LastUsed := Now;
//
//    if FindComPortIndex(PortNumber) >= 0 then
//      UpdateComPortInfo(PortInfo)
//    else
//      AddComPortInfo(PortInfo);
//
//    PortState := 'Порт COM' + IntToStr(PortNumber) + ' открыт';
//
//  finally    FComPortsLock.Leave;
//  end;
//end;

//procedure TFmxModuleManager.CloseComPort(PortNumber: integer);
//var
//  PortInfo: TComPortInfo;
//  Index: integer;
//begin
//  if not ClosePorts then Exit;
//
//  FComPortsLock.Enter;
//  try
//    Index := FindComPortIndex(PortNumber);
//    if Index >= 0 then
//    begin
//      PortInfo := FComPorts[Index];
//      if PortInfo.IsOpen then
//      begin
//        {$IFDEF MSWINDOWS}
//        PurgeComm(PortInfo.PortHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
//        EscapeCommFunction(PortInfo.PortHandle, CLRRTS);
//        CloseHandle(PortInfo.PortHandle);
//        {$ENDIF}
//
//        PortInfo.IsOpen := False;
//        PortInfo.PortHandle := INVALID_HANDLE_VALUE;
//        FComPorts[Index] := PortInfo;
//      end;
//    end;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;
//
//procedure TFmxModuleManager.CloseAllComPorts;
//var
//  i: integer;
//begin
//  FComPortsLock.Enter;
//  try
//    for i := 0 to High(FComPorts) do
//    begin
//      if FComPorts[i].IsOpen then
//        CloseComPort(FComPorts[i].PortNumber);
//    end;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;
//
//function TFmxModuleManager.FindComPortIndex(PortNumber: integer): integer;
//var
//  i: integer;
//begin
//  Result := -1;
//  for i := 0 to High(FComPorts) do
//  begin
//    if FComPorts[i].PortNumber = PortNumber then
//    begin
//      Result := i;
//      Exit;
//    end;
//  end;
//end;
//
//function TFmxModuleManager.GetComPortInfo(PortNumber: integer; var PortInfo: TComPortInfo;
//  var PortIndex: integer): Boolean;
//var
//  Index: integer;
//begin
//  Result := False;
//  FComPortsLock.Enter;
//  PortIndex := -1;
//  try
//    Index := FindComPortIndex(PortNumber);
//    if Index >= 0 then
//    begin
//      PortInfo := FComPorts[Index];
//      Result := PortInfo.IsOpen;
//      FComPorts[Index].LastUsed := Now;
//      PortIndex := Index;
//    end;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;
//
//procedure TFmxModuleManager.UpdateComPortInfo(const PortInfo: TComPortInfo);
//var
//  Index: integer;
//begin
//  FComPortsLock.Enter;
//  try
//    Index := FindComPortIndex(PortInfo.PortNumber);
//    if Index >= 0 then
//    begin
//      FComPorts[Index] := PortInfo;
//    end;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;
//
//procedure TFmxModuleManager.AddComPortInfo(const PortInfo: TComPortInfo);
//begin
//  FComPortsLock.Enter;
//  try
//    SetLength(FComPorts, Length(FComPorts) + 1);
//    FComPorts[High(FComPorts)] := PortInfo;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;

//function TFmxModuleManager.GetComPort(PortNumber, BaudRate, Parity, Timeout: integer;
//  var PortInfo: TComPortInfo; var PortIndex: integer): Boolean;
//begin
//  Result := False;
//  if GetComPortInfo(PortNumber, PortInfo, PortIndex) then
//  begin
//    Result := PortInfo.IsOpen;
//  end
//  else
//  begin
//    OpenComPort(PortNumber, BaudRate, Parity, Timeout, PortInfo, PortIndex);
//    Result := PortInfo.IsOpen;
//  end;
//end;

//procedure TFmxModuleManager.CleanupUnusedPorts(TimeoutMinutes: integer);
//var
//  i: integer;
//  CurrentTime: TDateTime;
//  ClosedCount: integer;
//begin
//  if not Assigned(FComPortsLock) then Exit;
//  if not ClosePorts then Exit;
//
//  ClosedCount := 0;
//  CurrentTime := Now;
//  FComPortsLock.Enter;
//  try
//    if Length(FComPorts) > 0 then
//      for i := High(FComPorts) downto 0 do
//      begin
//        if FComPorts[i].IsOpen and
//           (MinutesBetween(CurrentTime, FComPorts[i].LastUsed) > TimeoutMinutes) then
//        begin
//          {$IFDEF MSWINDOWS}
//          PurgeComm(FComPorts[i].PortHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
//          EscapeCommFunction(FComPorts[i].PortHandle, CLRRTS);
//          CloseHandle(FComPorts[i].PortHandle);
//          {$ENDIF}
//
//          FComPorts[i].IsOpen := False;
//          FComPorts[i].PortHandle := INVALID_HANDLE_VALUE;
//          FComPorts[i].TimeOuts := 0;
//          Inc(ClosedCount);
//
//          if Debug then
//            DebugOutput('Автоматически закрыт неиспользуемый порт COM' +
//              IntToStr(FComPorts[i].PortNumber));
//        end;
//      end;
//
//    if ClosedCount > 0 then
//      RemoveClosedPortsFromArray;
//  finally
//    FComPortsLock.Leave;
//  end;
//
//  if (ClosedCount > 0) and Debug then
//    DebugOutput('Автоматически закрыто портов: ' + IntToStr(ClosedCount));
//end;

//procedure TFmxModuleManager.RemoveClosedPortsFromArray;
//var
//  i: integer;
//  TempArray: TComPortArray;
//begin
//  FComPortsLock.Enter;
//  try
//    SetLength(TempArray, 0);
//    for i := 0 to High(FComPorts) do
//    begin
//      if FComPorts[i].IsOpen then
//      begin
//        SetLength(TempArray, Length(TempArray) + 1);
//        TempArray[High(TempArray)] := FComPorts[i];
//      end;
//    end;
//    FComPorts := TempArray;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;

procedure TFmxModuleManager.ClosePortHandle(PortHandle: Cardinal);
var
  Attempts: Integer;
  {$IFDEF MSWINDOWS}
  Timeouts: TCommTimeouts;
  {$ENDIF}
begin
  if PortHandle = INVALID_HANDLE_VALUE then Exit;
  if (not ClosePorts) or Debug or CtrlDown then Exit;

  Attempts := 0;
  while Attempts < 3 do
  begin
    try
      {$IFDEF MSWINDOWS}
      FillChar(Timeouts, SizeOf(Timeouts), 0);
      Timeouts.ReadIntervalTimeout := MAXDWORD;
      Timeouts.ReadTotalTimeoutMultiplier := 0;
      Timeouts.ReadTotalTimeoutConstant := 0;
      Timeouts.WriteTotalTimeoutMultiplier := 0;
      Timeouts.WriteTotalTimeoutConstant := 0;

      try
        SetCommTimeouts(PortHandle, Timeouts);
      except
      end;

      try
        CancelIo(PortHandle);
      except
      end;

      try
        SetCommMask(PortHandle, 0);
      except
      end;

      try
        PurgeComm(PortHandle, PURGE_TXABORT or PURGE_RXABORT or
                            PURGE_TXCLEAR or PURGE_RXCLEAR);
      except
      end;

      try
        EscapeCommFunction(PortHandle, CLRRTS);
        EscapeCommFunction(PortHandle, CLRDTR);
      except
      end;

      Sleep(50);

      if CloseHandle(PortHandle) then
      begin
        if Debug then
          DebugOutput('Порт успешно закрыт');
        Exit;
      end
      else
      begin
        if Debug then
          DebugOutput('Попытка ' + IntToStr(Attempts + 1) +
            ': не удалось закрыть порт. Код ошибки: ' + IntToStr(GetLastError));
      end;
      {$ENDIF}
    except
      on E: Exception do
      begin
        if Debug then
          DebugOutput('Исключение при закрытии порта (попытка ' +
            IntToStr(Attempts + 1) + '): ' + E.Message);
      end;
    end;

    Inc(Attempts);
    if Attempts < 3 then
      Sleep(100);
  end;

  if Debug then
    DebugOutput('Не удалось корректно закрыть порт после 3 попыток. ' +
                'Дескриптор: ' + IntToStr(PortHandle));
end;

// ============================================================
//  Статистика и вспомогательные методы
// ============================================================

function TFmxModuleManager.CountActiveModules: Integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to ModulesCount - 1 do
  begin
    if Assigned(Modules[i]) and
       (not Modules[i].Disguise) and
       Modules[i].EnabledAutoUpdate then
    begin
      Inc(Result);
    end;
  end;
end;

function TFmxModuleManager.HasActiveModules: Boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to ModulesCount - 1 do
  begin
    if Assigned(Modules[i]) and
       (not Modules[i].Disguise) and
       Modules[i].EnabledAutoUpdate then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TFmxModuleManager.GetFirstActiveModule: Integer;
var
  i: integer;
begin
  for i := 0 to ModulesCount - 1 do
  begin
    if Assigned(Modules[i]) and
       (not Modules[i].Disguise) and
       Modules[i].EnabledAutoUpdate then
    begin
      Result := i;
      Exit;
    end;
  end;
  Result := 0;
end;

procedure TFmxModuleManager.UpdateCycleStatistics(CycleTime: Double);
begin
  if FCycleCount = 0 then
  begin
    FMinCycleTime := CycleTime;
    FMaxCycleTime := CycleTime;
    FAverageCycleTime := CycleTime;
  end
  else
  begin
    if CycleTime < FMinCycleTime then
      FMinCycleTime := CycleTime;
    if CycleTime > FMaxCycleTime then
      FMaxCycleTime := CycleTime;
    FTotalCycleTime := FTotalCycleTime + CycleTime;
    FAverageCycleTime := FTotalCycleTime / (FCycleCount + 1);
  end;

  Inc(FCycleCount);

  if FCycleCount >= 1000 then
    ResetCycleStatistics;
end;

procedure TFmxModuleManager.ResetCycleStatistics;
begin
  FCycleCount := 0;
  FTotalCycleTime := 0;
  FAverageCycleTime := 0;
  FMinCycleTime := 0;
  FMaxCycleTime := 0;
end;

procedure TFmxModuleManager.ResetCycleStats;
begin
  ResetCycleStatistics;
  FCycleStartTime := GetTickCount;
end;

function TFmxModuleManager.IsOverallCommunicationAlive(): Boolean;
var
  i: Integer;
  tmpModule: TFmxModule;
begin
  if (ComPortType = ctMain) and (not PortReady) then
    Exit(False);
  if (ComPortType = ctFlowmeter) and (not TCP_Client_Active) then
    Exit(False);

  if ModulesCount = 0 then
    Exit(False);

  for i := 0 to ModulesCount - 1 do
  begin
    tmpModule := Module[i];
    if not Assigned(tmpModule) then Continue;
    if (not tmpModule.Disguise) and tmpModule.EnabledAutoUpdate and (tmpModule.ConnectIsOK = fdqGood) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function TFmxModuleManager.GetPercentOfQuality: integer;
var i: integer;
    received, sended: longint;
begin
  received := 0;
  sended := 0;
  for i := 1 to ModulesCount do
  begin
    if Assigned(Module[i]) then
    begin
      Inc(sended, Module[i].TotalSended);
      Inc(received, Module[i].TotalReceived);
    end;
  end;
  if sended > 0 then
    Result := Round(received / sended * 100)
  else
    Result := 100;
end;

// ============================================================
//  TCP Client
// ============================================================

procedure TFmxModuleManager.IdTCPClientConnected(Sender: TObject);
begin
  TCP_Client_Active := True;
end;

procedure TFmxModuleManager.IdTCPClientDisconnected(Sender: TObject);
begin
  TCP_Client_Active := False;
end;

function TFmxModuleManager.TCP_Client_Connected: Boolean;
begin
  if not TCP_Client.Connected then
  begin
    TCP_Client.Host := ModbusTCPHost;
    TCP_Client.Port := FModbusTCPPort;
  end;
  if not FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT then
  begin
    if TCP_Client.Connected then
      TCP_Client.Disconnect;
    TCP_Client.Host := ModbusTCPHost;
    TCP_Client.Port := FModbusTCPPort;
  end;
  try
    if not TCP_Client.Connected then
    begin
      try
        TCP_Client.Connect();
        Result := TCP_Client_Active;
      except
        Result := False;
      end;
    end
    else
      Result := TCP_Client_Active;
  except
    Result := False;
  end;
end;

// ============================================================
//  Сеттеры свойств
// ============================================================

procedure TFmxModuleManager.SetOnSendCommand(const Value: TSendCommandProcs);
begin
  FOnSendCommand := Value;
end;

procedure TFmxModuleManager.SetOnUpdateNext(const Value: TUpdateNextProcs);
begin
  FOnUpdateNext := Value;
end;

procedure TFmxModuleManager.SetOnGetPort(const Value: TProcedureOfGetPortObject);
begin
  FOnGetPort := Value;
end;

procedure TFmxModuleManager.SetComPortNumber(const Value: integer);
begin
  FComPortNumber := Value;
end;

procedure TFmxModuleManager.SetDebug(const Value: boolean);
begin
  FDebug := Value;
end;

procedure TFmxModuleManager.SetSENDING_TRIES_COUNT(const Value: integer);
begin
  FSENDING_TRIES_COUNT := Value;
end;

procedure TFmxModuleManager.SetChangePort(const Value: boolean);
begin
  FChangePort := Value;
end;

procedure TFmxModuleManager.SetErrorConnection(const Value: boolean);
begin
  FErrorConnection := Value;
  if Value then
  begin
    if Length(Modules) > 0 then
      if Assigned(Modules[CurrentModule]) then
      begin
        Modules[CurrentModule].ReceiveResponse(Modules[CurrentModule].StatusQuery, '');
      end;
  end;
end;

procedure TFmxModuleManager.SetShowPortInLog(const Value: boolean);
begin
  FShowPortInLog := Value;
end;

procedure TFmxModuleManager.SetShowModuleInLog(const Value: boolean);
begin
  FShowModuleInLog := Value;
end;

procedure TFmxModuleManager.SetPortState(const Value: shortString);
begin
  FPortState := Value;
  {$IFDEF MSWINDOWS}
  if FormHandle <> 0 then
    PostMessage(FormHandle, WM_UPDATE_PORT_INFO, 0, 0);
  {$ENDIF}
  if Debug then
    DebugOutput(Value);
end;

procedure TFmxModuleManager.SetPortStaus(const Value: TPortStatus);
begin
  FPortStaus := Value;
end;

procedure TFmxModuleManager.SetNextSleep(const Value: integer);
begin
  FNextSleep := Value;
end;

procedure TFmxModuleManager.SetFormHandle(const Value: THandle);
begin
  FFormHandle := Value;
end;

procedure TFmxModuleManager.SetDopTimOut(const Value: integer);
begin
  FDopTimOut := Value;
end;

procedure TFmxModuleManager.SetViewIOBuff(Index: integer; const Value: ShortString);
begin
  _ViewIOBuff[Index mod ViewIOBufMax] := Value;
end;

procedure TFmxModuleManager.SetViewIOBuffColor(Index: integer; const Value: TColor);
begin
  _ViewIOBuffColor[Index mod ViewIOBufMax] := Value;
end;

procedure TFmxModuleManager.SetViewIOBuffCounter(const Value: integer);
begin
  if Value in [0..ViewIOBufMax - 1] then
    FViewIOBuffCounter := Value
  else
    FViewIOBuffCounter := 0;
end;

procedure TFmxModuleManager.SetViewIOBuffActive(const Value: boolean);
begin
  FViewIOBuffActive := Value;
end;

procedure TFmxModuleManager.SetViewIOBufMax(const Value: integer);
begin
  if Value in [cViewIOBufMin..cViewIOBufMax] then
    FViewIOBufMax := Value;
end;

procedure TFmxModuleManager.SetCOMRunQueriesCount(const Value: integer);
begin
  // Заглушка - больше не используется
end;

procedure TFmxModuleManager.SetCurrentModule(const Value: integer);
begin
  FCurrentModule := Value;
end;

procedure TFmxModuleManager.SetModbusTCPHost(const Value: string);
begin
  FModbusTCPHost := Value;
end;

procedure TFmxModuleManager.SetModbusTCPPort(const Value: word);
begin
  FModbusTCPPort := Value;
end;

procedure TFmxModuleManager.SetTCP_Client_Active(const Value: Boolean);
begin
  FTCP_Client_Active := Value;
end;

procedure TFmxModuleManager.SetHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT(const Value: Boolean);
begin
  FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT := Value;
end;

procedure TFmxModuleManager.SetPortReady(const Value: boolean);
begin
  FPortReady := Value;
end;

procedure TFmxModuleManager.SetPortName(const Value: ShortString);
begin
  FPortName := Value;
end;

procedure TFmxModuleManager.SetUpdate(const Value: boolean);
begin
  if FUpdate <> Value then
  begin
    FUpdate := Value;
    if not Value then
    begin
      // Закрываем все порты через TransferManager
      if Assigned(FTransferManager) then
        FTransferManager.CloseAllPorts;

      if not FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT then
        TCP_Client.Disconnect;
    end
    else
    begin
//      CleanupUnusedPorts(10);
    end;
  end;
end;

procedure TFmxModuleManager.SetDelayBeforeSendCommand(const Value: integer);
begin
  FDelayBeforeSendCommand := Value;
end;

procedure TFmxModuleManager.SetOptimization(const Value: Boolean);
begin
  FOptimization := Value;
end;

procedure TFmxModuleManager.SetOnLogViewerAddMessage(const Value: TLogViewerAddMessage);
begin
  FOnLogViewerAddMessage := Value;
end;

procedure TFmxModuleManager.SetModule(ModuleIndex: integer; const Value: TFmxModule);
begin
  if (ModuleIndex >= 0) and (ModuleIndex < ModulesCount) then
    Modules[ModuleIndex] := Value;
end;

procedure TFmxModuleManager.SetModulesCount(const Value: integer);
begin
  SetLength(Modules, Value);
end;

procedure TFmxModuleManager.SetClosePorts(const Value: boolean);
begin
  FClosePorts := Value;
end;

procedure TFmxModuleManager.SetTimeDebug(const Value: string);
begin
  FTimeDebug := Value;
end;

procedure TFmxModuleManager.SetLogFileName(log_filename: String);
var
  LogDir: string;
begin
  // Закрываем файл если он был открыт
  if LogFileIsOpened then
  begin
    try
      CloseFile(LogFile);
    except
    end;
    LogFileIsOpened := false;
  end;

  if log_filename = '' then
  begin
    LogFileIsOpened := false;
    FLogFileName := '';
    if Debug then
      DebugOutput('ЛОГ обмена отключен');
  end
  else
  begin
    LogDir := ExtractFilePath(log_filename);
    if (LogDir <> '') and not DirectoryExists(LogDir) then
    begin
      try
        ForceDirectories(LogDir);
      except
        on E: Exception do
        begin
          DebugOutput('Ошибка создания директории для лога: ' + E.Message);
          LogFileIsOpened := false;
          FLogFileName := '';
          Exit;
        end;
      end;
    end;

    FLogFileName := log_filename;

    try
      AssignFile(LogFile, FLogFileName);
      {$I-}
      if FileExists(FLogFileName) then
        Append(LogFile)
      else
        Rewrite(LogFile);
      {$I+}
      LogFileIsOpened := (IOResult = 0);

      if LogFileIsOpened then
      begin
        if FileSize(LogFile) = 0 then
        begin
          WriteLn(LogFile, '=== Лог обмена данными через COM-порт и Modbus TCP ===');
          WriteLn(LogFile, '=== Начало: ' + DateTimeToStr(Now) + ' ===');
          WriteLn(LogFile, '');
        end;
        CloseFile(LogFile);
        if Debug then
          DebugOutput('ЛОГ обмена: ' + log_filename);
      end
      else
      begin
        DebugOutput('Ошибка открытия файла лога: ' + log_filename);
        FLogFileName := '';
      end;
    except
      on E: Exception do
      begin
        LogFileIsOpened := false;
        FLogFileName := '';
        DebugOutput('Ошибка при работе с файлом лога: ' + E.Message);
      end;
    end;
  end;
end;

// ============================================================
//  Геттеры свойств
// ============================================================

function TFmxModuleManager.GetDebug: boolean;
begin
  Result := FDebug;
end;

function TFmxModuleManager.GetRunQueriesCount: integer;
begin
  Result := 0;
end;

function TFmxModuleManager.GetThreadRun: integer;
begin
  Result := 0;
end;

function TFmxModuleManager.GetCurModule: Integer;
begin
  Result := CurrentModule;
end;

function TFmxModuleManager.GetCurrentModule: integer;
begin
  Result := FCurrentModule;
end;

//function TFmxModuleManager.GetPortName: ShortString;
//var
//  i: integer;
//  OpenPortsList: TStringList;
//begin
//  Result := '';
//
//  if TCP_Client_Active and TCP_Client.Connected then
//  begin
//    Result := 'TCP(' + ModbusTCPHost + ':' + IntToStr(ModbusTCPPort) + ')';
//  end;
//
//  FComPortsLock.Enter;
//  try
//    OpenPortsList := TStringList.Create;
//    try
//      for i := 0 to High(FComPorts) do
//      begin
//        if FComPorts[i].IsOpen then
//        begin
//          OpenPortsList.Add('COM' + IntToStr(FComPorts[i].PortNumber) +
//                           '(' + IntToStr(FComPorts[i].BaudRate) + ')');
//        end;
//      end;
//
//      if OpenPortsList.Count > 0 then
//      begin
//        if Result <> '' then
//          Result := Result + ' + ';
//        Result := Result + 'COM[' + OpenPortsList.DelimitedText + ']';
//      end;
//    finally
//      OpenPortsList.Free;
//    end;
//
//    if Result = '' then
//    begin
//      if FComPortNumber > 0 then
//        Result := 'COM' + IntToStr(FComPortNumber) + ' (закрыт)'
//      else
//        Result := 'Порты не настроены';
//    end;
//  finally
//    FComPortsLock.Leave;
//  end;
//end;

function TFmxModuleManager.GeTFmxModule(ModuleIndex: integer): TFmxModule;
begin
  if (ModuleIndex >= 0) and (ModuleIndex < ModulesCount) then
    Result := Modules[ModuleIndex]
  else
    Result := nil;
end;

function TFmxModuleManager.GeTFmxModulesCount: integer;
begin
  Result := Length(Modules);
end;

function TFmxModuleManager.GetViewIOBuff(Index: integer): ShortString;
begin
  Result := _ViewIOBuff[Index mod ViewIOBufMax];
end;

function TFmxModuleManager.GetViewIOBuffColor(Index: integer): TColor;
begin
  Result := _ViewIOBuffColor[Index mod ViewIOBufMax];
end;

function TFmxModuleManager.GetMaxViewBuffCounter: integer;
begin
  Result := ViewIOBufMax;
end;

function TFmxModuleManager.GetLogFileName: string;
begin
  Result := FLogFileName;
end;

function TFmxModuleManager.GetComPortsCount: integer;
begin
  // Получаем количество открытых портов из TransferManager
  if Assigned(FTransferManager) then
    Result := FTransferManager.GetOpenPortsCount
  else
    Result := 0;
end;

function TFmxModuleManager.GetComPortInformation(Idx: integer): TComPortInfo;
var
  PortInfo: TComPortInfo;
begin
  // Инициализируем пустой структурой на случай ошибки
  FillChar(Result, SizeOf(Result), 0);
  Result.PortHandle := INVALID_HANDLE_VALUE;
  Result.PortNumber := -1;
  Result.IsOpen := False;

  if Assigned(FTransferManager) then
  begin
    if FTransferManager.GetPortInfoByIndex(Idx, PortInfo) then
      Result := PortInfo;
  end;
end;

function TFmxModuleManager.GetPortName: ShortString;
var
  PortsList: TList<Integer>;
  i: Integer;
  PortInfo: TComPortInfo;
begin
  Result := '';

  // TCP часть
  if TCP_Client_Active and TCP_Client.Connected then
    Result := 'TCP(' + ModbusTCPHost + ':' + IntToStr(ModbusTCPPort) + ')';

  // COM порты из TransferManager
  if Assigned(FTransferManager) then
  begin
    PortsList := FTransferManager.GetOpenPortsList;
    try
      if PortsList.Count > 0 then
      begin
        if Result <> '' then
          Result := Result + ' + ';

        Result := Result + 'COM[';
        for i := 0 to PortsList.Count - 1 do
        begin
          if i > 0 then
            Result := Result + ',';

          if FTransferManager.GetPortInfoByNumber(PortsList[i], PortInfo) then
            Result := Result + 'COM' + IntToStr(PortsList[i]) +
                       '(' + IntToStr(PortInfo.BaudRate) + ')'
          else
            Result := Result + 'COM' + IntToStr(PortsList[i]);
        end;
        Result := Result + ']';
      end;
    finally
      PortsList.Free;
    end;
  end;

  if Result = '' then
  begin
    if FComPortNumber > 0 then
      Result := 'COM' + IntToStr(FComPortNumber) + ' (закрыт)'
    else
      Result := 'Порты не настроены';
  end;
end;

// === НОВЫЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ СПИСКА ПОРТОВ ===

function TFmxModuleManager.GetOpenPortsList: TList<Integer>;
begin
  if Assigned(FTransferManager) then
    Result := FTransferManager.GetOpenPortsList
  else
    Result := TList<Integer>.Create;
end;

// ============================================================
//  Методы-заглушки для совместимости
// ============================================================


function TFmxModuleManager.GetMaxChannels: byte;
begin
  Result := 0;
end;

procedure TFmxModuleManager.SetMaxChannels(const Value: byte);
begin
  // Заглушка
end;

// ============================================================
//  Обновление UpdateNext (старый метод - заглушка)
// ============================================================

procedure TFmxModuleManager.UpdateNext;
begin
  // Заглушка - больше не используется
end;

// ============================================================
//  Initialize
// ============================================================

initialization

end.
