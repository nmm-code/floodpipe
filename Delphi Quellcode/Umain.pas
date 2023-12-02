{ ------------------------------------------------------------------------------
  Hauptprogramm

  In dieser Unit ist das Hauptmenue und der wird beim starten der .exe
  immer zuerst aufgerufen und da kann man sich dann durch navigieren

  Verwendet: Usettings,Upipefield

  --> Neues Spiel    <->  Upipefield
  --> Laden          <->  Upipefield
  --> Einstellung    <->  Usettings
  --> Beenden

  Autor : Nima Mohammadimohammadi  alias ias105448
  ---------------------------------------------------------------------------- }
unit Umain;

interface

uses
  System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Controls, Vcl.Dialogs;

type
  TFmain = class(TForm)
    bNew: TButton;
    bLoad: TButton;
    bExit: TButton;
    bSettings: TButton;
    Image: TImage;
    procedure bNewClick(Sender: TObject);
    procedure bLoadClick(Sender: TObject);
    procedure bSettingsClick(Sender: TObject);
    procedure bExitClick(Sender: TObject);
  end;

var
  Fmain: TFmain;

implementation

{$R *.dfm}

{ Eingebundene Forms }
uses Upipefield, Usettings;


{ ----------------------------------------------
  * Das Spielfeld wird erstellt und der Modus wird eingestellt
  -----------------
  * Verwendet =
  *   u_pipefield
  ---------------------------------------------- }
procedure TFmain.bNewClick(Sender: TObject);
begin
  fnew.setMode(NEW_MODE);
  fnew.Show
end;

{ ----------------------------------------------
  * Das Einstellungs Fenster wird ge�ffnet
  -----------------
  * Verwendet =
  *   u_settings
  ---------------------------------------------- }
procedure TFmain.bSettingsClick(Sender: TObject);
begin
  fSetting.SetModi(NEW_MODE);
  fSetting.Show
end;

{ ----------------------------------------------
  * Das Spielfeld wird erstellt und der Modus wird eingestellt
  -----------------
  * Verwendet =
  *   u_pipedield
  ---------------------------------------------- }

procedure TFmain.bLoadClick(Sender: TObject);
begin
  fnew.setMode(LOAD_MODE);
  fnew.Show
end;

{ ----------------------------------------------
  * Form wird geschlossen wenn auf "Beenden" Button gedruckt wurde
  ---------------------------------------------- }
procedure TFmain.bExitClick(Sender: TObject);
begin
  close;
end;

end.
