unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType,  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls;

type
    TMATRIX = array [1..10, 1..10] of integer;
    TVECT = array [1..10] of integer;
    TMAS1 = array[1..2, 1..2] of real;
    TVECT1 = array[1..2] of real;
    TVECT2 = array[1..4] of TPoint;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    StatusBar1: TStatusBar;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure draw_graph_node(X: integer; Y: integer; N: integer; Image: TImage);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure clear_img(Image: TImage);
    procedure draw_graph_edge(A: TMATRIX; X: TVECT; Y: TVECT; N: integer; Image: TImage);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Label1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure depth_search(k: integer; n: integer);
    procedure depth_search_tree_bild(A: TMATRIX; X: TVECT; Y: TVECT; V: TVECT; N: integer; Image: TImage);
    function f1(x, y: real; x1, y1, x2, y2: real): real;
    function f2(x, y: real; a, b, r: real): real;
    function df1x(x, y: real; x1, y1, x2, y2: real): real;
    function df2x(x, y: real;  a, b, r: real): real;
    function df1y(x, y: real; x1, y1, x2, y2: real): real;
    function df2y(x, y: real;  a, b, r: real): real;
    function kramer(A: TMAS1; b: TVECT1): TVECT1;
    function det(A: TMAS1): real;
    function multiply(A: TMAS1; b: TVECT1): TVECT1;
    procedure set_edges_direction(Mas: TMATRIX; Color: TColor);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.frm}

var
  MAS_X, MAS_Y, MAS_N, V: TVECT;
  Edges, A1: TMATRIX;
  glob_counter: integer;
  NodesCount, StartNode, EndNode: integer;
  depth: boolean;
  rezstr, connectivity_components: String;

procedure TForm1.draw_graph_node(X, Y, N: integer; Image: TImage);
begin
     With Image do
       begin
         Canvas.Pen.Width := 1;
         Canvas.Pen.Color := clBlack;
         Canvas.Brush.Color := clActiveCaption;
         Canvas.Ellipse(X-12, Y-12, X+12, Y+12);
         Canvas.TextOut(X - (Length(IntToStr(N))*3), Y - 5, IntToStr(N));
       end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  p: boolean;
begin
  if (depth = true) then Exit;
  p := True;
  if (SpeedButton1.Down = True) then
    begin
      if (NodesCount = 10) then Exit;
      if (ssLeft in Shift) then
        begin
         if (NodesCount > 0) then
           for i := 1 to NodesCount do
             if (X > (MAS_X[i] - 50)) and (X < (MAS_X[i] + 50)) and (Y > (MAS_Y[i] - 50)) and (Y < (MAS_Y[i] + 50)) then
               begin
                 p := False;
                 break;
               end;
          if (p) then
            begin
              NodesCount := NodesCount + 1;
              MAS_X[NodesCount ] := X;
              MAS_Y[NodesCount ] := Y;
              MAS_N[NodesCount ] := NodesCount;
              draw_graph_node(X, Y, NodesCount , Image1);
            end;
        end;
    end;
    if (SpeedButton2.Down = True) then
      begin
        if (ssLeft in Shift) then
          for i := 1 to NodesCount do
            begin
              if (X >= (MAS_X[i] - 12)) and (X <= (MAS_X[i] + 12)) and (Y >= (MAS_Y[i] - 12)) and (Y <= (MAS_Y[i] + 12)) then
                begin
                  StartNode := i;
                  break;
                end;
            end;
      end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
   i, j: integer;
begin
     connectivity_components := '';
     depth := false;
     Image1.Canvas.Brush.Color := clWhite;
     Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));
     for i := 1 to 10 do
       for j := 1 to 10 do
         Edges[i, j] := 0;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   i: integer;
begin
     if (depth = true) then Exit;
     if (StartNode <> 0) and (ssLeft in Shift) then
       begin
         clear_img(Image1);
         draw_graph_edge(Edges, MAS_X, MAS_Y, NodesCount, Image1);
         Image1.Canvas.Pen.Style := psDot;
         Image1.Canvas.MoveTo(MAS_X[StartNode], MAS_Y[StartNode]);
         Image1.Canvas.LineTo(X, Y);
         Image1.Canvas.Pen.Style := psSolid;
         for i := 1 to NodesCount do
           draw_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
       end;
end;

procedure TForm1.clear_img(Image: TImage);
begin
     Image.Canvas.Brush.Color := clWhite;
     Image.Canvas.Rectangle(0, 0, Image.Width, Image.Height);
end;

procedure TForm1.draw_graph_edge(A: TMATRIX; X, Y: TVECT; N: integer;
  Image: TImage);
