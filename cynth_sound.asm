processSoundDriver:
	; determine whether to use portamento player
	; or regular player...
	lda soundMode
	beq polyMode
	and #MONO_MASK
	beq nextSoundModeCheck1
	jmp playMono
nextSoundModeCheck1:
	lda soundMode
	and #PORT_MASK
	beq nextSoundModeCheck2
	jmp playPort
nextSoundModeCheck2:
	lda soundMode
	and #ARP_MASK
	beq nextSoundModeCheck3
	jmp playArp
nextSoundModeCheck3:
	lda soundMode
	and #CHAN6_MASK
	beq nextSoundModeCheck4
	jmp play6Chan
nextSoundModeCheck4:
	jmp playFifths ; Otherwise, it's a 5ths mode
	;lda soundMode
	;cmp #MODE_5THS
	;bne endSoundMode
	;jmp playFifths
;endSoundMode:
	;brk ; Shouldn't ever reach this point in code
	
	
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; POLYPHONIC STEREO SOUND DRIVER (DEFAULT)
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
polyMode:
	ldx #2
polyCopyLoop
	lda noteNumArray,x
	sta playNoteArray,x
	dex
	bpl polyCopyLoop

	lda noteNumArray+0 ; Duplicate notes on second SID for stereo
	sta playNoteArray+3
	lda noteNumArray+1
	sta playNoteArray+4
	lda noteNumArray+2
	sta playNoteArray+5

	jmp sixVoicePlayer
	
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; MONO-STACK SOUND DRIVER
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
playMono:
	lda noteNumArray
playMonoWithA:
	sta temp
	sta playNoteArray+0
	cmp #255
	beq monoMute
	ldx soundMode
	;dex
	;beq noRaiseOctave
	cpx #MODE_MONO2
	beq noRaiseOctave	; Skip shifting the octave in MONO2 mode
	cpx #MODE_MONOPORT2
	beq noRaiseOctave
	;-------------------------------------
	clc
	adc #12
noRaiseOctave:
	sta playNoteArray+1
	;lda noteNumArray
	lda temp
	ldx soundMode
	cpx #MODE_MONO2
	beq noDropOctave	; Skip shifting the octave in MONO2 mode
	sec
	sbc #12
	bcs noDropOctave ; If no borrow occurred then continue...
	lda temp ; Borrow occurred, so don't drop octave
	;-------------------------------------
noDropOctave:
	sta playNoteArray+2
	jmp doubleToStereo
monoMute
	sta playNoteArray+1
	sta playNoteArray+2

doubleToStereo:
	lda playNoteArray+0
	 sta playNoteArray+3
	lda playNoteArray+1
	 sta playNoteArray+4
	lda playNoteArray+2
	 sta playNoteArray+5

	;;- NEW! ------------------------------;;
 	lda soundMode
	and #PORT_MASK
	beq continueToSixVoice7
	jmp portPlayer ; SKIP TO PLAYER
	;jmp playPort ; ORIGINAL
	;;-------------------------------------;;

continueToSixVoice7:
	jmp sixVoicePlayer
	
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; 5THS SOUND DRIVER (DEFAULT)
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
playFifths:
	;jmp polyMode ; DEBUG!
	jsr doSort
	ldx #2
fifthsCopyLoop
	lda noteNumArray,x
	sta playNoteArray,x
	dex
	bpl fifthsCopyLoop
	; Add 5th
	lda playNoteArray
	cmp #255 
	beq end5ths
	lda playNoteArray+1
	cmp #255
	bne checkThird
	; Found a note and an empty slot, put 5th in second slot
	lda playNoteArray
	clc
	adc #7
	sta playNoteArray+1
	jmp end5ths
	
checkThird:
	lda playNoteArray+2
	cmp #255
	bne end5ths ; No empty slot, so no 5th
	; Third slot is free, so put 5th is 3rd slot
	lda playNoteArray+1
	clc
	adc #7
	sta playNoteArray+2
	jmp end5ths
	
end5ths:
	lda playNoteArray+0
	 sta playNoteArray+3
	lda playNoteArray+1
	 sta playNoteArray+4
	lda playNoteArray+2
	 sta playNoteArray+5

	lda soundMode
	cmp #MODE_5PORT
	beq playPort5th
	jmp sixVoicePlayer
playPort5th:
	jmp portPlayer
	
	
	
	
