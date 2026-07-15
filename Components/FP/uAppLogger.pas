unit uAppLogger;

interface

uses
  System.SysUtils, System.IOUtils, FMX.Forms;

type
  TAppLogger = class
  private
    class function GetAppName: string;
    class function GetAppDataPath: string;
  public
    class procedure WriteLog(const Msg: string);
    class procedure WriteLogFmt(const Fmt: string; const Args: array of const);
  end;

implementation

{ TAppLogger }

class function TAppLogger.GetAppName: string;
begin
  // Пробуем получить название приложения
  {$IFDEF FMX}
  Result := Application.Title;
  {$ELSE}
  Result := Application.Title;
  {$ENDIF}

  // Если пустое, берем из имени исполняемого файла
  if Result = '' then
    Result := ChangeFileExt(ExtractFileName(ParamStr(0)), '');

  // Убираем расширение и проблемные символы
  Result := StringReplace(Result, ' ', '_', [rfReplaceAll]);
  Result := StringReplace(Result, PathDelim, '_', [rfReplaceAll]);

  // Если все еще пустое, используем значение по умолчанию
  if Result = '' then
    Result := 'MyApp';
end;

class function TAppLogger.GetAppDataPath: string;
var
  AppName: string;
begin
  AppName := GetAppName;

  {$IFDEF LINUX}
  Result := GetEnvironmentVariable('XDG_DATA_HOME');
  if Result = '' then
    Result := GetEnvironmentVariable('HOME') + '/.local/share';
  Result := Result + '/' + AppName;
  {$ELSE}
  Result := GetEnvironmentVariable('LOCALAPPDATA');
  if Result = '' then
    Result := GetEnvironmentVariable('APPDATA');
  if Result = '' then
    Result := GetEnvironmentVariable('TEMP');
  Result := Result + '\' + AppName;
  {$ENDIF}
end;

class procedure TAppLogger.WriteLog(const Msg: string);
var
  LogPath: string;
  LogDir: string;
  LogText: string;
begin
  LogPath := GetAppDataPath +
    {$IFDEF LINUX}'/app_log.txt'{$ELSE}'\app_log.txt'{$ENDIF};

  LogDir := ExtractFilePath(LogPath);
  LogText := Format('%s: %s', [DateTimeToStr(Now), Msg]) + sLineBreak;

  try
    if not TDirectory.Exists(LogDir) then
      TDirectory.CreateDirectory(LogDir);

    TFile.AppendAllText(LogPath, LogText, TEncoding.UTF8);
  except
    // Игнорируем ошибки записи лога
  end;
end;

class procedure TAppLogger.WriteLogFmt(const Fmt: string; const Args: array of const);
begin
  WriteLog(Format(Fmt, Args));
end;

end.
