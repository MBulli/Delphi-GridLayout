UNIT GridLayoutAlgorithmTests;

INTERFACE

USES
  System.SysUtils,
  System.Types,

  DUnitX.TestFramework,
  GridLayout,
  SvgExport;

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

    [Test]
    PROCEDURE TestInvalidColumnSpanValues;

    [Test]
    PROCEDURE TestInvalidRowSpanValues;

    // TODO Col/Row-Span tests for basic function
    // TODO Col/Row-Span tests for autosize row/cols

    [Test]
    PROCEDURE TestColumnSpanWithColumnGap;

    [Test]
    PROCEDURE TestRowSpanWithRowGap;

    [Test]
    PROCEDURE TestColumnSpanWithStarColumn;


    [Test]
    PROCEDURE TestCollapseRow;
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

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,0,1);
  VAR R11 := GL.Algorithm.ControlRect(RandomRect,1,1);
  VAR R10 := GL.Algorithm.ControlRect(RandomRect,1,0);

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

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,0,1);
  VAR R11 := GL.Algorithm.ControlRect(RandomRect,1,1);
  VAR R10 := GL.Algorithm.ControlRect(RandomRect,1,0);

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

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,0,1);
  VAR R11 := GL.Algorithm.ControlRect(RandomRect,1,1);
  VAR R10 := GL.Algorithm.ControlRect(RandomRect,1,0);

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

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,0,1);
  VAR R11 := GL.Algorithm.ControlRect(RandomRect,1,1);
  VAR R10 := GL.Algorithm.ControlRect(RandomRect,1,0);

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

  AssertRectEqual(Rect(0, 0,100,  6), GL.Algorithm.ControlRect(RandomRect,0,0));  // Height = floor((100-32-28)/6) * 1
  AssertRectEqual(Rect(0, 6,100, 34), GL.Algorithm.ControlRect(RandomRect,1,0));
  AssertRectEqual(Rect(0,34,100, 66), GL.Algorithm.ControlRect(RandomRect,2,0));
  AssertRectEqual(Rect(0,66,100, 99), GL.Algorithm.ControlRect(RandomRect,3,0));  // Height = floor((100-32-28)/6) * 5
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

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,0,1);
  VAR R02 := GL.Algorithm.ControlRect(RandomRect,0,2);

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

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0);
  VAR R10 := GL.Algorithm.ControlRect(RandomRect,1,0);
  VAR R20 := GL.Algorithm.ControlRect(RandomRect,2,0);

  AssertRectEqual(RectLTWH( 0,  0, 100, 20), R00);
  AssertRectEqual(RectLTWH( 0, 30, 100, 20), R10);
  AssertRectEqual(RectLTWH( 0, 60, 100, 20), R20);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestColumnSpanWithStarColumn;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddColumn(gsmStar  , 1);
  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);

  GL.AddRow(gsmPixels, 30);
  GL.AddRow(gsmPixels, 30);
  GL.AddRow(gsmPixels, 30);

  GL.ColumnGap := 10;

  GL.Algorithm.Calculate(LayoutBounds);

  VAR SVG := TSvgExport.Create('TestColumnSpanWithStarColumn.svg', GL, LayoutBounds);
  SVG.AddRect(RandomRect, 0,0, 0,3);
  SVG.AddRect(RandomRect, 1,1, 0,2);
  SVG.AddRect(RandomRect, 2,2, 0,1);
  FreeAndNil(SVG);


  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0, 0,3);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,1,1, 0,2);
  VAR R02 := GL.Algorithm.ControlRect(RandomRect,2,2, 0,1);

  AssertRectEqual(RectLTWH( 0,  0, 100, 30), R00);
  AssertRectEqual(RectLTWH(50, 30,  50, 30), R01);
  AssertRectEqual(RectLTWH(80, 60,  20, 30), R02);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestColumnSpanWithColumnGap;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);
  GL.AddRow(gsmPixels, 30);
  GL.AddRow(gsmPixels, 30);
  GL.AddRow(gsmPixels, 30);

  GL.ColumnGap := 10;

  GL.Algorithm.Calculate(LayoutBounds);

  VAR SVG := TSvgExport.Create('TestColumnSpanWithColumnGap.svg', GL, LayoutBounds);
  SVG.AddRect(RandomRect, 0,0, 0,3);
  SVG.AddRect(RandomRect, 1,0, 0,2);
  SVG.AddRect(RandomRect, 2,1, 0,2);
  FreeAndNil(SVG);

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0, 0,3);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,1,0, 0,2);
  VAR R02 := GL.Algorithm.ControlRect(RandomRect,2,1, 0,2);

  AssertRectEqual(RectLTWH( 0,  0,  80, 30), R00);
  AssertRectEqual(RectLTWH( 0, 30,  50, 30), R01);
  AssertRectEqual(RectLTWH(30, 60,  50, 30), R02);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestRowSpanWithRowGap;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddColumn(gsmPixels, 30);
  GL.AddColumn(gsmPixels, 30);
  GL.AddColumn(gsmPixels, 30);
  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);

  GL.RowGap := 10;

  GL.Algorithm.Calculate(LayoutBounds);

  VAR SVG := TSvgExport.Create('TestRowSpanWithRowGap.svg', GL, LayoutBounds);
  SVG.AddRect(RandomRect, 0,0, 3,0);
  SVG.AddRect(RandomRect, 0,1, 2,0);
  SVG.AddRect(RandomRect, 1,2, 2,0);
  FreeAndNil(SVG);

  VAR R00 := GL.Algorithm.ControlRect(RandomRect,0,0, 3,0);
  VAR R01 := GL.Algorithm.ControlRect(RandomRect,0,1, 2,0);
  VAR R02 := GL.Algorithm.ControlRect(RandomRect,1,2, 2,0);

  AssertRectEqual(RectLTWH( 0,  0, 30, 80), R00);
  AssertRectEqual(RectLTWH(30,  0, 30, 50), R01);
  AssertRectEqual(RectLTWH(60, 30, 30, 50), R02);
