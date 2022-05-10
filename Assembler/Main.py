import sys                                          
import risc_v_32_constatns

lines, lineinfo, lineadr, labels = [], [], [], {}
LINEINFO_NONE, LINEINFO_ORG, LINEINFO_BEGIN, LINEINFO_END	= 0x00000, 0x10000, 0x20000, 0x40000


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

    """
    # if there are special lines for formatting etc
    lineinfo.append(LINEINFO_NONE)                  # generate a separate lineinfo
    if lines[i].find('#begin') != -1:
        lineinfo[i] |= LINEINFO_BEGIN
        lines[i] = lines[i].replace('#begin', '')
    if lines[i].find('#end') != -1:
        lineinfo[i] |= LINEINFO_END
        lines[i] = lines[i].replace('#end', '')
    k = lines[i].find('#org')
    if (k != -1):        
        s = lines[i][k:].split(); rest = ""         # split from #org onwards
        lineinfo[i] |= LINEINFO_ORG + int(s[1], 0)  # use element after #org as origin address
        for el in s[2:]: rest += " " + el
        lines[i] = (lines[i][0:k] + rest).strip()   # join everything before and after the #org ... statement
    """
    if lines[i].find(':') != -1:
        labels[lines[i][:lines[i].find(':')]] = i   # put label with it's line number into dictionary
        lines[i] = lines[i][lines[i].find(':')+1:]  # cut out the label

    lines[i] = lines[i].split()                     # now split line into list of bytes (omitting whitepaces)

    for j in range(len(lines[i])-1, -1, -1):        # iterate from back to front while inserting stuff
        try: lines[i][j] = opCodes[lines[i][j]]     # try replacing mnemonic with opcode
        except: 
            if lines[i][j].find('0x') == 0 and len(lines[i][j]) > 4:    # replace '0xWORD' with 'LSB MSB'
                val = int(lines[i][j], 16)
                lines[i][j] = str(val & 0xff)
                lines[i].insert(j+1, str((val>>8) & 0xff))


print(lines)
print(lineinfo)
print(line)
print(labels)
