	
		
	;-------------------------------------
	; Process FX
	;-------------------------------------
	;fxType equ $7086
	;modValue1 equ $7087
	;modDirection equ $7089
	;modCounter equ $708A
	;modMinValue equ $708B
	;modMaxValue equ $708A
	; - - - - - - - - - - 
	;MOD_NONE equ 0
	;MOD_PW_LFO equ 1
	;MOD_FILT_LFO equ 2
	;MOD_FILT_OPEN equ 3
	;MOD_FILT_CLOSE equ 4
	;MOD_FILT_WOW equ 5
	
processFX	
	lda fxType
	bne doFX
	lda #127 ; Set default mod values...
	sta pwModValue
	sta filterModValue
	jmp quitFX
	; - - - - - - - -
doFX:
	cmp #MOD_PW_LFO
	bne notModPulseLFO
	jmp modPulseLFO ;------->
notModPulseLFO:
	cmp #MOD_FILT_LFO
	bne notModFiltLFO
	jmp modFiltLFO ;------->
notModFiltLFO:
	cmp #MOD_FILT_ENV
	bne noModFiltEnv
	jmp modFiltEnv ;------->
noModFiltEnv:
	cmp #MOD_FILT3
	beq modFilt3 ;------->
	cmp #MOD_FILT4 
	beq modFilt4 ;------->
	cmp #MOD_FILT5
	beq modFilt5 ;------->
	cmp #MOD_PW2
	bne quitFX
	jmp modPW2 ;------->
quitFX:
	rts


;---------------------	
modFilt3: ; - Fast, high-to-low filter sweep (for synth bass, etc)
	lda Frame
	lda modValue1
	and #%11111000
	beq noDecModValue2
	ldx modValue1
	dex
	dex
	dex
	dex
	dex
	stx modValue1
noDecModValue2:
	lda modValue1
	sta filterModValue
	;jsr setFilterFromA
	;rts ; DEBUG!!
	
	lda #180
	sta resetValue
	;jmp filtEnvReset ;---- end

filtEnvResetFast:
	lda soundMode
	cmp #MODE_MONO1
	beq handleMonoMode
	cmp #MODE_MONO2
	beq handleMonoMode
	
	; Reset filter envelope when new notes appear in buffer (POLY VERSION)
	ldx #5
	ldy #0
countNotesLoop
	lda noteNumArray,x
	cmp #255
	bne skipCountingNote
	iny
skipCountingNote:
	dex
	bpl countNotesLoop
	cpy lastNoteCount
	beq noNewNotes
	sty lastNoteCount
	lda resetValue ; Reset filter envelope
	sta modValue1
noNewNotes:
	rts

handleMonoMode:
	ldy noteNumArray+0
	cpy lastNote
	beq sameOldNote
	sty lastNote
	lda resetValue ; Reset filter envelope
	sta modValue1
sameOldNote:
	rts
	
	; Reset filter env when no notes are held...
;	ldx #5
;filtEnvResetLoop2
	;lda noteNumArray,x
	;cmp #255
	;bne quitFiltEnv2
	;dex
	;bpl filtEnvResetLoop2
	;lda resetValue
	;sta modValue1
;quitFiltEnv2:
	;rts

;---------------------	
modFilt4: ; Filter chopper FAST
	lda Frame
	and #%1000
	beq filterClosed
	lda #230
	sta filterModValue
	rts
	;jmp setFilterFromA	
filterClosed
	lda #0
	sta filterModValue
	rts
	;jmp setFilterFromA
	

;---------------------	
modFilt5: ; Filter chopper MEDIUM
	lda Frame
	and #%10
	beq filterClosed2
	lda #150
	;jmp setFilterFromA	
	sta filterModValue
	rts	
filterClosed2
	lda #50
	;jmp setFilterFromA
	sta filterModValue
	rts	
	
;---------------------	
modPW2: ; PW Envelope
	lda Frame
	lda modValue1
	;and #%11111000
	and #%11100000
	beq noDecModValue3
	ldx modValue1
	dex
	dex
	dex
	dex
	dex
	stx modValue1
noDecModValue3:
	lda modValue1
	jsr setPulseWidth
	
	lda #180
	sta resetValue

	jmp filtEnvResetFast
	rts
	
	
	
	
;---------------------	
modFiltEnv:
	lda Frame
	and #%1
	beq doEnvLFO
	rts
doEnvLFO:
	lda modValue1
	cmp #255
	beq noIncreaseModValue
	inc modValue1
noIncreaseModValue:
	lda modValue1
	sta filterModValue
	;jsr setFilterFromA
	lda #0
	sta resetValue 
	; jmp filtEnvReset
	
filtEnvReset:
	ldx #5
filtEnvResetLoop
	lda noteNumArray,x
	cmp #255
	bne quitFiltEnv
	dex
	bpl filtEnvResetLoop
	;lda #0
	lda resetValue
	sta modValue1
quitFiltEnv:
	rts
	
;---------------------	
modFiltLFO:
	lda #150
	sta modLFOMinValue
	lda #254
	sta modLFOMaxValue
	jsr doModulationLFO
	lda modValue1
	sta filterModValue
	;jsr setFilterFromA
	rts

	
	
;---------------------	
modPulseLFO:
	
	; Reset into range if way off value...
	lda modValue1
	bmi noResetValue
	lda #200
	sta modValue1
noResetValue

	;inc 1025 ; DEBUG!
	lda #150
	sta modLFOMinValue
	lda #254
	sta modLFOMaxValue
	jsr doModulationLFO
	ldx modValue1
	stx paddleY

	lda modValue1
	jsr setPulseWidth
	rts
	
	; Process special LFO for modulation
	; Store modLFOMaxValue and modLFOMinValue first
doModulationLFO
	lda Frame
	and #%111
	beq doModLFO
	rts
doModLFO:
	lda modDirection
	beq LFODown
LFOUp:
	ldx modValue1
	inx
	stx modValue1
	;jsr setPWValue
	stx paddleY
	;jsr setPulseWidth
	ldx modValue1
	
	cpx #245
	beq switchDirections
	rts
	
LFODown:
	ldx modValue1
	dex 
	stx modValue1
	cpx #150
	beq switchDirections
	rts
	
switchDirections:
	lda modDirection
	clc 
	adc #1
	and #1
	sta modDirection
	rts
