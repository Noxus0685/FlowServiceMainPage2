unit UnitClasses;



interface
uses
    System.Generics.Defaults, System.DateUtils,
    System.Generics.Collections,    System.StrUtils,    UnitBaseProcedures,
  System.SysUtils;
const
  DEFAULT_TYPE_CERT_YEARS = 5;

  StdDN: array[0..24] of Integer = (
    2, 4, 6, 8, 10,
    15, 20, 25, 32, 40,
    50, 65, 80, 100, 125,
    150, 200, 250, 300, 400,
    500, 600, 800, 1000, 1200
  );

  StdPointRates: array[0..4] of Double =
    (0.0125, 0.025, 0.25, 0.5, 1.0);

  BaudRates: array[0..4] of Integer = (
    2400,
    4800,
    9600,
    19200,
    115200);

type



    TDeviceTypeSortField = (
    sfName,
    sfCategory,
    sfManufacturer,
    sfModification,
    sfAccuracyClass,
    sfReestrNumber,
    sfProcedure,
    sfVerificationMethod,
    sfIVI,
    sfRegDate,
    sfValidityDate
  );

  TMeasuredDimension = (
    mdUnknown        = -1,

    mdVolumeFlow     = 0, // Объемный расход (м3/ч)
    mdMassFlow       = 1, // Массовый расход (т/ч, кг/ч)

    mdVolume         = 2, // Объем (л, м3)
    mdMass           = 3, // Масса (кг, т)

    mdSpeed          = 4, // Скорость (м/с)
    mdHeat           = 5  // Теплота (Гкал, МДж)
  );

  TOutputType = (
    otUnknown   = -1,
    otFrequency = 0,
    otImpulse   = 1,
    otVoltage   = 2,
    otCurrent   = 3,
    otInterface = 4,
    otVisual    = 5
  );


 // Классы!


  TTypeEntity = class(TInterfacedObject, IHasID)
  protected
    FID: Integer;
    FState: TObjectState;
    FName: string;
    FMitUUID: string;
    FDescription: string;         // Описание / примечания
    FRepoName: string;

  public

    constructor Create; virtual;

    function GetID: Integer;

    property ID: Integer read FID write FID;
    property State: TObjectState read FState write FState;
    property Name: string read FName write FName;
    property MitUUID: string read FMitUUID write FMitUUID;
    property Description: string read FDescription write FDescription;
     property RepoName: string read FRepoName write FRepoName;
    {====================================================================}
    { ХУКИ ДЛЯ ИНФРАСТРУКТУРЫ }
    {====================================================================}
    function GetSearchText: string; virtual;
    function GetFilterDate: TDate; virtual;
    function CompareTo(const B: TTypeEntity; ASortField: Integer): Integer; virtual;
    //procedure Assign(ASource: TTypeEntity);

  end;

  TDiameter = class (TTypeEntity)
  public
    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}
    DeviceTypeID: Integer;       // Идентификатор типа прибора (FK → TDeviceType.ID)

    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}
    Name: string;                // Наименование диаметра (например: DN50, Ду80)
    DN: string;                  // Условный диаметр (ДУ), строкой
    Description: string;         // Описание / примечания

    {====================================================================}
    { РАСХОДЫ (для расходомеров / счетчиков) }
    {====================================================================}
    Qmax: Double;                // Максимальный расход, м3/ч (или т/ч)
    Qmin: Double;                // Минимальный расход, м3/ч (или т/ч)

    {====================================================================}
    { ИМПУЛЬСНЫЕ / ЧАСТОТНЫЕ ПАРАМЕТРЫ }
    {====================================================================}
    Kp: Double;                  // Базовый коэффициент преобразования (имп/л или имп/кг)
    QFmax: Double;               // Расход, соответствующий максимальной частоте выхода

    {====================================================================}
    { ОБЪЕМ / МАССА (для емкостей и весов) }
    {====================================================================}
    Vmax: Double;                // Максимальный объем / масса, л (кг)
    Vmin: Double;                // Минимальный объем / масса, л (кг)

    constructor Create(ADeviceTypeID : Integer);
    procedure Assign(ASource: TDiameter);

  end;

  TTypePoint = class (TTypeEntity)
  public
    {====================================================================}
    { ИДЕНТИФИКАЦИЯ И СВЯЗИ }
    {====================================================================}


    DeviceTypeID: Integer;       // Идентификатор типа прибора (FK → TDeviceType.ID)

    {====================================================================}
    { ОБЩАЯ ИНФОРМАЦИЯ }
    {====================================================================}



    {====================================================================}
    { ОСНОВНЫЕ ПАРАМЕТРЫ РАСХОДА }
    {====================================================================}
    FlowRate: Double;            // Отношение Q / Qmax (0..1)
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
    { ПОГРЕШНОСТИ }
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

    constructor Create(ADeviceTypeID : Integer);
    procedure Assign(ASource: TTypePoint);

  end;

  TDeviceCategory = class (TTypeEntity)

  public
    {====================================================================}
    { ИДЕНТИФИКАЦИЯ }
    {====================================================================}

    {====================================================================}
    { ОТОБРАЖЕНИЕ И ПОИСК }
    {====================================================================}

    KeyWords: string;                   // Ключевые слова для поиска / фильтрации

    {====================================================================}
    { ПОВЕДЕНИЕ И НАСТРОЙКИ ПО УМОЛЧАНИЮ }
    {====================================================================}
    MeasuredDimension: TMeasuredDimension; // Измеряемая величина по умолчанию
    DefaultOutputType: TOutputType;         // Тип сигнала по умолчанию

    constructor Create;


  //  function DetectCategoryByKeywords(
  //  const Categories: TObjectList<TDeviceCategory>;
 //   const Text: string): Integer;

 //   function CategoryToText(ACategoryID: Integer): string;

  end;

  TDeviceType = class (TTypeEntity)
  private
      FDiameters  : TObjectList<TDiameter>;
      FPoints     : TObjectList<TTypePoint>;
  public
    {====================================================================}
    { ПОЛЯ БД!!!  }
    {====================================================================}

    {====================================================================}
    { НАИМЕНОВАНИЕ И КЛАССИФИКАЦИЯ }
    {====================================================================}

    Modification: string;        // Модификация (полное имя для АРШИН)
    Manufacturer: string;        // Изготовитель
    ReestrNumber: string;        // Номер в ГРСИ

    Category: Integer;           // Категория СИ (код)
    CategoryName: string;        // Категория СИ (отображение)

    AccuracyClass: string;       // Класс точности

    {====================================================================}
    { СРОКИ И РЕГЛАМЕНТ }
    {====================================================================}
    RegDate: TDate;              // Дата регистрации типа
    ValidityDate: TDate;         // Дата окончания действия

    IVI: Integer;                // Межповерочный интервал, лет
    RangeDynamic: Double;        // Динамический диапазон (Qmax / Qmin)

    {====================================================================}
    { ПРОЦЕДУРЫ И МЕТОДИКИ }
    {====================================================================}
    VerificationMethod: string;  // Методика поверки
    ProcedureName: string;       // Тип процедуры (Поверка, Калибровка и т.п.)

    {====================================================================}
    { КОМАНДЫ / ПОДГОТОВКА ПРИБОРА }
    {====================================================================}
    ProcedureCmd1: string;       // Команда подготовки №1
    ProcedureCmd2: string;       // Команда подготовки №2
    ProcedureCmd3: string;       // Команда подготовки №3
    ProcedureCmd4: string;       // Команда подготовки №4
    ProcedureCmd5: string;       // Команда подготовки №5

    {====================================================================}
    { ОПИСАНИЕ И ДОКУМЕНТАЦИЯ }
    {====================================================================}

    Documentation: string;       // Документация / ссылки
    ReportingForm: string;       // Отчетная форма
    SerialNumTemplate: string;   // Шаблон серийного номера

    {====================================================================}
    { ИЗМЕРЕНИЯ И СИГНАЛЫ (ОБЩЕЕ) }
    {====================================================================}
    MeasuredDimension: Integer;  // Измеряемая величина (объем / масса)
    OutputType: Integer;         // Тип выходного сигнала

    DimensionCoef: Integer;      // Представление коэффициента (имп/л, л/имп)

    {====================================================================}
    { ИМПУЛЬСНЫЙ / ЧАСТОТНЫЙ ВЫХОД }
    {====================================================================}
    OutputSet: Integer;          // Тип выхода (Auto / Passive / Active / Namur)
    Freq: Integer;               // Максимальная частота, Гц
    Coef: Double;                // Коэффициент преобразования
    FreqFlowRate: Double;        // Отношение расхода к частоте

    {====================================================================}
    { НАПРЯЖЕНИЕ }
    {====================================================================}
    VoltageRange: Integer;       // Диапазон напряжения
    VoltageQminRate: Double;     // Доля Qmax для минимального напряжения
    VoltageQmaxRate: Double;     // Доля Qmax для максимального напряжения

    {====================================================================}
    { ТОК }
    {====================================================================}
    CurrentRange: Integer;       // Диапазон тока
    CurrentQminRate: Double;     // Доля Qmax для минимального тока
    CurrentQmaxRate: Double;     // Доля Qmax для максимального тока
    IntegrationTime: Integer;    // Время усреднения, сек

    {====================================================================}
    { ИНТЕРФЕЙС СВЯЗИ }
    {====================================================================}
    ProtocolName: string;        // Протокол обмена
    BaudRate: Integer;           // Скорость связи
    Parity: Integer;             // Четность
    DeviceAddress: Integer;      // Адрес устройства

    {====================================================================}
    { ВИЗУАЛЬНЫЙ ВВОД }
    {====================================================================}
    InputType: Integer;          // Тип ввода (ручной / фотофиксация)

    {====================================================================}
    { АЛГОРИТМЫ И ИСПЫТАНИЯ }
    {====================================================================}
    SpillageType: Integer;       // Тип испытаний
    SpillageStop: Integer;       // Критерий остановки
    Repeats: Integer;            // Кол-во повторов
    RepeatsProtocol: Integer;    // Кол-во измерений в протоколе

    {====================================================================}
    { РЕЗУЛЬТАТЫ / ДОПУСТИМЫЕ ОШИБКИ }
    {====================================================================}
    Error: Double;               // Допустимая погрешность

    public

    SelectedDiameterID : Integer;

    constructor Create;
    destructor Destroy; override;

    procedure Assign(ASource: TDeviceType);
    function Clone: TDeviceType;
    function GetSearchText: string; override;

    function CompareTo(const B: TDeviceType; ASortField: TDeviceTypeSortField): Integer;

    procedure AddDiameterData(const ADN: string; AQmax, AQmin, AKp: Double  );
    function  CopyDiameter(SrcIndex: Integer): TDiameter;
    procedure GetNextStdDN(const ADN: string; out NextDNStr: string; out NextDNmm: Integer);

    class function CalcQmaxByDiameter(
      const OldQmax: Double;
      const OldDN, NewDN: Integer
    ): Double; static;

    class function CalcKpByDiameter(
      const OldKp: Double;
      const OldDN, NewDN: Integer
    ): Double; static;

    procedure AddPointData(const AName, ADesc: string; AFlowRate: Double;
    const AAccuracy: string; ALimitTime, APause: Integer );


  function AddDiameter: TDiameter;
  function AddTypePoint: TTypePoint;

    function GetID: Integer;
    function FindDiameterByDN(const ADN: string): TDiameter;

    property  Diameters  : TObjectList<TDiameter> read FDiameters write FDiameters;
    property  Points     : TObjectList<TTypePoint> read  FPoints write  FPoints;



  end;

  TEntitySorter<T: class> = class
  public
    class function Sort(
      const Source: TObjectList<T>;
      ASortField: Integer;
      AAscending: Boolean
    ): TObjectList<T>;
  end;
  TEntityFilters<T: class> = class
  public
    class function ApplyTextFilter(
      const Source: TObjectList<T>;
      const AText: string
    ): TObjectList<T>;

    class function ApplyDateFilter(
      const Source: TObjectList<T>;
      ADate: TDate;
      AEnabled: Boolean
    ): TObjectList<T>;
  end;
  TEntityHelpers<T: TTypeEntity> = class
  public
    class function NextID(
      const List: TObjectList<T>
    ): Integer; static;
  end;


  function SortDeviceTypes(const Source: TObjectList<TDeviceType>; ASortField: TDeviceTypeSortField;   ASortAscending: Boolean): TObjectList<TDeviceType>;
  function GetNextPointStdIndex(Count: Integer): Integer;


