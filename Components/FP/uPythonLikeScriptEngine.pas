unit uPythonLikeScriptEngine;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Rtti, FMX.Dialogs, FMX.Forms, FMX.Controls, System.TypInfo;

type
  TScriptFunction = reference to function(const Args: array of string): string;
  TVariableType = (vtString, vtNumber, vtBoolean, vtArray, vtObject);

  TScriptArray = TArray<string>;

  TScriptVariable = record
    Name: string;
    Value: string;
    ArrayValue: TScriptArray;
    VarType: TVariableType;
    ObjectInstance: TObject;
  end;

  TScriptContext = class
  public
    Variables: TDictionary<string, TScriptVariable>;
    Parent: TScriptContext;
    constructor Create(AParent: TScriptContext = nil);
    destructor Destroy; override;
  end;

  TPythonLikeScriptEngine = class
  private
    FGlobalVariables: TDictionary<string, TScriptVariable>;
    FFunctions: TDictionary<string, TScriptFunction>;
    FOutput: TStrings;
    FCurrentLine: Integer;
    FScriptLines: TArray<string>;
    FRttiContext: TRttiContext;
    FApplication: TApplication;

    procedure RegisterBuiltInFunctions;
    function ParseLine(var Context: TScriptContext; const Line: string): Boolean;
    function EvaluateExpression(var Context: TScriptContext; const Expr: string): string;
    function EvaluateCondition(var Context: TScriptContext; const Condition: string): Boolean;
    function IsNumber(const Str: string): Boolean;
    function IsBoolean(const Str: string): Boolean;
    function GetVariableValue(var Context: TScriptContext; const VarName: string): string;
    function GetVariableArray(var Context: TScriptContext; const VarName: string): TScriptArray;
    procedure SetVariableValue(var Context: TScriptContext; const VarName, Value: string);
    procedure SetVariableArray(var Context: TScriptContext; const VarName: string; const Value: TScriptArray);
    function ExecuteBlock(var Context: TScriptContext; StartLine: Integer; const EndCondition: string = ''): Integer;

    function ParseArray(const ArrayStr: string): TScriptArray;
    function ArrayToString(const Arr: TScriptArray): string;

    // RTTI функции
    function GetObjectProperty(Obj: TObject; const PropPath: string): string;
    procedure SetObjectProperty(Obj: TObject; const PropPath, Value: string);
    function CallObjectMethod(Obj: TObject; const MethodName: string; const Args: array of string): string;
    function FindComponent(const Name: string): TComponent;

    // Python-подобные конструкции
    function ParsePythonBlock(var Context: TScriptContext; StartLine: Integer; const BlockType: string): Integer;
    function ParsePythonStyleLine(var Context: TScriptContext; const Line: string): Boolean;
  public
    constructor Create(AApplication: TApplication);
    destructor Destroy; override;

    procedure RegisterFunction(const Name: string; Func: TScriptFunction);
    function ExecuteScript(const ScriptCode: string): string;
    function ExecuteScriptFile(const FileName: string): string;
    procedure SetOutput(Strings: TStrings);

    // Глобальные переменные приложения
    procedure SetGlobalVariable(const Name, Value: string);
    procedure SetGlobalArray(const Name: string; const Value: TScriptArray);
    procedure SetGlobalObject(const Name: string; Obj: TObject);
    function GetGlobalVariable(const Name: string): string;
    function GetGlobalArray(const Name: string): TScriptArray;

    property Output: TStrings read FOutput;
  end;

implementation

{ TScriptContext }

constructor TScriptContext.Create(AParent: TScriptContext);
begin
  inherited Create;
  Variables := TDictionary<string, TScriptVariable>.Create;
  Parent := AParent;
end;

destructor TScriptContext.Destroy;
begin
  Variables.Free;
  inherited;
end;

{ TPythonLikeScriptEngine }

constructor TPythonLikeScriptEngine.Create(AApplication: TApplication);
begin
  inherited Create;
  FApplication := AApplication;
  FGlobalVariables := TDictionary<string, TScriptVariable>.Create;
  FFunctions := TDictionary<string, TScriptFunction>.Create;
  FOutput := TStringList.Create;
  FRttiContext := TRttiContext.Create;

  RegisterBuiltInFunctions;
