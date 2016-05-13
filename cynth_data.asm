
;------------------------------------------
; Keyboard Reading Data
;------------------------------------------

hexColPiano:   
	byte $BF,$7F,$FD,$FB,  $FB,$F7,$EF,$EF,  $DF,$BF, $F7,$F7,   $EF,$EF,$DF,$DF,    $7F,0 ; PIANO KEYBOARD
hexCol:   
	byte $EF,$7F,$7F,$FD,  $FD,$FB,$FB,$F7,  $F7,$EF,~$02,~$08, ~$04,~$04,$FD,~$04,  $7F,0
		; 0   1   2   3     4   5   6   7     8   9    A   B       C   D   E   F    SPACEBAR (cancel)
hexRowPiano:
	byte $08,$08,$01,$01,  $08,$01,$01,$08,  $08,$01,$02,$40,  $02,$40,$02,$40,    $02,0 ; PIANO KEYBOARD ($10 = space) ($02 = backarrow)
hexRow:
	byte $08,$01,$08,$01,  $08,$01,$08,$01,  $08,$01,$04,$10,  $10,$04,$40,$20,    $02,0
		; 0   1   2   3     4   5   6   7     8   9   A   B     C   D   E   F     SPACEBAR (cancel)

	;-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	; Column activation data
col: ;         x         x                x           x    A    x    B 
	byte $7F, $7F, $FD, $FD,   $FD, $FB, $FB, $FB,   $FB, $F7, $F7, $F7
	byte $EF, $EF, $EF, $EF,   $DF, $DF, $DF, $BF,   $BF, $BF, $BF, $FE, 0
	 ;    C    x    D    x      E    F    x           x         x    

	; Row testing data
row: ;         x         x                x           x    A    x    B 
	byte $40, $08, $02, $01,   $40, $02, $01, $40,   $08, $02, $01, $40
	byte $02, $01, $40, $08,   $02, $40, $08, $02,   $01, $40, $08, $01, 0
	 ;    C    x    D    x      E    F    x           x         x    
	;-----------------------------------------------
	; Note  c  #  d  #    e  f  #  g    #  a  #  b 
	;  Key  q  2  w  3    e  r  5  t    6  y  7  u 
	;  Hex  1  2  3  4    5  6  7  8    9  10 11 12
	;-----------------------------------------------
	; Note  c  #  d  #    e  f  #  g    #  a  #  b
	;  Key  i  9  o  0    p  @  -  *    &  |  CL RE
	;  Hex  13 14 15 16   17 18 19 20   21 22 23 24
	;-----------------------------------------------

commandKeys: ; row, column
	byte ~$80, $10		;spc 28
	byte ~$02, $04		;A   0	
	byte ~$02, $20		;S   1
	byte ~$04, $04		;D   2
	byte ~$04, $20		;F   3
	byte ~$08, $04		;G   4
	byte ~$08, $20		;H   5
	byte ~$10, $04		;J   6
	byte ~$10, $20		;K   7
	byte ~$20, $04		;L   8
	byte ~$20, $20		;:   9
	byte ~$40, $04		;;   10
	byte ~$40, $20		;=   11
	byte ~$02, $10		;Z   12
	byte ~$04, $80		;X   13
	byte ~$04, $10		;C   14
	byte ~$08, $80		;V   15
	byte ~$08, $10		;B   16
	byte ~$10, $80		;N   17
	byte ~$10, $10		;M   18
	byte ~$20, $80		;,   19
	byte ~$20, $10		;.   20
	byte ~$40, $80		;/   21
	byte ~$01, $80		;u/d 22
	byte ~$01, $04		;l/r 23
	byte ~$01, $10		;F1  24
	byte ~$01, $20		;F3  25
	byte ~$01, $40		;F5  26
	byte ~$01, $08		;F7  27
	byte ~$01, $02		;ret 29
	byte ~$80, $02		;Larr 30
	;byte ~$80, $04		;Larr 30

rawKeyFunctions:
	;    functionPointer, inputData:Y,A
	word bendBender, $0000		;space
	word setPatch, $0A00	;A
	word setPatch, $0B00 	;S
	word setPatch, $0C00	;D
	word setPatch, $0D00	;F
	word setPatch, $0E00	;G
	word setPatch, $0F00	;H
	word setPatch, $1000	;J
	word setPatch, $1100	;K
	word setPatch, $1200	;L
	word setPatch, $1300	;:
	word setPatch, $1500	;;
	word setPatch, $1400	;=
	word setPatch, $0000	;Z
	word setPatch, $0100		;X
	word setPatch, $0200		;C
	word setPatch, $0300		;V
	word setPatch, $0400		;B
	word setPatch, $0500		;N
	word setPatch, $0600		;M
    word setPatch, $0700		;,
	word setPatch, $0800		;.
	word setPatch, $0900		;/
	word ksetMode, $0000			;up/down
	word ksetMode, $0001			;left/right
	word setOctave, 3			;F1
	word setOctave, 2			;F3
	word setOctave, 1			;F5
	word setOctave, 0			;F7
	word khelp,0   				;return
	word kloadPatch,0			;Larrow

