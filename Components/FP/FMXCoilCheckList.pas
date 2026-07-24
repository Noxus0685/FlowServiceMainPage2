unit FMXCoilCheckList;

{
  Описание:
  TFMXCoilCheckList предназначен для отображения битовых состояний контроллеров,
  работающих по протоколу Modbus - имеет возможность как считывать, так и записывать
  состояние катушек (Coils).

  Визуально поддерживает два режима:
  - OtherView = False: горизонтальные чекбоксы (TFlowLayout + TCheckBox) - без подписей
  - OtherView = True:  вертикальный список с чекбоксами (TMyCheckListBox)

  Связь с Modbus реализуется в приложении через переопределение виртуальных методов
  ReadFromDevice и WriteToDevice, либо через прямую установку свойства Value.
}

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.Types,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, FMX.Dialogs,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  FMX.Memo,
  FmxFPColors,
  FPCustomControl, FMXDeviceCustomControl,
  FmxFPDevices, uProcedureOfObject, FmxParamsFrm,
  FmxModbusConsts, FmxModbusTypes, FmxHelper,
  uMyCheckListBox,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cCoilCheckListStyle='CoilCheckListStyle';
  cCoilCheckListPropertyCount = 20;

  cCoilCheckListPropertys: array[0..cCoilCheckListPropertyCount-1] of string = (
    cHeader, cHint,
    cPort, cAddress, cBaudrate, cParity, cModuleType,
    cLeft, cTop, cWidth, cHeight,
    cOtherView,
    cSize,
    cVisible, cTypeOfProtocol,
    cModbusInputReg, cModbusOutputReg, cModulePriority,
    cCoilNames,
    cReadOnly
  );

  cCoilCheckListPropertysType: array[0..cCoilCheckListPropertyCount-1] of TParameterType = (
    ptText, ptText,
    ptNumber, ptNumber, ptNumber, ptComboBox, ptComboBox,
    ptFloat, ptFloat, ptFloat, ptFloat,
    ptComboBox,
    ptNumber,
    ptComboBox, ptComboBox,
    ptNumber, ptNumber, ptNumber,
    ptMemo,
    ptComboBox
  );

  cCoilCheckListPropertyComboItems: array[0..cCoilCheckListPropertyCount-1] of TArray<string> = (
    [], [],
    [], [], [], [cNone, cOdd, cEven, cMark, cSpace], [cmtHSC_CTRL, cmtSuperBIO, cmtValve, cmtBIO, cmtRT2, cmtModbusD],
    [], [], [], [],
    [cStandart, cOtherView],
    [],
    [cNo, cYes], [ctpProprietary, ctpModbusRTU, ctpModbusASCII, ctpModbusTCP],
    [], [], [],
    [],
    [cNo, cYes]
  );

