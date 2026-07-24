unit FmxPneumaticValve;
{ ===== Компонент FmxPneumaticValve =====
Визуальный компонент задвижки с дискретным управлением.
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FPCustomControl,FMXDeviceCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cPneumaticValveStyle='pneumaticvalvestyle';

  //Количество свойств
  cDiscretValvePropertyCount=29;

  //Наименования свойств
  cDiscretValvePropertys:array[0..cDiscretValvePropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,
  cLeft,cTop,cWidth,cHeight,
  cFirst,cNumAppFunction,cOpenSensor,
  cCloseSensor,cOpenContact,cCloseContact,cSwitchTime,сFeedback,cTwoControls,cFemale,cInitState,
  cVisible,cTypeAppFunc,cTypeOfProtocol,cModbusInputReg,cModbusOutputReg,cModulePriority,cChannelsCount);

  //типы свойств
  cDiscretValvePropertysType:array[0..cDiscretValvePropertyCount-1]of TParameterType=(
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
//  cFirst,cNumAppFunction,cOpenSensor,
    ptComboBox, ptNumber,       ptNumber,
//  cCloseSensor,cOpenContact,cCloseContact,cSwitchTime,
    ptNumber,ptNumber,ptNumber,ptNumber,
//  сFeedback,cTwoControls,cFemale,cInitState,cVisible,cTypeAppFunc,
    ptComboBox,ptComboBox,ptComboBox,ptComboBox,ptComboBox, ptComboBox,
//  cTypeOfProtocol,
    ptComboBox,
//  cModbusInputReg,cModbusOutputReg,cModulePriority
    ptNumber,ptNumber,ptNumber,ptNumber
  );

  //Комбо выпадающие списки
  cDiscretValvePropertyComboItems: array[0..cDiscretValvePropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtHSC_CTRL,cmtSuperBIO,cmtValve,cmtBIO,cmtRT2,cmtModbusD],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cFirst,cNumAppFunction,cOpenSensor,
    [cNo,cYes],[],[],
//  cCloseSensor,cOpenContact,cCloseContact,cSwitchTime,
    [],[],[],[],
//  сFeedback,cTwoControls,cFemale,cInitState,cVisible,cTypeAppFunc,
    [cNo,cYes],[cNo,cYes],[cNo,cYes],[cNo,cYes],[cNo,cYes],[cNumber,cMask],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModbusOutputReg,cModulePriority
    [],[],[],[]
    );



