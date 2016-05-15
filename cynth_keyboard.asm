;------------------------------------------
; Read the keyboard
;------------------------------------------
readKeyboard:
	; Keyboard read setup
	lda #127
	sta 56333

	;------------------------------------------
	; determine which keyset to use 
	; (raw/shift/commodorekey/runstop)
	;------------------------------------------

	; default is raw key functions (no modified keys)
	lda #<rawKeyFunctions		;-
	sta keyPtrL						;
	lda #>rawKeyFunctions		;
	sta keyPtrH						;-

	; Check for Shift/C=
	lda #~64 ; (Right Shift)
	sta 56320
	lda 56321
	and #16
	bne notAltKeys					;-
	lda #<shiftKeyFunctions		;
	sta keyPtrL						;
	lda #>shiftKeyFunctions		;-
	sta keyPtrH
notAltKeys:
	lda #~2 ; (Left Shift)
	sta 56320
	lda 56321
	and #128
	bne notAltKeys2				;-
	lda #<shiftKeyFunctions		;
	sta keyPtrL						;
	lda #>shiftKeyFunctions		;-
	sta keyPtrH
	jmp doKeyCheck
notAltKeys2:
	lda #~128 ; (C= key)
	sta 56320
	lda 56321
	and #32
	bne notAltKeys3
	lda #<commKeyFunctions		;-
	sta keyPtrL						;
	lda #>commKeyFunctions		;
	sta keyPtrH						;-
notAltKeys3:
	lda #~128 ; (Run Stop)
	sta 56320
	lda 56321
	and #128
	bne notAltKeys4
	lda #<runstopKeyFunctions	;-
	sta keyPtrL						;
	lda #>runstopKeyFunctions	;
	sta keyPtrH						;-
notAltKeys4:
	lda #~128 ; (CTRL key)
	sta 56320
	lda 56321
	and #4 ; CTRL
	;and #2 ; BACK ARROW
	bne notAltKeys5
	lda #<CTRLKeyFunctions		;-
	sta keyPtrL						;
	lda #>CTRLKeyFunctions		;
	sta keyPtrH						;-
notAltKeys5:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if DEBUG_DISABLE_KEY_TIMER=1
	lda #0
	sta keyTimer  ; DEBUG!  Disable key timer
	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; handle keytimer
	; (to avoid accidental keypresses on shifted keys)
	lda keyTimer
	beq readKeys
	dec keyTimer
	jmp startCheck
readKeys:

	;********************************
	; Check for Notes Being Pressed
	;********************************
startCheck:
	lda #0
	sta keyCount

	; Save last notes and clear note buffer
	ldx bufferSize
	;dex
	inx
	inx
clearKeys:
	lda kbBuffer,x
	IF DEBUG_DISPLAY=1
	sta 1024+40*20+5,x ; DEBUG SHOW DATA
	ENDIF
	sta lastKbBuffer,x
	lda #255
	sta kbBuffer,x
	dex
	bpl clearKeys
	
	;lda #255
	;sta KeyA
	;sta KeyB
	;sta KeyC

	ldx bufferSize
	;dex
	inx
	inx
	ldy #0
	; check for note keys being pressed
checkLoop:
	lda col,y
	beq quitCheck
	sta 56320
	lda 56321
	and row,y
	bne notPressed
	tya
	clc
	adc keyOffset
	;sta KeyA,x
	sta kbBuffer,x
	dex
	inc keyCount
	bmi quitCheck
notPressed:
	iny
	bne checkLoop

quitCheck:
	;-- -- -- -- -- -- -- -- -- -- -- -- -- 
	; Generate note on/offs from keyboard data
	;-- -- -- -- -- -- -- -- -- -- -- -- -- 
	; FIND NOTE ONS...
	ldx bufferSize
	;dex
	inx
	inx
noteOnCheck:
	lda kbBuffer,x ; Get next note from current kb buffer
	ldy bufferSize ; Set up loop to scan for note in lastKbBuffer...
	;dey
	iny
	iny
innerNoteOnCheck:
	cmp lastKbBuffer,y
	beq checkNextNote
	dey
	bpl innerNoteOnCheck
	;Found new note-on!
	;inc 53280
	sta noteTempA
	stx noteTempB
	jsr doNoteOn
	lda noteTempA
	ldx noteTempB
	; TODO: call note on function	
checkNextNote:
	dex
	bpl noteOnCheck
	
	; FIND NOTE OFF...
	ldx bufferSize
	;dex
	inx
	inx
noteOnCheck2:
	lda lastKbBuffer,x ; Get next note from last kb buffer
	ldy bufferSize ; Set up loop to scan for note in lastKbBuffer...
	;dey
	iny
	iny
innerNoteOnCheck2:
	cmp kbBuffer,y
	beq checkNextNote2
	dey
	bpl innerNoteOnCheck2
	;Found new note-on!
	;inc 53280
	sta noteTempA
	stx noteTempB
	jsr doNoteOff
	lda noteTempA
	ldx noteTempB
	; TODO: call note on function	
checkNextNote2:
	dex
	bpl noteOnCheck2
	;-- -- -- -- -- -- -- -- -- -- -- -- -- 
	; End of note on/off generation
	;-- -- -- -- -- -- -- -- -- -- -- -- -- 
	
	; Skip key command check if 3 or more piano keys
	; are held to avoid quirks with C64 keyboard
	; matrix hardware.
	ldx keyCount
	beq skipMinimalKeyboard
	; default is raw key functions (no modified keys)
	lda #<minimalKeyFunctions		;-
	sta keyPtrL						;
	lda #>minimalKeyFunctions		;
	sta keyPtrH						;-
	; also disable keytimer...
	lda #0
	sta keyTimer
skipMinimalKeyboard:

	; Check key timer...
	lda keyTimer
	beq contReadKeys
	rts
contReadKeys:
	stx lastOsc

	; Check for space bar (pitch bender)...
	lda #~$80
	sta 56320
	lda 56321
	and #$10
	bne noSpace
	jsr bendBender
	jmp skipKeyCheck
noSpace:

	
doKeyCheck:
	;********************************
	; Generic command key check
	;********************************
	
	ldx #30*2	;28+1 keys to check, set and read value (2 bytes) for each key
keyChkLoop:
	lda commandKeys,x
	sta 56320
	lda 56321
	and commandKeys+1,x
	bne keyNotDown

	; key down!
	;-----------
	txa ;multiply x by 2
	asl ;  to get the offset 
	tay ;  into the key functions array
	
	; get address of function to call
	lda (keyPtrL),y
	sta temp16L
	iny
	lda (keyPtrL),y
	sta temp16H
	beq keyNotDown	;if the MSB address is zero, then there is
					;  no function assigned to this key so quit

	; put return address onto stack to simulate JSR with a JMP()
	lda #>returnAddress
	pha 
	lda #<returnAddress
	pha 

	; save the value of X
	stx saveX

	iny
	lda (keyPtrL),y	;get value to pass to function for X
	sta keyTemp
	iny
	lda (keyPtrL),y	;get value to pass to function for A
	tay
	lda keyTemp

	; indirect jump to function, which acts as a JSR since 
	;   we pushed the return address onto the stack
	jmp (temp16L)
	
	nop
returnAddress:
	nop

	ldx saveX ; restore X

	; only set the keytimer when a raw key is used
	lda keyPtrL
	cmp #<rawKeyFunctions
	beq keyNotDown

	lda #KEYTIME
	sta keyTimer	
	;-----------
	jmp skipKeyCheck	; quit keycheck after a key is found

keyNotDown:
	dex
	dex
	bpl keyChkLoop

skipKeyCheck:

	; done
	rts