minimalKeyFunctions:
	;    functionPointer, inputData:Y,A
	word bendBender, $0000		;space
	word 0, $0A00	;A
	word 0, $0B00 	;S
	word 0, $0C00	;D
	word 0, $0D00	;F
	word 0, $0E00	;G
	word 0, $0F00	;H
	word 0, $1000	;J
	word 0, $1100	;K
	word 0, $1200	;L
	word 0, $1300	;:
	word 0, $1400	;;
	word 0, $1500	;=
	word 0, $0000	;Z
	word 0, $0100		;X
	word 0, $0200		;C
	word 0, $0300		;V
	word 0, $0400		;B
	word 0, $0500		;N
	word 0, $0600		;M
    word 0, $0700		;,
	word 0, $0800		;.
	word 0, $0900		;/
	word 0, $0000			;up/down
	word 0, $0001			;left/right
	word setOctave, 3			;F1
	word setOctave, 2			;F3
	word setOctave, 1			;F5
	word setOctave, 0			;F7
	word 0,0   				;return
	word 0,0			;Larrow
	
CTRLKeyFunctions:
	;    functionPointer, inputData:Y,A
	word 0, $0000			;space
	word setRelease, REL_SHORT	;A
	word setRelease, REL_MED	;S
	word setRelease, REL_LONG	;D
	word ksetMode, MODE_NORMAL	;F
	word ksetMode, MODE_5THS	;G
	word ksetMode, MODE_5PORT	;H
	word ksetMode, MODE_MONO1			;J
	word ksetMode, MODE_ARP1 			;K
	word ksetMode, MODE_ARP2 			;L
	word ksetMode, MODE_ARP3 			;:
	word ksetMode, MODE_ARP4 			;;
	word ksetMode, MODE_ARP5			;=
	word ksetFX,   $0000	;Z
	word ksetFX,   $0001	;X
	word ksetFX, 	$0002	;C
	word ksetFX, 	$0003	;V
	word ksetFX, 	$0004	;B
	word ksetFX, 	$0005	;N
	word ksetFX, 	$0006	;M
	word ksetFX, 	$0007	;,		
	word ksetFX, 	$0008	;.
	;word ksetFX, 	$0009	;/
	word ksetMode, MODE_MONO2			;/
	word ksetMode, MODE_MONOPORT1		;up/down
	word ksetMode, MODE_MONOPORT2		;left/right
	word ksetVolume, VOLHIGH			;F1
	word ksetVolume, VOLMED			;F3
	word ksetVolume, VOLLOW			;F5
	word ksetVolume, VOLOFF			;F7
	word ksetMode, MODE_6CHAN   	;return
	word 0,0					;Larrow
	
shiftKeyFunctions:
	;    functionPointer, inputData:Y,A
	word 0, $0000				;space
	word setAttack,ATK_SHORT;A
	word setAttack,ATK_MED 	;S
	word setAttack,ATK_LONG	;D
	word setVideoMode,$0108	;F
	word setVideoMode,$0203	;G
	word setVideoMode,$0315	;H
	word setVIC, 2	 			;J
	word setVIC, 1				;K
	word setVIC, 0				;L
	word setFullScreenMode, $0001	;:
	word setFullScreenMode, $0000	;;
	word 0, $0000				;=
	word setLFORate,0			;Z
	word setLFORate,1			;X
	word setLFORate,2			;C
	word setLFORate,3			;V
	word setLFODepth,0		;B
	word setLFODepth,1		;N
	word setLFODepth,2		;M
   word setLFODepth,3		;,
	word 0, $0000				;.
	word 0, $0000				;/
	word ksetPaddles, 0		;up/down
	word ksetPaddles, 1		;left/right
	word ksetMode, $0012		;F1 (Portamento slow)
	word ksetMode, $0011		;F3 (Portamento med)
	word ksetMode, $0010		;F5 (Portamento fast)
	word ksetMode, $0000		;F7 (Normal polyphonic)
	word kclearModulation,0    		;return
	word 0,0						;Larrow

commKeyFunctions:
	;    functionPointer, inputData:Y,A
	word 0, $0000			;space
	word ksetFilter, $0000	;A
	word ksetFilter, $0020  ;S
	word ksetFilter, $0040	;D
	word ksetFilter, $0060	;F
	word ksetFilter, $0080	;G
	word ksetFilter, $00A0	;H
	word ksetFilter, $00C0	;J
	word ksetFilter, $00E0	;K
	word 0, $0000			;L
	word 0, $0000		 	;:
	word 0, $0000		 	;;
	word 0, $0000			;=
	word kfiltOnOff,$0000	;Z
	word kfiltOnOff,$0100	;X
	word kfiltOnOff,$0200	;C
	word ksetPad2, $0000	;V
	word ksetPad2, $0001	;B
	word ksetPad2, $0003	;N
	word ksetPad2, $0004	;M
	word setMidiMode, $FFFF	;,  OMNI
	word setMidiMode, $0000	;.  CHANNEL 1
	word setMidiMode, $0404	;/  CHANNEL 5
	word 0, $0000			;up/down
	word 0, $0000			;left/right
	word 0, $0000			;F1
	word 0, $0000			;F3
	word 0, $0000			;F5
	word 0, $0000			;F7
	word 0,0   				;return
	word 0,0					;Larrow



