function IntAdaptiveTest
% function <a href="matlab:IntTrapezoidalTest">IntTrapezoidalTest</a>
% Test <a href="matlab:help IntTrapezoidal">IntTrapezoidal</a> on a representative scalar function.
% See <a href="matlab:NRweb">Numerical Renaissance: simulation, optimization, & control</a>, Section 9.4.
% Part of <a href="matlab:help NRC">Numerical Renaissance Codebase 1.0</a>, <a href="matlab:help NRchap09">Chapter 9</a>; please read the <a href="matlab:help NRcopyleft">copyleft</a>.
% See also IntRombergTest, IntAdaptiveTest.

disp('Testing the adaptive integration method.')
figure(1); clf; hold off; L=.1; R=2; b=(L+R)/2;
fa=Compute_f_Test(L); fb=Compute_f_Test(b); fc=Compute_f_Test(R);
[int,evals]=IntAdaptive(@Compute_f_Test,L,R,1e-4,3,fa,fb,fc)
end % function IntAdaptiveTest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f=Compute_f_Test(x)
f=sin(1./x); plot(x,f,'x'); hold on
end % function Compute_f_Test
