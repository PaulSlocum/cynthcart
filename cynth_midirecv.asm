	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
	; Read MIDI
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
	;- . - . - . - . - . - . - . - . - . - . - . - . - . - . 
	IF ENABLE_MIDI_COMMANDS=1
processMIDI:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Debug - show main note buffer
	IF DEBUG_DISPLAY=1
	lda noteNumArray+0
	sta 1744+125
	lda noteNumArray+1
	sta 1744+126
	lda noteNumArray+2
	sta 1744+127
	lda noteNumArray+3
	sta 1744+128

	lda noteNumArray+4
	sta 1744+129
	lda noteNumArray+5
	sta 1744+130
	lda noteNumArray+6
	sta 1744+131
	lda noteNumArray+7
	sta 1744+132
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; get next MIDI byte
check:		
	IF ENABLE_MIDI_COMMANDS=1
	lda midiEnabled
	beq skipMidiRead
	jsr midiRead ; Midi byte will be in A and Y
skipMidiRead
	ENDIF
	bne continueReading
	jmp endMIDI
continueReading:
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	inc 1824+81
	sta temp
	ldx #34
	ldy debugOffset
	iny
	iny
	iny
	iny
	iny
	iny
	jsr displayHex
	ldy debugOffset
	iny
	tya
	and #$0F
	sta debugOffset
	adc #5
	tay
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; If bit 7 isn't set, then it's a running mode byte...
	bpl runningModeByte
	sta savedMidiStatus ; Save MIDI status for potential running mode bytes
	tay
	and #$F0
	cmp #$F0
	beq processSysex ;Skip saving status if it's sysex
	;sta savedMidiStatus ; Save MIDI status for potential running mode bytes
	
	;tya	
	
	; If bit 7 isn't set, then it's a running mode byte...
	;bpl runningModeByte

	
		;tay
	;and #$F0
	;cmp #$F0
	;beq processSysex ;Skip saving status if it's sysex
	;sta savedMidiStatus ; Save MIDI status for potential running mode bytes
;skipSavingStatus ; <--- SEE WHAT CALLS THIS??? (ANSWER: NOTHING)
	IF ENABLE_MIDI_COMMANDS=1
	jsr midiReadWait ; Midi byte will be in A and Y
	ENDIF
	sta firstDataByte ; Save second byte in MIDI sequence
	lda savedMidiStatus
	jsr processMidiMessage ; handle the rest of the message...
	jmp check ; End of loop - - - 
	
processSysex:
	tya ; Get systex byte
	cmp #$F0 ; ACTUAL SYSEX $F0
	bne checkF1
sysexReadingLoop:
	jsr midiReadWait ; READ THE REST OF THE SYSEX UNTIL $F7...
	cmp #$F7
	bne sysexReadingLoop
	jmp check
	; - - - - - -
checkF1: ; MIDI TIME CODE, HAS ONE EXTRA BYTE
	cmp #$F1
	bne checkF2
	jsr midiReadWait
	jmp check
	; - - - - - -
checkF2: ; SONG POSITION POINTER, 2 EXTRA BYTES
	cmp #$F2
	bne checkF3
	IF ENABLE_MIDI_COMMANDS=1
	jsr midiReadWait
	jsr midiReadWait
	ENDIF
	jmp check
	; - - - - - -
checkF3: ; SONG SELECT, 1 EXTRA BYTE
	cmp #$F3
	bne checkF8
	jsr midiReadWait
	jmp check
	; - - - - - - 
	; ALL OF THE REMAINING SYSTEM MESSAGES DON'T HAVE AN EXTRA BYTE
	jmp check
	
	
checkF8:
	cmp #$F8
	bne checkFA
	; NO EXTRA BYTES TO READ
	jmp check
	; - - - - - -
checkFA:
	cmp #$FA
	bne checkFC
	; NO EXTRA BYTES TO READ
	jmp check
	; - - - - - -
checkFC:
	cmp #$FC
	bne checkFF
	; NO EXTRA BYTES TO READ
	jmp check
	; - - - - - -
checkFF:
	cmp #$FF
	bne endSysex 
	;---- END SYSTEM/CLOCK ----
