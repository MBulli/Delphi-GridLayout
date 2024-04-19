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


// Enables experimental Drag and Drop support for the form designer.
// Normally drag and drop is handled by the designer, this feature tries
// to outsmart the designer hook but currently fails doing so.
{ $ DEFINE EnableExperimentalDesignerHook}

{
 TODO:
 - RemoveCol/Row/Item/Clear methods - What should happen with the assigned controls?
 - TComponent Editor
 - TextOut Values in Paint for Columns
 - MinWidth/MinHeigth
 - Add "Row/Column" fake properties to controls https://edn.embarcadero.com/article/33448
 - Padding property for TGridLayoutItem
 - Small parser for quick row/column setup in code like GL.SetColumns('10px 2* auto');
 - Refactoring: It should be possible to unify the layout algorithm code to be agnostic of the layout direction.
                Meaning, the same code should compute the rows as well the columns.
}

TYPE
  TGridLayoutSizeMode = (gsmPixels, gsmStar, gsmAutosize);

  TGridVisibility = (glvVisible, glvCollapsed, glvHidden);

  TGridAutoSizeMode = (glaBoth, glaVertical, glaHorizontal);

  TGridLayout = CLASS;

  TGridLayoutDefinitionBase = CLASS(TCollectionItem)
  PROTECTED
    FMode   : TGridLayoutSizeMode;
    FFactor : Single;
    FVisibility : TGridVisibility;

    FUNCTION GetDisplayName: string; OVERRIDE;

    PROCEDURE SetFactor(NewValue : Single);
    PROCEDURE SetMode  (NewValue : TGridLayoutSizeMode);
    PROCEDURE SetVisibility(NewValue : TGridVisibility);

  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;
  END;


  TGridLayoutColumnDefinition = CLASS (TGridLayoutDefinitionBase)
  PUBLISHED
    PROPERTY Mode       : TGridLayoutSizeMode READ FMode   WRITE SetMode DEFAULT gsmAutosize;
    PROPERTY Width      : Single              READ FFactor WRITE SetFactor;
    PROPERTY Visibility : TGridVisibility READ FVisibility WRITE SetVisibility DEFAULT glvVisible;
  END;


  TGridLayoutRowDefinition = CLASS (TGridLayoutDefinitionBase)
  PUBLISHED
    PROPERTY Mode       : TGridLayoutSizeMode READ FMode   WRITE SetMode DEFAULT gsmAutosize;
    PROPERTY Height     : Single              READ FFactor WRITE SetFactor;
    PROPERTY Visibility : TGridVisibility     READ FVisibility WRITE SetVisibility DEFAULT glvVisible;
  END;


  TGridLayoutColumnCollection = CLASS(TOwnedCollection)
  PRIVATE
    FUNCTION HasAnyStarRow : BOOLEAN;

  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
  END;

  TGridlayoutRowCollection = CLASS(TOwnedCollection)
  PRIVATE
    FUNCTION HasAnyStarRow : BOOLEAN;

  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
  END;


  TGridLayoutItem = CLASS(TCollectionItem)
{$IFDEF EnableExperimentalDesignerHook}
  STRICT PRIVATE
    FOrigCtrlWndProc : TWndMethod;

    PROCEDURE DesignControlWndProcHook(VAR Message: TMessage);
{$ENDIF}

  STRICT PRIVATE
    FControl : TControl;

    // To make the designer experience more stable,
    // we don't use the row/col index to reference the actual row/col definition.
    // Instead, we hold a pointer directly to the object.
    // This solves the issue of changing row/col definitions in the designer,
    // if you add something new and move it up in the structure view.
    // For this the row/col definition can still be assigned by index
    // but in the background everything (up to the actual layouting) uses the pointer.
    // But the pointer can't be stored in the dfm, so the indices
    // are stored in the dfm and mapped in the ReadState() method of the GridLayout.
    FRowRef  : TGridLayoutRowDefinition;
    FColRef  : TGridLayoutColumnDefinition;

    FColumnSpan : Integer;
    FRowSpan    : Integer;

    FVisible : Boolean;

    PROCEDURE SetControl   (NewValue : TControl);
    PROCEDURE SetColumnSpan(NewValue : Integer);
    PROCEDURE SetRowSpan   (NewValue : Integer);

    PROCEDURE SetRowRef    (NewValue : TGridLayoutRowDefinition);
    PROCEDURE SetColRef    (NewValue : TGridLayoutColumnDefinition);

    PROCEDURE SetColIndex  (NewValue : Integer);
    PROCEDURE SetRowIndex  (NewValue : Integer);
    FUNCTION  GetColIndex : INTEGER;
    FUNCTION  GetRowIndex : INTEGER;

    PROCEDURE SetVisible(AValue : Boolean);
  PRIVATE

    PROCEDURE SetRefs(RowRef : TGridLayoutRowDefinition; ColRef : TGridLayoutColumnDefinition);

  PROTECTED
    FUNCTION GetDisplayName : STRING; OVERRIDE;

  PUBLIC
    CONSTRUCTOR Create(Collection: TCollection); OVERRIDE;

    FUNCTION OwningLayout : TGridLayout;

  PUBLISHED
    PROPERTY Control    : TControl READ FControl    WRITE SetControl     DEFAULT NIL;
    PROPERTY Column     : Integer  READ GetColIndex WRITE SetColIndex    DEFAULT -1;
    PROPERTY Row        : Integer  READ GetRowIndex WRITE SetRowIndex    DEFAULT -1;
    PROPERTY ColumnSpan : Integer  READ FColumnSpan WRITE SetColumnSpan  DEFAULT 1;
    PROPERTY RowSpan    : Integer  READ FRowSpan    WRITE SetRowSpan     DEFAULT 1;
    PROPERTY Visible    : Boolean  READ FVisible    WRITE SetVisible     DEFAULT TRUE;

    PROPERTY RowRef     : TGridLayoutRowDefinition    READ FRowRef WRITE SetRowRef STORED FALSE DEFAULT NIL;
    PROPERTY ColumnRef  : TGridLayoutColumnDefinition READ FColRef WRITE SetColRef STORED FALSE DEFAULT NIL;
  END;

  TGridLayoutItemCollection = CLASS(TOwnedCollection)
  PROTECTED
    PROCEDURE Update(Item: TCollectionItem); OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TPersistent);
  END;

  TGridLayoutAlgorithm = CLASS
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

    STRICT PRIVATE
      FParentLayout : TGridLayout;

      // Calculated layout values
      FColumns : TArray<TGridLayoutColumnTuple>;
      FRows    : TArray<TGridLayoutRowTuple>;

      FUNCTION GetColumnCount : INTEGER;  INLINE;
      FUNCTION GetRowCount    : INTEGER;  INLINE;

      FUNCTION GetColumn(Index : INTEGER) : TGridLayoutColumnTuple;  INLINE;
      FUNCTION GetRow   (Index : INTEGER) : TGridLayoutRowTuple;     INLINE;

      FUNCTION ColumnVisiblity(ColumnIndex : INTEGER) : TGridVisibility;
      FUNCTION RowVisiblity(RowIndex : INTEGER) : TGridVisibility;

      FUNCTION ColumnWidthAtIndex (ColumnIndex : Integer) : Single;
      FUNCTION RowHeightAtIndex   (RowIndex    : Integer) : Single;

    PUBLIC
      CONSTRUCTOR Create(ParentLayout : TGridLayout);

      PROCEDURE Calculate(ClientRect : TRect);

      FUNCTION ControlRect(BoundsRect: TRect; Row, Column: Integer) : TRect;    OVERLOAD;
      FUNCTION ControlRect(BoundsRect: TRect; Row, Column, RowSpan, ColumnSpan: Integer) : TRect;    OVERLOAD;

      PROPERTY ColumnCount : INTEGER READ GetColumnCount;
      PROPERTY RowCount    : INTEGER READ GetRowCount;

      PROPERTY Columns[Index : INTEGER] : TGridLayoutColumnTuple READ GetColumn;
      PROPERTY Rows   [Index : INTEGER] : TGridLayoutRowTuple READ GetRow;
  END;


  TGridLayout = CLASS(TCustomPanel)
  PRIVATE
    FItems     : TGridLayoutItemCollection; // TObjectList<TGridLayoutItem>;
    FRowDef    : TGridlayoutRowCollection;    // TObjectList<TGridLayoutRowDefinition>;
    FColumnDef : TGridLayoutColumnCollection; // TObjectList<TGridLayoutColumnDefinition>;
    FAlgorithm : TGridLayoutAlgorithm;

    FColumnGap : INTEGER;
    FRowGap    : INTEGER;

    FAutoSizeMode : TGridAutoSizeMode;

    FUNCTION GetColumnCount () : Integer;
    FUNCTION GetRowCount    () : Integer;

    PROCEDURE SetColumnGap(CONST NewValue : INTEGER);
    PROCEDURE SetRowGap   (CONST NewValue : INTEGER);

    PROCEDURE SetColumnDefinitionCollection(CONST AValue : TGridLayoutColumnCollection);
    PROCEDURE SetRowDefinitionCollection   (CONST AValue : TGridlayoutRowCollection);
    PROCEDURE SetItemCollection            (CONST AValue : TGridLayoutItemCollection);

    FUNCTION  GetColumnVisbility(ColumnIndex : Integer) : TGridVisibility;
    FUNCTION  GetRowVisbility   (RowIndex : Integer) : TGridVisibility;
    PROCEDURE SetColumnVisbility(ColumnIndex : Integer; Visbility : TGridVisibility);
    PROCEDURE SetRowVisbility   (RowIndex : Integer; Visbility : TGridVisibility);

    PROCEDURE CMControlChange(var Message: TCMControlChange); MESSAGE CM_CONTROLCHANGE;

  PROTECTED
    PROCEDURE AlignControls  (    AControl : TControl;
                              VAR Rect     : TRect);                            OVERRIDE;
    PROCEDURE Paint;                                                            OVERRIDE;

    PROCEDURE ReadState(Reader: TReader); OVERRIDE;

    FUNCTION CanAutoSize(VAR NewWidth: Integer; VAR NewHeight: Integer): Boolean; OVERRIDE;



  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR  Destroy();                  OVERRIDE;

    PROCEDURE BeginUpdate;
    PROCEDURE EndUpdate;

    PROCEDURE AddColumn(AMode : TGridLayoutSizeMode; AFactor : Single);
    PROCEDURE AddRow   (AMode : TGridLayoutSizeMode; AFactor : Single);

    FUNCTION AddItem(Control : TControl;
                     Row     : Integer;
                     Column  : Integer) : TGridLayoutItem; OVERLOAD;

    FUNCTION AddItem(Control : TControl;
                     RowDef  : TGridLayoutRowDefinition;
                     ColDef  : TGridLayoutColumnDefinition) : TGridLayoutItem; OVERLOAD;


    PROCEDURE RemoveItemForControl(Control : TControl);

