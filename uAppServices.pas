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
  // Корневой объект приложения: композиция сервисов без "тяжёлого" DI.
  TAppServices = class
  private
    FBasePath: string;
    FOwnsDataManager: Boolean;
    FWorkTableManager: TWorkTableManager;
    FInitialized: Boolean;
    FDataManager: TManagerTTableDM;

    function GetProtocolManager: TProtocolManager;
    function BuildSettingsPath(const AFileName: string): string;
    procedure EnsureSettingsDirectory;
    procedure LoadPersistentState;
    procedure ResetGlobalStatics;
  public
    constructor Create(const ABasePath: string = '');
    destructor Destroy; override;

    // Полная инициализация прикладных сервисов:
    // 1) гарантируем каталог Settings;
    // 2) поднимаем DataManager + загружаем репозитории;
    // 3) загружаем сохранённые TMeterValue (до загрузки рабочих столов);
    // 4) создаём/загружаем WorkTableManager.
    procedure Initialize;

    // Централизованное сохранение состояния приложения:
    // - конфигурация рабочих столов;
    // - репозитории DataManager;
    // - все TMeterValue, отмеченные как IsToSave.
    procedure SaveAll;

    // Управляемое завершение приложения:
    // - безопасное единоразовое SaveAll;
    // - освобождение владений;
    // - очистка глобальных статических контейнеров.
    procedure Shutdown;

    property WorkTableManager: TWorkTableManager read FWorkTableManager;
    property DataManager: TManagerTTableDM read FDataManager;
    property ProtocolManagerRef: TProtocolManager read GetProtocolManager;
    property Initialized: Boolean read FInitialized;
  end;

var
  // Опциональная глобальная точка входа композиции (создаётся на верхнем уровне приложения).
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
  FWorkTableManager := nil;
  FInitialized := False;
end;

destructor TAppServices.Destroy;
begin
  // Важно: если вызывают Destroy напрямую, корректно завершаем жизненный цикл.
  Shutdown;

  inherited;
end;

function TAppServices.BuildSettingsPath(const AFileName: string): string;
begin
  Result := TPath.Combine(TPath.Combine(FBasePath, 'Settings'), AFileName);
end;

function TAppServices.GetProtocolManager: TProtocolManager;
begin
  Result := uProtocols.ProtocolManager;
end;

procedure TAppServices.EnsureSettingsDirectory;
begin
  ForceDirectories(TPath.Combine(FBasePath, 'Settings'));
end;

procedure TAppServices.LoadPersistentState;
begin
  // Восстанавливаем все сохранённые значения измерений заранее,
  // чтобы при загрузке рабочих столов/каналов ссылки на hash-значения
  // привязывались к уже существующим TMeterValue.
  TMeterValue.LoadFromFile;
end;

procedure TAppServices.Initialize;
begin
  if FInitialized then
    Exit;

  EnsureSettingsDirectory;

  if DataManager = nil then
  begin
    FDataManager := TManagerTTableDM.Create(BuildSettingsPath('dbsettings.ini'));
    FOwnsDataManager := True;
  end;

  DataManager.Load;
  LoadPersistentState;

  if FWorkTableManager = nil then
    FWorkTableManager := TWorkTableManager.Create(BuildSettingsPath('TableSettings.ini'));

  FWorkTableManager.Load;
  FInitialized := True;
end;

procedure TAppServices.SaveAll;
begin
  // В порядке "домен -> инфраструктура -> измерения":
  // 1) рабочие столы, 2) репозитории, 3) реестр измерений.
  if FWorkTableManager <> nil then
    FWorkTableManager.Save;

  if DataManager <> nil then
    DataManager.Save;

  TMeterValue.SaveToFile(0);
end;

procedure TAppServices.ResetGlobalStatics;
begin
  // Глобальный список насосов пересобирается менеджером рабочих столов.
  // На остановке очищаем и освобождаем явно, чтобы не оставлять "висячие" ссылки.
  FreeAndNil(TPump.Pumps);

  // Эти списки статические и освобождаются в finalization uFlowMeter.
  // Здесь выполняем мягкую очистку содержимого, чтобы после Shutdown
  // не было доступа к устаревшим экземплярам.
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

  FreeAndNil(FWorkTableManager);

  if FOwnsDataManager and (DataManager <> nil) then
    FreeAndNil(DataManager);

  ResetGlobalStatics;
  FOwnsDataManager := False;
  FInitialized := False;
end;

initialization
  AppServices := nil;

finalization
  FreeAndNil(AppServices);

end.
