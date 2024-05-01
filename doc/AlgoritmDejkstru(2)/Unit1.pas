unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, Grids, StdCtrls, ToolWin, ComCtrls, ShellAPI;
type
  MAS = array[1..100, 1..100] of integer;
  VECT = array[1..100] of integer;
  MAS1 = array[1..2, 1..2] of real;
  VECT1 = array[1..2] of real;
  VECT2 = array[1..4] of TPoint;
type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    GroupBox2: TGroupBox;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Button1: TButton;
    Button2: TButton;
    StatusBar1: TStatusBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Panel1: TPanel;
    Label1: TLabel;
    ToolButton5: TToolButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    ToolButton6: TToolButton;
    Panel2: TPanel;
    Label2: TLabel;
    Edit1: TEdit;
    Button3: TButton;
    Label3: TLabel;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure create_graph_node(X: integer; Y: integer; N: integer; Image: TImage);
    procedure draw_graph_edge(A: MAS; X: VECT; Y: VECT; N: integer; Image: TImage);
    procedure show_min_path(A: MAS; X: VECT; Y:VECT; N: integer; Image: TImage);
    procedure draw_string_grid(A: MAS; Rows: VECT; Cols: VECT; N: integer);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure StringGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure clear_img(Image: TImage);
    procedure Label3Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    function belongs_to(p1: TPoint; p2: TPoint; p3: TPoint): boolean;
    function f1(x, y: real; x1, y1, x2, y2: real): real;
    function f2(x, y: real; a, b, r: real): real;
    function df1x(x, y: real; x1, y1, x2, y2: real): real;
    function df2x(x, y: real;  a, b, r: real): real;
    function df1y(x, y: real; x1, y1, x2, y2: real): real;
    function df2y(x, y: real;  a, b, r: real): real;
    procedure set_edges_direction(Mas: MAS; Color: TColor);
    function multiply(A: MAS1; b: VECT1): VECT1;
    function kramer(A: MAS1; b: VECT1): VECT1;
    function det(A: MAS1): real;
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Label1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var
  MAS_X, MAS_Y, MAS_N, Col, Row: VECT;
  graph_nodes_count, draw_nodes, edge_start, edge_end: integer;
  drawRect: TRect;
  draggin, min_path, create_an_edge, del_edge: boolean;
  Matrix, path_matrix: MAS;

procedure TForm1.create_graph_node(X, Y, N: integer; Image: TImage);
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
  i, j, del_I: integer;
  p: boolean;
  p3: TPoint;
