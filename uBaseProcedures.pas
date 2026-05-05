unit uBaseProcedures;

interface
uses
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.DateTimeCtrls,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.ListView,
  FMX.ListView.Adapters.Base,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Menus,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Types,
  System.Actions,
  System.Character,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.JSON,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.NetEncoding,
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants;

  const
  COLOR_INVALID = $FFFFECEC;   // Светло-красный: точка некорректна
  COLOR_RUNNING = $FFF2E9FF;   // Светло-фиолетовый: точка выполняется
  COLOR_COMPLETED = $FFEAF9EA; // Светло-зелёный: точка выполнена
  COLOR_WARNING   = $FFFFF8E6; // Светло-жёлтый

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

    EMeasurementState = (
      msNone,

      msSelectPoint,// — Выбор точки измерения

      msSelectEtalon,// — Выбор эталона

      msSetupPoint,// — Установка заданной точки

      msWaitStable,// — Ожидание стабилизации параметров

      msMeasure,// — Проведение измерения

      msResultsRead,// — Подготовка и чтение результатов

      msSave,// — Сохранение результатов

      msDone //— Окончание цикла измерения
  );

  EStableStatus = (
    ssNONE,
    ssRun_NN,   // no target, no stable
    ssRun_SN,   // stable, no target
    ssRun_NS,   // no stable, target
    ssOk,       // done + stable
    ssFail_SN,  // stable, no target
    ssFail_NS,  // no stable, target
    ssFail_NN   // no stable, no target
  );

  RStableInfo = record
    Status: EStableStatus;
    StatusText: string;
    CurrentValue: Double;
  end;

  EOutPutSet = (
    optAuto = 0,
    optPassive,
    optActive,
    optUniversal,
    optCapacity
  );

  ESyncChannelMode = (
    scmOff = 0,
    scmByEdge,
    scmByEdgeTime
  );

  TErrorInfo = record
    Code: Integer;
    Msg: string;
    Time: TDateTime;
    Stage: Integer;//EMeasurementState;
    class function Empty(AStage:Integer{: EMeasurementState}): TErrorInfo; static;
  end;



function NormalizeFloatInput(const S: string): Double;
function FormatPercentPM(const Value: Double): string;
function ExtractFirstFloat(const S: string): Double;
function ParseAccuracyClass(const S: string): Double;
function GetFracDigits(Value: Double): Integer;
function FormatDeviceError(Value: Double): string;
function FormatError(Value: Double): string;
 function FormatPhys(Value: Double): string;
function FormatTime(Value: Double): string;
function FormatByBaseError(Value, BaseError: Double): string;
function FormatValue(Value: Double; Accuracy: Integer; Error: Double): string; overload;
function FormatValue(const Str: string; Accuracy: Integer; Error: Double): string; overload;
function RemoveTrailingZeros(const Str: string): string;
function RandomGenerate(Value, Error: Double): Double;
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
function NormalizeFlowAccuracyInput(const S: string): string;
function BoolToRussianYesNo(const AValue: Boolean): string;
function ObjClassNameOrNil(const AObject: TObject): string;
function OutputSetToStr(AValue: EOutPutSet): string;
function StrToOutputSet(const AValue: string): EOutPutSet;
function IntToOutputSet(const AValue: Integer): EOutPutSet;
function SyncChannelModeToStr(AValue: ESyncChannelMode): string;
function StrToSyncChannelMode(const AValue: string): ESyncChannelMode;
function IntToSyncChannelMode(const AValue: Integer): ESyncChannelMode;
function NoiseFilterToStr(AValue: Integer): string;
function StrToNoiseFilter(const AValue: string): Integer;

implementation

  { TErrorInfo }

class function TErrorInfo.Empty(AStage: Integer): TErrorInfo;
begin
  Result.Code := 0;
  Result.Msg := '';
  Result.Time := Now;
  Result.Stage := AStage;
end;

