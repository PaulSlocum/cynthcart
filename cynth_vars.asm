; *********************************************
; Constants
; *********************************************

;KEYTIME equ 128
;KEYTIME equ 64
KEYTIME equ 40

REL_SHORT equ $E0
REL_MED	equ $E9
REL_LONG equ $EE

ATK_SHORT equ $00
ATK_MED	equ $90
ATK_LONG equ $E0


VOLOFF equ $00
VOLLOW equ $07
VOLMED equ $0B
VOLHIGH equ $0F

CURRENTKEY equ 197

BACK_COLOR equ 53280
BORD_COLOR equ 53281

SID1 equ $D400


;SID2 equ $DEE0

SID2OFFSET equ 4

SID_SYMPHONY_FILTER_OFFSET equ 10
	
SV1FL 		equ $00
SV1FH 		equ $01
SV1PWL 		equ $02
SV1PWH 		equ $03
SV1WAVE		equ $04
SV1AD 		equ $05
SV1SR 		equ $06

SV2FL 		equ $07
SV2FH 		equ $08
SV2PWL 		equ $09
SV2PWH 		equ $0A
SV2WAVE 	equ $0B
SV2AD 		equ $0C
SV2SR 		equ $0D

SV3FL 		equ $0E
SV3FH 		equ $0F
SV3PWL 		equ $10
SV3PWH 		equ $11
SV3WAVE 	equ $12
SV3AD 		equ $13
SV3SR 		equ $14
	
SFILTL		equ $15
SFILTH		equ $16
SFILTC		equ $17
SVOLMODE	equ $18

SPAD1		equ $19
SPAD2		equ $1A

SRAND 		equ $1B

PortA		equ $dc00
Ciddra		equ $dc02


; *********************************************
; RAM Variables
; *********************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ZERO PAGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FROM SORTING ROUTINE
zpadd  = $120				;2 byte pointer in page zero. set by calling program
nval	 = $122				;set by calling program
work1  = $125				;3 bytes used as working area
work2  = $126
work3  = $127

;ZPADD  = $30            ;2 BYTE POINTER IN PAGE ZERO. SET BY CALLING PROGRAM
;NVAL   = $32            ;SET BY CALLING PROGRAM
;WORK1  = $33            ;3 BYTES USED AS WORKING AREA
;WORK2  = $34
;WORK3  = $35

; CYNTHCART
tunePtrL	equ 34 ;2 bytes 
copyPtrS	equ 34 ; (also used for RAM copying)
tunePtrH	equ 36 ;2 bytes (also used for RAM copying)
copyPtrD	equ 36 ; (also used for RAM copying)

lowTextPtr equ 43 ; 2 BYTES
lowColorPtr equ 45 ; 2 BYTES

helpReadPointerL equ 47
helpReadPointerM equ 48
helpWritePointerL equ 49
helpWritePointerM equ 50
helpColorPointerL equ 51
helpColorPointerM equ 52
 
portPtrL	equ 53 ;2 bytes
portPtrH	equ 71 ;2 bytes

keyPtrL equ 194 ; used to set up key command function calls
keyPtrH equ 195

; -= -= -= -= -= - = -= -= -= -= -= -= -= -= -= -= -= -= -= -= -=
; MIDI module -= -= -= -= -= -= -= -= -= -= -= -= 
; private addresses ======
midiControl equ $64 ; $64 = 100
midiStatus = $66 ; 102
midiTx = $68 ;104
midiRx = $6a ;106
keyTestIndex = $6f ; 111
keyPressedIntern = $70 ; 112
shiftPressed = $72 ; 114
; public addresses ======
midiRingbufferReadIndex = $6c ;108
midiRingbufferWriteIndex = $6d ;109
midiInterfaceType = $6e ;110
keyPressed = $71 ; 113
; this module ======
midiMessage equ $59 ; 95
lastWaveform equ $5a ; 90
; - - - - - - - - - - - - - -
; - - - - - - - - - - - - - -
; Non-zero page
midiRingbuffer = $7F00
; -= -= -= -= -= - = -= -= -= -= -= -= -= -= -= -= -= -= -= -= -=

;-------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NON-ZERO PAGE ($7000-$7FFF)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Trem		equ $7000

FrameH		equ $7002
Frame		equ $7003

EchoPtr		equ $7004
EchoCur		equ $7005

Buffer  	equ $7006 ; for paddle reading routine

MagicVoice	equ $7007

LastKey		equ $7008

Button		equ $7009

LFO			equ $700A

PatchTune	equ $700B

temp		equ $700C

;KeyA	equ $700D
;KeyB	equ $700E
;KeyC	equ $700F

;lastKeyA equ $7010
;lastKeyB equ $7011
;lastKeyC equ $7012

portDirA equ $7013
portDirB equ $7014
portDirC equ $7015

pitchLA	equ $7016
pitchLB	equ $7017
pitchLC	equ $7018

pitchHA	equ $7019
pitchHB	equ $701A
pitchHC	equ $701B

volume	equ $701C

