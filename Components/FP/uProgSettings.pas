unit uProgSettings;
{ ===== Класс TProgSettings =====
Класс настроек программы. Позволяет загружать и сохранять настройки в файл. 19.04.2020 Бахтин Н.А.
}

interface

uses System.SysUtils,System.Types,IniFiles,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat;

  const
  cBoolName:array[boolean] of String=('FALSE','TRUE');

type

 TPrintMessageProc=procedure(AMessage:String) of Object;
 TProgSettings = class
 private
    FDataBase:TFDTable;
    FOnPrintMessage: TPrintMessageProc;
   function GetVal(Param: String): string;
   procedure SetVal(Param: String; const Value: string);
    function GetDB: TFDTable;
    procedure SetFDataBase(const Value: TFDTable);
    procedure SetOnPrintMessage(const Value: TPrintMessageProc);
 public

   function GetValue(Param: String;DefValue:String=''): String;overload;
   procedure SetValue(Param: String; const Val: String);overload;
   function GetValue(Param: String;DefValue:double): Double;overload;
   procedure SetValue(Param: String; const Val: double);overload;
   function GetValue(Param: String;DefValue:integer): integer;overload;
   function GetValue(Param: String; DefValue: longword): longword;overload;
   procedure SetValue(Param: String; const Val: integer);overload;
   function GetValue(Param: String;DefValue:boolean=false): boolean;overload;
   procedure SetValue(Param: String; const Val: boolean);overload;
   constructor Create(table: TFDTable);
   procedure ExportToFile(const FileName: String);
   procedure ImportFromFile(const FileName: String);
   property Value[Param:String]:string read GetVal write SetVal;
   property DB:TFDTable read GetDB write SetFDataBase;
   property OnPrintMessage:TPrintMessageProc read FOnPrintMessage write SetOnPrintMessage;
 end;

implementation

uses FMXHelper;

constructor TProgSettings.Create(table: TFDTable);
begin
  FDataBase:=table;
end;

function TProgSettings.GetDB: TFDTable;
begin
   result:=FDataBase;
end;

function TProgSettings.GetValue(Param: String; DefValue: double): Double;
var s:String;
begin
  s:=Value[Param];
  if s='' then result:=DefValue
  else result:=StrToFloatDef(CP(s),DefValue);
end;

function TProgSettings.GetValue(Param: String; DefValue: integer): integer;
var s:String;
begin
  s:=Value[Param];
  if s='' then result:=DefValue
  else result:=StrToIntDef(s,DefValue);
end;

function TProgSettings.GetValue(Param: String; DefValue: longword): longword;
var s:String;
begin
  s:=Value[Param];
  if s='' then result:=DefValue
  else result:=StrToIntDef(s,DefValue);
end;

function TProgSettings.GetValue(Param: String; DefValue: boolean): boolean;
var s:String;
begin
  s:=Value[Param];
  if s='' then result:=DefValue
  else result:=cBoolName[true]=s;
end;

function TProgSettings.GetValue(Param, DefValue: String): String;
var s:String;
begin
  s:=Value[Param];
  if s='' then result:=DefValue
  else result:=s;
end;

function TProgSettings.GetVal(Param: String): string;
begin
  Result := '';
  //Загрузка настроек из базы данных
  if not FDataBase.Active then FDataBase.Active:=True;
  if FDataBase.Locate('KeyName',Param,[]) then
    Result:= FDataBase.FieldValues['KeyValue']
end;


procedure TProgSettings.SetFDataBase(const Value: TFDTable);
begin
  FDataBase:=Value;
end;

procedure TProgSettings.SetOnPrintMessage(const Value: TPrintMessageProc);
begin
  FOnPrintMessage := Value;
end;

procedure TProgSettings.SetValue(Param: String; const Val: double);
begin
   Value[Param]:=FloatToStr(Val);
end;

procedure TProgSettings.SetValue(Param: String; const Val: integer);
begin
   Value[Param]:=IntToStr(Val);
end;

procedure TProgSettings.SetValue(Param: String; const Val: boolean);
begin
   Value[Param]:=cBoolName[Val];
end;

procedure TProgSettings.SetValue(Param: String; const Val: String);
begin
   Value[Param]:=Val;
end;

procedure TProgSettings.SetVal(Param: String; const Value: string);
begin
  if not FDataBase.Active then FDataBase.Active:=True;

  //Сохранение настроек в базу данных
  if FDataBase.Locate('KeyName',Param,[]) then begin
    FDataBase.Edit;
    FDataBase.FieldValues['KeyValue']:= Value;
    try
      FDataBase.Post;
    except
      on e:Exception do
      begin
          if Assigned(OnPrintMessage) then
             OnPrintMessage('Exception:'+e.Message);
      end;
    end;
  end
  else begin
    FDataBase.Append;
    FDataBase.FieldValues['KeyName']:=Param;
    FDataBase.FieldValues['KeyValue']:= Value;
    try
      FDataBase.Post;
    except
      on e:Exception do
      begin
          if Assigned(OnPrintMessage) then
             OnPrintMessage('SetValue exception:'+e.Message);
      end;
    end;
  end;
end;


procedure TProgSettings.ExportToFile(const FileName: String);
var
  MyIniFile: TIniFile;
begin
  MyIniFile := TIniFile.Create(FileName);
  try
    //Сохранение настроек не в текстовый файл, а в базу данных
    if FDataBase.Active then
    begin
       FDataBase.First;
       while not FDataBase.Eof do
       begin
          MyIniFile.WriteString('Settings',FDataBase.FieldByName('KeyName').AsString,FDataBase.FieldByName('KeyValue').AsString);
          FDataBase.Next;
       end;
    end;
  finally
    MyIniFile.Free;
  end;
end;

procedure TProgSettings.ImportFromFile(const FileName: String);
var
  MyIniFile: TIniFile;
  value:String;
begin
  MyIniFile := TIniFile.Create(FileName);
  try
    //Сохранение настроек не в текстовый файл, а в базу данных
    if FDataBase.Active then
    begin
       FDataBase.First;
       while not FDataBase.Eof do
       begin
          value:=MyIniFile.ReadString('Settings',FDataBase.FieldByName('KeyName').AsString,'');
          if Value<>'' then
          begin
            FDataBase.Edit;
            FDataBase.FieldByName('KeyValue').AsString:=Value;
            FDataBase.Post;
           end;
          FDataBase.Next;
       end;
    end;
  finally
    MyIniFile.Free;
  end;
end;


end.

