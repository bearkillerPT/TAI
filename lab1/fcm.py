
import sys
import math
class FCM:

    def __init__(self, k, a, textFile='example.txt'):
        self.k = k 
        self.a = a
        if textFile != 'example.txt':
            self.textFile = open(textFile, 'r')
            self.text = self.textFile.read()
            self.createContext()
            self.total_count = self.countContextChildren(self.context)
            self.calculateProbabilities()

    def loadFromContext(self, context):
        self.context = context["count_context"]
        self.total_count = self.countContextChildren(context)
        self.probabilitiesContext = context["probs_context"]

    def calculateProbabilities(self, current_context=None, current_res={}, parent_prob=None):
        if not current_context:
            current_context = self.context
        if not parent_prob:
            parent_prob = self.total_count
            
        total_alpha = self.a * parent_prob
      
        for char in current_context.keys(): 
            if current_context[char] == {}:
                current_res.setdefault(char, self.a / (parent_prob + total_alpha))
            elif isinstance(current_context[char], int) or isinstance(current_context[char], float):
                    current_res.setdefault(char,  (current_context[char] + self.a) / (parent_prob + total_alpha))
            else:
                current_res.setdefault(char, {})
                parent_prob = self.countContextChildren(current_context)
                children_res = self.calculateProbabilities(current_context[char], current_res[char],parent_prob)
                current_res.setdefault(char, children_res)
        
        if current_context == self.context:
            self.probabilitiesContext = current_res 
        

    def entropy(self, current_probs_context=None, parent_prob=None):
        if not current_probs_context:
            current_probs_context = self.probabilitiesContext
        if not parent_prob:
            parent_prob = 1
        row_entropy = 0
        if isinstance(current_probs_context, int) or isinstance(current_probs_context, float):
            return -math.log2(current_probs_context / parent_prob)
        else:
            parent_prob = self.countContextChildren(current_probs_context)
            for context in current_probs_context:
                row_entropy += parent_prob * self.entropy(current_probs_context[context], parent_prob)
            return -row_entropy


        
        
    
    def countContextChildren(self, current_context):
        current_total=0
        for children in current_context.keys():
            if isinstance(current_context[children], int) or isinstance(current_context[children], float):
                current_total += current_context[children]
            elif isinstance(current_context[children], dict):
                current_total += self.countContextChildren(current_context[children])

        return current_total 

    def createContext(self):
        self.alphabet = set(self.text)
        res = {}
        for char_index in range(len(self.text)):
            current_ref = res
            k_end = self.k
            if(len(self.text) - char_index < self.k):
                k_end = len(self.text) - char_index 
            for i in range(k_end):
                if i == self.k - 1:
                    if self.text[char_index + i] in current_ref.keys():
                            current_ref[self.text[char_index + i]] += 1
                    else:
                        current_ref.setdefault(self.text[char_index + i], 1)
                else:
                    if self.text[char_index + i] not in current_ref.keys():
                        current_ref.setdefault(self.text[char_index + i], {})
                current_ref = current_ref[self.text[char_index + i]]
        self.context = res
        
        for char_index in range(len(self.text) - self.k):
            current_ref = res
            for i in range(self.k):
                for letter in self.alphabet:
                    if letter not in current_ref.keys():
                        current_ref.setdefault(letter,0)
                current_ref = current_ref[self.text[char_index + i]]

               

                    


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("The program show be called like this: \n\tpython3 fcmm.py filename ||\n\tpython3 fcmm.py k_order filename ||\n\tpython3 fcmm.py k_order a filename\nk_order meaning de order of the model and\na being a smoothing parameter")
    elif len(sys.argv) == 2:
        a = FCM(2,0.3, sys.argv[1])
    elif len(sys.argv) == 3:
        a = FCM(int(sys.argv[1]),0.3, sys.argv[2])
    elif len(sys.argv) == 4:
        a = FCM(int(sys.argv[1]),float(sys.argv[2]), sys.argv[3])