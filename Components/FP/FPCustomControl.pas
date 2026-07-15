
unit FPCustomControl;

interface

uses
  System.Classes, System.UITypes,FMX.Controls, FMX.Objects, FMX.Graphics, FMX.Styles,FMX.Styles.Objects,
  uFmxStrConsts,
  FMX.Types, FMX.Controls.Presentation,
  FMX.Text,
  FMX.Effects,
  FmxFPModule;
type
  TParameterType = (ptComboBox, ptNumber,ptFloat, ptText,ptBool, ptMemo);
  TFmxFPParameter = record
    Name: string;   //название параметра
    ParamType: TParameterType;//тип
    Items: TArray<string>; // заполняемый список вариантов для комбобокса
  end;
  TOutlayType=(otCubeMeterPerHour,otLiterPerHour,otLiterPerMinute,otLiterPerSecond);
  TTypeOfAppFunc=(tafDigit,tafMaska);
  TLeds=(lpLED1=0,lpLED2);
  TFPControlState=(fpsEnabled,fpsDisguise,fpsEnabledSelected,fpsDisabled,fpsDisabledSelected,fpsError,fpsEditing);
  TFmxColorSheme=(fcsGray=0,fcsBlue,fcsGreen,fcsRed,fcsYellow,fcsNotAssigned);
//  === FMX.Types ====
//  TNotifyEvent = procedure(Sender: TObject) of object;
//  TMouseEvent = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single) of object;
//  TMouseMoveEvent = procedure(Sender: TObject; Shift: TShiftState; X, Y: Single) of object;
//  TMouseWheelEvent = procedure(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean) of object;
//  TKeyEvent = procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState) of object;
//  TProcessTickEvent = procedure(Sender: TObject; time, deltaTime: Single) of object;
//  TVirtualKeyboardEvent = procedure(Sender: TObject; KeyboardVisible: Boolean; const Bounds : TRect) of object;
//  TTapEvent = procedure(Sender: TObject; const Point: TPointF) of object;
//  TTouchEvent = procedure(Sender: TObject; const Touches: TTouches; const Action: TTouchAction) of object;

const
  cBooleanName:array[boolean] of String=(cNo,cYes);
  cSimpleBooleanName:array[boolean] of String=('0','1');
  cFmxShemeVirtualImageHeader='shape';
  cFmxStyleName='style';
  сScrollbarStyleName='scrollbar';
  cEditFrame='editframe';
//  сPositionBarStyleName='positionbar';
  сSWITCHPropertyCount=7;
  cTypeOfProtocols:array[TTypeOfProtocol] of String=('Частный','Modbus RTU','Modbus ASCII','Modbus TCP');
  cOtherViewName:array[boolean] of string=(cStandart,cOtherView);
  cTankPositionName:array[boolean] of string=(cTankToLeft,cTankToRight);
  cTypeOfAppFunc:array[TTypeOfAppFunc] of String=(cNumber,cMask);
  cOutlayTypeNameVolume:array[TOutlayType] of String=('м3/ч','л/ч','л/мин','л/сек');
  cOutlayTypeNameMassa:array[TOutlayType] of String=('т/ч','кг/ч','кг/мин','кг/сек');
  cFmxColorShemeName:array[TFmxColorSheme] of String=('gray','blue','green','red','yellow','none');
  cFmxShemeColorNames:array[TFmxColorSheme] of String=(
    cShapeColorGray,
    cShapeColorBlue,
    cShapeColorGreen,
    cShapeColorRed,
    cShapeColorYellow,
    cShapeColorNotAssigned
  );

  сSWITCHPropertys:array[0..сSWITCHPropertyCount-1]of string=(
  cHint,cLeft,cTop,cWidth,cHeight,cMask,cVisible);
type
  TChangedClassName=(ccnNone,ccnEdit,ccnTrackBar,ccnStartStopButton,ccnOpenButton,ccnCloseButton);
  TControlType=(ctFlowmter=0,ctScale,ctFCD,ctPump,ctUnoperatedFlowPump,
               ctUnoperatedValve,ctPneumaticValve,ctElectricValve,ctBlcedValve,
               ctFlowmetersPanel,ctLevelDetector,ctHeater,ctThermometer,
               ctManometer,ctIVTM,ctSWITCH,ctTEXT,ctPIPE,ctWaterLevel,ctDeskTop,ctSchemePrimitive,ctFrame,ctBarometer,ctHygrometer,ctShape,ctEdit,ctCoilCheckList,ctFinalElement);
  TAppFunctionalType=(
    aftHydraulicSheme=0,
    aftFlowmeter,
    aftScale,
    aftWaterPressure,
    aftAirSystemPressure,
    aftHeatingSystem,
    aftScaleOverflowDetector,//переполнение бака весов
    aftWorkLevelDetector,    //рабочий уровень установки
    aftMinLevelDetector,     //аварийный уровень
    aftScaleSlivDetector,    //датчик слива
    aftOpenSheme,
    aftCloseSheme,
    aftBypassWithScale,
    aftBypassWithoutScale,
    aftFillPipe,
    aftPump,
    aftUnoperatedPump,
    aftSemaphore,
    aftCoriolis,
    aftValvesMask,
    aftHydroBlow, //гидроудар
    aftStartInit,   //Начальная инициализация
    aftParking,   //Парковка
    aftDeskTop,
    aftAskingBeforExec,
    aftEnvironment,//Окружающая среда
    aftPourOutOverflow,//датчики на емкости - куда сливается вода - контроль переполнения
    aftReset,//сброс состояния перед запуском счета на 500 мсек
    aftActivDiscretsDuringWeight,//если насосы не выключаем при взвешивании
    aftDeskTopPlus,//Дополнительная функция с привязкой по рабочему столу
    aftDeskTopBlock,
    aftStartStop
  );
  TAppFunctionalTypeSet = set of TAppFunctionalType;
  TAppFunctionalTypeSetName=array[TAppFunctionalType]of String;
const
  cAppFunctionalTypeName:TAppFunctionalTypeSetName=(
    'Все режимы',  //общее
    'Расходомер',  //связан с расходомерной линией
    'Весы', //вычисления для весов
    'Давление воды',  //водяной контур установки - т.н. Коллайдер
    'Давление воздуха',//воздущный контур запорной арматуры
    'Нагрев воды',    //наргев воды
    'Перелив',        //система контроля за переливом
    'Рабочий уровень',        //рабочий уровень - начинать работу нельзя, если остуствует сигнал, но продолжать можно
    'Аварийный уровень',      //аварийный уровень - ниже нельзя
    'Опустошение',    //слив жидкостей
    'Открытая схема',//Через СР1
    'Закрытая схема',//Коллайдер
    'Байпас по весам',//Если требуется активировать байпас по весам
    'Байпас без весов',//Если требуется активировать байпас без весов
    'Заполнение трубы',//Если требуется заполнение трубы
    'Заполнение системы',//используется в заполнении системы
    'Нерегулируемый насос',//используется неуправляемым наоосом (в паре насос задвижка)
    'Семафор',        //линия управления красным и зеленым светофором
    'Кориолис',       //Кориолисовы расходомеры
    'Клапаны/задвижки',//Клапаны из ГС
    'Гидроудар',//клапаны, которые могут привести к гидроудару
    'Начальная установка',//клапаны, которые при старте должны занять треуемую позицию
    'Конечная установка',//клапаны, которые при парковке должны занять треуемую позицию
    'Рабочий стол',
    'Запрос перед исполнением',
    'Окружающая среда',
    'Уровень емкости слива',//уровень воды в емкости, куда сливается вода
    '', //Контакт реле, подающий уровень на линию питания контроллеров, и перед началом счета, сбрасывающил питание на 500мсек
    '',//Состояние насосов при взвешивании
    'Рабочий стол +',//Доп функция с привязкой к рабочему столу
    'Блокировка рабочего стола',//Блокировка рабочего стола
    'Старт/Стоп' //Контакт реле, подающий уровень на линию разрешения счета
  );
