
(* Возженников,
   ** 12.10.2007: Добавляю модуль температуры для 6ти-канального датчика температур
   ** 22.07.2008: Добавляю модуль для CounterEx, для получения точных частот с нового счетчика
   ** 20.01.2021: Добавлен модуль поддержки контроллеров Агат,Коралл
*)

unit FmxFPDevices;

{ ===== Классы устройств =====
В этом Unit'е описаны все классы устройств, используемые при разработке ПО для управления УПСЖ. Для устройств,
которые на данный момент могут быть подключены только к одному типу модулей, закоментированы поля типа модуля
и строки их инициализации, а также не производится проверка типа модуля при выполнении операций с ним.

Все классы являются потомками класса TFmxDevice.
}

interface

uses
  System.Classes,
  FmxFPDevice,
  FPCustomControl,
  FmxFPModule,
  FmxFPModules,
  FmxModbusTypes,
  FmxHelper,
  FmxFPDeviceManager,
  SYNCOBJS,
  FmxMedianFilter,
  uProcedureOfObject; // 28.09.09 - добавл для реализации функции AddReceiver у модуля TBigScales

  const
  cHSC_CTRL_OpenPosition=97.9;
  cMinValve_IO_PinNumber=0;//Внимание: у задвижек нумерация с 1
  cDefaultDensity=998.6;//Плотность воды при 18 градусах
  var
    //13.07.2010 Саранцев. Что бы задвижки могли знать запущен ли хотя бы один насос
    //флаг показывающий число запущенных насосов
    PumpsOpened:byte = 0;

    //критическая секция для увеличения/уменьшения числа запущенных насосов
    CriticalSection:TCriticalSection;

type
  TFmxDeviceCoilCheckList = class(TFmxDevice)
  private
    FSize: Byte;
    FValue: LongWord;
    FStartAddress: Word;
    FManualValue: LongWord;
    function GetValue: LongWord;
    procedure SetValue(const Value: LongWord);
  public
    constructor CreateOnModule(AModbusTCPHost: string; AModbusTCPPort: word;
      port: integer; address: Byte; BR: Cardinal; InputReg: Word; OutputReg: Word; size: Byte;
      AModuleType: TFmxModuleType; _typeofprotocol: TTypeOfProtocol);
    function ReadCoils: Boolean;
    function WriteCoils: Boolean;
    function UpdateStatus: Boolean;
    property Value: LongWord read GetValue write SetValue;
    property Size: Byte read FSize;
  end;


  TLinearCalibrationSettings = record
    CalibrationCoefficient: Double;
    CalibrationNull: longint;
  end;

  TCalibrationPointsArray=array of TCalibrationPoint;


  TScalesSettings = record
    AtmosphericPressure: Array of Double;
    AmbientTemperature: Array of Double;
    RelativeHumidity: Array of Double;
    DumbbellsDensity: Array of Double;
    CalibrationCoefficients: Array of Double;
    CalibrationNulls: Array of Longword;
    DischargeOscillation: Double;
    EmptyOscillation: Double;
    FullOscillation: Double;
    MaxWeight: Double;
    NonemptyOscillation: Double;
    StabilizationSampleCount: integer;
    StabilizationTime: Word;
    TankWeight: Double;
    WeightsBufferLength: integer;
    Discontinuity: {longword}Word; // 10.07.2008 - дискретность (в милиграммах)
