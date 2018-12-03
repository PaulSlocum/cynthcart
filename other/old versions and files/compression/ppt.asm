; Commodore 64 Synthcart
; by Paul Slocum
;------------------------
; TODO:
; - Create extra images
; - Complete rough draft of full presentation
; - Add flashing arrow indicator
;
; LATER:
; - Integrate Cynthcart
; - Improve text sound
; - Add sound effects
; - Add blue C64 startup screen
;
;------------------------

;------------------------
; Memory Map:

; $0000 \ SYSTEM
; $03FF /

; $0400 \ COLOR CELL MEMORY
; $07FF /

; $1000 \ Cynthcart code
; $17FF / 

; $2000 \ BITMAP MEMORY
; $3FFF /

; $4000 \ Big font
; $47FF /

; $4800 \ Small font
; $4BFF /

; $4C00 \ Script
; $5FFF /

; $6000 \ ROM #1 compressed pictures
; $73FF /

; $8000 \ CARTRIDGE ROM
; $9FFF /

; $C000 \ Decompression Routine
; $C200 /

; $D000 \ SID/VIC/CIA1/CIA2
; $DFFF /
;
; $E000 \ KERNAL ROM
; $FFFF /
;------------------------


	processor 6502

	; Include .CRT emulation header
	;include crt_hdr.asm

; *********************************************
; Constants
; *********************************************

PITCHA equ 30
PITCHB equ 15

IMAGERAM equ $6000

IMAGEROM equ $9FF0

program equ $4C00

TXDLY equ 10

CURRENTKEY equ 197

BACK_COLOR equ 53280
BORD_COLOR equ 53281

SID equ $D400
	
V1FL 	equ $D400
V1FH 	equ $D401
V1PWL 	equ $D402
V1PWH 	equ $D403
V1WAVE 	equ $D404
V1AD 	equ $D405
V1SR 	equ $D406

V2FL 	equ $D407
V2FH 	equ $D408
V2PWL 	equ $D409
V2PWH 	equ $D40A
V2WAVE 	equ $D40B
V2AD 	equ $D40C
V2SR 	equ $D40D

V3FL 	equ $D40E
V3FH 	equ $D40F
V3PWL 	equ $D410
V3PWH 	equ $D411
V3WAVE 	equ $D412
V3AD 	equ $D413
V3SR 	equ $D414

FILTL	equ $D415
FILTH	equ $D416
FILTC	equ $D417
VOLMODE	equ $D418

PAD1	equ $D419
PAD2	equ $D41A

PortA	equ $dc00
Ciddra	equ $dc02


; *********************************************
; RAM Variables
; *********************************************

; zero page variables

textdataL equ 78
textdataH equ 79

progptrL equ 87
progptrH equ 88

textBL equ 163
textBH equ 164

;--------------;
destL	equ 251  ;
destH equ 252  ;
srcL	equ 253  ;
srcH	equ 254  ;
;||||||||||||||;
fontL equ 251  ;
fontH equ 252  ;
textAL equ 253 ;
textAH equ 254 ;
;--------------;

; non-z-page varibles

base 	equ $7FF0
;7ff1 free

textloc equ $7FF2
cursorL equ $7FF3
cursorH equ $7FF4
curStat equ $7FF5

pitch equ $7FF6

	; *********************************************
	; ROM Data
	; *********************************************
	org $8000

	; Startup Vector
	word Startup
	; Restore Vector
	word Startup
;	word Restore

	; 5 byte cartridge startup code
	byte $C3, $C2, $CD, $38, $30

Startup:
	; System Startup Stuff
	sei
	jsr $FF84
	jsr $FF87
	jsr $FF8A
	jsr $FF81
	cli

;	jsr setup
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	lda #14
	sta BACK_COLOR
	lda #6
	sta BORD_COLOR

	lda #27
	sta $d011

	lda #21
	sta $d018

	; Set up sound
	lda #$1C
	sta VOLMODE
	lda #$01
	sta V1AD
	lda #$00
	sta V1SR
	lda #$10
	sta V1WAVE
	lda #$00
	sta FILTC
	lda #30
	sta V1FH
	
	; DECOMPRESS SCRIPT
	ldx #>script ;H
	ldy #<script ;L
	iny
	iny
	jsr $C000


	; DEBUG Test decompression of image
;	lda $d011
;	ora #32
;	sta $d011
;	lda $d018
;	ora #8
;	sta $d018
;	lda #0
;	sta BACK_COLOR
;	sta BORD_COLOR
;	ldy $6000 ;L
;	ldx $6001 ;H
;	iny
;	iny
;	jsr $C000
;cockup
;	jmp cockup

	ldx #70
textlp
	lda startText,x
	sta 1024,x
	dex
	bpl textlp

	lda #0
	sta curStat	

	lda #<program
	sta progptrL
	lda #>program
	sta progptrH

	jmp clrscr

