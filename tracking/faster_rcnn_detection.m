function [boxes, scores] = faster_rcnn_detection(im, thres, opts, proposal_detection_model, rpn_net, fast_rcnn_net)

% imread('./12_3023.jpg')
%% -------------------- WARM UP --------------------
% the first run will be slower; use an empty image to warm up

% for j = 1:2 % we warm up 2 times
%     im = uint8(ones(375, 500, 3)*128);
%     if opts.use_gpu
%         im = gpuArray(im);
%     end
%     [boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
%     aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
%     if proposal_detection_model.is_share_feature
%         [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
%             rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
%             aboxes(:, 1:4), opts.after_nms_topN);
%     else
%         [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
%             aboxes(:, 1:4), opts.after_nms_topN);
%     end
% end

%% -------------------- TESTING --------------------
% im_names = {'001763.jpg', '004545.jpg', '000542.jpg', '000456.jpg', '001150.jpg'};
% im_names = {'test01.jpg','test02.jpg','test03.jpg','test04.jpg','test05.jpg','test06.jpg'};
% im_names = {'1_817.jpg', '1_827.jpg', '1_847.jpg', '7_10957.jpg', '12_2859.jpg'};
% im_names = {'12_3023.jpg'};
% these images can be downloaded with fetch_faster_rcnn_final_model.m

% running_time = [];
    
%     im = imread(fullfile(pwd, im_names{j}));

if opts.use_gpu
    im = gpuArray(im);
end

% test proposal
% th = tic();
[boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
% t_proposal = toc(th);
% th = tic();
aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
% t_nms = toc(th);

% test detection
% th = tic();
if proposal_detection_model.is_share_feature
    [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
        aboxes(:, 1:4), opts.after_nms_topN);
else
    [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        aboxes(:, 1:4), opts.after_nms_topN);
end
% t_detection = toc(th);

boxes_cell = [boxes(:,1:4), scores(:,1)];
boxes_cell = boxes_cell(nms(boxes_cell, 0.3), :);
ind = boxes_cell(:,5) >= thres;
boxes_cell = boxes_cell(ind, :);
boxes = floor(boxes_cell(:,1:4));
scores = boxes_cell(:,5);

% ind = scores>=thres;
% boxes = boxes(ind,:);
% scores = scores(ind);

% fprintf('%s (%dx%d): time %.3fs (resize+conv+proposal: %.3fs, nms+regionwise: %.3fs)\n', im_names{j}, ...
%     size(im, 2), size(im, 1), t_proposal + t_nms + t_detection, t_proposal, t_nms+t_detection);
%     running_time(end+1) = t_proposal + t_nms + t_detection;

%     % visualize
%     classes = proposal_detection_model.classes;
%     boxes_cell = cell(length(classes), 1);
%     thres = 0.6;
%     for i = 1:length(boxes_cell)
%         boxes_cell{i} = [boxes(:, (1+(i-1)*4):(i*4)), scores(:, i)];
%         boxes_cell{i} = boxes_cell{i}(nms(boxes_cell{i}, 0.3), :);
%         
%         I = boxes_cell{i}(:, 5) >= thres;
%         boxes_cell{i} = boxes_cell{i}(I, :);
%     end
%     figure(j);
%     showboxes(im, boxes_cell, classes, 'voc');
%     pause(0.1);

% fprintf('mean time: %.3fs\n', mean(running_time));

% caffe.reset_all(); 
% clear mex;

end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), per_nms_topN), :);
    end
    % do nms
    if nms_overlap_thres > 0 && nms_overlap_thres < 1
        aboxes = aboxes(nms(aboxes, nms_overlap_thres, use_gpu), :);       
    end
    if after_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), after_nms_topN), :);
    end
end
