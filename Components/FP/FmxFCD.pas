unit FmxFCD;

{ ===== Компонент FmxFCD =====
   Визуальный компонент УПП
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cFCDClassicStyle='fcdstyle';
  cFCDOtherStyle='fcdotherstyle';

  //Количество свойств
  cFCDPropertyCount=22;
  (*
    cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cView,
  cTankPosition,
  cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc,
  cTypeOfProtocol,
  cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel);
*)

  //Наименования свойств
  cFCDPropertys:array[0..cFCDPropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cView,
  cTankPosition,
  cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc,
  cTypeOfProtocol,
  cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel);


  //типы свойств
  cFCDPropertysType:array[0..cFCDPropertyCount-1]of TParameterType=(
      // cHeader, cHint
      ptText,ptText,
      //  cPort,   cAddress,cBaudrate,
      ptNumber,ptNumber,ptNumber,
      //cParity
      ptComboBox,
      //  cModuleType,
      ptComboBox,
      //  cLeft,cTop,cWidth,cHeight,
      ptFloat,ptFloat,ptFloat,ptFloat,
      //  cView,
      ptComboBox,
      //  cTankToRight,
      ptComboBox,
      //  cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc
      ptComboBox,ptNumber,ptComboBox,ptNumber,
      //  cTypeOfProtocol,
      ptComboBox,
      //  cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel
      ptNumber,    ptNumber,      ptNumber,      ptNumber
    );

  //Комбо выпадающие списки
  cFCDPropertyComboItems: array[0..cFCDPropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtHSC_FCD,cmtFCD,сmtFCD2],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cView,
    [cStandart,cOtherView],
//  cTankToRight,
    [cTankToLeft,cTankToRight],
//  cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc
    [],[],[cNo,cYes],[cNumber,cMask],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel
    [],[],[],[]
    );




type
  TFmxFCD = class(TFMXDeviceCustomControl)

  private

    FFCDNumber: Byte;

    // Метка, используемая для отображения положения УПП.
    PositionLabel: TLabel;

    // Флаг, используемый методом Switch.
    SwitchInTank: Boolean;

    //Флаг полного раскрытия формы
    FTankToRight: boolean;
    FInTankPosition: boolean;
    FSynchroChannel: byte;

    // Обработчик нажатия на кнупку.
    procedure ButtonClick(Sender: TObject);

    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    procedure SetFCDNumber(FCD_number: Byte);

    { ===== Switch =====
    Переключает УПП на бак или на пролетную трубу (в зависимости от значения флага SwitchInTank), после чего
    обновляет статус модуля.
    }
    procedure Switch;

    procedure SetTankToRight(const Value: boolean);
    procedure SetInTankPosition(const Value: boolean);
    function GetInTankPosition: boolean;
    procedure UpdateTankPosotion;
    function GetPriority: integer;override;
    procedure SetSynchroChannel(const Value: byte);
    function GetFCDNumber: byte;
    function GetTimeToPipe: Single;
    function GetTimeToTank: Single;
    function GetInTankTime: Single;

  protected
    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    function GetModuleManager: TFmxModuleManager;override;
    procedure UpdateStyle;override;
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);override;
    procedure DoOnChange(Sender: TObject);override;
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

  public

    // Указатель на используемое устройство.
    Device: TFmxDeviceFCD;

    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    procedure FillParametersList;override;

  published

    property ShowHint;

    property FCDNumber:byte read GetFCDNumber write SetFCDNumber;
    //Позиция на бак - ссправа или слева
    property TankToRight:boolean read FTankToRight write SetTankToRight;

    property InTankPosition:boolean read GetInTankPosition write SetInTankPosition;

    property SynchroChannel:byte read FSynchroChannel write SetSynchroChannel;

    property TimeToTank:Single read GetTimeToTank;

    property TimeToPipe:Single read GetTimeToPipe;

    property InTankTime:Single read GetInTankTime;
  end;

procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti;



