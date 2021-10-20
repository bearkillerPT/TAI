
import copy
import sys

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
            else:
                total_probability += self.countContextChildre(res[char])
        for char in res.keys():
            if isinstance(res[char], int)  or isinstance(res[char], float):
                res[char] = res[char] / (total_probability)
            elif isinstance(res[char], dict):
                if k < self.k:
                    res[char] = self.calculateProbabilities(res[char], k+1)
            else:
                print("not a number nor a dict: " + res[char])
        return res
            
    def countContextChildre(self, context):
        total = 0
        for children in context.values():
            if isinstance(children, int)  or isinstance(children, float):
                total += children
            else:
                self.countContextChildre(children)
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
                for i in range(k_order):
                    current_ref = current_ref[word[i]]
                if isinstance(current_ref, dict):
                    if word[k_order] not in current_ref.keys():
                        current_ref.setdefault(word[k_order], 1)
                    else:
                        current_ref[word[k_order]] += 1
                else:
                    res[word[:k_order]] = {word[k_order] : 1}
                    
        self.context = res


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("The program show be called like this: \n\tpython3 filename ||\n\tpython3 k_order filename ||\n\tpython3 k_order a filename\nk_order meaning de order of the model and\na being a smoothing parameter")
    elif len(sys.argv) == 2:
        a = FCM(2,0.3, sys.argv[1])
    elif len(sys.argv) == 3:
        a = FCM(sys.argv[1],0.3, sys.argv[2])
    elif len(sys.argv) == 4:
        a = FCM(sys.argv[1],sys.argv[2], sys.argv[3])