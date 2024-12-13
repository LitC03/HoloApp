vidObj = VideoReader("angry cat.mp4");
read(vidObj)
% while hasFrame(vidObj)
%     vidFrame = readFrame(vidObj);
%     imshow(vidFrame)
%     pause(1/vidObj.FrameRate)
% end
clear vidObj