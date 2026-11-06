; ==============================================================================
; HEADER: video.inc
; DESCRIÇÃO: Protótipos e constantes globais do módulo de vídeo
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef VIDEO_INC
%define VIDEO_INC

; Constantes de Vídeo VGA Mode 12h
VGA_MODE_12H    equ 12h
VGA_WIDTH       equ 640
VGA_HEIGHT      equ 480

; Funções exportadas de video.asm
extern video_init
extern video_restore
extern video_render
extern video_clear

; Variáveis exportadas de video.asm
extern orig_video_mode

extern plane0_seg
extern plane1_seg
extern plane2_seg
extern plane3_seg

%endif