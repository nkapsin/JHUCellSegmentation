function [returnMat] = loadMat(matName)
%I'm tired of having to convert these things all the time
returnMat = cell2mat(struct2cell(load(matName)));
end

