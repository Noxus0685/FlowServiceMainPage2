unit uAppServices;

interface

uses
  System.SysUtils,
  System.IOUtils,
  uDataManager,
  uMeterValue,
  uParameter,
  uProtocols,
  uFlowMeter,
  uWorkTable;

type
  TAppServices = class
  private
    FBasePath: string;

    FOwnsDataManager: Boolean;
    FOwnsProtocolManager: Boolean;
    FOwnsWorkTableManager: Boolean;

    FInitialized: Boolean;

    FDataManager: TManagerTTableDM;
    FProtocolManager: TProtocolManager;
    FWorkTableManager: TWorkTableManager;

    function GetProtocolManager: TProtocolManager;
    function GetDataManager: TManagerTTableDM;
    function GetWorkTableManager: TWorkTableManager;

    function BuildSettingsPath(const AFileName: string): string;
    procedure EnsureSettingsDirectory;
    procedure LoadPersistentState;
    procedure ResetGlobalStatics;

  public
    constructor Create(const ABasePath: string = '');
    destructor Destroy; override;

    procedure Initialize;
    procedure SaveAll;
    procedure Shutdown;

    property WorkTableManager: TWorkTableManager read GetWorkTableManager;
    property DataManager: TManagerTTableDM read GetDataManager;
    property ProtocolManagerRef: TProtocolManager read GetProtocolManager;
    property Initialized: Boolean read FInitialized;
  end;

var
  AppServices: TAppServices;

implementation

{ TAppServices }

constructor TAppServices.Create(const ABasePath: string);
begin
  inherited Create;

  if Trim(ABasePath) = '' then
    FBasePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))
  else
    FBasePath := IncludeTrailingPathDelimiter(ABasePath);

  FOwnsDataManager := False;
  FOwnsProtocolManager := False;
  FOwnsWorkTableManager := False;

  FDataManager := nil;
  FProtocolManager := nil;
  FWorkTableManager := nil;

  FInitialized := False;
end;

destructor TAppServices.Destroy;
begin
  Shutdown;
  inherited;
end;

function TAppServices.BuildSettingsPath(const AFileName: string): string;
begin
  Result := TPath.Combine(TPath.Combine(FBasePath, 'Settings'), AFileName);
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

procedure TAppServices.EnsureSettingsDirectory;
begin
  ForceDirectories(TPath.Combine(FBasePath, 'Settings'));
end;

procedure TAppServices.LoadPersistentState;
begin
  TMeterValue.LoadFromFile;
end;

procedure TAppServices.Initialize;
begin
  if FInitialized then
    Exit;

  EnsureSettingsDirectory;

  // --- DataManager ---
  if FDataManager = nil then
  begin
    FDataManager := TManagerTTableDM.Create(BuildSettingsPath('dbsettings.ini'));
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
  LoadPersistentState;

  // --- WorkTableManager ---
  if FWorkTableManager = nil then
  begin
    FWorkTableManager := TWorkTableManager.Create(
      BuildSettingsPath('TableSettings.ini')
    );
    uWorkTable.WorkTableManager := FWorkTableManager;
    FOwnsWorkTableManager := True;
  end;

  FWorkTableManager.Load;

  FInitialized := True;
end;

procedure TAppServices.SaveAll;
begin
  if FWorkTableManager <> nil then
    FWorkTableManager.Save;

  if FDataManager <> nil then
    FDataManager.Save;

  TMeterValue.SaveToFile(0);
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

  SaveAll;

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

  FOwnsDataManager := False;
  FOwnsProtocolManager := False;
  FOwnsWorkTableManager := False;

  FInitialized := False;
end;

initialization
  AppServices := nil;

finalization
  FreeAndNil(AppServices);

end.
