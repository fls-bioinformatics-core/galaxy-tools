#!/bin/sh
#
# Shell wrapper to run Trimmomatic jar file as a Galaxy tool
echo $@
java $@ 2>&1 | tee trimmomatic.log
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