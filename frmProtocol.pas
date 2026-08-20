unit frmProtocol;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Platform,
  FMX.Graphics,
  FMX.Layouts,
  FMX.ListBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.IniFiles,
  System.Generics.Collections,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils,
  System.UITypes,
  uBaseProcedures,
  uProtocols,
  uProjectSettings,
  uAppVersion,
  uWorkTable;

type
  TFrameProtocol = class(TFrame)
    ToolBarProtocol: TToolBar;
    SpeedButtonResume: TSpeedButton;
    SpeedButtonPause: TSpeedButton;
    SpeedButtonClear: TSpeedButton;
    LayoutFilters: TLayout;
    CheckBoxEvent: TCheckBox;
    CheckBoxState: TCheckBox;
    CheckBoxAction: TCheckBox;
    CheckBoxForm: TCheckBox;
    CheckBoxParameters: TCheckBox;
    CheckBoxWorkTable: TCheckBox;
    CheckBoxMeasurement: TCheckBox;
    CheckBoxMKS: TCheckBox;
    ListBoxProtocol: TListBox;
    CheckBoxWorkLog: TCheckBox;
    CheckBoxProc: TCheckBox;
    CheckBoxHandler: TCheckBox;
    CheckBoxEngine: TCheckBox;
    procedure SpeedButtonResumeClick(Sender: TObject);
    procedure SpeedButtonPauseClick(Sender: TObject);
    procedure SpeedButtonClearClick(Sender: TObject);
    procedure SpeedButtonExportClick(Sender: TObject);
    procedure SpeedButtonCopyClick(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
  private
    FMessages: TObjectList<TProtocolMessage>;
    FListener: TProtocolListener;
    FLoadingSettings: Boolean;
    FProtocolSettingsFileName: string;
    FFullLogFileName: string;
    FFullLogWriter: TStreamWriter;
    FSessionLogFiles: TStringList;
    FCurrentLogSizeBytes: Int64;
    FTotalMessageCount: Int64;
    procedure HandleProtocolMessage(Msg: TProtocolMessage);
    function ProtocolLogDirectory: string;
    procedure CleanupOldProtocolFiles;
    procedure InitializeFullLog;
    procedure ResetFullLog;
    procedure AppendFullLogMessage(const Msg: TProtocolMessage);
    procedure TrimStoredMessages;
    procedure TrimProtocolItems;
    procedure ShowPartialCopyWarning(const ACopiedCount: Integer);

    procedure AddProtocolItem(const Msg: TProtocolMessage);
    function IsAllowedByFilters(Msg: TProtocolMessage): Boolean;
    procedure RebuildMemo;
    procedure ExportProtocolToFile;
    procedure CopyProtocolToClipboard;
    procedure LoadProtocolSettings;
    procedure SaveProtocolSettings;
    function ProtocolSettingsFileName: string;
    procedure LoadCheckBoxSetting(AIni: TCustomIniFile; ACheckBox: TCheckBox);
    procedure SaveCheckBoxSetting(AIni: TCustomIniFile; ACheckBox: TCheckBox);
    procedure LoadComboBoxSetting(AIni: TCustomIniFile; AComboBox: TComboBox);
    procedure SaveComboBoxSetting(AIni: TCustomIniFile; AComboBox: TComboBox);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

const
  CProtocolMemoryMessageLimit = 2000;
  CProtocolDisplayMessageLimit = 2000;
  CClipboardCharacterLimit = 5 * 1024 * 1024;
  CProtocolRetentionDays = 7;
  CProtocolTotalSizeLimit = Int64(1024) * 1024 * 1024;
  CProtocolFileSizeLimit = Int64(100) * 1024 * 1024;

constructor TFrameProtocol.Create(AOwner: TComponent);
var
  BtnExport: TSpeedButton;
  BtnCopy: TSpeedButton;
  ActiveWorkTable: TWorkTable;
  SimulationModeText: string;
  EffectiveSimulationText: string;
begin
  inherited;
  FProtocolSettingsFileName := '';
  FMessages := TObjectList<TProtocolMessage>.Create(True);
  FFullLogWriter := nil;
  FSessionLogFiles := TStringList.Create;
  FFullLogFileName := '';
  FCurrentLogSizeBytes := 0;
  FTotalMessageCount := 0;
  InitializeFullLog;
  FLoadingSettings := True;

  CheckBoxEvent.IsChecked := True;
  CheckBoxState.IsChecked := True;
  CheckBoxAction.IsChecked := True;
  CheckBoxForm.IsChecked := True;
  CheckBoxParameters.IsChecked := True;
  CheckBoxWorkTable.IsChecked := True;
  CheckBoxMeasurement.IsChecked := True;
  CheckBoxMKS.IsChecked := True;
  CheckBoxWorkLog.IsChecked := True;
  CheckBoxProc.IsChecked := True;
  CheckBoxHandler.IsChecked := True;
  CheckBoxEngine.IsChecked := True;
  FLoadingSettings := False;
  LoadProtocolSettings;

  BtnCopy := TSpeedButton.Create(ToolBarProtocol);
  BtnCopy.Parent := ToolBarProtocol;
  BtnCopy.Align := TAlignLayout.Left;
  BtnCopy.Text := 'Скопировать';
  BtnCopy.Width := 110;
  BtnCopy.OnClick := SpeedButtonCopyClick;

  BtnExport := TSpeedButton.Create(ToolBarProtocol);
  BtnExport.Parent := ToolBarProtocol;
  BtnExport.Align := TAlignLayout.Left;
  BtnExport.Text := 'Выгрузить в файл';
  BtnExport.Width := 140;
  BtnExport.OnClick := SpeedButtonExportClick;

  FListener :=
    procedure(Msg: TProtocolMessage)
    begin
      HandleProtocolMessage(Msg);
    end;

  ProtocolManager.Subscribe(FListener);
  ActiveWorkTable := nil;
  if WorkTableManager <> nil then
    ActiveWorkTable := WorkTableManager.ActiveWorkTable;
  SimulationModeText := 'False';
  EffectiveSimulationText := 'False';
  if ActiveWorkTable <> nil then
  begin
    SimulationModeText := IfThen(ActiveWorkTable.IsSimulationMode, 'True', 'False');
    EffectiveSimulationText := IfThen(ActiveWorkTable.SimulationActive, 'True', 'False');
  end;
  ProtocolManager.AddMessage(pcInfo, psEngine, 'ApplicationVersion',
    'Версия программы',
    Format('Version=%s; Executable=%s; BuildDate=; GitCommit=; SimulationMode=%s; EffectiveSimulationActive=%s',
      [APP_VERSION, ExpandFileName(ParamStr(0)), SimulationModeText,
       EffectiveSimulationText]));
end;




function TFrameProtocol.ProtocolSettingsFileName: string;
begin
  // Запоминаем путь, пока менеджер рабочего стола ещё существует.
  if (WorkTableManager <> nil) and
     (Trim(WorkTableManager.IniFileName) <> '') then
    FProtocolSettingsFileName := WorkTableManager.IniFileName;

  // При завершении работы возвращаем ранее сохранённый путь без исключения.
  Result := FProtocolSettingsFileName;
end;

procedure TFrameProtocol.LoadCheckBoxSetting(AIni: TCustomIniFile; ACheckBox: TCheckBox);
begin
  if (AIni = nil) or (ACheckBox = nil) or (ACheckBox.Name = '') then
    Exit;

  ACheckBox.IsChecked := AIni.ReadBool('Protocol', ACheckBox.Name, True);
end;

procedure TFrameProtocol.SaveCheckBoxSetting(AIni: TCustomIniFile; ACheckBox: TCheckBox);
begin
  if (AIni = nil) or (ACheckBox = nil) or (ACheckBox.Name = '') then
    Exit;

  AIni.WriteBool('Protocol', ACheckBox.Name, ACheckBox.IsChecked);
end;

procedure TFrameProtocol.LoadComboBoxSetting(AIni: TCustomIniFile; AComboBox: TComboBox);
var
  Value: string;
  Index: Integer;
begin
  if (AIni = nil) or (AComboBox = nil) or (AComboBox.Name = '') then
    Exit;

  Value := AIni.ReadString('Protocol', AComboBox.Name, '');
  if Value = '' then
    Exit;

  Index := AComboBox.Items.IndexOf(Value);
  if Index >= 0 then
    AComboBox.ItemIndex := Index
  else if (AComboBox.ItemIndex < 0) and (AComboBox.Items.Count > 0) then
    AComboBox.ItemIndex := 0;
end;

procedure TFrameProtocol.SaveComboBoxSetting(AIni: TCustomIniFile; AComboBox: TComboBox);
begin
  if (AIni = nil) or (AComboBox = nil) or (AComboBox.Name = '') or
     (AComboBox.ItemIndex < 0) then
    Exit;

  AIni.WriteString('Protocol', AComboBox.Name, AComboBox.Items[AComboBox.ItemIndex]);
end;

procedure TFrameProtocol.LoadProtocolSettings;
var
  Ini: TCustomIniFile;
  I: Integer;
  FileName: string;
begin
  FileName := ProtocolSettingsFileName;
  if Trim(FileName) = '' then
    Exit;

  FLoadingSettings := True;
  Ini := TProjectSettingsIni.Create(FileName, STORAGE_TABLE_SETTINGS);
  try
    LoadCheckBoxSetting(Ini, CheckBoxEvent);
    LoadCheckBoxSetting(Ini, CheckBoxState);
    LoadCheckBoxSetting(Ini, CheckBoxAction);
    LoadCheckBoxSetting(Ini, CheckBoxForm);
    LoadCheckBoxSetting(Ini, CheckBoxParameters);
    LoadCheckBoxSetting(Ini, CheckBoxWorkTable);
    LoadCheckBoxSetting(Ini, CheckBoxMeasurement);
    LoadCheckBoxSetting(Ini, CheckBoxMKS);
    LoadCheckBoxSetting(Ini, CheckBoxWorkLog);
    LoadCheckBoxSetting(Ini, CheckBoxProc);
    LoadCheckBoxSetting(Ini, CheckBoxHandler);
    LoadCheckBoxSetting(Ini, CheckBoxEngine);
    for I := 0 to ComponentCount - 1 do
      if Components[I] is TComboBox then
      begin
        LoadComboBoxSetting(Ini, TComboBox(Components[I]));
        TComboBox(Components[I]).OnChange := FilterChanged;
      end;
  finally
    Ini.Free;
    FLoadingSettings := False;
  end;
end;

procedure TFrameProtocol.SaveProtocolSettings;
var
  Ini: TCustomIniFile;
  I: Integer;
  FileName: string;
begin
  FileName := ProtocolSettingsFileName;
  if Trim(FileName) = '' then
    Exit;

  Ini := TProjectSettingsIni.Create(FileName, STORAGE_TABLE_SETTINGS);
  try
    SaveCheckBoxSetting(Ini, CheckBoxEvent);
    SaveCheckBoxSetting(Ini, CheckBoxState);
    SaveCheckBoxSetting(Ini, CheckBoxAction);
    SaveCheckBoxSetting(Ini, CheckBoxForm);
    SaveCheckBoxSetting(Ini, CheckBoxParameters);
    SaveCheckBoxSetting(Ini, CheckBoxWorkTable);
    SaveCheckBoxSetting(Ini, CheckBoxMeasurement);
    SaveCheckBoxSetting(Ini, CheckBoxMKS);
    SaveCheckBoxSetting(Ini, CheckBoxWorkLog);
    SaveCheckBoxSetting(Ini, CheckBoxProc);
    SaveCheckBoxSetting(Ini, CheckBoxHandler);
    SaveCheckBoxSetting(Ini, CheckBoxEngine);
    for I := 0 to ComponentCount - 1 do
      if Components[I] is TComboBox then
        SaveComboBoxSetting(Ini, TComboBox(Components[I]));
  finally
    Ini.Free;
  end;
end;

function TFrameProtocol.ProtocolLogDirectory: string;
var
  ProjectFileName: string;
begin
  if TryGetProjectSettingsFileName(ProjectFileName) then
    Result := TPath.Combine(
      ExtractFileDir(ExpandFileName(ProjectFileName)), 'Logs')
  else
    Result := TPath.GetDocumentsPath;
end;

procedure TFrameProtocol.CleanupOldProtocolFiles;
var
  LogDirectory: string;
  Files: TStringList;
  FoundFiles: TArray<string>;
  FileName: string;
  Cutoff: TDateTime;
  ModifiedTime: TDateTime;
  OldestTime: TDateTime;
  TotalSize: Int64;
  FileSize: Int64;
  OldestIndex: Integer;
  I: Integer;

  function IsCurrentLogFile(const AFileName: string): Boolean;
  begin
    Result := (FFullLogFileName <> '') and
      SameText(ExpandFileName(AFileName), ExpandFileName(FFullLogFileName));
  end;

  procedure CollectFiles(const APattern: string);
  var
    Candidate: string;
  begin
    try
      FoundFiles := TDirectory.GetFiles(LogDirectory, APattern);
      for Candidate in FoundFiles do
        if Files.IndexOf(Candidate) < 0 then
          Files.Add(Candidate);
    except
      { Cleanup failure must not interrupt application startup or logging. }
    end;
  end;

begin
  LogDirectory := ProtocolLogDirectory;
  Files := TStringList.Create;
  try
    CollectFiles('protocol_session_*.txt');
    CollectFiles('protocol_export_*.txt');

    Cutoff := Now - CProtocolRetentionDays;
    TotalSize := 0;

    for I := Files.Count - 1 downto 0 do
    begin
      FileName := Files[I];

      try
        if not TFile.Exists(FileName) then
        begin
          Files.Delete(I);
          Continue;
        end;

        ModifiedTime := TFile.GetLastWriteTime(FileName);
        if (ModifiedTime < Cutoff) and not IsCurrentLogFile(FileName) then
        begin
          TFile.Delete(FileName);
          Files.Delete(I);
          Continue;
        end;

        Inc(TotalSize, TFile.GetSize(FileName));
      except
        Files.Delete(I);
      end;
    end;

    while TotalSize > CProtocolTotalSizeLimit do
    begin
      OldestIndex := -1;
      OldestTime := EncodeDate(9999, 12, 31);

      for I := 0 to Files.Count - 1 do
      begin
        FileName := Files[I];
        if IsCurrentLogFile(FileName) then
          Continue;

        try
          ModifiedTime := TFile.GetLastWriteTime(FileName);
          if ModifiedTime < OldestTime then
          begin
            OldestTime := ModifiedTime;
            OldestIndex := I;
          end;
        except
          { Ignore inaccessible candidates and continue with other files. }
        end;
      end;

      if OldestIndex < 0 then
        Break;

      FileName := Files[OldestIndex];
      try
        FileSize := TFile.GetSize(FileName);
        TFile.Delete(FileName);
        Dec(TotalSize, FileSize);
      except
        { Remove an inaccessible candidate to prevent an endless loop. }
      end;
      Files.Delete(OldestIndex);
    end;
  finally
    Files.Free;
  end;
end;

procedure TFrameProtocol.InitializeFullLog;
var
  LogDirectory: string;
begin
  FreeAndNil(FFullLogWriter);
  FFullLogFileName := '';
  FCurrentLogSizeBytes := 0;

  LogDirectory := ProtocolLogDirectory;
  ForceDirectories(LogDirectory);
  CleanupOldProtocolFiles;

  FFullLogFileName := TPath.Combine(
    LogDirectory,
    'protocol_session_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now) + '.txt'
  );

  try
    FFullLogWriter := TStreamWriter.Create(
      FFullLogFileName,
      False,
      TEncoding.UTF8
    );
    FFullLogWriter.AutoFlush := True;
    if FSessionLogFiles.IndexOf(FFullLogFileName) < 0 then
      FSessionLogFiles.Add(FFullLogFileName);
  except
    FreeAndNil(FFullLogWriter);
    FFullLogFileName := '';
  end;
end;

procedure TFrameProtocol.ResetFullLog;
begin
  FTotalMessageCount := 0;
  FSessionLogFiles.Clear;
  InitializeFullLog;
end;

procedure TFrameProtocol.AppendFullLogMessage(
  const Msg: TProtocolMessage);
var
  Line: string;
  LineSize: Int64;
begin
  if Msg = nil then
    Exit;

  Line := TProtocolManager.FormatMessage(Msg);
  LineSize := TEncoding.UTF8.GetByteCount(Line + sLineBreak);

  if (FFullLogWriter <> nil) and
     (FCurrentLogSizeBytes + LineSize > CProtocolFileSizeLimit) then
    InitializeFullLog;

  if FFullLogWriter = nil then
    Exit;

  try
    FFullLogWriter.WriteLine(Line);
    Inc(FCurrentLogSizeBytes, LineSize);
  except
    FreeAndNil(FFullLogWriter);
  end;
end;

procedure TFrameProtocol.TrimStoredMessages;
begin
  while FMessages.Count > CProtocolMemoryMessageLimit do
    FMessages.Delete(0);
end;

procedure TFrameProtocol.TrimProtocolItems;
var
  Item: TListBoxItem;
begin
  while ListBoxProtocol.Count > CProtocolDisplayMessageLimit do
  begin
    Item := ListBoxProtocol.ItemByIndex(0) as TListBoxItem;
    ListBoxProtocol.RemoveObject(Item);
    Item.Free;
  end;
end;

procedure TFrameProtocol.ShowPartialCopyWarning(
  const ACopiedCount: Integer);
var
  FileInfo: string;
begin
  if ACopiedCount >= FTotalMessageCount then
    Exit;

  FileInfo := '';
  if FSessionLogFiles.Count > 0 then
    FileInfo := sLineBreak +
      'Полный журнал можно получить кнопкой «Выгрузить в файл».' +
      sLineBreak + 'Папка журналов: ' + ProtocolLogDirectory;

  ShowMessage(Format(
    'В буфер скопирован не весь журнал: %d из %d сообщений.%s',
    [ACopiedCount, FTotalMessageCount, FileInfo]
  ));
end;

procedure TFrameProtocol.ExportProtocolToFile;
var
  FileName: string;
  SourceFileName: string;
  Reader: TStreamReader;
  Writer: TStreamWriter;
  HasSourceFiles: Boolean;
  I: Integer;
begin
  if FFullLogWriter <> nil then
    FFullLogWriter.Flush;

  HasSourceFiles := False;
  for I := 0 to FSessionLogFiles.Count - 1 do
    if TFile.Exists(FSessionLogFiles[I]) then
    begin
      HasSourceFiles := True;
      Break;
    end;

  if not HasSourceFiles then
  begin
    ShowMessage('Полный файл журнала недоступен.');
    Exit;
  end;

  FileName := TPath.Combine(
    ProtocolLogDirectory,
    'protocol_export_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now) + '.txt'
  );

  Writer := nil;
  try
    Writer := TStreamWriter.Create(FileName, False, TEncoding.UTF8);

    for I := 0 to FSessionLogFiles.Count - 1 do
    begin
      SourceFileName := FSessionLogFiles[I];
      if not TFile.Exists(SourceFileName) then
        Continue;

      Reader := TStreamReader.Create(
        SourceFileName,
        TEncoding.UTF8,
        True
      );
      try
        while not Reader.EndOfStream do
          Writer.WriteLine(Reader.ReadLine);
      finally
        Reader.Free;
      end;
    end;

    Writer.Flush;
    CleanupOldProtocolFiles;
    ShowMessage('Журнал выгружен: ' + FileName);
  except
    on E: Exception do
      ShowMessage('Не удалось выгрузить журнал: ' + E.Message);
  end;
  Writer.Free;
end;

destructor TFrameProtocol.Destroy;
begin
  SaveProtocolSettings;
  if ProtocolManager <> nil then
    ProtocolManager.Unsubscribe(FListener);

  FreeAndNil(FFullLogWriter);
  FreeAndNil(FSessionLogFiles);
  FreeAndNil(FMessages);
  inherited;
end;

procedure TFrameProtocol.HandleProtocolMessage(Msg: TProtocolMessage);
var
  CopyMsg: TProtocolMessage;
begin
  if Msg = nil then
    Exit;

  CopyMsg := Msg.Clone;

  TThread.Synchronize(nil,
    procedure
    begin
      Inc(FTotalMessageCount);
      AppendFullLogMessage(CopyMsg);

      FMessages.Add(CopyMsg);
      TrimStoredMessages;

      if IsAllowedByFilters(CopyMsg) then
        AddProtocolItem(CopyMsg);
    end
  );
end;

procedure TFrameProtocol.CopyProtocolToClipboard;
var
  Builder: TStringBuilder;
  I: Integer;
  Item: TListBoxItem;
  Line: string;
  ClipboardText: string;
  CopiedCount: Integer;
  ClipboardService: IFMXClipboardService;
begin
  if ListBoxProtocol.Count = 0 then
  begin
    if FTotalMessageCount > 0 then
      ShowPartialCopyWarning(0);
    Exit;
  end;

  Builder := TStringBuilder.Create;
  try
    CopiedCount := 0;

    for I := 0 to ListBoxProtocol.Count - 1 do
      if ListBoxProtocol.ItemByIndex(I) is TListBoxItem then
      begin
        Item := TListBoxItem(ListBoxProtocol.ItemByIndex(I));
        Line := Item.Text;

        if Builder.Length + Length(Line) + Length(sLineBreak) >
           CClipboardCharacterLimit then
          Break;

        Builder.Append(Line);
        Builder.Append(sLineBreak);
        Inc(CopiedCount);
      end;

    if (CopiedCount > 0) and TPlatformServices.Current.SupportsPlatformService(
      IFMXClipboardService, IInterface(ClipboardService)) then
    begin
      ClipboardText := Builder.ToString;
      ClipboardService.SetClipboard(ClipboardText);
      ShowPartialCopyWarning(CopiedCount);
    end;
  finally
    Builder.Free;
  end;
end;

procedure TFrameProtocol.AddProtocolItem(const Msg: TProtocolMessage);
var
  Item: TListBoxItem;
begin
  if Msg = nil then
    Exit;

  Item := TListBoxItem.Create(ListBoxProtocol);
  Item.Stored := False;
  Item.Text := TProtocolManager.FormatMessage(Msg);
  Item.Selectable := False;
  Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
  Item.TextSettings.Font.Family := 'Consolas';
  Item.TextSettings.Font.Size := 12;
  Item.TextSettings.WordWrap := False;

  case Msg.Category of
    pcInfo: Item.TextSettings.FontColor := TEXT_COLOR_INFO;
    pcWarning: Item.TextSettings.FontColor := TEXT_COLOR_WARNING;
    pcError: Item.TextSettings.FontColor := TEXT_COLOR_ERROR;
  end;

  ListBoxProtocol.AddObject(Item);
  TrimProtocolItems;
  ListBoxProtocol.ScrollToItem(Item);
end;

function TFrameProtocol.IsAllowedByFilters(Msg: TProtocolMessage): Boolean;
begin
  Result := True;

  case Msg.Category of
    pcEvent: Result := CheckBoxEvent.IsChecked;
    pcState: Result := CheckBoxState.IsChecked;
    pcAction: Result := CheckBoxAction.IsChecked;
    pcMKS: Result := CheckBoxMKS.IsChecked;
    pcWorkLog: Result := CheckBoxWorkLog.IsChecked;
    pcProc: Result := CheckBoxProc.IsChecked;
    pcHandler: Result := CheckBoxHandler.IsChecked;

  end;

  if (not Result) or (Msg.Category = pcMKS) then
    Exit;

  case Msg.Source of
    psForm: Result := CheckBoxForm.IsChecked;
    psParameters: Result := CheckBoxParameters.IsChecked;
    psWorkTable: Result := CheckBoxWorkTable.IsChecked;
    psMeasurement: Result := CheckBoxMeasurement.IsChecked;
    psEngine: Result := CheckBoxEngine.IsChecked;
  end;
end;

procedure TFrameProtocol.RebuildMemo;
var
  Msg: TProtocolMessage;
begin
  ListBoxProtocol.BeginUpdate;
  try
    ListBoxProtocol.Clear;
    for Msg in FMessages do
      if IsAllowedByFilters(Msg) then
        AddProtocolItem(Msg);
  finally
    ListBoxProtocol.EndUpdate;
  end;
end;

procedure TFrameProtocol.FilterChanged(Sender: TObject);
begin
  if not FLoadingSettings then
    SaveProtocolSettings;
  RebuildMemo;
end;

procedure TFrameProtocol.SpeedButtonClearClick(Sender: TObject);
begin
  ProtocolManager.Clear;
  FMessages.Clear;
  ListBoxProtocol.Clear;
  ResetFullLog;
end;

procedure TFrameProtocol.SpeedButtonExportClick(Sender: TObject);
begin
  ExportProtocolToFile;
end;

procedure TFrameProtocol.SpeedButtonCopyClick(Sender: TObject);
begin
  CopyProtocolToClipboard;
end;

procedure TFrameProtocol.SpeedButtonPauseClick(Sender: TObject);
begin
  ProtocolManager.Pause;
end;

procedure TFrameProtocol.SpeedButtonResumeClick(Sender: TObject);
begin
  ProtocolManager.Resume;
end;

end.
