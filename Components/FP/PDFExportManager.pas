unit PDFExportManager;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, FMX.Dialogs
  {$IFDEF MSWINDOWS}, Winapi.Windows, Winapi.ShellApi{$ENDIF}
  {$IFDEF POSIX}, Posix.Stdlib{$ENDIF};

type
  TPlatformHelper = class
  public
    class function IsBrowserAvailable: Boolean;
    class function GetBrowserPath: string;
    class function GetPDFOutputPath(const AFileName: string): string;
    class function ExecuteCommand(const ACommand: string): Boolean;
  end;

  TPDFExportManager = class
  public
    class function GeneratePDFFromHTML(const AHTMLContent: TStringList;
      const AFileName: string = ''): Boolean;
    class procedure SaveHTMLForExport(const AHTMLContent: TStringList;
      const AFileName: string = '');
  end;

implementation

{ TPlatformHelper }

class function TPlatformHelper.IsBrowserAvailable: Boolean;
begin
  Result := GetBrowserPath <> '';
end;

class function TPlatformHelper.GetBrowserPath: string;
var s:String;
begin
  {$IFDEF MSWINDOWS}
  // варианты для Chrome/Edge
  s:='C:\Program Files\Google\Chrome\Application\chrome.exe';
  if FileExists(s) then
    Exit(s);
  s:='C:\Program Files (x86)\Google\Chrome\Application\chrome.exe';
  if FileExists(s) then
    Exit(s);
  s:='C:\Program Files\Microsoft\Edge\Application\msedge.exe';
  if FileExists(s) then
    Exit(s);
  // Яндекс.Браузер (Windows)
  s:='C:\Users\' + GetEnvironmentVariable('USERNAME') + '\AppData\Local\Yandex\YandexBrowser\Application\browser.exe';
  if FileExists(s) then
    Exit(s);
   s:='C:\Program Files (x86)\Yandex\YandexBrowser\browser.exe';
  if FileExists(s) then
    Exit(s);
  {$ENDIF}

  {$IFDEF LINUX}
  // Резервные варианты
  if FileExists('/usr/bin/google-chrome') then
    Exit('/usr/bin/google-chrome');
  if FileExists('/usr/bin/google-chrome-stable') then
    Exit('/usr/bin/google-chrome-stable');
  if FileExists('/usr/bin/chromium-browser') then
    Exit('/usr/bin/chromium-browser');
  if FileExists('/usr/bin/chromium') then
    Exit('/usr/bin/chromium');
  if FileExists('/snap/bin/chromium') then
    Exit('/snap/bin/chromium');
  // Яндекс.Браузер (Linux)
  if FileExists('/usr/bin/yandex-browser') then
    Exit('/usr/bin/yandex-browser');
  if FileExists('/usr/bin/yandex-browser-stable') then
    Exit('/usr/bin/yandex-browser-stable');
  {$ENDIF}

  {$IFDEF MACOS}
  // Яндекс.Браузер (macOS)
  if FileExists('/Applications/Yandex.app/Contents/MacOS/Yandex') then
    Exit('/Applications/Yandex.app/Contents/MacOS/Yandex');
  // Резервные варианты
  if FileExists('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome') then
    Exit('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome');
  if FileExists('/Applications/Chromium.app/Contents/MacOS/Chromium') then
    Exit('/Applications/Chromium.app/Contents/MacOS/Chromium');
  {$ENDIF}

  Result := '';
end;


class function TPlatformHelper.GetPDFOutputPath(const AFileName: string): string;
begin
  {$IFDEF MSWINDOWS}
  Result := TPath.Combine(TPath.GetDocumentsPath, AFileName);
  {$ENDIF}

  {$IFDEF LINUX}
  Result := TPath.Combine(TPath.GetHomePath, 'Documents');
  ForceDirectories(Result);
  Result := TPath.Combine(Result, AFileName);
  {$ENDIF}

  {$IFDEF ANDROID}
  Result := TPath.Combine(TPath.GetSharedDocumentsPath, AFileName);
  {$ENDIF}

  {$IFDEF IOS}
  Result := TPath.Combine(TPath.GetDocumentsPath, AFileName);
  {$ENDIF}

  {$IFDEF MACOS}
  Result := TPath.Combine(TPath.GetDocumentsPath, AFileName);
  {$ENDIF}
end;