//    PROCEDURE AddItem    (Item : TGridLayoutItem);
//    PROCEDURE RemoveItem (Item : TGridLayoutItem);

//    PROCEDURE AddRowDefinition       (RowDefinition    : TGridLayoutRowDefinition);
//    PROCEDURE RemoveRowDefinition    (RowDefinition    : TGridLayoutRowDefinition);

//    PROCEDURE AddColumnDefinition    (ColumnDefinition : TGridLayoutColumnDefinition);
//    PROCEDURE RemoveColumnDefinition (ColumnDefinition : TGridLayoutColumnDefinition);

    PROPERTY ColumnVisbility[Index: Integer] : TGridVisibility READ GetColumnVisbility  WRITE SetColumnVisbility;
    PROPERTY RowVisbility[Index: Integer] : TGridVisibility READ GetRowVisbility  WRITE SetRowVisbility;

    FUNCTION SetColumnVisbilityForControl(AControl : TControl; Visibility : TGridVisibility) : INTEGER;
    FUNCTION SetRowVisbilityForControl   (AControl : TControl; Visibility : TGridVisibility) : INTEGER;

    FUNCTION GetItemFromControl(AControl : TControl) : TGridLayoutItem;

    FUNCTION ColumnIndexFromPos(CONST Position : TPoint) : INTEGER;
    FUNCTION RowIndexFromPos   (CONST Position : TPoint) : INTEGER;

    // TODO: Functions are not recursive; Meaning needs AControl.Parent=self to return something.
    FUNCTION ColumnIndexFromControl(CONST AControl : TControl) : INTEGER;
    FUNCTION RowIndexFromControl   (CONST AControl : TControl) : INTEGER;

    FUNCTION ColumnOrNil(CONST ColumnIndex : INTEGER) : TGridLayoutColumnDefinition;
    FUNCTION RowOrNil   (CONST RowIndex    : INTEGER) : TGridLayoutRowDefinition;

    PROPERTY  ColumnCount : Integer READ GetColumnCount;
    PROPERTY  RowCount    : Integer READ GetRowCount;

    PROPERTY  Algorithm : TGridLayoutAlgorithm READ FAlgorithm;

  PUBLISHED
    PROPERTY Align;
    PROPERTY AutoSize;
    PROPERTY Color;
    PROPERTY ParentBackground;
    PROPERTY ParentColor;

    PROPERTY ColumnDefinitions : TGridLayoutColumnCollection READ FColumnDef WRITE SetColumnDefinitionCollection;
    PROPERTY RowDefinitions    : TGridLayoutRowCollection    READ FRowDef    WRITE SetRowDefinitionCollection;
    PROPERTY Items             : TGridLayoutItemCollection   READ FItems     WRITE SetItemCollection;

    PROPERTY ColumnGap : INTEGER READ FColumnGap WRITE SetColumnGap DEFAULT 0;
    PROPERTY RowGap    : INTEGER READ FRowGap    WRITE SetRowGap    DEFAULT 0;

    PROPERTY AutoSizeMode : TGridAutoSizeMode READ FAutoSizeMode WRITE FAutoSizeMode DEFAULT glaBoth;
  END;

