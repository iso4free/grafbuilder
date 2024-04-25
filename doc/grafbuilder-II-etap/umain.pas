unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Menus, ExtDlgs;

const
  //максимальна розмірність масиву координат
  CMAS_MAXSIZE = 10;
  //радіус вершини, в межах координат якого не можна додати нової вершини
  CNODE_RADIUS = 20;
  H = 0.01;

type
  //масив чисел
  TVECT = array [1..CMAS_MAXSIZE] of integer;
  //матриця
  TMATRIX = array[1..CMAS_MAXSIZE, 1..CMAS_MAXSIZE] of integer;
  TMAS1 = array[1..2, 1..2] of real;
  TVECT1 = array[1..2] of real;
  TVECT2 = array[1..4] of TPoint;


  { TfrmMain }

  TfrmMain = class(TForm)
    bbNewGraf: TBitBtn;
    bbWidth: TBitBtn;
    bbDepth: TBitBtn;
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
    sbAddNode: TSpeedButton;
    sbAddEdge: TSpeedButton;
    procedure BbNewGraph(Sender: TObject);
    procedure bbWidthClick(Sender: TObject);
    procedure bbDepthClick(Sender: TObject);
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
    procedure draw_graph_node(X, Y, N: integer; nodecolor: TColor = clActiveCaption);
    //намалювати ребра
    procedure draw_graph_edge;
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
    //перевірити чи вершина має грані
    function NodeHasEdges(nodenum: integer): boolean;
    //функція пошуку в глибину
    procedure depth_search(k: integer; n: integer);
    //відобразити напрямок обходу вершин стрілками
    procedure set_edges_direction(Mas: TMATRIX; EdgeColor: TColor);
    //допоміжні функції для розрахунків
    function f1(x, y: real; x1, y1, x2, y2: real): real;
    function f2(x, y: real; a, b, r: real): real;
    function df1x(x, y: real; x1, y1, x2, y2: real): real;
    function df2x(x, y: real; a, b, r: real): real;
    function df1y(x, y: real; x1, y1, x2, y2: real): real;
    function df2y(x, y: real; a, b, r: real): real;
    //функція розв'язку квадратних систем лінійних алгебраїчних рівнянь із ненульовим визначником основної матриці методом Крамера
    //використовується при визначенні напрямку обходу
    function kramer(A: TMAS1; b: TVECT1): TVECT1;
    //визначник матриці
    function det(A: TMAS1): real;
    function multiply(A: TMAS1; b: TVECT1): TVECT1;
    //пошук в ширину
    procedure search_tree_bild(A: TMatrix; X: TVECT; Y: TVECT;
      V: TVECT; N: integer);
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
  //тут будемо запам`ятовувати № вибраної вершини
  //  SelectedNode: integer;
  //змінні для пошуку в глибину
  depth: boolean;
  a1: TMATRIX;
  V, V0, V1, V2: TVECT;
  glob_counter: integer;
  rezstr, connectivity_components: string;
  isConnectivity: boolean;


implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //Підготовка інтерфейсу і ініціалізація змінних
  PrepareData;
  ClearImage;
end;

procedure TfrmMain.BbNewGraph(Sender: TObject);
begin
  //Підготовка програми до роботи - ініціалізація даних та очистка зображення
  PrepareData;
  ClearImage;
end;

procedure TfrmMain.bbWidthClick(Sender: TObject);
var
  i, j, m, z, l1, l2, k, kk: integer;
