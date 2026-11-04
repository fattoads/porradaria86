; ==============================================================================
; MÓDULO: player.asm
; DESCRIÇÃO: Armazena o estado dos lutadores (p1 e p2), gerencia a entrada de
;             teclado dos jogadores e renderiza os personagens na tela.
; AUTORIA: Enrico Polez Ferreira Pinto
; ==============================================================================

%define PLAYER_ASM

%include "kbd.inc"
%include "linec.inc"
%include "player.inc"
%include "action.inc"
%include "ui.inc"

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global p1
global p2
global player_init
global player_erase_all
global player_draw_all
global player_update_input

; ------------------------------------------------------------------------------
; SEGMENTO DE DADOS (data)
; ------------------------------------------------------------------------------
segment data

; Alocação física das estruturas dos dois lutadores
p1: resb Player.size
p2: resb Player.size

; ------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO (code)
; ------------------------------------------------------------------------------
segment code

; ------------------------------------------------------------------------------
; player_init: Inicializa os valores padrão das estruturas p1 e p2.
; ------------------------------------------------------------------------------
player_init:
    push    ax

    ; Chama inicialização do módulo de ação
    call    action_init

    ; --- JOGADOR 1 ---
    mov     word [p1 + Player.x], P1_START_X
    mov     word [p1 + Player.y], FLOOR_Y - 1
    mov     word [p1 + Player.old_x], P1_START_X
    mov     word [p1 + Player.old_y], FLOOR_Y - 1
    mov     word [p1 + Player.vx], 0
    mov     word [p1 + Player.vy], 0
    mov     byte [p1 + Player.hp], PLAYER_MAX_HP
    mov     byte [p1 + Player.state], STATE_IDLE
    mov     byte [p1 + Player.dir], DIR_RIGHT
    mov     byte [p1 + Player.color], cyan_claro
    mov     byte [p1 + Player.rounds], 0
    mov     byte [p1 + Player.is_grounded], 1
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p1 + Player.stun_timer], 0

    ; --- JOGADOR 2 ---
    mov     word [p2 + Player.x], P2_START_X
    mov     word [p2 + Player.y], FLOOR_Y - 1
    mov     word [p2 + Player.old_x], P2_START_X
    mov     word [p2 + Player.old_y], FLOOR_Y - 1
    mov     word [p2 + Player.vx], 0
    mov     word [p2 + Player.vy], 0
    mov     byte [p2 + Player.hp], PLAYER_MAX_HP
    mov     byte [p2 + Player.state], STATE_IDLE
    mov     byte [p2 + Player.dir], DIR_LEFT
    mov     byte [p2 + Player.color], rosa
    mov     byte [p2 + Player.rounds], 0
    mov     byte [p2 + Player.is_grounded], 1
    mov     byte [p2 + Player.attack_active], 0
    mov     byte [p2 + Player.stun_timer], 0

    pop     ax
    ret

; ------------------------------------------------------------------------------
; player_update_input: Lê os scan codes do teclado e atualiza as intenções
;                      de movimento e ataque de p1 e p2.
; ------------------------------------------------------------------------------
player_update_input:
    push    ax

    ; ==========================================================================
    ; INPUT JOGADOR 1 (W, A, S, D, T)
    ; ==========================================================================
    cmp     byte [p1 + Player.stun_timer], 0
    jne     .update_p2_input

    mov     word [p1 + Player.vx], 0        ; Reseta velocidade horizontal por padrão

    ; Se está em ataque ou levando golpe, ignora novos inputs de movimento
    cmp     byte [p1 + Player.state], STATE_ATTACK
    je      .update_p2_input
    cmp     byte [p1 + Player.state], STATE_HIT
    je      .update_p2_input

    ; Tecla A: Esquerda
    mov     al, SCANCODE_A
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_check_d
    mov     word [p1 + Player.vx], -3
    mov     byte [p1 + Player.dir], DIR_LEFT
    jmp     .p1_check_jump

.p1_check_d:
    ; Tecla D: Direita
    mov     al, SCANCODE_D
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_check_jump
    mov     word [p1 + Player.vx], 3
    mov     byte [p1 + Player.dir], DIR_RIGHT

