from os import curdir
import sys
import json
from fcm import FCM
import random
from datetime import datetime

def save(filename, fcm_obj):
    fp = open( filename, 'w')
    json.dump({'count_context': fcm_obj.context, "probs_context": fcm_obj.probabilitiesContext}, fp)
    fp.close()

def loadContext(filename, k=4, a=0.3):
    file = open( filename, 'r')
    dict = json.load(file)
    fcm_obj = FCM(k, a)
    fcm_obj.loadFromContext(dict)
    file.close()
    return fcm_obj

def parseArgs():
    if len(sys.argv) == 3:
        
        a = FCM(4,0.3, sys.argv[1])
        text_length = int(sys.argv[2])
    elif len(sys.argv) == 4:
        if sys.argv[1] == "--load":
            a = loadContext(sys.argv[2],8, 0.3)
            text_length = int(sys.argv[3])
        else:
            a = FCM(int(sys.argv[2]),0.3, sys.argv[1])
            text_length = int(sys.argv[3])
    elif len(sys.argv) == 5:
        text_length = int(sys.argv[4])
        if sys.argv[1] == "--save":
            a = FCM(4,0.3, sys.argv[3])
            save(sys.argv[2],a)
        elif sys.argv[1] == "--load":
            a = loadContext(sys.argv[2],float(sys.argv[3]), 0.3)
        else:
            a = FCM(int(sys.argv[2]),float(sys.argv[3]), sys.argv[1])
    elif len(sys.argv) == 6:
        if sys.argv[1] == "--save":
            a = FCM(int(sys.argv[4]),0.3, sys.argv[3])
            text_length = int(sys.argv[5])
            save(sys.argv[2],a)

        elif sys.argv[1] == "--load":
            a = loadContext(sys.argv[2],int(sys.argv[3]), float(sys.argv[4]))
            text_length = int(sys.argv[5])
    elif len(sys.argv) == 7:
        if sys.argv[1] == "--save":
            a = FCM(int(sys.argv[4]),float(sys.argv[5]), sys.argv[3])
            text_length = int(sys.argv[6])
            save(sys.argv[2],a)
    return [a, text_length]
if __name__ == "__main__":
    start = datetime.now()
    text_length = 200
    text = ""
    a = FCM
    done = False
    if len(sys.argv) <= 1:
        print("The program show be called like this: \n\tpython3 generator.py ([--save context_filename] filename | --load context_filename]) string_length ||\n\tpython3 generator.py ([--save context_filename] filename | --load context_filename]) k_order string_length ||\n\tpython3 generator.py ([--save context_filename] filename | --load context_filename]) k_order a string_length\nk_order meaning de order of the model and\na being a smoothing parameter\nOptional: \n\t--save context_filename")
        done = True
    if not done:
        [a, text_length] = parseArgs()
        parent_prob = a.total_count
        done = False
        while not done:
            current_context = a.context
            current_probs_context = a.probabilitiesContext
            parent_prob = 1
            for k_index in range(a.k):
                if len(text) == text_length:
                    done = True
                    break
                choices = []
                if isinstance(current_probs_context, dict):
                    parent_prob = a.countContextChildren(current_probs_context)

                    for option in current_context.keys():
                        if isinstance(current_probs_context[option], int) or isinstance(current_probs_context[option], float):
                            choices.append(current_probs_context[option]  /parent_prob)
                        else:
                            choices.append(a.countContextChildren(current_probs_context[option])/parent_prob )
                    total = 0
                    for num in choices:
                        total+= num

                    choice = random.choices(list(current_context.keys()),choices)[0]
                    text += choice
                    current_context = current_context[choice]
                    current_probs_context = current_probs_context[choice]

        print("Text Generated:\n" + text)
        print("Entropy:\n" + str(a.entropy()))
        print('Execution Time: ' + str(datetime.now() - start))
        