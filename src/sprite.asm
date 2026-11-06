; ==============================================================================
; MÓDULO: sprite.asm
; DESCRIÇÃO: Definições das matrizes de máscara de pixel do spritework.
; AUTORIA: Enrico Polez
; ==============================================================================

%define SPRITE_ASM

; ==============================================================================
; GENERATED SPRITE MATRICES (32x32 Bitmaps - 128 bytes per frame)
; ==============================================================================

segment data

; ==============================================================================
; FRAME: sprite_SEMB_IDLE_FRAME0 (Source: SEMB_IDLE_FRAME0.png)
; ==============================================================================
global sprite_SEMB_IDLE_FRAME0
sprite_SEMB_IDLE_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 007h, 0C0h, 000h, 000h    ; Line 08
    db 007h, 0C0h, 000h, 000h    ; Line 09
    db 00Fh, 0C0h, 000h, 000h    ; Line 10
    db 00Fh, 0C0h, 000h, 000h    ; Line 11
    db 01Fh, 0F3h, 000h, 000h    ; Line 12
    db 03Fh, 0FBh, 080h, 000h    ; Line 13
    db 07Fh, 0FFh, 080h, 000h    ; Line 14
    db 0FFh, 0FFh, 080h, 000h    ; Line 15
    db 0FFh, 0FFh, 000h, 000h    ; Line 16
    db 0FFh, 0EFh, 000h, 000h    ; Line 17
    db 03Fh, 0E6h, 000h, 000h    ; Line 18
    db 00Fh, 0E0h, 000h, 000h    ; Line 19
    db 00Fh, 0E0h, 000h, 000h    ; Line 20
    db 01Fh, 0F0h, 000h, 000h    ; Line 21
    db 01Fh, 0F0h, 000h, 000h    ; Line 22
    db 01Fh, 0F8h, 000h, 000h    ; Line 23
    db 03Eh, 078h, 000h, 000h    ; Line 24
    db 03Ch, 03Ch, 000h, 000h    ; Line 25
    db 03Ch, 01Ch, 000h, 000h    ; Line 26
    db 038h, 00Eh, 000h, 000h    ; Line 27
    db 038h, 00Eh, 000h, 000h    ; Line 28
    db 070h, 007h, 000h, 000h    ; Line 29
    db 0F0h, 007h, 080h, 000h    ; Line 30
    db 0F0h, 007h, 080h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_IDLE_FRAME1 (Source: SEMB_IDLE_FRAME1.png)
; ==============================================================================
global sprite_SEMB_IDLE_FRAME1
sprite_SEMB_IDLE_FRAME1:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 003h, 0E0h, 000h, 000h    ; Line 09
    db 003h, 0E0h, 000h, 000h    ; Line 10
    db 007h, 0E0h, 000h, 000h    ; Line 11
    db 00Fh, 0E0h, 000h, 000h    ; Line 12
    db 01Fh, 0F8h, 0C0h, 000h    ; Line 13
    db 03Fh, 0FCh, 0E0h, 000h    ; Line 14
    db 07Fh, 0FFh, 0E0h, 000h    ; Line 15
    db 0FFh, 0FFh, 0E0h, 000h    ; Line 16
    db 0FFh, 0EFh, 080h, 000h    ; Line 17
    db 0FFh, 0E7h, 080h, 000h    ; Line 18
    db 03Fh, 0E0h, 000h, 000h    ; Line 19
    db 00Fh, 0E0h, 000h, 000h    ; Line 20
    db 01Fh, 0F0h, 000h, 000h    ; Line 21
    db 01Fh, 0F0h, 000h, 000h    ; Line 22
    db 01Fh, 0F8h, 000h, 000h    ; Line 23
    db 03Eh, 078h, 000h, 000h    ; Line 24
    db 03Ch, 03Ch, 000h, 000h    ; Line 25
    db 03Ch, 01Ch, 000h, 000h    ; Line 26
    db 038h, 00Eh, 000h, 000h    ; Line 27
    db 038h, 00Eh, 000h, 000h    ; Line 28
    db 070h, 007h, 000h, 000h    ; Line 29
    db 0F0h, 007h, 080h, 000h    ; Line 30
    db 0F0h, 007h, 080h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_WALK_FRAME0 (Source: SEMB_WALK_FRAME0.png)
