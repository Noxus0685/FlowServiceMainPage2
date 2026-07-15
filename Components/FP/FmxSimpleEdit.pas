unit FmxSimpleEdit;

interface


uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxModbusConsts,
  FmxModbusTypes,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cSimpleValveStyle = 'analogparamstyle';

{ ===== Компонент FmxElectricValve =====
Визуальный компонент задвижки с регулиуемым проходным сечением
}

  //Количество свойств
  cSimpleEditPropertyCount=21;

  //Наименования свойств
  cSimpleEditPropertys:array[0..cSimpleEditPropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cNumChannel,cVisible,
  cTypeOfProtocol,
  cModbusOutputReg,cModbusFormat,cMinOutput,cMaxOutput,cModulePriority,cChannelsCount,cEdIzmParam);

  //типы свойств
  cSimpleEditPropertysType:array[0..cSimpleEditPropertyCount-1]of TParameterType=(
//  cHeader,cHint
    ptText,ptText,
//  cPort,   cAddress,cBaudrate,
    ptNumber,ptNumber,ptNumber,
//  cParity,
    ptComboBox,
//  cModuleType,
    ptComboBox,
//cLeft,cTop,cWidth,cHeight,
    ptFloat,ptFloat,ptFloat,ptFloat,
//  cNumChannel,cVisible,
    ptNumber,ptComboBox,
//  cTypeOfProtocol,
    ptComboBox,
//  cModbusOutputReg,cModbusFormat,cMinOutput,cMaxOutput,cModulePriority,cEdIzmParam
    ptNumber,ptComboBox,ptNumber,ptNumber,ptNumber,ptNumber,ptText
  );

  //Комбо выпадающие списки
  cSimpleEditPropertyComboItems: array[0..cSimpleEditPropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtHSC_CTRL,cmtModbusA],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cNumChannel,cVisible,
    [],[cNo,cYes],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusOutputReg,cMinOutput,cMaxOutput,cModulePriority,cEdIzmParam
    [],[cModBusFormatName1,cModBusFormatName2,cModBusFormatName3,cModBusFormatName4],[],[],[],[],[]
    );
//  cModBusFormatName1='0_1_2_3';
//  cModBusFormatName2='1_0_3_2';//ТРМ10
//  cModBusFormatName3='2_3_0_1';
//  cModBusFormatName4='3_2_1_0';

type
  TFmxSimpleEdit = class(TFMXDeviceCustomControl)
  private
    //Флаг полного раскрытия формы
    FFull: Boolean;

    FAddress: Byte;

    // Значение, хранящее позицию задвижки по процедуре StoreValvesPosition и возвращающе позицию по команде RestoreValvesPosition
    PreviousPosition: Double;

    // Значение, используемое мотодом Move.
    NewValue: Double;//новое значение уставки
    FOutputValue: Double;//Записываемое значение уставки
    FInputValue: Double;//Считанное значение уставки

    FButtonVisible: boolean;

    FParity:TComParity;
    FOutputNumber: Byte;
    FInputNumber: Byte;
    FBaseRegister: word;


    { ===== DoChange =====
    Меняет значение уставки на значение NewValue, после чего обновляет статус модуля.
    }
    procedure DoChange;

    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    // Обработчик нажатия кнопки запуска/остановки задвижки.
    procedure StartStopButtonClick(Sender: TObject);

    procedure SetInputNumber(const Value: Byte);
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    function GetValue: Double;
    function GetMaxChannels: byte;
    procedure SetMaxChannels(const Value: byte);
    procedure SetBaseRegister(const Value: word);
  protected

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    function GetPriority: integer;override;
    procedure UpdateStyle;override;
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    function GetModuleManager: TFmxModuleManager;override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
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
  public
    // Указатель на используемое устройство.
    Device: TFmxDeviceSimpleEdit;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillParametersList;override;
    procedure DoOnChange(Sender: TObject); override;
    procedure Update;

  published
    // Номер регистра от базового для записи
    property BaseRegister: word read FBaseRegister write SetBaseRegister;
    property InputNumber: Byte read FInputNumber write SetInputNumber;
    property MaxChannels:byte read GetMaxChannels write SetMaxChannels;
  end;





procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti,
     FMX.Text,
     SYNCOBJS;

{ TFmxSimpleEdit }




