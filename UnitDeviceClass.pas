unit UnitDeviceClass;

interface

 uses
     UnitClasses,
    System.Generics.Defaults, System.DateUtils,     System.Math,
    System.Generics.Collections,    System.StrUtils,    UnitBaseProcedures,
  System.SysUtils;

type


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
    dsfValidityDate          // Действует до
  );


  TDevicePoint = class (TTypeEntity)
   public
    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}

    DeviceID: Integer;           // Идентификатор прибора (FK → TDevice.ID)
    DeviceTypePointID: Integer;  // Идентификатор шаблонной точки типа (опционально)

    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}
    Name: string;                // Наименование точки (Qmax, Qnom, Q1...)
    Description: string;         // Описание / примечания

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

    {====================================================================}
    { СЛУЖЕБНОЕ }
    {====================================================================}
    Num: Integer;                // Порядковый номер точки (для сортировки / UI)

    constructor Create(ADeviceID : Integer);

    procedure Assign(ASource: TDevicePoint);
  end;

  TPointSpillage = class (TTypeEntity)

  public
    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}

    DeviceID: Integer;           // Прибор, к которому относится измерение (FK → TDevice.ID)
    DevicePointID: Integer;      // Поверочная точка прибора (FK → TDevicePoint.ID)
    DeviceTypePointID: Integer;  // Шаблонная точка типа (опционально)

    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}

    Description: string;         // Комментарий оператора

    DateTime: TDateTime;         // Дата и время окончания измерения
    OperatorName: string;        // Оператор (опционально)
    EtalonName: string;          // Эталон, использованный при измерении

    {====================================================================}
    { ПАРАМЕТРЫ ИЗМЕРЕНИЯ (УСТАНОВКА / ЭТАЛОН) }
    {====================================================================}

    SpillTime: Double;           // Время измерения, сек

    QavgEtalon: Double;          // Средний расход по эталону, м3/ч (т/ч)
    EtalonVolume: Double;        // Объем эталона, л
    EtalonMass: Double;          // Масса эталона, кг

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

    {====================================================================}
    { РЕЗУЛЬТАТ ИЗМЕРЕНИЯ }
    {====================================================================}

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

    PulseCount: Integer;         // Кол-во импульсов
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
    ArchivedData: string;        // Архив сырых данных (по секундам и т.п.)

    constructor Create (ADeviceID : Integer);


    procedure Assign(ASource: TPointSpillage);
  end;

  TDevice = class(TTypeEntity)
  private
      FSpillages  : TObjectList<TPointSpillage>;
      FPoints     : TObjectList<TDevicePoint>;
      FDeviceType : TDeviceType;
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

    {====================================================================}
    { ОПИСАНИЕ И ПРИМЕЧАНИЯ }
    {====================================================================}
    Comment: string;
    Description: string;
    ReportingForm: string;

  public
    constructor Create;
    destructor Destroy;

    procedure Assign(ASource: TDevice);
    function Clone: TDevice;

    function CompareTo(
      const B: TDevice;
      ASortField: TDeviceSortField
    ): Integer;

    function AddPoint: TDevicePoint;
    function AddSpillage: TPointSpillage;

    property  Spillages  : TObjectList<TPointSpillage> read FSpillages write FSpillages;
    property  Points     : TObjectList<TDevicePoint> read  FPoints write  FPoints;

    procedure AttachType(AType: TDeviceType; RepoName: String);
    procedure FillFromType(AType: TDeviceType);

  end;

implementation

destructor TDevice.Destroy;
begin
  FSpillages.Free;
  FPoints.Free;
  inherited;
end;

constructor TDevice.Create;
begin
  inherited Create;

   {----------------------------------}
  { Создание коллекций }
  {----------------------------------}
  FSpillages := TObjectList<TPointSpillage>.Create(True);
  FPoints    := TObjectList<TDevicePoint>.Create(True);

  {----------------------------------}
  { Идентификация }
  {----------------------------------}
  DeviceTypeUUID := '';
  DeviceTypeName := '';
  DeviceTypeRepo := '';
   {----------------------------------}
  { Наименование и паспорт }
  {----------------------------------}
  Name := 'Новый прибор';
  SerialNumber := '000000';
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
  DN := 'DN25';
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
  SpillageStop := 0;
  Repeats := 3;
  RepeatsProtocol := 3;

  {----------------------------------}
  { Описание }
  {----------------------------------}
  Comment := '';
  Description := '';
  ReportingForm := '';