implementation

 constructor TTypeEntity.Create;
begin
  inherited Create;
  FID := 0;
  FState := osNew;
  FMitUUID := TGUID.NewGuid.ToString;
end;

class function TEntitySorter<T>.Sort(
  const Source: TObjectList<T>;
  ASortField: Integer;
  AAscending: Boolean
): TObjectList<T>;
begin
  Result := TObjectList<T>.Create(False);

  if Source = nil then
    Exit;

  Result.AddRange(Source);

  Result.Sort(
    TComparer<T>.Construct(
      function(const L, R: T): Integer
      var
        E1, E2: TTypeEntity;
        Cmp: Integer;
      begin
        if not (TObject(L) is TTypeEntity) or
           not (TObject(R) is TTypeEntity) then
          Exit(0);

        E1 := TTypeEntity(TObject(L));
        E2 := TTypeEntity(TObject(R));

        Cmp := E1.CompareTo(E2, ASortField);

        if AAscending then
          Result := Cmp
        else
          Result := -Cmp;
      end
    )
  );
end;



function TTypeEntity.GetID: Integer;
begin
  Result := FID;
end;

function TTypeEntity.GetSearchText: string;
begin
  Result := Name;
end;

function TDeviceType.GetSearchText: string;
var
  B: TStringBuilder;
  D: TDiameter;
  P: TTypePoint;
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
    Add(MitUUID);
    Add(Description);
    Add(RepoName);

    Add(Modification);
    Add(Manufacturer);
    Add(ReestrNumber);
    Add(IntToStr(Category));
    Add(CategoryName);
    Add(AccuracyClass);
    Add(DateToStr(RegDate));
    Add(DateToStr(ValidityDate));
    Add(IntToStr(IVI));
    Add(FloatToStr(RangeDynamic));
    Add(VerificationMethod);
    Add(ProcedureName);
    Add(ProcedureCmd1);
    Add(ProcedureCmd2);
    Add(ProcedureCmd3);
    Add(ProcedureCmd4);
    Add(ProcedureCmd5);
    Add(Documentation);
    Add(ReportingForm);
    Add(SerialNumTemplate);
    Add(IntToStr(MeasuredDimension));
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
    Add(FloatToStr(Error));

    for D in FDiameters do
    begin
      Add(IntToStr(D.ID));
      Add(IntToStr(D.DeviceTypeID));
      Add(D.Name);
      Add(D.DN);
      Add(D.Description);
      Add(FloatToStr(D.Qmax));
      Add(FloatToStr(D.Qmin));
      Add(FloatToStr(D.Kp));
      Add(FloatToStr(D.QFmax));
      Add(FloatToStr(D.Vmax));
      Add(FloatToStr(D.Vmin));
    end;

    for P in FPoints do
    begin
      Add(IntToStr(P.ID));
      Add(IntToStr(P.DeviceTypeID));
      Add(P.Name);
      Add(P.Description);
      Add(FloatToStr(P.FlowRate));
      Add(P.FlowAccuracy);
      Add(FloatToStr(P.Pressure));
      Add(FloatToStr(P.Temp));
      Add(P.TempAccuracy);
      Add(IntToStr(P.LimitImp));
      Add(FloatToStr(P.LimitVolume));
      Add(FloatToStr(P.LimitTime));
      Add(FloatToStr(P.Error));
      Add(IntToStr(P.Pause));
      Add(IntToStr(P.RepeatsProtocol));
      Add(IntToStr(P.Repeats));
    end;

    Result := Trim(B.ToString);
  finally
    B.Free;
  end;
