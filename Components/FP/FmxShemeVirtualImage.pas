unit FmxShemeVirtualImage;


{ ===== Компонент FmxShemeVirtualImage =====
Визуальный компонент отображения элементов схемы
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  uProcedureOfObject,
  FPCustomControl,
  FMXDeviceCustomControl,
  FmxFPModule,
  FmxFPDevices,
  FmxFPModuleManager,
  FmxFPDeviceManager,
  uFmxStrConsts;

type
  TFmxShemeImageTypes=(fitElbow=0,//Угол   1
               fitPipe_H,fitPipe_V,//Трубы  2,3
               fitTee,//тройник            4
               fitCross,//Крестовина       5
               fitScaleTank,//Весовой бак       6
               fitMainTank,//Резервуар обменный   7
               fitTank_H,fitTank_V,//Рессивер  8,9
               fitFlange,//Фланцы
               fitValve,//Клапан управления горизонтальный (11)
               fitValve_C,fitValve_O,//Клапан закрытый и открытый - ручные - горизонтальные
               fitPump_1,//Насос вертикальный   (14)
               fitPump_2,//Насос вертикальный
               fitPump_3,//Насос вертикальный
               fitPump_4,//Насос вертикальный
               fitText,//Простой текст
               fitGroupBox,//Групповая панель
               fitUser_1,//пользовательский 1 - (18)
               fitUser_2,//пользовательский 2 - (19)
               fitUser_3,//пользовательский 3 - (20)
               fitUser_4,//пользовательский 4 - (21)
               fitUser_5,//пользовательский 5 - (22)
               fitUser_6,//пользовательский 6 - (23)
               fitUser_7,//пользовательский 7 - (24)
               fitUser_8,//пользовательский 8 - (25)
               fitUser_9,//пользовательский 9 - (26)
               fitUser_10,//пользовательский 10- (27)
               fitUser_11,//пользовательский 11 - (28)
               fitUser_12,//пользовательский 12 - (29)
               fitUser_13,//пользовательский 13 - (30)
               fitUser_14,//пользовательский 14 - (31)
               fitUser_15,//пользовательский 15 - (32)
               fitUser_16,//пользовательский 16 - (33)
               fitUser_17,//пользовательский 17 - (34)
               fitUser_18,//пользовательский 18 - (35)
               fitUser_19,//пользовательский 19 - (36)
               fitUser_20,//пользовательский 20- (37)
               fitUser_21,//пользовательский 21 - (38)
               fitUser_22,//пользовательский 22 - (39)
               fitUser_23,//пользовательский 23 - (40)
               fitUser_24,//пользовательский 24 - (41)
               fitUser_25,//пользовательский 25 - (42)
               fitUser_26,//пользовательский 26 - (43)
               fitUser_27,//пользовательский 27 - (44)
               fitUser_28,//пользовательский 28 - (45)
               fitUser_29,//пользовательский 29 - (46)
               fitUser_30//пользовательский 30- (47)
               );
const
      сSheme_Name=0;
      cShemeHeader=1;
      cShemeLeft=2;
      cShemeTop=3;
      cShemeWidth=4;
      cShemeHeight=5;
      cShemeNumAppFunction=6;
      cShemeTypeOfApp=7;
      cShemeBaseType=8;
      cShemeExtraType=9;
      cShemeState=10;
      cShemeAngle=11;
      cShemeZPosition=12;
      cShemeVisible=13;
      cShemeColor=14;
      cShemeOpacity=15;

      //Количество свойств
      сShemePropertyCount=16;

      //Наименования свойств
      cShemePropertys:array[0..сShemePropertyCount-1]of string=(
      cHeader,cHint,
      cLeft,cTop,cWidth,cHeight,cNumAppFunction,cTypeAppFunc,
      cShapeBaseKind,cShapeExtraKind,cState,cAngle,cZPosition,cVisible,cColor,cOpacity);

      //типы свойств
      cShemePropertysType:array[0..сShemePropertyCount-1]of TParameterType=(
      ptText,ptText,
      ptFloat,ptFloat,ptFloat,ptFloat,ptNumber,ptComboBox,
      ptComboBox,ptComboBox,ptComboBox,ptFloat,ptNumber,ptComboBox,ptComboBox,ptFloat);

      //Комбо выпадающие списки
      cShemePropertyComboItems: array[0..сShemePropertyCount-1] of TArray<string> = (
          [], // cHeader - ptText, не нужны Items
          [], // cHint - ptText
          [], // cLeft - ptNumber
          [], // cTop - ptNumber
          [], // cWidth - ptNumber
          [], // cHeight - ptNumber
          [], // cNumAppFunction - ptNumber
          [cNumber,cMask], // cTypeAppFunc - ptNumber
          [
           cElbow,cPipe_H,cPipe_V,cTee,cCross,cScaleTank,cMainTank,
           cTank_H,cTank_V,cFlange,cValve,cValve_C,cValve_O,cPump_1,cPump_2,cPump_3,
           cPump_4,cText,cGroupBox,cUser_1,cUser_2,cUser_3,cUser_4,cUser_5,
           cUser_6,cUser_7,cUser_8,cUser_9,cUser_10,cUser_11,cUser_12,cUser_13,cUser_14,cUser_15,
           cUser_16,cUser_17,cUser_18,cUser_19,cUser_20,cUser_21,cUser_22,cUser_23,cUser_24,cUser_25,
           cUser_26,cUser_27,cUser_28,cUser_29,cUser_30
          ],
          [
           cElbow,cPipe_H,cPipe_V,cTee,cCross,cScaleTank,cMainTank,
           cTank_H,cTank_V,cFlange,cValve,cValve_C,cValve_O,cPump_1,cPump_2,cPump_3,
           cPump_4,cText,cGroupBox,cUser_1,cUser_2,cUser_3,cUser_4,cUser_5,
           cUser_6,cUser_7,cUser_8,cUser_9,cUser_10,cUser_11,cUser_12,cUser_13,cUser_14,cUser_15,
           cUser_16,cUser_17,cUser_18,cUser_19,cUser_20,cUser_21,cUser_22,cUser_23,cUser_24,cUser_25,
           cUser_26,cUser_27,cUser_28,cUser_29,cUser_30
          ],
          [cNo,cYes],// cState - состояние (открыт/закрыт, да/нет ...)
          [], // cAngle - ptFloat
          [],//Z
          [cNo,cYes],
          [cShapeColorGray,cShapeColorBlue,cShapeColorGreen,cShapeColorRed,cShapeColorYellow],
          []
        );

      ShemeImageTypesNames:array[TFmxShemeImageTypes] of String=(
       cElbow,//Угол   1
       cPipe_H,cPipe_V,//Трубы  2,3
       cTee,//тройник            4
       cCross,//Крестовина       5
       cScaleTank,//Весовой бак       6
       cMainTank,//Резервуар обменный   7
       cTank_H,cTank_V,//Рессивер  8,9
       cFlange,//Фланцы
       cValve,//Клапан управления горизонтальный (11)
       cValve_C,cValve_O,//Клапан закрытый и открытый - ручные - горизонтальные
       cPump_1,//Насос вертикальный   (14)
       cPump_2,//Насос вертикальный
       cPump_3,//Насос вертикальный
       cPump_4,//Насос вертикальный
       cText,//Простой текст
       cGroupBox,//Групповая панель
       cUser_1,//пользовательский 1 - (18)
       cUser_2,//пользовательский 2 - (19)
       cUser_3,//пользовательский 3 - (20)
       cUser_4,//пользовательский 4 - (21)
       cUser_5,//пользовательский 5 - (22)
       cUser_6,//пользовательский 6 - (23)
       cUser_7,//пользовательский 7 - (24)
       cUser_8,//пользовательский 8 - (25)
       cUser_9,//пользовательский 9 - (26)
       cUser_10,//пользовательский 10- (27)
       cUser_11,//пользовательский 1 - (18)
       cUser_12,//пользовательский 2 - (19)
       cUser_13,//пользовательский 3 - (20)
       cUser_14,//пользовательский 4 - (21)
       cUser_15,//пользовательский 5 - (22)
       cUser_16,//пользовательский 6 - (23)
       cUser_17,//пользовательский 7 - (24)
       cUser_18,//пользовательский 8 - (25)
       cUser_19,//пользовательский 9 - (26)
       cUser_20,//пользовательский 10- (27)
       cUser_21,//пользовательский 1 - (18)
       cUser_22,//пользовательский 2 - (19)
       cUser_23,//пользовательский 3 - (20)
       cUser_24,//пользовательский 4 - (21)
       cUser_25,//пользовательский 5 - (22)
       cUser_26,//пользовательский 6 - (23)
       cUser_27,//пользовательский 7 - (24)
       cUser_28,//пользовательский 8 - (25)
       cUser_29,//пользовательский 9 - (26)
       cUser_30//пользовательский 10- (27)
      );
      ShemeImageTypesAppNames:array[TFMXShemeImageTypes] of String=(
      'elbow',//Колено
      'pipe_h','pipe_v',//горизонтальная и верстикальная трубы
      'tee',//тройник
      'cross',//крестовина
      'scales_tank',//весовой бак
      'main_tank',//обменный бак
      'tank_h', //горизонтальный рессивер
      'tank_v', //верстикальный рессивер
      'flange',//фланец
      'valve_auto',//завдижка с автоматическим управлением
      'valve_manual_close',//ручной кран закрытый
      'valve_manual_open',//ручной кран открытый
      'pump_1',//Насос вертикальный
      'pump_2',//Насос вертикальный
      'pump_3',//Насос вертикальный
      'pump_4',//Насос вертикальный
      'text',//Текст
      'frame',//Группа
      'user_image_1',//пользовательский
      'user_image_2',//пользовательский
      'user_image_3',//пользовательский
      'user_image_4',//пользовательский
      'user_image_5',//пользовательский
      'user_image_6',//пользовательский
      'user_image_7',//пользовательский
      'user_image_8',//пользовательский
      'user_image_9',//пользовательский
      'user_image_10',//пользовательский
      'user_image_11',//пользовательский
      'user_image_12',//пользовательский
      'user_image_13',//пользовательский
      'user_image_14',//пользовательский
      'user_image_15',//пользовательский
      'user_image_16',//пользовательский
      'user_image_17',//пользовательский
      'user_image_18',//пользовательский
      'user_image_19',//пользовательский
      'user_image_20',//пользовательский
      'user_image_21',//пользовательский
      'user_image_22',//пользовательский
      'user_image_23',//пользовательский
      'user_image_24',//пользовательский
      'user_image_25',//пользовательский
      'user_image_26',//пользовательский
      'user_image_27',//пользовательский
      'user_image_28',//пользовательский
      'user_image_29',//пользовательский
      'user_image_30'//пользовательский
      );

type
  TFmxShemeVirtualImage = class(TFPCustomControl)
  private
    FBaseType: TFmxShemeImageTypes;
    FShemeImageTypeIndex: integer;
    FExtraType: TFmxShemeImageTypes;
    FIsBaseType: Boolean;
    procedure SetBaseType(const Value: TFmxShemeImageTypes);
    procedure SetShemeImageTypeIndex(const Value: integer);
    procedure SetExtraType(const Value: TFmxShemeImageTypes);
    procedure SetIsBaseType(const Value: Boolean);
    function GetZPosition: integer;
    procedure SetZPosition(const Value: integer);
    procedure SetEditing(const Value: boolean);override;
    { Private declarations }
  protected
    { Protected declarations }
    //прячем свойства
    procedure UpdateStyle;override;
    procedure DoOnClick(Sender: TObject);override;
    procedure SetColorSheme(const Value: TFmxColorSheme);override;
    property ButtonEnabled;
    property ButtonText;
    property Caption;
    property CaptionColor;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    procedure Invalidate;
    procedure FillParametersList;override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;

  published
    property ShemeImageTypes:TFmxShemeImageTypes read FBaseType write SetBaseType;//Основной вид для совместимости
    property BaseType:TFmxShemeImageTypes read FBaseType write SetBaseType;//Основной вид
    property ExtraType:TFmxShemeImageTypes read FExtraType write SetExtraType;//Дополнительный вид
    property IsBaseType:Boolean read FIsBaseType write SetIsBaseType;//Состояние - в основом или доболнительном
    property ShemeImageTypeIndex:integer read FShemeImageTypeIndex write SetShemeImageTypeIndex;
    property ZPosition:integer read GetZPosition write SetZPosition;
  end;

procedure Register;
function Str2ShemeImageType(const Value:String):TFmxShemeImageTypes;
function ShemeImageType2Str(const Value:TFmxShemeImageTypes):string;

implementation
uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti;


function ShemeImageType2Str(const Value:TFmxShemeImageTypes):string;
begin
   if Value in [fitElbow..fitUser_10] then
      result:=ShemeImageTypesNames[Value]
   else
      result:='';
end;

function Str2ShemeImageType(const Value:String):TFmxShemeImageTypes;
var i:TFmxShemeImageTypes;
begin
   result:=fitElbow;
   for I := fitElbow to fitUser_30 do
   begin
     if (Value=ShemeImageTypesNames[I]) or (Value= IntToStr(Ord(i))) then
     begin
       result:=i;
       Break;
     end;
   end;
end;


constructor TFmxShemeVirtualImage.Create(AOwner: TComponent);
begin
  inherited;
  //Чтобы произошла перезапись
  FBaseType:=fitUser_10;
  BaseType:=fitElbow;
  FShemeImageTypeIndex:=0;
  State:=fpsEnabled;
  OtherView:=False;
  ControlType:=ctSchemePrimitive;
  HitTest := True;
  IsBaseType:=True;
  StylesData['editframe.HitTest']:=True;
  StylesData['editframe.OnClick']:=TValue.From<TNotifyEvent>(DoOnClick);
end;

procedure TFmxShemeVirtualImage.SetEditing(const Value: boolean);
begin
  inherited;
  if Value then
     StylesData['editframe.HitTest']:=False
  else
     StylesData['editframe.HitTest']:=True;
end;
procedure TFmxShemeVirtualImage.DoOnClick(Sender: TObject);
begin
  inherited;
  if Editing then Exit;
  if BaseType<>ExtraType then
    IsBaseType:=Not IsBaseType;

  if Assigned(OnClick) then
     OnClick(self);
end;

//Заполняем структуру
procedure TFmxShemeVirtualImage.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,сShemePropertyCount);
   for i := 0 to сShemePropertyCount-1 do
   begin
     FParameters[i].Name:=cShemePropertys[i]; //Наименование
     FParameters[i].ParamType:=cShemePropertysType[i];//тип
     FParameters[i].Items:=cShemePropertyComboItems[i];
   end;