type
  TFPCustomControl = class(TStyledControl)
  private
    FMax: Single;
    FMin: Single;
    FDesignMode: Boolean;
    FEditing: boolean;
    FState: TFPControlState;
    FPreviousState: TFPControlState;
    FStateVisible: boolean;
    FPreviousStateVisible: boolean;
    FLEDON:array[TLeds] of TAlphaColor;
    FLEDOFF:array[TLeds] of TAlphaColor;
    FLedState:array[TLeds] of boolean;
    FInputValue: Single;
    FScrollBarPosition: Single;
    FEditValue: Single;
    FTextColor: TAlphaColor;
    FCaptionColor: TAlphaColor;
//    FExtValue: String;
    FValueMask: String;
    FExtColor: TAlphaColor;
    FLedVisible: boolean;
    FLedsCount: byte;
    FFloatTag: Single;
    FOnChange: TNotifyEvent;
    FCCN: TChangedClassName;
    Fedittype: TNumValueType;
    FDecimalDigits: byte;
    FOtherView: Boolean;
    FFull: Boolean;
    FShortHeight: Single;
    FLongHeight: Single;
    FCaptionBackgroundColor: TAlphaColor;
    FColorSheme: TFmxColorSheme;
    FTypeOfAppFunc: TTypeOfAppFunc;
    FControlType:TControlType;
    FDraggingOffsetX: Single;
    FDraggingOffsetY: Single;
    FDragging: Boolean;
    FScrollVsEdit: Single;
    Fclr: TAlphaColor;
    Fbackclr: TAlphaColor;
    FShiftT: Single;
    FShiftL: Single;
    FCaption:String;
    FExt:String;
    FControlsEnabled: boolean;
    FMoving: boolean;
    FEditFrame: TRectangle;
    ShadowEffect: TShadowEffect;
    FShadow: Boolean;
    //Тип компонента (Датчик, Эталонный расходомер,  Насос, УПП и т.п.)
    function GetControlType: TControlType;
    procedure SetControlType(const Value: TControlType);
    function GetCaption: String;
    procedure SetPreviousState(const Value: TFPControlState);
    procedure SetCaptionColor(const Value: TAlphaColor);
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetExtValue(const Value: String);
    procedure SetValueMask(const Value: String);
    function GetInputValue: Single;
    function GetExtValue: String;
    procedure SetExtColor(const Value: TAlphaColor);
    function GetExtColor: TAlphaColor;
    function GetTextColor: TAlphaColor;
    procedure SetLedVisible(const Value: boolean);
    procedure SetStateVisible(const Value: boolean);
    function GetLedOFF(aLed: TLeds): TAlphaColor;
    function GetLedON(aLed: TLeds): TAlphaColor;
    function GetLedState(aLed: TLeds): boolean;
    procedure SetLedOFF(aLed: TLeds; const Value: TAlphaColor);
    procedure SetLedON(aLed: TLeds; const Value: TAlphaColor);
    procedure SetLedState(aLed: TLeds; const Value: boolean);
    procedure SetFloatTag(const Value: Single);
    function GetLED1Light: boolean;
    function GetLED1OFFColor: TAlphaColor;
    function GetLED1ONColor: TAlphaColor;
    function GetLED2OFFColor: TAlphaColor;
    function GetLED2ONColor: TAlphaColor;
    procedure SetLED1Light(const Value: boolean);
    procedure SetLED1OFFColor(const Value: TAlphaColor);
    procedure SetLED1ONColor(const Value: TAlphaColor);
    procedure SetLED2OFFColor(const Value: TAlphaColor);
    procedure SetLED2ONColor(const Value: TAlphaColor);
    function GetLED2Light: boolean;
    procedure SetLED2Light(const Value: boolean);
    function GetLeft: Single;
    function GetTop: Single;
    procedure SetLeft(const Value: Single);
    procedure SetTop(const Value: Single);
    function GetButtonText: string;
    procedure SetButtonText(const Value: string);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetCCN(const Value: TChangedClassName);
    procedure Setedittype(const Value: TNumValueType);
    procedure SetDecimalDigits(const Value: byte);
    procedure SetOtherView(const Value: Boolean);
    procedure UpdateInputValue;
    function GetInfotext: string;
    procedure SetInfotext(const Value: string);
    function GetInputValueWithExtension: string;
    procedure SetFull(const Value: Boolean);
    procedure SetLongHeight(const Value: Single);
    procedure SetShortHeight(const Value: Single);
    function GetControlPanelVisible: boolean;
    procedure SetControlPanelVisible(const Value: boolean);
    function GetAFIdx: integer;
    function GetAFTypeSet: TAppFunctionalTypeSet;
    function GetIdx: integer;
    procedure SetAFIdx(const Value: integer);
    procedure SetAFTypeSet(const Value: TAppFunctionalTypeSet);
    procedure SetIdx(const Value: integer);
    procedure SetDesignMode(const Value: Boolean);
    procedure SetTypeOfAppFunc(const Value: TTypeOfAppFunc);
    procedure SetDragging(const Value: Boolean);
    procedure SetDraggingOffsetX(const Value: Single);
    procedure SetDraggingOffsetY(const Value: Single);
    function GetEditValue: Single;
    procedure SetEditValue(const Value: Single);
    function GetEditMax: Single;
    function GetEditMin: Single;
    procedure SetEditMax(const Value: Single);
    procedure SetEditMin(const Value: Single);
    function GetScrollBarPositionValue: Single;
    function GetScrollBarPositionMax: Single;
    function GetScrollBarPositionMin: Single;
    procedure SetScrollBarPosition(const Value: Single);
    procedure SetScrollBarPositionMax(const Value: Single);
    procedure SetScrollBarPositionMin(const Value: Single);
    procedure SetScrollVsEdit(const Value: Single);
    procedure Setbackclr(const Value: TAlphaColor);
    procedure Setclr(const Value: TAlphaColor);
    function GetButtonEnabled: boolean;
    procedure SetButtonEnabled(const Value: boolean);
    function GetEditEnabled: boolean;
    procedure SetEditEnabled(const Value: boolean);
    function GetControlPanelEnabled: boolean;
    procedure SetControlPanelEnabled(const Value: boolean);
    function GetParamName(Row: integer): string;
    function GetParamsCount: integer;
    function GetParamNameType(Row: integer): TParameterType;
    procedure SetShiftL(const Value: Single);
    procedure SetShiftT(const Value: Single);
    function GetParamItemIndex(Row: integer): Integer;
    function GetParamFloatValue(Row: integer): Single;
    function GetParamItems(Row: integer): TArray<string>;
    function GetParamBoolValue(Row: integer): Boolean;
    procedure SetControlsEnabled(const Value: boolean);
    procedure UpdateLedColor(ALed: TStyledControl; AColor: TAlphaColor);
    procedure SetLedColorSimple(LedName: String; AColor: TAlphaColor);
    procedure SetVisibleHeader(const Value: boolean);
    function GetVisibleHeader: boolean;
    function GetVisibleBody: boolean;
    function GetVisibleFooter: boolean;
    function GetVisibleInformation: boolean;
    procedure SetVisibleBody(const Value: boolean);
    procedure SetVisibleFooter(const Value: boolean);
    procedure SetVisibleInformation(const Value: boolean);
    function GetVisibleMainBody: boolean;
    procedure SetVisibleMainBody(const Value: boolean);
    function GetEditWidth: Single;
    procedure SetEditWidth(const Value: Single);
    function GetVisibleLeds: boolean;
    procedure SetVisibleLeds(const Value: boolean);
    function GetInputText: String;
    procedure SetInputText(const Value: String);
    procedure UpdateEditFrame;
    procedure SetEditFrame(const Value: TRectangle);
    procedure SetShadow(const Value: Boolean);
    { Private declarations }
  protected
    FParameters: TArray<TFmxFPParameter>;
    FIdx:integer;//Индекс в массиве построения компонентов - Z уровень
    FAFTypeSet:TAppFunctionalTypeSet;
    FAFIdx:integer;
    { Protected declarations }
    procedure SetState(const Value: TFPControlState);virtual;
    procedure SetEditing(const Value: boolean);virtual;
    procedure SetCaption(const Value: String);virtual;
    procedure OnAnimationTimer(Sender: TObject);
    function GetParamValue(Row: integer): String;virtual;
    procedure SetParamValue(Row: integer; const Value: String);virtual;abstract;
    function GetRebootWarning(Row: integer): Boolean;virtual;
    procedure UpdateLeds(aLed:TLeds);
    procedure DoOnClick(Sender: TObject);virtual;
    procedure DoOnMouseEnter(Sender: TObject);virtual;
    procedure DoOnMouseLeave(Sender: TObject);virtual;
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);virtual;
    procedure DoOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);virtual;
    procedure DoOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);virtual;
    procedure DoOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);virtual;
    function GetMax: Single;virtual;
    function GetMin: Single;virtual;
    procedure SetInputValue(const aValue: Single);virtual;
    procedure SetMax(const Value: Single);virtual;
    procedure SetMin(const Value: Single);virtual;

    procedure SetColorSheme(const Value: TFmxColorSheme);virtual;
    function GetCurState: string;virtual;
    procedure DoOnChange(Sender: TObject);virtual;
    procedure UpdateStyle;virtual;
    procedure SetLedsCount(const Value: byte);virtual;
    function FindStyleObject(const StyleName: string): TFmxObject;virtual;
    procedure RefreshStyle;virtual;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillParametersList;virtual;
    property ControlType:TControlType  read GetControlType write SetControlType;
    property TypeOfAppFunc:TTypeOfAppFunc read FTypeOfAppFunc write SetTypeOfAppFunc;
    property DesignMode:Boolean read FDesignMode write SetDesignMode default False;
    property Idx:integer read GetIdx write SetIdx;
    property AFTypeSet:TAppFunctionalTypeSet read GetAFTypeSet write SetAFTypeSet;
    property AFIdx:integer read GetAFIdx write SetAFIdx;
    property CurrentState:string read GetCurState;
    property LedON[aLed:TLeds]:TAlphaColor read GetLedON write SetLedON;
    property LedOFF[aLed:TLeds]:TAlphaColor read GetLedOFF write SetLedOFF;
    property LedState[aLed:TLeds]:boolean read GetLedState write SetLedState;
    property LedVisible:boolean read FLedVisible write SetLedVisible;
    property LedsCount:byte read FLedsCount write SetLedsCount;
    property LED1ONColor:TAlphaColor read GetLED1ONColor write SetLED1ONColor;
    property LED1OFFColor:TAlphaColor read GetLED1OFFColor write SetLED1OFFColor;
    property LED2ONColor:TAlphaColor read GetLED2ONColor write SetLED2ONColor;
    property LED2OFFColor:TAlphaColor read GetLED2OFFColor write SetLED2OFFColor;
    property ForeColor:TAlphaColor read Fclr write Setclr;
    property BackColor:TAlphaColor read Fbackclr write Setbackclr;
    property ParamsCount:integer read GetParamsCount;
    property ParamName[Row:integer]:string read GetParamName;
    property ParamType[Row:integer]:TParameterType read GetParamNameType;
    property ParamValue[Row:integer]:String read GetParamValue write SetParamValue;
    property ParamBoolValue[Row:integer]:Boolean read GetParamBoolValue;
    property ParamFloatValue[Row:integer]:Single read GetParamFloatValue;
    property ParamItemIndex[Row:integer]:Integer read GetParamItemIndex;
    property ParamItems[Row:integer]:TArray<string> read GetParamItems;
    property RebootWarning[Row:integer]:Boolean read GetRebootWarning;
  published
    { Published declarations }
    property Align;
    property Enabled;
    property StyleLookup;
    property Position;
    property Width;
    property Height;
    property RotationAngle;
    property RotationCenter;
    property ShowHint;
    property Hint;
    property OnClick;
    property OnMouseDown;
    property Visible;
    property LED1Light:boolean read GetLED1Light write SetLED1Light;
    property LED2Light:boolean read GetLED2Light write SetLED2Light;
    property State:TFPControlState read FState write SetState;//текущее состояние
    property StateVisible:boolean read FStateVisible write SetStateVisible;
    property PreviousState:TFPControlState read FPreviousState write SetPreviousState;//состояние до редактирования
    property Editing:boolean read FEditing write SetEditing;//состояние редактирования
    property Caption:String read GetCaption write SetCaption;
    property CaptionColor:TAlphaColor read FCaptionColor write SetCaptionColor;
    property InputText:String read GetInputText write SetInputText;
    property InputValue:Single read GetInputValue write SetInputValue;
    property EditValue:Single read GetEditValue write SetEditValue;
    property EditMin:Single read GetEditMin write SetEditMin;
    property EditMax:Single read GetEditMax write SetEditMax;
    property EditWidth:Single read GetEditWidth write SetEditWidth;
    property ScrollBarPosition:Single read GetScrollBarPositionValue write SetScrollBarPosition;
    property ScrollBarPositionMin:Single read GetScrollBarPositionMin write SetScrollBarPositionMin;
    property ScrollBarPositionMax:Single read GetScrollBarPositionMax write SetScrollBarPositionMax;
    property ValueColor:TAlphaColor read GetTextColor write SetTextColor;
    property ValueMask:String read FValueMask write SetValueMask;
    property Ext:String read GetExtValue write SetExtValue;
    property ExtColor:TAlphaColor read GetExtColor write SetExtColor;
    property FloatTag:Single read FFloatTag write SetFloatTag;
    property Left:Single read GetLeft write SetLeft;
    property Top:Single read GetTop write SetTop;
    property ButtonText:string read GetButtonText write SetButtonText;
    property ButtonEnabled:boolean read GetButtonEnabled write SetButtonEnabled;
    property EditEnabled:boolean read GetEditEnabled write SetEditEnabled;
    property Infotext:string read GetInfotext write SetInfotext;
    property InputValueWithExtension:string read GetInputValueWithExtension;
    property CCN:TChangedClassName read FCCN write SetCCN;
    property OnChange:TNotifyEvent read FOnChange write SetOnChange;
    property ValueType:TNumValueType read Fedittype write Setedittype;
    property DecimalDigits:byte read FDecimalDigits write SetDecimalDigits;
    property OtherView:Boolean read FOtherView write SetOtherView;
    property ControlPanelVisible:boolean read GetControlPanelVisible write SetControlPanelVisible;
    property ControlPanelEnabled:boolean read GetControlPanelEnabled write SetControlPanelEnabled;
    property Dragging: Boolean read FDragging write SetDragging;//0-кнопки, 1-метка расхода, 2-Пауза, 3-ГC 4-Кнопка ExtraOrdinaryStop
    property DraggingOffsetX:Single read FDraggingOffsetX write SetDraggingOffsetX;
    property DraggingOffsetY:Single read FDraggingOffsetY write SetDraggingOffsetY;
    property ShiftL:Single read FShiftL write SetShiftL;
    property ShiftT:Single read FShiftT write SetShiftT;

    property Full: Boolean read FFull write SetFull default false;
    // Высота компонента в неполной форме, которая была до установки флага Full.
    property ShortHeight: Single read FShortHeight write SetShortHeight;
    property LongHeight: Single read FLongHeight write SetLongHeight;
    property ColorSheme:TFmxColorSheme read FColorSheme write SetColorSheme;
    property ScrollVsEdit:Single read FScrollVsEdit write SetScrollVsEdit;
    property Size;
    property IsFocused;
    property Min:Single read GetMin write SetMin;
    property Max:Single read GetMax write SetMax;
    property ControlsEnabled:boolean read FControlsEnabled write SetControlsEnabled;
    property VisibleHeader:boolean read GetVisibleHeader write SetVisibleHeader;
    property VisibleFooter:boolean read GetVisibleFooter write SetVisibleFooter;
    property VisibleBody:boolean read GetVisibleBody write SetVisibleBody;
    property VisibleMainBody:boolean read GetVisibleMainBody write SetVisibleMainBody;
    property VisibleInformation:boolean read GetVisibleInformation write SetVisibleInformation;
    property VisibleLeds:boolean read GetVisibleLeds write SetVisibleLeds;
    property EditFrame:TRectangle read FEditFrame write SetEditFrame;
    property Shadow:Boolean read FShadow write SetShadow;
  end;

