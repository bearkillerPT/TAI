
import copy
from os import confstr

class FCM:
    def __init__(self, k, a, textFile='example.txt'):
        self.k = k
        self.a = a
        self.textFile = open(textFile, 'r')
        self.text = self.textFile.read()
        self.createContext()
        self.probabilitiesContext = self.calculateProbabilities(self.context)

    def calculateProbabilities(self, context, k=0):
        res = copy.deepcopy(context) 
        total_probability = 0
        for char in res.keys():
            if isinstance(res[char], int)  or isinstance(res[char], float):
                total_probability += res[char]
        for char in res.keys():
            if isinstance(res[char], int)  or isinstance(res[char], float):
                res[char] = res[char] / (total_probability)
            elif isinstance(res[char], dict):
                if k < self.k:
                    res[char] = self.calculateProbabilities(res[char], k+1)
            else:
                print("not a number nor a dict: " + res[char])
        return res
            


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
                for i in range(k_order):
                    current_ref = current_ref[word[i]]
                if isinstance(current_ref, dict):
                    if word[k_order] not in current_ref.keys():
                        current_ref.setdefault(word[k_order], self.a)
                    else:
                        current_ref[word[k_order]] += 1
                else:
                    res[word[:k_order]] = {word[k_order] : self.a}
                    
        self.context = res

                

a = FCM(2,0.3)
    
