unit ShellHelper;

interface

uses
  System.Threading,
  System.SysUtils, System.Diagnostics, System.IOUtils,
  {$IFDEF MSWINDOWS}
  Winapi.ShellAPI, Winapi.Windows,
  {$ENDIF}
  {$IFDEF MACOS}
  Macapi.CoreFoundation, Macapi.AppKit, // для NSWorkspace (опционально)
  {$ENDIF}
  FMX.Platform; // для служебных функций

type
  TMyShowCmd = (swHidden, swNormal, swMinimized, swMaximized);

function MyShellExecute(Operation: string; FileName: string;
  Parameters: string = ''; Directory: string = '';
  ShowCmd: TMyShowCmd = swNormal): Boolean;
var
  LProcess: TProcess;
  LFileName: string;
  LParams: string;
begin
  Result := False;

  // 1. Для Windows можно напрямую использовать ShellExecute, если нужно точное поведение
  {$IFDEF MSWINDOWS}
  // Если нужно просто открыть документ/папку или выполнить команду с ассоциацией,
  // лучше использовать ShellExecute (он поддерживает 'open', 'print', 'explore' и т.д.)
  if (Operation <> '') or (TPath.HasExtension(FileName) and
     not (SameText(TPath.GetExtension(FileName), '.exe')) and
     not (SameText(TPath.GetExtension(FileName), '.bat')) and
     not (SameText(TPath.GetExtension(FileName), '.cmd'))) then
  begin
    // Преобразуем TMyShowCmd в Winapi.Windows.SW_ константы
    var SW: Integer := SW_SHOWNORMAL;
    case ShowCmd of
      swHidden: SW := SW_HIDE;
      swNormal: SW := SW_SHOWNORMAL;
      swMinimized: SW := SW_SHOWMINNOACTIVE; // или SW_MINIMIZE
      swMaximized: SW := SW_SHOWMAXIMIZED;
    end;
    // ShellExecuteW возвращает HINSTANCE, но нам нужно только Boolean
    var Res := ShellExecuteW(0, PWideChar(Operation), PWideChar(FileName),
      PWideChar(Parameters), PWideChar(Directory), SW);
    Result := Res > 32; // успех если >32
    Exit;
  end;
  {$ENDIF}

  // 2. Для macOS и других Unix-подобных систем, а также для запуска .bat/.exe на Windows
  LProcess := TProcess.Create(nil);
  try
    // Определяем исполняемый файл и параметры
    {$IFDEF MSWINDOWS}
    // Для .bat/.cmd используем cmd.exe
    if SameText(TPath.GetExtension(FileName), '.bat') or
       SameText(TPath.GetExtension(FileName), '.cmd') then
    begin
      LProcess.Executable := 'cmd.exe';
      LProcess.Parameters.Add('/c');
      LProcess.Parameters.Add(FileName);
      if Parameters <> '' then
        LProcess.Parameters.Add(Parameters);
    end
    else
    begin
      LProcess.Executable := FileName;
      LProcess.Parameters.Add(Parameters);
    end;
    // Устанавливаем режим окна
    case ShowCmd of
      swHidden: LProcess.WindowShowMode := TProcessWindowShowMode.swHidden;
      swNormal: LProcess.WindowShowMode := TProcessWindowShowMode.swNormal;
      swMinimized: LProcess.WindowShowMode := TProcessWindowShowMode.swMinimized;
      swMaximized: LProcess.WindowShowMode := TProcessWindowShowMode.swMaximized;
    end;
    {$ENDIF}

    {$IFDEF MACOS}
    // На macOS для открытия документов лучше использовать 'open' утилиту
    if (Operation = 'open') and (not TFile.Exists(FileName) or
       (TFile.GetAttributes(FileName) and TFileAttributes.faSymLink = 0)) then
    begin
      // Если файл не является исполняемым, используем open
      LProcess.Executable := '/usr/bin/open';
      LProcess.Parameters.Add(FileName);
    end
    else
    begin
      LProcess.Executable := FileName;
      LProcess.Parameters.Add(Parameters);
    end;
    // На macOS скрытие окна не поддерживается напрямую, но можно добавить '&' или использовать nohup?
    // Оставляем как есть – окно терминала не появится, если приложение графическое.
    {$ENDIF}

    {$IFDEF LINUX}
    LProcess.Executable := FileName;
    LProcess.Parameters.Add(Parameters);
    // На Linux можно попытаться скрыть окно, но это не гарантировано.
    {$ENDIF}

    // Устанавливаем рабочую папку
    if Directory <> '' then
      LProcess.CurrentDirectory := Directory;

    // Выполняем
    Result := LProcess.Execute;
  finally
    LProcess.Free;
  end;
end;
