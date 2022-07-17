program PoissonMG2DTest
! A 2D Poisson solver on a uniform mesh using multigrid with red/black smoothing.
! RHS vector is assumed to be scaled such that the discretized Laplace operator has a 1
! By Thomas Bewley, Paolo Luchini, Paul Belitz, and Anish Karandikar.
include 'PoissonMG2DTest.f90.header'
! -------------------------------------- USER INPUT --------------------------------------
! XBC=1 for hom. Dirichlet (0:NX), =2 for periodic (-1:NX), =3 for hom. Neumann (-1:NX+1).
! Same for YBC. NX, NY must be powers of two with NX>=NY. N1,N2,N3 set how much smoothing
NX=256; NY=256; XBC=1; YBC=1; N1=2; N2=2; N3=2            ! is applied at various steps.
! ----------------------------------- END OF USER INPUT ----------------------------------
print *, 'BCs: ',XBC,',',YBC,'. Smoothing: ',N1,',',N2,',',N3,'.  Grids:'
call PoissonMG2DInit(NX,NY)
s=0.; do j=3,g(0)%ym-2; do i=3,g(0)%xm-2         ! The RHS vector b is stored in the
    call random_number(h); d(0)%d(i,j)=h; s=s+h  ! initial value of -d [see (3.8a)], here
end do; end do                                   ! taken as a zero-mean random number.
d(0)%d(3:g(0)%xm-2,3:g(0)%ym-2)=d(0)%d(3:g(0)%xm-2,3:g(0)%ym-2)-s/(g(0)%xm-4.)/(g(0)%ym-4.)
call PoissonMG2D
end program PoissonMG2DTest
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine PoissonMG2DInit(NX,NY)
! This initialization routine defines several global variables to avoid the repeated
! memory allocation/deallocation otherwise caused by recursion.  Note that d and v are
! defined as arrays of arrays, which are of different size at each level l.
include 'PoissonMG2DTest.f90.header'
select case(XBC); case(1); xo=1; case(2); xo=2; case(3); xo=2; end select
select case(YBC); case(1); yo=1; case(2); yo=2; case(3); yo=2; end select
nlev=int(log10(real(min(NX,NY)))/log10(2.0))-1; call random_seed; sum = 0.0                  
do l=0,nlev
   g(l)%nx = NX/(2**l); g(l)%ny = NY/(2**l);  ! The g data structure contains
   g(l)%xm=g(l)%nx+XBC; g(l)%ym=g(l)%ny+YBC;  ! information about the grids.
   allocate(v(l)%d(g(l)%xm,g(l)%ym)); allocate(d(l)%d(g(l)%xm,g(l)%ym));
   v(l)%d=0.0; d(l)%d=0.0;  print *,l,g(l)%nx,g(l)%ny   ! d=defect, v=correction.
end do
end subroutine PoissonMG2DInit
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine PoissonMG2D
include 'PoissonMG2DTest.f90.header'
integer :: ta(8);  real*8 :: MaxDefect
e=MaxDefect(0); print *,'Iter=0, max defect=',e	
do i=1,N1; call Smooth(0); end do ! APPLY SMOOTHING BEFORE STARTING MULTIGRID (N1 times)
call date_and_time(values=ta); t = ta(5)*3600 + ta(6)*60 + ta(7) + 0.001*ta(8) 
main: do iter=1,10                ! PERFORM UP TO 10 MULTIGRID CYCLES.
   o=e; call Multigrid(0); e = MaxDefect(0);
   print *,'Iter=',iter,', max defect=',e,'factor=',o/e
   if (e<1E-13) then; print *,'Converged'; exit main; end if 
end do main 
call date_and_time(values=ta); t = ta(5)*3600 + ta(6)*60 + ta(7) + 0.001*ta(8) - t 
print *,'-> Total time: ',t,' sec; Time/iteration: ',t/iter,' sec'
do l=0,nlev; deallocate(v(l)%d); deallocate(d(l)%d); end do
end subroutine PoissonMG2D
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
recursive subroutine Multigrid(l) 
! The main recursive function for the multigrid algorithm. It calls the smoothing function,
! it performs the restriction and prolongation, and calls itself on the coarser grid.
include 'PoissonMG2DTest.f90.header'
do i=1,N2; call Smooth(l); end do    !  APPLY SMOOTHING STEPS BEFORE COARSENING (N2 times)
! Now COMPUTE THE DEFECT and RESTRICT it to the coarser grid in a single step.  TRICK #1:
! we will SKIP several factors below, including a /2 factor here; however, all skipped
! factors cancel.  TRICK #2 we calculate the defect ONLY on the red points here, as the
! defect on the neighboring black points is zero coming out of the previous call to Smooth.
! Note: this is restriction with half weighting [see (3.13)].
do jc=2,g(l+1)%ym-1; j=2*(jc-yo)+yo; do ic=2,g(l+1)%xm-1;  i=2*(ic-xo)+xo;
   d(l+1)%d(ic,jc)=(v(l)%d(i+1,j)+v(l)%d(i-1,j)+v(l)%d(i,j+1)+ &
                    & v(l)%d(i,j-1))/4 -v(l)%d(i,j) +d(l)%d(i,j);                                  
