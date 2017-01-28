function [feat] = getColorFtr(samples, img)
% get color histogram feature from sample image
% x = samples.sx;
% y = samples.sy;
% w = samples.sw;
% h = samples.sh;
num_sample = length(samples.sx);
feat = zeros(125, num_sample);
for i = 1:num_sample
    im = img(samples.sy(i):samples.sy(i)+samples.sh(i), samples.sx(i):samples.sx(i)+samples.sw(i),:);
    hist = invhist(im);
    feat(:,i) = hist(:);
end

end