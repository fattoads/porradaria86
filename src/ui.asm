; ==============================================================================
; MÓDULO: ui.asm
; DESCRIÇÃO: Renderização da interface do usuário (Arena, HUD, Barras de HP e Pausa)
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================
%define UI_ASM

%include "linec.inc"
%include "ui.inc"
%include "game.inc"
%include "player.inc"

global ui_draw_arena
global ui_draw_hud
global ui_draw_pause
global draw_rect_filled
global ui_draw_gameover
global ui_draw_confirm_quit

global WALL_LEFT
global WALL_RIGHT
global FLOOR_Y

; Constantes da interface
PAUSE_X                 equ     230
PAUSE_Y                 equ     220
PAUSE_W                 equ     181
PAUSE_H                 equ     41 

BORDER_TOP_X1           equ     20 
BORDER_TOP_Y1           equ     70 
BORDER_TOP_X2           equ     619
BORDER_TOP_Y2           equ     70 

BORDER_BASE_X1          equ     20 
BORDER_BASE_Y1          equ     460
BORDER_BASE_X2          equ     619
BORDER_BASE_Y2          equ     460

BORDER_LEFT_X1          equ     20 
BORDER_LEFT_Y1          equ     70 
BORDER_LEFT_X2          equ     20 
BORDER_LEFT_Y2          equ     460

BORDER_RIGHT_X1         equ     619
BORDER_RIGHT_Y1         equ     70 
BORDER_RIGHT_X2         equ     619
BORDER_RIGHT_Y2         equ     460

ARENA_TOP_X1            equ     24 
ARENA_TOP_Y1            equ     74 
ARENA_TOP_X2            equ     615
ARENA_TOP_Y2            equ     74 
                    
ARENA_BASE_X1           equ     24 
ARENA_BASE_Y1           equ     456
ARENA_BASE_X2           equ     615
ARENA_BASE_Y2           equ     456
                    
ARENA_LEFT_X1           equ     24 
ARENA_LEFT_Y1           equ     74 
ARENA_LEFT_X2           equ     24 
ARENA_LEFT_Y2           equ     456

ARENA_RIGHT_X1          equ     615 
ARENA_RIGHT_Y1          equ     74  
ARENA_RIGHT_X2          equ     615 
ARENA_RIGHT_Y2          equ     456 

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

msg_title       db "PORRADARIA86", 0
msg_p1          db "JOGADOR 1", 0
msg_p2          db "JOGADOR 2", 0
msg_paused      db "--- PAUSADO ---", 0
msg_gameover    db "GAME OVER", 0
msg_p1_wins     db "PLAYER 1 WINS", 0
msg_p2_wins     db "PLAYER 2 WINS", 0
msg_play_again  db "JOGAR NOVAMENTE? (Y/N)", 0

str_timer       db "180", 0
last_timer      dw 0FFFFh       ; Guarda o último segundo renderizado na tela

msg_confirm_quit db "SAIR DO JOGO? (Y/N)", 0

; ------------------------------------------------------------------------------
; CS
; ------------------------------------------------------------------------------
segment code

; ------------------------------------------------------------------------------
; draw_rect_filled: Desenha um retângulo preenchido na tela.
; Utiliza a cor definida previamente na variável global 'cor'.
; Entrada (via Pilha):
;   [BP+10] = X (Canto superior esquerdo)
;   [BP+8]  = Y (Canto superior esquerdo)
;   [BP+6]  = Largura (Width)
;   [BP+4]  = Altura (Height)
; ------------------------------------------------------------------------------
draw_rect_filled:
    ; Salva estado
    push    bp
    mov     bp, sp
    pushf
    push    ax
    push    bx
    push    cx
    push    dx
    push    si

    mov     cx, [bp+4]          ; CX = Altura (contador do loop de linhas)
    cmp     cx, 0
    jle     .done

    mov     dx, [bp+8]          ; DX = Y atual
    mov     si, [bp+10]         ; SI = X1
    mov     bx, si
    add     bx, [bp+6]
    dec     bx                  ; BX = X2 (X1 + Largura - 1)

.row_loop:
    ; Desenha a linha horizontal de (X1, Y) até (X2, Y)
    push    si                  ; X1
    push    dx                  ; Y1
    push    bx                  ; X2
    push    dx                  ; Y2
    call    line

    inc     dx                  ; Próxima linha (Y++)
    loop    .row_loop