//    CalibrationCoefficient_L2 : Double; // 28.07.2009 - калибровочный коэффициент второго уровня.
    PipeFillingVolume: Double;
    // Калибровочная таблица, используемая для расчета массы. Элементы должны быть отсортированы по
    // возрастанию расхода и не содержать одинаковых значений массы.
    CalibrationTable: array of TCalibrationPoint;
    //Сделаем многоточечную калибровку второго уровня
    // Калибровочная таблица, используемая для расчета массы. Элементы должны быть отсортированы по
    // возрастанию расхода и не содержать одинаковых значений массы.
    CalibrationTable_l2: Array of TCalibrationPoint;
  end;

  TFlowmeterSettings = record
    _CalibrationTable: Array of TCalibrationPoint;
    ImpulseWeight: Double;
    OutlayType:TOutlayType;
  end;

  //Попробуем учитывать силу архимеда всегда и везде
  //Соответственно при взвешивании гирь одна плотность того, что на весы нагружено
  //при обычной работе - другая
  //при калибровке наверное вообще не надо ее никак учитывать

  //Я тут подумал и решил не использовать режим smWorking, а вместо него
  //использовать smCalibration, пусть всегда, кроме поверки используется чистый вес
  //А силу архимеда вычислять непосредственно при взвешивании воды
  TScalesMode = (smCalibration, smChecking, smWorking);

  TFmxDeviceBlcedValve = class(TFmxDevice)

  private
    // 20.05.2009 -- внутренняя переменная для отображения в логе записей для насосов
    FUnoperatedPump : boolean;


    // Номер используемого выхода
    // 0-12 при использовании SuperBIO
    // 0-1 при использовании BIO
    // 6-8 при использовании Valve
    //Для запуска
    FStartOutputNumber: Byte;
    FStartInputNumber: Byte;
    //Для останова
    FStopOutputNumber: Byte;
    FStopInputNumber: Byte;

    FWithInput: boolean;
    FTwoSwitch: Boolean;

    function GetOpened: Boolean;
    procedure SetWithInput(const Value: boolean);
    procedure SetStartInputNumber(const Value: Byte);
    procedure SetStartOutputNumber(const Value: Byte);
    procedure SetTwoSwitch(const Value: Boolean);
    function GetStopInputNumber: Byte;
    function GetStopOutputNumber: Byte;
    procedure SetStopInputNumber(const Value: Byte);
    procedure SetStopOutputNumber(const Value: Byte);
    procedure SetMaxChannels(const Value: byte);override;

  public
    // 20.05.2009 -- свойство для отображения в логе записей для насосов
    property IsUnoperatedPump: boolean read FUnoperatedPump write FUnoperatedPump default false;

    // Флаг открытия сливного клапана.
    property Opened: Boolean read GetOpened;

    property WithInput:boolean read FWithInput write SetWithInput default False;

    // output_number - номер используемого выхода;
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte; BR: Cardinal; output_number: byte; input_number: byte; with_input:boolean; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);


    { ===== Close =====
    Закрывает клапан.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Close: Boolean;

    { ===== Open =====
    Открывает клапан.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Open: Boolean;


    { ===== Stop =====
    Отключает ууправление.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Stop: Boolean;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    property StartOutputNumber: Byte read FStartOutputNumber write SetStartOutputNumber;
    property StartInputNumber: Byte read FStartInputNumber write SetStartInputNumber;
    property StopOutputNumber: Byte read GetStopOutputNumber write SetStopOutputNumber;
    property StopInputNumber: Byte read GetStopInputNumber write SetStopInputNumber;
    property TwoSwitch:Boolean read FTwoSwitch write SetTwoSwitch;
  end;


  {Счетчик поверямого канала}
  TFmxDeviceCounter = class(TFmxDevice)

  private
    //Хранилище для вариантов ручного ввода
    FFrequency:Single;
    FImpulse:Single;
    FInstantTime: integer;
    FActive:boolean;
    FStarted:boolean;
    FChannelNumber: Byte;
    FTypeOfInput: Byte;
    FImpulseWeights: Double;
    FMaxOutlay: Single;
    FMinOutlay: Single;
    FConversionCoefficientType: boolean;
    FAntiShatterFilterTime: integer;
    FAntiShatterFilter: boolean;
    FSynchro: THSC_IMP_TypeOfSynchro;
    FCaption: String;
    // Функции, возвращающие данные из модуля.
    function GetCounterIsActive: Boolean;
    function GetCountIsStarted: Boolean;
    function GetDependentImpulseModeIsActive: Boolean;
    function GetSlowImpulseModeIsActive: Boolean;

    { ===== GetFrequency =====
    Возвращает значение частоты для поверяемого расходомера.
    Принимаемые параметры:
    flowmeter_number - номер поверяемого расходомера (от 0 до 7).
    Возвращает 0 в случае некорректности номера поверяемого расходомера.
    }
    function GetFrequency: Single;

    function GetImpulses: Single;

    //Текущее время
    function GetCurrentTime: Integer;
    { ===== GetVolume =====
    Возвращает пролитый объем в литрах для поверяемого расходомера.
    Принимаемые параметры:
    flowmeter_number - номер поверяемого расходомера (от 0 до 7).
    Возвращает 0 в слечае некорректности номера поверяемого расходомера.
    }
    function GetVolume: Double;

    { ===== GetWaterDischarge =====
    Возвращает значение расхода в м3/ч для поверяемого расходомера.
    Принимаемые параметры:
    flowmeter_number - номер поверяемого расходомера (от 0 до 7).
    Возвращает 0 в слечае некорректности номера поверяемого расходомера.
    }
    function GetWaterDischarge: Double;
    function GetEnable4_7: boolean;
    procedure SetEnable4_7(const Value: boolean);
    procedure SetFrequency(const Value: Single);
    procedure SetImpulses(const Value: Single);
    procedure SetCounterIsActive(const Value: Boolean);
    procedure SetCountIsStarted(const Value: Boolean);
    procedure SetChannelNumber(const Value: Byte);
    function GetBaudrate: longword;
    procedure SetBaudrate(const Value: longword);
    procedure SetTypeOfInput(const Value: Byte);
    procedure SetImpulseWeights(const Value: Double);
    procedure SetMaxOutlay(const Value: Single);
    procedure SetMinOutlay(const Value: Single);
    function GetQuality: TFmxDeviceQuality;
    procedure SetConversionCoefficientType(const Value: boolean);
    procedure SetStarted(const Value: boolean);
    procedure SetAntiShatterFilterTime(const Value: integer);
    procedure SetAntiShatterFilter(const Value: boolean);
    procedure SetSynchro(const Value: THSC_IMP_TypeOfSynchro);
    procedure SetCaption(const Value: String);

  public
    function GetAddr: integer;override;
    procedure SetAddr(const Value: integer);override;
    function GetPort: integer;override;
    procedure SetPort(const Value: integer);override;

    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port: integer; _addr: Byte; BR: Cardinal; Cnl:integer; AModuleType: TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);

    procedure SetupInputs;

    // Флаги активности счетчиков (для режима зависимых импульсов).
    property Active: Boolean read GetCounterIsActive write SetCounterIsActive;

    // Флаг состояния программного старта.
    property CountIsStarted: Boolean read GetCountIsStarted write SetCountIsStarted;

    // Флаг использования режима зависимых импульсов.
    property DependentImpulseModeIsActive: Boolean read GetDependentImpulseModeIsActive;

    // Частоты для каждого из поверяемых расходомеров.
    property Frequencies: Single read GetFrequency write SetFrequency;

    // Количество импульсов для каждого из поверяемых расходомеров.
    property Impulses: Single read GetImpulses write SetImpulses;

    // Флаг использования режима медленных импульсов.
    property SlowImpulseModeIsActive: Boolean read GetSlowImpulseModeIsActive;

    // Пролитые объемы в литрах для каждого из поверяемых расходомеров.
    property Volume: Double read GetVolume;

    //Текущее время
    property CurrentTime: Integer read GetCurrentTime;

    // Расходы в м3/ч для каждого из поверяемых расходомеров.
    //         или тоннах в час
    property Outlay: Double read GetWaterDischarge;

    //Взводит
    function PrepareExternalSynchro():Boolean;

    function StartCountWithoutSynchro: Boolean;

    { ===== SetDependentImpulseMode =====
    Устанавливает состояние режима зависимых импульсов.
    Принимаемые параметры:
    activate - влаг активности режима зависимых импульсов.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function SetDependentImpulseMode(activate: Boolean): Boolean;

    { ===== SetSlowImpulseMode =====
    Устанавливает состояние режима медленных импульсов.
    Принимаемые параметры:
    activate - влаг активности режима медленных импульсов.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function SetSlowImpulseMode(activate: Boolean): Boolean;

    { ===== StartCount =====
    Программный запуск стчета.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function StartCount(): Boolean;

    { ===== StopCount =====
    Программная остановка счета.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом;
    }
    function StopCount: Boolean;

    function Reset:Boolean;

    { ===== SendLock =====
      Посылает блокировку вычислений
    }
    function SendLockAllValues: Boolean;

    { ===== UpdateCommonStatus =====
    Обновляет общий статус счетчиков (флаги запущенных счетчиков, выбранная пара эталонных расходомеров,
    состояния программного старта, режима медленных импульсов и режима зависимых импульсов).
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateCommonStatus: Boolean;

    { ===== UpdateVolumes =====
    Обновляет значения пролитых объемов.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateVolumes: Boolean;

    { ===== UpdateFinalVolumes =====
    Обновляет значения пролитых объемов.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateFinalVolumes: Boolean;

    { ===== UpdateWaterDischarges =====
    Обновляет значения текущих расходов.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateWaterDischarges: Boolean;

    function SetupStartStop(aInterval:integer): Boolean;

    property Enable4_7:boolean read GetEnable4_7 write SetEnable4_7;

    property Addr:integer read GetAddr write SetAddr;

    property PortNumber:integer read GetPort write SetPort;

    property Baudrate:longword read GetBaudrate write SetBaudrate;

    property ExternalSynchro:THSC_IMP_TypeOfSynchro read FSynchro write SetSynchro;

    property ChannelNumber:Byte read FChannelNumber write SetChannelNumber;

    property TypeOfInput:Byte read FTypeOfInput write SetTypeOfInput;

    //Вес импульса в л/имп для поверяемого расходомера.
    property ImpulseWeights: Double read FImpulseWeights write SetImpulseWeights;

    //Препочтение в отображении коэфиициента  - True - литр/имп False - имп/литр (пока только для отображения)
    property ConversionCoefficientInLiterPerImpulse:boolean read FConversionCoefficientType write SetConversionCoefficientType;

    property MinOutlay: Single read FMinOutlay write SetMinOutlay;

    property MaxOutlay: Single read FMaxOutlay write SetMaxOutlay;

    property Quality:TFmxDeviceQuality read GetQuality;

    property Started:boolean read FStarted write SetStarted;

    property AntiShatterFilter:boolean read FAntiShatterFilter write SetAntiShatterFilter;

    property AntiShatterFilterTime:integer read FAntiShatterFilterTime write SetAntiShatterFilterTime;

    property Caption:String read FCaption write SetCaption;

  end;


//============================================================================================================

  // Вспомогательные типы, используемые для определения направления и состояния задвижки.
  TElectricValveDirection = (dClosing, dStoped, dOpening, dIncorrect);
  TElectricValveStatus = (sClosed, sIntermediate, sOpened, sClosing,sOpening,sIncorrect);

  //==========================================================================================================

  TFmxDeviceElectricValve = class(TFmxDevice)

  private

    // Номер задвижки на модуле.
    FValveNumber: Byte;
    FFullCommandTime: Single;       //время выполнения всей операции
    FFullCommandTickCount: Longword; //ожидаемое время выполнения всей операции
    FStartCommandTickCount: Longword; //ожидаемое время выполнения всей операции
    FTimeToSwitch: integer;
    FCommandDirection: Boolean;
    FStartedPos: double;
    FDeltaPos: double;
    FTargetPos: double;
    FMoving: boolean;
    FValveInputNumber: Byte;
    FKOutput: Single;
    FKInput: Single;
    FMaxChannels: byte;

    function GetDirection: TElectricValveDirection;
    function GetPosition: Double;
    function GetStatus: TElectricValveStatus;
    procedure SetValveNumber(const Value: Byte);
    function GetClosing: boolean;
    function GetOpening: boolean;
    procedure SetFullCommandTime(const Value: Single);
    procedure SetTimeToSwitch(const Value: integer);
    function GetCurCommandTime: Single;
    procedure SetCommandDirection(const Value: Boolean);
    procedure SetStartedPos(const Value: double);
    procedure SetDeltaPos(const Value: double);
    procedure SetTargetPos(const Value: double);
    function GetInputPos: Double;
    function GetRemainTime: Single;
    procedure SetMoving(const Value: boolean);
    procedure SetValveInputNumber(const Value: Byte);
    function GetTimeToSwitch: integer;
    procedure SetMaxChannels(const Value: byte);override;

  public

    // Направление задвижки.
    property Direction: TElectricValveDirection read GetDirection;

    // Положение задвижки в процентах.
    property Position: Double read GetPosition;

    property InputPos:Double read GetInputPos;

    // Состояние задвижки.
    property Status: TElectricValveStatus read GetStatus;

    // valve_number - номер задвижки на модуле (от 0 до 2);
    constructor CreateOnModuleValve(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;  valve_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    { ===== CalibrateValves =====
    Калибрует все задвижки на модуле.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function CalibrateValves: Boolean;

    { ===== MoveValve =====
    Меняет положение задвижки.
    Принимаемые параметры:
    position - устанавливаемое положение задвижки в процентах.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом;
    - некорректное значение устанавливаемого положения.
    }
    function MoveValve(_position: Double): Boolean;

    { ===== StopValve =====
    Останавливает задвижку.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function StopValve: Boolean;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    { ===== Opened =====
    Возвращает false в случае:
    - задвижка не открыта на 100%
    }
    function Opened:boolean;

    procedure Open;

    procedure Close;

    property ModuleType;

    property ValveInputNumber: Byte read FValveInputNumber write SetValveInputNumber;

    property ValveNumber: Byte read FValveNumber write SetValveNumber;

    property Opening:boolean read GetOpening;

    property Closing:boolean read GetClosing;
    {Полное время текущей операции, сек }
    property FullCommandTime:Single read FFullCommandTime write SetFullCommandTime;
    {текущее время выполнения, сек}
    property CurComandTime:Single read GetCurCommandTime;
    {Время переключения от начального до конечного состояния}
    property TimeToSwitch:integer read GetTimeToSwitch write SetTimeToSwitch;
    {Направление отрабтки команды True - открытие, False - Закрытие}
    property CommandDirection:Boolean read FCommandDirection write SetCommandDirection;
    {Позиция при начале выполнения команды}
    property StartedPos:double read FStartedPos write SetStartedPos;
    {Требумая позиция при начале выполнения команды}
    property TargetPos:double read FTargetPos write SetTargetPos;
    {Разница между положениями}
    property DeltaPos:double read FDeltaPos write SetDeltaPos;
    {Оставшееся время}
    property RemainTime:Single read GetRemainTime;
    {Состояние движения}
    property Moving:boolean read FMoving write SetMoving;
  end;

//============================================================================================================


  TFmxDeviceSimpleEdit = class(TFmxDevice)

  private

    // Номер задвижки на модуле.
    FInputNumber: Byte;
    FOutputNumber: Byte;
    FMaxChannels: byte;
    FNumber: Byte;
    FMustUpdate: boolean;

    function GetInputValue: Double;
    procedure SetMaxChannels(const Value: byte);override;
    function GetOutputValue: Double;
    procedure SetOutputValue(const Value: Double);
    procedure SetNumber(const Value: Byte);
    procedure SetMustUpdate(const Value: boolean);override;
    Function GetMustUpdate():boolean;override;
    procedure SetModbusFormat(const Value: TModBusDataFormat);override;

  public

    property OutputValue: Double read GetOutputValue write SetOutputValue;

    property InputValue:Double read GetInputValue;

    // valve_number - номер задвижки на модуле (от 0 до 2);
    constructor CreateOnModuleValve(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;  valve_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    function ChangeValue(_value: Double): Boolean;

    property ModuleType;

    property Number: Byte read FNumber write SetNumber;

    property MustUpdate:boolean read FMustUpdate write SetMustUpdate;
  end;

//============================================================================================================


  TFmxDeviceFCD = class(TFmxDevice)

  private

    // Номер УПП на модуле.
    F_FCDNumber: Byte;
    OfflineInTankTime:Single;
    OfflineInTankTimeCounter:longword;
    FSynchroChannel: byte;



    // Функции, возвращающие данные из модуля.
    //в нашем случае InTankTime = OfflineValue2, а оставшееся время над баком - OfflineValue
    function GetInTankPosition: Boolean;
    function GetInTankTime: real;
    function Gett1: real;
    function Gett2: real;
    function Gett3: real;
    function Gett4: real;
    function GetFCDNumber: Byte;
    procedure SetFCDNumber(const Value: Byte);
    procedure SetSynchroChannel(const Value: byte);
    function GetSynchroChannel: byte;
    function GetInPipeTime: real;
    function GetSwitchingTimeToPipe(Idx: integer): real;
    function GetSwitchingTimeToTank(Idx: integer): real;
    function GetTimeToPipe: real;
    function GetTimeToTank: real;
  public

    // Положение УПП (true - на бак, false - на пролетную трубу).
    property InTankPosition: Boolean read GetInTankPosition;

    // Длительность последнего переключения УПП на модуле (не обязательно этого УПП) в мс.
    property TimeToTank: real read GetTimeToTank;
    property TimeToPipe: real read GetTimeToPipe;

    //Время нахождения сопла в баке
    property InTankTime: real read GetInTankTime;

    //времена между срабатыванием датчиков
    property t1:real read Gett1;
    property t2:real read Gett2;
    property t3:real read Gett3;
    property t4:real read Gett4;

    // FCD_number - номер УПП на модуле (от 0 до 2).
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address:Byte;BR: Cardinal;  AFCD_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    procedure SetActiveChannel;
    { ===== Switch =====
    Переключает УПП на бак или на пролетную трубу.
    Принимаемые параметры:
    in_tank - устанавливаемое положение (true - на бак, false - на пролетную трубу).
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Switch(in_tank: Boolean): Boolean;

    { ===== SwitchWithTimer =====
    Переключает УПП на бак на заданное время.
    Принимаемые параметры:
    time - время в десятых долях секунды (от 0 до 18000).
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом;
    - некорректное значение времени.
    }
    function SwitchWithTimer(time: Word): Boolean;

    {
    Переключает УПП по датчикам, при срабатывании 1го датчика переключается на
    бак, при срабатывании 2го - обратно на пролетку.
    Принимаемые параметры:
    FCD_number - номер УПП (от 0 до 2);
    Sensor - номер датчика (от 0 до 3);
      0 - 1я пара направление вперед
      1 - 2я пара направление вперед
      2 - 1я пара направление назад
      3 - 2я пара направление назад
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом;
    }
    function SwitchWithSensor(time: Word): Boolean;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }

    function UpdateStatus: Boolean;

    function UpdateTimeInTank: Boolean;

    property FCDNumber: Byte read GetFCDNumber write SetFCDNumber;

    property SynchroChannel:byte read GetSynchroChannel write SetSynchroChannel;
  end;

//============================================================================================================


  //====================

  TFmxDeviceFlowmeter = class(TFmxDevice)

  private
    // Номер пары эталонных расходомеров, на которой висит расходомер.
    FPairNumber: Byte;

    // Флаг использования первичного канала в паре эталонных расходомеров модуля, на котором висит расходомер.
    Primary: Boolean;
    FRequestMasterSlaveTogether: boolean;
    FSpillTime: Single;
    FUnSelected: boolean;
    FCurrentKoeff: Single;
    FMassCounter: Boolean;
    //Для ручного ввода
    FFrequency:Single;//Частота
    FImpulse:Single;
    FTypeOfInput: Byte;
    FMasterMode: boolean;



    function GetFrequency: Single;
    function GetSecondaryFrequency: Word;


    { ===== GetVolume =====
    Возвращает пролитый через расходомер объем в литрах на заданном канале c учетом калибровки.
    Принимаемые значения:
    counter_number - номер канала (от 0 до 7).
    Возвращает 0 в случае некорректности номера канала.
    }
    function GetVolume: Double;

    { ===== GetWaterDischarge =====
    Возвращает текущий расход в м3/ч с учетом калибровки.
    по эталонному расходомеру
    }
    function GetWaterDischarge: Double;
    { ===== GetWaterDischarges =====
    Возвращает текущий расход в м3/ч с учетом калибровки.
    по поверяемым расходомерам
    }
    function GetVersion: String;
    procedure SetUnSelected(const Value: boolean);
    function GetCurKoeff: Double;

    function GetTime: Double;
    function GetResultTime: Double;
    function GetCurrentTime: Integer;
    function GetImpulse: Single;
    function GetCounterIsActive(index: Byte): Boolean;
    function GetAddr: integer;override;
    function GetIsCounterStarting: boolean;
    function GetCountIsStarted: boolean;
    procedure SetCurrentKoeff(const Value: Single);
    procedure SetMassCounter(const Value: Boolean);
    procedure SetFrequency(const Value: Single);
    procedure SetImpulse(const Value: Single);
    function RequestVolumes_Status: Boolean;
    procedure SetCounterIsActive(index: Byte; const Value: Boolean);
    procedure SetMasterMode(const Value: boolean);
    procedure SetTypeOfInput(const Value: Byte);

    //
//    property Outlay[index: Byte]: Double read GetOutlay;


    { ===== GetResultGeneratorError =====
    Возвращает состояние флага ошибки генератора
    }
    function GetResultGeneratorError: boolean;

    { ===== IsSelected =====
    Возвращает true, если расходомер входит в выбранную эталонную пару.
    }
    function IsSelected: Boolean;
    procedure SetSelected(const Value: Boolean);
    procedure SetRequestMasterSlaveTogether(const Value: boolean);
    //ПЕРЕИМЕНОВЫВАЕМ GetIVolume в GetMasterVolume_C_E
    function GetMasterVolume(index:byte): Double;
    procedure SetSpillTime(const Value: Single);
    function GetImpulses(index: Byte): Double;
    function GetSomeActiveChannelsIsActive: boolean;
    function GetSpillTime: Single;
    procedure SetPairNumber(const Value: byte);
    function GetProtocolID: word;

  public

    // Веса импульсов в л/имп для каждого из поверяемых расходомеров.
//    SlaveImpulseWeights: array [0..15] of Double;
    current_settings:TFlowmeterSettings;//рабочие значения
    stored_settings:TFlowmeterSettings;//сохраненные значения

    { ===== CalculateCalibrationCoefficient =====
    Возвращает калибровочный коэффициент для текущего расхода. Если калибровочная таблица пуста или
    некорректна, возвращает 1.
    }
    function CalculateCalibrationCoefficient: Double;
    procedure StartCount;
    procedure StartCountWithoutSynchro;
    procedure StopCount;
    procedure SetDependentImpulseMode(aDepenededMode:boolean);
    function SetupCountWithoutSynchro:integer;
    procedure SetMustUpdate(const Value: boolean);override;

    // Флаги активности счетчиков (для режима зависимых импульсов).
    property CounterIsActive[index: Byte]: Boolean read GetCounterIsActive write SetCounterIsActive;

    // Текущее значение частоты расходомера.
    property Frequency: Single read GetFrequency write SetFrequency;

    // Текущее значение частоты, которая идет на 2й канал
    property SecondaryFrequency: Word read GetSecondaryFrequency;

    // Флаг вхождения расходомера в выбранную эталонную пару на модуле.
    property Selected: Boolean read IsSelected write SetSelected;

    property Impulse:Single read GetImpulse write SetImpulse;


    // Текущий расход в м3/ч с учетом калибровки и веса импульса.
    property WaterDischarge: Double read GetWaterDischarge;

    // Текущий объем в м3 с учетом калибровки и веса импульса
    // Текущая масса в тоннах - если массовик
    // зависит от настроек расходомера - массовый будет масса, объемный - объем
    property VolumeOrMassa: Double read GetVolume;

    //Флаг сигнализирующий об ошибке генератора
    property GeneratorError: boolean read GetResultGeneratorError;

    property SomeActiveChannelsIsActive:boolean read GetSomeActiveChannelsIsActive;

    // primary - флаг использования первичного канала в паре эталонных расходомеров;
    // channel_number - номер канала в паре эталонных расходомеров, на котором висит расходомер;
    constructor CreateOnModuleCounter(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: longword;BR: Cardinal;  pair_number: Byte; prima:
      Boolean; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    destructor Destroy; override;

    { ===== Select =====
    Выбирает пару эталонных расходомеров, в которую входит данный расходомер.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Select: Boolean;
    { ===== Select =====
    Выбирает пару эталонных расходомеров, в которую входит данный расходомер.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UnSelect: Boolean;

    { ===== UpdateCommonStatus =====
    Обновляет общий статус счетчиков (флаги запущенных счетчиков, выбранная пара эталонных расходомеров,
    состояния программного старта, режима медленных импульсов и режима зависимых импульсов).
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateCommonStatus: Boolean;

    { ===== Lockvalues =====
    Защелкивает крайние показания
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function LockAllValues: Boolean;


//    { ===== RequestUpdateVolumes =====
//    Запрашивает данные по накопленному объему
//    вызываются команды A,B,C,D,E и S
//    переименовываем RequestUpdateVolumes в RequestVolumes_Status
//    }
//    function RequestVolumes_Status: Boolean;
    { ===== UpdateVolumes =====
    Обновляет значения пролитых объемов. При каждом вызове обновляет значение объема для каждого канала с
    учетом изменения количества импульсов с последнего вызова (калибровочный коэффициент для текущего расхода
    действует только на изменение количества импульсов, а расчитанное ранее значение не претерпевает
    изменений). Перед вызовом рекомендуется также обновлять расход вызовом UpdateWaterDischarges, т.к. он
    учитывается для определения калибровочного коэффициента.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateVolumes(): Boolean;

    { ===== UpdateWaterDischarges =====
    Обновляет значения текущих расходов для всех расходомеров модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateWaterDischarges: Boolean;

    procedure SetupInputs;

   function SetupStartStop: Boolean;


    property RequestMasterSlaveTogether:boolean read FRequestMasterSlaveTogether write SetRequestMasterSlaveTogether;//запрашивать накопленные по эталонным и по
    //поверяемым одновременно
    property StartStopTime:Single read GetSpillTime write SetSpillTime;

    //С НУЛЯ
    property PairNumber:byte read FPairNumber write SetPairNumber;

    property Version:String read GetVersion;

    property UnSelected:boolean read FUnSelected write SetUnSelected;

    property Addr:integer read GetAddr;

    property IsCounterStarting:boolean read GetIsCounterStarting;

    // Флаг состояния программного старта.
    property CountIsStarted: Boolean read GetCountIsStarted;

    property CurrentKoeff:Single read FCurrentKoeff write SetCurrentKoeff;

    property MassCounter:Boolean read FMassCounter write SetMassCounter;

    property TypeOfInput:Byte read FTypeOfInput write SetTypeOfInput;

    property MasterMode:boolean read FMasterMode write SetMasterMode;

    property ProtocolID:word read GetProtocolID;

    property CurrentTime:Integer read GetCurrentTime;
    property ResultTime:Double read GetResultTime;
    property Time:Double read GetTime;


  end;

//============================================================================================================

  TFmxDeviceHeater = class(TFmxDevice)

  private

    // Номер используемого выхода от 0 до 3
    FOutputNumber: Byte;

    function GetActive: Boolean;
    procedure SetOutputNumber(const Value: Byte);
    procedure SetMaxChannels(const Value: byte);override;

  public

    // Флаг включения прибора.
    property Active: Boolean read GetActive;

    // output_number - номер используемого выхода.
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;  output_number: word;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
//    constructor CreateOnModuleValve(address: Byte;BR: Cardinal;  output_number: Byte);
//    constructor CreateOnModuleSuperBio(address: Byte;BR: Cardinal;  output_number: Byte);

    { ===== Activate =====
    Включает прибор.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Activate: Boolean; virtual;

    { ===== Deactivate =====
    Выключает прибор.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Deactivate: Boolean; virtual;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    property OutputNumber:Byte read FOutputNumber write SetOutputNumber;


  end;

//============================================================================================================

  TFmxDeviceHeatingPump = class(TFmxDeviceHeater)

  public

    { ===== Activate =====
    Включает прибор.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Activate: Boolean; override;

    { ===== Deactivate =====
    Выключает прибор.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Deactivate: Boolean; override;

  end;

//============================================================================================================

  TFmxDeviceLevelDetector = class(TFmxDevice)

  private

    // Номер используемого входа
    // 0-12 при использовании SuperBIO
    // 6-9 при использовании Valve
    FInputNumber: Byte;

    FFromInput: boolean;
    FInverse: boolean;

    { ===== GetInput =====
    Возвращает значение входа, на котором висит датчик уровня.
    }
    function GetInput: Boolean;
    procedure SetInputNumber(const Value: byte);
    procedure SetInverse(const Value: boolean);

  public

    // Флаг затопления датчика уровня. 1 - погружен в жидкость, 0 - в воздухе
    property Submerged: Boolean read GetInput;

    // input_number - номер используемого входа.
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: integer;BR: Cardinal;  input_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);
//    constructor CreateOnModuleValve(address: Byte;BR: Cardinal;  input_number: Byte);

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    property FromInput:boolean read FFromInput write FFromInput default true;

    property InputNumber:byte read FInputNumber write SetInputNumber;

    property Inverse:boolean read FInverse write SetInverse;

  end;

//============================================================================================================

  TFmxDevicePneumaticValve = class(TFmxDevice)

  private

    // Номер используемой пары вход/выход
    // 0-12 при использовании SuperBIO
    // 6-8 при использовании Valve
    FOpenONumber: byte;
    FCloseONumber:byte;
    FOpenINumber: byte;
    FCloseINumber:byte;

    //Момент когда "безконечниковая" задвижка начинает открываться или закрываться
    StartTickCount: longword;

    FOpened:boolean;
    FClosed:boolean;
    FTwoSwitch:boolean;

    // Предыдущее состояние true - открыта, false - закрыта
    PreviousState: boolean;
    FWithInput: boolean;
    FLastCmd: byte;
    FCloseTickCount: Cardinal;
    FOpenTickCount: Cardinal;

    function GetOpened: Boolean;
    function GetClosed: Boolean;
    procedure SetWithInput(const Value: boolean);
    procedure SetOpenONumber(const Value: byte);
    procedure SetCloseONumber(const Value: byte);
    procedure SetLastCmd(const Value: boolean);
    function GetLastCmd: boolean;
    procedure StopOpen;
    procedure StopClose;
    function GetOpening: Boolean;
    function GetClosing: boolean;
    function GetMustInCloseState: boolean;
    function GetMustInOpenState: boolean;
    procedure SetCloseTickCount(const Value: Cardinal);
    procedure SetOpenTickCount(const Value: Cardinal);
    function GetCloseTimeIsOut: boolean;
    function GetOpenTimeIsOut: boolean;
    procedure SetCloseINumber(const Value: byte);
    procedure SetOpenINumber(const Value: byte);
    function GetStopped: boolean;

  public

    //Время движения задвижки. После истечения данного времени с момента подачи команды,
    //считаем, что задвижка открылась или закрылась
    TimeToSwitch:byte;

    //означает, что у задвижки 2 конечника
    property TwoSwitch:boolean read FTwoSwitch write FTwoSwitch;


    // Флаг открытия задвижки.
    property Opened: Boolean read GetOpened;

    property Opening: Boolean read GetOpening;

        // Флаг открытия задвижки.
    property Closed: Boolean read GetClosed;

    property Closing:boolean read GetClosing;

    // io_number - номер используемой пары вход/выход.
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR:
      Cardinal; open_i_number,close_i_number,open_o_number,close_o_number: byte;
      two_switches,with_input:boolean;AModuleType:TFmxModuleType;InputReg:Word;OutputReg:word;_typeofprotocol:TTypeOfProtocol);
    //constructor CreateOnModuleValve(address: Byte;BR: Cardinal;  io_number: Byte);

    { ===== Close =====
    Закрывает задвижку.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Close: Boolean;

    { ===== Open =====
    Открывает задвижку.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Open: Boolean;

    procedure Stop;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    //с вохдными значениями - true InputValues соответствуют OutputValues
    property WithInput:boolean read FWithInput write SetWithInput;

    //Ноемр входа платы superbio для первого и второго конечника
    property OpenONumber:byte read FOpenONumber write SetOpenONumber;
    property CloseONumber: byte read FCloseONumber write SetCloseONumber;
    property OpenINumber:byte read FOpenINumber write SetOpenINumber;
    property CloseINumber:byte read FCloseINumber write SetCloseINumber;

    property LastCmd:boolean read GetLastCmd write SetLastCmd;

    property OpenTickCount:Cardinal read FOpenTickCount write SetOpenTickCount;//время - если меньше текущего - знаит событие наступило - если 0 - то такого события не было
    property CloseTickCount:Cardinal read FCloseTickCount write SetCloseTickCount;//время - если меньше текущего - знаит событие наступило - если 0 - то такого события не было
    property  MustInOpenState:boolean read GetMustInOpenState;
    property  MustInCloseState:boolean read GetMustInCloseState;
    property Stopped:boolean read GetStopped;//прошла команда останова
    property OpenTimeIsOut:boolean read GetOpenTimeIsOut;
    property CloseTimeIsOut:boolean read GetCloseTimeIsOut;
  end;

//============================================================================================================

  TFmxDeviceProver = class(TFmxDevice)

  private

    function GetActive: Boolean;

  public

    // Активированность модуля.
    property Active: Boolean read GetActive;

    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    { ===== SetActivity =====
    Активирует/деактивирует модуль ТПУ.
    Принимаемые параметры:
    activity - устанавливаемый флаг "активированности".
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function SetActivity(activity: Boolean): Boolean;

    { ===== UpdateStatus =====
    Обновляет статус модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

  end;

//============================================================================================================
  TFmxDevicePumpStartStop = class(TFmxDevice)

  private
    // Номер используемой пары вход/выход
    // 0-12 при использовании SuperBIO
    // 6-8 при использовании Valve
    FIONumber: Byte;
    FEnabledToStart: Boolean;
    FWithInput: boolean;
    function GetStarted: Boolean;
    procedure SetStarted(const Value: Boolean);
    procedure SetWithInput(const Value: boolean);
    procedure SetIONumber(const Value: byte);
    function IONumberCorrect(Value:integer): Boolean;

  public
    // Флаг активности насоса.
    property Started: Boolean read GetStarted write SetStarted;
    //СВойство для разрешения запуска насоса
    property EnabledToStart: Boolean read FEnabledToStart write FEnabledToStart default true;

    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: integer;BR: Cardinal;io_number: Byte;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    { ===== Init =====
    Инициализирует работу с модулем-устройством. Необходимо выполнять один раз перед отправкой команд.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Init: Boolean;

    { ===== StartPump =====
    Запускает насос.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function StartPump: Boolean;

    { ===== StopPump =====
    Останавливает насос.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function StopPump: Boolean;



    //с вохдными значениями - true InputValues соответствуют OutputValues
    property WithInput:boolean read FWithInput write SetWithInput;

    property IONumber:byte read FIONumber write SetIONumber;

  end;


  TFmxDevicePumpPower = class(TFmxDevice)

  private
    FDAC_Number: byte;
    FMinFreq: Integer;
    function GetFreq: Single;
    procedure SetDAC_Number(const Value: byte);
    { ===== SetPower =====
    Устанавливает мощность насоса.
    Принимаемые параметры:
    power - устанавливаемая мощность в герцах (от 0 до 50).
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом;
    - некорректное значение устанавливаемой мощности.
    }
    procedure SetMinFreq(const Value: Integer);
    function GetPower: Single;
    procedure SetPower(const Value: Single);

  public

    // Частота вращения насоса в герцах. [0..50]
    property CurrentFrequency: Single read GetFreq;

    // Установленная мощность насоса в %. [0..100]
    property Power: Single read GetPower write SetPower;

    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: integer;BR: Cardinal;DACNumb:byte;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);

    { ===== Init =====
    Инициализирует работу с модулем-устройством. Необходимо выполнять один раз перед отправкой команд.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function Init: Boolean;

    property DAC_Number:byte read FDAC_Number write SetDAC_Number;

    property MinFreq:Integer read FMinFreq write SetMinFreq;
  end;

//============================================================================================================

  TFmxDeviceCMCylinders = class(TFmxDevice)
  private
    FDensity: real;
    FDiscontinuity: int64;
    FTare: Single;
    FCalibrationCoefficient: Single;
    FCalibrationNull: Single;
    FScaleValue: Double;
    FActive: boolean;
    FKalibrKoeff: Single;
    function GetVolume: Single;
    function GetWeight: Single;
    procedure SetActive(const Value: boolean);
    procedure SetCalibrationCoefficient(const Value: Single);
    procedure SetCalibrationNull(const Value: Single);
    procedure SetDensity(const Value: real);
    procedure SetDiscontinuity(const Value: int64);
    procedure SetScaleValue(const Value: Double);
    procedure SetTare(const Value: Single);
    procedure SetKalibrKoeff(const Value: Single);
    function CalibrationCoefficient(Scale: double): double;
  public
    settings:TScalesSettings;

	//Режим работы весов
    ScalesMode: TScalesMode;

    // Калибровочный параметр. Значения, измеренные в нуле.
    property CalibrationNull:Single read FCalibrationNull write SetCalibrationNull;

    // Позиция в миллиметрах при пустом мернике
    property Tare: Single read FTare write SetTare;

    // Значение дискретности для выбранного мерника.
    property Discontinuity : int64 read FDiscontinuity write SetDiscontinuity;

    // Текущее значение по шкале в мм
    property ScaleValue: Double read FScaleValue write SetScaleValue;

    // Значения веса на датчиках в кг. Расчитывается из массива последних значений датчиков веса, учитывая
    // калибровку.
    property Volume: Single read GetVolume;

    property Weight: Single read GetWeight;

    //Чтение проверяет активны ли весы, и если активны, то возвращает true
    //запись делает весы активными или неактивными, то есть ставит на тензодатчики бак
    // или наоборот убирает
    property Active:boolean read FActive write SetActive;

    constructor CreateOnModule(MT:TFmxModuleType);
    destructor Destroy; override;

    //плотность воды в весовом баке
    property Density:real read FDensity write SetDensity;

    //текущий калибровочный коэффициент
    property KalibrKoeff:Single read FKalibrKoeff write SetKalibrKoeff;

  end;

//============================================================================================================

  TFmxDeviceScales = class(TFmxDevice)

  private

    FSensorsQuantity: Byte;
    FWeightsBufferLength: Byte;
//    FCalibrationCoefficient_L2:Double;
    FDiscontinuity:int64;
    FTare:Double;
    FPrevResult:Double;
    FCalibrationNulls: array [0..3] of Longword;
    FCalibrationCoefficients: array [0..3] of Double;
    FAmbientTemperature0: array [0..3] of Double;
    FAtmosphericPressure0: array [0..3] of Double;
    FRelativeHumidity0: array [0..3] of Double;
    FDumbbellsDensity0: array [0..3] of Double;
    MedianFilter:array [0..3] of TFmxMedianFilter;
    FActive:boolean;

    // Значения на входах модуля-устройства.
    FSensorValues: array [0..3] of Single;
    // Массив последних значений датчиков веса.
    ValuesBuffer: Array of Array [0..3] of Double;
    FUse_L2: boolean;
    FKalibrKoeff: Double;
    FDensity: real;
    FValue: Double;
    FMassMode: Boolean;
    FUse_L1: boolean;
    FMedianFilterSize: byte;
    Fchanged: boolean;

    //29.12.2011. Саранцев
    //Делаю эти 3 метода виртуальными, так как они будут переопределяться в BigScales
    //и переношу их в protected
    //function GetSensorValue(sensor_number: Byte): Longword;
    //function GetSensorWeight(sensor_number: Byte): Double;
    //function GetWeight: Double;

    // Обработчик ответов от модуля-устройства. Значение веса, выдаваемое модулем-устройством изменилось с
    // последнего обращения, то добавляет в буфер весов новое значение, удаляя самое старое, если буфер
    // заполнен.

    procedure ScalesPneumaticContactOpen;
    procedure ScalesPneumaticContactClose;
    procedure ReceiveResponse;
    function CalibrationCoefficient(Discharge:double):double;
	function GetAmbientTemperature0(sensor_number: byte): Double;
    function GetAtmosphericPressure0(sensor_number: byte): Double;
    function GetDumbbellsDensity0(sensor_number: byte): Double;
    function GetRelativeHumidity0(sensor_number: byte): Double;
    procedure SetAmbientTemperature0(sensor_number: byte;
      const Value: Double);
    procedure SetAtmosphericPressure0(sensor_number: byte;
      const Value: Double);
    procedure SetDumbbellsDensity0(sensor_number: byte;
      const Value: Double);
    procedure SetRelativeHumidity0(sensor_number: byte;
      const Value: Double);
    function GetDumbbellsDensity: double;
    procedure SetDumbbellsDensity(const Value: double);
    procedure SetAmbientTemperature(const Value: double);
    procedure SetAtmosphericPressure(const Value: double);
    procedure SetRelativeHumidity(const Value: double);
    procedure SetSensorsQuantity(const Value: Byte);
    procedure SetUse_L2(const Value: boolean);
    procedure SetSensorValue(index: Byte; const Value: Double);
    function GetVolume: Double;
    procedure SetDensity(const Value: real);
    procedure SetValue(const Value: Double);
    function GetValue: Double;
    procedure SetMassMode(const Value: Boolean);
    procedure SetUse_L1(const Value: boolean);
    procedure SetWeight(const xValue: Double);
    procedure SetMedianFilterSize(const Value: byte);
    procedure Setchanged(const Value: boolean);

  protected
    function GetSensorValue(sensor_number: Byte): Double; Virtual;
    function GetWeight: Double; Virtual;
    function GetSensorWeight(sensor_number: Byte): Double; Virtual;
    function GetClearWeight: Double; Virtual;
    function GetDiscontinuity:int64; virtual;
    procedure SetDiscontinuity(Dt:int64); virtual;
    function GetTare: Double; virtual;
    procedure SetTare(const Value: Double); virtual;
    function GetCalibrationNulls(sensor_number:byte): Longword; virtual;
    procedure SetCalibrationNulls(sensor_number:byte; const Value: Longword);virtual;
    function  GetCalibrationCoefficients(sensor_number:byte): Double; virtual;
    procedure SetCalibrationCoefficients(sensor_number:byte;CalibrationCoefficient: Double); virtual;
    function GetSensorsQuantity:byte; virtual;
    procedure SetWeightsBufferLength(weights_buffer_length: Byte); virtual;
    function  GetWeightsBufferLength:byte; virtual;
    procedure SetActive(AActive:boolean);
    function GetActive:boolean;

  public
    settings:TScalesSettings;

	//Режим работы весов
    ScalesMode: TScalesMode;

    //контакт который будет управлять пневмоцилиндром поднимающим и опускающим весовой бак
    ScalesPneumaticContact: TFmxDeviceBlcedValve;

    //Параметры окружающей среды для вычисления силы архимеда, будут записываться
    //во время получения ответа компонентами соответствующих датчиков
    FAmbientTemperature:double;
    FRelativeHumidity:double;
    FAtmosphericPressure:double;
    WaterTemperature:double; //температура воды в весовом баке

    //флаг определющий каким состоянием контакта ScalesPneumaticContact активируются весы
    //если ActiveToActivate=true, то при активном выходе весы, активируются при неактивном
    //деактивируются. И соответственно ActiveToActivate=false, то при неактивном выходе весы активны
    //то есть стоят на тенходатчиках
    ActiveToActivate:boolean;
    function GetCalibrationCoefficient_L2(Discharge: double): double;

    // Калибровочный параметр. Коэффициенты.
    property CalibrationCoefficients[sensor_number:byte]:Double read GetCalibrationCoefficients write SetCalibrationCoefficients;

    // Калибровочный параметр. Значения, измеренные в нуле.
    property CalibrationNulls[sensor_number:byte]:Longword read GetCalibrationNulls write SetCalibrationNulls;

    //Значение атмосферного давления при калибровке в Паскалях
    property AtmosphericPressure0[sensor_number:byte]:Double read GetAtmosphericPressure0 write SetAtmosphericPressure0;

    //Значение темепратуры воздуха при калибровке
    property AmbientTemperature0[sensor_number:byte]:Double read GetAmbientTemperature0 write SetAmbientTemperature0;

    //Значение относительной влажности воздуха при калибровке
    property RelativeHumidity0[sensor_number:byte]:Double read GetRelativeHumidity0 write SetRelativeHumidity0;

    //Значение относительной влажности воздуха при калибровке
    property DumbbellsDensity0[sensor_number:byte]:Double read GetDumbbellsDensity0 write SetDumbbellsDensity0;

    // Вес пустого бака в кг.
    property Tare: Double read GetTare write SetTare;

    // 10.07.2008, Возженников
    // Значение дискретности для выбранных весов.
    property Discontinuity : {Longword}int64 read GetDiscontinuity write SetDiscontinuity;


    // Количество используемых датчиков.
    property SensorsQuantity: Byte read GetSensorsQuantity write SetSensorsQuantity;

    // Текущие значения весов на датчиках без учета калибровки.
    property SensorValues[index: Byte]: Double read GetSensorValue write SetSensorValue;

    // Значения веса на датчиках в кг. Расчитывается из массива последних значений датчиков веса, учитывая
    // калибровку.
    property SensorWeights[index: Byte]: Double read GetSensorWeight;

    // Вес содержимого бака в кг. Сумма значений веса по каждому датчику минус тара.
    property Weight: Double read GetWeight write SetWeight;

    // Объем
    property Volume: Double read GetVolume;

    property Value:Double read GetValue write SetValue;

    //Без учета калибровочного коэффициента. Вес содержимого бака в кг. Сумма значений веса по каждому датчику минус тара.
    property ClearWeight: Double read GetClearWeight;

    // Размер буфера последних значений веса. Минимальное значение - '1'.
    property WeightsBufferLength: Byte read GetWeightsBufferLength write SetWeightsBufferLength;

    //Чтение проверяет активны ли весы, и если активны, то возвращает true
    //запись делает весы активными или неактивными, то есть ставит на тензодатчики бак
    // или наоборот убирает
    property Active:boolean read GetActive write SetActive;

    property DumbbellsDensity:double read GetDumbbellsDensity write SetDumbbellsDensity; //плотность материала гирь, используемых при поверке

    // sensors_count - количество используемых датчиков (от 1 до 4).
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;MT:TFmxModuleType;port:integer; address: integer;BR: Cardinal; sensors_quantity: Byte;_typeofprotocol:TTypeOfProtocol;InputReg:Word);

    destructor Destroy; override;

    { ===== UpdateStatus =====
    Обновляет статус модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }

    //29.12.2011. Саранцев
    //Делаю мметод виртуальным, так как он будет переопределяться в BigScales
    function UpdateStatus: Boolean; Virtual;

    //плотность воды в весовом баке
    function DensityScales(T, P:real):real;

    //плотность воздуха
    function DensityAir(T, P, H:real):real;

    property AmbientTemperature:double read FAmbientTemperature write SetAmbientTemperature;
    property RelativeHumidity:double read FRelativeHumidity write SetRelativeHumidity;
    property AtmosphericPressure:double read FAtmosphericPressure write SetAtmosphericPressure;

    property Use_L1:boolean read FUse_L1 write SetUse_L1;

    property Use_L2:boolean read FUse_L2 write SetUse_L2;

    //плотность воды в весовом баке
    property Density:real read FDensity write SetDensity;

    property MassMode:Boolean read FMassMode write SetMassMode default True;

    property MedianFilterSize:byte read FMedianFilterSize write SetMedianFilterSize;

    property changed:boolean read Fchanged write Setchanged;
  end;

//============================================================================================================

// 02.09.2009 - класс для реализации трехмодульных весов. Как ни крутись, без него не обойтись

{
  Все-таки лучше делать класс потомком TFmxDevice, и немного поправить его,
  иначе большой объем кода придется дублировать.
}


 //============================================================================================================

  // Класс используется как для термометра, так и для манометра.
  TFmxDeviceThermometer = class(TFmxDevice)

  private
    FInputNumber: byte;
    FValue:Double;
    { ===== GetTemperature =====
    Возвращает показание температуры с учетом калибровочных данных.
    }
    function GetValue: Double;
    procedure SetValue(const Value: Double);
    procedure SetInputNumber(const Value: byte);
    procedure SetMaxChannels(const Value: byte);override;
    procedure SetDigitsForChannel(const Value: byte);override;
    procedure SetMustUpdate(const Value: boolean);override;
    procedure SetModbusFormat(const Value: TModBusDataFormat);override;
    function GetMustUpdate: boolean;override;
    function GetRawValue: Single;

  public

    // Калибровочный параметр. Коэффициент.
    settings:TLinearCalibrationSettings;

    // Значение температуры в градусах Цельсия (с учетом калибровки). (Для давления - в барах)
    property Value: Double read GetValue write SetValue;

    // input_number - номер входа на модуле (от 0 до 7 для модуля T; от 0 до 3 для модуля Temp2).
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer; address: integer;BR: Cardinal; input_number: Byte;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);
    //constructor CreateOnModuleTemp2(address: Byte;BR: Cardinal; input_number: Byte);
    //constructor CreateOnModuleTemp6(address: Byte;BR: Cardinal; input_number: Byte); (* от 0 до 5 для модуля Temp6 *)
    //constructor CreateOnModuleUI(address: Byte;BR: Cardinal; input_number: Byte);
    //constructor CreateOnModuleIVTM(input_number: Byte;BR: Cardinal);

    //На самом деле никакого модуля не создается
    //Сделано для того, что бы не убирать кучу кода, от элемеровской установки
    //в которой были настоящие барометр и гигрометр
    //В программе применяются эти устройства, но на самом деле их нет, поэтому создаем
    //Device на основе "виртуального" модуля
    //Более полное описание смотреть в репозитории ревизия 315
    //constructor CreateOnModuleVirt;

    //переопределим деструктор, если у нас виртуальный модуль, то уничтожать нам нечего
    destructor Destroy; override;

    //так как для термометров может применяться тип модуля Virt, а на самом деле никакого такого модуля нет
    //то AddReceiver не может ничего никуда добавить, поэтому переопределим родительский метод
    //так, что если используется тим модуля Virt, то ничего не добавляется
    procedure AddReceiver(receiver: TProcedureOfObject; use_main_thread: Boolean = true); override;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    property InputNumber:byte read FInputNumber write SetInputNumber;

    property RAWValue:Single read GetRawValue;
  end;
//============================================================================================================

  // Класс используется как для термометра, так и для манометра.
  TFmxDeviceIVTM = class(TFmxDevice)

  private
    FPValue: Double;
    FTValue: Double;
    FHValue: Double;
    FUse_P: boolean;
    FUse_T: boolean;
    FUse_H: boolean;
    FFromBalance: boolean;
    { ===== GetTemperature =====
    Возвращает показание температуры с учетом калибровочных данных.
    }
    function GetH_Value: Double;
    function GetP_Value: Double;
    function GetT_Value: Double;
    procedure SetH_Value(const Value: Double);
    procedure SetP_Value(const Value: Double);
    procedure SetT_Value(const Value: Double);
    procedure SetUse_H(const Value: boolean);
    procedure SetUse_P(const Value: boolean);
    procedure SetUse_T(const Value: boolean);
    procedure ReceiveResponse;
    procedure SetFromBalance(const Value: boolean); // переделать, возвращать сумму с трех модулей

  public
    // Значение температуры в градусах Цельсия (с учетом калибровки). (Для давления - в барах)
    property T_Value: Double read GetT_Value write SetT_Value;
    property P_Value: Double read GetP_Value write SetP_Value;
    property H_Value: Double read GetH_Value write SetH_Value;

    // input_number - номер входа на модуле (от 0 до 7 для модуля T; от 0 до 3 для модуля Temp2).
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer; address: integer;BR: Cardinal; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);

    //переопределим деструктор, если у нас виртуальный модуль, то уничтожать нам нечего
    destructor Destroy; override;

    //так как для термометров может применяться тип модуля Virt, а на самом деле никакого такого модуля нет
    //то AddReceiver не может ничего никуда добавить, поэтому переопределим родительский метод
    //так, что если используется тим модуля Virt, то ничего не добавляется
    procedure AddReceiver(receiver: TProcedureOfObject; use_main_thread: Boolean = true); override;

    { ===== UpdateStatus =====
    Обновляет статус используемого модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    property Use_T:boolean read FUse_T write SetUse_T;
    property Use_H:boolean read FUse_H write SetUse_H;
    property Use_P:boolean read FUse_P write SetUse_P;
    property FromBalance:boolean read FFromBalance write SetFromBalance;

  end;


//============================================================================================================

  // Класс используется как для вольтметра, так и для амперметра.
  TFmxDeviceVoltmeter = class(TFmxDevice)

  private

    // Номер используемого канала на модуле.
    FChannelNumber: Byte;

    //тип входа, ток-0 или напряжение-1
    FInputType:byte;
    FTopMaxOutlay: Single;
    FIntegralValue:Double;//интегральное значение
    FIntegralCounter:longword;//количество значений в FIntegralValue
    FStartStopTime: Double;
    FStarted: Boolean;
    FMaxPhysicalValue: Double;
    FMinPhysicalValue: Double;
    FTopOutlay: Single;
    FMaxOutlay: Single;
    FMinOutlay: Single;
    FCaption: String;

    function GetPhysicalValue: Double;

    function GetMeanValue: Double;
    function GetQuality: TFmxDeviceQuality;
    function GetBaudrate: longword;
    procedure SetBaudrate(const Value: longword);
    procedure SetChannelNumber(const Value: Byte);
    procedure SetMaxOutlay(const Value: Single);
    function GetOutlay: Single;
    function GetVolume: Double;
    procedure SetStartStopTime(const Value: Double);
    procedure SetIntegralCounter(const Value: longword);
    procedure SetIntegralValue(const Value: Double);
    procedure SetStarted(const AValue: Boolean);
    procedure SetMaxPhysicalValue(const Value: Double);
    procedure SetMinPhysicalValue(const Value: Double);
    procedure SetTopOutlay(const Value: Single);
    procedure SetMinOutlay(const Value: Single);
    function GetMaxPhysicalValue: Double;
    function GetMinPhysicalValue: Double;
    function GetRAWValue: Double;
    function GetAddr: integer;override;
    procedure SetAddr(const Value: integer);override;
    function GetPort: integer;override;
    procedure SetPort(const Value: integer);override;
    procedure SetMaxChannels(const Value: byte);override;
    procedure SetCaption(const Value: String);
  protected
    function GetInfo: String;override;

  public
    settings:TLinearCalibrationSettings;

     //Валидность значения
    property Quality: TFmxDeviceQuality read GetQuality;


    // Значение вольтметра в вольтах или амперметра в милиамперах с учетом градуировки.
    property Value: Double read GetPhysicalValue;

    property RawValue: Double read GetRawValue;

    property MinPhysicalValue: Double read GetMinPhysicalValue write SetMinPhysicalValue;

    property MaxPhysicalValue: Double read GetMaxPhysicalValue write SetMaxPhysicalValue;

    //Среднее за проливку Значение вольтметра в вольтах или амперметра в милиамперах с учетом градуировки.
    property MeanPhysicalValue: Double read GetMeanValue;

    // channel_number - номер канала на модуле (от 0 до 7).
    //InputType - тип входа. 0 - напряжение, 1- ток
    constructor CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer; address: integer;BR: Cardinal; channel_number: Byte; AModuleType:TFmxModuleType; InputType:byte; _typeofprotocol:TTypeOfProtocol;InputReg:Word);

    // channel_number - номер канала на модуле (от 0 до 7).
    //InputType - тип входа. 0 - напряжение, 1- ток
    //constructor CreateOnModuleFastwelUI(address: Byte;BR: Cardinal; channel_number: Byte; InputType:byte);

    { ===== UpdateStatus =====
    Обновляет статус модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function UpdateStatus: Boolean;

    { ===== UpdateMeans =====
    Обновляет средние значения на входах модуля.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    - если используется своя железяка, а не fastwel
    }
    function UpdateMeans: boolean;

    function SetupCount(): Boolean;
    { ===== StartCount =====
    Программный запуск стчета.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом.
    }
    function StartCount(aInterval:integer=0): Boolean;

    { ===== StopCount =====
    Программная остановка счета.
    Возвращает false в случае:
    - функция вызвана не из потока работы с COM-портом;
    - произошла ошибка при работе с COM-портом;
    }
    function StopCount: Boolean;


    property Addr:integer read GetAddr write SetAddr;

    property PortNumber:integer read GetPort write SetPort;

    property Baudrate:longword read GetBaudrate write SetBaudrate;

    property ChannelNumber: Byte read FChannelNumber write SetChannelNumber;

    property Outlay:Single read GetOutlay;

    property Volume:Double read GetVolume;

    property StartStopTime:Double read FStartStopTime write SetStartStopTime;

    property IntegralValue:Double read FIntegralValue write SetIntegralValue;//интегральное значение

    property IntegralCounter:longword read FIntegralCounter write SetIntegralCounter;//количество значений в FIntegralValue

    property Started:Boolean read FStarted write SetStarted;

    property TopOutlay:Single read FTopOutlay write SetTopOutlay;

    property MinOutlay: Single read FMinOutlay write SetMinOutlay;

    property MaxOutlay: Single read FMaxOutlay write SetMaxOutlay;

    property Caption:String read FCaption write SetCaption;

  end;



//============================================================================================================


function GetCalibrationKoeff(inValue:Double; Table:TCalibrationPointsArray):double;

var
  // Менеджер устройств, используемый для создания модулей и назначения их устройствам.
  MainDeviceManager: TFmxDeviceManager;
  DigitalDeviceManager: TFmxDeviceManager;

implementation

uses
  SysUtils;//,uMain;


//============================================================================================================

{ ===== CreateDeviceManagerIfNotCreated =====
Создает DeviceManager, если он еще не создан. Необходимо вызывать эту процедуру в каждом конструкторе каждого
устройства до обращения к DeviceManager.
}
procedure CreateMainDeviceManagerIfNotCreated(AHost:String;APort:Word);
begin
  if MainDeviceManager = nil then
     MainDeviceManager := TFmxDeviceManager.Create(AHost,APort)
  else begin
     if AHost<>'' then
     begin
        MainDeviceManager.ModbusTCPHost:=AHost;
        MainDeviceManager.ModbusTCPPort:=APort;
     end;
  end;
end;

//============================================================================================================

{ ===== CreateDeviceManagerIfNotCreated =====
Создает DeviceManager, если он еще не создан. Необходимо вызывать эту процедуру в каждом конструкторе каждого
устройства до обращения к DeviceManager.
}
procedure CreateDigitalDeviceManagerIfNotCreated(AHost:String;APort:Word);
begin
  if DigitalDeviceManager = nil then
     DigitalDeviceManager := TFmxDeviceManager.Create(AHost,APort)
  else begin
     if AHost<>'' then
     begin
        DigitalDeviceManager.ModbusTCPHost:=AHost;
        DigitalDeviceManager.ModbusTCPPort:=APort;
     end;
  end;
end;

//============================================================================================================
//-------------------- TFmxDeviceBlcedValve --------------------
//============================================================================================================

function TFmxDeviceBlcedValve.GetOpened: Boolean;
begin
  if not Assigned(Module) then Exit;
  Module.LastDevice:=self;
  if WithInput then
    case ModuleType of
      mtModbusD: Result := TFmxModuleModbusD(Module).InputValues[StartInputNumber];
      mtBIO: Result := TFmxModuleBIO(Module).InputValues[StartInputNumber];
      mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).InputValues[StartInputNumber];
      mtSuperBIO: Result := TFmxModuleSuperBIO(Module).InputValues[StartInputNumber];
      mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).InputValues[StartInputNumber]=100;
      mtValve:   Result := TFmxModuleValve(Module).InputValues[StartInputNumber];
      else Result := false;
    end
  else
    case ModuleType of
      mtModbusD: Result := TFmxModuleModbusD(Module).OutputValues[StartOutputNumber];
      mtBIO: Result := TFmxModuleBIO(Module).OutputValues[StartOutputNumber];
      mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).OutputValues[StartOutputNumber];
      mtSuperBIO: Result := TFmxModuleSuperBIO(Module).OutputValues[StartOutputNumber];
      mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).OutputValues[StartInputNumber]=100;
      mtValve:    Result := TFmxModuleValve(Module).OutputValues[StartOutputNumber];
      else Result := false;
    end;
  Module.LastDevice:=nil;
end;

function TFmxDeviceBlcedValve.GetStopInputNumber: Byte;
begin
  if TwoSwitch then
     result:=FStopInputNumber
  else
     result:=FStartInputNumber;
end;

function TFmxDeviceBlcedValve.GetStopOutputNumber: Byte;
begin
  if TwoSwitch then
     result:=FStopOutputNumber
  else
     result:=FStartOutputNumber;
end;

//============================================================================================================

constructor TFmxDeviceBlcedValve.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte; BR: Cardinal; output_number: byte; input_number: byte; with_input:boolean; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;
  FTwoSwitch:=False;
  ModuleType := AModuleType;
  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  if AModuleType=mtBIO then
  begin
    if output_number < 2 then StartOutputNumber := output_number
    else StartOutputNumber := 0;
    if input_number < 2 then StartInputNumber := input_number
    else StartInputNumber := 0;
  end
  else if AModuleType=mtSuperBIO then
  begin
    if output_number < 13 then StartOutputNumber := output_number
    else StartOutputNumber := 0;
  end
  else if AModuleType=mtHSC_CTRL then
  begin
    if output_number < MaxChannels then StartOutputNumber := output_number
    else StartOutputNumber := 0;
  end
  else if AModuleType=mtModbusD then
  begin
    StartOutputNumber := output_number;
    StartInputNumber := input_number;
  end
  else if AModuleType=mtValve then begin
    if (output_number > cMinValve_IO_PinNumber) and (output_number < 9) then StartOutputNumber := output_number
    else StartOutputNumber := 6;
  end;
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
  // 20.05.2009 -- при создании модуля по умолчанию это клапан.
  FUnoperatedPump := false;
end;

//============================================================================================================
(*
constructor TFmxDeviceBlcedValve.CreateOnModuleValve(address: Byte;BR: Cardinal;  output_number: Byte);
begin
  inherited Create;

  ModuleType := mtValve;
  if (output_number > cMinValve_IO_PinNumber) and (output_number < 9) then OutputNumber := output_number
  else OutputNumber := 6;

  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(Valve,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
  // 20.05.2009 -- при создании модуля по умолчанию это клапан.
  FUnoperatedPump := false;
end;
*)
//============================================================================================================

function TFmxDeviceBlcedValve.Close: Boolean;
var s:String;
//    prevstate:boolean;
begin
  if not Assigned(Module) then Exit;
  try
    Module.LastDevice:=self;
//    case ModuleType of
//      mtModbusD: prevstate:=TFmxModuleModbusD(Module).OutputValues[StartOutputNumber];
//      mtBIO: prevstate:=TFmxModuleBIO(Module).OutputValues[StartOutputNumber];
//      mtSuperBIO: prevstate:=TFmxModuleSuperBIO(Module).OutputValues[StartOutputNumber];
//      mtHSC_CTRL: prevstate:=TFmxModuleHsc_Ctrl(Module).OutputValues[StartOutputNumber]=100;
//      mtHSC_FCD: prevstate:=TFmxModuleHSC_FCD(Module).OutputValues[StartOutputNumber];
//      mtValve: prevstate:=TFmxModuleValve(Module).OutputValues[StartOutputNumber];
//      else
//        prevstate:=true;
//    end;
    //если было включено
//    if prevstate then
    begin
      if Assigned(Host) then
         s:=Host.Caption;

      if Assigned(AddToWorkLogProc) then
       if IsUnoperatedPump then AddToWorkLogProc(DeviceName+': Остановка...',awlHard)
       else AddToWorkLogProc(DeviceName+': Закрытие...',awlHard);

      //отключаеем стартовый выход
      case ModuleType of
        mtModbusD: Result := TFmxModuleModbusD(Module).SetOutput(StartOutputNumber, false);
        mtBIO: Result := TFmxModuleBIO(Module).SetOutput(StartOutputNumber, false);
        mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).SetOutput(StartOutputNumber, false);
        mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).SetOutput(StartOutputNumber, false);
        mtSuperBIO: Result := TFmxModuleSuperBIO(Module).SetOutput(StartOutputNumber, false);
        mtValve: Result := TFmxModuleValve(Module).SetOutput(StartOutputNumber, false);
        else Result := false;
      end;

      //включаем стоповый выход
      if TwoSwitch then
      case ModuleType of
        mtModbusD: Result := TFmxModuleModbusD(Module).SetOutput(StopOutputNumber, True);
        mtBIO: Result := TFmxModuleBIO(Module).SetOutput(StopOutputNumber, True);
        mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).SetOutput(StopOutputNumber, True);
        mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).SetOutput(StopOutputNumber, True);
        mtSuperBIO: Result := TFmxModuleSuperBIO(Module).SetOutput(StopOutputNumber, True);
        mtValve: Result := TFmxModuleValve(Module).SetOutput(StopOutputNumber, True);
        else Result := false;
      end;

    end;
    finally
     Module.LastDevice:=nil;
    end;
end;

//============================================================================================================

function TFmxDeviceBlcedValve.Open: Boolean;
var s:String;
    prevstate:boolean;
begin
  if not Assigned(Module) then Exit;
  try
    Module.LastDevice:=self;
//    case ModuleType of
//      mtHSC_FCD: prevstate:=TFmxModuleHSC_FCD(Module).OutputValues[StartOutputNumber];
//      mtModbusD: prevstate:=TFmxModuleModbusD(Module).OutputValues[StartOutputNumber];
//      mtBIO: prevstate:=TFmxModuleBIO(Module).OutputValues[StartOutputNumber];
//      mtSuperBIO: prevstate:=TFmxModuleSuperBIO(Module).OutputValues[StartOutputNumber];
//      mtHSC_CTRL: prevstate:=TFmxModuleHsc_Ctrl(Module).OutputValues[StartOutputNumber]=100;
//      mtValve: prevstate:=TFmxModuleValve(Module).OutputValues[StartOutputNumber];
//      else
//        prevstate:=false;
//    end;
    //если было включено
//    if not prevstate then
//    begin
    if Assigned(AddToWorkLogProc) then
     if IsUnoperatedPump then AddToWorkLogProc(DeviceName+': Запуск...',awlHard)  // 20.05.2009
     else AddToWorkLogProc(DeviceName+': Открытие...',awlHard);

    //выключаем стоповый выход
    if TwoSwitch then
      case ModuleType of
        mtModbusD: Result := TFmxModuleModbusD(Module).SetOutput(StopOutputNumber, False);
        mtBIO: Result := TFmxModuleBIO(Module).SetOutput(StopOutputNumber, False);
        mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).SetOutput(StopOutputNumber, False);
        mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).SetOutput(StopOutputNumber, False);
        mtSuperBIO: Result := TFmxModuleSuperBIO(Module).SetOutput(StopOutputNumber, False);
        mtValve: Result := TFmxModuleValve(Module).SetOutput(StopOutputNumber, False);
        else Result := false;
      end;


    //Включаем стартовый выход
    case ModuleType of
      mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).SetOutput(StartOutputNumber, true);
      mtModbusD: Result := TFmxModuleModbusD(Module).SetOutput(StartOutputNumber, true);
      mtBIO: Result := TFmxModuleBIO(Module).SetOutput(StartOutputNumber, true);
      mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).SetOutput(StartOutputNumber, true);
      mtSuperBIO: Result := TFmxModuleSuperBIO(Module).SetOutput(StartOutputNumber, true);
      mtValve: Result := TFmxModuleValve(Module).SetOutput(StartOutputNumber, true);
      else Result := false;
    end;
//    end;
  finally
    Module.LastDevice:=nil;
  end;
end;

//============================================================================================================

function TFmxDeviceBlcedValve.UpdateStatus: Boolean;
begin
  if not Assigned(Module) then Exit;
  try
    Module.LastDevice:=self;
    case ModuleType of
      mtModbusD:   Result := TFmxModuleModbusD(Module).UpdateStatus;
      mtBIO: Result := TFmxModuleBIO(Module).UpdateStatus;
      mtSuperBIO: Result := TFmxModuleSuperBIO(Module).UpdateStatus;
      mtValve: Result := TFmxModuleValve(Module).UpdateStatus;
      mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).UpdateStatus;
      mtHSC_FCD: begin
            TFmxModuleHSC_FCD(Module).SlivChannel:=StartOutputNumber;
            Result := TFmxModuleHSC_FCD(Module).UpdateOutputs;
        end
      else Result := false;
    end;
 finally
    Module.LastDevice:=nil;
 end;
end;


//============================================================================================================
//-------------------- TFmxDeviceElectricValve --------------------
//============================================================================================================

function TFmxDeviceElectricValve.GetClosing: boolean;
begin
   Result := False;
   if not Assigned(Module) then Exit;
   case ModuleType of
   mtValve: begin
              result:=TFmxModuleValve(Module).Closing[ValveNumber];
            end;
   mtHSC_Ctrl: begin
              result:=TFmxModuleHSC_Ctrl(Module).Closing[ValveNumber];
            end;
   mtModbusA,
   mtLogoDAC,
   mtDAC_I702X,
   mtRT2:begin
            if RemainTime>0 then
               Result := not CommandDirection;
         end;
   end;
end;

function GetTickCount:Cardinal;
begin
 result:=TThread.GetTickCount;
end;

function TFmxDeviceElectricValve.GetCurCommandTime: Single;
var CurTime:Single;
begin
  CurTime:=(GetTickCount()-FStartCommandTickCount) / 1000;
  if CurTime<FFullCommandTime then
     result:=CurTime
  else
     result:=FFullCommandTime;
end;

function TFmxDeviceElectricValve.GetDirection: TElectricValveDirection;
begin
   Result := dStoped;
   if not Assigned(Module) then Exit;
   case ModuleType of
   mtModbusA: begin
               if RemainTime>0 then
               begin
                 if CommandDirection then
                  Result := dOpening
                else
                  Result := dClosing;

               end
               else begin
                  Result := dStoped;
               end;
            end;
   mtValve: begin
              // Если открываем
              if TFmxModuleValve(Module).OutputValues[ValveNumber*2] then
              begin
                // Если и закрываем
                if TFmxModuleValve(Module).OutputValues[ValveNumber*2 + 1] then
                begin
                  //Нештатная ситуация
                  TFmxModuleValve(Module).OutputValues[ValveNumber*2]:=False;
                  TFmxModuleValve(Module).OutputValues[ValveNumber*2 + 1]:=False;
                  Result := dIncorrect;
                end
                else begin
                  //если сработал конечник открытия
                  if TFmxModuleValve(Module).InputValues[ValveNumber*2] then
                  begin
                    Result := dStoped;
                    //Снимаем питание
                    TFmxModuleValve(Module).OutputValues[ValveNumber*2]:=False;
                  end
                  else
                     Result := dOpening
                end
              end
              else begin
                //Если не открываем, закрываем?
                if TFmxModuleValve(Module).OutputValues[ValveNumber*2 + 1] then
                begin
                  //Закрываем
                  if TFmxModuleValve(Module).InputValues[ValveNumber*2 + 1] then
                  begin
                    //Если срабюотал концевик закрытия
                    Result := dStoped;
                    //Снимаем питание
                    TFmxModuleValve(Module).OutputValues[ValveNumber*2 + 1]:=False;
                  end
                  else
                    Result := dClosing;
                end;
              end;
            end;
   mtHSC_Ctrl: begin
                  if TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber] in [0..100] then
                  begin
                    //Если разница менее 3% - считаем, что позиция достигнура -
                    //TODO: возможно в дальнейшем ввести свойство погрешности
                    if (ABS(TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber]-
                       TFmxModuleHSC_Ctrl(Module).OutputValues[ValveNumber])<3) or
                       (TFmxModuleHSC_Ctrl(Module).OutputValues[ValveNumber]>cHSC_CTRL_OpenPosition)
                    then
                      Result := dStoped
                    else begin
                      if TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber]>
                         TFmxModuleHSC_Ctrl(Module).OutputValues[ValveNumber] then
                           Result := dClosing
                      else if TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber]<
                         TFmxModuleHSC_Ctrl(Module).OutputValues[ValveNumber] then
                           Result := dOpening
                    end;
                  end
                  else
                    Result := dIncorrect;
              end;
   mtLogoDAC,
   mtDAC_I702X,
   mtRT2:begin
            if CurComandTime<FullCommandTime then
            begin
               if CommandDirection then
                  Result := dOpening
               else
                   Result := dClosing;
           end
         end;
   end;
end;

//Для регулируемой задвижки внешняя шкала 0..100
function TFmxDeviceElectricValve.GetInputPos: Double;
begin
   result:=0;
   if not Assigned(Module) then Exit;
   case ModuleType of
   mtModbusA:  result := ConvertScale(TFmxModuleModbusA(Module).InputValues[ValveInputNumber],MinInput,MaxInput,0,100);
   mtValve: result := TFmxModuleValve(Module).ValvePositions[ValveNumber] / 10;
   mtHSC_CTRL: result := TFmxModuleHsc_Ctrl(Module).InputValues[ValveNumber];
   mtDAC_I702X: result := ConvertScale(TFmxModuleDAC_I702X(Module).Value[ValveNumber],MinInput,MaxInput,0,100);
   mtLogoDAC: result:=ConvertScale(TFmxModuleLogoDAC(Module).DAC[ValveNumber],MinInput,MaxInput,0,100);
   mtRT2: result := ConvertScale(TFmxModuleRT2(Module).DAC[ValveNumber],MinInput,MaxInput,0,100);
   end;
end;

function TFmxDeviceElectricValve.GetOpening: boolean;
begin
   case ModuleType of
   mtValve: begin
              result:=TFmxModuleValve(Module).Opening[ValveNumber];
            end;
   mtHSC_Ctrl: begin
              result:=TFmxModuleHSC_Ctrl(Module).Opening[ValveNumber];
            end;
   mtModbusA,
   mtLogoDAC,
   mtDAC_I702X,
   mtRT2:begin
            if RemainTime>0 then
               Result := CommandDirection
            else
               Result := False;
         end;
   end;
end;

//============================================================================================================
{
Для задвижек, не имеющих обратной связи, текущая позиция рассчитывается как,
Позиция расчетная на конец завершения операции - FinalPos
Позиция на начало выполнения - StartedPos
Разница позиций по модулю -DeltaPos (FinalPos-StartedPos)
Время выполнения всей операции - FullCommandTime
Текущее время выполнения - CurComandTime - не более FullCommandTime
Текущая позиция:  StartedPos +/- DeltaPos * (CurComantTime/FullCommandTime)
}
function TFmxDeviceElectricValve.GetPosition: Double;
var PrevMoving:boolean;
begin
   PrevMoving:=moving;
   moving:=(TimeToSwitch>0) and (Direction<>dStoped) and (FullCommandTime>0);
   result:=InputPos;
   //если время установки задвижки не равно 0
   if moving then
   begin
      //стремимся к result
      if CommandDirection then
      begin
         //Открываемся
          if FullCommandTime>0 then
             result:=StartedPos+DeltaPos*(CurComandTime/FullCommandTime);
      end
      else begin
         //Закрываемся
          if FullCommandTime>0 then
             result:=StartedPos-DeltaPos*(CurComandTime/FullCommandTime);
      end;
   end;
end;

function TFmxDeviceElectricValve.GetRemainTime: Single;
begin
  result:=FullCommandTime-CurComandTime;
end;

//============================================================================================================

function TFmxDeviceElectricValve.GetStatus: TElectricValveStatus;
begin
   case ModuleType of
    mtValve: begin
      if TFmxModuleValve(Module).InputValues[ValveNumber*2] then
        if TFmxModuleValve(Module).InputValues[ValveNumber*2 + 1] then
          Result := sIncorrect
        else
          Result := sOpened
      else
        if TFmxModuleValve(Module).InputValues[ValveNumber*2 + 1] then
          Result := sClosed
        else
          Result := sIntermediate
      end;
    mtHSC_Ctrl: begin
      if TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber]>=100 then
      begin
        if TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber]>100 then
          Result := sIncorrect
        else
          Result := sOpened
      end
      else
        if TFmxModuleHSC_Ctrl(Module).InputValues[ValveNumber]=0 then
          Result := sClosed
        else
          Result := sIntermediate
      end;

     mtModbusA,
     mtLogoDAC,
     mtDAC_I702X,
     mtRT2: begin
         if not Moving then
         begin
           if GetPosition()>=99.9 then
              Result := sOpened
           else if GetPosition()<=0.01 then
              Result := sClosed
           else
              Result := sIntermediate;
         end
         else begin
           if CommandDirection then
              Result := sOpening
           else
              Result := sClosing;
         end;
      end;
   end;

end;

function TFmxDeviceElectricValve.GetTimeToSwitch: integer;
begin
  if ModuleType in [TFmxModuleType.mtValve,TFmxModuleType.mtHSC_CTRL] then
     result:=0
  else
     //Если этот тип использует программную функцию расчета текущей позиции
     result:=FTimeToSwitch;
end;

//============================================================================================================

constructor TFmxDeviceElectricValve.CreateOnModuleValve(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;  valve_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;
(*
   case ModuleType of
   mtModbusA:  result := TFmxModuleModbusA(Module).InputValues[ValveInputNumber] * InputKoeff;
   mtValve: result := TFmxModuleValve(Module).ValvePositions[ValveNumber] / 10;
   mtDAC_I702X: result := TFmxModuleDAC_I702X(Module).Value[ValveNumber] * 10;
   mtLogoDAC: result:=TFmxModuleLogoDAC(Module).DAC[ValveNumber]/10;
   mtRT2: result := TFmxModuleRT2(Module).DAC[ValveNumber]/10;
   end;

*)  FullCommandTime:=0;
  ModuleType := AModuleType;
  if ModuleType=mtValve then
  begin
    if valve_number <= 2 then ValveNumber := valve_number
    else ValveNumber := 0;
  end
  else if ModuleType=mtRT2 then
  begin
    if valve_number <= 1 then ValveNumber := valve_number
    else ValveNumber := 0;
  end
  else if ModuleType=mtHSC_CTRL then
  begin
    if valve_number <= 23 then ValveNumber := valve_number
    else ValveNumber := 0;
  end
  else if ModuleType=mtModbusA then
  begin
    if valve_number <= 16 then ValveNumber := valve_number
    else ValveNumber := 0;
  end
  else if ModuleType=mtDAC_I702X then
  begin
    ValveNumber := valve_number;
  end
  else begin
    ValveNumber := valve_number;
  end;
  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

//============================================================================================================

function TFmxDeviceElectricValve.CalibrateValves: Boolean;
begin
   case ModuleType of
    mtValve: begin
      if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Запуск градуировки...',awlHard);
      Result := TFmxModuleValve(Module).CalibrateValves;
    end;
   end;
end;

//============================================================================================================

function TFmxDeviceElectricValve.MoveValve(_position: Double): Boolean;
begin
 try

  Module.LastDevice:=self;
  TargetPos:=_position;
  if (TimeToSwitch>0) and (TargetPos<>Position) then
  begin
       //Запоминаем направление
       StartedPos:=Position;
       if (TargetPos>StartedPos) then
           DeltaPos:=TargetPos-Position
       else
           DeltaPos:=Position-TargetPos;
       CommandDirection:=InputPos<TargetPos;
  end;
  if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName +': Установка положения ' + FloatToStr(_position) +'%',awlHard);
  begin
     //отрабатываем команду
//     case ModuleType of
//     mtModbusA: Result := TFmxModuleModbusA(Module).SetOutput( ValveNumber, Round(_position*OutputKoeff));
//     mtValve: Result := TFmxModuleValve(Module).MoveValve( ValveNumber, Round(_position*10) );
//     mtDAC_I702X: begin TFmxModuleDAC_I702X(Module).Value[ValveNumber]:=_position/10.0; result:=True;  end;
//     mtLogoDAC: begin TFmxModuleLogoDAC(Module).DAC[ValveNumber]:=_position*10; result:=True;  end;
//     mtRT2:       begin TFmxModuleRT2(Module).DAC[ValveNumber]:=_position*10; result:=True; end;
//     end;
     case ModuleType of
     mtModbusA: Result := TFmxModuleModbusA(Module).SetOutput( ValveNumber, ConvertScale(_position, 0, 100, MinOutput, MaxOutput));
     mtValve: Result := TFmxModuleValve(Module).MoveValve( ValveNumber, Round(_position*10) );
     mtHSC_CTRL:   Result := TFmxModuleHSC_CTRL(Module).MoveValve( ValveNumber, Round(_position) );
     mtDAC_I702X: begin TFmxModuleDAC_I702X(Module).Value[ValveNumber]:=ConvertScale(_position, 0, 100, MinOutput, MaxOutput); result:=True; end;
     mtLogoDAC:   begin TFmxModuleLogoDAC(Module).DAC[ValveNumber]:=ConvertScale(_position, 0, 100, MinOutput, MaxOutput); result:=True;end;
     mtRT2:       begin TFmxModuleRT2(Module).DAC[ValveNumber]:=ConvertScale(_position, 0, 100, MinOutput, MaxOutput); result:=True;end;
     end;
  end;


 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================



procedure TFmxDeviceElectricValve.SetCommandDirection(const Value: Boolean);
begin
  FCommandDirection := Value;
end;

procedure TFmxDeviceElectricValve.SetDeltaPos(const Value: double);
begin
  FDeltaPos := Value;
  if Value>0 then FullCommandTime:=(TimeToSwitch * (Value/100));
end;

procedure TFmxDeviceElectricValve.SetFullCommandTime(
  const Value: Single);
begin
  FFullCommandTime := Value;
  FStartCommandTickCount:=GetTickCount();
  FFullCommandTickCount:=FStartCommandTickCount+Round(Value*1000);
end;



procedure TFmxDeviceElectricValve.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Module) then
  case ModuleType of
    mtHSC_CTRL: TFmxModuleHsc_Ctrl(Module).MaxChannels:=Value;
  end;
end;

procedure TFmxDeviceElectricValve.SetMoving(const Value: boolean);
begin
  FMoving := Value;
end;

procedure TFmxDeviceElectricValve.SetStartedPos(const Value: double);
begin
  FStartedPos := Value;
end;

procedure TFmxDeviceElectricValve.SetTargetPos(const Value: double);
begin
  FTargetPos := Value;
end;

procedure TFmxDeviceElectricValve.SetTimeToSwitch(const Value: integer);
begin
  FTimeToSwitch := Value;
end;




procedure TFmxDeviceElectricValve.SetValveInputNumber(const Value: Byte);
begin
  FValveInputNumber := Value;
end;

procedure TFmxDeviceElectricValve.SetValveNumber(const Value: Byte);
begin
  FValveNumber := Value;
end;

function TFmxDeviceElectricValve.StopValve: Boolean;
begin
 try
  Module.LastDevice:=self;
  if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Остановка',awlHard);
  case ModuleType of
   mtValve:  Result := TFmxModuleValve(Module).StopValve(ValveNumber);
   mtHSC_CTRL: Result := TFmxModuleHSC_Ctrl(Module).StopValve(ValveNumber);
   mtModbusA: Result := TFmxModuleModbusA(Module).SetOutput( ValveNumber, Position);
   mtDAC_I702X: begin TFmxModuleDAC_I702X(Module).Value[ValveNumber]:=Position/10.0; result:=True;  end;
   mtLogoDAC: begin TFmxModuleLogoDAC(Module).DAC[ValveNumber]:=Position*10; result:=True;  end;
   mtRT2:       begin TFmxModuleRT2(Module).DAC[ValveNumber]:=Position*10; result:=True; end;
  end;

 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceElectricValve.UpdateStatus: Boolean;
begin
 try
  Module.LastDevice:=self;
  case ModuleType of
  mtModbusA: Result := TFmxModuleModbusA(Module).UpdateStatus;
  mtValve:  Result := TFmxModuleValve(Module).UpdateStatus;
  mtHSC_CTRL:  Result := TFmxModuleHSC_Ctrl(Module).UpdateStatus;
  mtDAC_I702X:  Result := TFmxModuleDAC_I702X(Module).UpdateStatus;
  mtLogoDAC: TFmxModuleLogoDAC(Module).UpdateStatus;
  mtRT2:  Result := TFmxModuleRT2(Module).UpdateStatus;
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceFCD --------------------
//============================================================================================================

function TFmxDeviceFCD.GetFCDNumber: Byte;
begin
    result:=F_FCDNumber;
    case ModuleType of
      mtFCD,
      mtFCD2:  Result := F_FCDNumber;
      mtHSC_FCD:  Result := F_FCDNumber;
    end;
end;

function TFmxDeviceFCD.GetInPipeTime: real;
begin
  case ModuleType of
    mtFCD:Result := TFmxModuleFCD(Module).InTanktime;
    mtFCD2:Result := TFmxModuleFCD2(Module).InTankTime;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).InTankTime;
  end;
end;

function TFmxDeviceFCD.GetInTankPosition: Boolean;
begin
    case ModuleType of
      mtFCD:  Result := TFmxModuleFCD(Module).InTankPositions[FCDNumber];
      mtFCD2:  Result := TFmxModuleFCD2(Module).InTankPositions[FCDNumber];
      mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).InTankPositions[FCDNumber];
    end;
end;

//============================================================================================================

function TFmxDeviceFCD.GetSwitchingTimeToPipe(Idx: integer): real;
begin
  Result := 0;
  if Assigned(Module) then
  case ModuleType of
    mtFCD2:Result := TFmxModuleFCD2(Module).LastSwitchingTimeToTank;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).SwitchingTimeToPipe[Idx];
  end;
end;

function TFmxDeviceFCD.GetSwitchingTimeToTank(Idx: integer): real;
begin
  Result := 0;
  if Assigned(Module) then
  case ModuleType of
    mtFCD2:Result := TFmxModuleFCD2(Module).LastSwitchingTimeToTank;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).SwitchingTimeToTank[Idx];
  end;
end;

function TFmxDeviceFCD.GetSynchroChannel: byte;
begin
  result:=FSynchroChannel;
end;

//============================================================================================================
function TFmxDeviceFCD.GetInTankTime: real;
begin
    case ModuleType of
      mtFCD:Result := OfflineInTankTime;
      mtFCD2:Result := TFmxModuleFCD2(Module).InTankTime;
      mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).InTankTime;
     end;
  if Result = 0 then Result := 1;
end;

//============================================================================================================
function TFmxDeviceFCD.Gett1: real;
begin
  case ModuleType of
    mtFCD:Result := 0;
    mtFCD2:Result := TFmxModuleFCD2(Module).t1;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).t1;
  end;
end;

//============================================================================================================
function TFmxDeviceFCD.Gett2: real;
begin
  case ModuleType of
    mtFCD:Result := 0;
    mtFCD2:Result := TFmxModuleFCD2(Module).t2;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).t2;
  end;
end;

//============================================================================================================
function TFmxDeviceFCD.Gett3: real;
begin
  case ModuleType of
    mtFCD:Result := 0;
    mtFCD2:Result := TFmxModuleFCD2(Module).t3;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).t3;
  end;
