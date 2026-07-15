unit FmxElectricValve;

{ ===== Компонент FmxElectricValve =====
Визуальный компонент задвижки с регулиуемым проходным сечением
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cElectricValveStyle='electricvalvestyle';

  //Количество свойств
  cElectricValvePropertyCount=27;

  //Наименования свойств
  cElectricValvePropertys:array[0..cElectricValvePropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cFirst,cNumAppFunction,cNumContactI,
  cNumChannel,cInitState,cVisible,cTypeAppFunc,cSwitchTime,
  cTypeOfProtocol,
  cModbusInputReg,cModbusOutputReg,cMinInput,cMaxInput,cMinOutput,cMaxOutput,cModulePriority);

  //типы свойств
  cElectricValvePropertysType:array[0..cElectricValvePropertyCount-1]of TParameterType=(
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
//  cFirst,cNumAppFunction,cNumContactI,
    ptComboBox, ptNumber,ptNumber,
//  cNumChannel,cInitState,cVisible,cTypeAppFunc,cSwitchTime,
    ptNumber,ptComboBox,ptComboBox,ptComboBox,ptNumber,
//  cTypeOfProtocol,
    ptComboBox,
//  cModbusInputReg,cModbusOutputReg,cMinInput,cMaxInput,cMinOutput,cMaxOutput,cModulePriority
    ptNumber,ptNumber,ptNumber,ptNumber,ptNumber,ptNumber,ptNumber
  );

  //Комбо выпадающие списки
  cElectricValvePropertyComboItems: array[0..cElectricValvePropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtHSC_CTRL,cmtValve,cmtModbusA,cmtRT2,cmtDAC_I702X,cmtLogoDAC],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cFirst,cNumAppFunction,cNumContactI,
    [cNo,cYes],[],[],
//  cNumChannel,cInitState,cVisible,cTypeAppFunc,cSwitchTime,
    [],[cNo,cYes],[cNo,cYes],[cNumber,cMask],[],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModbusOutputReg,cMinInput,cMaxInput,cMinOutput,cMaxOutput,cModulePriority
    [],[],[],[],[],[],[]
    );


type
  TFmxElectricValve = class(TFMXDeviceCustomControl)
  private
    FAddress: Byte;

    FValveNumber: Byte;

    // Значение, хранящее позицию задвижки по процедуре StoreValvesPosition и возвращающе позицию по команде RestoreValvesPosition
    PreviousPosition: Double;

    // Значение, используемое мотодом Move.
    NewPosition: Double;

    FButtonVisible: boolean;

    FValveInputNumber: Byte;

    FParity:TComParity;


    // Обработчик прокрутки колеса мыши при вводе текста в строке ввода положения задвижки.
    procedure PositionEditChange;
    { ===== Move =====
    Меняет положение задвижки на значение NewPosition, после чего обновляет статус модуля.
    }
    procedure Move;
    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    procedure SetValveNumber(valve_number: Byte);

    // Обработчик нажатия кнопки закрытия задвижки.
    procedure CloseButtonClick(Sender: TObject);

    // Обработчик нажатия кнопки открытия задвижки.
    procedure OpenButtonClick(Sender: TObject);

    // Обработчик нажатия кнопки запуска/остановки задвижки.
    procedure StartStopButtonClick(Sender: TObject);

    { ===== Stop =====
    Останавливает задвижку, после чего обновляет статус модуля.
    }
    procedure Stop;
    function GetPosition: Single;
    procedure SetPosition(const Value: Single);
    function GetStartCaption: String;
    function GetStopCaption: String;
    procedure SetSwitchTime(const Value: Integer);
    function GetSwitchTime: Integer;
    procedure SetValveInputNumber(const Value: Byte);
    function GetMaxI: Single;
    function GetMaxO: Single;
    function GetMinI: Single;
    function GetMinO: Single;
    procedure SetMaxI(const Value: Single);
    procedure SetMaxO(const Value: Single);
    procedure SetMinI(const Value: Single);
    procedure SetMinO(const Value: Single);
    function GetPriority: integer;override;
  protected

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
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
    function GetMaxChannels: byte;override;
    procedure SetMaxChannels(const Value: byte);override;

  public
    // Указатель на используемое устройство.
    Device: TFmxDeviceElectricValve;
    //Время переключения
    FTimeToSwitch: Integer;
    ActualTimeToSwitch: Cardinal;//Актуальное время

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillParametersList;override;
    procedure DoOnChange(Sender: TObject); override;
    procedure StoreValvePosition;
    procedure RestoreValvePosition;

  published


    // Номер используемой пары эталонных расходомеров.
    property ValveInputNumber: Byte read FValveInputNumber write SetValveInputNumber;
    property ValveNumber: Byte read FValveNumber write SetValveNumber default 0;
    property Position:Single read GetPosition write SetPosition;
    property StopCaption:String read GetStopCaption;
    property StartCaption:String read GetStartCaption;
    property TimeToSwitch:Integer read GetSwitchTime write SetSwitchTime;//Время переключения - если не старые задвижки
    property MinInput:Single read GetMinI write SetMinI;
    property MaxInput:Single read GetMaxI write SetMaxI;
    property MinOutput:Single read GetMinO write SetMinO;
    property MaxOutput:Single read GetMaxO write SetMaxO;
  end;





procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti,
     FMX.Text,
     SYNCOBJS;

{ TFmxElectricValve }



procedure TFmxElectricValve.CloseButtonClick(Sender: TObject);
procedure CloseValve;
begin
  NewPosition:=0;
  Buttonenabled:=False;
  EditValue  := 0;// в % 0 до 100
  ScrollBarPosition := 0;//в % от 0 до 100
  Device.ModuleManager.ExecuteInCOMThread(Move);
end;

begin
  if aftAskingBeforExec in AFTypeSet then
  begin
    if (not (aftAskingBeforExec in AFTypeSet)) or DialogYesNo('Вы действительно хотите закрыть '+Caption+'?') then
    begin
      CloseValve();
      if Assigned(Device.AddToWorkLogProc) then
         Device.AddToWorkLogProc('Пользователь в ручном режиме закрыл ' + Caption);
    end;
  end
  else
    CloseValve();
end;

constructor TFmxElectricValve.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cElectricValveStyle;
  Device := nil;
  FAddress := 0;
  FValveNumber := 0;
  ModuleType[0] := mtHSC_CTRL;
  Address[0] := 0;
  BaudRate[0] := 19200;
  Height := 81;
  Width := 112;
  ControlType:=ctElectricValve;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Эл. Задвижка '+IntToStr(FIdx+1);
  LedsCount:=2;
  LED1ONColor:=CL_FMX_GREEN;
  LED1OFFColor:=CL_FMX_OFF;
  LED2ONColor:=CL_FMX_RED;
  LED2OFFColor:=CL_FMX_OFF;
  LED1Light:=False;
  LED2Light:=False;
  ButtonText:=StartCaption;
  ValueType:=TNumValueType.Float;
  DecimalDigits:=1;
  StylesData['editvalue.Min']  := 0;// в % 0 до 100
  StylesData['editvalue.Max']  := 100;// в % 0 до 100
  StylesData['PositionBar.Min'] := 0;//в % от 0 до 100
  StylesData['PositionBar.Nax'] := 100;//в % от 0 до 100
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
  ControlsEnabled:=True;
//  StylesData['openbutton.OnClick']:=TValue.From<TNotifyEvent>(OpenButtonClick);
//  StylesData['closebutton.OnClick']:=TValue.From<TNotifyEvent>(CloseButtonClick);
//  StylesData['startstopbutton.OnClick']:=TValue.From<TNotifyEvent>(StartStopButtonClick);
end;


destructor TFmxElectricValve.Destroy;
begin
  inherited;
end;

function TFmxElectricValve.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=False;
end;

procedure TFmxElectricValve.DoOnChange(Sender: TObject);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone: ;
    ccnEdit: begin
      //Пользователь выставил частоту в TEdit
      PositionEditChange();
      end;
    ccnStartStopButton: begin
      //Пользователь нажал кнопку стартстоп
      StartStopButtonClick(self);
    end;
    ccnOpenButton:begin
      //Пользователь шагово прибавил мощность
      OpenButtonClick(Sender);
    end;
    ccnCloseButton: begin
      //Пользователь шагово убавил мощность
      CloseButtonClick(Sender);
    end;
  end;
  CCN:=ccnNone;

end;

