{ ----------------------------------------------------
        MICHAL LESNIEWSKI
               GRA
         KOSMICI ATAKUJA
  ----------------------------------------------------
         MYSZ.PAS
         Obsluga myszy
  ----------------------------------------------------
}


var MyszX, MyszY, Przyciski: integer;

Function JestMysz: boolean;
  var pom:integer;
begin
  asm
    MOV AX,0
    INT $33
    MOV pom,AX
  end;
  JestMysz := (pom<>0);
end;

Function MyszPrzycisk(nr: integer): boolean;
var pom :integer;
begin
  asm
   MOV AX,3
   INT $33
   MOV pom,BX
  end;
  MyszPrzycisk := (pom = nr);
end;

Procedure PozycjaMyszy(var x, y, przyciski: integer);
  var p1, p2, p3: integer;
begin
  asm
    MOV AX,3
    INT $33
    MOV p1,CX
    MOV p2,DX
    MOV p3,BX
   end;
 x := p1;
 y := p2;
 przyciski := p3;
end;

Procedure MyszGranice(x_min, y_min, x_max, y_max: integer);
begin
 asm
  MOV AX,7
  MOV CX,x_min
  MOV DX,x_max
  INT $33

  MOV AX,8
  MOV CX,y_min
  MOV DX,y_max
  INT $33
 end
end;

Procedure UstawMysz(x, y: integer);
begin
  asm
    MOV AX,4
    MOV CX,x
    MOV DX,y
    INT $33
  end;
end;