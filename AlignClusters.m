function [new,idx_optim]=AlignClusters(clustering1,clustering2,K)

%Takes two clusterings of a common dataset, and aligns the cluster labels
%as much as possible.  This facilitates superior visualization an meaniful
%quantitative analysis.

%JMM 5-4-17: make sure the set of labels is the same for both clusterings.

LabelNames1=unique(clustering1);
LabelNames2=unique(clustering2);
LabelsUse=setdiff(LabelNames1,LabelNames2);
LabelsChange=setdiff(LabelNames2,LabelNames1);

for i=1:length(LabelsChange)
    clustering2(clustering2==LabelsChange(i))=LabelsUse(i);
end


if K~=length(unique(clustering1))
    % if number of input classes is different from number of labels, do nothing.
    new=[];
else
    
    overlap=zeros(K,K);
    for i=1:K
        for j=1:K
            %overlap(i,j)=length(intersect(find(clustering1==i),find(clustering2==j)));
            overlap(i,j)=sum((clustering1==i).*(clustering2==j));
        end
    end
    
    overlap=overlap';
    
    tic
    
    idxs=perms(1:K);
    
    for i=1:size(idxs,1)
        for j=1:size(idxs,2)
            temp(i,j)=overlap(j,idxs(i,j));
            val(i)=sum(temp(i,:));
        end
    end
    
    [~,optim]=max(val); 

    idx_optim=idxs(optim,:);
    
    new=zeros(size(clustering2));
    for k=1:K
        new(find(clustering2==k))=idx_optim(k);
    end
end
end