IMPLEMENTATION

{ TGridLayoutDefinitionBase }

CONSTRUCTOR TGridLayoutDefinitionBase.Create(Collection: TCollection);
BEGIN
  INHERITED Create(Collection);

  FMode       := gsmAutosize;
  FFactor     := 0;
  FVisibility := glvVisible;
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

  IF FVisibility = glvCollapsed THEN BEGIN
    Result := Result + ' (collapsed)';
  END
  ELSE IF FVisibility = glvHidden THEN BEGIN
    Result := Result + ' (hidden)';
  END
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


PROCEDURE TGridLayoutDefinitionBase.SetVisibility(NewValue: TGridVisibility);
BEGIN
  FVisibility := NewValue;
  Changed(false);
END;

{ TGridLayoutColumnCollection }

CONSTRUCTOR TGridLayoutColumnCollection.Create(AOwner: TPersistent);
BEGIN
  INHERITED Create(AOwner, TGridLayoutColumnDefinition);
END;


FUNCTION TGridLayoutColumnCollection.HasAnyStarRow: BOOLEAN;
BEGIN
  FOR VAR I := 0 TO Count-1 DO BEGIN
    IF TGridLayoutColumnDefinition(Items[I]).Mode = gsmStar THEN BEGIN
      EXIT(TRUE);
    END;
  END;

  EXIT(FALSE);
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


FUNCTION TGridlayoutRowCollection.HasAnyStarRow: BOOLEAN;
BEGIN
  FOR VAR I := 0 TO Count-1 DO BEGIN
    IF TGridLayoutRowDefinition(Items[I]).Mode = gsmStar THEN BEGIN
      EXIT(TRUE);
    END;
  END;

  EXIT(FALSE);
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

  FControl    := nil;
  FRowRef     := nil;
  FColRef     := nil;
  FRowSpan    := 1;
  FColumnSpan := 1;
  FVisible    := TRUE;
END;


{$IFDEF EnableExperimentalDesignerHook}
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
{$ENDIF}


FUNCTION TGridLayoutItem.GetDisplayName: STRING;
BEGIN
  VAR CtrlName := 'nil';

  IF Assigned(FControl) THEN BEGIN
    IF FControl.Name <> ''
    THEN CtrlName := FControl.Name
    ELSE CtrlName := FControl.ClassName;
  END;

  Result := Format('%s[%d, %d] (%s)', [ClassName, Row, Column, CtrlName]);

{$IFDEF EnableExperimentalDesignerHook}
  IF Assigned(FOrigCtrlWndProc) THEN BEGIN
    Result := Result + ' H';
  END;
{$ENDIF}
END;


FUNCTION TGridLayoutItem.OwningLayout: TGridLayout;
BEGIN
  Result := Collection.Owner AS TGridLayout;
END;


PROCEDURE TGridLayoutItem.SetColIndex(NewValue : Integer);
BEGIN
  IF NewValue <> GetColIndex THEN BEGIN
    VAR ColDef := OwningLayout.ColumnOrNil(NewValue);
    SetColRef(ColDef);
  END;
END;


PROCEDURE TGridLayoutItem.SetRowIndex(NewValue : Integer);
BEGIN
  IF NewValue <> GetRowIndex THEN BEGIN
    VAR RowDef := OwningLayout.RowOrNil(NewValue);
    SetRowRef(RowDef);
  END;
END;


FUNCTION TGridLayoutItem.GetColIndex: INTEGER;
BEGIN
  IF FColRef <> NIL
  THEN EXIT(FColRef.Index)
  ELSE EXIT(-1);
END;


FUNCTION TGridLayoutItem.GetRowIndex: INTEGER;
BEGIN
  IF FRowRef <> NIL
  THEN EXIT(FRowRef.Index)
  ELSE EXIT(-1);
END;


PROCEDURE TGridLayoutItem.SetColumnSpan(NewValue: Integer);
BEGIN
  IF NewValue <> FColumnSpan THEN BEGIN
    FColumnSpan := NewValue;
    Changed(false);
  END;
