function [cost, V, I_ext, tau_fr, costparts] = simDecay(x, ~, ~)

  % find an applied current that produces spikes
  % then, simulate with more current,
  % then, drop the current

  cost        = 0;
  costparts   = zeros(5, 1);
  weights     = [1, 1, 1, 1, 1];

  % containers
  V           = NaN(x.t_end / x.dt, 3);
  spiketimes  = cell(3, 1);
  rat         = cell(3, 1);
  mean_rat    = Nan(3, 1);
  tau_fr      = Nan(3, 1);

  %% Figure out the minimum applied current for the model

  I_ext       = minSpikingCurrent(x, 'min_firing_rate', 1, 'verbosity', false);
  I_ext_2     = minSpikingCurrent(x, 'min_firing_rate', 10, 'verbosity', false);

  %% Simulate with some injected current

  x.reset;
  x.closed_loop = true;
  x.I_ext = I_ext;
  % reach a tonic-spiking steady-state
  x.integrate;
  % simulate and save the voltage
  V(:, 1) = x.integrate;

  % compute the spike times
  spiketimes{1} = veclib.nonnans(xtools.findNSpikeTimes(V(:, 1) - mean(V(:, 1)), 600, 10));

  %% Simulate with much more current

  x.reset;
  x.I_ext = I_ext_2;
  V(:, 2) = x.integrate;

  % compute the spike times
  spiketimes{2} = veclib.nonnans(xtools.findNSpikeTimes(V(:, 2) - mean(V(:, 2)), 600, 10));

  %% Simulate once more with the normal current

  x.reset
  x.I_ext = I_ext;
  V(:, 3) = x.integrate;

  % compute the spike times
  spiketimes{3} = veclib.nonnans(xtools.findNSpikeTimes(V(:, 3) - mean(V(:, 3)), 600, 10));

  %% Cost due to number of spikes
  % the number of spikes must be at least one per second of simulated time

  sim_time = x.t_end / 1000; % seconds
  nSpikes = length(spiketimes);
  nSpikes2 = length(spiketimes2);

  if nSpikes / sim_time < 1
    costparts(1) = costparts(1) + 1e9;
  end

  if nSpikes2 / sim_time < 1
    costparts(1) = costparts(1) + 1e9;
  end

  %% Cost due to the ratio of the ISIs
  % TODO: talk to Zoran or Marc about this...

  rat           = ratio(1e-3 * diff(spiketimes2)); % ratio of adjacent ISIs in seconds
  mean_rat      = mean(rat);

  %% Cost due to variation around exponential decay in firing rate
  % the coefficient of variation (CV) of the ratio of adjacent interspike intervals (ISIs)
  % should be 0 if the firing rate decays exponentially
  % the mean of the ratio is the base of the exponent

  CV            = std(rat) / mean_rat;
  costparts(3)  = sqCost(0, CV);

  %% Cost due to time constant of firing rate change
  % the time constant should be within an acceptable range
  tau_fr        = 1 / log(mean_rat);
  costparts(4)  = xtools.binCost([0.5, 10], tau_fr);

  %% Compute the total cost

  cost      = sum(weights * costparts);

end % function
