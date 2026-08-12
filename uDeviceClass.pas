unit uDeviceClass;

{$RTTI EXPLICIT FIELDS([vcPublic]) PROPERTIES([vcPublic, vcPublished])}

interface

uses
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.StrUtils,
  System.SysUtils,
  System.UITypes,
  uBaseProcedures,
  uClasses,
  uMeterValue;



type
  { Execution and metrological state are deliberately orthogonal.  Never use
    the ordinal of one of these enums as a value of another enum. }
  EValidationStatus = (vsNone, vsUndefined, vsValid, vsInvalid);
  EMeasurementSpillageStatus = (mssNone, mssCreated, mssDataAssigned,
    mssAnalyzing, mssCompleted, mssSavePending, mssSaved, mssInterrupted,
    mssCancelled, mssError);
  EMeasurementDeviceStatus = (mdsNone, mdsPrepared, mdsMeasurement,
    mdsCompleted, mdsSavePending, mdsSaved, mdsInterrupted, mdsCancelled,
    mdsError);
  ESpillageValidationReason = (svrNone, svrNotAnalyzed, svrDisabled,
    svrPointNotMatched, svrStopCriteriaFailed, svrInvalidSourceData,
    svrErrorExceeded, svrErrorWithinTolerance);
  EPointValidationReason = (pvrNone, pvrNotAnalyzed, pvrDisabled,
    pvrNoMeasurements, pvrNoMatchedMeasurements,
    pvrInsufficientMatchedMeasurements, pvrInsufficientValidMeasurements,
    pvrRequiredValidMeasurementsCollected, pvrInvalidSettings);
  EDeviceValidationReason = (dvrNone, dvrNotAnalyzed, dvrNoPoints,
    dvrNoEnabledPoints, dvrPointsIncomplete, dvrInvalidPointsAndIncomplete,
    dvrInvalidPointsAndComplete, dvrAllPointsValid);




  TCalibrCoefTableType = (
    cctMeterValueCoef = 0,            // поправка коэффициента пересчёта TMeterValue.Coef
    cctMeterValueFlowRate = 2,        // поправка TMeterValue.FlowRate
    cctMeterValueQuantity = 3,        // поправка TMeterValue.Quantity
    cctMeterValueDensity = 4,         // поправка TMeterValue.Density
    cctReference = 10,                // справочная таблица (в расчётах TMeterValue не применяется)
    cctDeviceCoefCorrection = 11,     // поправка коэффициента преобразования (для записи в прибор)
    cctDeviceFlowRateCorrection = 12, // поправка расхода (для записи в прибор)
    cctDeviceQuantityCorrection = 13, // поправка количества (для записи в прибор)
    cctDeviceDensityCorrection = 14   // поправка плотности (для записи в прибор)
  );


  function ValidationStatusToText(const AValue: EValidationStatus): string;
function MeasurementSpillageStatusToText(const AValue: EMeasurementSpillageStatus): string;
function MeasurementPointStatusToText(const AValue: EMeasurementPointStatus): string;
function MeasurementDeviceStatusToText(const AValue: EMeasurementDeviceStatus): string;
function SpillageValidationReasonToText(const AValue: ESpillageValidationReason): string;
function PointValidationReasonToText(const AValue: EPointValidationReason): string;
function DeviceValidationReasonToText(const AValue: EDeviceValidationReason): string;
function SpillageValidationToLegacyCode(const AValidation: EValidationStatus;
  const AReason: ESpillageValidationReason): Integer;
function GetSpillageValidationColor(const AValidation: EValidationStatus;
  const AReason: ESpillageValidationReason): TAlphaColor;
function GetPointValidationColor(const AValidation: EValidationStatus;
  const AReason: EPointValidationReason): TAlphaColor;
function GetDeviceValidationColor(const AValidation: EValidationStatus;
  const AReason: EDeviceValidationReason): TAlphaColor;
function GetPointExecutionStatusColor(const AStatus: EMeasurementPointStatus): TAlphaColor;

function TryCalibrCoefTableType(const ARawType: Integer;
  out ATableType: TCalibrCoefTableType): Boolean;
function CalibrCoefTableTypeName(const ATableType: TCalibrCoefTableType): string;
function TryResolveCalibrCoefTableTarget(const ARawType: Integer;
  out ATableType: TCalibrCoefTableType; out AResolvedTypeName,
  ATargetField: string): Boolean;