end;

//============================================================================================================
function TFmxDeviceFCD.Gett4: real;
begin
  case ModuleType of
    mtFCD:Result := 0;
    mtFCD2:Result := TFmxModuleFCD2(Module).t4;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).t4;
  end;
end;
function TFmxDeviceFCD.GetTimeToPipe: real;
begin
  result:=GetSwitchingTimeToPipe(FCDNumber);
end;

function TFmxDeviceFCD.GetTimeToTank: real;
begin
  result:=GetSwitchingTimeToTank(FCDNumber);
end;

//============================================================================================================

constructor TFmxDeviceFCD.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;  AFCD_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;

  if AFCD_number <= 2 then FCDNumber := AFCD_number
  else FCDNumber := 0;
  ModuleType := AModuleType;

  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

//============================================================================================================
(*
constructor TFmxDeviceFCD.CreateOnModule2(address: Byte;BR: Cardinal;  FCD_number: Byte);
begin
  inherited Create;

  if FCD_number <= 2 then FCDNumber := FCD_number
  else FCDNumber := 0;
  ModuleType := FCD2;

  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(FCD2,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;
  *)
//============================================================================================================

procedure TFmxDeviceFCD.SetActiveChannel;
begin
    case ModuleType of
      mtHSC_FCD: begin
        TFmxModuleHSC_FCD(Module).SynchroChannel:=SynchroChannel;
        TFmxModuleHSC_FCD(Module).UpdateActiveChannelCOM;
      end;
    end;
end;

procedure TFmxDeviceFCD.SetFCDNumber(const Value: Byte);
begin
    F_FCDNumber:=Value;
    case ModuleType of
      mtFCD: begin
        if Value in [0..2] then F_FCDNumber:=Value else F_FCDNumber:=0;
        TFmxModuleFCD(Module).ActiveChannel:=F_FCDNumber;
      end;
      mtFCD2: begin
        if Value in [0..2] then F_FCDNumber:=Value else F_FCDNumber:=0;
        TFmxModuleFCD2(Module).ActiveChannel:=F_FCDNumber;
      end;
      mtHSC_FCD: begin
        if Value in [0..3] then F_FCDNumber:=Value else F_FCDNumber:=0;
        TFmxModuleHSC_FCD(Module).ActiveChannel:=F_FCDNumber;
      end;
    end;
end;

procedure TFmxDeviceFCD.SetSynchroChannel(const Value: byte);
begin
  FSynchroChannel := Value;
end;

function TFmxDeviceFCD.Switch(in_tank: Boolean): Boolean;
begin
 try
  Module.LastDevice:=self;
  if Assigned(AddToWorkLogProc) then
    if in_tank then AddToWorkLogProc(DeviceName+': Переключение на весовой бак',awlHard)
    else AddToWorkLogProc(DeviceName+': Переключение на пролетную трубу',awlHard);

  if in_tank then
     OfflineInTankTimeCounter:=GetTickCount+60000
  else
     OfflineInTankTimeCounter:=0;

  case ModuleType of
    mtFCD:Result := TFmxModuleFCD(Module).SwitchFCD(FCDNumber, in_tank);
    mtFCD2:Result := TFmxModuleFCD2(Module).SwitchFCD(FCDNumber, in_tank);
    mtHSC_FCD:Result := TFmxModuleHSC_FCD(Module).SwitchFCD(FCDNumber, in_tank);
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceFCD.SwitchWithTimer(time: Word): Boolean;
begin
 try
  Module.LastDevice:=self;
  //фиксируем начало переключения запоминаем время окончания + 2 секунды
  OfflineInTankTimeCounter:=GetTickCount+time*100+2000;
  //сохраняем время над баком
  OfflineInTankTime:=time/10;
  if Assigned(AddToWorkLogProc) then
    AddToWorkLogProc(DeviceName +': Переключение на бак, длительностью ' + FloatToStr(time/10) + ' сек.',awlHard);
  case ModuleType of
    mtFCD:Result := TFmxModuleFCD(Module).SwitchFCDWithTimer(FCDNumber, time);
    mtFCD2:Result := TFmxModuleFCD2(Module).SwitchFCDWithTimer(FCDNumber, time);
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).SwitchFCDWithTimer(FCDNumber, time);
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceFCD.SwitchWithSensor(time: Word): Boolean;
begin
 try
  Module.LastDevice:=Self;
  OfflineInTankTime:=time;
  if Assigned(AddToWorkLogProc) then
    AddToWorkLogProc(DeviceName + ': Переключение по датчикам.',awlHard);
  case ModuleType of
    mtFCD:Result := false;
    mtFCD2:Result := TFmxModuleFCD2(Module).SwitchFCDWithSensors(FCDNumber,time);
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).SwitchFCDWithSensors(FCDNumber,time);
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceFCD.UpdateStatus: Boolean;
begin
 try
  Module.LastDevice:=self;
  case ModuleType of
    mtFCD: Result := TFmxModuleFCD(Module).UpdateStatus;
    mtFCD2: Result := TFmxModuleFCD2(Module).UpdateStatus;
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).UpdateStatus;
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

function TFmxDeviceFCD.UpdateTimeInTank: Boolean;
begin
 try
  Module.LastDevice:=self;
  case ModuleType of
    mtHSC_FCD:  Result := TFmxModuleHSC_FCD(Module).UpdateTimeInTank;
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceFlowmeter --------------------
//============================================================================================================