{ TFmxFCD }

procedure TFmxFCD.ButtonClick(Sender: TObject);
begin
  SwitchInTank := not Device.InTankPosition;
  ButtonEnabled := false;
    if Assigned(Device) then
    begin
        if (aftAskingBeforExec in AFTypeSet) then
        begin
          if DialogYesNo('Вы действительно хотите переключить ' + Caption + '?') then
            begin
              Device.AddToWorkLogProc('Пользователь в ручном режиме переключил '+Caption);
              Device.ModuleManager.ExecuteInCOMThread(Switch);
            end;
        end//if (aftAskingBeforExec in AFTypeSet)
        else
          Device.ModuleManager.ExecuteInCOMThread(Switch);
    end;//if Assigned(Device) then
end;

constructor TFmxFCD.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Device := nil;
  Active:=False;
  SynchroChannel:=0;
  ModuleType[0] := mtHSC_FCD;
  Address[0] := 0;
  BaudRate[0] := 115200;
  FFCDNumber := 0;
  AFIdx:=Idx+1;
  Width := 120;
  ControlType:=ctFCD;
  CaptionColor:=CL_FMX_WHITE;
  LED1ONColor:=CL_FMX_GREEN;
  LED1OFFColor:=CL_FMX_RED;
  ButtonText := 'переключить';
  Caption:='УПП '+IntToStr(Idx+1);
  OtherView:=False;
  ButtonEnabled := false;
  HitTest:=True;
  AutoCapture:=True;
//  OnMouseDown:=DoOnMouseDown;  - приводит к зацикливанию и переполнению
  ShortHeight:=60;
  LongHeight:=90;
  Height := ShortHeight;
  StyleLookup:=cFCDClassicStyle;
  InTankPosition:=False;
  TankToRight:=True;
  StylesData['mainbody.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  StylesData['body.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
  LedsCount:=1;
end;

destructor TFmxFCD.Destroy;
begin

  inherited;
end;

function TFmxFCD.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=false;
end;

procedure TFmxFCD.DoOnChange(Sender: TObject);
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

function TFmxFCD.GetCurState: String;
begin
  result:=inherited;
  if Assigned(PositionLabel) then
       result:=result+Format(': %s, %s ',[Infotext, InputValueWithExtension]);
end;

function TFmxFCD.GetFCDNumber: byte;
begin
  if Assigned(Device) then
  begin
     result:=Device.FCDNumber;
     FFCDNumber:=Device.FCDNumber;
  end;
  result:=FFCDNumber;
end;

function TFmxFCD.GetInTankPosition: boolean;
begin
  if Assigned(Device) then
    FInTankPosition:=Device.InTankPosition;
  result:=FInTankPosition;
end;

function TFmxFCD.GetInTankTime: Single;
begin
  if Assigned(Device) then
    result:=Device.InTankTime
  else
    result:=0;
end;

function TFmxFCD.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

  (*
    cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cView,
  cTankPosition,
  cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc,
  cTypeOfProtocol,
  cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel);
*)


function TFmxFCD.GetParamValue(Row: integer): String;
begin
  case Row of
    0://cHeader,
      result := Caption;
    1://cHint,
      result := Hint;
    2:
      result := IntToStr(Port[0]);
    3:
      result := IntToStr(Address[0]);
    4:
      result := IntToStr(BaudRate[0]);
    5:
      result:=cComParityName[Parity];//cPort,cAddress,cBaudrate,cParity,
    6:
      result := cModuleTypeNames[ModuleType[0]]; //cModuleType
    7:
      result := FloatToStr(left+ShiftL);
    8:
      result := FloatToStr(top+ShiftT);
    9:
      result := FloatToStr(width);
    10:
      result := FloatToStr(height); //cLeft,cTop,cWidth,cHeight
    11:
      result := cOtherViewName[OtherView];//cView
    12:
      result := cTankPositionName[TankToRight];//cTankPosition
    13:
      result := IntToStr(AFIdx);
    14:
      result := IntToStr(FCDNumber+1);
    15:
      result := cBooleanName[Visible];
    16:
      result := cTypeOfAppFunc[TypeOfAppFunc]; //cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc,
    17:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];//cTypeOfProtocol
    18:
      result := IntToStr(InputRegister[0]);//cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel
    19:
      result := IntToStr(OutputRegister[0]);
    20:
      result := IntToStr(ModulePriority);
    21:
      result := IntToStr(SynchroChannel);
  end;
