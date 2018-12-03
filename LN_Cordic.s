@ Calculates natural log of number x. Stored in R2


@ ln holds Natural log of 32, 16, 8, 4, 2, 1, 3/2, 5/4, 9/8, 17/16, 33/32, 65/64, 129/128, 257/256
@ All values multiplied by 2^16
ln:
        .word   227130
        .word   181704
        .word   136278
        .word   90852
        .word   45426
        .word   26572
        .word   14623
        .word   7719
        .word   3973
        .word   2016
        .word   1016
        .word   510
        .word   255
@ Corresponding power of 2 to each natural log
ln2:
        .word   5
        .word   4
        .word   3
        .word   2
        .word   1
        .word   1
        .word   2
        .word   3
        .word   4
        .word   5
        .word   6
        .word   7
        .word   8

@ Test number 54
x:
        .word   3538944
main:
        str     fp, [sp, #-4]!
        add     fp, sp, #0
        sub     sp, sp, #20
        ldr     r3, vars
        ldr     r3, [r3, #0]
        mov     r2, r3, asr #9 @ divide x by 512
        ldr     r3, vars
        str     r2, [r3, #0]
        ldr     r3, vars+4
        str     r3, [fp, #-8]
        mov     r3, #0
        str     r3, [fp, #-12]
        b       for_loop_positive_powers
if:
	@ Check if x is < 1/ln [i]
        ldr     r3, vars+8
        ldr     r2, [fp, #-12]
        ldr     r3, [r3, r2, asl #2]
        rsb     r3, r3, #16
        mov     r2, #1
        mov     r2, r2, asl r3
        ldr     r3, vars
        ldr     r3, [r3, #0]
        cmp     r2, r3
        ble     increment_1

	@ Multipy x by ln2[i]
        ldr     r3, vars
        ldr     r2, [r3, #0]
        ldr     r3, vars+8
        ldr     r1, [fp, #-12]
        ldr     r3, [r3, r1, asl #2]
        mov     r2, r2, asl r3
        ldr     r3, vars
        str     r2, [r3, #0]

	@ Subtract ln[i] from y
        ldr     r3, vars+12
        ldr     r2, [fp, #-12]
        ldr     r3, [r3, r2, asl #2]
        ldr     r2, [fp, #-8]
        rsb     r3, r3, r2
        str     r3, [fp, #-8]

increment_1:
	@ Increment i in first loop
        ldr     r3, [fp, #-12]
        add     r3, r3, #1
        str     r3, [fp, #-12]

for_loop_positive_powers:
	@ Loop through natural log of positive powers of 2 i.e. ln[0 - 5]
        ldr     r3, [fp, #-12]
        cmp     r3, #4
        movgt   r3, #0
        movle   r3, #1
        and     r3, r3, #255
        cmp     r3, #0
        bne     if

	@ Exit loop
        mov     r3, #5
        str     r3, [fp, #-16]
        b       for_loop_negative_powers
negative_loop_work:

	@ Set temp = x + x*ln2[i]
        ldr     r3, vars         
        ldr     r2, [r3, #0]
        ldr     r3, vars+8	 
        ldr     r1, [fp, #-16]
        ldr     r3, [r3, r1, asl #2]
        mov     r2, r2, asr r3
        ldr     r3, vars
        ldr     r3, [r3, #0]
        add     r3, r2, r3
        str     r3, [fp, #-20]

	@ branch if temp < 2^16 i.e 1
        ldr     r2, [fp, #-20]
        ldr     r3, vars+16
        cmp     r2, r3
        bgt     increment_2

	@ Set x = temp
        ldr     r3, vars
        ldr     r2, [fp, #-20]
        str     r2, [r3, #0]

	@ subtract ln[i] from y
        ldr     r3, vars+12
        ldr     r2, [fp, #-16]
        ldr     r3, [r3, r2, asl #2]
        ldr     r2, [fp, #-8]
        rsb     r3, r3, r2
        str     r3, [fp, #-8]

increment_2:
	@ Increment i in second loop
        ldr     r3, [fp, #-16]
        add     r3, r3, #1
        str     r3, [fp, #-16]

for_loop_negative_powers:
        ldr     r3, [fp, #-16]
        cmp     r3, #12
        movgt   r3, #0
        movle   r3, #1
        and     r3, r3, #255
        cmp     r3, #0
        bne     negative_loop_work

        @ Exit loop
        mov     r0, r3
        add     sp, fp, #0
        ldmfd   sp!, {fp}
        bx      lr
vars:
        .word   x
        .word   408834
        .word   ln2
        .word   ln
        .word   65535
