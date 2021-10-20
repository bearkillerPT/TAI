from fcm import FCM

tests= ["exampleSImple"]

for test in tests:
    a = FCM(2, 0.3, textFile='tests/' + test + '.txt')
    expected_file = 'tests/' + test + '.expected'
    if(str(a.context) == open(expected_file, 'r').read()):
        print("Test: " + test + " Passed!")
    