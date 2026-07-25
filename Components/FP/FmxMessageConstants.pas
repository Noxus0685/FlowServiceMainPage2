unit FmxMessageConstants;

{ ===== Модуль MessageConstants =====
Модуль идентификаторов используемых сообщений и типов.
}

interface

uses
{$IFDEF MSWINDOWS}
  Messages,
  Windows,
  Vcl.Controls;
{$ELSE}
  Fmx.Forms,
  Fmx.Controls;
{$ENDIF}

const

  // Завершение проливки.
{$IFDEF MSWINDOWS}
  WM_SPILLEND = WM_USER + 10000;
  // Завершение одной точки проливки (для градуировки эталонных расходомеров).
  WM_SPILLPOINTEND = WM_USER + 10001;

  // Команда смены активного элемента управления окна.
  WM_CHANGEACTIVECONTROL = WM_USER + 10002;

  // Обновление состояни порта
  WM_UPDATE_PORT_INFO = WM_USER + 10003;
{$ELSE}
  WM_SPILLEND = 10000;
  // Завершение одной точки проливки (для градуировки эталонных расходомеров).
  WM_SPILLPOINTEND = 10001;

  // Команда смены активного элемента управления окна.
  WM_CHANGEACTIVECONTROL = 10002;

  // Обновление состояни порта
  WM_UPDATE_PORT_INFO = 10003;
{$ENDIF}





type
  TWMSpillPointEnd = packed record
    Msg: Longword;
    FlowmeterNumber: Longint;
    PointNumber: Longint;
    Result: Longint;
  end;


implementation

end.
