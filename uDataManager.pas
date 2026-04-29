unit uDataManager;

interface



uses
  FMX.TreeView,
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.IniFiles,
  System.IOUtils,
  System.SysUtils,
  uBaseProcedures,
  uClasses,
  uDeviceClass,
  uRepositories,
  uTable_DATA;

type

  TManagerTTableDM = class
  private

    FIniFileName: string;
    FDms: TObjectDictionary<string, TTableDM>;

    FRepositories: TObjectDictionary<string, TObject>;

    FTypeRepositories: TObjectList<TTypeRepository>;
    FActiveTypeRepo:  TTypeRepository;

    FDeviceRepositories: TObjectList<TDeviceRepository>;
    FActiveDeviceRepo:  TDeviceRepository;

    FCategories: TObjectList<TDeviceCategory>;
    FCopiedTypes: TObjectList<TDeviceType>;
    FCopiedDevices: TObjectList<TDevice>;
    FBufferTypesBusy: Boolean;
    FBufferDevicesBusy: Boolean;

    //Загрузка нужного репозитария  (rkType, rkDevice, rkResults);


    function CreateRepository(const AName: string; AKind: TRepositoryKind;ADM: TTableDM ): TBaseRepository;


    function CreateTypeRepository(const AName: string; ADM: TTableDM): TTypeRepository;
    function CreateDeviceRepository(const AName: string; ADM: TTableDM): TDeviceRepository;
    function MakeUniqueRepositoryName(const ABaseName: string): string;
    function NormalizeRepositoryDbFileName(AKind: TRepositoryKind; const ADbFile: string): string;
    function GetBufferTypes: TList<TDeviceType>;
    procedure SetBufferTypes(const ATypes: TList<TDeviceType>);
    function GetBufferDevices: TList<TDevice>;
    procedure SetBufferDevices(const ADevices: TList<TDevice>);

  public

  BufferType: TDeviceType;
  BufferDevice: TDevice;

  constructor Create(const AIniFileName: string);
  destructor Destroy; override;

  procedure Save;
  procedure Load;

  procedure BuildRepositories(AKind: TRepositoryKind);
  procedure LoadRepositories(AKind: TRepositoryKind);


  property ActiveTypeRepo: TTypeRepository read FActiveTypeRepo write FActiveTypeRepo;
  property TypeRepositories: TObjectList<TTypeRepository> read FTypeRepositories write  FTypeRepositories;


  property ActiveDeviceRepo: TDeviceRepository read FActiveDeviceRepo write FActiveDeviceRepo;
  property DeviceRepositories: TObjectList<TDeviceRepository> read FDeviceRepositories;
  // Буфер копирования типов. Чтение возвращает новые клоны из внутреннего буфера.
  property BufferTypes: TList<TDeviceType> read GetBufferTypes write SetBufferTypes;
  // Буфер копирования приборов. Чтение возвращает ссылки только для просмотра.
  property BufferDevices: TList<TDevice> read GetBufferDevices write SetBufferDevices;

  procedure AddRepository(const AName: string; AKind: TRepositoryKind; const ADbFile: string);
  procedure RemoveRepository(const AName: string);

  procedure SetActiveRepository(AKind: TRepositoryKind; const AName: string);
  procedure SetActiveTypeRepository(const AName: string);
  procedure SetActiveDeviceRepository(const AName: string);

  function GetRepository(const AName: string): TObject;
  procedure CloseAll;

  function FindCategoryByID(AID: Integer): TDeviceCategory;
  function Categories : TObjectList<TDeviceCategory>;

  function FindType(const AUUID, AName: string; out ARepo: TTypeRepository): TDeviceType;
  function FindDevice(const AUUID: string; out ARepo: TDeviceRepository): TDevice;
  function FindTypeRepositoryByName(const AName: string): TTypeRepository;
  function FindDeviceRepositoryByName(const AName: string): TDeviceRepository;
  // Копирование списка типов во внутренний буфер через Clone.
  procedure CopyTypesToBuffer(const ATypes: TList<TDeviceType>);
  // Вставка типов из буфера в активный репозиторий с созданием новых экземпляров.
  function PasteBufferTypes: TObjectList<TDeviceType>;
  // Вырезание: копирование в буфер и удаление из активного репозитория.
  procedure CutTypesToBuffer(const ATypes: TList<TDeviceType>);
  // Проверка наличия данных в буфере типов.
  function HasBufferTypes: Boolean;
  // Копирование списка приборов во внутренний буфер через Clone.
  procedure CopyDevicesToBuffer(const ADevices: TList<TDevice>);
  // Вставка приборов из буфера в активный репозиторий с созданием новых экземпляров.
  function PasteBufferDevices: TObjectList<TDevice>;
  // Вырезание приборов: копирование в буфер и удаление из активного репозитория.
  procedure CutDevicesToBuffer(const ADevices: TList<TDevice>);
  // Проверка наличия данных в буфере приборов.
  function HasBufferDevices: Boolean;
  // Назначение полей прибора по выбранной ветке дерева.
  procedure AssignDeviceTreeFields(const ADevice: TDevice; const ANode: TTreeViewItem);
  // Назначение полей типа по выбранной ветке дерева.
  procedure AssignTypeTreeFields(const AType: TDeviceType; const ANode: TTreeViewItem);

  end;

  var  DataManager:  TManagerTTableDM;

