% finds the rheobase of a xolotl model by increasing the injected current until the model spikes
% the current starts at whatever I_ext is set to, and then increases by the current step each iteration
% stops when the model begins spiking at a given frequency, or 100 simulations are reached

%% Arguments:
%   x: the xolotl object
%   min_firing_rate: the minimum acceptable firing rate to terminate the simulations (Hz)
%   current_steps: a vector of current steps to determine the rheobase
%   verbosity: print extra information?
%   varargin: arguments to xtools.V2metrics

%% Outputs:
%   I_ext: the determined rheobase in nA
%   ii: the index into current_steps for I_ext
%   metrics: properties of the waveform computed by xtools

%% Example
%   I_ext = rheobase(x, 0.5, 0:0.01:1, 'sampling_rate', 1/x.dt)

%% See Also: xtools.V2metrics

function [I_ext, ii, metrics] = rheobase(x, min_firing_rate, current_steps, verbosity, varargin)

  if ~exist('min_firing_rate', 'var') || isempty(min_firing_rate)
    min_firing_rate = 1; % Hz
  end

  if ~exist('current_steps', 'var') || isempty(current_steps)
    current_steps = 0:0.01:1; % nA
  end

  if ~exist('verbosity', 'var') || isempty(verbosity)
    verbosity = true;
  end

  % save the initial state
  x.snapshot('rheobase_function');

  for ii = 1:length(current_steps)
    corelib.verb(verbosity, 'rheobase', ['I_ext = ' num2str(current_steps(ii)) ' nA'])

    x.reset('rheobase_function');
    x.closed_loop;
    x.I_ext = current_steps(ii);

    x.integrate;
    V = x.integrate;

    metrics = xtools.V2metrics(V, varargin{:});

    if metrics.firing_rate >= min_firing_rate
      break
    end
  end % for loop

  corelib.verb(ii == length(current_steps) & verbosity, 'rheobase', ['maximum iterations reached'])

  I_ext = current_steps(ii);

end % function
