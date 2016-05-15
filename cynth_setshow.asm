
	;-------------------------------------------
	; new key-based set functions
	;-------------------------------------------

ksavePatch
	lda #1
	sta customPatchSaved
	;-------------------
	lda #SAVED_PATCH_MESSAGE
	sta patchSetY
	jsr showPatchName
	;----------------
	ldx #$19
saveLoop:
	lda sidData,x
	sta sidSaveData,x
	dex
	bpl saveLoop
	;----------------
	lda paddle
	sta savePaddle
	lda octave
	sta saveOctave
	lda soundMode
	sta saveSoundMode
	lda fxType
	sta saveFXType
	lda arpSpeed
	sta saveArpSpeed
	lda LFODepth
	sta saveLFODepth
	lda LFORate
	sta saveLFORate
	lda volume
	sta saveVolume
	lda volModeRAM
	sta saveVolMode
	lda filter
	sta saveFilter
	;----------------	
	rts
	
kloadPatch
	; don't load patch if none has been saved
	lda customPatchSaved
	bne contLoadPatch
	rts	
contLoadPatch:
	; Maybe show this name with direct text instead?...
	;lda #SAVED_PATCH_MESSAGE
	;sta patchSetY
	;jsr showPatchName
	;----------------
	lda #CUSTOM_PATCH_NUMBER
	sta patchSetY
	jsr showPatchName
	;-----------------------
	lda saveVolMode
	sta volModeRAM
	;.....................	
	lda saveVolume
	sta volume
	;.....................	
	lda savePaddle
	jsr setPaddles
	;.....................	
	lda saveOctave
	jsr setOctave
	;.....................	
	lda saveSoundMode
	sta soundMode
	;lda saveArpSpeed
	jsr setMode
	;.....................	
	lda saveFXType
	sta fxType
	jsr setFX
	;.....................	
	lda saveLFODepth
	jsr setLFODepth
	;.....................	
	lda saveLFORate
	jsr setLFORate
	;.....................	
	lda saveFilter
	sta filter
	;----------------	
	ldx #$19
loadLoop:
	lda sidSaveData,x
	sta SID1,x
	sta SID2,x
	sta sidData,x
	dex
	bpl loadLoop
	;----------------	
	lda sidData+SV1WAVE
	sta WaveType
	lda sidData+SV2WAVE
	sta WaveType2
	lda sidData+SV3WAVE
	sta WaveType3
	;----------------	
	rts

khelp
	; PREVENT MESSING UP FILTER (WHY IS THIS NEEDED?)
	lda filterSetValue
	sta sidEditSaveTemp1
	

	lda #0
	sta 53280 ; CLEAR RED ERROR BACKGROUND IF SHOWN

	jsr clrScr
	lda #KEYTIME
	sta keyTimer	
	lda helpMode
	eor #1
	;sta helpMode
	jsr setHelpMode
	jsr displayInit
	lda helpMode
	beq showHelpMessage
	;---------------
	; Show full help page...
	ldx #>normalHelp ;low/MSB
	ldy #<normalHelp ;high/LSB
	jsr displayPage ; <--- Draw full help page

	; PREVENT MESSING UP FILTER (WHY IS THIS NEEDED?)
	lda sidEditSaveTemp1
	sta filterSetValue
	rts
		
	; \/ Show help message at bottom of screen
showHelpMessage:
	; Show help key...
	ldx #0
helpMessageLoop:
	lda helpMessage,x
	beq endHelpMsgLoop
	cmp #64
	bmi showSpace99
	sbc #64
showSpace99
	sta 1024+24*40,x
	lda #11
	sta 55296+24*40,x ; color non-static text
	inx
	bne helpMessageLoop
endHelpMsgLoop:

	jsr showMidiMode


;	jsr displayInit

	
	; PREVENT MESSING UP FILTER (WHY IS THIS NEEDED?)
	lda sidEditSaveTemp1
	sta filterSetValue
	
