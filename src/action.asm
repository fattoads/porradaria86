; ==============================================================================
; MÓDULO: action.asm
; DESCRIÇÃO: Processador de física, colisão de corpos, hitboxes e combate.
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%define ACTION_ASM

%include "player.inc"
%include "action.inc"
%include "ui.inc"

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global action_init
global action_update
global check_aabb_collision
global clash_occurred, clash_x, clash_y

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

; Buffers de hit/hurtbox: X, Y, W, H
hb1:    times 4 dw 0 
hb2:    times 4 dw 0 
hurt1:  times 4 dw 0 
hurt2:  times 4 dw 0

; ------------------------------------------------------------------------------
; CS
; ------------------------------------------------------------------------------
segment code

; ------------------------------------------------------------------------------
; action_init: Inicializa os dados de efeito do módulo de ação.
; ------------------------------------------------------------------------------
action_init:
    ret

; ------------------------------------------------------------------------------
; check_aabb_collision: Testa colisão de intersecção entre 2 retângulos (AABB).
; Entrada (via Pilha):
;   [BP+18] = X1, [BP+16] = Y1, [BP+14] = W1, [BP+12] = H1 (Retângulo 1)
;   [BP+10] = X2, [BP+8]  = Y2, [BP+6]  = W2, [BP+4]  = H2 (Retângulo 2)
; Saída:
;   AL = 1 (Houve colisão) ou 0 (Não houve colisão)
; ------------------------------------------------------------------------------
check_aabb_collision:
    ; Salva estado
    push    bp
    mov     bp, sp
    push    bx
    push    cx
    push    dx

    ; Se X1 + W1 < X2, não houve colisão
    mov     ax, [bp+18]         ; X1
    add     ax, [bp+14]         ; X1 + W1
    cmp     ax, [bp+10]         ; X2
    jl      .no_collision

    ; Se X2 + W2 < X1, não houve colisão
    mov     ax, [bp+10]         ; X2
    add     ax, [bp+6]          ; X2 + W2
    cmp     ax, [bp+18]         ; X1
    jl      .no_collision

    ; Se Y1 + H1 < Y2, não houve colisão
    mov     ax, [bp+16]         ; Y1
    add     ax, [bp+12]         ; Y1 + H1
    cmp     ax, [bp+8]          ; Y2
    jl      .no_collision

    ; Se Y2 + H2 < Y1, não houve colisão
    mov     ax, [bp+8]          ; Y2
    add     ax, [bp+4]          ; Y2 + H2
    cmp     ax, [bp+16]         ; Y1
    jl      .no_collision

    ; Se chegamos aqui, os retângulos se interceptaram
    mov     al, 1               ; Houve colisão
    jmp     .done

.no_collision:
    mov     al, 0               ; Não houve colisão

.done:
    ; Restaura estado
    pop     dx
    pop     cx
    pop     bx
    pop     bp
    ret     16                  ; Limpa 8 parâmetros de 2 bytes (16 bytes)

; ------------------------------------------------------------------------------
; check_rect_collision: Wrapper para check_aabb_collision que recebe endereços de 2 retângulos.
; Entrada:
;   SI = ptr para Retângulo 1
;   DI = ptr para Retângulo 2
; Saída: 
;   AL = 1 (Houve colisão) ou 0 (Não houve colisão)
; ------------------------------------------------------------------------------
check_rect_collision:
    push    word [si]           ; X1
    push    word [si+2]         ; Y1
    push    word [si+4]         ; W1
    push    word [si+6]         ; H1
    push    word [di]           ; X2
    push    word [di+2]         ; Y2
    push    word [di+4]         ; W2
    push    word [di+6]         ; H2
    call    check_aabb_collision
    ret