type
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




  TMeasurementPointParticipant = record
    DeviceUUID: string;
    DeviceChannelUUID: string;
    SourcePointUUID: string;
    SourcePointName: string;
    SourceFlowRate: Double;
    SourceDeviceQmaxLS: Double;
    StoredSourcePointQLS: Double;
    CalculatedSourceTargetQLS: Double;
    SelectedSourceTargetQLS: Double;
    SourceTargetQLS: Double;
    SourceErrorPercent: Double;
    SourcePauseSec: Double;
  end;


  TDevicePoint = class (TTypeEntity)
  private

    FStatus: EMeasurementPointStatus;
    FEnabled: Boolean;
    FValidation: EValidationStatus;
    FValidationReason: EPointValidationReason;
    FValidationMessage: string;

    function GetStopCriteria: TSpillageStopCriteria;
    procedure SetStopCriteria(const Value: TSpillageStopCriteria);
    function GettargetEtalonType: integer;
    procedure SettargetEtalonType(etalonType:integer);
    function GetMeasurementPointStatus: EMeasurementPointStatus;
    procedure SetMeasurementPointStatus(const Value: EMeasurementPointStatus);


  protected
    procedure SetState(const Value: TObjectState); override;
   public
    DataPoints: TObjectList<TPointSpillage>;          // Все измерения, относящиеся к точке по расходу
    ProtocolDataPoints: TObjectList<TPointSpillage>;  // Лучшие измерения по погрешности (не более RepeatsProtocol)

    /// <summary>

    ResultError: Double;         // Итоговая (худшая из лучших) погрешность
    AverageError: Double;        // Средняя погрешность лучших измерений
    StdDev: Double;              // СКО погрешности лучших измерений

    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}

    DeviceID: Integer;           // Идентификатор прибора (FK → TDevice.ID)
    DeviceUUID: String;
    DeviceTypeUUID: string;   // UUID шаблонной точки типа (опционально)

    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}

    {====================================================================}
    { ОСНОВНЫЕ ПАРАМЕТРЫ РАСХОДА }
    {====================================================================}
    FlowRate: Double;            // Отношение Q / Qmax (0..1)
    Q: Double;                   // Абсолютный расход, л/с
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
    Pause: Integer;              // Время стабилизации перед измерением, сек (-1 = Авто)
    RequireAutoStabilization: Boolean; // Runtime: в session-точке есть хотя бы одна исходная точка с Pause < 0
    RequiredStabilizationSec: Double;  // Runtime: максимальный неотрицательный Pause исходных точек
    Participants: TArray<TMeasurementPointParticipant>;
    SourcePointCount: Integer;
    CommonMinQ: Double;          // Runtime: common admissible flow interval of all participants
    CommonMaxQ: Double;
    MinEtalonDeltaQ: Double;     // Runtime: strictest absolute etalon tolerance in the group
    EtalonRangeValid: Boolean;   // Runtime: false when the source etalon error is invalid

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

    constructor Create(ADeviceID : Integer);  overload;
    constructor Create; overload;

    destructor Destroy; override;

    procedure Assign(ASource: TDevicePoint; FullAssign: Boolean);
    procedure Apply(ASource: TTypePoint);
    function GetStatus: string;
    function GetStatusHint: string;
    function GetStatusColor: TAlphaColor;
    procedure SetValidation(const AValidation: EValidationStatus;
      const AReason: EPointValidationReason; const AMessage: string);
    function GetShortStateText: string;
    function GetFullStateText: string;
    class function GetPointSpillageTypeText(const AType: EPointSpillageType): string; overload; static;
    class function GetPointSpillageTypeText(const AType: Integer): string; overload; static;
    class function GetPointEtalonTypeText(const AType: EPointEtalonType): string; overload; static;
    class function GetPointEtalonTypeText(const AType: Integer): string; overload; static;
    class function GetPointFlowSourceTypeText(const AType: EPointFlowSourceType): string; overload; static;
    class function GetPointFlowSourceTypeText(const AType: Integer): string; overload; static;

    property Enabled: Boolean read FEnabled write FEnabled;
    property StopCriteria: TSpillageStopCriteria read GetStopCriteria write SetStopCriteria;
    /// <summary>
    /// Gets or sets the typed execution/result status of the point. The setter
    /// intentionally contains no measurement state transition logic.
    /// </summary>
    property Status: EMeasurementPointStatus read GetMeasurementPointStatus write SetMeasurementPointStatus;
    property Validation: EValidationStatus read FValidation;
    property ValidationReason: EPointValidationReason read FValidationReason;
    property ValidationMessage: string read FValidationMessage;

    property target_EtalonType: integer read GettargetEtalonType  write SettargetEtalonType;

  end;

  TPointSpillage = class (TTypeEntity)
  private
    FStatus: EMeasurementSpillageStatus;
    FValidation: EValidationStatus;
    FValidationReason: ESpillageValidationReason;
    FValidationMessage: string;
    procedure SetStatus(const AValue: EMeasurementSpillageStatus);
    function GetValid: Boolean;
  public

    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}

    SessionID: Integer;          // Сессия, к которой относится измерение (FK → TSessionSpillage.ID)
    DeviceUUID: string;          // Прибор, к которому относится измерение (стабильная связь по UUID)
    DeviceTypeUUID: string;   // UUID шаблонной точки типа (опционально)
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
    Error: Double;               // Итоговая погрешность, %

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
    procedure SetValidation(const AValidation: EValidationStatus;
      const AReason: ESpillageValidationReason; const AMessage: string);
    procedure ImportLegacyValidation(const ALegacyStatus: Integer;
      const ALegacyMessage: string; const ALegacyValid: Boolean);
    function GetShortStateText: string;
    function GetFullStateText: string;
    property Status: EMeasurementSpillageStatus read FStatus write SetStatus;
    property Validation: EValidationStatus read FValidation;
    property ValidationReason: ESpillageValidationReason read FValidationReason;
    property ValidationMessage: string read FValidationMessage;
    property Valid: Boolean read GetValid; // compatibility, intentionally read-only


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

    procedure Assign(ASource: TCalibrCoefItem);
    function Clone: TCalibrCoefItem;
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

    procedure Assign(ASource: TCalibrCoefTable);
    function Clone: TCalibrCoefTable;
    function FindItemByQ(Q: Double): TCalibrCoefItem;
    function ApplyByQ(Q, X: Double): Double;
    function TableType: TCalibrCoefTableType;
    procedure SetTableType(const AType: TCalibrCoefTableType);
  end;

  TDevice = class(TTypeEntity)
  private
      FSpillages  : TObjectList<TPointSpillage>;
      FSessions   : TObjectList<TSessionSpillage>;
      FPoints     : TObjectList<TDevicePoint>;
      FCalibrCoefTable: TObjectList<TCalibrCoefTable>;
      FDeviceType : TDeviceType;
      FDimensions: TList<TDimension>;
      FStatus: EMeasurementDeviceStatus;
      FValidation: EValidationStatus;
      FValidationReason: EDeviceValidationReason;
      FValidationMessage: string;
      function GetStopCriteria: TSpillageStopCriteria;
      procedure SetStopCriteria(const Value: TSpillageStopCriteria);
      function NormalizeActiveSessionSpillage: TSessionSpillage;
      function GetCalibrCoefTable: TCalibrCoefTable;
      procedure SetCalibrCoefTable(const Value: TCalibrCoefTable);
      function FindDiameter(AType: TDeviceType): TDiameter;
      procedure ApplyType(AType: TDeviceType);
      procedure ApplyDiameter(ADiameter: TDiameter; AType: TDeviceType);

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
    Qtr: Double;
    Q2tr: Double;
    Qnom: Double;
    QFmax : Double;
    Kp: Double;
    Temp: string;               // Температура
    Error: Double;              // Допустимая погрешность, %
    Enabled: Boolean;

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
    SyncMode: Integer;          // Режим синхронизации канала (Ord(ESyncChannelMode))
    NoiseFilter: Integer;       // Фильтр помех, мс (-1=off, 0=auto, >0=ms)
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

    {====================================================================}
    { ОПИСАНИЕ И ПРИМЕЧАНИЯ }
    {====================================================================}
    Comment: string;
    ReportingForm: string;

  public
    constructor Create;
    destructor Destroy;

    procedure Assign(ASource: TDevice; FullAssign: Boolean);
    procedure AssignWithoutMeasurementHistory(ASource: TDevice);
    function Clone: TDevice;
    function GetSearchText: string; override;
    procedure RecalcPoints;
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
    function FindMatchedDevicePointForSpillage(const ASpillage: TPointSpillage): TDevicePoint;

    function  AnalyseDataPoint(const ASpillage: TPointSpillage): EValidationStatus;
    procedure FillDataPointsList(APoint: TDevicePoint);
    procedure SetDimensions;
    function GetDimensionName: string;
    function ToBaseUnits(const AValue: Double): Double;
    function FromBaseUnits(const AValue: Double): Double;
    procedure AnalyseDevicePointsResults;
    procedure AnalyseResults;
    procedure SetValidation(const AValidation: EValidationStatus;
      const AReason: EDeviceValidationReason; const AMessage: string);
    function GetShortStateText: string;
    function GetFullStateText: string;


    property  Spillages  : TObjectList<TPointSpillage> read FSpillages write FSpillages;
    property  Sessions   : TObjectList<TSessionSpillage> read FSessions write FSessions;
    property  Points     : TObjectList<TDevicePoint> read  FPoints write  FPoints;
    property  Dimensions : TList<TDimension> read FDimensions;
    property  CalibrCoefTables: TObjectList<TCalibrCoefTable> read FCalibrCoefTable write FCalibrCoefTable;
    property  CalibrCoefTable: TCalibrCoefTable read GetCalibrCoefTable write SetCalibrCoefTable;
    property  StopCriteria: TSpillageStopCriteria read GetStopCriteria write SetStopCriteria;
    property Status: EMeasurementDeviceStatus read FStatus write FStatus;
    property Validation: EValidationStatus read FValidation;
    property ValidationReason: EDeviceValidationReason read FValidationReason;
    property ValidationMessage: string read FValidationMessage;

    procedure AttachType(AType: TDeviceType; RepoName: String);
    procedure AttachDN(ADiameter: TDiameter; AType: TDeviceType);  overload;
    procedure AttachDN(ADN: String; AType: TDeviceType);  overload;
    procedure FillFromType(AType: TDeviceType; const APreservePointsAndSerial: Boolean = False);
    procedure SyncNameWithModificationAndDiameter;

  end;

// Выбирает отображаемую погрешность из уже сформированной группировки Summary.
function TrySelectDevicePointDisplaySpillage(
  const ASpillages: array of TPointSpillage;
  out ASelected: TPointSpillage): Boolean;
// Возвращает погрешность поверочной точки по тому же правилу, которое используется в сводной таблице обработки.
function TryGetDevicePointDisplayError(ADevice: TDevice;
  ADevicePoint: TDevicePoint; ASession: TSessionSpillage;
  out AError: Double): Boolean;

implementation
uses
  uDataManager,
  uAppServices,
  uRepositories,
  uMKSDebug;