END;


PROCEDURE TGridLayoutItem.SetRefs(RowRef: TGridLayoutRowDefinition; ColRef: TGridLayoutColumnDefinition);
BEGIN
  SetRowRef(RowRef);
  SetColRef(ColRef);
END;


PROCEDURE TGridLayoutItem.SetRowRef(NewValue: TGridLayoutRowDefinition);
BEGIN
  IF NewValue <> NIL THEN BEGIN
    Assert(NewValue.Collection = OwningLayout.RowDefinitions);
  END;

  IF NewValue <> FRowRef THEN BEGIN
    FRowRef := NewValue;
    Changed(false);
  END;
END;


PROCEDURE TGridLayoutItem.SetColRef(NewValue: TGridLayoutColumnDefinition);
BEGIN
  IF NewValue <> NIL THEN BEGIN
    Assert(NewValue.Collection = OwningLayout.ColumnDefinitions);
  END;

  IF NewValue <> FColRef THEN BEGIN
    FColRef := NewValue;
    Changed(false);
  END;
END;


PROCEDURE TGridLayoutItem.SetRowSpan(NewValue: Integer);
BEGIN
  IF NewValue <> FRowSpan THEN BEGIN
    FRowSpan := NewValue;
    Changed(false);
  END;
END;

PROCEDURE TGridLayoutItem.SetVisible(AValue: Boolean);
BEGIN
  IF AValue <> FVisible THEN BEGIN
    FVisible := AValue;
    Changed(false);
  END;
END;

PROCEDURE TGridLayoutItem.SetControl(NewValue: TControl);

{$IFDEF EnableExperimentalDesignerHook}
  FUNCTION _AlreadyHooked(CONST Ctrl : TControl) : BOOLEAN; INLINE;
  BEGIN
    Result := (TMethod(Ctrl.WindowProc).Code = @TGridLayoutItem.DesignControlWndProcHook);
  END;

  FUNCTION _ShouldHookWndProc: BOOLEAN;
  BEGIN
    IF NOT Assigned(FControl) THEN EXIT(FALSE);
    IF (csDestroying IN FControl.ComponentState) THEN EXIT(FALSE);
    IF _AlreadyHooked(FControl) THEN EXIT(FALSE);

    Result := (csDesigning IN FControl.ComponentState);
  END;
{$ENDIF}

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

{$IFDEF EnableExperimentalDesignerHook}
  // Reset old control state
  IF FControl <> NIL THEN BEGIN
    IF Assigned(FOrigCtrlWndProc) THEN BEGIN
      FControl.WindowProc := FOrigCtrlWndProc;
      FOrigCtrlWndProc := NIL;
    END;
  END;

  FOrigCtrlWndProc := NIL;
{$ENDIF}

  // Set new control
  FControl := NewValue;

  IF Assigned(FControl) THEN BEGIN
    // Set Parent if necessary
    IF (FControl.Parent <> OwningLayout) THEN BEGIN
      FControl.Parent := OwningLayout;
    END;

{$IFDEF EnableExperimentalDesignerHook}
    // Hook window for drag and drop form designer hack
    IF _ShouldHookWndProc THEN BEGIN
      FOrigCtrlWndProc := FControl.WindowProc;
      FControl.WindowProc := DesignControlWndProcHook;
    END;
{$ENDIF}
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
  FAlgorithm := TGridLayoutAlgorithm.Create(self);

  Color := clWhite;
END;


DESTRUCTOR TGridLayout.Destroy;
BEGIN
  FreeAndNil(FItems);
  FreeAndNil(FRowDef);
  FreeAndNil(FColumnDef);
  FreeAndNil(FAlgorithm);

  INHERITED;
END;


PROCEDURE TGridLayout.ReadState(Reader: TReader);
BEGIN
  INHERITED;

  VAR RowMax := FRowDef.Count-1;
  VAR ColMax := FColumnDef.Count-1;

  FOR VAR I := 0 TO FItems.Count-1 DO BEGIN
    VAR Item := FItems.Items[I] AS TGridLayoutItem;

    IF Item = NIL THEN CONTINUE;

    VAR Row := NIL;
    VAR Col := NIL;

    IF InRange(Item.Row, 0, RowMax) THEN BEGIN
      Row := FRowDef.Items[Item.Row];
    END;

    IF InRange(Item.Column, 0, ColMax) THEN BEGIN
      Col := FColumnDef.Items[Item.Column];
    END;

    Item.SetRefs(Row, Col);
  END;

END;


FUNCTION TGridLayout.GetColumnCount: Integer;
BEGIN
  Result := FColumnDef.Count;
END;


FUNCTION TGridLayout.GetRowCount: Integer;
BEGIN
  Result := FRowDef.Count;
END;


PROCEDURE TGridLayout.BeginUpdate;
BEGIN
  FItems.BeginUpdate;
  FColumnDef.BeginUpdate;
  FRowDef.BeginUpdate;
END;


PROCEDURE TGridLayout.EndUpdate;
BEGIN
  FItems.EndUpdate;
  FColumnDef.EndUpdate;
  FRowDef.EndUpdate;
END;


FUNCTION TGridLayout.AddItem(Control : TControl; Row : Integer; Column : Integer) : TGridLayoutItem;
BEGIN
  VAR RowDef := RowOrNil(Row);
  VAR ColDef := ColumnOrNil(Column);

  Result := AddItem(Control, RowDef, ColDef);
END;


FUNCTION TGridLayout.AddItem(Control: TControl; RowDef: TGridLayoutRowDefinition; ColDef: TGridLayoutColumnDefinition) : TGridLayoutItem;
BEGIN
  Assert(Assigned(Control));
  IF RowDef <> NIL THEN Assert(RowDef.Collection = Self.RowDefinitions);
  IF ColDef <> NIL THEN Assert(ColDef.Collection = Self.ColumnDefinitions);

  Result := FItems.Add AS TGridLayoutItem;

  Result.SetRefs(RowDef, ColDef);
  Result.Control := Control;
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


