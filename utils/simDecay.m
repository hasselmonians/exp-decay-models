function [cost, V, I_ext, mean_rat, CV, tau_fr, costparts] = simDecay(x, ~, ~)

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
  mean_rat    = NaN(3, 1);
  tau_fr      = NaN(3, 1);

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

  sim_time = x.t_end / 1000; % seconds
  for ii = 1:3
    nSpikes = length(spiketimes{ii});

    % the number of spikes must be at least one per second of simulated time
    if nSpikes / sim_time < 1
      costparts(1) = costparts(1) + 1e9;
    end

    % the number of spikes in the second phase must be at least ten per second of simulated time
    if ii == 2 || nSpikes / sim_time < 10
      costparts(1) = costparts(1) + 1e9;
    end

  end

  %% Compute the ratio of adjacent interspike intervals (ISIs)

  for ii = 1:3
    % ratio of adjacent ISIs in seconds
    rat{ii} = ratio(1e-3 * diff(spiketimes{ii}));
    % mean ratio of adjacent ISIs in seconds
    mean_rat(ii) = mean(rat{ii});
    % coefficient of variation
    CV{ii} = std(rat{ii}) / mean_rat(ii);
    % time constant, computed from the mean ISI ratio
    tau_fr(ii) = 1 / log(mean_rat(ii));
  end

  %% Cost due to variation around exponential decay in firing rate
  % the coefficient of variation (CV) of the ratio of adjacent interspike intervals (ISIs)
  % should be 0 if the firing rate decays exponentially
  % the mean of the ratio is the base of the exponent

  costparts(2)  = sqCost(0, CV{3});

  %% Cost due to time constant of firing rate change
  % the time constant should be within an acceptable range

  costparts(3)  = xtools.binCost([0.5, 10], tau_fr(3));

  %% Compute the total cost

  cost      = sum(weights * costparts);

end % function
