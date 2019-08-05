function plotNModels(x, cost, param_names, params, n)

  if ~exist('n', 'var')
    n = length(cost);
  end

  figure; hold on

  [~, index] = sort(cost);

  for ii = 1:n
    x.reset;
    x.set(param_names, params(index(ii), :));
    V = x.integrate;
    plot(V);
  end

end % function
