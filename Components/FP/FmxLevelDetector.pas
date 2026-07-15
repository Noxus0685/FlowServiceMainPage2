unit FmxLevelDetector;



{ ===== Компонент FmxLevelDetector =====
Визуальный компонент датчика уровня, либо любого другого датчика дискретного состояния
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  System.UITypes,//TMouseButton
  FmxParamsFrm,//Форма ручного ввода параметров
  //System.Types,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;
const
  cLevelDetectorStyle='ledindicatorstyle';
type
  TAlphaColorNameItem=record
    CN:string;
    CV:TAlphaColor;
  end;
const
    //Количество свойств
    cLevelDetectorPropertyCount=25;

    //Наименования свойств
    cLevelDetectorPropertys:array[0..cLevelDetectorPropertyCount-1]of string=(
      cHeader,cHint,
      cPort,cAddress,cBaudrate,cParity,
      cModuleType,
      cLeft,cTop,cWidth,cHeight,
      cFirst,cNumAppFunction,cNumContact,
      cInputContact,cActiveColor,cPassiveColor,cColor,cVisible,cTypeAppFunc,
      cTypeOfProtocol,
      cModbusInputReg,cModulePriority,cInverse,cChannelsCount
    );

    //типы свойств
    cLevelDetectorPropertysType:array[0..cLevelDetectorPropertyCount-1]of TParameterType=(
      //  cHeader,cHint
      ptText,ptText,
      //  cPort,   cAddress,cBaudrate,
      ptNumber,ptNumber,ptNumber,
      //cParity
      ptComboBox,
      //  cModuleType,
      ptComboBox,
      //cLeft,cTop,cWidth,cHeight,
      ptFloat,ptFloat,ptFloat,ptFloat,
      //cFirst,cNumAppFunction,cNumContact,
      ptComboBox, ptNumber, ptNumber,
      //cInputContact,cActiveColor,cPassiveColor,cVisible,cTypeAppFunc,
      ptComboBox,ptNumber,ptNumber,ptNumber,ptComboBox,ptComboBox,
      //cTypeOfProtocol,
      ptComboBox,
      //cModbusInputReg,cInverse,cModulePriority
      ptNumber,ptNumber,ptComboBox,ptNumber
    );

  //Комбо выпадающие списки
  cLevelDetectorPropertyComboItems: array[0..cLevelDetectorPropertyCount-1] of TArray<string> = (
      //cHeader,cHint,
      [],[],
      //  cPort,cAddress,cBaudrate,cParity
      [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
      //  cModuleType
      [cmtHSC_CTRL,cmtSuperBIO,cmtValve,cmtBIO,cmtRT2,cmtModbusD],
      //  cLeft,cTop,cWidth,cHeight,
      [],[],[],[],
      //  cFirst,cNumAppFunction,cNumContact,
      [cNo,cYes],[],[],
      //cInputContact,cActiveColor,cPassiveColor,cVisible,cTypeAppFunc,
      [cNo,cYes],[],[],[],[cNo,cYes],[cNumber,cMask],
      //  cTypeOfProtocol,
      [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
      //cModbusInputReg,cModulePriority
      [],[],[cNo,cYes],[]
    );




type

  // Тип, используемый для определения типа модуля (не путать с одноименным типом в unit'е DeviceManager).

  //==========================================================================================================

  TFmxLevelDetector = class(TFMXDeviceCustomControl)
  private

    FInputNumber: Byte;
    FFromInput: boolean;
    FInverse: Boolean;

    procedure SetInputNumber(input_number: byte);
    procedure SetFromInput(const Value: boolean);
    function GetSubmerged: Boolean;
    function GetActiveColor: TAlphaColor;
    function GetUnactiveColor: TAlphaColor;
    procedure SetActiveColor(const Value: TAlphaColor);
    procedure SetUnactiveColor(const Value: TAlphaColor);
    function GetPriority: integer;override;
    function GetTextColor: TAlphaColor;
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetInverse(const Value: Boolean);
    function GetInverse: Boolean;

  protected
    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    function  GetModuleManager: TFmxModuleManager;override;
    procedure SetComPort(AIdx: integer; const Value: word); override;
    procedure SetAddress(AIdx: Integer; const Value: Integer); override;
    procedure SetBaudrate(AIdx: Integer; const Value: Cardinal); override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType); override;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    function  Disguise: Boolean; override;
    function  GetCurState: String; override;
    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
    procedure SetParity(const Value: TComParity);override;
    function GetMaxChannels: byte;override;
    procedure SetMaxChannels(const Value: byte);override;

  public

    // Указатель на используемое устройство.
    Device: TFmxDeviceLevelDetector;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillParametersList;override;

  published

    // Номер входа модуля, к которому подключен датчик (0-12 для SuperBIO, 6-9 для Valve).
    property InputNumber: Byte read FInputNumber write SetInputNumber default 0;

    //Цвет значка при замкнутых контактах датчика
    property ActiveColor: TAlphaColor read GetActiveColor write SetActiveColor;

    //Цвет значка при замкнутых контактах датчика
    property UnactiveColor: TAlphaColor read GetUnactiveColor write SetUnactiveColor;

    property Color:TAlphaColor read GetTextColor write SetTextColor;


    //откуда берется
    property FromInput:boolean read FFromInput write  SetFromInput default true;

    property ShowHint;

    property Submerged:Boolean read GetSubmerged;

    property Inverse:Boolean read GetInverse write SetInverse;
  end;

procedure Register;
function ColorToString(Color: TAlphaColor): string;
function StringToColor(const S: string): TAlphaColor;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     FMX.Text,
     System.Rtti;
const
  cMaxAlphaColorNameItems=155;
  cAlphaColorNamesArray: array[0..cMaxAlphaColorNameItems-1] of TAlphaColorNameItem=(
    (CN:'Alpha';     CV: TAlphaColor(TAlphaColorRec.Alpha or $000000)),
    (CN:'Aliceblue'; CV: TAlphaColor(TAlphaColorRec.Alpha or $F0F8FF)),
    (CN:'Antiquewhite'; CV: TAlphaColor(TAlphaColorRec.Alpha or $FAEBD7)),
    (CN:'Aqua'; CV: TAlphaColor(TAlphaColorRec.Alpha or $00FFFF)),
    (CN:'Aquamarine'; CV: TAlphaColor(TAlphaColorRec.Alpha or $7FFFD4)),
    (CN:'Azure'; CV: TAlphaColor(TAlphaColorRec.Alpha or $F0FFFF)),
    (CN:'Beige'; CV: TAlphaColor(TAlphaColorRec.Alpha or $F5F5DC)),
    (CN:'Bisque'; CV: TAlphaColor(TAlphaColorRec.Alpha or $FFE4C4)),
    (CN:'Black'; CV: TAlphaColor(TAlphaColorRec.Alpha or $000000)),
    (CN:'Blanchedalmond'; CV: TAlphaColor(TAlphaColorRec.Alpha or $FFEBCD)),
    (CN:'Blue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $0000FF)),
    (CN:'Blueviolet';     CV: TAlphaColor(TAlphaColorRec. Alpha or $8A2BE2)),
    (CN:'Brown';     CV: TAlphaColor(TAlphaColorRec. Alpha or $A52A2A)),
    (CN:'Burlywood';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DEB887)),
    (CN:'Cadetblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $5F9EA0)),
    (CN:'Chartreuse';     CV: TAlphaColor(TAlphaColorRec. Alpha or $7FFF00)),
    (CN:'Chocolate';     CV: TAlphaColor(TAlphaColorRec. Alpha or $D2691E)),
    (CN:'Coral';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF7F50)),
    (CN:'Cornflowerblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $6495ED)),
    (CN:'Cornsilk';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFF8DC)),
    (CN:'Crimson';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DC143C)),
    (CN:'Cyan';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00FFFF)),
    (CN:'Darkblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00008B)),
    (CN:'Darkcyan';     CV: TAlphaColor(TAlphaColorRec. Alpha or $008B8B)),
    (CN:'Darkgoldenrod';     CV: TAlphaColor(TAlphaColorRec. Alpha or $B8860B)),
    (CN:'Darkgray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $A9A9A9)),
    (CN:'Darkgreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $006400)),
    (CN:'Darkgrey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $A9A9A9)),
    (CN:'Darkkhaki';     CV: TAlphaColor(TAlphaColorRec. Alpha or $BDB76B)),
    (CN:'Darkmagenta';     CV: TAlphaColor(TAlphaColorRec. Alpha or $8B008B)),
    (CN:'Darkolivegreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $556B2F)),
    (CN:'Darkorange';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF8C00)),
    (CN:'Darkorchid';     CV: TAlphaColor(TAlphaColorRec. Alpha or $9932CC)),
    (CN:'Darkred';     CV: TAlphaColor(TAlphaColorRec. Alpha or $8B0000)),
    (CN:'Darksalmon';     CV: TAlphaColor(TAlphaColorRec. Alpha or $E9967A)),
    (CN:'Darkseagreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $8FBC8F)),
    (CN:'Darkslateblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $483D8B)),
    (CN:'Darkslategray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $2F4F4F)),
    (CN:'Darkslategrey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $2F4F4F)),
    (CN:'Darkturquoise';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00CED1)),
    (CN:'Darkviolet';     CV: TAlphaColor(TAlphaColorRec. Alpha or $9400D3)),
    (CN:'Deeppink';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF1493)),
    (CN:'Deepskyblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00BFFF)),
    (CN:'Dimgray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $696969)),
    (CN:'Dimgrey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $696969)),
    (CN:'Dodgerblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $1E90FF)),
    (CN:'Firebrick';     CV: TAlphaColor(TAlphaColorRec. Alpha or $B22222)),
    (CN:'Floralwhite';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFAF0)),
    (CN:'Forestgreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $228B22)),
    (CN:'Fuchsia';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF00FF)),
    (CN:'Gainsboro';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DCDCDC)),
    (CN:'Ghostwhite';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F8F8FF)),
    (CN:'Gold';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFD700)),
    (CN:'Goldenrod';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DAA520)),
    (CN:'Gray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $808080)),
    (CN:'Green';     CV: TAlphaColor(TAlphaColorRec. Alpha or $008000)),
    (CN:'Greenyellow';     CV: TAlphaColor(TAlphaColorRec. Alpha or $ADFF2F)),
    (CN:'Grey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $808080)),
    (CN:'Honeydew';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F0FFF0)),
    (CN:'Hotpink';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF69B4)),
    (CN:'Indianred';     CV: TAlphaColor(TAlphaColorRec. Alpha or $CD5C5C)),
    (CN:'Indigo';     CV: TAlphaColor(TAlphaColorRec. Alpha or $4B0082)),
    (CN:'Ivory';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFFF0)),
    (CN:'Khaki';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F0E68C)),
    (CN:'Lavender';     CV: TAlphaColor(TAlphaColorRec. Alpha or $E6E6FA)),
    (CN:'Lavenderblush';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFF0F5)),
    (CN:'Lawngreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $7CFC00)),
    (CN:'Lemonchiffon';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFACD)),
    (CN:'Lightblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $ADD8E6)),
    (CN:'Lightcoral';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F08080)),
    (CN:'Lightcyan';     CV: TAlphaColor(TAlphaColorRec. Alpha or $E0FFFF)),
    (CN:'Lightgoldenrodyellow';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FAFAD2)),
    (CN:'Lightgray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $D3D3D3)),
    (CN:'Lightgreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $90EE90)),
    (CN:'Lightgrey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $D3D3D3)),
    (CN:'Lightpink';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFB6C1)),
    (CN:'Lightsalmon';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFA07A)),
    (CN:'Lightseagreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $20B2AA)),
    (CN:'Lightskyblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $87CEFA)),
    (CN:'Lightslategray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $778899)),
    (CN:'Lightslategrey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $778899)),
    (CN:'Lightsteelblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $B0C4DE)),
    (CN:'Lightyellow';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFFE0)),
    (CN:'LtGray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $C0C0C0)),
    (CN:'MedGray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $A0A0A0)),
    (CN:'DkGray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $808080)),
    (CN:'MoneyGreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $C0DCC0)),
    (CN:'LegacySkyBlue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F0CAA6)),
    (CN:'Cream';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F0FBFF)),
    (CN:'Lime';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00FF00)),
    (CN:'Limegreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $32CD32)),
    (CN:'Linen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FAF0E6)),
    (CN:'Magenta';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF00FF)),
    (CN:'Maroon';     CV: TAlphaColor(TAlphaColorRec. Alpha or $800000)),
    (CN:'Mediumaquamarine';     CV: TAlphaColor(TAlphaColorRec. Alpha or $66CDAA)),
    (CN:'Mediumblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $0000CD)),
    (CN:'Mediumorchid';     CV: TAlphaColor(TAlphaColorRec. Alpha or $BA55D3)),
    (CN:'Mediumpurple';     CV: TAlphaColor(TAlphaColorRec. Alpha or $9370DB)),
    (CN:'Mediumseagreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $3CB371)),
    (CN:'Mediumslateblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $7B68EE)),
    (CN:'Mediumspringgreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00FA9A)),
    (CN:'Mediumturquoise';     CV: TAlphaColor(TAlphaColorRec. Alpha or $48D1CC)),
    (CN:'Mediumvioletred';     CV: TAlphaColor(TAlphaColorRec. Alpha or $C71585)),
    (CN:'Midnightblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $191970)),
    (CN:'Mintcream';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F5FFFA)),
    (CN:'Mistyrose';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFE4E1)),
    (CN:'Moccasin';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFE4B5)),
    (CN:'Navajowhite';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFDEAD)),
    (CN:'Navy';     CV: TAlphaColor(TAlphaColorRec. Alpha or $000080)),
    (CN:'Oldlace';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FDF5E6)),
    (CN:'Olive';     CV: TAlphaColor(TAlphaColorRec. Alpha or $808000)),
    (CN:'Olivedrab';     CV: TAlphaColor(TAlphaColorRec. Alpha or $6B8E23)),
    (CN:'Orange';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFA500)),
    (CN:'Orangered';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF4500)),
    (CN:'Orchid';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DA70D6)),
    (CN:'Palegoldenrod';     CV: TAlphaColor(TAlphaColorRec. Alpha or $EEE8AA)),
    (CN:'Palegreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $98FB98)),
    (CN:'Paleturquoise';     CV: TAlphaColor(TAlphaColorRec. Alpha or $AFEEEE)),
    (CN:'Palevioletred';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DB7093)),
    (CN:'Papayawhip';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFEFD5)),
    (CN:'Peachpuff';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFDAB9)),
    (CN:'Peru';     CV: TAlphaColor(TAlphaColorRec. Alpha or $CD853F)),
    (CN:'Pink';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFC0CB)),
    (CN:'Plum';     CV: TAlphaColor(TAlphaColorRec. Alpha or $DDA0DD)),
    (CN:'Powderblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $B0E0E6)),
    (CN:'Purple';     CV: TAlphaColor(TAlphaColorRec. Alpha or $800080)),
    (CN:'Red';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF0000)),
    (CN:'Rosybrown';     CV: TAlphaColor(TAlphaColorRec. Alpha or $BC8F8F)),
    (CN:'Royalblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $4169E1)),
    (CN:'Saddlebrown';     CV: TAlphaColor(TAlphaColorRec. Alpha or $8B4513)),
    (CN:'Salmon';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FA8072)),
    (CN:'Sandybrown';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F4A460)),
    (CN:'Seagreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $2E8B57)),
    (CN:'Seashell';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFF5EE)),
    (CN:'Sienna';     CV: TAlphaColor(TAlphaColorRec. Alpha or $A0522D)),
    (CN:'Silver';     CV: TAlphaColor(TAlphaColorRec. Alpha or $C0C0C0)),
    (CN:'Skyblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $87CEEB)),
    (CN:'Slateblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $6A5ACD)),
    (CN:'Slategray';     CV: TAlphaColor(TAlphaColorRec. Alpha or $708090)),
    (CN:'Slategrey';     CV: TAlphaColor(TAlphaColorRec. Alpha or $708090)),
    (CN:'Snow';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFAFA)),
    (CN:'Springgreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $00FF7F)),
    (CN:'Steelblue';     CV: TAlphaColor(TAlphaColorRec. Alpha or $4682B4)),
    (CN:'Tan';     CV: TAlphaColor(TAlphaColorRec. Alpha or $D2B48C)),
    (CN:'Teal';     CV: TAlphaColor(TAlphaColorRec. Alpha or $008080)),
    (CN:'Thistle';     CV: TAlphaColor(TAlphaColorRec. Alpha or $D8BFD8)),
    (CN:'Tomato';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FF6347)),
    (CN:'Turquoise';     CV: TAlphaColor(TAlphaColorRec. Alpha or $40E0D0)),
    (CN:'Violet';     CV: TAlphaColor(TAlphaColorRec. Alpha or $EE82EE)),
    (CN:'Wheat';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F5DEB3)),
    (CN:'White';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFFFF)),
    (CN:'Whitesmoke';     CV: TAlphaColor(TAlphaColorRec. Alpha or $F5F5F5)),
    (CN:'Yellow';     CV: TAlphaColor(TAlphaColorRec. Alpha or $FFFF00)),
    (CN:'Yellowgreen';     CV: TAlphaColor(TAlphaColorRec. Alpha or $9ACD32)),
    (CN:'Null';     CV: TAlphaColor($00000000))
    );

function ColorToString(Color: TAlphaColor): string;
var i:integer;
begin
   result:='$'+IntToHex(Color,8);
   for I := 0 to cMaxAlphaColorNameItems-1 do
   begin
     if Color = cAlphaColorNamesArray[i].CV then
     begin
       result:=cAlphaColorNamesArray[i].CN;
       Break;
     end;
   end;
end;

function StringToColor(const S: string): TAlphaColor;
var i:integer;
begin
   result:=TAlphaColorRec.Alpha;
   for I := 0 to cMaxAlphaColorNameItems-1 do
   begin
     if AnsiUpperCase(s) = AnsiUpperCase(cAlphaColorNamesArray[i].CN) then
     begin
       result:=cAlphaColorNamesArray[i].CV;
       Break;
     end;
   end;
end;


{ TFmxLevelDetector }

constructor TFmxLevelDetector.Create(AOwner: TComponent);
begin
  inherited;
  FInverse:=False;
  StyleLookup:=cLevelDetectorStyle;
  ControlType:=ctLevelDetector;
  ModuleType[0]:=mtHSC_CTRL;
  BaudRate[0]:=19200;
  Color:=CL_FMX_BLACK;
  Caption:='Датчик состояния '+IntToStr(FIdx+1);
  StateVisible:=False;
  ValueType:=TNumValueType.Integer;
  LedON[TLeds(0)]:=TAlphaColorRec.Blue;//Заполнено водой
  LedOFF[TLeds(0)]:=TAlphaColorRec.Silver;//Пусто
  LedsCount:=1;
  Width:=130;
  Height := 30;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
end;

destructor TFmxLevelDetector.Destroy;
begin

  inherited;
end;

function TFmxLevelDetector.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=False;
end;


procedure TFmxLevelDetector.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cLevelDetectorPropertyCount);
   for i := 0 to cLevelDetectorPropertyCount-1 do
   begin
     FParameters[i].Name:=cLevelDetectorPropertys[i]; //Наименование
     FParameters[i].ParamType:=cLevelDetectorPropertysType[i];//тип
     FParameters[i].Items:=cLevelDetectorPropertyComboItems[i];
   end;
end;

function TFmxLevelDetector.GetActiveColor: TAlphaColor;
begin
  result:=LEDON[TLeds(0)];
end;

function TFmxLevelDetector.GetCurState: String;
begin
  result:=inherited;
  if Assigned(Device) then
       if Device.Submerged then
          result:=result+': Замкнут'
       else
          result:=result+': Разомкнут';
end;

function TFmxLevelDetector.GetInverse: Boolean;
begin
  if Assigned(Device) then
     result:=Device.Inverse
  else
     result:=FInverse;
end;

function TFmxLevelDetector.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     inherited;
end;

function TFmxLevelDetector.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

function TFmxLevelDetector.GetParamValue(Row: integer): String;
begin
  case Row of
    0:
      result := Caption;
    1:
      result := Hint;
    2:
      result := IntToStr(Port[0]);
    3:
      result := IntToStr(Address[0]);
    4:
      result := IntToStr(BaudRate[0]);
    5:
      result:=cComParityName[Parity];
    6:
      result := cModuleTypeNames[ModuleType[0]];
    7:
      result := FloatToStr(left+ShiftL);
    8:
      result := FloatToStr(top+ShiftT);
    9:
      result := FloatToStr(width);
    10:
      result := FloatToStr(height);
    11:
      result := cBooleanName[First];
    12:
      result := IntToStr(AFIdx);
    13:
      result := IntToStr(InputNumber+1);
    14:
      result := cBooleanName[FromInput];
    15:
      result := MyAlphaColorToStr(ActiveColor);
    16:
      result := MyAlphaColorToStr(UnactiveColor);
    17:
      result := MyAlphaColorToStr(Color);
    18:
      result := cBooleanName[Visible];
    19:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    20:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    21:
      result := IntToStr(InputRegister[0]);
    22:
      result := IntToStr(ModulePriority);
    23:
      result := cBooleanName[Inverse];
    24:
      result := IntToStr(MaxChannels);
  end;
end;

function TFmxLevelDetector.GetRebootWarning(Row: integer): Boolean;
begin
  result := Row in [2 .. 5];
end;

function TFmxLevelDetector.GetSubmerged: Boolean;
begin
  if Assigned(Device) then
     result:=Device.Submerged
  else
     result:=False;
end;

function TFmxLevelDetector.GetTextColor: TAlphaColor;
begin
  result:=StylesData['caption.textsettings.fontcolor'].AsType<TAlphaColor>;
end;

function TFmxLevelDetector.GetUnactiveColor: TAlphaColor;
begin
  result:=LEDOFF[TLeds(0)];
end;

procedure TFmxLevelDetector.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then begin
    Device := TFmxDeviceLevelDetector.CreateOnModule(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], InputNumber,ModuleType[0],TypeOfProtocol[0],InputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxLevelDetector.ReceiveResponse;
begin
  if Assigned(Device) then
  if Device.ConnectIsOK then
  begin
       if Device.Disguise then
       begin
         State:=fpsDisguise;
         Exit;
       end;
      LedState[TLeds(0)]:=Device.Submerged;
      State:=fpsEnabled;
  end
  else
      State:=fpsError;
end;

procedure TFmxLevelDetector.SetActiveColor(const Value: TAlphaColor);
begin
  LEDON[TLeds(0)]:=Value;
end;

procedure TFmxLevelDetector.SetAddress(AIdx: Integer; const Value: Integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxLevelDetector.SetBaudrate(AIdx: Integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;

procedure TFmxLevelDetector.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxLevelDetector.SetFromInput(const Value: boolean);
begin
  FFromInput:=Value;
  if Assigned(Device) then
     Device.FromInput:=FFromInput;
end;

procedure TFmxLevelDetector.SetInputNumber(input_number: byte);
begin
  case ModuleType[0] of
    mtModbusD: if input_number <= 15 then FInputNumber := input_number;
    mtBIO: if input_number <= 2 then FInputNumber := input_number;
    mtSuperBIO: if input_number <= 12 then FInputNumber := input_number;
    mtHSC_CTRL: if input_number <= MaxChannels then FInputNumber := input_number;
    mtValve: if (input_number >= 6) and (input_number <= 9) then FInputNumber := input_number;
  end;
  if Assigned(Device) then
    Device.InputNumber:=FInputNumber;
end;

procedure TFmxLevelDetector.SetInverse(const Value: Boolean);
begin
  FInverse := Value;
  if Assigned(Device) then
     Device.Inverse:=Value;
end;

procedure TFmxLevelDetector.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Device) then
     Device.MaxChannels:=Value;
end;

procedure TFmxLevelDetector.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
  begin
    if Value in [mtModbusD,mtBIO,mtSuperBIO, mtValve, mtHSC_CTRL] then
    begin
      case Value of
        mtModbusD:
          if not InputNumber in [1..16] then InputNumber := 1;
        mtSuperBIO:
          if InputNumber > 12 then InputNumber := 12;
        mtHSC_CTRL:
          if InputNumber > MaxChannels then InputNumber := 0;
        mtBIO:
          if InputNumber > 2 then InputNumber := 2;
        mtValve:
          if InputNumber < 6 then InputNumber := 6
          else
            if InputNumber > 9 then InputNumber := 9;
      end;
    end;
    Device.ModuleType:=Value;
  end;
end;

procedure TFmxLevelDetector.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Port[0] :=  StrToIntDef(Value, Port[0]);
    3:
      Address[0] :=StrToIntDef(Value, Address[0]);
    4:
      BaudRate[0] := StrToIntDef(Value, 9600);
    5:
      Parity:=StrToParity(Value);
    6:
      ModuleType[0] := StrToModuleType(Value);
    7:
      left :=StrToFloatDef(CP(Value), left)-ShiftL;
    8:
      top :=StrToFloatDef(CP(Value), top)-ShiftT;
    9:
      width :=StrToFloatDef(CP(Value), width);
    10:
      height :=StrToFloatDef(CP(Value), height);
    11:
      First := myStrToBool(Value);
    12:
      AFIdx :=
        StrToIntDef(Value, AFIdx);
    13:
      InputNumber :=
        StrToIntDef(Value, InputNumber+1)-1;
    14:
      FromInput := myStrToBool(Value);
    15:
      ActiveColor :=StrToAlphaColor(Value);
    16:
      UnactiveColor :=StrToAlphaColor(Value);
    17:
      Color :=StrToAlphaColor(Value);
    18:
      Visible := myStrToBool(Value);
    19:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    20:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    21:
      InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    22:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    23:
      Inverse:=myStrToBool(Value);
    24:
      MaxChannels:=StrToIntDef(Value, MaxChannels);
  end;
end;

procedure TFmxLevelDetector.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxLevelDetector.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

function TFmxLevelDetector.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxLevelDetector.SetTextColor(const Value: TAlphaColor);
begin
    StylesData['caption.textsettings.fontcolor']:=Value;
end;

procedure TFmxLevelDetector.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;

procedure TFmxLevelDetector.SetUnactiveColor(const Value: TAlphaColor);
begin
  LEDOFF[TLeds(0)]:=Value;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxLevelDetector]);
end;

end.
