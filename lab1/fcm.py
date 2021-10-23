
import copy
from os import W_OK, curdir
import sys

class FCM:
    def __init__(self, k, a, textFile='example.txt'):
        self.k = k
        self.a = a
        self.textFile = open(textFile, 'r')
        self.text = self.textFile.read()
        self.createContext()
        self.probabilitiesContext = self.calculateProbabilities(self.context)

    def calculateProbabilities(self, context, k=0, parentProb=1):
        res = copy.deepcopy(context)
        total_probability = 0
        for char in res.keys():
            if isinstance(res[char], int)  or isinstance(res[char], float):
                total_probability += res[char]
            elif char == 'value':
                total_probability += res['value']
            elif isinstance(res[char], dict):
                total_probability += self.countContextChildren(res[char]) 
                total_probability += 1/parentProb
                res[char].setdefault('value', parentProb)
        for char in res.keys():
            if isinstance(res[char], int)  or isinstance(res[char], float):
                    res[char] = res[char]/total_probability * parentProb
            elif isinstance(res[char], dict):
                if k < self.k:
                    prob = self.countContextChildren(res[char])
                    res[char] = self.calculateProbabilities(res[char], k+1, (prob/total_probability))
            else:
                print("not a number nor a dict: " + res[char])
        return res
            
    def countContextChildren(self, context):
        total = 0
        percentage = 1
        for children in context.keys():
            if isinstance(context[children], int)  or isinstance(context[children], float):
                total += context[children]
            elif isinstance(context[children], str):
                if(children == "char"):
                    pass
            else:
                total +=self.countContextChildren(context[children])
        return total 

    def createContext(self):
        res = {}
        parent_ref = {}
        trash_chars = ['', '\n', '|', '!', '"', '$', '%', '&', '/', '(', ')', '=', '?', '\'' , '»', '\\', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '{', '[', ']', '}', '«', ',', '.', ';', ':', '-', '_']
        for k_order in range(self.k):
            for word in self.text.split(' '):
                if(k_order > len(word) -1):
                    continue
                bad_word = False
                for char in word:
                    if char in trash_chars:
                        bad_word = True
                if bad_word:
                    continue
                current_ref = res
                for i in range(0,k_order):
                    if isinstance(current_ref[word[i]],int):
                        current_ref[word[i]] = {}
                    current_ref = current_ref[word[i]]
                if isinstance(current_ref, dict):
                    if word[k_order] not in current_ref.keys():
                        current_ref.setdefault(word[k_order], 1)
                    else:
                        current_ref[word[k_order]] += 1
                else:
                    temp_ref = res
                    for i in range(k_order):
                        temp_ref = temp_ref[word[i]]
                    temp_ref = {word[k_order] : 1}
                    
        self.context = res


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("The program show be called like this: \n\tpython3 fcmm.py filename ||\n\tpython3 fcmm.py k_order filename ||\n\tpython3 fcmm.py k_order a filename\nk_order meaning de order of the model and\na being a smoothing parameter")
    elif len(sys.argv) == 2:
        a = FCM(2,0.3, sys.argv[1])
    elif len(sys.argv) == 3:
        a = FCM(sys.argv[1],0.3, sys.argv[2])
    elif len(sys.argv) == 4:
        a = FCM(sys.argv[1],sys.argv[2], sys.argv[3])