var
  i, j: integer;
begin
     Image.Canvas.Pen.Width := 1;
     Image.Canvas.Pen.Color := clBlack;
     Image.Canvas.Brush.Color := clWhite;
     Image.Canvas.FillRect(Rect(0, 0, Image.Width, Image.Height));
     for i := 1 to N do
       for j := 1 to N do
         if (A[i, j] <> 0) then
           begin
             Image.Canvas.MoveTo(X[i], Y[i]);
             Image.Canvas.LineTo(X[j], Y[j]);
           end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   i, j: integer;
begin
     if (depth = true) then Exit;
     draw_graph_edge(Edges, MAS_X, MAS_Y, NodesCount, Image1);
     for i := 1 to NodesCount do
       draw_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
      if (StartNode <> 0) then
        begin
          for i := 1 to NodesCount do
            if (X >= (MAS_X[i] - 12)) and (X <= (MAS_X[i] + 12)) and (Y >= (MAS_Y[i] - 12)) and (Y <= (MAS_Y[i] + 12)) then
              begin
                EndNode := i;
                if (EndNode <> StartNode) then
                  begin
                    Edges[StartNode, EndNode] := 1;
                    Edges[EndNode, StartNode] := 1;
                    draw_graph_edge(Edges, MAS_X, MAS_Y, NodesCount, Image1);
                    Image1.Canvas.Pen.Style := psSolid;
                    for j := 1 to NodesCount do
                      draw_graph_node(MAS_X[j], MAS_Y[j], j, Image1);
                    break;
                  end;
              end;
            StartNode := 0;
        end;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
     OpenURL('http://www.mathros.net.ua/perevirka-neorijentovanogo-grafa-na-zvjaznist-ta-acyklichnist.html'); { *Перетворено з ShellExecute* }
end;

procedure TForm1.Label1MouseLeave(Sender: TObject);
begin
     Label1.Font.Style := [];
end;

procedure TForm1.Label1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
     Label1.Font.Style := Label1.Font.Style + [fsUnderline];
end;

procedure TForm1.depth_search(k, n: integer);
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
                 glob_counter := glob_counter + 1;
                 V[glob_counter] := j;
                 rezstr := rezstr + ', ' + IntToStr(j);
                 depth_search(j, n);
               end;
           end;
       end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   ii, i1, j1, k: integer;
begin
     depth := true;
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
           connectivity_components := connectivity_components + ', {' + rezstr + '}';
       end;
     depth_search_tree_bild(A1, MAS_X, MAS_Y, V, NodesCount, Image1);
     StatusBar1.Panels[1].Text := connectivity_components;
end;

procedure TForm1.depth_search_tree_bild(A: TMATRIX; X, Y, V: TVECT; N: integer;
  Image: TImage);
var
   i, j: integer;
begin
     Image.Canvas.Brush.Color := clWhite;
     for i := 1 to N do
       for j := 1 to N do
         if (A[i, j] = 3) then
           begin
             Image.Canvas.Pen.Width := 3;
             Image.Canvas.Pen.Style := psSolid;
             Image.Canvas.MoveTo(X[i], Y[i]);
             Image.Canvas.LineTo(X[j], Y[j]);
           end
         else
           if (A[i, j] = 2) then
             begin
               Image.Canvas.Pen.Width := 1;
               Image.Canvas.Pen.Style := psDot;
               Image.Canvas.MoveTo(X[i], Y[i]);
               Image.Canvas.LineTo(X[j], Y[j]);
             end;
       Image.Canvas.Pen.Width := 1;
       Image.Canvas.Pen.Style := psSolid;
       for i := 1 to NodesCount do
         begin
           draw_graph_node(MAS_X[i], MAS_Y[i], i, Image);
           Image.Canvas.Brush.Color := clWhite;
           for j := 1 to NodesCount do
             if (V[j] = i) then
               Image.Canvas.TextOut(MAS_X[i] + 10, MAS_Y[i] + 10, IntToStr(j));
         end;
       set_edges_direction(A, clBlack);
end;

function TForm1.f1(x, y, x1, y1, x2, y2: real): real;
begin
     f1 := (y1-y2)*x + (x2-x1)*y + (x1*y2 - x2*y1);
end;

function TForm1.df1x(x, y, x1, y1, x2, y2: real): real;
var
   h: real;
begin
     h := 0.01;
     df1x := (f1(x+h, y, x1, y1, x2, y2)-f1(x, y, x1, y1, x2, y2))/h;
end;

function TForm1.df1y(x, y, x1, y1, x2, y2: real): real;
var
   h: real;