class function TPlatformHelper.ExecuteCommand(const ACommand: string): Boolean;
{$IFDEF MSWINDOWS}
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  CommandLine: string;
begin
  Result := False;
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  // Создаем копию командной строки
  CommandLine := ACommand;
  UniqueString(CommandLine);

  if CreateProcess(nil, PChar(CommandLine), nil, nil, False,
                   CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    try
      // Ждем завершения процесса (30 секунд)
      WaitForSingleObject(ProcessInfo.hProcess, 30000);
      Result := True;
    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;
{$ENDIF}

{$IFDEF POSIX}
class function TPlatformHelper.ExecuteCommand(const ACommand: string): Boolean;
begin
  // На Linux/macOS используем system()
  Result := system(PAnsiChar(UTF8String(ACommand))) = 0;
end;
{$ENDIF}

{ TPDFExportManager }

function ContainsRussianText(const AText: string): Boolean;
begin
  // Простая проверка на наличие русских букв
  for var I := 1 to Length(AText) do
  begin
    var Ch := AText[I];
    if (Ch >= 'А') and (Ch <= 'я') then
      Exit(True);
  end;
  Result := False;
end;

class function TPDFExportManager.GeneratePDFFromHTML(const AHTMLContent: TStringList;
  const AFileName: string = ''): Boolean;
var
  OutputPDF, HTMLFile, BrowserPath, Command: string;
  Encoding: TEncoding;
  HTML: TStringList;
  isYandex:boolean;
begin
  Result := False;

  // Определяем имя файла
  if AFileName = '' then
    OutputPDF := TPlatformHelper.GetPDFOutputPath('report_' +
                  FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.pdf')
  else
    OutputPDF := TPlatformHelper.GetPDFOutputPath(AFileName);

  // Создаем временный HTML файл
  HTMLFile := TPath.Combine(TPath.GetTempPath, 'temp_report_' +
               IntToStr(TThread.GetTickCount) + '.html');

  AHTMLContent.SaveToFile(HTMLFile,TEncoding.UTF8);

  try

    if not FileExists(HTMLFile) then begin
      ShowMessage('Ошибка создания временного файла'+#13#10+HTMLFile);
      Exit;
    end;



    // Получаем путь к Chrome
    BrowserPath := TPlatformHelper.GetBrowserPath;

    if (BrowserPath <> '') then
    begin
      //'C:\Users\User\AppData\Local\Yandex\YandexBrowser\Application\browser.exe'
      // Формируем команду для конвертации
      isYandex:=pos('Yandex',BrowserPath)>0;
      if isYandex then
        Command := '"' + BrowserPath + '" --disable-gpu --no-margins --no-sandbox --disable-dev-shm-usage ' +
                   '--print-to-pdf="' + OutputPDF + '" "file://' + HTMLFile + '"'
      else
        Command := '"' + BrowserPath + '" --headless --disable-gpu --no-margins --no-sandbox --disable-dev-shm-usage ' +
                   '--print-to-pdf="' + OutputPDF + '" "file://' + HTMLFile + '"';
      // Выполняем команду
      if TPlatformHelper.ExecuteCommand(Command) then
      begin
        // Даем время на создание файла
        Sleep(2000);
        Result := FileExists(OutputPDF);
      end;
    end
    else
    begin
      // Если браузер не найден, просто сохраняем HTML
      SaveHTMLForExport(AHTMLContent, ChangeFileExt(ExtractFileName(OutputPDF), '.html'));
      Result := True;

      ShowMessage('Browser не найден. ' + sLineBreak +
                  'HTML отчет сохранен. Вы можете открыть его в браузере ' +
                  'и сохранить как PDF вручную.');
    end;

  finally
    // Удаляем временный файл
//    if FileExists(HTMLFile) then
//    begin
//      try
//        TFile.Delete(HTMLFile);
//      except
//        // Игнорируем ошибки удаления временного файла
//      end;
//    end;
  end;
end;

class procedure TPDFExportManager.SaveHTMLForExport(const AHTMLContent: TStringList;
  const AFileName: string = '');
var
  OutputFile: string;
begin
  if AFileName = '' then
    OutputFile := TPlatformHelper.GetPDFOutputPath('report_' +
                   FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.html')
  else
    OutputFile := TPlatformHelper.GetPDFOutputPath(AFileName);

  // Создаем директорию если не существует
  ForceDirectories(ExtractFilePath(OutputFile));

  AHTMLContent.SaveToFile(OutputFile,TEncoding.UTF8);

  ShowMessage('HTML отчет сохранен: ' + OutputFile);
end;

end.
