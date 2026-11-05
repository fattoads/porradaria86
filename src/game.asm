; ==============================================================================
; HEADER: game.asm
; DESCRIÇÃO: ???
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%define GAME_ASM

%include "game.inc"
%include "player.inc"

segment data

global game_state, round_timer, match_winner

game_state      db STATE_SELECT
round_timer     dw ROUND_TIME_MAX   ; Relógio de 180 segundos
match_winner    db 0                ; 0 = empate, 1 = player1, 2 = player2
game_winner     db 0
current_round   db 1


segment code

; Função para iniciar o jogo
start_game:
    push    ax
    
    mov     byte [p1 + Player.rounds], 0
    mov     byte [p2 + Player.rounds], 0

    call    start_round

    pop     ax
    ret

; Função para iniciar um round
start_round:
    push    ax

    mov     word [round_timer], ROUND_TIME_MAX
    call    player_init                    ;Funcao q inicializa player
    mov     byte [game_state], STATE_PLAYING

    pop     ax
    ret

check_round_rules:
    push    ax
    
    ; 1. Primeiro verifica se houve KO
    call    check_ko
    cmp     byte [match_winner], 0
    jne     .end_check_round_rules

    ; 2. Se ninguém sofreu KO, verifica se o tempo do relógio acabou
    call    check_end_time

.end_check_round_rules:
    pop     ax
    ret

check_ko:
    push    ax

    ; Verifica HP do Player1
    mov     al,[p1 + Player.hp]
    cmp     al, 0
    jle     .p2_wins_round              ; Se P1 <= 0, P2 venceu o round


    mov     al,[p2 + Player.hp]
    cmp     al, 0
    jle     .p1_wins_round              ; Se P2 <= 0, P1 venceu o round

    jmp     .ko_done

.p1_wins_round:
    mov     byte [match_winner], 1      ; Marca provisoriamente que P1 ganhou o round
    call    register_round_win         ; Contabiliza o ponto e gerencia melhor de 3
    jmp     .ko_done

.p2_wins_round:
    mov     byte [match_winner], 2      ; Marca provisoriamente que P2 ganhou o round
    call    register_round_win         ; Contabiliza o ponto e gerencia melhor de 3

.ko_done:
    pop     ax
    ret

check_end_time:
    push    ax

    ; Verifica se o cronômetro de 180 segundos (word) chegou a zero
    cmp     word [round_timer], 0
    jg      .time_done                   ; Se round_timer > 0, o round continua normalmente

    ; Tempo esgotado: compara o HP atual do Jogador 1 e do Jogador 2
    mov     al, [p1 + Player.hp]
    mov     ah, [p2 + Player.hp]
    cmp     al, ah
    jge     .p1_wins_time                ; Se HP_P1 > HP_P2, Jogador 1 vence o round
    jmp     .p2_wins_time                ; Se HP_P1 < HP_P2, Jogador 2 vence o round

    ; Se HP_P1 == HP_P2, aciona o critério de desempate (Morte Súbita)
    call    tie_breaker
    jmp     .time_done

.p1_wins_time:
    mov     byte [match_winner], 1      ; Marca que P1 ganhou o round
    call    register_round_win         ; Contabiliza o ponto e gerencia melhor de 3
    jmp     .time_done

.p2_wins_time:
    mov     byte [match_winner], 2      ; Marca que P2 ganhou o round
    call    register_round_win         ; Contabiliza o ponto e gerencia melhor de 3

.time_done:
    pop     ax
    ret

tie_breaker: ; Quem der o primeiro hit após o tempo acabar ganha o round
    ; Mantém o round em andamento com o relógio travado em 0.
    ; Assim que o primeiro golpe entrar, o HP de um dos jogadores cairá em 1 ponto
    ; e a próxima chamada de check_end_time detectará a diferença (JG ou JL).
    mov     word [round_timer], 0
    ret

; Contabiliza a vitória do round e verifica se a partida terminou (Melhor de 3)
register_round_win:
    push    ax

    cmp     byte [match_winner], 1
    je      .credit_p1
    cmp     byte [match_winner], 2
    je      .credit_p2
    jmp     .done_register

.credit_p1:
    inc     byte [p1 + Player.rounds]
    mov     al, [p1 + Player.rounds]
    cmp     al, ROUNDS_TO_WIN           ; Verifica se P1 alcançou 2 vitórias
    jge     .match_over
    jmp     .next_round

.credit_p2:
    inc     byte [p2 + Player.rounds]
    mov     al, [p2 + Player.rounds]
    cmp     al, ROUNDS_TO_WIN           ; Verifica se P2 alcançou 2 vitórias
    jge     .match_over

.next_round:
    ; A partida ainda não acabou: avança para o próximo round
    inc     byte [current_round]
    call    start_round                ; Reinicia timer, HP, posições e zera match_winner
    jmp     .done_register

.match_over:
    ; Um dos jogadores venceu 2 rounds: encerra a partida mantendo match_winner (1 ou 2)
    mov     byte [game_state], STATE_GAMEOVER

.done_register:
    pop     ax
    ret
