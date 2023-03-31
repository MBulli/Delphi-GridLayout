object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 461
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
    Height = 461
    Align = alLeft
    Color = clWindow
    ParentBackground = False
    ColumnDefinitions = <
      item
        Mode = gsmPixels
        Width = 50.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Width = 100.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Width = 50.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmStar
        Width = 1.000000000000000000
        Visibility = glvVisible
      end>
    RowDefinitions = <
      item
        Mode = gsmPixels
        Height = 100.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Height = 50.000000000000000000
        Visibility = glvHidden
      end
      item
        Mode = gsmPixels
        Height = 10.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Height = 50.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmStar
        Height = 1.000000000000000000
        Visibility = glvVisible
      end>
    Items = <
      item
        Control = Button2
        Column = 2
      end
      item
        Control = Button3
        Column = 1
        Row = 1
      end>
    object Button2: TButton
      Left = 150
      Top = 0
      Width = 50
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
      Visible = False
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
    OnClick = Button1Click
  end
  object GridLayout2: TGridLayout
    Left = 384
    Top = 55
    Width = 340
    Height = 346
    Color = clWhite
    ParentBackground = False
    ColumnDefinitions = <
      item
        Mode = gsmPixels
        Width = 100.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Width = 90.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Width = 50.000000000000000000
        Visibility = glvVisible
      end>
    RowDefinitions = <
      item
        Mode = gsmPixels
        Height = 50.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Height = 100.000000000000000000
        Visibility = glvVisible
      end
      item
        Mode = gsmPixels
        Height = 100.000000000000000000
        Visibility = glvVisible
      end>
    Items = <
      item
        Control = Button5
      end
      item
        Control = Button6
        Column = 1
      end
      item
        Control = Button7
        Row = 1
      end
      item
        Control = Button8
        Column = 1
        Row = 1
      end
      item
        Control = Button9
        Column = 2
      end
      item
        Control = Button10
        Row = 2
      end
      item
        Control = Button11
        Column = 1
        Row = 2
      end
      item
        Control = Button12
        Column = 2
        Row = 2
      end
      item
        Control = Button13
        Column = 2
        Row = 1
      end>
    ColumnGap = 10
    RowGap = 10
    object Button5: TButton
      Left = 0
      Top = 0
      Width = 100
      Height = 50
      Caption = 'Button5'
      TabOrder = 0
    end
    object Button6: TButton
      Left = 110
      Top = 0
      Width = 90
      Height = 50
      Caption = 'Button6'
      TabOrder = 1
    end
    object Button7: TButton
      Left = 0
      Top = 60
      Width = 100
      Height = 100
      Caption = 'Button7'
      TabOrder = 2
    end
    object Button8: TButton
      Left = 110
      Top = 60
      Width = 90
      Height = 100
      Caption = 'Button8'
      TabOrder = 3
    end
    object Button9: TButton
      Left = 210
      Top = 0
      Width = 50
      Height = 50
      Caption = 'Button9'
      TabOrder = 4
    end
    object Button10: TButton
      Left = 0
      Top = 170
      Width = 100
      Height = 100
      Caption = 'Button10'
      TabOrder = 5
    end
    object Button11: TButton
      Left = 110
      Top = 170
      Width = 90
      Height = 100
      Caption = 'Button11'
      TabOrder = 6
    end
    object Button12: TButton
      Left = 210
      Top = 170
      Width = 50
      Height = 100
      Caption = 'Button12'
      TabOrder = 7
    end
    object Button13: TButton
      Left = 210
      Top = 60
      Width = 50
      Height = 100
      Caption = 'Button13'
      TabOrder = 8
    end
  end
  object Timer1: TTimer
    Left = 496
    Top = 472
  end
end
