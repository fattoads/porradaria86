; ==============================================================================
; MÓDULO: main.asm
; DESCRIÇÃO: Ponto de entrada do jogo, controle da máquina de estados,
;             loop de execução e encerramento seguro.
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

; ------------------------------------------------------------------------------
; INCLUDES
; ------------------------------------------------------------------------------
%include "kbd.inc"
%include "video.inc"
%include "ui.inc"
%include "player.inc" 
%include "action.inc"
%include "game.inc"
%include "timer.inc"
%include "linec.inc"

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS / IMPORTADOS
; ------------------------------------------------------------------------------
global main

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

; Flag de execução do jogo
game_running            db 1

; "Debounce" de tecla para o toggle da Pausa (evita alternar várias vezes no mesmo clique)
p_key_was_pressed       db 0

; Mensagem de encerramento
msg_quit                db "Jogo encerrado com sucesso. Restaurando DOS...", 0Dh, 0Ah, "$"

; Guarda o estado anterior ao pedido de confirmacao de saida do jogo
prev_game_state         db STATE_PLAYING

; Paleta de 4 cores disponíveis na seleção
color_palette           db cyan_claro, rosa, verde, vermelho
p1_color_idx            db 0            ; Índice inicial P1 (0 = cyan_claro)
p2_color_idx            db 1            ; Índice inicial P2 (1 = rosa)
select_step             db 0            ; 0 = P1 escolhendo, 1 = P2 escolhendo

; ------------------------------------------------------------------------------
; CS
; ------------------------------------------------------------------------------
segment code

..start:
    ; Inicialização de registradores
    mov 	ax,data					        ; inicializa o registrador de Segmento de Dados DS e o extra ES
    mov 	ds,ax   
    mov 	es,ax
    mov 	ax,stack				        ; inicializa o registrador de Segmento de Pilha SS
    mov 	ss,ax   
    mov 	sp,stacktop				        ; inicializa o apontador de Pilha SP

    ; Configura o Modo Gráfico VGA 12h (640x480, 16 cores)
    call    video_init

    ; Instala a ISR customizada do teclado (INT 9h) e do timer (INT 1Ch)
    call    kbd_init
    call    timer_init

    ; Inicializa posições dos lutadores e configura estado inicial para seleção
    call    player_init
    mov     byte [p1 + Player.color], cyan_claro
    mov     byte [p2 + Player.color], rosa
    mov     byte [game_state], STATE_SELECT
    ; Inicializa a partida (zera rounds, seta round_timer = 180, chama player_init e ativa STATE_PLAYING)
    ; call    start_game
    ; TODO: Inicializar outros módulos e interrupts (timer...!)

; ------------------------------------------------------------------------------
; LOOP DE EXECUÇÃO
; ------------------------------------------------------------------------------
.game_loop:
    ; Verifica se o flag de execução continua ativo
    cmp     byte [game_running], 0
    je      .exit_game

    ; Limpa a tela
    call video_clear

    ; Primeiro, consideramos as teclas que afetam o estado global do jogo (pausa e encerramento).
    ; Tecla Q: Encerra a aplicação
    mov     al, SCANCODE_Q
    call    get_key_event
    cmp     al, 1
    je      .handle_quit_key

    ; Tecla P: Alterna estado de pausa
    mov     al, SCANCODE_P
    call    get_key_event
    cmp     al, 1
    je      .handle_pause_key
    
    jmp     .update_state

.handle_pause_key:
    ; Inverte o estado entre PLAYING e PAUSED
    cmp     byte [game_state], STATE_PLAYING
    je      .set_paused
    cmp     byte [game_state], STATE_PAUSED
    je      .set_playing
    jmp     .update_state

.set_paused:
    mov     byte [game_state], STATE_PAUSED
    jmp     .update_state

.set_playing:
    mov     byte [game_state], STATE_PLAYING
    jmp     .update_state

.handle_quit_key:
    ; Se já estamos na tela de confirmação, não sobrescreve prev_game_state
    cmp     byte [game_state], STATE_CONFIRM_QUIT
    je      .update_state

    ; Salva o estado atual, muda para confirmação e desenha a caixa 1 vez
    mov     al, [game_state]
    mov     [prev_game_state], al
    mov     byte [game_state], STATE_CONFIRM_QUIT
    jmp     .update_state

