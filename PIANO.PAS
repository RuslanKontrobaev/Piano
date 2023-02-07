{$G+}
Program Piano;
uses CRT;
const
   arrSize = 24;
   scanCodes: array[1..arrSize] of byte =
              ($2C, $2D, $2E, $2F, $30, $31, $32, {Z, X, C, V, B, N, M}
               $10, $11, $12, $13, $14, $15, $16, {Q, W, E, R, T, Y, U}
               $1F, $20, $22, $23, $24,           {S, D, G, H, J}
               $03, $04, $06, $07, $08);          {2, 3, 5, 6, 7}

   notes: array[1..arrSize] of word =
              ($11D0, $0FDF, $0E23, $0D58, $0BE3, $0A97, $096F,
               $08E8, $07EF, $0711, $06AC, $05F1, $054B, $04B8,
               $10D0, $0EFA, $0C98, $0B39, $09FF,
               $0868, $077D, $064C, $059C, $04FF);

BEGIN
     ClrScr;
     writeln('Program Piano, ver.1.0');
     writeln('Controls:');
     writeln('Z,X,C,V,B,N,M - 1 octave');
     writeln('Q,W,E,R,T,Y,U - 2 octave');
     writeln('S,D,G,H,J - 1 octave #');
     writeln('2,3,5,6,7 - 2 octave #');
     writeln('Esc - exit');
     
     asm
        cld
@clearKbBuf:
	mov   ah,01h
	int   16h
	jz    @clearKbBuf
		
        xor   ah,ah
        int   16h
		
        cmp   ah,01h
        je    @exi

	lea   di,scanCodes
	mov   cx,arrSize

        rol   ax,8
        repne scasb
        jne   @clearKbBuf
{----------Sound on----------}
		lea   ax,scanCodes
        dec   di                    {di - current addr+1 in array}
        sub   di,ax
        shl   di,1
		
        mov   dx,word ptr notes[di]
        mov   al,0B6h               {to get sound}
        out   43h,al                {control register timer}
        mov   al,dl
        out   42h,al                {2 channel timer, counter}
        mov   al,dh
        out   42h,al
        in    al,61h
        or    al,00000011b          {bit0 - T2G(timer gate 2), bit1 - spk}
        out   61h,al
@readScanCode:
        in    al,60h
	or    al,al
	jns   @readScanCode         {if btn unpressed}
{----------Sound off----------}
	in    al, 61h
	and   al, 11111100b
	out   61h,al
	jmp   @clearKbBuf
@exi:
     end;
     ClrScr;
END.
