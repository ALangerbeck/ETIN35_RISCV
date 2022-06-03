# ETIN35_RISCV

## Description

Project repository for the second project in the course IC-Project 1 given at LTH spting 2022

## Assebmler

Run assembler with  

	python .\assembler_with_compressed.py <assebly code file> 

this will output a output.mem in the same directory

## Still to be tested
	- none
## Currently implemented instructions

- R-format - performs register to register operations
	- add - rtr addition
	- sub - rtr subtraction
	- sll - shift left logical, shift rs1 left by rs2 bit positions, only looks at the five lsb of rs2.
	- slt - set if less than, compares rs1 to rs2 and sets rd as 1 if rs1 is smaller. 
	- sltu - set if less than unsigned
	- xor - bitwise logical xor operator
	- srl - shift right logical
	- sra - shift right arithmetical
	- or - bitwise logical or operator
	- and - bitwise logical and operation
- I-format
	- addi - add immideate
	- slti - set if less than immediate
	- sltiu - set if less than immediate unsigned - some questions about this one
	- xori - bitwise logical xor operator
	- ori - bitwise logical or operator
	- andi - bitwise logical and operator
	- slli - shift left logical immediate
	- srli - shift right logical immediate
	- srai - shift right arithmetic immediate
	- LW - load word
- B-format
	- beq - branch if equal
	- bne - branch if not equal 
	- blt - branch if less than - if rg1 is less than rg2 
	- bge - branch if greater than or equal 
	- bltu - branch if less than or equal unsigned
	- bgeu - branch if greater than unsigned
- S-format
	- SW - store word
- Compressed instructions 
	- c.LW - expands rd, uimm(rs1') where rd = 8+rd' and rs1=8+rs1'
		     and uimm is basically shifted two to the left before 
			 being turned into imm. 
	- c.SW - expands sw rs2, uimm(rs1) where rs2 = 8+rs2' and rs1 = 8+rs1'
	- c.ADD - expand to add rd,rd,rs2 
	- c.ADDI - expand to addi rd, rd, imm with a sign extended 6 bit immediate
	- c.SUB - expand sub rd. rd, rs2 where rd=8+rd' and rs2=8+rs2'
	- c.AND - expands to and rd, rd, rs2 where rd=8+rd' and rs2=8+rs2'
	- c.ANDI - expands to andi rd, rd, imm where rd=8+rd'
	- c.OR - expands to or rd, rd, rs2, rd=8+rd' rs2=8+rs2'
	- c.XOR - expands to xor, rd, rd, rs2 where rd=8+rd' and rs2=rs2=8+rs2'
	- c.MV - expands to add rd, x0, rs2 Invalid when rs2=0
	- c.LI - expands to addi rd, x0, imm
	- c.LUI - do later after ordinary lui
	- c.SLLI - shift left logical immediate expands to slli rd, rd, uimm
	- c.SRAI - shift right arithmetuc immediate. expands to srai rd, rd, uimm 
	           where rd=8+rd'
	- c.SRLI - shift right logical immediate, expands to srli rd, rd, uimm 
	           where rd=8+rd'
	- c.nop - used for unkown instruction.