end;

destructor TPythonLikeScriptEngine.Destroy;
begin
  FGlobalVariables.Free;
  FFunctions.Free;
  FOutput.Free;
  FRttiContext.Free;
  inherited;
end;

function TPythonLikeScriptEngine.FindComponent(const Name: string): TComponent;
begin
  Result := FApplication.FindComponent(Name);
  if Result = nil then
    Result := FApplication.MainForm.FindComponent(Name);
end;

function TPythonLikeScriptEngine.GetGlobalArray(
  const Name: string): TScriptArray;
begin

end;

function TPythonLikeScriptEngine.GetGlobalVariable(const Name: string): string;
begin

end;

function TPythonLikeScriptEngine.GetObjectProperty(Obj: TObject; const PropPath: string): string;
var
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  RttiField: TRttiField;
  CurrentObj: TObject;
  PathParts: TArray<string>;
  I: Integer;
  Value: TValue;
begin
  if Obj = nil then
    Exit('None');

  PathParts := PropPath.Split(['.']);
  CurrentObj := Obj;

  try
    for I := 0 to Length(PathParts) - 1 do
    begin
      RttiType := FRttiContext.GetType(CurrentObj.ClassType);

      // Ищем свойство
      RttiProp := RttiType.GetProperty(PathParts[I]);
      if RttiProp <> nil then
      begin
        if I = Length(PathParts) - 1 then
        begin
          Value := RttiProp.GetValue(CurrentObj);
          Result := Value.ToString;
          Exit;
        end
        else
        begin
          CurrentObj := RttiProp.GetValue(CurrentObj).AsObject;
          if CurrentObj = nil then
            Exit('None');
        end;
      end
      else
      begin
        // Ищем поле
        RttiField := RttiType.GetField(PathParts[I]);
        if RttiField <> nil then
        begin
          if I = Length(PathParts) - 1 then
          begin
            Value := RttiField.GetValue(CurrentObj);
            Result := Value.ToString;
            Exit;
          end
          else
          begin
            CurrentObj := RttiField.GetValue(CurrentObj).AsObject;
            if CurrentObj = nil then
              Exit('None');
          end;
        end
        else
          Exit('None');
      end;
    end;

    Result := 'None';
  except
    on E: Exception do
      Result := 'Error: ' + E.Message;
  end;
end;

function TPythonLikeScriptEngine.GetVariableArray(var Context: TScriptContext;
  const VarName: string): TScriptArray;
begin

end;

function TPythonLikeScriptEngine.GetVariableValue(var Context: TScriptContext;
  const VarName: string): string;
begin

end;

function TPythonLikeScriptEngine.IsBoolean(const Str: string): Boolean;
begin

end;

function TPythonLikeScriptEngine.IsNumber(const Str: string): Boolean;
begin

end;

procedure TPythonLikeScriptEngine.SetObjectProperty(Obj: TObject; const PropPath, Value: string);
var
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  PathParts: TArray<string>;
  CurrentObj: TObject;
  I: Integer;
  NewValue: TValue;
begin
  if Obj = nil then
    Exit;

  PathParts := PropPath.Split(['.']);
  CurrentObj := Obj;

  try
    for I := 0 to Length(PathParts) - 2 do
    begin
      RttiType := FRttiContext.GetType(CurrentObj.ClassType);
      RttiProp := RttiType.GetProperty(PathParts[I]);
      if RttiProp <> nil then
        CurrentObj := RttiProp.GetValue(CurrentObj).AsObject
      else
        Exit;

      if CurrentObj = nil then
        Exit;
    end;

    RttiType := FRttiContext.GetType(CurrentObj.ClassType);
    RttiProp := RttiType.GetProperty(PathParts[Length(PathParts) - 1]);

    if RttiProp <> nil then
    begin
      case RttiProp.PropertyType.TypeKind of
        tkInteger, tkInt64:
          NewValue := StrToIntDef(Value, 0);
        tkFloat:
          NewValue := StrToFloatDef(Value, 0);
        tkUString, tkString, tkWString, tkLString:
          NewValue := Value;
        tkEnumeration:
          if RttiProp.PropertyType.ToString = 'Boolean' then
            NewValue := (LowerCase(Value) = 'true') or (Value = '1')
          else
            NewValue := Value;
        else
          NewValue := Value;
      end;

      RttiProp.SetValue(CurrentObj, NewValue);
    end;
  except
    on E: Exception do
      FOutput.Add('Error setting property: ' + E.Message);
  end;
