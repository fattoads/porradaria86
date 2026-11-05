; ==============================================================================
; MÓDULO: player.asm
; DESCRIÇÃO: Armazena o estado dos lutadores (p1 e p2), gerencia a entrada de
;             teclado dos jogadores e renderiza os personagens na tela.
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
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
; DS
; ------------------------------------------------------------------------------
segment data

; Alocação física das estruturas dos dois lutadores
p1: resb Player.size
p2: resb Player.size

; ------------------------------------------------------------------------------
; CS
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
    ; mov     byte [p1 + Player.rounds], 0
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
    ; mov     byte [p2 + Player.rounds], 0
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

    ; PLAYER 1
    ; ---
    ; Se P1 está paralisado, atacando ou atingido, ele não vai agir. 
    cmp     byte [p1 + Player.stun_timer], 0
    jne     .update_p2_input

    mov     word [p1 + Player.vx], 0        ; Resetamos a velocidade antes dos próximos saltos para não mantê-la durante o ataque

    cmp     byte [p1 + Player.state], STATE_ATTACK
    je      .update_p2_input
    cmp     byte [p1 + Player.state], STATE_HIT
    je      .update_p2_input

    ; Checamos a tecla de agachar e desabilitamos esse estado se ela for liberada
    ; Tecla S: Agachar
    mov     al, SCANCODE_S
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_disable_crouch
    cmp     byte [p1 + Player.is_grounded], 1
    jne     .p1_disable_crouch
    mov     byte [p1 + Player.state], STATE_CROUCH
    jmp     .p1_check_attack

.p1_disable_crouch:
    cmp     byte [p1 + Player.state], STATE_CROUCH
    jne     .p1_check_left
    mov     byte [p1 + Player.state], STATE_IDLE

.p1_check_left:
    ; Tecla A: Esquerda
    mov     al, SCANCODE_A
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_check_right
    mov     word [p1 + Player.vx], -3
    mov     byte [p1 + Player.dir], DIR_LEFT
    mov     byte [p1 + Player.state], STATE_WALK
    jmp     .p1_check_jump

.p1_check_right:
    ; Tecla D: Direita
    mov     al, SCANCODE_D
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_check_jump
    mov     word [p1 + Player.vx], 3
    mov     byte [p1 + Player.dir], DIR_RIGHT
    mov     byte [p1 + Player.state], STATE_WALK

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
    ; Tecla T: Soco
    mov     al, SCANCODE_T
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_check_kick
    
    ; Só dispara novo ataque se o timer de ataque anterior tiver chegado a 0
    cmp     byte [p1 + Player.attack_timer], 0
    jne     .update_p2_input

    ; Dispara o golpe: entra em STATE_ATTACK e inicia o timer
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p1 + Player.attack_timer], ATTACK_TOTAL_DURATION
    mov     byte [p1 + Player.attack_type], ATTACK_TYPE_PUNCH
    mov     byte [p1 + Player.state], STATE_ATTACK

.p1_check_kick:
    ; Tecla R: Chute P1
    mov     al, SCANCODE_R
    call    is_key_pressed
    cmp     al, 1
    jne     .update_p2_input

    ; Só dispara novo ataque se o timer de ataque anterior tiver chegado a 0
    cmp     byte [p1 + Player.attack_timer], 0
    jne     .update_p2_input

    ; Dispara o golpe: entra em STATE_ATTACK e inicia o timer
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p1 + Player.attack_timer], ATTACK_TOTAL_DURATION
    mov     byte [p1 + Player.attack_type], ATTACK_TYPE_KICK
    mov     byte [p1 + Player.state], STATE_ATTACK

.update_p2_input:
    ; PLAYER 2
    ; ---
    ; Se P2 está paralisado, atacando ou atingido, ele não vai agir. 
    cmp     byte [p2 + Player.stun_timer], 0
    jne     .done_input

    mov     word [p2 + Player.vx], 0        ; Resetamos a velocidade antes dos próximos saltos para não mantê-la durante o ataque

    ; Se está em ataque ou levando golpe, ignora novos inputs de movimento
    cmp     byte [p2 + Player.state], STATE_ATTACK
    je      .done_input
    cmp     byte [p2 + Player.state], STATE_HIT
    je      .done_input

    ; Checamos a tecla de agachar e desabilitamos esse estado se ela for liberada
    ; Seta Baixo: Agachar
    mov     al, SCANCODE_DOWN
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_disable_crouch
    cmp     byte [p2 + Player.is_grounded], 1
    jne     .p2_disable_crouch
    mov     byte [p2 + Player.state], STATE_CROUCH
    jmp     .p2_check_attack

.p2_disable_crouch:
    cmp     byte [p2 + Player.state], STATE_CROUCH
    jne     .p2_check_left
    mov     byte [p2 + Player.state], STATE_IDLE

.p2_check_left:
    ; Seta Esquerda
    mov     al, SCANCODE_LEFT
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_check_right
    mov     word [p2 + Player.vx], -3
    mov     byte [p2 + Player.dir], DIR_LEFT
    mov     byte [p2 + Player.state], STATE_WALK
    jmp     .p2_check_jump

