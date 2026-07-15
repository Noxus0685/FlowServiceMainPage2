unit uMyCheckListBox;

interface

uses
  System.SysUtils, System.Classes, System.UITypes, FMX.Types, FMX.Controls,
  FMX.Layouts, FMX.ListBox, FMX.Graphics, FMX.Objects;

type
  TMyCheckListBox = class(TListBox)
  private
    FActiveColor: TAlphaColor;
    FUpdatingColor: Boolean;
    FBoldCheckedItems: Boolean;
    FLastCheckedItemIndex: Integer;
    function GetValue: LongWord;
    procedure SetValue(const Value: LongWord);
    procedure SetActiveColor(const Value: TAlphaColor);
    procedure SetBoldCheckedItems(const Value: Boolean);
    procedure UpdateItemColor(Item: TListBoxItem; ImmediateRepaint: Boolean = True);
    procedure OnItemChange(Sender: TObject);
    procedure OnApplyStyleLookup(Sender: TObject);
    procedure OnItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure HookItemEvents;
    procedure UnhookItemEvents;
  protected
    procedure DoChange; override;
    procedure ApplyStyle; override;
    procedure DoEndUpdate; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Value: LongWord read GetValue write SetValue;
    property ActiveColor: TAlphaColor read FActiveColor write SetActiveColor default TAlphaColorRec.Green;
    property BoldCheckedItems: Boolean read FBoldCheckedItems write SetBoldCheckedItems default True;
  end;

procedure Register;

implementation

uses System.Types;

procedure Register;
begin
  RegisterComponents('FP', [TMyCheckListBox]);
end;

{ TMyCheckListBox }

constructor TMyCheckListBox.Create(AOwner: TComponent);
begin
  inherited;
  ShowCheckboxes := True;
  FActiveColor := TAlphaColorRec.Green;
  FUpdatingColor := False;
  FBoldCheckedItems := True;
  FLastCheckedItemIndex := -1;

  // Назначаем обработчик изменения состояния
  OnChange := OnItemChange;

  // Подписываемся на события существующих элементов
  HookItemEvents;
end;

destructor TMyCheckListBox.Destroy;
begin
  UnhookItemEvents;
  inherited;
end;

procedure TMyCheckListBox.HookItemEvents;
var
  i: Integer;
begin
  // Подписываемся на события применения стиля для всех элементов
  for i := 0 to Count - 1 do
  begin
    ListItems[i].OnApplyStyleLookup := OnApplyStyleLookup;
    // Добавляем обработчик MouseDown для каждого элемента
    ListItems[i].OnMouseDown := OnItemMouseDown;
    // Обновляем цвет элемента с немедленной перерисовкой
    UpdateItemColor(ListItems[i], True);
  end;
end;

procedure TMyCheckListBox.UnhookItemEvents;
var
  i: Integer;
begin
  // Отписываемся от событий всех элементов
  for i := 0 to Count - 1 do
  begin
    ListItems[i].OnApplyStyleLookup := nil;
    ListItems[i].OnMouseDown := nil;
  end;
end;

procedure TMyCheckListBox.ApplyStyle;
begin
  inherited;

  // Обновляем цвета всех элементов после применения стиля к списку
  HookItemEvents;
end;

procedure TMyCheckListBox.DoEndUpdate;
begin
  inherited;
  // После завершения массового обновления обновляем все элементы
  if not FUpdatingColor then
  begin
    for var i := 0 to Count - 1 do
      UpdateItemColor(ListItems[i], True);
  end;
end;

procedure TMyCheckListBox.OnApplyStyleLookup(Sender: TObject);
begin
  // Обновляем цвет элемента после применения стиля
  if Sender is TListBoxItem then
  begin
    // Подписываемся на MouseDown для этого элемента
    TListBoxItem(Sender).OnMouseDown := OnItemMouseDown;
    UpdateItemColor(TListBoxItem(Sender), True);
  end;
end;

procedure TMyCheckListBox.OnItemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  Item: TListBoxItem;
  CheckObj: TFmxObject;
  CheckRect: TRectF;
  LocalX, LocalY: Single;
  PointInCheckbox: Boolean;
