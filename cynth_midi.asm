; public MIDI interface routines:
; midiDetect
; midiInit
; midiRead
; midiWrite

; interface type for midiDetect and midiInit:
; 0: no MIDI interface was detected
; 1: Sequential Circuits Inc.
; 2: Passport & Syntech
; 3: DATEL/Siel/JMS
; 4: Namesoft
		
;BUFFER_SIZE_MASK equ #$1F ; original size
BUFFER_SIZE_MASK equ #$FF

		
	processor 6502

TRUE equ 1
FALSE equ 0
	
PRA equ $dc00            ; CIA#1 (Port Register A)
DDRA equ $dc02            ; CIA#1 (Data Direction Register A)

PRB  equ  $dc01            ; CIA#1 (Port Register B)
DDRB equ  $dc03            ; CIA#1 (Data Direction Register B)

;loopCount equ 1104
;irqCountTotal equ 1105
;irqCountMidi equ 1106
;irqCountTDREmpty equ 1107
;saveY equ 1140
;firstPass equ 1141
statusSample1 equ 1104
statusSample2 equ 1105

TEST_KEYBOARD equ FALSE
INCLUDE_DETECT_IRQ equ FALSE
		
	;=========================================================================
	; MIDI DETECT		
	; =========================================================================
	
	; detect MIDI interface, return type in accu
midiDetect:	; TODO
	;lda #0
	;sta irqCountTotal
	;sta irqCountMidi
	;sta loopCount

	
	
	; old code to manually set interface type
	lda #3 ; DATEL
	;lda #2 ; PASSPORT
	;lda #0 ; MIDI OFF
	;rts ; <--FUNCTION DISABLED (DEBUG!!)

	sta midiInterfaceType
testingLoop:
	; save interface type from ACC
	lda midiInterfaceType
	tax
	dex

	sei ; disable IRQ interrupts

	lda #$ff  ; CIA#1 port A = outputs 
	sta DDRA             

	lda #0  ; CIA#1 port B = inputs
	sta DDRB             
	
	; init addresses
	lda midiControlOfs,x
	sta midiControl
	lda midiStatusOfs,x
	sta midiStatus
	lda midiTxOfs,x
	sta midiTx
	lda midiRxOfs,x
	sta midiRx
	lda #$de
	sta midiControl+1
	sta midiStatus+1
	sta midiTx+1
	sta midiRx+1
	
	; send reset code to MIDI adapter
	jsr midiReset
	
	inc dummyMidiIncrementer
	inc dummyMidiIncrementer
	inc dummyMidiIncrementer
	inc dummyMidiIncrementer
	
	ldy #0
	lda (midiStatus),y
	ora (midiStatus),y
	ora (midiStatus),y
	sta 1024+160
	sta statusSample1
	
	; enable IRQ/NMI
	;lda #3 ; MIDI reset (DEBUG)
	lda #$B4 ; $Bx turns on transmit interrupt as well as receive interrupt
	;lda #$34 ; transmit interrupt only
	;lda #$94 ; receive interrupt only (default)
	ora midiCr0Cr1,x
	sta (midiControl),y
	
	inc dummyMidiIncrementer
	inc dummyMidiIncrementer
	inc dummyMidiIncrementer
	inc dummyMidiIncrementer

	ldy #0
	lda (midiStatus),y
	ora (midiStatus),y
	ora (midiStatus),y
	sta 1024+160+1
	sta statusSample2

lock: ; DEBUG!!!!!!!!!!!!!!!!!!!!
	inc 1065
	;jmp lock ; DEBUG!!!!!!!!!!!!!!!!!!!!
	
	
	
	; set the interface to DATEL or NO_MIDI based on results
	lda statusSample1
	bne midiNotDetected
	lda statusSample2
	beq midiNotDetected
	;lda midiInterfaceType ; use current interface
	;cli
	;rts ; quit
	jmp quitDetect
midiNotDetected:
	ldx midiInterfaceType
	dex
	stx midiInterfaceType
	;cpx #1
	beq noMidi ; loop again to try next interface
	jmp testingLoop
noMidi:
	lda #0 ; last interface, so no MIDI
	sta midiInterfaceType
	;cli
	;rts ; quit
	
quitDetect:
	jsr midiReset
	lda midiInterfaceType
	cli
	rts
	
	;;------------------------------------====================================
	
	
	; =========================================================================
	; MIDI INIT
	; =========================================================================
	
	; init MIDI interface, type in accu from midiDetect
midiInit:	
	;rts ; <-- MIDI DISABLED (DEBUG!!)
	
	
	sei ; disable IRQ interrupts

	sta midiInterfaceType
	tax
	dex

	lda #$ff  ; CIA#1 port A = outputs 
	sta DDRA             

	lda #0  ; CIA#1 port B = inputs
	sta DDRB             
	
	; clear memory variables
	lda #0
	sta keyPressed
	sta keyTestIndex
	sta keyPressedIntern

	; init addresses
	lda midiControlOfs,x
	sta midiControl
	lda midiStatusOfs,x
	sta midiStatus
	lda midiTxOfs,x
	sta midiTx
	lda midiRxOfs,x
	sta midiRx
	lda #$de
	sta midiControl+1
	sta midiStatus+1
	sta midiTx+1
	sta midiRx+1
	
	; send reset code to MIDI adapter
	jsr midiReset
	
	; clear ringbuffer
	lda #0
	sta midiRingbufferReadIndex
	sta midiRingbufferWriteIndex
	
	; if the adapter uses NMI interrupts instead of IRQ
	lda midiIrqType,x
	bne midiSetIrq
	
	; set NMI routine
	lda #<midiNmi
	sta $0318
	lda #>midiNmi
	sta $0319
	
	; set IRQ routine
