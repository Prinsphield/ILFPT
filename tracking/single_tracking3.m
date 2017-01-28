function single_tracking3(testdir)
% use Haar + color feature
% ------------------------------------------------
% video file setting
% ------------------------------------------------

img_dir = dir([testdir 'img/*.jpg']);
imgSr = imread([testdir 'img/' img_dir(1).name]);
img = double(imgSr(:,:,1));
WIDTH = size(img,2);
HEIGHT = size(img,1);

tmp = strsplit(testdir,'/');
videoname = tmp{3:4};
fid = fopen(fullfile(testdir, [videoname '_result_Ours[Haar+Color].txt']), 'w');
% fid = fopen([testdir, 'result.txt'], 'w');
if ~exist([testdir 'groundtruth_rect.txt'],'file')
    printf('cannot find groundtruth_rect.txt');
else
    gt = load([testdir 'groundtruth_rect.txt']); % initial tracker
    initstate = gt(1,:);
end

% ------------------------------------------------
% initialize networks
% ------------------------------------------------
[opts, proposal_detection_model, rpn_net, fast_rcnn_net] = init_faster_rcnn();


% ------------------------------------------------
% set parameters
% ------------------------------------------------
% tracking parameters
trparams.init_negnumtrain = 50;%number of trained negative samples
trparams.init_postrainrad = 4.0;%radical scope of positive samples
trparams.initstate = initstate;% object position [x y width height]
trparams.srchwinsz = 20;% size of search window
% Sometimes, it affects the results.

% classifier parameters
clfparams.width = trparams.initstate(3);
clfparams.height= trparams.initstate(4);

% feature parameters: number of rectangle from 2 to 4.
ftrparams.minNumRect = 2;
ftrparams.maxNumRect = 4;

% dimensions of re-id feature
M = 125; 

% detection parameters
dctparams.chooseNum = 1;
dctparams.freq = 10;
dctparams.memory = 200;
dctparams.srchwinsz = 50;
dctparams.penalty_track = 1;

% Haar feature samples
posx.mu = zeros(M,1);% mean of positive features
negx.mu = zeros(M,1);
posx.sig= ones(M,1);% variance of positive features
negx.sig= ones(M,1);

% storation samples for detection and re-id
pos_store.mu = zeros(M,1);
neg_store.mu = zeros(M,1);
pos_store.sig = ones(M,1);
neg_store.sig = ones(M,1);

% learning rate
lRate = 0.86;

% velocity 
inertia.x = 0;
inertia.y = 0;
inertia.rho = 0.79;

disappear = false;

% ------------------------------------------------
% process the initial frames 
% ------------------------------------------------
% compute feature template
[ftr.px,ftr.py,ftr.pw,ftr.ph,ftr.pwt] = HaarFtr(clfparams,ftrparams,M);

% compute sample templates
posx.sampleImage = sampleImg(img,initstate,inertia,trparams.init_postrainrad,0,100000);
negx.sampleImage = sampleImg(img,initstate,inertia,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,50);

pos_store.sampleImage = random_choose_sample(posx.sampleImage, dctparams.chooseNum);
neg_store.sampleImage = random_choose_sample(negx.sampleImage, dctparams.chooseNum);

% Feature extraction
iH = integral(img); % Compute integral image
posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
negx.feature = getFtrVal(iH,negx.sampleImage,ftr);

pos_store.feature = getColorFtr(pos_store.sampleImage, imgSr);
neg_store.feature = getColorFtr(neg_store.sampleImage, imgSr);