begin
  if not (Sender is TListBoxItem) then Exit;

  Item := TListBoxItem(Sender);

  // Запоминаем индекс элемента, по которому кликнули
  FLastCheckedItemIndex := Item.Index;

  // Проверяем, был ли клик в области чекбокса
  // Находим объект чекбокса в стиле
  CheckObj := Item.FindStyleResource('check');
  if (CheckObj <> nil) and (CheckObj is TControl) then
  begin
    var CheckControl := TControl(CheckObj);

    // Получаем прямоугольник чекбокса в локальных координатах элемента
    CheckRect := CheckControl.BoundsRect;

    // Проверяем, находится ли точка клика внутри прямоугольника чекбокса
    PointInCheckbox := (X >= CheckRect.Left) and (X <= CheckRect.Right) and
                       (Y >= CheckRect.Top) and (Y <= CheckRect.Bottom);

    // Если клик в области чекбокса, сразу меняем состояние
    if PointInCheckbox then
    begin
      // Инвертируем состояние чекбокса
      Item.IsChecked := not Item.IsChecked;

      // Немедленно обновляем цвет
      UpdateItemColor(Item, True);
    end;
  end;
end;

procedure TMyCheckListBox.OnItemChange(Sender: TObject);
begin
  // Обновляем цвет при изменении состояния
  if not FUpdatingColor then
  begin
    // Если мы знаем, какой элемент изменялся, обновляем его
    if FLastCheckedItemIndex >= 0 then
    begin
      UpdateItemColor(ListItems[FLastCheckedItemIndex], True);
      FLastCheckedItemIndex := -1; // Сбрасываем
    end
    else
    begin
      // Иначе обновляем все элементы
      for var i := 0 to Count - 1 do
        UpdateItemColor(ListItems[i], True);
    end;
  end;
end;

procedure TMyCheckListBox.DoChange;
begin
  inherited;
  if not FUpdatingColor then
  begin
    // Обновляем цвет выделенного элемента
    if ItemIndex >= 0 then
      UpdateItemColor(ListItems[ItemIndex], True);
  end;
end;

function TMyCheckListBox.GetValue: LongWord;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    if ListItems[i].IsChecked then
      Result := Result or (1 shl i);
end;

procedure TMyCheckListBox.SetActiveColor(const Value: TAlphaColor);
begin
  if FActiveColor <> Value then
  begin
    FActiveColor := Value;
    for var i := 0 to Count - 1 do
      UpdateItemColor(ListItems[i], True);
  end;
end;

procedure TMyCheckListBox.SetBoldCheckedItems(const Value: Boolean);
begin
  if FBoldCheckedItems <> Value then
  begin
    FBoldCheckedItems := Value;
    for var i := 0 to Count - 1 do
      UpdateItemColor(ListItems[i], True);
  end;
end;

procedure TMyCheckListBox.SetValue(const Value: LongWord);
var
  i: Integer;
  mask: LongWord;
begin
  FUpdatingColor := True;
  try
    BeginUpdate;
    try
      mask := Value;
      for i := 0 to Count - 1 do
        ListItems[i].IsChecked := (mask and (1 shl i)) <> 0;
    finally
      EndUpdate;
    end;
  finally
    FUpdatingColor := False;
    // Обновляем все элементы с немедленной перерисовкой
    for i := 0 to Count - 1 do
      UpdateItemColor(ListItems[i], True);
  end;
end;

procedure TMyCheckListBox.UpdateItemColor(Item: TListBoxItem; ImmediateRepaint: Boolean = True);
var
  TextObj: TText;
  MarkObj: TFmxObject;
  CheckObj: TFmxObject;
  NeedsRepaint: Boolean;
