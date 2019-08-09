function [cost, V, costparts] = simDecay(x, ~, ~)

  cost = 0;
  costparts = zeros(5, 1);
  weights = [1, 1, 1, 1, 1];

  % figure out the rheobase for the model
  I_ext = rheobase(x, [], [], false, 'sampling_rate', 1/x.dt);

  % simulate with some injected current
  x.reset;
  x.closed_loop = true;
  x.I_ext = I_ext;
  V = x.integrate;

  spiketimes = veclib.nonnans(xtools.findNSpikeTimes(V - mean(V), 600, 10));

  % simulate with twice the current
  x.reset;
  x.I_ext = 2 * I_ext;
  V2 = x.integrate;

  % compute the spike times
  spiketimes2 = veclib.nonnans(xtools.findNSpikeTimes(V2 - mean(V2), 600, 10));

  % concatenate the two simulations to get the full trace
  V = [V; V2];

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

  %% Cost due to exponential decay in firing rate
  % the coefficient of variation (CV) of the ratio of adjacent interspike intervals (ISIs)
  % should be 0 if the firing rate decays exponentially
  % the mean of the ratio is the base of the exponent

  rat           = ratio(spiketimes2);
  CV            = std(rat) / mean(rat);
  costparts(2)  = sqCost(0, CV);

  %% Compute the total cost

  costparts = weights .* costparts;
  cost      = sum(cost);

end % function
