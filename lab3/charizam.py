import os
import sys
import shutil
import gzip
import bz2
import lzma
from datetime import datetime

class CHARIZAM:

    def __init__(self,sampleWav,compressor):
        self.deleteFiles(sampleWav)
        self.noFreqs = False
        self.isDbFreqs()
        self.database_dir = "./database"
        self.wavs = self.getDbWavs(self.database_dir)
        self.distances = {}
        self.createFreqsFile(sampleWav,isSample=True)
        self.createDistances(self.wavs,self.noFreqs,sampleWav,compressor)
        self.guessed_song = min(self.distances,key=self.distances.get)  
        self.deleteFiles(sampleWav)

       
    def createDistances(self,wavs,noFreqs,sampleWav,compressor):
         for i in wavs:
            if noFreqs == True:
                self.createFreqsFile(i,isSample=False)
            ncdBits,music= self.ncd(sampleWav,i,compressor)
            self.distances.update({music:ncdBits})

    def isDbFreqs(self):
        if os.path.isdir('DbFreqs') == False:
            self.createFreqsFolder()
            self.noFreqs = True

    def getDbWavs(self,database_dir):
        arr = os.listdir(database_dir)
        return arr

    def createFreqsFolder(self):
        folder = "DbFreqs"
        parent_dir = "."
        path = os.path.join(parent_dir, folder)

        if os.path.isdir(path) == False:
            os.mkdir(path)

    def moveToFreqsFolder(self,filename):
        destination = "DbFreqs"
        shutil.move(filename, destination)

    def deleteFiles(self,wavName):
        freqsFileName = wavName[8:-4] + ".freqs"

        if os.path.isfile(freqsFileName) == True:
            os.remove(freqsFileName)
        if os.path.isfile('concat.freqs') == True:
            os.remove('concat.freqs')
        if os.path.isfile('temp.gz') == True:
            os.remove('temp.gz')

    def createFreqsFile(self,wavName,isSample):
        if isSample == False:
            freqsFileName = wavName[:-4] + ".freqs"
            newFreqsName = freqsFileName.replace(' ','_')
            newWavName = wavName.replace(' ','\\ ')
            wav = "./database" + "/" + newWavName
            args = "./GetMaxFreqs/bin/GetMaxFreqs -w " + newFreqsName + " " + wav
            os.system(args)
            self.moveToFreqsFolder(newFreqsName)
        else:
            freqsFileName = wavName[8:-4] + ".freqs"
            args = "./GetMaxFreqs/bin/GetMaxFreqs -w " + freqsFileName + " " + wavName
            os.system(args)

    def compressing(self,file,compressor):
        comp_file = "temp.gz"

        with open(file, 'rb') as f_in:
            if compressor == '-g':
                with gzip.open(comp_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            elif compressor == '-b': 
                with bz2.open(comp_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            elif compressor == '-l':
                with lzma.open(comp_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)

        size = os.path.getsize(comp_file)
        
        return size

    def concatFiles(self,sampleFile,musicFile):
        command = "cat " + sampleFile + " " + musicFile + " > concat.freqs"
        os.system(command)

    def ncd(self,sampleFile,musicFile,compressor):
        sampleFile = sampleFile[8:-4] + ".freqs"
        music = musicFile
        music = music[:-4]
        musicFile = musicFile[:-4] + ".freqs"
        musicFile = musicFile.replace(' ','_')
        musicFile = "./DbFreqs" + "/" + musicFile
        
        self.concatFiles(sampleFile,musicFile)
        
        concatBits = self.compressing('concat.freqs',compressor)
        sampleBits = self.compressing(sampleFile,compressor)
        musicBits = self.compressing(musicFile,compressor)
        
        bits = [sampleBits,musicBits]
        ncd = (concatBits - min(bits))/max(bits)
        
        return ncd,music


if __name__ == "__main__":
    if len(sys.argv) == 3:
        start = datetime.now()
        
        sampleWav = sys.argv[1]
        compressor = sys.argv[2]
        
        print('Analyzing the sample...')
        
        object = CHARIZAM(sampleWav,compressor)

        print('\n')
        print("-------------------------GUESSED SONG-------------------------")
        print("--------------------------------------------------------------")
        print(object.guessed_song)

        print("--------------------------------------------------------------")
        print('\n')
        print('Execution time: ' + str(datetime.now() - start))
    
    else:
        print("The program show be called like this: \n\tpython3 charizam.py sample.wav")

