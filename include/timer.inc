; ==============================================================================
; HEADER: timer.inc
; DESCRIÇÃO: Declarações extern do módulo de temporização via INT 1Ch
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================
%ifndef TIMER_INC
%define TIMER_INC

; Funções exportadas de timer.asm
extern timer_init
extern timer_restore

; Variáveis exportadas de timer.asm
extern timer_ticks

%endif