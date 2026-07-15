unit FmxThermometer_Manometer;


{ ===== Компонент FmxThermometer_Manometer =====
Визуальный компонент датчика температуры, давления
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  System.UITypes,//TMouseButton
  FmxParamsFrm,//Форма ручного ввода параметров
  FmxModbusConsts,
  FmxModbusTypes,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cThermometer_ManometerStyle='thermometer_manometerstyle';
  cThermometerStyle='thermometerstyle';
  cManometerStyle='manometerstyle';

type
  // Тип, используемый для определения типа модуля (не путать с одноименным типом в unit'е DeviceManager).
  // Тип, используемый для определения типа устройства.
  TThermometerOrManometer = (dtNotAssigned, dtThermometer, dtManometer, dtHygrometer, dtBarometer);
  TThermometer_ManometerParams=(tmpValue);

const
  cThermometer_ManometerParamsCount=1;
  cFlowmeterVolumeParams:array[TThermometerOrManometer]of string=('Параметр','Температура,°C','Давление, МПа','Влажность,  %','Атм. давление,  Па');

  //Количество свойств
  cThermometer_ManometerPropertyCount=27;

  //Наименования свойств
  cThermometer_ManometerPropertys:array[0..cThermometer_ManometerPropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,cLeft,cTop,cWidth,cHeight,
  cView,cFirst,cNumAppFunction,cNumContactInp,cVisible,
  cTypeAppFunc,cTypeOfProtocol,cModbusInputReg,cModbusFormat,
  cSerialNum,cChannelsCount,cDigitsForChannel,cModulePriority,cMin,cMax,cDigits);

  //типы свойств
  cThermometer_ManometerPropertysType:array[0..cThermometer_ManometerPropertyCount-1]of TParameterType=(
// cHeader, cHint
    ptText,ptText,
//  cPort,   cAddress,cBaudrate,
    ptNumber,ptNumber,ptNumber,
//cParity
    ptComboBox,
//  cModuleType,cLeft,cTop,cWidth,cHeight,
    ptComboBox,ptFloat,ptFloat,ptFloat,ptFloat,
//  cView, cFirst,    cNumAppFunction,cNumContactInp,cVisible,
    ptComboBox,ptComboBox,ptNumber,       ptNumber,      ptComboBox,
//  cTypeAppFunc,cTypeOfProtocol,cModbusInputReg,cModbusFormat,cSerialNum,cChannelsCount,cDigitsForChannel,cModulePriority);
    ptComboBox,    ptComboBox,     ptNumber,ptComboBox,      ptText,    ptNumber,         ptNumber,        ptNumber,
    //Min, MAx, Digits
    ptFloat,ptFloat,ptNumber);

  //Комбо выпадающие списки
  cThermometer_ManometerPropertyComboItems: array[0..cThermometer_ManometerPropertyCount-1] of TArray<string> = (
    //cHeader,cHint,
    [],[],
    //  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
    //  cModuleType
    [сmtManual,cmtADC_I70XX,cmtT,cmtTemp2,cmtTemp6,cmtUI,сmtOldUI,cmtIVTM,cmtKM5,cmtRT2,cmtModbusA,cmtLTA],
    //  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
    //  cView,cFirst,
    [cStandart,cOtherView],[cNo,cYes],
    //    cNumAppFunction,cNumContactInp,cVisible,cTypeAppFunc
    [],[],[cNo,cYes],[cNumber,cMask],
    //  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
    //  cModbusInputReg,cModbusFormat,
    [],[cModBusFormatName1,cModBusFormatName2,cModBusFormatName3,cModBusFormatName4,cModBusFormatName5],
    //cSerialNum,cChannelsCount,cDigitsForChannel,cModulePriority,cMin,cMax,cDigits
    [],[],[],[],[],[],[]
    );



type
  //==========================================================================================================

  TFmxThermometer_Manometer = class(TFMXDeviceCustomControl)

  private

    FAddress: integer;
    FDeviceType: TThermometerOrManometer;
    FInputNumber: Byte;

    // Метка, используемая для отображения значения датчика.
    FBaudRate: Cardinal;
    FfrmParams: TfrmParams;
    FValue: Single;
    FP_EdIzm: Byte;
    Blink:boolean;

    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    procedure SetDeviceType(device_type: TThermometerOrManometer);
    procedure SetInputNumber(input_number: Byte);

    function GetValue: Double;
    procedure StoreParamValues();
    procedure LoadParamValues();
    procedure SetValue(const Value: Double);
    function GetManualEnter: Boolean;
    procedure SetfrmParams(const Value: TfrmParams);
    procedure SetP_EdIzm(const Value: Byte);
    function GetMaxChannels: byte;
    procedure SetMaxChannels(const Value: byte);
    function GetDigitsForChannel: byte;
    procedure SetDigitsForChannel(const Value: byte);
    function GetRawValue: Double;

  protected

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    function GetPriority: integer;override;
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    procedure UpdateStyle;override;
    function GetModuleManager: TFmxModuleManager;override;
    procedure SetComPort(AIdx: integer; const Value: word); override;
    procedure SetAddress(AIdx: Integer; const Value: Integer); override;
    procedure SetBaudrate(AIdx: Integer; const Value: Cardinal); override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType); override;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    function Disguise: Boolean; override;
    function GetCurState: String; override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
    procedure SetParity(const Value: TComParity);override;
    procedure SetModbusFormat(const Value: TModBusDataFormat);override;
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);override;

  public

    // Указатель на используемое устройство.
    Device: TFmxDeviceThermometer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update;
    procedure FillParametersList;override;
    function GetInfo: String;override;

  published
    property frmParams: TfrmParams read FfrmParams write SetfrmParams;
    // Тип устройства.
    property DeviceType: TThermometerOrManometer read FDeviceType write SetDeviceType default dtThermometer;

    // Номер входа модуля, к которому подключен датчик (от 0 до 7 для модуля T; от 0 до 3 для модуля Temp2).
    // !!! (от 0 до 5 для Temp6)
    property InputNumber: Byte read FInputNumber write SetInputNumber default 0;

    property ShowHint;

    property ParamValue:Double read GetValue write SetValue;

    property ManualEnter:Boolean read GetManualEnter;

    property P_EdIzm:Byte read FP_EdIzm write SetP_EdIzm;

    property LedVisible;

    property MaxChannels:byte read GetMaxChannels write SetMaxChannels;

    property DigitsForChannel:byte read GetDigitsForChannel write SetDigitsForChannel;

    property Value:Double read GetValue;

    property RawValue:Double read GetRawValue;

  end;

