function [] = compareImages(colorMap,varargin)

numIms = length(varargin);

size1 = ceil((-1+sqrt(1+numIms*4))/2);
size2 = ceil(sqrt(numIms));

figure
colormap(colorMap)
for i = 1:length(varargin)
subplot(size1,size2,i)
imagesc(varargin{i});
title(['Image ' num2str(i)]);
end

end

%{
figure
subplot(2,2,1)       % add first plot in 2 x 2 grid
colormap(colorcube); imagesc(curGoldStand);    % line plot
title('Subplot 1')

subplot(2,2,2)       % add second plot in 2 x 2 grid
imagesc(dab)       % scatter plot
title('Subplot 2')

subplot(2,2,3)       % add third plot in 2 x 2 grid
colormap(jet); imagesc(showMe); colorbar;       % stem plot
title('Subplot 3')
%}