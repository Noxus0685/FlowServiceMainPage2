program Updater;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.DateUtils,
  System.Hash,
  System.IOUtils,
  System.JSON,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.SysUtils,
  System.Zip,
  Winapi.ShellAPI,
  Winapi.Windows;

const
  GITHUB_LATEST_RELEASE_URL = 'https://api.github.com/repos/makspyankov150796-design/FlowServiceMainPage2-Updates/releases/latest';
  GITHUB_USER_AGENT = 'FlowServiceMainPage2-Updater';
  UPDATE_TEMP_FOLDER = 'FlowServiceMainPage2_Update';
  HTTP_CONNECTION_TIMEOUT_MS = 15000;
  HTTP_RESPONSE_TIMEOUT_MS = 120000;
  VERSION_FILE_NAME = 'version.txt';

type
  TReleaseAsset = record
    Name: string;
    Url: string;
    Digest: string;
  end;

procedure Info(const AText: string);
begin
  MessageBox(0, PChar(AText), 'FlowServiceMainPage2 Update', MB_OK or MB_ICONINFORMATION);
end;

procedure ErrorMsg(const AText: string);
begin
  MessageBox(0, PChar(AText), 'FlowServiceMainPage2 Update', MB_OK or MB_ICONERROR);
end;

function Confirm(const AText: string): Boolean;
begin
  Result := MessageBox(0, PChar(AText), 'FlowServiceMainPage2 Update', MB_YESNO or MB_ICONQUESTION) = IDYES;
end;

function NormalizeVersion(const AVersion: string): string;
begin
  Result := Trim(AVersion);
  if (Result <> '') and ((Result[1] = 'v') or (Result[1] = 'V')) then
    Delete(Result, 1, 1);
end;

function VersionPart(const AParts: TArray<string>; const AIndex: Integer): Integer;
begin
  Result := 0;
  if AIndex < Length(AParts) then
    TryStrToInt(AParts[AIndex], Result);
end;

function CompareVersions(const ALeft, ARight: string): Integer;
var
  LParts: TArray<string>;
  RParts: TArray<string>;
  I: Integer;
  LValue: Integer;
  RValue: Integer;
begin
  Result := 0;
  LParts := NormalizeVersion(ALeft).Split(['.']);
  RParts := NormalizeVersion(ARight).Split(['.']);
  for I := 0 to Max(Length(LParts), Length(RParts)) - 1 do
  begin
    LValue := VersionPart(LParts, I);
    RValue := VersionPart(RParts, I);
    if LValue > RValue then
      Exit(1);
    if LValue < RValue then
      Exit(-1);
  end;
end;

function GetJsonString(AObject: TJSONObject; const AName: string): string;
var
  LValue: TJSONValue;
begin
  Result := '';
  if AObject = nil then
    Exit;
  LValue := AObject.GetValue(AName);
  if LValue <> nil then
    Result := LValue.Value;
end;

function SelectZipAsset(ARelease: TJSONObject; out AAsset: TReleaseAsset): Boolean;
var
  Assets: TJSONArray;
  I: Integer;
  Obj: TJSONObject;
  Candidate: TReleaseAsset;
  IsPreferred: Boolean;
begin
  Result := False;
  AAsset.Name := '';
  AAsset.Url := '';
  AAsset.Digest := '';
  Assets := ARelease.GetValue<TJSONArray>('assets');
  if Assets = nil then
    Exit;
  for I := 0 to Assets.Count - 1 do
  begin
    Obj := Assets.Items[I] as TJSONObject;
    Candidate.Name := GetJsonString(Obj, 'name');
    Candidate.Url := GetJsonString(Obj, 'browser_download_url');
    Candidate.Digest := GetJsonString(Obj, 'digest');
    if (not SameText(ExtractFileExt(Candidate.Name), '.zip')) or (Candidate.Url = '') then
      Continue;
    IsPreferred := Candidate.Name.StartsWith('FlowServiceMainPage2_', True);
    if (not Result) or IsPreferred then
    begin
      AAsset := Candidate;
      Result := True;
      if IsPreferred then
        Exit;
    end;
  end;
end;

function DownloadString(const AUrl: string): string;
var
  Client: TNetHTTPClient;
  Response: IHTTPResponse;
