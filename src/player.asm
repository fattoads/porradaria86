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
%include "sprite.inc"

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global p1
global p2
global player_init
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
    mov     word [p1 + Player.vx], 0
    mov     word [p1 + Player.vy], 0
    mov     byte [p1 + Player.hp], PLAYER_MAX_HP
    mov     byte [p1 + Player.state], STATE_IDLE
    mov     byte [p1 + Player.dir], DIR_RIGHT
    mov     byte [p1 + Player.is_grounded], 1
    mov     byte [p1 + Player.attack_active], 0
    mov     byte [p1 + Player.stun_timer], 0
    mov     byte [p1 + Player.anim_frame], 0
    mov     byte [p1 + Player.anim_timer], 0

    ; --- JOGADOR 2 ---
    mov     word [p2 + Player.x], P2_START_X
    mov     word [p2 + Player.y], FLOOR_Y - 1
    mov     word [p2 + Player.vx], 0
    mov     word [p2 + Player.vy], 0
    mov     byte [p2 + Player.hp], PLAYER_MAX_HP
    mov     byte [p2 + Player.state], STATE_IDLE
    mov     byte [p2 + Player.dir], DIR_LEFT
    mov     byte [p2 + Player.is_grounded], 1
    mov     byte [p2 + Player.attack_active], 0
    mov     byte [p2 + Player.stun_timer], 0
    mov     byte [p2 + Player.anim_frame], 0
    mov     byte [p2 + Player.anim_timer], 0

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
    cmp     byte [p1 + Player.is_grounded], 1
    jne     .p1_check_jump
    mov     byte [p1 + Player.state], STATE_WALK
    jmp     .p1_check_jump

.p1_check_right:
    ; Tecla D: Direita
    mov     al, SCANCODE_D
    call    is_key_pressed
    cmp     al, 1
    jne     .p1_no_walk
    mov     word [p1 + Player.vx], 3
    mov     byte [p1 + Player.dir], DIR_RIGHT
    cmp     byte [p1 + Player.is_grounded], 1
    jne     .p1_check_jump
    mov     byte [p1 + Player.state], STATE_WALK
    jmp     .p1_check_jump

.p1_no_walk:
    cmp     byte [p1 + Player.is_grounded], 1
    jne     .p1_check_jump
    cmp     byte [p1 + Player.state], STATE_WALK
    jne     .p1_check_jump
    mov     byte [p1 + Player.state], STATE_IDLE

.p1_check_jump:
    ; Tecla W: Pulo
    mov     al, SCANCODE_W
    call    get_key_event
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
    call    get_key_event
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
    mov     byte [p1 + Player.anim_frame], 0       ; Reinicia a animação no Frame 0
    mov     byte [p1 + Player.anim_timer], 0

.p1_check_kick:
    ; Tecla R: Chute P1
    mov     al, SCANCODE_R
    call    get_key_event
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
    mov     byte [p1 + Player.anim_frame], 0       ; Reinicia a animação no Frame 0
    mov     byte [p1 + Player.anim_timer], 0

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
    cmp     byte [p2 + Player.is_grounded], 1
    jne     .p2_check_jump
    mov     byte [p2 + Player.state], STATE_WALK
    jmp     .p2_check_jump

.p2_check_right:
    ; Seta Direita
    mov     al, SCANCODE_RIGHT
    call    is_key_pressed
    cmp     al, 1
    jne     .p2_no_walk
    mov     word [p2 + Player.vx], 3
    mov     byte [p2 + Player.dir], DIR_RIGHT
    cmp     byte [p2 + Player.is_grounded], 1
    jne     .p2_check_jump
    mov     byte [p2 + Player.state], STATE_WALK
    jmp     .p2_check_jump

.p2_no_walk:
    cmp     byte [p2 + Player.is_grounded], 1
    jne     .p2_check_jump
    cmp     byte [p2 + Player.state], STATE_WALK
    jne     .p2_check_jump
    mov     byte [p2 + Player.state], STATE_IDLE

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
    call    get_key_event
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
    mov     byte [p2 + Player.anim_frame], 0       ; Reinicia a animação no Frame 0
    mov     byte [p2 + Player.anim_timer], 0

.p2_check_kick:
    ; Tecla N: Chute P1
    mov     al, SCANCODE_N
    call    get_key_event
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
    mov     byte [p2 + Player.anim_frame], 0       ; Reinicia a animação no Frame 0
    mov     byte [p2 + Player.anim_timer], 0

.done_input:
    pop     ax
    ret

