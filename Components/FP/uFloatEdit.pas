unit uFloatEdit;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Edit, FMX.Objects,
  FMX.StdCtrls, System.Types, System.UITypes, FMX.Graphics;

type
  TValueType=(vtFloat,vtInteger);
  TFloatEdit = class(TEdit)
  private
    FDecimalDigits: Byte;
    FDisplayFormat: string;
    FValue: Double;
    FExt: string;
    FExtPosition: Boolean;
    FExtSpacing: Integer;
    FShowExt: Boolean;
    FMinValue: Single;
    FMaxValue: Single;
    FInvalidColor: TAlphaColor;
    FOriginalTextSettings: TTextSettings;
    FOriginalBackgroundColor: TAlphaColor;
    FCheckRange: Boolean;
    FInternalUpdate: Boolean;
    FDelta: Single;
    FOnChangeValue: TNotifyEvent;
    FValueType: TValueType;
    procedure SetDecimalDigits(const Value: Byte);
    procedure SetDisplayFormat(const Value: string);
    procedure SetValue(const Value: Double);
    procedure SetExt(const Value: string);
    procedure SetExtPosition(const Value: Boolean);
    procedure SetExtSpacing(const Value: Integer);
    procedure SetShowExt(const Value: Boolean);
    procedure SetMinValue(const Value: Single);
    procedure SetMaxValue(const Value: Single);
    procedure SetInvalidColor(const Value: TAlphaColor);
    procedure SetCheckRange(const Value: Boolean);
    function GetDisplayText: string;
    procedure UpdateText;
    function GetCleanValue: Double;
    procedure CheckRangeAndUpdateColor;
    procedure SaveOriginalStyles;
    procedure RestoreOriginalStyles;
    procedure ApplyInvalidStyle;
    procedure HandleChangeTracking(Sender: TObject);
    procedure SetDelta(const Value: Single);
    procedure MouseWheelHandler(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure SetOnChangeValue(const Value: TNotifyEvent);
    procedure SetValueType(const Value: TValueType);
  protected
    procedure DoExit; override;
    procedure DoEnter; override;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsValid: Boolean;
    property CleanValue: Double read GetCleanValue;
  published
    property DecimalDigits: Byte read FDecimalDigits write SetDecimalDigits default 2;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property Value: Double read FValue write SetValue;
    property Ext: string read FExt write SetExt;
    property ExtPosition: Boolean read FExtPosition write SetExtPosition default True;
    property ExtSpacing: Integer read FExtSpacing write SetExtSpacing default 1;
    property ShowExt: Boolean read FShowExt write SetShowExt default True;
    property Min: Single read FMinValue write SetMinValue;
    property Max: Single read FMaxValue write SetMaxValue;
    property Delta: Single read FDelta write SetDelta;
    property InvalidColor: TAlphaColor read FInvalidColor write SetInvalidColor default TAlphaColorRec.Lightpink;
    property CheckRange: Boolean read FCheckRange write SetCheckRange default True;
    property OnChangeValue:TNotifyEvent read FOnChangeValue write SetOnChangeValue;
    property ValueType:TValueType read FValueType write SetValueType;
  end;

procedure Register;

implementation

uses
  System.Math,
  FmxHelper,
  System.StrUtils, FMX.Styles;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFloatEdit]);
end;

{ TFloatEdit }

constructor TFloatEdit.Create(AOwner: TComponent);
begin
  inherited;
  FMinValue:=0.0;
  FMaxValue:=9999999.0;
  FDecimalDigits := 2;
  FDisplayFormat := '0.00';
  FExt := 'Гц';
  FExtPosition := False;
  FExtSpacing := 1;
  FShowExt := True;
  FInvalidColor := TAlphaColorRec.Lightpink;
  FCheckRange := True;
  FInternalUpdate := False;
  KeyboardType := TVirtualKeyboardType.NumberPad;
  OnMouseWheel := MouseWheelHandler;
  ControlType:=TControlType.Styled;
  StyleLookup:='floateditstyle';

  // Подписываемся на событие изменения
  OnChangeTracking := HandleChangeTracking;

  // Сохраняем оригинальные стили
  SaveOriginalStyles;

  // Устанавливаем начальное значение
  UpdateText;
end;

destructor TFloatEdit.Destroy;
begin
  FreeAndNil(FOriginalTextSettings);
  inherited;
end;

procedure TFloatEdit.DoEnter;
begin
  inherited;
  FInternalUpdate := True;
  try
    Text := Format('%.' + IntToStr(FDecimalDigits) + 'f', [FValue]);
  finally
    FInternalUpdate := False;
  end;
  RestoreOriginalStyles;
end;

procedure TFloatEdit.DoExit;
var
  S: string;
  D: Double;
begin
  inherited;
  S := Text;
  if Pos('NAN',s)>0 then
    s:='0'
  else
    S := S.Replace(FExt, '').Trim;

  if TryStrToFloat(CP(S), D) then
    FValue := D
  else
    FValue := 0;

  UpdateText;
  CheckRangeAndUpdateColor;
end;

procedure TFloatEdit.HandleChangeTracking(Sender: TObject);
begin
  if not FInternalUpdate then
  begin
    // Проверка диапазона при ручном вводе
    if not IsFocused then
      CheckRangeAndUpdateColor;
  end;
end;

function TFloatEdit.GetCleanValue: Double;
begin
  Result := FValue;
end;

function TFloatEdit.GetDisplayText: string;
begin
  if FDisplayFormat <> '' then
    Result := FormatFloat(FDisplayFormat, FValue)
  else
    Result := Format('%.' + IntToStr(FDecimalDigits) + 'f', [FValue]);

  if FShowExt then
  begin
    if FExtPosition then
      Result := FExt + StringOfChar(' ', FExtSpacing) + Result
    else
      Result := Result + StringOfChar(' ', FExtSpacing) + FExt;
  end;
