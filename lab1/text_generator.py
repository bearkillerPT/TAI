from os import curdir
import sys
import json
from text_fcm import FCM
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
        if sys.argv[1] == "--save":
            a = FCM(4,0.3, sys.argv[3])
            text_length = int(sys.argv[4])
            save(sys.argv[2],a)
        elif sys.argv[1] == "--load":
            a = loadContext(sys.argv[2],float(sys.argv[3]), 0.3)
            text_length = int(sys.argv[4])
        else:
            a = FCM(int(sys.argv[2]),float(sys.argv[3]), sys.argv[1])
            text_length = int(sys.argv[4])
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
        context_pile = []
        context_pile.append(a.probabilitiesContext)
        i = 0
        parent_prob = 1
        
        while i < text_length: 

            if(len(context_pile)== 0):
                context_pile.append(a.probabilitiesContext)
                text+=" "
                parent_prob = 1
            
            current_context = context_pile.pop()
            probs = []
            for prob in current_context.keys():
                current_prob= current_context[prob]
                if isinstance(current_prob, int) or isinstance(current_prob, float):
                    probs.append(current_prob)
                elif isinstance(current_prob,dict):
                    value = FCM.countContextChildren(a,current_prob)
                    probs.append(value)
            
            keys = list(current_context.keys())
            scaled_probs = []
            for prob in probs:
                scaled_probs.append(prob/parent_prob)
            res = random.choices(keys, weights=scaled_probs)[0]
            parent_prob = probs[keys.index(res)] 
            if res != '':
                text += res
                if not (isinstance(current_context[res], float) or isinstance(current_context[res], float)):
                    context_pile.append(current_context[res])
            else:
                i += 1

        print(text)
        print('Execution Time: ' + str(datetime.now() - start))
        