implementation


{==== TManagerTTableDM ==================================}
constructor TManagerTTableDM.Create(const AIniFileName: string);
begin
  inherited Create;

  {--------------------------------------------------}
  { Имя ini-файла }
  {--------------------------------------------------}
  FIniFileName := AIniFileName;

  {--------------------------------------------------}
  { Контейнеры DataModule }
  {--------------------------------------------------}
  FDms := TObjectDictionary<string, TTableDM>.Create([doOwnsValues]);

  {--------------------------------------------------}
  { Общий контейнер репозиториев (если нужен) }
  {--------------------------------------------------}
  FRepositories := TObjectDictionary<string, TObject>.Create([doOwnsValues]);

  {--------------------------------------------------}
  { Репозитории типов }
  {--------------------------------------------------}
  FTypeRepositories := TObjectList<TTypeRepository>.Create(False);
  FActiveTypeRepo := nil;

  {--------------------------------------------------}
  { Репозитории приборов }
  {--------------------------------------------------}
  FDeviceRepositories := TObjectList<TDeviceRepository>.Create(False);
  FActiveDeviceRepo := nil;
  FCopiedTypes := TObjectList<TDeviceType>.Create(True);
  FCopiedDevices := TObjectList<TDevice>.Create(True);

  {--------------------------------------------------}
  { Репозитории результатов }
  {--------------------------------------------------}

 // FResultsRepositories := TObjectList<TResultRepository>.Create(False);
 // FActiveResultsRepo := nil;

  {--------------------------------------------------}
  { ВАЖНО: загрузка репозиториев выполняется ЯВНО }
  {--------------------------------------------------}
  // BuildRepositories(...) вызываются снаружи,
  // когда это действительно необходимо
end;



procedure TManagerTTableDM.SetBufferTypes(const ATypes: TList<TDeviceType>);
var
  I: Integer;
  CopiedType: TDeviceType;
begin
  // Защита от повторного входа, чтобы исключить рекурсивные сценарии и переполнение стека.
  if FBufferTypesBusy then
    Exit;
  FBufferTypesBusy := True;
  try
  // Очищаем буфер и формируем полный снимок каждого типа через Clone.
  FCopiedTypes.Clear;
  if ATypes = nil then
    Exit;

  for I := 0 to ATypes.Count - 1 do
  begin
    if ATypes[I] = nil then
      Continue;
    CopiedType := ATypes[I].Clone;
    FCopiedTypes.Add(CopiedType);
  end;
  finally
    FBufferTypesBusy := False;
  end;
end;

function TManagerTTableDM.GetBufferTypes: TList<TDeviceType>;
var
  I: Integer;
  ClonedTypes: TObjectList<TDeviceType>;
begin
  // Защита от повторного входа, чтобы исключить рекурсивные сценарии и переполнение стека.
  if FBufferTypesBusy then
    Exit(TObjectList<TDeviceType>.Create(True));
  FBufferTypesBusy := True;
  try
  // При чтении возвращаем новые экземпляры, чтобы не выдавать ссылки на внутренний буфер.
  ClonedTypes := TObjectList<TDeviceType>.Create(True);
  for I := 0 to FCopiedTypes.Count - 1 do
    if FCopiedTypes[I] <> nil then
      ClonedTypes.Add(FCopiedTypes[I].Clone);
  Result := ClonedTypes;
  finally
    FBufferTypesBusy := False;
  end;
end;

procedure TManagerTTableDM.CopyTypesToBuffer(const ATypes: TList<TDeviceType>);
begin
  // Бизнес-логика Copy: копируем переданные типы во внутренний буфер.
  SetBufferTypes(ATypes);
end;

function TManagerTTableDM.PasteBufferTypes: TObjectList<TDeviceType>;
var
  SourceType: TDeviceType;
  NewType: TDeviceType;
begin
  // Бизнес-логика Paste: создаём новые типы в активном репозитории по снимку буфера.
  Result := TObjectList<TDeviceType>.Create(False);
  if (ActiveTypeRepo = nil) or (FCopiedTypes.Count = 0) then
    Exit;

  for SourceType in FCopiedTypes do
  begin
    if SourceType = nil then
      Continue;
    NewType := ActiveTypeRepo.CreateType(SourceType);
    Result.Add(NewType);
  end;
end;

procedure TManagerTTableDM.CutTypesToBuffer(const ATypes: TList<TDeviceType>);
var
  DeviceType: TDeviceType;
begin
  // Бизнес-логика Cut: сначала копируем в буфер, затем удаляем исходные типы.
  SetBufferTypes(ATypes);
  if ActiveTypeRepo = nil then
    Exit;
  for DeviceType in ATypes do
    if DeviceType <> nil then
      ActiveTypeRepo.DeleteType(DeviceType);
end;

function TManagerTTableDM.HasBufferTypes: Boolean;
begin
  Result := (FCopiedTypes <> nil) and (FCopiedTypes.Count > 0);
end;

procedure TManagerTTableDM.SetBufferDevices(const ADevices: TList<TDevice>);
var
  I: Integer;
  CopiedDevice: TDevice;