arpSpeedTable
	byte %11,%111,%1111,%111,%11,%1,%11,%111,%1111,%11111,%111111

	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; ARP STEREO SOUND DRIVER
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
playArp:

	; Figure out arp speed setting...
	lda soundMode
	and #$0F
	tax
	lda arpSpeedTable,x
	sta temp
	
	ldx soundMode
	cpx #MODE_ARP4
	beq playArpDown
	cpx #MODE_ARP5
	beq playArpDown

	;***********	
	; ARP UP
	;***********	
	; Increment arpOffset pointer...
	lda Frame
	and temp ; Arp speed
	bne skipArpAdvance
	inc arpOffset
skipArpAdvance:

	; Sort note buffer
	jsr doSort
	
	; Count the number of notes...
	ldx #0
	lda #255
noteCount:
	cmp noteNumArray,x
	beq quitNoteCount
	inx
	cpx bufferSize
	bne noteCount
quitNoteCount:
	; X now contains the note count

	; Make sure arpOffset isn't past end...
	dex
	cpx arpOffset
	bpl noArpOffsetReset
	lda #0 ; Reset to zero
	sta arpOffset
noArpOffsetReset:
	
	; Play single arp note...
	ldy arpOffset
	lda noteNumArray,y
	
	jmp playMonoWithA
	
	;lda soundMode
	;and #PORT_MASK
	;beq nextSoundModeCheck2
	;jmp playPort

	
	;***********	
	; ARP DOWN
	;***********	
playArpDown:	
	; Decrement arpOffset pointer...
	lda Frame
	and temp ; Arp speed
	bne skipArpAdvance2
	dec arpOffset
skipArpAdvance2:

	; Sort note buffer
	jsr doSort
	
	; Count the number of notes...
	ldx #0
	lda #255
noteCount2:
	cmp noteNumArray,x
	beq quitNoteCount2
	inx
	cpx bufferSize
	bmi noteCount2
quitNoteCount2:
	; X now contains the note count
	stx temp

	; Make sure arpOffset isn't at zero...
	lda arpOffset
	bpl noArpOffsetReset2
	ldx temp ; Reset arpOffset to end of available notes
	beq skipTempDecrement
	dex
skipTempDecrement:
	stx arpOffset
noArpOffsetReset2:

	; Play single arp note...
	ldy arpOffset
	lda noteNumArray,y
	
	jmp playMonoWithA
		

	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; 6-CHANNEL MONO SOUND DRIVER
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
play6Chan:
	lda noteNumArray+0
	sta playNoteArray+0
	lda noteNumArray+1
	sta playNoteArray+4
	lda noteNumArray+2
	sta playNoteArray+2
	
	lda noteNumArray+3
	sta playNoteArray+3
	lda noteNumArray+4
	sta playNoteArray+1
	lda noteNumArray+5
	sta playNoteArray+5

	jmp sixVoicePlayer
	
	
retuneNoteShiftTable:
	byte 0,0,0,0,0, 0,1,1,1,1, 1,1,1,1,1, 1,2,2,2,2, 2,2,2,2,2
	byte 2,3,3,3,3, 3,3,3,3,3, 3,4,4,4,4, 4,4,4,4,4, 4,5,5,5,5
	byte 5,5,5,5,5, 5,6,6,6,6, 6,6,6,6,6, 6,7,7,7,7, 7,7,7,7,7
	byte 7,8,8,8,8, 8,8,8,8,8, 8,9,9,9,9, 9,9,9,9,9, 9,$A,$A,$A
	byte 0,0,0, 0,0,0 ; FILLER 6
	byte 0,0,0,0,0, 0,1,1,1,1, 1,1,1,1,1, 1,2,2,2,2, 2,2,2,2,2 ; FILLER 25
	byte 0,0,0,0,0, 0,1,1,1,1, 1,1,1,1,1, 1,2,2,2,2, 2,2,2,2,2 ; FILLER 25
	
	;byte 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0 
	;byte 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0 
	;byte 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, -1,-1,-1,-1,-1 
	;byte -1,-1,-1,-1,-1, -1,-1,-1,-1,-1, -1,-1,-1,-1,-1, 0,0,0,0,0, 0,0,0,0,0 
	byte $F6,$F6,$F6,$F6,$F6, $F6,$F7,$F7,$F7,$F7, $F7,$F7,$F7,$F7,$F7, $F7,$F8,$F8,$F8,$F8, $F8,$F8,$F8,$F8,$F8
	byte $F8,$F9,$F9,$F9,$F9, $F9,$F9,$F9,$F9,$F9, $F9,$FA,$FA,$FA,$FA, $FA,$FA,$FA,$FA,$FA, $FA,$FB,$FB,$FB,$FB
	byte $FB,$FB,$FB,$FB,$FB, $FB,$FC,$FC,$FC,$FC, $FC,$FC,$FC,$FC,$FC, $FC,$FD,$FD,$FD,$FD, $FD,$FD,$FD,$FD,$FD
	byte $FD,$FE,$FE,$FE,$FE, $FE,$FE,$FE,$FE,$FE, $FE,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF, $FF,$00,$00,$00,$00
	