runstopKeyFunctions:
	;    functionPointer, inputData:Y,A
	word 0, $0000			;space
	word ksetTune,$0000	;A
	word ksetTune,$0100  ;S
	word ksetTune,$0200	;D
	word ksetTune,$0300	;F
	word ksetTune,$0400	;G
	word ksetTune,$0500	;H
	word ksetTune,$0600	;J
	word ksetTune,$0700	;K
	word ksetTune,$0800	;L
	word ksetTune,$0900 	;:
	word 0, $0000		 	;;
	;word ksetTune,$0A00 	;;
	word 0, $0000			;=
	word setPatch, $1600	;Z  
	word setPatch, $1700	;X
	word setPatch, $1800	;C
	word setPatch, $1900	;V
	word setPatch, $1A00	;B
	word setPatch, $1B00	;N
	word setPatch, $1C00	;M
    word 0, $0000			;,
	word ksetPalNtsc,$0001	;.
	word ksetPalNtsc,$0000  ;/
	word 0, $0000			;up/down
	word 0, $0000			;left/right
	word SIDEdit,$0000	;F1
	word ksavePatch,0	;F3
	word 0,0			;F5
	word SIDEdit,$FFFF	;F7
	word 0,0   				;return
	word 0,0					;Larrow

modeList:
	byte MODE_NORMAL
	byte MODE_5THS 
	byte MODE_5PORT
	byte MODE_PORT1
	byte MODE_PORT2
	byte MODE_PORT3
	byte MODE_MONO1
	byte MODE_MONO2
	byte MODE_MONOPORT1 ; new
	byte MODE_MONOPORT2 ; new
	byte MODE_ARP1 
	byte MODE_ARP2 
	byte MODE_ARP3 
	byte MODE_ARP4 
	byte MODE_ARP5 
	byte MODE_6CHAN ;16
	;byte MODE_MONOPORT1
	;byte MODE_MONOPORT2 ;16
	
MAX_PATCH_NUMBER equ 28


patchName
	byte "SAWTOOTH BASS   " ;0
	byte "GRITTY BASS     " ;1
	byte "PORTAMENTO 5THS " ;2
	byte "SAW PORTAMENTO  " ;3
	byte "PULSE 5THS      " ;4
	byte "PULSE HIGH PORT " ;5
	byte "TRINGL HIGH LONG" ;6
	byte "TRIANGLE DROP   " ;7
	byte "SID EXPLOSION   " ;8
	byte "MUTE            " ;9
	byte "FILTER BASS     " ;10 <--------- new patches start here
	byte "SWEEP ARP       " ;11
	byte "PLUCK ARP       " ;12
	byte "SLOW ARP        " ;13
	byte "FILTER STACK 1  " ;14
	byte "FILTER STACK 2  " ;15
	
patchName2
	byte "PULSAR          " ;16
	byte "VIBRATO LEAD    " ;17
	byte "SLOW RISE       " ;18
	byte "BENDING ECHO    " ;19
	byte "6 CHANNEL SAW   " ;20 
	byte "ARP LEAD        " ;21 <--- LAST PATCH THAT'S ACTUALLY SET UP AND USED
	byte "LASER BASS      " ;22 
	byte "TROMBONE BLAST  " ;23 ; THESE PATCHES ARE FOR FUTURE EXPANSION
	byte "NOISY SQUARE ARP" ;24
	byte "TRIANGLE SYNC   " ;25
	byte "CLEAN SAWTOOTH  " ;26 ; To ADD: TRI+SAW 30 30 30    TRI-RINGMOD 14 14 14    TRI+PULSE-RINGMOD 54 54 54
	byte "CLEAN TRIANGLE  " ;27
	byte "CLEAN PULSE SQR " ;28
	byte "PATCH SAVED     " ;29
	byte "CUSTOM PATCH    " ;30
	
SAVED_PATCH_MESSAGE equ 29
CUSTOM_PATCH_NUMBER equ 30


patchSoundMode
	byte  MODE_NORMAL ;0
	byte  MODE_NORMAL ;1
	byte  MODE_5PORT  ;2
	byte  MODE_PORT2  ;3
	byte  MODE_5THS   ;4
	byte  MODE_PORT2  ;5
	byte  MODE_NORMAL ;6
	byte  MODE_MONO1  ;7
	byte  MODE_PORT1 ;8
	byte  MODE_NORMAL ;9 
	byte  MODE_NORMAL ;10 <--- start of new 1.5.0 patches
	byte  MODE_ARP1  ;11
	byte  MODE_ARP2  ;12 
	byte  MODE_ARP3  ;13
	byte  MODE_MONO1 ;14
	byte  MODE_MONO2 ;15
	byte  MODE_NORMAL ;16
	byte  MODE_MONO1 ;17
	byte  MODE_NORMAL  ;18
	byte  MODE_PORT3 ;19
	byte  MODE_6CHAN ;20
	byte  MODE_ARP5 ;21
	byte  MODE_MONOPORT1 ;22 <---- start of 1.6.0 patches
	byte  MODE_MONOPORT2 ;23
	byte  MODE_ARP1 ;24
	byte  MODE_MONOPORT2 ;25
	byte  MODE_NORMAL ;26
	byte  MODE_NORMAL ;27
	byte  MODE_NORMAL ;28
	byte  MODE_NORMAL ;29
	byte  MODE_NORMAL ;30

	
	;     0     1     2     3     4     5     6     7     8     9    
