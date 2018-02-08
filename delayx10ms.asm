/****
 * lab2b.asm
 *
 * Khari Ollivierre
****/

.include "ATxmega128A1Udef.inc"

.equ LIMIT = 0xFF
.equ DELAY = 0x19
.equ ZERO = 0x00
.equ REPS = 0x05

.ORG 0x0000					
	rjmp DELAY10MS				

.ORG 0x0100

DELAY10MS:
	ldi 	R18, ZERO		; Zero registers for counting
	ldi 	R19, ZERO
	ldi 	R20, LIMIT
	ldi 	R21, ZERO		; Register for delay extension multiplier counter
	ldi 	R22, REPS		; Multiplier value stored in R20
	sts 	PORTD_DIRSET, R13 	; Allow Port D to output the delayed clock
	sts 	PORTD_OUTCLR, R13

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
	breq 	XLOOP		; Each increment will execute 771 instructions. 19998/771 ~= 26, so this entire loop
					; should execute 26 times. The end result will be marginally identical to 10 ms
	ldi 	R18, ZERO
	rjmp 	DLOOP

XLOOP:
	inc 	R21
	cp 	R21, R22
	breq 	END
	ldi 	R18, ZERO
	ldi 	R19, ZERO
	rjmp 	DLOOP
END:
	sts 	PORTD_OUTTGL, R18	; Toggle the output like a clock
	ldi 	R18, ZERO
	ldi 	R19, ZERO
	ldi 	R21, ZERO
	rjmp 	DLOOP
	

