function [cost, V, I_ext, mean_rat, CV, tau_fr, costparts] = simDecay(x, ~, ~)

  % find an applied current that produces spikes
  % then, simulate with more current,
  % then, drop the current

  % containers
  cost        = 0;
  costparts   = zeros(5, 1);
  weights     = [1, 1, 1, 1, 1];
  V           = NaN(x.t_end / x.dt, 3);
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
  x.integrate;

  % simulate and save the voltage
  V(:, 1) = x.integrate;

  % penalize models with NaN voltage
  if any(isnan(V(:, 1)))
    cost = 1e10;
    return
  end

  % increase the current and keep simulating
  x.I_ext = I_ext2;
  V(:, 2) = x.integrate;

  % penalize models with NaN voltage
  if any(isnan(V(:, 2)))
    cost = 1e10;
    return
  end

  % suddenly drop the current back to the initial value
  x.I_ext = I_ext;
  V(:, 3) = x.integrate;

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
  costparts(1) = costparts(1) + xtools.binCost([1.2, Inf]*spiketimes{1}, spiketimes{2});

  % penalize model if the frequency of the I_ext condition is not greater than 10 Hz
  costparts(1) = costparts(1) + xtools.binCost([10, Inf], spiketimes{1});

  % penalize model if the frequency of the I_ext2 condition is not greater than 10 Hz
  costparts(1) = costparts(1) + xtools.binCost([12, Inf], spiketimes{2});

  %% Compute the ratio of adjacent interspike intervals (ISIs)

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


  % ------------------------------------

  %% Cost due to variation around exponential decay in firing rate
  % the coefficient of variation (CV) of the ratio of adjacent interspike intervals (ISIs)
  % should be 0 if the firing rate decays exponentially
  % the mean of the ratio is the base of the exponent

  costparts(3)  = sqCost(0, CV{3});

  %% Cost due to time constant of firing rate change
  % the time constant should be within an acceptable range

  costparts(4)  = xtools.binCost([0.5, 10], tau_fr(3));

  %% Compute the total cost

  cost      = sum(weights * costparts);

  if isnan(cost)
    cost = 3e10;
  end

end % function
