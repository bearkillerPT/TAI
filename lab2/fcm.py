import sys
from collections import defaultdict
import math

class FCM:

    def __init__(self, k, a, textFile):
        self.k = k
        self.a = a
        self.textFile = textFile

        self.sizeAlphabet = 0
        self.contextTable = defaultdict(lambda: defaultdict(int))
        self.createContext()

    def createContext(self):
        context = ""
        textFile = open(self.textFile,"r")
        
        for line in textFile:
            for char in line:
                if len(context) == (self.k):
                    self.addToTable(context, char)
                    context = context[1:] + char
                    continue
                context += char

    def addToTable(self,context,next_char):
        self.contextTable[context][next_char] += 1
        self.contextTable[context]["total"] += 1


if __name__ == "__main__":
    if len(sys.argv) == 4:
        fcm = FCM(int(sys.argv[1]),float(sys.argv[2]), sys.argv[3])
    else:
        print("The program show be called like this: \n\tpython3 fcm.py k_order a filename")

        
