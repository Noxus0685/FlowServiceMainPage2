unit IcsFmxNxMessagingTestMain;

{$I Include\OverbyteIcsDefs.inc}

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
{$IFDEF MSWINDOWS}
    Winapi.Windows, Winapi.Messages,
{$ENDIF}
{$IFDEF POSIX}
    Posix.Pthread,
    Posix.Unistd,
    Posix.SysSelect,
{$ENDIF}
    FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
    FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
    FMX.Memo,
    OverbyteIcsUtils,
    OverbyteIcsTypes,
    NX.Horizon;

type
    TMsgRec = record
        Msg      : Cardinal;
        Instance : TObject;
        WParam   : NativeUInt;
        LParam   : NativeUInt;
    end;
    TMsgRecEvent = type TMsgRec;

    TSendMessageThread = class(TThread)
    private
        FCount : Integer;
    public
        procedure Execute; override;
    end;

    TNxMessagingTestForm = class(TForm)
        HelloWorldButton: TButton;
        StartThreadButton: TButton;
        StopThreadButton: TButton;
        ClearDisplayButton: TButton;
        SendMsg1Button: TButton;
        PostMsg1Button: TButton;
        SubscribeToMsg1Button: TButton;
        DisplayMemo: TMemo;
        SleepButton: TButton;
        procedure ClearDisplayButtonClick(Sender: TObject);
        procedure HelloWorldButtonClick(Sender: TObject);
        procedure PostMsg1ButtonClick(Sender: TObject);
        procedure SendMsg1ButtonClick(Sender: TObject);
        procedure SleepButtonClick(Sender: TObject);
        procedure StartThreadButtonClick(Sender: TObject);
        procedure StopThreadButtonClick(Sender: TObject);
        procedure SubscribeToMsg1ButtonClick(Sender: TObject);
    private
        FThread       : TSendMessageThread;
        FMsg1Count    : Integer;
        FSubscription : INxEventSubscription;
        procedure Display(const Msg : String); overload;
        procedure Display(const Fmt : String; const Args : array of const); overload;
        procedure MsgRecEventHandler(const AEvent: TMsgRecEvent);
    public
        constructor Create(AOwner : TComponent); override;
        destructor  Destroy; override;
    end;

var
  NxMessagingTestForm: TNxMessagingTestForm;

implementation

{$R *.fmx}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TNxMessagingTestForm.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TNxMessagingTestForm.Destroy;
begin
    if Assigned(FSubscription) then begin
        FSubscription.WaitFor;
        NxHorizon.Instance.Unsubscribe(FSubscription);
    end;
    if Assigned(FThread) then begin
        FThread.Terminate;
        FThread.WaitFor;
        FreeAndNil(FThread);
    end;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.ClearDisplayButtonClick(Sender: TObject);
begin
    DisplayMemo.Lines.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.Display(
    const Fmt  : String;
    const Args : array of const);
begin
    Display(System.SysUtils.Format(Fmt, args));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.Display(const Msg: String);
begin
    DisplayMemo.Lines.Add(Msg);
    DisplayMemo.GoToTextEnd;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.HelloWorldButtonClick(Sender: TObject);
begin
    Display('Hello World. ThreadID=%d', [IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.MsgRecEventHandler(const AEvent: TMsgRecEvent);
begin
    Display('MsgRecEventHandler Msg=%d  WParam=%d  LParam=%d. ThreadID=%d',
            [AEvent.Msg, AEvent.WParam, AEvent.LParam, IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.PostMsg1ButtonClick(Sender: TObject);
var
    MsgRec : TMsgRecEvent;
begin
    Inc(FMsg1Count);
    MsgRec.Msg      := WM_USER;
    MsgRec.Instance := Self;
    MsgRec.WParam   := FMsg1Count;
    MsgRec.LParam   := 56;
    NxHorizon.Instance.Send<TMsgRecEvent>(MsgRec, MainAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.SendMsg1ButtonClick(Sender: TObject);
var
    MsgRec : TMsgRecEvent;
begin
    Inc(FMsg1Count);
    MsgRec.Msg      := WM_USER;
    MsgRec.Instance := Self;
    MsgRec.WParam   := FMsg1Count;
    MsgRec.LParam   := 34;
    NxHorizon.Instance.Send<TMsgRecEvent>(MsgRec, MainSync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.SleepButtonClick(Sender: TObject);
begin
    Display('Begin sleeping');
    Sleep(5000);
    Display('End sleeping');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.StartThreadButtonClick(Sender: TObject);
begin
    if Assigned(FThread) then begin
        Display('Thread already running');
        Exit;
    end;
    FThread := TSendMessageThread.Create(True);
    FThread.Start;
    Display('Thread Started');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.StopThreadButtonClick(Sender: TObject);
begin
    if not Assigned(FThread) then begin
        Display('Thread already stopped');
        Exit;
    end;
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNxMessagingTestForm.SubscribeToMsg1ButtonClick(Sender: TObject);
begin
    FSubscription := NxHorizon.Instance.Subscribe<TMsgRecEvent>(MainAsync, MsgRecEventHandler);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSendMessageThread.Execute;
var
    MsgRec : TMsgRecEvent;
begin
    while not Terminated do begin
        Inc(FCount);
        MsgRec.Msg      := WM_USER;
        MsgRec.Instance := Self;
        MsgRec.WParam   := FCount;
        MsgRec.LParam   := 0;
        NxHorizon.Instance.Send<TMsgRecEvent>(MsgRec, MainAsync);
        if Terminated then
            Exit;
        Sleep(50);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
