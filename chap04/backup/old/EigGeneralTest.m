% script EigGeneralTest
% Test EigGeneral.m, together with ShiftedInversePower.m, on a random matrix.
% Numerical Renaissance Codebase 1.0, Chapter 4; see text for copyleft info.

clear; n=10; A=randn(n)+sqrt(-1)*randn(n);  lam=EigGeneral(A)
[S]=ShiftedInversePower(A,lam);    eig_error=norm(A*S-S*diag(lam))
[U,T]=ShiftedInversePower(A,lam);  schur_error=norm(A-U*T*U')

% end script EigGeneralTest