; ------------------------------------------------------------------------------
; draw_sprite_mask: Desenha uma matriz de 32x32 bits com escala 2x2 no buffer RAM.
; Entrada (via Pilha):
;   [BP+10] = X base (centro do jogador)
;   [BP+8]  = Y base (pé do jogador no chão)
;   [BP+6]  = Endereço da matriz do sprite (128 bytes)
;   [BP+4]  = Direção (DIR_RIGHT = 0, DIR_LEFT = 1)
; Utiliza a cor global [cor]
; ------------------------------------------------------------------------------
draw_sprite_mask:
    push    bp
    mov     bp, sp
    sub     sp, 6               ; Aloca 6 bytes para variáveis locais:
                                ; [bp-2] = mask_byte (salva DL)
                                ; [bp-4] = X_screen
                                ; [bp-6] = Y_screen

    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    mov     si, [bp+6]          ; SI = Endereço da matriz do sprite (128 bytes)
    mov     di, 0               ; DI = Linha vertical (0 a 31)

.row_loop:
    cmp     di, 32
    jge     .done_draw

    mov     bx, 0               ; BX = Byte da linha (0 a 3)

.byte_loop:
    cmp     bx, 4
    jge     .next_row

    mov     dl, [si]            ; DL = Byte da máscara (8 pixels)
    inc     si
    mov     cx, 0               ; CX = Bit dentro do byte (0 a 7)

.bit_loop:
    cmp     cx, 8
    jge     .next_byte

    test    dl, 80h             ; Pixel aceso (Bit 7 = 1)?
    jz      .skip_pixel

    ; Salvamos a máscara em uma "variável local" na pilha
    mov     [bp-2], dl

    ; Calcula coluna do sprite
    mov     ax, bx
    shl     ax, 3
    add     ax, cx              ; AX = (BX * 8) + CX

    ; Espelha na direção esquerda
    cmp     word [bp+4], DIR_LEFT
    jne     .calc_coords
    ; Deslocamento do sprite para alinhar com a hitbox
    ;   Isso foi feito de forma mais ou menos empírica. Os sprites foram desenhados com ~7px de distância da borda do quadro em média,
    ;   mas eles são salvos colados em uma das paredes. Logo, restam ~14-15px vazios na frente do sprite e precisamos compensar esse espaço
    ;   desenhando ele com um deslocamento. 
    mov     dx, 15
    sub     dx, ax
    mov     ax, dx

.calc_coords:
    ; --- X_SCREEN = (X_base - 32) + (col * 2) ---
    shl     ax, 1
    add     ax, [bp+10]
    sub     ax, 32
    mov     [bp-4], ax          ; Salva X_screen em [bp-4]

    ; --- Y_SCREEN = (Y_base - 64) + (row * 2) ---
    mov     ax, di
    shl     ax, 1
    add     ax, [bp+8]
    sub     ax, 64
    mov     [bp-6], ax          ; Salva Y_screen em [bp-6]

    ; --- DESENHA O PIXEL COM UPSCALING ---
    ; Pixel 1: (X, Y)
    push    word [bp-4]
    push    word [bp-6]
    call    plot_xy

    ; Pixel 2: (X+1, Y)
    mov     ax, [bp-4]
    inc     ax
    push    ax
    push    word [bp-6]
    call    plot_xy

    ; Pixel 3: (X, Y+1)
    mov     ax, [bp-6]
    inc     ax
    push    word [bp-4]
    push    ax
    call    plot_xy

    ; Pixel 4: (X+1, Y+1)
    mov     ax, [bp-4]
    inc     ax
    mov     dx, [bp-6]
    inc     dx
    push    ax
    push    dx
    call    plot_xy

    ; Restaura a máscara de bits
    mov     dl, [bp-2]

.skip_pixel:
    shl     dl, 1               ; Próximo bit (Bit 6 passa para Bit 7)
    inc     cx
    jmp     .bit_loop

.next_byte:
    inc     bx
    jmp     .byte_loop

.next_row:
    inc     di
    jmp     .row_loop

.done_draw:
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax

    mov     sp, bp              ; Libera as variáveis locais da pilha
    pop     bp
    ret     8                   ; Desempilha os 4 parâmetros da chamada

