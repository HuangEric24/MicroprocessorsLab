	#include <xc.inc>

psect	code, abs
	
data_out	EQU 0x06 
temp	        EQU 0x90 
delay_number	EQU 0x91  
loop_number     EQU 0x92
counter_low     EQU 0x93 	
counter_high    EQU 0x94 	

main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 	0x0
	movwf	TRISJ, A
	movlw   0x00
	movwf   counter
	movlw   0x7F
	movwf   loop_number ; 7F = 128 loop
	movlw   0x10
	movwf   temp; Port C all outputs
	movwf   delay_number   ;original
	bra 	loop_high
loop_high:
	movlw 	0xFF
	movwf   data_out
	movff 	data_out, PORTJ
	call    delay
	movff   delay_number, temp
	incf    counter_high, F
	movf    counter_high, W      ; W = counter
	cpfsgt  loop_number         ; skip if counter > loop number
	bra     test_high
	bra     loop_low
loop_low:
	movlw 	0x00
	movff 	data_out, PORTJ
	call    delay
	movff   delay_number, temp
	incf    counter_low, F
	movf    counter_low, W      ; W = counter
	cpfsgt  loop_number         ; skip if counter > loop number
	bra     test_low
	goto    0x0
	

delay:
        decfsz  delay_number
	bra     delay
	return
        end	main
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    