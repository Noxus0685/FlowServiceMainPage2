unit uDeviceClass;

interface

uses
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.StrUtils,
  System.SysUtils,
  uBaseProcedures,
  uClasses,
  uMeterValue;



type

  TCalibrCoefTableType = (
    cctReference = 0,                 // справочная таблица (в расчётах TMeterValue не применяется)
    cctMeterValueCoef = 1,            // поправка коэффициента пересчёта TMeterValue.Coef
    cctMeterValueFlowRate = 2,        // поправка TMeterValue.FlowRate
    cctMeterValueQuantity = 3,        // поправка TMeterValue.Quantity
    cctMeterValueDensity = 4,         // поправка TMeterValue.Density
    cctDeviceCoefCorrection = 11,     // поправка коэффициента преобразования (для записи в прибор)
    cctDeviceFlowRateCorrection = 12, // поправка расхода (для записи в прибор)
    cctDeviceQuantityCorrection = 13, // поправка количества (для записи в прибор)
    cctDeviceDensityCorrection = 14   // поправка плотности (для записи в прибор)
  );

  TPointSpillage = class;

  TSessionSpillage = class(TTypeEntity)
  public
    DeviceUUID: string;
    DateTimeOpen: TDateTime;
    DateTimeClose: TDateTime;
    OperatorName: string;

    K: Double;
    P: Double;
    Active: Boolean;
    Status: Integer;

    DeviceCoefsName: string;
    DeviceCoefsUUID: string;
    CalibrCoefsName: string;
    CalibrCoefsUUID: string;

    FSpillages: TObjectList<TPointSpillage>;

    constructor Create(const ADeviceUUID: string);
    destructor Destroy; override;
    procedure Assign(ASource: TSessionSpillage);

    property Spillages: TObjectList<TPointSpillage> read FSpillages;
  end;


  TDeviceSortField = (
    dsfName,                 // Наименование прибора
    dsfSerialNumber,         // Серийный номер
    dsfManufacturer,         // Изготовитель
    dsfOwner,                // Владелец
    dsfCategory,             // Категория (CategoryName)
    dsfModification,         // Модификация
    dsfDN,                   // Номинальный диаметр
    dsfQmax,                 // Максимальный расход
    dsfAccuracyClass,        // Класс точности
    dsfReestrNumber,         // Номер в ГРСИ
    dsfProcedure,            // Тип процедуры
    dsfVerificationMethod,   // Методика поверки
    dsfIVI,                  // Межповерочный интервал
    dsfRegDate,              // Дата регистрации
    dsfValidityDate,         // Действует до
    dsfDateOfManufacture     // Дата изготовления
  );

  EPointSpillageType = (
    stWithoutStop = 0,  // без остановки потока
    stWithStop = 1    // с остановкой потока
  );

  EPointEtalonType = (
    etNone = 0,
    etAuto = 1,    // автоматически
    etCompare = 2, // сличение (по расходомеру)
    etWeight = 3   // весовое устройство
  );

  EPointFlowSourceType = (
    fstNone  = 0,  // не определён
    fstPump = 1,     // насос (основной источник)
    fstExternal = 2  // внешний источник (магистраль / подвод)
  );




  TDevicePoint = class (TTypeEntity)
  private
    function GetStopCriteria: TSpillageStopCriteria;
    procedure SetStopCriteria(const Value: TSpillageStopCriteria);
  protected
    procedure SetState(const Value: TObjectState); override;
   public
    DataPoints: TObjectList<TPointSpillage>;          // Все измерения, относящиеся к точке по расходу
    ProtocolDataPoints: TObjectList<TPointSpillage>;  // Лучшие измерения по погрешности (не более RepeatsProtocol)

    Status: Integer;             // Статус точки по результатам анализа измерений
    StatusStr: string;           // Текстовое описание статуса

    ResultError: Double;         // Итоговая (худшая из лучших) погрешность
    AverageError: Double;        // Средняя погрешность лучших измерений
    StdDev: Double;              // СКО погрешности лучших измерений

    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}

    DeviceID: Integer;           // Идентификатор прибора (FK → TDevice.ID)
    DeviceUUID: String;
    DeviceTypePointID: Integer;  // Идентификатор шаблонной точки типа (опционально)

    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}

    {====================================================================}
    { ОСНОВНЫЕ ПАРАМЕТРЫ РАСХОДА }
    {====================================================================}
    FlowRate: Double;            // Отношение Q / Qmax (0..1)
    Q: Double;                   // Абсолютный расход, м3/ч (т/ч)
    FlowAccuracy: string;        // Допустимое отклонение расхода ("±5%", "-5%", "+5%")

    {====================================================================}
    { УСЛОВИЯ ИЗМЕРЕНИЯ }
    {====================================================================}
    Pressure: Double;            // Давление, МПа (0 = не применяется)
    Temp: Double;                // Температура, °C (0 = не применяется)
    TempAccuracy: string;        // Точность задания температуры

    {====================================================================}
    { ОГРАНИЧЕНИЯ ИЗМЕРЕНИЯ }
    {====================================================================}
    LimitImp: Integer;           // Ограничение по импульсам, шт
    LimitVolume: Double;         // Ограничение по объему / массе, л (кг)
    LimitTime: Double;           // Ограничение по времени, сек

    SpillageStop: Integer;       // Критерии остановки (битовая маска)
    SpillageType: Integer;       // Тип пролива (с/без остановки потока)
    EtalonType: Integer;         // Тип эталона
    FlowSorceType: Integer;      // Тип источника расхода

    {====================================================================}
    { МЕТРОЛОГИЧЕСКИЕ ПАРАМЕТРЫ }
    {====================================================================}
    Error: Double;               // Допустимая относительная погрешность, %

    {====================================================================}
    { ДОПОЛНИТЕЛЬНЫЕ ПАРАМЕТРЫ }
    {====================================================================}
    Pause: Integer;              // Время стабилизации перед измерением, сек

    {====================================================================}
    { ПОВТОРЫ И СЕРИИ }
    {====================================================================}
    RepeatsProtocol: Integer;    // Кол-во повторов, идущих в зачёт
    Repeats: Integer;            // Общее кол-во измерений в серии
    RepeatsCompleted: Integer;   // Выполненных измерений

    {====================================================================}
    { СЛУЖЕБНОЕ }
    {====================================================================}
    Num: Integer;                // Порядковый номер точки (для сортировки / UI)
    DateTime: TDateTime;         // Дата/время окончания измерения
    ArchivedData: string;        // Архив сырых данных (по секундам и т.п.)

    constructor Create(ADeviceID : Integer);
    destructor Destroy; override;

    procedure Assign(ASource: TDevicePoint; FullAssign: Boolean);
    procedure Apply(ASource: TTypePoint);
    function GetStatus: string;
    function GetStatusHint: string;
    class function GetPointSpillageTypeText(const AType: EPointSpillageType): string; overload; static;
    class function GetPointSpillageTypeText(const AType: Integer): string; overload; static;
    class function GetPointEtalonTypeText(const AType: EPointEtalonType): string; overload; static;
    class function GetPointEtalonTypeText(const AType: Integer): string; overload; static;
    class function GetPointFlowSourceTypeText(const AType: EPointFlowSourceType): string; overload; static;
    class function GetPointFlowSourceTypeText(const AType: Integer): string; overload; static;

    property StopCriteria: TSpillageStopCriteria read GetStopCriteria write SetStopCriteria;
  end;

  TPointSpillage = class (TTypeEntity)

            const
      // Статусы точки проливки (используются для UI/журнала анализа)
      SPS_CREATED = 0;              // Точка только создана, данные ещё не присваивались
      SPS_DATA_ASSIGNED = 1;        // Данные присвоены, но анализ ещё не выполнен
      SPS_FLOW_NOT_MATCHED = 2;     // Анализ выполнен: расход не сопоставлен ни с одной точкой (серый)
      SPS_STOP_CRITERIA_FAILED = 3; // Анализ выполнен: расход сопоставлен, но критерий остановки не выполнен (серый)
      SPS_ERROR_EXCEEDED = 4;       // Анализ выполнен: критерий остановки выполнен, но погрешность выше допуска (красный)
      SPS_OK = 5;                   // Анализ выполнен: критерий остановки выполнен, погрешность в допуске (зелёный)


  public

    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}

    SessionID: Integer;          // Сессия, к которой относится измерение (FK → TSessionSpillage.ID)
    DevicePointID: Integer;      // Поверочная точка прибора (FK → TDevicePoint.ID)
    DeviceTypePointID: Integer;  // Шаблонная точка типа (опционально)
    EtalonName: string;
    EtalonUUID: string;

    Enabled: Boolean;
    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}

    {====================================================================}
    { ПАРАМЕТРЫ ИЗМЕРЕНИЯ (УСТАНОВКА / ЭТАЛОН) }
    {====================================================================}

    SpillTime: Double;           // Время измерения, сек

    QavgEtalon: Double;          // Средний расход по эталону, м3/ч (т/ч)
    EtalonVolume: Double;        // Объем эталона, л
    EtalonMass: Double;          // Масса эталона, кг

    EtalonVolumeFlow: Double;         //Расчётные велечины
    EtalonMassFlow: Double;         //Расчётные велечины

    {====================================================================}
    { СТАТИСТИКА ЭТАЛОНА }
    {====================================================================}

    QEtalonStd: Double;          // СКО расхода эталона
    QEtalonCV: Double;           // Относительная вариация, %

    {====================================================================}
    { ПОКАЗАНИЯ ПРИБОРА }
    {====================================================================}

    DeviceVolume: Double;        // Объем по прибору, л
    DeviceMass: Double;          // Масса по прибору, кг
    Velocity: Double;            // Скорость потока (если применимо)

    DeviceMassFlow : Double;         //Расчётные велечины
    DeviceVolumeFlow  : Double;      //Расчётные велечины

    {====================================================================}
    { РЕЗУЛЬТАТ ИЗМЕРЕНИЯ }
    {====================================================================}
    Status: Integer;             // Статус анализа точки (см. SPS_*)
    StatusStr: string;           // Текстовое пояснение статуса

    Error: Double;               // Итоговая погрешность, %
    Valid: Boolean;              // Годность измерения (в зачёт / нет)

    {====================================================================}
    { СТАТИСТИКА ПРИБОРА }
    {====================================================================}

    QStd: Double;                // СКО расхода прибора
    QCV: Double;                 // Относительная вариация, %

    {====================================================================}
    { ДОПОЛНИТЕЛЬНО ДЛЯ СЧЁТЧИКОВ }
    {====================================================================}

    VolumeBefore: Double;        // Показания до измерения
    VolumeAfter: Double;         // Показания после измерения

    {====================================================================}
    { СЫРЫЕ ДАННЫЕ ИЗМЕРЕНИЯ }
    {====================================================================}

    PulseCount: Double;          // Кол-во импульсов
    MeanFrequency: Double;       // Средняя частота, Гц
    AvgCurrent: Double;          // Средний ток, мА
    AvgVoltage: Double;          // Среднее напряжение, В

    Data1: string;               // Данные интерфейса 1 (сырьё)
    Data2: string;               // Данные интерфейса 2 (сырьё)

    {====================================================================}
    { ПАРАМЕТРЫ ЖИДКОСТИ }
    {====================================================================}

    StartTemperature: Double;    // Температура в начале
    EndTemperature: Double;      // Температура в конце
    AvgTemperature: Double;      // Средняя температура

    InputPressure: Double;       // Давление на входе
    OutputPressure: Double;      // Давление на выходе
    DeltaPressure: Double;
    Density: Double;             // Плотность жидкости

    {====================================================================}
    { ПАРАМЕТРЫ ОКРУЖАЮЩЕЙ СРЕДЫ }
    {====================================================================}

    AmbientTemperature: Double;  // Температура воздуха
    AtmosphericPressure: Double; // Атмосферное давление
    RelativeHumidity: Double;    // Относительная влажность, %

    {====================================================================}
    { ПАРАМЕТРЫ ПРИБОРА }
    {====================================================================}

    Coef: Double;                // Коэффициент преобразования на момент измерения
    FCDCoefficient: string;      // Коэффициенты коррекции (JSON / строка)

    {====================================================================}
    { СЛУЖЕБНОЕ }
    {====================================================================}

    Num: Integer;                // Порядковый номер проливки
    DateTime: TDateTime;         // Дата/время окончания измерения
    ArchivedData: string;        // Архив сырых данных (по секундам и т.п.)

    constructor Create (ASessionID : Integer);


    procedure Assign(ASource: TPointSpillage);
  end;

  TCalibrCoefItem = class
  public
    Name: string;
    UUID: string;
    TableID: Integer;
    OrderNo: Integer;
    Value: Double;
    Arg: Double;
    QFrom: Double;
    QTo: Double;
    RangeArg: Double;
    K: Double;
    b: Double;
    Enable: Boolean;            // Используется ли точка в расчётах K и P

    function InRange(Q: Double): Boolean;
  end;

  TCalibrCoefTable = class
  public
    ID: Integer;
    UUID: string;
    DeviceID: Integer;
    DeviceUUID: string;
    &Type: Integer;
    Active: Boolean;
    AppliedAt: TDateTime;
    Name: string;
    Comment: string;
    Items: TObjectList<TCalibrCoefItem>;

    constructor Create;
    destructor Destroy; override;

    function FindItemByQ(Q: Double): TCalibrCoefItem;
    function ApplyByQ(Q, X: Double): Double;
  end;

  TDevice = class(TTypeEntity)
  private
      FSpillages  : TObjectList<TPointSpillage>;
      FSessions   : TObjectList<TSessionSpillage>;
      FPoints     : TObjectList<TDevicePoint>;
      FCalibrCoefTable: TObjectList<TCalibrCoefTable>;
      FDeviceType : TDeviceType;
      FDimensions: TList<TDimension>;
      function GetStopCriteria: TSpillageStopCriteria;
      procedure SetStopCriteria(const Value: TSpillageStopCriteria);
      function NormalizeActiveSessionSpillage: TSessionSpillage;
      function GetCalibrCoefTable: TCalibrCoefTable;
      procedure SetCalibrCoefTable(const Value: TCalibrCoefTable);
      function FindDiameter(AType: TDeviceType): TDiameter;
      procedure ApplyType(AType: TDeviceType);
      procedure ApplyDiameter(ADiameter: TDiameter; AType: TDeviceType);
      procedure RecalcPoints;
      procedure CreatePointsFromType(AType: TDeviceType);
  protected
      procedure SetState(const Value: TObjectState); override;
  public
    {====================================================================}
    { ПОЛЯ БД!!! }
    {====================================================================}

    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}
    DeviceTypeUUID: string;      // Ссылка на тип прибора (FK)
    DeviceTypeName: string;     // Имя типа (для отображения)
    DeviceTypeRepo: string;     // Имя типа (для отображения)
    RepoTypeName: string;       // Имя репозитория типа (DeviceTypeUUID)
    RepoTypeUUID: string;       // UUID репозитория типа (DeviceTypeUUID)
    RepoDeviceName: string;     // Имя репозитория прибора (DeviceUUID)
    RepoDeviceUUID: string;     // UUID репозитория прибора (DeviceUUID)

    {====================================================================}
    { НАИМЕНОВАНИЕ И ПАСПОРТНЫЕ ДАННЫЕ }
    {====================================================================}
    SerialNumber: string;       // Серийный номер
    Modification: string;       // Модификация (для АРШИН)

    Manufacturer: string;       // Изготовитель
    Owner: string;              // Владелец
    ReestrNumber: string;       // ГРСИ

    {====================================================================}
    { КЛАССИФИКАЦИЯ }
    {====================================================================}
    Category: Integer;          // Категория СИ (код)
    CategoryName: string;       // Категория СИ (отображение)

    AccuracyClass: string;      // Класс точности

    {====================================================================}
    { СРОКИ И РЕГЛАМЕНТ }
    {====================================================================}
    RegDate: TDate;             // Дата регистрации
    ValidityDate: TDate;        // Действует до
    DateOfManufacture: TDate;   // Дата изготовления
    Documentation: string;
    IVI: Integer;               // Межповерочный интервал, лет

    {====================================================================}
    { МЕТРОЛОГИЯ И ДИАПАЗОНЫ }
    {====================================================================}
    DN: string;                 // Номинальный диаметр
    Qmax: Double;               // Максимальный расход
    Qmin: Double;               // Минимальный расход
    RangeDynamic: Double;       // Динамический диапазон (Qmax / Qmin)

    Error: Double;              // Допустимая погрешность, %

    {====================================================================}
    { ПРОЦЕДУРЫ И МЕТОДИКИ }
    {====================================================================}
    VerificationMethod: string; // Методика поверки
    ProcedureName: string;      // Тип процедуры

    {====================================================================}
    { ИЗМЕРЕНИЯ И СИГНАЛЫ (ОБЩЕЕ) }
    {====================================================================}
    MeasuredDimension: Integer; // Измеряемая величина
    Units: Integer;             // Единицы измерения
    OutputType: Integer;        // Тип выходного сигнала
    DimensionCoef: Integer;     // Представление коэффициента

    {====================================================================}
    { ИМПУЛЬСНЫЙ / ЧАСТОТНЫЙ ВЫХОД }
    {====================================================================}
    OutputSet: Integer;         // Тип выхода
    Freq: Integer;              // Максимальная частота, Гц
    Coef: Double;               // Коэффициент преобразования
    FreqFlowRate: Double;       // Отношение расхода к частоте

    {====================================================================}
    { НАПРЯЖЕНИЕ }
    {====================================================================}
    VoltageRange: Integer;
    VoltageQminRate: Double;
    VoltageQmaxRate: Double;

    {====================================================================}
    { ТОК }
    {====================================================================}
    CurrentRange: Integer;
    CurrentQminRate: Double;
    CurrentQmaxRate: Double;
    IntegrationTime: Integer;

    {====================================================================}
    { ИНТЕРФЕЙС СВЯЗИ }
    {====================================================================}
    ProtocolName: string;
    BaudRate: Integer;
    Parity: Integer;
    DeviceAddress: Integer;

    {====================================================================}
    { ВИЗУАЛЬНЫЙ ВВОД }
    {====================================================================}
    InputType: Integer;

    {====================================================================}
    { ИСПЫТАНИЯ }
    {====================================================================}
    SpillageType: Integer;
    SpillageStop: Integer;
    Repeats: Integer;
    RepeatsProtocol: Integer;
    Status: Integer;            // Итоговый статус прибора по анализу точек (не сохраняется в БД)
    StatusStr: string;          // Текстовое описание итогового статуса (не сохраняется в БД)

    {====================================================================}
    { ОПИСАНИЕ И ПРИМЕЧАНИЯ }
    {====================================================================}
    Comment: string;
    ReportingForm: string;

  public
    constructor Create;
    destructor Destroy;

    procedure Assign(ASource: TDevice; FullAssign: Boolean);
    function Clone: TDevice;
    function GetSearchText: string; override;

    function CompareTo(
      const B: TTypeEntity;
      ASortField: Integer
    ): Integer; overload; override;

    function CompareTo(
      const B: TDevice;
      ASortField: TDeviceSortField
    ): Integer; reintroduce; overload;

    function AddPoint: TDevicePoint;
    function AddSessionSpillage: TSessionSpillage;
    function GetActiveSessionSpillage: TSessionSpillage;
    function AddSpillage: TPointSpillage;
    function IsFlowInPoint(const AFlow: Double; const APoint: TDevicePoint): Boolean;

    function  AnalyseDataPoint(const ASpillage: TPointSpillage): Boolean;
    procedure FillDataPointsList(APoint: TDevicePoint);
    procedure SetDimensions;
    function GetDimensionName: string;
    function ToBaseUnits(const AValue: Double): Double;
    function FromBaseUnits(const AValue: Double): Double;
    procedure AnalyseDevicePointsResults;
    procedure AnalyseResults;


    property  Spillages  : TObjectList<TPointSpillage> read FSpillages write FSpillages;
    property  Sessions   : TObjectList<TSessionSpillage> read FSessions write FSessions;
    property  Points     : TObjectList<TDevicePoint> read  FPoints write  FPoints;
    property  Dimensions : TList<TDimension> read FDimensions;
    property  CalibrCoefTables: TObjectList<TCalibrCoefTable> read FCalibrCoefTable write FCalibrCoefTable;
    property  CalibrCoefTable: TCalibrCoefTable read GetCalibrCoefTable write SetCalibrCoefTable;
    property  StopCriteria: TSpillageStopCriteria read GetStopCriteria write SetStopCriteria;

    procedure AttachType(AType: TDeviceType; RepoName: String);
    procedure AttachDN(ADiameter: TDiameter; AType: TDeviceType);  overload;
    procedure AttachDN(ADN: String; AType: TDeviceType);  overload;
    procedure FillFromType(AType: TDeviceType; const APreservePointsAndSerial: Boolean = False);
    procedure SyncNameWithModificationAndDiameter;

  end;

