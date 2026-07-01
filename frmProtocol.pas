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
  System.SysUtils,
  System.UITypes,
  uProtocols,
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
    procedure HandleProtocolMessage(Msg: TProtocolMessage);

    procedure AddProtocolItem(const Msg: TProtocolMessage);
    function IsAllowedByFilters(Msg: TProtocolMessage): Boolean;
    procedure RebuildMemo;
    procedure ExportProtocolToFile;
    procedure CopyProtocolToClipboard;
    procedure LoadProtocolSettings;
    procedure SaveProtocolSettings;
    function ProtocolSettingsFileName: string;
    procedure LoadCheckBoxSetting(AIni: TIniFile; ACheckBox: TCheckBox);
    procedure SaveCheckBoxSetting(AIni: TIniFile; ACheckBox: TCheckBox);
    procedure LoadComboBoxSetting(AIni: TIniFile; AComboBox: TComboBox);
    procedure SaveComboBoxSetting(AIni: TIniFile; AComboBox: TComboBox);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

constructor TFrameProtocol.Create(AOwner: TComponent);
var
  BtnExport: TSpeedButton;
  BtnCopy: TSpeedButton;
begin
  inherited;
  FMessages := TObjectList<TProtocolMessage>.Create(True);
  FLoadingSettings := False;

  CheckBoxEvent.IsChecked := True;
  CheckBoxState.IsChecked := True;
  CheckBoxAction.IsChecked := True;
  CheckBoxForm.IsChecked := True;
  CheckBoxParameters.IsChecked := True;
  CheckBoxWorkTable.IsChecked := True;
  CheckBoxMeasurement.IsChecked := True;
  CheckBoxMKS.IsChecked := True;
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
end;




function TFrameProtocol.ProtocolSettingsFileName: string;
begin
  if (WorkTableManager <> nil) and (Trim(WorkTableManager.IniFileName) <> '') then
    Exit(WorkTableManager.IniFileName);

  Result := TPath.Combine(
    TPath.Combine(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))), 'Settings'),
    'TableSettings.ini'
  );
end;

procedure TFrameProtocol.LoadCheckBoxSetting(AIni: TIniFile; ACheckBox: TCheckBox);
begin
  if (AIni = nil) or (ACheckBox = nil) or (ACheckBox.Name = '') then
    Exit;

  ACheckBox.IsChecked := AIni.ReadBool('Protocol', ACheckBox.Name, True);
end;

procedure TFrameProtocol.SaveCheckBoxSetting(AIni: TIniFile; ACheckBox: TCheckBox);
begin
  if (AIni = nil) or (ACheckBox = nil) or (ACheckBox.Name = '') then
    Exit;

  AIni.WriteBool('Protocol', ACheckBox.Name, ACheckBox.IsChecked);
end;

procedure TFrameProtocol.LoadComboBoxSetting(AIni: TIniFile; AComboBox: TComboBox);
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

procedure TFrameProtocol.SaveComboBoxSetting(AIni: TIniFile; AComboBox: TComboBox);
begin
  if (AIni = nil) or (AComboBox = nil) or (AComboBox.Name = '') or
     (AComboBox.ItemIndex < 0) then
    Exit;

  AIni.WriteString('Protocol', AComboBox.Name, AComboBox.Items[AComboBox.ItemIndex]);
end;

procedure TFrameProtocol.LoadProtocolSettings;
var
  Ini: TIniFile;
  I: Integer;
  FileName: string;
begin
  FileName := ProtocolSettingsFileName;
  if Trim(FileName) = '' then
    Exit;

  ForceDirectories(ExtractFilePath(FileName));
  FLoadingSettings := True;
  Ini := TIniFile.Create(FileName);
  try
    for I := 0 to ComponentCount - 1 do
    begin
      if Components[I] is TCheckBox then
        LoadCheckBoxSetting(Ini, TCheckBox(Components[I]))
      else if Components[I] is TComboBox then
      begin
        LoadComboBoxSetting(Ini, TComboBox(Components[I]));
        TComboBox(Components[I]).OnChange := FilterChanged;
      end;
    end;
  finally
    Ini.Free;
    FLoadingSettings := False;
  end;
