{ ----------------------------------------------------
        MICHAL LESNIEWSKI
               GRA
         KOSMICI ATAKUJA
  ----------------------------------------------------
         KOSMITA.PAS
         Plik glowny
  ----------------------------------------------------
}

program KosmiciAtakuja;

uses Crt;

{$I grafika.pas}
{$I mysz.pas}

const krok = 5;

const ilepociskow = 42;
      iluwrogow = 4;
      ilebroni = 4;
      ileeksplozji = 100;
      dlugosc = 4000;

var CzasWyswietlaniaNapisu: integer;
    WyswietlanyNapis: byte;
    dzwiek, przes: byte;
    DzwiekWlaczony: boolean;
    Powoli: boolean;

{ SPRITEy }
var eksplozja: array[1..15] of spr;
    statek: array[1..2] of spr;
    kosmici: array[1..iluwrogow, 1..2] of spr;
    pociskibroni: array[1..ilebroni, 1..2] of spr;
    tlo, napis, dysk: spr;

var c: byte;

{ ------------------------ }

var PokazujDyskietke: byte;

var StatekGracza: record
  x, y: word;
  zycie: shortint;
  pancerz: shortint;

  punkty: Longint;

  naboje: array[1..ilebroni] of word;

  temperatura: word;
  czas: word;
  wybranabron: byte;
end;


var ostatnipocisk, ostatniaeksplozja, ostatniepunkty: byte;

var Gwiazdy: array[1..2, 1..30] of record
  x, y: integer;
end;

var Wrogowie: array[1..15] of record
  aktywny: boolean;
  numer: byte;
  sila: integer;
  x, y: integer;
  vx, vy: integer;
end;

var PokazEksplozje: array[1..ileeksplozji] of record
    x, y: word;
    klatka: shortint;
    rzad: word;
end;

var PokazPunkty: array[1..15] of record
      x, y: integer;
      czas: integer;
      ile: string;
end;

var Pociski: array[1..ilepociskow] of record
  x, y: integer;
  jaki: byte;
end;

{----------------------------------------------------------------------------}

function IntToStr(x: Longint): string;
var s: string[50];
begin
  str(x, s);
  IntToStr := s;
end;

procedure ZaladujGrafike;
  var i: byte;
      s: string;
begin
  PalLoad('grafika\p.pal');

  SprLoad('grafika\back3.spr', tlo);
  SprLoad('grafika\dysk.spr',  dysk);
  SprLoad('grafika\s1.spr', statek[1]);
  SprLoad('grafika\s2.spr', statek[2]);
  for i := 1 to 15 do
  begin
    str(i, s);
    SprLoad('grafika\e1p' + s + '.spr', eksplozja[i]);
  end;
  for i := 1 to ilebroni do
  begin
    SprLoad('grafika\p' + IntToStr(i) + 'k1.spr', pociskibroni[i, 1]);
    SprLoad('grafika\p' + IntToStr(i) + 'k2.spr', pociskibroni[i, 2]);
  end;

  for i := 1 to iluwrogow do
  begin
    SprLoad('grafika\w' + IntToStr(i) + 'k1.spr', kosmici[i, 1]);
    SprLoad('grafika\w' + IntToStr(i) + 'k2.spr', kosmici[i, 2]);
  end;

  SprLoad('grafika\tytul.spr', napis);

end;

procedure WykasujGrafike;
  var i: byte;
begin
  for i := 1 to 15 do
  begin
    PalDark(0.9);
    delay(25);
  end;

  for i := 1 to 15 do
    SprFree(eksplozja[i]);

  SprFree(statek[1]);
  SprFree(statek[2]);

  for i := 1 to iluwrogow do
  begin
    SprFree(kosmici[i, 1]);
    SprFree(kosmici[i, 2]);
  end;

  for i := 1 to iluwrogow do
  begin
    SprFree(pociskibroni[i, 1]);
    SprFree(pociskibroni[i, 2]);
  end;
  SprFree(dysk);
  SprFree(tlo);
  SprFree(napis);
end;

procedure GrajDzwiek(x: byte);
begin
  Dzwiek := x;
  Przes := 1;
end;

