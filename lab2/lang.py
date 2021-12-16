#from os import fchdir
import sys
from fcm import FCM
from math import log2

class LANG:
    
    def __init__(self,ref,target,k,a):
        self.k = int(k)
        self.a = float(a)

        self.ref = ref
        self.target = target
        
        self.refObject = self.createContext(self.ref)
        self.tarObject = self.createContext(self.target)

        self.refContext = self.refObject.contextTable
        self.tarContext = self.tarObject.contextTable

        self.tamTexto = 0
        self.bits = self.estimateTotalBits()
        self.n =self.bits / (self.tamTexto * log2(self.tarObject.sizeAlphabet))
        
        print("Bits de compressao: " + str(self.bits))
        print("Normalized: " + str(self.n))
        print(log2(self.tarObject.sizeAlphabet/2))
      
    def createContext(self,file):
        fcm_obj = FCM(self.k,self.a,file)
        return fcm_obj

    def isContextInRef(self,context):
        if context in self.refContext.keys():
            total = self.refContext[context]["total"]
        else:
            total = -1
        
        return total

    def calcBits(self,total,ni):
        divisor = total + (self.a * self.tarObject.sizeAlphabet)
        prob = (ni + self.a) / divisor
        bits = -log2(prob)
        
        return bits
    
    def goToRef(self,context,char):
        if context in self.refContext.keys():
            ni = self.refContext[context][char]
            total = self.refContext[context]["total"]
            bits = self.calcBits(total,ni)
        else:
            divisor = self.a * self.tarObject.sizeAlphabet
            prob = self.a / divisor
            bits = -log2(prob)
            
        return bits
        
    def estimateTotalBits(self):
        
        
        bits = 0
        context = ""
        textFile = open(self.target,"r")
        i = 0
        
        for line in textFile:
            for char in line:
                i +=1
                if len(context) == (self.k):
                    bits += self.goToRef(context,char)
                    context = context[1:] + char
                    continue
                context += char

        self.tamTexto = i
        return bits

if __name__ == "__main__":
    if len(sys.argv) == 5:
        lang = LANG(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
    else:
        print("The program show be called like this: \n\tpython3 lang.py referenceFile targetFile k a")