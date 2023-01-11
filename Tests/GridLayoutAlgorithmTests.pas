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

    [Test]
    PROCEDURE TestMultiRow;


    [Test]
    PROCEDURE TestColumnGap;

    [Test]
    PROCEDURE TestRowGap;

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


FUNCTION RectLTRB(CONST Left, Top, Right, Bottom : INTEGER) : TRect; INLINE;
BEGIN
  Result.Left   := Left;
  Result.Top    := Top;
  Result.Right  := Right;
  Result.Bottom := Bottom;
END;


FUNCTION RectLTWH(CONST Left, Top, Width, Height : INTEGER) : TRect; INLINE;
BEGIN
  Result.Left   := Left;
  Result.Top    := Top;
  Result.Width  := Width;
  Result.Height := Height;
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


PROCEDURE TGridLayoutAlgorithmTests.TestMultiRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);

  VAR GL := TGridLayout.Create(NIL);

  // 1* 30px 31 5*
  GL.AddRow(gsmStar  , 1);  // Space
  GL.AddRow(gsmPixels, 28); // Row 1
  GL.AddRow(gsmPixels, 32); // Row 2
  GL.AddRow(gsmStar  , 5);  // Space

  GL.Algorithm.Calculate(LayoutBounds);

  AssertRectEqual(Rect(0, 0,100,  6), GL.Algorithm.ControlRect(0,0,RandomRect));  // Height = floor((100-32-28)/6) * 1
  AssertRectEqual(Rect(0, 6,100, 34), GL.Algorithm.ControlRect(1,0,RandomRect));
  AssertRectEqual(Rect(0,34,100, 66), GL.Algorithm.ControlRect(2,0,RandomRect));
  AssertRectEqual(Rect(0,66,100, 99), GL.Algorithm.ControlRect(3,0,RandomRect));  // Height = floor((100-32-28)/6) * 5
END;


PROCEDURE TGridLayoutAlgorithmTests.TestColumnGap;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,30,25);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);

  GL.ColumnGap := 10;

  GL.Algorithm.Calculate(LayoutBounds);

  VAR R00 := GL.Algorithm.ControlRect(0,0,RandomRect);
  VAR R01 := GL.Algorithm.ControlRect(0,1,RandomRect);
  VAR R02 := GL.Algorithm.ControlRect(0,2,RandomRect);

  AssertRectEqual(RectLTWH( 0, 0, 20, 100), R00);
  AssertRectEqual(RectLTWH(30, 0, 20, 100), R01);
  AssertRectEqual(RectLTWH(60, 0, 20, 100), R02);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestRowGap;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,30,25);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);

  GL.RowGap := 10;

  GL.Algorithm.Calculate(LayoutBounds);

  VAR R00 := GL.Algorithm.ControlRect(0,0,RandomRect);
  VAR R10 := GL.Algorithm.ControlRect(1,0,RandomRect);
  VAR R20 := GL.Algorithm.ControlRect(2,0,RandomRect);

  AssertRectEqual(RectLTWH( 0,  0, 100, 20), R00);
  AssertRectEqual(RectLTWH( 0, 30, 100, 20), R10);
  AssertRectEqual(RectLTWH( 0, 60, 100, 20), R20);
END;

INITIALIZATION
  TDUnitX.RegisterTestFixture(TGridLayoutAlgorithmTests);

END.
