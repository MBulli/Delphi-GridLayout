UNIT GridLayout;

INTERFACE

USES
  WinApi.Windows,
  WinApi.Messages,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.WinXPanels;

{
 TODO:
 - RemoveCol/Row/Item methods
 - How to handle implicit row and column? Maybe add in Layout and Remove after? Or TCollection.Update
 - Prevent deletion of implicit row and column in Designer and Code
 - TComponent Editor
 - TextOut Values in Paint for Columns
 - Col/Row Span
 - MinWidth/MinHeigth
 - Add "Row/Column" fake properties to controls https://edn.embarcadero.com/article/33448
}

TYPE
  TGridLayoutSizeMode = (gsmPixels, gsmStar, gsmAutosize);

  TGridLayout = CLASS;

  TGridLayoutDefinitionBase = CLASS(TCollectionItem)
  PROTECTED
    FMode   : TGridLayoutSizeMode;
    FFactor : Single;

    FUNCTION GetDisplayName: string; OVERRIDE;

    PROCEDURE SetFactor(NewValue : Single);
    PROCEDURE SetMode  (NewValue : TGridLayoutSizeMode);

  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;
  END;


  TGridLayoutColumnDefinition = CLASS (TGridLayoutDefinitionBase)
  PUBLISHED
    PROPERTY Mode  : TGridLayoutSizeMode READ FMode   WRITE SetMode;
    PROPERTY Width : Single              READ FFactor WRITE SetFactor;
  END;


  TGridLayoutRowDefinition = CLASS (TGridLayoutDefinitionBase)
  PUBLISHED
    PROPERTY Mode   : TGridLayoutSizeMode READ FMode   WRITE SetMode;
    PROPERTY Height : Single READ FFactor WRITE SetFactor;
  END;


  TGridLayoutColumnCollection = CLASS(TOwnedCollection)
  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
  END;

  TGridlayoutRowCollection = CLASS(TOwnedCollection)
  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
  END;


  TGridLayoutItem = CLASS(TCollectionItem)
  STRICT PRIVATE
    FOrigCtrlWndProc : TWndMethod;

    PROCEDURE DesignControlWndProcHook(VAR Message: TMessage);

  STRICT PRIVATE
    FControl : TControl;
    FColumn  : Integer;
    FRow     : Integer;

//    FColumnSpan : Integer;
//    FRowSpan    : Integer;

    PROCEDURE SetControl(NewValue : TControl);
    PROCEDURE SetColumn (NewValue : Integer);
    PROCEDURE SetRow    (NewValue : Integer);

  PROTECTED
    FUNCTION GetDisplayName : STRING; OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;

    FUNCTION OwningLayout : TGridLayout;

  PUBLISHED
    PROPERTY Control : TControl READ FControl WRITE SetControl;
    PROPERTY Column  : Integer  READ FColumn  WRITE SetColumn;
    PROPERTY Row     : Integer  READ FRow     WRITE SetRow;
  END;

  TGridLayoutItemCollection = CLASS(TOwnedCollection)
  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
  END;

  TGridLayout = CLASS(TCustomPanel)
  PRIVATE
    TYPE TGridLayoutColumnTuple = RECORD
      MinX       : Single;
      Width      : Single;
      Definition : TGridLayoutColumnDefinition
    END;

    TYPE TGridLayoutRowTuple = RECORD
      MinY       : Single;
      Height     : Single;
      Definition : TGridLayoutRowDefinition
    END;

  PRIVATE
    FItems     : TGridLayoutItemCollection; // TObjectList<TGridLayoutItem>;
    FRowDef    : TGridlayoutRowCollection;    // TObjectList<TGridLayoutRowDefinition>;
    FColumnDef : TGridLayoutColumnCollection; // TObjectList<TGridLayoutColumnDefinition>;

    // We need at least one definition
    // The last definition is always a filler with 1*
    FImplicitRowDef    : TGridLayoutRowDefinition;
    FImplicitColumnDef : TGridLayoutColumnDefinition;

    // Calculated layout values
    FColumns : TArray<TGridLayoutColumnTuple>;
    FRows    : TArray<TGridLayoutRowTuple>;

    FUNCTION ColumnWidthAtIndex (ColumnIndex : Integer) : Single;
    FUNCTION RowHeightAtIndex   (RowIndex    : Integer) : Single;

    FUNCTION GetColumnCount () : Integer;
    FUNCTION GetRowCount    () : Integer;

    PROCEDURE SetColumnDefinitionCollection(CONST AValue : TGridLayoutColumnCollection);
    PROCEDURE SetRowDefinitionCollection   (CONST AValue : TGridlayoutRowCollection);
    PROCEDURE SetItemCollection            (CONST AValue : TGridLayoutItemCollection);

    PROCEDURE CMControlChange(var Message: TCMControlChange); MESSAGE CM_CONTROLCHANGE;

  PROTECTED
    PROCEDURE AlignControls  (    AControl : TControl;
                              VAR Rect     : TRect);                            OVERRIDE;
    PROCEDURE Paint;                                                            OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR  Destroy();                  OVERRIDE;

    PROCEDURE AddColumn(Mode : TGridLayoutSizeMode; Factor : Single);
    PROCEDURE AddRow   (Mode : TGridLayoutSizeMode; Factor : Single);

    PROCEDURE AddItem(Control : TControl;
                      Row     : Integer;
                      Column  : Integer);

    PROCEDURE RemoveItemForControl(Control : TControl);

