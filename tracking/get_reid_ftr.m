function [samplesFtrVal] = get_reid_ftr(sampleImage, img_color, M, Net)
%% parameters
% sampleImage: sample images as inputs
% M: the number of all weaker classifiers, i.e,feature pool
% Net: reid net as default 


%% extract deep feature from reid net
num_feat = length(sampleImage.sx);
samplesFtrVal = zeros(M, num_feat);
for i = 1:num_feat
    img = img_color(sampleImage.sy(i):sampleImage.sy(i)+sampleImage.sh(i), ...
                sampleImage.sx(i):sampleImage.sx(i)+sampleImage.sw(i), :);
    samplesFtrVal(:,i) = extract_reid_feature(img, Net);
end

end


function [feature] = extract_reid_feature(img, net)

input_img = imresize(img, [144, 56], 'bicubic');
input_img = permute(input_img,[2,1,3]);
feature = net.forward({gpuArray(input_img)});
feature = double(feature{1});

end