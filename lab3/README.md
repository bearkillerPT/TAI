TESTING CHARIZAM.PY

- 4 sample folders : 
  . samples - samples with 12 seconds
  . 05sSmpl - samples with 5 seconds
  . 30sSmpl - samples with 30 seconds 
  . noisySp -  samples with 12 seconds with noise

Each sample folder has 50 samples (sample01.wav->sample50.wav)

- 3 compressor flags:
  . -g -> program uses gzip compressor
  . -b -> program uses bzip2 compressor
  . -l -> program uses lzm

The program should be called like this :
- python3 charizam.py sampleFolder/samplexx.wav -[compressor flag]

Example:
- python3 charizam.py noisySp/sample02.wav -g

An additional flag (-u) can be used if you need to update DbFreqs folder that contains the .freqs files from database
Example:  python3 charizam.py noisySp/sample02.wav -g -h

TESTING ACCURACY.PY

The program should be called like this: 
- python3 accuracy.py sampleFolder -[compressor flag]

Example: python3 accuracy.py samples -b
