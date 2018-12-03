HEX_DISP_OFFSET equ 4


;---------------------------------
; Wait until no hex key is down
; (doesn't check all keys, only hex keys!)
waitForKeyRelease:
	jsr readHexKey
	cmp #255
	bne waitForKeyRelease
	ldx #255 ; Always 255
	ldy #96 ; Delay amount
delay ; Delay a short time to avoid catching key bounce...
	dex
	bne delay
	dey
	bne delay
	rts

	
	;===============================================
	; Allow the user to hex edit the SID registers
	; directly.
SIDEdit:

	; PREVENT SID EDIT FROM MESSING UP FILTER (WHY IS THIS NEEDED?)
	ldx filterSetValue
	stx sidEditSaveTemp5

	sta hexKeyMode

	;jsr beep
	;jsr beep
	;jsr beep

	jsr clrScr
	jsr displayInit

	; X = low data address
	; Y = high data address
	ldx #>hexEditHelp ;low/MSB
	ldy #<hexEditHelp ;high/LSB
	jsr displayPage

	jsr showSidValues

	
	;enable keyboard interrupt
;	lda #129
;	sta 56333
	; wait for all keys to be released first
;waitForNoKey:
;	lda 197
;	cmp #64
;	bne waitForNoKey


	; clear top line
	ldx #9
	lda #32
hexClearA
	sta 1024,x
	dex
	bpl hexClearA

	; display "sid edit" text
	ldx #92
	ldy #0
	jsr updateText

	;jsr waitForKeyRelease
	
	; get/display the first hex digit of the address to edit
	lda #36
	sta 1024+HEX_DISP_OFFSET
	jsr getHexKey
	cmp #16 ; cancelled
	bne notCancelled
	jmp waitKeyRelease
notCancelled:
	tax
	asl
	asl
	asl
	asl
	sta SIDeditAddr
	lda hexDisplay,x
	sta 1024+HEX_DISP_OFFSET

	;sta 1024
	;jsr waitForKeyRelease
	;sta 1024
	
	; get/display the second hex digit of the address to edit
	lda #36
	sta 1025+HEX_DISP_OFFSET
	jsr getHexKey
	cmp #16 ; cancelled
	bne notCancelled2
	jmp waitKeyRelease
notCancelled2:
	tax
	ora SIDeditAddr
	sta SIDeditAddr
	lda hexDisplay,x
	sta 1025+HEX_DISP_OFFSET
	
	; display a '>' between
	lda #62
	sta 1026+HEX_DISP_OFFSET

	; get/display the first hex digit of the value to write
	lda #36
	sta 1027+HEX_DISP_OFFSET
	jsr getHexKey
	cmp #16 ; cancelled
	bne notCancelled3
	jmp waitKeyRelease
notCancelled3:
	tax
	asl
	asl
	asl
	asl
	sta SIDeditValue
	lda hexDisplay,x
	sta 1027+HEX_DISP_OFFSET

	; get/display the second hex digit of the value to write
	lda #36
	sta 1028+HEX_DISP_OFFSET
	jsr getHexKey
	cmp #16 ; cancelled
	bne notCancelled4
	jmp waitKeyRelease
notCancelled4:
	tax
	ora SIDeditValue
	sta SIDeditValue
	lda hexDisplay,x
	sta 1028+HEX_DISP_OFFSET

	; if <=$20 then write to all 3 SID oscillator regs
	ldx SIDeditAddr
	cpx #$20
	bmi normalWrite
	;--------------
	lda SIDeditValue
	sta SID1-32,x
	sta SID2-32,x
	sta sidData-32,x
	sta SID1-32+#$7,x
	sta SID2-32+#$7,x
	sta sidData-32+#$7,x
	sta SID1-32+#$E,x
	sta SID2-32+#$E,x
	sta sidData-32+#$E,x
	cpx #SV1WAVE+32
	bne no3Wave
	sta WaveType
	sta WaveType2
	sta WaveType3
no3Wave:
	jmp skipNormalWrite
	;...............
normalWrite:
	; write the value to both sids
	ldx SIDeditAddr
	lda SIDeditValue
	sta SID1,x
	sta SID2,x
	sta sidData,x

	cpx #SV1WAVE
	bne noWave1
	sta WaveType
noWave1:

	cpx #SV2WAVE
	bne noWave2
	sta WaveType2
noWave2:

	cpx #SV3WAVE
	bne noWave3
	sta WaveType3
noWave3:

	cpx #SFILTH
	bne noFiltSave
	sta filter
noFiltSave:

	; turn off paddles if filter was adjusted
	cpx #SFILTL
	beq paddleOffhex
	cpx #SFILTH
	bne noPaddleOff
paddleOffhex:
	lda #0
	sta paddle ; turn off paddle controller first
	jsr showPaddle
noPaddleOff:

skipNormalWrite:
	ldx SIDeditAddr
	lda SIDeditValue

	; check for a volume/mode change...
	; if changed, write it to related variables too
	cpx #SVOLMODE
	bne noVolumeSetting
	sta temp
	and #$F0
	sta volModeRAM
	lda temp
	and #$0F
	sta volume
noVolumeSetting:
;	lda volModeRAM
;	and #$F0
;	ora volume

	; wait for key to be released before returning
waitKeyRelease:
	lda 197
	cmp #64
	bne waitKeyRelease

	; reset volume (messed up from clicks)
	jsr setVolume

	lda #0
	;sta helpMode
	jsr setHelpMode
	jsr displayInit
	; X = low data address
	; Y = high data address
;	ldx #>hexEditHelp ;low/MSB
;	ldy #<hexEditHelp ;high/LSB
;	jsr displayPage
;	jsr showSidValues

	; PREVENT SID EDIT FROM MESSING UP FILTER (WHY IS THIS NEEDED?)
	lda sidEditSaveTemp5
	sta filterSetValue
	

	rts ; EXIT HEX EDIT MODE
	; -------------------------------------------------- /

	
	
	;************************************
showSidValues:
	ldy #2
sidDispLoop1:
	sty sidTemp1
	lda sidData,y
	sta sidTemp2
	tya
	asl
	clc
	adc #4
	tay
	lda sidTemp2
	ldx #6
	jsr displayHex
	ldy sidTemp1
	;---------------
	lda sidData+7,y
	sta sidTemp2
	tya
	asl
	clc
	adc #4
	tay
	lda sidTemp2
	ldx #10
	jsr displayHex
	ldy sidTemp1
	;---------------
	lda sidData+14,y
	sta sidTemp2
	tya
	asl
	clc
	adc #4
	tay
	lda sidTemp2
	ldx #14
	jsr displayHex
	ldy sidTemp1

	iny
	cpy #7
	bne sidDispLoop1
	;---------------
	;---------------
	ldy #$15
sidDispLoop2:
	sty sidTemp1
	lda sidData,y
	sta sidTemp2
	tya
	sec
	sbc #2
	tay
	lda sidTemp2
	ldx #5
	jsr displayHex
	ldy sidTemp1

	iny
	cpy #$19
	bne sidDispLoop2
	;---------------
	rts

	
	
	;=======================================================================
	; waits for user to press a key (0-F) and returns
	; the value in A
getHexKey:
	jsr waitForKeyRelease
getHexLoop:
	;inc 1024
	jsr readHexKey
	cmp #255 ; No key pressed
	beq getHexLoop
	;inc 1025
	rts



	;=======================================================================
	; Returns the currently pressed hex key, or #255 if none 
	; is currently pressed
readHexKey

	lda hexKeyMode ; this variable determines which key set is used
	beq normalHexKey
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Use piano keys to enter hex numbers
pianoHexKey:
	ldy #0
checkLoop2:
	lda hexColPiano,y
	beq quitCheck2
	sta 56320
	lda 56321
	and hexRowPiano,y
	bne notPressed2
	tya
	;sta 1027
	rts
	;jmp quitCheck2
notPressed2:
	iny
	bne checkLoop2
quitCheck2:
	lda #255 ; no key pressed
	rts	
	;jmp pianoHexKey
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Use normal keys (0-9,A-F) to enter hex numbers
normalHexKey:
	ldy #0
checkLoop3:
	lda hexCol,y
	beq quitCheck3
	sta 56320
	lda 56321
	and hexRow,y
	bne notPressed3
	tya
	;sta 1027
	rts
	;jmp quitCheck3
notPressed3:
	iny
	bne checkLoop3
quitCheck3:
	lda #255 ; no key pressed
	rts	

;beep:
	;ldx #3
;beepLoop:
;	lda volModeRAM
;	ora #$0F
;	sta SID1+SVOLMODE
;	sta SID2+SVOLMODE
;	sta sidData+SVOLMODE
;	jsr clickDelay
;	lda volModeRAM
;	and #$F0
;	sta SID1+SVOLMODE
;	sta SID2+SVOLMODE
;	sta sidData+SVOLMODE
;	dex
;	bne beepLoop
;	rts
	

	; ------------------------------------
	; delay for click (for beep) -- uses Y
;clickDelay:
	;ldy #$10
	;sty temp
;mainDelayLoop:
;	ldy #0
;innerDelayLoop:
;	dey
;	bne innerDelayLoop
;	dec temp
;	bne mainDelayLoop
;	rts	
	