; ==============================================================================
global sprite_SEMB_WALK_FRAME0
sprite_SEMB_WALK_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 0E0h, 000h, 000h    ; Line 06
    db 001h, 0F0h, 000h, 000h    ; Line 07
    db 001h, 0F0h, 000h, 000h    ; Line 08
    db 003h, 0F0h, 000h, 000h    ; Line 09
    db 003h, 0F0h, 000h, 000h    ; Line 10
    db 007h, 0F0h, 000h, 000h    ; Line 11
    db 007h, 0F8h, 000h, 000h    ; Line 12
    db 00Fh, 0F8h, 000h, 000h    ; Line 13
    db 00Fh, 0FCh, 000h, 000h    ; Line 14
    db 01Fh, 0FCh, 000h, 000h    ; Line 15
    db 01Fh, 0FCh, 000h, 000h    ; Line 16
    db 01Fh, 0FEh, 000h, 000h    ; Line 17
    db 03Fh, 0FFh, 000h, 000h    ; Line 18
    db 03Fh, 0FFh, 000h, 000h    ; Line 19
    db 03Fh, 0FFh, 000h, 000h    ; Line 20
    db 03Bh, 0F8h, 000h, 000h    ; Line 21
    db 003h, 0F8h, 000h, 000h    ; Line 22
    db 007h, 0F8h, 000h, 000h    ; Line 23
    db 007h, 038h, 000h, 000h    ; Line 24
    db 00Fh, 038h, 000h, 000h    ; Line 25
    db 00Fh, 038h, 000h, 000h    ; Line 26
    db 00Eh, 03Ch, 000h, 000h    ; Line 27
    db 01Eh, 01Ch, 000h, 000h    ; Line 28
    db 01Ch, 01Ch, 000h, 000h    ; Line 29
    db 01Eh, 01Eh, 000h, 000h    ; Line 30
    db 01Eh, 01Eh, 000h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_WALK_FRAME1 (Source: SEMB_WALK_FRAME1.png)
; ==============================================================================
global sprite_SEMB_WALK_FRAME1
sprite_SEMB_WALK_FRAME1:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 038h, 000h, 000h    ; Line 07
    db 000h, 07Ch, 000h, 000h    ; Line 08
    db 000h, 0FCh, 000h, 000h    ; Line 09
    db 001h, 0FCh, 000h, 000h    ; Line 10
    db 003h, 0FCh, 000h, 000h    ; Line 11
    db 003h, 0FEh, 000h, 000h    ; Line 12
    db 003h, 0FEh, 000h, 000h    ; Line 13
    db 007h, 0FEh, 000h, 000h    ; Line 14
    db 007h, 0FFh, 000h, 000h    ; Line 15
    db 007h, 0FFh, 000h, 000h    ; Line 16
    db 007h, 0FFh, 000h, 000h    ; Line 17
    db 007h, 0FFh, 080h, 000h    ; Line 18
    db 007h, 0FBh, 080h, 000h    ; Line 19
    db 003h, 0FBh, 080h, 000h    ; Line 20
    db 007h, 0F8h, 000h, 000h    ; Line 21
    db 007h, 0F0h, 000h, 000h    ; Line 22
    db 00Fh, 0F8h, 000h, 000h    ; Line 23
    db 01Fh, 0F8h, 000h, 000h    ; Line 24
    db 01Eh, 07Ch, 000h, 000h    ; Line 25
    db 03Ch, 03Ch, 000h, 000h    ; Line 26
    db 038h, 01Ch, 000h, 000h    ; Line 27
    db 078h, 01Eh, 000h, 000h    ; Line 28
    db 0F0h, 00Eh, 000h, 000h    ; Line 29
    db 0F0h, 00Fh, 000h, 000h    ; Line 30
    db 078h, 00Fh, 000h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_CROUCH_FRAME0 (Source: SEMB_CROUCH_FRAME0.png)
