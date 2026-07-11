unit uObservable;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  uBaseProcedures;

type
  ENotifyEvent = (
    notifyStateChanged = 1,  // Изменилось состояние
    notifyAction,             // Действие пользователя
    notifyEvent               // Событие которое произошло с объектом
  );

  IEventObserver = interface
    ['{7E95DA5C-E734-49FA-868D-4CF8CDFF24B0}']
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
  end;

  TActionNotification = class
  private
    FAction: Integer;
  public
    constructor Create(AAction: Integer);
    property Action: Integer read FAction;
  end;

  TEventNotification = class
  private
    FEvent: Integer;
  public
    constructor Create(AEvent: Integer);
    property Event: Integer read FEvent;
  end;

  TStateNotification = class
  private
    FOldState: Integer;
    FNewState: Integer;
  public
    constructor Create(AOldState: Integer; ANewState: Integer);
    property OldState: Integer read FOldState;
    property NewState: Integer read FNewState;
  end;

  TObservableObject = class
  private
    FObservers: TList<IEventObserver>;
    FObserversLock: TObject;
    FIsDestroying: Boolean;
    FEvent: Integer;
    FLastError: TErrorInfo;
    FName: string;
  protected
    procedure Notify(Event: Integer; Data: TObject = nil); overload;
    procedure Notify(AEvent: ENotifyEvent; Data: TObject = nil); overload;
    procedure NotifyOwned(Event: Integer; Data: TObject); overload;
    procedure NotifyOwned(AEvent: ENotifyEvent; Data: TObject); overload;
    procedure NotifySync(Event: Integer; Data: TObject = nil); overload;
    procedure NotifySync(AEvent: ENotifyEvent; Data: TObject = nil); overload;
    procedure NotifySyncOwned(Event: Integer; Data: TObject); overload;
    procedure NotifySyncOwned(AEvent: ENotifyEvent; Data: TObject); overload;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Subscribe(const AObserver: IEventObserver);
    procedure Unsubscribe(const AObserver: IEventObserver);
    function ObserverCount: Integer;
    procedure FireEvent(AEvent: Integer; const AError: TErrorInfo); overload; virtual;
    procedure FireEvent(AEvent: Integer); overload; virtual;
    property Event: Integer read FEvent write   FEvent;
    property LastError: TErrorInfo read FLastError;
    property Name: string read FName write FName;

  protected
    procedure DoFireEvent(AEvent: Integer; const AError: TErrorInfo); virtual;
  end;

implementation

constructor TActionNotification.Create(AAction: Integer);
begin
  inherited Create;
  FAction := AAction;
end;

constructor TEventNotification.Create(AEvent: Integer);
begin
  inherited Create;
  FEvent := AEvent;
end;

constructor TStateNotification.Create(AOldState: Integer; ANewState: Integer);
begin
  inherited Create;
  FOldState := AOldState;
  FNewState := ANewState;
end;

constructor TObservableObject.Create;
begin
  inherited Create;
  FObservers := TList<IEventObserver>.Create;
  FObserversLock := TObject.Create;
  FEvent := 0;
  FLastError := TErrorInfo.Empty(0);
end;

destructor TObservableObject.Destroy;
begin
  FIsDestroying := True;

  if FObserversLock <> nil then
  begin
    TMonitor.Enter(FObserversLock);
    try
      if FObservers <> nil then
        FObservers.Clear;
    finally
      TMonitor.Exit(FObserversLock);
    end;
  end;

  FreeAndNil(FObservers);
  FreeAndNil(FObserversLock);

  inherited Destroy;
end;

procedure TObservableObject.Subscribe(const AObserver: IEventObserver);
begin
  if AObserver = nil then
    Exit;

  if FIsDestroying or (FObserversLock = nil) or (FObservers = nil) then
    Exit;

  TMonitor.Enter(FObserversLock);
  try
    if FObservers.IndexOf(AObserver) < 0 then
      FObservers.Add(AObserver);
  finally
    TMonitor.Exit(FObserversLock);
  end;
end;

procedure TObservableObject.Unsubscribe(const AObserver: IEventObserver);
begin
  if AObserver = nil then
    Exit;

  if FIsDestroying or (FObserversLock = nil) or (FObservers = nil) then
    Exit;

  TMonitor.Enter(FObserversLock);
  try
    FObservers.Remove(AObserver);
  finally
    TMonitor.Exit(FObserversLock);
  end;
