unit uMathOperand;

interface

type
  TOperationType = (opNone, opAssign, opEqual, opGreaterOrEqual, opLessOrEqual,
    opGreater, opLess, opNotEqual);

  TOperandInfo = record
    Operation: TOperationType;
    LeftOperand: string;
    RightOperand: string;
    Valid: Boolean;
  end;

function ParseOperation(const InputString: string): TOperandInfo;
function OperationTypeToString(OpType: TOperationType): string;
function SplitStringByComma(const InputString: string): TArray<string>;
function GetLeftOperand(const InputString: string): String;
function GetOperation(_Operation: TOperationType): String;
function GetLeftOperandAndOperation(const InputString: string): String;

implementation

uses
  System.Classes, // для TStringList
  System.SysUtils;

const
  cOperationTypeNames: Array [TOperationType] of String = ('', '=', '==', '>=',
    '<=', '>', '<', '!=');

function ParseOperation(const InputString: string): TOperandInfo;
var
  Str: string;
  OpPos: Integer;
  OpStr: string;
begin
  // Инициализация результата
  Result.Valid := False;
  Result.LeftOperand := '';
  Result.RightOperand := '';
  Result.Operation := opNone;

  Str := Trim(InputString);
  if Str = '' then
    Exit;

  // Поиск операции (в порядке приоритета многосимвольных операций)
  if Pos(GetOperation(opEqual), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opEqual), Str);
    OpStr := GetOperation(opEqual);
    Result.Operation := opEqual;
  end
  else if Pos(GetOperation(opGreaterOrEqual), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opGreaterOrEqual), Str);
    OpStr := GetOperation(opGreaterOrEqual);
    Result.Operation := opGreaterOrEqual;
  end
  else if Pos(GetOperation(opLessOrEqual), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opLessOrEqual), Str);
    OpStr := GetOperation(opLessOrEqual);
    Result.Operation := opLessOrEqual;
  end
  else if Pos(GetOperation(opNotEqual), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opNotEqual), Str);
    OpStr := GetOperation(opNotEqual);
    Result.Operation := opNotEqual;
  end
  else if Pos(GetOperation(opAssign), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opAssign), Str);
    OpStr := GetOperation(opAssign);
    Result.Operation := opAssign;
  end
  else if Pos(GetOperation(opGreater), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opGreater), Str);
    OpStr := GetOperation(opGreater);
    Result.Operation := opGreater;
  end
  else if Pos(GetOperation(opLess), Str) > 0 then
  begin
    OpPos := Pos(GetOperation(opLess), Str);
    OpStr := GetOperation(opLess);
    Result.Operation := opLess;
  end
  else
  begin
    // Операция не найдена
    Result.Valid := Str<>'';
    Result.LeftOperand := Str;
    Result.RightOperand := '';
    Result.Operation := opNone;
    Exit;
  end;

  // Извлечение операндов
  Result.LeftOperand := Trim(Copy(Str, 1, OpPos - 1));
  Result.RightOperand := Trim(Copy(Str, OpPos + Length(OpStr), MaxInt));
  Result.Valid := (Result.LeftOperand <> '') and (Result.RightOperand <> '');
end;

function GetLeftOperandAndOperation(const InputString: string): String;
var
  OI: TOperandInfo;
begin
  OI := ParseOperation(InputString);
  Result := OI.LeftOperand + cOperationTypeNames[OI.Operation];
end;

function GetOperation(_Operation: TOperationType): String;
begin
  if (_Operation >= opNone) and (_Operation <= opNotEqual) then
    Result := cOperationTypeNames[_Operation]
  else
    Result := '';
end;

function GetLeftOperand(const InputString: string): String;
var
  OI: TOperandInfo;
begin
  OI := ParseOperation(InputString);
  Result := OI.LeftOperand;
end;

// Функция для получения текстового представления типа операции
function OperationTypeToString(OpType: TOperationType): string;
begin
  case OpType of
    opAssign:
      Result := 'присвоение';
    opEqual:
      Result := 'равно';
    opGreaterOrEqual:
      Result := 'больше или равно';
    opLessOrEqual:
      Result := 'меньше или равно';
    opGreater:
      Result := 'больше';
    opLess:
      Result := 'меньше';
    opNotEqual:
      Result := 'не равно';
  else
    Result := 'неизвестно';
  end;
end;

function SplitStringByComma(const InputString: string): TArray<string>;
var
  Elements: TStringList;
  i: Integer;
begin
  Elements := TStringList.Create;
  try
    Elements.Delimiter := ',';
    Elements.StrictDelimiter := True;
    Elements.DelimitedText := InputString;

    SetLength(Result, Elements.Count);
    for i := 0 to Elements.Count - 1 do
      Result[i] := Trim(Elements[i]);
  finally
    FreeAndNil(Elements);
  end;
end;

end.
