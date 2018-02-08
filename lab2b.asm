/****
 * lab2b
 * Name: Khari Ollivierre
 * Section: 1490
 * TA: Samantha Soto
 * Description: Switch control for LEDs
****/

.include "ATxmega128A1Udef.inc"

.equ ONES = 0xFF
.equ ZERO = ~ONES

.ORG 0x0000					
	rjmp MAIN				

.ORG 0x0100

MAIN:
	ldi R16, ONES
	sts PORTA_DIRCLR, R16	; Configures Port A to receive switch input
	sts PORTC_DIRSET, R16	; Configures Port C to output to LEDs
	sts PORTC_OUTSET, R16	; Turns off LEDs (active-low)
	sts PORTA_IN, PORTC_OUT ; Sets the output to the switch state
	rjmp MAIN		; Loops forever
	
	
