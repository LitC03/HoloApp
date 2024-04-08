function x_padded = pad_to_SLM(img, dims)
    height = size(img,1);
    x_padded = padarray(img,[0 round((dims(2)-height)./2)],0,'both');
    % imshow(x_padded)
end