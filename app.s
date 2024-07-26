.section .data
str1: .asciz "The quick brown fox jumps over the lazy dog"
format_string: .asciz "\n\nFOO: %x %x %x %x %x\n\n"

// Offsets of varaibles stored in stack from stack pointer
.equ STR_PTR, 0 
.equ CURRENT_LENGTH, 8 
.equ ORIGINAL_LENGTH, 12 
.equ WORD, 16 
.equ LOCAL_VAR_SIZE, 656 

.section .text
.global _start
_start:
    bl main
    mov x8, 93
    mov x0, xzr
    svc 0

// Main function
main:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    
    ldr x0, =str1
    bl FOO

    ldp x29, x30, [sp], 16
    ret

// Function to compute SHA-1 hash
FOO:
    stp x29, x30, [sp, -16]!
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!
    stp x23, x24, [sp, -16]!
    mov x29, sp
    sub sp, sp, LOCAL_VAR_SIZE

    // Copying str1 to a new allocated memory with 100 more size
    str x0, [sp, STR_PTR]
    bl strlen
    str w0, [sp, ORIGINAL_LENGTH]
    add x0, x0, 100 
    bl malloc
    ldr x1, [sp, STR_PTR]
    bl strcpy
    str x0, [sp, STR_PTR]

    // Preprocess the input string 
    ldr w0, [sp, ORIGINAL_LENGTH] 
    ldr x1, [sp, STR_PTR]
    add x1, x1, x0 

    mov w2, 0x80 
    strb w2, [x1]
    add x1, x1, 1 

    mov w2, wzr 
    strb w2, [x1] 

    add w0, w0, 1 
    str w0, [sp, CURRENT_LENGTH]

    // Calculate the number of padding bytes needed
    and w0, w0, 0x3F

    // Determine the value of ib
ib_56:
    cmp w0, 56
    bge ib_56_else
    mov w1, 62
    b ib_56_done
ib_56_else:
    mov w1, 126
    b ib_56_done
ib_56_done:
    sub w0, w1, w0

    // Fill str with 0x00 for ib + 6 iterations
    ldr x1, [sp, STR_PTR]
    ldr w2, [sp, CURRENT_LENGTH]
    mov w3, wzr

    mov w17, wzr
for_start:
    cmp w17, w0
    bge for_end

    add x4, x1, x2
    strb w3, [x4]
    add w2, w2, 1

    add w17, w17, 1
    b for_start
for_end:
    str w2, [sp, CURRENT_LENGTH]

    // Calculate the value to store in str
    ldr x0, [sp, STR_PTR]
    ldr w1, [sp, CURRENT_LENGTH]
    add x0, x0, x1

    ldr w2, [sp, ORIGINAL_LENGTH]
    lsl w2, w2, 3

    // Store the high byte in str
    lsr w3, w2, 8
    strb w3, [x0]
    add x0, x0, 1

    // Store the low byte in str
    and w3, w2, 0xFF
    strb w3, [x0]
    add x0, x0, 1

    // Terminate str
    mov w3, wzr
    strb w3, [x0]
    
    add w1, w1, 2
    str w1, [sp, CURRENT_LENGTH]

    // Initialize variables
    movz x19, 0x6745, lsl 16
    movk x19, 0x2301
    movz x20, 0xEFCD, lsl 16
    movk x20, 0xAB89
    movz x21, 0x98BA, lsl 16
    movk x21, 0xDCFE
    movz x22, 0x1032, lsl 16
    movk x22, 0x5476
    movz x23, 0xC3D2, lsl 16
    movk x23, 0xE1F0

    // Process each 512-bit chunk of the preprocessed input
    ldr w17, [sp, CURRENT_LENGTH]
    lsr w17, w17, 6
    
    mov w16, wzr
outer_loop_start:
    cmp w16, w17
    bge outer_loop_end

    // First inner loop
    ldr x0, [sp, STR_PTR]

    mov w15, wzr 
