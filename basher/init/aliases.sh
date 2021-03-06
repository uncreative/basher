# ALIASES

# Don't overwrite/delete without asking me first!
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# function shortcuts
alias cd=cd_func
alias ips='ifconfig | grep "inet "'
alias sup='svn_up_and_log'
# file merge diff for svn
#undo prev commit:
alias svnundocommit='svn merge -r COMMITTED:PREV .'

alias scpresume='rsync --partial --progress -avzr'

alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"


# fix ls
export LS_OPTIONS='--color=auto'

case $OSTYPE in
    cygwin*)
        export CLICOLOR='true'
    ;;
    darwin*)
        alias killtunnelandproxy='sudo killall natd & sudo ipfw -f flush & sudo sysctl -w net.inet.ip.fw.verbose=0 && killall ssh'
        # gui svn diff with file merge. requires developers tools installed and http://soft.vub.ac.be/svn-gen/bdefrain/fmscripts
        alias sfmdiff='svn diff --diff-cmd fmdiff'

        # easily hibernate or not
        alias hibernateon='sudo pmset -a hibernatemode 1'
        alias hibernateoff='sudo pmset -a hibernatemode 0'

        alias dashboardkill='defaults write com.apple.dashboard mcx-disabled -boolean YES && killall Dock'

		# textwrangler from command line
		alias wrangle='open -b com.barebones.textwrangler'

		whichls=`which ls`
	    if [ "$whichls" == "/bin/ls" ]; then
			export LS_OPTIONS=''
			export CLICOLOR=1
			export LSCOLORS=ExFxCxDxBxegedabagacad
		fi

    ;;
    linux*)
    ;;
	*)
    ;;
esac



if [ -f /usr/local/bin/src-hilite-lesspipe.sh ]; then
    export LESSOPEN="| /usr/local/bin/src-hilite-lesspipe.sh %s"
    export LESS=' -R '
fi


alias ls='ls $LS_OPTIONS -F -axh'

alias grep="grep --color"

# delete extras
alias rmsvn='find . -name .svn -exec rm -rf "{}" \;'
alias rmpyc='find . -name "*.pyc" -exec rm -rf "{}" \;'
alias rmDS_STORE='find . -name ".DS_Store" -exec rm -rf "{}" \;'

# python
alias pysitepackages='python -c "from distutils.sysconfig import get_python_lib; print( get_python_lib())"'

alias logcatb='logcat-color bejblitz'
alias gdbb='ndk-gdb --start --verbose --force --exec=~/.gdbinitndk'
alias logcatsym='adb logcat –d | ~/p4_managed/BejBlitz/adapt_touch_engineer/BejBlitz/projects/android/ndk-symbolicate ~/p4_managed/BejBlitz/adapt_touch_engineer/BejBlitz/projects/android/obj/local/armeabi'