end;

function TPythonLikeScriptEngine.ArrayToString(const Arr: TScriptArray): string;
begin

end;

procedure TPythonLikeScriptEngine.SetOutput(Strings: TStrings);
begin

end;

procedure TPythonLikeScriptEngine.SetVariableArray(var Context: TScriptContext;
  const VarName: string; const Value: TScriptArray);
begin

end;

procedure TPythonLikeScriptEngine.SetVariableValue(var Context: TScriptContext;
  const VarName, Value: string);
begin

end;

function TPythonLikeScriptEngine.CallObjectMethod(Obj: TObject; const MethodName: string; const Args: array of string): string;
var
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
  Params: array of TValue;
  I: Integer;
  ReturnValue: TValue;
begin
  if Obj = nil then
    Exit('None');

  try
    RttiType := FRttiContext.GetType(Obj.ClassType);
    RttiMethod := RttiType.GetMethod(MethodName);

    if RttiMethod <> nil then
    begin
      SetLength(Params, Length(Args));
      for I := 0 to High(Args) do
      begin
        // Простое преобразование аргументов
        if IsNumber(Args[I]) then
          Params[I] := StrToFloat(Args[I])
        else if IsBoolean(Args[I]) then
          Params[I] := (Args[I] = 'true') or (Args[I] = '1')
        else
          Params[I] := Args[I];
      end;

      ReturnValue := RttiMethod.Invoke(Obj, Params);
      Result := ReturnValue.ToString;
    end
    else
      Result := 'None';
  except
    on E: Exception do
      Result := 'Error: ' + E.Message;
  end;
end;

procedure TPythonLikeScriptEngine.RegisterBuiltInFunctions;
begin
  // Python-подобные встроенные функции
  RegisterFunction('print',
    function(const Args: array of string): string
    var
      I: Integer;
      OutputText: string;
    begin
      OutputText := '';
      for I := 0 to High(Args) do
        OutputText := OutputText + Args[I] + ' ';

      if FOutput <> nil then
        FOutput.Add(OutputText.Trim);

      Result := OutputText.Trim;
    end);

  RegisterFunction('len',
    function(const Args: array of string): string
    begin
      if Length(Args) > 0 then
        Result := IntToStr(Length(Args[0]))
      else
        Result := '0';
    end);

  RegisterFunction('range',
    function(const Args: array of string): string
    var
      Start, Stop, Step, I: Integer;
      ResultArr: TArray<string>;
    begin
      if Length(Args) = 1 then
      begin
        Stop := StrToIntDef(Args[0], 0);
        SetLength(ResultArr, Stop);
        for I := 0 to Stop - 1 do
          ResultArr[I] := IntToStr(I);
      end
      else if Length(Args) >= 2 then
      begin
        Start := StrToIntDef(Args[0], 0);
        Stop := StrToIntDef(Args[1], 0);
        Step := 1;
        if Length(Args) >= 3 then
          Step := StrToIntDef(Args[2], 1);

        SetLength(ResultArr, (Stop - Start) div Step);
        for I := 0 to High(ResultArr) do
          ResultArr[I] := IntToStr(Start + I * Step);
      end;

      Result := ArrayToString(ResultArr);
    end);

  RegisterFunction('str',
    function(const Args: array of string): string
    begin
      if Length(Args) > 0 then
        Result := Args[0]
      else
        Result := '';
    end);

  RegisterFunction('int',
    function(const Args: array of string): string
    begin
      if Length(Args) > 0 then
        Result := IntToStr(StrToIntDef(Args[0], 0))
      else
        Result := '0';
    end);

  RegisterFunction('float',
    function(const Args: array of string): string
    begin
      if Length(Args) > 0 then
        Result := FloatToStr(StrToFloatDef(Args[0], 0))
      else
        Result := '0.0';
    end);
