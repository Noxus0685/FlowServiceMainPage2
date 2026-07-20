unit uWorkTable;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.IniFiles,
  System.Math,
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  System.UITypes,
  uBaseProcedures,
  uClasses,
  uControlRegister,
  uDataManager,
  uDeviceClass,
  uFlowMeter,
  uMeterValue,
  uObservable,
  uParameter,
  uProtocols,
  uRepositories,
  uSyncSetup;


type

  // Используем общий тип уведомлений из uObservable
  EWorkTableNotifyEvent = ENotifyEvent;

    TMeasurementStopControlMode = (
    scmNone,
    scmControllerTime,
    scmControllerImpulse,
    scmCommand
  );

type
  /// <summary>
  /// Состояние выполнения операций рабочей таблицы.
  /// Описывает полный жизненный цикл: от ожидания до завершения/ошибки.
  /// </summary>
  EStateWorkTable = (
    /// <summary>
    /// Состояние не определено.
    /// Начальное значение или полностью остановленная система.
    /// </summary>
    swtNONE = 0,

    /// <summary>
    /// Режим ожидания.
    /// Система готова к работе, но команда ещё не получена.
    /// </summary>
    swtSTANDBY,

    /// <summary>
    /// Установлено соединение с оборудованием или сервисом.
    /// </summary>
    swtCONNECTED,

    /// <summary>
    /// Инициирован запуск мониторинга.
    /// Команда отправлена, но ещё не подтверждена.
    /// </summary>
    swtSTARTMONITOR,

    /// <summary>
    /// Ожидание начала мониторинга.
    /// Подтверждение от устройства или переход в активный режим.
    /// </summary>
    swtSTARTMONITORWAIT,

    /// <summary>
    /// Активный мониторинг.
    /// Чтение параметров и контроль состояния.
    /// </summary>
    swtMONITOR,

    /// <summary>
    /// Инициирована остановка мониторинга.
    /// </summary>
    swtSTOPMONITOR,

    /// <summary>
    /// Ожидание завершения мониторинга.
    /// </summary>
    swtSTOPMONITORWAIT,

    /// <summary>
    /// Конфигурация завершена.
    /// Все параметры установлены, система готова к тесту.
    /// </summary>
    swtCONFIGED,

    /// <summary>
    /// Инициирован запуск теста.
    /// Отправка команд на выполнение испытания.
    /// </summary>
    swtSTARTTEST,

    /// <summary>
    /// Ожидание старта теста.
    /// Подтверждение от оборудования.
    /// </summary>
    swtSTARTWAIT,

    /// <summary>
    /// Выполнение теста.
    /// Основной рабочий процесс измерений.
    /// </summary>
    swtEXECUTE,

    /// <summary>
    /// Инициирована остановка теста.
    /// </summary>
    swtSTOPTEST,

    /// <summary>
    /// Ожидание завершения теста.
    /// </summary>
    swtSTOPWAIT,

    /// <summary>
    /// Финальное считывание данных.
    /// Снятие последних показаний после остановки.
    /// </summary>
    swtFINALREAD,

    /// <summary>
    /// Процесс успешно завершён.
    /// Все операции выполнены корректно.
    /// </summary>
    swtCOMPLETE,

    /// <summary>
    /// Ошибка выполнения.
    /// Процесс завершён сбоем или некорректным состоянием.
    /// </summary>
    swtFAILURE
  );

  EActionWorkTable = (
    awtNone = 0,
    awtStartTest,
    awtStopTest,
    awtStartMonitor,
    awtStopMonitor,
    awtClampTable,
    awtUnClampTable,
    awtAddPump,
    awtRemovePump,
    awtAddChannel,
    awtRemoveChannel,
    awtWriteRegister,
    awtReadRegister,
    // Автоматический выбор эталонных каналов для текущего расхода.
    awtSelectEtalons

  );

  EEventWorkTable = (
    ewtNone = 0,
    ewtEvent = 1,
    ewtState,
    ewtAction,
    ewtInfo,
    ewtWarning,
    ewtError,
    ewtActivated,
    ewtRefresh,
    // Изменился набор выбранных эталонных каналов рабочего стола.
    ewtEtalonsChanged
  );
  TWorkTableEvent = EEventWorkTable;

  EWorkTableErrorCode = (
    wtecNone = 0,
    wtecGeneral = 2000,
    wtecStartMonitorFailed = 2001,
    wtecStartTestFailed = 2002,
    wtecStopMonitorFailed = 2003,
    wtecStopTestFailed = 2004,
    wtecSaveResultsFailed = 2005
  );

  EMeasurementRunMode = (mrmManual =0, mrmHalfAutomatic, mrmAutomatic);

  // Алиас для обратной совместимости
  EWorkTableState = EStateWorkTable;


  TGridColumnLayout = record
    Name: string;
    DisplayIndex: Integer;
    Width: Single;
    Visible: Boolean;
  end;



