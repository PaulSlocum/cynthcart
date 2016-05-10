; Commodore 64 Cynthcart
; by Paul Slocum
;------------------------
; TEXT EDITOR TAB=3
;------------------------

;     ~~~=====================================================~~~
; <<<<<< "MODE" SHOULD BE DEFINED IN DASM CALL (dasm -DMODE=1) >>>>>>
;     ~~~=====================================================~~~

; IMAGE RUN MODES:
CART_OBSOLETE equ 0 ; run at $8000 off cartridge ROM (No longer supported because the ROM is bigger than 8K)
DISK equ 1 ; run at $8000, include initial load location word (PRG format)
RAM equ 2 ; run at $3000, needs to be copied or decompressed into $3000 (used for compresed version)
KERNEL_OBSOLETE equ 3 ; set up as replacement for 8k BASIC section of KERNEL (No longer supported because the ROM is bigger than 8K)

;;;;MODE equ RAM   ; DISK, CART_OBSOLETE, RAM (for compression), or KERNEL_OBSOLETE

;=================================------------ - - - -  -   -
;
; TODO FOR 1.6.0:
; - finish designing new patches
; - make it work without midi adapter
; - maybe make it autodetect the passport and DATEL
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; MAYBE:
; - move video settings keys to a less used location?
; - add more FX modes
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - add some of Gert's mixed waveform sounds
; - add a button that resets all settings and turns video on
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - automatically turn off paddle when MIDI mod wheel data is received
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - 'O' key specifically may be out of tune
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
;
;=================================------------ - - - -  -   -
;
; - - - - - - - - - - - - - - 
; Change Log:
; - - - - - - - - - - - - - - 
; 1.6.0
; + added mono stack portamento modes
; + wrote new instruction manual
; + moved secondary SID to $DF00 to work with SIDcart II
; + created new compression setup to fit latest ROM onto 8K cartridge
; + added a button to cancel out of the SID editor
; + fixed minor bug with full screen display showing filter cutoff value
; + adjustments to help screen
; + fixed SID editor waveform bug
; + help screen now shows even when video is off
; + other minor bugfixes
; - - - - - - - - - - - - - - 
; 1.5.1
; + fixed clock and sysex bytes causing crashes/stuck notes (0xF0-0xFF)
; + fixed bad pitch bend startup value
; + added non-omni modes for channel 1 and 5
; - - - - - - - - - - - - - - 
; 1.5.0 (major update for Kerberos)
; + added MIDI support for Kerberos cartridge/DATEL MIDI interface
; + arpeggiator
; + mono stack mode and 6-voice mode
; + new filter and pulse width effects modes
; + additional presets
; + improved clarity of help screen text
; + moved SID location for MIDI version to $D420 since MIDI address overlaps with SID Symphony ($DE00)
; + refactored much of project source
; + new smarter note buffering system
; + reworked patch parameter display
; + only disable keyboard scanning during paddle reads instead of disabling all interrupts
; + optimized the tuning shift tables for space by overlapping tables
; + made LFO and all pitch modulations use proper tuning/scaling
; + fixed some errors in the tuning shift tables
; + added "RETURN FOR CONTROLS" message at bottom
;--------------------------
; - - - - - - - - - - - - - - 
; 1.2.4
; + designated paddle 1 and 2 in help screen
; - - - - - - - - - - - - - - 
; 1.2.3
; + disable key-commands when 3 piano keys are held
;		to avoid quirks with keyboard matrix
; + fixed LFO indicator w/ fullscreen video in helpMode
; + reinstated shift-lock holding notes
; + add another octave to NTSC note chart (had 1 less than PAL)
; + add another octave to tuning charts for 5ths in top octave
; + auto-paddle on
; + set up custom test for space bar
; + disable settings changes w/ space bar
; + corrected "sine" to "tringl" in patch names
; + restored startup patch to "saw bass"
; o add support for second paddle (pitch, LFO depth, LFO rate, pulse width)
;	+ add key command to switch controls and turn off
;	+ add display of paddle status
;	+ add code to run things from the second paddle
; - - - - - - - - - - - - - - 
; 1.2.2
; + keyboard driver rewrite
; + moved tuning from piano to ASDF... 
; + moved filter On/Off to ZXC
; + keys swap portamento and octave
; + move video mode to SHFT+FGH and require shift for VIC mode
; + add key to switch between PAL/NTSC (RUNSTOP+Z/X)
; + separate functions for "show everything" and "variable init" 
; + video mode with no text (shift+:/;)
; + SID register $20-$26 edits all 3 oscillators at once
; + write help display routine
; + add help screen
; + reverse octave keys
; + add help for SID edit mode
; + redo hex editor piano KB layout
; + save SID edits
; + added "COPYING TO RAM" text when RAM copy is on
; - - - - - - - - - - - - - - 
; 1.2.1
; + pitch fix for PAL
; + autodetection for PAL/NTSC
; - - - - - - - - - - - - - - 
; 1.2.0
; + filter adjustment for SID Symphony
; - - - - - - - - - - - - - - 
; 1.1 RELEASE
; + added SID HEX editor
; + changed tuning keys to avoid accidentally changing the tuning
; + added ability to turn the SID filter on and off
; - - - - - - - - - - - - - - 
; 1.0 RELEASE
; + first official release
;-----------------------------------------------------