.p2_check_right:
    ; Seta Direita
    mov     al, SCANCODE_RIGHT
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_check_jump
    mov     word [p2 + Player.vx], 3
    mov     byte [p2 + Player.dir], DIR_RIGHT
    mov     byte [p2 + Player.state], STATE_WALK

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
    ; Tecla M: Soco
    mov     al, SCANCODE_M
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_check_kick
    
    ; Só dispara novo ataque se o timer de ataque anterior tiver chegado a 0
    cmp     byte [p2 + Player.attack_timer], 0
    jne     .done_input

    ; Dispara o golpe: entra em STATE_ATTACK e inicia o timer
    mov     byte [p2 + Player.attack_active], 0
    mov     byte [p2 + Player.attack_timer], ATTACK_TOTAL_DURATION
    mov     byte [p2 + Player.attack_type], ATTACK_TYPE_PUNCH
    mov     byte [p2 + Player.state], STATE_ATTACK

.p2_check_kick:
    ; Tecla N: Chute P1
    mov     al, SCANCODE_N
    call    is_key_pressed
    cmp     al, 1
    jne     .done_input

    ; Só dispara novo ataque se o timer de ataque anterior tiver chegado a 0
    cmp     byte [p2 + Player.attack_timer], 0
    jne     .done_input

    ; Dispara o golpe: entra em STATE_ATTACK e inicia o timer
    mov     byte [p2 + Player.attack_active], 0
    mov     byte [p2 + Player.attack_timer], ATTACK_TOTAL_DURATION
    mov     byte [p2 + Player.attack_type], ATTACK_TYPE_KICK
    mov     byte [p2 + Player.state], STATE_ATTACK

.done_input:
    pop     ax
    ret

; ------------------------------------------------------------------------------
; draw_single_player: Função auxiliar para desenhar/apagar a silhueta do lutador.
; Entrada:
;   AX = Pos X
;   DX = Pos Y
;   CL = State (para checar STATE_CROUCH)
;   Cor obtida de [cor] (black para apagar, Player.color para desenhar)
; ------------------------------------------------------------------------------
draw_single_player:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    cmp     cl, STATE_CROUCH
    je      .draw_crouched

    ; --- SILHUETA EM PÉ ---
    ; Cabeça: (X, Y - 60, R=8)
    push    ax
    mov     bx, dx
    sub     bx, 60
    push    bx
    push    word 8
    call    full_circle

    ; Tronco: (X, Y - 50) até (X, Y - 20)
    mov     bx, dx
    sub     bx, 50
    mov     di, dx
    sub     di, 20
    push    ax
    push    bx
    push    ax
    push    di
    call    line

    ; Perna Esquerda: (X - 10, Y) até (X, Y - 20)
    mov     si, ax
    sub     si, 10
    push    si
    push    dx
    push    ax
    push    di
    call    line

    ; Perna Direita: (X + 10, Y) até (X, Y - 20)
    mov     si, ax
    add     si, 10
    push    si
    push    dx
    push    ax
    push    di
    call    line
    jmp     .done

.draw_crouched:
    ; --- SILHUETA AGACHADA ---
    ; Cabeça: (X, Y - 30, R=8)
    push    ax
    mov     bx, dx
    sub     bx, 30
    push    bx
    push    word 8
    call    full_circle

    ; Tronco: (X, Y - 25) até (X, Y - 10)
    mov     bx, dx
    sub     bx, 25
    mov     di, dx
    sub     di, 10
    push    ax
    push    bx
    push    ax
    push    di
    call    line

    ; Perna Esquerda: (X - 12, Y) até (X, Y - 10)
    mov     si, ax
    sub     si, 12
    push    si
    push    dx
    push    ax
    push    di
    call    line

    ; Perna Direita: (X + 12, Y) até (X, Y - 10)
    mov     si, ax
    add     si, 12
    push    si
    push    dx
    push    ax
    push    di
    call    line

.done:
    ; Restaura estado
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; player_erase_all: Apaga as posições anteriores dos jogadores.
; ------------------------------------------------------------------------------
player_erase_all:
    ; Salva estado
    push    ax
    push    cx
    push    dx

    ; Apagamos P1
    mov     ax, [p1 + Player.old_x]
    mov     dx, [p1 + Player.old_y]
    mov     cl, [p1 + Player.old_state]
    mov     byte [cor], preto
    call    draw_single_player

    ; Apagamos P2
    mov     ax, [p2 + Player.old_x]
    mov     dx, [p2 + Player.old_y]
    mov     cl, [p2 + Player.old_state]
    call    draw_single_player

    ; Restaura estado
    pop     dx
    pop     cx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; player_draw_all: Desenha p1 e p2 nas coordenadas atuais e atualiza old_x/old_y/old_state.
; ------------------------------------------------------------------------------
player_draw_all:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx

    ; Desenhamos P1
    mov     ax, [p1 + Player.x]
    mov     dx, [p1 + Player.y]
    mov     cl, [p1 + Player.state]
    mov     bl, [p1 + Player.color]
    mov     [cor], bl
    call    draw_single_player

    ; Salvamos o histórico de P1
    mov     [p1 + Player.old_x], ax
    mov     [p1 + Player.old_y], dx
    mov     [p1 + Player.old_state], cl

    ; Desenhamos P2
    mov     ax, [p2 + Player.x]
    mov     dx, [p2 + Player.y]
    mov     cl, [p2 + Player.state]
    mov     bl, [p2 + Player.color]
    mov     [cor], bl
    call    draw_single_player

    ; Salvamos o histórico de P2
    mov     [p2 + Player.old_x], ax
    mov     [p2 + Player.old_y], dx
    mov     [p2 + Player.old_state], cl

    ; Restaura estado
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret