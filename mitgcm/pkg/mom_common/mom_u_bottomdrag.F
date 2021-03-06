C $Header: /u/gcmpack/MITgcm/pkg/mom_common/mom_u_bottomdrag.F,v 1.9 2008/10/21 18:04:16 jmc Exp $
C $Name:  $

#include "MOM_COMMON_OPTIONS.h"

CBOP
C !ROUTINE: MOM_U_BOTTOMDRAG

C !INTERFACE: ==========================================================
      SUBROUTINE MOM_U_BOTTOMDRAG(
     I        bi,bj,k,
     I        uFld, KE, KappaRU,
     O        uDragTerms,
     I        myThid)

C !DESCRIPTION:
C Calculates the drag due to friction and the no-slip condition at bottom:
C \begin{equation*}
C G^u_{drag} = - \frac{1}{\Delta r_f} ( r_b + C_D |v| + \frac{2}{\Delta r_c} ) u
C \end{equation*}

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#ifdef ALLOW_BOTTOMDRAG_CONTROL
# include "DYNVARS.h"
#endif

C !INPUT PARAMETERS: ===================================================
C  bi,bj                :: tile indices
C  k                    :: vertical level
C  uFld                 :: zonal flow
C  KE                   :: Kinetic energy
C  KappaRU              :: vertical viscosity
C  myThid               :: thread number
      INTEGER bi,bj,k
      _RL uFld(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL KE(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL KappaRU(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  uDragTerms           :: drag term
      _RL uDragTerms(1-OLx:sNx+OLx,1-OLy:sNy+OLy)

C !LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
C  Kp1                  :: =k+1 for k<Nr, =Nr for k>=Nr
      INTEGER i,j,kDown,kDownC,kBottom
      _RL viscFac, dragFac
      _RL rdrckp1, maskDown
CEOP

C-  No-slip BCs impose a drag at bottom
      IF ( usingZCoords ) THEN
       kBottom = Nr
       kDown   = min(k+1,kBottom)
       kDownC  = kDown
c      dragFac = mass2rUnit*rhoConst
c      dragFac = wUnit2rVel(k+1)
       dragFac = 1. _d 0
      ELSE
       kBottom = 1
       kDown   = max(k-1,kBottom)
       kDownC  = k
       dragFac = mass2rUnit*rhoConst
c      dragFac = wUnit2rVel(k)
      ENDIF
      rdrckp1=recip_drC(kDownC)
      IF (k.EQ.kBottom) rdrckp1=recip_drF(k)
      viscFac=0.
      IF (no_slip_bottom) viscFac=1.
      DO j=1-Oly,sNy+Oly-1
       DO i=1-Olx+1,sNx+Olx-1
        maskDown=_maskW(i,j,kDown,bi,bj)
        IF (k.EQ.kBottom) maskDown=0.
        uDragTerms(i,j)=
     &   -_recip_hFacW(i,j,k,bi,bj)*recip_drF(k)
     &   *(
     &      2.*KappaRU(i,j,kDownC)*rdrckp1*viscFac
#ifdef ALLOW_BOTTOMDRAG_CONTROL
     &     + bottomdragfld(i,j,bi,bj)*dragFac
#else
     &     + bottomDragLinear*dragFac
#endif
     &    )*(1.-maskDown)*uFld(i,j)
        IF ( (KE(i,j)+KE(i-1,j)) .NE. 0. ) THEN
         uDragTerms(i,j)=uDragTerms(i,j)
     &    -_recip_hFacW(i,j,k,bi,bj)*recip_drF(k)
     &    *bottomDragQuadratic*SQRT(KE(i,j)+KE(i-1,j))*dragFac
     &    *(1.-maskDown)*uFld(i,j)
        ENDIF
       ENDDO
      ENDDO

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics) THEN
        CALL DIAGNOSTICS_FILL(uDragTerms,'UBotDrag',k,1,2,bi,bj,myThid)
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

      RETURN
      END