; ==============================================================================
global sprite_SEMB_CROUCH_FRAME0
sprite_SEMB_CROUCH_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 000h, 000h, 000h    ; Line 09
    db 000h, 000h, 000h, 000h    ; Line 10
    db 000h, 000h, 000h, 000h    ; Line 11
    db 000h, 000h, 000h, 000h    ; Line 12
    db 000h, 000h, 000h, 000h    ; Line 13
    db 000h, 000h, 000h, 000h    ; Line 14
    db 000h, 0F0h, 000h, 000h    ; Line 15
    db 000h, 0F8h, 000h, 000h    ; Line 16
    db 001h, 0F8h, 000h, 000h    ; Line 17
    db 001h, 0F8h, 000h, 000h    ; Line 18
    db 003h, 0FCh, 000h, 000h    ; Line 19
    db 007h, 0FCh, 000h, 000h    ; Line 20
    db 00Fh, 0FEh, 000h, 000h    ; Line 21
    db 01Fh, 0FFh, 000h, 000h    ; Line 22
    db 01Fh, 0FFh, 080h, 000h    ; Line 23
    db 03Fh, 0FFh, 080h, 000h    ; Line 24
    db 03Fh, 0FFh, 080h, 000h    ; Line 25
    db 01Fh, 0FFh, 0C0h, 000h    ; Line 26
    db 03Fh, 0FFh, 0C0h, 000h    ; Line 27
    db 07Fh, 0FFh, 0C0h, 000h    ; Line 28
    db 07Ch, 001h, 0E0h, 000h    ; Line 29
    db 0F8h, 001h, 0F0h, 000h    ; Line 30
    db 0F0h, 001h, 0F0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_CROUCH_FRAME1 (Source: SEMB_CROUCH_FRAME1.png)
; ==============================================================================
global sprite_SEMB_CROUCH_FRAME1
sprite_SEMB_CROUCH_FRAME1:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 000h, 000h, 000h    ; Line 09
    db 000h, 000h, 000h, 000h    ; Line 10
    db 000h, 000h, 000h, 000h    ; Line 11
    db 000h, 000h, 000h, 000h    ; Line 12
    db 000h, 000h, 000h, 000h    ; Line 13
    db 000h, 0F0h, 000h, 000h    ; Line 14
    db 000h, 0F8h, 000h, 000h    ; Line 15
    db 001h, 0F8h, 000h, 000h    ; Line 16
    db 001h, 0F8h, 000h, 000h    ; Line 17
    db 003h, 0FCh, 000h, 000h    ; Line 18
    db 007h, 0FCh, 000h, 000h    ; Line 19
    db 00Fh, 0FEh, 000h, 000h    ; Line 20
    db 01Fh, 0FFh, 000h, 000h    ; Line 21
    db 01Fh, 0FFh, 080h, 000h    ; Line 22
    db 03Fh, 0FFh, 080h, 000h    ; Line 23
    db 03Fh, 0FFh, 0C0h, 000h    ; Line 24
    db 01Fh, 0FFh, 0C0h, 000h    ; Line 25
    db 01Fh, 0FFh, 080h, 000h    ; Line 26
    db 03Fh, 0FFh, 0C0h, 000h    ; Line 27
    db 07Eh, 007h, 0C0h, 000h    ; Line 28
    db 07Ch, 003h, 0E0h, 000h    ; Line 29
    db 0F8h, 001h, 0F0h, 000h    ; Line 30
    db 0F0h, 001h, 0F0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_JUMP_FRAME0 (Source: SEMB_JUMP_FRAME0.png)
