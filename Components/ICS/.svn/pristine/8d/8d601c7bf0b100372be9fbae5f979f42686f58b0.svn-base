{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Copyright:    You can use this software freely, at your own risks
Creation:     June 2022
Version:      10.0
Last update:  Nov 27, 2024
Object:       This is just a test program to help developping ICS. Its aim
              is to test for the messaging system used internally. You should
              not normally use it unless you are curious.
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
Support:      https://en.delphipraxis.net/forum/37-ics-internet-component-suite/
Legal issues: Copyright (C) 2024 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Updates:
Jul 2022 - V9.00 - This program is part of ICSv9 beta.

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit IcsFmxMessagingTestMain;

{$I Include\OverbyteIcsDefs.inc}

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes,
    System.Variants, System.Messaging, System.SyncObjs, Generics.Collections,
    FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
    FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
    FMX.StdCtrls, FMX.Edit,

{$IFDEF MSWINDOWS}
    OverbyteIcsWinsock,
{$ENDIF}
{$IFDEF POSIX}
    Posix.Pthread,
    Posix.Unistd,
    Posix.SysSelect,
{$ENDIF}
    OverbyteIcsUtils,
    OverbyteIcsTypes,
    Ics.Fmx.OverbyteIcsMessMan,
    Ics.Fmx.OverbyteIcsWSocket,
    OverbyteIcsLogger;


type
    TIcsSendMessageThread = class(TThread)
    private
        FCount : Integer;
    public
        procedure Execute; override;
    end;

    TMessagingTestForm = class(TForm)
        HelloWorldButton: TButton;
        Memo1: TMemo;
        SendMsg1Button: TButton;
        SubscribeToMsg1Button: TButton;
        StartThreadButton: TButton;
        StopThreadButton: TButton;
        ConnectSocketButton: TButton;
        PostMsg1Button: TButton;
        CreateSocketButton: TButton;
        PipeWriteButton: TButton;
        DataEdit: TEdit;
        SendDataButton: TButton;
        Label1: TLabel;
        CloseSocketButton: TButton;
        ClearDisplayButton: TButton;
        UdpBroadcastButton: TButton;
        procedure ClearDisplayButtonClick(Sender: TObject);
        procedure CloseSocketButtonClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure ConnectSocketButtonClick(Sender: TObject);
        procedure CreateSocketButtonClick(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure HelloWorldButtonClick(Sender: TObject);
        procedure PipeWriteButtonClick(Sender: TObject);
        procedure PostMsg1ButtonClick(Sender: TObject);
        procedure SendDataButtonClick(Sender: TObject);
        procedure SendMsg1ButtonClick(Sender: TObject);
        procedure StartThreadButtonClick(Sender: TObject);
        procedure StopThreadButtonClick(Sender: TObject);
        procedure SubscribeToMsg1ButtonClick(Sender: TObject);
        procedure UdpBroadcastButtonClick(Sender: TObject);
    procedure IcsLoggerIcsLogEvent(Sender: TObject; LogOption: TLogOption; const Msg: string);
    private
    protected
        FThread          : TIcsSendMessageThread;
        FMsg1Count       : Integer;
        FSubscription    : TIcsSocketMessageSubscription;
        FAppSubscription : TIcsSocketMessageSubscription;
        FWSocket         : TWSocket;
        FIcsLogger       : TIcsLogger;
        procedure Display(const Msg : String); overload;
        procedure Display(const Fmt : String; const Args : array of const); overload;
        procedure IcsMessageListener({$IFDEF RTL_MESSAGING}const Sender: TObject;{$ENDIF} const M: TMessage);
        procedure AppIcsSocketMessageListener({$IFDEF RTL_MESSAGING}const Sender: TObject;{$ENDIF} const M: TMessage);
        procedure WSocketSessionConnected(Sender: TObject; ErrCode: WORD);
        procedure WSocketSendData(Sender: TObject; BytesSent: Integer);
        procedure WSocketDataSent(Sender: TObject; ErrCode: WORD);
        procedure WSocketDataAvailable(Sender: TObject; ErrCode: WORD);
        procedure WSocketSessionClosed(Sender: TObject; ErrCode: WORD);
        procedure WSocketErrorHandler(Sender: TObject);
        procedure WSocketExceptionHandler(Sender: TObject; E: ESocketException);
    public

    end;

var
  MessagingTestForm: TMessagingTestForm;

implementation

{$R *.fmx}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.FormCreate(Sender: TObject);
begin
    FIcsLogger := TIcsLogger.Create(Self);
    FIcsLogger.LogOptions := [loDestOutDebug, loAddStamp, loWsockErr, loWsockInfo, loSslErr, loSslInfo, loProtSpecErr, loProtSpecInfo];
    FIcsLogger.LogOptions := FIcsLogger.LogOptions + [loWsockDump];  // suppress line to reduce message logging
    FIcsLogger.OnIcsLogEvent := IcsLoggerIcsLogEvent;
    FAppSubscription := TIcsMessageManager.IcsDefaultManager.SubscribeIcsMessage(AppIcsSocketMessageListener);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.AppIcsSocketMessageListener({$IFDEF RTL_MESSAGING}const Sender: TObject;{$ENDIF}  const M: TMessage);
var
//    Msg     : TIcsSocketMessage;
    Value   : TIcsSocketMsgRec;
//    WSocket : TIcsCustomWSocket;
begin
{$IFDEF RTL_MESSAGING}
    Value := M.Value;
//    Msg     := M as TIcsSocketMessage;
{$ELSE}
    Value := TIcsSocketMsgRec(M);
{$ENDIF}
//    WSocket := Msg.Value.Instance as TIcsCustomWSocket;
    case Value.Msg of
    WM_ICS_TEST :
        begin
            Display('WM_ICS_TEST. ThreadID=%d', [IcsGetCurrentThreadID]);
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.ClearDisplayButtonClick(Sender: TObject);
begin
    Memo1.Lines.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.CloseSocketButtonClick(Sender: TObject);
begin
    if not Assigned(FWSocket) then begin
        Display('Socket not created yet.');
        Exit;
    end;
    Display('Closing Socket');
    FWSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.ConnectSocketButtonClick(Sender: TObject);
begin
    if not Assigned(FWSocket) then begin
        Display('Socket not created yet.');
        Exit;
    end;
    FWSocket.Addr  := '192.168.1.101';
//    FWSocket.Addr  := '2a02:a03f:a131:1a00:f8be:c694:4b64:40b9';
    FWSocket.Port  := 'telnet';
    FWSocket.Proto := 'tcp';
    FWSocket.Connect;
    Display('Connecting to ' + FWSocket.Addr);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.CreateSocketButtonClick(Sender: TObject);
begin
    if Assigned(FWSocket) then begin
        Display('Socket already created');
        Exit;
    end;

    FWSocket                    := TWSocket.Create(Self);
    FWSocket.OnSessionConnected := WSocketSessionConnected;
    FWSocket.OnDataAvailable    := WSocketDataAvailable;
    FWSocket.OnDataSent         := WSocketDataSent;
    FWSocket.OnSendData         :=  WSocketSendData;
    FWSocket.OnSessionClosed    := WSocketSessionClosed;
//    FWSocket.OnError            := WSocketErrorHandler;
    FWSocket.OnException        := WSocketExceptionHandler;
    FWSocket.IcsLogger          := FIcsLogger;
    Display('Socket created');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.Display(const Fmt: String; const Args: array of const);
begin
    Display(System.SysUtils.Format(Fmt, args));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.Display(const Msg: String);
begin
    Memo1.Lines.Add(Msg);
    Memo1.GoToTextEnd;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketSessionConnected(Sender: TObject; ErrCode: WORD);
begin
    Display('Socket connected. Error=%d ThreadID=%d', [ErrCode, IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketErrorHandler(Sender: TObject);
begin
    Display('Socket error. ThreadID=%d', [IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketExceptionHandler(Sender: TObject;  E: ESocketException);
begin
    Display('Socket Exception %s:%s. ThreadID=%d', [E.ClassName, E.Message, IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketSessionClosed(Sender: TObject;  ErrCode: WORD);
begin
    Display('Socket disconnected. Error=%d ThreadID=%d', [ErrCode, IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketDataSent(Sender: TObject; ErrCode: WORD);
begin
    Display('Socket data sent. Error=%d ThreadID=%d', [ErrCode, IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketSendData(Sender: TObject; BytesSent: Integer);
begin
    Display('Socket sending data, Count=%d', [BytesSent]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.WSocketDataAvailable(Sender: TObject;  ErrCode : WORD);
var
    Buf : AnsiString;
    Len : Integer;
begin
    if ErrCode <> 0 then begin
        Display('Socket DataAvailable. Error=%d ThreadID=%d', [ErrCode, IcsGetCurrentThreadID]);
        Exit;
    end;
    SetLength(Buf, 2000);
    Len := FWSocket.Receive(PAnsiChar(Buf), Length(Buf) - 1);
    if Len < 0 then begin
        if WSocket_GetLastError() = WSAEWOULDBLOCK then
            Exit;
        Display('Socket DataAvailable. ThreadID=%d. Receive error %d', [IcsGetCurrentThreadID, WSocket_GetLastError]);
        Exit;
    end;
    if Len = 0 then begin
        Display('Socket DataAvailable. ThreadID=%d. Received 0 bytes. Remote closed?', [IcsGetCurrentThreadID]);
        Exit;
    end;
    SetLength(Buf, Len);
    Display('Socket DataAvailable. ThreadID=%d. Received %d bytes: >%s', [IcsGetCurrentThreadID, Len, String(Buf)]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.FormDestroy(Sender: TObject);
begin
    if Assigned(FSubscription) then
        TIcsMessageManager.IcsDefaultManager.UnsubscribeIcsMessage(
            FSubscription);
    if Assigned(FAppSubscription) then
        TIcsMessageManager.IcsDefaultManager.UnsubscribeIcsMessage(
            FAppSubscription);
    FreeAndNil(FWSocket);
    if Assigned(FThread) then begin
        FThread.Terminate;
        FThread.WaitFor;
        FreeAndNil(FThread);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.HelloWorldButtonClick(Sender: TObject);
begin
    Display('Hello World. ThreadID=%d', [IcsGetCurrentThreadID]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.IcsLoggerIcsLogEvent(Sender: TObject; LogOption: TLogOption; const Msg: string);
begin
    Display(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.IcsMessageListener(
{$IFDEF RTL_MESSAGING}
    const Sender : TObject;
{$ENDIF}
    const M      : TMessage);
var
    I     : Integer;
    Value : TIcsSocketMsgRec;
begin
{$IFDEF RTL_MESSAGING}
    if not (M is TIcsSocketMessage) then
        Exit;
    Value := TIcsSocketMessage(M).Value;
{$ELSE}
    Value := TIcsSocketMsgRec(M);
{$ENDIF}
    Display('Enter listener Msg=%d WParam=%d  LParam=%d  ThreadID=%d  Tick=%d',
            [Value.Msg,
             Value.WParam,
             Value.LParam,
             IcsGetCurrentThreadID,
             TThread.GetTickCount]);
    for I := 1 to 5 do begin
        Application.HandleMessage;         // Will repaint the window
//        Sleep(400);
        Display('  Loop listener %d WParam=%d  Tick=%d',
                [I,
                 Value.WParam,
                 TThread.GetTickCount]);
    end;
    Display('Exit listener WParam=%d  Tick=%d',
            [Value.WParam, TThread.GetTickCount]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.PipeWriteButtonClick(Sender: TObject);
begin
    if not Assigned(FWSocket) then begin
        Display('Socket not created yet.');
        Exit;
    end;
//    FWSocket.XXXPipeWrite(PIPE_CMD_SENDMESSAGE);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.PostMsg1ButtonClick(Sender: TObject);
begin
    Inc(FMsg1Count);
    TIcsMessageManager.IcsDefaultManager.PostMessage(Self, CreateIcsSocketMessage(WM_USER, Self, FMsg1Count, 34));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.SendDataButtonClick(Sender: TObject);
var
    Buf : AnsiString;
begin
    if not Assigned(FWSocket) then begin
        Display('Socket not created yet.');
        Exit;
    end;
    Buf := AnsiString(DataEdit.Text) + #13#10;
    FWSocket.Send(PAnsiChar(Buf), Length(Buf));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.SendMsg1ButtonClick(Sender: TObject);
var
    MsgItem   : TIcsSocketMessage;
begin
    Inc(FMsg1Count);
    MsgItem := CreateIcsSocketMessage(WM_USER, Self, FMsg1Count, 34);
    TIcsMessageManager.IcsDefaultManager.SendMessage(Self, MsgItem);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.StartThreadButtonClick(Sender: TObject);
begin
    if Assigned(FThread) then begin
        Display('Thread already running');
        Exit;
    end;
    FThread := TIcsSendMessageThread.Create(True);
    FThread.Start;
    Display('Thread Started');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.StopThreadButtonClick(Sender: TObject);
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
procedure TMessagingTestForm.SubscribeToMsg1ButtonClick(Sender: TObject);
begin
    FSubscription := TIcsMessageManager.IcsDefaultManager.SubscribeIcsMessage(
        IcsMessageListener);
    Display('Subscribed to TIcsSocketMessage.');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMessagingTestForm.UdpBroadcastButtonClick(Sender: TObject);
begin
    if not Assigned(FWSocket) then begin
        Display('Socket not created yet.');
        Exit;
    end;
    if FWSocket.State <> wsConnected then begin
        FWSocket.Proto      := 'udp';
        FWSocket.Port       := '600';
        FWSocket.LocalPort  := '0';
        FWSocket.Addr       := '255.255.255.255';  // Broadcast IP
        // UDP is connectionless. Connect will just open the socket
        FWSocket.Connect;
    end;
    FWSocket.SendStr(FormatDateTime('HH:NN:SS', Now) + '>' + DataEdit.Text);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TIcsSendMessageThread }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsSendMessageThread.Execute;
var
    MsgItem   : TIcsSocketMessage;
begin
    while not Terminated do begin
        Inc(FCount);
        Synchronize(
            procedure
            begin
                MsgItem := CreateIcsSocketMessage(WM_USER, Self, FCount, 0);
                TIcsMessageManager.IcsDefaultManager.SendMessage(
                       Self, MsgItem);
            end);
        if Terminated then
            Exit;
        Sleep(50);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