procedure TFmxElectricValve.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cElectricValvePropertyCount);
   for i := 0 to cElectricValvePropertyCount-1 do
   begin
     FParameters[i].Name:=cElectricValvePropertys[i]; //Наименование
     FParameters[i].ParamType:=cElectricValvePropertysType[i];//тип
     FParameters[i].Items:=cElectricValvePropertyComboItems[i];
   end;
end;

function TFmxElectricValve.GetCurState: String;
begin
  result:=inherited;
  if Assigned(Device) then
       result:=result+Format(': %f %',[Device.Position]);
end;

function TFmxElectricValve.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     inherited;
end;

function TFmxElectricValve.GetMaxI: Single;
begin
  if Assigned(Device) then
     result:=Device.MaxInput
  else
     result:=0;
end;

function TFmxElectricValve.GetMaxO: Single;
begin
  if Assigned(Device) then
     result:=Device.MaxOutput
  else
     result:=0;
end;

function TFmxElectricValve.GetMinI: Single;
begin
  if Assigned(Device) then
     result:=Device.MinInput
  else
     result:=0;
end;

function TFmxElectricValve.GetMinO: Single;
begin
  if Assigned(Device) then
     result:=Device.MinOutput
  else
     result:=0;
end;

function TFmxElectricValve.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

function TFmxElectricValve.GetParamValue(Row: integer): String;
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
      result := IntToStr(ValveInputNumber+1);
    14:
      result := IntToStr(ValveNumber+1);
    15:
      result := IntToStr(DefaultState);
    16:
      result := cBooleanName[Visible];
    17:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    18:
      result := IntToStr(TimeToSwitch);
    19:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    20:
      result := IntToStr(InputRegister[0]);
    21:
      result := IntToStr(OutputRegister[0]);
    22:
      result := FloatToStrF(MinInput, ffFixed, 15, 5);
    23:
      result := FloatToStrF(MaxInput, ffFixed, 15, 5);
    24:
      result := FloatToStrF(MinOutput, ffFixed, 15, 5);
    25:
      result := FloatToStrF(MaxOutput, ffFixed, 15, 5);
    26:
      result := IntToStr(ModulePriority);
  end;
end;


function TFmxElectricValve.GetPosition: Single;
begin
  if Assigned(Device) then
     result:=Device.Position
  else
     result:=0;
end;

function TFmxElectricValve.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 5];
end;

function TFmxElectricValve.GetStartCaption: String;
begin
  result:='пуск';
end;


function TFmxElectricValve.GetStopCaption: String;
begin
  result:='стоп';
end;

function TFmxElectricValve.GetSwitchTime: Integer;
begin
  result:=FTimeToSwitch;
end;

procedure TFmxElectricValve.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then
  begin
    Device := TFmxDeviceElectricValve.CreateOnModuleValve(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], ValveNumber,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxElectricValve.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited MouseMove(Shift, X, Y);
  SetFocus;
end;

procedure TFmxElectricValve.Move;
begin
  if Assigned(Device) then
  begin
    ActualTimeToSwitch:=TThread.GetTickCount()+TimeToSwitch*1000;
    Device.MoveValve(NewPosition);
    EditValue:=NewPosition;
    Device.UpdateStatus;
  end;
end;

procedure TFmxElectricValve.OpenButtonClick(Sender: TObject);
procedure OpenValve;
begin
  NewPosition:=100;
  ButtonEnabled:=False;
  EditValue  := NewPosition;// в % 0 до 100
  ScrollBarPosition := NewPosition;//в % от 0 до 100
  Device.ModuleManager.ExecuteInCOMThread(Move);
end;

begin
  if aftAskingBeforExec in AFTypeSet then
  begin
    if (not (aftAskingBeforExec in AFTypeSet)) or DialogYesNo('Вы действительно хотите открыть '+Caption+'?') then
    begin
      OpenValve();
      if Assigned(Device.AddToWorkLogProc) then
         Device.AddToWorkLogProc('Пользователь в ручном режиме открыл ' + Caption);
    end;
  end
  else
    OpenValve();
end;

