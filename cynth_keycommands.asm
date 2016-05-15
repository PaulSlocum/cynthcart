
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
	word 0, 0	;A
	word 0, 0 	;S
	word 0, 0	;D
	word 0, 0	;F
	word 0, 0	;G
	word 0, 0	;H
	word 0, 0	;J
	word 0, 0	;K
	word 0, 0	;L
	word 0, 0	;:
	word 0, 0	;;
	word 0, 0	;=
	word 0, 0	;Z
	word 0, 0		;X
	word 0, 0		;C
	word 0, 0		;V
	word 0, 0		;B
	word 0, 0		;N
	word 0, 0		;M
   word 0, 0		;,
	word 0, 0		;.
	word 0, 0		;/
	word 0, 0			;up/down
	word 0, 0			;left/right
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
	word ksetPalNtsc,$0001	;F1
	word ksetPalNtsc,$0000  ;F3
	;word 0, $0000			;F1
	;word 0, $0000			;F3
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
   word setPatch, $1D00	;,
	word 0, $0000	;.
	word 0, $0000  ;/
	;word ksetBlackBG, $0000	;.
	;word ksetBlueBG, $0000  ;/
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