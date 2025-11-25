; Musical Notes Generator for EasyPIC Pro v7
; Generates Do, Re, Mi, Fa, Sol, La, Si using sine wave approximation
; Output: Port J -> DAC -> Op-Amp -> 8-ohm speaker

#include <xc.inc>

; Memory allocation
psect udata_acs
note_index:     ds 1    ; Current note being played
sample_index:   ds 1    ; Current position in sine wave table
delay_counter1: ds 1    ; Delay counter for timing
delay_counter2: ds 1    ; Delay counter for timing

psect code, abs

; Sine wave lookup table (32 samples, 8-bit, 0-255 range)
; This creates a smooth sine wave for musical quality
org 0x200
sine_table:
    db 128, 152, 176, 198, 217, 233, 245, 252
    db 255, 252, 245, 233, 217, 198, 176, 152
    db 128, 103, 79, 57, 38, 22, 10, 3
    db 0, 3, 10, 22, 38, 57, 79, 103

; Delay values for each note (controls frequency)
; Smaller values = higher frequency = higher pitch
org 0x220
delay_table:
    db 119  ; Do (C4) - 261.63 Hz
    db 106  ; Re (D4) - 293.66 Hz
    db 95   ; Mi (E4) - 329.63 Hz
    db 89   ; Fa (F4) - 349.23 Hz
    db 79   ; Sol (G4) - 392.00 Hz
    db 71   ; La (A4) - 440.00 Hz
    db 63   ; Si (B4) - 493.88 Hz

org 0x0
    goto start

org 0x100
start:
    ; Initialize Port J as output
    movlw   0x0
    movwf   TRISJ, A        ; Port J all outputs
    
    ; Initialize variables
    clrf    note_index, A
    clrf    sample_index, A
    
play_scale:
    ; Play each note for a duration
    movlw   7               ; Number of notes
    cpfslt  note_index, A   ; Check if we've played all notes
    goto    reset_scale
    
    ; Play current note for ~500ms
    movlw   200             ; Duration counter (adjust for longer/shorter notes)
    movwf   delay_counter2, A
    
play_note:
    ; Get current sine wave sample
    movlw   LOW(sine_table)
    addwf   sample_index, W, A
    movwf   TBLPTRL, A
    movlw   HIGH(sine_table)
    movwf   TBLPTRH, A
    clrf    TBLPTRU, A
    
    tblrd*                  ; Read sine value
    movff   TABLAT, PORTJ   ; Output to DAC
    
    ; Get delay value for current note
    movlw   LOW(delay_table)
    addwf   note_index, W, A
    movwf   TBLPTRL, A
    movlw   HIGH(delay_table)
    movwf   TBLPTRH, A
    
    tblrd*                  ; Read delay value
    movff   TABLAT, delay_counter1
    
    ; Delay based on note frequency
    call    note_delay
    
    ; Move to next sample in sine wave
    incf    sample_index, F, A
    movlw   32              ; 32 samples per cycle
    cpfslt  sample_index, A
    clrf    sample_index, A ; Wrap around
    
    ; Check if note duration complete
    decfsz  delay_counter2, F, A
    goto    play_note
    
    ; Move to next note
    incf    note_index, F, A
    goto    play_scale

reset_scale:
    clrf    note_index, A
    goto    play_scale

; Delay routine - determines note frequency
note_delay:
    movf    delay_counter1, W, A
delay_loop:
    nop
    nop
    nop
    decfsz  WREG, W, A
    goto    delay_loop
    return

end main