; ------------------------------------------------------------------------------
; player_draw_all: Desenha ambos os jogadores e atualiza seus antigos estados
;                   e posições.
; ------------------------------------------------------------------------------
player_draw_all:
    push    ax
    push    bx
    push    si

    ; --- DESENHA JOGADOR 1 ---
    mov     al, [p1 + Player.color]
    mov     byte [cor], al

    mov     si, p1
    call    get_player_sprite_ptr       ; AX = ponteiro para o sprite de P1

    push    word [p1 + Player.x]        ; Param 1: X
    push    word [p1 + Player.y]        ; Param 2: Y
    push    ax                          ; Param 3: Matriz
    xor     bx, bx
    mov     bl, [p1 + Player.dir]
    push    bx                          ; Param 4: Direção (DIR_RIGHT/DIR_LEFT)
    call    draw_sprite_mask

    ; --- DESENHA JOGADOR 2 ---
    mov     al, [p2 + Player.color]
    mov     byte [cor], al

    mov     si, p2
    call    get_player_sprite_ptr       ; AX = ponteiro para o sprite de P2

    push    word [p2 + Player.x]        ; Param 1: X
    push    word [p2 + Player.y]        ; Param 2: Y
    push    ax                          ; Param 3: Matriz
    xor     bx, bx
    mov     bl, [p2 + Player.dir]
    push    bx                          ; Param 4: Direção
    call    draw_sprite_mask

    pop     si
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; get_player_sprite_ptr: Retorna em AX o ponteiro da matriz do sprite ativo.
; Entrada: SI = Ponteiro para a struct Player (p1 ou p2)
; Saída: AX = Endereço da matriz de 128 bytes
; ------------------------------------------------------------------------------
get_player_sprite_ptr:
    push    bx

    mov     al, [si + Player.state]
    mov     bl, [si + Player.anim_frame]    ; BL = 0 ou 1 (para idle, walk, etc.)

    cmp     al, STATE_IDLE
    je      .idle
    cmp     al, STATE_WALK
    je      .walk
    cmp     al, STATE_JUMP
    je      .jump
    cmp     al, STATE_ATTACK
    je      .attack
    cmp     al, STATE_HIT
    je      .hit
    cmp     al, STATE_CROUCH
    je      .crouch
    jmp     .idle

; --- ESTADOS PASSIVOS ---
.idle:
    cmp     bl, 0
    jne     .idle_f1
    mov     ax, sprite_SEMB_IDLE_FRAME0
    jmp     .done
.idle_f1:
    mov     ax, sprite_SEMB_IDLE_FRAME1
    jmp     .done

.walk:
    cmp     bl, 0
    jne     .walk_f1
    mov     ax, sprite_SEMB_WALK_FRAME0
    jmp     .done
.walk_f1:
    mov     ax, sprite_SEMB_WALK_FRAME1
    jmp     .done

.jump:
    mov     ax, sprite_SEMB_JUMP_FRAME0
    jmp     .done

.hit:
    mov     ax, sprite_SEMB_HIT_FRAME0
    jmp     .done

.crouch:
    cmp     bl, 0
    jne     .crouch_f1
    mov     ax, sprite_SEMB_CROUCH_FRAME0
    jmp     .done
.crouch_f1:
    mov     ax, sprite_SEMB_CROUCH_FRAME1
    jmp     .done

; --- ESTADO DE ATAQUE ---
.attack:
    cmp     byte [si + Player.attack_type], ATTACK_TYPE_KICK
    je      .kick

    ; --- SOCO ---
    mov     al, [si + Player.attack_timer]
    cmp     al, 9
    jg      .punch_startup          ; Timer 12..10: Startup (f0)
    cmp     al, 4
    jg      .punch_active           ; Timer 9..5: Active (f1)

.punch_recovery:
    mov     ax, sprite_SEMB_PUNCH_FRAME2     ; Timer 4..1: Recovery (f2)
    jmp     .done

.punch_active:
    mov     ax, sprite_SEMB_PUNCH_FRAME1
    jmp     .done

.punch_startup:
    mov     ax, sprite_SEMB_PUNCH_FRAME0
    jmp     .done

.kick:
    ; --- CHUTE ---
    mov     al, [si + Player.attack_timer]
    cmp     al, 9
    jg      .kick_startup           ; Timer 12..10: Startup (f0)
    cmp     al, 4
    jg      .kick_active            ; Timer 9..5: Active (f1)

.kick_recovery:
    mov     ax, sprite_SEMB_KICK_FRAME2      ; Timer 4..1: Recovery (f2)
    jmp     .done

.kick_active:
    mov     ax, sprite_SEMB_KICK_FRAME1
    jmp     .done

.kick_startup:
    mov     ax, sprite_SEMB_KICK_FRAME0

.done:
    pop     bx
    ret