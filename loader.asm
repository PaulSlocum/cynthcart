; Commodore 64 Cynthcart LOADER
; by Paul Slocum
;------------------------
; TEXT EDITOR TAB=3
;------------------------

;------------------------
;------------------------
; TODO
;------------------------
; - LFO -> Pulse Width and Volume and Filter
;--------------------------
;--------------------------


;#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
;# MEMORY MAP
;#
;# $0800-$3800 Program and data
;# $7000-$7200 Variables and buffers (512 bytes) 
;# $7F00-$7FFF MIDI ring buffer
;#
;#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#




;/\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ 
	processor 6502

	; Image run mode:
CART equ 0 ; run at $8000 off cartridge ROM
DISK equ 1 ; run at $2047, include BASIC sys command
RAM equ 2 ; run at $8000 in RAM from PRG 

;**********************************************************
;**********************************************************
; PROGRAM CONFIGURATION SWITCHES
;**********************************************************
;**********************************************************
;MODE equ DISK   ; DISK mode is for testing
;MODE equ CART
MODE equ RAM

;**********************************************************
;**********************************************************
;**********************************************************

	; *********************************************
	; START OF PROGRAM IN MEMORY
	; *********************************************

	;==================================================
	; straight cart ROM
	IF MODE=CART
BASEADDR equ $8000
	org BASEADDR
	word Startup
	word Startup
	; 5 byte cartridge startup code
	byte $C3, $C2, $CD, $38, $30
	ENDIF

	;==================================================
	; load from disk as PRG with auto-run
	IF MODE=DISK
BASEADDR equ 2047 ; 2047 = $7FF
	org BASEADDR ; the beginning of the BASIC program area

	; disk load location
	byte $01,$08
	; BASIC program to call the cynthcart machine code...
	; 10 SYS 2061
	byte $0b,$08,  $0a,$00,$9e,$32,  $30,$36,$31,$00,  $00,$00 
	; next effective address after this is 2061 / $80D
	ENDIF

	;==================================================
	; load from disk as PRG with auto-run
	IF MODE=RAM
BASEADDR equ $8000 ;
	org BASEADDR-2 ; the beginning of the BASIC program area
	; disk load location
	byte $00,$80
	ENDIF


	
	;---------------------------------------
	; variables and constants here
	;---------------------------------------

	
	
	; *********************************************
	; Start of program
	; *********************************************
Startup:

	IF MODE=CART
	; System Startup Stuff
	; (not needed if starting from disk)
	sei
	jsr $FF84 ; initialize I/O devices
	jsr $FF87 ; initalise memory pointers
	jsr $FF8A ; restore I/O vectors
	jsr $FF81 ; initalise screen and keyboard
	cli
	ENDIF

;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
	
FROM equ 34
TO equ 36
SIZEL equ 150
SIZEH equ 151
	
; Move memory down
;
; FROM = source start address
;   TO = destination start address
; SIZE = number of bytes to move
;

	IF MODE=999
	ldy #<compressedData ;L
	ldx #>compressedData ;H
	sty FROM+0
	stx FROM+1
	ldy #$01 ; L $801 start of BASIC area
	ldx #$08 ; H $801 start of BASIC area
	sty TO+0
	stx TO+1
	ldy #$00 ; L 
	ldx #$20 ; H 8K bytes
	sty TO+0
	stx TO+1
	
	lda #23
	sta 1066

MOVEDOWN LDY #0
         LDX SIZEH
         BEQ MD2
MD1      LDA (FROM),Y ; move a page at a time
         STA (TO),Y
         INY
         BNE MD1
         INC FROM+1
         INC TO+1
         DEX
         BNE MD1
MD2      LDX SIZEL
         BEQ MD4
MD3      LDA (FROM),Y ; move the remaining bytes
         STA (TO),Y
         INY
         DEX
         BNE MD3
MD4      ;RTS

	ENDIF

	;lda #23
	;sta 1066
	
	;jmp 2061 ; JMP to start of built-in decomopression routine
	;rts
	
;lock2: jmp lock2

		; COPY DECOMPRESSOR INTO MEMORY
	ldx #0
	ldy #32
decompCopyLoop:
	lda compressedData+2,x
storeLocation:
	sta $0801,x
	dex
	bne decompCopyLoop
	inc decompCopyLoop+2
	inc storeLocation+2
	dey
	bne decompCopyLoop
	
	;lda #0
	;sta 1068

	;rts	
;lock: jmp lock
	jmp 2061
	
	
	
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	; switch to lowercase mode
	lda #23
	sta $d018

	lda #0 ; DEBUG put character on screen
	sta 1024
	lda #1 ; DEBUG put character on screen
	sta 1025
	;lda #2 ; DEBUG put character on screen
	;sta 1026

	jmp 2061 ; JMP to start of built-in decomopression routine
	
	;ldx #>compressedData ;H
	;ldy #<compressedData ;L
	;iny
	;iny
	;sty 1028
	;jsr $C000
	
	;bcc good
bad:
	;lda #2 ; 'b'
	;sta 1030
	;jmp stop
good:
	;lda #7 ; 'g'
	;sta 1028
	
	;jmp $5000
;	ORG $c000

	; Call with X = HI of packed data, Y = LO of packed data
	; Returns exec address in X = HI and Y = LO
	; Carry will be set for error, cleared for OK

		
	; Lock cpu (DEBUG)
stop:
	jmp stop
	
	
compressedData:
	incbin "cynthcart152_comp.prg"
	;incbin "cynthcart152.cmp"
	;incbin "eprom.cmp" ; DEBUG!!

decompressor:
	;include "sa_uncrunch.asm"

		
	;IF MODE=KERNEL_OBSOLETE
	;org $bfff
	;byte 0
	;ENDIF
