; ==============================================================================
; HEADER: player.inc
; DESCRIÇÃO: Definições da estrutura dos lutadores, constantes padrão e símbolos externos
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef PLAYER_INC
%define PLAYER_INC

; -----------------------------------------------------------------------------
; Constantes de inicialização
; -----------------------------------------------------------------------------
PLAYER_MAX_HP   equ 10        ; Cada lutador inicia com 10 de energia
DIR_RIGHT       equ 0         ; Olhando para a direita (P1)
DIR_LEFT        equ 1         ; Olhando para a esquerda (P2)
P1_START_X      equ 150       ; Posição X inicial P1
P2_START_X      equ 490       ; Posição X inicial P2

; -----------------------------------------------------------------------------
; Constantes do ciclo de ataque
; -----------------------------------------------------------------------------
ATTACK_TOTAL_DURATION   equ 12    ; Duração total do golpe
ATTACK_STARTUP_FRAMES   equ 3     ; Preparação
ATTACK_ACTIVE_FRAMES    equ 5     ; Janela Ativa
ATTACK_RECOVERY_FRAMES  equ 4     ; Recolhimento

; -----------------------------------------------------------------------------
; Struct do lutador
; -----------------------------------------------------------------------------
STRUC Player
    .x              resw 1    ; Posição X atual na tela
    .y              resw 1    ; Posição Y atual na tela
    .old_x          resw 1    ; Posição X no frame anterior
    .old_y          resw 1    ; Posição Y no frame anterior
    .vx             resw 1    ; Velocidade horizontal
    .vy             resw 1    ; Velocidade vertical
    .hp             resb 1    ; Energia atual (10 a 0)
    .state          resb 1    ; Estado atual
    .old_state      resb 1    ; Estado no frame anterior
    .dir            resb 1    ; Direção que está olhando
    .color          resb 1    ; Cor escolhida
    .rounds         resb 1    ; Rounds vencidos
    .is_grounded    resb 1    ; 1 = No chão, 0 = No ar
    .attack_active  resb 1    ; 1 = Hitbox de ataque ativa no frame
    .attack_timer   resb 1    ; Frames restantes da janela de ataque
    .attack_type    resb 1    ; 0 = ATTACK_TYPE_PUNCH, 1 = ATTACK_TYPE_KICK
    .stun_timer     resb 1    ; Frames de atordoamento/recuperação
    .anim_frame     resb 1    ; Frame atual da animação (0 ou 1) 
    .anim_timer     resb 1    ; Contador de ciclos para trocar o frame
.size:
ENDSTRUC

%ifndef PLAYER_ASM
extern player_init
extern player_draw_all
extern player_update_input
extern p1
extern p2
%endif

%endif