; soundModes 
; UPPER 5 BITS = MODE, LOWER 3 BITS = SUBMODE
MODE_NORMAL equ $00
MODE_6CHAN 	equ $08
MODE_PORT1	equ $10
MODE_PORT2	equ $11
MODE_PORT3	equ $12
MODE_MONO1 	equ $20
MODE_MONO2 	equ $21
MODE_MONOPORT1 equ $31
MODE_MONOPORT2 equ $32
MODE_ARP1 	equ $40
MODE_ARP2 	equ $41
MODE_ARP3 	equ $42
MODE_ARP4 	equ $43
MODE_ARP5 	equ $44
MODE_5THS 	equ $01
MODE_5PORT 	equ $02
;- - - - - - - - - - - 

PORT_MASK 	equ $10
MONO_MASK 	equ $20
ARP_MASK 	equ $40
CHAN6_MASK 	equ $08


soundMode equ $701D
arpSpeed	equ $701E

dispOn	equ $701F

VICMode	equ $7020

patPtr	equ $7021

keyOffset	equ $7022

volModeRAM equ $7024

shiftL1 equ $7025
shiftH1 equ $7026
shiftL2 equ $7027
shiftH2 equ $7028

;$7025 - $7028 free

paddle	equ $7029 ; determines whether paddle controls filter or not

WaveType	equ $7030
WaveType2	equ $7037
WaveType3	equ $703E

LFObend		equ $703F
bender		equ $7040

pitchTmpL	equ $7043
pitchTmpH	equ $7044

videoMode	equ $7045

textTemp	equ $7046

patchSetY	equ $7047

LFORate		equ $7048
LFODepth	equ $7049

videoModeNum equ $7050

portLastNote equ $7051 ;-$7053   3 bytes
portLastDir	 equ $7054 ;-$7056	 3 bytes

filter	equ $7057

keyTimer equ $7058

bendSpd equ $7059

SIDeditAddr equ $705A
SIDeditValue equ $705B

filterDisable equ $705C

lastKey equ $705D

hexKeyMode equ $7060

NTSCmode equ $7061

temp16L equ $7062
temp16H equ $7063

saveX equ $7064

;EchoBuffer	equ 1184 ; 256 bytes

keyTemp equ $7065

lastOsc equ $7066

fullScreenMode equ $7067

videoText equ $7068

attack equ $7069
release equ $706A
octave equ $706B
filterStatus equ $706C

helpColor equ $706D
helpYIn equ $706E
helpYOut equ $706F

helpMode equ $7070

tuneSetting equ $7071

hexDispTemp equ $7072

sidTemp1 equ $7073
sidTemp2 equ $7074

customPatchSaved equ $7075

paddleTop equ $7076
paddleBottom equ $7077

paddleX equ $7078
paddleY equ $7079

paddle2 equ $707A
lastPad2 equ $707B

debugOffset equ $707C
savedMidiStatus equ $707D
firstDataByte equ $707E
tempVelocity equ $707F
bufferSize equ $7080
noteTempA equ $7081
noteTempB equ $7082

benderAutoreset equ $7083
polyphony equ $7084

arpOffset equ $7085

fxType equ $7086
modValue1 equ $7087
modDirection equ $7089
modCounter equ $708A
modLFOMinValue equ $708B
modLFOMaxValue equ $708A

MOD_NONE equ 0
MOD_FILT_LFO equ 1
MOD_FILT_ENV equ 2
MOD_FILT3 equ 3
MOD_FILT4 equ 4
MOD_FILT5 equ 5
MOD_PW_LFO equ 6
MOD_PW2 equ 7

noteOffCount equ $708B
noteOnCount equ $708C

hexDispColor equ $708D

midiBendValue equ $708E

temp2 equ $708F


resonance equ $7097

resetValue equ $7098

lastNoteCount equ $7099
lastNote equ $709A

keyCount equ $709B

filterModValue equ $709C
filterSetValue equ $709D
pwModValue equ $709E
pwSetValue equ $709F

midiTuning equ $70F0
benderTuning equ $70F1
lfoTuning equ $70F2
systemTuning equ $70F3
masterTuning equ $70F4
finalTuning equ $70F5
noteShift equ $70F6

midiMode equ $70F7


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; BUFFERS
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - 

NOTE_BUF_SIZE equ 8
noteNumArray equ $70A0
playNoteArray equ $70B0

;noteVelArray equ $70C0

kbBuffer equ $70D0
lastKbBuffer equ $70E0

tempA equ $70E1
tempX equ $70E2
tempY equ $70E3


;-----------------------------------------------

; SID editor custom preset data...
sidData equ $7100 ; 32 bytes -- location to save SID register writes since it is read only

sidSaveData equ $7120 ; 32 bytes -- location to save edited SID patch
savePaddle equ $7141
saveOctave equ $7142
saveSoundMode equ $7143
saveFXType equ $7143
saveArpSpeed equ $7144
saveLFODepth equ $7146
saveLFORate equ $7147
saveVolume equ $7148
saveVolMode equ $7149
saveFilter equ $714A

;--------------------------------------------------

midiEnabled equ $7150 
dummyMidiIncrementer equ $7151

sidEditSaveTemp1 equ $7052
sidEditSaveTemp2 equ $7053
sidEditSaveTemp3 equ $7054
sidEditSaveTemp4 equ $7055
sidEditSaveTemp5 equ $7056
sidEditSaveTemp6 equ $7057
sidEditSaveTemp7 equ $7058

		