; ==============================================================================
global sprite_SEMB_JUMP_FRAME0
sprite_SEMB_JUMP_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 007h, 080h, 000h, 000h    ; Line 04
    db 007h, 0C0h, 000h, 000h    ; Line 05
    db 007h, 0C0h, 000h, 000h    ; Line 06
    db 00Fh, 0C0h, 000h, 000h    ; Line 07
    db 00Fh, 0C0h, 000h, 000h    ; Line 08
    db 00Fh, 0C0h, 000h, 000h    ; Line 09
    db 01Fh, 0E0h, 000h, 000h    ; Line 10
    db 01Fh, 0E0h, 000h, 000h    ; Line 11
    db 03Fh, 0F0h, 000h, 000h    ; Line 12
    db 03Fh, 0F0h, 000h, 000h    ; Line 13
    db 07Fh, 0F0h, 000h, 000h    ; Line 14
    db 07Fh, 0F8h, 000h, 000h    ; Line 15
    db 07Fh, 0F8h, 000h, 000h    ; Line 16
    db 0FFh, 0FCh, 000h, 000h    ; Line 17
    db 0FFh, 0FCh, 000h, 000h    ; Line 18
    db 0CFh, 0ECh, 000h, 000h    ; Line 19
    db 00Fh, 0E0h, 000h, 000h    ; Line 20
    db 00Fh, 0E0h, 000h, 000h    ; Line 21
    db 01Ch, 0E0h, 000h, 000h    ; Line 22
    db 01Ch, 0E0h, 000h, 000h    ; Line 23
    db 01Ch, 0E0h, 000h, 000h    ; Line 24
    db 038h, 0E0h, 000h, 000h    ; Line 25
    db 038h, 0E0h, 000h, 000h    ; Line 26
    db 078h, 0E0h, 000h, 000h    ; Line 27
    db 070h, 0E0h, 000h, 000h    ; Line 28
    db 070h, 060h, 000h, 000h    ; Line 29
    db 000h, 000h, 000h, 000h    ; Line 30
    db 000h, 000h, 000h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_JUMP_FRAME1 (Source: SEMB_JUMP_FRAME1.png)
; ==============================================================================
global sprite_SEMB_JUMP_FRAME1
sprite_SEMB_JUMP_FRAME1:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 000h, 000h, 000h    ; Line 09
    db 000h, 0F0h, 000h, 000h    ; Line 10
    db 000h, 0F8h, 000h, 000h    ; Line 11
    db 001h, 0F8h, 000h, 000h    ; Line 12
    db 001h, 0F8h, 000h, 000h    ; Line 13
    db 003h, 0FCh, 000h, 000h    ; Line 14
    db 007h, 0FCh, 000h, 000h    ; Line 15
    db 00Fh, 0FEh, 000h, 000h    ; Line 16
    db 01Fh, 0FFh, 000h, 000h    ; Line 17
    db 01Fh, 0FFh, 080h, 000h    ; Line 18
    db 03Fh, 0FBh, 0C0h, 000h    ; Line 19
    db 03Bh, 0FDh, 0C0h, 000h    ; Line 20
    db 03Fh, 0FFh, 0E0h, 000h    ; Line 21
    db 03Fh, 0FFh, 0E0h, 000h    ; Line 22
    db 03Fh, 0FEh, 0E0h, 000h    ; Line 23
    db 01Fh, 0FFh, 000h, 000h    ; Line 24
    db 03Eh, 01Fh, 000h, 000h    ; Line 25
    db 03Ch, 00Fh, 080h, 000h    ; Line 26
    db 078h, 007h, 080h, 000h    ; Line 27
    db 070h, 003h, 0C0h, 000h    ; Line 28
    db 0F0h, 003h, 0C0h, 000h    ; Line 29
    db 0F0h, 003h, 0C0h, 000h    ; Line 30
    db 000h, 000h, 000h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_PUNCH_FRAME0 (Source: SEMB_PUNCH_FRAME0.png)
; ==============================================================================
global sprite_SEMB_PUNCH_FRAME0
sprite_SEMB_PUNCH_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 001h, 030h, 000h, 000h    ; Line 06
    db 003h, 060h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 007h, 08Ch, 000h, 000h    ; Line 09
    db 007h, 0D8h, 000h, 000h    ; Line 10
    db 00Fh, 0C0h, 000h, 000h    ; Line 11
    db 00Fh, 0C0h, 000h, 000h    ; Line 12
    db 01Fh, 0FCh, 0E0h, 000h    ; Line 13
    db 03Fh, 0FFh, 0C0h, 000h    ; Line 14
    db 07Fh, 0FFh, 0E0h, 000h    ; Line 15
    db 0FFh, 0FFh, 0E0h, 000h    ; Line 16
    db 0FFh, 0E3h, 080h, 000h    ; Line 17
    db 0FFh, 0C0h, 000h, 000h    ; Line 18
    db 07Fh, 0E0h, 000h, 000h    ; Line 19
    db 01Fh, 0F0h, 000h, 000h    ; Line 20
    db 00Fh, 0F0h, 000h, 000h    ; Line 21
    db 01Fh, 0F8h, 000h, 000h    ; Line 22
    db 01Fh, 0F8h, 000h, 000h    ; Line 23
    db 01Eh, 03Ch, 000h, 000h    ; Line 24
    db 01Ch, 01Eh, 000h, 000h    ; Line 25
    db 01Ch, 00Eh, 000h, 000h    ; Line 26
    db 01Ch, 00Fh, 000h, 000h    ; Line 27
    db 01Ch, 007h, 000h, 000h    ; Line 28
    db 038h, 003h, 080h, 000h    ; Line 29
    db 078h, 003h, 0C0h, 000h    ; Line 30
    db 078h, 003h, 0C0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_PUNCH_FRAME1 (Source: SEMB_PUNCH_FRAME1.png)
