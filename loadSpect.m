function [returnMat] = loadSpect(slice,method,neighbors,numEigs,varK,varSectK)
imTitle = ['db4_Slice-' num2str(slice) '_' method '_DoubleSpect_Neighbors-' num2str(neighbors) '_numEigs-' num2str(numEigs) '_varK-' num2str(varK) '_varSectK-' num2str(varSectK) '.mat'];
curFold = pwd;
cd(['C:\Users\nathan\Documents\MATLAB\DoubleSpectCollect\New\' method '\DoubleSpectMats']);
returnMat = loadMat(imTitle);
cd(curFold);
end