end;

function TObservableObject.ObserverCount: Integer;
begin
  if FIsDestroying or (FObserversLock = nil) or (FObservers = nil) then
    Exit(0);

  TMonitor.Enter(FObserversLock);
  try
    Result := FObservers.Count;
  finally
    TMonitor.Exit(FObserversLock);
  end;
end;

procedure TObservableObject.Notify(Event: Integer; Data: TObject);
var
  LocalObservers: TArray<IEventObserver>;
begin
  if FIsDestroying or (FObserversLock = nil) or (FObservers = nil) then
    Exit;

  TMonitor.Enter(FObserversLock);
  try
    LocalObservers := FObservers.ToArray;
  finally
    TMonitor.Exit(FObserversLock);
  end;

  TThread.Queue(nil,
    procedure
    var
      I: Integer;
      Observer: IEventObserver;
    begin
      for I := 0 to Length(LocalObservers) - 1 do
      begin
        Observer := LocalObservers[I];
        if Observer <> nil then
          Observer.OnNotify(Self, Event, Data);
       end;
    end);
end;

procedure TObservableObject.Notify(AEvent: ENotifyEvent; Data: TObject);
begin
  Notify(Ord(AEvent), Data);
end;

procedure TObservableObject.NotifyOwned(Event: Integer; Data: TObject);
var
  LocalObservers: TArray<IEventObserver>;
begin
  if Data = nil then
    Exit;

  if FIsDestroying or (FObserversLock = nil) or (FObservers = nil) then
  begin
    Data.Free;
    Exit;
  end;

  TMonitor.Enter(FObserversLock);
  try
    LocalObservers := FObservers.ToArray;
  finally
    TMonitor.Exit(FObserversLock);
  end;

  TThread.Queue(nil,
    procedure
    var
      I: Integer;
      Observer: IEventObserver;
    begin
      try
        for I := 0 to Length(LocalObservers) - 1 do
        begin
          Observer := LocalObservers[I];
          if Observer <> nil then
            Observer.OnNotify(Self, Event, Data);
        end;
      finally
        Data.Free;
      end;
    end);
end;

procedure TObservableObject.NotifyOwned(AEvent: ENotifyEvent; Data: TObject);
begin
  NotifyOwned(Ord(AEvent), Data);
end;

procedure TObservableObject.NotifySync(Event: Integer; Data: TObject);
var
  LocalObservers: TArray<IEventObserver>;
  I: Integer;
  Observer: IEventObserver;
begin
  if FIsDestroying or (FObserversLock = nil) or (FObservers = nil) then
    Exit;

  TMonitor.Enter(FObserversLock);
  try
    LocalObservers := FObservers.ToArray;
  finally
    TMonitor.Exit(FObserversLock);
  end;

  for I := 0 to Length(LocalObservers) - 1 do
  begin
    Observer := LocalObservers[I];
    if Observer <> nil then
      Observer.OnNotify(Self, Event, Data);
  end;
end;

procedure TObservableObject.NotifySync(AEvent: ENotifyEvent; Data: TObject);
begin
  NotifySync(Ord(AEvent), Data);
end;

procedure TObservableObject.NotifySyncOwned(Event: Integer; Data: TObject);
begin
  try
    NotifySync(Event, Data);
  finally
    Data.Free;
  end;
end;

procedure TObservableObject.NotifySyncOwned(AEvent: ENotifyEvent; Data: TObject);
begin
  NotifySyncOwned(Ord(AEvent), Data);
end;

procedure TObservableObject.FireEvent(AEvent: Integer; const AError: TErrorInfo);
begin
  FEvent := AEvent;
  FLastError := AError;
  DoFireEvent(AEvent, AError);
end;

procedure TObservableObject.FireEvent(AEvent: Integer);
begin
  FireEvent(AEvent, TErrorInfo.Empty(0));
end;

procedure TObservableObject.DoFireEvent(AEvent: Integer; const AError: TErrorInfo);
begin
  NotifyOwned(notifyEvent, TEventNotification.Create(AEvent));
end;

end.
