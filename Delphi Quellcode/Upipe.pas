{ ------------------------------------------------------------------------------
  Unit Rohr

  In dieser Unit sind die Typen Deklarationen von den Rohren und
  viele kleine Funktionen und Proceduren

  Autor : Nima Mohammadimohammadi  alias ias105448
  ---------------------------------------------------------------------------- }
unit Upipe;

interface

type
  TIndex = (N, O, S, W);

  TFieldrecord = record
    direction: array [TIndex] of boolean;
    occupied, filled: boolean;
    bitMapIdx: byte;
    rotNum: byte;
  end;

  TField = array of array of TFieldrecord;

procedure NOSWset(var pipe: TFieldrecord);
procedure NOSWrot(var pipe: TFieldrecord);
procedure rotatePipe(var Field: TField);
procedure addSource(var Field: TField; var x, y: byte);
function solvedField(Field: TField; overflow: boolean): boolean;
function allConnect(widthField, heightField, stone: byte;
  strResult: string): boolean;
function placeStone(Field: TField; stone: byte): TField;
function placePipe(Field: TField; overflow: boolean): TField;

implementation

{ -------------------------------------------------
  * In der Procedure werden alle Richtungen gesetzt abhaenging
  * was fuer ein Rohr das ist
  * PS: Schaue erst die BilderListe in u_pipefield
  -----------------
  * Parameter :
  * ref in : ein Rohr
  * ref out : ein Rohr mit richtigen Richtungen true
  ---------------------------------------------- }
procedure NOSWset(var pipe: TFieldrecord);
begin
  pipe.direction[N] := false;
  pipe.direction[O] := false;
  pipe.direction[S] := false;
  pipe.direction[W] := false;

  case pipe.bitMapIdx of
    // T Stueck in allen Varianten
    4, 8, 12:
      begin
        pipe.direction[N] := true;
        pipe.direction[O] := true;
        pipe.direction[S] := true;
      end;
    // Geraden Stueck in allen Varianten
    3, 7, 11:
      begin
        pipe.direction[N] := true;
        pipe.direction[S] := true;
      end;
    // Kurve Stueck in allen Varianten
    2, 6, 10:
      begin
        pipe.direction[O] := true;
        pipe.direction[S] := true;
      end;
    // End Stueck in allen Varianten
    1, 5, 9:
      pipe.direction[S] := true;
  end;

end;

{ -------------------------------------------------
  * In der Procedure werden alle Richtungen
  * um "einen" in Uhrzeiger Richtung rotiert
  -----------------
  * Beispiel :
  * Norder --> Osten
  * Osten --> Sueden
  * Sueden --> Westen
  * Westen --> Norden
  -----------------
  * Parameter :
  * ref in : ein Rohr
  * ref out : ein Rohr mit einmal rotierten Richtung
  ---------------------------------------------- }
procedure NOSWrot(var pipe: TFieldrecord);
var
  copyO, copyS, copyW: boolean;
begin
  copyO := pipe.direction[O];
  pipe.direction[O] := pipe.direction[N];
  copyS := pipe.direction[S];
  pipe.direction[S] := copyO;
  copyW := pipe.direction[W];
  pipe.direction[W] := copyS;
  pipe.direction[N] := copyW;
end;

{ -------------------------------------------------
  * In dieser Funktion wird das uebergebene Rohr gecheckt
  * ob das Rohr an der aktuellen stelle passt diese Ueberpruefung passiert in
  * CheckRohr und CheckNachbar
  -----------------
  * Parameter :
  * in : Spielfeld und x & y vom ueberprueften Rohr
  * out : true / false
  -----------------
  * Verwendet:
  ---------------------------------------------- }
function fitsThePipe(Field: TField; x, y: byte; overflow: boolean): boolean;
var
  check: boolean;