; ------------------------------------------------------------------------------
; get_player_hitbox: Calcula a Hitbox (X, Y, W, H) do jogador apontado por SI
;                    e armazena a estrutura no buffer apontado por DI.
; Entrada: 
;   SI = ptr para Player
;   DI = ptr para buffer de destino (4 words)
; ------------------------------------------------------------------------------
get_player_hitbox:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx

    cmp     byte [si + Player.attack_type], ATTACK_TYPE_KICK
    je      .kick_dim
    
    ; Dimensões do soco
    mov     cx, PUNCH_WIDTH
    mov     dx, PUNCH_HEIGHT
    mov     bx, [si + Player.y]
    sub     bx, 60                      ; Y do soco
    jmp     .calc_x

.kick_dim:
    ; Dimensões do chute
    mov     cx, KICK_WIDTH
    mov     dx, KICK_HEIGHT
    mov     bx, [si + Player.y]
    sub     bx, 30                      ; Y do chute

.calc_x:
    ; Alcance do ataque no eixo x
    mov     ax, [si + Player.x]
    cmp     byte [si + Player.dir], DIR_RIGHT
    jne     .left_dir
    add     ax, 15
    jmp     .store_hitbox

.left_dir:
    sub     ax, 15
    sub     ax, cx                      ; X = x - 15 - W

.store_hitbox:
    mov     [di], ax                    ; X 
    mov     [di + 2], bx                ; Y 
    mov     [di + 4], cx                ; W 
    mov     [di + 6], dx                ; H

    ; Restaura estado
    pop     dx 
    pop     cx 
    pop     bx 
    pop     ax 
    ret

; ------------------------------------------------------------------------------
; get_player_hurtbox: Calcula a Hurtbox (X, Y, W, H) do jogador apontado por SI
;                     e armazena a estrutura no buffer apontado por DI.
; Entrada:
;   SI = ptr para Player
;   DI = ptr para buffer de destino (4 words)
; ------------------------------------------------------------------------------
get_player_hurtbox:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx

    mov     ax, [si + Player.x]
    sub     ax, 15                      ; X = x - 15
    mov     cx, PLAYER_WIDTH            ; W = 30

    cmp     byte [si + Player.state], STATE_CROUCH
    je      .crouch_hurt

    ; Altura do player normal
    mov     bx, [si + Player.y]
    sub     bx, PLAYER_HEIGHT           ; Y = y - 70
    mov     dx, PLAYER_HEIGHT           ; H = 70
    jmp     .store_hurtbox

.crouch_hurt:
    ; Altura do player agachado
    mov     bx, [si + Player.y]
    sub     bx, CROUCH_HEIGHT           ; Y = y - 35
    mov     dx, CROUCH_HEIGHT           ; H = 35

.store_hurtbox:
    mov     [di], ax                    ; X
    mov     [di + 2], bx                ; Y
    mov     [di + 4], cx                ; W
    mov     [di + 6], dx                ; H

    ; Restaura estado
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; action_update: Executa a física, gravidade, limites, repulsão e combate
;                sobre as instâncias p1 e p2 mantidas no player.asm.
; ------------------------------------------------------------------------------
action_update:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    ; --- Atualização de timers de stun e ataque ---
    ; O ataque é separado em 3 estados, que correspondem a intervalos diferentes de valores do timer.
    ; Startup: Timer de 12 a 10 - Ataque sujeito a clash
    ; Active: Timer de 9 a 5    - Ataque ativo, causará dano se interceptar
    ; Recovery: Timer de 4 a 1  - Ataque finalizado, intervalo breve antes de retornar controle ao jogador
    ; Se o timer chega em 0, não estamos mais no estado de ataque
    cmp     byte [p1 + Player.attack_timer], 0
    je      .check_p1_stun                      ; Se não estamos atacando, verificamos o estado de stun

    dec     byte [p1 + Player.attack_timer]
    mov     al, [p1 + Player.attack_timer]
    cmp     al, 0
    jne     .check_p1_phases                    ; Se ainda estamos atacando, então vamos pra lógica de fases de ataque

    ; Se o timer acaba de atingir 0, encerramos o estado de ataque
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p1 + Player.state], STATE_IDLE
    jmp     .check_p1_stun

