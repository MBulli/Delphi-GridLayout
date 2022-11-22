UNIT GridLayoutAlgorithmTests;

INTERFACE

USES
  System.Types,

  DUnitX.TestFramework,
  GridLayout;

TYPE
  [TestFixture]
  TGridLayoutAlgorithmTests = CLASS
  PUBLIC

    [Test]
    PROCEDURE TestNoColumnNoRow;

    [Test]
    PROCEDURE TestNoColumnsOneRow;

  END;

IMPLEMENTATION

{ TGridLayoutAlgorithmTests }

PROCEDURE TGridLayoutAlgorithmTests.TestNoColumnNoRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);

  VAR GL := TGridLayout.Create(NIL);
  GL.ColumnDefinition.Clear;
  GL.RowDefinitions.Clear;

  GL.Algorithm.Calculate(LayoutBounds);

  VAR R := GL.Algorithm.ControlRect(0,0,Rect(42,1337,512,1024));

  Assert.AreEqual(LayoutBounds, R);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestNoColumnsOneRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);

  VAR GL := TGridLayout.Create(NIL);
  GL.ColumnDefinition.Clear;
  GL.RowDefinitions.Clear;

  GL.AddRow(gsmPixels, 25);
  GL.Algorithm.Calculate(LayoutBounds);

  VAR R0 := GL.Algorithm.ControlRect(0,0,Rect(42,1337,512,1024));
  VAR R1 := GL.Algorithm.ControlRect(1,0,Rect(42,1337,512,1024));

  Assert.AreEqual(Rect(0,0,100,25), R0);
  Assert.AreEqual(Rect(0,0,100,25), R1);
END;

INITIALIZATION
  TDUnitX.RegisterTestFixture(TGridLayoutAlgorithmTests);

END.