begin
  // Логика буфера устройств: формируем полный снимок каждого прибора через Clone.
  if FBufferDevicesBusy then
    Exit;
  FBufferDevicesBusy := True;
  try
    FCopiedDevices.Clear;
    if ADevices = nil then
      Exit;

    for I := 0 to ADevices.Count - 1 do
    begin
      if ADevices[I] = nil then
        Continue;

      CopiedDevice := ADevices[I].Clone;
      FCopiedDevices.Add(CopiedDevice);
    end;
  finally
    FBufferDevicesBusy := False;
  end;
end;

function TManagerTTableDM.GetBufferDevices: TList<TDevice>;
begin
  // Возвращаем ссылки на буфер только для просмотра содержимого буфера.
  Result := FCopiedDevices;
end;

procedure TManagerTTableDM.CopyDevicesToBuffer(const ADevices: TList<TDevice>);
begin
  // Бизнес-логика Copy для приборов через менеджер данных.
  SetBufferDevices(ADevices);
end;

function TManagerTTableDM.PasteBufferDevices: TObjectList<TDevice>;
var
  SourceDevice: TDevice;
  NewDevice: TDevice;
begin
  // Бизнес-логика Paste: создаём новые экземпляры приборов через репозиторий.
  Result := TObjectList<TDevice>.Create(False);
  if (ActiveDeviceRepo = nil) or (FCopiedDevices.Count = 0) then
    Exit;

  for SourceDevice in FCopiedDevices do
  begin
    if SourceDevice = nil then
      Continue;
    NewDevice := ActiveDeviceRepo.CreateDevice(SourceDevice);
    Result.Add(NewDevice);
  end;
end;

procedure TManagerTTableDM.CutDevicesToBuffer(const ADevices: TList<TDevice>);
var
  Device: TDevice;
begin
  // Бизнес-логика Cut: сначала копирование в буфер, затем удаление исходных строк.
  SetBufferDevices(ADevices);
  if ActiveDeviceRepo = nil then
    Exit;
  for Device in ADevices do
    if Device <> nil then
      ActiveDeviceRepo.DeleteDevice(Device);
end;

function TManagerTTableDM.HasBufferDevices: Boolean;
begin
  // Проверка наличия данных в буфере устройств.
  Result := (FCopiedDevices <> nil) and (FCopiedDevices.Count > 0);
end;

procedure TManagerTTableDM.AssignDeviceTreeFields(const ADevice: TDevice; const ANode: TTreeViewItem);
var
  Cur: TTreeViewItem;
begin
  // Логика замены полей прибора по выбранной ветке дерева.
  if (ADevice = nil) or (ANode = nil) then
    Exit;

  Cur := ANode;
  while Cur <> nil do
  begin
    case Cur.Tag of
      Ord(tnManufacturer):
        ADevice.Manufacturer := Cur.TagString;
      Ord(tnCategory):
        begin
          ADevice.Category := StrToIntDef(Cur.TagString, 0);
          if Cur.Text <> '<категория>' then
            ADevice.CategoryName := Cur.Text;
        end;
      Ord(tnModification):
        ADevice.Modification := Cur.TagString;
    end;
    Cur := Cur.ParentItem;
  end;
end;

procedure TManagerTTableDM.AssignTypeTreeFields(const AType: TDeviceType; const ANode: TTreeViewItem);
var
  Cur: TTreeViewItem;
begin
  // Замена полей назначения по выбранной ветке:
  // Modification -> Modification/Category/Manufacturer,
  // Category -> Category/Manufacturer, Manufacturer -> только Manufacturer.
  if (AType = nil) or (ANode = nil) then
    Exit;

  Cur := ANode;
  while Cur <> nil do
  begin
    case Cur.Tag of
      Ord(tnManufacturer):
        AType.Manufacturer := Cur.TagString;
      Ord(tnCategory):
        begin
          AType.Category := StrToIntDef(Cur.TagString, 0);
          AType.CategoryName := Cur.Text;
        end;
      Ord(tnModification):
        AType.Modification := Cur.TagString;
    end;
    Cur := Cur.ParentItem;
  end;
end;






function RepositoryKindFromString(const S: string): TRepositoryKind;
begin
  if SameText(S, 'TypeRepository') then
    Result := rkType

  else if SameText(S, 'DeviceRepository') then
    Result := rkDevice

  else if SameText(S, 'ResultsRepository') then
    Result := rkResults

  else
    raise Exception.Create('Unknown repository kind: ' + S);
end;


function RepositoryKindToString(AKind: TRepositoryKind): string;
begin
  case AKind of
    rkType:
      Result := 'TypeRepository';

    rkDevice:
      Result := 'DeviceRepository';

    rkResults:
      Result := 'ResultsRepository';

  else
    raise Exception.Create('Unknown repository kind');
  end;
end;


function TManagerTTableDM.NormalizeRepositoryDbFileName(
  AKind: TRepositoryKind;
  const ADbFile: string
): string;
var
  BaseDir: string;
  TargetDir: string;
begin
  BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(FIniFileName));

  case AKind of
    rkType:
      TargetDir := TPath.Combine(BaseDir, 'Types');

    rkDevice:
      TargetDir := TPath.Combine(BaseDir, 'Devices');
  else
    TargetDir := BaseDir;
  end;

  if not TPath.IsPathRooted(ADbFile) then
    Result := TPath.Combine(TargetDir, TPath.GetFileName(ADbFile))
  else if SameText(TPath.GetDirectoryName(ADbFile), ExcludeTrailingPathDelimiter(TargetDir)) then
    Result := ADbFile
  else
    Result := TPath.Combine(TargetDir, TPath.GetFileName(ADbFile));