.done:
    ; Restaura estado
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
    pop     bp
    ret     8

; ------------------------------------------------------------------------------
; ui_print_string: Imprime uma string terminada em zero em uma posição da tela.
; Utiliza a cor definida na variável global 'cor'.
; Entrada:
;   SI = Endereço da string
;   DH = Linha do cursor (0 a 29)
;   DL = Coluna do cursor (0 a 79)
; ------------------------------------------------------------------------------
ui_print_string:
    ; Salva estado
    push    ax
    push    bx
    push    dx
    push    si

    mov     bl, [cor]

    ; Posicionando cursor
    mov     ah, 02h             ; Seleciona função de posicionar cursor
    mov     bh, 0               ; Seleciona página de vídeo 0
    int     10h                 ; Chama serviço de vídeo da BIOS

.char_loop:
    lodsb                       ; Carrega o byte de [DS:SI] em AL e incrementa SI
    cmp     al, 0
    je      .done

    ; Imprimindo caractere
    mov     ah, 0Eh             ; Seleciona função de saída de caractere
    mov     bh, 0               ; Seleciona página de vídeo 0
    int     10h                 ; Chama serviço de vídeo da BIOS
    jmp     .char_loop

.done:
    ; Restaura estado
    pop     si
    pop     dx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; ui_draw_arena: Desenha o quadro de bordas duplas da arena e títulos principais.
; ------------------------------------------------------------------------------
ui_draw_arena:
    ; Salva estado
    push    ax

    ; Caso estivermos saindo de uma tela de pausa, é necessário limpar essa tela com um retângulo preto.
    ; Isso é estranho. Vai interferir na visualização dos personagens no primeiro instante de retorno ao jogo.
    ; Não sei se é a solução ideal, mas por enquanto funciona.
    ; --- LIMPA TELA DE PAUSA ---
    mov byte [cor], preto 
    push word PAUSE_X 
    push word PAUSE_Y 
    push word PAUSE_W
    push word PAUSE_H
    call draw_rect_filled

    ; Define cor branca intensa para a moldura da arena
    mov     byte [cor], branco_intenso

    ; --- BORDA EXTERNA ---
    ; Topo
    push    word BORDER_TOP_X1
    push    word BORDER_TOP_Y1
    push    word BORDER_TOP_X2
    push    word BORDER_TOP_Y2
    call    line
    ; Base
    push    word BORDER_BASE_X1 
    push    word BORDER_BASE_Y1 
    push    word BORDER_BASE_X2 
    push    word BORDER_BASE_Y2 
    call    line
    ; Esquerda
    push    word BORDER_LEFT_X1 
    push    word BORDER_LEFT_Y1 
    push    word BORDER_LEFT_X2 
    push    word BORDER_LEFT_Y2 
    call    line
    ; Direita
    push    word BORDER_RIGHT_X1
    push    word BORDER_RIGHT_Y1
    push    word BORDER_RIGHT_X2
    push    word BORDER_RIGHT_Y2
    call    line

    ; --- BORDA INTERNA ---
    ; Topo
    push    word ARENA_TOP_X1            
    push    word ARENA_TOP_Y1            
    push    word ARENA_TOP_X2            
    push    word ARENA_TOP_Y2            
    call    line
    ; Base
    push    word ARENA_BASE_X1           
    push    word ARENA_BASE_Y1           
    push    word ARENA_BASE_X2           
    push    word ARENA_BASE_Y2           
    call    line
    ; Esquerda
    push    word ARENA_LEFT_X1           
    push    word ARENA_LEFT_Y1           
    push    word ARENA_LEFT_X2           
    push    word ARENA_LEFT_Y2           
    call    line
    ; Direita
    push    word ARENA_RIGHT_X1          
    push    word ARENA_RIGHT_Y1          
    push    word ARENA_RIGHT_X2          
    push    word ARENA_RIGHT_Y2          
    call    line

    ; --- TÍTULOS ---
    ; Título Central: PORRADARIA86
    mov     byte [cor], amarelo      ; Cor
    mov     si, msg_title       ; String
    mov     dh, 1               ; Linha
    mov     dl, 34              ; Coluna
    call    ui_print_string

    ; Jogador 1
    mov     byte [cor], cyan_claro   ; Cor
    mov     si, msg_p1          ; String
    mov     dh, 1               ; Linha
    mov     dl, 4               ; Coluna
    call    ui_print_string

    ; Jogador 2
    mov     byte [cor], rosa         ; Cor
    mov     si, msg_p2          ; String
    mov     dh, 1               ; Linha
    mov     dl, 65              ; Coluna
    call    ui_print_string

    mov     word [last_timer], 0FFFFh

    ; Restaura estado
    pop     ax
    ret

