function [cost, I_ext] = testCost(x, ~, ~)

  % this is a test of minSpikingCurrent within xfit

  I_ext = minSpikingCurrent(x, 'current_steps', 0:0.001:1, 'min_firing_rate', 10, 'verbosity', false);

  cost = normSqCost(0.2, I_ext);

end
