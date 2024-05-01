object Form1: TForm1
  Left = 239
  Top = 160
  Width = 742
  Height = 454
  Caption = 'www.mathros.net.ua'
  Color = clBtnFace
  Constraints.MaxHeight = 454
  Constraints.MaxWidth = 742
  Constraints.MinHeight = 454
  Constraints.MinWidth = 742
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 1
    Top = 55
    Width = 365
    Height = 341
    Caption = #1043#1088#1072#1092' : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuHighlight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Image1: TImage
      Left = 2
      Top = 15
      Width = 361
      Height = 324
      Cursor = crArrow
      Align = alClient
      OnMouseDown = Image1MouseDown
      OnMouseMove = Image1MouseMove
      OnMouseUp = Image1MouseUp
    end
    object Panel2: TPanel
      Left = 144
      Top = 144
      Width = 137
      Height = 45
      TabOrder = 0
      Visible = False
      object Label2: TLabel
        Left = 3
        Top = 20
        Width = 50
        Height = 13
        Caption = #1044#1086#1074#1078#1080#1085#1072':'
      end
      object Label3: TLabel
        Left = 121
        Top = 0
        Width = 11
        Height = 13
        Cursor = crHandPoint
        Caption = '[x]'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMenuHighlight
        Font.Height = -5
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        OnClick = Label3Click
      end
      object Edit1: TEdit
        Left = 56
        Top = 17
        Width = 41
        Height = 21
        TabOrder = 0
      end
      object Button3: TButton
        Left = 99
        Top = 14
        Width = 33
        Height = 25
        Caption = 'Ok'
        TabOrder = 1
        OnClick = Button3Click
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 368
    Top = 55
    Width = 365
    Height = 341
    Caption = #1052#1072#1090#1088#1080#1094#1103' '#1089#1091#1084#1110#1078#1085#1086#1089#1090#1110' : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuHighlight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object StringGrid1: TStringGrid
      Left = 2
      Top = 15
      Width = 361
      Height = 324
      Align = alClient
      Color = clWhite
      ColCount = 2
      RowCount = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs]
      ParentFont = False
      TabOrder = 0
      Visible = False
      OnKeyPress = StringGrid1KeyPress
      OnSetEditText = StringGrid1SetEditText
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 25
    Width = 734
    Height = 28
    Caption = 'ToolBar1'
    EdgeBorders = [ebLeft, ebRight, ebBottom]
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsDivider
    end
    object SpeedButton1: TSpeedButton
      Left = 8
      Top = 2
      Width = 100
      Height = 22
      Cursor = crHandPoint
      Hint = #1057#1090#1074#1086#1088#1080#1090#1080' '#1074#1077#1088#1096#1080#1085#1091' '#1075#1088#1072#1092#1072
      GroupIndex = 1
      Down = True
      Caption = #1044#1086#1076#1072#1090#1080' '#1074#1077#1088#1096#1080#1085#1091
      ParentShowHint = False
      ShowHint = True
    end
    object SpeedButton2: TSpeedButton
      Left = 108
      Top = 2
      Width = 100
      Height = 22
      Cursor = crHandPoint
      Hint = #1042#1080#1076#1072#1083#1080#1090#1080' '#1074#1077#1088#1096#1080#1085#1091'  '#1075#1088#1072#1092#1072
      GroupIndex = 1
      Caption = #1042#1080#1076#1072#1083#1080#1090#1080' '#1074#1077#1088#1096#1080#1085#1091
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 208
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 1
      Style = tbsDivider
    end
    object SpeedButton3: TSpeedButton
      Left = 216
      Top = 2
      Width = 100
      Height = 22
      GroupIndex = 1
      Caption = #1044#1072#1076#1072#1090#1080' '#1088#1077#1073#1088#1086
    end
    object SpeedButton4: TSpeedButton
      Left = 316
      Top = 2
      Width = 100
      Height = 22
      GroupIndex = 1
      Caption = #1042#1080#1076#1072#1083#1080#1090#1080' '#1088#1077#1073#1088#1086
    end
    object ToolButton5: TToolButton
      Left = 416
      Top = 2
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 3
      Style = tbsDivider
    end
    object Button2: TButton
      Left = 424
      Top = 2
      Width = 100
      Height = 22
      Caption = #1042#1080#1076#1072#1083#1080#1090#1080' '#1075#1088#1072#1092
      TabOrder = 1
      OnClick = Button2Click
    end
    object ToolButton4: TToolButton
      Left = 524
      Top = 2
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 2
      Style = tbsDivider
    end
    object Button1: TButton
      Left = 532
      Top = 2
      Width = 190
      Height = 22
      Caption = #1047#1085#1072#1081#1090#1080' '#1076#1077#1088#1077#1074#1086' '#1084#1110#1085#1110#1084#1072#1083#1100#1085#1086#1111' '#1074#1072#1088#1090#1086#1089#1090#1110
      TabOrder = 0
      OnClick = Button1Click
    end
    object ToolButton6: TToolButton
      Left = 722
      Top = 2
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 4
      Style = tbsDivider
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 402
    Width = 734
    Height = 19
    Panels = <
      item
        Width = 371
      end
      item
        Width = 371
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 734
    Height = 25
    Align = alTop
    Alignment = taLeftJustify
    TabOrder = 4
    object Label1: TLabel
      Left = 3
      Top = 6
      Width = 347
      Height = 13
      Cursor = crHandPoint
      Alignment = taCenter
      Caption = #1047#1085#1072#1093#1086#1076#1078#1077#1085#1085#1103' '#1076#1077#1088#1077#1074#1072' '#1084#1110#1085#1110#1084#1072#1083#1100#1085#1086#1111' '#1074#1072#1088#1090#1086#1089#1090#1110' '#1079#1072' '#1072#1083#1075#1086#1088#1080#1090#1084#1086#1084' '#1044#1077#1081#1082#1089#1090#1088#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMenuHighlight
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = Label1Click
      OnMouseMove = Label1MouseMove
      OnMouseLeave = Label1MouseLeave
    end
  end
end
