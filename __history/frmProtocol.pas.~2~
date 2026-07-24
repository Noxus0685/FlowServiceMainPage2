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
  FMX.Memo,
  FMX.Layouts,
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
    MemoProtocol: TMemo;
    procedure SpeedButtonResumeClick(Sender: TObject);
    procedure SpeedButtonPauseClick(Sender: TObject);
    procedure SpeedButtonClearClick(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
  private
    FMessages: TObjectList<TProtocolMessage>;
    FListener: TProtocolListener;
    procedure HandleProtocolMessage(Msg: TProtocolMessage);
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
    MemoProtocol.Lines.Add(TProtocolManager.FormatMessage(CopyMsg));
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
  MemoProtocol.Lines.BeginUpdate;
  try
    MemoProtocol.Lines.Clear;
    for Msg in FMessages do
      if IsAllowedByFilters(Msg) then
        MemoProtocol.Lines.Add(TProtocolManager.FormatMessage(Msg));
  finally
    MemoProtocol.Lines.EndUpdate;
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
  MemoProtocol.Lines.Clear;
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