function GetCalibrationKoeff(inValue:Double; Table:TCalibrationPointsArray):double;
var
  cur_discharge: Double;
  i: Byte;
  point1: Byte;
  point2: Byte;
  table_length: Byte;
begin
  Result := 1;
  cur_discharge:=inValue;
  table_length := Length(Table);
  if table_length > 0 then
    if table_length = 1 then Result := table[0].Coefficient
    else begin

      // Поиск в калибровочной таблице отрезка, в который входит текущая частота.
      point1 := 0;
      point2 := table_length-1;
      try
        for i := 1 to table_length-1 do
        begin
            if (cur_discharge >= table[i-1].WaterDischarge) and (cur_discharge <= table[i].WaterDischarge) then
            begin
              point1 := i-1;
              point2 := i;
              break;
            end;
        end;
      except

      end;

      // Выход в случае некорректного расположения элементов в таблице (не по-порядку или с повторами частот).
      if (point1 > point2) or (point1 + 1 < point2) then Exit;

      if point1 = point2 then
        if point1 = 0 then point2 := 1
        else
          if point1 = table_length - 1 then point1 := table_length - 2
          else begin
            // Найденные точки равны и не располагаются в одном из концов таблицы => значение частоты в этой
            // точке равно текущему показанию модуля (высчитывать коэффициент не надо).
            Result := table[point1].Coefficient;
            Exit;
          end;

      // Высчитываем коэффициент. Уравнение прямой: (x-x1)/(x2-x1) = (y-y1)/(y2-y1)
      try
        if (table[point2].WaterDischarge - table[point1].WaterDischarge)<>0 then
               Result := (table[point2].Coefficient - table[point1].Coefficient) *
                  (cur_discharge - table[point1].WaterDischarge) /
                  (table[point2].WaterDischarge - table[point1].WaterDischarge) +
                  table[point1].Coefficient
        else
                Result:=1;
      except
      end;
    end;

end;


function TFmxDeviceFlowmeter.CalculateCalibrationCoefficient: Double;
var
  cur_discharge: Double;
  i: Byte;
  point1: Byte;
  point2: Byte;
  table_length: Byte;
begin
  Result := 1;
  if ModuleType=mtCounter then
  begin
    if Primary then cur_discharge := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[0] * current_settings.ImpulseWeight * 3.6
    else cur_discharge := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[1] * current_settings.ImpulseWeight * 3.6;
  end
  else if ModuleType=mtCounterEx then
  begin
      cur_discharge := TFmxModuleCounterEx(Module).MasterFlowmeterFreq_J[PairNumber] * current_settings.ImpulseWeight * 3.6;
  end
  else if ModuleType=mtHSC_IMP then
  begin
      cur_discharge := TFmxModuleHSC_IMP(Module).FlowmeterFrequencies[PairNumber] * current_settings.ImpulseWeight * 3.6;
  end
  else if ModuleType=mtManual then
  begin
      cur_discharge := FFrequency * current_settings.ImpulseWeight * 3.6;
  end;

  table_length := Length(current_settings._CalibrationTable);
  if table_length > 0 then
    if table_length = 1 then Result := current_settings._CalibrationTable[0].Coefficient
    else begin

      // Поиск в калибровочной таблице отрезка, в который входит текущая частота.
      point1 := 0;
      point2 := table_length-1;
      try
      for i := 1 to table_length do begin
        if cur_discharge >= current_settings._CalibrationTable[i-1].WaterDischarge then point1 := i-1;
        if cur_discharge <= current_settings._CalibrationTable[table_length-i].WaterDischarge then point2 := table_length-i;
      end;
      except
        cur_discharge:=0;
      end;

      // Выход в случае некорректного расположения элементов в таблице (не по-порядку или с повторами частот).
      if (point1 > point2) or (point1 + 1 < point2) then Exit;

      if point1 = point2 then
        if point1 = 0 then point2 := 1
        else
          if point1 = table_length - 1 then point1 := table_length - 2
          else begin
            // Найденные точки равны и не располагаются в одном из концов таблицы => значение частоты в этой
            // точке равно текущему показанию модуля (высчитывать коэффициент не надо).
            Result := current_settings._CalibrationTable[point1].Coefficient;
            Exit;
          end;

      // Высчитываем коэффициент. Уравнение прямой: (x-x1)/(x2-x1) = (y-y1)/(y2-y1)
      try
        if (current_settings._CalibrationTable[point2].WaterDischarge - current_settings._CalibrationTable[point1].WaterDischarge)<>0 then
               Result := (current_settings._CalibrationTable[point2].Coefficient - current_settings._CalibrationTable[point1].Coefficient) *
                  (cur_discharge - current_settings._CalibrationTable[point1].WaterDischarge) /
                  (current_settings._CalibrationTable[point2].WaterDischarge - current_settings._CalibrationTable[point1].WaterDischarge) +
                  current_settings._CalibrationTable[point1].Coefficient
        else
                Result:=1;
      except
      end;
    end;
    //фиксируем текущий коэффициент
    CurrentKoeff:=Result;
end;








//============================================================================================================

function TFmxDeviceFlowmeter.GetAddr: integer;
begin
  result:=0;
  case ModuleType of
    mtCounter: begin
        Result := TFmxModuleCounter(Module).Address;
      end;
    mtCounterEx: begin
        result:=TFmxModuleCounterEx(Module).Address;
      end;
    mtHSC_IMP: begin
        result:=TFmxModuleHSC_IMP(Module).Address;
      end;
    mtKM5: begin
        result:=TFmxModuleKM5(Module).Address;
      end;
  end;
end;

function TFmxDeviceFlowmeter.GetCounterIsActive(index: Byte): Boolean;
begin
  case ModuleType of
    mtCounter: begin
        if index < 8 then Result := TFmxModuleCounter(Module).CounterIsActive[index]
        else Result := false;
      end;
    mtCounterEx: begin
        if index < 8 then Result := TFmxModuleCounterEx(Module).TestCounterIsActive[index]
        else Result := false;
      end;
    mtHSC_IMP: begin
        Result := TFmxModuleHSC_IMP(Module).CounterIsActive[index];
      end;
    mtManual:
      begin
         Result := Selected;
      end;
  end;
end;

function TFmxDeviceFlowmeter.GetCurKoeff: Double;
begin
  result:=CalculateCalibrationCoefficient();
end;


function TFmxDeviceFlowmeter.GetFrequency: Single;
begin
    Result := 0;
    if ModuleType=mtCounter then
    begin
      if Primary then Result := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[0]
      else Result := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[1];
    end
    else if ModuleType=mtCounterEx then
    begin
//      if Primary then
        Result := TFmxModuleCounterEx(Module).MasterFlowmeterFreq_J[PairNumber];
//      else Result := TFmxModuleCounterEx(Module).SlaveFlowmeterFreq_J[PairNumber];
    end
    else if ModuleType=mtHSC_IMP then
    begin
      Result := TFmxModuleHSC_IMP(Module).Frequencies[PairNumber]
    end
    else if ModuleType=mtManual then
    begin
       Result := FFrequency;
    end;
end;
//============================================================================================================

function TFmxDeviceFlowmeter.GetSecondaryFrequency: Word;
begin
  Result := 10000;
  if ModuleType=mtCounter then
    Result := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[1]
end;

//============================================================================================================


//если какой то канал еще ожидает прихода импульса
function TFmxDeviceFlowmeter.GetSomeActiveChannelsIsActive: boolean;
begin
  result:=False;
  if ModuleType=mtCounter then
  begin
    //TODO надо найти способ после разбора в статусе вернуть состояние slave каналов (идет счет или нет)
    //result:=TFmxModuleCounter(Module).
  end
  else if ModuleType=mtCounterEx then
  begin
    //TFmxModuleCounterEx(Module)
  end;

end;

function TFmxDeviceFlowmeter.GetSpillTime: Single;
begin
  result := 1;
  if Assigned(Module) then
  begin
    if ModuleType=mtCounter then
       result :=TFmxModuleCounter(Module).StartStopTime //версия 2.10 - 29.06.2023
  //    result :=SecondaryImpulses[0]/10000  //версии старее 2.10
    else if ModuleType=mtCounterEx then
      result :=TFmxModuleCounterEx(Module).StartStopTime_A_B
    else if ModuleType=mtHSC_IMP then
      result :=TFmxModuleHSC_IMP(Module).StartStopTime
    else if ModuleType=mtKM5 then
      result :=TFmxModuleKM5(Module).StartStopTime
    else if ModuleType=mtManual then
      result :=FSpillTime;
  end;
end;

//============================================================================================================

function TFmxDeviceFlowmeter.GetWaterDischarge: Double;
begin
  if ModuleType=mtCounter then
  begin
    if Primary then Result := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[0]
    else Result := TFmxModuleCounter(Module).SampleFlowmeterFrequencies[1];
    Result := Result * CalculateCalibrationCoefficient;
    // Умножение частоты на вес импульса дает расход в л/с, поэтому умножаем на 3.6
    Result := Result * current_settings.ImpulseWeight * 3.6;
  end
  else  if ModuleType=mtCounterEx then
  begin
    Result := TFmxModuleCounterEx(Module).MasterFlowmeterFreq_J[PairNumber];
    Result := Result * CalculateCalibrationCoefficient;
    // Умножение частоты на вес импульса дает расход в л/с, поэтому умножаем на 3.6
    Result := Result * current_settings.ImpulseWeight * 3.6;
  end
  else  if ModuleType=mtHSC_IMP then
  begin
    Result := TFmxModuleHSC_IMP(Module).FlowmeterFrequencies[PairNumber];
    Result := Result * CalculateCalibrationCoefficient;
    // Умножение частоты на вес импульса дает расход в л/с, поэтому умножаем на 3.6
    Result := Result * current_settings.ImpulseWeight * 3.6;
  end
  else  if ModuleType=mtKM5 then
  begin
    Result := TFmxModuleKM5(Module).Qv;
    Result := Result * CalculateCalibrationCoefficient;
  end
  else  if ModuleType=mtManual then
  begin
    Result := FFrequency * current_settings.ImpulseWeight * 3.6 * CalculateCalibrationCoefficient;
  end

end;

//function TFmxDeviceFlowmeter.GetOutlay(index: Byte): Double;
//begin
////Для разделения метрологически значимой части и не метрологически
////значимой части обычное умножение заменяем на вызов функции умножения
////из внешней dll
//  case Moduletype of
//    mtCounter: begin
//                  if index < 8 then
//                    Result:=TFmxModuleCounter(Module).CertifiableFlowmeterFrequencies[index]*SlaveImpulseWeights[index] * 3.6
//                  else
//                    Result := 0;
//               end;
//
//    mtCounterEx:begin
//                  if index < 8 then
//                    Result:=TFmxModuleCounterEx(Module).SlaveFlowmeterFreq_J[index]*SlaveImpulseWeights[index] * 3.6
//                  else
//                    Result := 0;
//               end;
//    mtHSC_IMP:begin
//                  if index < 16 then
//                    Result:=TFmxModuleHSC_IMP(Module).FlowmeterFrequencies[index]*SlaveImpulseWeights[index] * 3.6
//                  else
//                    Result := 0;
//               end;
//
//    mtKM5:     begin
//                  Result:=TFmxModuleKM5(Module).Qv;
//                  Result := Result * CalculateCalibrationCoefficient;
//               end;
//  end;
//
//end;

//============================================================================================================

function TFmxDeviceFlowmeter.GetResultGeneratorError: boolean;
begin
  if ModuleType=mtCounter then
    Result:=TFmxModuleCounter(Module).GeneratorError
  else
    Result:=False;
end;


function TFmxDeviceFlowmeter.GetTime: Double;
var i:integer;
begin
  Result :=-1;

  if ModuleType=mtHSC_IMP then
  begin
    if (TFmxModuleHSC_IMP(Module).State = hmsExecute) or (TFmxModuleHSC_IMP(Module).State = hmsMonitor)  then
     Result :=TFmxModuleHSC_IMP(Module).CurrentTime
    else
     Result :=TFmxModuleHSC_IMP(Module).ResultTime
  end
  else if ModuleType=mtManual then
    Result :=-1;
end;

function TFmxDeviceFlowmeter.GetResultTime: Double;
var i:integer;
begin
  Result :=-1;

  if ModuleType=mtHSC_IMP then
    Result :=TFmxModuleHSC_IMP(Module).ResultTime
  else if ModuleType=mtManual then
    Result :=-1;
end;

function TFmxDeviceFlowmeter.GetCurrentTime: Integer;
var i:integer;
begin
  Result :=-1;

  if ModuleType=mtHSC_IMP then
    Result :=TFmxModuleHSC_IMP(Module).CurrentTime
  else if ModuleType=mtManual then
    Result :=-1;
end;

function TFmxDeviceFlowmeter.GetImpulse: Single;
var i:integer;
begin
  Result :=0;
  if ModuleType=mtCounter then
  begin
    //24.10.24 - беру первый не нулевой
    for I := 0 to 7 do
     begin
       Result := TFmxModuleCounter(Module).SampleFlowmeterImpulses[i,0];
       if Result<>0 then Break;
     end;
  end
  else if ModuleType=mtCounterEx then
    Result :=TFmxModuleCounterEx(Module).MasterFlowmeterImpCounters_D[PairNumber]
  else if ModuleType=mtHSC_IMP then
    Result :=TFmxModuleHSC_IMP(Module).Impulses[PairNumber]
  else if ModuleType=mtManual then
    Result :=FImpulse;
end;

function TFmxDeviceFlowmeter.GetImpulses(index: Byte): Double;
begin
  Result := 0;
  if index <= 7 then
  begin
    if ModuleType=mtCounter then
       Result := TFmxModuleCounter(Module).CertifiableFlowmeterImpulses[index]
    else if ModuleType=mtCounterEx then
       Result := TFmxModuleCounterEx(Module).SlaveFlowmeterImpCounters_A_B[index]
    else if ModuleType=mtHSC_IMP then
       Result := TFmxModuleHSC_IMP(Module).ResultImpulses[index];
  end;
end;

function TFmxDeviceFlowmeter.GetIsCounterStarting: boolean;
begin
  UpdateCommonStatus();
  result:=GetCountIsStarted();
end;

//============================================================================================================

function TFmxDeviceFlowmeter.IsSelected: Boolean;
begin
  result:=True;
  if not Assigned(Module) then Exit;
  if ModuleType=mtCounter then
  begin
    Result := (PairNumber = TFmxModuleCounter(Module).SamplePairNumber) and (not Unselected);
  end
  else if ModuleType=mtCounterEx then
  begin
    result := TFmxModuleCounterEx(Module).CertifiableCounterIsActive[PairNumber] and (not Unselected);
  end
  else if ModuleType=mtHSC_IMP then
  begin
    result := TFmxModuleHSC_IMP(Module).CounterIsActive[PairNumber] and (not Unselected);
  end
  else if ModuleType=mtKM5 then
    result:=TFmxModuleKM5(Module).Selected and (not Unselected);
end;


{ TODO : Проверить - Возможно для HSC_IMP этот код понадобится }
function TFmxDeviceFlowmeter.LockAllValues: Boolean;
begin
  try
     if Assigned(Module) then
        Module.LastDevice:=self;
      case  ModuleType of
      mtManual:result:=True;
      mtCounter:result:=True;
      mtHSC_IMP:Result := TFmxModuleHSC_IMP(Module).LockAllValues;
      mtKM5:result:=True;
      end;
   finally
     if Assigned(Module) then
        Module.LastDevice:=nil;
   end;
end;

//============================================================================================================

constructor TFmxDeviceFlowmeter.CreateOnModuleCounter(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: longword;BR: Cardinal;  pair_number: Byte; prima: Boolean;
  AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
var
  i: Byte;
begin
  inherited Create;
  FUnSelected:=False;
  current_settings.OutlayType:=otCubeMeterPerHour;
  FRequestMasterSlaveTogether:=True;
  ModuleType:=AModuleType;
  SetLength(current_settings._CalibrationTable, 0);
  Primary := prima;
  current_settings.ImpulseWeight := 1;
  //ModuleType := Counter;
  if AModuleType=mtCounter then
  begin
    if pair_number in [1..4] then PairNumber := pair_number-1
    else PairNumber := 0;
  end
  else if AModuleType=mtCounterEx then begin
    if pair_number in [1..8] then PairNumber := pair_number-1
    else PairNumber := 0;
  end
  else if AModuleType=mtHSC_IMP then begin
    if pair_number in [1..15] then PairNumber := pair_number-1
    else PairNumber := 0;
  end
  else begin
    PairNumber := pair_number-1;
  end;

  if ModuleType<>mtManual then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;

end;

//============================================================================================================

destructor TFmxDeviceFlowmeter.Destroy;
begin
  inherited Destroy;
  SetLength(current_settings._CalibrationTable, 0);
  SetLength(stored_settings._CalibrationTable, 0);
end;

//============================================================================================================

procedure TFmxDeviceFlowmeter.StartCount;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
   if ModuleType=mtCounter then
     TFmxModuleCounter(Module).StartCount
   else if ModuleType=mtCounterEx then
     TFmxModuleCounterEx(Module).StartCount
   else if ModuleType=mtHSC_IMP then
     TFmxModuleHSC_IMP(Module).StartCount
   else if ModuleType=mtKM5 then
     TFmxModuleKM5(Module).StartCount
  finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
  end;
end;

procedure TFmxDeviceFlowmeter.StartCountWithoutSynchro;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
   if ModuleType=mtCounter then
     TFmxModuleCounter(Module).StartCount
   else if ModuleType=mtHSC_IMP then
     TFmxModuleHSC_IMP(Module).StartCount
   else if ModuleType=mtCounterEx then
     TFmxModuleCounterEx(Module).StartCountWithoutSyncro
   else if ModuleType=mtKM5 then
     TFmxModuleKM5(Module).StartCount
  finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
  end;
end;

function TFmxDeviceFlowmeter.SetupCountWithoutSynchro:integer;
var i,_repeat:integer;
begin
    _repeat:=0;
    while not IsCounterStarting do
    begin
      Inc(_repeat);
      StartCountWithoutSynchro();
      sleep(30);
      if _repeat>10 then
      begin
        break;
      end;
    end;
    result:=_repeat;
end;



procedure TFmxDeviceFlowmeter.SetupInputs;
begin
  if ModuleType=mtHSC_IMP then
    TFmxModuleHSC_IMP(Module).SetupInputs;
end;



function TFmxDeviceFlowmeter.Select: Boolean;
begin
  result:=false;
  FUnSelected:=False;
  if not Assigned(Module) then Exit;
  try
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Выбран эталоном',awlHard);
    if self.ModuleType=mtCounter then
    begin
      Result := TFmxModuleCounter(Module).SetSamplePair(PairNumber);
      TFmxModuleCounter(Module).SamplePairNumber:=PairNumber;
    end
    else if self.ModuleType=mtCounterEx then
    begin
      TFmxModuleCounterEx(Module).CertifiableCounterIsActive[PairNumber]:=True;
      Result := TFmxModuleCounterEx(Module).CertifiableCounterIsActive[PairNumber];
    end
    else if self.ModuleType=mtHSC_IMP then
    begin
      TFmxModuleHSC_IMP(Module).CounterIsActive[PairNumber]:=True;
      Result := TFmxModuleHSC_IMP(Module).CounterIsActive[PairNumber];
    end;
  except
    result:=false;
  end;
end;

//============================================================================================================

function TFmxDeviceFlowmeter.UnSelect: Boolean;
begin
  FUnSelected:=True;
  if self.ModuleType=mtCounterEx then
  begin
    TFmxModuleCounterEx(Module).CertifiableCounterIsActive[PairNumber]:=False;
    Result := TFmxModuleCounterEx(Module).CertifiableCounterIsActive[PairNumber];
  end
  else if self.ModuleType=mtHSC_IMP then
  begin
    TFmxModuleHSC_IMP(Module).CounterIsActive[PairNumber]:=False;
    Result := TFmxModuleHSC_IMP(Module).CounterIsActive[PairNumber];
  end
  else
    result:=True;
end;

function TFmxDeviceFlowmeter.GetCountIsStarted:boolean;
begin
  try
    if Assigned(Module) then
      Module.LastDevice:=self;
    case  ModuleType of
    mtManual:result:=True;
    mtCounter:Result := TFmxModuleCounter(Module).CountIsStarted;
    mtHSC_IMP:Result := TFmxModuleHSC_IMP(Module).CountIsStarted;
    mtCounterEx:Result := TFmxModuleCounterEx(Module).CountIsStarted;
    mtKM5:Result := TFmxModuleKM5(Module).CountIsStarted;
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

function TFmxDeviceFlowmeter.UpdateCommonStatus: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case  ModuleType of
    mtManual:result:=True;
    mtCounter:Result := TFmxModuleCounter(Module).UpdateCommonStatus;
    mtHSC_IMP:Result := TFmxModuleHSC_IMP(Module).UpdateStatusQuery;
    mtCounterEx:Result := TFmxModuleCounterEx(Module).UpdateStatus_S;
    mtKM5:Result := TFmxModuleKM5(Module).UpdateStatus;
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

function TFmxDeviceFlowmeter.UpdateVolumes: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
  result:=True;
  if ModuleType=mtCounterEx then
  begin
    //запрашиваем данные в контроллере
    Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_D;//D
    Result := TFmxModuleCounterEx(Module).UpdateSlaveCounters_A_B;//Команда A и B - запрос поверяемых объемов
    Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_C_E;//команда C
    Result := TFmxModuleCounterEx(Module).UpdateStatus_S;//команда S
  end
  else if ModuleType=mtCounter then
  begin
    Result := TFmxModuleCounter(Module).UpdateImpulseCounters;
  end
  else if ModuleType=mtHSC_IMP then
  begin
    UpdateCommonStatus();
  end
  else if ModuleType=mtKM5 then
  begin
    Result := TFmxModuleKM5(Module).UpdateVolume();
    Result := TFmxModuleKM5(Module).UpdateStatus();
  end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

//============================================================================================================


//============================================================================================================

function TFmxDeviceFlowmeter.UpdateWaterDischarges: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case ModuleType of
    mtModbusA: Result := TFmxModuleModbusA(Module).UpdateStatus;
    mtManual:result:=True;
    mtCounter:
      Result := TFmxModuleCounter(Module).UpdateFrequencies;
    mtCounterEx:
      Result := TFmxModuleCounterEx(Module).UpdateFrequencies;
    mtHSC_IMP:
    begin
     Result := TFmxModuleHSC_IMP(Module).UpdateStatusQuery;
    end;
    mtKM5:
      Result := TFmxModuleKM5(Module).UpdateWaterDischarge;
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;


function TFmxDeviceFlowmeter.SetupStartStop: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case ModuleType of
    mtManual:result:=True;
    mtCounter:
      Result := true;
    mtCounterEx:
      Result := TFmxModuleCounterEx(Module).SetupStartStop;
    mtHSC_IMP:
      Result := TFmxModuleHSC_IMP(Module).SetupStartStop;
    mtKM5:
      Result := TFmxModuleKM5(Module).SetupStartStop;
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;


procedure TFmxDeviceFlowmeter.StopCount;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
   if ModuleType=mtCounter then
      TFmxModuleCounter(Module).StopCount
   else if ModuleType=mtCounterEx then
      TFmxModuleCounterEx(Module).StopCount
   else if ModuleType=mtHSC_IMP then
     TFmxModuleHSC_IMP(Module).StopCount
   else if ModuleType=mtKM5 then
      TFmxModuleKM5(Module).StopCount
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceHeater --------------------
//============================================================================================================

function TFmxDeviceHeater.GetActive: Boolean;
begin
  case ModuleType of
    mtWarm: Result := TFmxModuleWarm(Module).OutputValues[OutputNumber];
    mtValve: Result := TFmxModuleValve(Module).OutputValues[OutputNumber];
    mtSuperBio: Result := TFmxModuleSuperBio(Module).OutputValues[OutputNumber];
    mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).OutputValues[OutputNumber]=100;
    mtBio: Result := TFmxModuleBio(Module).OutputValues[OutputNumber];
    mtModbusD:   Result := TFmxModuleModbusD(Module).OutputValues[OutputNumber];
  end;
end;

procedure TFmxDeviceHeater.SetMaxChannels(const Value: byte);
begin
  inherited;

end;

procedure TFmxDeviceHeater.SetOutputNumber(const Value: Byte);
begin
  FOutputNumber := Value;
end;

//============================================================================================================

constructor TFmxDeviceHeater.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;  output_number: word;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;

  ModuleType := AModuleType;
  if AModuleType=mtWarm then
  begin
    if output_number < 4 then OutputNumber := output_number
    else OutputNumber := 0;
  end
  else if AModuleType=mtBIO then
  begin
    if output_number < 2 then OutputNumber := output_number
    else OutputNumber := 0;
  end
  else if AModuleType=mtSuperBIO then
  begin
    if output_number < 12 then OutputNumber := output_number
    else OutputNumber := 0;
  end
  else if AModuleType=mtHSC_CTRL then
  begin
    if output_number < cHsc_MaxChannels then OutputNumber := output_number
    else OutputNumber := 0;
  end
  else
    OutputNumber := output_number;

  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