end;


procedure TManagerTTableDM.Load;
begin
  BuildRepositories(rkType);
  BuildRepositories(rkDevice);

  LoadRepositories(rkType);
  LoadRepositories(rkDevice);
end;

procedure TManagerTTableDM.Save;
var
  Ini: TIniFile;
  Repo: TBaseRepository;
  Section: string;
begin
  if FIniFileName = '' then
    Exit;

  Ini := TIniFile.Create(FIniFileName);
  try
    {==================================================}
    { 1. СОХРАНЕНИЕ РЕПОЗИТОРИЕВ }
    {==================================================}

    // ---------- ТИПЫ ----------
    for Repo in FTypeRepositories do
    begin
      if not Repo.WriteAccess then
        Continue;

      if (Repo.State <> osLoaded) and (Repo.State <> osClean)    then
        Repo.Save;
    end;

    // ---------- ПРИБОРЫ ----------
    for Repo in FDeviceRepositories do
    begin
      if not Repo.WriteAccess then
        Continue;

      if (Repo.State <> osLoaded) and (Repo.State <> osClean) then
        Repo.Save;
    end;

    {==================================================}
    { 2. ПЕРЕЗАПИСЬ INI-ФАЙЛА }
    {==================================================}

    Ini.EraseSection('Repositories');

    // ---------- ТИПЫ ----------
    for Repo in FTypeRepositories do
    begin
      Ini.WriteString(
        'Repositories',
        Repo.Name,
        Repo.GeTDMFileName
      );

      Section := 'Repository.' + Repo.Name;

      Ini.WriteString(Section, 'Kind', RepositoryKindToString(Repo.Kind));
      Ini.WriteString(Section, 'UUID', Repo.UUID);
      Ini.WriteBool  (Section, 'WriteAccess', Repo.WriteAccess);
      Ini.WriteString(Section, 'Comment', Repo.Comment);
    end;

    // ---------- ПРИБОРЫ ----------
    for Repo in FDeviceRepositories do
    begin
      Ini.WriteString(
        'Repositories',
        Repo.Name,
        Repo.GeTDMFileName
      );

      Section := 'Repository.' + Repo.Name;

      Ini.WriteString(Section, 'Kind', RepositoryKindToString(Repo.Kind));
      Ini.WriteString(Section, 'UUID', Repo.UUID);
      Ini.WriteBool  (Section, 'WriteAccess', Repo.WriteAccess);
      Ini.WriteString(Section, 'Comment', Repo.Comment);
    end;

    {==================================================}
    { 3. АКТИВНЫЕ РЕПОЗИТОРИИ }
    {==================================================}

    if FActiveTypeRepo <> nil then
      Ini.WriteString(
        'Active',
        'TypeRepository',
        FActiveTypeRepo.Name
      );

    if FActiveDeviceRepo <> nil then
      Ini.WriteString(
        'Active',
        'DeviceRepository',
        FActiveDeviceRepo.Name
      );

  finally
    Ini.Free;
  end;
end;

procedure TManagerTTableDM.BuildRepositories(
  AKind: TRepositoryKind
);
var
  Ini: TIniFile;
  Names: TStringList;
  I: Integer;

  RepoName: string;
  DbFile: string;
  KindStr: string;
  Kind: TRepositoryKind;

  DM: TTableDM;
  Repo: TBaseRepository;

  Section: string;
  RepoUUID: string;
  RepoComment: string;
  RepoWriteAccess: Boolean;

  ActiveKey: string;
begin
  {--------------------------------------------------}
  { Гарантируем наличие ini-файла }
  {--------------------------------------------------}
  if not FileExists(FIniFileName) then
    TIniFile.Create(FIniFileName).Free;

  Ini   := TIniFile.Create(FIniFileName);
  Names := TStringList.Create;
  try
    {--------------------------------------------------}
    { Список репозиториев }
    {--------------------------------------------------}
    Ini.ReadSection('Repositories', Names);

    for I := 0 to Names.Count - 1 do
    begin
      RepoName := Names[I];
      DbFile   := Ini.ReadString('Repositories', RepoName, '');
      KindStr  := Ini.ReadString('Repository.' + RepoName, 'Kind', '');

      if (RepoName = '') or (DbFile = '') or (KindStr = '') then
        Continue;

      Kind := RepositoryKindFromString(KindStr);
      DbFile := NormalizeRepositoryDbFileName(Kind, DbFile);
      if Kind <> AKind then
        Continue;

      {--------------------------------------------------}
      { Параметры репозитория }
      {--------------------------------------------------}
      Section := 'Repository.' + RepoName;

      RepoUUID :=
        Ini.ReadString(
          Section,
          'UUID',
          TGUID.NewGuid.ToString
        );

      RepoWriteAccess :=
        Ini.ReadBool(
          Section,
          'WriteAccess',
          True
        );

      RepoComment :=
        Ini.ReadString(
          Section,
          'Comment',
          ''
        );

      {--------------------------------------------------}
      { Создаём DataModule }
      {--------------------------------------------------}
      DM := TTableDM.Create(DbFile);
      try
        DM.OpenDB;

        {--------------------------------------------------}
        { Создаём репозиторий }
        {--------------------------------------------------}
        Repo := CreateRepository(RepoName, Kind, DM);

        {--------------------------------------------------}
        { Инициализация общих свойств }
        {--------------------------------------------------}
        Repo.Init(RepoUUID, RepoWriteAccess, RepoComment);

      except
        DM.Free;
        raise;
      end;
    end;

    {--------------------------------------------------}
    { Восстановление активного репозитория }
    {--------------------------------------------------}
    case AKind of
      rkType:    ActiveKey := 'TypeRepository';
      rkDevice:  ActiveKey := 'DeviceRepository';
      rkResults: ActiveKey := 'ResultsRepository';
    else
      Exit;
    end;

    RepoName := Ini.ReadString('Active', ActiveKey, '');
    if RepoName <> '' then
      SetActiveRepository(AKind, RepoName);

    {--------------------------------------------------}
    { Фолбэк — первый доступный }
    {--------------------------------------------------}
    case AKind of
      rkType:
        if (FActiveTypeRepo = nil) and (FTypeRepositories.Count > 0) then
          FActiveTypeRepo := FTypeRepositories[0];

      rkDevice:
        if (FActiveDeviceRepo = nil) and (FDeviceRepositories.Count > 0) then
          FActiveDeviceRepo := FDeviceRepositories[0];

      rkResults:
        begin
          // пока не используется
        end;
    end;

  finally
    Names.Free;
    Ini.Free;
  end;
