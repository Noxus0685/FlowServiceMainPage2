unit uAppServices;

interface

uses
  System.SysUtils,
  uDataManager,
  uDeviceClass,
  uRepositories,
  uMeterValue,
  uParameter,
  uProjectSettings,
  uProtocols,
  uFlowMeter,
{$IFDEF MSWINDOWS}
 WinAPI.Windows,
{$ENDIF}
  uWorkTable;

type
  TAppShutdownEvent = procedure(Sender: TObject) of object;

  TAppServices = class
  private
    FProjectFileName: string;

    FOwnsDataManager: Boolean;
    FOwnsProtocolManager: Boolean;
    FOwnsWorkTableManager: Boolean;

    FInitialized: Boolean;
    FOnBeforeShutdown: TAppShutdownEvent;
    FShutdownPrepared: Boolean;
    FShuttingDown: Boolean;

    FDataManager: TManagerTTableDM;
    FProtocolManager: TProtocolManager;
    FWorkTableManager: TWorkTableManager;

    function GetProtocolManager: TProtocolManager;
    function GetDataManager: TManagerTTableDM;
    function GetWorkTableManager: TWorkTableManager;

    function ResolveProjectFileName(const AProjectFileName: string): string;
    procedure LoadPersistentState;
    // Догружает только приборы, которые сохранены в каналах рабочих столов.
    procedure LoadWorkTableDeviceData;
    procedure ResetGlobalStatics;

  public
    constructor Create(const AProjectFileName: string = '');
    destructor Destroy; override;

    procedure Initialize(const AProjectFileName: string = '');
    procedure SaveAll;
    // Сохраняет состояние до уничтожения FMX-форм; повторный вызов безопасен.
    procedure PrepareForShutdown;
    procedure Shutdown;

    property WorkTableManager: TWorkTableManager read GetWorkTableManager;
    property DataManager: TManagerTTableDM read GetDataManager;
    property ProtocolManagerRef: TProtocolManager read GetProtocolManager;
    property Initialized: Boolean read FInitialized;
    property ProjectFileName: string read FProjectFileName;
    property OnBeforeShutdown: TAppShutdownEvent read FOnBeforeShutdown write FOnBeforeShutdown;
  end;

var
  AppServices: TAppServices;

implementation

{ TAppServices }

constructor TAppServices.Create(const AProjectFileName: string);
begin
  inherited Create;

  FProjectFileName := Trim(AProjectFileName);

  FOwnsDataManager := False;
  FOwnsProtocolManager := False;
  FOwnsWorkTableManager := False;

  FDataManager := nil;
  FProtocolManager := nil;
  FWorkTableManager := nil;

  FInitialized := False;
  FOnBeforeShutdown := nil;
  FShutdownPrepared := False;
  FShuttingDown := False;
end;

destructor TAppServices.Destroy;
begin
  Shutdown;
  inherited;
end;

function TAppServices.ResolveProjectFileName(
  const AProjectFileName: string): string;
begin
  if Trim(AProjectFileName) <> '' then
    Result := ExpandFileName(AProjectFileName)
  else if Trim(FProjectFileName) <> '' then
    Result := ExpandFileName(FProjectFileName)
  else
    raise EArgumentException.Create('Не задан выбранный файл проекта *.fpp');

  if not SameText(ExtractFileExt(Result), '.fpp') then
    raise EArgumentException.CreateFmt(
      'Файл проекта должен иметь расширение .fpp: %s', [Result]);
end;

function TAppServices.GetProtocolManager: TProtocolManager;
begin
  Result := FProtocolManager;
end;

function TAppServices.GetDataManager: TManagerTTableDM;
begin
  Result := FDataManager;
end;

function TAppServices.GetWorkTableManager: TWorkTableManager;
begin
  Result := FWorkTableManager;
end;

procedure TAppServices.LoadPersistentState;
begin
  TMeterValue.LoadFromStorage;
end;

procedure TAppServices.LoadWorkTableDeviceData;
var
  WorkTable: TWorkTable;
  Channel: TChannel;
  Repo: TDeviceRepository;
  Device: TDevice;

  procedure LoadChannel(AChannel: TChannel);
  begin
    if (AChannel = nil) or (Trim(AChannel.DeviceUUID) = '') then
      Exit;

    Repo := nil;
    Device := FDataManager.LoadDeviceRuntimeData(
      AChannel.DeviceUUID,
      AChannel.RepoDeviceName,
      Repo
    );
    if Device = nil then
      Exit;

    if AChannel.FlowMeter <> nil then
    begin
      AChannel.FlowMeter.Device := Device;
      AChannel.FlowMeter.RebindCalculatedValues;
    end;

    if Repo <> nil then
    begin
      AChannel.RepoDeviceName := Repo.Name;
      AChannel.RepoDeviceUUID := Repo.UUID;
    end;
  end;

