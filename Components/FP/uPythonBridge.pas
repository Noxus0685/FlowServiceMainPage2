unit uPythonBridge;

interface

uses
  System.SysUtils, System.Classes, PythonEngine,
  FMX.Forms, FMX.Types, System.Generics.Collections, FMX.Dialogs;

type
  TAppFunction = reference to function(const Args: array of string): string;

  TPythonBridge = class
  private
    FPythonEngine: TPythonEngine;
    FPythonModule: TPythonModule;
    FRegisteredFunctions: TDictionary<string, TAppFunction>;

    procedure SetupPythonEngine;
    procedure RegisterInternalFunctions;

    function GetDeviceListFunc(const Args: array of string): string;
    function CalculateDataFunc(const Args: array of string): string;

    function GetPythonDllName: string;
    function GetDefaultPythonPath: string;
    procedure SetPythonEngine(const Value: TPythonEngine);
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterFunction(const Name: string; Func: TAppFunction);
    function ExecuteScript(const ScriptCode: string): string;
    function ExecuteScriptFile(const FileName: string): string;
    function CallFunction(const FunctionName: string;
      const Args: array of string): string;

    function IsPythonAvailable: Boolean;
    function GetPythonInfo: string;
    property PythonEngine: TPythonEngine read FPythonEngine write SetPythonEngine;
  end;

// Функции для экспорта в Python
function PyGetDeviceData(Self, Args: PPyObject): PPyObject; cdecl;
function PySetDeviceValue(Self, Args: PPyObject): PPyObject; cdecl;
function PyShowMessage(Self, Args: PPyObject): PPyObject; cdecl;
function PyLogMessage(Self, Args: PPyObject): PPyObject; cdecl;

implementation

uses
  System.IOUtils
  {$IFDEF MSWINDOWS}, Winapi.Windows{$ENDIF}
  {$IFDEF LINUX}, Posix.Unistd{$ENDIF};

{ TPythonBridge }

function TPythonBridge.GetPythonDllName: string;
begin
  {$IFDEF MSWINDOWS}
    {$IFDEF WIN32}
      Result := 'python314.dll'; // 32-bit Windows
    {$ELSE}
      Result := 'python314.dll'; // 64-bit Windows
    {$ENDIF}
  {$ENDIF}

  {$IFDEF LINUX}
    {$IFDEF CPUARM32}
      Result := 'libpython3.14.so'; // ARM 32-bit Linux
    {$ELSE}
      {$IFDEF CPU32}
        Result := 'libpython3.14.so'; // x86 32-bit Linux
      {$ELSE}
        Result := 'libpython3.14.so'; // x64 Linux
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF MACOS}
    Result := 'libpython3.14.dylib'; // macOS
  {$ENDIF}
end;

function TPythonBridge.GetDefaultPythonPath: string;
begin
  {$IFDEF MSWINDOWS}
    {$IFDEF WIN32}
      Result := 'C:\Python314-32\';
    {$ELSE}
      Result := 'C:\Python314\';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF LINUX}
    Result := '/usr/lib/python3.14/';
    // Альтернативные пути для Linux
    if not DirectoryExists(Result) then
      Result := '/usr/lib/x86_64-linux-gnu/';
    if not DirectoryExists(Result) then
      Result := '/usr/lib/i386-linux-gnu/';
  {$ENDIF}

  {$IFDEF MACOS}
    Result := '/Library/Frameworks/Python.framework/Versions/3.14/';
  {$ENDIF}
end;

function TPythonBridge.IsPythonAvailable: Boolean;
begin
  Result := FPythonEngine.IsHandleValid;
end;

function TPythonBridge.GetPythonInfo: string;
var
  PlatformInfo: string;
begin
  {$IFDEF MSWINDOWS}
    {$IFDEF WIN32}
      PlatformInfo := 'Windows 32-bit';
    {$ELSE}
      PlatformInfo := 'Windows 64-bit';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF LINUX}
    {$IFDEF CPU32}
      PlatformInfo := 'Linux 32-bit';
    {$ELSE}
      PlatformInfo := 'Linux 64-bit';
    {$ENDIF}
  {$ENDIF}

  {$IFDEF MACOS}
    PlatformInfo := 'macOS';
  {$ENDIF}

  if IsPythonAvailable then
    Result := 'Python loaded - ' + PlatformInfo + ' - DLL: ' + FPythonEngine.DllName
  else
    Result := 'Python not available - ' + PlatformInfo;
