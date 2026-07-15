unit uMessageConstants;

{ ===== Модуль MessageConstants =====
Модуль идентификаторов используемых сообщений и типов.
}

interface

uses
{$IFDEF MSWINDOWS}
  WinApi.Messages,
{$ENDIF}
  Fmx.Forms,
  Fmx.Controls;

const
{$IFDEF LINUX}
  WM_USER = 1000;
{$ENDIF}
  // Завершение проливки.
  WM_SPILLEND = WM_USER + 10000;

  // Завершение одной точки проливки (для градуировки эталонных расходомеров).
  WM_SPILLPOINTEND = WM_USER + 10001;

  // Команда смены активного элемента управления окна.
  WM_CHANGEACTIVECONTROL = WM_USER + 10002;

  // Обновление состояни порта
  WM_UPDATE_PORT_INFO = WM_USER + 10003;

  //открытие окна
  WM_SHOW_EVCW = WM_USER + 10004;

type
  TWMSpillPointEnd = packed record
    Msg: Longword;
    FlowmeterNumber: Longint;
    PointNumber: Longint;
    Result: Longint;
  end;

type
  TWMChangeActiveControl = packed record
    Msg: Longword;
    Form: TForm;
    WinControl: TControl;
    Result: Longint;
  end;

implementation

end.