function BoolToRussianYesNo(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function ObjClassNameOrNil(const AObject: TObject): string;
begin
  if AObject = nil then
    Exit('nil');
  Result := AObject.ClassName;
end;

function OutputSetToStr(AValue: EOutPutSet): string;
begin
  case AValue of
    optPassive: Result := 'Пассивный';
    optActive: Result := 'Активный';
    optUniversal: Result := 'Универсальный';
    optCapacity: Result := 'Емкостной';
  else
    Result := 'Авто';
  end;
end;

function StrToOutputSet(const AValue: string): EOutPutSet;
var
  LValue: string;
begin
  LValue := Trim(LowerCase(AValue));
  if LValue = LowerCase('Пассивный') then
    Exit(optPassive);
  if LValue = LowerCase('Активный') then
    Exit(optActive);
  if LValue = LowerCase('Универсальный') then
    Exit(optUniversal);
  if LValue = LowerCase('Емкостной') then
    Exit(optCapacity);
  Result := optAuto;
end;

function IntToOutputSet(const AValue: Integer): EOutPutSet;
begin
  if (AValue >= Ord(Low(EOutPutSet))) and (AValue <= Ord(High(EOutPutSet))) then
    Result := EOutPutSet(AValue)
  else
    Result := optAuto;
end;

function SyncChannelModeToStr(AValue: ESyncChannelMode): string;
begin
  case AValue of
    scmByEdge: Result := 'По фронту';
    scmByEdgeTime: Result := 'По фронту + время';
  else
    Result := 'Выкл';
  end;
end;

function StrToSyncChannelMode(const AValue: string): ESyncChannelMode;
var
  LValue: string;
begin
  LValue := Trim(LowerCase(AValue));
  if LValue = LowerCase('По фронту') then
    Exit(scmByEdge);
  if LValue = LowerCase('По фронту + время') then
    Exit(scmByEdgeTime);
  Result := scmOff;
end;

function IntToSyncChannelMode(const AValue: Integer): ESyncChannelMode;
begin
  if (AValue >= Ord(Low(ESyncChannelMode))) and
     (AValue <= Ord(High(ESyncChannelMode))) then
    Result := ESyncChannelMode(AValue)
  else
    Result := scmOff;
end;

function NoiseFilterToStr(AValue: Integer): string;
begin
  case AValue of
    -1: Result := 'Выкл';
    0: Result := 'Авто';
  else
    Result := IntToStr(AValue) + ' мс';
  end;
end;

function StrToNoiseFilter(const AValue: string): Integer;
var
  LValue: string;
  LInt: Integer;
begin
  LValue := Trim(LowerCase(AValue));
  if LValue = LowerCase('Выкл') then
    Exit(-1);
  if LValue = LowerCase('Авто') then
    Exit(0);
  if ExtractInt(LValue, LInt) then
    Result := LInt
  else
    Result := 0;
end;

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

function FormatByBaseError(Value, BaseError: Double): string;
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

  if Digits>10 then
          Digits := 10;
  // Формат без экспоненты
  Fmt := '0.' + StringOfChar('#', Digits);

  Result := FormatFloat(Fmt, Rounded);
end;

function GetDigitsFromError(Value, Error: Double): Integer;
var
  AbsError: Double;
  ValuePart: Double;
begin
  Result := 0;

  if Error <= 0 then
    Exit;

  // Абсолютная погрешность при относительной погрешности Error (%)
  AbsError := Abs(Value) * Error / 100;

  // Если само значение = 0, то относительная погрешность не даёт масштаба.
  // В таком случае просто оставляем 0 знаков.
  if AbsError <= 0 then
    Exit;

  // Требуемая дискретность отображения = 1/10 абсолютной погрешности
  ValuePart := AbsError / 2;

  if ValuePart >= 1 then
    Exit(0);

  Result := Ceil(-Log10(ValuePart));

  if Result < 0 then
    Result := 0;

  Result := EnsureRange(Result, 0, 12);
end;

function FormatValue(Value: Double; Accuracy: Integer; Error: Double): string;
var
  FS: TFormatSettings;
  FractPartCnt: Integer;
  RoundedValue: Double;
begin
  FS := TFormatSettings.Create;

  // 1. Если точность указана явно - используем только её
  if Accuracy >= 0 then
  begin
    FractPartCnt := EnsureRange(Accuracy, 0, 12);
    RoundedValue := RoundTo(Value, -FractPartCnt);
    Exit(FloatToStrF(RoundedValue, ffFixed, 18, FractPartCnt, FS));
  end;

  // 2. Иначе, если задана погрешность - рассчитываем число знаков по ней
  if Error > 0 then
    FractPartCnt := GetDigitsFromError(Value, Error)
  else
    FractPartCnt := 0;

  RoundedValue := RoundTo(Value, -FractPartCnt);
  Result := FloatToStrF(RoundedValue, ffFixed, 18, FractPartCnt, FS);
end;

function FormatValue(const Str: string; Accuracy: Integer; Error: Double): string;
var
  FS: TFormatSettings;
  S: string;
  V: Double;
begin
  FS := TFormatSettings.Create;
  S := Trim(Str);

  S := StringReplace(S, '.', FS.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, ',', FS.DecimalSeparator, [rfReplaceAll]);

  V := StrToFloatDef(S, 0, FS);
  Result := FormatValue(V, Accuracy, Error);
end;

function RemoveTrailingZeros(const Str: string): string;
var
  S: string;
  FS: TFormatSettings;
  SepPos, EndPos: Integer;
begin
  FS := TFormatSettings.Create;
  S := Trim(Str);
  SepPos := Pos(FS.DecimalSeparator, S);
  if SepPos = 0 then
    Exit(S);

  EndPos := Length(S);
  while (EndPos > SepPos) and (S[EndPos] = '0') do
    Dec(EndPos);

  if (EndPos >= SepPos) and (S[EndPos] = FS.DecimalSeparator) then
    Dec(EndPos);

  if EndPos > 0 then
    Result := Copy(S, 1, EndPos)
  else
    Result := '0';
end;

function RandomGenerate(Value, Error: Double): Double;
var
  LowerBound, UpperBound: Double;
begin
  LowerBound := Value - Value * Error / 100.0;
  UpperBound := Value + Value * Error / 100.0;
  Result := LowerBound + Random * (UpperBound - LowerBound);
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
