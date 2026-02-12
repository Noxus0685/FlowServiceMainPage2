unit UnitBaseProcedures;

interface
   uses

   System.Math,    System.StrUtils, System.Character,

   System.NetEncoding,
   System.DateUtils,
   System.JSON,
   System.Generics.Defaults,
    System.Generics.Collections,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.Rtti, FMX.Grid.Style, FMX.StdCtrls, FMX.Menus, FMX.Edit, FMX.Grid,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.TreeView, FMX.Layouts,
  FMX.ListView, System.Actions, FMX.ActnList, FMX.ListBox, FMX.DateTimeCtrls,
  FMX.Objects, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FMX.Memo.Types, FMX.Memo;

type

   IHasID = interface
    ['{A4E6E2F5-9E6F-4F8F-9A5C-6B4C9D3F8E21}']
    function GetID: Integer;
  end;


  TObjectState = (
    osEmpty,     // репозиторий пуст, ничего не загружено
    osLoading,   // идёт загрузка из БД

    osClean,     // загружено, без изменений (чистое состояние)
    osNew,       // создано, но ещё ни разу не сохранено
    osLoaded,
    osModified,  // изменено после загрузки или сохранения
    osDeleted,   // помечено на удаление

    osSaving,    // идёт сохранение
    osSaved,     // успешно сохранено
    osError      // ошибка
  );

  TTreeNodeKind = (
    tnAll,
    tnManufacturer,
    tnCategory,
    tnModification
  );


function NormalizeFloatInput(const S: string): Double;
function FormatPercentPM(const Value: Double): string;
function ExtractFirstFloat(const S: string): Double;
function ParseAccuracyClass(const S: string): Double;
function GetFracDigits(Value: Double): Integer;
function FormatDeviceError(Value: Double): string;
function FormatError(Value: Double): string;
 function FormatPhys(Value: Double): string;
function FormatTime(Value: Double): string;
function FormatQorV(Value, BaseError: Double): string;
function FormatFloatN(Value: Double; Digits: Integer): string;
function NormalizeAccuracyInput(const S: string): string;
function FormatAccuracy(const S: string): string;
function NormalizeDateInput(const AText: string): string;
function ParseFlexibleDate(const AText: string; out ADate: TDateTime): Boolean;
function ExtractInt(const AText: string; out AValue: Integer): Boolean;
function ExtractManufacturerName(const S: string): string;
function NormalizeNameCase(const S: string): string;
function NormalizeSearchText(const S: string): string;
function NormalizeTreeText(const S: string): string;
function FindChildInNode(AParent: TTreeViewItem; ATag: Integer; const AKey: string): TTreeViewItem;
function FindChildInTree(ATree: TTreeView; ATag: Integer; const AKey: string): TTreeViewItem;
function NewGuidString: string;
function ContainsTextAny(const AText, AFind: string): Boolean;
function IsDateInRange(const ADate, AFrom, ATo: TDate): Boolean;


implementation

function NormalizeFloatInput(const S: string): Double;
var
  I: Integer;
  Tmp: string;
  DecSep: Char;
begin
  Tmp := '';
  DecSep := FormatSettings.DecimalSeparator;

  for I := 1 to Length(S) do
    if CharInSet(S[I], ['0'..'9', '.', ',']) then
      Tmp := Tmp + S[I];

  Tmp := StringReplace(Tmp, '.', DecSep, [rfReplaceAll]);
  Tmp := StringReplace(Tmp, ',', DecSep, [rfReplaceAll]);

  Result := StrToFloatDef(Tmp, 0);
end;

function FormatPercentPM(const Value: Double): string;
begin
  if Value > 0 then
    Result := '±' + FloatToStr(Value) + '%'
  else
    Result := '—';
end;

function ExtractFirstFloat(const S: string): Double;
var
  I: Integer;
  Tmp: string;
  DecSep: Char;
begin
  Tmp := '';
  DecSep := FormatSettings.DecimalSeparator;

  for I := 1 to Length(S) do
    if CharInSet(S[I], ['0'..'9', '.', ',']) then
      Tmp := Tmp + S[I];

  Tmp := StringReplace(Tmp, '.', DecSep, [rfReplaceAll]);
  Tmp := StringReplace(Tmp, ',', DecSep, [rfReplaceAll]);

  Result := StrToFloatDef(Tmp, 0);
end;

function ParseAccuracyClass(const S: string): Double;
var
  Tmp: string;
begin
  Tmp := StringReplace(S, ',', '.', [rfReplaceAll]);
  Result := StrToFloatDef(Tmp, 1.0);
end;


function GetFracDigits(Value: Double): Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  if Value = 0 then Exit;

  S := FloatToStr(Value);
  P := Pos(FormatSettings.DecimalSeparator, S);
  if P > 0 then
    Result := Length(S) - P;
end;


function FormatFloatN(Value: Double; Digits: Integer): string;
begin
  Result := FormatFloat('0.' + StringOfChar('0', Digits), Value);