;	ldx #39
;	lda #32
;clearLastRow:
;	sta 1024+23*40,x
;	dex
;	bpl clearLastRow
	rts

kclearModulation
	lda #0
	jsr ksetFX
	lda #0
	jsr setLFODepth
	lda #0
	jmp setLFORate
	
	
;ksetBlackBG
;	lda #0
;	sta 53281
;	sta 53280
;	rts

;ksetBlueBG
;	lda #6
;	sta 53281
;	lda #14
;	sta 53280
;	rts	

	
ksetPalNtsc:
	sta NTSCmode
	jmp displayInit

	; bend the bender down
bendBender:
	lda bender
	cmp #252
	beq notBender
	inc bender
	inc bender
	inc bender
	inc bender
	lda #1
	sta benderAutoreset
notBender:
	rts
	
	; set VIC video chip mode
setVIC:
	sta VICMode
	rts
	
	; set paddle on/off
ksetPaddles:
	jsr setPaddles
	lda filter
	sta filterSetValue
	;jmp setFilter

ksetPad2:
	sta paddle2
	cmp #0
	beq skipLastPadSave
	sta lastPad2 ; save last pad2 setting (other than "OFF")
skipLastPadSave
	asl
	asl
	clc
	adc #PAD2VALTEXT ; add in offset into value text array
	tax
	ldy #PAD2TEXT ; screen position
	jmp updateText

ksetFilter:
	ldx #0
	stx paddle ; turn off paddle controller first (why?)
	;jsr setFilter
	sta filterSetValue
	lda #0
	jmp setPaddles


	;------------------
	; Set pulse width
	;------------------
	; MIDI CONTROLLER            <- 1 1 1  1 1 1 1  
	; PULSE WIDTH        1 1 1 1  1 1 1 1  1 1 1 1
	; -----------------------------------------------
setPulseWidth:
	; write pulse high byte
	tax
	lsr
	lsr
	lsr
	lsr
	sta 1025+40
	sta SID1+SV1PWH
	sta SID1+SV2PWH
	sta SID1+SV3PWH
	sta SID2+SV1PWH
	sta SID2+SV2PWH
	sta SID2+SV3PWH
	sta sidData+SV1PWH
	sta sidData+SV2PWH
	sta sidData+SV3PWH

	; write pulse low byte
	txa
	asl
	asl
	asl
	asl
	;asl ; extra ?
	ora #$0F
	sta 1024+40
	sta SID1+SV1PWL
	sta SID1+SV2PWL
	sta SID1+SV3PWL
	sta SID2+SV1PWL
	sta SID2+SV2PWL
	sta SID2+SV3PWL
	sta sidData+SV1PWL
	sta sidData+SV2PWL
	sta sidData+SV3PWL
	rts


;setAllOscillators:
	;sta SID1+0,y
	;sta SID1+7,y
	;sta SID1+14,y
	;sta SID2+0,y
	;sta SID2+7,y
	;sta SID2+14,y
	;sta sidData+0,y
	;sta sidData+7,y
	;sta sidData+14,y
	;rts
	
		
		
kfiltOnOff:
	sty filterStatus
setResonance:
	ldy filterStatus
	;------------------
	;lda sidData+SFILTC
	lda resonance	
	ora filtOrValue,y
	and filtAndValue,y
	sta SID1+SFILTC
	sta sidData+SFILTC
	;------------------
	lda sidData+SFILTC
	ora filtOrValue,y
	and filtAndValue,y
	sta SID2+SFILTC
	;------------------
	lda filtDisableValue,y
	sta filterDisable
	;------------------
showFiltOnOff:	
	lda filtTextValue,y
	tax
	ldy #FILTERTEXT2
	jmp updateText
	
		
filtOrValue:
	byte $0F,0,0
filtAndValue:
	byte $FF,$F0,$F0
filtDisableValue:
	byte 0,0,1
filtTextValue:	
	byte 4,0,DISABLED

