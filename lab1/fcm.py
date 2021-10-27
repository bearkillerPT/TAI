
import sys

class FCM:
    def __init__(self, k, a, textFile='example.txt'):
        self.k = k 
        self.a = a
        self.textFile = open(textFile, 'r')
        self.text = self.textFile.read()
        self.createContext()
        self.total_count = self.countContextChildren(self.context)
        self.calculateProbabilities()

    def calculateProbabilities(self, current_context=None, current_res={}, parent_prob=None):
        if not current_context:
            current_context = self.context
            

        if not parent_prob:
            parent_prob = self.total_count

        for char in current_context.keys(): 
            if isinstance(current_context[char], int):
                current_res.setdefault(char, current_context[char] / parent_prob)
            else:
                current_res.setdefault(char, {})
                children_count = self.countContextChildren(current_context[char])
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

    def createContext(self):
        res = {}
        trash_chars = ['', '\n', '|', '!', '"', '$', '%', '&', '/', '(', ')', '=', '?', '\'' , '»', '\\', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '{', '[', ']', '}', '«', ',', '.', ';', ':', '-', '_']     
        for word in self.text.split(' '):
            bad_word = False
            current_ref = res
            for char in word:
                if char in trash_chars:
                    bad_word = True
            if bad_word:
                continue
            for k_order in range(self.k):
                
                if(k_order > len(word) - 1):
                    break
                if k_order == self.k - 1 or k_order == len(word) - 1:
                    if isinstance(current_ref, int):
                        current_ref[word[k_order]] += 1
                    elif isinstance(current_ref, dict):
                        if not word[k_order] in current_ref.keys():
                            current_ref.setdefault(word[k_order], {'': 1})
                        elif '' in current_ref[word[k_order]]:
                            if isinstance(current_ref[word[k_order]][''], int):
                                current_ref[word[k_order]][''] += 1
                        
                else:   
                    if current_ref == {}:
                        current_ref.setdefault(word[k_order], {})
                    elif word[k_order] not in current_ref.keys():
                        current_ref.setdefault(word[k_order], {})
                        
                current_ref = current_ref[word[k_order]] 
                
                
               

                    
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