end;

function TManagerTTableDM.CreateRepository(
  const AName: string;
  AKind: TRepositoryKind;
  ADM: TTableDM
): TBaseRepository;
begin
  if AName = '' then
    raise Exception.Create('CreateRepository: empty name');

  case AKind of
    rkType:
      Result := CreateTypeRepository(AName, ADM);

    rkDevice:
      Result := CreateDeviceRepository(AName, ADM);

    rkResults:
      raise Exception.Create('Results repository not implemented');
  else
    raise Exception.Create('Unknown repository kind');
  end;
end;

procedure TManagerTTableDM.LoadRepositories(
  AKind: TRepositoryKind
);
var
  Repo: TBaseRepository;
begin
  case AKind of

    rkType:
      begin
        for Repo in FTypeRepositories do
        begin
          if Repo = nil then
            Continue;

          if Repo.State <> osLoaded then
            Repo.Load;
        end;

        {----------------------------------}
        { Категории живут в репозитории типов }
        { Инициализируем, если они пустые }
        {----------------------------------}
        if (ActiveTypeRepo <> nil) and
           ((ActiveTypeRepo.Categories = nil) or
            (ActiveTypeRepo.Categories.Count = 0)) then
        begin
          ActiveTypeRepo.InitCategories;
        end
        else
        begin

        end

      end;

    rkDevice:
      begin
        for Repo in FDeviceRepositories do
        begin
          if Repo = nil then
            Continue;

          if Repo.State <> osLoaded then
            Repo.Load;
        end;
      end;

    rkResults:
      begin
        // на будущее
      end;

  else
    raise Exception.CreateFmt(
      'LoadRepositories: unsupported kind (%d)',
      [Ord(AKind)]
    );
  end;
end;


function TManagerTTableDM.CreateTypeRepository(
  const AName: string;
  ADM: TTableDM
): TTypeRepository;
begin
  if (ADM = nil) or (AName = '') then
    raise Exception.Create('CreateTypeRepository: invalid parameters');

  {--------------------------------------------------}
  { Создаём репозиторий }
  {--------------------------------------------------}
  Result := TTypeRepository.Create(AName, ADM);

  {--------------------------------------------------}
  { Регистрация в менеджере }
  {--------------------------------------------------}
  FTypeRepositories.Add(Result);
  FRepositories.Add(AName, Result);

  {--------------------------------------------------}
  { Делаем активным }
  {--------------------------------------------------}
  FActiveTypeRepo := Result;
end;

function TManagerTTableDM.CreateDeviceRepository(
  const AName: string;
  ADM: TTableDM
): TDeviceRepository;
begin
  if (ADM = nil) or (AName = '') then
    raise Exception.Create('CreateDeviceRepository: invalid parameters');

  {--------------------------------------------------}
  { Создаём репозиторий }
  {--------------------------------------------------}
  Result := TDeviceRepository.Create(AName, ADM);

  {--------------------------------------------------}
  { Регистрация в менеджере }
  {--------------------------------------------------}
  FDeviceRepositories.Add(Result);
  FRepositories.Add(AName, Result);

  {--------------------------------------------------}
  { Делаем активным }
  {--------------------------------------------------}
  FActiveDeviceRepo := Result;
end;

procedure TManagerTTableDM.AddRepository(
  const AName: string;
  AKind: TRepositoryKind;
  const ADbFile: string
);
var
  Ini: TIniFile;
  DM: TTableDM;
  Repo: TBaseRepository;
  RepoName: string;
  DbFile: string;
  KindStr: string;
