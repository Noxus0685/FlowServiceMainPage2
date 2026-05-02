# UnitControlRegister

Модуль `UnitControlRegister.pas` содержит универсальный класс `TControlRegister<T>` для хранения значений параметров и контроля их синхронизации с контроллером.

## Назначение

Класс:
- хранит значения из разных источников (`DefaultValue`, `Value`, `ControllerValue`);
- вычисляет состояние синхронизации (`State`);
- не выполняет прямой обмен с контроллером (без `Read/Write`);
- отправляет уведомления через `TObservableObject.Notify`.

## Основные типы

> Внутри класса нет ветвления по типу `T`.
> По умолчанию класс сам выбирает сравнение:
> - для `Double/Float` использует `SameValue(..., Epsilon)`;
> - для `Integer/Enum` и остальных типов использует стандартное равенство.
> При необходимости можно передать собственный `AComparer`.


- `EStateControlRegister` — состояние синхронизации:
  - `crsUnknown` — нет данных;
  - `crsActual` — совпадает с контроллером;
  - `crsMismatch` — отличается от контроллера;
  - `crsPending` — не записано в контроллер;
  - `crsError` — ошибка обмена.

- `EActionControlRegister` — запрошенное действие:
  - `craWriteToController` — нужно записать значение;
  - `craReadFromController` — нужно прочитать значение.

- `EEventControlRegister` — служебное событие:
  - изменение состояния;
  - запрос действия;
  - ошибка.

## Поведение методов

- `FromDefault(AValue)`
  - инициализирует `DefaultValue` и `Value`;
  - выставляет `State = crsPending`;
  - устанавливает `Action = craWriteToController`.

- `SetValue(AValue)`
  - меняет `Value`;
  - выставляет `Action = craWriteToController`;
  - пересчитывает `State` через `UpdateState`.

- `FromController(AValue)`
  - обновляет `ControllerValue`;
  - сбрасывает `Action`;
  - пересчитывает `State`.

- `MarkWritten()`
  - синхронизирует `ControllerValue := Value`;
  - устанавливает `State = crsActual`.

- `MarkError()`
  - устанавливает `State = crsError`;
  - отправляет событие ошибки (`notifyEvent`).

- `RequestWriteToController()` / `RequestReadFromController()`
  - фиксируют требуемое действие;
  - отправляют `notifyAction`.

- `Reset()`
  - сбрасывает значения в `Default(T)`;
  - переводит регистр в `crsUnknown`.

## Уведомления (Notify)

Класс наследуется от `TObservableObject` и отправляет:
- `notifyStateChanged` при изменении `State`;
- `notifyAction` при запросе операций записи/чтения;
- `notifyEvent` при ошибке обмена.

Это позволяет интегрировать регистр в ту же модель подписок, что и классы типа `TPump`.

## Цвет для UI

Используйте:
- `StateToColor(State): TAlphaColor`;
- `StateToColorName(State): string`.

Соответствие:
- `crsActual` → зелёный;
- `crsMismatch` → жёлтый;
- `crsPending` → серый;
- `crsError` → красный;
- `crsUnknown` → светлый.

## Сравнение по умолчанию (без передачи AComparer)

```pascal
var
  Reg: TControlRegister<Double>;
begin
  // AComparer не передаём, будет SameValue с Epsilon=0.001
  Reg := TControlRegister<Double>.Create(nil, 0.001);
end;
```

## Пример кастомного сравнения

```pascal
uses System.Math;

var
  Reg: TControlRegister<Double>;
begin
  Reg := TControlRegister<Double>.Create(
    function(const A, B: Double): Boolean
    begin
      Result := SameValue(A, B, 0.001);
    end
  );
end;
```