type
  TChannel = class;
  TWorkTable = class;

  TDeviceCreateMode = (
    dcmUserCreated,
    dcmGridPlaceholder,
    dcmMeasurementPromoted
  );

  TDeviceCreationService = class
  private
    class procedure FillDeviceFromChannel(ADevice: TDevice; AChannel: TChannel;
      AMode: TDeviceCreateMode); static;
    class procedure SyncChannelAndFlowMeter(ADevice: TDevice; AChannel: TChannel); static;
    class procedure RecalcDevicePointQ(ADevice: TDevice); static;
    class procedure AddProtocol(AMode: TDeviceCreateMode; const AAction: string;
      ADevice: TDevice; AChannel: TChannel); static;
    class function FindDeviceByUUID(const ADeviceUUID: string; ARepo: TDeviceRepository): TDevice; static;
  public
    class function CreateDevice(
      ARepo: TDeviceRepository;
      AMode: TDeviceCreateMode;
      ASourceDevice: TDevice = nil;
      const ADeviceUUID: string = ''
    ): TDevice; static;

    class function EnsureDeviceForChannel(
      AChannel: TChannel;
      AWorkTable: TWorkTable;
      ARepo: TDeviceRepository;
      AMode: TDeviceCreateMode;
      ASourceDevice: TDevice = nil;
      ACurrentPoint: TDevicePoint = nil
    ): TDevice; static;
  end;

  TChannel = class(TTypeEntity)
  private
    FEnabled: Boolean;
    FText: string;
    FGroup: Integer;
    FCategory: EStdCategory;

    // Channel values (not proxy fields)
    FImpSec: Double;
    FImpResult: Double;
    FCurSec: Double;
    FCurResult: Double;
    FVolSec: Double;
    FVolResult: Double;

    FValueSec: Double;
    FValueResult: Double;
    FSimulationStartImpSec: Double;
    FSimulationTargetImpSec: Double;
    FSimulationRampStartTimeMs: Double;
    FSimulationRampDurationSec: Double;
    FSimulationRampActive: Boolean;
    FSimulationLastProgressLogMs: Double;

    FFlowMeter: TFlowMeter;
    FValueImp: TMeterValue;
    FValueImpTotal: TMeterValue;
    FValueCurrent: TMeterValue;
    FValueInterface: TMeterValue;

    FHashValueImp: string;
    FHashValueImpTotal: string;
    FHashValueCurrent: string;
    FHashValueInterface: string;
    FHashValueFlow: string;
    FName: string;
    FWorkTabeID: Integer;
    FOutputSet: TControlRegister<EOutPutSet>;
    FSyncMode: TControlRegister<ESyncChannelMode>;
    FNoiseFilter: TControlRegister<Integer>;
    FQMaxWork: Double;
    FQMinWork: Double;
    FVMaxWork: Double;
    FVMinWork: Double;

    // --- proxies for FlowMeter fields ---
    function GetDeviceNameProxy: string;
    procedure SetDeviceNameProxy(const AValue: string);

    function GetTypeNameProxy: string;
    procedure SetTypeNameProxy(const AValue: string);

    function GetSerialProxy: string;
    procedure SetSerialProxy(const AValue: string);

    function GetSignalProxy: Integer;
    procedure SetSignalProxy(const AValue: Integer);
    function GetOutputSetProxy: EOutPutSet;
    procedure SetOutputSetProxy(const AValue: EOutPutSet);
    function GetSyncModeProxy: ESyncChannelMode;
    procedure SetSyncModeProxy(const AValue: ESyncChannelMode);
    function GetNoiseFilterProxy: Integer;
    procedure SetNoiseFilterProxy(const AValue: Integer);
    function GetCategoryProxy: Integer;
    procedure SetCategoryProxy(const AValue: Integer);

    function GetDeviceUUIDProxy: string;
    procedure SetDeviceUUIDProxy(const AValue: string);

    function GetTypeUUIDProxy: string;
    procedure SetTypeUUIDProxy(const AValue: string);

    function GetRepoTypeNameProxy: string;
    procedure SetRepoTypeNameProxy(const AValue: string);

    function GetRepoTypeUUIDProxy: string;
    procedure SetRepoTypeUUIDProxy(const AValue: string);

    function GetRepoDeviceNameProxy: string;
    procedure SetRepoDeviceNameProxy(const AValue: string);

    function GetRepoDeviceUUIDProxy: string;
    procedure SetRepoDeviceUUIDProxy(const AValue: string);

    procedure Init;

    // --- regular getters/setters for channel fields ---
    function GetImpSecProxy: Double;
    procedure SetImpSecProxy(const AValue: Double);

    function GetImpResultProxy: Double;
    procedure SetImpResultProxy(const AValue: Double);

    function GetCurSecProxy: Double;
    procedure SetCurSecProxy(const AValue: Double);

    function GetCurResultProxy: Double;
    procedure SetCurResultProxy(const AValue: Double);

    function GetValueSecProxy: Double;
    procedure SetValueSecProxy(const AValue: Double);

    function GetValueResultProxy: Double;
    procedure SetValueResultProxy(const AValue: Double);

    procedure InitMeterValues;
    procedure SetMeterValue(var ATarget: TMeterValue; var ATargetHash: string;const AValue: TMeterValue);

    procedure SetValueImp(const AValue: TMeterValue);
    procedure SetValueImpTotal(const AValue: TMeterValue);
    procedure SetValueCurrent(const AValue: TMeterValue);
    procedure SetValueInterface(const AValue: TMeterValue);
    function GetVolResultProxy: Double;
    procedure SetVolResultProxy(const AValue: Double);
    function GetVolSecProxy: Double;
    procedure SetVolSecProxy(const AValue: Double);

  public
    constructor Create; override;
    destructor Destroy; override;

    //property UUID: string read FUUID write FUUID;

    property FlowMeter: TFlowMeter read FFlowMeter;

    property Enabled: Boolean read FEnabled write FEnabled;
    property Name: string read FName write FName;
    property Text: string read FText write FText;
    property WorkTabeID: Integer read FWorkTabeID write FWorkTabeID;



    // Proxy fields (mirror FlowMeter)
    property DeviceName: string read GetDeviceNameProxy write SetDeviceNameProxy;
    property TypeName: string read GetTypeNameProxy write SetTypeNameProxy;
    property Serial: string read GetSerialProxy write SetSerialProxy;
    property Signal: Integer read GetSignalProxy write SetSignalProxy;
    property OutputSet: EOutPutSet read GetOutputSetProxy write SetOutputSetProxy;
    property SyncMode: ESyncChannelMode read GetSyncModeProxy write SetSyncModeProxy;
    property NoiseFilter: Integer read GetNoiseFilterProxy write SetNoiseFilterProxy;
    property Category: Integer read GetCategoryProxy write SetCategoryProxy;
    // Group > 0: номер группы канала; для эталонов Qmax группы суммируется,
    // для приборов заданный расход делится между включенными каналами группы.
    // Group <= 0: канал считается одиночным.
    property Group: Integer read FGroup write FGroup;
    property DeviceUUID: string read GetDeviceUUIDProxy write SetDeviceUUIDProxy;
    property TypeUUID: string read GetTypeUUIDProxy write SetTypeUUIDProxy;
    property RepoTypeName: string read GetRepoTypeNameProxy write SetRepoTypeNameProxy;
    property RepoTypeUUID: string read GetRepoTypeUUIDProxy write SetRepoTypeUUIDProxy;
    property RepoDeviceName: string read GetRepoDeviceNameProxy write SetRepoDeviceNameProxy;
    property RepoDeviceUUID: string read GetRepoDeviceUUIDProxy write SetRepoDeviceUUIDProxy;
    property QMaxWork: Double read FQMaxWork write FQMaxWork;
    property QMinWork: Double read FQMinWork write FQMinWork;
    property VMaxWork: Double read FVMaxWork write FVMaxWork;
    property VMinWork: Double read FVMinWork write FVMinWork;

    // Channel fields (internal variables)
    property ImpSec: Double read GetImpSecProxy write SetImpSecProxy;
    property ImpResult: Double read GetImpResultProxy write SetImpResultProxy;
    property CurSec: Double read GetCurSecProxy write SetCurSecProxy;
    property CurResult: Double read GetCurResultProxy write SetCurResultProxy;
    property VolSec: Double read GetVolSecProxy write SetVolSecProxy;
    property VolResult: Double read GetVolResultProxy write SetVolResultProxy;
    property ValueSec: Double read GetValueSecProxy write SetValueSecProxy;
    property ValueResult: Double read GetValueResultProxy write SetValueResultProxy;
    property SimulationStartImpSec: Double read FSimulationStartImpSec write FSimulationStartImpSec;
    property SimulationTargetImpSec: Double read FSimulationTargetImpSec write FSimulationTargetImpSec;
    property SimulationRampStartTimeMs: Double read FSimulationRampStartTimeMs write FSimulationRampStartTimeMs;
    property SimulationRampDurationSec: Double read FSimulationRampDurationSec write FSimulationRampDurationSec;
    property SimulationRampActive: Boolean read FSimulationRampActive write FSimulationRampActive;
    property SimulationLastProgressLogMs: Double read FSimulationLastProgressLogMs write FSimulationLastProgressLogMs;

    property ValueImp: TMeterValue read FValueImp write SetValueImp;
    property ValueImpTotal: TMeterValue read FValueImpTotal write SetValueImpTotal;
    // Синоним для совместимости формулировки/старого кода: ValueImpResult == ValueImpTotal
    property ValueImpResult: TMeterValue read FValueImpTotal;
    property ValueCurrent: TMeterValue read FValueCurrent write SetValueCurrent;
    property ValueInterface: TMeterValue read FValueInterface write SetValueInterface;

    procedure RebindFlowMeterValues(const AWorkTable: TWorkTable);
    procedure RecreateFlowMeter(const AWorkTable: TWorkTable);
    procedure AssignFlowMeterFrom(const ASource: TChannel; const AWorkTable: TWorkTable;
      const ACloneDeviceToRepo: Boolean = True);
    procedure SetValues;
    procedure CreateDevice;
    procedure InitWorkRangesFromFlowMeter;

    function GetOutputSetStateColor: TAlphaColor;
    function GetSyncModeStateColor: TAlphaColor;
    function GetNoiseFilterStateColor: TAlphaColor;

  end;

  TWorkTable = class(TObservableObject)

  type

  private
    FID: Integer;
    FUUID: string;
    FName: string;
    FText: string;
    FActivePump : TPump;
    FActiveScale: TWeight;

    FState: EStateWorkTable;
    FAction: EActionWorkTable;
    FIsActive: Boolean;

    FTimeSet : Integer;
    FLimitImpSet: Integer;
    FLimitVolumeSet: Double;
    FRepeats:Integer;
    FRepeat:Integer;

    FDeviceChannels: TObjectList<TChannel>;
    FEtalonChannels: TObjectList<TChannel>;

    FPumps: TObjectList<TPump>;
    FScales: TObjectList<TWeight>;
    FFlowRate: TFlowRate;

    FMeasurementRun: TObject;
    FMode:EMeasurementRunMode;

    FFluidTemp: TFluidTemp;
    FFluidPress: TFluidPress;
    FTime: Double;
    FTimeResult: Double;
    FDeviceReady: Boolean;
    FEtalonFlowSet: Double;
    FCurrentWeight: Double;
    FScaleTareWeight: Double;

    FTableClamped: Boolean;
    FFlowUnitName: string;
    FQuantityUnitName: string;

    FTableFlow: TFlowMeter;

    FNextClimateChangeAt: TDateTime;
    FNextPressChangeAt: TDateTime;
    FNextFreqChangeAt: TDateTime;
    FSimulationLastUpdateTimeMs: Double;
    FSimulationLastFlowUnitsLogTarget: Double;
    FSimulationTargetFlowBase: Double;

    FHashValueTempertureBefore: string;
    FHashValueTempertureAfter: string;
    FHashValueTempertureDelta: string;
    FHashValueTemperture: string;
    FHashValuePressureBefore: string;
    FHashValuePressureAfter: string;
    FHashValuePressureDelta: string;
    FHashValuePressure: string;
    FHashValueDensity: string;
    FHashValueAirPressure: string;
    FHashValueAirTemperture: string;
    FHashValueHumidity: string;
    FHashValueTime: string;
    FHashValueQuantity: string;
    FHashValueFlowRate: string;

    FLayoutFlowRateVisible: Boolean;
    FLayoutPumpVisible: Boolean;
    FLayoutMainVisible: Boolean;
    FLayoutMesureVisible: Boolean;
    FLayoutConditionsVisible: Boolean;
    FLayoutProceduresVisible: Boolean;
    FInstrumentalLayoutOrder: string;

    FEtalonsGridColumns: TArray<TGridColumnLayout>;
    FDevicesGridColumns: TArray<TGridColumnLayout>;
    FDataPointsGridColumns: TArray<TGridColumnLayout>;
    FResultsGridColumns: TArray<TGridColumnLayout>;
    FSyncSetup: TSyncSetup;

    function GetValueTempertureBefore: TMeterValue;
    function GetValueTempertureAfter: TMeterValue;
    function GetValueTempertureDelta: TMeterValue;
    function GetValueTemperture: TMeterValue;
    function GetValuePressureBefore: TMeterValue;
    function GetValuePressureAfter: TMeterValue;
    function GetValuePressureDelta: TMeterValue;
    function GetValuePressure: TMeterValue;
    function GetValueDensity: TMeterValue;
    function GetValueAirPressure: TMeterValue;
    function GetValueAirTemperture: TMeterValue;
    function GetValueHumidity: TMeterValue;
    function GetValueTime: TMeterValue;
    function GetValueQuantity: TMeterValue;
    function GetValueFlowRate: TMeterValue;
    function GetTemp: Double;
    function GetTempDelta: Double;
    function GetPress: Double;
    function GetPressDelta: Double;
    function GetTime: Double;
    function GetTimeResult: Double;
    function GetFlowRate: Double;
    function GetCurentValue: Double;
    procedure SetCurentValue(const AValue: Double);

    procedure SetValueTempertureBefore(const AValue: TMeterValue);
    procedure SetValueTempertureAfter(const AValue: TMeterValue);
    procedure SetValueTempertureDelta(const AValue: TMeterValue);
    procedure SetValueTemperture(const AValue: TMeterValue);
    procedure SetValuePressureBefore(const AValue: TMeterValue);
    procedure SetValuePressureAfter(const AValue: TMeterValue);
    procedure SetValuePressureDelta(const AValue: TMeterValue);
    procedure SetValuePressure(const AValue: TMeterValue);
    procedure SetValueDensity(const AValue: TMeterValue);
    procedure SetValueAirPressure(const AValue: TMeterValue);
    procedure SetValueAirTemperture(const AValue: TMeterValue);
    procedure SetValueHumidity(const AValue: TMeterValue);
    procedure SetValueTime(const AValue: TMeterValue);
    procedure SetValueQuantity(const AValue: TMeterValue);
    procedure SetValueFlowRate(const AValue: TMeterValue);
    procedure SetTemp(const AValue: Double);
    procedure SetTempDelta(const AValue: Double);
    procedure SetPressDelta(const AValue: Double);
    procedure SetTime(const AValue: Double);
    procedure SetTimeResult(const AValue: Double);
    //procedure SetFlowRate(const AValue: Double);
    procedure AssignTableFlowAsEtalonToDevices;

    procedure SetValues;


    class procedure SaveGridColumns(
      AIni: TCustomIniFile;
      const ASectionPrefix: string;
      const AColumns: TArray<TGridColumnLayout>
    ); static;

    class procedure LoadGridColumns(
      AIni: TCustomIniFile;
      const ASectionPrefix: string;
      out AColumns: TArray<TGridColumnLayout>
    ); static;

    class procedure SaveChannelList(
      AIni: TCustomIniFile;
      const ASectionPrefix: string;
      AChannels: TObjectList<TChannel>
    ); static;

    class procedure LoadChannelList(
      AIni: TCustomIniFile;
      const ASectionPrefix: string;
      AChannels: TObjectList<TChannel>;
      const AWorkTableID: Integer
    ); static;

    class procedure SaveScaleList(
      AIni: TCustomIniFile;
      const ASectionPrefix: string;
      AScales: TObjectList<TWeight>
    ); static;

    class procedure LoadScaleList(
      AIni: TCustomIniFile;
      const ASectionPrefix: string;
      AScales: TObjectList<TWeight>
    ); static;

  private

  FCurrentPoint:  TDevicePoint;
  FParameterObserver: IEventObserver;

  procedure SetState(const ANewState: EStateWorkTable);
  procedure SetIsActive(const AValue: Boolean);
  procedure SetActivePumpObject(const APump: TPump);
  procedure SetActiveScaleObject(const AScale: TWeight);
  procedure BindParameterEvents(AParameter: TParameter);
  procedure UnbindParameterEvents(AParameter: TParameter);
  procedure HandleParameterNotify(Sender: TObject; Event: Integer; Data: TObject);
  function ResolveParameterStateEvent(AParameters: TParameter): ENotifyEvent;
  function ResolveParameterActionEvent(AParameters: TParameter; AParameterAction: EActionParameter): ENotifyEvent;

  procedure MeasurementRunPointChanged(ASender: TObject; APoint: TDevicePoint; APointIndex: Integer);
  function CreateActionNotification(AAction: EActionWorkTable; const ASourceName: string;
    const ADescription: string): TActionNotification;
  procedure FireAction(AAction: EActionWorkTable; const ASourceName: string; const ADescription: string);
  procedure DoStartMonitor;
  procedure DoStopMonitor;
  procedure DoStartTest;
  procedure DoStopTest;
  class function WorkTableEventToText(AEvent: TWorkTableEvent): string; static;
  class function WorkTableEventToString(AEvent: TWorkTableEvent): string; static;
  class function WorkTableEventToProtocolCategory(AEvent: TWorkTableEvent): EProtocolCategory; static;



  public
  procedure InitChannels;
  constructor Create;
  destructor Destroy; override;
    class function WorkTableStateToString(AState: EStateWorkTable): string; static;
    class function WorkTableStateFromString(const AValue: string): EStateWorkTable; static;
    class function BuildWorkTableServiceName(const ATableIndex: Integer): string; static;
    class function BuildDeviceChannelServiceName(const AChannelIndex: Integer): string; static;
    class function BuildEtalonChannelServiceName(const AChannelIndex: Integer): string; static;
    class function BuildChannelDefaultText(const AChannelIndex: Integer): string; static;

    function AddDeviceChannel: TChannel; overload;
    function AddDeviceChannel(const AName: string): TChannel; overload;
    function AddDeviceChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
        ATypeName, ASerial, ADeviceUUID: string): TChannel; overload;

    function AddEtalonChannel: TChannel; overload;
    function AddEtalonChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
       ATypeName, ASerial, ADeviceUUID: string): TChannel;  overload;

    class procedure Save(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

    class procedure Load(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

  procedure Rebind;

  function AddPump(const APumpName: string): TPump; overload;
  function AddPump(APump: TPump): Boolean; overload;
  procedure RemovePump(const APumpUUID: string); overload;
  procedure RemovePump(APump: TPump); overload;
  procedure ClearPumps;
  procedure ClearScales;
  procedure SetActivePump(APumpName: string);
  procedure SetActiveScale(AScaleName: string);
  function DeleteChannel(AChannel: TChannel): Boolean;
  procedure ReindexChannels(AChannels: TObjectList<TChannel>;
      const AEtalonChannels: Boolean);

  procedure ApplyChannelValues(AChannels: TObjectList<TChannel>; const ACurSec: Double;
  const AImpSecValues: TArray<Double>; const AImpResult: Double);

  function FindPumpByUUID(const APumpUUID: string): TPump;
  function FindPumpByName(const APumpName: string): TPump;
  function AddScale(const AScaleName: string): TWeight; overload;
  function AddScale(AScale: TWeight): Boolean; overload;
  procedure RemoveScale(const AScaleUUID: string); overload;
  procedure RemoveScale(AScale: TWeight); overload;
  function FindScaleByUUID(const AScaleUUID: string): TWeight;
  function FindScaleByName(const AScaleName: string): TWeight;
  function DisplayWeight: Double;
  procedure DoScaleTare;
  procedure DoScaleDrain;
  property Pumps: TObjectList<TPump> read FPumps;
  property Scales: TObjectList<TWeight> read FScales;
  property Weights: TObjectList<TWeight> read FScales;

  property MeasurementRun: TObject read FMeasurementRun;
  property MeasurementMode: EMeasurementRunMode read FMode write FMode;

  property FluidTemp: TFluidTemp read FFluidTemp;
  property FluidPress: TFluidPress read FFluidPress;

  property ActivePump: TPump read FActivePump write SetActivePumpObject;
  property ActiveScale: TWeight read FActiveScale write SetActiveScaleObject;
  property FlowRate: TFlowRate read FFlowRate write FFlowRate;

    property ID: Integer read FID write FID;
    property UUID: string read FUUID write FUUID;
    property Name: string read FName write FName;
    property Text: string read FText write FText;

    property DeviceChannels: TObjectList<TChannel> read FDeviceChannels;
    property EtalonChannels: TObjectList<TChannel> read FEtalonChannels;
    property TableFlow: TFlowMeter read FTableFlow;
    //property Temp: Double read GetTemp write SetTemp;
    property TempDelta: Double read GetTempDelta write SetTempDelta;
    property PressDelta: Double read GetPressDelta write SetPressDelta;

    property Time: Double read GetTime write SetTime;
    property TimeSet: Integer read FTimeSet write FTimeSet;
    property LimitImpSet: Integer read FLimitImpSet write FLimitImpSet;
    property LimitVolumeSet: Double read FLimitVolumeSet write FLimitVolumeSet;
    property CurrentPoint:  TDevicePoint read FCurrentPoint write FCurrentPoint;

    property Repeats: Integer read FRepeats write FRepeats;
    property &Repeat: Integer read FRepeat write FRepeat;

    property TimeResult: Double read GetTimeResult write SetTimeResult;
    property DeviceReady: Boolean read FDeviceReady write FDeviceReady;
    property EtalonFlowSet: Double read FEtalonFlowSet write FEtalonFlowSet;
    property CurrentWeight: Double read FCurrentWeight write FCurrentWeight;
    property Value: Double read FCurrentWeight write FCurrentWeight;
    property CurentValue: Double read GetCurentValue write SetCurentValue;
    property ScaleTareWeight: Double read FScaleTareWeight write FScaleTareWeight;

    //property State: TSpillState read FState write FState;
    property State: EStateWorkTable read FState write SetState;
    property Action: EActionWorkTable read FAction write FAction;
    property IsActive: Boolean read FIsActive write SetIsActive;

    property TableClamped: Boolean read FTableClamped write FTableClamped;
    property FlowUnitName: string read FFlowUnitName write FFlowUnitName;
    property QuantityUnitName: string read FQuantityUnitName write FQuantityUnitName;

    property ValueTempertureBefore: TMeterValue read GetValueTempertureBefore write SetValueTempertureBefore;
    property ValueTempertureAfter: TMeterValue read GetValueTempertureAfter write SetValueTempertureAfter;
    property ValueTempertureDelta: TMeterValue read GetValueTempertureDelta write SetValueTempertureDelta;
    property ValueTemperture: TMeterValue read GetValueTemperture write SetValueTemperture;
    property ValuePressureBefore: TMeterValue read GetValuePressureBefore write SetValuePressureBefore;
    property ValuePressureAfter: TMeterValue read GetValuePressureAfter write SetValuePressureAfter;
    property ValuePressureDelta: TMeterValue read GetValuePressureDelta write SetValuePressureDelta;
    property ValuePressure: TMeterValue read GetValuePressure write SetValuePressure;
    property ValueDensity: TMeterValue read GetValueDensity write SetValueDensity;
    property ValueAirPressure: TMeterValue read GetValueAirPressure write SetValueAirPressure;
    property ValueAirTemperture: TMeterValue read GetValueAirTemperture write SetValueAirTemperture;
    property ValueHumidity: TMeterValue read GetValueHumidity write SetValueHumidity;
    property ValueTime: TMeterValue read GetValueTime write SetValueTime;
    property ValueQuantity: TMeterValue read GetValueQuantity write SetValueQuantity;
    property ValueFlowRate: TMeterValue read GetValueFlowRate write SetValueFlowRate;

    property LayoutFlowRateVisible: Boolean read FLayoutFlowRateVisible write FLayoutFlowRateVisible;
    property LayoutPumpVisible: Boolean read FLayoutPumpVisible write FLayoutPumpVisible;
    property LayoutMainVisible: Boolean read FLayoutMainVisible write FLayoutMainVisible;
    property LayoutMesureVisible: Boolean read FLayoutMesureVisible write FLayoutMesureVisible;
    property LayoutConditionsVisible: Boolean read FLayoutConditionsVisible write FLayoutConditionsVisible;
    property LayoutProceduresVisible: Boolean read FLayoutProceduresVisible write FLayoutProceduresVisible;
    property InstrumentalLayoutOrder: string read FInstrumentalLayoutOrder write FInstrumentalLayoutOrder;

    property EtalonsGridColumns: TArray<TGridColumnLayout> read FEtalonsGridColumns write FEtalonsGridColumns;
    property DevicesGridColumns: TArray<TGridColumnLayout> read FDevicesGridColumns write FDevicesGridColumns;
    property DataPointsGridColumns: TArray<TGridColumnLayout> read FDataPointsGridColumns write FDataPointsGridColumns;
    property ResultsGridColumns: TArray<TGridColumnLayout> read FResultsGridColumns write FResultsGridColumns;
    property SyncSetup: TSyncSetup read FSyncSetup;

    property NextClimateChangeAt: TDateTime  read FNextClimateChangeAt write FNextClimateChangeAt;
    property NextPressChangeAt: TDateTime  read FNextPressChangeAt write FNextPressChangeAt;
    property NextFreqChangeAt: TDateTime  read FNextFreqChangeAt write FNextFreqChangeAt;
    property SimulationLastUpdateTimeMs: Double read FSimulationLastUpdateTimeMs write FSimulationLastUpdateTimeMs;
    property SimulationLastFlowUnitsLogTarget: Double read FSimulationLastFlowUnitsLogTarget write FSimulationLastFlowUnitsLogTarget;
    property SimulationTargetFlowBase: Double read FSimulationTargetFlowBase write FSimulationTargetFlowBase;

    procedure RebindAllFlowMeters;
    procedure RecalculateAllMeterValues;
    procedure UpdateAggregateMeterValues;
    function SelectEtalons(const AFlowRate: Double; out AError: TErrorInfo): Boolean;
    function SetEtalonsByNames(const AEtalonNames: TArray<string>;
      out AError: TErrorInfo): Boolean;
    function CalcEtalonFlowRateMax: Double;
    function CalcEtalonFlowRateMin: Double;
    procedure UpdateFlowRateLimitsByEtalons;

    procedure InitMeterValues;
    // Собирает Hash и удаляет из глобального списка сохранения MeterValues значения этого рабочего стола.
    procedure RemoveMeterValuesFromStorage(ADeletedHashes: TStrings = nil);
    procedure SetTemperature(ATempBefore, ATempAfter: Double);
    procedure SetPressure(APressBefore, APressAfter: Double);
    procedure SetFlowRateMin(const AValue: Double);
    procedure SetFlowRateMax(const AValue: Double);
    procedure SetPressureMin(const AValue: Double);
    procedure SetPressureMax(const AValue: Double);

    procedure FireEvent(AEvent: TWorkTableEvent; const AError: TErrorInfo); overload;
    procedure FireEvent(AEvent: TWorkTableEvent; const AMsg: String ); overload;
    procedure FireEvent(AEvent: TWorkTableEvent); overload;
    procedure MeasurementRunStateChanged(ASender: TObject; AState: EMeasurementState);

  public

  procedure DoProcStart(AProcName: string);
  procedure DoProcStop(AProcName: string);
  procedure DoProcPause(AProcName: string);
  procedure DoProcNextStep(AProcName: string);
  procedure DoProcRepeat(AProcName: string);
  procedure DoSpillageStart;
  procedure DoSpillageStop;
  procedure Notify(Event: Integer; Data: TObject = nil); reintroduce; overload;
  procedure Notify(AEvent: ENotifyEvent; Data: TObject = nil); overload;
  procedure StartMeasurementRun;    overload;
  procedure StartMeasurementRun(AMode: Integer); overload;
  procedure ResetSpillageRuntimeValues;
  procedure ResetMeasurementValues;
  procedure StopMeasurementRun;
  procedure PauseMeasurementRun;
  procedure ResumeMeasurementRun;
  procedure NextMeasurementPoint;
  procedure ExecuteAction(AAction: EActionWorkTable; const ASourceName: string = '';
    const ADescription: string = '');

  procedure StartTest;
  procedure StopTest;
  procedure StartMonitor;
  procedure StopMonitor;
  procedure SaveMeasurementResults;


  end;

  IWorkTableObserverHost = interface
    ['{8E305AD6-49F7-4D3C-AD3E-1DBDF5692656}']
    procedure DetachWorkTableObservers(AWorkTable: TWorkTable);
  end;

  TWorkTableManager = class
  private
    FIniFileName: string;
    FWorkTables: TObjectList<TWorkTable>;
    FIsSimulationMode :Boolean;
    FActiveWorkTable  :TWorkTable;

  public
    constructor Create(const AIniFileName: string);
    destructor Destroy; override;

    procedure Load;
    procedure Save;
    procedure AddWorkTable;  overload;
    procedure AddWorkTable(const WorkTableName: string);  overload;
    function DeleteWorkTableByName(const AWorkTableName: string): Boolean;
    function DeleteWorkTablesByNames: Integer;

    function FindWorkTableName(const WorkTableName: string): TWorkTable;
    function FindWorkTableByID(const WorkTableID: Integer): TWorkTable;
    procedure SetActiveWorkTable(AWorkTable: TWorkTable);
    function FindPumpByName(const APumpName: string): TPump;
    function GetChannelFlowCoef(const AChannel: TChannel): Double;
    function UpdateDeviceImpSecFromFlowRate(const AWorkTable: TWorkTable; const AFlowRate: Double): Double;
    function UpdateEtalonImpSecFromFlowRate(const AWorkTable: TWorkTable; AFlowRate: Double = 0;
      AEtalonChannels: TObjectList<TChannel> = nil): Double;
    function BuildImpSecValuesForChannels(const AWorkTable: TWorkTable; AChannels: TObjectList<TChannel>;
    const AFlowRate, AFallbackImpSec: Double; const ASplitByQmax: Boolean = True;
    const ASplitByEnabledGroup: Boolean = False): TArray<Double>;

    property WorkTables: TObjectList<TWorkTable> read FWorkTables;
    property ActiveWorkTable: TWorkTable read FActiveWorkTable write SetActiveWorkTable;
    property IniFileName: string read FIniFileName write FIniFileName;
    property IsSimulationMode:Boolean read FIsSimulationMode  write FIsSimulationMode;
    procedure UpdateSimulation;

  end;

  var WorkTableManager:   TWorkTableManager;

implementation

uses
  FmxHelper,
  frmMainTable,
  uMeasurementRun,
  uMKSDebug;

const
  CEmptyGridDeviceComment = '[GridDevices.EmptyPlaceholder]';
  DEVICE_FLOW_RATE_DIM_INDEX = 4;

  {$REGION 'HELPERS'}

class procedure TDeviceCreationService.AddProtocol(AMode: TDeviceCreateMode;
  const AAction: string; ADevice: TDevice; AChannel: TChannel);
var
  Source: TProtocolSource;
  Name: string;
  Description: string;
  Params: string;

  function ChannelText: string;
  begin
    if AChannel <> nil then
      Result := AChannel.Text
    else
      Result := '';
  end;
begin
  if (ProtocolManager = nil) or (ADevice = nil) then
    Exit;

  Source := psWorkTable;
  case AMode of
    dcmUserCreated:
      begin
        Source := psForm;
        Name := 'DeviceUserCreated';
        Description := 'Создан прибор пользователем';
        Params := Format('UUID=%s; Name=%s; Serial=%s; Source=DeviceSelect',
          [ADevice.UUID, ADevice.Name, ADevice.SerialNumber]);
      end;
    dcmGridPlaceholder:
      begin
        Name := 'GridPlaceholderDeviceCreated';
        Description := 'Создан технический пустой прибор для строки GridDevices';
        Params := Format('UUID=%s; Channel=%s', [ADevice.UUID, ChannelText]);
      end;
    dcmMeasurementPromoted:
      begin
        Name := 'GridPlaceholderDevicePromoted';
        Description := 'Placeholder-прибор преобразован в прибор после проливки';
        Params := Format('UUID=%s; Name=%s; Serial=%s; Channel=%s',
          [ADevice.UUID, ADevice.Name, ADevice.SerialNumber, ChannelText]);
      end;
  else
    Name := 'DeviceCreationService';
    Description := AAction;
    Params := ADevice.UUID;
  end;

  if SameText(AAction, 'Reuse') then
  begin
    Name := 'GridExistingDeviceBound';
    Description := 'Строка GridDevices привязана к существующему прибору';
    Params := Format('UUID=%s; Name=%s; Serial=%s; Channel=%s',
      [ADevice.UUID, ADevice.Name, ADevice.SerialNumber, ChannelText]);
  end;

  ProtocolManager.AddMessage(pcAction, Source, Name, Description, Params);
end;

class function TDeviceCreationService.CreateDevice(ARepo: TDeviceRepository;
  AMode: TDeviceCreateMode; ASourceDevice: TDevice;
  const ADeviceUUID: string): TDevice;
var
  WasCreated: Boolean;
begin
  Result := nil;
  WasCreated := False;
  if ARepo = nil then
    Exit;

  if Trim(ADeviceUUID) <> '' then
  begin
    Result := FindDeviceByUUID(ADeviceUUID, ARepo);
    if Result <> nil then
    begin
      if ASourceDevice <> nil then
      begin
        Result.Assign(ASourceDevice, False);
        Result.SerialNumber := ASourceDevice.SerialNumber;
      end;
    end;
  end;

  if Result = nil then
  begin
    Result := ARepo.CreateDevice(ASourceDevice);
    if Result = nil then
      Exit;

    if Trim(ADeviceUUID) <> '' then
      Result.UUID := Trim(ADeviceUUID)
    else if Trim(Result.UUID) = '' then
      Result.UUID := TGUID.NewGuid.ToString;

    Result.State := osNew;
    WasCreated := True;
  end;

  case AMode of
    dcmUserCreated:
      begin
        Result.Comment := '';
        if WasCreated then
          AddProtocol(AMode, 'Create', Result, nil)
        else
          AddProtocol(AMode, 'Reuse', Result, nil);
      end;
    dcmGridPlaceholder:
      begin
        if WasCreated then
        begin
          Result.Comment := '';
          Result.Name := '';
          Result.SerialNumber := '';
          Result.OutputType := -1;
          AddProtocol(AMode, 'Create', Result, nil);
        end
        else
          AddProtocol(AMode, 'Reuse', Result, nil);
      end;
    dcmMeasurementPromoted:
      begin
        if SameText(Trim(Result.Comment), CEmptyGridDeviceComment) then
          Result.Comment := '';
        if WasCreated then
          AddProtocol(AMode, 'Create', Result, nil)
        else
          AddProtocol(AMode, 'Reuse', Result, nil);
      end;
  end;
end;

class function TDeviceCreationService.FindDeviceByUUID(const ADeviceUUID: string;
  ARepo: TDeviceRepository): TDevice;
var
  Repo: TDeviceRepository;
begin
  Result := nil;
  if Trim(ADeviceUUID) = '' then
    Exit;

  if (ARepo <> nil) then
    Result := ARepo.FindDeviceByUUID(ADeviceUUID);
  if Result <> nil then
    Exit;

  if DataManager <> nil then
    Result := DataManager.FindDevice(ADeviceUUID, Repo);
end;

class procedure TDeviceCreationService.FillDeviceFromChannel(ADevice: TDevice;
  AChannel: TChannel; AMode: TDeviceCreateMode);

  function MergeStringIfNeeded(const ATarget, ASource: string): string;
  begin
    Result := ATarget;
    if Trim(ASource) <> '' then
      Result := Trim(ASource)
    else if Trim(Result) = '' then
      Result := Trim(ASource);
  end;

begin
  if (ADevice = nil) or (AChannel = nil) then
    Exit;

  if AMode = dcmGridPlaceholder then
  begin
    ADevice.Comment := '';
    ADevice.Name := '';
    ADevice.SerialNumber := '';
    ADevice.OutputType := -1;
    Exit;
  end;

  ADevice.Name := MergeStringIfNeeded(ADevice.Name, AChannel.DeviceName);
  if Trim(ADevice.Name) = '' then
    ADevice.Name := 'Прибор ' + Trim(AChannel.Text);
  ADevice.SerialNumber := MergeStringIfNeeded(ADevice.SerialNumber, AChannel.Serial);
  ADevice.DeviceTypeName := MergeStringIfNeeded(ADevice.DeviceTypeName, AChannel.TypeName);
  ADevice.DeviceTypeUUID := MergeStringIfNeeded(ADevice.DeviceTypeUUID, AChannel.TypeUUID);
  ADevice.RepoTypeName := MergeStringIfNeeded(ADevice.RepoTypeName, AChannel.RepoTypeName);
  ADevice.RepoTypeUUID := MergeStringIfNeeded(ADevice.RepoTypeUUID, AChannel.RepoTypeUUID);
  ADevice.RepoDeviceName := MergeStringIfNeeded(ADevice.RepoDeviceName, AChannel.RepoDeviceName);
  ADevice.RepoDeviceUUID := MergeStringIfNeeded(ADevice.RepoDeviceUUID, AChannel.RepoDeviceUUID);

  if AChannel.Signal >= 0 then
    ADevice.OutputType := AChannel.Signal;
end;

class procedure TDeviceCreationService.SyncChannelAndFlowMeter(ADevice: TDevice;
  AChannel: TChannel);
begin
  if (ADevice = nil) or (AChannel = nil) then
    Exit;

  AChannel.DeviceUUID := ADevice.UUID;
  if AChannel.FlowMeter <> nil then
  begin
    AChannel.FlowMeter.Device := ADevice;
    AChannel.FlowMeter.DeviceUUID := ADevice.UUID;
    AChannel.FlowMeter.UpdateByDevice;
      AChannel.InitWorkRangesFromFlowMeter;
  end;

  if Trim(ADevice.DeviceTypeUUID) <> '' then
    AChannel.TypeUUID := ADevice.DeviceTypeUUID;
  if Trim(ADevice.DeviceTypeName) <> '' then
    AChannel.TypeName := ADevice.DeviceTypeName;
  if Trim(ADevice.SerialNumber) <> '' then
    AChannel.Serial := ADevice.SerialNumber;
  if (ADevice.OutputType >= 0) and
     (not SameText(Trim(ADevice.Comment), CEmptyGridDeviceComment)) then
    AChannel.Signal := ADevice.OutputType;
  if Trim(ADevice.RepoTypeName) <> '' then
    AChannel.RepoTypeName := ADevice.RepoTypeName;
  if Trim(ADevice.RepoTypeUUID) <> '' then
    AChannel.RepoTypeUUID := ADevice.RepoTypeUUID;
  if Trim(ADevice.RepoDeviceName) <> '' then
    AChannel.RepoDeviceName := ADevice.RepoDeviceName;
  if Trim(ADevice.RepoDeviceUUID) <> '' then
    AChannel.RepoDeviceUUID := ADevice.RepoDeviceUUID;
end;


class procedure TDeviceCreationService.RecalcDevicePointQ(ADevice: TDevice);
var
  DevicePoint: TDevicePoint;
begin
  if (ADevice = nil) or (ADevice.Points = nil) or (ADevice.Qmax <= 0) then
    Exit;

  for DevicePoint in ADevice.Points do
    if (DevicePoint <> nil) and (DevicePoint.FlowRate > 0) then
      DevicePoint.Q := DevicePoint.FlowRate * ADevice.Qmax;
end;

class function TDeviceCreationService.EnsureDeviceForChannel(AChannel: TChannel;
  AWorkTable: TWorkTable; ARepo: TDeviceRepository; AMode: TDeviceCreateMode;
  ASourceDevice: TDevice; ACurrentPoint: TDevicePoint): TDevice;
var
  DeviceUUID: string;
  WasCreated: Boolean;
  WasPlaceholder: Boolean;
  DevicePoint: TDevicePoint;
begin
  Result := nil;
  if (AChannel = nil) or (ARepo = nil) then
    Exit;

  if AChannel.FlowMeter = nil then
    AChannel.RecreateFlowMeter(AWorkTable);

  DeviceUUID := Trim(AChannel.DeviceUUID);
  if (DeviceUUID = '') and (AChannel.FlowMeter <> nil) then
    DeviceUUID := Trim(AChannel.FlowMeter.DeviceUUID);
  if DeviceUUID = '' then
    DeviceUUID := TGUID.NewGuid.ToString;

  Result := FindDeviceByUUID(DeviceUUID, ARepo);
  WasCreated := Result = nil;
  if WasCreated then
  begin
    Result := ARepo.CreateDevice(ASourceDevice);
    if Result = nil then
      Exit;
    Result.UUID := DeviceUUID;
    Result.State := osNew;
  end
  else
    AddProtocol(AMode, 'Reuse', Result, AChannel);

  WasPlaceholder := SameText(Trim(Result.Comment), CEmptyGridDeviceComment);

  case AMode of
    dcmUserCreated:
      begin
        Result.Comment := '';
        Result.State := osNew;
      end;
    dcmGridPlaceholder:
      begin
        if WasCreated or WasPlaceholder then
        begin
          Result.Comment := '';
          Result.Name := '';
          Result.SerialNumber := '';
          Result.OutputType := -1;
        end;
      end;
    dcmMeasurementPromoted:
      begin
        if WasPlaceholder then
          Result.Comment := '';
      end;
  end;

  if (AMode <> dcmGridPlaceholder) or WasCreated or WasPlaceholder then
    FillDeviceFromChannel(Result, AChannel, AMode);

  if (AMode = dcmMeasurementPromoted) and (ASourceDevice <> nil) and
     (ASourceDevice <> Result) and (ASourceDevice.Qmax > 0) then
  begin
    Result.Qmax := ASourceDevice.Qmax;
    RecalcDevicePointQ(Result);
  end;

  SyncChannelAndFlowMeter(Result, AChannel);

  if AMode = dcmMeasurementPromoted then
  begin
    if (ACurrentPoint <> nil) and ((Result.Points = nil) or (Result.Points.Count = 0)) then
    begin
      DevicePoint := Result.AddPoint;
      if DevicePoint <> nil then
      begin
        DevicePoint.Assign(ACurrentPoint, False);
        DevicePoint.DeviceID := Result.ID;
        DevicePoint.DeviceUUID := Result.UUID;
        DevicePoint.State := osNew;
      end;
    end;

    if Result.State = osClean then
      Result.State := osModified;
  end;

  if WasCreated then
    AddProtocol(AMode, 'Create', Result, AChannel)
  else if (AMode = dcmMeasurementPromoted) and WasPlaceholder then
    AddProtocol(AMode, 'Promote', Result, AChannel);
end;

type
  {
    TParameterObserverBridge — промежуточный наблюдатель параметров
    рабочего стола.

    Класс реализует интерфейс IEventObserver, поэтому на него можно
    подписывать объекты TParameter через метод Subscribe.

    Сам класс не обрабатывает уведомления по существу.
    Его задача — передать полученное уведомление владельцу TWorkTable.
  }
  TParameterObserverBridge = class(TInterfacedObject, IEventObserver)
  private
    {
      Рабочий стол, которому принадлежат наблюдаемые параметры.

      Ссылка не является интерфейсной и не управляет временем жизни
      рабочего стола. TWorkTable должен существовать всё время,
      пока этот мост подписан на параметры.
    }
    FOwner: TWorkTable;

  public
    {
      Создаёт мост и связывает его с конкретным рабочим столом.

      AOwner — рабочий стол, который должен получать уведомления
      от своих параметров.
    }
    constructor Create(AOwner: TWorkTable);

    {
      Реализация метода интерфейса IEventObserver.

      Метод вызывается объектом TParameter, когда в параметре произошло
      изменение состояния, действие или доменное событие.

      Sender — объект, сформировавший уведомление. Обычно TParameter.

      Event — код типа уведомления, например:
        Ord(notifyStateChanged);
        Ord(notifyAction);
        Ord(notifyEvent).

      Data — дополнительные данные уведомления.
      В некоторых случаях здесь также может передаваться сам TParameter.

      Мост не изменяет Sender, Event и Data, а передаёт их в TWorkTable.
    }
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
  end;


constructor TParameterObserverBridge.Create(AOwner: TWorkTable);
begin
  {
    Инициализируем базовый класс TInterfacedObject.

    Это необходимо, поскольку TParameterObserverBridge реализует
    интерфейс IEventObserver и хранится через интерфейсную ссылку.
  }
  inherited Create;

  {
    Запоминаем рабочий стол, которому необходимо передавать
    уведомления от параметров.

    Например, мост создаётся в конструкторе TWorkTable:

      FParameterObserver := TParameterObserverBridge.Create(Self);

    После этого один экземпляр моста может использоваться для подписки
    сразу на несколько параметров данного рабочего стола.
  }
  FOwner := AOwner;
end;


procedure TParameterObserverBridge.OnNotify(
  Sender: TObject;
  Event: Integer;
  Data: TObject
);
begin
  {
    Проверяем, что рабочий стол ещё доступен.

    Такая проверка защищает от обращения по nil, хотя сама по себе
    не защищает от висячей ссылки, если TWorkTable уже уничтожен,
    а мост всё ещё остался подписан на какой-либо параметр.

    Поэтому перед уничтожением TWorkTable все подписки должны быть сняты.
  }
  if FOwner <> nil then
  begin
    {
      Передаём уведомление рабочему столу без изменения данных.

      Дальнейшая обработка выполняется в TWorkTable.HandleParameterNotify:

      1. определяется параметр-источник;
      2. анализируется общий тип уведомления;
      3. событие параметра преобразуется в событие рабочего стола;
      4. TWorkTable уведомляет уже своих подписчиков.

      Таким образом, TParameter ничего не должен знать о TWorkTable,
      а TWorkTable получает все события своих параметров через одну
      централизованную точку.
    }
    FOwner.HandleParameterNotify(Sender, Event, Data);
  end;
end;

{$ENDREGION}

  {$REGION 'TChannel'}

procedure TChannel.InitMeterValues;
var
  IsExisted: Integer;
begin
 ValueImp := TMeterValue.GetExistedMeterValueBool(FHashValueImp, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueImp.Description:='Импульсы за сек';
    FValueImp.DependenceType := INDEPENDENT;
    FValueImp.UpdateType := ONLINE_TYPE;
  end;

  FValueImp.SetAsImp;
  FValueImp.SetToSave(True);

  ValueImpTotal := TMeterValue.GetExistedMeterValueBool(FHashValueImpTotal, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueImp.Description:='Импульсы накопительный итог';
    FValueImpTotal.DependenceType := INDEPENDENT;
    FValueImpTotal.UpdateType := ONLINE_TYPE;
  end;

  FValueImpTotal.SetAsImp;
  FValueImpTotal.SetToSave(True);

  ValueCurrent := TMeterValue.GetExistedMeterValueBool(FHashValueCurrent, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueCurrent.SetAsCurrent;
    FValueImp.Description:='Ток текущий';
    FValueCurrent.DependenceType := INDEPENDENT;
    FValueCurrent.UpdateType := ONLINE_TYPE;
  end;
  FValueCurrent.SetToSave(True);

  ValueInterface := TMeterValue.GetExistedMeterValueBool(FHashValueInterface, IsExisted, UUID, Name);
  if IsExisted = 0 then
  begin
    FValueInterface.Name := 'Интерфейс';
    FValueInterface.ShrtName := 'Интерфейс';
    FValueImp.Description:='Значение расхода';
    FValueInterface.DependenceType := INDEPENDENT;
    FValueInterface.UpdateType := ONLINE_TYPE;
  end;
  FValueInterface.SetToSave(True);

end;

procedure TChannel.SetMeterValue(var ATarget: TMeterValue; var ATargetHash: string;const AValue: TMeterValue);
begin
  if ATarget = AValue then
  begin
    if ATarget <> nil then
      ATargetHash := ATarget.Hash
    else
      ATargetHash := '';
    Exit;
  end;

  if ATarget <> nil then
    TMeterValue.RebindReferences(ATarget, AValue);

  ATarget := AValue;
  if ATarget <> nil then
    ATargetHash := ATarget.Hash
  else
    ATargetHash := '';
end;

procedure TChannel.SetValueImp(const AValue: TMeterValue);
begin
  SetMeterValue(FValueImp, FHashValueImp, AValue);
end;

procedure TChannel.SetValueImpTotal(const AValue: TMeterValue);
begin
  SetMeterValue(FValueImpTotal, FHashValueImpTotal, AValue);
end;

procedure TChannel.SetValueCurrent(const AValue: TMeterValue);
begin
  SetMeterValue(FValueCurrent, FHashValueCurrent, AValue);
end;

procedure TChannel.SetValueInterface(const AValue: TMeterValue);
begin
  SetMeterValue(FValueInterface, FHashValueInterface, AValue);
end;

  { Creates a channel object, initializes defaults, and allocates linked meter values. }
constructor TChannel.Create;

begin
  inherited Create;

  FFlowMeter := TFlowMeter.Create;
  FOutputSet := TControlRegister<EOutPutSet>.Create;
  FSyncMode := TControlRegister<ESyncChannelMode>.Create;
  FNoiseFilter := TControlRegister<Integer>.Create;

  FEnabled := False;
  FName:= 'Канал';
  FText := '1';
  FImpSec := 0;
  FImpResult := 0;
  FCurSec := 0;
  FSimulationStartImpSec := 0;
  FSimulationTargetImpSec := 0;
  FSimulationRampStartTimeMs := 0;
  FSimulationRampDurationSec := 0;
  FSimulationRampActive := False;
  FSimulationLastProgressLogMs := 0;
  FCurResult := 0;
  FValueSec := 0;
  FValueResult := 0;
  FGroup := 0;
  FCategory := mftUnknownType;
  FWorkTabeID := 0;
  FQMaxWork := 0;
  FQMinWork := 0;
  FVMaxWork := 0;
  FVMinWork := 0;

  FFlowMeter.Name := 'Прибор ' + FName;
end;

{ Releases channel-owned resources and removes linked values from shared storage. }
destructor TChannel.Destroy;
begin
  FreeAndNil(FOutputSet);
  FreeAndNil(FSyncMode);
  FreeAndNil(FNoiseFilter);
  FreeAndNil(FFlowMeter);
  inherited Destroy;
end;


{ Initializes channel FlowMeter links using the configured device UUID. }
procedure TChannel.Init;
begin
  if not Assigned(FFlowMeter) then
    Exit;

  FFlowMeter.Init(DeviceUUID);
  if (FFlowMeter.Device <> nil) then
  begin
    FOutputSet.FromDefault(IntToOutputSet(FFlowMeter.Device.OutputSet));
    FSyncMode.FromDefault(IntToSyncChannelMode(FFlowMeter.Device.SyncMode));
    FNoiseFilter.FromDefault(FFlowMeter.Device.NoiseFilter);
  end;
end;

procedure TChannel.InitWorkRangesFromFlowMeter;
begin
  if FFlowMeter = nil then
    Exit;

  FQMaxWork := FFlowMeter.FlowMax;
  FQMinWork := FFlowMeter.FlowMin;
  FVMaxWork := FFlowMeter.QuantityMax;
  FVMinWork := FFlowMeter.QuantityMin;
end;
                                         {TODO -oOwner -cGeneral : ActionItem}
{ Rebinds FlowMeter value references to channel and work table meter values. }
procedure TChannel.RebindFlowMeterValues(const AWorkTable: TWorkTable);
begin
  if (FFlowMeter = nil) then
    Exit;


  FFlowMeter.RebindCalculatedValues;
  FFlowMeter.InitHashValues;

  // Pulse and current values are taken directly from the channel.
  FFlowMeter.ValueImp := FValueImp;
  FFlowMeter.ValueImpTotal := ValueImpResult;
  FFlowMeter.ValueCurrent := FValueCurrent;
  //Интерфейс тоже.

  if AWorkTable <> nil then
  begin
    // Temperature/pressure and atmospheric conditions are taken from the work table.
    FFlowMeter.ValueTemperture := AWorkTable.ValueTemperture;
    FFlowMeter.ValuePressure := AWorkTable.ValuePressure;
    FFlowMeter.ValueDensity := AWorkTable.ValueDensity;
    FFlowMeter.ValueAirPressure := AWorkTable.ValueAirPressure;
    FFlowMeter.ValueAirTemperture := AWorkTable.ValueAirTemperture;
    FFlowMeter.ValueHumidity := AWorkTable.ValueHumidity;
    FFlowMeter.ValueTime := AWorkTable.ValueTime;
  end;


end;

procedure TChannel.RecreateFlowMeter(const AWorkTable: TWorkTable);
begin
  FreeAndNil(FFlowMeter);
  FFlowMeter := TFlowMeter.Create;
  FFlowMeter.Name := 'Прибор ' + FName;

  Init;
  RebindFlowMeterValues(AWorkTable);
end;

 procedure TChannel.CreateDevice;
 var
    ADevice: TDevice;
    AType: TDeviceType;
    ActiveRepo:  TDeviceRepository;
    FoundRepo: TTypeRepository;
begin



  if FFlowMeter = nil then
  Exit;

  FFlowMeter.CreateDevice;

  end;

procedure TChannel.AssignFlowMeterFrom(const ASource: TChannel;
  const AWorkTable: TWorkTable; const ACloneDeviceToRepo: Boolean);
var
  SrcDevice: TDevice;
  NewDevice: TDevice;
begin
  if (ASource = nil) or (ASource.FFlowMeter = nil) then
    Exit;

  RecreateFlowMeter(AWorkTable);

  FFlowMeter.UUID := TGUID.NewGuid.ToString;
  FFlowMeter.Name := ASource.FFlowMeter.Name;
  FFlowMeter.DeviceUUID := ASource.FFlowMeter.DeviceUUID;
  FFlowMeter.DeviceTypeName := ASource.FFlowMeter.DeviceTypeName;
  FFlowMeter.DeviceTypeUUID := ASource.FFlowMeter.DeviceTypeUUID;
  FFlowMeter.RepoTypeName := ASource.FFlowMeter.RepoTypeName;
  FFlowMeter.RepoTypeUUID := ASource.FFlowMeter.RepoTypeUUID;
  FFlowMeter.RepoDeviceName := ASource.FFlowMeter.RepoDeviceName;
  FFlowMeter.RepoDeviceUUID := ASource.FFlowMeter.RepoDeviceUUID;
  FFlowMeter.SerialNumber := ASource.FFlowMeter.SerialNumber;
  FFlowMeter.OutputType := ASource.FFlowMeter.OutputType;

  FFlowMeter.Active := ASource.FFlowMeter.Active;
  FFlowMeter.CheckType := ASource.FFlowMeter.CheckType;
  FFlowMeter.Status := ASource.FFlowMeter.Status;
  FFlowMeter.SendStatus := ASource.FFlowMeter.SendStatus;
  FFlowMeter.FlowTypeName := ASource.FFlowMeter.FlowTypeName;
  FFlowMeter.DocNumber := ASource.FFlowMeter.DocNumber;
  FFlowMeter.Means := ASource.FFlowMeter.Means;
  FFlowMeter.K1 := ASource.FFlowMeter.K1;
  FFlowMeter.P1 := ASource.FFlowMeter.P1;
  FFlowMeter.K2 := ASource.FFlowMeter.K2;
  FFlowMeter.P2 := ASource.FFlowMeter.P2;
  FFlowMeter.TempWater := ASource.FFlowMeter.TempWater;
  FFlowMeter.Temperature := ASource.FFlowMeter.Temperature;
  FFlowMeter.Pressure := ASource.FFlowMeter.Pressure;
  FFlowMeter.Humidity := ASource.FFlowMeter.Humidity;
  FFlowMeter.VrfDate := ASource.FFlowMeter.VrfDate;
  FFlowMeter.Data1 := ASource.FFlowMeter.Data1;
  FFlowMeter.Data2 := ASource.FFlowMeter.Data2;
  FFlowMeter.Data3 := ASource.FFlowMeter.Data3;
  FFlowMeter.Date1 := ASource.FFlowMeter.Date1;
  FFlowMeter.Date2 := ASource.FFlowMeter.Date2;
  FFlowMeter.ResultValue := ASource.FFlowMeter.ResultValue;
  FFlowMeter.MeterDateTime := ASource.FFlowMeter.MeterDateTime;
  FFlowMeter.ModifiedDateTime := ASource.FFlowMeter.ModifiedDateTime;
  FFlowMeter.Kp := ASource.FFlowMeter.Kp;
  FFlowMeter.FactoryKp := ASource.FFlowMeter.FactoryKp;
  FFlowMeter.FreqMax := ASource.FFlowMeter.FreqMax;
  FFlowMeter.FlowMax := ASource.FFlowMeter.FlowMax;
  FFlowMeter.FlowMin := ASource.FFlowMeter.FlowMin;
  FFlowMeter.QuantityMax := ASource.FFlowMeter.QuantityMax;
  FFlowMeter.QuantityMin := ASource.FFlowMeter.QuantityMin;
  FQMaxWork := ASource.FQMaxWork;
  FQMinWork := ASource.FQMinWork;
  FVMaxWork := ASource.FVMaxWork;
  FVMinWork := ASource.FVMinWork;
  FFlowMeter.Error := ASource.FFlowMeter.Error;
  FFlowMeter.PointIndex := ASource.FFlowMeter.PointIndex;
  FFlowMeter.Comment := ASource.FFlowMeter.Comment;
  FFlowMeter.MeterFlowCategory := ASource.FFlowMeter.MeterFlowCategory;
  FCategory := ASource.FCategory;
  FGroup := ASource.FGroup;
  OutputSet := ASource.OutputSet;
  SyncMode := ASource.SyncMode;
  NoiseFilter := ASource.NoiseFilter;

  SrcDevice := ASource.FFlowMeter.Device;
  if ACloneDeviceToRepo and (SrcDevice <> nil) and (DataManager <> nil) and (DataManager.ActiveDeviceRepo <> nil) then
  begin
    NewDevice := DataManager.ActiveDeviceRepo.CreateDevice(SrcDevice);
    NewDevice.UUID := TGUID.NewGuid.ToString;
    NewDevice.SerialNumber := SrcDevice.SerialNumber;
    FFlowMeter.Device := NewDevice;
  end
  else if SrcDevice <> nil then
  begin
    FFlowMeter.DeviceTypeName := SrcDevice.DeviceTypeName;
    FFlowMeter.DeviceTypeUUID := SrcDevice.DeviceTypeUUID;
    FFlowMeter.SerialNumber := SrcDevice.SerialNumber;
    FFlowMeter.OutputType := SrcDevice.OutputType;
  end;

  RebindFlowMeterValues(AWorkTable);
end;

// =====================================================
// == Proxy: FlowMeter fields
// =====================================================

{ Returns device type name from FlowMeter for proxy property access. }
function TChannel.GetTypeNameProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.DeviceTypeName
  else
    Result := '';
end;

function TChannel.GetDeviceNameProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.DeviceName
  else
    Result := '';
end;

procedure TChannel.SetDeviceNameProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.DeviceName := AValue;
end;

{ Updates FlowMeter device type name through proxy property. }
procedure TChannel.SetTypeNameProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.DeviceTypeName := AValue;
end;

{ Returns serial number from FlowMeter for proxy property access. }
function TChannel.GetSerialProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.SerialNumber
  else
    Result := '';
end;

{ Updates FlowMeter serial number through proxy property. }
procedure TChannel.SetSerialProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.SerialNumber := AValue;
end;

{ Returns FlowMeter output signal type for proxy property access. }
function TChannel.GetSignalProxy: Integer;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.OutputType
  else
    Result := -1;
end;

{ Updates FlowMeter output signal type through proxy property. }
procedure TChannel.SetSignalProxy(const AValue: Integer);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.OutputType := AValue;
end;

function TChannel.GetOutputSetProxy: EOutPutSet;
begin
  if FOutputSet <> nil then
    Result := FOutputSet.Value
  else
    Result := optAuto;
end;

procedure TChannel.SetOutputSetProxy(const AValue: EOutPutSet);
begin
  if FOutputSet <> nil then
    FOutputSet.SetValue(AValue);
end;

function TChannel.GetSyncModeProxy: ESyncChannelMode;
begin
  if FSyncMode <> nil then
    Result := FSyncMode.Value
  else
    Result := scmOff;
end;

procedure TChannel.SetSyncModeProxy(const AValue: ESyncChannelMode);
begin
  if FSyncMode <> nil then
    FSyncMode.SetValue(AValue);
end;

function TChannel.GetNoiseFilterProxy: Integer;
begin
  if FNoiseFilter <> nil then
    Result := FNoiseFilter.Value
  else
    Result := 0;
end;

procedure TChannel.SetNoiseFilterProxy(const AValue: Integer);
begin
  if FNoiseFilter <> nil then
    FNoiseFilter.SetValue(AValue);
end;


function TChannel.GetOutputSetStateColor: TAlphaColor;
begin
  if FOutputSet <> nil then
    Result := FOutputSet.GetStateColor
  else
    Result := TAlphaColors.Gray;
end;

function TChannel.GetSyncModeStateColor: TAlphaColor;
begin
  if FSyncMode <> nil then
    Result := FSyncMode.GetStateColor
  else
    Result := TAlphaColors.Gray;
end;

function TChannel.GetNoiseFilterStateColor: TAlphaColor;
begin
  if FNoiseFilter <> nil then
    Result := FNoiseFilter.GetStateColor
  else
    Result := TAlphaColors.Gray;
end;

function TChannel.GetCategoryProxy: Integer;
begin
  if Assigned(FFlowMeter) and Assigned(FFlowMeter.Device) then
    Result := FFlowMeter.Device.Category
  else
    Result := Ord(FCategory);
end;

procedure TChannel.SetCategoryProxy(const AValue: Integer);
begin
  if Assigned(FFlowMeter) and Assigned(FFlowMeter.Device) then
  begin
    FFlowMeter.Device.Category := AValue;
    FFlowMeter.Device.State := osModified;
  end
  else
    if (AValue >= Ord(Low(EStdCategory))) and (AValue <= Ord(High(EStdCategory))) then
      FCategory := EStdCategory(AValue)
    else
      FCategory := mftUnknownType;
end;

{ Returns bound FlowMeter device UUID for proxy property access. }
function TChannel.GetDeviceUUIDProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.DeviceUUID
  else
    Result := '';
end;

{ Updates FlowMeter device UUID through proxy property. }
procedure TChannel.SetDeviceUUIDProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
  begin
    FFlowMeter.DeviceUUID := AValue;
  end;
end;

function TChannel.GetTypeUUIDProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.DeviceTypeUUID
  else
    Result := '';
end;

procedure TChannel.SetTypeUUIDProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.DeviceTypeUUID := AValue;
end;

function TChannel.GetRepoTypeNameProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.RepoTypeName
  else
    Result := '';
end;

procedure TChannel.SetRepoTypeNameProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.RepoTypeName := AValue;
end;

function TChannel.GetRepoTypeUUIDProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.RepoTypeUUID
  else
    Result := '';
end;

procedure TChannel.SetRepoTypeUUIDProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.RepoTypeUUID := AValue;
end;

function TChannel.GetRepoDeviceNameProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.RepoDeviceName
  else
    Result := '';
end;

procedure TChannel.SetRepoDeviceNameProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.RepoDeviceName := AValue;
end;

function TChannel.GetRepoDeviceUUIDProxy: string;
begin
  if Assigned(FFlowMeter) then
    Result := FFlowMeter.RepoDeviceUUID
  else
    Result := '';
end;

procedure TChannel.SetRepoDeviceUUIDProxy(const AValue: string);
begin
  if Assigned(FFlowMeter) then
    FFlowMeter.RepoDeviceUUID := AValue;
end;

// =====================================================
// == Proxy: channel internal variables
// =====================================================

{ Returns channel pulse-per-second runtime value. }
function TChannel.GetImpSecProxy: Double;
begin
  Result := FImpSec;
end;

{ Stores channel pulse-per-second runtime value. }
procedure TChannel.SetImpSecProxy(const AValue: Double);
begin
  FImpSec := AValue;
end;

{ Returns channel pulse result value. }
function TChannel.GetImpResultProxy: Double;
begin
  Result := FImpResult;
end;

{ Stores channel pulse result value. }
procedure TChannel.SetImpResultProxy(const AValue: Double);
begin
  FImpResult := AValue;
end;

{ Returns channel current-per-second runtime value. }
function TChannel.GetCurSecProxy: Double;
begin
  Result := FCurSec;
end;

{ Stores channel current-per-second runtime value. }
procedure TChannel.SetCurSecProxy(const AValue: Double);
begin
  FCurSec := AValue;
end;

{ Returns channel current result value. }
function TChannel.GetCurResultProxy: Double;
begin
  Result := FCurResult;
end;

{ Stores channel current result value. }
procedure TChannel.SetCurResultProxy(const AValue: Double);
begin
  FCurResult := AValue;
end;

{ Returns channel current result value. }
function TChannel.GetVolResultProxy: Double;
begin
  Result := FCurResult;
end;

{ Stores channel current result value. }
procedure TChannel.SetVolResultProxy(const AValue: Double);
begin
  FCurResult := AValue;
end;

{ Returns channel secondary runtime value. }
function TChannel.GetValueSecProxy: Double;
begin
  Result := FValueSec;
end;

{ Stores channel secondary runtime value. }
procedure TChannel.SetValueSecProxy(const AValue: Double);
begin
  FValueSec := AValue;
end;

{ Returns channel secondary runtime value. }
function TChannel.GetVolSecProxy: Double;
begin
  Result := FVolSec;
end;

{ Stores channel secondary runtime value. }
procedure TChannel.SetVolSecProxy(const AValue: Double);
begin
  FVolSec := AValue;
end;

{ Returns channel secondary result value. }
function TChannel.GetValueResultProxy: Double;
begin
  Result := FValueResult;
end;

{ Stores channel secondary result value. }
procedure TChannel.SetValueResultProxy(const AValue: Double);
begin
  FValueResult := AValue;
end;

procedure TChannel.SetValues;
begin
 if FFlowMeter<>nil then
    FFlowMeter.SetValues;
end;


    {$ENDREGION}

  {$REGION 'TWorkTable'}

{ Creates a work table with default state, channels lists, and meter values. }
constructor TWorkTable.Create;
begin
  inherited Create;
  FParameterObserver := TParameterObserverBridge.Create(Self);
  FUUID := TGUID.NewGuid.ToString;
  FSyncSetup := TSyncSetup.Create;

  FDeviceChannels := TObjectList<TChannel>.Create(True);
  FEtalonChannels := TObjectList<TChannel>.Create(True);

  Name := BuildWorkTableServiceName(ID);
      if Trim(Text) = '' then
        Text := 'Рабочий стол ' + IntToStr(ID);

  FPumps := TObjectList<TPump>.Create(false); // True — автоосвобождение объектов   False- хрантся копии
  FScales := TObjectList<TWeight>.Create(false);
  FlowRate := TFlowRate.Create('Расход');
  FFluidTemp := TFluidTemp.Create;
  FFluidPress := TFluidPress.Create;
  BindParameterEvents(FlowRate);
  BindParameterEvents(FFluidTemp);
  BindParameterEvents(FFluidPress);

  FTableFlow := TFlowMeter.Create;

  FState := swtNONE;
  FAction := awtNone;
  FMode := mrmAutomatic;
  FTableClamped := False;
  FText := 'Рабочий стол 1';
  FFlowUnitName := 'м3/ч';
  FQuantityUnitName := 'м3';
  FTimeSet := 0;
  FLimitImpSet := 0;
  FLimitVolumeSet := 0;
  FSimulationLastUpdateTimeMs := 0;
  FSimulationLastFlowUnitsLogTarget := 0;
  FSimulationTargetFlowBase := 0;

  FCurrentPoint := TDevicePoint.Create(0);
  FCurrentPoint.LimitTime := -1;
  FCurrentPoint.LimitImp := -1;
  FCurrentPoint.LimitVolume := -1;
  FCurrentPoint.StopCriteria := [];

  FLayoutFlowRateVisible := True;
  FLayoutPumpVisible := True;
  FLayoutMainVisible := True;
  FLayoutMesureVisible := True;
  FLayoutConditionsVisible := True;
  FLayoutProceduresVisible := True;
  FInstrumentalLayoutOrder := 'FlowRate,Pump,Main,Mesure,Conditions,Procedures';

  //Temp := 20.2;
  TempDelta := 0.1;
  //Press := 101.1;
  PressDelta := 0.1;
  //FlowRate := 10;

  FMeasurementRun := TMeasurementRun.Create(Self);
  FIsActive := False;

  ProtocolManager.AddMessage(pcState, psWorkTable, 'WorkTableCreate',
    'Создан рабочий стол', Name);


 // InitMeterValues;
end;

{ Creates/restores all work table meter values and configures their dependencies. }
procedure TWorkTable.InitMeterValues;
var
  IsExisted: Integer;
  procedure EnsureDescription(AMeterValue: TMeterValue; const ADescription: string);
  begin
    if (AMeterValue <> nil) and (Trim(AMeterValue.Description) = '') then
      AMeterValue.Description := ADescription;
  end;
begin

  ValueTempertureBefore := TMeterValue.GetExistedMeterValueBool(FHashValueTempertureBefore, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueTempertureBefore.SetAsTemp;
    FTableFlow.ValueTempertureBefore.DependenceType := INDEPENDENT;
    FTableFlow.ValueTempertureBefore.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueTempertureBefore, 'Температура до стола');
  FTableFlow.ValueTempertureBefore.SetToSave(True);

  ValueTempertureAfter := TMeterValue.GetExistedMeterValueBool(FHashValueTempertureAfter, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueTempertureAfter.SetAsTemp;
    FTableFlow.ValueTempertureAfter.DependenceType := INDEPENDENT;
    FTableFlow.ValueTempertureAfter.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueTempertureAfter, 'Температура после стола');
  FTableFlow.ValueTempertureAfter.SetToSave(True);

  ValueTempertureDelta := TMeterValue.GetExistedMeterValueBool(FHashValueTempertureDelta, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueTempertureDelta.SetAsError;
    FTableFlow.ValueTempertureDelta.DependenceType := INDEPENDENT;
    FTableFlow.ValueTempertureDelta.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueTempertureDelta, 'Разница температур до и после стола');
  FTableFlow.ValueTempertureDelta.SetToSave(True);

  ValueTemperture := TMeterValue.GetExistedMeterValueBool(FHashValueTemperture, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueTemperture.SetAsTemp;
    FTableFlow.ValueTemperture.DependenceType := INDEPENDENT;
    FTableFlow.ValueTemperture.UpdateType := ONLINE_TYPE;
  end;
  //FTableFlow.ValueTemperture.SetAsTemp;
  FTableFlow.ValueTemperture.ValueType := MEAN_TYPE;
  FTableFlow.ValueTemperture.ValueBaseMultiplier := FTableFlow.ValueTempertureAfter;
  FTableFlow.ValueTemperture.ValueBaseDevider := FTableFlow.ValueTempertureBefore;
  EnsureDescription(FTableFlow.ValueTemperture, 'Средняя температура стола');
  FTableFlow.ValueTemperture.SetToSave(True);

  ValuePressureBefore := TMeterValue.GetExistedMeterValueBool(FHashValuePressureBefore, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValuePressureBefore.SetAsPressure;
    FTableFlow.ValuePressureBefore.DependenceType := INDEPENDENT;
    FTableFlow.ValuePressureBefore.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValuePressureBefore, 'Давление до стола');
  FTableFlow.ValuePressureBefore.SetToSave(True);

  ValuePressureAfter := TMeterValue.GetExistedMeterValueBool(FHashValuePressureAfter, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValuePressureAfter.SetAsPressure;
    FTableFlow.ValuePressureAfter.DependenceType := INDEPENDENT;
    FTableFlow.ValuePressureAfter.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValuePressureAfter, 'Давление после стола');
  FTableFlow.ValuePressureAfter.SetToSave(True);

  ValuePressureDelta := TMeterValue.GetExistedMeterValueBool(FHashValuePressureDelta, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValuePressureDelta.SetAsError;
    FTableFlow.ValuePressureDelta.DependenceType := INDEPENDENT;
    FTableFlow.ValuePressureDelta.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValuePressureDelta, 'Разница давлений до и после стола');
  FTableFlow.ValuePressureDelta.SetToSave(True);

  ValuePressure := TMeterValue.GetExistedMeterValueBool(FHashValuePressure, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValuePressure.SetAsPressure;
    FTableFlow.ValuePressure.DependenceType := INDEPENDENT;
    FTableFlow.ValuePressure.UpdateType := ONLINE_TYPE;
  end;
  FTableFlow.ValuePressure.ValueType := MEAN_TYPE;
  FTableFlow.ValuePressure.ValueBaseMultiplier := FTableFlow.ValuePressureAfter;
  FTableFlow.ValuePressure.ValueBaseDevider := FTableFlow.ValuePressureBefore;
  EnsureDescription(FTableFlow.ValuePressure, 'Среднее давление стола');
  FTableFlow.ValuePressure.SetToSave(True);

  ValueDensity := TMeterValue.GetExistedMeterValueBool(FHashValueDensity, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueDensity.SetAsDensity;
  end;
  EnsureDescription(FTableFlow.ValueDensity, 'Плотность среды');
  FTableFlow.ValueDensity.ValueBaseMultiplier := FTableFlow.ValueTemperture;
  FTableFlow.ValueDensity.ValueBaseDevider := FTableFlow.ValuePressure;
  FTableFlow.ValueDensity.ValueRate := nil;
  FTableFlow.ValueDensity.ValueEtalon := nil;
  FTableFlow.ValueDensity.SetToSave(True);

  ValueAirPressure := TMeterValue.GetExistedMeterValueBool(FHashValueAirPressure, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueAirPressure.SetAsAirPressure;
    FTableFlow.ValueAirPressure.DependenceType := INDEPENDENT;
    FTableFlow.ValueAirPressure.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueAirPressure, 'Атмосферное давление');
  FTableFlow.ValueAirPressure.SetToSave(True);

  ValueAirTemperture := TMeterValue.GetExistedMeterValueBool(FHashValueAirTemperture, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueAirTemperture.SetAsAirTemp;
    FTableFlow.ValueAirTemperture.DependenceType := INDEPENDENT;
    FTableFlow.ValueAirTemperture.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueAirTemperture, 'Температура воздуха');
  FTableFlow.ValueAirTemperture.SetToSave(True);

  ValueHumidity := TMeterValue.GetExistedMeterValueBool(FHashValueHumidity, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueHumidity.SetAsHumidity;
    FTableFlow.ValueHumidity.DependenceType := INDEPENDENT;
    FTableFlow.ValueHumidity.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueHumidity, 'Влажность воздуха');
  FTableFlow.ValueHumidity.SetToSave(True);

  ValueTime := TMeterValue.GetExistedMeterValueBool(FHashValueTime, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueTime.SetAsTime;
    FTableFlow.ValueTime.DependenceType := INDEPENDENT;
    FTableFlow.ValueTime.UpdateType := ONLINE_TYPE;
  end;
  EnsureDescription(FTableFlow.ValueTime, 'Время измерения');
  FTableFlow.ValueTime.SetToSave(True);

  ValueQuantity := TMeterValue.GetExistedMeterValueBool(FHashValueQuantity, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueQuantity.SetAsVolume;
    FTableFlow.ValueQuantity.DependenceType := INDEPENDENT;
    FTableFlow.ValueQuantity.UpdateType := ONLINE_TYPE;
  end;
  FTableFlow.ValueQuantity.ValueType := AGGREGATE_TYPE;
  EnsureDescription(FTableFlow.ValueQuantity, 'Кол-во жидкости за измерение');
  FTableFlow.ValueQuantity.SetToSave(True);

  ValueFlowRate := TMeterValue.GetExistedMeterValueBool(FHashValueFlowRate, IsExisted, '', Name);
  if IsExisted = 0 then
  begin
    FTableFlow.ValueFlowRate.SetAsVolumeFlow;
    FTableFlow.ValueFlowRate.DependenceType := INDEPENDENT;
    FTableFlow.ValueFlowRate.UpdateType := ONLINE_TYPE;
  end;
  FTableFlow.ValueFlowRate.ValueType := AGGREGATE_TYPE;
  EnsureDescription(FTableFlow.ValueFlowRate, 'Расход');
  FTableFlow.ValueFlowRate.SetToSave(True);

  // Инициализируем оставшиеся значения расходомера стола,
  // чтобы у FTableFlow не оставалось неинициализированных TMeterValue.
  if FTableFlow.ValueImp = nil then
  begin
    FTableFlow.ValueImp := TMeterValue.Create('', Name);
    FTableFlow.ValueImp.SetAsImp;
    FTableFlow.ValueImp.ValueType := AGGREGATEMIN_TYPE;
    EnsureDescription(FTableFlow.ValueImp, 'Импульсы стола');
  end;

  if FTableFlow.ValueImpTotal = nil then
  begin
    FTableFlow.ValueImpTotal := TMeterValue.Create('', Name);
    FTableFlow.ValueImpTotal.SetAsImp;
    FTableFlow.ValueImp.ValueType := AGGREGATEMIN_TYPE;
    EnsureDescription(FTableFlow.ValueImpTotal, 'Суммарные импульсы стола');
  end;

  if FTableFlow.ValueMassCoef = nil then
  begin
    FTableFlow.ValueMassCoef := TMeterValue.Create('', Name);
    FTableFlow.ValueMassCoef.SetAsMassCoef;
    FTableFlow.ValueMassCoef.SetValue(1);
    EnsureDescription(FTableFlow.ValueMassCoef, 'Коэффициент массы');
  end;

  if FTableFlow.ValueVolumeCoef = nil then
  begin
    FTableFlow.ValueVolumeCoef := TMeterValue.Create('', Name);
    FTableFlow.ValueVolumeCoef.SetAsVolumeCoef;
    FTableFlow.ValueVolumeCoef.SetValue(1);
    EnsureDescription(FTableFlow.ValueVolumeCoef, 'Коэффициент объема');
  end;

  if FTableFlow.ValueMassFlow = nil then
  begin
    FTableFlow.ValueMassFlow := TMeterValue.Create('', Name);
    FTableFlow.ValueMassFlow.SetAsMassFlow;
    EnsureDescription(FTableFlow.ValueMassFlow, 'Массовый расход стола');
  end;

  if FTableFlow.ValueVolumeFlow = nil then
  begin
    FTableFlow.ValueVolumeFlow := TMeterValue.Create('', Name);
    FTableFlow.ValueVolumeFlow.SetAsVolumeFlow;
    EnsureDescription(FTableFlow.ValueVolumeFlow, 'Объемный расход стола');
  end;

  if FTableFlow.ValueVolume = nil then
  begin
    FTableFlow.ValueVolume := TMeterValue.Create('', Name);
    FTableFlow.ValueVolume.SetAsVolume;
    EnsureDescription(FTableFlow.ValueVolume, 'Объем стола');
  end;

  if FTableFlow.ValueMass = nil then
  begin
    FTableFlow.ValueMass := TMeterValue.Create('', Name);
    FTableFlow.ValueMass.SetAsMass;
    EnsureDescription(FTableFlow.ValueMass, 'Масса стола');
  end;

  if FTableFlow.ValueVolumeMeter = nil then
  begin
    FTableFlow.ValueVolumeMeter := TMeterValue.Create('', Name);
    FTableFlow.ValueVolumeMeter.SetAsVolume;
    EnsureDescription(FTableFlow.ValueVolumeMeter, 'Объем по прибору стола');
  end;

  if FTableFlow.ValueMassMeter = nil then
  begin
    FTableFlow.ValueMassMeter := TMeterValue.Create('', Name);
    FTableFlow.ValueMassMeter.SetAsMass;
    EnsureDescription(FTableFlow.ValueMassMeter, 'Масса по прибору стола');
  end;

  if FTableFlow.ValueVolumeError = nil then
  begin
    FTableFlow.ValueVolumeError := TMeterValue.Create('', Name);
    FTableFlow.ValueVolumeError.SetAsVolumeError;
    EnsureDescription(FTableFlow.ValueVolumeError, 'Погрешность объема стола');
  end;

  if FTableFlow.ValueMassError = nil then
  begin
    FTableFlow.ValueMassError := TMeterValue.Create('', Name);
    FTableFlow.ValueMassError.SetAsMassError;
    EnsureDescription(FTableFlow.ValueMassError, 'Погрешность массы стола');
  end;

  if FTableFlow.ValueError = nil then
  begin
    FTableFlow.ValueError := TMeterValue.Create('', Name);
    FTableFlow.ValueError.SetAsError;
    EnsureDescription(FTableFlow.ValueError, 'Итоговая погрешность стола');
  end;

  if FTableFlow.ValueCurrent = nil then
  begin
    FTableFlow.ValueCurrent := TMeterValue.Create('', Name);
    FTableFlow.ValueCurrent.SetAsCurrent;
    EnsureDescription(FTableFlow.ValueCurrent, 'Токовый сигнал стола');
  end;

  if FTableFlow.ValueFlowRate <> nil then
    FlowRate.Value := FTableFlow.ValueFlowRate;
  EnsureDescription(FlowRate.Value, 'Расход');

  if FTableFlow.ValueTemperture <> nil then
    FluidTemp.Value := FTableFlow.ValueTemperture;
  EnsureDescription(FluidTemp.Value, 'Температура');

  if FTableFlow.ValuePressure <> nil then
    FluidPress.Value := FTableFlow.ValuePressure;
  EnsureDescription(FluidPress.Value, 'Давление');

    if FlowRate.Valueset = nil then
  begin
    FlowRate.Valueset := TMeterValue.Create('', Name);
    FlowRate.Valueset.SetAsVolumeFlow;
    EnsureDescription(FlowRate.Valueset, 'Установленный расход');
  end;
    if FluidTemp.Valueset = nil then
  begin
    FluidTemp.Valueset := TMeterValue.Create('', Name);
    FluidTemp.Valueset.SetAsAirTemp;
    EnsureDescription(FluidTemp.Valueset, 'Установленная температура');
  end;

    if FluidPress.Valueset = nil then
  begin
    FluidPress.Valueset := TMeterValue.Create('', Name);
    FluidPress.Valueset.SetAsPressure;
    EnsureDescription(FluidPress.Valueset, 'Установленное давление');
  end;


  // Настраиваем вычислительные связи для всех инициализированных значений.
  FTableFlow.ValueMassFlow.ValueCorrection := nil;
  FTableFlow.ValueMassFlow.ValueBaseMultiplier := FTableFlow.ValueImp;
  FTableFlow.ValueMassFlow.ValueBaseDevider := FTableFlow.ValueMassCoef;
  FTableFlow.ValueMassFlow.ValueRate := nil;
  FTableFlow.ValueMassFlow.ValueEtalon := nil;

  FTableFlow.ValueVolumeFlow.ValueCorrection := nil;
  FTableFlow.ValueVolumeFlow.ValueBaseMultiplier := FTableFlow.ValueImp;
  FTableFlow.ValueVolumeFlow.ValueBaseDevider := FTableFlow.ValueVolumeCoef;
  FTableFlow.ValueVolumeFlow.ValueRate := nil;
  FTableFlow.ValueVolumeFlow.ValueEtalon := nil;

  FTableFlow.ValueVolume.ValueCorrection := FTableFlow.ValueVolumeFlow;
  FTableFlow.ValueVolume.ValueBaseMultiplier := FTableFlow.ValueImpTotal;
  FTableFlow.ValueVolume.ValueBaseDevider := FTableFlow.ValueVolumeCoef;
  FTableFlow.ValueVolume.ValueRate := nil;
  FTableFlow.ValueVolume.ValueEtalon := nil;

  FTableFlow.ValueMass.ValueCorrection := FTableFlow.ValueMassFlow;
  FTableFlow.ValueMass.ValueBaseMultiplier := FTableFlow.ValueImpTotal;
  FTableFlow.ValueMass.ValueBaseDevider := FTableFlow.ValueMassCoef;
  FTableFlow.ValueMass.ValueRate := nil;
  FTableFlow.ValueMass.ValueEtalon := nil;

  FTableFlow.ValueVolumeError.ValueBaseMultiplier := FTableFlow.ValueVolume;
  FTableFlow.ValueMassError.ValueBaseMultiplier := FTableFlow.ValueMass;
  FTableFlow.ValueError.ValueBaseMultiplier := FTableFlow.ValueQuantity;

  FTableFlow.SetMeterCategory(FTableFlow.MeterFlowCategory);

  AssignTableFlowAsEtalonToDevices;
end;

procedure TWorkTable.AssignTableFlowAsEtalonToDevices;
var
  I: Integer;
  Channel: TChannel;
begin
  if FTableFlow = nil then
    Exit;

  for I := 0 to FDeviceChannels.Count - 1 do
  begin
    Channel := FDeviceChannels[I];
    if (Channel <> nil) and (Channel.FlowMeter <> nil) then
      Channel.FlowMeter.SetEtalon(FTableFlow);
  end;
end;

function TWorkTable.GetValueTempertureBefore: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueTempertureBefore else Result := nil;
end;

function TWorkTable.GetFlowRate: Double;
begin
  if FlowRate <> nil then
    Result := FlowRate.Value.Value
  else
    Result := FlowRate.Min;
end;

function TWorkTable.GetValueTempertureAfter: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueTempertureAfter else Result := nil;
end;

function TWorkTable.GetValueTempertureDelta: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueTempertureDelta else Result := nil;
end;

function TWorkTable.GetValueTemperture: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueTemperture else Result := nil;
end;

function TWorkTable.GetValuePressureBefore: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValuePressureBefore else Result := nil;
end;

function TWorkTable.GetValuePressureAfter: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValuePressureAfter else Result := nil;
end;

function TWorkTable.GetValuePressureDelta: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValuePressureDelta else Result := nil;
end;

function TWorkTable.GetValuePressure: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValuePressure else Result := nil;
end;

function TWorkTable.GetValueDensity: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueDensity else Result := nil;
end;

function TWorkTable.GetValueAirPressure: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueAirPressure else Result := nil;
end;

function TWorkTable.GetValueAirTemperture: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueAirTemperture else Result := nil;
end;

function TWorkTable.GetValueHumidity: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueHumidity else Result := nil;
end;

function TWorkTable.GetValueTime: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueTime else Result := nil;
end;

function TWorkTable.GetValueQuantity: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueQuantity else Result := nil;
end;

function TWorkTable.GetValueFlowRate: TMeterValue;
begin
  if FTableFlow <> nil then Result := FTableFlow.ValueFlowRate else Result := nil;
end;

procedure TWorkTable.SetValueTempertureBefore(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueTempertureBefore := AValue;
  if AValue <> nil then
    FHashValueTempertureBefore := AValue.Hash
  else
    FHashValueTempertureBefore := '';
end;

procedure TWorkTable.SetValueTempertureAfter(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueTempertureAfter := AValue;
  if AValue <> nil then
    FHashValueTempertureAfter := AValue.Hash
  else
    FHashValueTempertureAfter := '';
end;

procedure TWorkTable.SetValueTempertureDelta(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueTempertureDelta := AValue;
  if AValue <> nil then
    FHashValueTempertureDelta := AValue.Hash
  else
    FHashValueTempertureDelta := '';
end;

procedure TWorkTable.SetValueTemperture(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueTemperture := AValue;
  if AValue <> nil then
    FHashValueTemperture := AValue.Hash
  else
    FHashValueTemperture := '';
end;

procedure TWorkTable.SetValuePressureBefore(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValuePressureBefore := AValue;
  if AValue <> nil then
    FHashValuePressureBefore := AValue.Hash
  else
    FHashValuePressureBefore := '';
end;

procedure TWorkTable.SetValuePressureAfter(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValuePressureAfter := AValue;
  if AValue <> nil then
    FHashValuePressureAfter := AValue.Hash
  else
    FHashValuePressureAfter := '';
end;

procedure TWorkTable.SetValuePressureDelta(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValuePressureDelta := AValue;
  if AValue <> nil then
    FHashValuePressureDelta := AValue.Hash
  else
    FHashValuePressureDelta := '';
end;

procedure TWorkTable.SetValuePressure(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValuePressure := AValue;
  if AValue <> nil then
    FHashValuePressure := AValue.Hash
  else
    FHashValuePressure := '';
end;

procedure TWorkTable.SetValueDensity(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueDensity := AValue;
  if AValue <> nil then
    FHashValueDensity := AValue.Hash
  else
    FHashValueDensity := '';
end;

procedure TWorkTable.SetValueAirPressure(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueAirPressure := AValue;
  if AValue <> nil then
    FHashValueAirPressure := AValue.Hash
  else
    FHashValueAirPressure := '';
end;

procedure TWorkTable.SetValueAirTemperture(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueAirTemperture := AValue;
  if AValue <> nil then
    FHashValueAirTemperture := AValue.Hash
  else
    FHashValueAirTemperture := '';
end;

procedure TWorkTable.SetValueHumidity(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueHumidity := AValue;
  if AValue <> nil then
    FHashValueHumidity := AValue.Hash
  else
    FHashValueHumidity := '';
end;

procedure TWorkTable.SetValueTime(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueTime := AValue;
  if AValue <> nil then
    FHashValueTime := AValue.Hash
  else
    FHashValueTime := '';
end;

procedure TWorkTable.SetValueQuantity(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueQuantity := AValue;
  if AValue <> nil then
    FHashValueQuantity := AValue.Hash
  else
    FHashValueQuantity := '';
end;

procedure TWorkTable.SetValueFlowRate(const AValue: TMeterValue);
begin
  if FTableFlow <> nil then
    FTableFlow.ValueFlowRate := AValue;
  if AValue <> nil then
    FHashValueFlowRate := AValue.Hash
  else
    FHashValueFlowRate := '';
end;


procedure TWorkTable.RemoveMeterValuesFromStorage(ADeletedHashes: TStrings);
var
  Channel: TChannel;

  procedure RemoveMeterValue(AMeterValue: TMeterValue);
  begin
    // Запоминаем Hash: по этому списку затем физически чистится MeterValues.ini.
    if AMeterValue <> nil then
    begin
      if (ADeletedHashes <> nil) and (Trim(AMeterValue.Hash) <> '') and
         (ADeletedHashes.IndexOf(AMeterValue.Hash) < 0) then
        ADeletedHashes.Add(AMeterValue.Hash);

      AMeterValue.SetToSave(False);
      AMeterValue.DeleteFromVector;
    end;
  end;

  procedure RemoveChannelMeterValues(AChannel: TChannel);
  begin
    if AChannel = nil then
      Exit;

    RemoveMeterValue(AChannel.ValueImp);
    RemoveMeterValue(AChannel.ValueImpTotal);
    RemoveMeterValue(AChannel.ValueCurrent);
    RemoveMeterValue(AChannel.ValueInterface);
  end;

begin
  // Сначала удаляем значения каналов, относящиеся только к этому рабочему столу.
  if FDeviceChannels <> nil then
    for Channel in FDeviceChannels do
      RemoveChannelMeterValues(Channel);

  if FEtalonChannels <> nil then
    for Channel in FEtalonChannels do
      RemoveChannelMeterValues(Channel);

  // Затем удаляем собственные значения расходомера рабочего стола.
  if FTableFlow <> nil then
  begin
    RemoveMeterValue(FTableFlow.ValueTempertureBefore);
    RemoveMeterValue(FTableFlow.ValueTempertureAfter);
    RemoveMeterValue(FTableFlow.ValueTempertureDelta);
    RemoveMeterValue(FTableFlow.ValueTemperture);
    RemoveMeterValue(FTableFlow.ValuePressureBefore);
    RemoveMeterValue(FTableFlow.ValuePressureAfter);
    RemoveMeterValue(FTableFlow.ValuePressureDelta);
    RemoveMeterValue(FTableFlow.ValuePressure);
    RemoveMeterValue(FTableFlow.ValueDensity);
    RemoveMeterValue(FTableFlow.ValueAirPressure);
    RemoveMeterValue(FTableFlow.ValueAirTemperture);
    RemoveMeterValue(FTableFlow.ValueHumidity);
    RemoveMeterValue(FTableFlow.ValueTime);
    RemoveMeterValue(FTableFlow.ValueQuantity);
    RemoveMeterValue(FTableFlow.ValueFlowRate);
    RemoveMeterValue(FTableFlow.ValueImp);
    RemoveMeterValue(FTableFlow.ValueImpTotal);
    RemoveMeterValue(FTableFlow.ValueCoef);
    RemoveMeterValue(FTableFlow.ValueMassCoef);
    RemoveMeterValue(FTableFlow.ValueVolumeCoef);
    RemoveMeterValue(FTableFlow.ValueMassFlow);
    RemoveMeterValue(FTableFlow.ValueVolumeFlow);
    RemoveMeterValue(FTableFlow.ValueVolume);
    RemoveMeterValue(FTableFlow.ValueMass);
    RemoveMeterValue(FTableFlow.ValueVolumeMeter);
    RemoveMeterValue(FTableFlow.ValueMassMeter);
    RemoveMeterValue(FTableFlow.ValueVolumeError);
    RemoveMeterValue(FTableFlow.ValueMassError);
    RemoveMeterValue(FTableFlow.ValueError);
    RemoveMeterValue(FTableFlow.ValueCurrent);
  end;

  // Установочные значения параметров создаются отдельно от FTableFlow.
  if FFlowRate <> nil then
    RemoveMeterValue(FFlowRate.ValueSet);
  if FFluidTemp <> nil then
    RemoveMeterValue(FFluidTemp.ValueSet);
  if FFluidPress <> nil then
    RemoveMeterValue(FFluidPress.ValueSet);
end;

 procedure TWorkTable.Rebind;
begin
  InitMeterValues;

  RebindAllFlowMeters;
  RecalculateAllMeterValues;
  UpdateAggregateMeterValues;
  UpdateFlowRateLimitsByEtalons;
end;


{
  TODO HYDRAULIC-SCHEME / METROLOGY / CHANNEL STATE:

  Текущая реализация выполняет предварительный fallback-выбор эталонов
  без использования полной гидравлической схемы установки.

  В качестве исходных данных используются:
    - рабочие диапазоны Channel.QMinWork / Channel.QMaxWork;
    - поле Channel.Group;
    - требуемый расход AFlowRate.

  Важно:
    QMinWork, QMaxWork и AFlowRate должны быть выражены в одинаковых
    единицах расхода.

  Алгоритм предварительного выбора:

    1. Сначала каждый корректный эталонный канал рассматривается отдельно,
       независимо от значения Channel.Group.

    2. Если найдено несколько одиночных эталонов, покрывающих требуемый
       расход, выбирается эталон с минимальным QMaxWork.

       Это временная эвристика.

       В будущем выбор одиночного эталона должен быть вынесен в отдельную
       функцию и учитывать метрологические характеристики:
         - погрешность;
         - рабочую точку внутри диапазона;
         - поверочный диапазон;
         - приоритет эталона;
         - техническое состояние;
         - другие метрологические и эксплуатационные параметры.

    3. Если подходящий одиночный эталон не найден, анализируются группы.

    4. Для каждой группы перебираются все непустые комбинации корректных
       каналов группы.

       Для каждой комбинации рассчитывается:
         SumMin = сумма QMinWork выбранных каналов;
         SumMax = сумма QMaxWork выбранных каналов.

       Комбинация считается подходящей, если:
         SumMin <= AFlowRate <= SumMax.

    5. Из подходящих комбинаций выбирается вариант:
         - с минимальным SumMax;
         - при равном SumMax — с меньшим количеством каналов;
         - при остальных равных условиях — с меньшим номером группы.

       Это также временная эвристика до внедрения гидравлической схемы.

    6. Поиск выполняется без изменения Channel.Enabled.

       Текущий набор эталонов изменяется только после того, как подходящий
       одиночный эталон или конкретная комбинация каналов успешно найдены.

    7. При ошибке текущий набор Channel.Enabled остается без изменений.

    8. После успешного поиска:
         - отключаются ранее выбранные эталонные каналы;
         - включаются только каналы найденного варианта;
         - пересчитываются агрегированные значения;
         - в одной общей точке вызывается FireAction(awtSelectEtalons, ...).

  Архитектура уведомлений:

    SelectEtalons выполняет только предварительный выбор.

    После этого обработчик awtSelectEtalons может скорректировать выбранный
    набор на основании гидравлической схемы.

    Вызов FireAction должен быть единой точкой продолжения алгоритма
    независимо от того, был выбран:
      - одиночный эталон;
      - набор эталонов одной группы.

    Отдельный вызов FireEvent(ewtEtalonsChanged, ...) в этой процедуре
    не выполняется.

    Предполагается, что скорректированный TWorkTable.FireAction для действия
    awtSelectEtalons сам формирует окончательное событие ewtEtalonsChanged
    после обработки или подтверждения выбранного набора.

  Ограничение текущей модели:

    Channel.Enabled одновременно используется:
      - как конфигурационный признак доступности канала;
      - как признак выбора эталона для текущего измерения.

    Поскольку Enabled сохраняется вместе с рабочим столом, автоматический
    выбор может случайно стать постоянной настройкой.

    В будущем необходимо разделить:
      Channel.Enabled                — канал разрешен конфигурацией;
      Channel.SelectedForMeasurement — канал выбран для текущей точки.
}
function TWorkTable.SelectEtalons(
  const AFlowRate: Double;
  out AError: TErrorInfo
): Boolean;
const
  // Явная точность сравнения вычисленных суммарных диапазонов.
  //
  // Значение применяется только при сравнении вариантов между собой,
  // а не для искусственного расширения рабочего диапазона эталонов.
  FLOW_COMPARE_EPSILON = 1E-9;

type
  // Список каналов, составляющих один вариант выбора.
  TChannelList = TList<TChannel>;

var
  I: Integer;
  Channel: TChannel;

  // Лучший одиночный эталон, покрывающий требуемый расход.
  BestSingle: TChannel;

  // Конкретный окончательный набор каналов, который будет применен
  // только после успешного завершения поиска.
  SelectedChannels: TChannelList;

  // Словарь групп:
  //   ключ      — Channel.Group;
  //   значение — список корректных каналов данной группы.
  Groups: TObjectDictionary<Integer, TChannelList>;

  GroupChannels: TChannelList;
  GroupPair: TPair<Integer, TChannelList>;

  FlowMin: Double;
  FlowMax: Double;

  // Характеристики лучшей найденной групповой комбинации.
  BestGroupID: Integer;
  BestGroupMax: Double;
  BestGroupCount: Integer;

  SelectionDescription: string;

  procedure SetSelectionError(ACode: Integer; const AMsg: string);
  begin
    // Формируем ошибку на основании текущего состояния рабочего стола.
    //
    // В отличие от локальной фабрики с Stage := 0, здесь в ошибке
    // сохраняется фактическое состояние TWorkTable.
    AError := TErrorInfo.Empty(Integer(FState));
    AError.Code := ACode;
    AError.Msg := AMsg;
    AError.Time := Now;
  end;

  function GetChannelFlowMin(AChannel: TChannel): Double;
  begin
    Result := 0;

    if (AChannel <> nil) and (AChannel.FlowMeter <> nil) then
      Result := AChannel.QMinWork;
  end;

  function GetChannelFlowMax(AChannel: TChannel): Double;
  begin
    Result := 0;

    if (AChannel <> nil) and (AChannel.FlowMeter <> nil) then
      Result := AChannel.QMaxWork;
  end;

  function IsChannelValidForSelection(AChannel: TChannel): Boolean;
  var
    ChannelFlowMin: Double;
    ChannelFlowMax: Double;
  begin
    Result := False;

    // Канал без назначенного расходомера не может участвовать
    // в выборе эталонного набора.
    if (AChannel = nil) or (not AChannel.Enabled) or (AChannel.State = osDeleted) or
       (AChannel.FlowMeter = nil) then
      Exit;

    ChannelFlowMin := GetChannelFlowMin(AChannel);
    ChannelFlowMax := GetChannelFlowMax(AChannel);

    // На текущем этапе оставляем минимальную проверку диапазона:
    // верхняя рабочая граница должна быть положительной.
    //
    // Расширенную проверку NaN, Infinity и согласованности QMin/QMax
    // можно добавить отдельно при ужесточении валидации данных проекта.
    if ChannelFlowMax <= 0 then
      Exit;

    Result := True;
  end;

  procedure CopyChannels(
    const ASource: TChannelList;
    const ADestination: TChannelList
  );
  var
    SourceChannel: TChannel;
  begin
    ADestination.Clear;

    for SourceChannel in ASource do
      ADestination.Add(SourceChannel);
  end;

  procedure ApplySelectedChannels(const AChannels: TChannelList);
  var
    J: Integer;
    SelectedChannel: TChannel;
  begin
    // Этот метод вызывается только после успешного поиска.
    //
    // До этой точки существующий набор Enabled не изменялся,
    // поэтому при любой ошибке старый выбор остается сохранен.

    for J := 0 to FEtalonChannels.Count - 1 do
    begin
      Channel := FEtalonChannels[J];

      if Channel <> nil then
        Channel.Enabled := False;
    end;

    // Включаем только конкретные каналы найденного варианта.
    //
    // Для группового выбора здесь не используется повторная проверка
    // Channel.Group, поэтому случайно не будут включены:
    //   - каналы без FlowMeter;
    //   - каналы с некорректным диапазоном;
    //   - каналы группы, которые не входили в выбранную комбинацию.
    for SelectedChannel in AChannels do
      if SelectedChannel <> nil then
        SelectedChannel.Enabled := True;
  end;

  procedure EvaluateGroupCombination(
    const AGroupID: Integer;
    const ACombination: TChannelList
  );
  var
    CombinationChannel: TChannel;
    SumMin: Double;
    SumMax: Double;
    CombinationCount: Integer;
    IsBetter: Boolean;
  begin
    if ACombination.Count = 0 then
      Exit;

    SumMin := 0;
    SumMax := 0;

    // Рассчитываем общий рабочий диапазон конкретной комбинации
    // параллельно работающих эталонов.
    for CombinationChannel in ACombination do
    begin
      SumMin := SumMin + GetChannelFlowMin(CombinationChannel);
      SumMax := SumMax + GetChannelFlowMax(CombinationChannel);
    end;

    // Требуемый расход должен входить в суммарный диапазон комбинации.
    if (AFlowRate < SumMin) or (AFlowRate > SumMax) then
      Exit;

    CombinationCount := ACombination.Count;

    // Временные правила выбора лучшей комбинации:
    //
    // 1. Первый найденный подходящий вариант.
    // 2. Минимальный суммарный QMax.
    // 3. При равном QMax — меньшее количество каналов.
    // 4. При остальных равных условиях — меньший GroupID.
    IsBetter :=
      (BestGroupID = 0) or

      (SumMax < BestGroupMax - FLOW_COMPARE_EPSILON) or

      (SameValue(SumMax, BestGroupMax, FLOW_COMPARE_EPSILON) and
       (CombinationCount < BestGroupCount)) or

      (SameValue(SumMax, BestGroupMax, FLOW_COMPARE_EPSILON) and
       (CombinationCount = BestGroupCount) and
       (AGroupID < BestGroupID));

    if not IsBetter then
      Exit;

    BestGroupID := AGroupID;
    BestGroupMax := SumMax;
    BestGroupCount := CombinationCount;

    // Сохраняем именно конкретную комбинацию каналов.
    //
    // Это принципиально важно: позднее нельзя просто включить все каналы
    // с тем же Group, поскольку часть из них могла не участвовать
    // в найденном подходящем варианте.
    CopyChannels(ACombination, SelectedChannels);
  end;

  procedure EnumerateGroupCombinations(
    const AGroupID: Integer;
    const AChannels: TChannelList
  );
  var
    CurrentCombination: TChannelList;

    procedure EnumerateFrom(AStartIndex: Integer);
    var
      J: Integer;
    begin
      // Каждая непустая текущая комбинация является отдельным кандидатом.
      if CurrentCombination.Count > 0 then
        EvaluateGroupCombination(AGroupID, CurrentCombination);

      // Рекурсивно формируем все сочетания без повторений.
      //
      // Для каналов A, B, C будут проверены:
      //   A;
      //   A+B;
      //   A+B+C;
      //   A+C;
      //   B;
      //   B+C;
      //   C.
      for J := AStartIndex to AChannels.Count - 1 do
      begin
        CurrentCombination.Add(AChannels[J]);
        try
          EnumerateFrom(J + 1);
        finally
          CurrentCombination.Delete(CurrentCombination.Count - 1);
        end;
      end;
    end;

  begin
    if (AChannels = nil) or (AChannels.Count = 0) then
      Exit;

    CurrentCombination := TChannelList.Create;
    try
      EnumerateFrom(0);
    finally
      CurrentCombination.Free;
    end;
  end;

begin
  // По умолчанию операция считается неуспешной.
  Result := False;

  // Начальное значение ошибки соответствует отсутствию ошибки
  // и содержит текущее состояние рабочего стола.
  AError := TErrorInfo.Empty(Integer(FState));

  BestSingle := nil;
  BestGroupID := 0;
  BestGroupMax := 0;
  BestGroupCount := 0;
  SelectionDescription := '';

  SelectedChannels := TChannelList.Create;

  // TObjectDictionary владеет созданными списками каналов и автоматически
  // освобождает их благодаря doOwnsValues.
  Groups := TObjectDictionary<Integer, TChannelList>.Create([doOwnsValues]);
  try
    // Проверяем наличие коллекции эталонных каналов.
    //
    // При ошибке существующие значения Channel.Enabled не изменяются.
    if (FEtalonChannels = nil) or (FEtalonChannels.Count = 0) then
    begin
      SetSelectionError(
        1101,
        'Список эталонных каналов не создан или пуст'
      );
      Exit;
    end;

    // Неположительный расход не может использоваться для выбора эталона.
    //
    // При ошибке текущий выбранный набор также остается без изменений.
    if AFlowRate <= 0 then
    begin
      SetSelectionError(
        1102,
        Format(
          'Некорректный расход для выбора эталона: %.6f',
          [AFlowRate]
        )
      );
      Exit;
    end;

    // ------------------------------------------------------------
    // ЭТАП 1. ПОИСК ЛУЧШЕГО ОДИНОЧНОГО ЭТАЛОНА
    // ------------------------------------------------------------

    for I := 0 to FEtalonChannels.Count - 1 do
    begin
      Channel := FEtalonChannels[I];

      if not IsChannelValidForSelection(Channel) then
        Continue;

      FlowMin := GetChannelFlowMin(Channel);
      FlowMax := GetChannelFlowMax(Channel);

      // Каждый канал рассматривается как одиночный эталон
      // независимо от значения Channel.Group.
      //
      // Group означает возможность совместной параллельной работы,
      // но не запрещает использовать канал отдельно.
      if (AFlowRate >= FlowMin) and (AFlowRate <= FlowMax) then
      begin
        // Пока используется простая эвристика:
        // выбирается подходящий эталон с минимальным QMaxWork.
        //
        // В будущем это сравнение необходимо заменить вызовом отдельной
        // функции оценки метрологической пригодности эталона.
        if (BestSingle = nil) or
           (FlowMax < GetChannelFlowMax(BestSingle)) then
          BestSingle := Channel;
      end;

      // Одновременно собираем корректные каналы групп.
      //
      // В групповой поиск включаются только те каналы, которые прошли
      // IsChannelValidForSelection.
      if Channel.Group > 0 then
      begin
        if not Groups.TryGetValue(Channel.Group, GroupChannels) then
        begin
          GroupChannels := TChannelList.Create;
          Groups.Add(Channel.Group, GroupChannels);
        end;

        GroupChannels.Add(Channel);
      end;
    end;

    if BestSingle <> nil then
    begin
      // Для одиночного выбора итоговый набор состоит из одного канала.
      SelectedChannels.Add(BestSingle);

      SelectionDescription := Format(
        'Выполнен предварительный выбор одиночного эталона для расхода %.6f',
        [AFlowRate]
      );
    end
    else
    begin
      // ----------------------------------------------------------
      // ЭТАП 2. ПОИСК ЛУЧШЕЙ КОМБИНАЦИИ КАНАЛОВ ВНУТРИ ГРУПП
      // ----------------------------------------------------------

      for GroupPair in Groups do
        EnumerateGroupCombinations(
          GroupPair.Key,
          GroupPair.Value
        );

      if SelectedChannels.Count > 0 then
      begin
        SelectionDescription := Format(
          'Выполнен предварительный выбор группы %d: каналов %d, ' +
          'суммарный QMax %.6f, требуемый расход %.6f',
          [
            BestGroupID,
            BestGroupCount,
            BestGroupMax,
            AFlowRate
          ]
        );
      end;
    end;

    // Если ни одиночный эталон, ни групповая комбинация не найдены,
    // возвращаем ошибку и не меняем текущий набор Enabled.
    if SelectedChannels.Count = 0 then
    begin
      SetSelectionError(
        1103,
        Format(
          'Эталон или комбинация эталонов для расхода %.6f не найдены',
          [AFlowRate]
        )
      );
      Exit;
    end;

    // ------------------------------------------------------------
    // ЭТАП 3. АТОМАРНОЕ ПРИМЕНЕНИЕ НАЙДЕННОГО РЕЗУЛЬТАТА
    // ------------------------------------------------------------

    // Только теперь, после успешного завершения поиска, изменяем
    // Channel.Enabled.
    ApplySelectedChannels(SelectedChannels);

    // Агрегированные параметры рабочего стола должны быть рассчитаны
    // уже по новому предварительно выбранному набору эталонов.
    UpdateAggregateMeterValues;

    // Единая точка продолжения алгоритма для любого способа выбора:
    //   - одиночного эталона;
    //   - комбинации каналов группы.
    //
    // Обработчик awtSelectEtalons может скорректировать предварительный
    // выбор на основании гидравлической схемы.
    //
    // Отдельный FireEvent здесь не вызывается. Предполагается, что
    // FireAction для awtSelectEtalons после обработки формирует
    // ewtEtalonsChanged.
    FireAction(
      awtSelectEtalons,
      'SelectEtalons',
      SelectionDescription
    );

    Result := True;
  finally
    Groups.Free;
    SelectedChannels.Free;
  end;
end;



function TWorkTable.SetEtalonsByNames(const AEtalonNames: TArray<string>;
  out AError: TErrorInfo): Boolean;
var
  I: Integer;
  Channel: TChannel;
  ChannelName: string;
  NeedEnabled: Boolean;
  Changed: Boolean;
  MatchedCount: Integer;

  function BuildWorkTableError(ACode: Integer; const AMsg: string): TErrorInfo;
  begin
    Result.Code := ACode;
    Result.Msg := AMsg;
    Result.Time := Now;
    Result.Stage := 0;
  end;

  function NameInList(const AName: string): Boolean;
  var
    J: Integer;
    Name: string;
  begin
    Result := False;
    Name := Trim(AName);

    if Name = '' then
      Exit;

    for J := Low(AEtalonNames) to High(AEtalonNames) do
      if SameText(Name, Trim(AEtalonNames[J])) then
        Exit(True);
  end;

begin
  Result := False;
  Changed := False;
  MatchedCount := 0;
  AError := TErrorInfo.Empty(0);

  if (FEtalonChannels = nil) or (FEtalonChannels.Count = 0) then
  begin
    AError := BuildWorkTableError(1101, 'Список эталонных каналов не создан или пуст');
    Exit;
  end;

  if Length(AEtalonNames) = 0 then
  begin
    AError := BuildWorkTableError(1102, 'Список имён эталонов для выбора пуст');
    Exit;
  end;

  for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];

    if Channel = nil then
      Continue;

    ChannelName := '';

    if Channel.FlowMeter <> nil then
      ChannelName := Channel.FlowMeter.Name;

    NeedEnabled := NameInList(ChannelName);

    if NeedEnabled then
      Inc(MatchedCount);

    if Channel.Enabled <> NeedEnabled then
    begin
      Channel.Enabled := NeedEnabled;
      Changed := True;
    end;
  end;

  UpdateAggregateMeterValues;

  if MatchedCount = 0 then
  begin
    AError := BuildWorkTableError(1103,
      'В рабочем столе не найдены эталонные каналы по именам из гидросхемы');
    Exit(False);
  end;

  if Changed then
    FireEvent(ewtEtalonsChanged, 'Изменен набор выбранных эталонных каналов');

  Result := True;
end;

{ Rebuilds aggregate lists for table values from enabled etalon channels. }
procedure TWorkTable.UpdateAggregateMeterValues;
var
  I: Integer;
  Channel: TChannel;
  AggregateGroup: Integer;
  ChannelGroup: Integer;
  ChannelFlow: Double;
  GroupFlow: Double;
  MaxGroupFlow: Double;
  GroupFlows: TDictionary<Integer, Double>;
  Pair: TPair<Integer, Double>;
  IsQuantityTemplateSet: Boolean;
  IsFlowTemplateSet: Boolean;
  IsImpTemplateSet: Boolean;
  IsImpTotalTemplateSet: Boolean;

  function GetAggregateGroupKey(const AIndex: Integer; const AChannel: TChannel): Integer;
  begin
    if (AChannel <> nil) and (AChannel.Group >= 0) then
      Result := AChannel.Group
    else
      Result := -AIndex - 1;
  end;
begin
  if FTableFlow.ValueQuantity <> nil then
    FTableFlow.ValueQuantity.ClearMeterValues;
  if FTableFlow.ValueFlowRate <> nil then
    FTableFlow.ValueFlowRate.ClearMeterValues;

  IsQuantityTemplateSet := False;
  IsFlowTemplateSet := False;
  IsImpTemplateSet := False;
  IsImpTotalTemplateSet := False;
  AggregateGroup := 0;
  MaxGroupFlow := -1;

  GroupFlows := TDictionary<Integer, Double>.Create;
  try
    for I := 0 to FEtalonChannels.Count - 1 do
    begin
      Channel := FEtalonChannels[I];
      if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) or
         (Channel.FlowMeter.ValueFlow = nil) then
        Continue;

      ChannelGroup := GetAggregateGroupKey(I, Channel);
      ChannelFlow := Abs(Channel.FlowMeter.ValueFlow.GetDoubleValue);
      if GroupFlows.TryGetValue(ChannelGroup, GroupFlow) then
        GroupFlows[ChannelGroup] := GroupFlow + ChannelFlow
      else
        GroupFlows.Add(ChannelGroup, ChannelFlow);
    end;

    for Pair in GroupFlows do
      if Pair.Value > MaxGroupFlow then
      begin
        MaxGroupFlow := Pair.Value;
        AggregateGroup := Pair.Key;
      end;
  finally
    GroupFlows.Free;
  end;

  if MaxGroupFlow < 0 then
    Exit;

  for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];
    if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
      Continue;

    if GetAggregateGroupKey(I, Channel) <> AggregateGroup then
      Continue;

    if (FTableFlow.ValueQuantity <> nil) and (Channel.FlowMeter.ValueQuantity <> nil) then
    begin
      if not IsQuantityTemplateSet then
      begin
        FTableFlow.ValueQuantity.SetAs(Channel.FlowMeter.ValueQuantity);
        if FQuantityUnitName <> '' then
          FTableFlow.ValueQuantity.SetDim(FQuantityUnitName);
        FTableFlow.ValueQuantity.ValueType := AGGREGATE_TYPE;
        IsQuantityTemplateSet := True;
      end;
      FTableFlow.ValueQuantity.AddMeterValue(Channel.FlowMeter.ValueQuantity);
    end;

    if (FTableFlow.ValueFlowRate <> nil) and (Channel.FlowMeter.ValueFlow <> nil) then
    begin
      if not IsFlowTemplateSet then
      begin
        FTableFlow.ValueFlowRate.SetAs(Channel.FlowMeter.ValueFlow);
        if FFlowUnitName <> '' then
          FTableFlow.ValueFlowRate.SetDim(FFlowUnitName);
        FTableFlow.ValueFlowRate.ValueType := AGGREGATE_TYPE;
        IsFlowTemplateSet := True;
      end;
      FTableFlow.ValueFlowRate.AddMeterValue(Channel.FlowMeter.ValueFlow);
    end;
  end;


 // Агрегация импульсов поверяемых приборов.
// Для стола ValueImp и ValueImpTotal берут минимальное значение
// среди включенных каналов поверяемых приборов.
for I := 0 to FDeviceChannels.Count - 1 do
begin
  Channel := FDeviceChannels[I];

  if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
    Continue;

  if (FTableFlow.ValueImp <> nil) and (Channel.FlowMeter.ValueImp <> nil) then
  begin
    if not IsImpTemplateSet then
    begin
      FTableFlow.ValueImp.SetAs(Channel.FlowMeter.ValueImp);
      FTableFlow.ValueImp.ValueType := AGGREGATEMIN_TYPE;
      IsImpTemplateSet := True;
    end;

    FTableFlow.ValueImp.AddMeterValue(Channel.FlowMeter.ValueImp);
  end;

  if (FTableFlow.ValueImpTotal <> nil) and (Channel.FlowMeter.ValueImpTotal <> nil) then
  begin
    if not IsImpTotalTemplateSet then
    begin
      FTableFlow.ValueImpTotal.SetAs(Channel.FlowMeter.ValueImpTotal);
      FTableFlow.ValueImpTotal.ValueType := AGGREGATEMIN_TYPE;
      IsImpTotalTemplateSet := True;
    end;

    FTableFlow.ValueImpTotal.AddMeterValue(Channel.FlowMeter.ValueImpTotal);
  end;
end;

end;

{ Calculates the greatest supported flow from single etalons and parallel groups. }
function TWorkTable.CalcEtalonFlowRateMax: Double;
var
  I: Integer;
  Channel: TChannel;
  QmaxBase: Double;
  GroupSum: Double;
  GroupSums: TDictionary<Integer, Double>;
  Pair: TPair<Integer, Double>;
begin
  Result := 0;
  if (FEtalonChannels = nil) or (ValueFlowRate = nil) then
    Exit;

  GroupSums := TDictionary<Integer, Double>.Create;
  try
    for I := 0 to FEtalonChannels.Count - 1 do
    begin
      Channel := FEtalonChannels[I];
      if (Channel = nil) or (not Channel.Enabled) or (Channel.State = osDeleted) or
         (Channel.FlowMeter = nil) or (Channel.FlowMeter.Device = nil) then
        Continue;

      QmaxBase := Channel.QMaxWork;
      if QmaxBase <= 0 then
        Continue;

      if Channel.Group > 0 then
      begin
        if GroupSums.TryGetValue(Channel.Group, GroupSum) then
          GroupSums[Channel.Group] := GroupSum + QmaxBase
        else
          GroupSums.Add(Channel.Group, QmaxBase);
      end
      else if QmaxBase > Result then
        Result := QmaxBase;
    end;

    for Pair in GroupSums do
      if Pair.Value > Result then
        Result := Pair.Value;
  finally
    GroupSums.Free;
  end;
end;

{ Calculates the lowest positive Qmin among enabled etalon devices. }
function TWorkTable.CalcEtalonFlowRateMin: Double;
var
  I: Integer;
  Channel: TChannel;
  Device: TDevice;
  QminBase: Double;
  IsFound: Boolean;
begin
  Result := 0;
  IsFound := False;
  if (FEtalonChannels = nil) or (ValueFlowRate = nil) then
    Exit;

  for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];
    if (Channel = nil) or (not Channel.Enabled) or
       (Channel.FlowMeter = nil) or (Channel.FlowMeter.Device = nil) then
      Continue;

    Device := Channel.FlowMeter.Device;
    if Device.Qmin <= 0 then
      Continue;

    QminBase := Device.Qmin;//ValueFlowRate.GetDoubleBaseNum(Device.Qmin,
    //  DEVICE_FLOW_RATE_DIM_INDEX);
    if QminBase <= 0 then
      Continue;

    if (not IsFound) or (QminBase < Result) then
    begin
      Result := QminBase;
      IsFound := True;
    end;
  end;
end;

{ Refreshes flow-rate limits from installed etalons and clamps the current task. }
procedure TWorkTable.UpdateFlowRateLimitsByEtalons;
var
  NewMin: Double;
  NewMax: Double;
  OldMin: Double;
  OldMax: Double;
  OldValueSet: Double;
begin
  if (FlowRate = nil) or (ValueFlowRate = nil) then
    Exit;

  NewMin := 0;
  NewMax := CalcEtalonFlowRateMax;
  OldMin := FlowRate.Min;
  OldMax := FlowRate.Max;
  if FlowRate.ValueSet <> nil then
    OldValueSet := FlowRate.ValueSet.Value
  else
    OldValueSet := 0;

  // Change the opposite boundary first when the old range would reject a valid new one.
  if (NewMin > 0) and (NewMax > 0) and (NewMin <= NewMax) then
  begin
    if NewMin > FlowRate.Max then
      FlowRate.Max := NewMax
    else if NewMax < FlowRate.Min then
      FlowRate.Min := NewMin;
  end;

  if NewMin > 0 then
    FlowRate.Min := NewMin;
  if NewMax > 0 then
    FlowRate.Max := NewMax;

  if FlowRate.ValueSet <> nil then
  begin
    if (FlowRate.Max > 0) and (FlowRate.ValueSet.Value > FlowRate.Max) then
      FlowRate.ValueSet.Value := FlowRate.Max;
    if (FlowRate.Min > 0) and (FlowRate.ValueSet.Value > 0) and
       (FlowRate.ValueSet.Value < FlowRate.Min) then
      FlowRate.ValueSet.Value := FlowRate.Min;
  end;

  if (not SameValue(OldMin, FlowRate.Min)) or
     (not SameValue(OldMax, FlowRate.Max)) or
     ((FlowRate.ValueSet <> nil) and
      (not SameValue(OldValueSet, FlowRate.ValueSet.Value))) then

  //  Notify(notifyEvent, FlowRate);
end;

{ Frees channel collections owned by the work table. }
destructor TWorkTable.Destroy;
begin
  if ProtocolManager <> nil then
    ProtocolManager.AddMessage(pcState, psWorkTable, 'WorkTableDestroy',
      'Удалён рабочий стол', Name);
  UnbindParameterEvents(FFluidTemp);
  UnbindParameterEvents(FFluidPress);
  UnbindParameterEvents(FlowRate);
  if FActivePump <> nil then
    UnbindParameterEvents(FActivePump);
  if FActiveScale <> nil then
    UnbindParameterEvents(FActiveScale);
  ClearPumps;
  ClearScales;
  FParameterObserver := nil;

  FreeAndNil(FMeasurementRun);
  FreeAndNil(FFluidTemp);
  FreeAndNil(FFluidPress);
  FreeAndNil(FlowRate);
  FreeAndNil(FTableFlow);
  FreeAndNil(FSyncSetup);
  FDeviceChannels.Free;
  FEtalonChannels.Free;
  FreeAndNil(FPumps);
  FreeAndNil(FScales);

  if FCurrentPoint<>nil then
  FreeAndNil(FCurrentPoint);

  inherited;
end;

function TWorkTable.GetTemp: Double;
begin
  if FFluidTemp <> nil then
    Result := FFluidTemp.Value.Value
  else
    Result := 0;
end;

function TWorkTable.GetTempDelta: Double;
begin
  if FFluidTemp <> nil then
    Result := FFluidTemp.DeltaValue
  else
    Result := 0;
end;

function TWorkTable.GetPress: Double;
begin
  if FFluidPress <> nil then
    Result := FFluidPress.Value.Value
  else
    Result := 0;
end;

procedure TWorkTable.InitChannels;

  procedure InitChannelList(AChannels: TObjectList<TChannel>);
  var
    I: Integer;
  begin
    if AChannels = nil then
      Exit;

    for I := 0 to AChannels.Count - 1 do
    begin
      if (AChannels[I] <> nil) and Assigned(AChannels[I].FFlowMeter) then
        AChannels[I].FFlowMeter.Init();
    end;
  end;

begin
  InitChannelList(FDeviceChannels);
  InitChannelList(FEtalonChannels);
end;

function TWorkTable.GetPressDelta: Double;
begin
  if FFluidPress <> nil then
    Result := FFluidPress.DeltaValue
  else
    Result := 0;
end;

function TWorkTable.GetTime: Double;
begin
  Result := FTime;
end;

function TWorkTable.GetTimeResult: Double;
begin
  Result := FTimeResult;
end;

procedure TWorkTable.SetTemp(const AValue: Double);
var
  TempBeforeValue: Double;
  TempAfterValue: Double;
begin
  TempBeforeValue := 0;
  TempAfterValue := 0;
  if ValueTempertureBefore <> nil then
    TempBeforeValue := ValueTempertureBefore.GetDoubleValue;
  if ValueTempertureAfter <> nil then
    TempAfterValue := ValueTempertureAfter.GetDoubleValue;
  SetTemperature(TempBeforeValue, TempAfterValue);
end;

procedure TWorkTable.SetTempDelta(const AValue: Double);
begin
  if FFluidTemp <> nil then
    FFluidTemp.DeltaValue := AValue;
end;


procedure TWorkTable.SetPressDelta(const AValue: Double);
begin
  if FFluidPress <> nil then
    FFluidPress.DeltaValue := AValue;
end;

procedure TWorkTable.SetTime(const AValue: Double);
begin
  FTime := AValue;
end;

procedure TWorkTable.SetTimeResult(const AValue: Double);
begin
  FTimeResult := AValue;
end;

procedure TWorkTable.SetTemperature(ATempBefore, ATempAfter: Double);
begin
  // При удалении/переключении рабочего стола параметры могут быть уже освобождены.
  if FFluidTemp = nil then
    Exit;

  if (ATempBefore = 0)  then
    FFluidTemp.BeforeValue:= ATempAfter ;
  if ATempAfter = 0 then
    FFluidTemp.AfterValue:= ATempBefore ;

end;

procedure TWorkTable.SetPressure( APressBefore, APressAfter: Double);

begin
  // Не обращаемся к параметру давления, если рабочий стол уже очищается.
  if FFluidPress = nil then
    Exit;

  if (APressBefore = 0)  then
    FFluidPress.BeforeValue:= APressAfter ;
  if APressAfter = 0 then
    FFluidPress.AfterValue:= APressBefore ;

end;

procedure TWorkTable.SetFlowRateMin(const AValue: Double);
var
  AValueBase: Double;
begin
  if (FlowRate = nil) or (ValueFlowRate = nil) then
    Exit;

  AValueBase := ValueFlowRate.GetDoubleNum(AValue);
  if AValueBase > FlowRate.Max then
    Exit;

  FlowRate.Min := AValueBase;
end;


procedure TWorkTable.SetFlowRateMax(const AValue: Double);
var
  AValueBase: Double;
begin
  if (FlowRate = nil) or (ValueFlowRate = nil) then
    Exit;

  AValueBase := ValueFlowRate.GetDoubleNum(AValue);
  if AValueBase < FlowRate.Min then
    Exit;

  FlowRate.Max := AValueBase;
end;

procedure TWorkTable.SetPressureMin(const AValue: Double);
var
  AValueBase: Double;
begin
  if (FluidPress = nil) or (ValuePressure = nil) then
    Exit;

  AValueBase := ValuePressure.GetDoubleNum(AValue);
  if AValueBase > FluidPress.Max then
    Exit;

  FluidPress.Min := AValueBase;
end;

procedure TWorkTable.SetPressureMax(const AValue: Double);
var
  AValueBase: Double;
begin
  if (FluidPress = nil) or (ValuePressure = nil) then
    Exit;

  AValueBase := ValuePressure.GetDoubleNum(AValue);
  if AValueBase < FluidPress.Min then
    Exit;

  FluidPress.Max := AValueBase;
end;


{ Adds a new device channel with default identifiers and bindings. }
function TWorkTable.AddDeviceChannel: TChannel;
var
  ChannelIndex: Integer;
begin
  ChannelIndex := FDeviceChannels.Count + 1;
  Result := TChannel.Create;
  Result.ID := ChannelIndex;
  Result.Name := BuildDeviceChannelServiceName(ChannelIndex);
  Result.Text := BuildChannelDefaultText(ChannelIndex);
  Result.WorkTabeID := Self.ID;
  FDeviceChannels.Add(Result);
  Result.RebindFlowMeterValues(Self);
  if (Result.FlowMeter <> nil) and (FTableFlow <> nil) then
    Result.FlowMeter.SetEtalon(FTableFlow);
end;

function TWorkTable.AddDeviceChannel(const AName: string): TChannel;
begin
  Result:= AddDeviceChannel;
  Result.Name := AName;
end;

{ Adds and configures a new device channel from provided parameters. }
function TWorkTable.AddDeviceChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
  ATypeName, ASerial, ADeviceUUID: string): TChannel;
begin
  Result := AddDeviceChannel;
  Result.Enabled := AEnabled;
  Result.Text := AName;
  Result.TypeName := ATypeName;
  Result.Serial := ASerial;
  Result.Signal := ASignal;
  Result.DeviceUUID := ADeviceUUID;
  Result.Init;
  Result.InitMeterValues;
  Result.RebindFlowMeterValues(Self);
end;

{ Adds a new etalon channel with default identifiers and bindings. }
function TWorkTable.AddEtalonChannel: TChannel;
var
  ChannelIndex: Integer;
begin
  ChannelIndex := FEtalonChannels.Count + 1;
  Result := TChannel.Create;
  Result.ID := ChannelIndex;
  Result.Name := BuildEtalonChannelServiceName(ChannelIndex);
  Result.Text := BuildChannelDefaultText(ChannelIndex);
  Result.WorkTabeID := Self.ID;
  FEtalonChannels.Add(Result);
  Result.RebindFlowMeterValues(Self);
end;

{ Rebinds all device and etalon flow meters to this work table values. }
procedure TWorkTable.RebindAllFlowMeters;
var
  I: Integer;

  function IsVolumeFlowUnitName(const AUnitName: string): Boolean;
  begin
    Result := SameText(AUnitName, 'л/с') or
              SameText(AUnitName, 'л/мин') or
              SameText(AUnitName, 'л/ч') or
              SameText(AUnitName, 'м3/мин') or
              SameText(AUnitName, 'м3/ч');
  end;

  procedure ApplySelectedUnitsToChannel(AChannel: TChannel);
  var
    Meter: TFlowMeter;
  begin
    if (AChannel = nil) or (AChannel.FlowMeter = nil) or (FFlowUnitName = '') then
      Exit;

    Meter := AChannel.FlowMeter;
    if IsVolumeFlowUnitName(FFlowUnitName) then
    begin
      Meter.ValueQuantity := Meter.ValueVolume;
      Meter.ValueFlow := Meter.ValueVolumeFlow;
      if (Meter.ValueVolume <> nil) and (FQuantityUnitName <> '') then
        Meter.ValueVolume.SetDim(FQuantityUnitName);
      if Meter.ValueVolumeFlow <> nil then
        Meter.ValueVolumeFlow.SetDim(FFlowUnitName);
    end
    else
    begin
      Meter.ValueQuantity := Meter.ValueMass;
      Meter.ValueFlow := Meter.ValueMassFlow;
      if (Meter.ValueMass <> nil) and (FQuantityUnitName <> '') then
        Meter.ValueMass.SetDim(FQuantityUnitName);
      if Meter.ValueMassFlow <> nil then
        Meter.ValueMassFlow.SetDim(FFlowUnitName);
    end;
  end;

begin
  for I := 0 to FDeviceChannels.Count - 1 do
  begin
    FDeviceChannels[I].RebindFlowMeterValues(Self);
    ApplySelectedUnitsToChannel(FDeviceChannels[I]);
  end;

   for I := 0 to FEtalonChannels.Count - 1 do
   begin
    FEtalonChannels[I].RebindFlowMeterValues(Self);
    ApplySelectedUnitsToChannel(FEtalonChannels[I]);
   end;

  UpdateAggregateMeterValues;
  UpdateFlowRateLimitsByEtalons;
  AssignTableFlowAsEtalonToDevices;
end;

procedure TWorkTable.SetValues;

begin

if FTableFlow<>nil then

    begin
      if FTableFlow.ValueDensity <> nil then FTableFlow.ValueDensity.SetValue();
      if FTableFlow.ValueTime <> nil then FTableFlow.ValueTime.SetValue();
      if FTableFlow.ValueQuantity <> nil then FTableFlow.ValueQuantity.SetValue();
      if FTableFlow.ValueFlowRate <> nil then FTableFlow.ValueFlowRate.SetValue();


      if FTableFlow.ValueTemperture <> nil then FTableFlow.ValueTemperture.SetValue();
      if FTableFlow.ValuePressure <> nil then FTableFlow.ValuePressure.SetValue();
    end
end;


{ Triggers recalculation/update pass for work table and channel meter values. }
procedure TWorkTable.RecalculateAllMeterValues;
var
  I: Integer;
  Channel: TChannel;
begin
   for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];
    if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
      Continue;

    Channel.SetValues;

  end;

  UpdateAggregateMeterValues;

      Self.SetValues;

     for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];
    if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
      Continue;
    if Channel.FlowMeter.ValueError <> nil then Channel.FlowMeter.ValueError.SetValue();
  end;


  for I := 0 to FDeviceChannels.Count - 1 do
  begin
    Channel := FDeviceChannels[I];
    if (Channel = nil) or (Channel.FlowMeter = nil) then
      Continue;

    Channel.SetValues;
  end;


end;

{ Adds and configures a new etalon channel from provided parameters. }
function TWorkTable.AddEtalonChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
  ATypeName, ASerial, ADeviceUUID: string): TChannel;
begin
  Result := AddEtalonChannel;
  Result.Enabled := AEnabled;
  Result.Text := AName;
  Result.TypeName := ATypeName;
  Result.Serial := ASerial;
  Result.Signal := ASignal;
  Result.DeviceUUID := ADeviceUUID;
  Result.Init;
  Result.InitMeterValues;
  Result.RebindFlowMeterValues(Self);
  UpdateAggregateMeterValues;
  UpdateFlowRateLimitsByEtalons;
end;

{ Saves work table list, channels, and meter values to INI files. }
class procedure TWorkTable.Save(const AIniFileName: string;
  AWorkTables: TObjectList<TWorkTable>);
var
  Ini: TMemIniFile;
  ValuesIni: TMemIniFile;
  I: Integer;
  WorkTable: TWorkTable;
  Section: string;
  WorkTableValuesFileName: string;

  procedure ClearOldWorkTableSections(AIni: TMemIniFile);
  var
    Sections: TStringList;
    J: Integer;
    SectionName: string;
  begin
    if AIni = nil then
      Exit;

    Sections := TStringList.Create;
    try
      AIni.ReadSections(Sections);

      for J := Sections.Count - 1 downto 0 do
      begin
        SectionName := Trim(Sections[J]);

        if StartsText('WorkTable.', SectionName) or
           (StartsText('WorkTable_', SectionName) and EndsText('_Sync', SectionName)) then
          AIni.EraseSection(SectionName);
      end;
    finally
      Sections.Free;
    end;
  end;
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  Ini := TMemIniFile.Create(AIniFileName);
  WorkTableValuesFileName := IncludeTrailingPathDelimiter(ExtractFilePath(AIniFileName)) + 'WorkTableValues.ini';
  ValuesIni := TMemIniFile.Create(WorkTableValuesFileName);
  try
    ClearOldWorkTableSections(Ini);
    ClearOldWorkTableSections(ValuesIni);

    Ini.WriteInteger('WorkTables', 'Count', AWorkTables.Count);

     if ValuesIni.ReadFloat('Common', 'InitDensity', 0) = 0 then
          ValuesIni.WriteFloat('Common', 'InitDensity', 0.9982);

    for I := 0 to AWorkTables.Count - 1 do
    begin
      WorkTable := AWorkTables[I];
      Section := 'WorkTable.' + IntToStr(I);


      Ini.WriteInteger(Section, 'ID', WorkTable.ID);
      Ini.WriteString(Section, 'UUID', WorkTable.UUID);
      Ini.WriteString(Section, 'Name', WorkTable.Name);
      Ini.WriteString(Section, 'Text', WorkTable.Text);
      Ini.WriteFloat(Section, 'Temp', WorkTable.FluidTemp.Value.Value);
      Ini.WriteFloat(Section, 'TempDelta', WorkTable.TempDelta);
     // Ini.WriteFloat(Section, 'Press', WorkTable.Press);
      Ini.WriteFloat(Section, 'PressDelta', WorkTable.PressDelta);
      Ini.WriteFloat(Section, 'FlowRate', WorkTable.FlowRate.Value.Value);
      Ini.WriteFloat(Section, 'PressureMin', WorkTable.FluidPress.Min);
      Ini.WriteFloat(Section, 'PressureMax', WorkTable.FluidPress.Max);
      Ini.WriteFloat(Section, 'TempMin', WorkTable.FluidTemp.Min);
      Ini.WriteFloat(Section, 'TempMax', WorkTable.FluidTemp.Max);
      Ini.WriteFloat(Section, 'FlowRateMin', WorkTable.FlowRate.Min);
      Ini.WriteFloat(Section, 'FlowRateMax', WorkTable.FlowRate.Max);
      Ini.WriteFloat(Section, 'QuantityMin', WorkTable.TableFlow.QuantityMin);
      Ini.WriteFloat(Section, 'QuantityMax', WorkTable.TableFlow.QuantityMax);
      Ini.WriteFloat(Section, 'Time', WorkTable.Time);
      Ini.WriteFloat(Section, 'TimeResult', WorkTable.TimeResult);
      Ini.WriteFloat(Section, 'CurrentWeight', WorkTable.CurrentWeight);
      Ini.WriteFloat(Section, 'ScaleTareWeight', WorkTable.ScaleTareWeight);
      if WorkTable.ActiveScale <> nil then
        Ini.WriteString(Section, 'ActiveScaleUUID', WorkTable.ActiveScale.UUID)
      else
        Ini.WriteString(Section, 'ActiveScaleUUID', '');
      if WorkTable.CurrentPoint <> nil then
      begin
        Ini.WriteInteger(Section, 'TimeSet', Round(WorkTable.CurrentPoint.LimitTime));
        Ini.WriteInteger(Section, 'LimitImpSet', WorkTable.CurrentPoint.LimitImp);
        Ini.WriteFloat(Section, 'LimitVolumeSet', WorkTable.CurrentPoint.LimitVolume);
        Ini.WriteInteger(Section, 'StopCriteria', CriteriaToInt(WorkTable.CurrentPoint.StopCriteria));
      end
      else
      begin
        Ini.WriteInteger(Section, 'TimeSet', -1);
        Ini.WriteInteger(Section, 'LimitImpSet', -1);
        Ini.WriteFloat(Section, 'LimitVolumeSet', -1);
        Ini.WriteInteger(Section, 'StopCriteria', 0);
      end;
      Ini.WriteString(Section, 'Status', WorkTableStateToString(WorkTable.State));
      Ini.WriteString(Section, 'MeasurementState', WorkTableStateToString(WorkTable.State));
      Ini.WriteBool(Section, 'TableClamped', WorkTable.TableClamped);
      Ini.WriteString(Section, 'FlowUnitName', WorkTable.FlowUnitName);
      Ini.WriteString(Section, 'QuantityUnitName', WorkTable.QuantityUnitName);
      Ini.WriteBool(Section, 'LayoutFlowRateVisible', WorkTable.LayoutFlowRateVisible);
      Ini.WriteBool(Section, 'LayoutPumpVisible', WorkTable.LayoutPumpVisible);
      Ini.WriteBool(Section, 'LayoutMainVisible', WorkTable.LayoutMainVisible);
      Ini.WriteBool(Section, 'LayoutMesureVisible', WorkTable.LayoutMesureVisible);
      Ini.WriteBool(Section, 'LayoutConditionsVisible', WorkTable.LayoutConditionsVisible);
      Ini.WriteBool(Section, 'LayoutProceduresVisible', WorkTable.LayoutProceduresVisible);
      Ini.WriteString(Section, 'InstrumentalLayoutOrder', WorkTable.InstrumentalLayoutOrder);

      ValuesIni.WriteString(Section, 'HashValueTempertureBefore', WorkTable.ValueTempertureBefore.Hash);
      ValuesIni.WriteString(Section, 'HashValueTempertureAfter', WorkTable.ValueTempertureAfter.Hash);
      ValuesIni.WriteString(Section, 'HashValueTempertureDelta', WorkTable.ValueTempertureDelta.Hash);
      ValuesIni.WriteString(Section, 'HashValueTemperture', WorkTable.ValueTemperture.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressureBefore', WorkTable.ValuePressureBefore.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressureAfter', WorkTable.ValuePressureAfter.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressureDelta', WorkTable.ValuePressureDelta.Hash);
      ValuesIni.WriteString(Section, 'HashValuePressure', WorkTable.ValuePressure.Hash);
      ValuesIni.WriteString(Section, 'HashValueDensity', WorkTable.ValueDensity.Hash);
      ValuesIni.WriteString(Section, 'HashValueAirPressure', WorkTable.ValueAirPressure.Hash);
      ValuesIni.WriteString(Section, 'HashValueAirTemperture', WorkTable.ValueAirTemperture.Hash);
      ValuesIni.WriteString(Section, 'HashValueHumidity', WorkTable.ValueHumidity.Hash);
      ValuesIni.WriteString(Section, 'HashValueTime', WorkTable.ValueTime.Hash);
      ValuesIni.WriteString(Section, 'HashValueQuantity', WorkTable.ValueQuantity.Hash);
      ValuesIni.WriteString(Section, 'HashValueFlowRate', WorkTable.ValueFlowRate.Hash);

      ValuesIni.WriteFloat(Section, 'ValueTempertureBefore', WorkTable.ValueTempertureBefore.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueTempertureAfter', WorkTable.ValueTempertureAfter.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueTempertureDelta', WorkTable.ValueTempertureDelta.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueTemperture', WorkTable.ValueTemperture.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressureBefore', WorkTable.ValuePressureBefore.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressureAfter', WorkTable.ValuePressureAfter.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressureDelta', WorkTable.ValuePressureDelta.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValuePressure', WorkTable.ValuePressure.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueDensity', WorkTable.ValueDensity.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueAirPressure', WorkTable.ValueAirPressure.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueAirTemperture', WorkTable.ValueAirTemperture.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueHumidity', WorkTable.ValueHumidity.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueTime', WorkTable.ValueTime.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueQuantity', WorkTable.ValueQuantity.GetDoubleValue);
      ValuesIni.WriteFloat(Section, 'ValueFlowRate', WorkTable.ValueFlowRate.GetDoubleValue);

      SaveScaleList(Ini, Section + '.Scales', WorkTable.Weights);
      SaveChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      SaveChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);
      SaveGridColumns(Ini, Section + '.EtalonGrid', WorkTable.EtalonsGridColumns);
      SaveGridColumns(Ini, Section + '.DeviceGrid', WorkTable.DevicesGridColumns);
      SaveGridColumns(Ini, Section + '.DataPointsGrid', WorkTable.DataPointsGridColumns);
      SaveGridColumns(Ini, Section + '.ResultsGrid', WorkTable.ResultsGridColumns);
      WorkTable.SyncSetup.SaveToIni(Ini, 'WorkTable_' + WorkTable.UUID);
    end;
    Ini.UpdateFile;
    ValuesIni.UpdateFile;
  finally
    ValuesIni.Free;
    Ini.Free;
  end;
end;

{ Loads work table list, channels, and meter values from INI files. }
class procedure TWorkTable.Load(const AIniFileName: string;
  AWorkTables: TObjectList<TWorkTable>);
var
  Ini: TIniFile;
  ValuesIni: TIniFile;
  Count, I: Integer;
  WorkTable: TWorkTable;
  Section: string;
  WorkTableValuesFileName: string;
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  if not FileExists(AIniFileName) then
    Exit;

  AWorkTables.Clear;
  if TWeight.Weights <> nil then
    TWeight.Weights.Clear;

  Ini := TIniFile.Create(AIniFileName);
  WorkTableValuesFileName := IncludeTrailingPathDelimiter(ExtractFilePath(AIniFileName)) + 'WorkTableValues.ini';
  ValuesIni := TIniFile.Create(WorkTableValuesFileName);
  try
    Count := Ini.ReadInteger('WorkTables', 'Count', 0);
    TMeterValue.SetInitDensity(S2F(ValuesIni.ReadString('Common', 'InitDensity', FloatToStr(TMeterValue.GetInitDensity))));

    for I := 0 to Count - 1 do
    begin
      Section := 'WorkTable.' + IntToStr(I);
      WorkTable := TWorkTable.Create;

      WorkTable.ID := Ini.ReadInteger(Section, 'ID', I + 1);
      WorkTable.UUID := Ini.ReadString(Section, 'UUID', WorkTable.UUID);
      if Trim(WorkTable.UUID) = '' then
        WorkTable.UUID := TGUID.NewGuid.ToString;
      WorkTable.SyncSetup.LoadFromIni(Ini, 'WorkTable_' + WorkTable.UUID);
      WorkTable.Name := Ini.ReadString(Section, 'Name','0'); //BuildWorkTableServiceName(WorkTable.ID);
      WorkTable.Text := Ini.ReadString(Section, 'Text', 'Рабочий стол ' + IntToStr(WorkTable.ID));
      if Trim(WorkTable.Text) = '' then
        WorkTable.Text := 'Рабочий стол ' + IntToStr(WorkTable.ID);
      //WorkTable.FluidTemp.Value.Value := S2F(Ini.ReadString(Section, 'Temp', '0'));
      WorkTable.TempDelta := S2F(Ini.ReadString(Section, 'TempDelta','0'));
      //WorkTable.Press := Ini.ReadFloat(Section, 'Press', 0);
      WorkTable.PressDelta := S2F(Ini.ReadString(Section, 'PressDelta','0'));
     // WorkTable.FlowRate.Value.Value := S2F(Ini.ReadString(Section, 'FlowRate', '0'));
      WorkTable.FluidPress.Min := S2F(Ini.ReadString(Section, 'PressureMin', FloatToStr(WorkTable.FluidPress.Min)));
      WorkTable.FluidPress.Max := S2F(Ini.ReadString(Section, 'PressureMax', FloatToStr(WorkTable.FluidPress.Max)));
      WorkTable.FluidTemp.Min := S2F(Ini.ReadString(Section, 'TempMin', FloatToStr(WorkTable.FluidTemp.Min)));
      WorkTable.FluidTemp.Max := S2F(Ini.ReadString(Section, 'TempMax', FloatToStr(WorkTable.FluidTemp.Max)));
      WorkTable.FlowRate.Min := S2F(Ini.ReadString(Section, 'FlowRateMin', FloatToStr(WorkTable.FlowRate.Min)));
      WorkTable.FlowRate.Max := S2F(Ini.ReadString(Section, 'FlowRateMax', FloatToStr(WorkTable.FlowRate.Max)));
      WorkTable.TableFlow.QuantityMin := S2F(Ini.ReadString(Section, 'QuantityMin', FloatToStr(WorkTable.TableFlow.QuantityMin)));
      WorkTable.TableFlow.QuantityMax := S2F(Ini.ReadString(Section, 'QuantityMax', FloatToStr(WorkTable.TableFlow.QuantityMax)));
      WorkTable.Time := S2F(Ini.ReadString(Section, 'Time', '0'));
      WorkTable.TimeResult := S2F(Ini.ReadString(Section, 'TimeResult', '0'));
      WorkTable.CurrentWeight := S2F(Ini.ReadString(Section, 'CurrentWeight', '0'));
      WorkTable.ScaleTareWeight := S2F(Ini.ReadString(Section, 'ScaleTareWeight', '0'));
      if WorkTable.CurrentPoint <> nil then
      begin
        WorkTable.CurrentPoint.LimitTime := Ini.ReadInteger(Section, 'TimeSet', -1);
        WorkTable.CurrentPoint.LimitImp := Ini.ReadInteger(Section, 'LimitImpSet', -1);
        WorkTable.CurrentPoint.LimitVolume := S2F(Ini.ReadString(Section, 'LimitVolumeSet', '-1'));

        if Ini.ValueExists(Section, 'StopCriteria') then
          WorkTable.CurrentPoint.StopCriteria :=
            IntToCriteria(Ini.ReadInteger(Section, 'StopCriteria', 0))
        else
        begin
          WorkTable.CurrentPoint.StopCriteria := [];

          if WorkTable.CurrentPoint.LimitTime > 0 then
            WorkTable.CurrentPoint.StopCriteria :=
              WorkTable.CurrentPoint.StopCriteria + [scTime];

          if WorkTable.CurrentPoint.LimitImp > 0 then
            WorkTable.CurrentPoint.StopCriteria :=
              WorkTable.CurrentPoint.StopCriteria + [scImpulse];

          if WorkTable.CurrentPoint.LimitVolume > 0 then
            WorkTable.CurrentPoint.StopCriteria :=
              WorkTable.CurrentPoint.StopCriteria + [scVolume];
        end;
      end;
       //Нет смысла восстанавливать состояние
     { WorkTable.State := WorkTableStateFromString(
        Ini.ReadString(Section, 'Status',
          Ini.ReadString(Section, 'MeasurementState', 'swtNONE'))
      );   }
      WorkTable.TableClamped := Ini.ReadBool(Section, 'TableClamped', False);
      WorkTable.FlowUnitName := Trim(Ini.ReadString(Section, 'FlowUnitName', WorkTable.FlowUnitName));
      WorkTable.QuantityUnitName := Trim(Ini.ReadString(Section, 'QuantityUnitName', WorkTable.QuantityUnitName));
      WorkTable.LayoutFlowRateVisible := Ini.ReadBool(Section, 'LayoutFlowRateVisible', True);
      WorkTable.LayoutPumpVisible := Ini.ReadBool(Section, 'LayoutPumpVisible', True);
      WorkTable.LayoutMainVisible := Ini.ReadBool(Section, 'LayoutMainVisible', True);
      WorkTable.LayoutMesureVisible := Ini.ReadBool(Section, 'LayoutMesureVisible', True);
      WorkTable.LayoutConditionsVisible := Ini.ReadBool(Section, 'LayoutConditionsVisible', True);
      WorkTable.LayoutProceduresVisible := Ini.ReadBool(Section, 'LayoutProceduresVisible', True);
      WorkTable.InstrumentalLayoutOrder := Ini.ReadString(Section, 'InstrumentalLayoutOrder',
        'FlowRate,Pump,Main,Mesure,Conditions,Procedures');

      WorkTable.FHashValueTempertureBefore := ValuesIni.ReadString(Section, 'HashValueTempertureBefore', WorkTable.FHashValueTempertureBefore);
      WorkTable.FHashValueTempertureAfter := ValuesIni.ReadString(Section, 'HashValueTempertureAfter', WorkTable.FHashValueTempertureAfter);
      WorkTable.FHashValueTempertureDelta := ValuesIni.ReadString(Section, 'HashValueTempertureDelta', WorkTable.FHashValueTempertureDelta);
      WorkTable.FHashValueTemperture := ValuesIni.ReadString(Section, 'HashValueTemperture', WorkTable.FHashValueTemperture);
      WorkTable.FHashValuePressureBefore := ValuesIni.ReadString(Section, 'HashValuePressureBefore', WorkTable.FHashValuePressureBefore);
      WorkTable.FHashValuePressureAfter := ValuesIni.ReadString(Section, 'HashValuePressureAfter', WorkTable.FHashValuePressureAfter);
      WorkTable.FHashValuePressureDelta := ValuesIni.ReadString(Section, 'HashValuePressureDelta', WorkTable.FHashValuePressureDelta);
      WorkTable.FHashValuePressure := ValuesIni.ReadString(Section, 'HashValuePressure', WorkTable.FHashValuePressure);
      WorkTable.FHashValueDensity := ValuesIni.ReadString(Section, 'HashValueDensity', WorkTable.FHashValueDensity);
      WorkTable.FHashValueAirPressure := ValuesIni.ReadString(Section, 'HashValueAirPressure', WorkTable.FHashValueAirPressure);
      WorkTable.FHashValueAirTemperture := ValuesIni.ReadString(Section, 'HashValueAirTemperture', WorkTable.FHashValueAirTemperture);
      WorkTable.FHashValueHumidity := ValuesIni.ReadString(Section, 'HashValueHumidity', WorkTable.FHashValueHumidity);
      WorkTable.FHashValueTime := ValuesIni.ReadString(Section, 'HashValueTime', WorkTable.FHashValueTime);
      WorkTable.FHashValueQuantity := ValuesIni.ReadString(Section, 'HashValueQuantity', WorkTable.FHashValueQuantity);
      WorkTable.FHashValueFlowRate := ValuesIni.ReadString(Section, 'HashValueFlowRate', WorkTable.FHashValueFlowRate);

      if WorkTable.FTableFlow.ValueTempertureBefore <> nil then WorkTable.FTableFlow.ValueTempertureBefore.DeleteFromVector;
      if WorkTable.FTableFlow.ValueTempertureAfter <> nil then WorkTable.FTableFlow.ValueTempertureAfter.DeleteFromVector;
      if WorkTable.FTableFlow.ValueTempertureDelta <> nil then WorkTable.FTableFlow.ValueTempertureDelta.DeleteFromVector;
      if WorkTable.FTableFlow.ValueTemperture <> nil then WorkTable.FTableFlow.ValueTemperture.DeleteFromVector;
      if WorkTable.FTableFlow.ValuePressureBefore <> nil then WorkTable.FTableFlow.ValuePressureBefore.DeleteFromVector;
      if WorkTable.FTableFlow.ValuePressureAfter <> nil then WorkTable.FTableFlow.ValuePressureAfter.DeleteFromVector;
      if WorkTable.FTableFlow.ValuePressureDelta <> nil then WorkTable.FTableFlow.ValuePressureDelta.DeleteFromVector;
      if WorkTable.FTableFlow.ValuePressure <> nil then WorkTable.FTableFlow.ValuePressure.DeleteFromVector;
      if WorkTable.FTableFlow.ValueAirPressure <> nil then WorkTable.FTableFlow.ValueAirPressure.DeleteFromVector;
      if WorkTable.FTableFlow.ValueAirTemperture <> nil then WorkTable.FTableFlow.ValueAirTemperture.DeleteFromVector;
      if WorkTable.FTableFlow.ValueHumidity <> nil then WorkTable.FTableFlow.ValueHumidity.DeleteFromVector;
      if WorkTable.FTableFlow.ValueTime <> nil then WorkTable.FTableFlow.ValueTime.DeleteFromVector;
      if WorkTable.FTableFlow.ValueQuantity <> nil then WorkTable.FTableFlow.ValueQuantity.DeleteFromVector;
      if WorkTable.FTableFlow.ValueFlowRate <> nil then WorkTable.FTableFlow.ValueFlowRate.DeleteFromVector;

      WorkTable.InitMeterValues;

      WorkTable.ValueTempertureBefore.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueTempertureBefore', '21')));
      WorkTable.ValueTempertureAfter.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueTempertureAfter', '21')));
      WorkTable.ValueTempertureDelta.SetValue(S2F(ValuesIni.ReadString(Section,'ValueTempertureDelta', '0')));
      WorkTable.ValueTemperture.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueTemperture', '21')));
      WorkTable.ValuePressureBefore.SetValue(S2F(ValuesIni.ReadString(Section, 'ValuePressureBefore', '0')));
      WorkTable.ValuePressureAfter.SetValue(S2F(ValuesIni.ReadString(Section, 'ValuePressureAfter', '0')));
      WorkTable.ValuePressureDelta.SetValue(S2F(ValuesIni.ReadString(Section, 'ValuePressureDelta', '0')));
      WorkTable.ValuePressure.SetValue(S2F(ValuesIni.ReadString(Section, 'ValuePressure', '0')));
      WorkTable.ValueDensity.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueDensity', FloatToStr(TMeterValue.GetInitDensity))));
      WorkTable.ValueAirPressure.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueAirPressure', '0')));
      WorkTable.ValueAirTemperture.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueAirTemperture', '0')));
      WorkTable.ValueHumidity.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueHumidity', '0')));
      WorkTable.ValueTime.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueTime', '0')));
      WorkTable.ValueQuantity.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueQuantity', '0')));
      WorkTable.ValueFlowRate.SetValue(S2F(ValuesIni.ReadString(Section, 'ValueFlowRate', '0')));

      WorkTable.ValueTempertureBefore.SetValue(21);
      WorkTable.ValueTempertureAfter.SetValue(21);

      WorkTable.FluidTemp.Value.Value := 21;

      LoadScaleList(Ini, Section + '.Scales', WorkTable.Weights);
      WorkTable.ActiveScale := WorkTable.FindScaleByUUID(Ini.ReadString(Section, 'ActiveScaleUUID', ''));
      LoadChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels, WorkTable.ID);
      LoadChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels, WorkTable.ID);
      LoadGridColumns(Ini, Section + '.EtalonGrid', WorkTable.FEtalonsGridColumns);
      LoadGridColumns(Ini, Section + '.DeviceGrid', WorkTable.FDevicesGridColumns);
      LoadGridColumns(Ini, Section + '.DataPointsGrid', WorkTable.FDataPointsGridColumns);
      LoadGridColumns(Ini, Section + '.ResultsGrid', WorkTable.FResultsGridColumns);

      WorkTable.RebindAllFlowMeters;
      WorkTable.RecalculateAllMeterValues;
      WorkTable.UpdateAggregateMeterValues;
      WorkTable.UpdateFlowRateLimitsByEtalons;

      AWorkTables.Add(WorkTable);
    end;
  finally
    ValuesIni.Free;
    Ini.Free;
  end;
end;

class procedure TWorkTable.SaveGridColumns(AIni: TCustomIniFile;
  const ASectionPrefix: string; const AColumns: TArray<TGridColumnLayout>);
var
  I, OldCount: Integer;
  Section: string;
begin
  if AIni = nil then
    Exit;

  OldCount := AIni.ReadInteger(ASectionPrefix, 'Count', 0);
  AIni.WriteInteger(ASectionPrefix, 'Count', Length(AColumns));

  for I := Length(AColumns) to OldCount - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);
    AIni.EraseSection(Section);
  end;

  for I := 0 to High(AColumns) do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);
    AIni.WriteString(Section, 'Name', AColumns[I].Name);
    AIni.WriteInteger(Section, 'DisplayIndex', AColumns[I].DisplayIndex);
    AIni.WriteFloat(Section, 'Width', AColumns[I].Width);
    AIni.WriteBool(Section, 'Visible', AColumns[I].Visible);
  end;
end;

class procedure TWorkTable.LoadGridColumns(AIni: TCustomIniFile;
  const ASectionPrefix: string; out AColumns: TArray<TGridColumnLayout>);
var
  I, Count: Integer;
  Section: string;
begin
  SetLength(AColumns, 0);
  if AIni = nil then
    Exit;

  Count := AIni.ReadInteger(ASectionPrefix, 'Count', 0);
  if Count <= 0 then
    Exit;

  SetLength(AColumns, Count);
  for I := 0 to Count - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);
    AColumns[I].Name := AIni.ReadString(Section, 'Name', '');
    AColumns[I].DisplayIndex := AIni.ReadInteger(Section, 'DisplayIndex', I);
    AColumns[I].Width := S2F(AIni.ReadString(Section, 'Width', '80'));
    AColumns[I].Visible := AIni.ReadBool(Section, 'Visible', True);
  end;
end;

{ Persists channel collection metadata to INI storage. }
class procedure TWorkTable.SaveChannelList(AIni: TCustomIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>);
var
  I, OldCount: Integer;
  Channel: TChannel;
  Section: string;
begin
  if (AIni = nil) or (AChannels = nil) then
    Exit;

  OldCount := AIni.ReadInteger(ASectionPrefix, 'Count', 0);
  AIni.WriteInteger(ASectionPrefix, 'Count', AChannels.Count);

  for I := AChannels.Count to OldCount - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);
    AIni.EraseSection(Section);
  end;

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    Section := ASectionPrefix + '.' + IntToStr(I);

    Channel.ID := I + 1;
    if Trim(Channel.Name) = '' then
    begin
      if EndsText('.Etalon', ASectionPrefix) then
        Channel.Name := BuildEtalonChannelServiceName(Channel.ID)
      else
        Channel.Name := BuildDeviceChannelServiceName(Channel.ID);
    end;

    AIni.WriteInteger(Section, 'ID', Channel.ID);
    AIni.WriteString(Section, 'UUID', Channel.UUID);
    AIni.WriteInteger(Section, 'WorkTabeID', Channel.WorkTabeID);
    AIni.WriteBool(Section, 'Enabled', Channel.Enabled);
    AIni.WriteString(Section, 'Name', Channel.Name);
    AIni.WriteString(Section, 'Text', Channel.Text);
    AIni.WriteString(Section, 'TypeName', Channel.TypeName);
    AIni.WriteString(Section, 'DeviceName', Channel.DeviceName);
    AIni.WriteString(Section, 'Serial', Channel.Serial);
    AIni.WriteInteger(Section, 'Signal', Channel.Signal);
    AIni.WriteInteger(Section, 'OutputSet', Ord(Channel.OutputSet));
    AIni.WriteInteger(Section, 'SyncMode', Ord(Channel.SyncMode));
    AIni.WriteInteger(Section, 'NoiseFilter', Channel.NoiseFilter);
    AIni.WriteInteger(Section, 'Category', Channel.Category);
    AIni.WriteInteger(Section, 'Group', Channel.Group);
    AIni.WriteString(Section, 'DeviceUUID', Channel.DeviceUUID);
    AIni.WriteString(Section, 'TypeUUID', Channel.TypeUUID);
    AIni.WriteString(Section, 'RepoTypeName', Channel.RepoTypeName);
    AIni.WriteString(Section, 'RepoTypeUUID', Channel.RepoTypeUUID);
    AIni.WriteString(Section, 'RepoDeviceName', Channel.RepoDeviceName);
    AIni.WriteString(Section, 'RepoDeviceUUID', Channel.RepoDeviceUUID);
    AIni.WriteFloat(Section, 'QMaxWork', Channel.QMaxWork);
    AIni.WriteFloat(Section, 'QMinWork', Channel.QMinWork);
    AIni.WriteFloat(Section, 'VMaxWork', Channel.VMaxWork);
    AIni.WriteFloat(Section, 'VMinWork', Channel.VMinWork);

    AIni.WriteFloat(Section, 'ImpSec', Channel.ImpSec);
    AIni.WriteFloat(Section, 'ImpResult', Channel.ImpResult);
    AIni.WriteFloat(Section, 'CurSec', Channel.CurSec);
    AIni.WriteFloat(Section, 'CurResult', Channel.CurResult);
    AIni.WriteFloat(Section, 'ValueSec', Channel.ValueSec);
    AIni.WriteFloat(Section, 'ValueResult', Channel.ValueResult);

    if (Channel<>nil) then
    begin
    if (Channel.ValueImp<>nil) then
    AIni.WriteString(Section, 'HashValueImp', Channel.ValueImp.Hash);
    if (Channel.ValueImpTotal<>nil) then
    AIni.WriteString(Section, 'HashValueImpTotal', Channel.ValueImpTotal.Hash);
    if (Channel.ValueCurrent<>nil) then
    AIni.WriteString(Section, 'HashValueCurrent', Channel.ValueCurrent.Hash);
    if (Channel.ValueInterface<>nil) then
    AIni.WriteString(Section, 'HashValueInterface', Channel.ValueInterface.Hash);
    if (Channel.FlowMeter<>nil) and (Channel.FlowMeter.ValueVolumeFlow<>nil) then
    AIni.WriteString(Section, 'HashValueFlow', Channel.FlowMeter.ValueVolumeFlow.Hash);
    end;
  end;
end;



{ Restores channel collection metadata from INI storage. }
class procedure TWorkTable.LoadChannelList(AIni: TCustomIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>; const AWorkTableID: Integer);
var
  Count, I: Integer;
  Channel: TChannel;
  Section: string;
  IsExisted: Integer;
begin
  if (AIni = nil) or (AChannels = nil) then
    Exit;

  AChannels.Clear;
  Count := AIni.ReadInteger(ASectionPrefix, 'Count', 0);

  for I := 0 to Count - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);

    Channel := TChannel.Create;
    Channel.ID := AIni.ReadInteger(Section, 'ID', I + 1);
    Channel.UUID := AIni.ReadString(Section, 'UUID', '');
    Channel.WorkTabeID := AIni.ReadInteger(Section, 'WorkTabeID', AWorkTableID);
    Channel.Enabled := AIni.ReadBool(Section, 'Enabled', True);
    if EndsText('.Etalon', ASectionPrefix) then
      Channel.Name := AIni.ReadString(Section, 'Name', BuildEtalonChannelServiceName(Channel.ID))
    else
      Channel.Name := AIni.ReadString(Section, 'Name', BuildDeviceChannelServiceName(Channel.ID));
    if Trim(Channel.Name) = '' then
    begin
      if EndsText('.Etalon', ASectionPrefix) then
        Channel.Name := BuildEtalonChannelServiceName(Channel.ID)
      else
        Channel.Name := BuildDeviceChannelServiceName(Channel.ID);
    end;
    Channel.Text := AIni.ReadString(Section, 'Text', BuildChannelDefaultText(I + 1));
    if Trim(Channel.Text) = '' then
      Channel.Text := BuildChannelDefaultText(I + 1);
    Channel.TypeName := AIni.ReadString(Section, 'TypeName', '');
    Channel.DeviceName := AIni.ReadString(Section, 'DeviceName', Channel.TypeName);
    Channel.Serial := AIni.ReadString(Section, 'Serial', '');
    Channel.Signal := AIni.ReadInteger(Section, 'Signal', -1);
    Channel.OutputSet := IntToOutputSet(
      AIni.ReadInteger(Section, 'OutputSet', Ord(optAuto))
    );
    Channel.SyncMode := IntToSyncChannelMode(
      AIni.ReadInteger(Section, 'SyncMode', Ord(scmOff))
    );
    Channel.NoiseFilter := AIni.ReadInteger(Section, 'NoiseFilter', 0);
    Channel.Category := AIni.ReadInteger(Section, 'Category', Ord(mftUnknownType));
    Channel.Group := AIni.ReadInteger(Section, 'Group', 0);
    Channel.DeviceUUID := AIni.ReadString(Section, 'DeviceUUID', '');
    Channel.TypeUUID := AIni.ReadString(Section, 'TypeUUID', '');
    Channel.RepoTypeName := AIni.ReadString(Section, 'RepoTypeName', '');
    Channel.RepoTypeUUID := AIni.ReadString(Section, 'RepoTypeUUID', '');
    Channel.RepoDeviceName := AIni.ReadString(Section, 'RepoDeviceName', '');
    Channel.RepoDeviceUUID := AIni.ReadString(Section, 'RepoDeviceUUID', '');
    if AIni.ValueExists(Section, 'QMaxWork') then
    begin
      Channel.QMaxWork := S2F(AIni.ReadString(Section, 'QMaxWork', '0'));
      Channel.QMinWork := S2F(AIni.ReadString(Section, 'QMinWork', '0'));
      Channel.VMaxWork := S2F(AIni.ReadString(Section, 'VMaxWork', '0'));
      Channel.VMinWork := S2F(AIni.ReadString(Section, 'VMinWork', '0'));
    end;

    Channel.ImpSec := S2F(AIni.ReadString(Section, 'ImpSec', '0'));
    Channel.ImpResult :=0; //AIni.ReadFloat(Section, 'ImpResult', 0);
    Channel.CurSec := S2F(AIni.ReadString(Section, 'CurSec', '0'));
    Channel.CurResult := S2F(AIni.ReadString(Section, 'CurResult', '0'));
    Channel.ValueSec := S2F(AIni.ReadString(Section, 'ValueSec', '0'));
    Channel.ValueResult := S2F(AIni.ReadString(Section, 'ValueResult', '0'));

    Channel.FHashValueImp := AIni.ReadString(Section, 'HashValueImp', Channel.FHashValueImp);
    Channel.FHashValueImpTotal := AIni.ReadString(Section, 'HashValueImpTotal', Channel.FHashValueImpTotal);
    Channel.FHashValueCurrent := AIni.ReadString(Section, 'HashValueCurrent', Channel.FHashValueCurrent);
    Channel.FHashValueInterface := AIni.ReadString(Section, 'HashValueInterface', Channel.FHashValueInterface);
    Channel.FHashValueFlow := AIni.ReadString(Section, 'HashValueFlow', Channel.FHashValueFlow);
    if (Channel.FlowMeter <> nil) and (Trim(Channel.FHashValueFlow) <> '') then
    begin
      Channel.FlowMeter.RestoreValueVolumeFlowHash(Channel.FHashValueFlow);
    end;

    if Channel.FValueImp <> nil then Channel.FValueImp.DeleteFromVector;
    if Channel.FValueImpTotal <> nil then Channel.FValueImpTotal.DeleteFromVector;
    if Channel.FValueCurrent <> nil then Channel.FValueCurrent.DeleteFromVector;
    if Channel.FValueInterface <> nil then Channel.FValueInterface.DeleteFromVector;

    Channel.InitMeterValues;

    Channel.FlowMeter.Name := 'прибор '+ Channel.Name;

    Channel.Init;
    if not AIni.ValueExists(Section, 'QMaxWork') then
      Channel.InitWorkRangesFromFlowMeter;

    AChannels.Add(Channel);
  end;
end;

class procedure TWorkTable.SaveScaleList(AIni: TCustomIniFile;
  const ASectionPrefix: string; AScales: TObjectList<TWeight>);
var
  I, OldCount: Integer;
  Scale: TWeight;
  Section: string;
begin
  if (AIni = nil) or (AScales = nil) then
    Exit;

  OldCount := AIni.ReadInteger(ASectionPrefix, 'Count', 0);
  AIni.WriteInteger(ASectionPrefix, 'Count', AScales.Count);

  for I := AScales.Count to OldCount - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);
    AIni.EraseSection(Section);
  end;

  for I := 0 to AScales.Count - 1 do
  begin
    Scale := AScales[I];
    if Scale = nil then
      Continue;

    Section := ASectionPrefix + '.' + IntToStr(I);
    AIni.WriteString(Section, 'Name', Scale.Name);
    AIni.WriteString(Section, 'UUID', Scale.UUID);
    AIni.WriteFloat(Section, 'CurrentWeight', Scale.CurrentWeight);
    AIni.WriteFloat(Section, 'TareWeight', Scale.TareWeight);
  end;
end;

class procedure TWorkTable.LoadScaleList(AIni: TCustomIniFile;
  const ASectionPrefix: string; AScales: TObjectList<TWeight>);
var
  I, Count: Integer;
  Scale: TWeight;
  Section, ScaleName, ScaleUUID: string;
begin
  if (AIni = nil) or (AScales = nil) then
    Exit;

  AScales.Clear;
  Count := AIni.ReadInteger(ASectionPrefix, 'Count', 0);
  for I := 0 to Count - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);
    ScaleName := AIni.ReadString(Section, 'Name', '');
    Scale := TWeight.Create(ScaleName);
    ScaleUUID := AIni.ReadString(Section, 'UUID', '');
    if Trim(ScaleUUID) <> '' then
      Scale.UUID := ScaleUUID;
    Scale.CurrentWeight := S2F(AIni.ReadString(Section, 'CurrentWeight', '0'));
    Scale.TareWeight := S2F(AIni.ReadString(Section, 'TareWeight', '0'));
    AScales.Add(Scale);
  end;
end;

{ Builds canonical internal service name for a work table by index. }
class function TWorkTable.BuildWorkTableServiceName(const ATableIndex: Integer): string;
begin
  Result := 'Рабочий стол ' + IntToStr(ATableIndex);
end;

{ Builds canonical internal service name for a device channel by index. }
class function TWorkTable.BuildDeviceChannelServiceName(const AChannelIndex: Integer): string;
begin
  Result := 'Канал поверяемых приборов ' + IntToStr(AChannelIndex);
end;

{ Builds canonical internal service name for an etalon channel by index. }
class function TWorkTable.BuildEtalonChannelServiceName(const AChannelIndex: Integer): string;
begin
  Result := 'Канал эталонов ' + IntToStr(AChannelIndex);
end;

{ Builds default UI display text for a channel by index. }
class function TWorkTable.BuildChannelDefaultText(const AChannelIndex: Integer): string;
begin
  Result := IntToStr(AChannelIndex);
end;

function TWorkTable.DeleteChannel(AChannel: TChannel): Boolean;
var
  ChannelIndex: Integer;
begin
  Result := False;
  if AChannel = nil then
    Exit;

  ChannelIndex := FDeviceChannels.IndexOf(AChannel);
  if ChannelIndex >= 0 then
  begin
    FDeviceChannels.Delete(ChannelIndex);
    //ReindexChannels(FDeviceChannels, False);
    UpdateAggregateMeterValues;
    AssignTableFlowAsEtalonToDevices;
    Result := True;
    Exit;
  end;

  ChannelIndex := FEtalonChannels.IndexOf(AChannel);
  if ChannelIndex >= 0 then
  begin
    FEtalonChannels.Delete(ChannelIndex);
    //ReindexChannels(FEtalonChannels, True);
    UpdateAggregateMeterValues;
    UpdateFlowRateLimitsByEtalons;
    AssignTableFlowAsEtalonToDevices;
    Result := True;
    Exit;
  end;
end;

//нигде не используется
procedure TWorkTable.ReindexChannels(AChannels: TObjectList<TChannel>;
  const AEtalonChannels: Boolean);
var
  I: Integer;
  Channel: TChannel;
begin
  if AChannels = nil then
    Exit;

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    if Channel = nil then
      Continue;

    Channel.ID := I + 1;
    if AEtalonChannels then
      Channel.Name := BuildEtalonChannelServiceName(Channel.ID)
    else
      Channel.Name := BuildDeviceChannelServiceName(Channel.ID);

  end;
end;

class function TWorkTable.WorkTableStateFromString(
  const AValue: string): EStateWorkTable;
begin
  if SameText(AValue, 'swtSTANDBY') then
    Exit(swtSTANDBY);
  if SameText(AValue, 'swtCONNECTED') then
    Exit(swtCONNECTED);
  if SameText(AValue, 'swtSTARTMONITOR') then
    Exit(swtSTARTMONITOR);
  if SameText(AValue, 'swtSTARTMONITORWAIT') then
    Exit(swtSTARTMONITORWAIT);
  if SameText(AValue, 'swtMONITOR') then
    Exit(swtMONITOR);
  if SameText(AValue, 'swtSTOPMONITOR') then
    Exit(swtSTOPMONITOR);
  if SameText(AValue, 'swtCONFIGED') then
    Exit(swtCONFIGED);
  if SameText(AValue, 'swtSTARTTEST') then
    Exit(swtSTARTTEST);
  if SameText(AValue, 'swtSTARTWAIT') then
    Exit(swtSTARTWAIT);
  if SameText(AValue, 'swtEXECUTE') then
    Exit(swtEXECUTE);
  if SameText(AValue, 'swtSTOPTEST') then
    Exit(swtSTOPTEST);
  if SameText(AValue, 'swtSTOPWAIT') then
    Exit(swtSTOPWAIT);
  if SameText(AValue, 'swtCOMPLETE') then
    Exit(swtCOMPLETE);
  if SameText(AValue, 'swtFINALREAD') then
    Exit(swtFINALREAD);
  if SameText(AValue, 'swtFAILURE') then
    Exit(swtFAILURE);

  Result := swtNONE;
end;


class function TWorkTable.WorkTableStateToString(
  AState: EStateWorkTable): string;
begin
  case AState of
    swtSTANDBY: Result := 'swtSTANDBY';
    swtCONNECTED: Result := 'swtCONNECTED';
    swtSTARTMONITOR: Result := 'swtSTARTMONITOR';
    swtSTARTMONITORWAIT: Result := 'swtSTARTMONITORWAIT';
    swtMONITOR: Result := 'swtMONITOR';
    swtSTOPMONITOR: Result := 'swtSTOPMONITOR';
    swtCONFIGED: Result := 'swtCONFIGED';
    swtSTARTTEST: Result := 'swtSTARTTEST';
    swtSTARTWAIT: Result := 'swtSTARTWAIT';
    swtEXECUTE: Result := 'swtEXECUTE';
    swtSTOPTEST: Result := 'swtSTOPTEST';
    swtSTOPWAIT: Result := 'swtSTOPWAIT';
    swtCOMPLETE: Result := 'swtCOMPLETE';
    swtFINALREAD: Result := 'swtFINALREAD';
    swtFAILURE: Result := 'swtFAILURE';
  else
    Result := 'swtNONE';
  end;
end;

class function TWorkTable.WorkTableEventToText(AEvent: TWorkTableEvent): string;
begin
  case AEvent of
    ewtEtalonsChanged:
      Result := 'EtalonsChanged';
  else
    Result := GetEnumName(TypeInfo(TWorkTableEvent), Ord(AEvent));
  end;
end;

class function TWorkTable.WorkTableEventToString(AEvent: TWorkTableEvent): string;
begin
  Result := WorkTableEventToText(AEvent);
end;

class function TWorkTable.WorkTableEventToProtocolCategory(
  AEvent: TWorkTableEvent): EProtocolCategory;
begin
  case AEvent of
    ewtNone:
      Result := pcNone;

    ewtEvent:
      Result := pcEvent;

    ewtState,
    ewtRefresh:
      Result := pcState;

    ewtAction,
    ewtActivated:
      Result := pcAction;

    ewtInfo,
    ewtEtalonsChanged:
      Result := pcInfo;

    ewtWarning:
      Result := pcWarning;

    ewtError:
      Result := pcError;
  else
    Result := pcEvent;
  end;
end;

procedure TWorkTable.SetIsActive(const AValue: Boolean);
begin
  if FIsActive = AValue then
    Exit;

  FIsActive := AValue;

  if FIsActive then
    FireEvent(ewtActivated);
end;

procedure TWorkTable.FireEvent(AEvent: TWorkTableEvent; const AMsg: String );
var
  Category: EProtocolCategory;
  EventText: string;
  ErrorDetails: string;
begin
  Category := WorkTableEventToProtocolCategory(AEvent);
  EventText := WorkTableEventToText(AEvent);

  ProtocolManager.AddMessage(Category, psWorkTable, 'WorkTableEvent',
    'Событие рабочего стола', AMsg);

  Event := Integer(AEvent);
  NotifyOwned(notifyEvent, TEventNotification.Create(Ord(AEvent)));
end;

procedure TWorkTable.FireEvent(AEvent: TWorkTableEvent; const AError: TErrorInfo);
var
  Category: EProtocolCategory;
  EventText: string;
  ErrorDetails: string;
begin
  Category := WorkTableEventToProtocolCategory(AEvent);
  EventText := WorkTableEventToText(AEvent);

  ProtocolManager.AddMessage(Category, psWorkTable, 'FireEvent',
    'Событие рабочего стола', EventText);

  if (AError.Code <> 0) or (Trim(AError.Msg) <> '') then
  begin
    ErrorDetails := Format('Event=%s; Code=%d; State=%s; Time=%s; Msg=%s', [
      EventText,
      AError.Code,
      WorkTableStateToString(EStateWorkTable(AError.Stage)),
      FormatDateTime('dd.mm.yyyy hh:nn:ss', AError.Time),
      AError.Msg
    ]);

    ProtocolManager.AddMessage(pcError, psWorkTable, 'FireEvent-ERROR',
      'Ошибка события рабочего стола', ErrorDetails);
  end;

  Event := Integer(AEvent);
  NotifyOwned(notifyEvent, TEventNotification.Create(Ord(AEvent)));
end;

procedure TWorkTable.FireEvent(AEvent: TWorkTableEvent);
begin
  FireEvent(AEvent, TErrorInfo.Empty(Integer(FState)));
end;

procedure TWorkTable.Notify(Event: Integer; Data: TObject);
begin
  inherited Notify(Event, Data);
end;

procedure TWorkTable.Notify(AEvent: ENotifyEvent; Data: TObject);
begin
  Notify(Ord(AEvent), Data);
end;

procedure TWorkTable.BindParameterEvents(AParameter: TParameter);
begin
  if (AParameter = nil) or (FParameterObserver = nil) then
    Exit;

  AParameter.Subscribe(FParameterObserver);
end;

procedure TWorkTable.UnbindParameterEvents(AParameter: TParameter);
begin
  if (AParameter = nil) or (FParameterObserver = nil) then
    Exit;

  AParameter.Unsubscribe(FParameterObserver);
end;

procedure TWorkTable.HandleParameterNotify(Sender: TObject; Event: Integer; Data: TObject);
var
  AParameter: TParameter;
  AEvent: ENotifyEvent;
  ActionNotification: TActionNotification;
  EventNotification: TEventNotification;
  StateNotification: TStateNotification;
begin
  if Sender is TParameter then
    AParameter := TParameter(Sender)
  else
    Exit;

  case Event of
    Ord(notifyStateChanged):
      begin
        if not (Data is TStateNotification) then
          Exit;
        StateNotification := TStateNotification(Data);
      //  AEvent := ResolveParameterStateEvent(AParameter);
      { NotifyOwned(AEvent, TStateNotification.Create(StateNotification.OldState, StateNotification.NewState));  }
      end;
    Ord(notifyAction):
      begin
        if not (Data is TActionNotification) then
          Exit;
        ActionNotification := TActionNotification(Data);
        if (ActionNotification.Action < Ord(Low(EActionParameter))) or
           (ActionNotification.Action > Ord(High(EActionParameter))) then
          Exit;
       // AEvent := ResolveParameterActionEvent(AParameter, EActionParameter(ActionNotification.Action));
      {  NotifyOwned(AEvent, TActionNotification.Create(ActionNotification.Action));   }
      end;
    Ord(notifyEvent):
      begin
        if not (Data is TEventNotification) then
          Exit;
        EventNotification := TEventNotification(Data);
       { NotifyOwned(notifyEvent, TEventNotification.Create(EventNotification.Event));   }
      end;
  end;
end;
//Не понятно зачем
function TWorkTable.ResolveParameterStateEvent(AParameters: TParameter): ENotifyEvent;
begin

end;
//Не понятно зачем
function TWorkTable.ResolveParameterActionEvent(AParameters: TParameter;
  AParameterAction: EActionParameter): ENotifyEvent;
begin
  if AParameters is TPump then
  begin
    case AParameterAction of
      apStart: Exit(notifyAction);
      apStop: Exit(notifyAction);
      apSet: Exit(notifyAction);
    else
      Exit(notifyStateChanged);
    end;
  end;

  if AParameters is TFlowRate then
  begin
    case AParameterAction of
      apStart: Exit(notifyAction);
      apStop: Exit(notifyAction);
      apSet: Exit(notifyAction);
    else
      Exit(notifyStateChanged);
    end;
  end;

  if AParameters is TFluidTemp then
  begin
    case AParameterAction of
      apStart: Exit(notifyAction);
      apStop: Exit(notifyAction);
      apSet: Exit(notifyAction);
    else
      Exit(notifyStateChanged);
    end;
  end;

  if AParameters is TFluidPress then
  begin
    case AParameterAction of
      apStart: Exit(notifyAction);
      apStop: Exit(notifyAction);
      apSet: Exit(notifyAction);
    else
      Exit(notifyStateChanged);
    end;
  end;

  Result := notifyStateChanged;
end;

procedure TWorkTable.SetActivePumpObject(const APump: TPump);
begin
  if FActivePump = APump then
    Exit;

  UnbindParameterEvents(FActivePump);
  FActivePump := APump;
  BindParameterEvents(FActivePump);
end;

procedure TWorkTable.SetActiveScaleObject(const AScale: TWeight);
begin
  if FActiveScale = AScale then
    Exit;

  UnbindParameterEvents(FActiveScale);
  FActiveScale := AScale;
  BindParameterEvents(FActiveScale);
  if FActiveScale <> nil then
  begin
    FCurrentWeight := FActiveScale.CurrentWeight;
    FScaleTareWeight := FActiveScale.TareWeight;
  end;
end;

procedure TWorkTable.DoProcStart(AProcName: string);
begin
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));

end;

procedure TWorkTable.DoProcStop(AProcName: string);
begin
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));

end;

procedure TWorkTable.DoProcPause(AProcName: string);
begin
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));

end;

procedure TWorkTable.DoProcNextStep(AProcName: string);
begin
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

procedure TWorkTable.DoProcRepeat(AProcName: string);
begin
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));