end;

function TTypeEntity.GetFilterDate: TDate;
begin
  Result := 0; // по умолчанию фильтр не проходит
end;

function TTypeEntity.CompareTo(
  const B: TTypeEntity;
  ASortField: Integer
): Integer;
begin
  // дефолтная сортировка — по имени
  Result := CompareText(Name, B.Name);
end;





constructor TDeviceCategory.Create;
begin
  inherited Create;

  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}
  State := osNew;

  {====================================================================}
  { Идентификация }
  {====================================================================}
  ID := 0;

  {====================================================================}
  { Основные данные }
  {====================================================================}
  Name := '';
  KeyWords := '';

  MeasuredDimension := mdUnknown;
  DefaultOutputType := otUnknown;
end;


constructor TDiameter.Create(ADeviceTypeID : Integer);
begin
  inherited Create;

  {====================================================================}
  { СОСТОЯНИЕ }
  {====================================================================}

  {====================================================================}
  { Идентификация и связь с типом }
  {====================================================================}
  DeviceTypeID := ADeviceTypeID;
  {====================================================================}
  { Общая информация }
  {====================================================================}
  Name := '';
  DN := '';
  Description := '';

  {====================================================================}
  { Расходы }
  {====================================================================}
  Qmax := 0.0;
  Qmin := 0.0;

  {====================================================================}
  { Импульсные / частотные параметры }
  {====================================================================}
  Kp := 0.0;
  QFmax := 0.0;

  {====================================================================}
  { Объем / масса }
  {====================================================================}
  Vmax := 0.0;
  Vmin := 0.0;
