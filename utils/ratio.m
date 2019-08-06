% computes the ratio between adjacent elements in an array
%
% Arguments:
%   x: a vector to be ratio'd
% Outputs:
%   y: the ratio'd vector, the dimension is one less than x (same as with 'diff')
%     y is always a column vector (n x 1)
%
% Example:
%   y = ratio(x);
%   ratio([1, 2, 3]) => [2.0000, 1.5000]'
%
% See Also: diff

function y = ratio(x)

  if isvector(x)
    x = x(:);
  end
    y = x(2:end, :) ./ x(1:end-1, :);

end % function