end;

procedure TWorkTable.DoSpillageStart;
begin
  ResetSpillageRuntimeValues;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoSpillageStart',
    'Начало проливки. Сброшены текущие накопители времени, объёма и среднего расхода', Name);
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

procedure TWorkTable.DoSpillageStop;
begin
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

procedure TWorkTable.SetState(const ANewState: EStateWorkTable);
var
  OldState: EStateWorkTable;
begin
  if FState = ANewState then
    Exit;

  OldState := FState;
  if FState = swtCONNECTED then
    ProtocolManager.AddMessage(pcState, psWorkTable, 'SetState',
      'swtCONNECTED',
      Format('%s: %s -> %s', [Text, WorkTableStateToString(OldState),
        WorkTableStateToString(ANewState)]));

  FState := ANewState;
  ProtocolManager.AddMessage(pcState, psWorkTable, 'SetState',
    'Изменено состояние рабочего стола',
    Format('%s: %s -> %s', [Text, WorkTableStateToString(OldState),
      WorkTableStateToString(ANewState)]));
  NotifyOwned(notifyStateChanged, TStateNotification.Create(Ord(OldState), Ord(ANewState)));
end;

function TWorkTable.CreateActionNotification(AAction: EActionWorkTable; const ASourceName: string;
  const ADescription: string): TActionNotification;