.trigger_quit:
    mov     byte [game_running], 0
    jmp     .game_loop  ; Próximo loop vai detectar a flag e encerrar imediatamente

; Decidimos o curso a seguir com base no estado e encerramos cada lógica com a renderização do resultado na tela.
.update_state:
    mov     al, [game_state]

    cmp     al, STATE_SELECT
    je      .state_select_logic

    cmp     al, STATE_PLAYING
    je      .state_playing_logic

    cmp     al, STATE_PAUSED
    je      .state_paused_logic

    cmp     al, STATE_CONFIRM_QUIT
    je      .state_confirm_quit_logic

    cmp     al, STATE_GAMEOVER
    je      .state_gameover_logic

    ; unreachable, mas sempre terminamos com a renderização
    jmp     .prepare_frame

.state_select_logic:
    ; Atualiza as cores nas structs para visualização em tempo real dos bonecos
    xor     bx, bx
    mov     bl, [p1_color_idx]
    mov     al, [color_palette + bx]
    mov     [p1 + Player.color], al

    mov     bl, [p2_color_idx]
    mov     al, [color_palette + bx]
    mov     [p2 + Player.color], al

    ; --- Leitura dos inputs do menu ---

    cmp     byte [select_step], 0
    je      .p1_select_turn

    ; --- VEZ DO JOGADOR 2 (Setas Cima/Baixo e Enter) ---
    mov     al, SCANCODE_UP
    call    get_key_event
    cmp     al, 1
    je      .p2_prev_color

    mov     al, SCANCODE_DOWN
    call    get_key_event
    cmp     al, 1
    je      .p2_next_color

    mov     al, SCANCODE_ENTER
    call    get_key_event
    cmp     al, 1
    je      .confirm_p2_and_start
    jmp     .prepare_frame

.p2_prev_color:
    dec     byte [p2_color_idx]
    and     byte [p2_color_idx], 03h    ; Wrap-around entre 0 e 3
    mov     al, [p2_color_idx]
    cmp     al, [p1_color_idx]
    je      .p2_prev_color              ; Pula a cor já escolhida pelo P1
    jmp     .prepare_frame

.p2_next_color:
    inc     byte [p2_color_idx]
    and     byte [p2_color_idx], 03h    ; Wrap-around entre 0 e 3
    mov     al, [p2_color_idx]
    cmp     al, [p1_color_idx]
    je      .p2_next_color              ; Pula a cor já escolhida pelo P1
    jmp     .prepare_frame

.confirm_p2_and_start:
    call    start_game
    jmp     .prepare_frame

    ; --- VEZ DO JOGADOR 1 (W/S e Enter) ---
.p1_select_turn:
    mov     al, SCANCODE_W
    call    get_key_event
    cmp     al, 1
    je      .p1_prev_color

    mov     al, SCANCODE_S
    call    get_key_event
    cmp     al, 1
    je      .p1_next_color

    mov     al, SCANCODE_ENTER
    call    get_key_event
    cmp     al, 1
    je      .confirm_p1_choice
    jmp     .prepare_frame

.p1_prev_color:
    dec     byte [p1_color_idx]
    and     byte [p1_color_idx], 03h    ; Wrap-around entre 0 e 3
    jmp     .prepare_frame

.p1_next_color:
    inc     byte [p1_color_idx]
    and     byte [p1_color_idx], 03h    ; Wrap-around entre 0 e 3
    jmp     .prepare_frame

.confirm_p1_choice:
    mov     byte [select_step], 1       ; Passa a vez para o P2
    ; Se o cursor inicial do P2 coincidir com a cor que P1 escolheu, avança 1 posição
    mov     al, [p2_color_idx]
    cmp     al, [p1_color_idx]
    jne     .prepare_frame
    inc     byte [p2_color_idx]
    and     byte [p2_color_idx], 03h
    jmp     .prepare_frame

.state_playing_logic:
    ; Leitura de inputs de movimento dos lutadores
    call    player_update_input

    ; Atualização da física, colisões e dano
    call    action_update

    ; Verifica se algum HP chegou a 0 (KO) ou se os 180s acabaram
    call    check_round_rules

    jmp     .prepare_frame

