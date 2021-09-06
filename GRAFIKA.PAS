{ ----------------------------------------------------
        MICHAL LESNIEWSKI
               GRA
         KOSMICI ATAKUJA
  ----------------------------------------------------
         GRAFIKA.PAS
         Procedury graficzne
  ----------------------------------------------------
}

{$I znaki.pas}

type scr = array[0..63999] of byte;

type spr = record
  sx, sy: word;
  pic: ^scr;
end;

var buf: ^scr;
var dek, zw, pamiec: word;


procedure initialization;
begin
  pamiec := memavail;
  dek := 0;
  zw := 0;
  WriteLn('Wolna pamiec ', pamiec, ' b');
  delay(1000);
  getmem(buf, 64000);
  asm
    mov ah, 00h
    mov al, 13h
    int 10h
  end;
end;

procedure finalization;
begin
  freemem(buf, 64000);
  asm
    mov ah, 00h
    mov al, 03h
    int 10h
  end;
  WriteLn('Gra zakonczona.');
  WriteLn('');
  WriteLn('BILANS PAMIECI:');
  WriteLn('Przed uruchomieniem  ', pamiec, ' b');
  WriteLn('Po zakonczeniu       ', memavail, ' b');
  WriteLn('Zmiana               ', abs(pamiec - memavail), ' b');
  WriteLn('W CZASIE DZIALANIA PROGRAMU');
  WriteLn('Zaalokowano ', dek, ' b');
  WriteLn('Zwolniono   ', zw, ' b');
  delay(500);
  ReadKey;
end;

procedure pset(x, y: word; kolor: byte); assembler;
asm
  mov ax, y
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, x
  mov ax, 0a000h
  mov es, ax
  mov al, kolor
  mov byte ptr es:[di], al
end;

Function pget(x, y: word): byte; assembler;
asm
  mov ax, 0a000h
  mov es, ax
  mov dx, y
  mov di, x
  xchg dh, dl
  add di, dx
  shr dx, 2
  add di, dx
  mov al, es:[di]
end;

procedure cls(kolor: byte); assembler;
asm
  mov ax, 0a000h
  mov es, ax
  mov di, 0
  mov cx, 32000
  mov ah, kolor
  mov al, ah
  cld
  rep stosw
end;

procedure bpset(x, y: word; kolor: byte); assembler;
asm
  les bx, buf
  mov ax, y
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, x
  add di, bx
  mov al, kolor
  mov byte ptr es:[di], al
end;

procedure bcls(kolor: byte); assembler;
asm
  les di, buf
  mov cx, 32000
  mov ah, kolor
  mov al, ah
  cld
  rep stosw
end;

procedure bcopy; assembler;
asm
  push ds
  mov ax, 0a000h
  mov es, ax
  mov di, 0
  lds si, buf
  mov cx, 32000
  cld
  rep movsw
  pop ds
end;

procedure retrace; assembler;
asm
  mov dx, 3dah
  @refresh:
  in al, dx
  test al, 00001000b
  jnz @refresh
  @norefresh:
  in al, dx
  test al, 00001000b
  jz @norefresh
end;

procedure palset(kolor, r, g, b: byte);
begin
  port[$3c8] := kolor;
  port[$3c9] := r;
  port[$3c9] := g;
  port[$3c9] := b;
end;

procedure palget(kolor: byte; var r, g, b: byte);
begin
  Port[$3c7] := kolor;
  r := port[$3c9];
  g := port[$3c9];
  b := port[$3c9];
end;

procedure SprGet(x, y, sx, sy: word; var sprite: spr);
  var ix, iy: word;
begin
  sprite.sx := sx;
  sprite.sy := sy;
  getmem(sprite.pic, sx * sy);
  for ix := 0 to (sx - 1) do
    for iy := 0 to (sy - 1) do
      sprite.pic^[ix + iy * sprite.sx] := pget(x + ix, y + iy);
end;

procedure SprPut(x, y: integer; sprite: spr);
  var ix, iy: word;
      xmin, xmax, ymin, ymax: word;
begin
  { prawo, dół }
  if (x > 319) or (y > 199) then exit;
  { lewo, góra }
  if (x + sprite.sx - 1 < 0) or (y + sprite.sy - 1 < 0) then exit;

  { Obetnij krawedzie }
  if x < 0 then xmin := -x else xmin := 0;
  if x + sprite.sx > 319 then xmax := 320 - x else xmax := sprite.sx;
  if y < 0 then ymin := -y else ymin := 0;
  if y + sprite.sy > 199 then ymax := 199 - y else ymax := sprite.sy - 1;

  for iy := ymin to ymax do
  asm
    push ds
    { cel - ustaw na ekran}
    mov ax, y
    add ax, iy
    mov di, ax
    shl ax, 8
    shl di, 6
    add di, ax
    add di, x
    add di, xmin
    mov ax, 0a000h
    mov es, ax
    { źródło - ustaw na sprite}
    lds si, sprite.pic
    { przesuń }
    mov ax, iy
    mul sprite.sx
    add si, ax
    add si, xmin
    { ilość }
    mov cx, xmax
    sub cx, xmin
    cld
    rep movsb
    pop ds
  end;
  {
  for iy := ymin to ymax do
    for ix := xmin to xmax do
      pset(x + ix, y + iy, sprite.pic^[ix + iy * sprite.sx]);
  }
