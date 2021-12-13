from os import fchdir
import sys
from fcm import FCM

class LANG:
    
    def __init__(self,ref,target,k,a):
        self.k = int(k)
        self.a = float(a)

        self.ref = ref
        self.target = target

        self.refFile = open(self.ref,'r')
        self.refText = self.refFile.read() 
        self.targetFile = open(self.target,'r')
        self.targetText = self.targetFile.read()
        
        self.refContext = self.createRefContext()
        self.tarContext = self.createTarContext()
        self.bits = self.estimateBits()
      
    def createRefContext(self):
        fcm_obj = FCM(self.k,self.a,self.ref)
        return fcm_obj.context

    def createTarContext(self):
        fcm_obj = FCM(self.k,self.a,self.target)
        return fcm_obj.context


    def estimateBits(self):
        bits=0
        #i = 0
        #for key in self.tarContext.keys():
            #print(key)



        return bits


if __name__ == "__main__":
    if len(sys.argv) == 5:
        lang = LANG(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
    else:
        print("The program show be called like this: \n\tpython3 lang.py referenceFile targetFile k a")