ksetTune:
	sty tuneSetting
	
	tya
	sec
	sbc #4
	sta systemTuning ; Store value in +/- cents for master tuning
	
	;lda tuneArrPtrLL,y
	;sta tunePtrL
	;lda tuneArrPtrLH,y
	;sta tunePtrL+1
	;lda tuneArrPtrHL,y
	;sta tunePtrH
	;lda tuneArrPtrHH,y
	;sta tunePtrH+1
	tya
	asl
	asl
	clc
	adc #TUNING
	tax
	ldy #TUNINGTEXT
	jmp updateText
	

setFullScreenMode:
	sta fullScreenMode
	cmp #0
	beq notFullScreen
	;--------
	lda #<(PTRNTEXTBASE)
	sta lowTextPtr
	lda #>(PTRNTEXTBASE)
	sta lowTextPtr+1
	lda #<(PTRNCOLORBASE)
	sta lowColorPtr
	lda #>(PTRNCOLORBASE)
	sta lowColorPtr+1
	rts
	;--------
notFullScreen:
	lda #<(PTRNTEXTBASE+200)
	sta lowTextPtr
	lda #>(PTRNTEXTBASE+200)
	sta lowTextPtr+1
	lda #<(PTRNCOLORBASE+200)
	sta lowColorPtr
	lda #>(PTRNCOLORBASE+200)
	sta lowColorPtr+1
	jsr displayInit
	rts

setHelpMode:
	sta helpMode
	rts
	
	;--------------------------------
	; Set Video Mode
	;--------------------------------
setVideoMode
	sta videoMode
	sty videoText
	tya	
	clc
	adc #"0"
	sta 1024+VIDEOTEXT
	rts

	;--------------------------------
	; Set Paddles
	;--------------------------------
setPaddles
	sta paddle
	asl
	bne noFilterReset
	ldx filter
	stx SID1+SFILTH
	stx SID2+SFILTH
	sta sidData+SFILTH
noFilterReset:
	ldy #0
	sty paddleTop
	sty paddleBottom
showPaddle:
	asl
	tax
	ldy #PADDLETEXT
	jmp updateText


	;--------------------------------
	; Set LFO Depth
	;--------------------------------
setLFODepth
	sta LFODepth
;showLFO:
	ldy helpMode
	beq doShowLFO
	rts
doShowLFO:
	ldy #LFODEPTHTEXT
	clc
	adc #"0"
	sta 1024,y
	lda #32
	ldx #8
	rts


	;--------------------------------
	; Set LFO Rate
	;--------------------------------
setLFORate
	sta LFORate
showLFORate:
	ldy helpMode
	beq doShowLFORate
	rts
doShowLFORate:
	ldy #LFORATETEXT
	clc
	adc #"0"
	sta 1024,y
	;lda #32
	lda #CYNTHCART_COLOR
	ldx #8
LFOClear:
	;sta 1064,x
	sta 55296,x
	dex
	bpl LFOClear
	rts

	;--------------------------------
	; Set Release for each OSC2 indpendently
	;--------------------------------
	; A = release OSC2 value
setReleaseOSC2:
	;sta release
	sta SID1+SV2SR
	sta SID2+SV2SR
	sta sidData+SV2SR
	rts
	;jmp showRelease
	;----------------

	;--------------------------------
	; Set Release for each OSC3 indpendently
	;--------------------------------
	; A = release OSC2 value
setReleaseOSC3:
	;sta release
	sta SID1+SV3SR
	sta SID2+SV3SR
	sta sidData+SV3SR
	rts
	;jmp showRelease
	;----------------
	;--------------------------------
	; Set Release
	;--------------------------------
	; A = release OSC1 value
	; X = release OSC2 value
	; Y = release OSC3 value
setRelease:
	sta release
	sta SID1+SV1SR
	sta SID1+SV2SR
	sta SID1+SV3SR
	sta SID2+SV1SR
	sta SID2+SV2SR
	sta SID2+SV3SR
	sta sidData+SV1SR
	sta sidData+SV2SR
	sta sidData+SV3SR
	;----------------
