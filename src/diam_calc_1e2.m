function  [diam, px_width] = diam_calc_1e2(path_to_file,varargin)
% This function takes the path to a csv file containing the profile of a 
% beam/circle... and the pitch of the camera from which it was obtained. It
% gives the diameter (1/e^2) in metres and in number of pixels.

    close all

    if isempty(varargin)
        cam_pitch=3.45e-6;
    else
        cam_pitch=varargin{1};
    end
    
    %% Read the csv file
    % info = readmatrix('C:\Users\lito\Videos\Exp Feb 2024\profile_left_circle.csv');
    info = readmatrix(path_to_file);
    profile = info(:,2);

    %% Plot profile
    f=figure(1);
    f.Position = [1954.333333333333,179,432.6666666666667,266];
    plot(profile,'LineWidth',1)

    %% Get the indexes of the half maximum points and their values
    [indx_half,mid_vals] = find_closer_midpoint(profile);
    % mid_vals = profile(indx_half);


    figure(1)
    hold on
    scatter(indx_half,mid_vals,'filled')

    px_width = indx_half(2)-indx_half(1);
    diam = px_width*cam_pitch;

    % using_1e2 = sqrt(2/log(2))*real_FWHM

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function [idxs,mid_vals] = find_closer_midpoint(arr)
    % This function takes an array and divides it into two, with the cut
    % being made at the max value. Each of these smaller arrays goes
    % through binary chop to get the two midpoints for the FWHM calculation

        max_num=max(arr); %Get max value of the array

        % Separate array into 2
        idx_max=find(arr==max_num);
        arr1=arr(1:idx_max);
        arr2=arr(idx_max:end);


        idxs=zeros(2,1);
        mid_vals=zeros(2,1);
        
        % Perform binary chop on both arrays
        [idxs(1),mid_vals(1)]=binary_chop(arr1,max_num/exp(2));
        [idxs(2),mid_vals(2)]=binary_chop(arr2,max_num/exp(2));
        idxs(2)=idxs(2)+idx_max-1;
    end
    
    
    function [idx,actual_num_found] = binary_chop(arr,num)
        % Perform binary chop on an array (arr) to get the index at which
        % it a specific number (num) is found (or something close to it)

        sorted_arr=sort(arr); % Sort array
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

        % Get the actual number found and its index
        actual_num_found=sorted_arr(query_idx);
        idx=find(arr==actual_num_found);
    end
    % 
end