end;

function TFmxFCD.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 5];
end;

function TFmxFCD.GetTimeToPipe: Single;
begin
  if Assigned(Device) then result:=Device.TimeToPipe
  else result:=0;
end;

function TFmxFCD.GetTimeToTank: Single;
begin
  if Assigned(Device) then result:=Device.TimeToTank
  else result:=0;
end;

procedure TFmxFCD.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then
  begin
    if (AFIdx=0) then AFIdx:=1;
    Device := TFMXDeviceFCD.CreateOnModule(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], AFIdx-1 , ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxFCD.ReceiveResponse;
begin
  if Assigned(Device) then
  begin
    if Device.ConnectIsOK then
    begin
       if Device.Disguise then
       begin
         State:=fpsDisguise;
         Exit;
       end;
      ControlPanelVisible:=True;
      if ControlsEnabled then
      begin
         if Active then
            State:=fpsEnabledSelected
         else
            State:=fpsEnabled;
      end
      else begin
         if Active then
            State:=fpsDisabledSelected
         else
            State:=fpsDisabled;
      end;
      InTankPosition:=Device.InTankPosition;
//      if InTankPosition then
//      begin
//         InputText:='--.- / --.-';
//      end
//      else begin
//         InputText:=Format('%5.1f / %5.1f',[TimeToTank/10.0,TimeToPipe/10.0]);
//      end;
        if InTankPosition then
        begin
           InputText:='--.- / --.-';
        end
        else begin
           InputText:=Format('%5.1f / %5.1f',[TimeToTank,TimeToPipe]);
        end;


      if not  (State in [fpsDisabled,fpsDisabledSelected]) then
         ButtonEnabled := true;
    end
    else begin
        State:=fpsError;
        ControlPanelVisible:=True;
    end;
  end;
end;

procedure TFmxFCD.SetAddress(AIdx: Integer; const Value: Integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxFCD.SetBaudrate(AIdx: Integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;


procedure TFmxFCD.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxFCD.SetFCDNumber(FCD_number: Byte);
begin
  FFCDNumber:=0;
  if Assigned(Device) then
  begin
     Device.FCDNumber:=FCD_number;
     FFCDNumber:=Device.FCDNumber;
  end;
end;

procedure TFmxFCD.UpdateTankPosotion();
begin
    if FInTankPosition then InfoText := 'Весовой бак'
    else InfoText := 'Пролетная труба';
    if TankToRight then
      LedState[TLeds(0)]:=not FInTankPosition
    else
      LedState[TLeds(0)]:=FInTankPosition;
end;

procedure TFmxFCD.SetInTankPosition(const Value: boolean);
begin
  if FInTankPosition <> Value then
  begin
    FInTankPosition := Value;
    UpdateTankPosotion();
  end;
  UpdateStyle();
end;

procedure TFmxFCD.SetTankToRight(const Value: boolean);
begin
  if FTankToRight <> Value then
  begin
    FTankToRight := Value;
    UpdateTankPosotion();
  end;
end;

procedure TFmxFCD.SetModuleType(AIdx: integer; const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
    Device.ModuleType:=Value;
end;


procedure TFmxFCD.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;//cHeader,cHint,
    2:
      Port[0] := StrToIntDef(Value, Port[0]);
    3:
      Address[0] :=
        StrToIntDef(Value, Address[0]);
    4:
      BaudRate[0] := StrToIntDef(Value, 9600);
    5:
      Parity:=StrToParity(Value); //cPort,cAddress,cBaudrate,cParity,
    6:
      ModuleType[0] := StrToModuleType(Value); //cModuleType
    7:
      left :=StrToFloatDef(CP(Value), left)-ShiftL;
    8:
      top := StrToFloatDef(CP(Value), top)-ShiftT;
    9:
      width :=StrToFloatDef(CP(Value), width);
    10:
      height :=StrToFloatDef(CP(Value), height);//cLeft,cTop,cWidth,cHeight
    11:
      OtherView := myStrToOtherView(Value); //cView
    12:
      TankToRight := myStrToTankPosition(Value); //cTankPosition
    13:
      AFIdx := StrToIntDef(Value, AFIdx);
    14:
       FCDNumber :=StrToIntDef(Value, 1)-1;
    15:
      Visible := myStrToBool(Value);
    16:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value); //cNumAppFunction,cNumChannel,cVisible,cTypeAppFunc
    17:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value)); //cTypeOfProtocol,
    18:
      InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    19:
      OutputRegister[0] := StrToIntDef(Value, OutputRegister[0]);
    20:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    21:
      SynchroChannel :=  StrToIntDef(Value, SynchroChannel); //cModbusInputReg,cModbusOutputReg,cModulePriority,cSynchroChannel
  end;
