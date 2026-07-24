unit FmxUnoperatedPump;

{ ===== Компонент FmxUnoperatedPump =====
Визуальный компонент насоса с дискретным управлением.
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cUnoperatedPumpStyle='unoperatedpumpstyle';

  //Количество свойств
  cUnoperatedPumpPropertyCount=27;
  //cOpenSensor, cCloseSensor,cOpenContact,cCloseContact
  //Наименования свойств
  cUnoperatedPumpPropertys:array[0..cUnoperatedPumpPropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cFirst,cNumAppFunction,cNumContactInp,cNumContactInp2,
  cNumContactOut,cNumContactOut2,сFeedback,cVisible,cTypeAppFunc,
  cTypeOfProtocol,cModbusInputReg,cModbusOutputReg,cModulePriority,cTwoControls,cImpulseOutput,cChannelsCount);

  //типы свойств
  cUnoperatedPumpPropertysType:array[0..cUnoperatedPumpPropertyCount-1]of TParameterType=(
//  cHeader,cHint
    ptText,ptText,
//  cPort,   cAddress,cBaudrate,
    ptNumber,ptNumber,ptNumber,
//  cParity
    ptComboBox,
//  cModuleType,
    ptComboBox,
//cLeft,cTop,cWidth,cHeight,
    ptFloat,ptFloat,ptFloat,ptFloat,
//  cFirst,cNumAppFunction,cNumContactInp,
    ptComboBox, ptNumber,       ptNumber,ptNumber,
//  cNumContactOut,сFeedback,cVisible,cTypeAppFunc,
    ptNumber,ptNumber,ptComboBox, ptComboBox,ptComboBox,
//  cTypeOfProtocol,cModbusInputReg,cModbusOutputReg,cModulePriority
    ptComboBox, ptNumber,  ptNumber,  ptNumber,ptComboBox,ptComboBox,ptComboBox
  );

  //Комбо выпадающие списки
  cUnoperatedPumpPropertyComboItems: array[0..cUnoperatedPumpPropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtHSC_CTRL,cmtSuperBIO,cmtValve,cmtBIO,cmtRT2,cmtModbusD],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cFirst,cNumAppFunction,cNumContactInp,
    [cNo,cYes],[],[],[],
//  cNumContactOut,сFeedback,cVisible,cTypeAppFunc,
    [],[],[cNo,cYes],[cNo,cYes],[cNumber,cMask],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModbusOutputReg,cModulePriority
    [],[],[],[cNo,cYes],[cNo,cYes],[]
    );



  type
  TFmxUnoperatedPump  = class(TFMXDeviceCustomControl)
  private
    // Флаг, используемый методом Switch.
    SwitchToStarted: Boolean;

    FStarted: boolean;

    FParity:TComParity;
    FTwoSwitch: boolean;
    FImpulseOutput: boolean;
    FLastOperation: boolean;

 // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    procedure SetStartOutputNumber(output_number: Byte);


    { ===== Switch =====
    Включает или выключает насос (в зависимости от значения флага SwitchToStarted), после чего
    обновляет статус модуля.
    }
    procedure Switch;
    procedure SetStartInputNumber(const Value: Byte);
    procedure SetWithInput(const Value: boolean);
    function GetStartInputNumber: Byte;
    function GetStartOutputNumber: Byte;
    function GetWithInput: boolean;
    function GetStarted: boolean;
    function GetStartCaption: String;
    function GetStopCaption: String;
    procedure SetTwoSwitch(const Value: boolean);
    function GetStopInputNumber: Byte;
    function GetStopOutputNumber: Byte;
    procedure SetStopInputNumber(const Value: Byte);
    procedure SetStopOutputNumber(const Value: Byte);
    procedure SetImpulseOutput(const Value: boolean);
    procedure SetLastOperation(const Value: boolean);
    function GetPriority: integer;override;

  protected

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetPriority(const Value: integer);override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType);override;
    procedure SetComPort(AIdx: integer; const Value: word);override;
    procedure SetAddress(AIdx: integer; const Value: integer);override;
    procedure SetBaudrate(AIdx: integer; const Value: Cardinal);virtual;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    function GetModuleManager: TFmxModuleManager;override;
    procedure Loaded; override;
    function Disguise: Boolean;override;
    function GetCurState: String;override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
    procedure SetParity(const Value: TComParity); override;
    // обработчик нажатия на кнопку.
    procedure StartStopButtonClick(Sender: TObject);
    procedure UpdateStyle;override;
    procedure SetLedsCount(const Value: byte);override;
    function GetMaxChannels: byte;override;
    procedure SetMaxChannels(const Value: byte);override;

  public

    // Указатель на используемое устройство.
    Device: TFmxDeviceBlcedValve;
    procedure Start;
    procedure Stop;
    constructor Create  (AOwner: TComponent); override;
    procedure DoOnChange(Sender: TObject); override;
    destructor Destroy; override;
    procedure FillParametersList;override;

  published
    // Номер выхода модуля, к которому подключен сливной клапан (от 0 до 12 для модуля SuperBIO, от 6 до 8 для
    // модуля Valve).
    property StartOutputNumber: Byte read GetStartOutputNumber write SetStartOutputNumber default 0;

    property StartInputNumber: Byte read GetStartInputNumber write SetStartInputNumber default 0;

    property StopOutputNumber: Byte read GetStopOutputNumber write SetStopOutputNumber default 0;

    property StopInputNumber: Byte read GetStopInputNumber write SetStopInputNumber default 0;
    //с вохдными значениями - true InputValues соответствуют OutputValues
    property WithInput:boolean read GetWithInput write SetWithInput default False;

    //два управляющих контакта
    property TwoSwitch: boolean read FTwoSwitch write SetTwoSwitch default false;

    property ShowHint;

    property Started:boolean read GetStarted;

    property StopCaption:String read GetStopCaption;

    property StartCaption:String read GetStartCaption;
    //Импульсный выход - Включение выхода | Пауза 1сек | Выключенние ыыхода - состояние считывается по внутреннему логическому флагу крайней операции
    property  ImpulseOutput:boolean read FImpulseOutput write SetImpulseOutput;
    //Флаг крайней операции
    property  LastOperation:boolean read FLastOperation write SetLastOperation;
 end;

procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti,
     FMX.Text,
     SYNCOBJS;

{ TFmxUnoperatedPump }


constructor TFmxUnoperatedPump.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cUnoperatedPumpStyle;
  Device := nil;
  Height := 70;
  Width := 80;
  ControlType:=ctUnoperatedFlowPump;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Насос '+IntToStr(FIdx+1);
  State:=fpsEnabled;
  LedsCount:=1;
  LED1ONColor:=CL_FMX_GREEN;
  LED1OFFColor:=CL_FMX_RED;
  LED1Light:=False;
  ButtonText:=StartCaption;
  ModuleType[0] := mtHSC_CTRL;
  Address[0] := 0;
  BaudRate[0] := 19200;
  StartOutputNumber := 0;
  StartInputNumber := 0;
  WithInput:=False;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
end;


destructor TFmxUnoperatedPump.Destroy;
begin
  if CriticalSection<>nil then begin
    CriticalSection.Free;
    CriticalSection:=nil;
  end;
  inherited Destroy;
end;

function TFmxUnoperatedPump.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=False;
end;

procedure TFmxUnoperatedPump.DoOnChange(Sender: TObject);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone: ;
    ccnEdit: begin
      end;
    ccnTrackBar: begin
    end;
    ccnStartStopButton: begin
      StartStopButtonClick(self);
    end;
    ccnOpenButton:begin
    end;
    ccnCloseButton: begin
    end;
  end;
  CCN:=ccnNone;

end;

procedure TFmxUnoperatedPump.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cUnoperatedPumpPropertyCount);
   for i := 0 to cUnoperatedPumpPropertyCount-1 do
   begin
     FParameters[i].Name:=cUnoperatedPumpPropertys[i]; //Наименование
     FParameters[i].ParamType:=cUnoperatedPumpPropertysType[i];//тип
     FParameters[i].Items:=cUnoperatedPumpPropertyComboItems[i];
   end;
end;

function TFmxUnoperatedPump.GetStartInputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then result:=Device.StartInputNumber
end;

function TFmxUnoperatedPump.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     inherited;
end;

function TFmxUnoperatedPump.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

function TFmxUnoperatedPump.GetStartOutputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then result:=Device.StartOutputNumber
end;

function TFmxUnoperatedPump.GetParamValue(Row: integer): String;
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
      result := IntToStr(StartInputNumber+1);
    14:
      result := IntToStr(StopInputNumber+1);
    15:
      result := IntToStr(StartOutputNumber+1);
    16:
      result := IntToStr(StopOutputNumber+1);
    17:
      result := cBooleanName[WithInput];
    18:
      result := cBooleanName[Visible];
    19:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    20:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    21:
      result := IntToStr(InputRegister[0]);
    22:
      result := IntToStr(OutputRegister[0]);
    23:
      result := IntToStr(ModulePriority);
    24:
      result := cBooleanName[TwoSwitch];
    25:
      result := cBooleanName[ImpulseOutput];
    26:
      result := IntToStr(MaxChannels);
  end;
