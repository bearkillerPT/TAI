import os
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


def deleteFiles(foldername,wavName):
    freqsFileName = wavName[8:-4] + ".freqs"

    if os.path.isdir(foldername) == True:
        shutil.rmtree(foldername)
    if os.path.isfile(freqsFileName) == True:
        os.remove(freqsFileName)
    if os.path.isfile('concat.freqs') == True:
        os.remove('concat.freqs')
    if os.path.isfile('temp.gz') == True:
        os.remove('temp.gz')


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


def concatFiles(sampleFile,musicFile):
    command = "cat " + sampleFile + " " + musicFile + " > concat.freqs"
    os.system(command)


def ncd(sampleFile,musicFile):
    sampleFile = sampleFile[8:-4] + ".freqs"

    music = musicFile
    music = music[:-4]

    musicFile = musicFile[:-4] + ".freqs"
    musicFile = musicFile.replace(' ','_')
    musicFile = "./DbFreqs" + "/" + musicFile

    concatFiles(sampleFile,musicFile)
    concatBits = gzipcomp('concat.freqs')

    sampleBits = gzipcomp(sampleFile)
    musicBits = gzipcomp(musicFile)
    bits = [sampleBits,musicBits]

    ncd = (concatBits - min(bits))/max(bits)
    
    return ncd,music



if __name__ == "__main__":
    if len(sys.argv) == 2:
        sampleWav = sys.argv[1]
        
        deleteFiles('DbFreqs',sampleWav)
        createFreqsFolder()
        
        database_dir = "./database"
        sample_dir = "./samples"
        wavs = getDbWavs(database_dir)
        
        distances = {}

        createFreqsFile(sampleWav,isSample=True)
        
        print('Analyzing the sample...')

        for i in wavs:
            createFreqsFile(i,isSample=False)
            ncdBits,music= ncd(sampleWav,i)
            distances.update({music:ncdBits})
        
        print('\n')
        print("-------------------------GUESSED SONG-------------------------")
        print("--------------------------------------------------------------")

        print(min(distances,key=distances.get))

        print("--------------------------------------------------------------")
        
        deleteFiles('DbFreqs',sampleWav)
    
    else:
        print("The program show be called like this: \n\tpython3 charizam.py sample.wav")

