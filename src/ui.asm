; ==============================================================================
; MÓDULO: ui.asm
; DESCRIÇÃO: Renderização da interface do usuário (Arena, HUD, Barras de HP e Pausa)
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%include "linec.inc"

global ui_draw_arena
global ui_draw_hud
global ui_draw_pause
global draw_rect_filled

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

msg_title       db "PORRADARIA86", 0
msg_p1          db "JOGADOR 1", 0
msg_p2          db "JOGADOR 2", 0
msg_paused      db "--- PAUSADO ---", 0

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
    push word 230               ; X 
    push word 220               ; Y 
    push word 181               ; W
    push word 41                ; H
    call draw_rect_filled

    ; Define cor branca intensa para a moldura da arena
    mov     byte [cor], branco_intenso

    ; --- BORDA EXTERNA ---
    ; Topo
    push    word 20             ; X1
    push    word 70             ; Y1
    push    word 619            ; X2
    push    word 70             ; Y2
    call    line
    ; Base
    push    word 20             ; X1
    push    word 460            ; Y1
    push    word 619            ; X2
    push    word 460            ; Y2
    call    line
    ; Esquerda
    push    word 20             ; X1
    push    word 70             ; Y1
    push    word 20             ; X2
    push    word 460            ; Y2
    call    line
    ; Direita
    push    word 619            ; X1
    push    word 70             ; Y1
    push    word 619            ; X2
    push    word 460            ; Y2
    call    line

    ; --- BORDA INTERNA ---
    ; Topo
    push    word 24             ; X1
    push    word 74             ; Y1
    push    word 615            ; X2
    push    word 74             ; Y2
    call    line
    ; Base
    push    word 24             ; X1
    push    word 456            ; Y1
    push    word 615            ; X2
    push    word 456            ; Y2
    call    line
    ; Esquerda
    push    word 24             ; X1
    push    word 74             ; Y1
    push    word 24             ; X2
    push    word 456            ; Y2
    call    line
    ; Direita
    push    word 615            ; X1
    push    word 74             ; Y1
    push    word 615            ; X2
    push    word 456            ; Y2
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
    jge     .done_hud

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