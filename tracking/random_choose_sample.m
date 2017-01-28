function [newsample] = random_choose_sample(sampleImage, k)
%% parameters
% - sampleImage: has 4 attributes sx, sy, sw, sh
% - k: the number of selection

%%
number = length(sampleImage.sx);
if k < number
    ind = datasample(1:number, k, 'Replace', false);
else
    ind = 1:number;
end
newsample.sx = sampleImage.sx(ind);
newsample.sy = sampleImage.sy(ind);
newsample.sw = sampleImage.sw(ind);
newsample.sh = sampleImage.sh(ind);

end