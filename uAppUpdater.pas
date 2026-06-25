unit uAppUpdater;

interface

type
  TAppUpdater = class
  public
    procedure CheckAndRunUpdate;
  end;

var
  AppUpdater: TAppUpdater;

implementation

uses
  FMX.Dialogs,
  FMX.Forms,
  System.IOUtils,
  System.SysUtils,
  Winapi.ShellAPI,
  Winapi.Windows;

const
  UPDATER_EXE_NAME = 'Updater.exe';

function QuoteParam(const AValue: string): string;
begin
  Result := '"' + AValue.Replace('"', '\"') + '"';
end;

function FindUpdaterPath(const AProgramFolder: string): string;
var
  Candidate: string;
  ParentFolder: string;
  I: Integer;
begin
  Candidate := TPath.Combine(AProgramFolder, UPDATER_EXE_NAME);
  if TFile.Exists(Candidate) then
    Exit(Candidate);

  Candidate := TPath.Combine(TDirectory.GetCurrentDirectory, UPDATER_EXE_NAME);
  if TFile.Exists(Candidate) then
    Exit(Candidate);

  ParentFolder := ExcludeTrailingPathDelimiter(AProgramFolder);
  for I := 1 to 4 do
  begin
    ParentFolder := ExtractFileDir(ParentFolder);
    if ParentFolder = '' then
      Break;

    Candidate := TPath.Combine(ParentFolder, UPDATER_EXE_NAME);
    if TFile.Exists(Candidate) then
      Exit(Candidate);
  end;

  Result := '';
end;

procedure TAppUpdater.CheckAndRunUpdate;
var
  ProgramFolder: string;
  MainExeName: string;
  UpdaterPath: string;
  Params: string;
begin
  try
    ProgramFolder := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
    MainExeName := ExtractFileName(ParamStr(0));
    UpdaterPath := FindUpdaterPath(ProgramFolder);
    if UpdaterPath = '' then
      raise Exception.Create('Updater.exe не найден в папке программы или папке проекта.');

    Params := QuoteParam(ProgramFolder) + ' ' + QuoteParam(MainExeName) + ' ' + IntToStr(GetCurrentProcessId);
    if ShellExecute(0, 'open', PChar(UpdaterPath), PChar(Params), PChar(ProgramFolder), SW_SHOWNORMAL) <= 32 then
      raise Exception.Create('Не удалось запустить Updater.exe.');

    Application.Terminate;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

initialization
  AppUpdater := TAppUpdater.Create;

finalization
  AppUpdater.Free;

end.
