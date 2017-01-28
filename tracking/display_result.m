function display_result(img_dir)
%----------------------------------------------------------------------- 
% display the tracking result 
% input
%   img_dir: contains the groundtruth_rect.txt, or tracking result file 
%-----------------------------------------------------------------------

% load groundtruth
% result = load([img_dir 'groundtruth_rect.txt']);

% or load tracking result 
tmp = strsplit(img_dir,'/');
videoname = tmp{3};
result = load([img_dir [videoname '_result_Ours.txt']]);
% result = load([img_dir videoname '_result_Ours[Haar+VGG16-4096].txt']);
% result = load([img_dir videoname '_result_Ours[Haar+Color].txt']);
% result = load([img_dir videoname '_result_Ours[Haar].txt']);

% result = load([img_dir 'test211_result_MDNet.txt']);

% result = load([img_dir 'video8_result_Ours[HOG+VGG16-4096].txt']);
% result = load([img_dir 'groundtruth_rect.txt']);
img_names = dir([img_dir 'img/*.jpg']);
for i = 1:length(img_names)
    img = imread([img_dir, 'img/' img_names(i).name]);
    imshow(img);
    if i<=size(result,1) && any(result(i,:))
        rectangle('Position',result(i,:),'LineWidth',4,'EdgeColor','r');
    end
    hold on;
    text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
    set(gca,'position',[0 0 1 1]); 


    pause(0.031); 
    hold off;
end

end
