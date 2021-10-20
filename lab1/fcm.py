
class FCM:
    def __init__(self, k, a, textFile='example.txt'):
        self.k = k
        self.a = a
        self.textFile = open(textFile, 'r')
        self.text = self.textFile.read()
        self.createContext()

    def createContext(self):
        res = {}
        trash_chars = ['', '|', '!', '"', '$', '%', '&', '/', '(', ')', '=', '?', '\'' , '»', '\\', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '{', '[', ']', '}', '«', ',', '.', ';', ':', '-', '_']
        for k_order in range(self.k):
            for word in self.text.split(' '):
                if(k_order > len(word)-1):
                    break
                k_order_dict = {}
                if k_order != 0:
                    previous_state_indexes = word[0:k_order-1]
                    tmp_dict = res
                    for char in previous_state_indexes:
                        if char not in trash_chars:
                            tmp_dict = tmp_dict[char]
                    k_order_dict = tmp_dict
                if word[k_order] not in trash_chars:
                    if word[k_order] not in k_order_dict.keys():
                        k_order_dict.setdefault(word[k_order], self.a)
                    else:
                        k_order_dict[word[k_order]] += 1
                if k_order == 0:
                    res = k_order_dict
                else:
                    res[previous_state_indexes] = k_order_dict
        self.context = res
                

a = FCM(3,0.3)

    