.check_p1_phases:
    cmp     al, 9                               ; AL ainda armazena o timer nesse ponto
    jne     .check_p1_recovery
    mov     byte [p1 + Player.attack_active], 1 ; Ataque se torna ativo ao fim do startup
    jmp     .check_p1_stun

.check_p1_recovery:
    cmp     al, 4                               ; AL ainda armazena o timer nesse ponto
    jne     .check_p1_stun
    mov     byte [p1 + Player.attack_active], 0 ; Ataque desativa no início do recovery

.check_p1_stun:
    cmp     byte [p1 + Player.stun_timer], 0
    je      .update_p2_timers
    dec     byte [p1 + Player.stun_timer]
    jnz     .update_p2_timers

    ; Se chegamos aqui, o stun timer acaba de atingir 0. Logo, precisamos zerar a velocidade e resetar o estado para idle
    mov word [p1 + Player.vx], 0 
    mov byte [p1 + Player.state], STATE_IDLE

.update_p2_timers:
    ; O ataque é separado em 3 estados, que correspondem a intervalos diferentes de valores do timer.
    ; Startup: Timer de 12 a 10 - Ataque sujeito a clash
    ; Active: Timer de 9 a 5    - Ataque ativo, causará dano se interceptar
    ; Recovery: Timer de 4 a 1  - Ataque finalizado, intervalo breve antes de retornar controle ao jogador
    ; Se o timer chega em 0, não estamos mais no estado de ataque
    cmp     byte [p2 + Player.attack_timer], 0
    je      .check_p2_stun                      ; Se não estamos atacando, verificamos o estado de stun

    dec     byte [p2 + Player.attack_timer]
    mov     al, [p2 + Player.attack_timer]
    cmp     al, 0
    jne     .check_p2_phases                    ; Se ainda estamos atacando, então vamos pra lógica de fases de ataque

    ; Se o timer acaba de atingir 0, encerramos o estado de ataque
    mov     byte [p2 + Player.attack_active], 0
    cmp     byte [p2 + Player.state], STATE_ATTACK
    jne     .check_p2_stun
    mov     byte [p2 + Player.state], STATE_IDLE
    jmp     .check_p2_stun

.check_p2_phases:
    cmp     al, 9                               ; AL ainda armazena o timer nesse ponto
    jne     .check_p2_recovery
    mov     byte [p2 + Player.attack_active], 1 ; Ataque se torna ativo ao fim do startup
    jmp     .check_p2_stun

.check_p2_recovery:
    cmp     al, 4                               ; AL ainda armazena o timer nesse ponto
    jne     .check_p2_stun
    mov     byte [p2 + Player.attack_active], 0 ; Ataque desativa no início do recovery

.check_p2_stun:
    cmp     byte [p2 + Player.stun_timer], 0
    je      .update_p1_physics
    dec     byte [p2 + Player.stun_timer]
    jnz     .update_p1_physics

    ; Se chegamos aqui, o stun timer acaba de atingir 0. Logo, precisamos zerar a velocidade e resetar o estado para idle
    mov word [p2 + Player.vx], 0 
    mov byte [p2 + Player.state], STATE_IDLE

    ; --- FÍSICA DO JOGADOR 1 ---
.update_p1_physics:
    ; Enquanto agachado, jogador não pode se mexer
    cmp     byte [p1 + Player.state], STATE_CROUCH
    jne     .p1_apply_vx
    mov     word [p1 + Player.vx], 0

.p1_apply_vx:
    ; Posição X += Velocidade X
    mov     ax, [p1 + Player.vx]
    add     [p1 + Player.x], ax

    ; Delimitação das Paredes da Arena
    cmp     word [p1 + Player.x], (WALL_LEFT + 12)      ; Se estamos à direita da parede esquerda, verificamos a parede direita
    jge     .p1_right_wall
    mov     word [p1 + Player.x], (WALL_LEFT + 12)      ; Caso contrário, colamos à esquerda

