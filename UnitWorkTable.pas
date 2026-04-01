unit UnitWorkTable;

interface

uses
  UnitRepositories,
  UnitFlowMeter,
  UnitMeterValue,
  UnitClasses, UnitDeviceClass,
  UnitDataManager,
  System.SysUtils,
  System.StrUtils,
  System.IniFiles,
  System.Generics.Collections;


type
  EMeasurementState = (
    STATE_NONE = 0,
    STATE_STANDBY,
    STATE_CONNECTED,
    STATE_STARTMONITOR,
    STATE_STARTMONITORWAIT,
    STATE_MONITOR,
    STATE_STOPMONITOR,
    STATE_CONFIGED,
    STATE_STARTTEST,
    STATE_STARTWAIT,
    STATE_EXECUTE,
    STATE_STOPTEST,
    STATE_STOPWAIT,
    STATE_COMPLETE,
    STATE_FINALREAD,
    STATE_FAILURE
  );

  TGridColumnLayout = record
    Name: string;
    DisplayIndex: Integer;
    Width: Single;
    Visible: Boolean;
  end;


  EPumpState = (
    PUMP_STOPED,        // насос остановлен
    PUMP_STARTED     // насос работает на минимальной частоте

  );

  EPumpAction = (
    PUMP_START,   // насос стартует
    PUMP_SET,    // насос меняет частоту
    PUMP_STOP     // насос останавливается

    );

  EFlowRateState = (
    FLOWRATE_STARTED,
    FLOWRATE_STOPED
  );

  EFlowRateAction = (
    FLOWRATE_START,
    FLOWRATE_STOP,
    FLOWRATE_SET
  );

  EConditionsState = (
    CONDITIONS_STOPED,
    CONDITIONS_STARTED
  );

  EConditionsAction = (
    CONDITIONS_NONE,
    CONDITIONS_SET_TEMPERATURE,
    CONDITIONS_SET_PRESSURE,
    CONDITIONS_SET_TIME,
    CONDITIONS_RESET
  );