end;

function TFmxShemeVirtualImage.GetParamValue(Row: integer): String;
begin
  case Row of
    сSheme_Name:
      result := Caption; // 'Заголовок'
    cShemeHeader:
      result := Hint; // 'Подсказка'
    cShemeLeft:
      result := FloatToStr(left+ShiftL); //Слева
    cShemeTop:
      result := FloatToStr(top++ShiftT); //Сверху
    cShemeWidth:
      result := FloatToStr(width);//Ширина
    cShemeHeight:
      result := FloatToStr(height);//Высота
    cShemeNumAppFunction:
      result := IntToStr(AFIdx);//Функциональный номер
    cShemeTypeOfApp:
      result := cTypeOfAppFunc[TypeOfAppFunc];//Набор функций
    cShemeBaseType:
      result := ShemeImageTypesNames[BaseType];//Основной тип фигуры
    cShemeExtraType:
      result := ShemeImageTypesNames[ExtraType];//Всопомогательный тип фигуры
    cShemeState:
      result := cBooleanName[IsBaseType];//текущее состояние
    cShemeAngle:
      result := FloatToStr(RotationAngle);
    cShemeZPosition: begin
      result := IntToStr(ZPosition);
    end;
    cShemeVisible:
      result := cBooleanName[Visible];
    cShemeColor:
      result :=cFmxShemeColorNames[ColorSheme];
    cShemeOpacity:
      result :=FloatToStr(Opacity*100);
  end;