begin
  check := true;

  if Field[x, y].direction[N] then
    if y = 0 then
    begin
      if overflow then
      // Ueberlaufmodus aktiv ist wird das Rohr[0,maxHohe].Sueden unten auch Ueberprueft
      begin
        if Field[x, length(Field[0]) - 1].occupied and
          not Field[x, length(Field[0]) - 1].direction[S] then
          check := false;
      end
      else
        check := false;
    end
    // wenn Y groesser 0 ist wird das Rohr darueber ueberprueft
    else if Field[x, y - 1].occupied and not Field[x, y - 1].direction[S] then
      check := false;

  if check and Field[x, y].direction[O] then
    if x = length(Field) - 1 then
    begin
      if overflow then
      // Ueberlaufmodus aktiv ist wird das Rohr[0,maxHohe].Sueden unten auch Ueberprueft
      begin
        if Field[0, y].occupied and not Field[0, y].direction[W] then
          check := false;
      end
      else
        check := false;
    end
    // wenn Y groesser 0 ist wird das Rohr darueber ueberprueft
    else if Field[x + 1, y].occupied and not Field[x + 1, y].direction[W] then
      check := false;

  if check and Field[x, y].direction[S] then
    if y = length(Field[0]) - 1 then
    begin
      if overflow then
      // Ueberlaufmodus aktiv ist wird das Rohr[0,maxHohe].Sueden unten auch Ueberprueft
      begin
        if Field[x, 0].occupied and not Field[x, 0].direction[N] then
          check := false;
      end
      else
        check := false;
    end
    // wenn Y groesser 0 ist wird das Rohr darueber ueberprueft
    else if Field[x, y + 1].occupied and not Field[x, y + 1].direction[N] then
      check := false;

  if check and Field[x, y].direction[W] then
    if x = 0 then
    begin
      if overflow then
      // Ueberlaufmodus aktiv ist wird das Rohr[0,maxHohe].Sueden unten auch Ueberprueft
      begin
        if Field[length(Field) - 1, y].occupied and
          not Field[length(Field) - 1, y].direction[O] then
          check := false;
      end
      else
        check := false;
    end
    // wenn Y groesser 0 ist wird das Rohr darueber ueberprueft
    else if Field[x - 1, y].occupied and not Field[x - 1, y].direction[O] then
      check := false;

  if check then
    if (0 < y) then
    begin
      if Field[x, y - 1].direction[S] and not Field[x, y].direction[N] then
        check := false;
    end
    else if overflow and Field[x, length(Field[0]) - 1].direction[S] and
      not Field[x, y].direction[N] then
      check := false;

  if check then
    if (x < length(Field) - 1) then
    begin
      if Field[x + 1, y].direction[W] and not Field[x, y].direction[O] then
        check := false;
    end
    else if overflow and Field[0, y].direction[W] and
      not Field[x, y].direction[O] then
      check := false;

  if check then
    if (y < length(Field[0]) - 1) then
    begin
      if Field[x, y + 1].direction[N] and not Field[x, y].direction[S] then
        check := false;
    end
    else if overflow and Field[x, 0].direction[N] and
      not Field[x, y].direction[S] then
      check := false;

  if check then
    if (0 < x) then
    begin
      if Field[x - 1, y].direction[O] and not Field[x, y].direction[W] then
        check := false;
    end
    else if overflow and Field[length(Field) - 1, y].direction[O] and
      not Field[x, y].direction[W] then
      check := false;

  fitsThePipe := check;
end;

{ -------------------------------------------------
  * In dieser Funktion wird ueberpueft ob das Spielfeld geloest wurde
  -----------------
  * Parameter :
  * in : Field
  * out : true / false
  -----------------
  Verwendet:
  * fitsThePipe(...)
  ---------------------------------------------- }
function solvedField(Field: TField; overflow: boolean): boolean;
var
  i, j: byte;
  countRocks: byte;
  check: boolean;
begin
  check := true;
  i := 0;
  j := 0;
  countRocks := 0;
  repeat
    // Field < 5 bedeutet das die Blau angemalt sein muss
    // Field[i, j].bitmapidx <> 0 ungleich Stein geht er das feld durch
    if Field[i, j].bitMapIdx = 0 then
      inc(countRocks);

    if (Field[i, j].bitMapIdx <> 0) and (Field[i, j].bitMapIdx < 5) then
      check := false
    else if (not fitsThePipe(Field, i, j, overflow)) then
      check := false;

    inc(i);
    if i = length(Field) then
    begin
      i := 0;
      inc(j);
    end;
  until (check = false) or (j = length(Field[0]));

  solvedField := check and (countRocks <> (length(Field[0]) * length(Field)));
end;

{ -------------------------------------------------
  * In dieser Funktion wird ueberpueft ob das Spielfeld loesbar ist

  * Es wurde die Auffuellen Rekursion gestartet und
  * alle Felder die Angemalt werden muessen sind im string Erg

  * Es wird gezaehlt wie viele Felder angemalt werden muessen wenn weniger als
  * erwartet ,ist das Spielfeld nicht loesbar
  -----------------
  * Parameter :
  * in : strResult
  * in : widthField ,heightField, stone
  * out : true / false
  ---------------------------------------------- }
function allConnect(widthField, heightField, stone: byte;
  strResult: string): boolean;
var
  i: byte;
begin
  i := 1;
  repeat
    delete(strResult, pos('|', strResult), 1);
    delete(strResult, 1, pos('|', strResult));
    inc(i);
  until (strResult = '');
  allConnect := (i = heightField * widthField - stone);
end;

{ -------------------------------------------------
  * In dieser Funktion wird ein Quelle hinzugefügt

  * Das Bild wird eingestellt und
  * mit den Ref Parameter wird auch die Quelle Koordinate zurueck gegeben
  -----------------
  * Parameter :
  * ref in : Field
  * ref in : x,y
  ---------------------------------------------- }
