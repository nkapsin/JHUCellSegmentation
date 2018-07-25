function [fullIm, avList, centHolder] = doubleSpectKmeans(littleK, eigHolder, numEigs,baseIm)

centHolder = zeros(littleK,numEigs,16);
fullIm = zeros(800,800);

for i = 1:4
    for j = 1:4
        curEvects = eigHolder(:,:,j+(i-1)*4);
        [kMap, centroids] = kmeans(curEvects(:,1:numEigs),littleK, 'MaxIter', 1000, 'Replicates', 3);
        fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) = reshape(kMap, [200 200]);
        fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) = fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) + littleK*(j+(i-1)*4-1);
        centHolder(:,:,j+(i-1)*4) = centroids;
    end
end

%Random redistribution of colors so each section will have it's own color,
%but they won't be as likely to be similar to sections in the same segment
reList = randperm(16*littleK);
for i = 1:800
    for j = 1:800
        fullIm(i,j) = reList(fullIm(i,j));
    end
end

%Calculating the average intensities of each section
avList = zeros(16*littleK,2);

for i = 1:800
    for j = 1:800
        avList(fullIm(i,j),1) = avList(fullIm(i,j),1) + 1;
        avList(fullIm(i,j),2) = (avList(fullIm(i,j),2)*(avList(fullIm(i,j),1)-1) + double(baseIm(i,j)))/avList(fullIm(i,j),1);
    end
end

end