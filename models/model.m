x = xolotl;

%% Instantiate a single-compartment model

x.add('compartment', 'comp', 'Cm', 10, 'A', 0.029, 'vol', 2.9e-5);

% intracellular calcium
x.comp.add('buchholtz/CalciumMech', 'phi', 1, 'tau_Ca', 5, 'Ca_in', 2.4e-3);

% x.comp.add('soplata/thalamocortical/NaV', 'gbar', 900, 'E', 50);
x.comp.add('soplata/thalamocortical/Kd', 'gbar', 1000, 'E', -100);
x.comp.add('soplata/thalamocortical/HCurrent', 'gbar', 0.25, 'E', -43);
x.comp.add('soplata/thalamocortical/CaT', 'gbar', 20);
x.comp.add('Leak', 'gbar', 0.1, 'E', -50);

%% Set up xfit

p           = xfit;
p.x         = x;
p.options.UseParallel = true;
p.SimFcn    = @simSpiking;

% parameters
p.parameter_names = x.find('*gbar');
p.lb = zeros(1, length(p.parameter_names));
p.ub = 2000 * ones(1, length(p.parameter_names));

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
filename    = ['data-simSpiking-ching-' corelib.getComputerName '.mat'];
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
    [cost(ii), rate(ii)] = p.sim_func(x);
    save(filename, 'cost', 'params', 'rate', 'param_names');
    disp(['saved simulation ' num2str(ii)])

  catch

    disp('Something went wrong.')

  end

end
