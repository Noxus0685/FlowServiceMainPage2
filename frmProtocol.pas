unit frmProtocol;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.ListBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.SysUtils,
  System.UITypes,
  uProtocols;

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
    ListBoxProtocol: TListBox;
    procedure SpeedButtonResumeClick(Sender: TObject);
    procedure SpeedButtonPauseClick(Sender: TObject);
    procedure SpeedButtonClearClick(Sender: TObject);
    procedure SpeedButtonExportClick(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
  private
    FMessages: TObjectList<TProtocolMessage>;
    FListener: TProtocolListener;
    procedure HandleProtocolMessage(Msg: TProtocolMessage);

    procedure AddProtocolItem(const Msg: TProtocolMessage);
    function IsAllowedByFilters(Msg: TProtocolMessage): Boolean;
    procedure RebuildMemo;
    procedure ExportProtocolToFile;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

constructor TFrameProtocol.Create(AOwner: TComponent);
var
  BtnExport: TSpeedButton;
begin
  inherited;
  FMessages := TObjectList<TProtocolMessage>.Create(True);
  ListBoxProtocol.ShowScrollBars := True;
  ListBoxProtocol.AniCalculations.AutoShowing := False;
  ListBoxProtocol.VertScrollBar.Visible := True;
  ListBoxProtocol.VertScrollBar.Enabled := True;
  ListBoxProtocol.HorzScrollBar.Visible := True;
  ListBoxProtocol.HorzScrollBar.Enabled := True;

  CheckBoxEvent.IsChecked := True;
  CheckBoxState.IsChecked := True;
  CheckBoxAction.IsChecked := True;
  CheckBoxForm.IsChecked := True;
  CheckBoxParameters.IsChecked := True;
  CheckBoxWorkTable.IsChecked := True;
  CheckBoxMeasurement.IsChecked := True;

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
  end;

  if not Result then
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

procedure TFrameProtocol.SpeedButtonPauseClick(Sender: TObject);
begin
  ProtocolManager.Pause;
end;

procedure TFrameProtocol.SpeedButtonResumeClick(Sender: TObject);
begin
  ProtocolManager.Resume;
end;

end.
