unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Menus, ExtDlgs;

const
  //максимальна розмірність масиву координат
  CMAS_MAXSIZE = 100;
  //радіус вершини, в межах координат якого не можна додати нової вершини
  CNODE_RADIUS = 20;

type
  //масив чисел
  TVECT = array [1..CMAS_MAXSIZE] of integer;
  //матриця
  TMATRIX = array[1..CMAS_MAXSIZE, 1..2] of integer;


  { TfrmMain }

  TfrmMain = class(TForm)
    BitBtn1: TBitBtn;
    Image1: TImage;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SavePictureDialog1: TSavePictureDialog;
    Separator1: TMenuItem;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
  private

  public
    //початкова ініціалізація усіх даних
    procedure PrepareData;
    //очистка зображення перед малюванням
    procedure ClearImage;
    //намалювати вершину графа в координатах x,y з індексом N
    procedure draw_graph_node(X, Y, N: integer);
    //намалювати граф повністю
    procedure DrawGraph;
    //знайти по координатах вершину і повернути її номер, інакше повернути -1
    function FindNodeByXY(x, y: integer): integer;
    //знайти існуюче ребро і повернути його номер, інакше повернути -1
    function FindEdgeByNodes(start, finish: integer): integer;
    //видалити ребро по його номеру
    procedure RemoveEdge(num: integer);
    //видалити вершину і усі пов'язані з нею ребра рекурсивно
    procedure RemoveNode(nodenum: integer);
  end;

var
  frmMain: TfrmMain;

  //кількість вершин
  NodesCount: integer;
  //масиви координат по x,y і номерів вершин
  mas_x, mas_y, mas_n: TVECT;
  //кількість ребер
  EdgesCount: integer;
  //матриця суміжності двох вешнин для ребра
  edges: TMATRIX;
  //координати початку і кінця для ребра
  startnode, endnode: integer;
  //координати поточної позиції мишки при малюванні ребра
  tmppoint: TPoint;
  //ознака режиму видалення
  deletemode: boolean;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //Підготовка інтерфейсу і ініціалізація змінних
  PrepareData;
  ClearImage;
end;

procedure TfrmMain.BitBtn1Click(Sender: TObject);
begin
  //Підготовка програми до роботи - ініціалізація даних та очистка зображення
  PrepareData;
  ClearImage;
end;

procedure TfrmMain.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i: integer;
  p: integer; //№ вершини
begin
  //режим додавання вершин
  if (SpeedButton1.Down = True) then
  begin
    //якщо натиснута ліва кнопка мишки
    if (ssLeft in Shift) then
    begin
      p := FindNodeByXY(x, y);
      //додаємо нову вершину
      if p = -1 then
      begin
        NodesCount := NodesCount + 1;
        MAS_X[NodesCount] := X;
        MAS_Y[NodesCount] := Y;
        MAS_N[NodesCount] := NodesCount;
        draw_graph_node(x, y, NodesCount);
      end
      else
      begin
        //такі координати вже зайняті - вершину не додаємо
        Memo1.Lines.Add(
          'В цьому місці вже існує вершина!');
        Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
      end;
    end
    //права кнопка мишки - видалення вершини
    else if (ssRight in Shift) then
    begin
      p := FindNodeByXY(x, y);
      if p <> -1 then
      begin
        RemoveNode(p);
      end;
    end;
  end;
  //режим додавання ребер
  if (SpeedButton2.Down = True) then
  begin
    //якщо менше двох вершин, не можна додати ребро
    if NodesCount < 2 then
    begin
      Memo1.Lines.Add('Недостатньо вершин, щоб додати ребро!');
      Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
      Exit;
    end;
    //якщо натиснуто праву кнопку мишки, режим видалення ребра
    if (ssRight in Shift) then deletemode := True
    else if (ssLeft in Shift) then deletemode := False;
    //шукаємо координати обраної вершини
    startnode := FindNodeByXY(x, y);
    endnode := -1;
  end;
  ClearImage;
  DrawGraph;
end;

procedure TfrmMain.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  //якщо не обрано режим малювання ребер або недостатньо вершин, нічого не робимо
  if (NodesCount < 2) or (SpeedButton1.Down) or (startnode = -1) then Exit;
  if ((ssLeft in Shift) or (ssRight in Shift)) then
  begin
    ClearImage;
    DrawGraph;
    //малюємо лінію від обраної вершири до поточних координат
    Image1.Canvas.Pen.Style := psSolid;
    Image1.Canvas.Pen.Color := clRed;
    Image1.Canvas.MoveTo(mas_x[startnode], mas_y[startnode]);
    Image1.Canvas.LineTo(x, y);
  end;