type

  TPump = class(TTypeEntity)
  private

    FFreq: Double;  // текущая
    FFreqMax: Double;
    FFreqMin: Double;
    FStatus: EPumpState;
    FAction: EPumpAction;
    FName: string;
    FHeader: string; // краткое название насоса по мнемосхеме
    FHint: string;
    FPumpType: string;
    FFreqSet: double;   //установленная пользователем


    function GetIsRunning: Boolean;
    function GetIsChanging: Boolean;

  public
    constructor Create(const APumpName: string);
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    procedure SetFrequency(ANewFreq: Double);
    procedure SetFreqMin(const Value: Double);
    procedure SetFreqMax(const Value: Double);
    function GetStateAsString: string;
    function GetActionAsString: string;

    property Name: string read FName write FName;
    //property UUID: string read FUUID write FUUID;
    property Freq: Double read FFreq write FFreq;
    property FreqSet: Double read FFreqSet write FFreqSet;
    property State: EPumpState read FStatus write FStatus;
    property IsRunning: Boolean read GetIsRunning;
    property IsChanging: Boolean read GetIsChanging;
    property FreqMax: Double read FFreqMax write SetFreqMax;
    property FreqMin: Double read FFreqMin write SetFreqMin;
    property Action : EPumpAction read FAction write FAction;

    property Header: string read FHeader write FHeader;
    property Hint: string read FHint write FHint;
    property PumpType : string read FPumpType write FPumpType;


  end;

  TFlowRate = class(TTypeEntity)
  private
    FFlow: Double;
    FFlowSet: Double;
    FFlowRateMin: Double;
    FFlowRateMax: Double;
    FStatus: EFlowRateState;
    FAction: EFlowRateAction;
    FFlowAccuracyPlus: Double;           //в %
    FFlowAccuracyMinus: Double;

    FName: string;
    FHint: string;
    function GetIsRunning: Boolean;
    function GetIsChanging: Boolean;
    procedure SetFlowRateMin(const Value: Double);
    procedure SetFlowRateMax(const Value: Double);
    procedure Start;
  public
    constructor Create(const AName: string = 'FlowRate');
    procedure SetFlowRate(ANewValue: Double);
    procedure Stop;
    function GetStateAsString: string;
    function GetActionAsString: string;

    property IsRunning: Boolean read GetIsRunning;
    property IsChanging: Boolean read GetIsChanging;
    property Name: string read FName write FName;
    property Hint: string read FHint write FHint;
    property Flow: Double read FFlow write FFlow;
    property FlowSet: Double read FFlowSet write FFlowSet;
    property FlowRateMin: Double read FFlowRateMin write FFlowRateMin;
    property FlowRateMax: Double read FFlowRateMax write FFlowRateMax;
    property FlowAccuracyPlus: Double read FFlowAccuracyPlus write FFlowAccuracyPlus;
    property FlowAccuracyMinus: Double read FFlowAccuracyMinus write FFlowAccuracyMinus;
    property Status: EFlowRateState read FStatus write FStatus;
    property Action: EFlowRateAction read FAction write FAction;
  end;

  TConditionsTemp = class(TTypeEntity)
  private
    FTemp: Double;
    FTempSet: Double;
    FTempBefore: Double;
    FTempAfter: Double;
    FTempDelta: Double;
    FTempMin: Double;
    FTempMax: Double;
    FTempAccuracyPlus: Double;
    FTempAccuracyMinus: Double;
    procedure SetTempMin(const Value: Double);
    procedure SetTempMax(const Value: Double);
  public
    constructor Create;
    procedure SetTemperature(const ATemp, ATempDelta, ATempBefore, ATempAfter: Double);
    property Temp: Double read FTemp write FTemp;
    property TempSet: Double read FTempSet write FTempSet;
    property TempBefore: Double read FTempBefore write FTempBefore;
    property TempAfter: Double read FTempAfter write FTempAfter;
    property TempDelta: Double read FTempDelta write FTempDelta;
    property TempMin: Double read FTempMin write SetTempMin;
    property TempMax: Double read FTempMax write SetTempMax;
    property TempAccuracyPlus: Double read FTempAccuracyPlus write FTempAccuracyPlus;
    property TempAccuracyMinus: Double read FTempAccuracyMinus write FTempAccuracyMinus;
  end;

  TConditionsPress = class(TTypeEntity)
  private
    FPress: Double;
    FPressSet: Double;
    FPressBefore: Double;
    FPressAfter: Double;
    FPressDelta: Double;
    FPressMin: Double;
    FPressMax: Double;
    FPressAccuracyPlus: Double;
    FPressAccuracyMinus: Double;
    procedure SetPressMin(const Value: Double);
    procedure SetPressMax(const Value: Double);
  public
    constructor Create;
    procedure SetPressure(const APress, APressDelta, APressBefore, APressAfter: Double);
    property Press: Double read FPress write FPress;
    property PressSet: Double read FPressSet write FPressSet;
    property PressBefore: Double read FPressBefore write FPressBefore;
    property PressAfter: Double read FPressAfter write FPressAfter;
    property PressDelta: Double read FPressDelta write FPressDelta;
    property PressMin: Double read FPressMin write SetPressMin;
    property PressMax: Double read FPressMax write SetPressMax;
    property PressAccuracyPlus: Double read FPressAccuracyPlus write FPressAccuracyPlus;
    property PressAccuracyMinus: Double read FPressAccuracyMinus write FPressAccuracyMinus;
  end;

  TWorkTable = class;

  TSpillState = (
    ssNone,
    ssReady,
    ssStarting,
    ssOnGoing,
    ssStopping,
    ssResultReady
  );

  TChannel = class(TTypeEntity)
  private
    FEnabled: Boolean;
    FText: string;

    // Channel values (not proxy fields)
    FImpSec: Double;
    FImpResult: Double;
    FCurSec: Double;
    FCurResult: Double;
    FValueSec: Double;
    FValueResult: Double;

    FFlowMeter: TFlowMeter;
    FValueImp: TMeterValue;
    FValueImpTotal: TMeterValue;
    FValueCurrent: TMeterValue;
    FValueInterface: TMeterValue;

    FHashValueImp: string;
    FHashValueImpTotal: string;
    FHashValueCurrent: string;
    FHashValueInterface: string;

    // --- proxies for FlowMeter fields ---
    function GetDeviceNameProxy: string;
    procedure SetDeviceNameProxy(const AValue: string);

    function GetTypeNameProxy: string;
    procedure SetTypeNameProxy(const AValue: string);

    function GetSerialProxy: string;
    procedure SetSerialProxy(const AValue: string);

    function GetSignalProxy: Integer;
    procedure SetSignalProxy(const AValue: Integer);

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

  public
    constructor Create; override;
    destructor Destroy; override;

    //property UUID: string read FUUID write FUUID;

    property FlowMeter: TFlowMeter read FFlowMeter;

    property Enabled: Boolean read FEnabled write FEnabled;
    property Name: string read FName write FName;
    property Text: string read FText write FText;



    // Proxy fields (mirror FlowMeter)
    property DeviceName: string read GetDeviceNameProxy write SetDeviceNameProxy;
    property TypeName: string read GetTypeNameProxy write SetTypeNameProxy;
    property Serial: string read GetSerialProxy write SetSerialProxy;
    property Signal: Integer read GetSignalProxy write SetSignalProxy;
    property DeviceUUID: string read GetDeviceUUIDProxy write SetDeviceUUIDProxy;
    property TypeUUID: string read GetTypeUUIDProxy write SetTypeUUIDProxy;
    property RepoTypeName: string read GetRepoTypeNameProxy write SetRepoTypeNameProxy;
    property RepoTypeUUID: string read GetRepoTypeUUIDProxy write SetRepoTypeUUIDProxy;
    property RepoDeviceName: string read GetRepoDeviceNameProxy write SetRepoDeviceNameProxy;
    property RepoDeviceUUID: string read GetRepoDeviceUUIDProxy write SetRepoDeviceUUIDProxy;

    // Channel fields (internal variables)
    property ImpSec: Double read GetImpSecProxy write SetImpSecProxy;
    property ImpResult: Double read GetImpResultProxy write SetImpResultProxy;
    property CurSec: Double read GetCurSecProxy write SetCurSecProxy;
    property CurResult: Double read GetCurResultProxy write SetCurResultProxy;
    property ValueSec: Double read GetValueSecProxy write SetValueSecProxy;
    property ValueResult: Double read GetValueResultProxy write SetValueResultProxy;

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

  end;

  TWorkTable = class

  type
  // Обработчики для расхода
  TOnFlowRateSetEvent = procedure(ASender: TObject; ANewFlowRate: Double) of object;

  // Обработчики для насоса
  //TOnPumpStartEvent = procedure(APump: TPump) of object;
  //TOnPumpStopEvent = procedure(ASender: TObject; APumpName: string) of object;
  //TOnFreqSetEvent = procedure(ASender: TObject; APumpName: string; ANewFreq: Double) of object;

  TonPumpChangeEvent =  procedure(APump: TPump ; FAction : EPumpAction) of object;
  TonFlowRateChangeEvent =  procedure(AFlowRate: TFlowRate ; FAction : EFlowRateAction) of object;


  // Обработчики для пакетных заданий
  TOnProcStartEvent = procedure(ASender: TObject; AProcName: string) of object;
  TOnProcStopEvent = procedure(ASender: TObject; AProcName: string) of object;
  TOnProcPauseEvent = procedure(ASender: TObject; AProcName: string) of object;
  TOnProcNextStepEvent = procedure(ASender: TObject; AProcName: string) of object;
  TOnProcRepeatEvent = procedure(ASender: TObject; AProcName: string) of object;

  // Обработчики для измерений
  TOnSpillageStartEvent = procedure(ASender: TObject) of object;
  TOnSpillageStopEvent = procedure(ASender: TObject) of object;
  TOnMeasurementStateChangedEvent = procedure(ASender: TObject;
    AOldState, ANewState: EMeasurementState) of object;




  private
    FID: Integer;
    FName: string;
    FText: string;
    FActivePump : TPump;

    FDeviceChannels: TObjectList<TChannel>;
    FEtalonChannels: TObjectList<TChannel>;

    FPumps: TObjectList<TPump>;

    FFlowRate: TFlowRate;

    FConditionsTemp: TConditionsTemp;
    FConditionsPress: TConditionsPress;
    FTime: Double;
    FTimeResult: Double;
    FState: TSpillState;
    FMeasurementState: EMeasurementState;
    FTableClamped: Boolean;
    FFlowUnitName: string;
    FQuantityUnitName: string;

    FTableFlow: TFlowMeter;

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
    procedure SetPress(const AValue: Double);
    procedure SetPressDelta(const AValue: Double);
    procedure SetTime(const AValue: Double);
    procedure SetTimeResult(const AValue: Double);
    //procedure SetFlowRate(const AValue: Double);
    procedure AssignTableFlowAsEtalonToDevices;

    procedure SetValues;





    class function SpillStateToString(AState: TSpillState): string; static;
    class function SpillStateFromString(const AValue: string): TSpillState; static;
    class function MeasurementStateToString(AState: EMeasurementState): string; static;
    class function MeasurementStateFromString(const AValue: string): EMeasurementState; static;

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
      AChannels: TObjectList<TChannel>
    ); static;

