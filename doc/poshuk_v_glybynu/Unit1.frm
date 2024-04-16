object Form1: TForm1
  Left = 350
  Height = 480
  Top = 194
  Width = 600
  Caption = 'www.mathros.net.ua'
  ClientHeight = 480
  ClientWidth = 600
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  LCLVersion = '8.3'
  OnCreate = FormCreate
  object Image1: TImage
    Cursor = crHandPoint
    Left = 0
    Height = 431
    Top = 49
    Width = 600
    Align = alClient
    OnMouseDown = Image1MouseDown
    OnMouseMove = Image1MouseMove
    OnMouseUp = Image1MouseUp
  end
  object Panel1: TPanel
    Left = 0
    Height = 49
    Top = 0
    Width = 600
    Align = alTop
    ClientHeight = 49
    ClientWidth = 600
    ParentBackground = False
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 3
      Height = 22
      Top = 24
      Width = 100
      Caption = 'Додати вершину'
      Down = True
      GroupIndex = 1
    end
    object SpeedButton2: TSpeedButton
      Left = 104
      Height = 22
      Top = 24
      Width = 100
      Caption = 'Додати ребро'
      GroupIndex = 1
    end
    object Label1: TLabel
      Cursor = crHandPoint
      Left = 3
      Height = 14
      Top = 8
      Width = 133
      Caption = 'Обхід графа в глибину'
      Font.Color = clMenuHighlight
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      ParentFont = False
      OnClick = Label1Click
      OnMouseLeave = Label1MouseLeave
      OnMouseMove = Label1MouseMove
    end
    object Button1: TButton
      Left = 336
      Height = 22
      Top = 24
      Width = 250
      Caption = 'Побудувати дерево обходу в глибину'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 208
      Height = 22
      Top = 24
      Width = 100
      Caption = 'Видалити граф'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
