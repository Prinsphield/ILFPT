# Integrated Learning Framework for Pedestrian Tracking

### Introduction

ILFPT is in intergated framework designed for pedestrian tracking, especially in the surveillance videos.


### Requirements 

0. `Caffe` (see `external/caffe/`)
0. MATLAB
0. GPU 
    - 3GB GPU memory for ZF net 
    - 9GB GPU memory for VGG-16 net


### Preparation for Testing:

0.  `git clone https://github.com/Prinsphield/ILFPT.git`
0.  Build Caffe in the `external/caffe`
0.  Download the test videos from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCWEpodlFPQml0cms) or [BaiduPan](https://pan.baidu.com/s/1i4PdO1Z) and extract them into the 'test/' directory
0.  Download the detection network model from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCaGxfSVJYNXN5X3c) or [BaiduPan](http://pan.baidu.com/s/1mhWzjOs) and extract into `model/` directory
0.  Download the pretrained detection network from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCcy12RGF2MVVBQW8) or [BaiduPan](http://pan.baidu.com/s/1gePhQdd) and extract into `output/` directory
0.  Download the pretrained re-id network files from either [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCVUhqc1ZyX21FMWs) or [BaiduPan](http://pan.baidu.com/s/1qYJahB2) and extract into `reid_net/` directory


### Testing Demo

0.  Start Matlab from the root directory
0.  Run `faster_rcnn_build.m`
0.  Run `startup.m`
0.  Run `demo.m` 


### Training Your Pedestrian Detection Network

0.	Download SVD-B training data from [Google Drive](https://drive.google.com/open?id=0B_ZFgt4zqONCV1lIN3ZzRXFTMlE) and extract into `dataset/` directory
0.  Modify related files in `model/` dir to config detection network
0.  Run scripts in `experiments/` accordingly to train a detection network.