; ------------------------------------------------------------------------------
; ui_draw_hud: Renderiza as barras de vida dos dois jogadores.
; As barras vão da cor verde pro amarelo pro vermelho conforme a vida diminui.
; Entrada (via registradores):
;   AL = HP do Jogador 1 (0 a 10)
;   AH = HP do Jogador 2 (0 a 10)
; ------------------------------------------------------------------------------
ui_draw_hud:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx
    push    si

    mov     cl, al              ; CL = HP P1
    mov     ch, ah              ; CH = HP P2

    ; ==========================================================================
    ; BARRA DE HP DO JOGADOR 1 (Diminui da direita para a esquerda)
    ; 10 blocos de 12x16px a partir de X=30, Y=35 (espaçamento = 15px por bloco)
    ; ==========================================================================
    mov     si, 0               ; SI = Índice do bloco (0 a 9)

.loop_p1:
    cmp     si, 10
    jge     .draw_p2

    ; Calcula X do bloco = 30 + SI * 15
    mov     ax, si
    mov     bx, 15
    mul     bx
    add     ax, 30
    mov     dx, ax              ; DX = Pos X do bloco P1

    ; Determina a cor do bloco
    ; Se o índice SI < HP_P1, o bloco está ativo
    mov     bx, si
    cmp     bl, cl
    jge     .p1_block_empty

    ; Bloco Ativo: Escolhe a cor com base no valor atual do HP
    cmp     cl, 6
    jg      .p1_green
    cmp     cl, 3
    jg      .p1_yellow

.p1_red:
    mov     byte [cor], vermelho
    jmp     .draw_p1_block
.p1_yellow:
    mov     byte [cor], amarelo
    jmp     .draw_p1_block
.p1_green:
    mov     byte [cor], verde_claro
    jmp     .draw_p1_block

.p1_block_empty:
    mov     byte [cor], preto           

.draw_p1_block:
    push    dx                  ; X
    push    word 35             ; Y
    push    word 12             ; Largura
    push    word 16             ; Altura
    call    draw_rect_filled

    inc     si
    jmp     .loop_p1

    ; ==========================================================================
    ; BARRA DE HP DO JOGADOR 2 (Diminui da esquerda para a direita)
    ; 10 blocos de 12x16px a partir de X=463, Y=35 (espaçamento = 15px por bloco)
    ; ==========================================================================
.draw_p2:
    mov     si, 0               ; SI = Índice do bloco (0 a 9)

.loop_p2:
    cmp     si, 10
    jge     .draw_rounds

    ; Calcula X do bloco = 463 + SI * 15
    mov     ax, si
    mov     bx, 15
    mul     bx
    add     ax, 463
    mov     dx, ax              ; DX = Pos X do bloco P2

    ; No P2, os blocos da esquerda somem primeiro se o HP cai.
    ; Blocos ativos: índices SI >= (10 - HP_P2)
    mov     al, 10
    sub     al, ch              ; AL = limite inferior ativo (10 - HP)
    mov     bx, si
    cmp     bl, al
    jl      .p2_block_empty

    ; Bloco Ativo: Escolhe a cor com base no valor atual do HP
    cmp     ch, 6
    jg      .p2_green
    cmp     ch, 3
    jg      .p2_yellow

.p2_red:
    mov     byte [cor], vermelho
    jmp     .draw_p2_block
.p2_yellow:
    mov     byte [cor], amarelo
    jmp     .draw_p2_block
.p2_green:
    mov     byte [cor], verde_claro
    jmp     .draw_p2_block

.p2_block_empty:
    mov     byte [cor], preto           

.draw_p2_block:
    push    dx                  ; X
    push    word 35             ; Y
    push    word 12             ; Largura
    push    word 16             ; Altura
    call    draw_rect_filled

    inc     si
    jmp     .loop_p2