end;

procedure TfrmMain.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  newedge: integer;
begin
  //не режим додавння ребер - нічого не робимо
  if SpeedButton1.Down then Exit;
  endnode := FindNodeByXY(x, y);
  if endnode = -1 then
  begin
    Memo1.Lines.Add('Не обрано кінцеву вершину!');
    Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
    Exit;
  end;
  //шукаємо № ребра
  newedge := FindEdgeByNodes(startnode, endnode);

  case deletemode of
    False: begin
      if (newedge = -1) then
      begin
        EdgesCount := EdgesCount + 1;
        edges[EdgesCount, 1] := startnode;
        edges[EdgesCount, 2] := endnode;
      end;
    end;
    True: begin
      if newedge <> -1 then RemoveEdge(newedge);
    end;
  end;

  //оновлюємо зображення графа
  ClearImage;
  DrawGraph;
end;

procedure TfrmMain.MenuItem2Click(Sender: TObject);
var
  f : TextFile;
  i: Integer;
begin
  //Зберегти файл з графом
  if NodesCount=0 then Exit; //Якщо немає жодної вершини, немає що зберігати
  SaveDialog1.InitialDir:=ExtractFileDir(Application.ExeName);
  if SaveDialog1.Execute then begin
   AssignFile(f,SaveDialog1.FileName);
   Rewrite(f);
   WriteLn(f,NodesCount);
   for i:=1 to NodesCount do begin
     WriteLN(f,mas_x[i]);
     WriteLN(f,mas_y[i]);
   end;
   WriteLn(f,EdgesCount);
   if EdgesCount<>0 then for i := 1 to EdgesCount do begin
    WriteLn(f,edges[i,1]);
    WriteLn(f,edges[i,2]);
   end;
   CloseFile(f);
  end;
end;

procedure TfrmMain.MenuItem3Click(Sender: TObject);
var
  f : TextFile;
  i: Integer;
  s : String;
begin
  //Прочитати файл з графом, очистивши попередню інформацію
  PrepareData;
  ClearImage;
  OpenDialog1.InitialDir:=ExtractFileDir(Application.ExeName);
  if OpenDialog1.Execute then begin
   AssignFile(f,OpenDialog1.FileName);
   Reset(f);
   ReadLN(f,s);
   NodesCount:=StrToInt(s);
   for i:=1 to NodesCount do begin
     ReadLN(f,s);
     mas_x[i]:=StrToInt(s);
     ReadLN(f,s);
     mas_y[i]:=StrToInt(s);
   end;
   ReadLN(f,s);
   EdgesCount:=StrToInt(s);
   if EdgesCount<>0 then for i := 1 to EdgesCount do begin
     ReadLN(f,s);
     edges[i,1]:=StrToInt(s);
     ReadLN(f,s);
     edges[i,2]:=StrToInt(s);
   end;
   CloseFile(f);
  end;
  ClearImage;
  DrawGraph;
end;

procedure TfrmMain.MenuItem4Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.MenuItem5Click(Sender: TObject);
begin
  ShowMessage('Графобудівник - програма для візуальної побудови графів.');
end;

procedure TfrmMain.MenuItem6Click(Sender: TObject);
begin
  SavePictureDialog1.InitialDir:=ExtractFileDir(Application.ExeName);
  if SavePictureDialog1.Execute then begin
   Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TfrmMain.PrepareData;
var
  i: integer;
begin
  //ініціалізація змінних
  NodesCount := 0;
  EdgesCount := 0;
  for i := 1 to CMAS_MAXSIZE do
  begin
    mas_x[i] := 0;
    mas_y[i] := 0;
    mas_n[i] := 0;
    edges[i, 1] := 0;
    edges[i, 2] := 0;
  end;
end;

procedure TfrmMain.ClearImage;
begin
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));
end;

procedure TfrmMain.draw_graph_node(X, Y, N: integer);
begin
  with Image1 do
  begin
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clActiveCaption;
    Canvas.Ellipse(X - 12, Y - 12, X + 12, Y + 12);
    Canvas.TextOut(X - (Length(IntToStr(N)) * 3), Y - 5, IntToStr(N));
  end;