;-----------------------------------------------------
; FUTURE TODO LIST:
; - - - - - - - - - - - - - - - 
; - consider adding per-patch filter on/off/disabled setting
; - midi trigger to turn off/on omni
; - - - - - - - - - - - - - - - 
; - make rising mod not drop
; - wire up pwModValue from functions
; - wire up pwSetValue from midi and paddle
; - create filter and PW setter that runs every frame
; - - - - - - - - - - - - - - - 
; - have mono-stack check to make sure notes aren't too low or too high
; - create 3-char copy routine and update "FILTR" to "FILTER"
; - create system that cycles which spots are favored for new empty or replacement notes
; - - - - - - - - - - - - - - - 
; - auto-detect secondary SID
; - automatic setup for Kerberos MIDI
; - - - - - - - - - - - - - - - 
; - fix note off bug with drum machine?
; - - - - - - - - - - - - - - - 
; -- show held modifier keys
; - link SID memory to a controller block
; - make fifths buttons preserve the portamento setting
; - - - - - - - - - - - - - - - 
; - new intervals other than 5ths
; - better mute/noise reduction
; - alternate set of keybindings for use without the keyboard overlay
; - - - - - - - - - - - - - - - 
; - more patches
; - paddle 2 auto-on
; - make smarter key->oscillator assignment to fix long release
;--------------------------
; - add echo long/med/short
; - more extreme variations in video mode
; - noise reduction
; - Envelope -> Filter Cutoff
; - filter type
; - ring modulation
; - sync
; - Whammy speed control
;--------------------------
; - filter Q
; - save patches to disk
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


;**********************************************************
;**********************************************************
; PROGRAM CONFIGURATION SWITCHES
;**********************************************************
;**********************************************************


RAMCOPY equ 1	; Copy program to RAM before running

SID2 equ $D420
;SID2 equ $DE00
;SID2 equ $DF00

USE_DUMMY_MIDI_LIBRARY equ 0
;USE_DUMMY_MIDI_LIBRARY equ 1

ENABLE_MIDI_COMMANDS equ 1

DEBUG_DISABLE_VIDEO_MODE equ 0
DEBUG_DISPLAY equ 0
OFFSET_CONTROLLERS equ 0
DEBUG_SHOW_MIDI equ 0
DEBUG_DISABLE_KEY_TIMER equ 0
DEBUG_SHOW_PORTAMENTO equ 0


;**********************************************************
;**********************************************************
;**********************************************************

	; *********************************************
	; START OF PROGRAM IN MEMORY
	; *********************************************

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
	; straight cart ROM
	IF MODE=CART_OBSOLETE
