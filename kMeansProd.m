profile off;
profile on;

%This is designed to be the counterpart to doubleSpectProd, but it is much
%simpler as it only runs kmeans on the input image and then run kmeans on
%it (Before finding its quality)

resetP = input('Reset parameters? (0/1) '); %Setting all parameters 
if resetP
    fileName = input('Enter file name: ','s');
    sliceList = input('Enter the slices of the image to be used: ([# # #...]) (1-50) ');
    kList = input('Enter the values of k for kmeans: ([# # #...]) ');
    %Note that only 2, 3, 6, and 7 work now in kList since the k needs to 
    %correspond with a gold standard (Only 2 and 3 exist as of writing, and
    %6 takes the default if holes are considering part of the background, and 7 otherwise)
    holesCond = input('Consider light organelles holes? (0/1) ');
end

if holesCond == 0
    holeTitle = 'considered seperate';
else
    holeTitle = 'part of background';
end

curFold = pwd; %The current location is saved here

dateName = datestr(datetime('now'));
for dChange = 1:length(dateName)
    if dateName(dChange) == ':'
        dateName(dChange) = '-';
    end
end

dateName = ['KMEANS_Run ' dateName];

cd('C:\Users\nathan\Documents\JHUImages');
mkdir (dateName);
cd(curFold);

for sliceInd = 1:length(sliceList)
    sliceNum = sliceList(sliceInd);
    for kInd = 1:length(kList)
        k = kList(kInd);
        
        disp(['sliceNum = ' num2str(sliceNum) ', k = ' num2str(k)]);
        
        tic;
        
        curIm = imread(fileName,sliceNum);
        curResult = reshape(kmeans(curIm(:),k,'Replicates',5,'MaxIter',50000),size(curIm,1),size(curIm,2));
        %It's safe to bump up replicates and maxIter because this data is
        %relatively small
        
        if ~holesCond
            if k ~= 7
                curGoldStand = double(cell2mat(struct2cell(load(['goldStand' num2str(k) '.mat']))));
            else
                curGoldStand = double(cell2mat(struct2cell(load('goldStandDefault.mat'))));
            end
        else
            if k ~= 6
                curGoldStand = double(cell2mat(struct2cell(load(['goldStand' num2str(k) '_holes.mat']))));
            else
                curGoldStand = double(cell2mat(struct2cell(load('goldStandDefault_holes.mat'))));
            end
        end
        
        curGoldStand = curGoldStand(:,:,sliceNum); %Gets the gold standard for comparison
        
        [intersection, confMat] = compByIntersect(curGoldStand,curResult,k);
        
        intersection = intersection*100; %Bumps up for percentage
        if intersection < 0.1
            intersection = 0;
        end
        
        interTitle = num2str(intersection);
        titleCutoff = floor(log(intersection)/log(10))+1;
        interTitle = interTitle(1:titleCutoff+2);
        
        colormap(jet); curVisual = imagesc(curResult); colorbar; title(['Quality: ' interTitle '%, Light organelles ' holeTitle]);
        cd(['C:\Users\nathan\Documents\JHUImages\' dateName]);
        saveas(curVisual,['db4_KMEANS_k_' num2str(k) '_Slice-' num2str(sliceNum) '.tif']);
        cd(curFold);
        
        disp(['Completed in ' num2str(toc) ' seconds.']);
    end
end