begin
  if (AName = '') or (ADbFile = '') then
    raise Exception.Create('AddRepository: invalid parameters');

  {--------------------------------------------------}
  { Подбираем уникальное имя репозитория }
  {--------------------------------------------------}
  RepoName := MakeUniqueRepositoryName(AName);

  {--------------------------------------------------}
  { Файл БД (используем тот, что передали) }
  {--------------------------------------------------}
  DbFile := NormalizeRepositoryDbFileName(AKind, ADbFile);

  KindStr := RepositoryKindToString(AKind);

  {--------------------------------------------------}
  { 1. Сохраняем настройки в ini }
  {--------------------------------------------------}
  Ini := TIniFile.Create(FIniFileName);
  try
    Ini.WriteString('Repositories', RepoName, DbFile);
    Ini.WriteString('Repository.' + RepoName, 'Kind', KindStr);

    { базовые параметры репозитория }
    Ini.WriteString(
      'Repository.' + RepoName,
      'UUID',
      TGUID.NewGuid.ToString
    );
    Ini.WriteBool(
      'Repository.' + RepoName,
      'WriteAccess',
      True
    );
    Ini.WriteString(
      'Repository.' + RepoName,
      'Comment',
      ''
    );

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;

  {--------------------------------------------------}
  { 2. Создаём DataModule и открываем БД }
  {--------------------------------------------------}
  DM := TTableDM.Create(DbFile);
  try
    DM.OpenDB;

    { регистрируем DM }
    FDms.Add(RepoName, DM);

    {--------------------------------------------------}
    { 3. Создаём репозиторий }
    {--------------------------------------------------}
    Repo := CreateRepository(RepoName, AKind, DM);

    {--------------------------------------------------}
    { 4. Загружаем/инициализируем схему и данные }
    {--------------------------------------------------}
    if Repo.State <> osLoaded then
      Repo.Load;

  except
    DM.Free;
    raise;
  end;
end;

procedure TManagerTTableDM.RemoveRepository(const AName: string);
var
  Ini: TIniFile;
  Obj: TObject;
  Repo: TBaseRepository;
  DM: TTableDM;
begin
  Repo := nil;

  {--------------------------------------------------}
  { 1. Находим репозиторий }
  {--------------------------------------------------}
  if FRepositories.TryGetValue(AName, Obj) then
  begin
    if Obj is TBaseRepository then
      Repo := TBaseRepository(Obj);

    // удаляем из общего словаря
    FRepositories.Remove(AName);
  end;

  {--------------------------------------------------}
  { 2. Удаляем из специализированных списков }
  {--------------------------------------------------}
  if Repo <> nil then
  begin
    case Repo.Kind of

      rkType:
        begin
          FTypeRepositories.Remove(TTypeRepository(Repo));
          if FActiveTypeRepo = Repo then
            FActiveTypeRepo := nil;
        end;

      rkDevice:
        begin
          FDeviceRepositories.Remove(TDeviceRepository(Repo));
          if FActiveDeviceRepo = Repo then
            FActiveDeviceRepo := nil;
        end;

      rkResults:
        begin
          // пока не используется
        end;

    end;
    // Repo будет освобождён владельцем списка
  end;

  {--------------------------------------------------}
  { 3. Удаляем DataModule }
  {--------------------------------------------------}
  if FDms.TryGetValue(AName, DM) then
  begin
    FDms.Remove(AName);
    // DM освобождается автоматически (doOwnsValues)
  end;

  {--------------------------------------------------}
  { 4. Восстанавливаем активные репозитории }
  {--------------------------------------------------}
  if (FActiveTypeRepo = nil) and (FTypeRepositories.Count > 0) then
    FActiveTypeRepo := FTypeRepositories[0];

  if (FActiveDeviceRepo = nil) and (FDeviceRepositories.Count > 0) then
    FActiveDeviceRepo := FDeviceRepositories[0];

  {--------------------------------------------------}
  { 5. Обновляем INI }
  {--------------------------------------------------}
  Ini := TIniFile.Create(FIniFileName);
  try
    Ini.DeleteKey('Repositories', AName);
    Ini.EraseSection('Repository.' + AName);

    if FActiveTypeRepo <> nil then
      Ini.WriteString('Active', 'TypeRepository', FActiveTypeRepo.Name)
    else
      Ini.DeleteKey('Active', 'TypeRepository');

    if FActiveDeviceRepo <> nil then
      Ini.WriteString('Active', 'DeviceRepository', FActiveDeviceRepo.Name)
    else
      Ini.DeleteKey('Active', 'DeviceRepository');

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

function TManagerTTableDM.GetRepository(const AName: string): TObject;
begin
  Result := FRepositories[AName];
end;

procedure   TManagerTTableDM.CloseAll;
begin
         // освобождает все TTableDM
  //FRepositories.Clear;
end;

function TManagerTTableDM.MakeUniqueRepositoryName(
  const ABaseName: string
): string;
var
  Index: Integer;
begin
  Result := ABaseName;
  Index := 1;

  while FRepositories.ContainsKey(Result) do
  begin
    Result := Format('%s (%d)', [ABaseName, Index]);
    Inc(Index);
  end;
end;

procedure TManagerTTableDM.SetActiveRepository(
  AKind: TRepositoryKind;
  const AName: string
);
var
  I: Integer;
