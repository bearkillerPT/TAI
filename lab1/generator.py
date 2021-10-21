from os import curdir
import sys
from fcm import FCM
import random

if __name__ == "__main__":
    text_length = 200
    text = ""
    a = FCM
    done = False
    if len(sys.argv) == 1:
        print("The program show be called like this: \n\tpython3 generator.py filename string_length ||\n\tpython3 generator.py k_order filename string_length ||\n\tpython3 generator.py k_order a filename string_length\nk_order meaning de order of the model and\na being a smoothing parameter")
        done = True
    if not done:
        if len(sys.argv) == 3:
            a = FCM(4,0.3, sys.argv[1])
            text_length = int(sys.argv[2])
        elif len(sys.argv) == 4:
            a = FCM(int(sys.argv[1]),0.3, sys.argv[2])
            text_length = int(sys.argv[3])
        elif len(sys.argv) == 5:
            a = FCM(int(sys.argv[1]),float(sys.argv[2]), sys.argv[3])
            text_length = int(sys.argv[4])
        context_pile = []
        context_pile.append(a.probabilitiesContext)
        i = 0
        while i < text_length: 
            if(len(context_pile)== 0):
                context_pile.append(a.probabilitiesContext)
                text+=" "
                i += 1
            current_context = context_pile.pop()
            probs = []
            for prob in current_context:
                if isinstance(current_context[prob], int) or isinstance(current_context[prob], float):
                    probs.append(current_context[prob])
                elif not isinstance(current_context[prob],str):
                    probs.append(FCM.countContextChildren(a, current_context[prob]))
            keys = list(current_context.keys())
            if 'char' in keys:
                keys.remove('char')
            if 'value' in keys:
                keys.remove('value')
                keys.append('')
            res = random.choices(keys, probs)[0]
            if '' in keys:
                keys.remove('')
            if res != '':
                text += res
                if not (isinstance(current_context[res], int) or isinstance(current_context[res], float)):
                    context_pile.append(current_context[res])
        print(text)
        