#include <xc.inc>
psect code, abs
main:
    org 0x0
    goto start

    org 0x100           ; Main code starts here at address 0x100
start:
    movlw   0x0
    movwf   TRISJ, A    ; Port J all outputs

    ; Initialize registers
    ; 0x06 = current output value (0 or 255 for square wave)
    ; 0x90 = delay counter for frequency

    movlw   0xFF        ; Start with HIGH state (255)
    movwf   0x06, A

    movlw   119         ; Delay value for "Do" frequency (261.63 Hz)
    movwf   0x91, A     ; Store as reference value

loop:
    ; Output current square wave state to DAC
    movff   0x06, PORTJ

    ; Delay to control frequency
    movff   0x91, 0x90  ; Reload delay counter
    call    delay

    ; Toggle between 0 and 255 (square wave)
    movlw   0xFF
    cpfseq  0x06, A     ; If currently 255...
    bra     set_high    ; ...go to set_high

set_low:
    movlw   0x00        ; Set to LOW (0)
    movwf   0x06, A
    bra     loop

set_high:
    movlw   0xFF        ; Set to HIGH (255)
    movwf   0x06, A
    bra     loop
delay:
    decfsz  0x90, F, A
    bra     delay
    return
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    