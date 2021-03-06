C $Header: /u/gcmpack/MITgcm/pkg/seaice/seaice_ad_dump.F,v 1.6 2009/08/27 18:00:01 jmc Exp $
C $Name:  $

#include "AD_CONFIG.h"
#include "PACKAGES_CONFIG.h"
#include "SEAICE_OPTIONS.h"

CBOP
C     !ROUTINE: seaice_ad_dump
C     !INTERFACE:
      subroutine seaice_ad_dump( mytime, myiter, myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE seaice_ad_dump                           |
C     *==========================================================*
C     Extract adjoint variable from TAMC/TAF-generated
C     adjoint common blocks, contained in adcommon.h
C     and write fields to file;
C     Make sure common blocks in adcommon.h are up-to-date
C     w.r.t. current adjoint code.
C     *==========================================================*
C     | SUBROUTINE seaice_ad_dump                           |
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE

C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SEAICE_PARAMS.h"
#ifdef ALLOW_MNC
#include "MNC_PARAMS.h"
#endif
#include "GRID.h"
#ifdef ALLOW_AUTODIFF_MONITOR
# include "adcommon.h"
#endif

      LOGICAL  DIFFERENT_MULTIPLE
      EXTERNAL DIFFERENT_MULTIPLE
      INTEGER  IO_ERRCOUNT
      EXTERNAL IO_ERRCOUNT

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myIter - iteration counter for this thread
C     myTime - time counter for this thread
C     myThid - Thread number for this instance of the routine.
      integer myThid
      integer myiter
      _RL     mytime

#if (defined (ALLOW_ADJOINT_RUN) || defined (ALLOW_ADMTLM))
#ifdef ALLOW_AUTODIFF_MONITOR

C     !LOCAL VARIABLES:
c     == local variables ==
C     suff - Hold suffix part of a filename
C     beginIOErrCount - Begin and end IO error counts
C     endIOErrCount
C     msgBuf - Error message buffer
      CHARACTER*(MAX_LEN_FNAM) suff
      INTEGER beginIOErrCount
      INTEGER endIOErrCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf

c     == end of interface ==
CEOP

      call TIMER_START('I/O (WRITE)        [ADJOINT LOOP]', myThid )

      IF (
     &  DIFFERENT_MULTIPLE(adjDumpFreq,mytime,deltaTClock)
     & ) THEN

C--     Set suffix for this set of data files.
        WRITE(suff,'(I10.10)') myIter
        writeBinaryPrec = writeStatePrec

C--     Read IO error counter
        beginIOErrCount = IO_ERRCOUNT(myThid)

        CALL WRITE_REC_3D_RL(
     &       'ADJarea.'//suff, writeBinaryPrec,
     &       1,  adarea, 1, myIter, myThid )
        CALL WRITE_REC_3D_RL(
     &       'ADJheff.'//suff, writeBinaryPrec,
     &       1,  adheff, 1, myIter, myThid )
        CALL WRITE_REC_3D_RL(
     &       'ADJhsnow.'//suff, writeBinaryPrec,
     &       1,  adhsnow, 1, myIter, myThid )
# ifdef SEAICE_ALLOW_DYNAMICS
cph        IF ( SEAICEuseDynamics ) THEN
          CALL WRITE_REC_3D_RL(
     &       'ADJuice.'//suff, writeBinaryPrec,
     &       1,  aduice, 1, myIter, myThid )
          CALL WRITE_REC_3D_RL(
     &       'ADJvice.'//suff, writeBinaryPrec,
     &       1,  advice, 1, myIter, myThid )
cph        ENDIF
# endif

#ifdef ALLOW_MNC
        IF (useMNC .AND. autodiff_mnc) THEN

          CALL MNC_CW_SET_UDIM('adseaice', -1, myThid)
          CALL MNC_CW_RL_W_S('D','adseaice',0,0,'T',myTime,myThid)
          CALL MNC_CW_SET_UDIM('adseaice', 0, myThid)
          CALL MNC_CW_I_W_S('I','adseaice',0,0,'iter',myIter,myThid)
          CALL MNC_CW_RL_W_S('D','adseaice',0,0,'model_time',myTime,
     &         myThid)
c
          CALL MNC_CW_RL_W('D','adseaice',0,0,'adarea',
     &         adarea, myThid)
          CALL MNC_CW_RL_W('D','adseaice',0,0,'adheff',
     &         adheff, myThid)
          CALL MNC_CW_RL_W('D','adseaice',0,0,'adhsnow',
     &         adhsnow, myThid)
# ifdef SEAICE_ALLOW_DYNAMICS
          IF (SEAICEuseDYNAMICS) THEN
            CALL MNC_CW_RL_W('D','adseaice',0,0,'aduice',
     &         aduice, myThid)
            CALL MNC_CW_RL_W('D','adseaice',0,0,'advice',
     &         advice, myThid)
          ENDIF
# endif

        ENDIF
#endif /* ALLOW_MNC */

      ENDIF

      CALL TIMER_STOP( 'I/O (WRITE)        [ADJOINT LOOP]', myThid )

#endif /* ALLOW_AUTODIFF_MONITOR */
#endif /* ALLOW_ADJOINT_RUN */

      RETURN
      END
