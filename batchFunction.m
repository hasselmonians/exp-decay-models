function batchFunction(varargin)

  % options & defaults
  options = struct;
  options.nSims = 100;
  options.nEpochs = 3;
  options.simFcn = 'cost_fI';
  options.outfile = ['data-' options.simFcn '-' corelib.getComputerName() '.mat'];
  options.seeds = [];

  options = orderfields(options);

  % validate and accept options
  options = corelib.parseNameValueArguments(options, varargin{:});

  % select a xolotl model
  model_howard

  % create an xfit object
  p           = xfit;
  p.x         = x;
  p.options.UseParallel = true;
  p.SimFcn    = str2func(options.simFcn);

  % parameters
  param_names = [x.find('*gbar')];
  p.parameter_names = param_names;
  p.lb = zeros(1, length(p.parameter_names));
  p.ub = 2 * [x.get('*gbar')]';

  % set procrustes options
  p.options.MaxTime = 900;
  p.options.SwarmSize = 24;
  p.options.UseParallel = true;

  %% Initialize optimization parameters

  % optimization parameters
  nParams     = length(p.parameter_names);

  % output vectors
  cost        = NaN(options.nSims, 1);
  params      = NaN(options.nSims, nParams);

  % try to load existing data file
  if exist(options.outfile)
    load(options.outfile)
    start_idx = find(isnan(cost), 1, 'first');
  else
    % otherwise begin a new one
    start_idx = 1;
  end

  %% Begin the main loop

  % useful variables
  nSeeds = size(options.seeds, 1);

  for ii = start_idx:options.nSims

    % set the seed
    if ~isempty(options.seeds)
      p.seed = options.seeds(randi(nSeeds), :);
      p.seed = p.seed .* (0.8 + 0.4 * rand(1, nParams));
    else
      p.seed = p.ub .* rand(nParams);
    end

    % run xfit
    for qq = 1:options.nEpochs
      p.fit;
    end

    % save
    params(ii, :) = p.seed;
    [cost(ii)] = options.simFcn();
    save(options.outfile, 'cost', 'params');

  end

end % function
