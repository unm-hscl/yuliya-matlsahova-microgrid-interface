function D = loadSystem(name)
%UNTITLED21 Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;

validateName = @(arg) validateattributes(arg, {'char', 'string'}, {'nonempty'});
addRequired(p, 'name', validateName);

parse(p, name);

S = load(name);
D = S.sys;

end