//    PROCEDURE AddItem    (Item : TGridLayoutItem);
//    PROCEDURE RemoveItem (Item : TGridLayoutItem);

//    PROCEDURE AddRowDefinition       (RowDefinition    : TGridLayoutRowDefinition);
//    PROCEDURE RemoveRowDefinition    (RowDefinition    : TGridLayoutRowDefinition);

//    PROCEDURE AddColumnDefinition    (ColumnDefinition : TGridLayoutColumnDefinition);
//    PROCEDURE RemoveColumnDefinition (ColumnDefinition : TGridLayoutColumnDefinition);

    FUNCTION ColumnIndexFromPos(CONST Position : TPoint) : INTEGER;
    FUNCTION RowIndexFromPos   (CONST Position : TPoint) : INTEGER;

    PROPERTY  ColumnCount : Integer READ GetColumnCount;
    PROPERTY  RowCount    : Integer READ GetRowCount;

  PUBLISHED
    PROPERTY Align;
    PROPERTY Color;
    PROPERTY ParentBackground;

    PROPERTY ColumnDefinition : TGridLayoutColumnCollection READ FColumnDef WRITE SetColumnDefinitionCollection;
    PROPERTY RowDefinitions   : TGridLayoutRowCollection    READ FRowDef    WRITE SetRowDefinitionCollection;
    PROPERTY Items            : TGridLayoutItemCollection   READ FItems     WRITE SetItemCollection;
  END;

IMPLEMENTATION

{ TGridLayoutDefinitionBase }

CONSTRUCTOR TGridLayoutDefinitionBase.Create(Collection: TCollection);
BEGIN
  INHERITED Create(Collection);

  FMode   := gsmAutosize;
  FFactor := 0;
END;


FUNCTION TGridLayoutDefinitionBase.GetDisplayName: string;
BEGIN
  IF Self is TGridLayoutColumnDefinition
  THEN Result := 'Column: '
  ELSE Result := 'Row: ';

  IF FMode = gsmAutosize THEN BEGIN
    Result := Result + 'autosize';
  END
  ELSE IF FMode = gsmPixels THEN BEGIN
    Result := Result + IntToStr(Trunc(FFactor)) + 'px';
  END
  ELSE BEGIN
    Result := Result + FloatToStr(FFactor) + '*';
  END;
END;


