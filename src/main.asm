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

; Flag para desenhar a mensagem de game over apenas uma vez
gameover_drawn          db 0

; Guarda o estado anterior ao pedido de confirmacao de saida do jogo
prev_game_state         db STATE_PLAYING

; Paleta de 4 cores disponíveis na seleção
color_palette           db cyan_claro, rosa, verde, vermelho
p1_color_idx            db 0            ; Índice inicial P1 (0 = cyan_claro)
p2_color_idx            db 1            ; Índice inicial P2 (1 = rosa)
select_step             db 0            ; 0 = P1 escolhendo, 1 = P2 escolhendo
select_needs_redraw     db 1            ; 1 = Precisa redesenhar a caixa de seleção
select_key_lock         db 0            ; Debounce para teclas do menu (W/S/Setas/Enter)

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

    ; Desenha a moldura da arena e títulos
    call    ui_draw_arena

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

    ; Primeiro, consideramos as teclas que afetam o estado global do jogo (pausa e encerramento).
    ; Tecla Q: Encerra a aplicação
    mov     al, SCANCODE_Q
    call    is_key_pressed
    cmp     al, 1
    je      .handle_quit_key

    ; Tecla P: Alterna estado de pausa
    mov     al, SCANCODE_P
    call    is_key_pressed
    cmp     al, 1
    je      .handle_pause_key
    
    ; Se P não está apertada, reseta o flag de debounce
    mov     byte [p_key_was_pressed], 0
    jmp     .update_state

.handle_pause_key:
    ; Só alterna a pausa se a tecla P não estava pressionada no quadro anterior
    cmp     byte [p_key_was_pressed], 0
    jne     .update_state
    mov     byte [p_key_was_pressed], 1     ; Marca que P está pressionada

    ; Inverte o estado entre PLAYING e PAUSED
    cmp     byte [game_state], STATE_PLAYING
    je      .set_paused
    cmp     byte [game_state], STATE_PAUSED
    je      .set_playing
    jmp     .update_state

.set_paused:
    mov     byte [game_state], STATE_PAUSED
    call    ui_draw_pause                  ; Tela de pausa só precisa ser desenhada 1 vez
    jmp     .update_state

.set_playing:
    mov     byte [game_state], STATE_PLAYING
    call    ui_draw_arena                   ; Arena só precisa ser desenhada 1 vez
    jmp     .update_state

.handle_quit_key:
    ; Se já estamos na tela de confirmação, não sobrescreve prev_game_state
    cmp     byte [game_state], STATE_CONFIRM_QUIT
    je      .update_state

    ; Salva o estado atual, muda para confirmação e desenha a caixa 1 vez
    mov     al, [game_state]
    mov     [prev_game_state], al
    mov     byte [game_state], STATE_CONFIRM_QUIT
    call    ui_draw_confirm_quit
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
    jmp     .render_frame

.state_select_logic:
    ; Atualiza as cores nas structs para visualização em tempo real dos bonecos
    xor     bx, bx
    mov     bl, [p1_color_idx]
    mov     al, [color_palette + bx]
    mov     [p1 + Player.color], al

    mov     bl, [p2_color_idx]
    mov     al, [color_palette + bx]
    mov     [p2 + Player.color], al

    ; Redesenha o menu apenas quando houver mudança
    cmp     byte [select_needs_redraw], 0
    je      .check_select_input

    mov     al, [p1_color_idx]
    mov     ah, [p2_color_idx]
    mov     bl, [select_step]
    call    ui_draw_select
    mov     byte [select_needs_redraw], 0

.check_select_input:
    ; Se uma tecla do menu ainda está segurada, aguarda soltar todas (debounce)
    cmp     byte [select_key_lock], 0
    je      .read_select_keys

    mov     al, SCANCODE_W
    call    is_key_pressed
    mov     bl, al
    mov     al, SCANCODE_S
    call    is_key_pressed
    or      bl, al
    mov     al, SCANCODE_UP
    call    is_key_pressed
    or      bl, al
    mov     al, SCANCODE_DOWN
    call    is_key_pressed
    or      bl, al
    mov     al, SCANCODE_ENTER
    call    is_key_pressed
    or      bl, al
    cmp     bl, 0
    jne     .render_frame
    mov     byte [select_key_lock], 0

.read_select_keys:
    cmp     byte [select_step], 0
    je      .p1_select_turn

    ; --- VEZ DO JOGADOR 2 (Setas Cima/Baixo e Enter) ---
    mov     al, SCANCODE_UP
    call    is_key_pressed
    cmp     al, 1
    je      .p2_prev_color

    mov     al, SCANCODE_DOWN
    call    is_key_pressed
    cmp     al, 1
    je      .p2_next_color

    mov     al, SCANCODE_ENTER
    call    is_key_pressed
    cmp     al, 1
    je      .confirm_p2_and_start
    jmp     .render_frame

.p2_prev_color:
    dec     byte [p2_color_idx]
    and     byte [p2_color_idx], 03h    ; Wrap-around entre 0 e 3
    mov     al, [p2_color_idx]
    cmp     al, [p1_color_idx]
    je      .p2_prev_color              ; Pula a cor já escolhida pelo P1
    mov     byte [select_key_lock], 1
    mov     byte [select_needs_redraw], 1
    jmp     .render_frame

