function [VGGNet, VGGconfig] = init_VGGNet()
%% Set caffe mode
use_gpu = 1;
gpu_id = 0;         % we will use the first gpu in this demo
if use_gpu
  caffe.set_mode_gpu();
  caffe.set_device(gpu_id);
else
  caffe.set_mode_cpu();
end

%% Initialize the network
net_model = './VGG16/vgg16.prototxt';
net_weights = './VGG16/VGG_ILSVRC_16_layers.caffemodel';


phase = 'test';         % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please train CaffeNet before you run this function.');
end
VGGNet = caffe.Net(net_model, net_weights, phase);

%% Load the mean data
VGGconfig.IMAGE_DIM = 224;
% CROPPED_DIM = 227;
mean_data = zeros(1,1,3);
mean_data(1,1,:) = [103.939, 116.779, 123.68];
VGGconfig.mean_data = single(repmat(mean_data, VGGconfig.IMAGE_DIM, VGGconfig.IMAGE_DIM, 1));
VGGconfig.layers = 'pool3'; % if more than one layers, use a cell array.
VGGconfig.bPermute = 1;
VGGconfig.permute_param = [2,1,3];
VGGconfig.img_mode = 'bgr';
% VGGconfig.batch_size = 1;

end

% % example:
% [VGGNet, VGGconfig] = init_VGGNet();
% % load images to imgs
% extracted_feats = extract_feat2(VGGNet, imgs, VGGconfig);


