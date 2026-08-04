unit uProtocols;

interface

uses
  System.Classes,
  System.Generics.Collections,
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

  TProtocolManager = class(TObservableObject)
  private const
    CQueueCapacity = 10000;
  private
    FQueue: TThreadedQueue<TProtocolMessage>;
    FListeners: TList<TProtocolListener>;
    FListenersLock: TObject;
    FPaused: Boolean;
    FWorkerThread: TThread;
    FShuttingDown: Boolean;

    class function CategoryMarker(ACategory: EProtocolCategory): string; static;
    class function SourceMarker(ASource: TProtocolSource): string; static;

    procedure NotifyListeners(const Msg: TProtocolMessage);
    procedure StartWorker;
    procedure StopWorker;
    procedure WorkerProc;
    procedure FreeMessage(var Msg: TProtocolMessage);
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

    procedure Pause;
    procedure Resume;
    procedure Clear;

    class function FormatMessage(const Msg: TProtocolMessage): string; static;

    property Paused: Boolean read FPaused;
  end;

var
  ProtocolManager: TProtocolManager;

implementation

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
  FListeners := TList<TProtocolListener>.Create;
  FListenersLock := TObject.Create;
  FPaused := False;
  StartWorker;
end;

destructor TProtocolManager.Destroy;
begin
  FShuttingDown := True;
  StopWorker;
  Clear;
  TMonitor.Enter(FListenersLock);
  try
    FListeners.Clear;
  finally
    TMonitor.Exit(FListenersLock);
  end;
  FreeAndNil(FListeners);
  FreeAndNil(FListenersLock);
  FreeAndNil(FQueue);
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
  FWorkerThread := nil;
  if LThread = nil then
    Exit;

  LThread.Terminate;
  LThread.WaitFor;
  LThread.Free;
end;

procedure TProtocolManager.WorkerProc;
var
  Msg: TProtocolMessage;
  PopResult: TWaitResult;
begin
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
        NotifyListeners(Msg);
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
  if FShuttingDown or (FQueue = nil) then Exit;
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

procedure TProtocolManager.NotifyListeners(const Msg: TProtocolMessage);
var
  LocalListeners: TArray<TProtocolListener>;
  L: TProtocolListener;
  CopyMsg: TProtocolMessage;
begin
  if FShuttingDown or (Msg = nil) or (FListeners = nil) or
     (FListenersLock = nil) then
    Exit;

  TMonitor.Enter(FListenersLock);
  try
    LocalListeners := FListeners.ToArray;
  finally
    TMonitor.Exit(FListenersLock);
  end;

  for L in LocalListeners do
  begin
    if FShuttingDown then Exit;
    CopyMsg := Msg.Clone;
    TThread.Queue(nil,
      procedure
      begin
        try
          L(CopyMsg);
        finally
          CopyMsg.Free;
        end;
      end);
  end;
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
  if FQueue = nil then Exit;
  while FQueue.QueueSize > 0 do
    if FQueue.PopItem(Msg) = wrSignaled then
      FreeMessage(Msg);

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
