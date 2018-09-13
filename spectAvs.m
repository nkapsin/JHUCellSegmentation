function [clustIm,LrwList,eVals,avClusts, wM, Lrw] = spectAvs(avList,k,sigma,NN,fullIm, normNum)

wM = NNSort(avList,sigma,NN);

Lrw = speye(length(avList)) - sparse(1:length(avList),1:length(avList),1./sum(wM))*wM;

%Equals k since looking for k regions
[LrwList, eVals] = eigs(Lrw, k, 'sr');

%Normalizing the eVects to avoid outliers
for i = 1:k
    LrwList(:,i) = LrwList(:,i)./norm(LrwList(:,i), normNum);
end

avClusts = kmeans(LrwList,k, 'MaxIter', 1000, 'Replicates', 3);

clustIm = fullIm;
for i = 1:800
    for j = 1:800
        clustIm(i,j) = avClusts(fullIm(i,j));
    end
end

end