patchFX                                             
	byte 	0,		5,		0,		0,		7,		6,   	1,		3,		2,   	0
	byte	3,		1,		3,		0,		2,		3,		4,		1,		1,		2
	byte	0,		3,		 1,	3,		3,		0,		0,		0,		0,		0
patchLFO ; (TREMOLO)
	byte 	$11,	$02,	$02,	$13,	$13,	$10,	$01,	$02, 	$13, 	$00
	byte 	$00,	$22,	$13,	$11,	$10,	$02,	$00,	$33, 	$10, 	$11
	byte 	$10,	$12,	 $13,	$00,	$00,	$13,	$00,	$00, 	$00, 	$00
patchOctave                                               
	byte 	0,	   0,    1,		1,		1,		2,		3,		3,		0, 	0
	byte 	1,	   2,    3,		1,		1,		2,		3,		3,		1, 	3
	byte 	1,	   3,     0,	3,		3,		1,		1,		3,		1, 	1
patchAD                                                  
	byte 	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00, 	$00, 	0
	byte 	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00, 	$E0, 	$A0
	byte 	$00,	$00,	$00,	$00,	$00,	$00,	$00,	$00, 	$00, 	0
patchSR1                                                  
	byte 	$F0,	$F5,	$F0,	$F0,	$F8,	$F0,	$FE,	$F6,	$F0, 	0
	byte 	$F0,	$Fa,	$F6,	$F6,	$FA,	$F9,	$FE,	$F7,	$FF, 	$EE
	byte 	$F0,	$F5,	 $F5,	$86,	$F6,	$F2,	$F2,	$F2,	$F0, 	0
patchSR2
	byte 	$F0,	$F5,	$F0,	$F0,	$F8,	$F0,	$FE,	$F6,	$F0, 	0
	byte 	$F0,	$Fa,	$F6,	$F6,	$FA,	$F9,	$FE,	$F7,	$FF, 	$EE
	byte 	$F0,	$F5,	 $F5,	$F6,	$54,	$F2,	$F2,	$F2,	$F0, 	0
patchSR3
	byte 	$F0,	$F5,	$F0,	$F0,	$F8,	$F0,	$FE,	$F6,	$F0, 	0
	byte 	$F0,	$Fa,	$F6,	$F6,	$FA,	$F9,	$FE,	$F7,	$FF, 	$EE
	byte 	$F0,	$F5,	 $F5,	$F6,	$F6,	$F2,	$F2,	$F2,	$F0, 	0
patchPaddle
	byte 	0,		0,		0,		0,		0,		0,		0,		0,		0, 	0
	byte	0,		0,		0,		0,		0,		0,		0,		0,		0,		0
	byte	0,		0,		0,		0,		0,		0,		0,		0,		0,		0
newPatchFiltCut                                             
	byte 	$B0,	$90,	$c0,	$FF,	$40,	$50,	$c0,	$70,	$80, 	0
	byte 	$80,	$A0,	$c0,	$FF,	$A0,	$80,	$c0,	$c0,	$80, 	$80
	byte 	$c0,	$F0,	 $c0,	$b0,	$A0,	$50,	$c0,	$c0,	$80, 	0
patchVol                                                 
	byte 	$f,	$F,	$b,	$9,	$9,	$7,	$F,	$C,	$c, 	0
	byte 	$f,	$c,	$F,	$b,	$9,	$7,	$F,	$c,	$F, 	$8
	byte 	$f,	$C,	 $b,	$9,	$F,	$F,	$F,	$F,	$c, 	0
patchPWL                                                 
	byte 	0,		0,		0,		0,		0,		0,		0,		0,		0, 	0
	byte	0,		0,		0,		0,		0,		0,		0,		0,		0,		0
	byte	0,		0,		 0,	0,		0,		0,		0,		0,		0,		0
patchPWH                                                 
	byte 	8,		8,		8,	   8,	 	8,		8,		8,		8,		8, 	0
	byte 	8,		8,		8,	   8,	 	8,		8,		8,		8,		8, 	8
	byte 	8,		8,		 8,	8,	 	8,		8,		8,		8,		8, 	0
	
patchWave1                                             
	byte 	$20,	$20,	$20,	$20,	$40,	$40,	$10,	$10,	$80, 	0
	byte 	$20,	$20,	$20,	$20,	$40,	$40,	$10,	$20,	$20, 	$40
	byte 	$20,	$20,	 $14,	$80,	$40,	$12,	$20,	$10,	$40, 	0
patchWave2
	byte 	$20,	$20,	$20,	$20,	$40,	$40,	$10,	$10,	$80, 	0
	byte 	$20,	$20,	$20,	$20,	$40,	$40,	$10,	$20,	$20, 	$40
	byte 	$20,	$20,	 $14,	$20,	$80,	$12,	$20,	$10,	$40, 	0