PROCEDURE TGridLayoutDefinitionBase.SetFactor(NewValue: Single);
BEGIN
  IF NewValue < 0 THEN EXIT;

  IF NewValue <> FFactor THEN BEGIN
    FFactor := NewValue;
    Changed(False);
  END;
END;


PROCEDURE TGridLayoutDefinitionBase.SetMode(NewValue: TGridLayoutSizeMode);
BEGIN
  IF NewValue <> FMode THEN BEGIN
    FMode := NewValue;
    Changed(False);
  END;
END;


{ TGridLayoutColumnCollection }

CONSTRUCTOR TGridLayoutColumnCollection.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TGridLayoutColumnDefinition);
END;


PROCEDURE TGridLayoutColumnCollection.Update(Item: TCollectionItem);
BEGIN
  INHERITED;

  IF Owner <> nil THEN BEGIN
    WITH Owner AS TGridLayout DO BEGIN
      Invalidate;
      Realign;
    END;
  END;
END;

{ TGridlayoutRowCollection }

CONSTRUCTOR TGridlayoutRowCollection.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TGridLayoutRowDefinition);
END;

PROCEDURE TGridlayoutRowCollection.Update(Item: TCollectionItem);
BEGIN
  INHERITED;

  IF Owner <> nil THEN BEGIN
    WITH Owner AS TGridLayout DO BEGIN
      Invalidate;
      Realign;
    END;
  END;
END;


{ TGridLayoutItem }


CONSTRUCTOR TGridLayoutItem.Create(Collection: TCollection);
BEGIN
  INHERITED Create(Collection);

  FControl := nil;
  FRow     := 0;
  FColumn  := 0;
END;


PROCEDURE TGridLayoutItem.DesignControlWndProcHook(var Message: TMessage);
BEGIN
  Assert(Assigned(FOrigCtrlWndProc));

  IF (csDesigning IN FControl.ComponentState) THEN BEGIN
    IF Message.Msg = WM_WINDOWPOSCHANGED THEN BEGIN

      VAR WinPosMsg := TWMWindowPosChanged(Message);

      // If control is moved
      IF ((WinPosMsg.WindowPos.flags AND SWP_NOMOVE) = 0) THEN BEGIN
        VAR OwningLayout := FControl.Parent AS TGridLayout;
        VAR Position := OwningLayout.ScreenToClient(Mouse.CursorPos);

        VAR Col := OwningLayout.ColumnIndexFromPos(Position);
        VAR Row := OwningLayout.RowIndexFromPos(Position);

        IF (Col <> -1) AND (Row <> -1) THEN BEGIN
          SetColumn(Col);
          SetRow(Row);
        END;
      END;
    END;
  END;

  FOrigCtrlWndProc(Message);
END;


FUNCTION TGridLayoutItem.GetDisplayName: STRING;
BEGIN
  VAR CtrlName := 'nil';

  IF Assigned(FControl) THEN BEGIN
    IF FControl.Name <> ''
    THEN CtrlName := FControl.Name
    ELSE CtrlName := FControl.ClassName;
  END;

  Result := Format('%s[%d, %d] (%s)', [ClassName, FColumn, FRow, CtrlName]);

  IF Assigned(FOrigCtrlWndProc) THEN BEGIN
    Result := Result + ' H';
  END;
END;


FUNCTION TGridLayoutItem.OwningLayout: TGridLayout;
BEGIN
  Result := Collection.Owner AS TGridLayout;
END;


PROCEDURE TGridLayoutItem.SetColumn(NewValue: Integer);
BEGIN
  IF NewValue <> FColumn THEN BEGIN
    FColumn := NewValue;
    Changed(false);
  END;
END;


PROCEDURE TGridLayoutItem.SetRow(NewValue: Integer);
BEGIN
  IF NewValue <> FRow THEN BEGIN
    FRow := NewValue;
    Changed(false);
  END;
END;