function IsDevicePointDisplayErrorCandidate(ASpillage: TPointSpillage): Boolean;
begin
  Result := (ASpillage <> nil) and (ASpillage.State <> osDeleted) and
    ASpillage.Enabled and ASpillage.Valid and
    (ASpillage.Validation = vsValid) and not IsNan(ASpillage.Error) and
    not IsInfinite(ASpillage.Error) and (Abs(ASpillage.Error) < MaxDouble);
end;

function TrySelectDevicePointDisplaySpillage(
  const ASpillages: array of TPointSpillage;
  out ASelected: TPointSpillage): Boolean;
var
  Candidate: TPointSpillage;
begin
  ASelected := nil;
  for Candidate in ASpillages do
    if IsDevicePointDisplayErrorCandidate(Candidate) and
       ((ASelected = nil) or
        (Abs(Candidate.Error) < Abs(ASelected.Error)) or
        (SameValue(Abs(Candidate.Error), Abs(ASelected.Error), 1E-9) and
         (Candidate.ID >= ASelected.ID))) then
      ASelected := Candidate;
  Result := ASelected <> nil;
end;

function TryGetDevicePointDisplayError(ADevice: TDevice;
  ADevicePoint: TDevicePoint; ASession: TSessionSpillage;
  out AError: Double): Boolean;
var
  Candidate, Selected: TPointSpillage;
  Candidates: TList<TPointSpillage>;
  ExactPointIdentity: Boolean;
begin
  AError := 0;
  Result := False;
  if (ADevice = nil) or (ADevicePoint = nil) or (ASession = nil) or
     (ASession.Spillages = nil) or (ASession.ID <= 0) or
     ((Trim(ASession.DeviceUUID) <> '') and
      not SameText(Trim(ASession.DeviceUUID), Trim(ADevice.UUID))) then Exit;
  Candidates := TList<TPointSpillage>.Create;
  try
    for Candidate in ASession.Spillages do
    begin
      if (Candidate = nil) or (Candidate.SessionID <> ASession.ID) or
         ((Trim(Candidate.DeviceUUID) <> '') and
          not SameText(Trim(Candidate.DeviceUUID), Trim(ADevice.UUID))) then
        Continue;
      if (Trim(ADevicePoint.DeviceTypeUUID) <> '') and
         (Trim(Candidate.DeviceTypeUUID) <> '') then
      begin
        if not SameText(Trim(Candidate.DeviceTypeUUID),
          Trim(ADevicePoint.DeviceTypeUUID)) then
          Continue;
        ExactPointIdentity := True;
      end
      else if (Trim(ADevicePoint.Name) <> '') and
              (Trim(Candidate.Name) <> '') then
        ExactPointIdentity := SameText(Trim(Candidate.Name),
          Trim(ADevicePoint.Name))
      else
        ExactPointIdentity := False;
      if not ExactPointIdentity and
         (ADevice.FindMatchedDevicePointForSpillage(Candidate) <> ADevicePoint) then
        Continue;
      Candidates.Add(Candidate);
    end;
    Result := TrySelectDevicePointDisplaySpillage(Candidates.ToArray, Selected);
    if Result then
      AError := Selected.Error;
  finally
    Candidates.Free;
  end;
end;

function UnknownStateText(const ACode: Integer): string;
begin
  Result := Format('Неизвестное состояние (код %d)', [ACode]);
end;

function ValidationStatusToText(const AValue: EValidationStatus): string;
begin
  case AValue of
    vsNone: Result := 'Метрологический результат отсутствует';
    vsUndefined: Result := 'Результат не определён';
    vsValid: Result := 'Годен';
    vsInvalid: Result := 'Не годен';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function MeasurementSpillageStatusToText(const AValue: EMeasurementSpillageStatus): string;
begin
  case AValue of
    mssNone: Result := 'Состояние не задано'; mssCreated: Result := 'Создано';
    mssDataAssigned: Result := 'Данные присвоены'; mssAnalyzing: Result := 'Выполняется анализ';
    mssCompleted: Result := 'Завершено'; mssSavePending: Result := 'Ожидает сохранения';
    mssSaved: Result := 'Сохранено'; mssInterrupted: Result := 'Прервано';
    mssCancelled: Result := 'Отменено'; mssError: Result := 'Ошибка';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function MeasurementPointStatusToText(const AValue: EMeasurementPointStatus): string;
begin
  case AValue of
    mptsNone: Result := 'Состояние не задано'; mptsSelectPoint: Result := 'Выбор точки';
    mptsInvalidPoint: Result := 'Некорректная точка'; mptsSelectEtalon: Result := 'Выбор эталона';
    mptsSetupPoint: Result := 'Установка точки'; mptsWaitStable: Result := 'Ожидание стабилизации';
    mptsWaitMeasureStart: Result := 'Ожидание начала измерения'; mptsMeasure: Result := 'Измерение';
    mptsWaitMeasureStop: Result := 'Ожидание завершения измерения'; mptsResultsRead: Result := 'Чтение результатов';
    mptsSave: Result := 'Сохранение'; mptsDone: Result := 'Завершено';
    mptsSetupError: Result := 'Ошибка установки'; mptsMeasureError: Result := 'Ошибка измерения';
    mptsInterrupted: Result := 'Прервано'; mptsCancelled: Result := 'Отменено';
    mptsSaved: Result := 'Сохранено'; mptsSkipped: Result := 'Пропущено';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function MeasurementDeviceStatusToText(const AValue: EMeasurementDeviceStatus): string;
begin
  case AValue of
    mdsNone: Result := 'Состояние не задано'; mdsPrepared: Result := 'Подготовлен';
    mdsMeasurement: Result := 'Выполняется измерение'; mdsCompleted: Result := 'Завершено';
    mdsSavePending: Result := 'Ожидает сохранения'; mdsSaved: Result := 'Сохранено';
    mdsInterrupted: Result := 'Прервано'; mdsCancelled: Result := 'Отменено';
    mdsError: Result := 'Ошибка';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function SpillageValidationReasonToText(const AValue: ESpillageValidationReason): string;
begin
  case AValue of
    svrNone: Result := ''; svrNotAnalyzed: Result := 'Анализ не выполнялся';
    svrDisabled: Result := 'Измерение отключено'; svrPointNotMatched: Result := 'Измерение не соответствует поверочной точке';
    svrStopCriteriaFailed: Result := 'Критерий остановки не выполнен'; svrInvalidSourceData: Result := 'Исходные данные некорректны';
    svrErrorExceeded: Result := 'Превышена допустимая погрешность'; svrErrorWithinTolerance: Result := 'Погрешность находится в допуске';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function PointValidationReasonToText(const AValue: EPointValidationReason): string;
begin
  case AValue of
    pvrNone: Result := ''; pvrNotAnalyzed: Result := 'Анализ не выполнялся'; pvrDisabled: Result := 'Точка отключена';
    pvrNoMeasurements: Result := 'Измерения отсутствуют'; pvrNoMatchedMeasurements: Result := 'Соответствующие измерения отсутствуют';
    pvrInsufficientMatchedMeasurements: Result := 'Недостаточно соответствующих измерений';
    pvrInsufficientValidMeasurements: Result := 'Недостаточно годных измерений';
    pvrRequiredValidMeasurementsCollected: Result := 'Требуемое количество годных измерений набрано';
    pvrInvalidSettings: Result := 'Настройки точки некорректны';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function DeviceValidationReasonToText(const AValue: EDeviceValidationReason): string;
