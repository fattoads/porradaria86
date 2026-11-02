; ==============================================================================
; MÓDULO: video.asm
; DESCRIÇÃO: Gerenciamento do modo de vídeo VGA 12h (640x480 16 cores),
;             salvamento/restauração de modo e sincronização VSync.
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global video_init
global video_restore
global video_wait_vsync
global orig_video_mode

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

; Guarda o modo de vídeo original do sistema para restauração ao encerrar o jogo
orig_video_mode db 0

; ------------------------------------------------------------------------------
; CS
; ------------------------------------------------------------------------------
segment code

; ------------------------------------------------------------------------------
; video_init: Consulta e armazena o modo de vídeo atual e ativa o modo VGA 12h
; ------------------------------------------------------------------------------
video_init:
    ; Salva estado
    push    ax
    push    bx

    ; Salvar modo de vídeo original
    mov     ah, 0Fh                 ; Seleciona função de consulta de modo de vídeo
    int     10h                     ; Chama serviço de vídeo da BIOS
    mov     [orig_video_mode], al   ; Salva modo original
    ; obs: INT 10h AH 0Fh retorna o modo corrente em AL, o número de colunas de caracteres na tela em AH e a página de vídeo ativa em BH

    ; Define o novo modo de vídeo para VGA 12h (640x480, 16 cores)
    mov     ah, 00h                 ; Seleciona função de definir modo de vídeo
    mov     al, 12h                 ; Seleciona o modo VGA 12h
    int     10h                     ; Chama serviço de vídeo da BIOS

    ; Restaura estado
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; video_restore: Restaura o modo de vídeo original salvo durante o video_init
; ------------------------------------------------------------------------------
video_restore:
    ; Salva estado
    push    ax

    ; Executa a chamada BIOS para alterar o modo para orig_video_mode
    mov     ah, 00h                 ; Seleciona função de definir modo de vídeo
    mov     al, [orig_video_mode]   ; Seleciona o modo orig_video_mode
    int     10h                     ; Chama serviço de vídeo da BIOS

    ; Restaura estado
    pop     ax
    ret

; ------------------------------------------------------------------------------
; video_wait_vsync: Sincronização com o Retrace Vertical do monitor.
; Essa rotina realiza um busy-wait na porta 0x03DA e retorna no início do próximo período de retrace vertical.
;
; Entre a exibição de um quadro e outro, o monitor entra em um período chamado "vertical retrace" onde o sinal de vídeo
;   retorna do final para o início da tela e a imagem não é atualizada. O início desse período é sinalizado pelo bit 3
;   da porta 0x03DA. Se a imagem é atualizada somente durante esse período, garantimos que nenhum quadro sobrescreverá
;   o anterior durante a exibição, evitando screen-tearing e flickering.
; ------------------------------------------------------------------------------
video_wait_vsync:
    ; Salva estado
    push    ax
    push    dx

    mov     dx, 03DAh           ; Porta Input Status Register 1 da VGA

.wait_retrace_end:
    in      al, dx
    test    al, 08h             ; Bit 3 = 1 durante o Retrace Vertical
    jnz     .wait_retrace_end   ; Se já estiver em retrace, aguarda terminar (Bit 3 -> 0)

.wait_retrace_start:
    in      al, dx
    test    al, 08h
    jz      .wait_retrace_start ; Aguarda o início do próximo retrace (Bit 3 -> 1)

    ; Restaura estado
    pop     dx
    pop     ax
    ret