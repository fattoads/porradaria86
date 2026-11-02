; ==============================================================================
; MÓDULO: kbd.asm
; DESCRIÇÃO: Trata a interrupção de hardware do teclado (INT 9h) e
;            mantém um buffer assíncrono de teclas pressionadas (key_states).
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

; ------------------------------------------------------------------------------
; SÍMBOLOS EXPORTADOS
; ------------------------------------------------------------------------------
global kbd_init
global kbd_restore
global is_key_pressed
global key_states

; ------------------------------------------------------------------------------
; DS
; ------------------------------------------------------------------------------
segment data

; Array com o estado de 128 teclas possíveis do teclado (0 = Solta, 1 = Pressionada)
; Indexado pelo código Make da tecla (0x00 - 0x7F)
key_states: resb 128

; Armazenamento do endereço original do vetor da INT 9h para restauração ao sair
orig_int9_off dw 0 ; IP
orig_int9_seg dw 0 ; CS

; ------------------------------------------------------------------------------
; CS
; ------------------------------------------------------------------------------
segment code

; ------------------------------------------------------------------------------
; kbd_init: Instala a nossa rotina ISR customizada na INT 9h.
; Guarda o vetor antigo para garantir o retorno seguro ao DOS.
; ------------------------------------------------------------------------------
kbd_init:
    ; Salva estado
    push    ax
    push    bx
    push    cx
    push    dx
    push    di
    push    es

    ; Limpa a tabela de estados (zera os 128 bytes)
    mov     di, key_states
    mov     cx, 128
.clear_loop:
    mov     [di], 0
    inc     di
    loop    .clear_loop

    ; Salvar INT 9h original
    mov     ah, 35h             ; Obtém endereço atual da interrupção AL no vetor de interrupções
    mov     al, 09h             ; Seleciona interrupção 9h
    int     21h                 ; Endereço é salvo em ES:BX
    mov     [orig_int9_off], bx ; Armazena offset original
    mov     [orig_int9_seg], es ; Armazena base original

    ; Atualizar o vetor da INT 9h para a nossa ISR
    push    ds                  ; Salva DS atual
    mov     ax, cs              ; Precisamos guardar o endereço da rotina (CS:IP) em DS:DX
    mov     ds, ax              ; Então armazenamos CS em DS
    mov     dx, kbd_isr         ; E armazenamos o offset (IP) de kbd_isr em DX
    mov     ah, 25h             ; Atualiza endereço da interrupção AL no vetor de interrupções com o endereço DS:DX
    mov     al, 09h             ; Seleciona interrupção 9h
    int     21h                 ; Endereço é atualizado
    pop     ds                  ; Restaura DS original

    ; Restaura estado
    pop     es
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; kbd_restore: Restaura o vetor original da INT 9h que foi salvo.
; Sempre chamar antes de encerrar o programa
; ------------------------------------------------------------------------------
kbd_restore:
    ; Salva estado
    push    ax
    push    dx
    push    ds

    ; Não restaura interrupção caso ela não tenha sido alterada ou já tenha sido restaurada
    cmp     word [orig_int9_seg], 0
    je      .done

    ; Restaura a INT 9h original
    mov     dx, [orig_int9_off]     ; Precisamos armazenar o endereço da interrupção em DS:DX, então movemos o offset original pra DX
    mov     ds, [orig_int9_seg]     ; E movemos a base original para DS
    mov     ah, 25h                 ; Atualiza endereço da interrupção AL com o endereço DS:DX
    mov     al, 09h                 ; Seleciona interrupção 9h
    int     21h                     ; Endereço é atualizado

    ; Reseta o segmento guardado para evitar chamadas duplicadas
    mov     ax, data
    mov     ds, ax
    mov     word [orig_int9_seg], 0

.done:
    ; Restaura estado
    pop     ds
    pop     dx
    pop     ax
    ret

; ------------------------------------------------------------------------------
; kbd_isr: Interrupção do teclado
; ------------------------------------------------------------------------------
kbd_isr:
    ; Salva estado
    push    ax
    push    bx
    push    ds

    ; Garante DS consistente com o resto do programa quando a interrupção é disparada
    mov     ax, data
    mov     ds, ax

    ; Lê o scan code da porta E/S 60h
    in      al, 60h

    ; Analisa se é Make Code (Pressionada) ou Break Code (Solta)
    ; Se o bit 7 (0x80) de AL estiver setado, é um break code, logo saltamos pra .key_released
    ; Caso contrário, seguimos para .key_pressed
    mov     bl, al              ; A tabela é indexada pelo código, então armazenamos ele em BL (somente BX pode indexar memória)
    test    al, 80h             ; Testa o bit 7
    jnz     .key_released

.key_pressed:
    ; Setamos o estado dessa tecla
    and     bx, 007Fh           ; O scan code só é representado pelos primeiros 7 bits
    mov     byte [key_states + bx], 1
    jmp     .eoi

.key_released:
    ; Zeramos o estado dessa tecla
    and     bx, 007Fh           ; O scan code só é representado pelos primeiros 7 bits
    mov     byte [key_states + bx], 0

.eoi:
    ; Envia o sinal End of Interrupt para o controlador na porta 20h
    mov     al, 20h
    out     20h, al

    ; Restaura estado
    pop     ds
    pop     bx
    pop     ax
    iret

; ------------------------------------------------------------------------------
; is_key_pressed: Verifica o estado de uma tecla indicada pelo scan code
; Entrada: AL = Scan Code da tecla
; Saída:   AL = 1 (Pressionada) ou 0 (Solta)
; ------------------------------------------------------------------------------
is_key_pressed:
    push    bx
    mov     bl, al                  ; Armazenando scan code em BL para indexação
    and     bx, 007Fh               ; O scan code só é representado pelos primeiros 7 bits
    mov     al, [key_states + bx]   ; AL armazena o estado da tecla
    pop     bx
    ret