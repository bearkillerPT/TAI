from fcm import FCM

tests= ["exampleSImple"]

for test in tests:
    a = FCM(2, 0.3, textFile='tests/' + test + '.txt')
    expected_counts_file = 'tests/' + test + '.expected'
    expected_probs_file = 'tests/' + test + 'Probs.expected'
    if(str(a.context) + str(a.probabilitiesContext) == open(expected_counts_file, 'r').read() + open(expected_probs_file, 'r').read()):
        print("Test: " + test + " Passed!")
    