begin
  FAction := AAction;
  ProtocolManager.AddMessage(pcAction, psWorkTable, ASourceName, ADescription, Name);
  Result := TActionNotification.Create(Ord(AAction));
end;

procedure TWorkTable.FireAction(AAction: EActionWorkTable; const ASourceName: string;
  const ADescription: string);
begin
  NotifyOwned(notifyAction, CreateActionNotification(AAction, ASourceName, ADescription));
end;

procedure TWorkTable.ExecuteAction(AAction: EActionWorkTable; const ASourceName: string;
  const ADescription: string);
begin
  NotifySyncOwned(notifyAction, CreateActionNotification(AAction, ASourceName, ADescription));
end;

procedure TWorkTable.ResetSpillageRuntimeValues;
var
  Ch: TChannel;

  procedure ResetMeter(const AMeter: TMeterValue); overload;
  begin
    if AMeter <> nil then
      AMeter.Reset;
  end;

  procedure ResetMeter(const AMeter: TMeterValue; const AValue: Double); overload;
  begin
    if AMeter <> nil then
      AMeter.Reset(AValue);
  end;
begin
  Time := 0;
  TimeResult := 0;
  ResetMeter(ValueTime, 0);
  ResetMeter(ValueQuantity, 0);

  if DeviceChannels <> nil then
    for Ch in DeviceChannels do
      if Ch <> nil then
      begin
        Ch.CurSec := 0;
        Ch.ImpResult := 0;
        ResetMeter(Ch.ValueImp);
        ResetMeter(Ch.ValueImpTotal, 0);
        if (Ch.FlowMeter <> nil) and (Ch.FlowMeter.ValueQuantity <> nil) then
          Ch.FlowMeter.ValueQuantity.Reset(0);
      end;

  if EtalonChannels <> nil then
    for Ch in EtalonChannels do
      if Ch <> nil then
      begin
        Ch.CurSec := 0;
        Ch.ImpResult := 0;
        ResetMeter(Ch.ValueImp);
        ResetMeter(Ch.ValueImpTotal, 0);
        if (Ch.FlowMeter <> nil) and (Ch.FlowMeter.ValueQuantity <> nil) then
          Ch.FlowMeter.ValueQuantity.Reset(0);
      end;