end;

procedure TDiameter.Assign(ASource: TDiameter);
begin
  if ASource = nil then
    Exit;

  {----------------------------------}
  { Идентификация и связи }
  {----------------------------------}
  ID := ASource.ID;
  DeviceTypeID := ASource.DeviceTypeID;

  {----------------------------------}
  { Общая информация }
  {----------------------------------}
  Name := ASource.Name;
  DN := ASource.DN;
  Description := ASource.Description;

  {----------------------------------}
  { Расходы }
  {----------------------------------}
  Qmax := ASource.Qmax;
  Qmin := ASource.Qmin;

  {----------------------------------}
  { Импульсные / частотные параметры }
  {----------------------------------}
  Kp := ASource.Kp;
  QFmax := ASource.QFmax;

  {----------------------------------}
  { Объем / масса }
  {----------------------------------}
  Vmax := ASource.Vmax;
  Vmin := ASource.Vmin;

  {----------------------------------}
  { Состояние }
  {----------------------------------}
  State := ASource.State;
end;

constructor TTypePoint.Create(ADeviceTypeID : Integer);
begin
  inherited Create;

  {====================================================================}
  { Идентификация и связи }
  {====================================================================}
  DeviceTypeID := ADeviceTypeID;

  {====================================================================}
  { Общая информация }
  {====================================================================}
  Name := 'Новый шабло поверочной точки';
  Description := '';

  {====================================================================}
  { Основные параметры расхода }
  {====================================================================}
  FlowRate := 0.0;
  FlowAccuracy := '';

  {====================================================================}
  { Условия измерения }
  {====================================================================}
  Pressure := 0.0;
  Temp := 0.0;
  TempAccuracy := '';

  {====================================================================}
  { Ограничения измерения }
  {====================================================================}
  LimitImp := 0;
  LimitVolume := 0.0;
  LimitTime := 0.0;

  {====================================================================}
  { Погрешности }
  {====================================================================}
  Error := 0.0;

  {====================================================================}
  { Дополнительные параметры }
  {====================================================================}
  Pause := 0;

  {====================================================================}
  { Повторы и серии }
  {====================================================================}
  RepeatsProtocol := 0;
  Repeats := 0;
