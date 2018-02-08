/****
 * lab2d
 * Name: Khari Ollivierre
 * Section: 1490
 * TA: Samantha Soto
 * Description: LED game
****/

.include "ATxmega128A1Udef.inc"


.equ LIMIT = 0xFF
.equ DELAY = 0x13
.equ OFFSET = 0x10
.equ ZERO = 0x00
.equ ONES = ~ZERO

.def TMP = R16
.def A = R17
.def C = R23
.def F = R24

.ORG 0x0000					
	rjmp	MAIN				

.ORG 0x0100

MAIN:
	ldi	TMP, ONES
	sts	PORTA_DIRCLR, TMP
	sts	PORTC_DIRSET, TMP
	sts	PORTF_DIRCLR, TMP
	clr	TMP

LOOP:
	clr	C
	sts	PORTC_OUT, C
	lds	F, PORTF_IN
	sbrs	F, 2		; Check if S1 is pressed
	rjmp	DISP
	sbrs	F, 3		; Check if S2 is pressed
	rjmp	BLNK
	rjmp	LOOP

DISP:
	lds	A, PORTA_IN
	sts	PORTC_OUT, A
	lds	F, PORTF_IN
	sbrc	F, 2
	rjmp	LOOP
	rjmp	DISP

BLNK:
	lds	A, PORTA_IN
	sts	PORTC_OUTTGL, A
	lds	F, PORTF_IN
	sbrc	F, 2
	rjmp	LOOP
	rjmp	DELAY10MS

DELAY10MS:
	ldi 	R18, ZERO		; Zero registers for counting
	ldi 	R19, ZERO
	ldi 	R20, LIMIT
	ldi 	R21, ZERO		; Register for delay extension multiplier counter
	ldi 	R22, OFFSET		; Multiplier value stored in R20.

DLOOP:
	inc 	R18		; Increment counter register
	cpi 	R18, LIMIT	; Counter check
	brne 	DLOOP		; This loops 256 times, 3*256 = 768 instructions per loop
					; It takes the CPU 10 ms to execute 20000 instructions,
					; and by the start of the loop, it has executed 2 instructions, so
					; 19998 instructions are left to be executed.
					;
					; 19998/3 = 6666, so the loop would have to execute 6666 times to delay appropriately.
					; Since the registers only hold 2 bytes each, multiple registers must track the loop 
					; execution.
	inc 	R19		; increments the 2nd counter
	cpi 	R19, DELAY	; counter check
	breq 	LOOP		; Each increment will execute 771 instructions. 19998/771 ~= 26, so this entire loop
					; should execute 26 times. The end result will be marginally identical to 10 ms
	ldi 	R18, ZERO
	rjmp 	DLOOP

LOOP:
	inc 	R21
	cp 	R21, R22
	breq 	END
	ldi 	R18, ZERO
	ldi 	R19, ZERO
	rjmp 	DLOOP
END:
	sts 	PORTC_OUTTGL, R18	; Toggle the output like a clock
	ldi 	R18, ZERO
	ldi 	R19, ZERO
	ldi 	R21, ZERO
	rjmp 	BLNK

	
	
	

