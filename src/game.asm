; HEADER: game.asm
; DESCRIÇÃO: ???
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%include "include/game.inc"
%include "include/player.inc"

segment data
    global game_state, round_timer, match_winner

    game_state db STATE_SELECT
    round_timer dw ROUND_TIME_MAX   ; Relógio de 180 segundos
    match_winner db 0               ; 0 = empate, 1 = player1, 2 = player2

segment code
    
    ; Função para iniciar o jogo
    start_game:
        push ax
        
        mov byte [p1 + Player.rounds], 0
        mov byte [p2 + Player.rounds], 0

        mov byte[game_winner], 0
        mov byte [current_round], 1


        call start_round

        pop ax
        ret
    ; Função para iniciar um round
    start_round:
        push ax

        mov word [round_timer], ROUND_TIME_MAX
        call player init                    ;Funcao q inicializa player
        mov byte [game_state], STATE_PLAYING

        pop ax
        ret

    check_round_rules:
        push ax
        
        ; 1. Primeiro verifica se houve KO
        call check_ko
        cmp byte [match_winner], 0
        jne .end_check_round_rules

        ; 2. Se ninguém sofreu KO, verifica se o tempo do relógio acabou
        call check_end_time

    .end_check_round_rules:
        pop ax
        ret
    
    
    check_ko:
        push ax

        ; Verifica HP do Player1
        mov al,[p1 + Player.hp]
        cmp al, 0
        jle .p2_wins_round              ; Se P1 <= 0, P2 venceu o round


        mov al,[p2 + Player.hp]
        cmp al, 0
        jle .p1_wins_round              ; Se P2 <= 0, P1 venceu o round

        jmp .ko_done

    .p1_wins_round:
        mov byte [match_winner], 1      ; Marca provisoriamente que P1 ganhou o round
        call register_round_win         ; Contabiliza o ponto e gerencia melhor de 3
        jmp .ko_done

    .p2_wins_round:
        mov byte [match_winner], 2      ; Marca provisoriamente que P2 ganhou o round
        call register_round_win         ; Contabiliza o ponto e gerencia melhor de 3

    .ko_done:
        pop ax
        ret

    check_end_time:

    tie_breaker: ;Quem der o primeiro hit apos o tempo acabar ganha o round

