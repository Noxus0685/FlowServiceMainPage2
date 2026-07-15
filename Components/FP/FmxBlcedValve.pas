unit FmxBlcedValve;

{ ===== Компонент FmxBlcedValve =====
Визуальный компонент сливного клапана с весового бака
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cBlcedValveStyle='blcedvalvestyle';

  //Количество свойств
  cBlcedValvePropertyCount=24;

  //Наименования свойств
  cBlcedValvePropertys:array[0..cBlcedValvePropertyCount-1]of string=(
    cHeader,cHint,
    cPort,cAddress,cBaudrate,cParity,
    cModuleType,
    cLeft,cTop,cWidth,cHeight,
    cFirst,cNumAppFunction,cNumContactInp,
    cNumContactOut,сFeedback,cInitState,cVisible,cTypeAppFunc,
    cTypeOfProtocol,
    cModbusInputReg,cModbusOutputReg,cModulePriority,cChannelsCount
  );
  //типы свойств
  cBlcedValvePropertysType:array[0..cBlcedValvePropertyCount-1]of TParameterType=(
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
//  cFirst,cNumAppFunction,cNumContactInp,
    ptComboBox, ptComboBox, ptNumber,
//  cNumContactOut,сFeedback,cInitState,cVisible,cTypeAppFunc,
    ptNumber,ptComboBox,ptComboBox,ptComboBox,ptNumber,
//  cTypeOfProtocol,
    ptComboBox,
//  cModbusInputReg,cModbusOutputReg,cModulePriority,cChannelsCount
    ptNumber,ptNumber,ptNumber,ptNumber
  );

  //Комбо выпадающие списки
  cBlcedValvePropertyComboItems: array[0..cBlcedValvePropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtHSC_CTRL,cmtHSC_FCD,cmtSuperBIO,cmtValve,cmtBIO,cmtRT2,cmtModbusD],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cFirst,cNumAppFunction,cNumContactInp,
    [cNo,cYes],[cNumber,cMask],[],
//  cNumContactOut,сFeedback,cInitState,cVisible,cTypeAppFunc,
    [],[cNo,cYes],[cNo,cYes],[cNo,cYes],[],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModbusOutputReg,cModulePriority,cChannelsCount
    [],[],[],[]
    );




type
  TFmxBlcedValve  = class(TFMXDeviceCustomControl)
  private
    // Флаг, используемый методом Switch.
    SwitchToOpened: Boolean;

    FParity: TComParity;

    // Обработчик нажатия на кнупку.
    procedure ButtonClick(Sender: TObject);

    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetPriority(const Value: integer);override;

    { ===== Switch =====
    Открывает или закрывает сливной клапан (в зависимости от значения флага SwitchToOpened), после чего
    обновляет статус модуля.
    }
    procedure Switch;
    procedure SetWithInput(const Value: boolean);
    procedure SetStartInputNumber(const Value: Byte);
    procedure SetStartOutputNumber(Value: Byte);
    function GetStartInputNumber: Byte;
    function GetStartOutputNumber: Byte;
    function GetWithInput: boolean;
    function GetStopInputNumber: Byte;
    function GetStopOutputNumber: Byte;
    procedure SetStopInputNumber(const Value: Byte);
    procedure SetStopOutputNumber(const Value: Byte);
    function GetTwoSwitch: Boolean;
    function GetPriority: integer;override;

  protected

    procedure Loaded; override;
    procedure SetLedsCount(const Value: byte);override;
    procedure DoOnChange(Sender: TObject);override;
    procedure SetComPort(AIdx: integer; const Value: word);override;
    procedure SetAddress(AIdx: integer; const Value: integer);override;
    procedure SetBaudrate(AIdx: integer; const Value: Cardinal);virtual;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType);override;
    function Disguise: Boolean;override;
    function GetCurState: String;override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
    procedure SetParity(const Value: TComParity);override;
    function GetMaxChannels: byte;override;
    procedure SetMaxChannels(const Value: byte);override;

  public

    // Указатель на используемое устройство.
    Device: TFmxDeviceBlcedValve;

    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    procedure FillParametersList;override;

  published
    // Номер входа модуля, к которому подключен сливной клапан (от 0 до 12 для модуля SuperBIO, от 6 до 8 для
    // модуля Valve).
    property InputNumber: Byte read GetStartInputNumber write SetStartInputNumber default 0;

    property OutputNumber: Byte read GetStartOutputNumber write SetStartOutputNumber default 0;

    //с вохдными значениями - true InputValues соответствуют OutputValues
    property WithInput:boolean read GetWithInput write SetWithInput default False;

    property TwoSwitch:Boolean read GetTwoSwitch;

  end;

procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti,
     FMX.Text,
     SYNCOBJS;


{ TFmxBlcedValve }

