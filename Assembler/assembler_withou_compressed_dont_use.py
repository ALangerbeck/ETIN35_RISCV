from cProfile import label
import opcode
from os import remove
import string
import sys
from tabnanny import check

from nbformat import write
from risc_v_32_constants import memonicToFunct                                          
import risc_v_32_constants as constants
from textwrap import wrap

lines, lineinfo, lineadr, labels, empty = [], [], [], {}, []
LINEINFO_NONE, LINEINFO_ORG, LINEINFO_BEGIN, LINEINFO_END	= 0x00000, 0x10000, 0x20000, 0x40000
DEBUG = True


if len(sys.argv) < 2: print('USAGE: asm.py <sourcefile> [-s[<tag>]]'); exit(1)

try: f = open(sys.argv[1], 'r')                     # read in the source line WITHOUT #include function
except: print("ERROR: Can't find file \'" + sys.argv[1] + "\'."); exit(1)
while True:
    line = f.readline()
    if not line: break
    lines.append(line.strip())                      # store each line without leading/trailing whitespaces
f.close()


for i in range(len(lines)):                         # PASS 1: do PER LINE replacements
    while(lines[i].find('\'') != -1):               # replace '...' occurances with corresponding ASCII code(s)
        k = lines[i].find('\'')
        l = lines[i].find('\'', k+1)
        if k != -1 and l != -1:
            replaced = ''
            for c in lines[i][k+1:l]: replaced += str(ord(c)) + ' '
            lines[i] = lines[i][0:k] + replaced + lines[i][l+1:]
        else: break

    if (lines[i].find(';') != -1): lines[i] = lines[i][0:lines[i].find(';')]    # delete comments
    lines[i] = lines[i].replace(',', ' ')                                       # replace commas with spaces

    if lines[i].find(':') != -1:
        labels[lines[i][:lines[i].find(':')]] = i   # put label with it's line number into dictionary
        lines[i] = lines[i][lines[i].find(':')+1:]  # cut out the label

    lines[i] = lines[i].split()                     # now split line into list of bytes (omitting whitepaces)

    #makeing sure to remove line that is left after lone comment or label
    if bool(lines[i]) : lineinfo.append(lines[i][0])
    else: empty.append(i)

    for j in range(len(lines[i])-1, -1, -1):        # iterate from back to front while inserting stuff
        try: 
            lines[i][j] = constants.opcodes[lines[i][j]]     # try replacing mnemonic with opcode
        except: 
            if lines[i][j].find('0x') == 0 and len(lines[i][j]) > 4:    # replace '0xWORD' with 'LSB MSB'
                val = int(lines[i][j], 16)
                lines[i][j] = str(val & 0xff)
                lines[i].insert(j+1, str((val>>8) & 0xff))

        
## delete empty lines  and adjusting labels##
iter = 0
for i in empty:
   del lines[i - iter]
   iter = iter + 1
   for key in labels:
       if labels[key] > i:
           labels[key] = labels[key] - 1
   
if DEBUG :
    print("Lines, lineinfo and labels before line parsing")
    print(lines)
    print(lineinfo)
    print(labels)

########################### catering to specific intructions ###########################################
for i in range(len(lines)):
    opcode = lines[i][0]
    ### integer instruction ###
    
    if opcode == '0010011' or opcode == '0000011':
        if(len(lines[i]) != 4 ):
           raise Exception("Expecting 3 arguments for " + lineinfo[i] + " around line " + str(i+1))
        rd = "{:05b}".format(int(lines[i][1]))
        funct = constants.memonicToFunct[lineinfo[i]]
        rs1 = "{:05b}".format(int(lines[i][2]))
        imm ="{:012b}".format(int(lines[i][3]) & 0b111111111111)
        lines[i] = [opcode,rd,funct,rs1,imm]
    ### Register instructions ###
    elif opcode == '0110011':
        if(len(lines[i]) != 4 ):
            raise Exception("Expecting 3 arguments for " + lineinfo[i] + " around line " + str(i+1))
        lines[i][1]
        rd = "{:05b}".format(int(lines[i][1]))
        rs1 = "{:05b}".format(int(lines[i][2]))
        rs2 = "{:05b}".format(int(lines[i][3]))
        funct = constants.memonicToFunct[lineinfo[i]]
        imm = constants.memonicToImm[lineinfo[i]]
        lines[i] = [opcode,rd,funct,rs1,rs2,imm]
    ### store instructions ###
    elif opcode == '0100011':
        if(len(lines[i]) != 4 ):
            raise Exception("Expecting 3 arguments for " + lineinfo[i] + " around line " + str(i+1))
        funct = constants.memonicToFunct[lineinfo[i]]
        rs1 = "{:05b}".format(int(lines[i][1]))
        rs2 = "{:05b}".format(int(lines[i][2]))
        imm = "{:012b}".format(int(lines[i][3]) & 0b111111111111)
        imm3125 = imm[0:7]
        imm117 = imm[7:]
        lines[i] = [opcode,imm117,funct,rs1,rs2,imm3125]
    ### Branch instructions ###
    elif opcode == '1100011':
        if(len(lines[i]) != 4 ):
            raise Exception("Expecting 3 arguments for " + lineinfo[i] + " around line " + str(i+1))
        label = lines[i][3]
        if label not in labels:
            raise Exception("Label " + label + " around line " + str(i+1) + " is not recognized")
        lineDist = i - labels[label]
        #print(lineDist)
        relativeLineAdress = 0;
        linechecker = i;
        while linechecker != labels[label]:
            if lineDist > 0:
                if lineinfo[linechecker - 1][0] == 'C':
                    relativeLineAdress = relativeLineAdress - 2
                else:
                    relativeLineAdress = relativeLineAdress - 4
                linechecker = linechecker - 1
            if lineDist < 0:
                if lineinfo[linechecker + 1][0] == 'C':
                    relativeLineAdress = relativeLineAdress + 2
                else:
                    relativeLineAdress = relativeLineAdress + 4
                linechecker = linechecker + 1

        imm = "{:013b}".format(int(relativeLineAdress) & 0b1111111111111)
        rs1 = "{:05b}".format(int(lines[i][1]))
        rs2 = "{:05b}".format(int(lines[i][2]))
        imm117 = imm[8:12] + imm[1] 
        imm3125 = imm[0] + (imm[2:8])
        funct = constants.memonicToFunct[lineinfo[i]]
        lines[i] = [opcode,imm117,funct,rs1,rs2,imm3125]
    else:
        raise Exception( lineinfo[i] + " around line " + str(i+1) +" cannot be parsed either something is wrong or the command is not yet implemented")    
    
    ### concatenating the instruction into one sting ###
    if (DEBUG) : print(lines[i])
    
    lines[i].reverse()
    concat_string = ""
    for inst in lines[i]:
        concat_string =  concat_string + inst
    lines[i] = concat_string
    if(len(lines[i]) != 32): Exception("Line " + str(i) + " is the wrong number of bits")    
    
    lines[i] = wrap(lines[i],8)
    lines[i].reverse()
    lines[i] = [element + "\n" for element in lines[i]]
    if i == max(range(len(lines))):
        lines[i][len(lines[i]) - 1] = lines[i][len(lines[i]) - 1][:-1]

with open('output.mem', 'w') as f:
    for line in lines:
        f.writelines(line)

if DEBUG:
    print("Lines, lineinfo and labels after being worked on")
    print(lines)
    print(lineinfo)
    print(labels)

print("Assebled instruction successfully into output.mem")