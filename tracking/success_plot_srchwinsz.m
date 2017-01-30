results_dir = './results_srchwinsz';

videolist = {'video01','video02','video03','video04','video05','video06','video07','video08','video09','video10','video11','video12','video13','video14','video15','video16','video17','video18','video19','video20'}; % overall
% videolist = {'video02','video03','video04','video05','video07','video16','video17','video20'}; % SV
% videolist = {'video01','video02','video07','video09','video10','video11','video12','video13','video14','video15','video16','video17','video18','video19'}; % OCC
% videolist = {'video01','video04','video05','video06','video07','video08','video09','video13','video15','video18','video19','video20'}; % BC
% videolist = {'video03','video10','video14','video15','video17'}; % DEF
% videolist = {'video02','video03','video08','video15','video17','video19'}; % IPR

ground_truth = zeros(0,4);
numResults = numel(dir(fullfile(results_dir, [videolist{1}, '_result_*.txt'])));
positions = cell(1,numResults);

srchwinsz_list = [1,5:5:100];
for kk = 1:numel(videolist)
    videoname = videolist{kk};
    ground_truth = [ground_truth; load(fullfile(results_dir, [videoname, '_groundtruth_rect.txt']))];
    for i = 1:21
        result_name = sprintf('%s_result_Ours_srchwinsz_%d.txt',videoname,srchwinsz_list(i));
        positions{i} = [positions{i}; floor(load(fullfile(results_dir, result_name)))];
    end
end


max_threshold = 50;  %used for graphs in the paper
precisions = zeros(numResults, max_threshold);

stepsize = 0.01;  %used for graphs in the paper
success = zeros(numResults, floor(1/stepsize)+1);  

for i = 1:numResults
    ratio = zeros(size(ground_truth,1),1);
    for j = 1:size(ground_truth,1)
        if ground_truth(j,3)==0 && positions{i}(j,3)==0
            ratio(j) = 0.99;
        elseif ground_truth(j,3)==0 && positions{i}(j,3)~=0
            ratio(j) = 0;
        elseif ground_truth(j,3)~=0 && positions{i}(j,3)==0
            ratio(j) = 0;
        else 
            area_gt = ground_truth(j,3)*ground_truth(j,4);
            area_th = positions{i}(j,3)*positions{i}(j,4);
            l = max(ground_truth(j,1), positions{i}(j,1));
            r = min(ground_truth(j,1)+ground_truth(j,3), positions{i}(j,1)+positions{i}(j,3));
            t = max(ground_truth(j,2), positions{i}(j,2));
            b = min(ground_truth(j,2)+ground_truth(j,4), positions{i}(j,2)+positions{i}(j,4));
            if l < r && t < b
                overlap = (r-l)*(b-t);
                ratio(j) = overlap/(area_gt+area_th - overlap);
            else
                ratio(j) = 0;
            end
        end 
    end
    count = 0;
    for p = 0:stepsize:1
        count = count + 1;
        success(i,count) = nnz(ratio > p) / numel(ratio);
    end
end


%plot the precisions
rng(0);
colors = rand(21,3);
    
style = { '-.','-',':'};

figure('Name','Success plots of OPE');
for i = 1:numResults
    score = mean(success(i,1:100));
    fprintf('%.3f\n',score);
    
    displayname = sprintf('srchwinsz=%d (%.3f)', srchwinsz_list(i), score);
     
    plot(0:stepsize:1,success(i,:), style{mod(i,3)+1}, 'LineWidth',5,'Color',colors(i,:),'DisplayName',displayname);
    hold on;
end

fprintf('\n');
title('Success plots of OPE');
xlabel('Overlap threshold'), ylabel('Success rate');
h_legend = legend('show');
set(h_legend,'FontSize',11);

