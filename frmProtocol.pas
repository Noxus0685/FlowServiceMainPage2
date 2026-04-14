unit frmProtocol;

interface

uses
  UnitProtocols,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Graphics,
  FMX.Controls.Presentation;

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
    procedure FilterChanged(Sender: TObject);
  private
    FMessages: TObjectList<TProtocolMessage>;
    FListener: TProtocolListener;
    procedure HandleProtocolMessage(Msg: TProtocolMessage);

    procedure AddProtocolItem(const Msg: TProtocolMessage);
    function IsAllowedByFilters(Msg: TProtocolMessage): Boolean;
    procedure RebuildMemo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

constructor TFrameProtocol.Create(AOwner: TComponent);
begin
  inherited;
  FMessages := TObjectList<TProtocolMessage>.Create(True);

  CheckBoxEvent.IsChecked := True;
  CheckBoxState.IsChecked := True;
  CheckBoxAction.IsChecked := True;
  CheckBoxForm.IsChecked := True;
  CheckBoxParameters.IsChecked := True;
  CheckBoxWorkTable.IsChecked := True;
  CheckBoxMeasurement.IsChecked := True;

  FListener :=
    procedure(Msg: TProtocolMessage)
    begin
      HandleProtocolMessage(Msg);
    end;

  ProtocolManager.Subscribe(FListener);
end;

destructor TFrameProtocol.Destroy;
begin
  ProtocolManager.Unsubscribe(FListener);
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

procedure TFrameProtocol.SpeedButtonPauseClick(Sender: TObject);
begin
  ProtocolManager.Pause;
end;

procedure TFrameProtocol.SpeedButtonResumeClick(Sender: TObject);
begin
  ProtocolManager.Resume;
end;

end.