end;

procedure TfrmMain.DrawGraph;
var
  i: integer;
begin
  if NodesCount = 0 then Exit;
  for i := 1 to NodesCount do draw_graph_node(mas_x[i], mas_y[i], mas_n[i]);
  if EdgesCount = 0 then Exit;
  for i := 1 to EdgesCount do
  begin
    //малюємо лінію від обраної вершини до порточних координат
    Image1.Canvas.Pen.Style := psSolid;
    Image1.Canvas.Pen.Color := clGreen;
    Image1.Canvas.Line(mas_x[edges[i, 1]], mas_y[edges[i, 1]],mas_x[edges[i, 2]], mas_y[edges[i, 2]]);
   { WriteLN('x1=',mas_x[edges[i, 1]],', y1=',mas_y[edges[i, 1]],'; ','x2=',mas_x[edges[i, 2]],', y2=',mas_y[edges[i, 2]]);
    WriteLN('edges[i,1]=',edges[i,1],';','edges[i,2]=',edges[i,2],'; i=',i);}
  end;
  Invalidate;
end;

function TfrmMain.FindNodeByXY(x, y: integer): integer;
var
  i: integer;
begin
  Result := -1;
  if NodesCount = 0 then Exit;
  for i := 1 to NodesCount do
  begin
    if (X > (MAS_X[i] - CNODE_RADIUS)) and (X < (MAS_X[i] + CNODE_RADIUS)) and
      (Y > (MAS_Y[i] - CNODE_RADIUS)) and (Y < (MAS_Y[i] + CNODE_RADIUS)) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TfrmMain.FindEdgeByNodes(start, finish: integer): integer;
var
  i: integer;
begin
  Result := -1;
  if EdgesCount = 0 then Exit;
  for i := 1 to EdgesCount do
  begin
    //при пошуку потрібно враховувати, що початкова і кінцева вершини можуть бути поміняні місцями
    if ((edges[i, 1] = start) and (edges[i, 2] = finish)) or
      ((edges[i, 2] = start) and (edges[i, 1] = finish)) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TfrmMain.RemoveEdge(num: integer);
var
  i: integer;
begin
  if num = -1 then Exit;
  if num < EdgesCount then
  begin
    for i := num to EdgesCount - 1 do
    begin
      edges[i, 1] := edges[i + 1, 1];
      edges[i, 2] := edges[i + 1, 2];
    end;
  end;
  edges[EdgesCount, 1] := 0;
  edges[EdgesCount, 2] := 0;
  EdgesCount := EdgesCount - 1;
end;

procedure TfrmMain.RemoveNode(nodenum: integer);
var
  found: boolean;
  //ознака знайденого ребра з потрібною вершиною
  i, j: integer;
begin
  found := False;
  for i := 1 to EdgesCount do
  begin
    if (edges[i, 1] = nodenum) or (edges[i, 2] = nodenum) then
    begin
      //якщо було знайдено ребро з зазначеною вершиною, видаляємо його
      //і перериваємо цикл зі встановленням ознаки
      RemoveEdge(i);
      Found := True;
      Break;
    end;
  end;
  //якщо ознака встановлена, виконуємо процедуру рекурсивно
  if found then begin
    RemoveNode(nodenum);
    Exit;
  end
  else
  begin
    //ознака не встановлена - вершина більше не прив'язана до жодного з ребер,
    //отже її можна видалити (по аналогії видалення ребра - зміщуємо елементи масиву)
    if nodenum < NodesCount then
    begin
      for j := nodenum to NodesCount - 1 do
      begin
        mas_x[j] := mas_x[j + 1];
        mas_y[j] := mas_y[j + 1];
        mas_n[j] := j;
      end;
    end;
    //очищаємо останній елемент масивів і зменшуємо кількість вершин
    mas_x[NodesCount] := 0;
    mas_y[NodesCount] := 0;
    mas_n[NodesCount] := 0;
    NodesCount := NodesCount - 1;
    //поправка на поточну кількість вершин
    if EdgesCount>0 then for j:=1 to EdgesCount do begin
      if edges[j,1]>=NodesCount then edges[j,1]:=edges[j,1]-1;
      if edges[j,2]>=NodesCount then edges[j,2]:=edges[j,2]-1;
    end;
  end;
end;

end.