begin
  case AValue of
    dvrNone: Result := ''; dvrNotAnalyzed: Result := 'Анализ не выполнялся'; dvrNoPoints: Result := 'Поверочные точки отсутствуют';
    dvrNoEnabledPoints: Result := 'Нет включённых поверочных точек'; dvrPointsIncomplete: Result := 'Не по всем точкам получен результат';
    dvrInvalidPointsAndIncomplete: Result := 'Есть негодные и не завершённые точки';
    dvrInvalidPointsAndComplete: Result := 'Все точки определены, имеются негодные';
    dvrAllPointsValid: Result := 'Все поверочные точки годны';
  else Result := UnknownStateText(Ord(AValue)); end;
end;

function SpillageValidationToLegacyCode(const AValidation: EValidationStatus;
  const AReason: ESpillageValidationReason): Integer;
const
  LEGACY_CREATED = 0;
  LEGACY_FLOW_NOT_MATCHED = 2;
  LEGACY_STOP_CRITERIA_FAILED = 3;
  LEGACY_ERROR_EXCEEDED = 4;
  LEGACY_OK = 5;
begin
  { The database column belongs to the legacy, versionless format.  Keep its
    encoding at this single compatibility boundary; runtime code never uses it. }
  if AValidation = vsValid then Exit(LEGACY_OK);
  if AValidation = vsInvalid then Exit(LEGACY_ERROR_EXCEEDED);
  case AReason of
    svrPointNotMatched: Result := LEGACY_FLOW_NOT_MATCHED;
    svrStopCriteriaFailed: Result := LEGACY_STOP_CRITERIA_FAILED;
  else Result := LEGACY_CREATED; end;
end;

function GetSpillageValidationColor(const AValidation: EValidationStatus; const AReason: ESpillageValidationReason): TAlphaColor;
begin
  case AValidation of vsValid: Result := COLOR_COMPLETED; vsInvalid: Result := COLOR_WARNING; else Result := COLOR_NONE; end;
end;
function GetPointValidationColor(const AValidation: EValidationStatus; const AReason: EPointValidationReason): TAlphaColor;
begin
  case AValidation of vsValid: Result := COLOR_COMPLETED; vsInvalid: Result := COLOR_INVALID; else Result := COLOR_NONE; end;
end;
function GetDeviceValidationColor(const AValidation: EValidationStatus; const AReason: EDeviceValidationReason): TAlphaColor;
begin
  if AValidation = vsValid then Result := COLOR_COMPLETED
  else if (AValidation = vsInvalid) and (AReason = dvrInvalidPointsAndIncomplete) then Result := COLOR_WARNING
  else if AValidation = vsInvalid then Result := COLOR_INVALID else Result := COLOR_NONE;
end;
function GetPointExecutionStatusColor(const AStatus: EMeasurementPointStatus): TAlphaColor;
begin
  case AStatus of
    mptsSelectEtalon, mptsSetupPoint, mptsWaitStable, mptsWaitMeasureStart, mptsMeasure,
    mptsWaitMeasureStop, mptsResultsRead, mptsSave: Result := COLOR_RUNNING;
    mptsDone, mptsInterrupted, mptsCancelled, mptsSkipped: Result := COLOR_WARNING;
    mptsSaved: Result := COLOR_COMPLETED;
    mptsInvalidPoint, mptsSetupError, mptsMeasureError: Result := COLOR_INVALID;
  else Result := COLOR_NONE; end;
end;

function TryCalibrCoefTableType(const ARawType: Integer;
  out ATableType: TCalibrCoefTableType): Boolean;
begin
  Result := (ARawType >= Ord(Low(TCalibrCoefTableType))) and
    (ARawType <= Ord(High(TCalibrCoefTableType)));
  if not Result then Exit;
  // Do not cast an Integer into a sparse enum.  Resolve exclusively through
  // the ordinals of the canonical declaration above, so persisted value 1 is
  // unambiguously cctMeterValueCoef on every compiler/range-check setting.
  case ARawType of
    Ord(cctReference): ATableType := cctReference;
    Ord(cctMeterValueCoef): ATableType := cctMeterValueCoef;
    Ord(cctMeterValueFlowRate): ATableType := cctMeterValueFlowRate;
    Ord(cctMeterValueQuantity): ATableType := cctMeterValueQuantity;
    Ord(cctMeterValueDensity): ATableType := cctMeterValueDensity;
    Ord(cctDeviceCoefCorrection): ATableType := cctDeviceCoefCorrection;
    Ord(cctDeviceFlowRateCorrection): ATableType := cctDeviceFlowRateCorrection;
    Ord(cctDeviceQuantityCorrection): ATableType := cctDeviceQuantityCorrection;
    Ord(cctDeviceDensityCorrection): ATableType := cctDeviceDensityCorrection;
  else
    Result := False;
  end;
end;

function CalibrCoefTableTypeName(
  const ATableType: TCalibrCoefTableType): string;
begin
  case ATableType of
    cctReference: Result := 'cctReference';
    cctMeterValueCoef: Result := 'cctMeterValueCoef';
    cctMeterValueFlowRate: Result := 'cctMeterValueFlowRate';
    cctMeterValueQuantity: Result := 'cctMeterValueQuantity';
    cctMeterValueDensity: Result := 'cctMeterValueDensity';
    cctDeviceCoefCorrection: Result := 'cctDeviceCoefCorrection';
    cctDeviceFlowRateCorrection: Result := 'cctDeviceFlowRateCorrection';
    cctDeviceQuantityCorrection: Result := 'cctDeviceQuantityCorrection';
    cctDeviceDensityCorrection: Result := 'cctDeviceDensityCorrection';
  else Result := 'Unknown';
  end;
end;

function TryResolveCalibrCoefTableTarget(const ARawType: Integer;
  out ATableType: TCalibrCoefTableType; out AResolvedTypeName,
  ATargetField: string): Boolean;
begin
  AResolvedTypeName := '';
  ATargetField := '';
  Result := TryCalibrCoefTableType(ARawType, ATableType);
  if not Result then Exit;
  AResolvedTypeName := CalibrCoefTableTypeName(ATableType);
  case ATableType of
    cctReference: ATargetField := 'Device.CalibrCoefTables[cctReference]';
    cctMeterValueCoef: ATargetField := 'ValueCoef';
    cctMeterValueFlowRate: ATargetField := 'ValueFlow';
    cctMeterValueQuantity: ATargetField := 'ValueQuantity';
    cctMeterValueDensity: ATargetField := 'ValueDensity';
  else
    Result := False;
  end;
end;

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


function TDevicePoint.GetMeasurementPointStatus: EMeasurementPointStatus;
begin
  Result := FStatus;
end;

procedure TDevicePoint.SetMeasurementPointStatus(const Value: EMeasurementPointStatus);
begin
  FStatus := Value;
end;

function TDevicePoint.GettargetEtalonType : integer;
begin
    if (EtalonType=0) then
    begin
      Result:= 0;
    end

    else if (EtalonType=1) then
    begin
      Result:= 0;
    end

     else if (EtalonType=2) then
    begin
      Result:= 0;
    end

    else if (EtalonType=3) then
    begin
      Result:= 1;
    end
end;


procedure TDevicePoint.SettargetEtalonType(etalonType:integer);
begin
   EtalonType:= etalonType;
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
  Qnom:=1;
  Qtr:=1;
  RangeDynamic := 100.0;            // Qmax / Qmin
  Temp := '';
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
  SyncMode := 0;
  NoiseFilter := 0;
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
  FStatus := mdsNone;
  FValidation := vsNone;
  FValidationReason := dvrNotAnalyzed;
  FValidationMessage := '';

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
      NewItem := SrcItem.Clone;
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
var
  Sp: TPointSpillage;
  NewSp: TPointSpillage;
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

  if ASource.FSpillages <> nil then
    for Sp in ASource.FSpillages do
    begin
      if Sp = nil then
        Continue;
      NewSp := TPointSpillage.Create(Sp.SessionID);
      NewSp.Assign(Sp);
      FSpillages.Add(NewSp);
    end;
