{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Cross platform message manager for ICS, replaced Windows messages to
              work on Windows, Linux, Android and other platforms in the future.
              Only supported for Delphi 10.4 and later, and if ICS_NewMessaging
              is defined. Supports either Delphi messaging if RTL_MESSAGING is
              defined, or Dalija Prasnikar's NxHorizon component.
Creation:     Oct 2024
Updated:      Nov 2024
Version:      V10.0
EMail:        francois.piette@overbyte.be  https://www.overbyte.eu
Support:      https://en.delphipraxis.net/forum/37-ics-internet-component-suite/
Legal issues: Copyright (C) 2022-2024 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium.

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

History:
Oct 30, 2024 V10.0 Baseline.





 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF ICS_INCLUDE_MODE}
unit OverbyteIcsMessMan;
{$ENDIF}

{$I Include\OverbyteIcsDefs.inc}

interface

{$IFDEF ICS_NewMessaging}   { V10 }

uses
{$IFDEF MSWINDOWS}
    Winapi.Windows, Winapi.Messages,
{$ENDIF}
{$IFDEF POSIX}
    Posix.Pthread,
    Posix.Unistd,
    Posix.SysSelect,
{$ENDIF}
    System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
{$IFDEF RTL_MESSAGING}
    System.Messaging,
{$ELSE}
    NX.Horizon,
{$ENDIF}
    System.SyncObjs,
    Generics.Collections,
    OverbyteIcsUtils,
    OverbyteIcsTypes;

const
    INVALID_FILE_HANDLE = -1;

type
{$IFDEF POSIX}
    TFdSet      = fd_set;
    PFdSet      = Pfd_set;
    THANDLE     = Integer;
{$ENDIF}

    TPipeFd = packed record
        Read  : THANDLE;
        Write : THANDLE;
{$IFDEF MSWINDOWS}
        Event : TEvent;
{$ENDIF}
        procedure Clear;
    end;
    PPipeFd = ^TPipeFd;

    TIcsMessageManager = class;

{$IFDEF RTL_MESSAGING}
    TIcsSocMsgListener = TMessageListener;
{$ELSE}
    TIcsSocMsgListener = procedure (const M: TIcsSocMsg) of object;
{$ENDIF}

{$IFDEF RTL_MESSAGING}
    TIcsMessagingHelperThread = class(TThread)
    private
        FPostQueue : TQueue<TIcsSocMsg>; //TMessageBase>;
        FQueueLock : TSynchroObject;
        FPipeFd    : TPipeFd;
        FManager   : TIcsMessageManager;
    protected
        procedure TerminatedSet; override;
        procedure WriteToPipe;
        procedure WaitPipeReadable;
    public
        constructor Create(CreateSuspended: Boolean);
        destructor Destroy; override;
        procedure Execute; override;
        function PostMessage(const Sender: TObject; AMessage: TIcsSocMsg): Boolean; //TMessage);
        property Manager   : TIcsMessageManager read  FManager
                                                write FManager;
    end;
{$ENDIF}

