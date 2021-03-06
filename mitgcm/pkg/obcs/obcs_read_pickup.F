C $Header: /u/gcmpack/MITgcm/pkg/obcs/obcs_read_pickup.F,v 1.3 2011/05/24 14:31:14 jmc Exp $
C $Name:  $

#include "OBCS_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C     !ROUTINE: OBCS_READ_PICKUP

C     !INTERFACE:
      SUBROUTINE OBCS_READ_PICKUP( myIter, myThid )

C     !DESCRIPTION:
C     *==========================================================*
C     | SUBROUTINE OBCS_READ_PICKUP
C     | o Read open boundary pickup file
C     *==========================================================*
C     |   Note: only Orlanski OBC needs pickup files to restart
C     *==========================================================*

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "OBCS_PARAMS.h"
#include "OBCS_FIELDS.h"
#include "ORLANSKI.h"

C     !INPUT/OUTPUT PARAMETERS:
      INTEGER myIter
      INTEGER myThid
CEOP

#ifdef ALLOW_ORLANSKI

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_FNAM) fn
      CHARACTER*(10) suff
      INTEGER prec

      IF ( pickupSuff.EQ.' ' ) THEN
        WRITE(suff,'(I10.10)') myIter
      ELSE
        suff = pickupSuff
      ENDIF
      prec = precFloat64

C--   Unlike horizontal 2D or 3D IO routines, no thread synchronisation is
C     done within  Vertical Section IO routines. Since only thread one is
C     doing IO, we need a barrier here to wait for every one to finish.
      _BARRIER

#ifdef ALLOW_OBCS_NORTH
      IF ( useOrlanskiNorth ) THEN
C     READ N and S OB storage and phase speed arrays
        WRITE(fn,'(2A)') 'pickup_orlanskiN.',suff
        CALL READ_REC_XZ_RL(fn,prec,Nr,UN_STORE_1, 1,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,UN_STORE_2, 2,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,UN_STORE_3, 3,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,UN_STORE_4, 4,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VN_STORE_1, 5,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VN_STORE_2, 6,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VN_STORE_3, 7,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VN_STORE_4, 8,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TN_STORE_1, 9,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TN_STORE_2,10,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TN_STORE_3,11,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TN_STORE_4,12,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SN_STORE_1,13,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SN_STORE_2,14,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SN_STORE_3,15,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SN_STORE_4,16,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_UN , 17,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_VN , 18,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_TN , 19,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_SN , 20,myIter,myThid)
#ifdef ALLOW_NONHYDROSTATIC
       IF ( nonHydrostatic ) THEN
        CALL READ_REC_XZ_RL(fn,prec,Nr,WN_STORE_1,21,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,WN_STORE_2,22,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,WN_STORE_3,23,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,WN_STORE_4,24,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_WN , 25,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, OBNw    , 26,myIter,myThid)
       ENDIF
#endif
      ENDIF
#endif /* ALLOW_OBCS_NORTH */

#ifdef ALLOW_OBCS_SOUTH
      IF ( useOrlanskiSouth ) THEN
        WRITE(fn,'(2A)') 'pickup_orlanskiS.',suff
        CALL READ_REC_XZ_RL(fn,prec,Nr,US_STORE_1, 1,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,US_STORE_2, 2,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,US_STORE_3, 3,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,US_STORE_4, 4,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VS_STORE_1, 5,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VS_STORE_2, 6,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VS_STORE_3, 7,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,VS_STORE_4, 8,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TS_STORE_1, 9,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TS_STORE_2,10,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TS_STORE_3,11,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,TS_STORE_4,12,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SS_STORE_1,13,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SS_STORE_2,14,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SS_STORE_3,15,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,SS_STORE_4,16,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_US , 17,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_VS , 18,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_TS , 19,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_SS , 20,myIter,myThid)
#ifdef ALLOW_NONHYDROSTATIC
       IF ( nonHydrostatic ) THEN
        CALL READ_REC_XZ_RL(fn,prec,Nr,WS_STORE_1,21,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,WS_STORE_2,22,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,WS_STORE_3,23,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr,WS_STORE_4,24,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, CVEL_WS , 25,myIter,myThid)
        CALL READ_REC_XZ_RL(fn,prec,Nr, OBSw    , 26,myIter,myThid)
       ENDIF
