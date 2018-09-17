profile off;
profile on;

%Makes a collection of images with variations on slice, k in various
%kmeans, method, etc.

%Since some directories are referenced, and will need to be changed based
%on computer, I've commented a "DIRECT" next to all of those locations to
%make them easier to change

%The program has been made to have many more inputs than previously. Some
%common choices are: (top to bottom)
%{
db4map.tif: fileName = input('Enter file name: ','s');
5: sigm = input('Enter sigma for intensity similarity: ');
1368: NNnum = input('(NN) Enter neighbor count: ');
18: cutoff = input('(SR) What radius? '); %A radius of r will use (2*r+1)^2-1 neighbors
100: sigmDist = input('(SR) Enter sigma for distance similarity: ');
1: holesCond = input('Consider light organelles holes? (0/1) ');
2: kVarStart = input('Enter the starting k for the second kmeans'); %Defines the range of k values for the second kmeans
3: kVarEnd = input('Enter the ending k for the second kmeans');
(15:5:25): kVarSectList = input('Enter the list of k values for the 200x200 kmeans: ([# # #...]) ');
[39 1 14 25 50]: sliceList = input('Enter the slices of the image to be used: ([# # #...]) (1-50) ');
[5 10 20]: eigsVarList = input('Enter the list of eigenvector numbers for the 200x200 Spectral Clustering: ([# # #...]) ');
[2 Inf]: normList = input('Enter the list of norms for the second spectral clustering: ([# # #...]) ');
%}

%Since the program runs for a while, I decided to add more options for the
%user, since the script will take ages anyway.

%If we don't want to vary on a parameter, we can just enter one number

resetP = input('Reset parameters? (0/1) '); %Setting all parameters 
if resetP
    fileName = input('Enter file name: ','s');
    sigm = input('Enter sigma for intensity similarity: ');
    NNnum = input('(NN) Enter neighbor count: ');
    cutoff = input('(SR) What radius? '); %A radius of r will use (2*r+1)^2-1 neighbors
    sigmDist = input('(SR) Enter sigma for distance similarity: ');
    holesCond = input('Consider light organelles holes? (0/1) ');
    kVarStart = input('Enter the starting k for the second kmeans: '); %Defines the range of k values for the second kmeans
    kVarEnd = input('Enter the ending k for the second kmeans: ');
    kVarSectList = input('Enter the list of k values for the 200x200 kmeans: ([# # #...]) ');
    sliceList = input('Enter the slices of the image to be used: ([# # #...]) (1-50) ');
    eigsVarList = input('Enter the list of eigenvector numbers for the 200x200 Spectral Clustering: ([# # #...]) ');
    normList = input('Enter the list of norms for the second spectral clustering: ([# # #...]) ');
end

randCond = 0; %Leftovers from when we were considering adding random edges
randNum = -1;

curFold = pwd; %The current location is saved here

%Each run gets saved in its own folder, with the title including the time
%the data was created. This makes that title, and then folder, then subfolders.
%DIRECT.
dateName = datestr(datetime('now'));
for dChange = 1:length(dateName)
    if dateName(dChange) == ':'
        dateName(dChange) = '-';
    end
end

dateName = ['Run ' dateName];