startText
	byte 3,15,13,13,15,4,15,18,5,32,54,52,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
	byte 3,9,14,5,13,1,32,20,5,24,1,19,32,16,18,5,19,5,14,20,1,20,9,15,14,32,22,49,46,49,32,32,32

	; *********************************************
	; Event Handlers
	;------------------------
stop
	jsr incptr
ktest
	lda $dc00
	and #16
	beq continue
	lda CURRENTKEY
	cmp #4
	beq goCynth
	cmp #60
	bne ktest

continue

	; Clear any text
	ldx #70
	lda #$50
textlp2
	sta 1024,x
	dex
	bpl textlp2

	; Turn on bitmap mode
	lda $d011
	ora #32
	sta $d011

	; set bitmap location to 8192
	lda $d018
	ora #8
	sta $d018

	; background black
	lda #0
	sta BACK_COLOR
	sta BORD_COLOR

	jmp disploop

goCynth:
	
	; Turn off bitmap mode
;	lda $d011
;	and #~32
	lda #27
	sta $d011

	lda #21
	sta $d018

	; Load C64 image
;	ldy #2
;	lda $6000,y ;L
;	ldx $6001,y ;H
;	tay	

	jsr showimg

	jmp $101a ; Start Cynthcart


	;------------------------
image_rom
	jsr incptr
	lda (progptrL),x
	tay
	jsr incptr
	lda IMAGEROM,y 	;L
	ldx IMAGEROM+1,y ;H
	tay
	jsr showimg
	jmp disploop
	;------------------------
image_ram
	jsr incptr
	lda (progptrL),x
	tay
	jsr incptr
	lda IMAGERAM,y 	;L
	ldx IMAGERAM+1,y ;H
	tay	
	jsr showimg
	jmp disploop


	; *********************************************
	; Event Loop
disploop:
	ldx #0
	lda (progptrL),x
	bmi stop

	; Remove cursor if on screen
	lda curStat
	beq noCursor
	jsr removeCursor
noCursor

	ldx #0
	lda (progptrL),x

	beq image_ram
	cmp #1
	beq text
	cmp #3
	beq clrscr
	cmp #4
	beq text8
	cmp #5
	beq image_rom
	jmp disploop





	; *********************************************
	; More Event Handlers
	;------------------------
text
	jsr incptr
	lda (progptrL),x
	sta textloc
;	jsr incptr
;	lda (progptrL),x
;	sta textdataL
;	jsr incptr
;	lda (progptrL),x
;	sta textdataH
	jsr incptr
	jsr drawtext
	jmp disploop

	;------------------------
text8
	jsr incptr
	lda (progptrL),x
	sta textloc
;	jsr incptr
;	lda (progptrL),x
;	sta textdataL
;	jsr incptr
;	lda (progptrL),x
;	sta textdataH
	jsr incptr
	jsr drawtext8
	jmp disploop

	;------------------------
clrscr:
	jsr incptr

	lda #$20
	sta destH
	lda #$00
	sta destL
	ldy #0
	lda #0
clrlp
	sta (destL),y
	dey
	bne clrlp
	inc destH
	ldx #$40
	cpx destH
	bne clrlp
	jmp disploop

	;------------------------
removeCursor
	cmp #1
	beq removeBig

	; remove small cursor
	ldy #0
	sty curStat ; clear cursor status
	lda #0
rcura8
	sta (textAL),y
	iny
	cpy #8
	bne rcura8
	rts

removeBig
	; remove big cursor
	ldy #0
	sty curStat ; clear cursor status
	lda #0
rcura
	sta (textAL),y
	iny
	cpy #16
	bne rcura
	lda #$30
	clc
	adc textAL
	sta textAL
	lda #1
	adc textAH
	sta textAH
	lda #0
rcurb
	sta (textAL),y
	iny
	cpy #32
	bne rcurb
	rts
	
	;------------------------
	; little subroutine to increment
	; the program pointer
incptr
	inc progptrL
	bne noProgRoll
	inc progptrH
noProgRoll
	rts

	







	; ************************************
	; DISPLAY IMAGE
	; ************************************
showimg
;	ldx #>atari ;H
;	ldy #<atari ;L
	iny
	iny

	jsr $C000

	rts


offsetL
	byte $00,$40,$80,$C0
	byte $00,$40,$80,$C0
	byte $00,$40,$80,$C0
	byte $00,$40,$80,$C0
	byte $00,$40,$80,$C0
	byte $00,$40,$80,$C0
	byte $00

offsetH
	byte $20,$21,$22,$23
	byte $25,$26,$27,$28
	byte $2A,$2B,$2C,$2D
	byte $2F,$30,$31,$32
	byte $34,$35,$36,$37
	byte $39,$3A,$3B,$3C
	byte $3E

voffset
	byte 0,$28,$50,$78,$A0,$c8,$f0

	;****************************
	; DRAW TEXT
	;****************************
drawtext
	lda #PITCHA
	sta V1FH
	lda #$1C
	sta VOLMODE

