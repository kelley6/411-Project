.text
	.global _start
_start:
	
	LDR r0, =x			@ load the memory address of x into r0
	LDR r0, [r0]			@ load the value at memory address in r0 into r0
	@Index into each table, branch to loops for that	
	@Indicate end of program execution somewhere?
	SWI 0x11
	
.sinLoop:
.cosLoop:
.sinhLoop:
.coshLoop:
.eulerLoop:

.divLoop:
.lnLoop:
.sqrtLoop:
	.data
@Value x stored as word in memory
x:	.word 1

sinTable: .byte
cosTable: .byte
sinhTable: .byte
coshTable: .byte
eulerTable: .byte

@Extra credit shit here, dunno if we need lookup tables for these
divTable: .byte
lnTable: .byte
sqrtTable: .byte
	.end
	