showRelease:
	ldy helpMode
	beq doShowRelease
	rts
doShowRelease:
	and #$0F
	tay
	lda sixteenToTen,y
	clc
	adc #"0"
	sta 1024+RELTEXT
	rts
	
	ldy #RELTEXT
	lda #REL_SHORT
	cmp release
	bmi notRel0
	lda #"0"
	jmp setReleaseText
notRel0:
	lda #REL_MED
	cmp release
	bmi notRel1
	lda #"1"
	jmp setReleaseText
notRel1:
	lda #"2"
setReleaseText:
	sta 1024,y
	rts

sixteenToTen:
	byte 0,1,1,2, 3,3,4,4, 5,5,6,6, 7,8,8,9 
	
	
setMidiMode:
	sta midiMode
showMidiMode:
	lda #47
	sta 2017
	lda midiEnabled
	bne doShowMidiMode
	rts	
doShowMidiMode:
	lda #47
	sta 2012
	sta 2007
	ldx midiMode
	bmi showOmni
	;sta 2010
showChannel:
	lda #32
	sta 2008
	lda #3
	sta 2009
	lda #8
	sta 2010
	lda #49
	clc
	adc midiMode
	sta 2011
	rts
showOmni:
	lda #15
	sta 2008
	lda #13
	sta 2009
	lda #14
	sta 2010
	lda #9
	sta 2011
	
	jsr showAdapter
	rts	
	
	;--------------------------------
	; Set Attack
	;--------------------------------
	; A = Attack value
setAttack:
	sta attack
	sta SID1+SV2AD
	sta SID1+SV3AD
	sta SID2+SV2AD
	sta SID2+SV3AD
	sta SID1+SV1AD
	sta SID2+SV1AD
	sta sidData+SV2AD
	sta sidData+SV3AD
	sta sidData+SV1AD
	;----------------
showAttack:
	ldy helpMode
	beq doShowAttack
	rts
doShowAttack:
	lsr
	lsr
	lsr
	lsr
	tay
	lda sixteenToTen,y
	clc
	adc #"0"
	sta 1024+ATKTEXT
	rts


	;-----------------------------------
	; Set Volume to A (for key command)
	;-----------------------------------
ksetVolume
	sta volume
	
	
	;-----------------------------------
	; Set Volume
	;-----------------------------------
setVolume
	lda volModeRAM
	and #$F0
	ora volume
	sta SID1+SVOLMODE
	sta SID2+SVOLMODE
	sta sidData+SVOLMODE
showVolume:
	ldy helpMode
	beq doShowVolume
	rts
doShowVolume:
	and #$0F
	tax
	lda sixteenToTen,x
	clc
	adc #"0"
	sta 1024+VOLTEXT
	rts

	tax
	lda sixteenToTen,x
	tax
	ldy #VOLTEXT
	lda #VOLLOW
	jsr updateText
	rts
	
	
	; set volume text
	ldy #VOLTEXT
	lda #VOLLOW
	cmp volume
	bmi notLow
	ldx #VLOW
	jmp updateText
notLow
	lda #VOLMED
	cmp volume
	bmi notMed
	ldx #VMED
	jmp updateText
notMed
	ldx #VHIGH
	jmp updateText
	;-------------------------------------


	;-----------------------------------
	; Set Octave
	;-----------------------------------
setOctave
	sta octave
	tax
	lda octaveTable,x
	sta keyOffset
showOctave:
	ldy helpMode
	beq doShowOctave
	rts
doShowOctave:
	txa
	clc
	adc #"0"
	tax
	sta 1024+OCTAVETEXT
	rts

	;-----------------------------------
	; Set Filter
	;-----------------------------------
setFilter
	sta SID1+SFILTH
	sta SID2+SFILTH
	sta sidData+SFILTH

	sta filter
showFilter:
	ldy helpMode
	beq testFullScreenMode
	;beq doShowFilter
	rts