//============================================================================================================
(*
constructor TFmxDeviceHeater.CreateOnModuleValve(address: Byte;BR: Cardinal;  output_number: Byte);
begin
  inherited Create;

  ModuleType := Valve;
  //if output_number < 4 then OutputNumber := output_number
  //else OutputNumber := 0;

  OutputNumber := output_number;
  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(Valve,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;*)
//============================================================================================================
(*
constructor TFmxDeviceHeater.CreateOnModuleSuperBIO(address: Byte;BR: Cardinal;  output_number: Byte);
begin
  inherited Create;

  ModuleType := SuperBIO;
  //if output_number < 4 then OutputNumber := output_number
  //else OutputNumber := 0;

  OutputNumber := output_number  ;
  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(SuperBIO,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;
  *)
//============================================================================================================

function TFmxDeviceHeater.Activate: Boolean;
begin
  try
   Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Включение...',awlHard);
  case ModuleType of
    mtWarm:  Result := TFmxModuleWarm(Module).SetOutput(OutputNumber, true);
    mtValve: Result := TFmxModuleValve(Module).SetOutput(OutputNumber, true);
    mtSuperBIO:Result := TFmxModuleSuperBio(Module).SetOutput(OutputNumber, true);
    mtHSC_CTRL:Result := TFmxModuleHsc_Ctrl(Module).SetOutput(OutputNumber, true);
    mtBIO:Result := TFmxModuleBio(Module).SetOutput(OutputNumber, true);
    mtModbusD:   Result := TFmxModuleModbusD(Module).SetOutput(OutputNumber, true);
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceHeater.Deactivate: Boolean;
begin
  try
   Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Выключение...',awlHard);
  case ModuleType of
    mtWarm: Result := TFmxModuleWarm(Module).SetOutput(OutputNumber, false);
    mtValve: Result := TFmxModuleValve(Module).SetOutput(OutputNumber, false);
    mtSuperBio: Result := TFmxModuleSuperBio(Module).SetOutput(OutputNumber, false);
    mtHSC_CTRL:Result := TFmxModuleHsc_Ctrl(Module).SetOutput(OutputNumber, False);
    mtBio: Result := TFmxModuleBio(Module).SetOutput(OutputNumber, false);
    mtModbusD:   Result := TFmxModuleModbusD(Module).SetOutput(OutputNumber, false);
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceHeater.UpdateStatus: Boolean;
begin
  try
   Module.LastDevice:=self;
    case ModuleType of
    mtWarm: Result := TFmxModuleWarm(Module).UpdateStatus;
    mtValve: Result := TFmxModuleValve(Module).UpdateStatus;
    mtSuperBIO: Result := TFmxModuleSuperBIO(Module).UpdateStatus;
    mtHSC_CTRL:Result := TFmxModuleHsc_Ctrl(Module).UpdateStatus;
    mtBIO: Result := TFmxModuleBIO(Module).UpdateStatus;
    mtModbusD: Result := TFmxModuleModbusD(Module).UpdateStatus;
  end;
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceHeatingPump --------------------
//============================================================================================================

function TFmxDeviceHeatingPump.Activate: Boolean;
begin
  try
     Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Включение...',awlHard);
    Result := TFmxModuleWarm(Module).SetOutput(OutputNumber, true);
 finally
  Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceHeatingPump.Deactivate: Boolean;
begin
  try
   Module.LastDevice:=self;
   if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Выключение...',awlHard);
   Result := TFmxModuleWarm(Module).SetOutput(OutputNumber, false);
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceLevelDetector --------------------
//============================================================================================================

function TFmxDeviceLevelDetector.GetInput: Boolean;
begin
  case ModuleType of
    mtModbusD: begin
      if FromInput then
        Result := TFmxModuleModbusD(Module).InputValues[InputNumber]
      else
        Result := TFmxModuleModbusD(Module).OutputValues[InputNumber];
    end;
    mtBIO:
      if FromInput then
        Result := TFmxModuleBIO(Module).InputValues[InputNumber]
      else
        Result := TFmxModuleBIO(Module).OutputValues[InputNumber];

    mtSuperBIO:
      if FromInput then
        Result := TFmxModuleSuperBIO(Module).InputValues[InputNumber]
      else
        Result := TFmxModuleSuperBIO(Module).OutputValues[InputNumber];

    mtHSC_CTRL: { TODO : Возможно надо будет переделать источник информации для HSC_Ctrl }
      if FromInput then
        Result := TFmxModuleHsc_Ctrl(Module).InputValues[InputNumber]=100
      else
        Result := TFmxModuleHsc_Ctrl(Module).OutputValues[InputNumber]=100;

    mtValve:
      if FromInput then
         Result := TFmxModuleValve(Module).InputValues[InputNumber]
      else
         Result := TFmxModuleValve(Module).OutputValues[InputNumber];
         
    else Result := false;
  end;

  if Inverse then
     result:=not result;
end;

procedure TFmxDeviceLevelDetector.SetInputNumber(const Value: byte);
begin
  FInputNumber := Value;
end;

procedure TFmxDeviceLevelDetector.SetInverse(const Value: boolean);
begin
  FInverse := Value;
end;

//============================================================================================================

constructor TFmxDeviceLevelDetector.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: integer;BR: Cardinal;  input_number: Byte; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);
begin
  inherited Create;

  FInverse := False;

  ModuleType := AModuleType;
  if AModuleType=mtValve then
  begin
    if (input_number > cMinValve_IO_PinNumber) and (input_number < 10) then InputNumber := input_number
    else InputNumber := 6;
  end
  else if AModuleType=mtSuperBIO then begin
    if input_number < 13 then InputNumber := input_number
    else InputNumber := 0;
  end
  else if AModuleType=mtHSC_CTRL then begin
    if input_number < cHsc_MaxChannels then InputNumber := input_number
    else InputNumber := 0;
  end
  else if AModuleType=mtBIO then  begin
    if input_number < 2 then InputNumber := input_number
    else InputNumber := 0;
  end
  else begin
    InputNumber := input_number;
  end;


  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
  FFromInput:=True;
end;

//============================================================================================================
(*
constructor TFmxDeviceLevelDetector.CreateOnModuleValve(address: Byte;BR: Cardinal;  input_number: Byte);
begin
  inherited Create;

  ModuleType := Valve;
  if (input_number > cMinValve_IO_PinNumber) and (input_number < 10) then InputNumber := input_number
  else InputNumber := 6;

  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(Valve,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;
  *)
//============================================================================================================

function TFmxDeviceLevelDetector.UpdateStatus: Boolean;
begin
  try
   Module.LastDevice:=self;
    case ModuleType of
    mtModbusD: Result := TFmxModuleModbusD(Module).UpdateStatus;
    mtBIO: Result := TFmxModuleBIO(Module).UpdateStatus;
    mtSuperBIO: Result := TFmxModuleSuperBIO(Module).UpdateStatus;
    mtHSC_CTRL: Result := TFmxModuleHSC_Ctrl(Module).UpdateStatus;
    mtValve: Result := TFmxModuleValve(Module).UpdateStatus;
    else Result := false;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDevicePneumaticValve --------------------
//============================================================================================================

function TFmxDevicePneumaticValve.GetClosed: Boolean;
begin
  result:=True;
  if not Assigned(Module) then Exit;

  if TwoSwitch then
  begin
    case ModuleType of
      mtModbusD: begin
        //проверяем - закрыт ли
        if WithInput then
        begin
          Result:=TFmxModuleModbusD(Module).InputValues[CloseINumber];
          //если есть обратная связь - работаем по входнам значениям
          if (TFmxModuleModbusD(Module).InputValues[CloseINumber]) then
          begin
            //если бит закрытия сработал
            //а бит управления на закрытие активен - отключаем управление
            if (TFmxModuleModbusD(Module).OutputValues[CloseONumber]) then
            begin
              TFmxModuleModbusD(Module).OutputValues[CloseONumber]:=False;
              ModuleManager.ExecuteInCOMThread(StopClose);
            end;
          end;
          PreviousState:=Result;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          Result:=TFmxModuleModbusD(Module).OutputValues[CloseONumber];
          PreviousState:=Result;
        end;
      end;

      mtBIO: begin
        //проверяем - закрыт ли
        if WithInput then
        begin
          result:=TFmxModuleBIO(Module).InputValues[CloseINumber];
          //если есть обратная связь - работаем по входнам значениям
          if (TFmxModuleBIO(Module).InputValues[CloseINumber]) then
          begin
            //если бит закрытия сработал
            //а бит управления на закрытие активен - отключаем управление
            if (TFmxModuleBIO(Module).OutputValues[CloseONumber]) then
            begin
              TFmxModuleBIO(Module).OutputValues[CloseONumber]:=False;
              ModuleManager.ExecuteInCOMThread(StopClose);
            end;
          end;
          PreviousState:=Result;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          Result:=TFmxModuleBIO(Module).OutputValues[CloseONumber];
          PreviousState:=Result;
        end;
      end;

      mtSuperBIO: begin
        //проверяем - закрыт ли
        if WithInput then
        begin
          //если есть обратная связь - работаем по входнам значениям
          result:=TFmxModuleSuperBIO(Module).InputValues[CloseINumber];
          if (TFmxModuleSuperBIO(Module).InputValues[CloseINumber]) then
          begin
            //если бит закрытия сработал
            //а бит управления на закрытие активен - отключаем управление
            if (TFmxModuleSuperBIO(Module).OutputValues[CloseONumber]) then
            begin
              TFmxModuleSuperBIO(Module).OutputValues[CloseONumber]:=False;
              ModuleManager.ExecuteInCOMThread(StopClose);
            end;
          end;
          PreviousState:=Result;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          Result:=TFmxModuleSuperBIO(Module).OutputValues[CloseONumber]; //иначе говорим, что не закрыт
          PreviousState:=Result;
        end;
      end;

      mtHSC_CTRL: begin
        //проверяем - закрыт ли
        if WithInput then
        begin
          //если есть обратная связь - работаем по входнам значениям
          result:=TFmxModuleHsc_Ctrl(Module).InputValues[CloseINumber]=100;
          if (TFmxModuleHsc_Ctrl(Module).InputValues[CloseINumber]=100) then
          begin
            //если бит закрытия сработал
            //а бит управления на закрытие активен - отключаем управление
            if (TFmxModuleHsc_Ctrl(Module).OutputValues[CloseONumber]=100) then
            begin
              TFmxModuleHsc_Ctrl(Module).OutputValues[CloseONumber]:=0;
              ModuleManager.ExecuteInCOMThread(StopClose);
            end;
          end;
          PreviousState:=Result;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          Result:=TFmxModuleHsc_Ctrl(Module).OutputValues[CloseONumber]=100; //иначе говорим, что не закрыт
          PreviousState:=Result;
        end;
      end;

      mtValve: begin
        if WithInput then
        begin
          result:=TFmxModuleValve(Module).InputValues[CloseINumber];
          if TFmxModuleValve(Module).InputValues[CloseINumber] then begin
            //если бит закрытия сработал
            //а бит управления на закрытие активен - отключаем управление
            if TFmxModuleValve(Module).OutputValues[CloseONumber] then
            begin
              TFmxModuleValve(Module).OutputValues[CloseONumber]:=False;
              ModuleManager.ExecuteInCOMThread(StopClose);
            end;
          end;
          PreviousState:=Result;
        end
        else begin
          Result:=TFmxModuleValve(Module).OutputValues[CloseONumber];
          PreviousState:=Result;
        end;
      end;
    end;
  end
  else begin
    //Если один выход 1 - открыто 0- закрыто
    if WithInput then
      case ModuleType of
        mtModbusD: if WithInput then
                      Result := not TFmxModuleModbusD(Module).InputValues[OpenINumber]
                    else
                      Result := not TFmxModuleModbusD(Module).OutputValues[OpenONumber];
        mtBIO: if WithInput then
                      Result := not TFmxModuleBIO(Module).InputValues[OpenINumber]
                    else
                      Result := not TFmxModuleBIO(Module).OutputValues[OpenONumber];

        mtSuperBIO: if WithInput then
                      Result := not TFmxModuleSuperBIO(Module).InputValues[OpenINumber]
                    else
                      Result := not TFmxModuleSuperBIO(Module).OutputValues[OpenONumber];

        mtHSC_CTRL: if WithInput then
                      Result := not TFmxModuleHsc_Ctrl(Module).InputValues[OpenINumber]=100
                    else
                      Result := not TFmxModuleHsc_Ctrl(Module).OutputValues[OpenONumber]=100;

        mtValve: if WithInput then
                    Result := not TFmxModuleValve(Module).InputValues[OpenINumber]
                 else
                    Result := not TFmxModuleValve(Module).OutputValues[OpenONumber];
        else Result := false;
      end;
  end;


//  if not WithInput then begin
//    if FOpened and (StartTickCount<>0) and (GetTickCount-StartTickCount> TimeToSwitch*1000) then begin
//      FOpened:=false;
//      StartTickCount:=0;
//      Result:=FOpened;
//      Exit;
//    end;
//    if not FOpened and (StartTickCount<>0) and (GetTickCount-StartTickCount> TimeToSwitch*1000) then begin
//      FOpened:=true;
//      StartTickCount:=0;
//      Result:=FOpened;
//      Exit;
//    end;
//    Result:=FOpened;
//  end;
end;

function TFmxDevicePneumaticValve.GetCloseTimeIsOut: boolean;
begin
  result:=CloseTickCount<GetTickCount();
end;

function TFmxDevicePneumaticValve.GetClosing: boolean;
begin
  if TwoSwitch then
  begin
    case ModuleType of
        mtModbusD:
              Result:=TFmxModuleModbusD(Module).OutputValues[CloseONumber];
        mtBIO:
              Result:=TFmxModuleBIO(Module).OutputValues[CloseONumber];
        mtSuperBIO:
              Result:=TFmxModuleSuperBIO(Module).OutputValues[CloseONumber];
        mtHSC_CTRL:
              Result:=TFmxModuleHsc_Ctrl(Module).OutputValues[CloseONumber]=100;
        mtValve:
              Result:=TFmxModuleValve(Module).OutputValues[CloseONumber];
    end;
  end
  else
    result:=not GetOpening();

end;

function TFmxDevicePneumaticValve.GetLastCmd: boolean;
begin
  if FLastCmd=0 then
     result:=self.Opened
  else
     result:=FLastCmd=1;
end;

function TFmxDevicePneumaticValve.GetMustInCloseState: boolean;
begin
  //если было действие - о чем говорит OpenTickCount, и время вышло
  if TwoSwitch then
     result:=(OpenTickCount>0) and (OpenTickCount<GetTickCount) or (Opened) and (not Closed)
  else
     result:=Opened;
end;

function TFmxDevicePneumaticValve.GetMustInOpenState: boolean;
begin
  //если было действие - о чем говорит CloseTickCount, и время вышло
  if TwoSwitch then
     result:=(CloseTickCount>0) and (CloseTickCount<GetTickCount) or (Closed) and (not Opened)
  else
     result:=Closed;
end;

function TFmxDevicePneumaticValve.GetOpened: Boolean;
begin
  result:=False;
  if not Assigned(Module) then Exit;
  if TwoSwitch then begin
    case ModuleType of
      mtModbusD: begin
        if WithInput then
        begin
          Result:=TFmxModuleModbusD(Module).InputValues[OpenINumber];
          //если есть обратная связь - работаем по входнам значениям
          if (TFmxModuleModbusD(Module).InputValues[OpenINumber]) then
          begin
            Result:=true;
            //а бит управления на открытие активен - отключаем управление
            if TFmxModuleModbusD(Module).OutputValues[OpenONumber] then
            begin
              TFmxModuleModbusD(Module).OutputValues[OpenONumber]:=false;
              ModuleManager.ExecuteInCOMThread(StopOpen);
            end;
          end;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          result:=TFmxModuleModbusD(Module).OutputValues[OpenONumber];
        end;
        PreviousState:=Result;
      end;//ModbusD

      mtBIO: begin
        if WithInput then
        begin
          Result:=TFmxModuleBIO(Module).InputValues[OpenINumber];
          //если есть обратная связь - работаем по входнам значениям
          if (TFmxModuleBIO(Module).InputValues[OpenINumber]) then
          begin
            //а бит управления на открытие активен - отключаем управление
            if TFmxModuleBIO(Module).OutputValues[OpenONumber] then
            begin
              TFmxModuleBIO(Module).OutputValues[OpenONumber]:=false;
              ModuleManager.ExecuteInCOMThread(StopOpen);
            end;
          end;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          result:=TFmxModuleBIO(Module).OutputValues[OpenONumber];
        end;
        PreviousState:=Result;
      end;//BIO

      mtSuperBIO: begin
        if WithInput then
        begin
          Result:=TFmxModuleSuperBIO(Module).InputValues[OpenINumber];
          //если есть обратная связь - работаем по входнам значениям
          if (TFmxModuleSuperBIO(Module).InputValues[OpenINumber]) then
          begin
            //а бит управления на открытие активен - отключаем управление
            if TFmxModuleSuperBIO(Module).OutputValues[OpenONumber] then
            begin
              TFmxModuleSuperBIO(Module).OutputValues[OpenONumber]:=false;
              ModuleManager.ExecuteInCOMThread(StopOpen);
            end;
          end;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          result:=TFmxModuleSuperBIO(Module).OutputValues[OpenONumber];
        end;
        PreviousState:=Result;
      end;//SuperBIO

      mtHSC_CTRL: begin
        if WithInput then
        begin
          Result:=TFmxModuleHsc_Ctrl(Module).InputValues[OpenINumber]=100;
          //если есть обратная связь - работаем по входнам значениям
          if (TFmxModuleHsc_Ctrl(Module).InputValues[OpenINumber]=100) then
          begin
            //а бит управления на открытие активен - отключаем управление
            if TFmxModuleHsc_Ctrl(Module).OutputValues[OpenONumber]=100 then
            begin
              TFmxModuleHsc_Ctrl(Module).OutputValues[OpenONumber]:=0;
              ModuleManager.ExecuteInCOMThread(StopOpen);
            end;
          end;
        end
        else begin
          //если нет обратной связи - работаем по выходнам значениям
          result:=TFmxModuleHsc_Ctrl(Module).OutputValues[OpenONumber]=100;
        end;
        PreviousState:=Result;
      end;//SuperBIO

      mtValve:
        begin
          if WithInput then
          begin
            Result:=TFmxModuleValve(Module).InputValues[OpenINumber];
            //если сработал конечник
            if TFmxModuleValve(Module).InputValues[OpenINumber] then
            begin
              //а бит управления на открытие активен - отключаем управление
              if TFmxModuleValve(Module).OutputValues[OpenONumber] then
              begin
                TFmxModuleValve(Module).OutputValues[OpenONumber]:=False;
                ModuleManager.ExecuteInCOMThread(StopOpen);
              end;
            end;
          end
          else begin
              Result:=TFmxModuleValve(Module).OutputValues[OpenONumber];
          end;
          PreviousState:=Result;
        end;//Valve
    end;
  end
  else begin
        case ModuleType of
          mtModbusD: if WithInput then
                        Result := TFmxModuleModbusD(Module).InputValues[OpenINumber]
                      else
                        Result := TFmxModuleModbusD(Module).OutputValues[OpenONumber];

          mtBIO: if WithInput then
                        Result := TFmxModuleBIO(Module).InputValues[OpenINumber]
                      else
                        Result := TFmxModuleBIO(Module).OutputValues[OpenONumber];

          mtSuperBIO: if WithInput then
                        Result := TFmxModuleSuperBIO(Module).InputValues[OpenINumber]
                      else
                        Result := TFmxModuleSuperBIO(Module).OutputValues[OpenONumber];

          mtHSC_CTRL: if WithInput then
                        Result := TFmxModuleHsc_Ctrl(Module).InputValues[OpenINumber]=100
                      else
                        Result := TFmxModuleHsc_Ctrl(Module).OutputValues[OpenONumber]=100;

          mtValve: if WithInput then
                      Result := TFmxModuleValve(Module).InputValues[OpenINumber]
                   else
                      Result := TFmxModuleValve(Module).OutputValues[OpenONumber];
          else Result := false;
        end;
  end;
end;

function TFmxDevicePneumaticValve.GetOpening: Boolean;
begin
  result:=False;
  case ModuleType of
      mtModbusD:
            Result:=TFmxModuleModbusD(Module).OutputValues[OpenONumber];
      mtBIO:
            Result:=TFmxModuleBIO(Module).OutputValues[OpenONumber];
      mtSuperBIO:
            Result:=TFmxModuleSuperBIO(Module).OutputValues[OpenONumber];

      mtHSC_CTRL:
            Result := TFmxModuleHsc_Ctrl(Module).OutputValues[OpenONumber]=100;

      mtValve:
            Result:=TFmxModuleValve(Module).OutputValues[OpenONumber];
    end;
end;

function TFmxDevicePneumaticValve.GetOpenTimeIsOut: boolean;
begin
  result:=OpenTickCount<GetTickCount();
end;

function TFmxDevicePneumaticValve.GetStopped: boolean;
begin
  result:=True;
  if Assigned(Module) then
     if Closing or Opening then
        result:=False;
end;

//============================================================================================================

constructor TFmxDevicePneumaticValve.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;
  open_i_number,close_i_number,open_o_number,close_o_number: byte;
  two_switches,with_input:boolean;AModuleType:TFmxModuleType;InputReg:Word;OutputReg:word;_typeofprotocol:TTypeOfProtocol);
begin
  inherited Create;
  FCloseTickCount := 0;//никаких событий не было
  FOpenTickCount := 0;
  FLastCmd := 0;

  FWithInput := True;

  ModuleType :=AModuleType;

  TypeOfProtocol:=_typeofprotocol;

  //изначально будем считать, что задвижка открыта
  PreviousState:=true;

  FModuleManager := MainDeviceManager.ModuleManager;
  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);

  if ModuleType= mtSuperBIO then
  begin
    if open_i_number < 13 then OpenINumber := open_i_number
    else OpenINumber := 0;
    if close_i_number < 13 then CloseINumber := close_i_number
    else CloseINumber := 0;

    if open_o_number < 13 then OpenONumber := open_o_number
    else OpenINumber := 0;
    if close_o_number < 13 then CloseONumber := close_o_number
    else CloseONumber := 0;

    TwoSwitch:=two_switches;

    WithInput:=with_input;
    Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  end
  else if ModuleType= mtBIO then begin
    if open_i_number < 2 then OpenINumber := open_i_number
    else OpenINumber := 0;
    if close_i_number < 2 then CloseINumber := close_i_number
    else CloseINumber := 0;

    if open_o_number < 2 then OpenONumber := open_o_number
    else OpenINumber := 0;
    if close_o_number < 2 then CloseONumber := close_o_number
    else CloseONumber := 0;

    TwoSwitch:=two_switches;

    WithInput:=with_input;
  end
  else if ModuleType= mtValve then begin
    //Попытка управлять выходами в ручном реиме 21.12.22
    if (open_i_number > cMinValve_IO_PinNumber) and (open_i_number < 9) then OpenINumber := open_i_number
    else OpenINumber := 6;
    //Попытка управлять выходами в ручном реиме 21.12.22 (сменили 5 на 0)
    if (close_o_number > cMinValve_IO_PinNumber) and (close_o_number < 9) then CloseONumber := close_o_number
    else CloseONumber := 6;
  end
  else if ModuleType= mtHSC_CTRL then begin
    if (open_i_number > cMinValve_IO_PinNumber) and (open_i_number < cHsc_MaxChannels) then OpenINumber := open_i_number
    else OpenINumber := 6;
    if (close_o_number > cMinValve_IO_PinNumber) and (close_o_number < cHsc_MaxChannels) then CloseONumber := close_o_number
    else CloseONumber := 6;
  end
  else begin
    //ModbusD
    OpenINumber := open_i_number;
    OpenONumber := open_o_number;
    CloseINumber := close_i_number;
    CloseONumber := close_o_number;
  //  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  end;
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
end;

//============================================================================================================
(*
constructor TFmxDevicePneumaticValve.CreateOnModuleValve(address: Byte;BR: Cardinal;  io_number: Byte);
begin
  inherited Create;

end;
  *)
//============================================================================================================

function TFmxDevicePneumaticValve.Close: Boolean;
//var s:String;
begin
  try
    Module.LastDevice:=self;
    LastCmd:=False;
    OpenTickCount:=0;
    CloseTickCount:=GetTickCount()+TimeToSwitch*1000;
    if Assigned(AddToWorkLogProc) then
      AddToWorkLogProc(DeviceName+': Закрытие...',awlHard);
    case ModuleType of
      mtModbusD: begin
        TFmxModuleModbusD(Module).SetOutput(OpenONumber, false);
        if TwoSwitch then begin
          sleep(50);
          Result := TFmxModuleModbusD(Module).SetOutput(CloseONumber, true);
        end;
      end;
      mtBIO: begin
        TFmxModuleBIO(Module).SetOutput(OpenONumber, false);
        if TwoSwitch then begin
          sleep(50);
          Result := TFmxModuleBIO(Module).SetOutput(CloseONumber, true);
        end;
      end;
      mtSuperBIO: begin
        TFmxModuleSuperBIO(Module).SetOutput(OpenONumber, false);
        if TwoSwitch then begin
          sleep(50);
          Result := TFmxModuleSuperBIO(Module).SetOutput(CloseONumber, true);
        end;
      end;
      mtHSC_CTRL: begin
        TFmxModuleHsc_Ctrl(Module).SetOutput(OpenONumber, false);
        if TwoSwitch then begin
          sleep(50);
          Result := TFmxModuleHsc_Ctrl(Module).SetOutput(CloseONumber, true);
        end;
      end;
      mtValve: begin
        TFmxModuleValve(Module).SetOutput(OpenONumber, false);
        if TwoSwitch then begin
          sleep(50);
          Result := TFmxModuleValve(Module).SetOutput(CloseONumber, True);
        end;
      end;
      else Result := false;
    end;

    //если задвижка безконечниковая то запустим счет времени
    if Not WithInput then
      StartTickCount:=GetTickCount;
   finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDevicePneumaticValve.Open: Boolean;
//var s:String;
begin
  try
   Module.LastDevice:=self;
   LastCmd:=True;
   OpenTickCount:=GetTickCount()+TimeToSwitch*1000;
   CloseTickCount:=0;
//  if Assigned(Host) then
//     s:=Host.Caption;
   if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Открытие...',awlHard);
   case ModuleType of
    mtBIO: begin
      if TwoSwitch then begin
        TFmxModuleBIO(Module).SetOutput(CloseONumber, false);
        sleep(50);
      end;
      Result := TFmxModuleBIO(Module).SetOutput(OpenONumber, true);
    end;
    mtSuperBIO: begin
      if TwoSwitch then begin
        TFmxModuleSuperBIO(Module).SetOutput(CloseONumber, false);
        sleep(50);
      end;
      Result := TFmxModuleSuperBIO(Module).SetOutput(OpenONumber, true);
    end;
    mtHSC_CTRL: begin
      if TwoSwitch then begin
        TFmxModuleHsc_Ctrl(Module).SetOutput(CloseONumber, false);
        sleep(50);
      end;
      Result := TFmxModuleHsc_Ctrl(Module).SetOutput(OpenONumber, true);
    end;
    mtValve: begin
      if TwoSwitch then begin
        TFmxModuleValve(Module).SetOutput(CloseONumber, false);
        sleep(50);
      end;
      Result := TFmxModuleValve(Module).SetOutput(OpenONumber, true);
    end;
    mtModbusD: begin
      if TwoSwitch then begin
        TFmxModuleModbusD(Module).SetOutput(CloseONumber, false);
        sleep(50);
      end;
      Result := TFmxModuleModbusD(Module).SetOutput(OpenONumber, true);
    end;
    else Result := false;
  end;

  //если задвижка безконечниковая то запустим счет времени
  if Not WithInput then
    StartTickCount:=GetTickCount;
 finally
   Module.LastDevice:=nil;
 end;
end;

procedure TFmxDevicePneumaticValve.StopOpen;
begin
  try
   Module.LastDevice:=self;
    case ModuleType of
    mtModbusD: begin
        TFmxModuleModbusD(Module).SetOutput(OpenONumber, false);
      end;
    mtBIO: begin
      TFmxModuleBIO(Module).SetOutput(OpenONumber,false);
    end;
    mtSuperBIO: begin
      TFmxModuleSuperBIO(Module).SetOutput(OpenONumber,false);
    end;
    mtHSC_CTRL: begin
      TFmxModuleHsc_Ctrl(Module).SetOutput(CloseONumber,false);
    end;
    mtValve:begin
      TFmxModuleValve(Module).SetOutput(OpenONumber,false);
    end;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

procedure TFmxDevicePneumaticValve.StopClose;
begin
  try
   Module.LastDevice:=self;
    case ModuleType of
    mtModbusD: begin
      TFmxModuleModbusD(Module).SetOutput(CloseONumber, false);
      end;
    mtBIO: begin
      TFmxModuleBIO(Module).SetOutput(CloseONumber,false);
    end;
    mtSuperBIO: begin
      TFmxModuleSuperBIO(Module).SetOutput(CloseONumber,false);
    end;
    mtHSC_CTRL: begin
      TFmxModuleHsc_Ctrl(Module).SetOutput(CloseONumber,false);
    end;
    mtValve:begin
      TFmxModuleValve(Module).SetOutput(CloseONumber,false);
    end;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;


procedure TFmxDevicePneumaticValve.Stop;
begin
  try
   Module.LastDevice:=self;
    case ModuleType of
    mtModbusD: begin
      TFmxModuleModbusD(Module).SetOutput(OpenONumber,false);
      TFmxModuleModbusD(Module).SetOutput(CloseONumber,false);
    end;
    mtBIO: begin
      TFmxModuleBIO(Module).SetOutput(OpenONumber,false);
      TFmxModuleBIO(Module).SetOutput(CloseONumber,false);
    end;
    mtSuperBIO: begin
      TFmxModuleSuperBIO(Module).SetOutput(OpenONumber,false);
      TFmxModuleSuperBIO(Module).SetOutput(CloseONumber,false);
    end;
    mtHSC_CTRL: begin
      { TODO : Уточнить, как лучше останавливать HSC_CTRL }
      if not TwoSwitch then
         TFmxModuleHsc_Ctrl(Module).StopValve(OpenONumber)
      else begin
         TFmxModuleHsc_Ctrl(Module).SetOutput(OpenONumber,false);
         TFmxModuleHsc_Ctrl(Module).SetOutput(CloseONumber,false);
      end;
    end;
    mtValve:begin
      TFmxModuleValve(Module).SetOutput(OpenONumber,false);
      TFmxModuleValve(Module).SetOutput(CloseONumber,false);
    end;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;


//============================================================================================================

function TFmxDevicePneumaticValve.UpdateStatus: Boolean;
begin
  try
   Module.LastDevice:=self;
    case ModuleType of
    mtModbusD: TFmxModuleModbusD(Module).UpdateStatus;
    mtBIO: Result := TFmxModuleBIO(Module).UpdateStatus;
    mtSuperBIO: Result := TFmxModuleSuperBIO(Module).UpdateStatus;
    mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).UpdateStatus;
    mtValve: Result := TFmxModuleValve(Module).UpdateStatus;
    else Result := false;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceProver --------------------
//============================================================================================================

function TFmxDeviceProver.GetActive: Boolean;
begin
  Result := TFmxModuleProver(mtProver).Active;
end;

//============================================================================================================

constructor TFmxDeviceProver.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: Byte;BR: Cardinal;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;

  // ModuleType := Prover;

  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,mtProver,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

//============================================================================================================

function TFmxDeviceProver.SetActivity(activity: Boolean): Boolean;
begin
  try
   Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then
    if activity then AddToWorkLogProc(DeviceName+': Активация...',awlHard)
    else AddToWorkLogProc(DeviceName+': Деактивация...',awlHard);
  Result := TFmxModuleProver(Module).SetActivity(activity);
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceProver.UpdateStatus: Boolean;
begin
  try
   Module.LastDevice:=self;
    Result := TFmxModuleProver(Module).UpdateStatus;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDevicePump --------------------
//============================================================================================================


function TFmxDevicePumpPower.Init: Boolean;
begin
  try
   Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Инициализация блока изменения частоты вращения',awlHard);
  case ModuleType of
    mtABBModbus: Result := TFmxModuleABBModbus(Module).Init;
    mtDeltaModbus: Result := TFmxModuleDeltaModbus(Module).Init;
    mtVLT6000: Result := TFmxModuleVLT6000(Module).Init;
    mtVLTModbus: Result := TFmxModuleVLTModbus(Module).Init;
    mtVACONModbus: Result := TFmxModuleVaconModbus(Module).Init;
    mtATV312: Result := TFmxModuleATV312(Module).Init;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDevicePumpStartStop.IONumberCorrect(Value:integer): Boolean;
begin
  result:=false;
  case ModuleType of
   mtBIO: result:=Value in [0..1];
   mtSuperBIO: result:=Value in [0..12];
   mtHSC_Ctrl: result:=Value in [0..23];
   mtValve: result:=Value in [0..9];
   mtVLTModbus,
   mtModbusD,
   mtABBModbus,
   mtDeltaModbus,
   mtVACONModbus,
   mtATV312,
   mtVLT6000: result:=true;
   mtRT2: result:=Value in [0..3];
   mtLogoDAC: result:=Value in [0..1];
   end;
end;



function TFmxDevicePumpStartStop.GetStarted: Boolean;
begin
  result:=false;
  if IONumberCorrect(IONumber) and Assigned(Module) then
  case ModuleType of
    mtABBModbus: result:=TFmxModuleABBModbus(Module).Started;
    mtDeltaModbus:  result:=TFmxModuleDeltaModbus(Module).Started;
    mtModbusD: result:=TFmxModuleModbusD(Module).OutputValues[IONumber];
    mtBIO:
      if WithInput then
                  Result := TFmxModuleBIO(Module).InputValues[IONumber]
                else
                  Result := TFmxModuleBIO(Module).OutputValues[IONumber];
    mtSuperBIO:
      if WithInput then
                  Result := TFmxModuleSuperBIO(Module).InputValues[IONumber]
                else
                  Result := TFmxModuleSuperBIO(Module).OutputValues[IONumber];
    mtHSC_CTRL:
      if WithInput then
                  Result := TFmxModuleHSC_Ctrl(Module).InputValues[IONumber]=100
                else
                  Result := TFmxModuleHSC_Ctrl(Module).OutputValues[IONumber]=100;
    mtValve: if WithInput then
                Result := TFmxModuleValve(Module).InputValues[IONumber]
             else
                Result := TFmxModuleValve(Module).OutputValues[IONumber];
    mtVLT6000: Result := TFmxModuleVLT6000(Module).Started;
    mtVLTModbus: Result := TFmxModuleVLTModbus(Module).Started;
    mtVACONModbus: Result := TFmxModuleVaconModbus(Module).Started;
    mtATV312: Result := TFmxModuleATV312(Module).Started;
    mtRT2: Result := TFmxModuleRT2(Module).output[IONumber];
    mtLogoDAC: Result := TFmxModuleLogoDAC(Module).Start[IONumber];
      else Result := false;
  end;
end;

//============================================================================================================

constructor TFmxDevicePumpStartStop.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;address: integer;BR: Cardinal;io_number: Byte;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;
  ModuleType :=AModuleType;
  Started := False;
  FEnabledToStart:=True;

  if ModuleType= mtSuperBIO then
  begin
    if io_number < 13 then IONumber := io_number
    else IONumber := 0;
  end
  else if ModuleType= mtValve then
  begin
    if (io_number > cMinValve_IO_PinNumber) and (io_number < 9) then IONumber := io_number
    else IONumber := 6;
  end
  else if ModuleType= mtHSC_CTRL then
  begin
    if (io_number > cMinValve_IO_PinNumber) and (io_number < cHsc_MaxChannels) then IONumber := io_number
    else IONumber := 0;
  end
  else if ModuleType= mtRT2 then
  begin
    if (io_number < 4) then IONumber := io_number
    else IONumber := 0;
  end
  else if ModuleType= mtModbusD then
  begin
    if (io_number < 16) then IONumber := io_number
    else IONumber := 0;
  end
  else begin
    IONumber := io_number;
  end;

  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,ModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

//============================================================================================================

constructor TFmxDevicePumpPower.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer; address: integer;
  BR: Cardinal; DACNumb:byte;AModuleType: TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word;OutputReg:word);
begin
  inherited Create;
  ModuleType := AModuleType;
//  case ModuleType of
//    mtModbusA: Result := TFmxModuleModbusA(Module).InputValues[DAC_Number]*KInput;
//    mtVLT6000: Result := TFmxModuleVLT6000(Module).Power / 2;
//    mtVLTModbus: Result := TFmxModuleVLTModbus(Module).Power / 2;
//    mtVACONModbus: Result := TFmxModuleVaconModbus(Module).Power/2;
//    mtATV312: Result:=TFmxModuleATV312(Module).Power;
//    mtDAC_I702X: Result := TFmxModuleDAC_I702X(Module).Value[DAC_Number]*10;
//    mtRT2: Result := TFmxModuleRT2(Module).DAC[DAC_Number]/20;
//    mtLogoDAC: Result := TFmxModuleLogoDAC(Module).DAC[DAC_Number] / 20;
//  end;
                                                                          { TODO : Уточнить максимумы и минимумы }
  case ModuleType of
    mtABBModbus: begin MinInput:=0;MaxInput:=100; MinOutput:=0;MaxOutput:=100; end;
    mtDeltaModbus: begin MinInput:=0;MaxInput:=100; MinOutput:=0;MaxOutput:=100; end;
    mtModbusA: begin MinInput:=0;MaxInput:=10; MinOutput:=0;MaxOutput:=10; end;
    mtVLT6000: begin MinInput:=0;MaxInput:=100; MinOutput:=0;MaxOutput:=100; end;//TFmxModuleVLT6000(Module).Power:=AValue * 2;
    mtVLTModbus:begin MinInput:=0;MaxInput:=100; MinOutput:=0;MaxOutput:=100; end;// TFmxModuleVLTModbus(Module).SetPower(AValue * 2);
    mtVACONModbus: begin MinInput:=0;MaxInput:=100; MinOutput:=0;MaxOutput:=100; end;//TFmxModuleVACONModbus(Module).SetPower(AValue * 2);
    mtATV312: begin MinInput:=0;MaxInput:=100; MinOutput:=0;MaxOutput:=100; end;//TFmxModuleATV312(Module).SetPower(AValue);
    mtDAC_I702X: begin MinInput:=0;MaxInput:=10; MinOutput:=0;MaxOutput:=10; end;//TFmxModuleDAC_I702X(Module).Value[DAC_Number]:=AValue/10.0;
    mtRT2: begin MinInput:=0;MaxInput:=10; MinOutput:=0;MaxOutput:=10;end;//TFmxModuleRT2(Module).DAC[DAC_Number]:=AValue*20;
    mtLogoDAC: begin MinInput:=0;MaxInput:=10; MinOutput:=0;MaxOutput:=10;end;//TFmxModuleLogoDac(Module).DAC[DAC_Number]:=(AValue * 20);
  end;

  DAC_Number:=DACNumb;
  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,ModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

