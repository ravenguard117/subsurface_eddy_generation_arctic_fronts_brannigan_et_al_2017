C $Header: /u/gcmpack/MITgcm/pkg/seaice/seaice_freedrift.F,v 1.3 2010/11/09 00:36:04 jmc Exp $
C $Name:  $

#include "SEAICE_OPTIONS.h"

CBOP
      SUBROUTINE SEAICE_FREEDRIFT( myTime, myIter, myThid )
C     /==========================================================\
C     | SUBROUTINE  SEAICE_FREEDRIFT                             |
C     | o Solve ice approximate momentum equation analytically   |
C     \==========================================================/
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "GRID.h"
#include "SEAICE.h"
#include "SEAICE_PARAMS.h"

#ifdef ALLOW_AUTODIFF_TAMC
# include "tamc.h"
#endif

C     === Routine arguments ===
C     myTime :: Simulation time
C     myIter :: Simulation timestep number
C     myThid :: my Thread Id. number
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef SEAICE_ALLOW_FREEDRIFT
#ifdef SEAICE_CGRID

C     === Local variables ===
      INTEGER i, j, kSrf, bi, bj

      _RL tmpscal1,tmpscal2,tmpscal3,tmpscal4

      _RL taux_onIce_cntr, tauy_onIce_cntr, uvel_cntr, vvel_cntr
      _RL mIceCor, rhs_x, rhs_y, rhs_n, rhs_a, sol_n, sol_a

      _RL uice_cntr(1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      _RL vice_cntr(1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)


       kSrf=1

c initialize fields:
c ==================

       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           uice_fd(i,j,bi,bj)=0. _d 0
           vice_fd(i,j,bi,bj)=0. _d 0
           uice_cntr(i,j,bi,bj)=0. _d 0
           Vice_cntr(i,j,bi,bj)=0. _d 0
          ENDDO
         ENDDO
        ENDDO
       ENDDO

       CALL EXCH_UV_XY_RL( TAUX, TAUY, .TRUE., myThid )


       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1,sNy
          DO i=1,sNx

c preliminary computations:
c =========================
c factor to convert air-sea stress to air-ice stresss
           IF ( YC(I,J,bi,bj) .LT. ZERO ) THEN
            tmpscal1 = SEAICE_drag_south/OCEAN_drag
           ELSE
            tmpscal1 = SEAICE_drag      /OCEAN_drag
           ENDIF
c air-ice stress at cell center
           taux_onIce_cntr=
     &       tmpscal1*HALF*(TAUX(i,j,bi,bj)+TAUX(i+1,j,bi,bj))
           tauy_onIce_cntr=
     &       tmpscal1*HALF*(TAUY(i,j,bi,bj)+TAUY(i,j+1,bi,bj))
c mass of ice per unit area (kg/m2) times coriolis f
           mIceCor=SEAICE_rhoIce*HEFF(i,j,bi,bj)*_fCori(I,J,bi,bj)
c ocean velocity at cell center
           uvel_cntr=HALF*(uvel(i,j,kSrf,bi,bj)+uvel(i+1,j,kSrf,bi,bj))
           vvel_cntr=HALF*(vvel(i,j,kSrf,bi,bj)+vvel(i,j+1,kSrf,bi,bj))
c right hand side of free drift equation:
           rhs_x= -taux_onIce_cntr -mIceCor*vvel_cntr
           rhs_y= -tauy_onIce_cntr +mIceCor*uvel_cntr

c norm of angle of rhs
           tmpscal1=rhs_x*rhs_x + rhs_y*rhs_y
           if (tmpscal1.GT.0.) then
             rhs_n=sqrt( rhs_x*rhs_x + rhs_y*rhs_y )
             rhs_a=atan2(rhs_y,rhs_x)
           else
             rhs_n=0. _d 0
             rhs_a=0. _d 0
           endif

c solve for norm:
c ===============
           IF ( YC(I,J,bi,bj) .LT. ZERO ) THEN
            tmpscal1 = 1. _d 0 /SEAICE_waterDrag_south
           ELSE
            tmpscal1 = 1. _d 0 /SEAICE_waterDrag
           ENDIF
c polynomial coefficients
           tmpscal2= +tmpscal1*tmpscal1*mIceCor*mIceCor
           tmpscal3= -tmpscal1*tmpscal1*rhs_n*rhs_n
c discriminant
           tmpscal4=tmpscal2*tmpscal2-4*tmpscal3
           if (tmpscal4.GT.0) then
             sol_n=sqrt(HALF*(sqrt(tmpscal4)-tmpscal2))
           else
             sol_n=0. _d 0
           endif

c solve for angle:
c ================
           IF ( YC(I,J,bi,bj) .LT. ZERO ) THEN
            tmpscal1 = SEAICE_waterDrag_south
           ELSE
            tmpscal1 = SEAICE_waterDrag
           ENDIF
c
           tmpscal2= tmpscal1*sol_n*sol_n
           tmpscal3= mIceCor*sol_n
c
           tmpscal4=tmpscal2*tmpscal2 + tmpscal3*tmpscal3
           if (tmpscal4.GT.0) then
             sol_a=rhs_a-atan2(tmpscal3,tmpscal2)
           else
             sol_a=0. _d 0
           endif

c compute uice, vice at cell center:
c ==================================
           uice_cntr(i,j,bi,bj)=uvel_cntr-sol_n*cos(sol_a)
           vice_cntr(i,j,bi,bj)=vvel_cntr-sol_n*sin(sol_a)

          ENDDO
         ENDDO
        ENDDO
       ENDDO


c interpolated to velocity points:
c ================================

       CALL EXCH_UV_AGRID_3D_RL(uice_cntr,vice_cntr,.TRUE.,1,myThid)

       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1,sNy
          DO i=1,sNx
           uice_fd(i,j,bi,bj)=HALF*
     &       (uice_cntr(i-1,j,bi,bj)+uice_cntr(i,j,bi,bj))
           vice_fd(i,j,bi,bj)=HALF*
     &       (vice_cntr(i,j-1,bi,bj)+vice_cntr(i,j,bi,bj))
          ENDDO
         ENDDO
        ENDDO
       ENDDO

       CALL EXCH_UV_XY_RL( uice_fd, vice_fd, .TRUE., myThid )

C     Apply masks (same/similar to seaice_evp.F/seaice_lsr.F)
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1-Oly,sNy+Oly
         DO i=1-Olx,sNx+Olx
          uIce_fd(i,j,bi,bj)=uIce_fd(i,j,bi,bj)* _maskW(i,j,kSrf,bi,bj)
          vIce_fd(i,j,bi,bj)=vIce_fd(i,j,bi,bj)* _maskS(i,j,kSrf,bi,bj)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

#endif /* SEAICE_CGRID */
#endif /* SEAICE_ALLOW_FREEDRIFT */
      RETURN
      END
