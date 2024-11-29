clc; clear; close all;


original_img = imread('pcl_xz_30min.png');

if size(original_img, 3) == 3
    original_img = rgb2gray(original_img);
end

% rng(1); % For reproducibility
noisy_img = imnoise(original_img, 'gaussian', 0, 0.01);

% noisy_img = reshape(noisy_img, [size(noisy_img), 1]);
% original_img = reshape(original_img, [size(original_img), 1]);

noisy_img = im2single(noisy_img); % Convert to single precision
original_img = im2single(original_img);

input_data = {noisy_img};
output_data = {original_img};

input_ds = arrayDatastore(noisy_img, 'IterationDimension', 4);
output_ds = arrayDatastore(original_img, 'IterationDimension', 4);

training_ds = combine(input_ds, output_ds);

layers = [
    imageInputLayer([size(noisy_img,1), size(noisy_img, 2), 1])
    convolution2dLayer(3, 16, 'Padding', 'same')
    reluLayer
    convolution2dLayer(3, 16, 'Padding', 'same')
    reluLayer
    convolution2dLayer(3, 1, 'Padding', 'same')
    regressionLayer
    ];

options = trainingOptions('adam', ...
    'MaxEpochs', 60, ...
    'MiniBatchSize', 8, ...
    'InitialLearnRate', 1e-3, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true, ...
    'ExecutionEnvironment', 'cpu');


model_filename = 'cnn_7.mat';

% net = trainNetwork(cell2mat(training_data(:, 1)),cell2mat(training_data(:, 2)), layers, options);
net = trainNetwork(training_ds, layers, options);
save(model_filename, 'net');


denoised_img = predict(net, original_img);


lower_threshold = 0.01;
upper_threshold = 0.04;
sigma = 0.2; % Gaussian filter
edge_img = edge(denoised_img, 'canny', [lower_threshold upper_threshold], sigma);


[H, T, R] = hough(edge_img);
P = houghpeaks(H, 200, 'Threshold', 0.1 * max(H(:)));


lines = houghlines(edge_img, T, R, P, 'FillGap', 20, 'MinLength', 30);

line_img = repmat(original_img, [1 1 3]);% Create an RGB image to draw colored lines

% se = strel('square', 3);
% dilated_edges = imdilate(edge_img, se);
% eroded_edges = imerode(dilated_edges, se);

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];

    if abs(xy(1,1) - xy(2,1)) < 10 % Vertical line
        line_img = insertShape(line_img, 'Line', [xy(1,1), xy(1,2), xy(2,1), xy(2,2)], 'Color', 'red', 'LineWidth', 2);
    elseif abs(xy(1,2) - xy(2,2)) < 10 % Horizontal line
        line_img = insertShape(line_img, 'Line', [xy(1,1), xy(1,2), xy(2,1), xy(2,2)], 'Color', 'blue', 'LineWidth', 2);
    end
end


[H, T, R] = hough(edge_img);
P = houghpeaks(H, 200, 'Threshold', 0.1 * max(H(:)));
lines = houghlines(edge_img, T, R, P, 'FillGap', 20, 'MinLength', 30);

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    if abs(xy(1,1) - xy(2,1)) < 10 % Vertical line
        line_img = insertShape(line_img, 'Line', [xy(1,1), xy(1,2), xy(2,1), xy(2,2)], 'Color', 'red', 'LineWidth', 2);
    elseif abs(xy(1,2) - xy(2,2)) < 10 % Horizontal line
        line_img = insertShape(line_img, 'Line', [xy(1,1), xy(1,2), xy(2,1), xy(2,2)], 'Color', 'blue', 'LineWidth', 2);
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
