; versão de 10/05/2007
; corrigido erro de arredondamento na rotina line.
; circle e full_circle DISPonibilizados por JEfferson Moro em 10/2009
; 
; ALTERAÇÕES: Enrico Polez, Felipe Bruno, Vitor Tomé
;   Adaptação para uso como módulo no projeto (removendo código de teste e suas variáveis, exportando funções)
;	Diversas otimizações

; ver linec.inc para entender a necessidade dessa linha
%define LINEC_ASM

%include "linec.inc"
%include "video.inc"

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global cursor
global caracter
global plot_xy
global circle
global full_circle
global line
global cor

segment code

; ------------------------------------------------------------------------------
; cursor: Define a posição (X, Y) em pixels onde o texto será desenhado.
; Entrada (via pilha): [BP+6] = X, [BP+4] = Y
; ------------------------------------------------------------------------------
cursor:
    push    bp
    mov     bp, sp
    push    ax

    mov     ax, [bp+6]
    mov     [cursor_x], ax
    mov     ax, [bp+4]
    mov     [cursor_y], ax

    pop     ax
    pop     bp
    ret     4

; ------------------------------------------------------------------------------
; caracter: Desenha os pixels de um caractere ASCII nos buffers de RAM via plot_xy
; Entrada: AL = Código ASCII do caractere (ex: 'A')
; Utiliza a cor definida na variável global [cor]
; ------------------------------------------------------------------------------
caracter:
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di
    push    bp
    push    es

    push    ax                  ; Salva AL (caractere ASCII) na pilha

    ; 1. Consulta o ponteiro da tabela de fonte 8x8 na ROM do BIOS
    ; Retorna ES:BP apontando para o início da matriz de fontes 8x8
    mov     ax, 1130h
    mov     bh, 03h             ; BH = 3 (fonte 8x8)
    int     10h

    pop     ax                  ; Restaura AL = código ASCII
    xor     ah, ah              ; AX = código ASCII (0..255)

    ; 2. Calcula offset do caractere na ROM: BP = BP + (ASCII * 8)
    shl     ax, 3               ; AX = ASCII * 8 (cada caractere tem 8 bytes)
    add     bp, ax              ; ES:BP aponta para os 8 bytes do caractere

    ; 3. Percorre as 8 linhas verticais da matriz de pixels
    mov     si, 0               ; SI = linha vertical (0 a 7)

.row_loop:
    cmp     si, 8
    jge     .done_char

    mov     dl, [es:bp+si]      ; DL = byte com os 8 pixels da linha
    mov     cx, 0               ; CX = coluna horizontal (0 a 7)

.bit_loop:
    cmp     cx, 8
    jge     .next_row

    ; Testa se o bit 7 está ativo (pixel aceso)
    test    dl, 80h
    jz      .skip_pixel

    ; Pixel aceso: calcula posição e chama plot_xy(cursor_x + CX, cursor_y + SI)
    mov     ax, [cursor_x]
    add     ax, cx
    push    ax                  ; Param X

    mov     ax, [cursor_y]
    add     ax, si
    push    ax                  ; Param Y

    call    plot_xy             ; Desenha no buffer off-screen em RAM!

.skip_pixel:
    shl     dl, 1               ; Desloca para o próximo bit (Bit 6 vira Bit 7)
    inc     cx
    jmp     .bit_loop

.next_row:
    inc     si
    jmp     .row_loop

.done_char:
    ; 4. Avança a posição X do cursor em 8 pixels para o próximo caractere
    add     word [cursor_x], 8

    pop     es
    pop     bp
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret
	
; ------------------------------------------------------------------------------
; plot_xy: Altera a cor de um pixel (X, Y) nos buffers de RAM off-screen.
; Entrada (via pilha): [BP+6] = X (0..639), [BP+4] = Y (0..479)
; ------------------------------------------------------------------------------
plot_xy:
    push    bp
    mov     bp, sp
    push    ax
    push    bx
    push    cx
    push    dx
	push	es

    ; Calcula offset nos buffers: BX = (Y * 80) + (X / 8)
    mov     ax, [bp+4]          ; AX = Y
    mov     bx, 80
    mul     bx                  ; AX = Y * 80
    mov     bx, [bp+6]          ; BX = X
    shr     bx, 3               ; BX = X / 8
    add     bx, ax              ; BX = Offset (0 a 38399)

    ; Calcula a bitmask (AH) e sua inversa (AL)
    mov     cx, [bp+6]
    and     cl, 7               ; CL = X % 8
    mov     ah, 80h				; Inicializamos com 1 na posição mais à esquerda e deslocamos CL unidades à direita
    shr     ah, cl              ; AH = Bit desejado (ex: 10000000b)
    mov     al, ah
    not     al                  ; AL = Mascara limpa (ex: 01111111b)

    mov     dl, [cor]           ; DL = Cor atual (0 a 15)

    ; --- PLANO 0 (Bit 0 da cor) ---
	mov		es, [plane0_seg]
    and     byte [es:bx], al   ; Limpa o byte atual
    test    dl, 01h                      ; Testa se o Bit 0 da cor é 1
    jz      .check_p1
    or      byte [es:bx], ah   ; Liga o bit alvo se for 1

