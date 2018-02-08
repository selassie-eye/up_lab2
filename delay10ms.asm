/****
 * lab2b.asm
 *
 * Khari Ollivierre
****/

.include "ATxmega128A1Udef.inc"

.equ LIMIT = 0xFF
.equ DELAY = 0x14
.equ ZERO = 0x00

.ORG 0x0000					
	rjmp DELAY10MS				

.ORG 0x0100

DELAY10MS:
	ldi R11, ZERO	; Zero registers for counting
	ldi R12, ZERO
	ldi R13, LIMIT
	sts PORTD_DIRSET, R13 ; Allow Port D to output the delayed clock
	sts PORTD_OUTCLR, R13

DLOOP:
	inc R11		; Increment counter register
	cpi R11, LIMIT	; Counter check
	brne DLOOP	; This loops 256 times, 3*256 = 768 instructions per loop.
				; It takes the CPU 10 ms to execute 20000 instructions,
				; and by the start of the loop, it has executed 2 instructions, so
				; 19998 instructions are left to be executed.
				;
				; 19998/3 = 6666, so the loop would have to execute 6666 times to delay appropriately.
				; Since the registers only hold 2 bytes each, multiple registers must track the loop 
				; execution.
	inc R12		; increments the 2nd counter
	cpi R12, DELAY	; counter check
	breq END	; Each increment will execute 771 instructions. 19998/771 ~= 26, so this entire loop
				; should execute 26 times. The end result will be marginally identical to 10 ms
	ldi R11, ZERO
	rjmp DLOOP
END:
	sts PORTD_OUTTGL, R13	; Toggle the output like a clock
	ldi R11, ZERO
	rjmp DLOOP
	

