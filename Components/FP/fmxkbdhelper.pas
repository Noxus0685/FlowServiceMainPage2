unit fmxkbdhelper;

interface
{$IFDEF MSWINDOWS}
uses Winapi.Windows;
{$ENDIF}
function CtrlDown : Boolean;
function ShiftDown : Boolean;
function AltDown : Boolean;

implementation
function CtrlDown : Boolean;
{$IFDEF MSWINDOWS}
var
  State : TKeyboardState;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  GetKeyboardState(State);
  Result := (State[vk_Control] and 128) <> 0;
{$ENDIF}
{$IFDEF LINUX}
  Result := false;
{$ENDIF}
end;

function ShiftDown : Boolean;
{$IFDEF MSWINDOWS}
var
  State : TKeyboardState;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  GetKeyboardState(State);
  Result := (State[vk_Shift] and 128) <> 0;
{$ENDIF}
{$IFDEF LINUX}
  Result := False;
{$ENDIF}
end;

function AltDown : Boolean;
{$IFDEF MSWINDOWS}
var
  State : TKeyboardState;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  GetKeyboardState(State);
  Result := (State[vk_Menu] and 128) <> 0;
{$ENDIF}
{$IFDEF LINUX}
  Result := False;
{$ENDIF}
end;

end.
