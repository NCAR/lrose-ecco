

Unit tests for ecco-v

required environment:

$ mamba create -n ecco scipy


Python tests
How to run

$ python -m unittest velTexture_test.py 

Matlab test
How to run


>> addpath('~/git/lrose-ecco/ecco-v-test');
>> testCase = velTexture_test; 
>> addpath('~/git/lrose-ecco/ecco-v/ecco-v_functions');
results = testCase.run