begin
  if NodesCount = 0 then
  begin
    Memo1.Lines.Add(
      'Граф немає вершин, пошук в глибину неможливий!');
    Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
    Exit;
  end;
  ClearImage;
  DrawGraph;
  depth := True;
  isConnectivity := True;
  rezstr := '';
  connectivity_components := '';
  for Glob_Counter := 1 to NodesCount do
  begin
    V[Glob_Counter] := 0;
    V0[Glob_Counter] := 0;
  end;
  A1 := Edges;
  m := 1;
  l1 := m;
  V0[m] := 1;
  V1 := V0;
  V[1] := 0;
  kk := 1;
  while (True) do
  begin
    l2 := 0;
    for z := 1 to l1 do
    begin
      i := V1[z];
      for j := 1 to NodesCount do
        if (A1[i, j] = 1) then
        begin
          k := 0;
          for Glob_Counter := 1 to m do
            if (V0[Glob_Counter] = j) then
            begin
              k := k + 1;
              if (A1[j, i] <> 2) and (A1[j, i] <> 3) then
                A1[i, j] := 2;
            end;
          if (k = 0) then
          begin
            A1[i, j] := 3;
            m := m + 1;
            V0[m] := j;
            l2 := l2 + 1;
            V2[l2] := j;
            V[j] := kk;
          end;
        end;
    end;
    l1 := l2;
    V1 := V2;
    kk := kk + 1;
    if (l1 = 0) then
      break;
  end;
  search_tree_bild(A1, MAS_X, MAS_Y, V, NodesCount);
end;

procedure TfrmMain.bbDepthClick(Sender: TObject);
var
  ii, i1, j1, k: integer;
begin
  if NodesCount = 0 then
  begin
    Memo1.Lines.Add(
      'Граф немає вершин, пошук в глибину неможливий!');
    Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
    Exit;
  end;
  ClearImage;
  DrawGraph;
  //пошук в глибину, обхід від вибраної вершини
  depth := True;
  isConnectivity := True;
  rezstr := '';
  connectivity_components := '';
  //вважаємо, що граф зв'язний по замовчуванню
  for ii := 1 to NodesCount do
    V[ii] := 0;
  A1 := Edges;
  while (glob_counter < NodesCount) do
  begin
    if (glob_counter = 0) then
    begin
      glob_counter := glob_counter + 1;
      V[glob_counter] := 1;
    end
    else
    begin
      for i1 := 1 to NodesCount do
      begin
        k := 0;
        for j1 := 1 to glob_counter do
          if (V[j1] = i1) then
            k := k + 1;
        if (k = 0) then
          break;
      end;
      glob_counter := glob_counter + 1;
      V[glob_counter] := i1;
    end;
    rezstr := IntToStr(V[glob_counter]);
    depth_search(V[glob_counter], NodesCount);

    if (connectivity_components = '') then
      connectivity_components := '{' + rezstr + '}'
    else
    begin
      connectivity_components := connectivity_components + ', {' + rezstr + '}';
      isConnectivity := False;
    end;
  end;
  search_tree_bild(A1, MAS_X, MAS_Y, V, NodesCount);
  if isConnectivity then
    Memo1.Lines.Add('Граф зв''язний')
  else
    Memo1.Lines.Add('Граф не зв''язний');
  Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
end;

procedure TfrmMain.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  p: integer; //№ вершини
begin
  if depth then Exit;
  //режим додавання вершин
  if (sbAddNode.Down = True) then
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

        Memo1.Lines.Add(
          'Додано вершину ' + IntToStr(NodesCount));
        Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
        draw_graph_node(x, y, NodesCount);
      end
      else
      begin
        //такі координати вже зайняті - вершину не додаємо а робимо її вибраною
        Memo1.Lines.Add('Така вершина вже є!');
        Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
      end;
    end
    //права кнопка мишки - видалення вершини
    else if (ssRight in Shift) then
    begin
      p := FindNodeByXY(x, y);
      if p <> -1 then
      begin
        if NodeHasEdges(p) then
        begin
          Memo1.Lines.Add(
            'Не можна видалити вершину з прикріпленими ребрами!');
          Memo1.CaretPos := Point(0, Memo1.Lines.Count - 1);
          Exit;
        end
        else
          RemoveNode(p);
      end;
    end;
  end;
  //режим додавання ребер
  if (sbAddEdge.Down = True) then
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
  if depth then Exit;
  //якщо не обрано режим малювання ребер або недостатньо вершин, нічого не робимо
  if (NodesCount < 2) or (sbAddNode.Down) or (startnode = -1) then Exit;
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
  if depth then Exit;
  //не режим додавння ребер - нічого не робимо
  if sbAddNode.Down then Exit;
  endnode := FindNodeByXY(x, y);
  if (endnode = -1) or (endnode = startnode) then
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
        edges[startnode, endnode] := 1;
        edges[endnode, startnode] := 1;
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
  f: TextFile;
  i, j: integer;
