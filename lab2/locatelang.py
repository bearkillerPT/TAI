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
    if len(sys.argv) == 4:
        
        referenceFiles = getReferenceFiles()
        target = sys.argv[1]

        tarCardin = getAlphabetSize(target)
        threshold = log2(tarCardin)/2

        segmentLen = int(sys.argv[2])
        regionLen = int(sys.argv[3])

        k=4
        a=1.0

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

            print('Checking ' + language + "...")
            
            for i in mAvgProfile:
                if i < threshold:
                    coordinates.append(index)
                index += 1
                
            count_seg = []
            count = 0

            for j in range(len(coordinates)):
                if j == 0:
                    next = coordinates[j]
                else:
                    if coordinates[j] <= (next + regionLen):
                        count_seg.append(coordinates[j])
                        next = next + 1
                        count += 1
                    else:
                        count = 0
                        count_seg.clear()
                if count == segmentLen:
                    print(str(min(count_seg)) + "->" + str(max(count_seg)))
                    count = 0
                    count_seg.clear()

    else:
        print("The program show be called like this: \n\tpython3 locatelang.py targetFile segmentLen regionLen")