endSysex:
	jmp check ; END, RESTART LOOP AND SEE IF THERE ARE ANY MORE MIDI MESSAGES...
	
	
runningModeByte
	sta firstDataByte	; save the data byte...
	lda savedMidiStatus ;  and load the last saved midi status byte
	and #$F0 ; check for a system running byte (weird thing that happens with some midi adapters)
	cmp #$F0
	bne normalRunningMode
	;lda firstDataByte  ; We'll ignore this running mode byte, so the data byte now becomes the status byte...
	;jmp continueReading ; and jump back to the start of midi processing to process the data byte as the status byte...
	jmp check
	;-----------------------
	;sta savedMidiStatus ; =-=-=-=- probably can delete these 3 lines \/
	;jsr midiReadWait ; Now need to get a new "status byte"
	;jmp runningModeByte
	
normalRunningMode:
	lda savedMidiStatus ;  load the last saved midi status byte again
	jsr processMidiMessage
	jmp check
	
processMidiMessage
	tay ; MIDI STATUS BYTE IS IN A, STASH IN Y 
	
	; CHECK CHANNEL NUMBER IF NOT IN OMNI MODE...
	lda midiMode
	bmi endChannelCheck ; IF NOT IN OMNI MODE THEN SKIP...
	tya
	and #$0F
	cmp midiMode	; IF EQUAL TO CURRENT CHANNEL SETTING
	beq endChannelCheck ; THEN CONTINUE TO NOTE PROCESSING...
	
	;---------------------------------------------
	; WRONG CHANNEL, SO PROCESS DUMMY NOTE/MESSAGE HERE
	;---------------------------------------------
	tya 
	ora #%01000000
	beq twoParameters ; MESSAGE HAS TWO PARAMETERS
	tya 
	ora #%00100000
	beq oneParameter ; MESSAGE HAS ONE PARAMETER

twoParameters:
	jsr midiReadWait
oneParameter:
	;jsr midiReadWait ; THIS ONE IS DISABLED BECAUSE IT'S ALREADY READ ANOTHER BYTE
	rts
	;jmp check
	
	
endChannelCheck:
	; Status byte should be in A	
	; Ignoring channel for now
	;tay ; CHANGED THIS TO TYA BECAUSE MIDI STATUS IS NOW COMING IN Y
	tya
	
	and #$F0
	cmp #$80 ; Note off
	bne notNoteOff
	jmp noteOff
notNoteOff:
	cmp #$90 ; Note on
	bne notNoteOn
	jmp noteOn
notNoteOn:
	cmp #$E0 ; Pitch bend
	beq pitchBend
	cmp #$B0 ; Control change
	bne notControlChange
	jmp controlChange
notControlChange
	cmp #$D0 ; Channel pressure
	beq channelPressure
	cmp #$A0 ; Key pressure
	beq keyPressure
	cmp #$C0 ; Patch change
	beq patchChange
	;cmp #$F0 ; Sysex
	;beq sysex
	sta 2020
	lda #2
	sta 53280; Error! Unknown midi message type (change screen border color to red)
	jmp endMIDI

	
keyPressure
	IF DEBUG_DISPLAY=1
	inc 1824+86
	ENDIF
	lda firstDataByte
	IF ENABLE_MIDI_COMMANDS=1
	jsr midiReadWait
	ENDIF
	rts
	
	
	
;REL_SHORT equ $E0
;REL_MED	equ $E9
;REL_LONG equ $EE

;ATK_SHORT equ $00
;ATK_MED	equ $90
;ATK_LONG equ $E0
	
patchChange
	IF DEBUG_DISPLAY=1
	inc 1824+88
	ENDIF
	ldy firstDataByte ; Patch number
	bpl skipPatchDefault1 ; If patch number is > 127
	ldy #MAX_PATCH_NUMBER ; then set to max number (~30)
skipPatchDefault1:
	cpy #MAX_PATCH_NUMBER+1 
	bmi skipPatchDefault2 ; If patch is less than MAX_PATCH_NUM
	ldy #0 ; Saw Bass (because sending patch change zero doesn't work)
skipPatchDefault2:
	jsr setPatch
	rts

channelPressure
	IF DEBUG_DISPLAY=1
	inc 1824+89
	ENDIF
	lda firstDataByte
	rts
	
