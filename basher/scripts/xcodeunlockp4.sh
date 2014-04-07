#!/bin/sh

bashrcfile=~/.bashrc
source ${bashrcfile}


RESULT=`p4 edit  ${1#file://} 2>&1`
SHRESULT=$?

while [ $SHRESULT -ne 0 ]
    do
    SCRIPT="tell application \"XCode\" to display dialog \"$RESULT\" buttons {\"Try again\",\"Cancel\"} default button 1"
    osascript -e "$SCRIPT"
    if [ $? -ne 0 ]
    then
        break
    fi
    RESULT=`p4 edit  ${1#file://localhost} 2>&1`
    SHRESULT=$?
done

exit $SHRESULT