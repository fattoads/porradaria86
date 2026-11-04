; ==============================================================================
; HEADER / INCLUDE: action.inc
; DESCRIÇÃO: Definições de enums de ação, constantes de física e protótipos
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef ACTION_INC
%define ACTION_INC

; ------------------------------------------------------------------------------
; Enum de estado do lutador
; ------------------------------------------------------------------------------
STATE_IDLE      equ 0
STATE_WALK      equ 1
STATE_JUMP      equ 2
STATE_ATTACK    equ 3
STATE_HIT       equ 4
STATE_BLOCK     equ 5

; ------------------------------------------------------------------------------
; Constantes de física e arena
; ------------------------------------------------------------------------------
GRAVITY         equ 2       ; Aceleração da gravidade (px/frame^2)
JUMP_IMPULSE    equ -12     ; Velocidade inicial do pulo (px/frame, negativo = para cima)

PLAYER_WIDTH    equ 30      ; Largura da Hurtbox (caixa de recebimento de dano)
PLAYER_HEIGHT   equ 70      ; Altura da Hurtbox do jogador

ATTACK_WIDTH    equ 35      ; Largura da Hitbox de ataque
ATTACK_HEIGHT   equ 25      ; Altura da Hitbox de ataque

%ifndef ACTION_ASM

; Funções exportadas de action.asm
extern action_init
extern action_update
extern check_aabb_collision

%endif

%endif