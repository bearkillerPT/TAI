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
    if len(sys.argv) == 3:
        
        target = sys.argv[1]
        segmentLen = int(sys.argv[2])
        tarCardin = getAlphabetSize(target)
        threshold = log2(tarCardin)/2
        referenceFiles = getReferenceFiles()
        k=3
        a=0.001

        for file in referenceFiles:
            filePath = 'References/'
            filePath += file
            language = file[:-4]

            print('Checking ' + language + "...")

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

            for i in mAvgProfile:
                if i < threshold:
                    coordinates.append(index)
                index += 1
    
            count_seg = []
            
            for j in range(len(coordinates)):
                if j == 0:
                    previous = coordinates[j]
                    count_seg.append(coordinates[j])
                else:
                    if coordinates[j] - previous <= segmentLen :
                        count_seg.append(coordinates[j])
                        previous = coordinates[j]
            
    else:
        print("The program show be called like this: \n\tpython3 locatelang.py targetFile segmentLen")