patchWave3                                                
	byte 	$20,	$20,	$20,	$20,	$40,	$40,	$10,	$10,	$80, 	0
	byte 	$20,	$20,	$20,	$20,	$40,	$40,	$10,	$20,	$20, 	$40
	byte 	$20,	$20,	 $14,	$10,	$10,	$12,	$20,	$10,	$40, 	0
	
patchFilt                                                
	byte 	$EF,	$EF,	$0F,	$0F,	$EF,	$EF,	$0F,	$0F,	$EF, 	$EF
	byte 	$EF,	$EF,	$0F,	$0F,	$EF,	$EF,	$0F,	$0F,	$EF, 	$EF
	byte 	$EF,	$EF,	 $0F,	$0F,	$EF,	$EF,	$0F,	$0F,	$EF, 	$EF
patchVolMode                                                
	byte 	$10,	$10,	$10,	$10,	$20,	$20,	$10,	$10,	$10, 	$10
	byte 	$10,	$10,	$10,	$10,	$20,	$20,	$10,	$10,	$10, 	$10
	byte 	$10,	$10,	 $10,	$10,	$10,	$10,	$10,	$10,	$10, 	$10

octaveTable
	byte 0,12,24,36,48

	
pwLFO
	byte %00010000, %00110000, %01010000, %01110000
	byte %10010000, %10110000, %11010000, %11110000
	byte %11110000, %11010000, %10110000, %10010000
	byte %01110000, %01010000, %00110000, %00010000

patOffset
	byte 0,40,80,120,160,200

voiceOffset:
	byte $0,$7,$E

	

;---------------------------- displayPage
	
	; This chart references each line
	; on the standard character based screen.
	; = value x 40 + 0x400
lineOffsetL
	byte $00
	byte $28,$50,$78, $A0,$C8,$F0
	byte $18,$40,$68, $90,$B8,$E0
	byte $08,$30,$58, $80,$A8,$D0
	byte $F8,$20,$48, $70,$98,$C0
	byte $E8
lineOffsetM
	byte $04
	byte $04,$04,$04, $04,$04,$04
	byte $05,$05,$05, $05,$05,$05
	byte $06,$06,$06, $06,$06,$06
	byte $06,$07,$07, $07,$07,$07
	byte $07

debugOverlay
 	byte 5,$82,"NOTE ONS",0
 	byte 9,$82,"NOTE OFFS",0
 	byte 10,$82,"                                    MIDI",0
 	byte 11,$82,"                                      IN",0
	;byte 6,$8d,"ASD",$8F,"=RELEASE-TIME ",$8d,":;=",$8F,"=VOLUME LOW/MED/HI",0
	;byte 7,$8d,"ZXCVBNMM,.",$8F,"=PATCH-SELECTION  ",$8d,"/",$8F,"=MUTE",0
	;byte 8,$8d,"SPACE",$8F,"=BENDER",$8d,"  CURSOR-KEYS",$8F,"=FIFTHS ON/OFF",0
	;byte 9,$8d,"FUNCTION-KEYS",$8F,"=OCTAVE",$8d,"  CTRL",$8F,"=CUSTOM-PATCH",0
 	byte 19,$82,"BUFFERS ETC",0
	byte 255

midiModeNames:
	byte "        " ;0
	byte "SEQUENTL" ;1
	byte "PASSPORT" ;2
	byte "   DATEL" ;3
	byte "NAMESOFT" ;4

fxNames:
	byte "NONE    " ;0
	byte "FILT1   " ;1
	byte "FILT2   " ;2
	byte "FILT3   " ;3
	byte "FILT4   " ;4
	byte "FILT5   " ;5
	byte "PULS1   " ;6
	byte "PULS2   " ;7
	byte "PULS3   " ;8
	
hexEditHelp:
	byte  6,$82,"ALL OS1 OS2 OS3  7  6  5  4  3  2  1  0 ",0
	byte  7,$81,"$22 $02 $09 $10",$87,"  +---PULSE-WIDTH-LOW---+",0
	byte  8,$8E," VAL $   $   $",0
	byte  9,$81,"$23 $03 $0A $11",$87,"  .  .  .  .  +PULS-HIGH+",0
	byte 10,$8E," VAL $   $   $",0
	byte 11,$81,"$24 $04 $0B $12",$87,"  NO SQ SA TR TE RI SY GT",0
	byte 12,$8E," VAL $   $   $",0
	byte 13,$81,"$25 $05 $0C $13",$87,"  +-ATTACK--+ +--DECAY--+",0
	byte 14,$8E," VAL $   $   $",0
 	byte 15,$81,"$26 $06 $0D $14",$87,"  +-SUSTAIN-+ +-RELEASE-+",0
	byte 16,$8E," VAL $   $   $",0
 	byte 17,$82,"----------------------------------------",0
	byte 18,$82,"ALL VAL  7  6  5  4  3  2  1  0 ",$8B,"  PRESS",0
 	byte 19,$81,"$15 ",$8E,"$    ",$87,".  .  .  .  . +FILT-LO+",$8B,"  '_' TO",0
 	byte 20,$81,"$16 ",$8E,"$    ",$87,"+-FILTER-CUTOFF-HIGH--+",$8B,"  CANCEL",0
 	byte 21,$81,"$17 ",$8E,"$    ",$87,"+FILT-RES-+ FX F1 F2 F3",$8B,"  ",0
 	byte 22,$81,"$18 ",$8E,"$    ",$87,"XX HP BP LP +-VOLUME--+",0
 	byte 23,$82,"----------------------------------------",0
 	byte 24,$8B,"ENTER 2-DIGIT HEX ADDRESS THEN HEX VALUE",0
 	byte 255