PROCEDURE TGridLayoutItem.SetControl(NewValue: TControl);

  FUNCTION _SameMethodPtr(CONST A, B : TMethod) : BOOLEAN; INLINE;
  BEGIN
    Result := (A.Code = B.Code) AND (A.Data = B.Data);
  END;

  FUNCTION _ShouldHookWndProc: BOOLEAN;
  BEGIN
    IF NOT Assigned(FControl) THEN EXIT(FALSE);
    IF Assigned(FOrigCtrlWndProc) AND (TMethod(FControl.WindowProc).Code = @TGridLayoutItem.DesignControlWndProcHook) THEN EXIT(FALSE);
    IF Assigned(FOrigCtrlWndProc) AND _SameMethodPtr(TMethod(FControl.WindowProc), TMethod(FOrigCtrlWndProc)) THEN EXIT(FALSE);
    IF (csDestroying IN FControl.ComponentState) THEN EXIT(FALSE);

    Result := (csDesigning IN FControl.ComponentState);
  END;

  FUNCTION _ControlAlreadyAssigned : BOOLEAN;
  BEGIN
    IF NewValue = NIL THEN EXIT(FALSE);

    Result := FALSE;

    FOR VAR I := 0 TO Collection.Count-1  DO BEGIN
      VAR Item := Collection.Items[I] AS TGridLayoutItem;

      IF (Item <> self) AND (Item.FControl = NewValue) THEN BEGIN
        EXIT(TRUE);
      END;
    END;
  END;

BEGIN
  IF NewValue = FControl THEN EXIT;

  // Prevent that multiple TGridLayoutItems reference the same TControl
  IF _ControlAlreadyAssigned THEN BEGIN
    EXIT;
  END;

  // Reset old control state
  IF FControl <> NIL THEN BEGIN
    IF Assigned(FOrigCtrlWndProc) THEN BEGIN
      FControl.WindowProc := FOrigCtrlWndProc;
      FOrigCtrlWndProc := NIL;
    END;
  END;

  // Set new control
  FControl := NewValue;
  FOrigCtrlWndProc := NIL;

  IF Assigned(FControl) THEN BEGIN
    // Set Parent if necessary
    IF (FControl.Parent <> OwningLayout) THEN BEGIN
      FControl.Parent := OwningLayout;
    END;

    // Hook window for drag and drop form designer hack
    IF _ShouldHookWndProc THEN BEGIN
      FOrigCtrlWndProc := FControl.WindowProc;
      FControl.WindowProc := DesignControlWndProcHook;
    END;
  END;

  Changed(false);
END;

{ TGridLayoutItemCollection }

CONSTRUCTOR TGridLayoutItemCollection.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TGridLayoutItem);
END;


PROCEDURE TGridLayoutItemCollection.Update(Item: TCollectionItem);
BEGIN
  INHERITED;

  IF Owner <> nil THEN BEGIN
    WITH Owner AS TGridLayout DO BEGIN
      Invalidate;
      Realign;
    END;
  END;
END;

{ TGridLayout }

CONSTRUCTOR TGridLayout.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);

//  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
//    csSetCaption, csOpaque, csDoubleClicks, csReplicatable, csPannable, csGestures];

  FItems     := TGridLayoutItemCollection.Create(self);
  FRowDef    := TGridlayoutRowCollection.Create(self);
  FColumnDef := TGridLayoutColumnCollection.Create(self);

  FImplicitRowDef    := FRowDef.Add AS TGridLayoutRowDefinition;
  FImplicitColumnDef := FColumnDef.Add AS TGridLayoutColumnDefinition;

  FImplicitRowDef.FMode   := gsmStar;
  FImplicitRowDef.FFactor := 1;

  FImplicitColumnDef.FMode   := gsmStar;
  FImplicitColumnDef.FFactor := 1;

  Color := clWhite;
END;