end;

function TFmxShemeVirtualImage.GetZPosition: integer;
var i:integer;
begin
  result:=0;
  if Assigned(Parent) then
  begin
    for I := 0 to Parent.Children.Count-1 do
    begin
      if Parent.Children[i] = self then
      begin
        result:=i;
        break;
      end;
    end;
  end;
end;

procedure TFmxShemeVirtualImage.Invalidate;
begin
  UpdateStyle;
end;

destructor TFmxShemeVirtualImage.Destroy;
begin
  inherited;
end;

procedure TFmxShemeVirtualImage.SetExtraType(
  const Value: TFmxShemeImageTypes);
begin
  if FExtraType <> Value then
  begin
    FExtraType := Value;
    UpdateStyle();
  end;
end;

procedure TFmxShemeVirtualImage.SetIsBaseType(const Value: Boolean);
begin
  if FIsBaseType <> Value then
  begin
    FIsBaseType := Value;
    UpdateStyle();
  end;
end;

procedure TFmxShemeVirtualImage.SetParamValue(Row: integer;
  const Value: String);
begin
    case Row of
    сSheme_Name:
      Caption:=Value; // 'Заголовок'
    cShemeHeader:
      Hint:=Value; // 'Подсказка'
    cShemeLeft:
      left:=StrToFloatDef(CP(Value), left)-ShiftL;
    cShemeTop:
      top:=StrToFloatDef(CP(Value), top)-ShiftT;
    cShemeWidth:
      width:=StrToFloatDef(CP(Value), width);
    cShemeHeight:
      height:=StrToFloatDef(CP(Value), height);
    cShemeNumAppFunction:
      AFIdx:=StrToIntDef(Value, AFIdx);
    cShemeTypeOfApp:
      TypeOfAppFunc:=myStrToTypeOfAppFunc(Value);
    cShemeBaseType:
      BaseType := Str2ShemeImageType(Value);
    cShemeExtraType:
      ExtraType := Str2ShemeImageType(Value);
    cShemeState:
      IsBaseType := myStrToBool(Value);
    cShemeAngle:
      RotationAngle := StrToFloatDef(CP(Value),RotationAngle);
    cShemeZPosition:
      ZPosition:=StrToIntDef(Value, AFIdx);
  cShemeVisible:
      Visible := myStrToBool(Value);
  cShemeColor:
      ColorSheme :=myStrToFmxShemeColor(Value);
  cShemeOpacity:
     Opacity:=StrToFloatDef(CP(Value),Opacity*100)/100.0;
  end;
