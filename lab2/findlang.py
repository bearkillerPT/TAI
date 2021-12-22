from lang import LANG
import sys
import os
from datetime import datetime

class FIND:
    
    def __init__(self,target,k,a):
        self.k = int(k)
        self.a = float(a)
        self.target = target

        self.referenceFiles = self.getReferenceFiles()
        self.guessLang()


    def getReferenceFiles(self):
        arr = os.listdir('./References')
        return arr

    def guessLang(self):
        langBits = {}

        #print('\n')
        #print("--------------------------------------------------------------")
        #print("------------------------TRAINING MODELS-----------------------")
        #print("--------------------------------------------------------------")

        for file in self.referenceFiles:
            filePath = 'References/'
            
            #print('Training ' + file)
            
            filePath += file
            lang_obj = LANG(filePath,self.target,self.k,self.a)
            
            
            language = file[:-4]
            langBits.update({language:lang_obj.normalizedBits})
        
        self.guessedLang = min(langBits,key=langBits.get)

        #print("--------------------------------------------------------------")
        #print("----------------------------RESULT----------------------------")
        #print("--------------------------------------------------------------")

        print('\nTHE TARGET FILE IS WRITTEN IN ' +  str(self.guessedLang).upper() + '\n')
        
            

if __name__ == "__main__":
    start = datetime.now()
    if len(sys.argv) == 4:
        find = FIND(sys.argv[1],sys.argv[2],sys.argv[3])
        print("--------------------------------------------------------------")
        print("------------------------EXECUTION TIME------------------------")
        print("--------------------------------------------------------------")
        print(datetime.now() - start)
    else:
        print("The program show be called like this: \n\tpython3 findlang.py targetFile k a")