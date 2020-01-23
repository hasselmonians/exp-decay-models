%% cost_fI
% cost function to optimize a single-compartment xolotl model
% for the following metrics:
%
%   * firing rate between 10 and 50 Hz
%   * slope of frequency-input (fI) curve between 0.1 and BIG NUMBER
%   * Pearson's r^2 correlation for the resulting linear fit of the fI curve
%
% the algorithm should be agnostic to whether the model is type I or type II excitable
% by making use of computing the rheobase

function cost = cost_fI(x, ~, ~)

  %% Target metrics

  target_firing_rate = [10, 50]; % Hz
  target_norm_gain = [1, 1]; % a.u.
  target_rsq = 1; % unitless

  weights = [1, 1, 1];
  costs = zeros(1, 3);

  %% Compute the rheobase
  % 10 Hz spiking => 100 spikes/10 seconds

  x.t_end = 10e3; % ms
  I = x.rheobase('nSpikes', 100);

  if isnan(I)
    cost = 1e12;
    return
  end

  %% Compute the fI curve

  fI = x.fI('I_min', I, 'I_max', 5*I, 'n_steps', 11, 't_end', 10e3);

  current_steps = fI.I;
  firing_rate = fI.f_up;

  if any(isnan(firing_rate)) || any(isinf(firing_rate))
    cost = 1e12;
    return
  end

  %% Fit a linear model to the fI curve

  p = polyfit(rescale(current_steps), firing_rate);
  fit_firing_rate = polyval(p, rescale(current_steps));

  % compute the R-squared value
  SS_residual = sum((firing_rate - fit_firing_rate).^2);
  SS_total = (length(firing_rate) - 1) * var(firing_rate);
  rsq = SS_residual / SS_total;

  %% Compute costs

  % cost due to firing rate
  for ii = 1:length(firing_rate)
    cost(1) = cost(1) + xtools.binCost(target_firing_rate, firing_rate(ii));
  end

  % cost due to normalized gain
  cost(2) = cost(2) + xtools.binCost(target_norm_gain, p(1));

  % cost due to goodness-of-fit
  cost(3) = cost(3) + sqCost(target_rsq, rsq);

  %% Compute the total cost

  cost = dot(weights, costs);


end % function
