import sys
import os
from lang import LANG
from math import log2

def getReferenceFiles():
    arr = os.listdir('./References')
    return arr

def getAlphabetSize(filename):
    textFile = open(filename, 'r')
    text = textFile.read()
    sizeAlphabet = len(set(text))
        
    return sizeAlphabet

def sumList(aux):
    sum = 0
    for i in aux:
        sum += i
    return sum

if __name__ == "__main__":
    if len(sys.argv) == 2:
        
        referenceFiles = getReferenceFiles()
        target = sys.argv[1]

        tarCardin = getAlphabetSize(target)
        threshold = log2(tarCardin)/2

        k=4
        a=1.0

        dici = {}

        for file in referenceFiles:
            filePath = 'References/'
            filePath += file
            language = file[:-4]
            
            lang_obj = LANG(filePath,target,k,a)

            listOfBits = lang_obj.listOfBits

            aux = []
            mAvgProfile = [] 

            for i in listOfBits:
                if len(aux) == k:
                    bitSum = sumList(aux)
                    smoothBit = bitSum / k
                    mAvgProfile.append(smoothBit)
                    aux = aux[1:]
                    aux.append(i)
                    continue
                aux.append(i)

            bitSum = sumList(aux)
            smoothBit = bitSum / k 
            mAvgProfile.append(smoothBit)

            index = 1
            coordinates = []

            print('Linguagem: ' + language)
            
            for i in mAvgProfile:
                if i < threshold:
                    coordinates.append(index)
                index += 1
                
            
            dici.update({language:len(coordinates)})
            #for j in range(len(coordinates)):

        print(dici)



    else:
        print("The program show be called like this: \n\tpython3 locatelang.py targetFile")