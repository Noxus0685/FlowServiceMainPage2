program Updater;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.DateUtils,
  System.IOUtils,
  System.SysUtils,
  System.Zip,
  Winapi.ShellAPI,
  Winapi.Windows;


function IsZipFile(const AFileName: string): Boolean;
var
  Stream: TFileStream;
  Header: array[0..1] of Byte;
begin
  Result := False;
  if (not TFile.Exists(AFileName)) or (TFile.GetSize(AFileName) < 4) then
    Exit;

  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    if Stream.Read(Header, SizeOf(Header)) <> SizeOf(Header) then
      Exit;
    Result := (Header[0] = Ord('P')) and (Header[1] = Ord('K'));
  finally
    Stream.Free;
  end;
end;

function IsExcludedFromUpdate(const ARelativeName: string): Boolean;
var
  Ext: string;
  LowerName: string;
begin
  LowerName := LowerCase(ARelativeName.Replace('/', PathDelim));
  Ext := LowerCase(ExtractFileExt(LowerName));

  Result := (Ext = '.db') or (Ext = '.db-wal') or (Ext = '.db-shm') or
    (Ext = '.ini') or (Ext = '.log') or
    LowerName.StartsWith('measurements' + PathDelim) or
    LowerName.StartsWith('results' + PathDelim) or
    LowerName.StartsWith('user_settings' + PathDelim) or
    LowerName.StartsWith('settings' + PathDelim);
end;

function SafeTargetPath(const AProgramDir, AZipName: string; out ATargetPath: string): Boolean;
var
  RelativeName: string;
  FullProgramDir: string;
  FullTargetPath: string;
begin
  RelativeName := AZipName.Replace('/', PathDelim);
  if (RelativeName = '') or RelativeName.EndsWith(PathDelim) or TPath.IsPathRooted(RelativeName) then
    Exit(False);

  FullProgramDir := IncludeTrailingPathDelimiter(TPath.GetFullPath(AProgramDir));
  FullTargetPath := TPath.GetFullPath(TPath.Combine(FullProgramDir, RelativeName));
  Result := FullTargetPath.StartsWith(FullProgramDir, True);
  if Result then
    ATargetPath := FullTargetPath;
end;

function CanOpenExclusive(const AFileName: string): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  if not TFile.Exists(AFileName) then
    Exit(True);

  try
    Stream := TFileStream.Create(AFileName, fmOpenReadWrite or fmShareExclusive);
    try
      Result := True;
    finally
      Stream.Free;
    end;
  except
    Result := False;
  end;
end;

procedure WaitForMainExe(const AProgramDir, AMainExeName: string; const AMainProcessId: Cardinal);
var
  MainExePath: string;
  Deadline: TDateTime;
  ProcessHandle: THandle;
begin
  if AMainProcessId <> 0 then
  begin
    ProcessHandle := OpenProcess(SYNCHRONIZE, False, AMainProcessId);
    if ProcessHandle <> 0 then
    try
      WaitForSingleObject(ProcessHandle, INFINITE);
      Exit;
    finally
      CloseHandle(ProcessHandle);
    end;
  end;

  MainExePath := TPath.Combine(AProgramDir, AMainExeName);
  Deadline := IncSecond(Now, 5);

  while (Now < Deadline) and (not CanOpenExclusive(MainExePath)) do
    Sleep(50);

  if not CanOpenExclusive(MainExePath) then
    raise Exception.Create('Основная программа не закрылась за отведенное время.');
end;

procedure ApplyUpdate(const AZipFile, AProgramDir: string);
var
  Zip: TZipFile;
  I: Integer;
  ZipName: string;
  TargetPath: string;
begin
  Zip := TZipFile.Create;
  try
    Zip.Open(AZipFile, zmRead);
    for I := 0 to Zip.FileCount - 1 do
    begin
      ZipName := Zip.FileNames[I];
      if IsExcludedFromUpdate(ZipName) then
        Continue;
      if not SafeTargetPath(AProgramDir, ZipName, TargetPath) then
        Continue;

      TDirectory.CreateDirectory(ExtractFilePath(TargetPath));
      if TFile.Exists(TargetPath) then
        TFile.Delete(TargetPath);
      Zip.Extract(ZipName, AProgramDir, True);
    end;
  finally
    Zip.Free;
  end;
end;

procedure StartMainExe(const AProgramDir, AMainExeName: string);
var
  MainExePath: string;
begin
  MainExePath := TPath.Combine(AProgramDir, AMainExeName);
  ShellExecute(0, 'open', PChar(MainExePath), nil, PChar(AProgramDir), SW_SHOWNORMAL);
end;

var
  ZipFile: string;
  ProgramDir: string;
  MainExeName: string;
  MainProcessId: Cardinal;
begin
  try
    if ParamCount < 3 then
      raise Exception.Create('Usage: Updater.exe <zip> <program_dir> <main_exe>');

    ZipFile := ParamStr(1);
    ProgramDir := IncludeTrailingPathDelimiter(ParamStr(2));
    MainExeName := ParamStr(3);
    MainProcessId := 0;
    if ParamCount >= 4 then
      MainProcessId := StrToIntDef(ParamStr(4), 0);

    if not TFile.Exists(ZipFile) then
      raise Exception.Create('ZIP-файл обновления не найден.');
    if not IsZipFile(ZipFile) then
      raise Exception.Create('Файл обновления не является ZIP-архивом. Скачайте обновление повторно.');
    if not TDirectory.Exists(ProgramDir) then
      raise Exception.Create('Папка программы не найдена.');
    if MainExeName = '' then
      raise Exception.Create('Не указано имя основной программы.');

    WaitForMainExe(ProgramDir, MainExeName, MainProcessId);
    ApplyUpdate(ZipFile, ProgramDir);
    StartMainExe(ProgramDir, MainExeName);
  except
    on E: Exception do
    begin
      Writeln('Update failed: ' + E.Message);
      Sleep(5000);
    end;
  end;
end.