END;


PROCEDURE TGridLayoutAlgorithmTests.TestInvalidColumnSpanValues;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,30,25);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);
  GL.AddColumn(gsmPixels, 20);

  GL.Algorithm.Calculate(LayoutBounds);

  AssertRectEqual(RectLTWH( 0,  0, 20, 100), GL.Algorithm.ControlRect(RandomRect,0,0, 1,-1));
  AssertRectEqual(RectLTWH( 0,  0, 20, 100), GL.Algorithm.ControlRect(RandomRect,0,0, 1,0));
  AssertRectEqual(RectLTWH(20,  0, 20, 100), GL.Algorithm.ControlRect(RandomRect,0,1, 1,-1));
  AssertRectEqual(RectLTWH(20,  0, 20, 100), GL.Algorithm.ControlRect(RandomRect,0,1, 1,0));

  AssertRectEqual(RectLTWH( 0,  0, 60, 100), GL.Algorithm.ControlRect(RandomRect,0,0, 1,4));
  AssertRectEqual(RectLTWH(20,  0, 40, 100), GL.Algorithm.ControlRect(RandomRect,0,1, 1,4));
  AssertRectEqual(RectLTWH(40,  0, 20, 100), GL.Algorithm.ControlRect(RandomRect,0,2, 1,4));
END;


PROCEDURE TGridLayoutAlgorithmTests.TestInvalidRowSpanValues;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);
  VAR ExpectedRect := Rect(0,0,30,25);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);

  GL.Algorithm.Calculate(LayoutBounds);

  AssertRectEqual(RectLTWH( 0,  0, 100, 20), GL.Algorithm.ControlRect(RandomRect,0,0, -1,1));
  AssertRectEqual(RectLTWH( 0,  0, 100, 20), GL.Algorithm.ControlRect(RandomRect,0,0,  0,1));
  AssertRectEqual(RectLTWH( 0, 20, 100, 20), GL.Algorithm.ControlRect(RandomRect,1,0, -1,1));
  AssertRectEqual(RectLTWH( 0, 20, 100, 20), GL.Algorithm.ControlRect(RandomRect,1,0,  0,1));

  AssertRectEqual(RectLTWH( 0,  0, 100, 60), GL.Algorithm.ControlRect(RandomRect,0,0, 4,1));
  AssertRectEqual(RectLTWH( 0, 20, 100, 40), GL.Algorithm.ControlRect(RandomRect,1,0, 4,1));
  AssertRectEqual(RectLTWH( 0, 40, 100, 20), GL.Algorithm.ControlRect(RandomRect,2,0, 4,1));
END;


PROCEDURE TGridLayoutAlgorithmTests.TestCollapseRow;
BEGIN
  VAR LayoutBounds := Rect(0,0,100,100);
  VAR RandomRect   := Rect(42,1337,512,1024);

  VAR GL := TGridLayout.Create(NIL);

  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);
  GL.AddRow(gsmPixels, 20);

  GL.RowGap := 5;

  GL.RowVisbility[1] :=glvCollapsed;

  GL.Algorithm.Calculate(LayoutBounds);

  WriteLn(RectToDisplayString(GL.Algorithm.ControlRect(RandomRect,0,0)));
  WriteLn(RectToDisplayString(GL.Algorithm.ControlRect(RandomRect,1,0)));
  WriteLn(RectToDisplayString(GL.Algorithm.ControlRect(RandomRect,2,0)));

  WriteLn(RectToDisplayString(GL.Algorithm.ControlRect(RandomRect,1,0,2,-1)));


  VAR SVG := TSvgExport.Create('TestCollapseRow.svg', GL, LayoutBounds);
  SVG.AddRect(RandomRect, 1,0, 2,0);
  FreeAndNil(SVG);

  AssertRectEqual(RectLTWH( 0,  0, 100, 20), GL.Algorithm.ControlRect(RandomRect,0,0));
  AssertRectEqual(RectLTWH( 0, 20, 100,  0), GL.Algorithm.ControlRect(RandomRect,1,0));
  AssertRectEqual(RectLTWH( 0, 25, 100, 20), GL.Algorithm.ControlRect(RandomRect,2,0));

  // Row Span - First Row
  AssertRectEqual(RectLTWH( 0,  0, 100, 25), GL.Algorithm.ControlRect(RandomRect,0,0, 2, -1));
  AssertRectEqual(RectLTWH( 0,  0, 100, 50), GL.Algorithm.ControlRect(RandomRect,0,0, 3, -1));

  // Row Span - Second Row
  AssertRectEqual(RectLTWH( 0, 20, 100, 25), GL.Algorithm.ControlRect(RandomRect,1,0, 2, -1));
END;

INITIALIZATION
  TDUnitX.RegisterTestFixture(TGridLayoutAlgorithmTests);

END.
