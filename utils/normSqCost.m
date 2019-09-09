function cost = normSqCost(target, x)
  cost = (x - target).^2 / target;
end