begin
  //Зберегти файл з графом
  if NodesCount = 0 then Exit;
  //Якщо немає жодної вершини, немає що зберігати
  SaveDialog1.InitialDir := ExtractFileDir(Application.ExeName);
  if SaveDialog1.Execute then
  begin
    AssignFile(f, SaveDialog1.FileName);
    Rewrite(f);
    WriteLn(f, NodesCount);
    for i := 1 to NodesCount do
    begin
      WriteLN(f, mas_x[i]);
      WriteLN(f, mas_y[i]);
      WriteLN(f, mas_n[i]);
    end;
    WriteLn(f, EdgesCount);
    if EdgesCount <> 0 then for i := 1 to EdgesCount do
        for j := 1 to EdgesCount do
        begin
          WriteLn(f, edges[i, j]);
        end;
    CloseFile(f);
  end;
end;

procedure TfrmMain.MenuItem3Click(Sender: TObject);
var
  f: TextFile;
  i, j: integer;
  s: string;
begin
  //Прочитати файл з графом, очистивши попередню інформацію
  PrepareData;
  ClearImage;
  OpenDialog1.InitialDir := ExtractFileDir(Application.ExeName);
  if OpenDialog1.Execute then
  begin
    AssignFile(f, OpenDialog1.FileName);
    Reset(f);
    ReadLN(f, s);
    NodesCount := StrToInt(s);
    for i := 1 to NodesCount do
    begin
      ReadLN(f, s);
      mas_x[i] := StrToInt(s);
      ReadLN(f, s);
      mas_y[i] := StrToInt(s);
      ReadLn(f, s);
      mas_n[i] := StrToInt(s);
    end;
    ReadLN(f, s);
    EdgesCount := StrToInt(s);
    if EdgesCount <> 0 then for i := 1 to EdgesCount do
        for j := 1 to EdgesCount do
        begin
          ReadLN(f, s);
          edges[i, j] := StrToInt(s);
        end;
    CloseFile(f);
  end;
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
  SavePictureDialog1.InitialDir := ExtractFileDir(Application.ExeName);
  if SavePictureDialog1.Execute then
  begin
    Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TfrmMain.PrepareData;
var
  i, j: integer;
begin
  //ініціалізація змінних
  NodesCount := 0;
  EdgesCount := 0;
  for i := 1 to CMAS_MAXSIZE do
  begin
    mas_x[i] := 0;
    mas_y[i] := 0;
    mas_n[i] := 0;
    V[i] := 0;
    for j := 1 to CMAS_MAXSIZE do
    begin
      edges[i, j] := 0;
      A1[i, j] := 0;
    end;
  end;
  depth := False;
  sbAddNode.Down := True;
  Memo1.Clear;
end;

procedure TfrmMain.ClearImage;
begin
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));
end;

procedure TfrmMain.draw_graph_node(X, Y, N: integer; nodecolor: TColor);
begin
  with Image1 do
  begin
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := clBlack;
    if (depth and (N = 1)) then Canvas.Brush.Color := clYellow
    else
      Canvas.Brush.Color := nodecolor;
    Canvas.Ellipse(X - 12, Y - 12, X + 12, Y + 12);
    Canvas.TextOut(X - (Length(IntToStr(N)) * 3), Y - 5, IntToStr(N));
  end;
end;

procedure TfrmMain.draw_graph_edge;
var
  i, j: integer;
begin
  Image1.Canvas.Pen.Width := 1;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Brush.Color := clWhite;
  for i := 1 to NodesCount do
    for j := 1 to NodesCount do
      if (edges[i, j] <> 0) then
      begin
        Image1.Canvas.MoveTo(mas_x[i], mas_y[i]);
        Image1.Canvas.LineTo(mas_x[j], mas_y[j]);
      end;
end;

procedure TfrmMain.DrawGraph;
var
  i: integer;
