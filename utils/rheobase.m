% finds the rheobase of a xolotl model by increasing the injected current until the model spikes
% stops when the model begins spiking at a given frequency, or 100 simulations are reached

%% Arguments:
%   x: the xolotl object
%   min_firing_rate: the minimum acceptable firing rate to terminate the simulations (Hz)
%   current_resolution: the current step to use to determine the rheobase (nA)
%   verbosity: print extra information?
%   varargin: arguments to xtools.V2metrics
%% Outputs:
%   I_ext: the determined rheobase in nA
%% Example
%   I_ext = rheobase(x, 0.5, 0.01, 'sampling_rate', 1/x.dt)

function [I_ext, firing_rate] = rheobase(x, min_firing_rate, current_resolution, verbosity, varargin)

  is_spiking = false;
  x.I_ext = 0;
  I_ext = 0;
  counter = 0;

  while is_spiking == false
    counter = counter + 1;
    corelib.verb(verbosity, 'rheobase', ['I_ext = ' num2str(I_ext) ' nA, counter = ' num2str(counter)])

    x.reset;
    x.closed_loop = true;
    x.integrate;
    V = x.integrate;

    metrics = xtools.V2metrics(V, varargin{:});
    if metrics.firing_rate > min_firing_rate | counter > 100;
      is_spiking = true;
      firing_rate = metrics.firing_rate;
    else
      I_ext = I_ext + current_resolution;
      x.I_ext = I_ext;
    end

  end

end
