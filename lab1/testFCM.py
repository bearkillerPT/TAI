from fcm import FCM

tests= ["example1", "example2", "example3", "example4"]

for test in tests:
    a = FCM(3, 0.3, textFile='tests/' + test + '.txt')
    expected_counts_file = 'tests/expected/' + test + '.expected'
    expected_probs_file = 'tests/expected/' + test + 'Probs.expected'
    try:
        expected_counts = open(expected_counts_file, 'r').read()
        expected_probs = open(expected_probs_file, 'r').read()
    except:
        print("Files for expected results of " + test + " are missing!")

    if(str(a.context) + str(a.probabilitiesContext) == expected_counts + expected_probs):
        print("Test: " + test + " Passed!")
    else:
        print("Got Count: " + str(a.context))
        print("Expected Count: " + expected_counts)
        print("Got Probs: " + str(a.probabilitiesContext))
        print("Expected Probs: " + expected_probs)
    