end;

procedure   TTypePoint.Assign(ASource: TTypePoint);
begin
  if ASource = nil then
    Exit;

  {----------------------------------}
  { Состояние }
  {----------------------------------}
  State := ASource.State;

  {----------------------------------}
  { Идентификация и связи }
  {----------------------------------}
  ID := ASource.ID;
  DeviceTypeID := ASource.DeviceTypeID;

  {----------------------------------}
  { Общая информация }
  {----------------------------------}
  Name := ASource.Name;
  Description := ASource.Description;

  {----------------------------------}
  { Основные параметры расхода }
  {----------------------------------}
  FlowRate := ASource.FlowRate;
  FlowAccuracy := ASource.FlowAccuracy;

  {----------------------------------}
  { Условия измерения }
  {----------------------------------}
  Pressure := ASource.Pressure;
  Temp := ASource.Temp;
  TempAccuracy := ASource.TempAccuracy;

  {----------------------------------}
  { Ограничения измерения }
  {----------------------------------}
  LimitImp := ASource.LimitImp;
  LimitVolume := ASource.LimitVolume;
  LimitTime := ASource.LimitTime;

  {----------------------------------}
  { Погрешности }
  {----------------------------------}
  Error := ASource.Error;

  {----------------------------------}
  { Дополнительные параметры }
  {----------------------------------}
  Pause := ASource.Pause;

  {----------------------------------}
  { Повторы и серии }
  {----------------------------------}
  RepeatsProtocol := ASource.RepeatsProtocol;
  Repeats := ASource.Repeats;
end;

constructor TDeviceType.Create;
begin
  inherited Create;

      FDiameters := TObjectList<TDiameter>.Create(True);
      FPoints    := TObjectList<TTypePoint>.Create(True);

  {====================================================================}
  { Наименование и классификация }
  {====================================================================}
  Name := 'Новый тип';
  Modification := '';
  Manufacturer := '';
  ReestrNumber := '';

  Category := -1;
  CategoryName := '';
  AccuracyClass := '';

  {====================================================================}
  { Сроки и регламент }
  {====================================================================}
  RegDate := 0;
  ValidityDate := 0;

  IVI := 0;
  RangeDynamic := 0.0;

  {====================================================================}
  { Процедуры и методики }
  {====================================================================}
  VerificationMethod := '';
  ProcedureName := '';

  {====================================================================}
  { Команды подготовки прибора }
  {====================================================================}
  ProcedureCmd1 := '';
  ProcedureCmd2 := '';
  ProcedureCmd3 := '';
  ProcedureCmd4 := '';
  ProcedureCmd5 := '';

  {====================================================================}
  { Описание и документация }
  {====================================================================}
  Description := '';
  Documentation := '';
  ReportingForm := '';
  SerialNumTemplate := '';

  {====================================================================}
  { Измерения и сигналы (общее) }
  {====================================================================}
  MeasuredDimension := 0;   // если enum — лучше явное значение
  OutputType := 0;
  DimensionCoef := 0;

  {====================================================================}
  { Импульсный / частотный выход }
  {====================================================================}
  OutputSet := 0;
  Freq := 0;
  Coef := 0.0;
  FreqFlowRate := 0.0;

  {====================================================================}
  { Напряжение }
  {====================================================================}
  VoltageRange := 0;
  VoltageQminRate := 0.0;
  VoltageQmaxRate := 0.0;

  {====================================================================}
  { Ток }
  {====================================================================}
  CurrentRange := 0;
  CurrentQminRate := 0.0;
  CurrentQmaxRate := 0.0;
  IntegrationTime := 0;

  {====================================================================}
  { Интерфейс связи }
  {====================================================================}
  ProtocolName := '';
  BaudRate := 9600;       // разумный дефолт
  Parity := 0;            // без чётности
  DeviceAddress := 1;     // типичный адрес

  {====================================================================}
  { Визуальный ввод }
  {====================================================================}
  InputType := 0;

  {====================================================================}
  { Алгоритмы и испытания }
  {====================================================================}
  SpillageType := 0;
  SpillageStop := 0;
  Repeats := 0;
  RepeatsProtocol := 0;

  {====================================================================}
  { Погрешности }
  {====================================================================}
  Error := 0.0;
end;

destructor TDeviceType.Destroy;
begin
  FreeAndNil(FDiameters);
  FreeAndNil(FPoints);
  inherited;
end;

function TDeviceType.GetID: Integer;
begin
  Result := FID;
end;