DESTRUCTOR TGridLayout.Destroy;
BEGIN
  FreeAndNil(FItems);
  FreeAndNil(FRowDef);
  FreeAndNil(FColumnDef);

  INHERITED;
END;


FUNCTION TGridLayout.GetColumnCount: Integer;
BEGIN
  Result := FColumnDef.Count;
END;


FUNCTION TGridLayout.GetRowCount: Integer;
BEGIN
  Result := FRowDef.Count;
END;


PROCEDURE TGridLayout.AddItem(Control : TControl; Row : Integer; Column : Integer);
BEGIN
  Assert(Assigned(Control));

  VAR Item := FItems.Add AS TGridLayoutItem;

  Item.Column  := Column;
  Item.Row     := Row;
  Item.Control := Control;
END;


PROCEDURE TGridLayout.RemoveItemForControl(Control: TControl);
BEGIN
  IF NOT Assigned(Control) THEN EXIT;

  FOR VAR I := 0 TO FItems.Count-1 DO BEGIN
    IF TGridLayoutItem(FItems.Items[I]).Control = Control THEN BEGIN
      TGridLayoutItem(FItems.Items[I]).Control := NIL;
      FItems.Delete(I);
      EXIT;
    END;
  END;
END;


PROCEDURE TGridLayout.AddColumn(Mode: TGridLayoutSizeMode; Factor: Single);
BEGIN
  // Ensure that the implicit definition is always the last definition
  WITH FColumnDef.Insert(FColumnDef.Count-1) AS TGridLayoutColumnDefinition DO BEGIN
    FMode := Mode;

    CASE Mode OF
      gsmAutosize : FFactor := 0;
      gsmStar     : FFactor := Factor;
      gsmPixels   : FFactor := Trunc(Factor);
    END;
  END;
END;


PROCEDURE TGridLayout.AddRow(Mode: TGridLayoutSizeMode; Factor: Single);
BEGIN
  // Ensure that the implicit definition is always the last definition
  WITH FRowDef.Insert(FRowDef.Count-1) AS TGridLayoutRowDefinition DO BEGIN
    FMode := Mode;

    CASE Mode OF
      gsmAutosize : FFactor := 0;
      gsmStar     : FFactor := Factor;
      gsmPixels   : FFactor := Trunc(Factor);
    END;
  END;
END;


// TODO
//PROCEDURE TGridLayout.RemoveItem(Item: TGridLayoutItem);
//BEGIN
//  Assert(Assigned(Item));
//
//  FItems.Remove(Item);
//END;


// TODO
//PROCEDURE TGridLayout.RemoveColumnDefinition(ColumnDefinition: TGridLayoutColumnDefinition);
//BEGIN
//  Assert(ColumnDefinition<>FImplicitColumnDef, 'Can not remove implicit definition.');
//
//  FColumnDef.Remove(ColumnDefinition);
//END;


// TODO
//PROCEDURE TGridLayout.RemoveRowDefinition(RowDefinition: TGridLayoutRowDefinition);
//BEGIN
//  Assert(RowDefinition<>FImplicitRowDef, 'Can not remove implicit definition.');
//
//  FRowDef.Remove(RowDefinition);
//END;


PROCEDURE TGridLayout.SetColumnDefinitionCollection(CONST AValue : TGridLayoutColumnCollection);
BEGIN
  FColumnDef.Assign(AValue);
END;


PROCEDURE TGridLayout.SetRowDefinitionCollection(CONST AValue: TGridlayoutRowCollection);
BEGIN
  FRowDef.Assign(AValue);
END;


PROCEDURE TGridLayout.SetItemCollection(CONST AValue: TGridLayoutItemCollection);
BEGIN
  FItems.Assign(AValue);
END;