begin
     p := True;
     if (SpeedButton1.Down = True) then
       begin
         cursor := crHandPoint;
         if (ssLeft in Shift) then
           begin
             if (graph_nodes_count > 0) then
               for i := 1 to graph_nodes_count do
                 if (X > (MAS_X[i] - 50)) and (X < (MAS_X[i] + 50)) and (Y > (MAS_Y[i] - 50)) and (Y < (MAS_Y[i] + 50)) then
                   begin
                     p := False;
                     break;
                   end;

             if (p) then
               begin
                 graph_nodes_count := graph_nodes_count + 1;
                 MAS_X[graph_nodes_count] := X;
                 MAS_Y[graph_nodes_count] := Y;
                 MAS_N[graph_nodes_count] := graph_nodes_count;
                 create_graph_node(X, Y, graph_nodes_count, Image1);
                 With StringGrid1 do
                   begin
                     ColCount := graph_nodes_count + 1;
                     RowCount := graph_nodes_count + 1;
                     ColWidths[ColCount-1] := 30;
                     RowHeights[ColCount-1] := 17;
                     Cells[ColCount-1, 0] := IntToStr(ColCount-1);
                     Cells[0, RowCount-1] := IntToStr(RowCount-1);
                     Cells[ColCount-1, RowCount-1] := '-';
                     if (not Visible) then
                       Visible := True;
                   end;
               end
             else
               begin
                 for i := 1 to graph_nodes_count do
                   if (X >= (MAS_X[i] - 12)) and (X <= (MAS_X[i] + 12)) and (Y >= (MAS_Y[i] - 12)) and (Y <= (MAS_Y[i] + 12)) then
                     begin
                       draggin := true;
                       draw_nodes := i;
                       Image1.Canvas.Brush.Color := clWhite;
                       drawRect := Rect(MAS_X[i]-12, MAS_Y[i]-12, MAS_X[i]+12, MAS_Y[i]+12);
                       Image1.Canvas.DrawFocusRect(drawRect);
                       break;
                     end;
               end;
           end;
       end;
    if (SpeedButton2.Down = True) then
       begin
         cursor := crArrow;
         if (ssLeft in Shift) then
           begin
             if (graph_nodes_count > 0) then
               begin
                 del_I := -1;
                 for i := 1 to graph_nodes_count do
                   if (X > (MAS_X[i] - 12)) and (X < (MAS_X[i] + 12)) and (Y > (MAS_Y[i] - 12)) and (Y < (MAS_Y[i] + 12)) then
                     begin
                       del_I := i;
                       break;
                     end;
                 if (del_I > 0) then
                   begin
                     graph_nodes_count := graph_nodes_count - 1;
                     for i := 1 to graph_nodes_count do
                       begin
                         if (i >= del_I) then
                           begin
                             MAS_X[i] := MAS_X[i+1];
                             MAS_Y[i] := MAS_Y[i+1];
                           end;
                         for j := 1 to graph_nodes_count do
                           begin
                             if (i >= del_I) then
                               Matrix[i, j] := Matrix[i+1, j];

                            if (j >= del_I) then
                               Matrix[i, j] := Matrix[i, j+1];

                             if (i >= del_I) and (j >= del_I) then
                               Matrix[i, j] := Matrix[i+1, j+1];

                             StringGrid1.Cells[j, i] := IntToStr(Matrix[i, j]);

                             if (i = j) then
                               StringGrid1.Cells[j, i] := '-'
                             else
                               if (Matrix[i, j] <> 0) then
                                 StringGrid1.Cells[j, i] := IntToStr(Matrix[i, j])
                               else
                                 StringGrid1.Cells[j, i] := '';
                           end;
                       end;
                     for i := 1 to graph_nodes_count + 1 do
                       begin
                         Matrix[i, graph_nodes_count + 1] := 0;
                         Matrix[graph_nodes_count + 1, i] := 0;
                         StringGrid1.Cells[i, graph_nodes_count + 1] := '';
                         StringGrid1.Cells[graph_nodes_count + 1, i] := '';
                       end;
                   end;

                   if (StringGrid1.ColCount > 2) then
                     begin
                       StringGrid1.ColCount := graph_nodes_count + 1;
                       StringGrid1.RowCount := graph_nodes_count + 1;
                     end
                   else
                     StringGrid1.Visible := False;

                   draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
                   for i := 1 to graph_nodes_count do
                     create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
               end;
           end;
       end;

    if (SpeedButton3.Down = True) then
      begin
        for i := 1 to graph_nodes_count do
          begin
            if (X >= (MAS_X[i] - 12)) and (X <= (MAS_X[i] + 12)) and (Y >= (MAS_Y[i] - 12)) and (Y <= (MAS_Y[i] + 12)) then
              begin
                edge_start := i;
                create_an_edge := true;
                break;
              end;
          end;
      end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, j: integer;
begin
     min_path := false;

     for i := 1 to 100 do
       for j := 1 to 100 do
         Matrix[i, j] := 0;

     graph_nodes_count := 0;
     With StringGrid1 do
       begin
         for i := 1 to ColCount do
           begin
             ColWidths[i-1] := 30;
             RowHeights[i-1] := 17;
             Cells[i, 0] := IntToStr(i);
             Cells[0, i] := IntToStr(i);
           end;
       end;
     Image1.Canvas.Brush.Color := clWhite; 
     Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i, j: integer;
  b: boolean;
  p1, p2, p3: TPoint;
