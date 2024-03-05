unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

const
  //максимальна розмірність масиву координат
  CMAS_MAXSIZE = 100;
  //радіус вершини, в межах координат якого не можна додати нової вершини
  CNODE_RADIUS = 20;

type
  //масив чисел
  TVECT = array [1..CMAS_MAXSIZE] of integer;


  { TfrmMain }

  TfrmMain = class(TForm)
    BitBtn1: TBitBtn;
    Image1: TImage;
    Memo1: TMemo;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
  private

  public
    //початкова ініціалізація усіх даних
    procedure PrepareData;
    //очистка зображення перед малюванням
    procedure ClearImage;
    //намалювати вершину графа в координатах x,y з індексом N
    procedure draw_graph_node(X, Y, N: integer);
  end;

var
  frmMain: TfrmMain;

  //кількість вершин
  NodesCount: integer;
  //масиви координат по x,y і номерів вершин
  mas_x, mas_y, mas_n: TVECT;


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
  p: boolean; //ознака додавання нової вершини
begin
  //режим додавання вершин
  if (SpeedButton1.Down = True) then
  begin
    //якщо натиснута ліва кнопка мишки
    if (ssLeft in Shift) then
    begin
      p := True;
      //якщо кількість вершин більше нуля, перевіряємо і додаємо
      if (NodesCount > 0) then
        for i := 1 to NodesCount do
          //якщо координати точки в межах зображення вершини, нічого не робимо
          if (X > (MAS_X[i] - CNODE_RADIUS)) and (X < (MAS_X[i] + CNODE_RADIUS)) and
            (Y > (MAS_Y[i] - CNODE_RADIUS)) and (Y < (MAS_Y[i] + CNODE_RADIUS)) then
          begin
            p := False;
            //такі координати вже зайняті - вершину не додаємо
            Memo1.Lines.Add('В цьому місці вже існує вершина!');
            break;
          end;
      //додаємо нову вершину
      if p then
      begin
        NodesCount := NodesCount + 1;
        MAS_X[NodesCount] := X;
        MAS_Y[NodesCount] := Y;
        MAS_N[NodesCount] := NodesCount;
        draw_graph_node(X, Y, NodesCount);
      end;
    end;
  end;
end;

procedure TfrmMain.PrepareData;
var
  i: integer;
begin
  //ініціалізація змінних
  NodesCount := 0;
  for i := 1 to CMAS_MAXSIZE do
  begin
    mas_x[i] := 0;
    mas_y[i] := 0;
    mas_n[i] := 0;
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

end.
