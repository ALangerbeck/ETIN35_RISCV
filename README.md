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

- R-format
	- add
- I-format
	- addi - add immideate
	- slti - set if less than immediate
	- sltiu - set if less than immediate unsigned - some questions about this one
	- LW - load word
- B-format
	- beq - branch if equal
- S-format
	- SW - store word