{$IFDEF RTL_MESSAGING}
    // Using Delphi own System.Messaging classes
    TIcsSocMsgSubscription = TIcsSocMsgListener;
    TIcsMessageManager = class(TMessageManager)
    private
        FPostQueue    : TObjectList<TIcsSocMsg>;
        FHelperThread : TIcsMessagingHelperThread;
        class var FMainThreadID : TThreadID;
        // Global instance
        class var FIcsDefaultManager: TIcsMessageManager;
        class function GetIcsDefaultManager: TIcsMessageManager; static;
    public
        constructor Create;
        destructor Destroy; override;
        class procedure FreeIcsDefaultManager;
        class property IcsDefaultManager: TIcsMessageManager read GetIcsDefaultManager;
        class property MainThreadID : TThreadID read  FMainThreadID
                                                write FMainThreadID;
        function PostMessage(const Sender: TObject; AMessage: TIcsSocMsg): Boolean; // overload;
        procedure SendMessage(const Sender: TObject; AMessage: TIcsSocMsg); // overload;
        procedure CleanPostQueue(const Instance : TObject);
        function  SubscribeIcsMessage(MessageListener : TIcsSocMsgListener) : TIcsSocMsgSubscription;
        procedure UnsubscribeIcsMessage(ASubscription : TIcsSocMsgSubscription);
    end;
{$ELSE}
    // Using NX.Horizon messaging classes
    TIcsSocMsgSubscription = INxEventSubscription;
    TIcsMessageManager = class(TNxHorizon)
    private
        class var FMainThreadID : TThreadID;
        // Global instance
        class var FIcsDefaultManager: TIcsMessageManager;
        class function GetIcsDefaultManager: TIcsMessageManager; static;
    public
        constructor Create;
        destructor Destroy; override;
        class property IcsDefaultManager: TIcsMessageManager read GetIcsDefaultManager;
        class property MainThreadID : TThreadID read  FMainThreadID
                                                write FMainThreadID;
        class procedure FreeIcsDefaultManager;
        function PostMessage(const Sender: TObject; AMessage: TIcsSocMsg): Boolean; // overload;
        procedure SendMessage(const Sender: TObject; AMessage: TIcsSocMsg); // overload;
        procedure CleanPostQueue(const Instance : TObject);
        function  SubscribeIcsMessage(MessageListener : TIcsSocMsgListener) : TIcsSocMsgSubscription;
        procedure UnsubscribeIcsMessage(ASubscription : TIcsSocMsgSubscription);
    end;
{$ENDIF}

{$IFDEF POSIX}
//function  GetCurrentThreadID: TThreadID;
procedure CloseHandle(H : THANDLE);
{$ENDIF}

function CreateIcsSocketMessage(Msg: Cardinal; Instance: TObject; WParam: NativeUInt; LParam: NativeUInt): TIcsSocMsg;

{$ENDIF ICS_NewMessaging}   { V10 }

implementation

{$IFDEF ICS_NewMessaging}   { V10 }


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function CreateIcsSocketMessage(Msg: Cardinal; Instance: TObject; WParam: NativeUInt; LParam: NativeUInt): TIcsSocMsg;
begin
{$IFDEF RTL_MESSAGING}
    Result := TIcsSocMsg.CreateEx(Msg, Instance, WParam, LParam);
{$ELSE}
    Result.Msg      := Msg;
    Result.Instance := Instance;
    Result.WParam   := WParam;
    Result.LParam   := LParam;
{$ENDIF}
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TIcsSocMsg }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF RTL_MESSAGING}
constructor TIcsSocMsg.CreateEx(Msg: Cardinal; Instance: TObject; WParam: NativeUInt; LParam: NativeUInt);
var
    MsgRec : TIcsSocketMsgRec;
begin
    MsgRec.Msg      := Msg;
    MsgRec.Instance := Instance;
    MsgRec.WParam   := WParam;
    MsgRec.LParam   := LParam;
    Create(MsgRec);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF POSIX}
{ using Utils IcsGetCurrentthreadId)
function GetCurrentThreadID: TThreadID;
begin
  Exit(TThreadID(pthread_self));
end;  }
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF POSIX}
procedure CloseHandle(H : THANDLE);
begin
    __close(H);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TIcsMessagingTMessageManager }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsMessageManager.CleanPostQueue(const Instance: TObject);
begin

end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TIcsMessageManager.Create;
begin
    inherited Create;
{$IFDEF RTL_MESSAGING}
    FHelperThread := TIcsMessagingHelperThread.Create(TRUE);
    FHelperThread.Manager := Self;
    FHelperThread.Start;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TIcsMessageManager.Destroy;
begin
{$IFDEF RTL_MESSAGING}
    if Assigned(FHelperThread) then
        FHelperThread.Terminate;
{$ENDIF}
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
class procedure TIcsMessageManager.FreeIcsDefaultManager;
begin
    FreeAndNil(FIcsDefaultManager);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