begin
  if AName = '' then
    Exit;

  case AKind of

    rkType:
      begin
        for I := 0 to FTypeRepositories.Count - 1 do
          if SameText(FTypeRepositories[I].Name, AName) then
          begin
            FActiveTypeRepo := FTypeRepositories[I];
            Exit;
          end;
      end;

    rkDevice:
      begin
        for I := 0 to FDeviceRepositories.Count - 1 do
          if SameText(FDeviceRepositories[I].Name, AName) then
          begin
            FActiveDeviceRepo := FDeviceRepositories[I];
            Exit;
          end;
      end;

    rkResults:
      begin
        // Пока не реализовано
        Exit;
      end;

  else
    raise Exception.CreateFmt(
      'SetActiveRepository: неподдерживаемый тип (%d)',
      [Ord(AKind)]
    );
  end;
end;



procedure TManagerTTableDM.SetActiveTypeRepository(const AName: string);
var
  Repo: TObject;
  Ini: TIniFile;
begin
  // --------------------------------------------------
  // Проверка наличия
  // --------------------------------------------------
  if not FRepositories.TryGetValue(AName, Repo) then
    Exit;

  if not (Repo is TTypeRepository) then
    Exit;

  // --------------------------------------------------
  // Если уже активный — ничего не делаем
  // --------------------------------------------------
  if FActiveTypeRepo = TTypeRepository(Repo) then
    Exit;

  // --------------------------------------------------
  // Назначаем активным
  // --------------------------------------------------
  FActiveTypeRepo := TTypeRepository(Repo);

  // --------------------------------------------------
  // Сохраняем в ini
  // --------------------------------------------------
  Ini := TIniFile.Create(FIniFileName);
  try
    Ini.WriteString('Active', 'TypeRepository', AName);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TManagerTTableDM.SetActiveDeviceRepository(
  const AName: string
);
var
  I: Integer;
begin
  if AName = '' then
    Exit;

  for I := 0 to FDeviceRepositories.Count - 1 do
    if SameText(FDeviceRepositories[I].Name, AName) then
    begin
      FActiveDeviceRepo := FDeviceRepositories[I];
      Exit;
    end;

  raise Exception.CreateFmt(
    'SetActiveDeviceRepository: репозиторий "%s" не найден',
    [AName]
  );
end;




destructor  TManagerTTableDM.Destroy;
begin
  FDms.Clear;
  FreeAndNil(FCopiedTypes);
  FreeAndNil(FCategories);
  FreeAndNil(FDeviceRepositories);
  FreeAndNil(FTypeRepositories);
  FreeAndNil(FRepositories);
  FreeAndNil(FDms);
//  FRepositories.Free;        // Надо разобраться почему тут возикает ошибка и устранить её
  inherited;
end;

function TManagerTTableDM.Categories: TObjectList<TDeviceCategory>;
var
  C: TDeviceCategory;

  procedure AddCategory(
    AID: Integer;
    const AName: string;
    ADimension: TMeasuredDimension;
    AOutputType: TOutputType;
    const AKeyWords: string;
    AStdCategory: EStdCategory
  );
  begin
    C := TDeviceCategory.Create;
    C.ID := AID;
    C.Name := AName;
    C.MeasuredDimension := ADimension;
    C.DefaultOutputType := AOutputType;
    C.KeyWords := AKeyWords;
    C.StdCategory := AStdCategory;
    FCategories.Add(C);
  end;