end;

function FormatQorV(Value, BaseError: Double): string;
var
  Delta, Rounded: Double;
  Digits: Integer;
  Fmt: string;
begin
  // ------------------------------------
  // Защита
  // ------------------------------------
  if Value <= 0 then
    Exit('—');

  // Если погрешность не задана —
  // показываем число как есть, но НЕ в экспоненте
  if BaseError <= 0 then
  begin
    Result := FormatFloat('0.################', Value);
    Exit;
  end;

  // ------------------------------------
  // Шаг округления
  // Δ = F * E / 1000
  // ------------------------------------
  Delta := Value * BaseError / 1000;

  if Delta <= 0 then
  begin
    Result := FormatFloat('0.################', Value);
    Exit;
  end;

  // ------------------------------------
  // Δ >= 1 → дробная часть бессмысленна
  // ------------------------------------
  if Delta >= 1 then
  begin
    Result := FormatFloat('0', Trunc(Value));
    Exit;
  end;

  // ------------------------------------
  // Округление к шагу Δ
  // ------------------------------------
  Rounded := Round(Value / Delta) * Delta;

  // ------------------------------------
  // Определяем количество знаков
  // по шагу Δ
  // ------------------------------------
  Digits := Max(0, -Floor(Log10(Delta)));

  // Формат без экспоненты
  Fmt := '0.' + StringOfChar('#', Digits);

  Result := FormatFloat(Fmt, Rounded);
end;

function FormatTime(Value: Double): string;
begin
  if Value = 0 then
    Result := '—'
  else
    Result := FormatFloatN(Value, 2);
end;


 function FormatPhys(Value: Double): string;
begin
  if Value = 0 then
    Result := '—'
  else
    Result := FormatFloatN(Value, 1);
end;

function FormatError(Value: Double): string;
begin
  if Value = 0 then
    Result := '—'
  else
    Result := FormatFloatN(Value, 1);
end;

function FormatDeviceError(Value: Double): string;
var
  Digits: Integer;
begin
  if Value = 0 then
    Exit('—');

  Digits := GetFracDigits(Value);
  Result := FormatFloatN(Value, Digits);
end;

function NormalizeFlowAccuracyInput(const S: string): string;
var
  T: string;
  V: Double;
begin
  Result := '';

  // убираем пробелы и %
  T := Trim(S);
  T := StringReplace(T, '%', '', [rfReplaceAll]);
  T := StringReplace(T, '±', '', [rfReplaceAll]);

  if T = '' then
    Exit('');

  // +5
  if (T[1] = '+') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '+' + FloatToStr(V);
    Exit;
  end;

  // -5
  if (T[1] = '-') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '-' + FloatToStr(V);
    Exit;
  end;

  // 5 → ±5
  V := NormalizeFloatInput(T);
  if V > 0 then
    Result := FloatToStr(V); // знак ± добавим при выводе
end;


function NormalizeAccuracyInput(const S: string): string;
var
  T: string;
  V: Double;
begin
  Result := '';

  // убираем пробелы и %
  T := Trim(S);
  T := StringReplace(T, '%', '', [rfReplaceAll]);
  T := StringReplace(T, '±', '', [rfReplaceAll]);

  if T = '' then
    Exit('');

  // +5
  if (T[1] = '+') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '+' + FloatToStr(V);
    Exit;
  end;

  // -5
  if (T[1] = '-') then
  begin
    V := NormalizeFloatInput(Copy(T, 2, MaxInt));
    if V > 0 then
      Result := '-' + FloatToStr(V);
    Exit;
  end;

  // 5 → ±5
  V := NormalizeFloatInput(T);
  if V > 0 then
    Result := FloatToStr(V); // знак ± добавим при выводе
end;


 function FormatAccuracy(const S: string): string;
var
  V: Double;
begin
  Result := '—';

  if Trim(S) = '' then
    Exit;

  // +5
  if S[1] = '+' then
  begin
    V := NormalizeFloatInput(Copy(S, 2, MaxInt));
    if V > 0 then
      Result := '+' + FloatToStr(V);
    Exit;
  end;

  // -5
  if S[1] = '-' then
  begin
    V := NormalizeFloatInput(Copy(S, 2, MaxInt));
    if V > 0 then
      Result := '-' + FloatToStr(V);
    Exit;
  end;

  // 5 → ±5
  V := NormalizeFloatInput(S);
  if V > 0 then
    Result := '±' + FloatToStr(V);
end;

