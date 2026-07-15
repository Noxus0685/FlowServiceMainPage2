// ImageListHelper.pas
unit ImageListHelper;

interface

uses
  System.Classes, System.Types, System.UITypes, System.SysUtils,
  FMX.Objects,
  FMX.Graphics, FMX.ImgList, FMX.MultiResBitmap;

type
  TImageListHelper = class helper for TImageList
  public
    // Основные методы
    function Add(aBitmap: TBitmap): integer; overload;
    function Add(const FileName: string): integer; overload;
    function AddFromResource(const ResourceName: string): integer;

    // Управление
    procedure Clear;
    procedure Delete(Index: Integer);

    // Информация
    function ImageExists(Index: Integer): Boolean;
    function GetImageCount: Integer;

    // Дополнительные методы
    function AddScaled(aBitmap: TBitmap; Scale: Single = 1.0): integer;
  end;


implementation

uses
  System.Generics.Collections;


// Проверка наличия элемента с определенным масштабом
function HasScale(MultiResBitmap: TFixedMultiResBitmap; Scale: Single): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to MultiResBitmap.Count - 1 do
  begin
    if (MultiResBitmap.Items[i] is TCustomBitmapItem) and
       (Abs(TCustomBitmapItem(MultiResBitmap.Items[i]).Scale - Scale) < 0.01) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

// Получение элемента с определенным масштабом
function GetBitmapItemByScale(MultiResBitmap: TFixedMultiResBitmap;
  Scale: Single): TCustomBitmapItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to MultiResBitmap.Count - 1 do
  begin
    if (MultiResBitmap.Items[i] is TCustomBitmapItem) and
       (Abs(TCustomBitmapItem(MultiResBitmap.Items[i]).Scale - Scale) < 0.01) then
    begin
      Result := TCustomBitmapItem(MultiResBitmap.Items[i]);
      Break;
    end;
  end;
end;

// Обновление изображения с сохранением всех масштабов
procedure UpdateImageWithAllScales(ImageObj: TImage; Bitmap: TBitmap);
var
  i: Integer;
  OldItem, NewItem: TCustomBitmapItem;
  OldScale: Single;
begin
  // Запоминаем старые масштабы
  var Scales: TList<Single> := TList<Single>.Create;
  try
    for i := 0 to ImageObj.MultiResBitmap.Count - 1 do
    begin
      if ImageObj.MultiResBitmap.Items[i] is TCustomBitmapItem then
      begin
        OldItem := TCustomBitmapItem(ImageObj.MultiResBitmap.Items[i]);
        Scales.Add(OldItem.Scale);
      end;
    end;

    // Очищаем и добавляем заново с сохранением масштабов
    ImageObj.MultiResBitmap.Clear;

    for OldScale in Scales do
    begin
      NewItem := ImageObj.MultiResBitmap.Add as TCustomBitmapItem;
      NewItem.Scale := OldScale;

      // Масштабируем исходное изображение
      var ScaledBitmap := TBitmap.Create;
      try
        ScaledBitmap.SetSize(Round(Bitmap.Width * OldScale),
                           Round(Bitmap.Height * OldScale));
        ScaledBitmap.Canvas.BeginScene;
        try
          ScaledBitmap.Canvas.DrawBitmap(
            Bitmap,
            RectF(0, 0, Bitmap.Width, Bitmap.Height),
            RectF(0, 0, ScaledBitmap.Width, ScaledBitmap.Height),
            1
          );
        finally
          ScaledBitmap.Canvas.EndScene;
        end;
        NewItem.Bitmap.Assign(ScaledBitmap);
      finally
        ScaledBitmap.Free;
      end;
    end;
  finally
    Scales.Free;
  end;
end;



{ TImageListHelper }

function TImageListHelper.Add(aBitmap: TBitmap): integer;
const
  SCALE = 1;
var
  vSource: TCustomSourceItem;
  vBitmapItem: TCustomBitmapItem;
  vDest: TCustomDestinationItem;
  vLayer: TLayer;
begin
  Result := -1;
  if (aBitmap.Width = 0) or (aBitmap.Height = 0) then exit;

  // add source bitmap
  vSource := Source.Add;
  vSource.MultiResBitmap.TransparentColor := TColorRec.Fuchsia;
  vSource.MultiResBitmap.SizeKind := TSizeKind.Source;
  vSource.MultiResBitmap.Width := Round(aBitmap.Width / SCALE);
  vSource.MultiResBitmap.Height := Round(aBitmap.Height / SCALE);
  vBitmapItem := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);
  if vBitmapItem = nil then
  begin
    vBitmapItem := vSource.MultiResBitmap.Add;
    vBitmapItem.Scale := Scale;
  end;
  vBitmapItem.Bitmap.Assign(aBitmap);

  vDest := Destination.Add;
  vLayer := vDest.Layers.Add;
  vLayer.SourceRect.Rect := TRectF.Create(TPoint.Zero, vSource.MultiResBitmap.Width,
      vSource.MultiResBitmap.Height);
  vLayer.Name := vSource.Name;
  Result := vDest.Index;
end;


function TImageListHelper.Add(const FileName: string): integer;
var
  Bitmap: TBitmap;
begin
  Result := -1;
  if not FileExists(FileName) then Exit;

  Bitmap := TBitmap.Create;
  try
    try
      Bitmap.LoadFromFile(FileName);
      Result := Self.Add(Bitmap);
    except
      on E: Exception do
        raise Exception.CreateFmt('Ошибка загрузки файла %s: %s', [FileName, E.Message]);
    end;
  finally
    Bitmap.Free;
  end;
end;

function TImageListHelper.AddFromResource(const ResourceName: string): integer;
var
  Stream: TResourceStream;
  Bitmap: TBitmap;
begin
  Result := -1;
  Bitmap := TBitmap.Create;
  Stream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    try
      Bitmap.LoadFromStream(Stream);
      Result := Self.Add(Bitmap);
    except
      on E: Exception do
        raise Exception.CreateFmt('Ошибка загрузки ресурса %s: %s', [ResourceName, E.Message]);
    end;
  finally
    Stream.Free;
    Bitmap.Free;
  end;
end;

procedure TImageListHelper.Clear;
begin
  Self.Source.Clear;
  Self.Destination.Clear;
end;

procedure TImageListHelper.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < Self.Source.Count) then
  begin
    Self.Source.Delete(Index);
    // Также нужно удалить соответствующий Destination item
    if Index < Self.Destination.Count then
      Self.Destination.Delete(Index);
  end;
end;

function TImageListHelper.ImageExists(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index < Self.Source.Count);
end;

function TImageListHelper.GetImageCount: Integer;
begin
  Result := Self.Source.Count;
end;

function TImageListHelper.AddScaled(aBitmap: TBitmap; Scale: Single = 1.0): integer;
var
  ScaledBitmap: TBitmap;
begin
  if Scale = 1.0 then
    Result := Add(aBitmap)
  else
  begin
    ScaledBitmap := TBitmap.Create;
    try
      ScaledBitmap.SetSize(Round(aBitmap.Width * Scale), Round(aBitmap.Height * Scale));
      ScaledBitmap.Canvas.BeginScene;
      try
        ScaledBitmap.Canvas.DrawBitmap(
          aBitmap,
          RectF(0, 0, aBitmap.Width, aBitmap.Height),
          RectF(0, 0, ScaledBitmap.Width, ScaledBitmap.Height),
          1
        );
      finally
        ScaledBitmap.Canvas.EndScene;
      end;
      Result := Add(ScaledBitmap);
    finally
      ScaledBitmap.Free;
    end;
  end;
end;


end.