.p2_next_color:
    inc     byte [p2_color_idx]
    and     byte [p2_color_idx], 03h    ; Wrap-around entre 0 e 3
    mov     al, [p2_color_idx]
    cmp     al, [p1_color_idx]
    je      .p2_next_color              ; Pula a cor já escolhida pelo P1
    mov     byte [select_key_lock], 1
    mov     byte [select_needs_redraw], 1
    jmp     .render_frame

.confirm_p2_and_start:
    mov     byte [select_key_lock], 1
    ; Limpa a caixa de seleção redesenhando a tela e inicia a partida
    call    video_init
    call    ui_draw_arena
    call    start_game
    jmp     .render_frame

    ; --- VEZ DO JOGADOR 1 (W/S e Enter) ---
.p1_select_turn:
    mov     al, SCANCODE_W
    call    is_key_pressed
    cmp     al, 1
    je      .p1_prev_color

    mov     al, SCANCODE_S
    call    is_key_pressed
    cmp     al, 1
    je      .p1_next_color

    mov     al, SCANCODE_ENTER
    call    is_key_pressed
    cmp     al, 1
    je      .confirm_p1_choice
    jmp     .render_frame

.p1_prev_color:
    dec     byte [p1_color_idx]
    and     byte [p1_color_idx], 03h    ; Wrap-around entre 0 e 3
    mov     byte [select_key_lock], 1
    mov     byte [select_needs_redraw], 1
    jmp     .render_frame

.p1_next_color:
    inc     byte [p1_color_idx]
    and     byte [p1_color_idx], 03h    ; Wrap-around entre 0 e 3
    mov     byte [select_key_lock], 1
    mov     byte [select_needs_redraw], 1
    jmp     .render_frame

.confirm_p1_choice:
    mov     byte [select_step], 1       ; Passa a vez para o P2
    mov     byte [select_key_lock], 1
    mov     byte [select_needs_redraw], 1
    ; Se o cursor inicial do P2 coincidir com a cor que P1 escolheu, avança 1 posição
    mov     al, [p2_color_idx]
    cmp     al, [p1_color_idx]
    jne     .render_frame
    inc     byte [p2_color_idx]
    and     byte [p2_color_idx], 03h
    jmp     .render_frame

.state_playing_logic:
    ; Leitura de inputs de movimento dos lutadores
    call    player_update_input

    ; Atualização da física, colisões e dano
    call    action_update

    ; Verifica se algum HP chegou a 0 (KO) ou se os 180s acabaram
    call    check_round_rules

    jmp     .render_frame

.state_paused_logic:
    jmp     .render_frame

.state_gameover_logic:
    ; Desenha a caixa de Game Over apenas uma vez ao entrar no estado
    cmp     byte [gameover_drawn], 1
    je      .check_gameover_keys

    mov     al, [match_winner]
    call    ui_draw_gameover
    mov     byte [gameover_drawn], 1

.check_gameover_keys:
    ; Tecla N: Encerra o jogo
    mov     al, SCANCODE_N
    call    is_key_pressed
    cmp     al, 1
    je      .trigger_quit

    ; Tecla Y: Reinicia a partida
    mov     al, SCANCODE_Y
    call    is_key_pressed
    cmp     al, 1
    jne     .render_frame

    ; Reseta as flags de controle da seleção
    mov     byte [gameover_drawn], 0
    mov     byte [select_step], 0
    mov     byte [select_needs_redraw], 1
    
    ; Reseta os rounds dos jogadores para uma nova partida limpa
    mov     byte [p1 + Player.rounds], 0
    mov     byte [p2 + Player.rounds], 0

    ; Restaura o visual da arena e transita para o estado de seleção
    call    video_init
    call    ui_draw_arena
    mov     byte [game_state], STATE_SELECT
    jmp     .render_frame

.render_frame:
    ; VSYNC!!! Aguarda a placa de vídeo entrar em Retrace Vertical 
    ; para desenhar/atualizar os elementos, evitando screen-tearing e reduzindo flickering
    call video_wait_vsync

    cmp     byte [game_state], STATE_PLAYING
    je      .draw_fighters
    cmp     byte [game_state], STATE_SELECT
    je      .draw_fighters
    jmp     .draw_hud_only

    ; Desenha a barra de HP dos dois jogadores
    mov    al, [p1 + Player.hp] 
    mov    ah, [p2 + Player.hp] 
    call   ui_draw_hud                     ; hud precisa ser atualizada constantemente

    jmp     .game_loop

; Limpa sprites do frame anterior e renderiza os novos
.draw_fighters:
    call    player_erase_all
    call    player_draw_all

.draw_hud_only:
    mov     al, [p1 + Player.hp]
    mov     ah, [p2 + Player.hp]
    call    ui_draw_hud
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
    jne     .render_frame

    ; Restaura o estado salvo antes de apertar Q
    mov     al, [prev_game_state]
    mov     [game_state], al

    cmp     al, STATE_PAUSED
    je      .restore_paused_ui
    cmp     al, STATE_GAMEOVER
    je      .restore_gameover_ui

    ; Se retornou para STATE_PLAYING, redesenha a arena (apaga a caixa central)
    call    ui_draw_arena
    jmp     .render_frame

.restore_paused_ui:
    call    ui_draw_pause
    jmp     .render_frame

.restore_gameover_ui:
    mov     byte [gameover_drawn], 0
    jmp     .render_frame

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