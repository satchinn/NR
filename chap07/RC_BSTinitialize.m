function [D,r]=RC_BSTinitialize(D)
% function [D,r]=RC_BSTinitialize(D)
% Initialize a RC_BST based on a list of records D with markers in the first column.
% Renaissance Codebase, https://github.com/tbewley/RC/NRchap07
% Copyright 2023 by Thomas Bewley, distributed under BSD 3-Clause License. 
% See also RC_BSTinsert, RC_BSTrotateLR, RC_BSTrotateL, RC_BSTrotateR, RC_BSTbalance, RC_BSTenumerate,
% RC_BSTsuccessor.  Verify with RC_BSTtest.

[n,m]=size(D); D=[D zeros(n,5)]; r=1;
for i=2:n, [D,r]=RC_BSTinsert(D,i,r); if mod(i,1)==0, RC_BSTplot(D,r), pause(.01), end, end
disp('Press any key to do final balancing.  If balancing during insertion was adequate,')
disp('this step will not do that much...'); pause; [D,r]=RC_BSTbalance(D,r); RC_BSTplot(D,r)
end % function RC_BSTinitialize                                   
