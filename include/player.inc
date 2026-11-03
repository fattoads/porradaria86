; HEADER: player.inc
; DESCRIÇÃO: Definições da estrutura dos lutadores, constantes padrão e símbolos externos
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================


%ifndef PLAYER_INC
%define PLAYER_INC

%include "include/action.inc" ; Importa os enums de estado/ação (Idle, Walk, Punch, etc.)

; -----------------------------------------------------------------------------
; 1. Constantes Iniciais e de Direção
; -----------------------------------------------------------------------------
PLAYER_MAX_HP   equ 10        ; Regra: cada lutador inicia o round com 10 de energia

DIR_RIGHT       equ 0         ; Olhando para a direita (Padrão inicial do P1)
DIR_LEFT        equ 1         ; Olhando para a esquerda (Padrão inicial do P2)

P1_START_X      equ 150       ; Posição X inicial do Jogador 1 na arena
P2_START_X      equ 490       ; Posição X inicial do Jogador 2 na arena
GROUND_Y        equ 456       ; Altura padrão do chão da arena (ajustar conforme ui.asm)

; -----------------------------------------------------------------------------
; 2. Estrutura de Dados do Lutador (STRUC Player)
; -----------------------------------------------------------------------------
; Define os offsets de memória para acessar os atributos de P1 e P2
STRUC Player
    .x          resw 1        ; Posição X atual na tela (0 a 639) - 2 bytes (word)
    .y          resw 1        ; Posição Y atual na tela (0 a 479) - 2 bytes (word)
    .old_x      resw 1        ; Posição X no frame anterior (para apagar sem flicker)
    .old_y      resw 1        ; Posição Y no frame anterior (para apagar sem flicker)
    .vx         resw 1        ; Velocidade horizontal - 2 bytes (word com sinal)
    .vy         resw 1        ; Velocidade vertical (para pulo/gravidade) - 2 bytes
    .hp         resb 1        ; Energia atual (inicia em 10, perde 1 por golpe) - 1 byte
    .state      resb 1        ; Estado atual do lutador (valores vindos do action.inc)
    .dir        resb 1        ; Direção que está olhando (DIR_RIGHT ou DIR_LEFT)
    .color      resb 1        ; Cor escolhida na tela de seleção (valores do linec.inc)
    .rounds     resb 1        ; Quantidade de rounds vencidos (melhor de 3)
    .size:                    ; Rótulo especial do NASM que guarda o tamanho total da struct
ENDSTRUC

; -----------------------------------------------------------------------------
; 3. Símbolos Exportados (Disponíveis para main.asm, physics.asm, ui.asm, etc.)
; -----------------------------------------------------------------------------
; Instâncias dos jogadores alocadas no player.asm
EXTERN p1
EXTERN p2

; Rotinas públicas do player.asm
EXTERN player_init            ; Reseta posições, velocidades e HP=10 no início do round
EXTERN player_erase_all       ; Apaga os jogadores nas coordenadas .old_x e .old_y
EXTERN player_draw_all        ; Desenha os jogadores nas coordenadas .x e .y atuais

%endif