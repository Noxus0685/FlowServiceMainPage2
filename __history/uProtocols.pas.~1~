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

  EProtocolCategory = (
    pcNone,
    pcEvent,
    pcState,
    pcAction,
    pcMKS,
    pcInfo,
    pcWarning,
    pcError
  );

  TProtocolSource = (
    psUnknown,
    psForm,
    psParameters,
    psWorkTable,
    psMeasurement
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
  FQueue := TThreadedQueue<TProtocolMessage>.Create(CQueueCapacity, 50, 50);
  FListeners := TList<TProtocolListener>.Create;
  FListenersLock := TObject.Create;
  FPaused := False;
  StartWorker;
end;

destructor TProtocolManager.Destroy;
begin
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
  Msg := TProtocolMessage.Create;
  Msg.TimeStamp := Now;
  Msg.Category := ACategory;
  Msg.Source := ASource;
  Msg.Name := AName;
  Msg.Description := ADescription;
  Msg.Params := AParams;

  PushResult := FQueue.PushItem(Msg);
  if PushResult = wrTimeout then
  begin
    OldMsg := nil;
    if FQueue.PopItem(OldMsg) = wrSignaled then
      FreeMessage(OldMsg);

    if FQueue.PushItem(Msg) <> wrSignaled then
      FreeMessage(Msg);
  end;

  Notify(Integer(pmeMessageQueued));
end;

procedure TProtocolManager.NotifyListeners(const Msg: TProtocolMessage);
var
  LocalListeners: TArray<TProtocolListener>;
  L: TProtocolListener;
  CopyMsg: TProtocolMessage;
begin
  if Msg = nil then
    Exit;

  TMonitor.Enter(FListenersLock);
  try
    LocalListeners := FListeners.ToArray;
  finally
    TMonitor.Exit(FListenersLock);
  end;

  for L in LocalListeners do
  begin
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
  if not Assigned(AListener) then
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
  if not Assigned(AListener) then
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
  FPaused := True;
  Notify(Integer(pmePaused));
end;

procedure TProtocolManager.Resume;
begin
  FPaused := False;
  Notify(Integer(pmeResumed));
end;

procedure TProtocolManager.Clear;
var
  Msg: TProtocolMessage;
begin
  Msg := nil;
  while FQueue.QueueSize > 0 do
    if FQueue.PopItem(Msg) = wrSignaled then
      FreeMessage(Msg);

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
  FreeAndNil(ProtocolManager);

end.