private
  // События расхода
  FOnFlowRateSet: TOnFlowRateSetEvent;
  // События насоса
 // FOnPumpStart: TOnPumpStartEvent;
  //FOnPumpStop: TOnPumpStopEvent;
  //FOnFreqSet: TOnFreqSetEvent;

  FOnPumpChange: TonPumpChangeEvent;
  FOnFlowRateChange: TonFlowRateChangeEvent;

  // События пакетных заданий
  FOnProcStart: TOnProcStartEvent;
  FOnProcStop: TOnProcStopEvent;
  FOnProcPause: TOnProcPauseEvent;
  FOnProcNextStep: TOnProcNextStepEvent;
  FOnProcRepeat: TOnProcRepeatEvent;
  // События измерений
  FOnSpillageStart: TOnSpillageStartEvent;
  FOnSpillageStop: TOnSpillageStopEvent;
  FOnMeasurementStateChanged: TOnMeasurementStateChangedEvent;







  public
    constructor Create;
    destructor Destroy; override;

    class function BuildWorkTableServiceName(const ATableIndex: Integer): string; static;
    class function BuildDeviceChannelServiceName(const AChannelIndex: Integer): string; static;
    class function BuildEtalonChannelServiceName(const AChannelIndex: Integer): string; static;
    class function BuildChannelDefaultText(const AChannelIndex: Integer): string; static;

    function AddDeviceChannel: TChannel; overload;
    function AddDeviceChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
        ATypeName, ASerial, ADeviceUUID: string): TChannel; overload;

    function AddEtalonChannel: TChannel; overload;
    function AddEtalonChannel(const AEnabled: Boolean; const ASignal: Integer; const AName,
       ATypeName, ASerial, ADeviceUUID: string): TChannel;  overload;

    class procedure Save(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

    class procedure Load(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

      function AddPump(const APumpName: string): TPump; overload;
      function AddPump(APump: TPump): Boolean; overload;
  procedure RemovePump(const APumpUUID: string); overload;
  procedure RemovePump(APump: TPump); overload;
  procedure ClearPumps;
  procedure SetActivePump(APumpName: string);
  function FindPumpByUUID(const APumpUUID: string): TPump;
  function FindPumpByName(const APumpName: string): TPump;
  property Pumps: TObjectList<TPump> read FPumps;

  property ActivePump: TPump read FActivePump write FActivePump;
  property FlowRate: TFlowRate read FFlowRate write FFlowRate;

    property ID: Integer read FID write FID;
    property Name: string read FName write FName;
    property Text: string read FText write FText;

    property DeviceChannels: TObjectList<TChannel> read FDeviceChannels;
    property EtalonChannels: TObjectList<TChannel> read FEtalonChannels;
    property TableFlow: TFlowMeter read FTableFlow;
    property Temp: Double read GetTemp write SetTemp;
    property TempDelta: Double read GetTempDelta write SetTempDelta;
    property Press: Double read GetPress write SetPress;
    property PressDelta: Double read GetPressDelta write SetPressDelta;



    property Time: Double read GetTime write SetTime;
    property TimeResult: Double read GetTimeResult write SetTimeResult;

    property State: TSpillState read FState write FState;
    property MeasurementState: EMeasurementState read FMeasurementState write FMeasurementState;
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


    procedure RebindAllFlowMeters;
    procedure RecalculateAllMeterValues;
    procedure UpdateAggregateMeterValues;
    procedure InitMeterValues;
    procedure SetTemperature(const ATemp, ATempDelta, ATempBefore, ATempAfter: Double);
    procedure SetPressure(const APress, APressDelta, APressBefore, APressAfter: Double);


  public
  property OnFlowRateSet: TOnFlowRateSetEvent read FOnFlowRateSet write FOnFlowRateSet;


  //property OnPumpStart: TOnPumpStartEvent read FOnPumpStart write FOnPumpStart;
  //property OnPumpStop: TOnPumpStopEvent read FOnPumpStop write FOnPumpStop;
  //property OnFreqSet: TOnFreqSetEvent read FOnFreqSet write FOnFreqSet;
  property OnPumpChange: TonPumpChangeEvent read FOnPumpChange write FOnPumpChange;
  property OnFlowRateChange: TonFlowRateChangeEvent read FOnFlowRateChange write FOnFlowRateChange;

  property OnProcStart: TOnProcStartEvent read FOnProcStart write FOnProcStart;
  property OnProcStop: TOnProcStopEvent read FOnProcStop write FOnProcStop;
  property OnProcPause: TOnProcPauseEvent read FOnProcPause write FOnProcPause;
  property OnProcNextStep: TOnProcNextStepEvent read FOnProcNextStep write FOnProcNextStep;
  property OnProcRepeat: TOnProcRepeatEvent read FOnProcRepeat write FOnProcRepeat;
  property OnSpillageStart: TOnSpillageStartEvent read FOnSpillageStart write FOnSpillageStart;
  property OnSpillageStop: TOnSpillageStopEvent read FOnSpillageStop write FOnSpillageStop;
  property OnMeasurementStateChanged: TOnMeasurementStateChangedEvent
    read FOnMeasurementStateChanged write FOnMeasurementStateChanged;






  //нужно ли оставить одну  DoPumpChange ?
  procedure DoPumpStart(APumpName: string);
  procedure DoPumpStop(APumpName: string);
  procedure DoFreqSet(APumpName: string; ANewFreq: Double);

  procedure DoFlowRateStart;
  procedure DoFlowRateStop;
  procedure DoFlowRateSet(ANewFlowRate: Double);

  procedure DoProcStart(AProcName: string);
  procedure DoProcStop(AProcName: string);
  procedure DoProcPause(AProcName: string);
  procedure DoProcNextStep(AProcName: string);
  procedure DoProcRepeat(AProcName: string);
  procedure DoSpillageStart;
  procedure DoSpillageStop;
  procedure DoMeasurementStateChanged(AOldState, ANewState: EMeasurementState);


  end;



  TWorkTableManager = class
  private
    FIniFileName: string;
    FWorkTables: TObjectList<TWorkTable>;
    FActiveWorkTable  :TWorkTable;
  public
    constructor Create(const AIniFileName: string);
    destructor Destroy; override;

    procedure Load;
    procedure Save;

    procedure SetActiveWorkTable(AWorkTable: TWorkTable);

    property WorkTables: TObjectList<TWorkTable> read FWorkTables;
    property ActiveWorkTable: TWorkTable read FActiveWorkTable write FActiveWorkTable;
    property IniFileName: string read FIniFileName write FIniFileName;
  end;

implementation




uses frmMainTable;{$REGION 'TChannel'}

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
  begin
    TMeterValue.RebindReferences(ATarget, AValue);

    if TMeterValue.GetMeterValues <> nil then
      TMeterValue.GetMeterValues.Remove(ATarget);
    ATarget.Free;
  end;

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

  FEnabled := False;
  FName:= 'Канал';
  FText := '1';
  FImpSec := 0;
  FImpResult := 0;
  FCurSec := 0;
  FCurResult := 0;
  FValueSec := 0;
  FValueResult := 0;

  FFlowMeter.Name := 'Прибор ' + FName;
end;

{ Releases channel-owned resources and removes linked values from shared storage. }
destructor TChannel.Destroy;
begin
  FreeAndNil(FFlowMeter);
  inherited Destroy;
end;

{ Initializes channel FlowMeter links using the configured device UUID. }
procedure TChannel.Init;
begin
  if not Assigned(FFlowMeter) then
    Exit;

  FFlowMeter.Init(DeviceUUID);
end;

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

  if DataManager = nil then
  Exit;

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

  FFlowMeter.UUID := ASource.FFlowMeter.UUID;
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
  FFlowMeter.Error := ASource.FFlowMeter.Error;
  FFlowMeter.PointIndex := ASource.FFlowMeter.PointIndex;
  FFlowMeter.Comment := ASource.FFlowMeter.Comment;
  FFlowMeter.MeterFlowCategory := ASource.FFlowMeter.MeterFlowCategory;

  SrcDevice := ASource.FFlowMeter.Device;
  if ACloneDeviceToRepo and (SrcDevice <> nil) and (DataManager <> nil) and (DataManager.ActiveDeviceRepo <> nil) then
  begin
    NewDevice := DataManager.ActiveDeviceRepo.CreateDevice(SrcDevice);
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

  FDeviceChannels := TObjectList<TChannel>.Create(True);
  FEtalonChannels := TObjectList<TChannel>.Create(True);

  FPumps := TObjectList<TPump>.Create(True); // True — автоосвобождение объектов
  FlowRate := TFlowRate.Create('Расход');
  FConditionsTemp := TConditionsTemp.Create;
  FConditionsPress := TConditionsPress.Create;

  FTableFlow := TFlowMeter.Create;

  FState := ssNone;
  FMeasurementState := STATE_NONE;
  FTableClamped := False;
  FText := 'Рабочий стол 1';
  FFlowUnitName := 'м3/ч';
  FQuantityUnitName := 'м3';

  FLayoutFlowRateVisible := True;
  FLayoutPumpVisible := True;
  FLayoutMainVisible := True;
  FLayoutMesureVisible := True;
  FLayoutConditionsVisible := True;
  FLayoutProceduresVisible := True;
  FInstrumentalLayoutOrder := 'FlowRate,Pump,Main,Mesure,Conditions,Procedures';

  Temp := 20.2;
  TempDelta := 0.1;
  Press := 101.1;
  PressDelta := 0.1;
  //FlowRate := 10;


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
    EnsureDescription(FTableFlow.ValueImp, 'Импульсы стола');
  end;

  if FTableFlow.ValueImpTotal = nil then
  begin
    FTableFlow.ValueImpTotal := TMeterValue.Create('', Name);
    FTableFlow.ValueImpTotal.SetAsImp;
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
    Result := FlowRate.Flow
  else
    Result := FlowRate.FFlowRateMin;
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



{ Rebuilds aggregate lists for table values from enabled etalon channels. }
procedure TWorkTable.UpdateAggregateMeterValues;
var
  I: Integer;
  Channel: TChannel;
  IsQuantityTemplateSet: Boolean;
  IsFlowTemplateSet: Boolean;
begin
  if FTableFlow.ValueQuantity <> nil then
    FTableFlow.ValueQuantity.ClearMeterValues;
  if FTableFlow.ValueFlowRate <> nil then
    FTableFlow.ValueFlowRate.ClearMeterValues;

  IsQuantityTemplateSet := False;
  IsFlowTemplateSet := False;

  for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];
    if (Channel = nil) or (not Channel.Enabled) or (Channel.FlowMeter = nil) then
      Continue;

    if (FTableFlow.ValueQuantity <> nil) and (Channel.FlowMeter.ValueQuantity <> nil) then
    begin
      if not IsQuantityTemplateSet then
      begin
        FTableFlow.ValueQuantity.SetAs(Channel.FlowMeter.ValueQuantity);
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
        FTableFlow.ValueFlowRate.ValueType := AGGREGATE_TYPE;
        IsFlowTemplateSet := True;
      end;
      FTableFlow.ValueFlowRate.AddMeterValue(Channel.FlowMeter.ValueFlow);
    end;
  end;
end;

{ Frees channel collections owned by the work table. }
destructor TWorkTable.Destroy;
begin
  FreeAndNil(FConditionsTemp);
  FreeAndNil(FConditionsPress);
  FreeAndNil(FlowRate);
  FreeAndNil(FTableFlow);
  FDeviceChannels.Free;
  FEtalonChannels.Free;
  FreeAndNil(FPumps);

  inherited;
end;

function TWorkTable.GetTemp: Double;
begin
  if FConditionsTemp <> nil then
    Result := FConditionsTemp.Temp
  else
    Result := 0;
end;

function TWorkTable.GetTempDelta: Double;
begin
  if FConditionsTemp <> nil then
    Result := FConditionsTemp.TempDelta
  else
    Result := 0;
end;

function TWorkTable.GetPress: Double;
begin
  if FConditionsPress <> nil then
    Result := FConditionsPress.Press
  else
    Result := 0;
end;

function TWorkTable.GetPressDelta: Double;
begin
  if FConditionsPress <> nil then
    Result := FConditionsPress.PressDelta
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
  SetTemperature(AValue, TempDelta, TempBeforeValue, TempAfterValue);
end;

procedure TWorkTable.SetTempDelta(const AValue: Double);
begin
  if FConditionsTemp <> nil then
    FConditionsTemp.TempDelta := AValue;
end;

procedure TWorkTable.SetPress(const AValue: Double);
var
  PressBeforeValue: Double;
  PressAfterValue: Double;
begin
  PressBeforeValue := 0;
  PressAfterValue := 0;
  if ValuePressureBefore <> nil then
    PressBeforeValue := ValuePressureBefore.GetDoubleValue;
  if ValuePressureAfter <> nil then
    PressAfterValue := ValuePressureAfter.GetDoubleValue;
  SetPressure(AValue, PressDelta, PressBeforeValue, PressAfterValue);
end;

procedure TWorkTable.SetPressDelta(const AValue: Double);
begin
  if FConditionsPress <> nil then
    FConditionsPress.PressDelta := AValue;
end;

procedure TWorkTable.SetTime(const AValue: Double);
begin
  FTime := AValue;
end;

procedure TWorkTable.SetTimeResult(const AValue: Double);
begin
  FTimeResult := AValue;
end;

procedure TWorkTable.SetTemperature(const ATemp, ATempDelta, ATempBefore, ATempAfter: Double);
var
  AppliedTemp: Double;
  AppliedTempBefore: Double;
  AppliedTempAfter: Double;
begin
  AppliedTemp := ATemp;
  AppliedTempBefore := ATempBefore;
  AppliedTempAfter := ATempAfter;

  if FConditionsTemp <> nil then
  begin
    FConditionsTemp.SetTemperature(ATemp, ATempDelta, ATempBefore, ATempAfter);
    AppliedTemp := FConditionsTemp.Temp;
    AppliedTempBefore := FConditionsTemp.TempBefore;
    AppliedTempAfter := FConditionsTemp.TempAfter;
  end;

  if ValueTempertureBefore <> nil then
    ValueTempertureBefore.SetDoubleValue(AppliedTempBefore);
  if ValueTempertureAfter <> nil then
    ValueTempertureAfter.SetDoubleValue(AppliedTempAfter);
  if ValueTemperture <> nil then
    ValueTemperture.SetDoubleValue(AppliedTemp);
end;

procedure TWorkTable.SetPressure(const APress, APressDelta, APressBefore, APressAfter: Double);
var
  AppliedPress: Double;
  AppliedPressBefore: Double;
  AppliedPressAfter: Double;
begin
  AppliedPress := APress;
  AppliedPressBefore := APressBefore;
  AppliedPressAfter := APressAfter;

  if FConditionsPress <> nil then
  begin
    FConditionsPress.SetPressure(APress, APressDelta, APressBefore, APressAfter);
    AppliedPress := FConditionsPress.Press;
    AppliedPressBefore := FConditionsPress.PressBefore;
    AppliedPressAfter := FConditionsPress.PressAfter;
  end;

  if ValuePressureBefore <> nil then
    ValuePressureBefore.SetDoubleValue(AppliedPressBefore);
  if ValuePressureAfter <> nil then
    ValuePressureAfter.SetDoubleValue(AppliedPressAfter);
  if ValuePressure <> nil then
    ValuePressure.SetDoubleValue(AppliedPress);
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
  FDeviceChannels.Add(Result);
  Result.RebindFlowMeterValues(Self);
  if (Result.FlowMeter <> nil) and (FTableFlow <> nil) then
    Result.FlowMeter.SetEtalon(FTableFlow);
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
  FEtalonChannels.Add(Result);
  Result.RebindFlowMeterValues(Self);
end;

{ Rebinds all device and etalon flow meters to this work table values. }
procedure TWorkTable.RebindAllFlowMeters;
var
  I: Integer;
begin
  for I := 0 to FDeviceChannels.Count - 1 do
    FDeviceChannels[I].RebindFlowMeterValues(Self);

   for I := 0 to FEtalonChannels.Count - 1 do
    FEtalonChannels[I].RebindFlowMeterValues(Self);

  UpdateAggregateMeterValues;
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
    if (Channel = nil) or (Channel.FlowMeter = nil) then
      Continue;

    Channel.SetValues;

  end;

      Self.SetValues;

     for I := 0 to FEtalonChannels.Count - 1 do
  begin
    Channel := FEtalonChannels[I];
    if (Channel = nil) or (Channel.FlowMeter = nil) then
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
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  Ini := TMemIniFile.Create(AIniFileName);
  WorkTableValuesFileName := IncludeTrailingPathDelimiter(ExtractFilePath(AIniFileName)) + 'WorkTableValues.ini';
  ValuesIni := TMemIniFile.Create(WorkTableValuesFileName);
  try
    Ini.WriteInteger('WorkTables', 'Count', AWorkTables.Count);

    if AWorkTables.Count > 0 then
      ValuesIni.WriteFloat('Common', 'InitDensity', AWorkTables[0].ValueDensity.GetDoubleValue);

    for I := 0 to AWorkTables.Count - 1 do
    begin
      WorkTable := AWorkTables[I];
      Section := 'WorkTable.' + IntToStr(I);

      WorkTable.Name := BuildWorkTableServiceName(WorkTable.ID);
      if Trim(WorkTable.Text) = '' then
        WorkTable.Text := 'Рабочий стол ' + IntToStr(WorkTable.ID);

      Ini.WriteInteger(Section, 'ID', WorkTable.ID);
      Ini.WriteString(Section, 'Name', WorkTable.Name);
      Ini.WriteString(Section, 'Text', WorkTable.Text);
      Ini.WriteFloat(Section, 'Temp', WorkTable.Temp);
      Ini.WriteFloat(Section, 'TempDelta', WorkTable.TempDelta);
      Ini.WriteFloat(Section, 'Press', WorkTable.Press);
      Ini.WriteFloat(Section, 'PressDelta', WorkTable.PressDelta);
      Ini.WriteFloat(Section, 'FlowRate', WorkTable.FlowRate.Flow);
      Ini.WriteFloat(Section, 'Time', WorkTable.Time);
      Ini.WriteFloat(Section, 'TimeResult', WorkTable.TimeResult);
      Ini.WriteString(Section, 'State', SpillStateToString(WorkTable.State));
      Ini.WriteString(Section, 'MeasurementState', MeasurementStateToString(WorkTable.MeasurementState));
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

      SaveChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      SaveChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);
      SaveGridColumns(Ini, Section + '.EtalonGrid', WorkTable.EtalonsGridColumns);
      SaveGridColumns(Ini, Section + '.DeviceGrid', WorkTable.DevicesGridColumns);
      SaveGridColumns(Ini, Section + '.DataPointsGrid', WorkTable.DataPointsGridColumns);
      SaveGridColumns(Ini, Section + '.ResultsGrid', WorkTable.ResultsGridColumns);
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

  Ini := TIniFile.Create(AIniFileName);
  WorkTableValuesFileName := IncludeTrailingPathDelimiter(ExtractFilePath(AIniFileName)) + 'WorkTableValues.ini';
  ValuesIni := TIniFile.Create(WorkTableValuesFileName);
  try
    Count := Ini.ReadInteger('WorkTables', 'Count', 0);
    TMeterValue.SetInitDensity(ValuesIni.ReadFloat('Common', 'InitDensity', TMeterValue.GetInitDensity));

    for I := 0 to Count - 1 do
    begin
      Section := 'WorkTable.' + IntToStr(I);
      WorkTable := TWorkTable.Create;

      WorkTable.ID := Ini.ReadInteger(Section, 'ID', I + 1);
      WorkTable.Name := BuildWorkTableServiceName(WorkTable.ID);
      WorkTable.Text := Ini.ReadString(Section, 'Text', 'Рабочий стол ' + IntToStr(WorkTable.ID));
      if Trim(WorkTable.Text) = '' then
        WorkTable.Text := 'Рабочий стол ' + IntToStr(WorkTable.ID);
      WorkTable.Temp := Ini.ReadFloat(Section, 'Temp', 0);
      WorkTable.TempDelta := Ini.ReadFloat(Section, 'TempDelta', 0);
      WorkTable.Press := Ini.ReadFloat(Section, 'Press', 0);
      WorkTable.PressDelta := Ini.ReadFloat(Section, 'PressDelta', 0);
      WorkTable.FlowRate.Flow := Ini.ReadFloat(Section, 'FlowRate', 0);
      WorkTable.Time := Ini.ReadFloat(Section, 'Time', 0);
      WorkTable.TimeResult := Ini.ReadFloat(Section, 'TimeResult', 0);
      WorkTable.State := SpillStateFromString(
        Ini.ReadString(Section, 'State', 'None')
      );
      WorkTable.MeasurementState := MeasurementStateFromString(
        Ini.ReadString(Section, 'MeasurementState', 'STATE_NONE')
      );
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

      WorkTable.ValueTempertureBefore.SetValue(ValuesIni.ReadFloat(Section, 'ValueTempertureBefore', 21));
      WorkTable.ValueTempertureAfter.SetValue(ValuesIni.ReadFloat(Section, 'ValueTempertureAfter', 21));
      WorkTable.ValueTempertureDelta.SetValue(ValuesIni.ReadFloat(Section, 'ValueTempertureDelta', 0));
      WorkTable.ValueTemperture.SetValue(ValuesIni.ReadFloat(Section, 'ValueTemperture', 21));
      WorkTable.ValuePressureBefore.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressureBefore', 0));
      WorkTable.ValuePressureAfter.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressureAfter', 0));
      WorkTable.ValuePressureDelta.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressureDelta', 0));
      WorkTable.ValuePressure.SetValue(ValuesIni.ReadFloat(Section, 'ValuePressure', 0));
      WorkTable.ValueDensity.SetValue(ValuesIni.ReadFloat(Section, 'ValueDensity', TMeterValue.GetInitDensity));
      WorkTable.ValueAirPressure.SetValue(ValuesIni.ReadFloat(Section, 'ValueAirPressure', 0));
      WorkTable.ValueAirTemperture.SetValue(ValuesIni.ReadFloat(Section, 'ValueAirTemperture', 0));
      WorkTable.ValueHumidity.SetValue(ValuesIni.ReadFloat(Section, 'ValueHumidity', 0));
      WorkTable.ValueTime.SetValue(ValuesIni.ReadFloat(Section, 'ValueTime', 0));
      WorkTable.ValueQuantity.SetValue(ValuesIni.ReadFloat(Section, 'ValueQuantity', 0));
      WorkTable.ValueFlowRate.SetValue(ValuesIni.ReadFloat(Section, 'ValueFlowRate', 0));

      WorkTable.ValueTempertureBefore.SetValue(21);
      WorkTable.ValueTempertureAfter.SetValue(21);

      WorkTable.Temp := 21;

      LoadChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      LoadChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);
      LoadGridColumns(Ini, Section + '.EtalonGrid', WorkTable.FEtalonsGridColumns);
      LoadGridColumns(Ini, Section + '.DeviceGrid', WorkTable.FDevicesGridColumns);
      LoadGridColumns(Ini, Section + '.DataPointsGrid', WorkTable.FDataPointsGridColumns);
      LoadGridColumns(Ini, Section + '.ResultsGrid', WorkTable.FResultsGridColumns);

      WorkTable.RebindAllFlowMeters;
      WorkTable.RecalculateAllMeterValues;
      WorkTable.UpdateAggregateMeterValues;

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
    AColumns[I].Width := AIni.ReadFloat(Section, 'Width', 80);
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
    if EndsText('.Etalon', ASectionPrefix) then
      Channel.Name := BuildEtalonChannelServiceName(Channel.ID)
    else
      Channel.Name := BuildDeviceChannelServiceName(Channel.ID);

    AIni.WriteInteger(Section, 'ID', Channel.ID);
    AIni.WriteString(Section, 'UUID', Channel.UUID);
    AIni.WriteBool(Section, 'Enabled', Channel.Enabled);
    AIni.WriteString(Section, 'Name', Channel.Name);
    AIni.WriteString(Section, 'Text', Channel.Text);
    AIni.WriteString(Section, 'TypeName', Channel.TypeName);
    AIni.WriteString(Section, 'DeviceName', Channel.DeviceName);
    AIni.WriteString(Section, 'Serial', Channel.Serial);
    AIni.WriteInteger(Section, 'Signal', Channel.Signal);
    AIni.WriteString(Section, 'DeviceUUID', Channel.DeviceUUID);
    AIni.WriteString(Section, 'TypeUUID', Channel.TypeUUID);
    AIni.WriteString(Section, 'RepoTypeName', Channel.RepoTypeName);
    AIni.WriteString(Section, 'RepoTypeUUID', Channel.RepoTypeUUID);
    AIni.WriteString(Section, 'RepoDeviceName', Channel.RepoDeviceName);
    AIni.WriteString(Section, 'RepoDeviceUUID', Channel.RepoDeviceUUID);

    AIni.WriteFloat(Section, 'ImpSec', Channel.ImpSec);
    AIni.WriteFloat(Section, 'ImpResult', Channel.ImpResult);
    AIni.WriteFloat(Section, 'CurSec', Channel.CurSec);
    AIni.WriteFloat(Section, 'CurResult', Channel.CurResult);
    AIni.WriteFloat(Section, 'ValueSec', Channel.ValueSec);
    AIni.WriteFloat(Section, 'ValueResult', Channel.ValueResult);

    AIni.WriteString(Section, 'HashValueImp', Channel.ValueImp.Hash);
    AIni.WriteString(Section, 'HashValueImpTotal', Channel.ValueImpTotal.Hash);
    AIni.WriteString(Section, 'HashValueCurrent', Channel.ValueCurrent.Hash);
    AIni.WriteString(Section, 'HashValueInterface', Channel.ValueInterface.Hash);
  end;
