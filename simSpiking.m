function [cost, rate, V, costparts] = simSpiking(x, ~, ~)

  % function to be passed to the optimizer
  % computes the firing rate and chooses a cell with a firing rate around 20 Hz

  cost      = 0;
  costparts = zeros(3, 1);
  weights   = [1, 1e2, 1e-3];

  % add some injected current
  % x.I_ext = 0.2;

  % get rid of the transient
  x.reset
  x.closed_loop = true;
  V = x.integrate;

  % simulate for real
  V = x.integrate;

  %% Cost for a failed integration

  if any(isnan(V))
    costparts(1) = weights(1) * 1e9;
  end

  %% Cost for number of spikes and firing rate

  target_firing_rate  = 0.01; % MHz
  target_num_spikes   = x.t_end * target_firing_rate; % unitless

  % compute the spiketimes, stopping at a maximum of 600
  spiketimes = veclib.nonnans(xtools.findNSpikeTimes(V - mean(V), 600, 10));

  % compute the firing rate in Hz
  ISIs = diff(spiketimes); % ms
  rate = 1 / mean(ISIs); % MHz
  CV = std(ISIs) * rate; % unitless
  rate = 1e3 * rate; % Hz

  % penalize irregular spiking
  if isnan(rate) || isempty(rate)
    costparts(2) = weights(2) * 1e9;
  else
    costparts(2) = weights(2) * (CV)^2;
  end

  % penalize the number of spikes about a target value
  if isempty(spiketimes)
    costparts(3) = weights(3) * 1e9;
  else
    costparts(3) = weights(3) * (length(spiketimes) - target_num_spikes)^2;
  end

  %% Compute the final cost

  cost = sum(costparts);

end % function
