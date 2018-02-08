/****
 * lab2c
 * Name: Khari Ollivierre
 * Section: 1490
 * TA: Samantha Soto
 * Description: Clock Delay subroutines
****/

.include "ATxmega128A1Udef.inc"

.equ LIMIT = 0xFF
.equ DELAY = 0x13
.equ ZERO = 0x00
.equ OFFSET = 0x10
.equ CUSTOM = 0xFF

.ORG 0x0000					
	rjmp MAIN				

.dseg
.ORG 0x0100
	TMP: 	.byte 1

.cseg
MAIN:
	ldi 	R18, ZERO		; Zero registers for counting
	ldi 	R19, ZERO
	ldi 	R20, LIMIT
	ldi 	R21, ZERO		; Register for delay extension multiplier counter
	ldi 	R22, OFFSET		; Multiplier value stored in R20.
	ldi	R23, CUSTOM		; Custom delay value set to max
	sts 	PORTC_DIRSET, R13 	; Allow Port D to output the delayed clock
	sts 	PORTC_OUTCLR, R13

DELAY10MS:
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
	rjmp 	DLOOP

DELAYX10MS:
	sts	TMP, R23
	lds	R22, TMP
	rjmp	DLOOP

