{ Редактор палитр }
unit upalcolorchooser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ShellCtrls, StdCtrls,
  Grids, ExtCtrls, Types, IniFiles;

type

  { TfrmPalEditor }

  TfrmPalEditor = class(TForm)
    btnAddColorToPal: TButton;
    btnReadFromFile: TButton;
    btnSaveToFile: TButton;
    btnSelectColor: TButton;
    btnSetColor: TButton;
    ColorDialog1: TColorDialog;
    edColorAlias: TEdit;
    edColorValue: TEdit;
    lbAboutApp: TLabel;
    lbColorAlias: TLabel;
    lbColorValue: TLabel;
    lbPal: TLabel;
    OpenDialog1: TOpenDialog;
    panActionsWithPalFile: TPanel;
    panColorDetails: TPanel;
    panPal: TPanel;
    SaveDialog1: TSaveDialog;
    sgPal: TStringGrid;
    Shape1: TShape;
    procedure btnReadFromFileClick(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure btnSelectColorClick(Sender: TObject);
    procedure btnSetColorClick(Sender: TObject);
    procedure btnAddColorToPalClick(Sender: TObject);
    procedure sgPalDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  private

  public

  end;

var
  frmPalEditor: TfrmPalEditor;

implementation

{$R *.lfm}


  { TfrmPalEditor }

{ Преобразовывает rgb к TColor}
function convRgbToColor(colorRGB: string): TColor;
var
  r, g, b: Byte;
begin
  // Если ошибочное значение - возвращаем черный цвет
  if (Length(colorRGB) <> 7) or (colorRGB[1] <> '#') then begin
    result := clBlack;
    exit;
  end;

  // Разбор шестнадцатеричных для красного R, зеленого G, синего B
  r := StrToInt('$' + Copy(colorRGB, 2, 2));
  g := StrToInt('$' + Copy(colorRGB, 4, 2));
  b := StrToInt('$' + Copy(colorRGB, 6, 2));

  //  Используем функцию RGBToColor из модуля Graphics,
  // чтобы переобразовать к TColor
  Result := RGBToColor(r, g, b);
end;

{ Преобразовывает к строке формата #rrggbb цвет в формате TColor  }
function ColorToRGBString(color: TColor): string;
var
  r, g, b: Byte;
begin
  r := color and $FF;
  g := (color shr 8) and $FF;
  b := (color shr 16) and $FF;
  Result := Format('#%.2x%.2x%.2x', [r, g, b]);
end;

{ Обработчик выбора цвета - вызывает диалоговое окно выбора цвета}
procedure TfrmPalEditor.btnSelectColorClick(Sender: TObject);
begin
  if ColorDialog1.Execute then begin
     Shape1.Brush.Color:=frmPalEditor.ColorDialog1.Color;
     edColorValue.Text := ColorToRGBString(frmPalEditor.ColorDialog1.Color);
  end;
end;

{ Сохраняет палитру в файл }
procedure TfrmPalEditor.btnSaveToFileClick(Sender: TObject);
var
  ini: TIniFile;
  i: Integer;
  Section: string;
  fileName: string;
begin
  if not SaveDialog1.Execute then Exit;

  fileName := SaveDialog1.FileName; // Или любой другой путь/имя файла
  ini := TIniFile.Create(fileName);
  try
    // Очищаем файл перед записью новых данных
    ini.EraseSection('Grid');
    // Сохраняем количество строк
    ini.WriteInteger('Grid', 'RowCount', sgPal.RowCount);
    // Перебираем строки (начиная со строки 1, если 0 - заголовок)
    for i := 0 to sgPal.RowCount - 1 do
    begin
      Section := 'Row' + IntToStr(i);
      ini.WriteString(Section, 'Col0', sgPal.Cells[0, i]);
      ini.WriteString(Section, 'Col1', sgPal.Cells[1, i]);
      ini.WriteString(Section, 'Col2', sgPal.Cells[2, i]);
    end;
  finally
    ini.Free;
  end;
end;

{ Считывает палитру из файла }
procedure TfrmPalEditor.btnReadFromFileClick(Sender: TObject);
var
  ini: TIniFile;
  i, rowCnt: Integer;
  Section: string;
  fileName: string;
begin
  if not OpenDialog1.Execute then Exit;
  fileName := OpenDialog1.FileName; // Имя файла должно совпадать с тем, что используется при сохранении
  ini := TIniFile.Create(fileName);
  try
    rowCnt := ini.ReadInteger('Grid', 'RowCount', 1);
    sgPal.RowCount := rowCnt;
    // Загружаем данные по каждой строке
    for i := 0 to rowCnt - 1 do
    begin
      Section := 'Row' + IntToStr(i);
      sgPal.Cells[0, i] := ini.ReadString(Section, 'Col0', '');
      sgPal.Cells[1, i] := ini.ReadString(Section, 'Col1', '');
      sgPal.Cells[2, i] := ini.ReadString(Section, 'Col2', '');
    end;
    // Можно добавить перерисовку грида
    sgPal.Invalidate;
  finally
    ini.Free;
  end;
end;


{ Установка цвета по значению #rrggbb из однострочного поля }
procedure TfrmPalEditor.btnSetColorClick(Sender: TObject);
var someColor : TColor;
begin
  someColor := convRgbToColor( frmPalEditor.edColorValue.Text  );
    shape1.Brush.Color:=someColor;
    colordialog1.Color:=someColor;
end;

{ Добавление пары псевдоним цвета, код цвета к палитре }
procedure TfrmPalEditor.btnAddColorToPalClick(Sender: TObject);
var
  newRow: Integer;
  colorStr: string;
begin
  // Допустим, colorStr берётся из edColorValue.Text — пользователь вводит цвет в формате '#rrggbb'
  colorStr := edColorValue.Text;

  // Проверяем, что colorStr валидный
  if (Length(colorStr) <> 7) or (colorStr[1] <> '#') then
  begin
    ShowMessage('Введите цвет в формате #RRGGBB');
    Exit;
  end;

  newRow := sgPal.RowCount;
  sgPal.RowCount := newRow + 1;

  // Заполняем ячейки новой строки
  sgPal.Cells[0, newRow] := '___';
  sgPal.Cells[1, newRow] := colorStr;
  sgPal.Cells[2, newRow] := edColorAlias.Text;

  // Перерисовать сетку, чтобы применить фон к первому столбцу
  sgPal.Invalidate;
end;

{ отрисовка ячеек в таблице с палитрой, первая колонка - просмотр
оттенка, вторая колонка - код цвета, третья - псевдоним цвета}
procedure TfrmPalEditor.sgPalDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  bgColor: TColor;
  cellText: string;
begin

   cellText := sgPal.Cells[aCol, aRow];

  if aCol = 0 then
  begin
    // Определяем цвет из второго столбца той же строки
    bgColor := convRgbToColor(sgPal.Cells[1, aRow]);
    sgPal.Canvas.Brush.Color := bgColor;
    sgPal.Canvas.FillRect(aRect);


    sgPal.Canvas.TextRect(aRect, aRect.Left + 2, aRect.Top + 2, cellText);
  end
  else
  begin
    // Остальные ячейки рисуем стандартно
    sgPal.Canvas.Brush.Color := clWhite;
    sgPal.Canvas.FillRect(aRect);
    sgPal.Canvas.Font.Color := clBlack;
    sgPal.Canvas.TextRect(aRect, aRect.Left + 2, aRect.Top + 2, cellText);
  end;
end;


end.