class function TIcsMessageManager.GetIcsDefaultManager: TIcsMessageManager;
begin
    if FIcsDefaultManager = nil then begin
        FIcsDefaultManager := TIcsMessageManager.Create;
{$IFDEF RTL_MESSAGING}
        FIcsDefaultManager.FPostQueue := TObjectList<TIcsSocMsg>.Create(FALSE);
{$ENDIF}
    end;

    Result := FIcsDefaultManager;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TIcsMessageManager.PostMessage( const Sender: TObject; AMessage: TIcsSocMsg): Boolean;
begin
{$IFDEF RTL_MESSAGING}
    Result := FHelperThread.PostMessage(Sender, AMessage);
{$ELSE}
    Send<TIcsSocMsg>(AMessage, MainAsync);
    Result := True;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsMessageManager.SendMessage(const Sender: TObject; AMessage: TIcsSocMsg);
begin
{$IFDEF RTL_MESSAGING}
    if IcsGetCurrentThreadID <> FMainThreadID then
        raise Exception.Create('TIcsMessageManager.SendMessage not called from main thread.');
    inherited SendMessage(Sender, AMessage);
{$ELSE}
    Send<TIcsSocMsg>(AMessage, MainSync);
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TIcsMessageManager.SubscribeIcsMessage(MessageListener: TIcsSocMsgListener): TIcsSocMsgSubscription;
begin
{$IFDEF RTL_MESSAGING}
    TIcsMessageManager.IcsDefaultManager.SubscribeToMessage(TIcsSocMsg, MessageListener);
{$ELSE}
    Result := Subscribe<TIcsSocMsg>(MainAsync, MessageListener);
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsMessageManager.UnsubscribeIcsMessage(ASubscription: TIcsSocMsgSubscription);
begin
{$IFDEF RTL_MESSAGING}
{$ELSE}
    Unsubscribe(ASubscription);
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TIcsMessagingHelperThread }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF RTL_MESSAGING}
constructor TIcsMessagingHelperThread.Create(CreateSuspended: Boolean);
{$IFDEF MSWINDOWS}
var
    saAttr             : TSecurityAttributes;
{$ENDIF}
begin
    inherited Create(TRUE);
    FPostQueue := TQueue<TIcsSocMsg>.Create; //TMessageBase>.Create;
    FQueueLock := TSynchroObject.Create;
{$IFDEF POSIX}
    if pipe(@FPipeFd) <> 0 then begin
{$ENDIF}
{$IFDEF MSWINDOWS}
    FPipeFd.Event               := TEvent.Create(nil, FALSE, FALSE, '');
