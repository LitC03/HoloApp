% Resize to square
function new_img = squaring_img(img,l)
    % This function resizes any image to a square of lxl pixels
            
            % get the dims of the image
            dim_img = size(img);
            
            % Initialise padding variables (this is for smaller images)
            padY=0;
            padX=0;
        

            % Determine which dimension will need padding
            log_arr = dim_img<=[l l];

            if log_arr(1)
                padY = l-dim_img(1);
            else
                disp('Image will be cut in y axis');
            end

            if log_arr(2)
                padX = l-dim_img(2);
            else
                disp('Image will be cut in x axis');
            end
            
            % Add padding if needed
            target = padarray(img,round([padY padX]./2),0,'both');
            
            % Crop image to the correct dims
            win1 = centerCropWindow2d(size(target),[l l]);
            new_img = imcrop(target,win1);
            % figure
            % imshow(new_img)
end