PROCEDURE TGridLayout.AddColumn(AMode: TGridLayoutSizeMode; AFactor: Single);
BEGIN
  WITH FColumnDef.Add AS TGridLayoutColumnDefinition DO BEGIN
    FMode := AMode;

    CASE AMode OF
      gsmAutosize : FFactor := 0;
      gsmStar     : FFactor := AFactor;
      gsmPixels   : FFactor := Trunc(AFactor);
    END;
  END;
END;


PROCEDURE TGridLayout.AddRow(AMode: TGridLayoutSizeMode; AFactor: Single);
BEGIN
  WITH FRowDef.Add AS TGridLayoutRowDefinition DO BEGIN
    FMode := AMode;

    CASE AMode OF
      gsmAutosize : FFactor := 0;
      gsmStar     : FFactor := AFactor;
      gsmPixels   : FFactor := Trunc(AFactor);
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
//
//  FColumnDef.Remove(ColumnDefinition);
//END;


// TODO
//PROCEDURE TGridLayout.RemoveRowDefinition(RowDefinition: TGridLayoutRowDefinition);
//BEGIN
//
//  FRowDef.Remove(RowDefinition);
//END;


PROCEDURE TGridLayout.SetColumnDefinitionCollection(CONST AValue : TGridLayoutColumnCollection);
BEGIN
  FColumnDef.Assign(AValue);
END;


PROCEDURE TGridLayout.SetColumnGap(CONST NewValue: INTEGER);
BEGIN
  IF NewValue < 0 THEN RAISE Exception.CreateFmt('Invalid column gap value "%d".', [NewValue]);

  IF FColumnGap <> NewValue THEN BEGIN
    FColumnGap := NewValue;
    AdjustSize;
    Realign;
    Invalidate;
  END;
END;


PROCEDURE TGridLayout.SetRowDefinitionCollection(CONST AValue: TGridlayoutRowCollection);
BEGIN
  FRowDef.Assign(AValue);
END;


PROCEDURE TGridLayout.SetRowGap(CONST NewValue: INTEGER);
BEGIN
  IF NewValue < 0 THEN RAISE Exception.CreateFmt('Invalid row gap value "%d".', [NewValue]);

  IF FRowGap <> NewValue THEN BEGIN
    FRowGap := NewValue;
    AdjustSize;
    Realign;
    Invalidate;
  END;
END;


FUNCTION TGridLayout.GetColumnVisbility(ColumnIndex: Integer): TGridVisibility;
BEGIN
  Result := (FColumnDef.Items[ColumnIndex] AS TGridLayoutColumnDefinition).Visibility
END;


FUNCTION TGridLayout.GetRowVisbility(RowIndex: Integer): TGridVisibility;
BEGIN
  Result := (FRowDef.Items[RowIndex] AS TGridLayoutRowDefinition).Visibility;
END;


PROCEDURE TGridLayout.SetColumnVisbility(ColumnIndex : Integer; Visbility : TGridVisibility);
BEGIN
  (FColumnDef.Items[ColumnIndex] AS TGridLayoutColumnDefinition).Visibility := Visbility;
END;


PROCEDURE TGridLayout.SetRowVisbility(RowIndex: Integer; Visbility: TGridVisibility);
BEGIN
  (FRowDef.Items[RowIndex] AS TGridLayoutRowDefinition).Visibility := Visbility;
END;


FUNCTION TGridLayout.SetColumnVisbilityForControl(AControl : TControl; Visibility : TGridVisibility) : INTEGER;
BEGIN
  VAR ColIndex := ColumnIndexFromControl(AControl);

  IF InRange(ColIndex, 0, FColumnDef.Count) THEN BEGIN
    SetColumnVisbility(ColIndex, Visibility);
  END;

  Result := ColIndex;
END;


FUNCTION TGridLayout.SetRowVisbilityForControl(AControl : TControl; Visibility : TGridVisibility) : INTEGER;
BEGIN
  VAR RowIndex := RowIndexFromControl(AControl);

  IF InRange(RowIndex, 0, FRowDef.Count) THEN BEGIN
    SetRowVisbility(RowIndex, Visibility);
  END;

  Result := RowIndex;
END;


FUNCTION TGridLayout.GetItemFromControl(AControl: TControl): TGridLayoutItem;
BEGIN
  IF AControl = NIL THEN EXIT(nil);
  IF AControl.Parent <> self THEN EXIT(nil);

  FOR VAR I := 0 TO FItems.Count-1 DO BEGIN
    VAR Item := TGridLayoutItem(FItems.Items[I]);

    IF Item.Control = AControl THEN BEGIN
      EXIT(Item);
    END;
  END;

  Exit(nil);
END;


PROCEDURE TGridLayout.SetItemCollection(CONST AValue: TGridLayoutItemCollection);
BEGIN
  FItems.Assign(AValue);
END;


