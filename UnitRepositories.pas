unit UnitRepositories;


interface
uses
  uData,
  UnitClasses,
  UnitDeviceClass,
  UnitBaseProcedures,
  System.Classes,
  System.SysUtils,    System.DateUtils,
  System.Generics.Collections,
  System.IOUtils,

  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.FMXUI.Wait,
  FireDAC.Phys.SQLiteWrapper.Stat
  ;

type

  TRepositoryKind = (rkType, rkDevice, rkResults);

  TBaseRepository = class
  protected
    FName: string;
    FID: Integer;
    FUUID: string;      // Уникальный ID репозитория
    FComment: string;
    FWriteAccess: Boolean;
    FKind: TRepositoryKind;
    FState: TObjectState;
    FDM: TDM;
    FDescription: string;
  public

    constructor Create(
      const AName: string;
      AKind: TRepositoryKind;
      ADM: TDM
    ); virtual;

     procedure Init(
  const AUUID: string;
  AWriteAccess: Boolean;
  const AComment: string


);

    property Name: string read FName;
    property UUID: string read FUUID write FUUID;
    property ID: Integer  read FID write FID;
    property Comment: string read FComment write FComment;
    property WriteAccess: Boolean read FWriteAccess write FWriteAccess;
    property Kind: TRepositoryKind read FKind;
    property State: TObjectState read FState write FState;
    property Description: string read FDescription write FDescription;

    function Save: Boolean; virtual; abstract;
    function Load: Boolean; virtual; abstract;
    procedure EnsureSchema; virtual; abstract;
    procedure AssertSchema; virtual; abstract;

    function GetDMFileName:string;

  end;

  TTypeRepository = class (TBaseRepository)
  private
  { ================= Хранилище ================= }
    { Хранилища, все исходные экземпляры, созданные из БД}
    FType: TDeviceType;
    FTypes: TObjectList<TDeviceType>;
 //   FDiameters: TObjectList<TDiameter>;
 //   FPoints: TObjectList<TTypePoint>;
    FCategories: TObjectList<TDeviceCategory>;

    { Генераторы ID }
    FNextTypeID: Integer;
    FNextDiameterID: Integer;
    FNextPointID: Integer;
    function FindCategoryByID(AID: Integer): TDeviceCategory;

    { ================= TYPES ================= }


    function CreateNewType: TDeviceType;
    function GenerateTypeID: Integer;

    function RequiredTypeColumns: TTableColumns;
    procedure EnsureTypeSchema;
    procedure AssertTypeSchema;

        //Сохранение одного тиипа. ACheckExists - нужно ли проверять его наличие в БД или сразу добавлять новый.
//    function SaveType(AType: TDeviceType; ACheckExists: Boolean): Boolean;
    function UpdateType(AType: TDeviceType): Boolean; //редактировать один тип
    function SaveTypes: Boolean; //Сохранение с заменой всех типов
    function RebuildTypes: Boolean;

        function MapTypeFromQuery(Q: TFDQuery): TDeviceType;


        {================= SCHEMA : DIAMETERS =================}

    // Описание структуры таблицы DeviceDiameter
    function RequiredDiameterColumns: TTableColumns;

    // Создание / миграция таблицы DeviceDiameter
    procedure EnsureDiameterSchema;

    // Проверка соответствия схемы DeviceDiameter модели
    procedure AssertDiameterSchema;

      {==== Работа с БД! ====}
      //Загрузка в список диаметров конкретного типа из БД    //Требует реализации SQL
    function MapDiameterFromQuery(Q: TFDQuery): TDiameter;

    function LoadDiametersByType(ATypeID: Integer): TObjectList<TDiameter>;

    function UpdateDiameter(ADiameter: TDiameter): Boolean;
    function UpdateDiameters(AType: TDeviceType): Boolean;
    { ================= POINTS ================= }

         {================= SCHEMA : TYPE POINTS =================}
    // Описание структуры таблицы DeviceTypePoint
    function RequiredPointColumns: TTableColumns;

    // Создание / миграция таблицы DeviceTypePoint
    procedure EnsurePointSchema;

    // Проверка соответствия схемы DeviceTypePoint модели
    procedure AssertPointSchema;
    {==== Работа с БД! ====}
    function MapTypePointFromQuery(Q: TFDQuery): TTypePoint;

    function LoadTypePointsByType(ATypeID: Integer): TObjectList<TTypePoint>;

     function UpdateTypePoint(APoint: TTypePoint): Boolean;
    function UpdateTypePoints(AType: TDeviceType): Boolean;   //Редактирование точек определенного типа //Требует реализации SQL
   


    { ================= CATEGORIES ================= }

    function RequiredCategoryColumns: TTableColumns;
    procedure EnsureCategorySchema;
    procedure AssertCategorySchema;
        {==== Работа с БД! ====}
    function LoadCategories: Boolean;   // Загрузка категорий //Требует реализации SQL
    function SaveCategories: Boolean;   //Сохранение с заменой всех категорий  //Требует реализации SQL

    { ================= INIT (тестовые данные) ================= }
    function InitTypes: TObjectList<TDeviceType>;
    //function InitDiameters: TObjectList<TDiameter>;
    //function InitPoints: TObjectList<TTypePoint>;


  public

    constructor Create(const AName: string; ADM: TDM);
    destructor Destroy; override;


    procedure Init;
    procedure InitBulkTestData;
    function InitCategories: TObjectList<TDeviceCategory>;
   // ТИПЫ
    property Types: TObjectList<TDeviceType> read FTypes write FTypes;

    function CreateType(AType: TDeviceType): TDeviceType; overload;
    function CreateType(ATypeID: Integer): TDeviceType; overload;


    function GetType(ATypeID: Integer): TDeviceType;
    procedure DeleteType(AType: TDeviceType);

    function SaveType(AType: TDeviceType): Boolean;



    {==== LOAD ====}
    function Load: Boolean; override;    // Загрузить из БД в Хранилище все списки
    function Save: Boolean; override;     // Сохранить в БД из Хранилища все списки


    {==== Работа с БД! ====}

    function LoadType(ATypeID: Integer): TDeviceType;
    function LoadTypes: Boolean;          //Загрузка в список всех типов



    property Categories: TObjectList<TDeviceCategory> read FCategories;
    function DetectCategoryByKeywords(const Text: string): Integer;  //Вспомогательная функция
    function CategoryToText(ACategory: Integer;const ACategoryName: string): string;  //Вспомогательная функция

    function FindTypeByUUID(const AUUID: string): TDeviceType;
    function FindTypeByName(const AName: string): TDeviceType;
    function FindTypeByID(const AID: Integer): TDeviceType;
//    FQuery: TFDQuery;
  end;

  TDeviceRepository = class  (TBaseRepository)
  private
    { ================= ХРАНИЛИЩЕ ================= }

    { Текущий прибор (выбранный / редактируемый) }
    FDevice: TDevice;

    { Все приборы, загруженные из БД }
    FDevices: TObjectList<TDevice>;

    { Генераторы ID }
    FNextDeviceID: Integer;
    FNextPointID: Integer;
    FNextSpillageID: Integer;

    { ================= INIT (тестовые данные) ================= }

    procedure Init;
    function InitDevices: TObjectList<TDevice>;
    function InitDevicePoints: TObjectList<TDevicePoint>;



    function GenerateDeviceID: Integer;

    { ================= SCHEMA : DEVICES ================= }

    function RequiredDeviceColumns: TTableColumns;
    procedure EnsureDeviceSchema;
    procedure AssertDeviceSchema;

    { ================= DB : DEVICES ================= }
    function CreateNewDevice: TDevice;

    function MapDeviceFromQuery(Q: TFDQuery): TDevice;


    function LoadDevices: Boolean;              // Загрузка всех приборов

    function UpdateDevice(ADevice: TDevice): Boolean;
    function RebuildDevices: Boolean;

    { ================= DEVICE POINTS ================= }



    function DeviceExistsInDB(AID: Integer): Boolean;

    function GenerateDevicePointID: Integer;

    { ================= SCHEMA : DEVICE POINTS ================= }

    function RequiredDevicePointColumns: TTableColumns;
    procedure EnsureDevicePointSchema;
    procedure AssertDevicePointSchema;

    { ================= DB : DEVICE POINTS ================= }

    function MapDevicePointFromQuery(Q: TFDQuery): TDevicePoint;

function LoadDevicePointsByDevice(ADeviceID: Integer): Boolean;



    function UpdateDevicePoint(
      APoint: TDevicePoint
    ): Boolean;

    function UpdateDevicePoints(
      ADevice: TDevice
    ): Boolean;


    { ================= SCHEMA : SPILLAGES ================= }

    function RequiredSpillageColumns: TTableColumns;
    procedure EnsureSpillageSchema;
    procedure AssertSpillageSchema;

    { ================= DB : SPILLAGES ================= }

    function MapSpillageFromQuery(Q: TFDQuery): TPointSpillage;

    function LoadSpillagesByDevice(ADeviceID: Integer): Boolean;

    //function SaveSpillages: Boolean;

    function UpdateSpillages(ADevice: TDevice): Boolean;

    function UpdateSpillage(ASpillage: TPointSpillage): Boolean;

  public
    { ================= META ================= }

     {$REGION 'Common'}
    constructor Create(const AName: string; ADM: TDM);
    destructor Destroy; override;



    { ================= LOAD / SAVE ================= }

    function Load: Boolean;override;      // Загрузить все приборы и связанные данные
    function Save: Boolean;override;      // Сохранить все изменения в БД

    function LoadDevice(ADevice: TDevice): TDevice; overload;
    function LoadDevice(ADeviceId: Integer): TDevice; overload;
    function SaveDevice(ADevice: TDevice): Boolean;
    {$ENDREGION}

    { ================= DEVICES ================= }

    property Devices: TObjectList<TDevice> read FDevices write FDevices;
    property Device: TDevice read FDevice write FDevice;

    function CreateDevice(AIndex: Integer): TDevice;

    function GetDevice(ADeviceID: Integer): TDevice;



    procedure DeleteDevice(ADevice: TDevice);
    function FindDeviceByID(ADeviceID: Integer): TDevice;
    procedure InitBulkTestData;

  end;

implementation

{$REGION 'Helpers'}
function Col(const AName, ASqlType: string): TTableColumn;
begin
  Result.Name := AName;
  Result.SqlType := ASqlType;
end;

procedure AppendRepoDebugLog(const AMessage: string);
var
  LogFile: string;
  Line: string;
begin
  try
    LogFile := TPath.Combine(TPath.GetTempPath, 'FlowService_DevicePoint_Debug.log');
    Line := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' | ' + AMessage + sLineBreak;
    TFile.AppendAllText(LogFile, Line, TEncoding.UTF8);
  except
    { no-op: debug logging must never break save flow }
  end;
end;

 procedure SetIntParam(Q: TFDQuery; const AName: string; const AValue: Integer);
begin
  with Q.ParamByName(AName) do
  begin
    DataType := ftInteger;
    AsInteger := AValue;
  end;
end;

procedure SetFloatParam(Q: TFDQuery; const AName: string; const AValue: Double);
begin
  with Q.ParamByName(AName) do
  begin
    DataType := ftFloat;
    AsFloat := AValue;
  end;
end;

procedure SetStrParam(Q: TFDQuery; const AName, AValue: string);
begin
  with Q.ParamByName(AName) do
  begin
    DataType := ftString;
    AsString := AValue;
  end;
end;

procedure SetDateParam(Q: TFDQuery; const AName: string; AValue: TDateTime);
begin
  with Q.ParamByName(AName) do
  begin
    DataType := ftDateTime;
    if AValue > 0 then
      AsDateTime := AValue
    else
      Clear;
  end;
end;

procedure SetDateTimeParam(
  Q: TFDQuery;
  const AName: string;
  const AValue: TDateTime
);
begin
  if AValue = 0 then
    Q.ParamByName(AName).Clear
  else
    Q.ParamByName(AName).AsDateTime := AValue;
end;

 {$ENDREGION}

{$REGION 'TBaseRepository'}
constructor TBaseRepository.Create(
  const AName: string;
  AKind: TRepositoryKind;
  ADM: TDM
);
begin
  inherited Create;

  if AName = '' then
    raise Exception.Create('Repository name is empty');

  if ADM = nil then
    raise Exception.Create('Repository DM is nil');

  FName := AName;
  FKind := AKind;
  FDM := ADM;

  FUUID := TGUID.NewGuid.ToString;
  FComment := '';
  FWriteAccess := True;
  FState := osClean;
end;

 procedure TBaseRepository.Init(
  const AUUID: string;
  AWriteAccess: Boolean;
  const AComment: string
);
begin
  {--------------------------------------------------}
  { UUID }
  {--------------------------------------------------}
  if Trim(AUUID) <> '' then
    FUUID := AUUID
  else
    FUUID := TGUID.NewGuid.ToString;

  {--------------------------------------------------}
  { Права на запись }
  {--------------------------------------------------}
  FWriteAccess := AWriteAccess;

  {--------------------------------------------------}
  { Комментарий }
  {--------------------------------------------------}
  FComment := AComment;
end;

    function TBaseRepository.GetDMFileName:string;
    begin
      result:=FDM.DatabaseFileName;
    end;

  {$ENDREGION}

{$REGION 'TTypeRepository'}

 {$REGION 'TypeRepository Methods'}
constructor TTypeRepository.Create(
  const AName: string;
  ADM: TDM
);
begin
  inherited Create(AName, rkType, ADM);

  {--------------------------------------------------}
  { Хранилища }
  {--------------------------------------------------}
  FTypes      := TObjectList<TDeviceType>.Create(True);
  //FDiameters  := TObjectList<TDiameter>.Create(True);
  //FPoints     := TObjectList<TTypePoint>.Create(True);
  FCategories := TObjectList<TDeviceCategory>.Create(True);

  {--------------------------------------------------}
  { Генераторы ID }
  {--------------------------------------------------}
  FNextTypeID     := 1;
  FNextDiameterID := 1;
  FNextPointID    := 1;
end;

destructor TTypeRepository.Destroy;
begin
  FreeAndNil(FCategories);
  //FreeAndNil(FPoints);
  //FreeAndNil(FDiameters);
  FreeAndNil(FTypes);

  inherited;
end;

function TTypeRepository.Load: Boolean;
begin
  Result := False;

  if FDM = nil then
    Exit;

  FState := osLoading;
  try
    {==================================================}
    { 1. СХЕМА БД }
    {==================================================}

    EnsureCategorySchema;
    EnsureTypeSchema;
    EnsureDiameterSchema;
    EnsurePointSchema;

    AssertCategorySchema;
    AssertTypeSchema;
    AssertDiameterSchema;
    AssertPointSchema;

    {==================================================}
    { 2. КАТЕГОРИИ }
    {==================================================}

    if not LoadCategories then
      raise Exception.Create('Не удалось загрузить категории');

    {==================================================}
    { 3. ТИПЫ (АГРЕГАТЫ) }
    {==================================================}

    if not LoadTypes then
      raise Exception.Create('Не удалось загрузить типы');

    FState := osLoaded;
    Result := True;

  except
    FState := osError;
    raise;
  end;
end;

function TTypeRepository.Save: Boolean;
var
  T: TDeviceType;
  SeenIDs: TDictionary<Integer, TDeviceType>;
begin
  Result := False;

  if (FDM = nil) or (FTypes = nil) then
    Exit;

  {--------------------------------------------------}
  { ПРОВЕРКА ЦЕЛОСТНОСТИ }
  {--------------------------------------------------}
  SeenIDs := TDictionary<Integer, TDeviceType>.Create;
  try
    for T in FTypes do
    begin
      if T.ID <= 0 then
        raise Exception.CreateFmt(
          'Type with invalid ID detected (ID=%d)',
          [T.ID]
        );

      if SeenIDs.ContainsKey(T.ID) then
        raise Exception.CreateFmt(
          'Duplicate type ID in memory: %d',
          [T.ID]
        );

      SeenIDs.Add(T.ID, T);
    end;
  finally
    SeenIDs.Free;
  end;

  {--------------------------------------------------}
  { ТРАНЗАКЦИЯ }
  {--------------------------------------------------}
  FDM.TypesConnection.StartTransaction;
  try
    for T in FTypes do
    begin
      if not UpdateType(T) then
        raise Exception.Create('Ошибка сохранения типа');

      if T.Diameters <> nil then
        for var D in T.Diameters do
          if not UpdateDiameter(D) then
            raise Exception.Create('Ошибка сохранения диаметра');

      if T.Points <> nil then
        for var P in T.Points do
          if not UpdateTypePoint(P) then
            raise Exception.Create('Ошибка сохранения точки типа');

      T.State := osClean;
    end;

    SaveCategories;

    FDM.TypesConnection.Commit;
    FState := osSaved;
    Result := True;

  except
    FDM.TypesConnection.Rollback;
    FState := osError;
    raise;
  end;
end;

function NextID(const List: TObjectList<TObject>): Integer;
var
  Obj: TObject;
  HasID: IHasID;
  MaxID: Integer;
begin
  MaxID := 0;

  if List <> nil then
    for Obj in List do
      if Supports(Obj, IHasID, HasID) then
        if HasID.GetID > MaxID then
          MaxID := HasID.GetID;

  Result := MaxID + 1;
end;

     {$ENDREGION}

 {$REGION 'Inits'}
function TTypeRepository.InitTypes: TObjectList<TDeviceType>;
var
  T, Base: TDeviceType;

  procedure AddClone(
    const ABase: TDeviceType;
    const AReestrNumber: string;
    ACategory: Integer;
    const AModification, AAccuracy: string;
    ARegDate, AValidityDate: TDate
  );
  begin
    T := TDeviceType.Create;
    T.Assign(ABase);

    T.ID := FNextTypeID;
    Inc(FNextTypeID);

    T.ReestrNumber := AReestrNumber;
    T.Category := ACategory;
    T.Modification := AModification;
    T.AccuracyClass := AAccuracy;
    T.RegDate := ARegDate;
    T.ValidityDate := AValidityDate;

    FTypes.Add(T);
  end;