end;

{ Restores channel collection metadata from INI storage. }
class procedure TWorkTable.LoadChannelList(AIni: TCustomIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>);
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
    Channel.Enabled := AIni.ReadBool(Section, 'Enabled', True);
    if EndsText('.Etalon', ASectionPrefix) then
      Channel.Name := BuildEtalonChannelServiceName(Channel.ID)
    else
      Channel.Name := BuildDeviceChannelServiceName(Channel.ID);
    Channel.Text := AIni.ReadString(Section, 'Text', BuildChannelDefaultText(I + 1));
    if Trim(Channel.Text) = '' then
      Channel.Text := BuildChannelDefaultText(I + 1);
    Channel.TypeName := AIni.ReadString(Section, 'TypeName', '');
    Channel.DeviceName := AIni.ReadString(Section, 'DeviceName', Channel.TypeName);
    Channel.Serial := AIni.ReadString(Section, 'Serial', '');
    Channel.Signal := AIni.ReadInteger(Section, 'Signal', -1);
    Channel.DeviceUUID := AIni.ReadString(Section, 'DeviceUUID', '');
    Channel.TypeUUID := AIni.ReadString(Section, 'TypeUUID', '');
    Channel.RepoTypeName := AIni.ReadString(Section, 'RepoTypeName', '');
    Channel.RepoTypeUUID := AIni.ReadString(Section, 'RepoTypeUUID', '');
    Channel.RepoDeviceName := AIni.ReadString(Section, 'RepoDeviceName', '');
    Channel.RepoDeviceUUID := AIni.ReadString(Section, 'RepoDeviceUUID', '');

    Channel.ImpSec := AIni.ReadFloat(Section, 'ImpSec', 0);
    Channel.ImpResult :=0; //AIni.ReadFloat(Section, 'ImpResult', 0);
    Channel.CurSec := AIni.ReadFloat(Section, 'CurSec', 0);
    Channel.CurResult := AIni.ReadFloat(Section, 'CurResult', 0);
    Channel.ValueSec := AIni.ReadFloat(Section, 'ValueSec', 0);
    Channel.ValueResult := AIni.ReadFloat(Section, 'ValueResult', 0);

    Channel.FHashValueImp := AIni.ReadString(Section, 'HashValueImp', Channel.FHashValueImp);
    Channel.FHashValueImpTotal := AIni.ReadString(Section, 'HashValueImpTotal', Channel.FHashValueImpTotal);
    Channel.FHashValueCurrent := AIni.ReadString(Section, 'HashValueCurrent', Channel.FHashValueCurrent);
    Channel.FHashValueInterface := AIni.ReadString(Section, 'HashValueInterface', Channel.FHashValueInterface);

    if Channel.FValueImp <> nil then Channel.FValueImp.DeleteFromVector;
    if Channel.FValueImpTotal <> nil then Channel.FValueImpTotal.DeleteFromVector;
    if Channel.FValueCurrent <> nil then Channel.FValueCurrent.DeleteFromVector;
    if Channel.FValueInterface <> nil then Channel.FValueInterface.DeleteFromVector;

    Channel.InitMeterValues;

    Channel.FlowMeter.Name := 'прибор '+ Channel.Name;

    Channel.Init;



    AChannels.Add(Channel);
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