% update classifier
[posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
[pos_store.mu,pos_store.sig,neg_store.mu,neg_store.sig] = classiferUpdate(pos_store, neg_store, pos_store.mu, pos_store.sig, neg_store.mu, neg_store.sig, lRate);% update distribution parameters

numFrames = length(img_dir); % number of frames
x = initstate(1); % x coordinate at the top left corner
y = initstate(2); % y coordinate at the top left corner
w = initstate(3); % width of the rectangle
h = initstate(4); % height of the rectangle

fprintf(fid, '%d %d %d %d\n', x, y, w, h);
c = 0 ;
tic
for i = 2:numFrames
    % for debugging    
    disp(disappear);
    disp(initstate);
    disp(inertia);
    disp(i);
%     clear imgSr;
%     clear img;
    imgSr = imread([testdir 'img/' img_dir(i).name]);
    img = double(imgSr(:,:,1));
    
    % make predictions about the position
    x = initstate(1) + inertia.x;
    y = initstate(2) + inertia.y;
    w = initstate(3);
    h = initstate(4);
    
    % check out whether target has been out of camera
    margin = 0;
    ind(1) = y - margin - 1; % top
    ind(2) = HEIGHT - (y + h + margin); % bottom
    ind(3) = x - margin - 1; % left
    ind(4) = WIDTH - (x + w + margin); % right
    
    if mod(i,dctparams.freq)==0 || disappear 
        disp('faster_rcnn');
        [boxes, scores] = faster_rcnn_detection(single(imgSr), 0.5, opts, proposal_detection_model, rpn_net, fast_rcnn_net);
        boxes = double(boxes);
        samples.sx = boxes(:,1)';
        samples.sy = boxes(:,2)';
        samples.sw = boxes(:,3)'- boxes(:,1)';
        samples.sh = boxes(:,4)'- boxes(:,2)';
        
        [detectx.sampleImage, neg_sample.sampleImage, sgn] = select_detection_sample(samples, initstate, inertia, dctparams.srchwinsz, WIDTH, HEIGHT);
        % disp(numel(neg_sample.sampleImage.sx))
        if numel(neg_sample.sampleImage.sx) > 0
            neg_sample.feature = getColorFtr(neg_sample.sampleImage, imgSr);
            neg_store = add_sample(neg_store, neg_sample, dctparams.memory);
        end
        
        if sgn == 0
            % no nearby pedestrian found
            disappear = 1;
            
            % update initstate 
            if ~any(ind<0)
                initstate = [x y w h];
            end
            
            fprintf(fid, '%d %d %d %d\n', initstate);
            continue;
        else
            disappear = 0;
            detectx.feature = getColorFtr(detectx.sampleImage,imgSr);
            r = ratioClassifier(pos_store,neg_store,detectx);
        end
        
    else
        
        if any(ind<=0)
            disappear = 1;
            fprintf(fid, '%d %d %d %d\n', initstate);
            continue;
        else
            disappear = 0;
            % normal sampling, in tracking part
            detectx.sampleImage = sampleImg(img,initstate,inertia,trparams.srchwinsz,0,100000);  
            iH = integral(img); % Compute integral image
            detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
            r = ratioClassifier(posx,negx,detectx); % compute the classifier for all samples          
        end
    end
    
    clf = sum(r);
    [c,index] = max(clf);
    disp(c);
    
    % following for normal tracking update     
    x = detectx.sampleImage.sx(index);
    y = detectx.sampleImage.sy(index);
    w = detectx.sampleImage.sw(index);
    h = detectx.sampleImage.sh(index);
    
    % update inertia and initstate    
    inertia.x = ceil(inertia.rho * inertia.x + (1 - inertia.rho) * (x+w/2 - initstate(1) - initstate(3)/2));
    inertia.y = ceil(inertia.rho * inertia.y + (1 - inertia.rho) * (y+h/2 - initstate(2) - initstate(4)/2));
    initstate = [x y w h];
    
    if c > -60 || i <= 10
        % update samples only when c > ? where ? is threshold
        fprintf(fid, '%d %d %d %d\n', x, y, w, h);
        
        % Extract samples  
        station.x = 0;
        station.y = 0;
        posx.sampleImage = sampleImg(img,initstate,station,trparams.init_postrainrad,0,100000);
        negx.sampleImage = sampleImg(img,initstate,station,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);

        pos_sample.sampleImage = random_choose_sample(posx.sampleImage, dctparams.chooseNum);
       
        % Update all the features 
        posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
        negx.feature = getFtrVal(iH,negx.sampleImage,ftr);

        pos_sample.feature = getColorFtr(pos_sample.sampleImage, imgSr);

        % add new sample to pos_store and neg_store
        pos_store = add_sample(pos_store, pos_sample, dctparams.memory);

        % update classifier
        [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
        [pos_store.mu, pos_store.sig, neg_store.mu, neg_store.sig] = classiferUpdate(pos_store, neg_store, pos_store.mu, pos_store.sig, neg_store.mu, neg_store.sig, lRate);        
        
    else
        fprintf(fid, '%d %d %d %d\n', x, y, w, h);
        % add negative samples to neg_store
        for k = 1:dctparams.penalty_track
            neg_store = add_sample(neg_store, detectx, dctparams.memory);
        end
        [pos_store.mu, pos_store.sig, neg_store.mu, neg_store.sig] = classiferUpdate(pos_store, neg_store, pos_store.mu, pos_store.sig, neg_store.mu, neg_store.sig, lRate); 
    end
     
end
toc
fclose(fid);
caffe.reset_all();

end
