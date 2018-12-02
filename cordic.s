@CMSC 411 Project
@Kelley Schmidt, Alayana Stepp, Spencer Teolis, Ian Moskunas
@Computes sine and cosine and stores them in memory

.data
@ Multiplied each number by 2^16=65536 to avoid floats

@ placeholder for where to store values in memory later
values_store:
  .skip 100

@ gainConstant = 0.6072529350
currCos:  @ x
  .int  39796

currSin:  @ y
  .int  0
  
Sine: .word 0

@ Original angles:
@   45.0, 26.565, 14.0362, 7.12502, 3.57633, 1.78991, 0.895174
@   0.447614, 0.223811, 0.111906, 0.055953, 0.027977

@ Multiply each by 2^16, arctanh angles for cordic method
angles:
  .int  2949120, 1740963, 919876, 466945, 234378, 117303, 58666
  .int  29334, 14667, 7333, 3666, 1833

@ Number of angles & iterations
iter:
  .int  12

@ Input angle z
currAngle:
  .int  4643985         @ z = 70.86159

@Begin program here

.text
main:
  LDR    R0, =iter           @ load & store number of iterations
  LDR    R2, [R0]
  SUB    R2, R2, #1          @ subtract 1 from size so we stay in bounds
  MOV    R1, #0              @ counter for for loop iterations

  LDR    R0, =currAngle      @ load & store currAngle
  LDR    R3, [R0]
  LDR    R0, =currCos        @ load & store currCos
  LDR    R4, [R0]
  LDR    R0, =currSin        @ load & store currSin
  LDR    R5, [R0]
  LDR    R0, =angles         @ load angles[] table

@ Handle simple edge cases
currAngle0:
  CMP    R3, #0              @ if currAngle = 0
  BNE    currAngle90
  MOV    R4, #1              @ currCos = 1
  MOV    R5, #0              @ currSin = 0
  MOV    R6, #0              @ tangent = 0
  B      exit

currAngle90:
  CMP    R3, #5898240        @ if currAngle = 90
  BNE    for_loop
  MOV    R4, #0              @ currCos = 0
  MOV    R5, #1              @ currSin = 1
  MOV    R6, #0              @ tangent = UNDEFINED
  B      exit

@ Back to main part of code
for_loop:
  MOV    R6, R1					
  LDR    R7, [R0, R6, LSL#2] @ get angles[i] w/ offset by shifting

  MOV    R8, R4              @ tempCos <-- currCos
  MOV    R9, R5              @ tempSin <-- currSin
  LSR    R8, R1              @ tempCos >> i
  LSR    R9, R1              @ tempSin >> i
  CMP    R3, #0              @ jump to appropriate section
  BGT    else

if:                          @ if currAngle <= 0
  ADD    R3, R3, R7          @ currAngle += angles[i]
  ADD    R4, R4, R9          @ currCos = currCos + tempSin
  SUB    R5, R5, R8          @ currSin = currSin - tempCos
  B      end_elif

else:                        @ if currAngle > 0
  SUB    R3, R3, R7          @ currAngle -= angles[i]
  SUB    R4, R4, R9          @ currCos = currCos - tempSin
  ADD    R5, R5, R8          @ currSin = currSin + tempCos

end_elif:
  ADD    R1, R1, #1          @ increment loop counter
  CMP    R1, R2              @ compare to make sure at right iteration
  BNE    for_loop

exit:
  LDR    R0, =values_store   @ store values in "array" in mem
  STR    R4, [R0] 			@cosine
  STR    R5, [R0, #4]		@sine

  SWI   0x11