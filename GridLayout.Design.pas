UNIT GridLayout.Design;

INTERFACE

USES
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Vcl.Dialogs,
  Vcl.Graphics,

  DesignEditors,
  DesignIntf,
  GridLayout;

TYPE
  TGridLayoutEditor = class (TComponentEditor)
    FUNCTION  GetVerbCount: Integer;           OVERRIDE;
    FUNCTION  GetVerb(Index: Integer): string; OVERRIDE;
    PROCEDURE ExecuteVerb(Index: Integer);     OVERRIDE;
    PROCEDURE Edit;                            OVERRIDE;

    FUNCTION GridComponent : TGridLayout;
  END;


PROCEDURE Register;

IMPLEMENTATION

PROCEDURE Register;
BEGIN
  RegisterComponentEditor (TGridLayout, TGridLayoutEditor);
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
      GridComponent.Color := clRed;



      ShowMessage('TEST');
    END;
  END;
END;


PROCEDURE TGridLayoutEditor.Edit;
BEGIN
  INHERITED;

END;


END.