begin
  if NodesCount = 0 then Exit;
  for i := 1 to NodesCount do draw_graph_node(mas_x[i], mas_y[i], mas_n[i]);
  if EdgesCount = 0 then Exit;
  for i := 1 to EdgesCount do draw_graph_edge();
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
  if found then
  begin
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
    if EdgesCount > 0 then for j := 1 to EdgesCount do
      begin
        if edges[j, 1] >= NodesCount then edges[j, 1] := edges[j, 1] - 1;
        if edges[j, 2] >= NodesCount then edges[j, 2] := edges[j, 2] - 1;
      end;
  end;
end;

function TfrmMain.NodeHasEdges(nodenum: integer): boolean;
var
  i: integer;
begin
  Result := False;
  if (nodenum = -1) or (EdgesCount = 0) then Exit;
  for i := 1 to EdgesCount do
  begin
    if (edges[i, 1] = nodenum) or (edges[i, 2] = nodenum) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TfrmMain.depth_search(k: integer; n: integer);
var
  ii, j, kk: integer;
begin
  for j := 1 to n do
  begin
    if (A1[k, j] = 1) then
    begin
      kk := 0;
      for ii := 1 to n do
        if (V[ii] = j) then
        begin
          kk := kk + 1;
          if (A1[j, k] <> 2) and (A1[j, k] <> 3) then
            A1[k, j] := 2;
        end;
      if (kk = 0) then
      begin
        A1[k, j] := 3;
        Inc(glob_counter);
        if glob_counter > CMAS_MAXSIZE then Break;
        V[glob_counter] := j;
        depth_search(j, n);
      end;
    end;
  end;
end;

procedure TfrmMain.set_edges_direction(Mas: TMATRIX; EdgeColor: TColor);
var
  A, M1, M2: TMAS1;
  b, X, rXY, XY1, rXY1: TVECT1;
  xp, yp, xn, yn, resx, resy, eps, x1, x2, y1, y2, a1, b1, r: real;
  i, j, text_X, text_Y: integer;
  P: TVECT2;
  pnt: TPoint;
begin
  eps := 0.001;
  M1[1, 1] := Cos(Pi / 10);
  M1[1, 2] := -Sin(Pi / 10);
  M1[2, 1] := Sin(Pi / 10);
  M1[2, 2] := Cos(Pi / 10);

  M2[1, 1] := Cos(Pi / 10);
  M2[1, 2] := Sin(Pi / 10);
  M2[2, 1] := -Sin(Pi / 10);
  M2[2, 2] := Cos(Pi / 10);
  for i := 1 to NodesCount do
    for j := 1 to NodesCount do
    begin
      if (Mas[i, j] = 3) or (Mas[i, j] = 2) then
      begin
        if (MAS_X[i] > MAS_X[j]) then
          text_X := MAS_X[j] + ((MAS_X[i] - MAS_X[j]) div 2)
        else
          text_X := MAS_X[i] + ((MAS_X[j] - MAS_X[i]) div 2);

        if (MAS_Y[i] > MAS_Y[j]) then
          text_Y := MAS_Y[j] + ((MAS_Y[i] - MAS_Y[j]) div 2)
        else
          text_Y := MAS_Y[i] + ((MAS_Y[j] - MAS_Y[i]) div 2);

        xp := MAS_X[i];
        yp := MAS_Y[i];
        x1 := MAS_X[i];
        y1 := MAS_Y[i];
        x2 := text_X;
        y2 := text_Y;
        a1 := text_X;
        b1 := text_Y;
        r := 12;
        repeat
          A[1, 1] := df1x(xp, yp, x1, y1, x2, y2);
          A[1, 2] := df1y(xp, yp, x1, y1, x2, y2);
          A[2, 1] := df2x(xp, yp, a1, b1, r);
          A[2, 2] := df2y(xp, yp, a1, b1, r);

          b[1] := -f1(xp, yp, x1, y1, x2, y2);
          b[2] := -f2(xp, yp, a1, b1, r);
          X := Kramer(A, b);
          xn := xp + X[1];
          yn := yp + X[2];
          resx := abs(xn - xp);
          resy := abs(yn - yp);
          xp := xn;
          yp := yn;
        until ((resx < eps) and (resy < eps));

        pnt.X := text_X;
        pnt.Y := text_Y;

        P[1] := pnt;

        XY1[1] := xp - text_X;
        XY1[2] := yp - text_Y;
        rXY1 := multiply(M1, XY1);
        pnt.X := Round(rXY1[1]) + text_X;
        pnt.Y := Round(rXY1[2]) + text_Y;
        P[2] := pnt;
        rXY := multiply(M2, XY1);
        pnt.X := Round(xp);
        pnt.Y := Round(yp);
        P[3] := pnt;
        pnt.X := Round(rXY[1]) + text_X;
        pnt.Y := Round(rXY[2]) + text_Y;
        P[4] := pnt;
        Image1.Canvas.Brush.Color := EdgeColor;
        Image1.Canvas.Polygon(P);
      end;

    end;