{ Converts persisted string to spill state enum value. }
class function TWorkTable.SpillStateFromString(const AValue: string): TSpillState;
begin
  if SameText(AValue, 'Ready') then
    Exit(ssReady);

  if SameText(AValue, 'Starting') then
    Exit(ssStarting);

  if SameText(AValue, 'OnGoing') then
    Exit(ssOnGoing);

  if SameText(AValue, 'Stopping') then
    Exit(ssStopping);

  if SameText(AValue, 'ResultReady') then
    Exit(ssResultReady);

  Result := ssNone;
end;


class function TWorkTable.MeasurementStateFromString(
  const AValue: string): EMeasurementState;
begin
  if SameText(AValue, 'STATE_STANDBY') then
    Exit(STATE_STANDBY);
  if SameText(AValue, 'STATE_CONNECTED') then
    Exit(STATE_CONNECTED);
  if SameText(AValue, 'STATE_STARTMONITOR') then
    Exit(STATE_STARTMONITOR);
  if SameText(AValue, 'STATE_STARTMONITORWAIT') then
    Exit(STATE_STARTMONITORWAIT);
  if SameText(AValue, 'STATE_MONITOR') then
    Exit(STATE_MONITOR);
  if SameText(AValue, 'STATE_STOPMONITOR') then
    Exit(STATE_STOPMONITOR);
  if SameText(AValue, 'STATE_CONFIGED') then
    Exit(STATE_CONFIGED);
  if SameText(AValue, 'STATE_STARTTEST') then
    Exit(STATE_STARTTEST);
  if SameText(AValue, 'STATE_STARTWAIT') then
    Exit(STATE_STARTWAIT);
  if SameText(AValue, 'STATE_EXECUTE') then
    Exit(STATE_EXECUTE);
  if SameText(AValue, 'STATE_STOPTEST') then
    Exit(STATE_STOPTEST);
  if SameText(AValue, 'STATE_STOPWAIT') then
    Exit(STATE_STOPWAIT);
  if SameText(AValue, 'STATE_COMPLETE') then
    Exit(STATE_COMPLETE);
  if SameText(AValue, 'STATE_FINALREAD') then
    Exit(STATE_FINALREAD);
  if SameText(AValue, 'STATE_FAILURE') then
    Exit(STATE_FAILURE);

  Result := STATE_NONE;