helpMessage
	;byte "RETURN FOR COMMANDS          ",0
	;byte "RETURN FOR HELP              ",0
	byte "RETURN=HELP                  ",0
normalHelp
 	byte 0,$82,"CYNTHCART -",$81,"KEY COMMANDS",$82,"-",$8B,"  RETURN TO EXIT012345",0
 	byte 1,$82,"----------------------------------------",0
 	byte 2,$83,"QWERTY",$8F," AND ",$83,"NUMBERS ROWS",$8F," ARE ",$81,"PIANO KEYS  ",0
 	byte 3,$83,"ASDF",$8F," AND",$83," ZXCV ROWS",$8F," SELECT",$81," SOUND PRESETS ",0
	byte 4,$83,"SPACE",$8F,"=BENDER",$83,"  CURSOR-KEYS",$8F,"=FIFTHS-ON/OFF",0
	byte 5,$83,"FUNCTION-KEYS",$8F,"=OCTAVE",$83," _",$8F,"=LOAD-CUSTOM-SOUND",0
 	byte 6,$82,"----------------------------------------",0
	byte 7,$81,"PRESS CTRL +",0
	byte 8,$8D,"ASD",$8F,"=RELEASE-TIME ",$8D,"FGHJKL:;",$8F,"=SOUND-MODE",0
	byte 9,$8D,"ZXCVBNM",$8F,"=MOD-MODE ",$8D,"F1-F7",$8F,"=VOL HI/MED/LO/OFF",0
 	byte 10,$82,"---------------------------------------",0
	byte 11,$81,"PRESS SHIFT +",0
	byte 12,$8A,"ASD",$8F,"=ATTACK  " ,$8A,"FGH",$8F,"=VID-STYLE" ,$8A," JKL",$8F,"=VID-ON/OFF"
	byte 0
	byte 13,$8A,"ZXCV",$8F,"=TREM-SPD " ,$8A,"BNM,",$8F,"=TREM-LEVL" ,$8A," ;:",$8F,"=VID-SIZE"
	byte 0
	byte 14,$8A,"CURSOR-KEYS",$8F,"=PADDLE1-ON/OFF",0
	byte 15, $8A,"F1-F7",$8F,"=PORTAMENTO ",$8A,"RETURN",$8F,"=CLEAR-MODULATION",0
 	byte 16,$82,"---------------------------------------",0
	byte 17,$81,"PRESS COMMODORE-KEY +",0
	byte 18,$8E,"ASDFGHJK",$8F,"=FIXED-CUTOFF  ",$8E,",./",$8F,"=OMNI/CH1/CH5"
	byte 0
	byte 19,$8E,"ZXC",$8F,"=FILT-ON/OFF/DISABLE",$8E," VBNM",$8F,"=PADDLE2"
	byte 0
 	byte 20,$82,"---------------------------------------",0
	byte 21,$81,"PRESS RUN-STOP +",0
	byte 22,$87,"ASDFGHJKL:;",$8F,"=TUNING" ,$87,"  ./",$8F,"=PAL/NTSC"
	byte 0
	byte 23,$87,"ZXCVBNM",$8F,"=",$81,"MORE",$8F,"-",$81,"PRESETS  ",$87,"F1",$8F,"=SID-EDIT-C64KEYS"
	byte 0
	byte 24,$87,"F3",$8F,"=SAVE-CUSTOM-SOUND  ",$87,"F7",$8F,"=SID-EDIT-PIANO "
	byte 0
	byte 255