function NormalizeDateInput(const AText: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := '';

  for I := 1 to Length(AText) do
  begin
    C := AText[I];

    // цифры оставляем
    if C in ['0'..'9'] then
      Result := Result + C

    // любые разделители считаем точкой
    else if C in ['.', ',', ':', '-', '/', ' '] then
    begin
      if (Result = '') or (Result[Length(Result)] <> '.') then
        Result := Result + '.';
    end;

    // все прочие символы просто игнорируем
  end;

  // убираем точку в конце
  if (Result <> '') and (Result[Length(Result)] = '.') then
    Delete(Result, Length(Result), 1);
end;

function ParseFlexibleDate(const AText: string; out ADate: TDateTime): Boolean;
var
  S: string;
  Parts: TArray<string>;
  Y, M, D: Word;
begin
  Result := False;
  ADate := 0;

  S := NormalizeDateInput(AText);
  if S = '' then Exit;

  Parts := S.Split(['.']);

  try
    case Length(Parts) of
      1:
        begin
          // только год
          Y := StrToInt(Parts[0]);
          M := 1;
          D := 1;
        end;

      2:
        begin
          // месяц + год
          M := StrToInt(Parts[0]);
          Y := StrToInt(Parts[1]);
          D := 1;
        end;

      3:
        begin
          // день + месяц + год
          D := StrToInt(Parts[0]);
          M := StrToInt(Parts[1]);
          Y := StrToInt(Parts[2]);
        end
      else
        Exit;
    end;

    ADate := EncodeDate(Y, M, D);
    Result := True;
  except
    Result := False;
  end;
end;

function ExtractInt(const AText: string; out AValue: Integer): Boolean;
var
  I: Integer;
  S: string;
begin
  S := '';

  for I := 1 to Length(AText) do
    if AText[I] in ['0'..'9'] then
      S := S + AText[I];

  Result := (S <> '');
  if Result then
    AValue := StrToIntDef(S, 0);
end;

function ExtractManufacturerName(const S: string): string;
var
  Src, Part, Name: string;
  I, StartPos, EndPos: Integer;
  OpenQuote, CloseQuote: Char;
begin
  Result := '';

  Src := Trim(S);
  if Src = '' then Exit;

  // Берём первого производителя (до ;)
  I := Pos(';', Src);
  if I > 0 then
    Part := Trim(Copy(Src, 1, I - 1))
  else
    Part := Src;

  // Ищем первую пару кавычек
  for I := 1 to Length(Part) do
  begin
    if (Part[I] = '"') or (Part[I] = '«') then
    begin
      OpenQuote := Part[I];
      if OpenQuote = '«' then
        CloseQuote := '»'
      else
        CloseQuote := '"';

      StartPos := I + 1;
      EndPos := StartPos;

      while (EndPos <= Length(Part)) and (Part[EndPos] <> CloseQuote) do
        Inc(EndPos);

      if EndPos <= Length(Part) then
      begin
        Name := Copy(Part, StartPos, EndPos - StartPos);
        Result := NormalizeNameCase(Trim(Name));
        Exit;
      end;
    end;
  end;

  // fallback
  Result := NormalizeNameCase(Src);
end;

function NormalizeNameCase(const S: string): string;
var
  I: Integer;
  FirstLetterFound: Boolean;
begin
  Result := S;
  FirstLetterFound := False;

  for I := 1 to Length(Result) do
  begin
    if TCharacter.IsLetter(Result[I]) then
    begin
      if not FirstLetterFound then
      begin
        Result[I] := TCharacter.ToUpper(Result[I]);
        FirstLetterFound := True;
      end
      else
        Result[I] := TCharacter.ToLower(Result[I]);
    end;
  end;
end;

function NormalizeSearchText(const S: string): string;
begin
  Result := LowerCase(S);

  // все виды тире → пробел
  Result := StringReplace(Result, '–', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '—', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '-', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '-', ' ', [rfReplaceAll]);
end;

function NormalizeTreeText(const S: string): string;
begin
  if Trim(S) = '' then
    Result := '<пусто>'
  else
    Result := Trim(S);
end;

function FindChildInTree(
  ATree: TTreeView;
  ATag: Integer;
  const AKey: string
): TTreeViewItem;
var
  I: Integer;
  Item: TTreeViewItem;
begin
  Result := nil;

  for I := 0 to ATree.Count - 1 do
  begin
    Item := ATree.Items[I];
    if (Item.Tag = ATag) and (Item.TagString = AKey) then
      Exit(Item);
  end;
end;

function FindChildInNode(
  AParent: TTreeViewItem;
  ATag: Integer;
  const AKey: string
): TTreeViewItem;
var
  I: Integer;
  Item: TTreeViewItem;
begin
  Result := nil;

  for I := 0 to AParent.Count - 1 do
  begin
    Item := TTreeViewItem(AParent.Items[I]);
    if (Item.Tag = ATag) and (Item.TagString = AKey) then
      Exit(Item);
  end;
end;



function NewGuidString: string;
begin
  Result := TGUID.NewGuid.ToString;
end;


function ContainsTextAny(const AText, AFind: string): Boolean;
begin
  Result := (AFind = '') or
            ContainsText(AText, AFind);
end;

function IsDateInRange(const ADate, AFrom, ATo: TDate): Boolean;
begin
  Result := (ADate >= AFrom) and (ADate <= ATo);
end;


end.