end;

procedure bSprPut(x, y: integer; sprite: spr);
  var ix, iy: word;
      xmin, xmax, ymin, ymax: word;
begin
  { prawo, dół }
  if (x > 319) or (y > 199) then exit;
  { lewo, góra }
  if (x + sprite.sx - 1 < 0) or (y + sprite.sy - 1 < 0) then exit;

  { Obetnij krawedzie }
  if x < 0 then xmin := -x else xmin := 0;
  if x + sprite.sx > 319 then xmax := 320 - x else xmax := sprite.sx;
  if y < 0 then ymin := -y else ymin := 0;
  if y + sprite.sy > 199 then ymax := 199 - y else ymax := sprite.sy - 1;

  for iy := ymin to ymax do
  asm
    push ds
    { cel - ustaw na bufer}
    les bx, buf
    mov ax, y
    add ax, iy
    mov di, ax
    shl ax, 8
    shl di, 6
    add di, ax
    add di, x
    add di, xmin
    add di, bx
    { źródło - ustaw na sprite}
    lds si, sprite.pic
    { przesuń }
    mov ax, iy
    mul sprite.sx
    add si, ax
    add si, xmin
    { ilość }
    mov cx, xmax
    sub cx, xmin
    cld
    rep movsb
    pop ds
  end;
  {
  for iy := ymin to ymax do
    for ix := xmin to xmax do
      buf^[x + ix, y + iy] := sprite.pic^[ix + iy * sprite.sx];
  }
end;

procedure bSprPutTrans(x, y: integer; sprite: spr);
  var ix, iy: word;
      xmin, xmax, ymin, ymax: word;
      l: byte;
      trans: byte;
begin
  { prawo, dół }
  if (x > 319) or (y > 199) then exit;
  { lewo, góra }
  if (x + sprite.sx - 1 < 0) or (y + sprite.sy - 1 < 0) then exit;

  { Obetnij krawedzie }
  if x < 0 then xmin := -x else xmin := 0;
  if x + sprite.sx > 319 then xmax := 320 - x else xmax := sprite.sx;
  if y < 0 then ymin := -y else ymin := 0;
  if y + sprite.sy > 199 then ymax := 199 - y else ymax := sprite.sy - 1;

  trans := sprite.pic^[0];

  for iy := ymin to ymax do
  asm
    push ds
    { cel - ustaw na bufer}
    les bx, buf
    mov ax, y
    add ax, iy
    mov di, ax
    shl ax, 8
    shl di, 6
    add di, ax
    add di, x
    add di, xmin
    add di, bx
    { źródło - ustaw na sprite}
    lds si, sprite.pic
    { przesuń }
    mov ax, iy
    mul sprite.sx
    add si, ax
    add si, xmin
    { ilość }
    mov cx, xmax
    sub cx, xmin
    mov ah, trans;
    {  RYSOWANIE }
    @nextpoint:
    mov al, byte ptr ds:[si]
    cmp al, ah
    jz @transparent

    mov byte ptr es:[di], al

    @transparent:
    inc di
    inc si
    loop @nextpoint
    pop ds
  end;
end;

procedure SprFree(var sprite: spr);
begin
  if (sprite.sx > 0) and (sprite.sy > 0) then
  freemem(sprite.pic, sprite.sx * sprite.sy);
  zw := zw + sprite.sx * sprite.sy;
  sprite.sx := 0;
  sprite.sy := 0;
end;

procedure SprSave(fn: string; sprite: spr);
  var sf: File;
begin
  Assign(sf, fn);
  Rewrite(sf, 1);
  Seek(sf, 0);
  BlockWrite(sf, sprite, 4);
  seek(sf, 4);
  BlockWrite(sf, sprite.pic^[0], sprite.sx * sprite.sy);
  Close(sf);
end;

procedure SprLoad(fn: string; var sprite: spr);
  var sf: File;
begin
  Assign(sf, fn);
  Reset(sf, 1);
  Seek(sf, 0);
  BlockRead(sf, sprite, 4);
  seek(sf, 4);
  if maxavail < sprite.sx * sprite.sy then
  begin
    finalization;
    WriteLn('BRAK PAMIECI!');
    readkey;
    halt;
  end;
  getmem(sprite.pic, sprite.sx * sprite.sy);
  dek := dek + sprite.sx * sprite.sy;
  BlockRead(sf, sprite.pic^[0], sprite.sx * sprite.sy);
  Close(sf);