procedure Odtwarzaj;
  const s1 = 'CDBCBCABABAA';
  const s2 = 'DECDCDBCBCBB';
  const s3 = 'EFDEDECDCDCC';
  const s4 = 'FGEFGFDEDEDD';
  const s5 = 'azazaz';
  const s6 = 'aAaA';
  const s7 = 'AB';
  var s: string;
begin
  case dzwiek of
    1: s := s1;
    2: s := s2;
    3: s := s3;
    4: s := s4;
    5: s := s1;
    6: s := s5;
    7: s := s6;
    8: s := s7;
    else exit;
  end;

{  if StatekGracza.czas mod 2 = 0 then} inc(przes);
  if (Dzwiek = 0) or (przes > length(s)) then
  begin
    NoSound;
    Dzwiek := 0;
  end else begin
    Sound(20 + (ord(s[przes]) - 64) * 8);
  end;
end;

{ ------ POCZĄTEK GRY ------ }
procedure Resetuj;
  var i: integer;
begin
  StatekGracza.x := (320 - Statek[1].sy) div 2;
  StatekGracza.y := 200 - Statek[1].sx;
  StatekGracza.czas := 0;
  StatekGracza.zycie := 100;
  StatekGracza.pancerz := 100;
  StatekGracza.punkty := 0;
  StatekGracza.naboje[3] := 0;
  StatekGracza.naboje[2] := 0;
  StatekGracza.naboje[4] := 0;
  StatekGracza.temperatura := 500;
  StatekGracza.wybranabron := 0;
  MyszGranice(0, 178, 319, 178);
  for i := 1 to 15 do
  begin
    pociski[i].y := -120;
    Wrogowie[i].aktywny := false;
    PokazPunkty[i].czas := 0;
  end;

  for i := 1 to ileeksplozji do
  begin
    PokazEksplozje[i].klatka := -random(15);
    PokazEksplozje[i].x := random(320) - 10;
    PokazEksplozje[i].y := random(200) - 10;
  end;
end;


{ ------ EKRAN GRY ------ }
procedure WyswietlGre;
  var i: word;
      wsp: byte;
