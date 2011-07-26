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


u=`whoami`
case $OSTYPE in
    darwin*)
        UHOME="/Users"
    ;;
    *)
        UHOME="/home"
		SKEL=/etc/skel
    ;;
esac

echo "INSTALLING FOR ${u} : ${UHOME}/${u}"

if [ -d ${UHOME}/${u} ] ; then
    MYBASHRCFILE=${UHOME}/${u}/.profile
    DESTINATION=${UHOME}/${u}/.etc
    #chmod -R oug+r $DESTINATION/basher
else
    echo "ERROR ${u} (whoami) doesn't have a home dir"
    exit
fi

echo "INSTALLING ./basher IN ${DESTINATION} TO BE READ BY $MYBASHRCFILE"

mkdir -p $DESTINATION
rsync -av --exclude=*.svn* ./basher $DESTINATION | grep -v "^sent " | grep -v "^total size "  | grep -v "^building file list"

outputifnotthere "source ${DESTINATION}/basher/bashrc # get some extra functions and configs" $MYBASHRCFILE




merge(){
    DEST=$1
    ORIG=$2
    if [ ${ORIG:0-4} = ".svn" ]; then
        return -2
    fi
    if [ -e ${DEST} ]; then
        diff_output=`diff -iw ${DEST} ${ORIG}`
        if [ "$diff_output" == "" ]; then
            return 1
        else
            return -1
        fi
    else
        return 1
    fi
}

files=`\ls -A skel/`
NOW=$(date +"%Y-%m-%d_%m%S")
BACKUP=${DESTINATION}/backup/${NOW}
mkdir -p $BACKUP

echo "REPLACING ${files} in ${UHOME}/${u} WITH files in skel/"
for f in $files ; do
    merge "${UHOME}/${u}/${f}" "skel/${f}" 
    UNCHANGED=$?
    
    if [ $UNCHANGED == -1 ]; then
        echo "backing up ${UHOME}/${u}/${f} ${$BACKUP}/${f}"
        mv "${UHOME}/${u}/${f}" "${$BACKUP}/${f}"
    fi
    if [ $UNCHANGED == -2 ]; then
        echo "ignoring skel/${f}"
    else
        rsync -av --exclude=*.svn* ./skel/${f} ${UHOME}/${u}/${f} | grep -v "^sent " | grep -v "^total size "  | grep -v "^building file list"
    fi
done











################# NOW CREATE USER/HOST OVERRIDES #################
if ! [ -f ${DESTINATION}/bashrc.hostspecific ]; then
    cp -v bashrc.hostspecific ${DESTINATION}/bashrc.hostspecific
fi    

echo ""
echo ""
echo ""
echo ""
echo "###   ***   ######   ***   ######   ***   ###"
echo "see $MYBASHRCFILE for bashrc file originally that is originally sourced everytime you start a shell. To make functions in this package work it now sources ${DESTINATION}/bash/bashrc as well"
echo "see ${DESTINATION}/bashrc.hostspecific to override configurations for this specific host."
echo "Place user's overrides and extra configurations in ~/.bashrc.user"
echo ""
echo "to get bonjour name completion on osx check out: http://www.jonathonmah.com/devetc/projects/playhaus/bonjour_lister/main etc/basher/init/completion/ssh will automatically use it to complete for ssh"
echo ""
echo ""
echo ""
echo "###   ***   ######   ***   ######   ***   ###"

############### CLEANUP ###########
echo "cleaning up"
rm -rf ${SKEL_ORIG}