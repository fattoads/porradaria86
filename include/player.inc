; ==============================================================================
; HEADER: player.inc
; DESCRIÇÃO: Definições da estrutura dos lutadores, constantes padrão e símbolos externos
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef PLAYER_INC
%define PLAYER_INC

; Constantes de inicialização
PLAYER_MAX_HP   equ 10        ; Regra: cada lutador inicia o round com 10 de energia
DIR_RIGHT       equ 0         ; Olhando para a direita (Padrão inicial do P1)
DIR_LEFT        equ 1         ; Olhando para a esquerda (Padrão inicial do P2)
P1_START_X      equ 150       ; Posição X inicial do Jogador 1 na arena
P2_START_X      equ 490       ; Posição X inicial do Jogador 2 na arena

; Constantes do ciclo de ataque
ATTACK_TOTAL_DURATION   equ 12        ; Duração total da animação de golpe (~0.2s a 60 FPS)
ATTACK_STARTUP_FRAMES   equ 3         ; Frames de preparação (hitbox inativa: timer 12..10)
ATTACK_ACTIVE_FRAMES    equ 5         ; Janela de impacto e clash (hitbox ativa: timer 9..5)
ATTACK_RECOVERY_FRAMES  equ 4         ; Janela de recolhimento (hitbox inativa: timer 4..1)

; -----------------------------------------------------------------------------
; Struct do lutador (Player)
; -----------------------------------------------------------------------------
STRUC Player
    .x              resw 1    ; Posição X atual na tela (0 a 639) - 2 bytes (word)
    .y              resw 1    ; Posição Y atual na tela (0 a 479) - 2 bytes (word)
    .old_x          resw 1    ; Posição X no frame anterior (para apagar sem flicker)
    .old_y          resw 1    ; Posição Y no frame anterior (para apagar sem flicker)
    .vx             resw 1    ; Velocidade horizontal - 2 bytes (word com sinal)
    .vy             resw 1    ; Velocidade vertical (para pulo/gravidade) - 2 bytes
    .hp             resb 1    ; Energia atual (inicia em 10, perde 1 por golpe) - 1 byte
    .state          resb 1    ; Estado atual do lutador (valores do action.inc)
    .dir            resb 1    ; Direção que está olhando (DIR_RIGHT ou DIR_LEFT)
    .color          resb 1    ; Cor escolhida na tela de seleção
    .rounds         resb 1    ; Quantidade de rounds vencidos (melhor de 3)
    .is_grounded    resb 1    ; 1 = No chão, 0 = No ar
    .attack_active  resb 1    ; 1 = Hitbox de ataque ativa no frame
    .attack_timer   resb 1    ; Frames restantes da janela de ataque
    .stun_timer     resb 1    ; Frames restantes de atordoamento/recuperação
.size:                        ; Guarda o tamanho total da struct
ENDSTRUC

%ifndef PLAYER_ASM

; Funções exportadas de player.asm
extern player_init            ; Reseta posições, velocidades e HP=10 no início do round
extern player_erase_all       ; Apaga os jogadores nas coordenadas .old_x e .old_y
extern player_draw_all        ; Desenha os jogadores nas coordenadas .x e .y atuais
extern player_update_input    ; Lê o teclado e ajusta intenções de movimento/ataque

; Variáveis exportadas de player.asm (Instâncias dos dois jogadores)
extern p1
extern p2

%endif

%endif