end;

class function TWorkTable.MeasurementStateToString(
  AState: EMeasurementState): string;
begin
  case AState of
    STATE_STANDBY: Result := 'STATE_STANDBY';
    STATE_CONNECTED: Result := 'STATE_CONNECTED';
    STATE_STARTMONITOR: Result := 'STATE_STARTMONITOR';
    STATE_STARTMONITORWAIT: Result := 'STATE_STARTMONITORWAIT';
    STATE_MONITOR: Result := 'STATE_MONITOR';
    STATE_STOPMONITOR: Result := 'STATE_STOPMONITOR';
    STATE_CONFIGED: Result := 'STATE_CONFIGED';
    STATE_STARTTEST: Result := 'STATE_STARTTEST';
    STATE_STARTWAIT: Result := 'STATE_STARTWAIT';
    STATE_EXECUTE: Result := 'STATE_EXECUTE';
    STATE_STOPTEST: Result := 'STATE_STOPTEST';
    STATE_STOPWAIT: Result := 'STATE_STOPWAIT';
    STATE_COMPLETE: Result := 'STATE_COMPLETE';
    STATE_FINALREAD: Result := 'STATE_FINALREAD';
    STATE_FAILURE: Result := 'STATE_FAILURE';
  else
    Result := 'STATE_NONE';
  end;
