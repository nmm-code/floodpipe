program FloodPipe;

uses
  Vcl.Forms,
  Umain in 'Umain.pas' {fmain},
  Upipefield in 'Upipefield.pas' {fnew},
  Usettings in 'Usettings.pas' {fSetting},
  Upipe in 'Upipe.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfmain, fmain);
  Application.CreateForm(Tfnew, fnew);
  Application.CreateForm(TfSetting, fSetting);
  Application.Run;

end.