end;

procedure SprHor(var sprite: spr);
var x, y: word;
    b: byte;
begin
  for y := 0 to (sprite.sy - 1) do
    for x := 0 to (sprite.sx div 2 - 1) do
    begin
      b := sprite.pic^[x + y * sprite.sx];
      sprite.pic^[x + y * sprite.sx] := sprite.pic^[-x - 1 + (y + 1) * sprite.sx];
      sprite.pic^[-x - 1 + (y + 1) * sprite.sx] := b;
    end;
end;

procedure PalSave(fn: string);
  var sf: File;
      pos: byte;
      k: array[1..3] of byte;
begin
  Assign(sf, fn);
  Rewrite(sf, 1);
  for pos := 0 to 255 do
  begin
    palget(pos, k[1], k[2], k[3]);
    Seek(sf, pos * 3);
    BlockWrite(sf, k[1], 3);
  end;
  Close(sf);
end;

procedure PalLoad(fn: string);
  var sf: File;
      pos: byte;
      k: array[1..3] of byte;
begin
  Assign(sf, fn);
  Reset(sf, 1);
  for pos := 0 to 255 do
  begin
    Seek(sf, pos * 3);
    BlockRead(sf, k[1], 3);
    palset(pos, k[1], k[2], k[3]);
  end;
  Close(sf);
end;

procedure PalDark(r: real);
var pos: byte;
    k: array[1..3] of byte;
begin
  for pos := 0 to 255 do
  begin
    palget(pos, k[1], k[2], k[3]);
    palset(pos, trunc(k[1] * r), trunc(k[2] * r), trunc(k[3] * r));
  end;
end;

procedure PalGray;
var pos: byte;
    k: array[1..3] of byte;
    w: byte;
begin
  for pos := 0 to 255 do
  begin
    palget(pos, k[1], k[2], k[3]);
    w := round((k[1] + k[2] + k[3]) / 3);
    palset(pos, w, w, w);
  end;
end;

procedure Text(x, y: word; kolor: byte ; tekst: string);
var max: byte;
    znak, bajt, bit: byte;
    posx, posy: word;
    index: byte;
    mask: byte;
    prs: word;
begin
  if y + 8 > 199 then exit;
  posx := x;
  posy := y;
  max := ord(tekst[0]);
  prs := y * 320 + x;
  for znak := 1 to max do
  begin
    { spacja }
    if tekst[znak] = ' ' then
    begin
      posx := posx + 8;
      prs := prs + 8;
      continue;
    end;
    { znaki specjalne }
    if tekst[znak] = '.' then index := 0 else
    if tekst[znak] = '-' then index := 63 else
    if tekst[znak] = '+' then index := 64 else
    if tekst[znak] = ',' then index := 65 else
    if tekst[znak] = '/' then index := 66 else
    if tekst[znak] = '*' then index := 67 else
    if tekst[znak] = ':' then index := 68 else
    if tekst[znak] = '=' then index := 69 else
    if tekst[znak] = '_' then index := 70 else
    { cyfry }
    if (tekst[znak] >= '0') and (tekst[znak] <= '9') then index := ord(tekst[znak]) - 47
    else
    { litery wielkie }
    if (tekst[znak] >= 'A') and (tekst[znak] <= 'Z') then index := ord(tekst[znak]) - 54
    else
    { litery małe }
    if (tekst[znak] >= 'a') and (tekst[znak] <= 'z') then index := ord(tekst[znak]) - 60
    else index := 71;
    mask := $80;
    for bajt := 0 to 7 do
    begin
      for bit := 0 to 7 do
      begin
        if (znaki[index][bajt] and mask) <> 0 then
        asm
          les di, buf
          add di, prs
          mov ah, kolor
          mov byte ptr es:[di], ah
        end;
        mask := mask shr 1;
        inc(prs);
      end;
      prs := prs + 312;
      mask := $80;
    end;
    posx := posx + 8;
    if posx > 312 then exit;
    prs := posy * 320 + posx;
  end;
end;

procedure TextShadow(x, y: word; tc, sc: byte; t: string);
begin
  Text(x + 1, y + 1, sc, t);
  Text(x, y, tc, t);
end;

procedure TextFat(x, y: word; tc, fc: byte; t: string);
begin
  Text(x + 1, y, fc, t);
  Text(x, y + 1, fc, t);
  Text(x - 1, y, fc, t);
  Text(x, y - 1, fc, t);

  Text(x + 1, y + 1, fc, t);
  Text(x - 1, y + 1, fc, t);
  Text(x + 1, y - 1, fc, t);
  Text(x - 1, y - 1, fc, t);

  Text(x, y, tc, t);
end;