end;



constructor TDevicePoint.Create;
begin
  inherited Create;

  DataPoints := TObjectList<TPointSpillage>.Create(False);
  ProtocolDataPoints := TObjectList<TPointSpillage>.Create(False);

  FID := 0;
  FState := osClean;
  FEnabled := True;

  { Идентификация }
  DeviceID := -1;
  DeviceTypeUUID := '';

  { Общая информация }
  Name := 'Точка вспомогательная';
  Description := 'Точка измерения не принадлежащая устройству';
  Num := 0;
  DateTime := 0;

  { Параметры расхода }
  FlowRate := 0.0;
  Q := 0.0;
  FlowAccuracy := '';
  CommonMinQ := 0.0;
  CommonMaxQ := 0.0;
  MinEtalonDeltaQ := 0.0;
  EtalonRangeValid := False;

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
  RequireAutoStabilization := False;
  RequiredStabilizationSec := 0.0;

  { Повторы }
  RepeatsProtocol := 0;
  Repeats := 0;
  RepeatsCompleted := 0;

  Status := mptsNone;
  FValidation := vsNone;
  FValidationReason := pvrNotAnalyzed;
  FValidationMessage := '';
  ResultError := 0.0;
  AverageError := 0.0;
  StdDev := 0.0;
end;



constructor TDevicePoint.Create(ADeviceID : Integer);
begin
  inherited Create;

  DataPoints := TObjectList<TPointSpillage>.Create(False);
  ProtocolDataPoints := TObjectList<TPointSpillage>.Create(False);

  FID := 0;
  FState := osNew;
  FEnabled := True;

  { Идентификация }
  DeviceID := ADeviceID;
  DeviceTypeUUID := '';

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
  RequireAutoStabilization := False;
  RequiredStabilizationSec := 0.0;

  { Повторы }
  RepeatsProtocol := 0;
  Repeats := 0;
  RepeatsCompleted := 0;

  Status := mptsNone;
  FValidation := vsNone;
  FValidationReason := pvrNotAnalyzed;
  FValidationMessage := '';
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
  DeviceUUID := '';
  DeviceTypeUUID := '';
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
  FStatus := mssCreated;
  FValidation := vsNone;
  FValidationReason := svrNotAnalyzed;
  FValidationMessage := '';
  Error := 0.0;

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
  S: TSessionSpillage;
  NewS: TSessionSpillage;
  Sp: TPointSpillage;
  NewSp: TPointSpillage;
  Table: TCalibrCoefTable;
begin
  if ASource = nil then
    Exit;

  if FullAssign then
   begin
     SerialNumber := ASource.SerialNumber;
     UUID:=  ASource. UUID;
     ID:=  ASource.  ID;
     fState  := ASource.State;
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
  Qnom := ASource.Qnom;
  Qtr := ASource.Qtr;
  RangeDynamic := ASource.RangeDynamic;
  Temp := ASource.Temp;
  Error := ASource.Error;

  VerificationMethod := ASource.VerificationMethod;
  ProcedureName := ASource.ProcedureName;

  MeasuredDimension := ASource.MeasuredDimension;
  Units := ASource.Units;
  SetDimensions;
  OutputType := ASource.OutputType;
  DimensionCoef := ASource.DimensionCoef;

  OutputSet := ASource.OutputSet;
  SyncMode := ASource.SyncMode;
  NoiseFilter := ASource.NoiseFilter;
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
  FValidation := ASource.Validation;
  FValidationReason := ASource.ValidationReason;
  FValidationMessage := ASource.ValidationMessage;

  Comment := ASource.Comment;
  Description := ASource.Description;
  ReportingForm := ASource.ReportingForm;

  { ============================= }
  { 2. Глубокое копирование вложенных списков }
  {    сессии, проливы и таблицы КК }
  { ============================= }

  FSessions.Clear;
  if ASource.FSessions <> nil then
    for S in ASource.FSessions do
    begin
      if S = nil then
        Continue;
      NewS := TSessionSpillage.Create(S.DeviceUUID);
      NewS.Assign(S);
      FSessions.Add(NewS);
    end;

  FSpillages.Clear;
  if ASource.FSpillages <> nil then
    for Sp in ASource.FSpillages do
    begin
      if Sp = nil then
        Continue;
      NewSp := TPointSpillage.Create(Sp.SessionID);
      NewSp.Assign(Sp);
      FSpillages.Add(NewSp);
    end;

  FCalibrCoefTable.Clear;
  { Калибровочные таблицы нужны рабочей копии прибора в редакторе, но
    переносятся только при полном копировании с сохранением UUID. }
  if FullAssign and (ASource.CalibrCoefTables <> nil) then
    for Table in ASource.CalibrCoefTables do
      if Table <> nil then
        { Clone создаёт независимые глубокие копии таблицы и всех её элементов. }
        FCalibrCoefTable.Add(Table.Clone);

  { ============================= }
  { 3. Глубокое копирование точек }
  { ============================= }

  FPoints.Clear;

  if ASource.FPoints <> nil then
    for P in ASource.FPoints do
    begin
      if P = nil then
        Continue;
      NewP := TDevicePoint.Create(ID);
      NewP.Assign(P, FullAssign);
      if FullAssign then
        NewP.State := P.State
      else
      begin
        NewP.ID := TEntityHelpers<TDevicePoint>.NextID(FPoints);
        NewP.DeviceID := ID;
        NewP.DeviceUUID := UUID;
        NewP.State := osNew;
      end;
      FPoints.Add(NewP);
    end;
end;

procedure TDevice.AssignWithoutMeasurementHistory(ASource: TDevice);
begin
  { Copy device configuration only. Sessions and spillages are created later,
    when a measurement is actually started. }
  Assign(ASource, False);
  FSessions.Clear;
  FSpillages.Clear;
end;

procedure TCalibrCoefItem.Assign(ASource: TCalibrCoefItem);
begin
  if ASource = nil then
    Exit;

  Name := ASource.Name;
  UUID := ASource.UUID;
  TableID := ASource.TableID;
  OrderNo := ASource.OrderNo;
  Value := ASource.Value;
  Arg := ASource.Arg;
  QFrom := ASource.QFrom;
  QTo := ASource.QTo;
  RangeArg := ASource.RangeArg;
  K := ASource.K;
  b := ASource.b;
  Enable := ASource.Enable;
end;

function TCalibrCoefItem.Clone: TCalibrCoefItem;
begin
  Result := TCalibrCoefItem.Create;
  Result.Assign(Self);
end;

function TCalibrCoefItem.InRange(Q: Double): Boolean;
begin
  Result := (Q >= QFrom) and ((Q < QTo) or SameValue(Q, QTo));
end;

constructor TCalibrCoefTable.Create;
begin
  inherited Create;
  // A newly created device table is a coefficient correction table.  Assign
  // the persisted value here, before any points can be appended to Items.
  SetTableType(cctMeterValueCoef);
  Active := False;
  Items := TObjectList<TCalibrCoefItem>.Create(True);
end;

function TCalibrCoefTable.TableType: TCalibrCoefTableType;
begin
  Result := TCalibrCoefTableType(&Type);
end;

procedure TCalibrCoefTable.SetTableType(const AType: TCalibrCoefTableType);
begin
  &Type := Ord(AType);
end;

destructor TCalibrCoefTable.Destroy;
begin
  Items.Free;
  inherited;
end;

procedure TCalibrCoefTable.Assign(ASource: TCalibrCoefTable);
var
  SrcItem: TCalibrCoefItem;