retuneTable:
	byte 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4
	byte 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1
	byte 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4
	byte 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1
	byte 0,0,0, 0,0,0 ; FILLER 6
	byte 0,0,0,0,0, 0,1,1,1,1, 1,1,1,1,1, 1,2,2,2,2, 2,2,2,2,2 ; FILLER 25
	byte 0,0,0,0,0, 0,1,1,1,1, 1,1,1,1,1, 1,2,2,2,2, 2,2,2,2,2 ; FILLER 25
	byte 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4
	byte 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1 
	byte 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4
	byte 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1
	;byte 5,-4,-3,-2,-1, 0,1,-4,-4,-4, -4,-4,-3,-2,-1, 0,1,2,3,4, 5,-4,-3,-2,-1

	;************************************************
	; 6-VOICE SOUND DRIVER
	;************************************************
sixVoicePlayer:

	; Calculate master tuning...
	lda systemTuning
	clc 
	adc midiTuning
	sta masterTuning
	tay

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW TUNING DATA
	IF DEBUG_DISPLAY=1
	tya
	sta temp
	ldy #20
	ldx #20
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	lda retuneTable,y ; Set tuning adjustment pointers based on final tuning...
	clc
	adc #4 ; Adjust current table format to tuning format (the table should be redone to fix this)
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW TUNING DATA
	IF DEBUG_DISPLAY=1
	sta temp
	ldy #21
	ldx #20
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	tay
	lda tuneArrPtrLL,y ; Set the tuning pointers...
	sta tunePtrL
	lda tuneArrPtrLH,y
	sta tunePtrL+1
	lda tuneArrPtrHL,y
	sta tunePtrH
	lda tuneArrPtrHH,y
	sta tunePtrH+1
	
	; Look up note shift from master tuning...
	ldy masterTuning
	lda retuneNoteShiftTable,y ; Offset the note based on the current tuning shift
	sta noteShift
	; - - - - - - - - - - - - -
	ldx #5
shiftNoteLoop:
	lda playNoteArray,x
	cmp #255
	beq skipShiftNote
	clc 
	adc noteShift
	sta playNoteArray,x
skipShiftNote:
	dex
	bpl shiftNoteLoop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW TUNING DATA
	IF DEBUG_DISPLAY=1
	sta temp
	ldy #22
	ldx #20
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; For each voice on SID #1...
	ldx #2
NsetRegsSidA:
	stx temp ; save current voice number
	ldy playNoteArray,x ; get next note to be played
	lda voiceOffset,x ; 
	tax
	cpy #255
	bne NsoundOnSidA
	lda #0
	beq NsoundOffSidA
NsoundOnSidA:

	; load note and deal
	; with tuning ------;
	lda NTSCmode			;
	beq palPlaySidA			;
ntscPlaySidA:				;
	clc					;
	lda NSoundLArr,y	;
	adc (tunePtrL),y	;
	sta pitchTmpL		;
	lda NSoundHArr,y	;
	adc (tunePtrH),y	;
	sta pitchTmpH		;	PAL/NTSC split
	jmp skipPalPlaySidA;
	;- - - - - - - - -;
palPlaySidA:			;
	clc					;
	lda PSoundLArr,y	;
	adc (tunePtrL),y	;
	sta pitchTmpL		;
	lda PSoundHArr,y	;
	adc (tunePtrH),y	;
	sta pitchTmpH		;
skipPalPlaySidA:		;;;;;

	; play SID #1
	clc
	lda pitchTmpL
	adc shiftL1		; add LFO/bend/tuning offset
	sta SID1+SV1FL,x ; set low freq
	lda pitchTmpH
	adc shiftH1		; add LFO/bend/tuning offset
	sta SID1+SV1FH,x ; set high freq

	lda #1
	; Set voice gates on or off