begin
  if (FDataManager = nil) or (FWorkTableManager = nil) or
     (FWorkTableManager.WorkTables = nil) then
    Exit;

  for WorkTable in FWorkTableManager.WorkTables do
  begin
    if WorkTable = nil then
      Continue;

    for Channel in WorkTable.DeviceChannels do
      LoadChannel(Channel);

    for Channel in WorkTable.EtalonChannels do
      LoadChannel(Channel);
  end;
end;

procedure TAppServices.Initialize(const AProjectFileName: string);
var
  ProjectFileName: string;
begin
  {$IFDEF DEBUG}
  OutputDebugString(PChar('TAppServices.Initialize - НАЧАЛО:'+IntToStr(GetTickCount())));
  {$ENDIF}

  ProjectFileName := ResolveProjectFileName(AProjectFileName);

  if FInitialized then
  begin
    if SameText(FProjectFileName, ProjectFileName) then
      Exit;
    Shutdown;
  end;

  FProjectFileName := ProjectFileName;
  SetProjectSettingsFileName(FProjectFileName);

  // --- DataManager ---
  if FDataManager = nil then
  begin
    FDataManager := TManagerTTableDM.Create(FProjectFileName);
    uDataManager.DataManager := FDataManager;
    FOwnsDataManager := True;
  end;

  // --- ProtocolManager ---
  if FProtocolManager = nil then
  begin
    FProtocolManager := TProtocolManager.Create;
    uProtocols.ProtocolManager := FProtocolManager;
    FOwnsProtocolManager := True;
  end;

  FDataManager.Load;
  {$IFDEF DEBUG}
  OutputDebugString(PChar('TAppServices.Initialize - FDataManager.Load:'+IntToStr(GetTickCount())));
  {$ENDIF}
  LoadPersistentState;
  {$IFDEF DEBUG}
  OutputDebugString(PChar('TAppServices.Initialize - LoadPersistentState:'+IntToStr(GetTickCount())));
  {$ENDIF}

  // --- WorkTableManager ---
  if FWorkTableManager = nil then
  begin
    FWorkTableManager := TWorkTableManager.Create(FProjectFileName);
    uWorkTable.WorkTableManager := FWorkTableManager;
    FOwnsWorkTableManager := True;
  end;

  FWorkTableManager.Load;
  {$IFDEF DEBUG}
  OutputDebugString(PChar('TAppServices.Initialize - FWorkTableManager.Load:'+IntToStr(GetTickCount())));
  {$ENDIF}
  LoadWorkTableDeviceData;
  {$IFDEF DEBUG}
  OutputDebugString(PChar('TAppServices.Initialize - LoadWorkTableDeviceData:'+IntToStr(GetTickCount())));
  {$ENDIF}

  FShutdownPrepared := False;
  {$IFDEF DEBUG}
  OutputDebugString(PChar('TAppServices.Initialize - КОНЕЦ:'+IntToStr(GetTickCount())));
  {$ENDIF}
  FInitialized := True;
end;

procedure TAppServices.SaveAll;
begin
  if FWorkTableManager <> nil then
    FWorkTableManager.Save;

  if FDataManager <> nil then
    FDataManager.Save;

  TMeterValue.SaveToStorage;
end;

procedure TAppServices.PrepareForShutdown;
begin
  if not FInitialized or FShutdownPrepared then
    Exit;

  if Assigned(FOnBeforeShutdown) then
    FOnBeforeShutdown(Self);

  SaveAll;
  FShutdownPrepared := True;
end;

procedure TAppServices.ResetGlobalStatics;
begin
  FreeAndNil(TPump.Pumps);

  if TFlowMeter.FlowMeters <> nil then
    TFlowMeter.FlowMeters.Clear;

  if TFlowMeter.Etalons <> nil then
    TFlowMeter.Etalons.Clear;
end;

procedure TAppServices.Shutdown;
begin
  if not FInitialized then
    Exit;

  if FShuttingDown then
    Exit;

  PrepareForShutdown;

  FShuttingDown := True;
  try
    // --- WorkTableManager ---
    if FOwnsWorkTableManager and (FWorkTableManager <> nil) then
    begin
      if uWorkTable.WorkTableManager = FWorkTableManager then
        uWorkTable.WorkTableManager := nil;

      FreeAndNil(FWorkTableManager);
    end;

    // --- DataManager ---
    if FOwnsDataManager and (FDataManager <> nil) then
    begin
      if uDataManager.DataManager = FDataManager then
        uDataManager.DataManager := nil;

      FreeAndNil(FDataManager);
    end;

    // --- ProtocolManager ---
    if FOwnsProtocolManager and (FProtocolManager <> nil) then
    begin
      if uProtocols.ProtocolManager = FProtocolManager then
        uProtocols.ProtocolManager := nil;

      FreeAndNil(FProtocolManager);
    end;

    ResetGlobalStatics;
    SetProjectSettingsFileName('');

    FOwnsDataManager := False;
    FOwnsProtocolManager := False;
    FOwnsWorkTableManager := False;

    FOnBeforeShutdown := nil;
    FShutdownPrepared := False;
    FInitialized := False;
  finally
    FShuttingDown := False;
  end;
end;

initialization
  AppServices := nil;

finalization
  FreeAndNil(AppServices);

end.