begin
  FTypes.Clear;
  FNextTypeID := 1;

  // =====================================================
  // ВЗЛЕТ
  // =====================================================
  Base := TDeviceType.Create;
  Base.ID := FNextTypeID; Inc(FNextTypeID);
  Base.Name := 'ВЗЛЕТ ТЭР-М';
  Base.Modification := 'ТЭР-М';
  Base.Manufacturer := 'ООО ВЗЛЕТ';
  Base.ReestrNumber := '65432-21';
  Base.Category := 1;
  Base.AccuracyClass := '±0.5';
  Base.ProcedureName := 'Поверка';
  Base.IVI := 4;
  Base.RegDate := EncodeDate(2021, 3, 15);
  Base.ValidityDate := EncodeDate(2025, 3, 15);
  FTypes.Add(Base);

  AddClone(Base, '65432-21', 1, 'ТЭР-М', '±0.25', EncodeDate(2022, 6, 10), EncodeDate(2026, 6, 10));
  AddClone(Base, '65432-21', 1, 'ТЭР-М', '±0.2',  EncodeDate(2020, 1, 20), EncodeDate(2024, 1, 20));
  AddClone(Base, '65432-21', 5, '',      'B',     EncodeDate(2023, 5, 1),  EncodeDate(2029, 5, 1));
  AddClone(Base, '65432-21', -1,'',      '±1.0',  EncodeDate(2019, 9, 30), EncodeDate(2023, 9, 30));

  // =====================================================
  // ЭМИС
  // =====================================================
  Base := TDeviceType.Create;
  Base.ID := FNextTypeID; Inc(FNextTypeID);
  Base.Name := 'ЭМИС-КОР';
  Base.Modification := 'DN10–DN150';
  Base.Manufacturer := 'НПФ ЭМИС';
  Base.ReestrNumber := '71234-20';
  Base.Category := 2;
  Base.AccuracyClass := '±0.2';
  Base.ProcedureName := 'Поверка';
  Base.IVI := 5;
  Base.RegDate := EncodeDate(2020, 2, 18);
  Base.ValidityDate := EncodeDate(2025, 2, 18);
  FTypes.Add(Base);

  AddClone(Base, '71234-20', 2, 'DN10–DN150', '±0.2', EncodeDate(2021, 7, 1),  EncodeDate(2026, 7, 1));
  AddClone(Base, '71234-20', 4, 'DN10–DN150', '±2.5', EncodeDate(2018, 8, 12), EncodeDate(2023, 8, 12));
  AddClone(Base, '71234-20', 2, '',           '±0.2', EncodeDate(2022,12,25), EncodeDate(2027,12,25));
  AddClone(Base, '71234-20', -1,'',           '±0.2', EncodeDate(2023, 4, 8),  EncodeDate(2028, 4, 8));

  // =====================================================
  // ТЕПЛОПРИБОР
  // =====================================================
  Base := TDeviceType.Create;
  Base.ID := FNextTypeID; Inc(FNextTypeID);
  Base.Name := 'ВИХРЬ-01';
  Base.Modification := 'DN25–DN200';
  Base.Manufacturer := 'ТЕПЛОПРИБОР';
  Base.ReestrNumber := '49876-19';
  Base.Category := 3;
  Base.AccuracyClass := '±1.0';
  Base.ProcedureName := 'Поверка';
  Base.IVI := 4;
  Base.RegDate := EncodeDate(2019, 10, 3);
  Base.ValidityDate := EncodeDate(2023, 10, 3);
  FTypes.Add(Base);

  AddClone(Base, '49876-19', 3, 'DN25–DN200', '±0.75', EncodeDate(2021,10,3), EncodeDate(2025,10,3));
  AddClone(Base, '49876-19', 6, '500 л',      '±0.5',  EncodeDate(2024, 6,30), EncodeDate(2030, 6,30));
  AddClone(Base, '49876-19', -1,'',           '±1.0',  EncodeDate(2022, 5,14), EncodeDate(2026, 5,14));

  // =====================================================
  // ТЕПЛОВОДОМЕР
  // =====================================================
  Base := TDeviceType.Create;
  Base.ID := FNextTypeID; Inc(FNextTypeID);
  Base.Name := 'СВК';
  Base.Modification := 'СВК-15';
  Base.Manufacturer := 'Тепловодомер';
  Base.ReestrNumber := '38765-18';
  Base.Category := 5;
  Base.AccuracyClass := 'B';
  Base.ProcedureName := 'Поверка';
  Base.IVI := 6;
  Base.RegDate := EncodeDate(2018, 4, 1);
  Base.ValidityDate := EncodeDate(2024, 4, 1);
  FTypes.Add(Base);

  AddClone(Base, '38765-18', 5, 'СВК-20', 'C', EncodeDate(2020,4,1), EncodeDate(2026,4,1));
  AddClone(Base, '38765-18', -1,'',      'B', EncodeDate(2023,1,1), EncodeDate(2029,1,1));

  // =====================================================
  // ПРОЧИЕ / ТЕСТОВЫЕ
  // =====================================================
  Base := TDeviceType.Create;
  Base.ID := FNextTypeID; Inc(FNextTypeID);
  Base.Name := 'РМ';
  Base.Modification := 'РМ-10';
  Base.Manufacturer := 'Манотомь';
  Base.ReestrNumber := '55678-22';
  Base.Category := 4;
  Base.AccuracyClass := '±2.5';
  Base.ProcedureName := 'Поверка';
  Base.IVI := 3;
  Base.RegDate := EncodeDate(2022, 2, 2);
  Base.ValidityDate := EncodeDate(2025, 2, 2);
  FTypes.Add(Base);

  AddClone(Base, '55678-22', -1,'', '±2.5', EncodeDate(2021,2,2), EncodeDate(2024,2,2));

  Base := TDeviceType.Create;
  Base.ID := FNextTypeID; Inc(FNextTypeID);
  Base.Name := 'ТЕСТ-01';
  Base.Manufacturer := '';
  Base.Modification := '';
  Base.ReestrNumber := '00001-24';
  Base.Category := -1;
  Base.AccuracyClass := '±5';
  Base.ProcedureName := 'Тест';
  Base.IVI := 1;
  Base.RegDate := EncodeDate(2024,1,1);
  Base.ValidityDate := EncodeDate(2025,1,1);
  FTypes.Add(Base);

  AddClone(Base, '00001-24', -1,'', '±5', EncodeDate(2023,1,1), EncodeDate(2024,1,1));
  AddClone(Base, '00001-24', -1,'', '±5', EncodeDate(2025,1,1), EncodeDate(2026,1,1));
  AddClone(Base, '00001-24', -1,'', '±5', EncodeDate(2022,6,1), EncodeDate(2023,6,1));
  AddClone(Base, '00001-24', -1,'', '±5', EncodeDate(2026,6,1), EncodeDate(2027,6,1));
  AddClone(Base, '00001-24', -1,'', '±5', EncodeDate(2020,6,1), EncodeDate(2021,6,1));

  Result := FTypes;
end;

//
//function TTypeRepository.InitDiameters: TObjectList<TDiameter>;
//var
//  D: TDiameter;
//
//
//begin
//  //FDiameters.Clear;
////  FNextDiameterID := 1;
////
////  // =====================================================
////  // Типы 1–5 : ВЗЛЕТ ТЭР-М
////  // =====================================================
////  D.AddDiameterData(1, '15', 6.3, 0.063, 1000);
////  D.AddDiameterData(1, '25', 16.0, 0.16, 800);
////  D.AddDiameterData(1, '40', 40.0, 0.40, 600);
////
////  D.AddDiameterData(2, '15', 6.3, 0.063, 1100);
////  D.AddDiameterData(2, '25', 16.0, 0.16, 900);
////
////  D.AddDiameterData(3, '15', 6.3, 0.063, 1200);
////  D.AddDiameterData(3, '40', 40.0, 0.40, 600);
////
////  D.AddDiameterData(4, '20', 10.0, 0.10, 700);
////  D.AddDiameterData(4, '50', 60.0, 0.60, 500);
////
////  D.AddDiameterData(5, '15', 6.3, 0.063, 900);
////  D.AddDiameterData(5, '25', 16.0, 0.16, 700);
////
////  // =====================================================
////  // Типы 6–10 : ЭМИС-КОР
////  // =====================================================
////  D.AddDiameterData(6, '10', 3.0, 0.03, 1500);
////  D.AddDiameterData(6, '25', 16.0, 0.16, 900);
////  D.AddDiameterData(6, '50', 60.0, 0.60, 500);
////
////  D.AddDiameterData(7, '15', 6.3, 0.063, 1200);
////  D.AddDiameterData(7, '40', 40.0, 0.40, 700);
////
////  D.AddDiameterData(8, '20', 10.0, 0.10, 800);
////  D.AddDiameterData(8, '80', 120.0, 1.20, 400);
////
////  D.AddDiameterData(9, '15', 6.3, 0.063, 900);
////  D.AddDiameterData(9, '50', 60.0, 0.60, 450);
////
////  D.AddDiameterData(10, '25', 16.0, 0.16, 600);
////  D.AddDiameterData(10, '100', 160.0, 1.60, 300);
////
////  // =====================================================
////  // Типы 11–14 : ВИХРЬ-01
////  // =====================================================
////  D.AddDiameterData(11, '25', 25.0, 0.25, 700);
////  D.AddDiameterData(11, '100', 160.0, 1.60, 300);
////
////  D.AddDiameterData(12, '40', 40.0, 0.40, 600);
////  D.AddDiameterData(12, '150', 250.0, 2.50, 200);
////
////  D.AddDiameterData(13, 'DN500', 500.0, 5.0, 50);
////  D.AddDiameterData(13, 'DN1000', 1000.0, 10.0, 25);
////
////  D.AddDiameterData(14, '25', 25.0, 0.25, 700);
////  D.AddDiameterData(14, '80', 120.0, 1.20, 350);
////
////  // =====================================================
////  // Типы 15–17 : СВК (счётчики воды)
////  // =====================================================
////  D.AddDiameterData(15, '15', 3.0, 0.03, 400);
////  D.AddDiameterData(15, '20', 5.0, 0.05, 300);
////  D.AddDiameterData(15, '25', 7.0, 0.07, 250);
////
////  D.AddDiameterData(16, '20', 5.0, 0.05, 350);
////  D.AddDiameterData(16, '25', 7.0, 0.07, 300);
////
////  D.AddDiameterData(17, '15', 3.0, 0.03, 450);
////  D.AddDiameterData(17, '20', 5.0, 0.05, 320);
////
////  // =====================================================
////  // Типы 18–19 : РМ
////  // =====================================================
////  D.AddDiameterData(18, '10', 1.6, 0.016, 200);
////  D.AddDiameterData(18, '20', 4.0, 0.04, 150);
////
////  D.AddDiameterData(19, '10', 1.6, 0.016, 220);
////  D.AddDiameterData(19, '25', 6.3, 0.063, 120);
////
////  // =====================================================
////  // Типы 20–25 : ТЕСТ / ПРОЧИЕ
////  // =====================================================
////  D.AddDiameterData(20, '15', 5.0, 0.05, 100);
////  D.AddDiameterData(20, '25', 10.0, 0.10, 80);
////
////  D.AddDiameterData(21, '15', 5.0, 0.05, 100);
////  D.AddDiameterData(21, '25', 10.0, 0.10, 80);
////
////  D.AddDiameterData(22, '15', 5.0, 0.05, 100);
////  D.AddDiameterData(22, '25', 10.0, 0.10, 80);
////
////  D.AddDiameterData(23, '15', 5.0, 0.05, 100);
////  D.AddDiameterData(23, '25', 10.0, 0.10, 80);
////
////  D.AddDiameterData(24, '15', 5.0, 0.05, 100);
////  D.AddDiameterData(24, '25', 10.0, 0.10, 80);
////
////  D.AddDiameterData(25, '15', 5.0, 0.05, 100);
////  D.AddDiameterData(25, '25', 10.0, 0.10, 80);
//
//  Result := FDiameters;
//end;
//
//function TTypeRepository.InitPoints: TObjectList<TTypePoint>;
//var
//  P: TTypePoint;
//  TypeID: Integer;
//
//
//
//begin
//  FPoints.Clear;
//  FNextPointID := 1;
////
//  // =====================================================
//  // Для каждого типа: Qmin / Qnom / Qmax
//  // =====================================================
//  for TypeID := 1 to 25 do
//  begin
//    // --- Минимальный расход ---
//    AddPoint(
//      TypeID,
//      'Qmin',
//      'Минимальный расход',
//      0.10,
//      '±5%',
//      60,
//      10
//    );
//
//    // --- Номинальный расход ---
//    AddPoint(
//      TypeID,
//      'Qnom',
//      'Номинальный расход',
//      0.50,
//      '±2%',
//      30,
//      5
//    );
//
//    // --- Максимальный расход ---
//    AddPoint(
//      TypeID,
//      'Qmax',
//      'Максимальный расход',
//      1.00,
//      '±1%',
//      20,
//      5
//    );
//  end;
//
//  Result := FPoints;
//end;

procedure TTypeRepository.InitBulkTestData;
var
  ManIdx, TypeVarIdx, ModIdx, AccIdx, DevIdx: Integer;
  TypeObj: TDeviceType;
  DiamIdx: Integer;
  PointIdx: Integer;

  Manufacturer: string;
  TypeName: string;
  Modification: string;
  Accuracy: string;

  BaseRegDate: TDate;
  CategoryID: Integer;

  D: TDiameter;
  P: TTypePoint;
begin
  FTypes.Clear;
  //FDiameters.Clear;
 // FPoints.Clear;

  FNextTypeID := 1;
  FNextDiameterID := 1;
  FNextPointID := 1;

  BaseRegDate := EncodeDate(2020, 1, 1);
//
//  // =====================================================
//  // 20 ИЗГОТОВИТЕЛЕЙ
//  // =====================================================
//  for ManIdx := 1 to 20 do
//  begin
//    Manufacturer := Format('Изготовитель %d', [ManIdx]);
//
//    // =================================================
//    // 3–4 ВАРИАНТА ТИПОВ
//    // =================================================
//    for TypeVarIdx := 1 to 4 do
//    begin
//      TypeName := Format('Тип-%d-%d', [ManIdx, TypeVarIdx]);
//
//      // =================================================
//      // 50 МОДИФИКАЦИЙ
//      // =================================================
//      for ModIdx := 1 to 5 do
//      begin
//        Modification := Format('Мод-%02d', [ModIdx]);
//
//        // =================================================
//        // 2 КЛАССА ТОЧНОСТИ
//        // =================================================
//        for AccIdx := 0 to 1 do
//        begin
//          if AccIdx = 0 then
//            Accuracy := '±0.5'
//          else
//            Accuracy := '±1.0';
//
//          // =================================================
//          // 5 ПРИБОРОВ НА КОМБИНАЦИЮ
//          // =================================================
//          for DevIdx := 1 to 5 do
//          begin
//            CategoryID := (ManIdx mod 6) + 1;
//
//            // ---------- СОЗДАНИЕ ТИПА ----------
//            TypeObj := TDeviceType.Create;
//            TypeObj.ID := FNextTypeID;
//            Inc(FNextTypeID);
//
//            TypeObj.Name := TypeName;
//            TypeObj.Manufacturer := Manufacturer;
//            TypeObj.Modification := Modification;
//            TypeObj.AccuracyClass := Accuracy;
//            TypeObj.Category := CategoryID;
//            TypeObj.ReestrNumber := Format('%05d-%02d', [TypeObj.ID, ManIdx]);
//            TypeObj.ProcedureName := 'Поверка';
//            TypeObj.IVI := 4 + (DevIdx mod 3);
//            TypeObj.RegDate := IncYear(BaseRegDate, DevIdx);
//            TypeObj.ValidityDate := IncYear(TypeObj.RegDate, 4);
//
//            FTypes.Add(TypeObj);
//
//            // =================================================
//            // 8 ДИАМЕТРОВ НА ТИП
//            // =================================================
//            for DiamIdx := 1 to 8 do
//            begin
//              D := TDiameter.Create;
//              D.ID := GenerateDiameterID;
//              D.DeviceTypeID := TypeObj.ID;
//
//              D.DN := IntToStr(DiamIdx * 10);
//              D.Name := 'DN' + D.DN;
//
//              D.Qmax := DiamIdx * 10;
//              D.Qmin := D.Qmax / 100;
//              D.Kp := 1000 / DiamIdx;
//              D.QFmax := D.Qmax;
//
//              FDiameters.Add(D);
//            end;
//
//            // =================================================
//            // 5 ТОЧЕК НА ТИП
//            // =================================================
//            for PointIdx := 1 to 5 do
//            begin
//              P := TTypePoint.Create;
//              P.ID := GenerateTypePointID;
//              P.DeviceTypeID := TypeObj.ID;
//
//              case PointIdx of
//                1: begin P.Name := 'Qmin'; P.FlowRate := 0.10; end;
//                2: begin P.Name := 'Qlow'; P.FlowRate := 0.25; end;
//                3: begin P.Name := 'Qnom'; P.FlowRate := 0.50; end;
//                4: begin P.Name := 'Qhigh';P.FlowRate := 0.75; end;
//                5: begin P.Name := 'Qmax'; P.FlowRate := 1.00; end;
//              end;
//
//              P.Description := 'Автотест';
//              P.FlowAccuracy := '±2%';
//              P.Temp := 20;
//              P.Pressure := 0;
//              P.TempAccuracy := '0';
//
//              P.LimitTime := 30;
//              P.Pause := 10;
//              P.Error := 0.5;
//
//              P.RepeatsProtocol := 3;
//              P.Repeats := 5;
//
//              FPoints.Add(P);
//            end;
//          end;
//        end;
//      end;
//    end;
//  end;
end;



function TTypeRepository.InitCategories: TObjectList<TDeviceCategory>;
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
  FCategories.Clear;

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
  // 0 — Расходомер электромагнитный
  // =================================================
  AddCategory(
    0,
    '<не указана>',
    mdVolume,
    otImpulse,
    ''
  );
  // =================================================
  // 0 — Расходомер электромагнитный
  // =================================================
  AddCategory(
    1,
    'Расходомер электромагнитный',
    mdVolume,
    otImpulse,
    'электромагнитн;магнитн'
  );

  // =================================================
  // 1 — Расходомер кориолисовый
  // =================================================
  AddCategory(
    2,
    'Расходомер кориолисовый',
    mdMass,
    otImpulse,
    'кориолис'
  );

  // =================================================
  // 2 — Расходомер вихревой
  // =================================================
  AddCategory(
    3,
    'Расходомер вихревой',
    mdVolume,
    otFrequency,
    'вихр'
  );

  // =================================================
  // 3 — Расходомер механический
  // =================================================
  AddCategory(
    4,
    'Расходомер механический',
    mdVolume,
    otImpulse,
    'механич;турбин;крыльчат'
  );

  // =================================================
  // 4 — Расходомер ультразвуковой
  // =================================================
  AddCategory(
    5,
    'Расходомер ультразвуковой',
    mdVolume,
    otImpulse,
    'ультразв'
  );

  // =================================================
  // 5 — Счётчик воды механический
  // =================================================
  AddCategory(
    6,
    'Счётчик воды механический',
    mdVolume,
    otImpulse,
    'счётчик воды;водосчётчик;водомер'
  );

  // =================================================
  // 6 — Скоростомер
  // =================================================
  AddCategory(
    7,
    'Скоростомер',
    mdSpeed,
    otFrequency,
    'скорост'
  );

  // =================================================
  // 7 — Теплосчетчик
  // =================================================
  AddCategory(
    8,
    'Теплосчетчик',
    mdMass,
    otInterface,
    'теплосчетчик;теплосчётчик;теплов'
  );

  // =================================================
  // 8 — Ротаметр
  // =================================================
  AddCategory(
    9,
    'Ротаметр',
    mdVolume,
    otVisual,
    'ротаметр'
  );

  // =================================================
  // 9 — Емкость (мерник)
  // =================================================
  AddCategory(
    10,
    'Емкость (мерник)',
    mdVolume,
    otVisual,
    'емкост;мерник;бак;резервуар'
  );

  // =================================================
  // 10 — Весы
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

procedure TTypeRepository.Init;
begin
  {====================================================}
  { Очистка всех хранилищ }
  {====================================================}
  FTypes.Clear;
 // FDiameters.Clear;
  //FPoints.Clear;
  FCategories.Clear;

  {====================================================}
  { Сброс генераторов ID }
  {====================================================}
  FNextTypeID := 1;
  FNextDiameterID := 1;
  FNextPointID := 1;

  {====================================================}
  { Инициализация справочников }
  {====================================================}
  InitCategories;

  {====================================================}
  { Инициализация основных сущностей }
  {====================================================}
  InitTypes;
  //InitDiameters;
 // InitPoints;
end;


      {$ENDREGION}

 {$REGION 'Types'}


function TTypeRepository.GenerateTypeID: Integer;
var
  T: TDeviceType;
  MaxID: Integer;
begin
  MaxID := 0;

  if (FTypes <> nil)  then
    for T in FTypes do
      if T.ID > MaxID then
        MaxID := T.ID;

  Result := MaxID + 1;
end;

function TTypeRepository.GetType(ATypeID: Integer): TDeviceType;
var
  T: TDeviceType;
begin
  Result := nil;

  if (ATypeID <= 0) or (FTypes = nil) then
    Exit;

  for T in FTypes do
    if T.ID = ATypeID then
      Exit(T);
end;

procedure TTypeRepository.DeleteType(AType: TDeviceType);
var
  I: Integer;
  TypeID: Integer;
begin
  if (AType = nil) or (FDM = nil) then
    Exit;

  TypeID := AType.ID;

  {----------------------------------}
  { Точки — помечаем на удаление }
  {----------------------------------}
  if AType.Points <> nil then
  begin
    for I := 0 to AType.Points.Count - 1 do
      if AType.Points[I].DeviceTypeID = TypeID then
        AType.Points[I].State := osDeleted;
  end;

  {----------------------------------}
  { Диаметры — помечаем на удаление }
  {----------------------------------}
  if AType.Diameters <> nil then
  begin
    for I := 0 to AType.Diameters.Count - 1 do
      if AType.Diameters[I].DeviceTypeID = TypeID then
        AType.Diameters[I].State := osDeleted;
  end;

  {----------------------------------}
  { Сам тип — удаляем СРАЗУ из БД }
  {----------------------------------}
  case AType.State of

    osNew:
      begin
        // тип ещё не был сохранён — просто убираем из памяти
        if FTypes <> nil then
          FTypes.Remove(AType);
      end;

  else
    begin
      // тип есть в БД — помечаем и удаляем штатным способом
      AType.State := osDeleted;

      if not UpdateType(AType) then
        raise Exception.Create('Ошибка удаления типа из БД');

      if FTypes <> nil then
        FTypes.Remove(AType);
    end;

  end;

  {----------------------------------}
  { Репозиторий изменён }
  {----------------------------------}
  FState := osModified;
