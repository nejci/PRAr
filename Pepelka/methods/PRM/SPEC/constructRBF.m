function K = constructRBF(X, rbf_var)
% function K = constructRBF(X, rbf_var)
%   X - each row is an instance
%   rbf_var - the variance

XP = sum((X.^2),2);
tmpW = XP*ones(1,length(XP)) - 2*(X*X') + ones(length(XP),1)*XP';

if nargin < 2
    rbf_var = prctile(tmpW(tmpW>0),20)^0.5;
end
if isnan(rbf_var)  % added by Nejc to survive - dont know if this is ok
   rbf_var = eps; 
   tmpW = abs(tmpW);
end

tmpW = (tmpW+tmpW')/2;

K = exp( -1/(rbf_var^2)*  tmpW );