implementation
uses
  uDataManager,
  uAppServices,
  uRepositories;

class function TDevicePoint.GetPointSpillageTypeText(const AType: EPointSpillageType): string;
begin
  case AType of
    stWithStop: Result := 'С остановкой потока';
    stWithoutStop: Result := 'Без остановки потока';
  else
    Result := 'Неизвестно';
  end;
end;

class function TDevicePoint.GetPointSpillageTypeText(const AType: Integer): string;
begin
  case AType of
    Integer(stWithStop), Integer(stWithoutStop):
      Result := TDevicePoint.GetPointSpillageTypeText(EPointSpillageType(AType));
  else
    Result := 'Неизвестно';
  end;
end;

class function TDevicePoint.GetPointEtalonTypeText(const AType: EPointEtalonType): string;
begin
  case AType of
    etAuto: Result := 'Автоматически';
    etCompare: Result := 'Сличение';
    etWeight: Result := 'Весовое устройство';
  else
    Result := 'Неизвестно';
  end;
end;

class function TDevicePoint.GetPointEtalonTypeText(const AType: Integer): string;
begin
  case AType of
    Integer(etAuto), Integer(etCompare), Integer(etWeight):
      Result := TDevicePoint.GetPointEtalonTypeText(EPointEtalonType(AType));
  else
    Result := 'Неизвестно';
  end;
