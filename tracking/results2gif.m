% write results to gif
clear;
imgs_dir= './test/';
videoname = 'video10';

outputname = fullfile(imgs_dir, videoname, [videoname,'.gif']);
delay = 1/30;


img_files = dir(fullfile(imgs_dir, videoname, 'img', '*.jpg'));
position_files = dir(fullfile(imgs_dir, videoname, '*.txt'));
numResults = numel(position_files);
positions = cell(1,numResults);

for i = 1:numResults
    if strcmp(position_files(i).name, [videoname, '_result_Ours.txt'])
        break;
    end
end

% switching i-th and the first one
tmp = position_files(1);
position_files(1) = position_files(i);
position_files(i) = tmp;

for i = 1:numResults
    positions{i} = floor(load(fullfile(imgs_dir, videoname, position_files(i).name))); 
end

% draw the gif
colors = [[1 0 0];
        [1 1 0];	
        [0 0 0];
        [0 0 1];
        [0 1 0];
        [0 1 1];	
        [1 0 1];	
        [0.9412 0.4706 0];
        [0.502 0.502 1]];
   
f = figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:size(positions{1},1)
    img = imread(fullfile(imgs_dir, videoname, 'img', img_files(i).name));
    imshow(img, 'border','tight');
    text(5,38,['#',num2str(i)],'Color','w','FontWeight','bold','FontSize',30);
    for j = 1:numResults
        if ~all(positions{j}(i,:) == 0)
            rectangle('Position',positions{j}(i,:), 'Linewidth',2,'EdgeColor',colors(j,:));
        end
        tmp = strsplit(position_files(j).name,'_');
        tmp = strsplit(tmp{end},'.');
        displayname = tmp{1};
        text(820,25+70*(j-1),displayname,'Color',colors(j,:),'FontWeight','bold','FontSize',20);
        drawnow;
        hold off;
    end
    
    

%     frm = getframe(f);
%     [m,n] = rgb2ind(frm.cdata,256);
%     if i == 1
%         imwrite(m,n,outputname);
%     elseif i == size(positions{1},1) % last frame
%         imwrite(m,n,outputname,'DelayTime', 1, 'WriteMode','append');
%     else
%         imwrite(m,n,outputname,'DelayTime',delay, 'WriteMode','append');
%     end
end

