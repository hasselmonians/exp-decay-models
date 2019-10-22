%% Plot the results of the exponential decay model optimization

%% Load the data

load('data-simDecay-rkc-has-ld-0001.mat')

%% Plot some of the waveforms

model_howard

% impute all NaNs to zeros
params(isnan(params)) = 0;

[~, costs_ordered] = sort(cost, 'ascend');

for ii = 1:5
  x.set(param_names, params(costs_ordered(ii), :));
  [~, V, Ca, I_ext] = simDecay(x);

  % generate figure
  figure;

  % plot the voltage
  ax(2) = subplot(4, 1, 2);
  % collect the voltage in a single vector
  V_vec = cat(1, V{:});
  t = 1e-3 * x.dt * (1:length(V_vec));
  plot(t, V_vec);

  % plot the firing rate
  ax(1) = subplot(4, 1, 1);
  spiketimes = veclib.nonnans(xtools.findNSpikeTimes(V_vec - mean(V_vec), 600, 10));
  rate = 1 ./ (1e-3 * diff(spiketimes));
  plot(1e-3 * x.dt * spiketimes(1:end-1), rate);

  % add labels
  ylabel(ax(1), 'firing rate (Hz)')
  ylabel(ax(2), 'membrane potential (mV)')
  title(ax(1), ['parameter set: ' num2str(costs_ordered(ii))])

  ax(3) = subplot(4, 1, 3);
  Ca_vec = cat(1, Ca{:});
  plot(t, Ca_vec)
  ylabel(ax(3), '[Ca++] (uM)')

  ax(4) = subplot(4, 1, 4);
  I_app = I_ext(1) * ones(size(V_vec));
  % get the times for the increased current
  t2 = length(V{1}) + (1:length(V{2}));
  I_app(t2) = I_ext(2);
  plot(t, I_app)
  xlabel(ax(4), 'time (s)')
  ylabel(ax(4), 'I_{app} (nA)')

  figlib.pretty('PlotBuffer', 0.1, 'LineWidth', 1)
end