//============================================================================================================

procedure Register;

//============================================================================================================

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     fmxkbdhelper,
     System.Rtti;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxThermometer_Manometer]);
end;

{ TFmxThermometer_Manometer }

constructor TFmxThermometer_Manometer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CaptionColor:=CL_FMX_WHITE;
  frmParams:=nil;
  Device := nil;
  Address[0] := 0;
  ModuleType[0] := mtTemp6;
  BaudRate[0] := 38400;
  DeviceType := dtThermometer;
  ControlType := ctThermometer;
  Min:=0;
  Max:=99;
  ValueMask:='';
  DecimalDigits := 1;
  InputNumber := 0;
  OtherView:=False;//Классический вид
  Height:=57;
  Width:=86;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
  HitTest:=True;
  LEDON[lpLED1]:=TAlphaColorRec.Red;
  LEDOFF[lpLED1]:=TAlphaColorRec.Green;
  FfrmParams:=TfrmParams.Create(self);
  frmParams.ParamsCount:=cThermometer_ManometerParamsCount;
end;

destructor TFmxThermometer_Manometer.Destroy;
begin
  if Assigned(FfrmParams) then
     FreeAndNil(FfrmParams);
  inherited;
end;

function TFmxThermometer_Manometer.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=False;
end;

procedure TFmxThermometer_Manometer.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cThermometer_ManometerPropertyCount);
   for i := 0 to cThermometer_ManometerPropertyCount-1 do
   begin
     FParameters[i].Name:=cThermometer_ManometerPropertys[i]; //Наименование
     FParameters[i].ParamType:=cThermometer_ManometerPropertysType[i];//тип
     FParameters[i].Items:=cThermometer_ManometerPropertyComboItems[i];
   end;
end;

function TFmxThermometer_Manometer.GetCurState: String;
begin
  result:=inherited;
  if Assigned(Device) then
       result:=result+Format(': %f',[ParamValue]);
end;

function TFmxThermometer_Manometer.GetDigitsForChannel: byte;
begin
  if Assigned(Device) then
     result:=Device.DigitsForChannel
  else
     result:=0;
