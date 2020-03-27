% Script to find single-compartment minimal model thalamocortical cells
% which have a dynamic range of possible firing rates
% in tonic-firing regimes.
% The F-I characteristic should be continuous,
% monotonically-increasing, and have a sufficient dynamic range
% (i.e. is not flat).

%% Create a xolotl model

x = model_soplata();

%% Create an xfit object

simulation_function = 'simDecay';

p = xfit;
p.x = x;
p.options.UseParallel = true;
p.SimFcn = str2func(simulation_function);

% parameters
p.parameter_names = [x.find('*gbar')];
p.lb = zeros(1, length(p.parameter_names));
p.ub = 2 * [x.get('*gbar')];

% set xfit options
p.options.MaxTime = 900;
p.options.SwarmSize = 24;
p.options.UseParallel = true;

%% Initialize optimization parameters

% optimization parameters
nSims       = 20;
nEpochs     = 3;
nParams     = length(p.parameter_names);

% output vectors
params      = NaN(nSims, nParams);
cost        = NaN(nSims, 1);
% mean_rat    = NaN(nSims, 3);
% I_ext       = NaN(nSims, 2);
% costparts   = NaN(nSims, 5);

%% Fit parameters

% try to load existing data file
filename = ['data-', simulation_function, '-', corelib.getComputerName, '.mat'];
if exist(filename, 'file')
    load(filename)
    start_idx = find(isnan(cost), 1, 'first');
else
    % no file found, begin a new one
    start_idx = 1;
end

% main loop
for ii = start_idx:nSims

    try
        % set seed using entirely random method
        p.seed = p.ub .* rand(size(p.ub));

        % run xfit
        for qq = 1:nEpochs
            p.fit;
        end

        % save output
        params(ii, :) = p.seed;
        save(filename, 'cost', 'params', 'costparts');
        disp(['saved simulation ', num2str(ii)])

    catch err

        disp('Something went wrong!')

    end % try/catch

end % main loop