end;

class function TDevicePoint.GetPointFlowSourceTypeText(const AType: EPointFlowSourceType): string;
begin
  case AType of
    fstNone : Result := '---';
    fstPump: Result := 'Насос';
    fstExternal: Result := 'Внешний источник';
  else
    Result := 'Неизвестно';
  end;
end;

class function TDevicePoint.GetPointFlowSourceTypeText(const AType: Integer): string;
begin
  case AType of
    Integer(fstNone ), Integer(fstPump), Integer(fstExternal):
      Result := TDevicePoint.GetPointFlowSourceTypeText(EPointFlowSourceType(AType));
  else
    Result := 'Неизвестно';
  end;
end;


procedure MarkDeviceAndRepositoryModified(const ADeviceUUID: string);
var
  ADevice: TDevice;
  Repo: TDeviceRepository;
begin


  if (Trim(ADeviceUUID) = '') or (AppServices.DataManager = nil) then
    Exit;

  ADevice := AppServices.DataManager.FindDevice(ADeviceUUID, Repo);

  if (ADevice <> nil) then
    ADevice.State := osModified;

  if (Repo <> nil) then
    Repo.State := osModified;
end;

destructor TDevice.Destroy;
begin
  FSessions.Free;
  FSpillages.Free;
  FPoints.Free;
  FDimensions.Free;
  FCalibrCoefTable.Free;
  inherited;
end;

constructor TDevice.Create;
begin
  inherited Create;

   {----------------------------------}
  { Создание коллекций }
  {----------------------------------}
  FSessions  := TObjectList<TSessionSpillage>.Create(True);
  FSpillages := TObjectList<TPointSpillage>.Create(True);
  FPoints    := TObjectList<TDevicePoint>.Create(True);
  FDimensions := TList<TDimension>.Create;
  FCalibrCoefTable := TObjectList<TCalibrCoefTable>.Create(True);

  {----------------------------------}
  { Идентификация }
  {----------------------------------}
  DeviceTypeUUID := '';
  DeviceTypeName := '';
  DeviceTypeRepo := '';
  RepoTypeName := '';
  RepoTypeUUID := '';
  RepoDeviceName := '';
  RepoDeviceUUID := '';
   {----------------------------------}
  { Наименование и паспорт }
  {----------------------------------}
  Name := '';
  SerialNumber := '';
  Modification := '';

  Manufacturer := '';
  Owner := '';
  ReestrNumber := '';

  {----------------------------------}
  { Классификация }
  {----------------------------------}
  Category := 0;
  CategoryName := '';
  AccuracyClass := '±1.0';

  {----------------------------------}
  { Сроки и регламент }
  {----------------------------------}
  RegDate := Date;                  // дата создания
  IVI := 1;                         // 1 год — самый частый вариант
  ValidityDate := IncYear(RegDate, IVI);
  DateOfManufacture := RegDate;

  {----------------------------------}
  { Метрология }
  {----------------------------------}
  DN := '';
  Qmax := 10.0;                     // м³/ч — типовое значение
  Qmin := 0.1;
  RangeDynamic := 100.0;            // Qmax / Qmin
  Error := 1.0;                     // %

  {----------------------------------}
  { Процедуры }
  {----------------------------------}
  VerificationMethod := '';
  ProcedureName := 'Поверка';

  {----------------------------------}
  { Измерения и сигналы }
  {----------------------------------}
  MeasuredDimension := 0;           // по enum
  Units := 0;
  OutputType := 0;
  DimensionCoef := 1;

  {----------------------------------}
  { Импульс / частота }
  {----------------------------------}
  OutputSet := 0;
  Freq := 1000;                     // Гц
  Coef := 1.0;
  FreqFlowRate := 1.0;

  {----------------------------------}
  { Напряжение }
  {----------------------------------}
  VoltageRange := 24;               // 24 В — промышленный стандарт
  VoltageQminRate := 0.0;
  VoltageQmaxRate := 1.0;

  {----------------------------------}
  { Ток }
  {----------------------------------}
  CurrentRange := 20;               // 4–20 мА
  CurrentQminRate := 0.2;
  CurrentQmaxRate := 1.0;
  IntegrationTime := 1;             // сек

  {----------------------------------}
  { Интерфейс связи }
  {----------------------------------}
  ProtocolName := '';
  BaudRate := 9600;
  Parity := 0;
  DeviceAddress := 1;

  {----------------------------------}
  { Визуальный ввод }
  {----------------------------------}
  InputType := 0;

  {----------------------------------}
  { Испытания }
  {----------------------------------}
  SpillageType := 0;
  SpillageStop := STOP_BY_TIME;
  Repeats := 3;
  RepeatsProtocol := 3;
  Status := 0;
  StatusStr := 'Измерения не производились/не анализировались.';

  {----------------------------------}
  { Описание }
  {----------------------------------}
  Comment := '';
  Description := '';
  ReportingForm := '';
  SetDimensions;
end;

function TDevice.GetStopCriteria: TSpillageStopCriteria;
begin
  Result := IntToCriteria(SpillageStop);
end;

procedure TDevice.SetStopCriteria(const Value: TSpillageStopCriteria);
begin
  SpillageStop := CriteriaToInt(Value);
end;

procedure TDevice.SetDimensions;
  procedure AddDimension(const AName: string; ARate, ADevider: Double; ARecip: Boolean);
  var
    Dim: TDimension;
  begin
    Dim.Name := AName;
    Dim.Hash := '';
    Dim.Rate := ARate;
    Dim.Devider := ADevider;
    Dim.Factor := False;
    Dim.Recip := ARecip;
    FDimensions.Add(Dim);
  end;
begin
  if FDimensions = nil then
    Exit;

  FDimensions.Clear;
  case TMeasuredDimension(MeasuredDimension) of
    mdVolumeFlow:
      begin
        AddDimension('л/с', 1, 1, False);
        AddDimension('л/мин', 60, 1, False);
        AddDimension('л/ч', 3600, 1, False);
        AddDimension('м3/мин', 60, 1000, False);
        AddDimension('м3/ч', 3600, 1000, False);
      end;
    mdMassFlow:
      begin
        AddDimension('кг/с', 1, 1, False);
        AddDimension('кг/мин', 60, 1, False);
        AddDimension('кг/ч', 3600, 1, False);
        AddDimension('т/мин', 60, 1000, False);
        AddDimension('т/ч', 3600, 1000, False);
      end;
    mdVolume:
      begin
        AddDimension('л', 1, 1, False);
        AddDimension('м3', 1, 1000, False);
      end;
    mdMass:
      begin
        AddDimension('кг', 1, 1, False);
        AddDimension('т', 1, 1000, False);
      end;
    mdSpeed:
      begin
        AddDimension('м/с', 1, 1, False);
        AddDimension('км/ч', 3.6, 1, False);
      end;
    mdHeat:
      begin
        AddDimension('Гкал', 1, 1, False);
        AddDimension('МДж', 4.1868, 1, False);
      end;
  end;

  if FDimensions.Count = 0 then
    Units := 0
  else if (Units < 0) or (Units >= FDimensions.Count) then
    Units := 0;
end;

function TDevice.GetDimensionName: string;
begin
  if (FDimensions = nil) or (FDimensions.Count = 0) then
    Exit('-');
  if (Units < 0) or (Units >= FDimensions.Count) then
    Exit(FDimensions[0].Name);
  Result := FDimensions[Units].Name;
end;

function TDevice.ToBaseUnits(const AValue: Double): Double;
var
  Dim: TDimension;
begin
  if (FDimensions = nil) or (FDimensions.Count = 0) then
    Exit(AValue);
  if (Units < 0) or (Units >= FDimensions.Count) then
    Dim := FDimensions[0]
  else
    Dim := FDimensions[Units];

  if Dim.Recip then
  begin
    if AValue = 0 then
      Exit(0);
    Result := (1 / AValue) * Dim.Devider / Dim.Rate;
  end
  else
    Result := AValue * Dim.Devider / Dim.Rate;
end;

function TDevice.FromBaseUnits(const AValue: Double): Double;
var
  Dim: TDimension;
begin
  if (FDimensions = nil) or (FDimensions.Count = 0) then
    Exit(AValue);
  if (Units < 0) or (Units >= FDimensions.Count) then
    Dim := FDimensions[0]
  else
    Dim := FDimensions[Units];

  if Dim.Recip then
  begin
    if AValue = 0 then
      Exit(0);
    Result := 1 / (AValue * Dim.Rate / Dim.Devider);
  end
  else
    Result := AValue * Dim.Rate / Dim.Devider;
end;

procedure TDevice.SetState(const Value: TObjectState);
var
  OldState: TObjectState;
  Session: TSessionSpillage;
  Point: TDevicePoint;
  Spillage: TPointSpillage;
  SessionSpillage: TPointSpillage;
  Repo: TDeviceRepository;
begin
  OldState := FState;
  inherited SetState(Value);

  if FState = osNew then
  begin
    if FPoints <> nil then
      for Point in FPoints do
        Point.State := osNew;

    if FSpillages <> nil then
      for Spillage in FSpillages do
        Spillage.State := osNew;

    if FSessions <> nil then
      for Session in FSessions do
      begin
        Session.State := osNew;
        if Session.Spillages <> nil then
          for SessionSpillage in Session.Spillages do
            SessionSpillage.State := osNew;
      end;
  end;

  if (Value <> OldState) and (Value in [osNew, osModified, osDeleted]) and
     (AppServices.DataManager <> nil) then
  begin
    AppServices.DataManager.FindDevice(UUID, Repo);
    if (Repo <> nil) then
      Repo.State := osModified;
  end;
