function [nSparse] = WMDist(image,sigmInt,sigmDist,r)

l = size(image); %l represents both length and width here, in a vector
image = double(image); %exp doesn't like working with uint8

coords = zeros(l(1)*l(2)*(2*r+1)^2,2); %The length overestimates, assuming each pixel would check every other in  a radius, assuming there are no boundaries
vals = zeros(l(1)*l(2)*(2*r+1)^2,1);
disparity = 0; %For subtracting when borders are hit

%Although matrices entered into this function should be square, the
%option to input a rectangular one should be preserved
for i = 1:l(1)*l(2) %The linear index of each element
    for jo = -r:r %io and jo are used to check the elements around the one selected by i
        for io = -r:r
            %Making sure the index hasn't looped around with the first
            %condidion
            %The second checks to see if j has put it out of bounds
            %disp([num2str(i) '_' num2str(io) '_' num2str(jo)]);
            curLoc = (i-1)*(2*r+1)^2 + io+r+1 + (jo+r)*(2*r+1) - disparity; %(jo+r) = (jo+r+1-1)
            
            if ceil((i+io)/l(1)) == ceil(i/l(1)) && (i+io+jo*l(1) >= 1 && i+io+jo*l(1) <= l(1)*l(2))
                coords(curLoc,1) = i;
                coords(curLoc,2) = i+io+l(1)*jo;
                vals(curLoc) = exp(-(image(i)-image(i+io+jo*l(1)))^2/sigmInt^2 - (io^2+jo^2)/sigmDist^2); %The similarity. io and jo mark the vertical and horizontal distance from the point at i
            else
                disparity = disparity + 1; %If the point is outside the edges of the images, we can move back
            end
        end
    end
end

coords = coords(1:length(coords)-disparity,:); %Cutting out extra zeros
vals = vals(1:length(vals)-disparity);

%It should be possible to preallocate for these without having to cut off
%zeros later, but attempting to do this led to a string of wrong results
%and this sacrifice isn't too considerable.

nSparse = sparse(coords(:,1), coords(:,2), vals, l(1)*l(2), l(1)*l(2), length(coords));
end