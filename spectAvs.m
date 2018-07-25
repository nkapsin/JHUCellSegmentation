function [clustIm,LrwList,eVals,avClusts] = spectAvs(avList,k,sigma,NN,fullIm)

wM = NNSort(avList,sigma,NN);

Lrw = speye(length(avList)) - sparse(1:length(avList),1:length(avList),1./sum(wM))*wM;

%Moved up to 10, used to be 3
[LrwList, eVals] = eigs(Lrw, 10, 'sr');

%Normalizing the eVects to avoid outliers
for i = 1:10
    LrwList(:,i) = LrwList(:,i)./max(abs(LrwList(:,i)));
end

avClusts = kmeans(LrwList,k, 'MaxIter', 1000, 'Replicates', 3);

clustIm = fullIm;
for i = 1:800
    for j = 1:800
        clustIm(i,j) = avClusts(fullIm(i,j));
    end
end

end