# colorpalette

Приложение для создания палитр т.е. наборов цветов 
Application for creating palettes e.g. sets of colors

Screenshot Снимок экрана
![colorpalette](https://dl.dropbox.com/scl/fi/pmdqlgfj3sb27asil3o9k/_20250728_120507.png?rlkey=apy8jrcpfccapcw5vqijrufe1&st=h0b4jwxw)


Функции программы:
- добавление цвета в палитру
- установка значения согласно коду цвета
- выбор цвета в т.ч. из экрана
- сохранение палитры в файл
- загрузка палитры из файла
- подсветка ячейки таблицы соответствующим цветом
- удаление строки по нажатию delete

Program functions:
- adding a color to the palette
- setting the value according to the color code
- choosing a color, including from the screen
- saving the palette to a file
- loading the palette from a file
- highlighting the table cell with the corresponding color
- remove row by pressing Delete key

Примечание: цвета сохраняются в кодах RGB формата `'#rrggbb'`
Note: colors are stored in RGB codes of the format `'#rrggbb'`

Формат файла палитры - ini.
Format palette file is the ini.

Example of the palette file
Пример файла палитры

```
[Grid]
RowCount=3

[Row0]
Col0=___
Col1=#FF5500
Col2=оранжевый

[Row1]
Col0=___
Col1=#FF007F
Col2=пурпурный

[Row2]
Col0=___
Col1=#AAFF7F
Col2=светло-зеленый
```
