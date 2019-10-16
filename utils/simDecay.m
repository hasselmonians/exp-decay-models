function [cost, V, Ca, I_ext, mean_rat, CV, tau_fr, costparts] = simDecay(x, ~, ~)

  % find an applied current that produces spikes
  % then, simulate with more current,
  % then, drop the current

  % containers
  cost        = 0;
  costparts   = zeros(5, 1);
  weights     = [1, 1e2, 1, 1e2, 1];
  V           = NaN(x.t_end / x.dt, 3);
  Ca          = NaN(x.t_end / x.dt, 3);
  spiketimes  = cell(3, 1);
  rat         = cell(3, 1);
  mean_rat    = NaN(3, 1);
  tau_fr      = NaN(3, 1);
  CV          = NaN(3, 1);

  %% Figure out the minimum applied current for the model

  I_ext       = minSpikingCurrent(x, 'min_firing_rate', 10, 'current_steps', 0:0.001:1, 'verbosity', false);
  I_ext2      = minSpikingCurrent(x, 'min_firing_rate', 20, 'current_steps', I_ext:0.001:2*I_ext, 'verbosity', false);

  %% Simulate the three conditions

  x.reset;
  x.closed_loop = true;
  x.I_ext = I_ext;

  % reach a tonic-spiking steady-state
  x.t_end = 5e3;
  x.integrate;

  % simulate and save the voltage
  [V(:, 1), Ca_] = x.integrate;
  Ca(:, 1) = Ca_(:, 1);

  % penalize models with NaN voltage
  if any(isnan(V(:, 1)))
    cost = 1e10;
    return
  end

  % increase the current and keep simulating
  x.t_end = 10;
  x.I_ext = I_ext2;
  [V(:, 2), Ca_] = x.integrate;
  Ca(:, 2) = Ca_(:, 1);

  % penalize models with NaN voltage
  if any(isnan(V(:, 2)))
    cost = 1e10;
    return
  end

  % suddenly drop the current back to the initial value
  x.t_end = 5e3;
  x.I_ext = I_ext;
  [V(:, 3), Ca_] = x.integrate;
  Ca(:, 3) = Ca_(:, 1);

  % penalize models with NaN voltage
  if any(isnan(V(:, 3)))
    cost = 1e10;
    return
  end

  %% Compute the spike times

  for ii = 1:3
    spiketimes{ii} = veclib.nonnans(xtools.findNSpikeTimes(V(:, ii) - mean(V(:, ii)), 600, 10));
  end

  %% Compute cost due to number of spikes/firing rate

  sim_time = x.t_end / 1000; % seconds

  % penalize model if the frequency of the I_ext2 condition is not significantly greater
  costparts(1) = costparts(1) + xtools.binCost([1.2, 1e9]*getFrequency(spiketimes{1}, sim_time), getFrequency(spiketimes{2}, sim_time));

  % penalize model if the frequency of the I_ext condition is not greater than 10 Hz
  costparts(1) = costparts(1) + xtools.binCost([10, 1e9], getFrequency(spiketimes{1}, sim_time));

  % penalize model if the frequency of the I_ext2 condition is not greater than 12 Hz
  costparts(1) = costparts(1) + xtools.binCost([12, 1e9], getFrequency(spiketimes{2}, sim_time));

  %% Compute the ratio of adjacent interspike intervals (ISIs)

  % gather relevant metrics
  for ii = 1:3
    % ratio of adjacent ISIs (seconds / seconds)
    rat{ii} = ratio(1e-3 * diff(spiketimes{ii}));
    % mean ratio of adjacent ISIs (seconds / seconds)
    mean_rat(ii) = mean(rat{ii});
    % coefficient of variation
    CV(ii) = std(rat{ii}) / mean_rat(ii);
    % time constant , computed from the mean ISI ratio
    tau_fr(ii) = 1 / log(mean_rat(ii));
  end

  %% Cost due to variation around exponential decay in firing rate
  % the coefficient of variation (CV) of the ratio of adjacent interspike intervals (ISIs)
  % should be 0 if the firing rate decays exponentially
  % the mean of the ratio is the base of the exponent

  for ii = 1:3
    costparts(2) = costparts(2) + sqCost(0, CV(ii));
  end

  %% Cost due to time constant of firing rate change
  % the time constant should be within an acceptable range

  costparts(3) = xtools.binCost([0.5, 10], tau_fr(3));

  if isnan(costparts(3)) || isinf(tau_fr(3))
    costparts(3) = 1e9;
  end

  %% Penalize mean ratio being unity
  % we want to see models that have decay

  costparts(4) = xtools.binCost([0, 0.9], mean_rat(3));

  %% Compute the total cost

  cost      = weights * costparts; % dot product => scalar cost

  if isnan(cost)
    cost = 3e10;
  end

  % output both injected currents
  I_ext = [I_ext, I_ext2];

end % function

function f = getFrequency(spiketimes, time)
  f = length(spiketimes) / time;
end
