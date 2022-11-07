function [x] = NR_NewtonRaphson(x,n,Compute_f,Compute_A,tol,verbose)         
% function [x] = NewtonRaphson(x,n,Compute_f,Compute_A,tol,verbose)         
% This function solves f(x)=0 using the Newton Raphson method given an initial guess for
% x, where the function f(x) and its Jacobian are defined in Compute_f and Compute_A.
% Take verbose=1 for printing progress reports to screen, or verbose=0 to suppress.
% Verify with <a href="matlab:help NewtonRaphsonTest">NewtonRaphsonTest</a>, which shows how to pass function handles into this code.
% Numerical Renaissance codebase, Chapter 2, https://github.com/tbewley/NR
% Copyright 2021 by Thomas Bewley, distributed under BSD 3-Clause License. 

if nargin<5, tol=1e-10; end, residual=2*tol;
if nargin<6, verbose=1; end, if verbose, disp('Convergence:'), end
while (residual>tol)
   f=Compute_f(x);  A=Compute_A(x);  residual=norm(f);  x=x+NR_GaussPP(A,-f,n);
   if verbose, disp(sprintf('%20.13f ',x(1:n),residual)); end
end
end % function NR_NewtonRaphson
