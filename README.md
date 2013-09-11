terminal configuration with bash
================================

bash editing in terminal
-------------------------
* up / down searches history
* match all files including hidden files
* when pressing tab for completion, show all the options if there's more than one
* ignore case when completing

prompt
-------------------------
<pre>environment <b>yourusername@yourhost:/path/to/current/dir</b> [lastcommandnumber]$</pre>

* environment:
if current server is production, there will be a red background with gray word saying prod
if current server is test or labs, yellow
otherwise (and by default) it is development and has normal black color
to change environment create a file in ~/.etc/server-role or ~/.server-role

* [lastcommandnumber] yellow if last command exited without error codes, or red if there was a non-zero exit code

* if you have jobs running in the background ( by using & or ctrl-z )
the prompt will indicating how many:
<pre>environment <b>yourusername@yourhost:/path/to/current/dir (numberofjobs)</b> [lastcommandnumber]$</pre>

* if you are in a directory which is a git repository the name of the current branch will show:
<pre>environment <b>yourusername@yourhost:/path/to/current/dir (nameofbranch)</b> [lastcommandnumber]$</pre>


misc
-------------------------
* confirm before remove / overwrite
* color ls output
* color grep output
* use lesspipe if there
* better autocompletion for ssh, uses .ssh/config and potentially bonjour
* better autocompletion for xcode
* recursively remove from current directories annoying files: rm .svn (rmsvn), DS_Store (rmDS_STORE) and pyc (rmpyc)
* alias for showing python site packages: pysitepackages
* wrangle : open with textwrangle in OS X
* dashboardkill : kill dashboard screen in OS X
* hibernateon | hibernateoff : allow hibernation sleep mode in OS X

net alias
-------------------------
* scpresume : copy remotely (or locally) using rsync with resume capabilities
* myip : show my external ip
* ips : show my various local ip (wifi, ethernet etc)

use fancy cd function that allows :
-------------------------
```bash
cd --
# to see a list of recent directories, with a numerical menu
cd -2
# to go to the second-most recent directory.
```

history
-------------------------
* automatically remember last month's history file for every month in ~/.history directory
new file for the current month is created and contains last 1500 lines from last month's file

* maximum file size: 500000
* ensure histories from multiple running terminals don't overwrite themselves
* multi-line commands are stored in the history as a single command

* expand commands and allow editing them before running them: ie, when you type !-1 pressing enter would usually run the previous command, now it will show the previous command allowing you to change it first.
for instance you can do:

```bash
$ python snake.py --width 10 --height 10 --timeBetweenUpdates 0.5 --verbose
$ ^snake^worm
# normally this would just run:
# python worm.py --width 10 --height 10 --timeBetweenUpdates 0.5 --verbose
# instead in our case you'll it'll be expanded in the terminal as a line you are typing to
$ python worm.py --width 10 --height 10 --timeBetweenUpdates 0.5 --verbose
# and you would verify this is the command you wanted and make edits before running.
```

svn:
-------------------------
* svnundocommit : merge the previous version from svn
* sup : svn update and show what has changed
* better autocompletion
* svnchangessince.sh script to see log of changes since last update


scripts
-------------------------
* proxy scripts to try and use ipfw natd and ssh tunnels as fake vpn
* ssh-copy-id script so that you don't have to type your passwords when ssh-ing
* xcodeunlockp4: script behavior to tell xcode what to do when a file is locked and you are using xcode


Install
================================

for your own user
-------------------------
```bash
git clone https://github.com/uncreative/basher.git
bashergitsource=`pwd`
mkdir ~/.etc && cd ~/.etc
ln -s $bashergitsource/basher/bashrc.hostspecific.sh .
ln -s $bashergitsource/basher/basher .
ln -s $bashergitsource/basher/.inputrc ~/
ln -s $bashergitsource/basher/.bashrc ~/
mkdir ~/.history
mkdir ~/.ssh
touch ~/.ssh/config
```

in .bash_profile or whichever file OS X now reads when you start terminal, append:
```bash
        echo "source $HOME/.bashrc # get some extra functions and configs" >> ~/.bash_profile
```

to make additional user specific configurations that are remembered in Dropbox:
```
mkdir -p ~/Dropbox/config
touch ~/Dropbox/config/.bashrc.user.sh
ln -s ~/Dropbox/config/.bashrc.user.sh ~/
# make changes to above with your favorite editor
```


for everyone
-------------------------
do something like this. this requires sudo and has not been tested. use with care...

```bash

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
files= ".inputrc" # `\ls -A skel/`
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
    cp -v bashrc.hostspecific /etc/bashrc.hostspecific.sh
fi

if ! [ -f "${SKEL}/.bashrc.user.sh" ]; then
    touch "${SKEL}/.bashrc.user.sh"
fi
echo ""
echo ""
echo ""
echo ""
echo "###   ***   ######   ***   ######   ***   ###"
echo "see ${SKEL}/ for dot files created with every user"
echo "see $HOSTBASHRCFILE for bashrc file originally that is originally sourced everytime you start a shell. To make functions in this package work it now sources /etc/bash/bashrc as well"
echo "see /etc/bashrc.hostspecific.sh to override configurations for this specific host."
echo "Place user's overrides and extra configurations in ~/.bashrc.user.sh (which is now generated in ${SKEL})"
echo ""
echo "to get bonjour name completion on osx check out: http://www.jonathonmah.com/devetc/projects/playhaus/bonjour_lister/main etc/basher/init/completion/ssh will automatically use it to complete for ssh"
echo ""
echo ""
echo ""
echo "###   ***   ######   ***   ######   ***   ###"

############### CLEANUP ###########
echo "cleaning up"
rm -rf ${SKEL_ORIG}


```