type
  TCoilChangeEvent = procedure(Sender: TObject; Index: Integer; State: Boolean) of object;

  TFMXCoilCheckList = class(TFMXDeviceCustomControl)
  private
    FFlowLayout: TFlowLayout;
    FCheckListBox: TMyCheckListBox;
    FCheckBoxes: TArray<TCheckBox>;
    FSize: Byte;
    FValue: LongWord;
    FOnCoilChange: TCoilChangeEvent;
    FCoilNames: TStringList;
    FUpdatingFromNames: Boolean;
    FMyEditFrame:TRectangle;
    FMainBody:TRectangle;
    FControlPanel:TLayout;
    FHeader:TLayout;
    FCaption_background:TRectangle;
    FCaption:Ttext;
    FReadOnly: boolean;


    procedure SetSize(const Value: Byte);
    procedure SetValue(const Value: LongWord);
    procedure SetCoilNames(const Value: TStringList);
    function GetCoilNamesText: string;
    procedure SetCoilNamesText(const Value: string);

    procedure RebuildBitMask;
    procedure UpdateControlsFromValue;
    procedure UpdateValueFromControls;
    function CheckBoxIndex(Sender: TObject): Integer;
    procedure UpdateCoilNamesList;
    procedure FillCheckListBoxFromNames;
    procedure OnCoilNamesChanged(Sender: TObject);
    procedure ApplyOtherView;

    procedure OnCheckBoxChange(Sender: TObject);
    procedure OnCheckListBoxChange(Sender: TObject);
    procedure SetReadOnly(const Value: boolean);

  protected
    Device: TFmxDeviceCoilCheckList;

    procedure UpdateStyle; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure ReceiveResponse; override;

    procedure ReadFromDevice; virtual;
    procedure WriteToDevice; virtual;

    procedure FillParametersList; override;
    function GetParamValue(Row: integer): String; override;
    procedure SetParamValue(Row: integer; const Value: String); override;
    function GetRebootWarning(Row: integer): Boolean; override;
    procedure SetEditing(const Value: Boolean);override;
    procedure SetState(const Value: TFPControlState);override;
    procedure SetCaption(const Value: String);override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property CoilNames: TStringList read FCoilNames write SetCoilNames;
    property CoilNamesText: string read GetCoilNamesText write SetCoilNamesText;
    property ReadOnly:boolean read FReadOnly write SetReadOnly;

  published
    property Size: Byte read FSize write SetSize default 8;
    property Value: LongWord read FValue write SetValue;
    property OnCoilChange: TCoilChangeEvent read FOnCoilChange write FOnCoilChange;

    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property Hint;
    property ShowHint;
    property OnChange;

    property Active;
    property ModbusTCPHost;
    property ModbusTCPPort;
    property Parity;
  end;

procedure Register;

implementation

uses System.StrUtils;

procedure Register;
begin
  RegisterComponents('FmxFP', [TFMXCoilCheckList]);
end;

{ TFMXCoilCheckList }

constructor TFMXCoilCheckList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSize := 8;
  FValue := 0;
  FUpdatingFromNames := False;

  FCoilNames := TStringList.Create;
  FCoilNames.OnChange := OnCoilNamesChanged;
  UpdateCoilNamesList;

  FMyEditFrame := TRectangle.Create(Self);
  FMyEditFrame.Parent := Self;
  FMyEditFrame.Align := TAlignLayout.Client;
  FMyEditFrame.Stroke.Kind := TBrushKind.Solid;
  FMyEditFrame.Stroke.Thickness := 2;
  FMyEditFrame.Stroke.Color := TAlphaColorRec.Green; // цвет рамки
  FMyEditFrame.Fill.Kind := TBrushKind.None;
  FMyEditFrame.Visible := True;
  FMyEditFrame.Padding.Rect := RectF(3, 3, 3, 3);
  FMyEditFrame.SendToBack; // чтобы не перекрывал содержимое
  FMyEditFrame.HitTest := False;

  //mainbody
  FMainBody := TRectangle.Create(Self);
  FMainBody.Parent := FMyEditFrame;
  FMainBody.Align := TAlignLayout.Client;
  FMainBody.Padding.Rect := RectF(3, 3, 3, 3);
  FMainBody.HitTest := false;

  //Header
  FHeader := TLayout.Create(Self);
  FHeader.Parent := FMainBody;
  FHeader.Align := TAlignLayout.MostTop;
  FHeader.Height:=21;
  FHeader.HitTest := True;
  FHeader.OnClick:=DoOnClick;
  FHeader.OnMouseEnter:=DoOnMouseEnter;
  FHeader.OnMouseLeave:=DoOnMouseLeave;
  FHeader.OnMouseMove:=DoOnMouseMove;
  FHeader.OnMouseDown:=DoOnMouseDown;
  FHeader.OnMouseUp:=DoOnMouseUp;


  //caption_background
  FCaption_background := TRectangle.Create(Self);
  FCaption_background.Parent:=FHeader;
  FCaption_background.Align := TAlignLayout.Client;
  FCaption_background.Fill.Color:= TAlphaColorRec.Gray;
  FCaption_background.HitTest := False;

  //caption
  FCaption := TText.Create(Self);
  FCaption.Parent:=FHeader;
  FCaption.Align := TAlignLayout.Client;
  FCaption.BringToFront;
  FCaption.TextSettings.FontColor:= TAlphaColorRec.Ghostwhite;
  FCaption.HorzTextAlign:=TTextAlign.Center;
  FCaption.VertTextAlign:=TTextAlign.Center;
  FCaption.HitTest := False;

  //ContrlPanel
  FControlPanel := TLayout.Create(Self);
  FControlPanel.Parent := FMainBody;
  FControlPanel.Align := TAlignLayout.Client;
  FControlPanel.HitTest := True;

  FFlowLayout := TFlowLayout.Create(Self);
  FFlowLayout.Parent := FControlPanel;
  FFlowLayout.Align := TAlignLayout.Client;
  FFlowLayout.HitTest := True;
  FFlowLayout.Margins.Rect := RectF(2, 2, 2, 2);

  FCheckListBox := TMyCheckListBox.Create(Self);
  FCheckListBox.Parent := FControlPanel;
  FCheckListBox.Align := TAlignLayout.Client;
  FCheckListBox.ShowCheckboxes := True;
  FCheckListBox.BoldCheckedItems := True;
  FCheckListBox.ActiveColor := TAlphaColorRec.Green;
  FCheckListBox.OnChange := OnCheckListBoxChange;

  ApplyOtherView;
  RebuildBitMask;

  Editing:=False;
