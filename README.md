# Integrated Learning Framework for Pedestrian Tracking

### Introduction

ILFPT is in integrated framework designed for pedestrian tracking, especially in the surveillance videos.


### Requirements 

1. `Caffe` (see `external/caffe/`)
1. MATLAB
1. GPU: GTX 980/1080, Tesla K20/K40/K80  


# Preparation for Testing:

0.  `git clone --recursive https://github.com/Prinsphield/ILFPT.git`
0.  Build Caffe in the `external/caffe`
0.  Download the test videos from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCS0lDbmg4NzkxZzQ) or [BaiduPan](https://pan.baidu.com/s/1cvgkJ8) and extract them into the 'test/' directory
0.  Download the detection network model from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCaGxfSVJYNXN5X3c) or [BaiduPan](http://pan.baidu.com/s/1mhWzjOs) and extract into `models/` directory
0.  Download our pretrained detection network from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCcy12RGF2MVVBQW8) or [BaiduPan](http://pan.baidu.com/s/1gePhQdd) and extract into `output/` directory
0.  Download the pretrained re-id network files from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCVUhqc1ZyX21FMWs) or [BaiduPan](http://pan.baidu.com/s/1qYJahB2) and extract into `reid_net/` directory


### Testing Demo

0.  Start Matlab from the root directory
0.  Run `faster_rcnn_build.m`
0.  Run `startup.m`
0.  Run `demo.m` 


### Training Your Pedestrian Detection Network

0.  Download SVD-B training data from [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCV1lIN3ZzRXFTMlE). Extract them into `dataset/` directory and rename to `VOCdevkit2007/`  
0.  Modify related files in `models/` dir to config detection network
0.  Run scripts in `experiments/` accordingly to train a detection network.

Note that the GPU cost for training a detection network is much higher than that for testing. Before training your own detection network, please ensure that your GPU memory memory meets the following requirement:

- 3GB GPU memory for ZF net
- 9GB GPU memory for VGG-16 net