function TDeviceType.CompareTo(
  const B: TDeviceType;
  ASortField: TDeviceTypeSortField
): Integer;
begin
  Result := 0;

  if B = nil then
    Exit;

  case ASortField of
    sfName:
      Result := CompareText(Name, B.Name);

    sfCategory:
      Result := CompareText(CategoryName, B.CategoryName);

    sfManufacturer:
      Result := CompareText(Manufacturer, B.Manufacturer);

    sfModification:
      Result := CompareText(Modification, B.Modification);

    sfAccuracyClass:
      Result := CompareText(AccuracyClass, B.AccuracyClass);

    sfReestrNumber:
      Result := CompareText(ReestrNumber, B.ReestrNumber);

    sfProcedure:
      Result := CompareText(ProcedureName, B.ProcedureName);

    sfVerificationMethod:
      Result := CompareText(VerificationMethod, B.VerificationMethod);

    sfIVI:
      Result := IVI - B.IVI;

    sfRegDate:
      Result := CompareDateTime(RegDate, B.RegDate);

    sfValidityDate:
      Result := CompareDateTime(ValidityDate, B.ValidityDate);
  end;
end;

function SortDeviceTypes(
  const Source: TObjectList<TDeviceType>;
  ASortField: TDeviceTypeSortField;
  ASortAscending: Boolean
): TObjectList<TDeviceType>;
var
  I, J: Integer;
  Tmp: TDeviceType;
  Cmp: Integer;
begin
  Result := TObjectList<TDeviceType>.Create(False); // ссылки, не владеем

  if Source = nil then
    Exit;

  // Копируем исходный список
  for Tmp in Source do
    Result.Add(Tmp);

  if Result.Count < 2 then
    Exit;

  // Сортировка (твоя логика, без изменений)
  for I := 0 to Result.Count - 2 do
    for J := I + 1 to Result.Count - 1 do
    begin
      Cmp := Result[I].CompareTo(Result[J], ASortField);

      if not ASortAscending then
        Cmp := -Cmp;

      if Cmp > 0 then
      begin
        Tmp := Result[I];
        Result[I] := Result[J];
        Result[J] := Tmp;
      end;
    end;
end;


class function TEntityFilters<T>.ApplyTextFilter(
  const Source: TObjectList<T>;
  const AText: string
): TObjectList<T>;
var
  E: T;
  Ent: TTypeEntity;
  Find, S: string;
begin
  Result := TObjectList<T>.Create(False);

  if (Source = nil) or (Trim(AText) = '') then
  begin
    if Source <> nil then
      Result.AddRange(Source);
    Exit;
  end;

  Find := UpperCase(Trim(AText));

  for E in Source do
  begin
    if not (TObject(E) is TTypeEntity) then
      Continue;

    Ent := TTypeEntity(TObject(E));
    S := UpperCase(Ent.GetSearchText);

    if (ContainsText(S, Find) ) then
      Result.Add(E);
  end;
end;


class function TEntityFilters<T>.ApplyDateFilter(
  const Source: TObjectList<T>;
  ADate: TDate;
  AEnabled: Boolean
): TObjectList<T>;
var
  E: T;
  Ent: TTypeEntity;
begin
  Result := TObjectList<T>.Create(False);

  if (Source = nil) or not AEnabled then
  begin
    if Source <> nil then
      Result.AddRange(Source);
    Exit;
  end;

  for E in Source do
  begin
    if not (TObject(E) is TTypeEntity) then
      Continue;

    Ent := TTypeEntity(TObject(E));
    if Ent.GetFilterDate >= ADate then
      Result.Add(E);
  end;
end;

  class function TEntityHelpers<T>.NextID(
  const List: TObjectList<T>
): Integer;
var
  E: T;
  MaxID: Integer;
begin
  MaxID := 0;

  if List <> nil then
    for E in List do
      if E.ID > MaxID then
        MaxID := E.ID;

  Result := MaxID + 1;
end;




function CalcQmaxByDiameter(
  const OldQmax: Double;
  const OldDN, NewDN: Integer
): Double;
begin
  if (OldQmax <= 0) or (OldDN <= 0) or (NewDN <= 0) then
    Exit(OldQmax);

  Result := OldQmax * Sqr(NewDN / OldDN);
end;

function CalcKpByDiameter(
  const OldKp: Double;
  const OldDN, NewDN: Integer
): Double;
begin
  if (OldKp <= 0) or (OldDN <= 0) or (NewDN <= 0) then
    Exit(OldKp);

  Result := OldKp * Sqr(OldDN / NewDN); // ∝ 1 / D²
end;

function TDeviceType.AddDiameter: TDiameter;
var
  NewDNmm: Integer;
begin
  if Diameters = nil then
    Diameters := TObjectList<TDiameter>.Create(True);

  Result := TDiameter.Create(ID);
  Result.ID := TEntityHelpers<TDiameter>.NextID(Diameters);
  Diameters.Add(Result);

  NewDNmm := StdDN[0];
  Result.DN   := NewDNmm.ToString;
  Result.Name := 'DN' + Result.DN;

end;

function TDeviceType.CopyDiameter(SrcIndex: Integer): TDiameter;
var
  Src: TDiameter;
  OldDNmm, NewDNmm: Integer;
  NextDNStr: string;