end;

function TPythonBridge.GetDeviceListFunc(const Args: array of string): string;
begin
  Result := '{"devices": ["device1", "device2"]}';
end;

function TPythonBridge.CalculateDataFunc(const Args: array of string): string;
begin
  if Length(Args) >= 2 then
    Result := FloatToStr(StrToFloat(Args[0]) + StrToFloat(Args[1]))
  else
    Result := 'Error: Not enough arguments';
end;

constructor TPythonBridge.Create;
begin
  inherited;
  FRegisteredFunctions := TDictionary<string, TAppFunction>.Create;

  FPythonEngine := TPythonEngine.Create(nil);
  FPythonModule := TPythonModule.Create(nil);

  SetupPythonEngine;
  RegisterInternalFunctions;
end;

destructor TPythonBridge.Destroy;
begin
  FPythonModule.Free;
  FPythonEngine.Free;
  FRegisteredFunctions.Free;
  inherited;
end;

procedure TPythonBridge.SetPythonEngine(const Value: TPythonEngine);
begin
  FPythonEngine := Value;
end;

procedure TPythonBridge.SetupPythonEngine;
var
  PythonPaths: TArray<string>;
  I: Integer;
  FoundPython: Boolean;
begin
  // Настройка для разных платформ
  {$IFDEF MSWINDOWS}
    PythonPaths := [
      GetDefaultPythonPath,
      'C:\Program Files\Python314\',
      'C:\Program Files (x86)\Python314-32\',
      '.\',
      '.\Python\'
    ];
  {$ENDIF}

  {$IFDEF LINUX}
    PythonPaths := [
      GetDefaultPythonPath,
      '/usr/local/lib/python3.8/',
      '/usr/lib/python3.8/',
      '/usr/lib/x86_64-linux-gnu/',
      '/usr/lib/i386-linux-gnu/',
      './',
      './python/'
    ];
  {$ENDIF}

  {$IFDEF MACOS}
    PythonPaths := [
      GetDefaultPythonPath,
      '/usr/local/opt/python@3.8/Frameworks/Python.framework/Versions/3.8/',
      './',
      './Python/'
    ];
  {$ENDIF}

  FPythonEngine.DllName := GetPythonDllName;
  FPythonEngine.UseLastKnownVersion := False;
  FPythonEngine.PyFlags := [pfInteractive];

  FoundPython := False;

  // Пробуем найти Python в разных путях
  for I := 0 to High(PythonPaths) do
  begin
    if DirectoryExists(PythonPaths[I]) then
    begin
      FPythonEngine.DllPath := PythonPaths[I];
      try
        FPythonEngine.LoadDll;
        FoundPython := True;
        Break;
      except
        // Пробуем следующий путь
      end;
    end;
  end;

  if not FoundPython then
  begin
    // Последняя попытка - автоопределение
    FPythonEngine.UseLastKnownVersion := True;
    try
      FPythonEngine.LoadDll;
      FoundPython := True;
    except
      on E: Exception do
      begin
        {$IFDEF MSWINDOWS}
          raise Exception.Create('Python not found. Please install Python 3.8 for ' +
            {$IFDEF WIN32}'Windows 32-bit'{$ELSE}'Windows 64-bit'{$ENDIF});
        {$ENDIF}
        {$IFDEF LINUX}
          raise Exception.Create('Python not found. Please install: sudo apt-get install python3.8 libpython3.8');
        {$ENDIF}
        {$IFDEF MACOS}
          raise Exception.Create('Python not found. Please install: brew install python@3.8');
        {$ENDIF}
      end;
    end;
  end;

  // Настройка модуля
  FPythonModule.Engine := FPythonEngine;
  FPythonModule.ModuleName := 'delphi_app';

  // Регистрация функций
  FPythonModule.AddMethod('get_device_data', @PyGetDeviceData, 'get_device_data(device_id) -> Get device data');
  FPythonModule.AddMethod('set_device_value', @PySetDeviceValue, 'set_device_value(device_id, value) -> Set device value');
  FPythonModule.AddMethod('show_message', @PyShowMessage, 'show_message(text) -> Show message dialog');
  FPythonModule.AddMethod('log_message', @PyLogMessage, 'log_message(text) -> Log message to application');