end;

function TfrmMain.f1(x, y: real; x1, y1, x2, y2: real): real;
begin
  Result := (y1 - y2) * x + (x2 - x1) * y + (x1 * y2 - x2 * y1);
end;

function TfrmMain.f2(x, y: real; a, b, r: real): real;
begin
  Result := (x - a) * (x - a) + (y - b) * (y - b) - r * r;
end;

function TfrmMain.df1x(x, y: real; x1, y1, x2, y2: real): real;
begin
  Result := (f1(x + h, y, x1, y1, x2, y2) - f1(x, y, x1, y1, x2, y2)) / H;
end;


function TfrmMain.df2x(x, y: real; a, b, r: real): real;
begin
  Result := (f2(x + h, y, a, b, r) - f2(x, y, a, b, r)) / H;
end;


function TfrmMain.df1y(x, y: real; x1, y1, x2, y2: real): real;
begin
  Result := (f1(x, y + h, x1, y1, x2, y2) - f1(x, y, x1, y1, x2, y2)) / H;
end;

function TfrmMain.df2y(x, y: real; a, b, r: real): real;
begin
  Result := (f2(x, y + h, a, b, r) - f2(x, y, a, b, r)) / H;
end;

function TfrmMain.kramer(A: TMAS1; b: TVECT1): TVECT1;
var
  i, j: integer;
  d, d1: real;
  A2: TMAS1;
begin
  d := det(A);
  for i := 1 to 2 do
  begin
    A2 := A;
    for j := 1 to 2 do
      A2[j, i] := b[j];
    d1 := det(A2);
    Result[i] := d1 / d;
  end;
end;


function TfrmMain.det(A: TMAS1): real;
begin
  Result := A[1, 1] * A[2, 2] - A[1, 2] * A[2, 1];
end;

function TfrmMain.multiply(A: TMAS1; b: TVECT1): TVECT1;
var
  i, j: integer;
  S: real;
begin
  for i := 1 to 2 do
  begin
    S := 0;
    for j := 1 to 2 do
      S := S + A[i, j] * b[j];
    Result[i] := S;
  end;
end;

procedure TfrmMain.search_tree_bild(A: TMatrix; X: TVECT; Y: TVECT;
  V: TVECT; N: integer);
var
  i, j: integer;
begin
  Canvas.Brush.Color := clWhite;
  for i := 1 to N do
    for j := 1 to N do
    begin
      if (A[i, j] = 3) then
      begin
        Canvas.Pen.Width := 3;
        Canvas.Pen.Style := psSolid;
        Canvas.MoveTo(X[i], Y[i] + CNODE_RADIUS * 2);
        Canvas.LineTo(X[j], Y[j] + CNODE_RADIUS * 2);
        draw_graph_node(X[i], MAS_Y[i], i, clLime);
        Application.ProcessMessages;
        Sleep(200);
      end
      else
      if (A[i, j] = 2) then
      begin
        Canvas.Pen.Width := 1;
        Canvas.Pen.Style := psDot;
        Canvas.MoveTo(X[i], Y[i] + CNODE_RADIUS * 2);
        Canvas.LineTo(X[j], Y[j] + CNODE_RADIUS * 2);
        draw_graph_node(X[i], MAS_Y[i], i, clYellow);
        Application.ProcessMessages;
        Sleep(200);
      end;
    end;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  set_edges_direction(A, clLime);
end;

end.