.state_paused_logic:
    jmp     .prepare_frame

.state_gameover_logic:
    ; Tecla N: Encerra o jogo
    mov     al, SCANCODE_N
    call    is_key_pressed
    cmp     al, 1
    je      .trigger_quit

    ; Tecla Y: Reinicia a partida
    mov     al, SCANCODE_Y
    call    is_key_pressed
    cmp     al, 1
    jne     .prepare_frame

    ; Reseta a flag de controle da seleção
    mov     byte [select_step], 0
    
    ; Reseta os rounds dos jogadores para uma nova partida limpa
    mov     byte [p1 + Player.rounds], 0
    mov     byte [p2 + Player.rounds], 0

    ; Restaura o estado de seleção
    mov     byte [game_state], STATE_SELECT

; --- COMPOSIÇÃO DA CENA ---
.prepare_frame:
    call    ui_draw_arena               ; Arena sempre é desenhada
    call    player_draw_all             ; Lutadores sempre são desenhados

    mov     al, [game_state]            ; Verificamos o estado e carregamos seus componentes específicos no frame

    cmp     al, STATE_SELECT
    je      .draw_select_scene

    cmp     al, STATE_PLAYING
    je      .draw_playing_scene

    cmp     al, STATE_PAUSED
    je      .draw_paused_scene

    cmp     al, STATE_CONFIRM_QUIT
    je      .draw_confirm_quit_scene

    cmp     al, STATE_GAMEOVER
    je      .draw_gameover_scene

    jmp     .render_frame

.draw_select_scene:
    mov     al, [p1_color_idx]
    mov     ah, [p2_color_idx]
    mov     bl, [select_step]
    call    ui_draw_select
    jmp     .render_frame

.draw_playing_scene:
    mov     al, [p1 + Player.hp]
    mov     ah, [p2 + Player.hp]
    call    ui_draw_hud
    jmp     .render_frame

.draw_paused_scene:
    mov     al, [p1 + Player.hp]
    mov     ah, [p2 + Player.hp]
    call    ui_draw_hud
    call    ui_draw_pause               ; Sobrepõe a caixa de pausa
    jmp     .render_frame

.draw_confirm_quit_scene:
    mov     al, [p1 + Player.hp]
    mov     ah, [p2 + Player.hp]
    call    ui_draw_hud
    call    player_draw_all
    call    ui_draw_confirm_quit        ; Sobrepõe a caixa de confirmação
    jmp     .render_frame

.draw_gameover_scene:
    mov     al, [p1 + Player.hp]
    mov     ah, [p2 + Player.hp]
    call    ui_draw_hud
    call    player_draw_all
    mov     al, [match_winner]
    call    ui_draw_gameover

.render_frame:
    call    video_render
    jmp     .game_loop

.state_confirm_quit_logic:
    ; Tecla Y: Confirma a saída e encerra o jogo
    mov     al, SCANCODE_Y
    call    is_key_pressed
    cmp     al, 1
    je      .trigger_quit

    ; Tecla N: Cancela e retorna ao estado anterior
    mov     al, SCANCODE_N
    call    is_key_pressed
    cmp     al, 1
    jne     .prepare_frame

    ; Restaura o estado salvo antes de apertar Q
    mov     al, [prev_game_state]
    mov     [game_state], al
    jmp     .prepare_frame

; Restauração do estado pré-execução e retorno ao DOS
.exit_game:
    ; Restaura as ISRs originais (INT 1Ch e INT 9h)
    call    timer_restore
    call    kbd_restore

    ; Restaura o modo de vídeo original do sistema
    call    video_restore

    ; Exibe mensagem de finalização no DOS no modo texto
    mov     dx, msg_quit
    mov     ah, 09h
    int     21h

    ; Retorna o controle ao DOS com código de saída 0
    mov     ax, 4C00h
    int     21h

; ------------------------------------------------------------------------------
; SS
; ------------------------------------------------------------------------------
segment stack stack
    resb 1024                ; Reserva 1024 bytes de pilha para o programa
stacktop: