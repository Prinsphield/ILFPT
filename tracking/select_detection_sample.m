function [select_samples, neg_samples, sgn] = select_detection_sample(samples, initstate, inertia, radius, width, height)
% selected detection samples within radius 
% sgn : -1 top, -2 bottom, -3 left, -4 right

x = initstate(1) + inertia.x;
y = initstate(2) + inertia.y;
w = initstate(3);
h = initstate(4);

dist = sqrt((samples.sx + samples.sw/2 - x - w/2).^2 + (samples.sy + samples.sh/2 - y - h/2).^2);
ind_pos = (dist <= radius);
ind_neg = (dist > radius);

if any(ind_pos) %sum(ind_pos~=0) ~= 0
    sgn = 1;
    select_samples.sx = samples.sx(ind_pos);
    select_samples.sy = samples.sy(ind_pos);
    select_samples.sw = samples.sw(ind_pos);
    select_samples.sh = samples.sh(ind_pos);
else
    sgn = 0;
    select_samples = struct('sx',[],'sy',[],'sw',[],'sh',[]);
    disp('no nearby pedestrian found')
end

neg_samples.sx = samples.sx(ind_neg);
neg_samples.sy = samples.sy(ind_neg);
neg_samples.sw = samples.sw(ind_neg);
neg_samples.sh = samples.sh(ind_neg);

end

