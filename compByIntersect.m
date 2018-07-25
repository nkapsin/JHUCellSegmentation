function [intersection, confMat] = compByIntersect(comper,compee,k)

newCompee = reshape(AlignClusters(comper(:),compee(:),k), [800 800]);

intersectCount = 0;

confMat = zeros(k);

for i = 1:size(comper,1)
    for j = 1:size(comper,2)
        if comper(i,j) == newCompee(i,j)
            intersectCount = intersectCount + 1;
        end
        confMat(comper(i,j),newCompee(i,j)) = confMat(comper(i,j),newCompee(i,j)) + 1;
        %Column is correct, row is our model
    end
end

intersection = intersectCount/length(comper(:));

end

