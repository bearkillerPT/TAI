
import sys
import math
class FCM:

    def __init__(self, k, a, textFile='example.txt'):
        self.k = k + 1
        self.a = a
        if textFile != 'example.txt':
            self.textFile = open(textFile, 'r')
            self.text = self.textFile.read()
            self.createContext()
            self.total_count = self.countContextChildren(self.context)
            self.total_alpha_count = self.a * len(self.alphabet)**(self.k - 1)
            
            self.calculateProbabilities()
            self.total_probs_count = self.countContextChildren(self.probabilitiesContext)


    def loadFromContext(self, context):
        self.context = context["count_context"]
        self.total_count = self.countContextChildren(context)
        self.probabilitiesContext = context["probs_context"]

    def calculateProbabilities(self, current_context=None, current_res={}, parent_prob=None):
        if not current_context:
            current_context = self.context
        if not parent_prob:
            parent_prob = self.total_count
        for char in current_context.keys(): 
            if isinstance(current_context[char], int) or isinstance(current_context[char], float):
                    total_alpha = self.a * len(current_context.keys())
                    current_res.setdefault(char,  (current_context[char] + self.a) / (parent_prob + total_alpha))
            else:
                current_res.setdefault(char, {})
                parent_prob = self.countContextChildren(current_context[char])
                children_res = self.calculateProbabilities(current_context[char], current_res[char],parent_prob)
                current_res.setdefault(char, children_res)
        
        if current_context == self.context:
            self.probabilitiesContext = current_res 
        
    
    
    def countContextChildren(self, current_context):
        current_total=0
        for children in current_context.keys():
            if isinstance(current_context[children], int) or isinstance(current_context[children], float):
                current_total += current_context[children]
            elif isinstance(current_context[children], dict):
                current_total += self.countContextChildren(current_context[children])

        return current_total 

             

                    


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("The program show be called like this: \n\tpython3 fcm.py filename ||\n\tpython3 fcm.py k_order filename ||\n\tpython3 fcm.py k_order a filename\nk_order meaning de order of the model and\na being a smoothing parameter")
    elif len(sys.argv) == 2:
        a = FCM(2,0.3, sys.argv[1])
    elif len(sys.argv) == 3:
        a = FCM(int(sys.argv[1]),0.3, sys.argv[2])
    elif len(sys.argv) == 4:
        a = FCM(int(sys.argv[1]),float(sys.argv[2]), sys.argv[3])