BASEADDR equ $8000
	org BASEADDR
	word Startup
	word Startup
	; 5 byte cartridge startup code
	byte $C3, $C2, $CD, $38, $30
	ENDIF

	;==================================================
	; load from RAM, requires wrapper to load into RAM (used for compressed version)
	IF MODE=RAM
BASEADDR equ $3000
;BASEADDR equ $4FFE ; DEBUG SETUP AS PRG
	org BASEADDR
	;byte $00,$50 ; DEBUG SETUP AS PRG
	ENDIF

	;==================================================
	; to replace BASIC ROM (NO LONGER SUPPORTED)
	IF MODE=KERNEL_OBSOLETE
BASEADDR equ $8000
	org BASEADDR
	word $E394   ; RESET
	word $E37B   ; Warm Start
	ENDIF

	;---------------------------------------
	; variables and constants here
	;---------------------------------------
	include cynth_vars.asm

	; *********************************************
	; Start of program
	; *********************************************
Startup:

	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	; switch to lowercase mode
	lda #23
	sta $d018

	; clear screen and show info
	ldx #0
	stx $d020
	stx $d021
loop1:	; clear screen...
	lda #32
	sta $0400,x
	sta $0400+250,x
	sta $0400+500,x
	sta $0400+750,x
	lda #14
	sta $d800,x
	sta $d800+250,x
	sta $d800+500,x
	sta $d800+750,x
	inx
	cpx #250
	bne loop1
	ldx #0
loop2:	; show info...
	;lda info,x
	lda #1
	sta $0400+10*40,x
	inx
	cpx #80
	bne loop2

	; init SID...
	lda #0
	ldx #0
initSid:	sta $d400,x
	inx
	cpx #25
	bne initSid
	lda #15
	sta $d418
	lda #1
	sta $d403

	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
;lock: jmp lock
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 

	IF ENABLE_MIDI_COMMANDS=1
	; init MIDI and enable all interrupts
	jsr midiDetect
	sta midiEnabled
	jsr midiInit
	ENDIF

	; Set default hex color
	lda #$E
	sta hexDispColor

	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 
	;=- =- =- =- =- =- =- =- =- =- =- =- =- =- 

skipTest:
	
	; Copy program into RAM if running from cartridge...
	IF MODE=CART_OBSOLETE
	ldx #0
RAMTextCopy:
	lda RAMText,x
	beq quitRAMTextCopy
	cmp #64
	bmi showSpaceRAM
	sbc #64
showSpaceRAM
	sta 1024,x
	inx
	jmp RAMTextCopy
RAMText:
	byte "COPYING TO RAM...",0
quitRAMTextCopy:
	;------------
	ldx #8*4
	lda #<copyStart
	sta copyPtrS
	lda #>copyStart
	sta copyPtrS+1
	lda #<ramStart
	sta copyPtrD
	lda #>ramStart
	sta copyPtrD+1
ramCopy1:
	ldy #0
ramCopy2:
	lda (copyPtrS),y
	sta (copyPtrD),y
	dey
	bne ramCopy2
	inc copyPtrS+1
	inc copyPtrD+1
	dex
	bne ramCopy1
	jmp ramStart
copyStart:
	rorg $3000 ; RAM destination
