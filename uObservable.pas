unit uObservable;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  IEventObserver = interface
    ['{7E95DA5C-E734-49FA-868D-4CF8CDFF24B0}']
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
  end;

  TObservableObject = class
  private
    FObservers: TList<IEventObserver>;
    FObserversLock: TObject;
  protected
    procedure Notify(Event: Integer; Data: TObject = nil);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Subscribe(const AObserver: IEventObserver);
    procedure Unsubscribe(const AObserver: IEventObserver);
    function ObserverCount: Integer;
  end;

implementation

constructor TObservableObject.Create;
begin
  inherited Create;
  FObservers := TList<IEventObserver>.Create;
  FObserversLock := TObject.Create;
end;

destructor TObservableObject.Destroy;
begin
  TMonitor.Enter(FObserversLock);
  try
    if FObservers <> nil then
      FObservers.Clear;
  finally
    TMonitor.Exit(FObserversLock);
  end;

  FreeAndNil(FObservers);
  FreeAndNil(FObserversLock);
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

end.
