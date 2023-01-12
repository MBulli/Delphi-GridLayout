UNIT SvgExport;

INTERFACE

USES
  System.Classes,
  System.IOUtils,
  System.Math,
  System.SysUtils,
  System.Types,

  GridLayout;


TYPE TSvgExport = CLASS
  PRIVATE
    FS    : TStreamWriter;
    FAlgo : TGridLayoutAlgorithm;

  PUBLIC
    CONSTRUCTOR Create(CONST FileName : STRING; GL: TGridLayout; ClientRect: TRect);
    DESTRUCTOR  Destroy; OVERRIDE;

    PROCEDURE AddRect(Bounds : TRect; Row, Column, RowSpan, ColumnSpan : INTEGER);
END;

IMPLEMENTATION

{ TSvgExport }

CONSTRUCTOR TSvgExport.Create(CONST FileName: STRING; GL: TGridLayout; ClientRect: TRect);
BEGIN
  FS := TFile.CreateText(FileName);
  FAlgo := GL.Algorithm;

  FAlgo.Calculate(ClientRect);

  FS.WriteLine('<svg width="%d" height="%d" xmlns="http://www.w3.org/2000/svg">', [ClientRect.Width, ClientRect.Height]);

  // Rows
  FOR VAR Loop := 0 TO FAlgo.RowCount-2 DO BEGIN
    VAR Row  := FAlgo.Rows[Loop];
    VAR MaxY := Trunc(Row.MinY + Max(1, Row.Height) + GL.RowGap/2);

    VAR x1 := 0;
    VAR y1 := MaxY;
    VAR x2 := ClientRect.Width;
    VAR y2 := MaxY;

    FS.WriteLine('  <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="black" stroke-width="1" stroke-dasharray="1,1" />', [x1,y1,x2,y2]);

    IF GL.RowGap > 0 THEN BEGIN
      FS.WriteLine('  <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="red" stroke-width="%d" stroke-opacity="0.25" />', [x1,y1,x2,y2, GL.RowGap]);
    END;
  END;

  // Columns
  FOR VAR Loop := 0 TO FAlgo.ColumnCount-2 DO BEGIN
    VAR Col  := FAlgo.Columns[Loop];
    VAR MaxX := Trunc(Col.MinX + Max(1, Col.Width) + GL.ColumnGap/2);

    VAR x1 := MaxX;
    VAR y1 := 0;
    VAR x2 := MaxX;
    VAR y2 := ClientRect.Height;

    FS.WriteLine('  <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="black" stroke-width="1" stroke-dasharray="1,1" />', [x1,y1,x2,y2]);

    IF GL.ColumnGap > 0 THEN BEGIN
      FS.WriteLine('  <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="red" stroke-width="%d" stroke-opacity="0.25" />', [x1,y1,x2,y2, GL.ColumnGap]);
    END;
  END;
END;


DESTRUCTOR TSvgExport.Destroy;
BEGIN
  FS.WriteLine('</svg>');

  FreeAndNil(FS);

  INHERITED;
END;


PROCEDURE TSvgExport.AddRect(Bounds: TRect; Row, Column, RowSpan, ColumnSpan: INTEGER);
BEGIN
  VAR Rect := FAlgo.ControlRect(Bounds, Row, Column, RowSpan, ColumnSpan);
  FS.WriteLine('  <rect x="%d" y="%d" width="%d" height="%d" fill="#0055FF" fill-opacity="0.25" /> <!-- r:%d c:%d rs:%d cs:%d -->',
                   [Rect.Left, Rect.Top, Rect.Width, Rect.Height, Row, Column, RowSpan, ColumnSpan]);
END;

END.
