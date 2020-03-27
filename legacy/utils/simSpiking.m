function [cost, rate, V, I_ext, costparts] = simSpiking(x, ~, ~)

  % function to be passed to the optimizer
  % computes the firing rate and chooses a cell with a firing rate around 10 Hz
  % also computes the FI curve and fits a line to it

  cost      = 0;
  rate      = 0;
  costparts = zeros(5, 1);
  weights   = [1, 1, 1, 1, 1];

  [I_ext, ~, metrics, V] = minSpikingCurrent(x, 'current_steps', 0:0.001:1, ...
                        'min_firing_rate', 10, 'verbosity', false);
  % I_ext = 0.02;
  % metrics.firing_rate = 10;
  % metrics.spike_peak_mean = 20;
  % metrics.min_V_mean = -70;
  % metrics.isi_std = 0;
  % V = rand(1000,1);

  %% Cost for a failed integration

  if any(isnan(V)) || isnan(I_ext) || ~isstruct(metrics)
    costparts(1) = 1e9;
  end

  %% Cost for number of spikes and firing rate

  target_firing_rate = 10; % Hz
  target_spike_height = [0, 30]; % mV
  target_spike_trough = [-80, -60]; % mV

  try
    costparts(2) = normSqCost(target_firing_rate, metrics.firing_rate);
    costparts(3) = xtools.binCost(target_spike_height, metrics.spike_peak_mean);
    costparts(4) = xtools.binCost(target_spike_trough, metrics.min_V_mean);
    costparts(5) = sqCost(0, metrics.isi_std * metrics.firing_rate);
  catch
    costparts(2:5) = 1e9;
  end

  %% Compute the final cost

  cost = sum(weights * costparts);

  if isnan(cost)
    cost = 1e12;
  end

  % compute outputs
  try
    rate = metrics.firing_rate;
  catch
    rate = NaN;
  end

end % function
