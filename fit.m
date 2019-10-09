p           = xfit;
p.x         = x;
p.options.UseParallel = true;
p.SimFcn    = @simDecay;

% parameters
param_names = [x.find('*gbar')];
p.parameter_names = param_names;
p.lb = zeros(1, length(p.parameter_names));
p.ub = 2 * [x.get('*gbar')]';

% set procrustes options
p.options.MaxTime = 900;
p.options.SwarmSize = 24;

%% Initialize optimization parameters

% optimization parameters
nSims       = 20;
nEpochs     = 3;
nParams     = length(p.parameter_names);

% output vectors
params      = NaN(nSims, nParams);
cost        = NaN(nSims, 1);
rate        = NaN(nSims, 1);
I_ext       = NaN(nSims, 1);

%% Fit parameters

% try to load existing data file
filename    = ['data-simDecay-' corelib.getComputerName '.mat'];
if exist(filename)
  load(filename)
  start_idx = find(isnan(cost),1,'first')
else
  % otherwise begin a new one
  start_idx = 1;
end

% load up initial parameters
seeds = load('data-simSpiking-rkc-has-ld-0001.mat')


% main loop
for ii = start_idx:nSims

  try

    % set seed
    % p.seed = p.ub .* rand(size(p.ub));
    % parameters from one of the pretrained seeds +/- 20%
    p.seed = seeds.params(randi(length(seeds.params)), :);
    p.seed = p.seed .* (0.8 + 0.4 * rand(1, size(seeds.params, 2)));
    % p.seed = params(ii, :);

    % run xfit
    for qq = 1:nEpochs
      p.fit;
    end

    % save
    params(ii, :)  = p.seed;
    [cost(ii), ~, I_ext(ii), rate(ii), ~] = p.SimFcn(x);
    save(filename, 'cost', 'params', 'rate', 'I_ext', 'param_names');
    disp(['saved simulation ' num2str(ii)])

  catch e
    keyboard
    disp('Something went wrong.')

  end

end