end do; end do
v(l+1)%d=d(l+1)%d;   ! TRICK #3: this is a better initial guess for v{l+1} than v{l+1}=0.
call EnforceBCs(l);
! Now CONTINUE DOWN TO COARSER GRID, or SOLVE THE COARSEST SYSTEM (via 20 smooth steps).
! We use same smoother on coarser grid; ie, we SKIP a *4 [i.e., *(delta x)^2] factor here.
if (l<nlev-1) then; call Multigrid(l+1); else; do i=1,20; call Smooth(nlev); end do; end if
! Now perform the PROLONGATION.  TRICK #4: Update black interior points only, as next call
! to Smooth recalculates all red points from scratch, so do not bother updating them here.
! We SKIP a /2 factor here (thus, we end up skipping a /2, *4, and /2, which all cancel).
do jc=2,g(l+1)%ym; j=2*(jc-yo)+yo; do ic=2,g(l+1)%xm; i=2*(ic-xo)+xo;     
   if (j<=g(l)%ym) then; v(l)%d(i-1,j)=v(l)%d(i-1,j)+(v(l+1)%d(ic-1,jc)+v(l+1)%d(ic,jc));
   end if
   if (i<=g(l)%xm) then; v(l)%d(i,j-1)=v(l)%d(i,j-1)+(v(l+1)%d(ic,jc-1)+v(l+1)%d(ic,jc));
   end if
end do; end do
call EnforceBCs(l)
do i=1,N3; call Smooth(l); end do    ! APPLY SMOOTHING STEPS AFTER COARSENING (N3 times)
end subroutine Multigrid 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine Smooth(l)
! Checkerboard smoothing with A from Poisson eluation scaled to unit diagonal elements.
! The set of points updated first, which we label as "red", includes the corners.
include 'PoissonMG2DTest.f90.header'
do irb=0,1; do j=2,g(l)%ym-1
   m=2+mod(j+irb+xo+yo,2); n=g(l)%xm-1;  v(l)%d(m:n:2,j) = d(l)%d(m:n:2,j) &
     & + (v(l)%d(m+1:n+1:2,j)+v(l)%d(m-1:n-1:2,j)+v(l)%d(m:n:2,j+1)+v(l)%d(m:n:2,j-1))/4;
end do; call EnforceBCs(l); end do
end subroutine Smooth
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine EnforceBCs(l)
include 'PoissonMG2DTest.f90.header'
! Enforce the Neumann and/or periodic boundary conditions (nothing to do for Dirichlet)
i=g(l)%xm-1; j=g(l)%ym-1;
select case(XBC);
   case(3); v(l)%d(1,2:j)=v(l)%d(3,2:j);         v(l)%d(g(l)%xm,2:j)=v(l)%d(g(l)%xm-2,2:j)
   case(2); v(l)%d(1,2:j)=v(l)%d(g(l)%xm-1,2:j); v(l)%d(g(l)%xm,2:j)=v(l)%d(2,2:j)
end select
select case(YBC);
   case(3); v(l)%d(2:i,1)=v(l)%d(2:i,3);         v(l)%d(2:i,g(l)%ym)=v(l)%d(2:i,g(l)%ym-2)
   case(2); v(l)%d(2:i,1)=v(l)%d(2:i,g(l)%ym-1); v(l)%d(2:i,g(l)%ym)=v(l)%d(2:i,2)
end select
end subroutine EnforceBCs
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
real*8 function MaxDefect(l)
include 'PoissonMG2DTest.f90.header'
MaxDefect = 0.0; do j=2,g(l)%ny; do i=2,g(l)%nx              ! Compute the maximum defect.
   MaxDefect = max(MaxDefect,abs((v(l)%d(i+1,j) + v(l)%d(i-1,j) +v(l)%d(i,j+1) &
             & +v(l)%d(i,j-1))/4 +d(l)%d(i,j) -v(l)%d(i,j)))
end do; end do
end function MaxDefect