pitchBend
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	;sta temp
	ldx #25
	ldy #22
	jsr displayHex
	lda temp
	ldy temp
	inc 1824+90
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	lda firstDataByte ; Get bend value...
	lsr
	lsr
	adc firstDataByte ; Add it to a fraction of itself to scale the value up
	sec
	sbc #$50 ; Center on zero
	bmi negPitch ; If negative...
	cmp #70 ; Max value
	bmi setTuningValue
	lda #70 ; Over max, so set to max value (50)
	jmp setTuningValue
	
NEG_TUNE_TEST_VALUE equ 186
negPitch:
	cmp #NEG_TUNE_TEST_VALUE ; Mimimum allowable value...
	bpl setTuningValue
	lda #NEG_TUNE_TEST_VALUE
	
setTuningValue:
	sta midiTuning
	

;	lda firstDataByte

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	ldx #25
	ldy #23
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	rts
	
	
controlChange
	IF DEBUG_DISPLAY=1
	inc 1824+87
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda firstDataByte
	ldy #21
	ldx #17
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	IF ENABLE_MIDI_COMMANDS=1
	jsr midiReadWait ; Read controller value
	ENDIF
	tay
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	;lda firstDataByte
	ldy #22
	ldx #17
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda firstDataByte ; Get controller number
	IF OFFSET_CONTROLLERS=1
	sec
	sbc #1 ; DEBUG! OFFSET CONTROLLERS FOR TESTING!! DEBUG!!!
	ENDIF
	;and #$0F ; Repeat every 16 controllers
	and #%11101111 ; Repeat every 16 controllers
	bne notResonance 
	; Resonance
	tya
	and #$F0
	sta resonance
	jsr setResonance
	rts
notResonance:
	cmp #1
	bne notModWheel
	;Mod wheel
	tya
	asl
	tay
	sta filterSetValue
	;jsr ksetFilter
	rts
notModWheel:
	cmp #2
	bne notMode
	; Sound Mode
	tya
	lsr
	lsr
	lsr
	and #$0F
	tax
	lda modeList,x
	jsr ksetMode
	rts
notMode:
	cmp #3
	bne notFX
	; FX
	tya
	lsr
	lsr
	lsr
	lsr
	and #$07
	jsr ksetFX
	rts
notFX:
	cmp #4
	bne notAttack
	; Attack
	tya
	asl
	and #$F0
	jsr setAttack
	rts
notAttack:
	cmp #5
	bne notRelease
	; Release
	tya
	lsr
	lsr
	lsr
	and #$0F
	ora #$F0
	jsr setRelease
	rts
notRelease:
	cmp #6
	bne notPW
	; Pulse Width
	tya
	asl
	ora #%10000
	jsr setPulseWidth
	rts
notPW:
	cmp #7
	bne notVolume
	; Volume
	tya
	lsr
	lsr
	lsr
	jsr ksetVolume
	rts
notVolume:
	cmp #8
	bne notTremolo
	; Tremolo level
	tya
	lsr
	lsr
	lsr
	lsr
	and #$03
	jsr setLFODepth
	rts
notTremolo
	cmp #9
	bne notTremRate
	; Tremolo level
	tya
	lsr
	lsr
	lsr
	lsr
	and #$03
	jsr setLFORate
	rts
notTremRate:
	cmp #13
	bne notWaveform
	; Waveform (all voices)
	tya
	lsr
	lsr
	lsr
	and #$03
	tax
	lda waveForms,x
	sta WaveType2
	sta WaveType3
	sta WaveType
	rts
notWaveform:
	cmp #14
	bne notWaveform2
	; Waveform (voice 2 only)
	tya
	lsr
	lsr
	lsr
	and #$03
	tax
	lda waveForms,x
	sta WaveType2
	rts
notWaveform2:
	cmp #15
	bne notWaveform3
	; Waveform (voice 3 only)
	tya
	lsr
	lsr
	lsr
	and #$03
	tax
	lda waveForms,x
	sta WaveType3
	rts
notWaveform3:
	rts

waveForms
	byte $10,$20,$40,$80
	;-  -  -  -  -  -  -  -  
	
	;IF ENABLE_MIDI_COMMANDS=1
	ENDIF
	
	
			
	; note is in Y		
