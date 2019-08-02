p           = xfit;
p.x         = x;
p.options.UseParallel = true;
p.SimFcn    = @simSpiking;

% parameters
param_names = [x.find('*gbar'); {'I_ext'}];
p.parameter_names = param_names;
p.lb = zeros(1, length(p.parameter_names));
p.ub = 500 * ones(1, length(p.parameter_names));
p.ub(7) = 1;

% set procrustes options
p.options.MaxTime = 900;
p.options.SwarmSize = 24;

%% Initialize optimization parameters

% optimization parameters
nSims       = 100;
nEpochs     = 3;
nParams     = length(p.parameter_names);

% output vectors
params      = NaN(nSims, nParams);
cost        = NaN(nSims, 1);
rate        = NaN(nSims, 1);

%% Fit parameters


% try to load existing data file
filename    = ['data-simSpiking-' corelib.getComputerName '.mat'];
if exist(filename)
  load(filename)
  start_idx = find(isnan(cost),1,'first')
else
  % otherwise begin a new one
  start_idx = 1;
end


% main loop
for ii = start_idx:nSims

  try

    % set seed
    p.seed = p.ub .* rand(size(p.ub));

    % run xfit
    for qq = 1:nEpochs
      p.fit;
    end

    % save
    params(ii, :)  = p.seed;
    [cost(ii), rate(ii)] = p.SimFcn(x);
    save(filename, 'cost', 'params', 'rate', 'param_names');
    disp(['saved simulation ' num2str(ii)])

  catch

    disp('Something went wrong.')

  end

end
