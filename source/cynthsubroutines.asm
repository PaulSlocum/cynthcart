;sorting subroutine coded by mats rosengren (mats.rosengren@esa.int)
;
; input:
;zpadd  - start address of sequence to be sorted shall be put in zpadd, zpadd+1 (zero page)
;			 should point to the byte just before the first byte to be sorted
;			 ( "lda (zpadd),y" with 1<=y<=255)
;nval   - number of values,  1<= nval <= 255
;			 value will be destroyed (set to zero)
;


		  ;*=$6000			;code anywhere in ram or rom
		  
	;=====================================================================
	; CUSTOM SORT FOR NOTE ARRAY
doSort:
	lda #8
	sta nval
sort: 
	ldy nval 			 ;start of subroutine sort
	lda noteNumArray-1,y		 ;last value in (what is left of) sequence to be sorted
	sta work3			;save value. will be over-written by largest number
	jmp l2
l1: 
	dey
	beq l3
	lda noteNumArray-1,y
	cmp work2
	bcc l1
l2: 
	sty work1 			;index of potentially largest value
	sta work2 			;potentially largest value
	jmp l1
l3: 
	ldy nval				;where the largest value shall be put
	lda work2 			;the largest value
	sta noteNumArray-1,y		;put largest value in place
	ldy work1 			;index of free space
	lda work3 			;the over-written value
	sta noteNumArray-1,y		;put the over-written value in the free space
	dec nval				;end of the shorter sequence still left
	bne sort				;start working with the shorter sequence
	rts
	;=====================================================================
	  
	 
	
	
	;=====================================================================
	; ORIGINAL VERSION
;originalSort: 
	;ldy nval 			 ;start of subroutine sort
	;;lda (zpadd),y		 ;last value in (what is left of) sequence to be sorted
	;sta work3			;save value. will be over-written by largest number
	;jmp l2
;l1: 
	;dey
	;beq l3
	;;lda (zpadd),y
	;cmp work2
	;bcc l1
;l2: 
	;sty work1 			;index of potentially largest value
	;sta work2 			;potentially largest value
	;jmp l1
;l3: 
	;ldy nval				;where the largest value shall be put
	;lda work2 			;the largest value
	;;sta (zpadd),y		;put largest value in place
	;ldy work1 			;index of free space
	;lda work3 			;the over-written value
	;;sta (zpadd),y		;put the over-written value in the free space
	;dec nval				;end of the shorter sequence still left
	;bne sort				;start working with the shorter sequence
	;rts
	;=====================================================================
	  
	 