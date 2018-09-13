sliceList = [1 14 25 39 50];

%1 - Method
%2 - Slice
%3 - Eig number
%4 - K2
%5 - K1
%6 - Norm

for method = 1:2
    if method == 1
        curMethod = 'NN';
    else
        curMethod = 'SR';
    end
    
    meanMaker = 0.*squeeze(qualHolder(method,1,:,:,:,:));
    
    for slice = 1:5
        curHolder = squeeze(qualHolder(method,slice,:,:,:,:));
        
        curMax = -1;
        c1 = 1;
        c2 = 1;
        c3 = 1;
        c4 = 1;
        for ca = 1:size(curHolder,1)
            for cb = 1:size(curHolder,2)
                for cc = 1:size(curHolder,3)
                    for cd = 1:size(curHolder,4)
                        if curHolder(ca,cb,cc,cd) > curMax
                            curMax = curHolder(ca,cb,cc,cd);
                            c1 = ca;
                            c2 = cb;
                            c3 = cc;
                            c4 = cd;
                        end
                    end
                end
            end
        end
        %{
        curMax = max(curHolder(:));
        %MATLAB is being a pain and won't give me an easy way to find the
        %indices of a maximum from an arbitrarily dimensioned matrix, so
        %I'm assuming that the input is going to be 4 as I have been doing
        %anyway
        [c1,c2,c3,c4]  = ind2sub(size(curHolder),curMax);
        %}
        meanMaker = (meanMaker.*(slice-1) + curHolder)./slice;
        disp([num2str(c1) ' ' num2str(c2) ' ' num2str(c3) ' ' num2str(c4) ' max for slice ' num2str(slice) ' and ' curMethod ' is ' num2str(curMax)]);
    end
    
    curMax = -1;
    c11 = 1;
    c22 = 1;
    c33 = 1;
    c44 = 1;
    for ca = 1:size(meanMaker,1)
        for cb = 1:size(meanMaker,2)
            for cc = 1:size(meanMaker,3)
                for cd = 1:size(meanMaker,4)
                    if meanMaker(ca,cb,cc,cd) > curMax
                        curMax = meanMaker(ca,cb,cc,cd);
                        c11 = ca;
                        c22 = cb;
                        c33 = cc;
                        c44 = cd;
                    end
                end
            end
        end
    end
    
    %{
    curMax2 = max(meanMaker(:));
    [c11,c22,c33,c44,c55]  = ind2sub(size(curHolder),curMax2);
    %}

    disp([num2str(c11) ' ' num2str(c22) ' ' num2str(c33) ' ' num2str(c44) ' optimizes mean for method ' curMethod ' which is ' num2str(curMax)]);
end

%{
NN:
Max slice 1: 10 eigs, 2 K2, 50/40 K1 norm Inf
slice 14: 10 eigs, 2 K2, 20 K1, norm Inf
slice 25: 20 eigs, 2 K2, 40 K1, norm Inf
slice 39: 5 eigs, 2 K2, 15 K1, norm Inf
slice 50: 5 eigs, 2 K2, 15 K1, norm Inf
Max mean over slices: 10 eigs, 2 K2, 50 K1, norm Inf
Every single SR but slice 1 maxes on 10 eigs


-Split k2
-Rep ex. 6/7 NN/SR
-Also show othr denois
%}