begin
  if ASource = nil then
    Exit;

  ID := ASource.ID;
  UUID := ASource.UUID;
  DeviceID := ASource.DeviceID;
  DeviceUUID := ASource.DeviceUUID;
  &Type := ASource.&Type;
  Active := ASource.Active;
  AppliedAt := ASource.AppliedAt;
  Name := ASource.Name;
  Comment := ASource.Comment;

  if Items = nil then
    Items := TObjectList<TCalibrCoefItem>.Create(True)
  else
    Items.Clear;

  if ASource.Items <> nil then
    for SrcItem in ASource.Items do
      if SrcItem <> nil then
        Items.Add(SrcItem.Clone);
end;

function TCalibrCoefTable.Clone: TCalibrCoefTable;
begin
  Result := TCalibrCoefTable.Create;
  Result.Assign(Self);
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
    Add(Temp);
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
      Add(P.DeviceTypeUUID);
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
      Add(S.DeviceUUID);
      Add(S.DeviceTypeUUID);
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
      { Preserve the legacy hash field order and encoding for stored records. }
      Add(IntToStr(SpillageValidationToLegacyCode(S.Validation, S.ValidationReason)));
      Add(S.ValidationMessage);
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

  DeviceTypeUUID := ASource.DeviceTypeUUID;
  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}

  State  := osModified;     //????????????????
  Enabled := ASource.Enabled;

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
  RequireAutoStabilization := ASource.RequireAutoStabilization;
  RequiredStabilizationSec := ASource.RequiredStabilizationSec;
  Participants := Copy(ASource.Participants);
  SourcePointCount := ASource.SourcePointCount;

  {====================================================================}
  { ПОВТОРЫ И СЕРИИ }
  {====================================================================}
  RepeatsProtocol := ASource.RepeatsProtocol;
  Repeats := ASource.Repeats;
  RepeatsCompleted := ASource.RepeatsCompleted;

  { Configuration copies must never inherit state from another measurement
    run.  Runtime state is copied only by the explicitly requested full copy. }
  if FullAssign then
  begin
    Status := ASource.Status;
    FValidation := ASource.Validation;
    FValidationReason := ASource.ValidationReason;
    FValidationMessage := ASource.ValidationMessage;
    ResultError := ASource.ResultError;
    AverageError := ASource.AverageError;
    StdDev := ASource.StdDev;
  end
  else
  begin
    Status := mptsNone;
    FValidation := vsNone;
    FValidationReason := pvrNotAnalyzed;
    FValidationMessage := '';
    ResultError := 0; AverageError := 0; StdDev := 0;
  end;

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

  DeviceTypeUUID := ASource.UUID;
  Enabled := True;
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
    mptsNone: Result := '-';
    mptsSelectPoint: Result := 'выбрана';
    mptsInvalidPoint: Result := 'некорректна';
    mptsSelectEtalon: Result := 'выбор эталона';
    mptsSetupPoint: Result := 'установка';
    mptsWaitStable: Result := 'стабилизация';
    mptsWaitMeasureStart: Result := 'запуск';
    mptsMeasure: Result := 'измерение';
    mptsWaitMeasureStop: Result := 'остановка';
    mptsResultsRead: Result := 'чтение результатов';
    mptsSave: Result := 'сохранение';
    mptsDone: Result := 'завершено';
    mptsSetupError: Result := 'ошибка установки';
    mptsMeasureError: Result := 'ошибка измерения';
    mptsInterrupted: Result := 'прервано';
    mptsCancelled: Result := 'Отменено';
    mptsSaved: Result := 'сохранено';
    mptsStabilityError: Result := 'ошибка стабилизации';
    mptsDevicePointMismatch: Result := 'точка прибора не сопоставлена';
    mptsSkipped: Result := 'Пропущена';
  else
    Result := 'неизвестный статус';
  end;
end;

function TDevicePoint.GetStatusHint: string;
begin
  case Status of
    mptsNone: Result := 'Измерение в точке ещё не выполнялось';
    mptsSelectPoint: Result := 'Точка выбрана для выполнения измерения';
    mptsInvalidPoint: Result := 'Точка некорректна или не может быть использована для измерения';
    mptsSelectEtalon: Result := 'Выполняется выбор эталонных средств измерения';
    mptsSetupPoint: Result := 'Выполняется установка параметров измерительной точки';
    mptsWaitStable: Result := 'Выполняется ожидание стабилизации параметров';
    mptsWaitMeasureStart: Result := 'Команда запуска передана, ожидается фактическое начало измерения';
    mptsMeasure: Result := 'Выполняется измерение';
    mptsWaitMeasureStop: Result := 'Команда остановки передана, ожидается завершение измерения';
    mptsResultsRead: Result := 'Выполняется чтение итоговых результатов измерения';
    mptsSave: Result := 'Выполняется сохранение результатов';
    mptsDone: Result := 'Измерение завершено, результаты ожидают сохранения или отмены';
    mptsSetupError: Result := 'Не удалось установить параметры измерительной точки';
    mptsMeasureError: Result := 'Во время выполнения измерения произошла ошибка';
    mptsInterrupted: Result := 'Измерение было принудительно прервано';
    mptsCancelled: Result := 'Полученные результаты были отменены пользователем';
    mptsSaved: Result := 'Измерение завершено, результаты успешно сохранены';
    mptsSkipped: Result := 'Точка пропущена пользователем при ручном переходе';
  else
    Result := 'Неизвестный статус точки';
  end;
end;

function TDevicePoint.GetStatusColor: TAlphaColor;
begin
  Result := GetPointExecutionStatusColor(Status);
end;

procedure TDevicePoint.SetValidation(const AValidation: EValidationStatus;
  const AReason: EPointValidationReason; const AMessage: string);
begin
  if ((AValidation = vsValid) and (AReason <> pvrRequiredValidMeasurementsCollected)) or
     ((AValidation = vsInvalid) and (AReason <> pvrInsufficientValidMeasurements)) then
    raise EArgumentException.Create('Недопустимое сочетание результата и причины поверочной точки');
  if (FValidation = AValidation) and (FValidationReason = AReason) and
     (FValidationMessage = AMessage) then Exit;
  FValidation := AValidation; FValidationReason := AReason; FValidationMessage := AMessage;
  State := osModified;
end;

function TDevicePoint.GetShortStateText: string;
begin
  Result := LowerCase(ValidationStatusToText(Validation));
  if Validation in [vsValid, vsInvalid] then
    Result := Result + ' — ' + LowerCase(PointValidationReasonToText(ValidationReason));
end;

function TDevicePoint.GetFullStateText: string;
begin
  Result := 'Состояние выполнения: ' + MeasurementPointStatusToText(Status) + '.' + sLineBreak +
    'Метрологический результат: ' + LowerCase(ValidationStatusToText(Validation)) + '.';
  if PointValidationReasonToText(ValidationReason) <> '' then
    Result := Result + sLineBreak + 'Причина: ' + LowerCase(PointValidationReasonToText(ValidationReason)) + '.';
  if Trim(ValidationMessage) <> '' then Result := Result + sLineBreak + 'Пояснение: ' + ValidationMessage + '.';
end;

procedure TPointSpillage.SetStatus(const AValue: EMeasurementSpillageStatus);
begin
  if FStatus = AValue then Exit;
  FStatus := AValue; State := osModified;
end;

function TPointSpillage.GetValid: Boolean;
begin Result := Validation = vsValid; end;

procedure TPointSpillage.SetValidation(const AValidation: EValidationStatus;
  const AReason: ESpillageValidationReason; const AMessage: string);
begin
  if ((AValidation = vsValid) and (AReason <> svrErrorWithinTolerance)) or
     ((AValidation = vsInvalid) and (AReason <> svrErrorExceeded)) then
    raise EArgumentException.Create('Недопустимое сочетание результата и причины измерения');
  if (FValidation = AValidation) and (FValidationReason = AReason) and
     (FValidationMessage = AMessage) then Exit;
  FValidation := AValidation; FValidationReason := AReason; FValidationMessage := AMessage;
  State := osModified;
