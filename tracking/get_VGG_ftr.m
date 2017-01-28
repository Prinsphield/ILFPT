function [samplesFtrVal] = get_VGG_ftr(sampleImage, img_color, M, Net, config)
%% parameters
% sampleImage: sample images as inputs
% M: the number of all weaker classifiers, i.e, feature pool
% Net: VGG net as default 
% config: Net config 

%% extract deep feature from deep net
num_feat = length(sampleImage.sx);
imgs = cell(1,num_feat);
for i = 1:num_feat
    imgs{i} = img_color(sampleImage.sy(i):sampleImage.sy(i)+sampleImage.sh(i), ...
                sampleImage.sx(i):sampleImage.sx(i)+sampleImage.sw(i), :);
end
ftrs = extract_feat_single(imgs, Net, config);

% img = img_color(sampleImage.sy(1):sampleImage.sy(1)+sampleImage.sh(1), ...
%                 sampleImage.sx(1):sampleImage.sx(1)+sampleImage.sw(1), :);
% tmp = extract_feat_single(img, Net, config);
% ftrs = zeros(length(tmp), num_feat);
% ftrs(:,1) = tmp;
% for i = 2:num_feat
%     img = img_color(sampleImage.sy(i):sampleImage.sy(i)+sampleImage.sh(i), ...
%                 sampleImage.sx(i):sampleImage.sx(i)+sampleImage.sw(i), :);
%     ftrs(:,i) = extract_feat_single(img, Net, config);
% end

%% random projection
samplesFtrVal = datasample(ftrs, M, 1, 'Replace', false);

end