FUNCTION TGridLayout.CanAutoSize(VAR NewWidth, NewHeight: Integer): Boolean;
BEGIN
  VAR VerticalChanged := FALSE;
  VAR HorizontalChanged := FALSE;

  VAR DoVertical   := (FRowDef.Count > 0) AND ((FAutoSizeMode = glaBoth) OR (FAutoSizeMode = glaVertical));
  VAR DoHorizontal := (FColumnDef.Count > 0) AND ((FAutoSizeMode = glaBoth) OR (FAutoSizeMode = glaHorizontal));

  FAlgorithm.Calculate(TRect.Create(0, 0, NewWidth, NewHeight));

  IF DoVertical THEN BEGIN
    IF NOT FRowDef.HasAnyStarRow THEN BEGIN
      VAR LastRow := FAlgorithm.Rows[FAlgorithm.RowCount-1];
      VAR TotalHeight := TRUNC(LastRow.MinY + LastRow.Height);

      IF NewHeight <> TotalHeight THEN BEGIN
        NewHeight := TotalHeight;
        VerticalChanged := TRUE;
      END;
    END;
  END;

  IF DoHorizontal THEN BEGIN
    IF NOT FColumnDef.HasAnyStarRow THEN BEGIN
      VAR LastColumn := FAlgorithm.Columns[FAlgorithm.ColumnCount-1];
      VAR TotalWidth := TRUNC(LastColumn.MinX + LastColumn.Width);

      IF NewWidth <> TotalWidth THEN BEGIN
        NewWidth := TotalWidth;
        HorizontalChanged := TRUE;
      END;
    END;
  END;

  Result := VerticalChanged OR HorizontalChanged;
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

        // If Control is dragged from the palette list and dropped while holding the ctrl key,
        // the GridLayout tries to place the control in the cell under the mouse cursor.
        // The default behavior is to set the column and row to -1 to let the user decide
        // where the control should be placed, as the drop position is not always the best choice
        // and might mess up the bounds of the control, which makes it hard to move them to autosize
        // columns or rows.
        IF GetKeyState(VK_CONTROL) < 0 THEN BEGIN
          VAR CtrlScreenRect := Message.Control.ClientToScreen(Message.Control.ClientRect);
          VAR ClientPos := ScreenToClient(CtrlScreenRect.Location);
          VAR Col := ColumnIndexFromPos(ClientPos);
          VAR Row := RowIndexFromPos(ClientPos);

          AddItem(Message.Control, Row, Col);
        END
        ELSE BEGIN
          AddItem(Message.Control, -1, -1);
        END;
      END
      ELSE BEGIN
        RemoveItemForControl(Message.Control);
      END;
    FINALLY
      EnableAlign;
    END;
  END;
END;


PROCEDURE TGridLayout.AlignControls(AControl : TControl; VAR Rect : TRect);
BEGIN
  IF (FItems.Count > 0) OR (csDesigning IN ComponentState) THEN BEGIN
    AdjustClientRect(Rect);

    FAlgorithm.Calculate(Rect);

    // 3. pass - enum all items and set frames
    FOR VAR I := 0 TO FItems.Count-1 DO BEGIN
      VAR Item := FItems.Items[I] AS TGridLayoutItem;

      // skip invalid items
      IF   (Item = NIL)
        OR (Item.Control = NIL)
        OR (NOT InRange(Item.Row, 0, FRowDef.Count-1))
        OR (NOT InRange(Item.Column, 0, FColumnDef.Count-1))
        OR (Item.ColumnRef = NIL)
        OR (Item.RowRef = NIL)
      THEN BEGIN
        Continue;
      END;

      // Set Control Bounds
      VAR CtrlBounds  := FAlgorithm.ControlRect(Item.Control.BoundsRect, Item.Row, Item.Column, Item.RowSpan, Item.ColumnSpan);

      // If rows or columns are hidden or collapsed, the algorithm assigns the correct dimensions.
      // So we don't have to check for visibility or anything, just infer it from the CtrlBounds.
      IF CtrlBounds.IsEmpty THEN BEGIN
        Item.Control.Visible := FALSE;
      END
      ELSE BEGIN
        Item.Control.Visible := Item.Visible;
        Item.Control.Margins.SetControlBounds(CtrlBounds, TRUE);
      END;
    END;

    // Repaint grid lines in design mode
    IF csDesigning IN ComponentState THEN BEGIN
      Invalidate;
    END;

    ControlsAligned;
  END; // of FItems.Count > 0

  IF Showing THEN BEGIN
    AdjustSize;
  END;
END;


FUNCTION TGridLayout.ColumnIndexFromPos(CONST Position: TPoint): INTEGER;
BEGIN
  IF NOT ClientRect.Contains(Position) THEN EXIT(-1);

  Result := -1;

  FOR VAR I := 0 TO FAlgorithm.ColumnCount-1 DO BEGIN
    VAR Col := FAlgorithm.Columns[I];
    IF InRange(Position.X, Col.MinX, Col.MinX + Col.Width) THEN BEGIN
      EXIT(I);
    END;
  END;
END;


FUNCTION TGridLayout.RowIndexFromPos(CONST Position: TPoint): INTEGER;
BEGIN
  IF NOT ClientRect.Contains(Position) THEN EXIT(-1);

  Result := -1;

  FOR VAR I := 0 TO FAlgorithm.RowCount-1 DO BEGIN
    VAR Row := FAlgorithm.Rows[I];
    IF InRange(Position.Y, Row.MinY, Row.MinY + Row.Height) THEN BEGIN
      EXIT(I);
    END;
  END;
END;


FUNCTION TGridLayout.ColumnIndexFromControl(CONST AControl : TControl) : INTEGER;
BEGIN
  VAR Item := GetItemFromControl(AControl);

  IF Item = NIL THEN EXIT(-1);

  Exit(Item.Column);
END;


FUNCTION TGridLayout.RowIndexFromControl(CONST AControl : TControl) : INTEGER;
BEGIN
  VAR Item := GetItemFromControl(AControl);

  IF Item = NIL THEN EXIT(-1);

  Exit(Item.Row);
END;


FUNCTION TGridLayout.ColumnOrNil(CONST ColumnIndex : INTEGER) : TGridLayoutColumnDefinition;
BEGIN
  Result := NIL;

  IF InRange(ColumnIndex, 0, FColumnDef.Count-1) THEN BEGIN
    Result := FColumnDef.Items[ColumnIndex] AS TGridLayoutColumnDefinition;
  END;
END;


FUNCTION TGridLayout.RowOrNil(CONST RowIndex : INTEGER) : TGridLayoutRowDefinition;
BEGIN
  Result := NIL;

  IF InRange(RowIndex, 0, FRowDef.Count-1) THEN BEGIN
    Result := FRowDef.Items[RowIndex] AS TGridLayoutRowDefinition;
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
    FOR VAR Loop := 0 TO FAlgorithm.RowCount-2 DO BEGIN
      VAR Row := FAlgorithm.Rows[Loop];
      VAR MaxY := Trunc(Row.MinY + Max(1, Row.Height) + FRowGap/2);

      Canvas.MoveTo(0 , MaxY);
      Canvas.LineTo(ClientWidth, MaxY);

      RowOutOfBounds := MaxY > ClientHeight;
    END;

    // Columns
    FOR VAR Loop := 0 TO FAlgorithm.ColumnCount-2 DO BEGIN
      VAR Col := FAlgorithm.Columns[Loop];
      VAR MaxX := Trunc(Col.MinX + Max(1, Col.Width) + FColumnGap/2);

      Canvas.MoveTo(MaxX, 0);
      Canvas.LineTo(MaxX, ClientHeight);

      ColOutOfBounds := MaxX > ClientWidth;
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