function TFmxDevicePumpPower.GetFreq: Single;
begin
  result:=0;
  if Assigned(Module) then
  case ModuleType of     //2-10 .. Res:=0-10*KInput (I-S)
    mtABBModbus: Result :=TFmxModuleABBModbus(Module).CurrentFrequency;
    mtDeltaModbus: Result :=TFmxModuleDeltaModbus(Module).CurrentFrequency;
    mtModbusA: Result :=ConvertScale(TFmxModuleModbusA(Module).InputValues[DAC_Number],MinInput,MaxInput,0,50);
    mtVLT6000: Result :=ConvertScale(TFmxModuleVLT6000(Module).Power,MinInput,MaxInput,0,50);
    mtVLTModbus: Result := ConvertScale(TFmxModuleVLTModbus(Module).Power,MinInput,MaxInput,0,50);
    mtVACONModbus: Result := ConvertScale(TFmxModuleVaconModbus(Module).Power,MinInput,MaxInput,0,50);
    mtATV312: Result:=ConvertScale(TFmxModuleATV312(Module).Power,MinInput,MaxInput,0,50);
    mtDAC_I702X: Result := ConvertScale(TFmxModuleDAC_I702X(Module).Value[DAC_Number],MinInput,MaxInput,0,50);
    mtRT2: Result := ConvertScale(TFmxModuleRT2(Module).DAC[DAC_Number],MinInput,MaxInput,0,50);
    mtLogoDAC: Result := ConvertScale(TFmxModuleLogoDAC(Module).DAC[DAC_Number],MinInput,MaxInput,0,50);
  end;
end;


function TFmxDevicePumpPower.GetPower: Single;
begin
  result:=GetFreq*2;
end;

//============================================================================================================

procedure TFmxDevicePumpPower.SetDAC_Number(const Value: byte);
begin
  FDAC_Number := Value;
end;


procedure TFmxDevicePumpPower.SetMinFreq(const Value: Integer);
begin
  FMinFreq := Value;
end;



procedure TFmxDevicePumpPower.SetPower(const Value: Single);
begin
  try
   Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then
    begin
       if Value=0 then
         AddToWorkLogProc( DeviceName + ': Сброс частоты вращения...' ,awlHard)
       else
         AddToWorkLogProc( DeviceName + ': Установка частоты вращения ' + FloatToStr(Value/2)+' Гц' ,awlHard);
    end;
    case ModuleType of
      mtABBModbus:
          TFmxModuleABBModbus(Module).Power:=Value;
      mtDeltaModbus:
          TFmxModuleDeltaModbus(Module).Power:=Value;
      mtVLT6000:
          TFmxModuleVLT6000(Module).Power:=Value;
      mtVLTModbus:
          TFmxModuleVLTModbus(Module).Power:=Value;
      mtVACONModbus:
          TFmxModuleVaconModbus(Module).Power:=Value;
      mtATV312:
          TFmxPumpModule(Module).Power:=Value;
      mtModbusA: TFmxModuleModbusA(Module).SetOutput(DAC_Number,ConvertScale(Value, 0, 50, MinOutput, MaxOutput));
      mtDAC_I702X: TFmxModuleDAC_I702X(Module).Value[DAC_Number]:=ConvertScale(Value, 0, 50, MinOutput, MaxOutput);
      mtRT2: TFmxModuleRT2(Module).DAC[DAC_Number]:=ConvertScale(Value, 0, 50, MinOutput, MaxOutput);
      mtLogoDAC: TFmxModuleLogoDac(Module).DAC[DAC_Number]:=ConvertScale(Value, 0, 50, MinOutput, MaxOutput);
    end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDevicePumpStartStop.StartPump: Boolean;
var s:String;
begin
  try
   Module.LastDevice:=self;
    if Assigned(Host) then  s:=Host.Caption;
  if  FEnabledToStart then begin
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Запуск...',awlHard);
    case ModuleType of
      mtABBModbus: Result := TFmxModuleABBModbus(Module).StartPump;
      mtDeltaModbus: Result := TFmxModuleDeltaModbus(Module).StartPump;
      mtModbusD: TFmxModuleModbusD(Module).SetOutput(IONumber, True);
      mtBIO: TFmxModuleBIO(Module).SetOutput(IONumber, true);
      mtSuperBIO: TFmxModuleSuperBIO(Module).SetOutput(IONumber, true);
      mtHSC_Ctrl: TFmxModuleHsc_Ctrl(Module).SetOutput(IONumber, true);
      mtValve: TFmxModuleValve(Module).SetOutput(IONumber, true);
      mtVLT6000: Result := TFmxModuleVLT6000(Module).StartPump;
      mtVLTModbus: Result := TFmxModuleVLTModbus(Module).StartPump;
      mtVaconModbus: Result := TFmxModuleVACONModbus(Module).StartPump;
      mtATV312: Result := TFmxModuleATV312(Module).StartPump;
      mtRT2: begin Result :=true; TFmxModuleRT2(Module).output[IONumber]:=True;end;
      mtLogoDAC: begin Result :=true; TFmxModuleLogoDac(Module).Start[IONumber]:=True;end;
    end;
  end
  else begin
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Запуск заблокирован!',awlHard);
    Result := false;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDevicePumpStartStop.StopPump: Boolean;
var s:String;
begin
  try
   Module.LastDevice:=self;
    if Assigned(Host) then
     s:=Host.Caption;
  if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Остановка...',awlHard);
  case ModuleType of
    mtABBModbus:  Result := TFmxModuleABBModbus(Module).StopPump;
    mtDeltaModbus:  Result := TFmxModuleDeltaModbus(Module).StopPump;
    mtModbusD: TFmxModuleModbusD(Module).SetOutput(IONumber, False);
    mtBIO: TFmxModuleBIO(Module).SetOutput(IONumber, false);
    mtSuperBIO: TFmxModuleSuperBIO(Module).SetOutput(IONumber, false);
    mtHSC_Ctrl: TFmxModuleHsc_Ctrl(Module).SetOutput(IONumber, False);
    mtValve: TFmxModuleValve(Module).SetOutput(IONumber, false);
    mtVLT6000:  Result := TFmxModuleVLT6000(Module).StopPump;
    mtVLTModbus: Result := TFmxModuleVLTModbus(Module).StopPump;
    mtVaconModbus: Result := TFmxModuleVACONModbus(Module).StopPump;
    mtATV312:  Result := TFmxModuleATV312(Module).StopPump;
    mtRT2: begin Result :=true;  TFmxModuleRT2(Module).output[IONumber]:=False;end;
    mtLogoDAC: begin Result :=true; TFmxModuleLogoDac(Module).Start[IONumber]:=False;end;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceScales --------------------
//============================================================================================================

function TFmxDeviceScales.GetSensorValue(sensor_number: Byte): Double;
begin
  if ModuleType=mtScales then
  begin
    if sensor_number < 4 then Result := MedianFilter[sensor_number].Filter(TFmxModuleScales(Module).ScalesValues[sensor_number])
    else Result := 0;
  end
  else if ModuleType=mtScalesMT then
  begin
    Result := TFmxModuleScalesMT(Module).ScalesValue
  end
  else if ModuleType=mtScalesAD103 then
  begin
    Result := TFmxModuleScalesAD103(Module).ScalesValue
  end
  else if ModuleType=mtScalesRADWAG then
  begin
    Result := TFmxModuleScalesRADWAG(Module).ScalesValue
  end
  else if ModuleType=mtManual then
  begin
    if sensor_number < 4 then Result := FSensorValues[sensor_number];
  end;
end;

//============================================================================================================

function TFmxDeviceScales.GetSensorWeight(sensor_number: Byte): Double;
var
  i,len: Byte;
begin
  Result := 0;
  if sensor_number > 3 then Exit;
  if ModuleType<>mtManual then
  begin
    len:=Length(ValuesBuffer);
    if Use_L1 then
    begin
      for i:=1 to len do
        Result := Result +
                  ValuesBuffer[i-1][sensor_number] * CalibrationCoefficients[sensor_number] -
                  CalibrationNulls[sensor_number]   *  CalibrationCoefficients[sensor_number];
    end
    else begin
      for i:=1 to len do
        Result := Result + ValuesBuffer[i-1][sensor_number];
    end;
    if len > 0 then Result := Result / len;
  end
  else begin
      Result := SensorValues[sensor_number] * CalibrationCoefficients[sensor_number] -
                CalibrationNulls[sensor_number]   *  CalibrationCoefficients[sensor_number];
  end;
end;

//============================================================================================================

function TFmxDeviceScales.GetWeight: Double;
begin
  if MassMode then
     result:=Value
  else
    result:=Value*Density;
end;

//============================================================================================================
function TFmxDeviceScales.GetClearWeight: Double;
var
  i: Byte;
begin
  Result := 0;
  for i:=1 to SensorsQuantity do
    Result := Result + SensorWeights[i-1];
  Result := Result - Tare;   // 29.07.2009 - собственно, вот

end;

//============================================================================================================
//============================================================================================================
//============================================================================================================
function TFmxDeviceScales.GetDiscontinuity:int64;
begin
  Result:=FDiscontinuity;
end;
//============================================================================================================
procedure TFmxDeviceScales.SetDensity(const Value: real);
begin
  FDensity := Value;
end;

procedure TFmxDeviceScales.SetDiscontinuity(Dt:int64);
begin
  FDiscontinuity:=Dt;
end;
//============================================================================================================
procedure TFmxDeviceScales.ScalesPneumaticContactClose;
begin
  ScalesPneumaticContact.Close;
end;
//============================================================================================================
procedure TFmxDeviceScales.ScalesPneumaticContactOpen;
begin
  ScalesPneumaticContact.Open;
end;
//============================================================================================================
procedure TFmxDeviceScales.ReceiveResponse;
var
  i: Byte;
begin
  changed := false;
  for i:=1 to SensorsQuantity do
    if ValuesBuffer[0][i-1] <> SensorValues[i-1] then changed := true;
  if Length(ValuesBuffer) < WeightsBufferLength then SetLength( ValuesBuffer, Length(ValuesBuffer) + 1 );
  for i := (Length(ValuesBuffer) - 1) downto 1 do ValuesBuffer[i] := ValuesBuffer[i-1];
  for i:=1 to SensorsQuantity do ValuesBuffer[0][i-1] := SensorValues[i-1];
end;
//============================================================================================================
function TFmxDeviceScales.CalibrationCoefficient(Discharge:double):double;
var
  i:byte;
  x1,x2,Y1,Y2,k,b:real;

  coef,error :real;
  PointsCount:byte;
begin
  result:=1;
  if (Discharge=0) then exit;
  with settings do
  begin
    PointsCount:=Length(CalibrationTable);
    if PointsCount=0 then exit;

    if PointsCount=1 then begin
      X1:=0;
      X2:=CalibrationTable[0].WaterDischarge;
      Y1:=1;
      Y2:=CalibrationTable[0].Coefficient;
    end
    else begin
      for i:=0 to Length(CalibrationTable)-2 do
        if CalibrationTable[i].WaterDischarge<=Discharge then begin
          X1:=CalibrationTable[i].WaterDischarge;
          X2:=CalibrationTable[i+1].WaterDischarge;
          Y1:=CalibrationTable[i].Coefficient;
          Y2:=CalibrationTable[i+1].Coefficient;
        end;

      if Discharge>=CalibrationTable[Length(CalibrationTable)-1].WaterDischarge then begin
          X1:=CalibrationTable[Length(CalibrationTable)-2].WaterDischarge;
          X2:=CalibrationTable[Length(CalibrationTable)-1].WaterDischarge;
          Y1:=CalibrationTable[Length(CalibrationTable)-2].Coefficient;
          Y2:=CalibrationTable[Length(CalibrationTable)-1].Coefficient;
      end;
      if Discharge<=CalibrationTable[0].WaterDischarge then begin
          X1:=CalibrationTable[0].WaterDischarge;
          X2:=CalibrationTable[1].WaterDischarge;
          Y1:=CalibrationTable[0].Coefficient;
          Y2:=CalibrationTable[1].Coefficient;
      end;
    end;

    if (X2-X1)>0 then
    begin
    k:=(Y2-Y1)/(X2-X1);
    b:=(Y1*X2-X1*Y2)/(X2-X1);
    end
    else begin
      k:=1.0;
      b:=0;
    end;
    coef:=k*Discharge+b;
  end;
  Result:=coef;
end;

function TFmxDeviceScales.GetCalibrationCoefficient_L2(Discharge:double):double;
var
  i:byte;
  x1,x2,Y1,Y2,k,b:Double;

  coef,error :Double;
  PointsCount:byte;
begin
  result:=1;
  if not (ScalesMode in [smWorking,smChecking]) then Exit;
  if (Discharge=0) then exit;
  with settings do
  begin
    PointsCount:=Length(CalibrationTable_l2);
    if PointsCount=0 then exit;

    if PointsCount=1 then begin
      X1:=0;
      X2:=CalibrationTable_l2[0].WaterDischarge;
      Y1:=1;
      Y2:=CalibrationTable_l2[0].Coefficient;
    end
    else begin
      for i:=0 to PointsCount-2 do
        if CalibrationTable_l2[i].WaterDischarge<=Discharge then begin
          X1:=CalibrationTable_l2[i].WaterDischarge;
          X2:=CalibrationTable_l2[i+1].WaterDischarge;
          Y1:=CalibrationTable_l2[i].Coefficient;
          Y2:=CalibrationTable_l2[i+1].Coefficient;
        end;

      if Discharge>=CalibrationTable_l2[PointsCount-1].WaterDischarge then begin
          X1:=CalibrationTable_l2[PointsCount-2].WaterDischarge;
          X2:=CalibrationTable_l2[PointsCount-1].WaterDischarge;
          Y1:=CalibrationTable_l2[PointsCount-2].Coefficient;
          Y2:=CalibrationTable_l2[PointsCount-1].Coefficient;
      end;
      if Discharge<=CalibrationTable_l2[0].WaterDischarge then begin
          X1:=CalibrationTable_l2[0].WaterDischarge;
          X2:=CalibrationTable_l2[1].WaterDischarge;
          Y1:=CalibrationTable_l2[0].Coefficient;
          Y2:=CalibrationTable_l2[1].Coefficient;
      end;
    end;

    if (X2-X1)>0 then
    begin
    k:=(Y2-Y1)/(X2-X1);
    b:=(Y1*X2-X1*Y2)/(X2-X1);
    end
    else begin
      k:=1.0;
      b:=0;
    end;
    coef:=k*Discharge+b;
  end;
  //Коэффициент коррекции не можт быть вне диапазона -2..2
  if (coef>2) or (coef<-2) then coef:=1;
  Result:=coef;
end;


procedure TFmxDeviceScales.SetWeight(const xValue: Double);
begin
  if MassMode then
     Value:=xValue
  else
    Value:=xValue/Density;
end;

//============================================================================================================

procedure TFmxDeviceScales.SetWeightsBufferLength(weights_buffer_length: Byte);
begin
  if weights_buffer_length > 0 then begin
    FWeightsBufferLength := weights_buffer_length;
    if WeightsBufferLength < Length(ValuesBuffer) then SetLength(ValuesBuffer, WeightsBufferLength);
  end;
end;
//============================================================================================================
function TFmxDeviceScales.GetWeightsBufferLength:byte;
begin
  Result:=FWeightsBufferLength;
end;

//============================================================================================================
procedure TFmxDeviceScales.SetActive(AActive: boolean);
begin
  FActive:=AActive;
  if ScalesPneumaticContact=nil then exit
  else begin
    if ActiveToActivate and AActive then ModuleManager.ExecuteInCOMThread(ScalesPneumaticContactOpen);
    if ActiveToActivate and  (not AActive) then ModuleManager.ExecuteInCOMThread(ScalesPneumaticContactClose);
    if (not ActiveToActivate) and AActive then ModuleManager.ExecuteInCOMThread(ScalesPneumaticContactClose);
    if (not ActiveToActivate) and  (not AActive) then ModuleManager.ExecuteInCOMThread(ScalesPneumaticContactOpen);
  end;
end;
//============================================================================================================
function TFmxDeviceScales.GetActive:boolean;
begin
  // если ScalesPneumaticContact=nil, то есть данное устройство не задано,
  //то весы стоят на датчиках по-любому, соответственно вернем true
  if ScalesPneumaticContact=nil then
    Result:=FActive
  else begin
    if ActiveToActivate then Result:=ScalesPneumaticContact.Opened;
    if  (not ActiveToActivate) then Result:=not ScalesPneumaticContact.Opened;
  end;
end;
//============================================================================================================
function TFmxDeviceScales.GetTare: Double;
begin
  Result:=FTare;
end;
function TFmxDeviceScales.GetValue: Double;
var
  i: Byte;
//  res:Double;
begin
  Result := 0;
  for i:=1 to SensorsQuantity do
    Result := Result + SensorWeights[i-1];

  FKalibrKoeff:=CalibrationCoefficient(Result-Tare);

  Result := (Result - Tare)*FKalibrKoeff;

  if Use_L2 then Result := Result * GetCalibrationCoefficient_L2(Result);
  //2026-02-15 - проверка на максимум
  if Result>(settings.MaxWeight+settings.TankWeight) then
     result:=(settings.MaxWeight+settings.TankWeight);

end;

function TFmxDeviceScales.GetVolume: Double;
begin
  if MassMode then
  begin
     if Density <>0  then
        result:=Value/Density
     else
        result:=Value;
  end
  else
    result:=Value;
end;

//============================================================================================================
procedure TFmxDeviceScales.SetTare(const Value: Double);
begin
  FTare:=Value;
end;

procedure TFmxDeviceScales.SetUse_L1(const Value: boolean);
begin
  FUse_L1 := Value;
end;

procedure TFmxDeviceScales.SetUse_L2(const Value: boolean);
begin
  FUse_L2 := Value;
end;

procedure TFmxDeviceScales.SetValue(const Value: Double);
begin
  FValue := Value;
end;

//============================================================================================================
function TFmxDeviceScales.GetCalibrationNulls(sensor_number:byte): Longword;
begin
  Result:=FCalibrationNulls[sensor_number];
end;

//============================================================================================================
procedure TFmxDeviceScales.SetCalibrationNulls(sensor_number:byte;
  const Value: Longword);
begin
 FCalibrationNulls[sensor_number]:=Value;
end;
procedure TFmxDeviceScales.Setchanged(const Value: boolean);
begin
  Fchanged := Value;
end;

//============================================================================================================
procedure TFmxDeviceScales.SetCalibrationCoefficients(sensor_number:byte;CalibrationCoefficient:Double);
begin
 FCalibrationCoefficients[sensor_number]:=CalibrationCoefficient;
end;
//============================================================================================================
function TFmxDeviceScales.GetCalibrationCoefficients(sensor_number:byte):Double;
begin
  Result:=FCalibrationCoefficients[sensor_number];
end;
//============================================================================================================
function TFmxDeviceScales.GetAmbientTemperature0(sensor_number: byte): Double;
begin
  Result:=FAmbientTemperature0[sensor_number];
end;
//============================================================================================================
function TFmxDeviceScales.GetAtmosphericPressure0(sensor_number: byte): Double;
begin
  Result:=FAtmosphericPressure0[sensor_number];
end;
//============================================================================================================
function TFmxDeviceScales.GetDumbbellsDensity0(sensor_number: byte): Double;
begin
  Result:=FDumbbellsDensity0[sensor_number];
end;
//============================================================================================================
function TFmxDeviceScales.GetRelativeHumidity0(sensor_number: byte): Double;
begin
  Result:=FRelativeHumidity0[sensor_number];
end;
//============================================================================================================
procedure TFmxDeviceScales.SetAmbientTemperature(const Value: double);
var i:integer;
begin
  FAmbientTemperature := Value;
  for i:=0 to 3 do
       AmbientTemperature0[i]:=Value;
end;

procedure TFmxDeviceScales.SetAmbientTemperature0(sensor_number: byte; const Value: Double);
begin
  FAmbientTemperature0[sensor_number]:=Value;
end;
//============================================================================================================
procedure TFmxDeviceScales.SetAtmosphericPressure(const Value: double);
var i:integer;
begin
  FAtmosphericPressure := Value;
  for i:=0 to 3 do
       AtmosphericPressure0[i]:=Value;
end;

procedure TFmxDeviceScales.SetAtmosphericPressure0(sensor_number: byte; const Value: Double);
begin
  FAtmosphericPressure0[sensor_number]:=Value;
end;
//============================================================================================================
procedure TFmxDeviceScales.SetDumbbellsDensity0(sensor_number: byte; const Value: Double);
begin
  FDumbbellsDensity0[sensor_number]:=Value;
end;

procedure TFmxDeviceScales.SetMassMode(const Value: Boolean);
begin
  FMassMode := Value;
end;

procedure TFmxDeviceScales.SetMedianFilterSize(const Value: byte);
var i:integer;
begin
  FMedianFilterSize := Value;
  for I := 0 to 3 do
    MedianFilter[i].Size:=Value;
end;

//============================================================================================================
procedure TFmxDeviceScales.SetRelativeHumidity(const Value: double);
var i:integer;
begin
  FRelativeHumidity := Value;
  for i:=0 to 3 do
       RelativeHumidity0[i]:=Value;
end;

procedure TFmxDeviceScales.SetRelativeHumidity0(sensor_number: byte; const Value: Double);
begin
  FRelativeHumidity0[sensor_number]:=Value;
end;
procedure TFmxDeviceScales.SetSensorsQuantity(const Value: Byte);
begin
  FSensorsQuantity:=Value;
end;

procedure TFmxDeviceScales.SetSensorValue(index: Byte; const Value: Double);
begin
    if index < 4 then FSensorValues[index]:=Value;
end;

//============================================================================================================
function TFmxDeviceScales.GetSensorsQuantity:byte;
begin
  Result:=FSensorsQuantity;
end;
//============================================================================================================
constructor TFmxDeviceScales.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;MT:TFmxModuleType;port:integer; address: integer;BR: Cardinal; sensors_quantity: Byte;_typeofprotocol:TTypeOfProtocol;InputReg:Word);
var
  i: Byte;
begin
  inherited Create;
  FUse_L2 := False;
  FDensity := cDefaultDensity;
  FMassMode:=True;//по умолчанию режим весов
  //Изначально весы назодятся в режиме обычной работы
  ScalesMode:=smCalibration;
  ModuleType := MT;

  //ModuleType := Scales;
  for i:=0 to 3 do begin
    MedianFilter[i]:=TFmxMedianFilter.Create(WeightsBufferLength);
    CalibrationCoefficients[i] := 1;
    CalibrationNulls[i] := 0;
  end;
  FWeightsBufferLength := 1;
  Tare := 0;
  if ModuleType=mtScales then
  begin
    Use_L1:=True;
    if (sensors_quantity >= 1) and (sensors_quantity <= 4) then FSensorsQuantity := sensors_quantity
    else FSensorsQuantity := 3;
  end
  else if ModuleType=mtScalesMT then
  begin
    //У Метро Толедо есть уже готовый показатель веса
    Use_L1:=False;
    FSensorsQuantity := 1;
  end
  else if ModuleType=mtScalesAD103 then
  begin
    // Hottinger Brüel & Kjaer GmbH
    Use_L1:=False;
    FSensorsQuantity := 1;
  end
  else if ModuleType=mtScalesRADWAG then
  begin
    // Hottinger Brüel & Kjaer GmbH
    Use_L1:=False;
    FSensorsQuantity := 1;
  end
  else begin
    FSensorsQuantity:=sensors_quantity;
  end;
  SetLength(ValuesBuffer, 1);
  if ModuleType<>mtManual then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port,ModuleType,BR, address,_typeofprotocol,InputReg);
    Module.AddReceiver(ReceiveResponse, false);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;
end;

//============================================================================================================

destructor TFmxDeviceScales.Destroy;
var
  vi: Integer;
begin
  inherited Destroy;
  SetLength(ValuesBuffer, 0);
  for vi := 0 to 3 do
    MedianFilter[vi].Free;
end;

//============================================================================================================

function TFmxDeviceScales.UpdateStatus: Boolean;
begin
  result:=True;
  try
   if Assigned(Module) then
   begin
      Module.LastDevice:=self;
      Result := TFmxModuleScales(Module).UpdateStatus;
   end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//давление в паскалях атмосферное
function TFmxDeviceScales.DensityScales(T, P:real):real;
const
  a1=-3.983035;
  a2=301.797;
  a3=522528.9;
  a4=69.34881;
  a5=999.974950;
  k0=5.074E-10;
  k1=-3.26E-12;
  k2=4.16E-14;
begin
  if T<=25
  then
    result:=(a5*(1-((T+a1)*(T+a1)*(T+a2)/(a3*(t+a4))))+((-4.612+0.106*T)/1000))*(1+(k0+k1*T+k2*T*T)*(P-101325))
  else
    result:=(a5*(1-((T+a1)*(T+a1)*(T+a2)/(a3*(t+a4)))))*(1+(k0+k1*T+k2*T*T)*(P-101325));

end;

//============================================================================================================

function TFmxDeviceScales.DensityAir(T, P, H:real):real;
begin
  //давление принимаем в паскалях, в формуле в гектапаскалях
  P:=P/100;
  result:=(0.34848*P-0.009024*H*Exp(0.0612*T))/(273.15+T);
end;



// 12.10.2007, добавляю Temp6 (модуль для шестиканального датчика температур)
//============================================================================================================
//-------------------- TFmxDeviceThermometer --------------------
//============================================================================================================

function TFmxDeviceThermometer.GetValue: Double;
begin
//Для разделения метрологически значимой части и не метрологически
//значимой части обычное умножение заменяем на вызов функции умножения
//из внешней dll
  Result:=0;
  with Settings do
  case ModuleType of
    mtT:
      //Result := (TFmxModuleT(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=(TFmxModuleT(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
    mtTemp2:
      //Result := (TFmxModuleTemp2(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=(TFmxModuleTemp2(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
{!} mtTemp6:
      //Result := (TFmxModuleTemp6(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=(TFmxModuleTemp6(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
{!} mtADC_I70XX:
      if Assigned(Module) then
         Result:=(TFmxModuleADC_I70XX(Module).Value[InputNumber] - CalibrationNull) * CalibrationCoefficient;
    mtUI:
      //Result := (TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=(TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
    mtOldUI:
      //Result := (TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=(TFmxModuleOldUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
    mtIVTM:
      //Result := (TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=TFmxModuleIVTM(Module).Value[InputNumber];
    mtLTA,
    mtManual:
      Result:=FValue;
    mtKM5:
      if Assigned(Module) then
         Result:=TFmxModuleKM5(Module).Values[InputNumber];
    mtModbusA:
      if Assigned(Module) then
         Result:=(TFmxModuleModbusA(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
    else
      Result := 0;
  end;
end;

procedure TFmxDeviceThermometer.SetDigitsForChannel(const Value: byte);
begin
  inherited;
  if Assigned(Module) then
  case ModuleType of
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).DigitsForChannel:=Value;
  end;
end;

procedure TFmxDeviceThermometer.SetInputNumber(const Value: byte);
begin
  FInputNumber := Value;
  if Assigned(Module) then
  case ModuleType of
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).MustUpdate:=True;
    mtModbusA: TFmxModuleModbusA(Module).MustUpdate:=True;
  end;
end;

procedure TFmxDeviceThermometer.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Module) then
  case ModuleType of
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).MaxChannels:=Value;
    mtModbusA: TFmxModuleModbusA(Module).MaxChannels:=Value;
  end;
end;

procedure TFmxDeviceThermometer.SetModbusFormat(const Value: TModBusDataFormat);
begin
  inherited;
  inherited;
  if Assigned(Module) then
  begin
    case ModuleType of
      mtADC_I70XX: TFmxModuleADC_I70XX(Module).ModbusFormat:=Value;
      mtModbusA: TFmxModuleModbusA(Module).ModbusFormat:=Value;
    end;
  end;
end;

procedure TFmxDeviceThermometer.SetMustUpdate(const Value: boolean);
begin
  inherited;
  if Assigned(Module) then
  begin
    case ModuleType of
      mtADC_I70XX: TFmxModuleADC_I70XX(Module).MustUpdate:=Value;
      mtModbusA: TFmxModuleModbusA(Module).MustUpdate:=Value;
    end;
  end;
end;

function TFmxDeviceThermometer.GetMustUpdate: boolean;
begin
  result:=False;
  if Assigned(Module) then
  begin
  case ModuleType of
    mtADC_I70XX: result:=TFmxModuleADC_I70XX(Module).MustUpdate;
    mtModbusA: result:=TFmxModuleModbusA(Module).MustUpdate;
  end;
  end;

end;


function TFmxDeviceThermometer.GetRawValue: Single;
begin
//Для разделения метрологически значимой части и не метрологически
//значимой части обычное умножение заменяем на вызов функции умножения
//из внешней dll
  Result:=0;
  with Settings do
  case ModuleType of
    mtT:
      //Result := (TFmxModuleT(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         result:=TFmxModuleT(Module).Temperatures[InputNumber];
    mtTemp2:
      //Result := (TFmxModuleTemp2(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=TFmxModuleTemp2(Module).Temperatures[InputNumber];
{!} mtTemp6:
      //Result := (TFmxModuleTemp6(Module).Temperatures[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=TFmxModuleTemp6(Module).Temperatures[InputNumber];
{!} mtADC_I70XX:
      if Assigned(Module) then
         Result:=TFmxModuleADC_I70XX(Module).Value[InputNumber];
    mtUI:
      //Result := (TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=TFmxModuleUI(Module).InputValues[InputNumber];
    mtOldUI:
      //Result := (TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=TFmxModuleOldUI(Module).InputValues[InputNumber];
    mtIVTM:
      //Result := (TFmxModuleUI(Module).InputValues[InputNumber] - CalibrationNull) * CalibrationCoefficient;
      if Assigned(Module) then
         Result:=TFmxModuleIVTM(Module).Value[InputNumber];
    mtLTA,
    mtManual:
      Result:=FValue;
    mtKM5:
      if Assigned(Module) then
         Result:=TFmxModuleKM5(Module).Values[InputNumber];
    mtModbusA:
      if Assigned(Module) then
         Result:=TFmxModuleModbusA(Module).InputValues[InputNumber];
    else
      Result := 0;
  end;
end;

procedure TFmxDeviceThermometer.SetValue(const Value: Double);
begin
  if ModuleType in [mtManual,mtLTA] then
     FValue:=Value;
end;

//============================================================================================================

constructor TFmxDeviceThermometer.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer; address: integer;BR: Cardinal; input_number: Byte;AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);
begin
  inherited Create;
  ModuleType := AModuleType;
  with settings do
  begin
    CalibrationCoefficient := 1;
    CalibrationNull := 0;
  end;
  case ModuleType of
  mtT: begin
          if input_number < 8 then InputNumber := input_number
          else InputNumber := 0;
       end;
  mtTemp2: begin
          if input_number < 4 then InputNumber := input_number
          else InputNumber := 0;
       end;
  mtADC_I70XX: begin
          if input_number < 8 then InputNumber := input_number
          else InputNumber := 0;
       end;
  mtTemp6: begin
          if input_number < 6 then InputNumber := input_number
          else InputNumber := 0;
       end;
  mtOldUI:begin
          if input_number <= 7 then InputNumber := input_number
          else InputNumber := 0;
       end;
  mtUI:begin
          if input_number <= 7 then InputNumber := input_number
          else InputNumber := 0;
       end;
  mtKM5:begin
          if input_number <= 3 then InputNumber := input_number
          else InputNumber := 0;
       end;
   else begin
       InputNumber := input_number;
   end;
  end;

  if not (ModuleType in [mtManual,mtLTA]) then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;
  MaxChannels:=8;
end;