ramStart:	
	ENDIF

	IF MODE=CART_OBSOLETE
	; System Startup Stuff
	; (not needed if starting from disk)
	sei
	jsr $FF84 ; initialize I/O devices
	jsr $FF87 ; initalise memory pointers
	jsr $FF8A ; restore I/O vectors
	jsr $FF81 ; initalise screen and keyboard
	cli
	ENDIF

	IF MODE=KERNEL_OBSOLETE
	org $A483
	ENDIF

	LDA $D011	; Disable VIC-II (This has to be done because of
	AND #$EF    ; badlines
	STA $D011

	; Disable RESTORE key
	lda #193
	sta 792
	
	lda #0
	sta BACK_COLOR
	sta BORD_COLOR

	;*****************************
	; Detect PAL/NTSC
	;*****************************
;palntsc:
	sei ; disable interrupts
wait:
	lda $d012
	bne wait ; wait for rasterline 0 or 256
wait1:
	lda $d011 ; Is rasterbeam in the area
	bpl wait1 ; 0-255? if yes, wait
wait2:
	ldy #$00
synch1:
	lda $d012
	cmp #$37 ; top PAL rasterline
	bne synch1
	lda $d012 ; if next is 0, then PAL
synch2:
	cmp $d012
	beq synch2
	lda $d012
	cli ; enable interrupts

	sta NTSCmode
	


	
	;****************************************************
	; init screen and variables
	;****************************************************
	lda #0
	sta resonance
	sta noteOnCount
	sta noteOffCount
	jsr setFullScreenMode
	jsr variableInit
	jsr displayInit
	
	; Clear note buffer...
	ldx #8
	lda #255
clearBufferLoop
	dex
	sta noteNumArray,x
	;sta noteAgeArray,x
	;sta noteVelArray,x
	bne clearBufferLoop
	
	
	IF DEBUG_DISPLAY=1
	ldx #>debugOverlay ;low/MSB
	ldy #<debugOverlay ;high/LSB
	jsr displayPage
	ENDIF

	lda #0
	ldy #0
	jsr setPatch
	
	lda #0
	sta midiTuning
	
	lda #$FF
	jsr setMidiMode
	;sta midiMode
	
	lda midiEnabled
	sta 1024+39
	
	;===========================================
	;===========================================
	;===========================================
	; Main Loop
	;===========================================
	;===========================================
	;===========================================
Loop:
	; Increment frame counter
	inc Frame
	lda Frame
	and #%00111111
	bne SkipHFrame
	inc FrameH
SkipHFrame:


	jsr processLFO
	jsr processFX
	
	IF ENABLE_MIDI_COMMANDS=1
	jsr processMIDI
	ENDIF
	
	jsr readKeyboard
	jsr processBender
	jsr processSoundDriver
	jsr processPaddles
	jsr processVideoMode
	jsr updateFilterAndPW
	jmp Loop
	;-------- BOTTOM OF MAIN LOOP ---------------------------

updateFilterAndPW:
	lda filterModValue
	sec 
	sbc #127
	bmi negativeFilterMod
	; Positive
	adc filterSetValue
	bcc doSetFilter
	lda #255
	jmp doSetFilter

negativeFilterMod:	
	; Negative
	adc filterSetValue
	bcs doSetFilter
	lda #0
	jmp doSetFilter
	
	;and #$F0
doSetFilter:
	jsr setFilter
	; TODO: add PW setting
	rts
	
	
	;-------------------------------
	; LFO
	;-------------------------------
processLFO:
	; Set current LFO modulation
	; into (pitch) shift variables

	;---------------------------
	; get pitch bend from paddle2
	lda paddle2
	cmp #4
	bne noPadBend
	lda paddleY
	sta bender
noPadBend:

	;----------------------------
	; get depth from paddle2
	lda paddle2
	cmp #3
	bne noPadLFO
	lda paddleY
	lsr
	lsr
	lsr
	tay
	jmp skipFixedLFODepth
	;---------------------
	; calculate LFO depth
	; increases per octave
noPadLFO:
	ldx LFODepth
	ldy LFODepthArray,x
skipFixedLFODepth:
	lda keyOffset 		; current octave offset
	cmp #12
	bmi endDepth
	iny
	cmp #36
	bne endDepth
	tya
	asl
	tay
endDepth	; y now contains the depth value
	

	; figure out LFO position
	lda FrameH
	ldx LFORate
	beq LFOSkip	
	lda Frame
	dex
	dex
	dex
	beq LFOSkip
	lsr
	inx
	beq LFOSkip
	lsr
	lsr
LFOSkip:
	lsr

	and #$0F
	tax
	lda LFOArrH,x
	sta shiftH1
	bne negativeLFO

	clc
	lda LFOArrL,x
depthLoop
	adc LFOArrL,x
	dey
	bne depthLoop
	sta shiftL1
	jmp endLFO	

negativeLFO
	lda LFOArrL,x
depthLoopN
	adc LFOArrL,x
	dey
	bne depthLoopN
	sta temp
	lda #255
	sec
	sbc temp
	sta shiftL1
endLFO:

	; if depth=0 then cancel LFO
	lda paddle2
	cmp #3
	beq doLFO
	lda LFODepth
	bne doLFO
	lda #0
	sta shiftL1
	sta shiftH1
doLFO:

	lda helpMode ; do show LFO if helpMode on
	bne showLFO
	lda fullScreenMode
	bne dontErase ; don't show LFO if in full screen mode
	;--------
	; Show it
showLFO:
	lda LFOdisp,x
	tax
	lda #CYNTHCART_HIGHLIGHT_COLOR
	;adc #10
	
	;lda #160
	;sta 1063,x
	sta 55296-1,x

	;clear the previous one
	;lda #32
	lda #CYNTHCART_COLOR
	;sta 1064,x
	sta 55296+0,x
	cpx #1
	beq dontErase
	;sta 1062,x
	sta 55296-2,x
dontErase:

	; set up shift for second SID
	; chip, pitch a tad higher for
	; awesome chorus effect
	clc
	lda shiftL1
	adc #SID2OFFSET
	sta shiftL2
	lda shiftH1
	adc #0
	sta shiftH2

	; LFO->filter
;	lda shiftL1
;	clc
;	adc #128
;	sta SID1+SFILTH
;	sta SID2+SFILTH

skipLFO:
	rts

	; Echo stuff
;	inc EchoCur
;	inc EchoPtr
	; Save note in echo buffer
;	ldx EchoCur
;	sta EchoBuffer,x

	;---------------------
	; Read keyboard
	;jsr readKeyboard
	;---------------------
	
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
	cpy #MAX_PATCH_NUMBER 
	bmi skipPatchDefault2 ; If patch is less than MAX_PATCH_NUM
	ldy #MAX_PATCH_NUMBER
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

	
	
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
	; PROCESS BENDER
	;=- =- =- =- =- =- =- =- =- =- =- =- -= 
processBender:
	; Update space-bar pitch bend...
	lda benderAutoreset
	beq endBenderReset
	lda bender
	bne doBenderReset
	lda #0
	sta benderAutoreset
	jmp endBenderReset
doBenderReset
	dec bender
	dec bender
endBenderReset:
		
	
	; Insert bender into LFO offset...
	lda shiftL1
	sec
	sbc bender
	sta shiftL1
	lda shiftH1
	sbc #0
	sta shiftH1

	lda shiftL2
	sec
	sbc bender
	sta shiftL2
	lda shiftH2
	sbc #0
	sta shiftH2
	rts

	;DEBUG -- disable LFO/bender
;	lda #0
;	sta shiftL1
;	sta shiftL2
;	sta shiftH1
;	sta shiftH2

	;----------------------------
	
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
	lda NTSCmode				;
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

	
;setFilterFromA:
	sta filterSetValue
	rts
	
	; Old version of FilterFromA...
	sta SID1+SFILTH
	sta sidData+SFILTH
	clc
	adc #SID_SYMPHONY_FILTER_OFFSET
	bcc noPaddleRoll
	lda #255
noPaddleRoll:
	sta SID2+SFILTH
noPaddleControl
	rts
	

	;-------------------------------------
	; Reading paddles from Prog Ref Guide
	;-------------------------------------
processPaddles:
pdlrd0                ; entry point for one pair (condition x 1st)
	; -  -  -  -  -
	;sei				; disable interrupts
	lda #224		; disable keyboard scan		
	sta 56322		; disable keyboard scan
	; -  -  -  -  -
	lda Ciddra    ; get current value of ddr
	sta Buffer    ; save it away
	lda #$c0
	sta Ciddra    ; set port a for input
	lda #$80

pdlrd1
	sta PortA     ; address a pair of paddles
	ldy #$80      ; wait a while
pdlrd2
	nop
	dey
	bpl pdlrd2
 
	ldx SID1+25    ; get x value
	stx paddleX
	ldy SID1+26		; get y value
	sty paddleY

	lda PortA     ; Read paddle fire buttons
	ora #80       ; make it the same as other pair
	sta Button    ; bit 2 is pdl x, bit 3 is pdl y

	lda Buffer
	sta Ciddra    ; restore previous value of ddr
	; -  -  -  -  -
	;cli			; enable interrupts
	lda #255		; enable keyboard scan		
	sta 56322		; enable keyboard scan
	; -  -  -  -  -

	;-------------------------------------
	; Auto paddle on - turn on paddle control if it's wiggled...
	lda paddle
	bne noPaddleAutoOn ; skip this if paddles are on
	cpx #160 
	bcc noPaddleTop
	lda #1
	sta paddleTop
noPaddleTop:
	cpx #96
	bcs noPaddleBottom
	lda #1
	sta paddleBottom
noPaddleBottom:
	;-----------
	lda paddleTop 			; if both paddle regions have
	beq noPaddleAutoOn	; been hit, then...
	lda paddleBottom
	beq noPaddleAutoOn
	lda #1					; turn paddle on
	jsr setPaddles
noPaddleAutoOn:

	;-------------------------------------
	; check to see if paddle control is on
	lda paddle
	beq processPaddle2

	; paddle1 -> filter
	txa
	sta filterSetValue
	;jsr setFilterFromA
	
	
	;sta SID1+SFILTH
	;sta sidData+SFILTH
	;clc
	;adc #SID_SYMPHONY_FILTER_OFFSET
	;bcc noPaddleRoll
	;lda #255
;noPaddleRoll:
	;sta SID2+SFILTH
;noPaddleControl

	;-------------------------------------
	; paddle 2

;	paddle 2 -> Pulse Width
processPaddle2:
	lda paddle2
	cmp #1
	bne skipPW
	lda paddleY
	cmp #245	; check for top limit (= no sound)
	bcc notPTop	
	lda #245 ; limit to maximum
	sta paddleY
notPTop:
	lda paddleY
	jsr setPulseWidth
	;-------------
	lda paddleY
	asl
	asl
	asl
	asl
	ora #$0F
	sta SID1+SV1PWL
	sta SID1+SV2PWL
	sta SID1+SV3PWL
	sta SID2+SV1PWL
	sta SID2+SV2PWL
	sta SID2+SV3PWL
	sta sidData+SV1PWL
	sta sidData+SV2PWL
	sta sidData+SV3PWL
skipPW:
	rts
	;END paddle ------------------------------

	
	;------------------
	; Set pulse width
	;------------------
setPulseWidth:
	lsr
	lsr
	lsr
	lsr
	sta SID1+SV1PWH
	sta SID1+SV2PWH
	sta SID1+SV3PWH
	sta SID2+SV1PWH
	sta SID2+SV2PWH
	sta SID2+SV3PWH
	sta sidData+SV1PWH
	sta sidData+SV2PWH
	sta sidData+SV3PWH
	rts
	
	
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


	;------------------------------------------
	; code to draw colored character patterns
	;------------------------------------------
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


; All notes off
midiPanic:
	ldx #NOTE_BUF_SIZE
	lda #255
midiPanicLoop:
	sta noteNumArray,x
	dex
	bpl midiPanicLoop
	rts
	
	
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
	jmp displayPage ; <--- Draw full help page
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
	; Set Sync
	;--------------------------------
	; This function does not appear to be used anywhere
	;--------------------------------
setSync
	sta videoMode
	tay
	asl
	asl
	beq syncOff
	sta temp
	ora WaveType
	sta WaveType
	lda temp
	ora WaveType2
	sta WaveType2
	lda temp
	ora WaveType3
	sta WaveType3
	jmp contSync
syncOff
	eor #255
	sta temp
	and WaveType
	sta WaveType
	lda temp
	and WaveType2
	sta WaveType2
	lda temp
	and WaveType3
	sta WaveType3
contSync:
	tya
	asl
	asl
	tax	
	ldy #SYNCTEXT
	jmp updateText
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
	sta release
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
	sta release
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
	sta 2012
	sta 2017
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
	sta WaveType2
	lda patchWave2,y
	sta WaveType3
	lda patchWave3,y
	sta WaveType

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

	sta hexKeyMode

	jsr beep
	jsr beep
	jsr beep

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

	rts

	
	
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

beep:
;	lda #$10
;	sta SID1+SV1FH

	ldx #3
beepLoop:
	lda volModeRAM
	ora #$0F
	sta SID1+SVOLMODE
	sta SID2+SVOLMODE
	sta sidData+SVOLMODE
	jsr clickDelay
	lda volModeRAM
	and #$F0
	sta SID1+SVOLMODE
	sta SID2+SVOLMODE
	sta sidData+SVOLMODE
	dex
	bne beepLoop
	rts
	

	; ------------------------------------
	; delay for click -- uses Y
clickDelay:
	;ldy #$40
	ldy #$10
	sty temp
mainDelayLoop:
	ldy #0
innerDelayLoop:
	dey
	bne innerDelayLoop
	dec temp
	bne mainDelayLoop
	rts	
	

	;------------------------------------------
	; update text
	;------------------------------------------
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

	; ***************************
	; Variable Setup
	; ***************************
variableInit:
	lda #0
	sta paddle2
	sta filterDisable
	sta filterStatus
	sta keyTimer
	sta bender
	sta helpMode
	sta patPtr
	sta Frame
	sta FrameH
	sta EchoCur
	sta customPatchSaved
	sta paddleTop
	sta paddleBottom

	lda #2
	sta lastPad2 ; default paddle2 setting is LFO Depth

	lda #4 		; set normal tuning
	sta tuneSetting 

	lda #0
	jsr setLFODepth ;********************************
	lda #0
	jsr setLFORate ;********************************

	; set up tuning array pointers
	lda #<tuningL4
	sta tunePtrL
	lda #>tuningL4
	sta tunePtrL+1

	lda #<tuningH4
	sta tunePtrH
	lda #>tuningH4
	sta tunePtrH+1

	lda #2
	sta VICMode
	lda #0
	sta soundMode
	;lda #40
	;sta portSpd

	; Video Mode
	lda #3
	ldy #2
	jsr setVideoMode ;********************************

	; Default full volume
	lda #$0F
	sta volume

	; Echo?
	lda #$70
	sta EchoPtr

	ldy #0
	jsr setPatch ;set bass sound

	; Set up starting portamento values
	ldx #12
	lda NSoundLArr,x
	sta pitchLA
	sta pitchLB
	sta pitchLC
	;sta lastKeyA ;;;;;;;;;;;;;;;;;;;;;;;;;;REWRITE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;sta lastKeyB
	;sta lastKeyC
	lda NSoundHArr,x
	sta pitchHA
	sta pitchHB
	sta pitchHC
	;----------
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
	rts

	; Extra subroutines
	include "cynth_subroutines.asm"

	; Screen text, data tables, note tuning tables, etc.
	include "cynth_data.asm"
	
	; Pitch offset data for alternate tuning modes
	include "cynth_tuning.asm"

	; Frank's MIDI interface code
	IF USE_DUMMY_MIDI_LIBRARY=1
		include "cynth_midi_dummy.asm"
	ELSE
		include "cynth_midi.asm"
	ENDIF

	
	IF MODE=KERNEL_OBSOLETE
	org $bfff
	byte 0
	ENDIF
