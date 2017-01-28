function [reidNet] = init_reid_Net()
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
net_model = './reid_net/jstl_dgd_deploy_inference.prototxt';
net_weights = './reid_net/jstl_dgd_inference.caffemodel';

phase = 'test';         % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please train CaffeNet before you run this function.');
end
reidNet = caffe.Net(net_model, net_weights, phase);


end