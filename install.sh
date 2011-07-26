#!/bin/bash
outputifnotthere ()
{
    LINE="$1"
    TOFILE="$2"
    grep_output=`grep "^$LINE" $TOFILE`
    if [ "$grep_output" == "" ]; then
        echo "" >> $TOFILE
        echo $LINE >> $TOFILE
        echo "appending $LINE to $TOFILE"
    else
        echo "$LINE already in $TOFILE";
    fi
}


case $OSTYPE in
    darwin*)
    	USERS=`dscl . -list /Users NFSHomeDirectory | perl -i -pe 'if(m/^(\S+)\s+\/Users\/\S+/) { $_ = "$1 " } else { $_ = "" }'`
        UHOME="/Users"
		SKEL="/System/Library/User Template/English.lproj"
    ;;
    *)
        USERS=$(grep /home/ /etc/passwd | awk -F":" '{ print $1  }') # get list of all users
        UHOME="/home"
		SKEL=/etc/skel
    ;;
esac



if [ ! -e "${SKEL}" ]; then
    echo "can't find skeleton directory /etc/skel or /System/Library/User\ Template/English.lproj"
    exit
fi


if [ -f /etc/bash.bashrc ]; then
    HOSTBASHRCFILE=/etc/bash.bashrc
elif [ -f /etc/bashrc ]; then
    HOSTBASHRCFILE=/etc/bashrc
else
    echo "can't find host bashrc file /etc/bashrc or /etc/bash.bashrc"
    exit
fi

echo "COPYING HOST CONFIGURATION"
cp -Rv basher /etc
chmod -R oug+r /etc/basher


# copying skeleton to $SKEL
rm -rf ~/tmp.skel.orig
SKEL_ORIG=~/tmp.skel.orig
mkdir "${SKEL_ORIG}"
echo "COPYING SKELETON"
files=`\ls -A skel/`
echo "====== FILES ========"
echo "${files}"
for f in $files ; do
	echo "${f}"
	if [ -e "${SKEL}/${f}" ]; then
		cp -Rv "${SKEL}/${f}" "${SKEL_ORIG}"
	fi
	cp -Rv "skel/${f}" "${SKEL}/"
done


declare -a skelappends

outputifnotthere "source /etc/basher/bashrc # get some extra functions and configs" $HOSTBASHRCFILE

if command -v port &>/dev/null
then
    if [ -e /Applications/MacPorts ]; then
        port contents coreutils | perl -nle 'print "alias $1=g$1" if m{/opt/local/bin/g(\w+)}' > ${SKEL}/.portaliases
        declare -a arr
        LINE="source ~/.portaliases # alias gnu port commands without the g"
        TOFILE=.bashrc
        arr=( "${LINE}" "${TOFILE}" )
        outputifnotthere "${LINE}" "${SKEL}/${TOFILE}"
        #outputifnotthere ${arr[@]}
        skelappends=( "${skelappends[@]}" "${arr[@]}" )
    fi
fi


merge(){
    DEST=$1
    ORIG=$2
    if [ ${ORIG:0-4} = ".svn" ]; then
        return -1
    fi
    if [ -e ${DEST} ]; then
        diff_output=`diff -iw ${DEST} ${ORIG}`
        if [ "$diff_output" == "" ]; then
            echo "replacing unchanged ${DEST} with new one in skel"
            return 1
        else
            echo "not copying to ${DEST} - file which was modified from original skeleton already exists"
            return -1
        fi
    else
        return 1
    fi
}



# copy skeleton to every user
echo "users ${USERS}"
for u in $USERS ; do
    echo "${u}: ${UHOME}/${u}"
    if [ -d ${UHOME}/${u} ] ; then
        echo "MERGING ${files} in skel/ WITH ${UHOME}/${u}"
        for f in $files ; do
            merge "${UHOME}/${u}/${f}" "${SKEL_ORIG}/${f}" 
            REPLACE=$?
            echo "replacing skel/${f} $REPLACE \? $?"
        
            if [ $REPLACE == 1 ]; then
                cp -Rp skel/${f} ${UHOME}/${u}/${f}
                chown $(id -un $u):$(id -gn $u) ${UHOME}/${u}/${f}
            fi
        done

        # append what was appended to skel files (modifies even changed user files to incorporate new code)
        for line2file in "${skelappends[@]}"
        do
            LINE=${line2file[0]}
            TOFILE=${line2file[1]}
            outputifnotthere "${LINE}" "${UHOME}/${u}/${TOFILE}"
        done
    else
        echo "ERROR ${u} doesn't have a home dir"
    fi
done


################# NOW CREATE USER/HOST OVERRIDES #################
if ! [ -f /etc/bashrc.hostspecific ]; then
    cp -v bashrc.hostspecific /etc/bashrc.hostspecific
fi    

if ! [ -f "${SKEL}/.bashrc.user" ]; then
    touch "${SKEL}/.bashrc.user"
fi
echo ""
echo ""
echo ""
echo ""
echo "###   ***   ######   ***   ######   ***   ###"
echo "see ${SKEL}/ for dot files created with every user"
echo "see $HOSTBASHRCFILE for bashrc file originally that is originally sourced everytime you start a shell. To make functions in this package work it now sources /etc/bash/bashrc as well"
echo "see /etc/bashrc.hostspecific to override configurations for this specific host."
echo "Place user's overrides and extra configurations in ~/.bashrc.user (which is now generated in ${SKEL})"
echo ""
echo "to get bonjour name completion on osx check out: http://www.jonathonmah.com/devetc/projects/playhaus/bonjour_lister/main etc/basher/init/completion/ssh will automatically use it to complete for ssh"
echo ""
echo ""
echo ""
echo "###   ***   ######   ***   ######   ***   ###"

############### CLEANUP ###########
echo "cleaning up"
rm -rf ${SKEL_ORIG}