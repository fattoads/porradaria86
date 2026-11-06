; ==============================================================================
; HEADER: sprite.inc
; DESCRIÇÃO: Declarações das matrizes de máscara de pixel do spritework.
; AUTORIA: Enrico Polez
; ==============================================================================

%ifndef SPRITE_INC
%define SPRITE_INC

%ifndef SPRITE_ASM
extern sprite_SEMB_IDLE_FRAME0, sprite_SEMB_IDLE_FRAME1
extern sprite_SEMB_WALK_FRAME0, sprite_SEMB_WALK_FRAME1
extern sprite_SEMB_CROUCH_FRAME0, sprite_SEMB_CROUCH_FRAME1
extern sprite_SEMB_JUMP_FRAME0, ; sprite_SEMB_JUMP_FRAME1
extern sprite_SEMB_PUNCH_FRAME0, sprite_SEMB_PUNCH_FRAME1, sprite_SEMB_PUNCH_FRAME2
extern sprite_SEMB_KICK_FRAME0, sprite_SEMB_KICK_FRAME1, sprite_SEMB_KICK_FRAME2
extern sprite_SEMB_HIT_FRAME0
%endif

%endif