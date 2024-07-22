program TestDrv;

uses
  Forms,
  uTestDrv in 'uTestDrv.pas' {Form1},
  LPTDrv in 'LPTDrv.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