.p1_check_jump:
    ; Tecla W: Pulo
    mov     al, SCANCODE_W
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_check_attack
    cmp     byte [p1 + Player.is_grounded], 1
    jne     .p1_check_attack
    mov     word [p1 + Player.vy], JUMP_IMPULSE
    mov     byte [p1 + Player.is_grounded], 0
    mov     byte [p1 + Player.state], STATE_JUMP

.p1_check_attack:
    ; Tecla T: Soco / Ataque
    mov     al, SCANCODE_T
    call    is_key_pressed
    cmp     al, 1
    jne     .update_p2_input
    
    ; Só dispara novo ataque se o timer de ataque anterior tiver chegado a 0
    cmp     byte [p1 + Player.attack_timer], 0
    jne     .update_p2_input

    ; Dispara o golpe: entra em STATE_ATTACK e inicia o timer no total (12 frames).
    ; A hitbox (attack_active) inicia em 0 durante a fase de Startup (frames 12..10)!
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p1 + Player.attack_timer], ATTACK_TOTAL_DURATION
    mov     byte [p1 + Player.state], STATE_ATTACK

    ; ==========================================================================
    ; INPUT JOGADOR 2 (Setas Cima, Esquerda, Direita, Baixo, M)
    ; ==========================================================================
.update_p2_input:
    cmp     byte [p2 + Player.stun_timer], 0
    jne     .done_input

    mov     word [p2 + Player.vx], 0        ; Reseta velocidade horizontal por padrão

    ; Se está em ataque ou levando golpe, ignora novos inputs de movimento
    cmp     byte [p2 + Player.state], STATE_ATTACK
    je      .done_input
    cmp     byte [p2 + Player.state], STATE_HIT
    je      .done_input

    ; Seta Esquerda
    mov     al, SCANCODE_LEFT
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_check_right
    mov     word [p2 + Player.vx], -3
    mov     byte [p2 + Player.dir], DIR_LEFT
    jmp     .p2_check_jump

.p2_check_right:
    ; Seta Direita
    mov     al, SCANCODE_RIGHT
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_check_jump
    mov     word [p2 + Player.vx], 3
    mov     byte [p2 + Player.dir], DIR_RIGHT

.p2_check_jump:
    ; Seta Cima: Pulo
    mov     al, SCANCODE_UP
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_check_attack
    cmp     byte [p2 + Player.is_grounded], 1
    jne     .p2_check_attack
    mov     word [p2 + Player.vy], JUMP_IMPULSE
    mov     byte [p2 + Player.is_grounded], 0
    mov     byte [p2 + Player.state], STATE_JUMP

.p2_check_attack:
    ; Tecla M: Soco / Ataque P2
    mov     al, SCANCODE_M
    call    is_key_pressed
    cmp     al, 1
    jne     .done_input

    ; Só dispara novo ataque se o timer de ataque anterior tiver chegado a 0
    cmp     byte [p2 + Player.attack_timer], 0
    jne     .done_input

    ; Dispara o golpe: entra em STATE_ATTACK e inicia o timer no total (12 frames).
    mov     byte [p2 + Player.attack_active], 0
    mov     byte [p2 + Player.attack_timer], ATTACK_TOTAL_DURATION
    mov     byte [p2 + Player.state], STATE_ATTACK

.done_input:
    pop     ax
    ret

