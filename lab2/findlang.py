from lang import LANG
import sys
import os

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

        for file in self.referenceFiles:
            filePath = 'References/'
            
            print('Training ' + file)
            
            filePath += file
            lang_obj = LANG(filePath,self.target,self.k,self.a)
            
            language = file[:-4]
            langBits.update({language:lang_obj.normalizedBits})
        
        guessedLang = min(langBits,key=langBits.get)
        print('\nTHE TARGET FILE IS WRITTEN IN ' +  str(guessedLang).upper())
            

if __name__ == "__main__":
    if len(sys.argv) == 4:
        find = FIND(sys.argv[1],sys.argv[2],sys.argv[3])
    else:
        print("The program show be called like this: \n\tpython3 findlang.py targetFile k a")