type

  // Тип, используемый для определения типа модуля (не путать с одноименным типом в unit'е DeviceManager).

  //==========================================================================================================

  TFmxPneumaticValve = class(TFMXDeviceCustomControl)

  private

    FTwoSwitch:boolean;

    FTimeToSwitch:byte;

    //линии управления
    FOpenONumber: word;

    FCloseONumber:word;

    //линии мониоринга концевых выключателей
    FOpenINumber: word;

    FCloseINumber:word;

    // Флаг, используемый методом Switch.
    SwitchToOpened: Boolean;

    FWithInput: boolean;

    FFemale: boolean;

    FDevice: TFmxDevicePneumaticValve;

    FParity: TComParity;
    //FBaudRate: Cardinal;

    // Опработчик нажатия на кнупку.
    procedure ButtonClick(Sender: TObject);

    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;

    { ===== Switch =====
    Открывает или закрывает пневмозадвижку (в зависимости от значения флага SwitchToOpened), после чего
    обновляет статус модуля.
    }
    procedure Switch;

    // вывод сообщения
    procedure mess;
    procedure SetWithInput(const Value: boolean);
    procedure SetFemale(const Value: boolean);
    procedure SetDevice(const Value: TFmxDevicePneumaticValve);
    function GetOpened: boolean;

    procedure SetCloseONumber(const Value: word);
    procedure SetOpenONumber(const Value: word);

    procedure SetCloseINumber(const Value: word);
    procedure SetOpenINumber(const Value: word);

    procedure SetTwoSwitch(const Value: boolean);
    function GetCmdCompleted: boolean;
    function GetLastCmd: boolean;
    function GetClosed: boolean;
    procedure SetOpenTickCount(const Value: Cardinal);
    procedure SetCloseTickCount(const Value: Cardinal);
    function GetMustInCloseState: boolean;
    function GetMustInOpenState: boolean;
    procedure Stop;
    function GetCloseTickCount: Cardinal;
    function GetOpenTickCount: Cardinal;
    function GetStopped: boolean;
    function GetPriority: integer;override;
    function GetMaxChannels: byte;override;
    procedure SetMaxChannels(const Value: byte);override;

  protected

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    procedure UpdateStyle;override;
    procedure DoOnChange(Sender: TObject);override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType);override;
    procedure SetComPort(AIdx: integer; const Value: word);override;
    procedure SetAddress(AIdx: integer; const Value: integer);override;
    procedure SetBaudrate(AIdx: integer; const Value: Cardinal);virtual;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    function GetModuleManager: TFmxModuleManager;override;
    function Disguise: Boolean;override;
    function GetCurState: String;override;
    procedure SetLedsCount(const Value: byte);override;
    procedure SetParity(const Value: TComParity);override;

  public
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure FillParametersList;override;

  published
    // Номер выхода, к которым подключено устройство (от 0 до 12 для модуля SuperBIO, от
    // 6 до 8 для модуля Valve).
    property OpenONumber: word read FOpenONumber write SetOpenONumber default 0;

    // Номер входа, к которым подключено устройство (от 0 до 12 для модуля SuperBIO, от
    // 6 до 8 для модуля Valve).
    property OpenINumber: word read FOpenINumber write SetOpenINumber default 0;

    //Теперь неожиданно электрозадвижка стала с конечниками, с двумя
    //Так как задвижка ездит медленно, то нужно следить за обоими,
    //поэтому опять будем городить огород, что бы обрабатывать оба конечника
    property TwoSwitch: boolean read FTwoSwitch write SetTwoSwitch default false;

    //Ноемр входа платы superbio для второго управления
    property CloseONumber: word read FCloseONumber write SetCloseONumber;

    //Ноемр входа платы superbio для второго конечника
    property CloseINumber: word read FCloseINumber write SetCloseINumber;

    //Время движения задвижки. После истечения данного времени с момента подачи команды,
    //считаем, что задвижка открылась или закрылась. Нужно для безконечниковой задвижки
    property TimeToSwitch: byte read FTimeToSwitch write FTimeToSwitch;

    //с вохдными значениями - true InputValues соответствуют OutputValues
    property WithInput:boolean read FWithInput write SetWithInput;

    property Female:boolean read FFemale write SetFemale;

    property ShowHint;

    property Visible;

    property Device:TFmxDevicePneumaticValve read FDevice write SetDevice;

    property Opened:boolean read GetOpened;

    property Closed:boolean read GetClosed;

    property LastCmd:boolean read GetLastCmd;

    property CmdCompleted:boolean read GetCmdCompleted;//команда выполнена

    property OpenTickCount:Cardinal read GetOpenTickCount write SetOpenTickCount;//время - если меньше текущего - знаит событие наступило - если 0 - то такого события не было

    property CloseTickCount:Cardinal read GetCloseTickCount write SetCloseTickCount;//время - если меньше текущего - знаит событие наступило - если 0 - то такого события не было

    property  MustInOpenState:boolean read GetMustInOpenState;

    property  MustInCloseState:boolean read GetMustInCloseState;

    property Stopped:boolean read GetStopped;

  end;

//============================================================================================================

procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     FmxFpModules,
     System.Rtti,
     FMX.Text,
{$IFDEF MSWINDOWS}
      Winapi.Windows,
{$ENDIF}
     SYNCOBJS;


{ TFmxPneumaticValve }

procedure TFmxPneumaticValve.Close;
begin
  if Assigned(Device) then Device.Close;
end;

constructor TFmxPneumaticValve.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cPneumaticValveStyle;
  Device := nil;
  ControlType:=ctPneumaticValve;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Клапан '+IntToStr(FIdx+1);
  LedsCount:=2;
  LED1Light:=False;
  LED2Light:=False;
  ModuleType[0] := mtHSC_CTRL;
  Address[0] := 0;
  BaudRate[0] := 19200;
  FOpenINumber := 0;
  FCloseINumber := 1;
  FTimeToSwitch:=20;
  Height := 70;
  Width := 80;
  FFemale := True;
  ButtonText:=femalenames[false];
  WithInput := True;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;