mainColorText
	byte 0,$82,"CYNTHCART  ",$8F,"PRESET",$8C,"=",$81,"                       ",0 
	byte 1,$8A,"MODE",$8C,"=",$81,"X    ",$83,"       ",$8D,"       ",$8F,"      ",$8D,"FILTR",$8C,"=",$81,"X   ",0
	byte 2,$8F,"TUNING",$8C,"=",$81,"X   ",$83,"ATTACK",$8C,"=",$81,"X ",$87,"TREMOLO",$8C,"=",$81,"X ",$8D,"CUTOFF",$8C,"=",$81,"X  ",0
	byte 3,$8F,"OCTAVE",$8C,"=",$81,"X   ",$83,"RELEAS",$8C,"=",$81,"X ",$87,"TRM-SPD",$8C,"=",$81,"X ",$8D,"PADD1",$8C,"=",$81,"X   ",0
	byte 4,$8F,"VOLUME",$8C,"=",$81,"X   ",$8F,"MOD",$8C,"=",$81,"XXXXX ",$8F," VIDEO",$8C,"=",$81,"X ",$8F,"PADD2",$8C,"=",$81,"X   ",0
 	byte 23,$82,"                                        ",0

 	; OLD LAYOUT
	;byte 0,$82,"CYNTHCART  ",$81,"PATCH",$8F,"=                       ",0
	;byte 1,$87,"           LFO:     RATE",$8F,"=     ",$87,"DEPTH",$8F,"=    ",0
	;byte 2,$81,"FIFTHS",$8F,"=    ",$83,"ATTACK",$8F,"=  ",$83,"RELEASE",$8F,"=  ",$8A,"MODE",$8F,"=     ",0
	;byte 3,$8D,"PAD1",$8F,"=      ",$8D,"CUTOFF",$8F,"=  ",$8D,"FILTR",$8F,"=    ",$81,"TUNE",$8F,"=    ",0
	;byte 4,$81,"PAD2",$8F,"=      ",$81,"OCTAVE",$8F,"=  ",$81,"VIDEO",$8F,"=    ",$81,"VOL",$8F,"=      ",0
	;byte 255

CYNTHCART_HIGHLIGHT_COLOR equ 7
CYNTHCART_COLOR equ 2
	
	
MODETEXT equ 40*1+5
TUNINGTEXT equ 40*2+7
OCTAVETEXT equ 40*3+7
VOLTEXT equ 40*4+7

ATKTEXT equ 40*2+18
RELTEXT equ 40*3+18
PATCHTEXT equ 40*0+18

LFORATETEXT equ 40*3+28
LFODEPTHTEXT equ 40*2+28
VIDEOTEXT equ 40*4+28

FXTEXT equ 40*4+15

FILTERTEXT2 equ 40*1+36
FILTERTEXT equ 40*2+37
PADDLETEXT equ 40*3+36
PAD2TEXT equ 40*4+36

SYNCTEXT equ 40*0+18 ; The sync feature is not currently used
	
	
	byte 255



textData ; can contain 64 four byte texts
	byte "OFF " ;0
	byte "ON  " ;4
	byte "SLOW" ;8
	byte "MED " ;12
	byte "FAST" ;16
	byte "-40 " ;20 tuning
	byte "-30 " ;24
	byte "-20 " ;28
	byte "-10 " ;32
	byte "0   " ;36
	byte "+10 " ;40
	byte "+20 " ;44
	byte "+30 " ;48
	byte "+40 " ;52
	byte "+50 " ;56
	byte "POLY" ;60 mode
	byte "MONO" ;64
	byte "FREQ" ;68 LFO dest
	byte "FILT" ;72
	byte "VOL " ;76
	byte "LOW " ;80
	byte "MED " ;84
	byte "HIGH" ;88
	byte "SID:" ;92
	byte "DIS " ;96
	byte "OFF " ;100 - paddle2 settings
	byte "PULS" ;104
	byte "XXXX" ;108 - this one for future...
	byte "LFO " ;112
	byte "BEND" ;116

		
modeNamesPolyphony ; Name (7 bytes) + Polyphony (1 byte)
	byte "POLY   ",3 ;$00 0
	byte "PORT1  ",3 ;$08 1
	byte "PORT2  ",3 ;$10 2
	byte "PORT3  ",3 ;$18 3
	byte "MONO1  ",1 ;$20 4
	byte "MONO2  ",1 ;$28 5
	byte "MONP1  ",1 ;$30 6 
	byte "ARP1   ",7 ;$38 7
	byte "ARP2   ",7 ;$40 8
	byte "ARP3   ",7 ;$48 9
	byte "ARP4   ",7 ;$50 10
	byte "ARP5   ",7 ;$58 11
	byte "6CHAN  ",6 ;$60 12
	byte "5THS   ",3 ;$68 13
	byte "5PORT  ",3 ;$70 14
	byte "MONP2  ",1 ;$78 15
	
modeNameOffsets
	;     0   1   2   3    4   5   6   7     8   9   A   B    C   D   E   F
	byte $00,$68,$70,$00, $00,$00,$00,$00,  $60,$00,$00,$00, $00,$00,$00,$00 ;$00
	byte $08,$10,$18,$00, $00,$00,$00,$00,  $00,$00,$00,$00, $00,$00,$00,$00 ;$10
	byte $20,$28,$30,$00, $00,$00,$00,$00,  $00,$00,$00,$00, $00,$00,$00,$00 ;$20
	byte $30,$30,$78,$78, $00,$00,$00,$00,  $00,$00,$00,$00, $00,$00,$00,$00 ;$30
	byte $38,$40,$48,$50, $58,$00,$00,$00,  $00,$00,$00,$00, $00,$00,$00,$00 ;$40
	
	
; VERSION NUMBER
bottomText
	byte " PAL V1.6.0",0
	byte "NTSC V1.6.0",0

	
; contant pointers into the textData array
ON equ 0
OFF equ 4
SLOW equ 8
MED equ 12
FAST equ 16
TUNING equ 20
POLY equ 60
MONO equ 64
FREQ equ 68
FILT equ 72
VOL equ 76
VLOW equ 80
VMED equ 84
VHIGH equ 88
DISABLED equ 96
PAD2VALTEXT equ 100