begin
     b := false;
     if (SpeedButton1.Down = True) then
       Image1.Cursor := crHandPoint;
     if (SpeedButton2.Down = True) or (SpeedButton3.Down = True) then
       begin
         Image1.Cursor := crArrow;
         for j := 1 to graph_nodes_count do
           if (X > (MAS_X[j] - 12)) and (X < (MAS_X[j] + 12)) and (Y > (MAS_Y[j] - 12)) and (Y < (MAS_Y[j] + 12)) then
             begin
               b := true;
               break;
             end;

         if (b) then
           Image1.Cursor := crHandPoint
         else
           Image1.Cursor := crArrow;
       end;

     if (SpeedButton4.Down = True) then
       begin
         for i := 1 to graph_nodes_count do
           for j := 1 to graph_nodes_count do
             begin
               if (j <> i) then
                 begin
                   p1.X := MAS_X[i]; p1.Y := MAS_Y[i];
                   p2.X := MAS_X[j]; p2.Y := MAS_Y[j];
                   p3.X := X; p3.Y := Y;
                   if (belongs_to(p1, p2, p3)) then
                     begin
                       if ((p3.X > p1.X) and (p3.X < p2.X) and (p3.Y > p1.Y) and (p3.Y < p2.Y)) or
                          ((p3.X < p1.X) and (p3.X > p2.X) and (p3.Y < p1.Y) and (p3.Y > p2.Y)) or
                          ((p3.X < p1.X) and (p3.X > p2.X) and (p3.Y > p1.Y) and (p3.Y < p2.Y))then
                       begin
                       b := true;
                       del_edge := true;
                       edge_start := i;
                       edge_end := j;
                       break;
                       end;
                     end;
                 end;
             end;
         if (b) then
           Image1.Cursor := crHandPoint
         else
           Image1.Cursor := crArrow;
       end;

     for i := 1 to graph_nodes_count do
       if (draggin) then
         begin
           Image1.Canvas.DrawFocusRect(drawRect);
           drawRect.Left := X - 12;
           drawRect.Top := Y - 12;
           drawRect.Right := X + 12;
           drawRect.Bottom := Y + 12;
           Image1.Canvas.DrawFocusRect(drawRect);
         end;
     if (create_an_edge) and (ssLeft in Shift) then
       begin
         clear_img(Image1);
         draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);

         Image1.Canvas.Pen.Style := psDot;
         Image1.Canvas.MoveTo(MAS_X[edge_start], MAS_Y[edge_start]);
         Image1.Canvas.LineTo(X, Y);
         set_edges_direction(Matrix, clBlack);
         Image1.Canvas.Pen.Style := psSolid;
         for i := 1 to graph_nodes_count do
           create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
       end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, j: integer;
begin
    Image1.Canvas.DrawFocusRect(drawRect);
    MAS_X[draw_nodes] := X;
    MAS_Y[draw_nodes] := Y;
    draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
    if (min_path) then
      show_min_path(path_matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
    set_edges_direction(Matrix, clBlack);
    for i := 1 to graph_nodes_count do
      create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
    draggin := false;
    draw_nodes := -1;
    if (create_an_edge) then
      begin
        for i := 1 to graph_nodes_count do
          if (X >= (MAS_X[i] - 12)) and (X <= (MAS_X[i] + 12)) and (Y >= (MAS_Y[i] - 12)) and (Y <= (MAS_Y[i] + 12)) then
            begin
              create_an_edge := false;
              edge_end := i;
              if (edge_end <> edge_start) then
                begin
                  if (Matrix[edge_end, edge_start] <> 0) then
                    Matrix[edge_end, edge_start] := 0;
                  if ((Image1.Width - X) >= Panel2.Width) then
                    Panel2.Left := X
                  else
                    Panel2.Left := Image1.Width - Panel2.Width;
                  if ((Image1.Height - Y) >= Panel2.Height) then
                    Panel2.Top := Y
                  else
                    Panel2.Top := Image1.Height - Panel2.Height;
                  Edit1.Text := '';
                  Panel2.Visible := True;

                  draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);

                  Image1.Canvas.Pen.Style := psDot;
                  Image1.Canvas.MoveTo(MAS_X[edge_start], MAS_Y[edge_start]);
                  Image1.Canvas.LineTo(MAS_X[edge_end], MAS_Y[edge_end]);

                  set_edges_direction(Matrix, clBlack);

                  Image1.Canvas.Pen.Style := psSolid;
                  for j := 1 to graph_nodes_count do
                    create_graph_node(MAS_X[j], MAS_Y[j], j, Image1);
                  break;
                end;
            end;
      end;

      if (del_edge) then
        begin
          Matrix[edge_start, edge_end] := 0;
          Matrix[edge_end, edge_start] := 0;
          StringGrid1.Cells[edge_start, edge_end] := '';
          StringGrid1.Cells[edge_end, edge_start] := '';
          edge_start := -1;
          edge_end := -1;
          del_edge := false;
          draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
          set_edges_direction(Matrix, clBlack);
          for i := 1 to graph_nodes_count do
            create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
        end;
