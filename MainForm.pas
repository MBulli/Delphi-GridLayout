unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  GridLayout, Vcl.ExtCtrls, Vcl.WinXPanels;

type
  TForm1 = class(TForm)
    GridLayout1: TGridLayout;
    GridPanel1: TGridPanel;
    StackPanel1: TStackPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel1: TPanel;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);

  function RandomColor() : TColor;
  begin
    Result := Random($00FFFFFF);
  end;

begin

//  GridLayout1.AddColumnDefinition(TGridLayoutColumnDefinition.Create(gsmPixels, 100));
//  GridLayout1.AddColumnDefinition(TGridLayoutColumnDefinition.Create(gsmPixels, 200));
//  GridLayout1.AddColumnDefinition(TGridLayoutColumnDefinition.Create(gsmPixels, 50));

//  GridLayout1.AddRowDefinition(TGridLayoutRowDefinition.Create(gsmPixels, 250));
//  GridLayout1.AddRowDefinition(TGridLayoutRowDefinition.Create(gsmPixels, 50));



  for var c := 0 to GridLayout1.ColumnCount-1 do begin
    for var r := 0 to GridLayout1.RowCount-1 do begin
      var pan := TPanel.Create(self);
      pan.BevelOuter := bvNone;
      pan.Margins.SetBounds(8,8,8,8);
      pan.Color := RandomColor();
      pan.ParentBackground := false;
      pan.Visible := true;
      pan.Name := Format('Panel_%dx%d', [c, r]);

      GridLayout1.AddItem(pan, r, c);
    end;
  end;


end;

end.