constructor TFmxSimpleEdit.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cSimpleValveStyle;
  Device := nil;
  FAddress := 0;
  ModuleType[0] := mtModbusA;
  Address[0] := 0;
  BaudRate[0] := 19200;
  Height := 81;
  Width := 112;
  ShortHeight:=60;
  LongHeight:=98;
  FFull:=False;//Сокращенный вид
  ControlType:=ctEdit;
//  OnMouseDown:=DoOnMouseDown; - приводит к зацикливанию и переполнению
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Уставка '+IntToStr(FIdx+1);
  LedsCount:=0;
  StylesData['startstopbutton.hint']  :='Записать изменение';
  StylesData['startstopbutton.showhint']  :=True;
  ButtonText:=' ';
  ValueType:=TNumValueType.Float;
  DecimalDigits:=1;
  StylesData['editvalue.Min']  := Min;// в % 0 до 100
  StylesData['editvalue.Max']  := Max;// в % 0 до 100
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
  ControlsEnabled:=True;
  State:=TFPControlState.fpsEnabled;
  StylesData['mainbody.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  StylesData['body.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);

end;


destructor TFmxSimpleEdit.Destroy;
begin
  inherited;
end;

function TFmxSimpleEdit.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=False;
end;

procedure TFmxSimpleEdit.DoOnChange(Sender: TObject);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone: ;
    ccnStartStopButton: begin
      //Пользователь нажал кнопку стартстоп
      StartStopButtonClick(self);
    end;
  end;
  CCN:=ccnNone;

end;

procedure TFmxSimpleEdit.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cSimpleEditPropertyCount);
   for i := 0 to cSimpleEditPropertyCount-1 do
   begin
     FParameters[i].Name:=cSimpleEditPropertys[i]; //Наименование
     FParameters[i].ParamType:=cSimpleEditPropertysType[i];//тип
     FParameters[i].Items:=cSimpleEditPropertyComboItems[i];
   end;
end;

function TFmxSimpleEdit.GetCurState: String;
begin
  result:=inherited;
  if Assigned(Device) then
       result:=result+Format(': I%f,O%f ',[Device.InputValue,Device.OutputValue]);
end;



function TFmxSimpleEdit.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     result:=0;
end;

function TFmxSimpleEdit.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

(*
  cModbusOutputReg,cMinOutput,cMaxOutput,cModulePriority,cEdIzmParam);

*)
function TFmxSimpleEdit.GetParamValue(Row: integer): String;
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
      result := IntToStr(InputNumber+1);
    12:
      result := cBooleanName[Visible];
    13:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    14:
      result := IntToStr(BaseRegister);
    15:
      result := cModBusTypeOfDataNames[ModbusFormat];
    16:
      result := FloatToStr(Min);
    17:
      result := FloatToStr(Max);
    18:
      result := IntToStr(ModulePriority);
    19:
      result := IntToStr(MaxChannels);
    20:
      result := Ext;
  end;
end;



function TFmxSimpleEdit.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 5];
end;



procedure TFmxSimpleEdit.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then
  begin
    Device := TFmxDeviceSimpleEdit.CreateOnModuleValve(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], InputNumber,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxSimpleEdit.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited MouseMove(Shift, X, Y);
  SetFocus;
end;

procedure TFmxSimpleEdit.DoChange;
begin
  if Assigned(Device) then
  begin
    Device.OutputValue:=NewValue;
  end;
end;



procedure TFmxSimpleEdit.ReceiveResponse;
begin
 try
   if Assigned(Device) then
   begin
      if Device.ConnectIsOK then
      begin
          if Device.Disguise then
          begin
             State:=fpsDisguise;
             Exit;
          end;
          editenabled:=True;//(Device.Direction = dStoped);
          Buttonenabled:=ControlsEnabled;
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


