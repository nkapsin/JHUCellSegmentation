profile off;
profile on;

%{
This program runs the Spect function. It's largely purposed to accept
various user inputs
%}

%Parameters don't need to be typed in again if only some of the code is
%changed, so this saves a little of the user's time
resetP = input('Reset parameters? (0/1) ');
if resetP
    randCond = 0;
    distCond = 0;
    fileName = input('Enter file name: ','s');
    startCoords = input('Enter starting coordinates: ([# #]) '); 
    %Starting coordinates indicate the first corner point that will be
    %used. (e.g. [1 1] will make the segment have the pixel at [1 1] in the upper left corner
    segLength = input('Enter length of square segment: '); %All segments are square
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
            cutoff = input('What radius? '); %The radius defines a square box around each pixel. r = 1 makes a 3x3 box, r = 2 makes a 5x5 box, r = n makes a 2n+1x2n+1 box
            sigmDist = input('Enter sigma for distance similarity: ');
        else
            cutoff = -1;
            sigmDist = -1;
        end
    end 
end

[eVecs, Lrw, wM, eVals] = Spect(fileName,startCoords,segLength,sigm,neighborCond,NNnum,randCond,randNum,distCond,cutoff,sigmDist);

%{
Putting a very low sigma value seems to work for showing the small dark
organelles in NNSort, but has side affects. The first two eigenvectors show
nothing, and only the third reveals the larger structure with slight detail
errors. The 4th and on tend to highlight the darker, smaller organelles.
See db4_[1 1]_100_1_500
Moving sigma up to 5 instead of 1 makes half-good values appear much later
However, moving NN up to 1000 makes these good results appear even earlier,
even with 5 (Hardly any difference between eigs 1 & 2 though)

To do: Make NNRandSort choose a random set of extra edges in total, not a
random set of extra edges per pixel

Using all eigenvectors in the full Kmeans sometimes works, but often
results in a distorted image. Need a cutoff. For the 100-100 starting at
400,50, this cutoff is at eig3. After that consistency is almost ensured
However, after that things are worse; 1-2 is more reliable than all, but
still reasonably unreliable

Supposedly the number of ~0 eigenvals should show how many sections there
are... somewhat appears

Eigs seems to run much more quickly at [400 50]...
%}