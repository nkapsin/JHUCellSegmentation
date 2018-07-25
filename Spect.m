function [LrwList, Lrw, wM, eVals] = Spect(imBase,segCoords,segSize,condList)

%Makes a weight matrix of type depending on input and runs eigs on Lrw.

%{
condList directory:
1 - Sigma for intensity
2 - Is NN
3 - Number of neighbors
4 - Includes random edges
5 - Number of random edges
6 - Is distance
7 - Radius for distance
8 - Sigma for distance
9 - Number of eigs to calculate
%}

isNN = condList(2);
isDist = condList(6);
isRand = condList(4);

imSeg = imBase(segCoords(1):segCoords(1)+segSize-1,segCoords(2):segCoords(2)+segSize-1);

if ~isNN
    if ~isDist
        wM = weightedMatrix(imSeg, condList(1));
    else
        %wM = WMDistAutoSig(imSeg,condList(1),sigmaDist,cutoff); 
        wM = WMDist(imSeg,condList(1),condList(8),condList(7));
    end
else
    if ~isRand
        wM = NNSort(imSeg, condList(1), condList(3));
    else
        wM = NNRandSort(imSeg,condList(1),condList(3),condList(5));
    end
end

%Both of these can be used independently, but since they will not be
%returned and are only used once, they are temporarily computed in the
%creation of Lrw to take up less memory:
%   D = sum(wM); %Matrix is symmetric, shouldn't need to worry about direction of sum
%   DDiagInv = sparse(1:segSize^2,1:segSize^2,1./D);%DDiag;

Lrw = speye(segSize^2) - sparse(1:segSize^2,1:segSize^2,1./sum(wM))*wM; %DDiagInv shouldn't need to take up more space when it's only used here

[LrwList, eVals] = eigs(Lrw, condList(9), 'sr');

end