end;

destructor TFmxPneumaticValve.Destroy;
begin

  inherited;
end;

function TFmxPneumaticValve.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=False;
end;

procedure TFmxPneumaticValve.DoOnChange(Sender: TObject);
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
      //Пользователь нажал кнопку
      ButtonClick(self);
    end;
    ccnOpenButton:begin
      //Пользователь шагово прибавил мощность
    end;
    ccnCloseButton: begin
      //Пользователь шагово убавил мощность
    end;
  end;
  CCN:=ccnNone;

end;

procedure TFmxPneumaticValve.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cDiscretValvePropertyCount);
   for i := 0 to cDiscretValvePropertyCount-1 do
   begin
     FParameters[i].Name:=cDiscretValvePropertys[i]; //Наименование
     FParameters[i].ParamType:=cDiscretValvePropertysType[i];//тип
     FParameters[i].Items:=cDiscretValvePropertyComboItems[i];
   end;
end;

function TFmxPneumaticValve.GetClosed: boolean;
begin
  //если время равно нулю - работаем по контактам
  if TimeToSwitch=0 then
  begin
    result:=Device.Closed
  end
  else begin
    if TwoSwitch then
        result:=Device.Closed or MustInCloseState
    else
        result:=Device.Closed
  end;
end;

function TFmxPneumaticValve.GetCloseTickCount: Cardinal;
begin
  if TimeToSwitch=0 then
  begin
    result:=0;
  end
  else begin
    if Assigned(Device) then
       result:=Device.CloseTickCount
    else
       result:=0;
  end;
end;

function TFmxPneumaticValve.GetCmdCompleted: boolean;
begin
  if Assigned(Device) then
     result:=(not (Device.LastCmd xor Device.Opened))
  else
     result:=True;
end;

function TFmxPneumaticValve.GetCurState: String;
var o,c:integer;
begin
  result:=inherited;
   if GetTickCount>OpenTickCount then
      o:=0
   else
      o:=(OpenTickCount-GetTickCount) div 1000;
   if GetTickCount>CloseTickCount then
      c:=0
   else
      c:=(CloseTickCount-GetTickCount) div 1000;

   result:=result+Format(': %s О:%d(%d) С:%d(%d) - ',[ButtonText,ord(MustInOpenState),o,ord(MustInCloseState),c]);
end;

function TFmxPneumaticValve.GetLastCmd: boolean;
begin
  if Assigned(Device) then
     result:=Device.LastCmd
  else
     result:=false;
end;

function TFmxPneumaticValve.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

function TFmxPneumaticValve.GetMustInCloseState: boolean;
begin
  if Assigned(Device) then
  begin
    if TimeToSwitch=0 then
    begin
      result:=Device.Closed;
    end
    else begin
      //если было действие - о чем говорит CloseTickCount, и время вышло
      if TwoSwitch then
         result:=(CloseTickCount>0) and (CloseTickCount<GetTickCount) or (Device.Closed) and (not Device.Opened)
      else
         result:=Device.Closed;
    end;
  end
  else
    result:=false;
end;

function TFmxPneumaticValve.GetMustInOpenState: boolean;
begin
  if Assigned(Device) then
  begin
    if TimeToSwitch=0 then
    begin
      result:=Device.Opened;
    end
    else begin
      //если было действие - о чем говорит OpenTickCount, и время вышло
      if TwoSwitch then
         result:=(OpenTickCount>0) and (OpenTickCount<GetTickCount) or (Device.Opened) and (not Device.Closed)
      else
         result:=Device.Opened;
    end;
  end
  else
    result:=false;
end;

function TFmxPneumaticValve.GetOpened: boolean;
begin
  if Assigned(Device) then
  begin
    if TimeToSwitch=0 then
    begin
          result:=Device.Opened
    end
    else begin
      if TwoSwitch then
          result:=Device.Opened or MustInOpenState
      else
          result:=Device.Opened
    end;
  end
  else
    result:=false;