procedure TFmxSimpleEdit.SetAddress(AIdx: Integer; const Value: Integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxSimpleEdit.SetBaseRegister(const Value: word);
begin
  FBaseRegister := Value;
  if Assigned(Device) then
    if Assigned(Device.Module) then
    begin
     Device.Module.InputRegister:=Value;
     Device.Module.OutputRegister:=Value;
    end;

end;

procedure TFmxSimpleEdit.SetBaudrate(AIdx: Integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;


procedure TFmxSimpleEdit.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;


procedure TFmxSimpleEdit.SetMaxChannels(const Value: byte);
begin
  if (Value>=1) and  (Value<=16) then
    if Assigned(Device) then
       Device.MaxChannels:=Value;
end;

procedure TFmxSimpleEdit.SetModbusFormat(const Value: TModBusDataFormat);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
      Device.ModbusFormat := Value;
end;

procedure TFmxSimpleEdit.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
      Device.Module.ModuleType := Value;
end;

procedure TFmxSimpleEdit.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Port[0] :=
        StrToIntDef(Value, Port[0]);
    3:
      Address[0] :=
        StrToIntDef(Value, Address[0]);
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
      InputNumber:=StrToIntDef(Value, 1)-1;
    12:
      Visible := myStrToBool(Value);
    13:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    14:
      BaseRegister := StrToIntDef(Value, BaseRegister);
    15:
      ModbusFormat:=StrToModBusFormat(Value);
    16:
      Min:=StrToFloatDef(CP(Value),  Min);
    17:
      Max:=StrToFloatDef(CP(Value),  Max);
    18:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    19:
      MaxChannels:=StrToIntDef(Value, MaxChannels);
    20:
      Ext:=Value;
  end;
end;

procedure TFmxSimpleEdit.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;


procedure TFmxSimpleEdit.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;


function TFmxSimpleEdit.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;


procedure TFmxSimpleEdit.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;


procedure TFmxSimpleEdit.SetInputNumber(const value: Byte);
begin
  if Assigned(Device) then
    case Device.ModuleType of
    mtHSC_CTRL: if value <= 23 then FInputNumber := value;
    mtModbusA:if value <= 16 then FInputNumber := value;
    else
      FInputNumber := value;
    end
  else
    FInputNumber:=Value;

  if Assigned(Device) then
     Device.Number:=FInputNumber;
end;



procedure TFmxSimpleEdit.StartStopButtonClick(Sender: TObject);
begin
  if not Assigned(Device) then Exit;
  NewValue := StylesData['editvalue.value'].AsExtended;
  if (NewValue >= Min) and (NewValue <= Max) then
  begin
      StylesData['editvalue.enabled']  := False;
      if aftAskingBeforExec in AFTypeSet then
        begin
          if (not (aftAskingBeforExec in AFTypeSet)) or DialogYesNo('Вы действительно хотите изменить значение '+Caption+'?') then
          begin
            Device.AddToWorkLogProc('Пользователь в ручном режиме изменил значение '+Caption);
            Device.ModuleManager.ExecuteInCOMThread(DoChange);
            if Assigned(Device.AddToWorkLogProc) then
               Device.AddToWorkLogProc('Пользователь в ручном режиме изменил значение ' + Caption);
          end;
        end
        else
          Device.ModuleManager.ExecuteInCOMThread(DoChange);
  end;
end;


procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxSimpleEdit]);
end;


procedure TFmxSimpleEdit.UpdateStyle;
var i:TFmxColorSheme;
    lighted,visibleflag:boolean;
    son,soff:String;
begin
  inherited;
  if Full then
  begin
       Height:=LongHeight;
  end
  else begin
       Height:=ShortHeight;
  end;
  StylesData['body.visible']:=Full;//Панель с кнопкой
end;

procedure TFmxSimpleEdit.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
   inherited;
   if (csDesigning in ComponentState) then Exit;
   if DesignMode then
   begin
     DoOnClick(Sender);
   end
   else
     if Button = TMouseButton.mbRight then
        Full:=not Full;
  if Assigned(OnMouseDown) then
     OnMouseDown(self,Button,Shift,X, Y);
end;

function TFmxSimpleEdit.GetValue: Double;
begin
  if Assigned(Device) then
     result:=Device.InputValue
  else
     result:=InputValue;

  //контроль выхода за диапазон
  if result>Max then result:=Max
  else if result<Min then result:=Min;
end;


procedure TFmxSimpleEdit.Update;
begin
   TThread.Queue(nil,
      procedure
      begin
          if Assigned(Device) then
          begin
            if InputValue<>Device.InputValue then
            begin
              InputValue:=Device.InputValue;
              EditValue:=Device.InputValue;
              EditEnabled:=True;
            end;
          end;
      end);
end;




end.
