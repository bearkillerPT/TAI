# TAI
Algorithmic Information Theory
```
The simple test was made in order to verify simply nested (second order) words.
More information about how to call fcm is presented when you run:

python3 fcm.py

and the same with the generator:

python3 generator.py

Furthermore there's a test module with some expected results for simple tasks. 
The tests are ran after:

Python3 testFCM.py

If you wish to try the generator with the biggest text (example.txt), run, for example:
python3 generator.py 10 0.3 tests/example.txt 200

Where:
- 10 represents the order of the model;
- 0.3 represents the smoothing parameter;
- 200 represents the number of words to generate.

```