end;

procedure TWorkTable.DoStartMonitor;
begin

 // SetState(swtSTARTMONITOR);

end;

procedure TWorkTable.DoStopMonitor;
begin
 // SetState(swtSTOPMONITOR);
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoStopMonitor',
    'Подготовка к остановке монитора. Ничего тут нет.', Name);
end;

procedure TWorkTable.DoStartTest;
begin

end;

procedure TWorkTable.DoStopTest;
begin
  //SetState(swtSTOPTEST);
  //StopMeasurementRun;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoStopTest',
    'Подготовка к остановке измеиения.', Name);
end;

/// <summary>
/// Handles a MeasurementRun stage notification without controlling the
/// measurement scenario or issuing low-level WorkTable commands.
/// </summary>
procedure TWorkTable.MeasurementRunStateChanged(ASender: TObject; AState: EMeasurementState);
begin
  ProtocolManager.AddMessage(pcState, psWorkTable, 'MeasurementRunStateChanged',
    'Изменение этапа процесса измерения',
    TMeasurementRun.MeasurementStateToString(AState));
 // Notify(notifyStateChanged, ASender);
end;

procedure TWorkTable.MeasurementRunPointChanged(ASender: TObject; APoint: TDevicePoint;
  APointIndex: Integer);
begin
  if (FCurrentPoint <> nil) and (APoint <> nil) then
    FCurrentPoint.Assign(APoint, True);

 // Notify(notifyStateChanged, APoint);
  DoProcNextStep(Format('Point %d', [APointIndex + 1]));
