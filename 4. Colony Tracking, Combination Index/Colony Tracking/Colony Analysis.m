tic; % Start timer
clc; % Clear command window
clearvars; % Clear variables
fprintf('Running Colony v2.28.m...\n');
workspace; % Show workspace 
imtool close all; % Close imtool figures
format long g;
format compact;
captionFontSize = 12;

% % Pixel micrometer scaling factor
% Scale = 0.5; % need a scale bar. ex, 100um/200 pixels = 0.5 
% fprintf('scaling factor: %.3f micrometers/pixel\n', Scale);

% % Image Processing Toolbox 
% hasIPT = license('test', 'image_toolbox');
% if ~hasIPT
%     % User does not have the toolbox installed.
%     message = sprintf('No Image Processing Toolbox.\nContinue?');
%     reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
%     if strcmpi(reply, 'No')
%         % User said No, so exit.
%         return;
%     end
% end

% Loop through images 
for imageNum = 1:9
    % Construct file name
    baseFileName = sprintf('Colony%d.png', imageNum);
    folder = fileparts(which(baseFileName)); % Get folder
    if isempty(folder)
        folder = pwd; % Use current directory
    end
    fullFileName = fullfile(folder, baseFileName);
    fprintf('Processing File: "%s"\n', fullFileName);
    
    % Check if file exists
    if ~exist(fullFileName, 'file')
        fprintf('Error: %s not found. Skipping...\n', fullFileName);
        continue; % Skip to next image
    end

    % Read image
    Image = imread(fullFileName);
    
    % Convert to grayscale if needed (gfp,rfp, merged images)
    [rows, columns, nChannels] = size(Image);
    if nChannels > 1
        Image = im2gray(Image);
    end
    
    % Display original image 
    hFig = figure;
    hFig.Units = 'normalized';
    hFig.WindowState = 'maximized';
    hFig.NumberTitle = 'off';
    hFig.Name = sprintf('Image Analyst - Picture%d', imageNum);
    subplot(3, 3, 1);
    imshow(Image);
    title(sprintf('Bacteria colonies - Picture%d', imageNum), 'FontSize', captionFontSize);
    axis('on', 'image');
    
    % Histogram and display
    [pixelCount, grayLevels] = imhist(Image);
    subplot(3, 3, 2);
    bar(pixelCount);
    title('Histogram', 'FontSize', captionFontSize);
    xlim([0 grayLevels(end)]);
    grid on;

    % Threshold (method2)
    thresholdValue1 = 110;
    thresholdValue2 = 42;
    binaryImage = (Image > thresholdValue1) | (Image < thresholdValue2);
    hold on;
    maxYValue = ylim;
    line([thresholdValue1, thresholdValue1], maxYValue, 'Color', 'r');
    line([thresholdValue2, thresholdValue2], maxYValue, 'Color', 'b');
    hold off;
    
    % Binary image processing
    [~, threshold] = edge(Image, 'sobel');
    fudgeFactor = 0.5;
    BWs = edge(Image, 'sobel', threshold * fudgeFactor);
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    minSize = 10;
    BWs2 = bwareaopen(BWs, minSize);  % removes all connected components
    BWsdil = imdilate(BWs2, [se90 se0]);
    se = strel('disk', 15); % creates a disk-shaped structuring element
    BWnobord = imclose(BWsdil, se); % morphological closing on the grayscale or binary image
    BWnobord2 = imclearborder(BWsdil, 4);
    BWnorbord3 = imfill(BWnobord2, 'holes');
    seD = strel('diamond', 3);
    BWfinal = imerode(BWnorbord3, seD);
    BWfinal2 = imerode(BWfinal, seD);
    BWfinal2 = imfill(BWfinal2, 'holes');

    minSize = 10; % minimum size detection
    bImage = bwareaopen(BWfinal2, minSize);  % removes all connected components
    
    % Display binary image
    subplot(3, 3, 3);
    imshow(labeloverlay(Image, bImage));
    title('Binary Image', 'FontSize', captionFontSize);
    
    % Colony analysis
    [labeled, nColony] = bwlabel(bImage, 8); 
    props = regionprops(labeled, Image, 'all');
    
    % Convert measurements to micrometers
    % for k = 1:nColony
    %     props(k).Area = props(k).Area * (Scale^2); % Area: pixels^2 to micrometers^2
    %     props(k).Perimeter = props(k).Perimeter * Scale; % Perimeter: pixels to micrometers
    %     props(k).EquivDiameter = props(k).EquivDiameter * Scale; % Diameter: pixels to micrometers
    %     props(k).Centroid = props(k).Centroid * Scale; % Centroid: pixels to micrometers
    % end

     for k = 1:nColony
        props(k).Area = props(k).Area; % Area: 
        props(k).Perimeter = props(k).Perimeter; % Perimeter: 
        props(k).EquivDiameter = props(k).EquivDiameter; % Diameter: 
        props(k).Centroid = props(k).Centroid; % Centroid: 
    end
    
    
    % Display outlines
    subplot(3, 3, 4);
    imshow(Image);
    title('Outlines', 'FontSize', captionFontSize);
    axis('on', 'image');
    bound = bwboundaries(bImage);
    nBound = size(bound, 1);
    hold on;
    for k = 1:nBound
        tBound = bound{k};
        x = tBound(:, 2) ; % x-coordinates 
        y = tBound(:, 1) ; % y-coordinates 
        plot(x, y, 'r-', 'LineWidth', 1);
    end
    hold off;
    
    % Print measurements
    fprintf('Results for %s (Measurements in micrometers)\n', baseFileName);
    fprintf('Colony #      Circularity  Area (um^2)  Perimeter (um)  Centroid_X (um)  Centroid_Y (um)  Diameter (um)\n');
    ColECD = [props.EquivDiameter];
    textFontSize = 8;
    
    % Store all measurements for display
    allResultsTable = table();
    for k = 1:nColony
        meanGL = props(k).MeanIntensity;
        ColArea = props(k).Area; % Already in micrometers^2
        ColPerimeter = props(k).Perimeter; % Already in micrometers
        ColCentroid = props(k).Centroid; % Already in micrometers
        ColCircularity = props(k).Circularity; % Unitless, no conversion needed
        fprintf('#%2d %17.1f %11.1f %13.1f %14.1f %14.1f %12.1f\n', ...
            k, ColCircularity, ColArea, ColPerimeter, ColCentroid(1), ColCentroid(2), ColECD(k));
        text(ColCentroid(1), ColCentroid(2), num2str(k), ...
            'FontSize', textFontSize, 'FontWeight', 'Bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'w');
        
        % Store in table
        allResultsTable(k, :) = table(k, ColCircularity, ColArea, ColPerimeter, ...
            ColCentroid(1), ColCentroid(2), ColECD(k), ...
            'VariableNames', {'Colony', 'Circularity', 'Area_um2', 'Perimeter_um', ...
            'Centroid_X_um', 'Centroid_Y_um', 'Diameter_um'});
    end
    
    % Visualizations (Circularity, Pseudo-colored, Sorting1, Sorting2, Colony colored)
    subplot(3, 3, 5);
    imshow(bImage);
    title('Circularity', 'FontSize', captionFontSize);
    axis('on', 'image');
    hold on;
    for k = 1:nBound
        tBound = bound{k};
        x = tBound(:, 2) ; 
        y = tBound(:, 1) ; 
        plot(x, y, 'r-', 'LineWidth', 1);
    end
    hold off;
    
    color_labels = label2rgb(labeled, 'hsv', 'k', 'shuffle');
    subplot(3, 3, 6);
    imshow(color_labels);
    axis image;
    title('Pseudo colored labels', 'FontSize', captionFontSize);
    for k = 1:nColony
        text(allResultsTable.Centroid_X_um(k), allResultsTable.Centroid_Y_um(k), num2str(k), ...
            'FontSize', textFontSize, 'FontWeight', 'Bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'w');
    end
    
    % Parameters for colony sorting  
    ColPeri = [props.Perimeter]; 
    ColCir = [props.Circularity];
    ColArea = [props.Area]; 
    ColDia = [props.EquivDiameter];
    ColIntenIndex = (ColPeri > 50) & (ColPeri < 400); % Adjust thresholds
    ColCirIndex = ColCir > 0.3;
    keeperIndexes = find(ColIntenIndex & ColCirIndex);
    keeperColImage = ismember(labeled, keeperIndexes);
    labeledColImage = bwlabel(keeperColImage, 8);
    
    subplot(3, 3, 7);
    imshow(bImage);
    title('Sorting1', 'FontSize', captionFontSize);
    hold on;
    for k = 1:nColony
        NonCir = (ColArea(k) >= 3000) | (ColDia(k) <= 5); % Adjust thresholds
        if NonCir
            plot(allResultsTable.Centroid_X_um(k), allResultsTable.Centroid_Y_um(k), ...
                'rx', 'MarkerSize', 10, 'LineWidth', 1);
        else
            plot(allResultsTable.Centroid_X_um(k), allResultsTable.Centroid_Y_um(k), ...
                'go', 'MarkerSize', 10, 'LineWidth', 1);
        end
    end
    hold off;
    
    % Filter for Sorting2 and create results table
    keeperIndexes = find(ColCir > 0.4 & ColArea < 2000 & ColDia > 5); % Adjust thresholds
    sortedR = allResultsTable(keeperIndexes, :); % Subset table for colonies
    if isempty(sortedR)
        fprintf('No colonies meet Sorting2 criteria for %s. Skipping Excel export.\n', baseFileName);
    else
        % Assign colony numbers for table
        sortedR.Colony = (1:height(sortedR))';
        % Export table to Excel
        output_file = fullfile(folder, sprintf('Results_%d.xlsx', imageNum));
        writetable(sortedR, output_file);
        fprintf('Results saved to %s\n', output_file);
    end
    
    Maskedbi = ismember(labeled, keeperIndexes); % masked
    maskedI = Image;
    maskedI(~Maskedbi) = 0;
    subplot(3, 3, 8);
    imshow(maskedI, []);
    axis image;
    title('Sorting2', 'FontSize', captionFontSize);
    
    color_labels = label2rgb(maskedI, 'hsv', 'k', 'shuffle');
    subplot(3, 3, 9);
    imshow(color_labels);
    axis image;
    title('Colony colored', 'FontSize', captionFontSize);
    
    drawnow; % Update figure
end

% Final timing
elapsedTime = toc;
fprintf('Processing completed in %.2f seconds.\n', elapsedTime);