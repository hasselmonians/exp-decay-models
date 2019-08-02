function [cost, rate, V] = simSpiking(x, ~, ~)

  % function to be passed to the optimizer
  % computes the firing rate and chooses a cell with a firing rate around 20 Hz

  cost = 0;

  % add some injected current
  % x.I_ext = 0.2;

  % get rid of the transient
  x.reset
  x.closed_loop = true;
  V = x.integrate;

  % simulate for real
  V = x.integrate;

  if any(isnan(V))
    cost = cost + 400;
  end

  % compute the spiketimes, stopping at a maximum of 600
  spiketimes = veclib.nonnans(xtools.findNSpikeTimes(V, 600, -30));

  % compute the firing rate in Hz
  rate = 1e3 / mean(diff(spiketimes));


  % compute the cost
  if isnan(rate) || isempty(rate)
    cost = cost + 400;
  else
    cost = cost + (rate - 5)^2;
  end

end % function
