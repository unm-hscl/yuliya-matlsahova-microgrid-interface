function saveSystem(name, varargin)
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here

% Structure construction.
sys = struct();

for k = 2:nargin
    sys.(inputname(k)) = varargin{k - 1};
end

% Ssave the variable to a file.
[folder, ~, ~] = fileparts(mfilename('fullpath'));
name = fullfile(folder, name);
save(name, 'sys')

end