end;

function TFmxPneumaticValve.GetOpenTickCount: Cardinal;
begin
  if TimeToSwitch=0 then
  begin
    result:=0;
  end
  else begin
    if Assigned(Device) then
       result:=Device.OpenTickCount
    else
       result:=0;
  end;
end;

function TFmxPneumaticValve.GetParamValue(Row: integer): String;
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
      //Входы
    13:
      result := IntToStr(OpenINumber+1);
    14:
      result := IntToStr(CloseINumber+1);
      //Выходы
    15:
      result := IntToStr(OpenONumber+1);
    16:
      result := IntToStr(CloseONumber+1);
    17:
      result := IntToStr(TimeToSwitch);
    18:
      result := cBooleanName[WithInput];
    19:
      result := cBooleanName[TwoSwitch];
    20:
      result := cBooleanName[Female];
    21:
      result := cBooleanName
        [Boolean(DefaultState and 1)];
    22:
      result := cBooleanName[Visible];
    23:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    24:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    25:
      result := IntToStr(InputRegister[0]);
    26:
      result := IntToStr(OutputRegister[0]);
    27:
      result := IntToStr(ModulePriority);
    28:
      result := IntToStr(MaxChannels);
  end;
end;


function TFmxPneumaticValve.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 5];
end;

function TFmxPneumaticValve.GetStopped: boolean;
begin
  if Assigned(Device) then
     result:=Device.Stopped
  else
     result:=True;
end;

function TFmxPneumaticValve.GetMaxChannels: byte;
begin
  if Assigned(Device) then
     result:=Device.MaxChannels
  else
     inherited;
end;

procedure TFmxPneumaticValve.Loaded;
begin
  inherited;
  Device := TFmxDevicePneumaticValve.CreateOnModule(ModbusTCPHost,ModbusTCPPort,port[0],Address[0],BaudRate[0],
            OpenINumber,CloseINumber,OpenONumber,CloseONumber,FTwoSwitch,FWithInput,ModuleType[0],
            InputRegister[0],OutputRegister[0],TypeOfProtocol[0]);
  Device.AddReceiver(ReceiveResponse);
  Device.TimeToSwitch:=FTimeToSwitch;
end;

procedure TFmxPneumaticValve.mess;
begin
  ShowMessage('Невозможно закрыть задвижку при включенном насосе');
end;

procedure TFmxPneumaticValve.Open;
begin
  if Assigned(Device) then Device.Open;
end;

