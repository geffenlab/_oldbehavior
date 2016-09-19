function [pse, thresh, outData, paramsValues] = fitPsycho(subs,dataType)

% Fit psychometric function to yes/no responses to dot motion stim.
close all
if nargin < 2 error('Not enough input arguments...'); end


%% Directories
if strcmp(dataType,'afc')
    str = 'AFCFitData/';
    dType = 0;
elseif strcmp(dataType, 'yn')
    str = 'PsychoFitData/';
    dType = 1;
else
    error('Must specify ''yesno'' or ''AFC'' for data type...');
end
dataDir = [pwd filesep str];



%% Load and concatenate
catData = [];
for i = 1:length(subs)
    % Load data
    tmp = importdata([dataDir 'sub_' mat2str(subs(i)) '.dat']);
    data = [repmat(subs(i),length(tmp.data),1) tmp.data(:,2:end)];

    % Concatenate
    catData = [catData; data];
end

keyboard

% Coherence values
coherences = unique(catData(:,4));
fitCoherences = linspace(min(coherences),max(coherences),100);



%% FITTING TIME
% Using the PALAMEDES toolbox cos the other one won't work...

% Set parameters for each data type:
if dType
    PF = @PAL_CumulativeNormal;
    paramsValues0 = [mean(coherences) 1/((max(coherences')-min(coherences'))/4) ...
                     0 0];
    respCol = 6;
    allResps = catData(:,respCol) > 0;
    titleStr = '"Up" Responses per Sound Condition (Cum. Norm.)';
    yStr = 'p(Respond "Up")';
    legOff = [.6 .2];
else
    PF = @PAL_Weibull;
    paramsValues0 = [mean(coherences) .5 .5 0];
    respCol = 7;
    allResps = catData(:,respCol) == catData(:,6);
    titleStr = '2AFC Fits per Sound Condition (Weibull)';
    yStr = 'p(Correct)';
    legOff = [.8 .6];
    pse = [];
end

% Fitting parameters and options
% paramsFree = [1 1 0 0];
% options = PAL_minimize('options');
% lapseLimits = [0 1];                 % Limit range for lambda
paramsFree = [1 1 0 0];
options = optimset('fminsearch');   % Type help optimset
options.TolFun = 1e-09;             % Increase required precision on LL
options.Display = 'off';            % Suppress fminsearch messages
lapseLimits = [0 1];                % Limit range for lambda

% Fit for each sound direction:
colors = {'b','g','r'};
soundDirs = unique(catData(:,5));
hold on
for i = 1:length(soundDirs)
    % Select subset:
    tmp = [];
    tmp = catData(catData(:,5) == soundDirs(i), :);
    resps = allResps(catData(:,5) == soundDirs(i));
    realData{i} = grpstats(resps, tmp(:,4));
    
    % Group stats
    fitData{i} = [grpstats(resps, tmp(:,4), 'sum') ...
                  grpstats(resps, tmp(:,4), 'numel')];
    
    % Fitting
    [paramsValues{i}] = PAL_PFML_Fit(...
        coherences,fitData{i}(:,1),fitData{i}(:,2), ...
        paramsValues0,paramsFree,PF,'searchOptions',options, ...
        'lapseLimits',lapseLimits);
    respFit = PF(paramsValues{i}, fitCoherences');
    
    % Plot data and fit
    plot(coherences, realData{i},'.','Color',colors{i}, ...
         'MarkerSize',20);
    h(i) = plot(fitCoherences, respFit, '-', 'Color', colors{i}, ...
                'LineWidth', 3);
    title(titleStr);
    xlabel('Coherences');
    ylabel(yStr);
    set(gca, 'FontSize', 16);
    
    % Find Point of Subjective Equality and threshold and plot
    fprintf('Sound Direction %+d (Palamedes Fit):\n', soundDirs(i));
    if dType
        pse(i) = PF(paramsValues{i}, .5, 'inverse');
        thresh(i) = PF(paramsValues{i}, .75, 'inverse') ...
            - PF(paramsValues{i}, .5, 'inverse');
        fprintf('\tPSE: %+4.03f\n\tThresh: %4.03f\n', ...
                pse(i), thresh(i));
        plot([pse(i) pse(i)], [0 1], ':', 'Color', colors{i}, ...
             'LineWidth', 2);
    else
        thresh(i) = PF(paramsValues{i}, .75, 'inverse');
        fprintf('\tThresh (@ .82 correct): %4.03f\n', thresh(i));
        plot([thresh(i) thresh(i)], [.5 .75], ':', 'Color', colors{i}, ...
             'LineWidth', 2);
    end
    
    % Format data for output
    outData{i} = [coherences ...
                  grpstats(resps, tmp(:,4), 'sum') ...
                  grpstats(resps, tmp(:,4), 'numel') ...
                  grpstats(resps, tmp(:,4))];
    
end
% Plot threshold boundary
plot([min(coherences) max(coherences)], [.75 .75], 'k:', 'LineWidth', 2);
hleg = legend(h, 'Down', 'Flat', 'Up', 'Location', 'SE');
legend('boxoff');
ht = text(legOff(1), legOff(2), sprintf('Sound\nDirection:'), 'FontSize', 14, 'FontWeight', 'bold');
set(ht, 'units', 'normalized');
hold off

return

threshs = [.184 .243 .267; .172 .249 .193];
hold on
plot(threshs(1,:), '--k', 'LineWidth', 3);
plot(threshs(2,:), 'k', 'LineWidth', 3);
legend('2AFC', 'UP/DOWN', 'Location', 'NW');
title('75% Threshold Estimates per Experiment')
xlabel('Sound Direction');
ylabel('75% Threshold Estimate');
xlim([.5 3.5])
set(gca,'XTick', [1 2 3]);
set(gca,'XTickLabel', {'Down', 'Flat', 'Up'});
set(gca, 'FontSize', 16);
hold off


    
    
    
    



    

