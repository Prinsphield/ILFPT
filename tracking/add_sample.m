function [sample] = add_sample(sample, newsample, memory)
% combine old and new samples
if numel(newsample.sampleImage.sx) ~= 0
    sample.feature = [sample.feature, newsample.feature];

    sample.sampleImage.sx = [sample.sampleImage.sx, newsample.sampleImage.sx];
    sample.sampleImage.sy = [sample.sampleImage.sy, newsample.sampleImage.sy];
    sample.sampleImage.sw = [sample.sampleImage.sw, newsample.sampleImage.sw];
    sample.sampleImage.sh = [sample.sampleImage.sh, newsample.sampleImage.sh];

    if memory < size(sample.feature,2)
        ind = datasample(1:size(sample.feature,2), memory, 'Replace', false);
    else
        ind = datasample(1:size(sample.feature,2), memory);
    end
    sample.feature = sample.feature(:,ind);

    sample.sampleImage.sx = sample.sampleImage.sx(ind);
    sample.sampleImage.sy = sample.sampleImage.sy(ind);
    sample.sampleImage.sw = sample.sampleImage.sw(ind);
    sample.sampleImage.sh = sample.sampleImage.sh(ind);

end

end