end;

{ Converts spill state enum value to persisted string. }
class function TWorkTable.SpillStateToString(AState: TSpillState): string;
begin
  case AState of
    ssReady:
      Result := 'Ready';
    ssStarting:
      Result := 'Starting';
    ssOnGoing:
      Result := 'OnGoing';
    ssStopping:
      Result := 'Stopping';
    ssResultReady:
      Result := 'ResultReady';
  else
    Result := 'None';
  end;
end;





procedure TWorkTable.DoPumpStart(APumpName: string);
var Pump: TPump;
begin

  Pump:=FindPumpByName(APumpName);

  if Pump=nil then
  Exit;

  IF Pump.FAction = PUMP_START then
    exit;

  Pump.Start;

  if Assigned(FOnPumpChange) then
    FOnPumpChange(Pump, PUMP_START);
end;

procedure TWorkTable.DoFlowRateStart;
begin


  if FlowRate=nil then
  Exit;

  IF FlowRate.FAction = FlowRate_START then
    exit;

  FlowRate.Start;

  if Assigned(FOnFlowRateChange) then
    FOnFlowRateChange(FlowRate, FlowRate_START);
end;

procedure TWorkTable.DoPumpStop(APumpName: string);
var Pump: TPump;
begin

  Pump:=FindPumpByName(APumpName);

  if Pump=nil then
    Exit;

  IF Pump.FAction = PUMP_STOP then
    exit;

  Pump.Stop;

  if Assigned(FOnPumpChange) then
    FOnPumpChange(Pump,PUMP_START);
end;

procedure TWorkTable.DoFlowRateStop;
begin


  if FlowRate=nil then
  Exit;

  IF FlowRate.FAction = FlowRate_Stop then
    exit;

  FlowRate.Stop;

  if Assigned(FOnFlowRateChange) then
    FOnFlowRateChange(FlowRate, FlowRate_Stop);
end;


procedure TWorkTable.DoFlowRateSet(ANewFlowRate: Double);
begin
  if FlowRate=nil then
    Exit;


  FlowRate.SetFlowRate(ANewFlowRate);


  if Assigned(FOnFlowRateChange) then
    FOnFlowRateChange(FlowRate, FlowRate_set);
end;

procedure TWorkTable.DoFreqSet(APumpName: string; ANewFreq: Double);
var Pump: TPump;
begin

  Pump:=FindPumpByName(APumpName);

  if Pump=nil then
  Exit;


  Pump.SetFrequency(ANewFreq);


  if Assigned(FOnPumpChange) then
    FOnPumpChange(Pump,PUMP_SET);
end;

procedure TWorkTable.DoProcStart(AProcName: string);
begin
  if Assigned(FOnProcStart) then
    FOnProcStart(Self, AProcName);
end;

procedure TWorkTable.DoProcStop(AProcName: string);
begin
  if Assigned(FOnProcStop) then
    FOnProcStop(Self, AProcName);
end;

procedure TWorkTable.DoProcPause(AProcName: string);
begin
  if Assigned(FOnProcPause) then
    FOnProcPause(Self, AProcName);
end;

procedure TWorkTable.DoProcNextStep(AProcName: string);
begin
  if Assigned(FOnProcNextStep) then
    FOnProcNextStep(Self, AProcName);
end;

procedure TWorkTable.DoProcRepeat(AProcName: string);
begin
  if Assigned(FOnProcRepeat) then
    FOnProcRepeat(Self, AProcName);
end;

procedure TWorkTable.DoSpillageStart;
begin
  if Assigned(FOnSpillageStart) then
    FOnSpillageStart(Self);
end;

procedure TWorkTable.DoSpillageStop;
begin
  if Assigned(FOnSpillageStop) then
    FOnSpillageStop(Self);
end;

procedure TWorkTable.DoMeasurementStateChanged(AOldState, ANewState: EMeasurementState);
begin
  if Assigned(FOnMeasurementStateChanged) then
    FOnMeasurementStateChanged(Self, AOldState, ANewState);
end;

function TWorkTable.AddPump(const APumpName: string): TPump;
var
  NewPump: TPump;
begin
  NewPump := TPump.Create(APumpName);
  FPumps.Add(NewPump);
  Result := NewPump;
end;

function TWorkTable.AddPump(APump: TPump): Boolean;
begin
  if Assigned(APump) then
  begin
    FPumps.Add(APump);
    Result := True;
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
    FPumps.Remove(Pump);
end;

procedure TWorkTable.RemovePump(APump: TPump);
begin
  if Assigned(APump) then
    FPumps.Remove(APump);
end;

procedure TWorkTable.ClearPumps;
begin
  FPumps.Clear;
end;

function TWorkTable.FindPumpByUUID(const APumpUUID: string): TPump;
var
  Pump: TPump;
begin
  for Pump in FPumps do
  begin
    if Pump.UUID = APumpUUID then
    begin
      Result := Pump;
      Exit;
    end;
  end;
  Result := nil;
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


procedure TWorkTable.SetActivePump(APumpName: string);
var
  Pump: TPump;
begin

  Pump:=FindPumpByName(APumpName);

  if Pump=nil then
  Exit;

    FActivePump:= Pump;
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
end;

{ Frees managed work table collection and manager resources. }
destructor TWorkTableManager.Destroy;
begin
  FWorkTables.Free;
  inherited;
end;

{ Loads managed work tables from configured INI file. }
procedure TWorkTableManager.Load;
begin
  TWorkTable.Load(FIniFileName, FWorkTables);

  if (FWorkTables<>nil) and (FWorkTables.Count>0) and (FWorkTables[0]<>nil) then

  SetActiveWorkTable(FWorkTables[0]);
end;

{ Saves managed work tables to configured INI file. }
procedure TWorkTableManager.Save;
begin
  TWorkTable.Save(FIniFileName, FWorkTables);
end;


procedure TWorkTableManager.SetActiveWorkTable(AWorkTable: TWorkTable);
begin
    FActiveWorkTable:= AWorkTable;
end;

     {$ENDREGION 'TWorkTableManager'}





   {$REGION 'TConditions'}
constructor TConditionsTemp.Create;
begin
  inherited Create;
  FTempMin := -50;
  FTempMax := 150;
  FTemp := 20.2;
  FTempSet := FTemp;
  FTempBefore := FTemp;
  FTempAfter := FTemp;
  FTempDelta := 0.1;
  FTempAccuracyPlus := 1;
  FTempAccuracyMinus := 1;
end;

procedure TConditionsTemp.SetTempMax(const Value: Double);
begin
  if Value < FTempMin then Exit;
  FTempMax := Value;
