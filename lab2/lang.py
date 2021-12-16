from os import fchdir
import sys
from fcm import FCM
from math import log2

class LANG:
    
    def __init__(self,ref,target,k,a):
        self.k = int(k)
        self.a = float(a)

        self.ref = ref
        self.target = target
        
        self.refContext = self.createContext(self.ref)

        self.tarAlphabetSize = self.getAlphabetSize(self.target)
        
        self.bits = self.estimateTotalBits()
        self.NormalizedBits = self.bitsNormalized()


    def getAlphabetSize(self,filename):
        textFile = open(filename, 'r')
        text = textFile.read()
        sizeAlphabet = len(set(text))
        
        return sizeAlphabet

    def getTextLen(self,filename):
        textFile = open(filename, 'r')
        text = textFile.read()
        textLen = len(text)

        return textLen
      
    def createContext(self,file):
        fcm_obj = FCM(self.k,self.a,file)
        return fcm_obj.contextTable

    def bitsNormalized(self):
        textLen = self.getTextLen(self.target)
        n = self.bits / (textLen * log2(self.tarAlphabetSize))

        return n

    def calcBits(self,total,ni,inContext,inSymbols):
        if inContext == True and inSymbols == True:
            divisor = total + (self.a * self.tarAlphabetSize)
            prob = (ni + self.a) / divisor
            bits = -log2(prob)
        elif inContext == True and inSymbols == False:
            divisor = total + (self.a * self.tarAlphabetSize)
            prob = self.a / divisor
            bits = -log2(prob)
        elif inContext == False and inSymbols == False:
            divisor = self.a * self.tarAlphabetSize
            prob = self.a / divisor
            bits = -log2(prob)
        
        return bits
        
    def estimateBits(self,context,char):
        if context in self.refContext.keys():
            total = self.refContext[context]["total"]
            if char not in self.refContext[context].keys():
                bits = self.calcBits(total,ni=0,inContext=True,inSymbols=False)
            else:
                ni = self.refContext[context][char]
                bits = self.calcBits(total,ni,inContext=True,inSymbols=True)
        else:
            bits = self.calcBits(total=0,ni=0,inContext=False,inSymbols=False)

        return bits

    def estimateTotalBits(self):
        bits = 0
        context = ""
        textFile = open(self.target,"r")

        for line in textFile:
            for char in line:
                if len(context) == (self.k):
                    bits += self.estimateBits(context,char)
                    context = context[1:] + char
                    continue
                context += char

        return bits

if __name__ == "__main__":
    if len(sys.argv) == 5:
        lang = LANG(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
    else:
        print("The program show be called like this: \n\tpython3 lang.py referenceFile targetFile k a")