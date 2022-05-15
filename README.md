# ETIN35_RISCV

## Description

Project repository for the second project in the course IC-Project 1 given at LTH spting 2022

## Todo

- [ ] RISC-V implementation
  - [ ] Implementing stages
  - [ ] VHD Test bench
  - [ ] Implement instruction
    - [ ] RV32I
      - [ ] Shifts
      - [ ] Aritmetic
      - [ ] Logical
      - [ ] Comapre
      - [ ] Branch
    - [ ] RV32C
      - [ ] Loads
      - [ ] Stores
      - [ ] extra: floating point rellated
    - [ ] extra: RV32f
- [x] Import Massoud's Auxiliaries
- [ ] Extra :Assembler Extension

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
	- bne
	- blt
	- bge
	- bltu
	- bgeu
- S-format
	- SW - store word