end;

function TDevice.GetCalibrCoefTable: TCalibrCoefTable;
begin
  Result := nil;
  if (FCalibrCoefTable = nil) or (FCalibrCoefTable.Count = 0) then
    Exit;
  Result := FCalibrCoefTable[0];
end;

procedure TDevice.SetCalibrCoefTable(const Value: TCalibrCoefTable);
var
  NewTable: TCalibrCoefTable;
  SrcItem: TCalibrCoefItem;
  NewItem: TCalibrCoefItem;
begin
  if FCalibrCoefTable = nil then
    FCalibrCoefTable := TObjectList<TCalibrCoefTable>.Create(True);

  FCalibrCoefTable.Clear;
  if Value = nil then
    Exit;

  NewTable := TCalibrCoefTable.Create;
  NewTable.ID := Value.ID;
  NewTable.UUID := Value.UUID;
  NewTable.DeviceID := Value.DeviceID;
  NewTable.DeviceUUID := Value.DeviceUUID;
  NewTable.&Type := Value.&Type;
  NewTable.Active := Value.Active;
  NewTable.AppliedAt := Value.AppliedAt;
  NewTable.Name := Value.Name;
  NewTable.Comment := Value.Comment;

  if Value.Items <> nil then
    for SrcItem in Value.Items do
    begin
      if SrcItem = nil then
        Continue;
      NewItem := TCalibrCoefItem.Create;
      NewItem.Name := SrcItem.Name;
      NewItem.UUID := SrcItem.UUID;
      NewItem.TableID := SrcItem.TableID;
      NewItem.OrderNo := SrcItem.OrderNo;
      NewItem.Value := SrcItem.Value;
      NewItem.Arg := SrcItem.Arg;
      NewItem.QFrom := SrcItem.QFrom;
      NewItem.QTo := SrcItem.QTo;
      NewItem.K := SrcItem.K;
      NewItem.b := SrcItem.b;
      NewItem.Enable := SrcItem.Enable;
      NewTable.Items.Add(NewItem);
    end;

  FCalibrCoefTable.Add(NewTable);
end;

constructor TSessionSpillage.Create(const ADeviceUUID: string);
begin
  inherited Create;

  DeviceUUID := ADeviceUUID;
  DateTimeOpen := 0;
  DateTimeClose := 0;
  OperatorName := '';

  K := 0.0;
  P := 0.0;
  Active := False;
  Status := 0;

  DeviceCoefsName := '';
  DeviceCoefsUUID := '';
  CalibrCoefsName := '';
  CalibrCoefsUUID := '';

  FSpillages := TObjectList<TPointSpillage>.Create(True);
end;

destructor TSessionSpillage.Destroy;
begin
  FSpillages.Free;
  inherited;
end;

procedure TSessionSpillage.Assign(ASource: TSessionSpillage);
begin
  if ASource = nil then
    Exit;

  State := ASource.State;
  ID := ASource.ID;
  DeviceUUID := ASource.DeviceUUID;
  DateTimeOpen := ASource.DateTimeOpen;
  DateTimeClose := ASource.DateTimeClose;
  OperatorName := ASource.OperatorName;
  K := ASource.K;
  P := ASource.P;
  Active := ASource.Active;
  Status := ASource.Status;
  DeviceCoefsName := ASource.DeviceCoefsName;
  DeviceCoefsUUID := ASource.DeviceCoefsUUID;
  CalibrCoefsName := ASource.CalibrCoefsName;
  CalibrCoefsUUID := ASource.CalibrCoefsUUID;

  if FSpillages = nil then
    FSpillages := TObjectList<TPointSpillage>.Create(True)
  else
    FSpillages.Clear;
end;

constructor TDevicePoint.Create(ADeviceID : Integer);
begin
  inherited Create;

  DataPoints := TObjectList<TPointSpillage>.Create(False);
  ProtocolDataPoints := TObjectList<TPointSpillage>.Create(False);

  FID := 0;
  FState := osNew;

  { Идентификация }
  DeviceID := ADeviceID;
  DeviceTypePointID := 0;

  { Общая информация }
  Name := 'Точка измерения';
  Description := 'Точка измерения с заданными параметрами';
  Num := 0;
  DateTime := 0;

  { Параметры расхода }
  FlowRate := 0.0;
  Q := 0.0;
  FlowAccuracy := '';

  { Условия измерения }
  Pressure := 0.0;
  Temp := 0.0;
  TempAccuracy := '';

  { Ограничения }
  LimitImp := 0;
  LimitVolume := 0.0;
  LimitTime := 0.0;
  SpillageStop := STOP_BY_TIME;
  SpillageType := Integer(stWithoutStop);
  EtalonType := Integer(etAuto);
  FlowSorceType := Integer(fstNone );

  { Метрология }
  Error := 0.0;

  { Дополнительно }
  Pause := 0;

  { Повторы }
  RepeatsProtocol := 0;
  Repeats := 0;
  RepeatsCompleted := 0;

  Status := 0;
  StatusStr := '-';
  ResultError := 0.0;
  AverageError := 0.0;
  StdDev := 0.0;
end;



destructor TDevicePoint.Destroy;
begin
  DataPoints.Free;
  ProtocolDataPoints.Free;
  inherited;
end;

procedure TDevicePoint.SetState(const Value: TObjectState);
var
  OldState: TObjectState;
begin
  OldState := FState;
  inherited SetState(Value);

  if (Value = OldState) or not (Value in [osNew, osModified, osDeleted]) then
    Exit;

  MarkDeviceAndRepositoryModified(DeviceUUID);
end;

constructor TPointSpillage.Create(ASessionID : Integer);
begin
  inherited Create;

  { Идентификация }
  SessionID := ASessionID;
  DevicePointID := 0;
  DeviceTypePointID := 0;
  EtalonName := '';
  EtalonUUID := '';
  Enabled := True;
  Num := 0;

  { Общая информация }
  Name := 'Новое измерение';
  Description := ' ';
  { Измерение }
  SpillTime := 0.0;
  QavgEtalon := 0.0;
  EtalonVolume := 0.0;
  EtalonMass := 0.0;

  { Статистика эталона }
  QEtalonStd := 0.0;
  QEtalonCV := 0.0;

  { Показания прибора }
  DeviceVolume := 0.0;
  DeviceMass := 0.0;
  Velocity := 0.0;

  { Результат }
  Status := SPS_CREATED;
  StatusStr := 'Точка создана. Данные измерения ещё не присваивались.';
  Error := 0.0;
  Valid := False;

  { Статистика прибора }
  QStd := 0.0;
  QCV := 0.0;

  { Счётчики }
  VolumeBefore := 0.0;
  VolumeAfter := 0.0;

  { Сырые данные }
  PulseCount := 0.0;
  MeanFrequency := 0.0;
  AvgCurrent := 0.0;
  AvgVoltage := 0.0;
  Data1 := '';
  Data2 := '';
  ArchivedData := '';

  { Жидкость }
  StartTemperature := 0.0;
  EndTemperature := 0.0;
  AvgTemperature := 0.0;
  InputPressure := 0.0;
  OutputPressure := 0.0;
  Density := 0.0;

  { Окружающая среда }
  AmbientTemperature := 0.0;
  AtmosphericPressure := 0.0;
  RelativeHumidity := 0.0;

  { Параметры прибора }
  Coef := 0.0;
  FCDCoefficient := '';
end;

procedure TDevice.Assign(ASource: TDevice; FullAssign: Boolean);
var
  P: TDevicePoint;
  NewP: TDevicePoint;
begin
  if ASource = nil then
    Exit;

  if FullAssign then
   begin
     SerialNumber := ASource.SerialNumber;
     UUID:=  ASource. UUID;
     ID:=  ASource.  ID;
     State  := ASource.State;
   end else
   begin

  //не проверяем изменения свойств, но считаем, что что-то изменилось
  { Состояние }
   State := osModified;
   end;

  { ============================= }
  { 1. Копирование простых полей  }
  { ============================= }

  DeviceTypeUUID := ASource.DeviceTypeUUID;
  DeviceTypeName := ASource.DeviceTypeName;
  DeviceTypeRepo := ASource.DeviceTypeRepo;
  RepoTypeName := ASource.RepoTypeName;
  RepoTypeUUID := ASource.RepoTypeUUID;
  RepoDeviceName := ASource.RepoDeviceName;
  RepoDeviceUUID := ASource.RepoDeviceUUID;

  Name := ASource.Name;

  Modification := ASource.Modification;
  Manufacturer := ASource.Manufacturer;
  Owner := ASource.Owner;
  ReestrNumber := ASource.ReestrNumber;

  Category := ASource.Category;
  CategoryName := ASource.CategoryName;
  AccuracyClass := ASource.AccuracyClass;

  RegDate := ASource.RegDate;
  ValidityDate := ASource.ValidityDate;
  DateOfManufacture := ASource.DateOfManufacture;
  IVI := ASource.IVI;

  DN := ASource.DN;
  Qmax := ASource.Qmax;
  Qmin := ASource.Qmin;
  RangeDynamic := ASource.RangeDynamic;
  Error := ASource.Error;

  VerificationMethod := ASource.VerificationMethod;
  ProcedureName := ASource.ProcedureName;

  MeasuredDimension := ASource.MeasuredDimension;
  Units := ASource.Units;
  SetDimensions;
  OutputType := ASource.OutputType;
  DimensionCoef := ASource.DimensionCoef;

  OutputSet := ASource.OutputSet;
  Freq := ASource.Freq;
  Coef := ASource.Coef;
  FreqFlowRate := ASource.FreqFlowRate;

  VoltageRange := ASource.VoltageRange;
  VoltageQminRate := ASource.VoltageQminRate;
  VoltageQmaxRate := ASource.VoltageQmaxRate;

  CurrentRange := ASource.CurrentRange;
  CurrentQminRate := ASource.CurrentQminRate;
  CurrentQmaxRate := ASource.CurrentQmaxRate;
  IntegrationTime := ASource.IntegrationTime;

  ProtocolName := ASource.ProtocolName;
  BaudRate := ASource.BaudRate;
  Parity := ASource.Parity;
  DeviceAddress := ASource.DeviceAddress;

  InputType := ASource.InputType;

  SpillageType := ASource.SpillageType;
  SpillageStop := ASource.SpillageStop;
  Repeats := ASource.Repeats;
  RepeatsProtocol := ASource.RepeatsProtocol;
  Status := ASource.Status;
  StatusStr := ASource.StatusStr;

  Comment := ASource.Comment;
  Description := ASource.Description;
  ReportingForm := ASource.ReportingForm;

  { ============================= }
  { 2. При копировании НЕ переносим }
  {    сессии, проливы и таблицу КК }
  { ============================= }

  FSessions.Clear;
  FSpillages.Clear;

  FCalibrCoefTable.Clear;

  { ============================= }
  { 3. Глубокое копирование точек }
  { ============================= }

  FPoints.Clear;

  for P in ASource.FPoints do
  begin
    NewP := AddPoint;
    NewP.Assign(P, False);
  end;
end;

function TCalibrCoefItem.InRange(Q: Double): Boolean;
begin
  Result := (Q >= QFrom) and ((Q < QTo) or SameValue(Q, QTo));
end;

constructor TCalibrCoefTable.Create;
begin
  inherited Create;
  &Type := 0;
  Active := False;
  Items := TObjectList<TCalibrCoefItem>.Create(True);
end;

destructor TCalibrCoefTable.Destroy;
begin
  Items.Free;
  inherited;
end;

function TCalibrCoefTable.FindItemByQ(Q: Double): TCalibrCoefItem;
var
  I: Integer;
  LastIndex: Integer;
  Item: TCalibrCoefItem;
begin
  Result := nil;
  if (Items = nil) or (Items.Count = 0) then
    Exit;

  LastIndex := -1;
  for I := 0 to Items.Count - 1 do
    if (Items[I] <> nil) and Items[I].Enable then
      LastIndex := I;

  if LastIndex < 0 then
    Exit;

  for I := 0 to LastIndex do
  begin
    Item := Items[I];
    if (Item = nil) or (not Item.Enable) then
      Continue;

    if (Q >= Item.QFrom) and ((Q < Item.QTo) or ((I = LastIndex) and (Q <= Item.QTo))) then
      Exit(Item);
  end;
end;

function TCalibrCoefTable.ApplyByQ(Q, X: Double): Double;
var
  Item: TCalibrCoefItem;
begin
  Item := FindItemByQ(Q);
  if Item = nil then
    Exit(X);

  Result := X * Item.K + Item.b;
end;

function TDevice.Clone: TDevice;
begin
  Result := TDevice.Create;
  Result.Assign(Self, True);

end;

function TDevice.GetSearchText: string;
var
  B: TStringBuilder;
  P: TDevicePoint;
  Sess: TSessionSpillage;
  S: TPointSpillage;
  procedure Add(const V: string);
  begin
    if Trim(V) = '' then
      Exit;
    B.Append(V).Append(' ');
  end;
begin
  B := TStringBuilder.Create;
  try
    Add(IntToStr(ID));
    Add(Name);
    Add(UUID);
    Add(Description);
    Add(RepoName);

    Add(DeviceTypeUUID);
    Add(DeviceTypeName);
    Add(DeviceTypeRepo);
    Add(RepoTypeName);
    Add(RepoTypeUUID);
    Add(RepoDeviceName);
    Add(RepoDeviceUUID);

    Add(SerialNumber);
    Add(Modification);
    Add(Manufacturer);
    Add(Owner);
    Add(ReestrNumber);

    Add(IntToStr(Category));
    Add(CategoryName);
    Add(AccuracyClass);

    Add(DateToStr(RegDate));
    Add(DateToStr(ValidityDate));
    Add(DateToStr(DateOfManufacture));
    Add(Documentation);
    Add(IntToStr(IVI));

    Add(DN);
    Add(FloatToStr(Qmax));
    Add(FloatToStr(Qmin));
    Add(FloatToStr(RangeDynamic));
    Add(FloatToStr(Error));

    Add(VerificationMethod);
    Add(ProcedureName);

    Add(IntToStr(MeasuredDimension));
    Add(IntToStr(Units));
    Add(IntToStr(OutputType));
    Add(IntToStr(DimensionCoef));

    Add(IntToStr(OutputSet));
    Add(IntToStr(Freq));
    Add(FloatToStr(Coef));
    Add(FloatToStr(FreqFlowRate));

    Add(IntToStr(VoltageRange));
    Add(FloatToStr(VoltageQminRate));
    Add(FloatToStr(VoltageQmaxRate));

    Add(IntToStr(CurrentRange));
    Add(FloatToStr(CurrentQminRate));
    Add(FloatToStr(CurrentQmaxRate));
    Add(IntToStr(IntegrationTime));

    Add(ProtocolName);
    Add(IntToStr(BaudRate));
    Add(IntToStr(Parity));
    Add(IntToStr(DeviceAddress));

    Add(IntToStr(InputType));
    Add(IntToStr(SpillageType));
    Add(IntToStr(SpillageStop));
    Add(IntToStr(Repeats));
    Add(IntToStr(RepeatsProtocol));

    Add(Comment);
    Add(ReportingForm);

    for P in FPoints do
    begin
      Add(IntToStr(P.ID));
      Add(IntToStr(P.DeviceID));
      Add(IntToStr(P.DeviceTypePointID));
      Add(IntToStr(P.Num));
      Add(P.Name);
      Add(P.Description);
      Add(FloatToStr(P.FlowRate));
      Add(FloatToStr(P.Q));
      Add(P.FlowAccuracy);
      Add(FloatToStr(P.Pressure));
      Add(FloatToStr(P.Temp));
      Add(P.TempAccuracy);
      Add(IntToStr(P.LimitImp));
      Add(FloatToStr(P.LimitVolume));
      Add(FloatToStr(P.LimitTime));
      Add(IntToStr(P.SpillageStop));
      Add(FloatToStr(P.Error));
      Add(IntToStr(P.Pause));
      Add(IntToStr(P.RepeatsProtocol));
      Add(IntToStr(P.Repeats));
    end;

    for Sess in FSessions do
    begin
      Add(IntToStr(Sess.ID));
      Add(Sess.DeviceUUID);
      Add(DateTimeToStr(Sess.DateTimeOpen));
      Add(DateTimeToStr(Sess.DateTimeClose));
      Add(Sess.OperatorName);
      Add(FloatToStr(Sess.K));
      Add(FloatToStr(Sess.P));
      Add(BoolToStr(Sess.Active, True));
      Add(Sess.DeviceCoefsName);
      Add(Sess.DeviceCoefsUUID);
      Add(Sess.CalibrCoefsName);
      Add(Sess.CalibrCoefsUUID);
    end;

    for S in FSpillages do
    begin
      Add(IntToStr(S.ID));
      Add(IntToStr(S.SessionID));
      Add(IntToStr(S.DevicePointID));
      Add(IntToStr(S.DeviceTypePointID));
      Add(IntToStr(S.Num));
      Add(S.Description);
      Add(FloatToStr(S.SpillTime));
      Add(FloatToStr(S.QavgEtalon));
      Add(FloatToStr(S.EtalonVolume));
      Add(FloatToStr(S.EtalonMass));
      Add(FloatToStr(S.QEtalonStd));
      Add(FloatToStr(S.QEtalonCV));
      Add(FloatToStr(S.DeviceVolume));
      Add(FloatToStr(S.DeviceMass));
      Add(FloatToStr(S.Velocity));
      Add(IntToStr(S.Status));
      Add(S.StatusStr);
      Add(FloatToStr(S.Error));
      Add(BoolToStr(S.Valid, True));
      Add(FloatToStr(S.QStd));
      Add(FloatToStr(S.QCV));
      Add(FloatToStr(S.VolumeBefore));
      Add(FloatToStr(S.VolumeAfter));
      Add(FloatToStr(S.PulseCount));
      Add(FloatToStr(S.MeanFrequency));
      Add(FloatToStr(S.AvgCurrent));
      Add(FloatToStr(S.AvgVoltage));
      Add(S.Data1);
      Add(S.Data2);
      Add(FloatToStr(S.StartTemperature));
      Add(FloatToStr(S.EndTemperature));
      Add(FloatToStr(S.AvgTemperature));
      Add(FloatToStr(S.InputPressure));
      Add(FloatToStr(S.OutputPressure));
      Add(FloatToStr(S.Density));
      Add(FloatToStr(S.AmbientTemperature));
      Add(FloatToStr(S.AtmosphericPressure));
      Add(FloatToStr(S.RelativeHumidity));
      Add(FloatToStr(S.Coef));
      Add(S.FCDCoefficient);
      Add(S.ArchivedData);
    end;

    Result := Trim(B.ToString);
  finally
    B.Free;
  end;
end;

function TDevice.CompareTo(
  const B: TTypeEntity;
  ASortField: Integer
): Integer;
begin
  if not (B is TDevice) then
    Exit(inherited CompareTo(B, ASortField));

  Result := CompareTo(TDevice(B), TDeviceSortField(ASortField));
end;

function TDevice.CompareTo(
  const B: TDevice;
  ASortField: TDeviceSortField
): Integer;
begin
  Result := 0;
  if B = nil then
    Exit;

  case ASortField of
    dsfName:
      Result := CompareText(Name, B.Name);

    dsfSerialNumber:
      Result := CompareText(SerialNumber, B.SerialNumber);

    dsfManufacturer:
      Result := CompareText(Manufacturer, B.Manufacturer);

    dsfOwner:
      Result := CompareText(Owner, B.Owner);

    dsfCategory:
      Result := CompareText(CategoryName, B.CategoryName);

    dsfModification:
      Result := CompareText(Modification, B.Modification);

    dsfDN:
      Result := CompareText(DN, B.DN);

    dsfQmax:
      Result := CompareValue(Qmax, B.Qmax);

    dsfAccuracyClass:
      Result := CompareText(AccuracyClass, B.AccuracyClass);

    dsfReestrNumber:
      Result := CompareText(ReestrNumber, B.ReestrNumber);

    dsfProcedure:
      Result := CompareText(ProcedureName, B.ProcedureName);

    dsfVerificationMethod:
      Result := CompareText(VerificationMethod, B.VerificationMethod);

    dsfIVI:
      Result := IVI - B.IVI;

    dsfRegDate:
      Result := CompareDate(RegDate, B.RegDate);

    dsfValidityDate:
      Result := CompareDate(ValidityDate, B.ValidityDate);

    dsfDateOfManufacture:
      Result := CompareDate(DateOfManufacture, B.DateOfManufacture);
  end;
end;