#endif
      ENDIF
#endif /* ALLOW_OBCS_SOUTH */

C     READ E and W OB storage and phase speed arrays
#ifdef ALLOW_OBCS_EAST
      IF ( useOrlanskiEast ) THEN
        WRITE(fn,'(2A)') 'pickup_orlanskiE.',suff
        CALL READ_REC_YZ_RL(fn,prec,Nr,UE_STORE_1, 1,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,UE_STORE_2, 2,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,UE_STORE_3, 3,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,UE_STORE_4, 4,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VE_STORE_1, 5,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VE_STORE_2, 6,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VE_STORE_3, 7,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VE_STORE_4, 8,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TE_STORE_1, 9,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TE_STORE_2,10,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TE_STORE_3,11,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TE_STORE_4,12,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SE_STORE_1,13,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SE_STORE_2,14,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SE_STORE_3,15,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SE_STORE_4,16,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_UE , 17,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_VE , 18,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_TE , 19,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_SE , 20,myIter,myThid)
#ifdef ALLOW_NONHYDROSTATIC
       IF ( nonHydrostatic ) THEN
        CALL READ_REC_YZ_RL(fn,prec,Nr,WE_STORE_1,21,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,WE_STORE_2,22,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,WE_STORE_3,23,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,WE_STORE_4,24,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_WE , 25,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, OBEw    , 26,myIter,myThid)
       ENDIF
#endif
      ENDIF
#endif /* ALLOW_OBCS_EAST */

#ifdef ALLOW_OBCS_WEST
      IF ( useOrlanskiWest ) THEN
        WRITE(fn,'(2A)') 'pickup_orlanskiW.',suff
        CALL READ_REC_YZ_RL(fn,prec,Nr,UW_STORE_1, 1,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,UW_STORE_2, 2,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,UW_STORE_3, 3,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,UW_STORE_4, 4,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VW_STORE_1, 5,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VW_STORE_2, 6,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VW_STORE_3, 7,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,VW_STORE_4, 8,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TW_STORE_1, 9,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TW_STORE_2,10,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TW_STORE_3,11,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,TW_STORE_4,12,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SW_STORE_1,13,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SW_STORE_2,14,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SW_STORE_3,15,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,SW_STORE_4,16,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_UW , 17,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_VW , 18,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_TW , 19,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_SW , 20,myIter,myThid)
#ifdef ALLOW_NONHYDROSTATIC
       IF ( nonHydrostatic ) THEN
        CALL READ_REC_YZ_RL(fn,prec,Nr,WW_STORE_1,21,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,WW_STORE_2,22,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,WW_STORE_3,23,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr,WW_STORE_4,24,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, CVEL_WW , 25,myIter,myThid)
        CALL READ_REC_YZ_RL(fn,prec,Nr, OBWw    , 26,myIter,myThid)
       ENDIF
#endif
      ENDIF
#endif /* ALLOW_OBCS_WEST */

C     Fill in edge regions
c      _EXCH_XZ_RL(UN_STORE_1 , myThid)
C      same with 2,3,4
C      same with VN_STORE_n, TN_STORE_n, SN_STORE_n, with n=1,2,3,4
C      same with XS_STORE_n, XE_STORE_N, XW_STORE_n, with X=U,V,T,S & n=1,2,3,4

c      _EXCH_XZ_RL(CVEL_UN , myThid)
C      same with CVEL_VN,  CVEL_TN,  CVEL_SN
C      same with CVEL_XS,  CVEL_XE,  CVEL_XW, with X=U,V,T,S
c#ifdef ALLOW_NONHYDROSTATIC
c      _EXCH_XZ_RL(WN_STORE_1 , myThid)
C      same with 2,3,4
C      same with WE_STORE_n, WE_STORE_n, WW_STORE_n, with n=1,2,3,4
c      _EXCH_XZ_RL(CVEL_WN , myThid)
C      same with CVEL_WS,  CVEL_WE,  CVEL_WW
c#endif

C--   Every one wait for thread 1 to finish (see comment @ the top)
      _BARRIER

#endif /* ALLOW_ORLANSKI */
      RETURN
      END