tuneArrPtrLL
	byte <tuningL0, <tuningL1, <tuningL2, <tuningL3, <tuningL4, <tuningL5, <tuningL6, <tuningL7, <tuningL8, <tuningL9
tuneArrPtrLH
	byte >tuningL0, >tuningL1, >tuningL2, >tuningL3, >tuningL4, >tuningL5, >tuningL6, >tuningL7, >tuningL8, >tuningL9
tuneArrPtrHL
	byte <tuningH0, <tuningH1, <tuningH2, <tuningH3, <tuningH4, <tuningH5, <tuningH6, <tuningH7, <tuningH8, <tuningH9
tuneArrPtrHH
	byte >tuningH0, >tuningH1, >tuningH2, >tuningH3, >tuningH4, >tuningH5, >tuningH6, >tuningH7, >tuningH8, >tuningH9

LFODepthArray
	byte 0,2,5,15
	
	
	
		
hexDisplay
	byte 48,49,50,51,52, 53,54,55,56,57, 1,2,3,4,5, 6

;keyData ; numbers 0-9 and letters a-f
;	byte 35,56,59,8,11, 16,19,24,27,32, 10,28,20,18,14, 21

	 ; key set for piano keyboard: black keys + middle A-F on the white keys
;	byte 51,59,8,16,19, 24,32,35,43,48, 25,30,33,38,41, 46

	; array of LFO values
LFOArrL
	byte 0,1,2,3,  2,1,0,1,     2,3,4,5,         4,3,2,1
LFOArrH
	byte 0,0,0,0, 0,0,0,255, 255,255,255,255, 255,255,255,255 ; more LFO depth
LFOdisp
	byte 6,7,8,9,  8,7,6,5, 4,3,2,1, 2,3,4,5

; NTSC Note Table
NSoundLArr:                                                               ;  |      80     |      C-5      |     8583    |      33     |     135     | 
	byte 24,56,90,125, 163,203,246,35, 83,134,187,244	; octave 2       ;  |      81     |      C#-5     |     9094    |      35     |     134     |
	byte 48,122,180,251, 71,151,237,71, 167,12,119,233	; octave 3       ;  |      82     |      D-5      |     9634    |      37     |     162     |
	byte 97,225,104,247, 143,47,218,142, 77,24,238,210	; octave 4       ;  |      83     |      D#-5     |    10207    |      39     |     223     |
	byte 195,195,209,239, 31,96,181,30, 156,49,223,165	; octave 5       ;  |      84     |      E-5      |    10814    |      42     |      62     |
	byte 135,134,162,223, 62,193,107,60, 57,99,190,75	; octave 6       ;  |      85     |      F-5      |    11457    |      44     |     193     |
	byte 15,12,69,191, 125,131,214,121, 115,199,124,151 ; octave 7
                                                                         ;  |      86     |      F#-5     |    12139    |      47     |     107     |
NSoundHArr:                                                               ;  |      87     |      G-5      |    12860    |      50     |      60     |
	byte 2,2,2,2, 2,2,2,3, 3,3,3,3				; octave 2               ;  |      88     |      G#-5     |    13625    |      53     |      57     |
	byte 4,4,4,4, 5,5,5,6, 6,7,7,7				; octave 3               ;  |      89     |      A-5      |    14435    |      56     |      99     |
	byte 8,8,9,9, 10,11,11,12, 13,14,14,15		; octave 4               ;  |      90     |      A#-5     |    15294    |      59     |     190     |
	byte 16,17,18,19, 21,22,23,25, 26,28,29,31	; octave 5               ;  |      91     |      B-5      |    16203    |      63     |      75     |
	byte 33,35,37,39, 42,44,47,50, 53,56,59,63	; octave 6               ;  |      96     |      C-6      |    17167    |      67     |      15     |
	byte 67,71,75,79, 84,89,94,100, 106,112,119,126 ;octave 7

; PAL Note Table
PSoundLArr:                                                            
	byte 45,78,113,150, 190,231,20,66, 116,169,224,27
	byte 90,156,226,45, 123,207,39,133, 232,81,193,55
	byte 180,56,196,89, 247,158,78,10, 208,162,129,109
	byte 103,112,137,178, 237,59,157,20, 160,69,3,219
	byte 207,225,18,101, 219,118,58,39, 65,138,5,181
	byte 157,193,36,201, 182,237,115,78, 130,20,10,106
	byte 59,130,72,147, 107,218,231,156, 4,40,20
                                                                     
PSoundHArr:                                                           
	byte 2,2,2,2, 2,2,3,3, 3,3,3,4
	byte 4,4,4,5, 5,5,6,6, 6,7,7,8
	byte 8,9,9,10, 10,11,12,13, 13,14,15,16
	byte 17,18,19,20, 21,23,24,26, 27,29,31,32
	byte 34,36,39,41, 43,46,49,52, 55,58,62,65
	byte 69,73,78,82, 87,92,98,104, 110,117,124,131
	byte 139,147,156,165, 175,185,196,208, 221,234,248
