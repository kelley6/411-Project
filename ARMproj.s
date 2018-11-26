.text
	.global _start
_start:
	@Load value x from memory
	LDR r0, =x
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
	
