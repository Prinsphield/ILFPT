function feats = extract_feat_single(imgs, net, config)
% Input:
%       net: caffeNet built by caffe.net()
%       imgs: cell or array, images to extract features, image mode = RGB
%       config: struct, contains:
%           IMAGE_DIM: network's input image dim
%           mean_data: network's mean data(mean_image)
%           bPermute: whether to permute
%           permute_param: how to flip data, i.e. permute(img, permute_param)
%           img_mode: image mode of network's input, if is not RGB, perform
%                     transformation.
%           layers: cell(extract more than one feat) or str(extract one feat),
%                     feature layer(name, str) to extract
% Output:
%       feats: cell or array, if more than one features are extracted,
%               return a cell array, else return a array
IMAGE_DIM = config.IMAGE_DIM;
mean_data = config.mean_data;
if isa(imgs, 'cell')
    N = length(imgs);
else
    imgs = {imgs};
    N = 1;
end
feats = cell(N, 1);

if isfield(config, 'img_mode')
    img_mode = config.img_mode;
    switch(lower(img_mode))
        case 'rgb'
            channel = [1,2,3];
        case 'rbg'
            channel = [1,3,2];
        case 'gbr'
            channel = [2,3,1];
        case 'grb'
            channel = [2,1,3];
        case 'bgr'
            channel = [3,2,1];
        case 'brg'
            channel = [3,1,2];   
    end
else
    channel = [3,2,1]; % for VGGNet
end

if isfield(config, 'bPermute')
    bPermute = config.bPermute;
else
    bPermute = 1;
end

if bPermute
    if isfield(config, 'permute_param')
        permute_param = config.permute_param;
    else
        warning(['bPermute is on, however, permute_param is not yet been set!',...
        'Auto set to default, permute_param = [2,1,3].'])
        permute_param = [2,1,3]; % For VGGNet
    end
end

if isfield(config, 'layers')
    layers = config.layers;
    if isa(layers, 'cell')
        m = length(layers);
        if m == 1
            layers = layers{1};
        end
    end
else
    layers = '';
end

for i = 1:N
    img = single(imgs{i}(:,:,channel));
    if bPermute
        img = permute(img, permute_param);
    end
    if size(img, 1) ~= IMAGE_DIM || size(img, 2) ~= IMAGE_DIM
        img = imresize(img, [IMAGE_DIM IMAGE_DIM], 'bicubic');  % resize im_data
    end
    img = img - single(mean_data);
    score = net.forward({img});
    if isa(layers, 'cell')
        tmp = cell(m,1);
        for j = 1:m
            tmp{j} = reshape(net.blobs(layers{j}).get_data(), [], 1);
        end
        feats{i} = cell2mat(tmp);
    else
        if strcmp(layers, '')
            feats{i} = score;
        else
            feats{i} = reshape(net.blobs(layers).get_data(), [], 1);
        end
    end
end

feats = cell2mat(feats);
end