end;


function TFmxUnoperatedPump.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 5];
end;

function TFmxUnoperatedPump.GetStartCaption: String;
begin
     result:='пуск';
end;

function TFmxUnoperatedPump.GetStarted: boolean;
begin
  //Если импульсное управление - возвращаем логически флаг
  if ImpulseOutput then
    result:=LastOperation
  else begin
    if Assigned(Device) then
       result:=Device.Opened
    else
       result:=False;
  end;
end;

function TFmxUnoperatedPump.GetCurState: String;
begin
  Result := inherited;
  if Assigned(Device) then
    Result := Result + Format(': %s', [ButtonText]);
end;

function TFmxUnoperatedPump.GetStopCaption: String;
begin
  result:='стоп';
end;

function TFmxUnoperatedPump.GetStopInputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then result:=Device.StopInputNumber
end;

function TFmxUnoperatedPump.GetStopOutputNumber: Byte;
begin
  result:=0;
  if Assigned(Device) then result:=Device.StopOutputNumber
end;

function TFmxUnoperatedPump.GetWithInput: boolean;
begin
  result:=false;
  if Assigned(Device) then result:=Device.WithInput
end;

procedure TFmxUnoperatedPump.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then begin
    Device := TFmxDeviceBlcedValve.CreateOnModule(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],Baudrate[0], StartOutputNumber,StartInputNumber,WithInput,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
  if CriticalSection=nil then
    CriticalSection:=TCriticalSection.create;
end;

procedure TFmxUnoperatedPump.ReceiveResponse;
begin
    if Device.ConnectIsOK then begin
       if Device.Disguise then
       begin
         State:=fpsDisguise;
         Exit;
       end;
      if ControlsEnabled then
      begin
        if Started then State := fpsEnabledSelected
                         else State := fpsEnabled;
      end
      else begin
        if Started then State := fpsDisabledSelected
                         else State := fpsDisabled;
      end;
      if not  (State in [fpsDisabled,fpsDisabledSelected]) then
         ButtonEnabled := true;
    end
    else
      State := fpsError;

    if not Started then ButtonText:= StartCaption
    else ButtonText:= StopCaption;

    LED1Light:=Started;
end;

