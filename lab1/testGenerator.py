from os import system
import sys

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("The program show be called like this: \n\tpython3 testGenerator.py filename ||\n\tpython3 testGenerator.py k_order filename ||\n\tpython3 testGenerator.py k_order a filename\nk_order meaning de order of the model and\na being a smoothing parameter")
    elif len(sys.argv) == 2:
        k = 2
        a = 0.3
        filename = sys.argv[1]
    elif len(sys.argv) == 3:
        k = int(sys.argv[1])
        a = 0.3
        filename = sys.argv[2]
    elif len(sys.argv) == 4:
        k = int(sys.argv[1])
        a = float(sys.argv[2])
        filename = sys.argv[3]
    
    for i in range(1,k+1):
        print('k: ' + str(i))
        print('a: ' + str(a))
        system('python3 generator.py ' + filename + ' ' + str(i) + ' ' + str(a) + ' 0')