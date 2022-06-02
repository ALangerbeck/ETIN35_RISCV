print("3 : 15")
print("4: " + str(-15))
print("5 : ",end="")
tal = "{:032b}".format(1048576 & 0b11111111111111111111111111111111)
tal2 = tal[0:20]
tal3 = tal2 + "000000000000"
tal4 = int(tal3,2)
print(tal4)
print("6 : 19")
print("7 : " + str(-15 ^ 19))
print("8 : " + str(19 ^ 1950))
print("9 : " + str( -15 | 19) )
print("10 : " + str(19 | 1950))
print("11 : " + str( -15 & 19))
print("12 : " + str( -15 & 1950))
print("13 : ",end="") 
if (19 ^ 1950) < -15:
    print(1)
else: 
    print(0)
print("14 : ",end="")
#still 14 to 17 to be done