inner_loop_start1:
    cmp w15, 16
    bge inner_loop_end1

    // Calculate the index for str
    lsl x1, x16, 6
    add x1, x1, x15, lsl 2

    // Load the four bytes and calculate the word
    ldrb w2, [x0, x1]
    add x1, x1, 1
    ldrb w3, [x0, x1]
    add x1, x1, 1
    ldrb w4, [x0, x1]
    add x1, x1, 1
    ldrb w5, [x0, x1]

    // Add them all
    lsl x2, x2, 24
    add x2, x2, x3, lsl 16
    add x2, x2, x4, lsl 8
    add x2, x2, x5

    // NOTE: I did this so that this app, outputs exactly like the FOO.c
    //       but in fact FOO.c is not working as it should be!
    //       to fix this problem
    //       we should cast the right hand side of the `=` oprator in FOO.c:54 to be unsigned
    //       with that, FOO.c will be working as it was intended to
    //       and we can comment out `sxtw x2, w2`
    sxtw x2, w2

    // Store in word[j]
    add x10, xzr, x15, lsl 3
    add x10, x10, WORD
    str x2, [sp, x10]

    add w15, w15, 1 
    b inner_loop_start1
inner_loop_end1:

    // Second inner loop
    mov w15, 16
inner_loop_start2:
    cmp w15, 80
    bge inner_loop_end2

    add x10, xzr, x15, lsl 3
    add x10, x10, WORD

    sub x11, x10, 24
    ldr x0, [sp, x11]

    sub x11, x10, 64
    ldr x1, [sp, x11]
    
    eor x0, x0, x1

    sub x11, x10, 112
    ldr x1, [sp, x11]

    eor x0, x0, x1

    sub x11, x10, 128
    ldr x1, [sp, x11]

    eor x0, x0, x1

    // Rotateleft the result by 1
    mov x1, x0
    lsl x0, x0, 1
    lsr x1, x1, 31
    orr x0, x0, x1

    // Store in word[j]
    str x0, [sp, x10]

    add w15, w15, 1
    b inner_loop_start2
inner_loop_end2:

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, x23

    // Main loop
    mov w14, wzr
main_loop_start:
    cmp w14, 80
    bge main_loop_end

m_20:
    cmp w14, 20
    bge m_40
    and x10, x1, x2
    mvn x11, x1
    and x11, x11, x3
    orr x5, x10, x11
    movz x6, 0x5A82, lsl 16
    movk x6, 0x7999
    b m_done
m_40:
    cmp w14, 40
    bge m_60
    eor x5, x1, x2
    eor x5, x5, x3
    movz x6, 0x6ED9, lsl 16
    movk x6, 0xEBA1
    b m_done
m_60:
    cmp w14, 60
    bge m_else
    and x10, x1, x2
    and x11, x1, x3
    and x12, x2, x3
    orr x5, x10, x11
    orr x5, x5, x12
    movz x6, 0x8F1B, lsl 16
    movk x6, 0xBCDC
    b m_done
m_else:
    eor x5, x1, x2
    eor x5, x5, x3
    movz x6, 0xCA62, lsl 16
    movk x6, 0xC1D6
    b m_done
m_done:

    // temp = rotateleft(a, 5)
    mov x10, x0
    mov x11, x10
    lsl x10, x10, 5
    lsr x11, x11, 27
    orr x7, x10, x11

    // temp = temp + f + e + k
    add x7, x7, x4
    add x7, x7, x5
    add x7, x7, x6

    // temp = temp + word[m]
    add x10, xzr, x14, lsl 3
    add x10, x10, WORD
    ldr x11, [sp, x10]
    add x7, x7, x11

    // temp = temp & 0xFFFFFFFF
    and x7, x7, 0xFFFFFFFF

    mov x4, x3
    mov x3, x2

    // c = rotateleft(b, 30);
    mov x10, x1
    mov x11, x10
    lsl x10, x10, 30
    lsr x11, x11, 2
    orr x2, x10, x11

    mov x1, x0
    mov x0, x7

    add w14, w14, 1
    b main_loop_start
main_loop_end:

    add x19, x19, x0
    add x20, x20, x1
    add x21, x21, x2
    add x22, x22, x3
    add x23, x23, x4

    add w16, w16, 1
    b outer_loop_start
outer_loop_end: 

    // Print the final hash value
    ldr x0, =format_string
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x22
    mov x5, x23
    bl printf

    add sp, sp, LOCAL_VAR_SIZE
    ldp x23, x24, [sp], 16
    ldp x21, x22, [sp], 16
    ldp x19, x20, [sp], 16
    ldp x29, x30, [sp], 16
    ret