end;

procedure TFloatEdit.KeyDown(var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
  var firstcondition,secondconditiobn:Boolean;
begin
  firstcondition:=not CharInSet(KeyChar, ['0'..'9', ',', '.', #8]);
  secondconditiobn:=not (Key in [vkHome, vkEnd, vkLeft, vkRight, vkDelete, vkBack]);
  // Разрешаем только цифры, точку/запятую и управляющие клавиши
  if firstcondition and secondconditiobn then
    KeyChar := #0;

  inherited;
end;

procedure TFloatEdit.SetDecimalDigits(const Value: Byte);
begin
  if FDecimalDigits <> Value then
  begin
    FDecimalDigits := Value;
    UpdateText;
  end;
end;

procedure TFloatEdit.SetDelta(const Value: Single);
begin
  FDelta := Value;
end;

procedure TFloatEdit.SetDisplayFormat(const Value: string);
begin
  if FDisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
    UpdateText;
  end;
end;

procedure TFloatEdit.SetShowExt(const Value: Boolean);
begin
  if FShowExt <> Value then
  begin
    FShowExt := Value;
    UpdateText;
  end;
end;

procedure TFloatEdit.SetExt(const Value: string);
begin
  if FExt <> Value then
  begin
    FExt := Value;
    UpdateText;
  end;
end;

procedure TFloatEdit.SetExtPosition(const Value: Boolean);
begin
  if FExtPosition <> Value then
  begin
    FExtPosition := Value;
    UpdateText;
  end;
end;

procedure TFloatEdit.SetExtSpacing(const Value: Integer);
begin
  if FExtSpacing <> Value then
  begin
    FExtSpacing := Value;
    UpdateText;
  end;
end;

procedure TFloatEdit.SetValue(const Value: Double);
begin
  if FValue <> Value then
  begin
    FValue := Value;
    UpdateText;
    CheckRangeAndUpdateColor;
    if Assigned(OnChangeValue) then
       OnChangeValue(self);
  end;
end;

procedure TFloatEdit.SetValueType(const Value: TValueType);
begin
  FValueType := Value;
  if Value = TValueType.vtInteger then
     DecimalDigits:=0;
end;

procedure TFloatEdit.SetMinValue(const Value: Single);
begin
  FMinValue := Value;
  CheckRangeAndUpdateColor;
end;

procedure TFloatEdit.SetOnChangeValue(const Value: TNotifyEvent);
begin
  FOnChangeValue := Value;
end;

procedure TFloatEdit.SetMaxValue(const Value: Single);
begin
  if FMaxValue <> Value then
  begin
    FMaxValue := Value;
    CheckRangeAndUpdateColor;
  end;
end;

procedure TFloatEdit.SetInvalidColor(const Value: TAlphaColor);
begin
  if FInvalidColor <> Value then
  begin
    FInvalidColor := Value;
    if not IsValid then
      ApplyInvalidStyle;
  end;
end;

procedure TFloatEdit.SetCheckRange(const Value: Boolean);
begin
  if FCheckRange <> Value then
  begin
    FCheckRange := Value;
    CheckRangeAndUpdateColor;
  end;
end;

procedure TFloatEdit.UpdateText;
begin
  FInternalUpdate := True;
  try
    Text := GetDisplayText;
  finally
    FInternalUpdate := False;
  end;
end;

procedure TFloatEdit.CheckRangeAndUpdateColor;
begin
  if FCheckRange then
  begin
    if IsValid then
      RestoreOriginalStyles
    else
      ApplyInvalidStyle;
  end
  else
    RestoreOriginalStyles;
end;

function TFloatEdit.IsValid: Boolean;
begin
  Result := (FValue >= FMinValue) and (FValue <= FMaxValue);
end;

procedure TFloatEdit.SaveOriginalStyles;
begin
//  // Сохраняем оригинальный цвет фона
//  FOriginalBackgroundColor := TAlphaColorRec.White; // По умолчанию
//  if (Background <> nil) and (Background is TRectangle) then
//    FOriginalBackgroundColor := TRectangle(Background).Fill.Color;
//
//  // Сохраняем оригинальные настройки текста
//  if FOriginalTextSettings = nil then
//    FOriginalTextSettings := TTextSettings.Create(nil);
//  FOriginalTextSettings.Assign(TextSettings);
end;

procedure TFloatEdit.RestoreOriginalStyles;
begin
//  if Assigned(FOriginalTextSettings) then
//  begin
//    TextSettings.Assign(FOriginalTextSettings);
//
//    // Восстанавливаем оригинальный цвет фона
//    if (Background <> nil) and (Background is TRectangle) then
//      TRectangle(Background).Fill.Color := FOriginalBackgroundColor;
//  end;
end;

procedure TFloatEdit.ApplyInvalidStyle;
begin
//  // Изменяем цвет фона
//  if (Background <> nil) and (Background is TRectangle) then
//    TRectangle(Background).Fill.Color := FInvalidColor;
//
//  // Изменяем цвет текста (темный для лучшей читаемости на светлом фоне)
//  TextSettings.FontColor := TAlphaColorRec.Black;
end;


procedure TFloatEdit.MouseWheelHandler(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
var
  Step: Double;
begin
  // Шаг изменения
  if DecimalDigits=0 then
  begin
    if ssCtrl in Shift then
      Step := 10
    else
      Step := 1;
  end
  else begin
    if ssCtrl in Shift then
      Step := 1.0
    else
      Step := 0.1;
  end;
  if WheelDelta > 0 then
    FValue := FValue + Step
  else
    FValue := FValue - Step;
  UpdateText();
  Handled := True;
end;

initialization
  RegisterClass(TFloatEdit);
end.
