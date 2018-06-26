function [LrwList, Lrw, wM, eVals] = Spect(baseName,segCoords,segSize,sigm,isSparse,neighbors,isRand,randNum,isDist,cutoff,sigmaDist)

%Makes a weight matrix of type depending on input and runs eigs on Lrw.

imBase = imread(baseName,1);
imSeg = imBase(segCoords(1):segCoords(1)+segSize-1,segCoords(2):segCoords(2)+segSize-1);

if isSparse == 0
    if ~isDist
        wM = weightedMatrix(imSeg, sigm);
    else
        wM = WMDist(imSeg,sigm,sigmaDist,cutoff);
    end
else
    if ~isRand
        wM = NNSort(imSeg, sigm, neighbors);
    else
        wM = NNRandSort(imSeg,sigm,neighbors,randNum);
    end
end

%Both of these can be used independently, but since they will not be
%returned and are only used once, they are temporarily computed in the
%creation of Lrw to take up less memory:
%   D = sum(wM); %Matrix is symmetric, shouldn't need to worry about direction of sum
%   DDiagInv = sparse(1:segSize^2,1:segSize^2,1./D);%DDiag;

Lrw = speye(segSize^2) - sparse(1:segSize^2,1:segSize^2,1./sum(wM))*wM; %DDiagInv shouldn't need to take up more space when it's only used here

[LrwList, eVals] = eigs(Lrw, 8, 'smallestabs');

end

