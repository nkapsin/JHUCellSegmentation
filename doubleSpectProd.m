profile off;
profile on;

%Same as SpectDistSegs, but run many times to create a collection of images

resetP = input('Reset parameters? (0/1) ');
if resetP
    fileName = input('Enter file name: ','s');
    sigm = input('Enter sigma for intensity similarity: ');
    NNnum = input('(NN) Enter neighbor count: ');
    cutoff = input('(SR) What radius? ');
    sigmDist = input('(SR) Enter sigma for distance similarity: ');
    holesCond = input('Consider light organelles holes? (0/1) ');
end

sliceList = [39 1 14 25 50];


kVarStart = 2;
kRange = 1;

randCond = 0;
randNum = -1;

curFold = pwd;

confHolder = cell(2,5,3,kRange+1,4);

for metType = 1:2
    if metType == 1
        neighborCond = 0;
        distCond = 1;
        methodType = 'SR';
        nTitle = (cutoff*2+1)^2-1;
    else
        neighborCond = 1;
        distCond = 0;
        methodType = 'NN';
        nTitle = NNnum;
    end
    
    condList = [sigm, neighborCond, NNnum, randCond, randNum, distCond, cutoff, sigmDist, 20];

    for sliceIndex = 1:5
        sliceNum = sliceList(sliceIndex);
        baseIm = imread(fileName, sliceNum);
        
        [eigHolder, imagList] = segEigs(baseIm, condList, 20);
        
        for varEigs = 1:3
            numEigs = 5+ceil((varEigs-1)/2)*5+floor((varEigs-1)/2)*10;
            for varK = kVarStart:kVarStart+kRange
                
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
                
                for varSectK = 10:5:25
                    cd(curFold); %Resetting every time in case I break out
                    tic;
                    
                    disp('Starting doubleSpectKmeans...');
                    
                    [fullIm, avList] = doubleSpectKmeans(varSectK,eigHolder,numEigs,baseIm);

                    %All the download stuff. spectAvs does the second spectral
                    %clustering.
                    
                    if isempty(imagList)
                        imagList = 'None';
                    end
                    
                    [a, b, c] = spectAvs(avList(:,2), varK, 5, ceil((16*varSectK)/10), fullIm);
                    valsVects = cell(2,1);
                    valsVects{2} = b;
                    valsVects{1} = c;
                    
                    disp(['varK = ' num2str(varK) ' and varSectK = ' num2str(varSectK) ' took ' num2str(toc) ' seconds']);
                    
                    cd('C:\Users\nathan\Documents\MATLAB');
                    
                    [intersection, confMat] = compByIntersect(curGoldStand,a,varK);
                    intersection = intersection*100;
                    if intersection < 0.1
                        intersection = 0;
                    end
                    interTitle = num2str(intersection);
                    titleCutoff = floor(log(intersection)/log(10))+1;
                    interTitle = interTitle(1:titleCutoff+2);
                    
                    confHolder{metType,sliceIndex,varEigs,varK-1,varSectK/5-1} = confMat;
                    
                    disp('Saving...');
                    
                    colormap(jet); curIm = imagesc(a); colorbar; title(['Quality: ' num2str(interTitle) '%  Imag:  ' imagList]);
                    cd(['C:\Users\nathan\Documents\MATLAB\DoubleSpectCollect\New\' methodType '\DoubleSpect']);
                    saveas(curIm,['db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '.tif']);
                    cd(['C:\Users\nathan\Documents\MATLAB\DoubleSpectCollect\New\' methodType '\DoubleSpectMats']);
                    save(['db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '.mat'],'a');        
                    cd(['C:\Users\nathan\Documents\MATLAB\DoubleSpectCollect\New\' methodType '\DoubleSpectEigs']);
                    save(['EIGS_db4_Slice-' num2str(sliceNum) '_' methodType '_DoubleSpect_Neighbors-' num2str(nTitle) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '.mat'],'valsVects');        
                end
            end
        end
    end
end