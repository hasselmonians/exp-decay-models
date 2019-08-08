% finds the rheobase of a xolotl model by increasing the injected current until the model spikes
% the current starts at whatever I_ext is set to, and then increases by the current step each iteration
% stops when the model begins spiking at a given frequency, or 100 simulations are reached

%% Arguments:
%   x: the xolotl object
%   min_firing_rate: the minimum acceptable firing rate to terminate the simulations (Hz)
%   current_step: the current step to use to determine the rheobase (nA)
%   verbosity: print extra information?
%   varargin: arguments to xtools.V2metrics
%% Outputs:
%   I_ext: the determined rheobase in nA
%% Example
%   I_ext = rheobase(x, 0.5, 0.01, 'sampling_rate', 1/x.dt)

function [I_ext, firing_rate] = rheobase(x, min_firing_rate, current_step, verbosity, varargin)

  if ~exist('verbosity', 'var') || isempty(verbosity)
    verbosity = true;
  end

  if ~exist('current_step', 'var') || isempty(current_step)
    current_step = 0.01; % nA
  end

  if ~exist('min_firing_rate', 'var') || isempty(min_firing_rate)
    min_firing_rate = eps;

  % save the initial state
  x.snapshot('rheobase_function');

  % useful variables
  is_spiking = false;
  x.I_ext = 0;
  I_ext = 0;
  counter = 0;

  while is_spiking == false
    counter = counter + 1;
    corelib.verb(verbosity, 'rheobase', ['I_ext = ' num2str(I_ext) ' nA, counter = ' num2str(counter)])

    % simulate the model
    x.reset;
    x.closed_loop = true;
    % discard the transient
    x.integrate;
    V = x.integrate;

    % compute the firing rate
    metrics = xtools.V2metrics(V, varargin{:});

    % if 100 iterations have passed or the firing rate is greater than/equal to the minimum
    % terminate the simulation
    % otherwise, continue
    if metrics.firing_rate >= min_firing_rate | counter > 100;
      is_spiking = true;
      firing_rate = metrics.firing_rate;
    else
      I_ext = I_ext + current_step;
      x.I_ext = I_ext;
    end

  end

  % return to the initial state
  x.reset('rheobase_function');

end
