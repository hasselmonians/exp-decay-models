%% Plot the results of the spiking model optimization

%% Load the data

load('data-simSpiking-rkc-has-ld-0001.mat');

%% Plot some of the waveforms

model_howard
plotNModels(x, cost, param_names, params, 10)

%% Clean up the data

% impute all NaNs to zeros
% this preserves the structure of the dataset
params(isnan(params)) = 0;

% normalize the data by rescaling each feature
for ii = 1:size(params, 2)
  params(:, ii) = rescale(params(:, ii));
end

%% Visualize the parameter space in 2 dimensions

Y = fast_tsne(params);

figure;
scatter(Y(:, 1), Y(:, 2));
axis square
xlabel('dim. 1 (a.u.)')
ylabel('dim. 2 (a.u.)')

figlib.pretty();
