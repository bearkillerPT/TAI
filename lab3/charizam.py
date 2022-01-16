import os
import re
import subprocess
import sys
import shutil
import gzip

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

def gzipcomp(file):
    comp_file = "temp.gz"
    with open(file, 'rb') as f_in:
        with gzip.open(comp_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
    
    size = os.path.getsize(comp_file)
    return size

def ncd(sampleFile,musicFile):
    sampleFile = sampleFile[8:-4] + ".freqs"
    musicFile = musicFile[:-4] + ".freqs"
    musicFile = musicFile.replace(' ','_')
    musicFile = "./DbFreqs" + "/" + musicFile

    sampleBits = gzipcomp(sampleFile)
    musicBits = gzipcomp(musicFile)
    
    bits = [sampleBits,musicBits]

    ncd = ((bits[0]+bits[1]) - min(bits))/max(bits)
    print((bits[0]+bits[1]))


if __name__ == "__main__":
    if len(sys.argv) == 2:

        createFreqsFolder()
        database_dir = "./database"
        sample_dir = "./samples"
        wavs = getDbWavs(database_dir)
        sampleWav = sys.argv[1]

        createFreqsFile(sampleWav,isSample=True)
        
        for i in wavs:
            createFreqsFile(i,isSample=False)
            ncd(sampleWav,i)
        
        deleteFreqs('DbFreqs',sampleWav)
    else:
        print("The program show be called like this: \n\tpython3 charizam.py sample.wav")

