; ==============================================================================
; HEADER: action.inc
; DESCRIÇÃO: Declarações de constantes, estruturas e protótipos para action.asm
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef ACTION_INC
%define ACTION_INC

; ------------------------------------------------------------------------------
; Enum de estados dos jogadores
; ------------------------------------------------------------------------------
STATE_IDLE      equ 0
STATE_WALK      equ 1
STATE_JUMP      equ 2
STATE_ATTACK    equ 3
STATE_HIT       equ 4
STATE_BLOCK     equ 5
STATE_CROUCH    equ 6

; ------------------------------------------------------------------------------
; Constantes de física, arena e combate
; ------------------------------------------------------------------------------
GRAVITY         equ 1       ; Aceleração da gravidade
JUMP_IMPULSE    equ -12     ; Velocidade inicial do pulo
WALL_LEFT       equ 24      ; Borda esquerda interna da arena
WALL_RIGHT      equ 615     ; Borda direita interna da arena

PLAYER_WIDTH    equ 30      ; Largura da Hurtbox
PLAYER_HEIGHT   equ 70      ; Altura da Hurtbox em pé
CROUCH_HEIGHT   equ 35      ; Altura da Hurtbox agachado

PUNCH_WIDTH     equ 35      ; Largura da Hitbox do soco
PUNCH_HEIGHT    equ 22      ; Altura da Hitbox do soco

KICK_WIDTH      equ 45      ; Largura da Hitbox do chute
KICK_HEIGHT     equ 20      ; Altura da Hitbox do chute

ATTACK_TYPE_PUNCH equ 0     ; Tipo de ataque: Soco
ATTACK_TYPE_KICK  equ 1     ; Tipo de ataque: Chute

%ifndef ACTION_ASM
extern action_init
extern action_update
extern check_aabb_collision
%endif

%endif