procedure TDevicePoint.Assign(ASource: TDevicePoint; FullAssign: Boolean);
begin
  if ASource = nil then
    Exit;

  {====================================================================}
  { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
  {====================================================================}
  if FullAssign then
  begin
  ID := ASource.ID;
  DeviceID := ASource.DeviceID;
  DeviceUUID := ASource.DeviceUUID;
  end;

  DeviceTypePointID := ASource.DeviceTypePointID;
  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}

  State  := osModified;     //????????????????

  {====================================================================}
  { ОБЩАЯ ИНФОРМАЦИЯ }
  {====================================================================}
  Name := ASource.Name;
  Description := ASource.Description;
  Num := ASource.Num;
  DateTime := ASource.DateTime;

  {====================================================================}
  { ОСНОВНЫЕ ПАРАМЕТРЫ РАСХОДА }
  {====================================================================}
  FlowRate := ASource.FlowRate;
  Q := ASource.Q;
  FlowAccuracy := ASource.FlowAccuracy;

  {====================================================================}
  { УСЛОВИЯ ИЗМЕРЕНИЯ }
  {====================================================================}
  Pressure := ASource.Pressure;
  Temp := ASource.Temp;
  TempAccuracy := ASource.TempAccuracy;

  {====================================================================}
  { ОГРАНИЧЕНИЯ ИЗМЕРЕНИЯ }
  {====================================================================}
  LimitImp := ASource.LimitImp;
  LimitVolume := ASource.LimitVolume;
  LimitTime := ASource.LimitTime;
  SpillageStop := ASource.SpillageStop;
  SpillageType := ASource.SpillageType;
  EtalonType := ASource.EtalonType;
  FlowSorceType := ASource.FlowSorceType;

  {====================================================================}
  { МЕТРОЛОГИЧЕСКИЕ ПАРАМЕТРЫ }
  {====================================================================}
  Error := ASource.Error;

  {====================================================================}
  { ДОПОЛНИТЕЛЬНЫЕ ПАРАМЕТРЫ }
  {====================================================================}
  Pause := ASource.Pause;

  {====================================================================}
  { ПОВТОРЫ И СЕРИИ }
  {====================================================================}
  RepeatsProtocol := ASource.RepeatsProtocol;
  Repeats := ASource.Repeats;
  RepeatsCompleted := ASource.RepeatsCompleted;

  Status := ASource.Status;
  StatusStr := ASource.StatusStr;
  ResultError := ASource.ResultError;
  AverageError := ASource.AverageError;
  StdDev := ASource.StdDev;

  if DataPoints = nil then
    DataPoints := TObjectList<TPointSpillage>.Create(False)
  else
    DataPoints.Clear;

  if ProtocolDataPoints = nil then
    ProtocolDataPoints := TObjectList<TPointSpillage>.Create(False)
  else
    ProtocolDataPoints.Clear;
end;

procedure TDevicePoint.Apply(ASource: TTypePoint);
begin
  if ASource = nil then
    Exit;

  DeviceTypePointID := ASource.ID;
  Name := ASource.Name;
  Description := ASource.Description;

  FlowRate := ASource.FlowRate;
  Q := 0;
  FlowAccuracy := ASource.FlowAccuracy;

  Pressure := ASource.Pressure;
  Temp := ASource.Temp;
  TempAccuracy := ASource.TempAccuracy;

  LimitImp := ASource.LimitImp;
  LimitVolume := ASource.LimitVolume;
  LimitTime := ASource.LimitTime;
  SpillageType := Integer(stWithoutStop);
  EtalonType := Integer(etAuto);
  FlowSorceType := Integer(fstNone);

  Error := ASource.Error;
  Pause := ASource.Pause;

  RepeatsProtocol := ASource.RepeatsProtocol;
  Repeats := ASource.Repeats;
  RepeatsCompleted := 0;
end;

function TDevicePoint.GetStatus: string;
begin
  case Status of
    0: Result := '-'; // hint :'измерения не проводились';
    1: Result := 'выбрана'; // hint :'измерения не проводились, точка выбрана';
    2: Result := 'некорректно'; // hint :'измерения не проводились, точка выбрана';
    3: Result := 'установка'; // hint :'измерения не проводились, устанавливаем расход';
    4: Result := 'установка темп-ры'; // hint :'измерения не проводились, устанавливаем температуру';
    5: Result := 'ошибка установки'; // hint :'измерения не проводились, устанавливаем температуру';
    6: Result := 'измерение';// hint :'измерение начато, но не завершено';  \
    7: Result := 'ошибка измерения'; // hint :'измерения не проводились, устанавливаем температуру';
    8: Result := 'прервано';// hint :'измерение начато, но завершено досрочно, не окончено';
    9: Result := 'закончено';// hint :'измерение завершено корректно';
    10: Result := 'отменено';// hint :'измерение завершено корректно и результаты отменены';
    11: Result := 'сохранено';// hint :'измерение завершено корректно и результаты сохранены';
  else
    Result := 'неизвестный статус';
  end;
end;

function TDevicePoint.GetStatusHint: string;
begin
  case Status of
    0: Result := 'измерения не проводились';
    1: Result := 'измерения не проводились, точка выбрана';
    2: Result := 'точка не корректна';
    3: Result := 'измерения не проводились, устанавливаем расход';
    4: Result := 'измерения не проводились, устанавливаем температуру';
    5: Result := 'ошибка установки';
    6: Result := 'измерение начато, но не завершено';
    7: Result := 'измерения не проводились, устанавливаем температуру';
    8: Result := 'измерение начато, но завершено досрочно, не окончено';
    9: Result := 'измерение завершено корректно';
    10: Result := 'измерение завершено корректно и результаты отменены';
    11: Result := 'измерение завершено корректно и результаты сохранены';
  else
    Result := 'неизвестный статус';
  end;
end;

function TDevicePoint.GetStopCriteria: TSpillageStopCriteria;
begin
  Result := IntToCriteria(SpillageStop);
end;

procedure TDevicePoint.SetStopCriteria(const Value: TSpillageStopCriteria);
begin
  SpillageStop := CriteriaToInt(Value);
end;

