from traceback import print_tb
from charizam import CHARIZAM
import os
import sys

def getAllSamples(samples_dir):
    arr = os.listdir(samples_dir)
    return arr

def classification(sampleWav,guessed_song):
    sampleNames = {
        "sample01.wav":"SUICIDEBOYS - PARIS","sample02.wav":"2pac ft Dr Dre - California Love","sample03.wav":"AC DC - Highway to Hell",
        "sample04.wav":"Big Pun - Beware","sample05.wav":"Biggie Smalls - Party and Bullshit","sample06.wav":"Bobby Shmurda - Hot N_gga",
        "sample07.wav":"Bon Jovi - Livin On A Prayer","sample08.wav":"Chief Keef - Love Sosa","sample09.wav":"Coldplay - Viva La Vida",
        "sample10.wav":"Deep Purple - Smoke on the Water","sample11.wav":"Dr Dre feat Snoop Dogg - Still Dre","sample12.wav":"Dr Dre ft Snoop Dogg - Deep Cover",
        "sample13.wav":"Foo Fighters - The Pretender","sample14.wav":"Green Day - American Idiot","sample15.wav":"Gunna and Future - pushin P",
        "sample16.wav":"Guns N Roses - Sweet Child O Mine","sample17.wav":"Ice Cube - Ghetto Bird","sample18.wav":"Kaiser Chiefs - Ruby",
        "sample19.wav":"Led Zeppelin - Whole Lotta Love","sample20.wav":"lil peep x lil tracy - witchblades","sample21.wav":"LMFAO - Sexy and I Know It",
        "sample22.wav":"Metallica - The Memory Remains","sample23.wav":"LON3R JOHNY - TRAPSTAR","sample24.wav":"Lynyrd Skynyrd - Sweet Home Alabama",
        "sample25.wav":"Maroon 5 - Harder To Breathe","sample26.wav":"Michael Bublé - Feeling Good","sample27.wav":"Michael Jackson - Bad",
        "sample28.wav":"Michael Jackson - Billie Jean","sample29.wav":"Mobb Deep - Shook Ones Part 2","sample30.wav":"Nas - NY State Of Mind",
        "sample31.wav":"Nirvana - Smells Like Teen Spirit","sample32.wav":"Numb - Linkin Park","sample33.wav":"NWA - Fuk Da Police",
        "sample34.wav":"Oasis - Dont Look Back In Anger","sample35.wav":"Somewhere over the Rainbow - Israel IZ Kamakawiwo ole","sample36.wav":"Pharrell Williams - Happy",
        "sample37.wav":"ProfJam - Agua de Coco","sample38.wav":"PSY - GANGNAM STYLE","sample39.wav":"Recayd Mob - Plaqtudum",
        "sample40.wav":"Red Hot Chili Peppers - Dani California","sample41.wav":"Robbie Williams - Angels","sample42.wav":"Robin Thicke - Blurred Lines ft TI and Pharrell",
        "sample43.wav":"scarlxrd - HEART ATTACK","sample44.wav":"Survivor - Eye Of The Tiger","sample45.wav":"The Black Eyed Peas - Where Is The Love",
        "sample46.wav":"The Killers - Mr. Brightside","sample47.wav":"The White Stripes - Seven Nation Army","sample48.wav":"Travis Scott - goosebumps ft Kendrick Lamar",
        "sample49.wav":"Whitney Houston - I Will Always Love You","sample50.wav":"Ylvis - The Fox"
    }
    sampleWav = sampleWav[8:]
    if sampleNames[sampleWav] == guessed_song:
        return 1
    else:
        return 0

if __name__ == "__main__":
    if len(sys.argv) == 3:
        sampleFolder = sys.argv[1]
        compressor = sys.argv[2]

        samples = getAllSamples(sampleFolder)
        samples.sort()
        
        correct_guesses = 0
        
        print("Calculating Accuracy...")
        print('\n')
        print("Sample Folder: " + sampleFolder)
        print("Compressor: " + compressor)
        print('\n')
        
        for i in samples:
            sampleWav = sampleFolder + "/" + i
            object = CHARIZAM(sampleWav,compressor,update=False)
            correct_guesses += classification(sampleWav,object.guessed_song)
        
        accuracy = (correct_guesses / len(samples)) * 100

        print("Accuracy: " + str(accuracy) + "%") 
    else:
        print("The program should be called like this: \n\tpython3 accuracy.py sampleFolder -[compressor flag]")