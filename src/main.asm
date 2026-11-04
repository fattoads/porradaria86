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

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS / IMPORTADOS
; ------------------------------------------------------------------------------
global main

; ------------------------------------------------------------------------------
; ESTADO DO JOGO
; ------------------------------------------------------------------------------
STATE_SELECT            equ 0  ; Seleção de personagem
STATE_PLAYING           equ 1  ; Jogo em andamento
STATE_PAUSED            equ 2  ; Jogo pausado
STATE_GAMEOVER          equ 3  ; Tela de Game Over

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

; Estado atual do jogo - iniciando direto no jogo pra testes iniciais
game_state              db STATE_PLAYING

; Flag de execução do jogo
game_running            db 1

; "Debounce" de tecla para o toggle da Pausa (evita alternar várias vezes no mesmo clique)
p_key_was_pressed       db 0

; Pontos de Vida (HP) dos jogadores (0 a 10) 
; TODO: mover para player.asm. tá aqui somente pra testes
hp_p1                   db 10 
hp_p2                   db 10

; Mensagem de encerramento
msg_quit                db "Jogo encerrado com sucesso. Restaurando DOS...", 0Dh, 0Ah, "$"

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

    ; Instala a ISR customizada do teclado
    call    kbd_init

    ; Desenha a moldura da arena e títulos
    call    ui_draw_arena

    ; Inicializa as estruturas dos lutadores p1 e p2
    call    player_init
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
    je      .trigger_quit

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

    cmp     al, STATE_GAMEOVER
    je      .state_gameover_logic

    ; unreachable, mas sempre terminamos com a renderização
    jmp     .render_frame

.state_select_logic:
    ; TODO: Lógica e desenho da tela de seleção de personagens
    jmp     .render_frame

.state_playing_logic:
    ; Leitura de inputs de movimento dos lutadores
    call    player_update_input

    ; Atualização da física e interações
    call    action_update

    ; TODO: Processar dano e regras (game.asm)
    jmp     .render_frame

.state_paused_logic:
    jmp     .render_frame

.state_gameover_logic:
    ; TODO: Desenhar a tela de Game Over e placar final (ui.asm)
    jmp     .render_frame

.render_frame:
    ; VSYNC!!! Aguarda a placa de vídeo entrar em Retrace Vertical 
    ; para desenhar/atualizar os elementos, evitando screen-tearing e reduzindo flickering
    call video_wait_vsync

    ; Limpa sprites do frame anterior e renderiza os novos
    call    player_erase_all
    call    player_draw_all

    ; Desenha a barra de HP dos dois jogadores
    mov    al, [p1 + Player.hp] 
    mov    ah, [p2 + Player.hp] 
    call   ui_draw_hud                     ; hud precisa ser atualizada constantemente

    jmp     .game_loop

; Restauração do estado pré-execução e retorno ao DOS
.exit_game:
    ; Restaura a ISR original da INT 9h
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