function [cost, V, costparts] = simDecay(x, ~, ~)

  cost = 0;
  costparts = zeros(5, 1);
  weights = [1, 1, 1, 1, 1];

  % simulate with some injected current
  x.reset;
  x.closed_loop = true;
  V = x.integrate;

  % simulate for real
  x.set('I_ext', 0);
  V = x.integrate;

  % compute the spike times
  spiketimes = veclib.nonnans(xtools.findNSpikeTimes(V - mean(V), 600, 10));

  %% Cost due to exponential decay in firing rate
  % the coefficient of variation (CV) of the ratio of adjacent interspike intervals (ISIs)
  % should be 0 if the firing rate decays exponentially
  % the mean of the ratio is the base of the exponent

  rat           = ratio(spiketimes);
  CV            = std(rat) / mean(rat);
  costparts(1)  = sqCost(0, CV);


  %% Compute the total cost

  costparts = weights .* costparts;
  cost      = sum(cost);

end % function