end;

procedure TWorkTable.ResetMeasurementValues;
var
  Ch: TChannel;

  procedure ResetMeter(const AMeter: TMeterValue); overload;
  begin
    if AMeter <> nil then
      AMeter.Reset;
  end;

  procedure ResetMeter(const AMeter: TMeterValue; const AValue: Double); overload;
  begin
    if AMeter <> nil then
      AMeter.Reset(AValue);
  end;

  procedure ResetSimulationChannelFields(const AChannel: TChannel);
  begin
    if AChannel = nil then
      Exit;

    AChannel.CurSec := 0;
   // AChannel.ImpSec := 0;
    AChannel.ImpResult := 0;
  end;
begin

  // Сброс полей, участвующих в имитации
  // (используются в имитации климата и каналов).
  //FActiveWorkTable.Temp := 0;
  //FActiveWorkTable.Press := 0;
  FNextClimateChangeAt := 0;

  Time  := 0;
  TimeResult  := 0;

  if TableFlow <> nil then
    TableFlow.Reset;

  ResetMeter(ValueTempertureBefore);
  ResetMeter(ValueTempertureAfter);
  ResetMeter(ValueTempertureDelta);
  ResetMeter(ValueTemperture);
  ResetMeter(ValuePressureBefore);
  ResetMeter(ValuePressureAfter);
  ResetMeter(ValuePressureDelta);
  ResetMeter(ValuePressure);
  ResetMeter(ValueDensity);
  ResetMeter(ValueAirPressure);
  ResetMeter(ValueAirTemperture);
  ResetMeter(ValueHumidity);
  ResetMeter(ValueTime, 0);
  ResetMeter(ValueQuantity, 0);
  ResetMeter(ValueFlowRate);

  for Ch in DeviceChannels do
  begin
    if Ch.FlowMeter <> nil then
      Ch.FlowMeter.Reset;

    ResetSimulationChannelFields(Ch);

    ResetMeter(Ch.ValueImp);
    ResetMeter(Ch.ValueImpTotal, 0);
    ResetMeter(Ch.ValueCurrent);
    ResetMeter(Ch.ValueInterface);
  end;

  for Ch in EtalonChannels do
  begin
    if Ch.FlowMeter <> nil then
      Ch.FlowMeter.Reset;

    ResetSimulationChannelFields(Ch);

    ResetMeter(Ch.ValueImp);
    ResetMeter(Ch.ValueImpTotal, 0);
    ResetMeter(Ch.ValueCurrent);
    ResetMeter(Ch.ValueInterface);
  end;
end;

procedure TWorkTable.SaveMeasurementResults;
var
  DeviceChannel: TChannel;
  EtalonChannel: TChannel;
  Point: TPointSpillage;
  Session: TSessionSpillage;
  DeviceRepo: TDeviceRepository;
  MeterValueCoef: TMeterValue;
  MeasuredDim: TMeasuredDimension;
  CurrentCoef: Double;
  CurrentPointQmax: Double;
  Device: TDevice;
  SourceDevice: TDevice;
  DevicePoint: TDevicePoint;
  MatchedPoint: TDevicePoint;
begin

  DeviceRepo := nil;
  if DataManager <> nil then
    DeviceRepo := DataManager.ActiveDeviceRepo;

  if DeviceChannels.Count = 0 then
    AddDeviceChannel(
      True,
      -1,
      TWorkTable.BuildChannelDefaultText(1),
      '',
      '-',
      ''
    );

  for DeviceChannel in DeviceChannels do
  begin
    if (DeviceChannel = nil) or (not DeviceChannel.Enabled) then
      Continue;

    SourceDevice := nil;
    if DeviceChannel.FlowMeter <> nil then
      SourceDevice := DeviceChannel.FlowMeter.Device;

    Device := TDeviceCreationService.EnsureDeviceForChannel(
      DeviceChannel,
      Self,
      DeviceRepo,
      dcmMeasurementPromoted,
      SourceDevice,
      CurrentPoint
    );
    if Device = nil then
      Continue;

    if (CurrentPoint <> nil) and (CurrentPoint.FlowRate > 0) and
       (CurrentPoint.Q > 0) then
    begin
      CurrentPointQmax := CurrentPoint.Q / CurrentPoint.FlowRate;
      if CurrentPointQmax > 0 then
      begin
        Device.Qmax := CurrentPointQmax;
        TDeviceCreationService.RecalcDevicePointQ(Device);
      end;
    end;

    Session := Device.GetActiveSessionSpillage;
    if Session = nil then
    begin
      Session := Device.AddSessionSpillage;
      if Session <> nil then
        Session.State := osNew;
    end
    else if Session.State <> osNew then
      Session.State := osModified;
    Device.State := osModified;

    if Session.DateTimeOpen = 0 then
      Session.DateTimeOpen := Now;

    Point := TPointSpillage.Create(Session.ID);
    try
      Point.Num := Device.Spillages.Count + 1;
      Point.Name := 'Измерение #' + IntToStr(Point.Num);
      Point.SessionID := Session.ID;
      Point.DeviceUUID := Device.UUID;
      Point.DateTime := Now;
      Point.SpillTime := ValueTime.GetDoubleValue;
      Point.QavgEtalon := ValueFlowRate.GetDoubleValue;

      MatchedPoint := nil;
      if (CurrentPoint <> nil) and (Device.Points <> nil) then
        for DevicePoint in Device.Points do
          if (DevicePoint <> nil) and
             (((CurrentPoint.ID <> 0) and (DevicePoint.ID = CurrentPoint.ID)) or
              ((CurrentPoint.ID = 0) and (Trim(CurrentPoint.Name) <> '') and
               SameText(DevicePoint.Name, CurrentPoint.Name))) then
          begin
            MatchedPoint := DevicePoint;
            Break;
          end;

      if MatchedPoint <> nil then
      begin
        Point.Name := MatchedPoint.Name;
      end;

      Point.EtalonVolume := TableFlow.ValueVolume.GetDoubleValue;

      Point.EtalonName := '';
      Point.EtalonUUID := '';
      for EtalonChannel in EtalonChannels do
      begin
        if (EtalonChannel = nil) or (not EtalonChannel.Enabled) or
           (EtalonChannel.FlowMeter = nil) or
           (EtalonChannel.FlowMeter.Device = nil) then
          Continue;

        if SameText(Trim(EtalonChannel.FlowMeter.Device.Name), 'Новое устройство') then
          Continue;

        Point.EtalonName := Trim(EtalonChannel.FlowMeter.Device.Name);
        Point.EtalonUUID := EtalonChannel.FlowMeter.Device.UUID;
        Break;
      end;

      if (Point.EtalonName = '') and (TableFlow <> nil) and
         (not SameText(Trim(TableFlow.Name), 'Новое устройство')) then
        Point.EtalonName := Trim(TableFlow.Name);

      Point.EtalonMass := TableFlow.ValueMass.GetDoubleValue;

      Point.EtalonVolumeFlow := Point.EtalonVolume/Point.SpillTime;
      Point.EtalonMassFlow := Point.EtalonMass/Point.SpillTime;

      Point.DeviceVolume := DeviceChannel.FlowMeter.ValueVolume.GetDoubleValue;
      Point.DeviceMass := DeviceChannel.FlowMeter.ValueMass.GetDoubleValue;

      Point.Density := DeviceChannel.FlowMeter.ValueDensity.GetDoubleValue;
      Point.Error := DeviceChannel.FlowMeter.ValueError.GetDoubleValue;
      Point.PulseCount := DeviceChannel.ValueImpResult.GetDoubleValue;

      Point.DeviceMassFlow := Point.DeviceMass/Point.SpillTime;
      Point.DeviceVolumeFlow := Point.DeviceVolume/Point.SpillTime;
      Point.MeanFrequency := Point.PulseCount/Point.SpillTime;

      CurrentCoef := 0.0;
      MeterValueCoef := DeviceChannel.FlowMeter.ValueCoef;
      if MeterValueCoef <> nil then
        CurrentCoef := MeterValueCoef.GetDoubleValue
      else if DeviceChannel.FlowMeter.Device <> nil then
        CurrentCoef := DeviceChannel.FlowMeter.Device.Coef;

      if SameValue(CurrentCoef, 0.0, 1E-12) and
         (DeviceChannel.FlowMeter.Device <> nil) then
      begin
        MeasuredDim := TMeasuredDimension(DeviceChannel.FlowMeter.Device.MeasuredDimension);
        case MeasuredDim of
          mdVolumeFlow, mdVolume:
            if not SameValue(Point.EtalonVolume, 0.0, 1E-12) then
              CurrentCoef := Point.PulseCount / Point.EtalonVolume;
          mdMassFlow, mdMass:
            if not SameValue(Point.EtalonMass, 0.0, 1E-12) then
              CurrentCoef := Point.PulseCount / Point.EtalonMass;
        end;
      end;
      Point.Coef := CurrentCoef;

      Point.AvgCurrent := DeviceChannel.ValueCurrent.GetDoubleValue;
      Point.StartTemperature := ValueTempertureBefore.GetDoubleValue;
      Point.EndTemperature := ValueTempertureAfter.GetDoubleValue;
      Point.AvgTemperature := ValueTemperture.GetDoubleValue;
      Point.InputPressure := ValuePressureBefore.GetDoubleValue;
      Point.OutputPressure := ValuePressureAfter.GetDoubleValue;
      Point.DeltaPressure :=  Point.InputPressure - Point.OutputPressure;
      Point.AtmosphericPressure := ValueAirPressure.GetDoubleValue;
      Point.AmbientTemperature := ValueAirTemperture.GetDoubleValue;
      Point.RelativeHumidity := ValueHumidity.GetDoubleValue;

      if Device <> nil then
      begin
        TDeviceCreationService.RecalcDevicePointQ(Device);
        LogMKS('DBG SP 1001', 'SaveMeasurementResults BEFORE AnalyseDataPoint',
          Format('Device=%s UUID=%s | %s', [Device.Name, Device.UUID, DumpSpillage(Point)]));
        Point.Valid := Device.AnalyseDataPoint(Point);
        LogMKS('DBG SP 1002', 'SaveMeasurementResults AFTER AnalyseDataPoint',
          Format('Device=%s UUID=%s | %s', [Device.Name, Device.UUID, DumpSpillage(Point)]));
      end;

      Point.State := osNew;
      if Session <> nil then
      begin
        if Session.State <> osNew then
          Session.State := osModified;
        Point.SessionID := Session.ID;
      end;
      Device.State := osModified;

      LogMKS('DBG SP 1003', 'SaveMeasurementResults BEFORE AddDataPoint',
        Format('Device=%s UUID=%s | %s', [Device.Name, Device.UUID, DumpSpillage(Point)]));
      DeviceChannel.FlowMeter.AddDataPoint(Point);
      LogMKS('DBG SP 1004', 'SaveMeasurementResults AFTER AddDataPoint',
        Format('Device=%s UUID=%s; Device.Spillages.Count=%d; Sessions.Count=%d',
          [Device.Name, Device.UUID, Device.Spillages.Count, Device.Sessions.Count]));

      if Assigned(DeviceRepo) then
        DeviceRepo.SaveDevice(Device);
    finally
      Point.Free;
    end;
  end;

