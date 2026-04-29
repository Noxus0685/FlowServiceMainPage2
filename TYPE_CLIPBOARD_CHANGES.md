# Изменения: перенос логики буфера типов в DataManager

## Цель изменений
- Убрать бизнес-логику Copy/Paste/Cut из формы `fuTypeSelect`.
- Централизовать буфер копирования типов в `TManagerTTableDM`.
- Сделать вставку в дерево предсказуемой при выборе подветок.

## Что изменено

### 1) `uDataManager.pas`
- Добавлен внутренний буфер типов `FCopiedTypes`.
- Добавлено свойство:
  - `BufferTypes: TList<TDeviceType>`
- Реализованы методы:
  - `SetBufferTypes(const ATypes: TList<TDeviceType>)`
  - `GetBufferTypes: TList<TDeviceType>`
  - `CopyTypesToBuffer(const ATypes: TList<TDeviceType>)`
  - `PasteBufferTypes: TObjectList<TDeviceType>`
  - `CutTypesToBuffer(const ATypes: TList<TDeviceType>)`
  - `HasBufferTypes: Boolean`
  - `AssignTypeTreeFields(const AType: TDeviceType; const ANode: TTreeViewItem)`
- Логика `SetBufferTypes`:
  - очищает буфер;
  - копирует каждый элемент через `Clone`;
  - сохраняет полный снимок типа.
- Логика `GetBufferTypes`:
  - возвращает **новые экземпляры** (клоны), а не ссылки на внутренний буфер.
- Вставка (`PasteBufferTypes`) создаёт новые типы через репозиторий:
  - `ActiveTypeRepo.CreateType(SourceType)`.
- Добавлена защита от повторного входа (`FBufferTypesBusy`) для предотвращения рекурсивных сценариев.
- Добавлена очистка буфера в деструкторе `TManagerTTableDM`.

### 2) `fuTypeSelect.pas`
- Удалён локальный буфер формы `FCopiedTypes`.
- Action-обработчики формы переведены на `AppServices.DataManager`:
  - `actTypeCopyExecute` -> `CopyTypesToBuffer`
  - `actTypePasteExecute` -> `PasteBufferTypes`
  - `actTypeCutExecute` -> `CutTypesToBuffer`
- В форме оставлена UI-ответственность:
  - выбор строк/узла;
  - обновление фильтра/грида;
  - выделение вставленной строки.
- Назначение полей типа по узлу дерева делегировано в:
  - `AppServices.DataManager.AssignTypeTreeFields`.
- `GetActiveTreeNode` переработан:
  - выполняется рекурсивный обход всех подузлов;
  - при множественном выборе выбирается самая глубокая ветка.
- `actTypePaste.Enabled` теперь зависит от:
  - `AppServices.DataManager.HasBufferTypes`.

## Правила замены полей при вставке
- Если выбран узел `Modification`:
  - заменяются `Modification`, `Category`, `Manufacturer`.
- Если выбран узел `Category`:
  - заменяются `Category`, `Manufacturer`.
- Если выбран узел `Manufacturer`:
  - заменяется только `Manufacturer`.
- Если узел не выбран (`nil`):
  - поля назначения не меняются.

## Результат
- Форма стала UI-слоем без хранения бизнес-состояния буфера.
- Буфер копирования типов и операции Copy/Paste/Cut централизованы в DataManager.
- Вставка в подветки дерева работает корректнее за счёт полного обхода дерева и выбора наиболее глубокого выбранного узла.