procedure Register;
function Str2AppFunctionalType(AValue:String):TAppFunctionalType;
function TypeSet2Int(value:TAppFunctionalTypeSet):longword;
function Int2TypeSet(value:longword):TAppFunctionalTypeSet;
function myStrToTypeOfAppFunc(Value:String):TTypeOfAppFunc;
function myStrToTypeOfProtocol(Value:String):TTypeOfProtocol;
function StrToModuleType(Value:String):TFmxModuleType;
function myStrToBool(Value:String):boolean;
function myStrToOtherView(Value:String):boolean;
function myStrToTankPosition(Value:String):boolean;
function myStrToFmxShemeColor(Value:String):TFmxColorSheme;


implementation

uses
  System.SysUtils,FMXHelper,FMX.Layouts,System.UIConsts,FmxFPColors,
  FMX.NumberBox,FMX.StdCtrls,
  FMX.Ani,
  System.Rtti;

var
  TFPCustomControlError:String;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFPCustomControl]);
end;


//============================================================================================================
function Str2AppFunctionalType(AValue:String):TAppFunctionalType;
begin
  for result:=aftStartStop  downto aftHydraulicSheme do
    if AValue=cAppFunctionalTypeName[result] then break;


end;

//============================================================================================================
function Int2TypeSet(value:longword):TAppFunctionalTypeSet;
var i:TAppFunctionalType;
begin
  result:=[];
  for i:=aftHydraulicSheme to aftStartStop do
  begin
    if (Value and (1 shl (ord(i))))<>0 then
      result:=result + [i];
  end;
