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

for i = 1:4
    for j = 1:4
    
    disp(['i = ' num2str(i) ', j = ' num2str(j)]);
    tic;
    [curEvects, ~, ~, ~] = Spect(fileName, [1+200*(i-1) 1+200*(j-1)],200,sigm,neighborCond,NNnum,randCond,randNum,distCond,cutoff,sigmDist);
    fullIm(1+200*(i-1):200*i,1+200*(j-1):200*j) = reshape(kmeans(curEvects,20), [200 200]);
    disp(['Completed. Took ' num2str(toc) ' seconds']);
    clear curEvects;
    
    end
end