PROCEDURE TGridLayout.CMControlChange(var Message: TCMControlChange);
BEGIN
  INHERITED;

  // Designer-Support:
  // This is called if a control's parent is set to the gridlayout or if the parent was the gridlayout.

  IF NOT (csLoading IN ComponentState) AND (csDesigning IN ComponentState) THEN BEGIN
    //ShowMessageFmt('CMControlChange: Control: %s; Parent: %s Inserting: %d at Pos (%d, %d)', [ Message.Control.Name, Message.Control.Parent.Name, IfThen(Message.Inserting, 1, 0), Message.Control.Top, Message.Control.Left]);

    DisableAlign;
    TRY
      IF Message.Inserting AND (Message.Control.Parent = Self) THEN BEGIN
        //Message.Control.Anchors := [];

        FOR VAR I := 0 TO FItems.Count-1 DO BEGIN
          VAR Item := FItems.Items[I] AS TGridLayoutItem;

          IF Item.Control = Message.Control THEN BEGIN
            // Control already assigned. Do nothing
            EXIT;
          END;
        END;

        VAR CtrlScreenRect := Message.Control.ClientToScreen(Message.Control.ClientRect);
        VAR ClientPos := ScreenToClient(CtrlScreenRect.Location);
        VAR Col := ColumnIndexFromPos(ClientPos);
        VAR Row := RowIndexFromPos(ClientPos);

        AddItem(Message.Control, Row, Col);
      END
      ELSE BEGIN
        RemoveItemForControl(Message.Control);
      END;
    FINALLY
      EnableAlign;
    END;
  END;
END;


PROCEDURE TGridLayout.AlignControls  (    AControl : TControl;
                                      VAR Rect     : TRect);

VAR i, c, r : Integer;
    Item : TGridLayoutItem;

    ColDef  : TGridLayoutColumnDefinition;
    RowDef  : TGridLayoutRowDefinition;

    Width      : Single;
    Height     : Single;

    SumNonStarWidth  : Single;
    SumNonStarHeight : Single;

    SumStarFactorsHorizontal : Single; // the sum of all sum factors in the column definitions
    SumStarFactorsVertical   : Single;

    StarWidthRemainder  : Single;
    StarHeightRemainder : Single;

    CtrlBounds : TRect;

BEGIN
  IF (FItems.Count > 0) OR (csDesigning IN ComponentState) THEN BEGIN
    AdjustClientRect(Rect);

    SetLength(FColumns, FColumnDef.Count);
    SetLength(FRows   , FRowDef.Count);

    SumNonStarWidth  := 0;
    SumNonStarHeight := 0;

    SumStarFactorsHorizontal := 0;
    SumStarFactorsVertical   := 0;


    // 1. pass - calculate row/column values for none star row/columns
    FOR c := 0 TO Length(FColumns)-1 DO BEGIN
      ColDef := FColumnDef.Items[c] AS TGridLayoutColumnDefinition;
      Width  := ColumnWidthAtIndex(c);

      IF ColDef.FMode = gsmStar THEN BEGIN
        SumStarFactorsHorizontal := SumStarFactorsHorizontal + Width;
      END
      ELSE BEGIN
        SumNonStarWidth := SumNonStarWidth + Width;
      END;

      FColumns[c].Width := Width;
      FColumns[c].Definition := colDef;
    END;


    FOR r := 0 TO Length(FRows)-1 DO BEGIN
      RowDef := FRowDef.Items[r] AS TGridLayoutRowDefinition;
      Height := RowHeightAtIndex(r);

      IF RowDef.FMode = gsmStar THEN BEGIN
        SumStarFactorsVertical := SumStarFactorsVertical + Height;
      END
      ELSE BEGIN
        SumNonStarHeight := SumNonStarHeight + Height;
      END;

      FRows[r].Height := Height;
      FRows[r].Definition := rowDef;
    END;

    StarWidthRemainder  := Rect.Width - SumNonStarWidth; // TODO ist Rect richtig?
    StarHeightRemainder := Rect.Height - SumNonStarHeight;


    // 2. pass - calculate star fractions
    // for columns
    FOR c := 0 TO Length(FColumns)-1 DO BEGIN

      // calculate width for star
      IF FColumns[c].Definition.FMode = gsmStar THEN BEGIN
        FColumns[c].Width := (StarWidthRemainder / SumStarFactorsHorizontal) * FColumns[c].Definition.Width;
      END;

      // set minX
      IF (c = 0)
      THEN FColumns[c].MinX := 0
      ELSE FColumns[c].MinX := FColumns[c-1].MinX + FColumns[c-1].Width;
    END;

    // and rows
    FOR r := 0 TO Length(FRows)-1 DO BEGIN

      // calculate height for star
      IF FRows[r].Definition.FMode = gsmStar THEN BEGIN
        FRows[r].Height := (StarHeightRemainder / SumStarFactorsVertical) * FRows[r].Definition.Height;
      END;

       // set minY
      IF (r = 0)
      THEN FRows[r].MinY := 0
      ELSE FRows[r].MinY := FRows[r-1].MinY + FRows[r-1].Height;
    END;


    // 3. pass - enum all items and set frames
    FOR i := 0 TO FItems.Count-1 DO BEGIN
      Item := FItems.Items[i] AS TGridLayoutItem;

      // skip invalid items
      IF   (Item = NIL)
        OR (Item.Control = NIL)
        OR (NOT Item.Control.Visible)
        OR (NOT InRange(Item.Row, 0, FRowDef.Count-1))
        OR (NOT InRange(Item.Column, 0, FColumnDef.Count-1))
      THEN BEGIN
        Continue;
      END;