midiSetIrq:	
	;---------------------------
	lda #<midiIrq
	sta $0314
	lda #>midiIrq
	sta $0315
	;---------------------------
	
	; enable IRQ/NMI
	lda #$94
	ora midiCr0Cr1,x
	sta (midiControl),y
	
	cli
	rts

	; =========================================================================

midiRelease:	
	sei
	jsr midiReset
	lda #$31
	sta $0314
	lda #$ea
	sta $0315
	lda #$47
	sta $0318
	lda #$fe
	sta $0319
	cli
	rts
	
	; MC68B50 master reset and IRQ off
midiReset:
	ldy #0
	lda #3
	sta (midiControl),y
	rts

midiCanRead:	
	ldx midiRingbufferReadIndex
	cpx midiRingbufferWriteIndex
	rts

	; read MIDI byte from ringbuffer
midiRead:	
	ldx midiRingbufferReadIndex ; if the read and write pointers are different...
	cpx midiRingbufferWriteIndex
	bne processMidi  ; Slocum: modified to not wait for data...
	;beq midiRead 
	rts ; No new data, so return

	; wait for MIDI byte and read it from ringbuffer
midiReadWait:	
	ldx midiRingbufferReadIndex ; if the read and write pointers are different...
	cpx midiRingbufferWriteIndex
	bne processMidi  ; Slocum: modified to not wait for data...
	jmp midiReadWait 
	;rts ; No new data, so return
	
	
processMidi:
	; read next character from ringbuffer
	lda midiRingbuffer,x
	tay ; save next byte into y
	inx ; increment buffer pointer...
	txa
	;and #31 ; wrap around at end
	and #BUFFER_SIZE_MASK
	sta midiRingbufferReadIndex ; save it
	tya ; the byte read from the buffer ends up in both y and a
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_SHOW_MIDI=1
	;IF DEBUG_DISPLAY=1
	sta temp
	bpl notStatusByte
	lda #$E
	sta hexDispColor
	jmp endColor
notStatusByte	
	lda #$F
	sta hexDispColor
endColor:
	lda debugOffset
	and #$F0
	lsr
	lsr
	lsr
	tax
	;ldx #34
	lda debugOffset
	and #$0F
	tay
	iny
	iny
	iny
	iny
	iny
	iny
	lda temp
	jsr displayHex
	inc debugOffset
	;ldy debugOffset
	;iny
	;tya
	;and #$0F
	;sta debugOffset
	;adc #5
	;tay
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	rts
	
	; write MIDI byte and wait for write complete
midiWrite:	rts  ; TODO		

	; NMI handler
midiNmi:	pha
	txa
	pha
	tya
	pha
	
	; test if it was a NMI from the MIDI interface
	ldy #0
	lda (midiStatus),y
	and #1
	beq midiNmiEnd
	jsr midiStore
midiNmiEnd:	pla
	tay
	pla
	tax
	pla
	rti

	; IRQ handler
midiIrq:
	ldx midiInterfaceType
	dex
	lda midiIrqType,x
	beq midiIrqKey

	; test if it was an IRQ from the MIDI interface
	ldy #0
	lda (midiStatus),y
	and #1
	beq midiIrqKey
	jsr midiStore
	jmp midiNmiEnd

	; keyboard test
midiIrqKey:	
	IF TEST_KEYBOARD=1
	jsr keyboardTest
	ENDIF
	lda $dc0d
	jmp midiNmiEnd

	; get MIDI byte and store in ringbuffer
midiStore:	
	lda (midiRx),y
	ldx midiRingbufferWriteIndex
	sta midiRingbuffer,x
	inx
	txa
	;and #31
	and #BUFFER_SIZE_MASK
	sta midiRingbufferWriteIndex
	rts

		; MC68B50 control register (relative to $de00)
midiControlOfs:	.byte 0, 8, 4, 0

		; MC68B50 status register
midiStatusOfs:	.byte 2, 8, 6, 2

		; MC68B50 TX register
midiTxOfs:	.byte 1, 9, 5, 1

		; MC68B50 RX register offset
midiRxOfs:	.byte 3, 9, 7, 3

		; counter divide bits CR0 and CR1 for the MC68B50
midiCr0Cr1:	
	.byte 1, 1, 2, 1

		; 1=IRQ, 0=NMI
midiIrqType:	
	.byte 1, 1, 1, 0

	IF TEST_KEYBOARD=1
	; keyboard test
keyboardTest:	
	ldx keyTestIndex
	lda keys,x  ; load colum
	sta PRA
	inx
	lda PRB
	and keys,x  ; mask row
	inx
	cmp #0
	bne kbt2
	lda keys,x
	cmp #$80
	bne jump1
	inc shiftPressed
	bne kbt2
jump1:	
	sta keyPressedIntern
kbt2:	
	inx
	cpx #18
	bne kbt3
	ldx keyPressedIntern
	beq jump2
	lda shiftPressed
	beq jump2
	inx
jump2:		
	stx keyPressed
	bne jump3
	lda shiftPressed
	beq jump3
	lda #$40
	sta keyPressed
jump3:		
	ldx #0
	stx shiftPressed
	stx keyPressedIntern
kbt3:		
	stx keyTestIndex
	rts

keys:		
	.byte %11111110, %00010000, 1  ; F1
	.byte %11111110, %00100000, 3  ; F3
	.byte %11111110, %01000000, 5  ; F5
	.byte %11111110, %00001000, 7  ; F7
	.byte %10111111, %00010000, $80  ; right shift
	.byte %10111101, %10000000, $80  ; left shift
	ENDIF