end;

function myStrToTypeOfAppFunc(Value:String):TTypeOfAppFunc;
begin
   result:=tafDigit;
   if (cTypeOfAppFunc[tafMaska]=Value) or (cSimpleBooleanName[true]=Value) then
     result:=tafMaska;
end;

function myStrToTypeOfProtocol(Value:String):TTypeOfProtocol;
begin
  for result:=tpModbusTCP  downto tpProprietary do
  begin
    if Value=IntToStr(Ord(result)) then
      break
    else if Value=cTypeOfProtocols[result] then
        break;
  end;
end;


function TypeSet2Int(value:TAppFunctionalTypeSet):longword;
var i:TAppFunctionalType;
begin
  result:=0;
  for i:=aftHydraulicSheme to aftStartStop do
  begin
    if (i in Value) then
      result:=result  or  (1 shl (ord(i)));
  end;
end;


function StrToModuleType(Value:String):TFmxModuleType;
var i:integer;
begin
   result:=mtCounterEx;
   for I := ord(mtCounter) to ord(mtNone)-1 do
   begin
     if cModuleTypeNames[TFmxModuleType(I)]=Value then
     begin
       result:=TFmxModuleType(I);
       break;
     end;
   end;
end;

function myStrToBool(Value:String):boolean;
begin
   result:=false;
   if (cBooleanName[true]=Value) or (cSimpleBooleanName[true]=Value) then
     result:=true;
end;

function myStrToFmxShemeColor(Value:String):TFmxColorSheme;
var i:TFmxColorSheme;
begin
   result:=fcsGray;
   for I := TFmxColorSheme.fcsGray to TFmxColorSheme.fcsYellow do
   begin
     if UpperCase(cFmxShemeColorNames[i])=UpperCase(Value) then
     begin
       result:=i;
       break;
     end;
   end;
end;

function myStrToOtherView(Value:String):boolean;
begin
   result:=false;
   if (cOtherViewName[true]=Value) or (cSimpleBooleanName[true]=Value) then
     result:=true;
end;


function myStrToTankPosition(Value:String):boolean;
begin
   result:=false;
   if cTankPositionName[true]=Value then
     result:=true;
end;



{ TFPCustomControl }