end;

procedure TFmxShemeVirtualImage.SetShemeImageTypeIndex(const Value: integer);
begin
  FShemeImageTypeIndex := Value;
end;


procedure TFmxShemeVirtualImage.SetZPosition(const Value: integer);
var
  CurrIndex: Integer;
begin
  if not Assigned(Parent) then Exit;

  CurrIndex := GetZPosition;
  if CurrIndex = -1 then Exit;

  if (Value < 0) or (Value >= Parent.ChildrenCount) then
    Exit;

  if CurrIndex = Value then
    Exit;


  // Сохраняем ссылку на родителя
  var OldParent := Parent;

  // Временно удаляем себя из родителя
  Parent := nil;

  // Вставляем себя обратно на нужную позицию
  // Для этого используем Insert, который добавляет на конкретную позицию
  OldParent.InsertObject(Value, Self);

  UpdateStyle;
end;


procedure TFmxShemeVirtualImage.SetBaseType(
  const Value: TFmxShemeImageTypes);
begin
  if FBaseType <> Value then
  begin
    FBaseType := Value;
    UpdateStyle();
  end;
end;

procedure TFmxShemeVirtualImage.SetColorSheme(const Value: TFmxColorSheme);
begin
  inherited;
  CaptionColor:=ForeColor;
end;

procedure TFmxShemeVirtualImage.UpdateStyle;
var s:String;
begin
  inherited;
  if (BaseType in [fitElbow..fitGroupBox]) and (ExtraType in [fitElbow..fitGroupBox]) then
  begin
    if IsBaseType then
    begin
       s:=cFmxShemeVirtualImageHeader+cUnderline+ShemeImageTypesAppNames[BaseType]+cUnderline+cFmxColorShemeName[ColorSheme]+cUnderline+cFmxStyleName
    end
    else begin
       s:=cFmxShemeVirtualImageHeader+cUnderline+ShemeImageTypesAppNames[ExtraType]+cUnderline+cFmxColorShemeName[ColorSheme]+cUnderline+cFmxStyleName;
    end;
  end
  else begin
       S:=Format(cUser_IimageStyleNameMask,[ord(BaseType)-Ord(fitUser_1)+1])
  end;
  if s<>StyleLookup then
     StyleLookup:=s;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxShemeVirtualImage]);
end;

end.