procedure addSource(var Field: TField; var x, y: byte);
begin
  randomize;
  repeat
    x := random(length(Field));
    y := random(length(Field[0]));
  until Field[x, y].bitMapIdx <> 0;
  Field[x, y].bitMapIdx := Field[x, y].bitMapIdx + 8;
end;

{ -------------------------------------------------
  * In dieser Funktion werden auf den Spielfeld random Steine platziert

  * Das Bild wird eingestellt und die Richtung werden gesetzt
  -----------------
  * Parameter :
  * in : Field
  * in : stone
  * out : Field
  ---------------------------------------------- }
function placeStone(Field: TField; stone: byte): TField;
var
  a, b, Anzahl: byte;
begin
  randomize;
  Anzahl := stone;
  repeat
    repeat
      a := random(length(Field));
      b := random(length(Field[0]));
    until not Field[a, b].occupied;

    if Anzahl > 0 then
      with Field[a, b] do
      begin
        direction[N] := false;
        direction[O] := false;
        direction[S] := false;
        direction[W] := false;
        occupied := true;
        bitMapIdx := 0;
        rotNum := 0;
        dec(Anzahl);
      end;

  until 0 = Anzahl;
  placeStone := Field;
end;

{ -------------------------------------------------
  * In dieser Funktion werden auf den Spielfeld alle Rohre platziert und
  * passend eingestellt mit:

  * Anzahl Rotation,
  * Richtugen
  * Bitmap Zahl wird eingestellt
  -----------------
  * Die Rohre 2..4 werden mit gleicher Wahrscheinlichkeit eingesetzt
  * Wenn das Array durch gearbeitet wurde wird ein Endstück platziert
  * Wenn das auch nicht passt wird ein Stein platziert
  * dann ist die Generierung Fehlgeschlagen und ein neues Feld wird gemacht
  * in allConnect
  --------
  * dafür verwendet ich ein Array was die Rohre random einsetzt
  -----------------
  * Parameter :
  * in : Field
  * in : overflow
  * out : Field
  -----------------
  Verwendet:
  * fitsThePipe(...)
  * NOSWrot(...)
  * NOSWset(...)
  ---------------------------------------------- }
function placePipe(Field: TField; overflow: boolean): TField;

type
  TRohre = array [2 .. 4] of byte;
  { -------------------------------------------------
    * In dieser Procedure wird ein Array von 2..4 mit Rohren vermischt
    * Rohre:
    ~ T Stueck
    ~ Gerade
    ~ Kurve
    -----------------
    * Parameter :
    * ref in : rohr
    -----------------
    Verwendet :
    ---------------------------------------------- }
  procedure RandommizeArray(var rohr: TRohre);
  var
    i, j: byte;
  begin
    for i := 2 to 4 do
      rohr[i] := 0;
    i := 1;
    repeat
      inc(i);
      repeat
        j := random(3) + 2;
      until rohr[j] = 0;
      rohr[j] := i;
    until i = 4;
  end;

var
  a, b, i, j, p: byte;
  rohr: TRohre;
begin
  for b := 0 to length(Field[0]) - 1 do
    for a := 0 to length(Field) - 1 do
      if not Field[a, b].occupied then
      begin
        i := 255;
        p := 2;
        RandommizeArray(rohr);
        repeat
          if i > 1 then
            i := rohr[p];
          with Field[a, b] do
          begin
            direction[N] := false;
            direction[O] := false;
            direction[S] := false;
            direction[W] := false;
            occupied := true;
            bitMapIdx := i;
          end;
          NOSWset(Field[a, b]);
          if not fitsThePipe(Field, a, b, overflow) then
          begin
            j := 0;
            repeat
              NOSWrot(Field[a, b]);
              inc(j);
            until (j = 4) or (fitsThePipe(Field, a, b, overflow));
            if j = 4 then
              j := 0;
            Field[a, b].rotNum := j;
            inc(p);
          end;
          if p = 5 then
            i := 1;
          if (p = 6) then
            i := 0;
        until (p = 7) or fitsThePipe(Field, a, b, overflow);
      end;
  placePipe := Field;
end;

{ -------------------------------------------------
  * In dieser Funktion werden alle Rohre verdreht
  * Das Bild wird eingestellt und die Richtung rotiert
  -----------------
  * Parameter:
  * ref in : Field
  ----------------
  Verwendet:
  * NOSWrot(...)
  ---------------------------------------------- }
procedure rotatePipe(var Field: TField);
var
  i, j: byte;
  a, b: byte;
begin
  randomize;
  for b := 0 to length(Field[0]) - 1 do
    for a := 0 to length(Field) - 1 do
      if Field[a, b].bitMapIdx <> 0 then
      begin
        j := random(4);
        for i := 1 to j do
          NOSWrot(Field[a, b]);
        Field[a, b].rotNum := Field[a, b].rotNum + j;
        if Field[a, b].rotNum >= 4 then
          Field[a, b].rotNum := Field[a, b].rotNum - 4;
      end;
end;

end.