testFullScreenMode:
	ldy fullScreenMode
	beq doShowFilter
	rts
doShowFilter:
	lsr
	lsr
	lsr
	lsr
	lsr
	clc
	adc #"0"
endFilter:
	sta 1024+FILTERTEXT
	rts

	
	;-----------------------------------
	; Set Midi mode
	;-----------------------------------
showAdapter:
	; Draw name of new sound mode on screen...
	lda midiEnabled
	asl
	asl
	asl
	;lda modeNameOffsets,x
	;lda fxNames,x
	tax
	ldy #0
drawMidiModeLoop:
	;lda modeNamesPolyphony,x
	lda midiModeNames,x
	cmp #64
	bmi showSpaceZMidiMode
	sbc #64
showSpaceZMidiMode:
	sta 1024+40*24+15,y
	inx
	iny
	cpy #8
	bne drawMidiModeLoop
	; - - - - -
	;inx ; Get polyphony value at end of name string...
	;inx
	;lda modeNamesPolyphony,x
	;sta polyphony

	;lda #8
	;sta bufferSize
	
	rts
	
	
	
	;-----------------------------------
   ; Set FX mode with A,Y (for key command)
	;-----------------------------------
ksetFX
	sta fxType
	;-----------------------------------
	; Set FX mode
	;-----------------------------------
setFX
	lda helpMode
	beq doShowFX
	rts
doShowFX:
	;lda fxType
	
	; Draw name of new sound mode on screen...
	lda fxType
	asl
	asl
	asl
	;lda modeNameOffsets,x
	;lda fxNames,x
	tax
	ldy #0
drawModeLoopFX:
	;lda modeNamesPolyphony,x
	lda fxNames,x
	cmp #64
	bmi showSpaceZFX
	sbc #64
showSpaceZFX:
	sta 1024+FXTEXT,y
	inx
	iny
	cpy #5
	bne drawModeLoopFX
	; - - - - -
	;inx ; Get polyphony value at end of name string...
	;inx
	;lda modeNamesPolyphony,x
	;sta polyphony

	;lda #8
	;sta bufferSize
	
	rts
	
	
	
portSpeedTable
	byte 6,7,9
	;byte 5,7,9
	
	;-----------------------------------
   ; set port with A,Y (for key command)
	;-----------------------------------
ksetMode
   ;sta portOn
   sta soundMode
   ;sty portSpd
	; . . . . . . . . . . 
   	;-----------------------------------
	; Set sound mode
	;-----------------------------------
setMode
showModeName:
	ldy helpMode
	beq doShowModeName
	rts
doShowModeName:

	lda soundMode ; This probably needs work

	; Draw name of new sound mode on screen...
	ldx soundMode
	lda modeNameOffsets,x
	tax
	ldy #0
drawModeLoop:
	lda modeNamesPolyphony,x
	cmp #64
	bmi showSpaceZ
	sbc #64
showSpaceZ
	sta 1024+MODETEXT,y
	inx
	iny
	cpy #5
	bne drawModeLoop
	; - - - - -
	inx ; Get polyphony value at end of name string...
	inx
	lda modeNamesPolyphony,x
	sta polyphony

	lda #8
	sta bufferSize
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;sta 1024+161 ;DEBUG
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	; set up pointer to portamento speed array
	; (which is the tuning array)
	;lda portSpd
	;clc
	;adc #4
	
	; New version of code above...
	lda soundMode
	and #$0F ; Get portamento speed
	tay
	lda portSpeedTable,y
	
	;clc 
	;asl ; X2
	;adc #5
	
	tay
