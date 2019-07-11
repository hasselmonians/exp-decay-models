x = xolotl;

%% Instantiate a single-compartment model

x.add('compartment', 'comp', 'Cm', 10, 'A', 0.029);
x.comp.add('bucholtz/CalciumMech');

x.comp.add('soplata/thalamocortical/NaV', 'gbar', 900, 'E', 50);
x.comp.add('soplata/thalamocortical/Kd', 'gbar', 1000, 'E', -100);
x.comp.add('soplata/thalamocortical/HCurrent', 'gbar', 0.25, 'E', -43);
% x.comp.add('soplata/thalamocortical/CaT', 'gbar', 20);
x.comp.add('Leak', 'gbar', 0.1, 'E', -50);

x.add('compartment', 'Somatic', 'Cm', 30, 'radius', 2.42/1e3, 'len', 110/1e3);
x.Somatic.add('traub/CalciumMech', 'f', 17402, 'tau_Ca', 13.33);
x.Somatic.add('traub/NaV', 'gbar', 300, 'E', 50);
x.Somatic.add('traub/Cal', 'gbar', 40, 'E', 30);
x.Somatic.add('traub/Kd', 'gbar', 150, 'E', -80);
x.Somatic.add('traub/Kahp', 'gbar', 8, 'E', -80);
x.Somatic.add('traub/KCa', 'gbar', 100, 'E', -80);
x.Somatic.add('traub/ACurrent', 'gbar', 50, 'E', -80);
x.Somatic.add('Leak', 'gbar', 1, 'E', -50);

% gbars = 10* [30 4 15 0.8 10 50 0.1];
% % gbars = 10* [30 15 50 0.1];
% comps = x.find('compartment');
% conds = {'NaV', 'Cal', 'Kd', 'Kahp', 'KCa', 'ACurrent', 'Leak'};
% % conds = {'NaV', 'Kd', 'ACurrent', 'Leak'};
%
% for ii = 1:length(comps)
%     for qq = 1:length(conds)
%         x.(comps{ii}).(conds{qq}).gbar = gbars(ii, qq);
%     end
% end


%% Set up xfit

p           = xfit;
p.x         = x;
p.sim_func  = @simSpiking;

% parameters
param_names = x.find('*gbar');
p.parameter_names = param_names;
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
filename    = ['data-simSpiking-traub-' corelib.getComputerName '.mat'];
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