procedure TFmxPneumaticValve.ReceiveResponse;
begin
  inherited;
  if Assigned(Device) then
  try
      if Device.ConnectIsOK then
      begin
        if Device.Disguise then
        begin
           State:=fpsDisguise;
           Exit;
        end;
        Device.WithInput:=WithInput;
        //можно переключаться, если пришел сигнал, что открыто или вышло время
        if TwoSwitch then
        begin
           //если конечники показывают текущее состояние
           if TimeToSwitch=0 then
              SwitchToOpened :=NOT  (Device.Opened)
           else
             SwitchToOpened :=NOT  (Device.Opened or MustInOpenState);
        end
        else
           SwitchToOpened :=NOT  Device.Opened;

        if ControlsEnabled then
        begin
          if Device.Opened then State:=fpsEnabledSelected
          else State:=fpsEnabled;
        end
        else begin
          if Device.Opened then State:=fpsDisabledSelected
          else State:=fpsDisabled;
        end;
        if not  (State in [fpsDisabled,fpsDisabledSelected]) then
           ButtonEnabled := true;
      end
      else begin
        State:=fpsError;
        ButtonEnabled := false;
        Exit;
      end;

      if TwoSwitch then
      begin
        if Stopped then
        begin
          ButtonText := cStop;
        end
        else begin
          if Female then
          begin
             if TimeToSwitch=0 then
             begin
               if (not Device.Opened) and (not Device.Closed) then
                  ButtonText := movingnames[Device.LastCmd]
               else
                  ButtonText := femalenames[Device.Opened];
             end
             else begin
               if (not Device.Opened) and (not Device.Closed) then
                  ButtonText := movingnames[Device.LastCmd]
               else
                  ButtonText := femalenames[Device.Opened or MustInOpenState]
             end;
          end
          else begin
             if TimeToSwitch=0 then
             begin
               if (not Device.Opened) and (not Device.Closed) then
                  ButtonText := movingnames[Device.LastCmd]
               else
                  ButtonText := malenames[Device.Opened];
             end
             else begin
               if (not Device.Opened) and (not Device.Closed) then
                  ButtonText := movingnames[Device.LastCmd]
               else
                  ButtonText := malenames[Device.Opened or MustInOpenState];
             end;
          end;
        end;

      end
      else begin
        if Female then
        begin
           ButtonText := femalenames[Device.Opened]
        end
        else begin
           ButtonText := malenames[Device.Opened];
        end;
      end;

      if (Device.Opened) then
      begin
         LEDState[TLeds(0)]:=True;
         LEDState[TLeds(1)]:=False;
         //время открытия завершаем
         OpenTickCount:=GetTickCount()-1000;
      end
      else if (Device.Closed) then
      begin
         LEDState[TLeds(0)]:=False;
         LEDState[TLeds(1)]:=True;
         //время закрытия завершаем
         CloseTickCount:=GetTickCount()-1000;
      end
      else begin
        if TwoSwitch then
        begin
           if MustInOpenState then
           begin

              LEDState[TLeds(0)]:=True;
              LEDState[TLeds(1)]:=False;
              //если еще открывается - а время вышло - отрубаем линию управления
              if TwoSwitch and (TimeToSwitch>0) then
               if Device.Opening and (not Stopped) then
                   Device.ModuleManager.ExecuteInCOMThread(Stop);
           end
           else begin
              LEDState[TLeds(0)]:=False;
              LEDState[TLeds(1)]:=False;
           end;

           if MustInCloseState then
           begin
              LEDState[TLeds(0)]:=False;
              LEDState[TLeds(1)]:=True;
              //если еще закрывается - а время вышло - отрубаем линию управления
              if TwoSwitch and (TimeToSwitch>0) then
                if Device.Closing  and (not Stopped) then
                   Device.ModuleManager.ExecuteInCOMThread(Stop);
           end
           else begin
              LEDState[TLeds(0)]:=False;
              LEDState[TLeds(1)]:=False;
           end;

        end
        else begin
              LEDState[TLeds(0)]:=False;
              LEDState[TLeds(1)]:=False;
        end;
      end;
  except
  end;
end;

