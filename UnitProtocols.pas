unit UnitProtocols;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections;

type
  TProtocolCategory = (
    pcNone,
    pcEvent,
    pcState,
    pcAction
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
    Category: TProtocolCategory;
    Source: TProtocolSource;
    Name: string;
    Description: string;
    Params: string;
    function Clone: TProtocolMessage;
  end;

  TProtocolListener = reference to procedure(Msg: TProtocolMessage);

  TProtocolManager = class
  private const
    CQueueCapacity = 10000;
  private
    FQueue: TThreadedQueue<TProtocolMessage>;
    FListeners: TList<TProtocolListener>;
    FListenersLock: TObject;
    FPaused: Boolean;
    FWorkerThread: TThread;

    class function CategoryMarker(ACategory: TProtocolCategory): string; static;
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
      ACategory: TProtocolCategory;
      ASource: TProtocolSource;
      const AName, ADescription, AParams: string
    );

    procedure Subscribe(AListener: TProtocolListener);
    procedure Unsubscribe(AListener: TProtocolListener);

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

procedure TProtocolManager.AddMessage(ACategory: TProtocolCategory;
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
end;

procedure TProtocolManager.Resume;
begin
  FPaused := False;
end;

procedure TProtocolManager.Clear;
var
  Msg: TProtocolMessage;
begin
  Msg := nil;
  while FQueue.QueueSize > 0 do
    if FQueue.PopItem(Msg) = wrSignaled then
    FreeMessage(Msg);
end;

class function TProtocolManager.CategoryMarker(
  ACategory: TProtocolCategory): string;
begin
  case ACategory of
    pcEvent: Result := 'EVENT';
    pcState: Result := 'STATE';
    pcAction: Result := 'ACTION';
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
  Cat, Src, Prefix: string;
begin
  if Msg = nil then
    Exit('');

  Cat := CategoryMarker(Msg.Category);
  Src := SourceMarker(Msg.Source);
  Prefix := Trim(Cat + ' ' + Src);

  if Prefix <> '' then
    Prefix := Prefix + ': ';

  Result := Format('[%s] %s%s - %s', [
    FormatDateTime('hh:nn:ss', Msg.TimeStamp),
    Prefix,
    Msg.Name,
    Msg.Description
  ]);

  if Trim(Msg.Params) <> '' then
    Result := Result + ' (' + Msg.Params + ')';
end;

initialization
  ProtocolManager := TProtocolManager.Create;

finalization
  FreeAndNil(ProtocolManager);

end.
