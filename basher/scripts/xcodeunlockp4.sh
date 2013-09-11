#!/bin/bash

###
#   1.2 - Released 9/27/2012 - tomahony
#         Updated to handle spaces in the folder/flle names
#   1.1 - Released 6/25/2012 - jhalbig
#
# A shell script for an Xcode 4 behavior to automatically check out a file
# whenever it is "unlocked" (made writable) in Xcode. This should work with
# Xcode 4.1 (which introduced the ability to run scripts as a behavior),
# But has only been tested with Xcode 4.3.1.
#
# Full instructions for setting up this script can be found at:
#
#    http://kb.perforce.com/article/1735

#
###


## Set the timeout interval for dismissing the dialog:
to=10

## Turn on all feedback (messages).
## If set to 1, the "p4 edit" command result is displayed
##  when unlocking a file from Xcode.
## If set to 0, the file is unlocked and checked out of Perforce
## silently (messages and errors will still be logged to console):
fb=1

# Xcode4 doesn't setup the environment, so we load it here:
bashrcfile=~/.bashrc.user
source ${bashrcfile}

# Delete the URL part from the file passed in from Xcode:
fn=${1#file://localhost}
echo "fn=" ${fn}
fn=$(printf $(echo -n $fn | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g') )
echo "fn=" ${fn}

# Get the enclosing directory for the file being unlocked:
fp=$(dirname "${fn}")
echo "fp=" ${fp}

# A check to confirm the current P4CONFIG setting:
conf=$(p4 -d "${fp}" set P4CONFIG 2>&1)
echo ${conf}

if [ -a "${fn}" ]; then

    # Save the dialog timeout to an environment variable:
    export XC_TO=${to}

    # Check the file out from Perforce:
    res=$(p4 -d "${fp}" edit "${fn}" 2>&1)
    echo "res=" ${res}

    # Save the result as an environment variable
    export XC_RES=${res}

    if [ ${fb} -gt 0 ]; then

        # Tell Xcode to display a dialog to with the result of the command.
        # The timeout is set by '${to}', above:
        osascript -e "tell application \"xcode\" to display dialog (system attribute \"XC_RES\") buttons {\"OK\"} default button 1 giving up after (system attribute \"XC_TO\")"
    fi
else
    echo "FnF" "${fn}"
fi

###
# Copyright (c) Perforce Software, Inc., 1997-2012. All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PERFORCE
# SOFTWARE, INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.