//    OutputDebugString(PChar(Format('Pipe event created. Handle=%d', [FPipeFd.Event.Handle])));
    saAttr.nLength              := SizeOf(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle       := FALSE;
    saAttr.lpSecurityDescriptor := nil;
    if not CreatePipe(FPipeFd.Read, FPipeFd.Write, @saAttr, 0) then begin
{$ENDIF}
        FPipeFd.Read  := THANDLE(INVALID_FILE_HANDLE);
        FPipeFd.Write := THANDLE(INVALID_FILE_HANDLE);
        raise Exception.Create('pipe() failed');
    end;
    if CreateSuspended = FALSE then
        Start;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TIcsMessagingHelperThread.Destroy;
begin
    FreeAndNil(FQueueLock);
    FreeAndNil(FPostQueue);
{$IFDEF MSWINDOWS}
    FreeandNil(FPipeFd.Event);
{$ENDIF}
    if FPipeFd.Read <> THANDLE(INVALID_FILE_HANDLE) then begin
        CloseHandle(FPipeFd.Read);
        FPipeFd.Read := THANDLE(INVALID_FILE_HANDLE);
    end;
    if FPipeFd.Write <> THANDLE(INVALID_FILE_HANDLE) then begin
        CloseHandle(FPipeFd.Write);
        FPipeFd.Write := THANDLE(INVALID_FILE_HANDLE);
    end;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsMessagingHelperThread.Execute;
var
    MsgItem: TIcsSocMsg; //TMessageBase;
begin
    while not Terminated do begin
        FQueueLock.Acquire;
        if FPostQueue.Count > 0 then begin
            // There is a message in the queue, retrieve it
            MsgItem := FPostQueue.Dequeue;
            FQueueLock.Release;
            // Now we have one message to dispatch to the main thread
            Synchronize(
                procedure
                begin
                    FManager.SendMessage(nil, MsgItem);
                end);
        end
        else begin
            // No message in queue, we must wait for one to be posted
            FQueueLock.Release;
            WaitPipeReadable;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TIcsMessagingHelperThread.PostMessage(const Sender: TObject; AMessage: TIcsSocMsg): Boolean;
begin
    FQueueLock.Acquire;
    try
        FPostQueue.Enqueue(AMessage);
    finally
        FQueueLock.Release;
    end;
    // Write to the pipe to unblock call to select()
    WriteToPipe;
    Result := True;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TIcsMessagingHelperThread.TerminatedSet;
begin
    inherited TerminatedSet;
    // We must write to the pipe to unblock the call to select()
    WriteToPipe;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Write a single byte to the pipe (Windows version)
{$IFDEF MSWINDOWS}
procedure TIcsMessagingHelperThread.WriteToPipe;
var
    ByteWritten : Cardinal;
    Ch          : AnsiChar;
begin
    if FPipeFd.Write <> THANDLE(INVALID_FILE_HANDLE) then
        WriteFile(FPipeFd.Write, Ch, 1, ByteWritten, nil);
    if Assigned(FPipeFd.Event) then
        FPipeFd.Event.SetEvent;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF POSIX}
// Write a single byte to the pipe (POSIX version)
procedure TIcsMessagingHelperThread.WriteToPipe;
var
    Ch          : AnsiChar;
begin
    if FPipeFd.Write <> INVALID_FILE_HANDLE then
        __write(FPipeFd.Write, @Ch, 1);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF MSWINDOWS}
// Wait until something is readable from the pipe (Windows version)
procedure TIcsMessagingHelperThread.WaitPipeReadable;
var
    ByteRead    : Cardinal;
    Ch          : AnsiChar;
begin
    if WaitForSingleObject(FPipeFd.Read, INFINITE) = WAIT_OBJECT_0 then
        ReadFile(FPipeFd.Read, Ch, 1, ByteRead, nil);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Wait until something is readable from the pipe (Posix version)
{$IFDEF POSIX}
procedure TIcsMessagingHelperThread.WaitPipeReadable;
var
    ReadFds     : TFDSet;
    WriteFds    : TFDSet;
    ExceptFds   : TFDSet;
    SelectCount : Integer;
    NSelect     : Integer;
    Ch          : AnsiChar;
begin
    // Prepare call to blocking select()
    FD_ZERO(ReadFds);
    FD_ZERO(WriteFds);
    FD_ZERO(ExceptFds);
    _FD_SET(FPipeFd.Read, ReadFds);
    NSelect := FPipeFd.Read;
    // We will block here until one of our handles is ready
    // It is either pipe handle used for PostMessage event
    // or the socket handle
    SelectCount := select(NSelect + 1, @ReadFds, @WriteFds, @ExceptFds, nil);
    if SelectCount > 0 then begin
        if FD_ISSET(FPipeFd.Read, ReadFds) then
            __read(FPipeFd.Read, @Ch, 1);
    end;
end;
{$ENDIF}
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ TPipeFd }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TPipeFd.Clear;
begin
    Read  := THANDLE(INVALID_FILE_HANDLE);
    Write := THANDLE(INVALID_FILE_HANDLE);
{$IFDEF MSWINDOWS}
    Event := nil;
{$ENDIF}
end;

{$ENDIF ICS_NewMessaging}   { V10 }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF ICS_NewMessaging}   { V10 }
initialization
    TIcsMessageManager.IcsDefaultManager.MainThreadID := IcsGetCurrentThreadID;   { in Utils }
{$ENDIF ICS_NewMessaging}   { V10 }

end.
