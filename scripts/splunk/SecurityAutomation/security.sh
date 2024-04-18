#!/bin/bash
if [ $# -ne 1 ]
then
echo "
User controller for the secService module used in Splunk automation.
---------------------------------------------------------------------

-h     |     Help menu

-r     |     Refreshes the service, used in the case of password and/or other config change.

-s     |     Displays operational status of all involved scripts and/or files.

"
exit -1
fi
if [ $1 == "-r" || $1 == "-R" ]
then
python3 /bin/security.py -r
fi
if [ $1 == "-s" || $1 == "-S" ]
then
python3 /bin/security.py -s
fi