; ==============================================================================
global sprite_SEMB_PUNCH_FRAME1
sprite_SEMB_PUNCH_FRAME1:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 078h, 000h, 000h    ; Line 09
    db 000h, 07Ch, 000h, 000h    ; Line 10
    db 000h, 0FCh, 000h, 000h    ; Line 11
    db 000h, 0FCh, 00Eh, 000h    ; Line 12
    db 001h, 0FCh, 03Fh, 000h    ; Line 13
    db 001h, 0FFh, 0FFh, 000h    ; Line 14
    db 003h, 0FFh, 0FFh, 000h    ; Line 15
    db 007h, 0FFh, 0FFh, 000h    ; Line 16
    db 007h, 0FFh, 01Fh, 000h    ; Line 17
    db 007h, 0FEh, 033h, 000h    ; Line 18
    db 003h, 0FEh, 0C6h, 000h    ; Line 19
    db 000h, 0FEh, 018h, 000h    ; Line 20
    db 000h, 0FFh, 000h, 000h    ; Line 21
    db 001h, 0FFh, 000h, 000h    ; Line 22
    db 001h, 0FFh, 000h, 000h    ; Line 23
    db 003h, 0FFh, 000h, 000h    ; Line 24
    db 003h, 0CFh, 080h, 000h    ; Line 25
    db 007h, 087h, 080h, 000h    ; Line 26
    db 00Fh, 003h, 0C0h, 000h    ; Line 27
    db 01Eh, 003h, 0C0h, 000h    ; Line 28
    db 03Ch, 001h, 0C0h, 000h    ; Line 29
    db 078h, 001h, 0E0h, 000h    ; Line 30
    db 078h, 001h, 0E0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_PUNCH_FRAME2 (Source: SEMB_PUNCH_FRAME2.png)
; ==============================================================================
global sprite_SEMB_PUNCH_FRAME2
sprite_SEMB_PUNCH_FRAME2:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 0F0h, 000h, 000h    ; Line 09
    db 000h, 0F8h, 000h, 000h    ; Line 10
    db 001h, 0F8h, 000h, 000h    ; Line 11
    db 001h, 0F8h, 000h, 000h    ; Line 12
    db 003h, 0FCh, 000h, 000h    ; Line 13
    db 007h, 0FCh, 000h, 000h    ; Line 14
    db 00Fh, 0FEh, 000h, 000h    ; Line 15
    db 01Fh, 0FFh, 000h, 000h    ; Line 16
    db 01Fh, 0FFh, 080h, 000h    ; Line 17
    db 03Fh, 0FBh, 0C0h, 000h    ; Line 18
    db 03Bh, 0FDh, 0C0h, 000h    ; Line 19
    db 03Fh, 0FFh, 0E0h, 000h    ; Line 20
    db 03Fh, 0FFh, 0E0h, 000h    ; Line 21
    db 03Fh, 0FEh, 0E0h, 000h    ; Line 22
    db 007h, 0FEh, 000h, 000h    ; Line 23
    db 007h, 0FEh, 000h, 000h    ; Line 24
    db 00Fh, 09Fh, 000h, 000h    ; Line 25
    db 00Fh, 00Fh, 000h, 000h    ; Line 26
    db 01Eh, 007h, 000h, 000h    ; Line 27
    db 01Ch, 007h, 000h, 000h    ; Line 28
    db 038h, 003h, 080h, 000h    ; Line 29
    db 078h, 003h, 0C0h, 000h    ; Line 30
    db 078h, 003h, 0C0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_KICK_FRAME0 (Source: SEMB_KICK_FRAME0.png)
