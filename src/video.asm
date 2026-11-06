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
global video_render
global video_clear
global orig_video_mode

global plane0_seg
global plane1_seg
global plane2_seg
global plane3_seg

; ==============================================================================
; SEGMENTOS DE BUFFER DE VÍDEO
; ==============================================================================

; Os buffers de vídeo possuem 38400 bytes = 2400 parágrafos, e o DOS só permite 64KB por segmento.
; Tentei alocação dinâmica, mas o DOS aparentemente não permite solicitação extra de memória em tempo de execução!
; Logo, precisamos alocar um segmento separado para cada buffer.

segment plane0 align=16
    plane0_buf  resb 38400

segment plane1 align=16
    plane1_buf  resb 38400

segment plane2 align=16
    plane2_buf  resb 38400

segment plane3 align=16
    plane3_buf  resb 38400

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

; Guarda o modo de vídeo original do sistema para restauração ao encerrar o jogo
orig_video_mode db 0

; Planos de exibição do VGA 12h
plane0_seg  dw 0    ; Plano 0 (Bit 0 da cor - Azul)
plane1_seg  dw 0    ; Plano 1 (Bit 1 da cor - Verde)
plane2_seg  dw 0    ; Plano 2 (Bit 2 da cor - Vermelho)
plane3_seg  dw 0    ; Plano 3 (Bit 3 da cor - Intensidade)

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

    ; Armazenamos o endereço de cada segmento (ergo, de cada buffer) na variável global correspondente
    mov     ax, plane0
    mov     [plane0_seg], ax

    mov     ax, plane1
    mov     [plane1_seg], ax

    mov     ax, plane2
    mov     [plane2_seg], ax

    mov     ax, plane3
    mov     [plane3_seg], ax

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
; video_render: Transfere os 4 planos de vídeo da RAM para a VRAM (0xA000:0000).
; ------------------------------------------------------------------------------
video_render:
    ; Salva estado
    push    ax
    push    cx
    push    dx
    push    si
    push    di
    push    es

    ; Aqui, realizamos um busy-wait na porta 0x03DA para detectar o início do próximo período de retrace vertical.
    ;
    ; Entre a exibição de um quadro e outro, o monitor entra em um período chamado "vertical retrace" onde o sinal de vídeo
    ;   retorna do final para o início da tela e a tela não é atualizada. O início desse período é sinalizado pelo bit 3
    ;   da porta 0x03DA. Se o vídeo é atualizado somente durante esse período, garantimos que nenhum quadro sobrescreverá
    ;   o anterior durante a exibição, evitando screen-tearing e flickering.
    mov     dx, 03DAh
.wait_vsync_off:
    in      al, dx
    test    al, 08h
    jnz     .wait_vsync_off
.wait_vsync_on:
    in      al, dx
    test    al, 08h
    jz      .wait_vsync_on

    ; --- Configura segmento de destino para a VRAM ---
    mov     ax, 0A000h
    mov     es, ax

    ; -- Configura porta de escrita (ver comentário abaixo) ---
    mov     dx, 03C4h

    ; Agora, precisamos copiar os nossos buffers de vídeo para seus respectivos planos na VRAM.
    ; Para fazer isso, selecionamos a porta de escrita do VGA Sequencer Index, por meio da qual
    ;   selecionaremos o registrador onde queremos escrever.
    ; Então, selecionamos o registrador Map Mask, que permite a seleção do plano, e selecionamos o plano desejado.
    ; Então, selecionamos nosso endereço de fonte e destino (Buffer na RAM, segmento da VRAM) em SI e DI,
    ;   calculamos o número de words que queremos transferir (metade do tamanho do buffer/plano em bytes)
    ;   e usamos a instrução 'rep movsw' para fazer a cópia massiva dessas words da fonte pro destino.
    ; --------------------------------------------------------------------------
    ; PLANO 0 (AZUL)
    ; --------------------------------------------------------------------------
    mov     ax, 0102h           ; Map Mask Register (Index 2) = Select Plane 0 (01h)
    out     dx, ax

    push    ds
    mov     ds, [plane0_seg]
    xor     si, si              ; Fonte (RAM):      DS:SI = plane0_seg:0000
    xor     di, di              ; Destino (VRAM):   ES:DI = 0xA000:0000
    mov     cx, 19200           ; 38.400 bytes / 2 = 19.200 words
    rep movsw
    pop     ds

    ; --------------------------------------------------------------------------
    ; PLANO 1 (VERDE)
    ; --------------------------------------------------------------------------
    mov     ax, 0202h           ; Select Plane 1 (02h)
    out     dx, ax

    push    ds
    mov     ds, [plane1_seg]
    xor     si, si
    xor     di, di
    mov     cx, 19200
    rep movsw
    pop     ds

    ; --------------------------------------------------------------------------
    ; PLANO 2 (VERMELHO)
    ; --------------------------------------------------------------------------
    mov     ax, 0402h           ; Select Plane 2 (04h)
    out     dx, ax

    push    ds
    mov     ds, [plane2_seg]
    xor     si, si
    xor     di, di
    mov     cx, 19200
    rep movsw
    pop     ds

    ; --------------------------------------------------------------------------
    ; PLANO 3 (INTENSIDADE)
    ; --------------------------------------------------------------------------
    mov     ax, 0802h           ; Select Plane 3 (08h)
    out     dx, ax

    push    ds
    mov     ds, [plane3_seg]
    xor     si, si
    xor     di, di
    mov     cx, 19200
    rep movsw
    pop     ds

    ; Restaura estado
    pop     es
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     ax
    ret


video_clear:
    ; Salva estado
    push    ax
    push    cx
    push    di
    push    es

    xor     ax, ax              ; Word com valor 0 (preto)

    ; --- Limpa Plano 0 ---
    mov     es, [plane0_seg]
    xor     di, di              ; Offset 0
    mov     cx, 19200           ; 38.400 bytes / 2 = 19.200 words
    rep stosw

    ; --- Limpa Plano 1 ---
    mov     es, [plane1_seg]
    xor     di, di
    mov     cx, 19200
    rep stosw

    ; --- Limpa Plano 2 ---
    mov     es, [plane2_seg]
    xor     di, di
    mov     cx, 19200
    rep stosw

    ; --- Limpa Plano 3 ---
    mov     es, [plane3_seg]
    xor     di, di
    mov     cx, 19200
    rep stosw

    ; Restaura estado
    pop     es
    pop     di
    pop     cx
    pop     ax
    ret