procedure TFmxElectricValve.PositionEditChange;
begin
    NewPosition := EditValue;
    if aftAskingBeforExec in AFTypeSet then
      begin
        if (not (aftAskingBeforExec in AFTypeSet)) or DialogYesNo('Вы действительно хотите спозиционировать '+Caption+'?') then
        begin
          Device.AddToWorkLogProc('Пользователь в ручном режиме спозиционировал '+Caption);
          Device.ModuleManager.ExecuteInCOMThread(Move);
          if Assigned(Device.AddToWorkLogProc) then
             Device.AddToWorkLogProc('Пользователь в ручном режиме сместил позицию ' + Caption);
        end;
      end
      else
        Device.ModuleManager.ExecuteInCOMThread(Move);
end;

procedure TFmxElectricValve.ReceiveResponse;
begin
 try
    if Device.ConnectIsOK then
    begin
       if Device.Disguise then
       begin
         State:=fpsDisguise;
         Exit;
       end;
       try
      //     TFPControlState=(fpsEnabled,fpsDiscuse,fpsEnabledSelected,fpsDisabled,fpsDisabledSelected,fpsError,fpsEditing);
        if ControlsEnabled then

          if (Device.Position>0) or Device.Opened then State := fpsEnabledSelected
                           else State := fpsEnabled
        else
          if (Device.Position>0) or Device.Opened then State := fpsDisabledSelected
                           else State := fpsDisabled;
        InputValue:=Device.Position;
        ScrollBarPosition := Device.Position;
        if not  (State in [fpsDisabled,fpsDisabledSelected]) then
        begin
           editenabled:=True;//(Device.Direction = dStoped);
           StylesData['PositionBar.enabled']  := True;
           Buttonenabled:=ControlsEnabled;
          StylesData['closebutton.enabled'] := not (Device.Status = sClosed);
            StylesData['openbutton.enabled']  := not (Device.Status = sOpened);
        end;
        if Device.Direction = dStoped then ButtonText:=StartCaption
        else ButtonText:= StopCaption;

        if (Device.Status = sOpened) then
        begin
           //проверить - отключено ли управление на открытие

           if not LED1Light then
           begin
                LED1Light:=True;
                //Снимаем питание
                if ModuleType[1] in [mtValve,mtSuperBIO] then
                   Device.StopValve;
           end;
        end
        else
           LED1Light:=False;

        if (Device.Status = sClosed) then
        begin
           //проверить - отключено ли управление на закрытие
           if not LED2Light then
           begin
                LED2Light:=True;
                //Снимаем питание
                if ModuleType[1] in [mtValve,mtSuperBIO] then
                   Device.StopValve;
           end;
        end
        else
           LED2Light:=False;
       except
       end;
    end
    else begin
      //если не ConnectedIsOk
      State := fpsError;
    end;
 except
      on e:exception do
      begin
        if Assigned(Device) then
           Device.AddToWorkLogProc('Error in ReceiveResponse E='+e.Message,awlError);
      end;
 end;
end;

procedure TFmxElectricValve.RestoreValvePosition;
begin
  NewPosition:=PreviousPosition;
  Move;
end;

