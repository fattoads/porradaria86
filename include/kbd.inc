; HEADER: kbd.inc
; DESCRIÇÃO: Declarações extern e mapa de scan codes para os módulos que consumirem o teclado
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef KBD_INC
%define KBD_INC

; Funções exportadas de kbd.asm
extern kbd_init
extern kbd_restore

; Variáveis exportadas de kbd.asm
extern is_key_pressed
extern key_states

; ------------------------------------------------------------------------------
; Mapeamento dos Scan Codes (Make Codes) de teclas usadas no jogo
; ------------------------------------------------------------------------------
SCANCODE_ESC       equ 0x01
SCANCODE_ENTER     equ 0x1C

; Jogador 1 (Teclas W, A, S, D, R, T)
SCANCODE_W         equ 0x11    ; Pulo P1 / Navegação menu
SCANCODE_A         equ 0x1E    ; Esquerda P1
SCANCODE_S         equ 0x1F    ; Agachar P1 / Navegação menu
SCANCODE_D         equ 0x20    ; Direita P1
SCANCODE_R         equ 0x13    ; Chute P1
SCANCODE_T         equ 0x14    ; Soco P1

; Jogador 2 (Setas + N, M)
SCANCODE_UP        equ 0x48    ; Pulo P2 / Navegação menu
SCANCODE_LEFT      equ 0x4B    ; Esquerda P2
SCANCODE_DOWN      equ 0x50    ; Agachar P2 / Navegação menu
SCANCODE_RIGHT     equ 0x4D    ; Direita P2
SCANCODE_N         equ 0x31    ; Chute P2
SCANCODE_M         equ 0x32    ; Soco P2

; Teclas de Sistema e Menus
SCANCODE_P         equ 0x19    ; Pausa
SCANCODE_Q         equ 0x10    ; Quit (Sair)
SCANCODE_Y         equ 0x15    ; Tecla Y (Sim)

%endif