end;

constructor TDevicePoint.Create(ADeviceID : Integer);
begin
  inherited Create;

  FID := 0;
  FState := osNew;

  { Идентификация }
  DeviceID := ADeviceID;
  DeviceTypePointID := 0;

  { Общая информация }
  Name := 'Новая поверочная точка';
  Description := 'Наименование точки (Qmax, Qnom, Q1...)';
  Num := 0;

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

  { Метрология }
  Error := 0.0;

  { Дополнительно }
  Pause := 0;

  { Повторы }
  RepeatsProtocol := 0;
  Repeats := 0;
end;

constructor TPointSpillage.Create(ADeviceID : Integer);
begin
  inherited Create;

  { Идентификация }
  DeviceID := ADeviceID;
  DevicePointID := 0;
  DeviceTypePointID := 0;
  Num := 0;

  { Общая информация }
  Name := 'Новое измерение';
  Description := ' ';
  DateTime := 0;
  OperatorName := '';
  EtalonName := '';

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
  Error := 0.0;
  Valid := False;

  { Статистика прибора }
  QStd := 0.0;
  QCV := 0.0;

  { Счётчики }
  VolumeBefore := 0.0;
  VolumeAfter := 0.0;

  { Сырые данные }
  PulseCount := 0;
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

procedure TDevice.Assign(ASource: TDevice);
var
  S: TPointSpillage;
  NewS: TPointSpillage;
  P: TDevicePoint;
  NewP: TDevicePoint;
begin
  if ASource = nil then
    Exit;

  { ============================= }
  { 1. Копирование простых полей  }
  { ============================= }

  MitUUID := ASource.MitUUID;
  DeviceTypeUUID := ASource.DeviceTypeUUID;
  DeviceTypeName := ASource.DeviceTypeName;
  DeviceTypeRepo := ASource.DeviceTypeRepo;

  Name := ASource.Name;
  SerialNumber := ASource.SerialNumber;
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

  Comment := ASource.Comment;
  Description := ASource.Description;
  ReportingForm := ASource.ReportingForm;

  { Состояние }
  State := ASource.State;

  { ============================= }
  { 2. Глубокое копирование проливов }
  { ============================= }

  FSpillages.Clear;

  for S in ASource.FSpillages do
  begin
    NewS := AddSpillage;     // ← создаём через агрегат
    NewS.Assign(S);
  end;

  { ============================= }
  { 3. Глубокое копирование точек }
  { ============================= }

  FPoints.Clear;

  for P in ASource.FPoints do
  begin
    NewP := AddPoint;        // ← создаём через агрегат
    NewP.Assign(P);
  end;
end;

function TDevice.Clone: TDevice;
begin
  Result := TDevice.Create;
  Result.Assign(Self);
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
      Result := Category - B.Category;

    dsfDN:
      Result := CompareText(DN, B.DN);

    dsfQmax:
      Result := CompareValue(Qmax, B.Qmax);

    dsfAccuracyClass:
      Result := CompareText(AccuracyClass, B.AccuracyClass);

    dsfRegDate:
      Result := CompareDate(RegDate, B.RegDate);
  end;
end;

procedure TDevicePoint.Assign(ASource: TDevicePoint);
begin
  if ASource = nil then
    Exit;

  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}

  State  := ASource.State;

  {====================================================================}
  { ОБЩАЯ ИНФОРМАЦИЯ }
  {====================================================================}
  Name := ASource.Name;
  Description := ASource.Description;
  Num := ASource.Num;

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
end;

