from os import system
from fcm import FCM
import sys



def runTests(test, fcm_obj):
    expected_counts_filename = 'tests/expected/' + test + '.expected'
    expected_probs_filename = 'tests/expected/' + test + 'Probs.expected'
    try:
        expected_counts_file = open(expected_counts_filename, 'r')
        expected_probs_file = open(expected_probs_filename, 'r')
        expected_counts = expected_counts_file.read()
        expected_probs = expected_probs_file.read()
        if(str(fcm_obj.context) + str(fcm_obj.probabilitiesContext) == expected_counts + expected_probs):
            print("Test: " + test + " Passed!")
        else:
            print("teste " + test)
            print("Got Count: " + str(fcm_obj.context))
            print("Expected Count: " + expected_counts)
            print("Got Probs: " + str(fcm_obj.probabilitiesContext))
            print("Expected Probs: " + expected_probs)
        expected_counts_file.close()
        expected_probs_file.close()  
        
    except:
        print("Files for expected results of " + test + " are missing!")
    
tests = ["example1", "example2", "example3", "example4"]

if __name__ == "__main__":
    total_args = len(sys.argv)
    if total_args == 1:
        for test in tests:
            system('python3 testFCM.py ' + test)
    elif total_args == 2:
        filename = 'tests/' + sys.argv[1] + '.txt'
        fcm_obj = FCM(3, 0.3, textFile=filename)
        runTests(sys.argv[1], fcm_obj)
    elif total_args > 3:
        print("The program show be called without any parameters or with a name like: example1. \nEverything is standardized so that the tests are ran automatically according to the examples in the tests folder!")

    