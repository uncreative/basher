#!/bin/bash

# Xcode4 doesn't setup the environment
source ~/.bashrc


# Delete the URL part from the file passed in
fn=${BASH_ARGV#file://localhost}
echo "xcodeunlockp4 fn=" $fn  |logger


if [[ "$string" == *My* ]]
then
  echo "It's there!";
fi

if [[ $fn == *"p4_managed/BejBlitz"* ]]
then
 echo "xcodeunlockp4 exporting to iphone client" | logger
 export P4CLIENT=agoldin_bejblitz_adapt-touch-engineer_sea-mac-11577_managed
elif [[ $fn == *"p4_managed/Placerator"* ]]
then
 echo "xcodeunlockp4 exporting to placerator client" | logger
 export P4CLIENT=agoldin_placerator_trunk-engineer_sea-mac-11577_managed
elif [[ $fn == *"bejblitz_android"* ]]
then
 echo "xcodeunlockp4 exporting to android client" | logger
 export P4CLIENT=agoldin_bejblitz_android_trunk-engineer
elif [[ $fn == *"ResourceGen3"* ]]
then
 echo "xcodeunlockp4 exporting to ResourceGen3 client" | logger
 export P4CLIENT=agoldin_resourcegen3_main-engineer_sea-mac-11577_managed
else
 echo "xcodeunlockp4 Dont know this one... OOPS :(" | logger
fi



if [ -a ${fn} ]; then
    res=$(/usr/local/bin/p4 edit ${fn})

    # TODO: Report the status back to the user in Xcode
    # This output goes to the console.
    echo "xcodeunlockp4 " $res |logger
else
    echo "xcodeunlockp4 FnF" ${fn} | logger
fi