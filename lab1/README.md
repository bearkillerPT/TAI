# TAI
Algorithmic Information Theory
```
The simple test was made in order to verify simply nested (second order) words.
More information about how to call fcm is presented when you run:

python3 fcm.py

and the same with the generator:

python3 generator.py

Furthermore there's a test module with some expected results for simple tasks. 
The tests are ran with:

Python3 testFCM.py

If you wish to try the generator with the biggest text (example.txt), run, for example:
python3 generator.py tests/example.txt 10 0.3 200

Where:
- 10 represents the order of the model;
- 0.3 represents the smoothing parameter;
- 200 represents the number of words to generate.



Text specific generator:
It is also possible to save and hot load previous calculated contexts like so:
- Save: python3 text_generator.py --save bible_context tests/bible.txt 10 0.3 200 
[Execution Time: 0:00:04.008487]

- Load: python3 text_generator.py --load bible_context 10 0.3 200 [Execution Time: 0:00:01.506882]

Sequence Generator:
- Save: python3 generator.py --save bible_context tests/bible.txt 5 0.1 20 
[Execution Time: 0:07:06.708885]

- Load: python3 generator.py --load bible_context 5 0.1 20[Execution Time: 0:00:14.810960 ]

```