begin
  {--------------------------------------------------}
  { 1. Всегда создаём новый диаметр через AddDiameter }
  {--------------------------------------------------}
  Result := AddDiameter;

  {--------------------------------------------------}
  { 2. Если нет исходного — первый стандартный DN }
  {--------------------------------------------------}
  if (Diameters.Count <= 1) or
     (SrcIndex < 0) or
     (SrcIndex >= Diameters.Count - 1) then
  begin
    Exit;
  end;

  {--------------------------------------------------}
  { 3. Копирование + перерасчёт }
  {--------------------------------------------------}
  Src := Diameters[SrcIndex];

  Result.Assign(Src);

  OldDNmm := StrToIntDef(Src.DN, 0);

  GetNextStdDN(Src.DN, NextDNStr, NewDNmm);

  Result.DN   := NextDNStr;
  Result.Name := 'DN' + NextDNStr;

  {--- Qmax ∝ D² ---}
  Result.Qmax := CalcQmaxByDiameter(
    Src.Qmax,
    OldDNmm,
    NewDNmm
  );

  {--- QFmax = Qmax ---}
  Result.QFmax := Result.Qmax;

  {--- Qmin из динамического диапазона ---}
  if RangeDynamic > 0 then
    Result.Qmin := Result.Qmax / RangeDynamic
  else
    Result.Qmin := 0;

  {--- Kp ∝ 1 / D² ---}
  Result.Kp := CalcKpByDiameter(
    Src.Kp,
    OldDNmm,
    NewDNmm
  );
end;

procedure TDeviceType.AddDiameterData(
    const ADN: string;
    AQmax, AQmin, AKp: Double
  );
  var
   D: TDiameter;
  begin

    D:=AddDiameter;
 //   D.ID := GenerateDiameterID;
    D.Name := 'DN' + ADN;
    D.DN := ADN;
    D.Qmax := AQmax;
    D.Qmin := AQmin;
    D.Kp := AKp;
    D.QFmax := AQmax;
  end;

procedure TDeviceType.GetNextStdDN(
  const ADN: string;
  out NextDNStr: string;
  out NextDNmm: Integer
);
var
  CurDN, I: Integer;
begin
  NextDNStr := ADN;
  NextDNmm  := StrToIntDef(ADN, 0);

  CurDN := StrToIntDef(ADN, -1);
  if CurDN < 0 then Exit;

  for I := Low(StdDN) to High(StdDN) do
    if StdDN[I] = CurDN then
    begin
      if I < High(StdDN) then
        CurDN := StdDN[I + 1];

      NextDNStr := CurDN.ToString;
      NextDNmm  := CurDN;
      Exit;
    end;
end;

function TDeviceType.FindDiameterByDN(const ADN: string): TDiameter;
var
  I: Integer;
  S: string;
begin
  Result := nil;

  if FDiameters = nil then
    Exit;

  S := Trim(ADN);
  if S = '' then
    Exit;

  for I := 0 to FDiameters.Count - 1 do
  begin
    if FDiameters[I] = nil then
      Continue;

    if FDiameters[I].State = osDeleted then
      Continue;

    if SameText(Trim(FDiameters[I].Name), S) then
    begin
      Result := FDiameters[I];
      Exit;
    end;
  end;
end;



function GetNextPointStdIndex(Count: Integer): Integer;
var
  StdCount: Integer;
begin
  StdCount := Length(StdPointRates);

  if StdCount = 0 then
    Exit(0);

  // следующая стандартная точка по количеству уже добавленных
  Result := Count mod StdCount;
end;

function TDeviceType.AddTypePoint: TTypePoint;
var
StdIdx : Integer;
begin
  if Points = nil then
    Points := TObjectList<TTypePoint>.Create(True);

  Result := TTypePoint.Create(ID);
  Result.ID :=  TEntityHelpers<TTypePoint>.NextID(Points);

  StdIdx := GetNextPointStdIndex(Points.Count);
  Result.FlowRate := StdPointRates[StdIdx];

  Points.Add(Result);
end;

procedure TDeviceType.AddPointData(const AName, ADesc: string; AFlowRate: Double;
    const AAccuracy: string; ALimitTime, APause: Integer );
  var
    P: TTypePoint;

  begin

    P := AddTypePoint;
   // P.ID := GenerateTypePointID;
    P.Name := AName;
    P.Description := ADesc;

    P.FlowRate := AFlowRate;
    P.FlowAccuracy := AAccuracy;

    P.Pressure := 0;
    P.Temp := 20;
    P.TempAccuracy := '0';

    P.LimitImp := 0;
    P.LimitVolume := 0;
    P.LimitTime := ALimitTime;

    P.Error := 0;
    P.Pause := APause;

    P.RepeatsProtocol := 3;
    P.Repeats := 5;
  end;


  class function TDeviceType.CalcQmaxByDiameter(
  const OldQmax: Double;
  const OldDN, NewDN: Integer
): Double;
begin
  if (OldQmax <= 0) or (OldDN <= 0) or (NewDN <= 0) then
    Exit(OldQmax);

  Result := OldQmax * Sqr(NewDN / OldDN);
end;

