unit PortManager;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.SyncObjs,
  Fmx.Forms, FmxFPModule, FmxFPModuleManager, uProcedureOfObject,
  {$IFDEF MSWINDOWS}
  Windows, System.Win.ScktComp,
  {$ENDIF}
  IdTCPClient, IdGlobal, System.UITypes, Fmx.Graphics;

type
  TSinglePortManager = class;

  // Основной менеджер портов
  TPortManager = class
  private
    FPortManagers: TObjectDictionary<Integer, TSinglePortManager>;
    FOnLogViewerAddMessage: TLogViewerAddMessage;
    FDebug: Boolean;
    
    function GetPortManager(APortNumber: Integer): TSinglePortManager;
    function GetOrCreatePortManager(APortNumber: Integer; 
      APortType: TComPortType): TSinglePortManager;
    procedure SetDebug(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    
    // Основные методы
    procedure AddModule(AModule: TFmxModule);
    procedure RemoveModule(AModule: TFmxModule);
    procedure ExecuteInPortThread(APortNumber: Integer; 
      AMethod: TProcedureOfObject; AFirst: Boolean = False);
    function SendCommand(AModule: TFmxModule; const ACommand: ShortString; 
      AResponseLength: Integer; ATerminator: Char = #0): Boolean;
    
    // Управление всеми портами
    procedure StartAll;
    procedure StopAll;
    procedure SuspendAll;
    procedure ResumeAll;
    
    // Статистика
    function GetPortCount: Integer;
    function GetModuleCount: Integer;
    function GetPortStatus(APortNumber: Integer): TPortStatus;
    function GetPortState(APortNumber: Integer): ShortString;
    
    // Свойства
    property PortManager[PortNumber: Integer]: TSinglePortManager read GetPortManager;
    property OnLogViewerAddMessage: TLogViewerAddMessage read FOnLogViewerAddMessage write FOnLogViewerAddMessage;
    property Debug: Boolean read FDebug write SetDebug;
  end;

  // Менеджер для одного порта
  TSinglePortManager = class
  private
    FOwner: TPortManager;
    FComPortNumber: Integer;
    FPortType: TComPortType;
    FModules: TList<TFmxModule>;
    FTransferThread: TTransferThread;
    FActive: Boolean;
    FPortReady: Boolean;
    FPortStatus: TPortStatus;
    FPortState: ShortString;
    FCurrentModuleIndex: Integer;
    FLoopStartTickCount: Cardinal;
    FLastLoopTime: Double;
    
    // COM-порт поля
    {$IFDEF MSWINDOWS}
    FPort: Cardinal;
    FCTO: COMMTIMEOUTS;
    FDCB: DCB;
    {$ENDIF}
    
    // TCP клиент
    FTCP_Client: TIdTCPClient;
    FModbusTCPHost: string;
    FModbusTCPPort: Word;
    FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT: Boolean;
    FTCP_Client_Active: Boolean;
    
    // Очередь запросов
    FCOMRunQueriesBuffer: array[1..COM_RUN_QUERY_BUFFER_LENGTH] of TProcedureOfObject;
    FCOMRunQueriesCount: Integer;
    
    // Настройки
    FSENDING_TRIES_COUNT: Integer;
    FDopTimOut: Integer;
    FDelayBeforeSendCommand: Integer;
    
    // Логирование
    FLogFile: TextFile;
    FLogFileName: string;
    FLogFileIsOpened: Boolean;
    FShowPortInLog: Boolean;
    FShowModuleInLog: Boolean;
    
    procedure COMLoopProc;
    procedure OpenPort;
    procedure ClosePort;
    procedure UpdateNext;
    function SendCommandToModule(AModule: TFmxModule; const ACommand: ShortString; 
      AResponseLength: Integer; ATerminator: Char = #0): Boolean;
    function TCP_Client_Connected: Boolean;
    procedure SetActive(const Value: Boolean);
    procedure SetPortState(const Value: ShortString);
    procedure LogMessage(const AText: string; AColor: TAlphaColor = TAlphaColorRec.Black);
    procedure AddToLog(AModule: TFmxModule; ABuffer: PByte; ALength: Integer; 
      ASended: Boolean; AErr: Boolean = False);
    procedure GetNextCurrentModule(AUseTime: Boolean = False);
    procedure ExecuteErrorTransaction(AModule: TFmxModule);
    function GetModuleCount: Integer;
    procedure WriteToBuffer(AStr: ShortString; AModule: TFmxModule);
    
    // COM порт операции
    function WriteToPort(ABuffer: Pointer; ALength: Cardinal): Cardinal;
    function ReadFromPort(ABuffer: Pointer; ALength: Cardinal): Cardinal;
    procedure SetupPortParameters(ABaudRate: Integer; AParity: Byte; ATimeout: Integer);
    
  public
    constructor Create(AOwner: TPortManager; APortNumber: Integer; APortType: TComPortType);
    destructor Destroy; override;
    
    procedure AddModule(AModule: TFmxModule);
    procedure RemoveModule(AModule: TFmxModule);
    function ContainsModule(AModule: TFmxModule): Boolean;
    
    procedure ExecuteInCOMThread(AMethod: TProcedureOfObject; AFirst: Boolean = False);
    function SendCommand(AModule: TFmxModule; const ACommand: ShortString; 
      AResponseLength: Integer; ATerminator: Char = #0): Boolean;
    
    // Свойства
    property ComPortNumber: Integer read FComPortNumber;
    property PortType: TComPortType read FPortType;
    property Active: Boolean read FActive write SetActive;
    property PortReady: Boolean read FPortReady;
    property PortStatus: TPortStatus read FPortStatus;
    property PortState: ShortString read FPortState write SetPortState;
    property ModuleCount: Integer read GetModuleCount;
    property LastLoopTime: Double read FLastLoopTime;
  end;

implementation

uses
  System.DateUtils;

{ TPortManager }

constructor TPortManager.Create;
begin
  inherited Create;
  FPortManagers := TObjectDictionary<Integer, TSinglePortManager>.Create([doOwnsValues]);
  FDebug := False;
end;

destructor TPortManager.Destroy;
begin
  StopAll;
  FPortManagers.Free;
  inherited Destroy;
end;

procedure TPortManager.AddModule(AModule: TFmxModule);
var
  PortManager: TSinglePortManager;
  PortType: TComPortType;
begin
  if not Assigned(AModule) then Exit;

  // Определяем тип порта на основе типа модуля
  case AModule.ModuleType of
    mtFlowmeter: PortType := ctFlowmeter;
    else PortType := ctMain;
  end;

  PortManager := GetOrCreatePortManager(AModule.PortNumber, PortType);
  PortManager.AddModule(AModule);
  
  if Debug then
    LogMessage(Format('Модуль %s добавлен в порт COM%d', 
      [AModule.ModuleName, AModule.PortNumber]));
end;

procedure TPortManager.RemoveModule(AModule: TFmxModule);
var
  PortManager: TSinglePortManager;
begin
  if not Assigned(AModule) then Exit;
  
  if FPortManagers.TryGetValue(AModule.PortNumber, PortManager) then
  begin
    PortManager.RemoveModule(AModule);
    
    // Если в порте не осталось модулей, удаляем менеджер порта
    if PortManager.ModuleCount = 0 then
      FPortManagers.Remove(AModule.PortNumber);
  end;
end;

function TPortManager.GetOrCreatePortManager(APortNumber: Integer; 
  APortType: TComPortType): TSinglePortManager;
begin
  if not FPortManagers.TryGetValue(APortNumber, Result) then
  begin
    Result := TSinglePortManager.Create(Self, APortNumber, APortType);
    Result.OnLogViewerAddMessage := FOnLogViewerAddMessage;
    FPortManagers.Add(APortNumber, Result);
    
    if Debug then
      LogMessage(Format('Создан менеджер для порта COM%d', [APortNumber]));
  end;
end;

function TPortManager.GetPortManager(APortNumber: Integer): TSinglePortManager;
begin
  if not FPortManagers.TryGetValue(APortNumber, Result) then
    Result := nil;
end;

procedure TPortManager.StartAll;
var
  PortManager: TSinglePortManager;
begin
  for PortManager in FPortManagers.Values do
    PortManager.Active := True;
    
  if Debug then
    LogMessage('Все порты запущены', TAlphaColorRec.Green);
end;

procedure TPortManager.StopAll;
var
  PortManager: TSinglePortManager;
begin
  for PortManager in FPortManagers.Values do
    PortManager.Active := False;
    
  if Debug then
    LogMessage('Все порты остановлены', TAlphaColorRec.Red);
end;

procedure TPortManager.SuspendAll;
var
  PortManager: TSinglePortManager;
begin
  for PortManager in FPortManagers.Values do
    if PortManager.Active then
      PortManager.Active := False;
end;

procedure TPortManager.ResumeAll;
var
  PortManager: TSinglePortManager;
begin
  for PortManager in FPortManagers.Values do
    if not PortManager.Active then
      PortManager.Active := True;
end;

function TPortManager.SendCommand(AModule: TFmxModule; const ACommand: ShortString;
  AResponseLength: Integer; ATerminator: Char): Boolean;
var
  PortManager: TSinglePortManager;
begin
  Result := False;
  if Assigned(AModule) and FPortManagers.TryGetValue(AModule.PortNumber, PortManager) then
    Result := PortManager.SendCommand(AModule, ACommand, AResponseLength, ATerminator);
end;

procedure TPortManager.ExecuteInPortThread(APortNumber: Integer;
  AMethod: TProcedureOfObject; AFirst: Boolean);
var
  PortManager: TSinglePortManager;
begin
  if FPortManagers.TryGetValue(APortNumber, PortManager) then
    PortManager.ExecuteInCOMThread(AMethod, AFirst);
end;

function TPortManager.GetPortCount: Integer;
begin
  Result := FPortManagers.Count;
end;

function TPortManager.GetModuleCount: Integer;
var
  PortManager: TSinglePortManager;
begin
  Result := 0;
  for PortManager in FPortManagers.Values do
    Inc(Result, PortManager.ModuleCount);
end;

function TPortManager.GetPortStatus(APortNumber: Integer): TPortStatus;
var
  PortManager: TSinglePortManager;
begin
  if FPortManagers.TryGetValue(APortNumber, PortManager) then
    Result := PortManager.PortStatus
  else
    Result := psClose;
end;

function TPortManager.GetPortState(APortNumber: Integer): ShortString;
var
  PortManager: TSinglePortManager;
begin
  if FPortManagers.TryGetValue(APortNumber, PortManager) then
    Result := PortManager.PortState
  else
    Result := 'Порт не используется';
end;

procedure TPortManager.SetDebug(const Value: Boolean);
var
  PortManager: TSinglePortManager;
begin
  FDebug := Value;
  for PortManager in FPortManagers.Values do
    ; // Можно передать значение отладки в менеджеры портов при необходимости
end;

procedure TPortManager.LogMessage(const AText: string; AColor: TAlphaColor);
begin
  if Assigned(FOnLogViewerAddMessage) then
    FOnLogViewerAddMessage(AText, AColor);
end;

{ TSinglePortManager }

constructor TSinglePortManager.Create(AOwner: TPortManager; APortNumber: Integer;
  APortType: TComPortType);
begin
  inherited Create;
  FOwner := AOwner;
  FComPortNumber := APortNumber;
  FPortType := APortType;
  FModules := TList<TFmxModule>.Create;
  FActive := False;
  FPortReady := False;
  FPortStatus := psClose;
  FCurrentModuleIndex := 0;
  FLoopStartTickCount := GetTickCount;
  FLastLoopTime := 0.0;
  
  // Настройки по умолчанию
  FSENDING_TRIES_COUNT := 10;
  FDopTimOut := 100;
  FDelayBeforeSendCommand := 10;
  FShowPortInLog := True;
  FShowModuleInLog := True;
  FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT := True;
  
  // Инициализация COM порта
  {$IFDEF MSWINDOWS}
  FPort := INVALID_HANDLE_VALUE;
  {$ENDIF}
  
  // Инициализация TCP клиента
  FTCP_Client := TIdTCPClient.Create(nil);
  FModbusTCPHost := '127.0.0.1';
  FModbusTCPPort := 502;
  
  // Создание потока
  FTransferThread := TTransferThread.Create(True);
  FTransferThread.TransferProc := COMLoopProc;
  FTransferThread.Priority := tpNormal;
  
  // Открытие порта
  OpenPort;
  
  LogMessage(Format('Менеджер порта COM%d создан', [FComPortNumber]), TAlphaColorRec.Blue);
end;

destructor TSinglePortManager.Destroy;
begin
  Active := False;
  
  if Assigned(FTransferThread) then
  begin
    FTransferThread.Terminate;
    if not FTransferThread.Suspended then
      FTransferThread.Suspend;
    FTransferThread.WaitFor;
    FreeAndNil(FTransferThread);
  end;
  
  ClosePort;
  
  if Assigned(FTCP_Client) then
  begin
    if FTCP_Client.Connected then
      FTCP_Client.Disconnect;
    FreeAndNil(FTCP_Client);
  end;
  
  if FLogFileIsOpened then
    CloseFile(FLogFile);
    
  FreeAndNil(FModules);
  
  LogMessage(Format('Менеджер порта COM%d уничтожен', [FComPortNumber]));
  inherited Destroy;
end;

procedure TSinglePortManager.AddModule(AModule: TFmxModule);
begin
  if Assigned(AModule) and not FModules.Contains(AModule) then
  begin
    FModules.Add(AModule);
    LogMessage(Format('Модуль %s добавлен в COM%d', [AModule.ModuleName, FComPortNumber]), 
      TAlphaColorRec.Green);
  end;
end;

procedure TSinglePortManager.RemoveModule(AModule: TFmxModule);
begin
  if Assigned(AModule) then
  begin
    FModules.Remove(AModule);
    LogMessage(Format('Модуль %s удален из COM%d', [AModule.ModuleName, FComPortNumber]));
  end;
end;

function TSinglePortManager.ContainsModule(AModule: TFmxModule): Boolean;
begin
  Result := FModules.Contains(AModule);
end;

procedure TSinglePortManager.COMLoopProc;
begin
  if not FActive then Exit;
  
  try
    // Обработка очереди запросов
    if FCOMRunQueriesCount > 0 then
    begin
      try
        FCOMRunQueriesBuffer[FCOMRunQueriesCount];
        FCOMRunQueriesCount := FCOMRunQueriesCount - 1;
      except
        on E: Exception do
          LogMessage('Ошибка выполнения запроса: ' + E.Message, TAlphaColorRec.Red);
      end;
    end
    else
    begin
      // Обычный цикл опроса модулей
      UpdateNext;
    end;
    
    // Небольшая пауза для снижения нагрузки на CPU
    Sleep(1);
    
  except
    on E: Exception do
      LogMessage('Ошибка в потоке порта COM' + IntToStr(FComPortNumber) + ': ' + E.Message, 
        TAlphaColorRec.Red);
  end;
end;

procedure TSinglePortManager.UpdateNext;
var
  Module: TFmxModule;
  Stage, I, RequestLength, ResponseLength: Integer;
  Written, Readed: Cardinal;
  OutputBuffer, InBuffer: array[0..255] of AnsiChar;
  Request, Response: ShortString;
  TypeOfProtocol: TTypeOfProtocol;
  OutputBytes, InBytes: TIdBytes;
begin
  if not FActive or (FModules.Count = 0) then Exit;
  
  // Получаем текущий модуль
  if not (FCurrentModuleIndex in [0..FModules.Count-1]) then
    FCurrentModuleIndex := 0;
    
  Module := FModules[FCurrentModuleIndex];
  if not Assigned(Module) then
  begin
    GetNextCurrentModule;
    Exit;
  end;
  
  if not Module.EnabledAutoUpdate or Module.Disguise then
  begin
    GetNextCurrentModule;
    Exit;
  end;
  
  try
    Module.TotalSended := Module.TotalSended + 1;
    TypeOfProtocol := Module.Protocol;
    
    // Подготовка порта
    PortReady := False;
    if TypeOfProtocol in [tpProprietary..tpModbusASCII] then
    begin
      // Настройка COM порта
      SetupPortParameters(Module.BaudRate, Ord(Module.Parity), Module.Timeout + FDopTimOut);
      PortReady := (FPort <> INVALID_HANDLE_VALUE);
    end
    else
    begin
      // Modbus TCP
      PortReady := TCP_Client_Connected;
    end;
    
    if not PortReady then
    begin
      ExecuteErrorTransaction(Module);
      Exit;
    end;
    
    // Получение команды запроса статуса
    Request := Module.StatusQuery;
    RequestLength := Length(Request);
    ResponseLength := Module.ResponseLength;
    
    if RequestLength > 0 then
    begin
      // Подготовка буфера отправки
      for I := 1 to RequestLength do
        OutputBuffer[I-1] := Request[I];
        
      if TypeOfProtocol = tpModbusTCP then
        OutputBytes := RawToBytes(OutputBuffer, RequestLength);
        
      for Stage := 1 to FSENDING_TRIES_COUNT do
      begin
        if not FActive then Break;
        
        if Stage > 1 then
          Sleep(10 * Stage * 2); // Увеличение задержки при повторах
          
        // Отправка запроса
        AddToLog(Module, @OutputBuffer[0], RequestLength, True);
        
        try
          if TypeOfProtocol in [tpProprietary..tpModbusASCII] then
          begin
            {$IFDEF MSWINDOWS}
            EscapeCommFunction(FPort, SETRTS);
            PurgeComm(FPort, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
            WriteToPort(@OutputBuffer[0], RequestLength);
            {$ENDIF}
          end
          else
          begin
            // Modbus TCP
            FTCP_Client.Socket.Write(OutputBytes);
          end;
        except
          on E: Exception do
          begin
            PortState := 'Ошибка отправки: ' + E.Message;
            Continue;
          end;
        end;
        
        // Чтение ответа (если ожидается)
        if ResponseLength > 0 then
        begin
          Readed := 0;
          try
            if TypeOfProtocol in [tpProprietary..tpModbusASCII] then
            begin
              {$IFDEF MSWINDOWS}
              Readed := ReadFromPort(@InBuffer[0], ResponseLength);
              {$ENDIF}
            end
            else
            begin
              // Modbus TCP
              FTCP_Client.Socket.ReadBytes(InBytes, -1);
              Readed := Length(InBytes);
              for I := 0 to Readed - 1 do
                InBuffer[I] := AnsiChar(InBytes[I]);
            end;
          except
            on E: Exception do
            begin
              PortState := 'Ошибка чтения: ' + E.Message;
            end;
          end;
          
          // Логирование ответа
          if (ResponseLength <> Readed) then
            AddToLog(Module, @InBuffer[0], Readed, False, True)
          else
            AddToLog(Module, @InBuffer[0], Readed, False);
            
          // Обработка ответа
          Response := '';
          if Readed > 0 then
          begin
            for I := 1 to Readed do
              Response := Response + InBuffer[I-1];
              
            if Module.CheckResponse(Request, Response) then
            begin
              Module.TotalReceived := Module.TotalReceived + 1;
              Module.ReceiveResponse(Request, Response);
              Break;
            end;
          end;
          
          if Stage = FSENDING_TRIES_COUNT then
            ExecuteErrorTransaction(Module);
        end
        else
        begin
          // Ответ не ожидается
          Module.TotalReceived := Module.TotalReceived + 1;
          Break;
        end;
      end;
    end;
    
    GetNextCurrentModule(True);
    
  except
    on E: Exception do
    begin
      LogMessage('Ошибка в UpdateNext COM' + IntToStr(FComPortNumber) + ': ' + E.Message, 
        TAlphaColorRec.Red);
      GetNextCurrentModule;
    end;
  end;
end;

procedure TSinglePortManager.GetNextCurrentModule(AUseTime: Boolean);
begin
  if FModules.Count = 0 then Exit;
  
  FCurrentModuleIndex := FCurrentModuleIndex + 1;
  if FCurrentModuleIndex >= FModules.Count then
  begin
    FCurrentModuleIndex := 0;
    if AUseTime then
    begin
      FLastLoopTime := (GetTickCount - FLoopStartTickCount) / 1000.0;
      FLoopStartTickCount := GetTickCount;
    end;
  end;
end;

procedure TSinglePortManager.ExecuteErrorTransaction(AModule: TFmxModule);
begin
  if Assigned(AModule) then
  begin
    AModule.BadPackages := AModule.BadPackages + 1;
    if not AModule.Disguise then 
      AModule.ConnectIsOK := fdqBad;
    AModule.TimeOuts := AModule.TimeOuts + 1;
    AModule.ReceiveResponse;
  end;
end;

function TSinglePortManager.SendCommand(AModule: TFmxModule; const ACommand: ShortString;
  AResponseLength: Integer; ATerminator: Char): Boolean;
begin
  Result := False;
  if ContainsModule(AModule) and FActive then
  begin
    Sleep(FDelayBeforeSendCommand); // Задержка между командами
    Result := SendCommandToModule(AModule, ACommand, AResponseLength, ATerminator);
  end;
end;

function TSinglePortManager.SendCommandToModule(AModule: TFmxModule;
  const ACommand: ShortString; AResponseLength: Integer; ATerminator: Char): Boolean;
var
  Stage, I, RequestLength: Integer;
  Written, Readed: Cardinal;
  OutputBuffer, InBuffer: array[0..255] of AnsiChar;
  Response: ShortString;
  TypeOfProtocol: TTypeOfProtocol;
  OutputBytes, InBytes: TIdBytes;
begin
  Result := False;
  if not Assigned(AModule) then Exit;
  
  TypeOfProtocol := AModule.Protocol;
  RequestLength := Length(ACommand);
  
  // Подготовка буфера отправки
  for I := 1 to RequestLength do
    OutputBuffer[I-1] := ACommand[I];
    
  if TypeOfProtocol = tpModbusTCP then
    OutputBytes := RawToBytes(OutputBuffer, RequestLength);
    
  AModule.TotalSended := AModule.TotalSended + 1;
  
  for Stage := 1 to FSENDING_TRIES_COUNT do
  begin
    if not FActive then Break;
    
    if Stage > 1 then
      Sleep(10 * Stage * 2);
      
    // Отправка команды
    AddToLog(AModule, @OutputBuffer[0], RequestLength, True);
    
    try
      if TypeOfProtocol in [tpProprietary..tpModbusASCII] then
      begin
        {$IFDEF MSWINDOWS}
        EscapeCommFunction(FPort, SETRTS);
        PurgeComm(FPort, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
        WriteToPort(@OutputBuffer[0], RequestLength);
        {$ENDIF}
      end
      else
      begin
        FTCP_Client.Socket.Write(OutputBytes);
      end;
    except
      on E: Exception do
      begin
        PortState := 'Ошибка отправки команды: ' + E.Message;
        Continue;
      end;
    end;
    
    // Чтение ответа
    if AResponseLength > 0 then
    begin
      Readed := 0;
      try
        if TypeOfProtocol in [tpProprietary..tpModbusASCII] then
        begin
          {$IFDEF MSWINDOWS}
          Readed := ReadFromPort(@InBuffer[0], AResponseLength);
          {$ENDIF}
        end
        else
        begin
          FTCP_Client.Socket.ReadBytes(InBytes, -1);
          Readed := Length(InBytes);
          for I := 0 to Readed - 1 do
            InBuffer[I] := AnsiChar(InBytes[I]);
        end;
      except
        on E: Exception do
        begin
          PortState := 'Ошибка чтения ответа: ' + E.Message;
        end;
      end;
      
      // Логирование ответа
      if (AResponseLength <> Readed) then
        AddToLog(AModule, @InBuffer[0], Readed, False, True)
      else
        AddToLog(AModule, @InBuffer[0], Readed, False);
        
      // Обработка ответа
      Response := '';
      if Readed > 0 then
      begin
        for I := 1 to Readed do
          Response := Response + InBuffer[I-1];
          
        if AModule.CheckResponse(ACommand, Response) then
        begin
          AModule.TotalReceived := AModule.TotalReceived + 1;
          AModule.ReceiveResponse(ACommand, Response);
          Result := True;
          Break;
        end;
      end;
    end
    else
    begin
      // Ответ не ожидается
      AModule.TotalReceived := AModule.TotalReceived + 1;
      Result := True;
      Break;
    end;
  end;
  
  if not Result then
    ExecuteErrorTransaction(AModule);
end;

procedure TSinglePortManager.OpenPort;
begin
  {$IFDEF MSWINDOWS}
  if FComPortNumber <= 0 then
  begin
    PortState := 'Неверный номер порта';
    Exit;
  end;
  
  FPort := CreateFile(
    PChar('\\.\' + 'COM' + IntToStr(FComPortNumber)),
    GENERIC_READ or GENERIC_WRITE,
    0,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0
  );
  
  if FPort = INVALID_HANDLE_VALUE then
  begin
    FPortStatus := psError;
    PortState := 'Ошибка открытия порта COM' + IntToStr(FComPortNumber);
    LogMessage(PortState, TAlphaColorRec.Red);
    Exit;
  end;
  
  // Настройка параметров порта
  GetCommState(FPort, FDCB);
  FDCB.BaudRate := CBR_115200;
  FDCB.Parity := NOPARITY;
  FDCB.ByteSize := 8;
  FDCB.StopBits := ONESTOPBIT;
  SetCommState(FPort, FDCB);
  
  // Настройка таймаутов
  GetCommTimeouts(FPort, FCTO);
  FCTO.ReadIntervalTimeout := MAXWORD;
  FCTO.ReadTotalTimeoutMultiplier := 0;
  FCTO.ReadTotalTimeoutConstant := 300;
  FCTO.WriteTotalTimeoutMultiplier := 0;
  FCTO.WriteTotalTimeoutConstant := 300;
  SetCommTimeouts(FPort, FCTO);
  
  EscapeCommFunction(FPort, SETRTS);
  
  FPortStatus := psOpen;
  FPortReady := True;
  PortState := 'Порт COM' + IntToStr(FComPortNumber) + ' открыт';
  LogMessage(PortState, TAlphaColorRec.Green);
  {$ENDIF}
end;

procedure TSinglePortManager.ClosePort;
begin
  FPortReady := False;
  
  {$IFDEF MSWINDOWS}
  if FPort <> INVALID_HANDLE_VALUE then
  begin
    PurgeComm(FPort, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
    EscapeCommFunction(FPort, CLRRTS);
    CloseHandle(FPort);
    FPort := INVALID_HANDLE_VALUE;
  end;
  {$ENDIF}
  
  FPortStatus := psClose;
  PortState := 'Порт COM' + IntToStr(FComPortNumber) + ' закрыт';
  LogMessage(PortState);
end;

procedure TSinglePortManager.SetupPortParameters(ABaudRate: Integer; AParity: Byte; ATimeout: Integer);
begin
  {$IFDEF MSWINDOWS}
  if FPort = INVALID_HANDLE_VALUE then Exit;
  
  GetCommState(FPort, FDCB);
  FDCB.BaudRate := ABaudRate;
  FDCB.Parity := AParity;
  SetCommState(FPort, FDCB);
  
  GetCommTimeouts(FPort, FCTO);
  FCTO.ReadTotalTimeoutConstant := ATimeout;
  SetCommTimeouts(FPort, FCTO);
  {$ENDIF}
end;

function TSinglePortManager.WriteToPort(ABuffer: Pointer; ALength: Cardinal): Cardinal;
begin
  Result := 0;
  {$IFDEF MSWINDOWS}
  if FPort <> INVALID_HANDLE_VALUE then
    WriteFile(FPort, ABuffer^, ALength, Result, nil);
  {$ENDIF}
end;

function TSinglePortManager.ReadFromPort(ABuffer: Pointer; ALength: Cardinal): Cardinal;
begin
  Result := 0;
  {$IFDEF MSWINDOWS}
  if FPort <> INVALID_HANDLE_VALUE then
    ReadFile(FPort, ABuffer^, ALength, Result, nil);
  {$ENDIF}
end;

function TSinglePortManager.TCP_Client_Connected: Boolean;
begin
  Result := False;
  
  if not FTCP_Client.Connected then
  begin
    FTCP_Client.Host := FModbusTCPHost;
    FTCP_Client.Port := FModbusTCPPort;
  end;
  
  if not FHOLD_CONNECTION_WITH_MODBUS_TCP_CLIENT then
  begin
    if FTCP_Client.Connected then
      FTCP_Client.Disconnect;
  end;
  
  try
    if not FTCP_Client.Connected then
    begin
      FTCP_Client.Connect;
      FTCP_Client_Active := True;
      PortState := 'Подключен к TCP: ' + FModbusTCPHost + ':' + IntToStr(FModbusTCPPort);
      LogMessage(PortState, TAlphaColorRec.Green);
    end;
    Result := FTCP_Client_Active;
  except
    on E: Exception do
    begin
      FTCP_Client_Active := False;
      PortState := 'Ошибка подключения TCP: ' + E.Message;
      LogMessage(PortState, TAlphaColorRec.Red);
    end;
  end;
end;

procedure TSinglePortManager.ExecuteInCOMThread(AMethod: TProcedureOfObject; AFirst: Boolean);
begin
  if not Assigned(AMethod) then Exit;
  
  {$IFDEF MSWINDOWS}
  if GetCurrentThreadID = FTransferThread.ThreadID then
  begin
    // Если уже в потоке порта - выполняем сразу
    try
      AMethod;
    except
      on E: Exception do
        LogMessage('Ошибка выполнения в потоке порта: ' + E.Message, TAlphaColorRec.Red);
    end;
  end
  else
  {$ENDIF}
  begin
    // Добавляем в очередь
    if FCOMRunQueriesCount < COM_RUN_QUERY_BUFFER_LENGTH then
    begin
      if AFirst then
      begin
        FCOMRunQueriesCount := FCOMRunQueriesCount + 1;
        for var I := FCOMRunQueriesCount downto 2 do
          FCOMRunQueriesBuffer[I] := FCOMRunQueriesBuffer[I-1];
        FCOMRunQueriesBuffer[1] := AMethod;
      end
      else
      begin
        FCOMRunQueriesCount := FCOMRunQueriesCount + 1;
        FCOMRunQueriesBuffer[FCOMRunQueriesCount] := AMethod;
      end;
    end
    else
    begin
      LogMessage('Переполнение очереди запросов порта COM' + IntToStr(FComPortNumber), 
        TAlphaColorRec.Red);
    end;
  end;
end;

procedure TSinglePortManager.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    
    if FActive then
    begin
      if Assigned(FTransferThread) and FTransferThread.Suspended then
        FTransferThread.Resume;
      LogMessage('Порт COM' + IntToStr(FComPortNumber) + ' активирован', TAlphaColorRec.Green);
    end
    else
    begin
      if Assigned(FTransferThread) and not FTransferThread.Suspended then
        FTransferThread.Suspend;
      LogMessage('Порт COM' + IntToStr(FComPortNumber) + ' приостановлен');
    end;
  end;
end;

procedure TSinglePortManager.SetPortState(const Value: ShortString);
begin
  FPortState := Value;
  LogMessage('COM' + IntToStr(FComPortNumber) + ': ' + Value);
end;

procedure TSinglePortManager.AddToLog(AModule: TFmxModule; ABuffer: PByte; 
  ALength: Integer; ASended: Boolean; AErr: Boolean);
var
  Hour, Min, Sec, MSec: Word;
  Str, SubStr: string;
  I: Integer;
  MsgColor: TAlphaColor;
begin
  if not FLogFileIsOpened or (FLogFileName = '') then Exit;
  
  try
    AssignFile(FLogFile, FLogFileName);
    {$I-}
    Append(FLogFile);
    {$I+}
    FLogFileIsOpened := IOResult = 0;
    
    if not FLogFileIsOpened then Exit;
    
    Str := '';
    DecodeTime(Time, Hour, Min, Sec, MSec);
    Str := Str + Format('%.2d:%.2d:%.2d.%.3d', [Hour, Min, Sec, MSec]);
    
    SubStr := '';
    if FShowPortInLog then
      SubStr := ' COM' + IntToStr(FComPortNumber);
    if FShowModuleInLog and Assigned(AModule) then
    begin
      if AModule.ModuleType <> mtDigitalUnit then
        SubStr := SubStr + ' ' + AModule.ModuleName + Format('(0x%0.2X)', [AModule.FAddress])
      else
        SubStr := SubStr + ' ' + AModule.ModuleName;
    end;
    
    if ASended then
      Str := Str + SubStr + ') <-- '
    else
      Str := Str + SubStr + ') --> ';
      
    if not FPortReady then
    begin
      Str := Str + ' E:' + FPortState;
      MsgColor := TAlphaColorRec.Blue;
    end
    else
    begin
      if AErr then
        MsgColor := TAlphaColorRec.DarkRed
      else if ASended then
        MsgColor := TAlphaColorRec.DarkGreen
      else
        MsgColor := TAlphaColorRec.DarkOliveGreen;
        
      if ALength > 0 then
      begin
        if Assigned(AModule) and AModule.ASCII then
        begin
          for I := 0 to ALength - 1 do
          begin
            case ABuffer[I] of
              13: Str := Str + '<CR>';
              10: Str := Str + '<LF>';
              $A6: Str := Str + '<A6>';
              else Str := Str + Chr(ABuffer[I]);
            end;
          end;
        end
        else
        begin
          Str := Str + '[hex] ' + B2HS(ABuffer, ALength);
        end;
      end
      else
      begin
        Str := Str + 'нет ответа...';
      end;
    end;
    
    WriteLn(FLogFile, Str);
    CloseFile(FLogFile);
    
    if FOwner.Debug and Assigned(FOwner.OnLogViewerAddMessage) then
      FOwner.OnLogViewerAddMessage(Str, MsgColor);
      
  except
    on E: Exception do
    begin
      FLogFileIsOpened := False;
    end;
  end;
end;

procedure TSinglePortManager.LogMessage(const AText: string; AColor: TAlphaColor);
begin
  if Assigned(FOwner) and Assigned(FOwner.OnLogViewerAddMessage) then
    FOwner.OnLogViewerAddMessage(AText, AColor);
end;

procedure TSinglePortManager.WriteToBuffer(AStr: ShortString; AModule: TFmxModule);
begin
  // Реализация записи в буфер просмотра (если нужна)
  // ...
end;

function TSinglePortManager.GetModuleCount: Integer;
begin
  Result := FModules.Count;
end;

end.