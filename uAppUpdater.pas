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
  System.Classes,
  System.Hash,
  System.IOUtils,
  System.JSON,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.SysUtils,
  System.UITypes,
  uAppVersion,
  Winapi.ShellAPI,
  Winapi.Windows;

const
  GITHUB_LATEST_RELEASE_URL = 'https://api.github.com/repos/makspyankov150796-design/FlowServiceMainPage2-Updates/releases/latest';
  GITHUB_USER_AGENT = 'FlowServiceMainPage2-Updater';
  UPDATE_TEMP_FOLDER = 'FlowServiceMainPage2_Update';
  UPDATER_EXE_NAME = 'Updater.exe';

type
  TReleaseAsset = record
    Name: string;
    Url: string;
    Digest: string;
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
  IsZip: Boolean;
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

    IsZip := SameText(ExtractFileExt(Candidate.Name), '.zip') and (Candidate.Url <> '');
    if not IsZip then
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

procedure DownloadFile(const AUrl, AFileName: string);
var
  Client: TNetHTTPClient;
  Response: IHTTPResponse;
  Stream: TFileStream;
begin
  Client := TNetHTTPClient.Create(nil);
  try
    Client.HandleRedirects := True;
    Client.CustomHeaders['User-Agent'] := GITHUB_USER_AGENT;
    Client.CustomHeaders['Accept'] := 'application/octet-stream';
    Stream := TFileStream.Create(AFileName, fmCreate);
    try
      Response := Client.Get(AUrl, Stream);
      if Response.StatusCode <> 200 then
        raise Exception.CreateFmt('HTTP %d: %s', [Response.StatusCode, Response.StatusText]);
    finally
      Stream.Free;
    end;
  finally
    Client.Free;
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

procedure RunUpdaterAndClose(const AZipFile: string);
var
  ProgramFolder: string;
  MainExeName: string;
  UpdaterPath: string;
  Params: string;
begin
  ProgramFolder := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  MainExeName := ExtractFileName(ParamStr(0));
  UpdaterPath := FindUpdaterPath(ProgramFolder);

  if UpdaterPath = '' then
    raise Exception.Create('Updater.exe не найден в папке программы или папке проекта.');

  Params := QuoteParam(AZipFile) + ' ' + QuoteParam(ProgramFolder) + ' ' +
    QuoteParam(MainExeName) + ' ' + IntToStr(GetCurrentProcessId);
  if ShellExecute(0, 'open', PChar(UpdaterPath), PChar(Params), PChar(ProgramFolder), SW_SHOWNORMAL) <= 32 then
    raise Exception.Create('Не удалось запустить Updater.exe.');

  Application.Terminate;
end;

procedure TAppUpdater.CheckAndRunUpdate;
var
  JsonText: string;
  JsonValue: TJSONValue;
  Release: TJSONObject;
  TagName: string;
  LatestVersion: string;
  Asset: TReleaseAsset;
  TempFolder: string;
  ZipFile: string;
begin
  try
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

      if CompareVersions(LatestVersion, APP_VERSION) <= 0 then
      begin
        ShowMessage('Установлена актуальная версия.');
        Exit;
      end;

      if MessageDlg('Доступна новая версия ' + LatestVersion + '. Установить обновление?',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
        Exit;

      if not SelectZipAsset(Release, Asset) then
      begin
        ShowMessage('В последнем релизе не найден ZIP-файл обновления.');
        Exit;
      end;

      TempFolder := TPath.Combine(TPath.GetTempPath, UPDATE_TEMP_FOLDER);
      TDirectory.CreateDirectory(TempFolder);
      ZipFile := TPath.Combine(TempFolder, Asset.Name);
      if TFile.Exists(ZipFile) then
        TFile.Delete(ZipFile);

      try
        DownloadFile(Asset.Url, ZipFile);
      except
        on E: Exception do
        begin
          ShowMessage('Не удалось скачать обновление.' + sLineBreak + E.Message);
          Exit;
        end;
      end;

      if (not TFile.Exists(ZipFile)) or (TFile.GetSize(ZipFile) <= 0) or (not IsZipFile(ZipFile)) then
      begin
        ShowMessage('Не удалось скачать обновление. Загруженный файл не является ZIP-архивом.');
        Exit;
      end;

      if not VerifySha256IfAvailable(ZipFile, Asset.Digest) then
      begin
        ShowMessage('Не удалось скачать обновление. Контрольная сумма ZIP не совпадает.');
        Exit;
      end;

      RunUpdaterAndClose(ZipFile);
    finally
      JsonValue.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Не удалось проверить обновление.' + sLineBreak + E.Message);
  end;
end;

initialization
  AppUpdater := TAppUpdater.Create;

finalization
  AppUpdater.Free;

end.
