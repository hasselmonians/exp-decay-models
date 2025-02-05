% ### minSpikingCurrent
%
%
% **Syntax**
%
% ```matlab
% [I_ext, ii, metrics, V] = minSpikingCurrent(x)
% [I_ext, ii, metrics, V] = minSpikingCurrent(x, 'PropertyName', PropertyValue, ...)
% [I_ext, ii, metrics, V] = minSpikingCurrent(x, options)
% ```
%
% **Description**
%
% Finds the minimum injected current required to cause a xolotl model to spike with a given frequency.
% The model is simulated with constant injected current determined by the `current_steps` option,
% which is a vector of real numbers,
% until the minimum firing rate is reached.
% The output `I_ext` contains the current magnitude needed to cause the model to spike,
% `index` contains the linear index into the `current_steps` vector.
% `metrics` contains a struct of computed statistics for the resultant spike train.
%
% If called without arguments or outputs, a struct
% containing fields for all optional arguments, `options`,
% is created.
%
% Otherwise, the first argument should be a xolotl object,
% and the latter should be either name, value keyword pairs,
% or a struct to specify options.
% Options with a `NaN` value are ignored, and the default is used instead.
%
% | Option Name | Default Value | Units |
% | ----------- | ------------- | ----- |
% | `current_steps` | 0:0.01:1 | nA |
% | `debug` | false | |
% | `min_firing_rate` | 1 | Hz |
% | `sampling_rate` | 20 | 1/ms |
% | `spike_threshold` | 10 | mV |
% | `verbosity` | true | |
%
%
%
% !!! info "See Also"
%     xtools.V2metrics
%     xtools.findNSpikes
%     xtools.findNSpikeTimes
%

function [varargout] = minSpikingCurrent(x, varargin)

  %% Preamble

  % options and defaults
  options = struct;
  options.min_firing_rate = 1; % Hz
  options.spike_threshold = 10; % mV
  options.debug = false; % boolean
  options.current_steps = 0:0.01:1; % nA
  options.sampling_rate = 1/(1000 * x.dt); % Hz
  options.ibi_thresh = 300; % ms
  options.verbosity = true; % boolean

  options = orderfields(options);

  if nargout && ~nargin
    varargout{1} = options;
    return
  end

  % validate and accept options
  options = corelib.parseNameValueArguments(options, varargin{:});

  % save the initial state
  if any(strcmp({x.snapshots.name}, 'minSpikingCurrent'))
    corelib.verb(options.verbosity, 'minSpikingCurrent', 'overwriting ''minSpikingCurrent'' snapshot')
  else
    corelib.verb(options.verbosity, 'minSpikingCurrent', 'creating ''minSpikingCurrent'' snapshot')
  end

  x.snapshot('minSpikingCurrent');

  %% Main loop

  % iterate through the current steps and count the number of spikes
  % stop when the firing rate is equal to or greater than the min firing rate parameter

  for ii = 1:length(options.current_steps)
    corelib.verb(options.verbosity, 'minSpikingCurrent', ['I_ext = ' num2str(options.current_steps(ii)) ' nA'])

    x.reset('minSpikingCurrent');
    x.closed_loop = true;
    x.I_ext = options.current_steps(ii);

    x.integrate; % acquire steady-state
    V = x.integrate; % store voltage trace

    % if the simulation fails, return NaNs
    if isnan(V(:))
      corelib.verb(options.verbosity, 'minSpikingCurrent', 'ERROR: voltage is NaN, aborting...')
      I_ext = NaN;
      metrics = NaN;
      varargout{1} = I_ext;
      varargout{2} = ii;
      varargout{3} = metrics;
      varargout{4} = V;
      return
    end

    % compute metrics of the voltage trace
    metrics = xtools.V2metrics(V - mean(V), options);

    % break the loop if the stop criteria is reached
    if metrics.firing_rate >= options.min_firing_rate
      break
    end
  end % for loop


  corelib.verb(ii == length(options.current_steps) & options.verbosity, 'minSpikingCurrent', ['maximum iterations reached'])


  % outputs
  I_ext = options.current_steps(ii);
  varargout{1} = I_ext;
  varargout{2} = ii;
  varargout{3} = metrics;
  varargout{4} = V;

end % function
