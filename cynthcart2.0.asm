; Commodore 64 Cynthcart
; by Paul Slocum
;------------------------
; TEXT EDITOR TAB=3
;------------------------

;     ~~~==========================================================================================~~~
; <<<<<<"MODE" AND "DEVICE_CONFIG" SHOULD BE DEFINED IN DASM CALL (dasm -DMODE=1 -DDEVICE_CONFIG=0) >>>>>>
;     ~~~==========================================================================================~~~

; IMAGE RUN MODES:
CART_OBSOLETE equ 0 ; run at $8000 off cartridge ROM (No longer supported because the ROM is bigger than 8K)
DISK equ 1 ; run at $8000, include initial load location word (PRG format)
RAM equ 2 ; run at $3000, needs to be copied or decompressed into $3000 (used for compresed version)
KERNEL_OBSOLETE equ 3 ; set up as replacement for 8k BASIC section of KERNEL (No longer supported because the ROM is bigger than 8K)
; -- - -- - -- - -- - -- - 
;;;MODE equ RAM   ; DISK, CART_OBSOLETE, RAM (for compression), or KERNEL_OBSOLETE
; -- - -- - -- - -- - -- - 


; MIDI AND SID2 CONFIGURATION:
DEFAULT equ 0 ; Midi autodetect, SID2 at $DF00
KERBEROS equ 1 ; Datel Midi, SID2 at $D420
EMU equ 2 ; Midi disabled, SID2 at $D420
SIDSYMPHONY equ 3 ; Midi disabled, SID2 at $DE00
; -- - -- - -- - -- - -- - 
;;;DEVICE_CONFIG equ DEFAULT 		
; -- - -- - -- - -- - -- - 


BETA_RELEASE equ 0

;=================================------------ - - - -  -   -
;
; TODO:
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
;
;=================================------------ - - - -  -   -
;
; - - - - - - - - - - - - - - 
; Change Log:
; - - - - - - - - - - - - - - 
; 2.0
; + 7 additional presets
; + added mono stack portamento modes
; + wrote new instruction manual
; + moved secondary SID to $DF00 to work with SIDcart II (note: must build with SID #2 at $D420 for Kerberos)
; + now supports and autodetects Passport, Datel, Sequential, and Kerberos MIDI adapters (note: autodetect is incompatible with VICE)
; + created new compression system to fit latest ROM onto 8K cartridge
; + presets now have independent waveform and sustain/release for each oscillator
; + added a button to cancel out of the SID editor
; + help screen now displays even when video is off
; + fixed SID editor waveform bug
; + other minor bugfixes
; + added build switch for alternate midi and SID configurations
; - - - - - - - - - - - - - - 
; 1.5.1
; + fixed clock and sysex bytes causing crashes/stuck notes (Midi 0xF0-0xFF)
; + fixed bad pitch bend startup value		Q
; + added non-omni modes for channel 1 and 5
; - - - - - - - - - - - - - - 
; 1.5.0 (major update for Kerberos)
; + added MIDI support for Kerberos cartridge/DATEL MIDI interface
; + arpeggiator
; + mono stack mode and 6-voice mode
; + new filter and pulse width effects modes
; + 12 additional presets
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
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - make port modes respond to pitch wheel
; - figure out why pulse LFO is so slow
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - fix patch saver issue where mode and FX are sometimes not saved
; - bug is bypassed, but figure out why showScreen messes up the filter setting
; - figure out why portamento is slower going down than up
; - make (IRQ) detector that works with VICE?
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - make envelope reset on every new note in mono modes
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - automatically relocate SID when using Kerberos
; - move video settings keys to a less used location?
; - add more FX modes
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - add some of Gert's mixed waveform sounds
; - add a button that resets all settings and turns video on
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - automatically turn off paddle when MIDI mod wheel data is received
; -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  
; - 'O' key specifically may be out of tune
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



RAMCOPY equ 1	; Copy program to RAM before running (this should always be enabled)

	IF DEVICE_CONFIG=KERBEROS
SID2 equ $D420
ENABLE_MIDI_COMMANDS equ 1
	ENDIF
	IF DEVICE_CONFIG=EMU
SID2 equ $D420
ENABLE_MIDI_COMMANDS equ 0
	ENDIF
	IF DEVICE_CONFIG=SIDSYMPHONY
SID2 equ $DE00
ENABLE_MIDI_COMMANDS equ 0
	ENDIF
	IF DEVICE_CONFIG=DEFAULT
SID2 equ $DF00
ENABLE_MIDI_COMMANDS equ 1
	ENDIF

USE_DUMMY_MIDI_LIBRARY equ 0
;USE_DUMMY_MIDI_LIBRARY equ 1

;ENABLE_MIDI_COMMANDS equ 1

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
	; switch to (upper?) lowercase mode
	lda #23
	sta $d018

	; clear screen and show info
;	ldx #0
;	stx $d020
;	stx $d021
;loop1:	; clear screen...
;	lda #32
;	sta $0400,x
;	sta $0400+250,x
;	sta $0400+500,x
;	sta $0400+750,x
;	lda #14
;	sta $d800,x
;	sta $d800+250,x
;	sta $d800+500,x
;	sta $d800+750,x
;	inx
;	cpx #250
;	bne loop1
;	ldx #0
;loop2:	; show info...
;	lda #1
;	sta $0400+10*40,x
;	inx
;	cpx #80
;	bne loop2

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
	jsr midiDetect ; AUTODETECT MIDI IF NOT KERBEROS BUILD
	ELSE
	lda #0
	ENDIF
	sta midiEnabled
	jsr midiInit
	;ENDIF

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
	;--------------------------------------------------------
	;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ 

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
	;inc 1024+80
	lda paddleY
skipPW:
	rts
	;END paddle ------------------------------

	



; All notes off
midiPanic:
	ldx #NOTE_BUF_SIZE
	lda #255
midiPanicLoop:
	sta noteNumArray,x
	dex
	bpl midiPanicLoop
	rts
	
	
	




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

	include "cynth_display.asm"
	include "cynth_modulation.asm"
	include "cynth_setshow.asm"
	include "cynth_sound.asm"
	include "cynth_keyboard.asm"
	include "cynth_midirecv.asm"
	include "cynth_sidedit.asm"
	
	include "cynth_subroutines.asm" ; Extra subroutines - currently just note sorting routine
	
	include "cynth_keycommands.asm" ; key matrix tables and key command tables
	include "cynth_data.asm" ; Screen text, data tables, note tuning tables, etc.
	
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