end;

function TTypeRepository.CreateNewType: TDeviceType;
begin
  State := osModified;

  Result := TDeviceType.Create;
  Result.ID := GenerateTypeID;

  { 🔗 привязываем репозиторий }
  Result.RepoName := Self.Name;
  FTypes.Add(Result);
end;

function TTypeRepository.CreateType(AType: TDeviceType): TDeviceType;
var
  D: TDiameter;
  P: TTypePoint;
begin
  Result := CreateNewType;
  if AType = nil then
    Exit;

  // копируем ВСЕ поля
  Result.Assign(AType);

  { Новый объект должен быть новым для БД }
  Result.ID := GenerateTypeID;
  Result.State := osNew;

  { Дочерние сущности привязываем к новому типу и помечаем как новые }
  if Result.Diameters <> nil then
    for D in Result.Diameters do
    begin
      D.ID := 0;
      D.DeviceTypeID := Result.ID;
      D.State := osNew;
    end;

  if Result.Points <> nil then
    for P in Result.Points do
    begin
      P.ID := 0;
      P.DeviceTypeID := Result.ID;
      P.State := osNew;
    end;
end;

function TTypeRepository.CreateType(ATypeID: Integer): TDeviceType;
var
  Src: TDeviceType;
  D: TDiameter;
  P: TTypePoint;
begin
  { если индекс невалидный — просто новый тип }
  if (ATypeID < 0) or (ATypeID >= FTypes.Count) then
    Exit(CreateNewType);

  Src := FTypes[ATypeID];
  if Src = nil then
    Exit(CreateNewType);

  { создаём новый тип }
  Result := CreateNewType;

  { копируем ВСЕ поля }
  Result.Assign(Src);

  { гарантируем уникальность и корректное состояние для сохранения }
  Result.ID := GenerateTypeID;
  Result.State := osNew;

  if Result.Diameters <> nil then
    for D in Result.Diameters do
    begin
      D.ID := 0;
      D.DeviceTypeID := Result.ID;
      D.State := osNew;
    end;

  if Result.Points <> nil then
    for P in Result.Points do
    begin
      P.ID := 0;
      P.DeviceTypeID := Result.ID;
      P.State := osNew;
    end;
end;

function TTypeRepository.CategoryToText(
  ACategory: Integer;
  const ACategoryName: string
): string;
var
  C: TDeviceCategory;
begin
  // --------------------------------------------------
  // -1 → пользовательская категория (CategoryName)
  // --------------------------------------------------
  if ACategory = -1 then
  begin
    if Trim(ACategoryName) <> '' then
      Exit(ACategoryName)
    else
      Exit('<категория>');
  end;

  // --------------------------------------------------
  // 0 → категория не выбрана
  // --------------------------------------------------
  if ACategory = 0 then
    Exit('<категория>');

  // --------------------------------------------------
  // > 0 → ищем в справочнике
  // --------------------------------------------------
  for C in FCategories do
    if C.ID = ACategory then
      Exit(C.Name);

  // --------------------------------------------------
  // не найдено
  // --------------------------------------------------
  Result := 'Неизвестная категория';
end;




 // БД
function TTypeRepository.RequiredTypeColumns: TTableColumns;

begin
   Result := [
    Col('ID', 'INTEGER PRIMARY KEY AUTOINCREMENT'),
    Col('MitUUID', 'TEXT'),

    Col('Name', 'TEXT NOT NULL'),
    Col('Modification', 'TEXT'),
    Col('Manufacturer', 'TEXT'),
    Col('ReestrNumber', 'TEXT'),

    Col('Category', 'INTEGER'),
    Col('CategoryName', 'TEXT'),

    Col('AccuracyClass', 'TEXT'),

    Col('RegDate', 'DATE'),
    Col('ValidityDate', 'DATE'),

    Col('IVI', 'INTEGER'),
    Col('RangeDynamic', 'REAL'),

    Col('VerificationMethod', 'TEXT'),
    Col('ProcedureName', 'TEXT'),

    Col('ProcedureCmd1', 'TEXT'),
    Col('ProcedureCmd2', 'TEXT'),
    Col('ProcedureCmd3', 'TEXT'),
    Col('ProcedureCmd4', 'TEXT'),
    Col('ProcedureCmd5', 'TEXT'),

    Col('Description', 'TEXT'),
    Col('Documentation', 'TEXT'),
    Col('ReportingForm', 'TEXT'),
    Col('SerialNumTemplate', 'TEXT'),

    Col('MeasuredDimension', 'INTEGER'),
    Col('OutputType', 'INTEGER'),
    Col('DimensionCoef', 'INTEGER'),

    Col('OutputSet', 'INTEGER'),
    Col('Freq', 'REAL'),
    Col('Coef', 'REAL'),
    Col('FreqFlowRate', 'REAL'),

    Col('VoltageRange', 'INTEGER'),
    Col('VoltageQminRate', 'REAL'),
    Col('VoltageQmaxRate', 'REAL'),

    Col('CurrentRange', 'INTEGER'),
    Col('CurrentQminRate', 'REAL'),
    Col('CurrentQmaxRate', 'REAL'),
    Col('IntegrationTime', 'INTEGER'),

    Col('ProtocolName', 'TEXT'),
    Col('BaudRate', 'INTEGER'),
    Col('Parity', 'INTEGER'),
    Col('DeviceAddress', 'INTEGER'),

    Col('InputType', 'INTEGER'),
    Col('SpillageType', 'INTEGER'),
    Col('SpillageStop', 'INTEGER'),

    Col('Repeats', 'INTEGER'),
    Col('RepeatsProtocol', 'INTEGER'),

    Col('Error', 'REAL')
  ];
end;
procedure TTypeRepository.EnsureTypeSchema;
begin
  FDM.EnsureTable('DeviceType', RequiredTypeColumns);
end;
procedure TTypeRepository.AssertTypeSchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('DeviceType');
  Missing := TStringList.Create;
  try
    Cols := RequiredTypeColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с DeviceType.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

function TTypeRepository.MapTypeFromQuery(Q: TFDQuery): TDeviceType;
begin
  Result := CreateNewType;

  Result.ID := Q.FieldByName('ID').AsInteger;
  Result.MitUUID := Q.FieldByName('MitUUID').AsString;

  Result.Name := Q.FieldByName('Name').AsString;
  Result.Modification := Q.FieldByName('Modification').AsString;
  Result.Manufacturer := Q.FieldByName('Manufacturer').AsString;
  Result.ReestrNumber := Q.FieldByName('ReestrNumber').AsString;

  Result.Category := Q.FieldByName('Category').AsInteger;
  Result.CategoryName := Q.FieldByName('CategoryName').AsString;

  Result.AccuracyClass := Q.FieldByName('AccuracyClass').AsString;

  if not Q.FieldByName('RegDate').IsNull then
    Result.RegDate := Q.FieldByName('RegDate').AsDateTime;

  if not Q.FieldByName('ValidityDate').IsNull then
    Result.ValidityDate := Q.FieldByName('ValidityDate').AsDateTime;

  Result.IVI := Q.FieldByName('IVI').AsInteger;
  Result.RangeDynamic := Q.FieldByName('RangeDynamic').AsFloat;

  Result.VerificationMethod := Q.FieldByName('VerificationMethod').AsString;
  Result.ProcedureName := Q.FieldByName('ProcedureName').AsString;

  Result.ProcedureCmd1 := Q.FieldByName('ProcedureCmd1').AsString;
  Result.ProcedureCmd2 := Q.FieldByName('ProcedureCmd2').AsString;
  Result.ProcedureCmd3 := Q.FieldByName('ProcedureCmd3').AsString;
  Result.ProcedureCmd4 := Q.FieldByName('ProcedureCmd4').AsString;
  Result.ProcedureCmd5 := Q.FieldByName('ProcedureCmd5').AsString;

  Result.Description := Q.FieldByName('Description').AsString;
  Result.Documentation := Q.FieldByName('Documentation').AsString;
  Result.ReportingForm := Q.FieldByName('ReportingForm').AsString;
  Result.SerialNumTemplate := Q.FieldByName('SerialNumTemplate').AsString;

  Result.DimensionCoef := Q.FieldByName('DimensionCoef').AsInteger;

  Result.OutputSet := Q.FieldByName('OutputSet').AsInteger;
  Result.Freq := Q.FieldByName('Freq').AsInteger;
  Result.Coef := Q.FieldByName('Coef').AsFloat;
  Result.FreqFlowRate := Q.FieldByName('FreqFlowRate').AsFloat;

  Result.VoltageRange := Q.FieldByName('VoltageRange').AsInteger;
  Result.VoltageQminRate := Q.FieldByName('VoltageQminRate').AsFloat;
  Result.VoltageQmaxRate := Q.FieldByName('VoltageQmaxRate').AsFloat;

  Result.CurrentRange := Q.FieldByName('CurrentRange').AsInteger;
  Result.CurrentQminRate := Q.FieldByName('CurrentQminRate').AsFloat;
  Result.CurrentQmaxRate := Q.FieldByName('CurrentQmaxRate').AsFloat;
  Result.IntegrationTime := Q.FieldByName('IntegrationTime').AsInteger;

  Result.ProtocolName := Q.FieldByName('ProtocolName').AsString;
  Result.BaudRate := Q.FieldByName('BaudRate').AsInteger;
  Result.Parity := Q.FieldByName('Parity').AsInteger;
  Result.DeviceAddress := Q.FieldByName('DeviceAddress').AsInteger;

  Result.InputType := Q.FieldByName('InputType').AsInteger;
  Result.SpillageType := Q.FieldByName('SpillageType').AsInteger;
  Result.SpillageStop := Q.FieldByName('SpillageStop').AsInteger;
  Result.Repeats := Q.FieldByName('Repeats').AsInteger;
  Result.RepeatsProtocol := Q.FieldByName('RepeatsProtocol').AsInteger;
  Result.Error := Q.FieldByName('Error').AsFloat;

  Result.State := osClean;
end;

function TTypeRepository.LoadType(ATypeID: Integer): TDeviceType;
var
  Q: TFDQuery;
