unit uDebugLog;

interface

procedure InitDebugLog;
procedure DebugLog(const AText: string);

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  uProjectSettings;

var
  GDebugLogFile: string;
  GDebugLogLock: TObject;

procedure SelectDebugLogFile;
var
  ProjectFileName: string;
  LogDir: string;
  NewLogFile: string;
begin
  try
    if TryGetProjectSettingsFileName(ProjectFileName) then
      LogDir := TPath.Combine(
        ExtractFileDir(ExpandFileName(ProjectFileName)), 'Logs')
    else
      LogDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Logs');

    ForceDirectories(LogDir);
    NewLogFile := TPath.Combine(LogDir, 'debug.log');
    if SameText(GDebugLogFile, NewLogFile) then
      Exit;

    GDebugLogFile := NewLogFile;
    TFile.WriteAllText(GDebugLogFile, '', TEncoding.UTF8);
  except
    GDebugLogFile := '';
  end;
end;

procedure InitDebugLog;
begin
  TMonitor.Enter(GDebugLogLock);
  try
    SelectDebugLogFile;
  finally
    TMonitor.Exit(GDebugLogLock);
  end;
end;

procedure DebugLog(const AText: string);
var
  Line: string;
begin
  Line := FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now) + ' ' +
    StringReplace(AText, #13#10, ' | ', [rfReplaceAll]) + sLineBreak;
  TMonitor.Enter(GDebugLogLock);
  try
    SelectDebugLogFile;
    if GDebugLogFile = '' then
      Exit;

    try
      TFile.AppendAllText(GDebugLogFile, Line, TEncoding.UTF8);
    except
      { Диагностика не должна мешать работе программы. }
    end;
  finally
    TMonitor.Exit(GDebugLogLock);
  end;
end;

initialization
  GDebugLogFile := '';
  GDebugLogLock := TObject.Create;

finalization
  FreeAndNil(GDebugLogLock);

end.