constructor TFPCustomControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScrollVsEdit:=1;
  FEditing:=False;
  FMoving :=False;
  FCCN := ccnNone;
  FStateVisible := True;
  FMin:=0;
  FMax:=100;
  FLedsCount:=2;
  FLedVisible:=True;
  FState:=fpsEditing;
  FValueMask := '0.0#';
  FDecimalDigits:=2;
  StylesData['caption_background.fill.color']:=TAlphaColors.Green;
  //Подписываемся под заголоовок
  StylesData['header.OnClick']:=TValue.From<TNotifyEvent>(DoOnClick);
  StylesData['header.OnMouseEnter']:=TValue.From<TNotifyEvent>(DoOnMouseEnter);
  StylesData['header.OnMouseLeave']:=TValue.From<TNotifyEvent>(DoOnMouseLeave);
  StylesData['header.OnMouseMove']:=TValue.From<TMouseMoveEvent>(DoOnMouseMove);
  StylesData['header.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  StylesData['header.OnMouseUp']:=TValue.From<TMouseEvent>(DoOnMouseUp);
  //Подписываемся под осноное тело компонента
  StylesData['mainbody.OnClick']:=TValue.From<TNotifyEvent>(DoOnClick);
  StylesData['mainbody.OnMouseEnter']:=TValue.From<TNotifyEvent>(DoOnMouseEnter);
  StylesData['mainbody.OnMouseLeave']:=TValue.From<TNotifyEvent>(DoOnMouseLeave);
  StylesData['mainbody.OnMouseMove']:=TValue.From<TMouseMoveEvent>(DoOnMouseMove);
  StylesData['mainbody.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  StylesData['mainbody.OnMouseUp']:=TValue.From<TMouseEvent>(DoOnMouseUp);

  StylesData['mainbody.OnMouseMove']:=TValue.From<TMouseMoveEvent>(DoOnMouseMove);

  StylesData['scrollbar.OnChange']:=TValue.From<TNotifyEvent>(DoOnChange);
  StylesData['startstopbutton.OnClick']:=TValue.From<TNotifyEvent>(DoOnChange);
  StylesData['openbutton.OnClick']:=TValue.From<TNotifyEvent>(DoOnChange);
  StylesData['closebutton.OnClick']:=TValue.From<TNotifyEvent>(DoOnChange);
  StylesData['editvalue.OnChange']:=TValue.From<TNotifyEvent>(DoOnChange);
  FLedState[lpLED1]:=True;
  FLedState[lpLED1]:=True;
  FLedON[lpLED1]:=TAlphaColors.Green;
  FLedOFF[lpLED1]:=TAlphaColors.Lightgray;
  FLedON[lpLED2]:=TAlphaColors.Green;
  FLedOFF[lpLED2]:=TAlphaColors.Lightgray;
  HitTest := True; // Убедитесь, что компонент может получать фокус
//  OnMouseDown := DoOnMouseDown; // Привязка события OnMouseDown
  ColorSheme:=fcsGray;
  LED1Light:=False;
  LED2Light:=False;
  FillParametersList();//Заполняем структуру

// Создаем экземпляр TShadowEffect
  ShadowEffect := TShadowEffect.Create(Self);
  FShadow:=False;

  // Настраиваем свойства эффекта
  ShadowEffect.Direction := 45; // Направление тени в градусах
  ShadowEffect.Distance := 5;   // Расстояние тени
  ShadowEffect.Opacity := 0.5;  // Прозрачность (0..1)
  ShadowEffect.Softness := 0.3; // Мягкость границ (0..1)
  ShadowEffect.ShadowColor := TAlphaColorRec.Gray; // Цвет тени
  ShadowEffect.Enabled:=False;

  // Подключаем эффект к компоненту
  AddObject(ShadowEffect);
end;


destructor TFPCustomControl.Destroy;
begin
  ShadowEffect.Free;
  ShadowEffect:=nil;
  inherited;
end;

procedure TFPCustomControl.DoOnChange(Sender: TObject);
begin
  if Sender.ClassName='TNumberBox' then
     CCN:=ccnEdit
  else if Sender.ClassName='TTrackBar' then
     CCN:=ccnTrackBar
  else if Sender.ClassName='TCornerButton' then
     CCN:=ccnStartStopButton
  else if Sender.ClassName='TSpeedButton' then
  begin
     if TFPCustomControl(Sender).tag=1 then
        CCN:=ccnOpenButton
     else
        CCN:=ccnCloseButton;
  end;

  if Assigned(OnChange) then
  begin
     OnChange(Sender);
     CCN:=ccnNone;
  end;
end;

procedure TFPCustomControl.DoOnClick(Sender: TObject);
begin
  SetFocus;
  if Assigned(OnClick) then
     OnClick(self);
end;




procedure TFPCustomControl.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Assigned(OnMouseDown) then
     OnMouseDown(self,Button,Shift,X, Y);
end;

procedure TFPCustomControl.DoOnMouseEnter(Sender: TObject);
begin
  if Assigned(OnMouseEnter) then
     OnMouseEnter(self);
end;

procedure TFPCustomControl.DoOnMouseLeave(Sender: TObject);
begin
  if Assigned(OnMouseLeave) then
     OnMouseLeave(self);
end;

procedure TFPCustomControl.DoOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Assigned(OnMouseMove) then
     OnMouseMove(self,Shift,X, Y);
end;

procedure TFPCustomControl.DoOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
begin
  if Assigned(OnMouseUp) then
     OnMouseUp(self,Button,Shift,X, Y);
end;

procedure TFPCustomControl.DoOnMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  if Assigned(OnMouseWheel) then
     OnMouseWheel(self,Shift,WheelDelta,Handled);
end;

procedure TFPCustomControl.FillParametersList;
begin
   SetLength(FParameters,0);
end;

function TFPCustomControl.FindStyleObject(const StyleName: string): TFmxObject;
var
  StyleBook: TFmxObject;
begin
  if not Assigned(Scene) then
    Exit(nil);

  if not Assigned(Scene.StyleBook) then
    StyleBook := TStyleManager.ActiveStyleForScene(Scene)
  else
    StyleBook := Scene.StyleBook.Style;

  if not Assigned(StyleBook) then
    Exit(nil);

  Result := StyleBook.FindStyleResource(StyleName);
end;


function TFPCustomControl.GetAFIdx: integer;
begin
  result:=FAFIdx;
end;

function TFPCustomControl.GetAFTypeSet: TAppFunctionalTypeSet;
begin
  result:=FAFTypeSet;
end;

function TFPCustomControl.GetButtonEnabled: boolean;
begin
  result:=StylesData['startstopbutton.enabled'].AsBoolean;
end;

function TFPCustomControl.GetButtonText: string;
begin
  result:=StylesData['startstopbutton.text'].asString;
end;

function TFPCustomControl.GetCaption: String;
begin
    result:=FCaption;
end;

function TFPCustomControl.GetControlPanelEnabled: boolean;
begin
    result := StylesData['controlpanel.enabled'].AsBoolean;
end;

function TFPCustomControl.GetControlPanelVisible: boolean;
begin
    result := StylesData['controlpanel.visible'].AsBoolean;
end;

function TFPCustomControl.GetExtColor: TAlphaColor;
begin
  FExtColor := TAlphaColor(StylesData['extension.textsettings.fontcolor'].AsInt64);
  result:=FExtColor;
end;

function TFPCustomControl.GetExtValue: String;
begin
  result:=FExt;
end;

function TFPCustomControl.GetVisibleBody: boolean;
begin
    result:=StylesData['body.visible'].asBoolean;
end;

function TFPCustomControl.GetVisibleFooter: boolean;
begin
    result:=StylesData['footer.visible'].asBoolean;
end;

function TFPCustomControl.GetVisibleHeader: boolean;
begin
    result:=StylesData['header.visible'].asBoolean;
end;

function TFPCustomControl.GetVisibleInformation: boolean;
begin
    result:=StylesData['information.visible'].asBoolean;
end;

function TFPCustomControl.GetVisibleLeds: boolean;
begin
   result:=StylesData['ledspanel.visible'].AsBoolean;
end;

function TFPCustomControl.GetVisibleMainBody: boolean;
begin
    result:=StylesData['mainbody.visible'].asBoolean;
end;

function TFPCustomControl.GetLED1Light: boolean;
begin
  result:=LedState[lpLED1];
end;

function TFPCustomControl.GetLED1OFFColor: TAlphaColor;
begin
  result:=LedOFF[lpLED1];
end;

function TFPCustomControl.GetLED1ONColor: TAlphaColor;
begin
  result:=LedON[lpLED1];
end;

function TFPCustomControl.GetLED2Light: boolean;
begin
  result:=LedState[lpLED2];
end;

function TFPCustomControl.GetLED2OFFColor: TAlphaColor;
begin
  result:=LedOFF[lpLED2];
end;

function TFPCustomControl.GetLED2ONColor: TAlphaColor;
begin
  result:=LedON[lpLED2];
end;

function TFPCustomControl.GetLedOFF(aLed: TLeds): TAlphaColor;
begin
  if aLed in [lpLED1..lpLED2] then
     result:=FLedOFF[aLed]
  else
     result:=TAlphaColorRec.Black;
end;

function TFPCustomControl.GetLedON(aLed: TLeds): TAlphaColor;
begin
  if aLed in [lpLED1..lpLED2] then
     result:=FLedON[aLed]
  else
     result:=TAlphaColorRec.Black;
end;

function TFPCustomControl.GetLedState(aLed: TLeds): boolean;
begin
  if aLed in [lpLED1..lpLED2] then
     result:=FLedState[aLed]
  else
     result:=false;
end;

function TFPCustomControl.GetLeft: Single;
begin
  result:=Position.X;
end;


function TFPCustomControl.GetParamBoolValue(Row: integer): Boolean;
var i,len:integer;
    s:string;
begin
  result:=False;
  if (Row+1) in [1..ParamsCount] then
  begin
     s:=ParamValue[Row];
     if ParamType[Row] in [ptBool] then
       result:=myStrToBool(s);
  end;
end;

function TFPCustomControl.GetParamFloatValue(Row: integer): Single;
var i,len:integer;
    s:string;
begin
  result:=0;
  if (Row+1) in [1..ParamsCount] then
  begin
     s:=ParamValue[Row];
     if ParamType[Row] in [ptNumber,ptFloat] then
       result:=StrToFloatDef(CP(s),0);
  end;
end;

function TFPCustomControl.GetParamItemIndex(Row: integer): Integer;
var i,len:integer;
    s:string;
begin
  result:=-1;
  if (Row+1) in [1..ParamsCount] then
  begin
     len:=Length(FParameters[Row].Items);
     s:=ParamValue[Row];
     if ParamType[Row]=ptComboBox then
     begin
        for I := 0 to len-1 do
        begin
          result:=i;
          if s=FParameters[Row].Items[i] then Break;
        end;
     end
  end;
end;

function TFPCustomControl.GetParamItems(Row: integer): TArray<string>;
begin
  if (Row+1) in [1..ParamsCount] then
      result:=FParameters[Row].Items
  else
      result:=nil;
end;

function TFPCustomControl.GetParamName(Row: integer): string;
begin
  if (Row+1) in [1..ParamsCount] then
      result:=FParameters[Row].Name
  else
      result:='';
end;

function TFPCustomControl.GetParamNameType(Row: integer): TParameterType;
begin
  if (Row+1) in [1..ParamsCount] then
      result:=FParameters[Row].ParamType
  else
      result:=ptText;
end;

function TFPCustomControl.GetParamsCount: integer;
begin
  result:=Length(FParameters);
end;


function TFPCustomControl.GetParamValue(Row: integer): String;
begin
  result:='';
end;

function TFPCustomControl.GetRebootWarning(Row: integer): Boolean;
begin
  result:=False;
end;

function TFPCustomControl.GetEditEnabled: boolean;
begin
  result:=StylesData['editvalue.enabled'].AsBoolean;
end;

function TFPCustomControl.GetEditMax: Single;
begin
  result:=StylesData['editvalue.Max'].AsExtended;
end;

function TFPCustomControl.GetEditMin: Single;
begin
  result:=StylesData['editvalue.Min'].AsExtended;
end;

function TFPCustomControl.GetEditValue: Single;
var
  edt:Single;
begin
  edt:=StylesData['editvalue.Value'].AsExtended;
  if edt<>FEditValue then
  begin
    FEditValue:=edt;
    if FEditValue<Min then
       FEditValue:=Min
    else if FEditValue>Max then
       FEditValue:=Max;
    result:=FEditValue;
  end;
end;

function TFPCustomControl.GetEditWidth: Single;
begin
  result:=StylesData['editvalue.width'].AsExtended;
end;

function TFPCustomControl.GetTextColor: TAlphaColor;
begin
  FTextColor := TAlphaColor(StylesData['textvalue.textsettings.fontcolor'].AsInt64);
  result:=FTextColor;
end;

function TFPCustomControl.GetIdx: integer;
begin
  result:=FIdx;
end;

function TFPCustomControl.GetInfotext: string;
begin
  result:=StylesData['info_text.text'].asString;
end;

function TFPCustomControl.GetInputText: String;
begin
  result:=StylesData['textvalue.text'].AsString;
end;

function TFPCustomControl.GetInputValue: Single;
begin
  FInputValue :=StrToFloatDef(CP(StylesData['textvalue.text'].AsString),FInputValue);
  result:=FInputValue;
end;

function TFPCustomControl.GetInputValueWithExtension: string;
begin
  result:=StylesData['textvalue.text'].asString+' '+Ext;
end;

function TFPCustomControl.GetTop: Single;
begin
  result:=Position.Y;
end;


procedure TFPCustomControl.OnAnimationTimer(Sender: TObject);
begin

end;

function TFPCustomControl.GetScrollBarPositionValue: Single;
var
  StyleObj: TStyleObject;
begin
  StyleObj := TStyleObject(FindStyleObject(сScrollbarStyleName));
  if Assigned(StyleObj) then
     FScrollBarPosition:=StylesData['scrollbar.value'].asExtended
  else
     FScrollBarPosition:=StylesData['positionbar.value'].asExtended;
  result:=FScrollBarPosition;
end;

function TFPCustomControl.GetScrollBarPositionMax: Single;
var
  StyleObj: TStyleObject;
begin
  StyleObj := TStyleObject(FindStyleObject(сScrollbarStyleName));
  if Assigned(StyleObj) then
     result:=StylesData['scrollbar.Max'].asExtended
  else
     result:=StylesData['positionbar.Max'].asExtended;
end;

function TFPCustomControl.GetScrollBarPositionMin: Single;
var
  StyleObj: TStyleObject;
begin
  StyleObj := TStyleObject(FindStyleObject(сScrollbarStyleName));
  if Assigned(StyleObj) then
     result:=StylesData['scrollbar.Min'].asExtended
  else
     result:=StylesData['positionbar.Min'].asExtended;
end;

procedure TFPCustomControl.SetTextColor(const Value: TAlphaColor);
begin
  if FTextColor <> Value then
  begin
    FTextColor := Value;
    StylesData['textvalue.textsettings.fontcolor']:=Value;
  end;
end;

procedure TFPCustomControl.UpdateInputValue;
begin
  if ValueMask<>'' then
     StylesData['textvalue.text']:=FormatFloat(ValueMask,FInputValue)
  else
     StylesData['textvalue.text']:=FloatToStrF(FInputValue, ffFixed, 15, DecimalDigits);
  StylesData['progressbar.value']:=FInputValue;
  StylesData['positionbar.value']:=FInputValue;
  StylesData['arrow.RotationAngle']:=CalculateAngle(FInputValue,Min,Max);
end;

function TFPCustomControl.GetCurState: string;
begin
  Result := Format('%s,%s,%s,%s,', [Name,ClassName,Caption,Hint])+
         FloatToStr(left)+cDiv+
         FloatToStr(Top)+cDiv+
         FloatToStr(Width)+cDiv+
         FloatToStr(Height)+cDiv+
         IntToStr(Ord(AFIdx));

end;


procedure TFPCustomControl.SetIdx(const Value: integer);
begin
  FIdx:=Value;
end;

procedure TFPCustomControl.SetInfotext(const Value: string);
begin
  StylesData['info_text.text']:=Value;
end;

procedure TFPCustomControl.SetInputText(const Value: String);
begin
  StylesData['textvalue.text']:=Value;
end;

procedure TFPCustomControl.SetInputValue(const aValue: Single);
begin
  if FInputValue <> aValue then
  begin
    if aValue>Max then
       FInputValue := Max
    else
       FInputValue := aValue;
    UpdateInputValue();
  end;
end;

procedure TFPCustomControl.SetValueMask(const Value: String);
begin
  FValueMask := Value;
  UpdateInputValue();
end;


procedure TFPCustomControl.SetTop(const Value: Single);
begin
  Position.Y:=Value;
end;

procedure TFPCustomControl.SetTypeOfAppFunc(const Value: TTypeOfAppFunc);
begin
  FTypeOfAppFunc := Value;
end;

procedure TFPCustomControl.SetScrollBarPosition(const Value: Single);
var
  StyleObj: TStyleObject;
begin
  if FScrollBarPosition <> Value then
  begin
    FScrollBarPosition := Value;
    //Если значение идет извне - отключаем измененние
    StylesData['progressbar.value']:=FScrollBarPosition;
    //StylesData['positionbar.value']:=FScrollBarPosition;//22.09.25
    StylesData['positionbar.value']:=FScrollBarPosition;//2025-12-19
    StyleObj := TStyleObject(FindStyleObject(сScrollbarStyleName));
    if Assigned(StyleObj) then
    begin
       StylesData['scrollbar.OnChange']:=nil;
       StylesData['scrollbar.value']:=Value;
       StylesData['scrollbar.OnChange']:=TValue.From<TNotifyEvent>(DoOnChange);
    end
    else
       FScrollBarPosition:=StylesData['positionbar.value'].asExtended;
  end;
end;

procedure TFPCustomControl.SetScrollBarPositionMax(const Value: Single);
var
  StyleObj: TStyleObject;
begin
  StyleObj := TStyleObject(FindStyleObject(сScrollbarStyleName));
  if Assigned(StyleObj) then
     StylesData['scrollbar.Max']:=Value
  else
     StylesData['positionbar.Max']:=Value;
end;

procedure TFPCustomControl.SetScrollBarPositionMin(const Value: Single);
var
  StyleObj: TStyleObject;
begin
  StyleObj := TStyleObject(FindStyleObject(сScrollbarStyleName));
  if Assigned(StyleObj) then
     StylesData['scrollbar.Min']:=Value
  else
     StylesData['positionbar.Min']:=Value;
end;

procedure TFPCustomControl.SetScrollVsEdit(const Value: Single);
begin
  FScrollVsEdit := Value;
end;

procedure TFPCustomControl.UpdateLedColor(ALed: TStyledControl; AColor: TAlphaColor);
begin
  if Assigned(ALed) then
  begin
    ALed.StylesData['fill.color'] := AColor;
    ALed.Repaint; // Принудительная перерисовка
    ALed.ApplyStyleLookup; // Перезагрузка стиля
  end;
end;




procedure TFPCustomControl.SetLedColorSimple(LedName: String; AColor: TAlphaColor);
begin
//  AnimateLedColor(LedName,AColor);
  try
    // Пробуем установить через StylesData
    StylesData[LedName + '.fill.color'] := AColor;
//    ApplyStyleLookup;
//    Repaint;
  except
    // Обрабатываем ошибку, если свойство не найдено
  end;
end;


procedure TFPCustomControl.UpdateLeds(aLed:TLeds);
var Led:TStyledControl;
begin
   if (csDestroying in ComponentState) or (csLoading in ComponentState) then Exit;
   case aLed of
     lpLED1: begin
        Led:= TStyledControl(Self.FindStyleResource('tled'));
        if LEDState[lpLED1] and LedVisible then
           SetLedColorSimple('tled',LedON[lpLED1])
        else
           SetLedColorSimple('tled',LedOFF[lpLED1]);
     end;
     lpLED2: begin
        Led:= TStyledControl(Self.FindStyleResource('bled'));
        if LEDState[lpLED2] and LedVisible then
           SetLedColorSimple('bled',LedON[lpLED2])
        else
           SetLedColorSimple('bled',LedOFF[lpLED2]);
     end;
   end;
end;


procedure TFPCustomControl.UpdateStyle;
begin
  try
    ControlPanelVisible:=not (State in [fpsDisguise]);
    ForeColor:=CL_FMX_COLOR_SHEME_GRAY;
       CaptionColor:=CL_FMX_WHITE;
    case ColorSheme of
      fcsGray: begin ForeColor:=CL_FMX_COLOR_SHEME_GRAY; BackColor:=CL_FMX_COLOR_BACK_SHEME_GRAY;end;
      fcsBlue: begin ForeColor:=CL_FMX_COLOR_SHEME_BLUE; BackColor:=CL_FMX_COLOR_BACK_SHEME_BLUE;end;
      fcsGreen: begin ForeColor:=CL_FMX_COLOR_SHEME_GREEN; BackColor:=CL_FMX_COLOR_BACK_SHEME_GREEN;end;
      fcsRed: begin ForeColor:=CL_FMX_COLOR_SHEME_RED; BackColor:=CL_FMX_COLOR_BACK_SHEME_RED; end;
      fcsYellow: begin ForeColor:=CL_FMX_COLOR_SHEME_YELLOW;BackColor:=CL_FMX_COLOR_BACK_SHEME_YELLOW; end;
    end;
    StylesData['colorsheme.fill.color']:=ForeColor;
    StylesData['background.fill.color']:=BackColor;
  except
    on e:exception do
       TFPCustomControlError:='Ошибка в UpdateStyle Объект:'+Caption+' E:'+e.Message;
  end;
end;

procedure TFPCustomControl.RefreshStyle;
begin

end;

procedure TFPCustomControl.SetFull(const Value: Boolean);
begin
  if Value <>  FFull then
  begin
    FFull := Value;
    if Full then begin
      ShortHeight:=Height;
      Height := LongHeight;
    end
    else begin
      LongHeight:=Height;
      Height := ShortHeight;
    end;
    UpdateStyle();
  end;
end;



procedure TFPCustomControl.SetAFIdx(const Value: integer);
begin
  FAFIdx:=Value;
end;

procedure TFPCustomControl.SetAFTypeSet(const Value: TAppFunctionalTypeSet);
begin
  FAFTypeSet:=Value;
end;

procedure TFPCustomControl.Setbackclr(const Value: TAlphaColor);
begin
  Fbackclr := Value;
end;

procedure TFPCustomControl.SetButtonEnabled(const Value: boolean);
begin
  StylesData['startstopbutton.enabled']:=Value;
  StylesData['openbutton.enabled']:=Value;
  StylesData['closebutton.enabled']:=Value;
end;

procedure TFPCustomControl.SetButtonText(const Value: string);
begin
  StylesData['startstopbutton.text']:=Value;
end;

procedure TFPCustomControl.SetCaption(const Value: String);
begin
  FCaption:=Value;
  StylesData['caption.text']:=Value;
end;


procedure TFPCustomControl.SetCaptionColor(const Value: TAlphaColor);
begin
  if FCaptionColor <> Value then
  begin
    FCaptionColor := Value;
    StylesData['caption.textsettings.fontcolor']:=Value;
  end;
end;

procedure TFPCustomControl.SetVisibleBody(const Value: boolean);
begin
  StylesData['body.visible']:=Value;
end;

procedure TFPCustomControl.SetVisibleFooter(const Value: boolean);
begin
  StylesData['footer.visible']:=Value;
end;

procedure TFPCustomControl.SetVisibleHeader(const Value: boolean);
begin
  StylesData['header.visible']:=Value;
end;

procedure TFPCustomControl.SetVisibleInformation(const Value: boolean);
begin
  StylesData['information.visible']:=Value;
end;

procedure TFPCustomControl.SetVisibleLeds(const Value: boolean);
begin
   StylesData['ledspanel.visible']:=Value;
end;

procedure TFPCustomControl.SetVisibleMainBody(const Value: boolean);
begin
  StylesData['mainbody.visible']:=Value;
end;

procedure TFPCustomControl.SetCCN(const Value: TChangedClassName);
begin
  FCCN := Value;
end;

procedure TFPCustomControl.Setclr(const Value: TAlphaColor);
begin
  Fclr := Value;
end;

procedure TFPCustomControl.SetColorSheme(const Value: TFmxColorSheme);
begin
  if FColorSheme <> Value then
  begin
    FColorSheme := Value;
    UpdateStyle();
  end;
end;

procedure TFPCustomControl.SetControlPanelEnabled(const Value: boolean);
begin
    StylesData['controlpanel.enabled']:=Value;
end;

procedure TFPCustomControl.SetControlPanelVisible(const Value: boolean);
begin
    StylesData['controlpanel.visible']:=Value;
    StylesData['body.visible']:=Value;
end;

procedure TFPCustomControl.SetControlsEnabled(const Value: boolean);
begin
  FControlsEnabled := Value;
  ButtonEnabled:=Value;
//  controlpanelenabled:=Value;
  EditEnabled:=Value;
  if Value then
  begin
    if State=fpsDisabled then State:=fpsEnabled;
    if State=fpsDisabledSelected then State:=fpsEnabledSelected;
  end
  else begin
    if State=fpsEnabled then State:=fpsDisabled;
    if State=fpsEnabledSelected then State:=fpsDisabledSelected;
  end;
end;

procedure TFPCustomControl.SetDecimalDigits(const Value: byte);
begin
  FDecimalDigits := Value;
  StylesData['editvalue.decimaldigits']:=Value;
  UpdateInputValue();
end;

procedure TFPCustomControl.SetDesignMode(const Value: Boolean);
begin
  FDesignMode := Value;
  if (not Value) and Editing then
     Editing:=False;
end;

procedure TFPCustomControl.UpdateEditFrame();
begin
  try
    if (csDestroying in ComponentState) or (csLoading in ComponentState) then Exit;
    EditFrame:=TRectangle(FindStyleResource(cEditFrame));
    if not Assigned(EditFrame) then Exit;
    if FEditing  then
    begin
      if FDragging then
      begin
        EditFrame.stroke.Dash:=TStrokeDash.Dot;
        editframe.stroke.Color:=CL_FMX_BLUE;
      end
      else begin
        EditFrame.stroke.Dash:=TStrokeDash.Solid;
        editframe.stroke.Color:=CL_FMX_GREEN;
      end;
    end
    else begin
        EditFrame.stroke.Dash:=TStrokeDash.Solid;
        editframe.stroke.Color:=CL_FMX_NULL;
    end;
  except
    on e:exception do
       TFPCustomControlError:='Ошибка в UpdateEditFrame Объект:'+Caption+' E:'+e.Message;
  end;
end;

procedure TFPCustomControl.SetDragging(const Value: Boolean);
begin
  if FDragging <> Value then
  begin
    FDragging := Value;
    UpdateEditFrame();
  end;
end;

procedure TFPCustomControl.SetDraggingOffsetX(const Value: Single);
begin
  FDraggingOffsetX := Value;
end;

procedure TFPCustomControl.SetDraggingOffsetY(const Value: Single);
begin
  FDraggingOffsetY := Value;
end;

procedure TFPCustomControl.SetExtValue(const Value: String);
begin
  FExt:=Value;
  StylesData['extension.text']:=Value;
end;

procedure TFPCustomControl.SetExtColor(const Value: TAlphaColor);
begin
  if FExtColor <> Value then
  begin
    FExtColor := Value;
    StylesData['extension.textsettings.fontcolor']:=Value;
  end;
end;

procedure TFPCustomControl.SetEditEnabled(const Value: boolean);
begin
  StylesData['editvalue.enabled']:=Value;
end;

procedure TFPCustomControl.SetEditFrame(const Value: TRectangle);
begin
  FEditFrame := Value;
end;

procedure TFPCustomControl.SetEditing(const Value: boolean);
begin
 try
  if FEditing <> Value then
  begin
      FEditing := Value;
      if Value then
      begin
         Opacity:=1;
         State:=fpsEditing;
         FPreviousStateVisible:=StateVisible;
         StateVisible:=True;
      end
      else begin
         StateVisible:=FPreviousStateVisible;
         State:=FPreviousState;
      end;
      UpdateEditFrame();
      UpdateStyle;
    end;
 except
    on e:exception do
       TFPCustomControlError:='Ошибка в SetEditing Объект:'+Caption+' E:'+e.Message;
 end;
end;


procedure TFPCustomControl.SetEditMax(const Value: Single);
begin
  StylesData['editvalue.Max']:=Value;
end;

procedure TFPCustomControl.SetEditMin(const Value: Single);
begin
  StylesData['editvalue.Min']:=Value;
end;

procedure TFPCustomControl.Setedittype(const Value: TNumValueType);
begin
  Fedittype := Value;
  StylesData['editvalue.ValueType']:=TValue.From<TNumValueType>(Value);
end;

procedure TFPCustomControl.SetFloatTag(const Value: Single);
begin
  FFloatTag := Value;
end;


procedure TFPCustomControl.SetLED1Light(const Value: boolean);
begin
  LedState[lpLED1]:=Value;
end;

procedure TFPCustomControl.SetLED1OFFColor(const Value: TAlphaColor);
begin
  LedOFF[lpLED1]:=Value;
end;

procedure TFPCustomControl.SetLED1ONColor(const Value: TAlphaColor);
begin
  LedON[lpLED1]:=Value;
end;

procedure TFPCustomControl.SetLED2Light(const Value: boolean);
begin
  LedState[lpLED2]:=Value;
end;

procedure TFPCustomControl.SetLED2OFFColor(const Value: TAlphaColor);
begin
  LedOFF[lpLED2]:=Value;
end;

procedure TFPCustomControl.SetLED2ONColor(const Value: TAlphaColor);
begin
  LedON[lpLED2]:=Value;
end;

procedure TFPCustomControl.SetLedOFF(aLed: TLeds; const Value: TAlphaColor);
begin
  if aLed in [lpLED1..lpLED2] then
  begin
     if FLedOFF[aLed]<>Value then
     begin
       FLedOFF[aLed]:=Value;
       UpdateLeds(aLed);
     end;
  end;
end;

procedure TFPCustomControl.SetLedON(aLed: TLeds; const Value: TAlphaColor);
begin
  if aLed in [lpLED1..lpLED2] then
  begin
     if FLedON[aLed]<>Value then
     begin
       FLedON[aLed]:=Value;
       UpdateLeds(aLed);
     end;
  end;
end;

procedure TFPCustomControl.SetLedsCount(const Value: byte);
begin
  FLedsCount := Value;
  StylesData['tled.visible']:=Value>0;
  StylesData['bled.visible']:=Value>1;
end;

procedure TFPCustomControl.SetLedState(aLed: TLeds; const Value: boolean);
begin
  if aLed in [lpLED1..lpLED2] then
  begin
     if FLedState[aLed]<>Value then
     begin
       FLedState[aLed]:=Value;
       UpdateLeds(aLed);
     end;
  end;
end;

procedure TFPCustomControl.SetLedVisible(const Value: boolean);
begin
  FLedVisible := Value;
  if Value then
  begin
    StylesData['tled.visible']:=LedsCount>0;
    StylesData['bled.visible']:=LedsCount>1;
  end
  else begin
    StylesData['tled.visible']:=false;
    StylesData['bled.visible']:=false;
  end;
  StylesData['ledspanel.visible']:=Value;
end;

procedure TFPCustomControl.SetLeft(const Value: Single);
begin
  Position.X:=Value;
end;

procedure TFPCustomControl.SetLongHeight(const Value: Single);
begin
  FLongHeight := Value;
end;

procedure TFPCustomControl.SetMax(const Value: Single);
begin
  StylesData['scrollbar.max']:=Value;
  StylesData['progressbar.max']:=Value;
  StylesData['positionbar.max']:=Value;
  FMax := Value;
end;

procedure TFPCustomControl.SetMin(const Value: Single);
begin
  StylesData['scrollbar.min']:=Value;
  StylesData['progressbar.min']:=Value;
  StylesData['positionbar.min']:=Value;
  FMin := Value;
end;



procedure TFPCustomControl.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TFPCustomControl.SetOtherView(const Value: Boolean);
begin
  if FOtherView <> Value then
  begin
    FOtherView := Value;
    UpdateStyle();
    RefreshStyle();
  end;
end;

procedure TFPCustomControl.SetEditValue(const Value: Single);
begin
  if (FEditValue <> Value) and (Value>=Min) and  (Value<=Max) then
  begin
    FEditValue := Value;
    //Если значение идет извне - отключаем измененние
    StylesData['editvalue.OnChange']:=nil;
    StylesData['editvalue.value']:=Value;
    StylesData['editvalue.OnChange']:=TValue.From<TNotifyEvent>(DoOnChange);
  end;
end;


procedure TFPCustomControl.SetEditWidth(const Value: Single);
begin
  StylesData['editvalue.width']:=Value;
end;

procedure TFPCustomControl.SetPreviousState(const Value: TFPControlState);
begin
  FPreviousState := Value;
end;

procedure TFPCustomControl.SetShadow(const Value: Boolean);
begin
  if FShadow <> Value then
  begin
    FShadow := Value;
    if Assigned(ShadowEffect) then
       ShadowEffect.Enabled:=Value;
  end;
end;

procedure TFPCustomControl.SetShiftL(const Value: Single);
begin
  FShiftL := Value;
end;

procedure TFPCustomControl.SetShiftT(const Value: Single);
begin
  FShiftT := Value;
end;

procedure TFPCustomControl.SetShortHeight(const Value: Single);
begin
  FShortHeight := Value;
end;

procedure TFPCustomControl.SetState(const Value: TFPControlState);
begin
  if FState <> Value then
  begin
    //Если Enabled, то затираем и предыдущее
    if not (Value in [fpsEnabled,fpsEnabledSelected,fpsDisabled,fpsDisabledSelected]) then
       PreviousState:=FState
    else
       PreviousState:=Value;

    FState := Value;
    case Value  of
      fpsEnabled: StylesData['caption_background.fill.color']:=ColorToAlphaColor($A06030);
      fpsDisguise: StylesData['caption_background.fill.color']:=TAlphaColors.Cadetblue;
      fpsEnabledSelected: StylesData['caption_background.fill.color']:=TAlphaColors.Navy;
      fpsDisabled: StylesData['caption_background.fill.color']:=TAlphaColors.DarkGray;
      fpsDisabledSelected: StylesData['caption_background.fill.color']:=TAlphaColors.Gray;
      fpsError: StylesData['caption_background.fill.color']:=TAlphaColors.Red;
      fpsEditing: StylesData['caption_background.fill.color']:=TAlphaColors.Green;
    end;
    ControlsEnabled :=  Value in [fpsEnabled,fpsEnabledSelected,fpsDisguise,fpsEditing];
    UpdateStyle();
  end;
end;


procedure TFPCustomControl.SetStateVisible(const Value: boolean);
begin
  if Editing then FPreviousStateVisible:=FStateVisible
  else FPreviousStateVisible:=Value;
  FStateVisible := Value;
  StylesData['caption_background.visible']:=Value;
end;

function TFPCustomControl.GetControlType: TControlType;
begin
  result:=FControlType;
end;

procedure TFPCustomControl.SetControlType(const Value: TControlType);
begin
  FControlType:=Value;
end;


function TFPCustomControl.GetMax: Single;
begin
  result:=FMax;
end;

function TFPCustomControl.GetMin: Single;
begin
  result:=FMin;
end;

initialization
  TFPCustomControlError:='';

end.

