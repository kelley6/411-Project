@ cosh(x) will be in R0 (in radians)
@ sinh(x) will be in R1 (in radians)
@ e^x will be in 	 R2
@ cos(x) will be in  R4 (in degrees)
@ sin(x) will be in  R5 (in degrees)

.data
@ placeholder for where to store values in memory later
values_store:
  .skip 100

@ gainConstant = 0.6072529350
currCos:  @ x
  .int  39796

currSin:  @ y
  .int  0

@ original angles to be used (then will scale w/ 2^16):
@   45.0, 26.565, 14.0362, 7.12502, 3.57633, 1.78991, 0.895174
@   0.447614, 0.223811, 0.111906, 0.055953, 0.027977
angles:
  .int  2949120, 1740963, 919876, 466945, 234378, 117303, 58666
  .int  29334, 14667, 7333, 3666, 1833

@ number of angles & iterations
iter:
  .int  12

@ test angle for cos() and sin(), z
currAngle:
  .int  4325376         	@ z = 66

.text
main:
  LDR    R0, =iter          @ load & store number of iterations
  LDR    R2, [R0]
  SUB    R2, R2, #1         @ size - 1 to not go out-of-bounds
  MOV    R1, #0             @ for-loop counter, i

  LDR    R0, =currAngle     @ load & store currAngle
  LDR    R3, [R0]
  LDR    R0, =currCos       @ load & store currCos
  LDR    R4, [R0]
  LDR    R0, =currSin       @ load & store currSin
  LDR    R5, [R0]
  LDR    R0, =angles        @ load angles[]

@ handle edge cases
currAngle0:
  CMP    R3, #0             @ if currAngle = 0
  BNE    currAngle90
  MOV    R4, #1             @ currCos = 1
  MOV    R5, #0             @ currSin = 0
  MOV    R6, #0             @ tangent = 0
  B      exit

currAngle90:
  CMP    R3, #5898240       @ if currAngle = 90
  BNE    for_loop
  MOV    R4, #0             @ currCos = 0
  MOV    R5, #1             @ currSin = 1
  MOV    R6, #0             @ tangent = UNDEFINED
  B      exit

@ back to main part of code
for_loop:
  MOV    R6 , R1
  LDR    R7 , [R0, R6, LSL#2] @ get angles[i] w/ offset

  MOV    R8 , R4            @ tempCos <-- currCos
  MOV    R9 , R5            @ tempSin <-- currSin
  LSR    R8 , R1            @ tempCos >> i
  LSR    R9 , R1            @ tempSin >> i
  CMP    R3 , #0            @ jump to appropriate section
  BGT    else

if:                         @ if currAngle <= 0
  ADD    R3 , R3 , R7       @ currAngle += angles[i]
  ADD    R4 , R4 , R9       @ currCos = currCos + tempSin
  SUB    R5 , R5 , R8       @ currSin = currSin - tempCos
  B      end_elif

else:                		@ if currAngle > 0
  SUB    R3 , R3 , R7       @ currAngle -= angles[i]
  SUB    R4 , R4 , R9       @ currCos = currCos - tempSin
  ADD    R5 , R5 , R8     	@ currSin = currSin + tempCos

end_elif:
  ADD    R1 , R1, #1     	@ increment loop counter
  CMP    R1 , R2        	@ compare to make sure at right iteration
  BNE    for_loop

next:
  CMP    R1 , R2       		@ carry set if R1 > R2
  SUBCS  R1 , R1 , R2       @ R1 - R2, if it would give a positive answer
  ADDCS  R6 , R6 , R3       @ add the current bit in R3 to accumulating answer in R6

  MOVS   R3 , R3 , LSR #1   @ shift R3 right into carry flag
  MOVCC  R2 , R2 , LSR #1   @ if R3 bit0 = 0, shift R2 right
  BCC    next               @ if carry not clear, R3 shifted back to where it started, then end

divide_end:
  MOV    R6 , R6, LSL #4    @ must shift back since initially shifting by 4 bits

@ R4 holds cos(x) , R5 holds sin(x)
exit:
  LDR    R0 , =values_store @ store values in "array" in mem
  STR    R4 , [R0]
  STR    R5 , [R0, #4]
  
hyperbolicAndE:		
	@ will do 23 iterations
	@ of cordic since mantissa of single
	@ precision float is 23 bits
	@ multiply 23 * 4 since each word in the
	@atanh table is 4 bytes and get 92 or 0x5c
	MOV R1 , #0x5C
 		
	@ initialize loop counter (i)
	MOV R2 , #0x0
	@ This counter will hold i + 1
	@ for shifting
	MOV R0 , #1
	
	LDR R12 , =zero
	LDR R12 , [R12]

	LDR R14 , =one
	LDR R14 , [R14]
	
	LDR R13 , =two
	LDR R13 , [R13]

cordic:
	@ exit when i = 92
	CMP R2 , R1	
	BEQ exitHyperbolic
	
	LDR R3 , =desired
	LDR R3 , [R3]
	
	LDR R6 , =x
	LDR R6 , [R6]
	
	LDR R10 , =y
	LDR R10 , [R10]

	@ if desired number is greater
	@ than or equal to 0, rotate clockwise,
	@ otherwise counterclockwise
	CMP R3,R12
	BGE clock_rot 	
	
	B counter_rot

@Clock wise rotation
clock_rot:

	@ y >> i+1
	MOV R7 , R10 , ASR R0
	@ x >> i+1
	MOV R8 , R6 , ASR R0
	
	@ x + (y >> i+1)
	ADD R6 , R6 , R7	
	STR R6 , x

	@ y + (x >> i+1)
	ADD R10 , R10 , R8	
	STR R10 , y

	@ load atanhtable[i]
 	LDR R9 , =atanhTable
	LDR R9 , [R9,R2]

	@ z - atanh[i]
	SUB R3 , R3 , R9	
	STR R3 , desired

	@ add 4 to i and 1 to i+1 counters
	ADD R2 , R2 , #4
	ADD R0 , R0 , #1
	B cordic

@ Counter clockwise rotation
counter_rot:
	@ y >> i
	MOV R7 , R10 , ASR R0
	@ x >> i
	MOV R8 , R6 , ASR R0 

	@ x - (y >> i+1)
	SUB R6 , R6 , R7	
	STR R6 , x

	@ y - (x >> i+1)
	SUB R10 , R10 , R8	
	STR R10 , y

	@ load atanhtable[i]
 	LDR R9 , =atanhTable
	LDR R9 , [R9,R2]

	@ z + atanh[i]
	ADD R3 , R3 , R9	
	STR R3 , desired

	@ add 4 to i and 1 to i+1 counters
	ADD R2 , R2 , #4 
	ADD R0 , R0 , #1
	B cordic
	
atanhTable:
	.word 35999
	.word 16738
	.word 8235
	.word 4101
	.word 2048
	.word 1024
	.word 512
	.word 255
	.word 127
	.word 64
	.word 31
	.word 15
	.word 7
	.word 3
	.word 2
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	
x:
	.word 79136 	@ 1.207534 * 65536
	
y:
	.word 0

@ test value for cosh() / sinh() / e^x
desired:
	.word 65536		@ 65536 -> 1 radian

zero:
	.word 0
one:
	.word 1
two:
	.word 2
gain:
	.word 65536

exitHyperbolic:

	@ cosh() is R0
	LDR R0 , =x
	LDR R0 , [R0]

	@ sinh() is R1
	LDR R1 , =y
	LDR R1 , [R1]

	@ e^x = cosh() + sinh()
	ADD R2 , R0, R1
	
	swi 0x11
.end