; ==============================================================================
global sprite_SEMB_KICK_FRAME0
sprite_SEMB_KICK_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 026h, 000h, 000h    ; Line 08
    db 000h, 06Ch, 000h, 000h    ; Line 09
    db 000h, 000h, 000h, 000h    ; Line 10
    db 000h, 0F1h, 080h, 000h    ; Line 11
    db 000h, 0FBh, 000h, 000h    ; Line 12
    db 001h, 0F8h, 000h, 000h    ; Line 13
    db 001h, 0F8h, 000h, 000h    ; Line 14
    db 003h, 0FEh, 000h, 000h    ; Line 15
    db 007h, 0FFh, 000h, 000h    ; Line 16
    db 00Fh, 0FFh, 080h, 000h    ; Line 17
    db 01Fh, 0FFh, 0C0h, 000h    ; Line 18
    db 01Fh, 0FFh, 0C0h, 000h    ; Line 19
    db 01Fh, 0FFh, 080h, 000h    ; Line 20
    db 00Fh, 0FCh, 000h, 000h    ; Line 21
    db 003h, 0FEh, 000h, 000h    ; Line 22
    db 007h, 0FEh, 000h, 000h    ; Line 23
    db 00Fh, 0FFh, 000h, 000h    ; Line 24
    db 00Fh, 00Fh, 000h, 000h    ; Line 25
    db 01Eh, 00Fh, 080h, 000h    ; Line 26
    db 03Ch, 007h, 080h, 000h    ; Line 27
    db 03Ch, 007h, 080h, 000h    ; Line 28
    db 078h, 003h, 080h, 000h    ; Line 29
    db 0F8h, 003h, 0C0h, 000h    ; Line 30
    db 0F8h, 003h, 0C0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_KICK_FRAME1 (Source: SEMB_KICK_FRAME1.png)
; ==============================================================================
global sprite_SEMB_KICK_FRAME1
sprite_SEMB_KICK_FRAME1:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 000h, 000h, 000h    ; Line 09
    db 000h, 000h, 000h, 000h    ; Line 10
    db 000h, 000h, 000h, 000h    ; Line 11
    db 000h, 000h, 000h, 000h    ; Line 12
    db 007h, 080h, 000h, 000h    ; Line 13
    db 007h, 0C0h, 000h, 000h    ; Line 14
    db 00Fh, 0C0h, 000h, 000h    ; Line 15
    db 00Fh, 0C0h, 000h, 000h    ; Line 16
    db 01Fh, 0E0h, 000h, 000h    ; Line 17
    db 01Fh, 0F0h, 000h, 000h    ; Line 18
    db 03Fh, 0F8h, 000h, 000h    ; Line 19
    db 03Fh, 0FCh, 000h, 000h    ; Line 20
    db 03Fh, 0FEh, 000h, 000h    ; Line 21
    db 03Fh, 0FEh, 000h, 000h    ; Line 22
    db 03Fh, 0FEh, 000h, 000h    ; Line 23
    db 01Fh, 0FCh, 000h, 000h    ; Line 24
    db 00Fh, 0FEh, 060h, 000h    ; Line 25
    db 00Fh, 0FFh, 098h, 000h    ; Line 26
    db 01Eh, 01Fh, 0E6h, 000h    ; Line 27
    db 01Ch, 007h, 0F8h, 000h    ; Line 28
    db 03Ch, 01Fh, 0FCh, 000h    ; Line 29
    db 078h, 000h, 0FEh, 000h    ; Line 30
    db 078h, 000h, 03Eh, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_KICK_FRAME2 (Source: SEMB_KICK_FRAME2.png)
