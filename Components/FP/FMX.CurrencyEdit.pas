unit FMX.CurrencyEdit;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Edit, FMX.Objects,
  FMX.StdCtrls, System.Types, System.UITypes, FMX.Graphics;

type
  TFMXCurrencyEdit = class(TEdit)
  private
    FDecimalPlaces: Byte;
    FDisplayFormat: string;
    FValue: Currency;
    FSymbol: string;
    FSymbolPosition: Boolean;
    FSymbolSpacing: Integer;
    FShowSymbol: Boolean;
    FMinValue: Currency;
    FMaxValue: Currency;
    FInvalidColor: TAlphaColor;
    FOriginalTextSettings: TTextSettings;
    FOriginalBackgroundColor: TAlphaColor;
    FCheckRange: Boolean;
    FInternalUpdate: Boolean;
    procedure SetDecimalPlaces(const Value: Byte);
    procedure SetDisplayFormat(const Value: string);
    procedure SetValue(const Value: Currency);
    procedure SetSymbol(const Value: string);
    procedure SetSymbolPosition(const Value: Boolean);
    procedure SetSymbolSpacing(const Value: Integer);
    procedure SetShowSymbol(const Value: Boolean);
    procedure SetMinValue(const Value: Currency);
    procedure SetMaxValue(const Value: Currency);
    procedure SetInvalidColor(const Value: TAlphaColor);
    procedure SetCheckRange(const Value: Boolean);
    function GetDisplayText: string;
    procedure UpdateText;
    function GetCleanValue: Currency;
    procedure CheckRangeAndUpdateColor;
    procedure SaveOriginalStyles;
    procedure RestoreOriginalStyles;
    procedure ApplyInvalidStyle;
    procedure HandleChangeTracking(Sender: TObject);
  protected
    procedure DoExit; override;
    procedure DoEnter; override;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsValid: Boolean;
    property CleanValue: Currency read GetCleanValue;
  published
    property DecimalPlaces: Byte read FDecimalPlaces write SetDecimalPlaces default 2;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property Value: Currency read FValue write SetValue;
    property Symbol: string read FSymbol write SetSymbol;
    property SymbolPosition: Boolean read FSymbolPosition write SetSymbolPosition default True;
    property SymbolSpacing: Integer read FSymbolSpacing write SetSymbolSpacing default 1;
    property ShowSymbol: Boolean read FShowSymbol write SetShowSymbol default True;
    property MinValue: Currency read FMinValue write SetMinValue;
    property MaxValue: Currency read FMaxValue write SetMaxValue;
    property InvalidColor: TAlphaColor read FInvalidColor write SetInvalidColor default TAlphaColorRec.Lightpink;
    property CheckRange: Boolean read FCheckRange write SetCheckRange default True;
  end;

procedure Register;

implementation

uses
  System.Math, System.StrUtils, FMX.Styles;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFMXCurrencyEdit]);
end;

{ TFMXCurrencyEdit }

constructor TFMXCurrencyEdit.Create(AOwner: TComponent);
begin
  inherited;
  FDecimalPlaces := 2;
  FDisplayFormat := ',0.00';
  FSymbol := '$';
  FSymbolPosition := True;
  FSymbolSpacing := 1;
  FShowSymbol := True;
  FMinValue := -MaxCurrency;
  FMaxValue := MaxCurrency;
  FInvalidColor := TAlphaColorRec.Lightpink;
  FCheckRange := True;
  FInternalUpdate := False;
  KeyboardType := TVirtualKeyboardType.NumberPad;

  // Подписываемся на событие изменения
  OnChangeTracking := HandleChangeTracking;

  // Сохраняем оригинальные стили
  SaveOriginalStyles;

  // Устанавливаем начальное значение
  UpdateText;
end;

destructor TFMXCurrencyEdit.Destroy;
begin
  FreeAndNil(FOriginalTextSettings);
  inherited;
end;

procedure TFMXCurrencyEdit.DoEnter;
begin
  inherited;
  FInternalUpdate := True;
  try
    Text := Format('%.' + IntToStr(FDecimalPlaces) + 'f', [FValue]);
  finally
    FInternalUpdate := False;
  end;
  RestoreOriginalStyles;
end;

procedure TFMXCurrencyEdit.DoExit;
var
  S: string;
  D: Double;
begin
  inherited;
  S := Text;
  S := S.Replace(FSymbol, '').Trim;

  if TryStrToFloat(S, D) then
    FValue := D
  else
    FValue := 0;

  UpdateText;
  CheckRangeAndUpdateColor;