end;

procedure TForm1.StringGrid1SetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  i: integer;
begin
     if (Arow <> ACol) then
       begin
         if (StringGrid1.Cells[ACol, ARow] <> '-') then
           begin
             Image1.Canvas.Brush.Color := clWhite;
             Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));
             if (Value <> '') then
               begin
                 Matrix[ARow, ACol] := StrToInt(Value);
                 StringGrid1.Cells[ARow, ACol] := '-';
               end
             else
               begin
                 Matrix[ARow, ACol] := 0;
                 Matrix[ACol, ARow] := 0;
                 StringGrid1.Cells[ARow, ACol] := '';
                 StringGrid1.Cells[ACol, ARow] := '';
               end;
           end
       end
     else
       StringGrid1.Cells[ACol, ARow] := '-';

     draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
     set_edges_direction(Matrix, clBlack);
     for i := 1 to graph_nodes_count do
       create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
end;

procedure TForm1.StringGrid1KeyPress(Sender: TObject; var Key: Char);
begin
     if not(Key in ['0'..'9']) and not(Key in [#8]) then
       Key := #1;
end;

procedure TForm1.draw_graph_edge(A: MAS; X, Y: VECT; N: integer; Image: TImage);
var
  i, j, text_X, text_Y: integer;
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
             if (X[i] > X[j]) then
               text_X := X[j] + ((X[i]-X[j]) div 2) - (Length(IntToStr(A[i, j]))*3)
             else
               text_X := X[i] + ((X[j]-X[i]) div 2) - (Length(IntToStr(A[i, j]))*3);

             if (Y[i] > Y[j]) then
               text_Y := Y[j] + ((Y[i]-Y[j]) div 2) - 6
             else
               text_Y := Y[i] + ((Y[j]-Y[i]) div 2) - 6;

             Image.Canvas.TextOut(text_X, text_Y, IntToStr(A[i, j]));
           end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  C, B: VECT;
  k, MIN, i, j, z1, u, n, t, x, y: integer;
  Matrix1: MAS;
begin
     Matrix1 := Matrix;
     for i := 1 to graph_nodes_count do
       C[i] := 0;
     k := 0;
     u := 1;
     C[1] := 1;
     B[u] := 1;
     while (u < graph_nodes_count) do
       begin
         MIN := 999;
         for i := 1 to u do
           if B[i] > 0 then
             begin
               t := B[i];
               for j := 1 to graph_nodes_count do
                 if (Matrix1[t, j] <> 0) then
                   begin
                     if (Matrix1[t, j] < MIN) and (C[j] = 0) then
                       begin
                         MIN := Matrix1[t, j];
                         y := t;
                         x := j;
                       end;
                   end;
               end;
         Row[u] := StrToInt(StringGrid1.Cells[0, y]);
         Col[u] := StrToInt(StringGrid1.Cells[x, 0]);
         inc(u);
         B[u] := x;
         C[x] := 1;
         k := k + Matrix1[y, x];
         Matrix1[y, x] := 0;
       end;

       for i := 1 to graph_nodes_count do
         for j := 1 to graph_nodes_count do
           path_matrix[i, j] := 0;

       for i := 1 to graph_nodes_count do
         begin
           path_matrix[Row[i], Col[i]] := Matrix[Row[i], Col[i]];
           path_matrix[Col[i], Row[i]] := Matrix[Col[i], Row[i]];
         end;

       StatusBar1.Panels[0].Text := 'Мінімальний маршрут: ';

       draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
       show_min_path(path_matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
       for i := 1 to graph_nodes_count do
         begin
           create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
           if (i = u) then
             continue;
           StatusBar1.Panels[0].Text := StatusBar1.Panels[0].Text + '(' + IntToStr(Row[i]) + '; ' + IntToStr(Col[i]) + ')';
         end;
       StatusBar1.Panels[1].Text:= 'Довжина маршруту: ' + IntToStr(k);
       draw_string_grid(path_matrix, Row, Col, graph_nodes_count-1);

       StringGrid1.Enabled := False;
       Image1.Enabled := False;
       Button1.Enabled := False;
       SpeedButton1.Enabled := False;
       SpeedButton2.Enabled := False;
       SpeedButton3.Enabled := False;
       SpeedButton4.Enabled := False;
       min_path := True;
end;

procedure TForm1.show_min_path(A: MAS; X, Y: VECT; N: integer;
  Image: TImage);
var
  i, j, text_X, text_Y: integer;
begin
     Image.Canvas.Pen.Width := 1;
     Image.Canvas.Pen.Color := clGreen;
     for i := 1 to N do
       for j := 1 to N do
         if (A[i, j] <> 0) then
           begin
             Image.Canvas.MoveTo(X[i], Y[i]);
             Image.Canvas.LineTo(X[j], Y[j]);
             if (X[i] > X[j]) then
               text_X := X[j] + ((X[i]-X[j]) div 2) - (Length(IntToStr(A[i, j]))*3)
             else
               text_X := X[i] + ((X[j]-X[i]) div 2) - (Length(IntToStr(A[i, j]))*3);

             if (Y[i] > Y[j]) then
               text_Y := Y[j] + ((Y[i]-Y[j]) div 2) - 6
             else
               text_Y := Y[i] + ((Y[j]-Y[i]) div 2) - 6;

             Image.Canvas.TextOut(text_X, text_Y, IntToStr(A[i, j]));
           end;
     Image.Canvas.Pen.Color := clBlack;
     set_edges_direction(Matrix, clBlack);
     Image.Canvas.Pen.Color := clGreen;
     set_edges_direction(A, clGreen);
end;

procedure TForm1.draw_string_grid(A: MAS; Rows: VECT; Cols: VECT; N: integer);
var
  i, Left, Top, Right, Bottom: integer;
begin
     for i := 1 to N do
       begin
         StringGrid1.Canvas.Pen.Width := 0;
         StringGrid1.Canvas.Pen.Color := clGreen;
         StringGrid1.Canvas.Brush.Color := clWhite;

         Left := StringGrid1.CellRect(Cols[i], Rows[i]).Left;
         Top :=  StringGrid1.CellRect(Cols[i], Rows[i]).Top;
         Right := StringGrid1.CellRect(Cols[i], Rows[i]).Right;
         Bottom := StringGrid1.CellRect(Cols[i], Rows[i]).Bottom;
         
         StringGrid1.Canvas.Rectangle(Left-1, Top-1, Right+1, Bottom+1);
         StringGrid1.Canvas.TextOut(Left+2, Top+2, IntToStr(A[Rows[i], Cols[i]]));
       end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i, j: integer;
begin
      StringGrid1.Enabled := True;
      Image1.Enabled := True;
      Button1.Enabled := True;
      SpeedButton1.Enabled := True;
      SpeedButton2.Enabled := True;
      SpeedButton3.Enabled := True;
      SpeedButton4.Enabled := True;
      SpeedButton1.Down := True;
      
      for i := 1 to graph_nodes_count do
        begin
          for j := 1 to graph_nodes_count do
            begin
              StringGrid1.Cells[i, j] := '';
              Matrix[i, j] := 0;
              path_matrix[i, j] := 0;
            end;
          MAS_X[i] := 0;
          MAS_Y[i] := 0;
          MAS_N[i] := 0;
          Col[i] := 0;
          Row[i] := 0;
        end;
      
      graph_nodes_count := 0;
      StringGrid1.Visible := False;
      Image1.Canvas.Brush.Color := clWhite;
      Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));

      StatusBar1.Panels[0].Text := '';
      StatusBar1.Panels[1].Text := '';
end;

procedure TForm1.clear_img(Image: TImage);
begin
     Image.Canvas.Brush.Color := clWhite;
     Image.Canvas.Rectangle(0, 0, Image.Width, Image.Height);
end;

procedure TForm1.Label3Click(Sender: TObject);
var
   i: integer;
begin
     Panel2.Visible := False;
     edge_start := -1;
     edge_end := -1;
     del_edge := false;
     draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
     for i := 1 to graph_nodes_count do
       create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
   i: integer;
begin
     if (Edit1.Text <> '') then
       begin
         Matrix[edge_start, edge_end] := StrToInt(Edit1.Text);
         StringGrid1.Cells[edge_end, edge_start] := Edit1.Text;
         StringGrid1.Cells[edge_start, edge_end] := '-';
         draw_graph_edge(Matrix, MAS_X, MAS_Y, graph_nodes_count, Image1);
         set_edges_direction(Matrix, clBlack);
         for i := 1 to graph_nodes_count do
           create_graph_node(MAS_X[i], MAS_Y[i], i, Image1);
         Panel2.Visible := False;
       end
end;

function TForm1.belongs_to(p1, p2, p3: TPoint): boolean;
var
   res: boolean;
   r1, r2: real;
begin
     res := false;
     r1 := StrToFloat(FloatToStrF(((p3.Y-p1.Y)/(p2.Y-p1.Y)), ffNumber, 4, 1));
     r2 := StrToFloat(FloatToStrF(((p3.X-p1.X)/(p2.X-p1.X)), ffNumber, 4, 1));
     if (r1 = r2) then
       res := true;
     belongs_to := res;
end;

function TForm1.f1(x, y: real; x1, y1, x2, y2: real): real;
begin
     f1 := (y1-y2)*x + (x2-x1)*y + (x1*y2 - x2*y1);
end;

function TForm1.f2(x, y, a, b, r: real): real;
begin
     f2 := (x-a)*(x-a) + (y-b)*(y-b)-r*r;
end;

function TForm1.df1x(x, y, x1, y1, x2, y2: real): real;
var
   h: real;
begin
     h := 0.01;
     df1x := (f1(x+h, y, x1, y1, x2, y2)-f1(x, y, x1, y1, x2, y2))/h;
end;

function TForm1.df2x(x, y, a, b, r: real): real;
var
   h: real;
begin
     h := 0.01;
     df2x := (f2(x+h, y, a, b, r)-f2(x, y, a, b, r))/h;
end;

function TForm1.df1y(x, y: real; x1, y1, x2, y2: real): real;
var
   h: real;
begin
     h := 0.01;
     df1y := (f1(x, y+h, x1, y1, x2, y2)-f1(x, y, x1, y1, x2, y2))/h;
end;

function TForm1.df2y(x, y, a, b, r: real): real;
var
   h: real;
begin
     h := 0.01;
     df2y := (f2(x, y+h, a, b, r)-f2(x, y, a, b, r))/h;
end;

procedure TForm1.set_edges_direction(Mas: MAS; Color: TColor);
var
   A, M1, M2: MAS1;
   b, X, XY, rXY, XY1, rXY1: VECT1;
   xp, yp, xn, yn, resx, resy, eps, x1, x2, y1, y2, a1, b1, r: real;
   xp1, yp1, xn1, yn1, resx1, resy1, x11, x21, y11, y21, a11, b11, r1: real;
   i, j, ii: integer;
   P: VECT2;
   pnt: TPoint;
begin
     eps := 0.001;
     M1[1, 1] := Cos(Pi/25); M1[1, 2] := -Sin(Pi/25);
     M1[2, 1] := Sin(Pi/25); M1[2, 2] := Cos(Pi/25);

     M2[1, 1] := Cos(Pi/25); M2[1, 2] := Sin(Pi/25);
     M2[2, 1] := -Sin(Pi/25); M2[2, 2] := Cos(Pi/25);
     for i := 1 to graph_nodes_count do
       for j := 1 to graph_nodes_count do
       begin
       if (Mas[i, j] <> 0) then
         begin
           xp := MAS_X[i];
           yp := MAS_Y[i];
           x1 := MAS_X[i]; y1 := MAS_Y[i];
           x2 := MAS_X[j]; y2 := MAS_Y[j];
           a1 := MAS_X[j]; b1 := MAS_Y[j];
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
           pnt.X := Round(xp); pnt.Y := Round(yp);
           P[1] := pnt;
           xp1 := xp;
           yp1 := yp;
           x11 := MAS_X[i]; y11 := MAS_Y[i];
           x21 := MAS_X[j]; y21 := MAS_Y[j];
           a11 := MAS_X[j]; b11 := MAS_Y[j];
           r1 := 27;

           repeat
             A[1, 1] := df1x(xp1, yp1, x11, y11, x21, y21); A[1, 2] := df1y(xp1, yp1, x11, y11, x21, y21);
             A[2, 1] := df2x(xp1, yp1, a11, b11, r1); A[2, 2] := df2y(xp1, yp1, a11, b11, r1);

             b[1] := -f1(xp1, yp1, x11, y11, x21, y21); b[2] := -f2(xp1, yp1, a11, b11, r1);
             X := Kramer(A, b);
             xn1 := xp1 + X[1]; yn1 := yp1 + X[2];
             resx1 := abs(xn1 - xp1);
             resy1 := abs(yn1 - yp1);
             xp1 := xn1;
             yp1 := yn1;
             //i := i + 1;
           until((resx1 < eps) and (resy1 < eps));

           XY1[1] := xp1 - xp; XY1[2] := yp1 - yp;
           rXY1 := multiply(M1, XY1);
           pnt.X := Round(rXY1[1] + xp); pnt.Y := Round(rXY1[2]+ yp);
           P[2] := pnt;
           rXY := multiply(M2, XY1);
           pnt.X := Round(xp1); pnt.Y := Round(yp1);
           P[3] := pnt;
           pnt.X := Round(rXY[1] + xp); pnt.Y := Round(rXY[2] + yp);
           P[4] := pnt;
           Image1.Canvas.Brush.Color := Color;
           Image1.Canvas.Polygon(P);
         end;

     end;
end;

function TForm1.multiply(A: MAS1; b: VECT1): VECT1;
var
   res: VECT1;
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

function TForm1.kramer(A: MAS1; b: VECT1): VECT1;
var
   i, j: integer;
   d, d1: real;
   res: VECT1;
   A1: MAS1;
begin
     d := det(A);
     for i := 1 to 2 do
       begin
         A1 := A;
         for j := 1 to 2 do
           A1[j, i] := b[j];
         d1 := det(A1);
         res[i] := d1/d;
       end;
     kramer := res;
end;

function TForm1.det(A: MAS1): real;
begin
     det := A[1, 1]*A[2, 2] - A[1, 2]*A[2,1];
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
     ShellExecute(Application.Handle, 'open', 'http://www.mathros.net.ua/znahodzhennja-najkorotshogo-shljahu-v-orijentovanomu-grafi-za-algorytmom-dejkstry.html', nil, nil,SW_SHOWNOACTIVATE);
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

end.
