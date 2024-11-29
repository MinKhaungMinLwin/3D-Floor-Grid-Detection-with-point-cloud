clc; clear; close all;

pt_1 = pcread('Ply files/3rd Floor Male (019) - Cloud.ply');

figureHandle = figure;

pcshow(pt_1, 'VerticalAxis', 'Y', 'VerticalAxisDir', 'Down');
title("5th Floor Male (019)");

view([0 360]);% Set view to XZ plane

title('Original');

axis off;
ax = gca;
ax.XLabel.String = '';
ax.YLabel.String = '';
ax.ZLabel.String = '';
ax.Title.String = '';

resolution = 600; % DPI (dots per inch)
print(figureHandle, 'pcl_3ndFloor.png', '-dpng', ['-r', num2str(resolution)]);

keyPressTimer = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
    'TimerFcn', @(~, ~) checkKeyPress(figureHandle));

start(keyPressTimer);

disp('Press any key to close the image window ...');


waitfor(figureHandle);
stop(keyPressTimer);
delete(keyPressTimer);

function checkKeyPress(figureHandle)
    if ~ishandle(figureHandle)
        return;
    end
    k = get(figureHandle, 'CurrentCharacter');
    if ~isempty(k)
        close(figureHandle);
    end
end