class function TDeviceType.CalcKpByDiameter(
  const OldKp: Double;
  const OldDN, NewDN: Integer
): Double;
begin
  if (OldKp <= 0) or (OldDN <= 0) or (NewDN <= 0) then
    Exit(OldKp);

  Result := OldKp * Sqr(OldDN / NewDN); // ∝ 1 / D²
end;


function TDeviceType.Clone: TDeviceType;
begin
  Result := TDeviceType.Create;
   Result.ID := ID;
   Result.MitUUID := MitUUID;
  Result.Assign(Self);

end;


procedure TDeviceType.Assign(ASource: TDeviceType);
var
  D, NewD: TDiameter;
  P, NewP: TTypePoint;
begin
  if ASource = nil then
    Exit;

  {====================================================================}
  { Идентификация }
  {====================================================================}


  {====================================================================}
  { Наименование и классификация }
  {====================================================================}
  Name := ASource.Name;
  Modification := ASource.Modification;
  Manufacturer := ASource.Manufacturer;
  ReestrNumber := ASource.ReestrNumber;

  Category := ASource.Category;
  CategoryName := ASource.CategoryName;
  AccuracyClass := ASource.AccuracyClass;

  {====================================================================}
  { Сроки и регламент }
  {====================================================================}
  RegDate := ASource.RegDate;
  ValidityDate := ASource.ValidityDate;
  IVI := ASource.IVI;
  RangeDynamic := ASource.RangeDynamic;

  {====================================================================}
  { Процедуры и методики }
  {====================================================================}
  VerificationMethod := ASource.VerificationMethod;
  ProcedureName := ASource.ProcedureName;

  {====================================================================}
  { Команды подготовки прибора }
  {====================================================================}
  ProcedureCmd1 := ASource.ProcedureCmd1;
  ProcedureCmd2 := ASource.ProcedureCmd2;
  ProcedureCmd3 := ASource.ProcedureCmd3;
  ProcedureCmd4 := ASource.ProcedureCmd4;
  ProcedureCmd5 := ASource.ProcedureCmd5;

  {====================================================================}
  { Описание и документация }
  {====================================================================}
  Description := ASource.Description;
  Documentation := ASource.Documentation;
  ReportingForm := ASource.ReportingForm;
  SerialNumTemplate := ASource.SerialNumTemplate;

  {====================================================================}
  { Измерения и сигналы (общее) }
  {====================================================================}
  MeasuredDimension := ASource.MeasuredDimension;
  OutputType := ASource.OutputType;
  DimensionCoef := ASource.DimensionCoef;

  {====================================================================}
  { Импульсный / частотный выход }
  {====================================================================}
  OutputSet := ASource.OutputSet;
  Freq := ASource.Freq;
  Coef := ASource.Coef;
  FreqFlowRate := ASource.FreqFlowRate;

  {====================================================================}
  { Напряжение }
  {====================================================================}
  VoltageRange := ASource.VoltageRange;
  VoltageQminRate := ASource.VoltageQminRate;
  VoltageQmaxRate := ASource.VoltageQmaxRate;

  {====================================================================}
  { Ток }
  {====================================================================}
  CurrentRange := ASource.CurrentRange;
  CurrentQminRate := ASource.CurrentQminRate;
  CurrentQmaxRate := ASource.CurrentQmaxRate;
  IntegrationTime := ASource.IntegrationTime;

  {====================================================================}
  { Интерфейс связи }
  {====================================================================}
  ProtocolName := ASource.ProtocolName;
  BaudRate := ASource.BaudRate;
  Parity := ASource.Parity;
  DeviceAddress := ASource.DeviceAddress;

  {====================================================================}
  { Визуальный ввод }
  {====================================================================}
  InputType := ASource.InputType;

  {====================================================================}
  { Алгоритмы и испытания }
  {====================================================================}
  SpillageType := ASource.SpillageType;
  SpillageStop := ASource.SpillageStop;
  Repeats := ASource.Repeats;
  RepeatsProtocol := ASource.RepeatsProtocol;

  {====================================================================}
  { Погрешности }
  {====================================================================}
  Error := ASource.Error;

  {====================================================================}
  { Состояние }
  {====================================================================}
  State := ASource.State;

  {====================================================================}
  { ГЛУБОКОЕ КОПИРОВАНИЕ ДИАМЕТРОВ }
  {====================================================================}
  FDiameters.Clear;

  for D in ASource.FDiameters do
  begin
    NewD := AddDiameter;   // ← создаём с текущим ID типа
    NewD.Assign(D);
    NewD.DeviceTypeID := ID;
  end;

  {====================================================================}
  { ГЛУБОКОЕ КОПИРОВАНИЕ ШАБЛОНОВ ТОЧЕК }
  {====================================================================}
  FPoints.Clear;

  for P in ASource.FPoints do
  begin
    NewP := AddTypePoint;  // ← создаём с текущим ID типа
    NewP.Assign(P);
    NewP.DeviceTypeID := ID;
  end;
end;


end.