end;

procedure TFmxFCD.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxFCD.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

procedure TFmxFCD.SetSynchroChannel(const Value: byte);
begin
  FSynchroChannel := Value;
end;

function TFmxFCD.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxFCD.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone,
    ccnEdit,
    ccnOpenButton,ccnCloseButton:;
    ccnStartStopButton: begin
      //Пользователь нажал кнопку стартстоп
      ButtonClick(self);
    end;
  end;
  CCN:=ccnNone;
end;

procedure TFmxFCD.Switch;
begin
  if Assigned(Device) then
  begin
    Device.Switch(SwitchInTank);
    Device.UpdateStatus;
  end;
end;


procedure TFmxFCD.UpdateStyle;
var i:TFmxColorSheme;
    lighted,visibleflag:boolean;
    son,soff:String;
begin
  inherited;
  UpdateTankPosotion();
  if OtherView then
  begin
    if StyleLookup<>cFCDOtherStyle then
       StyleLookup:=cFCDOtherStyle;
    lighted:=LEDState[lpLED1];
    for i := Low(TFmxColorSheme) to High(TFmxColorSheme) do
    begin
       visibleflag:=i=ColorSheme;
       if lighted then
       begin
         son:='stateon_'+cFmxColorShemeName[i]+'.visible';
         soff:='stateoff_'+cFmxColorShemeName[i]+'.visible';
       end
       else begin
         son:='stateoff_'+cFmxColorShemeName[i]+'.visible';
         soff:='stateon_'+cFmxColorShemeName[i]+'.visible';
       end;
       StylesData[son]:=visibleflag;
       StylesData[soff]:=false;
    end;
  end
  else begin
    if StyleLookup<>cFCDClassicStyle then
       StyleLookup:=cFCDClassicStyle;
  end;


  if Full then
  begin
    //Большой вид
    if OtherView then
    begin
       lighted:=LEDState[lpLED1];
       StylesData['mainbody.height']:=LongHeight;
    end
    else begin
       Height:=LongHeight;
    end;
  end
  else begin
    if OtherView then
       StylesData['mainbody.height']:=ShortHeight
    else
       Height:=ShortHeight;
  end;
  StylesData['body.visible']:=Full;//Панель с кнопкой
end;


procedure TFmxFCD.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TFmxFCD.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cFCDPropertyCount);
   for i := 0 to cFCDPropertyCount-1 do
   begin
     FParameters[i].Name:=cFCDPropertys[i]; //Наименование
     FParameters[i].ParamType:=cFCDPropertysType[i];//тип
     FParameters[i].Items:=cFCDPropertyComboItems[i];
   end;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxFCD]);
end;


end.