{ TGridLayoutAlgorithm }


CONSTRUCTOR TGridLayoutAlgorithm.Create(ParentLayout: TGridLayout);
BEGIN
  FParentLayout := ParentLayout;
END;


PROCEDURE TGridLayoutAlgorithm.Calculate(ClientRect: TRect);
BEGIN
  SetLength(FColumns, FParentLayout.FColumnDef.Count);
  SetLength(FRows   , FParentLayout.FRowDef.Count);

  VAR SkipColumns := FALSE;
  VAR SkipRows    := FALSE;

  // Special cases:
  // No columns
  IF Length(FColumns) = 0 THEN BEGIN
    SetLength(FColumns, 1);
    FColumns[0].MinX       := 0;
    FColumns[0].Width      := ClientRect.Width;
    FColumns[0].Definition := NIL;
    SkipColumns := TRUE;
  END;

  // No rows
  IF Length(FRows) = 0 THEN BEGIN
    SetLength(FRows, 1);
    FRows[0].MinY       := 0;
    FRows[0].Height     := ClientRect.Height;
    FRows[0].Definition := NIL;
    SkipRows := TRUE;
  END;

  // Early exit if there are now user definied columns and rows
  IF SkipColumns AND SkipRows THEN EXIT;

  // Space taken by non-star columns and rows
  VAR SumNonStarWidth  : Single := 0.0;
  VAR SumNonStarHeight : Single := 0.0;

  // the sum of all sum factors in the column definitions
  VAR SumStarFactorsHorizontal : Single := 0.0;
  VAR SumStarFactorsVertical   : Single := 0.0;

  VAR NumColumnsWithGap := 0;
  VAR NumRowsWithGap    := 0;

  // 1. pass - calculate row/column values for none star row/columns
  IF NOT SkipColumns THEN BEGIN
    FOR VAR C := 0 TO Length(FColumns)-1 DO BEGIN
      VAR ColDef := FParentLayout.FColumnDef.Items[C] AS TGridLayoutColumnDefinition;
      VAR Width  := ColumnWidthAtIndex(C);

      IF ColDef.FMode = gsmStar THEN BEGIN
        SumStarFactorsHorizontal := SumStarFactorsHorizontal + Width;
      END
      ELSE BEGIN
        SumNonStarWidth := SumNonStarWidth + Width;
      END;

      IF ColumnVisiblity(C) <> glvCollapsed THEN BEGIN
        NumColumnsWithGap := NumColumnsWithGap + 1;
      END;

      FColumns[c].Width := Width;
      FColumns[c].Definition := colDef;
    END;
  END;

  IF NOT SkipRows THEN BEGIN
    FOR VAR R := 0 TO Length(FRows)-1 DO BEGIN
      VAR RowDef := FParentLayout.FRowDef.Items[R] AS TGridLayoutRowDefinition;
      VAR Height := RowHeightAtIndex(R);

      IF RowDef.FMode = gsmStar THEN BEGIN
        SumStarFactorsVertical := SumStarFactorsVertical + Height;
      END
      ELSE BEGIN
        SumNonStarHeight := SumNonStarHeight + Height;
      END;

      IF RowVisiblity(R) <> glvCollapsed THEN BEGIN
        NumRowsWithGap := NumRowsWithGap + 1;
      END;

      FRows[r].Height := Height;
      FRows[r].Definition := rowDef;
    END;
  END;

  VAR ColumnGap := Max(0, Self.FParentLayout.FColumnGap);
  VAR RowGap    := Max(0, Self.FParentLayout.FRowGap);

  VAR TotalColumnGap := Max(0, NumColumnsWithGap-1) * ColumnGap;
  VAR TotalRowGap    := Max(0, NumRowsWithGap-1   ) * RowGap;

  VAR StarWidthRemainder  := ClientRect.Width  - SumNonStarWidth  - TotalColumnGap;
  VAR StarHeightRemainder := ClientRect.Height - SumNonStarHeight - TotalRowGap;

  // 2. pass - calculate star fractions
  // for columns
  IF NOT SkipColumns THEN BEGIN
    FOR VAR C := 0 TO Length(FColumns)-1 DO BEGIN

      // calculate width for star
      IF FColumns[C].Definition.FMode = gsmStar THEN BEGIN
        FColumns[C].Width := (StarWidthRemainder / SumStarFactorsHorizontal) * FColumns[C].Definition.Width;
      END;

      // set minX
      IF (C = 0) THEN BEGIN
        FColumns[C].MinX := 0
      END
      ELSE IF (FColumns[C].Width > 0) THEN BEGIN
        FColumns[C].MinX := FColumns[C-1].MinX + FColumns[C-1].Width + ColumnGap;
      END
      ELSE BEGIN
        FColumns[C].MinX := FColumns[C-1].MinX + FColumns[C-1].Width;
      END;
    END;
  END;

  // and rows
  IF NOT SkipRows THEN BEGIN
    FOR VAR R := 0 TO Length(FRows)-1 DO BEGIN

      // calculate height for star
      IF FRows[R].Definition.FMode = gsmStar THEN BEGIN
        FRows[R].Height := (StarHeightRemainder / SumStarFactorsVertical) * FRows[R].Definition.Height;
      END;

       // set minY
      IF (R = 0) THEN BEGIN
        FRows[R].MinY := 0
      END
      ELSE IF (FRows[R].Height > 0) THEN BEGIN
        FRows[R].MinY := FRows[R-1].MinY + FRows[R-1].Height + RowGap;
      END
      ELSE BEGIN
        FRows[R].MinY := FRows[R-1].MinY + FRows[R-1].Height;
      END;
    END;
  END;