; ==========================================================================
; MARCADORES DE ROUNDS VENCIDOS (2 quadrados de 10x10px para cada jogador)
; ==========================================================================
.draw_rounds:
    ; --- JOGADOR 1 (1º Round: X=190 | 2º Round: X=205) ---
    mov     byte [cor], cinza
    cmp     byte [p1 + Player.rounds], 1
    jl      .draw_p1_r1
    mov     byte [cor], amarelo
.draw_p1_r1:
    push    word 190            ; X
    push    word 38             ; Y
    push    word 10             ; Largura
    push    word 10             ; Altura
    call    draw_rect_filled

    mov     byte [cor], cinza
    cmp     byte [p1 + Player.rounds], 2
    jl      .draw_p1_r2
    mov     byte [cor], amarelo
.draw_p1_r2:
    push    word 205            ; X
    push    word 38             ; Y
    push    word 10             ; Largura
    push    word 10             ; Altura
    call    draw_rect_filled

    ; --- JOGADOR 2 (1º Round: X=440 | 2º Round: X=425) ---
    mov     byte [cor], cinza
    cmp     byte [p2 + Player.rounds], 1
    jl      .draw_p2_r1
    mov     byte [cor], amarelo
.draw_p2_r1:
    push    word 440            ; X
    push    word 38             ; Y
    push    word 10             ; Largura
    push    word 10             ; Altura
    call    draw_rect_filled

    mov     byte [cor], cinza
    cmp     byte [p2 + Player.rounds], 2
    jl      .draw_p2_r2
    mov     byte [cor], amarelo
.draw_p2_r2:
    push    word 425            ; X
    push    word 38             ; Y
    push    word 10             ; Largura
    push    word 10             ; Altura
    call    draw_rect_filled

; ==========================================================================
; CRONÔMETRO DO ROUND (Centralizado entre as barras: Linha 2, Coluna 38)
; ==========================================================================
.draw_timer:
    mov     ax, [round_timer]
    cmp     ax, [last_timer]
    je      .done_hud           ; Só redesenha se o segundo mudou

    mov     [last_timer], ax

    ; Garante que o valor não seja negativo antes da divisão
    cmp     ax, 0
    jge     .convert_digits
    mov     ax, 0

.convert_digits:
    ; Centenas: AX / 100 -> AL = Quociente (centena), AH = Resto (0..99)
    mov     bl, 100
    div     bl
    add     al, '0'
    mov     [str_timer], al

    ; Dezenas e Unidades: AH / 10 -> AL = Dezena, AH = Unidade
    mov     al, ah
    xor     ah, ah
    mov     bl, 10
    div     bl
    add     al, '0'
    mov     [str_timer + 1], al
    add     ah, '0'
    mov     [str_timer + 2], ah

    ; Apaga os 3 caracteres anteriores (X = 38*8 = 304, Y = 2*16 = 32, W = 24, H = 16)
    mov     byte [cor], preto
    push    word 304
    push    word 32
    push    word 24
    push    word 16
    call    draw_rect_filled

    ; Imprime o tempo (fica vermelho nos últimos 10 segundos)
    mov     byte [cor], branco_intenso
    cmp     word [round_timer], 10
    jg      .print_time_str
    mov     byte [cor], vermelho

.print_time_str:
    mov     si, str_timer
    mov     dh, 2               ; Linha 2 (Y = 32)
    mov     dl, 38              ; Coluna 38 (X = 304)
    call    ui_print_string

