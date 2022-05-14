UNIT GridLayout.Design;

INTERFACE

USES
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.UITypes,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Graphics,

  DesignEditors,
  DesignIntf,
  GridLayout;

// https://stackoverflow.com/questions/29443609/how-to-use-registerpropertyeditor
// https://stackoverflow.com/questions/35705898/how-to-select-sub-control-in-my-custom-control-in-design-time-in-delphi
// https://stackoverflow.com/questions/49947102/how-to-create-component-property-similar-rowspan-colspan-delphi-with-gridpanel
// https://edn.embarcadero.com/article/33448
// https://stackoverflow.com/questions/1997387/delphi-how-do-i-know-what-my-property-editor-is-editing

TYPE
  TGridLayoutEditor = class (TComponentEditor)
    FUNCTION  GetVerbCount: Integer;           OVERRIDE;
    FUNCTION  GetVerb(Index: Integer): string; OVERRIDE;
    PROCEDURE ExecuteVerb(Index: Integer);     OVERRIDE;
    PROCEDURE Edit;                            OVERRIDE;

    FUNCTION GridComponent : TGridLayout;
  END;

// PropertyEditor for TGridLayoutItem.Control
// This class only adds TControls to the designers's dropdown which are not
// already assigned to any item in the TGridLayout.
TYPE TGridLayoutItemControlPropertyEditor = CLASS(TComponentProperty)
  STRICT PRIVATE
    TYPE TItemControlValueFilter = CLASS
      PRIVATE
        FEditor : TGridLayoutItemControlPropertyEditor;
        FValues : TList<STRING>;

        PROCEDURE AddValue(CONST S : STRING);
        PROCEDURE GetValues(Proc : TGetStrProc);

      PUBLIC
        CONSTRUCTOR Create;
        DESTRUCTOR  Destroy; OVERRIDE;
    END;

  PRIVATE
    FValuesFilter : TItemControlValueFilter;

  PUBLIC
    CONSTRUCTOR Create(CONST ADesigner: IDesigner; APropCount: Integer); OVERRIDE;
    DESTRUCTOR  Destroy; OVERRIDE;

    FUNCTION GetAttributes: TPropertyAttributes; OVERRIDE;
    PROCEDURE GetValues(Proc: TGetStrProc); OVERRIDE;
END;

PROCEDURE Register;

IMPLEMENTATION

PROCEDURE Register;
BEGIN
  RegisterComponents     ('ProLogic', [TGridLayout]);
  RegisterComponentEditor(TGridLayout, TGridLayoutEditor);
  RegisterPropertyEditor (TypeInfo(TControl), TGridLayoutItem, 'Control', TGridLayoutItemControlPropertyEditor);
END;

{ TGridLayoutEditor }

FUNCTION TGridLayoutEditor.GridComponent: TGridLayout;
BEGIN
  Result := self.Component AS TGridLayout;
END;


FUNCTION TGridLayoutEditor.GetVerbCount: Integer;
BEGIN
  Result := 1;
END;


FUNCTION TGridLayoutEditor.GetVerb(Index: Integer): string;
BEGIN
  CASE Index OF
    0: Result := 'Test';
  END;
END;


PROCEDURE TGridLayoutEditor.ExecuteVerb(Index: Integer);
BEGIN
  INHERITED;

  CASE Index OF
    0: BEGIN
      ShowMessage('TEST');
    END;
  END;
END;


PROCEDURE TGridLayoutEditor.Edit;
BEGIN
  INHERITED;

END;


{ TGridLayoutItemControlPropertyEditor }

CONSTRUCTOR TGridLayoutItemControlPropertyEditor.Create(CONST ADesigner: IDesigner; APropCount: Integer);
BEGIN
  INHERITED;

  FValuesFilter := TItemControlValueFilter.Create;
  FValuesFilter.FEditor := self;
END;


DESTRUCTOR TGridLayoutItemControlPropertyEditor.Destroy;
BEGIN
  FreeAndNil(FValuesFilter);

  INHERITED;
END;


FUNCTION TGridLayoutItemControlPropertyEditor.GetAttributes: TPropertyAttributes;
BEGIN
  Result := INHERITED GetAttributes;
  // We do not support multiselect
  Exclude(Result, paMultiSelect);
END;


PROCEDURE TGridLayoutItemControlPropertyEditor.GetValues(Proc: TGetStrProc);
BEGIN
  FValuesFilter.FValues.Clear;
  INHERITED GetValues(FValuesFilter.AddValue);
  FValuesFilter.GetValues(Proc);
END;

{ TGridLayoutItemControlPropertyEditor.TItemControlValueFilter }

CONSTRUCTOR TGridLayoutItemControlPropertyEditor.TItemControlValueFilter.Create;
BEGIN
  FValues := TList<STRING>.Create;
END;


DESTRUCTOR TGridLayoutItemControlPropertyEditor.TItemControlValueFilter.Destroy;
BEGIN
  FreeAndNil(FValues);
  INHERITED;
END;


PROCEDURE TGridLayoutItemControlPropertyEditor.TItemControlValueFilter.AddValue(CONST S: STRING);
BEGIN
  VAR EditedItem := FEditor.GetComponent(0) AS TGridLayoutItem; // no multiselect support
  VAR Comp := FEditor.Designer.GetComponent(S);

  VAR ControlAlreadyAssigned := FALSE;
  FOR VAR I := 0 TO EditedItem.OwningLayout.Items.Count-1 DO BEGIN
    VAR OtherItem := EditedItem.OwningLayout.Items.Items[I] AS TGridLayoutItem;

    IF (OtherItem <> EditedItem) AND (OtherItem.Control = Comp) THEN BEGIN
      ControlAlreadyAssigned := TRUE;
      BREAK;
    END;
  END;

  IF NOT ControlAlreadyAssigned THEN BEGIN
    FValues.Add(S);
  END;
END;


PROCEDURE TGridLayoutItemControlPropertyEditor.TItemControlValueFilter.GetValues(Proc: TGetStrProc);
BEGIN
  IF NOT Assigned(Proc) THEN EXIT;

  FOR VAR Value IN FValues DO BEGIN
    Proc(Value);
  END;
END;

END.
