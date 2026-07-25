unit uTransferManager;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  System.DateUtils,
  System.UITypes,
  Winapi.Windows,
  FmxFPModule,
  FmxHelper,
  IdTCPClient,
  IdGlobal,
  System.Generics.Collections;

const
  cSleepBeforeRead = 50;
  cDelayAfterErrorFirstRequest = 10;
  c_DopTimOut = 50;

type
  // Структура для хранения информации о COM-порте
  TComPortInfo = record
    PortHandle: Cardinal;
    PortNumber: integer;
    BaudRate: integer;
    Parity: Integer;
    Timeout: integer;
    IsOpen: Boolean;
    LastUsed: TDateTime;
    TimeOuts: Longint;
    TotalAttempts: Longint;
  end;

  // Событие для логирования
  TLogViewerAddMessage = procedure(const AText: string; const AColor: TAlphaColor = TAlphaColorRec.Black; const AStyle: TFontStyles = []) of object;

  // ============================================================
  //  TTransferWorker – воркер для одного порта (синхронный)
  // ============================================================
  TTransferWorker = class(TThread)
  private
    FName: string;
    FPortNumber: Integer;
    FManager: TObject;                  // ссылка на TFmxModuleManager
    FComPortInfo: TComPortInfo;
    FTCPClient: TIdTCPClient;
    FUseTCP: Boolean;
    FHost: string;
    FPort: Word;
    FHoldConnection: Boolean;
    FLock: TCriticalSection;
    FSendCommandCS: TCriticalSection;
    FWorkerID: Integer;                 // Уникальный ID для отладки
    FLogViewer: TLogViewerAddMessage;   // Ссылка на метод логирования

    procedure ClosePort;
    function OpenPort(AModule: TFmxModule): Boolean;
    procedure LogTransaction(Module: TFmxModule; buffer: PByte; length: Integer;
      sended: Boolean; err: Boolean = False);
    procedure DoLog(const Msg: string);
    function GetDebug: boolean;

  protected
    procedure Execute; override;

  public
    constructor Create(AManager: TObject; APortNumber: Integer; AUseTCP: Boolean = False;
      const AHost: string = ''; APort: Word = 0);
    destructor Destroy; override;

    // Синхронная отправка команды
    function SendCommand(AModule: TFmxModule; const ACommand: ShortString;
      AResponseLength: Integer; ATerminator: ansiChar = #0): Boolean;

    procedure Stop;

    // Информация о порте
    function GetPortInfo: TComPortInfo;
    function IsPortOpen: Boolean;
    function GetPortNumber: Integer;
    procedure UpdateLastUsed;
    property Debug:boolean read GetDebug;
  end;

  // ============================================================
  //  TTransferManager – менеджер воркеров
  // ============================================================
  TTransferManager = class
  private
    FWorkers: TList;                    // список TWorkerItem
    FLock: TCriticalSection;
    FModuleManager: TObject;
    FDefaultRetryCount: Integer;
    FLogViewer: TLogViewerAddMessage;
    function GetDebug: boolean;

    type
      PWorkerItem = ^TWorkerItem;
      TWorkerItem = record
        Key: Integer;       // номер порта (для TCP – 0)
        Worker: TTransferWorker;
      end;

    function FindWorker(Key: Integer): TTransferWorker;
    function GetOrCreateWorker(AModule: TFmxModule): TTransferWorker;
    procedure DoLog(const Msg: string);

  public
    constructor Create(AModuleManager: TObject);
    destructor Destroy; override;

    // Синхронная отправка (ждёт ответа)
    function SendCommand(AModule: TFmxModule; const ACommand: ShortString;
      AResponseLength: Integer; ATerminator: ansiChar = #0): Boolean;

    procedure StopAll;
    property DefaultRetryCount: Integer read FDefaultRetryCount write FDefaultRetryCount;

    // === Новые методы для доступа к информации о портах ===

    // Получить информацию о порте по номеру
    function GetPortInfoByNumber(PortNumber: Integer; out PortInfo: TComPortInfo): Boolean;

    // Получить информацию о порте по индексу в списке
    function GetPortInfoByIndex(Index: Integer; out PortInfo: TComPortInfo): Boolean;

    // Получить количество открытых портов
    function GetOpenPortsCount: Integer;

    // Получить список всех открытых портов
    function GetOpenPortsList: TList<Integer>;

    // Проверить, открыт ли порт
    function IsPortOpen(PortNumber: Integer): Boolean;

    // Обновить время последнего использования порта
    procedure UpdatePortLastUsed(PortNumber: Integer);

    // Закрыть все порты
    procedure CloseAllPorts;

    // Закрыть указанный порт
    procedure ClosePort(PortNumber: Integer);

    // Очистить неиспользуемые порты (таймаут в минутах)
    procedure CleanupUnusedPorts(TimeoutMinutes: Integer);

    // Получить строковое представление всех портов
    function GetPortsStatusString: string;

    // Установить обработчик логирования
    procedure SetLogViewer(ALogViewer: TLogViewerAddMessage);

    property Debug:boolean read GetDebug;
  end;

implementation

uses
  FmxFPModuleManager;  // для доступа к TFmxModuleManager.AddToLog

// ============================================================
//  TTransferWorker
// ============================================================

var
  G_WorkerCounter: Integer = 0;

constructor TTransferWorker.Create(AManager: TObject; APortNumber: Integer;
  AUseTCP: Boolean; const AHost: string; APort: Word);
begin
  inherited Create(True);
  FManager := AManager;
  FPortNumber := APortNumber;
  FUseTCP := AUseTCP;
  FHost := AHost;
  FPort := APort;
  FHoldConnection := False;
  FLock := TCriticalSection.Create;
  FSendCommandCS := TCriticalSection.Create;

  // Уникальный ID для отладки
  InterlockedIncrement(G_WorkerCounter);
  FWorkerID := G_WorkerCounter;

    // Формируем понятное уникальное имя.
  if FUseTCP then
    FName := Format(
      'TransferWorker_TCP_%s_%d_ID%d',
      [
        FHost,
        FPort,
        FWorkerID
      ]
    )
  else
    FName := Format(
      'TransferWorker_COM%d_ID%d',
      [
        FPortNumber,
        FWorkerID
      ]
    );

  if FUseTCP then
  begin
    FTCPClient := TIdTCPClient.Create(nil);
    FTCPClient.Host := FHost;
    FTCPClient.Port := FPort;
  end
  else
    FTCPClient := nil;

  FillChar(FComPortInfo, SizeOf(FComPortInfo), 0);
  FComPortInfo.PortHandle := INVALID_HANDLE_VALUE;
  FComPortInfo.PortNumber := APortNumber;
  FComPortInfo.IsOpen := False;
  FreeOnTerminate := False;

  // Получаем ссылку на метод логирования, если менеджер является TFmxModuleManager
  if Assigned(FManager) and (FManager is TFmxModuleManager) then
    FLogViewer := TFmxModuleManager(FManager).OnLogViewerAddMessage;

  Resume;
end;

destructor TTransferWorker.Destroy;
begin
  Terminate;
  if Suspended then Resume;
  WaitFor;

  if Assigned(FTCPClient) then
  begin
    if FTCPClient.Connected then
      FTCPClient.Disconnect;
    FTCPClient.Free;
  end;

  ClosePort;
  FLock.Free;
  FSendCommandCS.Free;
  inherited;
end;

procedure TTransferWorker.Execute;
begin
  TThread.NameThreadForDebugging(FName);
  // Поток не используется для цикла, все операции синхронные.
  // Метод нужен только для переопределения абстрактного метода.
end;

procedure TTransferWorker.DoLog(const Msg: string);
begin
  if Assigned(FLogViewer) and Debug then
    FLogViewer(Msg, TAlphaColorRec.Black, []);
end;

procedure TTransferWorker.ClosePort;
begin
  FLock.Enter;
  try
    if FComPortInfo.IsOpen then
    begin
      PurgeComm(FComPortInfo.PortHandle, PURGE_TXABORT or PURGE_RXABORT or
                PURGE_TXCLEAR or PURGE_RXCLEAR);
      EscapeCommFunction(FComPortInfo.PortHandle, CLRRTS);
      CloseHandle(FComPortInfo.PortHandle);
      FComPortInfo.IsOpen := False;
      FComPortInfo.PortHandle := INVALID_HANDLE_VALUE;
      DoLog('Порт COM' + IntToStr(FPortNumber) + ' закрыт (воркер ' + IntToStr(FWorkerID) + ')');
    end;
  finally
    FLock.Leave;
  end;
end;

function TTransferWorker.OpenPort(AModule: TFmxModule): Boolean;
var
  DCB: TDCB;
  CTO: COMMTIMEOUTS;
  Timeout: Integer;
  PortName: string;
  ErrorCode: DWORD;
begin
  Result := False;

  if FUseTCP then
  begin
    try
      if not FTCPClient.Connected then
        FTCPClient.Connect;
      Result := FTCPClient.Connected;
    except
      Result := False;
    end;
    Exit;
  end;

  FLock.Enter;
  try
    // Если порт уже открыт и параметры совпадают – используем
    if FComPortInfo.IsOpen and (FComPortInfo.PortNumber = AModule.PortNumber) then
    begin
      if (FComPortInfo.BaudRate <> AModule.BaudRate) or
         (FComPortInfo.Parity <> Ord(AModule.Parity)) then
      begin
        ClosePort; // переоткроем с новыми параметрами
      end
      else
      begin
        // Обновляем таймаут
        Timeout := AModule.Timeout + c_DopTimOut;
        GetCommTimeouts(FComPortInfo.PortHandle, CTO);
        CTO.ReadTotalTimeoutConstant := Timeout;
        SetCommTimeouts(FComPortInfo.PortHandle, CTO);
        FComPortInfo.LastUsed := Now;
        Result := True;
        Exit;
      end;
    end;

    // Открываем порт
    PortName := '\\.\COM' + IntToStr(AModule.PortNumber);

    FComPortInfo.PortHandle := CreateFile(
      PChar(PortName),
      GENERIC_READ or GENERIC_WRITE,
      0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

    if FComPortInfo.PortHandle = INVALID_HANDLE_VALUE then
    begin
      ErrorCode := GetLastError;
      FComPortInfo.IsOpen := False;
      DoLog('Ошибка открытия ' + PortName + ', код: ' + IntToStr(ErrorCode));
      Exit;
    end;

    // Настройка параметров порта
    GetCommState(FComPortInfo.PortHandle, DCB);
    DCB.BaudRate := AModule.BaudRate;
    DCB.Parity := Ord(AModule.Parity);
    DCB.ByteSize := 8;
    DCB.StopBits := ONESTOPBIT;
    SetCommState(FComPortInfo.PortHandle, DCB);

    // Таймауты
    GetCommTimeouts(FComPortInfo.PortHandle, CTO);
    CTO.ReadIntervalTimeout := MAXWORD;
    CTO.ReadTotalTimeoutMultiplier := 0;
    CTO.ReadTotalTimeoutConstant := AModule.Timeout + c_DopTimOut;
    CTO.WriteTotalTimeoutMultiplier := 150;
    CTO.WriteTotalTimeoutConstant := 100;
    SetCommTimeouts(FComPortInfo.PortHandle, CTO);

    EscapeCommFunction(FComPortInfo.PortHandle, SETRTS);

    FComPortInfo.IsOpen := True;
    FComPortInfo.PortNumber := AModule.PortNumber;
    FComPortInfo.BaudRate := AModule.BaudRate;
    FComPortInfo.Parity := Ord(AModule.Parity);
    FComPortInfo.Timeout := CTO.ReadTotalTimeoutConstant;
    FComPortInfo.LastUsed := Now;
    FComPortInfo.TimeOuts := 0;
    FComPortInfo.TotalAttempts := 0;
    Result := True;

    DoLog('Порт ' + PortName + ' открыт (воркер ' + IntToStr(FWorkerID) + ')');

  finally
    FLock.Leave;
  end;
end;

procedure TTransferWorker.LogTransaction(Module: TFmxModule; buffer: PByte;
  length: Integer; sended: Boolean; err: Boolean);
var
  Manager: TFmxModuleManager;
begin
  if Assigned(FManager) and (FManager is TFmxModuleManager) then
  begin
    if Debug then
    begin
      Manager := TFmxModuleManager(FManager);
      Manager.AddToLog(Module, buffer, length, sended, err);
    end;
  end;
end;

function TTransferWorker.SendCommand(AModule: TFmxModule; const ACommand: ShortString;
  AResponseLength: Integer; ATerminator: ansiChar): Boolean;
var
  stage, i, RequestLength: Integer;
  output_buffer, in_buff: array [0..255] of AnsiChar;
  written, readed: Cardinal;
  response: ShortString;
  _TypeOfProtocol: TTypeOfProtocol;
  _output_buffer, _in_buff: TIdBytes;
  Timeout: Integer;
  RetryCount: Integer;
  PortOpen: Boolean;
  LastError: DWORD;
begin
  Result := False;

  FSendCommandCS.Enter;
  try
    if not Assigned(AModule) then
    begin
      DoLog('SendCommand: модуль nil');
      Exit;
    end;

    _TypeOfProtocol := AModule.Protocol;
    RetryCount := 10;
    Timeout := AModule.Timeout;

    // Открываем порт
    PortOpen := OpenPort(AModule);
    if not PortOpen then
    begin
      AModule.ConnectIsOK := fdqBad;
      AModule.ReceiveResponse('*', '');
      DoLog('Не удалось открыть порт для ' + AModule.ModuleName);
      Exit;
    end;

    // Подготовка команды
    RequestLength := Length(ACommand);
    for i := 1 to RequestLength do
      output_buffer[i - 1] := ACommand[i];

    if _TypeOfProtocol = tpModbusTCP then
      _output_buffer := RawToBytes(output_buffer, RequestLength);

    // Логируем отправку
    LogTransaction(AModule, @output_buffer[0], RequestLength, True);

    // Если ответ не ожидается – просто отправляем и выходим
    if (AResponseLength = 0) and (ATerminator = #0) then
    begin
      if _TypeOfProtocol in [tpProprietary..tpModbusASCII] then
      begin
        PurgeComm(FComPortInfo.PortHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
        if not WriteFile(FComPortInfo.PortHandle, output_buffer, RequestLength, written, nil) then
        begin
          LastError := GetLastError;
          DoLog('Ошибка записи: ' + IntToStr(LastError));
        end;
      end
      else
        FTCPClient.Socket.Write(_output_buffer);
      Sleep(cSleepBeforeRead);
      Result := True;
      Exit;
    end;

    // Цикл попыток
    for stage := 1 to RetryCount do
    begin
      if Terminated then Break;

      if stage > 1 then
        Sleep(cDelayAfterErrorFirstRequest * stage * 2);

      if _TypeOfProtocol in [tpProprietary..tpModbusASCII] then
      begin
        PurgeComm(FComPortInfo.PortHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
        EscapeCommFunction(FComPortInfo.PortHandle, SETRTS);
      end;

      // Отправка
      try
        if _TypeOfProtocol in [tpProprietary..tpModbusASCII] then
        begin
          if not WriteFile(FComPortInfo.PortHandle, output_buffer, RequestLength, written, nil) then
          begin
            LastError := GetLastError;
            DoLog('Ошибка записи: ' + IntToStr(LastError));
            Continue;
          end;
        end
        else
          FTCPClient.Socket.Write(_output_buffer);
      except
        on e: Exception do
        begin
          DoLog('Ошибка отправки: ' + e.Message);
          Continue;
        end;
      end;

      // Пауза перед чтением
      Sleep(cSleepBeforeRead);

      // Чтение ответа
      readed := 0;
      if _TypeOfProtocol in [tpProprietary..tpModbusASCII] then
      begin
        if ATerminator = #0 then
        begin
          // Читаем фиксированное количество байт
          if not ReadFile(FComPortInfo.PortHandle, in_buff, AResponseLength, readed, nil) then
          begin
            LastError := GetLastError;
            DoLog('Ошибка чтения: ' + IntToStr(LastError));
            Continue;
          end;
        end
        else
        begin
          // Читаем до терминатора
          var ch: AnsiChar;
          var total: Integer := 0;
          while total < AResponseLength do
          begin
            if not ReadFile(FComPortInfo.PortHandle, ch, 1, readed, nil) then
            begin
              LastError := GetLastError;
              DoLog('Ошибка чтения: ' + IntToStr(LastError));
              Break;
            end;
            if readed = 0 then Break;
            in_buff[total] := ch;
            Inc(total);
            if ch = ATerminator then Break;
          end;
          readed := total;
        end;
      end
      else
      begin
        // Modbus TCP
        try
          FTCPClient.Socket.ReadBytes(_in_buff, -1);
          readed := Length(_in_buff);
          for i := 0 to readed - 1 do
            in_buff[i] := AnsiChar(_in_buff[i]);
        except
          on e: Exception do
          begin
            DoLog('Ошибка TCP чтения: ' + e.Message);
            readed := 0;
          end;
        end;
      end;

      // Логируем принятое
      if (AResponseLength <> Integer(readed)) then
        LogTransaction(AModule, @in_buff[0], readed, False, True)
      else
        LogTransaction(AModule, @in_buff[0], readed, False);

      // Проверяем длину
      if (AResponseLength > 0) and (readed = 0) then
      begin
        if stage = RetryCount then
        begin
          AModule.BadPackages := AModule.BadPackages + 1;
          AModule.ConnectIsOK := fdqBad;
          AModule.TimeOuts := AModule.TimeOuts + 1;
          AModule.ReceiveResponse();
          DoLog('Таймаут для ' + AModule.ModuleName);
        end;
        Continue;
      end;

      // Формируем ответ
      response := '';
      for i := 1 to readed do
        response := response + in_buff[i - 1];

      // Проверяем корректность
      if AModule.CheckResponse(ACommand, response) then
      begin
        AModule.TotalReceived := AModule.TotalReceived + 1;
        AModule.ReceiveResponse(ACommand, response);
        Result := True;
        if AModule.Debug then
           DoLog('Успешно: ' + AModule.ModuleName);
        Exit; // успех
      end
      else
      begin
        if stage = RetryCount then
        begin
          AModule.BadPackages := AModule.BadPackages + 1;
          AModule.ConnectIsOK := fdqBad;
          AModule.ReceiveResponse();
          DoLog('Ошибка CRC/ответа ' + AModule.ModuleName);
        end;
      end;
    end;

    // Если вышли из цикла – ошибка
    DoLog('Не удалось после ' + IntToStr(RetryCount) + ' попыток');
  finally
    FSendCommandCS.Leave;
  end;
end;

procedure TTransferWorker.Stop;
begin
  Terminate;
end;

function TTransferWorker.GetDebug: boolean;
begin
  if Assigned(FManager) then
     result:=TFmxModuleManager(FManager).Debug
  else
     result:=False;
end;

// === Информация о порте ===

function TTransferWorker.GetPortInfo: TComPortInfo;
begin
  FLock.Enter;
  try
    Result := FComPortInfo;
  finally
    FLock.Leave;
  end;
end;

function TTransferWorker.IsPortOpen: Boolean;
begin
  FLock.Enter;
  try
    Result := FComPortInfo.IsOpen;
  finally
    FLock.Leave;
  end;
end;

function TTransferWorker.GetPortNumber: Integer;
begin
  Result := FPortNumber;
end;

procedure TTransferWorker.UpdateLastUsed;
begin
  FLock.Enter;
  try
    FComPortInfo.LastUsed := Now;
  finally
    FLock.Leave;
  end;
end;

// ============================================================
//  TTransferManager
// ============================================================

constructor TTransferManager.Create(AModuleManager: TObject);
begin
  FModuleManager := AModuleManager;
  FWorkers := TList.Create;
  FLock := TCriticalSection.Create;
  FDefaultRetryCount := 10;
  FLogViewer := nil;
end;

destructor TTransferManager.Destroy;
begin
  StopAll;
  FWorkers.Free;
  FLock.Free;
  inherited;
end;

procedure TTransferManager.DoLog(const Msg: string);
begin
  if Assigned(FLogViewer) and Debug then
    FLogViewer(Msg, TAlphaColorRec.Black, []);
end;

function TTransferManager.FindWorker(Key: Integer): TTransferWorker;
var
  i: Integer;
  Item: PWorkerItem;
begin
  Result := nil;
  FLock.Enter;
  try
    for i := 0 to FWorkers.Count - 1 do
    begin
      Item := FWorkers[i];
      if Item^.Key = Key then
      begin
        Result := Item^.Worker;
        Break;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function TTransferManager.GetOrCreateWorker(AModule: TFmxModule): TTransferWorker;
var
  Key: Integer;
  UseTCP: Boolean;
  Host: string;
  Port: Word;
  Item: PWorkerItem;
begin
  Key := AModule.PortNumber;
  UseTCP := (AModule.Protocol = tpModbusTCP);

  if UseTCP then
  begin
    Key := 0;  // для TCP используем ключ 0
    Host := AModule.Info.PortDomen;
    Port := AModule.Info.PortNumber;
    if Port = 0 then
      Port := 502;
  end;

  Result := FindWorker(Key);
  if Assigned(Result) then
  begin
    Result.UpdateLastUsed;
    Exit;
  end;

  // Создаём нового воркера
  Result := TTransferWorker.Create(FModuleManager, Key, UseTCP, Host, Port);
  New(Item);
  Item^.Key := Key;
  Item^.Worker := Result;
  FLock.Enter;
  try
    FWorkers.Add(Item);
  finally
    FLock.Leave;
  end;

  DoLog('Создан воркер для порта ' + IntToStr(Key));
end;

function TTransferManager.SendCommand(AModule: TFmxModule; const ACommand: ShortString;
  AResponseLength: Integer; ATerminator: ansiChar): Boolean;
var
  Worker: TTransferWorker;
begin
  Result := False;
  if not Assigned(AModule) then Exit;

  Worker := GetOrCreateWorker(AModule);
  if not Assigned(Worker) then Exit;

  // Синхронный вызов
  Result := Worker.SendCommand(AModule, ACommand, AResponseLength, ATerminator);
end;

procedure TTransferManager.StopAll;
var
  i: Integer;
  Item: PWorkerItem;
begin
  FLock.Enter;
  try
    for i := 0 to FWorkers.Count - 1 do
    begin
      Item := FWorkers[i];
      Item^.Worker.Stop;
      Item^.Worker.WaitFor;
      Item^.Worker.Free;
      Dispose(Item);
    end;
    FWorkers.Clear;
    DoLog('Все воркеры остановлены');
  finally
    FLock.Leave;
  end;
end;

// === Новые методы для доступа к информации о портах ===

function TTransferManager.GetPortInfoByNumber(PortNumber: Integer; out PortInfo: TComPortInfo): Boolean;
var
  Worker: TTransferWorker;
begin
  Result := False;
  Worker := FindWorker(PortNumber);
  if Assigned(Worker) then
  begin
    PortInfo := Worker.GetPortInfo;
    Result := True;
  end;
end;

function TTransferManager.GetPortInfoByIndex(Index: Integer; out PortInfo: TComPortInfo): Boolean;
var
  i: Integer;
  Item: PWorkerItem;
  CurrentIndex: Integer;
begin
  Result := False;
  CurrentIndex := 0;

  FLock.Enter;
  try
    for i := 0 to FWorkers.Count - 1 do
    begin
      Item := FWorkers[i];
      if CurrentIndex = Index then
      begin
        PortInfo := Item^.Worker.GetPortInfo;
        Result := True;
        Exit;
      end;
      Inc(CurrentIndex);
    end;
  finally
    FLock.Leave;
  end;
end;

function TTransferManager.GetDebug: boolean;
begin
  if Assigned(FModuleManager) then
     result:=TFmxModuleManager(FModuleManager).Debug
  else
     result:=False;
end;

function TTransferManager.GetOpenPortsCount: Integer;
var
  i: Integer;
  Item: PWorkerItem;
begin
  Result := 0;
  FLock.Enter;
  try
    for i := 0 to FWorkers.Count - 1 do
    begin
      Item := FWorkers[i];
      if Item^.Worker.IsPortOpen then
        Inc(Result);
    end;
  finally
    FLock.Leave;
  end;
end;

function TTransferManager.GetOpenPortsList: TList<Integer>;
var
  i: Integer;
  Item: PWorkerItem;
begin
  Result := TList<Integer>.Create;
  FLock.Enter;
  try
    for i := 0 to FWorkers.Count - 1 do
    begin
      Item := FWorkers[i];
      if Item^.Worker.IsPortOpen then
        Result.Add(Item^.Key);
    end;
  finally
    FLock.Leave;
  end;
end;

function TTransferManager.IsPortOpen(PortNumber: Integer): Boolean;
var
  Worker: TTransferWorker;
begin
  Worker := FindWorker(PortNumber);
  Result := Assigned(Worker) and Worker.IsPortOpen;
end;

procedure TTransferManager.UpdatePortLastUsed(PortNumber: Integer);
var
  Worker: TTransferWorker;
begin
  Worker := FindWorker(PortNumber);
  if Assigned(Worker) then
    Worker.UpdateLastUsed;
end;

procedure TTransferManager.CloseAllPorts;
var
  i: Integer;
  Item: PWorkerItem;
begin
  FLock.Enter;
  try
    for i := 0 to FWorkers.Count - 1 do
    begin
      Item := FWorkers[i];
      Item^.Worker.ClosePort;
    end;
    DoLog('Все порты закрыты');
  finally
    FLock.Leave;
  end;
end;

procedure TTransferManager.ClosePort(PortNumber: Integer);
var
  Worker: TTransferWorker;
begin
  Worker := FindWorker(PortNumber);
  if Assigned(Worker) then
  begin
    Worker.ClosePort;
    DoLog('Порт ' + IntToStr(PortNumber) + ' закрыт');
  end;
end;

procedure TTransferManager.CleanupUnusedPorts(TimeoutMinutes: Integer);
var
  i: Integer;
  Item: PWorkerItem;
  PortInfo: TComPortInfo;
  CurrentTime: TDateTime;
  ClosedCount: Integer;
  WorkersToRemove: TList<Integer>;
begin
  ClosedCount := 0;
  CurrentTime := Now;
  WorkersToRemove := TList<Integer>.Create;

  try
    FLock.Enter;
    try
      for i := 0 to FWorkers.Count - 1 do
      begin
        Item := FWorkers[i];
        PortInfo := Item^.Worker.GetPortInfo;

        if PortInfo.IsOpen and (MinutesBetween(CurrentTime, PortInfo.LastUsed) > TimeoutMinutes) then
        begin
          Item^.Worker.ClosePort;
          WorkersToRemove.Add(i);
          Inc(ClosedCount);
          DoLog('Автоматически закрыт неиспользуемый порт ' + IntToStr(Item^.Key));
        end;
      end;

      // Удаляем закрытые воркеры (если они больше не нужны)
      // Но не удаляем полностью, т.к. они могут понадобиться снова
      // Просто закрываем порты, воркеры остаются в списке

    finally
      FLock.Leave;
    end;

    if ClosedCount > 0 then
      DoLog('Автоматически закрыто портов: ' + IntToStr(ClosedCount));

  finally
    WorkersToRemove.Free;
  end;
end;

function TTransferManager.GetPortsStatusString: string;
var
  i: Integer;
  Item: PWorkerItem;
  PortInfo: TComPortInfo;
  PortsList: TStringList;
begin
  Result := '';
  PortsList := TStringList.Create;
  try
    FLock.Enter;
    try
      for i := 0 to FWorkers.Count - 1 do
      begin
        Item := FWorkers[i];
        PortInfo := Item^.Worker.GetPortInfo;

        if PortInfo.IsOpen then
          PortsList.Add('COM' + IntToStr(Item^.Key) + '(' + IntToStr(PortInfo.BaudRate) + ')')
        else
          PortsList.Add('COM' + IntToStr(Item^.Key) + '(закрыт)');
      end;
    finally
      FLock.Leave;
    end;

    if PortsList.Count > 0 then
      Result := 'COM[' + PortsList.DelimitedText + ']'
    else
      Result := 'Порты не открыты';

  finally
    PortsList.Free;
  end;
end;

procedure TTransferManager.SetLogViewer(ALogViewer: TLogViewerAddMessage);
begin
  FLogViewer := ALogViewer;
end;

end.
