; ==============================================================================
; MÓDULO: timer.asm
; DESCRIÇÃO: Interceptação da INT 1Ch (Timer Tick Hook do BIOS) para controle
;            regressivo dos 180 segundos do round de forma assíncrona.
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================
%include "game.inc"

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global timer_init
global timer_restore
global timer_ticks

; ------------------------------------------------------------------------------
; DS (Segmento de Dados)
; ------------------------------------------------------------------------------
segment data

; Ponteiro do vetor original da INT 1Ch para restauração segura
orig_int1ch_off dw 0            ; Offset original (IP)
orig_int1ch_seg dw 0            ; Segmento original (CS)

; Contador acumulador para conversão de 18.2 Hz para 1 segundo exato:
; A cada interrupção somamos 10. Quando atinge 182 (182 / 10 = 18.2), 1s passou.
timer_acc       dw 0

; Contador geral de ticks (útil caso a física precise sincronizar animações)
timer_ticks     dw 0

; ------------------------------------------------------------------------------
; CS (Segmento de Código)
; ------------------------------------------------------------------------------
segment code

; ------------------------------------------------------------------------------
; timer_init: Salva o vetor original da INT 1Ch e instala a nossa rotina ISR
; ------------------------------------------------------------------------------
timer_init:
    push    ax
    push    bx
    push    dx
    push    es

    ; Reseta acumulador e contador
    mov     word [timer_acc], 0
    mov     word [timer_ticks], 0

    ; 1. Obtém o endereço atual da INT 1Ch (AH = 35h da INT 21h)
    ; Retorno: ES:BX = ponteiro do tratador original
    mov     ah, 35h
    mov     al, 1Ch
    int     21h
    mov     [orig_int1ch_off], bx
    mov     [orig_int1ch_seg], es

    ; 2. Define o novo tratador da INT 1Ch (AH = 25h da INT 21h)
    ; Entrada: DS:DX = endereço do novo tratador
    push    ds
    mov     ax, cs
    mov     ds, ax
    mov     dx, timer_isr
    mov     ah, 25h
    mov     al, 1Ch
    int     21h
    pop     ds

    pop     es
    pop     dx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; timer_restore: Restaura o tratador original da INT 1Ch
; ------------------------------------------------------------------------------
timer_restore:
    push    ax
    push    dx
    push    ds

    ; Verifica se a interrupção foi realmente modificada
    cmp     word [orig_int1ch_seg], 0
    je      .done

    ; Restaura endereço original salvo em orig_int1ch_seg:orig_int1ch_off
    mov     dx, [orig_int1ch_off]
    mov     ds, [orig_int1ch_seg]
    mov     ah, 25h
    mov     al, 1Ch
    int     21h

    ; Marca como restaurado zerando o segmento
    mov     ax, data
    mov     ds, ax
    mov     word [orig_int1ch_seg], 0

.done:
    pop     ds
    pop     dx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; timer_isr: Rotina de Serviço da Interrupção (chamada a cada ~55 ms pelo BIOS)
; ------------------------------------------------------------------------------
timer_isr:
    push    ax
    push    ds

    ; Configura o segmento de dados para acessar as variáveis globais
    mov     ax, data
    mov     ds, ax

    ; Incrementa contador global de ticks
    inc     word [timer_ticks]

    ; Só decrementa o tempo se o jogo estiver ativamente em combate (STATE_PLAYING)
    cmp     byte [game_state], STATE_PLAYING
    jne     .exit_isr

    ; Se o cronômetro do round já estiver zerado, não faz nada
    cmp     word [round_timer], 0
    jle     .exit_isr

    ; Acumulador de frequência fracionária (18.2 Hz -> 1 segundo)
    add     word [timer_acc], 10
    cmp     word [timer_acc], 182
    jb      .exit_isr

    ; Subtrai 182 e desconta 1 segundo do relógio do round
    sub     word [timer_acc], 182
    dec     word [round_timer]

.exit_isr:
    pop     ds
    pop     ax
    iret