procedure TFmxUnoperatedPump.SetAddress(AIdx: integer; const Value: integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxUnoperatedPump.SetBaudrate(AIdx: integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;

procedure TFmxUnoperatedPump.SetComPort(AIdx: integer;const  Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxUnoperatedPump.SetImpulseOutput(const Value: boolean);
begin
  FImpulseOutput := Value;
end;

procedure TFmxUnoperatedPump.SetLastOperation(const Value: boolean);
begin
  FLastOperation := Value;
end;

procedure TFmxUnoperatedPump.SetLedsCount(const Value: byte);
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

procedure TFmxUnoperatedPump.SetStartInputNumber(const Value: Byte);
begin
  if Assigned(Device) then
     Device.StartInputNumber := Value;
end;

procedure TFmxUnoperatedPump.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Device) then
     Device.MaxChannels:=Value;
end;

procedure TFmxUnoperatedPump.SetModuleType(AIdx: integer; const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
      Device.Module.ModuleType := Value;
end;

procedure TFmxUnoperatedPump.SetStartOutputNumber(output_number: Byte);
begin
  if Assigned(Device) then
  case ModuleType[0] of
    mtModbusD: if output_number in [1..16]   then Device.StartOutputNumber := output_number;
    mtBIO: if output_number <= 2 then Device.StartOutputNumber := output_number;
    mtSuperBIO: if output_number <= 12 then Device.StartOutputNumber := output_number;
    mtHSC_CTRL: if output_number <= 23 then Device.StartOutputNumber := output_number;
    mtValve: if (output_number >= 6) and (output_number <= 8) then Device.StartOutputNumber := output_number;
  end;
end;

procedure TFmxUnoperatedPump.SetStopInputNumber(const Value: Byte);
begin
  if Assigned(Device) then Device.StopInputNumber:=Value;
end;

procedure TFmxUnoperatedPump.SetStopOutputNumber(const Value: Byte);
begin
  if Assigned(Device) then Device.StopOutputNumber:=Value;
end;

procedure TFmxUnoperatedPump.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Port[0] :=StrToIntDef(Value,Port[0]);
    3:
      Address[0] :=StrToIntDef(Value,Address[0]);
    4:
      BaudRate[0] := StrToIntDef(Value, BaudRate[0]);
    5:
      Parity:=StrToParity(Value);
    6:
      ModuleType[0] := StrToModuleType(Value);
    7:
      left :=StrToFloatDef(CP(Value), left)-ShiftL;
    8:
      top :=StrToFloatDef(CP(Value), top)-ShiftT;
    9:
      width := StrToFloatDef(CP(Value), width);
    10:
      height := StrToFloatDef(CP(Value), height);
    11:
      First := myStrToBool(Value);
    12:
      AFIdx := StrToIntDef(Value, AFIdx);
    13:
      StartInputNumber :=StrToIntDef(Value, StartInputNumber+1)-1;
    14:
      StopInputNumber :=StrToIntDef(Value, StopInputNumber+1)-1;
    15:
      StartOutputNumber := StrToIntDef(Value, StartOutputNumber+1)-1;
    16:
      StopOutputNumber := StrToIntDef(Value, StopOutputNumber+1)-1;
    17:
      WithInput := myStrToBool(Value);
    18:
      Visible := myStrToBool(Value);
    19:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    20:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    21:
      InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    22:
      OutputRegister[0] := StrToIntDef(Value, OutputRegister[0]);
    23:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    24:
      TwoSwitch := myStrToBool(Value);
    25:
      ImpulseOutput := myStrToBool(Value);
    26:
      MaxChannels:=StrToIntDef(Value, MaxChannels);
  end;
end;

procedure TFmxUnoperatedPump.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxUnoperatedPump.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

function TFmxUnoperatedPump.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;


procedure TFmxUnoperatedPump.SetTwoSwitch(const Value: boolean);
begin
  FTwoSwitch := Value;
  if Assigned(Device) then
     Device.TwoSwitch:=Value;
  UpdateStyle();
end;

procedure TFmxUnoperatedPump.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;


procedure TFmxUnoperatedPump.SetWithInput(const Value: boolean);
begin
  if Assigned(Device) then
     Device.WithInput := Value;
end;


procedure TFmxUnoperatedPump.Start;
begin
  try
    LastOperation:=True;
    if Assigned(Device) then Device.Open;
    if ImpulseOutput then
    begin
      sleep(1000);
      if Assigned(Device) then Device.Stop;
    end;
  finally
    CriticalSection.Enter;
    if PumpsOpened<255 then
      inc(PumpsOpened);
    CriticalSection.Leave;
  end;
end;

procedure TFmxUnoperatedPump.StartStopButtonClick(Sender: TObject);
begin
  ButtonEnabled:=False;
  SwitchToStarted := not Started;
  if Assigned(Device) then
  begin
    if SwitchToStarted then
    begin
       if (aftAskingBeforExec in AFTypeSet) then
       begin
          if DialogYesNo('Вы действительно хотите включить '+Caption+'?') then
          begin
            Device.AddToWorkLogProc('Пользователь в ручном режиме включил '+Caption);
            //PositionEdit.Enabled := False;
            Device.ModuleManager.ExecuteInCOMThread(Switch);
          end;
       end
       else
          Device.ModuleManager.ExecuteInCOMThread(Switch);
    end
    else
       Device.ModuleManager.ExecuteInCOMThread(Switch);
  end;
end;

procedure TFmxUnoperatedPump.Stop;
begin
 try
  LastOperation:=False;
  if Assigned(Device) then Device.Close;
  if ImpulseOutput then
  begin
    sleep(1000);
    if Assigned(Device) then Device.Stop;
  end;
 finally
  CriticalSection.Enter;
  if PumpsOpened>0 then
    dec(PumpsOpened);
  CriticalSection.Leave;
 end;
end;

procedure TFmxUnoperatedPump.Switch;
begin
  if SwitchToStarted then
    Start()
  else
    Stop();

  if Assigned(Device) then
     Device.UpdateStatus;

end;

procedure TFmxUnoperatedPump.UpdateStyle;
begin
  inherited;
  if TwoSwitch then
  begin
     LedsCount:=2;
     LEDState[TLeds(0)]:=Started;
     LEDState[TLeds(1)]:=not Started;
  end
  else begin
     LedsCount:=1;
     LEDState[TLeds(0)]:=Started;
  end;
end;


procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxUnoperatedPump]);
end;

end.