; ------------------------------------------------------------------------------
; player_erase_all: Apaga as posições anteriores dos jogadores (com a cor preta).
; ------------------------------------------------------------------------------
player_erase_all:
    push    ax
    push    bx

    mov     byte [cor], preto

    ; Apaga P1 no old_x, old_y
    push    word [p1 + Player.old_x]
    mov     ax, [p1 + Player.old_y]
    sub     ax, 60
    push    ax
    push    word 8
    call    full_circle

    mov     ax, [p1 + Player.old_y]
    sub     ax, 50
    mov     bx, [p1 + Player.old_y]
    sub     bx, 20
    push    word [p1 + Player.old_x]
    push    ax
    push    word [p1 + Player.old_x]
    push    bx
    call    line

    mov     ax, [p1 + Player.old_x] 
    sub     ax, 10 
    push    ax 
    push    word [p1 + Player.old_y] 
    push    word [p1 + Player.old_x] 
    push    bx 
    call    line

    mov     ax, [p1 + Player.old_x] 
    add     ax, 10 
    push    ax 
    push    word [p1 + Player.old_y] 
    push    word [p1 + Player.old_x] 
    push    bx 
    call    line

    ; Apaga P2 no old_x, old_y
    push    word [p2 + Player.old_x]
    mov     ax, [p2 + Player.old_y]
    sub     ax, 60
    push    ax
    push    word 8
    call    full_circle

    mov     ax, [p2 + Player.old_y]
    sub     ax, 50
    mov     bx, [p2 + Player.old_y]
    sub     bx, 20
    push    word [p2 + Player.old_x]
    push    ax
    push    word [p2 + Player.old_x]
    push    bx
    call    line

    mov     ax, [p2 + Player.old_x] 
    sub     ax, 10 
    push    ax 
    push    word [p2 + Player.old_y] 
    push    word [p2 + Player.old_x] 
    push    bx 
    call    line

    mov     ax, [p2 + Player.old_x] 
    add     ax, 10 
    push    ax 
    push    word [p2 + Player.old_y] 
    push    word [p2 + Player.old_x] 
    push    bx 
    call    line

    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; player_draw_all: Desenha p1 e p2 nas coordenadas atuais e atualiza old_x/old_y.
; ------------------------------------------------------------------------------
player_draw_all:
    push    ax
    push    bx

    ; --- DESENHA JOGADOR 1 ---
    mov     al, [p1 + Player.color]
    mov     byte [cor], al

    ; Cabeça
    push    word [p1 + Player.x]
    mov     ax, [p1 + Player.y]
    sub     ax, 60
    push    ax
    push    word 8
    call    full_circle

    ; Tronco
    mov     ax, [p1 + Player.y]
    sub     ax, 50
    mov     bx, [p1 + Player.y]
    sub     bx, 20
    push    word [p1 + Player.x]
    push    ax
    push    word [p1 + Player.x]
    push    bx
    call    line

    ; Pernas
    mov     ax, [p1 + Player.x] 
    sub     ax, 10 
    push    ax 
    push    word [p1 + Player.y] 
    push    word [p1 + Player.x] 
    push    bx 
    call    line

    mov     ax, [p1 + Player.x] 
    add     ax, 10 
    push    ax 
    push    word [p1 + Player.y] 
    push    word [p1 + Player.x] 
    push    bx 
    call    line

    ; Atualiza coordenadas anteriores para a próxima borracha
    mov     ax, [p1 + Player.x]
    mov     [p1 + Player.old_x], ax
    mov     ax, [p1 + Player.y]
    mov     [p1 + Player.old_y], ax

    ; --- DESENHA JOGADOR 2 ---
    mov     al, [p2 + Player.color]
    mov     byte [cor], al

    ; Cabeça
    push    word [p2 + Player.x]
    mov     ax, [p2 + Player.y]
    sub     ax, 60
    push    ax
    push    word 8
    call    full_circle

    ; Tronco
    mov     ax, [p2 + Player.y]
    sub     ax, 50
    mov     bx, [p2 + Player.y]
    sub     bx, 20
    push    word [p2 + Player.x]
    push    ax
    push    word [p2 + Player.x]
    push    bx
    call    line

    ; Pernas
    mov     ax, [p2 + Player.x] 
    sub     ax, 10 
    push    ax 
    push    word [p2 + Player.y] 
    push    word [p2 + Player.x] 
    push    bx 
    call    line

    mov     ax, [p2 + Player.x] 
    add     ax, 10 
    push    ax 
    push    word [p2 + Player.y] 
    push    word [p2 + Player.x] 
    push    bx 
    call    line

    ; Atualiza coordenadas anteriores
    mov     ax, [p2 + Player.x]
    mov     [p2 + Player.old_x], ax
    mov     ax, [p2 + Player.y]
    mov     [p2 + Player.old_y], ax

.done_draw:
    pop     bx
    pop     ax
    ret