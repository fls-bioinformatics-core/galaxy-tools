#!/bin/sh
#
# Shell wrapper to run Trimmomatic jar file as a Galaxy tool
echo Arguments:
for i in $@ ; do
    echo "*" $i
done

if [ -n "$CONDA_PREFIX" ] ; then
  # bioconda installs trimmomatic in a share directory
  # with a jarfile called trimmomatic.jar
  TRIMMOMATIC_DIR="$CONDA_PREFIX/share/trimmomatic"
  JARFILE="trimmomatic.jar"
else
  JARFILE="trimmomatic-0.36.jar"
fi

if [ -z "$TRIMMOMATIC_DIR" ] ; then
  echo "TRIMMOMATIC_DIR variable not set, can't find jar file"
  exit 1
fi

java -mx16G -jar $TRIMMOMATIC_DIR/$JARFILE $@ 2>&1 | tee trimmomatic.log
status=$?
echo "Exit status: $status"
# Check for successful completion
if [ -z "$(tail -1 trimmomatic.log | grep "Completed successfully")" ] ; then
    echo "Trimmomatic did not finish successfully" >&2
    exit 1
fi
exit $status
##
#
