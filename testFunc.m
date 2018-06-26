function [outputVar] = testFunc(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
thresh = inputArg2;
if inputArg1(inputArg2) > thresh
    outputVar = 1;
else
    outputVar = 0;
end
