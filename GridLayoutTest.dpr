program GridLayoutTest;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
