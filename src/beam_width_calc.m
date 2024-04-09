clear
close all


left = readmatrix('C:\Users\lito\Videos\Exp Feb 2024\profile_left_circle.csv');
right = readmatrix('C:\Users\lito\Videos\Exp Feb 2024\profile_right_circle.csv');
one = readmatrix('C:\Users\lito\Videos\Exp Feb 2024\profile_only_one_circle.csv');

circle_info = {};
interp_info = cell(3,1);

f=figure(1);
f.Position = [3037,-165,560,602.6666666666666];
subplot(3,1,1)
plot(left(:,2),'LineWidth',1)
% hold on
subplot(3,1,2)
plot(right(:,2),'LineWidth',1)
subplot(3,1,3)
plot(one(:,2),'LineWidth',1)

circle_info{1}=left(:,2);
circle_info{2}=right(:,2);
circle_info{3}=one(:,2);


%% FWHM calculation
indx_half = zeros(3,2);
indx_max = zeros(3,1);
max_mat = zeros(3,1);
mid_vals = zeros(3,2);

for a=1:3
    profile =circle_info{a};
    max_mat(a)=max(profile,[],'all');
    indx_max(a) = find(profile==max_mat(a));
    indx_half(a,:) = find_closer_midpoint(profile);
    mid_vals(a,:) = circle_info{a}(indx_half(a,:));
    figure(1)
    subplot(3,1,a)
    hold on
    scatter(indx_half(a,:),mid_vals(a,:),'filled')
end


diams = indx_half(:,2)-indx_half(:,1);
FWHM = round(mean(diams))
cam_pitch = 3.45e-6;
real_FWHM = FWHM*cam_pitch
using_1e2 = sqrt(2/log(2))*real_FWHM

function idx = find_closer_midpoint(arr)

    max_num=max(arr);
    idx_max=find(arr==max_num);
    arr1=arr(1:idx_max);
    arr2=arr(idx_max:end);
    idx=zeros(2,1);

    idx(1)=binary_chop(arr1,max_num/2);
    idx(2)=binary_chop(arr2,max_num/2)+idx_max-1;
   
end


function idx = binary_chop(arr,num)
    sorted_arr=sort(arr);
    l=length(arr);
    idx_search=[1 l];

    while (idx_search(2)-idx_search(1)) > 1
        query_idx=round((sum(idx_search)-1)/2);
        
        if sorted_arr(query_idx)>num
            idx_search(2)=query_idx;
        else
            idx_search(1)=query_idx;
        end

    end
    actual_num_found=sorted_arr(query_idx);
    idx=find(arr==actual_num_found);
end
        