end;

destructor TFMXCoilCheckList.Destroy;
begin
  FCoilNames.Free;
  FCaption.Free;
  FCaption_background.Free;
  FControlPanel.Free;
  FHeader.Free;
  FMainBody.Free;
  FMyEditFrame.Free;
  inherited;
end;

procedure TFMXCoilCheckList.Loaded;
begin
  inherited;
  UpdateControlsFromValue;
  FillCheckListBoxFromNames;
  ApplyOtherView;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then begin
    Device := TFmxDeviceCoilCheckList.CreateOnModule(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], InputRegister[0],OutputRegister[0], Size,ModuleType[0], TypeOfProtocol[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFMXCoilCheckList.Resize;
begin
  inherited;
end;

procedure TFMXCoilCheckList.ApplyOtherView;
begin
  FFlowLayout.Visible := not OtherView;
  FCheckListBox.Visible := OtherView;

  if not OtherView then
    RebuildBitMask
  else
  begin
    if FCheckListBox.Count <> FSize then
    begin
      while FCheckListBox.Count < FSize do
        FCheckListBox.Items.Add('');
      while FCheckListBox.Count > FSize do
        FCheckListBox.Items.Delete(FCheckListBox.Count - 1);
      FillCheckListBoxFromNames;
      UpdateControlsFromValue;
    end;
  end;
end;

procedure TFMXCoilCheckList.UpdateStyle;
begin
  inherited;
  ApplyOtherView;
end;

procedure TFMXCoilCheckList.RebuildBitMask;
var
  i: Integer;
  cb: TCheckBox;
begin
  for i := 0 to High(FCheckBoxes) do
    FCheckBoxes[i].Free;
  SetLength(FCheckBoxes, 0);

  while FFlowLayout.ChildrenCount > 0 do
    FFlowLayout.Children[0].Free;

  SetLength(FCheckBoxes, FSize);
  for i := 0 to FSize - 1 do
  begin
    cb := TCheckBox.Create(FFlowLayout);
    cb.Parent := FFlowLayout;
    cb.Text := '';
    if i < FCoilNames.Count then
      cb.Hint := FCoilNames[i]
    else
      cb.Hint := Format('Bit %d', [i]);
    cb.ShowHint := True;
    cb.Width := 20;
    cb.Height := 20;
    cb.Tag := i;
    cb.OnChange := OnCheckBoxChange;
    FCheckBoxes[i] := cb;
  end;
  UpdateControlsFromValue;
end;

procedure TFMXCoilCheckList.ReceiveResponse;
begin
  inherited;
 try
    if Device.ConnectIsOK then
    begin
       if Device.Disguise then
       begin
         State:=fpsDisguise;
         Exit;
       end;
       Value:=Device.Value;
       State := fpsEnabled;
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

procedure TFMXCoilCheckList.UpdateControlsFromValue;
var
  i: Integer;
begin
  if not OtherView then
  begin
    for i := 0 to FSize - 1 do
      if i <= High(FCheckBoxes) then
        FCheckBoxes[i].IsChecked := (FValue and (1 shl i)) <> 0;
  end
  else
  begin
    if FCheckListBox.Count = FSize then
      FCheckListBox.Value := FValue;
  end;
end;

procedure TFMXCoilCheckList.UpdateValueFromControls;
var
  i: Integer;
  NewValue: LongWord;
begin
  NewValue := 0;
  if not OtherView then
  begin
    for i := 0 to FSize - 1 do
      if (i <= High(FCheckBoxes)) and FCheckBoxes[i].IsChecked then
        NewValue := NewValue or (1 shl i);
  end
  else
  begin
    NewValue := FCheckListBox.Value;
  end;
  NewValue := NewValue and ((1 shl FSize) - 1);
  if FValue <> NewValue then
    FValue := NewValue;
end;

//procedure TFMXCoilCheckList.ApplyStyle;
//var
//  Bg: TFmxObject;
//begin
//  inherited;
//  // Находим background в стиле
//  Bg := FindStyleResource('background');
//  if (Bg <> nil) and (Bg is TControl) then
//  begin
//    if FFlowLayout <> nil then
//      FFlowLayout.Parent := TControl(Bg);
//    if FCheckListBox <> nil then
//      FCheckListBox.Parent := TControl(Bg);
//  end;
//end;

function TFMXCoilCheckList.CheckBoxIndex(Sender: TObject): Integer;
begin
  if Sender is TCheckBox then
    Result := TCheckBox(Sender).Tag
  else
    Result := -1;
end;

procedure TFMXCoilCheckList.UpdateCoilNamesList;
begin
  if FUpdatingFromNames then Exit;
  FUpdatingFromNames := True;
  try
    while FCoilNames.Count < FSize do
      FCoilNames.Add(Format('Bit %d', [FCoilNames.Count]));
    while FCoilNames.Count > FSize do
      FCoilNames.Delete(FCoilNames.Count - 1);
  finally
    FUpdatingFromNames := False;
  end;
end;

procedure TFMXCoilCheckList.FillCheckListBoxFromNames;
var
  i: Integer;
begin
  if FCheckListBox = nil then Exit;

  // Синхронизируем количество элементов списка с текущим размером
  while FCheckListBox.Count < FSize do
    FCheckListBox.Items.Add('');
  while FCheckListBox.Count > FSize do
    FCheckListBox.Items.Delete(FCheckListBox.Count - 1);

  // Заполняем именами или значениями по умолчанию
  for i := 0 to FSize - 1 do
    if i < FCoilNames.Count then
      FCheckListBox.Items[i] := FCoilNames[i]
    else
      FCheckListBox.Items[i] := Format('Bit %d', [i]);
end;

procedure TFMXCoilCheckList.OnCoilNamesChanged(Sender: TObject);
begin
  if FUpdatingFromNames then Exit;
  SetSize(FCoilNames.Count);
  if OtherView then
    FillCheckListBoxFromNames
  else
  begin
    for var i := 0 to FSize - 1 do
      if i <= High(FCheckBoxes) then
      begin
        if i < FCoilNames.Count then
          FCheckBoxes[i].Hint := FCoilNames[i]
        else
          FCheckBoxes[i].Hint := Format('Bit %d', [i]);
      end;
  end;
end;

procedure TFMXCoilCheckList.SetCaption(const Value: String);
begin
   inherited;
   FCaption.Text:=Value;
end;

procedure TFMXCoilCheckList.SetCoilNames(const Value: TStringList);
begin
  if FUpdatingFromNames then Exit;
  FUpdatingFromNames := True;
  try
    FCoilNames.Assign(Value);
    var NewSize := FCoilNames.Count;
    if NewSize < 1 then NewSize := 1;
    if NewSize > 32 then NewSize := 32;
    if FSize <> NewSize then
    begin
      FCoilNames.OnChange := nil;
      try
        FSize := NewSize;
        while FCoilNames.Count < FSize do
          FCoilNames.Add(Format('Bit %d', [FCoilNames.Count]));
        while FCoilNames.Count > FSize do
          FCoilNames.Delete(FCoilNames.Count - 1);
        FValue := FValue and ((1 shl FSize) - 1);
      finally
        FCoilNames.OnChange := OnCoilNamesChanged;
      end;
    end;
  finally
    FUpdatingFromNames := False;
  end;
  ApplyOtherView;
  UpdateControlsFromValue;
  if Assigned(OnChange) then OnChange(Self);
end;

function TFMXCoilCheckList.GetCoilNamesText: string;
begin
  Result := FCoilNames.Text;
end;

procedure TFMXCoilCheckList.SetCoilNamesText(const Value: string);
begin
  FCoilNames.Text := Value;
end;

procedure TFMXCoilCheckList.OnCheckBoxChange(Sender: TObject);
var
  Index: Integer;
  OldValue: LongWord;
begin
  Index := CheckBoxIndex(Sender);
  if Index < 0 then Exit;

  OldValue := FValue;
  UpdateValueFromControls;

  if FValue <> OldValue then
  begin
    if Assigned(FOnCoilChange) then
      FOnCoilChange(Self, Index, (FValue shr Index) and 1 = 1);
    if Assigned(OnChange) then
      OnChange(Self);
    WriteToDevice;
  end;
end;

procedure TFMXCoilCheckList.OnCheckListBoxChange(Sender: TObject);
var
  NewValue: LongWord;
  i: Integer;
  ChangedBit: Integer;
begin
  NewValue := FCheckListBox.Value and ((1 shl FSize) - 1);
  if FValue = NewValue then Exit;

  ChangedBit := -1;
  for i := 0 to FSize - 1 do
    if ((FValue shr i) and 1) <> ((NewValue shr i) and 1) then
    begin
      ChangedBit := i;
      Break;
    end;

  FValue := NewValue;

  if Assigned(FOnCoilChange) and (ChangedBit >= 0) then
    FOnCoilChange(Self, ChangedBit, (FValue shr ChangedBit) and 1 = 1);
  if Assigned(OnChange) then
    OnChange(Self);

  WriteToDevice;
end;

procedure TFMXCoilCheckList.ReadFromDevice;
begin
  // Переопределить в потомке
end;

procedure TFMXCoilCheckList.WriteToDevice;
begin
  // Переопределить в потомке
end;

procedure TFMXCoilCheckList.SetSize(const Value: Byte);
var
  NewSize: Byte;
begin
  NewSize := Value;
  if NewSize < 1 then NewSize := 1;
  if NewSize > 32 then NewSize := 32;
  if FSize = NewSize then Exit;
  FSize := NewSize;
  UpdateCoilNamesList;
  if not OtherView then
    RebuildBitMask
  else
  begin
    while FCheckListBox.Count < FSize do
      FCheckListBox.Items.Add('');
    while FCheckListBox.Count > FSize do
      FCheckListBox.Items.Delete(FCheckListBox.Count - 1);
    FillCheckListBoxFromNames;
  end;
  SetValue(FValue and ((1 shl FSize) - 1));
end;

procedure TFMXCoilCheckList.SetState(const Value: TFPControlState);
begin
  inherited;
  case Value  of
    fpsEnabled: FCaption_background.fill.color:=ColorToAlphaColor($A06030);
    fpsDisguise: Fcaption_background.fill.color:=TAlphaColors.Cadetblue;
    fpsEnabledSelected: Fcaption_background.fill.color:=TAlphaColors.Navy;
    fpsDisabled: FCaption_background.fill.color:=TAlphaColors.DarkGray;
    fpsDisabledSelected: FCaption_background.fill.color:=TAlphaColors.Gray;
    fpsError: FCaption_background.fill.color:=TAlphaColors.Red;
    fpsEditing: FCaption_background.fill.color:=TAlphaColors.Green;
  end;
end;

procedure TFMXCoilCheckList.SetValue(const Value: LongWord);
begin
  if FValue = Value then Exit;
  FValue := Value and ((1 shl FSize) - 1);
  UpdateControlsFromValue;
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TFMXCoilCheckList.FillParametersList;
var
  i: Integer;
begin
  inherited;
  SetLength(FParameters, cCoilCheckListPropertyCount);
  for i := 0 to cCoilCheckListPropertyCount - 1 do
  begin
    FParameters[i].Name := cCoilCheckListPropertys[i];
    FParameters[i].ParamType := cCoilCheckListPropertysType[i];
    FParameters[i].Items := cCoilCheckListPropertyComboItems[i];
  end;
end;

function TFMXCoilCheckList.GetParamValue(Row: integer): String;
begin
  case Row of
    0: Result := Caption;
    1: Result := Hint;
    2: Result := IntToStr(Port[0]);
    3: Result := IntToStr(Address[0]);
    4: Result := IntToStr(BaudRate[0]);
    5: Result := cComParityName[Parity];
    6: Result := cModuleTypeNames[ModuleType[0]];
    7: Result := FloatToStr(Left + ShiftL);
    8: Result := FloatToStr(Top + ShiftT);
    9: Result := FloatToStr(Width);
    10: Result := FloatToStr(Height);
    11: Result := cOtherViewName[OtherView];
    12: Result := IntToStr(Size);
    13: Result := cBooleanName[Visible];
    14: Result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    15: Result := IntToStr(InputRegister[0]);
    16: Result := IntToStr(OutputRegister[0]);
    17: Result := IntToStr(ModulePriority);
    18: Result := GetCoilNamesText;
    19: Result := BoolToStr(ReadOnly,cYes,cNo);
  else
    Result := '';
  end;
end;

procedure TFMXCoilCheckList.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0: Caption := Value;
    1: Hint := Value;
    2: Port[0] := StrToIntDef(Value, Port[0]);
    3: Address[0] := StrToIntDef(Value, Address[0]);
    4: BaudRate[0] := StrToIntDef(Value, 9600);
    5: Parity := StrToParity(Value);
    6: ModuleType[0] := StrToModuleType(Value);
    7: Left := StrToFloatDef(CP(Value), Left) - ShiftL;
    8: Top := StrToFloatDef(CP(Value), Top) - ShiftT;
    9: Width := StrToFloatDef(CP(Value), Width);
    10: Height := StrToFloatDef(CP(Value), Height);
    11: OtherView := myStrToOtherView(Value);
    12: Size := StrToIntDef(Value, Size);
    13: Visible := myStrToBool(Value);
    14: TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    15: InputRegister[0] := StrToIntDef(Value, InputRegister[0]);
    16: OutputRegister[0] := StrToIntDef(Value, OutputRegister[0]);
    17: ModulePriority := StrToIntDef(Value, ModulePriority);
    18: SetCoilNamesText(Value);
    19: ReadOnly:=myStrToBool(Value);
  end;
end;

procedure TFMXCoilCheckList.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;
  FFlowLayout.Enabled:=not Value;
  FCheckListBox.Enabled:=not Value;
end;

function TFMXCoilCheckList.GetRebootWarning(Row: integer): Boolean;
begin
  Result := Row in [2, 3, 4, 5, 6, 14, 15, 16, 17];
end;

procedure TFMXCoilCheckList.SetEditing(const Value: Boolean);
begin
  inherited SetEditing(Value);
  if not Assigned(FMyEditFrame) then Exit;
  if Value  then
  begin
    if Dragging then
    begin
      FMyEditFrame.stroke.Dash:=TStrokeDash.Dot;
      FMyEditFrame.stroke.Color:=CL_FMX_BLUE;
    end
    else begin
      FMyEditFrame.stroke.Dash:=TStrokeDash.Solid;
      FMyEditFrame.stroke.Color:=CL_FMX_GREEN;
    end;
  end
  else begin
      FMyEditFrame.stroke.Dash:=TStrokeDash.Solid;
      FMyEditFrame.stroke.Color:=CL_FMX_NULL;
  end;
end;

end.
