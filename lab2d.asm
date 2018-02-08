/****
 * lab2d
 * Name: Khari Ollivierre
 * Section: 1490
 * TA: Samantha Soto
 * Description: LED game
****/

.include "ATxmega128A1Udef.inc"

.equ STATE0	= 0x81
.equ STATE1 	= 0x42
.equ STATE2 	= 0x24
.equ STATE3 	= 0x18
.equ ZERO 	= 0x00
.equ ONES 	= ~ZERO
.equ TABLE_S 	= 8
.equ RED	= 0xEF
.equ GREEN	= 0xDF

.equ LIMIT = 0xFF
.equ DELAY = 0x13
.equ REPS = 0x0A

.def C_STATE 	= R16
.def TMP 	= R17

.ORG 0x0000					
	rjmp MAIN				

.ORG 0x0100
	STATES: .db ~STATE0, ~STATE1, ~STATE2, ~STATE3, ~STATE2, ~STATE1, ~STATE0, ~ZERO

MAIN:
	ldi	ZL, low(STATES << 1)	; Loads table location into Z
	ldi	ZH, high(STATES << 1)
	ldi	TMP, ONES		; Set Port C and D to outputs
	sts	PORTC_DIRSET, TMP
	sts	PORTD_DIRSET, TMP
	sts	PORTF_DIRCLR, TMP	; Set Port F to input
	clr	TMP

LOOP:
	lpm 	C_STATE, Z+		; Loads the current state and increments
	sts	PORTC_OUT, C_STATE	; Sets output to state
	rjmp	DELAYX10MS

RE:
	cpi	C_STATE, ~ZERO		; Checks if current state is zero, resets Z if so
	breq	RESET
	rjmp	LOOP

RESET:
	ldi	ZL, low(STATES << 1)
	ldi	ZH, high(STATES << 1)
	rjmp	LOOP

CHECK:
	cpi	C_STATE, ~STATE3
	breq	WIN

LOSS:
	ldi	TMP, RED	; Set LED to red
	sts	PORTD_OUT, TMP
	lds	TMP, PORTF_IN
	sbrs	TMP, 2		; If S1 is pressed, reset game
	rjmp	RESET
	clr	TMP
	rjmp	LOSS

WIN:
	ldi	TMP, GREEN	; Set LED to green
	sts	PORTD_OUT, TMP
	lds	TMP, PORTF_IN
	sbrs	TMP, 2		; If S1 is pressed, reset game
	rjmp	RESET
	clr	TMP
	rjmp	WIN

DELAYX10MS:
	ldi 	R18, ZERO		; Zero registers for counting
	ldi 	R19, ZERO
	ldi 	R20, LIMIT
	ldi 	R21, ZERO		; Register for delay extension multiplier counter
	ldi 	R22, REPS		; Multiplier value stored in R22

DLOOP:
	inc 	R18		; Increment counter register
	lds 	TMP, PORTF_IN
	sbrs	TMP, 3		; If button is pressed, check win conditions
	rjmp	CHECK
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
	lds 	TMP, PORTF_IN
	sbrs	TMP, 3		; If button is pressed, check win conditions
	rjmp	CHECK
	cpi 	R19, DELAY	; counter check
	breq 	XLOOP		; Each increment will execute 771 instructions. 19998/771 ~= 26, so this entire loop
					; should execute 26 times. The end result will be marginally identical to 10 ms
	ldi 	R18, ZERO
	rjmp 	DLOOP

XLOOP:
	inc 	R21
	lds	TMP, PORTF_IN
	sbrs	TMP, 3		; If button is pressed, check win conditions
	rjmp	CHECK
	cp 	R21, R22	; Jump to end if delay is complete
	breq 	END
	ldi 	R18, ZERO
	ldi 	R19, ZERO
	rjmp 	DLOOP
END:
	ldi 	R18, ZERO
	ldi 	R19, ZERO
	ldi 	R21, ZERO
	rjmp 	RE		; Return to game code
	