.check_p1:
    ; --- PLANO 1 (Bit 1 da cor) ---
	mov		es, [plane1_seg]
    and     byte [es:bx], al
    test    dl, 02h
    jz      .check_p2
    or      byte [es:bx], ah

.check_p2:
    ; --- PLANO 2 (Bit 2 da cor) ---
	mov		es, [plane2_seg]
    and     byte [es:bx], al
    test    dl, 04h
    jz      .check_p3
    or      byte [es:bx], ah

.check_p3:
    ; --- PLANO 3 (Bit 3 da cor) ---
	mov		es, [plane3_seg]
    and     byte [es:bx], al
    test    dl, 08h
    jz      .done
    or      byte [es:bx], ah

.done:
	pop		es
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    pop     bp
    ret     4

;-----------------------------------------------------------------------------
;função line
; Parametros:
;	PUSH x1; PUSH y1; PUSH x2; PUSH y2; CALL line;  (x<639, y<479)
line:
		PUSH	BP
		MOV		BP,SP
		PUSHf             		;coloca os flags na pilha
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		MOV		AX,[BP+10]   	;resgata os vALores das coordenadas
		MOV		BX,[BP+8]    	;resgata os vALores das coordenadas
		MOV		CX,[BP+6]    	;resgata os vALores das coordenadas
		MOV		DX,[BP+4]    	;resgata os vALores das coordenadas
		CMP		AX,CX
		JE		line2
		JB		line1
		XCHG	AX,CX
		XCHG	BX,DX
		JMP		line1
line2:							;deltax = 0
		CMP		BX,DX  			;Subtrai DX de BX
		JB		line3
		XCHG	BX,DX        	;troca os valores de BX e DX entre eles
line3:							;DX > BX
		PUSH	AX
		PUSH	BX
		CALL 	plot_xy
		CMP		BX,DX
		JNE		line31
		JMP		fim_line
line31:	INC		BX
		JMP		line3
;deltax <>0
line1:
;Comparar módulos de deltax e deltay sabendo que CX>AX
	; CX > AX
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		JA		line32
		NEG		DX
line32:		
		MOV		[deltay],DX
		POP		DX

		PUSH	AX
		MOV		AX,[deltax]
		CMP		AX,[deltay]
		POP		AX
		JB		line5
; CX > AX e deltax>deltay
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,AX
line4:
		PUSH	AX
		PUSH	DX
		PUSH	SI
		SUB		SI,AX	;(x-x1)
		MOV		AX,[deltay]
		IMUL	SI
		MOV		SI,[deltax]		;arredondar
		SHR		SI,1
;Se numerador (DX)>0 soma se <0 Subtrai
		CMP		DX,0
		JL		ar1
		ADD		AX,SI
		ADC		DX,0
		JMP		arc1
ar1:	SUB		AX,SI
		SBB		DX,0
arc1:
		IDIV	word [deltax]
		ADD		AX,BX
		POP		SI
		PUSH	SI
		PUSH	AX
		CALL	plot_xy
		POP		DX
		POP		AX
		CMP		SI,CX
		JE		fim_line
		INC		SI
		JMP		line4

line5:	CMP		BX,DX
		JB 		line7
		XCHG	AX,CX
		XCHG	BX,DX
line7:
		PUSH	CX
		SUB		CX,AX
		MOV		[deltax],CX
		POP		CX
		PUSH	DX
		SUB		DX,BX
		MOV		[deltay],DX
		POP		DX

		MOV		SI,BX
line6:
		PUSH	DX
		PUSH	SI
		PUSH	AX
		SUB		SI,BX	;(y-y1)
		MOV		AX,[deltax]
		IMUL	SI
		MOV		SI,[deltay]		;arredondar
		SHR		SI,1
;Se numerador (DX)>0 soma se <0 subtrai
		CMP		DX,0
		JL		ar2
		ADD		AX,SI
		ADC		DX,0
		JMP		arc2
ar2:	SUB		AX,SI
		SBB		DX,0
arc2:
		IDIV	word [deltay]
		MOV		DI,AX
		POP		AX
		ADD		DI,AX
		POP		SI
		PUSH	DI
		PUSH	SI
		CALL	plot_xy
		POP		DX
		CMP		SI,DX
		JE		fim_line
		INC		SI
		JMP		line6

fim_line:
		POP		DI
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		POPf
		POP		BP
		RET		8
;*******************************************************************
segment data


cursor_x		dw		0
cursor_y		dw		0
deltax			dw		0
deltay			dw		0	
cor		        db		branco_intenso
;*************************************************************************