;	ldy #5 ; portSpd DEBUG
	lda tuneArrPtrLL,y
	sta portPtrL
	lda tuneArrPtrLH,y
	sta portPtrL+1
	lda tuneArrPtrHL,y
	sta portPtrH
	lda tuneArrPtrHH,y
	sta portPtrH+1
	rts


	;----------------------------------------
	; subroutine to set up patch 
	; (patch # stored in Y)
	;----------------------------------------
setPatch
	sty patchSetY

	lda patchVol,y
	sta volume

	lda patchPaddle,y
	jsr setPaddles

	;.....................
	jsr midiPanic
	;.....................

	; Reset modulation values
	lda #127
	sta filterModValue
	sta pwModValue

	ldy patchSetY
	lda newPatchFiltCut,y
	sta filterSetValue
	;jsr setFilter

	;lda patchFilt,y
	;sta SID1+SV1PWL

	
	ldy patchSetY
	lda patchSoundMode,y
	sta soundMode
	jsr setMode

	ldy patchSetY
	lda patchPWL,y
	sta SID1+SV1PWL
	sta SID1+SV2PWL
	sta SID1+SV3PWL
	sta SID2+SV1PWL
	sta SID2+SV2PWL
	sta SID2+SV3PWL
	sta sidData+SV1PWL
	sta sidData+SV2PWL
	sta sidData+SV3PWL

	ldy patchSetY
	lda patchPWH,y
	sta SID1+SV1PWH
	sta SID1+SV2PWH
	sta SID1+SV3PWH
	sta SID2+SV1PWH
	sta SID2+SV2PWH
	sta SID2+SV3PWH
	sta sidData+SV1PWH
	sta sidData+SV2PWH
	sta sidData+SV3PWH

	ldy patchSetY
	lda patchWave1,y
	sta WaveType
	lda patchWave2,y
	sta WaveType2
	lda patchWave3,y
	sta WaveType3

	ldy patchSetY
	lda patchLFO,y
	and #$0F
	sty temp
	jsr setLFORate
	ldy temp
	lda patchLFO,y
	and #$F0
	lsr
	lsr
	lsr
	lsr
	;lda #2
	jsr setLFODepth

	ldy temp
	lda patchAD,y
	;lda #0 ; DEBUG!!!!!!!!!!!!!!!!!!!!!!!!
	;lda #$F0
	jsr setAttack
	ldy patchSetY

	ldy temp
	lda patchSR1,y
	jsr setRelease
	ldy temp
	lda patchSR2,y
	jsr setReleaseOSC2
	lda patchSR3,y
	jsr setReleaseOSC3
	
	ldy patchSetY

	lda patchFilt,y
	ldx filterDisable
	beq skipFilterDisable
	and #$F0
skipFilterDisable:
	sta SID1+SFILTC
	sta SID2+SFILTC
	sta sidData+SFILTC
	and #$01
	beq skipFilterOnText
	ldy #FILTERTEXT2
	ldx #4
	jsr updateText
skipFilterOnText
	ldy patchSetY

	lda patchVolMode,y
	and #$F0
	ora volume
	sta volModeRAM
	jsr setVolume
	ldy patchSetY

	lda patchOctave,y
	jsr setOctave
	ldy patchSetY

	lda patchFX,y
	sta fxType 
	jsr setFX
	
	jsr showPatchName

	rts
	;------------------------ end of setpatch

showPatchName:
	lda helpMode
	beq doShowPatchName
	rts
doShowPatchName:
	lda patchSetY
	and #%11110000
	bne patchNameSecondBank
	;tay
	ldy patchSetY
	iny
	tya
	asl
	asl
	asl
	asl
	tay
	dey
	ldx #15
patchText:
	lda patchName,y
	cmp #64
	bmi pshowSpace
	sec
	sbc #64
pshowSpace:
	sta 1024+PATCHTEXT,x
	dey
	dex
	bpl patchText
	rts

patchNameSecondBank:
	;tay
	ldy patchSetY
	iny
	tya
	asl
	asl
	asl
	asl
	tay
	dey
	ldx #15
patchText2:
	lda patchName2,y
	cmp #64
	bmi pshowSpace2
	sec
	sbc #64
pshowSpace2:
	sta 1024+PATCHTEXT,x
	dey
	dex
	bpl patchText2
	rts
	
	