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

        print("Absolute Compression bits: " + str(self.bits))
        print("Normalized Bits: ", str(self.NormalizedBits))


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

    def calcBits(self,total,ni):
        divisor = total + (self.a * self.tarAlphabetSize)
        prob = (ni + self.a) / divisor
        bits = -log2(prob)
        
        return bits
        
    def estimateBits(self,context,char):
        if context in self.refContext.keys():
            ni = self.refContext[context][char]
            total = self.refContext[context]["total"]
            bits = self.calcBits(total,ni)
        else:
            divisor = self.a * self.tarAlphabetSize
            prob = self.a / divisor
            bits = -log2(prob)

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