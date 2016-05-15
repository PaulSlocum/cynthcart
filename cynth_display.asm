
	; ***************************
	; Process Video Mode
	; ***************************

processVideoMode:
	; Turn off Vic when no notes are playing
	lda helpMode
	bne vicOn
	
	lda VICMode
	beq vicOff 
	cmp #2
	beq vicOn
	lda dispOn
	bne vicOn
	lda noteNumArray+0
	;lda KeyA

	cmp #255
	bne vicOn
	lda noteNumArray+1
	;lda KeyB
	cmp #255
	bne vicOn
	lda noteNumArray+2
	;lda KeyC
	cmp #255
	bne vicOn
vicOff:
	; Vic off
	lda $d011
	and #$EF
	sta $D011

	jmp endVic
vicOn:
	; Vic on
	lda $d011
	ora #$10
	sta $d011

endVic:
	lda #0
	sta dispOn

	lda noteNumArray+0
	;lda KeyA
	sta temp
	jsr drawPattern
	lda noteNumArray+1
	;lda KeyB
	sta temp
	jsr drawPattern
	lda noteNumArray+2
	;lda KeyC
	sta temp
	jsr drawPattern

	rts
	;jmp Loop
	;====================================================
	; bottom of main loop
	;====================================================


	; ***************************
	; code to draw colored character patterns
	; ***************************
;PTRNTEXTBASE equ 1224
PTRNTEXTBASE equ 1224-40*5
;PTRNCOLORBASE equ 55496
PTRNCOLORBASE equ 55496-40*5


drawPattern
	; don't draw video when in help mode
	lda helpMode
	beq continueVideo
	rts
continueVideo:
	;---------
	; setup
	ldx patPtr
	inx
	cpx #40
	bne noPatReset
	ldx #0
noPatReset:
	stx patPtr	
	;---------
	ldx #5
	; main pattern loop
patternLoop:
	if DEBUG_DISABLE_VIDEO_MODE=1
	rts ; DEBUG! disable patterns
	endif

	lda patOffset,x
;	clc
	adc patPtr
	tay
;	clc
	lda temp
	cmp #255
	beq skipExtraColors	
	lda Frame
	and videoMode
	clc
	adc temp
skipExtraColors:
	adc #190
	sta temp2
	lda temp
	cmp #255
	bne reloadValue
	lda #127
	jmp afterReloadValue
reloadValue:
	lda temp2
afterReloadValue:
	sta (lowTextPtr),y
	sta PTRNTEXTBASE+200,y
	sta PTRNTEXTBASE+400,y
	sta PTRNTEXTBASE+600,y
	cpy #248
	bmi noTopText
	sta PTRNTEXTBASE+800,y
noTopText:
	;sbc #13
	adc #12
	sta (lowColorPtr),y
	sta PTRNCOLORBASE+200,y
	sta PTRNCOLORBASE+400,y
	sta PTRNCOLORBASE+600,y
	cpy #248
	bmi noTopColor
	sta PTRNCOLORBASE+800,y
noTopColor:
	dex
	bpl patternLoop
	rts
	;--------------------- end of draw patterns
	
	
	
	; ***************************
	; Display Setup
	; ***************************
displayInit:

	lda #21
	sta 53272 ; UPPERCASE mode

	; draw static text at the top of the screen
	ldx #>mainColorText ;low/MSB
	ldy #<mainColorText ;high/LSB
	jsr displayPage
	
	; Draw bottom text (version number+PAL/NTSC setting)
BOTTOMTEXT equ 40*24+29

	jsr showHelpMessage

	; SHOW BETA MESSAGE IF IN BETA MODE
	ldx #12
betaInfoLoop:
	lda betaInfo,x
	cmp #64
	bmi showSpaceBeta
	sbc #64
showSpaceBeta
	sta 1024+BOTTOMTEXT-40-3,x
	dex
	bpl betaInfoLoop
	
		; choose which text to show from PAL/NTSC test at startup
	ldx #0
	ldy #0
	lda NTSCmode
	beq showPAL
	ldx #12
showPAL:
	; Show version number and NTSC/PAL designation...
TextLoop2:
	lda bottomText,x
	beq endText2
	cmp #64
	bmi showSpace2
	sbc #64
showSpace2
	sta 1024+BOTTOMTEXT,y
	lda #11
	sta 55296+BOTTOMTEXT,y ; color non-static text
notBlank2:
	inx
	iny
	bne TextLoop2
