{ ------------------------------------------------------------------------------
  * In dieser Form Unit ist das Feld wodrauf man spielt und editiert
  ----
  * es kann zusaetzlich als eine Datei abgespeichert werden , wieder verwendet und aufgerufen werden
  ----
  * die jeweiligen Einstellung werden in einer seperaten Form gemacht fsettings
  -----------------------------------
  * ps : Rohr Bilder sind in der ImageList aber können im Ordner ebenfalls angeschaut werden
  ------------------------------
  Verwendet =
  Upipe,
  Usettings;

  Autor : Nima Mohammadimohammadi  alias ias105448
  ---------------------------------------------------------------------------- }
unit Upipefield;

interface

uses
  Windows, System.SysUtils, System.Classes, System.ImageList, System.UITypes,
  System.Types, Vcl.Graphics, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  {Eigene Units}
  Upipe;

type
  Tfnew = class(TForm)
    ilImageList: TImageList;
    lTime: TLabel;
    sbSave: TSpeedButton;
    bSetting: TButton;
    bEditor: TButton;
    procedure bSettingClick(Sender: TObject);
    procedure bEditorClick(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { attributes }
    cell, min, clicks: word;
    animationSpeed, mode, stoneNum: byte;
    fieldHeight, sec, fieldWidth, source_x, source_y: byte;
    overflow, pipeChange, cancel, finished: boolean;
    fillResult: string;
    { type attributes }
    field: TField;
    { object attributes }
    editorPipe: array [0 .. 5] of TImage;
    newLoad, editorMode: TButton;
    pipeReplaceSelect: TShape;
    myTimer, tempTimer, animationTimer: Ttimer;
    { methods }
    procedure rotateBitmap(var bmp: TBitmap);
    procedure paintOnTime(Sender: TObject);
    procedure fillPipe(Sender: TObject);
    procedure setTimerLabel(Sender: TObject);
    procedure addTimer(Sender: TObject; check: boolean);
    procedure addAnimationTimer(Sender: TObject);
    procedure drawField(Sender: TObject; check: boolean);
    procedure newClick(Sender: TObject);
    procedure loadClick(Sender: TObject);
    procedure file2Field(Filename: string);
    procedure fieldReload(Sender: TObject);
    procedure closeForm(Sender: TObject);
    procedure editorReload(Sender: TObject);
    procedure changeEditorMode(Sender: TObject);
    procedure moveShape(Sender: TObject);
    procedure fillRekursiv(s_x, s_y: byte);
    procedure resizeTimerLabel(Sender: TObject);
    procedure field2file(Filename: string);
  public
    procedure setMode(m: byte);
  end;

var
  fnew: Tfnew;

implementation

{$R *.dfm}

uses
  Usettings;

const
  TOP_GAP = 40;
  BORDER_STYLE_GAP = 40;

  { -------------------------------------------------
    * Dreht ein Bitmap um 90°
    -----------------
    * Parameter :
    * ref in : Bild
    * ref out : um 90° gedrehtes Bild
    ---------------------------------------------- }
procedure Tfnew.rotateBitmap(var bmp: TBitmap);
var
  tmpBmp: TBitmap;
  points: array [0 .. 2] of TPoint;
begin
  tmpBmp := TBitmap.Create;
  try
    tmpBmp.Assign(bmp);
    bmp.width := tmpBmp.height;
    bmp.height := tmpBmp.width;
    points[0] := Point(tmpBmp.height, 0);
    points[1] := Point(tmpBmp.height, tmpBmp.width);
    points[2] := Point(0, 0);
    if PlgBlt(bmp.Canvas.Handle, points, tmpBmp.Canvas.Handle, 0, 0,
      tmpBmp.width, tmpBmp.height, 0, 0, 0) then;

  finally
    tmpBmp.Free;
  end;
end;

{ -------------------------------------------------
  * Setzt den Modus fuer FormShow
  -----------------
  Unit fsettings:
  Modus =
  NEW_MODE = 0;
  LOAD_MODE = 1;
  EDITOR_MODE = 2;
  -----------------
  Parameter :
  in : m = uebergebener Modus
  -----------------
  Verwendet :
  private:
  mode;
  ---------------------------------------------- }
procedure Tfnew.setMode(m: byte);
begin
  mode := m;
end;

{ -------------------------------------------------
  * Die Form wird geschlossen und der Timer wird freigegeben

  * Wird als OnTimer Event zugewiesen ,
  * wenn beim laden keine Datei ausgewaehlt wurde
  -----------------
  Verwendet:
  object:
  myTimer;
  ---------------------------------------------- }
procedure Tfnew.closeForm(Sender: TObject);
begin
  myTimer.Free;
  close;
end;

{ -------------------------------------------------
  * Das Feld wird neu gezeichnet und der Timer wird freigegeben
  * Wird als OnTimer Event zugewiesen um nach den oeffnen direkt zu resizen
  -----------------
  Verwendet:
  object:
  myTimer;
  method:
  FormResize(...);
  ---------------------------------------------- }
procedure Tfnew.resizeTimerLabel(Sender: TObject);
begin
  myTimer.Free;
  FormResize(Sender);
end;

{ ---------------------------------------------------
  * Diese Procedur wird als OnTimer Event aufgerufen
  * diese zeichnet jedes Rohr was gefuellt wurde
  -----------------
  * Diese Information bekommt er in ein String "fillResult" und diese arbeitet
  * er durch bis der String leer ist
  -----------------
  Verwendet:
  const:
  TOP_GAP
  private:
  fillResult;
  field:TField;
  object:
  ilImageList;
  animationTimer;
  --------------------------------------------------- }
procedure Tfnew.paintOnTime(Sender: TObject);
var
  bmp: TBitmap;
  X, Y, r: byte;
begin
  if fillResult <> '' then
  begin
    try
      bmp := TBitmap.Create;

      X := strtoint(copy(fillResult, 2, pos(' ', fillResult) - 2));
      delete(fillResult, 1, pos(' ', fillResult));

      Y := strtoint(copy(fillResult, 1, pos('|', fillResult) - 1));
      delete(fillResult, 1, pos('|', fillResult));

      if ilImageList.GetBitmap(field[X, Y].bitMapIdx, bmp) then
      begin
        for r := 1 to field[X, Y].rotNum do
          rotateBitmap(bmp);

        Self.Canvas.StretchDraw(Rect(0 + X * cell, 0 + Y * cell + TOP_GAP,
          cell + X * cell, cell + Y * cell + TOP_GAP), bmp);
      end;
    finally
      bmp.Free;
    end;
  end
  else
    animationTimer.Enabled := false;
end;

{ ----------------------------------------------------
  * Startet den Animations Timer und stellt das OnTimer Event auf paintOnTime
  --------------------------
  Verwendet:
  private:
  animationSpeed;
  object:
  animationTimer;
  ----------------------------------------------------- }
procedure Tfnew.addAnimationTimer(Sender: TObject);
begin
  animationTimer := Ttimer.Create(Self);
  animationTimer.Interval := animationSpeed;
  animationTimer.Enabled := true;
  animationTimer.OnTimer := paintOnTime;
end;

{ ----------------------------------------------------
  * Startet bei der Quelle und geht in allen richtung falls ein Rohr verbunden ist
  * Falls ein Rohr gefunden wurde schreibt er diese in fillResult rein un die Quelle wird neu definiert
  * und die rekursion geht von vorne wieder
  -------------------------
  Verwendet:
  private:
  field;
  fillResult;
  ----------------------------------------------------- }
procedure Tfnew.fillRekursiv(s_x, s_y: byte);
{ ----------------------------------------------------
  * In dieser Funktion werden paar If Abfragen gemacht damit man in die Rekursion gehen darf#
  ------------------------
  * die Quelle darf nicht an den Rand sein
  * das Feld muss in der uebergebene Richtung verbunden sein
  * und die neue Quelle darf nicht gefuellt sein oder anders formuliert darf nicht doppelt in FillResult stehen
  -------------------------
  Verwendet:
  private:
  field;
  fieldHeight:
  fieldWidth;
  fillResult;
  ----------------------------------------------------- }
  function isConnect(source_x, source_y: byte; direction: Tindex): boolean;
  begin
    isConnect := false;
    if (source_x < fieldWidth) and (source_y < fieldHeight) then
      if field[source_x, source_y].direction[direction] then
        if not field[source_x, source_y].filled then
          isConnect := true;
  end;

begin
  field[s_x, s_y].filled := true;

  if field[s_x, s_y].direction[N] then // Die richtung muss true sein
  begin
    if (s_y <> 0) and isConnect(s_x, s_y - 1, S) then
    // Die If Abfragen siehe Funktion isConnect
    begin
      // wird in die Funktion geschrieben
      fillResult := (fillResult + '|' + inttostr(s_x) + ' ' +
        inttostr(s_y - 1) + '|');
      // geht in die Rekursion mit der neuen Quellen
      fillRekursiv(s_x, s_y - 1);
    end;
    if overflow and (s_y = 0) then // Ueberlaufmodus aktiv und am Rand
      if field[s_x, fieldHeight - 1].direction[S] and
      // das andere Rohr muss die selbe richtung haben
        not field[s_x, fieldHeight - 1].filled then
      // und darf nicht in Fillresult geschrieben sein
      begin
        fillResult := (fillResult + '|' + inttostr(s_x) + ' ' +
          inttostr(fieldHeight - 1) + '|');
        fillRekursiv(s_x, fieldHeight - 1);
      end;
  end;
  if field[s_x, s_y].direction[O] then // Die richtung muss true sein
  begin
    if (s_x <> fieldWidth) and isConnect(s_x + 1, s_y, W) then
    // Die If Abfragen siehe Funktion isConnect
    begin
      fillResult := (fillResult + '|' + inttostr(s_x + 1) + ' ' +
        inttostr(s_y) + '|');
      // geht in die Rekursion mit der neuen Quellen
      fillRekursiv(s_x + 1, s_y);
    end;
    if overflow and (s_x = fieldWidth - 1) then
      // Ueberlaufmodus aktiv und am Rand
      if field[0, s_y].direction[W] and
      // das andere Rohr muss die selbe richtung haben
        not field[0, s_y].filled then
      // und darf nicht in Fillresult geschrieben sein
      begin
        fillResult := (fillResult + '|' + inttostr(0) + ' ' +
          inttostr(s_y) + '|');
        fillRekursiv(0, s_y);
      end;
  end;
  if field[s_x, s_y].direction[S] then // Die richtung muss true sein
  begin
    if (s_y <> fieldHeight) and isConnect(s_x, s_y + 1, N) then
    // Die If Abfragen siehe Funktion isConnect
    begin
      fillResult := (fillResult + '|' + inttostr(s_x) + ' ' +
        inttostr(s_y + 1) + '|');
      // geht in die Rekursion mit der neuen Quellen
      fillRekursiv(s_x, s_y + 1);
    end;
    if overflow and (s_y = fieldHeight - 1) then
      // Ueberlaufmodus aktiv und am Rand
      if field[s_x, 0].direction[N]
      // das andere Rohr muss die selbe richtung haben
        and not field[s_x, 0].filled then
      // und darf nicht in Fillresult geschrieben sein
      begin
        fillResult := (fillResult + '|' + inttostr(s_x) + ' ' +
          inttostr(0) + '|');
        fillRekursiv(s_x, 0);
      end;
  end;
  if field[s_x, s_y].direction[W] then // Die richtung muss true sein
  begin
    if (s_x <> 0) and (isConnect(s_x - 1, s_y, O)) then
    // Die If Abfragen siehe Funktion isConnect
    begin
      fillResult := (fillResult + '|' + inttostr(s_x - 1) + ' ' +
        inttostr(s_y) + '|');
      // geht in die Rekursion mit der neuen Quellen
      fillRekursiv(s_x - 1, s_y);
    end;
    if overflow and (s_x = 0) then // Ueberlaufmodus aktiv und am Rand
      if field[fieldWidth - 1, s_y].direction[O] and
      // das andere Rohr muss die selbe richtung haben
        not field[fieldWidth - 1, s_y].filled then
      // und darf nicht in Fillresult geschrieben sein
      begin
        fillResult := (fillResult + '|' + inttostr(fieldWidth - 1) + ' ' +
          inttostr(s_y) + '|');
        fillRekursiv(fieldWidth - 1, s_y);
      end;
  end;
end;

{ ------------------------------------------------------------------------------------
  * Wird aufgerufen wenn das Feld erstellt wurde oder ein Rohr gedreht wurde
  -----------------------------------
  Verwendet:
  const:
  TOP_GAP
  private:
  field;
  fillResult;
  fieldwidth;
  fieldheight;
  object:
  ilImageList;
  method:
  fillRekursiv(...);
  addAnimationTimer(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.fillPipe(Sender: TObject);
var
  i, j, k: byte;
  bmp: TBitmap;
begin
  fillResult := '';
  if (source_x <> 255) and (source_y <> 255) then
    fillRekursiv(source_x, source_y);

  // Bereits gefuellte Bilder und die in FillResult sind werden geloescht im string
  // damit sie nicht nochmal gefuellt werden Redudanz vermeidung
  if fillResult <> '' then
  begin
    for i := 0 to fieldHeight - 1 do
      for j := 0 to fieldWidth - 1 do
        if (field[j, i].filled) and (field[j, i].bitMapIdx > 4) then
          delete(fillResult, pos('|' + inttostr(j) + ' ' + inttostr(i) + '|',
            fillResult), length('|' + inttostr(j) + ' ' + inttostr(i) + '|'));
    // Der Timer wird gestartet damit die Bilder angemalt werden
    addAnimationTimer(Sender);
  end;
  // Alle Bitmap Zahl wird eingestellt und falls er nicht mehr gefuellt ist wird er leer gemacht
  // filled wird wieder false eingestellt fuer die naechste rekursion
  for i := 0 to fieldHeight - 1 do
    for j := 0 to fieldWidth - 1 do
      if field[j, i].filled and (field[j, i].bitMapIdx <= 4) then
      begin
        field[j, i].bitMapIdx := field[j, i].bitMapIdx + 4;
        field[j, i].filled := false;
      end
      else if not field[j, i].filled and (field[j, i].bitMapIdx > 4) then
      begin
        bmp := TBitmap.Create;
        try
          field[j, i].bitMapIdx := field[j, i].bitMapIdx - 4;
          if ilImageList.GetBitmap(field[j, i].bitMapIdx, bmp) then
          begin
            for k := 1 to field[j, i].rotNum do
              rotateBitmap(bmp);

            Self.Canvas.StretchDraw(Rect(0 + j * cell, 0 + i * cell + TOP_GAP,
              cell + j * cell, cell + i * cell + TOP_GAP), bmp);
          end;
        finally
          bmp.Free;
        end;
      end
      else if field[j, i].filled then
        field[j, i].filled := false;
end;

{ ------------------------------------------------------------------------------------
  * Wird als OnTimer Event aufgerufen
  * aktuellisiert den Label der die zeit darstellt
  -----------------------------------
  Verwendet:
  private:
  sec;
  min;
  finished;
  object:
  tempTimer;
  lTime;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.setTimerLabel(Sender: TObject);
begin
  if not finished and (tempTimer.Enabled) then
    inc(sec);

  // 60 sec = 1 min
  if sec = 60 then
  begin
    sec := 0;
    inc(min);
  end;

  if (min > 0) then
    lTime.Caption := inttostr(min) + 'm:' + inttostr(sec) + 's'
  else
    lTime.Caption := inttostr(sec) + 's';

end;

{ ------------------------------------------------------------------------------------
  * Wird in FormShow aufgerufen und STellt den Timer ein
  * falls check = true dann stellt er die Zeit auf 0 und Label wird geleert
  * zbs. bei Neuclick aber nicht bei LadenClick weil die Uebergebene Zeit verworfen wird
  -----------------------------------
  Verwendet:
  private:
  sec;
  min;
  finished;
  object:
  tempTimer;
  lTime;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.addTimer(Sender: TObject; check: boolean);
begin
  if check then
  begin
    sec := 0;
    min := 0;
    lTime.Caption := '';
  end;

  tempTimer := Ttimer.Create(Self);
  tempTimer.Enabled := false;
  tempTimer.Interval := 1000;
  tempTimer.OnTimer := setTimerLabel;
end;

{ ------------------------------------------------------------------------------------
  * Wird als OnClick Event zugewiesen
  * ersetzt alle Rohre zu ein Stein und die Richtung werden auf false gesetzt
  -----------------------------------
  Verwendet:
  private:
  field;
  fieldwidth;
  fieldheight;
  source_x,source_y;
  method:
  drawField(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.editorReload(Sender: TObject);
var
  j, i: byte;
begin
  if MessageDlg('Sicher?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
  begin
    for j := 0 to fieldHeight - 1 do
      for i := 0 to fieldWidth - 1 do
      begin
        field[i, j].bitMapIdx := 0;
        field[i, j].rotNum := 0;
        field[i, j].direction[N] := false;
        field[i, j].direction[O] := false;
        field[i, j].direction[S] := false;
        field[i, j].direction[W] := false;
      end;
    drawField(Sender, false);
    source_x := 255;
    source_y := 255;
  end;
end;

{ ------------------------------------------------------------------------------------
  * Bewegt das Shape wenn ein Editor Rohr angeclickt wurde im Editor Modus
  * das Shape beschreibt welches Rohr aktiv ist
  * Bei den Modus: "Ersetzen" wird das Aktive Rohr genommen und
  * bei ein click auf das Feld wuerde er das angeclickte Rohr erstzen
  -----------------------------------
  Verwendet:
  private:
  object:
  pipeEditorMode;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.moveShape(Sender: TObject);
var
  p: TPoint;
begin
  p := Self.ScreenToClient(Mouse.CursorPos);
  pipeReplaceSelect.Left := p.X div cell * cell + 5;
end;

{ ------------------------------------------------------------------------------------
  * Wird als OnClick Event zugewiesen und es veraendert den Modus d
  * Modus:
  * Pipe change = ersetzt die Rohre bei ein Click
  * Pipe rot = rotiert das aktuelle Bild um 90°
  -----------------------------------
  Verwendet:
  private:
  pipeChange;
  object:
  editorMode;
  pipeEditorMode;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.changeEditorMode(Sender: TObject);
begin
  if editorMode.Caption = 'Aktiv = Rohre drehen' then
  begin
    editorMode.Caption := 'Aktiv = Rohre ersetzen';
    pipeChange := true;
    pipeReplaceSelect.Visible := true;
    pipeReplaceSelect.Parent := Self;
    pipeReplaceSelect.Brush.Color := clRed;
  end
  else
  begin
    editorMode.Caption := 'Aktiv = Rohre drehen';
    pipeChange := false;
    pipeReplaceSelect.Visible := false;
  end;
end;

{ ------------------------------------------------------------------------------------
  * Wird als OnClick Event zugewiesen und es veraendert den Modus d
  * Modus:
  * Pipe change = ersetzt die Rohre bei ein Click
  * Pipe rot = rotiert das aktuelle Bild um 90°
  -----------------------------------
  Verwendet:
  const:
  TOP_GAP
  private:
  field;
  fieldwidth;
  fieldheight;
  object:
  ilImagelist;
  method:
  rotateBitmap(...);
  Unit Upipe:
  NOSWrot(...);
  NOSWset(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.drawField(Sender: TObject; check: boolean);
var
  i: byte;
  a, b: byte;
  bmp: TBitmap;
begin
  for b := 0 to fieldHeight - 1 do
    for a := 0 to fieldWidth - 1 do
      try
        bmp := TBitmap.Create;
        if ilImageList.GetBitmap(field[a, b].bitMapIdx, bmp) then
        begin
          if check then
            NOSWset(field[a, b]);

          for i := 1 to field[a, b].rotNum do
          begin
            if check then
              NOSWrot(field[a, b]);
            rotateBitmap(bmp);
          end;

          Self.Canvas.StretchDraw(Rect(a * cell, b * cell + TOP_GAP,
            cell + a * cell, cell + b * cell + TOP_GAP), bmp);
        end;
      finally
        bmp.Free;
      end;

end;

{ ------------------------------------------------------------------------------------
  * Verwendet um das Feld neuzuladen und setzt die attribute auf standard
  ----------------------------------------------------------------
  Verwendet:
  Unit:
  fsettings:
  const:
  NEW_MODE
  private:
  mode;
  object:
  tempTimer;
  lTime;
  method:
  FormShow(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.fieldReload(Sender: TObject);
begin
  mode := NEW_MODE;
  tempTimer.Enabled := false;
  lTime.Caption := '';

  FormShow(Sender);
end;

{ ------------------------------------------------------------------------------------
  * Wird aufgerufen wenn der "Start" Button gedrueckt wurde und erstellt das Feld mit den Rohren
  --------------------------------------
  Verwendet:
  Unit:
  fSetting
  getrow,getColumn,getStoneNum, getOverflow, getAnimation;
  private:
  field;
  fieldHeight,fieldWidth;
  stoneNum,overflow;
  animationSpeed;
  fillResult;
  object:
  animationTimer;
  method:
  placePipe(...);
  fillRekursiv(...);
  allConnection(...);
  rotePipe(...);
  fillPipe(...);
  addTimer(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.newClick(Sender: TObject);
begin
  fieldHeight := fSetting.getrow;
  fieldWidth := fSetting.getColumn;
  stoneNum := fSetting.getStoneNum;
  overflow := fSetting.getOverflow;
  animationSpeed := fSetting.getAnimation;
  // Feld wird in der Repeat schleife erstellt
  repeat
    setlength(field, 0, 0);
    setlength(field, fieldWidth, fieldHeight); // Länge wird definiert
    field := placePipe(placeStone(field, stoneNum), overflow);
    // Steine werden platziert
    addSource(field, source_x, source_y); // die Quelle wird platziert
    fillResult := '';
    fillRekursiv(source_x, source_y); // rekursion wird durchgeführt
  until allConnect(fieldWidth, fieldHeight, stoneNum, fillResult);
  // Allconnect zählt die felder in die angemalt wurden
  rotatePipe(field); // rotiert alle rohr im Feld
  fillPipe(Sender); // Füllt die Rohre auf

  animationTimer := Ttimer.Create(Self);
  animationTimer.Enabled := false;
  addTimer(Sender, true); // allgemeine Spielzeit timer wird gestartet
end;

{ ------------------------------------------------------------------------------------
  * Verwandelt eine Datei in das Feld um
  --------------------------------------
  Verwendet:
  private:
  field;
  fieldHeight,fieldWidth;
  stoneNum,overflow;
  animationSpeed;
  source_x,source_y;
  sec,min,clicks;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.file2Field(Filename: string);
var
  f: file;
  i, j: byte;
begin
  AssignFile(f, Filename);
  reset(f, 1);
  blockread(f, fieldWidth, sizeof(byte));
  blockread(f, fieldHeight, sizeof(byte));
  setlength(field, fieldWidth, fieldHeight);
  blockread(f, source_x, sizeof(byte));
  blockread(f, source_y, sizeof(byte));
  blockread(f, sec, sizeof(byte));
  blockread(f, min, sizeof(byte));
  blockread(f, clicks, sizeof(word));
  for i := 0 to fieldHeight - 1 do
    for j := 0 to fieldWidth - 1 do
    begin
      blockread(f, field[j, i].bitMapIdx, sizeof(byte));
      blockread(f, field[j, i].rotNum, sizeof(byte));
    end;
  closefile(f);
end;

{ ------------------------------------------------------------------------------------
  * Wird aufgerufen wenn der "Laden" Button gedrueckt wurde
  * Eine Auswahl der Datein auf dem Pc
  * Umwandlung in file2Field eine Datein in dem Feld
  ---------------------------------------------
  Verwendet:
  Unit:
  fsetting
  getAnimation;
  getOverflow;
  private:
  field;
  animationSpeed;
  overflow;
  cancel;
  object:
  animationTimer;
  animationTimer;
  tempTimer;
  myTimer;
  method:
  file2Field(...);
  drawField(...);
  addTimer(...);
  closeForm(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.loadClick(Sender: TObject);
var
  Opendialog: TOpendialog;
begin
  Opendialog := TOpendialog.Create(Self);
  Opendialog.Filter := 'Dat Datei|*.dat|';
  Opendialog.DefaultExt := 'dat';
  if Opendialog.Execute then
  begin
    setlength(field, 0, 0);
    file2Field(Opendialog.Filename); // das feld wird durch die datei geladen
    animationSpeed := fSetting.getAnimation;
    overflow := fSetting.getOverflow;
    drawField(Sender, true); // Feld wird gezeichnet
    cancel := false;
    animationTimer := Ttimer.Create(Self);
    animationTimer.Enabled := false;
    addTimer(Sender, false);
    tempTimer.Enabled := false;
  end
  else
  begin
    cancel := true;
    myTimer := Ttimer.Create(Self);
    // falls abgebrochen wird die Form geschlossen
    myTimer.Interval := 1;
    myTimer.Enabled := true;
    myTimer.OnTimer := closeForm;
  end;
  Opendialog.Free;
end;

{ -------------------------------------------------------
  * Speichert das aktuelle Feld in ein Datei
  -----------------------
  Verwendet:
  private:
  field;
  fieldHeight,fieldWidth;
  stoneNum,overflow;
  animationSpeed;
  source_x,source_y;
  sec,min,clicks;
  mode;
  ---------------------------------------------------------- }
procedure Tfnew.field2file(Filename: string);
var
  f: file;
  i, j: byte;
begin
  AssignFile(f, Filename);
  rewrite(f, 1);
  blockwrite(f, fieldWidth, sizeof(byte));
  blockwrite(f, fieldHeight, sizeof(byte));
  blockwrite(f, source_x, sizeof(byte));
  blockwrite(f, source_y, sizeof(byte));
  if mode = EDITOR_MODE then
  begin
    min := 0;
    sec := 0;
  end;
  blockwrite(f, sec, sizeof(byte));
  blockwrite(f, min, sizeof(byte));;
  blockwrite(f, clicks, sizeof(word));;
  for i := 0 to fieldHeight - 1 do
    for j := 0 to fieldWidth - 1 do
    begin
      if mode = EDITOR_MODE then
      begin
        field[j, i].rotNum := field[j, i].rotNum + random(4);
        if field[j, i].rotNum >= 4 then
          field[j, i].rotNum := field[j, i].rotNum - 4;
      end;
      blockwrite(f, field[j, i].bitMapIdx, sizeof(byte));
      blockwrite(f, field[j, i].rotNum, sizeof(byte));
    end;
  closefile(f);
end;

{ ------------------------------------------------------------------------------------
  * Wird aufgerufen wenn der "speichern" Button gedrueckt wurde
  * SaveDialog wird aufgerufen
  * speichert das aktuelle Feld mit field2file und schliesst das Spielfeld
  -----------------------------------
  Verwendet:
  private:
  mode
  object:
  animationTimer
  tempTimer
  method:
  solvedField(...);
  field2file(...);
  FormResize(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.sbSaveClick(Sender: TObject);
var
  saveDialog: TSaveDialog;
  check, timer: boolean;
begin
  if not animationTimer.Enabled then
    repeat
      saveDialog := TSaveDialog.Create(Self);
      saveDialog.Filter := 'Dat Datei|*.dat|';
      saveDialog.DefaultExt := 'dat';
      saveDialog.Filename := '*.dat';
      saveDialog.Options := [ofOverwritePrompt];


      timer := false;

      if tempTimer.Enabled then // Die Spielzeit wird angehalten
      begin
        tempTimer.Enabled := false;
        timer := true;
      end;

      if saveDialog.Execute then // wird dann abgespeichert mit saveDialog
      begin
        check := true;
        if pos('.dat', saveDialog.Filename) = 0 then
          ShowMessage('Falscher Datei-Type')
        else
        begin
          check := false;
          field2file(saveDialog.Filename);
          ShowMessage('Gespeichert am ' + saveDialog.Filename);
          close;
        end;
      end
      else
      begin
        if timer then // timer wird wieder gestartet
          tempTimer.Enabled := true;
        check := false;
        FormResize(Sender);
      end;
      saveDialog.Free;
    until (not check);

end;

{ ------------------------------------------------------------------------------------
  * Wird aufgerufen wenn der "Editor" Button gedrueckt wurde und erstellt das Feld mit den Rohren
  -------------------------------------
  Verwendet:
  private:
  cell;
  fieldHeigth;
  TOP_GAP;
  BORDER_STYLE_GAP;
  finished;
  mode;
  object:
  newLoad;
  editorMode;
  tempTimer;
  lTime;;
  method:
  AddButton(...);
  changeEditorMode(...);
  fieldReload(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.bEditorClick(Sender: TObject);
{ -------------------------------------------------
  * Erstellt ein Button und setzt die Position und die Caption
  ------------------------------------------------- }
  procedure AddButton(var b: TButton; c: string; X, Y: word);
  begin
    b := TButton.Create(Self);
    b.Parent := Self;
    b.Caption := c;
    b.Top := Y;
    b.Left := X;
  end;

begin
  if bEditor.Caption = 'Editor' then
  begin
    bEditor.Caption := 'Zurück';
    lTime.Caption := '';
    finished := false;
    tempTimer.Enabled := false;

    AddButton(newLoad, 'Neues Feld', 5, bSetting.Top);
    newLoad.OnClick := editorReload;

    AddButton(editorMode, 'Aktiv = Rohre drehen', bEditor.Left + bEditor.width,
      bEditor.Top);
    mode := EDITOR_MODE;
    editorMode.width := editorMode.width + 50;
    editorMode.OnClick := changeEditorMode;
    height := cell * fieldHeight + TOP_GAP + BORDER_STYLE_GAP + cell + 10;
    myTimer := Ttimer.Create(Self);
    myTimer.Interval := 1;
    myTimer.Enabled := true;
    myTimer.OnTimer := resizeTimerLabel;
  end
  else
  begin
    if (MessageDlg('Wollen sie das Feld neuladen?', mtConfirmation,
      [mbOK, mbCancel], 0) = mrOK) then
    begin
      changeEditorMode(Sender);
      newLoad.Free;
      editorMode.Free;
      fieldReload(Sender);
      height := cell * fieldHeight + TOP_GAP + BORDER_STYLE_GAP;
    end;
  end;

end;

{ ------------------------------------------------------------------------------------
  * Oeffnet das Einstellungs Fenster
  * Speichert die Werte in der config.dat
  * Liest beim naechsten aufruf die config.dat
  * Setzt die Tracksbars auf die richtige Position
  ---------------------------
  Verwendet:
  const
  NEW_MODE
  LOAD_MODE
  EDITOR_MODE
  TOP_GAP
  Unit:
  fsettings:
  SetModi(...);
  getrow;
  getStoneNum;
  stoneNum;
  getOverflow;
  getColumn;
  getAnimation;
  private:
  field;
  cell;
  mode;
  fieldHeigth,fieldWidth;
  overflow;
  source_x,source_y;
  animationSpeed;
  object:
  tempTimer
  method:
  fieldReload(...)
  drawField(...);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.bSettingClick(Sender: TObject);
var
  check, timer: boolean;
begin
  timer := false;
  check := true;

  if tempTimer.Enabled then
  begin
    tempTimer.Enabled := false;
    timer := true;
  end;

  fSetting.SetModi(mode);
  if fSetting.ShowModal = mrOK then
  begin
    case mode of
      NEW_MODE:
        begin
          // falls einer der Komponenten geändert wurde muss das feld neugeladen werden
          if fSetting.getColumn <> fieldWidth then
            check := false;
          if fSetting.getrow <> fieldHeight then
            check := false;
          if fSetting.getStoneNum <> stoneNum then
            check := false;
          if fSetting.getOverflow <> overflow then
            check := false;

          if not check and (MessageDlg('Wollen sie das Feld neuladen?',
            mtConfirmation, [mbOK, mbCancel], 0) = mrOK) then
            fieldReload(Sender)
          else if timer then
            tempTimer.Enabled := true;
        end;
      LOAD_MODE:
        begin
          setlength(field, fieldWidth, fieldHeight);
          drawField(Sender, false);
          height := cell * fieldHeight + TOP_GAP + 10;
        end;
      EDITOR_MODE:
        begin
          fieldHeight := fSetting.getrow;
          fieldWidth := fSetting.getColumn;
          overflow := fSetting.getOverflow;
          if (source_x > fieldWidth) or (source_y > fieldHeight) then
          begin
            source_x := 255;
            source_y := 255;
          end;
          setlength(field, fieldWidth, fieldHeight);

          drawField(Sender, false);
          height := cell * fieldHeight + TOP_GAP + 10;
        end;
    end;
  end
  else if timer then
    tempTimer.Enabled := true;

  animationSpeed := fSetting.getAnimation;
end;

{ ------------------------------------------------------------------------------------
  * Wenn die Form erstellt wird , werden auch die Bilder erstellt
  -------------------------
  Verwendet:
  editorPipe;
  pipeEditorMode;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.FormCreate(Sender: TObject);
var
  i: byte;
begin
  for i := 0 to 5 do
    editorPipe[i] := TImage.Create(Self);
  pipeReplaceSelect := TShape.Create(Self);
end;

{ ------------------------------------------------------------------------------------
  * Wenn auf der Maus gedrueckt wurde , dreht man das angeclickte Rohr
  * Wenn im Editor "Rohr aendern" Aktiv ist , ersetzt er das angeclickte Rohr
  ----------------------------------------
  Verwendet:
  Unit:
  fsettings:
  const:
  NEW_MODE
  EDITOR_MODE;
  const:
  TOP_GAP;
  private:
  clicks;
  finished;
  fieldWidth,fieldHeigth;
  pipeChange;
  cell;
  mode;
  overflow
  object:
  AnimationTimer;
  tempTimer
  method:
  replacePipe(...)
  rotatePipeByButtonClick(...);
  fillPipe(...)
  solvedField(...)
  FormShow(Sender);
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{ ------------------------------------------------------------------------------------
  * Ein Rohr drehung
  ---------------------------------
  * Linksclick = 90° links Drehung
  * Rechtsclick = 90° rechts Drehung
  ----------------------------------
  Verwendet:
  private:
  field;
  object:
  ilImageList;
  method:
  NOSWrot(...);
  NOSWrot(field[X, Y]);
  rotateBitmap(bmp);
  end;
  ---------------------------------------------------------------------------------------- }
  procedure rotatePipeByButtonClick(X, Y: byte; var bmp: TBitmap);
  var
    j: byte;
  begin
    if ilImageList.GetBitmap(field[X, Y].bitMapIdx, bmp) then
    begin
      j := field[X, Y].rotNum;
      if Button = mbLeft then
      begin
        field[X, Y].rotNum := field[X, Y].rotNum + 1;
        NOSWrot(field[X, Y]);
      end
      else if Button = mbright then
      begin
        j := j + 2;
        field[X, Y].rotNum := field[X, Y].rotNum + 3;
        NOSWrot(field[X, Y]);
        NOSWrot(field[X, Y]);
        NOSWrot(field[X, Y]);
      end;

      for j := j downto 0 do
        rotateBitmap(bmp);

      if field[X, Y].rotNum >= 4 then
        field[X, Y].rotNum := field[X, Y].rotNum - 4;
    end;
  end;

{ ------------------------------------------------------------------------------------
  * Das Rohr wird ersetzt mit den ausgewaehlten Rohr
  ----------------------------------
  Verwendet:
  const:
  TOP_GAP;
  private:
  cell;
  field;
  source_x,source_y;
  object:
  ilImageList;
  pipeEditorMode;
  method:
  NOSWset(...);
  NOSWrot(...);
  rotateBitmap(...);
  end;
  ---------------------------------------------------------------------------------------- }
  procedure replacePipe(X, Y: byte; var bmp: TBitmap);
  var
    i, j: byte;
  begin
    j := (pipeReplaceSelect.Left + 5) div cell;
    if j = 5 then
    begin
      if field[X, Y].bitMapIdx <> 0 then
      begin
        if (source_x <> 255) and (source_y <> 255) then
        begin
          field[source_x, source_y].bitMapIdx := field[source_x, source_y]
            .bitMapIdx - 8;
          if ilImageList.GetBitmap(field[source_x, source_y].bitMapIdx, bmp)
          then
          begin
            NOSWset(field[source_x, source_y]);
            for i := 1 to field[source_x, source_y].rotNum do
            begin
              rotateBitmap(bmp);
              NOSWrot(field[source_x, source_y]);
            end;
            Self.Canvas.StretchDraw(Rect(0 + cell * source_x,
              0 + cell * source_y + TOP_GAP, cell + cell * source_x,
              cell + cell * source_y + TOP_GAP), bmp);
          end;
        end;

        case field[X, Y].bitMapIdx of
          1 .. 4:
            j := field[X, Y].bitMapIdx + 8;
          5 .. 8:
            j := field[X, Y].bitMapIdx + 4;
        else
          j := field[X, Y].bitMapIdx;
        end;

        if ilImageList.GetBitmap(j, bmp) then
        begin
          for i := 1 to field[X, Y].rotNum do
            rotateBitmap(bmp);
          field[X, Y].bitMapIdx := j;
          source_x := X;
          source_y := Y;
        end;
      end;
    end
    else if ilImageList.GetBitmap(j, bmp) then
    begin
      if (j = 0) then
      begin
        if (source_x = X) and (source_y = Y) then
        begin
          source_x := 255;
          source_y := 255;
        end;
      end
      else if (source_x = X) and (source_y = Y) then
      begin
        if ilImageList.GetBitmap(j + 8, bmp) then
          j := j + 8;
      end;

      field[X, Y].bitMapIdx := j;
      NOSWset(field[X, Y]);
      field[X, Y].rotNum := 0;
    end;
  end;

var
  p: TPoint;
  a, b: word;
  bmp: TBitmap;
begin
  inc(clicks);
  if not animationTimer.Enabled and not finished then
  begin
    p := Self.ScreenToClient(Mouse.CursorPos);
    if p.Y > TOP_GAP then
    begin
      a := p.X div cell;
      b := (p.Y - TOP_GAP) div cell;
      // Feld Koordinate ebstimmen durch die Maus

      if (a < fieldWidth) and (b < fieldHeight) then
      // Nach nicht außerhalb  sein
      begin
        try
          bmp := TBitmap.Create;

          // Wenn der Modus gesetzt wurde zum ersetzen
          if pipeChange then
            replacePipe(a, b, bmp)
          else
            rotatePipeByButtonClick(a, b, bmp);

          Self.Canvas.StretchDraw(Rect(a * cell, b * cell + TOP_GAP,
            cell + a * cell, cell + b * cell + TOP_GAP), bmp);
        finally
          bmp.Free;
        end;

        fillPipe(Sender);
        if mode <> EDITOR_MODE then
        begin
          tempTimer.Enabled := true;
          finished := solvedField(field, overflow);
        end;
      end;
    end;

    if (mode = EDITOR_MODE) and not solvedField(field, overflow) then
      sbSave.Enabled := false
    else
      sbSave.Enabled := true;

    if finished then
    begin
      ShowMessage('Du hast alle Rohre mit ' + inttostr(clicks) +
        ' Clicks richtig belegt');
      tempTimer.Free;
      mode := NEW_MODE;
      FormShow(Sender);
    end;
  end;

end;

{ ------------------------------------------------------------------------------------
  * Beim Schliessen wird das Feld geleert
  * Buttons werden freigegeben
  -------------------------
  Verwendet:
  private:
  cancel;
  object:
  tTemptimer;
  newLoad;
  editorMode;
  bEditor;
  ---------------------------------------------------------------------------------------- }
procedure Tfnew.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not cancel then
  begin
    tempTimer.Free;
    setlength(field, 0, 0);
  end;
  if bEditor.Caption <> 'Editor' then
  begin
    newLoad.Free;
    editorMode.Free;
  end;
end;

{ ------------------------------------------------------------------------------------
  * Wenn die Formulargroesse veraendert wurde werden die Bilder und die Buttons neu gesetzt
  ----------------------------------
  Verwendet:
  Unit:
  fsettings:
  const:
  EDITOR_MODE
  const:
  BORDER_STYLE_GAP
  TOP_GAP
  private:
  cancel;
  mode;
  cell;
  fieldHeigth;
  fieldWidth;
  object:
  ilImageList;
  pipeEditorMode;
  sbSave;
  moveShape;
  editorPipe;
  mehode:
  drawField(...);

}
procedure Tfnew.FormResize(Sender: TObject);
var
  i: byte;
  bmp: TBitmap;
begin
  if not cancel then
  begin
    cell := (width - 15) div fieldWidth;

    if mode = EDITOR_MODE then
    begin
      if not solvedField(field, overflow) then
        sbSave.Enabled := false
      else
        sbSave.Enabled := true;

      if cell * fieldWidth < cell * 6 then
        cell := (width - 15) div 6;

      pipeReplaceSelect.width := cell;
      pipeReplaceSelect.height := 10;
      pipeReplaceSelect.Top := TOP_GAP + (cell * fieldHeight) + cell + 5;
      pipeReplaceSelect.Left := 5;

      for i := 0 to 5 do
      begin
        editorPipe[i].Free;
        editorPipe[i] := TImage.Create(Self);
        editorPipe[i].Left := 5 + i * cell;
        editorPipe[i].Top := TOP_GAP + (cell * fieldHeight) + 5;
        editorPipe[i].width := cell;
        editorPipe[i].height := cell;
        editorPipe[i].Parent := Self;
        editorPipe[i].OnClick := moveShape;
        bmp := TBitmap.Create;
        try

          if (i = 5) and ilImageList.GetBitmap(11, bmp) then
            editorPipe[i].Canvas.StretchDraw(Rect(0, 0, cell, cell), bmp)
          else if ilImageList.GetBitmap(i, bmp) then
            editorPipe[i].Canvas.StretchDraw(Rect(0, 0, cell, cell), bmp);

        finally
          bmp.Free;
        end;
        editorPipe[i].Visible := true;
      end;
      Self.Canvas.FillRect(Rect(0, 0, width, height));
      height := cell * fieldHeight + TOP_GAP + BORDER_STYLE_GAP + cell + 10;
    end
    else
    begin
      for i := 0 to 5 do
        editorPipe[i].Visible := false;

      height := cell * fieldHeight + TOP_GAP + BORDER_STYLE_GAP;
    end;
    drawField(Sender, false);
    sbSave.Left := width - 50;
  end;
end;

{ ---------------------------------------------------------------------------
  * Hauptprogramm die beim Start aufgerufen wird
  -------------------------------------
  Verwendet:
  Unit:
  fsettings:
  const:
  NEW_MODE;
  LOAD_MODE;
  private:
  field;
  mode;
  myTimer
  overflow;
  cancel;
  pipeChange;
  clicks;
  finished;
  object:
  bSetting;
  bEditor;
  method:
  newClick(...)
  loadClick(...);
  solvedField(...);
  setTimerLabel(...);
  fillPipe(...);
  resizeTimerLabel(...)

}
procedure Tfnew.FormShow(Sender: TObject);
begin
  bSetting.Left := 150;
  bEditor.Left := bSetting.Left + bSetting.width;
  bEditor.Caption := 'Editor';
  cancel := false;
  pipeChange := false;
  clicks := 0;

  if mode = NEW_MODE then
    newClick(Sender)
  else if mode = LOAD_MODE then
    loadClick(Sender);

  if not cancel then
  begin
    finished := solvedField(field, overflow);
    setTimerLabel(Sender);
    fillPipe(Sender);
    myTimer := Ttimer.Create(Self);
    myTimer.Interval := 1;
    myTimer.Enabled := true;
    myTimer.OnTimer := resizeTimerLabel;
  end;
end;

end.
