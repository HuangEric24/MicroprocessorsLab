#include <xc.inc>
psect	code
	
data_out	EQU 0x95 
temp	        EQU 0x90 
delay_number	EQU 0x91  
index           EQU 0x92
counter_low     EQU 0x93 	
counter_high    EQU 0x94 	

; Sine table with 256 samples
	; Values scaled for 8-bit DAC (0-255)
	; Reference: 2.5V, so 0V=0, 1.25V=128, 2.5V=255
	psect sine_tbl,class=CODE,delta=1,abs
	org 0x300
sine_table_data:
	db   128, 131, 134, 137, 140, 143, 146, 149  ; 0-7
	db   152, 155, 158, 162, 165, 167, 170, 173  ; 8-15
	db   176, 179, 182, 185, 188, 190, 193, 196  ; 16-23
	db   198, 201, 203, 206, 208, 211, 213, 215  ; 24-31
	db   218, 220, 222, 224, 226, 228, 230, 232  ; 32-39
	db   234, 235, 237, 238, 240, 241, 243, 244  ; 40-47
	db   245, 246, 248, 249, 250, 250, 251, 252  ; 48-55
	db   253, 253, 254, 254, 254, 255, 255, 255  ; 56-63
	db   255, 255, 255, 255, 254, 254, 254, 253  ; 64-71 (peak)
	db   253, 252, 251, 250, 250, 249, 248, 246  ; 72-79
	db   245, 244, 243, 241, 240, 238, 237, 235  ; 80-87
	db   234, 232, 230, 228, 226, 224, 222, 220  ; 88-95
	db   218, 215, 213, 211, 208, 206, 203, 201  ; 96-103
	db   198, 196, 193, 190, 188, 185, 182, 179  ; 104-111
	db   176, 173, 170, 167, 165, 162, 158, 155  ; 112-119
	db   152, 149, 146, 143, 140, 137, 134, 131  ; 120-127
	db   128, 124, 121, 118, 115, 112, 109, 106  ; 128-135 (center)
	db   103, 100, 97, 93, 90, 88, 85, 82        ; 136-143
	db   79, 76, 73, 70, 67, 65, 62, 59          ; 144-151
	db   57, 54, 52, 49, 47, 44, 42, 40          ; 152-159
	db   37, 35, 33, 31, 29, 27, 25, 23          ; 160-167
	db   21, 20, 18, 17, 15, 14, 12, 11          ; 168-175
	db   10, 9, 7, 6, 5, 5, 4, 3                 ; 176-183
	db   2, 2, 1, 1, 1, 0, 0, 0                  ; 184-191
	db   0, 0, 0, 0, 1, 1, 1, 2                  ; 192-199 (bottom)
	db   2, 3, 4, 5, 5, 6, 7, 9                  ; 200-207
	db   10, 11, 12, 14, 15, 17, 18, 20          ; 208-215
	db   21, 23, 25, 27, 29, 31, 33, 35          ; 216-223
	db   37, 40, 42, 44, 47, 49, 52, 54          ; 224-231
	db   57, 59, 62, 65, 67, 70, 73, 76          ; 232-239
	db   79, 82, 85, 88, 90, 93, 97, 100         ; 240-247
	db   103, 106, 109, 112, 115, 118, 121, 124  ; 248-255
    
    
    
main:
	org	0x0
	goto	start
	org	0x100		    ; Main code starts here at address 0x100
	
	
start:
	movlw 	0x0
	movwf	TRISJ, A        ; Port J all outputs
	movlw   30
	movwf   delay_number    ; Delay value (adjust for frequency)
	movlw   0
	movwf   index           ; Initialize sine table index
	bra 	sine_loop

sine_loop:
	; Get sine value from table
	movf    index, W
	call    sine_table
	movwf   data_out
	; Output to port
	movff   data_out, PORTJ
	; Delay
	call    delay
	; Increment index (will automatically wrap from 255 to 0)
	incf    index, F
	bra     sine_loop

delay:        
	movff   delay_number, temp
delay_loop:
	decfsz  temp, F
	bra     delay_loop
	return

; Sine table lookup routine
sine_table:	
	movwf   temp            ; Save W (index)
	movlw   high(sine_table_data)
	movwf   TBLPTRH
	movlw   low(sine_table_data)
	movwf   TBLPTRL
	movlw   low highword(sine_table_data)
	movwf   TBLPTRU
	movf    temp, W           ; Restore index
	addwf   TBLPTRL, F       ; Add index to table pointer
	movlw   0
	addwfc  TBLPTRH, F       ; Handle carry
	TBLRD*                       ; Read from table
	movf    TABLAT, W        ; Get byte into W
	return

	

	end	main