end;

procedure TWorkTable.StartTest;
begin
  if State in [swtSTARTMONITOR, swtSTARTMONITORWAIT, swtMONITOR] then
    ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoStartTest',
      'Переход из режима монитора к измерению без промежуточной остановки', Name);

  ResetMeasurementValues;

  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoStartTest',
    'Подготовка к запуску измерения. Данные очищены', Name);

  FireAction(awtStartTest, 'StartTest', 'Запрошен запуск измерения');
end;

procedure TWorkTable.StartMonitor;
begin
  ResetMeasurementValues;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoStartMonitor',
    'Подготовка к запуску монитра. Очищены данные', Name);
  FireAction(awtStartMonitor, 'StartMonitor', 'Действие: запуск монитора');
end;

procedure TWorkTable.StopTest;
begin
  FireAction(awtStopTest, 'StopTest', 'Запрошена остановка теста');
end;

procedure TWorkTable.StopMonitor;
begin
  DoStopMonitor;
  FireAction(awtStopMonitor, 'StopMonitor', 'Запрошена остановка мониторинга');
end;

procedure TWorkTable.StartMeasurementRun;
begin

  ResetMeasurementValues;

  RecalculateAllMeterValues;

  FMode := MeasurementMode;
  TMeasurementRun(FMeasurementRun).Mode := MeasurementMode;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'StartMeasurementRun',
    'Запуск измерения', Format('Mode=%d', [Ord(MeasurementMode)]));
  TMeasurementRun(FMeasurementRun).Execute(mcStart);

end;


procedure TWorkTable.StartMeasurementRun(AMode: Integer);
var
  RunMode: EMeasurementRunMode;
begin
  if FMeasurementRun = nil then
    Exit;

  if (AMode < Ord(Low(EMeasurementRunMode))) or
     (AMode > Ord(High(EMeasurementRunMode))) then
    RunMode := mrmManual
  else
    RunMode := EMeasurementRunMode(AMode);

  FMode := RunMode;
  TMeasurementRun(FMeasurementRun).Mode := RunMode;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'StartMeasurementRun',
    'Запуск измерения', Format('Mode=%d', [Ord(RunMode)]));
  TMeasurementRun(FMeasurementRun).Execute(mcStart);
end;

procedure TWorkTable.StopMeasurementRun;
begin
  if FMeasurementRun <> nil then
    TMeasurementRun(FMeasurementRun).Execute(mcStop);
end;

procedure TWorkTable.PauseMeasurementRun;
begin
  if FMeasurementRun <> nil then
    TMeasurementRun(FMeasurementRun).Execute(mcPause);
end;

procedure TWorkTable.ResumeMeasurementRun;
begin
  if FMeasurementRun <> nil then
    TMeasurementRun(FMeasurementRun).Execute(mcResume);
end;

procedure TWorkTable.NextMeasurementPoint;
begin
  if FMeasurementRun <> nil then
    TMeasurementRun(FMeasurementRun).Execute(mcNextPoint);
end;

function TWorkTable.AddPump(const APumpName: string): TPump;
var
  NewPump: TPump;
  Pump: TPump;
begin
  Result := nil;
  if APumpName = '' then
    Exit;

  NewPump := nil;
  for Pump in TPump.Pumps do
    if Pump.Name = APumpName then
    begin
      NewPump := Pump;
      Break;
    end;

  if NewPump = nil then
    NewPump := TPump.Create(APumpName);

  if FPumps.IndexOf(NewPump) < 0 then
  begin
    BindParameterEvents(NewPump);
    FPumps.Add(NewPump);
  end;

  Result := NewPump;

      FAction:=awtAddPump;
    NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

function TWorkTable.AddPump(APump: TPump): Boolean;
begin
  if Assigned(APump) and (FPumps.IndexOf(APump) < 0) then
  begin
    BindParameterEvents(APump);
    FPumps.Add(APump);
    Result := True;
    FAction:=awtAddPump;
    NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));

  end
  else
    Result := False;


end;

procedure TWorkTable.RemovePump(const APumpUUID: string);
var
  Pump: TPump;
begin
  Pump := FindPumpByUUID(APumpUUID);
  if Assigned(Pump) then
  begin
    if FActivePump = Pump then
      FActivePump := nil;
    UnbindParameterEvents(Pump);
    FPumps.Remove(Pump);

    FAction:=awtRemovePump;
    NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
  end;
end;

procedure TWorkTable.RemovePump(APump: TPump);
begin
  if Assigned(APump) then
  begin
    if FActivePump = APump then
      FActivePump := nil;
    UnbindParameterEvents(APump);
    FPumps.Remove(APump);

    FAction := awtRemovePump;
    NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
  end;
end;

procedure TWorkTable.ClearPumps;
var
  Pump: TPump;
begin
  for Pump in FPumps do
    UnbindParameterEvents(Pump);
  FActivePump := nil;
  FPumps.Clear;
end;

function TWorkTable.FindPumpByName(const APumpName: string): TPump;
var
  Pump: TPump;
begin
  for Pump in FPumps do
  begin
    if Pump.Name = APumpName then
    begin
      Result := Pump;
      Exit;
    end;
  end;
  Result := nil;
end;

function TWorkTable.FindPumpByUUID(const APumpUUID: string): TPump;
var
  Pump: TPump;
begin
 { for Pump in FPumps do
  begin
    if Pump.UUID = APumpUUID then
    begin
      Result := Pump;
      Exit;
    end;
  end;
  Result := nil;   }
end;

procedure TWorkTable.SetActivePump(APumpName: string);
var
  Pump: TPump;
begin
  Pump := nil;
  for Pump in tPump.Pumps do
  begin
    if Pump.Name = APumpName then
      Break;
  end;

  if (Pump = nil) or (Pump.Name <> APumpName) then
    Exit;

  ActivePump := Pump;
end;

function TWorkTable.AddScale(const AScaleName: string): TWeight;
var
  NewScale: TWeight;
  Scale: TWeight;
begin
  Result := nil;
  if AScaleName = '' then
    Exit;

  NewScale := nil;
  if TWeight.Weights <> nil then
    for Scale in TWeight.Weights do
      if Scale.Name = AScaleName then
      begin
        NewScale := Scale;
        Break;
      end;

  if NewScale = nil then
    NewScale := TWeight.Create(AScaleName);

  if FScales.IndexOf(NewScale) < 0 then
  begin
    BindParameterEvents(NewScale);
    FScales.Add(NewScale);
  end;

  Result := NewScale;
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

function TWorkTable.AddScale(AScale: TWeight): Boolean;
begin
  if Assigned(AScale) and (FScales.IndexOf(AScale) < 0) then
  begin
    BindParameterEvents(AScale);
    FScales.Add(AScale);
    Result := True;
    NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
  end
  else
    Result := False;
end;

procedure TWorkTable.RemoveScale(const AScaleUUID: string);
var
  Scale: TWeight;
begin
  Scale := FindScaleByUUID(AScaleUUID);
  if Assigned(Scale) then
    RemoveScale(Scale);
end;

procedure TWorkTable.RemoveScale(AScale: TWeight);
begin
  if Assigned(AScale) then
  begin
    if FActiveScale = AScale then
      FActiveScale := nil;
    UnbindParameterEvents(AScale);
    FScales.Remove(AScale);
    NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
  end;
end;

procedure TWorkTable.ClearScales;
var
  Scale: TWeight;
begin
  for Scale in FScales do
    UnbindParameterEvents(Scale);
  FActiveScale := nil;
  FScales.Clear;
end;

function TWorkTable.FindScaleByName(const AScaleName: string): TWeight;
var
  Scale: TWeight;
begin
  Result := nil;
  for Scale in FScales do
    if (Scale <> nil) and SameText(Scale.Name, AScaleName) then
      Exit(Scale);
end;

function TWorkTable.FindScaleByUUID(const AScaleUUID: string): TWeight;
var
  Scale: TWeight;
begin
  Result := nil;
  if Trim(AScaleUUID) = '' then
    Exit;

  for Scale in FScales do
    if (Scale <> nil) and SameText(Scale.UUID, AScaleUUID) then
      Exit(Scale);
end;

procedure TWorkTable.SetActiveScale(AScaleName: string);
begin
  ActiveScale := FindScaleByName(AScaleName);
end;

function TWorkTable.GetCurentValue: Double;
begin
  Result := DisplayWeight;
end;

procedure TWorkTable.SetCurentValue(const AValue: Double);
begin
  CurrentWeight := AValue + ScaleTareWeight;
  if ActiveScale <> nil then
    ActiveScale.CurentValue := CurrentWeight;
end;

function TWorkTable.DisplayWeight: Double;
begin
  Result := CurrentWeight - ScaleTareWeight;
end;

procedure TWorkTable.DoScaleTare;
begin
  ScaleTareWeight := CurrentWeight;
  if ActiveScale <> nil then
  begin
    ActiveScale.CurrentWeight := CurrentWeight;
    ActiveScale.TareWeight := ScaleTareWeight;
  end;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoScaleTare',
    'Выполнена тара весов', Name);
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

procedure TWorkTable.DoScaleDrain;
begin
  // TODO: добавить аппаратную команду слива воды после появления поддержки весов.
  CurrentWeight := 0;
  ScaleTareWeight := 0;
  if ActiveScale <> nil then
  begin
    ActiveScale.CurrentWeight := CurrentWeight;
    ActiveScale.TareWeight := ScaleTareWeight;
  end;
  ProtocolManager.AddMessage(pcAction, psWorkTable, 'DoScaleDrain',
    'Выполнен слив воды', Name);
  NotifyOwned(notifyAction, TActionNotification.Create(Ord(FAction)));
end;

procedure TWorkTable.ApplyChannelValues(AChannels: TObjectList<TChannel>; const ACurSec: Double;
  const AImpSecValues: TArray<Double>; const AImpResult: Double);
var
  I: Integer;
  Channel: TChannel;
  ChannelImpSec: Double;
begin
  if AChannels = nil then
    Exit;

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    if Channel = nil then
      Continue;

    if (Length(AImpSecValues) > I) then
      ChannelImpSec := AImpSecValues[I]
    else
      ChannelImpSec := 0;

    Channel.CurSec := ACurSec;
    Channel.ImpSec := ChannelImpSec;
    if AImpResult > 0 then
      Channel.ImpResult := EnsureRange(AImpResult, 0.0, 1.0E12)
    else
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
  end;
end;

    {$ENDREGION 'TWorkTable'}

  {$REGION 'TWorkTableManager'}
{ TWorkTableManager }

{ Creates manager and initializes work table storage container. }
constructor TWorkTableManager.Create(const AIniFileName: string);
begin
  inherited Create;
  FIniFileName := AIniFileName;
  FWorkTables := TObjectList<TWorkTable>.Create(True);
  TPump.Pumps := TObjectList<TPump>.Create(True);
  TWeight.Weights := TObjectList<TWeight>.Create(True);
end;

{ Frees managed work table collection and manager resources. }
destructor TWorkTableManager.Destroy;
begin
  FWorkTables.Free;
  FreeAndNil(TWeight.Weights);
  inherited;
end;

{ Loads managed work tables from configured INI file. }
procedure TWorkTableManager.Load;
var
  Ini: TIniFile;
  ActiveUUID: string;
  ActiveName: string;
  ActiveIndex: Integer;
  I: Integer;
  WorkTable: TWorkTable;
begin
  TWorkTable.Load(FIniFileName, FWorkTables);

  WorkTable := nil;
  ActiveUUID := '';
  ActiveName := '';
  ActiveIndex := -1;

  if (FIniFileName <> '') and FileExists(FIniFileName) then
  begin
    Ini := TIniFile.Create(FIniFileName);
    try
      ActiveUUID := Trim(Ini.ReadString('WorkTables', 'ActiveUUID', ''));
      ActiveName := Trim(Ini.ReadString('WorkTables', 'ActiveName', ''));
      ActiveIndex := Ini.ReadInteger('WorkTables', 'ActiveIndex', -1);
    finally
      Ini.Free;
    end;
  end;

  if (ActiveUUID <> '') and (FWorkTables <> nil) then
    for I := 0 to FWorkTables.Count - 1 do
      if (FWorkTables[I] <> nil) and SameText(FWorkTables[I].UUID, ActiveUUID) then
      begin
        WorkTable := FWorkTables[I];
        Break;
      end;

  if (WorkTable = nil) and (ActiveName <> '') then
    WorkTable := FindWorkTableName(ActiveName);

  if (WorkTable = nil) and (ActiveIndex >= 0) and
     (FWorkTables <> nil) and (ActiveIndex < FWorkTables.Count) then
    WorkTable := FWorkTables[ActiveIndex];

  if (WorkTable = nil) and (FWorkTables <> nil) and
     (FWorkTables.Count > 0) and (FWorkTables[0] <> nil) then
    WorkTable := FWorkTables[0];

  SetActiveWorkTable(WorkTable);
end;

{ Saves managed work tables to configured INI file. }
procedure TWorkTableManager.Save;
var
  Ini: TMemIniFile;
begin
  TWorkTable.Save(FIniFileName, FWorkTables);

  if FIniFileName = '' then
    Exit;

  Ini := TMemIniFile.Create(FIniFileName);
  try
    if (FActiveWorkTable <> nil) and (FWorkTables <> nil) and
       (FWorkTables.IndexOf(FActiveWorkTable) >= 0) then
    begin
      Ini.WriteString('WorkTables', 'ActiveUUID', FActiveWorkTable.UUID);
      Ini.WriteString('WorkTables', 'ActiveName', FActiveWorkTable.Name);
      Ini.WriteInteger('WorkTables', 'ActiveIndex', FWorkTables.IndexOf(FActiveWorkTable));
    end
    else
    begin
      Ini.DeleteKey('WorkTables', 'ActiveUUID');
      Ini.DeleteKey('WorkTables', 'ActiveName');
      Ini.DeleteKey('WorkTables', 'ActiveIndex');
    end;

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TWorkTableManager.AddWorkTable;
 var
  WorkTable: TWorkTable;
  NextID: Integer;
  Existing: TWorkTable;
begin
  NextID := 1;
  while True do
  begin
    Existing := FindWorkTableByID(NextID);
    if Existing = nil then
      Break;
    Inc(NextID);
  end;

  WorkTable := TWorkTable.Create;
  WorkTable.ID := NextID;
  WorkTable.Name := TWorkTable.BuildWorkTableServiceName(WorkTable.ID);
  WorkTable.Text := 'Рабочий стол ' + IntToStr(WorkTable.ID);
  WorkTables.Add(WorkTable);
  WorkTable.Rebind;
end;

procedure TWorkTableManager.AddWorkTable(const WorkTableName: string);
begin
   AddWorkTable;
   WorkTables[WorkTables.Count-1].Name :=  WorkTableName;
end;

procedure TWorkTableManager.SetActiveWorkTable(AWorkTable: TWorkTable);
begin
  if FActiveWorkTable = AWorkTable then
    Exit;

  if (FActiveWorkTable <> nil) and
     ((FWorkTables = nil) or (FWorkTables.IndexOf(FActiveWorkTable) >= 0)) then
    FActiveWorkTable.IsActive := False;

  FActiveWorkTable := AWorkTable;

  if (FActiveWorkTable <> nil) and
     ((FWorkTables = nil) or (FWorkTables.IndexOf(FActiveWorkTable) >= 0)) then
    FActiveWorkTable.IsActive := True;
end;

function TWorkTableManager.DeleteWorkTableByName(
  const AWorkTableName: string): Boolean;
var
  I: Integer;
  WorkTable: TWorkTable;
  WorkTableName: string;
  DeletedMeterValueHashes: TStringList;
  DeletedMeterValueOwners: TStringList;

  procedure AddOwnerName(const AOwnerName: string);
  var
    OwnerName: string;
  begin
    OwnerName := Trim(AOwnerName);
    if (OwnerName <> '') and (DeletedMeterValueOwners.IndexOf(OwnerName) < 0) then
      DeletedMeterValueOwners.Add(OwnerName);
  end;

begin
  Result := False;
  WorkTableName := Trim(AWorkTableName);

  if WorkTableName = '' then
    Exit;

  if FWorkTables = nil then
    Exit;

  // Активный стол мог быть уже удалён другим экраном: не разыменовываем
  // висячую ссылку через SetActiveWorkTable, только проверяем наличие в списке.
  if (FActiveWorkTable <> nil) and (FWorkTables.IndexOf(FActiveWorkTable) < 0) then
    FActiveWorkTable := nil;

  DeletedMeterValueHashes := TStringList.Create;
  DeletedMeterValueOwners := TStringList.Create;
  try
    DeletedMeterValueHashes.Sorted := False;
    DeletedMeterValueHashes.Duplicates := TDuplicates.dupIgnore;
    DeletedMeterValueOwners.Sorted := False;
    DeletedMeterValueOwners.Duplicates := TDuplicates.dupIgnore;

    for I := FWorkTables.Count - 1 downto 0 do
    begin
      WorkTable := FWorkTables[I];

      if WorkTable = nil then
        Continue;

      if SameText(Trim(WorkTable.Name), WorkTableName) or
         SameText(Trim(WorkTable.Text), WorkTableName) then
      begin
        AddOwnerName(WorkTable.Text);
        AddOwnerName(WorkTable.Name);
        AddOwnerName(TWorkTable.BuildWorkTableServiceName(WorkTable.ID));
        AddOwnerName('Рабочий стол ' + IntToStr(WorkTable.ID));

        WorkTable.RemoveMeterValuesFromStorage(DeletedMeterValueHashes);

        if FActiveWorkTable = WorkTable then
          SetActiveWorkTable(nil);

        FWorkTables.Delete(I);

        if FWorkTables.Count = 0 then
          SetActiveWorkTable(nil)
        else if (FActiveWorkTable = nil) or
                (FWorkTables.IndexOf(FActiveWorkTable) < 0) then
        begin
          if I < FWorkTables.Count then
            SetActiveWorkTable(FWorkTables[I])
          else
            SetActiveWorkTable(FWorkTables[FWorkTables.Count - 1]);
        end;

        TMeterValue.DeleteFromFile(DeletedMeterValueHashes, DeletedMeterValueOwners);

        Result := True;
        Break;
      end;
    end;
  finally
    DeletedMeterValueOwners.Free;
    DeletedMeterValueHashes.Free;
  end;
end;

function TWorkTableManager.DeleteWorkTablesByNames: Integer;
var
  I: Integer;
  WorkTable: TWorkTable;
  NamesToDelete: TStringList;
  WorkTableName: string;
begin
  Result := 0;

  if FWorkTables = nil then
    Exit;

  NamesToDelete := TStringList.Create;
  try
    NamesToDelete.Sorted := False;
    NamesToDelete.Duplicates := TDuplicates.dupAccept;

    for I := FWorkTables.Count - 1 downto 0 do
    begin
      WorkTable := FWorkTables[I];
      if WorkTable = nil then
        Continue;

      WorkTableName := Trim(WorkTable.Name);
      if WorkTableName = '' then
        WorkTableName := Trim(WorkTable.Text);

      if WorkTableName <> '' then
        NamesToDelete.Add(WorkTableName);
    end;

    for I := 0 to NamesToDelete.Count - 1 do
      if DeleteWorkTableByName(NamesToDelete[I]) then
        Inc(Result);
  finally
    NamesToDelete.Free;
  end;
end;

function TWorkTableManager.FindWorkTableName(const WorkTableName: string): TWorkTable;
var
  WorkTable: TWorkTable;
begin
  Result := nil;

  if (FWorkTables = nil) or (Trim(WorkTableName) = '') then
    Exit;

  for WorkTable in FWorkTables do
  begin
    if (WorkTable <> nil) and SameText(WorkTable.Name, WorkTableName) then
    begin
      Result := WorkTable;
      Exit;
    end;
  end;
end;

function TWorkTableManager.FindWorkTableByID(const WorkTableID: Integer): TWorkTable;
var
  WorkTable: TWorkTable;
begin
  Result := nil;
  if (FWorkTables = nil) or (WorkTableID <= 0) then
    Exit;

  for WorkTable in FWorkTables do
    if (WorkTable <> nil) and (WorkTable.ID = WorkTableID) then
      Exit(WorkTable);
end;

function TWorkTableManager.FindPumpByName(const APumpName: string): TPump;
var
  WorkTable: TWorkTable;
  Pump: TPump;
begin
  Result := nil;

  if (FWorkTables = nil) or (APumpName = '') then
    Exit;

  for WorkTable in FWorkTables do
  begin
    if (WorkTable = nil) or (WorkTable.Pumps = nil) then
      Continue;

    for Pump in WorkTable.Pumps do
    begin
      if Pump.Name = APumpName then
      begin
        Result := Pump;
        Exit;
      end;
    end;
  end;
end;

function TWorkTableManager.GetChannelFlowCoef(const AChannel: TChannel): Double;

  function IsValidCoef(const AValue: Double): Boolean;
  begin
    Result := (AValue > 0.0) and (Abs(AValue) < MaxDouble);
  end;

var
  ValueCoef: Double;
begin
  Result := 0.0;
  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;

  // Базовый контракт коэффициента для импульсных каналов: имп/л.
  // Device.Coef является паспортным коэффициентом прибора и не зависит от
  // выбранной размерности UI; ValueCoef используем только если паспортного
  // коэффициента нет.
  if Assigned(AChannel.FlowMeter.Device) and IsValidCoef(AChannel.FlowMeter.Device.Coef) then
    Exit(AChannel.FlowMeter.Device.Coef);

  ValueCoef := 0.0;
  if (AChannel.FlowMeter.ValueCoef <> nil) then
    ValueCoef := AChannel.FlowMeter.ValueCoef.GetDoubleValue;
  if IsValidCoef(ValueCoef) then
    Exit(ValueCoef);

  if IsValidCoef(AChannel.FlowMeter.Kp) then
    Result := AChannel.FlowMeter.Kp;
end;

function TWorkTableManager.UpdateDeviceImpSecFromFlowRate(const AWorkTable: TWorkTable;
  const AFlowRate: Double): Double;
var
  Coef: Double;
begin
  Result := 0;
  if (AWorkTable = nil) or (AWorkTable.DeviceChannels.Count = 0) then
    Exit;

  Coef := GetChannelFlowCoef(AWorkTable.DeviceChannels[0]);
  if Coef <= 0 then
    Exit;

  Result := (AFlowRate * Coef) / 3.6;
end;

function TWorkTableManager.UpdateEtalonImpSecFromFlowRate(const AWorkTable: TWorkTable;
  AFlowRate: Double; AEtalonChannels: TObjectList<TChannel>): Double;
var
  FlowRate, Coef: Double;
  I: Integer;
begin
  Result := 0;
  Coef := 0;
  if (AWorkTable = nil) or (AWorkTable.EtalonChannels.Count = 0) then
    Exit;

  if (AEtalonChannels <> nil) and (AEtalonChannels.Count > 0) then
    for I := 0 to AEtalonChannels.Count - 1 do
      Coef := Coef + GetChannelFlowCoef(AEtalonChannels[I])
  else
    for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
      if (AWorkTable.EtalonChannels[I] <> nil) and
         (AWorkTable.EtalonChannels[I].Enabled) then
      begin
        Coef := GetChannelFlowCoef(AWorkTable.EtalonChannels[I]);
        Break;
      end;

  if Coef <= 0 then
    Exit;

  if AFlowRate <> 0 then
    FlowRate := AFlowRate
  else
    FlowRate := AWorkTable.FlowRate.Value.Value;

  Result := (FlowRate * Coef) / 3.6;
end;

function TWorkTableManager.BuildImpSecValuesForChannels(const AWorkTable: TWorkTable;
  AChannels: TObjectList<TChannel>; const AFlowRate, AFallbackImpSec: Double;
  const ASplitByQmax: Boolean; const ASplitByEnabledGroup: Boolean): TArray<Double>;
var
  I, J, GroupKey: Integer;
  Coef, SUM, MaxRatio, ChannelQmax: Double;
begin
  SetLength(Result, 0);
  if (AWorkTable = nil) or (AChannels = nil) then
    Exit;

  SetLength(Result, AChannels.Count);
  for I := 0 to AChannels.Count - 1 do
  begin
    if (AChannels[I] = nil) or (AChannels[I].FlowMeter = nil) or
       (AChannels[I].FlowMeter.Device = nil) then
    begin
      Result[I] := AFallbackImpSec;
      Continue;
    end;

    GroupKey := AChannels[I].Group;
    SUM := 0;
    if ASplitByEnabledGroup or ASplitByQmax then
    begin
      for J := 0 to AChannels.Count - 1 do
        if (AChannels[J] <> nil) and AChannels[J].Enabled and
           (((GroupKey > 0) and (AChannels[J].Group = GroupKey)) or
            ((GroupKey <= 0) and (J = I))) and
           (AChannels[J].FlowMeter <> nil) and (AChannels[J].FlowMeter.Device <> nil) then
          SUM := SUM + AWorkTable.ValueFlowRate.GetDoubleBaseNum(AChannels[J].FlowMeter.Device.Qmax, 4);

      ChannelQmax := AWorkTable.ValueFlowRate.GetDoubleBaseNum(AChannels[I].FlowMeter.Device.Qmax, 4);
      if SUM > 0 then
        MaxRatio := ChannelQmax / SUM
      else
        MaxRatio := 0;
    end
    else
      MaxRatio := 1;

    Coef := GetChannelFlowCoef(AChannels[I]);
    if (not AChannels[I].Enabled) then
      Result[I] := 0
    else if Coef > 0 then
      Result[I] := AFlowRate * MaxRatio * Coef
    else
    begin
      if ProtocolManager <> nil then
        ProtocolManager.AddMessage(pcError, psWorkTable, 'ChannelCoefficientInvalid',
          'Не удалось рассчитать частоту канала',
          Format('ChannelIndex=%d TargetFlowLS=%.6f CoefImpPerLiter=%.6f',
            [I, AFlowRate * MaxRatio, Coef]));
      Result[I] := AFallbackImpSec;
    end;
  end;
end;



procedure TWorkTableManager.UpdateSimulation;

 var
  I : Integer;
 CurrentImp:Double;
 CurrentVolume:Double;
 WorkTable:TWorkTable;
 HasLimits: Boolean;
 LimitReached: Boolean;   // Флаг: достигнут хотя бы один критерий остановки