noteOn:

	sta temp
	IF ENABLE_MIDI_COMMANDS=1
	jsr midiReadWait ; Read velocity byte
	ENDIF
	sta tempVelocity
	bne almostNoteOn
	; Zero-velocity, so it's really a note-off...
	;inc 53280
	lda firstDataByte
	sec
	sbc #12 ; Down one octave
	jmp doNoteOff
almostNoteOn:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda noteOnCount
	and #1
	asl
	asl
	asl
	ora #$F4
	sta hexDispColor
	lda noteOnCount
	and #%1111
	asl
	tax
	;lda temp
	lda savedMidiStatus
	ldy #6
	jsr displayHex
	lda temp
	ldy temp
	inc 1824+83 ; DEBUG INDICATOR
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda firstDataByte ; Get MIDI byte with note data
	sec
	sbc #12 ; Down one octave
doNoteOn:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda noteOnCount
	and #%1111
	asl
	tax
	lda temp
	ldy #7
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Find empty note slot...	
	ldx bufferSize ;3
	tay
	;ldx #3 ; DEBUG!
	dex
noteOnLoop:
	lda noteNumArray,x
	cmp #255
	beq quitNoteOnLoop ; If slot is empty (==255)...
	dex
	bpl noteOnLoop
	ldx #0
quitNoteOnLoop:

	tya
	sta noteNumArray,x ; Store note in slot

	;jsr midiReadWait ; Read velocity byte
	lda tempVelocity
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda noteOnCount
	and #%1111
	asl
	tax
	lda temp
	ldy #8
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;/----------------------
	inc noteOnCount
	rts

noteOff:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda noteOffCount
	and #1
	;eor #1
	asl
	asl
	asl
	ora #$F4
	sta hexDispColor
	lda noteOffCount
	and #%1111
	asl
	tax
	lda temp
	ldy #10
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;jmp endMIDI

	sta temp
	IF ENABLE_MIDI_COMMANDS=1
	jsr midiReadWait ; Read velocity byte
	ENDIF
	sta tempVelocity
	lda temp
		
	lda firstDataByte
	sec
	sbc #12 ; Down one octave
	;jsr midiReadWait ; Note number

doNoteOff:
	; Find matching note number to turn note off...
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda noteOffCount
	and #%1111
	asl
	tax
	lda temp
	ldy #11
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ldx bufferSize ;3
	sta temp
	;ldx #3 ; DEBUG!
	dex
killNoteLoop:
	lda noteNumArray,x
	cmp temp ; Note match?
	beq foundNote ; Then go turn off note
	dex ; next slot
	bpl killNoteLoop ; loop through all slots
	;Not found, so ignore
	jmp endNoteOff
	
foundNote:
	lda #255
	sta noteNumArray,x ; Turn off note

endNoteOff
	lda tempVelocity
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DEBUG - SHOW MIDI DATA
	IF DEBUG_DISPLAY=1
	sta temp
	lda noteOffCount
	and #%1111
	asl
	tax
	lda temp
	ldy #12
	jsr displayHex
	lda temp
	ldy temp
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;/----------------------
	inc noteOffCount
	rts

	
endMIDI:
	;- . - . - . - . - . - . - . - . - . - . - . - . - . - . 
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
	; FILL EMPTY PLAYABLE NOTES WITH ANY 
	; NON-PLAYING NOTES IN THE BUFFER
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
	;jsr doSort
	
	ldx polyphony
	dex
	;ldx #2 ; DEBUG
noteScan:
	lda noteNumArray,x
	cmp #255 ; Is note off?
	beq searchCopyNote
contNoteScan:
	dex
	bpl noteScan ; Loop...
	jmp quitNoteScan ; Done, jump to end
	
searchCopyNote:
	;ldy bufferSize
	;dey
	;ldy #3
	ldy polyphony
copyNoteLoop:
	lda noteNumArray,y
	cmp #255
	bne replaceNote
	iny
	cpy #NOTE_BUF_SIZE
	beq contNoteScan
	bne copyNoteLoop
	
replaceNote:
	sta noteNumArray,x
	lda #255
	sta noteNumArray,y
	jmp contNoteScan

quitNoteScan:
	rts
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 

	
	