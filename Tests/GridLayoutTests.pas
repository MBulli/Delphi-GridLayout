UNIT GridLayoutTests;

INTERFACE

USES
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  Vcl.Forms,

  DUnitX.TestFramework,
  GridLayout,
  SvgExport;


TYPE
  [TestFixture]
  TGridLayoutTests = CLASS
  PUBLIC

    [Test]
    PROCEDURE TestVerticalAutosize;

    [Test]
    PROCEDURE TestHorizontalAutosize;

  END;

IMPLEMENTATION

{ TGridLayoutTests }

PROCEDURE TGridLayoutTests.TestHorizontalAutosize;
BEGIN
  VAR Form := TForm.Create(NIL);
  VAR GL := TGridLayout.Create(Form);
  TRY
    GL.Align := alLeft;
    GL.Parent := Form;
    GL.RowGap := 9999;

    GL.AddColumn(gsmPixels, 100);
    GL.AddColumn(gsmPixels, 100);
    GL.AddColumn(gsmPixels, 100);
    GL.AddRow(gsmStar, 1);

    GL.AutoSizeMode := glaHorizontal;
    GL.AutoSize := TRUE;

    VAR R := GL.ClientRect;
    Assert.AreEqual(300, R.Width);

    GL.ColumnGap := 3;
    VAR R2 := GL.ClientRect;
    Assert.AreEqual(300+2*3, R2.Width);

    GL.AddColumn(gsmPixels, 100);            // TODO BUG: Does not call AdjustSize
    VAR R3 := GL.ClientRect;
    Assert.AreEqual(400+2*3, R3.Width);

  FINALLY
    FreeAndNil(Form);
  END;
END;


PROCEDURE TGridLayoutTests.TestVerticalAutosize;
BEGIN
  VAR Form := TForm.Create(NIL);
  VAR GL := TGridLayout.Create(Form);
  TRY
    GL.Align := alTop;
    GL.Parent := Form;
    GL.ColumnGap := 9999;

    GL.AddRow(gsmPixels, 100);
    GL.AddRow(gsmPixels, 100);
    GL.AddRow(gsmPixels, 100);
    GL.AddColumn(gsmStar, 1);

    GL.AutoSizeMode := glaVertical;
    GL.AutoSize := TRUE;

    VAR R := GL.ClientRect;
    Assert.AreEqual(300, R.Height);

    GL.RowGap := 3;
    VAR R2 := GL.ClientRect;
    Assert.AreEqual(300+2*3, R2.Height);

    GL.AddRow(gsmPixels, 100);               // TODO BUG: Does not call AdjustSize
    VAR R3 := GL.ClientRect;
    Assert.AreEqual(400+2*3, R3.Height);

  FINALLY
    FreeAndNil(Form);
  END;
END;

END.
