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

  TObservableObject = class
  private
    FObservers: TList<IEventObserver>;
    FObserversLock: TObject;
    FIsDestroying: Boolean;
    FEvent: Integer;
    FLastError: TErrorInfo;
  protected
    procedure Notify(Event: Integer; Data: TObject = nil); overload;
    procedure Notify(AEvent: ENotifyEvent; Data: TObject = nil); overload;
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
  protected
    procedure DoFireEvent(AEvent: Integer; const AError: TErrorInfo); virtual;
  end;

implementation

constructor TObservableObject.Create;
begin
  inherited Create;
  FObservers := TList<IEventObserver>.Create;
  FObserversLock := TObject.Create;
  FEvent := 0;
  FLastError := TErrorInfo.Empty(0);
end;

destructor TObservableObject.Destroy;
var
  LocalObservers: TArray<IEventObserver>;
begin
  FIsDestroying := True;

  if FObserversLock <> nil then
  begin
    TMonitor.Enter(FObserversLock);
    try
      if FObservers <> nil then
      begin
        // делаем копию и обнуляем список
       // LocalObservers := FObservers.ToArray;
      //  FObservers.Clear;
      end;
    finally
      TMonitor.Exit(FObserversLock);
    end;
  end;

  // ВАЖНО: освобождение вне lock
  // и без доступа к FObservers
 // SetLength(LocalObservers, 0);

  //FreeAndNil(FObservers);
  //FreeAndNil(FObserversLock);

  inherited Destroy;
end;

procedure TObservableObject.Subscribe(const AObserver: IEventObserver);
begin
  if (AObserver = nil) or (FObservers = nil) then
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
  if (AObserver = nil) or (FObservers = nil) then
    Exit;

    if (FObserversLock= nil) then
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
  if FObservers = nil then
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
    if FIsDestroying then
    Exit;

  if FObservers = nil then
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
  Notify(notifyEvent, Self);
end;

end.