begin
  {Narysuj tlo }
  bSprPut(0, 0, tlo);

  {Narysuj pociski}
  for i := 1 to ilepociskow do
    if (pociski[i].y > 0) and (pociski[i].jaki <= ilebroni) then
       bSprPutTrans(pociski[i].x, pociski[i].y, pociskibroni[pociski[i].jaki + 1, StatekGracza.czas mod 2 + 1]);

  {Narysuj wrogow }
  for i := 1 to 15 do
  if Wrogowie[i].aktywny then
       bSprPutTrans(wrogowie[i].x, wrogowie[i].y, kosmici[wrogowie[i].numer,
          ((StatekGracza.czas + i + wrogowie[i].numer) div 10) mod 2 + 1]);

  {Narysuj statek}
  if StatekGracza.zycie > 0 then
  bSprPutTrans(StatekGracza.x, StatekGracza.y, statek[StatekGracza.czas mod 2 + 1]);

  {Narysuj eksplozje}
  for i := 1 to ileeksplozji do
  begin
    if PokazEksplozje[i].klatka <= 14 then
    begin
      if (StatekGracza.czas mod 3 = 0) or (StatekGracza.czas mod 2 = 0) then
        inc(PokazEksplozje[i].klatka);
      if PokazEksplozje[i].klatka >= 1 then begin
        bSprPutTrans(PokazEksplozje[i].x, PokazEksplozje[i].y, eksplozja[PokazEksplozje[i].klatka]);
      end;
    end;
  end;

  {Narysuj punkty}
  if StatekGracza.zycie > 0 then
  begin
  for i := 1 to 15 do
  begin
    if PokazPunkty[i].czas > 0 then
    begin
      dec(PokazPunkty[i].czas);
      if (PokazPunkty[i].czas > 25) and (PokazPunkty[i].y > 10) then
        dec(PokazPunkty[i].y);
      wsp := round(15 * (25 - abs(25 - PokazPunkty[i].czas)) / 25);
      Text(PokazPunkty[i].x, PokazPunkty[i].y, 16 + wsp, PokazPunkty[i].ile);
    end;
  end;

  {Narysuj pasek informacji}
  Text(0, 0, 15, 'Statek : ' + IntToStr(StatekGracza.zycie));
  Text(0, 8, 15, 'Pancerz: ' + IntToStr(StatekGracza.pancerz));
  Text(0, 190, 15, 'Punkty:  ' + IntToStr(StatekGracza.punkty) + '00');

  Text(170, 190, 15, 'Czas:  ' + IntToStr(StatekGracza.czas));

  Text(280, 0, 79, 'temp:');
  if StatekGracza.temperatura < 2500 then
    if StatekGracza.temperatura > 1750 then
    wsp := round(48 - 8 * (StatekGracza.temperatura - 1750) / 750)
    else wsp := 10
  else if StatekGracza.czas mod 15 > 5 then wsp := 12 else wsp := 0;

  Text(280, 8, wsp, IntToStr(StatekGracza.temperatura));

  case StatekGracza.wybranabron of
  0: begin
      Text(110, 0, 15, 'Bron  : Laser');
      Text(110, 8, 15, 'Naboje: oo');
     end;
  1: Text(110, 0, 15, 'Bron  : Ogien');
  2: Text(110, 0, 15, 'Bron  : Rakieta');
  3: Text(110, 0, 15, 'Bron  : Bomba');
  end;
  if StatekGracza.wybranabron > 0 then
     Text(110, 8, 15, 'Naboje: ' + IntToStr(StatekGracza.naboje[StatekGracza.wybranabron]));
  end;

  { TYTUŁ }
  if (CzasWyswietlaniaNapisu >= 15) or ((CzasWyswietlaniaNapisu > 0) and (StatekGracza.czas mod 2 = 0)) then
  begin
     bSprPutTrans(160 - napis.sx div 2, 40, napis);
     dec(CzasWyswietlaniaNapisu);
  end;

  if PokazujDyskietke > 0 then
  begin
    bSprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
    dec(PokazujDyskietke);
  end;

  if StatekGracza.czas mod dlugosc < 150 then
    if StatekGracza.czas < dlugosc * 5 then
      TextFat(128, 30, 15, 0, 'POZIOM ' + IntToStr(StatekGracza.czas div dlugosc + 1));

  if (StatekGracza.czas > dlugosc * 5) or (StatekGracza.zycie <= 0) then
      TextFat(10, 120, 15, 0, 'Nacisnij r, aby rozpoczac od nowa.');



  if StatekGracza.czas < 150 then
    begin
      TextFat(70, 100, 15, 4, 'GRA MICHALA LESNIEWSKIEGO');

      TextFat(10, 120, 15, 0, 'Ocal ziemie przed inwazja kosmitow z');
      TextFat(10, 130, 15, 0, 'planety X.  Kieruj statkiem za pomoca');
      TextFat(10, 140, 15, 0, 'myszy. Bron zmieniaj prawym klawiszem.');
      TextFat(10, 150, 15, 0, '    UWAZAJ NA TEMPERATURE STATKU!');
      TextFat(10, 165, 15, 0, 'Funkcje klawiszy:  s - dzwiek');
      TextFat(10, 175, 15, 0, '                   r - restart');
      TextFat(10, 185, 15, 0, '                   z - predkosc');

      if (StatekGracza.czas < 100) and (round(random(40)) = 1) then
      begin
        StatekGracza.punkty := 0;
        StatekGracza.zycie := 100;
        StatekGracza.pancerz := 100;
        ostatniaeksplozja := (ostatniaeksplozja + 1) mod ileeksplozji + 1;
        PokazEksplozje[ostatniaeksplozja].klatka := -random(5);
        PokazEksplozje[ostatniaeksplozja].x := random(320) - 16;
        PokazEksplozje[ostatniaeksplozja].y := random(200) - 10;
      end;
    end;
  bcopy;
end;

{----------------------------------------------------------------------------}

