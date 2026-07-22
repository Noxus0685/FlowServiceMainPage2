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
  Header: string;
begin
  try
    GDebugLogFile := TPath.Combine(
      ExtractFilePath(ParamStr(0)),
      'MAIN2_UPDATE_COMMENTS.md');

    if not TFile.Exists(GDebugLogFile) then
    begin
      Header := '# MAIN2 runtime logs' + sLineBreak + sLineBreak;
      TFile.WriteAllText(GDebugLogFile, Header, TEncoding.UTF8);
    end;

    TFile.AppendAllText(
      GDebugLogFile,
      '## Запуск ' + FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now) +
        sLineBreak + sLineBreak,
      TEncoding.UTF8);
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

  Line := '- ' + FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now) + ' — ' +
    StringReplace(AText, #13#10, ' | ', [rfReplaceAll]) + sLineBreak;

  TMonitor.Enter(GDebugLogLock);
  try
    try
      TFile.AppendAllText(GDebugLogFile, Line, TEncoding.UTF8);
    except
      { Запись лога не должна мешать работе программы. }
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