//============================================================================================================
(*
constructor TFmxDeviceThermometer.CreateOnModuleTemp2(address: Byte;BR: Cardinal; input_number: Byte);
begin
  inherited Create;

  CalibrationCoefficient := 1;
  CalibrationNull := 0;
  if input_number < 4 then InputNumber := input_number
  else InputNumber := 0;
  ModuleType := Temp2;

  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(Temp2,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;
*)
{ !!! }
//============================================================================================================
(*
constructor TFmxDeviceThermometer.CreateOnModuleTemp6(address: Byte;BR: Cardinal; input_number: Byte);
begin
  inherited Create;

  CalibrationCoefficient := 1;
  CalibrationNull := 0;
  if input_number < 6 then InputNumber := input_number
  else InputNumber := 0;
  ModuleType := Temp6;

  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(Temp6,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;
*)
//============================================================================================================
(*
constructor TFmxDeviceThermometer.CreateOnModuleUI(address: Byte;BR: Cardinal; input_number: Byte);
begin
  inherited Create;

  if input_number <= 7 then InputNumber := input_number
  else InputNumber := 0;
  CalibrationCoefficient := 1;
  CalibrationNull := 0;
  ModuleType := UI;

  CreateDeviceManagerIfNotCreated;
  Module := DeviceManager.DetermineModule(UI,BR, address);
  FModuleManager := DeviceManager.ModuleManager;
end;
*)
//============================================================================================================
(*
constructor TFmxDeviceThermometer.CreateOnModuleVirt;
begin
  inherited Create;
  ModuleType:=Virt;
end;
*)
//============================================================================================================
destructor TFmxDeviceThermometer.Destroy;
begin
  (*if ModuleType<>mtVirt then*) inherited;
end;

//============================================================================================================

procedure TFmxDeviceThermometer.AddReceiver(receiver: TProcedureOfObject; use_main_thread: Boolean = true);
begin
//  if ModuleType<>mtVirt then
    inherited;
end;

//============================================================================================================

function TFmxDeviceThermometer.UpdateStatus: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case ModuleType of
    mtModbusA: Result := TFmxModuleModbusA(Module).UpdateStatus;
    mtT: Result := TFmxModuleT(Module).UpdateStatus;
    mtTemp2: Result := TFmxModuleTemp2(Module).UpdateStatus;
    mtADC_I70XX: Result := TFmxModuleADC_I70XX(Module).UpdateStatus;
    mtTemp6: Result := TFmxModuleTemp6(Module).UpdateStatus;
    mtUI:Result := TFmxModuleUI(Module).UpdateStatus;
    mtOldUI:Result := TFmxModuleOldUI(Module).UpdateStatus;
    mtIVTM:Result := TFmxModuleIVTM(Module).UpdateStatus;
    mtManual: Result := True;
    mtKM5: Result := TFmxModuleKM5(Module).UpdateWaterDischarge;
    else Result := false;
  end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

//============================================================================================================
//-------------------- TFmxDeviceVoltmeter --------------------
//============================================================================================================

function TFmxDeviceVoltmeter.GetPhysicalValue: Double;
begin
  with settings do
  case ModuleType of
    mtADC_I70XX:Result := ( TFmxModuleADC_I70XX(Module).Value[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
    mtModbusA:Result := ( TFmxModuleModbusA(Module).InputValues[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
    mtOldUI:Result := ( TFmxModuleOldUI(Module).InputValues[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
    mtUI:Result := ( TFmxModuleUI(Module).InputValues[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
    mtAgat:Result := ( TFmxModuleAgat(Module).Values[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
    mtFastwelUI:
      case FInputType of
        0:    Result := ( TFmxModuleFastwelUI(Module).InputValuesU[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
        1:    Result := ( TFmxModuleFastwelUI(Module).InputValuesI[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
      end;
  end;
end;

function TFmxDeviceVoltmeter.GetRAWValue: Double;
begin
  with settings do
  case ModuleType of
    mtADC_I70XX:Result := TFmxModuleADC_I70XX(Module).Value[ChannelNumber];
    mtModbusA:Result := TFmxModuleModbusA(Module).InputValues[ChannelNumber];
    mtOldUI:Result := TFmxModuleOldUI(Module).InputValues[ChannelNumber];
    mtUI:Result := TFmxModuleUI(Module).InputValues[ChannelNumber];
    mtAgat:Result := TFmxModuleAgat(Module).Values[ChannelNumber];
    mtFastwelUI:
      case FInputType of
        0:    Result := TFmxModuleFastwelUI(Module).InputValuesU[ChannelNumber];
        1:    Result := TFmxModuleFastwelUI(Module).InputValuesI[ChannelNumber];
      end;
  end;
end;


function TFmxDeviceVoltmeter.GetVolume: Double;
begin
  result:=0; { TODO : Добавить расчет объема }
end;

function TFmxDeviceVoltmeter.GetAddr: integer;
begin
  result:=0;
  if Assigned(Module) then
  case ModuleType of
    mtModbusA: Result :=  TFmxModuleModbusA(Module).Address;
    mtOldUI:   Result := TFmxModuleOldUI(Module).Address;
    mtUI:Result := TFmxModuleUI(Module).Address;
    mtADC_I70XX:Result := TFmxModuleADC_I70XX(Module).Address;
    mtAgat:Result := TFmxModuleAgat(Module).Address;
    mtFastwelUI: Result := TFmxModuleFastwelUI(Module).Address;
  end;

end;

function TFmxDeviceVoltmeter.GetBaudrate: longword;
begin
  result:=0;
  if Assigned(Module) then
  case ModuleType of
    mtModbusA: result:=TFmxModuleModbusA(Module).Baudrate;
    mtOldUI:   result:=TFmxModuleOldUI(Module).Baudrate;
    mtUI: result:=TFmxModuleUI(Module).Baudrate;
    mtADC_I70XX: result:=TFmxModuleADC_I70XX(Module).Baudrate;
    mtAgat:result:=TFmxModuleAgat(Module).Baudrate;
    mtFastwelUI: result:=TFmxModuleFastwelUI(Module).Baudrate;
  end;
end;

function TFmxDeviceVoltmeter.GetInfo: String;
begin
  result:=#9+'('+inherited+Format(' В:%d',[FChannelNumber+1])+')';
end;

procedure TFmxDeviceVoltmeter.SetAddr(const Value: integer);
begin
  if Assigned(Module) then
  case ModuleType of
    mtModbusA: TFmxModuleModbusA(Module).Address:=Value;
    mtOldUI:   TFmxModuleOldUI(Module).Address:=Value;
    mtUI: TFmxModuleUI(Module).Address:=Value;
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).Address:=Value;
    mtAgat:TFmxModuleAgat(Module).Address:=Value;
    mtFastwelUI: TFmxModuleFastwelUI(Module).Address:=Value;
  end;
end;

procedure TFmxDeviceVoltmeter.SetBaudrate(const Value: longword);
begin
  if Assigned(Module) then
  case ModuleType of
    mtModbusA: TFmxModuleModbusA(Module).Baudrate:=Value;
    mtOldUI:   TFmxModuleOldUI(Module).Baudrate:=Value;
    mtUI: TFmxModuleUI(Module).Baudrate:=Value;
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).Baudrate:=Value;
    mtAgat:TFmxModuleAgat(Module).Baudrate:=Value;
    mtFastwelUI: TFmxModuleFastwelUI(Module).Baudrate:=Value;
  end;
end;

procedure TFmxDeviceVoltmeter.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TFmxDeviceVoltmeter.SetChannelNumber(const Value: Byte);
begin
  FChannelNumber := Value;
end;



procedure TFmxDeviceVoltmeter.SetIntegralCounter(const Value: longword);
begin
  FIntegralCounter := Value;
end;

procedure TFmxDeviceVoltmeter.SetIntegralValue(const Value: Double);
begin
  FIntegralValue := Value;
end;

procedure TFmxDeviceVoltmeter.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Module) then
  case ModuleType of
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).MaxChannels:=Value;
  end;

end;

procedure TFmxDeviceVoltmeter.SetMaxOutlay(const Value: Single);
begin
  FMaxOutlay := Value;
end;

procedure TFmxDeviceVoltmeter.SetMaxPhysicalValue(const Value: Double);
begin
  FMaxPhysicalValue := Value;
end;


procedure TFmxDeviceVoltmeter.SetMinPhysicalValue(const Value: Double);
begin
  FMinPhysicalValue := Value;
end;

procedure TFmxDeviceVoltmeter.SetMinOutlay(const Value: Single);
begin
  FMinOutlay := Value;
end;

procedure TFmxDeviceVoltmeter.SetPort(const Value: integer);
begin
  if Assigned(Module) then
  case ModuleType of
    mtModbusA: TFmxModuleModbusA(Module).PortNumber:=Value;
    mtOldUI:   TFmxModuleOldUI(Module).PortNumber:=Value;
    mtUI: TFmxModuleUI(Module).PortNumber:=Value;
    mtADC_I70XX: TFmxModuleADC_I70XX(Module).PortNumber:=Value;
    mtAgat:TFmxModuleAgat(Module).PortNumber:=Value;
    mtFastwelUI: TFmxModuleFastwelUI(Module).PortNumber:=Value;
  end;
end;

procedure TFmxDeviceVoltmeter.SetStarted(const AValue: Boolean);
begin
  if FStarted <> AValue then
  begin
    if not FStarted then
    begin
      //Начался счет
      FIntegralCounter:=1;
      FIntegralValue:=Value;
    end;
    FStarted := AValue;
  end;
end;

procedure TFmxDeviceVoltmeter.SetStartStopTime(const Value: Double);
begin
  FStartStopTime := Value;
end;

procedure TFmxDeviceVoltmeter.SetTopOutlay(const Value: Single);
begin
  FTopOutlay := Value;
end;

function TFmxDeviceVoltmeter.SetupCount: Boolean;
begin
  { TODO : Возможна настройка канала }
  result:=True;
end;

function TFmxDeviceVoltmeter.StartCount(aInterval: integer): Boolean;
begin
  { TODO : Возможна настройка старта канала, aInterval пока не используем}
  Started:=True;
  IntegralValue:=Value;
  FIntegralCounter:=1;
  result:=True;
end;

function TFmxDeviceVoltmeter.StopCount: Boolean;
begin
  { TODO : Возможна настройка останова счета канала }
  Started:=False;
end;

function TFmxDeviceVoltmeter.GetMaxPhysicalValue: Double;
begin
  result:=FMaxPhysicalValue;
end;

//============================================================================================================

function TFmxDeviceVoltmeter.GetMeanValue: Double;
begin
  with settings do
  case ModuleType of
    mtADC_I70XX,
    mtOldUI,
    mtUI,
    mtAgat: begin
               if Started or (FIntegralCounter>0) then
               begin
                 if Started then
                 begin
                   IntegralValue:=IntegralValue+Value;
                   inc(FIntegralCounter);
                 end;
                 result:=IntegralValue/FIntegralCounter;
               end
               else
                result:=Value;
            end;
    mtFastwelUI:
      case FInputType of
        0:    Result := ( TFmxModuleFastwelUI(Module).MeanValuesU[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
        1:    Result := ( TFmxModuleFastwelUI(Module).MeanValuesI[ChannelNumber] - CalibrationNull ) * CalibrationCoefficient;
      end;
  end;
end;

function TFmxDeviceVoltmeter.GetMinPhysicalValue: Double;
begin
  result:=FMinPhysicalValue;
end;

{

     Набор параметров:
    Param1 - для аналоговых выходов минимальное значение сигнала, для частотных - коэффициент
             преобразования (устанавливается 0 для МИ), для интерфейса - адрес прибора;
    Param2 - для аналоговых выходов максимальное значение сигнала, для частотных определяет тип коэффициента
             преобразования ( =0 - имп/л, <>0 - л/имп);  для цифры - Тип библиотеки и тип визуализации адреса
    Param3 - для аналоговых выходов максимальный расход, для частотных определяет тип выхода ( <0 - пассивный,
             >0 - активный, =0 - оптосчитыватель). для цифры  - скорость обмена

      if Channels[cnl].OutputType in [otCurrent, otVoltage] then
      begin
        CertifiableValue := (Total_mean_analog_values[cnl - 1] - Channels[cnl]
          .Param1) / (Channels[cnl].Param2 - Channels[cnl].Param1) *
          Channels[cnl].Param3 / 3.6 * RSpillTime;
        SampleValue := TotalVolume;
      end

}


function TFmxDeviceVoltmeter.GetOutlay: Single;
begin
 try
  if (MaxPhysicalValue-MinPhysicalValue)>0 then
  begin
    if (StartStopTime=0) then
      result:=(MeanPhysicalValue-MinPhysicalValue)/(MaxPhysicalValue-MinPhysicalValue)*TopOutlay/3.6
    else
      result:=(MeanPhysicalValue-MinPhysicalValue)/(MaxPhysicalValue-MinPhysicalValue)*TopOutlay/3.6*StartStopTime;
  end
  else
    result:=0;//не сконфигурировал канал
 except
  result:=0;
 end;
end;

function TFmxDeviceVoltmeter.GetPort: integer;
begin
  result:=0;
  if Assigned(Module) then
  case ModuleType of
    mtModbusA: result:=TFmxModuleModbusA(Module).PortNumber;
    mtOldUI:   result:=TFmxModuleOldUI(Module).PortNumber;
    mtUI: result:=TFmxModuleUI(Module).PortNumber;
    mtADC_I70XX: result:=TFmxModuleADC_I70XX(Module).PortNumber;
    mtAgat:result:=TFmxModuleAgat(Module).PortNumber;
    mtFastwelUI: result:=TFmxModuleFastwelUI(Module).PortNumber;
  end;
end;

//============================================================================================================

constructor TFmxDeviceVoltmeter.CreateOnModule(
  AModbusTCPHost:string;
  AModbusTCPPort:word;
  port:integer;
  address: integer;
  BR: Cardinal;
  channel_number: Byte;
  AModuleType:TFmxModuleType;
  InputType:byte;
  _typeofprotocol:TTypeOfProtocol;
  InputReg:Word);
begin
  inherited Create;
  if AModuleType in [mtADC_I70XX,mtUI,mtOldUI,mtFastwelUI] then
  begin
    if channel_number <= 7 then ChannelNumber := channel_number
    else ChannelNumber := 0;
  end
  else if AModuleType in [mtAgat] then
  begin
    if channel_number <= 3 then ChannelNumber := channel_number
    else ChannelNumber := 0;
  end
  else begin
    ChannelNumber := channel_number;
  end;

  with settings do
  begin
    CalibrationCoefficient := 1;
    CalibrationNull := 0;
  end;
  ModuleType := AModuleType;

  if ModuleType<>mtManual then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;
  FInputType:=InputType;
  if InputType=0 then
  begin
    //для тока по умолчанию задаем шкалу 4..20 мА
    MinPhysicalValue:=4;
    MaxPhysicalValue:=20;
  end
  else begin
    //для напряжения - 0..10 В
    MinPhysicalValue:=0;
    MaxPhysicalValue:=10;
  end;
  Addr:=address;
  PortNumber:=port;
  Baudrate:=BR;
  MaxChannels:=8;
end;

//============================================================================================================

function TFmxDeviceVoltmeter.UpdateStatus: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case ModuleType of
    mtModbusA: Result := TFmxModuleModbusA(Module).UpdateStatus;
    mtOldUI:  Result := TFmxModuleOldUI(Module).UpdateStatus;
    mtUI:  Result := TFmxModuleUI(Module).UpdateStatus;
    mtADC_I70XX:  Result := TFmxModuleADC_I70XX(Module).UpdateStatus;
    mtAgat:  Result := TFmxModuleAgat(Module).UpdateValues;//запрашиваем значение параметра
    mtFastwelUI:  Result := TFmxModuleFastwelUI(Module).UpdateStatus;
    mtManual:  Result := True;
  end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

//============================================================================================================

function TFmxDeviceVoltmeter.UpdateMeans: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case ModuleType of
    mtModbusA: Result := TFmxModuleModbusA(Module).UpdateStatus;
    mtManual:result:=True;
    mtOldUI:  Result := false;
    mtUI:  Result := false;
    mtAgat:  Result := false;
    mtFastwelUI:  Result := TFmxModuleFastwelUI(Module).GetMeans;
  end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

//============================================================================================================


procedure TFmxDeviceFlowmeter.SetSelected(const Value: Boolean);
begin
  if not Assigned(Module) then Exit;
  if ModuleType=mtCounterEx then
     TFmxModuleCounterEx(Module).CertifiableCounterIsActive[PairNumber]:=Value
  else if ModuleType=mtHSC_IMP then
  begin
     TFmxModuleHSC_IMP(Module).CounterIsActive[PairNumber]:=Value;
     if Value then TFmxModuleHSC_IMP(Module).MasterMode:=True;
  end
  else if ModuleType=mtCounter then
     TFmxModuleCounter(Module).Selected[PairNumber]:=Value
  else if ModuleType=mtKM5 then
     TFmxModuleKM5(Module).Selected:=Value;
end;

function TFmxDeviceFlowmeter.GetVersion: String;
begin
  if ModuleType=mtCounter then
     result:='V1.0'
  else if ModuleType=mtCounter then
     result:=TFmxModuleCounterEx(Module).Version
  else if ModuleType=mtHSC_IMP then
     result:=TFmxModuleHSC_IMP(Module).Version
  else if ModuleType=mtKM5 then
     result:=TFmxModuleKM5(Module).Version;
end;

function TFmxDeviceFlowmeter.GetVolume: Double;
var i:integer;
    Val:Double;
begin
  if ModuleType=mtKM5 then
     Result :=TFmxModuleKM5(Module).Volume
  else if ModuleType in [mtCounterEx,mtCounter,mtHSC_IMP] then
  begin
    Val:=Impulse*current_settings.ImpulseWeight * CalculateCalibrationCoefficient;
    Result:=val;
  end
  else if ModuleType=mtManual then
    Result := Impulse * current_settings.ImpulseWeight
  else
    Result :=0;

end;


procedure TFmxDeviceFlowmeter.SetCounterIsActive(index: Byte;
  const Value: Boolean);
begin
  case ModuleType of
    mtCounter: begin
        if index < 8 then TFmxModuleCounter(Module).CounterIsActive[index]:=Value;
      end;
    mtCounterEx: begin
        if index < 8 then TFmxModuleCounterEx(Module).TestCounterIsActive[index]:=Value;
      end;
    mtHSC_IMP: begin
        if index < 15 then TFmxModuleHSC_IMP(Module).CounterIsActive[index]:=Value;
      end;
  end;
end;

procedure TFmxDeviceFlowmeter.SetCurrentKoeff(const Value: Single);
begin
  FCurrentKoeff := Value;
end;

procedure TFmxDeviceFlowmeter.SetDependentImpulseMode(aDepenededMode: boolean);
begin
  if ModuleType=mtCounter then
    TFmxModuleCounter(Module).SetDependentImpulseMode(aDepenededMode)
  else if ModuleType=mtHSC_IMP then
  begin
    { TODO : Проверить - Возможно для HSC_IMP этот код понадобится }
  end;
end;


procedure TFmxDeviceFlowmeter.SetFrequency(const Value: Single);
begin
   FFrequency:=Value;
end;

procedure TFmxDeviceFlowmeter.SetImpulse(const Value: Single);
begin
  FImpulse:=Value;
end;

procedure TFmxDeviceFlowmeter.SetMassCounter(const Value: Boolean);
begin
  FMassCounter := Value;
end;

procedure TFmxDeviceFlowmeter.SetMasterMode(const Value: boolean);
begin
  FMasterMode := Value;
  if (ModuleType=mtHSC_IMP) and Assigned(Module) then
    TFmxModuleHSC_IMP(Module).MasterMode:=Value;
end;

procedure TFmxDeviceFlowmeter.SetMustUpdate(const Value: boolean);
begin
  inherited;
  if Assigned(Module) then
     Module.MustUpdate:=Value;
end;

procedure TFmxDeviceFlowmeter.SetPairNumber(const Value: byte);
begin
  FPairNumber := Value;
end;

procedure TFmxDeviceFlowmeter.SetRequestMasterSlaveTogether(const Value: boolean);
begin
  FRequestMasterSlaveTogether := Value;
end;

function TFmxDeviceFlowmeter.RequestVolumes_Status: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
  result:=True;
  if ModuleType=mtCounterEx then
  begin
    //запрашиваем данные в контроллере
    Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_D;//D
    Result := TFmxModuleCounterEx(Module).UpdateSlaveCounters_A_B;//Команда A и B - запрос поверяемых объемов
    Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_C_E;//команда C
    Result := TFmxModuleCounterEx(Module).UpdateStatus_S;//команда S
  end
  else if ModuleType=mtHSC_IMP then
  begin
    //запрашиваем данные в контроллере
    Result := TFmxModuleHSC_IMP(Module).UpdateImpulseCounters;
  end
  else if ModuleType=mtCounter then
  begin
    Result := TFmxModuleCounter(Module).UpdateImpulseCounters;
  end
  else if ModuleType=mtKM5 then
  begin
    Result := TFmxModuleKM5(Module).UpdateVolume();
    Result := TFmxModuleKM5(Module).UpdateStatus();
  end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

function TFmxDeviceFlowmeter.GetMasterVolume(index:byte): Double;
begin
  if ModuleType=mtCounter then
  begin
     Result :=0;
  end
  else if ModuleType=mtCounterEx then
  begin
   try
    //пробегаемся по
    Result := TFmxModuleCounterEx(Module).MasterFlowmeterImpCounters_C_E[index,PairNumber];
    Result := Result * CalculateCalibrationCoefficient;
    // Умножение частоты на вес импульса дает расход в л/с, поэтому умножаем на 3.6
    Result := Result * current_settings.ImpulseWeight;
   except
   end;
  end
  else if ModuleType=mtHSC_IMP then
  begin             { TODO :
                      Проверить - верно ли все организовано
                      т.к. это другой тип
                    }
   try
    //пробегаемся по
    Result := TFmxModuleHSC_IMP(Module).ResultImpulses[index];
    Result := Result * CalculateCalibrationCoefficient;
    // Умножение частоты на вес импульса дает расход в л/с, поэтому умножаем на 3.6
    Result := Result * current_settings.ImpulseWeight;
   except
   end;
  end
  else if ModuleType=mtKM5 then
  begin
   try
    //пробегаемся по
    Result := TFmxModuleKM5(Module).Volume;
    Result := Result * CalculateCalibrationCoefficient;
   except
   end;

  end;


end;


function TFmxDeviceFlowmeter.GetProtocolID: word;
begin
  if ModuleType=mtCounterEx then
    Result := 2
  else if ModuleType=mtCounter then
    Result := 1
  else if ModuleType=mtHSC_IMP then
    Result := TFmxModuleHSC_IMP(Module).ProtocolID
  else
    Result := 0;
end;

procedure TFmxDeviceFlowmeter.SetSpillTime(const Value: Single);
var i:integer;
begin
  FSpillTime := Value;
//  for i := 0 to 7 do
//     LastSecondaryImpulses[i]:=Round(Value*10000);
end;



procedure TFmxDeviceFlowmeter.SetTypeOfInput(const Value: Byte);
begin
  FTypeOfInput := Value;
end;

procedure TFmxDeviceFlowmeter.SetUnSelected(const Value: boolean);
begin
  FUnSelected := Value;
  if Assigned(AddToWorkLogProc) then
  if Value then
     AddToWorkLogProc(DeviceName+': Неактивен...',awlHard)
  else
     AddToWorkLogProc(DeviceName+': Активный...',awlHard);
end;

function TFmxDeviceScales.GetDumbbellsDensity: double;
var i,cnt:integer;

begin
  result:=0;cnt:=0;
  for i := 0 to 3 do
  begin
    if FDumbbellsDensity0[i]<>0 then
    begin
      result:=result+FDumbbellsDensity0[i];
      inc(cnt);
    end;
  end;
  if cnt<>0 then
     result:=result/cnt;
end;

procedure TFmxDeviceScales.SetDumbbellsDensity(const Value: double);
var i:integer;
begin
  for i := 0 to 3 do
  begin
    FDumbbellsDensity0[i]:=Value;
  end;  
end;

procedure TFmxDevicePneumaticValve.SetCloseINumber(const Value: byte);
begin
  FCloseINumber := Value;
end;

procedure TFmxDevicePneumaticValve.SetCloseONumber(const Value: byte);
begin
  FCloseONumber := Value;
end;

procedure TFmxDevicePneumaticValve.SetCloseTickCount(const Value: Cardinal);
begin
  FCloseTickCount := Value;
end;

procedure TFmxDevicePneumaticValve.SetLastCmd(const Value: boolean);
begin
  if Value then
     FLastCmd := 1
  else
     FLastCmd := 2;

  if Assigned(AddToWorkLogProc) then
  if Value then
     AddToWorkLogProc(DeviceName+': крайняя команда - Открытие...',awlHard)
  else
     AddToWorkLogProc(DeviceName+': крайняя команда - Закрытие...',awlHard);
end;

procedure TFmxDevicePneumaticValve.SetOpenINumber(const Value: byte);
begin
  FOpenINumber := Value;
end;

procedure TFmxDevicePneumaticValve.SetOpenONumber(const Value: byte);
begin
  FOpenONumber := Value;
end;

procedure TFmxDevicePneumaticValve.SetOpenTickCount(const Value: Cardinal);
begin
  FOpenTickCount := Value;
end;


procedure TFmxDevicePneumaticValve.SetWithInput(const Value: boolean);
begin
  FWithInput := Value;
end;

function TFmxDeviceElectricValve.Opened: boolean;
begin
  result:=Position>=cHSC_CTRL_OpenPosition;
end;

procedure TFmxDeviceElectricValve.Close;
begin
  if (TimeToSwitch>0) and (Position<>0) then
  begin
     //Запоминаем направление
     StartedPos:=Position;
     DeltaPos:=Position;
     CommandDirection:=False;
  end;
  //отрабатываем команду
  try
   Module.LastDevice:=self;
     MoveValve(0)
  finally
   Module.LastDevice:=nil;
  end;
end;

procedure TFmxDeviceElectricValve.Open;
begin
  if (TimeToSwitch>0) and (Position<>100) then
  begin
     //Запоминаем направление
     StartedPos:=Position;
     DeltaPos:=100-Position;
     if DeltaPos>0 then
         FullCommandTime:=(TimeToSwitch / DeltaPos)+1;
     CommandDirection:=True;
  end;
  //отрабатываем команду
  try
   Module.LastDevice:=self;
   MoveValve(100)
  finally
   Module.LastDevice:=nil;
  end;
end;


function TFmxDeviceVoltmeter.GetQuality: TFmxDeviceQuality;
begin
  case ModuleType of
    mtManual: result:=fdqGood;
    mtModbusA: Result := TFmxModuleModbusA(Module).ConnectIsOK;
    mtOldUI:Result := TFmxModuleOldUI(Module).ConnectIsOK;
    mtUI:Result :=  TFmxModuleUI(Module).ConnectIsOK;
    mtADC_I70XX:Result :=  TFmxModuleADC_I70XX(Module).ConnectIsOK;
    mtFastwelUI: Result :=  TFmxModuleFastwelUI(Module).ConnectIsOK;
  end;

end;

procedure TFmxDeviceBlcedValve.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Module) then
  case ModuleType of
    mtHSC_CTRL: TFmxModuleHsc_Ctrl(Module).MaxChannels:=Value;
  end;
end;

procedure TFmxDeviceBlcedValve.SetStartInputNumber(const Value: Byte);
begin
  FStartInputNumber := Value;
end;

procedure TFmxDeviceBlcedValve.SetStartOutputNumber(const Value: Byte);
begin
  FStartOutputNumber := Value;
end;

procedure TFmxDeviceBlcedValve.SetStopInputNumber(const Value: Byte);
begin
  FStopInputNumber := Value;
end;

procedure TFmxDeviceBlcedValve.SetStopOutputNumber(const Value: Byte);
begin
  FStopOutputNumber := Value;
end;

procedure TFmxDeviceBlcedValve.SetTwoSwitch(const Value: Boolean);
begin
  FTwoSwitch := Value;
end;

procedure TFmxDeviceBlcedValve.SetWithInput(const Value: boolean);
begin
  FWithInput := Value;
end;



function TFmxDeviceBlcedValve.Stop: Boolean;
begin
  if not Assigned(Module) then Exit;
  try
    Module.LastDevice:=self;
    //выключаем стоповый выход - если используются два канала управления и стоповый активен
    if TwoSwitch (*and prevstate*) then
      case ModuleType of
        mtModbusD: Result := TFmxModuleModbusD(Module).SetOutput(StopOutputNumber, False);
        mtBIO: Result := TFmxModuleBIO(Module).SetOutput(StopOutputNumber, False);
        mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).SetOutput(StopOutputNumber, False);
        mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).SetOutput(StopOutputNumber, False);
        mtSuperBIO: Result := TFmxModuleSuperBIO(Module).SetOutput(StopOutputNumber, False);
        mtValve: Result := TFmxModuleValve(Module).SetOutput(StopOutputNumber, False);
        else Result := false;
      end;
    //Выключаем стартовый выход если он активен
      case ModuleType of
        mtHSC_FCD: Result := TFmxModuleHSC_FCD(Module).SetOutput(StartOutputNumber, false);
        mtModbusD: Result := TFmxModuleModbusD(Module).SetOutput(StartOutputNumber, false);
        mtBIO: Result := TFmxModuleBIO(Module).SetOutput(StartOutputNumber, false);
        mtHSC_CTRL: Result := TFmxModuleHsc_Ctrl(Module).SetOutput(StartOutputNumber, false);
        mtSuperBIO: Result := TFmxModuleSuperBIO(Module).SetOutput(StartOutputNumber, false);
        mtValve: Result := TFmxModuleValve(Module).SetOutput(StartOutputNumber, false);
        else Result := false;
      end;
  finally
    Module.LastDevice:=nil;
  end;

end;

{ TFmxDeviceIVTM }

procedure TFmxDeviceIVTM.AddReceiver(receiver: TProcedureOfObject;
  use_main_thread: Boolean);
begin
  inherited;

end;

constructor TFmxDeviceIVTM.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer; address: integer; BR: Cardinal;
  AModuleType: TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);
begin
  inherited Create;
  ModuleType := AModuleType;
  if ModuleType<>mtManual then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;
end;

destructor TFmxDeviceIVTM.Destroy;
begin
  inherited;
end;

function TFmxDeviceIVTM.GetH_Value: Double;
begin
  case ModuleType of
    mtIVTM:
      Result:=TFmxModuleIVTM(Module).H;
    mtManual:
      Result:=FHValue;
    else
      Result := 0;
  end;
end;

function TFmxDeviceIVTM.GetP_Value: Double;
begin
  case ModuleType of
    mtIVTM:
      Result:=TFmxModuleIVTM(Module).P;
    mtManual:
      Result:=FPValue;
    else
      Result := 0;
  end;
end;

function TFmxDeviceIVTM.GetT_Value: Double;
begin
  case ModuleType of
    mtIVTM:
      Result:=TFmxModuleIVTM(Module).T;
    mtManual:
      Result:=FTValue;
    else
      Result := 0;
  end;
end;


procedure TFmxDeviceIVTM.ReceiveResponse;
begin
  inherited;
end;

procedure TFmxDeviceIVTM.SetFromBalance(const Value: boolean);
begin
  FFromBalance := Value;
  case ModuleType of
  mtIVTM:TFmxModuleIVTM(Module).FromBalance:=Value;
  end;
end;

procedure TFmxDeviceIVTM.SetH_Value(const Value: Double);
begin
  if ModuleType=mtManual then
    FHValue:=Value;
end;

procedure TFmxDeviceIVTM.SetP_Value(const Value: Double);
begin
  if ModuleType=mtManual then
    FPValue:=Value;
end;

procedure TFmxDeviceIVTM.SetT_Value(const Value: Double);
begin
  if ModuleType=mtManual then
    FTValue:=Value;
end;


procedure TFmxDeviceIVTM.SetUse_H(const Value: boolean);
begin
  FUse_H := Value;
  case ModuleType of
  mtIVTM:TFmxModuleIVTM(Module).Use_H:=Value;
  end;
end;

procedure TFmxDeviceIVTM.SetUse_P(const Value: boolean);
begin
  FUse_P := Value;
  case ModuleType of
  mtIVTM:TFmxModuleIVTM(Module).Use_P:=Value;
  end;
end;

procedure TFmxDeviceIVTM.SetUse_T(const Value: boolean);
begin
  FUse_T := Value;
  case ModuleType of
  mtIVTM:TFmxModuleIVTM(Module).Use_T:=Value;
  end;
end;

function TFmxDeviceIVTM.UpdateStatus: Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
    case ModuleType of
    mtModbusA: Result := TFmxModuleModbusA(Module).UpdateStatus;
    mtIVTM:Result := TFmxModuleIVTM(Module).UpdateStatus;
    mtManual: Result := True;
    else Result := false;
  end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

{ TFmxDevicePumpStartStop }


function TFmxDevicePumpStartStop.Init: Boolean;
begin
  try
   Module.LastDevice:=self;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Инициализация блока включения/выключения',awlHard);
  case ModuleType of
    mtVLT6000: Result := TFmxModuleVLT6000(Module).Init;
    mtATV312: Result := TFmxModuleATV312(Module).Init;
  end;
 finally
   Module.LastDevice:=nil;
 end;
end;

procedure TFmxDevicePumpStartStop.SetIONumber(const Value: byte);
begin
  if IONumberCorrect(Value) then
     FIONumber := Value;
end;

procedure TFmxDevicePumpStartStop.SetStarted(const Value: Boolean);
begin
  if IONumberCorrect(IONumber) and Assigned(Module) then
  case ModuleType of
    mtABBModbus: TFmxModuleABBModbus(Module).Started:=Value;
    mtDeltaModbus: TFmxModuleDeltaModbus(Module).Started:=Value;
    mtModbusD: TFmxModuleModbusD(Module).SetOutput(self.IONumber,Value);
    mtVLT6000: TFmxModuleVLT6000(Module).Started:=Value;
    mtATV312: TFmxModuleATV312(Module).Started:=Value;
    mtVLTModbus: TFmxModuleVLTModbus(Module).Started:=Value;
    mtVaconModbus: TFmxModuleVACONModbus(Module).Started:=Value;
    mtRT2: TFmxModuleRT2(Module).output[IONumber]:=Value;
    mtLogoDAC: TFmxModuleLogoDAC(Module).Start[IONumber]:=Value;
  end;
end;



procedure TFmxDevicePumpStartStop.SetWithInput(const Value: boolean);
begin
  FWithInput := Value;
end;

{ TFmxDeviceCounter }

constructor TFmxDeviceCounter.CreateOnModule(AModbusTCPHost:string;AModbusTCPPort:word;port:integer;_addr: Byte; BR: Cardinal; Cnl:integer; AModuleType:TFmxModuleType;_typeofprotocol:TTypeOfProtocol;InputReg:Word);

begin
  inherited Create;
  ModuleType := AModuleType;
  ChannelNumber:=Cnl;
  ConversionCoefficientInLiterPerImpulse:=False;
  if ModuleType<>mtManual then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, _addr,_typeofprotocol,InputReg);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;
  Addr:=_addr;
  PortNumber:=port;
  Baudrate:=BR;
end;



function TFmxDeviceCounter.GetAddr: integer;
begin
  Result := 0;
  if not Assigned(Module) then Exit;
    case ModuleType of
      mtCounter: begin
          Result := TFmxModuleCounter(Module).Address;
        end;
      mtHSC_IMP: begin
          Result := TFmxModuleHSC_IMP(Module).Address;
        end;
      mtCounterEx: begin
          result:=TFmxModuleCounterEx(Module).Address;
        end;
    end;
end;

function TFmxDeviceCounter.GetBaudrate: longword;
begin
  result:=0;
  if Assigned(Module) then
  case ModuleType of
    mtCounter: begin
        result:=TFmxModuleCounter(Module).baudrate;
      end;
    mtHSC_IMP: begin
        result:=TFmxModuleHSC_IMP(Module).baudrate;
      end;
    mtCounterEx: begin
        result:=TFmxModuleCounterEx(Module).baudrate;
      end;
  end;
end;

function TFmxDeviceCounter.GetCounterIsActive: Boolean;
begin
  Result := false;
  case ModuleType of
    mtCounter: begin
        if ChannelNumber < 8 then Result := TFmxModuleCounter(Module).CounterIsActive[ChannelNumber];
      end;
    mtCounterEx: begin
        if ChannelNumber < 8 then Result := TFmxModuleCounterEx(Module).TestCounterIsActive[ChannelNumber]
      end;
    mtHSC_IMP: begin
        Result := TFmxModuleHSC_IMP(Module).CounterIsActive[ChannelNumber];
      end;
    mtManual: begin
        Result := FActive;
    end;
  end;

end;

function TFmxDeviceCounter.GetCountIsStarted: Boolean;
begin
  result:=False;
  case ModuleType of
    mtCounter: begin
        Result := TFmxModuleCounter(Module).ExternalStartStop or TFmxModuleCounter(Module).CountIsStarted;
    end;
    mtCounterEx: begin
       Result := TFmxModuleCounterEx(Module).CountIsStarted;
    end;
    mtHSC_IMP: begin
       Result := TFmxModuleHSC_IMP(Module).CountIsStarted;
    end;
    mtManual: begin
        Result := FStarted;
    end;
  end;
end;

function TFmxDeviceCounter.GetDependentImpulseModeIsActive: Boolean;
begin
  Result := False;
  case ModuleType of
  mtCounter:
    Result := TFmxModuleCounter(Module).DependentImpulseModeIsActive;
  end;
end;

function TFmxDeviceCounter.GetEnable4_7: boolean;
begin
  Result := false;
  if assigned(Module) then
    case ModuleType of
    mtCounterEx:
     Result := TFmxModuleCounterEx(Module).Enable4_7;
    end;
end;

function TFmxDeviceCounter.GetFrequency: Single;
begin
  case ModuleType of
  mtCounter:
     Result := TFmxModuleCounter(Module).CertifiableFlowmeterFrequencies[ChannelNumber];
  mtCounterEx:
     Result := TFmxModuleCounterEx(Module).SlaveFlowmeterFreq_J[ChannelNumber];
  mtHSC_IMP:
     Result := TFmxModuleHSC_IMP(Module).FlowmeterFrequencies[ChannelNumber];
  mtManual:
     Result := FFrequency;
  end;
end;


function TFmxDeviceCounter.GetCurrentTime: Integer;
begin
    result:=-1;
   case ModuleType of
    mtHSC_IMP:
      if ChannelNumber < 15 then
         Result := TFmxModuleHSC_IMP(Module).CurrentTime;
    end
end;

function TFmxDeviceCounter.GetImpulses: Single;
begin
    result:=0;
    case ModuleType of
    mtCounter:
      if ChannelNumber < 8 then
          Result := TFmxModuleCounter(Module).CertifiableFlowmeterImpulses[ChannelNumber];
    mtCounterEx:
      if ChannelNumber < 8 then
        Result := TFmxModuleCounterEx(Module).SlaveFlowmeterImpCounters_A_B[ChannelNumber];
    mtHSC_IMP:
      if ChannelNumber < 15 then
         Result := TFmxModuleHSC_IMP(Module).ResultImpulses[ChannelNumber];
   mtManual:
      Result := FImpulse;
    end
end;

function TFmxDeviceCounter.GetPort: integer;
begin
  result:=0;
  if Assigned(Module) then
  case ModuleType of
    mtCounter: begin
        result:=TFmxModuleCounter(Module).PortNumber;
      end;
    mtHSC_IMP: begin
        result:=TFmxModuleHSC_IMP(Module).PortNumber;
      end;
    mtCounterEx: begin
        result:=TFmxModuleCounterEx(Module).PortNumber;
      end;
  end;
end;

function TFmxDeviceCounter.GetQuality: TFmxDeviceQuality;
begin
  case ModuleType of
    mtCounter: begin
        Result := TFmxModuleCounter(Module).ConnectIsOK;
      end;
    mtCounterEx: begin
        result:=TFmxModuleCounterEx(Module).ConnectIsOK;
      end;
    mtHSC_IMP: begin
        result:=TFmxModuleHSC_IMP(Module).ConnectIsOK;
      end;
    mtKM5: begin
        result:=TFmxModuleKM5(Module).ConnectIsOK;
      end;
  end;

end;

function TFmxDeviceCounter.GetSlowImpulseModeIsActive: Boolean;
begin
  Result := False;
  case ModuleType of
  mtCounter:
    Result := TFmxModuleCounter(Module).SlowImpulseModeIsActive;
  end;
end;


function TFmxDeviceCounter.GetVolume: Double;
begin
  if ImpulseWeights>0 then
     Result:= Impulses / ImpulseWeights
  else
     Result:= Impulses;
end;

function TFmxDeviceCounter.GetWaterDischarge: Double;
begin
  if ImpulseWeights<>0 then
     Result:=(Frequencies/ImpulseWeights) * 3.6
  else
     Result:=Frequencies * 3.6;
end;


function TFmxDeviceCounter.Reset: Boolean;
begin
  Started:=False;
  case ModuleType of
  mtHSC_IMP:
            begin
              if Assigned(module) then
                 TFmxModuleHSC_IMP(module).Reset;
            end;
  end;
end;


function TFmxDeviceCounter.SendLockAllValues: Boolean;
begin
  Started:=False;
  case ModuleType of
  mtHSC_IMP:
            begin
              if Assigned(module) then
                 TFmxModuleHSC_IMP(module).LockAllValues;
            end;
  end;
end;

procedure TFmxDeviceCounter.SetAddr(const Value: integer);
begin
  if Assigned(Module) then
  case ModuleType of
    mtCounter: begin
        TFmxModuleCounter(Module).Address:=Value;
      end;
    mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).Address:=Value;
      end;
    mtCounterEx: begin
        TFmxModuleCounterEx(Module).Address:=Value;
      end;
  end;
end;

procedure TFmxDeviceCounter.SetAntiShatterFilter(const Value: boolean);
begin
  FAntiShatterFilter := Value;
  if Assigned(Module) then
  case ModuleType of
    mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).AntiShatterFilters[ChannelNumber]:=Value;
      end;
  end;
end;

procedure TFmxDeviceCounter.SetAntiShatterFilterTime(const Value: integer);
begin
  FAntiShatterFilterTime := Value;
  if Assigned(Module) then
  case ModuleType of
    mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).AntiShatterFilterTimes[ChannelNumber]:=Value;
      end;
  end;
end;

procedure TFmxDeviceCounter.SetBaudrate(const Value: longword);
begin
  if Assigned(Module) then
  case ModuleType of
    mtCounter: begin
        TFmxModuleCounter(Module).baudrate:=Value;
      end;
    mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).baudrate:=Value;
      end;
    mtCounterEx: begin
        TFmxModuleCounterEx(Module).baudrate:=Value;
      end;
  end;
end;

procedure TFmxDeviceCounter.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TFmxDeviceCounter.SetChannelNumber(const Value: Byte);
begin
  FChannelNumber := Value;
end;

procedure TFmxDeviceCounter.SetConversionCoefficientType(const Value: boolean);
begin
  FConversionCoefficientType := Value;
end;

procedure TFmxDeviceCounter.SetCounterIsActive(const Value: Boolean);
begin
  FActive:=Value;
  case ModuleType of
  mtHSC_IMP:
            begin
              if Assigned(module) then
                 TFmxModuleHSC_IMP(module).CounterIsActive[ChannelNumber]:=Value;
            end;
  end;

end;

procedure TFmxDeviceCounter.SetCountIsStarted(const Value: Boolean);
begin
  FStarted:=Value;
end;

function TFmxDeviceCounter.SetDependentImpulseMode(activate: Boolean): Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
      case ModuleType of
      mtCounter: begin
        if Assigned(AddToWorkLogProc) then
          if activate then AddToWorkLogProc(DeviceName+': Включение режима зависимых импульсов',awlHard)
          else AddToWorkLogProc(DeviceName+': Выключение режима зависимых импульсов',awlHard);
        Result := TFmxModuleCounter(Module).SetDependentImpulseMode(activate);
      end;
      mtCounterEx:
        Result := true;

    end
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

procedure TFmxDeviceCounter.SetEnable4_7(const Value: boolean);
begin
  if assigned(Module) then
    case ModuleType of
    mtCounterEx:
     TFmxModuleCounterEx(Module).Enable4_7:=Value;
    end;
end;

procedure TFmxDeviceCounter.SetFrequency(const Value: Single);
begin
   FFrequency:=Value;
end;


procedure TFmxDeviceCounter.SetImpulses(const Value: Single);
begin
     FImpulse:=Value;
end;

procedure TFmxDeviceCounter.SetImpulseWeights(const Value: Double);
begin
  FImpulseWeights := Value;
end;

procedure TFmxDeviceCounter.SetMaxOutlay(const Value: Single);
begin
  FMaxOutlay := Value;
end;

procedure TFmxDeviceCounter.SetMinOutlay(const Value: Single);
begin
  FMinOutlay := Value;
end;

procedure TFmxDeviceCounter.SetPort(const Value: integer);
begin
  if Assigned(Module) then
  case ModuleType of
    mtCounter: begin
        TFmxModuleCounter(Module).PortNumber:=Value;
      end;
    mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).PortNumber:=Value;
      end;
    mtCounterEx: begin
        TFmxModuleCounterEx(Module).PortNumber:=Value;
      end;
  end;
end;

function TFmxDeviceCounter.SetSlowImpulseMode(activate: Boolean): Boolean;
begin
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
      case ModuleType of
      mtCounter: begin
        if Assigned(AddToWorkLogProc) then
          if activate then AddToWorkLogProc(DeviceName+': Включение режима медленных импульсов',awlHard)
          else AddToWorkLogProc(DeviceName+': Выключение режима медленных импульсов',awlHard);
        Result := TFmxModuleCounter(Module).SetSlowImpulseMode(activate);
      end;
      mtManual,
      mtCounterEx:
        Result := true;
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

procedure TFmxDeviceCounter.SetStarted(const Value: boolean);
begin
  FStarted := Value;
end;

procedure TFmxDeviceCounter.SetSynchro(const Value: THSC_IMP_TypeOfSynchro);
begin
  FSynchro := Value;
end;

procedure TFmxDeviceCounter.SetTypeOfInput(const Value: Byte);
begin
  FTypeOfInput := Value;
end;

function TFmxDeviceCounter.SetupStartStop(aInterval:integer):boolean;
begin
 try
   if Assigned(Module) then
      Module.LastDevice:=self;
      Result := False;
    case ModuleType of
      mtCounterEx:
      begin
        if Assigned(Module) then
        begin
          if Assigned(AddToWorkLogProc) then
             AddToWorkLogProc(DeviceName+': Запуск счета от внешнего синхросигнала',awlHard);
          Result := TFmxModuleCounterEx(Module).SetupStartStop();
        end
        else
          AddToWorkLogProc(DeviceName+': Запуск счета от внешнего синхросигнала - не найден модуль',awlError);
      end;
      mtHSC_IMP:
      begin
        if Assigned(Module) then
        begin
          if Assigned(AddToWorkLogProc) then
             AddToWorkLogProc(DeviceName+': Запуск счета от внешнего синхросигнала',awlHard);
          Result := TFmxModuleHSC_IMP(Module).SetupStartStop(aInterval);
        end
        else
          AddToWorkLogProc(DeviceName+': Запуск счета от внешнего синхросигнала - не найден модуль',awlError);
      end;
      mtManual: result:=True;
      mtCounter:
      begin
        if Assigned(Module) then
        begin
          if Assigned(AddToWorkLogProc) then
             AddToWorkLogProc(DeviceName+': Проверка статуса счета от внешнего синхросигнала',awlHard);
          Result := TFmxModuleCounter(Module).UpdateCommonStatus;
        end
        else
          AddToWorkLogProc(DeviceName+': Проверка статуса счета от внешнего  - не найден модуль',awlError);
      end;
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

procedure TFmxDeviceCounter.SetupInputs;
begin
   if Assigned(Module) then
    case ModuleType of
      mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).SetupInputs;
      end;
    end;
end;


function TFmxDeviceCounter.StartCount(): Boolean;
begin
  Started:=True;
  try
   if Assigned(Module) then
      Module.LastDevice:=self;
      if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Программный запуск счета',awlHard);
    case ModuleType of
      mtCounter: begin
        Result := TFmxModuleCounter(Module).StartCount();
      end;
      mtHSC_IMP: begin
        Result := TFmxModuleHSC_IMP(Module).StartCount();
      end;
      mtManual: result:=True;
      mtCounterEx:
        Result := TFmxModuleCounterEx(Module).StartCount();
    end;
 finally
   if Assigned(Module) then
      Module.LastDevice:=nil;
 end;
end;

function TFmxDeviceCounter.StartCountWithoutSynchro: Boolean;
begin
    sleep(100);
    Started:=True;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Запуск счета',awlHard);
    case ModuleType of
      mtCounter: begin
        Result := TFmxModuleCounter(Module).StartCount;
      end;
      mtHSC_IMP: begin
        TFmxModuleHSC_IMP(Module).ExternalSyncro:=0;
        TFmxModuleHSC_IMP(Module).SetupExternalCount();
        Result := TFmxModuleHSC_IMP(Module).StartCount;
      end;
      mtCounterEx:
        Result := TFmxModuleCounterEx(Module).StartCountWithoutSyncro;
      mtManual:
        FStarted:=True;
    end;
end;


function TFmxDeviceCounter.StopCount: Boolean;
begin
    Started:=False;
    if Assigned(AddToWorkLogProc) then AddToWorkLogProc(DeviceName+': Программная остановка счета',awlHard);
    case ModuleType of
      mtCounter: begin
        Result := TFmxModuleCounter(Module).StopCount;
      end;
      mtHSC_IMP: begin
        Result := TFmxModuleHSC_IMP(Module).StopCount;
      end;
      mtCounterEx:
        Result := TFmxModuleCounterEx(Module).StopCount;
      mtManual: begin
        Result := True;
      end;
    end;
end;

function TFmxDeviceCounter.UpdateCommonStatus: Boolean;
begin
    case ModuleType of
      mtCounter: begin
        Result := TFmxModuleCounter(Module).UpdateCommonStatus;
      end;
      mtHSC_IMP: begin
        Result := TFmxModuleHSC_IMP(Module).UpdateStatusQuery;
      end;
      mtCounterEx:
      begin
        Result := TFmxModuleCounterEx(Module).UpdateStatus_S;
      end;
    end;
end;

function TFmxDeviceCounter.UpdateFinalVolumes: Boolean;
begin
    case ModuleType of
      mtCounter: begin
        Result := TFmxModuleCounter(Module).UpdateImpulseCounters;
      end;
      mtHSC_IMP: begin
        Result := TFmxModuleHSC_IMP(Module).UpdateFinalImpulseCounters;
      end;
      mtCounterEx:
      begin
        //запрашиваем количество импульсов
        Result := TFmxModuleCounterEx(Module).UpdateSlaveCounters_A_B();
        Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_C_E();
        Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_D;
        Result := TFmxModuleCounterEx(Module).UpdateStatus_S;
      end;
    end;
end;

function TFmxDeviceCounter.PrepareExternalSynchro: Boolean;
begin
  {
    Настройка выхода внешней синхронизации,
    Если канал синхронизации не выбран, то XX = 0. Если выбран, то XX = номер канала
  }
  case ModuleType of
    mtHSC_IMP: begin
         if ExternalSynchro=htsNone then
            TFmxModuleHSC_IMP(Module).ExternalSyncro:=0
         else
            TFmxModuleHSC_IMP(Module).ExternalSyncro:=(ord(ExternalSynchro) shl 8)+ChannelNumber;
      end;
    end;
end;

function TFmxDeviceCounter.UpdateVolumes: Boolean;
var counter_number:integer;
begin
    case ModuleType of
      mtCounter: begin
        Result := TFmxModuleCounter(Module).UpdateImpulseCounters;
      end;
      mtHSC_IMP: begin
        if TFmxModuleHSC_IMP(Module).StartStopState = sssRunning then
           Result := TFmxModuleHSC_IMP(Module).UpdateImpulseCounters
        else begin
           Result := TFmxModuleHSC_IMP(Module).UpdateFinalImpulseCounters;
        end;
      end;
      mtCounterEx:
      begin
        //запрашиваем количество импульсов
        Result := TFmxModuleCounterEx(Module).UpdateSlaveCounters_A_B();
        Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_C_E();
        Result := TFmxModuleCounterEx(Module).UpdateMasterCounters_D;
        Result := TFmxModuleCounterEx(Module).UpdateStatus_S;
      end;
    end;
end;

function TFmxDeviceCounter.UpdateWaterDischarges: Boolean;
begin
    case ModuleType of
      mtCounter:
        Result := TFmxModuleCounter(Module).UpdateFrequencies;
      mtHSC_IMP:
      begin
        Result := TFmxModuleHSC_IMP(Module).UpdateStatusQuery;
      end;
      mtCounterEx:
        Result := TFmxModuleCounterEx(Module).UpdateFrequencies;
    end;
end;


{ TFmxDeviceCMCylinders }

constructor TFmxDeviceCMCylinders.CreateOnModule(MT: TFmxModuleType);
begin
  inherited Create;

  //Изначально весы назодятся в режиме обычной работы
  ScalesMode:=smCalibration;
  ModuleType := MT;
// Данный девайс не имеет модулей, т.к. подразумевает ручной вод данных
//  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
//  Module := MainDeviceManager.DetermineModule(port,ModuleType,BR, address);
//  Module.AddReceiver(ReceiveResponse, false);
//  FModuleManager := MainDeviceManager.ModuleManager;

end;

function TFmxDeviceCMCylinders.CalibrationCoefficient(Scale:double):double;
var
  i:byte;
  x1,x2,Y1,Y2,k,b:real;

  coef,error :real;
  PointsCount:byte;
begin
  result:=1;
  if (Scale=0) then exit;
  with settings do
  begin
    PointsCount:=Length(CalibrationTable);
    if PointsCount=0 then exit;

    if PointsCount=1 then begin
      X1:=0;
      X2:=CalibrationTable[0].WaterDischarge;
      Y1:=1;
      Y2:=CalibrationTable[0].Coefficient;
    end
    else begin
      for i:=0 to Length(CalibrationTable)-2 do
        if CalibrationTable[i].WaterDischarge<=Scale then begin
          X1:=CalibrationTable[i].WaterDischarge;
          X2:=CalibrationTable[i+1].WaterDischarge;
          Y1:=CalibrationTable[i].Coefficient;
          Y2:=CalibrationTable[i+1].Coefficient;
        end;

      if Scale>=CalibrationTable[Length(CalibrationTable)-1].WaterDischarge then begin
          X1:=CalibrationTable[Length(CalibrationTable)-2].WaterDischarge;
          X2:=CalibrationTable[Length(CalibrationTable)-1].WaterDischarge;
          Y1:=CalibrationTable[Length(CalibrationTable)-2].Coefficient;
          Y2:=CalibrationTable[Length(CalibrationTable)-1].Coefficient;
      end;
      if Scale<=CalibrationTable[0].WaterDischarge then begin
          X1:=CalibrationTable[0].WaterDischarge;
          X2:=CalibrationTable[1].WaterDischarge;
          Y1:=CalibrationTable[0].Coefficient;
          Y2:=CalibrationTable[1].Coefficient;
      end;
    end;

    if (X2-X1)>0 then
    begin
    k:=(Y2-Y1)/(X2-X1);
    b:=(Y1*X2-X1*Y2)/(X2-X1);
    end
    else begin
      k:=1.0;
      b:=0;
    end;
    coef:=k*Scale+b;
  end;
  Result:=coef;
end;


destructor TFmxDeviceCMCylinders.Destroy;
begin

  inherited;
end;

function TFmxDeviceCMCylinders.GetVolume: Single;
begin
begin
  FKalibrKoeff:=CalibrationCoefficient(ScaleValue - Tare);{ TODO : Уточнить }
  Result := (ScaleValue - Tare) * FKalibrKoeff;
end;

end;

function TFmxDeviceCMCylinders.GetWeight: Single;
begin
 //
 if Density>0 then
    result:=Volume/Density
 else begin
    result:=Volume;
 end;
end;

procedure TFmxDeviceCMCylinders.SetActive(const Value: boolean);
begin
  FActive := Value;
end;

procedure TFmxDeviceCMCylinders.SetCalibrationCoefficient(const Value: Single);
begin
  FCalibrationCoefficient := Value;
end;

procedure TFmxDeviceCMCylinders.SetCalibrationNull(const Value: Single);
begin
  FCalibrationNull := Value;
end;

procedure TFmxDeviceCMCylinders.SetDensity(const Value: real);
begin
  FDensity := Value;
end;

procedure TFmxDeviceCMCylinders.SetDiscontinuity(const Value: int64);
begin
  FDiscontinuity := Value;
end;

procedure TFmxDeviceCMCylinders.SetKalibrKoeff(const Value: Single);
begin
  FKalibrKoeff := Value;
end;

procedure TFmxDeviceCMCylinders.SetScaleValue(const Value: Double);
begin
  FScaleValue := Value;
end;

procedure TFmxDeviceCMCylinders.SetTare(const Value: Single);
begin
  FTare := Value;
end;

{ TFmxDeviceSimpleEdit }

function TFmxDeviceSimpleEdit.ChangeValue(_value: Double): Boolean;
begin
  case ModuleType of
   mtHSC_CTRL:  TFmxModuleHsc_Ctrl(Module).MoveValve(Number,Round(_Value));
   mtModbusA:  TFmxModuleModbusA(Module).SetOutput(Number,_Value);
  end;

end;

constructor TFmxDeviceSimpleEdit.CreateOnModuleValve(AModbusTCPHost: string;
  AModbusTCPPort: word; port: integer; address: Byte; BR: Cardinal;
  valve_number: Byte; AModuleType: TFmxModuleType;
  _typeofprotocol: TTypeOfProtocol; InputReg, OutputReg: word);
begin
  inherited Create;
  ModuleType := AModuleType;
  if ModuleType=mtHSC_CTRL then
  begin
    if valve_number <= 23 then Number := valve_number
    else Number := 0;
  end
  else if ModuleType=mtModbusA then
  begin
    if valve_number <= 16 then Number := valve_number
    else Number := 0;
  end;
  CreateMainDeviceManagerIfNotCreated(AModbusTCPHost,AModbusTCPPort);
  Module := MainDeviceManager.DetermineModule(port,AModuleType,BR, address,_typeofprotocol,InputReg,OutputReg);
  FModuleManager := MainDeviceManager.ModuleManager;
end;

function TFmxDeviceSimpleEdit.GetOutputValue: Double;
begin
  result:=0;
  if Assigned(Module) then
  begin
  case ModuleType of
    mtModbusA: result:=TFmxModuleModbusA(Module).GetOutput(Number);
  end;
  end;
end;

function TFmxDeviceSimpleEdit.GetInputValue: Double;
begin
  result:=0;
  if Assigned(Module) then
  begin
  case ModuleType of
    mtModbusA: result:=TFmxModuleModbusA(Module).GetInput(Number);
  end;
  end;
end;

function TFmxDeviceSimpleEdit.GetMustUpdate: boolean;
begin
  result:=False;
  if Assigned(Module) then
  begin
  case ModuleType of
    mtModbusA: result:=TFmxModuleModbusA(Module).MustUpdate;
  end;
  end;

end;

procedure TFmxDeviceSimpleEdit.SetOutputValue(const Value: Double);
begin
  if Assigned(Module) then
  begin
  case ModuleType of
    mtModbusA: TFmxModuleModbusA(Module).SetOutput(Number,Value);
  end;
  end;
end;

procedure TFmxDeviceSimpleEdit.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Module) then
  begin
    case ModuleType of
      mtModbusA: TFmxModuleModbusA(Module).MaxChannels:=Value;
    end;
  end;
end;

procedure TFmxDeviceSimpleEdit.SetModbusFormat(const Value: TModBusDataFormat);
begin
  inherited;
  if Assigned(Module) then
  begin
    case ModuleType of
      mtModbusA: TFmxModuleModbusA(Module).ModbusFormat:=Value;
    end;
  end;
end;

procedure TFmxDeviceSimpleEdit.SetMustUpdate(const Value: boolean);
begin
  if Assigned(Module) then
  begin
    case ModuleType of
      mtModbusA: TFmxModuleModbusA(Module).MustUpdate:=True;
    end;
  end;
end;

procedure TFmxDeviceSimpleEdit.SetNumber(const Value: Byte);
begin
  FNumber := Value;
  if Assigned(Module) then
  begin
    case ModuleType of
      mtModbusA: TFmxModuleModbusA(Module).MustUpdate:=True;
    end;
  end;

end;

{ TFmxDeviceCoilCheckList }

constructor TFmxDeviceCoilCheckList.CreateOnModule(AModbusTCPHost: string;
  AModbusTCPPort: word; port: integer; address: Byte; BR: Cardinal;
  InputReg: Word; OutputReg: Word; size: Byte; AModuleType: TFmxModuleType;
  _typeofprotocol: TTypeOfProtocol);
begin
  inherited Create;
  FSize := size;
  InputRegister := InputReg;
  OutputRegister := OutputReg;
  FValue := 0;
  FManualValue := 0;
  ModuleType := AModuleType;
  if ModuleType <> mtManual then
  begin
    CreateMainDeviceManagerIfNotCreated(AModbusTCPHost, AModbusTCPPort);
    Module := MainDeviceManager.DetermineModule(port, AModuleType, BR, address,
      _typeofprotocol, InputRegister, OutputRegister);
    FModuleManager := MainDeviceManager.ModuleManager;
  end;
end;

function TFmxDeviceCoilCheckList.ReadCoils: Boolean;
var
  Bytes: TBytes;
  i: Integer;
  v: LongWord;
begin
  Result := False;
  if ModuleType = mtManual then
  begin
    FValue := FManualValue;
    Result := True;
    Exit;
  end;
  if not Assigned(Module) then Exit;
  if not (Module is TFmxModuleModbusD) then Exit; // предположительно работаем с ModbusD
  try
    Module.LastDevice := Self;
    // Читаем катушки (coils). Предполагается, что в TFmxModuleModbusD есть метод ReadCoils,
    // возвращающий массив байт. Если его нет, реализуйте самостоятельно.
    // Здесь для примера используем гипотетический метод.
    if TFmxModuleModbusD(Module).ReadCoils(FStartAddress, FSize, Bytes) then
    begin
      v := 0;
      for i := 0 to FSize - 1 do
        if (i div 8 < Length(Bytes)) and (((Bytes[i div 8] shr (i mod 8)) and 1) <> 0) then
          v := v or (1 shl i);
      FValue := v;
      Result := True;
    end;
  finally
    Module.LastDevice := nil;
  end;
end;

function TFmxDeviceCoilCheckList.WriteCoils: Boolean;
var
  Bytes: TBytes;
  i: Integer;
  Len: Integer;
begin
  Result := False;
  if ModuleType = mtManual then
  begin
    FManualValue := FValue;
    Result := True;
    Exit;
  end;
  if not Assigned(Module) then Exit;
  if not (Module is TFmxModuleModbusD) then Exit;
  try
    Module.LastDevice := Self;
    Len := (FSize + 7) div 8;
    SetLength(Bytes, Len);
    for i := 0 to Len * 8 - 1 do
      if i < FSize then
      begin
        if (FValue shr i) and 1 <> 0 then
          Bytes[i div 8] := Bytes[i div 8] or (1 shl (i mod 8));
      end;
    Result := TFmxModuleModbusD(Module).WriteMultipleCoils(FStartAddress, Bytes);
  finally
    Module.LastDevice := nil;
  end;
end;

function TFmxDeviceCoilCheckList.UpdateStatus: Boolean;
begin
  Result := ReadCoils; // при обновлении статуса перечитываем катушки
end;

function TFmxDeviceCoilCheckList.GetValue: LongWord;
begin
  if ModuleType = mtManual then
    Result := FManualValue
  else
    Result := FValue;
end;

procedure TFmxDeviceCoilCheckList.SetValue(const Value: LongWord);
begin
  if ModuleType = mtManual then
    FManualValue := Value
  else
    FValue := Value;
end;



initialization
  MainDeviceManager := nil;
  CreateMainDeviceManagerIfNotCreated('',502);
  DigitalDeviceManager := nil;
  CreateDigitalDeviceManagerIfNotCreated('',502);
end.