procedure TFmxPneumaticValve.SetAddress(AIdx: integer; const Value: integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxPneumaticValve.SetBaudrate(AIdx: integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;

procedure TFmxPneumaticValve.SetCloseINumber(const Value: word);
begin
  case ModuleType[0] of
    mtModbusD: begin
        if Value < 16  then FCloseINumber := Value;
    end;
    mtBIO: begin
        if Value <= 2 then FCloseINumber := Value;
    end;
    mtSuperBIO: begin
        if Value <= 12 then FCloseINumber := Value;
    end;
    mtHSC_CTRL: begin
        if Value <= (MaxChannels-1) then FCloseINumber := Value;
    end;
    mtValve:
    begin
      //временно сменили 6 на 1 - 21.12.22
      if Value <= 8 then
         FCloseINumber := Value;
    end;
  end;
  if Assigned(Device) then
     Device.CloseINumber:=FCloseINumber;
end;

procedure TFmxPneumaticValve.SetCloseONumber(const Value: word);
begin
  case ModuleType[0] of
    mtModbusD: begin
        if Value < 16 then FCloseONumber := Value;
    end;
    mtBIO: begin
        if Value <= 2 then FCloseONumber := Value;
    end;
    mtSuperBIO: begin
        if Value <= 12 then FCloseONumber := Value;
    end;
    mtHSC_CTRL: begin
        if Value <= (cHsc_MaxChannels-1) then FCloseONumber := Value;
    end;
    mtValve:
    begin
      //временно сменили 6 на 1 - 21.12.22
      if Value <= 8 then
         FCloseONumber := Value;
    end;
  end;
  if Assigned(Device) then Device.CloseONumber:=CloseONumber;
end;

procedure TFmxPneumaticValve.SetCloseTickCount(const Value: Cardinal);
begin
  if Assigned(Device) then
    Device.CloseTickCount := Value;
end;

procedure TFmxPneumaticValve.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxPneumaticValve.SetDevice(const Value: TFmxDevicePneumaticValve);
begin
  FDevice := Value;
end;

procedure TFmxPneumaticValve.SetFemale(const Value: boolean);
var state:boolean;
begin
  FFemale := Value;
  if Assigned(Device) then
     state:=Device.Opened or SwitchToOpened
  else
     state:=False;
  if Female then
     ButtonText := femalenames[state]
  else
     ButtonText := malenames[state];
end;

procedure TFmxPneumaticValve.SetLedsCount(const Value: byte);
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

procedure TFmxPneumaticValve.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  inherited;
  if Value in [mtBIO,mtSuperBIO,mtHSC_CTRL, mtValve,mtNone] then
  begin
    if Assigned(Device) then
      Device.ModuleType:=Value;
    case Value of
      mtModbusD: begin
                    //Управление
                    if not FOpenONumber in [0..15] then FOpenONumber := 0;
                    if not FCloseONumber in [0..15]  then FCloseONumber := 0;
                    //Состояние
                    if not FOpenINumber in [0..15]  then FOpenINumber := 0;
                    if not FCloseINumber in [0..15]  then FCloseINumber := 0;
             end;
      mtBIO: begin
                    //Управление
                    if FOpenONumber > 2 then FOpenONumber := 2;
                    if FCloseONumber > 2 then FCloseONumber := 2;
                    //Состояние
                    if FOpenINumber > 2 then FOpenINumber := 2;
                    if FCloseINumber > 2 then FCloseINumber := 2;
             end;
      mtSuperBIO: begin
                    //Управление
                    if FOpenONumber > 12 then FOpenONumber := 12;
                    if FCloseONumber > 12 then FCloseONumber := 12;
                    //Состояние
                    if FOpenINumber > 12 then FOpenINumber := 12;
                    if FCloseINumber > 12 then FCloseINumber := 12;
                  end;
      mtHSC_CTRL: begin
                    //Управление
                    if FOpenONumber > (cHsc_MaxChannels-1) then FOpenONumber := (cHsc_MaxChannels-1);
                    if FCloseONumber > (cHsc_MaxChannels-1) then FCloseONumber := (cHsc_MaxChannels-1);
                    //Состояние
                    if FOpenINumber > (cHsc_MaxChannels-1) then FOpenINumber := (cHsc_MaxChannels-1);
                    if FCloseINumber > (cHsc_MaxChannels-1) then FCloseINumber := (cHsc_MaxChannels-1);
                  end;
      mtValve:    begin
                    //Управление
                    if FOpenONumber < 6 then FOpenONumber := 6
                    else if FOpenONumber > 8 then FOpenONumber := 8;
                    if FCloseONumber < 6 then FCloseONumber := 6
                    else if FCloseONumber > 8 then FCloseONumber := 8;
                    //Состояние
                    if FOpenINumber < 6 then FOpenINumber := 6
                    else if FOpenINumber > 8 then FOpenINumber := 8;
                    if FCloseINumber < 6 then FCloseINumber := 6
                    else if FCloseINumber > 8 then FCloseINumber := 8;
                  end;
    end;
  end;
end;

procedure TFmxPneumaticValve.SetOpenINumber(const Value: word);
begin
  case ModuleType[0] of
    mtModbusD: begin
        if Value < 16  then FOpenINumber := Value;
    end;
    mtBIO: begin
        if Value <= 2 then FOpenINumber := Value;
    end;
    mtSuperBIO: begin
        if Value <= 12 then FOpenINumber := Value;
    end;
    mtHSC_CTRL: begin
        if Value <= (cHsc_MaxChannels-1) then FOpenINumber := Value;
    end;
    mtValve:
    begin
      //временно сменили 6 на 1 - 21.12.22
      if Value < 8 then
         FOpenINumber := Value;
    end;
    else
         FOpenINumber := Value;
  end;
  if Assigned(Device) then
     Device.OpenINumber:=FOpenINumber;
end;

procedure TFmxPneumaticValve.SetOpenONumber(const Value: word);
begin
  case ModuleType[0] of
    mtModbusD: begin
        if Value < 16  then FOpenONumber := Value;
    end;
    mtBIO: begin
        if Value <= 2 then FOpenONumber := Value;
    end;
    mtSuperBIO: begin
        if Value <= 12 then FOpenONumber := Value;
    end;
    mtValve:
    begin
      //временно сменили 6 на 1 - 21.12.22
      if Value <= 8 then
         FOpenONumber := Value;
    end;
    else
         FOpenONumber := Value;
  end;
  if Assigned(Device) then Device.OpenONumber:=FOpenONumber;
end;

procedure TFmxPneumaticValve.SetOpenTickCount(const Value: Cardinal);
begin
  if Assigned(Device) then
    Device.OpenTickCount := Value;
end;

procedure TFmxPneumaticValve.SetParamValue(Row: integer; const Value: String);
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
      AFIdx := StrToIntDef(Value, 1);
      //Входы
    13:
      OpenINumber := StrToIntDef(Value, OpenINumber+1)-1;
    14:
      CloseINumber := StrToIntDef(Value, CloseINumber+1)-1;
     //выходы
    15:
      OpenONumber := StrToIntDef(Value, OpenONumber+1)-1;
    16:
      CloseONumber := StrToIntDef(Value, CloseONumber+1)-1;
    17:
      TimeToSwitch := StrToIntDef(Value, TimeToSwitch);
    18:
      WithInput := myStrToBool(Value);
    19:
      TwoSwitch := myStrToBool(Value);
    20:
      Female := myStrToBool(Value);
    21:
      DefaultState :=
        Ord(myStrToBool(Value));
    22:
      Visible := myStrToBool(Value);
    23:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    24:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    25:
      InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    26:
      OutputRegister[0] := StrToIntDef(Value, OutputRegister[0]);
    27:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    28:
      MaxChannels:=StrToIntDef(Value, MaxChannels);
end;
end;

procedure TFmxPneumaticValve.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxPneumaticValve.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

function TFmxPneumaticValve.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxPneumaticValve.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(Device) then
     Device.MaxChannels:=Value;
end;

procedure TFmxPneumaticValve.SetTwoSwitch(const Value: boolean);
begin
  FTwoSwitch := Value;
  if Assigned(Device) then
     Device.TwoSwitch:=Value;
  UpdateStyle();
end;

procedure TFmxPneumaticValve.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;

procedure TFmxPneumaticValve.SetWithInput(const Value: boolean);
begin
  FWithInput := Value;
  if Assigned(Device) then
     Device.WithInput:=Value;
end;


procedure TFmxPneumaticValve.ButtonClick(Sender: TObject);
begin
  ButtonEnabled:=False;
  if Assigned(Device) then
  begin
       if (aftAskingBeforExec in AFTypeSet) then
       begin
          if DialogYesNo('Вы действительно хотите переключить '+Caption+'?') then
          begin
            Device.AddToWorkLogProc('Пользователь в ручном режиме переключил '+Caption);
            Device.ModuleManager.ExecuteInCOMThread(Switch);
          end;
       end
       else
          Device.ModuleManager.ExecuteInCOMThread(Switch);
  end;
end;


procedure TFmxPneumaticValve.Stop;
begin
  if Assigned(Device) then
  begin
     Device.Stop;//Останов
     Device.UpdateStatus;
  end;
end;

procedure TFmxPneumaticValve.Switch;
begin
  if Assigned(Device) then
  begin
    if SwitchToOpened then
                        Device.Open//открываем
                      else
                        Device.Close;//Закрываем
    Device.UpdateStatus;
  end;
end;

procedure TFmxPneumaticValve.UpdateStyle;
begin
  inherited;
  if TwoSwitch then
  begin
     LedsCount:=2;
     LEDState[TLeds(0)]:=Opened;
     LEDState[TLeds(1)]:=not Opened;
  end
  else begin
     LedsCount:=1;
     LEDState[TLeds(0)]:=Opened;
  end;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxPneumaticValve]);
end;


end.
