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
        Control = Button2
        Column = 2
        Row = 0
      end
      item
        Control = Button3
        Column = 1
        Row = 1
      end>
    object Button2: TButton
      Left = 150
      Top = 0
      Width = 201
      Height = 100
      Caption = 'Button1'
      TabOrder = 0
    end
    object Button3: TButton
      Left = 50
      Top = 100
      Width = 100
      Height = 50
      Caption = 'Button3'
      TabOrder = 1
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
    Left = 639
    Top = 441
    Width = 185
    Height = 102
    Caption = 'Panel1'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 400
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 4
  end
  object GridLayout2: TGridLayout
    Left = 384
    Top = 88
    Width = 185
    Height = 327
    Color = clWhite
    ParentBackground = False
    ColumnDefinition = <
      item
        Mode = gsmStar
        Width = 1.000000000000000000
      end>
    RowDefinitions = <
      item
        Mode = gsmPixels
        Height = 50.000000000000000000
      end
      item
        Mode = gsmPixels
        Height = 100.000000000000000000
      end
      item
        Mode = gsmPixels
        Height = 100.000000000000000000
      end>
    Items = <
      item
        Control = Button5
        Column = 0
        Row = 0
      end>
    object Button5: TButton
      Left = 0
      Top = 0
      Width = 183
      Height = 50
      Caption = 'Button5'
      TabOrder = 0
    end
  end
  object Timer1: TTimer
    Left = 480
    Top = 520
  end
end
