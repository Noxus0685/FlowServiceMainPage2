unit uDebugLog;

interface

procedure InitDebugLog;
procedure DebugLog(const AText: string);

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils;

var
  GDebugLogFile: string;
  GDebugLogLock: TObject;

procedure InitDebugLog;
var
  LogDir: string;
begin
  try
    LogDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Logs');
    ForceDirectories(LogDir);
    GDebugLogFile := TPath.Combine(LogDir, 'debug.log');
    TFile.WriteAllText(GDebugLogFile, '', TEncoding.UTF8);
  except
    GDebugLogFile := '';
  end;
end;

procedure DebugLog(const AText: string);
var
  Line: string;
begin
  if GDebugLogFile = '' then
    Exit;

  Line := FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now) + ' ' +
    StringReplace(AText, #13#10, ' | ', [rfReplaceAll]) + sLineBreak;
  TMonitor.Enter(GDebugLogLock);
  try
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