;	lda #18+%10000000
;	sta textloc

	lda textloc
	and #%00011111
	tax
	lda offsetL,x
	sta textAL
	lda offsetH,x
	sta textAH
	inx
	lda offsetL,x
	sec
	sbc #$10
	sta textBL
	lda offsetH,x
	sbc #0
	sta textBH
	 
	lda textloc
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	lda voffset,x
	clc
	adc textAL
	sta textAL
	lda #0
	adc textAH
	sta textAH

	lda voffset,x
	clc
	adc textBL
	sta textBL
	lda #0
	adc textBH
	sta textBH

	ldx #0
textproc	

	inc pitch
	inc pitch
	lda pitch
	sta V1FL

	lda #0
	sta fontH

	; Get next char
	lda (progptrL),x
	bmi quittext

	; x32
	asl
	asl
	rol fontH
	asl
	rol fontH
	asl
	rol fontH
	asl
	rol fontH
	sta fontL

	; Add offset of font data
	lda #$40 ; location of font in RAM: $4000
	clc
	adc fontH
	sta fontH

;	lda #$88
;	sta fontH
;	lda #<font
;	sta fontL

	ldy #0
fonta
	lda (fontL),y
	sta (textAL),y
	iny
	cpy #16
	bne fonta

;	ldy #16
fontb
	lda (fontL),y
	sta (textBL),y
	iny
	cpy #32
	bne fontb

	lda textAL
	clc
	adc #16
	sta textAL
	lda textAH
	adc #0
	sta textAH

	lda textBL
	clc
	adc #16
	sta textBL
	lda textBH
	adc #0
	sta textBH

	; draw cursor
	ldy #0
	lda #255
cura
	sta (textAL),y
	iny
	cpy #16
	bne cura
curb
	sta (textBL),y
	iny
	cpy #32
	bne curb


	lda #$11
	sta V1WAVE

	lda #TXDLY
	ldy #0
txtdly
	dey
	bne txtdly
	sec
	sbc #1
	bne txtdly

;	lda #0
;	sta VOLMODE
	lda #$10
	sta V1WAVE

	lda #TXDLY
	ldy #0
txtdly2
	dey
	bne txtdly2
	sec
	sbc #1
	bne txtdly2


	; move to next character in text data
;	inc textdataL
;	bne noroll
;	inc textdataH
;noroll
	jsr incptr

	jmp textproc

quittext
	; Save cursor info so it can be removed later
	ldy #1
quittext8
	sty curStat
	lda textAL
	sta cursorL
	lda textAH
	sta cursorH

	jsr incptr
	;****************************
	rts



	;****************************
	; DRAW 8x8 TEXT
	;****************************
drawtext8
	lda #PITCHB
	sta V1FH

	lda textloc
	and #%00011111
	tax
	lda offsetL,x
	sta textAL
	lda offsetH,x
	sta textAH
	 
	lda textloc
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	lda voffset,x
	clc
	adc textAL
	sta textAL
	lda #0
	adc textAH
	sta textAH

	ldx #0
textproc8

	inc pitch
	inc pitch
	lda pitch
	sta V1FL
	
	lda #0
	sta fontH

	ldy #2
	; Get next char
	lda (progptrL),x
	bmi quittext8

	; x8
	asl
	asl
	rol fontH
	asl
	rol fontH
	sta fontL

	; Add offset of font data
	lda #$48 ; location of 8X8 font in RAM: $4800
	clc
	adc fontH
	sta fontH

;	lda #$88
;	sta fontH
;	lda #<font
;	sta fontL

	ldy #0
fonta8
	lda (fontL),y
	sta (textAL),y
	iny
	cpy #8
	bne fonta8

	lda textAL
	clc
	adc #8
	sta textAL
	lda textAH
	adc #0
	sta textAH

	; cursor
	ldy #0
	lda #255
cura8
	sta (textAL),y
	iny
	cpy #8
	bne cura8

	lda #$1F
	sta VOLMODE

;	lda #$11
;	sta V1WAVE

	lda #TXDLY
	ldy #0
txtdly8
	dey
	bne txtdly8
	sec
	sbc #1
	bne txtdly8

;	lda #$10
;	sta V1WAVE

	lda #TXDLY
	ldy #0
txtdly82
	dey
	bne txtdly82
	sec
	sbc #1
	bne txtdly82

	lda #$1C
	sta VOLMODE

	; move to next character in text data
;	inc textdataL
;	bne noroll8
;	inc textdataH
;noroll8
	jsr incptr

	jmp textproc8


;setup
	; Disable RESTORE key
;	lda #193
;	sta 792
;	lda #0
;	sta BACK_COLOR
;	sta BORD_COLOR
;	rts


cart
;	incbin atari2.cmp
	incbin cart.cmp
paddle
	incbin paddle.cmp
eprom
	incbin eprom.cmp
keybd
	incbin keybrd.cmp
printer
	incbin printer.cmp

script
	incbin script.cmp

;	include script.h

	org $9ff0		; image reference
	word cart		;0
	word eprom		;2
	word keybd		;4
	word printer	;6
	word paddle		;8

	org $9fff
	byte 0