// TODO
//      // if items view is not already a subview, add it
//      if (item.view.superview != self) {
//          [self insertSubview:item.view atIndex:itemIndex];
//      }

      // TODO Align, Margin
      // Set Control Bounds
      CtrlBounds.Top  := Trunc(FRows[Item.Row].MinY);
      CtrlBounds.Left := Trunc(FColumns[Item.Column].MinX);

      IF FColumns[Item.Column].Definition.FMode = gsmAutosize THEN BEGIN
        CtrlBounds.Width := Item.Control.BoundsRect.Width;
      END
      ELSE BEGIN
        CtrlBounds.Width := Trunc(FColumns[Item.Column].Width);
      END;

      IF FRows[Item.Row].Definition.FMode = gsmAutoSize THEN BEGIN
        CtrlBounds.Height := Item.Control.BoundsRect.Height;
      END
      ELSE BEGIN
        CtrlBounds.Height := Trunc(FRows[Item.Row].Height);
      END;

      Item.Control.BoundsRect := CtrlBounds;
    END;

    ControlsAligned();
  END; // of FItems.Count > 0

  IF Showing THEN BEGIN
    AdjustSize;
  END;
END;


FUNCTION TGridLayout.ColumnIndexFromPos(CONST Position: TPoint): INTEGER;
BEGIN
  IF NOT ClientRect.Contains(Position) THEN EXIT(-1);

  Result := -1;

  FOR VAR I := 0 TO Length(FColumns)-1 DO BEGIN
    VAR Col := FColumns[I];
    IF InRange(Position.X, Col.MinX, Col.MinX + Col.Width) THEN BEGIN
      EXIT(I);
    END;
  END;
END;


FUNCTION TGridLayout.RowIndexFromPos(CONST Position: TPoint): INTEGER;
BEGIN
  IF NOT ClientRect.Contains(Position) THEN EXIT(-1);

  Result := -1;

  FOR VAR I := 0 TO Length(FRows)-1 DO BEGIN
    VAR Row := FRows[I];
    IF InRange(Position.Y, Row.MinY, Row.MinY + Row.Height) THEN BEGIN
      EXIT(I);
    END;
  END;
END;



FUNCTION TGridLayout.ColumnWidthAtIndex(ColumnIndex: Integer): Single;
VAR colDef   : TGridLayoutColumnDefinition;
    maxWidth : Single;
    item     : TCollectionItem;