END;


FUNCTION TGridLayoutAlgorithm.ControlRect(BoundsRect : TRect; Row, Column : INTEGER): TRect;
BEGIN
  Result := ControlRect(BoundsRect, Row, Column, 1, 1);
END;


FUNCTION TGridLayoutAlgorithm.ControlRect(BoundsRect : TRect; Row, Column, RowSpan, ColumnSpan : INTEGER): TRect;

  FUNCTION _IsAutoSize(Def : TGridLayoutDefinitionBase) : BOOLEAN;  INLINE;
  BEGIN
    Result := (Def <> NIL) AND (Def.FMode = gsmAutosize);
  END;

BEGIN
  // Clamp invalid indices to valid ones
  Column     := EnsureRange(Column, 0, Length(FColumns)-1);
  Row        := EnsureRange(Row, 0, Length(FRows)-1);
  ColumnSpan := EnsureRange(ColumnSpan, 1, Length(FColumns) - Column);
  RowSpan    := EnsureRange(RowSpan   , 1, Length(FRows   ) - Row);

  VAR ColumnGap := Max(0, Self.FParentLayout.FColumnGap);
  VAR RowGap    := Max(0, Self.FParentLayout.FRowGap);

  Result := Default(TRect);
  Result.Top  := Trunc(FRows[Row].MinY);
  Result.Left := Trunc(FColumns[Column].MinX);

  VAR Width : Single := 0.0;
  FOR VAR ColumnIndex := Column TO Column + ColumnSpan - 1 DO BEGIN
    Width := Width + FColumns[ColumnIndex].Width;
  END;

  VAR Height : Single := 0.0;
  FOR VAR RowIndex := Row TO Row + RowSpan - 1 DO BEGIN
    Height := Height + FRows[RowIndex].Height;
  END;

  // Adjust Gaps
  Width  := Width  + (ColumnSpan-1)*ColumnGap;
  Height := Height + (RowSpan-1)*RowGap;

  Result.Width  := Trunc(Width);
  Result.Height := Trunc(Height);


//  IF _IsAutoSize(FColumns[Column].Definition) THEN BEGIN
//    Result.Width := BoundsRect.Width;
//  END
//  ELSE BEGIN
//    Result.Width := Trunc(FColumns[Column].Width);
//  END;

//  IF _IsAutoSize(FRows[Row].Definition) THEN BEGIN
//    Result.Height := BoundsRect.Height;
//  END
//  ELSE BEGIN
//    Result.Height := Trunc(FRows[Row].Height);
//  END;
END;


FUNCTION TGridLayoutAlgorithm.ColumnWidthAtIndex(ColumnIndex: Integer): Single;
BEGIN
  VAR ColDef := FParentLayout.FColumnDef.Items[ColumnIndex] AS TGridLayoutColumnDefinition;

  IF ColumnVisiblity(ColumnIndex) = glvCollapsed THEN BEGIN
    Result := 0;
  END
  ELSE IF (ColDef.FMode = gsmAutosize) THEN BEGIN
    // find widest view in column
    VAR MaxWidth := 0.0;

    FOR VAR Item IN FParentLayout.FItems DO BEGIN
      WITH Item AS TGridLayoutItem DO BEGIN
        IF (Column = ColumnIndex) AND (Control <> NIL) THEN BEGIN
          MaxWidth := Max(Control.Width, MaxWidth);
        END;
      END;
    END;

    Result := MaxWidth;
  END
  ELSE BEGIN
    Result := ColDef.Width;
  END;
END;



FUNCTION TGridLayoutAlgorithm.RowHeightAtIndex(RowIndex: Integer): Single;
BEGIN
  VAR RowDef := FParentLayout.FRowDef.Items[RowIndex] AS TGridLayoutRowDefinition;

  IF RowVisiblity(RowIndex) = glvCollapsed THEN BEGIN
    Result := 0;
  END
  ELSE IF (RowDef.FMode = gsmAutosize) THEN BEGIN
    // find tallest view in row
    VAR MaxHeight := 0.0;

    FOR VAR Item IN FParentLayout.FItems DO BEGIN
      WITH Item AS TGridLayoutItem DO BEGIN
        IF (Row = RowIndex) AND (Control <> NIL) THEN BEGIN
          MaxHeight := Max(Control.Height, MaxHeight);
        END;
      END;
    END;

    Result := MaxHeight;
  END
  ELSE BEGIN
    Result := rowDef.Height;
  END;
END;


FUNCTION TGridLayoutAlgorithm.ColumnVisiblity(ColumnIndex: INTEGER): TGridVisibility;
BEGIN
  IF (csDesigning IN Self.FParentLayout.ComponentState) THEN BEGIN
    Result := glvVisible;
  END
  ELSE BEGIN
    Result := (FParentLayout.FColumnDef.Items[ColumnIndex] AS TGridLayoutColumnDefinition).Visibility;
  END;
END;


FUNCTION TGridLayoutAlgorithm.RowVisiblity(RowIndex: INTEGER): TGridVisibility;
BEGIN
  IF (csDesigning IN Self.FParentLayout.ComponentState) THEN BEGIN
    Result := glvVisible;
  END
  ELSE BEGIN
    Result := (FParentLayout.FRowDef.Items[RowIndex] AS TGridLayoutRowDefinition).Visibility;
  END;
END;

FUNCTION TGridLayoutAlgorithm.GetColumnCount: INTEGER;
BEGIN
  Result := Length(FColumns);
END;


FUNCTION TGridLayoutAlgorithm.GetRowCount: INTEGER;
BEGIN
  Result := Length(FRows);
END;


FUNCTION TGridLayoutAlgorithm.GetColumn(Index: INTEGER): TGridLayoutColumnTuple;
BEGIN
  Result := FColumns[Index];
END;


FUNCTION TGridLayoutAlgorithm.GetRow(Index: INTEGER): TGridLayoutRowTuple;
BEGIN
  Result := FRows[Index];
END;



END.