end;

function TFmxThermometer_Manometer.GetInfo: String;
begin
  result:=#9+'('+inherited+Format(' В:%d',[InputNumber+1])+')';
end;

function TFmxThermometer_Manometer.GetManualEnter: Boolean;
begin
  if Assigned(Device) then
     result:=Device.ModuleType=mtManual
  else
     result:=False;
end;

function TFmxThermometer_Manometer.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     result:=0;
end;

function TFmxThermometer_Manometer.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

(*
  cHeader,cHint,                     0..1
  cPort,cAddress,cBaudrate,cParity,  2..5
  cModuleType,cLeft,cTop,cWidth,cHeight, 6..10
  cView,cFirst,cNumAppFunction,cNumContactInp,cVisible, 11..15
  cTypeAppFunc,cTypeOfProtocol,cModbusInputReg,cModbusFormat, 16..19
  cSerialNum,cChannelsCount,cDigitsForChannel,cModulePriority,cMin,cMax,cDigits); 20..26
*)
function TFmxThermometer_Manometer.GetParamValue(Row: integer): String;
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
      result := cOtherViewName[OtherView];
    12:
      result := cBooleanName[First];
    13:
      result := IntToStr(AFIdx);
    14:
      result := IntToStr(InputNumber+1);
    15:
      result := cBooleanName[Visible];
    16:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    17:
      result := cTypeOfProtocols[TypeOfProtocol[0]];
    18:
      result := IntToStr(InputRegister[0]);
    19:
      result := cModBusTypeOfDataNames[ModbusFormat];
    20:
      result := IntToStr(SerialNum);
    21:
      result := IntToStr(MaxChannels);
    22:
      result := IntToStr(DigitsForChannel);
    23:
      result := IntToStr(ModulePriority);
    24:
      result := FloatToStr(Min);
    25:
      result := FloatToStr(Max);
    26:
      result := IntToStr(DecimalDigits);
  end;
end;

function TFmxThermometer_Manometer.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

function TFmxThermometer_Manometer.GetRawValue: Double;
begin
  if Assigned(Device) then
     result:=Device.RawValue
  else
     result:=0;
end;

function TFmxThermometer_Manometer.GetRebootWarning(Row: integer): Boolean;
begin
  result := Row in [2 .. 5];
end;

function TFmxThermometer_Manometer.GetValue: Double;
begin
  if Assigned(Device) then
     result:=Device.Value
  else
     result:=InputValue;

  //контроль выхода за диапазон
  if result>Max then result:=Max
  else if result<Min then result:=Min;



end;

procedure TFmxThermometer_Manometer.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then begin
    Device := TFmxDeviceThermometer.CreateOnModule(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], InputNumber,ModuleType[0],TypeOfProtocol[0],InputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxThermometer_Manometer.LoadParamValues;
begin
  if Assigned(frmParams) then
  begin
    frmParams.Caption:=cManualEnter+Caption;
    frmParams.ParamsWritable[Ord(tmpValue)]:=True;
    frmParams.ParamsName[Ord(tmpValue)]:=cFlowmeterVolumeParams[DeviceType];
    frmParams.ParamsValue[ord(tmpValue)]:=Device.Value;
  end;
end;


procedure TFmxThermometer_Manometer.ReceiveResponse;
begin
 try
   if True then

   if Assigned(Device) then
   begin
      if Device.Disguise then
      begin
         State:=fpsDisguise;
         Exit;
      end;
      if Device.ConnectIsOK then
      begin
          if ControlsEnabled then
            State := fpsEnabled
          else
            State := fpsDisabled;
          Update();//присваивает значение в InputValue
      end
      else begin
        State := fpsError;
      end;
   end;
  except
    State := fpsError;
  end;
end;

