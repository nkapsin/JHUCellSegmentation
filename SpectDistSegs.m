profile off;
profile on;

%This is the same as spectrunner, but with less user input and the
%inclusion of kmeans to make a large, full-image matrix

disp('Running 16 200x200 sections on a file');
resetP = input('Reset parameters? (0/1) ');
if resetP
    randCond = 0;
    distCond = 0;
    fileName = input('Enter file name: ','s');
    sigm = input('Enter sigma for intensity similarity: ');
    eigNum = input('Enter number of eigenvectors: ');
    kNum = input('Enter k for kmeans: ');
    neighborCond = input('Make NN? (0/1) ');
    if neighborCond
        cutoff = -1;
        sigmDist = -1;
        NNnum = input('Enter neighbor count: ');
        randCond = input('Add random edges? (0/1) ');
        if randCond
            randNum = input('How many? ');
        else
            randNum = -1;
        end
    else
        NNnum = -1;
        randNum = -1;
        distCond = input('Include distance? (0/1) ');
        if distCond
            cutoff = input('What radius? ');
            sigmDist = input('Enter sigma for distance similarity: ');
        else
            cutoff = -1;
            sigmDist = -1;
        end
    end 
end

fullIm = zeros(800,800);
eigHolder = zeros(200*200, eigNum, 16);
centHolder = zeros(kNum,eigNum,16);
baseIm = imread(fileName,25);

for i = 1:4
    for j = 1:4
    
    disp(['i = ' num2str(i) ', j = ' num2str(j)]);
    tic;
    [curEvects, ~, ~, ~] = Spect(baseIm, [1+200*(i-1) 1+200*(j-1)],200,sigm,neighborCond,NNnum,randCond,randNum,distCond,cutoff,sigmDist,eigNum);
    [kMap, centroids] = kmeans(curEvects,kNum);
    fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) = reshape(kMap, [200 200]);
    fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) = fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) + kNum*(j+(i-1)*4-1);
    eigHolder(:,:,j+(i-1)*4) = curEvects;
    centHolder(:,:,j+(i-1)*4) = centroids;
    disp(['Completed. Took ' num2str(toc) ' seconds']);
    clear curEvects;
    
    %Check i = 3, j = 3 for non-convergence
    %Also, later ones (starting at i = 3, j = 3) tend to take longer and
    %have these problems

    end
end

%Random redistribution of colors so each section will have it's own color,
%but they won't be as likely to be similar to sections in the same segment
reList = randperm(16*kNum);
for i = 1:800
    for j = 1:800
        fullIm(i,j) = reList(fullIm(i,j));
    end
end

%Calculating the average intensities of each section
avList = zeros(16*kNum,2);
origImage = imread(fileName);

for i = 1:800
    for j = 1:800
        avList(fullIm(i,j),1) = avList(fullIm(i,j),1) + 1;
        avList(fullIm(i,j),2) = (avList(fullIm(i,j),2)*(avList(fullIm(i,j),1)-1) + double(origImage(i,j)))/avList(fullIm(i,j),1);
    end
end

colIm = fullIm;
for i = 1:800
    for j = 1:800
        colIm(i,j) = avList(fullIm(i,j), 2);
    end
end