; ==============================================================================
global sprite_SEMB_KICK_FRAME2
sprite_SEMB_KICK_FRAME2:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 000h, 000h, 000h, 000h    ; Line 05
    db 000h, 000h, 000h, 000h    ; Line 06
    db 000h, 000h, 000h, 000h    ; Line 07
    db 000h, 000h, 000h, 000h    ; Line 08
    db 000h, 0F0h, 000h, 000h    ; Line 09
    db 000h, 0F8h, 000h, 000h    ; Line 10
    db 001h, 0F8h, 000h, 000h    ; Line 11
    db 001h, 0F8h, 000h, 000h    ; Line 12
    db 003h, 0FCh, 000h, 000h    ; Line 13
    db 007h, 0FCh, 000h, 000h    ; Line 14
    db 00Fh, 0FEh, 000h, 000h    ; Line 15
    db 01Fh, 0FFh, 000h, 000h    ; Line 16
    db 01Fh, 0FFh, 080h, 000h    ; Line 17
    db 03Fh, 0FBh, 0C0h, 000h    ; Line 18
    db 03Bh, 0FDh, 0C0h, 000h    ; Line 19
    db 03Fh, 0FFh, 0E0h, 000h    ; Line 20
    db 03Fh, 0FFh, 0E0h, 000h    ; Line 21
    db 03Fh, 0FEh, 0E0h, 000h    ; Line 22
    db 007h, 0FEh, 000h, 000h    ; Line 23
    db 007h, 0FEh, 000h, 000h    ; Line 24
    db 00Fh, 09Fh, 000h, 000h    ; Line 25
    db 00Fh, 00Fh, 000h, 000h    ; Line 26
    db 01Eh, 007h, 000h, 000h    ; Line 27
    db 01Ch, 007h, 000h, 000h    ; Line 28
    db 038h, 003h, 080h, 000h    ; Line 29
    db 078h, 003h, 0C0h, 000h    ; Line 30
    db 078h, 003h, 0C0h, 000h    ; Line 31

; ==============================================================================
; FRAME: sprite_SEMB_HIT_FRAME0 (Source: SEMB_HIT_FRAME0.png)
; ==============================================================================
global sprite_SEMB_HIT_FRAME0
sprite_SEMB_HIT_FRAME0:
    db 000h, 000h, 000h, 000h    ; Line 00
    db 000h, 000h, 000h, 000h    ; Line 01
    db 000h, 000h, 000h, 000h    ; Line 02
    db 000h, 000h, 000h, 000h    ; Line 03
    db 000h, 000h, 000h, 000h    ; Line 04
    db 00Ch, 000h, 000h, 000h    ; Line 05
    db 030h, 030h, 000h, 000h    ; Line 06
    db 040h, 008h, 000h, 000h    ; Line 07
    db 043h, 0C8h, 000h, 000h    ; Line 08
    db 027h, 0E0h, 000h, 000h    ; Line 09
    db 027h, 0E0h, 000h, 000h    ; Line 10
    db 007h, 0F0h, 000h, 000h    ; Line 11
    db 007h, 0F0h, 000h, 000h    ; Line 12
    db 00Fh, 0F8h, 000h, 000h    ; Line 13
    db 01Fh, 0F8h, 000h, 000h    ; Line 14
    db 01Fh, 0FCh, 000h, 000h    ; Line 15
    db 03Fh, 0FEh, 000h, 000h    ; Line 16
    db 03Fh, 0FFh, 000h, 000h    ; Line 17
    db 077h, 0FFh, 080h, 000h    ; Line 18
    db 07Fh, 0FFh, 080h, 000h    ; Line 19
    db 07Fh, 0FFh, 000h, 000h    ; Line 20
    db 07Fh, 0FEh, 000h, 000h    ; Line 21
    db 037h, 0FEh, 000h, 000h    ; Line 22
    db 007h, 0FFh, 000h, 000h    ; Line 23
    db 00Fh, 08Fh, 000h, 000h    ; Line 24
    db 00Fh, 007h, 080h, 000h    ; Line 25
    db 00Eh, 003h, 0C0h, 000h    ; Line 26
    db 01Eh, 001h, 0C0h, 000h    ; Line 27
    db 01Ch, 001h, 0E0h, 000h    ; Line 28
    db 01Ch, 001h, 0E0h, 000h    ; Line 29
    db 03Ch, 000h, 000h, 000h    ; Line 30
    db 038h, 000h, 000h, 000h    ; Line 31