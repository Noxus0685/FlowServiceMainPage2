unit FmxBaseCommunicationManager;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  Classes,
  SysUtils,
  FmxFPModule,
  IdTCPClient,
  IdGlobal,
  System.SyncObjs;

type
  ICommunicationCallbacks = interface
    ['{C1A3B4D5-E6F7-4859-B8C9-D0E1F2A3B4C5}']
    function GetCOMPortNumber: Integer;
    procedure SetCOMPortNumber(Value: Integer);
    function GetCOMPortHandle: Cardinal;
    function GetTCPClient: TIdTCPClient;
    function GetDopTimOut: Integer;
    procedure AddToLog(Module: TFmxModule; Buffer: PByte; Length: Integer;
      Sended, Error: Boolean);
    procedure SetPortState(const State: string);
    function TCP_Client_Connected: Boolean;
    procedure ClosePort;
    procedure OpenPort;

    {$IFDEF MSWINDOWS}
    function GetDCB: TDCB;
    function GetCTO: TCommTimeouts;
    {$ENDIF}
  end;

  TTransactionState = (tsIdle, tsSending, tsWaitingResponse, tsProcessing, tsError);
  TPollingPriority = (ppLow, ppNormal, ppHigh, ppImmediate);

  TBaseCommunicationManager = class
  private
    FPortReady: Boolean;
    FPortLock: TCriticalSection;
    FCallbacks: ICommunicationCallbacks;

    // Методы для работы с COM-портом
    function SetupCOMPort(Module: TFmxModule): Boolean;
    function SetupTCPConnection(Module: TFmxModule): Boolean;
    function SendCOMPortRequest(Module: TFmxModule; const Request: ShortString): Boolean;
    function SendTCPRequest(Module: TFmxModule; const Request: ShortString): Boolean;
    function ReceiveCOMPortResponse(Module: TFmxModule; out Response: ShortString;
      ExpectedLength: Integer): Boolean;
    function ReceiveTCPResponse(Module: TFmxModule; out Response: ShortString;
      ExpectedLength: Integer): Boolean;
    function InternalReceiveResponse(Module: TFmxModule;
      out Response: ShortString; ExpectedLength: Integer): Boolean;
    function InternalSendRequest(Module: TFmxModule;
      const Request: ShortString): Boolean;

  public
    constructor Create(Callbacks: ICommunicationCallbacks);
    destructor Destroy; override;
    function PrepareCommunicationChannel(Module: TFmxModule): Boolean;
    procedure ResetPortState;

    function ExecuteCommunication(Module: TFmxModule; const Request: ShortString;
      out Response: ShortString; ExpectedLength: Integer): Boolean;
    property PortReady: Boolean read FPortReady;
  end;

implementation

{ TBaseCommunicationManager }

constructor TBaseCommunicationManager.Create(Callbacks: ICommunicationCallbacks);
begin
  inherited Create;
  FCallbacks := Callbacks;
  FPortLock := TCriticalSection.Create;
end;

destructor TBaseCommunicationManager.Destroy;
begin
  FPortLock.Free;
  FCallbacks := nil;
  inherited;
end;

function TBaseCommunicationManager.ExecuteCommunication(Module: TFmxModule;
  const Request: ShortString; out Response: ShortString; ExpectedLength: Integer): Boolean;
begin
  Result := False;
  Response := '';

  if not Assigned(Module) then
  begin
    if Assigned(FCallbacks) then
      FCallbacks.SetPortState('Ошибка: Module не назначен');
    Exit;
  end;

 if not Assigned(FCallbacks) then
  begin
    // Нет способа сообщить об ошибке
    Exit;
  end;


  FPortLock.Enter;
  try
    FCallbacks.SetPortState('Начало подготовки канала для ' + Module.ModuleName);

// Подготовка канала связи
    case Module.Protocol of
      tpProprietary..tpModbusASCII:
      begin
        FCallbacks.SetPortState('Подготовка COM-порта...');
        FPortReady := SetupCOMPort(Module);
        FCallbacks.SetPortState('COM-порт готов: ' + BoolToStr(FPortReady, True));
      end;
      tpModbusTCP:
      begin
        FCallbacks.SetPortState('Подготовка TCP...');
        FPortReady := SetupTCPConnection(Module);
        FCallbacks.SetPortState('TCP готов: ' + BoolToStr(FPortReady, True));
      end;
    else
      FPortReady := False;
      FCallbacks.SetPortState('Неизвестный протокол');
    end;

    if not FPortReady then
    begin
      FCallbacks.SetPortState('Канал связи не готов');
      Exit;
    end;

    // Отправка запроса
    if not InternalSendRequest(Module, Request) then
    begin
      FCallbacks.SetPortState('Ошибка отправки запроса');
      Exit;
    end;

    // Прием ответа (если ожидается)
    if ExpectedLength > 0 then
    begin
      if not InternalReceiveResponse(Module, Response, ExpectedLength) then
      begin
        FCallbacks.SetPortState('Ошибка приема ответа');
        Exit;
      end;
    end;

    Result := True;

  finally
    FPortLock.Leave;
  end;