.done_hud:
    ; Restaura estado
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; ui_draw_pause: Desenha uma caixa central com aviso de "PAUSADO".
; ------------------------------------------------------------------------------
ui_draw_pause:
    ; Salva estado
    push    ax
    push    si
    push    dx
    push    bx

    ; Cria retângulo preto para o fundo da caixa de pausa
    mov     byte [cor], preto
    push    word 230            ; X
    push    word 220            ; Y
    push    word 180            ; W
    push    word 40             ; H
    call    draw_rect_filled

    ; Desenha moldura amarela da caixa de pausa
    mov     byte [cor], amarelo

    ; Topo
    push    word 230            ; X
    push    word 220            ; Y
    push    word 410            ; W
    push    word 220            ; H
    call    line
    ; Base
    push    word 230            ; X
    push    word 260            ; Y
    push    word 410            ; W
    push    word 260            ; H
    call    line
    ; Esquerda
    push    word 230            ; X
    push    word 220            ; Y
    push    word 230            ; W
    push    word 260            ; H
    call    line
    ; Direita
    push    word 410            ; X
    push    word 220            ; Y
    push    word 410            ; W
    push    word 260            ; H
    call    line

    ; Imprime o texto "--- PAUSADO ---" (Cor amarela herdada da moldura)
    mov     si, msg_paused      ; String
    mov     dh, 15              ; Linha
    mov     dl, 32              ; Coluna
    call    ui_print_string

    ; Restaura estado
    pop     bx
    pop     dx
    pop     si
    pop     ax
    ret

; ------------------------------------------------------------------------------
; ui_draw_gameover: Desenha o quadro de fim de jogo e anuncia o vencedor.
; Entrada:
;   AL = Vencedor da partida (1 = Jogador 1, 2 = Jogador 2)
; ------------------------------------------------------------------------------
ui_draw_gameover:
    push    ax
    push    bx
    push    dx
    push    si

    mov     bl, al              ; Salva o vencedor (1 ou 2) em BL

    ; Fundo preto da caixa central (X=200, Y=190, W=240, H=110)
    mov     byte [cor], preto
    push    word 200
    push    word 190
    push    word 240
    push    word 110
    call    draw_rect_filled

    ; Moldura branca da caixa
    mov     byte [cor], branco_intenso
    push    word 200
    push    word 190
    push    word 440
    push    word 190
    call    line

    push    word 200
    push    word 300
    push    word 440
    push    word 300
    call    line

    push    word 200
    push    word 190
    push    word 200
    push    word 300
    call    line

    push    word 440
    push    word 190
    push    word 440
    push    word 300
    call    line

    ; Imprime "GAME OVER" (Linha 13, Coluna 35)
    mov     byte [cor], amarelo
    mov     si, msg_gameover
    mov     dh, 13
    mov     dl, 35
    call    ui_print_string

    ; Seleciona a mensagem e a cor do vencedor com base em BL
    cmp     bl, 1
    je      .p1_winner

    mov     byte [cor], rosa
    mov     si, msg_p2_wins
    jmp     .print_winner

.p1_winner:
    mov     byte [cor], cyan_claro
    mov     si, msg_p1_wins

.print_winner:
    ; Imprime "PLAYER X WINS" (Linha 15, Coluna 33)
    mov     dh, 15
    mov     dl, 33
    call    ui_print_string

    ; Imprime "JOGAR NOVAMENTE? (Y/N)" (Linha 17, Coluna 29)
    mov     byte [cor], branco_intenso
    mov     si, msg_play_again
    mov     dh, 17
    mov     dl, 29
    call    ui_print_string

    pop     si
    pop     dx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; ui_draw_confirm_quit: Desenha a caixa central perguntando se deseja sair (Y/N).
; ------------------------------------------------------------------------------
ui_draw_confirm_quit:
    push    ax
    push    bx
    push    dx
    push    si

    ; Cria retângulo preto para o fundo da caixa (mesma área da caixa de pausa)
    mov     byte [cor], preto
    push    word 230            ; X
    push    word 220            ; Y
    push    word 180            ; W
    push    word 40             ; H
    call    draw_rect_filled

    ; Desenha moldura vermelha de alerta
    mov     byte [cor], vermelho
    ; Topo
    push    word 230
    push    word 220
    push    word 410
    push    word 220
    call    line
    ; Base
    push    word 230
    push    word 260
    push    word 410
    push    word 260
    call    line
    ; Esquerda
    push    word 230
    push    word 220
    push    word 230
    push    word 260
    call    line
    ; Direita
    push    word 410
    push    word 220
    push    word 410
    push    word 260
    call    line

    ; Imprime "SAIR DO JOGO? (Y/N)" centralizado na caixa (Linha 15, Coluna 30)
    mov     byte [cor], branco_intenso
    mov     si, msg_confirm_quit
    mov     dh, 15
    mov     dl, 30
    call    ui_print_string

    pop     si
    pop     dx
    pop     bx
    pop     ax
    ret