function Kolizja(x1, y1, w1, h1, x2, y2, w2, h2: integer): boolean;
begin
  { W poziomie }
  Kolizja :=
        (((x1 >= x2)     and (x1 <= x2 + w2))
     or ((x2 >= x1)      and (x2 <= x1 + w1))
     or ((x1 + w1 >= x2) and (x1 + w1 <= x2 + w2))
     or ((x2 + w2 >= x1) and (x2 + w2 <= x1 + w1)))
                         and
        (((y1 >= y2)     and (y1 <= y2 + h2))
     or ((y2 >= y1)      and (y2 <= y1 + h1))
     or ((y1 + h1 >= y2) and (y1 + h1 <= y2 + h2))
     or ((y2 + h2 >= y1) and (y2 + h2 <= y1 + h1)));
end;

{----------------------------------------------------------------------------}

procedure AI;
  var z, v, j, o: integer;
begin
  {Czas...}
  inc(StatekGracza.czas);

  if StatekGracza.czas > dlugosc * 5 then StatekGracza.czas := round(dlugosc * (5 + 5 / 12))+random(5);

  { Redukuj temperature }
  if StatekGracza.czas mod dlugosc = 0 then
  for j := 1 to ileeksplozji do
  if PokazEksplozje[j].klatka >= 15 then
  begin
    PokazEksplozje[j].klatka := 0;
    PokazEksplozje[j].x := random(320) - eksplozja[1].sx div 2;
    PokazEksplozje[j].y := random(200) - eksplozja[1].sy div 2;
  end;

  if StatekGracza.czas mod dlugosc = 6 then
  begin
    SprFree(tlo);
    SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
    SprLoad('grafika\back' + IntToStr(1 + StatekGracza.czas div dlugosc) + '.spr', tlo);
    PokazujDyskietke := 30;
  end;

  if StatekGracza.czas >= dlugosc * 3.9 then
  begin
    if (StatekGracza.temperatura > 1500) and (StatekGracza.czas mod 5 = 0) then
    StatekGracza.temperatura := 19 * StatekGracza.temperatura div 20;
  end;

  if StatekGracza.czas >= dlugosc * 5 then
  begin
    if WyswietlanyNapis <> 12 then begin
      StatekGracza.zycie := 0;
      SprFree(napis);
      SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
      SprLoad('grafika\zwyc.spr', napis);
      PokazujDyskietke := 10;
      WyswietlanyNapis := 12;
    end;
    CzasWyswietlaniaNapisu := 100;
  end else
  if StatekGracza.czas mod dlugosc > dlugosc - 25 then
  begin
    if WyswietlanyNapis <> 10 then begin
      SprFree(napis);
      SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
      SprLoad('grafika\przys.spr', napis);
      PokazujDyskietke := 10;
      WyswietlanyNapis := 10;
    end;
    CzasWyswietlaniaNapisu := 50;
  end else
  if StatekGracza.zycie <= 0 then
  begin
    if WyswietlanyNapis <> 3 then begin
      SprFree(napis);
      SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
      SprLoad('grafika\koniec.spr', napis);
      PokazujDyskietke := 10;
      WyswietlanyNapis := 3;
    end;
    CzasWyswietlaniaNapisu := 50;
  end else
  if StatekGracza.zycie <= 35 then
  begin
    if WyswietlanyNapis <> 2 then begin
      SprFree(napis);
      SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
      SprLoad('grafika\menergii.spr', napis);
      PokazujDyskietke := 10;
      WyswietlanyNapis := 2;
    end;
    CzasWyswietlaniaNapisu := 15;
  end else if StatekGracza.temperatura > 2450 then
  begin
    if WyswietlanyNapis <> 1 then begin
      SprFree(napis);
      SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
      SprLoad('grafika\temp.spr', napis);
      PokazujDyskietke := 10;
      WyswietlanyNapis := 1;
    end;
    CzasWyswietlaniaNapisu := 10;
  end else if StatekGracza.pancerz <= 0 then
  begin
    if WyswietlanyNapis <> 4 then begin
      SprFree(napis);
      SprPut(319 - dysk.sx, 199 - dysk.sy, dysk);
      SprLoad('grafika\bpancerz.spr', napis);
      PokazujDyskietke := 10;
      WyswietlanyNapis := 4;
    end;
    CzasWyswietlaniaNapisu := 15;
  end;


  if StatekGracza.zycie > 0 then
  begin
  if (StatekGracza.czas mod 7 = 0) and (StatekGracza.temperatura > 2900) then
  begin
    dec(StatekGracza.zycie);
    GrajDzwiek(8);
  end;

  if StatekGracza.temperatura > 4000 then
    StatekGracza.temperatura := 4000;

  if StatekGracza.temperatura > 50 + random(250) then
    dec(StatekGracza.temperatura, 2 + random(10));
  StatekGracza.temperatura := StatekGracza.temperatura - 1 + random(3);

  { Regeneruj zycie i pancerz }
  if (StatekGracza.czas mod 3 = 0) and (StatekGracza.temperatura < 1750) then
    if StatekGracza.zycie < 100 then
    begin
      inc(StatekGracza.zycie);
      GrajDzwiek(6);
    end
      else if StatekGracza.pancerz < 100 then
      begin
        inc(StatekGracza.pancerz);
        GrajDzwiek(7);
      end;
  end;

  { Przesun pociski }
  for z := 1 to ilepociskow do
    pociski[z].y := pociski[z].y - 2 * (4 - pociski[z].jaki);

  { Sztuczna inteligencja kosmitów }
  for z := 1 to 15 do
  if wrogowie[z].aktywny then      { aktywni }
  begin
    case wrogowie[z].numer of
      2: begin {Duch}
           if (wrogowie[z].y > 15) and (wrogowie[z].y < 170) then
           begin
             if (wrogowie[z].vy = 0) then
             begin
               { jesli stoi }
               if wrogowie[z].vx = 0 then
                 if wrogowie[z].x < 160 then wrogowie[z].vx := 2
                                        else wrogowie[z].vx := -2;
               { jesli kolo krawedzi ekranu }
               if (wrogowie[z].x <= 15) or
                  (wrogowie[z].x >= 304 - kosmici[wrogowie[z].numer, 1].sx) or
                  (round(random(100)) = 1) then
                  begin
                    wrogowie[z].vx := 0;
                    wrogowie[z].vy := 2;
                  end;
             end else
             if (wrogowie[z].y mod 10 = 0) then
             begin
               wrogowie[z].vy := 0;
               if wrogowie[z].x < 160 then wrogowie[z].vx := 2
                                        else wrogowie[z].vx := -2;
             end
           end else begin
             wrogowie[z].vy := 2;
             wrogowie[z].vx := 0;
           end;
         end;
      3: begin if wrogowie[z].x > StatekGracza.x then
              dec(wrogowie[z].x) else inc(wrogowie[z].x);
              wrogowie[z].vx := 0;
         end;
      4: begin
           wrogowie[z].vx := random(3) - 1;
           wrogowie[z].vy := 2;
         end;
    end;
    { Przesun w dol wroga }
    inc(wrogowie[z].y, wrogowie[z].vy * (1 + StatekGracza.czas div dlugosc));
    inc(wrogowie[z].x, wrogowie[z].vx);

    if StatekGracza.czas >= dlugosc * 5 then
    begin
      if wrogowie[z].y > 50 then dec(wrogowie[z].sila, random(3));
      if wrogowie[z].y > 120 then wrogowie[z].sila := 0;
        if wrogowie[z].sila <= 0 then
          begin
          { wylacz wroga }
          wrogowie[z].aktywny := false;
          { dodaj eksplozje }
          ostatniaeksplozja := (ostatniaeksplozja + 1) mod ileeksplozji + 1;
          PokazEksplozje[ostatniaeksplozja].klatka := 0;
          PokazEksplozje[ostatniaeksplozja].x :=
            wrogowie[z].x - eksplozja[1]. sx div 2 + kosmici[wrogowie[z].numer, 1].sx div 2;
          PokazEksplozje[ostatniaeksplozja].y :=
            wrogowie[z].y - eksplozja[1]. sy div 2 + kosmici[wrogowie[z].numer, 1].sy div 2;
          GrajDzwiek(1);
        end;
    end;

    { Zniszcz wroga, jesli opuscil ekran }
    if wrogowie[z].y >= 195 then wrogowie[z].aktywny := false;

    { Zderzenia eksplozji z kosmitami }
    for v := 1 to ileeksplozji do
      if (PokazEksplozje[v].klatka >= 1) and
         (PokazEksplozje[v].klatka <= 14) and
         kolizja(PokazEksplozje[v].x, PokazEksplozje[v].y,
                 eksplozja[1].sx, eksplozja[1].sy,
                 wrogowie[z].x, wrogowie[z].y,
                 kosmici[wrogowie[z].numer, 1].sx,
                 kosmici[wrogowie[z].numer, 1].sy) then
      begin
        wrogowie[z].sila := wrogowie[z].sila - PokazEksplozje[v].klatka div 6;
        if wrogowie[z].sila <= 0 then
          begin
          { wylacz wroga }
          if PokazEksplozje[v].rzad >= 3 then inc(StatekGracza.naboje[3], 1);
          if PokazEksplozje[v].rzad >= 2 then inc(StatekGracza.naboje[2], 1);
                                              inc(StatekGracza.naboje[1], 1);
          wrogowie[z].aktywny := false;
          { dodaj eksplozje }
          ostatniaeksplozja := (ostatniaeksplozja + 1) mod ileeksplozji + 1;
          PokazEksplozje[ostatniaeksplozja].rzad := PokazEksplozje[v].rzad + 1;
          PokazEksplozje[ostatniaeksplozja].klatka := 0;
          PokazEksplozje[ostatniaeksplozja].x :=
            wrogowie[z].x - eksplozja[1]. sx div 2 + kosmici[wrogowie[z].numer, 1].sx div 2;
          PokazEksplozje[ostatniaeksplozja].y :=
            wrogowie[z].y - eksplozja[1]. sy div 2 + kosmici[wrogowie[z].numer, 1].sy div 2;
          GrajDzwiek(2);
          { dodaj punkty }
          if StatekGracza.czas <= dlugosc * 5 then
          begin
          ostatniepunkty := (ostatniepunkty + 1) mod 15 + 1;
          PokazPunkty[ostatniepunkty].x := wrogowie[z].x - 10 + random(20);
          PokazPunkty[ostatniepunkty].y := wrogowie[z].y - 10 + random(20);
          PokazPunkty[ostatniepunkty].czas := 50;
          PokazPunkty[ostatniepunkty].ile :=
            intToStr(PokazEksplozje[ostatniaeksplozja].rzad) + ' x '
                     + IntToStr((StatekGracza.czas div dlugosc + 1) * wrogowie[z].numer) + '00';
          inc(StatekGracza.punkty, (StatekGracza.czas div dlugosc + 1)
                                   * wrogowie[z].numer * PokazEksplozje[ostatniaeksplozja].rzad);
          end;
          end;
      end;


    { Zderzenia pocisków z kosmitami }
    for v := 1 to ilepociskow do
    begin
      if kolizja(pociski[v].x, pociski[v].y, 2, 2,
                 wrogowie[z].x, wrogowie[z].y,
                 kosmici[wrogowie[z].numer, 1].sx,
                 kosmici[wrogowie[z].numer, 1].sy) then
      begin
        wrogowie[z].sila := wrogowie[z].sila - ((pociski[v].jaki + 1)* 3);
          if (pociski[v].jaki = 2) or (pociski[v].jaki = 3) then
          begin
          if pociski[v].jaki = 3 then
            for j := 1 to 3 do
              begin
                ostatniaeksplozja := (ostatniaeksplozja + 1) mod ileeksplozji + 1;
                PokazEksplozje[ostatniaeksplozja].rzad := 1;
                PokazEksplozje[ostatniaeksplozja].klatka := -random(10) - 5;
                PokazEksplozje[ostatniaeksplozja].x :=
                  wrogowie[z].x - eksplozja[1]. sx div 2 + kosmici[wrogowie[z].numer, 1].sx div 2 - 20 + random(40);
                PokazEksplozje[ostatniaeksplozja].y :=
                  wrogowie[z].y - eksplozja[1]. sy div 2 + kosmici[wrogowie[z].numer, 1].sy div 2 - 20 + random(40);
              end;
            ostatniaeksplozja := (ostatniaeksplozja + 1) mod ileeksplozji + 1;
            PokazEksplozje[ostatniaeksplozja].rzad := 1;
            PokazEksplozje[ostatniaeksplozja].klatka := 0;
            PokazEksplozje[ostatniaeksplozja].x :=
              wrogowie[z].x - eksplozja[1]. sx div 2 + kosmici[wrogowie[z].numer, 1].sx div 2 - 20 + random(40);
            PokazEksplozje[ostatniaeksplozja].y :=
              wrogowie[z].y - eksplozja[1]. sy div 2 + kosmici[wrogowie[z].numer, 1].sy div 2 - 20 + random(40);
            GrajDzwiek(1);
          end;

        if wrogowie[z].sila <= 0 then
          begin
          { wylacz wroga }
          wrogowie[z].aktywny := false;
          { dodaj eksplozje }
          ostatniaeksplozja := (ostatniaeksplozja + 1) mod ileeksplozji + 1;
          PokazEksplozje[ostatniaeksplozja].rzad := 1;
          PokazEksplozje[ostatniaeksplozja].klatka := 0;
          PokazEksplozje[ostatniaeksplozja].x :=
            wrogowie[z].x - eksplozja[1]. sx div 2 + kosmici[wrogowie[z].numer, 1].sx div 2;
          PokazEksplozje[ostatniaeksplozja].y :=
            wrogowie[z].y - eksplozja[1]. sy div 2 + kosmici[wrogowie[z].numer, 1].sy div 2;
          GrajDzwiek(3);
          { dodaj punkty }
          if StatekGracza.czas <= dlugosc * 5 then
          begin
            ostatniepunkty := (ostatniepunkty + 1) mod 15 + 1;
            PokazPunkty[ostatniepunkty].x := wrogowie[z].x - 10 + random(20);
            PokazPunkty[ostatniepunkty].y := wrogowie[z].y - 10 + random(20);
            PokazPunkty[ostatniepunkty].czas := 50;
            PokazPunkty[ostatniepunkty].ile := intToStr((StatekGracza.czas div dlugosc + 1) * wrogowie[z].numer) + '00';
            inc(StatekGracza.punkty, (StatekGracza.czas div dlugosc + 1) * wrogowie[z].numer);
          end;
          end;
        pociski[v].y := -200;
        end;
      end;

  end else
   if round(random(100)) = 2 then
   begin
     wrogowie[z].numer := random(iluwrogow) + 1;
     wrogowie[z].x := random(319 - kosmici[wrogowie[z].numer, 1].sx);
     wrogowie[z].y := -50;
     wrogowie[z].vx := 0;
     wrogowie[z].vy := 1;

     if StatekGracza.czas mod dlugosc < dlugosc * 2/6 then wrogowie[z].numer := random(2) + 1;
     if StatekGracza.czas mod dlugosc < dlugosc * 1/6 then wrogowie[z].numer := 1;

     if (StatekGracza.czas mod dlugosc > dlugosc * 3/6)
        and (StatekGracza.czas mod dlugosc < dlugosc * 4/6) then wrogowie[z].numer := 2;

     if (StatekGracza.czas mod dlugosc > dlugosc * 4/6)
        and (StatekGracza.czas mod dlugosc < dlugosc * 5/6) then wrogowie[z].numer := 3;

     if (StatekGracza.czas mod dlugosc > dlugosc * 5/6)
        and (StatekGracza.czas mod dlugosc < dlugosc) then wrogowie[z].numer := 4;

     wrogowie[z].sila := (wrogowie[z].numer - 1) * 10 + 3;
     wrogowie[z].aktywny := true;
   end;

   if StatekGracza.zycie > 0 then
    for v := 1 to 15 do
      if wrogowie[v].aktywny and
         Kolizja(StatekGracza.x, StatekGracza.y,
                 statek[1].sx, statek[1].sy,
                 wrogowie[v].x, wrogowie[v].y,
                 kosmici[wrogowie[v].numer, 1].sx,
                 kosmici[wrogowie[v].numer, 1].sy) then
      begin
          wrogowie[v].aktywny := false;
          ostatniepunkty := (ostatniepunkty + 1) mod ileeksplozji + 1;
          PokazEksplozje[ostatniaeksplozja].klatka := 0;
          PokazEksplozje[ostatniaeksplozja].x := wrogowie[v].x - 20 + random(11);
          PokazEksplozje[ostatniaeksplozja].y := wrogowie[v].y - 20 + random(11);
          PokazEksplozje[ostatniaeksplozja].rzad := 4;
          StatekGracza.zycie := StatekGracza.zycie - round((wrogowie[v].sila * wrogowie[v].numer)
                                                                          *(100-StatekGracza.pancerz)/100);
          StatekGracza.pancerz := 2 * StatekGracza.pancerz div 3;
          StatekGracza.temperatura := StatekGracza.temperatura + 150 * wrogowie[v].sila;
          GrajDzwiek(5);
      end;

