function [eigHolder,imagList] = segEigs(baseIm,condList,maxEigs)

imagList = '';
eigHolder = zeros(200*200, maxEigs, 16);
        
for i = 1:4
    for j = 1:4
        disp(['i = ' num2str(i) ', j = ' num2str(j)]);
        tic;
        [curEvects, ~, ~, curEvals] = Spect(baseIm, [1+200*(i-1) 1+200*(j-1)],200,condList);
        disp(['Completed. Took ' num2str(toc) ' seconds']);

        if (~isreal(curEvects) || ~isreal(curEvals))
            imagList = [imagList '_' num2str(i) '-' num2str(j)];
        end
        
        curEvects = real(curEvects);
        [~, eigValInds] = sort(diag(real(curEvals)));
        newCurEvects = curEvects;
        for sorter = 1:length(eigValInds)
            newCurEvects(:,sorter) = curEvects(:,eigValInds(sorter));
        end
        eigHolder(:,:,j+(i-1)*4) = newCurEvects;
    end
end

end