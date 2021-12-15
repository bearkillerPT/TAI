from os import fchdir
import sys
from fcm import FCM
from math import log2
#lang
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

        self.bits = self.estimateBits()
        print("Bits de compressao: " + str(self.bits))
      
    def createContext(self,file):
        fcm_obj = FCM(self.k,self.a,file)
        return fcm_obj

    def ContextInRef(self,key):
        if key in self.refContext.keys():
            total = self.refContext[key]["total"]
        else:
            total = -1
        
        return total

    def calcBits(self,key,symbol,total):
        divisor = total + (self.a * self.tarObject.sizeAlphabet)
        prob = (self.refContext[key][symbol] + self.a) / divisor

        bits = - log2(prob)
        return bits
        
    def estimateBits(self):
        bits = 0
        for key in self.tarContext.keys():
            total = self.ContextInRef(key)
            if total != -1:
                for symbol in self.tarContext[key].keys():
                    bits += self.calcBits(key,symbol,total)
        return bits 


if __name__ == "__main__":
    if len(sys.argv) == 5:
        lang = LANG(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
    else:
        print("The program show be called like this: \n\tpython3 lang.py referenceFile targetFile k a")