NsoundOffSidA:
	ora WaveType,x ; changed to Y
	sta SID1+SV1WAVE,x ; SID 1 ONLY  changed to Y
	;sta SID2+SV1WAVE,y ; changed to Y (why was this line disabled?)
	sta sidData+SV1WAVE,x ;BUG BUG BUG BUG BUG BUG  changed to Y
	ldx temp
	dex
	bmi quitPlayLoop
	jmp NsetRegsSidA
quitPlayLoop:

	;rts ; DEBUG!!!
	;~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
	;~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
	; For each voice on SID #2...
	ldx #2
NsetRegsSidB:
	stx temp
	;lda playNoteArray+3,x
	
	ldy playNoteArray+3,x ; get next note to be played
	lda voiceOffset,x
	
	tax
	cpy #255
	bne NsoundOnSidB
	lda #0
	beq NsoundOffSidB
NsoundOnSidB:

	; load note and deal
	; with tuning ------;
	lda NTSCmode			;
	beq palPlaySidB			;
ntscPlaySidB:				;
	clc					;
	lda NSoundLArr,y	;
	adc (tunePtrL),y	;
	sta pitchTmpL		;
	lda NSoundHArr,y	;
	adc (tunePtrH),y	;
	sta pitchTmpH		;	PAL/NTSC split
	jmp skipPalPlaySidB		;
palPlaySidB:				;
	clc					;
	lda PSoundLArr,y	;
	adc (tunePtrL),y	;
	sta pitchTmpL		;
	lda PSoundHArr,y	;
	adc (tunePtrH),y	;
	sta pitchTmpH		;
skipPalPlaySidB:		;;;;;

	; play SID #2
	clc
	lda pitchTmpL
	adc shiftL2		; add LFO/bend/tuning offset
	sta SID2+SV1FL,x ; set low freq
	lda pitchTmpH
	adc shiftH2		; add LFO/bend/tuning offset
	sta SID2+SV1FH,x ; set high freq

	lda #1
	; Set voice gates on or off
NsoundOffSidB:
	ora WaveType,x ; changed to Y
	;sta SID1+SV1WAVE,x ; changed to Y
	sta SID2+SV1WAVE,x ; SID2 ONLY changed to Y 
	sta sidData+SV1WAVE,x ; changed to Y
	ldx temp
	dex
	bpl NsetRegsSidB
	
	;~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
	;~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
	rts

	
		
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; PORTAMENTO SOUND SETUP
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
playPort
	
	ldx #2
portCopyLoop
	lda noteNumArray,x
	sta playNoteArray,x
	dex
	bpl portCopyLoop

	;lda noteNumArray+0 ; Duplicate notes on second SID for stereo
	;sta playNoteArray+3
	;lda noteNumArray+1
	;sta playNoteArray+4
	;lda noteNumArray+2
	;sta playNoteArray+5

	;jmp sixVoicePlayer

	jmp portPlayer

	

	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	; PORTAMENTO 3-VOICE SOUND DRIVER
	;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
portPlayer:
	; set up pointer to portamento speed array
	; (which is the tuning array)
	ldx #2
portLoop:
	ldy playNoteArray,x
	;ldy KeyA,x
	cpy #255
	bne noPlayNote
	jmp playNote
noPlayNote:
	lda Frame
	and #1
	beq noPlayNote2
	jmp playNote
noPlayNote2:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW DATA
	IF DEBUG_SHOW_PORTAMENTO=1
	lda pitchHA,x			;
	stx tempX
	sty tempY
	sta tempA
	;- - - - -
	;sta temp
	ldx #20
	ldy #6
	jsr displayHex
	;lda temp
	;ldy temp
	;- - - - -
	ldx tempX
	ldy tempY
	lda tempA
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW DATA
	IF DEBUG_SHOW_PORTAMENTO=1
	lda NSoundHArr,y		;
	stx tempX
	sty tempY
	sta tempA
	;- - - - -
	;sta temp
	ldx #20
	ldy #7
	jsr displayHex
	;lda temp
	;ldy temp
	;- - - - -
	ldx tempX
	ldy tempY
	lda tempA
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	jsr updatePortPosition
	jsr updatePortPosition