end;

function TBaseCommunicationManager.InternalSendRequest(Module: TFmxModule;
  const Request: ShortString): Boolean;
begin
  case Module.Protocol of
    tpProprietary..tpModbusASCII:
      Result := SendCOMPortRequest(Module, Request);
    tpModbusTCP:
      Result := SendTCPRequest(Module, Request);
  else
    Result := False;
  end;
end;

function TBaseCommunicationManager.InternalReceiveResponse(Module: TFmxModule;
  out Response: ShortString; ExpectedLength: Integer): Boolean;
begin
  case Module.Protocol of
    tpProprietary..tpModbusASCII:
      Result := ReceiveCOMPortResponse(Module, Response, ExpectedLength);
    tpModbusTCP:
      Result := ReceiveTCPResponse(Module, Response, ExpectedLength);
  else
    Result := False;
  end;
end;

function TBaseCommunicationManager.SetupCOMPort(Module: TFmxModule): Boolean;
begin
  Result := False;
  if not Assigned(FCallbacks) then Exit;

  try
    // Проверяем необходимость смены порта
    if Module.PortNumber <> FCallbacks.GetCOMPortNumber then
    begin
      FCallbacks.ClosePort;
      FCallbacks.SetCOMPortNumber(Module.PortNumber);
      FCallbacks.OpenPort;
    end;

    if FCallbacks.GetCOMPortHandle = INVALID_HANDLE_VALUE then
    begin
      FCallbacks.SetPortState('COM-порт не открыт');
      Exit;
    end;

    {$IFDEF MSWINDOWS}
    var DCB: TDCB := FCallbacks.GetDCB;
    var CTO: TCommTimeouts := FCallbacks.GetCTO;

    DCB.BaudRate := Module.BaudRate;
    DCB.Parity := Ord(Module.Parity);
    CTO.ReadTotalTimeoutConstant := Module.Timeout + FCallbacks.GetDopTimOut;

    Result := SetCommState(FCallbacks.GetCOMPortHandle, DCB) and
              SetCommTimeouts(FCallbacks.GetCOMPortHandle, CTO);

    if not Result then
      FCallbacks.SetPortState('Ошибка настройки параметров COM-порта');
    {$ELSE}
    Result := True;
    {$ENDIF}

  except
    on E: Exception do
    begin
      FCallbacks.SetPortState('Ошибка настройки COM-порта: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TBaseCommunicationManager.SendCOMPortRequest(Module: TFmxModule;
  const Request: ShortString): Boolean;
var
  OutputBuffer: array[0..255] of AnsiChar;
  Written: Cardinal;
  I: Integer;
begin
  Result := False;
  if not Assigned(FCallbacks) or (FCallbacks.GetCOMPortHandle = INVALID_HANDLE_VALUE) then
  begin
    FCallbacks.SetPortState('COM-порт недоступен для отправки');
    Exit;
  end;

  try
    // Подготавливаем буфер
    for I := 1 to Length(Request) do
      OutputBuffer[I - 1] := Request[I];

    {$IFDEF MSWINDOWS}
    // Логика отправки через COM-порт
    EscapeCommFunction(FCallbacks.GetCOMPortHandle, SETRTS);
    PurgeComm(FCallbacks.GetCOMPortHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);

    Result := WriteFile(FCallbacks.GetCOMPortHandle, OutputBuffer, Length(Request), Written, nil);

    if Result then
      FCallbacks.AddToLog(Module, @OutputBuffer[0], Length(Request), True, False)
    else
      FCallbacks.SetPortState('Ошибка WriteFile для COM-порта');
    {$ELSE}
    Result := True;
    {$ENDIF}

  except
    on E: Exception do
    begin
      FCallbacks.SetPortState('Ошибка отправки COM-запроса: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TBaseCommunicationManager.ReceiveCOMPortResponse(Module: TFmxModule;
  out Response: ShortString; ExpectedLength: Integer): Boolean;
var
  InBuffer: array[0..255] of AnsiChar;
  Readed: Cardinal;
  I: Integer;
begin
  Result := False;
  Response := '';
  if not Assigned(FCallbacks) or (FCallbacks.GetCOMPortHandle = INVALID_HANDLE_VALUE) then
  begin
    FCallbacks.SetPortState('COM-порт недоступен для приема');
    Exit;
  end;

  try
    {$IFDEF MSWINDOWS}
    Result := ReadFile(FCallbacks.GetCOMPortHandle, InBuffer, ExpectedLength, Readed, nil);

    if Result then
    begin
      for I := 1 to Readed do
        Response := Response + InBuffer[I - 1];

      FCallbacks.AddToLog(Module, @InBuffer[0], Readed, False, Readed <> ExpectedLength);
    end
    else
    begin
      FCallbacks.SetPortState('Ошибка ReadFile для COM-порта');
    end;
    {$ELSE}
    Result := True;
    {$ENDIF}

  except
    on E: Exception do
    begin
      FCallbacks.SetPortState('Ошибка приема COM-ответа: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TBaseCommunicationManager.SetupTCPConnection(Module: TFmxModule): Boolean;
begin
  Result := False;
  if not Assigned(FCallbacks) then Exit;

  try
    Result := FCallbacks.TCP_Client_Connected;

    if not Result then
      FCallbacks.SetPortState('TCP-соединение не установлено');

  except
    on E: Exception do
    begin
      FCallbacks.SetPortState('Ошибка настройки TCP: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TBaseCommunicationManager.SendTCPRequest(Module: TFmxModule;
  const Request: ShortString): Boolean;
var
  OutputBuffer: array[0..255] of AnsiChar;
  OutputBytes: TIdBytes;
  I: Integer;
begin
  Result := False;
  if not Assigned(FCallbacks) or not Assigned(FCallbacks.GetTCPClient) then
  begin
    FCallbacks.SetPortState('TCP-клиент недоступен для отправки');
    Exit;
  end;

  try
    // Подготавливаем буфер
    for I := 1 to Length(Request) do
      OutputBuffer[I - 1] := Request[I];

    OutputBytes := RawToBytes(OutputBuffer, Length(Request));
    FCallbacks.GetTCPClient.Socket.Write(OutputBytes);

    Result := True;

    FCallbacks.AddToLog(Module, @OutputBuffer[0], Length(Request), True, False);

  except
    on E: Exception do
    begin
      FCallbacks.SetPortState('Ошибка отправки TCP-запроса: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TBaseCommunicationManager.ReceiveTCPResponse(Module: TFmxModule;
  out Response: ShortString; ExpectedLength: Integer): Boolean;
var
  InBuffer: array[0..255] of AnsiChar;
  InputBytes: TIdBytes;
  Readed: Integer;
  I: Integer;
begin
  Result := False;
  Response := '';
  if not Assigned(FCallbacks) or not Assigned(FCallbacks.GetTCPClient) then
  begin
    FCallbacks.SetPortState('TCP-клиент недоступен для приема');
    Exit;
  end;

  try
    FCallbacks.GetTCPClient.Socket.ReadBytes(InputBytes, -1);
    Readed := Length(InputBytes);

    for I := 0 to Readed - 1 do
      InBuffer[I] := AnsiChar(InputBytes[I]);

    for I := 1 to Readed do
      Response := Response + InBuffer[I - 1];

    Result := True;

    FCallbacks.AddToLog(Module, @InBuffer[0], Readed, False, Readed <> ExpectedLength);

  except
    on E: Exception do
    begin
      FCallbacks.SetPortState('Ошибка приема TCP-ответа: ' + E.Message);
      Result := False;
    end;
  end;
end;


// Реализация:
function TBaseCommunicationManager.PrepareCommunicationChannel(Module: TFmxModule): Boolean;
begin
  Result := False;
  if not Assigned(Module) or not Assigned(FCallbacks) then Exit;

  FPortLock.Enter;
  try
    case Module.Protocol of
      tpProprietary..tpModbusASCII:
        Result := SetupCOMPort(Module);
      tpModbusTCP:
        Result := SetupTCPConnection(Module);
    else
      Result := False;
    end;
  finally
    FPortLock.Leave;
  end;
end;

// Добавить метод для сброса состояния
procedure TBaseCommunicationManager.ResetPortState;
begin
  FPortLock.Enter;
  try
    FPortReady := False;
  finally
    FPortLock.Leave;
  end;
end;


end.