end;

procedure OdpalPocisk;
begin
  if StatekGracza.zycie <= 0 then exit;
  if StatekGracza.czas >= 5 * dlugosc then exit;
  case StatekGracza.wybranabron of
    1: if StatekGracza.czas mod 2 <> 0 then exit;
    2: if StatekGracza.czas mod 5 <> 0 then exit;
    3: if StatekGracza.czas mod 10 <> 0 then exit;
  end;
  if StatekGracza.wybranabron <> 0 then
    if StatekGracza.naboje[StatekGracza.wybranabron] = 0 then exit else
       dec(StatekGracza.naboje[StatekGracza.wybranabron]);


  ostatnipocisk := (ostatnipocisk + 1) mod ilepociskow + 1;

  Pociski[ostatnipocisk].jaki := StatekGracza.wybranabron;
  Pociski[ostatnipocisk].x := StatekGracza.x + (statek[1].sx - pociskibroni[StatekGracza.wybranabron + 1, 1].sx) div 2;
  Pociski[ostatnipocisk].y := StatekGracza.y;

  case StatekGracza.wybranabron of
    0: StatekGracza.temperatura := StatekGracza.temperatura + 20 + random(20);
    1: StatekGracza.temperatura := StatekGracza.temperatura + 40 + random(10);
    2: StatekGracza.temperatura := StatekGracza.temperatura + 190 + random(20);
    3: StatekGracza.temperatura := StatekGracza.temperatura + 190 + random(20);
  end;

