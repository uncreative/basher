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

if [ -d /etc/basher ] ; then
    export ETC=/etc
else
    export ETC=${UHOME}/${u}/.etc
fi

export BASHINITPATH=$ETC/basher/init
export BASHFUNCPATH=$ETC/basher/func
export BASHSCRIPTS=$ETC/basher/scripts
export PATH=$PATH:$BASHSCRIPTS

case $OSTYPE in
    cygwin*)
        #source $BASHINITPATH/winpython
        export TERM=xterm
        funcdir=cygwin
    ;;
    darwin*)
        # to stop Finder writing .DS_Store files on network volumes
        # does this need to be commented out?
        defaults write com.apple.desktopservices DSDontWriteNetworkStores true
        # source $BASHINITPATH/fink
        funcdir=darwin
        # does this need to be commented out?
		export TERM=xterm-color
    ;;
    linux*)
        funcdir=linux
    ;;
    *)
    ;;
esac


sourcedirifthere () { # doesn't work in linux
    local DIRtoSOURCE="$1"

    for script in $DIRtoSOURCE/[a-zA-Z0-9]* ; do
        if [ -r $script ] ; then
            sourc $script
        fi
    done
}
#doesn't work in linux
#sourcedirifthere /etc/bash/func/all
#sourcedirifthere /etc/bash/func/$funcdir

# define some functions

# some more functions
if [ -e $BASHFUNCPATH/all ]; then
for cmd in $BASHFUNCPATH/all/* ; do
    source $cmd
done
fi
# define some functions
if [ -e $BASHFUNCPATH/$funcdir ]; then
for cmd in $BASHFUNCPATH/$funcdir/* ; do
    source $cmd
done
fi

if command -v dircolors &>/dev/null
then
	if [ -f $HOME/.dircolors ]; then
		dir_colors_file=$HOME/.dircolors
	else
		dir_colors_file=$BASHINITPATH/dir_colors
	fi
	eval `dircolors $dir_colors_file`
fi


# set some options
source $BASHINITPATH/loadcompleters.sh
source $BASHINITPATH/histopts.sh
source $BASHINITPATH/aliases.sh
source $BASHINITPATH/prompt.sh
source $BASHINITPATH/thirdparty.sh

if [ -f $ETC/bashrc.hostspecific ]; then
    source $ETC/bashrc.hostspecific
fi

unset funcdir

# allows using git with https
export GIT_SSL_NO_VERIFY=true

################# NOW OVERRIDE WITH USER SPECIFIC #################

if [ -f $HOME/.bashrc.user.sh ]; then
    source $HOME/.bashrc.user.sh
fi