endText2:

	IF DEVICE_CONFIG=KERBEROS
	lda #11 ; "K"
	sta 2022
	ENDIF
	IF DEVICE_CONFIG=EMU
	lda #5 ; "E"
	sta 2022
	ENDIF
	IF DEVICE_CONFIG=SIDSYMPHONY
	lda #19 ; "S"
	sta 2022
	ENDIF

	jsr showMidiMode

	;---------------------------------------------
	; Display current sound parameter values

	; set tuning text
	ldy tuneSetting 
	jsr ksetTune

	; Video Mode
	lda videoMode
	ldy videoText
	jsr setVideoMode ;********************************

	lda LFODepth
	jsr setLFODepth ;********************************
	lda LFORate
	jsr setLFORate ;********************************

	lda paddle
	jsr setPaddles
	
	lda filter
	sta filterSetValue
	;jsr setFilter
	
	jsr setMode

	jsr setFX
	
	lda attack
	jsr showAttack
	
	jsr showMidiMode
	
	lda release
	jsr showRelease
	
	ldy filterStatus
	jsr showFiltOnOff
	
	jsr setVolume
	
	lda octave
	jsr setOctave

	jsr showPatchName
	
	lda paddle2
	jsr ksetPad2

	rts
	;---------------------------------------------------

	;************************************
	; update text
	;************************************
	; Show text out of the textData array.
	; x=textData, y=screen position
updateText
	lda helpMode
	beq doUpdateText
	rts
doUpdateText:
;	lda helpMode
;	bne doUpdateText
;	rts
;doUpdateText:
	clc
	lda #4
	sta textTemp
updateTextLoop:
	lda textData,x
	cmp #64
	bmi showSpaceU
	sbc #64
showSpaceU
	sta 1024,y
	inx
	iny
	dec textTemp
	bne updateTextLoop
	rts


	;************************************
	; clrScr - Clear Screen
	;************************************	
clrScr:
	ldx #0
	lda #32
clrScrLoop:
	sta $400,x
	sta $500,x
	sta $600,x
	sta $700,x
	dex
	bne clrScrLoop
	rts


	;************************************
	; DisplayHex - draw hex value on screen
	;************************************
	; note uses helpWritePointer so can't be
	; used within displayPage routine
	; X = horizontal location
	; Y = vertical location
	; A = value
	; hexDispColor = color
displayHex
	; figure out screen location
	; and store in word pointer
	stx hexDispTemp
	tax ; save the hex value in X
	lda lineOffsetL,y
	clc
	adc hexDispTemp
	sta helpWritePointerL
	sta helpColorPointerL

	lda lineOffsetM,y
	adc #0
	sta helpWritePointerM
	clc
	adc #$D4
	sta helpColorPointerM
	;--------------------
	stx hexDispTemp ; save the hex value to be displayed
	txa
	and #$0F ; isolate the LS nibble
	tax
	lda hexDisplay,x ; get character to display
	ldy #1
	sta (helpWritePointerL),y
	;lda #$E
	lda hexDispColor
	sta (helpColorPointerL),y
	;-------------------
	lda hexDispTemp
	lsr	; get the MS nibble
	lsr
	lsr
	lsr
	tax
	lda hexDisplay,x ; get character to display
	ldy #0
	sta (helpWritePointerL),y
	;lda #$E
	lda hexDispColor
	sta (helpColorPointerL),y
	;-------------------
	rts
	

	;************************************
	; DisplayPage - display an entire
	; page of help info with color support
	;************************************
	; X = LSB of data address
	; Y = MSB of data address
	; data format:
	; line_number, color, text, 0
	; line_number, color, text, 0
	; 255
displayPage:
	sty helpReadPointerL
	stx helpReadPointerM

	; PREVENT FILTER BEING MESSED UP (WHY IS THIS NEEDED?)	
	;lda filterSetValue
	;sta sidEditSaveTemp1

	lda #1
	sta helpColor ; default to white
helpLoop:
	ldy #0
	; get line number and set up output pointers
	lda (helpReadPointerL),y
	cmp #255
	beq quitHelp
	tax
	lda lineOffsetM,x
	sta helpWritePointerM
	clc
	adc #$D4
	sta helpColorPointerM
	lda lineOffsetL,x
	sta helpWritePointerL
	sta helpColorPointerL
	;--------------------
	ldy #1
	sty helpYIn
	ldy #0
	sty helpYOut
helpTextLoop:
	; get the first character
	ldy helpYIn
	lda (helpReadPointerL),y
	beq quitTextLoop
	iny 
	sty helpYIn
	; see if it's a color command
	cmp #128
	bpl setColor ;---
	cmp #64
	bmi showSpaceHelp
	sbc #64
	;lda #126
showSpaceHelp:
	; write the color and character to the screen
	ldy helpYOut
	sta (helpWritePointerL),y
	lda helpColor
	sta (helpColorPointerL),y
	iny
	sty helpYOut
	jmp helpTextLoop
setColor:
	sec
	sbc #128
	sta helpColor
	jmp helpTextLoop
	;---------------
quitTextLoop:
	; update the input pointer
	iny
	tya
	clc
	adc helpReadPointerL
	sta helpReadPointerL
	lda helpReadPointerM
	adc #0
	sta helpReadPointerM
	jmp helpLoop ;/\/\/\/\/\
quitHelp:

	; PREVENT FILTER BEING MESSED UP (WHY IS THIS NEEDED?)	
	;lda sidEditSaveTemp1
	;sta filterSetValue

	rts ; END OF DISPLAY PAGE