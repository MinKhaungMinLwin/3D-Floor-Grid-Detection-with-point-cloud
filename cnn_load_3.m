clc; clear; close all;

original_img = imread('pcl_xz_30min.png');

if size(original_img, 3) == 3
    original_img = rgb2gray(original_img);
end

original_img = im2single(original_img);% Convert to single precision


model_filename = 'cnn_4.mat';
loaded_data = load(model_filename);
net = loaded_data.net;

denoised_img = predict(net, original_img);

lower_threshold = 0.01;
upper_threshold = 0.04;
sigma = 0.2; % Gaussian filter
edge_img = edge(denoised_img, 'canny', [lower_threshold upper_threshold], sigma);

[H, T, R] = hough(edge_img);

P = houghpeaks(H, 200, 'Threshold', 0.1 * max(H(:)), 'NHoodSize', [11 11]);

lines = houghlines(edge_img, T, R, P, 'FillGap', 20, 'MinLength', 30);

function merged_lines = merge_nearby_lines(lines, distance_threshold)
    if isempty(lines)
        merged_lines = [];
        return;
    end

    merged_lines = lines(1);% start the margin line with first line

    for k = 2:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        is_nearby = false;
    
        for j = 1:length(merged_lines)
            xy2 = [merged_lines(j).point1; merged_lines(j).point2];
            if is_lines_nearby(xy, xy2, distance_threshold)
                is_nearby = true;
                break;
            end
        end
    
        if ~is_nearby
            merged_lines = [merged_lines; lines(k)];
        end
    end
end

function is_near = is_lines_nearby(line1, line2, threshold)
    distance1 = pdist2(line1, line2);% Check if the lines are collinear and close to each other
    distance2 = pdist2(line2, line1);
    is_near = any(distance1 < threshold, 'all') || any(distance2 < threshold, 'all');
end

distance_threshold = 10;
merged_lines = merge_nearby_lines(lines, distance_threshold);

line_img = repmat(original_img, [1 1 3]);% Create an image to draw the lines on


for k = 1:length(merged_lines)% Draw the detected lines (blue)
    xy = [merged_lines(k).point1; merged_lines(k).point2];
    if abs(xy(1,1) - xy(2,1)) < 1 % Vertical line
        line_img = insertShape(line_img, 'Line', [xy(1,1), xy(1,2), xy(2,1), xy(2,2)], 'Color', 'blue', 'LineWidth', 4);
    elseif abs(xy(1,2) - xy(2,2)) < 1 % Horizontal line
        line_img = insertShape(line_img, 'Line', [xy(1,1), xy(1,2), xy(2,1), xy(2,2)], 'Color', 'blue', 'LineWidth', 4);
    end
end

for col = 1:size(original_img, 2)% Draw red lines in the gaps between blue lines
    col_lines = [];
    for k = 1:length(merged_lines)
        if abs(merged_lines(k).point1(1) - col) < 1 && abs(merged_lines(k).point2(1) - col) < 1
            col_lines = [col_lines; merged_lines(k)];
        end
    end
    if isempty(col_lines)
        continue;
    end
    y_coords = [];
    for k = 1:length(col_lines)
        y_coords = [y_coords; col_lines(k).point1(2); col_lines(k).point2(2)];
    end
    y_coords = sort(y_coords);
    for k = 1:length(y_coords)-1
        if y_coords(k+1) - y_coords(k) > 1
            line_img = insertShape(line_img, 'Line', [col, y_coords(k), col, y_coords(k+1)], 'Color', 'red', 'LineWidth', 2);
        end
    end
end

for row = 1:size(original_img, 1)
    row_lines = [];
    for k = 1:length(merged_lines)
        if abs(merged_lines(k).point1(2) - row) < 1 && abs(merged_lines(k).point2(2) - row) < 1
            row_lines = [row_lines; merged_lines(k)];
        end
    end
    if isempty(row_lines)
        continue;
    end
    x_coords = [];
    for k = 1:length(row_lines)
        x_coords = [x_coords; row_lines(k).point1(1); row_lines(k).point2(1)];
    end
    x_coords = sort(x_coords);
    for k = 1:length(x_coords)-1
        if x_coords(k+1) - x_coords(k) > 1
            line_img = insertShape(line_img, 'Line', [x_coords(k), row, x_coords(k+1), row], 'Color', 'red', 'LineWidth', 2);
        end
    end
end


figure;
subplot(1, 4, 1), imshow(original_img), title('Original Image');
subplot(1, 4, 2), imshow(denoised_img), title('Denoised Image');
subplot(1, 4, 3), imshow(edge_img), title('Edge Detected Image');
subplot(1, 4, 4), imshow(line_img), title('Grid Lines Detected');

disp('Press any key to close the image window...');
pause;
close(gcf);
