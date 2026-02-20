program ProtectingTwoObjects;

uses
  System.SysUtils,
  Vcl.Forms,
  MainForm in 'MainForm.pas' {frmMain},
  Test in 'Test.pas',
  ExemplosTryFinally in 'ExemplosTryFinally.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
