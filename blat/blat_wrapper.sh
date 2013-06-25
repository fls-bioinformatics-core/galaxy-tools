#!/bin/sh -e
#
# Wrapper script to run blat/pslReps etc as a Galaxy tool
#
# Usage: blat_wrapper.sh DATABASE QUERY PSL_OUT [ARGS..]
#
# Args:
#
# --run_pslReps BEST_PSL_OUT PSR_OUT
#
# Initialise from command line
DATABASE=$1
QUERY=$2
PSL_OUT=$3
#
# Process optional arguments
BEST_PSL_OUT=
PSR_OUT=
PSLREPS_MIN_COVER=0.15
PSLREPS_MIN_ALI=0.96
PSLREPS_NEAR_TOP=0.001
#
while [ ! -z "$4" ] ; do
    case $4 in
	--run_pslReps)
	    shift
	    BEST_PSL_OUT=$4
	    shift
	    PSR_OUT=$4
	    ;;
	--minCover)
	    shift
	    PSLREPS_MIN_COVER=$4
	    ;;
	--minAli)
	    shift
	    PSLREPS_MIN_ALI=$4
	    ;;
	--nearTop)
	    shift
	    PSLREPS_NEAR_TOP=$4
	    ;;
    esac
    shift
done
#
# Run BLAT (to do the alignments)
blat_cmd="blat $DATABASE $QUERY aligned.psl"
echo Running $blat_cmd
$blat_cmd
if [ ! -f aligned.psl ] ; then
    echo BLAT failed to generate alignments >&2
    exit 1
fi
#
# Run pslReps (to get the best/repeated alignments)
if [ ! -z "$BEST_PSL_OUT" ] ; then
    pslReps_cmd="pslReps -minCover=$PSLREPS_MIN_COVER -minAli=$PSLREPS_MIN_ALI -nearTop=$PSLREPS_NEAR_TOP aligned.psl aligned_best.psl repeats.psr"
    echo Running $pslReps_cmd
    $pslReps_cmd
    if [ ! -f aligned_best.psl ] || [ ! -f repeats.psr ] ; then
	echo pslReps failed to generate expected output files >&2
	exit 1
    fi
fi
#
# Move outputs to their final locations
/bin/mv aligned.psl $PSL_OUT
if [ ! -z "$BEST_PSL_OUT" ] ; then
    /bin/mv aligned_best.psl $BEST_PSL_OUT
    /bin/mv repeats.psr $PSR_OUT
fi
##
#