end;

procedure TConditionsTemp.SetTempMin(const Value: Double);
begin
  if Value > FTempMax then Exit;
  FTempMin := Value;
end;

procedure TConditionsTemp.SetTemperature(const ATemp, ATempDelta, ATempBefore, ATempAfter: Double);
var
  CalculatedTemp: Double;
begin
  FTempSet := ATemp;
  FTempBefore := ATempBefore;
  FTempAfter := ATempAfter;

  if Abs(ATempBefore) <= 1E-12 then
    CalculatedTemp := ATempAfter
  else
    CalculatedTemp := ATempAfter - ATempBefore;

  if CalculatedTemp < FTempMin then
    FTemp := FTempMin
  else if CalculatedTemp > FTempMax then
    FTemp := FTempMax
  else
    FTemp := CalculatedTemp;

  FTempDelta := ATempDelta;
end;

constructor TConditionsPress.Create;
begin
  inherited Create;
  FPressMin := 0;
  FPressMax := 200;
  FPress := 101.1;
  FPressSet := FPress;
  FPressBefore := FPress;
  FPressAfter := FPress;
  FPressDelta := 0.1;
  FPressAccuracyPlus := 1;
  FPressAccuracyMinus := 1;
end;

procedure TConditionsPress.SetPressMax(const Value: Double);
begin
  if Value < FPressMin then Exit;
  FPressMax := Value;
end;

procedure TConditionsPress.SetPressMin(const Value: Double);
begin
  if Value > FPressMax then Exit;
  FPressMin := Value;
end;

procedure TConditionsPress.SetPressure(const APress, APressDelta, APressBefore, APressAfter: Double);
var
  CalculatedPress: Double;
begin
  FPressSet := APress;
  FPressBefore := APressBefore;
  FPressAfter := APressAfter;

  if Abs(APressBefore) <= 1E-12 then
    CalculatedPress := APressAfter
  else
    CalculatedPress := APressAfter - APressBefore;

  if CalculatedPress < FPressMin then
    FPress := FPressMin
  else if CalculatedPress > FPressMax then
    FPress := FPressMax
  else
    FPress := CalculatedPress;

  FPressDelta := APressDelta;
end;

  {$ENDREGION 'TConditions'}

   {$REGION 'TFlowRate'}
constructor TFlowRate.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
  FFlowRateMin := 0;
  FFlowRateMax := 100;
  FFlow := 0;
  FFlowSet := FFlowRateMin;
  FlowAccuracyPlus:=5;
  FlowAccuracyMinus:=5;
  FStatus := FLOWRATE_STOPED;
  FAction := FLOWRATE_STOP;
end;



procedure TFlowRate.SetFlowRateMax(const Value: Double);
begin
  if Value > 1000 then Exit;
  if Value < 0 then Exit;
  if Value < FFlowRateMax then Exit;

    FFlowRateMax := Value;
end;


procedure TFlowRate.SetFlowRateMin(const Value: Double);
begin
  if Value > 1000 then Exit;
  if Value < 0 then Exit;
  if Value > FFlowRateMax then Exit;

  FFlowRateMin := Value;
end;


function TFlowRate.GetIsRunning: Boolean;
begin
  Result := (FStatus = FLOWRATE_STARTED);
end;


function TFlowRate.GetIsChanging: Boolean;
begin
  Result := Abs(FFlow - FFlowSet) > 0.0001;     // неправильная логика
end;


procedure TFlowRate.SetFlowRate(ANewValue: Double);
begin
  if ANewValue < FFlowRateMin then
    FFlowSet := FFlowRateMin
  else if ANewValue > FFlowRateMax then
    FFlowSet := FFlowRateMax
  else
    FFlowSet := ANewValue;

  FAction := FLOWRATE_SET;
end;


procedure TFlowRate.Start;
begin

    if FFlowSet<FFlowRateMin then
      FFlowSet:=FFlowRateMin;
    if FFlowSet>FFlowRateMax then
      FFlowSet:=FFlowRateMax;


  //FFlow := FFlowSet;
  FStatus := FLOWRATE_STARTED;
  FAction := FLOWRATE_START;
end;


procedure TFlowRate.Stop;
begin
  //FFlow := 0;
  //FSetValue := 0;
  FStatus := FLOWRATE_STOPED;
  FAction := FLOWRATE_STOP;
end;





function TFlowRate.GetStateAsString: string;
begin
  case FStatus of
    FLOWRATE_STARTED: Result := 'Запущен';
    FLOWRATE_STOPED: Result := 'Остановлен';
  else
    Result := 'Неизвестно';
  end;
end;

function TFlowRate.GetActionAsString: string;
begin
  case FAction of
    FLOWRATE_START: Result := 'Запущен';
    FLOWRATE_SET: Result := 'Изменен расход воды';
    FLOWRATE_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;
  {$ENDREGION 'TFlowRate'}

   {$REGION 'TPump'}
constructor TPump.Create(const APumpName: string);
begin
  inherited Create;
  FName := APumpName;
  FFreqMax:= 50;
  FFreqMin:= 12;

  FFreq:=0;
  FFreqSet := FFreqMin;
  FStatus := PUMP_STOPED;
  FAction:= PUMP_STOP;

end;

destructor TPump.Destroy;
begin
  inherited;
end;

function TPump.GetIsRunning: Boolean;
begin
  Result := (FStatus = PUMP_STARTED);
end;

function TPump.GetIsChanging: Boolean;
begin
  Result :=  FFreqSet<>FFreq;
end;


procedure TPump.SetFreqMax(const Value: Double);
begin
  if Value > 1000 then Exit;
  if Value < 0 then Exit;
  if Value < FFreqMin then Exit;

    FFreqMax := Value;
end;


procedure TPump.SetFreqMin(const Value: Double);
begin
  if Value > 1000 then Exit;
  if Value < 0 then Exit;
  if Value > FFreqMax then Exit;

  FFreqMin := Value;
end;

procedure TPump.Start;
begin
  if NOT IsRunning then
  begin

    if FFreqSet<FFreqMin then
      FFreqSet:=FFreqMin;
    if FFreqSet>FFreqMax then
      FFreqSet:=FFreqMax;

    // Здесь может быть логика запуска насоса (вызов внешних процедур и т. д.)
    // После успешного запуска устанавливаем рабочее состояние
    FAction := PUMP_START;
  end;
end;

procedure TPump.Stop;
begin
  if IsRunning then
  begin
    FAction := PUMP_STOP;
    //FFreqSet := 0.0;
    // Здесь может быть логика остановки насоса
  end;
end;

procedure TPump.SetFrequency(ANewFreq: Double);
begin

      if Abs(FFreq - ANewFreq) < 0.001 then
        Exit; // Частота не изменилась

      if ANewFreq<FFreqMin then
        FFreqSet:=FFreqMin
      else if ANewFreq>FFreqMax then
        FFreqSet:=FFreqMax
      else
        FFreqSet:=ANewFreq;

      FAction:=PUMP_SET;

end;

function TPump.GetStateAsString: string;
begin
  case FStatus of
    PUMP_STOPED: Result := 'Остановлен';
    PUMP_STARTED: Result := 'Работает (мин. частота)';
  else
    Result := 'Неизвестно';
  end;
end;

function TPump.GetActionAsString: string;
begin
  case FAction of
    PUMP_STOP: Result := 'Остановливается';
    PUMP_START: Result := 'Запускается';
    PUMP_SET: Result := 'Меняется частота';
  else
    Result := 'Неизвестно';
  end;
end;


  {$ENDREGION 'TPump'}

end.
