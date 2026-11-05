; ==============================================================================
; HEADER: ui.inc
; DESCRIÇÃO: Declarações de protótipos de funções exportadas do módulo ui.asm
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef UI_INC
%define UI_INC

WALL_LEFT       equ     24
WALL_RIGHT      equ     615
FLOOR_Y         equ     456

%ifndef UI_ASM

; Funções exportadas de ui.asm
extern ui_draw_arena
extern ui_draw_hud
extern ui_draw_pause
extern draw_rect_filled
extern ui_draw_gameover
extern ui_draw_confirm_quit

%endif

%endif