end;

function TPythonLikeScriptEngine.ParseArray(
  const ArrayStr: string): TScriptArray;
begin

end;

function TPythonLikeScriptEngine.ParseLine(var Context: TScriptContext;
  const Line: string): Boolean;
begin

end;

function TPythonLikeScriptEngine.ParsePythonBlock(var Context: TScriptContext;
  StartLine: Integer; const BlockType: string): Integer;
begin

end;

procedure TPythonLikeScriptEngine.RegisterFunction(const Name: string;
  Func: TScriptFunction);
begin

end;

// Остальные методы (IsNumber, IsBoolean, Get/SetVariableValue и т.д.)
// остаются аналогичными предыдущей версии, но с поддержкой Python-синтаксиса

function TPythonLikeScriptEngine.ParsePythonStyleLine(var Context: TScriptContext; const Line: string): Boolean;
var
  CleanLine, Command, Params, VarName, Value: string;
  ParamList: TArray<string>;
  I: Integer;
  Func: TScriptFunction;
  DotPos: Integer;
  ObjName, MemberName: string;
begin
  Result := True;
  CleanLine := Line.Trim;

  if CleanLine.IsEmpty or CleanLine.StartsWith('#') then
    Exit;

  // Обработка условий Python-style (отступы вместо end)
  if CleanLine.StartsWith('if ') or CleanLine.StartsWith('elif ') or
     CleanLine.StartsWith('else:') or CleanLine.StartsWith('while ') or
     CleanLine.StartsWith('for ') then
  begin
    // Обработка блоков через отступы будет в ExecuteBlock
    Exit(True);
  end;

  // Обработка присваивания
  if CleanLine.Contains('=') then
  begin
    VarName := CleanLine.Split(['='])[0].Trim;
    Value := CleanLine.Split(['='])[1].Trim;

    // Проверяем, не является ли это присваиванием свойства объекта
    if VarName.Contains('.') then
    begin
      DotPos := Pos('.', VarName);
      ObjName := Copy(VarName, 1, DotPos - 1);
      MemberName := Copy(VarName, DotPos + 1, Length(VarName));

      var ObjVar: TScriptVariable;
      if Context.Variables.TryGetValue(ObjName, ObjVar) and (ObjVar.VarType = vtObject) then
      begin
        SetObjectProperty(ObjVar.ObjectInstance, MemberName, EvaluateExpression(Context, Value));
        Exit;
      end
      else if FGlobalVariables.TryGetValue(ObjName, ObjVar) and (ObjVar.VarType = vtObject) then
      begin
        SetObjectProperty(ObjVar.ObjectInstance, MemberName, EvaluateExpression(Context, Value));
        Exit;
      end;
    end;

    Value := EvaluateExpression(Context, Value);
    SetVariableValue(Context, VarName, Value);
    Exit;
  end;

  // Обработка вызовов функций/методов
  if CleanLine.Contains('(') and CleanLine.Contains(')') then
  begin
    Command := CleanLine.Split(['('])[0].Trim;
    Params := Copy(CleanLine, Pos('(', CleanLine) + 1, Length(CleanLine));
    Params := Copy(Params, 1, Pos(')', Params) - 1);

    // Проверяем, не является ли это вызовом метода объекта
    if Command.Contains('.') then
    begin
      DotPos := Pos('.', Command);
      ObjName := Copy(Command, 1, DotPos - 1);
      MemberName := Copy(Command, DotPos + 1, Length(Command));

      var ObjVar: TScriptVariable;
      if Context.Variables.TryGetValue(ObjName, ObjVar) and (ObjVar.VarType = vtObject) then
      begin
        ParamList := Params.Split([',']);
        for I := 0 to High(ParamList) do
          ParamList[I] := EvaluateExpression(Context, ParamList[I].Trim);

        var ResultStr := CallObjectMethod(ObjVar.ObjectInstance, MemberName, ParamList);
        if ResultStr <> 'None' then
          FOutput.Add(ResultStr);
        Exit;
      end
      else if FGlobalVariables.TryGetValue(ObjName, ObjVar) and (ObjVar.VarType = vtObject) then
      begin
        ParamList := Params.Split([',']);
        for I := 0 to High(ParamList) do
          ParamList[I] := EvaluateExpression(Context, ParamList[I].Trim);

        var ResultStr := CallObjectMethod(ObjVar.ObjectInstance, MemberName, ParamList);
        if ResultStr <> 'None' then
          FOutput.Add(ResultStr);
        Exit;
      end;
    end;

    // Обычный вызов функции
    ParamList := Params.Split([',']);
    for I := 0 to High(ParamList) do
      ParamList[I] := EvaluateExpression(Context, ParamList[I].Trim);

    if FFunctions.TryGetValue(Command, Func) then
      Func(ParamList)
    else
      FOutput.Add('Error: Unknown function "' + Command + '"');
  end
  else if CleanLine.Contains('.') then
  begin
    // Доступ к свойствам без вызова метода
    DotPos := Pos('.', CleanLine);
    ObjName := Copy(CleanLine, 1, DotPos - 1);
    MemberName := Copy(CleanLine, DotPos + 1, Length(CleanLine));

    var ObjVar: TScriptVariable;
    if Context.Variables.TryGetValue(ObjName, ObjVar) and (ObjVar.VarType = vtObject) then
    begin
      var PropValue := GetObjectProperty(ObjVar.ObjectInstance, MemberName);
      if PropValue <> 'None' then
        FOutput.Add(PropValue);
    end
    else if FGlobalVariables.TryGetValue(ObjName, ObjVar) and (ObjVar.VarType = vtObject) then
    begin
      var PropValue := GetObjectProperty(ObjVar.ObjectInstance, MemberName);
      if PropValue <> 'None' then
        FOutput.Add(PropValue);
    end;
  end;