begin
  Result := nil;

  if (ATypeID <= 0) or (FDM = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    Q.SQL.Text := 'select * from DeviceType where ID = :ID';
    SetIntParam(Q, 'ID', ATypeID);
    Q.Open;

    if not Q.Eof then
    begin
      Result := MapTypeFromQuery(Q);

      { зависимые данные — ВНУТРИ типа }
      LoadDiametersByType(Result.ID);
      LoadTypePointsByType(Result.ID);
    end;
  finally
    Q.Free;
  end;
end;

function TTypeRepository.LoadTypes: Boolean;
var
  Q: TFDQuery;
  NewT: TDeviceType;
  TypeID: Integer;
begin
  Result := False;

  if FDM = nil then
    Exit;

  FState := osLoading;

  { пересоздаём список типов }
  FreeAndNil(FTypes);
  FTypes := TObjectList<TDeviceType>.Create(True);

  Q := FDM.CreateQuery;
  try
    try
      { получаем ТОЛЬКО ID }
      Q.SQL.Text :=
        'select ID from DeviceType order by Name';
      Q.Open;

      while not Q.Eof do
      begin
        TypeID := Q.FieldByName('ID').AsInteger;

        { загрузка агрегата }
        NewT := LoadType(TypeID);
        Q.Next;
      end;

      FState := osClean;
      Result := True;

    except
      FState := osError;
      raise;
    end;
  finally
    Q.Free;
  end;
end;
//
//function TTypeRepository.SaveType(
//  AType: TDeviceType;
//  ACheckExists: Boolean
//): Boolean;
//
//var
//  Exists: Boolean;
//  Q: TFDQuery;
//begin
//  Result := False;
//
//  if (AType = nil) or (FDM = nil) then
//    Exit;
//
//  // ---------------------------------------------------
//  // Если состояние уже задано — просто сохраняем
//  // ---------------------------------------------------
//  if AType.State <> osClean then
//    Exit(UpdateType(AType));
//
//  // ---------------------------------------------------
//  // Если состояние неизвестно — определяем его
//  // ---------------------------------------------------
//  Exists := False;
//
//  if ACheckExists and (AType.ID > 0) then
//  begin
//    Q := FDM.CreateQuery;
//    try
//      Q.SQL.Text := 'select 1 from DeviceType where ID = :ID';
//      Q.ParamByName('ID').AsInteger := AType.ID;
//      Q.Open;
//      Exists := not Q.Eof;
//    finally
//      Q.Free;
//    end;
//  end;
//
//  // ---------------------------------------------------
//  // Назначаем состояние
//  // ---------------------------------------------------
//  if Exists then
//    AType.State := osModified
//  else
//    AType.State := osNew;
//
//  Result := UpdateType(AType);
//end;
//
function TTypeRepository.SaveTypes: Boolean;
var
  T: TDeviceType;
begin
  Result := False;

  if (FDM = nil) or (FTypes = nil) then
    Exit;

  FDM.TypesConnection.StartTransaction;
  try

    for T in FTypes do
      if not UpdateType(T) then
        raise Exception.Create('Ошибка сохранения типа');

    FDM.TypesConnection.Commit;
    Result := True;

  except
    FDM.TypesConnection.Rollback;
    raise;
  end;
end;

function TTypeRepository.RebuildTypes: Boolean;
var
  Q: TFDQuery;
  T: TDeviceType;
begin
  Result := False;

  if (FDM = nil) or (FTypes = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    FDM.TypesConnection.StartTransaction;
    try
      // -------------------------------------------------
      // 1. Полная очистка таблицы
      // -------------------------------------------------
      Q.SQL.Text := 'delete from DeviceType';
      Q.ExecSQL;

      // Если используется генератор / identity — можно сбросить
      // (раскомментировать при необходимости)
      // Q.SQL.Text := 'alter sequence DeviceType_ID restart with 1';
      // Q.ExecSQL;

      // -------------------------------------------------
      // 2. Массовая запись
      // -------------------------------------------------
      for T in FTypes do
      begin
        T.State := osNew;

        if not UpdateType(T) then
          raise Exception.CreateFmt(
            'Ошибка пересборки DeviceType "%s"',
            [T.Name]
          );
      end;

      FDM.TypesConnection.Commit;
      Result := True;

    except
      FDM.TypesConnection.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

function TTypeRepository.UpdateType(AType: TDeviceType): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (AType = nil) or (FDM = nil) then
    Exit;

  if AType.State = osClean then
    Exit(True);

  { защита: новый тип обязан иметь ID }
  if (AType.State = osNew) and (AType.ID <= 0) then
    raise Exception.Create('New type must have predefined ID');

  Q := FDM.CreateQuery;
  try
    case AType.State of

      {==================================================}
      { DELETE — ЖЁСТКИЙ КАСКАД }
      {==================================================}
      osDeleted:
        begin
          { точки типа }
          Q.SQL.Text :=
            'delete from DeviceTypePoint where DeviceTypeID = :ID';
          SetIntParam(Q, 'ID', AType.ID);
          Q.ExecSQL;

          { диаметры }
          Q.SQL.Text :=
            'delete from DeviceDiameter where DeviceTypeID = :ID';
          SetIntParam(Q, 'ID', AType.ID);
          Q.ExecSQL;

          { сам тип }
          Q.SQL.Text :=
            'delete from DeviceType where ID = :ID';
          SetIntParam(Q, 'ID', AType.ID);
          Q.ExecSQL;

          AType.State := osClean;
          Result := True;
          Exit;
        end;

      {==================================================}
      { INSERT }
      {==================================================}
      osNew:
        Q.SQL.Text :=
          'insert into DeviceType (' +
          'ID, MitUUID, Name, Modification, Manufacturer, ReestrNumber, ' +
          'Category, CategoryName, AccuracyClass, ' +
          'RegDate, ValidityDate, IVI, RangeDynamic, ' +
          'VerificationMethod, ProcedureName, ' +
          'ProcedureCmd1, ProcedureCmd2, ProcedureCmd3, ProcedureCmd4, ProcedureCmd5, ' +
          'Description, Documentation, ReportingForm, SerialNumTemplate, ' +
          'MeasuredDimension, OutputType, DimensionCoef, ' +
          'OutputSet, Freq, Coef, FreqFlowRate, ' +
          'VoltageRange, VoltageQminRate, VoltageQmaxRate, ' +
          'CurrentRange, CurrentQminRate, CurrentQmaxRate, IntegrationTime, ' +
          'ProtocolName, BaudRate, Parity, DeviceAddress, ' +
          'InputType, SpillageType, SpillageStop, Repeats, RepeatsProtocol, Error' +
          ') values (' +
          ':ID, :MitUUID, :Name, :Modification, :Manufacturer, :ReestrNumber, ' +
          ':Category, :CategoryName, :AccuracyClass, ' +
          ':RegDate, :ValidityDate, :IVI, :RangeDynamic, ' +
          ':VerificationMethod, :ProcedureName, ' +
          ':ProcedureCmd1, :ProcedureCmd2, :ProcedureCmd3, :ProcedureCmd4, :ProcedureCmd5, ' +
          ':Description, :Documentation, :ReportingForm, :SerialNumTemplate, ' +
          ':MeasuredDimension, :OutputType, :DimensionCoef, ' +
          ':OutputSet, :Freq, :Coef, :FreqFlowRate, ' +
          ':VoltageRange, :VoltageQminRate, :VoltageQmaxRate, ' +
          ':CurrentRange, :CurrentQminRate, :CurrentQmaxRate, :IntegrationTime, ' +
          ':ProtocolName, :BaudRate, :Parity, :DeviceAddress, ' +
          ':InputType, :SpillageType, :SpillageStop, :Repeats, :RepeatsProtocol, :Error' +
          ')';

      {==================================================}
      { UPDATE }
      {==================================================}
      osModified:
        Q.SQL.Text :=
          'update DeviceType set ' +
          'MitUUID=:MitUUID, Name=:Name, Modification=:Modification, Manufacturer=:Manufacturer, ReestrNumber=:ReestrNumber, ' +
          'Category=:Category, CategoryName=:CategoryName, AccuracyClass=:AccuracyClass, ' +
          'RegDate=:RegDate, ValidityDate=:ValidityDate, IVI=:IVI, RangeDynamic=:RangeDynamic, ' +
          'VerificationMethod=:VerificationMethod, ProcedureName=:ProcedureName, ' +
          'ProcedureCmd1=:ProcedureCmd1, ProcedureCmd2=:ProcedureCmd2, ProcedureCmd3=:ProcedureCmd3, ' +
          'ProcedureCmd4=:ProcedureCmd4, ProcedureCmd5=:ProcedureCmd5, ' +
          'Description=:Description, Documentation=:Documentation, ReportingForm=:ReportingForm, SerialNumTemplate=:SerialNumTemplate, ' +
          'MeasuredDimension=:MeasuredDimension, OutputType=:OutputType, DimensionCoef=:DimensionCoef, ' +
          'OutputSet=:OutputSet, Freq=:Freq, Coef=:Coef, FreqFlowRate=:FreqFlowRate, ' +
          'VoltageRange=:VoltageRange, VoltageQminRate=:VoltageQminRate, VoltageQmaxRate=:VoltageQmaxRate, ' +
          'CurrentRange=:CurrentRange, CurrentQminRate=:CurrentQminRate, CurrentQmaxRate=:CurrentQmaxRate, IntegrationTime=:IntegrationTime, ' +
          'ProtocolName=:ProtocolName, BaudRate=:BaudRate, Parity=:Parity, DeviceAddress=:DeviceAddress, ' +
          'InputType=:InputType, SpillageType=:SpillageType, SpillageStop=:SpillageStop, ' +
          'Repeats=:Repeats, RepeatsProtocol=:RepeatsProtocol, Error=:Error ' +
          'where ID=:ID';
    end;

    {---------------- ПАРАМЕТРЫ ----------------}
    SetIntParam(Q, 'ID', AType.ID);
    SetStrParam(Q, 'MitUUID', AType.MitUUID);
    SetStrParam(Q, 'Name', AType.Name);
    SetStrParam(Q, 'Modification', AType.Modification);
    SetStrParam(Q, 'Manufacturer', AType.Manufacturer);
    SetStrParam(Q, 'ReestrNumber', AType.ReestrNumber);

    SetIntParam(Q, 'Category', AType.Category);
    SetStrParam(Q, 'CategoryName', AType.CategoryName);
    SetStrParam(Q, 'AccuracyClass', AType.AccuracyClass);

    SetDateParam(Q, 'RegDate', AType.RegDate);
    SetDateParam(Q, 'ValidityDate', AType.ValidityDate);

    SetIntParam(Q, 'IVI', AType.IVI);
    SetFloatParam(Q, 'RangeDynamic', AType.RangeDynamic);

    SetStrParam(Q, 'VerificationMethod', AType.VerificationMethod);
    SetStrParam(Q, 'ProcedureName', AType.ProcedureName);

    SetStrParam(Q, 'ProcedureCmd1', AType.ProcedureCmd1);
    SetStrParam(Q, 'ProcedureCmd2', AType.ProcedureCmd2);
    SetStrParam(Q, 'ProcedureCmd3', AType.ProcedureCmd3);
    SetStrParam(Q, 'ProcedureCmd4', AType.ProcedureCmd4);
    SetStrParam(Q, 'ProcedureCmd5', AType.ProcedureCmd5);

    SetStrParam(Q, 'Description', AType.Description);
    SetStrParam(Q, 'Documentation', AType.Documentation);
    SetStrParam(Q, 'ReportingForm', AType.ReportingForm);
    SetStrParam(Q, 'SerialNumTemplate', AType.SerialNumTemplate);

    SetIntParam(Q, 'MeasuredDimension', Ord(AType.MeasuredDimension));
    SetIntParam(Q, 'OutputType', Ord(AType.OutputType));
    SetIntParam(Q, 'DimensionCoef', AType.DimensionCoef);

    SetIntParam(Q, 'OutputSet', AType.OutputSet);
    SetFloatParam(Q, 'Freq', AType.Freq);
    SetFloatParam(Q, 'Coef', AType.Coef);
    SetFloatParam(Q, 'FreqFlowRate', AType.FreqFlowRate);

    SetIntParam(Q, 'VoltageRange', AType.VoltageRange);
    SetFloatParam(Q, 'VoltageQminRate', AType.VoltageQminRate);
    SetFloatParam(Q, 'VoltageQmaxRate', AType.VoltageQmaxRate);

    SetIntParam(Q, 'CurrentRange', AType.CurrentRange);
    SetFloatParam(Q, 'CurrentQminRate', AType.CurrentQminRate);
    SetFloatParam(Q, 'CurrentQmaxRate', AType.CurrentQmaxRate);
    SetIntParam(Q, 'IntegrationTime', AType.IntegrationTime);

    SetStrParam(Q, 'ProtocolName', AType.ProtocolName);
    SetIntParam(Q, 'BaudRate', AType.BaudRate);
    SetIntParam(Q, 'Parity', AType.Parity);
    SetIntParam(Q, 'DeviceAddress', AType.DeviceAddress);

    SetIntParam(Q, 'InputType', AType.InputType);
    SetIntParam(Q, 'SpillageType', AType.SpillageType);
    SetIntParam(Q, 'SpillageStop', AType.SpillageStop);
    SetIntParam(Q, 'Repeats', AType.Repeats);
    SetIntParam(Q, 'RepeatsProtocol', AType.RepeatsProtocol);
    SetFloatParam(Q, 'Error', AType.Error);

    Q.ExecSQL;

    {================ ДОЧЕРНИЕ СУЩНОСТИ =================}
    if AType.Diameters <> nil then
      if not UpdateDiameters(AType) then
        Exit(False);

    if AType.Points <> nil then
      if not UpdateTypePoints(AType) then
        Exit(False);

    AType.State := osClean;
    Result := True;

  finally
    Q.Free;
  end;
end;

function TTypeRepository.SaveType(
  AType: TDeviceType
): Boolean;
begin
  Result := False;

  if (AType = nil) or (FDM = nil) then
    Exit;

  { базовая защита }
  if AType.ID <= 0 then
    raise Exception.CreateFmt(
      'Type with invalid ID detected (ID=%d)',
      [AType.ID]
    );

  FDM.TypesConnection.StartTransaction;
  try
    if not UpdateType(AType) then
      raise Exception.Create('Ошибка сохранения типа');

    FDM.TypesConnection.Commit;

    Result := True;

  except
    FDM.TypesConnection.Rollback;
    raise;
  end;
end;

function TTypeRepository.FindTypeByID(
  const AID: Integer
): TDeviceType;
var
  T: TDeviceType;
begin
  Result := nil;

  if AID <= 0 then
    Exit;

  for T in FTypes do
    if T.ID = AID then
      Exit(T);
end;


function TTypeRepository.FindTypeByUUID(
  const AUUID: string
): TDeviceType;
var
  T: TDeviceType;
begin
  Result := nil;

  if AUUID = '' then
    Exit;

  for T in FTypes do
    if SameText(T.MitUUID, AUUID) then
      Exit(T);
end;

function TTypeRepository.FindTypeByName(
  const AName: string
): TDeviceType;
var
  T: TDeviceType;
begin
  Result := nil;

  if AName = '' then
    Exit;

  for T in FTypes do
    if SameText(T.Name, AName) then
      Exit(T);
end;


    {$ENDREGION}

 {$REGION 'Diametrs'}




//
//function TTypeRepository.GetDiameters(
//  AType: TDeviceType
//): TObjectList<TDiameter>;
//var
//  D: TDiameter;
//begin
//  Result := TObjectList<TDiameter>.Create(False);
//
//  if (AType = nil) or (FDiameters = nil) then
//    Exit;
//
//  for D in FDiameters do
//    if D.DeviceTypeID = AType.ID then
//      Result.Add(D);
//end;
//
//function TTypeRepository.SetDiameters(
//  AType: TDeviceType;
//  ADiameters: TObjectList<TDiameter>
//): Boolean;
//var
//  I: Integer;
//  D: TDiameter;
//begin
//  Result := False;
//
//  if (AType = nil) or (FDiameters = nil) or (ADiameters = nil) then
//    Exit;
//
//  // 1. Удаляем старые диаметры этого типа
//  for I := FDiameters.Count - 1 downto 0 do
//    if FDiameters[I].DeviceTypeID = AType.ID then
//      FDiameters.Delete(I); // объект освобождается
//
//  // 2. Добавляем новые
//  for D in ADiameters do
//  begin
//    D.DeviceTypeID := AType.ID;
//    FDiameters.Add(D);
//  end;
//
//  Result := True;
//end;
//
//
//function TTypeRepository.LoadDiameters: Boolean;
//var
//  T: TDeviceType;
//  L: TObjectList<TDiameter>;
//  D: TDiameter;
//begin
//  Result := False;
//
//  {----------------------------------}
//  { Проверка исходных данных }
//  {----------------------------------}
//  if (FDM = nil) or (FTypes = nil) then
//    Exit;
//
//  FState := osLoading;
//
//  {----------------------------------}
//  { Пересоздаём хранилище }
//  {----------------------------------}
//  FreeAndNil(FDiameters);
//  FDiameters := TObjectList<TDiameter>.Create(True);
//
//  try
//    for T in FTypes do
//    begin
//      L := LoadDiametersByType(T.ID);
//      try
//        if L <> nil then
//        begin
//          for D in L do
//            FDiameters.Add(D);
//
//          // передаём владение объектами основному списку
//          L.OwnsObjects := False;
//        end;
//      finally
//        L.Free;
//      end;
//    end;
//
//    {----------------------------------}
//    { Успешная загрузка }
//    {----------------------------------}
//    FState := osClean;
//    Result := True;
//
//  except
//    FState := osError;
//    Result := False;
//    raise;
//  end;
//end;
//

  /// БД
function TTypeRepository.RequiredDiameterColumns: TTableColumns;
begin
  Result := [
    Col('ID', 'INTEGER PRIMARY KEY AUTOINCREMENT'),
    Col('DeviceTypeID', 'INTEGER'),

    Col('Name', 'TEXT'),
    Col('DN', 'TEXT'),
    Col('Description', 'TEXT'),

    Col('Qmax', 'REAL'),
    Col('Qmin', 'REAL'),

    Col('Kp', 'REAL'),
    Col('QFmax', 'REAL'),

    Col('Vmax', 'REAL'),
    Col('Vmin', 'REAL')
  ];
end;
procedure TTypeRepository.EnsureDiameterSchema;
begin
  FDM.EnsureTable('DeviceDiameter', RequiredDiameterColumns);
end;
procedure TTypeRepository.AssertDiameterSchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('DeviceDiameter');
  Missing := TStringList.Create;
  try
    Cols := RequiredDiameterColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с DeviceDiameter.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

 function TTypeRepository.MapDiameterFromQuery(Q: TFDQuery): TDiameter;
  var
     ADeviceTypeID: Integer;
     AType: TDeviceType;
 begin

  ADeviceTypeID := Q.FieldByName('DeviceTypeID').AsInteger;

  AType:= FindTypeByID(ADeviceTypeID);

  Result := AType.AddDiameter;

  Result.ID := Q.FieldByName('ID').AsInteger;

  Result.Name := Q.FieldByName('Name').AsString;
  Result.DN := Q.FieldByName('DN').AsString;
  Result.Description := Q.FieldByName('Description').AsString;

  Result.Qmax := Q.FieldByName('Qmax').AsFloat;
  Result.Qmin := Q.FieldByName('Qmin').AsFloat;

  Result.Kp := Q.FieldByName('Kp').AsFloat;
  Result.QFmax := Q.FieldByName('QFmax').AsFloat;

  Result.Vmax := Q.FieldByName('Vmax').AsFloat;
  Result.Vmin := Q.FieldByName('Vmin').AsFloat;

  Result.State := osClean;
end;

function TTypeRepository.LoadDiametersByType(ATypeID: Integer): TObjectList<TDiameter>;
var
  Q: TFDQuery;
begin
  Result := TObjectList<TDiameter>.Create(True);

  if (ATypeID <= 0) or (FDM = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    Q.SQL.Text :=
      'select * from DeviceDiameter ' +
      'where DeviceTypeID = :ID ' +
      'order by ID';

    SetIntParam(Q, 'ID', ATypeID);
    Q.Open;

    while not Q.Eof do
    begin
      Result.Add(MapDiameterFromQuery(Q));
      Q.Next;
    end;

  finally
    Q.Free;
  end;
end;

function TTypeRepository.UpdateDiameter(
  ADiameter: TDiameter
): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (ADiameter = nil) or (FDM = nil) then
    Exit;

  if ADiameter.State = osClean then
    Exit(True);

  { защита: диаметр обязан принадлежать типу }
  if ADiameter.DeviceTypeID <= 0 then
    raise Exception.Create('Diameter must have valid DeviceTypeID');

  Q := FDM.CreateQuery;
  try
    case ADiameter.State of

      {======================= DELETE =======================}
      osDeleted:
        begin
          if ADiameter.ID <= 0 then
            Exit(True);

          Q.SQL.Text :=
            'delete from DeviceDiameter where ID = :ID';

          SetIntParam(Q, 'ID', ADiameter.ID);
          Q.ExecSQL;
          Exit(True);
        end;

      {======================= INSERT =======================}
      osNew:
        begin
          Q.SQL.Text :=
            'insert into DeviceDiameter (' +
            'DeviceTypeID, Name, DN, Description, ' +
            'Qmax, Qmin, Kp, QFmax, Vmax, Vmin' +
            ') values (' +
            ':DeviceTypeID, :Name, :DN, :Description, ' +
            ':Qmax, :Qmin, :Kp, :QFmax, :Vmax, :Vmin' +
            ')';
        end;

      {======================= UPDATE =======================}
      osModified:
        begin
          if ADiameter.ID <= 0 then
            raise Exception.Create('Cannot update diameter without ID');

          Q.SQL.Text :=
            'update DeviceDiameter set ' +
            'DeviceTypeID=:DeviceTypeID, ' +
            'Name=:Name, DN=:DN, Description=:Description, ' +
            'Qmax=:Qmax, Qmin=:Qmin, Kp=:Kp, ' +
            'QFmax=:QFmax, Vmax=:Vmax, Vmin=:Vmin ' +
            'where ID=:ID';
        end;

    else
      Exit(True);
    end;

    {======================= ПАРАМЕТРЫ =======================}

    if ADiameter.State <> osNew then
      SetIntParam(Q, 'ID', ADiameter.ID);

    SetIntParam(Q, 'DeviceTypeID', ADiameter.DeviceTypeID);
    SetStrParam(Q, 'Name', ADiameter.Name);
    SetStrParam(Q, 'DN', ADiameter.DN);
    SetStrParam(Q, 'Description', ADiameter.Description);

    SetFloatParam(Q, 'Qmax', ADiameter.Qmax);
    SetFloatParam(Q, 'Qmin', ADiameter.Qmin);
    SetFloatParam(Q, 'Kp', ADiameter.Kp);
    SetFloatParam(Q, 'QFmax', ADiameter.QFmax);
    SetFloatParam(Q, 'Vmax', ADiameter.Vmax);
    SetFloatParam(Q, 'Vmin', ADiameter.Vmin);

    {======================= EXEC =======================}

    Q.ExecSQL;

    { 🔴 получаем ID, сгенерированный БД }
    if ADiameter.State = osNew then
      ADiameter.ID :=
        Q.Connection.ExecSQLScalar(
          'select last_insert_rowid()'
        );

    ADiameter.State := osClean;
    Result := True;

  finally
    Q.Free;
  end;
end;

function TTypeRepository.UpdateDiameters(
  AType: TDeviceType
): Boolean;
var
  D: TDiameter;
begin
  Result := False;

  if (AType = nil) or (FDM = nil) then
    Exit;

  if AType.Diameters = nil then
    Exit(True);

  for D in AType.Diameters do
  begin
    if not UpdateDiameter(D) then
      Exit(False);
  end;

   for D in AType.Diameters do
  begin
    if not UpdateDiameter(D) then
      Exit(False);
  end;

  Result := True;
end;

   {$ENDREGION}

 {$REGION 'Type Points'}

//function TTypeRepository.GetTypePoints(
//  AType: TDeviceType
//): TObjectList<TTypePoint>;
//var
//  P: TTypePoint;
//begin
//  Result := TObjectList<TTypePoint>.Create(False);
//
//  if (AType = nil) or (FPoints = nil) then
//    Exit;
//
//  for P in FPoints do
//    if P.DeviceTypeID = AType.ID then
//      Result.Add(P);
//end;

//БД!!!


function TTypeRepository.RequiredPointColumns: TTableColumns;
begin
  Result := [
    Col('ID', 'INTEGER PRIMARY KEY AUTOINCREMENT'),
    Col('DeviceTypeID', 'INTEGER'),

    Col('Name', 'TEXT'),
    Col('Description', 'TEXT'),

    Col('FlowRate', 'REAL'),
    Col('FlowAccuracy', 'TEXT'),

    Col('Pressure', 'REAL'),
    Col('Temp', 'REAL'),
    Col('TempAccuracy', 'TEXT'),

    Col('LimitImp', 'INTEGER'),
    Col('LimitVolume', 'REAL'),
    Col('LimitTime', 'REAL'),

    Col('Error', 'REAL'),

    Col('Pause', 'INTEGER'),

    Col('RepeatsProtocol', 'INTEGER'),
    Col('Repeats', 'INTEGER')
  ];
end;

procedure TTypeRepository.EnsurePointSchema;
begin
  FDM.EnsureTable('DeviceTypePoint', RequiredPointColumns);
end;

procedure TTypeRepository.AssertPointSchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('DeviceTypePoint');
  Missing := TStringList.Create;
  try
    Cols := RequiredPointColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с DeviceTypePoint.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

//   var
//     ADeviceTypeID: Integer;
//     AType: TDeviceType;
// begin
//
//
//  ADeviceTypeID := Q.FieldByName('DeviceTypeID').AsInteger;
//
//  AType:= FindTypeByID(ADeviceTypeID);
//
//  Result := AType.AddDiameter;


function TTypeRepository.MapTypePointFromQuery(
  Q: TFDQuery
): TTypePoint;
var
  DeviceTypeID: Integer;
     AType: TDeviceType;
 begin

  DeviceTypeID:=  Q.FieldByName('DeviceTypeID').AsInteger;
  AType:= FindTypeByID(DeviceTypeID);
  Result := AType.AddTypePoint;

  {================ Идентификация ================}
  Result.ID := Q.FieldByName('ID').AsInteger;
  Result.DeviceTypeID := Q.FieldByName('DeviceTypeID').AsInteger;

  {================ Общая информация =============}
  Result.Name := Q.FieldByName('Name').AsString;
  Result.Description := Q.FieldByName('Description').AsString;

  {================ Расход =======================}
  Result.FlowRate := Q.FieldByName('FlowRate').AsFloat;
  Result.FlowAccuracy := Q.FieldByName('FlowAccuracy').AsString;

  {================ Условия ======================}
  Result.Pressure := Q.FieldByName('Pressure').AsFloat;
  Result.Temp := Q.FieldByName('Temp').AsFloat;
  Result.TempAccuracy := Q.FieldByName('TempAccuracy').AsString;

  {================ Ограничения ==================}
  Result.LimitImp := Q.FieldByName('LimitImp').AsInteger;
  Result.LimitVolume := Q.FieldByName('LimitVolume').AsFloat;
  Result.LimitTime := Q.FieldByName('LimitTime').AsFloat;

  {================ Погрешности ==================}
  Result.Error := Q.FieldByName('Error').AsFloat;

  {================ Дополнительно ================}
  Result.Pause := Q.FieldByName('Pause').AsInteger;

  {================ Повторы ======================}
  Result.RepeatsProtocol := Q.FieldByName('RepeatsProtocol').AsInteger;
  Result.Repeats := Q.FieldByName('Repeats').AsInteger;

  Result.State := osClean;
end;

function TTypeRepository.LoadTypePointsByType(
  ATypeID: Integer
): TObjectList<TTypePoint>;
var
  Q: TFDQuery;
begin
  Result := TObjectList<TTypePoint>.Create(True);

  if (ATypeID <= 0) or (FDM = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    Q.SQL.Text :=
      'select * from DeviceTypePoint ' +
      'where DeviceTypeID = :ID ' +
      'order by ID';

    SetIntParam(Q, 'ID', ATypeID);
    Q.Open;

    while not Q.Eof do
    begin
      Result.Add(MapTypePointFromQuery(Q));
      Q.Next;
    end;

  finally
    Q.Free;
  end;
end;
//
//function TTypeRepository.LoadTypePoints: Boolean;
//var
//  T: TDeviceType;
//  L: TObjectList<TTypePoint>;
//  P: TTypePoint;
//begin
//  Result := False;
//
//  if (FDM = nil) or (FTypes = nil) then
//    Exit;
//
//  FState := osLoading;
//
//  FreeAndNil(FPoints);
//  FPoints := TObjectList<TTypePoint>.Create(True);
//
//  try
//    for T in FTypes do
//    begin
//      L := LoadTypePointsByType(T.ID);
//      try
//        if L <> nil then
//        begin
//          for P in L do
//            FPoints.Add(P);
//
//          L.OwnsObjects := False;
//        end;
//      finally
//        L.Free;
//      end;
//    end;
//
//    FState := osClean;
//    Result := True;
//
//  except
//    FState := osError;
//    raise;
//  end;
//end;

function TTypeRepository.UpdateTypePoints(
  AType: TDeviceType
): Boolean;
var
  P: TTypePoint;
begin
  Result := False;

  if (AType = nil) or (FDM = nil) then
    Exit;

  if AType.Points = nil then
    Exit(True);

  for P in AType.Points do
  begin
    if not UpdateTypePoint(P) then
      Exit(False);
  end;

  Result := True;
end;
function TTypeRepository.UpdateTypePoint(
  APoint: TTypePoint
): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (APoint = nil) or (FDM = nil) then
    Exit;

  if APoint.State = osClean then
    Exit(True);

  { защита: точка обязана принадлежать типу }
  if APoint.DeviceTypeID <= 0 then
    raise Exception.Create('TypePoint must have valid DeviceTypeID');

  Q := FDM.CreateQuery;
  try
    case APoint.State of

      {======================= DELETE =======================}
      osDeleted:
        begin
          if APoint.ID <= 0 then
            Exit(True);

          Q.SQL.Text :=
            'delete from DeviceTypePoint where ID = :ID';

          SetIntParam(Q, 'ID', APoint.ID);
          Q.ExecSQL;
          Exit(True);
        end;

      {======================= INSERT =======================}
      osNew:
        begin
          Q.SQL.Text :=
            'insert into DeviceTypePoint (' +
            'DeviceTypeID, Name, Description, ' +
            'FlowRate, FlowAccuracy, ' +
            'Pressure, Temp, TempAccuracy, ' +
            'LimitImp, LimitVolume, LimitTime, ' +
            'Error, Pause, RepeatsProtocol, Repeats' +
            ') values (' +
            ':DeviceTypeID, :Name, :Description, ' +
            ':FlowRate, :FlowAccuracy, ' +
            ':Pressure, :Temp, :TempAccuracy, ' +
            ':LimitImp, :LimitVolume, :LimitTime, ' +
            ':Error, :Pause, :RepeatsProtocol, :Repeats' +
            ')';
        end;

      {======================= UPDATE =======================}
      osModified:
        begin
          if APoint.ID <= 0 then
            raise Exception.Create('Cannot update type point without ID');

          Q.SQL.Text :=
            'update DeviceTypePoint set ' +
            'DeviceTypeID=:DeviceTypeID, ' +
            'Name=:Name, Description=:Description, ' +
            'FlowRate=:FlowRate, FlowAccuracy=:FlowAccuracy, ' +
            'Pressure=:Pressure, Temp=:Temp, TempAccuracy=:TempAccuracy, ' +
            'LimitImp=:LimitImp, LimitVolume=:LimitVolume, LimitTime=:LimitTime, ' +
            'Error=:Error, Pause=:Pause, ' +
            'RepeatsProtocol=:RepeatsProtocol, Repeats=:Repeats ' +
            'where ID=:ID';
        end;

    else
      Exit(True);
    end;

    {======================= ПАРАМЕТРЫ =======================}

    if APoint.State <> osNew then
      SetIntParam(Q, 'ID', APoint.ID);

    SetIntParam(Q, 'DeviceTypeID', APoint.DeviceTypeID);
    SetStrParam(Q, 'Name', APoint.Name);
    SetStrParam(Q, 'Description', APoint.Description);

    SetFloatParam(Q, 'FlowRate', APoint.FlowRate);
    SetStrParam(Q, 'FlowAccuracy', APoint.FlowAccuracy);

    SetFloatParam(Q, 'Pressure', APoint.Pressure);
    SetFloatParam(Q, 'Temp', APoint.Temp);
    SetStrParam(Q, 'TempAccuracy', APoint.TempAccuracy);

    SetIntParam(Q, 'LimitImp', APoint.LimitImp);
    SetFloatParam(Q, 'LimitVolume', APoint.LimitVolume);
    SetFloatParam(Q, 'LimitTime', APoint.LimitTime);

    SetFloatParam(Q, 'Error', APoint.Error);
    SetIntParam(Q, 'Pause', APoint.Pause);
    SetIntParam(Q, 'RepeatsProtocol', APoint.RepeatsProtocol);
    SetIntParam(Q, 'Repeats', APoint.Repeats);

    {======================= EXEC =======================}

    Q.ExecSQL;

    { 🔴 получаем ID, сгенерированный БД }
    if APoint.State = osNew then
      APoint.ID :=
        Q.Connection.ExecSQLScalar(
          'select last_insert_rowid()'
        );

    APoint.State := osClean;
    Result := True;

  finally
    Q.Free;
  end;
end;

{$ENDREGION}

 {$REGION 'Categories'}


function TTypeRepository.FindCategoryByID(AID: Integer): TDeviceCategory;
var
  C: TDeviceCategory;
begin
  Result := nil;

  if FCategories = nil then
    Exit;

  for C in FCategories do
    if C.ID = AID then
      Exit(C);
end;

function TTypeRepository.DetectCategoryByKeywords(
  const Text: string
): Integer;
var
  C: TDeviceCategory;
  Words: TArray<string>;
  W: string;
  Src: string;
begin
  Result := -1;

  if (Text.Trim = '') or (FCategories = nil) then
    Exit;

  Src := LowerCase(Text);

  for C in FCategories do
  begin
    // пропускаем пустую категорию
    if C.ID < 0 then
      Continue;

    if C.KeyWords.Trim = '' then
      Continue;

    Words := C.KeyWords.Split([';']);

    for W in Words do
    begin
      if W = '' then
        Continue;

      if Pos(LowerCase(W), Src) > 0 then
      begin
        Result := C.ID;
        Exit;
      end;
    end;
  end;
end;

 function TTypeRepository.LoadCategories: Boolean;
var
  Q: TFDQuery;
  C: TDeviceCategory;
begin
  Result := False;

  if FDM = nil then
    Exit;

  FState := osLoading;

  FreeAndNil(FCategories);
  FCategories := TObjectList<TDeviceCategory>.Create(True);

  Q := FDM.CreateQuery;
  try
    try
      Q.SQL.Text :=
        'select * from DeviceCategory order by ID';
      Q.Open;

      while not Q.Eof do
      begin
        C := TDeviceCategory.Create;

        C.ID := Q.FieldByName('ID').AsInteger;
        C.Name := Q.FieldByName('Name').AsString;
        C.KeyWords := Q.FieldByName('KeyWords').AsString;

        C.MeasuredDimension :=
          TMeasuredDimension(
            Q.FieldByName('MeasuredDimension').AsInteger
          );

        C.DefaultOutputType :=
          TOutputType(
            Q.FieldByName('DefaultOutputType').AsInteger
          );

        FCategories.Add(C);
        Q.Next;
      end;

      // ----------------------------------
      // Если список пуст — считаем, что не загрузились
      // ----------------------------------
      if FCategories.Count = 0 then
      begin
        FState := osEmpty;   // данных нет, но ошибки тоже нет
        Result := True;
        Exit;
      end;

      FState := osClean;
      Result := True;

    except
      FState := osError;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

function TTypeRepository.SaveCategories: Boolean;
var
  Q: TFDQuery;
  C: TDeviceCategory;
begin
  Result := False;

  if (FDM = nil) or (FCategories = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    FDM.StartTransaction;
    try
      {--------------------------------------------}
      { 1. Удаляем все категории }
      {--------------------------------------------}
      Q.SQL.Text := 'delete from DeviceCategory';
      Q.ExecSQL;

      {--------------------------------------------}
      { 2. Записываем все заново }
      {--------------------------------------------}
      Q.SQL.Text :=
        'insert into DeviceCategory (' +
        'ID, Name, KeyWords, MeasuredDimension, DefaultOutputType' +
        ') values (' +
        ':ID, :Name, :KeyWords, :MeasuredDimension, :DefaultOutputType' +
        ')';

      for C in FCategories do
      begin
        with Q.ParamByName('ID') do
        begin
          DataType := ftInteger;
          AsInteger := C.ID;
        end;

        with Q.ParamByName('Name') do
        begin
          DataType := ftString;
          AsString := C.Name;
        end;

        with Q.ParamByName('KeyWords') do
        begin
          DataType := ftString;
          AsString := C.KeyWords;
        end;

        with Q.ParamByName('MeasuredDimension') do
        begin
          DataType := ftInteger;
          AsInteger := Ord(C.MeasuredDimension);
        end;

        with Q.ParamByName('DefaultOutputType') do
        begin
          DataType := ftInteger;
          AsInteger := Ord(C.DefaultOutputType);
        end;

        Q.ExecSQL;
      end;

      FDM.Commit;
      Result := True;

    except
      FDM.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

// БД

 function TTypeRepository.RequiredCategoryColumns: TTableColumns;
begin
  Result := [
    Col('ID', 'INTEGER PRIMARY KEY AUTOINCREMENT'),
    Col('Name', 'TEXT NOT NULL'),
    Col('KeyWords', 'TEXT'),
    Col('MeasuredDimension', 'INTEGER'),
    Col('DefaultOutputType', 'INTEGER')
  ];
end;
procedure TTypeRepository.EnsureCategorySchema;
begin
  FDM.EnsureTable('DeviceCategory', RequiredCategoryColumns);
end;
procedure TTypeRepository.AssertCategorySchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('DeviceCategory');
  Missing := TStringList.Create;
  try
    Cols := RequiredCategoryColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с DeviceCategory.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

{$ENDREGION}


{$ENDREGION}

{$REGION 'TDeviceRepository'}


 {$REGION 'TDeviceRepository methods'}
constructor TDeviceRepository.Create(
  const AName: string;
  ADM: TDM
);
begin
  {--------------------------------------------------}
  { Базовый репозиторий }
  {--------------------------------------------------}
  inherited Create(AName, rkDevice, ADM);

  {--------------------------------------------------}
  { Хранилища }
  {--------------------------------------------------}
  FDevices   := TObjectList<TDevice>.Create(True);


  {--------------------------------------------------}
  { Генераторы ID }
  {--------------------------------------------------}
  FNextDeviceID   := 1;
  FNextPointID    := 1;
  FNextSpillageID := 1;
end;

destructor TDeviceRepository.Destroy;
begin

  FreeAndNil(FDevices);

  inherited;
end;

procedure TDeviceRepository.Init;
begin
  {--------------------------------------------------}
  { Очистка текущего состояния }
  {--------------------------------------------------}
  FDevices.Clear;

  FNextDeviceID := 1;
  FNextPointID := 1;

  {--------------------------------------------------}
  { Инициализация тестовых данных }
  {--------------------------------------------------}
  InitDevices;
  InitDevicePoints;

  FState := osLoaded;
end;

function TDeviceRepository.InitDevices: TObjectList<TDevice>;
var
  D: TDevice;
begin
  Result := FDevices;

  {--------------------------------------------------}
  { Прибор №1 }
  {--------------------------------------------------}
  D := TDevice.Create;
  D.ID := FNextDeviceID;
  Inc(FNextDeviceID);

  D.State := osLoaded;

  D.Name := 'Расходомер ВЗЛЕТ ТЭР';
  D.SerialNumber := 'A123456';
  D.Manufacturer := 'ВЗЛЕТ';
  D.Owner := 'Лаборатория №1';

  D.DeviceTypeUUID := '';
  D.DeviceTypeName := 'Расходомер электромагнитный';
  D.DeviceTypeRepo := 'Основной';

  D.Category := 1;
  D.CategoryName := 'Расходомер электромагнитный';

  D.DN := 'DN50';
  D.Qmax := 25.0;
  D.Qmin := 0.25;
  D.RangeDynamic := 100.0;

  D.AccuracyClass := '±1.0';
  D.Error := 1.0;

  D.RegDate := EncodeDate(2022, 1, 1);
  D.ValidityDate := EncodeDate(2032, 1, 1);
  D.DateOfManufacture := EncodeDate(2021, 6, 15);

  FDevices.Add(D);

  {--------------------------------------------------}
  { Прибор №2 }
  {--------------------------------------------------}
  D := TDevice.Create;
  D.ID := FNextDeviceID;
  Inc(FNextDeviceID);

  D.State := osLoaded;

  D.Name := 'Счётчик воды СВК-15';
  D.SerialNumber := 'W987654';
  D.Manufacturer := 'Тепловодомер';
  D.Owner := 'Участок поверки';

  D.DeviceTypeUUID := '';
  D.DeviceTypeName := 'Счётчик воды';

  D.Category := 5;
  D.CategoryName := 'Счётчик воды';

  D.DN := 'DN15';
  D.Qmax := 3.0;
  D.Qmin := 0.03;
  D.RangeDynamic := 100.0;

  D.AccuracyClass := '±2.5';
  D.Error := 2.5;

  D.RegDate := EncodeDate(2020, 5, 10);
  D.ValidityDate := EncodeDate(2030, 5, 10);
  D.DateOfManufacture := EncodeDate(2020, 3, 1);

  FDevices.Add(D);
end;

function TDeviceRepository.InitDevicePoints: TObjectList<TDevicePoint>;
var
  P: TDevicePoint;
begin


//  {--------------------------------------------------}
//  { Точки для прибора ID = 1 }
//  {--------------------------------------------------}
//  P := TDevicePoint.Create;
//  P.ID := FNextPointID;
//  Inc(FNextPointID);
//
//  P.State := osLoaded;
//
//  P.DeviceID := 1;
//  P.Num := 1;
//  P.Name := 'Qmax';
//
//  P.FlowRate := 1.0;
//  P.Q := 25.0;
//  P.FlowAccuracy := '±5%';
//
//  P.LimitTime := 60;
//  P.LimitVolume := 400.0;
//  P.LimitImp := 0;
//
//  P.Error := 1.0;
//  P.RepeatsProtocol := 3;
//  P.Repeats := 5;
//
//  FPoints.Add(P);
//
//  {--------------------------------------------------}
//  { Вторая точка }
//  {--------------------------------------------------}
//  P := TDevicePoint.Create;
//  P.ID := FNextPointID;
//  Inc(FNextPointID);
//
//  P.State := osLoaded;
//
//  P.DeviceID := 1;
//  P.Num := 2;
//  P.Name := 'Qmin';
//
//  P.FlowRate := 0.1;
//  P.Q := 2.5;
//  P.FlowAccuracy := '±5%';
//
//  P.LimitTime := 120;
//  P.LimitVolume := 200.0;
//
//  P.Error := 1.0;
//  P.RepeatsProtocol := 3;
//  P.Repeats := 5;
//
//  FPoints.Add(P);
end;

procedure TDeviceRepository.InitBulkTestData;
const
  MANUFACTURERS: array[0..3] of string =
    ('ВЗЛЕТ', 'Тепловодомер', 'ЭМИС', 'КРОНЕ');

  OWNERS: array[0..2] of string =
    ('Лаборатория №1', 'Участок поверки', 'Метрологическая служба');

  DEVICE_TYPES: array[0..5] of record
    UUID: string;
    Name: string;
    Category: Integer;
    CategoryName: string;
    DN: string;
    Qmax: Double;
  end = (
    (UUID: '1'; Name: 'Расходомер электромагнитный'; Category: 1; CategoryName: 'Расходомер электромагнитный'; DN: 'DN50'; Qmax: 25.0),
    (UUID: '2'; Name: 'Счётчик воды';               Category: 5; CategoryName: 'Счётчик воды';               DN: 'DN15'; Qmax: 3.0),
    (UUID: '3'; Name: 'Расходомер кориолисовый';    Category: 2; CategoryName: 'Расходомер кориолисовый';    DN: 'DN25'; Qmax: 10.0),
    (UUID: '2'; Name: 'Счётчик воды';               Category: 5; CategoryName: 'Счётчик воды';               DN: 'DN15'; Qmax: 3.0),
    (UUID: '1'; Name: 'Расходомер электромагнитный'; Category: 1; CategoryName: 'Расходомер электромагнитный'; DN: 'DN50'; Qmax: 25.0),
    (UUID: '3'; Name: 'Расходомер кориолисовый';    Category: 2; CategoryName: 'Расходомер кориолисовый';    DN: 'DN25'; Qmax: 10.0)

  );
var
  i, j, k: Integer;
  D: TDevice;
  P: TDevicePoint;
begin

  Randomize;

  {--------------------------------------------------}
  { Генерация приборов }
  {--------------------------------------------------}
  for i := 0 to High(DEVICE_TYPES) do
  begin
    for j := 1 to 100 do   // много приборов каждого типа
    begin
      D := CreateNewDevice;


      {------------------------------}
      { Связь с типом }
      {------------------------------}
      D.DeviceTypeUUID   := DEVICE_TYPES[i].UUID;
      D.DeviceTypeName := DEVICE_TYPES[i].Name;

      D.Category     := DEVICE_TYPES[i].Category;
      D.CategoryName := DEVICE_TYPES[i].CategoryName;

      {------------------------------}
      { Идентификация }
      {------------------------------}
      D.Name         := DEVICE_TYPES[i].Name + ' №' + IntToStr(j);
      D.SerialNumber := DEVICE_TYPES[i].UUID +  Format(' SN-%d', [j]);

      {------------------------------}
      { Производитель / владелец }
      {------------------------------}
      D.Manufacturer := MANUFACTURERS[Random(Length(MANUFACTURERS))];
      D.Owner        := OWNERS[Random(Length(OWNERS))];

      {------------------------------}
      { Диапазоны }
      {------------------------------}
      D.DN           := DEVICE_TYPES[i].DN;
      D.Qmax         := DEVICE_TYPES[i].Qmax;
      D.Qmin         := D.Qmax / 100.0;
      D.RangeDynamic := 100.0;

      {------------------------------}
      { Погрешность }
      {------------------------------}
      D.AccuracyClass :=
        '±' + FloatToStrF(1.0 + Random * 1.5, ffFixed, 3, 1);
      D.Error :=
        StrToFloat(StringReplace(D.AccuracyClass, '±', '', []));

      {------------------------------}
      { Даты }
      {------------------------------}
      D.RegDate :=
        EncodeDate(2019 + Random(4), 1 + Random(12), 1 + Random(28));

      D.ValidityDate :=
        EncodeDate(2030 + Random(5), 1, 1);

      D.DateOfManufacture :=
        EncodeDate(2018 + Random(4), 1 + Random(12), 1 + Random(28));

      {------------------------------}
      { Повторы по умолчанию }
      {------------------------------}
      D.Repeats         := 5;
      D.RepeatsProtocol := 3;

      {--------------------------------------------------}
      { Поверочные точки прибора (ВНУТРИ Device) }
      {--------------------------------------------------}
      for k := 1 to 3 do
      begin
        P := D.AddPoint;
        P.State    := osLoaded;
        P.DeviceID := D.ID;
        P.Num      := k;

        case k of
          1:
            begin
              P.Name     := 'Qmax';
              P.FlowRate := 1.0;
            end;
          2:
            begin
              P.Name     := 'Qnom';
              P.FlowRate := 0.5;
            end;
          3:
            begin
              P.Name     := 'Qmin';
              P.FlowRate := 0.1;
            end;
        end;

        P.Q               := D.Qmax * P.FlowRate;
        P.FlowAccuracy    := '±5%';
        P.LimitTime       := 60 + Random(60);
        P.LimitVolume     := P.Q * P.LimitTime / 3.6;
        P.Error           := D.Error;
        P.Repeats         := D.Repeats;
        P.RepeatsProtocol := D.RepeatsProtocol;
      end;

    end;
  end;

  FState := osLoaded;
end;

function TDeviceRepository.Load: Boolean;
begin
  Result := False;

  if FDM = nil then
    Exit;

  FState := osLoading;
  try
    {==================================================}
    { 1. СХЕМА БД }
    {==================================================}

    EnsureDeviceSchema;
    EnsureDevicePointSchema;
    EnsureSpillageSchema;

    AssertDeviceSchema;
    AssertDevicePointSchema;
    AssertSpillageSchema;

    {==================================================}
    { 2. ПРИБОРЫ }
    {==================================================}

    if not LoadDevices then
      raise Exception.Create('Не удалось загрузить приборы');

    {==================================================}
    { 3. ЗАВИСИМЫЕ ДАННЫЕ }
    {==================================================}



    {==================================================}
    { 4. ИТОГ }
    {==================================================}

    FState := osLoaded;
    Result := True;

  except
    FState := osError;
    raise;
  end;
end;

function TDeviceRepository.DeviceExistsInDB(AID: Integer): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (FDM = nil) or (AID <= 0) then
    Exit;

  Q := FDM.CreateQuery;
  try
    Q.SQL.Text :=
      'select 1 from Devices where ID = :ID limit 1';
    SetIntParam(Q, 'ID', AID);
    Q.Open;
    Result := not Q.Eof;
  finally
    Q.Free;
  end;
end;


function TDeviceRepository.Save: Boolean;
var
  D: TDevice;
  SeenIDs: TDictionary<Integer, TDevice>;
begin
  Result := False;

  if (FDM = nil) or (FDevices = nil) then
    Exit;

  {--------------------------------------------------}
  { ЖЁСТКАЯ ПРОВЕРКА ЦЕЛОСТНОСТИ (до транзакции) }
  {--------------------------------------------------}
  SeenIDs := TDictionary<Integer, TDevice>.Create;
  try
    for D in FDevices do
    begin
      { ID обязан быть валидным }
      if D.ID <= 0 then
        raise Exception.CreateFmt(
          'Device with invalid ID detected (ID=%d)',
          [D.ID]
        );

      { запрет дубликатов ID в памяти }
      if SeenIDs.ContainsKey(D.ID) then
        raise Exception.CreateFmt(
          'Duplicate device ID in memory: %d',
          [D.ID]
        );

      SeenIDs.Add(D.ID, D);

      { osNew допустим только если записи нет в БД }
      if (D.State = osNew) and DeviceExistsInDB(D.ID) then
        raise Exception.CreateFmt(
          'Attempt to INSERT existing device ID=%d',
          [D.ID]
        );
    end;
  finally
    SeenIDs.Free;
  end;

  {--------------------------------------------------}
  { ТРАНЗАКЦИЯ }
  {--------------------------------------------------}
  FDM.StartTransaction;
  try
    for D in FDevices do
      if not UpdateDevice(D) then
        raise Exception.Create(
          'Ошибка сохранения прибора'
        );

    { вторая очередь }
    // SaveSpillages;

    FDM.Commit;
    FState := osSaved;
    Result := True;

  except
    FDM.Rollback;
    raise;
  end;
end;

function TDeviceRepository.SaveDevice(
  ADevice: TDevice
): Boolean;
begin
  Result := False;

  if (ADevice = nil) or (FDM = nil) then
    Exit;

  { базовая защита }
  if ADevice.ID <= 0 then
    raise Exception.CreateFmt(
      'Device with invalid ID detected (ID=%d)',
      [ADevice.ID]
    );

  // Начинаем транзакцию
  FDM.StartTransaction;
  try
    // Обновляем прибор
    if not UpdateDevice(ADevice) then
      raise Exception.Create('Ошибка сохранения прибора');

    // Применяем изменения в БД
    FDM.Commit;

    Result := True;

  except
    // Если произошла ошибка, откатываем изменения
    FDM.Rollback;
    raise;
  end;
end;




 {$ENDREGION}


  {$REGION 'Device'}
function TDeviceRepository.CreateNewDevice: TDevice;
begin
  Result := TDevice.Create;
  Result.ID := GenerateDeviceID;
  { 🔗 привязываем репозиторий }
  Result.RepoName := Self.Name;
  FDevices.Add(Result);
end;


function TDeviceRepository.CreateDevice(AIndex: Integer): TDevice;
var
  Src: TDevice;
begin
  { если индекс невалидный — просто новый }
  if (AIndex < 0) or (AIndex >= FDevices.Count) then
    Exit(CreateNewDevice);

  Src := FDevices[AIndex];
  if Src = nil then
    Exit(CreateNewDevice);

  { создаём новый прибор }
  Result := CreateNewDevice;

  { копируем данные }
  Result.Assign(Src);

  { гарантируем уникальность }
  Result.ID := GenerateDeviceID;
  Result.State := osNew;
end;

function TDeviceRepository.GetDevice(ADeviceID: Integer): TDevice;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to FDevices.Count - 1 do
    if FDevices[i].ID = ADeviceID then
      Exit(FDevices[i]);
end;

procedure TDeviceRepository.DeleteDevice(ADevice: TDevice);
var
  P: TDevicePoint;
begin
  if (ADevice = nil) or (FDM = nil) then
    Exit;

  case ADevice.State of

    {----------------------------------------------}
    { Новый, не сохранённый — просто убираем }
    {----------------------------------------------}
    osNew:
      begin
        FDevices.Remove(ADevice);
        Exit;
      end;

    {----------------------------------------------}
    { Уже сохранённый — удаляем СРАЗУ }
    {----------------------------------------------}
    osClean, osLoaded, osModified:
      begin
        { помечаем точки }
        if ADevice.Points <> nil then
          for P in ADevice.Points do
            P.State := osDeleted;

        { помечаем устройство }
        ADevice.State := osDeleted;

        { сразу пишем в БД }
        if not UpdateDevice(ADevice) then
          raise Exception.Create('Ошибка удаления прибора');

        { убираем из памяти }
        FDevices.Remove(ADevice);
      end;
  end;
end;

function TDeviceRepository.GenerateDeviceID: Integer;
var
  D: TDevice;
  MaxID: Integer;
begin
  MaxID := 0;

  if Assigned(FDevices) then
  begin
    for D in FDevices do
      if D.ID > MaxID then
        MaxID := D.ID;
  end;

  Result := MaxID + 1;
end;

function TDeviceRepository.RequiredDeviceColumns: TTableColumns;
begin
  Result := [
    {--------------------------------------------------}
    { Идентификация }
    {--------------------------------------------------}
    Col('ID',                'INTEGER PRIMARY KEY AUTOINCREMENT'),
    Col('MitUUID',           'TEXT'),

    Col('DeviceTypeUUID',      'TEXT'),
    Col('DeviceTypeName',      'TEXT'),
    Col('DeviceTypeRepo',      'TEXT'),
    {--------------------------------------------------}
    { Наименование и паспорт }
    {--------------------------------------------------}
    Col('Name',              'TEXT NOT NULL'),
    Col('SerialNumber',      'TEXT'),
    Col('Modification',      'TEXT'),

    Col('Manufacturer',      'TEXT'),
    Col('Owner',             'TEXT'),
    Col('ReestrNumber',      'TEXT'),

    {--------------------------------------------------}
    { Классификация }
    {--------------------------------------------------}
    Col('Category',          'INTEGER'),
    Col('CategoryName',     'TEXT'),
    Col('AccuracyClass',     'TEXT'),

    {--------------------------------------------------}
    { Сроки }
    {--------------------------------------------------}
    Col('RegDate',           'DATE'),
    Col('ValidityDate',      'DATE'),
    Col('DateOfManufacture', 'DATE'),

    Col('IVI',               'INTEGER'),

    {--------------------------------------------------}
    { Метрология }
    {--------------------------------------------------}
    Col('DN',                'TEXT'),
    Col('Qmax',              'REAL'),
    Col('Qmin',              'REAL'),
    Col('RangeDynamic',      'REAL'),

    Col('Error',             'REAL'),

    {--------------------------------------------------}
    { Процедуры }
    {--------------------------------------------------}
    Col('VerificationMethod','TEXT'),
    Col('ProcedureName',     'TEXT'),

    {--------------------------------------------------}
    { Измерения и сигналы }
    {--------------------------------------------------}
    Col('MeasuredDimension', 'INTEGER'),
    Col('OutputType',        'INTEGER'),
    Col('DimensionCoef',     'INTEGER'),

    {--------------------------------------------------}
    { Импульс / частота }
    {--------------------------------------------------}
    Col('OutputSet',         'INTEGER'),
    Col('Freq',              'REAL'),
    Col('Coef',              'REAL'),
    Col('FreqFlowRate',      'REAL'),

    {--------------------------------------------------}
    { Напряжение }
    {--------------------------------------------------}
    Col('VoltageRange',      'INTEGER'),
    Col('VoltageQminRate',   'REAL'),
    Col('VoltageQmaxRate',   'REAL'),

    {--------------------------------------------------}
    { Ток }
    {--------------------------------------------------}
    Col('CurrentRange',      'INTEGER'),
    Col('CurrentQminRate',   'REAL'),
    Col('CurrentQmaxRate',   'REAL'),
    Col('IntegrationTime',   'INTEGER'),

    {--------------------------------------------------}
    { Интерфейс }
    {--------------------------------------------------}
    Col('ProtocolName',      'TEXT'),
    Col('BaudRate',          'INTEGER'),
    Col('Parity',            'INTEGER'),
    Col('DeviceAddress',     'INTEGER'),

    {--------------------------------------------------}
    { Испытания }
    {--------------------------------------------------}
    Col('InputType',         'INTEGER'),
    Col('SpillageType',      'INTEGER'),
    Col('SpillageStop',      'INTEGER'),

    Col('Repeats',           'INTEGER'),
    Col('RepeatsProtocol',   'INTEGER'),

    {--------------------------------------------------}
    { Описание }
    {--------------------------------------------------}
    Col('Comment',           'TEXT'),
    Col('Description',       'TEXT'),
    Col('ReportingForm',     'TEXT')
  ];
end;

procedure TDeviceRepository.EnsureDeviceSchema;
begin
  try
    FDM.EnsureTable('Devices', RequiredDeviceColumns);
  except
    on E: Exception do
    begin
      raise Exception.Create(
        'Ошибка создания таблицы Devices:' + sLineBreak +
        E.Message
      );
    end;
  end;
end;

procedure TDeviceRepository.AssertDeviceSchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('Devices');
  Missing := TStringList.Create;
  try
    Cols := RequiredDeviceColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с Devices.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

function TDeviceRepository.MapDeviceFromQuery(Q: TFDQuery): TDevice;
begin
  Result := CreateNewDevice;

  Result.ID := Q.FieldByName('ID').AsInteger;
  Result.MitUUID := Q.FieldByName('MitUUID').AsString;

  Result.DeviceTypeUUID := Q.FieldByName('DeviceTypeUUID').AsString;
  Result.DeviceTypeName := Q.FieldByName('DeviceTypeName').AsString;
  Result.DeviceTypeRepo := Q.FieldByName('DeviceTypeRepo').AsString;

  Result.Name := Q.FieldByName('Name').AsString;
  Result.SerialNumber := Q.FieldByName('SerialNumber').AsString;
  Result.Modification := Q.FieldByName('Modification').AsString;

  Result.Manufacturer := Q.FieldByName('Manufacturer').AsString;
  Result.Owner := Q.FieldByName('Owner').AsString;
  Result.ReestrNumber := Q.FieldByName('ReestrNumber').AsString;

  Result.Category := Q.FieldByName('Category').AsInteger;
  Result.CategoryName := Q.FieldByName('CategoryName').AsString;



  Result.AccuracyClass := Q.FieldByName('AccuracyClass').AsString;

  if not Q.FieldByName('RegDate').IsNull then
    Result.RegDate := Q.FieldByName('RegDate').AsDateTime;

  if not Q.FieldByName('ValidityDate').IsNull then
    Result.ValidityDate := Q.FieldByName('ValidityDate').AsDateTime;

  if not Q.FieldByName('DateOfManufacture').IsNull then
    Result.DateOfManufacture := Q.FieldByName('DateOfManufacture').AsDateTime;

  Result.IVI := Q.FieldByName('IVI').AsInteger;

  Result.DN := Q.FieldByName('DN').AsString;
  Result.Qmax := Q.FieldByName('Qmax').AsFloat;
  Result.Qmin := Q.FieldByName('Qmin').AsFloat;
  Result.RangeDynamic := Q.FieldByName('RangeDynamic').AsFloat;

  Result.Error := Q.FieldByName('Error').AsFloat;

  Result.VerificationMethod := Q.FieldByName('VerificationMethod').AsString;
  Result.ProcedureName := Q.FieldByName('ProcedureName').AsString;

  Result.MeasuredDimension := Q.FieldByName('MeasuredDimension').AsInteger;
  Result.OutputType := Q.FieldByName('OutputType').AsInteger;
  Result.DimensionCoef := Q.FieldByName('DimensionCoef').AsInteger;

  Result.OutputSet := Q.FieldByName('OutputSet').AsInteger;
  Result.Freq := Q.FieldByName('Freq').AsInteger;
  Result.Coef := Q.FieldByName('Coef').AsFloat;
  Result.FreqFlowRate := Q.FieldByName('FreqFlowRate').AsFloat;

  Result.VoltageRange := Q.FieldByName('VoltageRange').AsInteger;
  Result.VoltageQminRate := Q.FieldByName('VoltageQminRate').AsFloat;
  Result.VoltageQmaxRate := Q.FieldByName('VoltageQmaxRate').AsFloat;

  Result.CurrentRange := Q.FieldByName('CurrentRange').AsInteger;
  Result.CurrentQminRate := Q.FieldByName('CurrentQminRate').AsFloat;
  Result.CurrentQmaxRate := Q.FieldByName('CurrentQmaxRate').AsFloat;
  Result.IntegrationTime := Q.FieldByName('IntegrationTime').AsInteger;

  Result.ProtocolName := Q.FieldByName('ProtocolName').AsString;
  Result.BaudRate := Q.FieldByName('BaudRate').AsInteger;
  Result.Parity := Q.FieldByName('Parity').AsInteger;
  Result.DeviceAddress := Q.FieldByName('DeviceAddress').AsInteger;

  Result.InputType := Q.FieldByName('InputType').AsInteger;
  Result.SpillageType := Q.FieldByName('SpillageType').AsInteger;
  Result.SpillageStop := Q.FieldByName('SpillageStop').AsInteger;
  Result.Repeats := Q.FieldByName('Repeats').AsInteger;
  Result.RepeatsProtocol := Q.FieldByName('RepeatsProtocol').AsInteger;

  Result.Comment := Q.FieldByName('Comment').AsString;
  Result.Description := Q.FieldByName('Description').AsString;
  Result.ReportingForm := Q.FieldByName('ReportingForm').AsString;

  Result.State := osClean;
end;

function TDeviceRepository.LoadDevice(ADevice: TDevice): TDevice;
var
  Q: TFDQuery;
begin
  Result := nil;

  if (ADevice = nil) or (ADevice.ID <= 0) or (FDM = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    // Выполняем запрос для поиска устройства по ID
    Q.SQL.Text := 'select * from Devices where ID = :ID';
    Q.ParamByName('ID').AsInteger := ADevice.ID;
    Q.Open;

    // Если запись найдена
    if not Q.Eof then
    begin
      // Преобразуем данные из Query в объект TDevice
      Result := MapDeviceFromQuery(Q);

      // Загружаем связанные данные для устройства
      LoadDevicePointsByDevice(Result.ID);
      LoadSpillagesByDevice(Result.ID);
    end;

  finally
    Q.Free;
  end;
end;

function TDeviceRepository.LoadDevice(ADeviceId: Integer): TDevice;
var
  Tmp: TDevice;
begin
  Result := nil;

  if ADeviceId <= 0 then
    Exit;

  Tmp := TDevice.Create;
  try
    Tmp.ID := ADeviceId;

    Result := LoadDevice(Tmp);

  finally
    Tmp.Free;
  end;
end;

function TDeviceRepository.LoadDevices: Boolean;
var
  Q: TFDQuery;
  NewD: TDevice;
begin
  Result := False;

  if FDM = nil then
    Exit;

  FState := osLoading;

  FDevices := TObjectList<TDevice>.Create(True);

  Q := FDM.CreateQuery;
  try
    try
      Q.SQL.Text := 'select * from Devices order by Name';
      Q.Open;

      while not Q.Eof do
      begin
        NewD := MapDeviceFromQuery(Q);

     if not LoadDevicePointsByDevice(NewD.ID) then
      raise Exception.Create('Не удалось загрузить точки приборов');

    if not LoadSpillagesByDevice(NewD.ID) then
      raise Exception.Create('Не удалось загрузить проливы');

        Q.Next;
      end;

      FState := osClean;
      Result := True;

    except
      FState := osError;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

function TDeviceRepository.RebuildDevices: Boolean;
var
  Q: TFDQuery;
  D: TDevice;
begin
  Result := False;

  if (FDM = nil) or (FDevices = nil) then
    Exit;

  Q := FDM.CreateQuery;
  try
    FDM.StartTransaction;
    try
      {--------------------------------------------------}
      { 1. Полная очистка таблицы }
      {--------------------------------------------------}
      Q.SQL.Text := 'delete from Devices';
      Q.ExecSQL;

      {--------------------------------------------------}
      { 2. Массовая запись }
      {--------------------------------------------------}
      for D in FDevices do
      begin
        D.State := osNew;

        if not UpdateDevice(D) then
          raise Exception.CreateFmt(
            'Ошибка пересборки Devices "%s"',
            [D.Name]
          );
      end;

      FDM.Commit;
      Result := True;

    except
      FDM.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

function TDeviceRepository.UpdateDevice(ADevice: TDevice): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (ADevice = nil) or (FDM = nil) then
    Exit;

  if ADevice.State = osClean then
    Exit(True);

  { защита: новый объект ОБЯЗАН иметь ID }
  if (ADevice.State = osNew) and (ADevice.ID <= 0) then
    raise Exception.Create('New device must have predefined ID');

  Q := FDM.CreateQuery;
  try
    case ADevice.State of

      {======================= DELETE =======================}
      osDeleted:
        begin
          Q.SQL.Text := 'delete from Devices where ID = :ID';
          SetIntParam(Q, 'ID', ADevice.ID);
          Q.ExecSQL;

          Q.SQL.Text :=
            'delete from DevicePoint where DeviceID = :DeviceID';
          SetIntParam(Q, 'DeviceID', ADevice.ID);
          Q.ExecSQL;

          Exit(True);
        end;

      {======================= INSERT =======================}
      osNew:
        Q.SQL.Text :=
          'insert into Devices (' +
          'ID, ' +
          'MitUUID, DeviceTypeUUID, DeviceTypeName, DeviceTypeRepo, ' +
          'Name, SerialNumber, Modification, ' +
          'Manufacturer, Owner, ReestrNumber, ' +
          'CategoryName, Category, AccuracyClass, ' +
          'RegDate, ValidityDate, DateOfManufacture, IVI, ' +
          'DN, Qmax, Qmin, RangeDynamic, Error, ' +
          'VerificationMethod, ProcedureName, ' +
          'MeasuredDimension, OutputType, DimensionCoef, ' +
          'OutputSet, Freq, Coef, FreqFlowRate, ' +
          'VoltageRange, VoltageQminRate, VoltageQmaxRate, ' +
          'CurrentRange, CurrentQminRate, CurrentQmaxRate, IntegrationTime, ' +
          'ProtocolName, BaudRate, Parity, DeviceAddress, ' +
          'InputType, SpillageType, SpillageStop, Repeats, RepeatsProtocol, ' +
          'Comment, Description, ReportingForm' +
          ') values (' +
          ':ID, ' +
          ':MitUUID, :DeviceTypeUUID, :DeviceTypeName, :DeviceTypeRepo, ' +
          ':Name, :SerialNumber, :Modification, ' +
          ':Manufacturer, :Owner, :ReestrNumber, ' +
          ':CategoryName, :Category, :AccuracyClass, ' +
          ':RegDate, :ValidityDate, :DateOfManufacture, :IVI, ' +
          ':DN, :Qmax, :Qmin, :RangeDynamic, :Error, ' +
          ':VerificationMethod, :ProcedureName, ' +
          ':MeasuredDimension, :OutputType, :DimensionCoef, ' +
          ':OutputSet, :Freq, :Coef, :FreqFlowRate, ' +
          ':VoltageRange, :VoltageQminRate, :VoltageQmaxRate, ' +
          ':CurrentRange, :CurrentQminRate, :CurrentQmaxRate, :IntegrationTime, ' +
          ':ProtocolName, :BaudRate, :Parity, :DeviceAddress, ' +
          ':InputType, :SpillageType, :SpillageStop, :Repeats, :RepeatsProtocol, ' +
          ':Comment, :Description, :ReportingForm' +
          ')';

      {======================= UPDATE =======================}
      osModified:
        Q.SQL.Text :=
          'update Devices set ' +
          'MitUUID = :MitUUID, ' +
          'DeviceTypeUUID = :DeviceTypeUUID, ' +
          'DeviceTypeName = :DeviceTypeName, ' +
          'DeviceTypeRepo = :DeviceTypeRepo, ' +
          'Name = :Name, SerialNumber = :SerialNumber, Modification = :Modification, ' +
          'Manufacturer = :Manufacturer, Owner = :Owner, ReestrNumber = :ReestrNumber, ' +
          'CategoryName = :CategoryName, Category = :Category, AccuracyClass = :AccuracyClass, ' +
          'RegDate = :RegDate, ValidityDate = :ValidityDate, DateOfManufacture = :DateOfManufacture, IVI = :IVI, ' +
          'DN = :DN, Qmax = :Qmax, Qmin = :Qmin, RangeDynamic = :RangeDynamic, Error = :Error, ' +
          'VerificationMethod = :VerificationMethod, ProcedureName = :ProcedureName, ' +
          'MeasuredDimension = :MeasuredDimension, OutputType = :OutputType, DimensionCoef = :DimensionCoef, ' +
          'OutputSet = :OutputSet, Freq = :Freq, Coef = :Coef, FreqFlowRate = :FreqFlowRate, ' +
          'VoltageRange = :VoltageRange, VoltageQminRate = :VoltageQminRate, VoltageQmaxRate = :VoltageQmaxRate, ' +
          'CurrentRange = :CurrentRange, CurrentQminRate = :CurrentQminRate, CurrentQmaxRate = :CurrentQmaxRate, IntegrationTime = :IntegrationTime, ' +
          'ProtocolName = :ProtocolName, BaudRate = :BaudRate, Parity = :Parity, DeviceAddress = :DeviceAddress, ' +
          'InputType = :InputType, SpillageType = :SpillageType, SpillageStop = :SpillageStop, ' +
          'Repeats = :Repeats, RepeatsProtocol = :RepeatsProtocol, ' +
          'Comment = :Comment, Description = :Description, ReportingForm = :ReportingForm ' +
          'where ID = :ID';

    else
      Exit(True);
    end;

    {======================= ПАРАМЕТРЫ =======================}

    SetIntParam(Q, 'ID', ADevice.ID);

    SetStrParam(Q, 'MitUUID', ADevice.MitUUID);
    SetStrParam(Q, 'DeviceTypeUUID', ADevice.DeviceTypeUUID);
    SetStrParam(Q, 'DeviceTypeName', ADevice.DeviceTypeName);
    SetStrParam(Q, 'DeviceTypeRepo', ADevice.DeviceTypeRepo);

    SetStrParam(Q, 'Name', ADevice.Name);
    SetStrParam(Q, 'SerialNumber', ADevice.SerialNumber);
    SetStrParam(Q, 'Modification', ADevice.Modification);

    SetStrParam(Q, 'Manufacturer', ADevice.Manufacturer);
    SetStrParam(Q, 'Owner', ADevice.Owner);
    SetStrParam(Q, 'ReestrNumber', ADevice.ReestrNumber);

    SetStrParam(Q, 'CategoryName', ADevice.CategoryName);
    SetIntParam(Q, 'Category', ADevice.Category);
    SetStrParam(Q, 'AccuracyClass', ADevice.AccuracyClass);

    SetDateParam(Q, 'RegDate', ADevice.RegDate);
    SetDateParam(Q, 'ValidityDate', ADevice.ValidityDate);
    SetDateParam(Q, 'DateOfManufacture', ADevice.DateOfManufacture);
    SetIntParam(Q, 'IVI', ADevice.IVI);

    SetStrParam(Q, 'DN', ADevice.DN);
    SetFloatParam(Q, 'Qmax', ADevice.Qmax);
    SetFloatParam(Q, 'Qmin', ADevice.Qmin);
    SetFloatParam(Q, 'RangeDynamic', ADevice.RangeDynamic);
    SetFloatParam(Q, 'Error', ADevice.Error);

    SetStrParam(Q, 'VerificationMethod', ADevice.VerificationMethod);
    SetStrParam(Q, 'ProcedureName', ADevice.ProcedureName);

    SetIntParam(Q, 'MeasuredDimension', ADevice.MeasuredDimension);
    SetIntParam(Q, 'OutputType', ADevice.OutputType);
    SetIntParam(Q, 'DimensionCoef', ADevice.DimensionCoef);

    SetIntParam(Q, 'OutputSet', ADevice.OutputSet);
    SetFloatParam(Q, 'Freq', ADevice.Freq);
    SetFloatParam(Q, 'Coef', ADevice.Coef);
    SetFloatParam(Q, 'FreqFlowRate', ADevice.FreqFlowRate);

    SetIntParam(Q, 'VoltageRange', ADevice.VoltageRange);
    SetFloatParam(Q, 'VoltageQminRate', ADevice.VoltageQminRate);
    SetFloatParam(Q, 'VoltageQmaxRate', ADevice.VoltageQmaxRate);

    SetIntParam(Q, 'CurrentRange', ADevice.CurrentRange);
    SetFloatParam(Q, 'CurrentQminRate', ADevice.CurrentQminRate);
    SetFloatParam(Q, 'CurrentQmaxRate', ADevice.CurrentQmaxRate);
    SetIntParam(Q, 'IntegrationTime', ADevice.IntegrationTime);

    SetStrParam(Q, 'ProtocolName', ADevice.ProtocolName);
    SetIntParam(Q, 'BaudRate', ADevice.BaudRate);
    SetIntParam(Q, 'Parity', ADevice.Parity);
    SetIntParam(Q, 'DeviceAddress', ADevice.DeviceAddress);

    SetIntParam(Q, 'InputType', ADevice.InputType);
    SetIntParam(Q, 'SpillageType', ADevice.SpillageType);
    SetIntParam(Q, 'SpillageStop', ADevice.SpillageStop);
    SetIntParam(Q, 'Repeats', ADevice.Repeats);
    SetIntParam(Q, 'RepeatsProtocol', ADevice.RepeatsProtocol);

    SetStrParam(Q, 'Comment', ADevice.Comment);
    SetStrParam(Q, 'Description', ADevice.Description);
    SetStrParam(Q, 'ReportingForm', ADevice.ReportingForm);

    Q.ExecSQL;

    UpdateDevicePoints(ADevice);
    UpdateSpillages(ADevice);

    ADevice.State := osClean;
    Result := True;

  finally
    Q.Free;
  end;
end;



 {$ENDREGION}

  {$REGION 'Device Points'}

function TDeviceRepository.GenerateDevicePointID: Integer;
begin
  Result := FNextPointID;
  Inc(FNextPointID);
end;

//БД

function TDeviceRepository.RequiredDevicePointColumns: TTableColumns;
begin
  Result := [
    Col('ID', 'INTEGER PRIMARY KEY AUTOINCREMENT'),
    Col('DeviceID', 'INTEGER'),
    Col('DeviceTypePointID', 'INTEGER'),

    Col('Num', 'INTEGER'),

    Col('Name', 'TEXT'),
    Col('Description', 'TEXT'),

    Col('FlowRate', 'REAL'),
    Col('Q', 'REAL'),
    Col('FlowAccuracy', 'TEXT'),

    Col('Pressure', 'REAL'),
    Col('Temp', 'REAL'),
    Col('TempAccuracy', 'TEXT'),

    Col('LimitImp', 'INTEGER'),
    Col('LimitVolume', 'REAL'),
    Col('LimitTime', 'REAL'),

    Col('Error', 'REAL'),

    Col('Pause', 'INTEGER'),

    Col('RepeatsProtocol', 'INTEGER'),
    Col('Repeats', 'INTEGER')
  ];
end;

procedure TDeviceRepository.EnsureDevicePointSchema;
begin
  FDM.EnsureTable('DevicePoint', RequiredDevicePointColumns);
end;

procedure TDeviceRepository.AssertDevicePointSchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('DevicePoint');
  Missing := TStringList.Create;
  try
    Cols := RequiredDevicePointColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с DevicePoint.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

function TDeviceRepository.MapDevicePointFromQuery(
  Q: TFDQuery
): TDevicePoint;
var

DeviceID : Integer;
ADevice : TDevice;


begin

   DeviceID := Q.FieldByName('DeviceID').AsInteger;

   ADevice := FindDeviceByID(DeviceID);
   if ADevice = nil then
     raise Exception.CreateFmt('Device for point not found (DeviceID=%d)', [DeviceID]);

   Result := ADevice.AddPoint;

  {================ Идентификация ================}
  Result.ID := Q.FieldByName('ID').AsInteger;
  Result.DeviceID := DeviceID;
  Result.DeviceTypePointID := Q.FieldByName('DeviceTypePointID').AsInteger;
  Result.Num := Q.FieldByName('Num').AsInteger;

  {================ Общая информация =============}
  Result.Name := Q.FieldByName('Name').AsString;
  Result.Description := Q.FieldByName('Description').AsString;

  {================ Расход =======================}
  Result.FlowRate := Q.FieldByName('FlowRate').AsFloat;
  Result.Q := Q.FieldByName('Q').AsFloat;
  Result.FlowAccuracy := Q.FieldByName('FlowAccuracy').AsString;

  {================ Условия ======================}
  Result.Pressure := Q.FieldByName('Pressure').AsFloat;
  Result.Temp := Q.FieldByName('Temp').AsFloat;
  Result.TempAccuracy := Q.FieldByName('TempAccuracy').AsString;

  {================ Ограничения ==================}
  Result.LimitImp := Q.FieldByName('LimitImp').AsInteger;
  Result.LimitVolume := Q.FieldByName('LimitVolume').AsFloat;
  Result.LimitTime := Q.FieldByName('LimitTime').AsFloat;

  {================ Погрешности ==================}
  Result.Error := Q.FieldByName('Error').AsFloat;

  {================ Дополнительно ================}
  Result.Pause := Q.FieldByName('Pause').AsInteger;

  {================ Повторы ======================}
  Result.RepeatsProtocol := Q.FieldByName('RepeatsProtocol').AsInteger;
  Result.Repeats := Q.FieldByName('Repeats').AsInteger;

  Result.State := osClean;
end;


function TDeviceRepository.FindDeviceByID(
  ADeviceID: Integer
): TDevice;
var
  D: TDevice;
begin
  Result := nil;

  if (ADeviceID <= 0) or (FDevices = nil) then
    Exit;

  for D in FDevices do
    if D.ID = ADeviceID then
      Exit(D);
end;

function TDeviceRepository.LoadDevicePointsByDevice(ADeviceID: Integer): Boolean;
var
  Q: TFDQuery;
  Device: TDevice;
begin
  Result := False;

  if (ADeviceID <= 0) or (FDM = nil) then
    Exit;

  Device := FindDeviceByID(ADeviceID);
  if (Device = nil) then
    Exit;

  if Device.Points = nil then
    Device.Points := TObjectList<TDevicePoint>.Create(True)
  else
    Device.Points.Clear;

  Q := FDM.CreateQuery;
  try
    Q.SQL.Text :=
      'select * from DevicePoint ' +
      'where DeviceID = :ID ' +
      'order by Num';

    SetIntParam(Q, 'ID', ADeviceID);
    Q.Open;

    while not Q.Eof do
    begin
      (MapDevicePointFromQuery(Q));
      Q.Next;
    end;

    Result := True;
  finally
    Q.Free;
  end;
end;


function TDeviceRepository.UpdateDevicePoints(
  ADevice: TDevice
): Boolean;
var
  P: TDevicePoint;
  Q: TFDQuery;
  KeepIDs: string;
begin
  Result := False;

  if (ADevice = nil) or (ADevice.Points = nil) then
    Exit;

  for P in ADevice.Points do
  begin
    if P <> nil then
      P.DeviceID := ADevice.ID;

    if not UpdateDevicePoint(P) then
      Exit(False);
  end;

  {--------------------------------------------------}
  { Жёсткая синхронизация состава точек в БД: }
  { удаляем всё, чего нет в актуальном списке прибора }
  {--------------------------------------------------}
  KeepIDs := '';
  for P in ADevice.Points do
    if (P <> nil) and (P.State <> osDeleted) and (P.ID > 0) then
    begin
      if KeepIDs <> '' then
        KeepIDs := KeepIDs + ',';
      KeepIDs := KeepIDs + IntToStr(P.ID);
    end;

  Q := FDM.CreateQuery;
  try
    if KeepIDs = '' then
      Q.SQL.Text :=
        'delete from DevicePoint where DeviceID = :DeviceID'
    else
      Q.SQL.Text :=
        'delete from DevicePoint where DeviceID = :DeviceID and ID not in (' + KeepIDs + ')';

    SetIntParam(Q, 'DeviceID', ADevice.ID);
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  {--------------------------------------------------}
  { Жёсткая синхронизация состава точек в БД: }
  { удаляем всё, чего нет в актуальном списке прибора }
  {--------------------------------------------------}
  KeepIDs := '';
  for P in ADevice.Points do
    if (P <> nil) and (P.State <> osDeleted) and (P.ID > 0) then
    begin
      if KeepIDs <> '' then
        KeepIDs := KeepIDs + ',';
      KeepIDs := KeepIDs + IntToStr(P.ID);
    end;

  Q := FDM.CreateQuery;
  try
    if KeepIDs = '' then
      Q.SQL.Text :=
        'delete from DevicePoint where DeviceID = :DeviceID'
    else
      Q.SQL.Text :=
        'delete from DevicePoint where DeviceID = :DeviceID and ID not in (' + KeepIDs + ')';

    SetIntParam(Q, 'DeviceID', ADevice.ID);
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  Result := True;
end;

function TDeviceRepository.UpdateDevicePoint(
  APoint: TDevicePoint
): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (APoint = nil) or (FDM = nil) then
    Exit;

  if APoint.State = osClean then
    Exit(True);

  { защита: точка обязана принадлежать прибору }
  if APoint.DeviceID <= 0 then
    raise Exception.Create('DevicePoint must have valid DeviceID');

  Q := FDM.CreateQuery;
  try
    case APoint.State of

      {======================= DELETE =======================}
      osDeleted:
        begin
          if APoint.ID <= 0 then
            Exit(True);  // новая точка — просто забываем

          Q.SQL.Text :=
            'delete from DevicePoint where ID = :ID and DeviceID = :DeviceID';

          SetIntParam(Q, 'ID', APoint.ID);
          SetIntParam(Q, 'DeviceID', APoint.DeviceID);
          Q.ExecSQL;

          if Q.RowsAffected = 0 then
            raise Exception.CreateFmt(
              'DevicePoint not deleted (ID=%d, DeviceID=%d)',
              [APoint.ID, APoint.DeviceID]
            );

          Exit(True);
        end;

      {======================= INSERT =======================}
      osNew:
        begin
          Q.SQL.Text :=
            'insert into DevicePoint (' +
            'DeviceID, DeviceTypePointID, Num, Name, Description, ' +
            'FlowRate, Q, FlowAccuracy, ' +
            'Pressure, Temp, TempAccuracy, ' +
            'LimitImp, LimitVolume, LimitTime, ' +
            'Error, Pause, RepeatsProtocol, Repeats' +
            ') values (' +
            ':DeviceID, :DeviceTypePointID, :Num, :Name, :Description, ' +
            ':FlowRate, :Q, :FlowAccuracy, ' +
            ':Pressure, :Temp, :TempAccuracy, ' +
            ':LimitImp, :LimitVolume, :LimitTime, ' +
            ':Error, :Pause, :RepeatsProtocol, :Repeats' +
            ')';
        end;

      {======================= UPDATE =======================}
      osModified:
        begin
          if APoint.ID <= 0 then
            raise Exception.Create('Cannot update DevicePoint without ID');

          Q.SQL.Text :=
            'update DevicePoint set ' +
            'DeviceID=:DeviceID, ' +
            'DeviceTypePointID=:DeviceTypePointID, ' +
            'Num=:Num, Name=:Name, Description=:Description, ' +
            'FlowRate=:FlowRate, Q=:Q, FlowAccuracy=:FlowAccuracy, ' +
            'Pressure=:Pressure, Temp=:Temp, TempAccuracy=:TempAccuracy, ' +
            'LimitImp=:LimitImp, LimitVolume=:LimitVolume, LimitTime=:LimitTime, ' +
            'Error=:Error, Pause=:Pause, ' +
            'RepeatsProtocol=:RepeatsProtocol, Repeats=:Repeats ' +
            'where ID=:ID';
        end;

    else
      Exit(True);
    end;

    {======================= ПАРАМЕТРЫ =======================}

    if APoint.State <> osNew then
      SetIntParam(Q, 'ID', APoint.ID);

    SetIntParam(Q, 'DeviceID', APoint.DeviceID);
    SetIntParam(Q, 'DeviceTypePointID', APoint.DeviceTypePointID);
    SetIntParam(Q, 'Num', APoint.Num);

    SetStrParam(Q, 'Name', APoint.Name);
    SetStrParam(Q, 'Description', APoint.Description);

    SetFloatParam(Q, 'FlowRate', APoint.FlowRate);
    SetFloatParam(Q, 'Q', APoint.Q);
    SetStrParam(Q, 'FlowAccuracy', APoint.FlowAccuracy);

    SetFloatParam(Q, 'Pressure', APoint.Pressure);
    SetFloatParam(Q, 'Temp', APoint.Temp);
    SetStrParam(Q, 'TempAccuracy', APoint.TempAccuracy);

    SetIntParam(Q, 'LimitImp', APoint.LimitImp);
    SetFloatParam(Q, 'LimitVolume', APoint.LimitVolume);
    SetFloatParam(Q, 'LimitTime', APoint.LimitTime);

    SetFloatParam(Q, 'Error', APoint.Error);
    SetIntParam(Q, 'Pause', APoint.Pause);
    SetIntParam(Q, 'RepeatsProtocol', APoint.RepeatsProtocol);
    SetIntParam(Q, 'Repeats', APoint.Repeats);

    {======================= EXEC =======================}

    Q.ExecSQL;

    { 🔴 получаем ID, сгенерированный БД }
    if APoint.State = osNew then
      APoint.ID :=
        Q.Connection.ExecSQLScalar(
          'select last_insert_rowid()'
        );

    APoint.State := osClean;
    Result := True;

  finally
    Q.Free;
  end;
end;

    {$ENDREGION}

 {$REGION 'Spillage Points'}

// БД !!

function TDeviceRepository.RequiredSpillageColumns: TTableColumns;
begin
  Result := [
    Col('ID', 'INTEGER PRIMARY KEY AUTOINCREMENT'),

    { Связи }
    Col('DeviceID', 'INTEGER'),
    Col('DevicePointID', 'INTEGER'),
    Col('DeviceTypePointID', 'INTEGER'),

    { Общая информация }
    Col('Num', 'INTEGER'),
    Col('Name', 'TEXT'),
    Col('Description', 'TEXT'),
    Col('DateTime', 'DATETIME'),

    { Эталон / установка }
    Col('SpillTime', 'REAL'),
    Col('QavgEtalon', 'REAL'),
    Col('EtalonVolume', 'REAL'),
    Col('EtalonMass', 'REAL'),

    { Статистика эталона }
    Col('QEtalonStd', 'REAL'),
    Col('QEtalonCV', 'REAL'),

    { Показания прибора }
    Col('DeviceVolume', 'REAL'),
    Col('DeviceMass', 'REAL'),
    Col('Velocity', 'REAL'),

    { Результат }
    Col('Error', 'REAL'),
    Col('Valid', 'INTEGER'),

    { Статистика прибора }
    Col('QStd', 'REAL'),
    Col('QCV', 'REAL'),

    { Счётчики }
    Col('VolumeBefore', 'REAL'),
    Col('VolumeAfter', 'REAL'),

    { Сырые данные }
    Col('PulseCount', 'INTEGER'),
    Col('MeanFrequency', 'REAL'),
    Col('AvgCurrent', 'REAL'),
    Col('AvgVoltage', 'REAL'),
    Col('Data1', 'TEXT'),
    Col('Data2', 'TEXT'),
    Col('ArchivedData', 'TEXT'),

    { Жидкость }
    Col('StartTemperature', 'REAL'),
    Col('EndTemperature', 'REAL'),
    Col('AvgTemperature', 'REAL'),
    Col('InputPressure', 'REAL'),
    Col('OutputPressure', 'REAL'),
    Col('Density', 'REAL'),

    { Окружающая среда }
    Col('AmbientTemperature', 'REAL'),
    Col('AtmosphericPressure', 'REAL'),
    Col('RelativeHumidity', 'REAL'),

    { Параметры прибора }
    Col('Coef', 'REAL'),
    Col('FCDCoefficient', 'TEXT')
  ];
end;

procedure TDeviceRepository.EnsureSpillageSchema;
begin
  FDM.EnsureTable('PointSpillage', RequiredSpillageColumns);
end;

procedure TDeviceRepository.AssertSpillageSchema;
var
  Existing: TStringList;
  Missing: TStringList;
  Cols: TTableColumns;
  I: Integer;
begin
  Existing := FDM.GetTableColumns('PointSpillage');
  Missing := TStringList.Create;
  try
    Cols := RequiredSpillageColumns;

    for I := Low(Cols) to High(Cols) do
      if Existing.IndexOf(Cols[I].Name) < 0 then
        Missing.Add(Cols[I].Name);

    if Missing.Count > 0 then
      raise Exception.Create(
        'Схема БД несовместима с PointSpillage.' + sLineBreak +
        'Отсутствуют колонки:' + sLineBreak +
        Missing.Text
      );
  finally
    Existing.Free;
    Missing.Free;
  end;
end;

function TDeviceRepository.MapSpillageFromQuery(
  Q: TFDQuery
): TPointSpillage;
var
DeviceID: Integer;
ADevice : TDevice;
begin
   DeviceID:= Q.FieldByName('DeviceID').AsInteger;
   ADevice := FindDeviceByID(DeviceID);
  Result := ADevice.AddSpillage;

  {================ Идентификация ================}
  Result.ID := Q.FieldByName('ID').AsInteger;
  Result.DevicePointID := Q.FieldByName('DevicePointID').AsInteger;
  Result.DeviceTypePointID := Q.FieldByName('DeviceTypePointID').AsInteger;
  Result.Num := Q.FieldByName('Num').AsInteger;

  {================ Общая информация =============}
  Result.Name := Q.FieldByName('Name').AsString;
  Result.Description := Q.FieldByName('Description').AsString;

  if not Q.FieldByName('DateTime').IsNull then
    Result.DateTime := Q.FieldByName('DateTime').AsDateTime;

  {================ Эталон / установка ===========}
  Result.SpillTime := Q.FieldByName('SpillTime').AsFloat;
  Result.QavgEtalon := Q.FieldByName('QavgEtalon').AsFloat;
  Result.EtalonVolume := Q.FieldByName('EtalonVolume').AsFloat;
  Result.EtalonMass := Q.FieldByName('EtalonMass').AsFloat;

  {================ Статистика эталона ===========}
  Result.QEtalonStd := Q.FieldByName('QEtalonStd').AsFloat;
  Result.QEtalonCV := Q.FieldByName('QEtalonCV').AsFloat;

  {================ Показания прибора ============}
  Result.DeviceVolume := Q.FieldByName('DeviceVolume').AsFloat;
  Result.DeviceMass := Q.FieldByName('DeviceMass').AsFloat;
  Result.Velocity := Q.FieldByName('Velocity').AsFloat;

  {================ Результат ====================}
  Result.Error := Q.FieldByName('Error').AsFloat;
  Result.Valid := Q.FieldByName('Valid').AsInteger <> 0;

  {================ Статистика прибора ============}
  Result.QStd := Q.FieldByName('QStd').AsFloat;
  Result.QCV := Q.FieldByName('QCV').AsFloat;

  {================ Счётчики =====================}
  Result.VolumeBefore := Q.FieldByName('VolumeBefore').AsFloat;
  Result.VolumeAfter := Q.FieldByName('VolumeAfter').AsFloat;

  {================ Сырые данные =================}
  Result.PulseCount := Q.FieldByName('PulseCount').AsInteger;
  Result.MeanFrequency := Q.FieldByName('MeanFrequency').AsFloat;
  Result.AvgCurrent := Q.FieldByName('AvgCurrent').AsFloat;
  Result.AvgVoltage := Q.FieldByName('AvgVoltage').AsFloat;
  Result.Data1 := Q.FieldByName('Data1').AsString;
  Result.Data2 := Q.FieldByName('Data2').AsString;
  Result.ArchivedData := Q.FieldByName('ArchivedData').AsString;

  {================ Жидкость =====================}
  Result.StartTemperature := Q.FieldByName('StartTemperature').AsFloat;
  Result.EndTemperature := Q.FieldByName('EndTemperature').AsFloat;
  Result.AvgTemperature := Q.FieldByName('AvgTemperature').AsFloat;
  Result.InputPressure := Q.FieldByName('InputPressure').AsFloat;
  Result.OutputPressure := Q.FieldByName('OutputPressure').AsFloat;
  Result.Density := Q.FieldByName('Density').AsFloat;

  {================ Окружающая среда ==============}
  Result.AmbientTemperature := Q.FieldByName('AmbientTemperature').AsFloat;
  Result.AtmosphericPressure := Q.FieldByName('AtmosphericPressure').AsFloat;
  Result.RelativeHumidity := Q.FieldByName('RelativeHumidity').AsFloat;

  {================ Параметры прибора =============}
  Result.Coef := Q.FieldByName('Coef').AsFloat;
  Result.FCDCoefficient := Q.FieldByName('FCDCoefficient').AsString;

  Result.State := osClean;
end;

function TDeviceRepository.LoadSpillagesByDevice(
  ADeviceID: Integer
): Boolean;
var
  Q: TFDQuery;
  Device: TDevice;
begin
  Result := False;

  if (ADeviceID <= 0) or (FDM = nil) then
    Exit;

  Device := FindDeviceByID(ADeviceID);
  if Device = nil then
    Exit;

  if Device.Spillages = nil then
    Device.Spillages := TObjectList<TPointSpillage>.Create(True)
  else
    Device.Spillages.Clear;

  Q := FDM.CreateQuery;
  try
    Q.SQL.Text :=
      'select * from PointSpillage ' +
      'where DeviceID = :ID ' +
      'order by Num';

    SetIntParam(Q, 'ID', ADeviceID);
    Q.Open;

    while not Q.Eof do
    begin
      MapSpillageFromQuery(Q);
      Q.Next;
    end;

    Result := True;
  finally
    Q.Free;
  end;
end;

function TDeviceRepository.UpdateSpillages(
  ADevice: TDevice
): Boolean;
var
  S: TPointSpillage;
begin
  Result := False;

  if (ADevice = nil) or (ADevice.Spillages = nil) then
    Exit;

  for S in ADevice.Spillages do
    if (S.DeviceID = ADevice.ID) and
       not UpdateSpillage(S) then
      Exit(False);

  Result := True;
end;

function TDeviceRepository.UpdateSpillage(
  ASpillage: TPointSpillage
): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  if (ASpillage = nil) or (FDM = nil) then
    Exit;

  if ASpillage.State = osClean then
    Exit(True);

  Q := FDM.CreateQuery;
  try
    case ASpillage.State of

      osDeleted:
        begin
          Q.SQL.Text :=
            'delete from PointSpillage where ID = :ID';
          SetIntParam(Q, 'ID', ASpillage.ID);
          Q.ExecSQL;
          Exit(True);
        end;

      osNew:
        Q.SQL.Text :=
          'insert into PointSpillage (' +
          'DeviceID, DevicePointID, DeviceTypePointID, Num, ' +
          'Name, Description, DateTime, ' +
          'SpillTime, QavgEtalon, EtalonVolume, EtalonMass, ' +
          'QEtalonStd, QEtalonCV, ' +
          'DeviceVolume, DeviceMass, Velocity, ' +
          'Error, Valid, QStd, QCV, ' +
          'VolumeBefore, VolumeAfter, ' +
          'PulseCount, MeanFrequency, AvgCurrent, AvgVoltage, ' +
          'Data1, Data2, ArchivedData, ' +
          'StartTemperature, EndTemperature, AvgTemperature, ' +
          'InputPressure, OutputPressure, Density, ' +
          'AmbientTemperature, AtmosphericPressure, RelativeHumidity, ' +
          'Coef, FCDCoefficient' +
          ') values (' +
          ':DeviceID, :DevicePointID, :DeviceTypePointID, :Num, ' +
          ':Name, :Description, :DateTime, ' +
          ':SpillTime, :QavgEtalon, :EtalonVolume, :EtalonMass, ' +
          ':QEtalonStd, :QEtalonCV, ' +
          ':DeviceVolume, :DeviceMass, :Velocity, ' +
          ':Error, :Valid, :QStd, :QCV, ' +
          ':VolumeBefore, :VolumeAfter, ' +
          ':PulseCount, :MeanFrequency, :AvgCurrent, :AvgVoltage, ' +
          ':Data1, :Data2, :ArchivedData, ' +
          ':StartTemperature, :EndTemperature, :AvgTemperature, ' +
          ':InputPressure, :OutputPressure, :Density, ' +
          ':AmbientTemperature, :AtmosphericPressure, :RelativeHumidity, ' +
          ':Coef, :FCDCoefficient' +
          ')';

      osModified:
        begin
          Q.SQL.Text :=
            'update PointSpillage set ' +
            'DeviceID=:DeviceID, DevicePointID=:DevicePointID, DeviceTypePointID=:DeviceTypePointID, Num=:Num, ' +
            'Name=:Name, Description=:Description, DateTime=:DateTime, ' +
            'SpillTime=:SpillTime, QavgEtalon=:QavgEtalon, EtalonVolume=:EtalonVolume, EtalonMass=:EtalonMass, ' +
            'QEtalonStd=:QEtalonStd, QEtalonCV=:QEtalonCV, ' +
            'DeviceVolume=:DeviceVolume, DeviceMass=:DeviceMass, Velocity=:Velocity, ' +
            'Error=:Error, Valid=:Valid, QStd=:QStd, QCV=:QCV, ' +
            'VolumeBefore=:VolumeBefore, VolumeAfter=:VolumeAfter, ' +
            'PulseCount=:PulseCount, MeanFrequency=:MeanFrequency, AvgCurrent=:AvgCurrent, AvgVoltage=:AvgVoltage, ' +
            'Data1=:Data1, Data2=:Data2, ArchivedData=:ArchivedData, ' +
            'StartTemperature=:StartTemperature, EndTemperature=:EndTemperature, AvgTemperature=:AvgTemperature, ' +
            'InputPressure=:InputPressure, OutputPressure=:OutputPressure, Density=:Density, ' +
            'AmbientTemperature=:AmbientTemperature, AtmosphericPressure=:AtmosphericPressure, RelativeHumidity=:RelativeHumidity, ' +
            'Coef=:Coef, FCDCoefficient=:FCDCoefficient ' +
            'where ID=:ID';

          SetIntParam(Q, 'ID', ASpillage.ID);
        end;
    end;

    { -------- параметры -------- }
    SetIntParam(Q, 'DeviceID', ASpillage.DeviceID);
    SetIntParam(Q, 'DevicePointID', ASpillage.DevicePointID);
    SetIntParam(Q, 'DeviceTypePointID', ASpillage.DeviceTypePointID);
    SetIntParam(Q, 'Num', ASpillage.Num);

    SetStrParam(Q, 'Name', ASpillage.Name);
    SetStrParam(Q, 'Description', ASpillage.Description);
    SetDateTimeParam(Q, 'DateTime', ASpillage.DateTime);

    SetFloatParam(Q, 'SpillTime', ASpillage.SpillTime);
    SetFloatParam(Q, 'QavgEtalon', ASpillage.QavgEtalon);
    SetFloatParam(Q, 'EtalonVolume', ASpillage.EtalonVolume);
    SetFloatParam(Q, 'EtalonMass', ASpillage.EtalonMass);

    SetFloatParam(Q, 'QEtalonStd', ASpillage.QEtalonStd);
    SetFloatParam(Q, 'QEtalonCV', ASpillage.QEtalonCV);

    SetFloatParam(Q, 'DeviceVolume', ASpillage.DeviceVolume);
    SetFloatParam(Q, 'DeviceMass', ASpillage.DeviceMass);
    SetFloatParam(Q, 'Velocity', ASpillage.Velocity);

    SetFloatParam(Q, 'Error', ASpillage.Error);
    SetIntParam(Q, 'Valid', Ord(ASpillage.Valid));

    SetFloatParam(Q, 'QStd', ASpillage.QStd);
    SetFloatParam(Q, 'QCV', ASpillage.QCV);

    SetFloatParam(Q, 'VolumeBefore', ASpillage.VolumeBefore);
    SetFloatParam(Q, 'VolumeAfter', ASpillage.VolumeAfter);

    SetIntParam(Q, 'PulseCount', ASpillage.PulseCount);
    SetFloatParam(Q, 'MeanFrequency', ASpillage.MeanFrequency);
    SetFloatParam(Q, 'AvgCurrent', ASpillage.AvgCurrent);
    SetFloatParam(Q, 'AvgVoltage', ASpillage.AvgVoltage);

    SetStrParam(Q, 'Data1', ASpillage.Data1);
    SetStrParam(Q, 'Data2', ASpillage.Data2);
    SetStrParam(Q, 'ArchivedData', ASpillage.ArchivedData);

    SetFloatParam(Q, 'StartTemperature', ASpillage.StartTemperature);
    SetFloatParam(Q, 'EndTemperature', ASpillage.EndTemperature);
    SetFloatParam(Q, 'AvgTemperature', ASpillage.AvgTemperature);
    SetFloatParam(Q, 'InputPressure', ASpillage.InputPressure);
    SetFloatParam(Q, 'OutputPressure', ASpillage.OutputPressure);
    SetFloatParam(Q, 'Density', ASpillage.Density);

    SetFloatParam(Q, 'AmbientTemperature', ASpillage.AmbientTemperature);
    SetFloatParam(Q, 'AtmosphericPressure', ASpillage.AtmosphericPressure);
    SetFloatParam(Q, 'RelativeHumidity', ASpillage.RelativeHumidity);

    SetFloatParam(Q, 'Coef', ASpillage.Coef);
    SetStrParam(Q, 'FCDCoefficient', ASpillage.FCDCoefficient);

    Q.ExecSQL;

    if ASpillage.State = osNew then
      ASpillage.ID :=
        FDM.DevicesConnection.GetLastAutoGenValue('PointSpillage');

    ASpillage.State := osClean;
    Result := True;

  finally
    Q.Free;
  end;
end;


//function TDeviceRepository.SaveSpillages: Boolean;
//var
//  S: TPointSpillage;
//  Q: TFDQuery;
//begin
//  Result := False;
//
//  if (FDM = nil) or (FSpillages = nil) then
//    Exit;
//
//  FDM.StartTransaction;
//  try
//    for S in FSpillages do
//    begin
//      if S.State = osClean then
//        Continue;
//
//      Q := FDM.CreateQuery;
//      try
//        case S.State of
//
//          osDeleted:
//            begin
//              Q.SQL.Text :=
//                'delete from PointSpillage where ID = :ID';
//              SetIntParam(Q, 'ID', S.ID);
//              Q.ExecSQL;
//            end;
//
//          osNew:
//            begin
//              Q.SQL.Text :=
//                'insert into PointSpillage (' +
//                'DeviceID, DevicePointID, DeviceTypePointID, Num, ' +
//                'Name, Description, DateTime, ' +
//                'SpillTime, QavgEtalon, EtalonVolume, EtalonMass, ' +
//                'QEtalonStd, QEtalonCV, ' +
//                'DeviceVolume, DeviceMass, Velocity, ' +
//                'Error, Valid, QStd, QCV, ' +
//                'VolumeBefore, VolumeAfter, ' +
//                'PulseCount, MeanFrequency, AvgCurrent, AvgVoltage, ' +
//                'Data1, Data2, ArchivedData, ' +
//                'StartTemperature, EndTemperature, AvgTemperature, ' +
//                'InputPressure, OutputPressure, Density, ' +
//                'AmbientTemperature, AtmosphericPressure, RelativeHumidity, ' +
//                'Coef, FCDCoefficient' +
//                ') values (' +
//                ':DeviceID, :DevicePointID, :DeviceTypePointID, :Num, ' +
//                ':Name, :Description, :DateTime, ' +
//                ':SpillTime, :QavgEtalon, :EtalonVolume, :EtalonMass, ' +
//                ':QEtalonStd, :QEtalonCV, ' +
//                ':DeviceVolume, :DeviceMass, :Velocity, ' +
//                ':Error, :Valid, :QStd, :QCV, ' +
//                ':VolumeBefore, :VolumeAfter, ' +
//                ':PulseCount, :MeanFrequency, :AvgCurrent, :AvgVoltage, ' +
//                ':Data1, :Data2, :ArchivedData, ' +
//                ':StartTemperature, :EndTemperature, :AvgTemperature, ' +
//                ':InputPressure, :OutputPressure, :Density, ' +
//                ':AmbientTemperature, :AtmosphericPressure, :RelativeHumidity, ' +
//                ':Coef, :FCDCoefficient' +
//                ')';
//            end;
//
//          osModified:
//            begin
//              Q.SQL.Text :=
//                'update PointSpillage set ' +
//                'DeviceID=:DeviceID, DevicePointID=:DevicePointID, DeviceTypePointID=:DeviceTypePointID, Num=:Num, ' +
//                'Name=:Name, Description=:Description, DateTime=:DateTime, ' +
//                'SpillTime=:SpillTime, QavgEtalon=:QavgEtalon, EtalonVolume=:EtalonVolume, EtalonMass=:EtalonMass, ' +
//                'QEtalonStd=:QEtalonStd, QEtalonCV=:QEtalonCV, ' +
//                'DeviceVolume=:DeviceVolume, DeviceMass=:DeviceMass, Velocity=:Velocity, ' +
//                'Error=:Error, Valid=:Valid, QStd=:QStd, QCV=:QCV, ' +
//                'VolumeBefore=:VolumeBefore, VolumeAfter=:VolumeAfter, ' +
//                'PulseCount=:PulseCount, MeanFrequency=:MeanFrequency, AvgCurrent=:AvgCurrent, AvgVoltage=:AvgVoltage, ' +
//                'Data1=:Data1, Data2=:Data2, ArchivedData=:ArchivedData, ' +
//                'StartTemperature=:StartTemperature, EndTemperature=:EndTemperature, AvgTemperature=:AvgTemperature, ' +
//                'InputPressure=:InputPressure, OutputPressure=:OutputPressure, Density=:Density, ' +
//                'AmbientTemperature=:AmbientTemperature, AtmosphericPressure=:AtmosphericPressure, RelativeHumidity=:RelativeHumidity, ' +
//                'Coef=:Coef, FCDCoefficient=:FCDCoefficient ' +
//                'where ID=:ID';
//
//              SetIntParam(Q, 'ID', S.ID);
//            end;
//        end;
//
//        {--------- параметры ---------}
//        SetIntParam(Q, 'DeviceID', S.DeviceID);
//        SetIntParam(Q, 'DevicePointID', S.DevicePointID);
//        SetIntParam(Q, 'DeviceTypePointID', S.DeviceTypePointID);
//        SetIntParam(Q, 'Num', S.Num);
//
//        SetStrParam(Q, 'Name', S.Name);
//        SetStrParam(Q, 'Description', S.Description);
//        SetDateTimeParam(Q, 'DateTime', S.DateTime);
//
//        SetFloatParam(Q, 'SpillTime', S.SpillTime);
//        SetFloatParam(Q, 'QavgEtalon', S.QavgEtalon);
//        SetFloatParam(Q, 'EtalonVolume', S.EtalonVolume);
//        SetFloatParam(Q, 'EtalonMass', S.EtalonMass);
//
//        SetFloatParam(Q, 'QEtalonStd', S.QEtalonStd);
//        SetFloatParam(Q, 'QEtalonCV', S.QEtalonCV);
//
//        SetFloatParam(Q, 'DeviceVolume', S.DeviceVolume);
//        SetFloatParam(Q, 'DeviceMass', S.DeviceMass);
//        SetFloatParam(Q, 'Velocity', S.Velocity);
//
//        SetFloatParam(Q, 'Error', S.Error);
//        SetIntParam(Q, 'Valid', Ord(S.Valid));
//
//        SetFloatParam(Q, 'QStd', S.QStd);
//        SetFloatParam(Q, 'QCV', S.QCV);
//
//        SetFloatParam(Q, 'VolumeBefore', S.VolumeBefore);
//        SetFloatParam(Q, 'VolumeAfter', S.VolumeAfter);
//
//        SetIntParam(Q, 'PulseCount', S.PulseCount);
//        SetFloatParam(Q, 'MeanFrequency', S.MeanFrequency);
//        SetFloatParam(Q, 'AvgCurrent', S.AvgCurrent);
//        SetFloatParam(Q, 'AvgVoltage', S.AvgVoltage);
//
//        SetStrParam(Q, 'Data1', S.Data1);
//        SetStrParam(Q, 'Data2', S.Data2);
//        SetStrParam(Q, 'ArchivedData', S.ArchivedData);
//
//        SetFloatParam(Q, 'StartTemperature', S.StartTemperature);
//        SetFloatParam(Q, 'EndTemperature', S.EndTemperature);
//        SetFloatParam(Q, 'AvgTemperature', S.AvgTemperature);
//        SetFloatParam(Q, 'InputPressure', S.InputPressure);
//        SetFloatParam(Q, 'OutputPressure', S.OutputPressure);
//        SetFloatParam(Q, 'Density', S.Density);
//
//        SetFloatParam(Q, 'AmbientTemperature', S.AmbientTemperature);
//        SetFloatParam(Q, 'AtmosphericPressure', S.AtmosphericPressure);
//        SetFloatParam(Q, 'RelativeHumidity', S.RelativeHumidity);
//
//        SetFloatParam(Q, 'Coef', S.Coef);
//        SetStrParam(Q, 'FCDCoefficient', S.FCDCoefficient);
//
//        Q.ExecSQL;
//
//        if S.State = osNew then
//          S.ID := FDM.DevicesConnection.GetLastAutoGenValue('PointSpillage');
//
//        S.State := osClean;
//
//      finally
//        Q.Free;
//      end;
//    end;
//
//    FDM.Commit;
//    Result := True;
//
//  except
//    FDM.Rollback;
//    raise;
//  end;
//end;
//
 {$ENDREGION}



   {$ENDREGION}
end.
