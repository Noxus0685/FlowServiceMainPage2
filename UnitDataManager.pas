unit UnitDataManager;

interface

uses
  UnitBaseProcedures,
  uDATA,
  UnitClasses,
  UnitDeviceClass,
  UnitRepositories,
  System.IniFiles,
  System.Classes,
  System.SysUtils,    System.DateUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf;

type

  TManagerTDM = class
  private

    FIniFileName: string;
    FDms: TObjectDictionary<string, TDM>;

    FRepositories: TObjectDictionary<string, TObject>;

    FTypeRepositories: TObjectList<TTypeRepository>;
    FActiveTypeRepo:  TTypeRepository;

    FDeviceRepositories: TObjectList<TDeviceRepository>;
    FActiveDeviceRepo:  TDeviceRepository;

    FCategories: TObjectList<TDeviceCategory>;

    //Загрузка нужного репозитария  (rkType, rkDevice, rkResults);


    function CreateRepository(const AName: string; AKind: TRepositoryKind;ADM: TDM ): TBaseRepository;


    function CreateTypeRepository(const AName: string; ADM: TDM): TTypeRepository;
    function CreateDeviceRepository(const AName: string; ADM: TDM): TDeviceRepository;
    function MakeUniqueRepositoryName(const ABaseName: string): string;

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
  function FindTypeRepositoryByName(const AName: string): TTypeRepository;


  end;

 var

  DataManager: TManagerTDM;

implementation


{==== TManagerTDM ==================================}
constructor TManagerTDM.Create(const AIniFileName: string);
begin
  inherited Create;

  {--------------------------------------------------}
  { Имя ini-файла }
  {--------------------------------------------------}
  FIniFileName := AIniFileName;

  {--------------------------------------------------}
  { Контейнеры DataModule }
  {--------------------------------------------------}
  FDms := TObjectDictionary<string, TDM>.Create([doOwnsValues]);

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


procedure TManagerTDM.Load;
begin
  BuildRepositories(rkType);
  BuildRepositories(rkDevice);

  LoadRepositories(rkType);
  LoadRepositories(rkDevice);
end;

procedure TManagerTDM.Save;
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

      if Repo.State <> osClean then
        Repo.Save;
    end;

    // ---------- ПРИБОРЫ ----------
    for Repo in FDeviceRepositories do
    begin
      if not Repo.WriteAccess then
        Continue;

      if Repo.State <> osClean then
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
        Repo.GetDMFileName
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
        Repo.GetDMFileName
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

procedure TManagerTDM.BuildRepositories(
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

  DM: TDM;
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
      DM := TDM.Create(DbFile);
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

function TManagerTDM.CreateRepository(
  const AName: string;
  AKind: TRepositoryKind;
  ADM: TDM
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
procedure TManagerTDM.LoadRepositories(
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


function TManagerTDM.CreateTypeRepository(
  const AName: string;
  ADM: TDM
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

function TManagerTDM.CreateDeviceRepository(
  const AName: string;
  ADM: TDM
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

procedure TManagerTDM.AddRepository(
  const AName: string;
  AKind: TRepositoryKind;
  const ADbFile: string
);
var
  Ini: TIniFile;
  DM: TDM;
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
  DbFile := ADbFile;

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
  DM := TDM.Create(DbFile);
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

procedure TManagerTDM.RemoveRepository(const AName: string);
var
  Ini: TIniFile;
  Obj: TObject;
  Repo: TBaseRepository;
  DM: TDM;
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

function TManagerTDM.GetRepository(const AName: string): TObject;
begin
  Result := FRepositories[AName];
end;

procedure   TManagerTDM.CloseAll;
begin
  FDms.Clear;         // освобождает все TDM
  FRepositories.Clear;
end;

function TManagerTDM.MakeUniqueRepositoryName(
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

procedure TManagerTDM.SetActiveRepository(
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



procedure TManagerTDM.SetActiveTypeRepository(const AName: string);
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

procedure TManagerTDM.SetActiveDeviceRepository(
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




destructor  TManagerTDM.Destroy;
begin
  CloseAll;
  FDms.Free;
  FRepositories.Free;
  inherited;
end;

function TManagerTDM.Categories: TObjectList<TDeviceCategory>;
var
  C: TDeviceCategory;

  procedure AddCategory(
    AID: Integer;
    const AName: string;
    ADimension: TMeasuredDimension;
    AOutputType: TOutputType;
    const AKeyWords: string
  );
  begin
    C := TDeviceCategory.Create;
    C.ID := AID;
    C.Name := AName;
    C.MeasuredDimension := ADimension;
    C.DefaultOutputType := AOutputType;
    C.KeyWords := AKeyWords;
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
    ''
  );

  // =================================================
  // 0 — НЕ УКАЗАНА
  // =================================================
  AddCategory(
    0,
    '<не указана>',
    mdVolume,
    otImpulse,
    ''
  );

  // =================================================
  // 1 — Расходомер электромагнитный
  // =================================================
  AddCategory(
    1,
    'Расходомер электромагнитный',
    mdVolume,
    otImpulse,
    'электромагнитн;магнитн'
  );

  // =================================================
  // 2 — Расходомер кориолисовый
  // =================================================
  AddCategory(
    2,
    'Расходомер кориолисовый',
    mdMass,
    otImpulse,
    'кориолис'
  );

  // =================================================
  // 3 — Расходомер вихревой
  // =================================================
  AddCategory(
    3,
    'Расходомер вихревой',
    mdVolume,
    otFrequency,
    'вихр'
  );

  // =================================================
  // 4 — Расходомер механический
  // =================================================
  AddCategory(
    4,
    'Расходомер механический',
    mdVolume,
    otImpulse,
    'механич;турбин;крыльчат'
  );

  // =================================================
  // 5 — Расходомер ультразвуковой
  // =================================================
  AddCategory(
    5,
    'Расходомер ультразвуковой',
    mdVolume,
    otImpulse,
    'ультразв'
  );

  // =================================================
  // 6 — Счётчик воды механический
  // =================================================
  AddCategory(
    6,
    'Счётчик воды механический',
    mdVolume,
    otImpulse,
    'счётчик воды;водосчётчик;водомер'
  );

  // =================================================
  // 7 — Скоростомер
  // =================================================
  AddCategory(
    7,
    'Скоростомер',
    mdSpeed,
    otFrequency,
    'скорост'
  );

  // =================================================
  // 8 — Теплосчетчик
  // =================================================
  AddCategory(
    8,
    'Теплосчетчик',
    mdMass,
    otInterface,
    'теплосчетчик;теплосчётчик;теплов'
  );

  // =================================================
  // 9 — Ротаметр
  // =================================================
  AddCategory(
    9,
    'Ротаметр',
    mdVolume,
    otVisual,
    'ротаметр'
  );

  // =================================================
  // 10 — Емкость (мерник)
  // =================================================
  AddCategory(
    10,
    'Емкость (мерник)',
    mdVolume,
    otVisual,
    'емкост;мерник;бак;резервуар'
  );

  // =================================================
  // 11 — Весы
  // =================================================
  AddCategory(
    11,
    'Весы',
    mdMass,
    otInterface,
    'весы;взвешиван'
  );

  Result := FCategories;
end;

function TManagerTDM.FindCategoryByID(AID: Integer): TDeviceCategory;
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

function TManagerTDM.FindType(
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


function TManagerTDM.FindTypeRepositoryByName(
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


end.