end;

function TPythonLikeScriptEngine.EvaluateCondition(var Context: TScriptContext;
  const Condition: string): Boolean;
begin

end;

function TPythonLikeScriptEngine.EvaluateExpression(var Context: TScriptContext;
  const Expr: string): string;
begin

end;

function TPythonLikeScriptEngine.ExecuteBlock(var Context: TScriptContext;
  StartLine: Integer; const EndCondition: string): Integer;
begin

end;

function TPythonLikeScriptEngine.ExecuteScript(const ScriptCode: string): string;
var
  Context: TScriptContext;
begin
  FOutput.Clear;
  Context := TScriptContext.Create;
  try
    FScriptLines := ScriptCode.Split([sLineBreak]);
    FCurrentLine := 0;

    try
      while FCurrentLine < Length(FScriptLines) do
      begin
        if not ParsePythonStyleLine(Context, FScriptLines[FCurrentLine]) then
          Break;
        Inc(FCurrentLine);
      end;

      Result := 'Script executed successfully';
    except
      on E: Exception do
        Result := 'Error at line ' + IntToStr(FCurrentLine + 1) + ': ' + E.Message;
    end;

  finally
    Context.Free;
  end;
end;

function TPythonLikeScriptEngine.ExecuteScriptFile(
  const FileName: string): string;
begin

end;

procedure TPythonLikeScriptEngine.SetGlobalArray(const Name: string;
  const Value: TScriptArray);
begin

end;

// Реализации остальных методов (EvaluateExpression, EvaluateCondition и т.д.)
// аналогичны предыдущей версии, но адаптированы под Python-синтаксис

procedure TPythonLikeScriptEngine.SetGlobalObject(const Name: string; Obj: TObject);
var
  VarRec: TScriptVariable;
begin
  VarRec.Name := Name;
  VarRec.ObjectInstance := Obj;
  VarRec.VarType := vtObject;
  VarRec.Value := 'Object:' + Obj.ClassName;

  FGlobalVariables.AddOrSetValue(Name, VarRec);
end;

procedure TPythonLikeScriptEngine.SetGlobalVariable(const Name, Value: string);
begin

end;

// ... остальные методы SetGlobalVariable, ExecuteScriptFile и т.д.

end.
