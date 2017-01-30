% success plot on all results
clear;
results_dir = './results_between_overall';
% results_dir = './results_tau';
% results_dir = './results_inter';

videolist = {'video01','video02','video03','video04','video05','video06','video07','video08','video09','video10','video11','video12','video13','video14','video15','video16','video17','video18','video19','video20'}; % overall
% videolist = {'video02','video03','video04','video05','video07','video16','video17','video20'}; % SV
% videolist = {'video01','video02','video07','video09','video10','video11','video12','video13','video14','video15','video16','video17','video18','video19'}; % OCC
% videolist = {'video01','video04','video05','video06','video07','video08','video09','video13','video15','video18','video19','video20'}; % BC
% videolist = {'video03','video10','video14','video15','video17'}; % DEF
% videolist = {'video02','video03','video08','video15','video17','video19'}; % IPR

ground_truth = zeros(0,4);
numResults = numel(dir(fullfile(results_dir, [videolist{1}, '_result_*.txt'])));
positions = cell(1,numResults);

for kk = 1:numel(videolist)
    videoname = videolist{kk};
    ground_truth = [ground_truth; load(fullfile(results_dir, [videoname, '_groundtruth_rect.txt']))];
    position_files = dir(fullfile(results_dir, [videoname, '_result_*.txt']));
    for i = 1:numResults
        if strcmp(position_files(i).name, [videoname, '_result_Ours.txt'])
            break;
        end
    end

    % switching i-th and the first one
    tmp = position_files(1);
    position_files(1) = position_files(i);
    position_files(i) = tmp;

    % switching i-th and the last one
%     tmp = position_files(end);
%     position_files(end) = position_files(i);
%     position_files(i) = tmp;

    for i = 1:numResults
        positions{i} = [positions{i}; floor(load(fullfile(results_dir, position_files(i).name)))]; 
    end

end

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
colors = [[1 0 0];
        [1 1 0];	
        [0 0 0];
        [0 0 1];
        [0 1 0];
        [0 1 1];	
        [1 0 1];	
        [0.9412 0.4706 0];
        [0.502 0.502 1];
        [0.9 0.8 0.3];	
        [0.5 0.5 0];
        [0 0.502 0.502]
        ];

style = { '-.','-',':'};

figure('Name','Success plots of OPE');
for i = 1:numResults
    score = mean(success(i,1:100));
    fprintf('%.3f\n',score);
    
    tmp = strsplit(position_files(i).name,'_');
    tmp = strsplit(tmp{3}, '.');
    displayname = sprintf('%s (%.3f)',tmp{1}, score);
    
%     tmp = position_files(i).name;
%     tmp = strsplit(tmp(21:end), '.');
%     tmp = strrep(tmp{1}, '_', '=');
%     displayname = sprintf('%s (%.3f)', tmp, score);
     
    plot(0:stepsize:1,success(i,:), style{mod(i,3)+1}, 'LineWidth',5,'Color',colors(i,:),'DisplayName',displayname);
    hold on;
end

fprintf('\n');
title('Success plots of OPE');
xlabel('Overlap threshold'), ylabel('Success rate');
h_legend = legend('show');
set(h_legend,'FontSize',11);