end;

procedure TPointSpillage.ImportLegacyValidation(const ALegacyStatus: Integer;
  const ALegacyMessage: string; const ALegacyValid: Boolean);
begin
  { Explicit migration is mandatory: legacy 0..5 represented metrology, not
    execution.  ALegacyValid is intentionally only a consistency hint. }
  case ALegacyStatus of
    0: begin FStatus := mssCreated; SetValidation(vsNone, svrNotAnalyzed, ALegacyMessage); end;
    1: begin FStatus := mssDataAssigned; SetValidation(vsNone, svrNotAnalyzed, ALegacyMessage); end;
    2: begin FStatus := mssCompleted; SetValidation(vsUndefined, svrPointNotMatched, ALegacyMessage); end;
    3: begin FStatus := mssCompleted; SetValidation(vsUndefined, svrStopCriteriaFailed, ALegacyMessage); end;
    4: begin FStatus := mssCompleted; SetValidation(vsInvalid, svrErrorExceeded, ALegacyMessage); end;
    5: begin FStatus := mssCompleted; SetValidation(vsValid, svrErrorWithinTolerance, ALegacyMessage); end;
  else begin FStatus := mssError; SetValidation(vsUndefined, svrInvalidSourceData,
    Format('%s (неизвестный старый код %d)', [ALegacyMessage, ALegacyStatus])); end; end;
end;

function TPointSpillage.GetShortStateText: string;
begin
  Result := LowerCase(ValidationStatusToText(Validation));
  if Validation in [vsValid, vsInvalid] then Result := Result + ' — ' + LowerCase(SpillageValidationReasonToText(ValidationReason));
end;

