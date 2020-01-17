function cost = sqCost(target, x, varargin)

  % options and defaults
  options = struct;
  options.Normalize = false;

  if nargout && ~nargin
    cost = options;
    return
  end

  % validate and accept options
  options = corelib.parseNameValueArguments(options, varargin{:});

  if target == 0
    % don't normalize to avoid divide-by-zero error
    cost = sum((x - target).^2);
  elseif options.Normalize
    % normalize by target squared
    cost = sum((x - target).^2 ./ target.^2);
  else
    % don't normalize
    cost = sum((x - target).^2);
  end

end % function
