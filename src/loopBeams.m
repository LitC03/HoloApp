function [totResult, totInten, totPhase, res] = loopBeams(SLM, beamShift, beamGauss, targShiftX, targShiftY, ...
    fftArr, sceneGeom, totInten, totPhase, targetPadArr, config, ...
    axes_3, axes_4, axes_5, axes_6)
    
    totInten = totInten * 0.0;
    totPhase = totPhase * 0.0;
    N_BEAMS = config.nCol * config.nRow;
    mapDim = config.mapDim;
    camDim = config.camDim;
    slmEdges = vertcat(SLM.zones.X);
    slmEdges = [1 slmEdges(:,2)'];
    slmDim = SLM.dim;
    dispDims = config.dispDims;
    slmPix = config.slmPix;
    labelSize = config.labelSize;
    titleSize = config.titleSize;
    gaussSigma = config.gaussSigma;
    N_ITERS = config.N_ITERS;
    
    do_plotting = 0;
    totTarget = targetPadArr(:,:,1) *0.0;
    for b = 1:N_BEAMS
        tic
        thisSLMR = sqrt((SLM.X-beamShift(1,b)).^2 + ...
            (SLM.Y-beamShift(2,b)).^2);
        thisBeamGauss = exp(-thisSLMR.^2/gaussSigma^2);
        slmInten = SLM.ap .* thisBeamGauss;

        targetPad = targetPadArr(:,:,b);
        thisTarget = targetPad;
        thisSource = fftArr;
        xStart = slmEdges(b)+round((mapDim(2)-slmDim(2))/2);
        xEnd = slmEdges(b+1)+round((mapDim(2)-slmDim(2))/2);
        xStart = SLM.zones(b).X(1)+round((mapDim(2)-slmDim(2))/2);
        xEnd = SLM.zones(b).X(2)+round((mapDim(2)-slmDim(2))/2);
        yStart = SLM.zones(b).Y(1)+round((mapDim(1)-slmDim(1))/2);
        yEnd = SLM.zones(b).Y(2)+round((mapDim(1)-slmDim(1))/2);
        phArrTemp = abs(fftArr) *0.0;
        phArrTemp(yStart:yEnd,xStart:xEnd) = 1;
        thisPhaseMask = angle(fftArr) .* phArrTemp;
        A = fft2(thisTarget);
        resDims = [size(A,1)/2-camDim(1)/2 ...
                  size(A,1)/2+camDim(1)/2 ...
                  size(A,2)/2-camDim(2)/2 ...
                  size(A,2)/2+camDim(2)/2];
        if ~isempty(resDims(resDims <0))
            resDims = [1 camDim(1) 1 camDim(2)];
        end


        %Compute the Gerchberg-Saxton phase retrieval

%         if ~ishandle(1)
%             fig1 = figure(1);
%             fig1.Position = [-1800,10,1400*1.2,800*1.2];
%         end
        pause(0.01)
        use_gpu = 0;
        for n = 1:N_ITERS

            if ~use_gpu

                B = thisSource.*exp(1i.*wrapTo2Pi(angle(A)));%Source amp, targ ph
                C = fftshift(fft2(B));
                D = fftshift(thisTarget.*exp(1i.*wrapTo2Pi(angle(C))));%Targ amp, meas ph
                A = fft2(D);  

            else

                B = gpuArray(thisSource.*exp(1i.*wrapTo2Pi(angle(A))));%Source amp, targ ph
                C = gpuArray(fftshift(fft2(B)));
                D = gpuArray(fftshift(thisTarget.*exp(1i.*wrapTo2Pi(angle(C)))));%Targ amp, meas ph
                A = gpuArray(fft2(D));  

            end

            phase = wrapTo2Pi(angle(A).*thisPhaseMask);
            inten = abs(padarray(slmInten, [config.apPaddingY config.apPaddingX], 0, 'both'));
            inten = imresize(inten, [config.mapDim(1) config.mapDim(2)]);
            total = inten.*exp(1i*phase);
            result = abs(fftshift(fft2(total)));
            
            if do_plotting
                subplot(2,3,1)
                imagesc([dispDims(1) dispDims(2)]*slmPix*1000, ...
                    [dispDims(3) dispDims(4)]*slmPix*1000, sceneGeom)
                title('Scene Geometry', 'FontSize', titleSize)
                xlabel('Pupil X (mm)', 'FontSize', labelSize)
                ylabel('Pupil Y (mm)', 'FontSize', labelSize)

                subplot(2,3,2)
                imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], inten)
                xlabel('Pupil X px', 'FontSize', labelSize)
                ylabel('Pupil Y px', 'FontSize', labelSize)
                title('Aperture Illumination', 'FontSize', titleSize)

                subplot(2,3,3)
                imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], phase)
                xlabel('Pupil X px', 'FontSize', labelSize)
                ylabel('Pupil Y px', 'FontSize', labelSize)
                title('Aperture Phase', 'FontSize', titleSize)

                subplot(2,3,4)
                camTargPad = padarray(target, [round(((camDim(1)-size(target,1)))/2) ...
                    round(((camDim(2)-size(target,2)))/2)]);
                tempCamTarg = imresize(target, [1000 1000]);
                imagesc(tempCamTarg)
                set(gca,'xtick',[])
                set(gca,'ytick',[])

                xlabel('Arbitrary X Dim', 'FontSize', labelSize)
                ylabel('Arbitrary Y Dim', 'FontSize', labelSize)
                title('Target Pattern', 'FontSize', titleSize)

                subplot(2,3,5)
                imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], thisTarget)
                xlabel('Image X px', 'FontSize', labelSize)
                ylabel('Image Y px', 'FontSize', labelSize)
                title('Target Image', 'FontSize', titleSize)

                s6 = subplot(2,3,6);
                result = flip(result,1);
                result = flip(result,2);
                camResult = result(resDims(1):resDims(2)-1, resDims(3):resDims(4)-1);
                    %TESTING
                foo = result./max(result(:))*255;
                imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], result)
                colormap(s6, 'gray')
                title('Simulated CAM Image', 'FontSize', titleSize)
                xlabel('Image X px', 'FontSize', labelSize)
                ylabel('Image Y px', 'FontSize', labelSize)

                sgtitle('Hologram Generation and Imaging', 'FontSize', 28)
                pause(0.01)
            end

        end
        totInten = (totInten + inten);
        totPhase = (totPhase + phase);
        totResult = abs(fftshift(fft2(totInten.*exp(1i.*totPhase))));
        totResult = flip(totResult, 1);
        totResult = flip(totResult, 2);
        if do_plotting
            subplot(2,3,2)
            imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], totInten)
            xlabel('Pupil X px', 'FontSize', labelSize)
            ylabel('Pupil Y px', 'FontSize', labelSize)
            title('Aperture Illumination', 'FontSize', titleSize)

            subplot(2,3,3)
            imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], totPhase)
            xlabel('Pupil X px', 'FontSize', labelSize)
            ylabel('Pupil Y px', 'FontSize', labelSize)
            title('Aperture Phase', 'FontSize', titleSize)

            s6 = subplot(2,3,6);
            camResult = result(resDims(1):resDims(2)-1, resDims(3):resDims(4)-1);
            foo = totResult./max(totResult(:))*255;
            imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], result)



            imagesc([dispDims(1) dispDims(2)], [dispDims(3) dispDims(4)], foo)
            title('Simulated CAM Image', 'FontSize', titleSize)
            xlabel('Image X px', 'FontSize', labelSize)
            ylabel('Image Y px', 'FontSize', labelSize)  
            colormap(s6, 'gray');
        end
        totTarget = totTarget + thisTarget;
        imagesc(axes_3, phase)
        imagesc(axes_4, inten)
        imagesc(axes_5, thisTarget)
        img6 = imagesc(axes_6, totResult);
        colormap(axes_6, 'gray');
        pause(0.01)
        toc
    end % N_BEAMS
    for i =1:N_BEAMS

    imagesc(axes_3, totPhase)
    imagesc(axes_4, totInten)   
    imagesc(axes_5, totTarget)
    img6 = imagesc(axes_6, totResult);
    colormap(axes_6, 'gray');
    
    res = 1;
    simDone = 1;
    end