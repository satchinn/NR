% script <a href="matlab:Wave1D_Newmark_Pade_Test">Wave1D_Newmark_Pade_Test</a>
% See <a href="matlab:NRweb">Numerical Renaissance: simulation, optimization, & control</a>, Section 11.3.
% Part of <a href="matlab:help NRC">Numerical Renaissance Codebase 1.0</a>, <a href="matlab:help NRchap11">Chapter 11</a>; please read the <a href="matlab:help NRcopyleft">copyleft</a>.
% See also Wave1D_ItCN_Pade_Test, Wave1D_ItCN_Pade_Test.

figure(2); clf; axis([-2 2 -.2 1.2]); xlabel('x'); ylabel('u'); hold on;
for k=1:4;
  switch k
    case 1, N=128; dt=.01;
    case 2, N= 32; dt=.01;
    case 3, N=128; dt=.02; 
    case 4, N=128; dt=.04; 
  end
  disp(sprintf('Testing Wave1D_ItCN_FD with N=%d, dt=%0.4g',N,dt));
  [q,x]=Wave1D_Newmark_Pade(4,4,1.0,N,dt); grid; if k<4, pause; else, disp(' '), end

  figure(2); plot(x,q); pause(0.001);
end
% end script Wave1D_Newmark_Pade_Test