procedure UpdateRandomTemp(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double; // Случайные приращения температуры и давления
  StableState: RStableInfo;     // Информация о стабильности параметра
begin
  // ============================================================
  // 1. Проверка входных данных
  // ============================================================

  // Если рабочая таблица не задана — выходим
  if AWorkTable = nil then
    Exit;


  // ============================================================
  // 3. Ограничение частоты обновления (не каждый тик таймера)
  // ============================================================

  // Обновляем температуру не постоянно, а раз в несколько секунд
  if (AWorkTable.NextClimateChangeAt = 0) or
     (Now >= AWorkTable.NextClimateChangeAt) then
  begin

    // ----------------------------------------------------------
    // 3.1 Генерация случайных изменений (шум системы)
    // ----------------------------------------------------------

    // Температура ±0.15
    TempDelta := (Random * 0.30) - 0.15;

    // Давление ±0.03 (сейчас не используется)
    PressDelta := (Random * 0.06) - 0.03;


    // ----------------------------------------------------------
    // 3.2 Регулирование температуры (имитация ПИД-подобного поведения)
    // ----------------------------------------------------------

    // Если система регулирования запущена
    if (AWorkTable.FluidTemp.IsRunning) then
    begin

      // Если температура ещё НЕ стабилизировалась
      if not AWorkTable.FluidTemp.IsStable(StableState) then
      begin

        // Если текущая температура меньше заданной → "нагреваем"
        if AWorkTable.FluidTemp.Value.Value < AWorkTable.FluidTemp.ValueSet.Value then
        begin
          AWorkTable.FluidTemp.BeforeValue :=
            AWorkTable.FluidTemp.BeforeValue + 1;

          AWorkTable.FluidTemp.AfterValue :=
            AWorkTable.FluidTemp.AfterValue + 1;
        end
        else
        begin
          // Иначе → "охлаждаем"
          AWorkTable.FluidTemp.BeforeValue :=
            AWorkTable.FluidTemp.BeforeValue - 1;

          AWorkTable.FluidTemp.AfterValue :=
            AWorkTable.FluidTemp.AfterValue - 1;
        end;

      end;

    end;


    // ----------------------------------------------------------
    // 3.3 Добавление случайного шума (реалистичность)
    // ----------------------------------------------------------

    // Если задано целевое значение температуры
    if AWorkTable.FluidTemp.ValueSet.Value <> 0 then
    begin
      // Добавляем небольшое случайное отклонение
      // и ограничиваем диапазон допустимых значений

      AWorkTable.FluidTemp.BeforeValue :=
        EnsureRange(
          AWorkTable.FluidTemp.BeforeValue + TempDelta,
          -50.0, 150.0);

      AWorkTable.FluidTemp.AfterValue :=
        EnsureRange(
          AWorkTable.FluidTemp.AfterValue + TempDelta,
          -50.0, 150.0);
    end;

    // ----------------------------------------------------------
    // 3.5 Планирование следующего изменения
    // ----------------------------------------------------------

    // Следующее обновление через 3–4 секунды
    AWorkTable.NextClimateChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
  end;
end;

procedure UpdateRandomPress(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double;
begin
  if AWorkTable = nil then
    Exit;


  if (AWorkTable.NextPressChangeAt = 0) or (Now >= AWorkTable.NextPressChangeAt) then
  begin

    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;
    if (AWorkTable.FluidPress.IsRunning) then
    begin
      if  (AWorkTable.FluidPress.Value.value<AWorkTable.FluidPress.ValueSet.value) then
      begin
        AWorkTable.FluidPress.BeforeValue:=(AWorkTable.FluidPress.BeforeValue+1);
        AWorkTable.FluidPress.AfterValue:=(AWorkTable.FluidPress.AfterValue+1);
      end
      else if  (AWorkTable.FluidPress.Value.value>AWorkTable.FluidPress.ValueSet.value)  then
      begin
        AWorkTable.FluidPress.BeforeValue:=(AWorkTable.FluidPress.BeforeValue-0.3);
        AWorkTable.FluidPress.AfterValue:=(AWorkTable.FluidPress.AfterValue-0.3);
      end;


    end;
      if  (AWorkTable.FluidPress.Value.value<AWorkTable.FluidPress.ValueSet.value)  then
      begin
        AWorkTable.FluidPress.BeforeValue:=(EnsureRange(AWorkTable.FluidPress.BeforeValue + 0.1, -50.0, 150.0));
        AWorkTable.FluidPress.AfterValue:=(EnsureRange(AWorkTable.FluidPress.AfterValue + 0.1, -50.0, 150.0));
      end;
      if AWorkTable.FluidPress.ValueSet.value<>0 then
      begin
        AWorkTable.FluidPress.BeforeValue:=(EnsureRange(AWorkTable.FluidPress.BeforeValue + PressDelta, -50.0, 150.0));
        AWorkTable.FluidPress.AfterValue:=(EnsureRange(AWorkTable.FluidPress.AfterValue + PressDelta, -50.0, 150.0));
      end;




      //AWorkTable.Temp := EnsureRange(AWorkTable.Temp + TempDelta, -50.0, 150.0);
      //AWorkTable.Press := EnsureRange(AWorkTable.Press + PressDelta, 0.0, 10.0);

      AWorkTable.NextPressChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
   end;
end;

procedure UpdateRandomFreq(const AWorkTable: TWorkTable);
var
  Pump: tPump;             // Активный насос (исполнитель)
  Freq: Double;
begin
  Pump := AWorkTable.ActivePump;   // Насос (может быть nil)


  if Pump = nil then
    Exit;


   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (AWorkTable.NextFreqChangeAt = 0) or (Now >= AWorkTable.NextFreqChangeAt) then
  begin
    Freq := (Random * 10);

   if Pump.IsRunning = true then
    begin

      Pump.Value.value:=(EnsureRange(Pump.Value.value + Freq,Pump.Value.value , Pump.ValueSet.value));


    end
    else
    begin
      //Pump.ValueSet:=(Pump.ValueSet);
      Pump.Value.value:=0;
    end;



    AWorkTable.NextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
   end;
end;

procedure ResetChannelSimulation(const AChannel: TChannel; const AResetImpResult: Boolean);
begin
  if AChannel = nil then
    Exit;

  AChannel.CurSec := 0;
  AChannel.ImpSec := 0;
  if AResetImpResult then
    AChannel.ImpResult := 0;
  AChannel.SimulationStartImpSec := 0;
  AChannel.SimulationTargetImpSec := 0;
  AChannel.SimulationRampStartTimeMs := 0;
  AChannel.SimulationRampDurationSec := 0;
  AChannel.SimulationRampActive := False;
  AChannel.SimulationLastProgressLogMs := 0;
end;

function IsSimulationChannelEnabled(const AChannel: TChannel): Boolean;
begin
  Result := (AChannel <> nil) and AChannel.Enabled and (AChannel.State <> osDeleted) and
    (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.Device <> nil);
end;

function GetCurrentTimeMs: Double;
begin
  Result := Now * MSecsPerDay;
end;

function CalculateRampDurationByFlowDelta(const AStartFlowLS, ATargetFlowLS: Double): Double;
const
  MIN_SIMULATION_RAMP_DURATION_SEC = 0.3;
  SIMULATION_RAMP_MAX_DURATION_SEC = 10.0;
  SIMULATION_RAMP_FLOW_SPEED_LS_PER_SEC = 0.666667;
var
  FlowDeltaLS: Double;
begin
  FlowDeltaLS := Abs(ATargetFlowLS - AStartFlowLS);
  if SIMULATION_RAMP_FLOW_SPEED_LS_PER_SEC <= 0 then
    Result := SIMULATION_RAMP_MAX_DURATION_SEC
  else
    Result := FlowDeltaLS / SIMULATION_RAMP_FLOW_SPEED_LS_PER_SEC;
  Result := EnsureRange(Result, MIN_SIMULATION_RAMP_DURATION_SEC,
    SIMULATION_RAMP_MAX_DURATION_SEC);
end;

function CalculateChannelFlowLS(const AChannel: TChannel): Double;
var
  ChannelCoef: Double;
begin
  Result := 0;
  ChannelCoef := GetChannelFlowCoef(AChannel);
  if ChannelCoef > 0 then
    Result := AChannel.ImpSec / ChannelCoef;
end;

procedure LogSimulationRamp(const AEvent, AChannelKind: string; const AChannelIndex: Integer;
  const ADetails: string);
begin
  if ProtocolManager <> nil then
    ProtocolManager.AddMessage(pcState, psWorkTable, AEvent,
      'Channel simulation',
      Format('ChannelKind=%s ChannelIndex=%d %s', [AChannelKind, AChannelIndex, ADetails]));
end;

procedure UpdateChannelRamp(const AChannel: TChannel; const AChannelKind: string;
  const AChannelIndex: Integer; const ATargetImpSec, ACurrentTimeMs: Double;
  const AStartDetails: string);
const
  TARGET_EPSILON = 1E-6;
  SIMULATION_RAMP_MAX_DURATION_SEC = 10.0;
var
  ElapsedSec: Double;
  Progress: Double;
  NewImpSec: Double;
  ChannelCoef: Double;
  StartFlowLS: Double;
  TargetFlowLS: Double;
  FlowDeltaLS: Double;
begin
  if AChannel = nil then
    Exit;

  if not SameValue(AChannel.SimulationTargetImpSec, ATargetImpSec, TARGET_EPSILON) then
  begin
    AChannel.SimulationStartImpSec := AChannel.ImpSec;
    AChannel.SimulationTargetImpSec := Max(0.0, ATargetImpSec);
    ChannelCoef := GetChannelFlowCoef(AChannel);
    if ChannelCoef > 0 then
    begin
      StartFlowLS := AChannel.SimulationStartImpSec / ChannelCoef;
      TargetFlowLS := AChannel.SimulationTargetImpSec / ChannelCoef;
    end
    else
    begin
      StartFlowLS := 0.0;
      TargetFlowLS := 0.0;
    end;
    FlowDeltaLS := Abs(TargetFlowLS - StartFlowLS);
    AChannel.SimulationRampStartTimeMs := ACurrentTimeMs;
    AChannel.SimulationRampDurationSec := CalculateRampDurationByFlowDelta(StartFlowLS,
      TargetFlowLS);
    AChannel.SimulationRampActive := not SameValue(AChannel.SimulationStartImpSec,
      AChannel.SimulationTargetImpSec, TARGET_EPSILON);
    AChannel.SimulationLastProgressLogMs := 0;
    LogSimulationRamp('SimulationRampStarted', AChannelKind, AChannelIndex,
      Format('%s StartFlowLS=%.6f TargetFlowLS=%.6f FlowDeltaLS=%.6f RampFlowSpeedLSPerSec=%.6f StartImpSec=%.6f TargetImpSec=%.6f CoefImpPerLiter=%.6f RampDurationSec=%.3f',
        [AStartDetails, StartFlowLS, TargetFlowLS, FlowDeltaLS, 0.666667,
         AChannel.SimulationStartImpSec, AChannel.SimulationTargetImpSec,
         ChannelCoef, AChannel.SimulationRampDurationSec]));
  end;

  if AChannel.SimulationRampActive then
  begin
    ElapsedSec := Max(0.0, (ACurrentTimeMs - AChannel.SimulationRampStartTimeMs) / 1000.0);
    if AChannel.SimulationRampDurationSec > 0 then
      Progress := EnsureRange(ElapsedSec / AChannel.SimulationRampDurationSec, 0.0, 1.0)
    else
      Progress := 1.0;

    NewImpSec := AChannel.SimulationStartImpSec +
      (AChannel.SimulationTargetImpSec - AChannel.SimulationStartImpSec) * Progress;
    AChannel.ImpSec := Max(0.0, NewImpSec);

    if ((AChannel.SimulationLastProgressLogMs = 0) or
        (ACurrentTimeMs - AChannel.SimulationLastProgressLogMs >= 1000.0)) and
       (Progress < 1.0) then
    begin
      AChannel.SimulationLastProgressLogMs := ACurrentTimeMs;
      LogSimulationRamp('SimulationRampProgress', AChannelKind, AChannelIndex,
        Format('CurrentImpSec=%.6f TargetImpSec=%.6f ElapsedSec=%.3f DurationSec=%.3f ProgressPercent=%.2f CalculatedFlowLS=%.6f',
          [AChannel.ImpSec, AChannel.SimulationTargetImpSec, ElapsedSec,
           AChannel.SimulationRampDurationSec, Progress * 100.0, CalculateChannelFlowLS(AChannel)]));
    end;

    if Progress >= 1.0 then
    begin
      AChannel.ImpSec := Max(0.0, AChannel.SimulationTargetImpSec);
      AChannel.SimulationRampActive := False;
      LogSimulationRamp('SimulationRampCompleted', AChannelKind, AChannelIndex,
        Format('ElapsedSec=%.3f TargetImpSec=%.6f ActualImpSec=%.6f CalculatedFlowLS=%.6f',
          [ElapsedSec, AChannel.SimulationTargetImpSec, AChannel.ImpSec,
           CalculateChannelFlowLS(AChannel)]));
    end
    else if ElapsedSec > SIMULATION_RAMP_MAX_DURATION_SEC + 0.5 then
      LogSimulationRamp('SimulationRampDeadlineExceeded', AChannelKind, AChannelIndex,
        Format('ElapsedSec=%.3f CurrentImpSec=%.6f TargetImpSec=%.6f',
          [ElapsedSec, AChannel.ImpSec, AChannel.SimulationTargetImpSec]));
  end;
end;

procedure ApplySimpleSimulationNoise(const AChannel: TChannel; const AChannelKind: string;
  const AChannelIndex: Integer; const ACurrentTimeMs, ANoisePercent: Double;
  const ADeviceReady: Boolean);
var
  TargetImpSec: Double;
  AllowedDelta: Double;
  RandomStep: Double;
  BeforeImpSec: Double;
  AfterImpSec: Double;
begin
  if (AChannel = nil) or AChannel.SimulationRampActive then
    Exit;

  TargetImpSec := AChannel.SimulationTargetImpSec;
  if TargetImpSec <= 0 then
    Exit;

  BeforeImpSec := AChannel.ImpSec;
  AllowedDelta := EnsureRange(Abs(TargetImpSec) * ANoisePercent / 100.0, 0.1, 30.0);
  RandomStep := (Random * 2.0 - 1.0) * AllowedDelta;
  AfterImpSec := EnsureRange(BeforeImpSec + RandomStep,
    Max(0.0, TargetImpSec - AllowedDelta), TargetImpSec + AllowedDelta);
  AChannel.ImpSec := AfterImpSec;

  if (ProtocolManager <> nil) and
     ((AChannel.SimulationLastProgressLogMs = 0) or
      (ACurrentTimeMs - AChannel.SimulationLastProgressLogMs >= 1000.0)) then
  begin
    AChannel.SimulationLastProgressLogMs := ACurrentTimeMs;
    ProtocolManager.AddMessage(pcState, psWorkTable, 'SimulationNoise',
      'Simple channel simulation noise',
      Format('ChannelKind=%s ChannelIndex=%d DeviceReady=%s TargetImpSec=%.6f BeforeImpSec=%.6f RandomStep=%.6f AllowedDelta=%.6f AfterImpSec=%.6f',
        [AChannelKind, AChannelIndex, IfThen(ADeviceReady, 'True', 'False'),
         TargetImpSec, BeforeImpSec, RandomStep, AllowedDelta, AfterImpSec]));
  end;
end;

procedure UpdateChannelCurSec(const AChannel: TChannel; const ADeltaRange: Double);
var
  CurDelta: Double;
begin
  if AChannel = nil then
    Exit;

  CurDelta := (Random * ADeltaRange * 2.0) - ADeltaRange;
  AChannel.CurSec := EnsureRange(AChannel.CurSec + CurDelta, 0.0, 1000.0);
end;

function CalculateEtalonTargetImpSecValues(const AWorkTable: TWorkTable;
  const AEnabledEtalonChannels: TObjectList<TChannel>; const ATargetFlow: Double): TArray<Double>;
begin
  Result := BuildImpSecValuesForChannels(AWorkTable, AEnabledEtalonChannels,
    ATargetFlow, 0, True, False);
end;

procedure UpdateEtalonChannelSignals(const AWorkTable: TWorkTable;
  const AEnabledEtalonChannels: TObjectList<TChannel>; const ATargetImpSecValues: TArray<Double>;
  const ACurrentTimeMs, ATargetFlow, AOldTargetFlow: Double);
var
  I: Integer;
  Channel: TChannel;
  ChannelCoef: Double;
  ChannelFlowLS: Double;
  CoefRaw: Double;
  CoefDimension: string;
begin
  for I := 0 to AEnabledEtalonChannels.Count - 1 do
  begin
    Channel := AEnabledEtalonChannels[I];
    ChannelCoef := GetChannelFlowCoef(Channel);
    if ChannelCoef > 0 then
      ChannelFlowLS := ATargetImpSecValues[I] / ChannelCoef
    else
      ChannelFlowLS := 0.0;
    CoefRaw := 0.0;
    CoefDimension := '';
    if (Channel.FlowMeter <> nil) and (Channel.FlowMeter.ValueCoef <> nil) then
    begin
      CoefRaw := Channel.FlowMeter.ValueCoef.GetDoubleValue;
      CoefDimension := Channel.FlowMeter.ValueCoef.GetDimName;
    end;

    if (ProtocolManager <> nil) and
       (not SameValue(Channel.SimulationTargetImpSec, ATargetImpSecValues[I], 1E-6)) then
      ProtocolManager.AddMessage(pcState, psWorkTable, 'EtalonTargetDiagnostic',
        'Etalon target impulse diagnostic',
        Format('ChannelIndex=%d TargetFlowTotalLS=%.6f ChannelFlowLS=%.6f CoefRaw=%.6f CoefDimension=%s CoefImpPerLiter=%.6f StartImpSec=%.6f TargetImpSec=%.6f ExpectedFlowFromTargetImpSec=%.6f',
          [AWorkTable.EtalonChannels.IndexOf(Channel), ATargetFlow,
           ChannelFlowLS, CoefRaw, CoefDimension, ChannelCoef, Channel.ImpSec,
           ATargetImpSecValues[I], ChannelFlowLS]));
    UpdateChannelRamp(Channel, 'Etalon', AWorkTable.EtalonChannels.IndexOf(Channel),
      ATargetImpSecValues[I], ACurrentTimeMs,
      Format('Reason=WorkTableTargetChanged TargetSource=WorkTableSetFlow TargetFlowBaseLS=%.6f OldTargetFlowBaseLS=%.6f PointUUID= DeviceReady=%s',
        [ATargetFlow, AOldTargetFlow, IfThen(AWorkTable.DeviceReady, 'True', 'False')]));
    ApplySimpleSimulationNoise(Channel, 'Etalon', AWorkTable.EtalonChannels.IndexOf(Channel),
      ACurrentTimeMs, 1.0, AWorkTable.DeviceReady);
    UpdateChannelCurSec(Channel, 0.03);
  end;
end;

function CalculateActualEtalonFlow(const AWorkTable: TWorkTable): Double;
var
  I, ActiveEtalonIndex: Integer;
  GroupKey: Integer;
  ChannelCoef: Double;
begin
  Result := 0;
  GroupKey := 0;
  ActiveEtalonIndex := -1;
  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
    if IsSimulationChannelEnabled(AWorkTable.EtalonChannels[I]) then
    begin
      GroupKey := AWorkTable.EtalonChannels[I].Group;
      ActiveEtalonIndex := I;
      Break;
    end;

  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
    if IsSimulationChannelEnabled(AWorkTable.EtalonChannels[I]) and
       (((GroupKey > 0) and (AWorkTable.EtalonChannels[I].Group = GroupKey)) or
        ((GroupKey <= 0) and (I = ActiveEtalonIndex))) then
    begin
      ChannelCoef := GetChannelFlowCoef(AWorkTable.EtalonChannels[I]);
      if ChannelCoef > 0 then
        Result := Result + AWorkTable.EtalonChannels[I].ImpSec / ChannelCoef;
    end;
end;

procedure UpdateDeviceChannelSignals(const AWorkTable: TWorkTable; const ATargetFlow, AOldTargetFlow: Double;
  const ACurrentTimeMs: Double);
var
  I: Integer;
  Channel: TChannel;
  EnabledDeviceChannels: TObjectList<TChannel>;
  TargetImpSecValues: TArray<Double>;
  TargetImpSec: Double;
begin
  EnabledDeviceChannels := TObjectList<TChannel>.Create(False);
  try
    for I := 0 to AWorkTable.DeviceChannels.Count - 1 do
    begin
      Channel := AWorkTable.DeviceChannels[I];
      if IsSimulationChannelEnabled(Channel) then
        EnabledDeviceChannels.Add(Channel)
      else if Channel <> nil then
        ResetChannelSimulation(Channel, True);
    end;

    if AWorkTable.DeviceReady then
    begin
      for I := 0 to EnabledDeviceChannels.Count - 1 do
      begin
        Channel := EnabledDeviceChannels[I];
        if not Channel.SimulationRampActive then
          Channel.SimulationTargetImpSec := Channel.ImpSec;
        ApplySimpleSimulationNoise(Channel, 'Device', AWorkTable.DeviceChannels.IndexOf(Channel),
          ACurrentTimeMs, 1.0, AWorkTable.DeviceReady);
        UpdateChannelCurSec(Channel, 0.3);
      end;
    end
    else
    begin
      TargetImpSecValues := BuildImpSecValuesForChannels(AWorkTable,
        EnabledDeviceChannels, ATargetFlow, 0, False, True);
      for I := 0 to EnabledDeviceChannels.Count - 1 do
      begin
        Channel := EnabledDeviceChannels[I];
        TargetImpSec := TargetImpSecValues[I];
        UpdateChannelRamp(Channel, 'Device', AWorkTable.DeviceChannels.IndexOf(Channel),
          TargetImpSec, ACurrentTimeMs,
          Format('Reason=WorkTableTargetChanged TargetSource=WorkTableSetFlow TargetFlowBaseLS=%.6f OldTargetFlowBaseLS=%.6f PointUUID= DeviceReady=%s',
            [ATargetFlow, AOldTargetFlow, IfThen(AWorkTable.DeviceReady, 'True', 'False')]));
        ApplySimpleSimulationNoise(Channel, 'Device', AWorkTable.DeviceChannels.IndexOf(Channel),
          ACurrentTimeMs, 1.0, AWorkTable.DeviceReady);
        UpdateChannelCurSec(Channel, 0.3);
      end;
    end;
  finally
    EnabledDeviceChannels.Free;
  end;
end;

procedure ResetDisabledChannelSignals(const AWorkTable: TWorkTable);
var
  I: Integer;
begin
  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
    if (AWorkTable.EtalonChannels[I] <> nil) and
       (not IsSimulationChannelEnabled(AWorkTable.EtalonChannels[I])) then
      ResetChannelSimulation(AWorkTable.EtalonChannels[I], True);
end;

procedure AccumulateChannelImpResult(const AChannels: TObjectList<TChannel>; const ADeltaTimeSec: Double);
var
  I: Integer;
  Channel: TChannel;
begin
  if AChannels = nil then
    Exit;

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    if IsSimulationChannelEnabled(Channel) then
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec * ADeltaTimeSec, 0.0, 1.0E12);
  end;
end;

procedure LogFlowUnitsDiagnostic(const AWorkTable: TWorkTable; const ABaseTargetFlowLS: Double);
const
  TARGET_EPSILON = 1E-6;
var
  UnitName: string;
  DisplayedSetValue: Double;
  EtalonValueFlowLS: Double;
  DeviceValueFlowLS: Double;
  DisplayedEtalonFlow: Double;
  DisplayedDeviceFlow: Double;
begin
  if (AWorkTable = nil) or (AWorkTable.ValueFlowRate = nil) or (ProtocolManager = nil) then
    Exit;

  if SameValue(AWorkTable.SimulationLastFlowUnitsLogTarget, ABaseTargetFlowLS, TARGET_EPSILON) then
    Exit;

  AWorkTable.SimulationLastFlowUnitsLogTarget := ABaseTargetFlowLS;
  UnitName := AWorkTable.ValueFlowRate.GetDimName;
  DisplayedSetValue := AWorkTable.ValueFlowRate.GetDoubleNum(ABaseTargetFlowLS,
    AWorkTable.ValueFlowRate.CurrentDimIndex);

  EtalonValueFlowLS := 0;
  if (AWorkTable.EtalonChannels.Count > 0) and (AWorkTable.EtalonChannels[0] <> nil) and
     (AWorkTable.EtalonChannels[0].FlowMeter <> nil) and
     (AWorkTable.EtalonChannels[0].FlowMeter.ValueFlow <> nil) then
    EtalonValueFlowLS := AWorkTable.EtalonChannels[0].FlowMeter.ValueFlow.GetDoubleValue;

  DeviceValueFlowLS := 0;
  if (AWorkTable.DeviceChannels.Count > 0) and (AWorkTable.DeviceChannels[0] <> nil) and
     (AWorkTable.DeviceChannels[0].FlowMeter <> nil) and
     (AWorkTable.DeviceChannels[0].FlowMeter.ValueFlow <> nil) then
    DeviceValueFlowLS := AWorkTable.DeviceChannels[0].FlowMeter.ValueFlow.GetDoubleValue;

  DisplayedEtalonFlow := AWorkTable.ValueFlowRate.GetDoubleNum(EtalonValueFlowLS,
    AWorkTable.ValueFlowRate.CurrentDimIndex);
  DisplayedDeviceFlow := AWorkTable.ValueFlowRate.GetDoubleNum(DeviceValueFlowLS,
    AWorkTable.ValueFlowRate.CurrentDimIndex);

  ProtocolManager.AddMessage(pcState, psWorkTable, 'FlowUnitsDiagnostic',
    'Flow unit conversion diagnostic',
    Format('DisplayedSetValue=%.6f SelectedUnit=%s BaseTargetFlowLS=%.6f EtalonValueFlowLS=%.6f DisplayedEtalonFlow=%.6f DeviceValueFlowLS=%.6f DisplayedDeviceFlow=%.6f',
      [DisplayedSetValue, UnitName, ABaseTargetFlowLS, EtalonValueFlowLS,
       DisplayedEtalonFlow, DeviceValueFlowLS, DisplayedDeviceFlow]));
end;

procedure UpdateChannelSimulation(const AWorkTable: TWorkTable);
const
  MAX_DELTA_TIME_SEC = 1.0;
var
  I: Integer;
  CurrentTimeMs: Double;
  DeltaTimeSec: Double;
  TargetFlow: Double;
  OldTargetFlow: Double;
  EnabledEtalonChannels: TObjectList<TChannel>;
  EtalonTargetImpSecValues: TArray<Double>;
begin
  if (AWorkTable = nil) or (AWorkTable.FlowRate = nil) or (not AWorkTable.FlowRate.IsRunning) then
    Exit;

  CurrentTimeMs := GetCurrentTimeMs;
  if AWorkTable.SimulationLastUpdateTimeMs > 0 then
    DeltaTimeSec := EnsureRange((CurrentTimeMs - AWorkTable.SimulationLastUpdateTimeMs) / 1000.0,
      0.0, MAX_DELTA_TIME_SEC)
  else
    DeltaTimeSec := 1.0;
  AWorkTable.SimulationLastUpdateTimeMs := CurrentTimeMs;
  AWorkTable.Time := AWorkTable.Time + DeltaTimeSec;

  TargetFlow := AWorkTable.FlowRate.ValueSet.Value;
  OldTargetFlow := AWorkTable.SimulationTargetFlowBase;
  LogFlowUnitsDiagnostic(AWorkTable, TargetFlow);
  EnabledEtalonChannels := TObjectList<TChannel>.Create(False);
  try
    for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
      if IsSimulationChannelEnabled(AWorkTable.EtalonChannels[I]) then
        EnabledEtalonChannels.Add(AWorkTable.EtalonChannels[I]);

    EtalonTargetImpSecValues := CalculateEtalonTargetImpSecValues(AWorkTable,
      EnabledEtalonChannels, TargetFlow);
    UpdateEtalonChannelSignals(AWorkTable, EnabledEtalonChannels,
      EtalonTargetImpSecValues, CurrentTimeMs, TargetFlow, OldTargetFlow);
  finally
    EnabledEtalonChannels.Free;
  end;

  UpdateDeviceChannelSignals(AWorkTable, TargetFlow, OldTargetFlow, CurrentTimeMs);
  AWorkTable.SimulationTargetFlowBase := TargetFlow;
  AccumulateChannelImpResult(AWorkTable.EtalonChannels, DeltaTimeSec);
  AccumulateChannelImpResult(AWorkTable.DeviceChannels, DeltaTimeSec);
  ResetDisabledChannelSignals(AWorkTable);
end;

procedure ResetDisabledChannelSignals(const AWorkTable: TWorkTable);
var
  I: Integer;
begin
  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
    if (AWorkTable.EtalonChannels[I] <> nil) and
       (not IsSimulationChannelEnabled(AWorkTable.EtalonChannels[I])) then
      ResetChannelSimulation(AWorkTable.EtalonChannels[I], True);
end;

procedure AccumulateChannelImpResult(const AChannels: TObjectList<TChannel>; const ADeltaTimeSec: Double);
var
  I: Integer;
  Channel: TChannel;
begin
  if AChannels = nil then
    Exit;

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    if IsSimulationChannelEnabled(Channel) then
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec * ADeltaTimeSec, 0.0, 1.0E12);
  end;
end;

procedure LogFlowUnitsDiagnostic(const AWorkTable: TWorkTable; const ABaseTargetFlowLS: Double);
const
  TARGET_EPSILON = 1E-6;
var
  UnitName: string;
  DisplayedSetValue: Double;
  EtalonValueFlowLS: Double;
  DeviceValueFlowLS: Double;
  DisplayedEtalonFlow: Double;
  DisplayedDeviceFlow: Double;
begin
  if (AWorkTable = nil) or (AWorkTable.ValueFlowRate = nil) or (ProtocolManager = nil) then
    Exit;

  if SameValue(AWorkTable.SimulationLastFlowUnitsLogTarget, ABaseTargetFlowLS, TARGET_EPSILON) then
    Exit;

  AWorkTable.SimulationLastFlowUnitsLogTarget := ABaseTargetFlowLS;
  UnitName := AWorkTable.ValueFlowRate.GetDimName;
  DisplayedSetValue := AWorkTable.ValueFlowRate.GetDoubleNum(ABaseTargetFlowLS,
    AWorkTable.ValueFlowRate.CurrentDimIndex);

  EtalonValueFlowLS := 0;
  if (AWorkTable.EtalonChannels.Count > 0) and (AWorkTable.EtalonChannels[0] <> nil) and
     (AWorkTable.EtalonChannels[0].FlowMeter <> nil) and
     (AWorkTable.EtalonChannels[0].FlowMeter.ValueFlow <> nil) then
    EtalonValueFlowLS := AWorkTable.EtalonChannels[0].FlowMeter.ValueFlow.GetDoubleValue;

  DeviceValueFlowLS := 0;
  if (AWorkTable.DeviceChannels.Count > 0) and (AWorkTable.DeviceChannels[0] <> nil) and
     (AWorkTable.DeviceChannels[0].FlowMeter <> nil) and
     (AWorkTable.DeviceChannels[0].FlowMeter.ValueFlow <> nil) then
    DeviceValueFlowLS := AWorkTable.DeviceChannels[0].FlowMeter.ValueFlow.GetDoubleValue;

  DisplayedEtalonFlow := AWorkTable.ValueFlowRate.GetDoubleNum(EtalonValueFlowLS,
    AWorkTable.ValueFlowRate.CurrentDimIndex);
  DisplayedDeviceFlow := AWorkTable.ValueFlowRate.GetDoubleNum(DeviceValueFlowLS,
    AWorkTable.ValueFlowRate.CurrentDimIndex);

  ProtocolManager.AddMessage(pcState, psWorkTable, 'FlowUnitsDiagnostic',
    'Flow unit conversion diagnostic',
    Format('DisplayedSetValue=%.6f SelectedUnit=%s BaseTargetFlowLS=%.6f EtalonValueFlowLS=%.6f DisplayedEtalonFlow=%.6f DeviceValueFlowLS=%.6f DisplayedDeviceFlow=%.6f',
      [DisplayedSetValue, UnitName, ABaseTargetFlowLS, EtalonValueFlowLS,
       DisplayedEtalonFlow, DeviceValueFlowLS, DisplayedDeviceFlow]));
end;

procedure UpdateChannelSimulation(const AWorkTable: TWorkTable);
const
  MAX_DELTA_TIME_SEC = 1.0;
var
  I: Integer;
  CurrentTimeMs: Double;
  DeltaTimeSec: Double;
  TargetFlow: Double;
  OldTargetFlow: Double;
  EnabledEtalonChannels: TObjectList<TChannel>;
  EtalonTargetImpSecValues: TArray<Double>;
begin
  if (AWorkTable = nil) or (AWorkTable.FlowRate = nil) or (not AWorkTable.FlowRate.IsRunning) then
    Exit;

  CurrentTimeMs := GetCurrentTimeMs;
  if AWorkTable.SimulationLastUpdateTimeMs > 0 then
    DeltaTimeSec := EnsureRange((CurrentTimeMs - AWorkTable.SimulationLastUpdateTimeMs) / 1000.0,
      0.0, MAX_DELTA_TIME_SEC)
  else
    DeltaTimeSec := 1.0;
  AWorkTable.SimulationLastUpdateTimeMs := CurrentTimeMs;
  AWorkTable.Time := AWorkTable.Time + DeltaTimeSec;

  TargetFlow := AWorkTable.FlowRate.ValueSet.Value;
  OldTargetFlow := AWorkTable.SimulationTargetFlowBase;
  LogFlowUnitsDiagnostic(AWorkTable, TargetFlow);
  EnabledEtalonChannels := TObjectList<TChannel>.Create(False);
  try
    for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
      if IsSimulationChannelEnabled(AWorkTable.EtalonChannels[I]) then
        EnabledEtalonChannels.Add(AWorkTable.EtalonChannels[I]);

    EtalonTargetImpSecValues := CalculateEtalonTargetImpSecValues(AWorkTable,
      EnabledEtalonChannels, TargetFlow);
    UpdateEtalonChannelSignals(AWorkTable, EnabledEtalonChannels,
      EtalonTargetImpSecValues, CurrentTimeMs, TargetFlow, OldTargetFlow);
  finally
    EnabledEtalonChannels.Free;
  end;

  UpdateDeviceChannelSignals(AWorkTable, TargetFlow, OldTargetFlow, CurrentTimeMs);
  AWorkTable.SimulationTargetFlowBase := TargetFlow;
  AccumulateChannelImpResult(AWorkTable.EtalonChannels, DeltaTimeSec);
  AccumulateChannelImpResult(AWorkTable.DeviceChannels, DeltaTimeSec);
  ResetDisabledChannelSignals(AWorkTable);
end;

begin

     for WorkTable in WorkTableManager.WorkTables do
   begin

  // ============================================================
  // 2. Эмуляция физического процесса (стенд)
  // ============================================================

  // Обновление частоты насоса (имитация работы)
  UpdateRandomFreq(WorkTable);

  // Обновление климатических параметров (температура и др.)
  UpdateRandomTemp(WorkTable);

  // Обновление давления
  UpdateRandomPress(WorkTable);


  // ============================================================
  // 3. Машина состояний измерения
  // ============================================================

  case WorkTable.State of

    // ------------------------------------------------------------
    // Начальное состояние → переход в режим ожидания
    // ------------------------------------------------------------
    swtNONE:
      WorkTable.State := swtSTANDBY;


    // ------------------------------------------------------------
    // Ожидание → считаем, что система подключена
    // ------------------------------------------------------------
    swtSTANDBY:
      WorkTable.State := swtCONNECTED;


    // ------------------------------------------------------------
    // Запуск мониторинга
    // ------------------------------------------------------------
    swtSTARTMONITOR:
      WorkTable.State := swtSTARTMONITORWAIT;


    // ------------------------------------------------------------
    // Ожидание запуска мониторинга → переход в мониторинг
    // ------------------------------------------------------------
    swtSTARTMONITORWAIT:
      WorkTable.State:= swtMONITOR;


    // ------------------------------------------------------------
    // Мониторинг (наблюдение без измерения)
    // ------------------------------------------------------------
    swtMONITOR:
      UpdateChannelSimulation(WorkTable); // обновление показаний


    // ------------------------------------------------------------
    // Остановка мониторинга или конфигурация
    // → возвращаемся в подключённое состояние
    // ------------------------------------------------------------
    swtSTOPMONITOR,
    swtCONFIGED:
      WorkTable.State := swtCONNECTED;


    // ------------------------------------------------------------
    // Запуск теста
    // ------------------------------------------------------------
    swtSTARTTEST:
      WorkTable.State := swtSTARTWAIT;


    // ------------------------------------------------------------
    // Ожидание старта → переход к выполнению
    // ------------------------------------------------------------
    swtSTARTWAIT:
      WorkTable.State := swtEXECUTE;


    // ============================================================
    // 4. Основной процесс измерения
    // ============================================================
    swtEXECUTE:
    begin
      // Обновление сигналов (имитация работы датчиков)
      UpdateChannelSimulation(WorkTable);


      // ----------------------------------------------------------
      // 4.1 Расчёт текущих импульсов
      // ----------------------------------------------------------

      CurrentImp := 0;

      for I := 0 to WorkTable.EtalonChannels.Count - 1 do
      begin
        // Пропускаем неинициализированные или отключённые каналы
        if (WorkTable.EtalonChannels[I] = nil) or
           (not WorkTable.EtalonChannels[I].Enabled) then
          Continue;

        // Берём максимальное значение импульсов среди эталонов
        // (используется как репрезентативное значение)
        CurrentImp := Max(CurrentImp,
                          WorkTable.EtalonChannels[I].ImpResult);
      end;


      // ----------------------------------------------------------
      // 4.2 Получение текущего объёма/массы
      // ----------------------------------------------------------

      CurrentVolume := 0;

      // ValueQuantity — агрегированное значение измеренного количества
      if WorkTable.ValueQuantity <> nil then
        CurrentVolume := WorkTable.ValueQuantity.GetDoubleValue;


      // ----------------------------------------------------------
      // 4.3 Проверка наличия критериев остановки
      // ----------------------------------------------------------

      HasLimits :=
        (WorkTable.CurrentPoint <> nil) and
        (
          // Ограничение по времени
          ((scTime in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.CurrentPoint.LimitTime > 0)) or

          // Ограничение по импульсам
          ((scImpulse in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.CurrentPoint.LimitImp > 0)) or

          // Ограничение по объёму/массе
          ((scVolume in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.CurrentPoint.LimitVolume > 0))
        );


      // ----------------------------------------------------------
      // 4.4 Проверка достижения критериев остановки
      // ----------------------------------------------------------

      LimitReached :=
        (WorkTable.CurrentPoint <> nil) and
        (
          // По времени
          ((scTime in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.Time >= WorkTable.CurrentPoint.LimitTime)) or

          // По импульсам
          ((scImpulse in WorkTable.CurrentPoint.StopCriteria) and
           (CurrentImp >= WorkTable.CurrentPoint.LimitImp)) or

          // По объёму/массе
          ((scVolume in WorkTable.CurrentPoint.StopCriteria) and
           (CurrentVolume >= WorkTable.CurrentPoint.LimitVolume))
        );


      // ----------------------------------------------------------
      // 4.5 Завершение измерения
      // ----------------------------------------------------------

      // Если заданы ограничения и хотя бы одно достигнуто
      // → инициируем остановку теста
      if HasLimits and LimitReached then
        WorkTable.State := swtSTOPTEST;
    end;


    // ------------------------------------------------------------
    // Инициация остановки теста
    // ------------------------------------------------------------
    swtSTOPTEST:
      WorkTable.State := swtSTOPWAIT;


    // ------------------------------------------------------------
    // Ожидание полной остановки
    // ------------------------------------------------------------
    swtSTOPWAIT:
      WorkTable.State := swtFINALREAD   ;


    // ------------------------------------------------------------
    // Тест завершён → переход к финальному считыванию
    // ------------------------------------------------------------
    swtFINALREAD:
      WorkTable.State := swtCOMPLETE;

  end;

  end;

  end;





     {$ENDREGION 'TWorkTableManager'}

 end.
