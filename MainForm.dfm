object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 551
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object GridLayout1: TGridLayout
    Left = 0
    Top = 0
    Width = 353
    Height = 551
    Align = alLeft
    Color = clWindow
    ParentBackground = False
    ColumnDefinition = <
      item
        Mode = gsmPixels
        Width = 50.000000000000000000
      end
      item
        Mode = gsmPixels
        Width = 100.000000000000000000
      end
      item
        Mode = gsmStar
        Width = 1.000000000000000000
      end>
    RowDefinitions = <
      item
        Mode = gsmPixels
        Height = 100.000000000000000000
      end
      item
        Mode = gsmPixels
        Height = 50.000000000000000000
      end
      item
        Mode = gsmPixels
        Height = 10.000000000000000000
      end
      item
        Mode = gsmStar
        Height = 1.000000000000000000
      end>
    Items = <
      item
        Control = Button3
        Column = 0
        Row = 0
      end
      item
        Column = 0
        Row = 0
      end>
    object Button3: TButton
      Left = 0
      Top = 0
      Width = 50
      Height = 100
      Caption = 'Button3'
      TabOrder = 0
    end
  end
  object GridPanel1: TGridPanel
    Left = 623
    Top = 8
    Width = 201
    Height = 201
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 33.333333333333340000
      end
      item
        Value = 66.666666666666660000
      end>
    ControlCollection = <
      item
        Column = -1
        Row = -1
      end
      item
        Column = -1
        Row = 0
      end
      item
        Column = 0
        Control = Button4
        Row = 0
      end>
    RowCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    TabOrder = 1
    DesignSize = (
      201
      201)
    object Button4: TButton
      Left = 1
      Top = 1
      Width = 100
      Height = 100
      Anchors = []
      Caption = 'Button4'
      TabOrder = 0
    end
  end
  object StackPanel1: TStackPanel
    Left = 639
    Top = 215
    ControlCollection = <>
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 432
    Top = 202
    Width = 185
    Height = 185
    Caption = 'Panel1'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 368
    Top = 88
    Width = 100
    Height = 100
    Caption = 'Button1'
    TabOrder = 4
  end
  object Button2: TButton
    Left = 474
    Top = 32
    Width = 100
    Height = 100
    Caption = 'Button2'
    TabOrder = 5
  end
end
