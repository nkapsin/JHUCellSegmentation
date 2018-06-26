function [nSparse] = NNSort(image,sigma,k)

%image = imnoise(image, 'gaussian', 0.01, 0.000001);

[valList, indexList] = sort(double(image(:)));
kFiller = double(-1000);

imLength = length(image(:));
sparseCoords = zeros(imLength*k,2);
sparseVal = zeros(imLength*k,1);
valList = [kFiller valList' kFiller];
indexList = [kFiller indexList' kFiller];

for i = 1:length(valList)
    Lstep = 1;
    Rstep = 1;
    if indexList(i) ~= kFiller
        for j = 1:k
            if j == 1
                sparseVal(j+k*(i-2)) = 1; %0
                sparseCoords(j+k*(i-2),1) = indexList(i);
                sparseCoords(j+k*(i-2),2) = indexList(i);
            elseif abs(valList(i-Lstep) - valList(i)) > abs(valList(i+Rstep) - valList(i))%exp(-abs(valList(i-Lstep)-valList(i))^2/(sigma^2)) < exp(-abs(valList(i)-valList(i+Rstep))^2/(sigma^2))
                %sparseVal(j+k*(i-2)) = abs(valList(i+Rstep) - valList(i)); %exp(-abs(valList(i)-valList(i+Rstep))^2/(sigma^2));
                sparseVal(j+k*(i-2)) = exp(-abs(valList(i+Rstep) - valList(i))^2/sigma^2); 
                sparseCoords(j+k*(i-2),1) = indexList(i);
                sparseCoords(j+k*(i-2),2) = indexList(i+Rstep);
                Rstep = Rstep + 1;
            else
                %sparseVal(j+k*(i-2)) = abs(valList(i-Lstep) - valList(i)); %exp(-abs(valList(i)-valList(i-Lstep))^2/(sigma^2)); 
                sparseVal(j+k*(i-2)) = exp(-abs(valList(i-Lstep) - valList(i))^2/sigma^2);
                sparseCoords(j+k*(i-2),1) = indexList(i);
                sparseCoords(j+k*(i-2),2) = indexList(i-Lstep);
                Lstep = Lstep + 1;
            end
        end
    end    
end
nSparse = sparse(sparseCoords(:,1), sparseCoords(:,2), sparseVal, imLength, imLength, imLength*k);
nSparse = max(nSparse,nSparse');


%{
for  i = 1:length(sparseVal)
    sparseVal(i) = exp(-sparseVal(i)^2/sigma^2);
end
%}


%{
AutoSigma = sigma;

%Inflection at non-repeated median of non-zero entries


for i = 1:imLength
    %{
    j = 1;
    AutoSigma = 0;
    tempVec = zeros(k,1);
    f = 0;
    lastNum = 0;
    while j <= k
        if sparseVal(k*(i-1)+j) ~= lastNum %0
            f = f + 1;
            tempVec(f) = sparseVal(k*(i-1)+j);
            lastNum = sparseVal(k*(i-1)+j);
        end
        j = j+1;
    end
    if f == 0
        AutoSigma = 0.5;
    else
        AutoSigma = 4*median(tempVec(1:f));
    end
    %}
    for j = 1:k
        sparseVal(k*(i-1)+j) = exp(-sparseVal(k*(i-1)+j)^2/AutoSigma^2);
    end

end
%}