procedure TFmxBlcedValve.ButtonClick(Sender: TObject);
begin
  ButtonEnabled := false;
  SwitchToOpened := not Device.Opened;
  Device.ModuleManager.ExecuteInCOMThread(Switch);
end;

constructor TFmxBlcedValve.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cBlcedValveStyle;
  Device := nil;
  ControlType:=ctUnoperatedFlowPump;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Клапан '+IntToStr(FIdx+1);
  LedsCount:=1;
  LED1ONColor:=CL_FMX_GREEN;
  LED1OFFColor:=CL_FMX_RED;
  LED1Light:=False;
  ButtonText:=cCloseCaption;
  ModuleType[0] := mtHSC_CTRL;
  Address[0] := 0;
  BaudRate[0] := 19200;
  OutputNumber := 0;
  InputNumber := 0;
  WithInput:=False;
  Height := 70;
  Width := 80;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
end;

procedure TFmxBlcedValve.SetLedsCount(const Value: byte);
begin
  inherited;
  case Value of
  1: begin
    LED1ONColor:=CL_FMX_GREEN;
    LED1OFFColor:=CL_FMX_RED;
    end;
  2: begin
    LED1ONColor:=CL_FMX_GREEN;
    LED1OFFColor:=CL_FMX_OFF;
    LED2ONColor:=CL_FMX_RED;
    LED2OFFColor:=CL_FMX_OFF;
    end;
  end;
end;


destructor TFmxBlcedValve.Destroy;
begin

  inherited;
end;

function TFmxBlcedValve.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=false;
end;

function TFmxBlcedValve.GetCurState: String;
begin
  result:=inherited;
  result:=result+Format(': %s',[ButtonText]);
end;

function TFmxBlcedValve.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     inherited;
end;

function TFmxBlcedValve.GetStartInputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then
     result:=Device.StartInputNumber;
end;

function TFmxBlcedValve.GetStartOutputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then
     result:=Device.StartOutputNumber;
end;

function TFmxBlcedValve.GetStopInputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then
     result:=Device.StopInputNumber;

end;

function TFmxBlcedValve.GetStopOutputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then
     result:=Device.StopOutputNumber;
end;

function TFmxBlcedValve.GetTwoSwitch: Boolean;
begin
  result:=False;
end;

function TFmxBlcedValve.GetParamValue(Row: integer): String;
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
      result := IntToStr(OutputNumber+1);
    15:
      result := cBooleanName[WithInput];
    16:
      result := cBooleanName
        [Boolean(DefaultState and 1)];
    17:
      result := cBooleanName[Visible];
    18:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    19:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    20:
      result := IntToStr(InputRegister[0]);
    21:
      result := IntToStr(OutputRegister[0]);
    22:
      result := IntToStr(ModulePriority);
    23:
      result := IntToStr(MaxChannels);
  end;
end;


function TFmxBlcedValve.GetRebootWarning(Row: integer): Boolean;
begin
  result := Row in [2 .. 5];
end;

function TFmxBlcedValve.GetWithInput: boolean;
begin
  result:=false;
  if Assigned(Device) then
     result:=Device.WithInput;
end;

procedure TFmxBlcedValve.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then begin
    Device := TFmxDeviceBlcedValve.CreateOnModule(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], OutputNumber,InputNumber,WithInput, ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxBlcedValve.ReceiveResponse;
begin
   if Assigned(Device) then
   begin
    //Цвет фона капшена
    if Device.ConnectIsOK then
    begin
      if Device.Disguise then
      begin
         State:=fpsDisguise;
         Exit;
      end;
      if ControlsEnabled then
      begin
        if Device.Opened then State := fpsEnabledSelected
                         else State := fpsEnabled;
      end
      else begin
        if Device.Opened then State := fpsDisabledSelected
                         else State := fpsDisabled;
      end;
      if not  (State in [fpsDisabled,fpsDisabledSelected]) then
         ButtonEnabled := true;
    end
    else
      State := fpsError;

    //Надпись на кнопке
    if Device.Opened then ButtonText := cOpenCaption
    else ButtonText := cCloseCaption;

    //Индикация состояния
    LedState[TLeds(0)]:=Device.Opened;
   end;
end;

