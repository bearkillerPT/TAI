import os
import subprocess
import sys
import shutil

def getDbWavs(database_dir):
    arr = os.listdir(database_dir)
    return arr

def createFreqsFolder():
    folder = "DbFreqs"
    parent_dir = "."
    path = os.path.join(parent_dir, folder)

    if os.path.isdir(path) == False:
        os.mkdir(path)

def moveToFreqsFolder(filename):
    destination = "DbFreqs"
    shutil.move(filename, destination)

def deleteFreqs(foldername,wavName):
    shutil.rmtree(foldername)
    freqsFileName = wavName[8:-4] + ".freqs"
    os.remove(freqsFileName)

def createFreqsFile(wavName,isSample):
    if isSample == False:
        freqsFileName = wavName[:-4] + ".freqs"
        newFreqsName = freqsFileName.replace(' ','_')
        newWavName = wavName.replace(' ','\\ ')
        wav = "./database" + "/" + newWavName
        args = "./GetMaxFreqs/bin/GetMaxFreqs -w " + newFreqsName + " " + wav
        os.system(args)
        moveToFreqsFolder(newFreqsName)
    else:
        freqsFileName = wavName[8:-4] + ".freqs"
        args = "./GetMaxFreqs/bin/GetMaxFreqs -w " + freqsFileName + " " + wavName
        os.system(args)

if __name__ == "__main__":
    if len(sys.argv) == 2:

        createFreqsFolder()
        database_dir = "./database"
        sample_dir = "./samples"
        wavs = getDbWavs(database_dir)
        sampleWav = sys.argv[1]
        
        for i in wavs:
            createFreqsFile(i,isSample=False)

        createFreqsFile(sampleWav,isSample=True)
        
        deleteFreqs('DbFreqs',sampleWav)
    else:
        print("The program show be called like this: \n\tpython3 charizam.py sample.wav")