procedure TPointSpillage.Assign(ASource: TPointSpillage);
begin
  if ASource = nil then
    Exit;

  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}
  State := ASource.State;

  {====================================================================}
  { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
  {====================================================================}

  SessionID := ASource.SessionID;
  DevicePointID := ASource.DevicePointID;
  DeviceTypePointID := ASource.DeviceTypePointID;
  EtalonName := ASource.EtalonName;
  EtalonUUID := ASource.EtalonUUID;
  Enabled := ASource.Enabled;

  {====================================================================}
  { ОБЩАЯ ИНФОРМАЦИЯ }
  {====================================================================}
  Name := ASource.Name;
  Description := ASource.Description;
  Num := ASource.Num;
  DateTime:= ASource.DateTime;

  {====================================================================}
  { ПАРАМЕТРЫ ИЗМЕРЕНИЯ (УСТАНОВКА / ЭТАЛОН) }
  {====================================================================}
  SpillTime := ASource.SpillTime;
  QavgEtalon := ASource.QavgEtalon;
  EtalonVolume := ASource.EtalonVolume;
  EtalonMass := ASource.EtalonMass;

  {====================================================================}
  { СТАТИСТИКА ЭТАЛОНА }
  {====================================================================}
  QEtalonStd := ASource.QEtalonStd;
  QEtalonCV := ASource.QEtalonCV;

  {====================================================================}
  { ПОКАЗАНИЯ ПРИБОРА }
  {====================================================================}
  DeviceVolume := ASource.DeviceVolume;
  DeviceMass := ASource.DeviceMass;
  Velocity := ASource.Velocity;

  {====================================================================}
  { РЕЗУЛЬТАТ ИЗМЕРЕНИЯ }
  {====================================================================}
  Status := ASource.Status;
  StatusStr := ASource.StatusStr;
  Error := ASource.Error;
  Valid := ASource.Valid;

  {====================================================================}
  { СТАТИСТИКА ПРИБОРА }
  {====================================================================}
  QStd := ASource.QStd;
  QCV := ASource.QCV;

  {====================================================================}
  { ДОПОЛНИТЕЛЬНО ДЛЯ СЧЁТЧИКОВ }
  {====================================================================}
  VolumeBefore := ASource.VolumeBefore;
  VolumeAfter := ASource.VolumeAfter;

  {====================================================================}
  { СЫРЫЕ ДАННЫЕ ИЗМЕРЕНИЯ }
  {====================================================================}
  PulseCount := ASource.PulseCount;
  MeanFrequency := ASource.MeanFrequency;
  AvgCurrent := ASource.AvgCurrent;
  AvgVoltage := ASource.AvgVoltage;

  Data1 := ASource.Data1;
  Data2 := ASource.Data2;
  ArchivedData := ASource.ArchivedData;

  {====================================================================}
  { ПАРАМЕТРЫ ЖИДКОСТИ }
  {====================================================================}
  StartTemperature := ASource.StartTemperature;
  EndTemperature := ASource.EndTemperature;
  AvgTemperature := ASource.AvgTemperature;

  InputPressure := ASource.InputPressure;
  OutputPressure := ASource.OutputPressure;
  Density := ASource.Density;

  {====================================================================}
  { ПАРАМЕТРЫ ОКРУЖАЮЩЕЙ СРЕДЫ }
  {====================================================================}
  AmbientTemperature := ASource.AmbientTemperature;
  AtmosphericPressure := ASource.AtmosphericPressure;
  RelativeHumidity := ASource.RelativeHumidity;

  {====================================================================}
  { ПАРАМЕТРЫ ПРИБОРА }
  {====================================================================}
  Coef := ASource.Coef;
  FCDCoefficient := ASource.FCDCoefficient;
end;

function TDevice.AddPoint: TDevicePoint;
var
  StdIdx: Integer;
begin
  if Points = nil then
    Points := TObjectList<TDevicePoint>.Create(True);

  Result := TDevicePoint.Create(ID);
  Result.ID := TEntityHelpers<TDevicePoint>.NextID(Points);
  Result.DeviceID := ID;
  Result.DeviceUUID:=UUID;
  Result.SpillageStop := SpillageStop;
  StdIdx := GetNextPointStdIndex(Points.Count);
  Result.FlowRate := StdPointRates[StdIdx];

  Points.Add(Result);
end;

function TDevice.AddSessionSpillage: TSessionSpillage;
var
  Sess: TSessionSpillage;
begin
  if Sessions = nil then
    Sessions := TObjectList<TSessionSpillage>.Create(True);

  for Sess in Sessions do
    if Sess <> nil then
    begin
      if Sess.Active then
      begin
        Sess.Active := False;
          Sess.State := osModified;
      end;
    end;

  Result := TSessionSpillage.Create(UUID);
  Result.ID := TEntityHelpers<TSessionSpillage>.NextID(Sessions);
  Result.DeviceUUID := UUID;
  Result.Active := True;
  Result.Status := 0;
  Result.DateTimeOpen := Now;
  Result.DateTimeClose := 0;

  Sessions.Add(Result);
end;

function TDevice.GetActiveSessionSpillage: TSessionSpillage;
begin
  Result := NormalizeActiveSessionSpillage;
end;

function TDevice.NormalizeActiveSessionSpillage: TSessionSpillage;
var
  Sess: TSessionSpillage;
  ActiveFound: Boolean;
begin
  Result := nil;
  if (Sessions = nil) or (Sessions.Count = 0) then
    Exit;

  ActiveFound := False;
  for Sess in Sessions do
  begin
    if Sess = nil then
      Continue;

    if Sess.Active and not ActiveFound then
    begin
      Result := Sess;
      ActiveFound := True;
      Continue;
    end;

    if Sess.Active then
    begin
      Sess.Active := False;
        Sess.State := osModified;
    end;
  end;

  if Result = nil then
  begin
    Result := Sessions[0];
    if Result <> nil then
    begin
      Result.Active := True;
        Result.State := osModified;
    end;
  end;
end;

function TDevice.AddSpillage: TPointSpillage;
var
  ActiveSession: TSessionSpillage;
  SessionCopy: TPointSpillage;
begin
  if Spillages = nil then
    Spillages := TObjectList<TPointSpillage>.Create(True);

  ActiveSession := GetActiveSessionSpillage;
  if ActiveSession = nil then
    ActiveSession := AddSessionSpillage;

  Result := TPointSpillage.Create(ActiveSession.ID);
  Result.ID := TEntityHelpers<TPointSpillage>.NextID(Spillages);
  Result.SessionID := ActiveSession.ID;
  Result.Num := Spillages.Count + 1;

  Spillages.Add(Result);

  if ActiveSession.Status <> 1 then
  begin
    ActiveSession.Status := 1;
      ActiveSession.State := osModified;
  end;

  if ActiveSession.FSpillages <> nil then
  begin
    SessionCopy := TPointSpillage.Create(Result.SessionID);
    SessionCopy.Assign(Result);
    SessionCopy.State := Result.State;
    ActiveSession.FSpillages.Add(SessionCopy);
  end;
end;

function TDevice.IsFlowInPoint(const AFlow: Double; const APoint: TDevicePoint): Boolean;
var
  Q1, Q2: Double;
  Percent: Double;
  AccNorm: string;
begin
  Result := False;
  if APoint = nil then
    Exit;

  if APoint.Q <= 0 then
    Exit;

  AccNorm := NormalizeFlowAccuracyInput(APoint.FlowAccuracy);
  Percent := 10.0; // fallback по аналогии со старой логикой: ±10%

  if AccNorm <> '' then
  begin
    if (AccNorm[1] = '+') or (AccNorm[1] = '-') then
      Percent := NormalizeFloatInput(Copy(AccNorm, 2, MaxInt))
    else
      Percent := NormalizeFloatInput(AccNorm);
  end;

  if Percent < 0 then
    Percent := Abs(Percent);

  if StartsText('+', AccNorm) then
  begin
    // "+5%" => от Q до Q + 5%*Q
    Q1 := APoint.Q;
    Q2 := APoint.Q + (APoint.Q * Percent / 100.0);
  end
  else if StartsText('-', AccNorm) then
  begin
    // "-5%" => от Q - 5%*Q до Q
    Q1 := APoint.Q - (APoint.Q * Percent / 100.0);
    Q2 := APoint.Q;
  end
  else
  begin
    // "±5%" (или "5") => симметричный диапазон
    Q1 := APoint.Q - (APoint.Q * Percent / 100.0);
    Q2 := APoint.Q + (APoint.Q * Percent / 100.0);
  end;

  if Q1 > Q2 then
  begin
    Percent := Q1;
    Q1 := Q2;
    Q2 := Percent;
  end;

  Result := InRange(AFlow, Q1, Q2);
end;

function TDevice.AnalyseDataPoint(const ASpillage: TPointSpillage):Boolean;
var
  P, MatchedPoint: TDevicePoint;
  StopOk: Boolean;
  StopCriteria: TSpillageStopCriteria;
  MeasuredValue: Double;
  AllowedError, ActualError: Double;
begin

  result:=False;
  if ASpillage = nil then
    Exit;

  ASpillage.Status := TPointSpillage.SPS_DATA_ASSIGNED;
  ASpillage.StatusStr := 'Данные присвоены, анализ выполняется.';
  ASpillage.Valid := False;

    ASpillage.State := osModified;

  MatchedPoint := nil;
  for P in FPoints do
    if IsFlowInPoint(ASpillage.QavgEtalon, P) then
    begin
      MatchedPoint := P;
      Break;
    end;

  if MatchedPoint = nil then
  begin
    ASpillage.DevicePointID := 0;
    ASpillage.Name := '-';
    ASpillage.Status := TPointSpillage.SPS_FLOW_NOT_MATCHED;
    ASpillage.StatusStr :=
      'Анализ выполнен: расход не соответствует ни одной поверочной точке прибора. ' +
      'Измерение некорректно (цвет: серый).';
    Exit;
  end;

  ASpillage.DevicePointID := MatchedPoint.ID;
  ASpillage.Name := MatchedPoint.Name;

  StopCriteria := MatchedPoint.StopCriteria;
  if StopCriteria = [] then
    StopCriteria := Self.StopCriteria;
  if StopCriteria = [] then
    StopCriteria := [scTime];

  StopOk := True;

  if scImpulse in StopCriteria then
  begin
    StopOk := StopOk and (ASpillage.PulseCount >= MatchedPoint.LimitImp);
    if not StopOk then
      ASpillage.StatusStr := Format(
        'Критерий остановки "Импульсы" не выполнен: %.6f < %d.',
        [ASpillage.PulseCount, MatchedPoint.LimitImp]
      );
  end;

  if StopOk and (scVolume in StopCriteria) then
  begin
    if (MeasuredDimension = Ord(mdMassFlow)) or (MeasuredDimension = Ord(mdMass)) then
      MeasuredValue := ASpillage.DeviceMass
    else
      MeasuredValue := ASpillage.DeviceVolume;

    StopOk := MeasuredValue >= MatchedPoint.LimitVolume;
    if not StopOk then
      ASpillage.StatusStr := Format(
        'Критерий остановки "Объём/масса" не выполнен: %.6f < %.6f.',
        [MeasuredValue, MatchedPoint.LimitVolume]
      );
  end;

  if StopOk and (scTime in StopCriteria) then
  begin
    StopOk := ASpillage.SpillTime >= MatchedPoint.LimitTime;
    if not StopOk then
      ASpillage.StatusStr := Format(
        'Критерий остановки "Время" не выполнен: %.3f < %.3f с.',
        [ASpillage.SpillTime, MatchedPoint.LimitTime]
      );
  end;

  if not StopOk then
  begin
    ASpillage.Status := TPointSpillage.SPS_STOP_CRITERIA_FAILED;
    ASpillage.StatusStr := 'Анализ выполнен: расход сопоставлен, но ' + ASpillage.StatusStr +
      ' Измерение некорректно (цвет: серый).';
    Exit;
  end;

  AllowedError := Abs(MatchedPoint.Error);
  ActualError := Abs(ASpillage.Error);

  if ActualError > AllowedError then
  begin
    ASpillage.Status := TPointSpillage.SPS_ERROR_EXCEEDED;
    ASpillage.StatusStr :=
      Format('Измерение корректно по расходу и критерию остановки, но погрешность превышена: |%.6f| > |%.6f| (цвет: красный).',
        [ASpillage.Error, MatchedPoint.Error]);
    ASpillage.Valid := False;
    Exit;
  end;

  ASpillage.Status := TPointSpillage.SPS_OK;
  ASpillage.StatusStr :=
    Format('Измерение полностью корректно: расход сопоставлен, критерий остановки выполнен, погрешность в допуске: |%.6f| <= |%.6f| (цвет: зелёный).',
      [ASpillage.Error, MatchedPoint.Error]);
  ASpillage.Valid := True;
    result:=True;

    ASpillage.State := osModified;
end;

procedure TDevice.FillDataPointsList(APoint: TDevicePoint);
var
  S: TPointSpillage;
  CandidateList: TList<TPointSpillage>;
  KeepCount: Integer;
  I: Integer;
  ActiveSession: TSessionSpillage;
begin
  if APoint = nil then
    Exit;

  if APoint.DataPoints = nil then
    APoint.DataPoints := TObjectList<TPointSpillage>.Create(False)
  else
    APoint.DataPoints.Clear;

  if APoint.ProtocolDataPoints = nil then
    APoint.ProtocolDataPoints := TObjectList<TPointSpillage>.Create(False)
  else
    APoint.ProtocolDataPoints.Clear;

  if Spillages = nil then
    Exit;

  ActiveSession := GetActiveSessionSpillage;
  if ActiveSession = nil then
    Exit;

  CandidateList := TList<TPointSpillage>.Create;
  try
    for S in Spillages do
      if (S.SessionID = ActiveSession.ID) and IsFlowInPoint(S.QavgEtalon, APoint) then
      begin
        APoint.DataPoints.Add(S);
        CandidateList.Add(S);
      end;

    CandidateList.Sort(
      TComparer<TPointSpillage>.Construct(
        function(const L, R: TPointSpillage): Integer
        begin
          Result := CompareValue(Abs(L.Error), Abs(R.Error));
        end
      )
    );

    KeepCount := APoint.RepeatsProtocol;
    if KeepCount <= 0 then
      KeepCount := CandidateList.Count
    else
      KeepCount := Min(KeepCount, CandidateList.Count);

    for I := 0 to KeepCount - 1 do
      APoint.ProtocolDataPoints.Add(CandidateList[I]);
  finally
    CandidateList.Free;
  end;
end;

procedure TDevice.AnalyseDevicePointsResults;
var
  DP: TDevicePoint;
  S: TPointSpillage;
  ValidCount: Integer;
  ErrorsSum: Double;
  VarianceSum: Double;
  CandidateError: Double;
  MinInvalidError: Double;
  HasMinInvalid: Boolean;
  ErrorExceededInValid: Boolean;
  RequiredCount: Integer;
  ProcessedCount: Integer;
begin
  if Points = nil then
    Exit;

  for DP in Points do
  begin
    FillDataPointsList(DP);

    DP.Status := 0;
    DP.StatusStr := 'Измерения не производились/не анализировались.';
    DP.ResultError := 0.0;
    DP.AverageError := 0.0;
    DP.StdDev := 0.0;

    if (DP.DataPoints = nil) or (DP.DataPoints.Count = 0) then
    begin
      DP.Status := 1;
      DP.StatusStr := 'Измерения производились, но измерений, связанных с данной точкой, нет.';
      Continue;
    end;

    ValidCount := 0;
    ErrorsSum := 0.0;
    VarianceSum := 0.0;
    CandidateError := -1.0;
    MinInvalidError := 0.0;
    HasMinInvalid := False;
    ErrorExceededInValid := False;

    for S in DP.ProtocolDataPoints do
    begin
      ErrorsSum := ErrorsSum + S.Error;

      if Abs(S.Error) <= Abs(DP.Error) then
      begin
        Inc(ValidCount);
        if Abs(S.Error) > CandidateError then
          CandidateError := Abs(S.Error);
      end
      else
      begin
        ErrorExceededInValid := True;
        if (not HasMinInvalid) or (Abs(S.Error) < MinInvalidError) then
        begin
          MinInvalidError := Abs(S.Error);
          HasMinInvalid := True;
        end;
      end;
    end;

    ProcessedCount := DP.ProtocolDataPoints.Count;
    if ProcessedCount > 0 then
      DP.AverageError := ErrorsSum / ProcessedCount;

    if ProcessedCount > 0 then
    begin
      for S in DP.ProtocolDataPoints do
        VarianceSum := VarianceSum + Sqr(S.Error - DP.AverageError);
      DP.StdDev := Sqrt(VarianceSum / ProcessedCount);
    end;

    RequiredCount := DP.RepeatsProtocol;
    if RequiredCount <= 0 then
      RequiredCount := ProcessedCount;

    if ValidCount >= RequiredCount then
      DP.ResultError := CandidateError
    else if HasMinInvalid then
      DP.ResultError := MinInvalidError
    else if ProcessedCount > 0 then
      DP.ResultError := Abs(DP.ProtocolDataPoints[0].Error)
    else
      DP.ResultError := 0.0;

    if ValidCount = 0 then
    begin
      DP.Status := 2;
      DP.StatusStr := 'Есть измерения по расходу, но корректных измерений недостаточно или нет.';
    end
    else if ValidCount < RequiredCount then
    begin
      if ErrorExceededInValid then
      begin
        DP.Status := 3;
        DP.StatusStr := 'Есть корректные измерения, но их меньше RepeatsProtocol и часть измерений превышает допуск по погрешности (красный).';
      end
      else
      begin
        DP.Status := 4;
        DP.StatusStr := 'Корректные измерения есть, их меньше RepeatsProtocol, но погрешности в пределах допуска (желтый).';
      end;
    end
    else
    begin
      DP.Status := 5;
      DP.StatusStr := 'Корректных измерений не меньше RepeatsProtocol, требование по погрешности выполнено (зеленый).';
    end;
  end;
end;

procedure TDevice.AnalyseResults;
var
  DP: TDevicePoint;
  HasStatus3: Boolean;
  HasStatus4: Boolean;
  AllStatus5: Boolean;
  AllStatus0: Boolean;
  AllStatus01: Boolean;
  AllStatus012: Boolean;
begin
  AnalyseDevicePointsResults;

  Status := 0;
  StatusStr := 'Измерения не производились/не анализировались.';

  if (Points = nil) or (Points.Count = 0) then
    Exit;

  HasStatus3 := False;
  HasStatus4 := False;
  AllStatus5 := True;
  AllStatus0 := True;
  AllStatus01 := True;
  AllStatus012 := True;

  for DP in Points do
  begin
    if DP = nil then
      Continue;

    if DP.Status <> 5 then
      AllStatus5 := False;

    if DP.Status <> 0 then
      AllStatus0 := False;

    if not (DP.Status in [0, 1]) then
      AllStatus01 := False;

    if not (DP.Status in [0, 1, 2]) then
      AllStatus012 := False;

    if DP.Status = 3 then
      HasStatus3 := True;

    if DP.Status = 4 then
      HasStatus4 := True;
  end;

  if AllStatus5 then
  begin
    Status := 5;
    StatusStr := 'Все поверочные точки имеют достаточное количество корректных измерений в пределах допуска (зеленый).';
    Exit;
  end;

  if HasStatus3 then
  begin
    Status := 3;
    StatusStr := 'Есть поверочные точки с недостаточным количеством корректных измерений и превышением допуска по погрешности (красный).';
    Exit;
  end;

  if HasStatus4 then
  begin
    Status := 4;
    StatusStr := 'Есть поверочные точки с корректными измерениями в допуске, но их меньше RepeatsProtocol (желтый).';
    Exit;
  end;

  if AllStatus012 then
  begin
    Status := 2;
    StatusStr := 'Есть измерения, связанные с поверочными точками, но корректных измерений недостаточно или они некорректны (серый).';
    Exit;
  end;

  if AllStatus01 then
  begin
    Status := 1;
    StatusStr := 'Измерения производились, но измерений, связанных с поверочными точками, нет.';
    Exit;
  end;

  if AllStatus0 then
  begin
    Status := 0;
    StatusStr := 'Измерения не производились/не анализировались.';
    Exit;
  end;
end;

function TDevice.FindDiameter(AType: TDeviceType): TDiameter;
begin
  Result := nil;

  if AType = nil then
    Exit;

  for var D in AType.Diameters do
    if AType.SelectedDiameterID = D.ID then
      Exit(D);

  for var D in AType.Diameters do
    if SameText(D.DN, DN) or SameText(D.Name, DN) then
      Exit(D);

  if AType.Diameters.Count > 0 then
    Result := AType.Diameters[0];
end;

procedure TDevice.ApplyType(AType: TDeviceType);
begin
  if AType = nil then
    Exit;

  Modification := AType.Modification;
  Manufacturer := AType.Manufacturer;
  AccuracyClass := AType.AccuracyClass;
  ReestrNumber := AType.ReestrNumber;
  Category := AType.Category;
  CategoryName := AType.CategoryName;

  MeasuredDimension := AType.MeasuredDimension;
  Units := AType.Units;
  SetDimensions;
  OutputType := AType.OutputType;
  OutputSet := AType.OutputSet;
  DimensionCoef := AType.DimensionCoef;
  SpillageStop := AType.SpillageStop;

  Freq := AType.Freq;
  VoltageRange := AType.VoltageRange;
  VoltageQminRate := AType.VoltageQminRate;
  VoltageQmaxRate := AType.VoltageQmaxRate;
  CurrentRange := AType.CurrentRange;
  CurrentQminRate := AType.CurrentQminRate;
  CurrentQmaxRate := AType.CurrentQmaxRate;
  IntegrationTime := AType.IntegrationTime;

  VerificationMethod := AType.VerificationMethod;
  ProcedureName := AType.ProcedureName;
  ReportingForm := AType.ReportingForm;
  Documentation := AType.Documentation;
end;

procedure TDevice.ApplyDiameter(ADiameter: TDiameter; AType: TDeviceType);
begin
  if ADiameter = nil then
    Exit;

  if (AType <> nil) and (FDeviceType <> AType) then
    FDeviceType := AType;

  DN := ADiameter.Name;
  Qmax := ADiameter.Qmax;
  Qmin := ADiameter.Qmin;

  if Qmin > 0 then
    RangeDynamic := Qmax / Qmin
  else
    RangeDynamic := 0;

  Coef := ADiameter.Kp;
  FreqFlowRate := ADiameter.QFmax;
end;

procedure TDevice.RecalcPoints;
var
  I: Integer;
  P: TDevicePoint;
  LQ, V, Tm: Double;
begin
  if (Points = nil) or (Coef <= 0) then
    Exit;

  for I := 0 to Points.Count - 1 do
  begin
    P := Points[I];
    LQ := P.FlowRate * Qmax;
    P.Q := LQ;

    if (LQ > 0) and (P.LimitTime > 0) then
    begin
      Tm := P.LimitTime;
      V := LQ * Tm / 3.6;
      P.LimitVolume := V;
      P.LimitImp := Round(V * Coef);
    end;
  end;
end;

procedure TDevice.CreatePointsFromType(AType: TDeviceType);
var
  TP: TTypePoint;
  DP: TDevicePoint;
begin
  if AType = nil then
    Exit;

  if Points = nil then
    Points := TObjectList<TDevicePoint>.Create(True);

  Points.Clear;

  for TP in AType.Points do
  begin
    DP := AddPoint;
    DP.Apply(TP);
    DP.SpillageStop := SpillageStop;
  end;
end;

procedure TDevice.AttachType(AType: TDeviceType; RepoName: String);
begin
  if AType = nil then
    Exit;

  FDeviceType := AType;
  DeviceTypeUUID := AType.UUID;
  DeviceTypeName := AType.Name;
  DeviceTypeRepo := RepoName;
  RepoTypeName := RepoName;

  FillFromType(AType);
end;

procedure TDevice.AttachDN(ADiameter: TDiameter; AType: TDeviceType);
begin
  if ADiameter = nil then
  begin
    SyncNameWithModificationAndDiameter;
    Exit;
  end;

  ApplyDiameter(ADiameter, AType);
  RecalcPoints;

  SyncNameWithModificationAndDiameter;
end;

procedure TDevice.AttachDN(ADN: String; AType: TDeviceType);
var
  LDiameter: TDiameter;
begin
  if AType = nil then
    Exit;

  LDiameter := AType.FindDiameterByDN(ADN);
  Self.AttachDN(LDiameter, AType); // вызов overload с TDiameter (не рекурсия)
end;

procedure TDevice.SyncNameWithModificationAndDiameter;
var
  NewName: string;
begin
  NewName := Trim(Modification);
 // Диаметр не будем отображать.

{  if Trim(DN) <> '' then
  begin
    if NewName <> '' then
      NewName := NewName + ' ';
    NewName := NewName; //+ Trim(DN);
  end;
                       }
  if NewName <> '' then
    Name := NewName;
end;

procedure TDevice.FillFromType(AType: TDeviceType; const APreservePointsAndSerial: Boolean);
var
  TD: TDiameter;
begin
  if AType = nil then
    Exit;

  FDeviceType := AType;
  ApplyType(AType);
  TD := FindDiameter(AType);
  if TD <> nil then
    ApplyDiameter(TD, AType);

  if not APreservePointsAndSerial then
    CreatePointsFromType(AType);

  RecalcPoints;

  SyncNameWithModificationAndDiameter;
end;

end.