begin
  if Item = nil then Exit;

  NeedsRepaint := False;

  // Ищем текстовый элемент в стиле
  TextObj := TText(Item.FindStyleResource('text'));

  if TextObj <> nil then
  begin
    if Item.IsChecked then
    begin
      // Проверяем, нужно ли обновлять цвет текста
      if TextObj.TextSettings.FontColor <> FActiveColor then
      begin
        TextObj.TextSettings.FontColor := FActiveColor;
        NeedsRepaint := True;
      end;

      // Проверяем, нужно ли обновлять жирность шрифта
      if FBoldCheckedItems then
      begin
        if not (TFontStyle.fsBold in TextObj.TextSettings.Font.Style) then
        begin
          TextObj.TextSettings.Font.Style := TextObj.TextSettings.Font.Style + [TFontStyle.fsBold];
          NeedsRepaint := True;
        end;
      end
      else
      begin
        if TFontStyle.fsBold in TextObj.TextSettings.Font.Style then
        begin
          TextObj.TextSettings.Font.Style := TextObj.TextSettings.Font.Style - [TFontStyle.fsBold];
          NeedsRepaint := True;
        end;
      end;

      // Ищем и изменяем цвет галочки (mark)
      MarkObj := Item.FindStyleResource('mark');
      if MarkObj <> nil then
      begin
        if MarkObj is TPath then
        begin
          if TPath(MarkObj).Fill.Color <> FActiveColor then
          begin
            TPath(MarkObj).Fill.Color := FActiveColor;
            TPath(MarkObj).Stroke.Color := FActiveColor;
            NeedsRepaint := True;
          end;
        end
        else if MarkObj is TRectangle then
        begin
          if TRectangle(MarkObj).Fill.Color <> FActiveColor then
          begin
            TRectangle(MarkObj).Fill.Color := FActiveColor;
            NeedsRepaint := True;
          end;
        end;
      end;

      // Ищем check (рамка чекбокса)
      CheckObj := Item.FindStyleResource('check');
      if CheckObj <> nil then
      begin
        if CheckObj is TRectangle then
        begin
          if TRectangle(CheckObj).Stroke.Color <> FActiveColor then
          begin
            // Изменяем цвет рамки чекбокса
            TRectangle(CheckObj).Stroke.Color := FActiveColor;
            NeedsRepaint := True;
          end;
        end;
      end;
    end
    else
    begin
      // Возвращаем стандартный цвет текста
      if TextObj.TextSettings.FontColor <> TAlphaColorRec.Black then
      begin
        TextObj.TextSettings.FontColor := TAlphaColorRec.Black;
        NeedsRepaint := True;
      end;

      // Убираем жирный шрифт
      if TFontStyle.fsBold in TextObj.TextSettings.Font.Style then
      begin
        TextObj.TextSettings.Font.Style := TextObj.TextSettings.Font.Style - [TFontStyle.fsBold];
        NeedsRepaint := True;
      end;

      // Возвращаем стандартный цвет галочки
      MarkObj := Item.FindStyleResource('mark');
      if MarkObj <> nil then
      begin
        if MarkObj is TPath then
        begin
          if TPath(MarkObj).Fill.Color <> TAlphaColorRec.Black then
          begin
            TPath(MarkObj).Fill.Color := TAlphaColorRec.Black;
            TPath(MarkObj).Stroke.Color := TAlphaColorRec.Black;
            NeedsRepaint := True;
          end;
        end
        else if MarkObj is TRectangle then
        begin
          if TRectangle(MarkObj).Fill.Color <> TAlphaColorRec.Black then
          begin
            TRectangle(MarkObj).Fill.Color := TAlphaColorRec.Black;
            NeedsRepaint := True;
          end;
        end;
      end;

      // Возвращаем стандартный цвет рамки чекбокса
      CheckObj := Item.FindStyleResource('check');
      if CheckObj <> nil then
      begin
        if CheckObj is TRectangle then
        begin
          if TRectangle(CheckObj).Stroke.Color <> TAlphaColorRec.Gray then
          begin
            TRectangle(CheckObj).Stroke.Color := TAlphaColorRec.Gray;
            NeedsRepaint := True;
          end;
        end;
      end;
    end;

    // Если были изменения и требуется немедленная перерисовка
    if NeedsRepaint and ImmediateRepaint then
    begin
      // Принудительно перерисовываем элемент
      Item.Repaint;
    end
    else if NeedsRepaint then
    begin
      // Если немедленная перерисовка не требуется, но изменения были,
      // помечаем элемент как нуждающийся в перерисовке
      Item.InvalidateRect(Item.LocalRect);
    end;
  end;
end;

end.
