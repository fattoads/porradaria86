; HEADER: game.inc
; DESCRIÇÃO: ???
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================
%ifndef GAME_INC
%define GAME_INC

; Máquina de Estados Principal
STATE_SELECT        equ 0
STATE_PLAYING       equ 1
STATE_PAUSED        equ 2
STATE_CONFIRM_QUIT  equ 3
STATE_ROUND_OVER    equ 4
STATE_GAMEOVER      equ 5

; Regras da Partida
ROUND_TIME_MAX      equ 180   ; 3 minutos = 180 segundos
ROUNDS_TO_WIN       equ 2     ; Melhor de 3 (quem fizer 2 vence)

; Variáveis e funções exportadas pelo game.asm
EXTERN game_state, round_timer, match_winner
EXTERN game_init_match, game_init_round, game_update_rules
EXTERN game_handle_select, game_handle_gameover

%endif