end;

procedure TFrameProtocol.SaveProtocolSettings;
var
  Ini: TIniFile;
  I: Integer;
  FileName: string;
begin
  FileName := ProtocolSettingsFileName;
  if Trim(FileName) = '' then
    Exit;

  ForceDirectories(ExtractFilePath(FileName));
  Ini := TIniFile.Create(FileName);
  try
    for I := 0 to ComponentCount - 1 do
      if Components[I] is TCheckBox then
        SaveCheckBoxSetting(Ini, TCheckBox(Components[I]))
      else if Components[I] is TComboBox then
        SaveComboBoxSetting(Ini, TComboBox(Components[I]));
  finally
    Ini.Free;
  end;
end;

procedure TFrameProtocol.ExportProtocolToFile;
var
  Lines: TStringList;
  I: Integer;
  FileName: string;
  Item: TListBoxItem;
begin
  Lines := TStringList.Create;
  try
    for I := 0 to ListBoxProtocol.Count - 1 do
      if ListBoxProtocol.ItemByIndex(I) is TListBoxItem then
      begin
        Item := TListBoxItem(ListBoxProtocol.ItemByIndex(I));
        Lines.Add(Item.Text);
      end;

    FileName := TPath.Combine(TPath.GetDocumentsPath,
      'protocol_export_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.txt');
    Lines.SaveToFile(FileName, TEncoding.UTF8);
    ShowMessage('Журнал выгружен: ' + FileName);
  finally
    Lines.Free;
  end;
end;

destructor TFrameProtocol.Destroy;
begin
  SaveProtocolSettings;
 if ProtocolManager<>nil then
   begin
   ProtocolManager.Unsubscribe(FListener);
  FreeAndNil(FMessages);
   end;
  inherited;
end;

procedure TFrameProtocol.HandleProtocolMessage(Msg: TProtocolMessage);
var
  CopyMsg: TProtocolMessage;
begin
  if Msg = nil then
    Exit;

  CopyMsg := Msg.Clone;
  FMessages.Add(CopyMsg);

  if IsAllowedByFilters(CopyMsg) then
    AddProtocolItem(CopyMsg);
end;

procedure TFrameProtocol.CopyProtocolToClipboard;
var
  Lines: TStringList;
  I: Integer;
  Item: TListBoxItem;
  ClipboardService: IFMXClipboardService;
begin
  if ListBoxProtocol.Count = 0 then
    Exit;

  Lines := TStringList.Create;
  try
    for I := 0 to ListBoxProtocol.Count - 1 do
      if ListBoxProtocol.ItemByIndex(I) is TListBoxItem then
      begin
        Item := TListBoxItem(ListBoxProtocol.ItemByIndex(I));
        Lines.Add(Item.Text);
      end;

    if (Lines.Count > 0) and TPlatformServices.Current.SupportsPlatformService(
      IFMXClipboardService, IInterface(ClipboardService)) then
      ClipboardService.SetClipboard(Lines.Text);
  finally
    Lines.Free;
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
    pcInfo: Item.TextSettings.FontColor := TAlphaColorRec.Dodgerblue;
    pcWarning: Item.TextSettings.FontColor := TAlphaColorRec.Gold;
    pcError: Item.TextSettings.FontColor := TAlphaColorRec.Red;
  end;

  ListBoxProtocol.AddObject(Item);
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
  end;

  if (not Result) or (Msg.Category = pcMKS) then
    Exit;

  case Msg.Source of
    psForm: Result := CheckBoxForm.IsChecked;
    psParameters: Result := CheckBoxParameters.IsChecked;
    psWorkTable: Result := CheckBoxWorkTable.IsChecked;
    psMeasurement: Result := CheckBoxMeasurement.IsChecked;
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