function TPointSpillage.GetFullStateText: string;
begin
  Result := 'Состояние выполнения: ' + MeasurementSpillageStatusToText(Status) + '.' + sLineBreak +
    'Метрологический результат: ' + LowerCase(ValidationStatusToText(Validation)) + '.';
  if SpillageValidationReasonToText(ValidationReason) <> '' then Result := Result + sLineBreak + 'Причина: ' + LowerCase(SpillageValidationReasonToText(ValidationReason)) + '.';
  if Trim(ValidationMessage) <> '' then Result := Result + sLineBreak + 'Пояснение: ' + ValidationMessage + '.';
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

  if (ASource.DeviceUUID <> Self.DeviceUUID) or
     (ASource.Name <> Self.Name) or
     (ASource.SessionID <> Self.SessionID) then
    LogMKS('DBG SP 3001', 'TPointSpillage.Assign BEFORE',
      Format('Self=%s | Source=%s', [DumpSpillage(Self), DumpSpillage(ASource)]));

  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}
  State := ASource.State;

  {====================================================================}
  { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
  {====================================================================}

  SessionID := ASource.SessionID;
  DeviceUUID := ASource.DeviceUUID;
  DeviceTypeUUID := ASource.DeviceTypeUUID;
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
  FStatus := ASource.Status;
  FValidation := ASource.Validation;
  FValidationReason := ASource.ValidationReason;
  FValidationMessage := ASource.ValidationMessage;
  Error := ASource.Error;

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

  if (ASource.DeviceUUID <> Self.DeviceUUID) or
     (ASource.Name <> Self.Name) or
     (ASource.SessionID <> Self.SessionID) or
     (Self.Name = '-') then
    LogMKS('DBG SP 3002', 'TPointSpillage.Assign AFTER',
      Format('Self=%s | Source=%s', [DumpSpillage(Self), DumpSpillage(ASource)]));
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
  Result.Q := Result.FlowRate * Qmax;

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

    if Sess.State = osDeleted then
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
    for Sess in Sessions do
      if (Sess <> nil) and (Sess.State <> osDeleted) then
      begin
        Result := Sess;
        Result.Active := True;
          Result.State := osModified;
        Break;
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

function TDevice.FindMatchedDevicePointForSpillage(
  const ASpillage: TPointSpillage
): TDevicePoint;
var
  P: TDevicePoint;
begin
  Result := nil;
  if (ASpillage = nil) or (FPoints = nil) then
    Exit;

  if (Trim(ASpillage.DeviceUUID) <> '') and
     (not SameText(Trim(ASpillage.DeviceUUID), Trim(Self.UUID))) then
    Exit;

  for P in FPoints do
    if (P <> nil) and IsFlowInPoint(ASpillage.QavgEtalon, P) then
      Exit(P);

end;

function TDevice.AnalyseDataPoint(const ASpillage: TPointSpillage): EValidationStatus;
var
  MatchedPoint: TDevicePoint;
  StopOk: Boolean;
  StopCriteria: TSpillageStopCriteria;
  MeasuredValue: Double;
  MessageText: string;
begin
  Result := vsUndefined;
  if ASpillage = nil then Exit;
  ASpillage.DeviceUUID := Self.UUID;
  ASpillage.Status := mssAnalyzing;
  MatchedPoint := FindMatchedDevicePointForSpillage(ASpillage);
  if MatchedPoint = nil then
  begin
    ASpillage.Name := '-'; ASpillage.Status := mssCompleted;
    ASpillage.SetValidation(vsUndefined, svrPointNotMatched,
      'Расход не соответствует ни одной поверочной точке прибора');
    Exit;
  end;
  ASpillage.DeviceTypeUUID := MatchedPoint.DeviceTypeUUID;
  ASpillage.Name := MatchedPoint.Name;
  StopCriteria := MatchedPoint.StopCriteria;
  if StopCriteria = [] then StopCriteria := Self.StopCriteria;
  if StopCriteria = [] then StopCriteria := [scTime];
  StopOk := True; MessageText := '';
  if scImpulse in StopCriteria then
  begin
    StopOk := ASpillage.PulseCount >= MatchedPoint.LimitImp;
    if not StopOk then MessageText := Format('Фактическое количество импульсов %.6f, требуется %d', [ASpillage.PulseCount, MatchedPoint.LimitImp]);
  end;
  if StopOk and (scVolume in StopCriteria) then
  begin
    if (MeasuredDimension = Ord(mdMassFlow)) or (MeasuredDimension = Ord(mdMass)) then MeasuredValue := ASpillage.DeviceMass else MeasuredValue := ASpillage.DeviceVolume;
    StopOk := MeasuredValue >= MatchedPoint.LimitVolume;
    if not StopOk then MessageText := Format('Фактический объём/масса %.6f, требуется %.6f', [MeasuredValue, MatchedPoint.LimitVolume]);
  end;
  if StopOk and (scTime in StopCriteria) then
  begin
    StopOk := ASpillage.SpillTime >= MatchedPoint.LimitTime;
    if not StopOk then MessageText := Format('Фактическое время %.3f с, требуется %.3f с', [ASpillage.SpillTime, MatchedPoint.LimitTime]);
  end;
  ASpillage.Status := mssCompleted;
  if not StopOk then begin ASpillage.SetValidation(vsUndefined, svrStopCriteriaFailed, MessageText); Exit; end;
  if Abs(ASpillage.Error) > Abs(MatchedPoint.Error) then
  begin
    ASpillage.SetValidation(vsInvalid, svrErrorExceeded, Format('Фактическая погрешность %.6f %%, допустимая погрешность %.6f %%', [ASpillage.Error, MatchedPoint.Error]));
    Result := vsInvalid; Exit;
  end;
  ASpillage.SetValidation(vsValid, svrErrorWithinTolerance, Format('Фактическая погрешность %.6f %%, допустимая погрешность %.6f %%', [ASpillage.Error, MatchedPoint.Error]));
  Result := vsValid;
end;

procedure TDevice.FillDataPointsList(APoint: TDevicePoint);
var
  S: TPointSpillage;
  CandidateList: TList<TPointSpillage>;
  MatchedPoint: TDevicePoint;
  Changed: Boolean;
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

  Changed := False;
  CandidateList := TList<TPointSpillage>.Create;
  try
    for S in Spillages do
      if (S <> nil) and S.Enabled and (S.State <> osDeleted) and
         (S.SessionID = ActiveSession.ID) then
      begin
        MatchedPoint := FindMatchedDevicePointForSpillage(S);
        if MatchedPoint <> APoint then
          Continue;

        if Trim(S.DeviceUUID) = '' then
        begin
          S.DeviceUUID := Self.UUID;
          S.State := osModified;
          Changed := True;
        end;

        if (S.DeviceTypeUUID <> APoint.DeviceTypeUUID) or
           (not SameText(S.Name, APoint.Name)) then
        begin
          S.DeviceTypeUUID := APoint.DeviceTypeUUID;
          S.Name := APoint.Name;
          S.State := osModified;
          Changed := True;
        end;

        APoint.DataPoints.Add(S);
        if S.Validation in [vsValid, vsInvalid] then
          CandidateList.Add(S);
      end;

    if Changed then
      Self.State := osModified;

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
  DP: TDevicePoint; S: TPointSpillage;
  MatchedCount, ValidCount, InvalidCount, RequiredCount: Integer;
  ErrorsSum, VarianceSum, WorstValid: Double;
begin
  if Points = nil then Exit;
  for DP in Points do
  begin
    FillDataPointsList(DP);
    DP.ResultError := 0; DP.AverageError := 0; DP.StdDev := 0;
    if not DP.Enabled then begin DP.SetValidation(vsUndefined, pvrDisabled, 'Поверочная точка отключена'); Continue; end;
    RequiredCount := DP.RepeatsProtocol; if RequiredCount <= 0 then RequiredCount := 1;
    MatchedCount := 0; ValidCount := 0; InvalidCount := 0; ErrorsSum := 0; WorstValid := 0;
    for S in DP.DataPoints do
      if (S <> nil) and S.Enabled and (S.State <> osDeleted) and (S.Validation in [vsValid, vsInvalid]) then
      begin
        Inc(MatchedCount); ErrorsSum := ErrorsSum + S.Error;
        if S.Validation = vsValid then begin Inc(ValidCount); if Abs(S.Error) > WorstValid then WorstValid := Abs(S.Error); end
        else Inc(InvalidCount);
      end;
    if MatchedCount > 0 then
    begin
      DP.AverageError := ErrorsSum / MatchedCount; VarianceSum := 0;
      for S in DP.DataPoints do if (S <> nil) and S.Enabled and (S.State <> osDeleted) and (S.Validation in [vsValid, vsInvalid]) then VarianceSum := VarianceSum + Sqr(S.Error - DP.AverageError);
      DP.StdDev := Sqrt(VarianceSum / MatchedCount);
    end;
    DP.ResultError := WorstValid;
    if ValidCount >= RequiredCount then
      DP.SetValidation(vsValid, pvrRequiredValidMeasurementsCollected, Format('Годных измерений %d из требуемых %d; негодных %d', [ValidCount, RequiredCount, InvalidCount]))
    else if MatchedCount < RequiredCount then
      DP.SetValidation(vsUndefined, pvrInsufficientMatchedMeasurements, Format('Соответствующих измерений %d из требуемых %d', [MatchedCount, RequiredCount]))
    else
      DP.SetValidation(vsInvalid, pvrInsufficientValidMeasurements, Format('Годных измерений %d из требуемых %d; негодных %d', [ValidCount, RequiredCount, InvalidCount]));
  end;
end;

procedure TDevice.AnalyseResults;
var
  DP: TDevicePoint;
  EnabledCount, ValidCount, InvalidCount, UndefinedCount: Integer;
begin
  AnalyseDevicePointsResults;
  if (Points = nil) or (Points.Count = 0) then begin SetValidation(vsUndefined, dvrNoPoints, 'У прибора отсутствуют поверочные точки'); Exit; end;
  EnabledCount := 0; ValidCount := 0; InvalidCount := 0; UndefinedCount := 0;
  for DP in Points do if (DP <> nil) and DP.Enabled then
  begin
    Inc(EnabledCount);
    case DP.Validation of vsValid: Inc(ValidCount); vsInvalid: Inc(InvalidCount); else Inc(UndefinedCount); end;
  end;
  if EnabledCount = 0 then SetValidation(vsUndefined, dvrNoEnabledPoints, 'Нет включённых поверочных точек')
  else if ValidCount = EnabledCount then SetValidation(vsValid, dvrAllPointsValid, Format('Годны все %d поверочных точек', [EnabledCount]))
  else if InvalidCount > 0 then
    if UndefinedCount > 0 then SetValidation(vsInvalid, dvrInvalidPointsAndIncomplete, Format('Негодных точек %d, без результата %d', [InvalidCount, UndefinedCount]))
    else SetValidation(vsInvalid, dvrInvalidPointsAndComplete, Format('Негодных точек %d из %d', [InvalidCount, EnabledCount]))
  else SetValidation(vsUndefined, dvrPointsIncomplete, Format('Без результата %d из %d точек', [UndefinedCount, EnabledCount]));
end;

procedure TDevice.SetValidation(const AValidation: EValidationStatus;
  const AReason: EDeviceValidationReason; const AMessage: string);
begin
  if ((AValidation = vsValid) and (AReason <> dvrAllPointsValid)) or
     ((AValidation = vsInvalid) and not (AReason in [dvrInvalidPointsAndIncomplete, dvrInvalidPointsAndComplete])) then
    raise EArgumentException.Create('Недопустимое сочетание результата и причины прибора');
  if (FValidation = AValidation) and (FValidationReason = AReason) and (FValidationMessage = AMessage) then Exit;
  FValidation := AValidation; FValidationReason := AReason; FValidationMessage := AMessage; State := osModified;
end;

function TDevice.GetShortStateText: string;
begin
  Result := LowerCase(ValidationStatusToText(Validation));
  if Validation in [vsValid, vsInvalid] then Result := Result + ' — ' + LowerCase(DeviceValidationReasonToText(ValidationReason));
end;

function TDevice.GetFullStateText: string;
begin
  Result := 'Состояние выполнения: ' + MeasurementDeviceStatusToText(Status) + '.' + sLineBreak +
    'Метрологический результат: ' + LowerCase(ValidationStatusToText(Validation)) + '.';
  if DeviceValidationReasonToText(ValidationReason) <> '' then Result := Result + sLineBreak + 'Причина: ' + LowerCase(DeviceValidationReasonToText(ValidationReason)) + '.';
  if Trim(ValidationMessage) <> '' then Result := Result + sLineBreak + 'Пояснение: ' + ValidationMessage + '.';
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
  Repeats := AType.Repeats;
  RepeatsProtocol := AType.RepeatsProtocol;

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
  Qnom := ADiameter.Qnom;
  Qtr := ADiameter.Qtr;
  Q2tr := ADiameter.Q2tr;

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
  if Points = nil then
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
      if Coef > 0 then
        P.LimitImp := Round(V * Coef);
    end;
    P.State := osModified;
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
    DP.Q := DP.FlowRate * Qmax;
    DP.SpillageStop := SpillageStop;
  end;

  if Points.Count > 0 then
  begin
    if Points[0].Repeats > 0 then
      Repeats := Points[0].Repeats
    else
      Repeats := Max(AType.Repeats, 1);

    if Points[0].RepeatsProtocol > 0 then
      RepeatsProtocol := Points[0].RepeatsProtocol
    else
      RepeatsProtocol := Max(AType.RepeatsProtocol, 1);
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

