unit UnitControlRegister;

interface

uses
  System.Generics.Defaults,
  System.SysUtils,
  System.UITypes,
  System.TypInfo,
  System.Rtti,
  uObservable;

type
  // Состояние синхронизации регистра относительно контроллера.
  EStateControlRegister = (
    crsUnknown = 0,   // нет достоверных данных
    crsActual,        // значение совпадает с контроллером
    crsMismatch,      // значение отличается от контроллера
    crsPending,       // локальное значение ещё не записано в контроллер
    crsError          // ошибка обмена с контроллером
  );

  // Тип действия регистра (по аналогии с action-событиями в параметрах/насосах).
  EActionControlRegister = (
    craNone,
    craWriteToController, // требуется запись в контроллер
    craReadFromController // требуется чтение из контроллера
  );

  // События регистра (по аналогии с event-событиями в параметрах/насосах).
  EEventControlRegister = (
    creNone,
    creStateChanged,
    creActionRequested,
    creError
  );

  // Универсальный регистр значения.
  // Не содержит прямого IO с контроллером: только состояние, данные и уведомления.
  TControlRegister<T> = class(TObservableObject)
  private
    FDefaultValue: T;        // значение по умолчанию (конфигурация/TDevice)
    FValue: T;               // текущее локальное значение (пользовательское)
    FControllerValue: T;     // последнее известное значение из контроллера
    FState: EStateControlRegister;
    FAction: EActionControlRegister;
    FEvent: EEventControlRegister;
    FComparer: TFunc<T, T, Boolean>; // функция сравнения значений
    FEpsilon: Double;                 // точность для вещественных типов

    procedure SetState(const AState: EStateControlRegister);
    procedure SetAction(const AAction: EActionControlRegister);
    procedure SetEventKind(const AEvent: EEventControlRegister);
  public
    constructor Create(AComparer: TFunc<T, T, Boolean> = nil; const AEpsilon: Double = 0.0001);

    // Значения регистра.
    property Value: T read FValue;
    property DefaultValue: T read FDefaultValue;
    property ControllerValue: T read FControllerValue;

    // Служебные состояния/события.
    property State: EStateControlRegister read FState;
    property Action: EActionControlRegister read FAction;
    property EventKind: EEventControlRegister read FEvent;

    // Инициализация значением из конфигурации.
    procedure FromDefault(const AValue: T);

    // Изменение локального значения (обычно пользователем).
    procedure SetValue(const AValue: T);

    // Приём значения, прочитанного из контроллера.
    procedure FromController(const AValue: T);

    // Явный запрос действий (для внешнего слоя обмена).
    procedure RequestWriteToController;
    procedure RequestReadFromController;

    // Отметки результатов обмена.
    procedure MarkWritten;
    procedure MarkError;

    // Пересчёт состояния синхронизации.
    procedure UpdateState;

    // Сброс регистра в исходное состояние.
    procedure Reset;

    // Цветовые помощники для UI.
    class function StateToColor(const AState: EStateControlRegister): TAlphaColor; static;
    class function StateToColorName(const AState: EStateControlRegister): string; static;
    function GetStateColor: TAlphaColor;
    function GetStateColorName: string;
  end;

implementation

uses
  System.Math;

{ TControlRegister<T> }

constructor TControlRegister<T>.Create(AComparer: TFunc<T, T, Boolean>; const AEpsilon: Double);
begin
  inherited Create;

  FEpsilon := AEpsilon;

  if Assigned(AComparer) then
    FComparer := AComparer
  else
    FComparer :=
      function(const A, B: T): Boolean
      var
        Kind: TTypeKind;
      begin
        Kind := PTypeInfo(TypeInfo(T))^.Kind;

        // Для вещественных типов используем сравнение с epsilon.
        if Kind in [tkFloat] then
          Exit(SameValue(TValue.From<T>(A).AsExtended, TValue.From<T>(B).AsExtended, FEpsilon));

        // Для Integer/Enum и остальных типов используем стандартное равенство.
        Result := TEqualityComparer<T>.Default.Equals(A, B);
      end;

  FState := crsUnknown;
  FAction := craNone;
  FEvent := creNone;
end;

procedure TControlRegister<T>.FromController(const AValue: T);
begin
  FControllerValue := AValue;
  SetAction(craNone);
  UpdateState;
end;

procedure TControlRegister<T>.FromDefault(const AValue: T);
begin
  FDefaultValue := AValue;
  FValue := AValue;
  SetAction(craWriteToController);
  SetState(crsPending);
end;

function TControlRegister<T>.GetStateColor: TAlphaColor;
begin
  Result := StateToColor(FState);
end;

function TControlRegister<T>.GetStateColorName: string;
begin
  Result := StateToColorName(FState);
end;

procedure TControlRegister<T>.MarkError;
begin
  SetState(crsError);
  SetEventKind(creError);
  Notify(notifyEvent, Self);
end;

procedure TControlRegister<T>.MarkWritten;
begin
  FControllerValue := FValue;
  SetAction(craNone);
  SetState(crsActual);
end;

procedure TControlRegister<T>.RequestReadFromController;
begin
  SetAction(craReadFromController);
  SetEventKind(creActionRequested);
  Notify(notifyAction, Self);
end;

procedure TControlRegister<T>.RequestWriteToController;
begin
  SetAction(craWriteToController);
  SetEventKind(creActionRequested);
  Notify(notifyAction, Self);
end;

procedure TControlRegister<T>.Reset;
begin
  FDefaultValue := Default(T);
  FValue := Default(T);
  FControllerValue := Default(T);
  SetAction(craNone);
  SetEventKind(creNone);
  SetState(crsUnknown);
end;

procedure TControlRegister<T>.SetAction(const AAction: EActionControlRegister);
begin
  FAction := AAction;
end;

procedure TControlRegister<T>.SetEventKind(const AEvent: EEventControlRegister);
begin
  FEvent := AEvent;
end;

procedure TControlRegister<T>.SetState(const AState: EStateControlRegister);
begin
  if FState = AState then
    Exit;

  FState := AState;
  SetEventKind(creStateChanged);
  Notify(notifyStateChanged, Self);
end;

procedure TControlRegister<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  SetAction(craWriteToController);
  UpdateState;
end;

class function TControlRegister<T>.StateToColor(
  const AState: EStateControlRegister): TAlphaColor;
begin
  case AState of
    crsActual:
      Result := TAlphaColorRec.Limegreen;  // зелёный
    crsMismatch:
      Result := TAlphaColorRec.Gold;       // жёлтый
    crsPending:
      Result := TAlphaColorRec.Gray;       // серый
    crsError:
      Result := TAlphaColorRec.Red;        // красный
    crsUnknown:
      Result := TAlphaColorRec.Lightgray;  // светлый
  else
    Result := TAlphaColorRec.Lightgray;
  end;
end;

class function TControlRegister<T>.StateToColorName(
  const AState: EStateControlRegister): string;
begin
  case AState of
    crsActual:   Result := 'зелёный';
    crsMismatch: Result := 'жёлтый';
    crsPending:  Result := 'серый';
    crsError:    Result := 'красный';
    crsUnknown:  Result := 'светлый';
  else
    Result := 'светлый';
  end;
end;

procedure TControlRegister<T>.UpdateState;
begin
  if FComparer(FControllerValue, FValue) then
    SetState(crsActual)
  else
    SetState(crsMismatch);
end;

end.
