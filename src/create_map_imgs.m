clear
close all
% folder with images
% folder = 'might_work_again';
% folder = 'jun_23_50';
% folder = 'whole_board_100';
folder = 'whole_board_50';
% folder = 'smaller_exp';
%get names of subfolders
sub_folders = dir(strcat('..\img\fibre_imgs\',folder));

%get part that I want to study 
% COMMENT OUT IF YOU WANT TO ANALYSE THE WHOLE IMAGE
row_indices = 500:800;
col_indices = 1700:2200;
row_pxs = length(row_indices);
col_pxs = length(col_indices);

fold_num = length(sub_folders)-2;
data_mean = zeros(fold_num,3);

if ~exist("row_indices","var")
    img_picked_matrix= zeros(2048,2448,fold_num);
else
    img_picked_matrix= zeros(row_pxs,col_pxs,fold_num);
end


for a = 1:fold_num
% for a = 1
    folder_name = sub_folders(a+2).name;
    fold_dir = strcat('..\img\fibre_imgs\',folder,'\',folder_name);
    imgs = dir(fold_dir);
    imgs_len = length(imgs)-2;
    [row,col,step]= get_coords(folder_name);
    if ~exist("row_indices","var")
        img_looked_matrix= zeros(2048,2448,imgs_len);
    else
        img_looked_matrix= zeros(row_pxs,col_pxs,imgs_len);
    end
    
    mean_matrix_img = zeros(1,imgs_len);

    for b = 1:imgs_len
    % for b = 1
        img_dir = strcat(fold_dir,'\',imgs(b+2).name);
        % img_dir = strcat(fold_dir,'\',imgs(end).name);
        img = double(imread(img_dir));
        if ~exist("row_indices","var")
            cut_img = img(:,:,1);
        else
            cut_img = img(row_indices,col_indices,1);
        end
        img_looked_matrix(:,:,b) = cut_img;
        mean_matrix_img(b) = mean(cut_img,"all");
        %put them in a matrix

        % imagesc(cut_img)
    end
    %choose image with the highest mean amongst the stack
    [val,indx] =max(mean_matrix_img);
    data_mean(a,:) = [val,row,col];
    img_picked_matrix(:,:,a) = img_looked_matrix(:,:,indx);
    % put the mean in the map
    
end
%%
min_row = min(data_mean(:,3));
max_row = max(data_mean(:,3));

min_col = min(data_mean(:,2));
max_col = max(data_mean(:,2));

map_size = [max_row-min_row,max_col-min_col]./step;
map = zeros(map_size(1),map_size(2));

% for a = 1
for a = 1:fold_num
    col_val = ((data_mean(a,2)-min_col)/step) +1;
    row_val = ((data_mean(a,3)-min_row)/step) +1;
    map(floor(row_val),floor(col_val)) = data_mean(a,1);
end
figure
y_axis = min_row:step:max_row;
x_axis = min_col:step:max_col;

imagesc(x_axis,y_axis,map)


function [row,col,step]= get_coords(folder_name)
    pattern = 'phase_(-?\d+)_(-?\d+)_step_(-?\d+)';
    tokens = regexp(folder_name, pattern, 'tokens');
    row = str2double(tokens{1}{1});
    col = str2double(tokens{1}{2});
    step = str2double(tokens{1}{3});
    % display(col)
end