begin
     h := 0.01;
     df1y := (f1(x, y+h, x1, y1, x2, y2)-f1(x, y, x1, y1, x2, y2))/h;
end;

function TForm1.df2x(x, y, a, b, r: real): real;
var
   h: real;
begin
     h := 0.01;
     df2x := (f2(x+h, y, a, b, r)-f2(x, y, a, b, r))/h;
end;

function TForm1.df2y(x, y, a, b, r: real): real;
var
   h: real;
begin
     h := 0.01;
     df2y := (f2(x, y+h, a, b, r)-f2(x, y, a, b, r))/h;
end;

function TForm1.f2(x, y, a, b, r: real): real;
begin
     f2 := (x-a)*(x-a) + (y-b)*(y-b)-r*r;
end;

function TForm1.det(A: TMAS1): real;
begin
     det := A[1, 1]*A[2, 2] - A[1, 2]*A[2,1];
end;

function TForm1.kramer(A: TMAS1; b: TVECT1): TVECT1;
var
   i, j: integer;
   d, d1: real;
   res: TVECT1;
   A2: TMAS1;
begin
     d := det(A);
     for i := 1 to 2 do
       begin
         A2 := A;
         for j := 1 to 2 do
           A2[j, i] := b[j];
         d1 := det(A2);
         res[i] := d1/d;
       end;
     kramer := res;
end;

function TForm1.multiply(A: TMAS1; b: TVECT1): TVECT1;
var
   res: TVECT1;
   i, j: integer;
   S: real;
begin
     for i := 1 to 2 do
       begin
         S := 0;
         for j := 1 to 2 do
           S := S + A[i, j] * b[j];
         res[i] := S;
       end;
     multiply := res;
end;

procedure TForm1.set_edges_direction(Mas: TMATRIX; Color: TColor);
var
   A, M1, M2: TMAS1;
   b, X, XY, rXY, XY1, rXY1: TVECT1;
   xp, yp, xn, yn, resx, resy, eps, x1, x2, y1, y2, a1, b1, r: real;
   xp1, yp1, xn1, yn1, resx1, resy1, x11, x21, y11, y21, a11, b11, r1: real;
   i, j, ii, text_X, text_Y: integer;
   P: TVECT2;
   pnt: TPoint;
begin
     eps := 0.001;
     M1[1, 1] := Cos(Pi/10); M1[1, 2] := -Sin(Pi/10);
     M1[2, 1] := Sin(Pi/10); M1[2, 2] := Cos(Pi/10);

     M2[1, 1] := Cos(Pi/10); M2[1, 2] := Sin(Pi/10);
     M2[2, 1] := -Sin(Pi/10); M2[2, 2] := Cos(Pi/10);
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
             A[1, 1] := df1x(xp, yp, x1, y1, x2, y2); A[1, 2] := df1y(xp, yp, x1, y1, x2, y2);
             A[2, 1] := df2x(xp, yp, a1, b1, r); A[2, 2] := df2y(xp, yp, a1, b1, r);

             b[1] := -f1(xp, yp, x1, y1, x2, y2); b[2] := -f2(xp, yp, a1, b1, r);
             X := Kramer(A, b);
             xn := xp + X[1]; yn := yp + X[2];
             resx := abs(xn - xp);
             resy := abs(yn - yp);
             xp := xn;
             yp := yn;
           until((resx < eps) and (resy < eps));

           pnt.X := text_X; pnt.Y := text_Y;

           P[1] := pnt;

           XY1[1] := xp - text_X; XY1[2] := yp - text_Y;
           rXY1 := multiply(M1, XY1);
           pnt.X := Round(rXY1[1]) + text_X; pnt.Y := Round(rXY1[2]) + text_Y;
           P[2] := pnt;
           rXY := multiply(M2, XY1);
           pnt.X := Round(xp); pnt.Y := Round(yp);
           P[3] := pnt;
           pnt.X := Round(rXY[1]) + text_X; pnt.Y := Round(rXY[2]) + text_Y;
           P[4] := pnt;
           Image1.Canvas.Brush.Color := Color;
           Image1.Canvas.Polygon(P);
         end;

     end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   i, j: integer;
begin
     connectivity_components := '';
     depth := false;
     NodesCount := 0;
     clear_img(Image1);
     for i := 1 to 10 do
       begin
         for j := 1 to 10 do
           Edges[i, j] := 0;
         MAS_X[i] := 0;
         MAS_Y[i] := 0;
         MAS_N[i] := 0;
       end;
     SpeedButton1.Down := True;
end;

end.