begin
  Client := TNetHTTPClient.Create(nil);
  try
    Client.HandleRedirects := True;
    Client.ConnectionTimeout := HTTP_CONNECTION_TIMEOUT_MS;
    Client.ResponseTimeout := HTTP_RESPONSE_TIMEOUT_MS;
    Client.CustomHeaders['User-Agent'] := GITHUB_USER_AGENT;
    Client.CustomHeaders['Accept'] := 'application/vnd.github+json';
    Response := Client.Get(AUrl);
    if Response.StatusCode <> 200 then
      raise Exception.CreateFmt('HTTP %d: %s', [Response.StatusCode, Response.StatusText]);
    Result := Response.ContentAsString(TEncoding.UTF8);
  finally
    Client.Free;
  end;
end;

type
  TUpdateDownloader = class
  private
    procedure OnReceiveData(const Sender: TObject; AContentLength: Int64;
      AReadCount: Int64; var Abort: Boolean);
  public
    procedure DownloadFile(const AUrl, ALocalFile: string);
  end;

procedure TUpdateDownloader.OnReceiveData(const Sender: TObject;
  AContentLength: Int64; AReadCount: Int64; var Abort: Boolean);
begin
  if AContentLength > 0 then
    Write(#13 + Format('Downloaded: %.1f%%  %d / %d bytes',
      [AReadCount / AContentLength * 100, AReadCount, AContentLength]))
  else
    Write(#13 + Format('Downloaded: %d bytes', [AReadCount]));
end;

procedure TUpdateDownloader.DownloadFile(const AUrl, ALocalFile: string);
var
  Client: TNetHTTPClient;
  Response: IHTTPResponse;
  Stream: TFileStream;
begin
  Writeln('URL: ' + AUrl);
  Writeln('Local file: ' + ALocalFile);
  Writeln('Start download...');

  Client := TNetHTTPClient.Create(nil);
  try
    Client.HandleRedirects := True;
    Client.ConnectionTimeout := HTTP_CONNECTION_TIMEOUT_MS;
    Client.ResponseTimeout := HTTP_RESPONSE_TIMEOUT_MS;
    Client.CustomHeaders['User-Agent'] := GITHUB_USER_AGENT;
    Client.CustomHeaders['Accept'] := 'application/octet-stream';
    Client.OnReceiveData := OnReceiveData;

    Stream := TFileStream.Create(ALocalFile, fmCreate);
    try
      try
        Response := Client.Get(AUrl, Stream);
        Writeln;
        Writeln(Format('HTTP status: %d %s', [Response.StatusCode, Response.StatusText]));
        Writeln(Format('Saved size: %d bytes', [Stream.Size]));

        if Response.StatusCode <> 200 then
          raise Exception.CreateFmt('HTTP error: %d %s', [Response.StatusCode, Response.StatusText]);
        if Stream.Size <= 0 then
          raise Exception.Create('Downloaded file is empty');

        Writeln('Download completed.');
      except
        on E: Exception do
        begin
          Writeln;
          Writeln('ERROR: ' + E.ClassName + ': ' + E.Message);
          raise;
        end;
      end;
    finally
      Stream.Free;
    end;
  finally
    Client.Free;
  end;
end;

procedure DownloadFile(const AUrl, AFileName: string);
var
  Downloader: TUpdateDownloader;
begin
  Downloader := TUpdateDownloader.Create;
  try
    Downloader.DownloadFile(AUrl, AFileName);
  finally
    Downloader.Free;
  end;
end;

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

function VerifySha256IfAvailable(const AFileName, ADigest: string): Boolean;
var
  Expected: string;
  Actual: string;
begin
  Result := True;
  if not ADigest.StartsWith('sha256:', True) then
    Exit;
  Expected := LowerCase(Copy(ADigest, Length('sha256:') + 1, MaxInt));
  Actual := LowerCase(THashSHA2.GetHashStringFromFile(AFileName, THashSHA2.TSHA2Version.SHA256));
  Result := SameText(Expected, Actual);
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
    LowerName.StartsWith('backup_before_update_') or
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

function CanOpenExclusive(const AFileName: string): Boolean; forward;

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


function GetDefaultMainExeName: string;
begin
  Result := 'ProjectFornTest.exe';
end;

function GetVersionFileName(const AProgramDir: string): string;
begin
  Result := TPath.Combine(AProgramDir, VERSION_FILE_NAME);
end;

function TryReadLocalVersion(const AProgramDir: string; out AVersion: string): Boolean;
var
  VersionFile: string;
begin
  VersionFile := GetVersionFileName(AProgramDir);
  Result := TFile.Exists(VersionFile);
  if Result then
    AVersion := NormalizeVersion(TFile.ReadAllText(VersionFile, TEncoding.UTF8))
  else
    AVersion := '';
end;

procedure WriteLocalVersion(const AProgramDir, AVersion: string);
begin
  TFile.WriteAllText(GetVersionFileName(AProgramDir), NormalizeVersion(AVersion), TEncoding.UTF8);
end;

procedure CheckDownloadAndApply(const AProgramDir, AMainExeName: string; const AMainProcessId: Cardinal);
var
  JsonText: string;
  JsonValue: TJSONValue;
  Release: TJSONObject;
  TagName: string;
  LatestVersion: string;
  LocalVersion: string;
  Asset: TReleaseAsset;
  TempFolder: string;
  ZipFile: string;
begin
  JsonText := DownloadString(GITHUB_LATEST_RELEASE_URL);
  JsonValue := TJSONObject.ParseJSONValue(JsonText);
  try
    if not (JsonValue is TJSONObject) then
      raise Exception.Create('Некорректный ответ GitHub API.');
    Release := TJSONObject(JsonValue);
    TagName := GetJsonString(Release, 'tag_name');
    LatestVersion := NormalizeVersion(TagName);
    if LatestVersion = '' then
      raise Exception.Create('В релизе не указан tag_name.');
    if TryReadLocalVersion(AProgramDir, LocalVersion) and SameText(LatestVersion, LocalVersion) then
    begin
      if not Confirm('Установлена актуальная версия ' + LatestVersion + '. Переустановить эту версию?') then
      begin
        StartMainExe(AProgramDir, AMainExeName);
        Exit;
      end;
    end
    else if not Confirm('Доступна новая версия ' + LatestVersion + '. Установить обновление?') then
    begin
      StartMainExe(AProgramDir, AMainExeName);
      Exit;
    end;
    if not SelectZipAsset(Release, Asset) then
      raise Exception.Create('В последнем релизе не найден ZIP-файл обновления.');
    TempFolder := TPath.Combine(TPath.GetTempPath, UPDATE_TEMP_FOLDER);
    TDirectory.CreateDirectory(TempFolder);
    ZipFile := TPath.Combine(TempFolder, Asset.Name);
    if TFile.Exists(ZipFile) then
      TFile.Delete(ZipFile);
    DownloadFile(Asset.Url, ZipFile);
    if (not TFile.Exists(ZipFile)) or (TFile.GetSize(ZipFile) <= 0) or (not IsZipFile(ZipFile)) then
      raise Exception.Create('Не удалось скачать обновление. Загруженный файл не является ZIP-архивом.');
    if not VerifySha256IfAvailable(ZipFile, Asset.Digest) then
      raise Exception.Create('Не удалось скачать обновление. Контрольная сумма ZIP не совпадает.');
    WaitForMainExe(AProgramDir, AMainExeName, AMainProcessId);
    ApplyUpdate(ZipFile, AProgramDir);
    WriteLocalVersion(AProgramDir, LatestVersion);
    StartMainExe(AProgramDir, AMainExeName);
  finally
    JsonValue.Free;
  end;
end;

var
  ProgramDir: string;
  MainExeName: string;
  MainProcessId: Cardinal;
  ManualMode: Boolean;
begin
  ManualMode := ParamCount = 0;
  try
    if ParamCount >= 2 then
    begin
      ProgramDir := IncludeTrailingPathDelimiter(ParamStr(1));
      MainExeName := ParamStr(2);
    end
    else
    begin
      ProgramDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
      MainExeName := GetDefaultMainExeName;
    end;

    MainProcessId := 0;
    if ParamCount >= 3 then
      MainProcessId := StrToIntDef(ParamStr(3), 0);
    if not TDirectory.Exists(ProgramDir) then
      raise Exception.Create('Папка программы не найдена.');
    if MainExeName = '' then
      raise Exception.Create('Не найден основной EXE. Запустите Updater.exe из папки программы или передайте параметры.');
    CheckDownloadAndApply(ProgramDir, MainExeName, MainProcessId);
  except
    on E: Exception do
    begin
      Writeln('ERROR: ' + E.ClassName + ': ' + E.Message);
      ErrorMsg(E.Message);
      if (ProgramDir <> '') and (MainExeName <> '') then
        StartMainExe(ProgramDir, MainExeName);
    end;
  end;

  if ManualMode then
  begin
    Writeln('Press Enter...');
    Readln;
  end;
end.
