UNIT GridLayoutAlgorithmTests;

INTERFACE

USES
  System.SysUtils,
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

    [Test]
    PROCEDURE TestOneColumnNoRows;

    [Test]
    PROCEDURE TestOneColumnOneRow;

  END;

IMPLEMENTATION

FUNCTION RectToDisplayString(CONST R : TRect) : STRING;
BEGIN
  Result := Format('(l:%d t:%d r:%d b:%d)', [R.Left, R.Top, R.Right, R.Bottom]);
END;


PROCEDURE AssertRectEqual(CONST Expected, Actual : TRect);
BEGIN
  IF (Expected <> Actual) THEN BEGIN
    Assert.FailFmt('Expected rect %s is not equal to actual rect %s', [RectToDisplayString(Expected), RectToDisplayString(Actual)]);
  END;
END;

{ TGridLayoutAlgorithmTests }

PROCEDURE TGridLayoutAlgorithmTests.TestNoColumnNoRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);

  VAR GL := TGridLayout.Create(NIL);

  GL.Algorithm.Calculate(LayoutBounds);

  VAR R00 := GL.Algorithm.ControlRect(0,0,RandomRect);
  VAR R01 := GL.Algorithm.ControlRect(0,1,RandomRect);
  VAR R11 := GL.Algorithm.ControlRect(1,1,RandomRect);
  VAR R10 := GL.Algorithm.ControlRect(1,0,RandomRect);

  AssertRectEqual(LayoutBounds, R00);
  AssertRectEqual(LayoutBounds, R01);
  AssertRectEqual(LayoutBounds, R11);
  AssertRectEqual(LayoutBounds, R10);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestNoColumnsOneRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,100,25);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddRow(gsmPixels, 25);
  GL.Algorithm.Calculate(LayoutBounds);

  VAR R00 := GL.Algorithm.ControlRect(0,0,RandomRect);
  VAR R01 := GL.Algorithm.ControlRect(0,1,RandomRect);
  VAR R11 := GL.Algorithm.ControlRect(1,1,RandomRect);
  VAR R10 := GL.Algorithm.ControlRect(1,0,RandomRect);

  AssertRectEqual(ExpectedRect, R00);
  AssertRectEqual(ExpectedRect, R01);
  AssertRectEqual(ExpectedRect, R11);
  AssertRectEqual(ExpectedRect, R10);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestOneColumnNoRows;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,30,100);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddColumn(gsmPixels, 30);
  GL.Algorithm.Calculate(LayoutBounds);

  VAR R00 := GL.Algorithm.ControlRect(0,0,RandomRect);
  VAR R01 := GL.Algorithm.ControlRect(0,1,RandomRect);
  VAR R11 := GL.Algorithm.ControlRect(1,1,RandomRect);
  VAR R10 := GL.Algorithm.ControlRect(1,0,RandomRect);

  AssertRectEqual(ExpectedRect, R00);
  AssertRectEqual(ExpectedRect, R01);
  AssertRectEqual(ExpectedRect, R11);
  AssertRectEqual(ExpectedRect, R10);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestOneColumnOneRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,30,25);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddRow(gsmPixels, 25);
  GL.AddColumn(gsmPixels, 30);
  GL.Algorithm.Calculate(LayoutBounds);

  VAR R00 := GL.Algorithm.ControlRect(0,0,RandomRect);
  VAR R01 := GL.Algorithm.ControlRect(0,1,RandomRect);
  VAR R11 := GL.Algorithm.ControlRect(1,1,RandomRect);
  VAR R10 := GL.Algorithm.ControlRect(1,0,RandomRect);

  AssertRectEqual(ExpectedRect, R00);
  AssertRectEqual(ExpectedRect, R01);
  AssertRectEqual(ExpectedRect, R11);
  AssertRectEqual(ExpectedRect, R10);
END;

INITIALIZATION
  TDUnitX.RegisterTestFixture(TGridLayoutAlgorithmTests);

END.
