clear all;

fileName = 'test_input.f06';

test = nastranMagic(fileName);
tr = test.parseTimeResponse();
tr