BEGIN
  colDef := FColumnDef.Items[ColumnIndex] AS TGridLayoutColumnDefinition;

  IF (colDef.FMode = gsmAutosize) THEN BEGIN
    // find widest view in column
    maxWidth := 0;

    FOR item IN FItems DO BEGIN
      WITH item AS TGridLayoutItem DO BEGIN
        IF (Column = ColumnIndex) THEN BEGIN
          maxWidth := Max(Control.Width, maxWidth);
        END;
      END;
    END;

    Result := maxWidth;
  END
  ELSE BEGIN
    Result := colDef.Width;
  END;
END;



FUNCTION TGridLayout.RowHeightAtIndex(RowIndex: Integer): Single;
VAR rowDef    : TGridLayoutRowDefinition;
    maxHeight : Single;
    item      : TCollectionItem;
BEGIN
  rowDef := FRowDef.Items[RowIndex] AS TGridLayoutRowDefinition;

  IF (rowDef.FMode = gsmAutosize) THEN BEGIN
    // find tallest view in row
    maxHeight := 0;

    FOR item IN FItems DO BEGIN
      WITH item AS TGridLayoutItem DO BEGIN
        IF (Row = RowIndex) THEN BEGIN
          maxHeight := Max(Control.Height, maxHeight);
        END;
      END;
    END;

    Result := maxHeight;
  END
  ELSE BEGIN
    Result := rowDef.Height;
  END;
END;


PROCEDURE TGridLayout.Paint;
BEGIN
  INHERITED;

  // Background
  Canvas.Brush.Color := Color;
  Canvas.FillRect(self.ClientRect);

  IF (csDesigning IN ComponentState) THEN BEGIN
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color   := clWhite;
    Canvas.Pen.Mode    := pmXor;
    Canvas.Pen.Style   := psDot;

    VAR RowOutOfBounds := FALSE;
    VAR ColOutOfBounds := FALSE;

    VAR ClientWidth := ClientWidth;
    VAR ClientHeight := ClientHeight;

    // If Row/Col Size is 0 pmXor deletes the old line  => Max(1, size)

    // Rows
    FOR VAR Loop := 0 TO Length(FRows)-1 DO BEGIN
      VAR Row := FRows[Loop];

      IF (Loop < Length(FRows)-1) OR (Row.Definition.Mode <> gsmStar) THEN BEGIN
        VAR MaxY := Trunc(Row.MinY + Max(1, Row.Height));

        Canvas.MoveTo(0 , MaxY);
        Canvas.LineTo(ClientWidth, MaxY);

        RowOutOfBounds := MaxY > ClientHeight;
      END;
    END;

    // Columns
    FOR VAR Loop := 0 TO Length(FColumns)-1 DO BEGIN
      VAR Col := FColumns[Loop];

      IF (Loop < Length(FColumns)-1) OR (Col.Definition.Mode <> gsmStar) THEN BEGIN
        VAR MaxX := Trunc(Col.MinX + Max(1, Col.Width));

        Canvas.MoveTo(MaxX, 0);
        Canvas.LineTo(MaxX, ClientHeight);

        ColOutOfBounds := MaxX > ClientWidth;
      END;
    END;

    // Highlight edge if some row or column is out of bounds
    IF ColOutOfBounds OR RowOutOfBounds THEN BEGIN
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Color   := clRed;
      Canvas.Pen.Mode    := pmCopy;
      Canvas.Pen.Style   := psSolid;
      Canvas.Pen.Width   := 2;

      IF RowOutOfBounds THEN BEGIN
        Canvas.MoveTo(0          , ClientHeight-1);
        Canvas.LineTo(ClientWidth, ClientHeight-1);
      END;

      IF ColOutOfBounds THEN BEGIN
        Canvas.MoveTo(ClientWidth-1, 0);
        Canvas.LineTo(ClientWidth-1, ClientHeight);
      END;
    END;
  END;
END;








END.