cd('C:\Users\nathan\Documents\JHUImages');
mkdir (dateName);
cd(['C:\Users\nathan\Documents\JHUImages\' dateName]);
mkdir DoubleSpect;
mkdir DoubleSpectEigs;
mkdir DoubleSpectMats;
mkdir wMandLrw;
mkdir SingleSpectSections;
cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\DoubleSpect']);
mkdir NN;
mkdir SR;
cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\DoubleSpectEigs']);
mkdir NN;
mkdir SR;
cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\DoubleSpectMats']);
mkdir NN;
mkdir SR;
cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\SingleSpectSections']);
mkdir NN;
mkdir SR;

cd(curFold);

confHolder = cell(2,5,3,kVarEnd-kVarStart+1,4); %Confusion matrix holder

%qualHolder will hold the percentages for every variation. The order of
%slots goes as it appears in the program:
%(Method type, Slice #, # of eigenfunctions, k for 2nd kmeans, k for
%200x200 kmeans, norm)
%At the end, qualHolder will be saved under a name that includes
%information about the parameters that did not vary among all slices
qualHolder = zeros(2,length(sliceList),length(eigsVarList),kVarEnd-kVarStart,length(kVarSectList),length(normList));

%{
Variation hierarchy, from outermost to innermost:
-Method (NN or SR)
-Slice #
-Number of eigs
-Overall k for kmeans
-200x200 k for kmeans
-Norm
%}

for metType = 1:2
    if metType == 2 %The method is decided here. The number can be switched between 2 and 1 if we want to run one method before the other
        neighborCond = 0;
        distCond = 1;
        methodType = 'SR';
        nTitle = (cutoff*2+1)^2-1; %The number of neighbors
    else
        neighborCond = 1;
        distCond = 0;
        methodType = 'NN';
        nTitle = NNnum;
    end
    
    condList = [sigm, neighborCond, NNnum, randCond, randNum, distCond, cutoff, sigmDist, max(eigsVarList)];

    for sliceIndex = 1:length(sliceList)
        sliceNum = sliceList(sliceIndex);
        baseIm = imread(fileName, sliceNum); %Reads current slice. Assumes .tif file, which our data is in
        
        [eigHolder, imagList] = segEigs(baseIm, condList, max(eigsVarList)); %Returns the eigenValues, along with the locations of any eigs that did not converge and produced imaginary eigenfunctions/values
        
        for varEigs = 1:length(eigsVarList)
            numEigs = eigsVarList(varEigs);
            for varK = kVarStart:kVarEnd
                
                if ~holesCond
                    if varK ~= 7
                        curGoldStand = double(cell2mat(struct2cell(load(['goldStand' num2str(varK) '.mat']))));
                    else
                        curGoldStand = double(cell2mat(struct2cell(load('goldStandDefault.mat'))));
                    end
                else
                    if varK ~= 6
                        curGoldStand = double(cell2mat(struct2cell(load(['goldStand' num2str(varK) '_holes.mat']))));
                    else
                        curGoldStand = double(cell2mat(struct2cell(load('goldStandDefault_holes.mat'))));
                    end
                end
                
                curGoldStand = curGoldStand(:,:,sliceNum);
                
                for varSectKInd = 1:length(kVarSectList)
                    varSectK = kVarSectList(varSectKInd);
                    for normInd = 1:length(normList)
                        normNum = normList(normInd);
                        cd(curFold); %Resetting every time in case I break out
                        tic;

                        disp('Starting doubleSpectKmeans...');

                        [fullIm, avList] = doubleSpectKmeans(varSectK,eigHolder,numEigs,baseIm);

                        %All the download stuff. spectAvs does the second spectral
                        %clustering.

                        if isempty(imagList)
                            imagList = 'None';
                        end

                        [a, b, c, ~, d, e] = spectAvs(avList(:,2), varK, 5, ceil((16*varSectK)/10), fullIm, normNum);
                        valsVects = cell(2,1);
                        valsVects{2} = b;
                        valsVects{1} = c;

                        disp(['varK = ' num2str(varK) ', varSectK = ' num2str(varSectK) ', and norm = ' num2str(normNum) ' took ' num2str(toc) ' seconds']);

                        cd('C:\Users\nathan\Documents\SourceTree\JHUCellSegmentation'); %DIRECT. The directory the script is in

                        [intersection, confMat] = compByIntersect(curGoldStand,a,varK);
                        intersection = intersection*100;
                        if intersection < 0.1
                            intersection = 0;
                        end

                        %{
                        interTitle = num2str(intersection);
                        titleCutoff = floor(log(intersection)/log(10))+1;
                        interTitle = interTitle(1:titleCutoff+2);
                        %}
                        
                        interTitle = num2str(intersection);
                        
                        confHolder{metType,sliceIndex,varEigs,varK-1,varSectK/5-1} = confMat;

                        disp('Saving...');

                        %DIRECT. Three locations for images/matrices to be
                        %saved

                        colormap(jet); curIm = imagesc(a); colorbar; title(['Quality: ' num2str(interTitle) '% Imag:  ' imagList]);
                        cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\DoubleSpect\' methodType]);
                        saveas(curIm,['db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_' num2str(interTitle) '%_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '_norm-' num2str(normNum) '.tif']);
                        cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\DoubleSpectMats\' methodType]);
                        save(['db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_' num2str(interTitle) '%_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '_norm-' num2str(normNum) '.mat'],'a');        
                        cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\DoubleSpectEigs\' methodType]);
                        save(['EIGS_db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_' num2str(interTitle) '%_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '_norm-' num2str(normNum) '.mat'],'valsVects');        
                        cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\wMandLrw']);
                        save(['matrix_db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_' num2str(interTitle) '%_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '_norm-' num2str(normNum) '_wM.mat'],'d');
                        save(['matrix_db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_' num2str(interTitle) '%_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '_norm-' num2str(normNum) '_Lrw.mat'],'e');
                        colormap(colorcube); segIm = imagesc(fullIm); colorbar; title(['Quality: ' num2str(interTitle) '% Imag:  ' imagList]);
                        cd(['C:\Users\nathan\Documents\JHUImages\' dateName '\SingleSpectSections\' methodType]);
                        saveas(segIm,['db4_Slice-' num2str(sliceNum) '_' methodType '_SingleSpect_' num2str(interTitle) '%_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '_norm-' num2str(normNum) '.tif']);
                        
                        cd('C:\Users\nathan\Documents\SourceTree\JHUCellSegmentation');
                        
                        qualHolder(metType, sliceIndex, varEigs, varK-kVarStart+1, varSectKInd, normInd) = intersection;
                    end
                end
            end
        end
    end
end
cd(['C:\Users\nathan\Documents\JHUImages\' dateName]);
save(['qualHolder_' fileName(1:find(fileName == '.')-1) '_Sigma-' num2str(sigm) '_NNs-' num2str(NNnum) '_SRrad-' num2str(cutoff) '_SRsigm-' num2str(sigmDist) '_holes-' num2str(holesCond) '.mat'], 'qualHolder');
%{
numList = [1 14 25 39 50];
list = [qualHolder23NN1 qualHolder23NN14 qualHolder23NN25 qualHolder23NN39 qualHolder23NN50 qualHolder23SR1 qualHolder23SR14 qualHolder23SR25 qualHolder23SR39 qualHolder23SR50];
list2 = [qualHolder7NN1 qualHolder7NN14 qualHolder7NN25 qualHolder7NN39 qualHolder7NN50 qualHolder7SR1 qualHolder7SR14 qualHolder7SR25 qualHolder7SR39 qualHolder7SR50];
list = [list list2];
for i = 1:length(list)
    disp(max(reshape(list(i),[1 size(list(i),1)*size(list(i),2)])));
    %}