procedure TFmxBlcedValve.SetAddress(AIdx: integer; const Value: integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxBlcedValve.SetBaudrate(AIdx: integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;

procedure TFmxBlcedValve.SetComPort(AIdx: integer;const  Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxBlcedValve.SetStartInputNumber(const Value: Byte);
begin
  if Assigned(Device) then
  case ModuleType[0] of
    mtModbusD: if (Value >=1) and (Value <= 16) then Device.StartInputNumber:=Value;
    mtSuperBIO: if Value <= 12 then Device.StartInputNumber:=Value;
    mtHSC_FCD: if Value <= 3 then Device.StartInputNumber := Value;
    mtHSC_CTRL: if Value <= 23 then Device.StartInputNumber:=Value;
    mtValve: if (Value >= 6) and (Value <= 8) then Device.StartInputNumber:=Value;
  else
    Device.StartInputNumber := Value;
  end;
end;

procedure TFmxBlcedValve.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Device) then
     Device.MaxChannels:=Value;
end;

procedure TFmxBlcedValve.SetModuleType(AIdx: integer; const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
       Device.Module.ModuleType := Value;
end;

procedure TFmxBlcedValve.SetStartOutputNumber(Value: Byte);
begin
  if Assigned(Device) then
  case ModuleType[0] of
    mtModbusD: if (Value >=1) and (Value <= 16) then Device.StartOutputNumber := Value;
    mtBIO: if Value <= 2 then Device.StartOutputNumber := Value;
    mtHSC_FCD: if Value <= 3 then Device.StartOutputNumber := Value;
    mtHSC_CTRL: if Value <= 23 then Device.StartOutputNumber := Value;
    mtSuperBIO: if Value <= 12 then Device.StartOutputNumber := Value;
    mtValve: if (Value >= 6) and (Value <= 8) then Device.StartOutputNumber := Value;
    else
       Device.StartOutputNumber := Value;
  end;
end;

procedure TFmxBlcedValve.SetStopInputNumber(const Value: Byte);
begin
  if Assigned(Device) then
  case ModuleType[0] of
    mtModbusD: if (Value >=1) and (Value <= 16) then Device.StopInputNumber:=Value;
    mtSuperBIO: if Value <= 12 then Device.StopInputNumber:=Value;
    mtHSC_FCD: if Device.StartOutputNumber > 3 then Device.StopOutputNumber := 2;
    mtHSC_CTRL: if Value <= 23 then Device.StopInputNumber:=Value;
    mtValve: if (Value >= 6) and (Value <= 8) then Device.StopInputNumber:=Value;
  else
    Device.StopInputNumber := Value;
  end;

end;

procedure TFmxBlcedValve.SetStopOutputNumber(const Value: Byte);
begin
  if Assigned(Device) then
  case ModuleType[0] of
    mtModbusD: if (Value >=1) and (Value <= 16) then Device.StopOutputNumber := Value;
    mtBIO: if Value <= 2 then Device.StopOutputNumber := Value;
    mtHSC_FCD: if Value <= 2 then Device.StopOutputNumber := Value;
    mtHSC_CTRL: if Value <= 23 then Device.StopOutputNumber := Value;
    mtSuperBIO: if Value <= 12 then Device.StopOutputNumber := Value;
    mtValve: if (Value >= 6) and (Value <= 8) then Device.StopOutputNumber := Value;
    else
       Device.StopOutputNumber := Value;
  end;
end;

procedure TFmxBlcedValve.SetParamValue(Row: integer; const Value: String);
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
      InputNumber :=
        StrToIntDef(Value, InputNumber+1)-1;
    14:
      OutputNumber :=
        StrToIntDef(Value, OutputNumber+1)-1;
    15:
      WithInput := myStrToBool(Value);
    16:
      DefaultState :=
        StrToIntDef(Value, DefaultState);
    17:
      Visible := myStrToBool(Value);
    18:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    19:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    20:
      InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    21:
      OutputRegister[0] := StrToIntDef(Value, OutputRegister[0]);
    22:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    23:
      MaxChannels:=StrToIntDef(Value, MaxChannels);
  end;
end;

procedure TFmxBlcedValve.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxBlcedValve.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

function TFmxBlcedValve.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxBlcedValve.SetTypeOfProtocol(AIdx: integer;
  const Value: TTypeOfProtocol);
begin
  inherited;

end;

procedure TFmxBlcedValve.SetWithInput(const Value: boolean);
begin
  if Assigned(Device) then
     Device.WithInput:=Value;
end;

procedure TFmxBlcedValve.Switch;
begin
  if SwitchToOpened then Device.Open
  else Device.Close;
  Device.UpdateStatus;
end;

procedure TFmxBlcedValve.DoOnChange(Sender: TObject);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone: ;
    ccnEdit: begin
      end;
    ccnStartStopButton: begin
      //Пользователь нажал кнопку стартстоп
      ButtonClick(self);
    end;
    ccnOpenButton:begin
    end;
    ccnCloseButton: begin
    end;
  end;
  CCN:=ccnNone;

end;



procedure TFmxBlcedValve.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cBlcedValvePropertyCount);
   for i := 0 to cBlcedValvePropertyCount-1 do
   begin
     FParameters[i].Name:=cBlcedValvePropertys[i]; //Наименование
     FParameters[i].ParamType:=cBlcedValvePropertysType[i];//тип
     FParameters[i].Items:=cBlcedValvePropertyComboItems[i];
   end;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxBlcedValve]);
end;

end.
