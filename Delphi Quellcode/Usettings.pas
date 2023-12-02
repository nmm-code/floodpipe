{ ------------------------------------------------------------------------------
  Einstellungs Fenster

  In diesen Form koennen folgende Dinge eingestellt werden ;
  * Hohe,
  * Breite,
  * Animationsgeschwindigkeit,
  * Ueberlaufmodus,
  * Anzahl der Steine auf den Feld,

  Diese Form erzeugt noch ausserdem eine "config.dat" Datei die eingestellte
  Optionen speichert. Damit der Benutzer nicht immer von neu die Einstellung
  veraendern muss.

  Autor : Nima Mohammadimohammadi  alias ias105448
  ---------------------------------------------------------------------------- }
unit Usettings;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

{ Constants }
const
  NEW_MODE = 0;
  LOAD_MODE = 1;
  EDITOR_MODE = 2;

type
  TfSetting = class(TForm)
    tColumn: TTrackBar;
    tRow: TTrackBar;
    bTask: TButton;
    tStone: TTrackBar;
    tAnimation: TTrackBar;
    rgOverflow: TRadioGroup;
    lTrackbarColumn: TLabel;
    lTrackbarRow: TLabel;
    lTrackbarStone: TLabel;
    lTrackbarAnimation: TLabel;
    lColumn: TLabel;
    lRow: TLabel;
    lStone: TLabel;
    lAnimation: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure save2File;
  public
    function getColumn: byte;
    function getRow: byte;
    function getStoneNum: byte;
    function getAnimation: byte;
    function getOverflow: boolean;
    procedure setModi(modi: byte);
  end;

var
  fSetting: TfSetting;

implementation

{$R *.dfm}

{ -------------------------------------------------
  * Das Einstellungs Fenster wird eingestellt
  * Beim LadenClick werden einige Komponenten ausgeblendet
  -----------------
  * Parameter =
  * in: Modi:byte
  -----------------
  * Verwendet =
  * lColumn,tColumn;
  * lTrackbarRow;
  ------
  * lRow, tRow;
  * LTrackbarZeilen
  ------
  * lStone,tStone;
  * lTrackbarStone;
  ------
  * rgOverflow;
  ---------------------------------------------- }
procedure TfSetting.setModi(modi: byte);
begin
  if modi = LOAD_MODE then
  begin
    lColumn.Visible := false;
    tColumn.Visible := false;
    lTrackbarColumn.Visible := false;
    lRow.Visible := false;
    tRow.Visible := false;
    lTrackbarRow.Visible := false;
    lStone.Visible := false;
    tStone.Visible := false;
    lTrackbarStone.Visible := false;
    rgOverflow.Visible := false;
  end;
end;

{ ----------------------------------------------
  * Die Funktion gibt die Position der SpaltenTracksbar
  * also den Wert der eingestellt wurde
  -----------------
  * return = (tColumn.Position)
  -----------------
  * Verwendet =
  * tColumn:TTrackbar;
  ---------------------------------------------- }
function TfSetting.getColumn: byte;
begin
  getColumn := tColumn.Position;
end;

{ ----------------------------------------------
  * Die Funktion gibt die Position der ZeilenTracksbars
  * also den Wert der eingestellt wurde
  -----------------
  * return = (tRow.Position)
  -----------------
  * Verwendet =
  * tRow:TTrackbar;
  ---------------------------------------------- }
function TfSetting.getRow: byte;
begin
  getRow := tRow.Position;
end;

{ ----------------------------------------------
  * Die Funcktion berechnet Die Anzahl der Steine die platziert werden muessen
  -----------------
  * Beispiel 10% : return = (Zeile * Spalte) * 10%
  -----------------
  * Verwendet =
  * tRow:TTrackbar;
  * tColumn:TTrackbar;
  * tStone:TTrackbar;
  ---------------------------------------------- }
function TfSetting.getStoneNum: byte;
begin
  getStoneNum := round((tRow.Position * tColumn.Position) *
    (tStone.Position / 100));
end;

{ ----------------------------------------------
  * Die Funktion gibt die Position der AnimationTracksbar
  * also den Wert der eingestellt wurde
  -----------------
  * return = (TAnimation.Position)
  -----------------
  * Verwendet =
  * tAnimation:TTrackbar;
  ---------------------------------------------- }
function TfSetting.getAnimation: byte;
begin
  getAnimation := tAnimation.Position;
end;

{ ----------------------------------------------
  * Die Funktion gibt zurueck ob der Ueberlaufmodus Aktiviert wurde
  -----------------
  * return = true / false
  -----------------
  * Verwendet =
  * rgOverflow:TRadioGroup;
  ---------------------------------------------- }
function TfSetting.getOverflow: boolean;
begin
  getOverflow := (rgOverflow.ItemIndex = 0);
end;

{ ----------------------------------------------
  * Die Procedur schreibt die Einstellungen in eine Datei
  -----------------
  * Verwendet =
  * TRow:TTrackbar;
  * TColumn:TTrackbar;
  * TStone:TTrackbar;
  * TAnimation:TTrackbar;
  * rgOverflow:TRadioGroup;
  ---------------------------------------------- }
procedure TfSetting.save2File;
var
  f: file;
begin
  AssignFile(f, 'config.dat');
  rewrite(f, 1);
  blockwrite(f, tColumn.Position, sizeof(byte));
  blockwrite(f, tRow.Position, sizeof(byte));
  blockwrite(f, tStone.Position, sizeof(byte));
  blockwrite(f, tAnimation.Position, sizeof(byte));
  blockwrite(f, rgOverflow.ItemIndex, sizeof(byte));
  closefile(f);
end;

{ ----------------------------------------------
  * Die Procedur schreibt die Einstellungen in eine Datei
  -----------------
  * Verwendet =
  * TRow,LRow;
  * LTrackbarRow:TLabel;
  * TColumn,LColumn;
  * LTrackbarColumn:TLabel;
  * TStone,LStone;
  * LTrackbarStone:TLabel;
  * TAnimation:TTrackbar;
  * rgOverflow:TRadioGroup;
  * procedure Save2File;
  ---------------------------------------------- }
procedure TfSetting.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  lColumn.Visible := true;
  tColumn.Visible := true;
  lTrackbarColumn.Visible := true;
  lRow.Visible := true;
  tRow.Visible := true;
  lTrackbarRow.Visible := true;
  lStone.Visible := true;
  tStone.Visible := true;
  lTrackbarStone.Visible := true;
  rgOverflow.Visible := true;
  save2File;
end;

{ ----------------------------------------------
  * Die Procedur liest die Einstellungen aus eine config Datei
  -----------------
  * Verwendet =
  * TRow:TTrackbar;
  * TColumn:TTrackbar;
  * TStone:TTrackbar;
  * TAnimation:TTrackbar;
  * rgOverflow:TRadioGroup;
  * procedure Save2File;
  ---------------------------------------------- }
procedure TfSetting.FormCreate(Sender: TObject);
var
  f: file;
  i: byte;
begin
  AssignFile(f, 'config.dat');
  if FileExists('config.dat') then
  begin
    reset(f, 1);
    blockread(f, i, sizeof(byte));
    tColumn.Position := i;
    blockread(f, i, sizeof(byte));
    tRow.Position := i;
    blockread(f, i, sizeof(byte));
    tStone.Position := i;
    blockread(f, i, sizeof(byte));
    tAnimation.Position := i;
    blockread(f, i, sizeof(byte));
    rgOverflow.ItemIndex := i;
    closefile(f);
  end
  else
    save2File;
end;

end.