.p1_right_wall:
    cmp     word [p1 + Player.x], (WALL_RIGHT - 12)     ; Se estamos à esquerda da parede direita, prosseguimos pra física vertical
    jle     .p1_vertical
    mov     word [p1 + Player.x], (WALL_RIGHT - 12)     ; Caso contrário, colamos à direita

.p1_vertical:
    cmp     byte [p1 + Player.is_grounded], 0
    jne     .update_p2_physics                  ; Se está no chão, pulamos a etapa de gravidade

    mov     ax, [p1 + Player.vy]
    add     [p1 + Player.y], ax
    add     word [p1 + Player.vy], GRAVITY

    ; Verificamos se a queda fez o lutador atingir o chão; se sim, setamos o estado IDLE
    cmp     word [p1 + Player.y], FLOOR_Y
    jl      .update_p2_physics
    mov     word [p1 + Player.y], (FLOOR_Y - 1)
    mov     word [p1 + Player.vy], 0
    mov     byte [p1 + Player.is_grounded], 1
    cmp     byte [p1 + Player.state], STATE_JUMP
    jne     .update_p2_physics
    mov     byte [p1 + Player.state], STATE_IDLE

    ; --- FÍSICA DO JOGADOR 2 ---
.update_p2_physics:
    ; Enquanto agachado, jogador não pode se mexer
    cmp     byte [p2 + Player.state], STATE_CROUCH
    jne     .p2_apply_vx
    mov     word [p2 + Player.vx], 0

.p2_apply_vx:
    ; Posição X += Velocidade X
    mov     ax, [p2 + Player.vx]
    add     [p2 + Player.x], ax

    ; Delimitação das Paredes da Arena
    cmp     word [p2 + Player.x], (WALL_LEFT + 12)     ; Se estamos à direita da parede esquerda, verificamos a parede direita
    jge     .p2_right_wall
    mov     word [p2 + Player.x], (WALL_LEFT + 12)     ; Caso contrário, colamos à esquerda

.p2_right_wall:
    cmp     word [p2 + Player.x], (WALL_RIGHT - 12)    ; Se estamos à esquerda da parede direita, prosseguimos pra física vertical
    jle     .p2_vertical
    mov     word [p2 + Player.x], (WALL_RIGHT - 12)    ; Caso contrário, colamos à direita

.p2_vertical:
    cmp     byte [p2 + Player.is_grounded], 0
    jne     .resolve_pushbox                    ; Se está no chão, pulamos a etapa de gravidade

    mov     ax, [p2 + Player.vy]
    add     [p2 + Player.y], ax
    add     word [p2 + Player.vy], GRAVITY

    ; Verificamos se a queda fez o lutador atingir o chão; se sim, setamos o estado IDLE
    cmp     word [p2 + Player.y], FLOOR_Y
    jl      .resolve_pushbox
    mov     word [p2 + Player.y], (FLOOR_Y - 1)
    mov     word [p2 + Player.vy], 0
    mov     byte [p2 + Player.is_grounded], 1
    cmp     byte [p2 + Player.state], STATE_JUMP
    jne     .resolve_pushbox
    mov     byte [p2 + Player.state], STATE_IDLE

    ; --- REPULSÃO DE CORPOS (PUSHBOX) ---
.resolve_pushbox:
    mov     ax, [p1 + Player.x]
    sub     ax, [p2 + Player.x]
    jge     .p1_on_right

.p1_on_left:
    mov     ax, [p2 + Player.x]
    sub     ax, [p1 + Player.x]
    cmp     ax, PLAYER_WIDTH
    jge     .combat_collisions

    dec     word [p1 + Player.x]
    inc     word [p2 + Player.x]
    jmp     .combat_collisions

.p1_on_right:
    cmp     ax, PLAYER_WIDTH
    jge     .combat_collisions

    inc     word [p1 + Player.x]
    dec     word [p2 + Player.x]

    ; --- DETECÇÃO DE COMBATE E HITBOXES ---
