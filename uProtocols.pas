unit uProtocols;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Diagnostics,
  System.SyncObjs,
  System.SysUtils,
  uObservable;

type
  TProtocolManagerEvent = (
    pmeMessageQueued,
    pmePaused,
    pmeResumed,
    pmeCleared
  );

  {
    Категории сообщений протокола.

    Категория определяет назначение сообщения, его предполагаемого получателя
    и допустимый уровень технической детализации.
  }
  EProtocolCategory = (
    {
      Временное локальное сообщение.

      Используется при разработке для временных пояснений, проверок и локальной
      диагностики, когда сообщение ещё не отнесено к постоянной категории.

      Сообщения этой категории не должны использоваться для постоянного
      протоколирования работы программы. После завершения отладки их следует
      удалить либо перенести в подходящую категорию.
    }
    pcNone,

    {
      Системная диагностика работы процедур и методов.

      Используется для регистрации входа в процедуру, этапов её выполнения,
      значений параметров, промежуточных результатов, выполненных проверок
      и причин принятия внутренних решений.

      Предназначена для разработчиков и технической диагностики. Сообщения
      могут содержать имена методов, полей, объектов и другие технические данные.
    }
    pcProc,

    {
      Событие программы.

      Используется для регистрации каждого события, возникающего в объектах
      и подсистемах программы.

      Сообщение рекомендуется публиковать для каждого события независимо от
      того, привело оно к изменению состояния или выполнению действия либо нет.

      Желательно указывать источник, тип или код события и переданные данные.
    }
    pcEvent,

    {
      Изменение состояния.

      Используется для регистрации каждого фактического изменения состояния
      объекта, процедуры или подсистемы.

      Сообщение должно по возможности содержать предыдущее состояние, новое
      состояние и причину перехода. Простое повторное назначение уже установленного
      состояния не считается новым изменением состояния.
    }
    pcState,

    {
      Действие или команда.

      Используется для регистрации каждого возникающего или выполняемого действия:
      команды пользователя, команды управления оборудованием, внутренней команды
      программы либо вызова операции объекта.

      Желательно указывать инициатора действия, объект выполнения, само действие
      и результат его выполнения, если он уже известен.
    }
    pcAction,

    {
      Специализированные сообщения МКС.

      Категория зарезервирована для сообщений и диагностической информации,
      используемых Максимом. Не следует применять её для общих системных
      или пользовательских сообщений.
    }
    pcMKS,

    {
      Важная информация для пользователя.

      Используется для сообщений о значимых результатах и ходе работы программы,
      которые необходимо показать пользователю.

      Сообщение должно быть изложено простым и понятным языком, без имён внутренних
      методов, полей, кодов состояний и лишних диагностических подробностей.
      Следует публиковать только действительно важную для пользователя информацию.
    }
    pcInfo,

    {
      Предупреждение для пользователя.

      Используется для важных некритических проблем, отклонений или условий,
      которые требуют внимания пользователя, но не делают дальнейшую работу
      программы полностью невозможной.

      Сообщение должно быть понятным пользователю, кратко описывать проблему
      и, по возможности, указывать необходимое действие. Внутренняя системная
      диагностика должна публиковаться отдельно в технической категории.
    }
    pcWarning,

    {
      Критическая ошибка для пользователя.

      Используется для ошибок, из-за которых операция не может быть продолжена,
      результат не может быть получен либо требуется обязательное вмешательство
      пользователя.

      Сообщение должно понятным языком объяснять, что произошло, какая операция
      не выполнена и что пользователь может сделать. Технические подробности,
      имена методов и значения внутренних переменных следует публиковать отдельно
      через системные категории протокола.
    }
    pcError,

    {
      Журнал работы основной процедуры.

      Используется для последовательной регистрации основных этапов рабочего
      процесса: запуска, подготовки, выполнения операций, ожидания, завершения
      и полученных результатов.

      Категория должна отражать ход основной процедуры без чрезмерной внутренней
      детализации отдельных методов.
    }
    pcWorkLog,

    {
      Работа обработчиков.

      Используется для протоколирования обработчиков событий, уведомлений,
      изменений состояний и действий различных объектов, форм и фреймов.

      Позволяет отследить получение уведомления, выбор ветви обработки,
      выполненную реакцию и передачу управления другим объектам.
    }
    pcHandler
  );

  {
    Источники сообщений протокола.

    Источник определяет функциональную часть программы, в которой было
    сформировано сообщение. Категория описывает назначение сообщения,
    а источник — место его возникновения.
  }
  TProtocolSource = (
    {
      Источник сообщения не указан или не может быть определён.

      Допустимо использовать как значение по умолчанию. Для постоянных сообщений
      рекомендуется по возможности указывать конкретный источник.
    }
    psUnknown,

    {
      Формы и фреймы пользовательского интерфейса.

      Используется для сообщений, сформированных окнами, формами, фреймами
      и другими элементами интерфейса, включая обработку действий пользователя
      и обновление отображаемых данных.
    }
    psForm,

    {
      Параметры и настройки.

      Используется для сообщений, связанных с чтением, изменением, проверкой,
      сохранением и применением параметров программы, оборудования или измерения.
    }
    psParameters,

    {
      Рабочий стол.

      Используется для сообщений объекта рабочего стола и связанных с ним
      операций: управления оборудованием, каналами, расходом, температурой,
      давлением, текущей точкой и состоянием испытательной установки.
    }
    psWorkTable,

    {
      Процедура измерения.

      Используется для сообщений, формируемых алгоритмом проведения измерения:
      выбора точки, настройки установки, ожидания готовности и стабильности,
      запуска, выполнения, остановки и сохранения результатов измерения.
    }
    psMeasurement,

    {
      Основной модуль программы.

      Используется для сообщений главного исполнительного модуля, управляющего
      общим порядком работы программы и переходами между основными режимами
      и состояниями.
    }
    psEngine
  );

  TProtocolMessage = class
  public
    TimeStamp: TDateTime;
    Category: EProtocolCategory;
    Source: TProtocolSource;
    Name: string;
    Description: string;
    Params: string;
    function Clone: TProtocolMessage;
  end;

  TProtocolListener = reference to procedure(Msg: TProtocolMessage);
  TProtocolBatchListener = reference to procedure(
    const Messages: TArray<TProtocolMessage>);

  TProtocolMessageContent = record
    Description: string;
    Params: string;
  end;

  TProtocolManager = class(TObservableObject)
  private const
    CQueueCapacity = 10000;
    CRecentMessageCapacity = 10000;
  private
    FQueue: TThreadedQueue<TProtocolMessage>;
    FListeners: TList<TProtocolListener>;
    FBatchListeners: TList<TProtocolBatchListener>;
    FListenersLock: TObject;
    FRecentMessages: TDictionary<string, TProtocolMessageContent>;
    FRecentMessageKeys: TQueue<string>;
    FRecentMessagesLock: TCriticalSection;
    FPaused: Boolean;
    FWorkerThread: TThread;
    FShuttingDown: Boolean;
    { Atomic optimization switches; zero is the safe default. }
    FProtocolEnabled: Integer;
    FLogEnabled: Integer;
    FSampleChartEnabled: Integer;
    FStatisticsEnabled: Integer;
    { Prepared messages waiting for the single bounded UI callback. }
    FUiQueue: TThreadedQueue<TProtocolMessage>;
    FUiCallbackPending: Integer;

    class function CategoryMarker(ACategory: EProtocolCategory): string; static;
    class function SourceMarker(ASource: TProtocolSource): string; static;

    procedure QueueForUi(const Msg: TProtocolMessage);
    procedure ScheduleUiDelivery;
    procedure DeliverUiBatch;
    procedure StartWorker;
    procedure StopWorker;
    procedure WorkerProc;
    procedure FreeMessage(var Msg: TProtocolMessage);
    function ShouldPublishMessage(ACategory: EProtocolCategory;
      ASource: TProtocolSource; const AName, ADescription,
      AParams: string): Boolean;
    procedure ClearRecentMessages;
    function GetProtocolEnabled: Boolean;
    function GetLogEnabled: Boolean;
    function GetSampleChartEnabled: Boolean;
    function GetStatisticsEnabled: Boolean;
    procedure SetProtocolEnabled(const Value: Boolean);
    procedure SetLogEnabled(const Value: Boolean);
    procedure SetSampleChartEnabled(const Value: Boolean);
    procedure SetStatisticsEnabled(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddMessage(
      ACategory: EProtocolCategory;
      ASource: TProtocolSource;
      const AName, ADescription, AParams: string
    );

    procedure Subscribe(AListener: TProtocolListener); overload;
    procedure Unsubscribe(AListener: TProtocolListener); overload;
    procedure SubscribeBatch(AListener: TProtocolBatchListener);
    procedure UnsubscribeBatch(AListener: TProtocolBatchListener);
    procedure LoadSettings(const AFileName: string);
    procedure SaveSettings(const AFileName: string);

    procedure Pause;
    procedure Resume;
    procedure Clear;

    class function FormatMessage(const Msg: TProtocolMessage): string; static;

    property Paused: Boolean read FPaused;
    property ProtocolEnabled: Boolean read GetProtocolEnabled write SetProtocolEnabled;
    property LogEnabled: Boolean read GetLogEnabled write SetLogEnabled;
    property SampleChartEnabled: Boolean read GetSampleChartEnabled write SetSampleChartEnabled;
    property StatisticsEnabled: Boolean read GetStatisticsEnabled write SetStatisticsEnabled;
  end;

var
  ProtocolManager: TProtocolManager;

implementation

uses
  System.IniFiles,
  uProjectSettings;

procedure FinalizeProtocolManager;
var
  Manager: TProtocolManager;
begin
  Manager := ProtocolManager;
  ProtocolManager := nil;
  Manager.Free;
end;

{ TProtocolMessage }

function TProtocolMessage.Clone: TProtocolMessage;
begin
  Result := TProtocolMessage.Create;
  Result.TimeStamp := TimeStamp;
  Result.Category := Category;
  Result.Source := Source;
  Result.Name := Name;
  Result.Description := Description;
  Result.Params := Params;
end;

{ TProtocolManager }

constructor TProtocolManager.Create;
begin
  inherited;
  FShuttingDown := False;
  FQueue := TThreadedQueue<TProtocolMessage>.Create(CQueueCapacity, 50, 50);
  FUiQueue := TThreadedQueue<TProtocolMessage>.Create(CQueueCapacity, 0, 0);
  FListeners := TList<TProtocolListener>.Create;
  FBatchListeners := TList<TProtocolBatchListener>.Create;
  FListenersLock := TObject.Create;
  FRecentMessages := TDictionary<string, TProtocolMessageContent>.Create;
  FRecentMessageKeys := TQueue<string>.Create;
  FRecentMessagesLock := TCriticalSection.Create;
  FPaused := False;
  FProtocolEnabled := 0;
  FLogEnabled := 0;
  FSampleChartEnabled := 0;
  FStatisticsEnabled := 0;
  FUiCallbackPending := 0;
  StartWorker;
end;

destructor TProtocolManager.Destroy;
begin
  FShuttingDown := True;
  StopWorker;
  { Only callbacks owned by our worker are removed; unrelated UI work is intact. }
  if FWorkerThread <> nil then
    TThread.RemoveQueuedEvents(FWorkerThread);
  TInterlocked.Exchange(FUiCallbackPending, 0);
  Clear;
  TMonitor.Enter(FListenersLock);
  try
    FListeners.Clear;
    FBatchListeners.Clear;
  finally
    TMonitor.Exit(FListenersLock);
  end;
  FreeAndNil(FListeners);
  FreeAndNil(FBatchListeners);
  FreeAndNil(FListenersLock);
  FreeAndNil(FRecentMessages);
  FreeAndNil(FRecentMessageKeys);
  FreeAndNil(FRecentMessagesLock);
  FreeAndNil(FQueue);
  FreeAndNil(FUiQueue);
  inherited;
end;

procedure TProtocolManager.StartWorker;
begin
  if Assigned(FWorkerThread) then
    Exit;

  FWorkerThread := TThread.CreateAnonymousThread(
    procedure
    begin
      WorkerProc;
    end
  );
  FWorkerThread.FreeOnTerminate := False;
  FWorkerThread.Start;
end;

procedure TProtocolManager.StopWorker;
var
  LThread: TThread;
begin
  LThread := FWorkerThread;
  if LThread = nil then
    Exit;

  LThread.Terminate;
  LThread.WaitFor;
  TThread.RemoveQueuedEvents(LThread);
  FWorkerThread := nil;
  LThread.Free;
end;

procedure TProtocolManager.WorkerProc;
var
  Msg: TProtocolMessage;
  PopResult: TWaitResult;
begin
  TThread.NameThreadForDebugging('ProtocolThread');
  Msg := nil;
  while not TThread.CurrentThread.CheckTerminated do
  begin
    if FPaused then
    begin
      TThread.Sleep(30);
      Continue;
    end;

    if FShuttingDown or (FQueue = nil) then
      Break;
    PopResult := FQueue.PopItem(Msg);
    if PopResult = wrSignaled then
    begin
      try
        QueueForUi(Msg);
      finally
        FreeMessage(Msg);
      end;
    end;
  end;
end;

procedure TProtocolManager.FreeMessage(var Msg: TProtocolMessage);
begin
  FreeAndNil(Msg);
end;

procedure TProtocolManager.AddMessage(ACategory: EProtocolCategory;
  ASource: TProtocolSource; const AName, ADescription, AParams: string);
var
  Msg: TProtocolMessage;
  PushResult: TWaitResult;
  OldMsg: TProtocolMessage;
begin
  if FShuttingDown then Exit;
  if not ProtocolEnabled then Exit;
  if (FQueue = nil) then Exit;
  if not ShouldPublishMessage(ACategory, ASource, AName, ADescription,
    AParams) then
    Exit;

  Msg := TProtocolMessage.Create;
  try
    Msg.TimeStamp := Now;
    Msg.Category := ACategory;
    Msg.Source := ASource;
    Msg.Name := AName;
    Msg.Description := ADescription;
    Msg.Params := AParams;

    if FShuttingDown or (FQueue = nil) then Exit;
    PushResult := FQueue.PushItem(Msg);
    if PushResult = wrSignaled then
      Msg := nil
    else if (PushResult = wrTimeout) and not FShuttingDown and (FQueue <> nil) then
    begin
      OldMsg := nil;
      if FQueue.PopItem(OldMsg) = wrSignaled then
        FreeMessage(OldMsg);
      if not FShuttingDown and (FQueue <> nil) and
         (FQueue.PushItem(Msg) = wrSignaled) then
        Msg := nil;
    end;

    if not FShuttingDown then
      Notify(Integer(pmeMessageQueued));
  finally
    Msg.Free;
  end;
end;

function TProtocolManager.ShouldPublishMessage(ACategory: EProtocolCategory;
  ASource: TProtocolSource; const AName, ADescription,
  AParams: string): Boolean;
var
  Key, OldestKey: string;
  Content: TProtocolMessageContent;
begin
  Result := False;
  if FRecentMessagesLock = nil then
    Exit;

  Key := IntToStr(Ord(ACategory)) + ':' + IntToStr(Ord(ASource)) + ':' +
    IntToStr(Length(AName)) + ':' + AName;

  FRecentMessagesLock.Acquire;
  try
    if FShuttingDown or (FRecentMessages = nil) or
       (FRecentMessageKeys = nil) then
      Exit;

    if FRecentMessages.TryGetValue(Key, Content) then
    begin
      if (Content.Description = ADescription) and
         (Content.Params = AParams) then
        Exit;
    end
    else
    begin
      if FRecentMessages.Count >= CRecentMessageCapacity then
      begin
        OldestKey := FRecentMessageKeys.Dequeue;
        FRecentMessages.Remove(OldestKey);
      end;
      FRecentMessageKeys.Enqueue(Key);
    end;

    Content.Description := ADescription;
    Content.Params := AParams;
    FRecentMessages.AddOrSetValue(Key, Content);
    Result := True;
  finally
    FRecentMessagesLock.Release;
  end;
end;

procedure TProtocolManager.ClearRecentMessages;
begin
  if FRecentMessagesLock = nil then
    Exit;

  FRecentMessagesLock.Acquire;
  try
    if FRecentMessages <> nil then
      FRecentMessages.Clear;
    if FRecentMessageKeys <> nil then
      FRecentMessageKeys.Clear;
  finally
    FRecentMessagesLock.Release;
  end;
end;

procedure TProtocolManager.QueueForUi(const Msg: TProtocolMessage);
var
  CopyMsg: TProtocolMessage;
begin
  if FShuttingDown or not ProtocolEnabled or (Msg = nil) or (FUiQueue = nil) then Exit;
  CopyMsg := Msg.Clone;
  if FUiQueue.PushItem(CopyMsg) <> wrSignaled then
    CopyMsg.Free;
  ScheduleUiDelivery;
end;

procedure TProtocolManager.ScheduleUiDelivery;
begin
  if FShuttingDown or not ProtocolEnabled then Exit;
  if TInterlocked.CompareExchange(FUiCallbackPending, 1, 0) <> 0 then Exit;
  TThread.Queue(FWorkerThread,
    procedure
    begin
      DeliverUiBatch;
    end);
end;

procedure TProtocolManager.DeliverUiBatch;
var
  LocalListeners: TArray<TProtocolListener>;
  LocalBatchListeners: TArray<TProtocolBatchListener>;
  L: TProtocolListener;
  BL: TProtocolBatchListener;
  Msg: TProtocolMessage;
  Batch: TList<TProtocolMessage>;
  Started: Int64;
begin
  TInterlocked.Exchange(FUiCallbackPending, 0);
  if FShuttingDown or not ProtocolEnabled or (FUiQueue = nil) then Exit;
  Batch := TList<TProtocolMessage>.Create;
  try
    Started := TStopwatch.GetTimeStamp;
    Msg := nil;
    while (Batch.Count < 100) and
      ((TStopwatch.GetTimeStamp - Started) * 1000.0 /
       TStopwatch.Frequency < 10) and
      (FUiQueue.PopItem(Msg) = wrSignaled) do
      Batch.Add(Msg);
    if Batch.Count = 0 then Exit;

    TMonitor.Enter(FListenersLock);
    try
      LocalListeners := FListeners.ToArray;
      LocalBatchListeners := FBatchListeners.ToArray;
    finally
      TMonitor.Exit(FListenersLock);
    end;

    for BL in LocalBatchListeners do BL(Batch.ToArray);
    for Msg in Batch do
      for L in LocalListeners do L(Msg);
  finally
    for Msg in Batch do Msg.Free;
    Batch.Free;
  end;
  if (not FShuttingDown) and (FUiQueue.QueueSize > 0) then ScheduleUiDelivery;
end;

procedure TProtocolManager.Subscribe(AListener: TProtocolListener);
begin
  if FShuttingDown or not Assigned(AListener) or (FListeners = nil) or
     (FListenersLock = nil) then
    Exit;

  TMonitor.Enter(FListenersLock);
  try
    FListeners.Add(AListener);
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

procedure TProtocolManager.Unsubscribe(AListener: TProtocolListener);
begin
  if FShuttingDown or not Assigned(AListener) or (FListeners = nil) or
     (FListenersLock = nil) then
    Exit;

  TMonitor.Enter(FListenersLock);
  try
    FListeners.Remove(AListener);
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

procedure TProtocolManager.SubscribeBatch(AListener: TProtocolBatchListener);
begin
  if FShuttingDown or not Assigned(AListener) then Exit;
  TMonitor.Enter(FListenersLock);
  try FBatchListeners.Add(AListener); finally TMonitor.Exit(FListenersLock); end;
end;

procedure TProtocolManager.UnsubscribeBatch(AListener: TProtocolBatchListener);
begin
  if FShuttingDown or not Assigned(AListener) then Exit;
  TMonitor.Enter(FListenersLock);
  try FBatchListeners.Remove(AListener); finally TMonitor.Exit(FListenersLock); end;
end;

function TProtocolManager.GetProtocolEnabled: Boolean;
begin Result := TInterlocked.CompareExchange(FProtocolEnabled, 0, 0) <> 0; end;
function TProtocolManager.GetLogEnabled: Boolean;
begin Result := TInterlocked.CompareExchange(FLogEnabled, 0, 0) <> 0; end;
function TProtocolManager.GetSampleChartEnabled: Boolean;
begin Result := TInterlocked.CompareExchange(FSampleChartEnabled, 0, 0) <> 0; end;
function TProtocolManager.GetStatisticsEnabled: Boolean;
begin Result := TInterlocked.CompareExchange(FStatisticsEnabled, 0, 0) <> 0; end;

procedure TProtocolManager.SetProtocolEnabled(const Value: Boolean);
var Msg: TProtocolMessage;
begin
  if FShuttingDown then Exit;
  TInterlocked.Exchange(FProtocolEnabled, Ord(Value));
  if not Value then
  begin
    TInterlocked.Exchange(FUiCallbackPending, 0);
    if FWorkerThread <> nil then TThread.RemoveQueuedEvents(FWorkerThread);
    Msg := nil;
    if FUiQueue <> nil then
      while FUiQueue.QueueSize > 0 do
        if FUiQueue.PopItem(Msg) = wrSignaled then FreeMessage(Msg);
  end;
  Notify(Integer(pmeMessageQueued));
end;
procedure TProtocolManager.SetLogEnabled(const Value: Boolean);
begin if not FShuttingDown then begin TInterlocked.Exchange(FLogEnabled, Ord(Value)); Notify(Integer(pmeMessageQueued)); end; end;
procedure TProtocolManager.SetSampleChartEnabled(const Value: Boolean);
begin if not FShuttingDown then begin TInterlocked.Exchange(FSampleChartEnabled, Ord(Value)); Notify(Integer(pmeMessageQueued)); end; end;
procedure TProtocolManager.SetStatisticsEnabled(const Value: Boolean);
begin if not FShuttingDown then begin TInterlocked.Exchange(FStatisticsEnabled, Ord(Value)); Notify(Integer(pmeMessageQueued)); end; end;

procedure TProtocolManager.LoadSettings(const AFileName: string);
var Ini: TCustomIniFile;
  function ReadStrictBool(const Key: string): Boolean;
  var S: string;
  begin
    S := Trim(Ini.ReadString('Protocol', Key, ''));
    Result := SameText(S, '1') or SameText(S, 'True');
  end;
begin
  ProtocolEnabled := False; LogEnabled := False;
  SampleChartEnabled := False; StatisticsEnabled := False;
  if Trim(AFileName) = '' then Exit;
  Ini := TProjectSettingsIni.Create(AFileName, STORAGE_TABLE_SETTINGS);
  try
    ProtocolEnabled := ReadStrictBool('ProtocolEnabled');
    LogEnabled := ReadStrictBool('LogEnabled');
    SampleChartEnabled := ReadStrictBool('SampleChartEnabled');
    StatisticsEnabled := ReadStrictBool('StatisticsEnabled');
  finally Ini.Free; end;
end;

procedure TProtocolManager.SaveSettings(const AFileName: string);
var Ini: TCustomIniFile;
begin
  {
  if FShuttingDown or (Trim(AFileName) = '') then Exit;
  Ini := TProjectSettingsIni.Create(AFileName, STORAGE_TABLE_SETTINGS);
  try
    Ini.WriteInteger('Protocol', 'ProtocolEnabled', Ord(ProtocolEnabled));
    Ini.WriteInteger('Protocol', 'LogEnabled', Ord(LogEnabled));
    Ini.WriteInteger('Protocol', 'SampleChartEnabled', Ord(SampleChartEnabled));
    Ini.WriteInteger('Protocol', 'StatisticsEnabled', Ord(StatisticsEnabled));
  finally Ini.Free; end;   }
end;

procedure TProtocolManager.Pause;
begin
  if FShuttingDown then Exit;
  FPaused := True;
  Notify(Integer(pmePaused));
end;

procedure TProtocolManager.Resume;
begin
  if FShuttingDown then Exit;
  FPaused := False;
  Notify(Integer(pmeResumed));
end;

procedure TProtocolManager.Clear;
var
  Msg: TProtocolMessage;
begin
  Msg := nil;
  if FQueue <> nil then
    while FQueue.QueueSize > 0 do
      if FQueue.PopItem(Msg) = wrSignaled then
        FreeMessage(Msg);
  if FUiQueue <> nil then
    while FUiQueue.QueueSize > 0 do
      if FUiQueue.PopItem(Msg) = wrSignaled then
        FreeMessage(Msg);

  ClearRecentMessages;

  if not FShuttingDown then
    Notify(Integer(pmeCleared));
end;

class function TProtocolManager.CategoryMarker(
  ACategory: EProtocolCategory): string;
begin
  case ACategory of
    pcEvent: Result := 'EVENT';
    pcState: Result := 'STATE';
    pcAction: Result := 'ACTION';
    pcMKS: Result := 'MKS';
    pcInfo: Result := 'INFO';
    pcProc: Result := 'PROC';
    pcWorkLog: Result := 'WORKLOG';
    pcHandler: Result := 'HANDLER';
    pcWarning: Result := 'Warning!';
    pcError: Result := 'Error!';
  else
    Result := '';
  end;
end;

class function TProtocolManager.SourceMarker(ASource: TProtocolSource): string;
begin
  case ASource of
    psForm: Result := 'FRM';
    psParameters: Result := 'PAR';
    psWorkTable: Result := 'WT';
    psMeasurement: Result := 'MR';
    psEngine: Result := 'ENG';
  else
    Result := '';
  end;
end;

class function TProtocolManager.FormatMessage(const Msg: TProtocolMessage): string;
var
  Cat, Src: string;

  function SingleLine(const AText: string): string;
  begin
    Result := StringReplace(AText, sLineBreak, ' | ', [rfReplaceAll]);
    Result := StringReplace(Result, #13, ' | ', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ' | ', [rfReplaceAll]);
    Result := StringReplace(Result, #9, ' ', [rfReplaceAll]);
  end;
begin
  if Msg = nil then
    Exit('');

  Cat := CategoryMarker(Msg.Category);
  Src := SourceMarker(Msg.Source);
  Result := Format('[%s] %-8s %-3s | %-18s | %-28s | %s', [
    FormatDateTime('hh:nn:ss', Msg.TimeStamp),
    Cat,
    Src,
    SingleLine(Msg.Name),
    SingleLine(Msg.Description),
    SingleLine(Msg.Params)
  ]);
end;

initialization
  ProtocolManager := nil;

finalization
  FinalizeProtocolManager;

end.