playNote:
	; deal with tuning
	clc
	lda pitchLA,x
	adc (tunePtrL),y
	sta pitchTmpL
	lda pitchHA,x
	adc (tunePtrH),y
	sta pitchTmpH

	tya	; Move the current key to A
	ldy voiceOffset,x
	cmp #255	; Check for note off
	bne soundOn
	lda #0
	beq soundOff
soundOn:

	; play SID #1
	clc
	lda pitchTmpL
	adc shiftL1		; add in LFO/bend/tuning offset
	sta SID1+SV1FL,y ; set low freq
	lda pitchTmpH
	adc shiftH1		; add in LFO/bend/tuning offset
	sta SID1+SV1FH,y ; set high freq

	; play SID #2
	clc
	lda pitchTmpL
	adc shiftL2		; add in LFO/bend/tuning offset
	sta SID2+SV1FL,y ; set low freq
	lda pitchTmpH
	adc shiftH2		; add in LFO/bend/tuning offset
	sta SID2+SV1FH,y ; set high freq

afterDStep

	lda #1
	; Set voice gates on or off
soundOff:
	;ldy voiceOffset,x ; added this line for copying, but implemented above...
	ora WaveType,y
	sta SID1+SV1WAVE,y
	sta SID2+SV1WAVE,y
	sta sidData+SV1WAVE,y ; changed to Y

	dex
	bmi quitPort
	jmp portLoop
quitPort:
skipPort:
	rts
	;--------------------------------------------------------------------
	;end of portamento play loop
	;--------------------------------------------------------------------


updatePortPosition:
	;check portamn direction;
	lda NTSCmode			;
	beq palPortH			;
ntscPortH:					;
	lda pitchHA,x			;
	cmp NSoundHArr,y		;
	beq portCheckL			;
	bmi portUp				; PAL/NTSC split
	bpl portDown			;
	;bpl portUp				; PAL/NTSC split
	;bmi portDown			;
palPortH:					;
	lda pitchHA,x			;
	cmp PSoundHArr,y		;
	beq portCheckL			;
	bmi portUp				;
	bpl portDown		;;;;;
	;bpl portUp				;
	;bmi portDown		;;;;;

portCheckL:
	
	;check portamn lowbyte--;
	lda NTSCmode				;
	beq palPortL			;
ntscPortL:					;
	lda pitchLA,x			;
	cmp NSoundLArr,y		;
	beq endPortUpdate
	;beq playNote ; note on	;
		;the stop so play	;
	bcs portDown			; PAL/NTSC split
	;bcs portUp			; PAL/NTSC split
	jmp skipPalPortL		;
palPortL:					;
	lda pitchLA,x			;
	cmp PSoundLArr,y		;
	beq endPortUpdate
	;beq playNote ; note on 	;
		;the stop so play	;
	bcs portDown			;
	;bcs portUp			 	;
skipPalPortL:			;;;;;


portUp:
	lda pitchLA,x
	clc
	adc (portPtrL),y
	sta pitchLA,x
	lda pitchHA,x
	adc (portPtrH),y
	sta pitchHA,x
	;inc 1025 ; DEBUG!!
	lda #0 ; indicate port direction
	jmp oscCheck
portDown:
	lda pitchLA,x
	sec
	sbc (portPtrL),y
	sta pitchLA,x
	lda pitchHA,x
	sbc (portPtrH),y
	sta pitchHA,x
	;inc 1024 ; DEBUG!!
	lda #1	; indicate port direction

	; check for pitch oscillation
	; (which means it's at the correct note)
	; it's oscillating if: the port direction
	; has changed and the note hasn't.
oscCheck:
	cmp portLastDir,x
	sta portLastDir,x ; save it for next time 'round
	beq skipOsc
	tya
	cmp portLastNote,x	
	sta portLastNote,x ; save it...
	bne skipOsc

	; it's oscilating at; 
	; the note, so lock ;
	; it onto the actual;
	; note				;
	lda NTSCmode		;
	beq palLock			;
ntscLock:				;
	lda NSoundLArr,y	;
	sta pitchLA,x		;	PAL/NTSC split
	lda NSoundHArr,y	;
	sta pitchHA,x		;
	jmp skipPalLock	;
palLock:					;
	lda PSoundLArr,y	;
	sta pitchLA,x		;
	lda PSoundHArr,y	;
	sta pitchHA,x		;
skipPalLock:	;;;;;

skipOsc:
endPortUpdate:
	rts
	