end;

procedure TFMXCurrencyEdit.HandleChangeTracking(Sender: TObject);
begin
  if not FInternalUpdate then
  begin
    // Проверка диапазона при ручном вводе
    if not IsFocused then
      CheckRangeAndUpdateColor;
  end;
end;

function TFMXCurrencyEdit.GetCleanValue: Currency;
begin
  Result := FValue;
end;

function TFMXCurrencyEdit.GetDisplayText: string;
begin
  if FDisplayFormat <> '' then
    Result := FormatFloat(FDisplayFormat, FValue)
  else
    Result := Format('%.' + IntToStr(FDecimalPlaces) + 'f', [FValue]);

  if FShowSymbol then
  begin
    if FSymbolPosition then
      Result := FSymbol + StringOfChar(' ', FSymbolSpacing) + Result
    else
      Result := Result + StringOfChar(' ', FSymbolSpacing) + FSymbol;
  end;
end;

procedure TFMXCurrencyEdit.KeyDown(var Key: Word; var KeyChar: Char;
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

procedure TFMXCurrencyEdit.SetDecimalPlaces(const Value: Byte);
begin
  if FDecimalPlaces <> Value then
  begin
    FDecimalPlaces := Value;
    UpdateText;
  end;
end;

procedure TFMXCurrencyEdit.SetDisplayFormat(const Value: string);
begin
  if FDisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
    UpdateText;
  end;
end;

procedure TFMXCurrencyEdit.SetShowSymbol(const Value: Boolean);
begin
  if FShowSymbol <> Value then
  begin
    FShowSymbol := Value;
    UpdateText;
  end;
end;

procedure TFMXCurrencyEdit.SetSymbol(const Value: string);
begin
  if FSymbol <> Value then
  begin
    FSymbol := Value;
    UpdateText;
  end;
end;

procedure TFMXCurrencyEdit.SetSymbolPosition(const Value: Boolean);
begin
  if FSymbolPosition <> Value then
  begin
    FSymbolPosition := Value;
    UpdateText;
  end;
end;

procedure TFMXCurrencyEdit.SetSymbolSpacing(const Value: Integer);
begin
  if FSymbolSpacing <> Value then
  begin
    FSymbolSpacing := Value;
    UpdateText;
  end;
end;

procedure TFMXCurrencyEdit.SetValue(const Value: Currency);
begin
  if FValue <> Value then
  begin
    FValue := Value;
    UpdateText;
    CheckRangeAndUpdateColor;
  end;
end;

procedure TFMXCurrencyEdit.SetMinValue(const Value: Currency);
begin
  if FMinValue <> Value then
  begin
    FMinValue := Value;
    CheckRangeAndUpdateColor;
  end;
end;

procedure TFMXCurrencyEdit.SetMaxValue(const Value: Currency);
begin
  if FMaxValue <> Value then
  begin
    FMaxValue := Value;
    CheckRangeAndUpdateColor;
  end;
end;

procedure TFMXCurrencyEdit.SetInvalidColor(const Value: TAlphaColor);
begin
  if FInvalidColor <> Value then
  begin
    FInvalidColor := Value;
    if not IsValid then
      ApplyInvalidStyle;
  end;
end;

procedure TFMXCurrencyEdit.SetCheckRange(const Value: Boolean);
begin
  if FCheckRange <> Value then
  begin
    FCheckRange := Value;
    CheckRangeAndUpdateColor;
  end;
end;

procedure TFMXCurrencyEdit.UpdateText;
begin
  FInternalUpdate := True;
  try
    Text := GetDisplayText;
  finally
    FInternalUpdate := False;
  end;
end;

procedure TFMXCurrencyEdit.CheckRangeAndUpdateColor;
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

function TFMXCurrencyEdit.IsValid: Boolean;
begin
  Result := (FValue >= FMinValue) and (FValue <= FMaxValue);
end;

procedure TFMXCurrencyEdit.SaveOriginalStyles;
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

procedure TFMXCurrencyEdit.RestoreOriginalStyles;
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

procedure TFMXCurrencyEdit.ApplyInvalidStyle;
begin
//  // Изменяем цвет фона
//  if (Background <> nil) and (Background is TRectangle) then
//    TRectangle(Background).Fill.Color := FInvalidColor;
//
//  // Изменяем цвет текста (темный для лучшей читаемости на светлом фоне)
//  TextSettings.FontColor := TAlphaColorRec.Black;
end;

end.