procedure TFmxElectricValve.SetAddress(AIdx: Integer; const Value: Integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxElectricValve.SetBaudrate(AIdx: Integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;


procedure TFmxElectricValve.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;


procedure TFmxElectricValve.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Device) then
     Device.MaxChannels:=Value;
end;

procedure TFmxElectricValve.SetMaxI(const Value: Single);
begin
  if Assigned(Device) then
     Device.MaxInput:=Value;
end;

procedure TFmxElectricValve.SetMaxO(const Value: Single);
begin
  if Assigned(Device) then
     Device.MaxOutput:=Value;
end;

procedure TFmxElectricValve.SetMinI(const Value: Single);
begin
  if Assigned(Device) then
     Device.MinInput:=Value;
end;

procedure TFmxElectricValve.SetMinO(const Value: Single);
begin
  if Assigned(Device) then
     Device.MinOutput:=Value;
end;

procedure TFmxElectricValve.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
      Device.Module.ModuleType := Value;
end;

procedure TFmxElectricValve.SetParamValue(Row: integer; const Value: String);
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
      First := myStrToBool(Value);
    12:
      AFIdx :=
        StrToIntDef(Value, AFIdx);
    13:
      ValveInputNumber :=
        StrToIntDef(Value, ValveInputNumber+1)-1;
    14:
      ValveNumber :=
        StrToIntDef(Value, ValveNumber+1)-1;
    15:
      DefaultState :=
        StrToIntDef(Value, DefaultState);
    16:
      Visible := myStrToBool(Value);
    17:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    18:
      TimeToSwitch :=
        StrToIntDef(Value, TimeToSwitch);
    19:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    20:
      InputRegister[0] := StrToIntDef(Value, 0);
    21:
      OutputRegister[0] := StrToIntDef(Value, 0);
    22:
      MinInput := StrToFloatDef(CP(Value),MinInput);
    23:
      MaxInput := StrToFloatDef(CP(Value),MaxInput);
    24:
      MinOutput := StrToFloatDef(CP(Value),MinOutput);
    25:
      MaxOutput := StrToFloatDef(CP(Value),MaxOutput);
    26:
      ModulePriority := StrToIntDef(Value, 0);
  end;
end;

procedure TFmxElectricValve.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxElectricValve.SetPosition(const Value: Single);
begin
  NewPosition:=Value;
  ActualTimeToSwitch:=TThread.GetTickCount()+TimeToSwitch*1000;
  StylesData['editvalue.value']  := Value;// в % 0 до 100
  if Assigned(Device) then
     Device.MoveValve(Value);
end;

procedure TFmxElectricValve.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;


function TFmxElectricValve.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxElectricValve.SetSwitchTime(const Value: Integer);
begin
  FTimeToSwitch := Value;
  if Assigned(Device) then
     Device.TimeToSwitch:=Value;
end;

procedure TFmxElectricValve.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;

procedure TFmxElectricValve.SetValveInputNumber(const Value: Byte);
begin
  FValveInputNumber := Value;
  if Assigned(Device) then
     Device.ValveInputNumber:=Value;
end;

procedure TFmxElectricValve.SetValveNumber(valve_number: Byte);
begin
  case Device.ModuleType of
  mtValve: if valve_number <= 2 then FValveNumber := valve_number;
  mtHSC_CTRL: if valve_number <= 23 then FValveNumber := valve_number;
  //2х канальные
  mtDAC_I702X,
  mtRT2,
  mtLogoDAC:if valve_number <= 1 then FValveNumber := valve_number;
  mtModbusA:if valve_number <= 16 then FValveNumber := valve_number;
  else
    FValveNumber := valve_number;
  end;
  if Assigned(Device) then
     Device.ValveNumber:=FValveNumber;
end;



procedure TFmxElectricValve.StartStopButtonClick(Sender: TObject);
begin
  if Device.Direction = dStoped then begin
    NewPosition := StylesData['editvalue.value'].AsExtended;
    if (NewPosition >= 0) and (NewPosition <= 100) then
    begin
      StylesData['editvalue.enabled']  := False;
      StylesData['PositionBar.enabled']  := False;
      StylesData['closebutton.enabled']  := False;
      StylesData['openbutton.enabled']  := False;
    if aftAskingBeforExec in AFTypeSet then
      begin
        if (not (aftAskingBeforExec in AFTypeSet)) or DialogYesNo('Вы действительно хотите спозиционировать '+Caption+'?') then
        begin
          Device.AddToWorkLogProc('Пользователь в ручном режиме спозиционировал '+Caption);
          Device.ModuleManager.ExecuteInCOMThread(Move);
          if Assigned(Device.AddToWorkLogProc) then
             Device.AddToWorkLogProc('Пользователь в ручном режиме сместил позицию ' + Caption);
        end;
      end
      else
        Device.ModuleManager.ExecuteInCOMThread(Move);
    end
    else begin
       if EditValue <> Device.Position then
        EditValue := Device.Position;
    end
  end
  else begin
    StylesData['editvalue.enabled']  := False;
    StylesData['PositionBar.enabled']  := False;
    StylesData['closebutton.enabled']  := False;
    StylesData['openbutton.enabled']  := False;
    Device.ModuleManager.ExecuteInCOMThread(Stop);
  end;
end;

procedure TFmxElectricValve.Stop;
begin
  if Assigned(Device) then
  begin
    ActualTimeToSwitch:=TThread.GetTickCount()+TimeToSwitch*1000;
    Device.StopValve;
    Device.UpdateStatus;
  end;
end;

procedure TFmxElectricValve.StoreValvePosition;
begin
  PreviousPosition:=Position;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxElectricValve]);
end;


end.