end;

procedure TPythonBridge.RegisterInternalFunctions;
begin
  RegisterFunction('GetDeviceList', GetDeviceListFunc);
  RegisterFunction('CalculateData', CalculateDataFunc);
end;

procedure TPythonBridge.RegisterFunction(const Name: string; Func: TAppFunction);
begin
  if FRegisteredFunctions.ContainsKey(Name) then
    FRegisteredFunctions[Name] := Func
  else
    FRegisteredFunctions.Add(Name, Func);
end;

function TPythonBridge.ExecuteScript(const ScriptCode: string): string;
begin
  if not IsPythonAvailable then
    Exit('Error: Python not available');

  try
    FPythonEngine.ExecString(AnsiString(ScriptCode));
    Result := 'Script executed successfully';
  except
    on E: Exception do
      Result := 'Error: ' + E.Message;
  end;
end;

function TPythonBridge.ExecuteScriptFile(const FileName: string): string;
var
  ScriptCode: string;
begin
  if not IsPythonAvailable then
    Exit('Error: Python not available');

  if not TFile.Exists(FileName) then
    Exit('Error: File not found');

  try
    ScriptCode := TFile.ReadAllText(FileName, TEncoding.UTF8);
    Result := ExecuteScript(ScriptCode);
  except
    on E: Exception do
      Result := 'Error reading file: ' + E.Message;
  end;
end;

function TPythonBridge.CallFunction(const FunctionName: string;
  const Args: array of string): string;
var
  Func: TAppFunction;
begin
  if FRegisteredFunctions.TryGetValue(FunctionName, Func) then
    try
      Result := Func(Args);
    except
      on E: Exception do
        Result := 'Error executing function: ' + E.Message;
    end
  else
    Result := 'Error: Function not found';
end;

// Реализация функций для Python
function PyGetDeviceData(Self, Args: PPyObject): PPyObject; cdecl;
var
  DeviceID: PAnsiChar;
  ResultStr: string;
begin
  with GetPythonEngine do
  begin
    if PyArg_ParseTuple(Args, 's:get_device_data', @DeviceID) <> 0 then
    begin
      ResultStr := 'Device data for ' + string(DeviceID);
      Result := PyUnicode_FromString(PAnsiChar(AnsiString(ResultStr)));
    end
    else
      Result := ReturnNone;
  end;
end;

function PySetDeviceValue(Self, Args: PPyObject): PPyObject; cdecl;
var
  DeviceID, Value: PAnsiChar;
begin
  with GetPythonEngine do
  begin
    if PyArg_ParseTuple(Args, 'ss:set_device_value', @DeviceID, @Value) <> 0 then
    begin
      Result := PyUnicode_FromString('Value set successfully');
    end
    else
      Result := ReturnNone;
  end;
end;

function PyShowMessage(Self, Args: PPyObject): PPyObject; cdecl;
var
  Text: PAnsiChar;
begin
  with GetPythonEngine do
  begin
    if PyArg_ParseTuple(Args, 's:show_message', @Text) <> 0 then
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          ShowMessage(string(Text));
        end
      );
      Result := PyUnicode_FromString('Message shown');
    end
    else
      Result := ReturnNone;
  end;
end;

function PyLogMessage(Self, Args: PPyObject): PPyObject; cdecl;
var
  Text: PAnsiChar;
begin
  with GetPythonEngine do
  begin
    if PyArg_ParseTuple(Args, 's:log_message', @Text) <> 0 then
    begin
      Result := PyUnicode_FromString(PAnsiChar('Message logged: ' + string(Text)));
    end
    else
      Result := ReturnNone;
  end;
end;

end.