procedure TPointSpillage.Assign(ASource: TPointSpillage);
begin
  if ASource = nil then
    Exit;

  {====================================================================}
  { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
  {====================================================================}

  DeviceTypePointID := ASource.DeviceTypePointID;

  {====================================================================}
  { ОБЩАЯ ИНФОРМАЦИЯ }
  {====================================================================}
  Name := ASource.Name;
  Description := ASource.Description;
  DateTime := ASource.DateTime;
  OperatorName := ASource.OperatorName;
  EtalonName := ASource.EtalonName;
  Num := ASource.Num;

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

  StdIdx := GetNextPointStdIndex(Points.Count);
  Result.FlowRate := StdPointRates[StdIdx];

  Points.Add(Result);
end;

function TDevice.AddSpillage: TPointSpillage;
 begin

 end;

procedure TDevice.AttachType(AType: TDeviceType; RepoName: String);
begin
  FDeviceType := AType;

  // синхронизируем данные устройства
  DeviceTypeUUID := AType.MitUUID;
  DeviceTypeName := AType.Name;
  DeviceTypeRepo := RepoName;

end;

procedure TDevice.FillFromType(AType: TDeviceType);
var
  TD: TDiameter;
  TP: TTypePoint;
  DP: TDevicePoint;

  Qmax, Q, V, Tm, Coef: Double;
begin
  if AType = nil then
    Exit;

  {====================================================}
  { 1. Основные параметры }
  {====================================================}
  Manufacturer      := AType.Manufacturer;
  AccuracyClass     := AType.AccuracyClass;
  ReestrNumber      := AType.ReestrNumber;
  Category          := AType.Category;
  CategoryName      := AType.CategoryName;

  {====================================================}
  { 2. Измерения }
  {====================================================}
  MeasuredDimension := AType.MeasuredDimension;
  OutputType        := AType.OutputType;
  OutputSet         := AType.OutputSet;
  DimensionCoef     := AType.DimensionCoef;

  {====================================================}
  { 3. Сигналы }
  {====================================================}
  Freq              := AType.Freq;
  FreqFlowRate      := AType.FreqFlowRate;
  Coef              := AType.Coef;

  VoltageRange      := AType.VoltageRange;
  VoltageQminRate   := AType.VoltageQminRate;
  VoltageQmaxRate   := AType.VoltageQmaxRate;

  CurrentRange      := AType.CurrentRange;
  CurrentQminRate   := AType.CurrentQminRate;
  CurrentQmaxRate   := AType.CurrentQmaxRate;

  IntegrationTime   := AType.IntegrationTime;

  {====================================================}
  { 4. Прочее }
  {====================================================}
  VerificationMethod := AType.VerificationMethod;
  ProcedureName     := AType.ProcedureName;
  ReportingForm     := AType.ReportingForm;
  Documentation     := AType.Documentation;

   {====================================================}
  { 5. Поиск диаметра типа по DN прибора }
  {====================================================}
  TD := nil;

  // 1️⃣ Пытаемся найти совпадение по DN / Name
  for var D in AType.Diameters do
    if SameText(D.DN, DN) or SameText(D.Name, DN) then
    begin
      TD := D;
      Break;
    end;

  // 2️⃣ Если не найден — берём первый диаметр
  if (TD = nil) and (AType.Diameters.Count > 0) then
    TD := AType.Diameters[0];

  // 3️⃣ Если диаметров нет вообще — выходим
  if TD = nil then
    Exit;


  {====================================================}
  { 6. Назначаем параметры диаметра }
  {====================================================}
  Qmax := TD.Qmax;
  Qmin := TD.Qmin;

  Self.Qmax := TD.Qmax;
  Self.Qmin := TD.Qmin;
  Self.RangeDynamic := TD.Qmax / Max(TD.Qmin, 1e-6);
  Self.Freq := Round(TD.QFmax);


  Coef := TD.Kp;

  {====================================================}
  { 7. Пересоздаём точки прибора }
  {====================================================}
  Points.Clear;

  for TP in AType.Points do
  begin
    DP := Self.AddPoint;

    {--- базовые поля ---}
    DP.Name           := TP.Name;
    DP.Description    := TP.Description;
    DP.Pressure       := TP.Pressure;
    DP.Temp           := TP.Temp;
    DP.FlowAccuracy   := TP.FlowAccuracy;
    DP.Error          := TP.Error;
    DP.Pause          := TP.Pause;
    DP.Repeats        := TP.Repeats;
    DP.RepeatsProtocol:= TP.RepeatsProtocol;

    {--- расчёт расхода ---}
    Q := TP.FlowRate * Qmax;
    DP.FlowRate := Q;

    {--- расчёт по времени / импульсам ---}
    if (Q > 0) and (TP.LimitTime > 0) then
    begin
      Tm := TP.LimitTime;
      V  := Q * Tm / 3.6;

      DP.LimitTime   := Tm;
      DP.LimitVolume := V;
      DP.LimitImp    := Round(V * Coef);
    end
    else
    begin
      DP.LimitTime   := TP.LimitTime;
      DP.LimitVolume := TP.LimitVolume;
      DP.LimitImp    := TP.LimitImp;
    end;
  end;
end;



end.
