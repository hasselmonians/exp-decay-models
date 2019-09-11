function plotNModels(x, cost, param_names, params, n)

  if ~exist('n', 'var')
    n = length(cost);
  end

  figure; hold on

  [~, index] = sort(cost);
  cmap = colormaps.linspecer(n);
  x.t_end = 1e3;

  for ii = 1:n
    x.reset;
    x.set(param_names, params(index(ii), :));
    V = x.integrate;
    t = x.dt * (1:length(V));
    plot(t, V, 'Color', cmap(ii, :));
  end

  xlabel('time (ms)')
  ylabel('membrane potential (mV)')

  figlib.pretty('PlotBuffer', 0.2);

end % function
