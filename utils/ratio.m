% computes the ratio between adjacent elements in an array
%
% Arguments:
%   x: a vector to be ratio'd
% Outputs:
%   y: the ratio'd vector
%
% Example:
%   y = ratio(x);
%   ratio([1, 2, 3]) => [0.5000, 0.6667]

function y = ratio(x)

  y = x(1:end-1) ./ x(2:end);

end