procedure TFmxThermometer_Manometer.SetAddress(AIdx: Integer;
  const Value: Integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxThermometer_Manometer.SetBaudrate(AIdx: Integer;
  const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;

procedure TFmxThermometer_Manometer.SetComPort(AIdx: integer;
  const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxThermometer_Manometer.SetDeviceType(
  device_type: TThermometerOrManometer);
begin
   if FDeviceType<>device_type then
   begin
     FDeviceType:=device_type;
     case DeviceType of
      dtNotAssigned: begin
        Min:=0;Max:=100;
        Ext:=''; Caption:='Устройство '+IntToStr(Idx+1);
      end;
      dtHygrometer: begin
        Min:=0;Max:=100;
        Ext:='%'; Caption:='Гигрометр '+IntToStr(Idx+1);
      end;
      dtBarometer: begin
        Min:=90000;Max:=120000;
        Ext:='Па'; Caption:='Барометр '+IntToStr(Idx+1);
      end;
      dtThermometer: begin
        Min:=-60;Max:=100;
        Ext:='°C'; Caption:='Термометр '+IntToStr(Idx+1);
      end;
      dtManometer: begin
        Ext:='МПа'; Caption:='Манометр '+IntToStr(Idx+1);
        Min:=0;Max:=100;
      end;
     end;
     UpdateStyle();
   end;
end;

procedure TFmxThermometer_Manometer.SetDigitsForChannel(const Value: byte);
begin
  if Assigned(Device) then
     Device.DigitsForChannel:=Value;
end;

procedure TFmxThermometer_Manometer.UpdateStyle;
begin
  inherited;
  if not OtherView then
     StyleLookup:=cThermometer_ManometerStyle
  else begin
      case DeviceType of
      dtNotAssigned, dtHygrometer, dtBarometer:
                    StyleLookup:=cThermometer_ManometerStyle;
      dtThermometer:StyleLookup:=cThermometerStyle;
      dtManometer:  StyleLookup:=cManometerStyle;
      end;
  end;

  Update();
end;


procedure TFmxThermometer_Manometer.SetfrmParams(const Value: TfrmParams);
begin
  FfrmParams := Value;
end;

procedure TFmxThermometer_Manometer.SetInputNumber(input_number: Byte);
begin
  case ModuleType[0] of
    mtT,mtOldUI,mtUI,mtADC_I70XX:     if input_number <= 7 then FInputNumber := input_number;
    mtTemp2: if input_number <= 3 then FInputNumber := input_number;
    mtTemp6: if input_number <= 7 then FInputNumber := input_number;
    mtLTA: if input_number <= 2 then FInputNumber := input_number;
    mtKM5: if input_number <= 3 then FInputNumber := input_number;
    mtRT2: if input_number <= 3 then FInputNumber := input_number;
    mtModbusA: if input_number <= 15 then FInputNumber := input_number;
    else
      FInputNumber := input_number;
  end;
  if Assigned(Device) then
    Device.InputNumber:=input_number;
end;

procedure TFmxThermometer_Manometer.SetMaxChannels(const Value: byte);
begin
  if Assigned(Device) then
     Device.MaxChannels:=Value;
end;

procedure TFmxThermometer_Manometer.SetModbusFormat(
  const Value: TModBusDataFormat);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
      Device.ModbusFormat := Value;
end;

procedure TFmxThermometer_Manometer.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  if Value in [mtT..mtOldUI,mtManual,mtKM5,mtRT2,mtADC_I70XX,mtModbusA,mtLTA] then
  begin
    Inherited;
    case ModuleType[0] of
      mtRT2:
        if FInputNumber > 3 then FinputNumber := 3;
      mtKM5:
        if FInputNumber > 3 then FinputNumber := 3;
      mtT,mtOldUI,mtUI:
        if FInputNumber > 7 then FinputNumber := 7;
      mtTemp2:
        if FInputNumber > 3 then FinputNumber := 3;
      mtTemp6:
        if FInputNumber > 5 then FinputNumber := 5;
      mtADC_I70XX:
        if FInputNumber > 8 then FinputNumber := 8;
      mtLTA:
        if FInputNumber > 2 then FinputNumber := 2;
      mtModbusA:
        if FInputNumber > 15 then FinputNumber := 15;  //нумерация хранения от 0 до мах-1
    end;
    if Assigned(Device) then
      Device.ModuleType:=Value;
  end;
end;


(*
  cHeader,cHint,                     0..1
  cPort,cAddress,cBaudrate,cParity,  2..5
  cModuleType,cLeft,cTop,cWidth,cHeight, 6..10
  cView,cFirst,cNumAppFunction,cNumContactInp,cVisible, 11..15
  cTypeAppFunc,cTypeOfProtocol,cModbusInputReg,cModbusFormat, 16..19
  cSerialNum,cChannelsCount,cDigitsForChannel,cModulePriority,cMin,cMax,cDigits); 20..26
*)

procedure TFmxThermometer_Manometer.SetParamValue(Row: integer;
  const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Port[0] := StrToIntDef(Value, Port[0]);
    3:
      Address[0] := StrToIntDef(Value, Address[0]);
    4:
      BaudRate[0] :=
        StrToIntDef(Value, 9600);
    5:
      Parity:=StrToParity(Value);
    6:
      ModuleType[0] :=
        StrToModuleType(Value);
    7:
      left :=StrToFloatDef(CP(Value),  left)-ShiftL;
    8:
      top :=StrToFloatDef(CP(Value),  top)-ShiftT;
    9:
      width :=StrToFloatDef(CP(Value),  width);
    10:
      height :=StrToFloatDef(CP(Value),  height);
    11:
      OtherView := myStrToOtherView(Value);
    12:
      First := myStrToBool(Value);
    13:
      AFIdx :=
        StrToIntDef(Value, AFIdx);
    14:
      InputNumber :=
        StrToIntDef(Value, InputNumber+1)-1;
    15:
      Visible := myStrToBool(Value);
    16:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    17:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    18:
      InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    19:
      ModbusFormat:=StrToModBusFormat(Value);
    20:
      SerialNum := StrToIntDef(Value, SerialNum);
    21:
      MaxChannels:=StrToIntDef(Value, MaxChannels);
    22:
      DigitsForChannel:=StrToIntDef(Value, DigitsForChannel);
    23:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    24:
      Min:=StrToFloatDef(CP(Value),  Min);
    25:
      Max:=StrToFloatDef(CP(Value),  Max);
    26:
      DecimalDigits:=StrToIntDef(Value,DecimalDigits);
  end;
end;

procedure TFmxThermometer_Manometer.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxThermometer_Manometer.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

procedure TFmxThermometer_Manometer.SetP_EdIzm(const Value: Byte);
begin
  FP_EdIzm := Value;
end;

procedure TFmxThermometer_Manometer.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;

procedure TFmxThermometer_Manometer.SetValue(const Value: Double);
var result:Single;
begin
  //контроль выхода за диапазон
  result:=Value;
  if result>Max then result:=Max
  else if result<Min then result:=Min;
  if Assigned(Device) then
  begin
     Device.Value:=result;
     Update();
  end;
end;

procedure TFmxThermometer_Manometer.StoreParamValues;
begin
   if Assigned(frmParams) and Assigned(Device) then
      Device.Value:=frmParams.ParamsValue[ord(tmpValue)];
   ReceiveResponse();
end;

procedure TFmxThermometer_Manometer.Update;
begin
   TThread.Queue(nil,
      procedure
      begin
          if Assigned(Device) then
          begin
            if InputValue<>Device.Value then
            begin
              InputValue:=Device.Value;
              LED1Light:=(ParamValue>=Max*0.9) or (ParamValue<=Min*1.1);
              //Мерцаем
              if LED1Light then
              begin
                Blink:=not Blink;
                if Blink then
                   LEDON[lpLED1]:=TAlphaColorRec.Red
                else
                   LEDON[lpLED1]:=TAlphaColorRec.Null;
              end
              else begin
                   Blink:=False;
                   LEDON[lpLED1]:=TAlphaColorRec.Red;
                   LEDSTATE[lpLED1]:=False;
              end;
              if ManualEnter and (not (State in [fpsEnabled,fpsEnabledSelected])) then
              begin
                 if Value>0 then  State:=fpsEnabledSelected
                 else State:=fpsEnabled;
              end;
            end;
          end;
      end);
end;

procedure TFmxThermometer_Manometer.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
   inherited;
   if (csDesigning in ComponentState) then Exit;
   if DesignMode then
   begin
     DoOnClick(Sender);
   end
   else
     if Button = TMouseButton.mbLeft then
     begin

       if CtrlDown and Assigned(Device) then
        begin
          if Device.ModuleType=mtManual then
          begin
             //вызываем диалоговое окно настройки значений параметров
             //Иначе вызываем диалоговое окно настройки значений параметров
             LoadParamValues();
             if frmParams.ShowModal=mrOk then
               StoreParamValues();
          end;
        end;
     end;
  if Assigned(OnMouseDown) then
     OnMouseDown(self,Button,Shift,X, Y);
end;


end.