end;

begin
  ClrScr;
  WriteLn('  Michal Lesniewski');
  WriteLn('   KOSMICI ATAKUJA');
  WriteLn('        2oo4');
  delay(1500);
  DzwiekWlaczony := true;
  Powoli := true;
  PokazujDyskietke := 10;
  CzasWyswietlaniaNapisu := 100;
  WyswietlanyNapis := 0;
  initialization;
  ZaladujGrafike;
  delay(3000);
  randomize;
  Resetuj;

  { GRA }
  repeat
    if keypressed then c := ord(readkey) else c := 2;
      if c = ord('s') then DzwiekWlaczony := not DzwiekWlaczony;
      if c = ord('z') then Powoli := not Powoli;
      if c = ord('r') then Resetuj;
      AI;
      if Powoli then
      begin
            retrace;
            retrace;
      end;
      wyswietlgre;
      if DzwiekWlaczony then Odtwarzaj else NoSound;

      PozycjaMyszy(MyszX, MyszY, Przyciski);

      StatekGracza.x := MyszX - (Statek[1].sx shr 1); StatekGracza.y := MyszY;

      if (Przyciski = 1) then OdpalPocisk;
      if (Przyciski = 2) and (StatekGracza.czas mod 3 = 0) then
        StatekGracza.wybranabron := (StatekGracza.wybranabron + 1) mod 4;


  until (ord(c) = 27);
  NoSound;
  TextFat(120, 75, 15, 4, 'KONIEC GRY');
  TextShadow(110, 90, 15, 0, 'Punkty: ' + IntToStr(StatekGracza.punkty) + '00');
  MyszGranice(0, 0, 639, 479);
  bcopy;
  ReadKey;
  WykasujGrafike;
  WriteLn('Twoje punkty: ' + IntToStr(StatekGracza.punkty) + '00');
  finalization;
end.