begin
  {--------------------------------------------------}
  { 1. Есть активный репозиторий типов → используем его }
  {--------------------------------------------------}
  if (ActiveTypeRepo <> nil) and
     (ActiveTypeRepo.Categories <> nil) and
     (ActiveTypeRepo.Categories.Count > 0) then
  begin
    Result := ActiveTypeRepo.Categories;
    Exit;
  end;



  {----------------------------------------------}
  { Если FCategories уже заполнен }
  {----------------------------------------------}
  if   (FCategories <> nil)
   then
   begin
   if (FCategories.Count > 0) then
  begin
    Result := FCategories;
    Exit;
  end
   end
   else
   begin
  if FCategories = nil then
    FCategories := TObjectList<TDeviceCategory>.Create(True);
   end;


  {----------------------------------------------}
  { FCategories пустой — заполняем стандартными }
  {----------------------------------------------}
  {--------------------------------------------------}
  { 2. Репозитория нет → используем FCategories }
  {--------------------------------------------------}

  // =================================================
  // -1 — ПУСТАЯ КАТЕГОРИЯ
  // =================================================
  AddCategory(
    -1,
    '<категория>',
    mdVolume,
    otImpulse,
    '',
    mftUnknownType
  );

  // =================================================
  // 0 — НЕ УКАЗАНА
  // =================================================
  AddCategory(
    0,
    '<не указана>',
    mdVolume,
    otImpulse,
    '',
    mftUnknownType
  );

  // =================================================
  // 1 — Расходомер электромагнитный
  // =================================================
  AddCategory(
    1,
    'Расходомер электромагнитный',
    mdVolume,
    otImpulse,
    'электромагнитн;магнитн',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 2 — Расходомер кориолисовый
  // =================================================
  AddCategory(
    2,
    'Расходомер кориолисовый',
    mdMass,
    otImpulse,
    'кориолис',
    mftMassFlowmeterType
  );

  // =================================================
  // 3 — Расходомер вихревой
  // =================================================
  AddCategory(
    3,
    'Расходомер вихревой',
    mdVolume,
    otFrequency,
    'вихр',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 4 — Расходомер механический
  // =================================================
  AddCategory(
    4,
    'Расходомер механический',
    mdVolume,
    otImpulse,
    'механич;турбин;крыльчат',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 5 — Расходомер ультразвуковой
  // =================================================
  AddCategory(
    5,
    'Расходомер ультразвуковой',
    mdVolume,
    otImpulse,
    'ультразв',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 6 — Счётчик воды механический
  // =================================================
  AddCategory(
    6,
    'Счётчик воды механический',
    mdVolume,
    otImpulse,
    'счётчик воды;водосчётчик;водомер',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 7 — Скоростомер
  // =================================================
  AddCategory(
    7,
    'Скоростомер',
    mdSpeed,
    otFrequency,
    'скорост',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 8 — Теплосчетчик
  // =================================================
  AddCategory(
    8,
    'Теплосчетчик',
    mdMass,
    otInterface,
    'теплосчетчик;теплосчётчик;теплов',
    mftMassFlowmeterType
  );

  // =================================================
  // 9 — Ротаметр
  // =================================================
  AddCategory(
    9,
    'Ротаметр',
    mdVolume,
    otVisual,
    'ротаметр',
    mftVolumeFlowmeterType
  );

  // =================================================
  // 10 — Емкость (мерник)
  // =================================================
  AddCategory(
    10,
    'Емкость (мерник)',
    mdVolume,
    otVisual,
    'емкост;мерник;бак;резервуар',
    mftTankType
  );

  // =================================================
  // 11 — Весы
  // =================================================
  AddCategory(
    11,
    'Весы',
    mdMass,
    otInterface,
    'весы;взвешиван',
    mftWeightsType
  );

  Result := FCategories;
end;

function TManagerTTableDM.FindCategoryByID(AID: Integer): TDeviceCategory;
var
  C: TDeviceCategory;
begin
  Result := nil;

  // служебные и некорректные ID не ищем
  if AID < 0 then
    Exit;

  if Categories = nil then
    Exit;

  for C in Categories do
    if C.ID = AID then
      Exit(C);
end;

function TManagerTTableDM.FindType(
  const AUUID, AName: string;
  out ARepo: TTypeRepository
): TDeviceType;
var
  Repo: TTypeRepository;
begin
  Result := nil;
  ARepo := nil;

  // --------------------------------------------------
  // 1. Сначала ищем в активном репозитории
  // --------------------------------------------------
  if ActiveTypeRepo <> nil then
  begin
    // приоритет — UUID
    if AUUID <> '' then
      Result := ActiveTypeRepo.FindTypeByUUID(AUUID);

    // если не найдено — по имени
   // if (Result = nil) and (AName <> '') then
   //   Result := ActiveTypeRepo.FindTypeByName(AName);

    if Result <> nil then
    begin
      ARepo := ActiveTypeRepo;
      Exit;
    end;
  end;

  // --------------------------------------------------
  // 2. Затем ищем во всех остальных репозиториях
  // --------------------------------------------------
  for Repo in TypeRepositories do
  begin
    if Repo = ActiveTypeRepo then
      Continue;

    // приоритет — UUID
    if AUUID <> '' then
      Result := Repo.FindTypeByUUID(AUUID);

    // если не найдено — по имени
    if (Result = nil) and (AName <> '') then
      Result := Repo.FindTypeByName(AName);

    if Result <> nil then
    begin
      ARepo := Repo;
      Exit;
    end;
  end;
end;

function TManagerTTableDM.FindDevice(
  const AUUID: string;
  out ARepo: TDeviceRepository
): TDevice;
var
  Repo: TDeviceRepository;
begin
  Result := nil;
  ARepo := nil;

  if AUUID = '' then
    Exit;

  // --------------------------------------------------
  // 1. Сначала ищем в активном репозитории приборов
  // --------------------------------------------------
  if (ActiveDeviceRepo <> nil) and (ActiveDeviceRepo.Devices <> nil) then
  begin
    for Result in ActiveDeviceRepo.Devices do
      if SameText(Result.UUID, AUUID) then
      begin
        ARepo := ActiveDeviceRepo;
        Exit;
      end;

    Result := nil;
  end;

  // --------------------------------------------------
  // 2. Затем ищем во всех остальных репозиториях
  // --------------------------------------------------
  for Repo in DeviceRepositories do
  begin
    if Repo = ActiveDeviceRepo then
      Continue;

    if Repo.Devices = nil then
      Continue;

    for Result in Repo.Devices do
      if SameText(Result.UUID, AUUID) then
      begin
        ARepo := Repo;
        Exit;
      end;

    Result := nil;
  end;
end;


function TManagerTTableDM.FindTypeRepositoryByName(
  const AName: string
): TTypeRepository;
var
  Repo: TTypeRepository;
begin
  Result := nil;

  if AName = '' then
    Exit;

  for Repo in TypeRepositories do
    if SameText(Repo.Name, AName) then
      Exit(Repo);
end;


function TManagerTTableDM.FindDeviceRepositoryByName(const AName: string): TDeviceRepository;
var
  Repo: TDeviceRepository;
begin
  Result := nil;

  if AName = '' then
    Exit;

  for Repo in DeviceRepositories do
    if SameText(Repo.Name, AName) then
      Exit(Repo);
end;




end.
