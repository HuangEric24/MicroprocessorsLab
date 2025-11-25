#include <xc.inc>

; =====================================================
; 32-entry sine table (0?255) for 8-bit DAC
; =====================================================
psect udata_acs
sine_index:    DS 1
phase_step:    DS 1

psect romdata
sine_table:
    DB 128,152,176,197,216,231,242,248
    DB 248,242,231,216,197,176,152,128
    DB 104,80, 59, 40, 25, 14, 8,  8
    DB 14, 25, 40, 59, 80,104,128,128

; =====================================================
; Main Code
; =====================================================
psect code
    global main
    
main:
    goto start

; =====================================================
; Interrupt Vector
; =====================================================
psect intcode
    goto ISR

; =====================================================
; Startup Code
; =====================================================
psect code
start:
    ; PORTJ = output
    clrf TRISJ, ACCESS
    clrf PORTJ, ACCESS
    
    ; init state variables
    clrf sine_index, ACCESS
    
    ; ---- choose note here ----
    movlw 0x02        ; = DO (C4) ~262 Hz
    movwf phase_step, ACCESS
    ; movlw 0x02      ; = RE (D4) ~294 Hz
    ; movlw 0x03      ; = MI (E4) ~330 Hz
    ; movlw 0x04      ; = LA (A4) ~440 Hz
    ; --------------------------
    
    ; === Setup Timer2 for 20 kHz ISR ===
    ; Assuming 8 MHz oscillator with PLL (32 MHz)
    ; Timer2: Postscale=1, Prescale=16, PR2=99
    ; Interrupt rate = 32MHz / (4 * 16 * 100) = 5 kHz
    movlw b'01111111'    ; postscale 1:16, TMR2 ON, prescale 1:16
    movwf T2CON, ACCESS
    
    movlw .99
    movwf PR2, ACCESS
    
    ; Enable interrupts
    bsf PIE1, TMR2IE, ACCESS
    bsf INTCON, PEIE, ACCESS
    bsf INTCON, GIE, ACCESS
    
loop:
    bra loop

; =====================================================
; Interrupt: output next sine sample
; =====================================================
ISR:
    ; clear interrupt flag
    bcf PIR1, TMR2IF, ACCESS
    
    ; fetch sample from sine table
    movf sine_index, W, ACCESS
    lfsr FSR0, sine_table    ; Load address of sine_table into FSR0
    movf PLUSW0, W           ; Get byte at sine_table + W
    movwf PORTJ, ACCESS      ; send to DAC
    
    ; increment index by phase_step
    movf phase_step, W, ACCESS
    addwf sine_index, F, ACCESS
    
    ; mask to 32 entries (0-31)
    movlw 0x1F
    andwf sine_index, F, ACCESS
    
    retfie FAST

END main