.combat_collisions:
    ; Salvamos as hit/hurtboxes nos buffers
    mov     si, p1
    mov     di, hb1
    call    get_player_hitbox

    mov     si, p2
    mov     di, hb2
    call    get_player_hitbox

    mov     si, p1
    mov     di, hurt1
    call    get_player_hurtbox

    mov     si, p2
    mov     di, hurt2
    call    get_player_hurtbox

    ; Se algum dos dois não está atacando, não precisamos analisar a possibilidade de clash
    cmp     byte [p1 + Player.attack_active], 1
    jne     .check_p1_hit
    cmp     byte [p2 + Player.attack_active], 1
    jne     .check_p1_hit

    ; Como ambos estão atacando, verificamos se ambos se atingiram ao mesmo tempo
    mov     si, hb1
    mov     di, hurt2
    call    check_rect_collision
    push    ax                          ; Salva 1 se HB1 acerta HURT2

    mov     si, hb2
    mov     di, hurt1
    call    check_rect_collision        ; AL = 1 se HB2 acerta HURT1
    pop     bx                          ; BL = 1 se HB1 acerta HURT2
    and     al, bl                      ; 1 se os dois acertaram
    cmp     al, 1
    je      .trigger_clash

    ; --- P1 Atacando P2 ---
.check_p1_hit:
    ; Houve um ataque?
    cmp     byte [p1 + Player.attack_active], 1
    jne     .check_p2_hit

    ; O ataque conectou?
    mov     si, hb1
    mov     di, hurt2
    call    check_rect_collision
    cmp     al, 1
    jne     .check_p2_hit

    ; Resultado do ataque
    mov     byte [p1 + Player.attack_active], 0 ; Ataque desativa ao conectar com o oponente
    mov     byte [p2 + Player.state], STATE_HIT
    mov     byte [p2 + Player.stun_timer], 12
    mov     byte [p2 + Player.attack_active], 0 ; Cancela qualquer ataque do P2
    mov     byte [p2 + Player.attack_timer], 0  ; Zera o timer de ataque do P2

    cmp     byte [p2 + Player.hp], 0
    je      .knockback_p2                       ; TODO: Encerramento do round
    dec     byte [p2 + Player.hp]

.knockback_p2:
    mov     word [p2 + Player.vx], 8
    cmp     byte [p1 + Player.dir], DIR_RIGHT
    je      .check_p2_hit
    mov     word [p2 + Player.vx], -8

    ; --- P2 Atacando P1 ---
.check_p2_hit:
    ; Houve um ataque?
    cmp     byte [p2 + Player.attack_active], 1
    jne     .done_action

    ; O ataque conectou?
    mov     si, hb2
    mov     di, hurt1
    call    check_rect_collision
    cmp     al, 1
    jne     .done_action

    ; Resultado do ataque
    mov     byte [p2 + Player.attack_active], 0 ; Ataque desativa ao conectar com o oponente
    mov     byte [p1 + Player.state], STATE_HIT
    mov     byte [p1 + Player.stun_timer], 12
    mov     byte [p1 + Player.attack_active], 0 ; Cancela qualquer ataque do P1
    mov     byte [p1 + Player.attack_timer], 0  ; Zera o timer de ataque do P1

    cmp     byte [p1 + Player.hp], 0
    je      .knockback_p1                       ; TODO: encerramento do round
    dec     byte [p1 + Player.hp]

.knockback_p1:
    mov     word [p1 + Player.vx], -8
    cmp     byte [p2 + Player.dir], DIR_LEFT
    je      .done_action
    mov     word [p1 + Player.vx], 8
    jmp     .done_action

.trigger_clash:
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p2 + Player.attack_active], 0
    mov     byte [p1 + Player.stun_timer], 10
    mov     byte [p2 + Player.stun_timer], 10
    mov     word [p1 + Player.vx], -6
    mov     word [p2 + Player.vx], 6

.done_action:
    ; Restaura estado
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret